
_mkdir:     file format elf32-i386


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
    printf(2, "Usage: mkdir files...\n");
   f:	c7 44 24 04 ef 08 00 	movl   $0x8ef,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 06 05 00 00       	call   529 <printf>
    exit();
  23:	e8 bc 02 00 00       	call   2e4 <exit>
  }

  for(i = 1; i < argc; i++){
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 4e                	jmp    80 <main+0x80>
    if(mkdir(argv[i]) < 0){
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 00 03 00 00       	call   34c <mkdir>
  4c:	85 c0                	test   %eax,%eax
  4e:	79 2c                	jns    7c <main+0x7c>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  50:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  5e:	01 d0                	add    %edx,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	89 44 24 08          	mov    %eax,0x8(%esp)
  66:	c7 44 24 04 06 09 00 	movl   $0x906,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  75:	e8 af 04 00 00       	call   529 <printf>
      break;
  7a:	eb 0d                	jmp    89 <main+0x89>
  if(argc < 2){
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  7c:	ff 44 24 1c          	incl   0x1c(%esp)
  80:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  84:	3b 45 08             	cmp    0x8(%ebp),%eax
  87:	7c a9                	jl     32 <main+0x32>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
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

0000042c <set_root_inode>:
SYSCALL(set_root_inode)
 42c:	b8 2b 00 00 00       	mov    $0x2b,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <cstop>:
SYSCALL(cstop)
 434:	b8 2c 00 00 00       	mov    $0x2c,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <df>:
SYSCALL(df)
 43c:	b8 2d 00 00 00       	mov    $0x2d,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <max_containers>:
SYSCALL(max_containers)
 444:	b8 2e 00 00 00       	mov    $0x2e,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 44c:	55                   	push   %ebp
 44d:	89 e5                	mov    %esp,%ebp
 44f:	83 ec 18             	sub    $0x18,%esp
 452:	8b 45 0c             	mov    0xc(%ebp),%eax
 455:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 45f:	00 
 460:	8d 45 f4             	lea    -0xc(%ebp),%eax
 463:	89 44 24 04          	mov    %eax,0x4(%esp)
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	89 04 24             	mov    %eax,(%esp)
 46d:	e8 92 fe ff ff       	call   304 <write>
}
 472:	c9                   	leave  
 473:	c3                   	ret    

00000474 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 474:	55                   	push   %ebp
 475:	89 e5                	mov    %esp,%ebp
 477:	56                   	push   %esi
 478:	53                   	push   %ebx
 479:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 47c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 483:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 487:	74 17                	je     4a0 <printint+0x2c>
 489:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 48d:	79 11                	jns    4a0 <printint+0x2c>
    neg = 1;
 48f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 496:	8b 45 0c             	mov    0xc(%ebp),%eax
 499:	f7 d8                	neg    %eax
 49b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 49e:	eb 06                	jmp    4a6 <printint+0x32>
  } else {
    x = xx;
 4a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4ad:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b0:	8d 41 01             	lea    0x1(%ecx),%eax
 4b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4bc:	ba 00 00 00 00       	mov    $0x0,%edx
 4c1:	f7 f3                	div    %ebx
 4c3:	89 d0                	mov    %edx,%eax
 4c5:	8a 80 70 0b 00 00    	mov    0xb70(%eax),%al
 4cb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4cf:	8b 75 10             	mov    0x10(%ebp),%esi
 4d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d5:	ba 00 00 00 00       	mov    $0x0,%edx
 4da:	f7 f6                	div    %esi
 4dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e3:	75 c8                	jne    4ad <printint+0x39>
  if(neg)
 4e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e9:	74 10                	je     4fb <printint+0x87>
    buf[i++] = '-';
 4eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ee:	8d 50 01             	lea    0x1(%eax),%edx
 4f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f9:	eb 1e                	jmp    519 <printint+0xa5>
 4fb:	eb 1c                	jmp    519 <printint+0xa5>
    putc(fd, buf[i]);
 4fd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 500:	8b 45 f4             	mov    -0xc(%ebp),%eax
 503:	01 d0                	add    %edx,%eax
 505:	8a 00                	mov    (%eax),%al
 507:	0f be c0             	movsbl %al,%eax
 50a:	89 44 24 04          	mov    %eax,0x4(%esp)
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	89 04 24             	mov    %eax,(%esp)
 514:	e8 33 ff ff ff       	call   44c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 519:	ff 4d f4             	decl   -0xc(%ebp)
 51c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 520:	79 db                	jns    4fd <printint+0x89>
    putc(fd, buf[i]);
}
 522:	83 c4 30             	add    $0x30,%esp
 525:	5b                   	pop    %ebx
 526:	5e                   	pop    %esi
 527:	5d                   	pop    %ebp
 528:	c3                   	ret    

00000529 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 529:	55                   	push   %ebp
 52a:	89 e5                	mov    %esp,%ebp
 52c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 52f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 536:	8d 45 0c             	lea    0xc(%ebp),%eax
 539:	83 c0 04             	add    $0x4,%eax
 53c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 53f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 546:	e9 77 01 00 00       	jmp    6c2 <printf+0x199>
    c = fmt[i] & 0xff;
 54b:	8b 55 0c             	mov    0xc(%ebp),%edx
 54e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 551:	01 d0                	add    %edx,%eax
 553:	8a 00                	mov    (%eax),%al
 555:	0f be c0             	movsbl %al,%eax
 558:	25 ff 00 00 00       	and    $0xff,%eax
 55d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 560:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 564:	75 2c                	jne    592 <printf+0x69>
      if(c == '%'){
 566:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56a:	75 0c                	jne    578 <printf+0x4f>
        state = '%';
 56c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 573:	e9 47 01 00 00       	jmp    6bf <printf+0x196>
      } else {
        putc(fd, c);
 578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57b:	0f be c0             	movsbl %al,%eax
 57e:	89 44 24 04          	mov    %eax,0x4(%esp)
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	89 04 24             	mov    %eax,(%esp)
 588:	e8 bf fe ff ff       	call   44c <putc>
 58d:	e9 2d 01 00 00       	jmp    6bf <printf+0x196>
      }
    } else if(state == '%'){
 592:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 596:	0f 85 23 01 00 00    	jne    6bf <printf+0x196>
      if(c == 'd'){
 59c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a0:	75 2d                	jne    5cf <printf+0xa6>
        printint(fd, *ap, 10, 1);
 5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a5:	8b 00                	mov    (%eax),%eax
 5a7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ae:	00 
 5af:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5b6:	00 
 5b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 ae fe ff ff       	call   474 <printint>
        ap++;
 5c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ca:	e9 e9 00 00 00       	jmp    6b8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5cf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d3:	74 06                	je     5db <printf+0xb2>
 5d5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d9:	75 2d                	jne    608 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5de:	8b 00                	mov    (%eax),%eax
 5e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5e7:	00 
 5e8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ef:	00 
 5f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	89 04 24             	mov    %eax,(%esp)
 5fa:	e8 75 fe ff ff       	call   474 <printint>
        ap++;
 5ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 603:	e9 b0 00 00 00       	jmp    6b8 <printf+0x18f>
      } else if(c == 's'){
 608:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 60c:	75 42                	jne    650 <printf+0x127>
        s = (char*)*ap;
 60e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 611:	8b 00                	mov    (%eax),%eax
 613:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 616:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 61a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61e:	75 09                	jne    629 <printf+0x100>
          s = "(null)";
 620:	c7 45 f4 22 09 00 00 	movl   $0x922,-0xc(%ebp)
        while(*s != 0){
 627:	eb 1c                	jmp    645 <printf+0x11c>
 629:	eb 1a                	jmp    645 <printf+0x11c>
          putc(fd, *s);
 62b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62e:	8a 00                	mov    (%eax),%al
 630:	0f be c0             	movsbl %al,%eax
 633:	89 44 24 04          	mov    %eax,0x4(%esp)
 637:	8b 45 08             	mov    0x8(%ebp),%eax
 63a:	89 04 24             	mov    %eax,(%esp)
 63d:	e8 0a fe ff ff       	call   44c <putc>
          s++;
 642:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 645:	8b 45 f4             	mov    -0xc(%ebp),%eax
 648:	8a 00                	mov    (%eax),%al
 64a:	84 c0                	test   %al,%al
 64c:	75 dd                	jne    62b <printf+0x102>
 64e:	eb 68                	jmp    6b8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 650:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 654:	75 1d                	jne    673 <printf+0x14a>
        putc(fd, *ap);
 656:	8b 45 e8             	mov    -0x18(%ebp),%eax
 659:	8b 00                	mov    (%eax),%eax
 65b:	0f be c0             	movsbl %al,%eax
 65e:	89 44 24 04          	mov    %eax,0x4(%esp)
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	89 04 24             	mov    %eax,(%esp)
 668:	e8 df fd ff ff       	call   44c <putc>
        ap++;
 66d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 671:	eb 45                	jmp    6b8 <printf+0x18f>
      } else if(c == '%'){
 673:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 677:	75 17                	jne    690 <printf+0x167>
        putc(fd, c);
 679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67c:	0f be c0             	movsbl %al,%eax
 67f:	89 44 24 04          	mov    %eax,0x4(%esp)
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	89 04 24             	mov    %eax,(%esp)
 689:	e8 be fd ff ff       	call   44c <putc>
 68e:	eb 28                	jmp    6b8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 690:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 697:	00 
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	89 04 24             	mov    %eax,(%esp)
 69e:	e8 a9 fd ff ff       	call   44c <putc>
        putc(fd, c);
 6a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a6:	0f be c0             	movsbl %al,%eax
 6a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ad:	8b 45 08             	mov    0x8(%ebp),%eax
 6b0:	89 04 24             	mov    %eax,(%esp)
 6b3:	e8 94 fd ff ff       	call   44c <putc>
      }
      state = 0;
 6b8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6bf:	ff 45 f0             	incl   -0x10(%ebp)
 6c2:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c8:	01 d0                	add    %edx,%eax
 6ca:	8a 00                	mov    (%eax),%al
 6cc:	84 c0                	test   %al,%al
 6ce:	0f 85 77 fe ff ff    	jne    54b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6d4:	c9                   	leave  
 6d5:	c3                   	ret    
 6d6:	90                   	nop
 6d7:	90                   	nop

000006d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d8:	55                   	push   %ebp
 6d9:	89 e5                	mov    %esp,%ebp
 6db:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6de:	8b 45 08             	mov    0x8(%ebp),%eax
 6e1:	83 e8 08             	sub    $0x8,%eax
 6e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e7:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 6ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ef:	eb 24                	jmp    715 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f9:	77 12                	ja     70d <free+0x35>
 6fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 701:	77 24                	ja     727 <free+0x4f>
 703:	8b 45 fc             	mov    -0x4(%ebp),%eax
 706:	8b 00                	mov    (%eax),%eax
 708:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70b:	77 1a                	ja     727 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	89 45 fc             	mov    %eax,-0x4(%ebp)
 715:	8b 45 f8             	mov    -0x8(%ebp),%eax
 718:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71b:	76 d4                	jbe    6f1 <free+0x19>
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 725:	76 ca                	jbe    6f1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	8b 40 04             	mov    0x4(%eax),%eax
 72d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 734:	8b 45 f8             	mov    -0x8(%ebp),%eax
 737:	01 c2                	add    %eax,%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	39 c2                	cmp    %eax,%edx
 740:	75 24                	jne    766 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	8b 50 04             	mov    0x4(%eax),%edx
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 00                	mov    (%eax),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	01 c2                	add    %eax,%edx
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	8b 10                	mov    (%eax),%edx
 75f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 762:	89 10                	mov    %edx,(%eax)
 764:	eb 0a                	jmp    770 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	8b 10                	mov    (%eax),%edx
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 40 04             	mov    0x4(%eax),%eax
 776:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 77d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 780:	01 d0                	add    %edx,%eax
 782:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 785:	75 20                	jne    7a7 <free+0xcf>
    p->s.size += bp->s.size;
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 50 04             	mov    0x4(%eax),%edx
 78d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 790:	8b 40 04             	mov    0x4(%eax),%eax
 793:	01 c2                	add    %eax,%edx
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 79b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79e:	8b 10                	mov    (%eax),%edx
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	89 10                	mov    %edx,(%eax)
 7a5:	eb 08                	jmp    7af <free+0xd7>
  } else
    p->s.ptr = bp;
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7ad:	89 10                	mov    %edx,(%eax)
  freep = p;
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	a3 8c 0b 00 00       	mov    %eax,0xb8c
}
 7b7:	c9                   	leave  
 7b8:	c3                   	ret    

000007b9 <morecore>:

static Header*
morecore(uint nu)
{
 7b9:	55                   	push   %ebp
 7ba:	89 e5                	mov    %esp,%ebp
 7bc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7bf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7c6:	77 07                	ja     7cf <morecore+0x16>
    nu = 4096;
 7c8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7cf:	8b 45 08             	mov    0x8(%ebp),%eax
 7d2:	c1 e0 03             	shl    $0x3,%eax
 7d5:	89 04 24             	mov    %eax,(%esp)
 7d8:	e8 8f fb ff ff       	call   36c <sbrk>
 7dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7e0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7e4:	75 07                	jne    7ed <morecore+0x34>
    return 0;
 7e6:	b8 00 00 00 00       	mov    $0x0,%eax
 7eb:	eb 22                	jmp    80f <morecore+0x56>
  hp = (Header*)p;
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f6:	8b 55 08             	mov    0x8(%ebp),%edx
 7f9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ff:	83 c0 08             	add    $0x8,%eax
 802:	89 04 24             	mov    %eax,(%esp)
 805:	e8 ce fe ff ff       	call   6d8 <free>
  return freep;
 80a:	a1 8c 0b 00 00       	mov    0xb8c,%eax
}
 80f:	c9                   	leave  
 810:	c3                   	ret    

00000811 <malloc>:

void*
malloc(uint nbytes)
{
 811:	55                   	push   %ebp
 812:	89 e5                	mov    %esp,%ebp
 814:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 817:	8b 45 08             	mov    0x8(%ebp),%eax
 81a:	83 c0 07             	add    $0x7,%eax
 81d:	c1 e8 03             	shr    $0x3,%eax
 820:	40                   	inc    %eax
 821:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 824:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 829:	89 45 f0             	mov    %eax,-0x10(%ebp)
 82c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 830:	75 23                	jne    855 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 832:	c7 45 f0 84 0b 00 00 	movl   $0xb84,-0x10(%ebp)
 839:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83c:	a3 8c 0b 00 00       	mov    %eax,0xb8c
 841:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 846:	a3 84 0b 00 00       	mov    %eax,0xb84
    base.s.size = 0;
 84b:	c7 05 88 0b 00 00 00 	movl   $0x0,0xb88
 852:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 855:	8b 45 f0             	mov    -0x10(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	8b 40 04             	mov    0x4(%eax),%eax
 863:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 866:	72 4d                	jb     8b5 <malloc+0xa4>
      if(p->s.size == nunits)
 868:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86b:	8b 40 04             	mov    0x4(%eax),%eax
 86e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 871:	75 0c                	jne    87f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	8b 10                	mov    (%eax),%edx
 878:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87b:	89 10                	mov    %edx,(%eax)
 87d:	eb 26                	jmp    8a5 <malloc+0x94>
      else {
        p->s.size -= nunits;
 87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 882:	8b 40 04             	mov    0x4(%eax),%eax
 885:	2b 45 ec             	sub    -0x14(%ebp),%eax
 888:	89 c2                	mov    %eax,%edx
 88a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 890:	8b 45 f4             	mov    -0xc(%ebp),%eax
 893:	8b 40 04             	mov    0x4(%eax),%eax
 896:	c1 e0 03             	shl    $0x3,%eax
 899:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8a2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	a3 8c 0b 00 00       	mov    %eax,0xb8c
      return (void*)(p + 1);
 8ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b0:	83 c0 08             	add    $0x8,%eax
 8b3:	eb 38                	jmp    8ed <malloc+0xdc>
    }
    if(p == freep)
 8b5:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 8ba:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8bd:	75 1b                	jne    8da <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 8bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c2:	89 04 24             	mov    %eax,(%esp)
 8c5:	e8 ef fe ff ff       	call   7b9 <morecore>
 8ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d1:	75 07                	jne    8da <malloc+0xc9>
        return 0;
 8d3:	b8 00 00 00 00       	mov    $0x0,%eax
 8d8:	eb 13                	jmp    8ed <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8e8:	e9 70 ff ff ff       	jmp    85d <malloc+0x4c>
}
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    
