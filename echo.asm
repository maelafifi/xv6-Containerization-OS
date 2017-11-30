
_echo:     file format elf32-i386


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

  for(i = 1; i < argc; i++)
   9:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  10:	00 
  11:	eb 48                	jmp    5b <main+0x5b>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  17:	40                   	inc    %eax
  18:	3b 45 08             	cmp    0x8(%ebp),%eax
  1b:	7d 07                	jge    24 <main+0x24>
  1d:	b8 bb 08 00 00       	mov    $0x8bb,%eax
  22:	eb 05                	jmp    29 <main+0x29>
  24:	b8 bd 08 00 00       	mov    $0x8bd,%eax
  29:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2d:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  34:	8b 55 0c             	mov    0xc(%ebp),%edx
  37:	01 ca                	add    %ecx,%edx
  39:	8b 12                	mov    (%edx),%edx
  3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  43:	c7 44 24 04 bf 08 00 	movl   $0x8bf,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 9e 04 00 00       	call   4f5 <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
  57:	ff 44 24 1c          	incl   0x1c(%esp)
  5b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5f:	3b 45 08             	cmp    0x8(%ebp),%eax
  62:	7c af                	jl     13 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
  64:	e8 57 02 00 00       	call   2c0 <exit>
  69:	90                   	nop
  6a:	90                   	nop
  6b:	90                   	nop

0000006c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	57                   	push   %edi
  70:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  74:	8b 55 10             	mov    0x10(%ebp),%edx
  77:	8b 45 0c             	mov    0xc(%ebp),%eax
  7a:	89 cb                	mov    %ecx,%ebx
  7c:	89 df                	mov    %ebx,%edi
  7e:	89 d1                	mov    %edx,%ecx
  80:	fc                   	cld    
  81:	f3 aa                	rep stos %al,%es:(%edi)
  83:	89 ca                	mov    %ecx,%edx
  85:	89 fb                	mov    %edi,%ebx
  87:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  8d:	5b                   	pop    %ebx
  8e:	5f                   	pop    %edi
  8f:	5d                   	pop    %ebp
  90:	c3                   	ret    

00000091 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  91:	55                   	push   %ebp
  92:	89 e5                	mov    %esp,%ebp
  94:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  97:	8b 45 08             	mov    0x8(%ebp),%eax
  9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  9d:	90                   	nop
  9e:	8b 45 08             	mov    0x8(%ebp),%eax
  a1:	8d 50 01             	lea    0x1(%eax),%edx
  a4:	89 55 08             	mov    %edx,0x8(%ebp)
  a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  ad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  b0:	8a 12                	mov    (%edx),%dl
  b2:	88 10                	mov    %dl,(%eax)
  b4:	8a 00                	mov    (%eax),%al
  b6:	84 c0                	test   %al,%al
  b8:	75 e4                	jne    9e <strcpy+0xd>
    ;
  return os;
  ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bd:	c9                   	leave  
  be:	c3                   	ret    

000000bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bf:	55                   	push   %ebp
  c0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c2:	eb 06                	jmp    ca <strcmp+0xb>
    p++, q++;
  c4:	ff 45 08             	incl   0x8(%ebp)
  c7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	8a 00                	mov    (%eax),%al
  cf:	84 c0                	test   %al,%al
  d1:	74 0e                	je     e1 <strcmp+0x22>
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	8a 10                	mov    (%eax),%dl
  d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  db:	8a 00                	mov    (%eax),%al
  dd:	38 c2                	cmp    %al,%dl
  df:	74 e3                	je     c4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	8a 00                	mov    (%eax),%al
  e6:	0f b6 d0             	movzbl %al,%edx
  e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  ec:	8a 00                	mov    (%eax),%al
  ee:	0f b6 c0             	movzbl %al,%eax
  f1:	29 c2                	sub    %eax,%edx
  f3:	89 d0                	mov    %edx,%eax
}
  f5:	5d                   	pop    %ebp
  f6:	c3                   	ret    

000000f7 <strlen>:

uint
strlen(char *s)
{
  f7:	55                   	push   %ebp
  f8:	89 e5                	mov    %esp,%ebp
  fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 104:	eb 03                	jmp    109 <strlen+0x12>
 106:	ff 45 fc             	incl   -0x4(%ebp)
 109:	8b 55 fc             	mov    -0x4(%ebp),%edx
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	01 d0                	add    %edx,%eax
 111:	8a 00                	mov    (%eax),%al
 113:	84 c0                	test   %al,%al
 115:	75 ef                	jne    106 <strlen+0xf>
    ;
  return n;
 117:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 11a:	c9                   	leave  
 11b:	c3                   	ret    

0000011c <memset>:

void*
memset(void *dst, int c, uint n)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 122:	8b 45 10             	mov    0x10(%ebp),%eax
 125:	89 44 24 08          	mov    %eax,0x8(%esp)
 129:	8b 45 0c             	mov    0xc(%ebp),%eax
 12c:	89 44 24 04          	mov    %eax,0x4(%esp)
 130:	8b 45 08             	mov    0x8(%ebp),%eax
 133:	89 04 24             	mov    %eax,(%esp)
 136:	e8 31 ff ff ff       	call   6c <stosb>
  return dst;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <strchr>:

char*
strchr(const char *s, char c)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	83 ec 04             	sub    $0x4,%esp
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 14c:	eb 12                	jmp    160 <strchr+0x20>
    if(*s == c)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	8a 00                	mov    (%eax),%al
 153:	3a 45 fc             	cmp    -0x4(%ebp),%al
 156:	75 05                	jne    15d <strchr+0x1d>
      return (char*)s;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	eb 11                	jmp    16e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 15d:	ff 45 08             	incl   0x8(%ebp)
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	8a 00                	mov    (%eax),%al
 165:	84 c0                	test   %al,%al
 167:	75 e5                	jne    14e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 169:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16e:	c9                   	leave  
 16f:	c3                   	ret    

00000170 <gets>:

char*
gets(char *buf, int max)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 176:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 17d:	eb 49                	jmp    1c8 <gets+0x58>
    cc = read(0, &c, 1);
 17f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 186:	00 
 187:	8d 45 ef             	lea    -0x11(%ebp),%eax
 18a:	89 44 24 04          	mov    %eax,0x4(%esp)
 18e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 195:	e8 3e 01 00 00       	call   2d8 <read>
 19a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 19d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a1:	7f 02                	jg     1a5 <gets+0x35>
      break;
 1a3:	eb 2c                	jmp    1d1 <gets+0x61>
    buf[i++] = c;
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	8d 50 01             	lea    0x1(%eax),%edx
 1ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ae:	89 c2                	mov    %eax,%edx
 1b0:	8b 45 08             	mov    0x8(%ebp),%eax
 1b3:	01 c2                	add    %eax,%edx
 1b5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ba:	8a 45 ef             	mov    -0x11(%ebp),%al
 1bd:	3c 0a                	cmp    $0xa,%al
 1bf:	74 10                	je     1d1 <gets+0x61>
 1c1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c4:	3c 0d                	cmp    $0xd,%al
 1c6:	74 09                	je     1d1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cb:	40                   	inc    %eax
 1cc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1cf:	7c ae                	jl     17f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	01 d0                	add    %edx,%eax
 1d9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <stat>:

int
stat(char *n, struct stat *st)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1ee:	00 
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	89 04 24             	mov    %eax,(%esp)
 1f5:	e8 06 01 00 00       	call   300 <open>
 1fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 201:	79 07                	jns    20a <stat+0x29>
    return -1;
 203:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 208:	eb 23                	jmp    22d <stat+0x4c>
  r = fstat(fd, st);
 20a:	8b 45 0c             	mov    0xc(%ebp),%eax
 20d:	89 44 24 04          	mov    %eax,0x4(%esp)
 211:	8b 45 f4             	mov    -0xc(%ebp),%eax
 214:	89 04 24             	mov    %eax,(%esp)
 217:	e8 fc 00 00 00       	call   318 <fstat>
 21c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 21f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 222:	89 04 24             	mov    %eax,(%esp)
 225:	e8 be 00 00 00       	call   2e8 <close>
  return r;
 22a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <atoi>:

int
atoi(const char *s)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 235:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 23c:	eb 24                	jmp    262 <atoi+0x33>
    n = n*10 + *s++ - '0';
 23e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 241:	89 d0                	mov    %edx,%eax
 243:	c1 e0 02             	shl    $0x2,%eax
 246:	01 d0                	add    %edx,%eax
 248:	01 c0                	add    %eax,%eax
 24a:	89 c1                	mov    %eax,%ecx
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	8d 50 01             	lea    0x1(%eax),%edx
 252:	89 55 08             	mov    %edx,0x8(%ebp)
 255:	8a 00                	mov    (%eax),%al
 257:	0f be c0             	movsbl %al,%eax
 25a:	01 c8                	add    %ecx,%eax
 25c:	83 e8 30             	sub    $0x30,%eax
 25f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	8a 00                	mov    (%eax),%al
 267:	3c 2f                	cmp    $0x2f,%al
 269:	7e 09                	jle    274 <atoi+0x45>
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	8a 00                	mov    (%eax),%al
 270:	3c 39                	cmp    $0x39,%al
 272:	7e ca                	jle    23e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 274:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 285:	8b 45 0c             	mov    0xc(%ebp),%eax
 288:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 28b:	eb 16                	jmp    2a3 <memmove+0x2a>
    *dst++ = *src++;
 28d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 290:	8d 50 01             	lea    0x1(%eax),%edx
 293:	89 55 fc             	mov    %edx,-0x4(%ebp)
 296:	8b 55 f8             	mov    -0x8(%ebp),%edx
 299:	8d 4a 01             	lea    0x1(%edx),%ecx
 29c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 29f:	8a 12                	mov    (%edx),%dl
 2a1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a3:	8b 45 10             	mov    0x10(%ebp),%eax
 2a6:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a9:	89 55 10             	mov    %edx,0x10(%ebp)
 2ac:	85 c0                	test   %eax,%eax
 2ae:	7f dd                	jg     28d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    
 2b5:	90                   	nop
 2b6:	90                   	nop
 2b7:	90                   	nop

000002b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b8:	b8 01 00 00 00       	mov    $0x1,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exit>:
SYSCALL(exit)
 2c0:	b8 02 00 00 00       	mov    $0x2,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <wait>:
SYSCALL(wait)
 2c8:	b8 03 00 00 00       	mov    $0x3,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <pipe>:
SYSCALL(pipe)
 2d0:	b8 04 00 00 00       	mov    $0x4,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <read>:
SYSCALL(read)
 2d8:	b8 05 00 00 00       	mov    $0x5,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <write>:
SYSCALL(write)
 2e0:	b8 10 00 00 00       	mov    $0x10,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <close>:
SYSCALL(close)
 2e8:	b8 15 00 00 00       	mov    $0x15,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <kill>:
SYSCALL(kill)
 2f0:	b8 06 00 00 00       	mov    $0x6,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exec>:
SYSCALL(exec)
 2f8:	b8 07 00 00 00       	mov    $0x7,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <open>:
SYSCALL(open)
 300:	b8 0f 00 00 00       	mov    $0xf,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <mknod>:
SYSCALL(mknod)
 308:	b8 11 00 00 00       	mov    $0x11,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <unlink>:
SYSCALL(unlink)
 310:	b8 12 00 00 00       	mov    $0x12,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <fstat>:
SYSCALL(fstat)
 318:	b8 08 00 00 00       	mov    $0x8,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <link>:
SYSCALL(link)
 320:	b8 13 00 00 00       	mov    $0x13,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <mkdir>:
SYSCALL(mkdir)
 328:	b8 14 00 00 00       	mov    $0x14,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <chdir>:
SYSCALL(chdir)
 330:	b8 09 00 00 00       	mov    $0x9,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <dup>:
SYSCALL(dup)
 338:	b8 0a 00 00 00       	mov    $0xa,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <getpid>:
SYSCALL(getpid)
 340:	b8 0b 00 00 00       	mov    $0xb,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <sbrk>:
SYSCALL(sbrk)
 348:	b8 0c 00 00 00       	mov    $0xc,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <sleep>:
SYSCALL(sleep)
 350:	b8 0d 00 00 00       	mov    $0xd,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <uptime>:
SYSCALL(uptime)
 358:	b8 0e 00 00 00       	mov    $0xe,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <getticks>:
SYSCALL(getticks)
 360:	b8 16 00 00 00       	mov    $0x16,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <get_name>:
SYSCALL(get_name)
 368:	b8 17 00 00 00       	mov    $0x17,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <get_max_proc>:
SYSCALL(get_max_proc)
 370:	b8 18 00 00 00       	mov    $0x18,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <get_max_mem>:
SYSCALL(get_max_mem)
 378:	b8 19 00 00 00       	mov    $0x19,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <get_max_disk>:
SYSCALL(get_max_disk)
 380:	b8 1a 00 00 00       	mov    $0x1a,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <get_curr_proc>:
SYSCALL(get_curr_proc)
 388:	b8 1b 00 00 00       	mov    $0x1b,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <get_curr_mem>:
SYSCALL(get_curr_mem)
 390:	b8 1c 00 00 00       	mov    $0x1c,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <get_curr_disk>:
SYSCALL(get_curr_disk)
 398:	b8 1d 00 00 00       	mov    $0x1d,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <set_name>:
SYSCALL(set_name)
 3a0:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <set_max_mem>:
SYSCALL(set_max_mem)
 3a8:	b8 1f 00 00 00       	mov    $0x1f,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <set_max_disk>:
SYSCALL(set_max_disk)
 3b0:	b8 20 00 00 00       	mov    $0x20,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <set_max_proc>:
SYSCALL(set_max_proc)
 3b8:	b8 21 00 00 00       	mov    $0x21,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <set_curr_mem>:
SYSCALL(set_curr_mem)
 3c0:	b8 22 00 00 00       	mov    $0x22,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <set_curr_disk>:
SYSCALL(set_curr_disk)
 3c8:	b8 23 00 00 00       	mov    $0x23,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 3d0:	b8 24 00 00 00       	mov    $0x24,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <find>:
SYSCALL(find)
 3d8:	b8 25 00 00 00       	mov    $0x25,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <is_full>:
SYSCALL(is_full)
 3e0:	b8 26 00 00 00       	mov    $0x26,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <container_init>:
SYSCALL(container_init)
 3e8:	b8 27 00 00 00       	mov    $0x27,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <cont_proc_set>:
SYSCALL(cont_proc_set)
 3f0:	b8 28 00 00 00       	mov    $0x28,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <ps>:
SYSCALL(ps)
 3f8:	b8 29 00 00 00       	mov    $0x29,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 400:	b8 2a 00 00 00       	mov    $0x2a,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <set_root_inode>:
SYSCALL(set_root_inode)
 408:	b8 2b 00 00 00       	mov    $0x2b,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <cstop>:
 410:	b8 2c 00 00 00       	mov    $0x2c,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 18             	sub    $0x18,%esp
 41e:	8b 45 0c             	mov    0xc(%ebp),%eax
 421:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 424:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 42b:	00 
 42c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 42f:	89 44 24 04          	mov    %eax,0x4(%esp)
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	89 04 24             	mov    %eax,(%esp)
 439:	e8 a2 fe ff ff       	call   2e0 <write>
}
 43e:	c9                   	leave  
 43f:	c3                   	ret    

00000440 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	56                   	push   %esi
 444:	53                   	push   %ebx
 445:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 448:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 44f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 453:	74 17                	je     46c <printint+0x2c>
 455:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 459:	79 11                	jns    46c <printint+0x2c>
    neg = 1;
 45b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 462:	8b 45 0c             	mov    0xc(%ebp),%eax
 465:	f7 d8                	neg    %eax
 467:	89 45 ec             	mov    %eax,-0x14(%ebp)
 46a:	eb 06                	jmp    472 <printint+0x32>
  } else {
    x = xx;
 46c:	8b 45 0c             	mov    0xc(%ebp),%eax
 46f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 479:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 47c:	8d 41 01             	lea    0x1(%ecx),%eax
 47f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 482:	8b 5d 10             	mov    0x10(%ebp),%ebx
 485:	8b 45 ec             	mov    -0x14(%ebp),%eax
 488:	ba 00 00 00 00       	mov    $0x0,%edx
 48d:	f7 f3                	div    %ebx
 48f:	89 d0                	mov    %edx,%eax
 491:	8a 80 10 0b 00 00    	mov    0xb10(%eax),%al
 497:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 49b:	8b 75 10             	mov    0x10(%ebp),%esi
 49e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a1:	ba 00 00 00 00       	mov    $0x0,%edx
 4a6:	f7 f6                	div    %esi
 4a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4af:	75 c8                	jne    479 <printint+0x39>
  if(neg)
 4b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b5:	74 10                	je     4c7 <printint+0x87>
    buf[i++] = '-';
 4b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ba:	8d 50 01             	lea    0x1(%eax),%edx
 4bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4c5:	eb 1e                	jmp    4e5 <printint+0xa5>
 4c7:	eb 1c                	jmp    4e5 <printint+0xa5>
    putc(fd, buf[i]);
 4c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4cf:	01 d0                	add    %edx,%eax
 4d1:	8a 00                	mov    (%eax),%al
 4d3:	0f be c0             	movsbl %al,%eax
 4d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	89 04 24             	mov    %eax,(%esp)
 4e0:	e8 33 ff ff ff       	call   418 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4e5:	ff 4d f4             	decl   -0xc(%ebp)
 4e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ec:	79 db                	jns    4c9 <printint+0x89>
    putc(fd, buf[i]);
}
 4ee:	83 c4 30             	add    $0x30,%esp
 4f1:	5b                   	pop    %ebx
 4f2:	5e                   	pop    %esi
 4f3:	5d                   	pop    %ebp
 4f4:	c3                   	ret    

000004f5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f5:	55                   	push   %ebp
 4f6:	89 e5                	mov    %esp,%ebp
 4f8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 502:	8d 45 0c             	lea    0xc(%ebp),%eax
 505:	83 c0 04             	add    $0x4,%eax
 508:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 50b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 512:	e9 77 01 00 00       	jmp    68e <printf+0x199>
    c = fmt[i] & 0xff;
 517:	8b 55 0c             	mov    0xc(%ebp),%edx
 51a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 51d:	01 d0                	add    %edx,%eax
 51f:	8a 00                	mov    (%eax),%al
 521:	0f be c0             	movsbl %al,%eax
 524:	25 ff 00 00 00       	and    $0xff,%eax
 529:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 52c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 530:	75 2c                	jne    55e <printf+0x69>
      if(c == '%'){
 532:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 536:	75 0c                	jne    544 <printf+0x4f>
        state = '%';
 538:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 53f:	e9 47 01 00 00       	jmp    68b <printf+0x196>
      } else {
        putc(fd, c);
 544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 547:	0f be c0             	movsbl %al,%eax
 54a:	89 44 24 04          	mov    %eax,0x4(%esp)
 54e:	8b 45 08             	mov    0x8(%ebp),%eax
 551:	89 04 24             	mov    %eax,(%esp)
 554:	e8 bf fe ff ff       	call   418 <putc>
 559:	e9 2d 01 00 00       	jmp    68b <printf+0x196>
      }
    } else if(state == '%'){
 55e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 562:	0f 85 23 01 00 00    	jne    68b <printf+0x196>
      if(c == 'd'){
 568:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 56c:	75 2d                	jne    59b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 56e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 571:	8b 00                	mov    (%eax),%eax
 573:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 57a:	00 
 57b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 582:	00 
 583:	89 44 24 04          	mov    %eax,0x4(%esp)
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	89 04 24             	mov    %eax,(%esp)
 58d:	e8 ae fe ff ff       	call   440 <printint>
        ap++;
 592:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 596:	e9 e9 00 00 00       	jmp    684 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 59b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 59f:	74 06                	je     5a7 <printf+0xb2>
 5a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5a5:	75 2d                	jne    5d4 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5aa:	8b 00                	mov    (%eax),%eax
 5ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5b3:	00 
 5b4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5bb:	00 
 5bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c0:	8b 45 08             	mov    0x8(%ebp),%eax
 5c3:	89 04 24             	mov    %eax,(%esp)
 5c6:	e8 75 fe ff ff       	call   440 <printint>
        ap++;
 5cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cf:	e9 b0 00 00 00       	jmp    684 <printf+0x18f>
      } else if(c == 's'){
 5d4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5d8:	75 42                	jne    61c <printf+0x127>
        s = (char*)*ap;
 5da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dd:	8b 00                	mov    (%eax),%eax
 5df:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ea:	75 09                	jne    5f5 <printf+0x100>
          s = "(null)";
 5ec:	c7 45 f4 c4 08 00 00 	movl   $0x8c4,-0xc(%ebp)
        while(*s != 0){
 5f3:	eb 1c                	jmp    611 <printf+0x11c>
 5f5:	eb 1a                	jmp    611 <printf+0x11c>
          putc(fd, *s);
 5f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fa:	8a 00                	mov    (%eax),%al
 5fc:	0f be c0             	movsbl %al,%eax
 5ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 603:	8b 45 08             	mov    0x8(%ebp),%eax
 606:	89 04 24             	mov    %eax,(%esp)
 609:	e8 0a fe ff ff       	call   418 <putc>
          s++;
 60e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 611:	8b 45 f4             	mov    -0xc(%ebp),%eax
 614:	8a 00                	mov    (%eax),%al
 616:	84 c0                	test   %al,%al
 618:	75 dd                	jne    5f7 <printf+0x102>
 61a:	eb 68                	jmp    684 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 61c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 620:	75 1d                	jne    63f <printf+0x14a>
        putc(fd, *ap);
 622:	8b 45 e8             	mov    -0x18(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	0f be c0             	movsbl %al,%eax
 62a:	89 44 24 04          	mov    %eax,0x4(%esp)
 62e:	8b 45 08             	mov    0x8(%ebp),%eax
 631:	89 04 24             	mov    %eax,(%esp)
 634:	e8 df fd ff ff       	call   418 <putc>
        ap++;
 639:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 63d:	eb 45                	jmp    684 <printf+0x18f>
      } else if(c == '%'){
 63f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 643:	75 17                	jne    65c <printf+0x167>
        putc(fd, c);
 645:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 648:	0f be c0             	movsbl %al,%eax
 64b:	89 44 24 04          	mov    %eax,0x4(%esp)
 64f:	8b 45 08             	mov    0x8(%ebp),%eax
 652:	89 04 24             	mov    %eax,(%esp)
 655:	e8 be fd ff ff       	call   418 <putc>
 65a:	eb 28                	jmp    684 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 65c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 663:	00 
 664:	8b 45 08             	mov    0x8(%ebp),%eax
 667:	89 04 24             	mov    %eax,(%esp)
 66a:	e8 a9 fd ff ff       	call   418 <putc>
        putc(fd, c);
 66f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 672:	0f be c0             	movsbl %al,%eax
 675:	89 44 24 04          	mov    %eax,0x4(%esp)
 679:	8b 45 08             	mov    0x8(%ebp),%eax
 67c:	89 04 24             	mov    %eax,(%esp)
 67f:	e8 94 fd ff ff       	call   418 <putc>
      }
      state = 0;
 684:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 68b:	ff 45 f0             	incl   -0x10(%ebp)
 68e:	8b 55 0c             	mov    0xc(%ebp),%edx
 691:	8b 45 f0             	mov    -0x10(%ebp),%eax
 694:	01 d0                	add    %edx,%eax
 696:	8a 00                	mov    (%eax),%al
 698:	84 c0                	test   %al,%al
 69a:	0f 85 77 fe ff ff    	jne    517 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6a0:	c9                   	leave  
 6a1:	c3                   	ret    
 6a2:	90                   	nop
 6a3:	90                   	nop

000006a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a4:	55                   	push   %ebp
 6a5:	89 e5                	mov    %esp,%ebp
 6a7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6aa:	8b 45 08             	mov    0x8(%ebp),%eax
 6ad:	83 e8 08             	sub    $0x8,%eax
 6b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b3:	a1 2c 0b 00 00       	mov    0xb2c,%eax
 6b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bb:	eb 24                	jmp    6e1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c5:	77 12                	ja     6d9 <free+0x35>
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6cd:	77 24                	ja     6f3 <free+0x4f>
 6cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d2:	8b 00                	mov    (%eax),%eax
 6d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d7:	77 1a                	ja     6f3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e7:	76 d4                	jbe    6bd <free+0x19>
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f1:	76 ca                	jbe    6bd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f6:	8b 40 04             	mov    0x4(%eax),%eax
 6f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	01 c2                	add    %eax,%edx
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	39 c2                	cmp    %eax,%edx
 70c:	75 24                	jne    732 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	8b 50 04             	mov    0x4(%eax),%edx
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	8b 40 04             	mov    0x4(%eax),%eax
 71c:	01 c2                	add    %eax,%edx
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	8b 10                	mov    (%eax),%edx
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	89 10                	mov    %edx,(%eax)
 730:	eb 0a                	jmp    73c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	8b 10                	mov    (%eax),%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 40 04             	mov    0x4(%eax),%eax
 742:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	01 d0                	add    %edx,%eax
 74e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 751:	75 20                	jne    773 <free+0xcf>
    p->s.size += bp->s.size;
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	8b 50 04             	mov    0x4(%eax),%edx
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	01 c2                	add    %eax,%edx
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	8b 10                	mov    (%eax),%edx
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	89 10                	mov    %edx,(%eax)
 771:	eb 08                	jmp    77b <free+0xd7>
  } else
    p->s.ptr = bp;
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	8b 55 f8             	mov    -0x8(%ebp),%edx
 779:	89 10                	mov    %edx,(%eax)
  freep = p;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	a3 2c 0b 00 00       	mov    %eax,0xb2c
}
 783:	c9                   	leave  
 784:	c3                   	ret    

00000785 <morecore>:

static Header*
morecore(uint nu)
{
 785:	55                   	push   %ebp
 786:	89 e5                	mov    %esp,%ebp
 788:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 78b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 792:	77 07                	ja     79b <morecore+0x16>
    nu = 4096;
 794:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 79b:	8b 45 08             	mov    0x8(%ebp),%eax
 79e:	c1 e0 03             	shl    $0x3,%eax
 7a1:	89 04 24             	mov    %eax,(%esp)
 7a4:	e8 9f fb ff ff       	call   348 <sbrk>
 7a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ac:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b0:	75 07                	jne    7b9 <morecore+0x34>
    return 0;
 7b2:	b8 00 00 00 00       	mov    $0x0,%eax
 7b7:	eb 22                	jmp    7db <morecore+0x56>
  hp = (Header*)p;
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c2:	8b 55 08             	mov    0x8(%ebp),%edx
 7c5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cb:	83 c0 08             	add    $0x8,%eax
 7ce:	89 04 24             	mov    %eax,(%esp)
 7d1:	e8 ce fe ff ff       	call   6a4 <free>
  return freep;
 7d6:	a1 2c 0b 00 00       	mov    0xb2c,%eax
}
 7db:	c9                   	leave  
 7dc:	c3                   	ret    

000007dd <malloc>:

void*
malloc(uint nbytes)
{
 7dd:	55                   	push   %ebp
 7de:	89 e5                	mov    %esp,%ebp
 7e0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e3:	8b 45 08             	mov    0x8(%ebp),%eax
 7e6:	83 c0 07             	add    $0x7,%eax
 7e9:	c1 e8 03             	shr    $0x3,%eax
 7ec:	40                   	inc    %eax
 7ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7f0:	a1 2c 0b 00 00       	mov    0xb2c,%eax
 7f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7fc:	75 23                	jne    821 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 7fe:	c7 45 f0 24 0b 00 00 	movl   $0xb24,-0x10(%ebp)
 805:	8b 45 f0             	mov    -0x10(%ebp),%eax
 808:	a3 2c 0b 00 00       	mov    %eax,0xb2c
 80d:	a1 2c 0b 00 00       	mov    0xb2c,%eax
 812:	a3 24 0b 00 00       	mov    %eax,0xb24
    base.s.size = 0;
 817:	c7 05 28 0b 00 00 00 	movl   $0x0,0xb28
 81e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 821:	8b 45 f0             	mov    -0x10(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 829:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82c:	8b 40 04             	mov    0x4(%eax),%eax
 82f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 832:	72 4d                	jb     881 <malloc+0xa4>
      if(p->s.size == nunits)
 834:	8b 45 f4             	mov    -0xc(%ebp),%eax
 837:	8b 40 04             	mov    0x4(%eax),%eax
 83a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 83d:	75 0c                	jne    84b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 83f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 842:	8b 10                	mov    (%eax),%edx
 844:	8b 45 f0             	mov    -0x10(%ebp),%eax
 847:	89 10                	mov    %edx,(%eax)
 849:	eb 26                	jmp    871 <malloc+0x94>
      else {
        p->s.size -= nunits;
 84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84e:	8b 40 04             	mov    0x4(%eax),%eax
 851:	2b 45 ec             	sub    -0x14(%ebp),%eax
 854:	89 c2                	mov    %eax,%edx
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 85c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85f:	8b 40 04             	mov    0x4(%eax),%eax
 862:	c1 e0 03             	shl    $0x3,%eax
 865:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 868:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 86e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 871:	8b 45 f0             	mov    -0x10(%ebp),%eax
 874:	a3 2c 0b 00 00       	mov    %eax,0xb2c
      return (void*)(p + 1);
 879:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87c:	83 c0 08             	add    $0x8,%eax
 87f:	eb 38                	jmp    8b9 <malloc+0xdc>
    }
    if(p == freep)
 881:	a1 2c 0b 00 00       	mov    0xb2c,%eax
 886:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 889:	75 1b                	jne    8a6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 88b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 88e:	89 04 24             	mov    %eax,(%esp)
 891:	e8 ef fe ff ff       	call   785 <morecore>
 896:	89 45 f4             	mov    %eax,-0xc(%ebp)
 899:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 89d:	75 07                	jne    8a6 <malloc+0xc9>
        return 0;
 89f:	b8 00 00 00 00       	mov    $0x0,%eax
 8a4:	eb 13                	jmp    8b9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	8b 00                	mov    (%eax),%eax
 8b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8b4:	e9 70 ff ff ff       	jmp    829 <malloc+0x4c>
}
 8b9:	c9                   	leave  
 8ba:	c3                   	ret    
