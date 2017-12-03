
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
	printf(1, "%d (%d used) availabe pages out of %d total pages.\n", avail-used, used, avail);
  1b:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  1f:	8b 54 24 28          	mov    0x28(%esp),%edx
  23:	29 c2                	sub    %eax,%edx
  25:	8b 44 24 28          	mov    0x28(%esp),%eax
  29:	89 44 24 10          	mov    %eax,0x10(%esp)
  2d:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  35:	89 54 24 08          	mov    %edx,0x8(%esp)
  39:	c7 44 24 04 dc 08 00 	movl   $0x8dc,0x4(%esp)
  40:	00 
  41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  48:	e8 c8 04 00 00       	call   515 <printf>
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

00000438 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 438:	55                   	push   %ebp
 439:	89 e5                	mov    %esp,%ebp
 43b:	83 ec 18             	sub    $0x18,%esp
 43e:	8b 45 0c             	mov    0xc(%ebp),%eax
 441:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 444:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 44b:	00 
 44c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 44f:	89 44 24 04          	mov    %eax,0x4(%esp)
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	89 04 24             	mov    %eax,(%esp)
 459:	e8 6a fe ff ff       	call   2c8 <write>
}
 45e:	c9                   	leave  
 45f:	c3                   	ret    

00000460 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	56                   	push   %esi
 464:	53                   	push   %ebx
 465:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 468:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 46f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 473:	74 17                	je     48c <printint+0x2c>
 475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 479:	79 11                	jns    48c <printint+0x2c>
    neg = 1;
 47b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 482:	8b 45 0c             	mov    0xc(%ebp),%eax
 485:	f7 d8                	neg    %eax
 487:	89 45 ec             	mov    %eax,-0x14(%ebp)
 48a:	eb 06                	jmp    492 <printint+0x32>
  } else {
    x = xx;
 48c:	8b 45 0c             	mov    0xc(%ebp),%eax
 48f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 492:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 499:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 49c:	8d 41 01             	lea    0x1(%ecx),%eax
 49f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a8:	ba 00 00 00 00       	mov    $0x0,%edx
 4ad:	f7 f3                	div    %ebx
 4af:	89 d0                	mov    %edx,%eax
 4b1:	8a 80 5c 0b 00 00    	mov    0xb5c(%eax),%al
 4b7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4bb:	8b 75 10             	mov    0x10(%ebp),%esi
 4be:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c1:	ba 00 00 00 00       	mov    $0x0,%edx
 4c6:	f7 f6                	div    %esi
 4c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cf:	75 c8                	jne    499 <printint+0x39>
  if(neg)
 4d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4d5:	74 10                	je     4e7 <printint+0x87>
    buf[i++] = '-';
 4d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4da:	8d 50 01             	lea    0x1(%eax),%edx
 4dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4e0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4e5:	eb 1e                	jmp    505 <printint+0xa5>
 4e7:	eb 1c                	jmp    505 <printint+0xa5>
    putc(fd, buf[i]);
 4e9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ef:	01 d0                	add    %edx,%eax
 4f1:	8a 00                	mov    (%eax),%al
 4f3:	0f be c0             	movsbl %al,%eax
 4f6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	89 04 24             	mov    %eax,(%esp)
 500:	e8 33 ff ff ff       	call   438 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 505:	ff 4d f4             	decl   -0xc(%ebp)
 508:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50c:	79 db                	jns    4e9 <printint+0x89>
    putc(fd, buf[i]);
}
 50e:	83 c4 30             	add    $0x30,%esp
 511:	5b                   	pop    %ebx
 512:	5e                   	pop    %esi
 513:	5d                   	pop    %ebp
 514:	c3                   	ret    

00000515 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 515:	55                   	push   %ebp
 516:	89 e5                	mov    %esp,%ebp
 518:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 51b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 522:	8d 45 0c             	lea    0xc(%ebp),%eax
 525:	83 c0 04             	add    $0x4,%eax
 528:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 52b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 532:	e9 77 01 00 00       	jmp    6ae <printf+0x199>
    c = fmt[i] & 0xff;
 537:	8b 55 0c             	mov    0xc(%ebp),%edx
 53a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 53d:	01 d0                	add    %edx,%eax
 53f:	8a 00                	mov    (%eax),%al
 541:	0f be c0             	movsbl %al,%eax
 544:	25 ff 00 00 00       	and    $0xff,%eax
 549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 54c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 550:	75 2c                	jne    57e <printf+0x69>
      if(c == '%'){
 552:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 556:	75 0c                	jne    564 <printf+0x4f>
        state = '%';
 558:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 55f:	e9 47 01 00 00       	jmp    6ab <printf+0x196>
      } else {
        putc(fd, c);
 564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 567:	0f be c0             	movsbl %al,%eax
 56a:	89 44 24 04          	mov    %eax,0x4(%esp)
 56e:	8b 45 08             	mov    0x8(%ebp),%eax
 571:	89 04 24             	mov    %eax,(%esp)
 574:	e8 bf fe ff ff       	call   438 <putc>
 579:	e9 2d 01 00 00       	jmp    6ab <printf+0x196>
      }
    } else if(state == '%'){
 57e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 582:	0f 85 23 01 00 00    	jne    6ab <printf+0x196>
      if(c == 'd'){
 588:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 58c:	75 2d                	jne    5bb <printf+0xa6>
        printint(fd, *ap, 10, 1);
 58e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 591:	8b 00                	mov    (%eax),%eax
 593:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 59a:	00 
 59b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5a2:	00 
 5a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a7:	8b 45 08             	mov    0x8(%ebp),%eax
 5aa:	89 04 24             	mov    %eax,(%esp)
 5ad:	e8 ae fe ff ff       	call   460 <printint>
        ap++;
 5b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b6:	e9 e9 00 00 00       	jmp    6a4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5bb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5bf:	74 06                	je     5c7 <printf+0xb2>
 5c1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5c5:	75 2d                	jne    5f4 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ca:	8b 00                	mov    (%eax),%eax
 5cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5d3:	00 
 5d4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5db:	00 
 5dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
 5e3:	89 04 24             	mov    %eax,(%esp)
 5e6:	e8 75 fe ff ff       	call   460 <printint>
        ap++;
 5eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ef:	e9 b0 00 00 00       	jmp    6a4 <printf+0x18f>
      } else if(c == 's'){
 5f4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f8:	75 42                	jne    63c <printf+0x127>
        s = (char*)*ap;
 5fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fd:	8b 00                	mov    (%eax),%eax
 5ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 602:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 606:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 60a:	75 09                	jne    615 <printf+0x100>
          s = "(null)";
 60c:	c7 45 f4 10 09 00 00 	movl   $0x910,-0xc(%ebp)
        while(*s != 0){
 613:	eb 1c                	jmp    631 <printf+0x11c>
 615:	eb 1a                	jmp    631 <printf+0x11c>
          putc(fd, *s);
 617:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61a:	8a 00                	mov    (%eax),%al
 61c:	0f be c0             	movsbl %al,%eax
 61f:	89 44 24 04          	mov    %eax,0x4(%esp)
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	89 04 24             	mov    %eax,(%esp)
 629:	e8 0a fe ff ff       	call   438 <putc>
          s++;
 62e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 631:	8b 45 f4             	mov    -0xc(%ebp),%eax
 634:	8a 00                	mov    (%eax),%al
 636:	84 c0                	test   %al,%al
 638:	75 dd                	jne    617 <printf+0x102>
 63a:	eb 68                	jmp    6a4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 63c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 640:	75 1d                	jne    65f <printf+0x14a>
        putc(fd, *ap);
 642:	8b 45 e8             	mov    -0x18(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	89 44 24 04          	mov    %eax,0x4(%esp)
 64e:	8b 45 08             	mov    0x8(%ebp),%eax
 651:	89 04 24             	mov    %eax,(%esp)
 654:	e8 df fd ff ff       	call   438 <putc>
        ap++;
 659:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65d:	eb 45                	jmp    6a4 <printf+0x18f>
      } else if(c == '%'){
 65f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 663:	75 17                	jne    67c <printf+0x167>
        putc(fd, c);
 665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 668:	0f be c0             	movsbl %al,%eax
 66b:	89 44 24 04          	mov    %eax,0x4(%esp)
 66f:	8b 45 08             	mov    0x8(%ebp),%eax
 672:	89 04 24             	mov    %eax,(%esp)
 675:	e8 be fd ff ff       	call   438 <putc>
 67a:	eb 28                	jmp    6a4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 67c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 683:	00 
 684:	8b 45 08             	mov    0x8(%ebp),%eax
 687:	89 04 24             	mov    %eax,(%esp)
 68a:	e8 a9 fd ff ff       	call   438 <putc>
        putc(fd, c);
 68f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 692:	0f be c0             	movsbl %al,%eax
 695:	89 44 24 04          	mov    %eax,0x4(%esp)
 699:	8b 45 08             	mov    0x8(%ebp),%eax
 69c:	89 04 24             	mov    %eax,(%esp)
 69f:	e8 94 fd ff ff       	call   438 <putc>
      }
      state = 0;
 6a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6ab:	ff 45 f0             	incl   -0x10(%ebp)
 6ae:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b4:	01 d0                	add    %edx,%eax
 6b6:	8a 00                	mov    (%eax),%al
 6b8:	84 c0                	test   %al,%al
 6ba:	0f 85 77 fe ff ff    	jne    537 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6c0:	c9                   	leave  
 6c1:	c3                   	ret    
 6c2:	90                   	nop
 6c3:	90                   	nop

000006c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c4:	55                   	push   %ebp
 6c5:	89 e5                	mov    %esp,%ebp
 6c7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ca:	8b 45 08             	mov    0x8(%ebp),%eax
 6cd:	83 e8 08             	sub    $0x8,%eax
 6d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d3:	a1 78 0b 00 00       	mov    0xb78,%eax
 6d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6db:	eb 24                	jmp    701 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e5:	77 12                	ja     6f9 <free+0x35>
 6e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ed:	77 24                	ja     713 <free+0x4f>
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	8b 00                	mov    (%eax),%eax
 6f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f7:	77 1a                	ja     713 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 701:	8b 45 f8             	mov    -0x8(%ebp),%eax
 704:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 707:	76 d4                	jbe    6dd <free+0x19>
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	8b 00                	mov    (%eax),%eax
 70e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 711:	76 ca                	jbe    6dd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 713:	8b 45 f8             	mov    -0x8(%ebp),%eax
 716:	8b 40 04             	mov    0x4(%eax),%eax
 719:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 720:	8b 45 f8             	mov    -0x8(%ebp),%eax
 723:	01 c2                	add    %eax,%edx
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 00                	mov    (%eax),%eax
 72a:	39 c2                	cmp    %eax,%edx
 72c:	75 24                	jne    752 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	8b 50 04             	mov    0x4(%eax),%edx
 734:	8b 45 fc             	mov    -0x4(%ebp),%eax
 737:	8b 00                	mov    (%eax),%eax
 739:	8b 40 04             	mov    0x4(%eax),%eax
 73c:	01 c2                	add    %eax,%edx
 73e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 741:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 744:	8b 45 fc             	mov    -0x4(%ebp),%eax
 747:	8b 00                	mov    (%eax),%eax
 749:	8b 10                	mov    (%eax),%edx
 74b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74e:	89 10                	mov    %edx,(%eax)
 750:	eb 0a                	jmp    75c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 752:	8b 45 fc             	mov    -0x4(%ebp),%eax
 755:	8b 10                	mov    (%eax),%edx
 757:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 40 04             	mov    0x4(%eax),%eax
 762:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 769:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76c:	01 d0                	add    %edx,%eax
 76e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 771:	75 20                	jne    793 <free+0xcf>
    p->s.size += bp->s.size;
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	8b 50 04             	mov    0x4(%eax),%edx
 779:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77c:	8b 40 04             	mov    0x4(%eax),%eax
 77f:	01 c2                	add    %eax,%edx
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 787:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78a:	8b 10                	mov    (%eax),%edx
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	89 10                	mov    %edx,(%eax)
 791:	eb 08                	jmp    79b <free+0xd7>
  } else
    p->s.ptr = bp;
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	8b 55 f8             	mov    -0x8(%ebp),%edx
 799:	89 10                	mov    %edx,(%eax)
  freep = p;
 79b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79e:	a3 78 0b 00 00       	mov    %eax,0xb78
}
 7a3:	c9                   	leave  
 7a4:	c3                   	ret    

000007a5 <morecore>:

static Header*
morecore(uint nu)
{
 7a5:	55                   	push   %ebp
 7a6:	89 e5                	mov    %esp,%ebp
 7a8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7ab:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7b2:	77 07                	ja     7bb <morecore+0x16>
    nu = 4096;
 7b4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	c1 e0 03             	shl    $0x3,%eax
 7c1:	89 04 24             	mov    %eax,(%esp)
 7c4:	e8 67 fb ff ff       	call   330 <sbrk>
 7c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7d0:	75 07                	jne    7d9 <morecore+0x34>
    return 0;
 7d2:	b8 00 00 00 00       	mov    $0x0,%eax
 7d7:	eb 22                	jmp    7fb <morecore+0x56>
  hp = (Header*)p;
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e2:	8b 55 08             	mov    0x8(%ebp),%edx
 7e5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7eb:	83 c0 08             	add    $0x8,%eax
 7ee:	89 04 24             	mov    %eax,(%esp)
 7f1:	e8 ce fe ff ff       	call   6c4 <free>
  return freep;
 7f6:	a1 78 0b 00 00       	mov    0xb78,%eax
}
 7fb:	c9                   	leave  
 7fc:	c3                   	ret    

000007fd <malloc>:

void*
malloc(uint nbytes)
{
 7fd:	55                   	push   %ebp
 7fe:	89 e5                	mov    %esp,%ebp
 800:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 803:	8b 45 08             	mov    0x8(%ebp),%eax
 806:	83 c0 07             	add    $0x7,%eax
 809:	c1 e8 03             	shr    $0x3,%eax
 80c:	40                   	inc    %eax
 80d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 810:	a1 78 0b 00 00       	mov    0xb78,%eax
 815:	89 45 f0             	mov    %eax,-0x10(%ebp)
 818:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 81c:	75 23                	jne    841 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 81e:	c7 45 f0 70 0b 00 00 	movl   $0xb70,-0x10(%ebp)
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	a3 78 0b 00 00       	mov    %eax,0xb78
 82d:	a1 78 0b 00 00       	mov    0xb78,%eax
 832:	a3 70 0b 00 00       	mov    %eax,0xb70
    base.s.size = 0;
 837:	c7 05 74 0b 00 00 00 	movl   $0x0,0xb74
 83e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 841:	8b 45 f0             	mov    -0x10(%ebp),%eax
 844:	8b 00                	mov    (%eax),%eax
 846:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	8b 40 04             	mov    0x4(%eax),%eax
 84f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 852:	72 4d                	jb     8a1 <malloc+0xa4>
      if(p->s.size == nunits)
 854:	8b 45 f4             	mov    -0xc(%ebp),%eax
 857:	8b 40 04             	mov    0x4(%eax),%eax
 85a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85d:	75 0c                	jne    86b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 10                	mov    (%eax),%edx
 864:	8b 45 f0             	mov    -0x10(%ebp),%eax
 867:	89 10                	mov    %edx,(%eax)
 869:	eb 26                	jmp    891 <malloc+0x94>
      else {
        p->s.size -= nunits;
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	8b 40 04             	mov    0x4(%eax),%eax
 871:	2b 45 ec             	sub    -0x14(%ebp),%eax
 874:	89 c2                	mov    %eax,%edx
 876:	8b 45 f4             	mov    -0xc(%ebp),%eax
 879:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	8b 40 04             	mov    0x4(%eax),%eax
 882:	c1 e0 03             	shl    $0x3,%eax
 885:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 888:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 88e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 891:	8b 45 f0             	mov    -0x10(%ebp),%eax
 894:	a3 78 0b 00 00       	mov    %eax,0xb78
      return (void*)(p + 1);
 899:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89c:	83 c0 08             	add    $0x8,%eax
 89f:	eb 38                	jmp    8d9 <malloc+0xdc>
    }
    if(p == freep)
 8a1:	a1 78 0b 00 00       	mov    0xb78,%eax
 8a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a9:	75 1b                	jne    8c6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ae:	89 04 24             	mov    %eax,(%esp)
 8b1:	e8 ef fe ff ff       	call   7a5 <morecore>
 8b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8bd:	75 07                	jne    8c6 <malloc+0xc9>
        return 0;
 8bf:	b8 00 00 00 00       	mov    $0x0,%eax
 8c4:	eb 13                	jmp    8d9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cf:	8b 00                	mov    (%eax),%eax
 8d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8d4:	e9 70 ff ff ff       	jmp    849 <malloc+0x4c>
}
 8d9:	c9                   	leave  
 8da:	c3                   	ret    
