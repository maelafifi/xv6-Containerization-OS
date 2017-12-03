
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
   f:	c7 44 24 04 f3 08 00 	movl   $0x8f3,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 0a 05 00 00       	call   52d <printf>
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
  60:	c7 44 24 04 06 09 00 	movl   $0x906,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 b9 04 00 00       	call   52d <printf>
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

00000400 <cont_proc_set>:
SYSCALL(cont_proc_set)
 400:	b8 28 00 00 00       	mov    $0x28,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <ps>:
SYSCALL(ps)
 408:	b8 29 00 00 00       	mov    $0x29,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 410:	b8 2a 00 00 00       	mov    $0x2a,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <set_root_inode>:
SYSCALL(set_root_inode)
 418:	b8 2b 00 00 00       	mov    $0x2b,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <cstop>:
SYSCALL(cstop)
 420:	b8 2c 00 00 00       	mov    $0x2c,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <df>:
SYSCALL(df)
 428:	b8 2d 00 00 00       	mov    $0x2d,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <max_containers>:
SYSCALL(max_containers)
 430:	b8 2e 00 00 00       	mov    $0x2e,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <container_reset>:
SYSCALL(container_reset)
 438:	b8 2f 00 00 00       	mov    $0x2f,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <pause>:
SYSCALL(pause)
 440:	b8 30 00 00 00       	mov    $0x30,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <resume>:
SYSCALL(resume)
 448:	b8 31 00 00 00       	mov    $0x31,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	83 ec 18             	sub    $0x18,%esp
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 45c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 463:	00 
 464:	8d 45 f4             	lea    -0xc(%ebp),%eax
 467:	89 44 24 04          	mov    %eax,0x4(%esp)
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	89 04 24             	mov    %eax,(%esp)
 471:	e8 7a fe ff ff       	call   2f0 <write>
}
 476:	c9                   	leave  
 477:	c3                   	ret    

00000478 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
 47b:	56                   	push   %esi
 47c:	53                   	push   %ebx
 47d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 480:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 487:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 48b:	74 17                	je     4a4 <printint+0x2c>
 48d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 491:	79 11                	jns    4a4 <printint+0x2c>
    neg = 1;
 493:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49a:	8b 45 0c             	mov    0xc(%ebp),%eax
 49d:	f7 d8                	neg    %eax
 49f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a2:	eb 06                	jmp    4aa <printint+0x32>
  } else {
    x = xx;
 4a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b4:	8d 41 01             	lea    0x1(%ecx),%eax
 4b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c0:	ba 00 00 00 00       	mov    $0x0,%edx
 4c5:	f7 f3                	div    %ebx
 4c7:	89 d0                	mov    %edx,%eax
 4c9:	8a 80 68 0b 00 00    	mov    0xb68(%eax),%al
 4cf:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d3:	8b 75 10             	mov    0x10(%ebp),%esi
 4d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d9:	ba 00 00 00 00       	mov    $0x0,%edx
 4de:	f7 f6                	div    %esi
 4e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e7:	75 c8                	jne    4b1 <printint+0x39>
  if(neg)
 4e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ed:	74 10                	je     4ff <printint+0x87>
    buf[i++] = '-';
 4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f2:	8d 50 01             	lea    0x1(%eax),%edx
 4f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4fd:	eb 1e                	jmp    51d <printint+0xa5>
 4ff:	eb 1c                	jmp    51d <printint+0xa5>
    putc(fd, buf[i]);
 501:	8d 55 dc             	lea    -0x24(%ebp),%edx
 504:	8b 45 f4             	mov    -0xc(%ebp),%eax
 507:	01 d0                	add    %edx,%eax
 509:	8a 00                	mov    (%eax),%al
 50b:	0f be c0             	movsbl %al,%eax
 50e:	89 44 24 04          	mov    %eax,0x4(%esp)
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	89 04 24             	mov    %eax,(%esp)
 518:	e8 33 ff ff ff       	call   450 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 51d:	ff 4d f4             	decl   -0xc(%ebp)
 520:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 524:	79 db                	jns    501 <printint+0x89>
    putc(fd, buf[i]);
}
 526:	83 c4 30             	add    $0x30,%esp
 529:	5b                   	pop    %ebx
 52a:	5e                   	pop    %esi
 52b:	5d                   	pop    %ebp
 52c:	c3                   	ret    

0000052d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 52d:	55                   	push   %ebp
 52e:	89 e5                	mov    %esp,%ebp
 530:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 533:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 53a:	8d 45 0c             	lea    0xc(%ebp),%eax
 53d:	83 c0 04             	add    $0x4,%eax
 540:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 543:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 54a:	e9 77 01 00 00       	jmp    6c6 <printf+0x199>
    c = fmt[i] & 0xff;
 54f:	8b 55 0c             	mov    0xc(%ebp),%edx
 552:	8b 45 f0             	mov    -0x10(%ebp),%eax
 555:	01 d0                	add    %edx,%eax
 557:	8a 00                	mov    (%eax),%al
 559:	0f be c0             	movsbl %al,%eax
 55c:	25 ff 00 00 00       	and    $0xff,%eax
 561:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 564:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 568:	75 2c                	jne    596 <printf+0x69>
      if(c == '%'){
 56a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56e:	75 0c                	jne    57c <printf+0x4f>
        state = '%';
 570:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 577:	e9 47 01 00 00       	jmp    6c3 <printf+0x196>
      } else {
        putc(fd, c);
 57c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57f:	0f be c0             	movsbl %al,%eax
 582:	89 44 24 04          	mov    %eax,0x4(%esp)
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	89 04 24             	mov    %eax,(%esp)
 58c:	e8 bf fe ff ff       	call   450 <putc>
 591:	e9 2d 01 00 00       	jmp    6c3 <printf+0x196>
      }
    } else if(state == '%'){
 596:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 59a:	0f 85 23 01 00 00    	jne    6c3 <printf+0x196>
      if(c == 'd'){
 5a0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a4:	75 2d                	jne    5d3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 5a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a9:	8b 00                	mov    (%eax),%eax
 5ab:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5b2:	00 
 5b3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5ba:	00 
 5bb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	89 04 24             	mov    %eax,(%esp)
 5c5:	e8 ae fe ff ff       	call   478 <printint>
        ap++;
 5ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ce:	e9 e9 00 00 00       	jmp    6bc <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5d3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d7:	74 06                	je     5df <printf+0xb2>
 5d9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5dd:	75 2d                	jne    60c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e2:	8b 00                	mov    (%eax),%eax
 5e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5eb:	00 
 5ec:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5f3:	00 
 5f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f8:	8b 45 08             	mov    0x8(%ebp),%eax
 5fb:	89 04 24             	mov    %eax,(%esp)
 5fe:	e8 75 fe ff ff       	call   478 <printint>
        ap++;
 603:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 607:	e9 b0 00 00 00       	jmp    6bc <printf+0x18f>
      } else if(c == 's'){
 60c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 610:	75 42                	jne    654 <printf+0x127>
        s = (char*)*ap;
 612:	8b 45 e8             	mov    -0x18(%ebp),%eax
 615:	8b 00                	mov    (%eax),%eax
 617:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 61a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 61e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 622:	75 09                	jne    62d <printf+0x100>
          s = "(null)";
 624:	c7 45 f4 1a 09 00 00 	movl   $0x91a,-0xc(%ebp)
        while(*s != 0){
 62b:	eb 1c                	jmp    649 <printf+0x11c>
 62d:	eb 1a                	jmp    649 <printf+0x11c>
          putc(fd, *s);
 62f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 632:	8a 00                	mov    (%eax),%al
 634:	0f be c0             	movsbl %al,%eax
 637:	89 44 24 04          	mov    %eax,0x4(%esp)
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	89 04 24             	mov    %eax,(%esp)
 641:	e8 0a fe ff ff       	call   450 <putc>
          s++;
 646:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 649:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64c:	8a 00                	mov    (%eax),%al
 64e:	84 c0                	test   %al,%al
 650:	75 dd                	jne    62f <printf+0x102>
 652:	eb 68                	jmp    6bc <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 654:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 658:	75 1d                	jne    677 <printf+0x14a>
        putc(fd, *ap);
 65a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	0f be c0             	movsbl %al,%eax
 662:	89 44 24 04          	mov    %eax,0x4(%esp)
 666:	8b 45 08             	mov    0x8(%ebp),%eax
 669:	89 04 24             	mov    %eax,(%esp)
 66c:	e8 df fd ff ff       	call   450 <putc>
        ap++;
 671:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 675:	eb 45                	jmp    6bc <printf+0x18f>
      } else if(c == '%'){
 677:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67b:	75 17                	jne    694 <printf+0x167>
        putc(fd, c);
 67d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 680:	0f be c0             	movsbl %al,%eax
 683:	89 44 24 04          	mov    %eax,0x4(%esp)
 687:	8b 45 08             	mov    0x8(%ebp),%eax
 68a:	89 04 24             	mov    %eax,(%esp)
 68d:	e8 be fd ff ff       	call   450 <putc>
 692:	eb 28                	jmp    6bc <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 694:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 69b:	00 
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
 69f:	89 04 24             	mov    %eax,(%esp)
 6a2:	e8 a9 fd ff ff       	call   450 <putc>
        putc(fd, c);
 6a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6aa:	0f be c0             	movsbl %al,%eax
 6ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b1:	8b 45 08             	mov    0x8(%ebp),%eax
 6b4:	89 04 24             	mov    %eax,(%esp)
 6b7:	e8 94 fd ff ff       	call   450 <putc>
      }
      state = 0;
 6bc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6c3:	ff 45 f0             	incl   -0x10(%ebp)
 6c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cc:	01 d0                	add    %edx,%eax
 6ce:	8a 00                	mov    (%eax),%al
 6d0:	84 c0                	test   %al,%al
 6d2:	0f 85 77 fe ff ff    	jne    54f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6d8:	c9                   	leave  
 6d9:	c3                   	ret    
 6da:	90                   	nop
 6db:	90                   	nop

000006dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6dc:	55                   	push   %ebp
 6dd:	89 e5                	mov    %esp,%ebp
 6df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e2:	8b 45 08             	mov    0x8(%ebp),%eax
 6e5:	83 e8 08             	sub    $0x8,%eax
 6e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6eb:	a1 84 0b 00 00       	mov    0xb84,%eax
 6f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f3:	eb 24                	jmp    719 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fd:	77 12                	ja     711 <free+0x35>
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 705:	77 24                	ja     72b <free+0x4f>
 707:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70f:	77 1a                	ja     72b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	89 45 fc             	mov    %eax,-0x4(%ebp)
 719:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71f:	76 d4                	jbe    6f5 <free+0x19>
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 729:	76 ca                	jbe    6f5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 40 04             	mov    0x4(%eax),%eax
 731:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 738:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73b:	01 c2                	add    %eax,%edx
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	39 c2                	cmp    %eax,%edx
 744:	75 24                	jne    76a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 746:	8b 45 f8             	mov    -0x8(%ebp),%eax
 749:	8b 50 04             	mov    0x4(%eax),%edx
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	8b 40 04             	mov    0x4(%eax),%eax
 754:	01 c2                	add    %eax,%edx
 756:	8b 45 f8             	mov    -0x8(%ebp),%eax
 759:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	8b 10                	mov    (%eax),%edx
 763:	8b 45 f8             	mov    -0x8(%ebp),%eax
 766:	89 10                	mov    %edx,(%eax)
 768:	eb 0a                	jmp    774 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 76a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76d:	8b 10                	mov    (%eax),%edx
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	01 d0                	add    %edx,%eax
 786:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 789:	75 20                	jne    7ab <free+0xcf>
    p->s.size += bp->s.size;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 50 04             	mov    0x4(%eax),%edx
 791:	8b 45 f8             	mov    -0x8(%ebp),%eax
 794:	8b 40 04             	mov    0x4(%eax),%eax
 797:	01 c2                	add    %eax,%edx
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 79f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a2:	8b 10                	mov    (%eax),%edx
 7a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a7:	89 10                	mov    %edx,(%eax)
 7a9:	eb 08                	jmp    7b3 <free+0xd7>
  } else
    p->s.ptr = bp;
 7ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7b1:	89 10                	mov    %edx,(%eax)
  freep = p;
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	a3 84 0b 00 00       	mov    %eax,0xb84
}
 7bb:	c9                   	leave  
 7bc:	c3                   	ret    

000007bd <morecore>:

static Header*
morecore(uint nu)
{
 7bd:	55                   	push   %ebp
 7be:	89 e5                	mov    %esp,%ebp
 7c0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7c3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ca:	77 07                	ja     7d3 <morecore+0x16>
    nu = 4096;
 7cc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7d3:	8b 45 08             	mov    0x8(%ebp),%eax
 7d6:	c1 e0 03             	shl    $0x3,%eax
 7d9:	89 04 24             	mov    %eax,(%esp)
 7dc:	e8 77 fb ff ff       	call   358 <sbrk>
 7e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7e4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7e8:	75 07                	jne    7f1 <morecore+0x34>
    return 0;
 7ea:	b8 00 00 00 00       	mov    $0x0,%eax
 7ef:	eb 22                	jmp    813 <morecore+0x56>
  hp = (Header*)p;
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fa:	8b 55 08             	mov    0x8(%ebp),%edx
 7fd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 800:	8b 45 f0             	mov    -0x10(%ebp),%eax
 803:	83 c0 08             	add    $0x8,%eax
 806:	89 04 24             	mov    %eax,(%esp)
 809:	e8 ce fe ff ff       	call   6dc <free>
  return freep;
 80e:	a1 84 0b 00 00       	mov    0xb84,%eax
}
 813:	c9                   	leave  
 814:	c3                   	ret    

00000815 <malloc>:

void*
malloc(uint nbytes)
{
 815:	55                   	push   %ebp
 816:	89 e5                	mov    %esp,%ebp
 818:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81b:	8b 45 08             	mov    0x8(%ebp),%eax
 81e:	83 c0 07             	add    $0x7,%eax
 821:	c1 e8 03             	shr    $0x3,%eax
 824:	40                   	inc    %eax
 825:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 828:	a1 84 0b 00 00       	mov    0xb84,%eax
 82d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 830:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 834:	75 23                	jne    859 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 836:	c7 45 f0 7c 0b 00 00 	movl   $0xb7c,-0x10(%ebp)
 83d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 840:	a3 84 0b 00 00       	mov    %eax,0xb84
 845:	a1 84 0b 00 00       	mov    0xb84,%eax
 84a:	a3 7c 0b 00 00       	mov    %eax,0xb7c
    base.s.size = 0;
 84f:	c7 05 80 0b 00 00 00 	movl   $0x0,0xb80
 856:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 859:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 861:	8b 45 f4             	mov    -0xc(%ebp),%eax
 864:	8b 40 04             	mov    0x4(%eax),%eax
 867:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86a:	72 4d                	jb     8b9 <malloc+0xa4>
      if(p->s.size == nunits)
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 40 04             	mov    0x4(%eax),%eax
 872:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 875:	75 0c                	jne    883 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 877:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87a:	8b 10                	mov    (%eax),%edx
 87c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87f:	89 10                	mov    %edx,(%eax)
 881:	eb 26                	jmp    8a9 <malloc+0x94>
      else {
        p->s.size -= nunits;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	2b 45 ec             	sub    -0x14(%ebp),%eax
 88c:	89 c2                	mov    %eax,%edx
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 40 04             	mov    0x4(%eax),%eax
 89a:	c1 e0 03             	shl    $0x3,%eax
 89d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8a6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ac:	a3 84 0b 00 00       	mov    %eax,0xb84
      return (void*)(p + 1);
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	83 c0 08             	add    $0x8,%eax
 8b7:	eb 38                	jmp    8f1 <malloc+0xdc>
    }
    if(p == freep)
 8b9:	a1 84 0b 00 00       	mov    0xb84,%eax
 8be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8c1:	75 1b                	jne    8de <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c6:	89 04 24             	mov    %eax,(%esp)
 8c9:	e8 ef fe ff ff       	call   7bd <morecore>
 8ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d5:	75 07                	jne    8de <malloc+0xc9>
        return 0;
 8d7:	b8 00 00 00 00       	mov    $0x0,%eax
 8dc:	eb 13                	jmp    8f1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	8b 00                	mov    (%eax),%eax
 8e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8ec:	e9 70 ff ff ff       	jmp    861 <malloc+0x4c>
}
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    
