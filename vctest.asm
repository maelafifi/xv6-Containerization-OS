
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
   f:	c7 44 24 04 78 0a 00 	movl   $0xa78,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 8e 06 00 00       	call   6b1 <printf>
    exit();
  23:	e8 0c 04 00 00       	call   434 <exit>
  }

  fd = open(argv[1], O_RDWR);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  37:	00 
  38:	89 04 24             	mov    %eax,(%esp)
  3b:	e8 34 04 00 00       	call   474 <open>
  40:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  printf(1, "fd = %d\n", fd);
  44:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  48:	89 44 24 08          	mov    %eax,0x8(%esp)
  4c:	c7 44 24 04 9e 0a 00 	movl   $0xa9e,0x4(%esp)
  53:	00 
  54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5b:	e8 51 06 00 00       	call   6b1 <printf>

  /* fork a child and exec argv[1] */
  id = fork();
  60:	e8 c7 03 00 00       	call   42c <fork>
  65:	89 44 24 18          	mov    %eax,0x18(%esp)

  if (id == 0){
  69:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  6e:	75 67                	jne    d7 <main+0xd7>
    close(0);
  70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  77:	e8 e0 03 00 00       	call   45c <close>
    close(1);
  7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  83:	e8 d4 03 00 00       	call   45c <close>
    close(2);
  88:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8f:	e8 c8 03 00 00       	call   45c <close>
    dup(fd);
  94:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  98:	89 04 24             	mov    %eax,(%esp)
  9b:	e8 0c 04 00 00       	call   4ac <dup>
    dup(fd);
  a0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  a4:	89 04 24             	mov    %eax,(%esp)
  a7:	e8 00 04 00 00       	call   4ac <dup>
    dup(fd);
  ac:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  b0:	89 04 24             	mov    %eax,(%esp)
  b3:	e8 f4 03 00 00       	call   4ac <dup>
    exec(argv[2], &argv[2]);
  b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  bb:	8d 50 08             	lea    0x8(%eax),%edx
  be:	8b 45 0c             	mov    0xc(%ebp),%eax
  c1:	83 c0 08             	add    $0x8,%eax
  c4:	8b 00                	mov    (%eax),%eax
  c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  ca:	89 04 24             	mov    %eax,(%esp)
  cd:	e8 9a 03 00 00       	call   46c <exec>
    exit();
  d2:	e8 5d 03 00 00       	call   434 <exit>
  }

  printf(1, "%s started on vc0\n", argv[1]);
  d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  da:	83 c0 04             	add    $0x4,%eax
  dd:	8b 00                	mov    (%eax),%eax
  df:	89 44 24 08          	mov    %eax,0x8(%esp)
  e3:	c7 44 24 04 a7 0a 00 	movl   $0xaa7,0x4(%esp)
  ea:	00 
  eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f2:	e8 ba 05 00 00       	call   6b1 <printf>

  exit();
  f7:	e8 38 03 00 00       	call   434 <exit>

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
 225:	e8 22 02 00 00       	call   44c <read>
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
 285:	e8 ea 01 00 00       	call   474 <open>
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
 2a7:	e8 e0 01 00 00       	call   48c <fstat>
 2ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b2:	89 04 24             	mov    %eax,(%esp)
 2b5:	e8 a2 01 00 00       	call   45c <close>
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

00000345 <itoa>:

int itoa(int value, char *sp, int radix)
{
 345:	55                   	push   %ebp
 346:	89 e5                	mov    %esp,%ebp
 348:	53                   	push   %ebx
 349:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 34c:	8d 45 d8             	lea    -0x28(%ebp),%eax
 34f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 352:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 356:	75 0d                	jne    365 <itoa+0x20>
 358:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 35c:	79 07                	jns    365 <itoa+0x20>
 35e:	b8 01 00 00 00       	mov    $0x1,%eax
 363:	eb 05                	jmp    36a <itoa+0x25>
 365:	b8 00 00 00 00       	mov    $0x0,%eax
 36a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 36d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 371:	74 0a                	je     37d <itoa+0x38>
      v = -value;
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	f7 d8                	neg    %eax
 378:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 37b:	eb 54                	jmp    3d1 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 383:	eb 4c                	jmp    3d1 <itoa+0x8c>
  {
    i = v % radix;
 385:	8b 4d 10             	mov    0x10(%ebp),%ecx
 388:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38b:	ba 00 00 00 00       	mov    $0x0,%edx
 390:	f7 f1                	div    %ecx
 392:	89 d0                	mov    %edx,%eax
 394:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 397:	8b 5d 10             	mov    0x10(%ebp),%ebx
 39a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39d:	ba 00 00 00 00       	mov    $0x0,%edx
 3a2:	f7 f3                	div    %ebx
 3a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 3a7:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 3ab:	7f 13                	jg     3c0 <itoa+0x7b>
      *tp++ = i+'0';
 3ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3b0:	8d 50 01             	lea    0x1(%eax),%edx
 3b3:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3b6:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3b9:	83 c2 30             	add    $0x30,%edx
 3bc:	88 10                	mov    %dl,(%eax)
 3be:	eb 11                	jmp    3d1 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 3c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3c3:	8d 50 01             	lea    0x1(%eax),%edx
 3c6:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3c9:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3cc:	83 c2 57             	add    $0x57,%edx
 3cf:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 3d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3d5:	75 ae                	jne    385 <itoa+0x40>
 3d7:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3da:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3dd:	74 a6                	je     385 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 3df:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3e5:	29 c2                	sub    %eax,%edx
 3e7:	89 d0                	mov    %edx,%eax
 3e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 3ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f0:	74 11                	je     403 <itoa+0xbe>
  {
    *sp++ = '-';
 3f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f5:	8d 50 01             	lea    0x1(%eax),%edx
 3f8:	89 55 0c             	mov    %edx,0xc(%ebp)
 3fb:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 3fe:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 401:	eb 15                	jmp    418 <itoa+0xd3>
 403:	eb 13                	jmp    418 <itoa+0xd3>
    *sp++ = *--tp;
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	8d 50 01             	lea    0x1(%eax),%edx
 40b:	89 55 0c             	mov    %edx,0xc(%ebp)
 40e:	ff 4d f8             	decl   -0x8(%ebp)
 411:	8b 55 f8             	mov    -0x8(%ebp),%edx
 414:	8a 12                	mov    (%edx),%dl
 416:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 418:	8d 45 d8             	lea    -0x28(%ebp),%eax
 41b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 41e:	77 e5                	ja     405 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 420:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 423:	83 c4 30             	add    $0x30,%esp
 426:	5b                   	pop    %ebx
 427:	5d                   	pop    %ebp
 428:	c3                   	ret    
 429:	90                   	nop
 42a:	90                   	nop
 42b:	90                   	nop

0000042c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 42c:	b8 01 00 00 00       	mov    $0x1,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <exit>:
SYSCALL(exit)
 434:	b8 02 00 00 00       	mov    $0x2,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <wait>:
SYSCALL(wait)
 43c:	b8 03 00 00 00       	mov    $0x3,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <pipe>:
SYSCALL(pipe)
 444:	b8 04 00 00 00       	mov    $0x4,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <read>:
SYSCALL(read)
 44c:	b8 05 00 00 00       	mov    $0x5,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <write>:
SYSCALL(write)
 454:	b8 10 00 00 00       	mov    $0x10,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <close>:
SYSCALL(close)
 45c:	b8 15 00 00 00       	mov    $0x15,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <kill>:
SYSCALL(kill)
 464:	b8 06 00 00 00       	mov    $0x6,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <exec>:
SYSCALL(exec)
 46c:	b8 07 00 00 00       	mov    $0x7,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <open>:
SYSCALL(open)
 474:	b8 0f 00 00 00       	mov    $0xf,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <mknod>:
SYSCALL(mknod)
 47c:	b8 11 00 00 00       	mov    $0x11,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <unlink>:
SYSCALL(unlink)
 484:	b8 12 00 00 00       	mov    $0x12,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <fstat>:
SYSCALL(fstat)
 48c:	b8 08 00 00 00       	mov    $0x8,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <link>:
SYSCALL(link)
 494:	b8 13 00 00 00       	mov    $0x13,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <mkdir>:
SYSCALL(mkdir)
 49c:	b8 14 00 00 00       	mov    $0x14,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <chdir>:
SYSCALL(chdir)
 4a4:	b8 09 00 00 00       	mov    $0x9,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <dup>:
SYSCALL(dup)
 4ac:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <getpid>:
SYSCALL(getpid)
 4b4:	b8 0b 00 00 00       	mov    $0xb,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <sbrk>:
SYSCALL(sbrk)
 4bc:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <sleep>:
SYSCALL(sleep)
 4c4:	b8 0d 00 00 00       	mov    $0xd,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <uptime>:
SYSCALL(uptime)
 4cc:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <getticks>:
SYSCALL(getticks)
 4d4:	b8 16 00 00 00       	mov    $0x16,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <get_name>:
SYSCALL(get_name)
 4dc:	b8 17 00 00 00       	mov    $0x17,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <get_max_proc>:
SYSCALL(get_max_proc)
 4e4:	b8 18 00 00 00       	mov    $0x18,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <get_max_mem>:
SYSCALL(get_max_mem)
 4ec:	b8 19 00 00 00       	mov    $0x19,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <get_max_disk>:
SYSCALL(get_max_disk)
 4f4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <get_curr_proc>:
SYSCALL(get_curr_proc)
 4fc:	b8 1b 00 00 00       	mov    $0x1b,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <get_curr_mem>:
SYSCALL(get_curr_mem)
 504:	b8 1c 00 00 00       	mov    $0x1c,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <get_curr_disk>:
SYSCALL(get_curr_disk)
 50c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <set_name>:
SYSCALL(set_name)
 514:	b8 1e 00 00 00       	mov    $0x1e,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <set_max_mem>:
SYSCALL(set_max_mem)
 51c:	b8 1f 00 00 00       	mov    $0x1f,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <set_max_disk>:
SYSCALL(set_max_disk)
 524:	b8 20 00 00 00       	mov    $0x20,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <set_max_proc>:
SYSCALL(set_max_proc)
 52c:	b8 21 00 00 00       	mov    $0x21,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <set_curr_mem>:
SYSCALL(set_curr_mem)
 534:	b8 22 00 00 00       	mov    $0x22,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <set_curr_disk>:
SYSCALL(set_curr_disk)
 53c:	b8 23 00 00 00       	mov    $0x23,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <set_curr_proc>:
SYSCALL(set_curr_proc)
 544:	b8 24 00 00 00       	mov    $0x24,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <find>:
SYSCALL(find)
 54c:	b8 25 00 00 00       	mov    $0x25,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <is_full>:
SYSCALL(is_full)
 554:	b8 26 00 00 00       	mov    $0x26,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <container_init>:
SYSCALL(container_init)
 55c:	b8 27 00 00 00       	mov    $0x27,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <cont_proc_set>:
SYSCALL(cont_proc_set)
 564:	b8 28 00 00 00       	mov    $0x28,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <ps>:
SYSCALL(ps)
 56c:	b8 29 00 00 00       	mov    $0x29,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 574:	b8 2a 00 00 00       	mov    $0x2a,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <set_root_inode>:
SYSCALL(set_root_inode)
 57c:	b8 2b 00 00 00       	mov    $0x2b,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <cstop>:
SYSCALL(cstop)
 584:	b8 2c 00 00 00       	mov    $0x2c,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <df>:
SYSCALL(df)
 58c:	b8 2d 00 00 00       	mov    $0x2d,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <max_containers>:
SYSCALL(max_containers)
 594:	b8 2e 00 00 00       	mov    $0x2e,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <container_reset>:
SYSCALL(container_reset)
 59c:	b8 2f 00 00 00       	mov    $0x2f,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <pause>:
SYSCALL(pause)
 5a4:	b8 30 00 00 00       	mov    $0x30,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <resume>:
SYSCALL(resume)
 5ac:	b8 31 00 00 00       	mov    $0x31,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <tmem>:
SYSCALL(tmem)
 5b4:	b8 32 00 00 00       	mov    $0x32,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <amem>:
SYSCALL(amem)
 5bc:	b8 33 00 00 00       	mov    $0x33,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <c_ps>:
SYSCALL(c_ps)
 5c4:	b8 34 00 00 00       	mov    $0x34,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <get_used>:
SYSCALL(get_used)
 5cc:	b8 35 00 00 00       	mov    $0x35,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	83 ec 18             	sub    $0x18,%esp
 5da:	8b 45 0c             	mov    0xc(%ebp),%eax
 5dd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5e0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5e7:	00 
 5e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ef:	8b 45 08             	mov    0x8(%ebp),%eax
 5f2:	89 04 24             	mov    %eax,(%esp)
 5f5:	e8 5a fe ff ff       	call   454 <write>
}
 5fa:	c9                   	leave  
 5fb:	c3                   	ret    

000005fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5fc:	55                   	push   %ebp
 5fd:	89 e5                	mov    %esp,%ebp
 5ff:	56                   	push   %esi
 600:	53                   	push   %ebx
 601:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 604:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 60b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 60f:	74 17                	je     628 <printint+0x2c>
 611:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 615:	79 11                	jns    628 <printint+0x2c>
    neg = 1;
 617:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 61e:	8b 45 0c             	mov    0xc(%ebp),%eax
 621:	f7 d8                	neg    %eax
 623:	89 45 ec             	mov    %eax,-0x14(%ebp)
 626:	eb 06                	jmp    62e <printint+0x32>
  } else {
    x = xx;
 628:	8b 45 0c             	mov    0xc(%ebp),%eax
 62b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 62e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 635:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 638:	8d 41 01             	lea    0x1(%ecx),%eax
 63b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 63e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 641:	8b 45 ec             	mov    -0x14(%ebp),%eax
 644:	ba 00 00 00 00       	mov    $0x0,%edx
 649:	f7 f3                	div    %ebx
 64b:	89 d0                	mov    %edx,%eax
 64d:	8a 80 2c 0d 00 00    	mov    0xd2c(%eax),%al
 653:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 657:	8b 75 10             	mov    0x10(%ebp),%esi
 65a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 65d:	ba 00 00 00 00       	mov    $0x0,%edx
 662:	f7 f6                	div    %esi
 664:	89 45 ec             	mov    %eax,-0x14(%ebp)
 667:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 66b:	75 c8                	jne    635 <printint+0x39>
  if(neg)
 66d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 671:	74 10                	je     683 <printint+0x87>
    buf[i++] = '-';
 673:	8b 45 f4             	mov    -0xc(%ebp),%eax
 676:	8d 50 01             	lea    0x1(%eax),%edx
 679:	89 55 f4             	mov    %edx,-0xc(%ebp)
 67c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 681:	eb 1e                	jmp    6a1 <printint+0xa5>
 683:	eb 1c                	jmp    6a1 <printint+0xa5>
    putc(fd, buf[i]);
 685:	8d 55 dc             	lea    -0x24(%ebp),%edx
 688:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68b:	01 d0                	add    %edx,%eax
 68d:	8a 00                	mov    (%eax),%al
 68f:	0f be c0             	movsbl %al,%eax
 692:	89 44 24 04          	mov    %eax,0x4(%esp)
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	89 04 24             	mov    %eax,(%esp)
 69c:	e8 33 ff ff ff       	call   5d4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6a1:	ff 4d f4             	decl   -0xc(%ebp)
 6a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a8:	79 db                	jns    685 <printint+0x89>
    putc(fd, buf[i]);
}
 6aa:	83 c4 30             	add    $0x30,%esp
 6ad:	5b                   	pop    %ebx
 6ae:	5e                   	pop    %esi
 6af:	5d                   	pop    %ebp
 6b0:	c3                   	ret    

000006b1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6b1:	55                   	push   %ebp
 6b2:	89 e5                	mov    %esp,%ebp
 6b4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6be:	8d 45 0c             	lea    0xc(%ebp),%eax
 6c1:	83 c0 04             	add    $0x4,%eax
 6c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ce:	e9 77 01 00 00       	jmp    84a <printf+0x199>
    c = fmt[i] & 0xff;
 6d3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d9:	01 d0                	add    %edx,%eax
 6db:	8a 00                	mov    (%eax),%al
 6dd:	0f be c0             	movsbl %al,%eax
 6e0:	25 ff 00 00 00       	and    $0xff,%eax
 6e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ec:	75 2c                	jne    71a <printf+0x69>
      if(c == '%'){
 6ee:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f2:	75 0c                	jne    700 <printf+0x4f>
        state = '%';
 6f4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6fb:	e9 47 01 00 00       	jmp    847 <printf+0x196>
      } else {
        putc(fd, c);
 700:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 703:	0f be c0             	movsbl %al,%eax
 706:	89 44 24 04          	mov    %eax,0x4(%esp)
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	89 04 24             	mov    %eax,(%esp)
 710:	e8 bf fe ff ff       	call   5d4 <putc>
 715:	e9 2d 01 00 00       	jmp    847 <printf+0x196>
      }
    } else if(state == '%'){
 71a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 71e:	0f 85 23 01 00 00    	jne    847 <printf+0x196>
      if(c == 'd'){
 724:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 728:	75 2d                	jne    757 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 72a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72d:	8b 00                	mov    (%eax),%eax
 72f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 736:	00 
 737:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 73e:	00 
 73f:	89 44 24 04          	mov    %eax,0x4(%esp)
 743:	8b 45 08             	mov    0x8(%ebp),%eax
 746:	89 04 24             	mov    %eax,(%esp)
 749:	e8 ae fe ff ff       	call   5fc <printint>
        ap++;
 74e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 752:	e9 e9 00 00 00       	jmp    840 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 757:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 75b:	74 06                	je     763 <printf+0xb2>
 75d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 761:	75 2d                	jne    790 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 763:	8b 45 e8             	mov    -0x18(%ebp),%eax
 766:	8b 00                	mov    (%eax),%eax
 768:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 76f:	00 
 770:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 777:	00 
 778:	89 44 24 04          	mov    %eax,0x4(%esp)
 77c:	8b 45 08             	mov    0x8(%ebp),%eax
 77f:	89 04 24             	mov    %eax,(%esp)
 782:	e8 75 fe ff ff       	call   5fc <printint>
        ap++;
 787:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78b:	e9 b0 00 00 00       	jmp    840 <printf+0x18f>
      } else if(c == 's'){
 790:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 794:	75 42                	jne    7d8 <printf+0x127>
        s = (char*)*ap;
 796:	8b 45 e8             	mov    -0x18(%ebp),%eax
 799:	8b 00                	mov    (%eax),%eax
 79b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 79e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a6:	75 09                	jne    7b1 <printf+0x100>
          s = "(null)";
 7a8:	c7 45 f4 ba 0a 00 00 	movl   $0xaba,-0xc(%ebp)
        while(*s != 0){
 7af:	eb 1c                	jmp    7cd <printf+0x11c>
 7b1:	eb 1a                	jmp    7cd <printf+0x11c>
          putc(fd, *s);
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	8a 00                	mov    (%eax),%al
 7b8:	0f be c0             	movsbl %al,%eax
 7bb:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bf:	8b 45 08             	mov    0x8(%ebp),%eax
 7c2:	89 04 24             	mov    %eax,(%esp)
 7c5:	e8 0a fe ff ff       	call   5d4 <putc>
          s++;
 7ca:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	8a 00                	mov    (%eax),%al
 7d2:	84 c0                	test   %al,%al
 7d4:	75 dd                	jne    7b3 <printf+0x102>
 7d6:	eb 68                	jmp    840 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7d8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7dc:	75 1d                	jne    7fb <printf+0x14a>
        putc(fd, *ap);
 7de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	0f be c0             	movsbl %al,%eax
 7e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ea:	8b 45 08             	mov    0x8(%ebp),%eax
 7ed:	89 04 24             	mov    %eax,(%esp)
 7f0:	e8 df fd ff ff       	call   5d4 <putc>
        ap++;
 7f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f9:	eb 45                	jmp    840 <printf+0x18f>
      } else if(c == '%'){
 7fb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ff:	75 17                	jne    818 <printf+0x167>
        putc(fd, c);
 801:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 804:	0f be c0             	movsbl %al,%eax
 807:	89 44 24 04          	mov    %eax,0x4(%esp)
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	89 04 24             	mov    %eax,(%esp)
 811:	e8 be fd ff ff       	call   5d4 <putc>
 816:	eb 28                	jmp    840 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 818:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 81f:	00 
 820:	8b 45 08             	mov    0x8(%ebp),%eax
 823:	89 04 24             	mov    %eax,(%esp)
 826:	e8 a9 fd ff ff       	call   5d4 <putc>
        putc(fd, c);
 82b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 82e:	0f be c0             	movsbl %al,%eax
 831:	89 44 24 04          	mov    %eax,0x4(%esp)
 835:	8b 45 08             	mov    0x8(%ebp),%eax
 838:	89 04 24             	mov    %eax,(%esp)
 83b:	e8 94 fd ff ff       	call   5d4 <putc>
      }
      state = 0;
 840:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 847:	ff 45 f0             	incl   -0x10(%ebp)
 84a:	8b 55 0c             	mov    0xc(%ebp),%edx
 84d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 850:	01 d0                	add    %edx,%eax
 852:	8a 00                	mov    (%eax),%al
 854:	84 c0                	test   %al,%al
 856:	0f 85 77 fe ff ff    	jne    6d3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 85c:	c9                   	leave  
 85d:	c3                   	ret    
 85e:	90                   	nop
 85f:	90                   	nop

00000860 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 860:	55                   	push   %ebp
 861:	89 e5                	mov    %esp,%ebp
 863:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 866:	8b 45 08             	mov    0x8(%ebp),%eax
 869:	83 e8 08             	sub    $0x8,%eax
 86c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86f:	a1 48 0d 00 00       	mov    0xd48,%eax
 874:	89 45 fc             	mov    %eax,-0x4(%ebp)
 877:	eb 24                	jmp    89d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 881:	77 12                	ja     895 <free+0x35>
 883:	8b 45 f8             	mov    -0x8(%ebp),%eax
 886:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 889:	77 24                	ja     8af <free+0x4f>
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 893:	77 1a                	ja     8af <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 895:	8b 45 fc             	mov    -0x4(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 89d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a3:	76 d4                	jbe    879 <free+0x19>
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ad:	76 ca                	jbe    879 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b2:	8b 40 04             	mov    0x4(%eax),%eax
 8b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bf:	01 c2                	add    %eax,%edx
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	39 c2                	cmp    %eax,%edx
 8c8:	75 24                	jne    8ee <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cd:	8b 50 04             	mov    0x4(%eax),%edx
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	8b 00                	mov    (%eax),%eax
 8d5:	8b 40 04             	mov    0x4(%eax),%eax
 8d8:	01 c2                	add    %eax,%edx
 8da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	8b 10                	mov    (%eax),%edx
 8e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ea:	89 10                	mov    %edx,(%eax)
 8ec:	eb 0a                	jmp    8f8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	8b 10                	mov    (%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 40 04             	mov    0x4(%eax),%eax
 8fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	01 d0                	add    %edx,%eax
 90a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 90d:	75 20                	jne    92f <free+0xcf>
    p->s.size += bp->s.size;
 90f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 912:	8b 50 04             	mov    0x4(%eax),%edx
 915:	8b 45 f8             	mov    -0x8(%ebp),%eax
 918:	8b 40 04             	mov    0x4(%eax),%eax
 91b:	01 c2                	add    %eax,%edx
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	8b 10                	mov    (%eax),%edx
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	89 10                	mov    %edx,(%eax)
 92d:	eb 08                	jmp    937 <free+0xd7>
  } else
    p->s.ptr = bp;
 92f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 932:	8b 55 f8             	mov    -0x8(%ebp),%edx
 935:	89 10                	mov    %edx,(%eax)
  freep = p;
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	a3 48 0d 00 00       	mov    %eax,0xd48
}
 93f:	c9                   	leave  
 940:	c3                   	ret    

00000941 <morecore>:

static Header*
morecore(uint nu)
{
 941:	55                   	push   %ebp
 942:	89 e5                	mov    %esp,%ebp
 944:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 947:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 94e:	77 07                	ja     957 <morecore+0x16>
    nu = 4096;
 950:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 957:	8b 45 08             	mov    0x8(%ebp),%eax
 95a:	c1 e0 03             	shl    $0x3,%eax
 95d:	89 04 24             	mov    %eax,(%esp)
 960:	e8 57 fb ff ff       	call   4bc <sbrk>
 965:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 968:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 96c:	75 07                	jne    975 <morecore+0x34>
    return 0;
 96e:	b8 00 00 00 00       	mov    $0x0,%eax
 973:	eb 22                	jmp    997 <morecore+0x56>
  hp = (Header*)p;
 975:	8b 45 f4             	mov    -0xc(%ebp),%eax
 978:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 97b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97e:	8b 55 08             	mov    0x8(%ebp),%edx
 981:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	83 c0 08             	add    $0x8,%eax
 98a:	89 04 24             	mov    %eax,(%esp)
 98d:	e8 ce fe ff ff       	call   860 <free>
  return freep;
 992:	a1 48 0d 00 00       	mov    0xd48,%eax
}
 997:	c9                   	leave  
 998:	c3                   	ret    

00000999 <malloc>:

void*
malloc(uint nbytes)
{
 999:	55                   	push   %ebp
 99a:	89 e5                	mov    %esp,%ebp
 99c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99f:	8b 45 08             	mov    0x8(%ebp),%eax
 9a2:	83 c0 07             	add    $0x7,%eax
 9a5:	c1 e8 03             	shr    $0x3,%eax
 9a8:	40                   	inc    %eax
 9a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ac:	a1 48 0d 00 00       	mov    0xd48,%eax
 9b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b8:	75 23                	jne    9dd <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 9ba:	c7 45 f0 40 0d 00 00 	movl   $0xd40,-0x10(%ebp)
 9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c4:	a3 48 0d 00 00       	mov    %eax,0xd48
 9c9:	a1 48 0d 00 00       	mov    0xd48,%eax
 9ce:	a3 40 0d 00 00       	mov    %eax,0xd40
    base.s.size = 0;
 9d3:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
 9da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e0:	8b 00                	mov    (%eax),%eax
 9e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	8b 40 04             	mov    0x4(%eax),%eax
 9eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ee:	72 4d                	jb     a3d <malloc+0xa4>
      if(p->s.size == nunits)
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 40 04             	mov    0x4(%eax),%eax
 9f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9f9:	75 0c                	jne    a07 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	8b 10                	mov    (%eax),%edx
 a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a03:	89 10                	mov    %edx,(%eax)
 a05:	eb 26                	jmp    a2d <malloc+0x94>
      else {
        p->s.size -= nunits;
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8b 40 04             	mov    0x4(%eax),%eax
 a0d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a10:	89 c2                	mov    %eax,%edx
 a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a15:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1b:	8b 40 04             	mov    0x4(%eax),%eax
 a1e:	c1 e0 03             	shl    $0x3,%eax
 a21:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a2a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a30:	a3 48 0d 00 00       	mov    %eax,0xd48
      return (void*)(p + 1);
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	83 c0 08             	add    $0x8,%eax
 a3b:	eb 38                	jmp    a75 <malloc+0xdc>
    }
    if(p == freep)
 a3d:	a1 48 0d 00 00       	mov    0xd48,%eax
 a42:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a45:	75 1b                	jne    a62 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a4a:	89 04 24             	mov    %eax,(%esp)
 a4d:	e8 ef fe ff ff       	call   941 <morecore>
 a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a59:	75 07                	jne    a62 <malloc+0xc9>
        return 0;
 a5b:	b8 00 00 00 00       	mov    $0x0,%eax
 a60:	eb 13                	jmp    a75 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	8b 00                	mov    (%eax),%eax
 a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a70:	e9 70 ff ff ff       	jmp    9e5 <malloc+0x4c>
}
 a75:	c9                   	leave  
 a76:	c3                   	ret    
