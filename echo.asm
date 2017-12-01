
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
  1d:	b8 d3 08 00 00       	mov    $0x8d3,%eax
  22:	eb 05                	jmp    29 <main+0x29>
  24:	b8 d5 08 00 00       	mov    $0x8d5,%eax
  29:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2d:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  34:	8b 55 0c             	mov    0xc(%ebp),%edx
  37:	01 ca                	add    %ecx,%edx
  39:	8b 12                	mov    (%edx),%edx
  3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  43:	c7 44 24 04 d7 08 00 	movl   $0x8d7,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 b6 04 00 00       	call   50d <printf>
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
SYSCALL(cstop)
 410:	b8 2c 00 00 00       	mov    $0x2c,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <df>:
SYSCALL(df)
 418:	b8 2d 00 00 00       	mov    $0x2d,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <max_containers>:
SYSCALL(max_containers)
 420:	b8 2e 00 00 00       	mov    $0x2e,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <container_reset>:
SYSCALL(container_reset)
 428:	b8 2f 00 00 00       	mov    $0x2f,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	83 ec 18             	sub    $0x18,%esp
 436:	8b 45 0c             	mov    0xc(%ebp),%eax
 439:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 43c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 443:	00 
 444:	8d 45 f4             	lea    -0xc(%ebp),%eax
 447:	89 44 24 04          	mov    %eax,0x4(%esp)
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	89 04 24             	mov    %eax,(%esp)
 451:	e8 8a fe ff ff       	call   2e0 <write>
}
 456:	c9                   	leave  
 457:	c3                   	ret    

00000458 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	56                   	push   %esi
 45c:	53                   	push   %ebx
 45d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 460:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 467:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 46b:	74 17                	je     484 <printint+0x2c>
 46d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 471:	79 11                	jns    484 <printint+0x2c>
    neg = 1;
 473:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 47a:	8b 45 0c             	mov    0xc(%ebp),%eax
 47d:	f7 d8                	neg    %eax
 47f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 482:	eb 06                	jmp    48a <printint+0x32>
  } else {
    x = xx;
 484:	8b 45 0c             	mov    0xc(%ebp),%eax
 487:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 48a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 491:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 494:	8d 41 01             	lea    0x1(%ecx),%eax
 497:	89 45 f4             	mov    %eax,-0xc(%ebp)
 49a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 49d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a0:	ba 00 00 00 00       	mov    $0x0,%edx
 4a5:	f7 f3                	div    %ebx
 4a7:	89 d0                	mov    %edx,%eax
 4a9:	8a 80 28 0b 00 00    	mov    0xb28(%eax),%al
 4af:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4b3:	8b 75 10             	mov    0x10(%ebp),%esi
 4b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b9:	ba 00 00 00 00       	mov    $0x0,%edx
 4be:	f7 f6                	div    %esi
 4c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c7:	75 c8                	jne    491 <printint+0x39>
  if(neg)
 4c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4cd:	74 10                	je     4df <printint+0x87>
    buf[i++] = '-';
 4cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d2:	8d 50 01             	lea    0x1(%eax),%edx
 4d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4dd:	eb 1e                	jmp    4fd <printint+0xa5>
 4df:	eb 1c                	jmp    4fd <printint+0xa5>
    putc(fd, buf[i]);
 4e1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e7:	01 d0                	add    %edx,%eax
 4e9:	8a 00                	mov    (%eax),%al
 4eb:	0f be c0             	movsbl %al,%eax
 4ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
 4f5:	89 04 24             	mov    %eax,(%esp)
 4f8:	e8 33 ff ff ff       	call   430 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4fd:	ff 4d f4             	decl   -0xc(%ebp)
 500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 504:	79 db                	jns    4e1 <printint+0x89>
    putc(fd, buf[i]);
}
 506:	83 c4 30             	add    $0x30,%esp
 509:	5b                   	pop    %ebx
 50a:	5e                   	pop    %esi
 50b:	5d                   	pop    %ebp
 50c:	c3                   	ret    

0000050d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 50d:	55                   	push   %ebp
 50e:	89 e5                	mov    %esp,%ebp
 510:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 513:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 51a:	8d 45 0c             	lea    0xc(%ebp),%eax
 51d:	83 c0 04             	add    $0x4,%eax
 520:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 523:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 52a:	e9 77 01 00 00       	jmp    6a6 <printf+0x199>
    c = fmt[i] & 0xff;
 52f:	8b 55 0c             	mov    0xc(%ebp),%edx
 532:	8b 45 f0             	mov    -0x10(%ebp),%eax
 535:	01 d0                	add    %edx,%eax
 537:	8a 00                	mov    (%eax),%al
 539:	0f be c0             	movsbl %al,%eax
 53c:	25 ff 00 00 00       	and    $0xff,%eax
 541:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 544:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 548:	75 2c                	jne    576 <printf+0x69>
      if(c == '%'){
 54a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54e:	75 0c                	jne    55c <printf+0x4f>
        state = '%';
 550:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 557:	e9 47 01 00 00       	jmp    6a3 <printf+0x196>
      } else {
        putc(fd, c);
 55c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55f:	0f be c0             	movsbl %al,%eax
 562:	89 44 24 04          	mov    %eax,0x4(%esp)
 566:	8b 45 08             	mov    0x8(%ebp),%eax
 569:	89 04 24             	mov    %eax,(%esp)
 56c:	e8 bf fe ff ff       	call   430 <putc>
 571:	e9 2d 01 00 00       	jmp    6a3 <printf+0x196>
      }
    } else if(state == '%'){
 576:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 57a:	0f 85 23 01 00 00    	jne    6a3 <printf+0x196>
      if(c == 'd'){
 580:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 584:	75 2d                	jne    5b3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 586:	8b 45 e8             	mov    -0x18(%ebp),%eax
 589:	8b 00                	mov    (%eax),%eax
 58b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 592:	00 
 593:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 59a:	00 
 59b:	89 44 24 04          	mov    %eax,0x4(%esp)
 59f:	8b 45 08             	mov    0x8(%ebp),%eax
 5a2:	89 04 24             	mov    %eax,(%esp)
 5a5:	e8 ae fe ff ff       	call   458 <printint>
        ap++;
 5aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ae:	e9 e9 00 00 00       	jmp    69c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5b3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b7:	74 06                	je     5bf <printf+0xb2>
 5b9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5bd:	75 2d                	jne    5ec <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c2:	8b 00                	mov    (%eax),%eax
 5c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5cb:	00 
 5cc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5d3:	00 
 5d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d8:	8b 45 08             	mov    0x8(%ebp),%eax
 5db:	89 04 24             	mov    %eax,(%esp)
 5de:	e8 75 fe ff ff       	call   458 <printint>
        ap++;
 5e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e7:	e9 b0 00 00 00       	jmp    69c <printf+0x18f>
      } else if(c == 's'){
 5ec:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f0:	75 42                	jne    634 <printf+0x127>
        s = (char*)*ap;
 5f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f5:	8b 00                	mov    (%eax),%eax
 5f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 602:	75 09                	jne    60d <printf+0x100>
          s = "(null)";
 604:	c7 45 f4 dc 08 00 00 	movl   $0x8dc,-0xc(%ebp)
        while(*s != 0){
 60b:	eb 1c                	jmp    629 <printf+0x11c>
 60d:	eb 1a                	jmp    629 <printf+0x11c>
          putc(fd, *s);
 60f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 612:	8a 00                	mov    (%eax),%al
 614:	0f be c0             	movsbl %al,%eax
 617:	89 44 24 04          	mov    %eax,0x4(%esp)
 61b:	8b 45 08             	mov    0x8(%ebp),%eax
 61e:	89 04 24             	mov    %eax,(%esp)
 621:	e8 0a fe ff ff       	call   430 <putc>
          s++;
 626:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 629:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62c:	8a 00                	mov    (%eax),%al
 62e:	84 c0                	test   %al,%al
 630:	75 dd                	jne    60f <printf+0x102>
 632:	eb 68                	jmp    69c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 634:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 638:	75 1d                	jne    657 <printf+0x14a>
        putc(fd, *ap);
 63a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63d:	8b 00                	mov    (%eax),%eax
 63f:	0f be c0             	movsbl %al,%eax
 642:	89 44 24 04          	mov    %eax,0x4(%esp)
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	89 04 24             	mov    %eax,(%esp)
 64c:	e8 df fd ff ff       	call   430 <putc>
        ap++;
 651:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 655:	eb 45                	jmp    69c <printf+0x18f>
      } else if(c == '%'){
 657:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65b:	75 17                	jne    674 <printf+0x167>
        putc(fd, c);
 65d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 660:	0f be c0             	movsbl %al,%eax
 663:	89 44 24 04          	mov    %eax,0x4(%esp)
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	89 04 24             	mov    %eax,(%esp)
 66d:	e8 be fd ff ff       	call   430 <putc>
 672:	eb 28                	jmp    69c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 674:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 67b:	00 
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	89 04 24             	mov    %eax,(%esp)
 682:	e8 a9 fd ff ff       	call   430 <putc>
        putc(fd, c);
 687:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	89 44 24 04          	mov    %eax,0x4(%esp)
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	89 04 24             	mov    %eax,(%esp)
 697:	e8 94 fd ff ff       	call   430 <putc>
      }
      state = 0;
 69c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a3:	ff 45 f0             	incl   -0x10(%ebp)
 6a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ac:	01 d0                	add    %edx,%eax
 6ae:	8a 00                	mov    (%eax),%al
 6b0:	84 c0                	test   %al,%al
 6b2:	0f 85 77 fe ff ff    	jne    52f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b8:	c9                   	leave  
 6b9:	c3                   	ret    
 6ba:	90                   	nop
 6bb:	90                   	nop

000006bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c2:	8b 45 08             	mov    0x8(%ebp),%eax
 6c5:	83 e8 08             	sub    $0x8,%eax
 6c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6cb:	a1 44 0b 00 00       	mov    0xb44,%eax
 6d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d3:	eb 24                	jmp    6f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6dd:	77 12                	ja     6f1 <free+0x35>
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e5:	77 24                	ja     70b <free+0x4f>
 6e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ea:	8b 00                	mov    (%eax),%eax
 6ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ef:	77 1a                	ja     70b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ff:	76 d4                	jbe    6d5 <free+0x19>
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 709:	76 ca                	jbe    6d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	8b 40 04             	mov    0x4(%eax),%eax
 711:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 718:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71b:	01 c2                	add    %eax,%edx
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	39 c2                	cmp    %eax,%edx
 724:	75 24                	jne    74a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 726:	8b 45 f8             	mov    -0x8(%ebp),%eax
 729:	8b 50 04             	mov    0x4(%eax),%edx
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	8b 00                	mov    (%eax),%eax
 731:	8b 40 04             	mov    0x4(%eax),%eax
 734:	01 c2                	add    %eax,%edx
 736:	8b 45 f8             	mov    -0x8(%ebp),%eax
 739:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 00                	mov    (%eax),%eax
 741:	8b 10                	mov    (%eax),%edx
 743:	8b 45 f8             	mov    -0x8(%ebp),%eax
 746:	89 10                	mov    %edx,(%eax)
 748:	eb 0a                	jmp    754 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 74a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74d:	8b 10                	mov    (%eax),%edx
 74f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 752:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 754:	8b 45 fc             	mov    -0x4(%ebp),%eax
 757:	8b 40 04             	mov    0x4(%eax),%eax
 75a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	01 d0                	add    %edx,%eax
 766:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 769:	75 20                	jne    78b <free+0xcf>
    p->s.size += bp->s.size;
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 50 04             	mov    0x4(%eax),%edx
 771:	8b 45 f8             	mov    -0x8(%ebp),%eax
 774:	8b 40 04             	mov    0x4(%eax),%eax
 777:	01 c2                	add    %eax,%edx
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	8b 10                	mov    (%eax),%edx
 784:	8b 45 fc             	mov    -0x4(%ebp),%eax
 787:	89 10                	mov    %edx,(%eax)
 789:	eb 08                	jmp    793 <free+0xd7>
  } else
    p->s.ptr = bp;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 791:	89 10                	mov    %edx,(%eax)
  freep = p;
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	a3 44 0b 00 00       	mov    %eax,0xb44
}
 79b:	c9                   	leave  
 79c:	c3                   	ret    

0000079d <morecore>:

static Header*
morecore(uint nu)
{
 79d:	55                   	push   %ebp
 79e:	89 e5                	mov    %esp,%ebp
 7a0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7aa:	77 07                	ja     7b3 <morecore+0x16>
    nu = 4096;
 7ac:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b3:	8b 45 08             	mov    0x8(%ebp),%eax
 7b6:	c1 e0 03             	shl    $0x3,%eax
 7b9:	89 04 24             	mov    %eax,(%esp)
 7bc:	e8 87 fb ff ff       	call   348 <sbrk>
 7c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c8:	75 07                	jne    7d1 <morecore+0x34>
    return 0;
 7ca:	b8 00 00 00 00       	mov    $0x0,%eax
 7cf:	eb 22                	jmp    7f3 <morecore+0x56>
  hp = (Header*)p;
 7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7da:	8b 55 08             	mov    0x8(%ebp),%edx
 7dd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e3:	83 c0 08             	add    $0x8,%eax
 7e6:	89 04 24             	mov    %eax,(%esp)
 7e9:	e8 ce fe ff ff       	call   6bc <free>
  return freep;
 7ee:	a1 44 0b 00 00       	mov    0xb44,%eax
}
 7f3:	c9                   	leave  
 7f4:	c3                   	ret    

000007f5 <malloc>:

void*
malloc(uint nbytes)
{
 7f5:	55                   	push   %ebp
 7f6:	89 e5                	mov    %esp,%ebp
 7f8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fb:	8b 45 08             	mov    0x8(%ebp),%eax
 7fe:	83 c0 07             	add    $0x7,%eax
 801:	c1 e8 03             	shr    $0x3,%eax
 804:	40                   	inc    %eax
 805:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 808:	a1 44 0b 00 00       	mov    0xb44,%eax
 80d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 810:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 814:	75 23                	jne    839 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 816:	c7 45 f0 3c 0b 00 00 	movl   $0xb3c,-0x10(%ebp)
 81d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 820:	a3 44 0b 00 00       	mov    %eax,0xb44
 825:	a1 44 0b 00 00       	mov    0xb44,%eax
 82a:	a3 3c 0b 00 00       	mov    %eax,0xb3c
    base.s.size = 0;
 82f:	c7 05 40 0b 00 00 00 	movl   $0x0,0xb40
 836:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 839:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	8b 40 04             	mov    0x4(%eax),%eax
 847:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 84a:	72 4d                	jb     899 <malloc+0xa4>
      if(p->s.size == nunits)
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	8b 40 04             	mov    0x4(%eax),%eax
 852:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 855:	75 0c                	jne    863 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 857:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85a:	8b 10                	mov    (%eax),%edx
 85c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85f:	89 10                	mov    %edx,(%eax)
 861:	eb 26                	jmp    889 <malloc+0x94>
      else {
        p->s.size -= nunits;
 863:	8b 45 f4             	mov    -0xc(%ebp),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	2b 45 ec             	sub    -0x14(%ebp),%eax
 86c:	89 c2                	mov    %eax,%edx
 86e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 871:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 874:	8b 45 f4             	mov    -0xc(%ebp),%eax
 877:	8b 40 04             	mov    0x4(%eax),%eax
 87a:	c1 e0 03             	shl    $0x3,%eax
 87d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 880:	8b 45 f4             	mov    -0xc(%ebp),%eax
 883:	8b 55 ec             	mov    -0x14(%ebp),%edx
 886:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	a3 44 0b 00 00       	mov    %eax,0xb44
      return (void*)(p + 1);
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	83 c0 08             	add    $0x8,%eax
 897:	eb 38                	jmp    8d1 <malloc+0xdc>
    }
    if(p == freep)
 899:	a1 44 0b 00 00       	mov    0xb44,%eax
 89e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a1:	75 1b                	jne    8be <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a6:	89 04 24             	mov    %eax,(%esp)
 8a9:	e8 ef fe ff ff       	call   79d <morecore>
 8ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b5:	75 07                	jne    8be <malloc+0xc9>
        return 0;
 8b7:	b8 00 00 00 00       	mov    $0x0,%eax
 8bc:	eb 13                	jmp    8d1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8cc:	e9 70 ff ff ff       	jmp    841 <malloc+0x4c>
}
 8d1:	c9                   	leave  
 8d2:	c3                   	ret    
