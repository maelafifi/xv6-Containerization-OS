
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
   f:	c7 44 24 04 9f 0a 00 	movl   $0xa9f,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 b6 06 00 00       	call   6d9 <printf>
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
  8f:	c7 44 24 04 b3 0a 00 	movl   $0xab3,0x4(%esp)
  96:	00 
  97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9e:	e8 36 06 00 00       	call   6d9 <printf>
  printf(1, "t1    = %d\n", t1);
  a3:	8b 44 24 20          	mov    0x20(%esp),%eax
  a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  ab:	c7 44 24 04 bf 0a 00 	movl   $0xabf,0x4(%esp)
  b2:	00 
  b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ba:	e8 1a 06 00 00       	call   6d9 <printf>
  printf(1, "t2    = %d\n", t2);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  c7:	c7 44 24 04 cb 0a 00 	movl   $0xacb,0x4(%esp)
  ce:	00 
  cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d6:	e8 fe 05 00 00       	call   6d9 <printf>
  printf(1, "t2-t1 = %d\n", t2-t1);    
  db:	8b 44 24 20          	mov    0x20(%esp),%eax
  df:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  e3:	29 c2                	sub    %eax,%edx
  e5:	89 d0                	mov    %edx,%eax
  e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  eb:	c7 44 24 04 d7 0a 00 	movl   $0xad7,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 da 05 00 00       	call   6d9 <printf>

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

000005ec <get_cticks>:
SYSCALL(get_cticks)
 5ec:	b8 38 00 00 00       	mov    $0x38,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <tick_reset2>:
SYSCALL(tick_reset2)
 5f4:	b8 39 00 00 00       	mov    $0x39,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5fc:	55                   	push   %ebp
 5fd:	89 e5                	mov    %esp,%ebp
 5ff:	83 ec 18             	sub    $0x18,%esp
 602:	8b 45 0c             	mov    0xc(%ebp),%eax
 605:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 608:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 60f:	00 
 610:	8d 45 f4             	lea    -0xc(%ebp),%eax
 613:	89 44 24 04          	mov    %eax,0x4(%esp)
 617:	8b 45 08             	mov    0x8(%ebp),%eax
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 3a fe ff ff       	call   45c <write>
}
 622:	c9                   	leave  
 623:	c3                   	ret    

00000624 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	56                   	push   %esi
 628:	53                   	push   %ebx
 629:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 62c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 633:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 637:	74 17                	je     650 <printint+0x2c>
 639:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 63d:	79 11                	jns    650 <printint+0x2c>
    neg = 1;
 63f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 646:	8b 45 0c             	mov    0xc(%ebp),%eax
 649:	f7 d8                	neg    %eax
 64b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 64e:	eb 06                	jmp    656 <printint+0x32>
  } else {
    x = xx;
 650:	8b 45 0c             	mov    0xc(%ebp),%eax
 653:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 656:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 65d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 660:	8d 41 01             	lea    0x1(%ecx),%eax
 663:	89 45 f4             	mov    %eax,-0xc(%ebp)
 666:	8b 5d 10             	mov    0x10(%ebp),%ebx
 669:	8b 45 ec             	mov    -0x14(%ebp),%eax
 66c:	ba 00 00 00 00       	mov    $0x0,%edx
 671:	f7 f3                	div    %ebx
 673:	89 d0                	mov    %edx,%eax
 675:	8a 80 54 0d 00 00    	mov    0xd54(%eax),%al
 67b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 67f:	8b 75 10             	mov    0x10(%ebp),%esi
 682:	8b 45 ec             	mov    -0x14(%ebp),%eax
 685:	ba 00 00 00 00       	mov    $0x0,%edx
 68a:	f7 f6                	div    %esi
 68c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 68f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 693:	75 c8                	jne    65d <printint+0x39>
  if(neg)
 695:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 699:	74 10                	je     6ab <printint+0x87>
    buf[i++] = '-';
 69b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69e:	8d 50 01             	lea    0x1(%eax),%edx
 6a1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6a9:	eb 1e                	jmp    6c9 <printint+0xa5>
 6ab:	eb 1c                	jmp    6c9 <printint+0xa5>
    putc(fd, buf[i]);
 6ad:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b3:	01 d0                	add    %edx,%eax
 6b5:	8a 00                	mov    (%eax),%al
 6b7:	0f be c0             	movsbl %al,%eax
 6ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 6be:	8b 45 08             	mov    0x8(%ebp),%eax
 6c1:	89 04 24             	mov    %eax,(%esp)
 6c4:	e8 33 ff ff ff       	call   5fc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6c9:	ff 4d f4             	decl   -0xc(%ebp)
 6cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d0:	79 db                	jns    6ad <printint+0x89>
    putc(fd, buf[i]);
}
 6d2:	83 c4 30             	add    $0x30,%esp
 6d5:	5b                   	pop    %ebx
 6d6:	5e                   	pop    %esi
 6d7:	5d                   	pop    %ebp
 6d8:	c3                   	ret    

000006d9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6d9:	55                   	push   %ebp
 6da:	89 e5                	mov    %esp,%ebp
 6dc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6e6:	8d 45 0c             	lea    0xc(%ebp),%eax
 6e9:	83 c0 04             	add    $0x4,%eax
 6ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6f6:	e9 77 01 00 00       	jmp    872 <printf+0x199>
    c = fmt[i] & 0xff;
 6fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 6fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 701:	01 d0                	add    %edx,%eax
 703:	8a 00                	mov    (%eax),%al
 705:	0f be c0             	movsbl %al,%eax
 708:	25 ff 00 00 00       	and    $0xff,%eax
 70d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 710:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 714:	75 2c                	jne    742 <printf+0x69>
      if(c == '%'){
 716:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 71a:	75 0c                	jne    728 <printf+0x4f>
        state = '%';
 71c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 723:	e9 47 01 00 00       	jmp    86f <printf+0x196>
      } else {
        putc(fd, c);
 728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72b:	0f be c0             	movsbl %al,%eax
 72e:	89 44 24 04          	mov    %eax,0x4(%esp)
 732:	8b 45 08             	mov    0x8(%ebp),%eax
 735:	89 04 24             	mov    %eax,(%esp)
 738:	e8 bf fe ff ff       	call   5fc <putc>
 73d:	e9 2d 01 00 00       	jmp    86f <printf+0x196>
      }
    } else if(state == '%'){
 742:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 746:	0f 85 23 01 00 00    	jne    86f <printf+0x196>
      if(c == 'd'){
 74c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 750:	75 2d                	jne    77f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 752:	8b 45 e8             	mov    -0x18(%ebp),%eax
 755:	8b 00                	mov    (%eax),%eax
 757:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 75e:	00 
 75f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 766:	00 
 767:	89 44 24 04          	mov    %eax,0x4(%esp)
 76b:	8b 45 08             	mov    0x8(%ebp),%eax
 76e:	89 04 24             	mov    %eax,(%esp)
 771:	e8 ae fe ff ff       	call   624 <printint>
        ap++;
 776:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 77a:	e9 e9 00 00 00       	jmp    868 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 77f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 783:	74 06                	je     78b <printf+0xb2>
 785:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 789:	75 2d                	jne    7b8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 78b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 797:	00 
 798:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 79f:	00 
 7a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a4:	8b 45 08             	mov    0x8(%ebp),%eax
 7a7:	89 04 24             	mov    %eax,(%esp)
 7aa:	e8 75 fe ff ff       	call   624 <printint>
        ap++;
 7af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b3:	e9 b0 00 00 00       	jmp    868 <printf+0x18f>
      } else if(c == 's'){
 7b8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7bc:	75 42                	jne    800 <printf+0x127>
        s = (char*)*ap;
 7be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c1:	8b 00                	mov    (%eax),%eax
 7c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ce:	75 09                	jne    7d9 <printf+0x100>
          s = "(null)";
 7d0:	c7 45 f4 e3 0a 00 00 	movl   $0xae3,-0xc(%ebp)
        while(*s != 0){
 7d7:	eb 1c                	jmp    7f5 <printf+0x11c>
 7d9:	eb 1a                	jmp    7f5 <printf+0x11c>
          putc(fd, *s);
 7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7de:	8a 00                	mov    (%eax),%al
 7e0:	0f be c0             	movsbl %al,%eax
 7e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	89 04 24             	mov    %eax,(%esp)
 7ed:	e8 0a fe ff ff       	call   5fc <putc>
          s++;
 7f2:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	8a 00                	mov    (%eax),%al
 7fa:	84 c0                	test   %al,%al
 7fc:	75 dd                	jne    7db <printf+0x102>
 7fe:	eb 68                	jmp    868 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 800:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 804:	75 1d                	jne    823 <printf+0x14a>
        putc(fd, *ap);
 806:	8b 45 e8             	mov    -0x18(%ebp),%eax
 809:	8b 00                	mov    (%eax),%eax
 80b:	0f be c0             	movsbl %al,%eax
 80e:	89 44 24 04          	mov    %eax,0x4(%esp)
 812:	8b 45 08             	mov    0x8(%ebp),%eax
 815:	89 04 24             	mov    %eax,(%esp)
 818:	e8 df fd ff ff       	call   5fc <putc>
        ap++;
 81d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 821:	eb 45                	jmp    868 <printf+0x18f>
      } else if(c == '%'){
 823:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 827:	75 17                	jne    840 <printf+0x167>
        putc(fd, c);
 829:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 82c:	0f be c0             	movsbl %al,%eax
 82f:	89 44 24 04          	mov    %eax,0x4(%esp)
 833:	8b 45 08             	mov    0x8(%ebp),%eax
 836:	89 04 24             	mov    %eax,(%esp)
 839:	e8 be fd ff ff       	call   5fc <putc>
 83e:	eb 28                	jmp    868 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 840:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 847:	00 
 848:	8b 45 08             	mov    0x8(%ebp),%eax
 84b:	89 04 24             	mov    %eax,(%esp)
 84e:	e8 a9 fd ff ff       	call   5fc <putc>
        putc(fd, c);
 853:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 856:	0f be c0             	movsbl %al,%eax
 859:	89 44 24 04          	mov    %eax,0x4(%esp)
 85d:	8b 45 08             	mov    0x8(%ebp),%eax
 860:	89 04 24             	mov    %eax,(%esp)
 863:	e8 94 fd ff ff       	call   5fc <putc>
      }
      state = 0;
 868:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 86f:	ff 45 f0             	incl   -0x10(%ebp)
 872:	8b 55 0c             	mov    0xc(%ebp),%edx
 875:	8b 45 f0             	mov    -0x10(%ebp),%eax
 878:	01 d0                	add    %edx,%eax
 87a:	8a 00                	mov    (%eax),%al
 87c:	84 c0                	test   %al,%al
 87e:	0f 85 77 fe ff ff    	jne    6fb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 884:	c9                   	leave  
 885:	c3                   	ret    
 886:	90                   	nop
 887:	90                   	nop

00000888 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 888:	55                   	push   %ebp
 889:	89 e5                	mov    %esp,%ebp
 88b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88e:	8b 45 08             	mov    0x8(%ebp),%eax
 891:	83 e8 08             	sub    $0x8,%eax
 894:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 897:	a1 70 0d 00 00       	mov    0xd70,%eax
 89c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 89f:	eb 24                	jmp    8c5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a9:	77 12                	ja     8bd <free+0x35>
 8ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8b1:	77 24                	ja     8d7 <free+0x4f>
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	8b 00                	mov    (%eax),%eax
 8b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8bb:	77 1a                	ja     8d7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c0:	8b 00                	mov    (%eax),%eax
 8c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8cb:	76 d4                	jbe    8a1 <free+0x19>
 8cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8d5:	76 ca                	jbe    8a1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	8b 40 04             	mov    0x4(%eax),%eax
 8dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e7:	01 c2                	add    %eax,%edx
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 00                	mov    (%eax),%eax
 8ee:	39 c2                	cmp    %eax,%edx
 8f0:	75 24                	jne    916 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f5:	8b 50 04             	mov    0x4(%eax),%edx
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 00                	mov    (%eax),%eax
 8fd:	8b 40 04             	mov    0x4(%eax),%eax
 900:	01 c2                	add    %eax,%edx
 902:	8b 45 f8             	mov    -0x8(%ebp),%eax
 905:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	8b 10                	mov    (%eax),%edx
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	89 10                	mov    %edx,(%eax)
 914:	eb 0a                	jmp    920 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	8b 10                	mov    (%eax),%edx
 91b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 920:	8b 45 fc             	mov    -0x4(%ebp),%eax
 923:	8b 40 04             	mov    0x4(%eax),%eax
 926:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 92d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 930:	01 d0                	add    %edx,%eax
 932:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 935:	75 20                	jne    957 <free+0xcf>
    p->s.size += bp->s.size;
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	8b 50 04             	mov    0x4(%eax),%edx
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	01 c2                	add    %eax,%edx
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	8b 10                	mov    (%eax),%edx
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	89 10                	mov    %edx,(%eax)
 955:	eb 08                	jmp    95f <free+0xd7>
  } else
    p->s.ptr = bp;
 957:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 95d:	89 10                	mov    %edx,(%eax)
  freep = p;
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	a3 70 0d 00 00       	mov    %eax,0xd70
}
 967:	c9                   	leave  
 968:	c3                   	ret    

00000969 <morecore>:

static Header*
morecore(uint nu)
{
 969:	55                   	push   %ebp
 96a:	89 e5                	mov    %esp,%ebp
 96c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 96f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 976:	77 07                	ja     97f <morecore+0x16>
    nu = 4096;
 978:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 97f:	8b 45 08             	mov    0x8(%ebp),%eax
 982:	c1 e0 03             	shl    $0x3,%eax
 985:	89 04 24             	mov    %eax,(%esp)
 988:	e8 37 fb ff ff       	call   4c4 <sbrk>
 98d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 990:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 994:	75 07                	jne    99d <morecore+0x34>
    return 0;
 996:	b8 00 00 00 00       	mov    $0x0,%eax
 99b:	eb 22                	jmp    9bf <morecore+0x56>
  hp = (Header*)p;
 99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a6:	8b 55 08             	mov    0x8(%ebp),%edx
 9a9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9af:	83 c0 08             	add    $0x8,%eax
 9b2:	89 04 24             	mov    %eax,(%esp)
 9b5:	e8 ce fe ff ff       	call   888 <free>
  return freep;
 9ba:	a1 70 0d 00 00       	mov    0xd70,%eax
}
 9bf:	c9                   	leave  
 9c0:	c3                   	ret    

000009c1 <malloc>:

void*
malloc(uint nbytes)
{
 9c1:	55                   	push   %ebp
 9c2:	89 e5                	mov    %esp,%ebp
 9c4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ca:	83 c0 07             	add    $0x7,%eax
 9cd:	c1 e8 03             	shr    $0x3,%eax
 9d0:	40                   	inc    %eax
 9d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9d4:	a1 70 0d 00 00       	mov    0xd70,%eax
 9d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9e0:	75 23                	jne    a05 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 9e2:	c7 45 f0 68 0d 00 00 	movl   $0xd68,-0x10(%ebp)
 9e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ec:	a3 70 0d 00 00       	mov    %eax,0xd70
 9f1:	a1 70 0d 00 00       	mov    0xd70,%eax
 9f6:	a3 68 0d 00 00       	mov    %eax,0xd68
    base.s.size = 0;
 9fb:	c7 05 6c 0d 00 00 00 	movl   $0x0,0xd6c
 a02:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	8b 00                	mov    (%eax),%eax
 a0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a10:	8b 40 04             	mov    0x4(%eax),%eax
 a13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a16:	72 4d                	jb     a65 <malloc+0xa4>
      if(p->s.size == nunits)
 a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1b:	8b 40 04             	mov    0x4(%eax),%eax
 a1e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a21:	75 0c                	jne    a2f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	8b 10                	mov    (%eax),%edx
 a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2b:	89 10                	mov    %edx,(%eax)
 a2d:	eb 26                	jmp    a55 <malloc+0x94>
      else {
        p->s.size -= nunits;
 a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a32:	8b 40 04             	mov    0x4(%eax),%eax
 a35:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a38:	89 c2                	mov    %eax,%edx
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a43:	8b 40 04             	mov    0x4(%eax),%eax
 a46:	c1 e0 03             	shl    $0x3,%eax
 a49:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a52:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a58:	a3 70 0d 00 00       	mov    %eax,0xd70
      return (void*)(p + 1);
 a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a60:	83 c0 08             	add    $0x8,%eax
 a63:	eb 38                	jmp    a9d <malloc+0xdc>
    }
    if(p == freep)
 a65:	a1 70 0d 00 00       	mov    0xd70,%eax
 a6a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a6d:	75 1b                	jne    a8a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a72:	89 04 24             	mov    %eax,(%esp)
 a75:	e8 ef fe ff ff       	call   969 <morecore>
 a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a81:	75 07                	jne    a8a <malloc+0xc9>
        return 0;
 a83:	b8 00 00 00 00       	mov    $0x0,%eax
 a88:	eb 13                	jmp    a9d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a93:	8b 00                	mov    (%eax),%eax
 a95:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a98:	e9 70 ff ff ff       	jmp    a0d <malloc+0x4c>
}
 a9d:	c9                   	leave  
 a9e:	c3                   	ret    
