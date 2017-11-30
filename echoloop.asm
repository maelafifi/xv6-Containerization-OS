
_echoloop:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;
  int ticks;

  if (argc < 3) {
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
  	printf(1, "usage: echoloop ticks arg1 [arg2 ...]\n");
   f:	c7 44 24 04 f8 08 00 	movl   $0x8f8,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 0e 05 00 00       	call   531 <printf>
  	exit();
  23:	e8 d4 02 00 00       	call   2fc <exit>
  }

  ticks = atoi(argv[1]);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	89 04 24             	mov    %eax,(%esp)
  33:	e8 33 02 00 00       	call   26b <atoi>
  38:	89 44 24 18          	mov    %eax,0x18(%esp)

  while(1){
	  for(i = 2; i < argc; i++)
  3c:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
  43:	00 
  44:	eb 48                	jmp    8e <main+0x8e>
    	printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  46:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  4a:	40                   	inc    %eax
  4b:	3b 45 08             	cmp    0x8(%ebp),%eax
  4e:	7d 07                	jge    57 <main+0x57>
  50:	b8 1f 09 00 00       	mov    $0x91f,%eax
  55:	eb 05                	jmp    5c <main+0x5c>
  57:	b8 21 09 00 00       	mov    $0x921,%eax
  5c:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  60:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  67:	8b 55 0c             	mov    0xc(%ebp),%edx
  6a:	01 ca                	add    %ecx,%edx
  6c:	8b 12                	mov    (%edx),%edx
  6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  72:	89 54 24 08          	mov    %edx,0x8(%esp)
  76:	c7 44 24 04 23 09 00 	movl   $0x923,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 a7 04 00 00       	call   531 <printf>
  }

  ticks = atoi(argv[1]);

  while(1){
	  for(i = 2; i < argc; i++)
  8a:	ff 44 24 1c          	incl   0x1c(%esp)
  8e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  92:	3b 45 08             	cmp    0x8(%ebp),%eax
  95:	7c af                	jl     46 <main+0x46>
    	printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
    sleep(ticks);
  97:	8b 44 24 18          	mov    0x18(%esp),%eax
  9b:	89 04 24             	mov    %eax,(%esp)
  9e:	e8 e9 02 00 00       	call   38c <sleep>
  }
  a3:	eb 97                	jmp    3c <main+0x3c>
  a5:	90                   	nop
  a6:	90                   	nop
  a7:	90                   	nop

000000a8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	57                   	push   %edi
  ac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b0:	8b 55 10             	mov    0x10(%ebp),%edx
  b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  b6:	89 cb                	mov    %ecx,%ebx
  b8:	89 df                	mov    %ebx,%edi
  ba:	89 d1                	mov    %edx,%ecx
  bc:	fc                   	cld    
  bd:	f3 aa                	rep stos %al,%es:(%edi)
  bf:	89 ca                	mov    %ecx,%edx
  c1:	89 fb                	mov    %edi,%ebx
  c3:	89 5d 08             	mov    %ebx,0x8(%ebp)
  c6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  c9:	5b                   	pop    %ebx
  ca:	5f                   	pop    %edi
  cb:	5d                   	pop    %ebp
  cc:	c3                   	ret    

000000cd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  d9:	90                   	nop
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	8d 50 01             	lea    0x1(%eax),%edx
  e0:	89 55 08             	mov    %edx,0x8(%ebp)
  e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  e9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ec:	8a 12                	mov    (%edx),%dl
  ee:	88 10                	mov    %dl,(%eax)
  f0:	8a 00                	mov    (%eax),%al
  f2:	84 c0                	test   %al,%al
  f4:	75 e4                	jne    da <strcpy+0xd>
    ;
  return os;
  f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f9:	c9                   	leave  
  fa:	c3                   	ret    

000000fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  fe:	eb 06                	jmp    106 <strcmp+0xb>
    p++, q++;
 100:	ff 45 08             	incl   0x8(%ebp)
 103:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 106:	8b 45 08             	mov    0x8(%ebp),%eax
 109:	8a 00                	mov    (%eax),%al
 10b:	84 c0                	test   %al,%al
 10d:	74 0e                	je     11d <strcmp+0x22>
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	8a 10                	mov    (%eax),%dl
 114:	8b 45 0c             	mov    0xc(%ebp),%eax
 117:	8a 00                	mov    (%eax),%al
 119:	38 c2                	cmp    %al,%dl
 11b:	74 e3                	je     100 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	8a 00                	mov    (%eax),%al
 122:	0f b6 d0             	movzbl %al,%edx
 125:	8b 45 0c             	mov    0xc(%ebp),%eax
 128:	8a 00                	mov    (%eax),%al
 12a:	0f b6 c0             	movzbl %al,%eax
 12d:	29 c2                	sub    %eax,%edx
 12f:	89 d0                	mov    %edx,%eax
}
 131:	5d                   	pop    %ebp
 132:	c3                   	ret    

00000133 <strlen>:

uint
strlen(char *s)
{
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 139:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 140:	eb 03                	jmp    145 <strlen+0x12>
 142:	ff 45 fc             	incl   -0x4(%ebp)
 145:	8b 55 fc             	mov    -0x4(%ebp),%edx
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	01 d0                	add    %edx,%eax
 14d:	8a 00                	mov    (%eax),%al
 14f:	84 c0                	test   %al,%al
 151:	75 ef                	jne    142 <strlen+0xf>
    ;
  return n;
 153:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 15e:	8b 45 10             	mov    0x10(%ebp),%eax
 161:	89 44 24 08          	mov    %eax,0x8(%esp)
 165:	8b 45 0c             	mov    0xc(%ebp),%eax
 168:	89 44 24 04          	mov    %eax,0x4(%esp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	89 04 24             	mov    %eax,(%esp)
 172:	e8 31 ff ff ff       	call   a8 <stosb>
  return dst;
 177:	8b 45 08             	mov    0x8(%ebp),%eax
}
 17a:	c9                   	leave  
 17b:	c3                   	ret    

0000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	83 ec 04             	sub    $0x4,%esp
 182:	8b 45 0c             	mov    0xc(%ebp),%eax
 185:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 188:	eb 12                	jmp    19c <strchr+0x20>
    if(*s == c)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	8a 00                	mov    (%eax),%al
 18f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 192:	75 05                	jne    199 <strchr+0x1d>
      return (char*)s;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	eb 11                	jmp    1aa <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 199:	ff 45 08             	incl   0x8(%ebp)
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	8a 00                	mov    (%eax),%al
 1a1:	84 c0                	test   %al,%al
 1a3:	75 e5                	jne    18a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <gets>:

char*
gets(char *buf, int max)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b9:	eb 49                	jmp    204 <gets+0x58>
    cc = read(0, &c, 1);
 1bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1c2:	00 
 1c3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1d1:	e8 3e 01 00 00       	call   314 <read>
 1d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1dd:	7f 02                	jg     1e1 <gets+0x35>
      break;
 1df:	eb 2c                	jmp    20d <gets+0x61>
    buf[i++] = c;
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	8d 50 01             	lea    0x1(%eax),%edx
 1e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ea:	89 c2                	mov    %eax,%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	01 c2                	add    %eax,%edx
 1f1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1f4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1f6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1f9:	3c 0a                	cmp    $0xa,%al
 1fb:	74 10                	je     20d <gets+0x61>
 1fd:	8a 45 ef             	mov    -0x11(%ebp),%al
 200:	3c 0d                	cmp    $0xd,%al
 202:	74 09                	je     20d <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 204:	8b 45 f4             	mov    -0xc(%ebp),%eax
 207:	40                   	inc    %eax
 208:	3b 45 0c             	cmp    0xc(%ebp),%eax
 20b:	7c ae                	jl     1bb <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 20d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	01 d0                	add    %edx,%eax
 215:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 218:	8b 45 08             	mov    0x8(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <stat>:

int
stat(char *n, struct stat *st)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 223:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 22a:	00 
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	89 04 24             	mov    %eax,(%esp)
 231:	e8 06 01 00 00       	call   33c <open>
 236:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 239:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 23d:	79 07                	jns    246 <stat+0x29>
    return -1;
 23f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 244:	eb 23                	jmp    269 <stat+0x4c>
  r = fstat(fd, st);
 246:	8b 45 0c             	mov    0xc(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 250:	89 04 24             	mov    %eax,(%esp)
 253:	e8 fc 00 00 00       	call   354 <fstat>
 258:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 25b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25e:	89 04 24             	mov    %eax,(%esp)
 261:	e8 be 00 00 00       	call   324 <close>
  return r;
 266:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 269:	c9                   	leave  
 26a:	c3                   	ret    

0000026b <atoi>:

int
atoi(const char *s)
{
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 271:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 278:	eb 24                	jmp    29e <atoi+0x33>
    n = n*10 + *s++ - '0';
 27a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27d:	89 d0                	mov    %edx,%eax
 27f:	c1 e0 02             	shl    $0x2,%eax
 282:	01 d0                	add    %edx,%eax
 284:	01 c0                	add    %eax,%eax
 286:	89 c1                	mov    %eax,%ecx
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	8d 50 01             	lea    0x1(%eax),%edx
 28e:	89 55 08             	mov    %edx,0x8(%ebp)
 291:	8a 00                	mov    (%eax),%al
 293:	0f be c0             	movsbl %al,%eax
 296:	01 c8                	add    %ecx,%eax
 298:	83 e8 30             	sub    $0x30,%eax
 29b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	8a 00                	mov    (%eax),%al
 2a3:	3c 2f                	cmp    $0x2f,%al
 2a5:	7e 09                	jle    2b0 <atoi+0x45>
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	8a 00                	mov    (%eax),%al
 2ac:	3c 39                	cmp    $0x39,%al
 2ae:	7e ca                	jle    27a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c7:	eb 16                	jmp    2df <memmove+0x2a>
    *dst++ = *src++;
 2c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2cc:	8d 50 01             	lea    0x1(%eax),%edx
 2cf:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2d5:	8d 4a 01             	lea    0x1(%edx),%ecx
 2d8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2db:	8a 12                	mov    (%edx),%dl
 2dd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2df:	8b 45 10             	mov    0x10(%ebp),%eax
 2e2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e5:	89 55 10             	mov    %edx,0x10(%ebp)
 2e8:	85 c0                	test   %eax,%eax
 2ea:	7f dd                	jg     2c9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ef:	c9                   	leave  
 2f0:	c3                   	ret    
 2f1:	90                   	nop
 2f2:	90                   	nop
 2f3:	90                   	nop

000002f4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f4:	b8 01 00 00 00       	mov    $0x1,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <exit>:
SYSCALL(exit)
 2fc:	b8 02 00 00 00       	mov    $0x2,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <wait>:
SYSCALL(wait)
 304:	b8 03 00 00 00       	mov    $0x3,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <pipe>:
SYSCALL(pipe)
 30c:	b8 04 00 00 00       	mov    $0x4,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <read>:
SYSCALL(read)
 314:	b8 05 00 00 00       	mov    $0x5,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <write>:
SYSCALL(write)
 31c:	b8 10 00 00 00       	mov    $0x10,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <close>:
SYSCALL(close)
 324:	b8 15 00 00 00       	mov    $0x15,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <kill>:
SYSCALL(kill)
 32c:	b8 06 00 00 00       	mov    $0x6,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <exec>:
SYSCALL(exec)
 334:	b8 07 00 00 00       	mov    $0x7,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <open>:
SYSCALL(open)
 33c:	b8 0f 00 00 00       	mov    $0xf,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <mknod>:
SYSCALL(mknod)
 344:	b8 11 00 00 00       	mov    $0x11,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <unlink>:
SYSCALL(unlink)
 34c:	b8 12 00 00 00       	mov    $0x12,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <fstat>:
SYSCALL(fstat)
 354:	b8 08 00 00 00       	mov    $0x8,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <link>:
SYSCALL(link)
 35c:	b8 13 00 00 00       	mov    $0x13,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <mkdir>:
SYSCALL(mkdir)
 364:	b8 14 00 00 00       	mov    $0x14,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <chdir>:
SYSCALL(chdir)
 36c:	b8 09 00 00 00       	mov    $0x9,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <dup>:
SYSCALL(dup)
 374:	b8 0a 00 00 00       	mov    $0xa,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <getpid>:
SYSCALL(getpid)
 37c:	b8 0b 00 00 00       	mov    $0xb,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <sbrk>:
SYSCALL(sbrk)
 384:	b8 0c 00 00 00       	mov    $0xc,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <sleep>:
SYSCALL(sleep)
 38c:	b8 0d 00 00 00       	mov    $0xd,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <uptime>:
SYSCALL(uptime)
 394:	b8 0e 00 00 00       	mov    $0xe,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <getticks>:
SYSCALL(getticks)
 39c:	b8 16 00 00 00       	mov    $0x16,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <get_name>:
SYSCALL(get_name)
 3a4:	b8 17 00 00 00       	mov    $0x17,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <get_max_proc>:
SYSCALL(get_max_proc)
 3ac:	b8 18 00 00 00       	mov    $0x18,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <get_max_mem>:
SYSCALL(get_max_mem)
 3b4:	b8 19 00 00 00       	mov    $0x19,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <get_max_disk>:
SYSCALL(get_max_disk)
 3bc:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <get_curr_proc>:
SYSCALL(get_curr_proc)
 3c4:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <get_curr_mem>:
SYSCALL(get_curr_mem)
 3cc:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <get_curr_disk>:
SYSCALL(get_curr_disk)
 3d4:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <set_name>:
SYSCALL(set_name)
 3dc:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <set_max_mem>:
SYSCALL(set_max_mem)
 3e4:	b8 1f 00 00 00       	mov    $0x1f,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <set_max_disk>:
SYSCALL(set_max_disk)
 3ec:	b8 20 00 00 00       	mov    $0x20,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <set_max_proc>:
SYSCALL(set_max_proc)
 3f4:	b8 21 00 00 00       	mov    $0x21,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <set_curr_mem>:
SYSCALL(set_curr_mem)
 3fc:	b8 22 00 00 00       	mov    $0x22,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <set_curr_disk>:
SYSCALL(set_curr_disk)
 404:	b8 23 00 00 00       	mov    $0x23,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <set_curr_proc>:
SYSCALL(set_curr_proc)
 40c:	b8 24 00 00 00       	mov    $0x24,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <find>:
SYSCALL(find)
 414:	b8 25 00 00 00       	mov    $0x25,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <is_full>:
SYSCALL(is_full)
 41c:	b8 26 00 00 00       	mov    $0x26,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <container_init>:
SYSCALL(container_init)
 424:	b8 27 00 00 00       	mov    $0x27,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <cont_proc_set>:
SYSCALL(cont_proc_set)
 42c:	b8 28 00 00 00       	mov    $0x28,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <ps>:
SYSCALL(ps)
 434:	b8 29 00 00 00       	mov    $0x29,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 43c:	b8 2a 00 00 00       	mov    $0x2a,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <set_root_inode>:
SYSCALL(set_root_inode)
 444:	b8 2b 00 00 00       	mov    $0x2b,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <cstop>:
 44c:	b8 2c 00 00 00       	mov    $0x2c,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	83 ec 18             	sub    $0x18,%esp
 45a:	8b 45 0c             	mov    0xc(%ebp),%eax
 45d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 460:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 467:	00 
 468:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46b:	89 44 24 04          	mov    %eax,0x4(%esp)
 46f:	8b 45 08             	mov    0x8(%ebp),%eax
 472:	89 04 24             	mov    %eax,(%esp)
 475:	e8 a2 fe ff ff       	call   31c <write>
}
 47a:	c9                   	leave  
 47b:	c3                   	ret    

0000047c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	56                   	push   %esi
 480:	53                   	push   %ebx
 481:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 484:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 48f:	74 17                	je     4a8 <printint+0x2c>
 491:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 495:	79 11                	jns    4a8 <printint+0x2c>
    neg = 1;
 497:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49e:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a1:	f7 d8                	neg    %eax
 4a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a6:	eb 06                	jmp    4ae <printint+0x32>
  } else {
    x = xx;
 4a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b8:	8d 41 01             	lea    0x1(%ecx),%eax
 4bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4be:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c4:	ba 00 00 00 00       	mov    $0x0,%edx
 4c9:	f7 f3                	div    %ebx
 4cb:	89 d0                	mov    %edx,%eax
 4cd:	8a 80 74 0b 00 00    	mov    0xb74(%eax),%al
 4d3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d7:	8b 75 10             	mov    0x10(%ebp),%esi
 4da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4dd:	ba 00 00 00 00       	mov    $0x0,%edx
 4e2:	f7 f6                	div    %esi
 4e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4eb:	75 c8                	jne    4b5 <printint+0x39>
  if(neg)
 4ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f1:	74 10                	je     503 <printint+0x87>
    buf[i++] = '-';
 4f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f6:	8d 50 01             	lea    0x1(%eax),%edx
 4f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4fc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 501:	eb 1e                	jmp    521 <printint+0xa5>
 503:	eb 1c                	jmp    521 <printint+0xa5>
    putc(fd, buf[i]);
 505:	8d 55 dc             	lea    -0x24(%ebp),%edx
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	01 d0                	add    %edx,%eax
 50d:	8a 00                	mov    (%eax),%al
 50f:	0f be c0             	movsbl %al,%eax
 512:	89 44 24 04          	mov    %eax,0x4(%esp)
 516:	8b 45 08             	mov    0x8(%ebp),%eax
 519:	89 04 24             	mov    %eax,(%esp)
 51c:	e8 33 ff ff ff       	call   454 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 521:	ff 4d f4             	decl   -0xc(%ebp)
 524:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 528:	79 db                	jns    505 <printint+0x89>
    putc(fd, buf[i]);
}
 52a:	83 c4 30             	add    $0x30,%esp
 52d:	5b                   	pop    %ebx
 52e:	5e                   	pop    %esi
 52f:	5d                   	pop    %ebp
 530:	c3                   	ret    

00000531 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 531:	55                   	push   %ebp
 532:	89 e5                	mov    %esp,%ebp
 534:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 537:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 53e:	8d 45 0c             	lea    0xc(%ebp),%eax
 541:	83 c0 04             	add    $0x4,%eax
 544:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 547:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 54e:	e9 77 01 00 00       	jmp    6ca <printf+0x199>
    c = fmt[i] & 0xff;
 553:	8b 55 0c             	mov    0xc(%ebp),%edx
 556:	8b 45 f0             	mov    -0x10(%ebp),%eax
 559:	01 d0                	add    %edx,%eax
 55b:	8a 00                	mov    (%eax),%al
 55d:	0f be c0             	movsbl %al,%eax
 560:	25 ff 00 00 00       	and    $0xff,%eax
 565:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 568:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56c:	75 2c                	jne    59a <printf+0x69>
      if(c == '%'){
 56e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 572:	75 0c                	jne    580 <printf+0x4f>
        state = '%';
 574:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 57b:	e9 47 01 00 00       	jmp    6c7 <printf+0x196>
      } else {
        putc(fd, c);
 580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 583:	0f be c0             	movsbl %al,%eax
 586:	89 44 24 04          	mov    %eax,0x4(%esp)
 58a:	8b 45 08             	mov    0x8(%ebp),%eax
 58d:	89 04 24             	mov    %eax,(%esp)
 590:	e8 bf fe ff ff       	call   454 <putc>
 595:	e9 2d 01 00 00       	jmp    6c7 <printf+0x196>
      }
    } else if(state == '%'){
 59a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 59e:	0f 85 23 01 00 00    	jne    6c7 <printf+0x196>
      if(c == 'd'){
 5a4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a8:	75 2d                	jne    5d7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 5aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ad:	8b 00                	mov    (%eax),%eax
 5af:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5b6:	00 
 5b7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5be:	00 
 5bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c3:	8b 45 08             	mov    0x8(%ebp),%eax
 5c6:	89 04 24             	mov    %eax,(%esp)
 5c9:	e8 ae fe ff ff       	call   47c <printint>
        ap++;
 5ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d2:	e9 e9 00 00 00       	jmp    6c0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5d7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5db:	74 06                	je     5e3 <printf+0xb2>
 5dd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e1:	75 2d                	jne    610 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e6:	8b 00                	mov    (%eax),%eax
 5e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5ef:	00 
 5f0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5f7:	00 
 5f8:	89 44 24 04          	mov    %eax,0x4(%esp)
 5fc:	8b 45 08             	mov    0x8(%ebp),%eax
 5ff:	89 04 24             	mov    %eax,(%esp)
 602:	e8 75 fe ff ff       	call   47c <printint>
        ap++;
 607:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 60b:	e9 b0 00 00 00       	jmp    6c0 <printf+0x18f>
      } else if(c == 's'){
 610:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 614:	75 42                	jne    658 <printf+0x127>
        s = (char*)*ap;
 616:	8b 45 e8             	mov    -0x18(%ebp),%eax
 619:	8b 00                	mov    (%eax),%eax
 61b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 61e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 622:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 626:	75 09                	jne    631 <printf+0x100>
          s = "(null)";
 628:	c7 45 f4 28 09 00 00 	movl   $0x928,-0xc(%ebp)
        while(*s != 0){
 62f:	eb 1c                	jmp    64d <printf+0x11c>
 631:	eb 1a                	jmp    64d <printf+0x11c>
          putc(fd, *s);
 633:	8b 45 f4             	mov    -0xc(%ebp),%eax
 636:	8a 00                	mov    (%eax),%al
 638:	0f be c0             	movsbl %al,%eax
 63b:	89 44 24 04          	mov    %eax,0x4(%esp)
 63f:	8b 45 08             	mov    0x8(%ebp),%eax
 642:	89 04 24             	mov    %eax,(%esp)
 645:	e8 0a fe ff ff       	call   454 <putc>
          s++;
 64a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 64d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 650:	8a 00                	mov    (%eax),%al
 652:	84 c0                	test   %al,%al
 654:	75 dd                	jne    633 <printf+0x102>
 656:	eb 68                	jmp    6c0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 658:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 65c:	75 1d                	jne    67b <printf+0x14a>
        putc(fd, *ap);
 65e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	0f be c0             	movsbl %al,%eax
 666:	89 44 24 04          	mov    %eax,0x4(%esp)
 66a:	8b 45 08             	mov    0x8(%ebp),%eax
 66d:	89 04 24             	mov    %eax,(%esp)
 670:	e8 df fd ff ff       	call   454 <putc>
        ap++;
 675:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 679:	eb 45                	jmp    6c0 <printf+0x18f>
      } else if(c == '%'){
 67b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67f:	75 17                	jne    698 <printf+0x167>
        putc(fd, c);
 681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 684:	0f be c0             	movsbl %al,%eax
 687:	89 44 24 04          	mov    %eax,0x4(%esp)
 68b:	8b 45 08             	mov    0x8(%ebp),%eax
 68e:	89 04 24             	mov    %eax,(%esp)
 691:	e8 be fd ff ff       	call   454 <putc>
 696:	eb 28                	jmp    6c0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 698:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 69f:	00 
 6a0:	8b 45 08             	mov    0x8(%ebp),%eax
 6a3:	89 04 24             	mov    %eax,(%esp)
 6a6:	e8 a9 fd ff ff       	call   454 <putc>
        putc(fd, c);
 6ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ae:	0f be c0             	movsbl %al,%eax
 6b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	89 04 24             	mov    %eax,(%esp)
 6bb:	e8 94 fd ff ff       	call   454 <putc>
      }
      state = 0;
 6c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6c7:	ff 45 f0             	incl   -0x10(%ebp)
 6ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d0:	01 d0                	add    %edx,%eax
 6d2:	8a 00                	mov    (%eax),%al
 6d4:	84 c0                	test   %al,%al
 6d6:	0f 85 77 fe ff ff    	jne    553 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6dc:	c9                   	leave  
 6dd:	c3                   	ret    
 6de:	90                   	nop
 6df:	90                   	nop

000006e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	83 e8 08             	sub    $0x8,%eax
 6ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ef:	a1 90 0b 00 00       	mov    0xb90,%eax
 6f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f7:	eb 24                	jmp    71d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 701:	77 12                	ja     715 <free+0x35>
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 709:	77 24                	ja     72f <free+0x4f>
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	8b 00                	mov    (%eax),%eax
 710:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 713:	77 1a                	ja     72f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 715:	8b 45 fc             	mov    -0x4(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 71d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 720:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 723:	76 d4                	jbe    6f9 <free+0x19>
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 00                	mov    (%eax),%eax
 72a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72d:	76 ca                	jbe    6f9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 72f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 73c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73f:	01 c2                	add    %eax,%edx
 741:	8b 45 fc             	mov    -0x4(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	39 c2                	cmp    %eax,%edx
 748:	75 24                	jne    76e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 74a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74d:	8b 50 04             	mov    0x4(%eax),%edx
 750:	8b 45 fc             	mov    -0x4(%ebp),%eax
 753:	8b 00                	mov    (%eax),%eax
 755:	8b 40 04             	mov    0x4(%eax),%eax
 758:	01 c2                	add    %eax,%edx
 75a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 760:	8b 45 fc             	mov    -0x4(%ebp),%eax
 763:	8b 00                	mov    (%eax),%eax
 765:	8b 10                	mov    (%eax),%edx
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	89 10                	mov    %edx,(%eax)
 76c:	eb 0a                	jmp    778 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 76e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 771:	8b 10                	mov    (%eax),%edx
 773:	8b 45 f8             	mov    -0x8(%ebp),%eax
 776:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 778:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77b:	8b 40 04             	mov    0x4(%eax),%eax
 77e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	01 d0                	add    %edx,%eax
 78a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 78d:	75 20                	jne    7af <free+0xcf>
    p->s.size += bp->s.size;
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	8b 50 04             	mov    0x4(%eax),%edx
 795:	8b 45 f8             	mov    -0x8(%ebp),%eax
 798:	8b 40 04             	mov    0x4(%eax),%eax
 79b:	01 c2                	add    %eax,%edx
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a6:	8b 10                	mov    (%eax),%edx
 7a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ab:	89 10                	mov    %edx,(%eax)
 7ad:	eb 08                	jmp    7b7 <free+0xd7>
  } else
    p->s.ptr = bp;
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7b5:	89 10                	mov    %edx,(%eax)
  freep = p;
 7b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ba:	a3 90 0b 00 00       	mov    %eax,0xb90
}
 7bf:	c9                   	leave  
 7c0:	c3                   	ret    

000007c1 <morecore>:

static Header*
morecore(uint nu)
{
 7c1:	55                   	push   %ebp
 7c2:	89 e5                	mov    %esp,%ebp
 7c4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7c7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ce:	77 07                	ja     7d7 <morecore+0x16>
    nu = 4096;
 7d0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7d7:	8b 45 08             	mov    0x8(%ebp),%eax
 7da:	c1 e0 03             	shl    $0x3,%eax
 7dd:	89 04 24             	mov    %eax,(%esp)
 7e0:	e8 9f fb ff ff       	call   384 <sbrk>
 7e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7e8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7ec:	75 07                	jne    7f5 <morecore+0x34>
    return 0;
 7ee:	b8 00 00 00 00       	mov    $0x0,%eax
 7f3:	eb 22                	jmp    817 <morecore+0x56>
  hp = (Header*)p;
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fe:	8b 55 08             	mov    0x8(%ebp),%edx
 801:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 804:	8b 45 f0             	mov    -0x10(%ebp),%eax
 807:	83 c0 08             	add    $0x8,%eax
 80a:	89 04 24             	mov    %eax,(%esp)
 80d:	e8 ce fe ff ff       	call   6e0 <free>
  return freep;
 812:	a1 90 0b 00 00       	mov    0xb90,%eax
}
 817:	c9                   	leave  
 818:	c3                   	ret    

00000819 <malloc>:

void*
malloc(uint nbytes)
{
 819:	55                   	push   %ebp
 81a:	89 e5                	mov    %esp,%ebp
 81c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81f:	8b 45 08             	mov    0x8(%ebp),%eax
 822:	83 c0 07             	add    $0x7,%eax
 825:	c1 e8 03             	shr    $0x3,%eax
 828:	40                   	inc    %eax
 829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 82c:	a1 90 0b 00 00       	mov    0xb90,%eax
 831:	89 45 f0             	mov    %eax,-0x10(%ebp)
 834:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 838:	75 23                	jne    85d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 83a:	c7 45 f0 88 0b 00 00 	movl   $0xb88,-0x10(%ebp)
 841:	8b 45 f0             	mov    -0x10(%ebp),%eax
 844:	a3 90 0b 00 00       	mov    %eax,0xb90
 849:	a1 90 0b 00 00       	mov    0xb90,%eax
 84e:	a3 88 0b 00 00       	mov    %eax,0xb88
    base.s.size = 0;
 853:	c7 05 8c 0b 00 00 00 	movl   $0x0,0xb8c
 85a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 860:	8b 00                	mov    (%eax),%eax
 862:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	8b 40 04             	mov    0x4(%eax),%eax
 86b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86e:	72 4d                	jb     8bd <malloc+0xa4>
      if(p->s.size == nunits)
 870:	8b 45 f4             	mov    -0xc(%ebp),%eax
 873:	8b 40 04             	mov    0x4(%eax),%eax
 876:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 879:	75 0c                	jne    887 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	8b 10                	mov    (%eax),%edx
 880:	8b 45 f0             	mov    -0x10(%ebp),%eax
 883:	89 10                	mov    %edx,(%eax)
 885:	eb 26                	jmp    8ad <malloc+0x94>
      else {
        p->s.size -= nunits;
 887:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88a:	8b 40 04             	mov    0x4(%eax),%eax
 88d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 890:	89 c2                	mov    %eax,%edx
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 898:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89b:	8b 40 04             	mov    0x4(%eax),%eax
 89e:	c1 e0 03             	shl    $0x3,%eax
 8a1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8aa:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b0:	a3 90 0b 00 00       	mov    %eax,0xb90
      return (void*)(p + 1);
 8b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b8:	83 c0 08             	add    $0x8,%eax
 8bb:	eb 38                	jmp    8f5 <malloc+0xdc>
    }
    if(p == freep)
 8bd:	a1 90 0b 00 00       	mov    0xb90,%eax
 8c2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8c5:	75 1b                	jne    8e2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ca:	89 04 24             	mov    %eax,(%esp)
 8cd:	e8 ef fe ff ff       	call   7c1 <morecore>
 8d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d9:	75 07                	jne    8e2 <malloc+0xc9>
        return 0;
 8db:	b8 00 00 00 00       	mov    $0x0,%eax
 8e0:	eb 13                	jmp    8f5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8eb:	8b 00                	mov    (%eax),%eax
 8ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8f0:	e9 70 ff ff ff       	jmp    865 <malloc+0x4c>
}
 8f5:	c9                   	leave  
 8f6:	c3                   	ret    
