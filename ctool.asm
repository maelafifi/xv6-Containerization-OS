
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
  5d:	e8 f2 06 00 00       	call   754 <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 e8 0c 00 	movl   $0xce8,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 a2 08 00 00       	call   921 <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 bd 06 00 00       	call   754 <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 e8 0c 00 	movl   $0xce8,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 6d 08 00 00       	call   921 <printf>
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
  cf:	e8 60 06 00 00       	call   734 <write>
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
  ec:	e8 3b 06 00 00       	call   72c <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 37 06 00 00       	call   73c <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 2c 06 00 00       	call   73c <close>
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <init>:

void init(){
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 08             	sub    $0x8,%esp


	container_init();
 118:	e8 1f 07 00 00       	call   83c <container_init>

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
 12e:	e8 49 06 00 00       	call   77c <mkdir>
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
 179:	c7 44 24 04 00 0d 00 	movl   $0xd00,0x4(%esp)
 180:	00 
 181:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 188:	e8 94 07 00 00       	call   921 <printf>

		char dir[strlen(c_args[0])];
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	8b 00                	mov    (%eax),%eax
 192:	89 04 24             	mov    %eax,(%esp)
 195:	e8 b1 03 00 00       	call   54b <strlen>
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
 1d2:	e8 0e 03 00 00       	call   4e5 <strcpy>
		strcat(dir, "/");
 1d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1da:	c7 44 24 04 05 0d 00 	movl   $0xd05,0x4(%esp)
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
 214:	c7 44 24 04 07 0d 00 	movl   $0xd07,0x4(%esp)
 21b:	00 
 21c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 223:	e8 f9 06 00 00       	call   921 <printf>

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
 272:	e8 dd 04 00 00       	call   754 <open>
 277:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 27a:	8b 45 0c             	mov    0xc(%ebp),%eax
 27d:	89 04 24             	mov    %eax,(%esp)
 280:	e8 ff 04 00 00       	call   784 <chdir>
	// chroot(dir);

	/* fork a child and exec argv[1] */
	id = fork();
 285:	e8 82 04 00 00       	call   70c <fork>
 28a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 28d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 291:	75 70                	jne    303 <attach_vc+0xa5>
		close(0);
 293:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 29a:	e8 9d 04 00 00       	call   73c <close>
		close(1);
 29f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a6:	e8 91 04 00 00       	call   73c <close>
		close(2);
 2ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2b2:	e8 85 04 00 00       	call   73c <close>
		dup(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 ca 04 00 00       	call   78c <dup>
		dup(fd);
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	89 04 24             	mov    %eax,(%esp)
 2c8:	e8 bf 04 00 00       	call   78c <dup>
		dup(fd);
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	89 04 24             	mov    %eax,(%esp)
 2d3:	e8 b4 04 00 00       	call   78c <dup>
		exec(file, &file);
 2d8:	8b 45 10             	mov    0x10(%ebp),%eax
 2db:	8d 55 10             	lea    0x10(%ebp),%edx
 2de:	89 54 24 04          	mov    %edx,0x4(%esp)
 2e2:	89 04 24             	mov    %eax,(%esp)
 2e5:	e8 62 04 00 00       	call   74c <exec>
		printf(1, "Failure to attach VC.");
 2ea:	c7 44 24 04 16 0d 00 	movl   $0xd16,0x4(%esp)
 2f1:	00 
 2f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f9:	e8 23 06 00 00       	call   921 <printf>
		exit();
 2fe:	e8 11 04 00 00       	call   714 <exit>
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
 312:	e8 1d 05 00 00       	call   834 <is_full>
 317:	89 45 f0             	mov    %eax,-0x10(%ebp)
 31a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 31e:	79 19                	jns    339 <start+0x34>
		printf(1, "No Available Containers.\n");
 320:	c7 44 24 04 2c 0d 00 	movl   $0xd2c,0x4(%esp)
 327:	00 
 328:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 32f:	e8 ed 05 00 00       	call   921 <printf>
		return;
 334:	e9 a6 00 00 00       	jmp    3df <start+0xda>
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

	printf(1, "Open container at %d\n", index);
 35a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 35d:	89 44 24 08          	mov    %eax,0x8(%esp)
 361:	c7 44 24 04 46 0d 00 	movl   $0xd46,0x4(%esp)
 368:	00 
 369:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 370:	e8 ac 05 00 00       	call   921 <printf>

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	8b 00                	mov    (%eax),%eax
 37a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* dir = s_args[1];
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	8b 40 04             	mov    0x4(%eax),%eax
 383:	89 45 e8             	mov    %eax,-0x18(%ebp)
	char* file = s_args[2];
 386:	8b 45 08             	mov    0x8(%ebp),%eax
 389:	8b 40 08             	mov    0x8(%eax),%eax
 38c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if(find(dir) == 0){
 38f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 392:	89 04 24             	mov    %eax,(%esp)
 395:	e8 92 04 00 00       	call   82c <find>
 39a:	85 c0                	test   %eax,%eax
 39c:	75 16                	jne    3b4 <start+0xaf>
		printf(1, "Container already in use.\n");
 39e:	c7 44 24 04 5c 0d 00 	movl   $0xd5c,0x4(%esp)
 3a5:	00 
 3a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3ad:	e8 6f 05 00 00       	call   921 <printf>
		return;
 3b2:	eb 2b                	jmp    3df <start+0xda>
	}

	set_name(dir, index);
 3b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 3bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 3be:	89 04 24             	mov    %eax,(%esp)
 3c1:	e8 2e 04 00 00       	call   7f4 <set_name>
	//ASsume they give us the values for now
	// set_max_proc(atoi(s_args[3]), index);
	// set_max_mem(atoi(s_args[4]), index);
	// set_max_disk(atoi(s_args[5]), index);

	attach_vc(vc, dir, file);
 3c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3c9:	89 44 24 08          	mov    %eax,0x8(%esp)
 3cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 3d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d7:	89 04 24             	mov    %eax,(%esp)
 3da:	e8 7f fe ff ff       	call   25e <attach_vc>
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 3df:	c9                   	leave  
 3e0:	c3                   	ret    

000003e1 <pause>:

void pause(char *c_name){
 3e1:	55                   	push   %ebp
 3e2:	89 e5                	mov    %esp,%ebp

}
 3e4:	5d                   	pop    %ebp
 3e5:	c3                   	ret    

000003e6 <resume>:

void resume(char *c_name){
 3e6:	55                   	push   %ebp
 3e7:	89 e5                	mov    %esp,%ebp

}
 3e9:	5d                   	pop    %ebp
 3ea:	c3                   	ret    

000003eb <stop>:

void stop(char *c_name){
 3eb:	55                   	push   %ebp
 3ec:	89 e5                	mov    %esp,%ebp

}
 3ee:	5d                   	pop    %ebp
 3ef:	c3                   	ret    

000003f0 <info>:

void info(char *c_name){
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp

}
 3f3:	5d                   	pop    %ebp
 3f4:	c3                   	ret    

000003f5 <main>:

int main(int argc, char *argv[]){
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	83 e4 f0             	and    $0xfffffff0,%esp
 3fb:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "init") == 0){
 3fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 401:	83 c0 04             	add    $0x4,%eax
 404:	8b 00                	mov    (%eax),%eax
 406:	c7 44 24 04 77 0d 00 	movl   $0xd77,0x4(%esp)
 40d:	00 
 40e:	89 04 24             	mov    %eax,(%esp)
 411:	e8 fd 00 00 00       	call   513 <strcmp>
 416:	85 c0                	test   %eax,%eax
 418:	75 0a                	jne    424 <main+0x2f>
		init();
 41a:	e8 f3 fc ff ff       	call   112 <init>
 41f:	e9 80 00 00 00       	jmp    4a4 <main+0xaf>
	}
	else if(strcmp(argv[1], "create") == 0){
 424:	8b 45 0c             	mov    0xc(%ebp),%eax
 427:	83 c0 04             	add    $0x4,%eax
 42a:	8b 00                	mov    (%eax),%eax
 42c:	c7 44 24 04 7c 0d 00 	movl   $0xd7c,0x4(%esp)
 433:	00 
 434:	89 04 24             	mov    %eax,(%esp)
 437:	e8 d7 00 00 00       	call   513 <strcmp>
 43c:	85 c0                	test   %eax,%eax
 43e:	75 24                	jne    464 <main+0x6f>
		printf(1, "Calling create\n");
 440:	c7 44 24 04 83 0d 00 	movl   $0xd83,0x4(%esp)
 447:	00 
 448:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 44f:	e8 cd 04 00 00       	call   921 <printf>
		create(&argv[2]);
 454:	8b 45 0c             	mov    0xc(%ebp),%eax
 457:	83 c0 08             	add    $0x8,%eax
 45a:	89 04 24             	mov    %eax,(%esp)
 45d:	e8 bd fc ff ff       	call   11f <create>
 462:	eb 40                	jmp    4a4 <main+0xaf>
	}
	else if(strcmp(argv[1], "start") == 0){
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	83 c0 04             	add    $0x4,%eax
 46a:	8b 00                	mov    (%eax),%eax
 46c:	c7 44 24 04 93 0d 00 	movl   $0xd93,0x4(%esp)
 473:	00 
 474:	89 04 24             	mov    %eax,(%esp)
 477:	e8 97 00 00 00       	call   513 <strcmp>
 47c:	85 c0                	test   %eax,%eax
 47e:	75 10                	jne    490 <main+0x9b>
		start(&argv[2]);
 480:	8b 45 0c             	mov    0xc(%ebp),%eax
 483:	83 c0 08             	add    $0x8,%eax
 486:	89 04 24             	mov    %eax,(%esp)
 489:	e8 77 fe ff ff       	call   305 <start>
 48e:	eb 14                	jmp    4a4 <main+0xaf>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 490:	c7 44 24 04 9c 0d 00 	movl   $0xd9c,0x4(%esp)
 497:	00 
 498:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 49f:	e8 7d 04 00 00       	call   921 <printf>
	}
	printf(1, "Done with ctool\n");
 4a4:	c7 44 24 04 d7 0d 00 	movl   $0xdd7,0x4(%esp)
 4ab:	00 
 4ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4b3:	e8 69 04 00 00       	call   921 <printf>

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
 4b8:	e8 57 02 00 00       	call   714 <exit>
 4bd:	90                   	nop
 4be:	90                   	nop
 4bf:	90                   	nop

000004c0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	57                   	push   %edi
 4c4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4c8:	8b 55 10             	mov    0x10(%ebp),%edx
 4cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ce:	89 cb                	mov    %ecx,%ebx
 4d0:	89 df                	mov    %ebx,%edi
 4d2:	89 d1                	mov    %edx,%ecx
 4d4:	fc                   	cld    
 4d5:	f3 aa                	rep stos %al,%es:(%edi)
 4d7:	89 ca                	mov    %ecx,%edx
 4d9:	89 fb                	mov    %edi,%ebx
 4db:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4de:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4e1:	5b                   	pop    %ebx
 4e2:	5f                   	pop    %edi
 4e3:	5d                   	pop    %ebp
 4e4:	c3                   	ret    

000004e5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4e5:	55                   	push   %ebp
 4e6:	89 e5                	mov    %esp,%ebp
 4e8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4f1:	90                   	nop
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
 4f5:	8d 50 01             	lea    0x1(%eax),%edx
 4f8:	89 55 08             	mov    %edx,0x8(%ebp)
 4fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 4fe:	8d 4a 01             	lea    0x1(%edx),%ecx
 501:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 504:	8a 12                	mov    (%edx),%dl
 506:	88 10                	mov    %dl,(%eax)
 508:	8a 00                	mov    (%eax),%al
 50a:	84 c0                	test   %al,%al
 50c:	75 e4                	jne    4f2 <strcpy+0xd>
    ;
  return os;
 50e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 511:	c9                   	leave  
 512:	c3                   	ret    

00000513 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 513:	55                   	push   %ebp
 514:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 516:	eb 06                	jmp    51e <strcmp+0xb>
    p++, q++;
 518:	ff 45 08             	incl   0x8(%ebp)
 51b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 51e:	8b 45 08             	mov    0x8(%ebp),%eax
 521:	8a 00                	mov    (%eax),%al
 523:	84 c0                	test   %al,%al
 525:	74 0e                	je     535 <strcmp+0x22>
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	8a 10                	mov    (%eax),%dl
 52c:	8b 45 0c             	mov    0xc(%ebp),%eax
 52f:	8a 00                	mov    (%eax),%al
 531:	38 c2                	cmp    %al,%dl
 533:	74 e3                	je     518 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 535:	8b 45 08             	mov    0x8(%ebp),%eax
 538:	8a 00                	mov    (%eax),%al
 53a:	0f b6 d0             	movzbl %al,%edx
 53d:	8b 45 0c             	mov    0xc(%ebp),%eax
 540:	8a 00                	mov    (%eax),%al
 542:	0f b6 c0             	movzbl %al,%eax
 545:	29 c2                	sub    %eax,%edx
 547:	89 d0                	mov    %edx,%eax
}
 549:	5d                   	pop    %ebp
 54a:	c3                   	ret    

0000054b <strlen>:

uint
strlen(char *s)
{
 54b:	55                   	push   %ebp
 54c:	89 e5                	mov    %esp,%ebp
 54e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 551:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 558:	eb 03                	jmp    55d <strlen+0x12>
 55a:	ff 45 fc             	incl   -0x4(%ebp)
 55d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 560:	8b 45 08             	mov    0x8(%ebp),%eax
 563:	01 d0                	add    %edx,%eax
 565:	8a 00                	mov    (%eax),%al
 567:	84 c0                	test   %al,%al
 569:	75 ef                	jne    55a <strlen+0xf>
    ;
  return n;
 56b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 56e:	c9                   	leave  
 56f:	c3                   	ret    

00000570 <memset>:

void*
memset(void *dst, int c, uint n)
{
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
 573:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 576:	8b 45 10             	mov    0x10(%ebp),%eax
 579:	89 44 24 08          	mov    %eax,0x8(%esp)
 57d:	8b 45 0c             	mov    0xc(%ebp),%eax
 580:	89 44 24 04          	mov    %eax,0x4(%esp)
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	89 04 24             	mov    %eax,(%esp)
 58a:	e8 31 ff ff ff       	call   4c0 <stosb>
  return dst;
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 592:	c9                   	leave  
 593:	c3                   	ret    

00000594 <strchr>:

char*
strchr(const char *s, char c)
{
 594:	55                   	push   %ebp
 595:	89 e5                	mov    %esp,%ebp
 597:	83 ec 04             	sub    $0x4,%esp
 59a:	8b 45 0c             	mov    0xc(%ebp),%eax
 59d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5a0:	eb 12                	jmp    5b4 <strchr+0x20>
    if(*s == c)
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
 5a5:	8a 00                	mov    (%eax),%al
 5a7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 5aa:	75 05                	jne    5b1 <strchr+0x1d>
      return (char*)s;
 5ac:	8b 45 08             	mov    0x8(%ebp),%eax
 5af:	eb 11                	jmp    5c2 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 5b1:	ff 45 08             	incl   0x8(%ebp)
 5b4:	8b 45 08             	mov    0x8(%ebp),%eax
 5b7:	8a 00                	mov    (%eax),%al
 5b9:	84 c0                	test   %al,%al
 5bb:	75 e5                	jne    5a2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 5bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5c2:	c9                   	leave  
 5c3:	c3                   	ret    

000005c4 <gets>:

char*
gets(char *buf, int max)
{
 5c4:	55                   	push   %ebp
 5c5:	89 e5                	mov    %esp,%ebp
 5c7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5d1:	eb 49                	jmp    61c <gets+0x58>
    cc = read(0, &c, 1);
 5d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5da:	00 
 5db:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5de:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5e9:	e8 3e 01 00 00       	call   72c <read>
 5ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5f5:	7f 02                	jg     5f9 <gets+0x35>
      break;
 5f7:	eb 2c                	jmp    625 <gets+0x61>
    buf[i++] = c;
 5f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fc:	8d 50 01             	lea    0x1(%eax),%edx
 5ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
 602:	89 c2                	mov    %eax,%edx
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	01 c2                	add    %eax,%edx
 609:	8a 45 ef             	mov    -0x11(%ebp),%al
 60c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 60e:	8a 45 ef             	mov    -0x11(%ebp),%al
 611:	3c 0a                	cmp    $0xa,%al
 613:	74 10                	je     625 <gets+0x61>
 615:	8a 45 ef             	mov    -0x11(%ebp),%al
 618:	3c 0d                	cmp    $0xd,%al
 61a:	74 09                	je     625 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 61c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61f:	40                   	inc    %eax
 620:	3b 45 0c             	cmp    0xc(%ebp),%eax
 623:	7c ae                	jl     5d3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 625:	8b 55 f4             	mov    -0xc(%ebp),%edx
 628:	8b 45 08             	mov    0x8(%ebp),%eax
 62b:	01 d0                	add    %edx,%eax
 62d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 630:	8b 45 08             	mov    0x8(%ebp),%eax
}
 633:	c9                   	leave  
 634:	c3                   	ret    

00000635 <stat>:

int
stat(char *n, struct stat *st)
{
 635:	55                   	push   %ebp
 636:	89 e5                	mov    %esp,%ebp
 638:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 63b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 642:	00 
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	89 04 24             	mov    %eax,(%esp)
 649:	e8 06 01 00 00       	call   754 <open>
 64e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 651:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 655:	79 07                	jns    65e <stat+0x29>
    return -1;
 657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 65c:	eb 23                	jmp    681 <stat+0x4c>
  r = fstat(fd, st);
 65e:	8b 45 0c             	mov    0xc(%ebp),%eax
 661:	89 44 24 04          	mov    %eax,0x4(%esp)
 665:	8b 45 f4             	mov    -0xc(%ebp),%eax
 668:	89 04 24             	mov    %eax,(%esp)
 66b:	e8 fc 00 00 00       	call   76c <fstat>
 670:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 673:	8b 45 f4             	mov    -0xc(%ebp),%eax
 676:	89 04 24             	mov    %eax,(%esp)
 679:	e8 be 00 00 00       	call   73c <close>
  return r;
 67e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 681:	c9                   	leave  
 682:	c3                   	ret    

00000683 <atoi>:

int
atoi(const char *s)
{
 683:	55                   	push   %ebp
 684:	89 e5                	mov    %esp,%ebp
 686:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 689:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 690:	eb 24                	jmp    6b6 <atoi+0x33>
    n = n*10 + *s++ - '0';
 692:	8b 55 fc             	mov    -0x4(%ebp),%edx
 695:	89 d0                	mov    %edx,%eax
 697:	c1 e0 02             	shl    $0x2,%eax
 69a:	01 d0                	add    %edx,%eax
 69c:	01 c0                	add    %eax,%eax
 69e:	89 c1                	mov    %eax,%ecx
 6a0:	8b 45 08             	mov    0x8(%ebp),%eax
 6a3:	8d 50 01             	lea    0x1(%eax),%edx
 6a6:	89 55 08             	mov    %edx,0x8(%ebp)
 6a9:	8a 00                	mov    (%eax),%al
 6ab:	0f be c0             	movsbl %al,%eax
 6ae:	01 c8                	add    %ecx,%eax
 6b0:	83 e8 30             	sub    $0x30,%eax
 6b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
 6b9:	8a 00                	mov    (%eax),%al
 6bb:	3c 2f                	cmp    $0x2f,%al
 6bd:	7e 09                	jle    6c8 <atoi+0x45>
 6bf:	8b 45 08             	mov    0x8(%ebp),%eax
 6c2:	8a 00                	mov    (%eax),%al
 6c4:	3c 39                	cmp    $0x39,%al
 6c6:	7e ca                	jle    692 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6cb:	c9                   	leave  
 6cc:	c3                   	ret    

000006cd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6cd:	55                   	push   %ebp
 6ce:	89 e5                	mov    %esp,%ebp
 6d0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 6dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6df:	eb 16                	jmp    6f7 <memmove+0x2a>
    *dst++ = *src++;
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8d 50 01             	lea    0x1(%eax),%edx
 6e7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 6ea:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ed:	8d 4a 01             	lea    0x1(%edx),%ecx
 6f0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 6f3:	8a 12                	mov    (%edx),%dl
 6f5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6f7:	8b 45 10             	mov    0x10(%ebp),%eax
 6fa:	8d 50 ff             	lea    -0x1(%eax),%edx
 6fd:	89 55 10             	mov    %edx,0x10(%ebp)
 700:	85 c0                	test   %eax,%eax
 702:	7f dd                	jg     6e1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 704:	8b 45 08             	mov    0x8(%ebp),%eax
}
 707:	c9                   	leave  
 708:	c3                   	ret    
 709:	90                   	nop
 70a:	90                   	nop
 70b:	90                   	nop

0000070c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 70c:	b8 01 00 00 00       	mov    $0x1,%eax
 711:	cd 40                	int    $0x40
 713:	c3                   	ret    

00000714 <exit>:
SYSCALL(exit)
 714:	b8 02 00 00 00       	mov    $0x2,%eax
 719:	cd 40                	int    $0x40
 71b:	c3                   	ret    

0000071c <wait>:
SYSCALL(wait)
 71c:	b8 03 00 00 00       	mov    $0x3,%eax
 721:	cd 40                	int    $0x40
 723:	c3                   	ret    

00000724 <pipe>:
SYSCALL(pipe)
 724:	b8 04 00 00 00       	mov    $0x4,%eax
 729:	cd 40                	int    $0x40
 72b:	c3                   	ret    

0000072c <read>:
SYSCALL(read)
 72c:	b8 05 00 00 00       	mov    $0x5,%eax
 731:	cd 40                	int    $0x40
 733:	c3                   	ret    

00000734 <write>:
SYSCALL(write)
 734:	b8 10 00 00 00       	mov    $0x10,%eax
 739:	cd 40                	int    $0x40
 73b:	c3                   	ret    

0000073c <close>:
SYSCALL(close)
 73c:	b8 15 00 00 00       	mov    $0x15,%eax
 741:	cd 40                	int    $0x40
 743:	c3                   	ret    

00000744 <kill>:
SYSCALL(kill)
 744:	b8 06 00 00 00       	mov    $0x6,%eax
 749:	cd 40                	int    $0x40
 74b:	c3                   	ret    

0000074c <exec>:
SYSCALL(exec)
 74c:	b8 07 00 00 00       	mov    $0x7,%eax
 751:	cd 40                	int    $0x40
 753:	c3                   	ret    

00000754 <open>:
SYSCALL(open)
 754:	b8 0f 00 00 00       	mov    $0xf,%eax
 759:	cd 40                	int    $0x40
 75b:	c3                   	ret    

0000075c <mknod>:
SYSCALL(mknod)
 75c:	b8 11 00 00 00       	mov    $0x11,%eax
 761:	cd 40                	int    $0x40
 763:	c3                   	ret    

00000764 <unlink>:
SYSCALL(unlink)
 764:	b8 12 00 00 00       	mov    $0x12,%eax
 769:	cd 40                	int    $0x40
 76b:	c3                   	ret    

0000076c <fstat>:
SYSCALL(fstat)
 76c:	b8 08 00 00 00       	mov    $0x8,%eax
 771:	cd 40                	int    $0x40
 773:	c3                   	ret    

00000774 <link>:
SYSCALL(link)
 774:	b8 13 00 00 00       	mov    $0x13,%eax
 779:	cd 40                	int    $0x40
 77b:	c3                   	ret    

0000077c <mkdir>:
SYSCALL(mkdir)
 77c:	b8 14 00 00 00       	mov    $0x14,%eax
 781:	cd 40                	int    $0x40
 783:	c3                   	ret    

00000784 <chdir>:
SYSCALL(chdir)
 784:	b8 09 00 00 00       	mov    $0x9,%eax
 789:	cd 40                	int    $0x40
 78b:	c3                   	ret    

0000078c <dup>:
SYSCALL(dup)
 78c:	b8 0a 00 00 00       	mov    $0xa,%eax
 791:	cd 40                	int    $0x40
 793:	c3                   	ret    

00000794 <getpid>:
SYSCALL(getpid)
 794:	b8 0b 00 00 00       	mov    $0xb,%eax
 799:	cd 40                	int    $0x40
 79b:	c3                   	ret    

0000079c <sbrk>:
SYSCALL(sbrk)
 79c:	b8 0c 00 00 00       	mov    $0xc,%eax
 7a1:	cd 40                	int    $0x40
 7a3:	c3                   	ret    

000007a4 <sleep>:
SYSCALL(sleep)
 7a4:	b8 0d 00 00 00       	mov    $0xd,%eax
 7a9:	cd 40                	int    $0x40
 7ab:	c3                   	ret    

000007ac <uptime>:
SYSCALL(uptime)
 7ac:	b8 0e 00 00 00       	mov    $0xe,%eax
 7b1:	cd 40                	int    $0x40
 7b3:	c3                   	ret    

000007b4 <getticks>:
SYSCALL(getticks)
 7b4:	b8 16 00 00 00       	mov    $0x16,%eax
 7b9:	cd 40                	int    $0x40
 7bb:	c3                   	ret    

000007bc <get_name>:
SYSCALL(get_name)
 7bc:	b8 17 00 00 00       	mov    $0x17,%eax
 7c1:	cd 40                	int    $0x40
 7c3:	c3                   	ret    

000007c4 <get_max_proc>:
SYSCALL(get_max_proc)
 7c4:	b8 18 00 00 00       	mov    $0x18,%eax
 7c9:	cd 40                	int    $0x40
 7cb:	c3                   	ret    

000007cc <get_max_mem>:
SYSCALL(get_max_mem)
 7cc:	b8 19 00 00 00       	mov    $0x19,%eax
 7d1:	cd 40                	int    $0x40
 7d3:	c3                   	ret    

000007d4 <get_max_disk>:
SYSCALL(get_max_disk)
 7d4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 7d9:	cd 40                	int    $0x40
 7db:	c3                   	ret    

000007dc <get_curr_proc>:
SYSCALL(get_curr_proc)
 7dc:	b8 1b 00 00 00       	mov    $0x1b,%eax
 7e1:	cd 40                	int    $0x40
 7e3:	c3                   	ret    

000007e4 <get_curr_mem>:
SYSCALL(get_curr_mem)
 7e4:	b8 1c 00 00 00       	mov    $0x1c,%eax
 7e9:	cd 40                	int    $0x40
 7eb:	c3                   	ret    

000007ec <get_curr_disk>:
SYSCALL(get_curr_disk)
 7ec:	b8 1d 00 00 00       	mov    $0x1d,%eax
 7f1:	cd 40                	int    $0x40
 7f3:	c3                   	ret    

000007f4 <set_name>:
SYSCALL(set_name)
 7f4:	b8 1e 00 00 00       	mov    $0x1e,%eax
 7f9:	cd 40                	int    $0x40
 7fb:	c3                   	ret    

000007fc <set_max_mem>:
SYSCALL(set_max_mem)
 7fc:	b8 1f 00 00 00       	mov    $0x1f,%eax
 801:	cd 40                	int    $0x40
 803:	c3                   	ret    

00000804 <set_max_disk>:
SYSCALL(set_max_disk)
 804:	b8 20 00 00 00       	mov    $0x20,%eax
 809:	cd 40                	int    $0x40
 80b:	c3                   	ret    

0000080c <set_max_proc>:
SYSCALL(set_max_proc)
 80c:	b8 21 00 00 00       	mov    $0x21,%eax
 811:	cd 40                	int    $0x40
 813:	c3                   	ret    

00000814 <set_curr_mem>:
SYSCALL(set_curr_mem)
 814:	b8 22 00 00 00       	mov    $0x22,%eax
 819:	cd 40                	int    $0x40
 81b:	c3                   	ret    

0000081c <set_curr_disk>:
SYSCALL(set_curr_disk)
 81c:	b8 23 00 00 00       	mov    $0x23,%eax
 821:	cd 40                	int    $0x40
 823:	c3                   	ret    

00000824 <set_curr_proc>:
SYSCALL(set_curr_proc)
 824:	b8 24 00 00 00       	mov    $0x24,%eax
 829:	cd 40                	int    $0x40
 82b:	c3                   	ret    

0000082c <find>:
SYSCALL(find)
 82c:	b8 25 00 00 00       	mov    $0x25,%eax
 831:	cd 40                	int    $0x40
 833:	c3                   	ret    

00000834 <is_full>:
SYSCALL(is_full)
 834:	b8 26 00 00 00       	mov    $0x26,%eax
 839:	cd 40                	int    $0x40
 83b:	c3                   	ret    

0000083c <container_init>:
SYSCALL(container_init)
 83c:	b8 27 00 00 00       	mov    $0x27,%eax
 841:	cd 40                	int    $0x40
 843:	c3                   	ret    

00000844 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 844:	55                   	push   %ebp
 845:	89 e5                	mov    %esp,%ebp
 847:	83 ec 18             	sub    $0x18,%esp
 84a:	8b 45 0c             	mov    0xc(%ebp),%eax
 84d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 850:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 857:	00 
 858:	8d 45 f4             	lea    -0xc(%ebp),%eax
 85b:	89 44 24 04          	mov    %eax,0x4(%esp)
 85f:	8b 45 08             	mov    0x8(%ebp),%eax
 862:	89 04 24             	mov    %eax,(%esp)
 865:	e8 ca fe ff ff       	call   734 <write>
}
 86a:	c9                   	leave  
 86b:	c3                   	ret    

0000086c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 86c:	55                   	push   %ebp
 86d:	89 e5                	mov    %esp,%ebp
 86f:	56                   	push   %esi
 870:	53                   	push   %ebx
 871:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 874:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 87b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 87f:	74 17                	je     898 <printint+0x2c>
 881:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 885:	79 11                	jns    898 <printint+0x2c>
    neg = 1;
 887:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 88e:	8b 45 0c             	mov    0xc(%ebp),%eax
 891:	f7 d8                	neg    %eax
 893:	89 45 ec             	mov    %eax,-0x14(%ebp)
 896:	eb 06                	jmp    89e <printint+0x32>
  } else {
    x = xx;
 898:	8b 45 0c             	mov    0xc(%ebp),%eax
 89b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 89e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8a5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 8a8:	8d 41 01             	lea    0x1(%ecx),%eax
 8ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8b4:	ba 00 00 00 00       	mov    $0x0,%edx
 8b9:	f7 f3                	div    %ebx
 8bb:	89 d0                	mov    %edx,%eax
 8bd:	8a 80 78 11 00 00    	mov    0x1178(%eax),%al
 8c3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 8c7:	8b 75 10             	mov    0x10(%ebp),%esi
 8ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8cd:	ba 00 00 00 00       	mov    $0x0,%edx
 8d2:	f7 f6                	div    %esi
 8d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8db:	75 c8                	jne    8a5 <printint+0x39>
  if(neg)
 8dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e1:	74 10                	je     8f3 <printint+0x87>
    buf[i++] = '-';
 8e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e6:	8d 50 01             	lea    0x1(%eax),%edx
 8e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8ec:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8f1:	eb 1e                	jmp    911 <printint+0xa5>
 8f3:	eb 1c                	jmp    911 <printint+0xa5>
    putc(fd, buf[i]);
 8f5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fb:	01 d0                	add    %edx,%eax
 8fd:	8a 00                	mov    (%eax),%al
 8ff:	0f be c0             	movsbl %al,%eax
 902:	89 44 24 04          	mov    %eax,0x4(%esp)
 906:	8b 45 08             	mov    0x8(%ebp),%eax
 909:	89 04 24             	mov    %eax,(%esp)
 90c:	e8 33 ff ff ff       	call   844 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 911:	ff 4d f4             	decl   -0xc(%ebp)
 914:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 918:	79 db                	jns    8f5 <printint+0x89>
    putc(fd, buf[i]);
}
 91a:	83 c4 30             	add    $0x30,%esp
 91d:	5b                   	pop    %ebx
 91e:	5e                   	pop    %esi
 91f:	5d                   	pop    %ebp
 920:	c3                   	ret    

00000921 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 921:	55                   	push   %ebp
 922:	89 e5                	mov    %esp,%ebp
 924:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 927:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 92e:	8d 45 0c             	lea    0xc(%ebp),%eax
 931:	83 c0 04             	add    $0x4,%eax
 934:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 937:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 93e:	e9 77 01 00 00       	jmp    aba <printf+0x199>
    c = fmt[i] & 0xff;
 943:	8b 55 0c             	mov    0xc(%ebp),%edx
 946:	8b 45 f0             	mov    -0x10(%ebp),%eax
 949:	01 d0                	add    %edx,%eax
 94b:	8a 00                	mov    (%eax),%al
 94d:	0f be c0             	movsbl %al,%eax
 950:	25 ff 00 00 00       	and    $0xff,%eax
 955:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 958:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 95c:	75 2c                	jne    98a <printf+0x69>
      if(c == '%'){
 95e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 962:	75 0c                	jne    970 <printf+0x4f>
        state = '%';
 964:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 96b:	e9 47 01 00 00       	jmp    ab7 <printf+0x196>
      } else {
        putc(fd, c);
 970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 973:	0f be c0             	movsbl %al,%eax
 976:	89 44 24 04          	mov    %eax,0x4(%esp)
 97a:	8b 45 08             	mov    0x8(%ebp),%eax
 97d:	89 04 24             	mov    %eax,(%esp)
 980:	e8 bf fe ff ff       	call   844 <putc>
 985:	e9 2d 01 00 00       	jmp    ab7 <printf+0x196>
      }
    } else if(state == '%'){
 98a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 98e:	0f 85 23 01 00 00    	jne    ab7 <printf+0x196>
      if(c == 'd'){
 994:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 998:	75 2d                	jne    9c7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 99a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 99d:	8b 00                	mov    (%eax),%eax
 99f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 9a6:	00 
 9a7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 9ae:	00 
 9af:	89 44 24 04          	mov    %eax,0x4(%esp)
 9b3:	8b 45 08             	mov    0x8(%ebp),%eax
 9b6:	89 04 24             	mov    %eax,(%esp)
 9b9:	e8 ae fe ff ff       	call   86c <printint>
        ap++;
 9be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9c2:	e9 e9 00 00 00       	jmp    ab0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 9c7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9cb:	74 06                	je     9d3 <printf+0xb2>
 9cd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9d1:	75 2d                	jne    a00 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 9d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9d6:	8b 00                	mov    (%eax),%eax
 9d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9df:	00 
 9e0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9e7:	00 
 9e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 9ec:	8b 45 08             	mov    0x8(%ebp),%eax
 9ef:	89 04 24             	mov    %eax,(%esp)
 9f2:	e8 75 fe ff ff       	call   86c <printint>
        ap++;
 9f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9fb:	e9 b0 00 00 00       	jmp    ab0 <printf+0x18f>
      } else if(c == 's'){
 a00:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a04:	75 42                	jne    a48 <printf+0x127>
        s = (char*)*ap;
 a06:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a09:	8b 00                	mov    (%eax),%eax
 a0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a0e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a16:	75 09                	jne    a21 <printf+0x100>
          s = "(null)";
 a18:	c7 45 f4 e8 0d 00 00 	movl   $0xde8,-0xc(%ebp)
        while(*s != 0){
 a1f:	eb 1c                	jmp    a3d <printf+0x11c>
 a21:	eb 1a                	jmp    a3d <printf+0x11c>
          putc(fd, *s);
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	8a 00                	mov    (%eax),%al
 a28:	0f be c0             	movsbl %al,%eax
 a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a2f:	8b 45 08             	mov    0x8(%ebp),%eax
 a32:	89 04 24             	mov    %eax,(%esp)
 a35:	e8 0a fe ff ff       	call   844 <putc>
          s++;
 a3a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a40:	8a 00                	mov    (%eax),%al
 a42:	84 c0                	test   %al,%al
 a44:	75 dd                	jne    a23 <printf+0x102>
 a46:	eb 68                	jmp    ab0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a48:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a4c:	75 1d                	jne    a6b <printf+0x14a>
        putc(fd, *ap);
 a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a51:	8b 00                	mov    (%eax),%eax
 a53:	0f be c0             	movsbl %al,%eax
 a56:	89 44 24 04          	mov    %eax,0x4(%esp)
 a5a:	8b 45 08             	mov    0x8(%ebp),%eax
 a5d:	89 04 24             	mov    %eax,(%esp)
 a60:	e8 df fd ff ff       	call   844 <putc>
        ap++;
 a65:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a69:	eb 45                	jmp    ab0 <printf+0x18f>
      } else if(c == '%'){
 a6b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a6f:	75 17                	jne    a88 <printf+0x167>
        putc(fd, c);
 a71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a74:	0f be c0             	movsbl %al,%eax
 a77:	89 44 24 04          	mov    %eax,0x4(%esp)
 a7b:	8b 45 08             	mov    0x8(%ebp),%eax
 a7e:	89 04 24             	mov    %eax,(%esp)
 a81:	e8 be fd ff ff       	call   844 <putc>
 a86:	eb 28                	jmp    ab0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a88:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a8f:	00 
 a90:	8b 45 08             	mov    0x8(%ebp),%eax
 a93:	89 04 24             	mov    %eax,(%esp)
 a96:	e8 a9 fd ff ff       	call   844 <putc>
        putc(fd, c);
 a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a9e:	0f be c0             	movsbl %al,%eax
 aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
 aa5:	8b 45 08             	mov    0x8(%ebp),%eax
 aa8:	89 04 24             	mov    %eax,(%esp)
 aab:	e8 94 fd ff ff       	call   844 <putc>
      }
      state = 0;
 ab0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 ab7:	ff 45 f0             	incl   -0x10(%ebp)
 aba:	8b 55 0c             	mov    0xc(%ebp),%edx
 abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac0:	01 d0                	add    %edx,%eax
 ac2:	8a 00                	mov    (%eax),%al
 ac4:	84 c0                	test   %al,%al
 ac6:	0f 85 77 fe ff ff    	jne    943 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 acc:	c9                   	leave  
 acd:	c3                   	ret    
 ace:	90                   	nop
 acf:	90                   	nop

00000ad0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ad0:	55                   	push   %ebp
 ad1:	89 e5                	mov    %esp,%ebp
 ad3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ad6:	8b 45 08             	mov    0x8(%ebp),%eax
 ad9:	83 e8 08             	sub    $0x8,%eax
 adc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 adf:	a1 94 11 00 00       	mov    0x1194,%eax
 ae4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ae7:	eb 24                	jmp    b0d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aec:	8b 00                	mov    (%eax),%eax
 aee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af1:	77 12                	ja     b05 <free+0x35>
 af3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af9:	77 24                	ja     b1f <free+0x4f>
 afb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afe:	8b 00                	mov    (%eax),%eax
 b00:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b03:	77 1a                	ja     b1f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b08:	8b 00                	mov    (%eax),%eax
 b0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b10:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b13:	76 d4                	jbe    ae9 <free+0x19>
 b15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b18:	8b 00                	mov    (%eax),%eax
 b1a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b1d:	76 ca                	jbe    ae9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b22:	8b 40 04             	mov    0x4(%eax),%eax
 b25:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2f:	01 c2                	add    %eax,%edx
 b31:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b34:	8b 00                	mov    (%eax),%eax
 b36:	39 c2                	cmp    %eax,%edx
 b38:	75 24                	jne    b5e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3d:	8b 50 04             	mov    0x4(%eax),%edx
 b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b43:	8b 00                	mov    (%eax),%eax
 b45:	8b 40 04             	mov    0x4(%eax),%eax
 b48:	01 c2                	add    %eax,%edx
 b4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b4d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b50:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b53:	8b 00                	mov    (%eax),%eax
 b55:	8b 10                	mov    (%eax),%edx
 b57:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b5a:	89 10                	mov    %edx,(%eax)
 b5c:	eb 0a                	jmp    b68 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b61:	8b 10                	mov    (%eax),%edx
 b63:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b66:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b68:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b6b:	8b 40 04             	mov    0x4(%eax),%eax
 b6e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b75:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b78:	01 d0                	add    %edx,%eax
 b7a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b7d:	75 20                	jne    b9f <free+0xcf>
    p->s.size += bp->s.size;
 b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b82:	8b 50 04             	mov    0x4(%eax),%edx
 b85:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b88:	8b 40 04             	mov    0x4(%eax),%eax
 b8b:	01 c2                	add    %eax,%edx
 b8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b90:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b93:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b96:	8b 10                	mov    (%eax),%edx
 b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9b:	89 10                	mov    %edx,(%eax)
 b9d:	eb 08                	jmp    ba7 <free+0xd7>
  } else
    p->s.ptr = bp;
 b9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 ba5:	89 10                	mov    %edx,(%eax)
  freep = p;
 ba7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 baa:	a3 94 11 00 00       	mov    %eax,0x1194
}
 baf:	c9                   	leave  
 bb0:	c3                   	ret    

00000bb1 <morecore>:

static Header*
morecore(uint nu)
{
 bb1:	55                   	push   %ebp
 bb2:	89 e5                	mov    %esp,%ebp
 bb4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bb7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bbe:	77 07                	ja     bc7 <morecore+0x16>
    nu = 4096;
 bc0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bc7:	8b 45 08             	mov    0x8(%ebp),%eax
 bca:	c1 e0 03             	shl    $0x3,%eax
 bcd:	89 04 24             	mov    %eax,(%esp)
 bd0:	e8 c7 fb ff ff       	call   79c <sbrk>
 bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bd8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bdc:	75 07                	jne    be5 <morecore+0x34>
    return 0;
 bde:	b8 00 00 00 00       	mov    $0x0,%eax
 be3:	eb 22                	jmp    c07 <morecore+0x56>
  hp = (Header*)p;
 be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bee:	8b 55 08             	mov    0x8(%ebp),%edx
 bf1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf7:	83 c0 08             	add    $0x8,%eax
 bfa:	89 04 24             	mov    %eax,(%esp)
 bfd:	e8 ce fe ff ff       	call   ad0 <free>
  return freep;
 c02:	a1 94 11 00 00       	mov    0x1194,%eax
}
 c07:	c9                   	leave  
 c08:	c3                   	ret    

00000c09 <malloc>:

void*
malloc(uint nbytes)
{
 c09:	55                   	push   %ebp
 c0a:	89 e5                	mov    %esp,%ebp
 c0c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c0f:	8b 45 08             	mov    0x8(%ebp),%eax
 c12:	83 c0 07             	add    $0x7,%eax
 c15:	c1 e8 03             	shr    $0x3,%eax
 c18:	40                   	inc    %eax
 c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c1c:	a1 94 11 00 00       	mov    0x1194,%eax
 c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c28:	75 23                	jne    c4d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 c2a:	c7 45 f0 8c 11 00 00 	movl   $0x118c,-0x10(%ebp)
 c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c34:	a3 94 11 00 00       	mov    %eax,0x1194
 c39:	a1 94 11 00 00       	mov    0x1194,%eax
 c3e:	a3 8c 11 00 00       	mov    %eax,0x118c
    base.s.size = 0;
 c43:	c7 05 90 11 00 00 00 	movl   $0x0,0x1190
 c4a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c50:	8b 00                	mov    (%eax),%eax
 c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c58:	8b 40 04             	mov    0x4(%eax),%eax
 c5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c5e:	72 4d                	jb     cad <malloc+0xa4>
      if(p->s.size == nunits)
 c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c63:	8b 40 04             	mov    0x4(%eax),%eax
 c66:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c69:	75 0c                	jne    c77 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6e:	8b 10                	mov    (%eax),%edx
 c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c73:	89 10                	mov    %edx,(%eax)
 c75:	eb 26                	jmp    c9d <malloc+0x94>
      else {
        p->s.size -= nunits;
 c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7a:	8b 40 04             	mov    0x4(%eax),%eax
 c7d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c80:	89 c2                	mov    %eax,%edx
 c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c85:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8b:	8b 40 04             	mov    0x4(%eax),%eax
 c8e:	c1 e0 03             	shl    $0x3,%eax
 c91:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c97:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c9a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca0:	a3 94 11 00 00       	mov    %eax,0x1194
      return (void*)(p + 1);
 ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca8:	83 c0 08             	add    $0x8,%eax
 cab:	eb 38                	jmp    ce5 <malloc+0xdc>
    }
    if(p == freep)
 cad:	a1 94 11 00 00       	mov    0x1194,%eax
 cb2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cb5:	75 1b                	jne    cd2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 cb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 cba:	89 04 24             	mov    %eax,(%esp)
 cbd:	e8 ef fe ff ff       	call   bb1 <morecore>
 cc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cc9:	75 07                	jne    cd2 <malloc+0xc9>
        return 0;
 ccb:	b8 00 00 00 00       	mov    $0x0,%eax
 cd0:	eb 13                	jmp    ce5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cdb:	8b 00                	mov    (%eax),%eax
 cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ce0:	e9 70 ff ff ff       	jmp    c55 <malloc+0x4c>
}
 ce5:	c9                   	leave  
 ce6:	c3                   	ret    
