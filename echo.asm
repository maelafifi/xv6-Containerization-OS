
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
  1d:	b8 93 08 00 00       	mov    $0x893,%eax
  22:	eb 05                	jmp    29 <main+0x29>
  24:	b8 95 08 00 00       	mov    $0x895,%eax
  29:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2d:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  34:	8b 55 0c             	mov    0xc(%ebp),%edx
  37:	01 ca                	add    %ecx,%edx
  39:	8b 12                	mov    (%edx),%edx
  3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  43:	c7 44 24 04 97 08 00 	movl   $0x897,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 76 04 00 00       	call   4cd <printf>
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

000003f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	83 ec 18             	sub    $0x18,%esp
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 403:	00 
 404:	8d 45 f4             	lea    -0xc(%ebp),%eax
 407:	89 44 24 04          	mov    %eax,0x4(%esp)
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
 40e:	89 04 24             	mov    %eax,(%esp)
 411:	e8 ca fe ff ff       	call   2e0 <write>
}
 416:	c9                   	leave  
 417:	c3                   	ret    

00000418 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	56                   	push   %esi
 41c:	53                   	push   %ebx
 41d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 420:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 427:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 42b:	74 17                	je     444 <printint+0x2c>
 42d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 431:	79 11                	jns    444 <printint+0x2c>
    neg = 1;
 433:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 43a:	8b 45 0c             	mov    0xc(%ebp),%eax
 43d:	f7 d8                	neg    %eax
 43f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 442:	eb 06                	jmp    44a <printint+0x32>
  } else {
    x = xx;
 444:	8b 45 0c             	mov    0xc(%ebp),%eax
 447:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 44a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 451:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 454:	8d 41 01             	lea    0x1(%ecx),%eax
 457:	89 45 f4             	mov    %eax,-0xc(%ebp)
 45a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 45d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 460:	ba 00 00 00 00       	mov    $0x0,%edx
 465:	f7 f3                	div    %ebx
 467:	89 d0                	mov    %edx,%eax
 469:	8a 80 e8 0a 00 00    	mov    0xae8(%eax),%al
 46f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 473:	8b 75 10             	mov    0x10(%ebp),%esi
 476:	8b 45 ec             	mov    -0x14(%ebp),%eax
 479:	ba 00 00 00 00       	mov    $0x0,%edx
 47e:	f7 f6                	div    %esi
 480:	89 45 ec             	mov    %eax,-0x14(%ebp)
 483:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 487:	75 c8                	jne    451 <printint+0x39>
  if(neg)
 489:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 48d:	74 10                	je     49f <printint+0x87>
    buf[i++] = '-';
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	8d 50 01             	lea    0x1(%eax),%edx
 495:	89 55 f4             	mov    %edx,-0xc(%ebp)
 498:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 49d:	eb 1e                	jmp    4bd <printint+0xa5>
 49f:	eb 1c                	jmp    4bd <printint+0xa5>
    putc(fd, buf[i]);
 4a1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a7:	01 d0                	add    %edx,%eax
 4a9:	8a 00                	mov    (%eax),%al
 4ab:	0f be c0             	movsbl %al,%eax
 4ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b2:	8b 45 08             	mov    0x8(%ebp),%eax
 4b5:	89 04 24             	mov    %eax,(%esp)
 4b8:	e8 33 ff ff ff       	call   3f0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4bd:	ff 4d f4             	decl   -0xc(%ebp)
 4c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c4:	79 db                	jns    4a1 <printint+0x89>
    putc(fd, buf[i]);
}
 4c6:	83 c4 30             	add    $0x30,%esp
 4c9:	5b                   	pop    %ebx
 4ca:	5e                   	pop    %esi
 4cb:	5d                   	pop    %ebp
 4cc:	c3                   	ret    

000004cd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4cd:	55                   	push   %ebp
 4ce:	89 e5                	mov    %esp,%ebp
 4d0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4da:	8d 45 0c             	lea    0xc(%ebp),%eax
 4dd:	83 c0 04             	add    $0x4,%eax
 4e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ea:	e9 77 01 00 00       	jmp    666 <printf+0x199>
    c = fmt[i] & 0xff;
 4ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 4f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4f5:	01 d0                	add    %edx,%eax
 4f7:	8a 00                	mov    (%eax),%al
 4f9:	0f be c0             	movsbl %al,%eax
 4fc:	25 ff 00 00 00       	and    $0xff,%eax
 501:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 504:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 508:	75 2c                	jne    536 <printf+0x69>
      if(c == '%'){
 50a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 50e:	75 0c                	jne    51c <printf+0x4f>
        state = '%';
 510:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 517:	e9 47 01 00 00       	jmp    663 <printf+0x196>
      } else {
        putc(fd, c);
 51c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51f:	0f be c0             	movsbl %al,%eax
 522:	89 44 24 04          	mov    %eax,0x4(%esp)
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	89 04 24             	mov    %eax,(%esp)
 52c:	e8 bf fe ff ff       	call   3f0 <putc>
 531:	e9 2d 01 00 00       	jmp    663 <printf+0x196>
      }
    } else if(state == '%'){
 536:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 53a:	0f 85 23 01 00 00    	jne    663 <printf+0x196>
      if(c == 'd'){
 540:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 544:	75 2d                	jne    573 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 546:	8b 45 e8             	mov    -0x18(%ebp),%eax
 549:	8b 00                	mov    (%eax),%eax
 54b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 552:	00 
 553:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 55a:	00 
 55b:	89 44 24 04          	mov    %eax,0x4(%esp)
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	89 04 24             	mov    %eax,(%esp)
 565:	e8 ae fe ff ff       	call   418 <printint>
        ap++;
 56a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56e:	e9 e9 00 00 00       	jmp    65c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 573:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 577:	74 06                	je     57f <printf+0xb2>
 579:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 57d:	75 2d                	jne    5ac <printf+0xdf>
        printint(fd, *ap, 16, 0);
 57f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 582:	8b 00                	mov    (%eax),%eax
 584:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 58b:	00 
 58c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 593:	00 
 594:	89 44 24 04          	mov    %eax,0x4(%esp)
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	89 04 24             	mov    %eax,(%esp)
 59e:	e8 75 fe ff ff       	call   418 <printint>
        ap++;
 5a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a7:	e9 b0 00 00 00       	jmp    65c <printf+0x18f>
      } else if(c == 's'){
 5ac:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5b0:	75 42                	jne    5f4 <printf+0x127>
        s = (char*)*ap;
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c2:	75 09                	jne    5cd <printf+0x100>
          s = "(null)";
 5c4:	c7 45 f4 9c 08 00 00 	movl   $0x89c,-0xc(%ebp)
        while(*s != 0){
 5cb:	eb 1c                	jmp    5e9 <printf+0x11c>
 5cd:	eb 1a                	jmp    5e9 <printf+0x11c>
          putc(fd, *s);
 5cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d2:	8a 00                	mov    (%eax),%al
 5d4:	0f be c0             	movsbl %al,%eax
 5d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	89 04 24             	mov    %eax,(%esp)
 5e1:	e8 0a fe ff ff       	call   3f0 <putc>
          s++;
 5e6:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ec:	8a 00                	mov    (%eax),%al
 5ee:	84 c0                	test   %al,%al
 5f0:	75 dd                	jne    5cf <printf+0x102>
 5f2:	eb 68                	jmp    65c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5f8:	75 1d                	jne    617 <printf+0x14a>
        putc(fd, *ap);
 5fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fd:	8b 00                	mov    (%eax),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	89 44 24 04          	mov    %eax,0x4(%esp)
 606:	8b 45 08             	mov    0x8(%ebp),%eax
 609:	89 04 24             	mov    %eax,(%esp)
 60c:	e8 df fd ff ff       	call   3f0 <putc>
        ap++;
 611:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 615:	eb 45                	jmp    65c <printf+0x18f>
      } else if(c == '%'){
 617:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61b:	75 17                	jne    634 <printf+0x167>
        putc(fd, c);
 61d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 620:	0f be c0             	movsbl %al,%eax
 623:	89 44 24 04          	mov    %eax,0x4(%esp)
 627:	8b 45 08             	mov    0x8(%ebp),%eax
 62a:	89 04 24             	mov    %eax,(%esp)
 62d:	e8 be fd ff ff       	call   3f0 <putc>
 632:	eb 28                	jmp    65c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 634:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 63b:	00 
 63c:	8b 45 08             	mov    0x8(%ebp),%eax
 63f:	89 04 24             	mov    %eax,(%esp)
 642:	e8 a9 fd ff ff       	call   3f0 <putc>
        putc(fd, c);
 647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64a:	0f be c0             	movsbl %al,%eax
 64d:	89 44 24 04          	mov    %eax,0x4(%esp)
 651:	8b 45 08             	mov    0x8(%ebp),%eax
 654:	89 04 24             	mov    %eax,(%esp)
 657:	e8 94 fd ff ff       	call   3f0 <putc>
      }
      state = 0;
 65c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 663:	ff 45 f0             	incl   -0x10(%ebp)
 666:	8b 55 0c             	mov    0xc(%ebp),%edx
 669:	8b 45 f0             	mov    -0x10(%ebp),%eax
 66c:	01 d0                	add    %edx,%eax
 66e:	8a 00                	mov    (%eax),%al
 670:	84 c0                	test   %al,%al
 672:	0f 85 77 fe ff ff    	jne    4ef <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 678:	c9                   	leave  
 679:	c3                   	ret    
 67a:	90                   	nop
 67b:	90                   	nop

0000067c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67c:	55                   	push   %ebp
 67d:	89 e5                	mov    %esp,%ebp
 67f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 682:	8b 45 08             	mov    0x8(%ebp),%eax
 685:	83 e8 08             	sub    $0x8,%eax
 688:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68b:	a1 04 0b 00 00       	mov    0xb04,%eax
 690:	89 45 fc             	mov    %eax,-0x4(%ebp)
 693:	eb 24                	jmp    6b9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	8b 00                	mov    (%eax),%eax
 69a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69d:	77 12                	ja     6b1 <free+0x35>
 69f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a5:	77 24                	ja     6cb <free+0x4f>
 6a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6aa:	8b 00                	mov    (%eax),%eax
 6ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6af:	77 1a                	ja     6cb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	8b 00                	mov    (%eax),%eax
 6b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6bf:	76 d4                	jbe    695 <free+0x19>
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c9:	76 ca                	jbe    695 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ce:	8b 40 04             	mov    0x4(%eax),%eax
 6d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6db:	01 c2                	add    %eax,%edx
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	39 c2                	cmp    %eax,%edx
 6e4:	75 24                	jne    70a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e9:	8b 50 04             	mov    0x4(%eax),%edx
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	8b 40 04             	mov    0x4(%eax),%eax
 6f4:	01 c2                	add    %eax,%edx
 6f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 00                	mov    (%eax),%eax
 701:	8b 10                	mov    (%eax),%edx
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	89 10                	mov    %edx,(%eax)
 708:	eb 0a                	jmp    714 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 70a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70d:	8b 10                	mov    (%eax),%edx
 70f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 712:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 40 04             	mov    0x4(%eax),%eax
 71a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	01 d0                	add    %edx,%eax
 726:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 729:	75 20                	jne    74b <free+0xcf>
    p->s.size += bp->s.size;
 72b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72e:	8b 50 04             	mov    0x4(%eax),%edx
 731:	8b 45 f8             	mov    -0x8(%ebp),%eax
 734:	8b 40 04             	mov    0x4(%eax),%eax
 737:	01 c2                	add    %eax,%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 73f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 742:	8b 10                	mov    (%eax),%edx
 744:	8b 45 fc             	mov    -0x4(%ebp),%eax
 747:	89 10                	mov    %edx,(%eax)
 749:	eb 08                	jmp    753 <free+0xd7>
  } else
    p->s.ptr = bp;
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 751:	89 10                	mov    %edx,(%eax)
  freep = p;
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	a3 04 0b 00 00       	mov    %eax,0xb04
}
 75b:	c9                   	leave  
 75c:	c3                   	ret    

0000075d <morecore>:

static Header*
morecore(uint nu)
{
 75d:	55                   	push   %ebp
 75e:	89 e5                	mov    %esp,%ebp
 760:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 763:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 76a:	77 07                	ja     773 <morecore+0x16>
    nu = 4096;
 76c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	c1 e0 03             	shl    $0x3,%eax
 779:	89 04 24             	mov    %eax,(%esp)
 77c:	e8 c7 fb ff ff       	call   348 <sbrk>
 781:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 784:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 788:	75 07                	jne    791 <morecore+0x34>
    return 0;
 78a:	b8 00 00 00 00       	mov    $0x0,%eax
 78f:	eb 22                	jmp    7b3 <morecore+0x56>
  hp = (Header*)p;
 791:	8b 45 f4             	mov    -0xc(%ebp),%eax
 794:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 797:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79a:	8b 55 08             	mov    0x8(%ebp),%edx
 79d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a3:	83 c0 08             	add    $0x8,%eax
 7a6:	89 04 24             	mov    %eax,(%esp)
 7a9:	e8 ce fe ff ff       	call   67c <free>
  return freep;
 7ae:	a1 04 0b 00 00       	mov    0xb04,%eax
}
 7b3:	c9                   	leave  
 7b4:	c3                   	ret    

000007b5 <malloc>:

void*
malloc(uint nbytes)
{
 7b5:	55                   	push   %ebp
 7b6:	89 e5                	mov    %esp,%ebp
 7b8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	83 c0 07             	add    $0x7,%eax
 7c1:	c1 e8 03             	shr    $0x3,%eax
 7c4:	40                   	inc    %eax
 7c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7c8:	a1 04 0b 00 00       	mov    0xb04,%eax
 7cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7d4:	75 23                	jne    7f9 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 7d6:	c7 45 f0 fc 0a 00 00 	movl   $0xafc,-0x10(%ebp)
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	a3 04 0b 00 00       	mov    %eax,0xb04
 7e5:	a1 04 0b 00 00       	mov    0xb04,%eax
 7ea:	a3 fc 0a 00 00       	mov    %eax,0xafc
    base.s.size = 0;
 7ef:	c7 05 00 0b 00 00 00 	movl   $0x0,0xb00
 7f6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 801:	8b 45 f4             	mov    -0xc(%ebp),%eax
 804:	8b 40 04             	mov    0x4(%eax),%eax
 807:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 80a:	72 4d                	jb     859 <malloc+0xa4>
      if(p->s.size == nunits)
 80c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80f:	8b 40 04             	mov    0x4(%eax),%eax
 812:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 815:	75 0c                	jne    823 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 817:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81a:	8b 10                	mov    (%eax),%edx
 81c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81f:	89 10                	mov    %edx,(%eax)
 821:	eb 26                	jmp    849 <malloc+0x94>
      else {
        p->s.size -= nunits;
 823:	8b 45 f4             	mov    -0xc(%ebp),%eax
 826:	8b 40 04             	mov    0x4(%eax),%eax
 829:	2b 45 ec             	sub    -0x14(%ebp),%eax
 82c:	89 c2                	mov    %eax,%edx
 82e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 831:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 834:	8b 45 f4             	mov    -0xc(%ebp),%eax
 837:	8b 40 04             	mov    0x4(%eax),%eax
 83a:	c1 e0 03             	shl    $0x3,%eax
 83d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	8b 55 ec             	mov    -0x14(%ebp),%edx
 846:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 849:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84c:	a3 04 0b 00 00       	mov    %eax,0xb04
      return (void*)(p + 1);
 851:	8b 45 f4             	mov    -0xc(%ebp),%eax
 854:	83 c0 08             	add    $0x8,%eax
 857:	eb 38                	jmp    891 <malloc+0xdc>
    }
    if(p == freep)
 859:	a1 04 0b 00 00       	mov    0xb04,%eax
 85e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 861:	75 1b                	jne    87e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 863:	8b 45 ec             	mov    -0x14(%ebp),%eax
 866:	89 04 24             	mov    %eax,(%esp)
 869:	e8 ef fe ff ff       	call   75d <morecore>
 86e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 871:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 875:	75 07                	jne    87e <malloc+0xc9>
        return 0;
 877:	b8 00 00 00 00       	mov    $0x0,%eax
 87c:	eb 13                	jmp    891 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	89 45 f0             	mov    %eax,-0x10(%ebp)
 884:	8b 45 f4             	mov    -0xc(%ebp),%eax
 887:	8b 00                	mov    (%eax),%eax
 889:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 88c:	e9 70 ff ff ff       	jmp    801 <malloc+0x4c>
}
 891:	c9                   	leave  
 892:	c3                   	ret    
