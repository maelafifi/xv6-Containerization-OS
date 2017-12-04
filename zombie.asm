
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 46 03 00 00       	call   354 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 ce 03 00 00       	call   3ec <sleep>
  exit();
  1e:	e8 39 03 00 00       	call   35c <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 08             	mov    0x8(%ebp),%eax
  59:	8d 50 01             	lea    0x1(%eax),%edx
  5c:	89 55 08             	mov    %edx,0x8(%ebp)
  5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  62:	8d 4a 01             	lea    0x1(%edx),%ecx
  65:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  68:	8a 12                	mov    (%edx),%dl
  6a:	88 10                	mov    %dl,(%eax)
  6c:	8a 00                	mov    (%eax),%al
  6e:	84 c0                	test   %al,%al
  70:	75 e4                	jne    56 <strcpy+0xd>
    ;
  return os;
  72:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  75:	c9                   	leave  
  76:	c3                   	ret    

00000077 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  77:	55                   	push   %ebp
  78:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  7a:	eb 06                	jmp    82 <strcmp+0xb>
    p++, q++;
  7c:	ff 45 08             	incl   0x8(%ebp)
  7f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  82:	8b 45 08             	mov    0x8(%ebp),%eax
  85:	8a 00                	mov    (%eax),%al
  87:	84 c0                	test   %al,%al
  89:	74 0e                	je     99 <strcmp+0x22>
  8b:	8b 45 08             	mov    0x8(%ebp),%eax
  8e:	8a 10                	mov    (%eax),%dl
  90:	8b 45 0c             	mov    0xc(%ebp),%eax
  93:	8a 00                	mov    (%eax),%al
  95:	38 c2                	cmp    %al,%dl
  97:	74 e3                	je     7c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	8a 00                	mov    (%eax),%al
  9e:	0f b6 d0             	movzbl %al,%edx
  a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  a4:	8a 00                	mov    (%eax),%al
  a6:	0f b6 c0             	movzbl %al,%eax
  a9:	29 c2                	sub    %eax,%edx
  ab:	89 d0                	mov    %edx,%eax
}
  ad:	5d                   	pop    %ebp
  ae:	c3                   	ret    

000000af <strlen>:

uint
strlen(char *s)
{
  af:	55                   	push   %ebp
  b0:	89 e5                	mov    %esp,%ebp
  b2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  bc:	eb 03                	jmp    c1 <strlen+0x12>
  be:	ff 45 fc             	incl   -0x4(%ebp)
  c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	01 d0                	add    %edx,%eax
  c9:	8a 00                	mov    (%eax),%al
  cb:	84 c0                	test   %al,%al
  cd:	75 ef                	jne    be <strlen+0xf>
    ;
  return n;
  cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d2:	c9                   	leave  
  d3:	c3                   	ret    

000000d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d4:	55                   	push   %ebp
  d5:	89 e5                	mov    %esp,%ebp
  d7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  da:	8b 45 10             	mov    0x10(%ebp),%eax
  dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	89 04 24             	mov    %eax,(%esp)
  ee:	e8 31 ff ff ff       	call   24 <stosb>
  return dst;
  f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  f6:	c9                   	leave  
  f7:	c3                   	ret    

000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  fb:	83 ec 04             	sub    $0x4,%esp
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 104:	eb 12                	jmp    118 <strchr+0x20>
    if(*s == c)
 106:	8b 45 08             	mov    0x8(%ebp),%eax
 109:	8a 00                	mov    (%eax),%al
 10b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 10e:	75 05                	jne    115 <strchr+0x1d>
      return (char*)s;
 110:	8b 45 08             	mov    0x8(%ebp),%eax
 113:	eb 11                	jmp    126 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 115:	ff 45 08             	incl   0x8(%ebp)
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	8a 00                	mov    (%eax),%al
 11d:	84 c0                	test   %al,%al
 11f:	75 e5                	jne    106 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 121:	b8 00 00 00 00       	mov    $0x0,%eax
}
 126:	c9                   	leave  
 127:	c3                   	ret    

00000128 <gets>:

char*
gets(char *buf, int max)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 135:	eb 49                	jmp    180 <gets+0x58>
    cc = read(0, &c, 1);
 137:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 13e:	00 
 13f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 142:	89 44 24 04          	mov    %eax,0x4(%esp)
 146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 14d:	e8 22 02 00 00       	call   374 <read>
 152:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 155:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 159:	7f 02                	jg     15d <gets+0x35>
      break;
 15b:	eb 2c                	jmp    189 <gets+0x61>
    buf[i++] = c;
 15d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 160:	8d 50 01             	lea    0x1(%eax),%edx
 163:	89 55 f4             	mov    %edx,-0xc(%ebp)
 166:	89 c2                	mov    %eax,%edx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	01 c2                	add    %eax,%edx
 16d:	8a 45 ef             	mov    -0x11(%ebp),%al
 170:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 172:	8a 45 ef             	mov    -0x11(%ebp),%al
 175:	3c 0a                	cmp    $0xa,%al
 177:	74 10                	je     189 <gets+0x61>
 179:	8a 45 ef             	mov    -0x11(%ebp),%al
 17c:	3c 0d                	cmp    $0xd,%al
 17e:	74 09                	je     189 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	8b 45 f4             	mov    -0xc(%ebp),%eax
 183:	40                   	inc    %eax
 184:	3b 45 0c             	cmp    0xc(%ebp),%eax
 187:	7c ae                	jl     137 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 189:	8b 55 f4             	mov    -0xc(%ebp),%edx
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	01 d0                	add    %edx,%eax
 191:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
}
 197:	c9                   	leave  
 198:	c3                   	ret    

00000199 <stat>:

int
stat(char *n, struct stat *st)
{
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a6:	00 
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 ea 01 00 00       	call   39c <open>
 1b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b9:	79 07                	jns    1c2 <stat+0x29>
    return -1;
 1bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c0:	eb 23                	jmp    1e5 <stat+0x4c>
  r = fstat(fd, st);
 1c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	89 04 24             	mov    %eax,(%esp)
 1cf:	e8 e0 01 00 00       	call   3b4 <fstat>
 1d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 a2 01 00 00       	call   384 <close>
  return r;
 1e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e5:	c9                   	leave  
 1e6:	c3                   	ret    

000001e7 <atoi>:

int
atoi(const char *s)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
 1ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f4:	eb 24                	jmp    21a <atoi+0x33>
    n = n*10 + *s++ - '0';
 1f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f9:	89 d0                	mov    %edx,%eax
 1fb:	c1 e0 02             	shl    $0x2,%eax
 1fe:	01 d0                	add    %edx,%eax
 200:	01 c0                	add    %eax,%eax
 202:	89 c1                	mov    %eax,%ecx
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8d 50 01             	lea    0x1(%eax),%edx
 20a:	89 55 08             	mov    %edx,0x8(%ebp)
 20d:	8a 00                	mov    (%eax),%al
 20f:	0f be c0             	movsbl %al,%eax
 212:	01 c8                	add    %ecx,%eax
 214:	83 e8 30             	sub    $0x30,%eax
 217:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	8a 00                	mov    (%eax),%al
 21f:	3c 2f                	cmp    $0x2f,%al
 221:	7e 09                	jle    22c <atoi+0x45>
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	8a 00                	mov    (%eax),%al
 228:	3c 39                	cmp    $0x39,%al
 22a:	7e ca                	jle    1f6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 22c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22f:	c9                   	leave  
 230:	c3                   	ret    

00000231 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 231:	55                   	push   %ebp
 232:	89 e5                	mov    %esp,%ebp
 234:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 23d:	8b 45 0c             	mov    0xc(%ebp),%eax
 240:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 243:	eb 16                	jmp    25b <memmove+0x2a>
    *dst++ = *src++;
 245:	8b 45 fc             	mov    -0x4(%ebp),%eax
 248:	8d 50 01             	lea    0x1(%eax),%edx
 24b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 24e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 251:	8d 4a 01             	lea    0x1(%edx),%ecx
 254:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 257:	8a 12                	mov    (%edx),%dl
 259:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 25b:	8b 45 10             	mov    0x10(%ebp),%eax
 25e:	8d 50 ff             	lea    -0x1(%eax),%edx
 261:	89 55 10             	mov    %edx,0x10(%ebp)
 264:	85 c0                	test   %eax,%eax
 266:	7f dd                	jg     245 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26b:	c9                   	leave  
 26c:	c3                   	ret    

0000026d <itoa>:

int itoa(int value, char *sp, int radix)
{
 26d:	55                   	push   %ebp
 26e:	89 e5                	mov    %esp,%ebp
 270:	53                   	push   %ebx
 271:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 274:	8d 45 d8             	lea    -0x28(%ebp),%eax
 277:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 27a:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 27e:	75 0d                	jne    28d <itoa+0x20>
 280:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 284:	79 07                	jns    28d <itoa+0x20>
 286:	b8 01 00 00 00       	mov    $0x1,%eax
 28b:	eb 05                	jmp    292 <itoa+0x25>
 28d:	b8 00 00 00 00       	mov    $0x0,%eax
 292:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 295:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 299:	74 0a                	je     2a5 <itoa+0x38>
      v = -value;
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	f7 d8                	neg    %eax
 2a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2a3:	eb 54                	jmp    2f9 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 2ab:	eb 4c                	jmp    2f9 <itoa+0x8c>
  {
    i = v % radix;
 2ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b3:	ba 00 00 00 00       	mov    $0x0,%edx
 2b8:	f7 f1                	div    %ecx
 2ba:	89 d0                	mov    %edx,%eax
 2bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 2bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	ba 00 00 00 00       	mov    $0x0,%edx
 2ca:	f7 f3                	div    %ebx
 2cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 2cf:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 2d3:	7f 13                	jg     2e8 <itoa+0x7b>
      *tp++ = i+'0';
 2d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2d8:	8d 50 01             	lea    0x1(%eax),%edx
 2db:	89 55 f8             	mov    %edx,-0x8(%ebp)
 2de:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2e1:	83 c2 30             	add    $0x30,%edx
 2e4:	88 10                	mov    %dl,(%eax)
 2e6:	eb 11                	jmp    2f9 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 2e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2eb:	8d 50 01             	lea    0x1(%eax),%edx
 2ee:	89 55 f8             	mov    %edx,-0x8(%ebp)
 2f1:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2f4:	83 c2 57             	add    $0x57,%edx
 2f7:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2fd:	75 ae                	jne    2ad <itoa+0x40>
 2ff:	8d 45 d8             	lea    -0x28(%ebp),%eax
 302:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 305:	74 a6                	je     2ad <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 307:	8b 55 f8             	mov    -0x8(%ebp),%edx
 30a:	8d 45 d8             	lea    -0x28(%ebp),%eax
 30d:	29 c2                	sub    %eax,%edx
 30f:	89 d0                	mov    %edx,%eax
 311:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 314:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 318:	74 11                	je     32b <itoa+0xbe>
  {
    *sp++ = '-';
 31a:	8b 45 0c             	mov    0xc(%ebp),%eax
 31d:	8d 50 01             	lea    0x1(%eax),%edx
 320:	89 55 0c             	mov    %edx,0xc(%ebp)
 323:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 326:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 329:	eb 15                	jmp    340 <itoa+0xd3>
 32b:	eb 13                	jmp    340 <itoa+0xd3>
    *sp++ = *--tp;
 32d:	8b 45 0c             	mov    0xc(%ebp),%eax
 330:	8d 50 01             	lea    0x1(%eax),%edx
 333:	89 55 0c             	mov    %edx,0xc(%ebp)
 336:	ff 4d f8             	decl   -0x8(%ebp)
 339:	8b 55 f8             	mov    -0x8(%ebp),%edx
 33c:	8a 12                	mov    (%edx),%dl
 33e:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 340:	8d 45 d8             	lea    -0x28(%ebp),%eax
 343:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 346:	77 e5                	ja     32d <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 348:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 34b:	83 c4 30             	add    $0x30,%esp
 34e:	5b                   	pop    %ebx
 34f:	5d                   	pop    %ebp
 350:	c3                   	ret    
 351:	90                   	nop
 352:	90                   	nop
 353:	90                   	nop

00000354 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 354:	b8 01 00 00 00       	mov    $0x1,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <exit>:
SYSCALL(exit)
 35c:	b8 02 00 00 00       	mov    $0x2,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <wait>:
SYSCALL(wait)
 364:	b8 03 00 00 00       	mov    $0x3,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <pipe>:
SYSCALL(pipe)
 36c:	b8 04 00 00 00       	mov    $0x4,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <read>:
SYSCALL(read)
 374:	b8 05 00 00 00       	mov    $0x5,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <write>:
SYSCALL(write)
 37c:	b8 10 00 00 00       	mov    $0x10,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <close>:
SYSCALL(close)
 384:	b8 15 00 00 00       	mov    $0x15,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <kill>:
SYSCALL(kill)
 38c:	b8 06 00 00 00       	mov    $0x6,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <exec>:
SYSCALL(exec)
 394:	b8 07 00 00 00       	mov    $0x7,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <open>:
SYSCALL(open)
 39c:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <mknod>:
SYSCALL(mknod)
 3a4:	b8 11 00 00 00       	mov    $0x11,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <unlink>:
SYSCALL(unlink)
 3ac:	b8 12 00 00 00       	mov    $0x12,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <fstat>:
SYSCALL(fstat)
 3b4:	b8 08 00 00 00       	mov    $0x8,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <link>:
SYSCALL(link)
 3bc:	b8 13 00 00 00       	mov    $0x13,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <mkdir>:
SYSCALL(mkdir)
 3c4:	b8 14 00 00 00       	mov    $0x14,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <chdir>:
SYSCALL(chdir)
 3cc:	b8 09 00 00 00       	mov    $0x9,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <dup>:
SYSCALL(dup)
 3d4:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <getpid>:
SYSCALL(getpid)
 3dc:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <sbrk>:
SYSCALL(sbrk)
 3e4:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <sleep>:
SYSCALL(sleep)
 3ec:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <uptime>:
SYSCALL(uptime)
 3f4:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <getticks>:
SYSCALL(getticks)
 3fc:	b8 16 00 00 00       	mov    $0x16,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <get_name>:
SYSCALL(get_name)
 404:	b8 17 00 00 00       	mov    $0x17,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <get_max_proc>:
SYSCALL(get_max_proc)
 40c:	b8 18 00 00 00       	mov    $0x18,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <get_max_mem>:
SYSCALL(get_max_mem)
 414:	b8 19 00 00 00       	mov    $0x19,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <get_max_disk>:
SYSCALL(get_max_disk)
 41c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <get_curr_proc>:
SYSCALL(get_curr_proc)
 424:	b8 1b 00 00 00       	mov    $0x1b,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <get_curr_mem>:
SYSCALL(get_curr_mem)
 42c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <get_curr_disk>:
SYSCALL(get_curr_disk)
 434:	b8 1d 00 00 00       	mov    $0x1d,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <set_name>:
SYSCALL(set_name)
 43c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <set_max_mem>:
SYSCALL(set_max_mem)
 444:	b8 1f 00 00 00       	mov    $0x1f,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <set_max_disk>:
SYSCALL(set_max_disk)
 44c:	b8 20 00 00 00       	mov    $0x20,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <set_max_proc>:
SYSCALL(set_max_proc)
 454:	b8 21 00 00 00       	mov    $0x21,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <set_curr_mem>:
SYSCALL(set_curr_mem)
 45c:	b8 22 00 00 00       	mov    $0x22,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <set_curr_disk>:
SYSCALL(set_curr_disk)
 464:	b8 23 00 00 00       	mov    $0x23,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <set_curr_proc>:
SYSCALL(set_curr_proc)
 46c:	b8 24 00 00 00       	mov    $0x24,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <find>:
SYSCALL(find)
 474:	b8 25 00 00 00       	mov    $0x25,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <is_full>:
SYSCALL(is_full)
 47c:	b8 26 00 00 00       	mov    $0x26,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <container_init>:
SYSCALL(container_init)
 484:	b8 27 00 00 00       	mov    $0x27,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <cont_proc_set>:
SYSCALL(cont_proc_set)
 48c:	b8 28 00 00 00       	mov    $0x28,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <ps>:
SYSCALL(ps)
 494:	b8 29 00 00 00       	mov    $0x29,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 49c:	b8 2a 00 00 00       	mov    $0x2a,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <set_root_inode>:
SYSCALL(set_root_inode)
 4a4:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <cstop>:
SYSCALL(cstop)
 4ac:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <df>:
SYSCALL(df)
 4b4:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <max_containers>:
SYSCALL(max_containers)
 4bc:	b8 2e 00 00 00       	mov    $0x2e,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <container_reset>:
SYSCALL(container_reset)
 4c4:	b8 2f 00 00 00       	mov    $0x2f,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <pause>:
SYSCALL(pause)
 4cc:	b8 30 00 00 00       	mov    $0x30,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <resume>:
SYSCALL(resume)
 4d4:	b8 31 00 00 00       	mov    $0x31,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <tmem>:
SYSCALL(tmem)
 4dc:	b8 32 00 00 00       	mov    $0x32,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <amem>:
SYSCALL(amem)
 4e4:	b8 33 00 00 00       	mov    $0x33,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <c_ps>:
SYSCALL(c_ps)
 4ec:	b8 34 00 00 00       	mov    $0x34,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <get_used>:
SYSCALL(get_used)
 4f4:	b8 35 00 00 00       	mov    $0x35,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	83 ec 18             	sub    $0x18,%esp
 502:	8b 45 0c             	mov    0xc(%ebp),%eax
 505:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 508:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 50f:	00 
 510:	8d 45 f4             	lea    -0xc(%ebp),%eax
 513:	89 44 24 04          	mov    %eax,0x4(%esp)
 517:	8b 45 08             	mov    0x8(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 5a fe ff ff       	call   37c <write>
}
 522:	c9                   	leave  
 523:	c3                   	ret    

00000524 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
 527:	56                   	push   %esi
 528:	53                   	push   %ebx
 529:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 52c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 533:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 537:	74 17                	je     550 <printint+0x2c>
 539:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 53d:	79 11                	jns    550 <printint+0x2c>
    neg = 1;
 53f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 546:	8b 45 0c             	mov    0xc(%ebp),%eax
 549:	f7 d8                	neg    %eax
 54b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54e:	eb 06                	jmp    556 <printint+0x32>
  } else {
    x = xx;
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 556:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 55d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 560:	8d 41 01             	lea    0x1(%ecx),%eax
 563:	89 45 f4             	mov    %eax,-0xc(%ebp)
 566:	8b 5d 10             	mov    0x10(%ebp),%ebx
 569:	8b 45 ec             	mov    -0x14(%ebp),%eax
 56c:	ba 00 00 00 00       	mov    $0x0,%edx
 571:	f7 f3                	div    %ebx
 573:	89 d0                	mov    %edx,%eax
 575:	8a 80 10 0c 00 00    	mov    0xc10(%eax),%al
 57b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 57f:	8b 75 10             	mov    0x10(%ebp),%esi
 582:	8b 45 ec             	mov    -0x14(%ebp),%eax
 585:	ba 00 00 00 00       	mov    $0x0,%edx
 58a:	f7 f6                	div    %esi
 58c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 58f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 593:	75 c8                	jne    55d <printint+0x39>
  if(neg)
 595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 599:	74 10                	je     5ab <printint+0x87>
    buf[i++] = '-';
 59b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59e:	8d 50 01             	lea    0x1(%eax),%edx
 5a1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5a4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5a9:	eb 1e                	jmp    5c9 <printint+0xa5>
 5ab:	eb 1c                	jmp    5c9 <printint+0xa5>
    putc(fd, buf[i]);
 5ad:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b3:	01 d0                	add    %edx,%eax
 5b5:	8a 00                	mov    (%eax),%al
 5b7:	0f be c0             	movsbl %al,%eax
 5ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
 5c1:	89 04 24             	mov    %eax,(%esp)
 5c4:	e8 33 ff ff ff       	call   4fc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5c9:	ff 4d f4             	decl   -0xc(%ebp)
 5cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d0:	79 db                	jns    5ad <printint+0x89>
    putc(fd, buf[i]);
}
 5d2:	83 c4 30             	add    $0x30,%esp
 5d5:	5b                   	pop    %ebx
 5d6:	5e                   	pop    %esi
 5d7:	5d                   	pop    %ebp
 5d8:	c3                   	ret    

000005d9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5d9:	55                   	push   %ebp
 5da:	89 e5                	mov    %esp,%ebp
 5dc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e6:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e9:	83 c0 04             	add    $0x4,%eax
 5ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f6:	e9 77 01 00 00       	jmp    772 <printf+0x199>
    c = fmt[i] & 0xff;
 5fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 601:	01 d0                	add    %edx,%eax
 603:	8a 00                	mov    (%eax),%al
 605:	0f be c0             	movsbl %al,%eax
 608:	25 ff 00 00 00       	and    $0xff,%eax
 60d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 610:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 614:	75 2c                	jne    642 <printf+0x69>
      if(c == '%'){
 616:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61a:	75 0c                	jne    628 <printf+0x4f>
        state = '%';
 61c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 623:	e9 47 01 00 00       	jmp    76f <printf+0x196>
      } else {
        putc(fd, c);
 628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62b:	0f be c0             	movsbl %al,%eax
 62e:	89 44 24 04          	mov    %eax,0x4(%esp)
 632:	8b 45 08             	mov    0x8(%ebp),%eax
 635:	89 04 24             	mov    %eax,(%esp)
 638:	e8 bf fe ff ff       	call   4fc <putc>
 63d:	e9 2d 01 00 00       	jmp    76f <printf+0x196>
      }
    } else if(state == '%'){
 642:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 646:	0f 85 23 01 00 00    	jne    76f <printf+0x196>
      if(c == 'd'){
 64c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 650:	75 2d                	jne    67f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 652:	8b 45 e8             	mov    -0x18(%ebp),%eax
 655:	8b 00                	mov    (%eax),%eax
 657:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 65e:	00 
 65f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 666:	00 
 667:	89 44 24 04          	mov    %eax,0x4(%esp)
 66b:	8b 45 08             	mov    0x8(%ebp),%eax
 66e:	89 04 24             	mov    %eax,(%esp)
 671:	e8 ae fe ff ff       	call   524 <printint>
        ap++;
 676:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 67a:	e9 e9 00 00 00       	jmp    768 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 67f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 683:	74 06                	je     68b <printf+0xb2>
 685:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 689:	75 2d                	jne    6b8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 68b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68e:	8b 00                	mov    (%eax),%eax
 690:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 697:	00 
 698:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 69f:	00 
 6a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a4:	8b 45 08             	mov    0x8(%ebp),%eax
 6a7:	89 04 24             	mov    %eax,(%esp)
 6aa:	e8 75 fe ff ff       	call   524 <printint>
        ap++;
 6af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b3:	e9 b0 00 00 00       	jmp    768 <printf+0x18f>
      } else if(c == 's'){
 6b8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6bc:	75 42                	jne    700 <printf+0x127>
        s = (char*)*ap;
 6be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c1:	8b 00                	mov    (%eax),%eax
 6c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ce:	75 09                	jne    6d9 <printf+0x100>
          s = "(null)";
 6d0:	c7 45 f4 9f 09 00 00 	movl   $0x99f,-0xc(%ebp)
        while(*s != 0){
 6d7:	eb 1c                	jmp    6f5 <printf+0x11c>
 6d9:	eb 1a                	jmp    6f5 <printf+0x11c>
          putc(fd, *s);
 6db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6de:	8a 00                	mov    (%eax),%al
 6e0:	0f be c0             	movsbl %al,%eax
 6e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ea:	89 04 24             	mov    %eax,(%esp)
 6ed:	e8 0a fe ff ff       	call   4fc <putc>
          s++;
 6f2:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f8:	8a 00                	mov    (%eax),%al
 6fa:	84 c0                	test   %al,%al
 6fc:	75 dd                	jne    6db <printf+0x102>
 6fe:	eb 68                	jmp    768 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 700:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 704:	75 1d                	jne    723 <printf+0x14a>
        putc(fd, *ap);
 706:	8b 45 e8             	mov    -0x18(%ebp),%eax
 709:	8b 00                	mov    (%eax),%eax
 70b:	0f be c0             	movsbl %al,%eax
 70e:	89 44 24 04          	mov    %eax,0x4(%esp)
 712:	8b 45 08             	mov    0x8(%ebp),%eax
 715:	89 04 24             	mov    %eax,(%esp)
 718:	e8 df fd ff ff       	call   4fc <putc>
        ap++;
 71d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 721:	eb 45                	jmp    768 <printf+0x18f>
      } else if(c == '%'){
 723:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 727:	75 17                	jne    740 <printf+0x167>
        putc(fd, c);
 729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72c:	0f be c0             	movsbl %al,%eax
 72f:	89 44 24 04          	mov    %eax,0x4(%esp)
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 be fd ff ff       	call   4fc <putc>
 73e:	eb 28                	jmp    768 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 740:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 747:	00 
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	89 04 24             	mov    %eax,(%esp)
 74e:	e8 a9 fd ff ff       	call   4fc <putc>
        putc(fd, c);
 753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 756:	0f be c0             	movsbl %al,%eax
 759:	89 44 24 04          	mov    %eax,0x4(%esp)
 75d:	8b 45 08             	mov    0x8(%ebp),%eax
 760:	89 04 24             	mov    %eax,(%esp)
 763:	e8 94 fd ff ff       	call   4fc <putc>
      }
      state = 0;
 768:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 76f:	ff 45 f0             	incl   -0x10(%ebp)
 772:	8b 55 0c             	mov    0xc(%ebp),%edx
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	01 d0                	add    %edx,%eax
 77a:	8a 00                	mov    (%eax),%al
 77c:	84 c0                	test   %al,%al
 77e:	0f 85 77 fe ff ff    	jne    5fb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 784:	c9                   	leave  
 785:	c3                   	ret    
 786:	90                   	nop
 787:	90                   	nop

00000788 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 788:	55                   	push   %ebp
 789:	89 e5                	mov    %esp,%ebp
 78b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
 791:	83 e8 08             	sub    $0x8,%eax
 794:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 797:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 79c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79f:	eb 24                	jmp    7c5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a9:	77 12                	ja     7bd <free+0x35>
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b1:	77 24                	ja     7d7 <free+0x4f>
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	8b 00                	mov    (%eax),%eax
 7b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bb:	77 1a                	ja     7d7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cb:	76 d4                	jbe    7a1 <free+0x19>
 7cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d5:	76 ca                	jbe    7a1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7da:	8b 40 04             	mov    0x4(%eax),%eax
 7dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e7:	01 c2                	add    %eax,%edx
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	39 c2                	cmp    %eax,%edx
 7f0:	75 24                	jne    816 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	8b 50 04             	mov    0x4(%eax),%edx
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 00                	mov    (%eax),%eax
 7fd:	8b 40 04             	mov    0x4(%eax),%eax
 800:	01 c2                	add    %eax,%edx
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	8b 10                	mov    (%eax),%edx
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	89 10                	mov    %edx,(%eax)
 814:	eb 0a                	jmp    820 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 816:	8b 45 fc             	mov    -0x4(%ebp),%eax
 819:	8b 10                	mov    (%eax),%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 40 04             	mov    0x4(%eax),%eax
 826:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	01 d0                	add    %edx,%eax
 832:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 835:	75 20                	jne    857 <free+0xcf>
    p->s.size += bp->s.size;
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	8b 50 04             	mov    0x4(%eax),%edx
 83d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	01 c2                	add    %eax,%edx
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	8b 10                	mov    (%eax),%edx
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	89 10                	mov    %edx,(%eax)
 855:	eb 08                	jmp    85f <free+0xd7>
  } else
    p->s.ptr = bp;
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 85d:	89 10                	mov    %edx,(%eax)
  freep = p;
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	a3 2c 0c 00 00       	mov    %eax,0xc2c
}
 867:	c9                   	leave  
 868:	c3                   	ret    

00000869 <morecore>:

static Header*
morecore(uint nu)
{
 869:	55                   	push   %ebp
 86a:	89 e5                	mov    %esp,%ebp
 86c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 86f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 876:	77 07                	ja     87f <morecore+0x16>
    nu = 4096;
 878:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 87f:	8b 45 08             	mov    0x8(%ebp),%eax
 882:	c1 e0 03             	shl    $0x3,%eax
 885:	89 04 24             	mov    %eax,(%esp)
 888:	e8 57 fb ff ff       	call   3e4 <sbrk>
 88d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 890:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 894:	75 07                	jne    89d <morecore+0x34>
    return 0;
 896:	b8 00 00 00 00       	mov    $0x0,%eax
 89b:	eb 22                	jmp    8bf <morecore+0x56>
  hp = (Header*)p;
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a6:	8b 55 08             	mov    0x8(%ebp),%edx
 8a9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8af:	83 c0 08             	add    $0x8,%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 ce fe ff ff       	call   788 <free>
  return freep;
 8ba:	a1 2c 0c 00 00       	mov    0xc2c,%eax
}
 8bf:	c9                   	leave  
 8c0:	c3                   	ret    

000008c1 <malloc>:

void*
malloc(uint nbytes)
{
 8c1:	55                   	push   %ebp
 8c2:	89 e5                	mov    %esp,%ebp
 8c4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ca:	83 c0 07             	add    $0x7,%eax
 8cd:	c1 e8 03             	shr    $0x3,%eax
 8d0:	40                   	inc    %eax
 8d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d4:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 8d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e0:	75 23                	jne    905 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8e2:	c7 45 f0 24 0c 00 00 	movl   $0xc24,-0x10(%ebp)
 8e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ec:	a3 2c 0c 00 00       	mov    %eax,0xc2c
 8f1:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 8f6:	a3 24 0c 00 00       	mov    %eax,0xc24
    base.s.size = 0;
 8fb:	c7 05 28 0c 00 00 00 	movl   $0x0,0xc28
 902:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 905:	8b 45 f0             	mov    -0x10(%ebp),%eax
 908:	8b 00                	mov    (%eax),%eax
 90a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 90d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 910:	8b 40 04             	mov    0x4(%eax),%eax
 913:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 916:	72 4d                	jb     965 <malloc+0xa4>
      if(p->s.size == nunits)
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 40 04             	mov    0x4(%eax),%eax
 91e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 921:	75 0c                	jne    92f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	8b 10                	mov    (%eax),%edx
 928:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92b:	89 10                	mov    %edx,(%eax)
 92d:	eb 26                	jmp    955 <malloc+0x94>
      else {
        p->s.size -= nunits;
 92f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 932:	8b 40 04             	mov    0x4(%eax),%eax
 935:	2b 45 ec             	sub    -0x14(%ebp),%eax
 938:	89 c2                	mov    %eax,%edx
 93a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 940:	8b 45 f4             	mov    -0xc(%ebp),%eax
 943:	8b 40 04             	mov    0x4(%eax),%eax
 946:	c1 e0 03             	shl    $0x3,%eax
 949:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 952:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 955:	8b 45 f0             	mov    -0x10(%ebp),%eax
 958:	a3 2c 0c 00 00       	mov    %eax,0xc2c
      return (void*)(p + 1);
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	83 c0 08             	add    $0x8,%eax
 963:	eb 38                	jmp    99d <malloc+0xdc>
    }
    if(p == freep)
 965:	a1 2c 0c 00 00       	mov    0xc2c,%eax
 96a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 96d:	75 1b                	jne    98a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 96f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 972:	89 04 24             	mov    %eax,(%esp)
 975:	e8 ef fe ff ff       	call   869 <morecore>
 97a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 97d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 981:	75 07                	jne    98a <malloc+0xc9>
        return 0;
 983:	b8 00 00 00 00       	mov    $0x0,%eax
 988:	eb 13                	jmp    99d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 990:	8b 45 f4             	mov    -0xc(%ebp),%eax
 993:	8b 00                	mov    (%eax),%eax
 995:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 998:	e9 70 ff ff ff       	jmp    90d <malloc+0x4c>
}
 99d:	c9                   	leave  
 99e:	c3                   	ret    
