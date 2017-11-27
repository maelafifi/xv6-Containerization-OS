
_ln:     file format elf32-i386


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
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc != 3){
   9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 a3 08 00 	movl   $0x8a3,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 ba 04 00 00       	call   4dd <printf>
    exit();
  23:	e8 a8 02 00 00       	call   2d0 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 08             	add    $0x8,%eax
  2e:	8b 10                	mov    (%eax),%edx
  30:	8b 45 0c             	mov    0xc(%ebp),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	89 54 24 04          	mov    %edx,0x4(%esp)
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 ec 02 00 00       	call   330 <link>
  44:	85 c0                	test   %eax,%eax
  46:	79 2c                	jns    74 <main+0x74>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	8b 45 0c             	mov    0xc(%ebp),%eax
  4b:	83 c0 08             	add    $0x8,%eax
  4e:	8b 10                	mov    (%eax),%edx
  50:	8b 45 0c             	mov    0xc(%ebp),%eax
  53:	83 c0 04             	add    $0x4,%eax
  56:	8b 00                	mov    (%eax),%eax
  58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  60:	c7 44 24 04 b6 08 00 	movl   $0x8b6,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 69 04 00 00       	call   4dd <printf>
  exit();
  74:	e8 57 02 00 00       	call   2d0 <exit>
  79:	90                   	nop
  7a:	90                   	nop
  7b:	90                   	nop

0000007c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	57                   	push   %edi
  80:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  84:	8b 55 10             	mov    0x10(%ebp),%edx
  87:	8b 45 0c             	mov    0xc(%ebp),%eax
  8a:	89 cb                	mov    %ecx,%ebx
  8c:	89 df                	mov    %ebx,%edi
  8e:	89 d1                	mov    %edx,%ecx
  90:	fc                   	cld    
  91:	f3 aa                	rep stos %al,%es:(%edi)
  93:	89 ca                	mov    %ecx,%edx
  95:	89 fb                	mov    %edi,%ebx
  97:	89 5d 08             	mov    %ebx,0x8(%ebp)
  9a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9d:	5b                   	pop    %ebx
  9e:	5f                   	pop    %edi
  9f:	5d                   	pop    %ebp
  a0:	c3                   	ret    

000000a1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a1:	55                   	push   %ebp
  a2:	89 e5                	mov    %esp,%ebp
  a4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ad:	90                   	nop
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	8d 50 01             	lea    0x1(%eax),%edx
  b4:	89 55 08             	mov    %edx,0x8(%ebp)
  b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  bd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  c0:	8a 12                	mov    (%edx),%dl
  c2:	88 10                	mov    %dl,(%eax)
  c4:	8a 00                	mov    (%eax),%al
  c6:	84 c0                	test   %al,%al
  c8:	75 e4                	jne    ae <strcpy+0xd>
    ;
  return os;
  ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cd:	c9                   	leave  
  ce:	c3                   	ret    

000000cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d2:	eb 06                	jmp    da <strcmp+0xb>
    p++, q++;
  d4:	ff 45 08             	incl   0x8(%ebp)
  d7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	8a 00                	mov    (%eax),%al
  df:	84 c0                	test   %al,%al
  e1:	74 0e                	je     f1 <strcmp+0x22>
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	8a 10                	mov    (%eax),%dl
  e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  eb:	8a 00                	mov    (%eax),%al
  ed:	38 c2                	cmp    %al,%dl
  ef:	74 e3                	je     d4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	8a 00                	mov    (%eax),%al
  f6:	0f b6 d0             	movzbl %al,%edx
  f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  fc:	8a 00                	mov    (%eax),%al
  fe:	0f b6 c0             	movzbl %al,%eax
 101:	29 c2                	sub    %eax,%edx
 103:	89 d0                	mov    %edx,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <strlen>:

uint
strlen(char *s)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 114:	eb 03                	jmp    119 <strlen+0x12>
 116:	ff 45 fc             	incl   -0x4(%ebp)
 119:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	01 d0                	add    %edx,%eax
 121:	8a 00                	mov    (%eax),%al
 123:	84 c0                	test   %al,%al
 125:	75 ef                	jne    116 <strlen+0xf>
    ;
  return n;
 127:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12a:	c9                   	leave  
 12b:	c3                   	ret    

0000012c <memset>:

void*
memset(void *dst, int c, uint n)
{
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 132:	8b 45 10             	mov    0x10(%ebp),%eax
 135:	89 44 24 08          	mov    %eax,0x8(%esp)
 139:	8b 45 0c             	mov    0xc(%ebp),%eax
 13c:	89 44 24 04          	mov    %eax,0x4(%esp)
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	89 04 24             	mov    %eax,(%esp)
 146:	e8 31 ff ff ff       	call   7c <stosb>
  return dst;
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14e:	c9                   	leave  
 14f:	c3                   	ret    

00000150 <strchr>:

char*
strchr(const char *s, char c)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	83 ec 04             	sub    $0x4,%esp
 156:	8b 45 0c             	mov    0xc(%ebp),%eax
 159:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15c:	eb 12                	jmp    170 <strchr+0x20>
    if(*s == c)
 15e:	8b 45 08             	mov    0x8(%ebp),%eax
 161:	8a 00                	mov    (%eax),%al
 163:	3a 45 fc             	cmp    -0x4(%ebp),%al
 166:	75 05                	jne    16d <strchr+0x1d>
      return (char*)s;
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	eb 11                	jmp    17e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 16d:	ff 45 08             	incl   0x8(%ebp)
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	8a 00                	mov    (%eax),%al
 175:	84 c0                	test   %al,%al
 177:	75 e5                	jne    15e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 179:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17e:	c9                   	leave  
 17f:	c3                   	ret    

00000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18d:	eb 49                	jmp    1d8 <gets+0x58>
    cc = read(0, &c, 1);
 18f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 196:	00 
 197:	8d 45 ef             	lea    -0x11(%ebp),%eax
 19a:	89 44 24 04          	mov    %eax,0x4(%esp)
 19e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a5:	e8 3e 01 00 00       	call   2e8 <read>
 1aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b1:	7f 02                	jg     1b5 <gets+0x35>
      break;
 1b3:	eb 2c                	jmp    1e1 <gets+0x61>
    buf[i++] = c;
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	8d 50 01             	lea    0x1(%eax),%edx
 1bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1be:	89 c2                	mov    %eax,%edx
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	01 c2                	add    %eax,%edx
 1c5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ca:	8a 45 ef             	mov    -0x11(%ebp),%al
 1cd:	3c 0a                	cmp    $0xa,%al
 1cf:	74 10                	je     1e1 <gets+0x61>
 1d1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1d4:	3c 0d                	cmp    $0xd,%al
 1d6:	74 09                	je     1e1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1db:	40                   	inc    %eax
 1dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1df:	7c ae                	jl     18f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	01 d0                	add    %edx,%eax
 1e9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ef:	c9                   	leave  
 1f0:	c3                   	ret    

000001f1 <stat>:

int
stat(char *n, struct stat *st)
{
 1f1:	55                   	push   %ebp
 1f2:	89 e5                	mov    %esp,%ebp
 1f4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fe:	00 
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	89 04 24             	mov    %eax,(%esp)
 205:	e8 06 01 00 00       	call   310 <open>
 20a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 211:	79 07                	jns    21a <stat+0x29>
    return -1;
 213:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 218:	eb 23                	jmp    23d <stat+0x4c>
  r = fstat(fd, st);
 21a:	8b 45 0c             	mov    0xc(%ebp),%eax
 21d:	89 44 24 04          	mov    %eax,0x4(%esp)
 221:	8b 45 f4             	mov    -0xc(%ebp),%eax
 224:	89 04 24             	mov    %eax,(%esp)
 227:	e8 fc 00 00 00       	call   328 <fstat>
 22c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 232:	89 04 24             	mov    %eax,(%esp)
 235:	e8 be 00 00 00       	call   2f8 <close>
  return r;
 23a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23d:	c9                   	leave  
 23e:	c3                   	ret    

0000023f <atoi>:

int
atoi(const char *s)
{
 23f:	55                   	push   %ebp
 240:	89 e5                	mov    %esp,%ebp
 242:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 245:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24c:	eb 24                	jmp    272 <atoi+0x33>
    n = n*10 + *s++ - '0';
 24e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 251:	89 d0                	mov    %edx,%eax
 253:	c1 e0 02             	shl    $0x2,%eax
 256:	01 d0                	add    %edx,%eax
 258:	01 c0                	add    %eax,%eax
 25a:	89 c1                	mov    %eax,%ecx
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	8d 50 01             	lea    0x1(%eax),%edx
 262:	89 55 08             	mov    %edx,0x8(%ebp)
 265:	8a 00                	mov    (%eax),%al
 267:	0f be c0             	movsbl %al,%eax
 26a:	01 c8                	add    %ecx,%eax
 26c:	83 e8 30             	sub    $0x30,%eax
 26f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	8a 00                	mov    (%eax),%al
 277:	3c 2f                	cmp    $0x2f,%al
 279:	7e 09                	jle    284 <atoi+0x45>
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	8a 00                	mov    (%eax),%al
 280:	3c 39                	cmp    $0x39,%al
 282:	7e ca                	jle    24e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 284:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 287:	c9                   	leave  
 288:	c3                   	ret    

00000289 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 295:	8b 45 0c             	mov    0xc(%ebp),%eax
 298:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 29b:	eb 16                	jmp    2b3 <memmove+0x2a>
    *dst++ = *src++;
 29d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a0:	8d 50 01             	lea    0x1(%eax),%edx
 2a3:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2a6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2a9:	8d 4a 01             	lea    0x1(%edx),%ecx
 2ac:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2af:	8a 12                	mov    (%edx),%dl
 2b1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b3:	8b 45 10             	mov    0x10(%ebp),%eax
 2b6:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b9:	89 55 10             	mov    %edx,0x10(%ebp)
 2bc:	85 c0                	test   %eax,%eax
 2be:	7f dd                	jg     29d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c3:	c9                   	leave  
 2c4:	c3                   	ret    
 2c5:	90                   	nop
 2c6:	90                   	nop
 2c7:	90                   	nop

000002c8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c8:	b8 01 00 00 00       	mov    $0x1,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <exit>:
SYSCALL(exit)
 2d0:	b8 02 00 00 00       	mov    $0x2,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <wait>:
SYSCALL(wait)
 2d8:	b8 03 00 00 00       	mov    $0x3,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <pipe>:
SYSCALL(pipe)
 2e0:	b8 04 00 00 00       	mov    $0x4,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <read>:
SYSCALL(read)
 2e8:	b8 05 00 00 00       	mov    $0x5,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <write>:
SYSCALL(write)
 2f0:	b8 10 00 00 00       	mov    $0x10,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <close>:
SYSCALL(close)
 2f8:	b8 15 00 00 00       	mov    $0x15,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <kill>:
SYSCALL(kill)
 300:	b8 06 00 00 00       	mov    $0x6,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <exec>:
SYSCALL(exec)
 308:	b8 07 00 00 00       	mov    $0x7,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <open>:
SYSCALL(open)
 310:	b8 0f 00 00 00       	mov    $0xf,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <mknod>:
SYSCALL(mknod)
 318:	b8 11 00 00 00       	mov    $0x11,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <unlink>:
SYSCALL(unlink)
 320:	b8 12 00 00 00       	mov    $0x12,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <fstat>:
SYSCALL(fstat)
 328:	b8 08 00 00 00       	mov    $0x8,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <link>:
SYSCALL(link)
 330:	b8 13 00 00 00       	mov    $0x13,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <mkdir>:
SYSCALL(mkdir)
 338:	b8 14 00 00 00       	mov    $0x14,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <chdir>:
SYSCALL(chdir)
 340:	b8 09 00 00 00       	mov    $0x9,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <dup>:
SYSCALL(dup)
 348:	b8 0a 00 00 00       	mov    $0xa,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <getpid>:
SYSCALL(getpid)
 350:	b8 0b 00 00 00       	mov    $0xb,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <sbrk>:
SYSCALL(sbrk)
 358:	b8 0c 00 00 00       	mov    $0xc,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <sleep>:
SYSCALL(sleep)
 360:	b8 0d 00 00 00       	mov    $0xd,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <uptime>:
SYSCALL(uptime)
 368:	b8 0e 00 00 00       	mov    $0xe,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <getticks>:
SYSCALL(getticks)
 370:	b8 16 00 00 00       	mov    $0x16,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <get_name>:
SYSCALL(get_name)
 378:	b8 17 00 00 00       	mov    $0x17,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <get_max_proc>:
SYSCALL(get_max_proc)
 380:	b8 18 00 00 00       	mov    $0x18,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <get_max_mem>:
SYSCALL(get_max_mem)
 388:	b8 19 00 00 00       	mov    $0x19,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <get_max_disk>:
SYSCALL(get_max_disk)
 390:	b8 1a 00 00 00       	mov    $0x1a,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <get_curr_proc>:
SYSCALL(get_curr_proc)
 398:	b8 1b 00 00 00       	mov    $0x1b,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <get_curr_mem>:
SYSCALL(get_curr_mem)
 3a0:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <get_curr_disk>:
SYSCALL(get_curr_disk)
 3a8:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <set_name>:
SYSCALL(set_name)
 3b0:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <set_max_mem>:
SYSCALL(set_max_mem)
 3b8:	b8 1f 00 00 00       	mov    $0x1f,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <set_max_disk>:
SYSCALL(set_max_disk)
 3c0:	b8 20 00 00 00       	mov    $0x20,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <set_max_proc>:
SYSCALL(set_max_proc)
 3c8:	b8 21 00 00 00       	mov    $0x21,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <set_curr_mem>:
SYSCALL(set_curr_mem)
 3d0:	b8 22 00 00 00       	mov    $0x22,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <set_curr_disk>:
SYSCALL(set_curr_disk)
 3d8:	b8 23 00 00 00       	mov    $0x23,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 3e0:	b8 24 00 00 00       	mov    $0x24,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <find>:
SYSCALL(find)
 3e8:	b8 25 00 00 00       	mov    $0x25,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <is_full>:
SYSCALL(is_full)
 3f0:	b8 26 00 00 00       	mov    $0x26,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <container_init>:
SYSCALL(container_init)
 3f8:	b8 27 00 00 00       	mov    $0x27,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	83 ec 18             	sub    $0x18,%esp
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 40c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 413:	00 
 414:	8d 45 f4             	lea    -0xc(%ebp),%eax
 417:	89 44 24 04          	mov    %eax,0x4(%esp)
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
 41e:	89 04 24             	mov    %eax,(%esp)
 421:	e8 ca fe ff ff       	call   2f0 <write>
}
 426:	c9                   	leave  
 427:	c3                   	ret    

00000428 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 428:	55                   	push   %ebp
 429:	89 e5                	mov    %esp,%ebp
 42b:	56                   	push   %esi
 42c:	53                   	push   %ebx
 42d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 430:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 437:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 43b:	74 17                	je     454 <printint+0x2c>
 43d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 441:	79 11                	jns    454 <printint+0x2c>
    neg = 1;
 443:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 44a:	8b 45 0c             	mov    0xc(%ebp),%eax
 44d:	f7 d8                	neg    %eax
 44f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 452:	eb 06                	jmp    45a <printint+0x32>
  } else {
    x = xx;
 454:	8b 45 0c             	mov    0xc(%ebp),%eax
 457:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 45a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 461:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 464:	8d 41 01             	lea    0x1(%ecx),%eax
 467:	89 45 f4             	mov    %eax,-0xc(%ebp)
 46a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 46d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 470:	ba 00 00 00 00       	mov    $0x0,%edx
 475:	f7 f3                	div    %ebx
 477:	89 d0                	mov    %edx,%eax
 479:	8a 80 18 0b 00 00    	mov    0xb18(%eax),%al
 47f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 483:	8b 75 10             	mov    0x10(%ebp),%esi
 486:	8b 45 ec             	mov    -0x14(%ebp),%eax
 489:	ba 00 00 00 00       	mov    $0x0,%edx
 48e:	f7 f6                	div    %esi
 490:	89 45 ec             	mov    %eax,-0x14(%ebp)
 493:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 497:	75 c8                	jne    461 <printint+0x39>
  if(neg)
 499:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49d:	74 10                	je     4af <printint+0x87>
    buf[i++] = '-';
 49f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a2:	8d 50 01             	lea    0x1(%eax),%edx
 4a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4ad:	eb 1e                	jmp    4cd <printint+0xa5>
 4af:	eb 1c                	jmp    4cd <printint+0xa5>
    putc(fd, buf[i]);
 4b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b7:	01 d0                	add    %edx,%eax
 4b9:	8a 00                	mov    (%eax),%al
 4bb:	0f be c0             	movsbl %al,%eax
 4be:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	89 04 24             	mov    %eax,(%esp)
 4c8:	e8 33 ff ff ff       	call   400 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4cd:	ff 4d f4             	decl   -0xc(%ebp)
 4d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d4:	79 db                	jns    4b1 <printint+0x89>
    putc(fd, buf[i]);
}
 4d6:	83 c4 30             	add    $0x30,%esp
 4d9:	5b                   	pop    %ebx
 4da:	5e                   	pop    %esi
 4db:	5d                   	pop    %ebp
 4dc:	c3                   	ret    

000004dd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4dd:	55                   	push   %ebp
 4de:	89 e5                	mov    %esp,%ebp
 4e0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4ea:	8d 45 0c             	lea    0xc(%ebp),%eax
 4ed:	83 c0 04             	add    $0x4,%eax
 4f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4fa:	e9 77 01 00 00       	jmp    676 <printf+0x199>
    c = fmt[i] & 0xff;
 4ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 502:	8b 45 f0             	mov    -0x10(%ebp),%eax
 505:	01 d0                	add    %edx,%eax
 507:	8a 00                	mov    (%eax),%al
 509:	0f be c0             	movsbl %al,%eax
 50c:	25 ff 00 00 00       	and    $0xff,%eax
 511:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 514:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 518:	75 2c                	jne    546 <printf+0x69>
      if(c == '%'){
 51a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 51e:	75 0c                	jne    52c <printf+0x4f>
        state = '%';
 520:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 527:	e9 47 01 00 00       	jmp    673 <printf+0x196>
      } else {
        putc(fd, c);
 52c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 52f:	0f be c0             	movsbl %al,%eax
 532:	89 44 24 04          	mov    %eax,0x4(%esp)
 536:	8b 45 08             	mov    0x8(%ebp),%eax
 539:	89 04 24             	mov    %eax,(%esp)
 53c:	e8 bf fe ff ff       	call   400 <putc>
 541:	e9 2d 01 00 00       	jmp    673 <printf+0x196>
      }
    } else if(state == '%'){
 546:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 54a:	0f 85 23 01 00 00    	jne    673 <printf+0x196>
      if(c == 'd'){
 550:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 554:	75 2d                	jne    583 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 556:	8b 45 e8             	mov    -0x18(%ebp),%eax
 559:	8b 00                	mov    (%eax),%eax
 55b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 562:	00 
 563:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 56a:	00 
 56b:	89 44 24 04          	mov    %eax,0x4(%esp)
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	89 04 24             	mov    %eax,(%esp)
 575:	e8 ae fe ff ff       	call   428 <printint>
        ap++;
 57a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 57e:	e9 e9 00 00 00       	jmp    66c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 583:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 587:	74 06                	je     58f <printf+0xb2>
 589:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 58d:	75 2d                	jne    5bc <printf+0xdf>
        printint(fd, *ap, 16, 0);
 58f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 592:	8b 00                	mov    (%eax),%eax
 594:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 59b:	00 
 59c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5a3:	00 
 5a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
 5ab:	89 04 24             	mov    %eax,(%esp)
 5ae:	e8 75 fe ff ff       	call   428 <printint>
        ap++;
 5b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b7:	e9 b0 00 00 00       	jmp    66c <printf+0x18f>
      } else if(c == 's'){
 5bc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5c0:	75 42                	jne    604 <printf+0x127>
        s = (char*)*ap;
 5c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d2:	75 09                	jne    5dd <printf+0x100>
          s = "(null)";
 5d4:	c7 45 f4 ca 08 00 00 	movl   $0x8ca,-0xc(%ebp)
        while(*s != 0){
 5db:	eb 1c                	jmp    5f9 <printf+0x11c>
 5dd:	eb 1a                	jmp    5f9 <printf+0x11c>
          putc(fd, *s);
 5df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e2:	8a 00                	mov    (%eax),%al
 5e4:	0f be c0             	movsbl %al,%eax
 5e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	89 04 24             	mov    %eax,(%esp)
 5f1:	e8 0a fe ff ff       	call   400 <putc>
          s++;
 5f6:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fc:	8a 00                	mov    (%eax),%al
 5fe:	84 c0                	test   %al,%al
 600:	75 dd                	jne    5df <printf+0x102>
 602:	eb 68                	jmp    66c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 604:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 608:	75 1d                	jne    627 <printf+0x14a>
        putc(fd, *ap);
 60a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60d:	8b 00                	mov    (%eax),%eax
 60f:	0f be c0             	movsbl %al,%eax
 612:	89 44 24 04          	mov    %eax,0x4(%esp)
 616:	8b 45 08             	mov    0x8(%ebp),%eax
 619:	89 04 24             	mov    %eax,(%esp)
 61c:	e8 df fd ff ff       	call   400 <putc>
        ap++;
 621:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 625:	eb 45                	jmp    66c <printf+0x18f>
      } else if(c == '%'){
 627:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62b:	75 17                	jne    644 <printf+0x167>
        putc(fd, c);
 62d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 630:	0f be c0             	movsbl %al,%eax
 633:	89 44 24 04          	mov    %eax,0x4(%esp)
 637:	8b 45 08             	mov    0x8(%ebp),%eax
 63a:	89 04 24             	mov    %eax,(%esp)
 63d:	e8 be fd ff ff       	call   400 <putc>
 642:	eb 28                	jmp    66c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 644:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 64b:	00 
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
 64f:	89 04 24             	mov    %eax,(%esp)
 652:	e8 a9 fd ff ff       	call   400 <putc>
        putc(fd, c);
 657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65a:	0f be c0             	movsbl %al,%eax
 65d:	89 44 24 04          	mov    %eax,0x4(%esp)
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	89 04 24             	mov    %eax,(%esp)
 667:	e8 94 fd ff ff       	call   400 <putc>
      }
      state = 0;
 66c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 673:	ff 45 f0             	incl   -0x10(%ebp)
 676:	8b 55 0c             	mov    0xc(%ebp),%edx
 679:	8b 45 f0             	mov    -0x10(%ebp),%eax
 67c:	01 d0                	add    %edx,%eax
 67e:	8a 00                	mov    (%eax),%al
 680:	84 c0                	test   %al,%al
 682:	0f 85 77 fe ff ff    	jne    4ff <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 688:	c9                   	leave  
 689:	c3                   	ret    
 68a:	90                   	nop
 68b:	90                   	nop

0000068c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	83 e8 08             	sub    $0x8,%eax
 698:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69b:	a1 34 0b 00 00       	mov    0xb34,%eax
 6a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a3:	eb 24                	jmp    6c9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	8b 00                	mov    (%eax),%eax
 6aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ad:	77 12                	ja     6c1 <free+0x35>
 6af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b5:	77 24                	ja     6db <free+0x4f>
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	8b 00                	mov    (%eax),%eax
 6bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6bf:	77 1a                	ja     6db <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6cf:	76 d4                	jbe    6a5 <free+0x19>
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	8b 00                	mov    (%eax),%eax
 6d6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d9:	76 ca                	jbe    6a5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6de:	8b 40 04             	mov    0x4(%eax),%eax
 6e1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6eb:	01 c2                	add    %eax,%edx
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	39 c2                	cmp    %eax,%edx
 6f4:	75 24                	jne    71a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f9:	8b 50 04             	mov    0x4(%eax),%edx
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 00                	mov    (%eax),%eax
 701:	8b 40 04             	mov    0x4(%eax),%eax
 704:	01 c2                	add    %eax,%edx
 706:	8b 45 f8             	mov    -0x8(%ebp),%eax
 709:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 70c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70f:	8b 00                	mov    (%eax),%eax
 711:	8b 10                	mov    (%eax),%edx
 713:	8b 45 f8             	mov    -0x8(%ebp),%eax
 716:	89 10                	mov    %edx,(%eax)
 718:	eb 0a                	jmp    724 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 71a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71d:	8b 10                	mov    (%eax),%edx
 71f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 722:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 40 04             	mov    0x4(%eax),%eax
 72a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 731:	8b 45 fc             	mov    -0x4(%ebp),%eax
 734:	01 d0                	add    %edx,%eax
 736:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 739:	75 20                	jne    75b <free+0xcf>
    p->s.size += bp->s.size;
 73b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73e:	8b 50 04             	mov    0x4(%eax),%edx
 741:	8b 45 f8             	mov    -0x8(%ebp),%eax
 744:	8b 40 04             	mov    0x4(%eax),%eax
 747:	01 c2                	add    %eax,%edx
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 74f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 752:	8b 10                	mov    (%eax),%edx
 754:	8b 45 fc             	mov    -0x4(%ebp),%eax
 757:	89 10                	mov    %edx,(%eax)
 759:	eb 08                	jmp    763 <free+0xd7>
  } else
    p->s.ptr = bp;
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 761:	89 10                	mov    %edx,(%eax)
  freep = p;
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
 766:	a3 34 0b 00 00       	mov    %eax,0xb34
}
 76b:	c9                   	leave  
 76c:	c3                   	ret    

0000076d <morecore>:

static Header*
morecore(uint nu)
{
 76d:	55                   	push   %ebp
 76e:	89 e5                	mov    %esp,%ebp
 770:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 773:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 77a:	77 07                	ja     783 <morecore+0x16>
    nu = 4096;
 77c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	c1 e0 03             	shl    $0x3,%eax
 789:	89 04 24             	mov    %eax,(%esp)
 78c:	e8 c7 fb ff ff       	call   358 <sbrk>
 791:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 794:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 798:	75 07                	jne    7a1 <morecore+0x34>
    return 0;
 79a:	b8 00 00 00 00       	mov    $0x0,%eax
 79f:	eb 22                	jmp    7c3 <morecore+0x56>
  hp = (Header*)p;
 7a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	8b 55 08             	mov    0x8(%ebp),%edx
 7ad:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b3:	83 c0 08             	add    $0x8,%eax
 7b6:	89 04 24             	mov    %eax,(%esp)
 7b9:	e8 ce fe ff ff       	call   68c <free>
  return freep;
 7be:	a1 34 0b 00 00       	mov    0xb34,%eax
}
 7c3:	c9                   	leave  
 7c4:	c3                   	ret    

000007c5 <malloc>:

void*
malloc(uint nbytes)
{
 7c5:	55                   	push   %ebp
 7c6:	89 e5                	mov    %esp,%ebp
 7c8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7cb:	8b 45 08             	mov    0x8(%ebp),%eax
 7ce:	83 c0 07             	add    $0x7,%eax
 7d1:	c1 e8 03             	shr    $0x3,%eax
 7d4:	40                   	inc    %eax
 7d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7d8:	a1 34 0b 00 00       	mov    0xb34,%eax
 7dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7e4:	75 23                	jne    809 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 7e6:	c7 45 f0 2c 0b 00 00 	movl   $0xb2c,-0x10(%ebp)
 7ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f0:	a3 34 0b 00 00       	mov    %eax,0xb34
 7f5:	a1 34 0b 00 00       	mov    0xb34,%eax
 7fa:	a3 2c 0b 00 00       	mov    %eax,0xb2c
    base.s.size = 0;
 7ff:	c7 05 30 0b 00 00 00 	movl   $0x0,0xb30
 806:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	8b 00                	mov    (%eax),%eax
 80e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	8b 40 04             	mov    0x4(%eax),%eax
 817:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 81a:	72 4d                	jb     869 <malloc+0xa4>
      if(p->s.size == nunits)
 81c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81f:	8b 40 04             	mov    0x4(%eax),%eax
 822:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 825:	75 0c                	jne    833 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 827:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82a:	8b 10                	mov    (%eax),%edx
 82c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82f:	89 10                	mov    %edx,(%eax)
 831:	eb 26                	jmp    859 <malloc+0x94>
      else {
        p->s.size -= nunits;
 833:	8b 45 f4             	mov    -0xc(%ebp),%eax
 836:	8b 40 04             	mov    0x4(%eax),%eax
 839:	2b 45 ec             	sub    -0x14(%ebp),%eax
 83c:	89 c2                	mov    %eax,%edx
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	c1 e0 03             	shl    $0x3,%eax
 84d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 850:	8b 45 f4             	mov    -0xc(%ebp),%eax
 853:	8b 55 ec             	mov    -0x14(%ebp),%edx
 856:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 859:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85c:	a3 34 0b 00 00       	mov    %eax,0xb34
      return (void*)(p + 1);
 861:	8b 45 f4             	mov    -0xc(%ebp),%eax
 864:	83 c0 08             	add    $0x8,%eax
 867:	eb 38                	jmp    8a1 <malloc+0xdc>
    }
    if(p == freep)
 869:	a1 34 0b 00 00       	mov    0xb34,%eax
 86e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 871:	75 1b                	jne    88e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 873:	8b 45 ec             	mov    -0x14(%ebp),%eax
 876:	89 04 24             	mov    %eax,(%esp)
 879:	e8 ef fe ff ff       	call   76d <morecore>
 87e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 885:	75 07                	jne    88e <malloc+0xc9>
        return 0;
 887:	b8 00 00 00 00       	mov    $0x0,%eax
 88c:	eb 13                	jmp    8a1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	89 45 f0             	mov    %eax,-0x10(%ebp)
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 00                	mov    (%eax),%eax
 899:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 89c:	e9 70 ff ff ff       	jmp    811 <malloc+0x4c>
}
 8a1:	c9                   	leave  
 8a2:	c3                   	ret    
