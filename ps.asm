
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"


int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
	ps();
   6:	e8 75 04 00 00       	call   480 <ps>
	exit();
   b:	e8 38 03 00 00       	call   348 <exit>

00000010 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  10:	55                   	push   %ebp
  11:	89 e5                	mov    %esp,%ebp
  13:	57                   	push   %edi
  14:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  18:	8b 55 10             	mov    0x10(%ebp),%edx
  1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  1e:	89 cb                	mov    %ecx,%ebx
  20:	89 df                	mov    %ebx,%edi
  22:	89 d1                	mov    %edx,%ecx
  24:	fc                   	cld    
  25:	f3 aa                	rep stos %al,%es:(%edi)
  27:	89 ca                	mov    %ecx,%edx
  29:	89 fb                	mov    %edi,%ebx
  2b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  2e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  31:	5b                   	pop    %ebx
  32:	5f                   	pop    %edi
  33:	5d                   	pop    %ebp
  34:	c3                   	ret    

00000035 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  35:	55                   	push   %ebp
  36:	89 e5                	mov    %esp,%ebp
  38:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  3b:	8b 45 08             	mov    0x8(%ebp),%eax
  3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  41:	90                   	nop
  42:	8b 45 08             	mov    0x8(%ebp),%eax
  45:	8d 50 01             	lea    0x1(%eax),%edx
  48:	89 55 08             	mov    %edx,0x8(%ebp)
  4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  4e:	8d 4a 01             	lea    0x1(%edx),%ecx
  51:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  54:	8a 12                	mov    (%edx),%dl
  56:	88 10                	mov    %dl,(%eax)
  58:	8a 00                	mov    (%eax),%al
  5a:	84 c0                	test   %al,%al
  5c:	75 e4                	jne    42 <strcpy+0xd>
    ;
  return os;
  5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  61:	c9                   	leave  
  62:	c3                   	ret    

00000063 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  63:	55                   	push   %ebp
  64:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  66:	eb 06                	jmp    6e <strcmp+0xb>
    p++, q++;
  68:	ff 45 08             	incl   0x8(%ebp)
  6b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  6e:	8b 45 08             	mov    0x8(%ebp),%eax
  71:	8a 00                	mov    (%eax),%al
  73:	84 c0                	test   %al,%al
  75:	74 0e                	je     85 <strcmp+0x22>
  77:	8b 45 08             	mov    0x8(%ebp),%eax
  7a:	8a 10                	mov    (%eax),%dl
  7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  7f:	8a 00                	mov    (%eax),%al
  81:	38 c2                	cmp    %al,%dl
  83:	74 e3                	je     68 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  85:	8b 45 08             	mov    0x8(%ebp),%eax
  88:	8a 00                	mov    (%eax),%al
  8a:	0f b6 d0             	movzbl %al,%edx
  8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  90:	8a 00                	mov    (%eax),%al
  92:	0f b6 c0             	movzbl %al,%eax
  95:	29 c2                	sub    %eax,%edx
  97:	89 d0                	mov    %edx,%eax
}
  99:	5d                   	pop    %ebp
  9a:	c3                   	ret    

0000009b <strlen>:

uint
strlen(char *s)
{
  9b:	55                   	push   %ebp
  9c:	89 e5                	mov    %esp,%ebp
  9e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  a8:	eb 03                	jmp    ad <strlen+0x12>
  aa:	ff 45 fc             	incl   -0x4(%ebp)
  ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	01 d0                	add    %edx,%eax
  b5:	8a 00                	mov    (%eax),%al
  b7:	84 c0                	test   %al,%al
  b9:	75 ef                	jne    aa <strlen+0xf>
    ;
  return n;
  bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  be:	c9                   	leave  
  bf:	c3                   	ret    

000000c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  c6:	8b 45 10             	mov    0x10(%ebp),%eax
  c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	89 04 24             	mov    %eax,(%esp)
  da:	e8 31 ff ff ff       	call   10 <stosb>
  return dst;
  df:	8b 45 08             	mov    0x8(%ebp),%eax
}
  e2:	c9                   	leave  
  e3:	c3                   	ret    

000000e4 <strchr>:

char*
strchr(const char *s, char c)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	83 ec 04             	sub    $0x4,%esp
  ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  f0:	eb 12                	jmp    104 <strchr+0x20>
    if(*s == c)
  f2:	8b 45 08             	mov    0x8(%ebp),%eax
  f5:	8a 00                	mov    (%eax),%al
  f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  fa:	75 05                	jne    101 <strchr+0x1d>
      return (char*)s;
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	eb 11                	jmp    112 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 101:	ff 45 08             	incl   0x8(%ebp)
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	8a 00                	mov    (%eax),%al
 109:	84 c0                	test   %al,%al
 10b:	75 e5                	jne    f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 10d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 112:	c9                   	leave  
 113:	c3                   	ret    

00000114 <gets>:

char*
gets(char *buf, int max)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 121:	eb 49                	jmp    16c <gets+0x58>
    cc = read(0, &c, 1);
 123:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 12a:	00 
 12b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 12e:	89 44 24 04          	mov    %eax,0x4(%esp)
 132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 139:	e8 22 02 00 00       	call   360 <read>
 13e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 141:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 145:	7f 02                	jg     149 <gets+0x35>
      break;
 147:	eb 2c                	jmp    175 <gets+0x61>
    buf[i++] = c;
 149:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14c:	8d 50 01             	lea    0x1(%eax),%edx
 14f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 152:	89 c2                	mov    %eax,%edx
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	01 c2                	add    %eax,%edx
 159:	8a 45 ef             	mov    -0x11(%ebp),%al
 15c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 15e:	8a 45 ef             	mov    -0x11(%ebp),%al
 161:	3c 0a                	cmp    $0xa,%al
 163:	74 10                	je     175 <gets+0x61>
 165:	8a 45 ef             	mov    -0x11(%ebp),%al
 168:	3c 0d                	cmp    $0xd,%al
 16a:	74 09                	je     175 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16f:	40                   	inc    %eax
 170:	3b 45 0c             	cmp    0xc(%ebp),%eax
 173:	7c ae                	jl     123 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 175:	8b 55 f4             	mov    -0xc(%ebp),%edx
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	01 d0                	add    %edx,%eax
 17d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 180:	8b 45 08             	mov    0x8(%ebp),%eax
}
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <stat>:

int
stat(char *n, struct stat *st)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 192:	00 
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	89 04 24             	mov    %eax,(%esp)
 199:	e8 ea 01 00 00       	call   388 <open>
 19e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1a5:	79 07                	jns    1ae <stat+0x29>
    return -1;
 1a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1ac:	eb 23                	jmp    1d1 <stat+0x4c>
  r = fstat(fd, st);
 1ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	89 04 24             	mov    %eax,(%esp)
 1bb:	e8 e0 01 00 00       	call   3a0 <fstat>
 1c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	89 04 24             	mov    %eax,(%esp)
 1c9:	e8 a2 01 00 00       	call   370 <close>
  return r;
 1ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <atoi>:

int
atoi(const char *s)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1e0:	eb 24                	jmp    206 <atoi+0x33>
    n = n*10 + *s++ - '0';
 1e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1e5:	89 d0                	mov    %edx,%eax
 1e7:	c1 e0 02             	shl    $0x2,%eax
 1ea:	01 d0                	add    %edx,%eax
 1ec:	01 c0                	add    %eax,%eax
 1ee:	89 c1                	mov    %eax,%ecx
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	8d 50 01             	lea    0x1(%eax),%edx
 1f6:	89 55 08             	mov    %edx,0x8(%ebp)
 1f9:	8a 00                	mov    (%eax),%al
 1fb:	0f be c0             	movsbl %al,%eax
 1fe:	01 c8                	add    %ecx,%eax
 200:	83 e8 30             	sub    $0x30,%eax
 203:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	8a 00                	mov    (%eax),%al
 20b:	3c 2f                	cmp    $0x2f,%al
 20d:	7e 09                	jle    218 <atoi+0x45>
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	8a 00                	mov    (%eax),%al
 214:	3c 39                	cmp    $0x39,%al
 216:	7e ca                	jle    1e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 229:	8b 45 0c             	mov    0xc(%ebp),%eax
 22c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 22f:	eb 16                	jmp    247 <memmove+0x2a>
    *dst++ = *src++;
 231:	8b 45 fc             	mov    -0x4(%ebp),%eax
 234:	8d 50 01             	lea    0x1(%eax),%edx
 237:	89 55 fc             	mov    %edx,-0x4(%ebp)
 23a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 23d:	8d 4a 01             	lea    0x1(%edx),%ecx
 240:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 243:	8a 12                	mov    (%edx),%dl
 245:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 247:	8b 45 10             	mov    0x10(%ebp),%eax
 24a:	8d 50 ff             	lea    -0x1(%eax),%edx
 24d:	89 55 10             	mov    %edx,0x10(%ebp)
 250:	85 c0                	test   %eax,%eax
 252:	7f dd                	jg     231 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 254:	8b 45 08             	mov    0x8(%ebp),%eax
}
 257:	c9                   	leave  
 258:	c3                   	ret    

00000259 <itoa>:

int itoa(int value, char *sp, int radix)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	53                   	push   %ebx
 25d:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 260:	8d 45 d8             	lea    -0x28(%ebp),%eax
 263:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 266:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 26a:	75 0d                	jne    279 <itoa+0x20>
 26c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 270:	79 07                	jns    279 <itoa+0x20>
 272:	b8 01 00 00 00       	mov    $0x1,%eax
 277:	eb 05                	jmp    27e <itoa+0x25>
 279:	b8 00 00 00 00       	mov    $0x0,%eax
 27e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 281:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 285:	74 0a                	je     291 <itoa+0x38>
      v = -value;
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	f7 d8                	neg    %eax
 28c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 28f:	eb 54                	jmp    2e5 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 297:	eb 4c                	jmp    2e5 <itoa+0x8c>
  {
    i = v % radix;
 299:	8b 4d 10             	mov    0x10(%ebp),%ecx
 29c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29f:	ba 00 00 00 00       	mov    $0x0,%edx
 2a4:	f7 f1                	div    %ecx
 2a6:	89 d0                	mov    %edx,%eax
 2a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 2ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
 2ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b1:	ba 00 00 00 00       	mov    $0x0,%edx
 2b6:	f7 f3                	div    %ebx
 2b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 2bb:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 2bf:	7f 13                	jg     2d4 <itoa+0x7b>
      *tp++ = i+'0';
 2c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2c4:	8d 50 01             	lea    0x1(%eax),%edx
 2c7:	89 55 f8             	mov    %edx,-0x8(%ebp)
 2ca:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2cd:	83 c2 30             	add    $0x30,%edx
 2d0:	88 10                	mov    %dl,(%eax)
 2d2:	eb 11                	jmp    2e5 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 2d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2d7:	8d 50 01             	lea    0x1(%eax),%edx
 2da:	89 55 f8             	mov    %edx,-0x8(%ebp)
 2dd:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2e0:	83 c2 57             	add    $0x57,%edx
 2e3:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e9:	75 ae                	jne    299 <itoa+0x40>
 2eb:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2ee:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 2f1:	74 a6                	je     299 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 2f3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2f6:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2f9:	29 c2                	sub    %eax,%edx
 2fb:	89 d0                	mov    %edx,%eax
 2fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 300:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 304:	74 11                	je     317 <itoa+0xbe>
  {
    *sp++ = '-';
 306:	8b 45 0c             	mov    0xc(%ebp),%eax
 309:	8d 50 01             	lea    0x1(%eax),%edx
 30c:	89 55 0c             	mov    %edx,0xc(%ebp)
 30f:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 312:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 315:	eb 15                	jmp    32c <itoa+0xd3>
 317:	eb 13                	jmp    32c <itoa+0xd3>
    *sp++ = *--tp;
 319:	8b 45 0c             	mov    0xc(%ebp),%eax
 31c:	8d 50 01             	lea    0x1(%eax),%edx
 31f:	89 55 0c             	mov    %edx,0xc(%ebp)
 322:	ff 4d f8             	decl   -0x8(%ebp)
 325:	8b 55 f8             	mov    -0x8(%ebp),%edx
 328:	8a 12                	mov    (%edx),%dl
 32a:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 32c:	8d 45 d8             	lea    -0x28(%ebp),%eax
 32f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 332:	77 e5                	ja     319 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 334:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 337:	83 c4 30             	add    $0x30,%esp
 33a:	5b                   	pop    %ebx
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    
 33d:	90                   	nop
 33e:	90                   	nop
 33f:	90                   	nop

00000340 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 340:	b8 01 00 00 00       	mov    $0x1,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <exit>:
SYSCALL(exit)
 348:	b8 02 00 00 00       	mov    $0x2,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <wait>:
SYSCALL(wait)
 350:	b8 03 00 00 00       	mov    $0x3,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <pipe>:
SYSCALL(pipe)
 358:	b8 04 00 00 00       	mov    $0x4,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <read>:
SYSCALL(read)
 360:	b8 05 00 00 00       	mov    $0x5,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <write>:
SYSCALL(write)
 368:	b8 10 00 00 00       	mov    $0x10,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <close>:
SYSCALL(close)
 370:	b8 15 00 00 00       	mov    $0x15,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <kill>:
SYSCALL(kill)
 378:	b8 06 00 00 00       	mov    $0x6,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <exec>:
SYSCALL(exec)
 380:	b8 07 00 00 00       	mov    $0x7,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <open>:
SYSCALL(open)
 388:	b8 0f 00 00 00       	mov    $0xf,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <mknod>:
SYSCALL(mknod)
 390:	b8 11 00 00 00       	mov    $0x11,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <unlink>:
SYSCALL(unlink)
 398:	b8 12 00 00 00       	mov    $0x12,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <fstat>:
SYSCALL(fstat)
 3a0:	b8 08 00 00 00       	mov    $0x8,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <link>:
SYSCALL(link)
 3a8:	b8 13 00 00 00       	mov    $0x13,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <mkdir>:
SYSCALL(mkdir)
 3b0:	b8 14 00 00 00       	mov    $0x14,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <chdir>:
SYSCALL(chdir)
 3b8:	b8 09 00 00 00       	mov    $0x9,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <dup>:
SYSCALL(dup)
 3c0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <getpid>:
SYSCALL(getpid)
 3c8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <sbrk>:
SYSCALL(sbrk)
 3d0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <sleep>:
SYSCALL(sleep)
 3d8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <uptime>:
SYSCALL(uptime)
 3e0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <getticks>:
SYSCALL(getticks)
 3e8:	b8 16 00 00 00       	mov    $0x16,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <get_name>:
SYSCALL(get_name)
 3f0:	b8 17 00 00 00       	mov    $0x17,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <get_max_proc>:
SYSCALL(get_max_proc)
 3f8:	b8 18 00 00 00       	mov    $0x18,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <get_max_mem>:
SYSCALL(get_max_mem)
 400:	b8 19 00 00 00       	mov    $0x19,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <get_max_disk>:
SYSCALL(get_max_disk)
 408:	b8 1a 00 00 00       	mov    $0x1a,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <get_curr_proc>:
SYSCALL(get_curr_proc)
 410:	b8 1b 00 00 00       	mov    $0x1b,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <get_curr_mem>:
SYSCALL(get_curr_mem)
 418:	b8 1c 00 00 00       	mov    $0x1c,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <get_curr_disk>:
SYSCALL(get_curr_disk)
 420:	b8 1d 00 00 00       	mov    $0x1d,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <set_name>:
SYSCALL(set_name)
 428:	b8 1e 00 00 00       	mov    $0x1e,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <set_max_mem>:
SYSCALL(set_max_mem)
 430:	b8 1f 00 00 00       	mov    $0x1f,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <set_max_disk>:
SYSCALL(set_max_disk)
 438:	b8 20 00 00 00       	mov    $0x20,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <set_max_proc>:
SYSCALL(set_max_proc)
 440:	b8 21 00 00 00       	mov    $0x21,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <set_curr_mem>:
SYSCALL(set_curr_mem)
 448:	b8 22 00 00 00       	mov    $0x22,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <set_curr_disk>:
SYSCALL(set_curr_disk)
 450:	b8 23 00 00 00       	mov    $0x23,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <set_curr_proc>:
SYSCALL(set_curr_proc)
 458:	b8 24 00 00 00       	mov    $0x24,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <find>:
SYSCALL(find)
 460:	b8 25 00 00 00       	mov    $0x25,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <is_full>:
SYSCALL(is_full)
 468:	b8 26 00 00 00       	mov    $0x26,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <container_init>:
SYSCALL(container_init)
 470:	b8 27 00 00 00       	mov    $0x27,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <cont_proc_set>:
SYSCALL(cont_proc_set)
 478:	b8 28 00 00 00       	mov    $0x28,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <ps>:
SYSCALL(ps)
 480:	b8 29 00 00 00       	mov    $0x29,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 488:	b8 2a 00 00 00       	mov    $0x2a,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <set_root_inode>:
SYSCALL(set_root_inode)
 490:	b8 2b 00 00 00       	mov    $0x2b,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <cstop>:
SYSCALL(cstop)
 498:	b8 2c 00 00 00       	mov    $0x2c,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <df>:
SYSCALL(df)
 4a0:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <max_containers>:
SYSCALL(max_containers)
 4a8:	b8 2e 00 00 00       	mov    $0x2e,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <container_reset>:
SYSCALL(container_reset)
 4b0:	b8 2f 00 00 00       	mov    $0x2f,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <pause>:
SYSCALL(pause)
 4b8:	b8 30 00 00 00       	mov    $0x30,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <resume>:
SYSCALL(resume)
 4c0:	b8 31 00 00 00       	mov    $0x31,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <tmem>:
SYSCALL(tmem)
 4c8:	b8 32 00 00 00       	mov    $0x32,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <amem>:
SYSCALL(amem)
 4d0:	b8 33 00 00 00       	mov    $0x33,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <c_ps>:
SYSCALL(c_ps)
 4d8:	b8 34 00 00 00       	mov    $0x34,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <get_used>:
SYSCALL(get_used)
 4e0:	b8 35 00 00 00       	mov    $0x35,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <get_os>:
SYSCALL(get_os)
 4e8:	b8 36 00 00 00       	mov    $0x36,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <set_os>:
SYSCALL(set_os)
 4f0:	b8 37 00 00 00       	mov    $0x37,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <get_cticks>:
SYSCALL(get_cticks)
 4f8:	b8 38 00 00 00       	mov    $0x38,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <tick_reset2>:
SYSCALL(tick_reset2)
 500:	b8 39 00 00 00       	mov    $0x39,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 508:	55                   	push   %ebp
 509:	89 e5                	mov    %esp,%ebp
 50b:	83 ec 18             	sub    $0x18,%esp
 50e:	8b 45 0c             	mov    0xc(%ebp),%eax
 511:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 514:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 51b:	00 
 51c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 51f:	89 44 24 04          	mov    %eax,0x4(%esp)
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	89 04 24             	mov    %eax,(%esp)
 529:	e8 3a fe ff ff       	call   368 <write>
}
 52e:	c9                   	leave  
 52f:	c3                   	ret    

00000530 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	56                   	push   %esi
 534:	53                   	push   %ebx
 535:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 538:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 53f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 543:	74 17                	je     55c <printint+0x2c>
 545:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 549:	79 11                	jns    55c <printint+0x2c>
    neg = 1;
 54b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 552:	8b 45 0c             	mov    0xc(%ebp),%eax
 555:	f7 d8                	neg    %eax
 557:	89 45 ec             	mov    %eax,-0x14(%ebp)
 55a:	eb 06                	jmp    562 <printint+0x32>
  } else {
    x = xx;
 55c:	8b 45 0c             	mov    0xc(%ebp),%eax
 55f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 562:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 569:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 56c:	8d 41 01             	lea    0x1(%ecx),%eax
 56f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 572:	8b 5d 10             	mov    0x10(%ebp),%ebx
 575:	8b 45 ec             	mov    -0x14(%ebp),%eax
 578:	ba 00 00 00 00       	mov    $0x0,%edx
 57d:	f7 f3                	div    %ebx
 57f:	89 d0                	mov    %edx,%eax
 581:	8a 80 1c 0c 00 00    	mov    0xc1c(%eax),%al
 587:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 58b:	8b 75 10             	mov    0x10(%ebp),%esi
 58e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 591:	ba 00 00 00 00       	mov    $0x0,%edx
 596:	f7 f6                	div    %esi
 598:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 59f:	75 c8                	jne    569 <printint+0x39>
  if(neg)
 5a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a5:	74 10                	je     5b7 <printint+0x87>
    buf[i++] = '-';
 5a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5aa:	8d 50 01             	lea    0x1(%eax),%edx
 5ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5b5:	eb 1e                	jmp    5d5 <printint+0xa5>
 5b7:	eb 1c                	jmp    5d5 <printint+0xa5>
    putc(fd, buf[i]);
 5b9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bf:	01 d0                	add    %edx,%eax
 5c1:	8a 00                	mov    (%eax),%al
 5c3:	0f be c0             	movsbl %al,%eax
 5c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	89 04 24             	mov    %eax,(%esp)
 5d0:	e8 33 ff ff ff       	call   508 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d5:	ff 4d f4             	decl   -0xc(%ebp)
 5d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5dc:	79 db                	jns    5b9 <printint+0x89>
    putc(fd, buf[i]);
}
 5de:	83 c4 30             	add    $0x30,%esp
 5e1:	5b                   	pop    %ebx
 5e2:	5e                   	pop    %esi
 5e3:	5d                   	pop    %ebp
 5e4:	c3                   	ret    

000005e5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e5:	55                   	push   %ebp
 5e6:	89 e5                	mov    %esp,%ebp
 5e8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5f2:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f5:	83 c0 04             	add    $0x4,%eax
 5f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 602:	e9 77 01 00 00       	jmp    77e <printf+0x199>
    c = fmt[i] & 0xff;
 607:	8b 55 0c             	mov    0xc(%ebp),%edx
 60a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60d:	01 d0                	add    %edx,%eax
 60f:	8a 00                	mov    (%eax),%al
 611:	0f be c0             	movsbl %al,%eax
 614:	25 ff 00 00 00       	and    $0xff,%eax
 619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 61c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 620:	75 2c                	jne    64e <printf+0x69>
      if(c == '%'){
 622:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 626:	75 0c                	jne    634 <printf+0x4f>
        state = '%';
 628:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62f:	e9 47 01 00 00       	jmp    77b <printf+0x196>
      } else {
        putc(fd, c);
 634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 637:	0f be c0             	movsbl %al,%eax
 63a:	89 44 24 04          	mov    %eax,0x4(%esp)
 63e:	8b 45 08             	mov    0x8(%ebp),%eax
 641:	89 04 24             	mov    %eax,(%esp)
 644:	e8 bf fe ff ff       	call   508 <putc>
 649:	e9 2d 01 00 00       	jmp    77b <printf+0x196>
      }
    } else if(state == '%'){
 64e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 652:	0f 85 23 01 00 00    	jne    77b <printf+0x196>
      if(c == 'd'){
 658:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 65c:	75 2d                	jne    68b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 65e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 66a:	00 
 66b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 672:	00 
 673:	89 44 24 04          	mov    %eax,0x4(%esp)
 677:	8b 45 08             	mov    0x8(%ebp),%eax
 67a:	89 04 24             	mov    %eax,(%esp)
 67d:	e8 ae fe ff ff       	call   530 <printint>
        ap++;
 682:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 686:	e9 e9 00 00 00       	jmp    774 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 68b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 68f:	74 06                	je     697 <printf+0xb2>
 691:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 695:	75 2d                	jne    6c4 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 697:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69a:	8b 00                	mov    (%eax),%eax
 69c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6a3:	00 
 6a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ab:	00 
 6ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b0:	8b 45 08             	mov    0x8(%ebp),%eax
 6b3:	89 04 24             	mov    %eax,(%esp)
 6b6:	e8 75 fe ff ff       	call   530 <printint>
        ap++;
 6bb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6bf:	e9 b0 00 00 00       	jmp    774 <printf+0x18f>
      } else if(c == 's'){
 6c4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6c8:	75 42                	jne    70c <printf+0x127>
        s = (char*)*ap;
 6ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6cd:	8b 00                	mov    (%eax),%eax
 6cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6da:	75 09                	jne    6e5 <printf+0x100>
          s = "(null)";
 6dc:	c7 45 f4 ab 09 00 00 	movl   $0x9ab,-0xc(%ebp)
        while(*s != 0){
 6e3:	eb 1c                	jmp    701 <printf+0x11c>
 6e5:	eb 1a                	jmp    701 <printf+0x11c>
          putc(fd, *s);
 6e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ea:	8a 00                	mov    (%eax),%al
 6ec:	0f be c0             	movsbl %al,%eax
 6ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f3:	8b 45 08             	mov    0x8(%ebp),%eax
 6f6:	89 04 24             	mov    %eax,(%esp)
 6f9:	e8 0a fe ff ff       	call   508 <putc>
          s++;
 6fe:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 701:	8b 45 f4             	mov    -0xc(%ebp),%eax
 704:	8a 00                	mov    (%eax),%al
 706:	84 c0                	test   %al,%al
 708:	75 dd                	jne    6e7 <printf+0x102>
 70a:	eb 68                	jmp    774 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 70c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 710:	75 1d                	jne    72f <printf+0x14a>
        putc(fd, *ap);
 712:	8b 45 e8             	mov    -0x18(%ebp),%eax
 715:	8b 00                	mov    (%eax),%eax
 717:	0f be c0             	movsbl %al,%eax
 71a:	89 44 24 04          	mov    %eax,0x4(%esp)
 71e:	8b 45 08             	mov    0x8(%ebp),%eax
 721:	89 04 24             	mov    %eax,(%esp)
 724:	e8 df fd ff ff       	call   508 <putc>
        ap++;
 729:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72d:	eb 45                	jmp    774 <printf+0x18f>
      } else if(c == '%'){
 72f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 733:	75 17                	jne    74c <printf+0x167>
        putc(fd, c);
 735:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 738:	0f be c0             	movsbl %al,%eax
 73b:	89 44 24 04          	mov    %eax,0x4(%esp)
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	89 04 24             	mov    %eax,(%esp)
 745:	e8 be fd ff ff       	call   508 <putc>
 74a:	eb 28                	jmp    774 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 74c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 753:	00 
 754:	8b 45 08             	mov    0x8(%ebp),%eax
 757:	89 04 24             	mov    %eax,(%esp)
 75a:	e8 a9 fd ff ff       	call   508 <putc>
        putc(fd, c);
 75f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 762:	0f be c0             	movsbl %al,%eax
 765:	89 44 24 04          	mov    %eax,0x4(%esp)
 769:	8b 45 08             	mov    0x8(%ebp),%eax
 76c:	89 04 24             	mov    %eax,(%esp)
 76f:	e8 94 fd ff ff       	call   508 <putc>
      }
      state = 0;
 774:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 77b:	ff 45 f0             	incl   -0x10(%ebp)
 77e:	8b 55 0c             	mov    0xc(%ebp),%edx
 781:	8b 45 f0             	mov    -0x10(%ebp),%eax
 784:	01 d0                	add    %edx,%eax
 786:	8a 00                	mov    (%eax),%al
 788:	84 c0                	test   %al,%al
 78a:	0f 85 77 fe ff ff    	jne    607 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 790:	c9                   	leave  
 791:	c3                   	ret    
 792:	90                   	nop
 793:	90                   	nop

00000794 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 794:	55                   	push   %ebp
 795:	89 e5                	mov    %esp,%ebp
 797:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	83 e8 08             	sub    $0x8,%eax
 7a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a3:	a1 38 0c 00 00       	mov    0xc38,%eax
 7a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ab:	eb 24                	jmp    7d1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b5:	77 12                	ja     7c9 <free+0x35>
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 24                	ja     7e3 <free+0x4f>
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c7:	77 1a                	ja     7e3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d7:	76 d4                	jbe    7ad <free+0x19>
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e1:	76 ca                	jbe    7ad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	8b 40 04             	mov    0x4(%eax),%eax
 7e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	01 c2                	add    %eax,%edx
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	39 c2                	cmp    %eax,%edx
 7fc:	75 24                	jne    822 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 801:	8b 50 04             	mov    0x4(%eax),%edx
 804:	8b 45 fc             	mov    -0x4(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	8b 40 04             	mov    0x4(%eax),%eax
 80c:	01 c2                	add    %eax,%edx
 80e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 811:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	8b 45 fc             	mov    -0x4(%ebp),%eax
 817:	8b 00                	mov    (%eax),%eax
 819:	8b 10                	mov    (%eax),%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	89 10                	mov    %edx,(%eax)
 820:	eb 0a                	jmp    82c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 822:	8b 45 fc             	mov    -0x4(%ebp),%eax
 825:	8b 10                	mov    (%eax),%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 40 04             	mov    0x4(%eax),%eax
 832:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	01 d0                	add    %edx,%eax
 83e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 841:	75 20                	jne    863 <free+0xcf>
    p->s.size += bp->s.size;
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 50 04             	mov    0x4(%eax),%edx
 849:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84c:	8b 40 04             	mov    0x4(%eax),%eax
 84f:	01 c2                	add    %eax,%edx
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 857:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85a:	8b 10                	mov    (%eax),%edx
 85c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85f:	89 10                	mov    %edx,(%eax)
 861:	eb 08                	jmp    86b <free+0xd7>
  } else
    p->s.ptr = bp;
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	8b 55 f8             	mov    -0x8(%ebp),%edx
 869:	89 10                	mov    %edx,(%eax)
  freep = p;
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	a3 38 0c 00 00       	mov    %eax,0xc38
}
 873:	c9                   	leave  
 874:	c3                   	ret    

00000875 <morecore>:

static Header*
morecore(uint nu)
{
 875:	55                   	push   %ebp
 876:	89 e5                	mov    %esp,%ebp
 878:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 87b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 882:	77 07                	ja     88b <morecore+0x16>
    nu = 4096;
 884:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 88b:	8b 45 08             	mov    0x8(%ebp),%eax
 88e:	c1 e0 03             	shl    $0x3,%eax
 891:	89 04 24             	mov    %eax,(%esp)
 894:	e8 37 fb ff ff       	call   3d0 <sbrk>
 899:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 89c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a0:	75 07                	jne    8a9 <morecore+0x34>
    return 0;
 8a2:	b8 00 00 00 00       	mov    $0x0,%eax
 8a7:	eb 22                	jmp    8cb <morecore+0x56>
  hp = (Header*)p;
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b2:	8b 55 08             	mov    0x8(%ebp),%edx
 8b5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bb:	83 c0 08             	add    $0x8,%eax
 8be:	89 04 24             	mov    %eax,(%esp)
 8c1:	e8 ce fe ff ff       	call   794 <free>
  return freep;
 8c6:	a1 38 0c 00 00       	mov    0xc38,%eax
}
 8cb:	c9                   	leave  
 8cc:	c3                   	ret    

000008cd <malloc>:

void*
malloc(uint nbytes)
{
 8cd:	55                   	push   %ebp
 8ce:	89 e5                	mov    %esp,%ebp
 8d0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d3:	8b 45 08             	mov    0x8(%ebp),%eax
 8d6:	83 c0 07             	add    $0x7,%eax
 8d9:	c1 e8 03             	shr    $0x3,%eax
 8dc:	40                   	inc    %eax
 8dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e0:	a1 38 0c 00 00       	mov    0xc38,%eax
 8e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ec:	75 23                	jne    911 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8ee:	c7 45 f0 30 0c 00 00 	movl   $0xc30,-0x10(%ebp)
 8f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f8:	a3 38 0c 00 00       	mov    %eax,0xc38
 8fd:	a1 38 0c 00 00       	mov    0xc38,%eax
 902:	a3 30 0c 00 00       	mov    %eax,0xc30
    base.s.size = 0;
 907:	c7 05 34 0c 00 00 00 	movl   $0x0,0xc34
 90e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	8b 00                	mov    (%eax),%eax
 916:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	8b 40 04             	mov    0x4(%eax),%eax
 91f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 922:	72 4d                	jb     971 <malloc+0xa4>
      if(p->s.size == nunits)
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 40 04             	mov    0x4(%eax),%eax
 92a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 92d:	75 0c                	jne    93b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 92f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 932:	8b 10                	mov    (%eax),%edx
 934:	8b 45 f0             	mov    -0x10(%ebp),%eax
 937:	89 10                	mov    %edx,(%eax)
 939:	eb 26                	jmp    961 <malloc+0x94>
      else {
        p->s.size -= nunits;
 93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93e:	8b 40 04             	mov    0x4(%eax),%eax
 941:	2b 45 ec             	sub    -0x14(%ebp),%eax
 944:	89 c2                	mov    %eax,%edx
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 40 04             	mov    0x4(%eax),%eax
 952:	c1 e0 03             	shl    $0x3,%eax
 955:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 958:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 95e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	a3 38 0c 00 00       	mov    %eax,0xc38
      return (void*)(p + 1);
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	83 c0 08             	add    $0x8,%eax
 96f:	eb 38                	jmp    9a9 <malloc+0xdc>
    }
    if(p == freep)
 971:	a1 38 0c 00 00       	mov    0xc38,%eax
 976:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 979:	75 1b                	jne    996 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 97b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 97e:	89 04 24             	mov    %eax,(%esp)
 981:	e8 ef fe ff ff       	call   875 <morecore>
 986:	89 45 f4             	mov    %eax,-0xc(%ebp)
 989:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 98d:	75 07                	jne    996 <malloc+0xc9>
        return 0;
 98f:	b8 00 00 00 00       	mov    $0x0,%eax
 994:	eb 13                	jmp    9a9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	89 45 f0             	mov    %eax,-0x10(%ebp)
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 00                	mov    (%eax),%eax
 9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9a4:	e9 70 ff ff ff       	jmp    919 <malloc+0x4c>
}
 9a9:	c9                   	leave  
 9aa:	c3                   	ret    
