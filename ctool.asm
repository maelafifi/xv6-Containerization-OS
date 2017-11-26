
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
  55:	e8 ca 04 00 00       	call   524 <mkdir>
	//chdir(create->name);
	
	int i = 1;
  5a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	int arg_size = (int) (sizeof(c_args)/sizeof(char*));
  61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	for(i = i; i < arg_size; i++){
  68:	e9 ad 00 00 00       	jmp    11a <create+0xd4>
		char* location = strcat(strcat(c_args[0], "/"), c_args[i]);
  6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  77:	8b 45 08             	mov    0x8(%ebp),%eax
  7a:	01 d0                	add    %edx,%eax
  7c:	8b 18                	mov    (%eax),%ebx
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	8b 00                	mov    (%eax),%eax
  83:	c7 44 24 04 08 0a 00 	movl   $0xa08,0x4(%esp)
  8a:	00 
  8b:	89 04 24             	mov    %eax,(%esp)
  8e:	e8 6d ff ff ff       	call   0 <strcat>
  93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  97:	89 04 24             	mov    %eax,(%esp)
  9a:	e8 61 ff ff ff       	call   0 <strcat>
  9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
		int id = fork();
  a2:	e8 0d 04 00 00       	call   4b4 <fork>
  a7:	89 45 e8             	mov    %eax,-0x18(%ebp)

		if(id == 0){
  aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  ae:	75 62                	jne    112 <create+0xcc>
			char *arr[] = {"cat", "<", c_args[i], ">", location,0};
  b0:	c7 45 d0 0a 0a 00 00 	movl   $0xa0a,-0x30(%ebp)
  b7:	c7 45 d4 0e 0a 00 00 	movl   $0xa0e,-0x2c(%ebp)
  be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	01 d0                	add    %edx,%eax
  cd:	8b 00                	mov    (%eax),%eax
  cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  d2:	c7 45 dc 10 0a 00 00 	movl   $0xa10,-0x24(%ebp)
  d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			exec("cat", arr);
  e6:	8d 45 d0             	lea    -0x30(%ebp),%eax
  e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  ed:	c7 04 24 0a 0a 00 00 	movl   $0xa0a,(%esp)
  f4:	e8 fb 03 00 00       	call   4f4 <exec>
			printf(1, "Failure to Execute.");
  f9:	c7 44 24 04 12 0a 00 	movl   $0xa12,0x4(%esp)
 100:	00 
 101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 108:	e8 34 05 00 00       	call   641 <printf>
			exit();
 10d:	e8 aa 03 00 00       	call   4bc <exit>
		}
		wait();
 112:	e8 ad 03 00 00       	call   4c4 <wait>
	mkdir(c_args[0]);
	//chdir(create->name);
	
	int i = 1;
	int arg_size = (int) (sizeof(c_args)/sizeof(char*));
	for(i = i; i < arg_size; i++){
 117:	ff 45 f4             	incl   -0xc(%ebp)
 11a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 11d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 120:	0f 8c 47 ff ff ff    	jl     6d <create+0x27>
			printf(1, "Failure to Execute.");
			exit();
		}
		wait();
	}
}
 126:	83 c4 44             	add    $0x44,%esp
 129:	5b                   	pop    %ebx
 12a:	5d                   	pop    %ebp
 12b:	c3                   	ret    

0000012c <attach_vc>:

void attach_vc(char* vc, char* dir, char* file){
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	83 ec 28             	sub    $0x28,%esp
	int fd, id;

	fd = open(vc, O_RDWR);
 132:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
 139:	00 
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	89 04 24             	mov    %eax,(%esp)
 140:	e8 b7 03 00 00       	call   4fc <open>
 145:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//printf(1, "fd = %d\n", fd);

	//TODO Check tosee file in file system

	chdir(dir);
 148:	8b 45 0c             	mov    0xc(%ebp),%eax
 14b:	89 04 24             	mov    %eax,(%esp)
 14e:	e8 d9 03 00 00       	call   52c <chdir>

	/* fork a child and exec argv[1] */
	id = fork();
 153:	e8 5c 03 00 00       	call   4b4 <fork>
 158:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (id == 0){
 15b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 15f:	75 70                	jne    1d1 <attach_vc+0xa5>
		close(0);
 161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 168:	e8 77 03 00 00       	call   4e4 <close>
		close(1);
 16d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 174:	e8 6b 03 00 00       	call   4e4 <close>
		close(2);
 179:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 180:	e8 5f 03 00 00       	call   4e4 <close>
		dup(fd);
 185:	8b 45 f4             	mov    -0xc(%ebp),%eax
 188:	89 04 24             	mov    %eax,(%esp)
 18b:	e8 a4 03 00 00       	call   534 <dup>
		dup(fd);
 190:	8b 45 f4             	mov    -0xc(%ebp),%eax
 193:	89 04 24             	mov    %eax,(%esp)
 196:	e8 99 03 00 00       	call   534 <dup>
		dup(fd);
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	89 04 24             	mov    %eax,(%esp)
 1a1:	e8 8e 03 00 00       	call   534 <dup>
		exec(file, &file);
 1a6:	8b 45 10             	mov    0x10(%ebp),%eax
 1a9:	8d 55 10             	lea    0x10(%ebp),%edx
 1ac:	89 54 24 04          	mov    %edx,0x4(%esp)
 1b0:	89 04 24             	mov    %eax,(%esp)
 1b3:	e8 3c 03 00 00       	call   4f4 <exec>
		printf(1, "Failure to attach VC.");
 1b8:	c7 44 24 04 26 0a 00 	movl   $0xa26,0x4(%esp)
 1bf:	00 
 1c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1c7:	e8 75 04 00 00       	call   641 <printf>
		exit();
 1cc:	e8 eb 02 00 00       	call   4bc <exit>
	}
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <start>:

void start(char *s_args[]){
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
	// 	}
	// 	else if(s_args[i] == '-d'){

	// 	}
	// }
}
 1d6:	5d                   	pop    %ebp
 1d7:	c3                   	ret    

000001d8 <pause>:

void pause(char *c_name){
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp

}
 1db:	5d                   	pop    %ebp
 1dc:	c3                   	ret    

000001dd <resume>:

void resume(char *c_name){
 1dd:	55                   	push   %ebp
 1de:	89 e5                	mov    %esp,%ebp

}
 1e0:	5d                   	pop    %ebp
 1e1:	c3                   	ret    

000001e2 <stop>:

void stop(char *c_name){
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp

}
 1e5:	5d                   	pop    %ebp
 1e6:	c3                   	ret    

000001e7 <info>:

void info(char *c_name){
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp

}
 1ea:	5d                   	pop    %ebp
 1eb:	c3                   	ret    

000001ec <main>:

int main(int argc, char *argv[]){
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 e4 f0             	and    $0xfffffff0,%esp
 1f2:	83 ec 10             	sub    $0x10,%esp
	if(strcmp(argv[1], "create")){
 1f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f8:	83 c0 04             	add    $0x4,%eax
 1fb:	8b 00                	mov    (%eax),%eax
 1fd:	c7 44 24 04 3c 0a 00 	movl   $0xa3c,0x4(%esp)
 204:	00 
 205:	89 04 24             	mov    %eax,(%esp)
 208:	e8 ae 00 00 00       	call   2bb <strcmp>
 20d:	85 c0                	test   %eax,%eax
 20f:	74 10                	je     221 <main+0x35>
		create(&argv[2]);
 211:	8b 45 0c             	mov    0xc(%ebp),%eax
 214:	83 c0 08             	add    $0x8,%eax
 217:	89 04 24             	mov    %eax,(%esp)
 21a:	e8 27 fe ff ff       	call   46 <create>
 21f:	eb 40                	jmp    261 <main+0x75>
	}
	else if(strcmp(argv[1], "start") == 0){
 221:	8b 45 0c             	mov    0xc(%ebp),%eax
 224:	83 c0 04             	add    $0x4,%eax
 227:	8b 00                	mov    (%eax),%eax
 229:	c7 44 24 04 43 0a 00 	movl   $0xa43,0x4(%esp)
 230:	00 
 231:	89 04 24             	mov    %eax,(%esp)
 234:	e8 82 00 00 00       	call   2bb <strcmp>
 239:	85 c0                	test   %eax,%eax
 23b:	75 10                	jne    24d <main+0x61>
		start(&argv[2]);
 23d:	8b 45 0c             	mov    0xc(%ebp),%eax
 240:	83 c0 08             	add    $0x8,%eax
 243:	89 04 24             	mov    %eax,(%esp)
 246:	e8 88 ff ff ff       	call   1d3 <start>
 24b:	eb 14                	jmp    261 <main+0x75>
	// }
	// else if(argv[1] == 'info'){
	// 	info(&argv[2]);
	// }
	else{
		printf(1, "Improper usage; create, start, pause, resume, stop, info");
 24d:	c7 44 24 04 4c 0a 00 	movl   $0xa4c,0x4(%esp)
 254:	00 
 255:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 25c:	e8 e0 03 00 00       	call   641 <printf>
	}
	return 0;
 261:	b8 00 00 00 00       	mov    $0x0,%eax
}
 266:	c9                   	leave  
 267:	c3                   	ret    

00000268 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 268:	55                   	push   %ebp
 269:	89 e5                	mov    %esp,%ebp
 26b:	57                   	push   %edi
 26c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 26d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 270:	8b 55 10             	mov    0x10(%ebp),%edx
 273:	8b 45 0c             	mov    0xc(%ebp),%eax
 276:	89 cb                	mov    %ecx,%ebx
 278:	89 df                	mov    %ebx,%edi
 27a:	89 d1                	mov    %edx,%ecx
 27c:	fc                   	cld    
 27d:	f3 aa                	rep stos %al,%es:(%edi)
 27f:	89 ca                	mov    %ecx,%edx
 281:	89 fb                	mov    %edi,%ebx
 283:	89 5d 08             	mov    %ebx,0x8(%ebp)
 286:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 289:	5b                   	pop    %ebx
 28a:	5f                   	pop    %edi
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    

0000028d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 299:	90                   	nop
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	8d 50 01             	lea    0x1(%eax),%edx
 2a0:	89 55 08             	mov    %edx,0x8(%ebp)
 2a3:	8b 55 0c             	mov    0xc(%ebp),%edx
 2a6:	8d 4a 01             	lea    0x1(%edx),%ecx
 2a9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2ac:	8a 12                	mov    (%edx),%dl
 2ae:	88 10                	mov    %dl,(%eax)
 2b0:	8a 00                	mov    (%eax),%al
 2b2:	84 c0                	test   %al,%al
 2b4:	75 e4                	jne    29a <strcpy+0xd>
    ;
  return os;
 2b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b9:	c9                   	leave  
 2ba:	c3                   	ret    

000002bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2be:	eb 06                	jmp    2c6 <strcmp+0xb>
    p++, q++;
 2c0:	ff 45 08             	incl   0x8(%ebp)
 2c3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	8a 00                	mov    (%eax),%al
 2cb:	84 c0                	test   %al,%al
 2cd:	74 0e                	je     2dd <strcmp+0x22>
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	8a 10                	mov    (%eax),%dl
 2d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d7:	8a 00                	mov    (%eax),%al
 2d9:	38 c2                	cmp    %al,%dl
 2db:	74 e3                	je     2c0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	8a 00                	mov    (%eax),%al
 2e2:	0f b6 d0             	movzbl %al,%edx
 2e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e8:	8a 00                	mov    (%eax),%al
 2ea:	0f b6 c0             	movzbl %al,%eax
 2ed:	29 c2                	sub    %eax,%edx
 2ef:	89 d0                	mov    %edx,%eax
}
 2f1:	5d                   	pop    %ebp
 2f2:	c3                   	ret    

000002f3 <strlen>:

uint
strlen(char *s)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 300:	eb 03                	jmp    305 <strlen+0x12>
 302:	ff 45 fc             	incl   -0x4(%ebp)
 305:	8b 55 fc             	mov    -0x4(%ebp),%edx
 308:	8b 45 08             	mov    0x8(%ebp),%eax
 30b:	01 d0                	add    %edx,%eax
 30d:	8a 00                	mov    (%eax),%al
 30f:	84 c0                	test   %al,%al
 311:	75 ef                	jne    302 <strlen+0xf>
    ;
  return n;
 313:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 316:	c9                   	leave  
 317:	c3                   	ret    

00000318 <memset>:

void*
memset(void *dst, int c, uint n)
{
 318:	55                   	push   %ebp
 319:	89 e5                	mov    %esp,%ebp
 31b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 31e:	8b 45 10             	mov    0x10(%ebp),%eax
 321:	89 44 24 08          	mov    %eax,0x8(%esp)
 325:	8b 45 0c             	mov    0xc(%ebp),%eax
 328:	89 44 24 04          	mov    %eax,0x4(%esp)
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	89 04 24             	mov    %eax,(%esp)
 332:	e8 31 ff ff ff       	call   268 <stosb>
  return dst;
 337:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33a:	c9                   	leave  
 33b:	c3                   	ret    

0000033c <strchr>:

char*
strchr(const char *s, char c)
{
 33c:	55                   	push   %ebp
 33d:	89 e5                	mov    %esp,%ebp
 33f:	83 ec 04             	sub    $0x4,%esp
 342:	8b 45 0c             	mov    0xc(%ebp),%eax
 345:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 348:	eb 12                	jmp    35c <strchr+0x20>
    if(*s == c)
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
 34d:	8a 00                	mov    (%eax),%al
 34f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 352:	75 05                	jne    359 <strchr+0x1d>
      return (char*)s;
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	eb 11                	jmp    36a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 359:	ff 45 08             	incl   0x8(%ebp)
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	8a 00                	mov    (%eax),%al
 361:	84 c0                	test   %al,%al
 363:	75 e5                	jne    34a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 365:	b8 00 00 00 00       	mov    $0x0,%eax
}
 36a:	c9                   	leave  
 36b:	c3                   	ret    

0000036c <gets>:

char*
gets(char *buf, int max)
{
 36c:	55                   	push   %ebp
 36d:	89 e5                	mov    %esp,%ebp
 36f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 372:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 379:	eb 49                	jmp    3c4 <gets+0x58>
    cc = read(0, &c, 1);
 37b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 382:	00 
 383:	8d 45 ef             	lea    -0x11(%ebp),%eax
 386:	89 44 24 04          	mov    %eax,0x4(%esp)
 38a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 391:	e8 3e 01 00 00       	call   4d4 <read>
 396:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 399:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 39d:	7f 02                	jg     3a1 <gets+0x35>
      break;
 39f:	eb 2c                	jmp    3cd <gets+0x61>
    buf[i++] = c;
 3a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a4:	8d 50 01             	lea    0x1(%eax),%edx
 3a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3aa:	89 c2                	mov    %eax,%edx
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	01 c2                	add    %eax,%edx
 3b1:	8a 45 ef             	mov    -0x11(%ebp),%al
 3b4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3b6:	8a 45 ef             	mov    -0x11(%ebp),%al
 3b9:	3c 0a                	cmp    $0xa,%al
 3bb:	74 10                	je     3cd <gets+0x61>
 3bd:	8a 45 ef             	mov    -0x11(%ebp),%al
 3c0:	3c 0d                	cmp    $0xd,%al
 3c2:	74 09                	je     3cd <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c7:	40                   	inc    %eax
 3c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3cb:	7c ae                	jl     37b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	01 d0                	add    %edx,%eax
 3d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3db:	c9                   	leave  
 3dc:	c3                   	ret    

000003dd <stat>:

int
stat(char *n, struct stat *st)
{
 3dd:	55                   	push   %ebp
 3de:	89 e5                	mov    %esp,%ebp
 3e0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 3ea:	00 
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	89 04 24             	mov    %eax,(%esp)
 3f1:	e8 06 01 00 00       	call   4fc <open>
 3f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3fd:	79 07                	jns    406 <stat+0x29>
    return -1;
 3ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 404:	eb 23                	jmp    429 <stat+0x4c>
  r = fstat(fd, st);
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	89 44 24 04          	mov    %eax,0x4(%esp)
 40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 410:	89 04 24             	mov    %eax,(%esp)
 413:	e8 fc 00 00 00       	call   514 <fstat>
 418:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 41b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41e:	89 04 24             	mov    %eax,(%esp)
 421:	e8 be 00 00 00       	call   4e4 <close>
  return r;
 426:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 429:	c9                   	leave  
 42a:	c3                   	ret    

0000042b <atoi>:

int
atoi(const char *s)
{
 42b:	55                   	push   %ebp
 42c:	89 e5                	mov    %esp,%ebp
 42e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 431:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 438:	eb 24                	jmp    45e <atoi+0x33>
    n = n*10 + *s++ - '0';
 43a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 43d:	89 d0                	mov    %edx,%eax
 43f:	c1 e0 02             	shl    $0x2,%eax
 442:	01 d0                	add    %edx,%eax
 444:	01 c0                	add    %eax,%eax
 446:	89 c1                	mov    %eax,%ecx
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	8d 50 01             	lea    0x1(%eax),%edx
 44e:	89 55 08             	mov    %edx,0x8(%ebp)
 451:	8a 00                	mov    (%eax),%al
 453:	0f be c0             	movsbl %al,%eax
 456:	01 c8                	add    %ecx,%eax
 458:	83 e8 30             	sub    $0x30,%eax
 45b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	8a 00                	mov    (%eax),%al
 463:	3c 2f                	cmp    $0x2f,%al
 465:	7e 09                	jle    470 <atoi+0x45>
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	8a 00                	mov    (%eax),%al
 46c:	3c 39                	cmp    $0x39,%al
 46e:	7e ca                	jle    43a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 470:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 473:	c9                   	leave  
 474:	c3                   	ret    

00000475 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 475:	55                   	push   %ebp
 476:	89 e5                	mov    %esp,%ebp
 478:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 481:	8b 45 0c             	mov    0xc(%ebp),%eax
 484:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 487:	eb 16                	jmp    49f <memmove+0x2a>
    *dst++ = *src++;
 489:	8b 45 fc             	mov    -0x4(%ebp),%eax
 48c:	8d 50 01             	lea    0x1(%eax),%edx
 48f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 492:	8b 55 f8             	mov    -0x8(%ebp),%edx
 495:	8d 4a 01             	lea    0x1(%edx),%ecx
 498:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 49b:	8a 12                	mov    (%edx),%dl
 49d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 49f:	8b 45 10             	mov    0x10(%ebp),%eax
 4a2:	8d 50 ff             	lea    -0x1(%eax),%edx
 4a5:	89 55 10             	mov    %edx,0x10(%ebp)
 4a8:	85 c0                	test   %eax,%eax
 4aa:	7f dd                	jg     489 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4af:	c9                   	leave  
 4b0:	c3                   	ret    
 4b1:	90                   	nop
 4b2:	90                   	nop
 4b3:	90                   	nop

000004b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4b4:	b8 01 00 00 00       	mov    $0x1,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <exit>:
SYSCALL(exit)
 4bc:	b8 02 00 00 00       	mov    $0x2,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <wait>:
SYSCALL(wait)
 4c4:	b8 03 00 00 00       	mov    $0x3,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <pipe>:
SYSCALL(pipe)
 4cc:	b8 04 00 00 00       	mov    $0x4,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <read>:
SYSCALL(read)
 4d4:	b8 05 00 00 00       	mov    $0x5,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <write>:
SYSCALL(write)
 4dc:	b8 10 00 00 00       	mov    $0x10,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <close>:
SYSCALL(close)
 4e4:	b8 15 00 00 00       	mov    $0x15,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <kill>:
SYSCALL(kill)
 4ec:	b8 06 00 00 00       	mov    $0x6,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <exec>:
SYSCALL(exec)
 4f4:	b8 07 00 00 00       	mov    $0x7,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <open>:
SYSCALL(open)
 4fc:	b8 0f 00 00 00       	mov    $0xf,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <mknod>:
SYSCALL(mknod)
 504:	b8 11 00 00 00       	mov    $0x11,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <unlink>:
SYSCALL(unlink)
 50c:	b8 12 00 00 00       	mov    $0x12,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <fstat>:
SYSCALL(fstat)
 514:	b8 08 00 00 00       	mov    $0x8,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <link>:
SYSCALL(link)
 51c:	b8 13 00 00 00       	mov    $0x13,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <mkdir>:
SYSCALL(mkdir)
 524:	b8 14 00 00 00       	mov    $0x14,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <chdir>:
SYSCALL(chdir)
 52c:	b8 09 00 00 00       	mov    $0x9,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <dup>:
SYSCALL(dup)
 534:	b8 0a 00 00 00       	mov    $0xa,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <getpid>:
SYSCALL(getpid)
 53c:	b8 0b 00 00 00       	mov    $0xb,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <sbrk>:
SYSCALL(sbrk)
 544:	b8 0c 00 00 00       	mov    $0xc,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <sleep>:
SYSCALL(sleep)
 54c:	b8 0d 00 00 00       	mov    $0xd,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <uptime>:
SYSCALL(uptime)
 554:	b8 0e 00 00 00       	mov    $0xe,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <getticks>:
 55c:	b8 16 00 00 00       	mov    $0x16,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	83 ec 18             	sub    $0x18,%esp
 56a:	8b 45 0c             	mov    0xc(%ebp),%eax
 56d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 570:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 577:	00 
 578:	8d 45 f4             	lea    -0xc(%ebp),%eax
 57b:	89 44 24 04          	mov    %eax,0x4(%esp)
 57f:	8b 45 08             	mov    0x8(%ebp),%eax
 582:	89 04 24             	mov    %eax,(%esp)
 585:	e8 52 ff ff ff       	call   4dc <write>
}
 58a:	c9                   	leave  
 58b:	c3                   	ret    

0000058c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 58c:	55                   	push   %ebp
 58d:	89 e5                	mov    %esp,%ebp
 58f:	56                   	push   %esi
 590:	53                   	push   %ebx
 591:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 594:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 59b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 59f:	74 17                	je     5b8 <printint+0x2c>
 5a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5a5:	79 11                	jns    5b8 <printint+0x2c>
    neg = 1;
 5a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b1:	f7 d8                	neg    %eax
 5b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b6:	eb 06                	jmp    5be <printint+0x32>
  } else {
    x = xx;
 5b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5c5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5c8:	8d 41 01             	lea    0x1(%ecx),%eax
 5cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d4:	ba 00 00 00 00       	mov    $0x0,%edx
 5d9:	f7 f3                	div    %ebx
 5db:	89 d0                	mov    %edx,%eax
 5dd:	8a 80 d8 0d 00 00    	mov    0xdd8(%eax),%al
 5e3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5e7:	8b 75 10             	mov    0x10(%ebp),%esi
 5ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ed:	ba 00 00 00 00       	mov    $0x0,%edx
 5f2:	f7 f6                	div    %esi
 5f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5fb:	75 c8                	jne    5c5 <printint+0x39>
  if(neg)
 5fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 601:	74 10                	je     613 <printint+0x87>
    buf[i++] = '-';
 603:	8b 45 f4             	mov    -0xc(%ebp),%eax
 606:	8d 50 01             	lea    0x1(%eax),%edx
 609:	89 55 f4             	mov    %edx,-0xc(%ebp)
 60c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 611:	eb 1e                	jmp    631 <printint+0xa5>
 613:	eb 1c                	jmp    631 <printint+0xa5>
    putc(fd, buf[i]);
 615:	8d 55 dc             	lea    -0x24(%ebp),%edx
 618:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61b:	01 d0                	add    %edx,%eax
 61d:	8a 00                	mov    (%eax),%al
 61f:	0f be c0             	movsbl %al,%eax
 622:	89 44 24 04          	mov    %eax,0x4(%esp)
 626:	8b 45 08             	mov    0x8(%ebp),%eax
 629:	89 04 24             	mov    %eax,(%esp)
 62c:	e8 33 ff ff ff       	call   564 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 631:	ff 4d f4             	decl   -0xc(%ebp)
 634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 638:	79 db                	jns    615 <printint+0x89>
    putc(fd, buf[i]);
}
 63a:	83 c4 30             	add    $0x30,%esp
 63d:	5b                   	pop    %ebx
 63e:	5e                   	pop    %esi
 63f:	5d                   	pop    %ebp
 640:	c3                   	ret    

00000641 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 641:	55                   	push   %ebp
 642:	89 e5                	mov    %esp,%ebp
 644:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 647:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 64e:	8d 45 0c             	lea    0xc(%ebp),%eax
 651:	83 c0 04             	add    $0x4,%eax
 654:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 657:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 65e:	e9 77 01 00 00       	jmp    7da <printf+0x199>
    c = fmt[i] & 0xff;
 663:	8b 55 0c             	mov    0xc(%ebp),%edx
 666:	8b 45 f0             	mov    -0x10(%ebp),%eax
 669:	01 d0                	add    %edx,%eax
 66b:	8a 00                	mov    (%eax),%al
 66d:	0f be c0             	movsbl %al,%eax
 670:	25 ff 00 00 00       	and    $0xff,%eax
 675:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 678:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 67c:	75 2c                	jne    6aa <printf+0x69>
      if(c == '%'){
 67e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 682:	75 0c                	jne    690 <printf+0x4f>
        state = '%';
 684:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 68b:	e9 47 01 00 00       	jmp    7d7 <printf+0x196>
      } else {
        putc(fd, c);
 690:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 693:	0f be c0             	movsbl %al,%eax
 696:	89 44 24 04          	mov    %eax,0x4(%esp)
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	89 04 24             	mov    %eax,(%esp)
 6a0:	e8 bf fe ff ff       	call   564 <putc>
 6a5:	e9 2d 01 00 00       	jmp    7d7 <printf+0x196>
      }
    } else if(state == '%'){
 6aa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ae:	0f 85 23 01 00 00    	jne    7d7 <printf+0x196>
      if(c == 'd'){
 6b4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6b8:	75 2d                	jne    6e7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6bd:	8b 00                	mov    (%eax),%eax
 6bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6c6:	00 
 6c7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6ce:	00 
 6cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	89 04 24             	mov    %eax,(%esp)
 6d9:	e8 ae fe ff ff       	call   58c <printint>
        ap++;
 6de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e2:	e9 e9 00 00 00       	jmp    7d0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6e7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6eb:	74 06                	je     6f3 <printf+0xb2>
 6ed:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6f1:	75 2d                	jne    720 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f6:	8b 00                	mov    (%eax),%eax
 6f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ff:	00 
 700:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 707:	00 
 708:	89 44 24 04          	mov    %eax,0x4(%esp)
 70c:	8b 45 08             	mov    0x8(%ebp),%eax
 70f:	89 04 24             	mov    %eax,(%esp)
 712:	e8 75 fe ff ff       	call   58c <printint>
        ap++;
 717:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71b:	e9 b0 00 00 00       	jmp    7d0 <printf+0x18f>
      } else if(c == 's'){
 720:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 724:	75 42                	jne    768 <printf+0x127>
        s = (char*)*ap;
 726:	8b 45 e8             	mov    -0x18(%ebp),%eax
 729:	8b 00                	mov    (%eax),%eax
 72b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 72e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 732:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 736:	75 09                	jne    741 <printf+0x100>
          s = "(null)";
 738:	c7 45 f4 85 0a 00 00 	movl   $0xa85,-0xc(%ebp)
        while(*s != 0){
 73f:	eb 1c                	jmp    75d <printf+0x11c>
 741:	eb 1a                	jmp    75d <printf+0x11c>
          putc(fd, *s);
 743:	8b 45 f4             	mov    -0xc(%ebp),%eax
 746:	8a 00                	mov    (%eax),%al
 748:	0f be c0             	movsbl %al,%eax
 74b:	89 44 24 04          	mov    %eax,0x4(%esp)
 74f:	8b 45 08             	mov    0x8(%ebp),%eax
 752:	89 04 24             	mov    %eax,(%esp)
 755:	e8 0a fe ff ff       	call   564 <putc>
          s++;
 75a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 75d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 760:	8a 00                	mov    (%eax),%al
 762:	84 c0                	test   %al,%al
 764:	75 dd                	jne    743 <printf+0x102>
 766:	eb 68                	jmp    7d0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 768:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 76c:	75 1d                	jne    78b <printf+0x14a>
        putc(fd, *ap);
 76e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 771:	8b 00                	mov    (%eax),%eax
 773:	0f be c0             	movsbl %al,%eax
 776:	89 44 24 04          	mov    %eax,0x4(%esp)
 77a:	8b 45 08             	mov    0x8(%ebp),%eax
 77d:	89 04 24             	mov    %eax,(%esp)
 780:	e8 df fd ff ff       	call   564 <putc>
        ap++;
 785:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 789:	eb 45                	jmp    7d0 <printf+0x18f>
      } else if(c == '%'){
 78b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78f:	75 17                	jne    7a8 <printf+0x167>
        putc(fd, c);
 791:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 794:	0f be c0             	movsbl %al,%eax
 797:	89 44 24 04          	mov    %eax,0x4(%esp)
 79b:	8b 45 08             	mov    0x8(%ebp),%eax
 79e:	89 04 24             	mov    %eax,(%esp)
 7a1:	e8 be fd ff ff       	call   564 <putc>
 7a6:	eb 28                	jmp    7d0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7af:	00 
 7b0:	8b 45 08             	mov    0x8(%ebp),%eax
 7b3:	89 04 24             	mov    %eax,(%esp)
 7b6:	e8 a9 fd ff ff       	call   564 <putc>
        putc(fd, c);
 7bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7be:	0f be c0             	movsbl %al,%eax
 7c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c5:	8b 45 08             	mov    0x8(%ebp),%eax
 7c8:	89 04 24             	mov    %eax,(%esp)
 7cb:	e8 94 fd ff ff       	call   564 <putc>
      }
      state = 0;
 7d0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7d7:	ff 45 f0             	incl   -0x10(%ebp)
 7da:	8b 55 0c             	mov    0xc(%ebp),%edx
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	01 d0                	add    %edx,%eax
 7e2:	8a 00                	mov    (%eax),%al
 7e4:	84 c0                	test   %al,%al
 7e6:	0f 85 77 fe ff ff    	jne    663 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7ec:	c9                   	leave  
 7ed:	c3                   	ret    
 7ee:	90                   	nop
 7ef:	90                   	nop

000007f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f0:	55                   	push   %ebp
 7f1:	89 e5                	mov    %esp,%ebp
 7f3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f6:	8b 45 08             	mov    0x8(%ebp),%eax
 7f9:	83 e8 08             	sub    $0x8,%eax
 7fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ff:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 804:	89 45 fc             	mov    %eax,-0x4(%ebp)
 807:	eb 24                	jmp    82d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 809:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80c:	8b 00                	mov    (%eax),%eax
 80e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 811:	77 12                	ja     825 <free+0x35>
 813:	8b 45 f8             	mov    -0x8(%ebp),%eax
 816:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 819:	77 24                	ja     83f <free+0x4f>
 81b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81e:	8b 00                	mov    (%eax),%eax
 820:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 823:	77 1a                	ja     83f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 830:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 833:	76 d4                	jbe    809 <free+0x19>
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 83d:	76 ca                	jbe    809 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	8b 40 04             	mov    0x4(%eax),%eax
 845:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 84c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84f:	01 c2                	add    %eax,%edx
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	39 c2                	cmp    %eax,%edx
 858:	75 24                	jne    87e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 85a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85d:	8b 50 04             	mov    0x4(%eax),%edx
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	8b 00                	mov    (%eax),%eax
 865:	8b 40 04             	mov    0x4(%eax),%eax
 868:	01 c2                	add    %eax,%edx
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 870:	8b 45 fc             	mov    -0x4(%ebp),%eax
 873:	8b 00                	mov    (%eax),%eax
 875:	8b 10                	mov    (%eax),%edx
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	89 10                	mov    %edx,(%eax)
 87c:	eb 0a                	jmp    888 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 87e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 881:	8b 10                	mov    (%eax),%edx
 883:	8b 45 f8             	mov    -0x8(%ebp),%eax
 886:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 888:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88b:	8b 40 04             	mov    0x4(%eax),%eax
 88e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 895:	8b 45 fc             	mov    -0x4(%ebp),%eax
 898:	01 d0                	add    %edx,%eax
 89a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 89d:	75 20                	jne    8bf <free+0xcf>
    p->s.size += bp->s.size;
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 50 04             	mov    0x4(%eax),%edx
 8a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a8:	8b 40 04             	mov    0x4(%eax),%eax
 8ab:	01 c2                	add    %eax,%edx
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b6:	8b 10                	mov    (%eax),%edx
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	89 10                	mov    %edx,(%eax)
 8bd:	eb 08                	jmp    8c7 <free+0xd7>
  } else
    p->s.ptr = bp;
 8bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8c5:	89 10                	mov    %edx,(%eax)
  freep = p;
 8c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ca:	a3 f4 0d 00 00       	mov    %eax,0xdf4
}
 8cf:	c9                   	leave  
 8d0:	c3                   	ret    

000008d1 <morecore>:

static Header*
morecore(uint nu)
{
 8d1:	55                   	push   %ebp
 8d2:	89 e5                	mov    %esp,%ebp
 8d4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8d7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8de:	77 07                	ja     8e7 <morecore+0x16>
    nu = 4096;
 8e0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8e7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ea:	c1 e0 03             	shl    $0x3,%eax
 8ed:	89 04 24             	mov    %eax,(%esp)
 8f0:	e8 4f fc ff ff       	call   544 <sbrk>
 8f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8f8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8fc:	75 07                	jne    905 <morecore+0x34>
    return 0;
 8fe:	b8 00 00 00 00       	mov    $0x0,%eax
 903:	eb 22                	jmp    927 <morecore+0x56>
  hp = (Header*)p;
 905:	8b 45 f4             	mov    -0xc(%ebp),%eax
 908:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 90b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90e:	8b 55 08             	mov    0x8(%ebp),%edx
 911:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 914:	8b 45 f0             	mov    -0x10(%ebp),%eax
 917:	83 c0 08             	add    $0x8,%eax
 91a:	89 04 24             	mov    %eax,(%esp)
 91d:	e8 ce fe ff ff       	call   7f0 <free>
  return freep;
 922:	a1 f4 0d 00 00       	mov    0xdf4,%eax
}
 927:	c9                   	leave  
 928:	c3                   	ret    

00000929 <malloc>:

void*
malloc(uint nbytes)
{
 929:	55                   	push   %ebp
 92a:	89 e5                	mov    %esp,%ebp
 92c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92f:	8b 45 08             	mov    0x8(%ebp),%eax
 932:	83 c0 07             	add    $0x7,%eax
 935:	c1 e8 03             	shr    $0x3,%eax
 938:	40                   	inc    %eax
 939:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 93c:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 941:	89 45 f0             	mov    %eax,-0x10(%ebp)
 944:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 948:	75 23                	jne    96d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 94a:	c7 45 f0 ec 0d 00 00 	movl   $0xdec,-0x10(%ebp)
 951:	8b 45 f0             	mov    -0x10(%ebp),%eax
 954:	a3 f4 0d 00 00       	mov    %eax,0xdf4
 959:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 95e:	a3 ec 0d 00 00       	mov    %eax,0xdec
    base.s.size = 0;
 963:	c7 05 f0 0d 00 00 00 	movl   $0x0,0xdf0
 96a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 970:	8b 00                	mov    (%eax),%eax
 972:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 975:	8b 45 f4             	mov    -0xc(%ebp),%eax
 978:	8b 40 04             	mov    0x4(%eax),%eax
 97b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97e:	72 4d                	jb     9cd <malloc+0xa4>
      if(p->s.size == nunits)
 980:	8b 45 f4             	mov    -0xc(%ebp),%eax
 983:	8b 40 04             	mov    0x4(%eax),%eax
 986:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 989:	75 0c                	jne    997 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	8b 10                	mov    (%eax),%edx
 990:	8b 45 f0             	mov    -0x10(%ebp),%eax
 993:	89 10                	mov    %edx,(%eax)
 995:	eb 26                	jmp    9bd <malloc+0x94>
      else {
        p->s.size -= nunits;
 997:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99a:	8b 40 04             	mov    0x4(%eax),%eax
 99d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9a0:	89 c2                	mov    %eax,%edx
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 40 04             	mov    0x4(%eax),%eax
 9ae:	c1 e0 03             	shl    $0x3,%eax
 9b1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ba:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	a3 f4 0d 00 00       	mov    %eax,0xdf4
      return (void*)(p + 1);
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	83 c0 08             	add    $0x8,%eax
 9cb:	eb 38                	jmp    a05 <malloc+0xdc>
    }
    if(p == freep)
 9cd:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 9d2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9d5:	75 1b                	jne    9f2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9da:	89 04 24             	mov    %eax,(%esp)
 9dd:	e8 ef fe ff ff       	call   8d1 <morecore>
 9e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9e9:	75 07                	jne    9f2 <malloc+0xc9>
        return 0;
 9eb:	b8 00 00 00 00       	mov    $0x0,%eax
 9f0:	eb 13                	jmp    a05 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fb:	8b 00                	mov    (%eax),%eax
 9fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a00:	e9 70 ff ff ff       	jmp    975 <malloc+0x4c>
}
 a05:	c9                   	leave  
 a06:	c3                   	ret    
