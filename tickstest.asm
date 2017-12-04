
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
   f:	c7 44 24 04 93 09 00 	movl   $0x993,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 aa 05 00 00       	call   5cd <printf>
  	exit();
  23:	e8 30 03 00 00       	call   358 <exit>
  }

  n = atoi(argv[1]);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	89 04 24             	mov    %eax,(%esp)
  33:	e8 8f 02 00 00       	call   2c7 <atoi>
  38:	89 44 24 24          	mov    %eax,0x24(%esp)

  t1 = uptime();
  3c:	e8 af 03 00 00       	call   3f0 <uptime>
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
  75:	e8 76 03 00 00       	call   3f0 <uptime>
  7a:	89 44 24 1c          	mov    %eax,0x1c(%esp)

  ticks = getticks();
  7e:	e8 75 03 00 00       	call   3f8 <getticks>
  83:	89 44 24 18          	mov    %eax,0x18(%esp)
  printf(1, "ticks = %d\n", ticks);
  87:	8b 44 24 18          	mov    0x18(%esp),%eax
  8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  8f:	c7 44 24 04 a7 09 00 	movl   $0x9a7,0x4(%esp)
  96:	00 
  97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9e:	e8 2a 05 00 00       	call   5cd <printf>
  printf(1, "t1    = %d\n", t1);
  a3:	8b 44 24 20          	mov    0x20(%esp),%eax
  a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  ab:	c7 44 24 04 b3 09 00 	movl   $0x9b3,0x4(%esp)
  b2:	00 
  b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ba:	e8 0e 05 00 00       	call   5cd <printf>
  printf(1, "t2    = %d\n", t2);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  c7:	c7 44 24 04 bf 09 00 	movl   $0x9bf,0x4(%esp)
  ce:	00 
  cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d6:	e8 f2 04 00 00       	call   5cd <printf>
  printf(1, "t2-t1 = %d\n", t2-t1);    
  db:	8b 44 24 20          	mov    0x20(%esp),%eax
  df:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  e3:	29 c2                	sub    %eax,%edx
  e5:	89 d0                	mov    %edx,%eax
  e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  eb:	c7 44 24 04 cb 09 00 	movl   $0x9cb,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 ce 04 00 00       	call   5cd <printf>

  exit();
  ff:	e8 54 02 00 00       	call   358 <exit>

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
 22d:	e8 3e 01 00 00       	call   370 <read>
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
 28d:	e8 06 01 00 00       	call   398 <open>
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
 2af:	e8 fc 00 00 00       	call   3b0 <fstat>
 2b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 be 00 00 00       	call   380 <close>
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
 34d:	90                   	nop
 34e:	90                   	nop
 34f:	90                   	nop

00000350 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 350:	b8 01 00 00 00       	mov    $0x1,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <exit>:
SYSCALL(exit)
 358:	b8 02 00 00 00       	mov    $0x2,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <wait>:
SYSCALL(wait)
 360:	b8 03 00 00 00       	mov    $0x3,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <pipe>:
SYSCALL(pipe)
 368:	b8 04 00 00 00       	mov    $0x4,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <read>:
SYSCALL(read)
 370:	b8 05 00 00 00       	mov    $0x5,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <write>:
SYSCALL(write)
 378:	b8 10 00 00 00       	mov    $0x10,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <close>:
SYSCALL(close)
 380:	b8 15 00 00 00       	mov    $0x15,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <kill>:
SYSCALL(kill)
 388:	b8 06 00 00 00       	mov    $0x6,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <exec>:
SYSCALL(exec)
 390:	b8 07 00 00 00       	mov    $0x7,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <open>:
SYSCALL(open)
 398:	b8 0f 00 00 00       	mov    $0xf,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <mknod>:
SYSCALL(mknod)
 3a0:	b8 11 00 00 00       	mov    $0x11,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <unlink>:
SYSCALL(unlink)
 3a8:	b8 12 00 00 00       	mov    $0x12,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <fstat>:
SYSCALL(fstat)
 3b0:	b8 08 00 00 00       	mov    $0x8,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <link>:
SYSCALL(link)
 3b8:	b8 13 00 00 00       	mov    $0x13,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <mkdir>:
SYSCALL(mkdir)
 3c0:	b8 14 00 00 00       	mov    $0x14,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <chdir>:
SYSCALL(chdir)
 3c8:	b8 09 00 00 00       	mov    $0x9,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <dup>:
SYSCALL(dup)
 3d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <getpid>:
SYSCALL(getpid)
 3d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <sbrk>:
SYSCALL(sbrk)
 3e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <sleep>:
SYSCALL(sleep)
 3e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <uptime>:
SYSCALL(uptime)
 3f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <getticks>:
SYSCALL(getticks)
 3f8:	b8 16 00 00 00       	mov    $0x16,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <get_name>:
SYSCALL(get_name)
 400:	b8 17 00 00 00       	mov    $0x17,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <get_max_proc>:
SYSCALL(get_max_proc)
 408:	b8 18 00 00 00       	mov    $0x18,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <get_max_mem>:
SYSCALL(get_max_mem)
 410:	b8 19 00 00 00       	mov    $0x19,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <get_max_disk>:
SYSCALL(get_max_disk)
 418:	b8 1a 00 00 00       	mov    $0x1a,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <get_curr_proc>:
SYSCALL(get_curr_proc)
 420:	b8 1b 00 00 00       	mov    $0x1b,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <get_curr_mem>:
SYSCALL(get_curr_mem)
 428:	b8 1c 00 00 00       	mov    $0x1c,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <get_curr_disk>:
SYSCALL(get_curr_disk)
 430:	b8 1d 00 00 00       	mov    $0x1d,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <set_name>:
SYSCALL(set_name)
 438:	b8 1e 00 00 00       	mov    $0x1e,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <set_max_mem>:
SYSCALL(set_max_mem)
 440:	b8 1f 00 00 00       	mov    $0x1f,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <set_max_disk>:
SYSCALL(set_max_disk)
 448:	b8 20 00 00 00       	mov    $0x20,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <set_max_proc>:
SYSCALL(set_max_proc)
 450:	b8 21 00 00 00       	mov    $0x21,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <set_curr_mem>:
SYSCALL(set_curr_mem)
 458:	b8 22 00 00 00       	mov    $0x22,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <set_curr_disk>:
SYSCALL(set_curr_disk)
 460:	b8 23 00 00 00       	mov    $0x23,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <set_curr_proc>:
SYSCALL(set_curr_proc)
 468:	b8 24 00 00 00       	mov    $0x24,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <find>:
SYSCALL(find)
 470:	b8 25 00 00 00       	mov    $0x25,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <is_full>:
SYSCALL(is_full)
 478:	b8 26 00 00 00       	mov    $0x26,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <container_init>:
SYSCALL(container_init)
 480:	b8 27 00 00 00       	mov    $0x27,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <cont_proc_set>:
SYSCALL(cont_proc_set)
 488:	b8 28 00 00 00       	mov    $0x28,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <ps>:
SYSCALL(ps)
 490:	b8 29 00 00 00       	mov    $0x29,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 498:	b8 2a 00 00 00       	mov    $0x2a,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <set_root_inode>:
SYSCALL(set_root_inode)
 4a0:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <cstop>:
SYSCALL(cstop)
 4a8:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <df>:
SYSCALL(df)
 4b0:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <max_containers>:
SYSCALL(max_containers)
 4b8:	b8 2e 00 00 00       	mov    $0x2e,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <container_reset>:
SYSCALL(container_reset)
 4c0:	b8 2f 00 00 00       	mov    $0x2f,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <pause>:
SYSCALL(pause)
 4c8:	b8 30 00 00 00       	mov    $0x30,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <resume>:
SYSCALL(resume)
 4d0:	b8 31 00 00 00       	mov    $0x31,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <tmem>:
SYSCALL(tmem)
 4d8:	b8 32 00 00 00       	mov    $0x32,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <amem>:
SYSCALL(amem)
 4e0:	b8 33 00 00 00       	mov    $0x33,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <c_ps>:
SYSCALL(c_ps)
 4e8:	b8 34 00 00 00       	mov    $0x34,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f0:	55                   	push   %ebp
 4f1:	89 e5                	mov    %esp,%ebp
 4f3:	83 ec 18             	sub    $0x18,%esp
 4f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 503:	00 
 504:	8d 45 f4             	lea    -0xc(%ebp),%eax
 507:	89 44 24 04          	mov    %eax,0x4(%esp)
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	89 04 24             	mov    %eax,(%esp)
 511:	e8 62 fe ff ff       	call   378 <write>
}
 516:	c9                   	leave  
 517:	c3                   	ret    

00000518 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 518:	55                   	push   %ebp
 519:	89 e5                	mov    %esp,%ebp
 51b:	56                   	push   %esi
 51c:	53                   	push   %ebx
 51d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 520:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 527:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 52b:	74 17                	je     544 <printint+0x2c>
 52d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 531:	79 11                	jns    544 <printint+0x2c>
    neg = 1;
 533:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 53a:	8b 45 0c             	mov    0xc(%ebp),%eax
 53d:	f7 d8                	neg    %eax
 53f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 542:	eb 06                	jmp    54a <printint+0x32>
  } else {
    x = xx;
 544:	8b 45 0c             	mov    0xc(%ebp),%eax
 547:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 54a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 551:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 554:	8d 41 01             	lea    0x1(%ecx),%eax
 557:	89 45 f4             	mov    %eax,-0xc(%ebp)
 55a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 55d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 560:	ba 00 00 00 00       	mov    $0x0,%edx
 565:	f7 f3                	div    %ebx
 567:	89 d0                	mov    %edx,%eax
 569:	8a 80 24 0c 00 00    	mov    0xc24(%eax),%al
 56f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 573:	8b 75 10             	mov    0x10(%ebp),%esi
 576:	8b 45 ec             	mov    -0x14(%ebp),%eax
 579:	ba 00 00 00 00       	mov    $0x0,%edx
 57e:	f7 f6                	div    %esi
 580:	89 45 ec             	mov    %eax,-0x14(%ebp)
 583:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 587:	75 c8                	jne    551 <printint+0x39>
  if(neg)
 589:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 58d:	74 10                	je     59f <printint+0x87>
    buf[i++] = '-';
 58f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 592:	8d 50 01             	lea    0x1(%eax),%edx
 595:	89 55 f4             	mov    %edx,-0xc(%ebp)
 598:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 59d:	eb 1e                	jmp    5bd <printint+0xa5>
 59f:	eb 1c                	jmp    5bd <printint+0xa5>
    putc(fd, buf[i]);
 5a1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a7:	01 d0                	add    %edx,%eax
 5a9:	8a 00                	mov    (%eax),%al
 5ab:	0f be c0             	movsbl %al,%eax
 5ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b2:	8b 45 08             	mov    0x8(%ebp),%eax
 5b5:	89 04 24             	mov    %eax,(%esp)
 5b8:	e8 33 ff ff ff       	call   4f0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5bd:	ff 4d f4             	decl   -0xc(%ebp)
 5c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c4:	79 db                	jns    5a1 <printint+0x89>
    putc(fd, buf[i]);
}
 5c6:	83 c4 30             	add    $0x30,%esp
 5c9:	5b                   	pop    %ebx
 5ca:	5e                   	pop    %esi
 5cb:	5d                   	pop    %ebp
 5cc:	c3                   	ret    

000005cd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5cd:	55                   	push   %ebp
 5ce:	89 e5                	mov    %esp,%ebp
 5d0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5da:	8d 45 0c             	lea    0xc(%ebp),%eax
 5dd:	83 c0 04             	add    $0x4,%eax
 5e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5ea:	e9 77 01 00 00       	jmp    766 <printf+0x199>
    c = fmt[i] & 0xff;
 5ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f5:	01 d0                	add    %edx,%eax
 5f7:	8a 00                	mov    (%eax),%al
 5f9:	0f be c0             	movsbl %al,%eax
 5fc:	25 ff 00 00 00       	and    $0xff,%eax
 601:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 604:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 608:	75 2c                	jne    636 <printf+0x69>
      if(c == '%'){
 60a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 60e:	75 0c                	jne    61c <printf+0x4f>
        state = '%';
 610:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 617:	e9 47 01 00 00       	jmp    763 <printf+0x196>
      } else {
        putc(fd, c);
 61c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61f:	0f be c0             	movsbl %al,%eax
 622:	89 44 24 04          	mov    %eax,0x4(%esp)
 626:	8b 45 08             	mov    0x8(%ebp),%eax
 629:	89 04 24             	mov    %eax,(%esp)
 62c:	e8 bf fe ff ff       	call   4f0 <putc>
 631:	e9 2d 01 00 00       	jmp    763 <printf+0x196>
      }
    } else if(state == '%'){
 636:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 63a:	0f 85 23 01 00 00    	jne    763 <printf+0x196>
      if(c == 'd'){
 640:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 644:	75 2d                	jne    673 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 646:	8b 45 e8             	mov    -0x18(%ebp),%eax
 649:	8b 00                	mov    (%eax),%eax
 64b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 652:	00 
 653:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 65a:	00 
 65b:	89 44 24 04          	mov    %eax,0x4(%esp)
 65f:	8b 45 08             	mov    0x8(%ebp),%eax
 662:	89 04 24             	mov    %eax,(%esp)
 665:	e8 ae fe ff ff       	call   518 <printint>
        ap++;
 66a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66e:	e9 e9 00 00 00       	jmp    75c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 673:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 677:	74 06                	je     67f <printf+0xb2>
 679:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 67d:	75 2d                	jne    6ac <printf+0xdf>
        printint(fd, *ap, 16, 0);
 67f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 682:	8b 00                	mov    (%eax),%eax
 684:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 68b:	00 
 68c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 693:	00 
 694:	89 44 24 04          	mov    %eax,0x4(%esp)
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	89 04 24             	mov    %eax,(%esp)
 69e:	e8 75 fe ff ff       	call   518 <printint>
        ap++;
 6a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a7:	e9 b0 00 00 00       	jmp    75c <printf+0x18f>
      } else if(c == 's'){
 6ac:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6b0:	75 42                	jne    6f4 <printf+0x127>
        s = (char*)*ap;
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c2:	75 09                	jne    6cd <printf+0x100>
          s = "(null)";
 6c4:	c7 45 f4 d7 09 00 00 	movl   $0x9d7,-0xc(%ebp)
        while(*s != 0){
 6cb:	eb 1c                	jmp    6e9 <printf+0x11c>
 6cd:	eb 1a                	jmp    6e9 <printf+0x11c>
          putc(fd, *s);
 6cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d2:	8a 00                	mov    (%eax),%al
 6d4:	0f be c0             	movsbl %al,%eax
 6d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6db:	8b 45 08             	mov    0x8(%ebp),%eax
 6de:	89 04 24             	mov    %eax,(%esp)
 6e1:	e8 0a fe ff ff       	call   4f0 <putc>
          s++;
 6e6:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ec:	8a 00                	mov    (%eax),%al
 6ee:	84 c0                	test   %al,%al
 6f0:	75 dd                	jne    6cf <printf+0x102>
 6f2:	eb 68                	jmp    75c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6f8:	75 1d                	jne    717 <printf+0x14a>
        putc(fd, *ap);
 6fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6fd:	8b 00                	mov    (%eax),%eax
 6ff:	0f be c0             	movsbl %al,%eax
 702:	89 44 24 04          	mov    %eax,0x4(%esp)
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	89 04 24             	mov    %eax,(%esp)
 70c:	e8 df fd ff ff       	call   4f0 <putc>
        ap++;
 711:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 715:	eb 45                	jmp    75c <printf+0x18f>
      } else if(c == '%'){
 717:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 71b:	75 17                	jne    734 <printf+0x167>
        putc(fd, c);
 71d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 720:	0f be c0             	movsbl %al,%eax
 723:	89 44 24 04          	mov    %eax,0x4(%esp)
 727:	8b 45 08             	mov    0x8(%ebp),%eax
 72a:	89 04 24             	mov    %eax,(%esp)
 72d:	e8 be fd ff ff       	call   4f0 <putc>
 732:	eb 28                	jmp    75c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 734:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 73b:	00 
 73c:	8b 45 08             	mov    0x8(%ebp),%eax
 73f:	89 04 24             	mov    %eax,(%esp)
 742:	e8 a9 fd ff ff       	call   4f0 <putc>
        putc(fd, c);
 747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 74a:	0f be c0             	movsbl %al,%eax
 74d:	89 44 24 04          	mov    %eax,0x4(%esp)
 751:	8b 45 08             	mov    0x8(%ebp),%eax
 754:	89 04 24             	mov    %eax,(%esp)
 757:	e8 94 fd ff ff       	call   4f0 <putc>
      }
      state = 0;
 75c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 763:	ff 45 f0             	incl   -0x10(%ebp)
 766:	8b 55 0c             	mov    0xc(%ebp),%edx
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	01 d0                	add    %edx,%eax
 76e:	8a 00                	mov    (%eax),%al
 770:	84 c0                	test   %al,%al
 772:	0f 85 77 fe ff ff    	jne    5ef <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 778:	c9                   	leave  
 779:	c3                   	ret    
 77a:	90                   	nop
 77b:	90                   	nop

0000077c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77c:	55                   	push   %ebp
 77d:	89 e5                	mov    %esp,%ebp
 77f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 782:	8b 45 08             	mov    0x8(%ebp),%eax
 785:	83 e8 08             	sub    $0x8,%eax
 788:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78b:	a1 40 0c 00 00       	mov    0xc40,%eax
 790:	89 45 fc             	mov    %eax,-0x4(%ebp)
 793:	eb 24                	jmp    7b9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79d:	77 12                	ja     7b1 <free+0x35>
 79f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a5:	77 24                	ja     7cb <free+0x4f>
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 00                	mov    (%eax),%eax
 7ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7af:	77 1a                	ja     7cb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bf:	76 d4                	jbe    795 <free+0x19>
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c9:	76 ca                	jbe    795 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ce:	8b 40 04             	mov    0x4(%eax),%eax
 7d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7db:	01 c2                	add    %eax,%edx
 7dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	39 c2                	cmp    %eax,%edx
 7e4:	75 24                	jne    80a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e9:	8b 50 04             	mov    0x4(%eax),%edx
 7ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ef:	8b 00                	mov    (%eax),%eax
 7f1:	8b 40 04             	mov    0x4(%eax),%eax
 7f4:	01 c2                	add    %eax,%edx
 7f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ff:	8b 00                	mov    (%eax),%eax
 801:	8b 10                	mov    (%eax),%edx
 803:	8b 45 f8             	mov    -0x8(%ebp),%eax
 806:	89 10                	mov    %edx,(%eax)
 808:	eb 0a                	jmp    814 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	8b 10                	mov    (%eax),%edx
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 814:	8b 45 fc             	mov    -0x4(%ebp),%eax
 817:	8b 40 04             	mov    0x4(%eax),%eax
 81a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	01 d0                	add    %edx,%eax
 826:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 829:	75 20                	jne    84b <free+0xcf>
    p->s.size += bp->s.size;
 82b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82e:	8b 50 04             	mov    0x4(%eax),%edx
 831:	8b 45 f8             	mov    -0x8(%ebp),%eax
 834:	8b 40 04             	mov    0x4(%eax),%eax
 837:	01 c2                	add    %eax,%edx
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	8b 10                	mov    (%eax),%edx
 844:	8b 45 fc             	mov    -0x4(%ebp),%eax
 847:	89 10                	mov    %edx,(%eax)
 849:	eb 08                	jmp    853 <free+0xd7>
  } else
    p->s.ptr = bp;
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 851:	89 10                	mov    %edx,(%eax)
  freep = p;
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	a3 40 0c 00 00       	mov    %eax,0xc40
}
 85b:	c9                   	leave  
 85c:	c3                   	ret    

0000085d <morecore>:

static Header*
morecore(uint nu)
{
 85d:	55                   	push   %ebp
 85e:	89 e5                	mov    %esp,%ebp
 860:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 863:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 86a:	77 07                	ja     873 <morecore+0x16>
    nu = 4096;
 86c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 873:	8b 45 08             	mov    0x8(%ebp),%eax
 876:	c1 e0 03             	shl    $0x3,%eax
 879:	89 04 24             	mov    %eax,(%esp)
 87c:	e8 5f fb ff ff       	call   3e0 <sbrk>
 881:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 884:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 888:	75 07                	jne    891 <morecore+0x34>
    return 0;
 88a:	b8 00 00 00 00       	mov    $0x0,%eax
 88f:	eb 22                	jmp    8b3 <morecore+0x56>
  hp = (Header*)p;
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 897:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89a:	8b 55 08             	mov    0x8(%ebp),%edx
 89d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a3:	83 c0 08             	add    $0x8,%eax
 8a6:	89 04 24             	mov    %eax,(%esp)
 8a9:	e8 ce fe ff ff       	call   77c <free>
  return freep;
 8ae:	a1 40 0c 00 00       	mov    0xc40,%eax
}
 8b3:	c9                   	leave  
 8b4:	c3                   	ret    

000008b5 <malloc>:

void*
malloc(uint nbytes)
{
 8b5:	55                   	push   %ebp
 8b6:	89 e5                	mov    %esp,%ebp
 8b8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8bb:	8b 45 08             	mov    0x8(%ebp),%eax
 8be:	83 c0 07             	add    $0x7,%eax
 8c1:	c1 e8 03             	shr    $0x3,%eax
 8c4:	40                   	inc    %eax
 8c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c8:	a1 40 0c 00 00       	mov    0xc40,%eax
 8cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8d4:	75 23                	jne    8f9 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8d6:	c7 45 f0 38 0c 00 00 	movl   $0xc38,-0x10(%ebp)
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	a3 40 0c 00 00       	mov    %eax,0xc40
 8e5:	a1 40 0c 00 00       	mov    0xc40,%eax
 8ea:	a3 38 0c 00 00       	mov    %eax,0xc38
    base.s.size = 0;
 8ef:	c7 05 3c 0c 00 00 00 	movl   $0x0,0xc3c
 8f6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fc:	8b 00                	mov    (%eax),%eax
 8fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 901:	8b 45 f4             	mov    -0xc(%ebp),%eax
 904:	8b 40 04             	mov    0x4(%eax),%eax
 907:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 90a:	72 4d                	jb     959 <malloc+0xa4>
      if(p->s.size == nunits)
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	8b 40 04             	mov    0x4(%eax),%eax
 912:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 915:	75 0c                	jne    923 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 917:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91a:	8b 10                	mov    (%eax),%edx
 91c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91f:	89 10                	mov    %edx,(%eax)
 921:	eb 26                	jmp    949 <malloc+0x94>
      else {
        p->s.size -= nunits;
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	8b 40 04             	mov    0x4(%eax),%eax
 929:	2b 45 ec             	sub    -0x14(%ebp),%eax
 92c:	89 c2                	mov    %eax,%edx
 92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 931:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 934:	8b 45 f4             	mov    -0xc(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	c1 e0 03             	shl    $0x3,%eax
 93d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 940:	8b 45 f4             	mov    -0xc(%ebp),%eax
 943:	8b 55 ec             	mov    -0x14(%ebp),%edx
 946:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 949:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94c:	a3 40 0c 00 00       	mov    %eax,0xc40
      return (void*)(p + 1);
 951:	8b 45 f4             	mov    -0xc(%ebp),%eax
 954:	83 c0 08             	add    $0x8,%eax
 957:	eb 38                	jmp    991 <malloc+0xdc>
    }
    if(p == freep)
 959:	a1 40 0c 00 00       	mov    0xc40,%eax
 95e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 961:	75 1b                	jne    97e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 963:	8b 45 ec             	mov    -0x14(%ebp),%eax
 966:	89 04 24             	mov    %eax,(%esp)
 969:	e8 ef fe ff ff       	call   85d <morecore>
 96e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 971:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 975:	75 07                	jne    97e <malloc+0xc9>
        return 0;
 977:	b8 00 00 00 00       	mov    $0x0,%eax
 97c:	eb 13                	jmp    991 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	89 45 f0             	mov    %eax,-0x10(%ebp)
 984:	8b 45 f4             	mov    -0xc(%ebp),%eax
 987:	8b 00                	mov    (%eax),%eax
 989:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 98c:	e9 70 ff ff ff       	jmp    901 <malloc+0x4c>
}
 991:	c9                   	leave  
 992:	c3                   	ret    
