
_free:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "container.h"

int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 30             	sub    $0x30,%esp
	int used = tmem();
   9:	e8 fe 04 00 00       	call   50c <tmem>
   e:	89 44 24 2c          	mov    %eax,0x2c(%esp)
	int avail = amem();
  12:	e8 fd 04 00 00       	call   514 <amem>
  17:	89 44 24 28          	mov    %eax,0x28(%esp)
	printf(1, "%d (%d used) available pages out of %d total pages.\n", avail-used, used, avail);
  1b:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  1f:	8b 54 24 28          	mov    0x28(%esp),%edx
  23:	29 c2                	sub    %eax,%edx
  25:	8b 44 24 28          	mov    0x28(%esp),%eax
  29:	89 44 24 10          	mov    %eax,0x10(%esp)
  2d:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  35:	89 54 24 08          	mov    %edx,0x8(%esp)
  39:	c7 44 24 04 e0 09 00 	movl   $0x9e0,0x4(%esp)
  40:	00 
  41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  48:	e8 cc 05 00 00       	call   619 <printf>
	exit();
  4d:	e8 3a 03 00 00       	call   38c <exit>
  52:	90                   	nop
  53:	90                   	nop

00000054 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  54:	55                   	push   %ebp
  55:	89 e5                	mov    %esp,%ebp
  57:	57                   	push   %edi
  58:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  5c:	8b 55 10             	mov    0x10(%ebp),%edx
  5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  62:	89 cb                	mov    %ecx,%ebx
  64:	89 df                	mov    %ebx,%edi
  66:	89 d1                	mov    %edx,%ecx
  68:	fc                   	cld    
  69:	f3 aa                	rep stos %al,%es:(%edi)
  6b:	89 ca                	mov    %ecx,%edx
  6d:	89 fb                	mov    %edi,%ebx
  6f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  72:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  75:	5b                   	pop    %ebx
  76:	5f                   	pop    %edi
  77:	5d                   	pop    %ebp
  78:	c3                   	ret    

00000079 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  7f:	8b 45 08             	mov    0x8(%ebp),%eax
  82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  85:	90                   	nop
  86:	8b 45 08             	mov    0x8(%ebp),%eax
  89:	8d 50 01             	lea    0x1(%eax),%edx
  8c:	89 55 08             	mov    %edx,0x8(%ebp)
  8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  92:	8d 4a 01             	lea    0x1(%edx),%ecx
  95:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  98:	8a 12                	mov    (%edx),%dl
  9a:	88 10                	mov    %dl,(%eax)
  9c:	8a 00                	mov    (%eax),%al
  9e:	84 c0                	test   %al,%al
  a0:	75 e4                	jne    86 <strcpy+0xd>
    ;
  return os;
  a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  a5:	c9                   	leave  
  a6:	c3                   	ret    

000000a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a7:	55                   	push   %ebp
  a8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  aa:	eb 06                	jmp    b2 <strcmp+0xb>
    p++, q++;
  ac:	ff 45 08             	incl   0x8(%ebp)
  af:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  b2:	8b 45 08             	mov    0x8(%ebp),%eax
  b5:	8a 00                	mov    (%eax),%al
  b7:	84 c0                	test   %al,%al
  b9:	74 0e                	je     c9 <strcmp+0x22>
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	8a 10                	mov    (%eax),%dl
  c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  c3:	8a 00                	mov    (%eax),%al
  c5:	38 c2                	cmp    %al,%dl
  c7:	74 e3                	je     ac <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  c9:	8b 45 08             	mov    0x8(%ebp),%eax
  cc:	8a 00                	mov    (%eax),%al
  ce:	0f b6 d0             	movzbl %al,%edx
  d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  d4:	8a 00                	mov    (%eax),%al
  d6:	0f b6 c0             	movzbl %al,%eax
  d9:	29 c2                	sub    %eax,%edx
  db:	89 d0                	mov    %edx,%eax
}
  dd:	5d                   	pop    %ebp
  de:	c3                   	ret    

000000df <strlen>:

uint
strlen(char *s)
{
  df:	55                   	push   %ebp
  e0:	89 e5                	mov    %esp,%ebp
  e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ec:	eb 03                	jmp    f1 <strlen+0x12>
  ee:	ff 45 fc             	incl   -0x4(%ebp)
  f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	01 d0                	add    %edx,%eax
  f9:	8a 00                	mov    (%eax),%al
  fb:	84 c0                	test   %al,%al
  fd:	75 ef                	jne    ee <strlen+0xf>
    ;
  return n;
  ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <memset>:

void*
memset(void *dst, int c, uint n)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 10a:	8b 45 10             	mov    0x10(%ebp),%eax
 10d:	89 44 24 08          	mov    %eax,0x8(%esp)
 111:	8b 45 0c             	mov    0xc(%ebp),%eax
 114:	89 44 24 04          	mov    %eax,0x4(%esp)
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	89 04 24             	mov    %eax,(%esp)
 11e:	e8 31 ff ff ff       	call   54 <stosb>
  return dst;
 123:	8b 45 08             	mov    0x8(%ebp),%eax
}
 126:	c9                   	leave  
 127:	c3                   	ret    

00000128 <strchr>:

char*
strchr(const char *s, char c)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 04             	sub    $0x4,%esp
 12e:	8b 45 0c             	mov    0xc(%ebp),%eax
 131:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 134:	eb 12                	jmp    148 <strchr+0x20>
    if(*s == c)
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	8a 00                	mov    (%eax),%al
 13b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 13e:	75 05                	jne    145 <strchr+0x1d>
      return (char*)s;
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	eb 11                	jmp    156 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 145:	ff 45 08             	incl   0x8(%ebp)
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	8a 00                	mov    (%eax),%al
 14d:	84 c0                	test   %al,%al
 14f:	75 e5                	jne    136 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 151:	b8 00 00 00 00       	mov    $0x0,%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <gets>:

char*
gets(char *buf, int max)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 165:	eb 49                	jmp    1b0 <gets+0x58>
    cc = read(0, &c, 1);
 167:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 16e:	00 
 16f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 172:	89 44 24 04          	mov    %eax,0x4(%esp)
 176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17d:	e8 22 02 00 00       	call   3a4 <read>
 182:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 185:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 189:	7f 02                	jg     18d <gets+0x35>
      break;
 18b:	eb 2c                	jmp    1b9 <gets+0x61>
    buf[i++] = c;
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	8d 50 01             	lea    0x1(%eax),%edx
 193:	89 55 f4             	mov    %edx,-0xc(%ebp)
 196:	89 c2                	mov    %eax,%edx
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	01 c2                	add    %eax,%edx
 19d:	8a 45 ef             	mov    -0x11(%ebp),%al
 1a0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a2:	8a 45 ef             	mov    -0x11(%ebp),%al
 1a5:	3c 0a                	cmp    $0xa,%al
 1a7:	74 10                	je     1b9 <gets+0x61>
 1a9:	8a 45 ef             	mov    -0x11(%ebp),%al
 1ac:	3c 0d                	cmp    $0xd,%al
 1ae:	74 09                	je     1b9 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b3:	40                   	inc    %eax
 1b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1b7:	7c ae                	jl     167 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	01 d0                	add    %edx,%eax
 1c1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c7:	c9                   	leave  
 1c8:	c3                   	ret    

000001c9 <stat>:

int
stat(char *n, struct stat *st)
{
 1c9:	55                   	push   %ebp
 1ca:	89 e5                	mov    %esp,%ebp
 1cc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1d6:	00 
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 ea 01 00 00       	call   3cc <open>
 1e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e9:	79 07                	jns    1f2 <stat+0x29>
    return -1;
 1eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f0:	eb 23                	jmp    215 <stat+0x4c>
  r = fstat(fd, st);
 1f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fc:	89 04 24             	mov    %eax,(%esp)
 1ff:	e8 e0 01 00 00       	call   3e4 <fstat>
 204:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 207:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20a:	89 04 24             	mov    %eax,(%esp)
 20d:	e8 a2 01 00 00       	call   3b4 <close>
  return r;
 212:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 215:	c9                   	leave  
 216:	c3                   	ret    

00000217 <atoi>:

int
atoi(const char *s)
{
 217:	55                   	push   %ebp
 218:	89 e5                	mov    %esp,%ebp
 21a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 21d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 224:	eb 24                	jmp    24a <atoi+0x33>
    n = n*10 + *s++ - '0';
 226:	8b 55 fc             	mov    -0x4(%ebp),%edx
 229:	89 d0                	mov    %edx,%eax
 22b:	c1 e0 02             	shl    $0x2,%eax
 22e:	01 d0                	add    %edx,%eax
 230:	01 c0                	add    %eax,%eax
 232:	89 c1                	mov    %eax,%ecx
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	8d 50 01             	lea    0x1(%eax),%edx
 23a:	89 55 08             	mov    %edx,0x8(%ebp)
 23d:	8a 00                	mov    (%eax),%al
 23f:	0f be c0             	movsbl %al,%eax
 242:	01 c8                	add    %ecx,%eax
 244:	83 e8 30             	sub    $0x30,%eax
 247:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	8a 00                	mov    (%eax),%al
 24f:	3c 2f                	cmp    $0x2f,%al
 251:	7e 09                	jle    25c <atoi+0x45>
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	8a 00                	mov    (%eax),%al
 258:	3c 39                	cmp    $0x39,%al
 25a:	7e ca                	jle    226 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 25f:	c9                   	leave  
 260:	c3                   	ret    

00000261 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 273:	eb 16                	jmp    28b <memmove+0x2a>
    *dst++ = *src++;
 275:	8b 45 fc             	mov    -0x4(%ebp),%eax
 278:	8d 50 01             	lea    0x1(%eax),%edx
 27b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 27e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 281:	8d 4a 01             	lea    0x1(%edx),%ecx
 284:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 287:	8a 12                	mov    (%edx),%dl
 289:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 28b:	8b 45 10             	mov    0x10(%ebp),%eax
 28e:	8d 50 ff             	lea    -0x1(%eax),%edx
 291:	89 55 10             	mov    %edx,0x10(%ebp)
 294:	85 c0                	test   %eax,%eax
 296:	7f dd                	jg     275 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 298:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29b:	c9                   	leave  
 29c:	c3                   	ret    

0000029d <itoa>:

int itoa(int value, char *sp, int radix)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	53                   	push   %ebx
 2a1:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2a4:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2aa:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 2ae:	75 0d                	jne    2bd <itoa+0x20>
 2b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2b4:	79 07                	jns    2bd <itoa+0x20>
 2b6:	b8 01 00 00 00       	mov    $0x1,%eax
 2bb:	eb 05                	jmp    2c2 <itoa+0x25>
 2bd:	b8 00 00 00 00       	mov    $0x0,%eax
 2c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 2c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2c9:	74 0a                	je     2d5 <itoa+0x38>
      v = -value;
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	f7 d8                	neg    %eax
 2d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 2d3:	eb 54                	jmp    329 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 2db:	eb 4c                	jmp    329 <itoa+0x8c>
  {
    i = v % radix;
 2dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e3:	ba 00 00 00 00       	mov    $0x0,%edx
 2e8:	f7 f1                	div    %ecx
 2ea:	89 d0                	mov    %edx,%eax
 2ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 2ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
 2f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f5:	ba 00 00 00 00       	mov    $0x0,%edx
 2fa:	f7 f3                	div    %ebx
 2fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 2ff:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 303:	7f 13                	jg     318 <itoa+0x7b>
      *tp++ = i+'0';
 305:	8b 45 f8             	mov    -0x8(%ebp),%eax
 308:	8d 50 01             	lea    0x1(%eax),%edx
 30b:	89 55 f8             	mov    %edx,-0x8(%ebp)
 30e:	8b 55 e8             	mov    -0x18(%ebp),%edx
 311:	83 c2 30             	add    $0x30,%edx
 314:	88 10                	mov    %dl,(%eax)
 316:	eb 11                	jmp    329 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 318:	8b 45 f8             	mov    -0x8(%ebp),%eax
 31b:	8d 50 01             	lea    0x1(%eax),%edx
 31e:	89 55 f8             	mov    %edx,-0x8(%ebp)
 321:	8b 55 e8             	mov    -0x18(%ebp),%edx
 324:	83 c2 57             	add    $0x57,%edx
 327:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 32d:	75 ae                	jne    2dd <itoa+0x40>
 32f:	8d 45 d8             	lea    -0x28(%ebp),%eax
 332:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 335:	74 a6                	je     2dd <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 337:	8b 55 f8             	mov    -0x8(%ebp),%edx
 33a:	8d 45 d8             	lea    -0x28(%ebp),%eax
 33d:	29 c2                	sub    %eax,%edx
 33f:	89 d0                	mov    %edx,%eax
 341:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 344:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 348:	74 11                	je     35b <itoa+0xbe>
  {
    *sp++ = '-';
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	8d 50 01             	lea    0x1(%eax),%edx
 350:	89 55 0c             	mov    %edx,0xc(%ebp)
 353:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 356:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 359:	eb 15                	jmp    370 <itoa+0xd3>
 35b:	eb 13                	jmp    370 <itoa+0xd3>
    *sp++ = *--tp;
 35d:	8b 45 0c             	mov    0xc(%ebp),%eax
 360:	8d 50 01             	lea    0x1(%eax),%edx
 363:	89 55 0c             	mov    %edx,0xc(%ebp)
 366:	ff 4d f8             	decl   -0x8(%ebp)
 369:	8b 55 f8             	mov    -0x8(%ebp),%edx
 36c:	8a 12                	mov    (%edx),%dl
 36e:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 370:	8d 45 d8             	lea    -0x28(%ebp),%eax
 373:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 376:	77 e5                	ja     35d <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 378:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37b:	83 c4 30             	add    $0x30,%esp
 37e:	5b                   	pop    %ebx
 37f:	5d                   	pop    %ebp
 380:	c3                   	ret    
 381:	90                   	nop
 382:	90                   	nop
 383:	90                   	nop

00000384 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 384:	b8 01 00 00 00       	mov    $0x1,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <exit>:
SYSCALL(exit)
 38c:	b8 02 00 00 00       	mov    $0x2,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <wait>:
SYSCALL(wait)
 394:	b8 03 00 00 00       	mov    $0x3,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <pipe>:
SYSCALL(pipe)
 39c:	b8 04 00 00 00       	mov    $0x4,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <read>:
SYSCALL(read)
 3a4:	b8 05 00 00 00       	mov    $0x5,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <write>:
SYSCALL(write)
 3ac:	b8 10 00 00 00       	mov    $0x10,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <close>:
SYSCALL(close)
 3b4:	b8 15 00 00 00       	mov    $0x15,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <kill>:
SYSCALL(kill)
 3bc:	b8 06 00 00 00       	mov    $0x6,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <exec>:
SYSCALL(exec)
 3c4:	b8 07 00 00 00       	mov    $0x7,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <open>:
SYSCALL(open)
 3cc:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <mknod>:
SYSCALL(mknod)
 3d4:	b8 11 00 00 00       	mov    $0x11,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <unlink>:
SYSCALL(unlink)
 3dc:	b8 12 00 00 00       	mov    $0x12,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <fstat>:
SYSCALL(fstat)
 3e4:	b8 08 00 00 00       	mov    $0x8,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <link>:
SYSCALL(link)
 3ec:	b8 13 00 00 00       	mov    $0x13,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <mkdir>:
SYSCALL(mkdir)
 3f4:	b8 14 00 00 00       	mov    $0x14,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <chdir>:
SYSCALL(chdir)
 3fc:	b8 09 00 00 00       	mov    $0x9,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <dup>:
SYSCALL(dup)
 404:	b8 0a 00 00 00       	mov    $0xa,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <getpid>:
SYSCALL(getpid)
 40c:	b8 0b 00 00 00       	mov    $0xb,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <sbrk>:
SYSCALL(sbrk)
 414:	b8 0c 00 00 00       	mov    $0xc,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <sleep>:
SYSCALL(sleep)
 41c:	b8 0d 00 00 00       	mov    $0xd,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <uptime>:
SYSCALL(uptime)
 424:	b8 0e 00 00 00       	mov    $0xe,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <getticks>:
SYSCALL(getticks)
 42c:	b8 16 00 00 00       	mov    $0x16,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <get_name>:
SYSCALL(get_name)
 434:	b8 17 00 00 00       	mov    $0x17,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <get_max_proc>:
SYSCALL(get_max_proc)
 43c:	b8 18 00 00 00       	mov    $0x18,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <get_max_mem>:
SYSCALL(get_max_mem)
 444:	b8 19 00 00 00       	mov    $0x19,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <get_max_disk>:
SYSCALL(get_max_disk)
 44c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <get_curr_proc>:
SYSCALL(get_curr_proc)
 454:	b8 1b 00 00 00       	mov    $0x1b,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <get_curr_mem>:
SYSCALL(get_curr_mem)
 45c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <get_curr_disk>:
SYSCALL(get_curr_disk)
 464:	b8 1d 00 00 00       	mov    $0x1d,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <set_name>:
SYSCALL(set_name)
 46c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <set_max_mem>:
SYSCALL(set_max_mem)
 474:	b8 1f 00 00 00       	mov    $0x1f,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <set_max_disk>:
SYSCALL(set_max_disk)
 47c:	b8 20 00 00 00       	mov    $0x20,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <set_max_proc>:
SYSCALL(set_max_proc)
 484:	b8 21 00 00 00       	mov    $0x21,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <set_curr_mem>:
SYSCALL(set_curr_mem)
 48c:	b8 22 00 00 00       	mov    $0x22,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <set_curr_disk>:
SYSCALL(set_curr_disk)
 494:	b8 23 00 00 00       	mov    $0x23,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <set_curr_proc>:
SYSCALL(set_curr_proc)
 49c:	b8 24 00 00 00       	mov    $0x24,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <find>:
SYSCALL(find)
 4a4:	b8 25 00 00 00       	mov    $0x25,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <is_full>:
SYSCALL(is_full)
 4ac:	b8 26 00 00 00       	mov    $0x26,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <container_init>:
SYSCALL(container_init)
 4b4:	b8 27 00 00 00       	mov    $0x27,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <cont_proc_set>:
SYSCALL(cont_proc_set)
 4bc:	b8 28 00 00 00       	mov    $0x28,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <ps>:
SYSCALL(ps)
 4c4:	b8 29 00 00 00       	mov    $0x29,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 4cc:	b8 2a 00 00 00       	mov    $0x2a,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <set_root_inode>:
SYSCALL(set_root_inode)
 4d4:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <cstop>:
SYSCALL(cstop)
 4dc:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <df>:
SYSCALL(df)
 4e4:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <max_containers>:
SYSCALL(max_containers)
 4ec:	b8 2e 00 00 00       	mov    $0x2e,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <container_reset>:
SYSCALL(container_reset)
 4f4:	b8 2f 00 00 00       	mov    $0x2f,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <pause>:
SYSCALL(pause)
 4fc:	b8 30 00 00 00       	mov    $0x30,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <resume>:
SYSCALL(resume)
 504:	b8 31 00 00 00       	mov    $0x31,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <tmem>:
SYSCALL(tmem)
 50c:	b8 32 00 00 00       	mov    $0x32,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <amem>:
SYSCALL(amem)
 514:	b8 33 00 00 00       	mov    $0x33,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <c_ps>:
SYSCALL(c_ps)
 51c:	b8 34 00 00 00       	mov    $0x34,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <get_used>:
SYSCALL(get_used)
 524:	b8 35 00 00 00       	mov    $0x35,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <get_os>:
SYSCALL(get_os)
 52c:	b8 36 00 00 00       	mov    $0x36,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <set_os>:
SYSCALL(set_os)
 534:	b8 37 00 00 00       	mov    $0x37,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 53c:	55                   	push   %ebp
 53d:	89 e5                	mov    %esp,%ebp
 53f:	83 ec 18             	sub    $0x18,%esp
 542:	8b 45 0c             	mov    0xc(%ebp),%eax
 545:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 548:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 54f:	00 
 550:	8d 45 f4             	lea    -0xc(%ebp),%eax
 553:	89 44 24 04          	mov    %eax,0x4(%esp)
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	89 04 24             	mov    %eax,(%esp)
 55d:	e8 4a fe ff ff       	call   3ac <write>
}
 562:	c9                   	leave  
 563:	c3                   	ret    

00000564 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	56                   	push   %esi
 568:	53                   	push   %ebx
 569:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 56c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 573:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 577:	74 17                	je     590 <printint+0x2c>
 579:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 57d:	79 11                	jns    590 <printint+0x2c>
    neg = 1;
 57f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 586:	8b 45 0c             	mov    0xc(%ebp),%eax
 589:	f7 d8                	neg    %eax
 58b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 58e:	eb 06                	jmp    596 <printint+0x32>
  } else {
    x = xx;
 590:	8b 45 0c             	mov    0xc(%ebp),%eax
 593:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 596:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 59d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5a0:	8d 41 01             	lea    0x1(%ecx),%eax
 5a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ac:	ba 00 00 00 00       	mov    $0x0,%edx
 5b1:	f7 f3                	div    %ebx
 5b3:	89 d0                	mov    %edx,%eax
 5b5:	8a 80 84 0c 00 00    	mov    0xc84(%eax),%al
 5bb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5bf:	8b 75 10             	mov    0x10(%ebp),%esi
 5c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c5:	ba 00 00 00 00       	mov    $0x0,%edx
 5ca:	f7 f6                	div    %esi
 5cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d3:	75 c8                	jne    59d <printint+0x39>
  if(neg)
 5d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d9:	74 10                	je     5eb <printint+0x87>
    buf[i++] = '-';
 5db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5de:	8d 50 01             	lea    0x1(%eax),%edx
 5e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5e4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5e9:	eb 1e                	jmp    609 <printint+0xa5>
 5eb:	eb 1c                	jmp    609 <printint+0xa5>
    putc(fd, buf[i]);
 5ed:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f3:	01 d0                	add    %edx,%eax
 5f5:	8a 00                	mov    (%eax),%al
 5f7:	0f be c0             	movsbl %al,%eax
 5fa:	89 44 24 04          	mov    %eax,0x4(%esp)
 5fe:	8b 45 08             	mov    0x8(%ebp),%eax
 601:	89 04 24             	mov    %eax,(%esp)
 604:	e8 33 ff ff ff       	call   53c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 609:	ff 4d f4             	decl   -0xc(%ebp)
 60c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 610:	79 db                	jns    5ed <printint+0x89>
    putc(fd, buf[i]);
}
 612:	83 c4 30             	add    $0x30,%esp
 615:	5b                   	pop    %ebx
 616:	5e                   	pop    %esi
 617:	5d                   	pop    %ebp
 618:	c3                   	ret    

00000619 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 619:	55                   	push   %ebp
 61a:	89 e5                	mov    %esp,%ebp
 61c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 61f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 626:	8d 45 0c             	lea    0xc(%ebp),%eax
 629:	83 c0 04             	add    $0x4,%eax
 62c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 62f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 636:	e9 77 01 00 00       	jmp    7b2 <printf+0x199>
    c = fmt[i] & 0xff;
 63b:	8b 55 0c             	mov    0xc(%ebp),%edx
 63e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 641:	01 d0                	add    %edx,%eax
 643:	8a 00                	mov    (%eax),%al
 645:	0f be c0             	movsbl %al,%eax
 648:	25 ff 00 00 00       	and    $0xff,%eax
 64d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 650:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 654:	75 2c                	jne    682 <printf+0x69>
      if(c == '%'){
 656:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65a:	75 0c                	jne    668 <printf+0x4f>
        state = '%';
 65c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 663:	e9 47 01 00 00       	jmp    7af <printf+0x196>
      } else {
        putc(fd, c);
 668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66b:	0f be c0             	movsbl %al,%eax
 66e:	89 44 24 04          	mov    %eax,0x4(%esp)
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	89 04 24             	mov    %eax,(%esp)
 678:	e8 bf fe ff ff       	call   53c <putc>
 67d:	e9 2d 01 00 00       	jmp    7af <printf+0x196>
      }
    } else if(state == '%'){
 682:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 686:	0f 85 23 01 00 00    	jne    7af <printf+0x196>
      if(c == 'd'){
 68c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 690:	75 2d                	jne    6bf <printf+0xa6>
        printint(fd, *ap, 10, 1);
 692:	8b 45 e8             	mov    -0x18(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 69e:	00 
 69f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6a6:	00 
 6a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 ae fe ff ff       	call   564 <printint>
        ap++;
 6b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ba:	e9 e9 00 00 00       	jmp    7a8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6bf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6c3:	74 06                	je     6cb <printf+0xb2>
 6c5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c9:	75 2d                	jne    6f8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6d7:	00 
 6d8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6df:	00 
 6e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	89 04 24             	mov    %eax,(%esp)
 6ea:	e8 75 fe ff ff       	call   564 <printint>
        ap++;
 6ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f3:	e9 b0 00 00 00       	jmp    7a8 <printf+0x18f>
      } else if(c == 's'){
 6f8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6fc:	75 42                	jne    740 <printf+0x127>
        s = (char*)*ap;
 6fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 701:	8b 00                	mov    (%eax),%eax
 703:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 706:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 70a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 70e:	75 09                	jne    719 <printf+0x100>
          s = "(null)";
 710:	c7 45 f4 15 0a 00 00 	movl   $0xa15,-0xc(%ebp)
        while(*s != 0){
 717:	eb 1c                	jmp    735 <printf+0x11c>
 719:	eb 1a                	jmp    735 <printf+0x11c>
          putc(fd, *s);
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	8a 00                	mov    (%eax),%al
 720:	0f be c0             	movsbl %al,%eax
 723:	89 44 24 04          	mov    %eax,0x4(%esp)
 727:	8b 45 08             	mov    0x8(%ebp),%eax
 72a:	89 04 24             	mov    %eax,(%esp)
 72d:	e8 0a fe ff ff       	call   53c <putc>
          s++;
 732:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 735:	8b 45 f4             	mov    -0xc(%ebp),%eax
 738:	8a 00                	mov    (%eax),%al
 73a:	84 c0                	test   %al,%al
 73c:	75 dd                	jne    71b <printf+0x102>
 73e:	eb 68                	jmp    7a8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 740:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 744:	75 1d                	jne    763 <printf+0x14a>
        putc(fd, *ap);
 746:	8b 45 e8             	mov    -0x18(%ebp),%eax
 749:	8b 00                	mov    (%eax),%eax
 74b:	0f be c0             	movsbl %al,%eax
 74e:	89 44 24 04          	mov    %eax,0x4(%esp)
 752:	8b 45 08             	mov    0x8(%ebp),%eax
 755:	89 04 24             	mov    %eax,(%esp)
 758:	e8 df fd ff ff       	call   53c <putc>
        ap++;
 75d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 761:	eb 45                	jmp    7a8 <printf+0x18f>
      } else if(c == '%'){
 763:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 767:	75 17                	jne    780 <printf+0x167>
        putc(fd, c);
 769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76c:	0f be c0             	movsbl %al,%eax
 76f:	89 44 24 04          	mov    %eax,0x4(%esp)
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 04 24             	mov    %eax,(%esp)
 779:	e8 be fd ff ff       	call   53c <putc>
 77e:	eb 28                	jmp    7a8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 780:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 787:	00 
 788:	8b 45 08             	mov    0x8(%ebp),%eax
 78b:	89 04 24             	mov    %eax,(%esp)
 78e:	e8 a9 fd ff ff       	call   53c <putc>
        putc(fd, c);
 793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	89 44 24 04          	mov    %eax,0x4(%esp)
 79d:	8b 45 08             	mov    0x8(%ebp),%eax
 7a0:	89 04 24             	mov    %eax,(%esp)
 7a3:	e8 94 fd ff ff       	call   53c <putc>
      }
      state = 0;
 7a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7af:	ff 45 f0             	incl   -0x10(%ebp)
 7b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b8:	01 d0                	add    %edx,%eax
 7ba:	8a 00                	mov    (%eax),%al
 7bc:	84 c0                	test   %al,%al
 7be:	0f 85 77 fe ff ff    	jne    63b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7c4:	c9                   	leave  
 7c5:	c3                   	ret    
 7c6:	90                   	nop
 7c7:	90                   	nop

000007c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c8:	55                   	push   %ebp
 7c9:	89 e5                	mov    %esp,%ebp
 7cb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ce:	8b 45 08             	mov    0x8(%ebp),%eax
 7d1:	83 e8 08             	sub    $0x8,%eax
 7d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d7:	a1 a0 0c 00 00       	mov    0xca0,%eax
 7dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7df:	eb 24                	jmp    805 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e9:	77 12                	ja     7fd <free+0x35>
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f1:	77 24                	ja     817 <free+0x4f>
 7f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7fb:	77 1a                	ja     817 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	89 45 fc             	mov    %eax,-0x4(%ebp)
 805:	8b 45 f8             	mov    -0x8(%ebp),%eax
 808:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 80b:	76 d4                	jbe    7e1 <free+0x19>
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 815:	76 ca                	jbe    7e1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	8b 40 04             	mov    0x4(%eax),%eax
 81d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 824:	8b 45 f8             	mov    -0x8(%ebp),%eax
 827:	01 c2                	add    %eax,%edx
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	8b 00                	mov    (%eax),%eax
 82e:	39 c2                	cmp    %eax,%edx
 830:	75 24                	jne    856 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	8b 50 04             	mov    0x4(%eax),%edx
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	8b 40 04             	mov    0x4(%eax),%eax
 840:	01 c2                	add    %eax,%edx
 842:	8b 45 f8             	mov    -0x8(%ebp),%eax
 845:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	8b 00                	mov    (%eax),%eax
 84d:	8b 10                	mov    (%eax),%edx
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	89 10                	mov    %edx,(%eax)
 854:	eb 0a                	jmp    860 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 856:	8b 45 fc             	mov    -0x4(%ebp),%eax
 859:	8b 10                	mov    (%eax),%edx
 85b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 86d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 870:	01 d0                	add    %edx,%eax
 872:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 875:	75 20                	jne    897 <free+0xcf>
    p->s.size += bp->s.size;
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	8b 50 04             	mov    0x4(%eax),%edx
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	8b 40 04             	mov    0x4(%eax),%eax
 883:	01 c2                	add    %eax,%edx
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 88b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88e:	8b 10                	mov    (%eax),%edx
 890:	8b 45 fc             	mov    -0x4(%ebp),%eax
 893:	89 10                	mov    %edx,(%eax)
 895:	eb 08                	jmp    89f <free+0xd7>
  } else
    p->s.ptr = bp;
 897:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 89d:	89 10                	mov    %edx,(%eax)
  freep = p;
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	a3 a0 0c 00 00       	mov    %eax,0xca0
}
 8a7:	c9                   	leave  
 8a8:	c3                   	ret    

000008a9 <morecore>:

static Header*
morecore(uint nu)
{
 8a9:	55                   	push   %ebp
 8aa:	89 e5                	mov    %esp,%ebp
 8ac:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8af:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8b6:	77 07                	ja     8bf <morecore+0x16>
    nu = 4096;
 8b8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8bf:	8b 45 08             	mov    0x8(%ebp),%eax
 8c2:	c1 e0 03             	shl    $0x3,%eax
 8c5:	89 04 24             	mov    %eax,(%esp)
 8c8:	e8 47 fb ff ff       	call   414 <sbrk>
 8cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8d4:	75 07                	jne    8dd <morecore+0x34>
    return 0;
 8d6:	b8 00 00 00 00       	mov    $0x0,%eax
 8db:	eb 22                	jmp    8ff <morecore+0x56>
  hp = (Header*)p;
 8dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e6:	8b 55 08             	mov    0x8(%ebp),%edx
 8e9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ef:	83 c0 08             	add    $0x8,%eax
 8f2:	89 04 24             	mov    %eax,(%esp)
 8f5:	e8 ce fe ff ff       	call   7c8 <free>
  return freep;
 8fa:	a1 a0 0c 00 00       	mov    0xca0,%eax
}
 8ff:	c9                   	leave  
 900:	c3                   	ret    

00000901 <malloc>:

void*
malloc(uint nbytes)
{
 901:	55                   	push   %ebp
 902:	89 e5                	mov    %esp,%ebp
 904:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 907:	8b 45 08             	mov    0x8(%ebp),%eax
 90a:	83 c0 07             	add    $0x7,%eax
 90d:	c1 e8 03             	shr    $0x3,%eax
 910:	40                   	inc    %eax
 911:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 914:	a1 a0 0c 00 00       	mov    0xca0,%eax
 919:	89 45 f0             	mov    %eax,-0x10(%ebp)
 91c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 920:	75 23                	jne    945 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 922:	c7 45 f0 98 0c 00 00 	movl   $0xc98,-0x10(%ebp)
 929:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92c:	a3 a0 0c 00 00       	mov    %eax,0xca0
 931:	a1 a0 0c 00 00       	mov    0xca0,%eax
 936:	a3 98 0c 00 00       	mov    %eax,0xc98
    base.s.size = 0;
 93b:	c7 05 9c 0c 00 00 00 	movl   $0x0,0xc9c
 942:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 945:	8b 45 f0             	mov    -0x10(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 94d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 950:	8b 40 04             	mov    0x4(%eax),%eax
 953:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 956:	72 4d                	jb     9a5 <malloc+0xa4>
      if(p->s.size == nunits)
 958:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95b:	8b 40 04             	mov    0x4(%eax),%eax
 95e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 961:	75 0c                	jne    96f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 963:	8b 45 f4             	mov    -0xc(%ebp),%eax
 966:	8b 10                	mov    (%eax),%edx
 968:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96b:	89 10                	mov    %edx,(%eax)
 96d:	eb 26                	jmp    995 <malloc+0x94>
      else {
        p->s.size -= nunits;
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	8b 40 04             	mov    0x4(%eax),%eax
 975:	2b 45 ec             	sub    -0x14(%ebp),%eax
 978:	89 c2                	mov    %eax,%edx
 97a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 980:	8b 45 f4             	mov    -0xc(%ebp),%eax
 983:	8b 40 04             	mov    0x4(%eax),%eax
 986:	c1 e0 03             	shl    $0x3,%eax
 989:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 992:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 995:	8b 45 f0             	mov    -0x10(%ebp),%eax
 998:	a3 a0 0c 00 00       	mov    %eax,0xca0
      return (void*)(p + 1);
 99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a0:	83 c0 08             	add    $0x8,%eax
 9a3:	eb 38                	jmp    9dd <malloc+0xdc>
    }
    if(p == freep)
 9a5:	a1 a0 0c 00 00       	mov    0xca0,%eax
 9aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9ad:	75 1b                	jne    9ca <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9b2:	89 04 24             	mov    %eax,(%esp)
 9b5:	e8 ef fe ff ff       	call   8a9 <morecore>
 9ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9c1:	75 07                	jne    9ca <malloc+0xc9>
        return 0;
 9c3:	b8 00 00 00 00       	mov    $0x0,%eax
 9c8:	eb 13                	jmp    9dd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 00                	mov    (%eax),%eax
 9d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9d8:	e9 70 ff ff ff       	jmp    94d <malloc+0x4c>
}
 9dd:	c9                   	leave  
 9de:	c3                   	ret    
