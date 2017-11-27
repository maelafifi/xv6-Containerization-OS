
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
  5d:	e8 3e 06 00 00       	call   6a0 <open>
  62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(fd_write < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <copy_files+0x3e>
		printf(1, "Invalid file location.\n");
  6b:	c7 44 24 04 ac 0b 00 	movl   $0xbac,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 66 07 00 00       	call   7e5 <printf>
		return;
  7f:	e9 8c 00 00 00       	jmp    110 <copy_files+0xca>
	}

	int fd_read = open(src, O_RDONLY);
  84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8b:	00 
  8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  8f:	89 04 24             	mov    %eax,(%esp)
  92:	e8 09 06 00 00       	call   6a0 <open>
  97:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(fd_read < 0){
  9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9e:	79 16                	jns    b6 <copy_files+0x70>
		printf(1, "Invalid file location.\n");
  a0:	c7 44 24 04 ac 0b 00 	movl   $0xbac,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 31 07 00 00       	call   7e5 <printf>
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
  cf:	e8 ac 05 00 00       	call   680 <write>
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
  ec:	e8 87 05 00 00       	call   678 <read>
  f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f8:	7f be                	jg     b8 <copy_files+0x72>
		write(fd_write, buf, bytes_read);
	}
	close(fd_write);
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 83 05 00 00       	call   688 <close>
	close(fd_read);
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 78 05 00 00       	call   688 <close>
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
 121:	e8 a2 05 00 00       	call   6c8 <mkdir>
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
 16c:	c7 44 24 04 c4 0b 00 	movl   $0xbc4,0x4(%esp)
 173:	00 
 174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17b:	e8 65 06 00 00       	call   7e5 <printf>

		char dir[strlen(c_args[0])];
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	8b 00                	mov    (%eax),%eax
 185:	89 04 24             	mov    %eax,(%esp)
 188:	e8 0a 03 00 00       	call   497 <strlen>
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
 1c5:	e8 67 02 00 00       	call   431 <strcpy>
		strcat(dir, "/");
 1ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1cd:	c7 44 24 04 c9 0b 00 	movl   $0xbc9,0x4(%esp)
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
 207:	c7 44 24 04 cb 0b 00 	movl   $0xbcb,0x4(%esp)
 20e:	00 
 20f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 216:	e8 ca 05 00 00       	call   7e5 <printf>

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
 265:	e8 36 04 00 00       	call   6a0 <open>
 26a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	89 04 24             	mov    %eax,(%esp)
 273:	e8 58 04 00 00       	call   6d0 <chdir>

	/* fork a child and exec argv[1] */
	id = fork();
 278:	e8 db 03 00 00       	call   658 <fork>
 27d:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 280:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 284:	75 70                	jne    2f6 <attach_vc+0xa5>
		close(0);
 286:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 28d:	e8 f6 03 00 00       	call   688 <close>
		close(1);
 292:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 299:	e8 ea 03 00 00       	call   688 <close>
		close(2);
 29e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2a5:	e8 de 03 00 00       	call   688 <close>
		dup(fd);
 2aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ad:	89 04 24             	mov    %eax,(%esp)
 2b0:	e8 23 04 00 00       	call   6d8 <dup>
		dup(fd);
 2b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b8:	89 04 24             	mov    %eax,(%esp)
 2bb:	e8 18 04 00 00       	call   6d8 <dup>
		dup(fd);
 2c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c3:	89 04 24             	mov    %eax,(%esp)
 2c6:	e8 0d 04 00 00       	call   6d8 <dup>
		exec(file, &file);
 2cb:	8b 45 10             	mov    0x10(%ebp),%eax
 2ce:	8d 55 10             	lea    0x10(%ebp),%edx
 2d1:	89 54 24 04          	mov    %edx,0x4(%esp)
 2d5:	89 04 24             	mov    %eax,(%esp)
 2d8:	e8 bb 03 00 00       	call   698 <exec>
		printf(1, "Failure to attach VC.");
 2dd:	c7 44 24 04 da 0b 00 	movl   $0xbda,0x4(%esp)
 2e4:	00 
 2e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ec:	e8 f4 04 00 00       	call   7e5 <printf>
		exit();
 2f1:	e8 6a 03 00 00       	call   660 <exit>
	}
}
 2f6:	c9                   	leave  
 2f7:	c3                   	ret    

000002f8 <start>:

void start(char *s_args[]){
 2f8:	55                   	push   %ebp
 2f9:	89 e5                	mov    %esp,%ebp
 2fb:	83 ec 28             	sub    $0x28,%esp
	// if((index = next_open_index()) < 0){
	// 	printf(1, "No Available Containers.\n");
	// 	return;
	// }

	int x = 0;
 2fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(s_args[x] != 0){
 305:	eb 03                	jmp    30a <start+0x12>
			x++;
 307:	ff 45 f4             	incl   -0xc(%ebp)
	// 	printf(1, "No Available Containers.\n");
	// 	return;
	// }

	int x = 0;
	while(s_args[x] != 0){
 30a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	01 d0                	add    %edx,%eax
 319:	8b 00                	mov    (%eax),%eax
 31b:	85 c0                	test   %eax,%eax
 31d:	75 e8                	jne    307 <start+0xf>
			x++;
	}

	//Make a VC in use function that checks if that VC is in use by a container
	char* vc = s_args[0];
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	8b 00                	mov    (%eax),%eax
 324:	89 45 f0             	mov    %eax,-0x10(%ebp)
	char* dir = s_args[1];
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	8b 40 04             	mov    0x4(%eax),%eax
 32d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char* file = s_args[2];
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	8b 40 08             	mov    0x8(%eax),%eax
 336:	89 45 e8             	mov    %eax,-0x18(%ebp)
	// }

	//ASsume they give us the values for now
	// set_max_a

	attach_vc(vc, dir, file);
 339:	8b 45 e8             	mov    -0x18(%ebp),%eax
 33c:	89 44 24 08          	mov    %eax,0x8(%esp)
 340:	8b 45 ec             	mov    -0x14(%ebp),%eax
 343:	89 44 24 04          	mov    %eax,0x4(%esp)
 347:	8b 45 f0             	mov    -0x10(%ebp),%eax
 34a:	89 04 24             	mov    %eax,(%esp)
 34d:	e8 ff fe ff ff       	call   251 <attach_vc>
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 352:	c9                   	leave  
 353:	c3                   	ret    

00000354 <pause>:

void pause(char *c_name){
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp

}
 357:	5d                   	pop    %ebp
 358:	c3                   	ret    

00000359 <resume>:

void resume(char *c_name){
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp

}
 35c:	5d                   	pop    %ebp
 35d:	c3                   	ret    

0000035e <stop>:

void stop(char *c_name){
 35e:	55                   	push   %ebp
 35f:	89 e5                	mov    %esp,%ebp

}
 361:	5d                   	pop    %ebp
 362:	c3                   	ret    

00000363 <info>:

void info(char *c_name){
 363:	55                   	push   %ebp
 364:	89 e5                	mov    %esp,%ebp

}
 366:	5d                   	pop    %ebp
 367:	c3                   	ret    

00000368 <main>:

int main(int argc, char *argv[]){
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	83 e4 f0             	and    $0xfffffff0,%esp
 36e:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
 371:	8b 45 0c             	mov    0xc(%ebp),%eax
 374:	83 c0 04             	add    $0x4,%eax
 377:	8b 00                	mov    (%eax),%eax
 379:	c7 44 24 04 f0 0b 00 	movl   $0xbf0,0x4(%esp)
 380:	00 
 381:	89 04 24             	mov    %eax,(%esp)
 384:	e8 d6 00 00 00       	call   45f <strcmp>
 389:	85 c0                	test   %eax,%eax
 38b:	75 24                	jne    3b1 <main+0x49>
		printf(1, "Calling create\n");
 38d:	c7 44 24 04 f7 0b 00 	movl   $0xbf7,0x4(%esp)
 394:	00 
 395:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 39c:	e8 44 04 00 00       	call   7e5 <printf>
		create(&argv[2]);
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	83 c0 08             	add    $0x8,%eax
 3a7:	89 04 24             	mov    %eax,(%esp)
 3aa:	e8 63 fd ff ff       	call   112 <create>
 3af:	eb 40                	jmp    3f1 <main+0x89>
	}
	else if(strcmp(argv[1], "start") == 0){
 3b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b4:	83 c0 04             	add    $0x4,%eax
 3b7:	8b 00                	mov    (%eax),%eax
 3b9:	c7 44 24 04 07 0c 00 	movl   $0xc07,0x4(%esp)
 3c0:	00 
 3c1:	89 04 24             	mov    %eax,(%esp)
 3c4:	e8 96 00 00 00       	call   45f <strcmp>
 3c9:	85 c0                	test   %eax,%eax
 3cb:	75 10                	jne    3dd <main+0x75>
		start(&argv[2]);
 3cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d0:	83 c0 08             	add    $0x8,%eax
 3d3:	89 04 24             	mov    %eax,(%esp)
 3d6:	e8 1d ff ff ff       	call   2f8 <start>
 3db:	eb 14                	jmp    3f1 <main+0x89>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info.\n");
 3dd:	c7 44 24 04 10 0c 00 	movl   $0xc10,0x4(%esp)
 3e4:	00 
 3e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3ec:	e8 f4 03 00 00       	call   7e5 <printf>
	}
	printf(1, "Done with ctool\n");
 3f1:	c7 44 24 04 4b 0c 00 	movl   $0xc4b,0x4(%esp)
 3f8:	00 
 3f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 400:	e8 e0 03 00 00       	call   7e5 <printf>

	//Fucking main DOESNT RETURN 0 IT EXITS or else you get a trap error and then spend an hour seeing where you messed up. 
	exit();
 405:	e8 56 02 00 00       	call   660 <exit>
 40a:	90                   	nop
 40b:	90                   	nop

0000040c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 40c:	55                   	push   %ebp
 40d:	89 e5                	mov    %esp,%ebp
 40f:	57                   	push   %edi
 410:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 411:	8b 4d 08             	mov    0x8(%ebp),%ecx
 414:	8b 55 10             	mov    0x10(%ebp),%edx
 417:	8b 45 0c             	mov    0xc(%ebp),%eax
 41a:	89 cb                	mov    %ecx,%ebx
 41c:	89 df                	mov    %ebx,%edi
 41e:	89 d1                	mov    %edx,%ecx
 420:	fc                   	cld    
 421:	f3 aa                	rep stos %al,%es:(%edi)
 423:	89 ca                	mov    %ecx,%edx
 425:	89 fb                	mov    %edi,%ebx
 427:	89 5d 08             	mov    %ebx,0x8(%ebp)
 42a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 42d:	5b                   	pop    %ebx
 42e:	5f                   	pop    %edi
 42f:	5d                   	pop    %ebp
 430:	c3                   	ret    

00000431 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 431:	55                   	push   %ebp
 432:	89 e5                	mov    %esp,%ebp
 434:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 43d:	90                   	nop
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	8d 50 01             	lea    0x1(%eax),%edx
 444:	89 55 08             	mov    %edx,0x8(%ebp)
 447:	8b 55 0c             	mov    0xc(%ebp),%edx
 44a:	8d 4a 01             	lea    0x1(%edx),%ecx
 44d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 450:	8a 12                	mov    (%edx),%dl
 452:	88 10                	mov    %dl,(%eax)
 454:	8a 00                	mov    (%eax),%al
 456:	84 c0                	test   %al,%al
 458:	75 e4                	jne    43e <strcpy+0xd>
    ;
  return os;
 45a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 45d:	c9                   	leave  
 45e:	c3                   	ret    

0000045f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 45f:	55                   	push   %ebp
 460:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 462:	eb 06                	jmp    46a <strcmp+0xb>
    p++, q++;
 464:	ff 45 08             	incl   0x8(%ebp)
 467:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	8a 00                	mov    (%eax),%al
 46f:	84 c0                	test   %al,%al
 471:	74 0e                	je     481 <strcmp+0x22>
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	8a 10                	mov    (%eax),%dl
 478:	8b 45 0c             	mov    0xc(%ebp),%eax
 47b:	8a 00                	mov    (%eax),%al
 47d:	38 c2                	cmp    %al,%dl
 47f:	74 e3                	je     464 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	8a 00                	mov    (%eax),%al
 486:	0f b6 d0             	movzbl %al,%edx
 489:	8b 45 0c             	mov    0xc(%ebp),%eax
 48c:	8a 00                	mov    (%eax),%al
 48e:	0f b6 c0             	movzbl %al,%eax
 491:	29 c2                	sub    %eax,%edx
 493:	89 d0                	mov    %edx,%eax
}
 495:	5d                   	pop    %ebp
 496:	c3                   	ret    

00000497 <strlen>:

uint
strlen(char *s)
{
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 49d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4a4:	eb 03                	jmp    4a9 <strlen+0x12>
 4a6:	ff 45 fc             	incl   -0x4(%ebp)
 4a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ac:	8b 45 08             	mov    0x8(%ebp),%eax
 4af:	01 d0                	add    %edx,%eax
 4b1:	8a 00                	mov    (%eax),%al
 4b3:	84 c0                	test   %al,%al
 4b5:	75 ef                	jne    4a6 <strlen+0xf>
    ;
  return n;
 4b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4ba:	c9                   	leave  
 4bb:	c3                   	ret    

000004bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 4bc:	55                   	push   %ebp
 4bd:	89 e5                	mov    %esp,%ebp
 4bf:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 4c2:	8b 45 10             	mov    0x10(%ebp),%eax
 4c5:	89 44 24 08          	mov    %eax,0x8(%esp)
 4c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	89 04 24             	mov    %eax,(%esp)
 4d6:	e8 31 ff ff ff       	call   40c <stosb>
  return dst;
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4de:	c9                   	leave  
 4df:	c3                   	ret    

000004e0 <strchr>:

char*
strchr(const char *s, char c)
{
 4e0:	55                   	push   %ebp
 4e1:	89 e5                	mov    %esp,%ebp
 4e3:	83 ec 04             	sub    $0x4,%esp
 4e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4ec:	eb 12                	jmp    500 <strchr+0x20>
    if(*s == c)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	8a 00                	mov    (%eax),%al
 4f3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 4f6:	75 05                	jne    4fd <strchr+0x1d>
      return (char*)s;
 4f8:	8b 45 08             	mov    0x8(%ebp),%eax
 4fb:	eb 11                	jmp    50e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 4fd:	ff 45 08             	incl   0x8(%ebp)
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	8a 00                	mov    (%eax),%al
 505:	84 c0                	test   %al,%al
 507:	75 e5                	jne    4ee <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 509:	b8 00 00 00 00       	mov    $0x0,%eax
}
 50e:	c9                   	leave  
 50f:	c3                   	ret    

00000510 <gets>:

char*
gets(char *buf, int max)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 516:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 51d:	eb 49                	jmp    568 <gets+0x58>
    cc = read(0, &c, 1);
 51f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 526:	00 
 527:	8d 45 ef             	lea    -0x11(%ebp),%eax
 52a:	89 44 24 04          	mov    %eax,0x4(%esp)
 52e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 535:	e8 3e 01 00 00       	call   678 <read>
 53a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 53d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 541:	7f 02                	jg     545 <gets+0x35>
      break;
 543:	eb 2c                	jmp    571 <gets+0x61>
    buf[i++] = c;
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	8d 50 01             	lea    0x1(%eax),%edx
 54b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54e:	89 c2                	mov    %eax,%edx
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	01 c2                	add    %eax,%edx
 555:	8a 45 ef             	mov    -0x11(%ebp),%al
 558:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 55a:	8a 45 ef             	mov    -0x11(%ebp),%al
 55d:	3c 0a                	cmp    $0xa,%al
 55f:	74 10                	je     571 <gets+0x61>
 561:	8a 45 ef             	mov    -0x11(%ebp),%al
 564:	3c 0d                	cmp    $0xd,%al
 566:	74 09                	je     571 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 568:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56b:	40                   	inc    %eax
 56c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 56f:	7c ae                	jl     51f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 571:	8b 55 f4             	mov    -0xc(%ebp),%edx
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	01 d0                	add    %edx,%eax
 579:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 57f:	c9                   	leave  
 580:	c3                   	ret    

00000581 <stat>:

int
stat(char *n, struct stat *st)
{
 581:	55                   	push   %ebp
 582:	89 e5                	mov    %esp,%ebp
 584:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 587:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 58e:	00 
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 06 01 00 00       	call   6a0 <open>
 59a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 59d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a1:	79 07                	jns    5aa <stat+0x29>
    return -1;
 5a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5a8:	eb 23                	jmp    5cd <stat+0x4c>
  r = fstat(fd, st);
 5aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b4:	89 04 24             	mov    %eax,(%esp)
 5b7:	e8 fc 00 00 00       	call   6b8 <fstat>
 5bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c2:	89 04 24             	mov    %eax,(%esp)
 5c5:	e8 be 00 00 00       	call   688 <close>
  return r;
 5ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    

000005cf <atoi>:

int
atoi(const char *s)
{
 5cf:	55                   	push   %ebp
 5d0:	89 e5                	mov    %esp,%ebp
 5d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5dc:	eb 24                	jmp    602 <atoi+0x33>
    n = n*10 + *s++ - '0';
 5de:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5e1:	89 d0                	mov    %edx,%eax
 5e3:	c1 e0 02             	shl    $0x2,%eax
 5e6:	01 d0                	add    %edx,%eax
 5e8:	01 c0                	add    %eax,%eax
 5ea:	89 c1                	mov    %eax,%ecx
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
 5ef:	8d 50 01             	lea    0x1(%eax),%edx
 5f2:	89 55 08             	mov    %edx,0x8(%ebp)
 5f5:	8a 00                	mov    (%eax),%al
 5f7:	0f be c0             	movsbl %al,%eax
 5fa:	01 c8                	add    %ecx,%eax
 5fc:	83 e8 30             	sub    $0x30,%eax
 5ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 602:	8b 45 08             	mov    0x8(%ebp),%eax
 605:	8a 00                	mov    (%eax),%al
 607:	3c 2f                	cmp    $0x2f,%al
 609:	7e 09                	jle    614 <atoi+0x45>
 60b:	8b 45 08             	mov    0x8(%ebp),%eax
 60e:	8a 00                	mov    (%eax),%al
 610:	3c 39                	cmp    $0x39,%al
 612:	7e ca                	jle    5de <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 614:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 617:	c9                   	leave  
 618:	c3                   	ret    

00000619 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 619:	55                   	push   %ebp
 61a:	89 e5                	mov    %esp,%ebp
 61c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 61f:	8b 45 08             	mov    0x8(%ebp),%eax
 622:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 625:	8b 45 0c             	mov    0xc(%ebp),%eax
 628:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 62b:	eb 16                	jmp    643 <memmove+0x2a>
    *dst++ = *src++;
 62d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 630:	8d 50 01             	lea    0x1(%eax),%edx
 633:	89 55 fc             	mov    %edx,-0x4(%ebp)
 636:	8b 55 f8             	mov    -0x8(%ebp),%edx
 639:	8d 4a 01             	lea    0x1(%edx),%ecx
 63c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 63f:	8a 12                	mov    (%edx),%dl
 641:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 643:	8b 45 10             	mov    0x10(%ebp),%eax
 646:	8d 50 ff             	lea    -0x1(%eax),%edx
 649:	89 55 10             	mov    %edx,0x10(%ebp)
 64c:	85 c0                	test   %eax,%eax
 64e:	7f dd                	jg     62d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 650:	8b 45 08             	mov    0x8(%ebp),%eax
}
 653:	c9                   	leave  
 654:	c3                   	ret    
 655:	90                   	nop
 656:	90                   	nop
 657:	90                   	nop

00000658 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 658:	b8 01 00 00 00       	mov    $0x1,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <exit>:
SYSCALL(exit)
 660:	b8 02 00 00 00       	mov    $0x2,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <wait>:
SYSCALL(wait)
 668:	b8 03 00 00 00       	mov    $0x3,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <pipe>:
SYSCALL(pipe)
 670:	b8 04 00 00 00       	mov    $0x4,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <read>:
SYSCALL(read)
 678:	b8 05 00 00 00       	mov    $0x5,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <write>:
SYSCALL(write)
 680:	b8 10 00 00 00       	mov    $0x10,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <close>:
SYSCALL(close)
 688:	b8 15 00 00 00       	mov    $0x15,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <kill>:
SYSCALL(kill)
 690:	b8 06 00 00 00       	mov    $0x6,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <exec>:
SYSCALL(exec)
 698:	b8 07 00 00 00       	mov    $0x7,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <open>:
SYSCALL(open)
 6a0:	b8 0f 00 00 00       	mov    $0xf,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <mknod>:
SYSCALL(mknod)
 6a8:	b8 11 00 00 00       	mov    $0x11,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <unlink>:
SYSCALL(unlink)
 6b0:	b8 12 00 00 00       	mov    $0x12,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <fstat>:
SYSCALL(fstat)
 6b8:	b8 08 00 00 00       	mov    $0x8,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <link>:
SYSCALL(link)
 6c0:	b8 13 00 00 00       	mov    $0x13,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <mkdir>:
SYSCALL(mkdir)
 6c8:	b8 14 00 00 00       	mov    $0x14,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <chdir>:
SYSCALL(chdir)
 6d0:	b8 09 00 00 00       	mov    $0x9,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <dup>:
SYSCALL(dup)
 6d8:	b8 0a 00 00 00       	mov    $0xa,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <getpid>:
SYSCALL(getpid)
 6e0:	b8 0b 00 00 00       	mov    $0xb,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <sbrk>:
SYSCALL(sbrk)
 6e8:	b8 0c 00 00 00       	mov    $0xc,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <sleep>:
SYSCALL(sleep)
 6f0:	b8 0d 00 00 00       	mov    $0xd,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <uptime>:
SYSCALL(uptime)
 6f8:	b8 0e 00 00 00       	mov    $0xe,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <getticks>:
 700:	b8 16 00 00 00       	mov    $0x16,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 708:	55                   	push   %ebp
 709:	89 e5                	mov    %esp,%ebp
 70b:	83 ec 18             	sub    $0x18,%esp
 70e:	8b 45 0c             	mov    0xc(%ebp),%eax
 711:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 714:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 71b:	00 
 71c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 71f:	89 44 24 04          	mov    %eax,0x4(%esp)
 723:	8b 45 08             	mov    0x8(%ebp),%eax
 726:	89 04 24             	mov    %eax,(%esp)
 729:	e8 52 ff ff ff       	call   680 <write>
}
 72e:	c9                   	leave  
 72f:	c3                   	ret    

00000730 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 730:	55                   	push   %ebp
 731:	89 e5                	mov    %esp,%ebp
 733:	56                   	push   %esi
 734:	53                   	push   %ebx
 735:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 738:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 73f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 743:	74 17                	je     75c <printint+0x2c>
 745:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 749:	79 11                	jns    75c <printint+0x2c>
    neg = 1;
 74b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 752:	8b 45 0c             	mov    0xc(%ebp),%eax
 755:	f7 d8                	neg    %eax
 757:	89 45 ec             	mov    %eax,-0x14(%ebp)
 75a:	eb 06                	jmp    762 <printint+0x32>
  } else {
    x = xx;
 75c:	8b 45 0c             	mov    0xc(%ebp),%eax
 75f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 762:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 769:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 76c:	8d 41 01             	lea    0x1(%ecx),%eax
 76f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 772:	8b 5d 10             	mov    0x10(%ebp),%ebx
 775:	8b 45 ec             	mov    -0x14(%ebp),%eax
 778:	ba 00 00 00 00       	mov    $0x0,%edx
 77d:	f7 f3                	div    %ebx
 77f:	89 d0                	mov    %edx,%eax
 781:	8a 80 cc 0f 00 00    	mov    0xfcc(%eax),%al
 787:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 78b:	8b 75 10             	mov    0x10(%ebp),%esi
 78e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 791:	ba 00 00 00 00       	mov    $0x0,%edx
 796:	f7 f6                	div    %esi
 798:	89 45 ec             	mov    %eax,-0x14(%ebp)
 79b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 79f:	75 c8                	jne    769 <printint+0x39>
  if(neg)
 7a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7a5:	74 10                	je     7b7 <printint+0x87>
    buf[i++] = '-';
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	8d 50 01             	lea    0x1(%eax),%edx
 7ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7b0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7b5:	eb 1e                	jmp    7d5 <printint+0xa5>
 7b7:	eb 1c                	jmp    7d5 <printint+0xa5>
    putc(fd, buf[i]);
 7b9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	01 d0                	add    %edx,%eax
 7c1:	8a 00                	mov    (%eax),%al
 7c3:	0f be c0             	movsbl %al,%eax
 7c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ca:	8b 45 08             	mov    0x8(%ebp),%eax
 7cd:	89 04 24             	mov    %eax,(%esp)
 7d0:	e8 33 ff ff ff       	call   708 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7d5:	ff 4d f4             	decl   -0xc(%ebp)
 7d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7dc:	79 db                	jns    7b9 <printint+0x89>
    putc(fd, buf[i]);
}
 7de:	83 c4 30             	add    $0x30,%esp
 7e1:	5b                   	pop    %ebx
 7e2:	5e                   	pop    %esi
 7e3:	5d                   	pop    %ebp
 7e4:	c3                   	ret    

000007e5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7e5:	55                   	push   %ebp
 7e6:	89 e5                	mov    %esp,%ebp
 7e8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7f2:	8d 45 0c             	lea    0xc(%ebp),%eax
 7f5:	83 c0 04             	add    $0x4,%eax
 7f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 802:	e9 77 01 00 00       	jmp    97e <printf+0x199>
    c = fmt[i] & 0xff;
 807:	8b 55 0c             	mov    0xc(%ebp),%edx
 80a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80d:	01 d0                	add    %edx,%eax
 80f:	8a 00                	mov    (%eax),%al
 811:	0f be c0             	movsbl %al,%eax
 814:	25 ff 00 00 00       	and    $0xff,%eax
 819:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 81c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 820:	75 2c                	jne    84e <printf+0x69>
      if(c == '%'){
 822:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 826:	75 0c                	jne    834 <printf+0x4f>
        state = '%';
 828:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 82f:	e9 47 01 00 00       	jmp    97b <printf+0x196>
      } else {
        putc(fd, c);
 834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 837:	0f be c0             	movsbl %al,%eax
 83a:	89 44 24 04          	mov    %eax,0x4(%esp)
 83e:	8b 45 08             	mov    0x8(%ebp),%eax
 841:	89 04 24             	mov    %eax,(%esp)
 844:	e8 bf fe ff ff       	call   708 <putc>
 849:	e9 2d 01 00 00       	jmp    97b <printf+0x196>
      }
    } else if(state == '%'){
 84e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 852:	0f 85 23 01 00 00    	jne    97b <printf+0x196>
      if(c == 'd'){
 858:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 85c:	75 2d                	jne    88b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 85e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 861:	8b 00                	mov    (%eax),%eax
 863:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 86a:	00 
 86b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 872:	00 
 873:	89 44 24 04          	mov    %eax,0x4(%esp)
 877:	8b 45 08             	mov    0x8(%ebp),%eax
 87a:	89 04 24             	mov    %eax,(%esp)
 87d:	e8 ae fe ff ff       	call   730 <printint>
        ap++;
 882:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 886:	e9 e9 00 00 00       	jmp    974 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 88b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 88f:	74 06                	je     897 <printf+0xb2>
 891:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 895:	75 2d                	jne    8c4 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 897:	8b 45 e8             	mov    -0x18(%ebp),%eax
 89a:	8b 00                	mov    (%eax),%eax
 89c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 8a3:	00 
 8a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8ab:	00 
 8ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b0:	8b 45 08             	mov    0x8(%ebp),%eax
 8b3:	89 04 24             	mov    %eax,(%esp)
 8b6:	e8 75 fe ff ff       	call   730 <printint>
        ap++;
 8bb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8bf:	e9 b0 00 00 00       	jmp    974 <printf+0x18f>
      } else if(c == 's'){
 8c4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8c8:	75 42                	jne    90c <printf+0x127>
        s = (char*)*ap;
 8ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8cd:	8b 00                	mov    (%eax),%eax
 8cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8da:	75 09                	jne    8e5 <printf+0x100>
          s = "(null)";
 8dc:	c7 45 f4 5c 0c 00 00 	movl   $0xc5c,-0xc(%ebp)
        while(*s != 0){
 8e3:	eb 1c                	jmp    901 <printf+0x11c>
 8e5:	eb 1a                	jmp    901 <printf+0x11c>
          putc(fd, *s);
 8e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ea:	8a 00                	mov    (%eax),%al
 8ec:	0f be c0             	movsbl %al,%eax
 8ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f3:	8b 45 08             	mov    0x8(%ebp),%eax
 8f6:	89 04 24             	mov    %eax,(%esp)
 8f9:	e8 0a fe ff ff       	call   708 <putc>
          s++;
 8fe:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 901:	8b 45 f4             	mov    -0xc(%ebp),%eax
 904:	8a 00                	mov    (%eax),%al
 906:	84 c0                	test   %al,%al
 908:	75 dd                	jne    8e7 <printf+0x102>
 90a:	eb 68                	jmp    974 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 90c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 910:	75 1d                	jne    92f <printf+0x14a>
        putc(fd, *ap);
 912:	8b 45 e8             	mov    -0x18(%ebp),%eax
 915:	8b 00                	mov    (%eax),%eax
 917:	0f be c0             	movsbl %al,%eax
 91a:	89 44 24 04          	mov    %eax,0x4(%esp)
 91e:	8b 45 08             	mov    0x8(%ebp),%eax
 921:	89 04 24             	mov    %eax,(%esp)
 924:	e8 df fd ff ff       	call   708 <putc>
        ap++;
 929:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 92d:	eb 45                	jmp    974 <printf+0x18f>
      } else if(c == '%'){
 92f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 933:	75 17                	jne    94c <printf+0x167>
        putc(fd, c);
 935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 938:	0f be c0             	movsbl %al,%eax
 93b:	89 44 24 04          	mov    %eax,0x4(%esp)
 93f:	8b 45 08             	mov    0x8(%ebp),%eax
 942:	89 04 24             	mov    %eax,(%esp)
 945:	e8 be fd ff ff       	call   708 <putc>
 94a:	eb 28                	jmp    974 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 94c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 953:	00 
 954:	8b 45 08             	mov    0x8(%ebp),%eax
 957:	89 04 24             	mov    %eax,(%esp)
 95a:	e8 a9 fd ff ff       	call   708 <putc>
        putc(fd, c);
 95f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 962:	0f be c0             	movsbl %al,%eax
 965:	89 44 24 04          	mov    %eax,0x4(%esp)
 969:	8b 45 08             	mov    0x8(%ebp),%eax
 96c:	89 04 24             	mov    %eax,(%esp)
 96f:	e8 94 fd ff ff       	call   708 <putc>
      }
      state = 0;
 974:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 97b:	ff 45 f0             	incl   -0x10(%ebp)
 97e:	8b 55 0c             	mov    0xc(%ebp),%edx
 981:	8b 45 f0             	mov    -0x10(%ebp),%eax
 984:	01 d0                	add    %edx,%eax
 986:	8a 00                	mov    (%eax),%al
 988:	84 c0                	test   %al,%al
 98a:	0f 85 77 fe ff ff    	jne    807 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 990:	c9                   	leave  
 991:	c3                   	ret    
 992:	90                   	nop
 993:	90                   	nop

00000994 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 994:	55                   	push   %ebp
 995:	89 e5                	mov    %esp,%ebp
 997:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 99a:	8b 45 08             	mov    0x8(%ebp),%eax
 99d:	83 e8 08             	sub    $0x8,%eax
 9a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a3:	a1 e8 0f 00 00       	mov    0xfe8,%eax
 9a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9ab:	eb 24                	jmp    9d1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b0:	8b 00                	mov    (%eax),%eax
 9b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9b5:	77 12                	ja     9c9 <free+0x35>
 9b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9bd:	77 24                	ja     9e3 <free+0x4f>
 9bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c2:	8b 00                	mov    (%eax),%eax
 9c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9c7:	77 1a                	ja     9e3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	8b 00                	mov    (%eax),%eax
 9ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9d7:	76 d4                	jbe    9ad <free+0x19>
 9d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9dc:	8b 00                	mov    (%eax),%eax
 9de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9e1:	76 ca                	jbe    9ad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 9e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e6:	8b 40 04             	mov    0x4(%eax),%eax
 9e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f3:	01 c2                	add    %eax,%edx
 9f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f8:	8b 00                	mov    (%eax),%eax
 9fa:	39 c2                	cmp    %eax,%edx
 9fc:	75 24                	jne    a22 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a01:	8b 50 04             	mov    0x4(%eax),%edx
 a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a07:	8b 00                	mov    (%eax),%eax
 a09:	8b 40 04             	mov    0x4(%eax),%eax
 a0c:	01 c2                	add    %eax,%edx
 a0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a11:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a17:	8b 00                	mov    (%eax),%eax
 a19:	8b 10                	mov    (%eax),%edx
 a1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1e:	89 10                	mov    %edx,(%eax)
 a20:	eb 0a                	jmp    a2c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a25:	8b 10                	mov    (%eax),%edx
 a27:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a2a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2f:	8b 40 04             	mov    0x4(%eax),%eax
 a32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3c:	01 d0                	add    %edx,%eax
 a3e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a41:	75 20                	jne    a63 <free+0xcf>
    p->s.size += bp->s.size;
 a43:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a46:	8b 50 04             	mov    0x4(%eax),%edx
 a49:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a4c:	8b 40 04             	mov    0x4(%eax),%eax
 a4f:	01 c2                	add    %eax,%edx
 a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a54:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a57:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5a:	8b 10                	mov    (%eax),%edx
 a5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5f:	89 10                	mov    %edx,(%eax)
 a61:	eb 08                	jmp    a6b <free+0xd7>
  } else
    p->s.ptr = bp;
 a63:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a66:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a69:	89 10                	mov    %edx,(%eax)
  freep = p;
 a6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6e:	a3 e8 0f 00 00       	mov    %eax,0xfe8
}
 a73:	c9                   	leave  
 a74:	c3                   	ret    

00000a75 <morecore>:

static Header*
morecore(uint nu)
{
 a75:	55                   	push   %ebp
 a76:	89 e5                	mov    %esp,%ebp
 a78:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a7b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a82:	77 07                	ja     a8b <morecore+0x16>
    nu = 4096;
 a84:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a8b:	8b 45 08             	mov    0x8(%ebp),%eax
 a8e:	c1 e0 03             	shl    $0x3,%eax
 a91:	89 04 24             	mov    %eax,(%esp)
 a94:	e8 4f fc ff ff       	call   6e8 <sbrk>
 a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a9c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 aa0:	75 07                	jne    aa9 <morecore+0x34>
    return 0;
 aa2:	b8 00 00 00 00       	mov    $0x0,%eax
 aa7:	eb 22                	jmp    acb <morecore+0x56>
  hp = (Header*)p;
 aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab2:	8b 55 08             	mov    0x8(%ebp),%edx
 ab5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abb:	83 c0 08             	add    $0x8,%eax
 abe:	89 04 24             	mov    %eax,(%esp)
 ac1:	e8 ce fe ff ff       	call   994 <free>
  return freep;
 ac6:	a1 e8 0f 00 00       	mov    0xfe8,%eax
}
 acb:	c9                   	leave  
 acc:	c3                   	ret    

00000acd <malloc>:

void*
malloc(uint nbytes)
{
 acd:	55                   	push   %ebp
 ace:	89 e5                	mov    %esp,%ebp
 ad0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ad3:	8b 45 08             	mov    0x8(%ebp),%eax
 ad6:	83 c0 07             	add    $0x7,%eax
 ad9:	c1 e8 03             	shr    $0x3,%eax
 adc:	40                   	inc    %eax
 add:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ae0:	a1 e8 0f 00 00       	mov    0xfe8,%eax
 ae5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ae8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aec:	75 23                	jne    b11 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 aee:	c7 45 f0 e0 0f 00 00 	movl   $0xfe0,-0x10(%ebp)
 af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af8:	a3 e8 0f 00 00       	mov    %eax,0xfe8
 afd:	a1 e8 0f 00 00       	mov    0xfe8,%eax
 b02:	a3 e0 0f 00 00       	mov    %eax,0xfe0
    base.s.size = 0;
 b07:	c7 05 e4 0f 00 00 00 	movl   $0x0,0xfe4
 b0e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b14:	8b 00                	mov    (%eax),%eax
 b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1c:	8b 40 04             	mov    0x4(%eax),%eax
 b1f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b22:	72 4d                	jb     b71 <malloc+0xa4>
      if(p->s.size == nunits)
 b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b27:	8b 40 04             	mov    0x4(%eax),%eax
 b2a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b2d:	75 0c                	jne    b3b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b32:	8b 10                	mov    (%eax),%edx
 b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b37:	89 10                	mov    %edx,(%eax)
 b39:	eb 26                	jmp    b61 <malloc+0x94>
      else {
        p->s.size -= nunits;
 b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3e:	8b 40 04             	mov    0x4(%eax),%eax
 b41:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b44:	89 c2                	mov    %eax,%edx
 b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b49:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4f:	8b 40 04             	mov    0x4(%eax),%eax
 b52:	c1 e0 03             	shl    $0x3,%eax
 b55:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b5e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b64:	a3 e8 0f 00 00       	mov    %eax,0xfe8
      return (void*)(p + 1);
 b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6c:	83 c0 08             	add    $0x8,%eax
 b6f:	eb 38                	jmp    ba9 <malloc+0xdc>
    }
    if(p == freep)
 b71:	a1 e8 0f 00 00       	mov    0xfe8,%eax
 b76:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b79:	75 1b                	jne    b96 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b7e:	89 04 24             	mov    %eax,(%esp)
 b81:	e8 ef fe ff ff       	call   a75 <morecore>
 b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b8d:	75 07                	jne    b96 <malloc+0xc9>
        return 0;
 b8f:	b8 00 00 00 00       	mov    $0x0,%eax
 b94:	eb 13                	jmp    ba9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9f:	8b 00                	mov    (%eax),%eax
 ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ba4:	e9 70 ff ff ff       	jmp    b19 <malloc+0x4c>
}
 ba9:	c9                   	leave  
 baa:	c3                   	ret    
