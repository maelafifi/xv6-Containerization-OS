
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
  39:	c7 44 24 04 f0 09 00 	movl   $0x9f0,0x4(%esp)
  40:	00 
  41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  48:	e8 dc 05 00 00       	call   629 <printf>
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

0000053c <get_cticks>:
SYSCALL(get_cticks)
 53c:	b8 38 00 00 00       	mov    $0x38,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <tick_reset2>:
SYSCALL(tick_reset2)
 544:	b8 39 00 00 00       	mov    $0x39,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	83 ec 18             	sub    $0x18,%esp
 552:	8b 45 0c             	mov    0xc(%ebp),%eax
 555:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 558:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 55f:	00 
 560:	8d 45 f4             	lea    -0xc(%ebp),%eax
 563:	89 44 24 04          	mov    %eax,0x4(%esp)
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	89 04 24             	mov    %eax,(%esp)
 56d:	e8 3a fe ff ff       	call   3ac <write>
}
 572:	c9                   	leave  
 573:	c3                   	ret    

00000574 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 574:	55                   	push   %ebp
 575:	89 e5                	mov    %esp,%ebp
 577:	56                   	push   %esi
 578:	53                   	push   %ebx
 579:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 57c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 583:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 587:	74 17                	je     5a0 <printint+0x2c>
 589:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 58d:	79 11                	jns    5a0 <printint+0x2c>
    neg = 1;
 58f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 596:	8b 45 0c             	mov    0xc(%ebp),%eax
 599:	f7 d8                	neg    %eax
 59b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59e:	eb 06                	jmp    5a6 <printint+0x32>
  } else {
    x = xx;
 5a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5ad:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5b0:	8d 41 01             	lea    0x1(%ecx),%eax
 5b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5bc:	ba 00 00 00 00       	mov    $0x0,%edx
 5c1:	f7 f3                	div    %ebx
 5c3:	89 d0                	mov    %edx,%eax
 5c5:	8a 80 94 0c 00 00    	mov    0xc94(%eax),%al
 5cb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5cf:	8b 75 10             	mov    0x10(%ebp),%esi
 5d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d5:	ba 00 00 00 00       	mov    $0x0,%edx
 5da:	f7 f6                	div    %esi
 5dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e3:	75 c8                	jne    5ad <printint+0x39>
  if(neg)
 5e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5e9:	74 10                	je     5fb <printint+0x87>
    buf[i++] = '-';
 5eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ee:	8d 50 01             	lea    0x1(%eax),%edx
 5f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5f4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5f9:	eb 1e                	jmp    619 <printint+0xa5>
 5fb:	eb 1c                	jmp    619 <printint+0xa5>
    putc(fd, buf[i]);
 5fd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 600:	8b 45 f4             	mov    -0xc(%ebp),%eax
 603:	01 d0                	add    %edx,%eax
 605:	8a 00                	mov    (%eax),%al
 607:	0f be c0             	movsbl %al,%eax
 60a:	89 44 24 04          	mov    %eax,0x4(%esp)
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	89 04 24             	mov    %eax,(%esp)
 614:	e8 33 ff ff ff       	call   54c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 619:	ff 4d f4             	decl   -0xc(%ebp)
 61c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 620:	79 db                	jns    5fd <printint+0x89>
    putc(fd, buf[i]);
}
 622:	83 c4 30             	add    $0x30,%esp
 625:	5b                   	pop    %ebx
 626:	5e                   	pop    %esi
 627:	5d                   	pop    %ebp
 628:	c3                   	ret    

00000629 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 629:	55                   	push   %ebp
 62a:	89 e5                	mov    %esp,%ebp
 62c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 62f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 636:	8d 45 0c             	lea    0xc(%ebp),%eax
 639:	83 c0 04             	add    $0x4,%eax
 63c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 63f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 646:	e9 77 01 00 00       	jmp    7c2 <printf+0x199>
    c = fmt[i] & 0xff;
 64b:	8b 55 0c             	mov    0xc(%ebp),%edx
 64e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 651:	01 d0                	add    %edx,%eax
 653:	8a 00                	mov    (%eax),%al
 655:	0f be c0             	movsbl %al,%eax
 658:	25 ff 00 00 00       	and    $0xff,%eax
 65d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 660:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 664:	75 2c                	jne    692 <printf+0x69>
      if(c == '%'){
 666:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 66a:	75 0c                	jne    678 <printf+0x4f>
        state = '%';
 66c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 673:	e9 47 01 00 00       	jmp    7bf <printf+0x196>
      } else {
        putc(fd, c);
 678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67b:	0f be c0             	movsbl %al,%eax
 67e:	89 44 24 04          	mov    %eax,0x4(%esp)
 682:	8b 45 08             	mov    0x8(%ebp),%eax
 685:	89 04 24             	mov    %eax,(%esp)
 688:	e8 bf fe ff ff       	call   54c <putc>
 68d:	e9 2d 01 00 00       	jmp    7bf <printf+0x196>
      }
    } else if(state == '%'){
 692:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 696:	0f 85 23 01 00 00    	jne    7bf <printf+0x196>
      if(c == 'd'){
 69c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6a0:	75 2d                	jne    6cf <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a5:	8b 00                	mov    (%eax),%eax
 6a7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6ae:	00 
 6af:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6b6:	00 
 6b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	89 04 24             	mov    %eax,(%esp)
 6c1:	e8 ae fe ff ff       	call   574 <printint>
        ap++;
 6c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ca:	e9 e9 00 00 00       	jmp    7b8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6cf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6d3:	74 06                	je     6db <printf+0xb2>
 6d5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6d9:	75 2d                	jne    708 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6de:	8b 00                	mov    (%eax),%eax
 6e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6e7:	00 
 6e8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ef:	00 
 6f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f4:	8b 45 08             	mov    0x8(%ebp),%eax
 6f7:	89 04 24             	mov    %eax,(%esp)
 6fa:	e8 75 fe ff ff       	call   574 <printint>
        ap++;
 6ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 703:	e9 b0 00 00 00       	jmp    7b8 <printf+0x18f>
      } else if(c == 's'){
 708:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 70c:	75 42                	jne    750 <printf+0x127>
        s = (char*)*ap;
 70e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 711:	8b 00                	mov    (%eax),%eax
 713:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 716:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 71a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 71e:	75 09                	jne    729 <printf+0x100>
          s = "(null)";
 720:	c7 45 f4 25 0a 00 00 	movl   $0xa25,-0xc(%ebp)
        while(*s != 0){
 727:	eb 1c                	jmp    745 <printf+0x11c>
 729:	eb 1a                	jmp    745 <printf+0x11c>
          putc(fd, *s);
 72b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72e:	8a 00                	mov    (%eax),%al
 730:	0f be c0             	movsbl %al,%eax
 733:	89 44 24 04          	mov    %eax,0x4(%esp)
 737:	8b 45 08             	mov    0x8(%ebp),%eax
 73a:	89 04 24             	mov    %eax,(%esp)
 73d:	e8 0a fe ff ff       	call   54c <putc>
          s++;
 742:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 745:	8b 45 f4             	mov    -0xc(%ebp),%eax
 748:	8a 00                	mov    (%eax),%al
 74a:	84 c0                	test   %al,%al
 74c:	75 dd                	jne    72b <printf+0x102>
 74e:	eb 68                	jmp    7b8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 750:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 754:	75 1d                	jne    773 <printf+0x14a>
        putc(fd, *ap);
 756:	8b 45 e8             	mov    -0x18(%ebp),%eax
 759:	8b 00                	mov    (%eax),%eax
 75b:	0f be c0             	movsbl %al,%eax
 75e:	89 44 24 04          	mov    %eax,0x4(%esp)
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	89 04 24             	mov    %eax,(%esp)
 768:	e8 df fd ff ff       	call   54c <putc>
        ap++;
 76d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 771:	eb 45                	jmp    7b8 <printf+0x18f>
      } else if(c == '%'){
 773:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 777:	75 17                	jne    790 <printf+0x167>
        putc(fd, c);
 779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77c:	0f be c0             	movsbl %al,%eax
 77f:	89 44 24 04          	mov    %eax,0x4(%esp)
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	89 04 24             	mov    %eax,(%esp)
 789:	e8 be fd ff ff       	call   54c <putc>
 78e:	eb 28                	jmp    7b8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 790:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 797:	00 
 798:	8b 45 08             	mov    0x8(%ebp),%eax
 79b:	89 04 24             	mov    %eax,(%esp)
 79e:	e8 a9 fd ff ff       	call   54c <putc>
        putc(fd, c);
 7a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a6:	0f be c0             	movsbl %al,%eax
 7a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ad:	8b 45 08             	mov    0x8(%ebp),%eax
 7b0:	89 04 24             	mov    %eax,(%esp)
 7b3:	e8 94 fd ff ff       	call   54c <putc>
      }
      state = 0;
 7b8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7bf:	ff 45 f0             	incl   -0x10(%ebp)
 7c2:	8b 55 0c             	mov    0xc(%ebp),%edx
 7c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c8:	01 d0                	add    %edx,%eax
 7ca:	8a 00                	mov    (%eax),%al
 7cc:	84 c0                	test   %al,%al
 7ce:	0f 85 77 fe ff ff    	jne    64b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7d4:	c9                   	leave  
 7d5:	c3                   	ret    
 7d6:	90                   	nop
 7d7:	90                   	nop

000007d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d8:	55                   	push   %ebp
 7d9:	89 e5                	mov    %esp,%ebp
 7db:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7de:	8b 45 08             	mov    0x8(%ebp),%eax
 7e1:	83 e8 08             	sub    $0x8,%eax
 7e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e7:	a1 b0 0c 00 00       	mov    0xcb0,%eax
 7ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ef:	eb 24                	jmp    815 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f9:	77 12                	ja     80d <free+0x35>
 7fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 801:	77 24                	ja     827 <free+0x4f>
 803:	8b 45 fc             	mov    -0x4(%ebp),%eax
 806:	8b 00                	mov    (%eax),%eax
 808:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80b:	77 1a                	ja     827 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	89 45 fc             	mov    %eax,-0x4(%ebp)
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 81b:	76 d4                	jbe    7f1 <free+0x19>
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 825:	76 ca                	jbe    7f1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	01 c2                	add    %eax,%edx
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	39 c2                	cmp    %eax,%edx
 840:	75 24                	jne    866 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 842:	8b 45 f8             	mov    -0x8(%ebp),%eax
 845:	8b 50 04             	mov    0x4(%eax),%edx
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	8b 00                	mov    (%eax),%eax
 84d:	8b 40 04             	mov    0x4(%eax),%eax
 850:	01 c2                	add    %eax,%edx
 852:	8b 45 f8             	mov    -0x8(%ebp),%eax
 855:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	8b 10                	mov    (%eax),%edx
 85f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 862:	89 10                	mov    %edx,(%eax)
 864:	eb 0a                	jmp    870 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 866:	8b 45 fc             	mov    -0x4(%ebp),%eax
 869:	8b 10                	mov    (%eax),%edx
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 870:	8b 45 fc             	mov    -0x4(%ebp),%eax
 873:	8b 40 04             	mov    0x4(%eax),%eax
 876:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	01 d0                	add    %edx,%eax
 882:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 885:	75 20                	jne    8a7 <free+0xcf>
    p->s.size += bp->s.size;
 887:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88a:	8b 50 04             	mov    0x4(%eax),%edx
 88d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 890:	8b 40 04             	mov    0x4(%eax),%eax
 893:	01 c2                	add    %eax,%edx
 895:	8b 45 fc             	mov    -0x4(%ebp),%eax
 898:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	8b 10                	mov    (%eax),%edx
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	89 10                	mov    %edx,(%eax)
 8a5:	eb 08                	jmp    8af <free+0xd7>
  } else
    p->s.ptr = bp;
 8a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8ad:	89 10                	mov    %edx,(%eax)
  freep = p;
 8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b2:	a3 b0 0c 00 00       	mov    %eax,0xcb0
}
 8b7:	c9                   	leave  
 8b8:	c3                   	ret    

000008b9 <morecore>:

static Header*
morecore(uint nu)
{
 8b9:	55                   	push   %ebp
 8ba:	89 e5                	mov    %esp,%ebp
 8bc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8bf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8c6:	77 07                	ja     8cf <morecore+0x16>
    nu = 4096;
 8c8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8cf:	8b 45 08             	mov    0x8(%ebp),%eax
 8d2:	c1 e0 03             	shl    $0x3,%eax
 8d5:	89 04 24             	mov    %eax,(%esp)
 8d8:	e8 37 fb ff ff       	call   414 <sbrk>
 8dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8e0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8e4:	75 07                	jne    8ed <morecore+0x34>
    return 0;
 8e6:	b8 00 00 00 00       	mov    $0x0,%eax
 8eb:	eb 22                	jmp    90f <morecore+0x56>
  hp = (Header*)p;
 8ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f6:	8b 55 08             	mov    0x8(%ebp),%edx
 8f9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ff:	83 c0 08             	add    $0x8,%eax
 902:	89 04 24             	mov    %eax,(%esp)
 905:	e8 ce fe ff ff       	call   7d8 <free>
  return freep;
 90a:	a1 b0 0c 00 00       	mov    0xcb0,%eax
}
 90f:	c9                   	leave  
 910:	c3                   	ret    

00000911 <malloc>:

void*
malloc(uint nbytes)
{
 911:	55                   	push   %ebp
 912:	89 e5                	mov    %esp,%ebp
 914:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 917:	8b 45 08             	mov    0x8(%ebp),%eax
 91a:	83 c0 07             	add    $0x7,%eax
 91d:	c1 e8 03             	shr    $0x3,%eax
 920:	40                   	inc    %eax
 921:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 924:	a1 b0 0c 00 00       	mov    0xcb0,%eax
 929:	89 45 f0             	mov    %eax,-0x10(%ebp)
 92c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 930:	75 23                	jne    955 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 932:	c7 45 f0 a8 0c 00 00 	movl   $0xca8,-0x10(%ebp)
 939:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93c:	a3 b0 0c 00 00       	mov    %eax,0xcb0
 941:	a1 b0 0c 00 00       	mov    0xcb0,%eax
 946:	a3 a8 0c 00 00       	mov    %eax,0xca8
    base.s.size = 0;
 94b:	c7 05 ac 0c 00 00 00 	movl   $0x0,0xcac
 952:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 955:	8b 45 f0             	mov    -0x10(%ebp),%eax
 958:	8b 00                	mov    (%eax),%eax
 95a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	8b 40 04             	mov    0x4(%eax),%eax
 963:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 966:	72 4d                	jb     9b5 <malloc+0xa4>
      if(p->s.size == nunits)
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8b 40 04             	mov    0x4(%eax),%eax
 96e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 971:	75 0c                	jne    97f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	8b 10                	mov    (%eax),%edx
 978:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97b:	89 10                	mov    %edx,(%eax)
 97d:	eb 26                	jmp    9a5 <malloc+0x94>
      else {
        p->s.size -= nunits;
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	8b 40 04             	mov    0x4(%eax),%eax
 985:	2b 45 ec             	sub    -0x14(%ebp),%eax
 988:	89 c2                	mov    %eax,%edx
 98a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 990:	8b 45 f4             	mov    -0xc(%ebp),%eax
 993:	8b 40 04             	mov    0x4(%eax),%eax
 996:	c1 e0 03             	shl    $0x3,%eax
 999:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9a2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a8:	a3 b0 0c 00 00       	mov    %eax,0xcb0
      return (void*)(p + 1);
 9ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b0:	83 c0 08             	add    $0x8,%eax
 9b3:	eb 38                	jmp    9ed <malloc+0xdc>
    }
    if(p == freep)
 9b5:	a1 b0 0c 00 00       	mov    0xcb0,%eax
 9ba:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9bd:	75 1b                	jne    9da <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9c2:	89 04 24             	mov    %eax,(%esp)
 9c5:	e8 ef fe ff ff       	call   8b9 <morecore>
 9ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d1:	75 07                	jne    9da <malloc+0xc9>
        return 0;
 9d3:	b8 00 00 00 00       	mov    $0x0,%eax
 9d8:	eb 13                	jmp    9ed <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 00                	mov    (%eax),%eax
 9e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9e8:	e9 70 ff ff ff       	jmp    95d <malloc+0x4c>
}
 9ed:	c9                   	leave  
 9ee:	c3                   	ret    
