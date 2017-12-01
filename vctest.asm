
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
   f:	c7 44 24 04 5c 09 00 	movl   $0x95c,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 72 05 00 00       	call   595 <printf>
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
  4c:	c7 44 24 04 82 09 00 	movl   $0x982,0x4(%esp)
  53:	00 
  54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5b:	e8 35 05 00 00       	call   595 <printf>

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
  e3:	c7 44 24 04 8b 09 00 	movl   $0x98b,0x4(%esp)
  ea:	00 
  eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f2:	e8 9e 04 00 00       	call   595 <printf>

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

00000498 <set_root_inode>:
SYSCALL(set_root_inode)
 498:	b8 2b 00 00 00       	mov    $0x2b,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <cstop>:
SYSCALL(cstop)
 4a0:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <df>:
SYSCALL(df)
 4a8:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <max_containers>:
SYSCALL(max_containers)
 4b0:	b8 2e 00 00 00       	mov    $0x2e,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
 4bb:	83 ec 18             	sub    $0x18,%esp
 4be:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4cb:	00 
 4cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	89 04 24             	mov    %eax,(%esp)
 4d9:	e8 92 fe ff ff       	call   370 <write>
}
 4de:	c9                   	leave  
 4df:	c3                   	ret    

000004e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e0:	55                   	push   %ebp
 4e1:	89 e5                	mov    %esp,%ebp
 4e3:	56                   	push   %esi
 4e4:	53                   	push   %ebx
 4e5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4f3:	74 17                	je     50c <printint+0x2c>
 4f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4f9:	79 11                	jns    50c <printint+0x2c>
    neg = 1;
 4fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 502:	8b 45 0c             	mov    0xc(%ebp),%eax
 505:	f7 d8                	neg    %eax
 507:	89 45 ec             	mov    %eax,-0x14(%ebp)
 50a:	eb 06                	jmp    512 <printint+0x32>
  } else {
    x = xx;
 50c:	8b 45 0c             	mov    0xc(%ebp),%eax
 50f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 512:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 519:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 51c:	8d 41 01             	lea    0x1(%ecx),%eax
 51f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 522:	8b 5d 10             	mov    0x10(%ebp),%ebx
 525:	8b 45 ec             	mov    -0x14(%ebp),%eax
 528:	ba 00 00 00 00       	mov    $0x0,%edx
 52d:	f7 f3                	div    %ebx
 52f:	89 d0                	mov    %edx,%eax
 531:	8a 80 ec 0b 00 00    	mov    0xbec(%eax),%al
 537:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 53b:	8b 75 10             	mov    0x10(%ebp),%esi
 53e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 541:	ba 00 00 00 00       	mov    $0x0,%edx
 546:	f7 f6                	div    %esi
 548:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 54f:	75 c8                	jne    519 <printint+0x39>
  if(neg)
 551:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 555:	74 10                	je     567 <printint+0x87>
    buf[i++] = '-';
 557:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55a:	8d 50 01             	lea    0x1(%eax),%edx
 55d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 560:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 565:	eb 1e                	jmp    585 <printint+0xa5>
 567:	eb 1c                	jmp    585 <printint+0xa5>
    putc(fd, buf[i]);
 569:	8d 55 dc             	lea    -0x24(%ebp),%edx
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	01 d0                	add    %edx,%eax
 571:	8a 00                	mov    (%eax),%al
 573:	0f be c0             	movsbl %al,%eax
 576:	89 44 24 04          	mov    %eax,0x4(%esp)
 57a:	8b 45 08             	mov    0x8(%ebp),%eax
 57d:	89 04 24             	mov    %eax,(%esp)
 580:	e8 33 ff ff ff       	call   4b8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 585:	ff 4d f4             	decl   -0xc(%ebp)
 588:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58c:	79 db                	jns    569 <printint+0x89>
    putc(fd, buf[i]);
}
 58e:	83 c4 30             	add    $0x30,%esp
 591:	5b                   	pop    %ebx
 592:	5e                   	pop    %esi
 593:	5d                   	pop    %ebp
 594:	c3                   	ret    

00000595 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 595:	55                   	push   %ebp
 596:	89 e5                	mov    %esp,%ebp
 598:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 59b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5a2:	8d 45 0c             	lea    0xc(%ebp),%eax
 5a5:	83 c0 04             	add    $0x4,%eax
 5a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5b2:	e9 77 01 00 00       	jmp    72e <printf+0x199>
    c = fmt[i] & 0xff;
 5b7:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5bd:	01 d0                	add    %edx,%eax
 5bf:	8a 00                	mov    (%eax),%al
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	25 ff 00 00 00       	and    $0xff,%eax
 5c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d0:	75 2c                	jne    5fe <printf+0x69>
      if(c == '%'){
 5d2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d6:	75 0c                	jne    5e4 <printf+0x4f>
        state = '%';
 5d8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5df:	e9 47 01 00 00       	jmp    72b <printf+0x196>
      } else {
        putc(fd, c);
 5e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e7:	0f be c0             	movsbl %al,%eax
 5ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ee:	8b 45 08             	mov    0x8(%ebp),%eax
 5f1:	89 04 24             	mov    %eax,(%esp)
 5f4:	e8 bf fe ff ff       	call   4b8 <putc>
 5f9:	e9 2d 01 00 00       	jmp    72b <printf+0x196>
      }
    } else if(state == '%'){
 5fe:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 602:	0f 85 23 01 00 00    	jne    72b <printf+0x196>
      if(c == 'd'){
 608:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 60c:	75 2d                	jne    63b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 60e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 611:	8b 00                	mov    (%eax),%eax
 613:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 61a:	00 
 61b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 622:	00 
 623:	89 44 24 04          	mov    %eax,0x4(%esp)
 627:	8b 45 08             	mov    0x8(%ebp),%eax
 62a:	89 04 24             	mov    %eax,(%esp)
 62d:	e8 ae fe ff ff       	call   4e0 <printint>
        ap++;
 632:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 636:	e9 e9 00 00 00       	jmp    724 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 63b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 63f:	74 06                	je     647 <printf+0xb2>
 641:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 645:	75 2d                	jne    674 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 647:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64a:	8b 00                	mov    (%eax),%eax
 64c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 653:	00 
 654:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 65b:	00 
 65c:	89 44 24 04          	mov    %eax,0x4(%esp)
 660:	8b 45 08             	mov    0x8(%ebp),%eax
 663:	89 04 24             	mov    %eax,(%esp)
 666:	e8 75 fe ff ff       	call   4e0 <printint>
        ap++;
 66b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66f:	e9 b0 00 00 00       	jmp    724 <printf+0x18f>
      } else if(c == 's'){
 674:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 678:	75 42                	jne    6bc <printf+0x127>
        s = (char*)*ap;
 67a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 682:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68a:	75 09                	jne    695 <printf+0x100>
          s = "(null)";
 68c:	c7 45 f4 9e 09 00 00 	movl   $0x99e,-0xc(%ebp)
        while(*s != 0){
 693:	eb 1c                	jmp    6b1 <printf+0x11c>
 695:	eb 1a                	jmp    6b1 <printf+0x11c>
          putc(fd, *s);
 697:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69a:	8a 00                	mov    (%eax),%al
 69c:	0f be c0             	movsbl %al,%eax
 69f:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a3:	8b 45 08             	mov    0x8(%ebp),%eax
 6a6:	89 04 24             	mov    %eax,(%esp)
 6a9:	e8 0a fe ff ff       	call   4b8 <putc>
          s++;
 6ae:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b4:	8a 00                	mov    (%eax),%al
 6b6:	84 c0                	test   %al,%al
 6b8:	75 dd                	jne    697 <printf+0x102>
 6ba:	eb 68                	jmp    724 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6bc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6c0:	75 1d                	jne    6df <printf+0x14a>
        putc(fd, *ap);
 6c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c5:	8b 00                	mov    (%eax),%eax
 6c7:	0f be c0             	movsbl %al,%eax
 6ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ce:	8b 45 08             	mov    0x8(%ebp),%eax
 6d1:	89 04 24             	mov    %eax,(%esp)
 6d4:	e8 df fd ff ff       	call   4b8 <putc>
        ap++;
 6d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6dd:	eb 45                	jmp    724 <printf+0x18f>
      } else if(c == '%'){
 6df:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6e3:	75 17                	jne    6fc <printf+0x167>
        putc(fd, c);
 6e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e8:	0f be c0             	movsbl %al,%eax
 6eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	89 04 24             	mov    %eax,(%esp)
 6f5:	e8 be fd ff ff       	call   4b8 <putc>
 6fa:	eb 28                	jmp    724 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6fc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 703:	00 
 704:	8b 45 08             	mov    0x8(%ebp),%eax
 707:	89 04 24             	mov    %eax,(%esp)
 70a:	e8 a9 fd ff ff       	call   4b8 <putc>
        putc(fd, c);
 70f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 712:	0f be c0             	movsbl %al,%eax
 715:	89 44 24 04          	mov    %eax,0x4(%esp)
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	89 04 24             	mov    %eax,(%esp)
 71f:	e8 94 fd ff ff       	call   4b8 <putc>
      }
      state = 0;
 724:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 72b:	ff 45 f0             	incl   -0x10(%ebp)
 72e:	8b 55 0c             	mov    0xc(%ebp),%edx
 731:	8b 45 f0             	mov    -0x10(%ebp),%eax
 734:	01 d0                	add    %edx,%eax
 736:	8a 00                	mov    (%eax),%al
 738:	84 c0                	test   %al,%al
 73a:	0f 85 77 fe ff ff    	jne    5b7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 740:	c9                   	leave  
 741:	c3                   	ret    
 742:	90                   	nop
 743:	90                   	nop

00000744 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 744:	55                   	push   %ebp
 745:	89 e5                	mov    %esp,%ebp
 747:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	83 e8 08             	sub    $0x8,%eax
 750:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 753:	a1 08 0c 00 00       	mov    0xc08,%eax
 758:	89 45 fc             	mov    %eax,-0x4(%ebp)
 75b:	eb 24                	jmp    781 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 765:	77 12                	ja     779 <free+0x35>
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76d:	77 24                	ja     793 <free+0x4f>
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	8b 00                	mov    (%eax),%eax
 774:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 777:	77 1a                	ja     793 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 781:	8b 45 f8             	mov    -0x8(%ebp),%eax
 784:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 787:	76 d4                	jbe    75d <free+0x19>
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 00                	mov    (%eax),%eax
 78e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 791:	76 ca                	jbe    75d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 793:	8b 45 f8             	mov    -0x8(%ebp),%eax
 796:	8b 40 04             	mov    0x4(%eax),%eax
 799:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a3:	01 c2                	add    %eax,%edx
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	39 c2                	cmp    %eax,%edx
 7ac:	75 24                	jne    7d2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b1:	8b 50 04             	mov    0x4(%eax),%edx
 7b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b7:	8b 00                	mov    (%eax),%eax
 7b9:	8b 40 04             	mov    0x4(%eax),%eax
 7bc:	01 c2                	add    %eax,%edx
 7be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c7:	8b 00                	mov    (%eax),%eax
 7c9:	8b 10                	mov    (%eax),%edx
 7cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ce:	89 10                	mov    %edx,(%eax)
 7d0:	eb 0a                	jmp    7dc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d5:	8b 10                	mov    (%eax),%edx
 7d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7da:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7df:	8b 40 04             	mov    0x4(%eax),%eax
 7e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	01 d0                	add    %edx,%eax
 7ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7f1:	75 20                	jne    813 <free+0xcf>
    p->s.size += bp->s.size;
 7f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f6:	8b 50 04             	mov    0x4(%eax),%edx
 7f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fc:	8b 40 04             	mov    0x4(%eax),%eax
 7ff:	01 c2                	add    %eax,%edx
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	8b 10                	mov    (%eax),%edx
 80c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80f:	89 10                	mov    %edx,(%eax)
 811:	eb 08                	jmp    81b <free+0xd7>
  } else
    p->s.ptr = bp;
 813:	8b 45 fc             	mov    -0x4(%ebp),%eax
 816:	8b 55 f8             	mov    -0x8(%ebp),%edx
 819:	89 10                	mov    %edx,(%eax)
  freep = p;
 81b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81e:	a3 08 0c 00 00       	mov    %eax,0xc08
}
 823:	c9                   	leave  
 824:	c3                   	ret    

00000825 <morecore>:

static Header*
morecore(uint nu)
{
 825:	55                   	push   %ebp
 826:	89 e5                	mov    %esp,%ebp
 828:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 82b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 832:	77 07                	ja     83b <morecore+0x16>
    nu = 4096;
 834:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 83b:	8b 45 08             	mov    0x8(%ebp),%eax
 83e:	c1 e0 03             	shl    $0x3,%eax
 841:	89 04 24             	mov    %eax,(%esp)
 844:	e8 8f fb ff ff       	call   3d8 <sbrk>
 849:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 84c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 850:	75 07                	jne    859 <morecore+0x34>
    return 0;
 852:	b8 00 00 00 00       	mov    $0x0,%eax
 857:	eb 22                	jmp    87b <morecore+0x56>
  hp = (Header*)p;
 859:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 85f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 862:	8b 55 08             	mov    0x8(%ebp),%edx
 865:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 868:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86b:	83 c0 08             	add    $0x8,%eax
 86e:	89 04 24             	mov    %eax,(%esp)
 871:	e8 ce fe ff ff       	call   744 <free>
  return freep;
 876:	a1 08 0c 00 00       	mov    0xc08,%eax
}
 87b:	c9                   	leave  
 87c:	c3                   	ret    

0000087d <malloc>:

void*
malloc(uint nbytes)
{
 87d:	55                   	push   %ebp
 87e:	89 e5                	mov    %esp,%ebp
 880:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 883:	8b 45 08             	mov    0x8(%ebp),%eax
 886:	83 c0 07             	add    $0x7,%eax
 889:	c1 e8 03             	shr    $0x3,%eax
 88c:	40                   	inc    %eax
 88d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 890:	a1 08 0c 00 00       	mov    0xc08,%eax
 895:	89 45 f0             	mov    %eax,-0x10(%ebp)
 898:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 89c:	75 23                	jne    8c1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 89e:	c7 45 f0 00 0c 00 00 	movl   $0xc00,-0x10(%ebp)
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	a3 08 0c 00 00       	mov    %eax,0xc08
 8ad:	a1 08 0c 00 00       	mov    0xc08,%eax
 8b2:	a3 00 0c 00 00       	mov    %eax,0xc00
    base.s.size = 0;
 8b7:	c7 05 04 0c 00 00 00 	movl   $0x0,0xc04
 8be:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cc:	8b 40 04             	mov    0x4(%eax),%eax
 8cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8d2:	72 4d                	jb     921 <malloc+0xa4>
      if(p->s.size == nunits)
 8d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d7:	8b 40 04             	mov    0x4(%eax),%eax
 8da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8dd:	75 0c                	jne    8eb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 8df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e2:	8b 10                	mov    (%eax),%edx
 8e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e7:	89 10                	mov    %edx,(%eax)
 8e9:	eb 26                	jmp    911 <malloc+0x94>
      else {
        p->s.size -= nunits;
 8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8f4:	89 c2                	mov    %eax,%edx
 8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ff:	8b 40 04             	mov    0x4(%eax),%eax
 902:	c1 e0 03             	shl    $0x3,%eax
 905:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 908:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 90e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	a3 08 0c 00 00       	mov    %eax,0xc08
      return (void*)(p + 1);
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	83 c0 08             	add    $0x8,%eax
 91f:	eb 38                	jmp    959 <malloc+0xdc>
    }
    if(p == freep)
 921:	a1 08 0c 00 00       	mov    0xc08,%eax
 926:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 929:	75 1b                	jne    946 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 92b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 92e:	89 04 24             	mov    %eax,(%esp)
 931:	e8 ef fe ff ff       	call   825 <morecore>
 936:	89 45 f4             	mov    %eax,-0xc(%ebp)
 939:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 93d:	75 07                	jne    946 <malloc+0xc9>
        return 0;
 93f:	b8 00 00 00 00       	mov    $0x0,%eax
 944:	eb 13                	jmp    959 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	89 45 f0             	mov    %eax,-0x10(%ebp)
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 00                	mov    (%eax),%eax
 951:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 954:	e9 70 ff ff ff       	jmp    8c9 <malloc+0x4c>
}
 959:	c9                   	leave  
 95a:	c3                   	ret    
