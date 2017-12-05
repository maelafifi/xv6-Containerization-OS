
_echo:     file format elf32-i386


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

  for(i = 1; i < argc; i++)
   9:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  10:	00 
  11:	eb 48                	jmp    5b <main+0x5b>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  17:	40                   	inc    %eax
  18:	3b 45 08             	cmp    0x8(%ebp),%eax
  1b:	7d 07                	jge    24 <main+0x24>
  1d:	b8 f7 09 00 00       	mov    $0x9f7,%eax
  22:	eb 05                	jmp    29 <main+0x29>
  24:	b8 f9 09 00 00       	mov    $0x9f9,%eax
  29:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2d:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  34:	8b 55 0c             	mov    0xc(%ebp),%edx
  37:	01 ca                	add    %ecx,%edx
  39:	8b 12                	mov    (%edx),%edx
  3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  43:	c7 44 24 04 fb 09 00 	movl   $0x9fb,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 da 05 00 00       	call   631 <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
  57:	ff 44 24 1c          	incl   0x1c(%esp)
  5b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5f:	3b 45 08             	cmp    0x8(%ebp),%eax
  62:	7c af                	jl     13 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
  64:	e8 3b 03 00 00       	call   3a4 <exit>
  69:	90                   	nop
  6a:	90                   	nop
  6b:	90                   	nop

0000006c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	57                   	push   %edi
  70:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  74:	8b 55 10             	mov    0x10(%ebp),%edx
  77:	8b 45 0c             	mov    0xc(%ebp),%eax
  7a:	89 cb                	mov    %ecx,%ebx
  7c:	89 df                	mov    %ebx,%edi
  7e:	89 d1                	mov    %edx,%ecx
  80:	fc                   	cld    
  81:	f3 aa                	rep stos %al,%es:(%edi)
  83:	89 ca                	mov    %ecx,%edx
  85:	89 fb                	mov    %edi,%ebx
  87:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  8d:	5b                   	pop    %ebx
  8e:	5f                   	pop    %edi
  8f:	5d                   	pop    %ebp
  90:	c3                   	ret    

00000091 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  91:	55                   	push   %ebp
  92:	89 e5                	mov    %esp,%ebp
  94:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  97:	8b 45 08             	mov    0x8(%ebp),%eax
  9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  9d:	90                   	nop
  9e:	8b 45 08             	mov    0x8(%ebp),%eax
  a1:	8d 50 01             	lea    0x1(%eax),%edx
  a4:	89 55 08             	mov    %edx,0x8(%ebp)
  a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  ad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  b0:	8a 12                	mov    (%edx),%dl
  b2:	88 10                	mov    %dl,(%eax)
  b4:	8a 00                	mov    (%eax),%al
  b6:	84 c0                	test   %al,%al
  b8:	75 e4                	jne    9e <strcpy+0xd>
    ;
  return os;
  ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bd:	c9                   	leave  
  be:	c3                   	ret    

000000bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bf:	55                   	push   %ebp
  c0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c2:	eb 06                	jmp    ca <strcmp+0xb>
    p++, q++;
  c4:	ff 45 08             	incl   0x8(%ebp)
  c7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	8a 00                	mov    (%eax),%al
  cf:	84 c0                	test   %al,%al
  d1:	74 0e                	je     e1 <strcmp+0x22>
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	8a 10                	mov    (%eax),%dl
  d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  db:	8a 00                	mov    (%eax),%al
  dd:	38 c2                	cmp    %al,%dl
  df:	74 e3                	je     c4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	8a 00                	mov    (%eax),%al
  e6:	0f b6 d0             	movzbl %al,%edx
  e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  ec:	8a 00                	mov    (%eax),%al
  ee:	0f b6 c0             	movzbl %al,%eax
  f1:	29 c2                	sub    %eax,%edx
  f3:	89 d0                	mov    %edx,%eax
}
  f5:	5d                   	pop    %ebp
  f6:	c3                   	ret    

000000f7 <strlen>:

uint
strlen(char *s)
{
  f7:	55                   	push   %ebp
  f8:	89 e5                	mov    %esp,%ebp
  fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 104:	eb 03                	jmp    109 <strlen+0x12>
 106:	ff 45 fc             	incl   -0x4(%ebp)
 109:	8b 55 fc             	mov    -0x4(%ebp),%edx
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	01 d0                	add    %edx,%eax
 111:	8a 00                	mov    (%eax),%al
 113:	84 c0                	test   %al,%al
 115:	75 ef                	jne    106 <strlen+0xf>
    ;
  return n;
 117:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 11a:	c9                   	leave  
 11b:	c3                   	ret    

0000011c <memset>:

void*
memset(void *dst, int c, uint n)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 122:	8b 45 10             	mov    0x10(%ebp),%eax
 125:	89 44 24 08          	mov    %eax,0x8(%esp)
 129:	8b 45 0c             	mov    0xc(%ebp),%eax
 12c:	89 44 24 04          	mov    %eax,0x4(%esp)
 130:	8b 45 08             	mov    0x8(%ebp),%eax
 133:	89 04 24             	mov    %eax,(%esp)
 136:	e8 31 ff ff ff       	call   6c <stosb>
  return dst;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <strchr>:

char*
strchr(const char *s, char c)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	83 ec 04             	sub    $0x4,%esp
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 14c:	eb 12                	jmp    160 <strchr+0x20>
    if(*s == c)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	8a 00                	mov    (%eax),%al
 153:	3a 45 fc             	cmp    -0x4(%ebp),%al
 156:	75 05                	jne    15d <strchr+0x1d>
      return (char*)s;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	eb 11                	jmp    16e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 15d:	ff 45 08             	incl   0x8(%ebp)
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	8a 00                	mov    (%eax),%al
 165:	84 c0                	test   %al,%al
 167:	75 e5                	jne    14e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 169:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16e:	c9                   	leave  
 16f:	c3                   	ret    

00000170 <gets>:

char*
gets(char *buf, int max)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 176:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 17d:	eb 49                	jmp    1c8 <gets+0x58>
    cc = read(0, &c, 1);
 17f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 186:	00 
 187:	8d 45 ef             	lea    -0x11(%ebp),%eax
 18a:	89 44 24 04          	mov    %eax,0x4(%esp)
 18e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 195:	e8 22 02 00 00       	call   3bc <read>
 19a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 19d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a1:	7f 02                	jg     1a5 <gets+0x35>
      break;
 1a3:	eb 2c                	jmp    1d1 <gets+0x61>
    buf[i++] = c;
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	8d 50 01             	lea    0x1(%eax),%edx
 1ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ae:	89 c2                	mov    %eax,%edx
 1b0:	8b 45 08             	mov    0x8(%ebp),%eax
 1b3:	01 c2                	add    %eax,%edx
 1b5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1b8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ba:	8a 45 ef             	mov    -0x11(%ebp),%al
 1bd:	3c 0a                	cmp    $0xa,%al
 1bf:	74 10                	je     1d1 <gets+0x61>
 1c1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c4:	3c 0d                	cmp    $0xd,%al
 1c6:	74 09                	je     1d1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cb:	40                   	inc    %eax
 1cc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1cf:	7c ae                	jl     17f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	01 d0                	add    %edx,%eax
 1d9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <stat>:

int
stat(char *n, struct stat *st)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1ee:	00 
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	89 04 24             	mov    %eax,(%esp)
 1f5:	e8 ea 01 00 00       	call   3e4 <open>
 1fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 201:	79 07                	jns    20a <stat+0x29>
    return -1;
 203:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 208:	eb 23                	jmp    22d <stat+0x4c>
  r = fstat(fd, st);
 20a:	8b 45 0c             	mov    0xc(%ebp),%eax
 20d:	89 44 24 04          	mov    %eax,0x4(%esp)
 211:	8b 45 f4             	mov    -0xc(%ebp),%eax
 214:	89 04 24             	mov    %eax,(%esp)
 217:	e8 e0 01 00 00       	call   3fc <fstat>
 21c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 21f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 222:	89 04 24             	mov    %eax,(%esp)
 225:	e8 a2 01 00 00       	call   3cc <close>
  return r;
 22a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <atoi>:

int
atoi(const char *s)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 235:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 23c:	eb 24                	jmp    262 <atoi+0x33>
    n = n*10 + *s++ - '0';
 23e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 241:	89 d0                	mov    %edx,%eax
 243:	c1 e0 02             	shl    $0x2,%eax
 246:	01 d0                	add    %edx,%eax
 248:	01 c0                	add    %eax,%eax
 24a:	89 c1                	mov    %eax,%ecx
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	8d 50 01             	lea    0x1(%eax),%edx
 252:	89 55 08             	mov    %edx,0x8(%ebp)
 255:	8a 00                	mov    (%eax),%al
 257:	0f be c0             	movsbl %al,%eax
 25a:	01 c8                	add    %ecx,%eax
 25c:	83 e8 30             	sub    $0x30,%eax
 25f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	8a 00                	mov    (%eax),%al
 267:	3c 2f                	cmp    $0x2f,%al
 269:	7e 09                	jle    274 <atoi+0x45>
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	8a 00                	mov    (%eax),%al
 270:	3c 39                	cmp    $0x39,%al
 272:	7e ca                	jle    23e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 274:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 285:	8b 45 0c             	mov    0xc(%ebp),%eax
 288:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 28b:	eb 16                	jmp    2a3 <memmove+0x2a>
    *dst++ = *src++;
 28d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 290:	8d 50 01             	lea    0x1(%eax),%edx
 293:	89 55 fc             	mov    %edx,-0x4(%ebp)
 296:	8b 55 f8             	mov    -0x8(%ebp),%edx
 299:	8d 4a 01             	lea    0x1(%edx),%ecx
 29c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 29f:	8a 12                	mov    (%edx),%dl
 2a1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a3:	8b 45 10             	mov    0x10(%ebp),%eax
 2a6:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a9:	89 55 10             	mov    %edx,0x10(%ebp)
 2ac:	85 c0                	test   %eax,%eax
 2ae:	7f dd                	jg     28d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <itoa>:

int itoa(int value, char *sp, int radix)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	53                   	push   %ebx
 2b9:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2bc:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2c2:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 2c6:	75 0d                	jne    2d5 <itoa+0x20>
 2c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2cc:	79 07                	jns    2d5 <itoa+0x20>
 2ce:	b8 01 00 00 00       	mov    $0x1,%eax
 2d3:	eb 05                	jmp    2da <itoa+0x25>
 2d5:	b8 00 00 00 00       	mov    $0x0,%eax
 2da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 2dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2e1:	74 0a                	je     2ed <itoa+0x38>
      v = -value;
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	f7 d8                	neg    %eax
 2e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2eb:	eb 54                	jmp    341 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 2ed:	8b 45 08             	mov    0x8(%ebp),%eax
 2f0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 2f3:	eb 4c                	jmp    341 <itoa+0x8c>
  {
    i = v % radix;
 2f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fb:	ba 00 00 00 00       	mov    $0x0,%edx
 300:	f7 f1                	div    %ecx
 302:	89 d0                	mov    %edx,%eax
 304:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 307:	8b 5d 10             	mov    0x10(%ebp),%ebx
 30a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30d:	ba 00 00 00 00       	mov    $0x0,%edx
 312:	f7 f3                	div    %ebx
 314:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 317:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 31b:	7f 13                	jg     330 <itoa+0x7b>
      *tp++ = i+'0';
 31d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 320:	8d 50 01             	lea    0x1(%eax),%edx
 323:	89 55 f8             	mov    %edx,-0x8(%ebp)
 326:	8b 55 e8             	mov    -0x18(%ebp),%edx
 329:	83 c2 30             	add    $0x30,%edx
 32c:	88 10                	mov    %dl,(%eax)
 32e:	eb 11                	jmp    341 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 330:	8b 45 f8             	mov    -0x8(%ebp),%eax
 333:	8d 50 01             	lea    0x1(%eax),%edx
 336:	89 55 f8             	mov    %edx,-0x8(%ebp)
 339:	8b 55 e8             	mov    -0x18(%ebp),%edx
 33c:	83 c2 57             	add    $0x57,%edx
 33f:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 341:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 345:	75 ae                	jne    2f5 <itoa+0x40>
 347:	8d 45 d8             	lea    -0x28(%ebp),%eax
 34a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 34d:	74 a6                	je     2f5 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 34f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 352:	8d 45 d8             	lea    -0x28(%ebp),%eax
 355:	29 c2                	sub    %eax,%edx
 357:	89 d0                	mov    %edx,%eax
 359:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 35c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 360:	74 11                	je     373 <itoa+0xbe>
  {
    *sp++ = '-';
 362:	8b 45 0c             	mov    0xc(%ebp),%eax
 365:	8d 50 01             	lea    0x1(%eax),%edx
 368:	89 55 0c             	mov    %edx,0xc(%ebp)
 36b:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 36e:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 371:	eb 15                	jmp    388 <itoa+0xd3>
 373:	eb 13                	jmp    388 <itoa+0xd3>
    *sp++ = *--tp;
 375:	8b 45 0c             	mov    0xc(%ebp),%eax
 378:	8d 50 01             	lea    0x1(%eax),%edx
 37b:	89 55 0c             	mov    %edx,0xc(%ebp)
 37e:	ff 4d f8             	decl   -0x8(%ebp)
 381:	8b 55 f8             	mov    -0x8(%ebp),%edx
 384:	8a 12                	mov    (%edx),%dl
 386:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 388:	8d 45 d8             	lea    -0x28(%ebp),%eax
 38b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 38e:	77 e5                	ja     375 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 390:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 393:	83 c4 30             	add    $0x30,%esp
 396:	5b                   	pop    %ebx
 397:	5d                   	pop    %ebp
 398:	c3                   	ret    
 399:	90                   	nop
 39a:	90                   	nop
 39b:	90                   	nop

0000039c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 39c:	b8 01 00 00 00       	mov    $0x1,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <exit>:
SYSCALL(exit)
 3a4:	b8 02 00 00 00       	mov    $0x2,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <wait>:
SYSCALL(wait)
 3ac:	b8 03 00 00 00       	mov    $0x3,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <pipe>:
SYSCALL(pipe)
 3b4:	b8 04 00 00 00       	mov    $0x4,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <read>:
SYSCALL(read)
 3bc:	b8 05 00 00 00       	mov    $0x5,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <write>:
SYSCALL(write)
 3c4:	b8 10 00 00 00       	mov    $0x10,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <close>:
SYSCALL(close)
 3cc:	b8 15 00 00 00       	mov    $0x15,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <kill>:
SYSCALL(kill)
 3d4:	b8 06 00 00 00       	mov    $0x6,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <exec>:
SYSCALL(exec)
 3dc:	b8 07 00 00 00       	mov    $0x7,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <open>:
SYSCALL(open)
 3e4:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <mknod>:
SYSCALL(mknod)
 3ec:	b8 11 00 00 00       	mov    $0x11,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <unlink>:
SYSCALL(unlink)
 3f4:	b8 12 00 00 00       	mov    $0x12,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <fstat>:
SYSCALL(fstat)
 3fc:	b8 08 00 00 00       	mov    $0x8,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <link>:
SYSCALL(link)
 404:	b8 13 00 00 00       	mov    $0x13,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <mkdir>:
SYSCALL(mkdir)
 40c:	b8 14 00 00 00       	mov    $0x14,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <chdir>:
SYSCALL(chdir)
 414:	b8 09 00 00 00       	mov    $0x9,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <dup>:
SYSCALL(dup)
 41c:	b8 0a 00 00 00       	mov    $0xa,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <getpid>:
SYSCALL(getpid)
 424:	b8 0b 00 00 00       	mov    $0xb,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <sbrk>:
SYSCALL(sbrk)
 42c:	b8 0c 00 00 00       	mov    $0xc,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <sleep>:
SYSCALL(sleep)
 434:	b8 0d 00 00 00       	mov    $0xd,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <uptime>:
SYSCALL(uptime)
 43c:	b8 0e 00 00 00       	mov    $0xe,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <getticks>:
SYSCALL(getticks)
 444:	b8 16 00 00 00       	mov    $0x16,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <get_name>:
SYSCALL(get_name)
 44c:	b8 17 00 00 00       	mov    $0x17,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <get_max_proc>:
SYSCALL(get_max_proc)
 454:	b8 18 00 00 00       	mov    $0x18,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <get_max_mem>:
SYSCALL(get_max_mem)
 45c:	b8 19 00 00 00       	mov    $0x19,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <get_max_disk>:
SYSCALL(get_max_disk)
 464:	b8 1a 00 00 00       	mov    $0x1a,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <get_curr_proc>:
SYSCALL(get_curr_proc)
 46c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <get_curr_mem>:
SYSCALL(get_curr_mem)
 474:	b8 1c 00 00 00       	mov    $0x1c,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <get_curr_disk>:
SYSCALL(get_curr_disk)
 47c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <set_name>:
SYSCALL(set_name)
 484:	b8 1e 00 00 00       	mov    $0x1e,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <set_max_mem>:
SYSCALL(set_max_mem)
 48c:	b8 1f 00 00 00       	mov    $0x1f,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <set_max_disk>:
SYSCALL(set_max_disk)
 494:	b8 20 00 00 00       	mov    $0x20,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <set_max_proc>:
SYSCALL(set_max_proc)
 49c:	b8 21 00 00 00       	mov    $0x21,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <set_curr_mem>:
SYSCALL(set_curr_mem)
 4a4:	b8 22 00 00 00       	mov    $0x22,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <set_curr_disk>:
SYSCALL(set_curr_disk)
 4ac:	b8 23 00 00 00       	mov    $0x23,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4b4:	b8 24 00 00 00       	mov    $0x24,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <find>:
SYSCALL(find)
 4bc:	b8 25 00 00 00       	mov    $0x25,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <is_full>:
SYSCALL(is_full)
 4c4:	b8 26 00 00 00       	mov    $0x26,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <container_init>:
SYSCALL(container_init)
 4cc:	b8 27 00 00 00       	mov    $0x27,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <cont_proc_set>:
SYSCALL(cont_proc_set)
 4d4:	b8 28 00 00 00       	mov    $0x28,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <ps>:
SYSCALL(ps)
 4dc:	b8 29 00 00 00       	mov    $0x29,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 4e4:	b8 2a 00 00 00       	mov    $0x2a,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <set_root_inode>:
SYSCALL(set_root_inode)
 4ec:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <cstop>:
SYSCALL(cstop)
 4f4:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <df>:
SYSCALL(df)
 4fc:	b8 2d 00 00 00       	mov    $0x2d,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <max_containers>:
SYSCALL(max_containers)
 504:	b8 2e 00 00 00       	mov    $0x2e,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <container_reset>:
SYSCALL(container_reset)
 50c:	b8 2f 00 00 00       	mov    $0x2f,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <pause>:
SYSCALL(pause)
 514:	b8 30 00 00 00       	mov    $0x30,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <resume>:
SYSCALL(resume)
 51c:	b8 31 00 00 00       	mov    $0x31,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <tmem>:
SYSCALL(tmem)
 524:	b8 32 00 00 00       	mov    $0x32,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <amem>:
SYSCALL(amem)
 52c:	b8 33 00 00 00       	mov    $0x33,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <c_ps>:
SYSCALL(c_ps)
 534:	b8 34 00 00 00       	mov    $0x34,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <get_used>:
SYSCALL(get_used)
 53c:	b8 35 00 00 00       	mov    $0x35,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <get_os>:
SYSCALL(get_os)
 544:	b8 36 00 00 00       	mov    $0x36,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <set_os>:
SYSCALL(set_os)
 54c:	b8 37 00 00 00       	mov    $0x37,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 554:	55                   	push   %ebp
 555:	89 e5                	mov    %esp,%ebp
 557:	83 ec 18             	sub    $0x18,%esp
 55a:	8b 45 0c             	mov    0xc(%ebp),%eax
 55d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 560:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 567:	00 
 568:	8d 45 f4             	lea    -0xc(%ebp),%eax
 56b:	89 44 24 04          	mov    %eax,0x4(%esp)
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	89 04 24             	mov    %eax,(%esp)
 575:	e8 4a fe ff ff       	call   3c4 <write>
}
 57a:	c9                   	leave  
 57b:	c3                   	ret    

0000057c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 57c:	55                   	push   %ebp
 57d:	89 e5                	mov    %esp,%ebp
 57f:	56                   	push   %esi
 580:	53                   	push   %ebx
 581:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 584:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 58b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 58f:	74 17                	je     5a8 <printint+0x2c>
 591:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 595:	79 11                	jns    5a8 <printint+0x2c>
    neg = 1;
 597:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 59e:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a1:	f7 d8                	neg    %eax
 5a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a6:	eb 06                	jmp    5ae <printint+0x32>
  } else {
    x = xx;
 5a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5b5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5b8:	8d 41 01             	lea    0x1(%ecx),%eax
 5bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5be:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c4:	ba 00 00 00 00       	mov    $0x0,%edx
 5c9:	f7 f3                	div    %ebx
 5cb:	89 d0                	mov    %edx,%eax
 5cd:	8a 80 70 0c 00 00    	mov    0xc70(%eax),%al
 5d3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5d7:	8b 75 10             	mov    0x10(%ebp),%esi
 5da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5dd:	ba 00 00 00 00       	mov    $0x0,%edx
 5e2:	f7 f6                	div    %esi
 5e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5eb:	75 c8                	jne    5b5 <printint+0x39>
  if(neg)
 5ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5f1:	74 10                	je     603 <printint+0x87>
    buf[i++] = '-';
 5f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f6:	8d 50 01             	lea    0x1(%eax),%edx
 5f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5fc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 601:	eb 1e                	jmp    621 <printint+0xa5>
 603:	eb 1c                	jmp    621 <printint+0xa5>
    putc(fd, buf[i]);
 605:	8d 55 dc             	lea    -0x24(%ebp),%edx
 608:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60b:	01 d0                	add    %edx,%eax
 60d:	8a 00                	mov    (%eax),%al
 60f:	0f be c0             	movsbl %al,%eax
 612:	89 44 24 04          	mov    %eax,0x4(%esp)
 616:	8b 45 08             	mov    0x8(%ebp),%eax
 619:	89 04 24             	mov    %eax,(%esp)
 61c:	e8 33 ff ff ff       	call   554 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 621:	ff 4d f4             	decl   -0xc(%ebp)
 624:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 628:	79 db                	jns    605 <printint+0x89>
    putc(fd, buf[i]);
}
 62a:	83 c4 30             	add    $0x30,%esp
 62d:	5b                   	pop    %ebx
 62e:	5e                   	pop    %esi
 62f:	5d                   	pop    %ebp
 630:	c3                   	ret    

00000631 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 631:	55                   	push   %ebp
 632:	89 e5                	mov    %esp,%ebp
 634:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 637:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 63e:	8d 45 0c             	lea    0xc(%ebp),%eax
 641:	83 c0 04             	add    $0x4,%eax
 644:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 647:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 64e:	e9 77 01 00 00       	jmp    7ca <printf+0x199>
    c = fmt[i] & 0xff;
 653:	8b 55 0c             	mov    0xc(%ebp),%edx
 656:	8b 45 f0             	mov    -0x10(%ebp),%eax
 659:	01 d0                	add    %edx,%eax
 65b:	8a 00                	mov    (%eax),%al
 65d:	0f be c0             	movsbl %al,%eax
 660:	25 ff 00 00 00       	and    $0xff,%eax
 665:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 668:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 66c:	75 2c                	jne    69a <printf+0x69>
      if(c == '%'){
 66e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 672:	75 0c                	jne    680 <printf+0x4f>
        state = '%';
 674:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 67b:	e9 47 01 00 00       	jmp    7c7 <printf+0x196>
      } else {
        putc(fd, c);
 680:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 683:	0f be c0             	movsbl %al,%eax
 686:	89 44 24 04          	mov    %eax,0x4(%esp)
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	89 04 24             	mov    %eax,(%esp)
 690:	e8 bf fe ff ff       	call   554 <putc>
 695:	e9 2d 01 00 00       	jmp    7c7 <printf+0x196>
      }
    } else if(state == '%'){
 69a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 69e:	0f 85 23 01 00 00    	jne    7c7 <printf+0x196>
      if(c == 'd'){
 6a4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6a8:	75 2d                	jne    6d7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ad:	8b 00                	mov    (%eax),%eax
 6af:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6b6:	00 
 6b7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6be:	00 
 6bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	89 04 24             	mov    %eax,(%esp)
 6c9:	e8 ae fe ff ff       	call   57c <printint>
        ap++;
 6ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d2:	e9 e9 00 00 00       	jmp    7c0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6d7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6db:	74 06                	je     6e3 <printf+0xb2>
 6dd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6e1:	75 2d                	jne    710 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e6:	8b 00                	mov    (%eax),%eax
 6e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ef:	00 
 6f0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6f7:	00 
 6f8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fc:	8b 45 08             	mov    0x8(%ebp),%eax
 6ff:	89 04 24             	mov    %eax,(%esp)
 702:	e8 75 fe ff ff       	call   57c <printint>
        ap++;
 707:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70b:	e9 b0 00 00 00       	jmp    7c0 <printf+0x18f>
      } else if(c == 's'){
 710:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 714:	75 42                	jne    758 <printf+0x127>
        s = (char*)*ap;
 716:	8b 45 e8             	mov    -0x18(%ebp),%eax
 719:	8b 00                	mov    (%eax),%eax
 71b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 71e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 722:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 726:	75 09                	jne    731 <printf+0x100>
          s = "(null)";
 728:	c7 45 f4 00 0a 00 00 	movl   $0xa00,-0xc(%ebp)
        while(*s != 0){
 72f:	eb 1c                	jmp    74d <printf+0x11c>
 731:	eb 1a                	jmp    74d <printf+0x11c>
          putc(fd, *s);
 733:	8b 45 f4             	mov    -0xc(%ebp),%eax
 736:	8a 00                	mov    (%eax),%al
 738:	0f be c0             	movsbl %al,%eax
 73b:	89 44 24 04          	mov    %eax,0x4(%esp)
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	89 04 24             	mov    %eax,(%esp)
 745:	e8 0a fe ff ff       	call   554 <putc>
          s++;
 74a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 74d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 750:	8a 00                	mov    (%eax),%al
 752:	84 c0                	test   %al,%al
 754:	75 dd                	jne    733 <printf+0x102>
 756:	eb 68                	jmp    7c0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 758:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 75c:	75 1d                	jne    77b <printf+0x14a>
        putc(fd, *ap);
 75e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 761:	8b 00                	mov    (%eax),%eax
 763:	0f be c0             	movsbl %al,%eax
 766:	89 44 24 04          	mov    %eax,0x4(%esp)
 76a:	8b 45 08             	mov    0x8(%ebp),%eax
 76d:	89 04 24             	mov    %eax,(%esp)
 770:	e8 df fd ff ff       	call   554 <putc>
        ap++;
 775:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 779:	eb 45                	jmp    7c0 <printf+0x18f>
      } else if(c == '%'){
 77b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 77f:	75 17                	jne    798 <printf+0x167>
        putc(fd, c);
 781:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 784:	0f be c0             	movsbl %al,%eax
 787:	89 44 24 04          	mov    %eax,0x4(%esp)
 78b:	8b 45 08             	mov    0x8(%ebp),%eax
 78e:	89 04 24             	mov    %eax,(%esp)
 791:	e8 be fd ff ff       	call   554 <putc>
 796:	eb 28                	jmp    7c0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 798:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 79f:	00 
 7a0:	8b 45 08             	mov    0x8(%ebp),%eax
 7a3:	89 04 24             	mov    %eax,(%esp)
 7a6:	e8 a9 fd ff ff       	call   554 <putc>
        putc(fd, c);
 7ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ae:	0f be c0             	movsbl %al,%eax
 7b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b5:	8b 45 08             	mov    0x8(%ebp),%eax
 7b8:	89 04 24             	mov    %eax,(%esp)
 7bb:	e8 94 fd ff ff       	call   554 <putc>
      }
      state = 0;
 7c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7c7:	ff 45 f0             	incl   -0x10(%ebp)
 7ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	01 d0                	add    %edx,%eax
 7d2:	8a 00                	mov    (%eax),%al
 7d4:	84 c0                	test   %al,%al
 7d6:	0f 85 77 fe ff ff    	jne    653 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7dc:	c9                   	leave  
 7dd:	c3                   	ret    
 7de:	90                   	nop
 7df:	90                   	nop

000007e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e0:	55                   	push   %ebp
 7e1:	89 e5                	mov    %esp,%ebp
 7e3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e6:	8b 45 08             	mov    0x8(%ebp),%eax
 7e9:	83 e8 08             	sub    $0x8,%eax
 7ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ef:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 7f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f7:	eb 24                	jmp    81d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 801:	77 12                	ja     815 <free+0x35>
 803:	8b 45 f8             	mov    -0x8(%ebp),%eax
 806:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 809:	77 24                	ja     82f <free+0x4f>
 80b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80e:	8b 00                	mov    (%eax),%eax
 810:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 813:	77 1a                	ja     82f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 81d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 820:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 823:	76 d4                	jbe    7f9 <free+0x19>
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 82d:	76 ca                	jbe    7f9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	8b 40 04             	mov    0x4(%eax),%eax
 835:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 83c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83f:	01 c2                	add    %eax,%edx
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 00                	mov    (%eax),%eax
 846:	39 c2                	cmp    %eax,%edx
 848:	75 24                	jne    86e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 84a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84d:	8b 50 04             	mov    0x4(%eax),%edx
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 00                	mov    (%eax),%eax
 855:	8b 40 04             	mov    0x4(%eax),%eax
 858:	01 c2                	add    %eax,%edx
 85a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	8b 00                	mov    (%eax),%eax
 865:	8b 10                	mov    (%eax),%edx
 867:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86a:	89 10                	mov    %edx,(%eax)
 86c:	eb 0a                	jmp    878 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 86e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 871:	8b 10                	mov    (%eax),%edx
 873:	8b 45 f8             	mov    -0x8(%ebp),%eax
 876:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 878:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87b:	8b 40 04             	mov    0x4(%eax),%eax
 87e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	01 d0                	add    %edx,%eax
 88a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 88d:	75 20                	jne    8af <free+0xcf>
    p->s.size += bp->s.size;
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 50 04             	mov    0x4(%eax),%edx
 895:	8b 45 f8             	mov    -0x8(%ebp),%eax
 898:	8b 40 04             	mov    0x4(%eax),%eax
 89b:	01 c2                	add    %eax,%edx
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a6:	8b 10                	mov    (%eax),%edx
 8a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ab:	89 10                	mov    %edx,(%eax)
 8ad:	eb 08                	jmp    8b7 <free+0xd7>
  } else
    p->s.ptr = bp;
 8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b5:	89 10                	mov    %edx,(%eax)
  freep = p;
 8b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ba:	a3 8c 0c 00 00       	mov    %eax,0xc8c
}
 8bf:	c9                   	leave  
 8c0:	c3                   	ret    

000008c1 <morecore>:

static Header*
morecore(uint nu)
{
 8c1:	55                   	push   %ebp
 8c2:	89 e5                	mov    %esp,%ebp
 8c4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8c7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8ce:	77 07                	ja     8d7 <morecore+0x16>
    nu = 4096;
 8d0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8d7:	8b 45 08             	mov    0x8(%ebp),%eax
 8da:	c1 e0 03             	shl    $0x3,%eax
 8dd:	89 04 24             	mov    %eax,(%esp)
 8e0:	e8 47 fb ff ff       	call   42c <sbrk>
 8e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8e8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8ec:	75 07                	jne    8f5 <morecore+0x34>
    return 0;
 8ee:	b8 00 00 00 00       	mov    $0x0,%eax
 8f3:	eb 22                	jmp    917 <morecore+0x56>
  hp = (Header*)p;
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fe:	8b 55 08             	mov    0x8(%ebp),%edx
 901:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 904:	8b 45 f0             	mov    -0x10(%ebp),%eax
 907:	83 c0 08             	add    $0x8,%eax
 90a:	89 04 24             	mov    %eax,(%esp)
 90d:	e8 ce fe ff ff       	call   7e0 <free>
  return freep;
 912:	a1 8c 0c 00 00       	mov    0xc8c,%eax
}
 917:	c9                   	leave  
 918:	c3                   	ret    

00000919 <malloc>:

void*
malloc(uint nbytes)
{
 919:	55                   	push   %ebp
 91a:	89 e5                	mov    %esp,%ebp
 91c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91f:	8b 45 08             	mov    0x8(%ebp),%eax
 922:	83 c0 07             	add    $0x7,%eax
 925:	c1 e8 03             	shr    $0x3,%eax
 928:	40                   	inc    %eax
 929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 92c:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 931:	89 45 f0             	mov    %eax,-0x10(%ebp)
 934:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 938:	75 23                	jne    95d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 93a:	c7 45 f0 84 0c 00 00 	movl   $0xc84,-0x10(%ebp)
 941:	8b 45 f0             	mov    -0x10(%ebp),%eax
 944:	a3 8c 0c 00 00       	mov    %eax,0xc8c
 949:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 94e:	a3 84 0c 00 00       	mov    %eax,0xc84
    base.s.size = 0;
 953:	c7 05 88 0c 00 00 00 	movl   $0x0,0xc88
 95a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 965:	8b 45 f4             	mov    -0xc(%ebp),%eax
 968:	8b 40 04             	mov    0x4(%eax),%eax
 96b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 96e:	72 4d                	jb     9bd <malloc+0xa4>
      if(p->s.size == nunits)
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 40 04             	mov    0x4(%eax),%eax
 976:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 979:	75 0c                	jne    987 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 97b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97e:	8b 10                	mov    (%eax),%edx
 980:	8b 45 f0             	mov    -0x10(%ebp),%eax
 983:	89 10                	mov    %edx,(%eax)
 985:	eb 26                	jmp    9ad <malloc+0x94>
      else {
        p->s.size -= nunits;
 987:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98a:	8b 40 04             	mov    0x4(%eax),%eax
 98d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 990:	89 c2                	mov    %eax,%edx
 992:	8b 45 f4             	mov    -0xc(%ebp),%eax
 995:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 998:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99b:	8b 40 04             	mov    0x4(%eax),%eax
 99e:	c1 e0 03             	shl    $0x3,%eax
 9a1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9aa:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b0:	a3 8c 0c 00 00       	mov    %eax,0xc8c
      return (void*)(p + 1);
 9b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b8:	83 c0 08             	add    $0x8,%eax
 9bb:	eb 38                	jmp    9f5 <malloc+0xdc>
    }
    if(p == freep)
 9bd:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 9c2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c5:	75 1b                	jne    9e2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9ca:	89 04 24             	mov    %eax,(%esp)
 9cd:	e8 ef fe ff ff       	call   8c1 <morecore>
 9d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d9:	75 07                	jne    9e2 <malloc+0xc9>
        return 0;
 9db:	b8 00 00 00 00       	mov    $0x0,%eax
 9e0:	eb 13                	jmp    9f5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	8b 00                	mov    (%eax),%eax
 9ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9f0:	e9 70 ff ff ff       	jmp    965 <malloc+0x4c>
}
 9f5:	c9                   	leave  
 9f6:	c3                   	ret    
