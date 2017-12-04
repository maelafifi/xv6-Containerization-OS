
_membomb:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#define ALLOCMB 1
#define ALLOCSIZE (ALLOCMB * MB)

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int totalmb = 0;
   9:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  10:	00 
  char *p;

  printf(1, "membomb: started\n");
  11:	c7 44 24 04 f4 09 00 	movl   $0x9f4,0x4(%esp)
  18:	00 
  19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  20:	e8 08 06 00 00       	call   62d <printf>
  while(1) {
    p = (char *) malloc(ALLOCSIZE);
  25:	c7 04 24 00 00 10 00 	movl   $0x100000,(%esp)
  2c:	e8 e4 08 00 00       	call   915 <malloc>
  31:	89 44 24 18          	mov    %eax,0x18(%esp)
    if (p == 0) {
  35:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  3a:	75 19                	jne    55 <main+0x55>
      printf(1, "membomb: malloc() failed, exiting\n");
  3c:	c7 44 24 04 08 0a 00 	movl   $0xa08,0x4(%esp)
  43:	00 
  44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4b:	e8 dd 05 00 00       	call   62d <printf>
      exit();
  50:	e8 5b 03 00 00       	call   3b0 <exit>
    }    
    totalmb += ALLOCMB;
  55:	ff 44 24 1c          	incl   0x1c(%esp)

    printf(1, "membomb: total memory allocated: %d MB\n", totalmb);
  59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  61:	c7 44 24 04 2c 0a 00 	movl   $0xa2c,0x4(%esp)
  68:	00 
  69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  70:	e8 b8 05 00 00       	call   62d <printf>
  }
  75:	eb ae                	jmp    25 <main+0x25>
  77:	90                   	nop

00000078 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	57                   	push   %edi
  7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80:	8b 55 10             	mov    0x10(%ebp),%edx
  83:	8b 45 0c             	mov    0xc(%ebp),%eax
  86:	89 cb                	mov    %ecx,%ebx
  88:	89 df                	mov    %ebx,%edi
  8a:	89 d1                	mov    %edx,%ecx
  8c:	fc                   	cld    
  8d:	f3 aa                	rep stos %al,%es:(%edi)
  8f:	89 ca                	mov    %ecx,%edx
  91:	89 fb                	mov    %edi,%ebx
  93:	89 5d 08             	mov    %ebx,0x8(%ebp)
  96:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  99:	5b                   	pop    %ebx
  9a:	5f                   	pop    %edi
  9b:	5d                   	pop    %ebp
  9c:	c3                   	ret    

0000009d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9d:	55                   	push   %ebp
  9e:	89 e5                	mov    %esp,%ebp
  a0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a3:	8b 45 08             	mov    0x8(%ebp),%eax
  a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a9:	90                   	nop
  aa:	8b 45 08             	mov    0x8(%ebp),%eax
  ad:	8d 50 01             	lea    0x1(%eax),%edx
  b0:	89 55 08             	mov    %edx,0x8(%ebp)
  b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  b9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  bc:	8a 12                	mov    (%edx),%dl
  be:	88 10                	mov    %dl,(%eax)
  c0:	8a 00                	mov    (%eax),%al
  c2:	84 c0                	test   %al,%al
  c4:	75 e4                	jne    aa <strcpy+0xd>
    ;
  return os;
  c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c9:	c9                   	leave  
  ca:	c3                   	ret    

000000cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ce:	eb 06                	jmp    d6 <strcmp+0xb>
    p++, q++;
  d0:	ff 45 08             	incl   0x8(%ebp)
  d3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	8a 00                	mov    (%eax),%al
  db:	84 c0                	test   %al,%al
  dd:	74 0e                	je     ed <strcmp+0x22>
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	8a 10                	mov    (%eax),%dl
  e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  e7:	8a 00                	mov    (%eax),%al
  e9:	38 c2                	cmp    %al,%dl
  eb:	74 e3                	je     d0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	8a 00                	mov    (%eax),%al
  f2:	0f b6 d0             	movzbl %al,%edx
  f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  f8:	8a 00                	mov    (%eax),%al
  fa:	0f b6 c0             	movzbl %al,%eax
  fd:	29 c2                	sub    %eax,%edx
  ff:	89 d0                	mov    %edx,%eax
}
 101:	5d                   	pop    %ebp
 102:	c3                   	ret    

00000103 <strlen>:

uint
strlen(char *s)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 109:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 110:	eb 03                	jmp    115 <strlen+0x12>
 112:	ff 45 fc             	incl   -0x4(%ebp)
 115:	8b 55 fc             	mov    -0x4(%ebp),%edx
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	01 d0                	add    %edx,%eax
 11d:	8a 00                	mov    (%eax),%al
 11f:	84 c0                	test   %al,%al
 121:	75 ef                	jne    112 <strlen+0xf>
    ;
  return n;
 123:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 126:	c9                   	leave  
 127:	c3                   	ret    

00000128 <memset>:

void*
memset(void *dst, int c, uint n)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 12e:	8b 45 10             	mov    0x10(%ebp),%eax
 131:	89 44 24 08          	mov    %eax,0x8(%esp)
 135:	8b 45 0c             	mov    0xc(%ebp),%eax
 138:	89 44 24 04          	mov    %eax,0x4(%esp)
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	89 04 24             	mov    %eax,(%esp)
 142:	e8 31 ff ff ff       	call   78 <stosb>
  return dst;
 147:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14a:	c9                   	leave  
 14b:	c3                   	ret    

0000014c <strchr>:

char*
strchr(const char *s, char c)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	83 ec 04             	sub    $0x4,%esp
 152:	8b 45 0c             	mov    0xc(%ebp),%eax
 155:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 158:	eb 12                	jmp    16c <strchr+0x20>
    if(*s == c)
 15a:	8b 45 08             	mov    0x8(%ebp),%eax
 15d:	8a 00                	mov    (%eax),%al
 15f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 162:	75 05                	jne    169 <strchr+0x1d>
      return (char*)s;
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	eb 11                	jmp    17a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 169:	ff 45 08             	incl   0x8(%ebp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	8a 00                	mov    (%eax),%al
 171:	84 c0                	test   %al,%al
 173:	75 e5                	jne    15a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 175:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17a:	c9                   	leave  
 17b:	c3                   	ret    

0000017c <gets>:

char*
gets(char *buf, int max)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 182:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 189:	eb 49                	jmp    1d4 <gets+0x58>
    cc = read(0, &c, 1);
 18b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 192:	00 
 193:	8d 45 ef             	lea    -0x11(%ebp),%eax
 196:	89 44 24 04          	mov    %eax,0x4(%esp)
 19a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a1:	e8 22 02 00 00       	call   3c8 <read>
 1a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ad:	7f 02                	jg     1b1 <gets+0x35>
      break;
 1af:	eb 2c                	jmp    1dd <gets+0x61>
    buf[i++] = c;
 1b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b4:	8d 50 01             	lea    0x1(%eax),%edx
 1b7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ba:	89 c2                	mov    %eax,%edx
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	01 c2                	add    %eax,%edx
 1c1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1c6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c9:	3c 0a                	cmp    $0xa,%al
 1cb:	74 10                	je     1dd <gets+0x61>
 1cd:	8a 45 ef             	mov    -0x11(%ebp),%al
 1d0:	3c 0d                	cmp    $0xd,%al
 1d2:	74 09                	je     1dd <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d7:	40                   	inc    %eax
 1d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1db:	7c ae                	jl     18b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	01 d0                	add    %edx,%eax
 1e5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1eb:	c9                   	leave  
 1ec:	c3                   	ret    

000001ed <stat>:

int
stat(char *n, struct stat *st)
{
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fa:	00 
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	89 04 24             	mov    %eax,(%esp)
 201:	e8 ea 01 00 00       	call   3f0 <open>
 206:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 209:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 20d:	79 07                	jns    216 <stat+0x29>
    return -1;
 20f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 214:	eb 23                	jmp    239 <stat+0x4c>
  r = fstat(fd, st);
 216:	8b 45 0c             	mov    0xc(%ebp),%eax
 219:	89 44 24 04          	mov    %eax,0x4(%esp)
 21d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 220:	89 04 24             	mov    %eax,(%esp)
 223:	e8 e0 01 00 00       	call   408 <fstat>
 228:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22e:	89 04 24             	mov    %eax,(%esp)
 231:	e8 a2 01 00 00       	call   3d8 <close>
  return r;
 236:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 239:	c9                   	leave  
 23a:	c3                   	ret    

0000023b <atoi>:

int
atoi(const char *s)
{
 23b:	55                   	push   %ebp
 23c:	89 e5                	mov    %esp,%ebp
 23e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 241:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 248:	eb 24                	jmp    26e <atoi+0x33>
    n = n*10 + *s++ - '0';
 24a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24d:	89 d0                	mov    %edx,%eax
 24f:	c1 e0 02             	shl    $0x2,%eax
 252:	01 d0                	add    %edx,%eax
 254:	01 c0                	add    %eax,%eax
 256:	89 c1                	mov    %eax,%ecx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	8d 50 01             	lea    0x1(%eax),%edx
 25e:	89 55 08             	mov    %edx,0x8(%ebp)
 261:	8a 00                	mov    (%eax),%al
 263:	0f be c0             	movsbl %al,%eax
 266:	01 c8                	add    %ecx,%eax
 268:	83 e8 30             	sub    $0x30,%eax
 26b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
 271:	8a 00                	mov    (%eax),%al
 273:	3c 2f                	cmp    $0x2f,%al
 275:	7e 09                	jle    280 <atoi+0x45>
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	8a 00                	mov    (%eax),%al
 27c:	3c 39                	cmp    $0x39,%al
 27e:	7e ca                	jle    24a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 280:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 283:	c9                   	leave  
 284:	c3                   	ret    

00000285 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 285:	55                   	push   %ebp
 286:	89 e5                	mov    %esp,%ebp
 288:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 291:	8b 45 0c             	mov    0xc(%ebp),%eax
 294:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 297:	eb 16                	jmp    2af <memmove+0x2a>
    *dst++ = *src++;
 299:	8b 45 fc             	mov    -0x4(%ebp),%eax
 29c:	8d 50 01             	lea    0x1(%eax),%edx
 29f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2a2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2a5:	8d 4a 01             	lea    0x1(%edx),%ecx
 2a8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2ab:	8a 12                	mov    (%edx),%dl
 2ad:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2af:	8b 45 10             	mov    0x10(%ebp),%eax
 2b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b5:	89 55 10             	mov    %edx,0x10(%ebp)
 2b8:	85 c0                	test   %eax,%eax
 2ba:	7f dd                	jg     299 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <itoa>:

int itoa(int value, char *sp, int radix)
{
 2c1:	55                   	push   %ebp
 2c2:	89 e5                	mov    %esp,%ebp
 2c4:	53                   	push   %ebx
 2c5:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2c8:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2ce:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 2d2:	75 0d                	jne    2e1 <itoa+0x20>
 2d4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2d8:	79 07                	jns    2e1 <itoa+0x20>
 2da:	b8 01 00 00 00       	mov    $0x1,%eax
 2df:	eb 05                	jmp    2e6 <itoa+0x25>
 2e1:	b8 00 00 00 00       	mov    $0x0,%eax
 2e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 2e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2ed:	74 0a                	je     2f9 <itoa+0x38>
      v = -value;
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	f7 d8                	neg    %eax
 2f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2f7:	eb 54                	jmp    34d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 2ff:	eb 4c                	jmp    34d <itoa+0x8c>
  {
    i = v % radix;
 301:	8b 4d 10             	mov    0x10(%ebp),%ecx
 304:	8b 45 f4             	mov    -0xc(%ebp),%eax
 307:	ba 00 00 00 00       	mov    $0x0,%edx
 30c:	f7 f1                	div    %ecx
 30e:	89 d0                	mov    %edx,%eax
 310:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 313:	8b 5d 10             	mov    0x10(%ebp),%ebx
 316:	8b 45 f4             	mov    -0xc(%ebp),%eax
 319:	ba 00 00 00 00       	mov    $0x0,%edx
 31e:	f7 f3                	div    %ebx
 320:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 323:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 327:	7f 13                	jg     33c <itoa+0x7b>
      *tp++ = i+'0';
 329:	8b 45 f8             	mov    -0x8(%ebp),%eax
 32c:	8d 50 01             	lea    0x1(%eax),%edx
 32f:	89 55 f8             	mov    %edx,-0x8(%ebp)
 332:	8b 55 e8             	mov    -0x18(%ebp),%edx
 335:	83 c2 30             	add    $0x30,%edx
 338:	88 10                	mov    %dl,(%eax)
 33a:	eb 11                	jmp    34d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 33c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 33f:	8d 50 01             	lea    0x1(%eax),%edx
 342:	89 55 f8             	mov    %edx,-0x8(%ebp)
 345:	8b 55 e8             	mov    -0x18(%ebp),%edx
 348:	83 c2 57             	add    $0x57,%edx
 34b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 34d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 351:	75 ae                	jne    301 <itoa+0x40>
 353:	8d 45 d8             	lea    -0x28(%ebp),%eax
 356:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 359:	74 a6                	je     301 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 35b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 35e:	8d 45 d8             	lea    -0x28(%ebp),%eax
 361:	29 c2                	sub    %eax,%edx
 363:	89 d0                	mov    %edx,%eax
 365:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 368:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 36c:	74 11                	je     37f <itoa+0xbe>
  {
    *sp++ = '-';
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	8d 50 01             	lea    0x1(%eax),%edx
 374:	89 55 0c             	mov    %edx,0xc(%ebp)
 377:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 37a:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 37d:	eb 15                	jmp    394 <itoa+0xd3>
 37f:	eb 13                	jmp    394 <itoa+0xd3>
    *sp++ = *--tp;
 381:	8b 45 0c             	mov    0xc(%ebp),%eax
 384:	8d 50 01             	lea    0x1(%eax),%edx
 387:	89 55 0c             	mov    %edx,0xc(%ebp)
 38a:	ff 4d f8             	decl   -0x8(%ebp)
 38d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 390:	8a 12                	mov    (%edx),%dl
 392:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 394:	8d 45 d8             	lea    -0x28(%ebp),%eax
 397:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 39a:	77 e5                	ja     381 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 39c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 39f:	83 c4 30             	add    $0x30,%esp
 3a2:	5b                   	pop    %ebx
 3a3:	5d                   	pop    %ebp
 3a4:	c3                   	ret    
 3a5:	90                   	nop
 3a6:	90                   	nop
 3a7:	90                   	nop

000003a8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3a8:	b8 01 00 00 00       	mov    $0x1,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <exit>:
SYSCALL(exit)
 3b0:	b8 02 00 00 00       	mov    $0x2,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <wait>:
SYSCALL(wait)
 3b8:	b8 03 00 00 00       	mov    $0x3,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <pipe>:
SYSCALL(pipe)
 3c0:	b8 04 00 00 00       	mov    $0x4,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <read>:
SYSCALL(read)
 3c8:	b8 05 00 00 00       	mov    $0x5,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <write>:
SYSCALL(write)
 3d0:	b8 10 00 00 00       	mov    $0x10,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <close>:
SYSCALL(close)
 3d8:	b8 15 00 00 00       	mov    $0x15,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <kill>:
SYSCALL(kill)
 3e0:	b8 06 00 00 00       	mov    $0x6,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <exec>:
SYSCALL(exec)
 3e8:	b8 07 00 00 00       	mov    $0x7,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <open>:
SYSCALL(open)
 3f0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <mknod>:
SYSCALL(mknod)
 3f8:	b8 11 00 00 00       	mov    $0x11,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <unlink>:
SYSCALL(unlink)
 400:	b8 12 00 00 00       	mov    $0x12,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <fstat>:
SYSCALL(fstat)
 408:	b8 08 00 00 00       	mov    $0x8,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <link>:
SYSCALL(link)
 410:	b8 13 00 00 00       	mov    $0x13,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <mkdir>:
SYSCALL(mkdir)
 418:	b8 14 00 00 00       	mov    $0x14,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <chdir>:
SYSCALL(chdir)
 420:	b8 09 00 00 00       	mov    $0x9,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <dup>:
SYSCALL(dup)
 428:	b8 0a 00 00 00       	mov    $0xa,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <getpid>:
SYSCALL(getpid)
 430:	b8 0b 00 00 00       	mov    $0xb,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <sbrk>:
SYSCALL(sbrk)
 438:	b8 0c 00 00 00       	mov    $0xc,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <sleep>:
SYSCALL(sleep)
 440:	b8 0d 00 00 00       	mov    $0xd,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <uptime>:
SYSCALL(uptime)
 448:	b8 0e 00 00 00       	mov    $0xe,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <getticks>:
SYSCALL(getticks)
 450:	b8 16 00 00 00       	mov    $0x16,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <get_name>:
SYSCALL(get_name)
 458:	b8 17 00 00 00       	mov    $0x17,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <get_max_proc>:
SYSCALL(get_max_proc)
 460:	b8 18 00 00 00       	mov    $0x18,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <get_max_mem>:
SYSCALL(get_max_mem)
 468:	b8 19 00 00 00       	mov    $0x19,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <get_max_disk>:
SYSCALL(get_max_disk)
 470:	b8 1a 00 00 00       	mov    $0x1a,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <get_curr_proc>:
SYSCALL(get_curr_proc)
 478:	b8 1b 00 00 00       	mov    $0x1b,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <get_curr_mem>:
SYSCALL(get_curr_mem)
 480:	b8 1c 00 00 00       	mov    $0x1c,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <get_curr_disk>:
SYSCALL(get_curr_disk)
 488:	b8 1d 00 00 00       	mov    $0x1d,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <set_name>:
SYSCALL(set_name)
 490:	b8 1e 00 00 00       	mov    $0x1e,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <set_max_mem>:
SYSCALL(set_max_mem)
 498:	b8 1f 00 00 00       	mov    $0x1f,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <set_max_disk>:
SYSCALL(set_max_disk)
 4a0:	b8 20 00 00 00       	mov    $0x20,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <set_max_proc>:
SYSCALL(set_max_proc)
 4a8:	b8 21 00 00 00       	mov    $0x21,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <set_curr_mem>:
SYSCALL(set_curr_mem)
 4b0:	b8 22 00 00 00       	mov    $0x22,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <set_curr_disk>:
SYSCALL(set_curr_disk)
 4b8:	b8 23 00 00 00       	mov    $0x23,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4c0:	b8 24 00 00 00       	mov    $0x24,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <find>:
SYSCALL(find)
 4c8:	b8 25 00 00 00       	mov    $0x25,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <is_full>:
SYSCALL(is_full)
 4d0:	b8 26 00 00 00       	mov    $0x26,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <container_init>:
SYSCALL(container_init)
 4d8:	b8 27 00 00 00       	mov    $0x27,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <cont_proc_set>:
SYSCALL(cont_proc_set)
 4e0:	b8 28 00 00 00       	mov    $0x28,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <ps>:
SYSCALL(ps)
 4e8:	b8 29 00 00 00       	mov    $0x29,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 4f0:	b8 2a 00 00 00       	mov    $0x2a,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <set_root_inode>:
SYSCALL(set_root_inode)
 4f8:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <cstop>:
SYSCALL(cstop)
 500:	b8 2c 00 00 00       	mov    $0x2c,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <df>:
SYSCALL(df)
 508:	b8 2d 00 00 00       	mov    $0x2d,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <max_containers>:
SYSCALL(max_containers)
 510:	b8 2e 00 00 00       	mov    $0x2e,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <container_reset>:
SYSCALL(container_reset)
 518:	b8 2f 00 00 00       	mov    $0x2f,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <pause>:
SYSCALL(pause)
 520:	b8 30 00 00 00       	mov    $0x30,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <resume>:
SYSCALL(resume)
 528:	b8 31 00 00 00       	mov    $0x31,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <tmem>:
SYSCALL(tmem)
 530:	b8 32 00 00 00       	mov    $0x32,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <amem>:
SYSCALL(amem)
 538:	b8 33 00 00 00       	mov    $0x33,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <c_ps>:
SYSCALL(c_ps)
 540:	b8 34 00 00 00       	mov    $0x34,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <get_used>:
SYSCALL(get_used)
 548:	b8 35 00 00 00       	mov    $0x35,%eax
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
 571:	e8 5a fe ff ff       	call   3d0 <write>
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
 5c9:	8a 80 c4 0c 00 00    	mov    0xcc4(%eax),%al
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
 724:	c7 45 f4 54 0a 00 00 	movl   $0xa54,-0xc(%ebp)
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
 7eb:	a1 e0 0c 00 00       	mov    0xce0,%eax
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
 8b6:	a3 e0 0c 00 00       	mov    %eax,0xce0
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
 8dc:	e8 57 fb ff ff       	call   438 <sbrk>
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
 90e:	a1 e0 0c 00 00       	mov    0xce0,%eax
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
 928:	a1 e0 0c 00 00       	mov    0xce0,%eax
 92d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 934:	75 23                	jne    959 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 936:	c7 45 f0 d8 0c 00 00 	movl   $0xcd8,-0x10(%ebp)
 93d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 940:	a3 e0 0c 00 00       	mov    %eax,0xce0
 945:	a1 e0 0c 00 00       	mov    0xce0,%eax
 94a:	a3 d8 0c 00 00       	mov    %eax,0xcd8
    base.s.size = 0;
 94f:	c7 05 dc 0c 00 00 00 	movl   $0x0,0xcdc
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
 9ac:	a3 e0 0c 00 00       	mov    %eax,0xce0
      return (void*)(p + 1);
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	83 c0 08             	add    $0x8,%eax
 9b7:	eb 38                	jmp    9f1 <malloc+0xdc>
    }
    if(p == freep)
 9b9:	a1 e0 0c 00 00       	mov    0xce0,%eax
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
