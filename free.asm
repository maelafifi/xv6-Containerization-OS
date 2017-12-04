
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
  39:	c7 44 24 04 d0 09 00 	movl   $0x9d0,0x4(%esp)
  40:	00 
  41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  48:	e8 bc 05 00 00       	call   609 <printf>
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

0000052c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
 52f:	83 ec 18             	sub    $0x18,%esp
 532:	8b 45 0c             	mov    0xc(%ebp),%eax
 535:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 538:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 53f:	00 
 540:	8d 45 f4             	lea    -0xc(%ebp),%eax
 543:	89 44 24 04          	mov    %eax,0x4(%esp)
 547:	8b 45 08             	mov    0x8(%ebp),%eax
 54a:	89 04 24             	mov    %eax,(%esp)
 54d:	e8 5a fe ff ff       	call   3ac <write>
}
 552:	c9                   	leave  
 553:	c3                   	ret    

00000554 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 554:	55                   	push   %ebp
 555:	89 e5                	mov    %esp,%ebp
 557:	56                   	push   %esi
 558:	53                   	push   %ebx
 559:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 55c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 563:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 567:	74 17                	je     580 <printint+0x2c>
 569:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 56d:	79 11                	jns    580 <printint+0x2c>
    neg = 1;
 56f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	f7 d8                	neg    %eax
 57b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 57e:	eb 06                	jmp    586 <printint+0x32>
  } else {
    x = xx;
 580:	8b 45 0c             	mov    0xc(%ebp),%eax
 583:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 586:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 58d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 590:	8d 41 01             	lea    0x1(%ecx),%eax
 593:	89 45 f4             	mov    %eax,-0xc(%ebp)
 596:	8b 5d 10             	mov    0x10(%ebp),%ebx
 599:	8b 45 ec             	mov    -0x14(%ebp),%eax
 59c:	ba 00 00 00 00       	mov    $0x0,%edx
 5a1:	f7 f3                	div    %ebx
 5a3:	89 d0                	mov    %edx,%eax
 5a5:	8a 80 74 0c 00 00    	mov    0xc74(%eax),%al
 5ab:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5af:	8b 75 10             	mov    0x10(%ebp),%esi
 5b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b5:	ba 00 00 00 00       	mov    $0x0,%edx
 5ba:	f7 f6                	div    %esi
 5bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c3:	75 c8                	jne    58d <printint+0x39>
  if(neg)
 5c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c9:	74 10                	je     5db <printint+0x87>
    buf[i++] = '-';
 5cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ce:	8d 50 01             	lea    0x1(%eax),%edx
 5d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5d4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5d9:	eb 1e                	jmp    5f9 <printint+0xa5>
 5db:	eb 1c                	jmp    5f9 <printint+0xa5>
    putc(fd, buf[i]);
 5dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e3:	01 d0                	add    %edx,%eax
 5e5:	8a 00                	mov    (%eax),%al
 5e7:	0f be c0             	movsbl %al,%eax
 5ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ee:	8b 45 08             	mov    0x8(%ebp),%eax
 5f1:	89 04 24             	mov    %eax,(%esp)
 5f4:	e8 33 ff ff ff       	call   52c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f9:	ff 4d f4             	decl   -0xc(%ebp)
 5fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 600:	79 db                	jns    5dd <printint+0x89>
    putc(fd, buf[i]);
}
 602:	83 c4 30             	add    $0x30,%esp
 605:	5b                   	pop    %ebx
 606:	5e                   	pop    %esi
 607:	5d                   	pop    %ebp
 608:	c3                   	ret    

00000609 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 60f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 616:	8d 45 0c             	lea    0xc(%ebp),%eax
 619:	83 c0 04             	add    $0x4,%eax
 61c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 61f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 626:	e9 77 01 00 00       	jmp    7a2 <printf+0x199>
    c = fmt[i] & 0xff;
 62b:	8b 55 0c             	mov    0xc(%ebp),%edx
 62e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 631:	01 d0                	add    %edx,%eax
 633:	8a 00                	mov    (%eax),%al
 635:	0f be c0             	movsbl %al,%eax
 638:	25 ff 00 00 00       	and    $0xff,%eax
 63d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 640:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 644:	75 2c                	jne    672 <printf+0x69>
      if(c == '%'){
 646:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 64a:	75 0c                	jne    658 <printf+0x4f>
        state = '%';
 64c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 653:	e9 47 01 00 00       	jmp    79f <printf+0x196>
      } else {
        putc(fd, c);
 658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65b:	0f be c0             	movsbl %al,%eax
 65e:	89 44 24 04          	mov    %eax,0x4(%esp)
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	89 04 24             	mov    %eax,(%esp)
 668:	e8 bf fe ff ff       	call   52c <putc>
 66d:	e9 2d 01 00 00       	jmp    79f <printf+0x196>
      }
    } else if(state == '%'){
 672:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 676:	0f 85 23 01 00 00    	jne    79f <printf+0x196>
      if(c == 'd'){
 67c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 680:	75 2d                	jne    6af <printf+0xa6>
        printint(fd, *ap, 10, 1);
 682:	8b 45 e8             	mov    -0x18(%ebp),%eax
 685:	8b 00                	mov    (%eax),%eax
 687:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 68e:	00 
 68f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 696:	00 
 697:	89 44 24 04          	mov    %eax,0x4(%esp)
 69b:	8b 45 08             	mov    0x8(%ebp),%eax
 69e:	89 04 24             	mov    %eax,(%esp)
 6a1:	e8 ae fe ff ff       	call   554 <printint>
        ap++;
 6a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6aa:	e9 e9 00 00 00       	jmp    798 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6af:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b3:	74 06                	je     6bb <printf+0xb2>
 6b5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b9:	75 2d                	jne    6e8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6be:	8b 00                	mov    (%eax),%eax
 6c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6c7:	00 
 6c8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6cf:	00 
 6d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d4:	8b 45 08             	mov    0x8(%ebp),%eax
 6d7:	89 04 24             	mov    %eax,(%esp)
 6da:	e8 75 fe ff ff       	call   554 <printint>
        ap++;
 6df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e3:	e9 b0 00 00 00       	jmp    798 <printf+0x18f>
      } else if(c == 's'){
 6e8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6ec:	75 42                	jne    730 <printf+0x127>
        s = (char*)*ap;
 6ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f1:	8b 00                	mov    (%eax),%eax
 6f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fe:	75 09                	jne    709 <printf+0x100>
          s = "(null)";
 700:	c7 45 f4 05 0a 00 00 	movl   $0xa05,-0xc(%ebp)
        while(*s != 0){
 707:	eb 1c                	jmp    725 <printf+0x11c>
 709:	eb 1a                	jmp    725 <printf+0x11c>
          putc(fd, *s);
 70b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70e:	8a 00                	mov    (%eax),%al
 710:	0f be c0             	movsbl %al,%eax
 713:	89 44 24 04          	mov    %eax,0x4(%esp)
 717:	8b 45 08             	mov    0x8(%ebp),%eax
 71a:	89 04 24             	mov    %eax,(%esp)
 71d:	e8 0a fe ff ff       	call   52c <putc>
          s++;
 722:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 725:	8b 45 f4             	mov    -0xc(%ebp),%eax
 728:	8a 00                	mov    (%eax),%al
 72a:	84 c0                	test   %al,%al
 72c:	75 dd                	jne    70b <printf+0x102>
 72e:	eb 68                	jmp    798 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 730:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 734:	75 1d                	jne    753 <printf+0x14a>
        putc(fd, *ap);
 736:	8b 45 e8             	mov    -0x18(%ebp),%eax
 739:	8b 00                	mov    (%eax),%eax
 73b:	0f be c0             	movsbl %al,%eax
 73e:	89 44 24 04          	mov    %eax,0x4(%esp)
 742:	8b 45 08             	mov    0x8(%ebp),%eax
 745:	89 04 24             	mov    %eax,(%esp)
 748:	e8 df fd ff ff       	call   52c <putc>
        ap++;
 74d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 751:	eb 45                	jmp    798 <printf+0x18f>
      } else if(c == '%'){
 753:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 757:	75 17                	jne    770 <printf+0x167>
        putc(fd, c);
 759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75c:	0f be c0             	movsbl %al,%eax
 75f:	89 44 24 04          	mov    %eax,0x4(%esp)
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 be fd ff ff       	call   52c <putc>
 76e:	eb 28                	jmp    798 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 770:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 777:	00 
 778:	8b 45 08             	mov    0x8(%ebp),%eax
 77b:	89 04 24             	mov    %eax,(%esp)
 77e:	e8 a9 fd ff ff       	call   52c <putc>
        putc(fd, c);
 783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 786:	0f be c0             	movsbl %al,%eax
 789:	89 44 24 04          	mov    %eax,0x4(%esp)
 78d:	8b 45 08             	mov    0x8(%ebp),%eax
 790:	89 04 24             	mov    %eax,(%esp)
 793:	e8 94 fd ff ff       	call   52c <putc>
      }
      state = 0;
 798:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79f:	ff 45 f0             	incl   -0x10(%ebp)
 7a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a8:	01 d0                	add    %edx,%eax
 7aa:	8a 00                	mov    (%eax),%al
 7ac:	84 c0                	test   %al,%al
 7ae:	0f 85 77 fe ff ff    	jne    62b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b4:	c9                   	leave  
 7b5:	c3                   	ret    
 7b6:	90                   	nop
 7b7:	90                   	nop

000007b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b8:	55                   	push   %ebp
 7b9:	89 e5                	mov    %esp,%ebp
 7bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7be:	8b 45 08             	mov    0x8(%ebp),%eax
 7c1:	83 e8 08             	sub    $0x8,%eax
 7c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c7:	a1 90 0c 00 00       	mov    0xc90,%eax
 7cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cf:	eb 24                	jmp    7f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d9:	77 12                	ja     7ed <free+0x35>
 7db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e1:	77 24                	ja     807 <free+0x4f>
 7e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e6:	8b 00                	mov    (%eax),%eax
 7e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7eb:	77 1a                	ja     807 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f0:	8b 00                	mov    (%eax),%eax
 7f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7fb:	76 d4                	jbe    7d1 <free+0x19>
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 805:	76 ca                	jbe    7d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 814:	8b 45 f8             	mov    -0x8(%ebp),%eax
 817:	01 c2                	add    %eax,%edx
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	39 c2                	cmp    %eax,%edx
 820:	75 24                	jne    846 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 822:	8b 45 f8             	mov    -0x8(%ebp),%eax
 825:	8b 50 04             	mov    0x4(%eax),%edx
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 00                	mov    (%eax),%eax
 82d:	8b 40 04             	mov    0x4(%eax),%eax
 830:	01 c2                	add    %eax,%edx
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	8b 10                	mov    (%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	89 10                	mov    %edx,(%eax)
 844:	eb 0a                	jmp    850 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 10                	mov    (%eax),%edx
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 40 04             	mov    0x4(%eax),%eax
 856:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	01 d0                	add    %edx,%eax
 862:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 865:	75 20                	jne    887 <free+0xcf>
    p->s.size += bp->s.size;
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	8b 50 04             	mov    0x4(%eax),%edx
 86d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 870:	8b 40 04             	mov    0x4(%eax),%eax
 873:	01 c2                	add    %eax,%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	8b 10                	mov    (%eax),%edx
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	89 10                	mov    %edx,(%eax)
 885:	eb 08                	jmp    88f <free+0xd7>
  } else
    p->s.ptr = bp;
 887:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88d:	89 10                	mov    %edx,(%eax)
  freep = p;
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	a3 90 0c 00 00       	mov    %eax,0xc90
}
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <morecore>:

static Header*
morecore(uint nu)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a6:	77 07                	ja     8af <morecore+0x16>
    nu = 4096;
 8a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	c1 e0 03             	shl    $0x3,%eax
 8b5:	89 04 24             	mov    %eax,(%esp)
 8b8:	e8 57 fb ff ff       	call   414 <sbrk>
 8bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c4:	75 07                	jne    8cd <morecore+0x34>
    return 0;
 8c6:	b8 00 00 00 00       	mov    $0x0,%eax
 8cb:	eb 22                	jmp    8ef <morecore+0x56>
  hp = (Header*)p;
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d6:	8b 55 08             	mov    0x8(%ebp),%edx
 8d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8df:	83 c0 08             	add    $0x8,%eax
 8e2:	89 04 24             	mov    %eax,(%esp)
 8e5:	e8 ce fe ff ff       	call   7b8 <free>
  return freep;
 8ea:	a1 90 0c 00 00       	mov    0xc90,%eax
}
 8ef:	c9                   	leave  
 8f0:	c3                   	ret    

000008f1 <malloc>:

void*
malloc(uint nbytes)
{
 8f1:	55                   	push   %ebp
 8f2:	89 e5                	mov    %esp,%ebp
 8f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f7:	8b 45 08             	mov    0x8(%ebp),%eax
 8fa:	83 c0 07             	add    $0x7,%eax
 8fd:	c1 e8 03             	shr    $0x3,%eax
 900:	40                   	inc    %eax
 901:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 904:	a1 90 0c 00 00       	mov    0xc90,%eax
 909:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 910:	75 23                	jne    935 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 912:	c7 45 f0 88 0c 00 00 	movl   $0xc88,-0x10(%ebp)
 919:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91c:	a3 90 0c 00 00       	mov    %eax,0xc90
 921:	a1 90 0c 00 00       	mov    0xc90,%eax
 926:	a3 88 0c 00 00       	mov    %eax,0xc88
    base.s.size = 0;
 92b:	c7 05 8c 0c 00 00 00 	movl   $0x0,0xc8c
 932:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 935:	8b 45 f0             	mov    -0x10(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 946:	72 4d                	jb     995 <malloc+0xa4>
      if(p->s.size == nunits)
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	8b 40 04             	mov    0x4(%eax),%eax
 94e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 951:	75 0c                	jne    95f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 10                	mov    (%eax),%edx
 958:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95b:	89 10                	mov    %edx,(%eax)
 95d:	eb 26                	jmp    985 <malloc+0x94>
      else {
        p->s.size -= nunits;
 95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 962:	8b 40 04             	mov    0x4(%eax),%eax
 965:	2b 45 ec             	sub    -0x14(%ebp),%eax
 968:	89 c2                	mov    %eax,%edx
 96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 40 04             	mov    0x4(%eax),%eax
 976:	c1 e0 03             	shl    $0x3,%eax
 979:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 982:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 985:	8b 45 f0             	mov    -0x10(%ebp),%eax
 988:	a3 90 0c 00 00       	mov    %eax,0xc90
      return (void*)(p + 1);
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	83 c0 08             	add    $0x8,%eax
 993:	eb 38                	jmp    9cd <malloc+0xdc>
    }
    if(p == freep)
 995:	a1 90 0c 00 00       	mov    0xc90,%eax
 99a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99d:	75 1b                	jne    9ba <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 99f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a2:	89 04 24             	mov    %eax,(%esp)
 9a5:	e8 ef fe ff ff       	call   899 <morecore>
 9aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b1:	75 07                	jne    9ba <malloc+0xc9>
        return 0;
 9b3:	b8 00 00 00 00       	mov    $0x0,%eax
 9b8:	eb 13                	jmp    9cd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c3:	8b 00                	mov    (%eax),%eax
 9c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c8:	e9 70 ff ff ff       	jmp    93d <malloc+0x4c>
}
 9cd:	c9                   	leave  
 9ce:	c3                   	ret    
