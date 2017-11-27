
_ctool:     file format elf32-i386


Disassembly of section .text:

00000000 <strcat>:
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
  5d:	e8 e6 05 00 00       	call   648 <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 54 0b 00 	movl   $0xb54,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 0e 07 00 00       	call   78d <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 b1 05 00 00       	call   648 <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 54 0b 00 	movl   $0xb54,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 d9 06 00 00       	call   78d <printf>
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
  cf:	e8 54 05 00 00       	call   628 <write>
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
  ec:	e8 2f 05 00 00       	call   620 <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 2b 05 00 00       	call   630 <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 20 05 00 00       	call   630 <close>
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <create>:

void create(char *c_args[]){
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	53                   	push   %ebx
 116:	83 ec 34             	sub    $0x34,%esp
	// //struct container create;
	// //create->name = c_args[0];
	// //create->max_mem = atoi(c_args[1]);
	// //create->max_proc = atoi(c_args2[2]);
	// //create->max_disk = atoi(c_args2[3]);
	mkdir(c_args[0]);
 119:	8b 45 08             	mov    0x8(%ebp),%eax
 11c:	8b 00                	mov    (%eax),%eax
 11e:	89 04 24             	mov    %eax,(%esp)
 121:	e8 4a 05 00 00       	call   670 <mkdir>
	// //chdir(create->name);

	
	int x = 0;
 126:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
 12d:	eb 03                	jmp    132 <create+0x20>
			x++;
 12f:	ff 45 f4             	incl   -0xc(%ebp)
	mkdir(c_args[0]);
	// //chdir(create->name);

	
	int x = 0;
	while(c_args[x] != 0){
 132:	8b 45 f4             	mov    -0xc(%ebp),%eax
 135:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	01 d0                	add    %edx,%eax
 141:	8b 00                	mov    (%eax),%eax
 143:	85 c0                	test   %eax,%eax
 145:	75 e8                	jne    12f <create+0x1d>
			x++;
	}

	int i;
	for(i = 1; i < x; i++){
 147:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 14e:	e9 ed 00 00 00       	jmp    240 <create+0x12e>
 153:	89 e0                	mov    %esp,%eax
 155:	89 c3                	mov    %eax,%ebx
		printf(1, "%s.\n", c_args[i]);
 157:	8b 45 f0             	mov    -0x10(%ebp),%eax
 15a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	01 d0                	add    %edx,%eax
 166:	8b 00                	mov    (%eax),%eax
 168:	89 44 24 08          	mov    %eax,0x8(%esp)
 16c:	c7 44 24 04 6c 0b 00 	movl   $0xb6c,0x4(%esp)
 173:	00 
 174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17b:	e8 0d 06 00 00       	call   78d <printf>

		char dir[strlen(c_args[0])];
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	8b 00                	mov    (%eax),%eax
 185:	89 04 24             	mov    %eax,(%esp)
 188:	e8 b2 02 00 00       	call   43f <strlen>
 18d:	89 c2                	mov    %eax,%edx
 18f:	4a                   	dec    %edx
 190:	89 55 ec             	mov    %edx,-0x14(%ebp)
 193:	ba 10 00 00 00       	mov    $0x10,%edx
 198:	4a                   	dec    %edx
 199:	01 d0                	add    %edx,%eax
 19b:	b9 10 00 00 00       	mov    $0x10,%ecx
 1a0:	ba 00 00 00 00       	mov    $0x0,%edx
 1a5:	f7 f1                	div    %ecx
 1a7:	6b c0 10             	imul   $0x10,%eax,%eax
 1aa:	29 c4                	sub    %eax,%esp
 1ac:	8d 44 24 0c          	lea    0xc(%esp),%eax
 1b0:	83 c0 00             	add    $0x0,%eax
 1b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
		strcpy(dir, c_args[0]);
 1b6:	8b 45 08             	mov    0x8(%ebp),%eax
 1b9:	8b 10                	mov    (%eax),%edx
 1bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1be:	89 54 24 04          	mov    %edx,0x4(%esp)
 1c2:	89 04 24             	mov    %eax,(%esp)
 1c5:	e8 0f 02 00 00       	call   3d9 <strcpy>
		strcat(dir, "/");
 1ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1cd:	c7 44 24 04 71 0b 00 	movl   $0xb71,0x4(%esp)
 1d4:	00 
 1d5:	89 04 24             	mov    %eax,(%esp)
 1d8:	e8 23 fe ff ff       	call   0 <strcat>
		char* location = strcat(dir, c_args[i]);
 1dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	01 d0                	add    %edx,%eax
 1ec:	8b 10                	mov    (%eax),%edx
 1ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1f1:	89 54 24 04          	mov    %edx,0x4(%esp)
 1f5:	89 04 24             	mov    %eax,(%esp)
 1f8:	e8 03 fe ff ff       	call   0 <strcat>
 1fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		printf(1, "Location: %s.\n", location);
 200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 203:	89 44 24 08          	mov    %eax,0x8(%esp)
 207:	c7 44 24 04 73 0b 00 	movl   $0xb73,0x4(%esp)
 20e:	00 
 20f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 216:	e8 72 05 00 00       	call   78d <printf>

		copy_files(location, c_args[i]);
 21b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 21e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	01 d0                	add    %edx,%eax
 22a:	8b 00                	mov    (%eax),%eax
 22c:	89 44 24 04          	mov    %eax,0x4(%esp)
 230:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 233:	89 04 24             	mov    %eax,(%esp)
 236:	e8 0b fe ff ff       	call   46 <copy_files>
 23b:	89 dc                	mov    %ebx,%esp
	while(c_args[x] != 0){
			x++;
	}

	int i;
	for(i = 1; i < x; i++){
 23d:	ff 45 f0             	incl   -0x10(%ebp)
 240:	8b 45 f0             	mov    -0x10(%ebp),%eax
 243:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 246:	0f 8c 07 ff ff ff    	jl     153 <create+0x41>

		// exec("echo", arr);
		// printf(1, "Failure to Execute.");
		// exit();
	}
}
 24c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 24f:	c9                   	leave  
 250:	c3                   	ret    

00000251 <attach_vc>:

void attach_vc(char* vc, char* dir, char* file){
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	83 ec 28             	sub    $0x28,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
 257:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 25e:	00 
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	89 04 24             	mov    %eax,(%esp)
 265:	e8 de 03 00 00       	call   648 <open>
 26a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	89 04 24             	mov    %eax,(%esp)
 273:	e8 00 04 00 00       	call   678 <chdir>

	/* fork a child and exec argv[1] */
	id = fork();
 278:	e8 83 03 00 00       	call   600 <fork>
 27d:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 280:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 284:	75 70                	jne    2f6 <attach_vc+0xa5>
		close(0);
 286:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 28d:	e8 9e 03 00 00       	call   630 <close>
		close(1);
 292:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 299:	e8 92 03 00 00       	call   630 <close>
		close(2);
 29e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2a5:	e8 86 03 00 00       	call   630 <close>
		dup(fd);
 2aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ad:	89 04 24             	mov    %eax,(%esp)
 2b0:	e8 cb 03 00 00       	call   680 <dup>
		dup(fd);
 2b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b8:	89 04 24             	mov    %eax,(%esp)
 2bb:	e8 c0 03 00 00       	call   680 <dup>
		dup(fd);
 2c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c3:	89 04 24             	mov    %eax,(%esp)
 2c6:	e8 b5 03 00 00       	call   680 <dup>
		exec(file, &file);
 2cb:	8b 45 10             	mov    0x10(%ebp),%eax
 2ce:	8d 55 10             	lea    0x10(%ebp),%edx
 2d1:	89 54 24 04          	mov    %edx,0x4(%esp)
 2d5:	89 04 24             	mov    %eax,(%esp)
 2d8:	e8 63 03 00 00       	call   640 <exec>
		printf(1, "Failure to attach VC.");
 2dd:	c7 44 24 04 82 0b 00 	movl   $0xb82,0x4(%esp)
 2e4:	00 
 2e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ec:	e8 9c 04 00 00       	call   78d <printf>
		exit();
 2f1:	e8 12 03 00 00       	call   608 <exit>
	}
}
 2f6:	c9                   	leave  
 2f7:	c3                   	ret    

000002f8 <start>:

void start(char *s_args[]){
 2f8:	55                   	push   %ebp
 2f9:	89 e5                	mov    %esp,%ebp
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 2fb:	5d                   	pop    %ebp
 2fc:	c3                   	ret    

000002fd <pause>:

void pause(char *c_name){
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp

}
 300:	5d                   	pop    %ebp
 301:	c3                   	ret    

00000302 <resume>:

void resume(char *c_name){
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp

}
 305:	5d                   	pop    %ebp
 306:	c3                   	ret    

00000307 <stop>:

void stop(char *c_name){
 307:	55                   	push   %ebp
 308:	89 e5                	mov    %esp,%ebp

}
 30a:	5d                   	pop    %ebp
 30b:	c3                   	ret    

0000030c <info>:

void info(char *c_name){
 30c:	55                   	push   %ebp
 30d:	89 e5                	mov    %esp,%ebp

}
 30f:	5d                   	pop    %ebp
 310:	c3                   	ret    

00000311 <main>:

int main(int argc, char *argv[]){
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 e4 f0             	and    $0xfffffff0,%esp
 317:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
 31a:	8b 45 0c             	mov    0xc(%ebp),%eax
 31d:	83 c0 04             	add    $0x4,%eax
 320:	8b 00                	mov    (%eax),%eax
 322:	c7 44 24 04 98 0b 00 	movl   $0xb98,0x4(%esp)
 329:	00 
 32a:	89 04 24             	mov    %eax,(%esp)
 32d:	e8 d5 00 00 00       	call   407 <strcmp>
 332:	85 c0                	test   %eax,%eax
 334:	75 24                	jne    35a <main+0x49>
		printf(1, "Calling create\n");
 336:	c7 44 24 04 9f 0b 00 	movl   $0xb9f,0x4(%esp)
 33d:	00 
 33e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 345:	e8 43 04 00 00       	call   78d <printf>
		create(&argv[2]);
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	83 c0 08             	add    $0x8,%eax
 350:	89 04 24             	mov    %eax,(%esp)
 353:	e8 ba fd ff ff       	call   112 <create>
 358:	eb 40                	jmp    39a <main+0x89>
	}
	else if(strcmp(argv[1], "start") == 0){
 35a:	8b 45 0c             	mov    0xc(%ebp),%eax
 35d:	83 c0 04             	add    $0x4,%eax
 360:	8b 00                	mov    (%eax),%eax
 362:	c7 44 24 04 af 0b 00 	movl   $0xbaf,0x4(%esp)
 369:	00 
 36a:	89 04 24             	mov    %eax,(%esp)
 36d:	e8 95 00 00 00       	call   407 <strcmp>
 372:	85 c0                	test   %eax,%eax
 374:	75 10                	jne    386 <main+0x75>
		start(&argv[2]);
 376:	8b 45 0c             	mov    0xc(%ebp),%eax
 379:	83 c0 08             	add    $0x8,%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 74 ff ff ff       	call   2f8 <start>
 384:	eb 14                	jmp    39a <main+0x89>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 386:	c7 44 24 04 b8 0b 00 	movl   $0xbb8,0x4(%esp)
 38d:	00 
 38e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 395:	e8 f3 03 00 00       	call   78d <printf>
	}
	printf(1, "Done with ctool\n");
 39a:	c7 44 24 04 f3 0b 00 	movl   $0xbf3,0x4(%esp)
 3a1:	00 
 3a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3a9:	e8 df 03 00 00       	call   78d <printf>

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
 3ae:	e8 55 02 00 00       	call   608 <exit>
 3b3:	90                   	nop

000003b4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	57                   	push   %edi
 3b8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3bc:	8b 55 10             	mov    0x10(%ebp),%edx
 3bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c2:	89 cb                	mov    %ecx,%ebx
 3c4:	89 df                	mov    %ebx,%edi
 3c6:	89 d1                	mov    %edx,%ecx
 3c8:	fc                   	cld    
 3c9:	f3 aa                	rep stos %al,%es:(%edi)
 3cb:	89 ca                	mov    %ecx,%edx
 3cd:	89 fb                	mov    %edi,%ebx
 3cf:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3d2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3d5:	5b                   	pop    %ebx
 3d6:	5f                   	pop    %edi
 3d7:	5d                   	pop    %ebp
 3d8:	c3                   	ret    

000003d9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3d9:	55                   	push   %ebp
 3da:	89 e5                	mov    %esp,%ebp
 3dc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3e5:	90                   	nop
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	8d 50 01             	lea    0x1(%eax),%edx
 3ec:	89 55 08             	mov    %edx,0x8(%ebp)
 3ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 3f2:	8d 4a 01             	lea    0x1(%edx),%ecx
 3f5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 3f8:	8a 12                	mov    (%edx),%dl
 3fa:	88 10                	mov    %dl,(%eax)
 3fc:	8a 00                	mov    (%eax),%al
 3fe:	84 c0                	test   %al,%al
 400:	75 e4                	jne    3e6 <strcpy+0xd>
    ;
  return os;
 402:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 40a:	eb 06                	jmp    412 <strcmp+0xb>
    p++, q++;
 40c:	ff 45 08             	incl   0x8(%ebp)
 40f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 412:	8b 45 08             	mov    0x8(%ebp),%eax
 415:	8a 00                	mov    (%eax),%al
 417:	84 c0                	test   %al,%al
 419:	74 0e                	je     429 <strcmp+0x22>
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
 41e:	8a 10                	mov    (%eax),%dl
 420:	8b 45 0c             	mov    0xc(%ebp),%eax
 423:	8a 00                	mov    (%eax),%al
 425:	38 c2                	cmp    %al,%dl
 427:	74 e3                	je     40c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 429:	8b 45 08             	mov    0x8(%ebp),%eax
 42c:	8a 00                	mov    (%eax),%al
 42e:	0f b6 d0             	movzbl %al,%edx
 431:	8b 45 0c             	mov    0xc(%ebp),%eax
 434:	8a 00                	mov    (%eax),%al
 436:	0f b6 c0             	movzbl %al,%eax
 439:	29 c2                	sub    %eax,%edx
 43b:	89 d0                	mov    %edx,%eax
}
 43d:	5d                   	pop    %ebp
 43e:	c3                   	ret    

0000043f <strlen>:

uint
strlen(char *s)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 445:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 44c:	eb 03                	jmp    451 <strlen+0x12>
 44e:	ff 45 fc             	incl   -0x4(%ebp)
 451:	8b 55 fc             	mov    -0x4(%ebp),%edx
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	01 d0                	add    %edx,%eax
 459:	8a 00                	mov    (%eax),%al
 45b:	84 c0                	test   %al,%al
 45d:	75 ef                	jne    44e <strlen+0xf>
    ;
  return n;
 45f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 462:	c9                   	leave  
 463:	c3                   	ret    

00000464 <memset>:

void*
memset(void *dst, int c, uint n)
{
 464:	55                   	push   %ebp
 465:	89 e5                	mov    %esp,%ebp
 467:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 46a:	8b 45 10             	mov    0x10(%ebp),%eax
 46d:	89 44 24 08          	mov    %eax,0x8(%esp)
 471:	8b 45 0c             	mov    0xc(%ebp),%eax
 474:	89 44 24 04          	mov    %eax,0x4(%esp)
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	89 04 24             	mov    %eax,(%esp)
 47e:	e8 31 ff ff ff       	call   3b4 <stosb>
  return dst;
 483:	8b 45 08             	mov    0x8(%ebp),%eax
}
 486:	c9                   	leave  
 487:	c3                   	ret    

00000488 <strchr>:

char*
strchr(const char *s, char c)
{
 488:	55                   	push   %ebp
 489:	89 e5                	mov    %esp,%ebp
 48b:	83 ec 04             	sub    $0x4,%esp
 48e:	8b 45 0c             	mov    0xc(%ebp),%eax
 491:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 494:	eb 12                	jmp    4a8 <strchr+0x20>
    if(*s == c)
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	8a 00                	mov    (%eax),%al
 49b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 49e:	75 05                	jne    4a5 <strchr+0x1d>
      return (char*)s;
 4a0:	8b 45 08             	mov    0x8(%ebp),%eax
 4a3:	eb 11                	jmp    4b6 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 4a5:	ff 45 08             	incl   0x8(%ebp)
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	8a 00                	mov    (%eax),%al
 4ad:	84 c0                	test   %al,%al
 4af:	75 e5                	jne    496 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 4b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4b6:	c9                   	leave  
 4b7:	c3                   	ret    

000004b8 <gets>:

char*
gets(char *buf, int max)
{
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
 4bb:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4c5:	eb 49                	jmp    510 <gets+0x58>
    cc = read(0, &c, 1);
 4c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4ce:	00 
 4cf:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4dd:	e8 3e 01 00 00       	call   620 <read>
 4e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e9:	7f 02                	jg     4ed <gets+0x35>
      break;
 4eb:	eb 2c                	jmp    519 <gets+0x61>
    buf[i++] = c;
 4ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f0:	8d 50 01             	lea    0x1(%eax),%edx
 4f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f6:	89 c2                	mov    %eax,%edx
 4f8:	8b 45 08             	mov    0x8(%ebp),%eax
 4fb:	01 c2                	add    %eax,%edx
 4fd:	8a 45 ef             	mov    -0x11(%ebp),%al
 500:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 502:	8a 45 ef             	mov    -0x11(%ebp),%al
 505:	3c 0a                	cmp    $0xa,%al
 507:	74 10                	je     519 <gets+0x61>
 509:	8a 45 ef             	mov    -0x11(%ebp),%al
 50c:	3c 0d                	cmp    $0xd,%al
 50e:	74 09                	je     519 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 510:	8b 45 f4             	mov    -0xc(%ebp),%eax
 513:	40                   	inc    %eax
 514:	3b 45 0c             	cmp    0xc(%ebp),%eax
 517:	7c ae                	jl     4c7 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 519:	8b 55 f4             	mov    -0xc(%ebp),%edx
 51c:	8b 45 08             	mov    0x8(%ebp),%eax
 51f:	01 d0                	add    %edx,%eax
 521:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 524:	8b 45 08             	mov    0x8(%ebp),%eax
}
 527:	c9                   	leave  
 528:	c3                   	ret    

00000529 <stat>:

int
stat(char *n, struct stat *st)
{
 529:	55                   	push   %ebp
 52a:	89 e5                	mov    %esp,%ebp
 52c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 52f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 536:	00 
 537:	8b 45 08             	mov    0x8(%ebp),%eax
 53a:	89 04 24             	mov    %eax,(%esp)
 53d:	e8 06 01 00 00       	call   648 <open>
 542:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 545:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 549:	79 07                	jns    552 <stat+0x29>
    return -1;
 54b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 550:	eb 23                	jmp    575 <stat+0x4c>
  r = fstat(fd, st);
 552:	8b 45 0c             	mov    0xc(%ebp),%eax
 555:	89 44 24 04          	mov    %eax,0x4(%esp)
 559:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55c:	89 04 24             	mov    %eax,(%esp)
 55f:	e8 fc 00 00 00       	call   660 <fstat>
 564:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 567:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56a:	89 04 24             	mov    %eax,(%esp)
 56d:	e8 be 00 00 00       	call   630 <close>
  return r;
 572:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 575:	c9                   	leave  
 576:	c3                   	ret    

00000577 <atoi>:

int
atoi(const char *s)
{
 577:	55                   	push   %ebp
 578:	89 e5                	mov    %esp,%ebp
 57a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 57d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 584:	eb 24                	jmp    5aa <atoi+0x33>
    n = n*10 + *s++ - '0';
 586:	8b 55 fc             	mov    -0x4(%ebp),%edx
 589:	89 d0                	mov    %edx,%eax
 58b:	c1 e0 02             	shl    $0x2,%eax
 58e:	01 d0                	add    %edx,%eax
 590:	01 c0                	add    %eax,%eax
 592:	89 c1                	mov    %eax,%ecx
 594:	8b 45 08             	mov    0x8(%ebp),%eax
 597:	8d 50 01             	lea    0x1(%eax),%edx
 59a:	89 55 08             	mov    %edx,0x8(%ebp)
 59d:	8a 00                	mov    (%eax),%al
 59f:	0f be c0             	movsbl %al,%eax
 5a2:	01 c8                	add    %ecx,%eax
 5a4:	83 e8 30             	sub    $0x30,%eax
 5a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
 5ad:	8a 00                	mov    (%eax),%al
 5af:	3c 2f                	cmp    $0x2f,%al
 5b1:	7e 09                	jle    5bc <atoi+0x45>
 5b3:	8b 45 08             	mov    0x8(%ebp),%eax
 5b6:	8a 00                	mov    (%eax),%al
 5b8:	3c 39                	cmp    $0x39,%al
 5ba:	7e ca                	jle    586 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 5bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5bf:	c9                   	leave  
 5c0:	c3                   	ret    

000005c1 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5c1:	55                   	push   %ebp
 5c2:	89 e5                	mov    %esp,%ebp
 5c4:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5c7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5d3:	eb 16                	jmp    5eb <memmove+0x2a>
    *dst++ = *src++;
 5d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d8:	8d 50 01             	lea    0x1(%eax),%edx
 5db:	89 55 fc             	mov    %edx,-0x4(%ebp)
 5de:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5e1:	8d 4a 01             	lea    0x1(%edx),%ecx
 5e4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 5e7:	8a 12                	mov    (%edx),%dl
 5e9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5eb:	8b 45 10             	mov    0x10(%ebp),%eax
 5ee:	8d 50 ff             	lea    -0x1(%eax),%edx
 5f1:	89 55 10             	mov    %edx,0x10(%ebp)
 5f4:	85 c0                	test   %eax,%eax
 5f6:	7f dd                	jg     5d5 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5fb:	c9                   	leave  
 5fc:	c3                   	ret    
 5fd:	90                   	nop
 5fe:	90                   	nop
 5ff:	90                   	nop

00000600 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 600:	b8 01 00 00 00       	mov    $0x1,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <exit>:
SYSCALL(exit)
 608:	b8 02 00 00 00       	mov    $0x2,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <wait>:
SYSCALL(wait)
 610:	b8 03 00 00 00       	mov    $0x3,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <pipe>:
SYSCALL(pipe)
 618:	b8 04 00 00 00       	mov    $0x4,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <read>:
SYSCALL(read)
 620:	b8 05 00 00 00       	mov    $0x5,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <write>:
SYSCALL(write)
 628:	b8 10 00 00 00       	mov    $0x10,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <close>:
SYSCALL(close)
 630:	b8 15 00 00 00       	mov    $0x15,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <kill>:
SYSCALL(kill)
 638:	b8 06 00 00 00       	mov    $0x6,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <exec>:
SYSCALL(exec)
 640:	b8 07 00 00 00       	mov    $0x7,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <open>:
SYSCALL(open)
 648:	b8 0f 00 00 00       	mov    $0xf,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <mknod>:
SYSCALL(mknod)
 650:	b8 11 00 00 00       	mov    $0x11,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <unlink>:
SYSCALL(unlink)
 658:	b8 12 00 00 00       	mov    $0x12,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <fstat>:
SYSCALL(fstat)
 660:	b8 08 00 00 00       	mov    $0x8,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <link>:
SYSCALL(link)
 668:	b8 13 00 00 00       	mov    $0x13,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <mkdir>:
SYSCALL(mkdir)
 670:	b8 14 00 00 00       	mov    $0x14,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <chdir>:
SYSCALL(chdir)
 678:	b8 09 00 00 00       	mov    $0x9,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <dup>:
SYSCALL(dup)
 680:	b8 0a 00 00 00       	mov    $0xa,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <getpid>:
SYSCALL(getpid)
 688:	b8 0b 00 00 00       	mov    $0xb,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <sbrk>:
SYSCALL(sbrk)
 690:	b8 0c 00 00 00       	mov    $0xc,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <sleep>:
SYSCALL(sleep)
 698:	b8 0d 00 00 00       	mov    $0xd,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <uptime>:
SYSCALL(uptime)
 6a0:	b8 0e 00 00 00       	mov    $0xe,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <getticks>:
 6a8:	b8 16 00 00 00       	mov    $0x16,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	83 ec 18             	sub    $0x18,%esp
 6b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6c3:	00 
 6c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ce:	89 04 24             	mov    %eax,(%esp)
 6d1:	e8 52 ff ff ff       	call   628 <write>
}
 6d6:	c9                   	leave  
 6d7:	c3                   	ret    

000006d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6d8:	55                   	push   %ebp
 6d9:	89 e5                	mov    %esp,%ebp
 6db:	56                   	push   %esi
 6dc:	53                   	push   %ebx
 6dd:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6e7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6eb:	74 17                	je     704 <printint+0x2c>
 6ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6f1:	79 11                	jns    704 <printint+0x2c>
    neg = 1;
 6f3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 6fd:	f7 d8                	neg    %eax
 6ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
 702:	eb 06                	jmp    70a <printint+0x32>
  } else {
    x = xx;
 704:	8b 45 0c             	mov    0xc(%ebp),%eax
 707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 70a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 711:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 714:	8d 41 01             	lea    0x1(%ecx),%eax
 717:	89 45 f4             	mov    %eax,-0xc(%ebp)
 71a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 71d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 720:	ba 00 00 00 00       	mov    $0x0,%edx
 725:	f7 f3                	div    %ebx
 727:	89 d0                	mov    %edx,%eax
 729:	8a 80 74 0f 00 00    	mov    0xf74(%eax),%al
 72f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 733:	8b 75 10             	mov    0x10(%ebp),%esi
 736:	8b 45 ec             	mov    -0x14(%ebp),%eax
 739:	ba 00 00 00 00       	mov    $0x0,%edx
 73e:	f7 f6                	div    %esi
 740:	89 45 ec             	mov    %eax,-0x14(%ebp)
 743:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 747:	75 c8                	jne    711 <printint+0x39>
  if(neg)
 749:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 74d:	74 10                	je     75f <printint+0x87>
    buf[i++] = '-';
 74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 752:	8d 50 01             	lea    0x1(%eax),%edx
 755:	89 55 f4             	mov    %edx,-0xc(%ebp)
 758:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 75d:	eb 1e                	jmp    77d <printint+0xa5>
 75f:	eb 1c                	jmp    77d <printint+0xa5>
    putc(fd, buf[i]);
 761:	8d 55 dc             	lea    -0x24(%ebp),%edx
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	01 d0                	add    %edx,%eax
 769:	8a 00                	mov    (%eax),%al
 76b:	0f be c0             	movsbl %al,%eax
 76e:	89 44 24 04          	mov    %eax,0x4(%esp)
 772:	8b 45 08             	mov    0x8(%ebp),%eax
 775:	89 04 24             	mov    %eax,(%esp)
 778:	e8 33 ff ff ff       	call   6b0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 77d:	ff 4d f4             	decl   -0xc(%ebp)
 780:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 784:	79 db                	jns    761 <printint+0x89>
    putc(fd, buf[i]);
}
 786:	83 c4 30             	add    $0x30,%esp
 789:	5b                   	pop    %ebx
 78a:	5e                   	pop    %esi
 78b:	5d                   	pop    %ebp
 78c:	c3                   	ret    

0000078d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 78d:	55                   	push   %ebp
 78e:	89 e5                	mov    %esp,%ebp
 790:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 793:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 79a:	8d 45 0c             	lea    0xc(%ebp),%eax
 79d:	83 c0 04             	add    $0x4,%eax
 7a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7aa:	e9 77 01 00 00       	jmp    926 <printf+0x199>
    c = fmt[i] & 0xff;
 7af:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b5:	01 d0                	add    %edx,%eax
 7b7:	8a 00                	mov    (%eax),%al
 7b9:	0f be c0             	movsbl %al,%eax
 7bc:	25 ff 00 00 00       	and    $0xff,%eax
 7c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7c8:	75 2c                	jne    7f6 <printf+0x69>
      if(c == '%'){
 7ca:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ce:	75 0c                	jne    7dc <printf+0x4f>
        state = '%';
 7d0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7d7:	e9 47 01 00 00       	jmp    923 <printf+0x196>
      } else {
        putc(fd, c);
 7dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7df:	0f be c0             	movsbl %al,%eax
 7e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e6:	8b 45 08             	mov    0x8(%ebp),%eax
 7e9:	89 04 24             	mov    %eax,(%esp)
 7ec:	e8 bf fe ff ff       	call   6b0 <putc>
 7f1:	e9 2d 01 00 00       	jmp    923 <printf+0x196>
      }
    } else if(state == '%'){
 7f6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7fa:	0f 85 23 01 00 00    	jne    923 <printf+0x196>
      if(c == 'd'){
 800:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 804:	75 2d                	jne    833 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 806:	8b 45 e8             	mov    -0x18(%ebp),%eax
 809:	8b 00                	mov    (%eax),%eax
 80b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 812:	00 
 813:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 81a:	00 
 81b:	89 44 24 04          	mov    %eax,0x4(%esp)
 81f:	8b 45 08             	mov    0x8(%ebp),%eax
 822:	89 04 24             	mov    %eax,(%esp)
 825:	e8 ae fe ff ff       	call   6d8 <printint>
        ap++;
 82a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82e:	e9 e9 00 00 00       	jmp    91c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 833:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 837:	74 06                	je     83f <printf+0xb2>
 839:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 83d:	75 2d                	jne    86c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 83f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 842:	8b 00                	mov    (%eax),%eax
 844:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 84b:	00 
 84c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 853:	00 
 854:	89 44 24 04          	mov    %eax,0x4(%esp)
 858:	8b 45 08             	mov    0x8(%ebp),%eax
 85b:	89 04 24             	mov    %eax,(%esp)
 85e:	e8 75 fe ff ff       	call   6d8 <printint>
        ap++;
 863:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 867:	e9 b0 00 00 00       	jmp    91c <printf+0x18f>
      } else if(c == 's'){
 86c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 870:	75 42                	jne    8b4 <printf+0x127>
        s = (char*)*ap;
 872:	8b 45 e8             	mov    -0x18(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 87a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 87e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 882:	75 09                	jne    88d <printf+0x100>
          s = "(null)";
 884:	c7 45 f4 04 0c 00 00 	movl   $0xc04,-0xc(%ebp)
        while(*s != 0){
 88b:	eb 1c                	jmp    8a9 <printf+0x11c>
 88d:	eb 1a                	jmp    8a9 <printf+0x11c>
          putc(fd, *s);
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	8a 00                	mov    (%eax),%al
 894:	0f be c0             	movsbl %al,%eax
 897:	89 44 24 04          	mov    %eax,0x4(%esp)
 89b:	8b 45 08             	mov    0x8(%ebp),%eax
 89e:	89 04 24             	mov    %eax,(%esp)
 8a1:	e8 0a fe ff ff       	call   6b0 <putc>
          s++;
 8a6:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	8a 00                	mov    (%eax),%al
 8ae:	84 c0                	test   %al,%al
 8b0:	75 dd                	jne    88f <printf+0x102>
 8b2:	eb 68                	jmp    91c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8b4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8b8:	75 1d                	jne    8d7 <printf+0x14a>
        putc(fd, *ap);
 8ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	0f be c0             	movsbl %al,%eax
 8c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c6:	8b 45 08             	mov    0x8(%ebp),%eax
 8c9:	89 04 24             	mov    %eax,(%esp)
 8cc:	e8 df fd ff ff       	call   6b0 <putc>
        ap++;
 8d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8d5:	eb 45                	jmp    91c <printf+0x18f>
      } else if(c == '%'){
 8d7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8db:	75 17                	jne    8f4 <printf+0x167>
        putc(fd, c);
 8dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8e0:	0f be c0             	movsbl %al,%eax
 8e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 8e7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ea:	89 04 24             	mov    %eax,(%esp)
 8ed:	e8 be fd ff ff       	call   6b0 <putc>
 8f2:	eb 28                	jmp    91c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8f4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8fb:	00 
 8fc:	8b 45 08             	mov    0x8(%ebp),%eax
 8ff:	89 04 24             	mov    %eax,(%esp)
 902:	e8 a9 fd ff ff       	call   6b0 <putc>
        putc(fd, c);
 907:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 90a:	0f be c0             	movsbl %al,%eax
 90d:	89 44 24 04          	mov    %eax,0x4(%esp)
 911:	8b 45 08             	mov    0x8(%ebp),%eax
 914:	89 04 24             	mov    %eax,(%esp)
 917:	e8 94 fd ff ff       	call   6b0 <putc>
      }
      state = 0;
 91c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 923:	ff 45 f0             	incl   -0x10(%ebp)
 926:	8b 55 0c             	mov    0xc(%ebp),%edx
 929:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92c:	01 d0                	add    %edx,%eax
 92e:	8a 00                	mov    (%eax),%al
 930:	84 c0                	test   %al,%al
 932:	0f 85 77 fe ff ff    	jne    7af <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 938:	c9                   	leave  
 939:	c3                   	ret    
 93a:	90                   	nop
 93b:	90                   	nop

0000093c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93c:	55                   	push   %ebp
 93d:	89 e5                	mov    %esp,%ebp
 93f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 942:	8b 45 08             	mov    0x8(%ebp),%eax
 945:	83 e8 08             	sub    $0x8,%eax
 948:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94b:	a1 90 0f 00 00       	mov    0xf90,%eax
 950:	89 45 fc             	mov    %eax,-0x4(%ebp)
 953:	eb 24                	jmp    979 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	8b 00                	mov    (%eax),%eax
 95a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 95d:	77 12                	ja     971 <free+0x35>
 95f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 962:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 965:	77 24                	ja     98b <free+0x4f>
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	8b 00                	mov    (%eax),%eax
 96c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 96f:	77 1a                	ja     98b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 971:	8b 45 fc             	mov    -0x4(%ebp),%eax
 974:	8b 00                	mov    (%eax),%eax
 976:	89 45 fc             	mov    %eax,-0x4(%ebp)
 979:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 97f:	76 d4                	jbe    955 <free+0x19>
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	8b 00                	mov    (%eax),%eax
 986:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 989:	76 ca                	jbe    955 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 98b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98e:	8b 40 04             	mov    0x4(%eax),%eax
 991:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 998:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99b:	01 c2                	add    %eax,%edx
 99d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a0:	8b 00                	mov    (%eax),%eax
 9a2:	39 c2                	cmp    %eax,%edx
 9a4:	75 24                	jne    9ca <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a9:	8b 50 04             	mov    0x4(%eax),%edx
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	8b 00                	mov    (%eax),%eax
 9b1:	8b 40 04             	mov    0x4(%eax),%eax
 9b4:	01 c2                	add    %eax,%edx
 9b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bf:	8b 00                	mov    (%eax),%eax
 9c1:	8b 10                	mov    (%eax),%edx
 9c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c6:	89 10                	mov    %edx,(%eax)
 9c8:	eb 0a                	jmp    9d4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cd:	8b 10                	mov    (%eax),%edx
 9cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d7:	8b 40 04             	mov    0x4(%eax),%eax
 9da:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e4:	01 d0                	add    %edx,%eax
 9e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9e9:	75 20                	jne    a0b <free+0xcf>
    p->s.size += bp->s.size;
 9eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ee:	8b 50 04             	mov    0x4(%eax),%edx
 9f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	01 c2                	add    %eax,%edx
 9f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a02:	8b 10                	mov    (%eax),%edx
 a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a07:	89 10                	mov    %edx,(%eax)
 a09:	eb 08                	jmp    a13 <free+0xd7>
  } else
    p->s.ptr = bp;
 a0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a11:	89 10                	mov    %edx,(%eax)
  freep = p;
 a13:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a16:	a3 90 0f 00 00       	mov    %eax,0xf90
}
 a1b:	c9                   	leave  
 a1c:	c3                   	ret    

00000a1d <morecore>:

static Header*
morecore(uint nu)
{
 a1d:	55                   	push   %ebp
 a1e:	89 e5                	mov    %esp,%ebp
 a20:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a23:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a2a:	77 07                	ja     a33 <morecore+0x16>
    nu = 4096;
 a2c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a33:	8b 45 08             	mov    0x8(%ebp),%eax
 a36:	c1 e0 03             	shl    $0x3,%eax
 a39:	89 04 24             	mov    %eax,(%esp)
 a3c:	e8 4f fc ff ff       	call   690 <sbrk>
 a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a44:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a48:	75 07                	jne    a51 <morecore+0x34>
    return 0;
 a4a:	b8 00 00 00 00       	mov    $0x0,%eax
 a4f:	eb 22                	jmp    a73 <morecore+0x56>
  hp = (Header*)p;
 a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5a:	8b 55 08             	mov    0x8(%ebp),%edx
 a5d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a63:	83 c0 08             	add    $0x8,%eax
 a66:	89 04 24             	mov    %eax,(%esp)
 a69:	e8 ce fe ff ff       	call   93c <free>
  return freep;
 a6e:	a1 90 0f 00 00       	mov    0xf90,%eax
}
 a73:	c9                   	leave  
 a74:	c3                   	ret    

00000a75 <malloc>:

void*
malloc(uint nbytes)
{
 a75:	55                   	push   %ebp
 a76:	89 e5                	mov    %esp,%ebp
 a78:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a7b:	8b 45 08             	mov    0x8(%ebp),%eax
 a7e:	83 c0 07             	add    $0x7,%eax
 a81:	c1 e8 03             	shr    $0x3,%eax
 a84:	40                   	inc    %eax
 a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a88:	a1 90 0f 00 00       	mov    0xf90,%eax
 a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a94:	75 23                	jne    ab9 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a96:	c7 45 f0 88 0f 00 00 	movl   $0xf88,-0x10(%ebp)
 a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa0:	a3 90 0f 00 00       	mov    %eax,0xf90
 aa5:	a1 90 0f 00 00       	mov    0xf90,%eax
 aaa:	a3 88 0f 00 00       	mov    %eax,0xf88
    base.s.size = 0;
 aaf:	c7 05 8c 0f 00 00 00 	movl   $0x0,0xf8c
 ab6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abc:	8b 00                	mov    (%eax),%eax
 abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac4:	8b 40 04             	mov    0x4(%eax),%eax
 ac7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aca:	72 4d                	jb     b19 <malloc+0xa4>
      if(p->s.size == nunits)
 acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acf:	8b 40 04             	mov    0x4(%eax),%eax
 ad2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ad5:	75 0c                	jne    ae3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ada:	8b 10                	mov    (%eax),%edx
 adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 adf:	89 10                	mov    %edx,(%eax)
 ae1:	eb 26                	jmp    b09 <malloc+0x94>
      else {
        p->s.size -= nunits;
 ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae6:	8b 40 04             	mov    0x4(%eax),%eax
 ae9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aec:	89 c2                	mov    %eax,%edx
 aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	8b 40 04             	mov    0x4(%eax),%eax
 afa:	c1 e0 03             	shl    $0x3,%eax
 afd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b03:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b06:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b0c:	a3 90 0f 00 00       	mov    %eax,0xf90
      return (void*)(p + 1);
 b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b14:	83 c0 08             	add    $0x8,%eax
 b17:	eb 38                	jmp    b51 <malloc+0xdc>
    }
    if(p == freep)
 b19:	a1 90 0f 00 00       	mov    0xf90,%eax
 b1e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b21:	75 1b                	jne    b3e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b26:	89 04 24             	mov    %eax,(%esp)
 b29:	e8 ef fe ff ff       	call   a1d <morecore>
 b2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b35:	75 07                	jne    b3e <malloc+0xc9>
        return 0;
 b37:	b8 00 00 00 00       	mov    $0x0,%eax
 b3c:	eb 13                	jmp    b51 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b47:	8b 00                	mov    (%eax),%eax
 b49:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b4c:	e9 70 ff ff ff       	jmp    ac1 <malloc+0x4c>
}
 b51:	c9                   	leave  
 b52:	c3                   	ret    
