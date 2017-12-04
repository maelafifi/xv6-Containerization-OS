
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
   f:	c7 44 24 04 0b 09 00 	movl   $0x90b,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 22 05 00 00       	call   545 <printf>
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
  60:	c7 44 24 04 1e 09 00 	movl   $0x91e,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 d1 04 00 00       	call   545 <printf>
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

00000450 <tmem>:
SYSCALL(tmem)
 450:	b8 32 00 00 00       	mov    $0x32,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <amem>:
SYSCALL(amem)
 458:	b8 33 00 00 00       	mov    $0x33,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <c_ps>:
SYSCALL(c_ps)
 460:	b8 34 00 00 00       	mov    $0x34,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
 46b:	83 ec 18             	sub    $0x18,%esp
 46e:	8b 45 0c             	mov    0xc(%ebp),%eax
 471:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 474:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 47b:	00 
 47c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 47f:	89 44 24 04          	mov    %eax,0x4(%esp)
 483:	8b 45 08             	mov    0x8(%ebp),%eax
 486:	89 04 24             	mov    %eax,(%esp)
 489:	e8 62 fe ff ff       	call   2f0 <write>
}
 48e:	c9                   	leave  
 48f:	c3                   	ret    

00000490 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	56                   	push   %esi
 494:	53                   	push   %ebx
 495:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 498:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 49f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4a3:	74 17                	je     4bc <printint+0x2c>
 4a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4a9:	79 11                	jns    4bc <printint+0x2c>
    neg = 1;
 4ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b5:	f7 d8                	neg    %eax
 4b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ba:	eb 06                	jmp    4c2 <printint+0x32>
  } else {
    x = xx;
 4bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4c9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4cc:	8d 41 01             	lea    0x1(%ecx),%eax
 4cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d8:	ba 00 00 00 00       	mov    $0x0,%edx
 4dd:	f7 f3                	div    %ebx
 4df:	89 d0                	mov    %edx,%eax
 4e1:	8a 80 80 0b 00 00    	mov    0xb80(%eax),%al
 4e7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4eb:	8b 75 10             	mov    0x10(%ebp),%esi
 4ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f1:	ba 00 00 00 00       	mov    $0x0,%edx
 4f6:	f7 f6                	div    %esi
 4f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ff:	75 c8                	jne    4c9 <printint+0x39>
  if(neg)
 501:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 505:	74 10                	je     517 <printint+0x87>
    buf[i++] = '-';
 507:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50a:	8d 50 01             	lea    0x1(%eax),%edx
 50d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 510:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 515:	eb 1e                	jmp    535 <printint+0xa5>
 517:	eb 1c                	jmp    535 <printint+0xa5>
    putc(fd, buf[i]);
 519:	8d 55 dc             	lea    -0x24(%ebp),%edx
 51c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51f:	01 d0                	add    %edx,%eax
 521:	8a 00                	mov    (%eax),%al
 523:	0f be c0             	movsbl %al,%eax
 526:	89 44 24 04          	mov    %eax,0x4(%esp)
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	89 04 24             	mov    %eax,(%esp)
 530:	e8 33 ff ff ff       	call   468 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 535:	ff 4d f4             	decl   -0xc(%ebp)
 538:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53c:	79 db                	jns    519 <printint+0x89>
    putc(fd, buf[i]);
}
 53e:	83 c4 30             	add    $0x30,%esp
 541:	5b                   	pop    %ebx
 542:	5e                   	pop    %esi
 543:	5d                   	pop    %ebp
 544:	c3                   	ret    

00000545 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 545:	55                   	push   %ebp
 546:	89 e5                	mov    %esp,%ebp
 548:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 54b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 552:	8d 45 0c             	lea    0xc(%ebp),%eax
 555:	83 c0 04             	add    $0x4,%eax
 558:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 55b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 562:	e9 77 01 00 00       	jmp    6de <printf+0x199>
    c = fmt[i] & 0xff;
 567:	8b 55 0c             	mov    0xc(%ebp),%edx
 56a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 56d:	01 d0                	add    %edx,%eax
 56f:	8a 00                	mov    (%eax),%al
 571:	0f be c0             	movsbl %al,%eax
 574:	25 ff 00 00 00       	and    $0xff,%eax
 579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 57c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 580:	75 2c                	jne    5ae <printf+0x69>
      if(c == '%'){
 582:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 586:	75 0c                	jne    594 <printf+0x4f>
        state = '%';
 588:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 58f:	e9 47 01 00 00       	jmp    6db <printf+0x196>
      } else {
        putc(fd, c);
 594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	89 44 24 04          	mov    %eax,0x4(%esp)
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 bf fe ff ff       	call   468 <putc>
 5a9:	e9 2d 01 00 00       	jmp    6db <printf+0x196>
      }
    } else if(state == '%'){
 5ae:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5b2:	0f 85 23 01 00 00    	jne    6db <printf+0x196>
      if(c == 'd'){
 5b8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5bc:	75 2d                	jne    5eb <printf+0xa6>
        printint(fd, *ap, 10, 1);
 5be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c1:	8b 00                	mov    (%eax),%eax
 5c3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ca:	00 
 5cb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5d2:	00 
 5d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d7:	8b 45 08             	mov    0x8(%ebp),%eax
 5da:	89 04 24             	mov    %eax,(%esp)
 5dd:	e8 ae fe ff ff       	call   490 <printint>
        ap++;
 5e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e6:	e9 e9 00 00 00       	jmp    6d4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5eb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5ef:	74 06                	je     5f7 <printf+0xb2>
 5f1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5f5:	75 2d                	jne    624 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fa:	8b 00                	mov    (%eax),%eax
 5fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 603:	00 
 604:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 60b:	00 
 60c:	89 44 24 04          	mov    %eax,0x4(%esp)
 610:	8b 45 08             	mov    0x8(%ebp),%eax
 613:	89 04 24             	mov    %eax,(%esp)
 616:	e8 75 fe ff ff       	call   490 <printint>
        ap++;
 61b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61f:	e9 b0 00 00 00       	jmp    6d4 <printf+0x18f>
      } else if(c == 's'){
 624:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 628:	75 42                	jne    66c <printf+0x127>
        s = (char*)*ap;
 62a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62d:	8b 00                	mov    (%eax),%eax
 62f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 632:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 636:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 63a:	75 09                	jne    645 <printf+0x100>
          s = "(null)";
 63c:	c7 45 f4 32 09 00 00 	movl   $0x932,-0xc(%ebp)
        while(*s != 0){
 643:	eb 1c                	jmp    661 <printf+0x11c>
 645:	eb 1a                	jmp    661 <printf+0x11c>
          putc(fd, *s);
 647:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64a:	8a 00                	mov    (%eax),%al
 64c:	0f be c0             	movsbl %al,%eax
 64f:	89 44 24 04          	mov    %eax,0x4(%esp)
 653:	8b 45 08             	mov    0x8(%ebp),%eax
 656:	89 04 24             	mov    %eax,(%esp)
 659:	e8 0a fe ff ff       	call   468 <putc>
          s++;
 65e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 661:	8b 45 f4             	mov    -0xc(%ebp),%eax
 664:	8a 00                	mov    (%eax),%al
 666:	84 c0                	test   %al,%al
 668:	75 dd                	jne    647 <printf+0x102>
 66a:	eb 68                	jmp    6d4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 670:	75 1d                	jne    68f <printf+0x14a>
        putc(fd, *ap);
 672:	8b 45 e8             	mov    -0x18(%ebp),%eax
 675:	8b 00                	mov    (%eax),%eax
 677:	0f be c0             	movsbl %al,%eax
 67a:	89 44 24 04          	mov    %eax,0x4(%esp)
 67e:	8b 45 08             	mov    0x8(%ebp),%eax
 681:	89 04 24             	mov    %eax,(%esp)
 684:	e8 df fd ff ff       	call   468 <putc>
        ap++;
 689:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68d:	eb 45                	jmp    6d4 <printf+0x18f>
      } else if(c == '%'){
 68f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 693:	75 17                	jne    6ac <printf+0x167>
        putc(fd, c);
 695:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 698:	0f be c0             	movsbl %al,%eax
 69b:	89 44 24 04          	mov    %eax,0x4(%esp)
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	89 04 24             	mov    %eax,(%esp)
 6a5:	e8 be fd ff ff       	call   468 <putc>
 6aa:	eb 28                	jmp    6d4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ac:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6b3:	00 
 6b4:	8b 45 08             	mov    0x8(%ebp),%eax
 6b7:	89 04 24             	mov    %eax,(%esp)
 6ba:	e8 a9 fd ff ff       	call   468 <putc>
        putc(fd, c);
 6bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c2:	0f be c0             	movsbl %al,%eax
 6c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	89 04 24             	mov    %eax,(%esp)
 6cf:	e8 94 fd ff ff       	call   468 <putc>
      }
      state = 0;
 6d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6db:	ff 45 f0             	incl   -0x10(%ebp)
 6de:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e4:	01 d0                	add    %edx,%eax
 6e6:	8a 00                	mov    (%eax),%al
 6e8:	84 c0                	test   %al,%al
 6ea:	0f 85 77 fe ff ff    	jne    567 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6f0:	c9                   	leave  
 6f1:	c3                   	ret    
 6f2:	90                   	nop
 6f3:	90                   	nop

000006f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f4:	55                   	push   %ebp
 6f5:	89 e5                	mov    %esp,%ebp
 6f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6fa:	8b 45 08             	mov    0x8(%ebp),%eax
 6fd:	83 e8 08             	sub    $0x8,%eax
 700:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 703:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 708:	89 45 fc             	mov    %eax,-0x4(%ebp)
 70b:	eb 24                	jmp    731 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 715:	77 12                	ja     729 <free+0x35>
 717:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71d:	77 24                	ja     743 <free+0x4f>
 71f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 727:	77 1a                	ja     743 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 729:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72c:	8b 00                	mov    (%eax),%eax
 72e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 731:	8b 45 f8             	mov    -0x8(%ebp),%eax
 734:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 737:	76 d4                	jbe    70d <free+0x19>
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 741:	76 ca                	jbe    70d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 743:	8b 45 f8             	mov    -0x8(%ebp),%eax
 746:	8b 40 04             	mov    0x4(%eax),%eax
 749:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	01 c2                	add    %eax,%edx
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8b 00                	mov    (%eax),%eax
 75a:	39 c2                	cmp    %eax,%edx
 75c:	75 24                	jne    782 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 75e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 761:	8b 50 04             	mov    0x4(%eax),%edx
 764:	8b 45 fc             	mov    -0x4(%ebp),%eax
 767:	8b 00                	mov    (%eax),%eax
 769:	8b 40 04             	mov    0x4(%eax),%eax
 76c:	01 c2                	add    %eax,%edx
 76e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 771:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	8b 00                	mov    (%eax),%eax
 779:	8b 10                	mov    (%eax),%edx
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	89 10                	mov    %edx,(%eax)
 780:	eb 0a                	jmp    78c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 10                	mov    (%eax),%edx
 787:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	8b 40 04             	mov    0x4(%eax),%eax
 792:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	01 d0                	add    %edx,%eax
 79e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a1:	75 20                	jne    7c3 <free+0xcf>
    p->s.size += bp->s.size;
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 50 04             	mov    0x4(%eax),%edx
 7a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ac:	8b 40 04             	mov    0x4(%eax),%eax
 7af:	01 c2                	add    %eax,%edx
 7b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	8b 10                	mov    (%eax),%edx
 7bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bf:	89 10                	mov    %edx,(%eax)
 7c1:	eb 08                	jmp    7cb <free+0xd7>
  } else
    p->s.ptr = bp;
 7c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7c9:	89 10                	mov    %edx,(%eax)
  freep = p;
 7cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ce:	a3 9c 0b 00 00       	mov    %eax,0xb9c
}
 7d3:	c9                   	leave  
 7d4:	c3                   	ret    

000007d5 <morecore>:

static Header*
morecore(uint nu)
{
 7d5:	55                   	push   %ebp
 7d6:	89 e5                	mov    %esp,%ebp
 7d8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7db:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7e2:	77 07                	ja     7eb <morecore+0x16>
    nu = 4096;
 7e4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7eb:	8b 45 08             	mov    0x8(%ebp),%eax
 7ee:	c1 e0 03             	shl    $0x3,%eax
 7f1:	89 04 24             	mov    %eax,(%esp)
 7f4:	e8 5f fb ff ff       	call   358 <sbrk>
 7f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7fc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 800:	75 07                	jne    809 <morecore+0x34>
    return 0;
 802:	b8 00 00 00 00       	mov    $0x0,%eax
 807:	eb 22                	jmp    82b <morecore+0x56>
  hp = (Header*)p;
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 80f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 812:	8b 55 08             	mov    0x8(%ebp),%edx
 815:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 818:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81b:	83 c0 08             	add    $0x8,%eax
 81e:	89 04 24             	mov    %eax,(%esp)
 821:	e8 ce fe ff ff       	call   6f4 <free>
  return freep;
 826:	a1 9c 0b 00 00       	mov    0xb9c,%eax
}
 82b:	c9                   	leave  
 82c:	c3                   	ret    

0000082d <malloc>:

void*
malloc(uint nbytes)
{
 82d:	55                   	push   %ebp
 82e:	89 e5                	mov    %esp,%ebp
 830:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 833:	8b 45 08             	mov    0x8(%ebp),%eax
 836:	83 c0 07             	add    $0x7,%eax
 839:	c1 e8 03             	shr    $0x3,%eax
 83c:	40                   	inc    %eax
 83d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 840:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 845:	89 45 f0             	mov    %eax,-0x10(%ebp)
 848:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 84c:	75 23                	jne    871 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 84e:	c7 45 f0 94 0b 00 00 	movl   $0xb94,-0x10(%ebp)
 855:	8b 45 f0             	mov    -0x10(%ebp),%eax
 858:	a3 9c 0b 00 00       	mov    %eax,0xb9c
 85d:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 862:	a3 94 0b 00 00       	mov    %eax,0xb94
    base.s.size = 0;
 867:	c7 05 98 0b 00 00 00 	movl   $0x0,0xb98
 86e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 871:	8b 45 f0             	mov    -0x10(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 879:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87c:	8b 40 04             	mov    0x4(%eax),%eax
 87f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 882:	72 4d                	jb     8d1 <malloc+0xa4>
      if(p->s.size == nunits)
 884:	8b 45 f4             	mov    -0xc(%ebp),%eax
 887:	8b 40 04             	mov    0x4(%eax),%eax
 88a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 88d:	75 0c                	jne    89b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	8b 10                	mov    (%eax),%edx
 894:	8b 45 f0             	mov    -0x10(%ebp),%eax
 897:	89 10                	mov    %edx,(%eax)
 899:	eb 26                	jmp    8c1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 89b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89e:	8b 40 04             	mov    0x4(%eax),%eax
 8a1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8a4:	89 c2                	mov    %eax,%edx
 8a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	8b 40 04             	mov    0x4(%eax),%eax
 8b2:	c1 e0 03             	shl    $0x3,%eax
 8b5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8be:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	a3 9c 0b 00 00       	mov    %eax,0xb9c
      return (void*)(p + 1);
 8c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cc:	83 c0 08             	add    $0x8,%eax
 8cf:	eb 38                	jmp    909 <malloc+0xdc>
    }
    if(p == freep)
 8d1:	a1 9c 0b 00 00       	mov    0xb9c,%eax
 8d6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8d9:	75 1b                	jne    8f6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8db:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8de:	89 04 24             	mov    %eax,(%esp)
 8e1:	e8 ef fe ff ff       	call   7d5 <morecore>
 8e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ed:	75 07                	jne    8f6 <malloc+0xc9>
        return 0;
 8ef:	b8 00 00 00 00       	mov    $0x0,%eax
 8f4:	eb 13                	jmp    909 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 904:	e9 70 ff ff ff       	jmp    879 <malloc+0x4c>
}
 909:	c9                   	leave  
 90a:	c3                   	ret    
