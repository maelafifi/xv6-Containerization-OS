
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
   f:	c7 44 24 04 98 0a 00 	movl   $0xa98,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 ae 06 00 00       	call   6d1 <printf>
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
  4c:	c7 44 24 04 be 0a 00 	movl   $0xabe,0x4(%esp)
  53:	00 
  54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5b:	e8 71 06 00 00       	call   6d1 <printf>

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
  e3:	c7 44 24 04 c7 0a 00 	movl   $0xac7,0x4(%esp)
  ea:	00 
  eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f2:	e8 da 05 00 00       	call   6d1 <printf>

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

000005d4 <get_os>:
SYSCALL(get_os)
 5d4:	b8 36 00 00 00       	mov    $0x36,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <set_os>:
SYSCALL(set_os)
 5dc:	b8 37 00 00 00       	mov    $0x37,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <get_cticks>:
SYSCALL(get_cticks)
 5e4:	b8 38 00 00 00       	mov    $0x38,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <tick_reset2>:
SYSCALL(tick_reset2)
 5ec:	b8 39 00 00 00       	mov    $0x39,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5f4:	55                   	push   %ebp
 5f5:	89 e5                	mov    %esp,%ebp
 5f7:	83 ec 18             	sub    $0x18,%esp
 5fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 600:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 607:	00 
 608:	8d 45 f4             	lea    -0xc(%ebp),%eax
 60b:	89 44 24 04          	mov    %eax,0x4(%esp)
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	89 04 24             	mov    %eax,(%esp)
 615:	e8 3a fe ff ff       	call   454 <write>
}
 61a:	c9                   	leave  
 61b:	c3                   	ret    

0000061c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 61c:	55                   	push   %ebp
 61d:	89 e5                	mov    %esp,%ebp
 61f:	56                   	push   %esi
 620:	53                   	push   %ebx
 621:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 624:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 62b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 62f:	74 17                	je     648 <printint+0x2c>
 631:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 635:	79 11                	jns    648 <printint+0x2c>
    neg = 1;
 637:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 63e:	8b 45 0c             	mov    0xc(%ebp),%eax
 641:	f7 d8                	neg    %eax
 643:	89 45 ec             	mov    %eax,-0x14(%ebp)
 646:	eb 06                	jmp    64e <printint+0x32>
  } else {
    x = xx;
 648:	8b 45 0c             	mov    0xc(%ebp),%eax
 64b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 64e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 655:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 658:	8d 41 01             	lea    0x1(%ecx),%eax
 65b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 65e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 661:	8b 45 ec             	mov    -0x14(%ebp),%eax
 664:	ba 00 00 00 00       	mov    $0x0,%edx
 669:	f7 f3                	div    %ebx
 66b:	89 d0                	mov    %edx,%eax
 66d:	8a 80 4c 0d 00 00    	mov    0xd4c(%eax),%al
 673:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 677:	8b 75 10             	mov    0x10(%ebp),%esi
 67a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 67d:	ba 00 00 00 00       	mov    $0x0,%edx
 682:	f7 f6                	div    %esi
 684:	89 45 ec             	mov    %eax,-0x14(%ebp)
 687:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 68b:	75 c8                	jne    655 <printint+0x39>
  if(neg)
 68d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 691:	74 10                	je     6a3 <printint+0x87>
    buf[i++] = '-';
 693:	8b 45 f4             	mov    -0xc(%ebp),%eax
 696:	8d 50 01             	lea    0x1(%eax),%edx
 699:	89 55 f4             	mov    %edx,-0xc(%ebp)
 69c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6a1:	eb 1e                	jmp    6c1 <printint+0xa5>
 6a3:	eb 1c                	jmp    6c1 <printint+0xa5>
    putc(fd, buf[i]);
 6a5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ab:	01 d0                	add    %edx,%eax
 6ad:	8a 00                	mov    (%eax),%al
 6af:	0f be c0             	movsbl %al,%eax
 6b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
 6b9:	89 04 24             	mov    %eax,(%esp)
 6bc:	e8 33 ff ff ff       	call   5f4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6c1:	ff 4d f4             	decl   -0xc(%ebp)
 6c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c8:	79 db                	jns    6a5 <printint+0x89>
    putc(fd, buf[i]);
}
 6ca:	83 c4 30             	add    $0x30,%esp
 6cd:	5b                   	pop    %ebx
 6ce:	5e                   	pop    %esi
 6cf:	5d                   	pop    %ebp
 6d0:	c3                   	ret    

000006d1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6d1:	55                   	push   %ebp
 6d2:	89 e5                	mov    %esp,%ebp
 6d4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6d7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6de:	8d 45 0c             	lea    0xc(%ebp),%eax
 6e1:	83 c0 04             	add    $0x4,%eax
 6e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6e7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ee:	e9 77 01 00 00       	jmp    86a <printf+0x199>
    c = fmt[i] & 0xff;
 6f3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f9:	01 d0                	add    %edx,%eax
 6fb:	8a 00                	mov    (%eax),%al
 6fd:	0f be c0             	movsbl %al,%eax
 700:	25 ff 00 00 00       	and    $0xff,%eax
 705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 708:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70c:	75 2c                	jne    73a <printf+0x69>
      if(c == '%'){
 70e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 712:	75 0c                	jne    720 <printf+0x4f>
        state = '%';
 714:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 71b:	e9 47 01 00 00       	jmp    867 <printf+0x196>
      } else {
        putc(fd, c);
 720:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 723:	0f be c0             	movsbl %al,%eax
 726:	89 44 24 04          	mov    %eax,0x4(%esp)
 72a:	8b 45 08             	mov    0x8(%ebp),%eax
 72d:	89 04 24             	mov    %eax,(%esp)
 730:	e8 bf fe ff ff       	call   5f4 <putc>
 735:	e9 2d 01 00 00       	jmp    867 <printf+0x196>
      }
    } else if(state == '%'){
 73a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 73e:	0f 85 23 01 00 00    	jne    867 <printf+0x196>
      if(c == 'd'){
 744:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 748:	75 2d                	jne    777 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 74a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 756:	00 
 757:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 75e:	00 
 75f:	89 44 24 04          	mov    %eax,0x4(%esp)
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 ae fe ff ff       	call   61c <printint>
        ap++;
 76e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 772:	e9 e9 00 00 00       	jmp    860 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 777:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 77b:	74 06                	je     783 <printf+0xb2>
 77d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 781:	75 2d                	jne    7b0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 783:	8b 45 e8             	mov    -0x18(%ebp),%eax
 786:	8b 00                	mov    (%eax),%eax
 788:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 78f:	00 
 790:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 797:	00 
 798:	89 44 24 04          	mov    %eax,0x4(%esp)
 79c:	8b 45 08             	mov    0x8(%ebp),%eax
 79f:	89 04 24             	mov    %eax,(%esp)
 7a2:	e8 75 fe ff ff       	call   61c <printint>
        ap++;
 7a7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ab:	e9 b0 00 00 00       	jmp    860 <printf+0x18f>
      } else if(c == 's'){
 7b0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7b4:	75 42                	jne    7f8 <printf+0x127>
        s = (char*)*ap;
 7b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b9:	8b 00                	mov    (%eax),%eax
 7bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c6:	75 09                	jne    7d1 <printf+0x100>
          s = "(null)";
 7c8:	c7 45 f4 da 0a 00 00 	movl   $0xada,-0xc(%ebp)
        while(*s != 0){
 7cf:	eb 1c                	jmp    7ed <printf+0x11c>
 7d1:	eb 1a                	jmp    7ed <printf+0x11c>
          putc(fd, *s);
 7d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d6:	8a 00                	mov    (%eax),%al
 7d8:	0f be c0             	movsbl %al,%eax
 7db:	89 44 24 04          	mov    %eax,0x4(%esp)
 7df:	8b 45 08             	mov    0x8(%ebp),%eax
 7e2:	89 04 24             	mov    %eax,(%esp)
 7e5:	e8 0a fe ff ff       	call   5f4 <putc>
          s++;
 7ea:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	8a 00                	mov    (%eax),%al
 7f2:	84 c0                	test   %al,%al
 7f4:	75 dd                	jne    7d3 <printf+0x102>
 7f6:	eb 68                	jmp    860 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7f8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7fc:	75 1d                	jne    81b <printf+0x14a>
        putc(fd, *ap);
 7fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 801:	8b 00                	mov    (%eax),%eax
 803:	0f be c0             	movsbl %al,%eax
 806:	89 44 24 04          	mov    %eax,0x4(%esp)
 80a:	8b 45 08             	mov    0x8(%ebp),%eax
 80d:	89 04 24             	mov    %eax,(%esp)
 810:	e8 df fd ff ff       	call   5f4 <putc>
        ap++;
 815:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 819:	eb 45                	jmp    860 <printf+0x18f>
      } else if(c == '%'){
 81b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 81f:	75 17                	jne    838 <printf+0x167>
        putc(fd, c);
 821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 824:	0f be c0             	movsbl %al,%eax
 827:	89 44 24 04          	mov    %eax,0x4(%esp)
 82b:	8b 45 08             	mov    0x8(%ebp),%eax
 82e:	89 04 24             	mov    %eax,(%esp)
 831:	e8 be fd ff ff       	call   5f4 <putc>
 836:	eb 28                	jmp    860 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 838:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 83f:	00 
 840:	8b 45 08             	mov    0x8(%ebp),%eax
 843:	89 04 24             	mov    %eax,(%esp)
 846:	e8 a9 fd ff ff       	call   5f4 <putc>
        putc(fd, c);
 84b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 84e:	0f be c0             	movsbl %al,%eax
 851:	89 44 24 04          	mov    %eax,0x4(%esp)
 855:	8b 45 08             	mov    0x8(%ebp),%eax
 858:	89 04 24             	mov    %eax,(%esp)
 85b:	e8 94 fd ff ff       	call   5f4 <putc>
      }
      state = 0;
 860:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 867:	ff 45 f0             	incl   -0x10(%ebp)
 86a:	8b 55 0c             	mov    0xc(%ebp),%edx
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	01 d0                	add    %edx,%eax
 872:	8a 00                	mov    (%eax),%al
 874:	84 c0                	test   %al,%al
 876:	0f 85 77 fe ff ff    	jne    6f3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 87c:	c9                   	leave  
 87d:	c3                   	ret    
 87e:	90                   	nop
 87f:	90                   	nop

00000880 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 880:	55                   	push   %ebp
 881:	89 e5                	mov    %esp,%ebp
 883:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 886:	8b 45 08             	mov    0x8(%ebp),%eax
 889:	83 e8 08             	sub    $0x8,%eax
 88c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88f:	a1 68 0d 00 00       	mov    0xd68,%eax
 894:	89 45 fc             	mov    %eax,-0x4(%ebp)
 897:	eb 24                	jmp    8bd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 899:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89c:	8b 00                	mov    (%eax),%eax
 89e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a1:	77 12                	ja     8b5 <free+0x35>
 8a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a9:	77 24                	ja     8cf <free+0x4f>
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 00                	mov    (%eax),%eax
 8b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b3:	77 1a                	ja     8cf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b8:	8b 00                	mov    (%eax),%eax
 8ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c3:	76 d4                	jbe    899 <free+0x19>
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	8b 00                	mov    (%eax),%eax
 8ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8cd:	76 ca                	jbe    899 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	8b 40 04             	mov    0x4(%eax),%eax
 8d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8df:	01 c2                	add    %eax,%edx
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	39 c2                	cmp    %eax,%edx
 8e8:	75 24                	jne    90e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ed:	8b 50 04             	mov    0x4(%eax),%edx
 8f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f3:	8b 00                	mov    (%eax),%eax
 8f5:	8b 40 04             	mov    0x4(%eax),%eax
 8f8:	01 c2                	add    %eax,%edx
 8fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 900:	8b 45 fc             	mov    -0x4(%ebp),%eax
 903:	8b 00                	mov    (%eax),%eax
 905:	8b 10                	mov    (%eax),%edx
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	89 10                	mov    %edx,(%eax)
 90c:	eb 0a                	jmp    918 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 90e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 911:	8b 10                	mov    (%eax),%edx
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 40 04             	mov    0x4(%eax),%eax
 91e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	01 d0                	add    %edx,%eax
 92a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 92d:	75 20                	jne    94f <free+0xcf>
    p->s.size += bp->s.size;
 92f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 932:	8b 50 04             	mov    0x4(%eax),%edx
 935:	8b 45 f8             	mov    -0x8(%ebp),%eax
 938:	8b 40 04             	mov    0x4(%eax),%eax
 93b:	01 c2                	add    %eax,%edx
 93d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 940:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	8b 10                	mov    (%eax),%edx
 948:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94b:	89 10                	mov    %edx,(%eax)
 94d:	eb 08                	jmp    957 <free+0xd7>
  } else
    p->s.ptr = bp;
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	8b 55 f8             	mov    -0x8(%ebp),%edx
 955:	89 10                	mov    %edx,(%eax)
  freep = p;
 957:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95a:	a3 68 0d 00 00       	mov    %eax,0xd68
}
 95f:	c9                   	leave  
 960:	c3                   	ret    

00000961 <morecore>:

static Header*
morecore(uint nu)
{
 961:	55                   	push   %ebp
 962:	89 e5                	mov    %esp,%ebp
 964:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 967:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 96e:	77 07                	ja     977 <morecore+0x16>
    nu = 4096;
 970:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 977:	8b 45 08             	mov    0x8(%ebp),%eax
 97a:	c1 e0 03             	shl    $0x3,%eax
 97d:	89 04 24             	mov    %eax,(%esp)
 980:	e8 37 fb ff ff       	call   4bc <sbrk>
 985:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 988:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 98c:	75 07                	jne    995 <morecore+0x34>
    return 0;
 98e:	b8 00 00 00 00       	mov    $0x0,%eax
 993:	eb 22                	jmp    9b7 <morecore+0x56>
  hp = (Header*)p;
 995:	8b 45 f4             	mov    -0xc(%ebp),%eax
 998:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 99b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99e:	8b 55 08             	mov    0x8(%ebp),%edx
 9a1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a7:	83 c0 08             	add    $0x8,%eax
 9aa:	89 04 24             	mov    %eax,(%esp)
 9ad:	e8 ce fe ff ff       	call   880 <free>
  return freep;
 9b2:	a1 68 0d 00 00       	mov    0xd68,%eax
}
 9b7:	c9                   	leave  
 9b8:	c3                   	ret    

000009b9 <malloc>:

void*
malloc(uint nbytes)
{
 9b9:	55                   	push   %ebp
 9ba:	89 e5                	mov    %esp,%ebp
 9bc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9bf:	8b 45 08             	mov    0x8(%ebp),%eax
 9c2:	83 c0 07             	add    $0x7,%eax
 9c5:	c1 e8 03             	shr    $0x3,%eax
 9c8:	40                   	inc    %eax
 9c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9cc:	a1 68 0d 00 00       	mov    0xd68,%eax
 9d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9d8:	75 23                	jne    9fd <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 9da:	c7 45 f0 60 0d 00 00 	movl   $0xd60,-0x10(%ebp)
 9e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e4:	a3 68 0d 00 00       	mov    %eax,0xd68
 9e9:	a1 68 0d 00 00       	mov    0xd68,%eax
 9ee:	a3 60 0d 00 00       	mov    %eax,0xd60
    base.s.size = 0;
 9f3:	c7 05 64 0d 00 00 00 	movl   $0x0,0xd64
 9fa:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a00:	8b 00                	mov    (%eax),%eax
 a02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a08:	8b 40 04             	mov    0x4(%eax),%eax
 a0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a0e:	72 4d                	jb     a5d <malloc+0xa4>
      if(p->s.size == nunits)
 a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a13:	8b 40 04             	mov    0x4(%eax),%eax
 a16:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a19:	75 0c                	jne    a27 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1e:	8b 10                	mov    (%eax),%edx
 a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a23:	89 10                	mov    %edx,(%eax)
 a25:	eb 26                	jmp    a4d <malloc+0x94>
      else {
        p->s.size -= nunits;
 a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2a:	8b 40 04             	mov    0x4(%eax),%eax
 a2d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a30:	89 c2                	mov    %eax,%edx
 a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a35:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3b:	8b 40 04             	mov    0x4(%eax),%eax
 a3e:	c1 e0 03             	shl    $0x3,%eax
 a41:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a47:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a4a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a50:	a3 68 0d 00 00       	mov    %eax,0xd68
      return (void*)(p + 1);
 a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a58:	83 c0 08             	add    $0x8,%eax
 a5b:	eb 38                	jmp    a95 <malloc+0xdc>
    }
    if(p == freep)
 a5d:	a1 68 0d 00 00       	mov    0xd68,%eax
 a62:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a65:	75 1b                	jne    a82 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a6a:	89 04 24             	mov    %eax,(%esp)
 a6d:	e8 ef fe ff ff       	call   961 <morecore>
 a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a79:	75 07                	jne    a82 <malloc+0xc9>
        return 0;
 a7b:	b8 00 00 00 00       	mov    $0x0,%eax
 a80:	eb 13                	jmp    a95 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8b:	8b 00                	mov    (%eax),%eax
 a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a90:	e9 70 ff ff ff       	jmp    a05 <malloc+0x4c>
}
 a95:	c9                   	leave  
 a96:	c3                   	ret    
