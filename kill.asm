
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 f3 09 00 	movl   $0x9f3,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 0a 06 00 00       	call   62d <printf>
    exit();
  23:	e8 78 03 00 00       	call   3a0 <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 26                	jmp    58 <main+0x58>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 df 01 00 00       	call   22b <atoi>
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 7c 03 00 00       	call   3d0 <kill>

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  54:	ff 44 24 1c          	incl   0x1c(%esp)
  58:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5c:	3b 45 08             	cmp    0x8(%ebp),%eax
  5f:	7c d1                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  61:	e8 3a 03 00 00       	call   3a0 <exit>
  66:	90                   	nop
  67:	90                   	nop

00000068 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	57                   	push   %edi
  6c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  70:	8b 55 10             	mov    0x10(%ebp),%edx
  73:	8b 45 0c             	mov    0xc(%ebp),%eax
  76:	89 cb                	mov    %ecx,%ebx
  78:	89 df                	mov    %ebx,%edi
  7a:	89 d1                	mov    %edx,%ecx
  7c:	fc                   	cld    
  7d:	f3 aa                	rep stos %al,%es:(%edi)
  7f:	89 ca                	mov    %ecx,%edx
  81:	89 fb                	mov    %edi,%ebx
  83:	89 5d 08             	mov    %ebx,0x8(%ebp)
  86:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  89:	5b                   	pop    %ebx
  8a:	5f                   	pop    %edi
  8b:	5d                   	pop    %ebp
  8c:	c3                   	ret    

0000008d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  99:	90                   	nop
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	8d 50 01             	lea    0x1(%eax),%edx
  a0:	89 55 08             	mov    %edx,0x8(%ebp)
  a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  a6:	8d 4a 01             	lea    0x1(%edx),%ecx
  a9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ac:	8a 12                	mov    (%edx),%dl
  ae:	88 10                	mov    %dl,(%eax)
  b0:	8a 00                	mov    (%eax),%al
  b2:	84 c0                	test   %al,%al
  b4:	75 e4                	jne    9a <strcpy+0xd>
    ;
  return os;
  b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b9:	c9                   	leave  
  ba:	c3                   	ret    

000000bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  be:	eb 06                	jmp    c6 <strcmp+0xb>
    p++, q++;
  c0:	ff 45 08             	incl   0x8(%ebp)
  c3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c6:	8b 45 08             	mov    0x8(%ebp),%eax
  c9:	8a 00                	mov    (%eax),%al
  cb:	84 c0                	test   %al,%al
  cd:	74 0e                	je     dd <strcmp+0x22>
  cf:	8b 45 08             	mov    0x8(%ebp),%eax
  d2:	8a 10                	mov    (%eax),%dl
  d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  d7:	8a 00                	mov    (%eax),%al
  d9:	38 c2                	cmp    %al,%dl
  db:	74 e3                	je     c0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	8a 00                	mov    (%eax),%al
  e2:	0f b6 d0             	movzbl %al,%edx
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	8a 00                	mov    (%eax),%al
  ea:	0f b6 c0             	movzbl %al,%eax
  ed:	29 c2                	sub    %eax,%edx
  ef:	89 d0                	mov    %edx,%eax
}
  f1:	5d                   	pop    %ebp
  f2:	c3                   	ret    

000000f3 <strlen>:

uint
strlen(char *s)
{
  f3:	55                   	push   %ebp
  f4:	89 e5                	mov    %esp,%ebp
  f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 100:	eb 03                	jmp    105 <strlen+0x12>
 102:	ff 45 fc             	incl   -0x4(%ebp)
 105:	8b 55 fc             	mov    -0x4(%ebp),%edx
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	01 d0                	add    %edx,%eax
 10d:	8a 00                	mov    (%eax),%al
 10f:	84 c0                	test   %al,%al
 111:	75 ef                	jne    102 <strlen+0xf>
    ;
  return n;
 113:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 116:	c9                   	leave  
 117:	c3                   	ret    

00000118 <memset>:

void*
memset(void *dst, int c, uint n)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 11e:	8b 45 10             	mov    0x10(%ebp),%eax
 121:	89 44 24 08          	mov    %eax,0x8(%esp)
 125:	8b 45 0c             	mov    0xc(%ebp),%eax
 128:	89 44 24 04          	mov    %eax,0x4(%esp)
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 31 ff ff ff       	call   68 <stosb>
  return dst;
 137:	8b 45 08             	mov    0x8(%ebp),%eax
}
 13a:	c9                   	leave  
 13b:	c3                   	ret    

0000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	83 ec 04             	sub    $0x4,%esp
 142:	8b 45 0c             	mov    0xc(%ebp),%eax
 145:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 148:	eb 12                	jmp    15c <strchr+0x20>
    if(*s == c)
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
 14d:	8a 00                	mov    (%eax),%al
 14f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 152:	75 05                	jne    159 <strchr+0x1d>
      return (char*)s;
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	eb 11                	jmp    16a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 159:	ff 45 08             	incl   0x8(%ebp)
 15c:	8b 45 08             	mov    0x8(%ebp),%eax
 15f:	8a 00                	mov    (%eax),%al
 161:	84 c0                	test   %al,%al
 163:	75 e5                	jne    14a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 165:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16a:	c9                   	leave  
 16b:	c3                   	ret    

0000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 179:	eb 49                	jmp    1c4 <gets+0x58>
    cc = read(0, &c, 1);
 17b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 182:	00 
 183:	8d 45 ef             	lea    -0x11(%ebp),%eax
 186:	89 44 24 04          	mov    %eax,0x4(%esp)
 18a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 191:	e8 22 02 00 00       	call   3b8 <read>
 196:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 199:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 19d:	7f 02                	jg     1a1 <gets+0x35>
      break;
 19f:	eb 2c                	jmp    1cd <gets+0x61>
    buf[i++] = c;
 1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a4:	8d 50 01             	lea    0x1(%eax),%edx
 1a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1aa:	89 c2                	mov    %eax,%edx
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	01 c2                	add    %eax,%edx
 1b1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1b6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b9:	3c 0a                	cmp    $0xa,%al
 1bb:	74 10                	je     1cd <gets+0x61>
 1bd:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c0:	3c 0d                	cmp    $0xd,%al
 1c2:	74 09                	je     1cd <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c7:	40                   	inc    %eax
 1c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1cb:	7c ae                	jl     17b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 d0                	add    %edx,%eax
 1d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1db:	c9                   	leave  
 1dc:	c3                   	ret    

000001dd <stat>:

int
stat(char *n, struct stat *st)
{
 1dd:	55                   	push   %ebp
 1de:	89 e5                	mov    %esp,%ebp
 1e0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1ea:	00 
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ee:	89 04 24             	mov    %eax,(%esp)
 1f1:	e8 ea 01 00 00       	call   3e0 <open>
 1f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1fd:	79 07                	jns    206 <stat+0x29>
    return -1;
 1ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 204:	eb 23                	jmp    229 <stat+0x4c>
  r = fstat(fd, st);
 206:	8b 45 0c             	mov    0xc(%ebp),%eax
 209:	89 44 24 04          	mov    %eax,0x4(%esp)
 20d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 210:	89 04 24             	mov    %eax,(%esp)
 213:	e8 e0 01 00 00       	call   3f8 <fstat>
 218:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 21b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21e:	89 04 24             	mov    %eax,(%esp)
 221:	e8 a2 01 00 00       	call   3c8 <close>
  return r;
 226:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 229:	c9                   	leave  
 22a:	c3                   	ret    

0000022b <atoi>:

int
atoi(const char *s)
{
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 231:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 238:	eb 24                	jmp    25e <atoi+0x33>
    n = n*10 + *s++ - '0';
 23a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23d:	89 d0                	mov    %edx,%eax
 23f:	c1 e0 02             	shl    $0x2,%eax
 242:	01 d0                	add    %edx,%eax
 244:	01 c0                	add    %eax,%eax
 246:	89 c1                	mov    %eax,%ecx
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	8d 50 01             	lea    0x1(%eax),%edx
 24e:	89 55 08             	mov    %edx,0x8(%ebp)
 251:	8a 00                	mov    (%eax),%al
 253:	0f be c0             	movsbl %al,%eax
 256:	01 c8                	add    %ecx,%eax
 258:	83 e8 30             	sub    $0x30,%eax
 25b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	8a 00                	mov    (%eax),%al
 263:	3c 2f                	cmp    $0x2f,%al
 265:	7e 09                	jle    270 <atoi+0x45>
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	8a 00                	mov    (%eax),%al
 26c:	3c 39                	cmp    $0x39,%al
 26e:	7e ca                	jle    23a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 270:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 281:	8b 45 0c             	mov    0xc(%ebp),%eax
 284:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 287:	eb 16                	jmp    29f <memmove+0x2a>
    *dst++ = *src++;
 289:	8b 45 fc             	mov    -0x4(%ebp),%eax
 28c:	8d 50 01             	lea    0x1(%eax),%edx
 28f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 292:	8b 55 f8             	mov    -0x8(%ebp),%edx
 295:	8d 4a 01             	lea    0x1(%edx),%ecx
 298:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 29b:	8a 12                	mov    (%edx),%dl
 29d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 29f:	8b 45 10             	mov    0x10(%ebp),%eax
 2a2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a5:	89 55 10             	mov    %edx,0x10(%ebp)
 2a8:	85 c0                	test   %eax,%eax
 2aa:	7f dd                	jg     289 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave  
 2b0:	c3                   	ret    

000002b1 <itoa>:

int itoa(int value, char *sp, int radix)
{
 2b1:	55                   	push   %ebp
 2b2:	89 e5                	mov    %esp,%ebp
 2b4:	53                   	push   %ebx
 2b5:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2b8:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2be:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 2c2:	75 0d                	jne    2d1 <itoa+0x20>
 2c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2c8:	79 07                	jns    2d1 <itoa+0x20>
 2ca:	b8 01 00 00 00       	mov    $0x1,%eax
 2cf:	eb 05                	jmp    2d6 <itoa+0x25>
 2d1:	b8 00 00 00 00       	mov    $0x0,%eax
 2d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 2d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2dd:	74 0a                	je     2e9 <itoa+0x38>
      v = -value;
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	f7 d8                	neg    %eax
 2e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2e7:	eb 54                	jmp    33d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 2ef:	eb 4c                	jmp    33d <itoa+0x8c>
  {
    i = v % radix;
 2f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f7:	ba 00 00 00 00       	mov    $0x0,%edx
 2fc:	f7 f1                	div    %ecx
 2fe:	89 d0                	mov    %edx,%eax
 300:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 303:	8b 5d 10             	mov    0x10(%ebp),%ebx
 306:	8b 45 f4             	mov    -0xc(%ebp),%eax
 309:	ba 00 00 00 00       	mov    $0x0,%edx
 30e:	f7 f3                	div    %ebx
 310:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 313:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 317:	7f 13                	jg     32c <itoa+0x7b>
      *tp++ = i+'0';
 319:	8b 45 f8             	mov    -0x8(%ebp),%eax
 31c:	8d 50 01             	lea    0x1(%eax),%edx
 31f:	89 55 f8             	mov    %edx,-0x8(%ebp)
 322:	8b 55 e8             	mov    -0x18(%ebp),%edx
 325:	83 c2 30             	add    $0x30,%edx
 328:	88 10                	mov    %dl,(%eax)
 32a:	eb 11                	jmp    33d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 32c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 32f:	8d 50 01             	lea    0x1(%eax),%edx
 332:	89 55 f8             	mov    %edx,-0x8(%ebp)
 335:	8b 55 e8             	mov    -0x18(%ebp),%edx
 338:	83 c2 57             	add    $0x57,%edx
 33b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 33d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 341:	75 ae                	jne    2f1 <itoa+0x40>
 343:	8d 45 d8             	lea    -0x28(%ebp),%eax
 346:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 349:	74 a6                	je     2f1 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 34b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 34e:	8d 45 d8             	lea    -0x28(%ebp),%eax
 351:	29 c2                	sub    %eax,%edx
 353:	89 d0                	mov    %edx,%eax
 355:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 358:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 35c:	74 11                	je     36f <itoa+0xbe>
  {
    *sp++ = '-';
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	8d 50 01             	lea    0x1(%eax),%edx
 364:	89 55 0c             	mov    %edx,0xc(%ebp)
 367:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 36a:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 36d:	eb 15                	jmp    384 <itoa+0xd3>
 36f:	eb 13                	jmp    384 <itoa+0xd3>
    *sp++ = *--tp;
 371:	8b 45 0c             	mov    0xc(%ebp),%eax
 374:	8d 50 01             	lea    0x1(%eax),%edx
 377:	89 55 0c             	mov    %edx,0xc(%ebp)
 37a:	ff 4d f8             	decl   -0x8(%ebp)
 37d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 380:	8a 12                	mov    (%edx),%dl
 382:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 384:	8d 45 d8             	lea    -0x28(%ebp),%eax
 387:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 38a:	77 e5                	ja     371 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 38c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 38f:	83 c4 30             	add    $0x30,%esp
 392:	5b                   	pop    %ebx
 393:	5d                   	pop    %ebp
 394:	c3                   	ret    
 395:	90                   	nop
 396:	90                   	nop
 397:	90                   	nop

00000398 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 398:	b8 01 00 00 00       	mov    $0x1,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <exit>:
SYSCALL(exit)
 3a0:	b8 02 00 00 00       	mov    $0x2,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <wait>:
SYSCALL(wait)
 3a8:	b8 03 00 00 00       	mov    $0x3,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <pipe>:
SYSCALL(pipe)
 3b0:	b8 04 00 00 00       	mov    $0x4,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <read>:
SYSCALL(read)
 3b8:	b8 05 00 00 00       	mov    $0x5,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <write>:
SYSCALL(write)
 3c0:	b8 10 00 00 00       	mov    $0x10,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <close>:
SYSCALL(close)
 3c8:	b8 15 00 00 00       	mov    $0x15,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <kill>:
SYSCALL(kill)
 3d0:	b8 06 00 00 00       	mov    $0x6,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <exec>:
SYSCALL(exec)
 3d8:	b8 07 00 00 00       	mov    $0x7,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <open>:
SYSCALL(open)
 3e0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <mknod>:
SYSCALL(mknod)
 3e8:	b8 11 00 00 00       	mov    $0x11,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <unlink>:
SYSCALL(unlink)
 3f0:	b8 12 00 00 00       	mov    $0x12,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <fstat>:
SYSCALL(fstat)
 3f8:	b8 08 00 00 00       	mov    $0x8,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <link>:
SYSCALL(link)
 400:	b8 13 00 00 00       	mov    $0x13,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <mkdir>:
SYSCALL(mkdir)
 408:	b8 14 00 00 00       	mov    $0x14,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <chdir>:
SYSCALL(chdir)
 410:	b8 09 00 00 00       	mov    $0x9,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <dup>:
SYSCALL(dup)
 418:	b8 0a 00 00 00       	mov    $0xa,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <getpid>:
SYSCALL(getpid)
 420:	b8 0b 00 00 00       	mov    $0xb,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <sbrk>:
SYSCALL(sbrk)
 428:	b8 0c 00 00 00       	mov    $0xc,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <sleep>:
SYSCALL(sleep)
 430:	b8 0d 00 00 00       	mov    $0xd,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <uptime>:
SYSCALL(uptime)
 438:	b8 0e 00 00 00       	mov    $0xe,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <getticks>:
SYSCALL(getticks)
 440:	b8 16 00 00 00       	mov    $0x16,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <get_name>:
SYSCALL(get_name)
 448:	b8 17 00 00 00       	mov    $0x17,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <get_max_proc>:
SYSCALL(get_max_proc)
 450:	b8 18 00 00 00       	mov    $0x18,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <get_max_mem>:
SYSCALL(get_max_mem)
 458:	b8 19 00 00 00       	mov    $0x19,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <get_max_disk>:
SYSCALL(get_max_disk)
 460:	b8 1a 00 00 00       	mov    $0x1a,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <get_curr_proc>:
SYSCALL(get_curr_proc)
 468:	b8 1b 00 00 00       	mov    $0x1b,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <get_curr_mem>:
SYSCALL(get_curr_mem)
 470:	b8 1c 00 00 00       	mov    $0x1c,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <get_curr_disk>:
SYSCALL(get_curr_disk)
 478:	b8 1d 00 00 00       	mov    $0x1d,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <set_name>:
SYSCALL(set_name)
 480:	b8 1e 00 00 00       	mov    $0x1e,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <set_max_mem>:
SYSCALL(set_max_mem)
 488:	b8 1f 00 00 00       	mov    $0x1f,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <set_max_disk>:
SYSCALL(set_max_disk)
 490:	b8 20 00 00 00       	mov    $0x20,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <set_max_proc>:
SYSCALL(set_max_proc)
 498:	b8 21 00 00 00       	mov    $0x21,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <set_curr_mem>:
SYSCALL(set_curr_mem)
 4a0:	b8 22 00 00 00       	mov    $0x22,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <set_curr_disk>:
SYSCALL(set_curr_disk)
 4a8:	b8 23 00 00 00       	mov    $0x23,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4b0:	b8 24 00 00 00       	mov    $0x24,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <find>:
SYSCALL(find)
 4b8:	b8 25 00 00 00       	mov    $0x25,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <is_full>:
SYSCALL(is_full)
 4c0:	b8 26 00 00 00       	mov    $0x26,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <container_init>:
SYSCALL(container_init)
 4c8:	b8 27 00 00 00       	mov    $0x27,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <cont_proc_set>:
SYSCALL(cont_proc_set)
 4d0:	b8 28 00 00 00       	mov    $0x28,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <ps>:
SYSCALL(ps)
 4d8:	b8 29 00 00 00       	mov    $0x29,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 4e0:	b8 2a 00 00 00       	mov    $0x2a,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <set_root_inode>:
SYSCALL(set_root_inode)
 4e8:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <cstop>:
SYSCALL(cstop)
 4f0:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <df>:
SYSCALL(df)
 4f8:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <max_containers>:
SYSCALL(max_containers)
 500:	b8 2e 00 00 00       	mov    $0x2e,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <container_reset>:
SYSCALL(container_reset)
 508:	b8 2f 00 00 00       	mov    $0x2f,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <pause>:
SYSCALL(pause)
 510:	b8 30 00 00 00       	mov    $0x30,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <resume>:
SYSCALL(resume)
 518:	b8 31 00 00 00       	mov    $0x31,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <tmem>:
SYSCALL(tmem)
 520:	b8 32 00 00 00       	mov    $0x32,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <amem>:
SYSCALL(amem)
 528:	b8 33 00 00 00       	mov    $0x33,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <c_ps>:
SYSCALL(c_ps)
 530:	b8 34 00 00 00       	mov    $0x34,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <get_used>:
SYSCALL(get_used)
 538:	b8 35 00 00 00       	mov    $0x35,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <get_os>:
SYSCALL(get_os)
 540:	b8 36 00 00 00       	mov    $0x36,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <set_os>:
SYSCALL(set_os)
 548:	b8 37 00 00 00       	mov    $0x37,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	83 ec 18             	sub    $0x18,%esp
 556:	8b 45 0c             	mov    0xc(%ebp),%eax
 559:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 55c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 563:	00 
 564:	8d 45 f4             	lea    -0xc(%ebp),%eax
 567:	89 44 24 04          	mov    %eax,0x4(%esp)
 56b:	8b 45 08             	mov    0x8(%ebp),%eax
 56e:	89 04 24             	mov    %eax,(%esp)
 571:	e8 4a fe ff ff       	call   3c0 <write>
}
 576:	c9                   	leave  
 577:	c3                   	ret    

00000578 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	56                   	push   %esi
 57c:	53                   	push   %ebx
 57d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 580:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 587:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 58b:	74 17                	je     5a4 <printint+0x2c>
 58d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 591:	79 11                	jns    5a4 <printint+0x2c>
    neg = 1;
 593:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 59a:	8b 45 0c             	mov    0xc(%ebp),%eax
 59d:	f7 d8                	neg    %eax
 59f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a2:	eb 06                	jmp    5aa <printint+0x32>
  } else {
    x = xx;
 5a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5b1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5b4:	8d 41 01             	lea    0x1(%ecx),%eax
 5b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c0:	ba 00 00 00 00       	mov    $0x0,%edx
 5c5:	f7 f3                	div    %ebx
 5c7:	89 d0                	mov    %edx,%eax
 5c9:	8a 80 78 0c 00 00    	mov    0xc78(%eax),%al
 5cf:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5d3:	8b 75 10             	mov    0x10(%ebp),%esi
 5d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d9:	ba 00 00 00 00       	mov    $0x0,%edx
 5de:	f7 f6                	div    %esi
 5e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e7:	75 c8                	jne    5b1 <printint+0x39>
  if(neg)
 5e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5ed:	74 10                	je     5ff <printint+0x87>
    buf[i++] = '-';
 5ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f2:	8d 50 01             	lea    0x1(%eax),%edx
 5f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5f8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5fd:	eb 1e                	jmp    61d <printint+0xa5>
 5ff:	eb 1c                	jmp    61d <printint+0xa5>
    putc(fd, buf[i]);
 601:	8d 55 dc             	lea    -0x24(%ebp),%edx
 604:	8b 45 f4             	mov    -0xc(%ebp),%eax
 607:	01 d0                	add    %edx,%eax
 609:	8a 00                	mov    (%eax),%al
 60b:	0f be c0             	movsbl %al,%eax
 60e:	89 44 24 04          	mov    %eax,0x4(%esp)
 612:	8b 45 08             	mov    0x8(%ebp),%eax
 615:	89 04 24             	mov    %eax,(%esp)
 618:	e8 33 ff ff ff       	call   550 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 61d:	ff 4d f4             	decl   -0xc(%ebp)
 620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 624:	79 db                	jns    601 <printint+0x89>
    putc(fd, buf[i]);
}
 626:	83 c4 30             	add    $0x30,%esp
 629:	5b                   	pop    %ebx
 62a:	5e                   	pop    %esi
 62b:	5d                   	pop    %ebp
 62c:	c3                   	ret    

0000062d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 62d:	55                   	push   %ebp
 62e:	89 e5                	mov    %esp,%ebp
 630:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 633:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 63a:	8d 45 0c             	lea    0xc(%ebp),%eax
 63d:	83 c0 04             	add    $0x4,%eax
 640:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 643:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 64a:	e9 77 01 00 00       	jmp    7c6 <printf+0x199>
    c = fmt[i] & 0xff;
 64f:	8b 55 0c             	mov    0xc(%ebp),%edx
 652:	8b 45 f0             	mov    -0x10(%ebp),%eax
 655:	01 d0                	add    %edx,%eax
 657:	8a 00                	mov    (%eax),%al
 659:	0f be c0             	movsbl %al,%eax
 65c:	25 ff 00 00 00       	and    $0xff,%eax
 661:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 664:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 668:	75 2c                	jne    696 <printf+0x69>
      if(c == '%'){
 66a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 66e:	75 0c                	jne    67c <printf+0x4f>
        state = '%';
 670:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 677:	e9 47 01 00 00       	jmp    7c3 <printf+0x196>
      } else {
        putc(fd, c);
 67c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67f:	0f be c0             	movsbl %al,%eax
 682:	89 44 24 04          	mov    %eax,0x4(%esp)
 686:	8b 45 08             	mov    0x8(%ebp),%eax
 689:	89 04 24             	mov    %eax,(%esp)
 68c:	e8 bf fe ff ff       	call   550 <putc>
 691:	e9 2d 01 00 00       	jmp    7c3 <printf+0x196>
      }
    } else if(state == '%'){
 696:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 69a:	0f 85 23 01 00 00    	jne    7c3 <printf+0x196>
      if(c == 'd'){
 6a0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6a4:	75 2d                	jne    6d3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a9:	8b 00                	mov    (%eax),%eax
 6ab:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6b2:	00 
 6b3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6ba:	00 
 6bb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bf:	8b 45 08             	mov    0x8(%ebp),%eax
 6c2:	89 04 24             	mov    %eax,(%esp)
 6c5:	e8 ae fe ff ff       	call   578 <printint>
        ap++;
 6ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ce:	e9 e9 00 00 00       	jmp    7bc <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6d3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6d7:	74 06                	je     6df <printf+0xb2>
 6d9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6dd:	75 2d                	jne    70c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6eb:	00 
 6ec:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6f3:	00 
 6f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f8:	8b 45 08             	mov    0x8(%ebp),%eax
 6fb:	89 04 24             	mov    %eax,(%esp)
 6fe:	e8 75 fe ff ff       	call   578 <printint>
        ap++;
 703:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 707:	e9 b0 00 00 00       	jmp    7bc <printf+0x18f>
      } else if(c == 's'){
 70c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 710:	75 42                	jne    754 <printf+0x127>
        s = (char*)*ap;
 712:	8b 45 e8             	mov    -0x18(%ebp),%eax
 715:	8b 00                	mov    (%eax),%eax
 717:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 71a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 71e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 722:	75 09                	jne    72d <printf+0x100>
          s = "(null)";
 724:	c7 45 f4 07 0a 00 00 	movl   $0xa07,-0xc(%ebp)
        while(*s != 0){
 72b:	eb 1c                	jmp    749 <printf+0x11c>
 72d:	eb 1a                	jmp    749 <printf+0x11c>
          putc(fd, *s);
 72f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 732:	8a 00                	mov    (%eax),%al
 734:	0f be c0             	movsbl %al,%eax
 737:	89 44 24 04          	mov    %eax,0x4(%esp)
 73b:	8b 45 08             	mov    0x8(%ebp),%eax
 73e:	89 04 24             	mov    %eax,(%esp)
 741:	e8 0a fe ff ff       	call   550 <putc>
          s++;
 746:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	8a 00                	mov    (%eax),%al
 74e:	84 c0                	test   %al,%al
 750:	75 dd                	jne    72f <printf+0x102>
 752:	eb 68                	jmp    7bc <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 754:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 758:	75 1d                	jne    777 <printf+0x14a>
        putc(fd, *ap);
 75a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75d:	8b 00                	mov    (%eax),%eax
 75f:	0f be c0             	movsbl %al,%eax
 762:	89 44 24 04          	mov    %eax,0x4(%esp)
 766:	8b 45 08             	mov    0x8(%ebp),%eax
 769:	89 04 24             	mov    %eax,(%esp)
 76c:	e8 df fd ff ff       	call   550 <putc>
        ap++;
 771:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 775:	eb 45                	jmp    7bc <printf+0x18f>
      } else if(c == '%'){
 777:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 77b:	75 17                	jne    794 <printf+0x167>
        putc(fd, c);
 77d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 780:	0f be c0             	movsbl %al,%eax
 783:	89 44 24 04          	mov    %eax,0x4(%esp)
 787:	8b 45 08             	mov    0x8(%ebp),%eax
 78a:	89 04 24             	mov    %eax,(%esp)
 78d:	e8 be fd ff ff       	call   550 <putc>
 792:	eb 28                	jmp    7bc <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 794:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 79b:	00 
 79c:	8b 45 08             	mov    0x8(%ebp),%eax
 79f:	89 04 24             	mov    %eax,(%esp)
 7a2:	e8 a9 fd ff ff       	call   550 <putc>
        putc(fd, c);
 7a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7aa:	0f be c0             	movsbl %al,%eax
 7ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b1:	8b 45 08             	mov    0x8(%ebp),%eax
 7b4:	89 04 24             	mov    %eax,(%esp)
 7b7:	e8 94 fd ff ff       	call   550 <putc>
      }
      state = 0;
 7bc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7c3:	ff 45 f0             	incl   -0x10(%ebp)
 7c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cc:	01 d0                	add    %edx,%eax
 7ce:	8a 00                	mov    (%eax),%al
 7d0:	84 c0                	test   %al,%al
 7d2:	0f 85 77 fe ff ff    	jne    64f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7d8:	c9                   	leave  
 7d9:	c3                   	ret    
 7da:	90                   	nop
 7db:	90                   	nop

000007dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7dc:	55                   	push   %ebp
 7dd:	89 e5                	mov    %esp,%ebp
 7df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e2:	8b 45 08             	mov    0x8(%ebp),%eax
 7e5:	83 e8 08             	sub    $0x8,%eax
 7e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7eb:	a1 94 0c 00 00       	mov    0xc94,%eax
 7f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f3:	eb 24                	jmp    819 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7fd:	77 12                	ja     811 <free+0x35>
 7ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 802:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 805:	77 24                	ja     82b <free+0x4f>
 807:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80f:	77 1a                	ja     82b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	89 45 fc             	mov    %eax,-0x4(%ebp)
 819:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 81f:	76 d4                	jbe    7f5 <free+0x19>
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 829:	76 ca                	jbe    7f5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	8b 40 04             	mov    0x4(%eax),%eax
 831:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 838:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83b:	01 c2                	add    %eax,%edx
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	8b 00                	mov    (%eax),%eax
 842:	39 c2                	cmp    %eax,%edx
 844:	75 24                	jne    86a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 846:	8b 45 f8             	mov    -0x8(%ebp),%eax
 849:	8b 50 04             	mov    0x4(%eax),%edx
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	8b 00                	mov    (%eax),%eax
 851:	8b 40 04             	mov    0x4(%eax),%eax
 854:	01 c2                	add    %eax,%edx
 856:	8b 45 f8             	mov    -0x8(%ebp),%eax
 859:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 85c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85f:	8b 00                	mov    (%eax),%eax
 861:	8b 10                	mov    (%eax),%edx
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	89 10                	mov    %edx,(%eax)
 868:	eb 0a                	jmp    874 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 86a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86d:	8b 10                	mov    (%eax),%edx
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 874:	8b 45 fc             	mov    -0x4(%ebp),%eax
 877:	8b 40 04             	mov    0x4(%eax),%eax
 87a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	01 d0                	add    %edx,%eax
 886:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 889:	75 20                	jne    8ab <free+0xcf>
    p->s.size += bp->s.size;
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 50 04             	mov    0x4(%eax),%edx
 891:	8b 45 f8             	mov    -0x8(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	01 c2                	add    %eax,%edx
 899:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 89f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a2:	8b 10                	mov    (%eax),%edx
 8a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a7:	89 10                	mov    %edx,(%eax)
 8a9:	eb 08                	jmp    8b3 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b1:	89 10                	mov    %edx,(%eax)
  freep = p;
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	a3 94 0c 00 00       	mov    %eax,0xc94
}
 8bb:	c9                   	leave  
 8bc:	c3                   	ret    

000008bd <morecore>:

static Header*
morecore(uint nu)
{
 8bd:	55                   	push   %ebp
 8be:	89 e5                	mov    %esp,%ebp
 8c0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8c3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8ca:	77 07                	ja     8d3 <morecore+0x16>
    nu = 4096;
 8cc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8d3:	8b 45 08             	mov    0x8(%ebp),%eax
 8d6:	c1 e0 03             	shl    $0x3,%eax
 8d9:	89 04 24             	mov    %eax,(%esp)
 8dc:	e8 47 fb ff ff       	call   428 <sbrk>
 8e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8e4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8e8:	75 07                	jne    8f1 <morecore+0x34>
    return 0;
 8ea:	b8 00 00 00 00       	mov    $0x0,%eax
 8ef:	eb 22                	jmp    913 <morecore+0x56>
  hp = (Header*)p;
 8f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fa:	8b 55 08             	mov    0x8(%ebp),%edx
 8fd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 900:	8b 45 f0             	mov    -0x10(%ebp),%eax
 903:	83 c0 08             	add    $0x8,%eax
 906:	89 04 24             	mov    %eax,(%esp)
 909:	e8 ce fe ff ff       	call   7dc <free>
  return freep;
 90e:	a1 94 0c 00 00       	mov    0xc94,%eax
}
 913:	c9                   	leave  
 914:	c3                   	ret    

00000915 <malloc>:

void*
malloc(uint nbytes)
{
 915:	55                   	push   %ebp
 916:	89 e5                	mov    %esp,%ebp
 918:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91b:	8b 45 08             	mov    0x8(%ebp),%eax
 91e:	83 c0 07             	add    $0x7,%eax
 921:	c1 e8 03             	shr    $0x3,%eax
 924:	40                   	inc    %eax
 925:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 928:	a1 94 0c 00 00       	mov    0xc94,%eax
 92d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 934:	75 23                	jne    959 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 936:	c7 45 f0 8c 0c 00 00 	movl   $0xc8c,-0x10(%ebp)
 93d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 940:	a3 94 0c 00 00       	mov    %eax,0xc94
 945:	a1 94 0c 00 00       	mov    0xc94,%eax
 94a:	a3 8c 0c 00 00       	mov    %eax,0xc8c
    base.s.size = 0;
 94f:	c7 05 90 0c 00 00 00 	movl   $0x0,0xc90
 956:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	8b 00                	mov    (%eax),%eax
 95e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	8b 40 04             	mov    0x4(%eax),%eax
 967:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 96a:	72 4d                	jb     9b9 <malloc+0xa4>
      if(p->s.size == nunits)
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	8b 40 04             	mov    0x4(%eax),%eax
 972:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 975:	75 0c                	jne    983 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 977:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97a:	8b 10                	mov    (%eax),%edx
 97c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97f:	89 10                	mov    %edx,(%eax)
 981:	eb 26                	jmp    9a9 <malloc+0x94>
      else {
        p->s.size -= nunits;
 983:	8b 45 f4             	mov    -0xc(%ebp),%eax
 986:	8b 40 04             	mov    0x4(%eax),%eax
 989:	2b 45 ec             	sub    -0x14(%ebp),%eax
 98c:	89 c2                	mov    %eax,%edx
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 40 04             	mov    0x4(%eax),%eax
 99a:	c1 e0 03             	shl    $0x3,%eax
 99d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9a6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ac:	a3 94 0c 00 00       	mov    %eax,0xc94
      return (void*)(p + 1);
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	83 c0 08             	add    $0x8,%eax
 9b7:	eb 38                	jmp    9f1 <malloc+0xdc>
    }
    if(p == freep)
 9b9:	a1 94 0c 00 00       	mov    0xc94,%eax
 9be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c1:	75 1b                	jne    9de <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9c6:	89 04 24             	mov    %eax,(%esp)
 9c9:	e8 ef fe ff ff       	call   8bd <morecore>
 9ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d5:	75 07                	jne    9de <malloc+0xc9>
        return 0;
 9d7:	b8 00 00 00 00       	mov    $0x0,%eax
 9dc:	eb 13                	jmp    9f1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e7:	8b 00                	mov    (%eax),%eax
 9e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ec:	e9 70 ff ff ff       	jmp    961 <malloc+0x4c>
}
 9f1:	c9                   	leave  
 9f2:	c3                   	ret    
