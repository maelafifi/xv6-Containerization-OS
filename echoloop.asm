
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
   f:	c7 44 24 04 44 0a 00 	movl   $0xa44,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 5a 06 00 00       	call   67d <printf>
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
  50:	b8 6b 0a 00 00       	mov    $0xa6b,%eax
  55:	eb 05                	jmp    5c <main+0x5c>
  57:	b8 6d 0a 00 00       	mov    $0xa6d,%eax
  5c:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  60:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  67:	8b 55 0c             	mov    0xc(%ebp),%edx
  6a:	01 ca                	add    %ecx,%edx
  6c:	8b 12                	mov    (%edx),%edx
  6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  72:	89 54 24 08          	mov    %edx,0x8(%esp)
  76:	c7 44 24 04 6f 0a 00 	movl   $0xa6f,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 f3 05 00 00       	call   67d <printf>
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

00000580 <get_os>:
SYSCALL(get_os)
 580:	b8 36 00 00 00       	mov    $0x36,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <set_os>:
SYSCALL(set_os)
 588:	b8 37 00 00 00       	mov    $0x37,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <get_cticks>:
SYSCALL(get_cticks)
 590:	b8 38 00 00 00       	mov    $0x38,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <tick_reset2>:
SYSCALL(tick_reset2)
 598:	b8 39 00 00 00       	mov    $0x39,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	83 ec 18             	sub    $0x18,%esp
 5a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5b3:	00 
 5b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 3a fe ff ff       	call   400 <write>
}
 5c6:	c9                   	leave  
 5c7:	c3                   	ret    

000005c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c8:	55                   	push   %ebp
 5c9:	89 e5                	mov    %esp,%ebp
 5cb:	56                   	push   %esi
 5cc:	53                   	push   %ebx
 5cd:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5d7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5db:	74 17                	je     5f4 <printint+0x2c>
 5dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e1:	79 11                	jns    5f4 <printint+0x2c>
    neg = 1;
 5e3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ed:	f7 d8                	neg    %eax
 5ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f2:	eb 06                	jmp    5fa <printint+0x32>
  } else {
    x = xx;
 5f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 601:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 604:	8d 41 01             	lea    0x1(%ecx),%eax
 607:	89 45 f4             	mov    %eax,-0xc(%ebp)
 60a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 60d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 610:	ba 00 00 00 00       	mov    $0x0,%edx
 615:	f7 f3                	div    %ebx
 617:	89 d0                	mov    %edx,%eax
 619:	8a 80 e4 0c 00 00    	mov    0xce4(%eax),%al
 61f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 623:	8b 75 10             	mov    0x10(%ebp),%esi
 626:	8b 45 ec             	mov    -0x14(%ebp),%eax
 629:	ba 00 00 00 00       	mov    $0x0,%edx
 62e:	f7 f6                	div    %esi
 630:	89 45 ec             	mov    %eax,-0x14(%ebp)
 633:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 637:	75 c8                	jne    601 <printint+0x39>
  if(neg)
 639:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 63d:	74 10                	je     64f <printint+0x87>
    buf[i++] = '-';
 63f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 642:	8d 50 01             	lea    0x1(%eax),%edx
 645:	89 55 f4             	mov    %edx,-0xc(%ebp)
 648:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 64d:	eb 1e                	jmp    66d <printint+0xa5>
 64f:	eb 1c                	jmp    66d <printint+0xa5>
    putc(fd, buf[i]);
 651:	8d 55 dc             	lea    -0x24(%ebp),%edx
 654:	8b 45 f4             	mov    -0xc(%ebp),%eax
 657:	01 d0                	add    %edx,%eax
 659:	8a 00                	mov    (%eax),%al
 65b:	0f be c0             	movsbl %al,%eax
 65e:	89 44 24 04          	mov    %eax,0x4(%esp)
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	89 04 24             	mov    %eax,(%esp)
 668:	e8 33 ff ff ff       	call   5a0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 66d:	ff 4d f4             	decl   -0xc(%ebp)
 670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 674:	79 db                	jns    651 <printint+0x89>
    putc(fd, buf[i]);
}
 676:	83 c4 30             	add    $0x30,%esp
 679:	5b                   	pop    %ebx
 67a:	5e                   	pop    %esi
 67b:	5d                   	pop    %ebp
 67c:	c3                   	ret    

0000067d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 67d:	55                   	push   %ebp
 67e:	89 e5                	mov    %esp,%ebp
 680:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 683:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 68a:	8d 45 0c             	lea    0xc(%ebp),%eax
 68d:	83 c0 04             	add    $0x4,%eax
 690:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 693:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 69a:	e9 77 01 00 00       	jmp    816 <printf+0x199>
    c = fmt[i] & 0xff;
 69f:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a5:	01 d0                	add    %edx,%eax
 6a7:	8a 00                	mov    (%eax),%al
 6a9:	0f be c0             	movsbl %al,%eax
 6ac:	25 ff 00 00 00       	and    $0xff,%eax
 6b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b8:	75 2c                	jne    6e6 <printf+0x69>
      if(c == '%'){
 6ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6be:	75 0c                	jne    6cc <printf+0x4f>
        state = '%';
 6c0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6c7:	e9 47 01 00 00       	jmp    813 <printf+0x196>
      } else {
        putc(fd, c);
 6cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6cf:	0f be c0             	movsbl %al,%eax
 6d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d6:	8b 45 08             	mov    0x8(%ebp),%eax
 6d9:	89 04 24             	mov    %eax,(%esp)
 6dc:	e8 bf fe ff ff       	call   5a0 <putc>
 6e1:	e9 2d 01 00 00       	jmp    813 <printf+0x196>
      }
    } else if(state == '%'){
 6e6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ea:	0f 85 23 01 00 00    	jne    813 <printf+0x196>
      if(c == 'd'){
 6f0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f4:	75 2d                	jne    723 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 702:	00 
 703:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 70a:	00 
 70b:	89 44 24 04          	mov    %eax,0x4(%esp)
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	89 04 24             	mov    %eax,(%esp)
 715:	e8 ae fe ff ff       	call   5c8 <printint>
        ap++;
 71a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71e:	e9 e9 00 00 00       	jmp    80c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 723:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 727:	74 06                	je     72f <printf+0xb2>
 729:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 72d:	75 2d                	jne    75c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 72f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 73b:	00 
 73c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 743:	00 
 744:	89 44 24 04          	mov    %eax,0x4(%esp)
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	89 04 24             	mov    %eax,(%esp)
 74e:	e8 75 fe ff ff       	call   5c8 <printint>
        ap++;
 753:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 757:	e9 b0 00 00 00       	jmp    80c <printf+0x18f>
      } else if(c == 's'){
 75c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 760:	75 42                	jne    7a4 <printf+0x127>
        s = (char*)*ap;
 762:	8b 45 e8             	mov    -0x18(%ebp),%eax
 765:	8b 00                	mov    (%eax),%eax
 767:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 76a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 76e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 772:	75 09                	jne    77d <printf+0x100>
          s = "(null)";
 774:	c7 45 f4 74 0a 00 00 	movl   $0xa74,-0xc(%ebp)
        while(*s != 0){
 77b:	eb 1c                	jmp    799 <printf+0x11c>
 77d:	eb 1a                	jmp    799 <printf+0x11c>
          putc(fd, *s);
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	8a 00                	mov    (%eax),%al
 784:	0f be c0             	movsbl %al,%eax
 787:	89 44 24 04          	mov    %eax,0x4(%esp)
 78b:	8b 45 08             	mov    0x8(%ebp),%eax
 78e:	89 04 24             	mov    %eax,(%esp)
 791:	e8 0a fe ff ff       	call   5a0 <putc>
          s++;
 796:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 799:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79c:	8a 00                	mov    (%eax),%al
 79e:	84 c0                	test   %al,%al
 7a0:	75 dd                	jne    77f <printf+0x102>
 7a2:	eb 68                	jmp    80c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7a4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7a8:	75 1d                	jne    7c7 <printf+0x14a>
        putc(fd, *ap);
 7aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ad:	8b 00                	mov    (%eax),%eax
 7af:	0f be c0             	movsbl %al,%eax
 7b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b6:	8b 45 08             	mov    0x8(%ebp),%eax
 7b9:	89 04 24             	mov    %eax,(%esp)
 7bc:	e8 df fd ff ff       	call   5a0 <putc>
        ap++;
 7c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c5:	eb 45                	jmp    80c <printf+0x18f>
      } else if(c == '%'){
 7c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7cb:	75 17                	jne    7e4 <printf+0x167>
        putc(fd, c);
 7cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d0:	0f be c0             	movsbl %al,%eax
 7d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d7:	8b 45 08             	mov    0x8(%ebp),%eax
 7da:	89 04 24             	mov    %eax,(%esp)
 7dd:	e8 be fd ff ff       	call   5a0 <putc>
 7e2:	eb 28                	jmp    80c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7e4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7eb:	00 
 7ec:	8b 45 08             	mov    0x8(%ebp),%eax
 7ef:	89 04 24             	mov    %eax,(%esp)
 7f2:	e8 a9 fd ff ff       	call   5a0 <putc>
        putc(fd, c);
 7f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fa:	0f be c0             	movsbl %al,%eax
 7fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 801:	8b 45 08             	mov    0x8(%ebp),%eax
 804:	89 04 24             	mov    %eax,(%esp)
 807:	e8 94 fd ff ff       	call   5a0 <putc>
      }
      state = 0;
 80c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 813:	ff 45 f0             	incl   -0x10(%ebp)
 816:	8b 55 0c             	mov    0xc(%ebp),%edx
 819:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81c:	01 d0                	add    %edx,%eax
 81e:	8a 00                	mov    (%eax),%al
 820:	84 c0                	test   %al,%al
 822:	0f 85 77 fe ff ff    	jne    69f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 828:	c9                   	leave  
 829:	c3                   	ret    
 82a:	90                   	nop
 82b:	90                   	nop

0000082c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82c:	55                   	push   %ebp
 82d:	89 e5                	mov    %esp,%ebp
 82f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 832:	8b 45 08             	mov    0x8(%ebp),%eax
 835:	83 e8 08             	sub    $0x8,%eax
 838:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83b:	a1 00 0d 00 00       	mov    0xd00,%eax
 840:	89 45 fc             	mov    %eax,-0x4(%ebp)
 843:	eb 24                	jmp    869 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 84d:	77 12                	ja     861 <free+0x35>
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 855:	77 24                	ja     87b <free+0x4f>
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 00                	mov    (%eax),%eax
 85c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85f:	77 1a                	ja     87b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	89 45 fc             	mov    %eax,-0x4(%ebp)
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86f:	76 d4                	jbe    845 <free+0x19>
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 879:	76 ca                	jbe    845 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	8b 40 04             	mov    0x4(%eax),%eax
 881:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 888:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88b:	01 c2                	add    %eax,%edx
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	39 c2                	cmp    %eax,%edx
 894:	75 24                	jne    8ba <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 896:	8b 45 f8             	mov    -0x8(%ebp),%eax
 899:	8b 50 04             	mov    0x4(%eax),%edx
 89c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89f:	8b 00                	mov    (%eax),%eax
 8a1:	8b 40 04             	mov    0x4(%eax),%eax
 8a4:	01 c2                	add    %eax,%edx
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8af:	8b 00                	mov    (%eax),%eax
 8b1:	8b 10                	mov    (%eax),%edx
 8b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b6:	89 10                	mov    %edx,(%eax)
 8b8:	eb 0a                	jmp    8c4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	8b 10                	mov    (%eax),%edx
 8bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 40 04             	mov    0x4(%eax),%eax
 8ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	01 d0                	add    %edx,%eax
 8d6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8d9:	75 20                	jne    8fb <free+0xcf>
    p->s.size += bp->s.size;
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	8b 50 04             	mov    0x4(%eax),%edx
 8e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e4:	8b 40 04             	mov    0x4(%eax),%eax
 8e7:	01 c2                	add    %eax,%edx
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f2:	8b 10                	mov    (%eax),%edx
 8f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f7:	89 10                	mov    %edx,(%eax)
 8f9:	eb 08                	jmp    903 <free+0xd7>
  } else
    p->s.ptr = bp;
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	8b 55 f8             	mov    -0x8(%ebp),%edx
 901:	89 10                	mov    %edx,(%eax)
  freep = p;
 903:	8b 45 fc             	mov    -0x4(%ebp),%eax
 906:	a3 00 0d 00 00       	mov    %eax,0xd00
}
 90b:	c9                   	leave  
 90c:	c3                   	ret    

0000090d <morecore>:

static Header*
morecore(uint nu)
{
 90d:	55                   	push   %ebp
 90e:	89 e5                	mov    %esp,%ebp
 910:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 913:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 91a:	77 07                	ja     923 <morecore+0x16>
    nu = 4096;
 91c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 923:	8b 45 08             	mov    0x8(%ebp),%eax
 926:	c1 e0 03             	shl    $0x3,%eax
 929:	89 04 24             	mov    %eax,(%esp)
 92c:	e8 37 fb ff ff       	call   468 <sbrk>
 931:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 934:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 938:	75 07                	jne    941 <morecore+0x34>
    return 0;
 93a:	b8 00 00 00 00       	mov    $0x0,%eax
 93f:	eb 22                	jmp    963 <morecore+0x56>
  hp = (Header*)p;
 941:	8b 45 f4             	mov    -0xc(%ebp),%eax
 944:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 947:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94a:	8b 55 08             	mov    0x8(%ebp),%edx
 94d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 950:	8b 45 f0             	mov    -0x10(%ebp),%eax
 953:	83 c0 08             	add    $0x8,%eax
 956:	89 04 24             	mov    %eax,(%esp)
 959:	e8 ce fe ff ff       	call   82c <free>
  return freep;
 95e:	a1 00 0d 00 00       	mov    0xd00,%eax
}
 963:	c9                   	leave  
 964:	c3                   	ret    

00000965 <malloc>:

void*
malloc(uint nbytes)
{
 965:	55                   	push   %ebp
 966:	89 e5                	mov    %esp,%ebp
 968:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 96b:	8b 45 08             	mov    0x8(%ebp),%eax
 96e:	83 c0 07             	add    $0x7,%eax
 971:	c1 e8 03             	shr    $0x3,%eax
 974:	40                   	inc    %eax
 975:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 978:	a1 00 0d 00 00       	mov    0xd00,%eax
 97d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 984:	75 23                	jne    9a9 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 986:	c7 45 f0 f8 0c 00 00 	movl   $0xcf8,-0x10(%ebp)
 98d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 990:	a3 00 0d 00 00       	mov    %eax,0xd00
 995:	a1 00 0d 00 00       	mov    0xd00,%eax
 99a:	a3 f8 0c 00 00       	mov    %eax,0xcf8
    base.s.size = 0;
 99f:	c7 05 fc 0c 00 00 00 	movl   $0x0,0xcfc
 9a6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ac:	8b 00                	mov    (%eax),%eax
 9ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	8b 40 04             	mov    0x4(%eax),%eax
 9b7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ba:	72 4d                	jb     a09 <malloc+0xa4>
      if(p->s.size == nunits)
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	8b 40 04             	mov    0x4(%eax),%eax
 9c2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9c5:	75 0c                	jne    9d3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 9c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ca:	8b 10                	mov    (%eax),%edx
 9cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cf:	89 10                	mov    %edx,(%eax)
 9d1:	eb 26                	jmp    9f9 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d6:	8b 40 04             	mov    0x4(%eax),%eax
 9d9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9dc:	89 c2                	mov    %eax,%edx
 9de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e7:	8b 40 04             	mov    0x4(%eax),%eax
 9ea:	c1 e0 03             	shl    $0x3,%eax
 9ed:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9f6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	a3 00 0d 00 00       	mov    %eax,0xd00
      return (void*)(p + 1);
 a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a04:	83 c0 08             	add    $0x8,%eax
 a07:	eb 38                	jmp    a41 <malloc+0xdc>
    }
    if(p == freep)
 a09:	a1 00 0d 00 00       	mov    0xd00,%eax
 a0e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a11:	75 1b                	jne    a2e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a16:	89 04 24             	mov    %eax,(%esp)
 a19:	e8 ef fe ff ff       	call   90d <morecore>
 a1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a25:	75 07                	jne    a2e <malloc+0xc9>
        return 0;
 a27:	b8 00 00 00 00       	mov    $0x0,%eax
 a2c:	eb 13                	jmp    a41 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 00                	mov    (%eax),%eax
 a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a3c:	e9 70 ff ff ff       	jmp    9b1 <malloc+0x4c>
}
 a41:	c9                   	leave  
 a42:	c3                   	ret    
