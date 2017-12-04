
_diskbomb:     file format elf32-i386


Disassembly of section .text:

00000000 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
   5:	8b 4d 08             	mov    0x8(%ebp),%ecx
   8:	8b 55 10             	mov    0x10(%ebp),%edx
   b:	8b 45 0c             	mov    0xc(%ebp),%eax
   e:	89 cb                	mov    %ecx,%ebx
  10:	89 df                	mov    %ebx,%edi
  12:	89 d1                	mov    %edx,%ecx
  14:	fc                   	cld    
  15:	f3 aa                	rep stos %al,%es:(%edi)
  17:	89 ca                	mov    %ecx,%edx
  19:	89 fb                	mov    %edi,%ebx
  1b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  1e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  21:	5b                   	pop    %ebx
  22:	5f                   	pop    %edi
  23:	5d                   	pop    %ebp
  24:	c3                   	ret    

00000025 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  25:	55                   	push   %ebp
  26:	89 e5                	mov    %esp,%ebp
  28:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  2b:	8b 45 08             	mov    0x8(%ebp),%eax
  2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  31:	90                   	nop
  32:	8b 45 08             	mov    0x8(%ebp),%eax
  35:	8d 50 01             	lea    0x1(%eax),%edx
  38:	89 55 08             	mov    %edx,0x8(%ebp)
  3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  3e:	8d 4a 01             	lea    0x1(%edx),%ecx
  41:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  44:	8a 12                	mov    (%edx),%dl
  46:	88 10                	mov    %dl,(%eax)
  48:	8a 00                	mov    (%eax),%al
  4a:	84 c0                	test   %al,%al
  4c:	75 e4                	jne    32 <strcpy+0xd>
    ;
  return os;
  4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  51:	c9                   	leave  
  52:	c3                   	ret    

00000053 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  53:	55                   	push   %ebp
  54:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  56:	eb 06                	jmp    5e <strcmp+0xb>
    p++, q++;
  58:	ff 45 08             	incl   0x8(%ebp)
  5b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  5e:	8b 45 08             	mov    0x8(%ebp),%eax
  61:	8a 00                	mov    (%eax),%al
  63:	84 c0                	test   %al,%al
  65:	74 0e                	je     75 <strcmp+0x22>
  67:	8b 45 08             	mov    0x8(%ebp),%eax
  6a:	8a 10                	mov    (%eax),%dl
  6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  6f:	8a 00                	mov    (%eax),%al
  71:	38 c2                	cmp    %al,%dl
  73:	74 e3                	je     58 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  75:	8b 45 08             	mov    0x8(%ebp),%eax
  78:	8a 00                	mov    (%eax),%al
  7a:	0f b6 d0             	movzbl %al,%edx
  7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  80:	8a 00                	mov    (%eax),%al
  82:	0f b6 c0             	movzbl %al,%eax
  85:	29 c2                	sub    %eax,%edx
  87:	89 d0                	mov    %edx,%eax
}
  89:	5d                   	pop    %ebp
  8a:	c3                   	ret    

0000008b <strlen>:

uint
strlen(char *s)
{
  8b:	55                   	push   %ebp
  8c:	89 e5                	mov    %esp,%ebp
  8e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  91:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  98:	eb 03                	jmp    9d <strlen+0x12>
  9a:	ff 45 fc             	incl   -0x4(%ebp)
  9d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  a0:	8b 45 08             	mov    0x8(%ebp),%eax
  a3:	01 d0                	add    %edx,%eax
  a5:	8a 00                	mov    (%eax),%al
  a7:	84 c0                	test   %al,%al
  a9:	75 ef                	jne    9a <strlen+0xf>
    ;
  return n;
  ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ae:	c9                   	leave  
  af:	c3                   	ret    

000000b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  b6:	8b 45 10             	mov    0x10(%ebp),%eax
  b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	89 04 24             	mov    %eax,(%esp)
  ca:	e8 31 ff ff ff       	call   0 <stosb>
  return dst;
  cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  d2:	c9                   	leave  
  d3:	c3                   	ret    

000000d4 <strchr>:

char*
strchr(const char *s, char c)
{
  d4:	55                   	push   %ebp
  d5:	89 e5                	mov    %esp,%ebp
  d7:	83 ec 04             	sub    $0x4,%esp
  da:	8b 45 0c             	mov    0xc(%ebp),%eax
  dd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  e0:	eb 12                	jmp    f4 <strchr+0x20>
    if(*s == c)
  e2:	8b 45 08             	mov    0x8(%ebp),%eax
  e5:	8a 00                	mov    (%eax),%al
  e7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  ea:	75 05                	jne    f1 <strchr+0x1d>
      return (char*)s;
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	eb 11                	jmp    102 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
  f1:	ff 45 08             	incl   0x8(%ebp)
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	8a 00                	mov    (%eax),%al
  f9:	84 c0                	test   %al,%al
  fb:	75 e5                	jne    e2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
  fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <gets>:

char*
gets(char *buf, int max)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 10a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 111:	eb 49                	jmp    15c <gets+0x58>
    cc = read(0, &c, 1);
 113:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 11a:	00 
 11b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 11e:	89 44 24 04          	mov    %eax,0x4(%esp)
 122:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 129:	e8 22 02 00 00       	call   350 <read>
 12e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 131:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 135:	7f 02                	jg     139 <gets+0x35>
      break;
 137:	eb 2c                	jmp    165 <gets+0x61>
    buf[i++] = c;
 139:	8b 45 f4             	mov    -0xc(%ebp),%eax
 13c:	8d 50 01             	lea    0x1(%eax),%edx
 13f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 142:	89 c2                	mov    %eax,%edx
 144:	8b 45 08             	mov    0x8(%ebp),%eax
 147:	01 c2                	add    %eax,%edx
 149:	8a 45 ef             	mov    -0x11(%ebp),%al
 14c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 14e:	8a 45 ef             	mov    -0x11(%ebp),%al
 151:	3c 0a                	cmp    $0xa,%al
 153:	74 10                	je     165 <gets+0x61>
 155:	8a 45 ef             	mov    -0x11(%ebp),%al
 158:	3c 0d                	cmp    $0xd,%al
 15a:	74 09                	je     165 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15f:	40                   	inc    %eax
 160:	3b 45 0c             	cmp    0xc(%ebp),%eax
 163:	7c ae                	jl     113 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 165:	8b 55 f4             	mov    -0xc(%ebp),%edx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	01 d0                	add    %edx,%eax
 16d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 170:	8b 45 08             	mov    0x8(%ebp),%eax
}
 173:	c9                   	leave  
 174:	c3                   	ret    

00000175 <stat>:

int
stat(char *n, struct stat *st)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 182:	00 
 183:	8b 45 08             	mov    0x8(%ebp),%eax
 186:	89 04 24             	mov    %eax,(%esp)
 189:	e8 ea 01 00 00       	call   378 <open>
 18e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 191:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 195:	79 07                	jns    19e <stat+0x29>
    return -1;
 197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 19c:	eb 23                	jmp    1c1 <stat+0x4c>
  r = fstat(fd, st);
 19e:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	89 04 24             	mov    %eax,(%esp)
 1ab:	e8 e0 01 00 00       	call   390 <fstat>
 1b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b6:	89 04 24             	mov    %eax,(%esp)
 1b9:	e8 a2 01 00 00       	call   360 <close>
  return r;
 1be:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1c1:	c9                   	leave  
 1c2:	c3                   	ret    

000001c3 <atoi>:

int
atoi(const char *s)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1d0:	eb 24                	jmp    1f6 <atoi+0x33>
    n = n*10 + *s++ - '0';
 1d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d5:	89 d0                	mov    %edx,%eax
 1d7:	c1 e0 02             	shl    $0x2,%eax
 1da:	01 d0                	add    %edx,%eax
 1dc:	01 c0                	add    %eax,%eax
 1de:	89 c1                	mov    %eax,%ecx
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	8d 50 01             	lea    0x1(%eax),%edx
 1e6:	89 55 08             	mov    %edx,0x8(%ebp)
 1e9:	8a 00                	mov    (%eax),%al
 1eb:	0f be c0             	movsbl %al,%eax
 1ee:	01 c8                	add    %ecx,%eax
 1f0:	83 e8 30             	sub    $0x30,%eax
 1f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	8a 00                	mov    (%eax),%al
 1fb:	3c 2f                	cmp    $0x2f,%al
 1fd:	7e 09                	jle    208 <atoi+0x45>
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	8a 00                	mov    (%eax),%al
 204:	3c 39                	cmp    $0x39,%al
 206:	7e ca                	jle    1d2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 208:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
 210:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 219:	8b 45 0c             	mov    0xc(%ebp),%eax
 21c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 21f:	eb 16                	jmp    237 <memmove+0x2a>
    *dst++ = *src++;
 221:	8b 45 fc             	mov    -0x4(%ebp),%eax
 224:	8d 50 01             	lea    0x1(%eax),%edx
 227:	89 55 fc             	mov    %edx,-0x4(%ebp)
 22a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 22d:	8d 4a 01             	lea    0x1(%edx),%ecx
 230:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 233:	8a 12                	mov    (%edx),%dl
 235:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 237:	8b 45 10             	mov    0x10(%ebp),%eax
 23a:	8d 50 ff             	lea    -0x1(%eax),%edx
 23d:	89 55 10             	mov    %edx,0x10(%ebp)
 240:	85 c0                	test   %eax,%eax
 242:	7f dd                	jg     221 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
}
 247:	c9                   	leave  
 248:	c3                   	ret    

00000249 <itoa>:

int itoa(int value, char *sp, int radix)
{
 249:	55                   	push   %ebp
 24a:	89 e5                	mov    %esp,%ebp
 24c:	53                   	push   %ebx
 24d:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 250:	8d 45 d8             	lea    -0x28(%ebp),%eax
 253:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 256:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 25a:	75 0d                	jne    269 <itoa+0x20>
 25c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 260:	79 07                	jns    269 <itoa+0x20>
 262:	b8 01 00 00 00       	mov    $0x1,%eax
 267:	eb 05                	jmp    26e <itoa+0x25>
 269:	b8 00 00 00 00       	mov    $0x0,%eax
 26e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 271:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 275:	74 0a                	je     281 <itoa+0x38>
      v = -value;
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	f7 d8                	neg    %eax
 27c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 27f:	eb 54                	jmp    2d5 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 281:	8b 45 08             	mov    0x8(%ebp),%eax
 284:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 287:	eb 4c                	jmp    2d5 <itoa+0x8c>
  {
    i = v % radix;
 289:	8b 4d 10             	mov    0x10(%ebp),%ecx
 28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28f:	ba 00 00 00 00       	mov    $0x0,%edx
 294:	f7 f1                	div    %ecx
 296:	89 d0                	mov    %edx,%eax
 298:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 29b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 29e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a1:	ba 00 00 00 00       	mov    $0x0,%edx
 2a6:	f7 f3                	div    %ebx
 2a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 2ab:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 2af:	7f 13                	jg     2c4 <itoa+0x7b>
      *tp++ = i+'0';
 2b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2b4:	8d 50 01             	lea    0x1(%eax),%edx
 2b7:	89 55 f8             	mov    %edx,-0x8(%ebp)
 2ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2bd:	83 c2 30             	add    $0x30,%edx
 2c0:	88 10                	mov    %dl,(%eax)
 2c2:	eb 11                	jmp    2d5 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 2c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2c7:	8d 50 01             	lea    0x1(%eax),%edx
 2ca:	89 55 f8             	mov    %edx,-0x8(%ebp)
 2cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2d0:	83 c2 57             	add    $0x57,%edx
 2d3:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d9:	75 ae                	jne    289 <itoa+0x40>
 2db:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2de:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 2e1:	74 a6                	je     289 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 2e3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2e6:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2e9:	29 c2                	sub    %eax,%edx
 2eb:	89 d0                	mov    %edx,%eax
 2ed:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 2f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2f4:	74 11                	je     307 <itoa+0xbe>
  {
    *sp++ = '-';
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	8d 50 01             	lea    0x1(%eax),%edx
 2fc:	89 55 0c             	mov    %edx,0xc(%ebp)
 2ff:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 302:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 305:	eb 15                	jmp    31c <itoa+0xd3>
 307:	eb 13                	jmp    31c <itoa+0xd3>
    *sp++ = *--tp;
 309:	8b 45 0c             	mov    0xc(%ebp),%eax
 30c:	8d 50 01             	lea    0x1(%eax),%edx
 30f:	89 55 0c             	mov    %edx,0xc(%ebp)
 312:	ff 4d f8             	decl   -0x8(%ebp)
 315:	8b 55 f8             	mov    -0x8(%ebp),%edx
 318:	8a 12                	mov    (%edx),%dl
 31a:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 31c:	8d 45 d8             	lea    -0x28(%ebp),%eax
 31f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 322:	77 e5                	ja     309 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 324:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 327:	83 c4 30             	add    $0x30,%esp
 32a:	5b                   	pop    %ebx
 32b:	5d                   	pop    %ebp
 32c:	c3                   	ret    
 32d:	90                   	nop
 32e:	90                   	nop
 32f:	90                   	nop

00000330 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 330:	b8 01 00 00 00       	mov    $0x1,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <exit>:
SYSCALL(exit)
 338:	b8 02 00 00 00       	mov    $0x2,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <wait>:
SYSCALL(wait)
 340:	b8 03 00 00 00       	mov    $0x3,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <pipe>:
SYSCALL(pipe)
 348:	b8 04 00 00 00       	mov    $0x4,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <read>:
SYSCALL(read)
 350:	b8 05 00 00 00       	mov    $0x5,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <write>:
SYSCALL(write)
 358:	b8 10 00 00 00       	mov    $0x10,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <close>:
SYSCALL(close)
 360:	b8 15 00 00 00       	mov    $0x15,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <kill>:
SYSCALL(kill)
 368:	b8 06 00 00 00       	mov    $0x6,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <exec>:
SYSCALL(exec)
 370:	b8 07 00 00 00       	mov    $0x7,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <open>:
SYSCALL(open)
 378:	b8 0f 00 00 00       	mov    $0xf,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <mknod>:
SYSCALL(mknod)
 380:	b8 11 00 00 00       	mov    $0x11,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <unlink>:
SYSCALL(unlink)
 388:	b8 12 00 00 00       	mov    $0x12,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <fstat>:
SYSCALL(fstat)
 390:	b8 08 00 00 00       	mov    $0x8,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <link>:
SYSCALL(link)
 398:	b8 13 00 00 00       	mov    $0x13,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <mkdir>:
SYSCALL(mkdir)
 3a0:	b8 14 00 00 00       	mov    $0x14,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <chdir>:
SYSCALL(chdir)
 3a8:	b8 09 00 00 00       	mov    $0x9,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <dup>:
SYSCALL(dup)
 3b0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <getpid>:
SYSCALL(getpid)
 3b8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <sbrk>:
SYSCALL(sbrk)
 3c0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <sleep>:
SYSCALL(sleep)
 3c8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <uptime>:
SYSCALL(uptime)
 3d0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <getticks>:
SYSCALL(getticks)
 3d8:	b8 16 00 00 00       	mov    $0x16,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <get_name>:
SYSCALL(get_name)
 3e0:	b8 17 00 00 00       	mov    $0x17,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <get_max_proc>:
SYSCALL(get_max_proc)
 3e8:	b8 18 00 00 00       	mov    $0x18,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <get_max_mem>:
SYSCALL(get_max_mem)
 3f0:	b8 19 00 00 00       	mov    $0x19,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <get_max_disk>:
SYSCALL(get_max_disk)
 3f8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <get_curr_proc>:
SYSCALL(get_curr_proc)
 400:	b8 1b 00 00 00       	mov    $0x1b,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <get_curr_mem>:
SYSCALL(get_curr_mem)
 408:	b8 1c 00 00 00       	mov    $0x1c,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <get_curr_disk>:
SYSCALL(get_curr_disk)
 410:	b8 1d 00 00 00       	mov    $0x1d,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <set_name>:
SYSCALL(set_name)
 418:	b8 1e 00 00 00       	mov    $0x1e,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <set_max_mem>:
SYSCALL(set_max_mem)
 420:	b8 1f 00 00 00       	mov    $0x1f,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <set_max_disk>:
SYSCALL(set_max_disk)
 428:	b8 20 00 00 00       	mov    $0x20,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <set_max_proc>:
SYSCALL(set_max_proc)
 430:	b8 21 00 00 00       	mov    $0x21,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <set_curr_mem>:
SYSCALL(set_curr_mem)
 438:	b8 22 00 00 00       	mov    $0x22,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <set_curr_disk>:
SYSCALL(set_curr_disk)
 440:	b8 23 00 00 00       	mov    $0x23,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <set_curr_proc>:
SYSCALL(set_curr_proc)
 448:	b8 24 00 00 00       	mov    $0x24,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <find>:
SYSCALL(find)
 450:	b8 25 00 00 00       	mov    $0x25,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <is_full>:
SYSCALL(is_full)
 458:	b8 26 00 00 00       	mov    $0x26,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <container_init>:
SYSCALL(container_init)
 460:	b8 27 00 00 00       	mov    $0x27,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <cont_proc_set>:
SYSCALL(cont_proc_set)
 468:	b8 28 00 00 00       	mov    $0x28,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <ps>:
SYSCALL(ps)
 470:	b8 29 00 00 00       	mov    $0x29,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 478:	b8 2a 00 00 00       	mov    $0x2a,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <set_root_inode>:
SYSCALL(set_root_inode)
 480:	b8 2b 00 00 00       	mov    $0x2b,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <cstop>:
SYSCALL(cstop)
 488:	b8 2c 00 00 00       	mov    $0x2c,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <df>:
SYSCALL(df)
 490:	b8 2d 00 00 00       	mov    $0x2d,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <max_containers>:
SYSCALL(max_containers)
 498:	b8 2e 00 00 00       	mov    $0x2e,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <container_reset>:
SYSCALL(container_reset)
 4a0:	b8 2f 00 00 00       	mov    $0x2f,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <pause>:
SYSCALL(pause)
 4a8:	b8 30 00 00 00       	mov    $0x30,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <resume>:
SYSCALL(resume)
 4b0:	b8 31 00 00 00       	mov    $0x31,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <tmem>:
SYSCALL(tmem)
 4b8:	b8 32 00 00 00       	mov    $0x32,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <amem>:
SYSCALL(amem)
 4c0:	b8 33 00 00 00       	mov    $0x33,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <c_ps>:
SYSCALL(c_ps)
 4c8:	b8 34 00 00 00       	mov    $0x34,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <get_used>:
SYSCALL(get_used)
 4d0:	b8 35 00 00 00       	mov    $0x35,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4d8:	55                   	push   %ebp
 4d9:	89 e5                	mov    %esp,%ebp
 4db:	83 ec 18             	sub    $0x18,%esp
 4de:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4eb:	00 
 4ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	89 04 24             	mov    %eax,(%esp)
 4f9:	e8 5a fe ff ff       	call   358 <write>
}
 4fe:	c9                   	leave  
 4ff:	c3                   	ret    

00000500 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 500:	55                   	push   %ebp
 501:	89 e5                	mov    %esp,%ebp
 503:	56                   	push   %esi
 504:	53                   	push   %ebx
 505:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 508:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 50f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 513:	74 17                	je     52c <printint+0x2c>
 515:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 519:	79 11                	jns    52c <printint+0x2c>
    neg = 1;
 51b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 522:	8b 45 0c             	mov    0xc(%ebp),%eax
 525:	f7 d8                	neg    %eax
 527:	89 45 ec             	mov    %eax,-0x14(%ebp)
 52a:	eb 06                	jmp    532 <printint+0x32>
  } else {
    x = xx;
 52c:	8b 45 0c             	mov    0xc(%ebp),%eax
 52f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 532:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 539:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 53c:	8d 41 01             	lea    0x1(%ecx),%eax
 53f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 542:	8b 5d 10             	mov    0x10(%ebp),%ebx
 545:	8b 45 ec             	mov    -0x14(%ebp),%eax
 548:	ba 00 00 00 00       	mov    $0x0,%edx
 54d:	f7 f3                	div    %ebx
 54f:	89 d0                	mov    %edx,%eax
 551:	8a 80 d0 0b 00 00    	mov    0xbd0(%eax),%al
 557:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 55b:	8b 75 10             	mov    0x10(%ebp),%esi
 55e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 561:	ba 00 00 00 00       	mov    $0x0,%edx
 566:	f7 f6                	div    %esi
 568:	89 45 ec             	mov    %eax,-0x14(%ebp)
 56b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56f:	75 c8                	jne    539 <printint+0x39>
  if(neg)
 571:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 575:	74 10                	je     587 <printint+0x87>
    buf[i++] = '-';
 577:	8b 45 f4             	mov    -0xc(%ebp),%eax
 57a:	8d 50 01             	lea    0x1(%eax),%edx
 57d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 580:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 585:	eb 1e                	jmp    5a5 <printint+0xa5>
 587:	eb 1c                	jmp    5a5 <printint+0xa5>
    putc(fd, buf[i]);
 589:	8d 55 dc             	lea    -0x24(%ebp),%edx
 58c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58f:	01 d0                	add    %edx,%eax
 591:	8a 00                	mov    (%eax),%al
 593:	0f be c0             	movsbl %al,%eax
 596:	89 44 24 04          	mov    %eax,0x4(%esp)
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	89 04 24             	mov    %eax,(%esp)
 5a0:	e8 33 ff ff ff       	call   4d8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5a5:	ff 4d f4             	decl   -0xc(%ebp)
 5a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ac:	79 db                	jns    589 <printint+0x89>
    putc(fd, buf[i]);
}
 5ae:	83 c4 30             	add    $0x30,%esp
 5b1:	5b                   	pop    %ebx
 5b2:	5e                   	pop    %esi
 5b3:	5d                   	pop    %ebp
 5b4:	c3                   	ret    

000005b5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5b5:	55                   	push   %ebp
 5b6:	89 e5                	mov    %esp,%ebp
 5b8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5c2:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c5:	83 c0 04             	add    $0x4,%eax
 5c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5d2:	e9 77 01 00 00       	jmp    74e <printf+0x199>
    c = fmt[i] & 0xff;
 5d7:	8b 55 0c             	mov    0xc(%ebp),%edx
 5da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5dd:	01 d0                	add    %edx,%eax
 5df:	8a 00                	mov    (%eax),%al
 5e1:	0f be c0             	movsbl %al,%eax
 5e4:	25 ff 00 00 00       	and    $0xff,%eax
 5e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f0:	75 2c                	jne    61e <printf+0x69>
      if(c == '%'){
 5f2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f6:	75 0c                	jne    604 <printf+0x4f>
        state = '%';
 5f8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5ff:	e9 47 01 00 00       	jmp    74b <printf+0x196>
      } else {
        putc(fd, c);
 604:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 607:	0f be c0             	movsbl %al,%eax
 60a:	89 44 24 04          	mov    %eax,0x4(%esp)
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	89 04 24             	mov    %eax,(%esp)
 614:	e8 bf fe ff ff       	call   4d8 <putc>
 619:	e9 2d 01 00 00       	jmp    74b <printf+0x196>
      }
    } else if(state == '%'){
 61e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 622:	0f 85 23 01 00 00    	jne    74b <printf+0x196>
      if(c == 'd'){
 628:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 62c:	75 2d                	jne    65b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 62e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 631:	8b 00                	mov    (%eax),%eax
 633:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 63a:	00 
 63b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 642:	00 
 643:	89 44 24 04          	mov    %eax,0x4(%esp)
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 ae fe ff ff       	call   500 <printint>
        ap++;
 652:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 656:	e9 e9 00 00 00       	jmp    744 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 65b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 65f:	74 06                	je     667 <printf+0xb2>
 661:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 665:	75 2d                	jne    694 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 667:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66a:	8b 00                	mov    (%eax),%eax
 66c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 673:	00 
 674:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 67b:	00 
 67c:	89 44 24 04          	mov    %eax,0x4(%esp)
 680:	8b 45 08             	mov    0x8(%ebp),%eax
 683:	89 04 24             	mov    %eax,(%esp)
 686:	e8 75 fe ff ff       	call   500 <printint>
        ap++;
 68b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68f:	e9 b0 00 00 00       	jmp    744 <printf+0x18f>
      } else if(c == 's'){
 694:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 698:	75 42                	jne    6dc <printf+0x127>
        s = (char*)*ap;
 69a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69d:	8b 00                	mov    (%eax),%eax
 69f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6aa:	75 09                	jne    6b5 <printf+0x100>
          s = "(null)";
 6ac:	c7 45 f4 7b 09 00 00 	movl   $0x97b,-0xc(%ebp)
        while(*s != 0){
 6b3:	eb 1c                	jmp    6d1 <printf+0x11c>
 6b5:	eb 1a                	jmp    6d1 <printf+0x11c>
          putc(fd, *s);
 6b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ba:	8a 00                	mov    (%eax),%al
 6bc:	0f be c0             	movsbl %al,%eax
 6bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	89 04 24             	mov    %eax,(%esp)
 6c9:	e8 0a fe ff ff       	call   4d8 <putc>
          s++;
 6ce:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d4:	8a 00                	mov    (%eax),%al
 6d6:	84 c0                	test   %al,%al
 6d8:	75 dd                	jne    6b7 <printf+0x102>
 6da:	eb 68                	jmp    744 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6dc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e0:	75 1d                	jne    6ff <printf+0x14a>
        putc(fd, *ap);
 6e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e5:	8b 00                	mov    (%eax),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	89 04 24             	mov    %eax,(%esp)
 6f4:	e8 df fd ff ff       	call   4d8 <putc>
        ap++;
 6f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6fd:	eb 45                	jmp    744 <printf+0x18f>
      } else if(c == '%'){
 6ff:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 703:	75 17                	jne    71c <printf+0x167>
        putc(fd, c);
 705:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 708:	0f be c0             	movsbl %al,%eax
 70b:	89 44 24 04          	mov    %eax,0x4(%esp)
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	89 04 24             	mov    %eax,(%esp)
 715:	e8 be fd ff ff       	call   4d8 <putc>
 71a:	eb 28                	jmp    744 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 71c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 723:	00 
 724:	8b 45 08             	mov    0x8(%ebp),%eax
 727:	89 04 24             	mov    %eax,(%esp)
 72a:	e8 a9 fd ff ff       	call   4d8 <putc>
        putc(fd, c);
 72f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 732:	0f be c0             	movsbl %al,%eax
 735:	89 44 24 04          	mov    %eax,0x4(%esp)
 739:	8b 45 08             	mov    0x8(%ebp),%eax
 73c:	89 04 24             	mov    %eax,(%esp)
 73f:	e8 94 fd ff ff       	call   4d8 <putc>
      }
      state = 0;
 744:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 74b:	ff 45 f0             	incl   -0x10(%ebp)
 74e:	8b 55 0c             	mov    0xc(%ebp),%edx
 751:	8b 45 f0             	mov    -0x10(%ebp),%eax
 754:	01 d0                	add    %edx,%eax
 756:	8a 00                	mov    (%eax),%al
 758:	84 c0                	test   %al,%al
 75a:	0f 85 77 fe ff ff    	jne    5d7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 760:	c9                   	leave  
 761:	c3                   	ret    
 762:	90                   	nop
 763:	90                   	nop

00000764 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 764:	55                   	push   %ebp
 765:	89 e5                	mov    %esp,%ebp
 767:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76a:	8b 45 08             	mov    0x8(%ebp),%eax
 76d:	83 e8 08             	sub    $0x8,%eax
 770:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 773:	a1 ec 0b 00 00       	mov    0xbec,%eax
 778:	89 45 fc             	mov    %eax,-0x4(%ebp)
 77b:	eb 24                	jmp    7a1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 780:	8b 00                	mov    (%eax),%eax
 782:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 785:	77 12                	ja     799 <free+0x35>
 787:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 78d:	77 24                	ja     7b3 <free+0x4f>
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	8b 00                	mov    (%eax),%eax
 794:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 797:	77 1a                	ja     7b3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	8b 00                	mov    (%eax),%eax
 79e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a7:	76 d4                	jbe    77d <free+0x19>
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b1:	76 ca                	jbe    77d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b6:	8b 40 04             	mov    0x4(%eax),%eax
 7b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c3:	01 c2                	add    %eax,%edx
 7c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	39 c2                	cmp    %eax,%edx
 7cc:	75 24                	jne    7f2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d1:	8b 50 04             	mov    0x4(%eax),%edx
 7d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d7:	8b 00                	mov    (%eax),%eax
 7d9:	8b 40 04             	mov    0x4(%eax),%eax
 7dc:	01 c2                	add    %eax,%edx
 7de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e7:	8b 00                	mov    (%eax),%eax
 7e9:	8b 10                	mov    (%eax),%edx
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	89 10                	mov    %edx,(%eax)
 7f0:	eb 0a                	jmp    7fc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f5:	8b 10                	mov    (%eax),%edx
 7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ff:	8b 40 04             	mov    0x4(%eax),%eax
 802:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 809:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80c:	01 d0                	add    %edx,%eax
 80e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 811:	75 20                	jne    833 <free+0xcf>
    p->s.size += bp->s.size;
 813:	8b 45 fc             	mov    -0x4(%ebp),%eax
 816:	8b 50 04             	mov    0x4(%eax),%edx
 819:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81c:	8b 40 04             	mov    0x4(%eax),%eax
 81f:	01 c2                	add    %eax,%edx
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	8b 10                	mov    (%eax),%edx
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	89 10                	mov    %edx,(%eax)
 831:	eb 08                	jmp    83b <free+0xd7>
  } else
    p->s.ptr = bp;
 833:	8b 45 fc             	mov    -0x4(%ebp),%eax
 836:	8b 55 f8             	mov    -0x8(%ebp),%edx
 839:	89 10                	mov    %edx,(%eax)
  freep = p;
 83b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83e:	a3 ec 0b 00 00       	mov    %eax,0xbec
}
 843:	c9                   	leave  
 844:	c3                   	ret    

00000845 <morecore>:

static Header*
morecore(uint nu)
{
 845:	55                   	push   %ebp
 846:	89 e5                	mov    %esp,%ebp
 848:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 84b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 852:	77 07                	ja     85b <morecore+0x16>
    nu = 4096;
 854:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 85b:	8b 45 08             	mov    0x8(%ebp),%eax
 85e:	c1 e0 03             	shl    $0x3,%eax
 861:	89 04 24             	mov    %eax,(%esp)
 864:	e8 57 fb ff ff       	call   3c0 <sbrk>
 869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 86c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 870:	75 07                	jne    879 <morecore+0x34>
    return 0;
 872:	b8 00 00 00 00       	mov    $0x0,%eax
 877:	eb 22                	jmp    89b <morecore+0x56>
  hp = (Header*)p;
 879:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 87f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 882:	8b 55 08             	mov    0x8(%ebp),%edx
 885:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 888:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88b:	83 c0 08             	add    $0x8,%eax
 88e:	89 04 24             	mov    %eax,(%esp)
 891:	e8 ce fe ff ff       	call   764 <free>
  return freep;
 896:	a1 ec 0b 00 00       	mov    0xbec,%eax
}
 89b:	c9                   	leave  
 89c:	c3                   	ret    

0000089d <malloc>:

void*
malloc(uint nbytes)
{
 89d:	55                   	push   %ebp
 89e:	89 e5                	mov    %esp,%ebp
 8a0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a3:	8b 45 08             	mov    0x8(%ebp),%eax
 8a6:	83 c0 07             	add    $0x7,%eax
 8a9:	c1 e8 03             	shr    $0x3,%eax
 8ac:	40                   	inc    %eax
 8ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8b0:	a1 ec 0b 00 00       	mov    0xbec,%eax
 8b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8bc:	75 23                	jne    8e1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8be:	c7 45 f0 e4 0b 00 00 	movl   $0xbe4,-0x10(%ebp)
 8c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c8:	a3 ec 0b 00 00       	mov    %eax,0xbec
 8cd:	a1 ec 0b 00 00       	mov    0xbec,%eax
 8d2:	a3 e4 0b 00 00       	mov    %eax,0xbe4
    base.s.size = 0;
 8d7:	c7 05 e8 0b 00 00 00 	movl   $0x0,0xbe8
 8de:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ec:	8b 40 04             	mov    0x4(%eax),%eax
 8ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f2:	72 4d                	jb     941 <malloc+0xa4>
      if(p->s.size == nunits)
 8f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f7:	8b 40 04             	mov    0x4(%eax),%eax
 8fa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8fd:	75 0c                	jne    90b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 8ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 902:	8b 10                	mov    (%eax),%edx
 904:	8b 45 f0             	mov    -0x10(%ebp),%eax
 907:	89 10                	mov    %edx,(%eax)
 909:	eb 26                	jmp    931 <malloc+0x94>
      else {
        p->s.size -= nunits;
 90b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90e:	8b 40 04             	mov    0x4(%eax),%eax
 911:	2b 45 ec             	sub    -0x14(%ebp),%eax
 914:	89 c2                	mov    %eax,%edx
 916:	8b 45 f4             	mov    -0xc(%ebp),%eax
 919:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 91c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91f:	8b 40 04             	mov    0x4(%eax),%eax
 922:	c1 e0 03             	shl    $0x3,%eax
 925:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 928:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 92e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 931:	8b 45 f0             	mov    -0x10(%ebp),%eax
 934:	a3 ec 0b 00 00       	mov    %eax,0xbec
      return (void*)(p + 1);
 939:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93c:	83 c0 08             	add    $0x8,%eax
 93f:	eb 38                	jmp    979 <malloc+0xdc>
    }
    if(p == freep)
 941:	a1 ec 0b 00 00       	mov    0xbec,%eax
 946:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 949:	75 1b                	jne    966 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 94b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 94e:	89 04 24             	mov    %eax,(%esp)
 951:	e8 ef fe ff ff       	call   845 <morecore>
 956:	89 45 f4             	mov    %eax,-0xc(%ebp)
 959:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 95d:	75 07                	jne    966 <malloc+0xc9>
        return 0;
 95f:	b8 00 00 00 00       	mov    $0x0,%eax
 964:	eb 13                	jmp    979 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 966:	8b 45 f4             	mov    -0xc(%ebp),%eax
 969:	89 45 f0             	mov    %eax,-0x10(%ebp)
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	8b 00                	mov    (%eax),%eax
 971:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 974:	e9 70 ff ff ff       	jmp    8e9 <malloc+0x4c>
}
 979:	c9                   	leave  
 97a:	c3                   	ret    
