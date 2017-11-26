
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 62 02 00 00       	call   270 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 ea 02 00 00       	call   308 <sleep>
  exit();
  1e:	e8 55 02 00 00       	call   278 <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 08             	mov    0x8(%ebp),%eax
  59:	8d 50 01             	lea    0x1(%eax),%edx
  5c:	89 55 08             	mov    %edx,0x8(%ebp)
  5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  62:	8d 4a 01             	lea    0x1(%edx),%ecx
  65:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  68:	8a 12                	mov    (%edx),%dl
  6a:	88 10                	mov    %dl,(%eax)
  6c:	8a 00                	mov    (%eax),%al
  6e:	84 c0                	test   %al,%al
  70:	75 e4                	jne    56 <strcpy+0xd>
    ;
  return os;
  72:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  75:	c9                   	leave  
  76:	c3                   	ret    

00000077 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  77:	55                   	push   %ebp
  78:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  7a:	eb 06                	jmp    82 <strcmp+0xb>
    p++, q++;
  7c:	ff 45 08             	incl   0x8(%ebp)
  7f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  82:	8b 45 08             	mov    0x8(%ebp),%eax
  85:	8a 00                	mov    (%eax),%al
  87:	84 c0                	test   %al,%al
  89:	74 0e                	je     99 <strcmp+0x22>
  8b:	8b 45 08             	mov    0x8(%ebp),%eax
  8e:	8a 10                	mov    (%eax),%dl
  90:	8b 45 0c             	mov    0xc(%ebp),%eax
  93:	8a 00                	mov    (%eax),%al
  95:	38 c2                	cmp    %al,%dl
  97:	74 e3                	je     7c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	8a 00                	mov    (%eax),%al
  9e:	0f b6 d0             	movzbl %al,%edx
  a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  a4:	8a 00                	mov    (%eax),%al
  a6:	0f b6 c0             	movzbl %al,%eax
  a9:	29 c2                	sub    %eax,%edx
  ab:	89 d0                	mov    %edx,%eax
}
  ad:	5d                   	pop    %ebp
  ae:	c3                   	ret    

000000af <strlen>:

uint
strlen(char *s)
{
  af:	55                   	push   %ebp
  b0:	89 e5                	mov    %esp,%ebp
  b2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  bc:	eb 03                	jmp    c1 <strlen+0x12>
  be:	ff 45 fc             	incl   -0x4(%ebp)
  c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	01 d0                	add    %edx,%eax
  c9:	8a 00                	mov    (%eax),%al
  cb:	84 c0                	test   %al,%al
  cd:	75 ef                	jne    be <strlen+0xf>
    ;
  return n;
  cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d2:	c9                   	leave  
  d3:	c3                   	ret    

000000d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d4:	55                   	push   %ebp
  d5:	89 e5                	mov    %esp,%ebp
  d7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  da:	8b 45 10             	mov    0x10(%ebp),%eax
  dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	89 04 24             	mov    %eax,(%esp)
  ee:	e8 31 ff ff ff       	call   24 <stosb>
  return dst;
  f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  f6:	c9                   	leave  
  f7:	c3                   	ret    

000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  fb:	83 ec 04             	sub    $0x4,%esp
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 104:	eb 12                	jmp    118 <strchr+0x20>
    if(*s == c)
 106:	8b 45 08             	mov    0x8(%ebp),%eax
 109:	8a 00                	mov    (%eax),%al
 10b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 10e:	75 05                	jne    115 <strchr+0x1d>
      return (char*)s;
 110:	8b 45 08             	mov    0x8(%ebp),%eax
 113:	eb 11                	jmp    126 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 115:	ff 45 08             	incl   0x8(%ebp)
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	8a 00                	mov    (%eax),%al
 11d:	84 c0                	test   %al,%al
 11f:	75 e5                	jne    106 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 121:	b8 00 00 00 00       	mov    $0x0,%eax
}
 126:	c9                   	leave  
 127:	c3                   	ret    

00000128 <gets>:

char*
gets(char *buf, int max)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 135:	eb 49                	jmp    180 <gets+0x58>
    cc = read(0, &c, 1);
 137:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 13e:	00 
 13f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 142:	89 44 24 04          	mov    %eax,0x4(%esp)
 146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 14d:	e8 3e 01 00 00       	call   290 <read>
 152:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 155:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 159:	7f 02                	jg     15d <gets+0x35>
      break;
 15b:	eb 2c                	jmp    189 <gets+0x61>
    buf[i++] = c;
 15d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 160:	8d 50 01             	lea    0x1(%eax),%edx
 163:	89 55 f4             	mov    %edx,-0xc(%ebp)
 166:	89 c2                	mov    %eax,%edx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	01 c2                	add    %eax,%edx
 16d:	8a 45 ef             	mov    -0x11(%ebp),%al
 170:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 172:	8a 45 ef             	mov    -0x11(%ebp),%al
 175:	3c 0a                	cmp    $0xa,%al
 177:	74 10                	je     189 <gets+0x61>
 179:	8a 45 ef             	mov    -0x11(%ebp),%al
 17c:	3c 0d                	cmp    $0xd,%al
 17e:	74 09                	je     189 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	8b 45 f4             	mov    -0xc(%ebp),%eax
 183:	40                   	inc    %eax
 184:	3b 45 0c             	cmp    0xc(%ebp),%eax
 187:	7c ae                	jl     137 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 189:	8b 55 f4             	mov    -0xc(%ebp),%edx
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	01 d0                	add    %edx,%eax
 191:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
}
 197:	c9                   	leave  
 198:	c3                   	ret    

00000199 <stat>:

int
stat(char *n, struct stat *st)
{
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a6:	00 
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 06 01 00 00       	call   2b8 <open>
 1b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b9:	79 07                	jns    1c2 <stat+0x29>
    return -1;
 1bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c0:	eb 23                	jmp    1e5 <stat+0x4c>
  r = fstat(fd, st);
 1c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	89 04 24             	mov    %eax,(%esp)
 1cf:	e8 fc 00 00 00       	call   2d0 <fstat>
 1d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 be 00 00 00       	call   2a0 <close>
  return r;
 1e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e5:	c9                   	leave  
 1e6:	c3                   	ret    

000001e7 <atoi>:

int
atoi(const char *s)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
 1ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f4:	eb 24                	jmp    21a <atoi+0x33>
    n = n*10 + *s++ - '0';
 1f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f9:	89 d0                	mov    %edx,%eax
 1fb:	c1 e0 02             	shl    $0x2,%eax
 1fe:	01 d0                	add    %edx,%eax
 200:	01 c0                	add    %eax,%eax
 202:	89 c1                	mov    %eax,%ecx
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8d 50 01             	lea    0x1(%eax),%edx
 20a:	89 55 08             	mov    %edx,0x8(%ebp)
 20d:	8a 00                	mov    (%eax),%al
 20f:	0f be c0             	movsbl %al,%eax
 212:	01 c8                	add    %ecx,%eax
 214:	83 e8 30             	sub    $0x30,%eax
 217:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	8a 00                	mov    (%eax),%al
 21f:	3c 2f                	cmp    $0x2f,%al
 221:	7e 09                	jle    22c <atoi+0x45>
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	8a 00                	mov    (%eax),%al
 228:	3c 39                	cmp    $0x39,%al
 22a:	7e ca                	jle    1f6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 22c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22f:	c9                   	leave  
 230:	c3                   	ret    

00000231 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 231:	55                   	push   %ebp
 232:	89 e5                	mov    %esp,%ebp
 234:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 23d:	8b 45 0c             	mov    0xc(%ebp),%eax
 240:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 243:	eb 16                	jmp    25b <memmove+0x2a>
    *dst++ = *src++;
 245:	8b 45 fc             	mov    -0x4(%ebp),%eax
 248:	8d 50 01             	lea    0x1(%eax),%edx
 24b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 24e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 251:	8d 4a 01             	lea    0x1(%edx),%ecx
 254:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 257:	8a 12                	mov    (%edx),%dl
 259:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 25b:	8b 45 10             	mov    0x10(%ebp),%eax
 25e:	8d 50 ff             	lea    -0x1(%eax),%edx
 261:	89 55 10             	mov    %edx,0x10(%ebp)
 264:	85 c0                	test   %eax,%eax
 266:	7f dd                	jg     245 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26b:	c9                   	leave  
 26c:	c3                   	ret    
 26d:	90                   	nop
 26e:	90                   	nop
 26f:	90                   	nop

00000270 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 270:	b8 01 00 00 00       	mov    $0x1,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <exit>:
SYSCALL(exit)
 278:	b8 02 00 00 00       	mov    $0x2,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <wait>:
SYSCALL(wait)
 280:	b8 03 00 00 00       	mov    $0x3,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <pipe>:
SYSCALL(pipe)
 288:	b8 04 00 00 00       	mov    $0x4,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <read>:
SYSCALL(read)
 290:	b8 05 00 00 00       	mov    $0x5,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <write>:
SYSCALL(write)
 298:	b8 10 00 00 00       	mov    $0x10,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <close>:
SYSCALL(close)
 2a0:	b8 15 00 00 00       	mov    $0x15,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <kill>:
SYSCALL(kill)
 2a8:	b8 06 00 00 00       	mov    $0x6,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <exec>:
SYSCALL(exec)
 2b0:	b8 07 00 00 00       	mov    $0x7,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <open>:
SYSCALL(open)
 2b8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <mknod>:
SYSCALL(mknod)
 2c0:	b8 11 00 00 00       	mov    $0x11,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <unlink>:
SYSCALL(unlink)
 2c8:	b8 12 00 00 00       	mov    $0x12,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <fstat>:
SYSCALL(fstat)
 2d0:	b8 08 00 00 00       	mov    $0x8,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <link>:
SYSCALL(link)
 2d8:	b8 13 00 00 00       	mov    $0x13,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <mkdir>:
SYSCALL(mkdir)
 2e0:	b8 14 00 00 00       	mov    $0x14,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <chdir>:
SYSCALL(chdir)
 2e8:	b8 09 00 00 00       	mov    $0x9,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <dup>:
SYSCALL(dup)
 2f0:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <getpid>:
SYSCALL(getpid)
 2f8:	b8 0b 00 00 00       	mov    $0xb,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <sbrk>:
SYSCALL(sbrk)
 300:	b8 0c 00 00 00       	mov    $0xc,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <sleep>:
SYSCALL(sleep)
 308:	b8 0d 00 00 00       	mov    $0xd,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <uptime>:
SYSCALL(uptime)
 310:	b8 0e 00 00 00       	mov    $0xe,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <getticks>:
 318:	b8 16 00 00 00       	mov    $0x16,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	83 ec 18             	sub    $0x18,%esp
 326:	8b 45 0c             	mov    0xc(%ebp),%eax
 329:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 32c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 333:	00 
 334:	8d 45 f4             	lea    -0xc(%ebp),%eax
 337:	89 44 24 04          	mov    %eax,0x4(%esp)
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	89 04 24             	mov    %eax,(%esp)
 341:	e8 52 ff ff ff       	call   298 <write>
}
 346:	c9                   	leave  
 347:	c3                   	ret    

00000348 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	56                   	push   %esi
 34c:	53                   	push   %ebx
 34d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 350:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 357:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 35b:	74 17                	je     374 <printint+0x2c>
 35d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 361:	79 11                	jns    374 <printint+0x2c>
    neg = 1;
 363:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	f7 d8                	neg    %eax
 36f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 372:	eb 06                	jmp    37a <printint+0x32>
  } else {
    x = xx;
 374:	8b 45 0c             	mov    0xc(%ebp),%eax
 377:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 37a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 381:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 384:	8d 41 01             	lea    0x1(%ecx),%eax
 387:	89 45 f4             	mov    %eax,-0xc(%ebp)
 38a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 38d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 390:	ba 00 00 00 00       	mov    $0x0,%edx
 395:	f7 f3                	div    %ebx
 397:	89 d0                	mov    %edx,%eax
 399:	8a 80 10 0a 00 00    	mov    0xa10(%eax),%al
 39f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3a3:	8b 75 10             	mov    0x10(%ebp),%esi
 3a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3a9:	ba 00 00 00 00       	mov    $0x0,%edx
 3ae:	f7 f6                	div    %esi
 3b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3b7:	75 c8                	jne    381 <printint+0x39>
  if(neg)
 3b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3bd:	74 10                	je     3cf <printint+0x87>
    buf[i++] = '-';
 3bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c2:	8d 50 01             	lea    0x1(%eax),%edx
 3c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3c8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3cd:	eb 1e                	jmp    3ed <printint+0xa5>
 3cf:	eb 1c                	jmp    3ed <printint+0xa5>
    putc(fd, buf[i]);
 3d1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d7:	01 d0                	add    %edx,%eax
 3d9:	8a 00                	mov    (%eax),%al
 3db:	0f be c0             	movsbl %al,%eax
 3de:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
 3e5:	89 04 24             	mov    %eax,(%esp)
 3e8:	e8 33 ff ff ff       	call   320 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3ed:	ff 4d f4             	decl   -0xc(%ebp)
 3f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3f4:	79 db                	jns    3d1 <printint+0x89>
    putc(fd, buf[i]);
}
 3f6:	83 c4 30             	add    $0x30,%esp
 3f9:	5b                   	pop    %ebx
 3fa:	5e                   	pop    %esi
 3fb:	5d                   	pop    %ebp
 3fc:	c3                   	ret    

000003fd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3fd:	55                   	push   %ebp
 3fe:	89 e5                	mov    %esp,%ebp
 400:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 403:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 40a:	8d 45 0c             	lea    0xc(%ebp),%eax
 40d:	83 c0 04             	add    $0x4,%eax
 410:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 413:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 41a:	e9 77 01 00 00       	jmp    596 <printf+0x199>
    c = fmt[i] & 0xff;
 41f:	8b 55 0c             	mov    0xc(%ebp),%edx
 422:	8b 45 f0             	mov    -0x10(%ebp),%eax
 425:	01 d0                	add    %edx,%eax
 427:	8a 00                	mov    (%eax),%al
 429:	0f be c0             	movsbl %al,%eax
 42c:	25 ff 00 00 00       	and    $0xff,%eax
 431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 434:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 438:	75 2c                	jne    466 <printf+0x69>
      if(c == '%'){
 43a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 43e:	75 0c                	jne    44c <printf+0x4f>
        state = '%';
 440:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 447:	e9 47 01 00 00       	jmp    593 <printf+0x196>
      } else {
        putc(fd, c);
 44c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44f:	0f be c0             	movsbl %al,%eax
 452:	89 44 24 04          	mov    %eax,0x4(%esp)
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	89 04 24             	mov    %eax,(%esp)
 45c:	e8 bf fe ff ff       	call   320 <putc>
 461:	e9 2d 01 00 00       	jmp    593 <printf+0x196>
      }
    } else if(state == '%'){
 466:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 46a:	0f 85 23 01 00 00    	jne    593 <printf+0x196>
      if(c == 'd'){
 470:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 474:	75 2d                	jne    4a3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 476:	8b 45 e8             	mov    -0x18(%ebp),%eax
 479:	8b 00                	mov    (%eax),%eax
 47b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 482:	00 
 483:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 48a:	00 
 48b:	89 44 24 04          	mov    %eax,0x4(%esp)
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	89 04 24             	mov    %eax,(%esp)
 495:	e8 ae fe ff ff       	call   348 <printint>
        ap++;
 49a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 49e:	e9 e9 00 00 00       	jmp    58c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 4a3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4a7:	74 06                	je     4af <printf+0xb2>
 4a9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4ad:	75 2d                	jne    4dc <printf+0xdf>
        printint(fd, *ap, 16, 0);
 4af:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b2:	8b 00                	mov    (%eax),%eax
 4b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4bb:	00 
 4bc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4c3:	00 
 4c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c8:	8b 45 08             	mov    0x8(%ebp),%eax
 4cb:	89 04 24             	mov    %eax,(%esp)
 4ce:	e8 75 fe ff ff       	call   348 <printint>
        ap++;
 4d3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d7:	e9 b0 00 00 00       	jmp    58c <printf+0x18f>
      } else if(c == 's'){
 4dc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4e0:	75 42                	jne    524 <printf+0x127>
        s = (char*)*ap;
 4e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e5:	8b 00                	mov    (%eax),%eax
 4e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f2:	75 09                	jne    4fd <printf+0x100>
          s = "(null)";
 4f4:	c7 45 f4 c3 07 00 00 	movl   $0x7c3,-0xc(%ebp)
        while(*s != 0){
 4fb:	eb 1c                	jmp    519 <printf+0x11c>
 4fd:	eb 1a                	jmp    519 <printf+0x11c>
          putc(fd, *s);
 4ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 502:	8a 00                	mov    (%eax),%al
 504:	0f be c0             	movsbl %al,%eax
 507:	89 44 24 04          	mov    %eax,0x4(%esp)
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	89 04 24             	mov    %eax,(%esp)
 511:	e8 0a fe ff ff       	call   320 <putc>
          s++;
 516:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 519:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51c:	8a 00                	mov    (%eax),%al
 51e:	84 c0                	test   %al,%al
 520:	75 dd                	jne    4ff <printf+0x102>
 522:	eb 68                	jmp    58c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 524:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 528:	75 1d                	jne    547 <printf+0x14a>
        putc(fd, *ap);
 52a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52d:	8b 00                	mov    (%eax),%eax
 52f:	0f be c0             	movsbl %al,%eax
 532:	89 44 24 04          	mov    %eax,0x4(%esp)
 536:	8b 45 08             	mov    0x8(%ebp),%eax
 539:	89 04 24             	mov    %eax,(%esp)
 53c:	e8 df fd ff ff       	call   320 <putc>
        ap++;
 541:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 545:	eb 45                	jmp    58c <printf+0x18f>
      } else if(c == '%'){
 547:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54b:	75 17                	jne    564 <printf+0x167>
        putc(fd, c);
 54d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 550:	0f be c0             	movsbl %al,%eax
 553:	89 44 24 04          	mov    %eax,0x4(%esp)
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	89 04 24             	mov    %eax,(%esp)
 55d:	e8 be fd ff ff       	call   320 <putc>
 562:	eb 28                	jmp    58c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 564:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 56b:	00 
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
 56f:	89 04 24             	mov    %eax,(%esp)
 572:	e8 a9 fd ff ff       	call   320 <putc>
        putc(fd, c);
 577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	89 44 24 04          	mov    %eax,0x4(%esp)
 581:	8b 45 08             	mov    0x8(%ebp),%eax
 584:	89 04 24             	mov    %eax,(%esp)
 587:	e8 94 fd ff ff       	call   320 <putc>
      }
      state = 0;
 58c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 593:	ff 45 f0             	incl   -0x10(%ebp)
 596:	8b 55 0c             	mov    0xc(%ebp),%edx
 599:	8b 45 f0             	mov    -0x10(%ebp),%eax
 59c:	01 d0                	add    %edx,%eax
 59e:	8a 00                	mov    (%eax),%al
 5a0:	84 c0                	test   %al,%al
 5a2:	0f 85 77 fe ff ff    	jne    41f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5a8:	c9                   	leave  
 5a9:	c3                   	ret    
 5aa:	90                   	nop
 5ab:	90                   	nop

000005ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5ac:	55                   	push   %ebp
 5ad:	89 e5                	mov    %esp,%ebp
 5af:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5b2:	8b 45 08             	mov    0x8(%ebp),%eax
 5b5:	83 e8 08             	sub    $0x8,%eax
 5b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5bb:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 5c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5c3:	eb 24                	jmp    5e9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c8:	8b 00                	mov    (%eax),%eax
 5ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5cd:	77 12                	ja     5e1 <free+0x35>
 5cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d5:	77 24                	ja     5fb <free+0x4f>
 5d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5da:	8b 00                	mov    (%eax),%eax
 5dc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5df:	77 1a                	ja     5fb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e4:	8b 00                	mov    (%eax),%eax
 5e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5ef:	76 d4                	jbe    5c5 <free+0x19>
 5f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f4:	8b 00                	mov    (%eax),%eax
 5f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5f9:	76 ca                	jbe    5c5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fe:	8b 40 04             	mov    0x4(%eax),%eax
 601:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 608:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60b:	01 c2                	add    %eax,%edx
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	39 c2                	cmp    %eax,%edx
 614:	75 24                	jne    63a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 616:	8b 45 f8             	mov    -0x8(%ebp),%eax
 619:	8b 50 04             	mov    0x4(%eax),%edx
 61c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61f:	8b 00                	mov    (%eax),%eax
 621:	8b 40 04             	mov    0x4(%eax),%eax
 624:	01 c2                	add    %eax,%edx
 626:	8b 45 f8             	mov    -0x8(%ebp),%eax
 629:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 62c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62f:	8b 00                	mov    (%eax),%eax
 631:	8b 10                	mov    (%eax),%edx
 633:	8b 45 f8             	mov    -0x8(%ebp),%eax
 636:	89 10                	mov    %edx,(%eax)
 638:	eb 0a                	jmp    644 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 63a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63d:	8b 10                	mov    (%eax),%edx
 63f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 642:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 644:	8b 45 fc             	mov    -0x4(%ebp),%eax
 647:	8b 40 04             	mov    0x4(%eax),%eax
 64a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	01 d0                	add    %edx,%eax
 656:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 659:	75 20                	jne    67b <free+0xcf>
    p->s.size += bp->s.size;
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 50 04             	mov    0x4(%eax),%edx
 661:	8b 45 f8             	mov    -0x8(%ebp),%eax
 664:	8b 40 04             	mov    0x4(%eax),%eax
 667:	01 c2                	add    %eax,%edx
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 66f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 672:	8b 10                	mov    (%eax),%edx
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	89 10                	mov    %edx,(%eax)
 679:	eb 08                	jmp    683 <free+0xd7>
  } else
    p->s.ptr = bp;
 67b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 681:	89 10                	mov    %edx,(%eax)
  freep = p;
 683:	8b 45 fc             	mov    -0x4(%ebp),%eax
 686:	a3 2c 0a 00 00       	mov    %eax,0xa2c
}
 68b:	c9                   	leave  
 68c:	c3                   	ret    

0000068d <morecore>:

static Header*
morecore(uint nu)
{
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 693:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 69a:	77 07                	ja     6a3 <morecore+0x16>
    nu = 4096;
 69c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6a3:	8b 45 08             	mov    0x8(%ebp),%eax
 6a6:	c1 e0 03             	shl    $0x3,%eax
 6a9:	89 04 24             	mov    %eax,(%esp)
 6ac:	e8 4f fc ff ff       	call   300 <sbrk>
 6b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6b4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6b8:	75 07                	jne    6c1 <morecore+0x34>
    return 0;
 6ba:	b8 00 00 00 00       	mov    $0x0,%eax
 6bf:	eb 22                	jmp    6e3 <morecore+0x56>
  hp = (Header*)p;
 6c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ca:	8b 55 08             	mov    0x8(%ebp),%edx
 6cd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d3:	83 c0 08             	add    $0x8,%eax
 6d6:	89 04 24             	mov    %eax,(%esp)
 6d9:	e8 ce fe ff ff       	call   5ac <free>
  return freep;
 6de:	a1 2c 0a 00 00       	mov    0xa2c,%eax
}
 6e3:	c9                   	leave  
 6e4:	c3                   	ret    

000006e5 <malloc>:

void*
malloc(uint nbytes)
{
 6e5:	55                   	push   %ebp
 6e6:	89 e5                	mov    %esp,%ebp
 6e8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ee:	83 c0 07             	add    $0x7,%eax
 6f1:	c1 e8 03             	shr    $0x3,%eax
 6f4:	40                   	inc    %eax
 6f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6f8:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 6fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 700:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 704:	75 23                	jne    729 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 706:	c7 45 f0 24 0a 00 00 	movl   $0xa24,-0x10(%ebp)
 70d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 710:	a3 2c 0a 00 00       	mov    %eax,0xa2c
 715:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 71a:	a3 24 0a 00 00       	mov    %eax,0xa24
    base.s.size = 0;
 71f:	c7 05 28 0a 00 00 00 	movl   $0x0,0xa28
 726:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 729:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72c:	8b 00                	mov    (%eax),%eax
 72e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 731:	8b 45 f4             	mov    -0xc(%ebp),%eax
 734:	8b 40 04             	mov    0x4(%eax),%eax
 737:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 73a:	72 4d                	jb     789 <malloc+0xa4>
      if(p->s.size == nunits)
 73c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73f:	8b 40 04             	mov    0x4(%eax),%eax
 742:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 745:	75 0c                	jne    753 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 747:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74a:	8b 10                	mov    (%eax),%edx
 74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74f:	89 10                	mov    %edx,(%eax)
 751:	eb 26                	jmp    779 <malloc+0x94>
      else {
        p->s.size -= nunits;
 753:	8b 45 f4             	mov    -0xc(%ebp),%eax
 756:	8b 40 04             	mov    0x4(%eax),%eax
 759:	2b 45 ec             	sub    -0x14(%ebp),%eax
 75c:	89 c2                	mov    %eax,%edx
 75e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 761:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	8b 40 04             	mov    0x4(%eax),%eax
 76a:	c1 e0 03             	shl    $0x3,%eax
 76d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	8b 55 ec             	mov    -0x14(%ebp),%edx
 776:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 779:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77c:	a3 2c 0a 00 00       	mov    %eax,0xa2c
      return (void*)(p + 1);
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	83 c0 08             	add    $0x8,%eax
 787:	eb 38                	jmp    7c1 <malloc+0xdc>
    }
    if(p == freep)
 789:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 78e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 791:	75 1b                	jne    7ae <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 793:	8b 45 ec             	mov    -0x14(%ebp),%eax
 796:	89 04 24             	mov    %eax,(%esp)
 799:	e8 ef fe ff ff       	call   68d <morecore>
 79e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a5:	75 07                	jne    7ae <malloc+0xc9>
        return 0;
 7a7:	b8 00 00 00 00       	mov    $0x0,%eax
 7ac:	eb 13                	jmp    7c1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	8b 00                	mov    (%eax),%eax
 7b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7bc:	e9 70 ff ff ff       	jmp    731 <malloc+0x4c>
}
 7c1:	c9                   	leave  
 7c2:	c3                   	ret    
