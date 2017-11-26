
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

00000046 <create>:

void create(char *c_args[]){
  46:	55                   	push   %ebp
  47:	89 e5                	mov    %esp,%ebp
  49:	53                   	push   %ebx
  4a:	83 ec 44             	sub    $0x44,%esp
	//struct container create;
	//create->name = c_args[0];
	//create->max_mem = atoi(c_args[1]);
	//create->max_proc = atoi(c_args2[2]);
	//create->max_disk = atoi(c_args2[3]);
	mkdir(c_args[0]);
  4d:	8b 45 08             	mov    0x8(%ebp),%eax
  50:	8b 00                	mov    (%eax),%eax
  52:	89 04 24             	mov    %eax,(%esp)
  55:	e8 76 05 00 00       	call   5d0 <mkdir>
	//chdir(create->name);

	
	int x = 0;
  5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c_args[x] != 0){
  61:	eb 03                	jmp    66 <create+0x20>
			x++;
  63:	ff 45 f4             	incl   -0xc(%ebp)
	mkdir(c_args[0]);
	//chdir(create->name);

	
	int x = 0;
	while(c_args[x] != 0){
  66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  70:	8b 45 08             	mov    0x8(%ebp),%eax
  73:	01 d0                	add    %edx,%eax
  75:	8b 00                	mov    (%eax),%eax
  77:	85 c0                	test   %eax,%eax
  79:	75 e8                	jne    63 <create+0x1d>
			x++;
	}

	printf(1, "%d\n", x);
  7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  82:	c7 44 24 04 b4 0a 00 	movl   $0xab4,0x4(%esp)
  89:	00 
  8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  91:	e8 57 06 00 00       	call   6ed <printf>
	int i;
	for(i = 1; i <= x; i++){
  96:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  9d:	e9 23 01 00 00       	jmp    1c5 <create+0x17f>
		printf(1, "here muthafuckaahhh\n");
  a2:	c7 44 24 04 b8 0a 00 	movl   $0xab8,0x4(%esp)
  a9:	00 
  aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b1:	e8 37 06 00 00       	call   6ed <printf>
		char* location = strcat(strcat(c_args[0], "/"), c_args[i]);
  b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  c0:	8b 45 08             	mov    0x8(%ebp),%eax
  c3:	01 d0                	add    %edx,%eax
  c5:	8b 18                	mov    (%eax),%ebx
  c7:	8b 45 08             	mov    0x8(%ebp),%eax
  ca:	8b 00                	mov    (%eax),%eax
  cc:	c7 44 24 04 cd 0a 00 	movl   $0xacd,0x4(%esp)
  d3:	00 
  d4:	89 04 24             	mov    %eax,(%esp)
  d7:	e8 24 ff ff ff       	call   0 <strcat>
  dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  e0:	89 04 24             	mov    %eax,(%esp)
  e3:	e8 18 ff ff ff       	call   0 <strcat>
  e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
		printf(1, "here muthafuckaahhh2\n");
  eb:	c7 44 24 04 cf 0a 00 	movl   $0xacf,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 ee 05 00 00       	call   6ed <printf>
		int id = fork();
  ff:	e8 5c 04 00 00       	call   560 <fork>
 104:	89 45 e8             	mov    %eax,-0x18(%ebp)
		printf(1, "here muthafuckaahhh3\n");
 107:	c7 44 24 04 e5 0a 00 	movl   $0xae5,0x4(%esp)
 10e:	00 
 10f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 116:	e8 d2 05 00 00       	call   6ed <printf>

		if(id == 0){
 11b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 11f:	0f 85 98 00 00 00    	jne    1bd <create+0x177>
			char *arr[] = {"cat", "<", c_args[i], ">", location,0};
 125:	c7 45 d0 fb 0a 00 00 	movl   $0xafb,-0x30(%ebp)
 12c:	c7 45 d4 ff 0a 00 00 	movl   $0xaff,-0x2c(%ebp)
 133:	8b 45 f0             	mov    -0x10(%ebp),%eax
 136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 13d:	8b 45 08             	mov    0x8(%ebp),%eax
 140:	01 d0                	add    %edx,%eax
 142:	8b 00                	mov    (%eax),%eax
 144:	89 45 d8             	mov    %eax,-0x28(%ebp)
 147:	c7 45 dc 01 0b 00 00 	movl   $0xb01,-0x24(%ebp)
 14e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 151:	89 45 e0             	mov    %eax,-0x20(%ebp)
 154:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			printf(1, "%s\n", arr[1]);
 15b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 15e:	89 44 24 08          	mov    %eax,0x8(%esp)
 162:	c7 44 24 04 03 0b 00 	movl   $0xb03,0x4(%esp)
 169:	00 
 16a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 171:	e8 77 05 00 00       	call   6ed <printf>
			printf(1, "%s\n", arr[2]);
 176:	8b 45 d8             	mov    -0x28(%ebp),%eax
 179:	89 44 24 08          	mov    %eax,0x8(%esp)
 17d:	c7 44 24 04 03 0b 00 	movl   $0xb03,0x4(%esp)
 184:	00 
 185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18c:	e8 5c 05 00 00       	call   6ed <printf>
			exec("cat", arr);
 191:	8d 45 d0             	lea    -0x30(%ebp),%eax
 194:	89 44 24 04          	mov    %eax,0x4(%esp)
 198:	c7 04 24 fb 0a 00 00 	movl   $0xafb,(%esp)
 19f:	e8 fc 03 00 00       	call   5a0 <exec>
			printf(1, "Failure to Execute.");
 1a4:	c7 44 24 04 07 0b 00 	movl   $0xb07,0x4(%esp)
 1ab:	00 
 1ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b3:	e8 35 05 00 00       	call   6ed <printf>
			exit();
 1b8:	e8 ab 03 00 00       	call   568 <exit>
		}
		wait();
 1bd:	e8 ae 03 00 00       	call   570 <wait>
			x++;
	}

	printf(1, "%d\n", x);
	int i;
	for(i = 1; i <= x; i++){
 1c2:	ff 45 f0             	incl   -0x10(%ebp)
 1c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1c8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 1cb:	0f 8e d1 fe ff ff    	jle    a2 <create+0x5c>
			printf(1, "Failure to Execute.");
			exit();
		}
		wait();
	}
}
 1d1:	83 c4 44             	add    $0x44,%esp
 1d4:	5b                   	pop    %ebx
 1d5:	5d                   	pop    %ebp
 1d6:	c3                   	ret    

000001d7 <attach_vc>:

void attach_vc(char* vc, char* dir, char* file){
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
 1da:	83 ec 28             	sub    $0x28,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
 1dd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 1e4:	00 
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	89 04 24             	mov    %eax,(%esp)
 1eb:	e8 b8 03 00 00       	call   5a8 <open>
 1f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 1f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f6:	89 04 24             	mov    %eax,(%esp)
 1f9:	e8 da 03 00 00       	call   5d8 <chdir>

	/* fork a child and exec argv[1] */
	id = fork();
 1fe:	e8 5d 03 00 00       	call   560 <fork>
 203:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 206:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20a:	75 70                	jne    27c <attach_vc+0xa5>
		close(0);
 20c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 213:	e8 78 03 00 00       	call   590 <close>
		close(1);
 218:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 21f:	e8 6c 03 00 00       	call   590 <close>
		close(2);
 224:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 22b:	e8 60 03 00 00       	call   590 <close>
		dup(fd);
 230:	8b 45 f4             	mov    -0xc(%ebp),%eax
 233:	89 04 24             	mov    %eax,(%esp)
 236:	e8 a5 03 00 00       	call   5e0 <dup>
		dup(fd);
 23b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23e:	89 04 24             	mov    %eax,(%esp)
 241:	e8 9a 03 00 00       	call   5e0 <dup>
		dup(fd);
 246:	8b 45 f4             	mov    -0xc(%ebp),%eax
 249:	89 04 24             	mov    %eax,(%esp)
 24c:	e8 8f 03 00 00       	call   5e0 <dup>
		exec(file, &file);
 251:	8b 45 10             	mov    0x10(%ebp),%eax
 254:	8d 55 10             	lea    0x10(%ebp),%edx
 257:	89 54 24 04          	mov    %edx,0x4(%esp)
 25b:	89 04 24             	mov    %eax,(%esp)
 25e:	e8 3d 03 00 00       	call   5a0 <exec>
		printf(1, "Failure to attach VC.");
 263:	c7 44 24 04 1b 0b 00 	movl   $0xb1b,0x4(%esp)
 26a:	00 
 26b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 272:	e8 76 04 00 00       	call   6ed <printf>
		exit();
 277:	e8 ec 02 00 00       	call   568 <exit>
	}
}
 27c:	c9                   	leave  
 27d:	c3                   	ret    

0000027e <start>:

void start(char *s_args[]){
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 281:	5d                   	pop    %ebp
 282:	c3                   	ret    

00000283 <pause>:

void pause(char *c_name){
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp

}
 286:	5d                   	pop    %ebp
 287:	c3                   	ret    

00000288 <resume>:

void resume(char *c_name){
 288:	55                   	push   %ebp
 289:	89 e5                	mov    %esp,%ebp

}
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    

0000028d <stop>:

void stop(char *c_name){
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp

}
 290:	5d                   	pop    %ebp
 291:	c3                   	ret    

00000292 <info>:

void info(char *c_name){
 292:	55                   	push   %ebp
 293:	89 e5                	mov    %esp,%ebp

}
 295:	5d                   	pop    %ebp
 296:	c3                   	ret    

00000297 <main>:

int main(int argc, char *argv[]){
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 e4 f0             	and    $0xfffffff0,%esp
 29d:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create") == 0){
 2a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a3:	83 c0 04             	add    $0x4,%eax
 2a6:	8b 00                	mov    (%eax),%eax
 2a8:	c7 44 24 04 31 0b 00 	movl   $0xb31,0x4(%esp)
 2af:	00 
 2b0:	89 04 24             	mov    %eax,(%esp)
 2b3:	e8 af 00 00 00       	call   367 <strcmp>
 2b8:	85 c0                	test   %eax,%eax
 2ba:	75 10                	jne    2cc <main+0x35>
		create(&argv[2]);
 2bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bf:	83 c0 08             	add    $0x8,%eax
 2c2:	89 04 24             	mov    %eax,(%esp)
 2c5:	e8 7c fd ff ff       	call   46 <create>
 2ca:	eb 40                	jmp    30c <main+0x75>
	}
	else if(strcmp(argv[1], "start") == 0){
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	83 c0 04             	add    $0x4,%eax
 2d2:	8b 00                	mov    (%eax),%eax
 2d4:	c7 44 24 04 38 0b 00 	movl   $0xb38,0x4(%esp)
 2db:	00 
 2dc:	89 04 24             	mov    %eax,(%esp)
 2df:	e8 83 00 00 00       	call   367 <strcmp>
 2e4:	85 c0                	test   %eax,%eax
 2e6:	75 10                	jne    2f8 <main+0x61>
		start(&argv[2]);
 2e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2eb:	83 c0 08             	add    $0x8,%eax
 2ee:	89 04 24             	mov    %eax,(%esp)
 2f1:	e8 88 ff ff ff       	call   27e <start>
 2f6:	eb 14                	jmp    30c <main+0x75>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info");
 2f8:	c7 44 24 04 40 0b 00 	movl   $0xb40,0x4(%esp)
 2ff:	00 
 300:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 307:	e8 e1 03 00 00       	call   6ed <printf>
	}
	return 0;
 30c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 311:	c9                   	leave  
 312:	c3                   	ret    
 313:	90                   	nop

00000314 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 314:	55                   	push   %ebp
 315:	89 e5                	mov    %esp,%ebp
 317:	57                   	push   %edi
 318:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 319:	8b 4d 08             	mov    0x8(%ebp),%ecx
 31c:	8b 55 10             	mov    0x10(%ebp),%edx
 31f:	8b 45 0c             	mov    0xc(%ebp),%eax
 322:	89 cb                	mov    %ecx,%ebx
 324:	89 df                	mov    %ebx,%edi
 326:	89 d1                	mov    %edx,%ecx
 328:	fc                   	cld    
 329:	f3 aa                	rep stos %al,%es:(%edi)
 32b:	89 ca                	mov    %ecx,%edx
 32d:	89 fb                	mov    %edi,%ebx
 32f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 332:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 335:	5b                   	pop    %ebx
 336:	5f                   	pop    %edi
 337:	5d                   	pop    %ebp
 338:	c3                   	ret    

00000339 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
 33c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 345:	90                   	nop
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 08             	mov    %edx,0x8(%ebp)
 34f:	8b 55 0c             	mov    0xc(%ebp),%edx
 352:	8d 4a 01             	lea    0x1(%edx),%ecx
 355:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 358:	8a 12                	mov    (%edx),%dl
 35a:	88 10                	mov    %dl,(%eax)
 35c:	8a 00                	mov    (%eax),%al
 35e:	84 c0                	test   %al,%al
 360:	75 e4                	jne    346 <strcpy+0xd>
    ;
  return os;
 362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 365:	c9                   	leave  
 366:	c3                   	ret    

00000367 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 36a:	eb 06                	jmp    372 <strcmp+0xb>
    p++, q++;
 36c:	ff 45 08             	incl   0x8(%ebp)
 36f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	8a 00                	mov    (%eax),%al
 377:	84 c0                	test   %al,%al
 379:	74 0e                	je     389 <strcmp+0x22>
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	8a 10                	mov    (%eax),%dl
 380:	8b 45 0c             	mov    0xc(%ebp),%eax
 383:	8a 00                	mov    (%eax),%al
 385:	38 c2                	cmp    %al,%dl
 387:	74 e3                	je     36c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 389:	8b 45 08             	mov    0x8(%ebp),%eax
 38c:	8a 00                	mov    (%eax),%al
 38e:	0f b6 d0             	movzbl %al,%edx
 391:	8b 45 0c             	mov    0xc(%ebp),%eax
 394:	8a 00                	mov    (%eax),%al
 396:	0f b6 c0             	movzbl %al,%eax
 399:	29 c2                	sub    %eax,%edx
 39b:	89 d0                	mov    %edx,%eax
}
 39d:	5d                   	pop    %ebp
 39e:	c3                   	ret    

0000039f <strlen>:

uint
strlen(char *s)
{
 39f:	55                   	push   %ebp
 3a0:	89 e5                	mov    %esp,%ebp
 3a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ac:	eb 03                	jmp    3b1 <strlen+0x12>
 3ae:	ff 45 fc             	incl   -0x4(%ebp)
 3b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	01 d0                	add    %edx,%eax
 3b9:	8a 00                	mov    (%eax),%al
 3bb:	84 c0                	test   %al,%al
 3bd:	75 ef                	jne    3ae <strlen+0xf>
    ;
  return n;
 3bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c2:	c9                   	leave  
 3c3:	c3                   	ret    

000003c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3c4:	55                   	push   %ebp
 3c5:	89 e5                	mov    %esp,%ebp
 3c7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3ca:	8b 45 10             	mov    0x10(%ebp),%eax
 3cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	89 04 24             	mov    %eax,(%esp)
 3de:	e8 31 ff ff ff       	call   314 <stosb>
  return dst;
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e6:	c9                   	leave  
 3e7:	c3                   	ret    

000003e8 <strchr>:

char*
strchr(const char *s, char c)
{
 3e8:	55                   	push   %ebp
 3e9:	89 e5                	mov    %esp,%ebp
 3eb:	83 ec 04             	sub    $0x4,%esp
 3ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3f4:	eb 12                	jmp    408 <strchr+0x20>
    if(*s == c)
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	8a 00                	mov    (%eax),%al
 3fb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3fe:	75 05                	jne    405 <strchr+0x1d>
      return (char*)s;
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	eb 11                	jmp    416 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 405:	ff 45 08             	incl   0x8(%ebp)
 408:	8b 45 08             	mov    0x8(%ebp),%eax
 40b:	8a 00                	mov    (%eax),%al
 40d:	84 c0                	test   %al,%al
 40f:	75 e5                	jne    3f6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 411:	b8 00 00 00 00       	mov    $0x0,%eax
}
 416:	c9                   	leave  
 417:	c3                   	ret    

00000418 <gets>:

char*
gets(char *buf, int max)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 425:	eb 49                	jmp    470 <gets+0x58>
    cc = read(0, &c, 1);
 427:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 42e:	00 
 42f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 432:	89 44 24 04          	mov    %eax,0x4(%esp)
 436:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 43d:	e8 3e 01 00 00       	call   580 <read>
 442:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 445:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 449:	7f 02                	jg     44d <gets+0x35>
      break;
 44b:	eb 2c                	jmp    479 <gets+0x61>
    buf[i++] = c;
 44d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 450:	8d 50 01             	lea    0x1(%eax),%edx
 453:	89 55 f4             	mov    %edx,-0xc(%ebp)
 456:	89 c2                	mov    %eax,%edx
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	01 c2                	add    %eax,%edx
 45d:	8a 45 ef             	mov    -0x11(%ebp),%al
 460:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 462:	8a 45 ef             	mov    -0x11(%ebp),%al
 465:	3c 0a                	cmp    $0xa,%al
 467:	74 10                	je     479 <gets+0x61>
 469:	8a 45 ef             	mov    -0x11(%ebp),%al
 46c:	3c 0d                	cmp    $0xd,%al
 46e:	74 09                	je     479 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 470:	8b 45 f4             	mov    -0xc(%ebp),%eax
 473:	40                   	inc    %eax
 474:	3b 45 0c             	cmp    0xc(%ebp),%eax
 477:	7c ae                	jl     427 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 479:	8b 55 f4             	mov    -0xc(%ebp),%edx
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
 47f:	01 d0                	add    %edx,%eax
 481:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 484:	8b 45 08             	mov    0x8(%ebp),%eax
}
 487:	c9                   	leave  
 488:	c3                   	ret    

00000489 <stat>:

int
stat(char *n, struct stat *st)
{
 489:	55                   	push   %ebp
 48a:	89 e5                	mov    %esp,%ebp
 48c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 48f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 496:	00 
 497:	8b 45 08             	mov    0x8(%ebp),%eax
 49a:	89 04 24             	mov    %eax,(%esp)
 49d:	e8 06 01 00 00       	call   5a8 <open>
 4a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a9:	79 07                	jns    4b2 <stat+0x29>
    return -1;
 4ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4b0:	eb 23                	jmp    4d5 <stat+0x4c>
  r = fstat(fd, st);
 4b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bc:	89 04 24             	mov    %eax,(%esp)
 4bf:	e8 fc 00 00 00       	call   5c0 <fstat>
 4c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ca:	89 04 24             	mov    %eax,(%esp)
 4cd:	e8 be 00 00 00       	call   590 <close>
  return r;
 4d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4d5:	c9                   	leave  
 4d6:	c3                   	ret    

000004d7 <atoi>:

int
atoi(const char *s)
{
 4d7:	55                   	push   %ebp
 4d8:	89 e5                	mov    %esp,%ebp
 4da:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e4:	eb 24                	jmp    50a <atoi+0x33>
    n = n*10 + *s++ - '0';
 4e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e9:	89 d0                	mov    %edx,%eax
 4eb:	c1 e0 02             	shl    $0x2,%eax
 4ee:	01 d0                	add    %edx,%eax
 4f0:	01 c0                	add    %eax,%eax
 4f2:	89 c1                	mov    %eax,%ecx
 4f4:	8b 45 08             	mov    0x8(%ebp),%eax
 4f7:	8d 50 01             	lea    0x1(%eax),%edx
 4fa:	89 55 08             	mov    %edx,0x8(%ebp)
 4fd:	8a 00                	mov    (%eax),%al
 4ff:	0f be c0             	movsbl %al,%eax
 502:	01 c8                	add    %ecx,%eax
 504:	83 e8 30             	sub    $0x30,%eax
 507:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 50a:	8b 45 08             	mov    0x8(%ebp),%eax
 50d:	8a 00                	mov    (%eax),%al
 50f:	3c 2f                	cmp    $0x2f,%al
 511:	7e 09                	jle    51c <atoi+0x45>
 513:	8b 45 08             	mov    0x8(%ebp),%eax
 516:	8a 00                	mov    (%eax),%al
 518:	3c 39                	cmp    $0x39,%al
 51a:	7e ca                	jle    4e6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 51c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51f:	c9                   	leave  
 520:	c3                   	ret    

00000521 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 521:	55                   	push   %ebp
 522:	89 e5                	mov    %esp,%ebp
 524:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 52d:	8b 45 0c             	mov    0xc(%ebp),%eax
 530:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 533:	eb 16                	jmp    54b <memmove+0x2a>
    *dst++ = *src++;
 535:	8b 45 fc             	mov    -0x4(%ebp),%eax
 538:	8d 50 01             	lea    0x1(%eax),%edx
 53b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 53e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 541:	8d 4a 01             	lea    0x1(%edx),%ecx
 544:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 547:	8a 12                	mov    (%edx),%dl
 549:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 54b:	8b 45 10             	mov    0x10(%ebp),%eax
 54e:	8d 50 ff             	lea    -0x1(%eax),%edx
 551:	89 55 10             	mov    %edx,0x10(%ebp)
 554:	85 c0                	test   %eax,%eax
 556:	7f dd                	jg     535 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 558:	8b 45 08             	mov    0x8(%ebp),%eax
}
 55b:	c9                   	leave  
 55c:	c3                   	ret    
 55d:	90                   	nop
 55e:	90                   	nop
 55f:	90                   	nop

00000560 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 560:	b8 01 00 00 00       	mov    $0x1,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <exit>:
SYSCALL(exit)
 568:	b8 02 00 00 00       	mov    $0x2,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <wait>:
SYSCALL(wait)
 570:	b8 03 00 00 00       	mov    $0x3,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <pipe>:
SYSCALL(pipe)
 578:	b8 04 00 00 00       	mov    $0x4,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <read>:
SYSCALL(read)
 580:	b8 05 00 00 00       	mov    $0x5,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <write>:
SYSCALL(write)
 588:	b8 10 00 00 00       	mov    $0x10,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <close>:
SYSCALL(close)
 590:	b8 15 00 00 00       	mov    $0x15,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <kill>:
SYSCALL(kill)
 598:	b8 06 00 00 00       	mov    $0x6,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <exec>:
SYSCALL(exec)
 5a0:	b8 07 00 00 00       	mov    $0x7,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <open>:
SYSCALL(open)
 5a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <mknod>:
SYSCALL(mknod)
 5b0:	b8 11 00 00 00       	mov    $0x11,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <unlink>:
SYSCALL(unlink)
 5b8:	b8 12 00 00 00       	mov    $0x12,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <fstat>:
SYSCALL(fstat)
 5c0:	b8 08 00 00 00       	mov    $0x8,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <link>:
SYSCALL(link)
 5c8:	b8 13 00 00 00       	mov    $0x13,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <mkdir>:
SYSCALL(mkdir)
 5d0:	b8 14 00 00 00       	mov    $0x14,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <chdir>:
SYSCALL(chdir)
 5d8:	b8 09 00 00 00       	mov    $0x9,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <dup>:
SYSCALL(dup)
 5e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <getpid>:
SYSCALL(getpid)
 5e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <sbrk>:
SYSCALL(sbrk)
 5f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <sleep>:
SYSCALL(sleep)
 5f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <uptime>:
SYSCALL(uptime)
 600:	b8 0e 00 00 00       	mov    $0xe,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <getticks>:
 608:	b8 16 00 00 00       	mov    $0x16,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	83 ec 18             	sub    $0x18,%esp
 616:	8b 45 0c             	mov    0xc(%ebp),%eax
 619:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 61c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 623:	00 
 624:	8d 45 f4             	lea    -0xc(%ebp),%eax
 627:	89 44 24 04          	mov    %eax,0x4(%esp)
 62b:	8b 45 08             	mov    0x8(%ebp),%eax
 62e:	89 04 24             	mov    %eax,(%esp)
 631:	e8 52 ff ff ff       	call   588 <write>
}
 636:	c9                   	leave  
 637:	c3                   	ret    

00000638 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 638:	55                   	push   %ebp
 639:	89 e5                	mov    %esp,%ebp
 63b:	56                   	push   %esi
 63c:	53                   	push   %ebx
 63d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 640:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 647:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 64b:	74 17                	je     664 <printint+0x2c>
 64d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 651:	79 11                	jns    664 <printint+0x2c>
    neg = 1;
 653:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 65a:	8b 45 0c             	mov    0xc(%ebp),%eax
 65d:	f7 d8                	neg    %eax
 65f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 662:	eb 06                	jmp    66a <printint+0x32>
  } else {
    x = xx;
 664:	8b 45 0c             	mov    0xc(%ebp),%eax
 667:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 66a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 671:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 674:	8d 41 01             	lea    0x1(%ecx),%eax
 677:	89 45 f4             	mov    %eax,-0xc(%ebp)
 67a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 67d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 680:	ba 00 00 00 00       	mov    $0x0,%edx
 685:	f7 f3                	div    %ebx
 687:	89 d0                	mov    %edx,%eax
 689:	8a 80 d0 0e 00 00    	mov    0xed0(%eax),%al
 68f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 693:	8b 75 10             	mov    0x10(%ebp),%esi
 696:	8b 45 ec             	mov    -0x14(%ebp),%eax
 699:	ba 00 00 00 00       	mov    $0x0,%edx
 69e:	f7 f6                	div    %esi
 6a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a7:	75 c8                	jne    671 <printint+0x39>
  if(neg)
 6a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6ad:	74 10                	je     6bf <printint+0x87>
    buf[i++] = '-';
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	8d 50 01             	lea    0x1(%eax),%edx
 6b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6bd:	eb 1e                	jmp    6dd <printint+0xa5>
 6bf:	eb 1c                	jmp    6dd <printint+0xa5>
    putc(fd, buf[i]);
 6c1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c7:	01 d0                	add    %edx,%eax
 6c9:	8a 00                	mov    (%eax),%al
 6cb:	0f be c0             	movsbl %al,%eax
 6ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d2:	8b 45 08             	mov    0x8(%ebp),%eax
 6d5:	89 04 24             	mov    %eax,(%esp)
 6d8:	e8 33 ff ff ff       	call   610 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6dd:	ff 4d f4             	decl   -0xc(%ebp)
 6e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e4:	79 db                	jns    6c1 <printint+0x89>
    putc(fd, buf[i]);
}
 6e6:	83 c4 30             	add    $0x30,%esp
 6e9:	5b                   	pop    %ebx
 6ea:	5e                   	pop    %esi
 6eb:	5d                   	pop    %ebp
 6ec:	c3                   	ret    

000006ed <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6ed:	55                   	push   %ebp
 6ee:	89 e5                	mov    %esp,%ebp
 6f0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6fa:	8d 45 0c             	lea    0xc(%ebp),%eax
 6fd:	83 c0 04             	add    $0x4,%eax
 700:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 703:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 70a:	e9 77 01 00 00       	jmp    886 <printf+0x199>
    c = fmt[i] & 0xff;
 70f:	8b 55 0c             	mov    0xc(%ebp),%edx
 712:	8b 45 f0             	mov    -0x10(%ebp),%eax
 715:	01 d0                	add    %edx,%eax
 717:	8a 00                	mov    (%eax),%al
 719:	0f be c0             	movsbl %al,%eax
 71c:	25 ff 00 00 00       	and    $0xff,%eax
 721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 724:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 728:	75 2c                	jne    756 <printf+0x69>
      if(c == '%'){
 72a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 72e:	75 0c                	jne    73c <printf+0x4f>
        state = '%';
 730:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 737:	e9 47 01 00 00       	jmp    883 <printf+0x196>
      } else {
        putc(fd, c);
 73c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73f:	0f be c0             	movsbl %al,%eax
 742:	89 44 24 04          	mov    %eax,0x4(%esp)
 746:	8b 45 08             	mov    0x8(%ebp),%eax
 749:	89 04 24             	mov    %eax,(%esp)
 74c:	e8 bf fe ff ff       	call   610 <putc>
 751:	e9 2d 01 00 00       	jmp    883 <printf+0x196>
      }
    } else if(state == '%'){
 756:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 75a:	0f 85 23 01 00 00    	jne    883 <printf+0x196>
      if(c == 'd'){
 760:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 764:	75 2d                	jne    793 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 766:	8b 45 e8             	mov    -0x18(%ebp),%eax
 769:	8b 00                	mov    (%eax),%eax
 76b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 772:	00 
 773:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 77a:	00 
 77b:	89 44 24 04          	mov    %eax,0x4(%esp)
 77f:	8b 45 08             	mov    0x8(%ebp),%eax
 782:	89 04 24             	mov    %eax,(%esp)
 785:	e8 ae fe ff ff       	call   638 <printint>
        ap++;
 78a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78e:	e9 e9 00 00 00       	jmp    87c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 793:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 797:	74 06                	je     79f <printf+0xb2>
 799:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 79d:	75 2d                	jne    7cc <printf+0xdf>
        printint(fd, *ap, 16, 0);
 79f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a2:	8b 00                	mov    (%eax),%eax
 7a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7ab:	00 
 7ac:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7b3:	00 
 7b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b8:	8b 45 08             	mov    0x8(%ebp),%eax
 7bb:	89 04 24             	mov    %eax,(%esp)
 7be:	e8 75 fe ff ff       	call   638 <printint>
        ap++;
 7c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c7:	e9 b0 00 00 00       	jmp    87c <printf+0x18f>
      } else if(c == 's'){
 7cc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7d0:	75 42                	jne    814 <printf+0x127>
        s = (char*)*ap;
 7d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d5:	8b 00                	mov    (%eax),%eax
 7d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e2:	75 09                	jne    7ed <printf+0x100>
          s = "(null)";
 7e4:	c7 45 f4 79 0b 00 00 	movl   $0xb79,-0xc(%ebp)
        while(*s != 0){
 7eb:	eb 1c                	jmp    809 <printf+0x11c>
 7ed:	eb 1a                	jmp    809 <printf+0x11c>
          putc(fd, *s);
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	8a 00                	mov    (%eax),%al
 7f4:	0f be c0             	movsbl %al,%eax
 7f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 7fb:	8b 45 08             	mov    0x8(%ebp),%eax
 7fe:	89 04 24             	mov    %eax,(%esp)
 801:	e8 0a fe ff ff       	call   610 <putc>
          s++;
 806:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	8a 00                	mov    (%eax),%al
 80e:	84 c0                	test   %al,%al
 810:	75 dd                	jne    7ef <printf+0x102>
 812:	eb 68                	jmp    87c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 814:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 818:	75 1d                	jne    837 <printf+0x14a>
        putc(fd, *ap);
 81a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81d:	8b 00                	mov    (%eax),%eax
 81f:	0f be c0             	movsbl %al,%eax
 822:	89 44 24 04          	mov    %eax,0x4(%esp)
 826:	8b 45 08             	mov    0x8(%ebp),%eax
 829:	89 04 24             	mov    %eax,(%esp)
 82c:	e8 df fd ff ff       	call   610 <putc>
        ap++;
 831:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 835:	eb 45                	jmp    87c <printf+0x18f>
      } else if(c == '%'){
 837:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 83b:	75 17                	jne    854 <printf+0x167>
        putc(fd, c);
 83d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 840:	0f be c0             	movsbl %al,%eax
 843:	89 44 24 04          	mov    %eax,0x4(%esp)
 847:	8b 45 08             	mov    0x8(%ebp),%eax
 84a:	89 04 24             	mov    %eax,(%esp)
 84d:	e8 be fd ff ff       	call   610 <putc>
 852:	eb 28                	jmp    87c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 854:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 85b:	00 
 85c:	8b 45 08             	mov    0x8(%ebp),%eax
 85f:	89 04 24             	mov    %eax,(%esp)
 862:	e8 a9 fd ff ff       	call   610 <putc>
        putc(fd, c);
 867:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 86a:	0f be c0             	movsbl %al,%eax
 86d:	89 44 24 04          	mov    %eax,0x4(%esp)
 871:	8b 45 08             	mov    0x8(%ebp),%eax
 874:	89 04 24             	mov    %eax,(%esp)
 877:	e8 94 fd ff ff       	call   610 <putc>
      }
      state = 0;
 87c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 883:	ff 45 f0             	incl   -0x10(%ebp)
 886:	8b 55 0c             	mov    0xc(%ebp),%edx
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	01 d0                	add    %edx,%eax
 88e:	8a 00                	mov    (%eax),%al
 890:	84 c0                	test   %al,%al
 892:	0f 85 77 fe ff ff    	jne    70f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 898:	c9                   	leave  
 899:	c3                   	ret    
 89a:	90                   	nop
 89b:	90                   	nop

0000089c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89c:	55                   	push   %ebp
 89d:	89 e5                	mov    %esp,%ebp
 89f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a2:	8b 45 08             	mov    0x8(%ebp),%eax
 8a5:	83 e8 08             	sub    $0x8,%eax
 8a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ab:	a1 ec 0e 00 00       	mov    0xeec,%eax
 8b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b3:	eb 24                	jmp    8d9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b8:	8b 00                	mov    (%eax),%eax
 8ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8bd:	77 12                	ja     8d1 <free+0x35>
 8bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c5:	77 24                	ja     8eb <free+0x4f>
 8c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ca:	8b 00                	mov    (%eax),%eax
 8cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8cf:	77 1a                	ja     8eb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8df:	76 d4                	jbe    8b5 <free+0x19>
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e9:	76 ca                	jbe    8b5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fb:	01 c2                	add    %eax,%edx
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	39 c2                	cmp    %eax,%edx
 904:	75 24                	jne    92a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	8b 50 04             	mov    0x4(%eax),%edx
 90c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90f:	8b 00                	mov    (%eax),%eax
 911:	8b 40 04             	mov    0x4(%eax),%eax
 914:	01 c2                	add    %eax,%edx
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91f:	8b 00                	mov    (%eax),%eax
 921:	8b 10                	mov    (%eax),%edx
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	89 10                	mov    %edx,(%eax)
 928:	eb 0a                	jmp    934 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 92a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92d:	8b 10                	mov    (%eax),%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	01 d0                	add    %edx,%eax
 946:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 949:	75 20                	jne    96b <free+0xcf>
    p->s.size += bp->s.size;
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 50 04             	mov    0x4(%eax),%edx
 951:	8b 45 f8             	mov    -0x8(%ebp),%eax
 954:	8b 40 04             	mov    0x4(%eax),%eax
 957:	01 c2                	add    %eax,%edx
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 95f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 962:	8b 10                	mov    (%eax),%edx
 964:	8b 45 fc             	mov    -0x4(%ebp),%eax
 967:	89 10                	mov    %edx,(%eax)
 969:	eb 08                	jmp    973 <free+0xd7>
  } else
    p->s.ptr = bp;
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 971:	89 10                	mov    %edx,(%eax)
  freep = p;
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	a3 ec 0e 00 00       	mov    %eax,0xeec
}
 97b:	c9                   	leave  
 97c:	c3                   	ret    

0000097d <morecore>:

static Header*
morecore(uint nu)
{
 97d:	55                   	push   %ebp
 97e:	89 e5                	mov    %esp,%ebp
 980:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 983:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 98a:	77 07                	ja     993 <morecore+0x16>
    nu = 4096;
 98c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 993:	8b 45 08             	mov    0x8(%ebp),%eax
 996:	c1 e0 03             	shl    $0x3,%eax
 999:	89 04 24             	mov    %eax,(%esp)
 99c:	e8 4f fc ff ff       	call   5f0 <sbrk>
 9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9a8:	75 07                	jne    9b1 <morecore+0x34>
    return 0;
 9aa:	b8 00 00 00 00       	mov    $0x0,%eax
 9af:	eb 22                	jmp    9d3 <morecore+0x56>
  hp = (Header*)p;
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ba:	8b 55 08             	mov    0x8(%ebp),%edx
 9bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c3:	83 c0 08             	add    $0x8,%eax
 9c6:	89 04 24             	mov    %eax,(%esp)
 9c9:	e8 ce fe ff ff       	call   89c <free>
  return freep;
 9ce:	a1 ec 0e 00 00       	mov    0xeec,%eax
}
 9d3:	c9                   	leave  
 9d4:	c3                   	ret    

000009d5 <malloc>:

void*
malloc(uint nbytes)
{
 9d5:	55                   	push   %ebp
 9d6:	89 e5                	mov    %esp,%ebp
 9d8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9db:	8b 45 08             	mov    0x8(%ebp),%eax
 9de:	83 c0 07             	add    $0x7,%eax
 9e1:	c1 e8 03             	shr    $0x3,%eax
 9e4:	40                   	inc    %eax
 9e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9e8:	a1 ec 0e 00 00       	mov    0xeec,%eax
 9ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9f4:	75 23                	jne    a19 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 9f6:	c7 45 f0 e4 0e 00 00 	movl   $0xee4,-0x10(%ebp)
 9fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a00:	a3 ec 0e 00 00       	mov    %eax,0xeec
 a05:	a1 ec 0e 00 00       	mov    0xeec,%eax
 a0a:	a3 e4 0e 00 00       	mov    %eax,0xee4
    base.s.size = 0;
 a0f:	c7 05 e8 0e 00 00 00 	movl   $0x0,0xee8
 a16:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1c:	8b 00                	mov    (%eax),%eax
 a1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a24:	8b 40 04             	mov    0x4(%eax),%eax
 a27:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a2a:	72 4d                	jb     a79 <malloc+0xa4>
      if(p->s.size == nunits)
 a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2f:	8b 40 04             	mov    0x4(%eax),%eax
 a32:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a35:	75 0c                	jne    a43 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3a:	8b 10                	mov    (%eax),%edx
 a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3f:	89 10                	mov    %edx,(%eax)
 a41:	eb 26                	jmp    a69 <malloc+0x94>
      else {
        p->s.size -= nunits;
 a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a46:	8b 40 04             	mov    0x4(%eax),%eax
 a49:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a4c:	89 c2                	mov    %eax,%edx
 a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a51:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a57:	8b 40 04             	mov    0x4(%eax),%eax
 a5a:	c1 e0 03             	shl    $0x3,%eax
 a5d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a63:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a66:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6c:	a3 ec 0e 00 00       	mov    %eax,0xeec
      return (void*)(p + 1);
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	83 c0 08             	add    $0x8,%eax
 a77:	eb 38                	jmp    ab1 <malloc+0xdc>
    }
    if(p == freep)
 a79:	a1 ec 0e 00 00       	mov    0xeec,%eax
 a7e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a81:	75 1b                	jne    a9e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a83:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a86:	89 04 24             	mov    %eax,(%esp)
 a89:	e8 ef fe ff ff       	call   97d <morecore>
 a8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a95:	75 07                	jne    a9e <malloc+0xc9>
        return 0;
 a97:	b8 00 00 00 00       	mov    $0x0,%eax
 a9c:	eb 13                	jmp    ab1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa7:	8b 00                	mov    (%eax),%eax
 aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 aac:	e9 70 ff ff ff       	jmp    a21 <malloc+0x4c>
}
 ab1:	c9                   	leave  
 ab2:	c3                   	ret    
