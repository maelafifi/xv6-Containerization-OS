
_echoloop:     file format elf32-i386


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
  int ticks;

  if (argc < 3) {
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
  	printf(1, "usage: echoloop ticks arg1 [arg2 ...]\n");
   f:	c7 44 24 04 24 0a 00 	movl   $0xa24,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 3a 06 00 00       	call   65d <printf>
  	exit();
  23:	e8 b8 03 00 00       	call   3e0 <exit>
  }

  ticks = atoi(argv[1]);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	89 04 24             	mov    %eax,(%esp)
  33:	e8 33 02 00 00       	call   26b <atoi>
  38:	89 44 24 18          	mov    %eax,0x18(%esp)

  while(1){
	  for(i = 2; i < argc; i++)
  3c:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
  43:	00 
  44:	eb 48                	jmp    8e <main+0x8e>
    	printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  46:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  4a:	40                   	inc    %eax
  4b:	3b 45 08             	cmp    0x8(%ebp),%eax
  4e:	7d 07                	jge    57 <main+0x57>
  50:	b8 4b 0a 00 00       	mov    $0xa4b,%eax
  55:	eb 05                	jmp    5c <main+0x5c>
  57:	b8 4d 0a 00 00       	mov    $0xa4d,%eax
  5c:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  60:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  67:	8b 55 0c             	mov    0xc(%ebp),%edx
  6a:	01 ca                	add    %ecx,%edx
  6c:	8b 12                	mov    (%edx),%edx
  6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  72:	89 54 24 08          	mov    %edx,0x8(%esp)
  76:	c7 44 24 04 4f 0a 00 	movl   $0xa4f,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 d3 05 00 00       	call   65d <printf>
  }

  ticks = atoi(argv[1]);

  while(1){
	  for(i = 2; i < argc; i++)
  8a:	ff 44 24 1c          	incl   0x1c(%esp)
  8e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  92:	3b 45 08             	cmp    0x8(%ebp),%eax
  95:	7c af                	jl     46 <main+0x46>
    	printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
    sleep(ticks);
  97:	8b 44 24 18          	mov    0x18(%esp),%eax
  9b:	89 04 24             	mov    %eax,(%esp)
  9e:	e8 cd 03 00 00       	call   470 <sleep>
  }
  a3:	eb 97                	jmp    3c <main+0x3c>
  a5:	90                   	nop
  a6:	90                   	nop
  a7:	90                   	nop

000000a8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	57                   	push   %edi
  ac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b0:	8b 55 10             	mov    0x10(%ebp),%edx
  b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  b6:	89 cb                	mov    %ecx,%ebx
  b8:	89 df                	mov    %ebx,%edi
  ba:	89 d1                	mov    %edx,%ecx
  bc:	fc                   	cld    
  bd:	f3 aa                	rep stos %al,%es:(%edi)
  bf:	89 ca                	mov    %ecx,%edx
  c1:	89 fb                	mov    %edi,%ebx
  c3:	89 5d 08             	mov    %ebx,0x8(%ebp)
  c6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  c9:	5b                   	pop    %ebx
  ca:	5f                   	pop    %edi
  cb:	5d                   	pop    %ebp
  cc:	c3                   	ret    

000000cd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  d9:	90                   	nop
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	8d 50 01             	lea    0x1(%eax),%edx
  e0:	89 55 08             	mov    %edx,0x8(%ebp)
  e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  e9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ec:	8a 12                	mov    (%edx),%dl
  ee:	88 10                	mov    %dl,(%eax)
  f0:	8a 00                	mov    (%eax),%al
  f2:	84 c0                	test   %al,%al
  f4:	75 e4                	jne    da <strcpy+0xd>
    ;
  return os;
  f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f9:	c9                   	leave  
  fa:	c3                   	ret    

000000fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  fe:	eb 06                	jmp    106 <strcmp+0xb>
    p++, q++;
 100:	ff 45 08             	incl   0x8(%ebp)
 103:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 106:	8b 45 08             	mov    0x8(%ebp),%eax
 109:	8a 00                	mov    (%eax),%al
 10b:	84 c0                	test   %al,%al
 10d:	74 0e                	je     11d <strcmp+0x22>
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	8a 10                	mov    (%eax),%dl
 114:	8b 45 0c             	mov    0xc(%ebp),%eax
 117:	8a 00                	mov    (%eax),%al
 119:	38 c2                	cmp    %al,%dl
 11b:	74 e3                	je     100 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	8a 00                	mov    (%eax),%al
 122:	0f b6 d0             	movzbl %al,%edx
 125:	8b 45 0c             	mov    0xc(%ebp),%eax
 128:	8a 00                	mov    (%eax),%al
 12a:	0f b6 c0             	movzbl %al,%eax
 12d:	29 c2                	sub    %eax,%edx
 12f:	89 d0                	mov    %edx,%eax
}
 131:	5d                   	pop    %ebp
 132:	c3                   	ret    

00000133 <strlen>:

uint
strlen(char *s)
{
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 139:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 140:	eb 03                	jmp    145 <strlen+0x12>
 142:	ff 45 fc             	incl   -0x4(%ebp)
 145:	8b 55 fc             	mov    -0x4(%ebp),%edx
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	01 d0                	add    %edx,%eax
 14d:	8a 00                	mov    (%eax),%al
 14f:	84 c0                	test   %al,%al
 151:	75 ef                	jne    142 <strlen+0xf>
    ;
  return n;
 153:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 15e:	8b 45 10             	mov    0x10(%ebp),%eax
 161:	89 44 24 08          	mov    %eax,0x8(%esp)
 165:	8b 45 0c             	mov    0xc(%ebp),%eax
 168:	89 44 24 04          	mov    %eax,0x4(%esp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	89 04 24             	mov    %eax,(%esp)
 172:	e8 31 ff ff ff       	call   a8 <stosb>
  return dst;
 177:	8b 45 08             	mov    0x8(%ebp),%eax
}
 17a:	c9                   	leave  
 17b:	c3                   	ret    

0000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	83 ec 04             	sub    $0x4,%esp
 182:	8b 45 0c             	mov    0xc(%ebp),%eax
 185:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 188:	eb 12                	jmp    19c <strchr+0x20>
    if(*s == c)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	8a 00                	mov    (%eax),%al
 18f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 192:	75 05                	jne    199 <strchr+0x1d>
      return (char*)s;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	eb 11                	jmp    1aa <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 199:	ff 45 08             	incl   0x8(%ebp)
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	8a 00                	mov    (%eax),%al
 1a1:	84 c0                	test   %al,%al
 1a3:	75 e5                	jne    18a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <gets>:

char*
gets(char *buf, int max)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b9:	eb 49                	jmp    204 <gets+0x58>
    cc = read(0, &c, 1);
 1bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1c2:	00 
 1c3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1d1:	e8 22 02 00 00       	call   3f8 <read>
 1d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1dd:	7f 02                	jg     1e1 <gets+0x35>
      break;
 1df:	eb 2c                	jmp    20d <gets+0x61>
    buf[i++] = c;
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	8d 50 01             	lea    0x1(%eax),%edx
 1e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ea:	89 c2                	mov    %eax,%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	01 c2                	add    %eax,%edx
 1f1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1f4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1f6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1f9:	3c 0a                	cmp    $0xa,%al
 1fb:	74 10                	je     20d <gets+0x61>
 1fd:	8a 45 ef             	mov    -0x11(%ebp),%al
 200:	3c 0d                	cmp    $0xd,%al
 202:	74 09                	je     20d <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 204:	8b 45 f4             	mov    -0xc(%ebp),%eax
 207:	40                   	inc    %eax
 208:	3b 45 0c             	cmp    0xc(%ebp),%eax
 20b:	7c ae                	jl     1bb <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 20d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	01 d0                	add    %edx,%eax
 215:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 218:	8b 45 08             	mov    0x8(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <stat>:

int
stat(char *n, struct stat *st)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 223:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 22a:	00 
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	89 04 24             	mov    %eax,(%esp)
 231:	e8 ea 01 00 00       	call   420 <open>
 236:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 239:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 23d:	79 07                	jns    246 <stat+0x29>
    return -1;
 23f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 244:	eb 23                	jmp    269 <stat+0x4c>
  r = fstat(fd, st);
 246:	8b 45 0c             	mov    0xc(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 250:	89 04 24             	mov    %eax,(%esp)
 253:	e8 e0 01 00 00       	call   438 <fstat>
 258:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 25b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25e:	89 04 24             	mov    %eax,(%esp)
 261:	e8 a2 01 00 00       	call   408 <close>
  return r;
 266:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 269:	c9                   	leave  
 26a:	c3                   	ret    

0000026b <atoi>:

int
atoi(const char *s)
{
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 271:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 278:	eb 24                	jmp    29e <atoi+0x33>
    n = n*10 + *s++ - '0';
 27a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27d:	89 d0                	mov    %edx,%eax
 27f:	c1 e0 02             	shl    $0x2,%eax
 282:	01 d0                	add    %edx,%eax
 284:	01 c0                	add    %eax,%eax
 286:	89 c1                	mov    %eax,%ecx
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	8d 50 01             	lea    0x1(%eax),%edx
 28e:	89 55 08             	mov    %edx,0x8(%ebp)
 291:	8a 00                	mov    (%eax),%al
 293:	0f be c0             	movsbl %al,%eax
 296:	01 c8                	add    %ecx,%eax
 298:	83 e8 30             	sub    $0x30,%eax
 29b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	8a 00                	mov    (%eax),%al
 2a3:	3c 2f                	cmp    $0x2f,%al
 2a5:	7e 09                	jle    2b0 <atoi+0x45>
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	8a 00                	mov    (%eax),%al
 2ac:	3c 39                	cmp    $0x39,%al
 2ae:	7e ca                	jle    27a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c7:	eb 16                	jmp    2df <memmove+0x2a>
    *dst++ = *src++;
 2c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2cc:	8d 50 01             	lea    0x1(%eax),%edx
 2cf:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2d5:	8d 4a 01             	lea    0x1(%edx),%ecx
 2d8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2db:	8a 12                	mov    (%edx),%dl
 2dd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2df:	8b 45 10             	mov    0x10(%ebp),%eax
 2e2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e5:	89 55 10             	mov    %edx,0x10(%ebp)
 2e8:	85 c0                	test   %eax,%eax
 2ea:	7f dd                	jg     2c9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ef:	c9                   	leave  
 2f0:	c3                   	ret    

000002f1 <itoa>:

int itoa(int value, char *sp, int radix)
{
 2f1:	55                   	push   %ebp
 2f2:	89 e5                	mov    %esp,%ebp
 2f4:	53                   	push   %ebx
 2f5:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2f8:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2fe:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 302:	75 0d                	jne    311 <itoa+0x20>
 304:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 308:	79 07                	jns    311 <itoa+0x20>
 30a:	b8 01 00 00 00       	mov    $0x1,%eax
 30f:	eb 05                	jmp    316 <itoa+0x25>
 311:	b8 00 00 00 00       	mov    $0x0,%eax
 316:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 319:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 31d:	74 0a                	je     329 <itoa+0x38>
      v = -value;
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	f7 d8                	neg    %eax
 324:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 327:	eb 54                	jmp    37d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 32f:	eb 4c                	jmp    37d <itoa+0x8c>
  {
    i = v % radix;
 331:	8b 4d 10             	mov    0x10(%ebp),%ecx
 334:	8b 45 f4             	mov    -0xc(%ebp),%eax
 337:	ba 00 00 00 00       	mov    $0x0,%edx
 33c:	f7 f1                	div    %ecx
 33e:	89 d0                	mov    %edx,%eax
 340:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 343:	8b 5d 10             	mov    0x10(%ebp),%ebx
 346:	8b 45 f4             	mov    -0xc(%ebp),%eax
 349:	ba 00 00 00 00       	mov    $0x0,%edx
 34e:	f7 f3                	div    %ebx
 350:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 353:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 357:	7f 13                	jg     36c <itoa+0x7b>
      *tp++ = i+'0';
 359:	8b 45 f8             	mov    -0x8(%ebp),%eax
 35c:	8d 50 01             	lea    0x1(%eax),%edx
 35f:	89 55 f8             	mov    %edx,-0x8(%ebp)
 362:	8b 55 e8             	mov    -0x18(%ebp),%edx
 365:	83 c2 30             	add    $0x30,%edx
 368:	88 10                	mov    %dl,(%eax)
 36a:	eb 11                	jmp    37d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 36c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 36f:	8d 50 01             	lea    0x1(%eax),%edx
 372:	89 55 f8             	mov    %edx,-0x8(%ebp)
 375:	8b 55 e8             	mov    -0x18(%ebp),%edx
 378:	83 c2 57             	add    $0x57,%edx
 37b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 37d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 381:	75 ae                	jne    331 <itoa+0x40>
 383:	8d 45 d8             	lea    -0x28(%ebp),%eax
 386:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 389:	74 a6                	je     331 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 38b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 38e:	8d 45 d8             	lea    -0x28(%ebp),%eax
 391:	29 c2                	sub    %eax,%edx
 393:	89 d0                	mov    %edx,%eax
 395:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 398:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 39c:	74 11                	je     3af <itoa+0xbe>
  {
    *sp++ = '-';
 39e:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a1:	8d 50 01             	lea    0x1(%eax),%edx
 3a4:	89 55 0c             	mov    %edx,0xc(%ebp)
 3a7:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 3aa:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 3ad:	eb 15                	jmp    3c4 <itoa+0xd3>
 3af:	eb 13                	jmp    3c4 <itoa+0xd3>
    *sp++ = *--tp;
 3b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b4:	8d 50 01             	lea    0x1(%eax),%edx
 3b7:	89 55 0c             	mov    %edx,0xc(%ebp)
 3ba:	ff 4d f8             	decl   -0x8(%ebp)
 3bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3c0:	8a 12                	mov    (%edx),%dl
 3c2:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 3c4:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3c7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3ca:	77 e5                	ja     3b1 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 3cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3cf:	83 c4 30             	add    $0x30,%esp
 3d2:	5b                   	pop    %ebx
 3d3:	5d                   	pop    %ebp
 3d4:	c3                   	ret    
 3d5:	90                   	nop
 3d6:	90                   	nop
 3d7:	90                   	nop

000003d8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3d8:	b8 01 00 00 00       	mov    $0x1,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <exit>:
SYSCALL(exit)
 3e0:	b8 02 00 00 00       	mov    $0x2,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <wait>:
SYSCALL(wait)
 3e8:	b8 03 00 00 00       	mov    $0x3,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <pipe>:
SYSCALL(pipe)
 3f0:	b8 04 00 00 00       	mov    $0x4,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <read>:
SYSCALL(read)
 3f8:	b8 05 00 00 00       	mov    $0x5,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <write>:
SYSCALL(write)
 400:	b8 10 00 00 00       	mov    $0x10,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <close>:
SYSCALL(close)
 408:	b8 15 00 00 00       	mov    $0x15,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <kill>:
SYSCALL(kill)
 410:	b8 06 00 00 00       	mov    $0x6,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <exec>:
SYSCALL(exec)
 418:	b8 07 00 00 00       	mov    $0x7,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <open>:
SYSCALL(open)
 420:	b8 0f 00 00 00       	mov    $0xf,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <mknod>:
SYSCALL(mknod)
 428:	b8 11 00 00 00       	mov    $0x11,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <unlink>:
SYSCALL(unlink)
 430:	b8 12 00 00 00       	mov    $0x12,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <fstat>:
SYSCALL(fstat)
 438:	b8 08 00 00 00       	mov    $0x8,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <link>:
SYSCALL(link)
 440:	b8 13 00 00 00       	mov    $0x13,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <mkdir>:
SYSCALL(mkdir)
 448:	b8 14 00 00 00       	mov    $0x14,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <chdir>:
SYSCALL(chdir)
 450:	b8 09 00 00 00       	mov    $0x9,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <dup>:
SYSCALL(dup)
 458:	b8 0a 00 00 00       	mov    $0xa,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <getpid>:
SYSCALL(getpid)
 460:	b8 0b 00 00 00       	mov    $0xb,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <sbrk>:
SYSCALL(sbrk)
 468:	b8 0c 00 00 00       	mov    $0xc,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <sleep>:
SYSCALL(sleep)
 470:	b8 0d 00 00 00       	mov    $0xd,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <uptime>:
SYSCALL(uptime)
 478:	b8 0e 00 00 00       	mov    $0xe,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <getticks>:
SYSCALL(getticks)
 480:	b8 16 00 00 00       	mov    $0x16,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <get_name>:
SYSCALL(get_name)
 488:	b8 17 00 00 00       	mov    $0x17,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <get_max_proc>:
SYSCALL(get_max_proc)
 490:	b8 18 00 00 00       	mov    $0x18,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <get_max_mem>:
SYSCALL(get_max_mem)
 498:	b8 19 00 00 00       	mov    $0x19,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <get_max_disk>:
SYSCALL(get_max_disk)
 4a0:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <get_curr_proc>:
SYSCALL(get_curr_proc)
 4a8:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <get_curr_mem>:
SYSCALL(get_curr_mem)
 4b0:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <get_curr_disk>:
SYSCALL(get_curr_disk)
 4b8:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <set_name>:
SYSCALL(set_name)
 4c0:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <set_max_mem>:
SYSCALL(set_max_mem)
 4c8:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <set_max_disk>:
SYSCALL(set_max_disk)
 4d0:	b8 20 00 00 00       	mov    $0x20,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <set_max_proc>:
SYSCALL(set_max_proc)
 4d8:	b8 21 00 00 00       	mov    $0x21,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <set_curr_mem>:
SYSCALL(set_curr_mem)
 4e0:	b8 22 00 00 00       	mov    $0x22,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <set_curr_disk>:
SYSCALL(set_curr_disk)
 4e8:	b8 23 00 00 00       	mov    $0x23,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4f0:	b8 24 00 00 00       	mov    $0x24,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <find>:
SYSCALL(find)
 4f8:	b8 25 00 00 00       	mov    $0x25,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <is_full>:
SYSCALL(is_full)
 500:	b8 26 00 00 00       	mov    $0x26,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <container_init>:
SYSCALL(container_init)
 508:	b8 27 00 00 00       	mov    $0x27,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <cont_proc_set>:
SYSCALL(cont_proc_set)
 510:	b8 28 00 00 00       	mov    $0x28,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <ps>:
SYSCALL(ps)
 518:	b8 29 00 00 00       	mov    $0x29,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 520:	b8 2a 00 00 00       	mov    $0x2a,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <set_root_inode>:
SYSCALL(set_root_inode)
 528:	b8 2b 00 00 00       	mov    $0x2b,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <cstop>:
SYSCALL(cstop)
 530:	b8 2c 00 00 00       	mov    $0x2c,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <df>:
SYSCALL(df)
 538:	b8 2d 00 00 00       	mov    $0x2d,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <max_containers>:
SYSCALL(max_containers)
 540:	b8 2e 00 00 00       	mov    $0x2e,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <container_reset>:
SYSCALL(container_reset)
 548:	b8 2f 00 00 00       	mov    $0x2f,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <pause>:
SYSCALL(pause)
 550:	b8 30 00 00 00       	mov    $0x30,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <resume>:
SYSCALL(resume)
 558:	b8 31 00 00 00       	mov    $0x31,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <tmem>:
SYSCALL(tmem)
 560:	b8 32 00 00 00       	mov    $0x32,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <amem>:
SYSCALL(amem)
 568:	b8 33 00 00 00       	mov    $0x33,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <c_ps>:
SYSCALL(c_ps)
 570:	b8 34 00 00 00       	mov    $0x34,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <get_used>:
SYSCALL(get_used)
 578:	b8 35 00 00 00       	mov    $0x35,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	83 ec 18             	sub    $0x18,%esp
 586:	8b 45 0c             	mov    0xc(%ebp),%eax
 589:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 58c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 593:	00 
 594:	8d 45 f4             	lea    -0xc(%ebp),%eax
 597:	89 44 24 04          	mov    %eax,0x4(%esp)
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	89 04 24             	mov    %eax,(%esp)
 5a1:	e8 5a fe ff ff       	call   400 <write>
}
 5a6:	c9                   	leave  
 5a7:	c3                   	ret    

000005a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a8:	55                   	push   %ebp
 5a9:	89 e5                	mov    %esp,%ebp
 5ab:	56                   	push   %esi
 5ac:	53                   	push   %ebx
 5ad:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5b7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5bb:	74 17                	je     5d4 <printint+0x2c>
 5bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c1:	79 11                	jns    5d4 <printint+0x2c>
    neg = 1;
 5c3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cd:	f7 d8                	neg    %eax
 5cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d2:	eb 06                	jmp    5da <printint+0x32>
  } else {
    x = xx;
 5d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5e1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5e4:	8d 41 01             	lea    0x1(%ecx),%eax
 5e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5f0:	ba 00 00 00 00       	mov    $0x0,%edx
 5f5:	f7 f3                	div    %ebx
 5f7:	89 d0                	mov    %edx,%eax
 5f9:	8a 80 c4 0c 00 00    	mov    0xcc4(%eax),%al
 5ff:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 603:	8b 75 10             	mov    0x10(%ebp),%esi
 606:	8b 45 ec             	mov    -0x14(%ebp),%eax
 609:	ba 00 00 00 00       	mov    $0x0,%edx
 60e:	f7 f6                	div    %esi
 610:	89 45 ec             	mov    %eax,-0x14(%ebp)
 613:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 617:	75 c8                	jne    5e1 <printint+0x39>
  if(neg)
 619:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 61d:	74 10                	je     62f <printint+0x87>
    buf[i++] = '-';
 61f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 622:	8d 50 01             	lea    0x1(%eax),%edx
 625:	89 55 f4             	mov    %edx,-0xc(%ebp)
 628:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 62d:	eb 1e                	jmp    64d <printint+0xa5>
 62f:	eb 1c                	jmp    64d <printint+0xa5>
    putc(fd, buf[i]);
 631:	8d 55 dc             	lea    -0x24(%ebp),%edx
 634:	8b 45 f4             	mov    -0xc(%ebp),%eax
 637:	01 d0                	add    %edx,%eax
 639:	8a 00                	mov    (%eax),%al
 63b:	0f be c0             	movsbl %al,%eax
 63e:	89 44 24 04          	mov    %eax,0x4(%esp)
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	89 04 24             	mov    %eax,(%esp)
 648:	e8 33 ff ff ff       	call   580 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 64d:	ff 4d f4             	decl   -0xc(%ebp)
 650:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 654:	79 db                	jns    631 <printint+0x89>
    putc(fd, buf[i]);
}
 656:	83 c4 30             	add    $0x30,%esp
 659:	5b                   	pop    %ebx
 65a:	5e                   	pop    %esi
 65b:	5d                   	pop    %ebp
 65c:	c3                   	ret    

0000065d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 65d:	55                   	push   %ebp
 65e:	89 e5                	mov    %esp,%ebp
 660:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 663:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 66a:	8d 45 0c             	lea    0xc(%ebp),%eax
 66d:	83 c0 04             	add    $0x4,%eax
 670:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 673:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 67a:	e9 77 01 00 00       	jmp    7f6 <printf+0x199>
    c = fmt[i] & 0xff;
 67f:	8b 55 0c             	mov    0xc(%ebp),%edx
 682:	8b 45 f0             	mov    -0x10(%ebp),%eax
 685:	01 d0                	add    %edx,%eax
 687:	8a 00                	mov    (%eax),%al
 689:	0f be c0             	movsbl %al,%eax
 68c:	25 ff 00 00 00       	and    $0xff,%eax
 691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 694:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 698:	75 2c                	jne    6c6 <printf+0x69>
      if(c == '%'){
 69a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 69e:	75 0c                	jne    6ac <printf+0x4f>
        state = '%';
 6a0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6a7:	e9 47 01 00 00       	jmp    7f3 <printf+0x196>
      } else {
        putc(fd, c);
 6ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6af:	0f be c0             	movsbl %al,%eax
 6b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
 6b9:	89 04 24             	mov    %eax,(%esp)
 6bc:	e8 bf fe ff ff       	call   580 <putc>
 6c1:	e9 2d 01 00 00       	jmp    7f3 <printf+0x196>
      }
    } else if(state == '%'){
 6c6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ca:	0f 85 23 01 00 00    	jne    7f3 <printf+0x196>
      if(c == 'd'){
 6d0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6d4:	75 2d                	jne    703 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d9:	8b 00                	mov    (%eax),%eax
 6db:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6e2:	00 
 6e3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6ea:	00 
 6eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	89 04 24             	mov    %eax,(%esp)
 6f5:	e8 ae fe ff ff       	call   5a8 <printint>
        ap++;
 6fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6fe:	e9 e9 00 00 00       	jmp    7ec <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 703:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 707:	74 06                	je     70f <printf+0xb2>
 709:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 70d:	75 2d                	jne    73c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 70f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 712:	8b 00                	mov    (%eax),%eax
 714:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 71b:	00 
 71c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 723:	00 
 724:	89 44 24 04          	mov    %eax,0x4(%esp)
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	89 04 24             	mov    %eax,(%esp)
 72e:	e8 75 fe ff ff       	call   5a8 <printint>
        ap++;
 733:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 737:	e9 b0 00 00 00       	jmp    7ec <printf+0x18f>
      } else if(c == 's'){
 73c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 740:	75 42                	jne    784 <printf+0x127>
        s = (char*)*ap;
 742:	8b 45 e8             	mov    -0x18(%ebp),%eax
 745:	8b 00                	mov    (%eax),%eax
 747:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 74a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 74e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 752:	75 09                	jne    75d <printf+0x100>
          s = "(null)";
 754:	c7 45 f4 54 0a 00 00 	movl   $0xa54,-0xc(%ebp)
        while(*s != 0){
 75b:	eb 1c                	jmp    779 <printf+0x11c>
 75d:	eb 1a                	jmp    779 <printf+0x11c>
          putc(fd, *s);
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	8a 00                	mov    (%eax),%al
 764:	0f be c0             	movsbl %al,%eax
 767:	89 44 24 04          	mov    %eax,0x4(%esp)
 76b:	8b 45 08             	mov    0x8(%ebp),%eax
 76e:	89 04 24             	mov    %eax,(%esp)
 771:	e8 0a fe ff ff       	call   580 <putc>
          s++;
 776:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 779:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77c:	8a 00                	mov    (%eax),%al
 77e:	84 c0                	test   %al,%al
 780:	75 dd                	jne    75f <printf+0x102>
 782:	eb 68                	jmp    7ec <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 784:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 788:	75 1d                	jne    7a7 <printf+0x14a>
        putc(fd, *ap);
 78a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78d:	8b 00                	mov    (%eax),%eax
 78f:	0f be c0             	movsbl %al,%eax
 792:	89 44 24 04          	mov    %eax,0x4(%esp)
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 df fd ff ff       	call   580 <putc>
        ap++;
 7a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a5:	eb 45                	jmp    7ec <printf+0x18f>
      } else if(c == '%'){
 7a7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ab:	75 17                	jne    7c4 <printf+0x167>
        putc(fd, c);
 7ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b0:	0f be c0             	movsbl %al,%eax
 7b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 be fd ff ff       	call   580 <putc>
 7c2:	eb 28                	jmp    7ec <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7cb:	00 
 7cc:	8b 45 08             	mov    0x8(%ebp),%eax
 7cf:	89 04 24             	mov    %eax,(%esp)
 7d2:	e8 a9 fd ff ff       	call   580 <putc>
        putc(fd, c);
 7d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7da:	0f be c0             	movsbl %al,%eax
 7dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e1:	8b 45 08             	mov    0x8(%ebp),%eax
 7e4:	89 04 24             	mov    %eax,(%esp)
 7e7:	e8 94 fd ff ff       	call   580 <putc>
      }
      state = 0;
 7ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7f3:	ff 45 f0             	incl   -0x10(%ebp)
 7f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fc:	01 d0                	add    %edx,%eax
 7fe:	8a 00                	mov    (%eax),%al
 800:	84 c0                	test   %al,%al
 802:	0f 85 77 fe ff ff    	jne    67f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 808:	c9                   	leave  
 809:	c3                   	ret    
 80a:	90                   	nop
 80b:	90                   	nop

0000080c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80c:	55                   	push   %ebp
 80d:	89 e5                	mov    %esp,%ebp
 80f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 812:	8b 45 08             	mov    0x8(%ebp),%eax
 815:	83 e8 08             	sub    $0x8,%eax
 818:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81b:	a1 e0 0c 00 00       	mov    0xce0,%eax
 820:	89 45 fc             	mov    %eax,-0x4(%ebp)
 823:	eb 24                	jmp    849 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 82d:	77 12                	ja     841 <free+0x35>
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 835:	77 24                	ja     85b <free+0x4f>
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	8b 00                	mov    (%eax),%eax
 83c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 83f:	77 1a                	ja     85b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 00                	mov    (%eax),%eax
 846:	89 45 fc             	mov    %eax,-0x4(%ebp)
 849:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 84f:	76 d4                	jbe    825 <free+0x19>
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 859:	76 ca                	jbe    825 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 85b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85e:	8b 40 04             	mov    0x4(%eax),%eax
 861:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 868:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86b:	01 c2                	add    %eax,%edx
 86d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 870:	8b 00                	mov    (%eax),%eax
 872:	39 c2                	cmp    %eax,%edx
 874:	75 24                	jne    89a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 876:	8b 45 f8             	mov    -0x8(%ebp),%eax
 879:	8b 50 04             	mov    0x4(%eax),%edx
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 00                	mov    (%eax),%eax
 881:	8b 40 04             	mov    0x4(%eax),%eax
 884:	01 c2                	add    %eax,%edx
 886:	8b 45 f8             	mov    -0x8(%ebp),%eax
 889:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 88c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88f:	8b 00                	mov    (%eax),%eax
 891:	8b 10                	mov    (%eax),%edx
 893:	8b 45 f8             	mov    -0x8(%ebp),%eax
 896:	89 10                	mov    %edx,(%eax)
 898:	eb 0a                	jmp    8a4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 89a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89d:	8b 10                	mov    (%eax),%edx
 89f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a7:	8b 40 04             	mov    0x4(%eax),%eax
 8aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b4:	01 d0                	add    %edx,%eax
 8b6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b9:	75 20                	jne    8db <free+0xcf>
    p->s.size += bp->s.size;
 8bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8be:	8b 50 04             	mov    0x4(%eax),%edx
 8c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c4:	8b 40 04             	mov    0x4(%eax),%eax
 8c7:	01 c2                	add    %eax,%edx
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	8b 10                	mov    (%eax),%edx
 8d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d7:	89 10                	mov    %edx,(%eax)
 8d9:	eb 08                	jmp    8e3 <free+0xd7>
  } else
    p->s.ptr = bp;
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e1:	89 10                	mov    %edx,(%eax)
  freep = p;
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	a3 e0 0c 00 00       	mov    %eax,0xce0
}
 8eb:	c9                   	leave  
 8ec:	c3                   	ret    

000008ed <morecore>:

static Header*
morecore(uint nu)
{
 8ed:	55                   	push   %ebp
 8ee:	89 e5                	mov    %esp,%ebp
 8f0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8f3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8fa:	77 07                	ja     903 <morecore+0x16>
    nu = 4096;
 8fc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 903:	8b 45 08             	mov    0x8(%ebp),%eax
 906:	c1 e0 03             	shl    $0x3,%eax
 909:	89 04 24             	mov    %eax,(%esp)
 90c:	e8 57 fb ff ff       	call   468 <sbrk>
 911:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 914:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 918:	75 07                	jne    921 <morecore+0x34>
    return 0;
 91a:	b8 00 00 00 00       	mov    $0x0,%eax
 91f:	eb 22                	jmp    943 <morecore+0x56>
  hp = (Header*)p;
 921:	8b 45 f4             	mov    -0xc(%ebp),%eax
 924:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 927:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92a:	8b 55 08             	mov    0x8(%ebp),%edx
 92d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 930:	8b 45 f0             	mov    -0x10(%ebp),%eax
 933:	83 c0 08             	add    $0x8,%eax
 936:	89 04 24             	mov    %eax,(%esp)
 939:	e8 ce fe ff ff       	call   80c <free>
  return freep;
 93e:	a1 e0 0c 00 00       	mov    0xce0,%eax
}
 943:	c9                   	leave  
 944:	c3                   	ret    

00000945 <malloc>:

void*
malloc(uint nbytes)
{
 945:	55                   	push   %ebp
 946:	89 e5                	mov    %esp,%ebp
 948:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 94b:	8b 45 08             	mov    0x8(%ebp),%eax
 94e:	83 c0 07             	add    $0x7,%eax
 951:	c1 e8 03             	shr    $0x3,%eax
 954:	40                   	inc    %eax
 955:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 958:	a1 e0 0c 00 00       	mov    0xce0,%eax
 95d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 960:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 964:	75 23                	jne    989 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 966:	c7 45 f0 d8 0c 00 00 	movl   $0xcd8,-0x10(%ebp)
 96d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 970:	a3 e0 0c 00 00       	mov    %eax,0xce0
 975:	a1 e0 0c 00 00       	mov    0xce0,%eax
 97a:	a3 d8 0c 00 00       	mov    %eax,0xcd8
    base.s.size = 0;
 97f:	c7 05 dc 0c 00 00 00 	movl   $0x0,0xcdc
 986:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 989:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98c:	8b 00                	mov    (%eax),%eax
 98e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 991:	8b 45 f4             	mov    -0xc(%ebp),%eax
 994:	8b 40 04             	mov    0x4(%eax),%eax
 997:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 99a:	72 4d                	jb     9e9 <malloc+0xa4>
      if(p->s.size == nunits)
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 40 04             	mov    0x4(%eax),%eax
 9a2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9a5:	75 0c                	jne    9b3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 9a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9aa:	8b 10                	mov    (%eax),%edx
 9ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9af:	89 10                	mov    %edx,(%eax)
 9b1:	eb 26                	jmp    9d9 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	8b 40 04             	mov    0x4(%eax),%eax
 9b9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9bc:	89 c2                	mov    %eax,%edx
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c7:	8b 40 04             	mov    0x4(%eax),%eax
 9ca:	c1 e0 03             	shl    $0x3,%eax
 9cd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9d6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	a3 e0 0c 00 00       	mov    %eax,0xce0
      return (void*)(p + 1);
 9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e4:	83 c0 08             	add    $0x8,%eax
 9e7:	eb 38                	jmp    a21 <malloc+0xdc>
    }
    if(p == freep)
 9e9:	a1 e0 0c 00 00       	mov    0xce0,%eax
 9ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9f1:	75 1b                	jne    a0e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9f6:	89 04 24             	mov    %eax,(%esp)
 9f9:	e8 ef fe ff ff       	call   8ed <morecore>
 9fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a05:	75 07                	jne    a0e <malloc+0xc9>
        return 0;
 a07:	b8 00 00 00 00       	mov    $0x0,%eax
 a0c:	eb 13                	jmp    a21 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a17:	8b 00                	mov    (%eax),%eax
 a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a1c:	e9 70 ff ff ff       	jmp    991 <malloc+0x4c>
}
 a21:	c9                   	leave  
 a22:	c3                   	ret    
