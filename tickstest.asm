
_tickstest:     file format elf32-i386


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
   6:	83 ec 30             	sub    $0x30,%esp
  int i, j;
  int n;
  uint ticks, t1, t2;


  if (argc != 2) {
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
  	printf(1, "usage: tickstest n\n");
   f:	c7 44 24 04 8f 0a 00 	movl   $0xa8f,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 a6 06 00 00       	call   6c9 <printf>
  	exit();
  23:	e8 14 04 00 00       	call   43c <exit>
  }

  n = atoi(argv[1]);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	89 04 24             	mov    %eax,(%esp)
  33:	e8 8f 02 00 00       	call   2c7 <atoi>
  38:	89 44 24 24          	mov    %eax,0x24(%esp)

  t1 = uptime();
  3c:	e8 93 04 00 00       	call   4d4 <uptime>
  41:	89 44 24 20          	mov    %eax,0x20(%esp)

  for (i = 0; i < n; i++) {
  45:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  4c:	00 
  4d:	eb 1c                	jmp    6b <main+0x6b>
    for (j = 0; j< 100000; j++) {
  4f:	c7 44 24 28 00 00 00 	movl   $0x0,0x28(%esp)
  56:	00 
  57:	eb 04                	jmp    5d <main+0x5d>
  59:	ff 44 24 28          	incl   0x28(%esp)
  5d:	81 7c 24 28 9f 86 01 	cmpl   $0x1869f,0x28(%esp)
  64:	00 
  65:	7e f2                	jle    59 <main+0x59>

  n = atoi(argv[1]);

  t1 = uptime();

  for (i = 0; i < n; i++) {
  67:	ff 44 24 2c          	incl   0x2c(%esp)
  6b:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  6f:	3b 44 24 24          	cmp    0x24(%esp),%eax
  73:	7c da                	jl     4f <main+0x4f>
    for (j = 0; j< 100000; j++) {
      ;
    }
  }

  t2 = uptime();
  75:	e8 5a 04 00 00       	call   4d4 <uptime>
  7a:	89 44 24 1c          	mov    %eax,0x1c(%esp)

  ticks = getticks();
  7e:	e8 59 04 00 00       	call   4dc <getticks>
  83:	89 44 24 18          	mov    %eax,0x18(%esp)
  printf(1, "ticks = %d\n", ticks);
  87:	8b 44 24 18          	mov    0x18(%esp),%eax
  8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  8f:	c7 44 24 04 a3 0a 00 	movl   $0xaa3,0x4(%esp)
  96:	00 
  97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9e:	e8 26 06 00 00       	call   6c9 <printf>
  printf(1, "t1    = %d\n", t1);
  a3:	8b 44 24 20          	mov    0x20(%esp),%eax
  a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  ab:	c7 44 24 04 af 0a 00 	movl   $0xaaf,0x4(%esp)
  b2:	00 
  b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ba:	e8 0a 06 00 00       	call   6c9 <printf>
  printf(1, "t2    = %d\n", t2);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  c7:	c7 44 24 04 bb 0a 00 	movl   $0xabb,0x4(%esp)
  ce:	00 
  cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d6:	e8 ee 05 00 00       	call   6c9 <printf>
  printf(1, "t2-t1 = %d\n", t2-t1);    
  db:	8b 44 24 20          	mov    0x20(%esp),%eax
  df:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  e3:	29 c2                	sub    %eax,%edx
  e5:	89 d0                	mov    %edx,%eax
  e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  eb:	c7 44 24 04 c7 0a 00 	movl   $0xac7,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 ca 05 00 00       	call   6c9 <printf>

  exit();
  ff:	e8 38 03 00 00       	call   43c <exit>

00000104 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	57                   	push   %edi
 108:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 109:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10c:	8b 55 10             	mov    0x10(%ebp),%edx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	89 cb                	mov    %ecx,%ebx
 114:	89 df                	mov    %ebx,%edi
 116:	89 d1                	mov    %edx,%ecx
 118:	fc                   	cld    
 119:	f3 aa                	rep stos %al,%es:(%edi)
 11b:	89 ca                	mov    %ecx,%edx
 11d:	89 fb                	mov    %edi,%ebx
 11f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 122:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 125:	5b                   	pop    %ebx
 126:	5f                   	pop    %edi
 127:	5d                   	pop    %ebp
 128:	c3                   	ret    

00000129 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 129:	55                   	push   %ebp
 12a:	89 e5                	mov    %esp,%ebp
 12c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 135:	90                   	nop
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	8d 50 01             	lea    0x1(%eax),%edx
 13c:	89 55 08             	mov    %edx,0x8(%ebp)
 13f:	8b 55 0c             	mov    0xc(%ebp),%edx
 142:	8d 4a 01             	lea    0x1(%edx),%ecx
 145:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 148:	8a 12                	mov    (%edx),%dl
 14a:	88 10                	mov    %dl,(%eax)
 14c:	8a 00                	mov    (%eax),%al
 14e:	84 c0                	test   %al,%al
 150:	75 e4                	jne    136 <strcpy+0xd>
    ;
  return os;
 152:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 155:	c9                   	leave  
 156:	c3                   	ret    

00000157 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 15a:	eb 06                	jmp    162 <strcmp+0xb>
    p++, q++;
 15c:	ff 45 08             	incl   0x8(%ebp)
 15f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	8a 00                	mov    (%eax),%al
 167:	84 c0                	test   %al,%al
 169:	74 0e                	je     179 <strcmp+0x22>
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	8a 10                	mov    (%eax),%dl
 170:	8b 45 0c             	mov    0xc(%ebp),%eax
 173:	8a 00                	mov    (%eax),%al
 175:	38 c2                	cmp    %al,%dl
 177:	74 e3                	je     15c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	8a 00                	mov    (%eax),%al
 17e:	0f b6 d0             	movzbl %al,%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	8a 00                	mov    (%eax),%al
 186:	0f b6 c0             	movzbl %al,%eax
 189:	29 c2                	sub    %eax,%edx
 18b:	89 d0                	mov    %edx,%eax
}
 18d:	5d                   	pop    %ebp
 18e:	c3                   	ret    

0000018f <strlen>:

uint
strlen(char *s)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 195:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 19c:	eb 03                	jmp    1a1 <strlen+0x12>
 19e:	ff 45 fc             	incl   -0x4(%ebp)
 1a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	01 d0                	add    %edx,%eax
 1a9:	8a 00                	mov    (%eax),%al
 1ab:	84 c0                	test   %al,%al
 1ad:	75 ef                	jne    19e <strlen+0xf>
    ;
  return n;
 1af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b2:	c9                   	leave  
 1b3:	c3                   	ret    

000001b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1ba:	8b 45 10             	mov    0x10(%ebp),%eax
 1bd:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	89 04 24             	mov    %eax,(%esp)
 1ce:	e8 31 ff ff ff       	call   104 <stosb>
  return dst;
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <strchr>:

char*
strchr(const char *s, char c)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 04             	sub    $0x4,%esp
 1de:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1e4:	eb 12                	jmp    1f8 <strchr+0x20>
    if(*s == c)
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	8a 00                	mov    (%eax),%al
 1eb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ee:	75 05                	jne    1f5 <strchr+0x1d>
      return (char*)s;
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	eb 11                	jmp    206 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f5:	ff 45 08             	incl   0x8(%ebp)
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	8a 00                	mov    (%eax),%al
 1fd:	84 c0                	test   %al,%al
 1ff:	75 e5                	jne    1e6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 201:	b8 00 00 00 00       	mov    $0x0,%eax
}
 206:	c9                   	leave  
 207:	c3                   	ret    

00000208 <gets>:

char*
gets(char *buf, int max)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 215:	eb 49                	jmp    260 <gets+0x58>
    cc = read(0, &c, 1);
 217:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 21e:	00 
 21f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 222:	89 44 24 04          	mov    %eax,0x4(%esp)
 226:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 22d:	e8 22 02 00 00       	call   454 <read>
 232:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 235:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 239:	7f 02                	jg     23d <gets+0x35>
      break;
 23b:	eb 2c                	jmp    269 <gets+0x61>
    buf[i++] = c;
 23d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 240:	8d 50 01             	lea    0x1(%eax),%edx
 243:	89 55 f4             	mov    %edx,-0xc(%ebp)
 246:	89 c2                	mov    %eax,%edx
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	01 c2                	add    %eax,%edx
 24d:	8a 45 ef             	mov    -0x11(%ebp),%al
 250:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 252:	8a 45 ef             	mov    -0x11(%ebp),%al
 255:	3c 0a                	cmp    $0xa,%al
 257:	74 10                	je     269 <gets+0x61>
 259:	8a 45 ef             	mov    -0x11(%ebp),%al
 25c:	3c 0d                	cmp    $0xd,%al
 25e:	74 09                	je     269 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 260:	8b 45 f4             	mov    -0xc(%ebp),%eax
 263:	40                   	inc    %eax
 264:	3b 45 0c             	cmp    0xc(%ebp),%eax
 267:	7c ae                	jl     217 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 269:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	01 d0                	add    %edx,%eax
 271:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <stat>:

int
stat(char *n, struct stat *st)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 286:	00 
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 04 24             	mov    %eax,(%esp)
 28d:	e8 ea 01 00 00       	call   47c <open>
 292:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 295:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 299:	79 07                	jns    2a2 <stat+0x29>
    return -1;
 29b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2a0:	eb 23                	jmp    2c5 <stat+0x4c>
  r = fstat(fd, st);
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	89 04 24             	mov    %eax,(%esp)
 2af:	e8 e0 01 00 00       	call   494 <fstat>
 2b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 a2 01 00 00       	call   464 <close>
  return r;
 2c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <atoi>:

int
atoi(const char *s)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d4:	eb 24                	jmp    2fa <atoi+0x33>
    n = n*10 + *s++ - '0';
 2d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d9:	89 d0                	mov    %edx,%eax
 2db:	c1 e0 02             	shl    $0x2,%eax
 2de:	01 d0                	add    %edx,%eax
 2e0:	01 c0                	add    %eax,%eax
 2e2:	89 c1                	mov    %eax,%ecx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 50 01             	lea    0x1(%eax),%edx
 2ea:	89 55 08             	mov    %edx,0x8(%ebp)
 2ed:	8a 00                	mov    (%eax),%al
 2ef:	0f be c0             	movsbl %al,%eax
 2f2:	01 c8                	add    %ecx,%eax
 2f4:	83 e8 30             	sub    $0x30,%eax
 2f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	8a 00                	mov    (%eax),%al
 2ff:	3c 2f                	cmp    $0x2f,%al
 301:	7e 09                	jle    30c <atoi+0x45>
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	8a 00                	mov    (%eax),%al
 308:	3c 39                	cmp    $0x39,%al
 30a:	7e ca                	jle    2d6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 30c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 31d:	8b 45 0c             	mov    0xc(%ebp),%eax
 320:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 323:	eb 16                	jmp    33b <memmove+0x2a>
    *dst++ = *src++;
 325:	8b 45 fc             	mov    -0x4(%ebp),%eax
 328:	8d 50 01             	lea    0x1(%eax),%edx
 32b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 32e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 331:	8d 4a 01             	lea    0x1(%edx),%ecx
 334:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 337:	8a 12                	mov    (%edx),%dl
 339:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 33b:	8b 45 10             	mov    0x10(%ebp),%eax
 33e:	8d 50 ff             	lea    -0x1(%eax),%edx
 341:	89 55 10             	mov    %edx,0x10(%ebp)
 344:	85 c0                	test   %eax,%eax
 346:	7f dd                	jg     325 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 348:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34b:	c9                   	leave  
 34c:	c3                   	ret    

0000034d <itoa>:

int itoa(int value, char *sp, int radix)
{
 34d:	55                   	push   %ebp
 34e:	89 e5                	mov    %esp,%ebp
 350:	53                   	push   %ebx
 351:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 354:	8d 45 d8             	lea    -0x28(%ebp),%eax
 357:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 35a:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 35e:	75 0d                	jne    36d <itoa+0x20>
 360:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 364:	79 07                	jns    36d <itoa+0x20>
 366:	b8 01 00 00 00       	mov    $0x1,%eax
 36b:	eb 05                	jmp    372 <itoa+0x25>
 36d:	b8 00 00 00 00       	mov    $0x0,%eax
 372:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 375:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 379:	74 0a                	je     385 <itoa+0x38>
      v = -value;
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	f7 d8                	neg    %eax
 380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 383:	eb 54                	jmp    3d9 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 38b:	eb 4c                	jmp    3d9 <itoa+0x8c>
  {
    i = v % radix;
 38d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 390:	8b 45 f4             	mov    -0xc(%ebp),%eax
 393:	ba 00 00 00 00       	mov    $0x0,%edx
 398:	f7 f1                	div    %ecx
 39a:	89 d0                	mov    %edx,%eax
 39c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 39f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a5:	ba 00 00 00 00       	mov    $0x0,%edx
 3aa:	f7 f3                	div    %ebx
 3ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 3af:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 3b3:	7f 13                	jg     3c8 <itoa+0x7b>
      *tp++ = i+'0';
 3b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3b8:	8d 50 01             	lea    0x1(%eax),%edx
 3bb:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3be:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3c1:	83 c2 30             	add    $0x30,%edx
 3c4:	88 10                	mov    %dl,(%eax)
 3c6:	eb 11                	jmp    3d9 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 3c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3cb:	8d 50 01             	lea    0x1(%eax),%edx
 3ce:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3d1:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3d4:	83 c2 57             	add    $0x57,%edx
 3d7:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 3d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3dd:	75 ae                	jne    38d <itoa+0x40>
 3df:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3e2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3e5:	74 a6                	je     38d <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 3e7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3ea:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3ed:	29 c2                	sub    %eax,%edx
 3ef:	89 d0                	mov    %edx,%eax
 3f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 3f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f8:	74 11                	je     40b <itoa+0xbe>
  {
    *sp++ = '-';
 3fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fd:	8d 50 01             	lea    0x1(%eax),%edx
 400:	89 55 0c             	mov    %edx,0xc(%ebp)
 403:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 406:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 409:	eb 15                	jmp    420 <itoa+0xd3>
 40b:	eb 13                	jmp    420 <itoa+0xd3>
    *sp++ = *--tp;
 40d:	8b 45 0c             	mov    0xc(%ebp),%eax
 410:	8d 50 01             	lea    0x1(%eax),%edx
 413:	89 55 0c             	mov    %edx,0xc(%ebp)
 416:	ff 4d f8             	decl   -0x8(%ebp)
 419:	8b 55 f8             	mov    -0x8(%ebp),%edx
 41c:	8a 12                	mov    (%edx),%dl
 41e:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 420:	8d 45 d8             	lea    -0x28(%ebp),%eax
 423:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 426:	77 e5                	ja     40d <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 428:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 42b:	83 c4 30             	add    $0x30,%esp
 42e:	5b                   	pop    %ebx
 42f:	5d                   	pop    %ebp
 430:	c3                   	ret    
 431:	90                   	nop
 432:	90                   	nop
 433:	90                   	nop

00000434 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 434:	b8 01 00 00 00       	mov    $0x1,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <exit>:
SYSCALL(exit)
 43c:	b8 02 00 00 00       	mov    $0x2,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <wait>:
SYSCALL(wait)
 444:	b8 03 00 00 00       	mov    $0x3,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <pipe>:
SYSCALL(pipe)
 44c:	b8 04 00 00 00       	mov    $0x4,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <read>:
SYSCALL(read)
 454:	b8 05 00 00 00       	mov    $0x5,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <write>:
SYSCALL(write)
 45c:	b8 10 00 00 00       	mov    $0x10,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <close>:
SYSCALL(close)
 464:	b8 15 00 00 00       	mov    $0x15,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <kill>:
SYSCALL(kill)
 46c:	b8 06 00 00 00       	mov    $0x6,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <exec>:
SYSCALL(exec)
 474:	b8 07 00 00 00       	mov    $0x7,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <open>:
SYSCALL(open)
 47c:	b8 0f 00 00 00       	mov    $0xf,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <mknod>:
SYSCALL(mknod)
 484:	b8 11 00 00 00       	mov    $0x11,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <unlink>:
SYSCALL(unlink)
 48c:	b8 12 00 00 00       	mov    $0x12,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <fstat>:
SYSCALL(fstat)
 494:	b8 08 00 00 00       	mov    $0x8,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <link>:
SYSCALL(link)
 49c:	b8 13 00 00 00       	mov    $0x13,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <mkdir>:
SYSCALL(mkdir)
 4a4:	b8 14 00 00 00       	mov    $0x14,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <chdir>:
SYSCALL(chdir)
 4ac:	b8 09 00 00 00       	mov    $0x9,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <dup>:
SYSCALL(dup)
 4b4:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <getpid>:
SYSCALL(getpid)
 4bc:	b8 0b 00 00 00       	mov    $0xb,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <sbrk>:
SYSCALL(sbrk)
 4c4:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <sleep>:
SYSCALL(sleep)
 4cc:	b8 0d 00 00 00       	mov    $0xd,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <uptime>:
SYSCALL(uptime)
 4d4:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <getticks>:
SYSCALL(getticks)
 4dc:	b8 16 00 00 00       	mov    $0x16,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <get_name>:
SYSCALL(get_name)
 4e4:	b8 17 00 00 00       	mov    $0x17,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <get_max_proc>:
SYSCALL(get_max_proc)
 4ec:	b8 18 00 00 00       	mov    $0x18,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <get_max_mem>:
SYSCALL(get_max_mem)
 4f4:	b8 19 00 00 00       	mov    $0x19,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <get_max_disk>:
SYSCALL(get_max_disk)
 4fc:	b8 1a 00 00 00       	mov    $0x1a,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <get_curr_proc>:
SYSCALL(get_curr_proc)
 504:	b8 1b 00 00 00       	mov    $0x1b,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <get_curr_mem>:
SYSCALL(get_curr_mem)
 50c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <get_curr_disk>:
SYSCALL(get_curr_disk)
 514:	b8 1d 00 00 00       	mov    $0x1d,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <set_name>:
SYSCALL(set_name)
 51c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <set_max_mem>:
SYSCALL(set_max_mem)
 524:	b8 1f 00 00 00       	mov    $0x1f,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <set_max_disk>:
SYSCALL(set_max_disk)
 52c:	b8 20 00 00 00       	mov    $0x20,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <set_max_proc>:
SYSCALL(set_max_proc)
 534:	b8 21 00 00 00       	mov    $0x21,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <set_curr_mem>:
SYSCALL(set_curr_mem)
 53c:	b8 22 00 00 00       	mov    $0x22,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <set_curr_disk>:
SYSCALL(set_curr_disk)
 544:	b8 23 00 00 00       	mov    $0x23,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <set_curr_proc>:
SYSCALL(set_curr_proc)
 54c:	b8 24 00 00 00       	mov    $0x24,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <find>:
SYSCALL(find)
 554:	b8 25 00 00 00       	mov    $0x25,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <is_full>:
SYSCALL(is_full)
 55c:	b8 26 00 00 00       	mov    $0x26,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <container_init>:
SYSCALL(container_init)
 564:	b8 27 00 00 00       	mov    $0x27,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <cont_proc_set>:
SYSCALL(cont_proc_set)
 56c:	b8 28 00 00 00       	mov    $0x28,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <ps>:
SYSCALL(ps)
 574:	b8 29 00 00 00       	mov    $0x29,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 57c:	b8 2a 00 00 00       	mov    $0x2a,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <set_root_inode>:
SYSCALL(set_root_inode)
 584:	b8 2b 00 00 00       	mov    $0x2b,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <cstop>:
SYSCALL(cstop)
 58c:	b8 2c 00 00 00       	mov    $0x2c,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <df>:
SYSCALL(df)
 594:	b8 2d 00 00 00       	mov    $0x2d,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <max_containers>:
SYSCALL(max_containers)
 59c:	b8 2e 00 00 00       	mov    $0x2e,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <container_reset>:
SYSCALL(container_reset)
 5a4:	b8 2f 00 00 00       	mov    $0x2f,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <pause>:
SYSCALL(pause)
 5ac:	b8 30 00 00 00       	mov    $0x30,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <resume>:
SYSCALL(resume)
 5b4:	b8 31 00 00 00       	mov    $0x31,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <tmem>:
SYSCALL(tmem)
 5bc:	b8 32 00 00 00       	mov    $0x32,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <amem>:
SYSCALL(amem)
 5c4:	b8 33 00 00 00       	mov    $0x33,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <c_ps>:
SYSCALL(c_ps)
 5cc:	b8 34 00 00 00       	mov    $0x34,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <get_used>:
SYSCALL(get_used)
 5d4:	b8 35 00 00 00       	mov    $0x35,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <get_os>:
SYSCALL(get_os)
 5dc:	b8 36 00 00 00       	mov    $0x36,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <set_os>:
SYSCALL(set_os)
 5e4:	b8 37 00 00 00       	mov    $0x37,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ec:	55                   	push   %ebp
 5ed:	89 e5                	mov    %esp,%ebp
 5ef:	83 ec 18             	sub    $0x18,%esp
 5f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5ff:	00 
 600:	8d 45 f4             	lea    -0xc(%ebp),%eax
 603:	89 44 24 04          	mov    %eax,0x4(%esp)
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	89 04 24             	mov    %eax,(%esp)
 60d:	e8 4a fe ff ff       	call   45c <write>
}
 612:	c9                   	leave  
 613:	c3                   	ret    

00000614 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 614:	55                   	push   %ebp
 615:	89 e5                	mov    %esp,%ebp
 617:	56                   	push   %esi
 618:	53                   	push   %ebx
 619:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 61c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 623:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 627:	74 17                	je     640 <printint+0x2c>
 629:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 62d:	79 11                	jns    640 <printint+0x2c>
    neg = 1;
 62f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 636:	8b 45 0c             	mov    0xc(%ebp),%eax
 639:	f7 d8                	neg    %eax
 63b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63e:	eb 06                	jmp    646 <printint+0x32>
  } else {
    x = xx;
 640:	8b 45 0c             	mov    0xc(%ebp),%eax
 643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 64d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 650:	8d 41 01             	lea    0x1(%ecx),%eax
 653:	89 45 f4             	mov    %eax,-0xc(%ebp)
 656:	8b 5d 10             	mov    0x10(%ebp),%ebx
 659:	8b 45 ec             	mov    -0x14(%ebp),%eax
 65c:	ba 00 00 00 00       	mov    $0x0,%edx
 661:	f7 f3                	div    %ebx
 663:	89 d0                	mov    %edx,%eax
 665:	8a 80 44 0d 00 00    	mov    0xd44(%eax),%al
 66b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 66f:	8b 75 10             	mov    0x10(%ebp),%esi
 672:	8b 45 ec             	mov    -0x14(%ebp),%eax
 675:	ba 00 00 00 00       	mov    $0x0,%edx
 67a:	f7 f6                	div    %esi
 67c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 683:	75 c8                	jne    64d <printint+0x39>
  if(neg)
 685:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 689:	74 10                	je     69b <printint+0x87>
    buf[i++] = '-';
 68b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68e:	8d 50 01             	lea    0x1(%eax),%edx
 691:	89 55 f4             	mov    %edx,-0xc(%ebp)
 694:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 699:	eb 1e                	jmp    6b9 <printint+0xa5>
 69b:	eb 1c                	jmp    6b9 <printint+0xa5>
    putc(fd, buf[i]);
 69d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a3:	01 d0                	add    %edx,%eax
 6a5:	8a 00                	mov    (%eax),%al
 6a7:	0f be c0             	movsbl %al,%eax
 6aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	89 04 24             	mov    %eax,(%esp)
 6b4:	e8 33 ff ff ff       	call   5ec <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6b9:	ff 4d f4             	decl   -0xc(%ebp)
 6bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c0:	79 db                	jns    69d <printint+0x89>
    putc(fd, buf[i]);
}
 6c2:	83 c4 30             	add    $0x30,%esp
 6c5:	5b                   	pop    %ebx
 6c6:	5e                   	pop    %esi
 6c7:	5d                   	pop    %ebp
 6c8:	c3                   	ret    

000006c9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6c9:	55                   	push   %ebp
 6ca:	89 e5                	mov    %esp,%ebp
 6cc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6d6:	8d 45 0c             	lea    0xc(%ebp),%eax
 6d9:	83 c0 04             	add    $0x4,%eax
 6dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6e6:	e9 77 01 00 00       	jmp    862 <printf+0x199>
    c = fmt[i] & 0xff;
 6eb:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f1:	01 d0                	add    %edx,%eax
 6f3:	8a 00                	mov    (%eax),%al
 6f5:	0f be c0             	movsbl %al,%eax
 6f8:	25 ff 00 00 00       	and    $0xff,%eax
 6fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 700:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 704:	75 2c                	jne    732 <printf+0x69>
      if(c == '%'){
 706:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 70a:	75 0c                	jne    718 <printf+0x4f>
        state = '%';
 70c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 713:	e9 47 01 00 00       	jmp    85f <printf+0x196>
      } else {
        putc(fd, c);
 718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71b:	0f be c0             	movsbl %al,%eax
 71e:	89 44 24 04          	mov    %eax,0x4(%esp)
 722:	8b 45 08             	mov    0x8(%ebp),%eax
 725:	89 04 24             	mov    %eax,(%esp)
 728:	e8 bf fe ff ff       	call   5ec <putc>
 72d:	e9 2d 01 00 00       	jmp    85f <printf+0x196>
      }
    } else if(state == '%'){
 732:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 736:	0f 85 23 01 00 00    	jne    85f <printf+0x196>
      if(c == 'd'){
 73c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 740:	75 2d                	jne    76f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 742:	8b 45 e8             	mov    -0x18(%ebp),%eax
 745:	8b 00                	mov    (%eax),%eax
 747:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 74e:	00 
 74f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 756:	00 
 757:	89 44 24 04          	mov    %eax,0x4(%esp)
 75b:	8b 45 08             	mov    0x8(%ebp),%eax
 75e:	89 04 24             	mov    %eax,(%esp)
 761:	e8 ae fe ff ff       	call   614 <printint>
        ap++;
 766:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76a:	e9 e9 00 00 00       	jmp    858 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 76f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 773:	74 06                	je     77b <printf+0xb2>
 775:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 779:	75 2d                	jne    7a8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 77b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77e:	8b 00                	mov    (%eax),%eax
 780:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 787:	00 
 788:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 78f:	00 
 790:	89 44 24 04          	mov    %eax,0x4(%esp)
 794:	8b 45 08             	mov    0x8(%ebp),%eax
 797:	89 04 24             	mov    %eax,(%esp)
 79a:	e8 75 fe ff ff       	call   614 <printint>
        ap++;
 79f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a3:	e9 b0 00 00 00       	jmp    858 <printf+0x18f>
      } else if(c == 's'){
 7a8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ac:	75 42                	jne    7f0 <printf+0x127>
        s = (char*)*ap;
 7ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7be:	75 09                	jne    7c9 <printf+0x100>
          s = "(null)";
 7c0:	c7 45 f4 d3 0a 00 00 	movl   $0xad3,-0xc(%ebp)
        while(*s != 0){
 7c7:	eb 1c                	jmp    7e5 <printf+0x11c>
 7c9:	eb 1a                	jmp    7e5 <printf+0x11c>
          putc(fd, *s);
 7cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ce:	8a 00                	mov    (%eax),%al
 7d0:	0f be c0             	movsbl %al,%eax
 7d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d7:	8b 45 08             	mov    0x8(%ebp),%eax
 7da:	89 04 24             	mov    %eax,(%esp)
 7dd:	e8 0a fe ff ff       	call   5ec <putc>
          s++;
 7e2:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8a 00                	mov    (%eax),%al
 7ea:	84 c0                	test   %al,%al
 7ec:	75 dd                	jne    7cb <printf+0x102>
 7ee:	eb 68                	jmp    858 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7f0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7f4:	75 1d                	jne    813 <printf+0x14a>
        putc(fd, *ap);
 7f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f9:	8b 00                	mov    (%eax),%eax
 7fb:	0f be c0             	movsbl %al,%eax
 7fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 802:	8b 45 08             	mov    0x8(%ebp),%eax
 805:	89 04 24             	mov    %eax,(%esp)
 808:	e8 df fd ff ff       	call   5ec <putc>
        ap++;
 80d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 811:	eb 45                	jmp    858 <printf+0x18f>
      } else if(c == '%'){
 813:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 817:	75 17                	jne    830 <printf+0x167>
        putc(fd, c);
 819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 81c:	0f be c0             	movsbl %al,%eax
 81f:	89 44 24 04          	mov    %eax,0x4(%esp)
 823:	8b 45 08             	mov    0x8(%ebp),%eax
 826:	89 04 24             	mov    %eax,(%esp)
 829:	e8 be fd ff ff       	call   5ec <putc>
 82e:	eb 28                	jmp    858 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 830:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 837:	00 
 838:	8b 45 08             	mov    0x8(%ebp),%eax
 83b:	89 04 24             	mov    %eax,(%esp)
 83e:	e8 a9 fd ff ff       	call   5ec <putc>
        putc(fd, c);
 843:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 846:	0f be c0             	movsbl %al,%eax
 849:	89 44 24 04          	mov    %eax,0x4(%esp)
 84d:	8b 45 08             	mov    0x8(%ebp),%eax
 850:	89 04 24             	mov    %eax,(%esp)
 853:	e8 94 fd ff ff       	call   5ec <putc>
      }
      state = 0;
 858:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 85f:	ff 45 f0             	incl   -0x10(%ebp)
 862:	8b 55 0c             	mov    0xc(%ebp),%edx
 865:	8b 45 f0             	mov    -0x10(%ebp),%eax
 868:	01 d0                	add    %edx,%eax
 86a:	8a 00                	mov    (%eax),%al
 86c:	84 c0                	test   %al,%al
 86e:	0f 85 77 fe ff ff    	jne    6eb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 874:	c9                   	leave  
 875:	c3                   	ret    
 876:	90                   	nop
 877:	90                   	nop

00000878 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 878:	55                   	push   %ebp
 879:	89 e5                	mov    %esp,%ebp
 87b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87e:	8b 45 08             	mov    0x8(%ebp),%eax
 881:	83 e8 08             	sub    $0x8,%eax
 884:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 887:	a1 60 0d 00 00       	mov    0xd60,%eax
 88c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 88f:	eb 24                	jmp    8b5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 00                	mov    (%eax),%eax
 896:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 899:	77 12                	ja     8ad <free+0x35>
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a1:	77 24                	ja     8c7 <free+0x4f>
 8a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a6:	8b 00                	mov    (%eax),%eax
 8a8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ab:	77 1a                	ja     8c7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	8b 00                	mov    (%eax),%eax
 8b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8bb:	76 d4                	jbe    891 <free+0x19>
 8bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c0:	8b 00                	mov    (%eax),%eax
 8c2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8c5:	76 ca                	jbe    891 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ca:	8b 40 04             	mov    0x4(%eax),%eax
 8cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d7:	01 c2                	add    %eax,%edx
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8b 00                	mov    (%eax),%eax
 8de:	39 c2                	cmp    %eax,%edx
 8e0:	75 24                	jne    906 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e5:	8b 50 04             	mov    0x4(%eax),%edx
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8eb:	8b 00                	mov    (%eax),%eax
 8ed:	8b 40 04             	mov    0x4(%eax),%eax
 8f0:	01 c2                	add    %eax,%edx
 8f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 00                	mov    (%eax),%eax
 8fd:	8b 10                	mov    (%eax),%edx
 8ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 902:	89 10                	mov    %edx,(%eax)
 904:	eb 0a                	jmp    910 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 906:	8b 45 fc             	mov    -0x4(%ebp),%eax
 909:	8b 10                	mov    (%eax),%edx
 90b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 910:	8b 45 fc             	mov    -0x4(%ebp),%eax
 913:	8b 40 04             	mov    0x4(%eax),%eax
 916:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	01 d0                	add    %edx,%eax
 922:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 925:	75 20                	jne    947 <free+0xcf>
    p->s.size += bp->s.size;
 927:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92a:	8b 50 04             	mov    0x4(%eax),%edx
 92d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 930:	8b 40 04             	mov    0x4(%eax),%eax
 933:	01 c2                	add    %eax,%edx
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 93b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93e:	8b 10                	mov    (%eax),%edx
 940:	8b 45 fc             	mov    -0x4(%ebp),%eax
 943:	89 10                	mov    %edx,(%eax)
 945:	eb 08                	jmp    94f <free+0xd7>
  } else
    p->s.ptr = bp;
 947:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 94d:	89 10                	mov    %edx,(%eax)
  freep = p;
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	a3 60 0d 00 00       	mov    %eax,0xd60
}
 957:	c9                   	leave  
 958:	c3                   	ret    

00000959 <morecore>:

static Header*
morecore(uint nu)
{
 959:	55                   	push   %ebp
 95a:	89 e5                	mov    %esp,%ebp
 95c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 95f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 966:	77 07                	ja     96f <morecore+0x16>
    nu = 4096;
 968:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 96f:	8b 45 08             	mov    0x8(%ebp),%eax
 972:	c1 e0 03             	shl    $0x3,%eax
 975:	89 04 24             	mov    %eax,(%esp)
 978:	e8 47 fb ff ff       	call   4c4 <sbrk>
 97d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 980:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 984:	75 07                	jne    98d <morecore+0x34>
    return 0;
 986:	b8 00 00 00 00       	mov    $0x0,%eax
 98b:	eb 22                	jmp    9af <morecore+0x56>
  hp = (Header*)p;
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 993:	8b 45 f0             	mov    -0x10(%ebp),%eax
 996:	8b 55 08             	mov    0x8(%ebp),%edx
 999:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 99c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99f:	83 c0 08             	add    $0x8,%eax
 9a2:	89 04 24             	mov    %eax,(%esp)
 9a5:	e8 ce fe ff ff       	call   878 <free>
  return freep;
 9aa:	a1 60 0d 00 00       	mov    0xd60,%eax
}
 9af:	c9                   	leave  
 9b0:	c3                   	ret    

000009b1 <malloc>:

void*
malloc(uint nbytes)
{
 9b1:	55                   	push   %ebp
 9b2:	89 e5                	mov    %esp,%ebp
 9b4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ba:	83 c0 07             	add    $0x7,%eax
 9bd:	c1 e8 03             	shr    $0x3,%eax
 9c0:	40                   	inc    %eax
 9c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9c4:	a1 60 0d 00 00       	mov    0xd60,%eax
 9c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9d0:	75 23                	jne    9f5 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 9d2:	c7 45 f0 58 0d 00 00 	movl   $0xd58,-0x10(%ebp)
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	a3 60 0d 00 00       	mov    %eax,0xd60
 9e1:	a1 60 0d 00 00       	mov    0xd60,%eax
 9e6:	a3 58 0d 00 00       	mov    %eax,0xd58
    base.s.size = 0;
 9eb:	c7 05 5c 0d 00 00 00 	movl   $0x0,0xd5c
 9f2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f8:	8b 00                	mov    (%eax),%eax
 9fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a00:	8b 40 04             	mov    0x4(%eax),%eax
 a03:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a06:	72 4d                	jb     a55 <malloc+0xa4>
      if(p->s.size == nunits)
 a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0b:	8b 40 04             	mov    0x4(%eax),%eax
 a0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a11:	75 0c                	jne    a1f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a16:	8b 10                	mov    (%eax),%edx
 a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1b:	89 10                	mov    %edx,(%eax)
 a1d:	eb 26                	jmp    a45 <malloc+0x94>
      else {
        p->s.size -= nunits;
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	8b 40 04             	mov    0x4(%eax),%eax
 a25:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a28:	89 c2                	mov    %eax,%edx
 a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	8b 40 04             	mov    0x4(%eax),%eax
 a36:	c1 e0 03             	shl    $0x3,%eax
 a39:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a42:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a48:	a3 60 0d 00 00       	mov    %eax,0xd60
      return (void*)(p + 1);
 a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a50:	83 c0 08             	add    $0x8,%eax
 a53:	eb 38                	jmp    a8d <malloc+0xdc>
    }
    if(p == freep)
 a55:	a1 60 0d 00 00       	mov    0xd60,%eax
 a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a5d:	75 1b                	jne    a7a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a62:	89 04 24             	mov    %eax,(%esp)
 a65:	e8 ef fe ff ff       	call   959 <morecore>
 a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a71:	75 07                	jne    a7a <malloc+0xc9>
        return 0;
 a73:	b8 00 00 00 00       	mov    $0x0,%eax
 a78:	eb 13                	jmp    a8d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a83:	8b 00                	mov    (%eax),%eax
 a85:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a88:	e9 70 ff ff ff       	jmp    9fd <malloc+0x4c>
}
 a8d:	c9                   	leave  
 a8e:	c3                   	ret    
