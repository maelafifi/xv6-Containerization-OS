
_rm:     file format elf32-i386


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

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "Usage: rm files...\n");
   f:	c7 44 24 04 cf 08 00 	movl   $0x8cf,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 e6 04 00 00       	call   509 <printf>
    exit();
  23:	e8 bc 02 00 00       	call   2e4 <exit>
  }

  for(i = 1; i < argc; i++){
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 4e                	jmp    80 <main+0x80>
    if(unlink(argv[i]) < 0){
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 e8 02 00 00       	call   334 <unlink>
  4c:	85 c0                	test   %eax,%eax
  4e:	79 2c                	jns    7c <main+0x7c>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  50:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  5e:	01 d0                	add    %edx,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	89 44 24 08          	mov    %eax,0x8(%esp)
  66:	c7 44 24 04 e3 08 00 	movl   $0x8e3,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  75:	e8 8f 04 00 00       	call   509 <printf>
      break;
  7a:	eb 0d                	jmp    89 <main+0x89>
  if(argc < 2){
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  7c:	ff 44 24 1c          	incl   0x1c(%esp)
  80:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  84:	3b 45 08             	cmp    0x8(%ebp),%eax
  87:	7c a9                	jl     32 <main+0x32>
      printf(2, "rm: %s failed to delete\n", argv[i]);
      break;
    }
  }

  exit();
  89:	e8 56 02 00 00       	call   2e4 <exit>
  8e:	90                   	nop
  8f:	90                   	nop

00000090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  98:	8b 55 10             	mov    0x10(%ebp),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	89 cb                	mov    %ecx,%ebx
  a0:	89 df                	mov    %ebx,%edi
  a2:	89 d1                	mov    %edx,%ecx
  a4:	fc                   	cld    
  a5:	f3 aa                	rep stos %al,%es:(%edi)
  a7:	89 ca                	mov    %ecx,%edx
  a9:	89 fb                	mov    %edi,%ebx
  ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b1:	5b                   	pop    %ebx
  b2:	5f                   	pop    %edi
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c1:	90                   	nop
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	8d 50 01             	lea    0x1(%eax),%edx
  c8:	89 55 08             	mov    %edx,0x8(%ebp)
  cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  d1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d4:	8a 12                	mov    (%edx),%dl
  d6:	88 10                	mov    %dl,(%eax)
  d8:	8a 00                	mov    (%eax),%al
  da:	84 c0                	test   %al,%al
  dc:	75 e4                	jne    c2 <strcpy+0xd>
    ;
  return os;
  de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e6:	eb 06                	jmp    ee <strcmp+0xb>
    p++, q++;
  e8:	ff 45 08             	incl   0x8(%ebp)
  eb:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	8a 00                	mov    (%eax),%al
  f3:	84 c0                	test   %al,%al
  f5:	74 0e                	je     105 <strcmp+0x22>
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	8a 10                	mov    (%eax),%dl
  fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  ff:	8a 00                	mov    (%eax),%al
 101:	38 c2                	cmp    %al,%dl
 103:	74 e3                	je     e8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 105:	8b 45 08             	mov    0x8(%ebp),%eax
 108:	8a 00                	mov    (%eax),%al
 10a:	0f b6 d0             	movzbl %al,%edx
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	8a 00                	mov    (%eax),%al
 112:	0f b6 c0             	movzbl %al,%eax
 115:	29 c2                	sub    %eax,%edx
 117:	89 d0                	mov    %edx,%eax
}
 119:	5d                   	pop    %ebp
 11a:	c3                   	ret    

0000011b <strlen>:

uint
strlen(char *s)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
 11e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 121:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 128:	eb 03                	jmp    12d <strlen+0x12>
 12a:	ff 45 fc             	incl   -0x4(%ebp)
 12d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 130:	8b 45 08             	mov    0x8(%ebp),%eax
 133:	01 d0                	add    %edx,%eax
 135:	8a 00                	mov    (%eax),%al
 137:	84 c0                	test   %al,%al
 139:	75 ef                	jne    12a <strlen+0xf>
    ;
  return n;
 13b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 146:	8b 45 10             	mov    0x10(%ebp),%eax
 149:	89 44 24 08          	mov    %eax,0x8(%esp)
 14d:	8b 45 0c             	mov    0xc(%ebp),%eax
 150:	89 44 24 04          	mov    %eax,0x4(%esp)
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	89 04 24             	mov    %eax,(%esp)
 15a:	e8 31 ff ff ff       	call   90 <stosb>
  return dst;
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strchr>:

char*
strchr(const char *s, char c)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	83 ec 04             	sub    $0x4,%esp
 16a:	8b 45 0c             	mov    0xc(%ebp),%eax
 16d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 170:	eb 12                	jmp    184 <strchr+0x20>
    if(*s == c)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	8a 00                	mov    (%eax),%al
 177:	3a 45 fc             	cmp    -0x4(%ebp),%al
 17a:	75 05                	jne    181 <strchr+0x1d>
      return (char*)s;
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	eb 11                	jmp    192 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 181:	ff 45 08             	incl   0x8(%ebp)
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	8a 00                	mov    (%eax),%al
 189:	84 c0                	test   %al,%al
 18b:	75 e5                	jne    172 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 18d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 192:	c9                   	leave  
 193:	c3                   	ret    

00000194 <gets>:

char*
gets(char *buf, int max)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a1:	eb 49                	jmp    1ec <gets+0x58>
    cc = read(0, &c, 1);
 1a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1aa:	00 
 1ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b9:	e8 3e 01 00 00       	call   2fc <read>
 1be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c5:	7f 02                	jg     1c9 <gets+0x35>
      break;
 1c7:	eb 2c                	jmp    1f5 <gets+0x61>
    buf[i++] = c;
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	8d 50 01             	lea    0x1(%eax),%edx
 1cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1d2:	89 c2                	mov    %eax,%edx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	01 c2                	add    %eax,%edx
 1d9:	8a 45 ef             	mov    -0x11(%ebp),%al
 1dc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1de:	8a 45 ef             	mov    -0x11(%ebp),%al
 1e1:	3c 0a                	cmp    $0xa,%al
 1e3:	74 10                	je     1f5 <gets+0x61>
 1e5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1e8:	3c 0d                	cmp    $0xd,%al
 1ea:	74 09                	je     1f5 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ef:	40                   	inc    %eax
 1f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f3:	7c ae                	jl     1a3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	01 d0                	add    %edx,%eax
 1fd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 200:	8b 45 08             	mov    0x8(%ebp),%eax
}
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <stat>:

int
stat(char *n, struct stat *st)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 212:	00 
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	89 04 24             	mov    %eax,(%esp)
 219:	e8 06 01 00 00       	call   324 <open>
 21e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 221:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 225:	79 07                	jns    22e <stat+0x29>
    return -1;
 227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22c:	eb 23                	jmp    251 <stat+0x4c>
  r = fstat(fd, st);
 22e:	8b 45 0c             	mov    0xc(%ebp),%eax
 231:	89 44 24 04          	mov    %eax,0x4(%esp)
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	89 04 24             	mov    %eax,(%esp)
 23b:	e8 fc 00 00 00       	call   33c <fstat>
 240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 243:	8b 45 f4             	mov    -0xc(%ebp),%eax
 246:	89 04 24             	mov    %eax,(%esp)
 249:	e8 be 00 00 00       	call   30c <close>
  return r;
 24e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 251:	c9                   	leave  
 252:	c3                   	ret    

00000253 <atoi>:

int
atoi(const char *s)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 259:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 260:	eb 24                	jmp    286 <atoi+0x33>
    n = n*10 + *s++ - '0';
 262:	8b 55 fc             	mov    -0x4(%ebp),%edx
 265:	89 d0                	mov    %edx,%eax
 267:	c1 e0 02             	shl    $0x2,%eax
 26a:	01 d0                	add    %edx,%eax
 26c:	01 c0                	add    %eax,%eax
 26e:	89 c1                	mov    %eax,%ecx
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	8d 50 01             	lea    0x1(%eax),%edx
 276:	89 55 08             	mov    %edx,0x8(%ebp)
 279:	8a 00                	mov    (%eax),%al
 27b:	0f be c0             	movsbl %al,%eax
 27e:	01 c8                	add    %ecx,%eax
 280:	83 e8 30             	sub    $0x30,%eax
 283:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	8a 00                	mov    (%eax),%al
 28b:	3c 2f                	cmp    $0x2f,%al
 28d:	7e 09                	jle    298 <atoi+0x45>
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	8a 00                	mov    (%eax),%al
 294:	3c 39                	cmp    $0x39,%al
 296:	7e ca                	jle    262 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 298:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29b:	c9                   	leave  
 29c:	c3                   	ret    

0000029d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2af:	eb 16                	jmp    2c7 <memmove+0x2a>
    *dst++ = *src++;
 2b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b4:	8d 50 01             	lea    0x1(%eax),%edx
 2b7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2bd:	8d 4a 01             	lea    0x1(%edx),%ecx
 2c0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2c3:	8a 12                	mov    (%edx),%dl
 2c5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c7:	8b 45 10             	mov    0x10(%ebp),%eax
 2ca:	8d 50 ff             	lea    -0x1(%eax),%edx
 2cd:	89 55 10             	mov    %edx,0x10(%ebp)
 2d0:	85 c0                	test   %eax,%eax
 2d2:	7f dd                	jg     2b1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d7:	c9                   	leave  
 2d8:	c3                   	ret    
 2d9:	90                   	nop
 2da:	90                   	nop
 2db:	90                   	nop

000002dc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2dc:	b8 01 00 00 00       	mov    $0x1,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <exit>:
SYSCALL(exit)
 2e4:	b8 02 00 00 00       	mov    $0x2,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <wait>:
SYSCALL(wait)
 2ec:	b8 03 00 00 00       	mov    $0x3,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <pipe>:
SYSCALL(pipe)
 2f4:	b8 04 00 00 00       	mov    $0x4,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <read>:
SYSCALL(read)
 2fc:	b8 05 00 00 00       	mov    $0x5,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <write>:
SYSCALL(write)
 304:	b8 10 00 00 00       	mov    $0x10,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <close>:
SYSCALL(close)
 30c:	b8 15 00 00 00       	mov    $0x15,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <kill>:
SYSCALL(kill)
 314:	b8 06 00 00 00       	mov    $0x6,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <exec>:
SYSCALL(exec)
 31c:	b8 07 00 00 00       	mov    $0x7,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <open>:
SYSCALL(open)
 324:	b8 0f 00 00 00       	mov    $0xf,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <mknod>:
SYSCALL(mknod)
 32c:	b8 11 00 00 00       	mov    $0x11,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <unlink>:
SYSCALL(unlink)
 334:	b8 12 00 00 00       	mov    $0x12,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <fstat>:
SYSCALL(fstat)
 33c:	b8 08 00 00 00       	mov    $0x8,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <link>:
SYSCALL(link)
 344:	b8 13 00 00 00       	mov    $0x13,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <mkdir>:
SYSCALL(mkdir)
 34c:	b8 14 00 00 00       	mov    $0x14,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <chdir>:
SYSCALL(chdir)
 354:	b8 09 00 00 00       	mov    $0x9,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <dup>:
SYSCALL(dup)
 35c:	b8 0a 00 00 00       	mov    $0xa,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <getpid>:
SYSCALL(getpid)
 364:	b8 0b 00 00 00       	mov    $0xb,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <sbrk>:
SYSCALL(sbrk)
 36c:	b8 0c 00 00 00       	mov    $0xc,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <sleep>:
SYSCALL(sleep)
 374:	b8 0d 00 00 00       	mov    $0xd,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <uptime>:
SYSCALL(uptime)
 37c:	b8 0e 00 00 00       	mov    $0xe,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <getticks>:
SYSCALL(getticks)
 384:	b8 16 00 00 00       	mov    $0x16,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <get_name>:
SYSCALL(get_name)
 38c:	b8 17 00 00 00       	mov    $0x17,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <get_max_proc>:
SYSCALL(get_max_proc)
 394:	b8 18 00 00 00       	mov    $0x18,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <get_max_mem>:
SYSCALL(get_max_mem)
 39c:	b8 19 00 00 00       	mov    $0x19,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <get_max_disk>:
SYSCALL(get_max_disk)
 3a4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <get_curr_proc>:
SYSCALL(get_curr_proc)
 3ac:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <get_curr_mem>:
SYSCALL(get_curr_mem)
 3b4:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <get_curr_disk>:
SYSCALL(get_curr_disk)
 3bc:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <set_name>:
SYSCALL(set_name)
 3c4:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <set_max_mem>:
SYSCALL(set_max_mem)
 3cc:	b8 1f 00 00 00       	mov    $0x1f,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <set_max_disk>:
SYSCALL(set_max_disk)
 3d4:	b8 20 00 00 00       	mov    $0x20,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <set_max_proc>:
SYSCALL(set_max_proc)
 3dc:	b8 21 00 00 00       	mov    $0x21,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <set_curr_mem>:
SYSCALL(set_curr_mem)
 3e4:	b8 22 00 00 00       	mov    $0x22,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <set_curr_disk>:
SYSCALL(set_curr_disk)
 3ec:	b8 23 00 00 00       	mov    $0x23,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <set_curr_proc>:
SYSCALL(set_curr_proc)
 3f4:	b8 24 00 00 00       	mov    $0x24,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <find>:
SYSCALL(find)
 3fc:	b8 25 00 00 00       	mov    $0x25,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <is_full>:
SYSCALL(is_full)
 404:	b8 26 00 00 00       	mov    $0x26,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <container_init>:
SYSCALL(container_init)
 40c:	b8 27 00 00 00       	mov    $0x27,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <cont_proc_set>:
SYSCALL(cont_proc_set)
 414:	b8 28 00 00 00       	mov    $0x28,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <ps>:
SYSCALL(ps)
 41c:	b8 29 00 00 00       	mov    $0x29,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 424:	b8 2a 00 00 00       	mov    $0x2a,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	83 ec 18             	sub    $0x18,%esp
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 438:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43f:	00 
 440:	8d 45 f4             	lea    -0xc(%ebp),%eax
 443:	89 44 24 04          	mov    %eax,0x4(%esp)
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	89 04 24             	mov    %eax,(%esp)
 44d:	e8 b2 fe ff ff       	call   304 <write>
}
 452:	c9                   	leave  
 453:	c3                   	ret    

00000454 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	56                   	push   %esi
 458:	53                   	push   %ebx
 459:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 45c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 463:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 467:	74 17                	je     480 <printint+0x2c>
 469:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 46d:	79 11                	jns    480 <printint+0x2c>
    neg = 1;
 46f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 476:	8b 45 0c             	mov    0xc(%ebp),%eax
 479:	f7 d8                	neg    %eax
 47b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47e:	eb 06                	jmp    486 <printint+0x32>
  } else {
    x = xx;
 480:	8b 45 0c             	mov    0xc(%ebp),%eax
 483:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 486:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 48d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 490:	8d 41 01             	lea    0x1(%ecx),%eax
 493:	89 45 f4             	mov    %eax,-0xc(%ebp)
 496:	8b 5d 10             	mov    0x10(%ebp),%ebx
 499:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49c:	ba 00 00 00 00       	mov    $0x0,%edx
 4a1:	f7 f3                	div    %ebx
 4a3:	89 d0                	mov    %edx,%eax
 4a5:	8a 80 48 0b 00 00    	mov    0xb48(%eax),%al
 4ab:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4af:	8b 75 10             	mov    0x10(%ebp),%esi
 4b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ba:	f7 f6                	div    %esi
 4bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c3:	75 c8                	jne    48d <printint+0x39>
  if(neg)
 4c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c9:	74 10                	je     4db <printint+0x87>
    buf[i++] = '-';
 4cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ce:	8d 50 01             	lea    0x1(%eax),%edx
 4d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4d9:	eb 1e                	jmp    4f9 <printint+0xa5>
 4db:	eb 1c                	jmp    4f9 <printint+0xa5>
    putc(fd, buf[i]);
 4dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e3:	01 d0                	add    %edx,%eax
 4e5:	8a 00                	mov    (%eax),%al
 4e7:	0f be c0             	movsbl %al,%eax
 4ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	89 04 24             	mov    %eax,(%esp)
 4f4:	e8 33 ff ff ff       	call   42c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f9:	ff 4d f4             	decl   -0xc(%ebp)
 4fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 500:	79 db                	jns    4dd <printint+0x89>
    putc(fd, buf[i]);
}
 502:	83 c4 30             	add    $0x30,%esp
 505:	5b                   	pop    %ebx
 506:	5e                   	pop    %esi
 507:	5d                   	pop    %ebp
 508:	c3                   	ret    

00000509 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 509:	55                   	push   %ebp
 50a:	89 e5                	mov    %esp,%ebp
 50c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 50f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 516:	8d 45 0c             	lea    0xc(%ebp),%eax
 519:	83 c0 04             	add    $0x4,%eax
 51c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 51f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 526:	e9 77 01 00 00       	jmp    6a2 <printf+0x199>
    c = fmt[i] & 0xff;
 52b:	8b 55 0c             	mov    0xc(%ebp),%edx
 52e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 531:	01 d0                	add    %edx,%eax
 533:	8a 00                	mov    (%eax),%al
 535:	0f be c0             	movsbl %al,%eax
 538:	25 ff 00 00 00       	and    $0xff,%eax
 53d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 540:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 544:	75 2c                	jne    572 <printf+0x69>
      if(c == '%'){
 546:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54a:	75 0c                	jne    558 <printf+0x4f>
        state = '%';
 54c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 553:	e9 47 01 00 00       	jmp    69f <printf+0x196>
      } else {
        putc(fd, c);
 558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55b:	0f be c0             	movsbl %al,%eax
 55e:	89 44 24 04          	mov    %eax,0x4(%esp)
 562:	8b 45 08             	mov    0x8(%ebp),%eax
 565:	89 04 24             	mov    %eax,(%esp)
 568:	e8 bf fe ff ff       	call   42c <putc>
 56d:	e9 2d 01 00 00       	jmp    69f <printf+0x196>
      }
    } else if(state == '%'){
 572:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 576:	0f 85 23 01 00 00    	jne    69f <printf+0x196>
      if(c == 'd'){
 57c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 580:	75 2d                	jne    5af <printf+0xa6>
        printint(fd, *ap, 10, 1);
 582:	8b 45 e8             	mov    -0x18(%ebp),%eax
 585:	8b 00                	mov    (%eax),%eax
 587:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 58e:	00 
 58f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 596:	00 
 597:	89 44 24 04          	mov    %eax,0x4(%esp)
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	89 04 24             	mov    %eax,(%esp)
 5a1:	e8 ae fe ff ff       	call   454 <printint>
        ap++;
 5a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5aa:	e9 e9 00 00 00       	jmp    698 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5af:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b3:	74 06                	je     5bb <printf+0xb2>
 5b5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b9:	75 2d                	jne    5e8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5be:	8b 00                	mov    (%eax),%eax
 5c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c7:	00 
 5c8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5cf:	00 
 5d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	89 04 24             	mov    %eax,(%esp)
 5da:	e8 75 fe ff ff       	call   454 <printint>
        ap++;
 5df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e3:	e9 b0 00 00 00       	jmp    698 <printf+0x18f>
      } else if(c == 's'){
 5e8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5ec:	75 42                	jne    630 <printf+0x127>
        s = (char*)*ap;
 5ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fe:	75 09                	jne    609 <printf+0x100>
          s = "(null)";
 600:	c7 45 f4 fc 08 00 00 	movl   $0x8fc,-0xc(%ebp)
        while(*s != 0){
 607:	eb 1c                	jmp    625 <printf+0x11c>
 609:	eb 1a                	jmp    625 <printf+0x11c>
          putc(fd, *s);
 60b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60e:	8a 00                	mov    (%eax),%al
 610:	0f be c0             	movsbl %al,%eax
 613:	89 44 24 04          	mov    %eax,0x4(%esp)
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 0a fe ff ff       	call   42c <putc>
          s++;
 622:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 625:	8b 45 f4             	mov    -0xc(%ebp),%eax
 628:	8a 00                	mov    (%eax),%al
 62a:	84 c0                	test   %al,%al
 62c:	75 dd                	jne    60b <printf+0x102>
 62e:	eb 68                	jmp    698 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 630:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 634:	75 1d                	jne    653 <printf+0x14a>
        putc(fd, *ap);
 636:	8b 45 e8             	mov    -0x18(%ebp),%eax
 639:	8b 00                	mov    (%eax),%eax
 63b:	0f be c0             	movsbl %al,%eax
 63e:	89 44 24 04          	mov    %eax,0x4(%esp)
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	89 04 24             	mov    %eax,(%esp)
 648:	e8 df fd ff ff       	call   42c <putc>
        ap++;
 64d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 651:	eb 45                	jmp    698 <printf+0x18f>
      } else if(c == '%'){
 653:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 657:	75 17                	jne    670 <printf+0x167>
        putc(fd, c);
 659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65c:	0f be c0             	movsbl %al,%eax
 65f:	89 44 24 04          	mov    %eax,0x4(%esp)
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	89 04 24             	mov    %eax,(%esp)
 669:	e8 be fd ff ff       	call   42c <putc>
 66e:	eb 28                	jmp    698 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 670:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 677:	00 
 678:	8b 45 08             	mov    0x8(%ebp),%eax
 67b:	89 04 24             	mov    %eax,(%esp)
 67e:	e8 a9 fd ff ff       	call   42c <putc>
        putc(fd, c);
 683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 686:	0f be c0             	movsbl %al,%eax
 689:	89 44 24 04          	mov    %eax,0x4(%esp)
 68d:	8b 45 08             	mov    0x8(%ebp),%eax
 690:	89 04 24             	mov    %eax,(%esp)
 693:	e8 94 fd ff ff       	call   42c <putc>
      }
      state = 0;
 698:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 69f:	ff 45 f0             	incl   -0x10(%ebp)
 6a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a8:	01 d0                	add    %edx,%eax
 6aa:	8a 00                	mov    (%eax),%al
 6ac:	84 c0                	test   %al,%al
 6ae:	0f 85 77 fe ff ff    	jne    52b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b4:	c9                   	leave  
 6b5:	c3                   	ret    
 6b6:	90                   	nop
 6b7:	90                   	nop

000006b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b8:	55                   	push   %ebp
 6b9:	89 e5                	mov    %esp,%ebp
 6bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6be:	8b 45 08             	mov    0x8(%ebp),%eax
 6c1:	83 e8 08             	sub    $0x8,%eax
 6c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c7:	a1 64 0b 00 00       	mov    0xb64,%eax
 6cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cf:	eb 24                	jmp    6f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	8b 00                	mov    (%eax),%eax
 6d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d9:	77 12                	ja     6ed <free+0x35>
 6db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e1:	77 24                	ja     707 <free+0x4f>
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 00                	mov    (%eax),%eax
 6e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6eb:	77 1a                	ja     707 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fb:	76 d4                	jbe    6d1 <free+0x19>
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 705:	76 ca                	jbe    6d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 707:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70a:	8b 40 04             	mov    0x4(%eax),%eax
 70d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 714:	8b 45 f8             	mov    -0x8(%ebp),%eax
 717:	01 c2                	add    %eax,%edx
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	39 c2                	cmp    %eax,%edx
 720:	75 24                	jne    746 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	8b 50 04             	mov    0x4(%eax),%edx
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 00                	mov    (%eax),%eax
 72d:	8b 40 04             	mov    0x4(%eax),%eax
 730:	01 c2                	add    %eax,%edx
 732:	8b 45 f8             	mov    -0x8(%ebp),%eax
 735:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73b:	8b 00                	mov    (%eax),%eax
 73d:	8b 10                	mov    (%eax),%edx
 73f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 742:	89 10                	mov    %edx,(%eax)
 744:	eb 0a                	jmp    750 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	8b 10                	mov    (%eax),%edx
 74b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 750:	8b 45 fc             	mov    -0x4(%ebp),%eax
 753:	8b 40 04             	mov    0x4(%eax),%eax
 756:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	01 d0                	add    %edx,%eax
 762:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 765:	75 20                	jne    787 <free+0xcf>
    p->s.size += bp->s.size;
 767:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76a:	8b 50 04             	mov    0x4(%eax),%edx
 76d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	01 c2                	add    %eax,%edx
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	8b 10                	mov    (%eax),%edx
 780:	8b 45 fc             	mov    -0x4(%ebp),%eax
 783:	89 10                	mov    %edx,(%eax)
 785:	eb 08                	jmp    78f <free+0xd7>
  } else
    p->s.ptr = bp;
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 78d:	89 10                	mov    %edx,(%eax)
  freep = p;
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	a3 64 0b 00 00       	mov    %eax,0xb64
}
 797:	c9                   	leave  
 798:	c3                   	ret    

00000799 <morecore>:

static Header*
morecore(uint nu)
{
 799:	55                   	push   %ebp
 79a:	89 e5                	mov    %esp,%ebp
 79c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 79f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a6:	77 07                	ja     7af <morecore+0x16>
    nu = 4096;
 7a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
 7b2:	c1 e0 03             	shl    $0x3,%eax
 7b5:	89 04 24             	mov    %eax,(%esp)
 7b8:	e8 af fb ff ff       	call   36c <sbrk>
 7bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c4:	75 07                	jne    7cd <morecore+0x34>
    return 0;
 7c6:	b8 00 00 00 00       	mov    $0x0,%eax
 7cb:	eb 22                	jmp    7ef <morecore+0x56>
  hp = (Header*)p;
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d6:	8b 55 08             	mov    0x8(%ebp),%edx
 7d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7df:	83 c0 08             	add    $0x8,%eax
 7e2:	89 04 24             	mov    %eax,(%esp)
 7e5:	e8 ce fe ff ff       	call   6b8 <free>
  return freep;
 7ea:	a1 64 0b 00 00       	mov    0xb64,%eax
}
 7ef:	c9                   	leave  
 7f0:	c3                   	ret    

000007f1 <malloc>:

void*
malloc(uint nbytes)
{
 7f1:	55                   	push   %ebp
 7f2:	89 e5                	mov    %esp,%ebp
 7f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f7:	8b 45 08             	mov    0x8(%ebp),%eax
 7fa:	83 c0 07             	add    $0x7,%eax
 7fd:	c1 e8 03             	shr    $0x3,%eax
 800:	40                   	inc    %eax
 801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 804:	a1 64 0b 00 00       	mov    0xb64,%eax
 809:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 810:	75 23                	jne    835 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 812:	c7 45 f0 5c 0b 00 00 	movl   $0xb5c,-0x10(%ebp)
 819:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81c:	a3 64 0b 00 00       	mov    %eax,0xb64
 821:	a1 64 0b 00 00       	mov    0xb64,%eax
 826:	a3 5c 0b 00 00       	mov    %eax,0xb5c
    base.s.size = 0;
 82b:	c7 05 60 0b 00 00 00 	movl   $0x0,0xb60
 832:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 846:	72 4d                	jb     895 <malloc+0xa4>
      if(p->s.size == nunits)
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	8b 40 04             	mov    0x4(%eax),%eax
 84e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 851:	75 0c                	jne    85f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8b 10                	mov    (%eax),%edx
 858:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85b:	89 10                	mov    %edx,(%eax)
 85d:	eb 26                	jmp    885 <malloc+0x94>
      else {
        p->s.size -= nunits;
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 40 04             	mov    0x4(%eax),%eax
 865:	2b 45 ec             	sub    -0x14(%ebp),%eax
 868:	89 c2                	mov    %eax,%edx
 86a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 870:	8b 45 f4             	mov    -0xc(%ebp),%eax
 873:	8b 40 04             	mov    0x4(%eax),%eax
 876:	c1 e0 03             	shl    $0x3,%eax
 879:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 882:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 885:	8b 45 f0             	mov    -0x10(%ebp),%eax
 888:	a3 64 0b 00 00       	mov    %eax,0xb64
      return (void*)(p + 1);
 88d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 890:	83 c0 08             	add    $0x8,%eax
 893:	eb 38                	jmp    8cd <malloc+0xdc>
    }
    if(p == freep)
 895:	a1 64 0b 00 00       	mov    0xb64,%eax
 89a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 89d:	75 1b                	jne    8ba <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 89f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a2:	89 04 24             	mov    %eax,(%esp)
 8a5:	e8 ef fe ff ff       	call   799 <morecore>
 8aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b1:	75 07                	jne    8ba <malloc+0xc9>
        return 0;
 8b3:	b8 00 00 00 00       	mov    $0x0,%eax
 8b8:	eb 13                	jmp    8cd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c3:	8b 00                	mov    (%eax),%eax
 8c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8c8:	e9 70 ff ff ff       	jmp    83d <malloc+0x4c>
}
 8cd:	c9                   	leave  
 8ce:	c3                   	ret    
