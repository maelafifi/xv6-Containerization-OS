
_free:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "container.h"

int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 30             	sub    $0x30,%esp
	int used = tmem();
   9:	e8 1a 04 00 00       	call   428 <tmem>
   e:	89 44 24 2c          	mov    %eax,0x2c(%esp)
	int avail = amem();
  12:	e8 19 04 00 00       	call   430 <amem>
  17:	89 44 24 28          	mov    %eax,0x28(%esp)
	printf(1, "%d (%d used) available pages out of %d total pages.\n", avail-used, used, avail);
  1b:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  1f:	8b 54 24 28          	mov    0x28(%esp),%edx
  23:	29 c2                	sub    %eax,%edx
  25:	8b 44 24 28          	mov    0x28(%esp),%eax
  29:	89 44 24 10          	mov    %eax,0x10(%esp)
  2d:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  35:	89 54 24 08          	mov    %edx,0x8(%esp)
  39:	c7 44 24 04 e4 08 00 	movl   $0x8e4,0x4(%esp)
  40:	00 
  41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  48:	e8 d0 04 00 00       	call   51d <printf>
	exit();
  4d:	e8 56 02 00 00       	call   2a8 <exit>
  52:	90                   	nop
  53:	90                   	nop

00000054 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  54:	55                   	push   %ebp
  55:	89 e5                	mov    %esp,%ebp
  57:	57                   	push   %edi
  58:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  5c:	8b 55 10             	mov    0x10(%ebp),%edx
  5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  62:	89 cb                	mov    %ecx,%ebx
  64:	89 df                	mov    %ebx,%edi
  66:	89 d1                	mov    %edx,%ecx
  68:	fc                   	cld    
  69:	f3 aa                	rep stos %al,%es:(%edi)
  6b:	89 ca                	mov    %ecx,%edx
  6d:	89 fb                	mov    %edi,%ebx
  6f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  72:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  75:	5b                   	pop    %ebx
  76:	5f                   	pop    %edi
  77:	5d                   	pop    %ebp
  78:	c3                   	ret    

00000079 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  7f:	8b 45 08             	mov    0x8(%ebp),%eax
  82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  85:	90                   	nop
  86:	8b 45 08             	mov    0x8(%ebp),%eax
  89:	8d 50 01             	lea    0x1(%eax),%edx
  8c:	89 55 08             	mov    %edx,0x8(%ebp)
  8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  92:	8d 4a 01             	lea    0x1(%edx),%ecx
  95:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  98:	8a 12                	mov    (%edx),%dl
  9a:	88 10                	mov    %dl,(%eax)
  9c:	8a 00                	mov    (%eax),%al
  9e:	84 c0                	test   %al,%al
  a0:	75 e4                	jne    86 <strcpy+0xd>
    ;
  return os;
  a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  a5:	c9                   	leave  
  a6:	c3                   	ret    

000000a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a7:	55                   	push   %ebp
  a8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  aa:	eb 06                	jmp    b2 <strcmp+0xb>
    p++, q++;
  ac:	ff 45 08             	incl   0x8(%ebp)
  af:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  b2:	8b 45 08             	mov    0x8(%ebp),%eax
  b5:	8a 00                	mov    (%eax),%al
  b7:	84 c0                	test   %al,%al
  b9:	74 0e                	je     c9 <strcmp+0x22>
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	8a 10                	mov    (%eax),%dl
  c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  c3:	8a 00                	mov    (%eax),%al
  c5:	38 c2                	cmp    %al,%dl
  c7:	74 e3                	je     ac <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  c9:	8b 45 08             	mov    0x8(%ebp),%eax
  cc:	8a 00                	mov    (%eax),%al
  ce:	0f b6 d0             	movzbl %al,%edx
  d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  d4:	8a 00                	mov    (%eax),%al
  d6:	0f b6 c0             	movzbl %al,%eax
  d9:	29 c2                	sub    %eax,%edx
  db:	89 d0                	mov    %edx,%eax
}
  dd:	5d                   	pop    %ebp
  de:	c3                   	ret    

000000df <strlen>:

uint
strlen(char *s)
{
  df:	55                   	push   %ebp
  e0:	89 e5                	mov    %esp,%ebp
  e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ec:	eb 03                	jmp    f1 <strlen+0x12>
  ee:	ff 45 fc             	incl   -0x4(%ebp)
  f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	01 d0                	add    %edx,%eax
  f9:	8a 00                	mov    (%eax),%al
  fb:	84 c0                	test   %al,%al
  fd:	75 ef                	jne    ee <strlen+0xf>
    ;
  return n;
  ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <memset>:

void*
memset(void *dst, int c, uint n)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 10a:	8b 45 10             	mov    0x10(%ebp),%eax
 10d:	89 44 24 08          	mov    %eax,0x8(%esp)
 111:	8b 45 0c             	mov    0xc(%ebp),%eax
 114:	89 44 24 04          	mov    %eax,0x4(%esp)
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	89 04 24             	mov    %eax,(%esp)
 11e:	e8 31 ff ff ff       	call   54 <stosb>
  return dst;
 123:	8b 45 08             	mov    0x8(%ebp),%eax
}
 126:	c9                   	leave  
 127:	c3                   	ret    

00000128 <strchr>:

char*
strchr(const char *s, char c)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 04             	sub    $0x4,%esp
 12e:	8b 45 0c             	mov    0xc(%ebp),%eax
 131:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 134:	eb 12                	jmp    148 <strchr+0x20>
    if(*s == c)
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	8a 00                	mov    (%eax),%al
 13b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 13e:	75 05                	jne    145 <strchr+0x1d>
      return (char*)s;
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	eb 11                	jmp    156 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 145:	ff 45 08             	incl   0x8(%ebp)
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	8a 00                	mov    (%eax),%al
 14d:	84 c0                	test   %al,%al
 14f:	75 e5                	jne    136 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 151:	b8 00 00 00 00       	mov    $0x0,%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <gets>:

char*
gets(char *buf, int max)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 165:	eb 49                	jmp    1b0 <gets+0x58>
    cc = read(0, &c, 1);
 167:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 16e:	00 
 16f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 172:	89 44 24 04          	mov    %eax,0x4(%esp)
 176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17d:	e8 3e 01 00 00       	call   2c0 <read>
 182:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 185:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 189:	7f 02                	jg     18d <gets+0x35>
      break;
 18b:	eb 2c                	jmp    1b9 <gets+0x61>
    buf[i++] = c;
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	8d 50 01             	lea    0x1(%eax),%edx
 193:	89 55 f4             	mov    %edx,-0xc(%ebp)
 196:	89 c2                	mov    %eax,%edx
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	01 c2                	add    %eax,%edx
 19d:	8a 45 ef             	mov    -0x11(%ebp),%al
 1a0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a2:	8a 45 ef             	mov    -0x11(%ebp),%al
 1a5:	3c 0a                	cmp    $0xa,%al
 1a7:	74 10                	je     1b9 <gets+0x61>
 1a9:	8a 45 ef             	mov    -0x11(%ebp),%al
 1ac:	3c 0d                	cmp    $0xd,%al
 1ae:	74 09                	je     1b9 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b3:	40                   	inc    %eax
 1b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1b7:	7c ae                	jl     167 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	01 d0                	add    %edx,%eax
 1c1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c7:	c9                   	leave  
 1c8:	c3                   	ret    

000001c9 <stat>:

int
stat(char *n, struct stat *st)
{
 1c9:	55                   	push   %ebp
 1ca:	89 e5                	mov    %esp,%ebp
 1cc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1d6:	00 
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 06 01 00 00       	call   2e8 <open>
 1e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e9:	79 07                	jns    1f2 <stat+0x29>
    return -1;
 1eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f0:	eb 23                	jmp    215 <stat+0x4c>
  r = fstat(fd, st);
 1f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fc:	89 04 24             	mov    %eax,(%esp)
 1ff:	e8 fc 00 00 00       	call   300 <fstat>
 204:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 207:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20a:	89 04 24             	mov    %eax,(%esp)
 20d:	e8 be 00 00 00       	call   2d0 <close>
  return r;
 212:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 215:	c9                   	leave  
 216:	c3                   	ret    

00000217 <atoi>:

int
atoi(const char *s)
{
 217:	55                   	push   %ebp
 218:	89 e5                	mov    %esp,%ebp
 21a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 21d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 224:	eb 24                	jmp    24a <atoi+0x33>
    n = n*10 + *s++ - '0';
 226:	8b 55 fc             	mov    -0x4(%ebp),%edx
 229:	89 d0                	mov    %edx,%eax
 22b:	c1 e0 02             	shl    $0x2,%eax
 22e:	01 d0                	add    %edx,%eax
 230:	01 c0                	add    %eax,%eax
 232:	89 c1                	mov    %eax,%ecx
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	8d 50 01             	lea    0x1(%eax),%edx
 23a:	89 55 08             	mov    %edx,0x8(%ebp)
 23d:	8a 00                	mov    (%eax),%al
 23f:	0f be c0             	movsbl %al,%eax
 242:	01 c8                	add    %ecx,%eax
 244:	83 e8 30             	sub    $0x30,%eax
 247:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	8a 00                	mov    (%eax),%al
 24f:	3c 2f                	cmp    $0x2f,%al
 251:	7e 09                	jle    25c <atoi+0x45>
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	8a 00                	mov    (%eax),%al
 258:	3c 39                	cmp    $0x39,%al
 25a:	7e ca                	jle    226 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 25f:	c9                   	leave  
 260:	c3                   	ret    

00000261 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 273:	eb 16                	jmp    28b <memmove+0x2a>
    *dst++ = *src++;
 275:	8b 45 fc             	mov    -0x4(%ebp),%eax
 278:	8d 50 01             	lea    0x1(%eax),%edx
 27b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 27e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 281:	8d 4a 01             	lea    0x1(%edx),%ecx
 284:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 287:	8a 12                	mov    (%edx),%dl
 289:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 28b:	8b 45 10             	mov    0x10(%ebp),%eax
 28e:	8d 50 ff             	lea    -0x1(%eax),%edx
 291:	89 55 10             	mov    %edx,0x10(%ebp)
 294:	85 c0                	test   %eax,%eax
 296:	7f dd                	jg     275 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 298:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29b:	c9                   	leave  
 29c:	c3                   	ret    
 29d:	90                   	nop
 29e:	90                   	nop
 29f:	90                   	nop

000002a0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a0:	b8 01 00 00 00       	mov    $0x1,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <exit>:
SYSCALL(exit)
 2a8:	b8 02 00 00 00       	mov    $0x2,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <wait>:
SYSCALL(wait)
 2b0:	b8 03 00 00 00       	mov    $0x3,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <pipe>:
SYSCALL(pipe)
 2b8:	b8 04 00 00 00       	mov    $0x4,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <read>:
SYSCALL(read)
 2c0:	b8 05 00 00 00       	mov    $0x5,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <write>:
SYSCALL(write)
 2c8:	b8 10 00 00 00       	mov    $0x10,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <close>:
SYSCALL(close)
 2d0:	b8 15 00 00 00       	mov    $0x15,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <kill>:
SYSCALL(kill)
 2d8:	b8 06 00 00 00       	mov    $0x6,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <exec>:
SYSCALL(exec)
 2e0:	b8 07 00 00 00       	mov    $0x7,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <open>:
SYSCALL(open)
 2e8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <mknod>:
SYSCALL(mknod)
 2f0:	b8 11 00 00 00       	mov    $0x11,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <unlink>:
SYSCALL(unlink)
 2f8:	b8 12 00 00 00       	mov    $0x12,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <fstat>:
SYSCALL(fstat)
 300:	b8 08 00 00 00       	mov    $0x8,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <link>:
SYSCALL(link)
 308:	b8 13 00 00 00       	mov    $0x13,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <mkdir>:
SYSCALL(mkdir)
 310:	b8 14 00 00 00       	mov    $0x14,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <chdir>:
SYSCALL(chdir)
 318:	b8 09 00 00 00       	mov    $0x9,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <dup>:
SYSCALL(dup)
 320:	b8 0a 00 00 00       	mov    $0xa,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <getpid>:
SYSCALL(getpid)
 328:	b8 0b 00 00 00       	mov    $0xb,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <sbrk>:
SYSCALL(sbrk)
 330:	b8 0c 00 00 00       	mov    $0xc,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <sleep>:
SYSCALL(sleep)
 338:	b8 0d 00 00 00       	mov    $0xd,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <uptime>:
SYSCALL(uptime)
 340:	b8 0e 00 00 00       	mov    $0xe,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <getticks>:
SYSCALL(getticks)
 348:	b8 16 00 00 00       	mov    $0x16,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <get_name>:
SYSCALL(get_name)
 350:	b8 17 00 00 00       	mov    $0x17,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <get_max_proc>:
SYSCALL(get_max_proc)
 358:	b8 18 00 00 00       	mov    $0x18,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <get_max_mem>:
SYSCALL(get_max_mem)
 360:	b8 19 00 00 00       	mov    $0x19,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <get_max_disk>:
SYSCALL(get_max_disk)
 368:	b8 1a 00 00 00       	mov    $0x1a,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <get_curr_proc>:
SYSCALL(get_curr_proc)
 370:	b8 1b 00 00 00       	mov    $0x1b,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <get_curr_mem>:
SYSCALL(get_curr_mem)
 378:	b8 1c 00 00 00       	mov    $0x1c,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <get_curr_disk>:
SYSCALL(get_curr_disk)
 380:	b8 1d 00 00 00       	mov    $0x1d,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <set_name>:
SYSCALL(set_name)
 388:	b8 1e 00 00 00       	mov    $0x1e,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <set_max_mem>:
SYSCALL(set_max_mem)
 390:	b8 1f 00 00 00       	mov    $0x1f,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <set_max_disk>:
SYSCALL(set_max_disk)
 398:	b8 20 00 00 00       	mov    $0x20,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <set_max_proc>:
SYSCALL(set_max_proc)
 3a0:	b8 21 00 00 00       	mov    $0x21,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <set_curr_mem>:
SYSCALL(set_curr_mem)
 3a8:	b8 22 00 00 00       	mov    $0x22,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <set_curr_disk>:
SYSCALL(set_curr_disk)
 3b0:	b8 23 00 00 00       	mov    $0x23,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <set_curr_proc>:
SYSCALL(set_curr_proc)
 3b8:	b8 24 00 00 00       	mov    $0x24,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <find>:
SYSCALL(find)
 3c0:	b8 25 00 00 00       	mov    $0x25,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <is_full>:
SYSCALL(is_full)
 3c8:	b8 26 00 00 00       	mov    $0x26,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <container_init>:
SYSCALL(container_init)
 3d0:	b8 27 00 00 00       	mov    $0x27,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <cont_proc_set>:
SYSCALL(cont_proc_set)
 3d8:	b8 28 00 00 00       	mov    $0x28,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <ps>:
SYSCALL(ps)
 3e0:	b8 29 00 00 00       	mov    $0x29,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 3e8:	b8 2a 00 00 00       	mov    $0x2a,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <set_root_inode>:
SYSCALL(set_root_inode)
 3f0:	b8 2b 00 00 00       	mov    $0x2b,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <cstop>:
SYSCALL(cstop)
 3f8:	b8 2c 00 00 00       	mov    $0x2c,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <df>:
SYSCALL(df)
 400:	b8 2d 00 00 00       	mov    $0x2d,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <max_containers>:
SYSCALL(max_containers)
 408:	b8 2e 00 00 00       	mov    $0x2e,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <container_reset>:
SYSCALL(container_reset)
 410:	b8 2f 00 00 00       	mov    $0x2f,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <pause>:
SYSCALL(pause)
 418:	b8 30 00 00 00       	mov    $0x30,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <resume>:
SYSCALL(resume)
 420:	b8 31 00 00 00       	mov    $0x31,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <tmem>:
SYSCALL(tmem)
 428:	b8 32 00 00 00       	mov    $0x32,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <amem>:
SYSCALL(amem)
 430:	b8 33 00 00 00       	mov    $0x33,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <c_ps>:
SYSCALL(c_ps)
 438:	b8 34 00 00 00       	mov    $0x34,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 18             	sub    $0x18,%esp
 446:	8b 45 0c             	mov    0xc(%ebp),%eax
 449:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 44c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 453:	00 
 454:	8d 45 f4             	lea    -0xc(%ebp),%eax
 457:	89 44 24 04          	mov    %eax,0x4(%esp)
 45b:	8b 45 08             	mov    0x8(%ebp),%eax
 45e:	89 04 24             	mov    %eax,(%esp)
 461:	e8 62 fe ff ff       	call   2c8 <write>
}
 466:	c9                   	leave  
 467:	c3                   	ret    

00000468 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
 46b:	56                   	push   %esi
 46c:	53                   	push   %ebx
 46d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 470:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 477:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 47b:	74 17                	je     494 <printint+0x2c>
 47d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 481:	79 11                	jns    494 <printint+0x2c>
    neg = 1;
 483:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 48a:	8b 45 0c             	mov    0xc(%ebp),%eax
 48d:	f7 d8                	neg    %eax
 48f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 492:	eb 06                	jmp    49a <printint+0x32>
  } else {
    x = xx;
 494:	8b 45 0c             	mov    0xc(%ebp),%eax
 497:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 49a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4a1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4a4:	8d 41 01             	lea    0x1(%ecx),%eax
 4a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b0:	ba 00 00 00 00       	mov    $0x0,%edx
 4b5:	f7 f3                	div    %ebx
 4b7:	89 d0                	mov    %edx,%eax
 4b9:	8a 80 64 0b 00 00    	mov    0xb64(%eax),%al
 4bf:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4c3:	8b 75 10             	mov    0x10(%ebp),%esi
 4c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c9:	ba 00 00 00 00       	mov    $0x0,%edx
 4ce:	f7 f6                	div    %esi
 4d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4d7:	75 c8                	jne    4a1 <printint+0x39>
  if(neg)
 4d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4dd:	74 10                	je     4ef <printint+0x87>
    buf[i++] = '-';
 4df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e2:	8d 50 01             	lea    0x1(%eax),%edx
 4e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4e8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4ed:	eb 1e                	jmp    50d <printint+0xa5>
 4ef:	eb 1c                	jmp    50d <printint+0xa5>
    putc(fd, buf[i]);
 4f1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f7:	01 d0                	add    %edx,%eax
 4f9:	8a 00                	mov    (%eax),%al
 4fb:	0f be c0             	movsbl %al,%eax
 4fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 502:	8b 45 08             	mov    0x8(%ebp),%eax
 505:	89 04 24             	mov    %eax,(%esp)
 508:	e8 33 ff ff ff       	call   440 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 50d:	ff 4d f4             	decl   -0xc(%ebp)
 510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 514:	79 db                	jns    4f1 <printint+0x89>
    putc(fd, buf[i]);
}
 516:	83 c4 30             	add    $0x30,%esp
 519:	5b                   	pop    %ebx
 51a:	5e                   	pop    %esi
 51b:	5d                   	pop    %ebp
 51c:	c3                   	ret    

0000051d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 51d:	55                   	push   %ebp
 51e:	89 e5                	mov    %esp,%ebp
 520:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 523:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 52a:	8d 45 0c             	lea    0xc(%ebp),%eax
 52d:	83 c0 04             	add    $0x4,%eax
 530:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 533:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 53a:	e9 77 01 00 00       	jmp    6b6 <printf+0x199>
    c = fmt[i] & 0xff;
 53f:	8b 55 0c             	mov    0xc(%ebp),%edx
 542:	8b 45 f0             	mov    -0x10(%ebp),%eax
 545:	01 d0                	add    %edx,%eax
 547:	8a 00                	mov    (%eax),%al
 549:	0f be c0             	movsbl %al,%eax
 54c:	25 ff 00 00 00       	and    $0xff,%eax
 551:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 554:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 558:	75 2c                	jne    586 <printf+0x69>
      if(c == '%'){
 55a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 55e:	75 0c                	jne    56c <printf+0x4f>
        state = '%';
 560:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 567:	e9 47 01 00 00       	jmp    6b3 <printf+0x196>
      } else {
        putc(fd, c);
 56c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56f:	0f be c0             	movsbl %al,%eax
 572:	89 44 24 04          	mov    %eax,0x4(%esp)
 576:	8b 45 08             	mov    0x8(%ebp),%eax
 579:	89 04 24             	mov    %eax,(%esp)
 57c:	e8 bf fe ff ff       	call   440 <putc>
 581:	e9 2d 01 00 00       	jmp    6b3 <printf+0x196>
      }
    } else if(state == '%'){
 586:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 58a:	0f 85 23 01 00 00    	jne    6b3 <printf+0x196>
      if(c == 'd'){
 590:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 594:	75 2d                	jne    5c3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 596:	8b 45 e8             	mov    -0x18(%ebp),%eax
 599:	8b 00                	mov    (%eax),%eax
 59b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5a2:	00 
 5a3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5aa:	00 
 5ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 5af:	8b 45 08             	mov    0x8(%ebp),%eax
 5b2:	89 04 24             	mov    %eax,(%esp)
 5b5:	e8 ae fe ff ff       	call   468 <printint>
        ap++;
 5ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5be:	e9 e9 00 00 00       	jmp    6ac <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5c3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5c7:	74 06                	je     5cf <printf+0xb2>
 5c9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5cd:	75 2d                	jne    5fc <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d2:	8b 00                	mov    (%eax),%eax
 5d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5db:	00 
 5dc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5e3:	00 
 5e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e8:	8b 45 08             	mov    0x8(%ebp),%eax
 5eb:	89 04 24             	mov    %eax,(%esp)
 5ee:	e8 75 fe ff ff       	call   468 <printint>
        ap++;
 5f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f7:	e9 b0 00 00 00       	jmp    6ac <printf+0x18f>
      } else if(c == 's'){
 5fc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 600:	75 42                	jne    644 <printf+0x127>
        s = (char*)*ap;
 602:	8b 45 e8             	mov    -0x18(%ebp),%eax
 605:	8b 00                	mov    (%eax),%eax
 607:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 60a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 60e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 612:	75 09                	jne    61d <printf+0x100>
          s = "(null)";
 614:	c7 45 f4 19 09 00 00 	movl   $0x919,-0xc(%ebp)
        while(*s != 0){
 61b:	eb 1c                	jmp    639 <printf+0x11c>
 61d:	eb 1a                	jmp    639 <printf+0x11c>
          putc(fd, *s);
 61f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 622:	8a 00                	mov    (%eax),%al
 624:	0f be c0             	movsbl %al,%eax
 627:	89 44 24 04          	mov    %eax,0x4(%esp)
 62b:	8b 45 08             	mov    0x8(%ebp),%eax
 62e:	89 04 24             	mov    %eax,(%esp)
 631:	e8 0a fe ff ff       	call   440 <putc>
          s++;
 636:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 639:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63c:	8a 00                	mov    (%eax),%al
 63e:	84 c0                	test   %al,%al
 640:	75 dd                	jne    61f <printf+0x102>
 642:	eb 68                	jmp    6ac <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 644:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 648:	75 1d                	jne    667 <printf+0x14a>
        putc(fd, *ap);
 64a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64d:	8b 00                	mov    (%eax),%eax
 64f:	0f be c0             	movsbl %al,%eax
 652:	89 44 24 04          	mov    %eax,0x4(%esp)
 656:	8b 45 08             	mov    0x8(%ebp),%eax
 659:	89 04 24             	mov    %eax,(%esp)
 65c:	e8 df fd ff ff       	call   440 <putc>
        ap++;
 661:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 665:	eb 45                	jmp    6ac <printf+0x18f>
      } else if(c == '%'){
 667:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 66b:	75 17                	jne    684 <printf+0x167>
        putc(fd, c);
 66d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 670:	0f be c0             	movsbl %al,%eax
 673:	89 44 24 04          	mov    %eax,0x4(%esp)
 677:	8b 45 08             	mov    0x8(%ebp),%eax
 67a:	89 04 24             	mov    %eax,(%esp)
 67d:	e8 be fd ff ff       	call   440 <putc>
 682:	eb 28                	jmp    6ac <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 684:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 68b:	00 
 68c:	8b 45 08             	mov    0x8(%ebp),%eax
 68f:	89 04 24             	mov    %eax,(%esp)
 692:	e8 a9 fd ff ff       	call   440 <putc>
        putc(fd, c);
 697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 69a:	0f be c0             	movsbl %al,%eax
 69d:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a1:	8b 45 08             	mov    0x8(%ebp),%eax
 6a4:	89 04 24             	mov    %eax,(%esp)
 6a7:	e8 94 fd ff ff       	call   440 <putc>
      }
      state = 0;
 6ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6b3:	ff 45 f0             	incl   -0x10(%ebp)
 6b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bc:	01 d0                	add    %edx,%eax
 6be:	8a 00                	mov    (%eax),%al
 6c0:	84 c0                	test   %al,%al
 6c2:	0f 85 77 fe ff ff    	jne    53f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6c8:	c9                   	leave  
 6c9:	c3                   	ret    
 6ca:	90                   	nop
 6cb:	90                   	nop

000006cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6cc:	55                   	push   %ebp
 6cd:	89 e5                	mov    %esp,%ebp
 6cf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d2:	8b 45 08             	mov    0x8(%ebp),%eax
 6d5:	83 e8 08             	sub    $0x8,%eax
 6d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6db:	a1 80 0b 00 00       	mov    0xb80,%eax
 6e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e3:	eb 24                	jmp    709 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ed:	77 12                	ja     701 <free+0x35>
 6ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f5:	77 24                	ja     71b <free+0x4f>
 6f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fa:	8b 00                	mov    (%eax),%eax
 6fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ff:	77 1a                	ja     71b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	89 45 fc             	mov    %eax,-0x4(%ebp)
 709:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70f:	76 d4                	jbe    6e5 <free+0x19>
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 719:	76 ca                	jbe    6e5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 71b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71e:	8b 40 04             	mov    0x4(%eax),%eax
 721:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 728:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72b:	01 c2                	add    %eax,%edx
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	39 c2                	cmp    %eax,%edx
 734:	75 24                	jne    75a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 736:	8b 45 f8             	mov    -0x8(%ebp),%eax
 739:	8b 50 04             	mov    0x4(%eax),%edx
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 00                	mov    (%eax),%eax
 741:	8b 40 04             	mov    0x4(%eax),%eax
 744:	01 c2                	add    %eax,%edx
 746:	8b 45 f8             	mov    -0x8(%ebp),%eax
 749:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	8b 10                	mov    (%eax),%edx
 753:	8b 45 f8             	mov    -0x8(%ebp),%eax
 756:	89 10                	mov    %edx,(%eax)
 758:	eb 0a                	jmp    764 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 75a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75d:	8b 10                	mov    (%eax),%edx
 75f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 762:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 764:	8b 45 fc             	mov    -0x4(%ebp),%eax
 767:	8b 40 04             	mov    0x4(%eax),%eax
 76a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	01 d0                	add    %edx,%eax
 776:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 779:	75 20                	jne    79b <free+0xcf>
    p->s.size += bp->s.size;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	8b 50 04             	mov    0x4(%eax),%edx
 781:	8b 45 f8             	mov    -0x8(%ebp),%eax
 784:	8b 40 04             	mov    0x4(%eax),%eax
 787:	01 c2                	add    %eax,%edx
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 78f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 792:	8b 10                	mov    (%eax),%edx
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	89 10                	mov    %edx,(%eax)
 799:	eb 08                	jmp    7a3 <free+0xd7>
  } else
    p->s.ptr = bp;
 79b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7a1:	89 10                	mov    %edx,(%eax)
  freep = p;
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	a3 80 0b 00 00       	mov    %eax,0xb80
}
 7ab:	c9                   	leave  
 7ac:	c3                   	ret    

000007ad <morecore>:

static Header*
morecore(uint nu)
{
 7ad:	55                   	push   %ebp
 7ae:	89 e5                	mov    %esp,%ebp
 7b0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7b3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ba:	77 07                	ja     7c3 <morecore+0x16>
    nu = 4096;
 7bc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7c3:	8b 45 08             	mov    0x8(%ebp),%eax
 7c6:	c1 e0 03             	shl    $0x3,%eax
 7c9:	89 04 24             	mov    %eax,(%esp)
 7cc:	e8 5f fb ff ff       	call   330 <sbrk>
 7d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7d4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7d8:	75 07                	jne    7e1 <morecore+0x34>
    return 0;
 7da:	b8 00 00 00 00       	mov    $0x0,%eax
 7df:	eb 22                	jmp    803 <morecore+0x56>
  hp = (Header*)p;
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ea:	8b 55 08             	mov    0x8(%ebp),%edx
 7ed:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f3:	83 c0 08             	add    $0x8,%eax
 7f6:	89 04 24             	mov    %eax,(%esp)
 7f9:	e8 ce fe ff ff       	call   6cc <free>
  return freep;
 7fe:	a1 80 0b 00 00       	mov    0xb80,%eax
}
 803:	c9                   	leave  
 804:	c3                   	ret    

00000805 <malloc>:

void*
malloc(uint nbytes)
{
 805:	55                   	push   %ebp
 806:	89 e5                	mov    %esp,%ebp
 808:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	83 c0 07             	add    $0x7,%eax
 811:	c1 e8 03             	shr    $0x3,%eax
 814:	40                   	inc    %eax
 815:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 818:	a1 80 0b 00 00       	mov    0xb80,%eax
 81d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 820:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 824:	75 23                	jne    849 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 826:	c7 45 f0 78 0b 00 00 	movl   $0xb78,-0x10(%ebp)
 82d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 830:	a3 80 0b 00 00       	mov    %eax,0xb80
 835:	a1 80 0b 00 00       	mov    0xb80,%eax
 83a:	a3 78 0b 00 00       	mov    %eax,0xb78
    base.s.size = 0;
 83f:	c7 05 7c 0b 00 00 00 	movl   $0x0,0xb7c
 846:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 849:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 851:	8b 45 f4             	mov    -0xc(%ebp),%eax
 854:	8b 40 04             	mov    0x4(%eax),%eax
 857:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85a:	72 4d                	jb     8a9 <malloc+0xa4>
      if(p->s.size == nunits)
 85c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85f:	8b 40 04             	mov    0x4(%eax),%eax
 862:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 865:	75 0c                	jne    873 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 867:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86a:	8b 10                	mov    (%eax),%edx
 86c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86f:	89 10                	mov    %edx,(%eax)
 871:	eb 26                	jmp    899 <malloc+0x94>
      else {
        p->s.size -= nunits;
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	8b 40 04             	mov    0x4(%eax),%eax
 879:	2b 45 ec             	sub    -0x14(%ebp),%eax
 87c:	89 c2                	mov    %eax,%edx
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 884:	8b 45 f4             	mov    -0xc(%ebp),%eax
 887:	8b 40 04             	mov    0x4(%eax),%eax
 88a:	c1 e0 03             	shl    $0x3,%eax
 88d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 890:	8b 45 f4             	mov    -0xc(%ebp),%eax
 893:	8b 55 ec             	mov    -0x14(%ebp),%edx
 896:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 899:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89c:	a3 80 0b 00 00       	mov    %eax,0xb80
      return (void*)(p + 1);
 8a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a4:	83 c0 08             	add    $0x8,%eax
 8a7:	eb 38                	jmp    8e1 <malloc+0xdc>
    }
    if(p == freep)
 8a9:	a1 80 0b 00 00       	mov    0xb80,%eax
 8ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8b1:	75 1b                	jne    8ce <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8b6:	89 04 24             	mov    %eax,(%esp)
 8b9:	e8 ef fe ff ff       	call   7ad <morecore>
 8be:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8c5:	75 07                	jne    8ce <malloc+0xc9>
        return 0;
 8c7:	b8 00 00 00 00       	mov    $0x0,%eax
 8cc:	eb 13                	jmp    8e1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d7:	8b 00                	mov    (%eax),%eax
 8d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8dc:	e9 70 ff ff ff       	jmp    851 <malloc+0x4c>
}
 8e1:	c9                   	leave  
 8e2:	c3                   	ret    
