
_vctest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int fd, id;

  if (argc < 3) {
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(1, "usage: vctest <vc> <cmd> [<arg> ...]\n");
   f:	c7 44 24 04 3c 09 00 	movl   $0x93c,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 52 05 00 00       	call   575 <printf>
    exit();
  23:	e8 28 03 00 00       	call   350 <exit>
  }

  fd = open(argv[1], O_RDWR);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  37:	00 
  38:	89 04 24             	mov    %eax,(%esp)
  3b:	e8 50 03 00 00       	call   390 <open>
  40:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  printf(1, "fd = %d\n", fd);
  44:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  48:	89 44 24 08          	mov    %eax,0x8(%esp)
  4c:	c7 44 24 04 62 09 00 	movl   $0x962,0x4(%esp)
  53:	00 
  54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5b:	e8 15 05 00 00       	call   575 <printf>

  /* fork a child and exec argv[1] */
  id = fork();
  60:	e8 e3 02 00 00       	call   348 <fork>
  65:	89 44 24 18          	mov    %eax,0x18(%esp)

  if (id == 0){
  69:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  6e:	75 67                	jne    d7 <main+0xd7>
    close(0);
  70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  77:	e8 fc 02 00 00       	call   378 <close>
    close(1);
  7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  83:	e8 f0 02 00 00       	call   378 <close>
    close(2);
  88:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8f:	e8 e4 02 00 00       	call   378 <close>
    dup(fd);
  94:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  98:	89 04 24             	mov    %eax,(%esp)
  9b:	e8 28 03 00 00       	call   3c8 <dup>
    dup(fd);
  a0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  a4:	89 04 24             	mov    %eax,(%esp)
  a7:	e8 1c 03 00 00       	call   3c8 <dup>
    dup(fd);
  ac:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  b0:	89 04 24             	mov    %eax,(%esp)
  b3:	e8 10 03 00 00       	call   3c8 <dup>
    exec(argv[2], &argv[2]);
  b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  bb:	8d 50 08             	lea    0x8(%eax),%edx
  be:	8b 45 0c             	mov    0xc(%ebp),%eax
  c1:	83 c0 08             	add    $0x8,%eax
  c4:	8b 00                	mov    (%eax),%eax
  c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  ca:	89 04 24             	mov    %eax,(%esp)
  cd:	e8 b6 02 00 00       	call   388 <exec>
    exit();
  d2:	e8 79 02 00 00       	call   350 <exit>
  }

  printf(1, "%s started on vc0\n", argv[1]);
  d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  da:	83 c0 04             	add    $0x4,%eax
  dd:	8b 00                	mov    (%eax),%eax
  df:	89 44 24 08          	mov    %eax,0x8(%esp)
  e3:	c7 44 24 04 6b 09 00 	movl   $0x96b,0x4(%esp)
  ea:	00 
  eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f2:	e8 7e 04 00 00       	call   575 <printf>

  exit();
  f7:	e8 54 02 00 00       	call   350 <exit>

000000fc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	57                   	push   %edi
 100:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 101:	8b 4d 08             	mov    0x8(%ebp),%ecx
 104:	8b 55 10             	mov    0x10(%ebp),%edx
 107:	8b 45 0c             	mov    0xc(%ebp),%eax
 10a:	89 cb                	mov    %ecx,%ebx
 10c:	89 df                	mov    %ebx,%edi
 10e:	89 d1                	mov    %edx,%ecx
 110:	fc                   	cld    
 111:	f3 aa                	rep stos %al,%es:(%edi)
 113:	89 ca                	mov    %ecx,%edx
 115:	89 fb                	mov    %edi,%ebx
 117:	89 5d 08             	mov    %ebx,0x8(%ebp)
 11a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 11d:	5b                   	pop    %ebx
 11e:	5f                   	pop    %edi
 11f:	5d                   	pop    %ebp
 120:	c3                   	ret    

00000121 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 121:	55                   	push   %ebp
 122:	89 e5                	mov    %esp,%ebp
 124:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 127:	8b 45 08             	mov    0x8(%ebp),%eax
 12a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 12d:	90                   	nop
 12e:	8b 45 08             	mov    0x8(%ebp),%eax
 131:	8d 50 01             	lea    0x1(%eax),%edx
 134:	89 55 08             	mov    %edx,0x8(%ebp)
 137:	8b 55 0c             	mov    0xc(%ebp),%edx
 13a:	8d 4a 01             	lea    0x1(%edx),%ecx
 13d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 140:	8a 12                	mov    (%edx),%dl
 142:	88 10                	mov    %dl,(%eax)
 144:	8a 00                	mov    (%eax),%al
 146:	84 c0                	test   %al,%al
 148:	75 e4                	jne    12e <strcpy+0xd>
    ;
  return os;
 14a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14d:	c9                   	leave  
 14e:	c3                   	ret    

0000014f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14f:	55                   	push   %ebp
 150:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 152:	eb 06                	jmp    15a <strcmp+0xb>
    p++, q++;
 154:	ff 45 08             	incl   0x8(%ebp)
 157:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 15a:	8b 45 08             	mov    0x8(%ebp),%eax
 15d:	8a 00                	mov    (%eax),%al
 15f:	84 c0                	test   %al,%al
 161:	74 0e                	je     171 <strcmp+0x22>
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	8a 10                	mov    (%eax),%dl
 168:	8b 45 0c             	mov    0xc(%ebp),%eax
 16b:	8a 00                	mov    (%eax),%al
 16d:	38 c2                	cmp    %al,%dl
 16f:	74 e3                	je     154 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	8a 00                	mov    (%eax),%al
 176:	0f b6 d0             	movzbl %al,%edx
 179:	8b 45 0c             	mov    0xc(%ebp),%eax
 17c:	8a 00                	mov    (%eax),%al
 17e:	0f b6 c0             	movzbl %al,%eax
 181:	29 c2                	sub    %eax,%edx
 183:	89 d0                	mov    %edx,%eax
}
 185:	5d                   	pop    %ebp
 186:	c3                   	ret    

00000187 <strlen>:

uint
strlen(char *s)
{
 187:	55                   	push   %ebp
 188:	89 e5                	mov    %esp,%ebp
 18a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 194:	eb 03                	jmp    199 <strlen+0x12>
 196:	ff 45 fc             	incl   -0x4(%ebp)
 199:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	01 d0                	add    %edx,%eax
 1a1:	8a 00                	mov    (%eax),%al
 1a3:	84 c0                	test   %al,%al
 1a5:	75 ef                	jne    196 <strlen+0xf>
    ;
  return n;
 1a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1b2:	8b 45 10             	mov    0x10(%ebp),%eax
 1b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	89 04 24             	mov    %eax,(%esp)
 1c6:	e8 31 ff ff ff       	call   fc <stosb>
  return dst;
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ce:	c9                   	leave  
 1cf:	c3                   	ret    

000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	83 ec 04             	sub    $0x4,%esp
 1d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1dc:	eb 12                	jmp    1f0 <strchr+0x20>
    if(*s == c)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	8a 00                	mov    (%eax),%al
 1e3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1e6:	75 05                	jne    1ed <strchr+0x1d>
      return (char*)s;
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
 1eb:	eb 11                	jmp    1fe <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ed:	ff 45 08             	incl   0x8(%ebp)
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	8a 00                	mov    (%eax),%al
 1f5:	84 c0                	test   %al,%al
 1f7:	75 e5                	jne    1de <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1fe:	c9                   	leave  
 1ff:	c3                   	ret    

00000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 206:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 20d:	eb 49                	jmp    258 <gets+0x58>
    cc = read(0, &c, 1);
 20f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 216:	00 
 217:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21a:	89 44 24 04          	mov    %eax,0x4(%esp)
 21e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 225:	e8 3e 01 00 00       	call   368 <read>
 22a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 22d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 231:	7f 02                	jg     235 <gets+0x35>
      break;
 233:	eb 2c                	jmp    261 <gets+0x61>
    buf[i++] = c;
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	8d 50 01             	lea    0x1(%eax),%edx
 23b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 23e:	89 c2                	mov    %eax,%edx
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	01 c2                	add    %eax,%edx
 245:	8a 45 ef             	mov    -0x11(%ebp),%al
 248:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 24a:	8a 45 ef             	mov    -0x11(%ebp),%al
 24d:	3c 0a                	cmp    $0xa,%al
 24f:	74 10                	je     261 <gets+0x61>
 251:	8a 45 ef             	mov    -0x11(%ebp),%al
 254:	3c 0d                	cmp    $0xd,%al
 256:	74 09                	je     261 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 258:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25b:	40                   	inc    %eax
 25c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 25f:	7c ae                	jl     20f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 261:	8b 55 f4             	mov    -0xc(%ebp),%edx
 264:	8b 45 08             	mov    0x8(%ebp),%eax
 267:	01 d0                	add    %edx,%eax
 269:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26f:	c9                   	leave  
 270:	c3                   	ret    

00000271 <stat>:

int
stat(char *n, struct stat *st)
{
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 277:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 27e:	00 
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	89 04 24             	mov    %eax,(%esp)
 285:	e8 06 01 00 00       	call   390 <open>
 28a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 28d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 291:	79 07                	jns    29a <stat+0x29>
    return -1;
 293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 298:	eb 23                	jmp    2bd <stat+0x4c>
  r = fstat(fd, st);
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a4:	89 04 24             	mov    %eax,(%esp)
 2a7:	e8 fc 00 00 00       	call   3a8 <fstat>
 2ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b2:	89 04 24             	mov    %eax,(%esp)
 2b5:	e8 be 00 00 00       	call   378 <close>
  return r;
 2ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2bd:	c9                   	leave  
 2be:	c3                   	ret    

000002bf <atoi>:

int
atoi(const char *s)
{
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2cc:	eb 24                	jmp    2f2 <atoi+0x33>
    n = n*10 + *s++ - '0';
 2ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d1:	89 d0                	mov    %edx,%eax
 2d3:	c1 e0 02             	shl    $0x2,%eax
 2d6:	01 d0                	add    %edx,%eax
 2d8:	01 c0                	add    %eax,%eax
 2da:	89 c1                	mov    %eax,%ecx
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	8d 50 01             	lea    0x1(%eax),%edx
 2e2:	89 55 08             	mov    %edx,0x8(%ebp)
 2e5:	8a 00                	mov    (%eax),%al
 2e7:	0f be c0             	movsbl %al,%eax
 2ea:	01 c8                	add    %ecx,%eax
 2ec:	83 e8 30             	sub    $0x30,%eax
 2ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f2:	8b 45 08             	mov    0x8(%ebp),%eax
 2f5:	8a 00                	mov    (%eax),%al
 2f7:	3c 2f                	cmp    $0x2f,%al
 2f9:	7e 09                	jle    304 <atoi+0x45>
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	8a 00                	mov    (%eax),%al
 300:	3c 39                	cmp    $0x39,%al
 302:	7e ca                	jle    2ce <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 304:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 307:	c9                   	leave  
 308:	c3                   	ret    

00000309 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 309:	55                   	push   %ebp
 30a:	89 e5                	mov    %esp,%ebp
 30c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 315:	8b 45 0c             	mov    0xc(%ebp),%eax
 318:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 31b:	eb 16                	jmp    333 <memmove+0x2a>
    *dst++ = *src++;
 31d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 320:	8d 50 01             	lea    0x1(%eax),%edx
 323:	89 55 fc             	mov    %edx,-0x4(%ebp)
 326:	8b 55 f8             	mov    -0x8(%ebp),%edx
 329:	8d 4a 01             	lea    0x1(%edx),%ecx
 32c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 32f:	8a 12                	mov    (%edx),%dl
 331:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 333:	8b 45 10             	mov    0x10(%ebp),%eax
 336:	8d 50 ff             	lea    -0x1(%eax),%edx
 339:	89 55 10             	mov    %edx,0x10(%ebp)
 33c:	85 c0                	test   %eax,%eax
 33e:	7f dd                	jg     31d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 340:	8b 45 08             	mov    0x8(%ebp),%eax
}
 343:	c9                   	leave  
 344:	c3                   	ret    
 345:	90                   	nop
 346:	90                   	nop
 347:	90                   	nop

00000348 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 348:	b8 01 00 00 00       	mov    $0x1,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <exit>:
SYSCALL(exit)
 350:	b8 02 00 00 00       	mov    $0x2,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <wait>:
SYSCALL(wait)
 358:	b8 03 00 00 00       	mov    $0x3,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <pipe>:
SYSCALL(pipe)
 360:	b8 04 00 00 00       	mov    $0x4,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <read>:
SYSCALL(read)
 368:	b8 05 00 00 00       	mov    $0x5,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <write>:
SYSCALL(write)
 370:	b8 10 00 00 00       	mov    $0x10,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <close>:
SYSCALL(close)
 378:	b8 15 00 00 00       	mov    $0x15,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <kill>:
SYSCALL(kill)
 380:	b8 06 00 00 00       	mov    $0x6,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <exec>:
SYSCALL(exec)
 388:	b8 07 00 00 00       	mov    $0x7,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <open>:
SYSCALL(open)
 390:	b8 0f 00 00 00       	mov    $0xf,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <mknod>:
SYSCALL(mknod)
 398:	b8 11 00 00 00       	mov    $0x11,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <unlink>:
SYSCALL(unlink)
 3a0:	b8 12 00 00 00       	mov    $0x12,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <fstat>:
SYSCALL(fstat)
 3a8:	b8 08 00 00 00       	mov    $0x8,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <link>:
SYSCALL(link)
 3b0:	b8 13 00 00 00       	mov    $0x13,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <mkdir>:
SYSCALL(mkdir)
 3b8:	b8 14 00 00 00       	mov    $0x14,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <chdir>:
SYSCALL(chdir)
 3c0:	b8 09 00 00 00       	mov    $0x9,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <dup>:
SYSCALL(dup)
 3c8:	b8 0a 00 00 00       	mov    $0xa,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <getpid>:
SYSCALL(getpid)
 3d0:	b8 0b 00 00 00       	mov    $0xb,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <sbrk>:
SYSCALL(sbrk)
 3d8:	b8 0c 00 00 00       	mov    $0xc,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <sleep>:
SYSCALL(sleep)
 3e0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <uptime>:
SYSCALL(uptime)
 3e8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <getticks>:
SYSCALL(getticks)
 3f0:	b8 16 00 00 00       	mov    $0x16,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <get_name>:
SYSCALL(get_name)
 3f8:	b8 17 00 00 00       	mov    $0x17,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <get_max_proc>:
SYSCALL(get_max_proc)
 400:	b8 18 00 00 00       	mov    $0x18,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <get_max_mem>:
SYSCALL(get_max_mem)
 408:	b8 19 00 00 00       	mov    $0x19,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <get_max_disk>:
SYSCALL(get_max_disk)
 410:	b8 1a 00 00 00       	mov    $0x1a,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <get_curr_proc>:
SYSCALL(get_curr_proc)
 418:	b8 1b 00 00 00       	mov    $0x1b,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <get_curr_mem>:
SYSCALL(get_curr_mem)
 420:	b8 1c 00 00 00       	mov    $0x1c,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <get_curr_disk>:
SYSCALL(get_curr_disk)
 428:	b8 1d 00 00 00       	mov    $0x1d,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <set_name>:
SYSCALL(set_name)
 430:	b8 1e 00 00 00       	mov    $0x1e,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <set_max_mem>:
SYSCALL(set_max_mem)
 438:	b8 1f 00 00 00       	mov    $0x1f,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <set_max_disk>:
SYSCALL(set_max_disk)
 440:	b8 20 00 00 00       	mov    $0x20,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <set_max_proc>:
SYSCALL(set_max_proc)
 448:	b8 21 00 00 00       	mov    $0x21,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <set_curr_mem>:
SYSCALL(set_curr_mem)
 450:	b8 22 00 00 00       	mov    $0x22,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <set_curr_disk>:
SYSCALL(set_curr_disk)
 458:	b8 23 00 00 00       	mov    $0x23,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <set_curr_proc>:
SYSCALL(set_curr_proc)
 460:	b8 24 00 00 00       	mov    $0x24,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <find>:
SYSCALL(find)
 468:	b8 25 00 00 00       	mov    $0x25,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <is_full>:
SYSCALL(is_full)
 470:	b8 26 00 00 00       	mov    $0x26,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <container_init>:
SYSCALL(container_init)
 478:	b8 27 00 00 00       	mov    $0x27,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <cont_proc_set>:
SYSCALL(cont_proc_set)
 480:	b8 28 00 00 00       	mov    $0x28,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <ps>:
SYSCALL(ps)
 488:	b8 29 00 00 00       	mov    $0x29,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 490:	b8 2a 00 00 00       	mov    $0x2a,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 498:	55                   	push   %ebp
 499:	89 e5                	mov    %esp,%ebp
 49b:	83 ec 18             	sub    $0x18,%esp
 49e:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4a4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4ab:	00 
 4ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4af:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b3:	8b 45 08             	mov    0x8(%ebp),%eax
 4b6:	89 04 24             	mov    %eax,(%esp)
 4b9:	e8 b2 fe ff ff       	call   370 <write>
}
 4be:	c9                   	leave  
 4bf:	c3                   	ret    

000004c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	56                   	push   %esi
 4c4:	53                   	push   %ebx
 4c5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4cf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4d3:	74 17                	je     4ec <printint+0x2c>
 4d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4d9:	79 11                	jns    4ec <printint+0x2c>
    neg = 1;
 4db:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	f7 d8                	neg    %eax
 4e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ea:	eb 06                	jmp    4f2 <printint+0x32>
  } else {
    x = xx;
 4ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4f9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4fc:	8d 41 01             	lea    0x1(%ecx),%eax
 4ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
 502:	8b 5d 10             	mov    0x10(%ebp),%ebx
 505:	8b 45 ec             	mov    -0x14(%ebp),%eax
 508:	ba 00 00 00 00       	mov    $0x0,%edx
 50d:	f7 f3                	div    %ebx
 50f:	89 d0                	mov    %edx,%eax
 511:	8a 80 cc 0b 00 00    	mov    0xbcc(%eax),%al
 517:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 51b:	8b 75 10             	mov    0x10(%ebp),%esi
 51e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 521:	ba 00 00 00 00       	mov    $0x0,%edx
 526:	f7 f6                	div    %esi
 528:	89 45 ec             	mov    %eax,-0x14(%ebp)
 52b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52f:	75 c8                	jne    4f9 <printint+0x39>
  if(neg)
 531:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 535:	74 10                	je     547 <printint+0x87>
    buf[i++] = '-';
 537:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53a:	8d 50 01             	lea    0x1(%eax),%edx
 53d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 540:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 545:	eb 1e                	jmp    565 <printint+0xa5>
 547:	eb 1c                	jmp    565 <printint+0xa5>
    putc(fd, buf[i]);
 549:	8d 55 dc             	lea    -0x24(%ebp),%edx
 54c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54f:	01 d0                	add    %edx,%eax
 551:	8a 00                	mov    (%eax),%al
 553:	0f be c0             	movsbl %al,%eax
 556:	89 44 24 04          	mov    %eax,0x4(%esp)
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	89 04 24             	mov    %eax,(%esp)
 560:	e8 33 ff ff ff       	call   498 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 565:	ff 4d f4             	decl   -0xc(%ebp)
 568:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 56c:	79 db                	jns    549 <printint+0x89>
    putc(fd, buf[i]);
}
 56e:	83 c4 30             	add    $0x30,%esp
 571:	5b                   	pop    %ebx
 572:	5e                   	pop    %esi
 573:	5d                   	pop    %ebp
 574:	c3                   	ret    

00000575 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 575:	55                   	push   %ebp
 576:	89 e5                	mov    %esp,%ebp
 578:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 57b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 582:	8d 45 0c             	lea    0xc(%ebp),%eax
 585:	83 c0 04             	add    $0x4,%eax
 588:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 58b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 592:	e9 77 01 00 00       	jmp    70e <printf+0x199>
    c = fmt[i] & 0xff;
 597:	8b 55 0c             	mov    0xc(%ebp),%edx
 59a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 59d:	01 d0                	add    %edx,%eax
 59f:	8a 00                	mov    (%eax),%al
 5a1:	0f be c0             	movsbl %al,%eax
 5a4:	25 ff 00 00 00       	and    $0xff,%eax
 5a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5b0:	75 2c                	jne    5de <printf+0x69>
      if(c == '%'){
 5b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b6:	75 0c                	jne    5c4 <printf+0x4f>
        state = '%';
 5b8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5bf:	e9 47 01 00 00       	jmp    70b <printf+0x196>
      } else {
        putc(fd, c);
 5c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c7:	0f be c0             	movsbl %al,%eax
 5ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ce:	8b 45 08             	mov    0x8(%ebp),%eax
 5d1:	89 04 24             	mov    %eax,(%esp)
 5d4:	e8 bf fe ff ff       	call   498 <putc>
 5d9:	e9 2d 01 00 00       	jmp    70b <printf+0x196>
      }
    } else if(state == '%'){
 5de:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5e2:	0f 85 23 01 00 00    	jne    70b <printf+0x196>
      if(c == 'd'){
 5e8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5ec:	75 2d                	jne    61b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 5ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5fa:	00 
 5fb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 602:	00 
 603:	89 44 24 04          	mov    %eax,0x4(%esp)
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	89 04 24             	mov    %eax,(%esp)
 60d:	e8 ae fe ff ff       	call   4c0 <printint>
        ap++;
 612:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 616:	e9 e9 00 00 00       	jmp    704 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 61b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 61f:	74 06                	je     627 <printf+0xb2>
 621:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 625:	75 2d                	jne    654 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 627:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62a:	8b 00                	mov    (%eax),%eax
 62c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 633:	00 
 634:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 63b:	00 
 63c:	89 44 24 04          	mov    %eax,0x4(%esp)
 640:	8b 45 08             	mov    0x8(%ebp),%eax
 643:	89 04 24             	mov    %eax,(%esp)
 646:	e8 75 fe ff ff       	call   4c0 <printint>
        ap++;
 64b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64f:	e9 b0 00 00 00       	jmp    704 <printf+0x18f>
      } else if(c == 's'){
 654:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 658:	75 42                	jne    69c <printf+0x127>
        s = (char*)*ap;
 65a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 662:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 666:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 66a:	75 09                	jne    675 <printf+0x100>
          s = "(null)";
 66c:	c7 45 f4 7e 09 00 00 	movl   $0x97e,-0xc(%ebp)
        while(*s != 0){
 673:	eb 1c                	jmp    691 <printf+0x11c>
 675:	eb 1a                	jmp    691 <printf+0x11c>
          putc(fd, *s);
 677:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67a:	8a 00                	mov    (%eax),%al
 67c:	0f be c0             	movsbl %al,%eax
 67f:	89 44 24 04          	mov    %eax,0x4(%esp)
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	89 04 24             	mov    %eax,(%esp)
 689:	e8 0a fe ff ff       	call   498 <putc>
          s++;
 68e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 691:	8b 45 f4             	mov    -0xc(%ebp),%eax
 694:	8a 00                	mov    (%eax),%al
 696:	84 c0                	test   %al,%al
 698:	75 dd                	jne    677 <printf+0x102>
 69a:	eb 68                	jmp    704 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 69c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6a0:	75 1d                	jne    6bf <printf+0x14a>
        putc(fd, *ap);
 6a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a5:	8b 00                	mov    (%eax),%eax
 6a7:	0f be c0             	movsbl %al,%eax
 6aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	89 04 24             	mov    %eax,(%esp)
 6b4:	e8 df fd ff ff       	call   498 <putc>
        ap++;
 6b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6bd:	eb 45                	jmp    704 <printf+0x18f>
      } else if(c == '%'){
 6bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6c3:	75 17                	jne    6dc <printf+0x167>
        putc(fd, c);
 6c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c8:	0f be c0             	movsbl %al,%eax
 6cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cf:	8b 45 08             	mov    0x8(%ebp),%eax
 6d2:	89 04 24             	mov    %eax,(%esp)
 6d5:	e8 be fd ff ff       	call   498 <putc>
 6da:	eb 28                	jmp    704 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6dc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6e3:	00 
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	89 04 24             	mov    %eax,(%esp)
 6ea:	e8 a9 fd ff ff       	call   498 <putc>
        putc(fd, c);
 6ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6f2:	0f be c0             	movsbl %al,%eax
 6f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f9:	8b 45 08             	mov    0x8(%ebp),%eax
 6fc:	89 04 24             	mov    %eax,(%esp)
 6ff:	e8 94 fd ff ff       	call   498 <putc>
      }
      state = 0;
 704:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 70b:	ff 45 f0             	incl   -0x10(%ebp)
 70e:	8b 55 0c             	mov    0xc(%ebp),%edx
 711:	8b 45 f0             	mov    -0x10(%ebp),%eax
 714:	01 d0                	add    %edx,%eax
 716:	8a 00                	mov    (%eax),%al
 718:	84 c0                	test   %al,%al
 71a:	0f 85 77 fe ff ff    	jne    597 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 720:	c9                   	leave  
 721:	c3                   	ret    
 722:	90                   	nop
 723:	90                   	nop

00000724 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 724:	55                   	push   %ebp
 725:	89 e5                	mov    %esp,%ebp
 727:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72a:	8b 45 08             	mov    0x8(%ebp),%eax
 72d:	83 e8 08             	sub    $0x8,%eax
 730:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 733:	a1 e8 0b 00 00       	mov    0xbe8,%eax
 738:	89 45 fc             	mov    %eax,-0x4(%ebp)
 73b:	eb 24                	jmp    761 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 745:	77 12                	ja     759 <free+0x35>
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 74d:	77 24                	ja     773 <free+0x4f>
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 00                	mov    (%eax),%eax
 754:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 757:	77 1a                	ja     773 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	8b 00                	mov    (%eax),%eax
 75e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 761:	8b 45 f8             	mov    -0x8(%ebp),%eax
 764:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 767:	76 d4                	jbe    73d <free+0x19>
 769:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76c:	8b 00                	mov    (%eax),%eax
 76e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 771:	76 ca                	jbe    73d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 773:	8b 45 f8             	mov    -0x8(%ebp),%eax
 776:	8b 40 04             	mov    0x4(%eax),%eax
 779:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 780:	8b 45 f8             	mov    -0x8(%ebp),%eax
 783:	01 c2                	add    %eax,%edx
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	8b 00                	mov    (%eax),%eax
 78a:	39 c2                	cmp    %eax,%edx
 78c:	75 24                	jne    7b2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 78e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 791:	8b 50 04             	mov    0x4(%eax),%edx
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	8b 00                	mov    (%eax),%eax
 799:	8b 40 04             	mov    0x4(%eax),%eax
 79c:	01 c2                	add    %eax,%edx
 79e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a7:	8b 00                	mov    (%eax),%eax
 7a9:	8b 10                	mov    (%eax),%edx
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	89 10                	mov    %edx,(%eax)
 7b0:	eb 0a                	jmp    7bc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b5:	8b 10                	mov    (%eax),%edx
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bf:	8b 40 04             	mov    0x4(%eax),%eax
 7c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	01 d0                	add    %edx,%eax
 7ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d1:	75 20                	jne    7f3 <free+0xcf>
    p->s.size += bp->s.size;
 7d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d6:	8b 50 04             	mov    0x4(%eax),%edx
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	8b 40 04             	mov    0x4(%eax),%eax
 7df:	01 c2                	add    %eax,%edx
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ea:	8b 10                	mov    (%eax),%edx
 7ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ef:	89 10                	mov    %edx,(%eax)
 7f1:	eb 08                	jmp    7fb <free+0xd7>
  } else
    p->s.ptr = bp;
 7f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7f9:	89 10                	mov    %edx,(%eax)
  freep = p;
 7fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fe:	a3 e8 0b 00 00       	mov    %eax,0xbe8
}
 803:	c9                   	leave  
 804:	c3                   	ret    

00000805 <morecore>:

static Header*
morecore(uint nu)
{
 805:	55                   	push   %ebp
 806:	89 e5                	mov    %esp,%ebp
 808:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 80b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 812:	77 07                	ja     81b <morecore+0x16>
    nu = 4096;
 814:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 81b:	8b 45 08             	mov    0x8(%ebp),%eax
 81e:	c1 e0 03             	shl    $0x3,%eax
 821:	89 04 24             	mov    %eax,(%esp)
 824:	e8 af fb ff ff       	call   3d8 <sbrk>
 829:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 82c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 830:	75 07                	jne    839 <morecore+0x34>
    return 0;
 832:	b8 00 00 00 00       	mov    $0x0,%eax
 837:	eb 22                	jmp    85b <morecore+0x56>
  hp = (Header*)p;
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 83f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 842:	8b 55 08             	mov    0x8(%ebp),%edx
 845:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 848:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84b:	83 c0 08             	add    $0x8,%eax
 84e:	89 04 24             	mov    %eax,(%esp)
 851:	e8 ce fe ff ff       	call   724 <free>
  return freep;
 856:	a1 e8 0b 00 00       	mov    0xbe8,%eax
}
 85b:	c9                   	leave  
 85c:	c3                   	ret    

0000085d <malloc>:

void*
malloc(uint nbytes)
{
 85d:	55                   	push   %ebp
 85e:	89 e5                	mov    %esp,%ebp
 860:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 863:	8b 45 08             	mov    0x8(%ebp),%eax
 866:	83 c0 07             	add    $0x7,%eax
 869:	c1 e8 03             	shr    $0x3,%eax
 86c:	40                   	inc    %eax
 86d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 870:	a1 e8 0b 00 00       	mov    0xbe8,%eax
 875:	89 45 f0             	mov    %eax,-0x10(%ebp)
 878:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 87c:	75 23                	jne    8a1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 87e:	c7 45 f0 e0 0b 00 00 	movl   $0xbe0,-0x10(%ebp)
 885:	8b 45 f0             	mov    -0x10(%ebp),%eax
 888:	a3 e8 0b 00 00       	mov    %eax,0xbe8
 88d:	a1 e8 0b 00 00       	mov    0xbe8,%eax
 892:	a3 e0 0b 00 00       	mov    %eax,0xbe0
    base.s.size = 0;
 897:	c7 05 e4 0b 00 00 00 	movl   $0x0,0xbe4
 89e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	8b 40 04             	mov    0x4(%eax),%eax
 8af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8b2:	72 4d                	jb     901 <malloc+0xa4>
      if(p->s.size == nunits)
 8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b7:	8b 40 04             	mov    0x4(%eax),%eax
 8ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8bd:	75 0c                	jne    8cb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	8b 10                	mov    (%eax),%edx
 8c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c7:	89 10                	mov    %edx,(%eax)
 8c9:	eb 26                	jmp    8f1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 8cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ce:	8b 40 04             	mov    0x4(%eax),%eax
 8d1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8d4:	89 c2                	mov    %eax,%edx
 8d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8df:	8b 40 04             	mov    0x4(%eax),%eax
 8e2:	c1 e0 03             	shl    $0x3,%eax
 8e5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8ee:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	a3 e8 0b 00 00       	mov    %eax,0xbe8
      return (void*)(p + 1);
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	83 c0 08             	add    $0x8,%eax
 8ff:	eb 38                	jmp    939 <malloc+0xdc>
    }
    if(p == freep)
 901:	a1 e8 0b 00 00       	mov    0xbe8,%eax
 906:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 909:	75 1b                	jne    926 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 90b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 90e:	89 04 24             	mov    %eax,(%esp)
 911:	e8 ef fe ff ff       	call   805 <morecore>
 916:	89 45 f4             	mov    %eax,-0xc(%ebp)
 919:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 91d:	75 07                	jne    926 <malloc+0xc9>
        return 0;
 91f:	b8 00 00 00 00       	mov    $0x0,%eax
 924:	eb 13                	jmp    939 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	89 45 f0             	mov    %eax,-0x10(%ebp)
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 934:	e9 70 ff ff ff       	jmp    8a9 <malloc+0x4c>
}
 939:	c9                   	leave  
 93a:	c3                   	ret    
