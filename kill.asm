
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 cf 08 00 	movl   $0x8cf,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 e6 04 00 00       	call   509 <printf>
    exit();
  23:	e8 94 02 00 00       	call   2bc <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 26                	jmp    58 <main+0x58>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 df 01 00 00       	call   22b <atoi>
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 98 02 00 00       	call   2ec <kill>

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  54:	ff 44 24 1c          	incl   0x1c(%esp)
  58:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5c:	3b 45 08             	cmp    0x8(%ebp),%eax
  5f:	7c d1                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  61:	e8 56 02 00 00       	call   2bc <exit>
  66:	90                   	nop
  67:	90                   	nop

00000068 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	57                   	push   %edi
  6c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  70:	8b 55 10             	mov    0x10(%ebp),%edx
  73:	8b 45 0c             	mov    0xc(%ebp),%eax
  76:	89 cb                	mov    %ecx,%ebx
  78:	89 df                	mov    %ebx,%edi
  7a:	89 d1                	mov    %edx,%ecx
  7c:	fc                   	cld    
  7d:	f3 aa                	rep stos %al,%es:(%edi)
  7f:	89 ca                	mov    %ecx,%edx
  81:	89 fb                	mov    %edi,%ebx
  83:	89 5d 08             	mov    %ebx,0x8(%ebp)
  86:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  89:	5b                   	pop    %ebx
  8a:	5f                   	pop    %edi
  8b:	5d                   	pop    %ebp
  8c:	c3                   	ret    

0000008d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  99:	90                   	nop
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	8d 50 01             	lea    0x1(%eax),%edx
  a0:	89 55 08             	mov    %edx,0x8(%ebp)
  a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  a6:	8d 4a 01             	lea    0x1(%edx),%ecx
  a9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ac:	8a 12                	mov    (%edx),%dl
  ae:	88 10                	mov    %dl,(%eax)
  b0:	8a 00                	mov    (%eax),%al
  b2:	84 c0                	test   %al,%al
  b4:	75 e4                	jne    9a <strcpy+0xd>
    ;
  return os;
  b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b9:	c9                   	leave  
  ba:	c3                   	ret    

000000bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  be:	eb 06                	jmp    c6 <strcmp+0xb>
    p++, q++;
  c0:	ff 45 08             	incl   0x8(%ebp)
  c3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c6:	8b 45 08             	mov    0x8(%ebp),%eax
  c9:	8a 00                	mov    (%eax),%al
  cb:	84 c0                	test   %al,%al
  cd:	74 0e                	je     dd <strcmp+0x22>
  cf:	8b 45 08             	mov    0x8(%ebp),%eax
  d2:	8a 10                	mov    (%eax),%dl
  d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  d7:	8a 00                	mov    (%eax),%al
  d9:	38 c2                	cmp    %al,%dl
  db:	74 e3                	je     c0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	8a 00                	mov    (%eax),%al
  e2:	0f b6 d0             	movzbl %al,%edx
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	8a 00                	mov    (%eax),%al
  ea:	0f b6 c0             	movzbl %al,%eax
  ed:	29 c2                	sub    %eax,%edx
  ef:	89 d0                	mov    %edx,%eax
}
  f1:	5d                   	pop    %ebp
  f2:	c3                   	ret    

000000f3 <strlen>:

uint
strlen(char *s)
{
  f3:	55                   	push   %ebp
  f4:	89 e5                	mov    %esp,%ebp
  f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 100:	eb 03                	jmp    105 <strlen+0x12>
 102:	ff 45 fc             	incl   -0x4(%ebp)
 105:	8b 55 fc             	mov    -0x4(%ebp),%edx
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	01 d0                	add    %edx,%eax
 10d:	8a 00                	mov    (%eax),%al
 10f:	84 c0                	test   %al,%al
 111:	75 ef                	jne    102 <strlen+0xf>
    ;
  return n;
 113:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 116:	c9                   	leave  
 117:	c3                   	ret    

00000118 <memset>:

void*
memset(void *dst, int c, uint n)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 11e:	8b 45 10             	mov    0x10(%ebp),%eax
 121:	89 44 24 08          	mov    %eax,0x8(%esp)
 125:	8b 45 0c             	mov    0xc(%ebp),%eax
 128:	89 44 24 04          	mov    %eax,0x4(%esp)
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 31 ff ff ff       	call   68 <stosb>
  return dst;
 137:	8b 45 08             	mov    0x8(%ebp),%eax
}
 13a:	c9                   	leave  
 13b:	c3                   	ret    

0000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	83 ec 04             	sub    $0x4,%esp
 142:	8b 45 0c             	mov    0xc(%ebp),%eax
 145:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 148:	eb 12                	jmp    15c <strchr+0x20>
    if(*s == c)
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
 14d:	8a 00                	mov    (%eax),%al
 14f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 152:	75 05                	jne    159 <strchr+0x1d>
      return (char*)s;
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	eb 11                	jmp    16a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 159:	ff 45 08             	incl   0x8(%ebp)
 15c:	8b 45 08             	mov    0x8(%ebp),%eax
 15f:	8a 00                	mov    (%eax),%al
 161:	84 c0                	test   %al,%al
 163:	75 e5                	jne    14a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 165:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16a:	c9                   	leave  
 16b:	c3                   	ret    

0000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 179:	eb 49                	jmp    1c4 <gets+0x58>
    cc = read(0, &c, 1);
 17b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 182:	00 
 183:	8d 45 ef             	lea    -0x11(%ebp),%eax
 186:	89 44 24 04          	mov    %eax,0x4(%esp)
 18a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 191:	e8 3e 01 00 00       	call   2d4 <read>
 196:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 199:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 19d:	7f 02                	jg     1a1 <gets+0x35>
      break;
 19f:	eb 2c                	jmp    1cd <gets+0x61>
    buf[i++] = c;
 1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a4:	8d 50 01             	lea    0x1(%eax),%edx
 1a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1aa:	89 c2                	mov    %eax,%edx
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	01 c2                	add    %eax,%edx
 1b1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1b6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b9:	3c 0a                	cmp    $0xa,%al
 1bb:	74 10                	je     1cd <gets+0x61>
 1bd:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c0:	3c 0d                	cmp    $0xd,%al
 1c2:	74 09                	je     1cd <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c7:	40                   	inc    %eax
 1c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1cb:	7c ae                	jl     17b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 d0                	add    %edx,%eax
 1d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1db:	c9                   	leave  
 1dc:	c3                   	ret    

000001dd <stat>:

int
stat(char *n, struct stat *st)
{
 1dd:	55                   	push   %ebp
 1de:	89 e5                	mov    %esp,%ebp
 1e0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1ea:	00 
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ee:	89 04 24             	mov    %eax,(%esp)
 1f1:	e8 06 01 00 00       	call   2fc <open>
 1f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1fd:	79 07                	jns    206 <stat+0x29>
    return -1;
 1ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 204:	eb 23                	jmp    229 <stat+0x4c>
  r = fstat(fd, st);
 206:	8b 45 0c             	mov    0xc(%ebp),%eax
 209:	89 44 24 04          	mov    %eax,0x4(%esp)
 20d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 210:	89 04 24             	mov    %eax,(%esp)
 213:	e8 fc 00 00 00       	call   314 <fstat>
 218:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 21b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21e:	89 04 24             	mov    %eax,(%esp)
 221:	e8 be 00 00 00       	call   2e4 <close>
  return r;
 226:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 229:	c9                   	leave  
 22a:	c3                   	ret    

0000022b <atoi>:

int
atoi(const char *s)
{
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 231:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 238:	eb 24                	jmp    25e <atoi+0x33>
    n = n*10 + *s++ - '0';
 23a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23d:	89 d0                	mov    %edx,%eax
 23f:	c1 e0 02             	shl    $0x2,%eax
 242:	01 d0                	add    %edx,%eax
 244:	01 c0                	add    %eax,%eax
 246:	89 c1                	mov    %eax,%ecx
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	8d 50 01             	lea    0x1(%eax),%edx
 24e:	89 55 08             	mov    %edx,0x8(%ebp)
 251:	8a 00                	mov    (%eax),%al
 253:	0f be c0             	movsbl %al,%eax
 256:	01 c8                	add    %ecx,%eax
 258:	83 e8 30             	sub    $0x30,%eax
 25b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	8a 00                	mov    (%eax),%al
 263:	3c 2f                	cmp    $0x2f,%al
 265:	7e 09                	jle    270 <atoi+0x45>
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	8a 00                	mov    (%eax),%al
 26c:	3c 39                	cmp    $0x39,%al
 26e:	7e ca                	jle    23a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 270:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 281:	8b 45 0c             	mov    0xc(%ebp),%eax
 284:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 287:	eb 16                	jmp    29f <memmove+0x2a>
    *dst++ = *src++;
 289:	8b 45 fc             	mov    -0x4(%ebp),%eax
 28c:	8d 50 01             	lea    0x1(%eax),%edx
 28f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 292:	8b 55 f8             	mov    -0x8(%ebp),%edx
 295:	8d 4a 01             	lea    0x1(%edx),%ecx
 298:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 29b:	8a 12                	mov    (%edx),%dl
 29d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 29f:	8b 45 10             	mov    0x10(%ebp),%eax
 2a2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a5:	89 55 10             	mov    %edx,0x10(%ebp)
 2a8:	85 c0                	test   %eax,%eax
 2aa:	7f dd                	jg     289 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave  
 2b0:	c3                   	ret    
 2b1:	90                   	nop
 2b2:	90                   	nop
 2b3:	90                   	nop

000002b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b4:	b8 01 00 00 00       	mov    $0x1,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <exit>:
SYSCALL(exit)
 2bc:	b8 02 00 00 00       	mov    $0x2,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <wait>:
SYSCALL(wait)
 2c4:	b8 03 00 00 00       	mov    $0x3,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <pipe>:
SYSCALL(pipe)
 2cc:	b8 04 00 00 00       	mov    $0x4,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <read>:
SYSCALL(read)
 2d4:	b8 05 00 00 00       	mov    $0x5,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <write>:
SYSCALL(write)
 2dc:	b8 10 00 00 00       	mov    $0x10,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <close>:
SYSCALL(close)
 2e4:	b8 15 00 00 00       	mov    $0x15,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <kill>:
SYSCALL(kill)
 2ec:	b8 06 00 00 00       	mov    $0x6,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <exec>:
SYSCALL(exec)
 2f4:	b8 07 00 00 00       	mov    $0x7,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <open>:
SYSCALL(open)
 2fc:	b8 0f 00 00 00       	mov    $0xf,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <mknod>:
SYSCALL(mknod)
 304:	b8 11 00 00 00       	mov    $0x11,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <unlink>:
SYSCALL(unlink)
 30c:	b8 12 00 00 00       	mov    $0x12,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <fstat>:
SYSCALL(fstat)
 314:	b8 08 00 00 00       	mov    $0x8,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <link>:
SYSCALL(link)
 31c:	b8 13 00 00 00       	mov    $0x13,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <mkdir>:
SYSCALL(mkdir)
 324:	b8 14 00 00 00       	mov    $0x14,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <chdir>:
SYSCALL(chdir)
 32c:	b8 09 00 00 00       	mov    $0x9,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <dup>:
SYSCALL(dup)
 334:	b8 0a 00 00 00       	mov    $0xa,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <getpid>:
SYSCALL(getpid)
 33c:	b8 0b 00 00 00       	mov    $0xb,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <sbrk>:
SYSCALL(sbrk)
 344:	b8 0c 00 00 00       	mov    $0xc,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <sleep>:
SYSCALL(sleep)
 34c:	b8 0d 00 00 00       	mov    $0xd,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <uptime>:
SYSCALL(uptime)
 354:	b8 0e 00 00 00       	mov    $0xe,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <getticks>:
SYSCALL(getticks)
 35c:	b8 16 00 00 00       	mov    $0x16,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <get_name>:
SYSCALL(get_name)
 364:	b8 17 00 00 00       	mov    $0x17,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <get_max_proc>:
SYSCALL(get_max_proc)
 36c:	b8 18 00 00 00       	mov    $0x18,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <get_max_mem>:
SYSCALL(get_max_mem)
 374:	b8 19 00 00 00       	mov    $0x19,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <get_max_disk>:
SYSCALL(get_max_disk)
 37c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <get_curr_proc>:
SYSCALL(get_curr_proc)
 384:	b8 1b 00 00 00       	mov    $0x1b,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <get_curr_mem>:
SYSCALL(get_curr_mem)
 38c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <get_curr_disk>:
SYSCALL(get_curr_disk)
 394:	b8 1d 00 00 00       	mov    $0x1d,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <set_name>:
SYSCALL(set_name)
 39c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <set_max_mem>:
SYSCALL(set_max_mem)
 3a4:	b8 1f 00 00 00       	mov    $0x1f,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <set_max_disk>:
SYSCALL(set_max_disk)
 3ac:	b8 20 00 00 00       	mov    $0x20,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <set_max_proc>:
SYSCALL(set_max_proc)
 3b4:	b8 21 00 00 00       	mov    $0x21,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <set_curr_mem>:
SYSCALL(set_curr_mem)
 3bc:	b8 22 00 00 00       	mov    $0x22,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <set_curr_disk>:
SYSCALL(set_curr_disk)
 3c4:	b8 23 00 00 00       	mov    $0x23,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <set_curr_proc>:
SYSCALL(set_curr_proc)
 3cc:	b8 24 00 00 00       	mov    $0x24,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <find>:
SYSCALL(find)
 3d4:	b8 25 00 00 00       	mov    $0x25,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <is_full>:
SYSCALL(is_full)
 3dc:	b8 26 00 00 00       	mov    $0x26,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <container_init>:
SYSCALL(container_init)
 3e4:	b8 27 00 00 00       	mov    $0x27,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <cont_proc_set>:
SYSCALL(cont_proc_set)
 3ec:	b8 28 00 00 00       	mov    $0x28,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <ps>:
SYSCALL(ps)
 3f4:	b8 29 00 00 00       	mov    $0x29,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 3fc:	b8 2a 00 00 00       	mov    $0x2a,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <set_root_inode>:
SYSCALL(set_root_inode)
 404:	b8 2b 00 00 00       	mov    $0x2b,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <cstop>:
SYSCALL(cstop)
 40c:	b8 2c 00 00 00       	mov    $0x2c,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <df>:
SYSCALL(df)
 414:	b8 2d 00 00 00       	mov    $0x2d,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <max_containers>:
SYSCALL(max_containers)
 41c:	b8 2e 00 00 00       	mov    $0x2e,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <container_reset>:
SYSCALL(container_reset)
 424:	b8 2f 00 00 00       	mov    $0x2f,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	83 ec 18             	sub    $0x18,%esp
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 438:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43f:	00 
 440:	8d 45 f4             	lea    -0xc(%ebp),%eax
 443:	89 44 24 04          	mov    %eax,0x4(%esp)
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	89 04 24             	mov    %eax,(%esp)
 44d:	e8 8a fe ff ff       	call   2dc <write>
}
 452:	c9                   	leave  
 453:	c3                   	ret    

00000454 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	56                   	push   %esi
 458:	53                   	push   %ebx
 459:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 45c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 463:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 467:	74 17                	je     480 <printint+0x2c>
 469:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 46d:	79 11                	jns    480 <printint+0x2c>
    neg = 1;
 46f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 476:	8b 45 0c             	mov    0xc(%ebp),%eax
 479:	f7 d8                	neg    %eax
 47b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47e:	eb 06                	jmp    486 <printint+0x32>
  } else {
    x = xx;
 480:	8b 45 0c             	mov    0xc(%ebp),%eax
 483:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 486:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 48d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 490:	8d 41 01             	lea    0x1(%ecx),%eax
 493:	89 45 f4             	mov    %eax,-0xc(%ebp)
 496:	8b 5d 10             	mov    0x10(%ebp),%ebx
 499:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49c:	ba 00 00 00 00       	mov    $0x0,%edx
 4a1:	f7 f3                	div    %ebx
 4a3:	89 d0                	mov    %edx,%eax
 4a5:	8a 80 30 0b 00 00    	mov    0xb30(%eax),%al
 4ab:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4af:	8b 75 10             	mov    0x10(%ebp),%esi
 4b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ba:	f7 f6                	div    %esi
 4bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c3:	75 c8                	jne    48d <printint+0x39>
  if(neg)
 4c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c9:	74 10                	je     4db <printint+0x87>
    buf[i++] = '-';
 4cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ce:	8d 50 01             	lea    0x1(%eax),%edx
 4d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4d9:	eb 1e                	jmp    4f9 <printint+0xa5>
 4db:	eb 1c                	jmp    4f9 <printint+0xa5>
    putc(fd, buf[i]);
 4dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e3:	01 d0                	add    %edx,%eax
 4e5:	8a 00                	mov    (%eax),%al
 4e7:	0f be c0             	movsbl %al,%eax
 4ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	89 04 24             	mov    %eax,(%esp)
 4f4:	e8 33 ff ff ff       	call   42c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f9:	ff 4d f4             	decl   -0xc(%ebp)
 4fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 500:	79 db                	jns    4dd <printint+0x89>
    putc(fd, buf[i]);
}
 502:	83 c4 30             	add    $0x30,%esp
 505:	5b                   	pop    %ebx
 506:	5e                   	pop    %esi
 507:	5d                   	pop    %ebp
 508:	c3                   	ret    

00000509 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 509:	55                   	push   %ebp
 50a:	89 e5                	mov    %esp,%ebp
 50c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 50f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 516:	8d 45 0c             	lea    0xc(%ebp),%eax
 519:	83 c0 04             	add    $0x4,%eax
 51c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 51f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 526:	e9 77 01 00 00       	jmp    6a2 <printf+0x199>
    c = fmt[i] & 0xff;
 52b:	8b 55 0c             	mov    0xc(%ebp),%edx
 52e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 531:	01 d0                	add    %edx,%eax
 533:	8a 00                	mov    (%eax),%al
 535:	0f be c0             	movsbl %al,%eax
 538:	25 ff 00 00 00       	and    $0xff,%eax
 53d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 540:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 544:	75 2c                	jne    572 <printf+0x69>
      if(c == '%'){
 546:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54a:	75 0c                	jne    558 <printf+0x4f>
        state = '%';
 54c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 553:	e9 47 01 00 00       	jmp    69f <printf+0x196>
      } else {
        putc(fd, c);
 558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55b:	0f be c0             	movsbl %al,%eax
 55e:	89 44 24 04          	mov    %eax,0x4(%esp)
 562:	8b 45 08             	mov    0x8(%ebp),%eax
 565:	89 04 24             	mov    %eax,(%esp)
 568:	e8 bf fe ff ff       	call   42c <putc>
 56d:	e9 2d 01 00 00       	jmp    69f <printf+0x196>
      }
    } else if(state == '%'){
 572:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 576:	0f 85 23 01 00 00    	jne    69f <printf+0x196>
      if(c == 'd'){
 57c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 580:	75 2d                	jne    5af <printf+0xa6>
        printint(fd, *ap, 10, 1);
 582:	8b 45 e8             	mov    -0x18(%ebp),%eax
 585:	8b 00                	mov    (%eax),%eax
 587:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 58e:	00 
 58f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 596:	00 
 597:	89 44 24 04          	mov    %eax,0x4(%esp)
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	89 04 24             	mov    %eax,(%esp)
 5a1:	e8 ae fe ff ff       	call   454 <printint>
        ap++;
 5a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5aa:	e9 e9 00 00 00       	jmp    698 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5af:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b3:	74 06                	je     5bb <printf+0xb2>
 5b5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b9:	75 2d                	jne    5e8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5be:	8b 00                	mov    (%eax),%eax
 5c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c7:	00 
 5c8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5cf:	00 
 5d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	89 04 24             	mov    %eax,(%esp)
 5da:	e8 75 fe ff ff       	call   454 <printint>
        ap++;
 5df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e3:	e9 b0 00 00 00       	jmp    698 <printf+0x18f>
      } else if(c == 's'){
 5e8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5ec:	75 42                	jne    630 <printf+0x127>
        s = (char*)*ap;
 5ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fe:	75 09                	jne    609 <printf+0x100>
          s = "(null)";
 600:	c7 45 f4 e3 08 00 00 	movl   $0x8e3,-0xc(%ebp)
        while(*s != 0){
 607:	eb 1c                	jmp    625 <printf+0x11c>
 609:	eb 1a                	jmp    625 <printf+0x11c>
          putc(fd, *s);
 60b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60e:	8a 00                	mov    (%eax),%al
 610:	0f be c0             	movsbl %al,%eax
 613:	89 44 24 04          	mov    %eax,0x4(%esp)
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 0a fe ff ff       	call   42c <putc>
          s++;
 622:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 625:	8b 45 f4             	mov    -0xc(%ebp),%eax
 628:	8a 00                	mov    (%eax),%al
 62a:	84 c0                	test   %al,%al
 62c:	75 dd                	jne    60b <printf+0x102>
 62e:	eb 68                	jmp    698 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 630:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 634:	75 1d                	jne    653 <printf+0x14a>
        putc(fd, *ap);
 636:	8b 45 e8             	mov    -0x18(%ebp),%eax
 639:	8b 00                	mov    (%eax),%eax
 63b:	0f be c0             	movsbl %al,%eax
 63e:	89 44 24 04          	mov    %eax,0x4(%esp)
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	89 04 24             	mov    %eax,(%esp)
 648:	e8 df fd ff ff       	call   42c <putc>
        ap++;
 64d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 651:	eb 45                	jmp    698 <printf+0x18f>
      } else if(c == '%'){
 653:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 657:	75 17                	jne    670 <printf+0x167>
        putc(fd, c);
 659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65c:	0f be c0             	movsbl %al,%eax
 65f:	89 44 24 04          	mov    %eax,0x4(%esp)
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	89 04 24             	mov    %eax,(%esp)
 669:	e8 be fd ff ff       	call   42c <putc>
 66e:	eb 28                	jmp    698 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 670:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 677:	00 
 678:	8b 45 08             	mov    0x8(%ebp),%eax
 67b:	89 04 24             	mov    %eax,(%esp)
 67e:	e8 a9 fd ff ff       	call   42c <putc>
        putc(fd, c);
 683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 686:	0f be c0             	movsbl %al,%eax
 689:	89 44 24 04          	mov    %eax,0x4(%esp)
 68d:	8b 45 08             	mov    0x8(%ebp),%eax
 690:	89 04 24             	mov    %eax,(%esp)
 693:	e8 94 fd ff ff       	call   42c <putc>
      }
      state = 0;
 698:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 69f:	ff 45 f0             	incl   -0x10(%ebp)
 6a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a8:	01 d0                	add    %edx,%eax
 6aa:	8a 00                	mov    (%eax),%al
 6ac:	84 c0                	test   %al,%al
 6ae:	0f 85 77 fe ff ff    	jne    52b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b4:	c9                   	leave  
 6b5:	c3                   	ret    
 6b6:	90                   	nop
 6b7:	90                   	nop

000006b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b8:	55                   	push   %ebp
 6b9:	89 e5                	mov    %esp,%ebp
 6bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6be:	8b 45 08             	mov    0x8(%ebp),%eax
 6c1:	83 e8 08             	sub    $0x8,%eax
 6c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c7:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 6cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cf:	eb 24                	jmp    6f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	8b 00                	mov    (%eax),%eax
 6d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d9:	77 12                	ja     6ed <free+0x35>
 6db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e1:	77 24                	ja     707 <free+0x4f>
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 00                	mov    (%eax),%eax
 6e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6eb:	77 1a                	ja     707 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fb:	76 d4                	jbe    6d1 <free+0x19>
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 705:	76 ca                	jbe    6d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 707:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70a:	8b 40 04             	mov    0x4(%eax),%eax
 70d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 714:	8b 45 f8             	mov    -0x8(%ebp),%eax
 717:	01 c2                	add    %eax,%edx
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	39 c2                	cmp    %eax,%edx
 720:	75 24                	jne    746 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	8b 50 04             	mov    0x4(%eax),%edx
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 00                	mov    (%eax),%eax
 72d:	8b 40 04             	mov    0x4(%eax),%eax
 730:	01 c2                	add    %eax,%edx
 732:	8b 45 f8             	mov    -0x8(%ebp),%eax
 735:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73b:	8b 00                	mov    (%eax),%eax
 73d:	8b 10                	mov    (%eax),%edx
 73f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 742:	89 10                	mov    %edx,(%eax)
 744:	eb 0a                	jmp    750 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	8b 10                	mov    (%eax),%edx
 74b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 750:	8b 45 fc             	mov    -0x4(%ebp),%eax
 753:	8b 40 04             	mov    0x4(%eax),%eax
 756:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	01 d0                	add    %edx,%eax
 762:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 765:	75 20                	jne    787 <free+0xcf>
    p->s.size += bp->s.size;
 767:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76a:	8b 50 04             	mov    0x4(%eax),%edx
 76d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	01 c2                	add    %eax,%edx
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	8b 10                	mov    (%eax),%edx
 780:	8b 45 fc             	mov    -0x4(%ebp),%eax
 783:	89 10                	mov    %edx,(%eax)
 785:	eb 08                	jmp    78f <free+0xd7>
  } else
    p->s.ptr = bp;
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 78d:	89 10                	mov    %edx,(%eax)
  freep = p;
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	a3 4c 0b 00 00       	mov    %eax,0xb4c
}
 797:	c9                   	leave  
 798:	c3                   	ret    

00000799 <morecore>:

static Header*
morecore(uint nu)
{
 799:	55                   	push   %ebp
 79a:	89 e5                	mov    %esp,%ebp
 79c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 79f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a6:	77 07                	ja     7af <morecore+0x16>
    nu = 4096;
 7a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
 7b2:	c1 e0 03             	shl    $0x3,%eax
 7b5:	89 04 24             	mov    %eax,(%esp)
 7b8:	e8 87 fb ff ff       	call   344 <sbrk>
 7bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c4:	75 07                	jne    7cd <morecore+0x34>
    return 0;
 7c6:	b8 00 00 00 00       	mov    $0x0,%eax
 7cb:	eb 22                	jmp    7ef <morecore+0x56>
  hp = (Header*)p;
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d6:	8b 55 08             	mov    0x8(%ebp),%edx
 7d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7df:	83 c0 08             	add    $0x8,%eax
 7e2:	89 04 24             	mov    %eax,(%esp)
 7e5:	e8 ce fe ff ff       	call   6b8 <free>
  return freep;
 7ea:	a1 4c 0b 00 00       	mov    0xb4c,%eax
}
 7ef:	c9                   	leave  
 7f0:	c3                   	ret    

000007f1 <malloc>:

void*
malloc(uint nbytes)
{
 7f1:	55                   	push   %ebp
 7f2:	89 e5                	mov    %esp,%ebp
 7f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f7:	8b 45 08             	mov    0x8(%ebp),%eax
 7fa:	83 c0 07             	add    $0x7,%eax
 7fd:	c1 e8 03             	shr    $0x3,%eax
 800:	40                   	inc    %eax
 801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 804:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 809:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 810:	75 23                	jne    835 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 812:	c7 45 f0 44 0b 00 00 	movl   $0xb44,-0x10(%ebp)
 819:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81c:	a3 4c 0b 00 00       	mov    %eax,0xb4c
 821:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 826:	a3 44 0b 00 00       	mov    %eax,0xb44
    base.s.size = 0;
 82b:	c7 05 48 0b 00 00 00 	movl   $0x0,0xb48
 832:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 846:	72 4d                	jb     895 <malloc+0xa4>
      if(p->s.size == nunits)
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	8b 40 04             	mov    0x4(%eax),%eax
 84e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 851:	75 0c                	jne    85f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8b 10                	mov    (%eax),%edx
 858:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85b:	89 10                	mov    %edx,(%eax)
 85d:	eb 26                	jmp    885 <malloc+0x94>
      else {
        p->s.size -= nunits;
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 40 04             	mov    0x4(%eax),%eax
 865:	2b 45 ec             	sub    -0x14(%ebp),%eax
 868:	89 c2                	mov    %eax,%edx
 86a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 870:	8b 45 f4             	mov    -0xc(%ebp),%eax
 873:	8b 40 04             	mov    0x4(%eax),%eax
 876:	c1 e0 03             	shl    $0x3,%eax
 879:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 882:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 885:	8b 45 f0             	mov    -0x10(%ebp),%eax
 888:	a3 4c 0b 00 00       	mov    %eax,0xb4c
      return (void*)(p + 1);
 88d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 890:	83 c0 08             	add    $0x8,%eax
 893:	eb 38                	jmp    8cd <malloc+0xdc>
    }
    if(p == freep)
 895:	a1 4c 0b 00 00       	mov    0xb4c,%eax
 89a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 89d:	75 1b                	jne    8ba <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 89f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a2:	89 04 24             	mov    %eax,(%esp)
 8a5:	e8 ef fe ff ff       	call   799 <morecore>
 8aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b1:	75 07                	jne    8ba <malloc+0xc9>
        return 0;
 8b3:	b8 00 00 00 00       	mov    $0x0,%eax
 8b8:	eb 13                	jmp    8cd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c3:	8b 00                	mov    (%eax),%eax
 8c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8c8:	e9 70 ff ff ff       	jmp    83d <malloc+0x4c>
}
 8cd:	c9                   	leave  
 8ce:	c3                   	ret    
