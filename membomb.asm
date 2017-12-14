
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
  11:	c7 44 24 04 14 0a 00 	movl   $0xa14,0x4(%esp)
  18:	00 
  19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  20:	e8 28 06 00 00       	call   64d <printf>
  while(1) {
    p = (char *) malloc(ALLOCSIZE);
  25:	c7 04 24 00 00 10 00 	movl   $0x100000,(%esp)
  2c:	e8 04 09 00 00       	call   935 <malloc>
  31:	89 44 24 18          	mov    %eax,0x18(%esp)
    if (p == 0) {
  35:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  3a:	75 19                	jne    55 <main+0x55>
      printf(1, "membomb: malloc() failed, exiting\n");
  3c:	c7 44 24 04 28 0a 00 	movl   $0xa28,0x4(%esp)
  43:	00 
  44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4b:	e8 fd 05 00 00       	call   64d <printf>
      exit();
  50:	e8 5b 03 00 00       	call   3b0 <exit>
    }    
    totalmb += ALLOCMB;
  55:	ff 44 24 1c          	incl   0x1c(%esp)

    printf(1, "membomb: total memory allocated: %d MB\n", totalmb);
  59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  61:	c7 44 24 04 4c 0a 00 	movl   $0xa4c,0x4(%esp)
  68:	00 
  69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  70:	e8 d8 05 00 00       	call   64d <printf>
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

00000550 <get_os>:
SYSCALL(get_os)
 550:	b8 36 00 00 00       	mov    $0x36,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <set_os>:
SYSCALL(set_os)
 558:	b8 37 00 00 00       	mov    $0x37,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <get_cticks>:
SYSCALL(get_cticks)
 560:	b8 38 00 00 00       	mov    $0x38,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <tick_reset2>:
SYSCALL(tick_reset2)
 568:	b8 39 00 00 00       	mov    $0x39,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
 573:	83 ec 18             	sub    $0x18,%esp
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 57c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 583:	00 
 584:	8d 45 f4             	lea    -0xc(%ebp),%eax
 587:	89 44 24 04          	mov    %eax,0x4(%esp)
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	89 04 24             	mov    %eax,(%esp)
 591:	e8 3a fe ff ff       	call   3d0 <write>
}
 596:	c9                   	leave  
 597:	c3                   	ret    

00000598 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 598:	55                   	push   %ebp
 599:	89 e5                	mov    %esp,%ebp
 59b:	56                   	push   %esi
 59c:	53                   	push   %ebx
 59d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5a7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ab:	74 17                	je     5c4 <printint+0x2c>
 5ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5b1:	79 11                	jns    5c4 <printint+0x2c>
    neg = 1;
 5b3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 5bd:	f7 d8                	neg    %eax
 5bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c2:	eb 06                	jmp    5ca <printint+0x32>
  } else {
    x = xx;
 5c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5d1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5d4:	8d 41 01             	lea    0x1(%ecx),%eax
 5d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5da:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5e0:	ba 00 00 00 00       	mov    $0x0,%edx
 5e5:	f7 f3                	div    %ebx
 5e7:	89 d0                	mov    %edx,%eax
 5e9:	8a 80 e4 0c 00 00    	mov    0xce4(%eax),%al
 5ef:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5f3:	8b 75 10             	mov    0x10(%ebp),%esi
 5f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5f9:	ba 00 00 00 00       	mov    $0x0,%edx
 5fe:	f7 f6                	div    %esi
 600:	89 45 ec             	mov    %eax,-0x14(%ebp)
 603:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 607:	75 c8                	jne    5d1 <printint+0x39>
  if(neg)
 609:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 60d:	74 10                	je     61f <printint+0x87>
    buf[i++] = '-';
 60f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 612:	8d 50 01             	lea    0x1(%eax),%edx
 615:	89 55 f4             	mov    %edx,-0xc(%ebp)
 618:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 61d:	eb 1e                	jmp    63d <printint+0xa5>
 61f:	eb 1c                	jmp    63d <printint+0xa5>
    putc(fd, buf[i]);
 621:	8d 55 dc             	lea    -0x24(%ebp),%edx
 624:	8b 45 f4             	mov    -0xc(%ebp),%eax
 627:	01 d0                	add    %edx,%eax
 629:	8a 00                	mov    (%eax),%al
 62b:	0f be c0             	movsbl %al,%eax
 62e:	89 44 24 04          	mov    %eax,0x4(%esp)
 632:	8b 45 08             	mov    0x8(%ebp),%eax
 635:	89 04 24             	mov    %eax,(%esp)
 638:	e8 33 ff ff ff       	call   570 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 63d:	ff 4d f4             	decl   -0xc(%ebp)
 640:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 644:	79 db                	jns    621 <printint+0x89>
    putc(fd, buf[i]);
}
 646:	83 c4 30             	add    $0x30,%esp
 649:	5b                   	pop    %ebx
 64a:	5e                   	pop    %esi
 64b:	5d                   	pop    %ebp
 64c:	c3                   	ret    

0000064d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 64d:	55                   	push   %ebp
 64e:	89 e5                	mov    %esp,%ebp
 650:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 653:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 65a:	8d 45 0c             	lea    0xc(%ebp),%eax
 65d:	83 c0 04             	add    $0x4,%eax
 660:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 663:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 66a:	e9 77 01 00 00       	jmp    7e6 <printf+0x199>
    c = fmt[i] & 0xff;
 66f:	8b 55 0c             	mov    0xc(%ebp),%edx
 672:	8b 45 f0             	mov    -0x10(%ebp),%eax
 675:	01 d0                	add    %edx,%eax
 677:	8a 00                	mov    (%eax),%al
 679:	0f be c0             	movsbl %al,%eax
 67c:	25 ff 00 00 00       	and    $0xff,%eax
 681:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 684:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 688:	75 2c                	jne    6b6 <printf+0x69>
      if(c == '%'){
 68a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 68e:	75 0c                	jne    69c <printf+0x4f>
        state = '%';
 690:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 697:	e9 47 01 00 00       	jmp    7e3 <printf+0x196>
      } else {
        putc(fd, c);
 69c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 69f:	0f be c0             	movsbl %al,%eax
 6a2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a6:	8b 45 08             	mov    0x8(%ebp),%eax
 6a9:	89 04 24             	mov    %eax,(%esp)
 6ac:	e8 bf fe ff ff       	call   570 <putc>
 6b1:	e9 2d 01 00 00       	jmp    7e3 <printf+0x196>
      }
    } else if(state == '%'){
 6b6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ba:	0f 85 23 01 00 00    	jne    7e3 <printf+0x196>
      if(c == 'd'){
 6c0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6c4:	75 2d                	jne    6f3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c9:	8b 00                	mov    (%eax),%eax
 6cb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6d2:	00 
 6d3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6da:	00 
 6db:	89 44 24 04          	mov    %eax,0x4(%esp)
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
 6e2:	89 04 24             	mov    %eax,(%esp)
 6e5:	e8 ae fe ff ff       	call   598 <printint>
        ap++;
 6ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ee:	e9 e9 00 00 00       	jmp    7dc <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6f3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6f7:	74 06                	je     6ff <printf+0xb2>
 6f9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6fd:	75 2d                	jne    72c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
 702:	8b 00                	mov    (%eax),%eax
 704:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 70b:	00 
 70c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 713:	00 
 714:	89 44 24 04          	mov    %eax,0x4(%esp)
 718:	8b 45 08             	mov    0x8(%ebp),%eax
 71b:	89 04 24             	mov    %eax,(%esp)
 71e:	e8 75 fe ff ff       	call   598 <printint>
        ap++;
 723:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 727:	e9 b0 00 00 00       	jmp    7dc <printf+0x18f>
      } else if(c == 's'){
 72c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 730:	75 42                	jne    774 <printf+0x127>
        s = (char*)*ap;
 732:	8b 45 e8             	mov    -0x18(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 73a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 73e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 742:	75 09                	jne    74d <printf+0x100>
          s = "(null)";
 744:	c7 45 f4 74 0a 00 00 	movl   $0xa74,-0xc(%ebp)
        while(*s != 0){
 74b:	eb 1c                	jmp    769 <printf+0x11c>
 74d:	eb 1a                	jmp    769 <printf+0x11c>
          putc(fd, *s);
 74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 752:	8a 00                	mov    (%eax),%al
 754:	0f be c0             	movsbl %al,%eax
 757:	89 44 24 04          	mov    %eax,0x4(%esp)
 75b:	8b 45 08             	mov    0x8(%ebp),%eax
 75e:	89 04 24             	mov    %eax,(%esp)
 761:	e8 0a fe ff ff       	call   570 <putc>
          s++;
 766:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 769:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76c:	8a 00                	mov    (%eax),%al
 76e:	84 c0                	test   %al,%al
 770:	75 dd                	jne    74f <printf+0x102>
 772:	eb 68                	jmp    7dc <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 774:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 778:	75 1d                	jne    797 <printf+0x14a>
        putc(fd, *ap);
 77a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77d:	8b 00                	mov    (%eax),%eax
 77f:	0f be c0             	movsbl %al,%eax
 782:	89 44 24 04          	mov    %eax,0x4(%esp)
 786:	8b 45 08             	mov    0x8(%ebp),%eax
 789:	89 04 24             	mov    %eax,(%esp)
 78c:	e8 df fd ff ff       	call   570 <putc>
        ap++;
 791:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 795:	eb 45                	jmp    7dc <printf+0x18f>
      } else if(c == '%'){
 797:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 79b:	75 17                	jne    7b4 <printf+0x167>
        putc(fd, c);
 79d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a0:	0f be c0             	movsbl %al,%eax
 7a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a7:	8b 45 08             	mov    0x8(%ebp),%eax
 7aa:	89 04 24             	mov    %eax,(%esp)
 7ad:	e8 be fd ff ff       	call   570 <putc>
 7b2:	eb 28                	jmp    7dc <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7b4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7bb:	00 
 7bc:	8b 45 08             	mov    0x8(%ebp),%eax
 7bf:	89 04 24             	mov    %eax,(%esp)
 7c2:	e8 a9 fd ff ff       	call   570 <putc>
        putc(fd, c);
 7c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ca:	0f be c0             	movsbl %al,%eax
 7cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d1:	8b 45 08             	mov    0x8(%ebp),%eax
 7d4:	89 04 24             	mov    %eax,(%esp)
 7d7:	e8 94 fd ff ff       	call   570 <putc>
      }
      state = 0;
 7dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7e3:	ff 45 f0             	incl   -0x10(%ebp)
 7e6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ec:	01 d0                	add    %edx,%eax
 7ee:	8a 00                	mov    (%eax),%al
 7f0:	84 c0                	test   %al,%al
 7f2:	0f 85 77 fe ff ff    	jne    66f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7f8:	c9                   	leave  
 7f9:	c3                   	ret    
 7fa:	90                   	nop
 7fb:	90                   	nop

000007fc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fc:	55                   	push   %ebp
 7fd:	89 e5                	mov    %esp,%ebp
 7ff:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 802:	8b 45 08             	mov    0x8(%ebp),%eax
 805:	83 e8 08             	sub    $0x8,%eax
 808:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80b:	a1 00 0d 00 00       	mov    0xd00,%eax
 810:	89 45 fc             	mov    %eax,-0x4(%ebp)
 813:	eb 24                	jmp    839 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 81d:	77 12                	ja     831 <free+0x35>
 81f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 822:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 825:	77 24                	ja     84b <free+0x4f>
 827:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82a:	8b 00                	mov    (%eax),%eax
 82c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 82f:	77 1a                	ja     84b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	89 45 fc             	mov    %eax,-0x4(%ebp)
 839:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83f:	76 d4                	jbe    815 <free+0x19>
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 00                	mov    (%eax),%eax
 846:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 849:	76 ca                	jbe    815 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	8b 40 04             	mov    0x4(%eax),%eax
 851:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 858:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85b:	01 c2                	add    %eax,%edx
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	8b 00                	mov    (%eax),%eax
 862:	39 c2                	cmp    %eax,%edx
 864:	75 24                	jne    88a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 866:	8b 45 f8             	mov    -0x8(%ebp),%eax
 869:	8b 50 04             	mov    0x4(%eax),%edx
 86c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86f:	8b 00                	mov    (%eax),%eax
 871:	8b 40 04             	mov    0x4(%eax),%eax
 874:	01 c2                	add    %eax,%edx
 876:	8b 45 f8             	mov    -0x8(%ebp),%eax
 879:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 00                	mov    (%eax),%eax
 881:	8b 10                	mov    (%eax),%edx
 883:	8b 45 f8             	mov    -0x8(%ebp),%eax
 886:	89 10                	mov    %edx,(%eax)
 888:	eb 0a                	jmp    894 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 88a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88d:	8b 10                	mov    (%eax),%edx
 88f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 892:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 894:	8b 45 fc             	mov    -0x4(%ebp),%eax
 897:	8b 40 04             	mov    0x4(%eax),%eax
 89a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	01 d0                	add    %edx,%eax
 8a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8a9:	75 20                	jne    8cb <free+0xcf>
    p->s.size += bp->s.size;
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 50 04             	mov    0x4(%eax),%edx
 8b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b4:	8b 40 04             	mov    0x4(%eax),%eax
 8b7:	01 c2                	add    %eax,%edx
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c2:	8b 10                	mov    (%eax),%edx
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	89 10                	mov    %edx,(%eax)
 8c9:	eb 08                	jmp    8d3 <free+0xd7>
  } else
    p->s.ptr = bp;
 8cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ce:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8d1:	89 10                	mov    %edx,(%eax)
  freep = p;
 8d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d6:	a3 00 0d 00 00       	mov    %eax,0xd00
}
 8db:	c9                   	leave  
 8dc:	c3                   	ret    

000008dd <morecore>:

static Header*
morecore(uint nu)
{
 8dd:	55                   	push   %ebp
 8de:	89 e5                	mov    %esp,%ebp
 8e0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8e3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8ea:	77 07                	ja     8f3 <morecore+0x16>
    nu = 4096;
 8ec:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8f3:	8b 45 08             	mov    0x8(%ebp),%eax
 8f6:	c1 e0 03             	shl    $0x3,%eax
 8f9:	89 04 24             	mov    %eax,(%esp)
 8fc:	e8 37 fb ff ff       	call   438 <sbrk>
 901:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 904:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 908:	75 07                	jne    911 <morecore+0x34>
    return 0;
 90a:	b8 00 00 00 00       	mov    $0x0,%eax
 90f:	eb 22                	jmp    933 <morecore+0x56>
  hp = (Header*)p;
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 917:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91a:	8b 55 08             	mov    0x8(%ebp),%edx
 91d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 920:	8b 45 f0             	mov    -0x10(%ebp),%eax
 923:	83 c0 08             	add    $0x8,%eax
 926:	89 04 24             	mov    %eax,(%esp)
 929:	e8 ce fe ff ff       	call   7fc <free>
  return freep;
 92e:	a1 00 0d 00 00       	mov    0xd00,%eax
}
 933:	c9                   	leave  
 934:	c3                   	ret    

00000935 <malloc>:

void*
malloc(uint nbytes)
{
 935:	55                   	push   %ebp
 936:	89 e5                	mov    %esp,%ebp
 938:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93b:	8b 45 08             	mov    0x8(%ebp),%eax
 93e:	83 c0 07             	add    $0x7,%eax
 941:	c1 e8 03             	shr    $0x3,%eax
 944:	40                   	inc    %eax
 945:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 948:	a1 00 0d 00 00       	mov    0xd00,%eax
 94d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 954:	75 23                	jne    979 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 956:	c7 45 f0 f8 0c 00 00 	movl   $0xcf8,-0x10(%ebp)
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	a3 00 0d 00 00       	mov    %eax,0xd00
 965:	a1 00 0d 00 00       	mov    0xd00,%eax
 96a:	a3 f8 0c 00 00       	mov    %eax,0xcf8
    base.s.size = 0;
 96f:	c7 05 fc 0c 00 00 00 	movl   $0x0,0xcfc
 976:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	8b 00                	mov    (%eax),%eax
 97e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	8b 40 04             	mov    0x4(%eax),%eax
 987:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 98a:	72 4d                	jb     9d9 <malloc+0xa4>
      if(p->s.size == nunits)
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	8b 40 04             	mov    0x4(%eax),%eax
 992:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 995:	75 0c                	jne    9a3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 997:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99a:	8b 10                	mov    (%eax),%edx
 99c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99f:	89 10                	mov    %edx,(%eax)
 9a1:	eb 26                	jmp    9c9 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a6:	8b 40 04             	mov    0x4(%eax),%eax
 9a9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9ac:	89 c2                	mov    %eax,%edx
 9ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 40 04             	mov    0x4(%eax),%eax
 9ba:	c1 e0 03             	shl    $0x3,%eax
 9bd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9c6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cc:	a3 00 0d 00 00       	mov    %eax,0xd00
      return (void*)(p + 1);
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	83 c0 08             	add    $0x8,%eax
 9d7:	eb 38                	jmp    a11 <malloc+0xdc>
    }
    if(p == freep)
 9d9:	a1 00 0d 00 00       	mov    0xd00,%eax
 9de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9e1:	75 1b                	jne    9fe <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9e6:	89 04 24             	mov    %eax,(%esp)
 9e9:	e8 ef fe ff ff       	call   8dd <morecore>
 9ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9f5:	75 07                	jne    9fe <malloc+0xc9>
        return 0;
 9f7:	b8 00 00 00 00       	mov    $0x0,%eax
 9fc:	eb 13                	jmp    a11 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	8b 00                	mov    (%eax),%eax
 a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a0c:	e9 70 ff ff ff       	jmp    981 <malloc+0x4c>
}
 a11:	c9                   	leave  
 a12:	c3                   	ret    
