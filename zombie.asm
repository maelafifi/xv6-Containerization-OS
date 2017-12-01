
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
SYSCALL(getticks)
 318:	b8 16 00 00 00       	mov    $0x16,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <get_name>:
SYSCALL(get_name)
 320:	b8 17 00 00 00       	mov    $0x17,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <get_max_proc>:
SYSCALL(get_max_proc)
 328:	b8 18 00 00 00       	mov    $0x18,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <get_max_mem>:
SYSCALL(get_max_mem)
 330:	b8 19 00 00 00       	mov    $0x19,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <get_max_disk>:
SYSCALL(get_max_disk)
 338:	b8 1a 00 00 00       	mov    $0x1a,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <get_curr_proc>:
SYSCALL(get_curr_proc)
 340:	b8 1b 00 00 00       	mov    $0x1b,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <get_curr_mem>:
SYSCALL(get_curr_mem)
 348:	b8 1c 00 00 00       	mov    $0x1c,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <get_curr_disk>:
SYSCALL(get_curr_disk)
 350:	b8 1d 00 00 00       	mov    $0x1d,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <set_name>:
SYSCALL(set_name)
 358:	b8 1e 00 00 00       	mov    $0x1e,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <set_max_mem>:
SYSCALL(set_max_mem)
 360:	b8 1f 00 00 00       	mov    $0x1f,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <set_max_disk>:
SYSCALL(set_max_disk)
 368:	b8 20 00 00 00       	mov    $0x20,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <set_max_proc>:
SYSCALL(set_max_proc)
 370:	b8 21 00 00 00       	mov    $0x21,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <set_curr_mem>:
SYSCALL(set_curr_mem)
 378:	b8 22 00 00 00       	mov    $0x22,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <set_curr_disk>:
SYSCALL(set_curr_disk)
 380:	b8 23 00 00 00       	mov    $0x23,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <set_curr_proc>:
SYSCALL(set_curr_proc)
 388:	b8 24 00 00 00       	mov    $0x24,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <find>:
SYSCALL(find)
 390:	b8 25 00 00 00       	mov    $0x25,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <is_full>:
SYSCALL(is_full)
 398:	b8 26 00 00 00       	mov    $0x26,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <container_init>:
SYSCALL(container_init)
 3a0:	b8 27 00 00 00       	mov    $0x27,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <cont_proc_set>:
SYSCALL(cont_proc_set)
 3a8:	b8 28 00 00 00       	mov    $0x28,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <ps>:
SYSCALL(ps)
 3b0:	b8 29 00 00 00       	mov    $0x29,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 3b8:	b8 2a 00 00 00       	mov    $0x2a,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <set_root_inode>:
SYSCALL(set_root_inode)
 3c0:	b8 2b 00 00 00       	mov    $0x2b,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <cstop>:
SYSCALL(cstop)
 3c8:	b8 2c 00 00 00       	mov    $0x2c,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <df>:
SYSCALL(df)
 3d0:	b8 2d 00 00 00       	mov    $0x2d,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3d8:	55                   	push   %ebp
 3d9:	89 e5                	mov    %esp,%ebp
 3db:	83 ec 18             	sub    $0x18,%esp
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3eb:	00 
 3ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	89 04 24             	mov    %eax,(%esp)
 3f9:	e8 9a fe ff ff       	call   298 <write>
}
 3fe:	c9                   	leave  
 3ff:	c3                   	ret    

00000400 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	56                   	push   %esi
 404:	53                   	push   %ebx
 405:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 408:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 40f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 413:	74 17                	je     42c <printint+0x2c>
 415:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 419:	79 11                	jns    42c <printint+0x2c>
    neg = 1;
 41b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 422:	8b 45 0c             	mov    0xc(%ebp),%eax
 425:	f7 d8                	neg    %eax
 427:	89 45 ec             	mov    %eax,-0x14(%ebp)
 42a:	eb 06                	jmp    432 <printint+0x32>
  } else {
    x = xx;
 42c:	8b 45 0c             	mov    0xc(%ebp),%eax
 42f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 439:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 43c:	8d 41 01             	lea    0x1(%ecx),%eax
 43f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 442:	8b 5d 10             	mov    0x10(%ebp),%ebx
 445:	8b 45 ec             	mov    -0x14(%ebp),%eax
 448:	ba 00 00 00 00       	mov    $0x0,%edx
 44d:	f7 f3                	div    %ebx
 44f:	89 d0                	mov    %edx,%eax
 451:	8a 80 c8 0a 00 00    	mov    0xac8(%eax),%al
 457:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 45b:	8b 75 10             	mov    0x10(%ebp),%esi
 45e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 461:	ba 00 00 00 00       	mov    $0x0,%edx
 466:	f7 f6                	div    %esi
 468:	89 45 ec             	mov    %eax,-0x14(%ebp)
 46b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46f:	75 c8                	jne    439 <printint+0x39>
  if(neg)
 471:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 475:	74 10                	je     487 <printint+0x87>
    buf[i++] = '-';
 477:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47a:	8d 50 01             	lea    0x1(%eax),%edx
 47d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 480:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 485:	eb 1e                	jmp    4a5 <printint+0xa5>
 487:	eb 1c                	jmp    4a5 <printint+0xa5>
    putc(fd, buf[i]);
 489:	8d 55 dc             	lea    -0x24(%ebp),%edx
 48c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48f:	01 d0                	add    %edx,%eax
 491:	8a 00                	mov    (%eax),%al
 493:	0f be c0             	movsbl %al,%eax
 496:	89 44 24 04          	mov    %eax,0x4(%esp)
 49a:	8b 45 08             	mov    0x8(%ebp),%eax
 49d:	89 04 24             	mov    %eax,(%esp)
 4a0:	e8 33 ff ff ff       	call   3d8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4a5:	ff 4d f4             	decl   -0xc(%ebp)
 4a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ac:	79 db                	jns    489 <printint+0x89>
    putc(fd, buf[i]);
}
 4ae:	83 c4 30             	add    $0x30,%esp
 4b1:	5b                   	pop    %ebx
 4b2:	5e                   	pop    %esi
 4b3:	5d                   	pop    %ebp
 4b4:	c3                   	ret    

000004b5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4b5:	55                   	push   %ebp
 4b6:	89 e5                	mov    %esp,%ebp
 4b8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4c2:	8d 45 0c             	lea    0xc(%ebp),%eax
 4c5:	83 c0 04             	add    $0x4,%eax
 4c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4d2:	e9 77 01 00 00       	jmp    64e <printf+0x199>
    c = fmt[i] & 0xff;
 4d7:	8b 55 0c             	mov    0xc(%ebp),%edx
 4da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4dd:	01 d0                	add    %edx,%eax
 4df:	8a 00                	mov    (%eax),%al
 4e1:	0f be c0             	movsbl %al,%eax
 4e4:	25 ff 00 00 00       	and    $0xff,%eax
 4e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f0:	75 2c                	jne    51e <printf+0x69>
      if(c == '%'){
 4f2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4f6:	75 0c                	jne    504 <printf+0x4f>
        state = '%';
 4f8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ff:	e9 47 01 00 00       	jmp    64b <printf+0x196>
      } else {
        putc(fd, c);
 504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 507:	0f be c0             	movsbl %al,%eax
 50a:	89 44 24 04          	mov    %eax,0x4(%esp)
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	89 04 24             	mov    %eax,(%esp)
 514:	e8 bf fe ff ff       	call   3d8 <putc>
 519:	e9 2d 01 00 00       	jmp    64b <printf+0x196>
      }
    } else if(state == '%'){
 51e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 522:	0f 85 23 01 00 00    	jne    64b <printf+0x196>
      if(c == 'd'){
 528:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 52c:	75 2d                	jne    55b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 52e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 531:	8b 00                	mov    (%eax),%eax
 533:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 53a:	00 
 53b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 542:	00 
 543:	89 44 24 04          	mov    %eax,0x4(%esp)
 547:	8b 45 08             	mov    0x8(%ebp),%eax
 54a:	89 04 24             	mov    %eax,(%esp)
 54d:	e8 ae fe ff ff       	call   400 <printint>
        ap++;
 552:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 556:	e9 e9 00 00 00       	jmp    644 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 55b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 55f:	74 06                	je     567 <printf+0xb2>
 561:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 565:	75 2d                	jne    594 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 567:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56a:	8b 00                	mov    (%eax),%eax
 56c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 573:	00 
 574:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 57b:	00 
 57c:	89 44 24 04          	mov    %eax,0x4(%esp)
 580:	8b 45 08             	mov    0x8(%ebp),%eax
 583:	89 04 24             	mov    %eax,(%esp)
 586:	e8 75 fe ff ff       	call   400 <printint>
        ap++;
 58b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58f:	e9 b0 00 00 00       	jmp    644 <printf+0x18f>
      } else if(c == 's'){
 594:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 598:	75 42                	jne    5dc <printf+0x127>
        s = (char*)*ap;
 59a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59d:	8b 00                	mov    (%eax),%eax
 59f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5aa:	75 09                	jne    5b5 <printf+0x100>
          s = "(null)";
 5ac:	c7 45 f4 7b 08 00 00 	movl   $0x87b,-0xc(%ebp)
        while(*s != 0){
 5b3:	eb 1c                	jmp    5d1 <printf+0x11c>
 5b5:	eb 1a                	jmp    5d1 <printf+0x11c>
          putc(fd, *s);
 5b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ba:	8a 00                	mov    (%eax),%al
 5bc:	0f be c0             	movsbl %al,%eax
 5bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c3:	8b 45 08             	mov    0x8(%ebp),%eax
 5c6:	89 04 24             	mov    %eax,(%esp)
 5c9:	e8 0a fe ff ff       	call   3d8 <putc>
          s++;
 5ce:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d4:	8a 00                	mov    (%eax),%al
 5d6:	84 c0                	test   %al,%al
 5d8:	75 dd                	jne    5b7 <printf+0x102>
 5da:	eb 68                	jmp    644 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5dc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5e0:	75 1d                	jne    5ff <printf+0x14a>
        putc(fd, *ap);
 5e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e5:	8b 00                	mov    (%eax),%eax
 5e7:	0f be c0             	movsbl %al,%eax
 5ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ee:	8b 45 08             	mov    0x8(%ebp),%eax
 5f1:	89 04 24             	mov    %eax,(%esp)
 5f4:	e8 df fd ff ff       	call   3d8 <putc>
        ap++;
 5f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5fd:	eb 45                	jmp    644 <printf+0x18f>
      } else if(c == '%'){
 5ff:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 603:	75 17                	jne    61c <printf+0x167>
        putc(fd, c);
 605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 608:	0f be c0             	movsbl %al,%eax
 60b:	89 44 24 04          	mov    %eax,0x4(%esp)
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	89 04 24             	mov    %eax,(%esp)
 615:	e8 be fd ff ff       	call   3d8 <putc>
 61a:	eb 28                	jmp    644 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 61c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 623:	00 
 624:	8b 45 08             	mov    0x8(%ebp),%eax
 627:	89 04 24             	mov    %eax,(%esp)
 62a:	e8 a9 fd ff ff       	call   3d8 <putc>
        putc(fd, c);
 62f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 632:	0f be c0             	movsbl %al,%eax
 635:	89 44 24 04          	mov    %eax,0x4(%esp)
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	89 04 24             	mov    %eax,(%esp)
 63f:	e8 94 fd ff ff       	call   3d8 <putc>
      }
      state = 0;
 644:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 64b:	ff 45 f0             	incl   -0x10(%ebp)
 64e:	8b 55 0c             	mov    0xc(%ebp),%edx
 651:	8b 45 f0             	mov    -0x10(%ebp),%eax
 654:	01 d0                	add    %edx,%eax
 656:	8a 00                	mov    (%eax),%al
 658:	84 c0                	test   %al,%al
 65a:	0f 85 77 fe ff ff    	jne    4d7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 660:	c9                   	leave  
 661:	c3                   	ret    
 662:	90                   	nop
 663:	90                   	nop

00000664 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 664:	55                   	push   %ebp
 665:	89 e5                	mov    %esp,%ebp
 667:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 66a:	8b 45 08             	mov    0x8(%ebp),%eax
 66d:	83 e8 08             	sub    $0x8,%eax
 670:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 673:	a1 e4 0a 00 00       	mov    0xae4,%eax
 678:	89 45 fc             	mov    %eax,-0x4(%ebp)
 67b:	eb 24                	jmp    6a1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 67d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 680:	8b 00                	mov    (%eax),%eax
 682:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 685:	77 12                	ja     699 <free+0x35>
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68d:	77 24                	ja     6b3 <free+0x4f>
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 00                	mov    (%eax),%eax
 694:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 697:	77 1a                	ja     6b3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a7:	76 d4                	jbe    67d <free+0x19>
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 00                	mov    (%eax),%eax
 6ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b1:	76 ca                	jbe    67d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	8b 40 04             	mov    0x4(%eax),%eax
 6b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c3:	01 c2                	add    %eax,%edx
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	39 c2                	cmp    %eax,%edx
 6cc:	75 24                	jne    6f2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d1:	8b 50 04             	mov    0x4(%eax),%edx
 6d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d7:	8b 00                	mov    (%eax),%eax
 6d9:	8b 40 04             	mov    0x4(%eax),%eax
 6dc:	01 c2                	add    %eax,%edx
 6de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e7:	8b 00                	mov    (%eax),%eax
 6e9:	8b 10                	mov    (%eax),%edx
 6eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ee:	89 10                	mov    %edx,(%eax)
 6f0:	eb 0a                	jmp    6fc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	8b 10                	mov    (%eax),%edx
 6f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 40 04             	mov    0x4(%eax),%eax
 702:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	01 d0                	add    %edx,%eax
 70e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 711:	75 20                	jne    733 <free+0xcf>
    p->s.size += bp->s.size;
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	8b 50 04             	mov    0x4(%eax),%edx
 719:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71c:	8b 40 04             	mov    0x4(%eax),%eax
 71f:	01 c2                	add    %eax,%edx
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	8b 10                	mov    (%eax),%edx
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	89 10                	mov    %edx,(%eax)
 731:	eb 08                	jmp    73b <free+0xd7>
  } else
    p->s.ptr = bp;
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
 736:	8b 55 f8             	mov    -0x8(%ebp),%edx
 739:	89 10                	mov    %edx,(%eax)
  freep = p;
 73b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73e:	a3 e4 0a 00 00       	mov    %eax,0xae4
}
 743:	c9                   	leave  
 744:	c3                   	ret    

00000745 <morecore>:

static Header*
morecore(uint nu)
{
 745:	55                   	push   %ebp
 746:	89 e5                	mov    %esp,%ebp
 748:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 74b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 752:	77 07                	ja     75b <morecore+0x16>
    nu = 4096;
 754:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 75b:	8b 45 08             	mov    0x8(%ebp),%eax
 75e:	c1 e0 03             	shl    $0x3,%eax
 761:	89 04 24             	mov    %eax,(%esp)
 764:	e8 97 fb ff ff       	call   300 <sbrk>
 769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 76c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 770:	75 07                	jne    779 <morecore+0x34>
    return 0;
 772:	b8 00 00 00 00       	mov    $0x0,%eax
 777:	eb 22                	jmp    79b <morecore+0x56>
  hp = (Header*)p;
 779:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 77f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 782:	8b 55 08             	mov    0x8(%ebp),%edx
 785:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 788:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78b:	83 c0 08             	add    $0x8,%eax
 78e:	89 04 24             	mov    %eax,(%esp)
 791:	e8 ce fe ff ff       	call   664 <free>
  return freep;
 796:	a1 e4 0a 00 00       	mov    0xae4,%eax
}
 79b:	c9                   	leave  
 79c:	c3                   	ret    

0000079d <malloc>:

void*
malloc(uint nbytes)
{
 79d:	55                   	push   %ebp
 79e:	89 e5                	mov    %esp,%ebp
 7a0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a3:	8b 45 08             	mov    0x8(%ebp),%eax
 7a6:	83 c0 07             	add    $0x7,%eax
 7a9:	c1 e8 03             	shr    $0x3,%eax
 7ac:	40                   	inc    %eax
 7ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7b0:	a1 e4 0a 00 00       	mov    0xae4,%eax
 7b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7bc:	75 23                	jne    7e1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 7be:	c7 45 f0 dc 0a 00 00 	movl   $0xadc,-0x10(%ebp)
 7c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c8:	a3 e4 0a 00 00       	mov    %eax,0xae4
 7cd:	a1 e4 0a 00 00       	mov    0xae4,%eax
 7d2:	a3 dc 0a 00 00       	mov    %eax,0xadc
    base.s.size = 0;
 7d7:	c7 05 e0 0a 00 00 00 	movl   $0x0,0xae0
 7de:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	8b 40 04             	mov    0x4(%eax),%eax
 7ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7f2:	72 4d                	jb     841 <malloc+0xa4>
      if(p->s.size == nunits)
 7f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f7:	8b 40 04             	mov    0x4(%eax),%eax
 7fa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7fd:	75 0c                	jne    80b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	8b 10                	mov    (%eax),%edx
 804:	8b 45 f0             	mov    -0x10(%ebp),%eax
 807:	89 10                	mov    %edx,(%eax)
 809:	eb 26                	jmp    831 <malloc+0x94>
      else {
        p->s.size -= nunits;
 80b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80e:	8b 40 04             	mov    0x4(%eax),%eax
 811:	2b 45 ec             	sub    -0x14(%ebp),%eax
 814:	89 c2                	mov    %eax,%edx
 816:	8b 45 f4             	mov    -0xc(%ebp),%eax
 819:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 81c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81f:	8b 40 04             	mov    0x4(%eax),%eax
 822:	c1 e0 03             	shl    $0x3,%eax
 825:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 828:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 82e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 831:	8b 45 f0             	mov    -0x10(%ebp),%eax
 834:	a3 e4 0a 00 00       	mov    %eax,0xae4
      return (void*)(p + 1);
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	83 c0 08             	add    $0x8,%eax
 83f:	eb 38                	jmp    879 <malloc+0xdc>
    }
    if(p == freep)
 841:	a1 e4 0a 00 00       	mov    0xae4,%eax
 846:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 849:	75 1b                	jne    866 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 84b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 84e:	89 04 24             	mov    %eax,(%esp)
 851:	e8 ef fe ff ff       	call   745 <morecore>
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
 859:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 85d:	75 07                	jne    866 <malloc+0xc9>
        return 0;
 85f:	b8 00 00 00 00       	mov    $0x0,%eax
 864:	eb 13                	jmp    879 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 00                	mov    (%eax),%eax
 871:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 874:	e9 70 ff ff ff       	jmp    7e9 <malloc+0x4c>
}
 879:	c9                   	leave  
 87a:	c3                   	ret    
