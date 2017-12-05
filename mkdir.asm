
_mkdir:     file format elf32-i386


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

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "Usage: mkdir files...\n");
   f:	c7 44 24 04 1b 0a 00 	movl   $0xa1b,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 32 06 00 00       	call   655 <printf>
    exit();
  23:	e8 a0 03 00 00       	call   3c8 <exit>
  }

  for(i = 1; i < argc; i++){
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 4e                	jmp    80 <main+0x80>
    if(mkdir(argv[i]) < 0){
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 e4 03 00 00       	call   430 <mkdir>
  4c:	85 c0                	test   %eax,%eax
  4e:	79 2c                	jns    7c <main+0x7c>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  50:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  5e:	01 d0                	add    %edx,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	89 44 24 08          	mov    %eax,0x8(%esp)
  66:	c7 44 24 04 32 0a 00 	movl   $0xa32,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  75:	e8 db 05 00 00       	call   655 <printf>
      break;
  7a:	eb 0d                	jmp    89 <main+0x89>
  if(argc < 2){
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  7c:	ff 44 24 1c          	incl   0x1c(%esp)
  80:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  84:	3b 45 08             	cmp    0x8(%ebp),%eax
  87:	7c a9                	jl     32 <main+0x32>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit();
  89:	e8 3a 03 00 00       	call   3c8 <exit>
  8e:	90                   	nop
  8f:	90                   	nop

00000090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  98:	8b 55 10             	mov    0x10(%ebp),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	89 cb                	mov    %ecx,%ebx
  a0:	89 df                	mov    %ebx,%edi
  a2:	89 d1                	mov    %edx,%ecx
  a4:	fc                   	cld    
  a5:	f3 aa                	rep stos %al,%es:(%edi)
  a7:	89 ca                	mov    %ecx,%edx
  a9:	89 fb                	mov    %edi,%ebx
  ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b1:	5b                   	pop    %ebx
  b2:	5f                   	pop    %edi
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c1:	90                   	nop
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	8d 50 01             	lea    0x1(%eax),%edx
  c8:	89 55 08             	mov    %edx,0x8(%ebp)
  cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  d1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d4:	8a 12                	mov    (%edx),%dl
  d6:	88 10                	mov    %dl,(%eax)
  d8:	8a 00                	mov    (%eax),%al
  da:	84 c0                	test   %al,%al
  dc:	75 e4                	jne    c2 <strcpy+0xd>
    ;
  return os;
  de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e6:	eb 06                	jmp    ee <strcmp+0xb>
    p++, q++;
  e8:	ff 45 08             	incl   0x8(%ebp)
  eb:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	8a 00                	mov    (%eax),%al
  f3:	84 c0                	test   %al,%al
  f5:	74 0e                	je     105 <strcmp+0x22>
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	8a 10                	mov    (%eax),%dl
  fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  ff:	8a 00                	mov    (%eax),%al
 101:	38 c2                	cmp    %al,%dl
 103:	74 e3                	je     e8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 105:	8b 45 08             	mov    0x8(%ebp),%eax
 108:	8a 00                	mov    (%eax),%al
 10a:	0f b6 d0             	movzbl %al,%edx
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	8a 00                	mov    (%eax),%al
 112:	0f b6 c0             	movzbl %al,%eax
 115:	29 c2                	sub    %eax,%edx
 117:	89 d0                	mov    %edx,%eax
}
 119:	5d                   	pop    %ebp
 11a:	c3                   	ret    

0000011b <strlen>:

uint
strlen(char *s)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
 11e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 121:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 128:	eb 03                	jmp    12d <strlen+0x12>
 12a:	ff 45 fc             	incl   -0x4(%ebp)
 12d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 130:	8b 45 08             	mov    0x8(%ebp),%eax
 133:	01 d0                	add    %edx,%eax
 135:	8a 00                	mov    (%eax),%al
 137:	84 c0                	test   %al,%al
 139:	75 ef                	jne    12a <strlen+0xf>
    ;
  return n;
 13b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 146:	8b 45 10             	mov    0x10(%ebp),%eax
 149:	89 44 24 08          	mov    %eax,0x8(%esp)
 14d:	8b 45 0c             	mov    0xc(%ebp),%eax
 150:	89 44 24 04          	mov    %eax,0x4(%esp)
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	89 04 24             	mov    %eax,(%esp)
 15a:	e8 31 ff ff ff       	call   90 <stosb>
  return dst;
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strchr>:

char*
strchr(const char *s, char c)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	83 ec 04             	sub    $0x4,%esp
 16a:	8b 45 0c             	mov    0xc(%ebp),%eax
 16d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 170:	eb 12                	jmp    184 <strchr+0x20>
    if(*s == c)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	8a 00                	mov    (%eax),%al
 177:	3a 45 fc             	cmp    -0x4(%ebp),%al
 17a:	75 05                	jne    181 <strchr+0x1d>
      return (char*)s;
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	eb 11                	jmp    192 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 181:	ff 45 08             	incl   0x8(%ebp)
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	8a 00                	mov    (%eax),%al
 189:	84 c0                	test   %al,%al
 18b:	75 e5                	jne    172 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 18d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 192:	c9                   	leave  
 193:	c3                   	ret    

00000194 <gets>:

char*
gets(char *buf, int max)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a1:	eb 49                	jmp    1ec <gets+0x58>
    cc = read(0, &c, 1);
 1a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1aa:	00 
 1ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b9:	e8 22 02 00 00       	call   3e0 <read>
 1be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c5:	7f 02                	jg     1c9 <gets+0x35>
      break;
 1c7:	eb 2c                	jmp    1f5 <gets+0x61>
    buf[i++] = c;
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	8d 50 01             	lea    0x1(%eax),%edx
 1cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1d2:	89 c2                	mov    %eax,%edx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	01 c2                	add    %eax,%edx
 1d9:	8a 45 ef             	mov    -0x11(%ebp),%al
 1dc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1de:	8a 45 ef             	mov    -0x11(%ebp),%al
 1e1:	3c 0a                	cmp    $0xa,%al
 1e3:	74 10                	je     1f5 <gets+0x61>
 1e5:	8a 45 ef             	mov    -0x11(%ebp),%al
 1e8:	3c 0d                	cmp    $0xd,%al
 1ea:	74 09                	je     1f5 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ef:	40                   	inc    %eax
 1f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f3:	7c ae                	jl     1a3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	01 d0                	add    %edx,%eax
 1fd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 200:	8b 45 08             	mov    0x8(%ebp),%eax
}
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <stat>:

int
stat(char *n, struct stat *st)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 212:	00 
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	89 04 24             	mov    %eax,(%esp)
 219:	e8 ea 01 00 00       	call   408 <open>
 21e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 221:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 225:	79 07                	jns    22e <stat+0x29>
    return -1;
 227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22c:	eb 23                	jmp    251 <stat+0x4c>
  r = fstat(fd, st);
 22e:	8b 45 0c             	mov    0xc(%ebp),%eax
 231:	89 44 24 04          	mov    %eax,0x4(%esp)
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	89 04 24             	mov    %eax,(%esp)
 23b:	e8 e0 01 00 00       	call   420 <fstat>
 240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 243:	8b 45 f4             	mov    -0xc(%ebp),%eax
 246:	89 04 24             	mov    %eax,(%esp)
 249:	e8 a2 01 00 00       	call   3f0 <close>
  return r;
 24e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 251:	c9                   	leave  
 252:	c3                   	ret    

00000253 <atoi>:

int
atoi(const char *s)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 259:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 260:	eb 24                	jmp    286 <atoi+0x33>
    n = n*10 + *s++ - '0';
 262:	8b 55 fc             	mov    -0x4(%ebp),%edx
 265:	89 d0                	mov    %edx,%eax
 267:	c1 e0 02             	shl    $0x2,%eax
 26a:	01 d0                	add    %edx,%eax
 26c:	01 c0                	add    %eax,%eax
 26e:	89 c1                	mov    %eax,%ecx
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	8d 50 01             	lea    0x1(%eax),%edx
 276:	89 55 08             	mov    %edx,0x8(%ebp)
 279:	8a 00                	mov    (%eax),%al
 27b:	0f be c0             	movsbl %al,%eax
 27e:	01 c8                	add    %ecx,%eax
 280:	83 e8 30             	sub    $0x30,%eax
 283:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	8a 00                	mov    (%eax),%al
 28b:	3c 2f                	cmp    $0x2f,%al
 28d:	7e 09                	jle    298 <atoi+0x45>
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	8a 00                	mov    (%eax),%al
 294:	3c 39                	cmp    $0x39,%al
 296:	7e ca                	jle    262 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 298:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29b:	c9                   	leave  
 29c:	c3                   	ret    

0000029d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2af:	eb 16                	jmp    2c7 <memmove+0x2a>
    *dst++ = *src++;
 2b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b4:	8d 50 01             	lea    0x1(%eax),%edx
 2b7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2bd:	8d 4a 01             	lea    0x1(%edx),%ecx
 2c0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2c3:	8a 12                	mov    (%edx),%dl
 2c5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c7:	8b 45 10             	mov    0x10(%ebp),%eax
 2ca:	8d 50 ff             	lea    -0x1(%eax),%edx
 2cd:	89 55 10             	mov    %edx,0x10(%ebp)
 2d0:	85 c0                	test   %eax,%eax
 2d2:	7f dd                	jg     2b1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d7:	c9                   	leave  
 2d8:	c3                   	ret    

000002d9 <itoa>:

int itoa(int value, char *sp, int radix)
{
 2d9:	55                   	push   %ebp
 2da:	89 e5                	mov    %esp,%ebp
 2dc:	53                   	push   %ebx
 2dd:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2e0:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2e6:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 2ea:	75 0d                	jne    2f9 <itoa+0x20>
 2ec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2f0:	79 07                	jns    2f9 <itoa+0x20>
 2f2:	b8 01 00 00 00       	mov    $0x1,%eax
 2f7:	eb 05                	jmp    2fe <itoa+0x25>
 2f9:	b8 00 00 00 00       	mov    $0x0,%eax
 2fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 301:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 305:	74 0a                	je     311 <itoa+0x38>
      v = -value;
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	f7 d8                	neg    %eax
 30c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 30f:	eb 54                	jmp    365 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 317:	eb 4c                	jmp    365 <itoa+0x8c>
  {
    i = v % radix;
 319:	8b 4d 10             	mov    0x10(%ebp),%ecx
 31c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31f:	ba 00 00 00 00       	mov    $0x0,%edx
 324:	f7 f1                	div    %ecx
 326:	89 d0                	mov    %edx,%eax
 328:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 32b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 32e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 331:	ba 00 00 00 00       	mov    $0x0,%edx
 336:	f7 f3                	div    %ebx
 338:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 33b:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 33f:	7f 13                	jg     354 <itoa+0x7b>
      *tp++ = i+'0';
 341:	8b 45 f8             	mov    -0x8(%ebp),%eax
 344:	8d 50 01             	lea    0x1(%eax),%edx
 347:	89 55 f8             	mov    %edx,-0x8(%ebp)
 34a:	8b 55 e8             	mov    -0x18(%ebp),%edx
 34d:	83 c2 30             	add    $0x30,%edx
 350:	88 10                	mov    %dl,(%eax)
 352:	eb 11                	jmp    365 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 354:	8b 45 f8             	mov    -0x8(%ebp),%eax
 357:	8d 50 01             	lea    0x1(%eax),%edx
 35a:	89 55 f8             	mov    %edx,-0x8(%ebp)
 35d:	8b 55 e8             	mov    -0x18(%ebp),%edx
 360:	83 c2 57             	add    $0x57,%edx
 363:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 365:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 369:	75 ae                	jne    319 <itoa+0x40>
 36b:	8d 45 d8             	lea    -0x28(%ebp),%eax
 36e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 371:	74 a6                	je     319 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 373:	8b 55 f8             	mov    -0x8(%ebp),%edx
 376:	8d 45 d8             	lea    -0x28(%ebp),%eax
 379:	29 c2                	sub    %eax,%edx
 37b:	89 d0                	mov    %edx,%eax
 37d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 380:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 384:	74 11                	je     397 <itoa+0xbe>
  {
    *sp++ = '-';
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	8d 50 01             	lea    0x1(%eax),%edx
 38c:	89 55 0c             	mov    %edx,0xc(%ebp)
 38f:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 392:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 395:	eb 15                	jmp    3ac <itoa+0xd3>
 397:	eb 13                	jmp    3ac <itoa+0xd3>
    *sp++ = *--tp;
 399:	8b 45 0c             	mov    0xc(%ebp),%eax
 39c:	8d 50 01             	lea    0x1(%eax),%edx
 39f:	89 55 0c             	mov    %edx,0xc(%ebp)
 3a2:	ff 4d f8             	decl   -0x8(%ebp)
 3a5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3a8:	8a 12                	mov    (%edx),%dl
 3aa:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 3ac:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3af:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3b2:	77 e5                	ja     399 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 3b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3b7:	83 c4 30             	add    $0x30,%esp
 3ba:	5b                   	pop    %ebx
 3bb:	5d                   	pop    %ebp
 3bc:	c3                   	ret    
 3bd:	90                   	nop
 3be:	90                   	nop
 3bf:	90                   	nop

000003c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3c0:	b8 01 00 00 00       	mov    $0x1,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <exit>:
SYSCALL(exit)
 3c8:	b8 02 00 00 00       	mov    $0x2,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <wait>:
SYSCALL(wait)
 3d0:	b8 03 00 00 00       	mov    $0x3,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <pipe>:
SYSCALL(pipe)
 3d8:	b8 04 00 00 00       	mov    $0x4,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <read>:
SYSCALL(read)
 3e0:	b8 05 00 00 00       	mov    $0x5,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <write>:
SYSCALL(write)
 3e8:	b8 10 00 00 00       	mov    $0x10,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <close>:
SYSCALL(close)
 3f0:	b8 15 00 00 00       	mov    $0x15,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <kill>:
SYSCALL(kill)
 3f8:	b8 06 00 00 00       	mov    $0x6,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <exec>:
SYSCALL(exec)
 400:	b8 07 00 00 00       	mov    $0x7,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <open>:
SYSCALL(open)
 408:	b8 0f 00 00 00       	mov    $0xf,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <mknod>:
SYSCALL(mknod)
 410:	b8 11 00 00 00       	mov    $0x11,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <unlink>:
SYSCALL(unlink)
 418:	b8 12 00 00 00       	mov    $0x12,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <fstat>:
SYSCALL(fstat)
 420:	b8 08 00 00 00       	mov    $0x8,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <link>:
SYSCALL(link)
 428:	b8 13 00 00 00       	mov    $0x13,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <mkdir>:
SYSCALL(mkdir)
 430:	b8 14 00 00 00       	mov    $0x14,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <chdir>:
SYSCALL(chdir)
 438:	b8 09 00 00 00       	mov    $0x9,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <dup>:
SYSCALL(dup)
 440:	b8 0a 00 00 00       	mov    $0xa,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <getpid>:
SYSCALL(getpid)
 448:	b8 0b 00 00 00       	mov    $0xb,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <sbrk>:
SYSCALL(sbrk)
 450:	b8 0c 00 00 00       	mov    $0xc,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <sleep>:
SYSCALL(sleep)
 458:	b8 0d 00 00 00       	mov    $0xd,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <uptime>:
SYSCALL(uptime)
 460:	b8 0e 00 00 00       	mov    $0xe,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <getticks>:
SYSCALL(getticks)
 468:	b8 16 00 00 00       	mov    $0x16,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <get_name>:
SYSCALL(get_name)
 470:	b8 17 00 00 00       	mov    $0x17,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <get_max_proc>:
SYSCALL(get_max_proc)
 478:	b8 18 00 00 00       	mov    $0x18,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <get_max_mem>:
SYSCALL(get_max_mem)
 480:	b8 19 00 00 00       	mov    $0x19,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <get_max_disk>:
SYSCALL(get_max_disk)
 488:	b8 1a 00 00 00       	mov    $0x1a,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <get_curr_proc>:
SYSCALL(get_curr_proc)
 490:	b8 1b 00 00 00       	mov    $0x1b,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <get_curr_mem>:
SYSCALL(get_curr_mem)
 498:	b8 1c 00 00 00       	mov    $0x1c,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <get_curr_disk>:
SYSCALL(get_curr_disk)
 4a0:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <set_name>:
SYSCALL(set_name)
 4a8:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <set_max_mem>:
SYSCALL(set_max_mem)
 4b0:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <set_max_disk>:
SYSCALL(set_max_disk)
 4b8:	b8 20 00 00 00       	mov    $0x20,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <set_max_proc>:
SYSCALL(set_max_proc)
 4c0:	b8 21 00 00 00       	mov    $0x21,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <set_curr_mem>:
SYSCALL(set_curr_mem)
 4c8:	b8 22 00 00 00       	mov    $0x22,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <set_curr_disk>:
SYSCALL(set_curr_disk)
 4d0:	b8 23 00 00 00       	mov    $0x23,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4d8:	b8 24 00 00 00       	mov    $0x24,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <find>:
SYSCALL(find)
 4e0:	b8 25 00 00 00       	mov    $0x25,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <is_full>:
SYSCALL(is_full)
 4e8:	b8 26 00 00 00       	mov    $0x26,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <container_init>:
SYSCALL(container_init)
 4f0:	b8 27 00 00 00       	mov    $0x27,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <cont_proc_set>:
SYSCALL(cont_proc_set)
 4f8:	b8 28 00 00 00       	mov    $0x28,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <ps>:
SYSCALL(ps)
 500:	b8 29 00 00 00       	mov    $0x29,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 508:	b8 2a 00 00 00       	mov    $0x2a,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <set_root_inode>:
SYSCALL(set_root_inode)
 510:	b8 2b 00 00 00       	mov    $0x2b,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <cstop>:
SYSCALL(cstop)
 518:	b8 2c 00 00 00       	mov    $0x2c,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <df>:
SYSCALL(df)
 520:	b8 2d 00 00 00       	mov    $0x2d,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <max_containers>:
SYSCALL(max_containers)
 528:	b8 2e 00 00 00       	mov    $0x2e,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <container_reset>:
SYSCALL(container_reset)
 530:	b8 2f 00 00 00       	mov    $0x2f,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <pause>:
SYSCALL(pause)
 538:	b8 30 00 00 00       	mov    $0x30,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <resume>:
SYSCALL(resume)
 540:	b8 31 00 00 00       	mov    $0x31,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <tmem>:
SYSCALL(tmem)
 548:	b8 32 00 00 00       	mov    $0x32,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <amem>:
SYSCALL(amem)
 550:	b8 33 00 00 00       	mov    $0x33,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <c_ps>:
SYSCALL(c_ps)
 558:	b8 34 00 00 00       	mov    $0x34,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <get_used>:
SYSCALL(get_used)
 560:	b8 35 00 00 00       	mov    $0x35,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <get_os>:
SYSCALL(get_os)
 568:	b8 36 00 00 00       	mov    $0x36,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <set_os>:
SYSCALL(set_os)
 570:	b8 37 00 00 00       	mov    $0x37,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	83 ec 18             	sub    $0x18,%esp
 57e:	8b 45 0c             	mov    0xc(%ebp),%eax
 581:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 584:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 58b:	00 
 58c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 58f:	89 44 24 04          	mov    %eax,0x4(%esp)
 593:	8b 45 08             	mov    0x8(%ebp),%eax
 596:	89 04 24             	mov    %eax,(%esp)
 599:	e8 4a fe ff ff       	call   3e8 <write>
}
 59e:	c9                   	leave  
 59f:	c3                   	ret    

000005a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	56                   	push   %esi
 5a4:	53                   	push   %ebx
 5a5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5b3:	74 17                	je     5cc <printint+0x2c>
 5b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5b9:	79 11                	jns    5cc <printint+0x2c>
    neg = 1;
 5bb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c5:	f7 d8                	neg    %eax
 5c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5ca:	eb 06                	jmp    5d2 <printint+0x32>
  } else {
    x = xx;
 5cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5dc:	8d 41 01             	lea    0x1(%ecx),%eax
 5df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5e8:	ba 00 00 00 00       	mov    $0x0,%edx
 5ed:	f7 f3                	div    %ebx
 5ef:	89 d0                	mov    %edx,%eax
 5f1:	8a 80 c0 0c 00 00    	mov    0xcc0(%eax),%al
 5f7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5fb:	8b 75 10             	mov    0x10(%ebp),%esi
 5fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
 601:	ba 00 00 00 00       	mov    $0x0,%edx
 606:	f7 f6                	div    %esi
 608:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 60f:	75 c8                	jne    5d9 <printint+0x39>
  if(neg)
 611:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 615:	74 10                	je     627 <printint+0x87>
    buf[i++] = '-';
 617:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61a:	8d 50 01             	lea    0x1(%eax),%edx
 61d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 620:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 625:	eb 1e                	jmp    645 <printint+0xa5>
 627:	eb 1c                	jmp    645 <printint+0xa5>
    putc(fd, buf[i]);
 629:	8d 55 dc             	lea    -0x24(%ebp),%edx
 62c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62f:	01 d0                	add    %edx,%eax
 631:	8a 00                	mov    (%eax),%al
 633:	0f be c0             	movsbl %al,%eax
 636:	89 44 24 04          	mov    %eax,0x4(%esp)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	89 04 24             	mov    %eax,(%esp)
 640:	e8 33 ff ff ff       	call   578 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 645:	ff 4d f4             	decl   -0xc(%ebp)
 648:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64c:	79 db                	jns    629 <printint+0x89>
    putc(fd, buf[i]);
}
 64e:	83 c4 30             	add    $0x30,%esp
 651:	5b                   	pop    %ebx
 652:	5e                   	pop    %esi
 653:	5d                   	pop    %ebp
 654:	c3                   	ret    

00000655 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 655:	55                   	push   %ebp
 656:	89 e5                	mov    %esp,%ebp
 658:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 65b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 662:	8d 45 0c             	lea    0xc(%ebp),%eax
 665:	83 c0 04             	add    $0x4,%eax
 668:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 66b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 672:	e9 77 01 00 00       	jmp    7ee <printf+0x199>
    c = fmt[i] & 0xff;
 677:	8b 55 0c             	mov    0xc(%ebp),%edx
 67a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 67d:	01 d0                	add    %edx,%eax
 67f:	8a 00                	mov    (%eax),%al
 681:	0f be c0             	movsbl %al,%eax
 684:	25 ff 00 00 00       	and    $0xff,%eax
 689:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 68c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 690:	75 2c                	jne    6be <printf+0x69>
      if(c == '%'){
 692:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 696:	75 0c                	jne    6a4 <printf+0x4f>
        state = '%';
 698:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 69f:	e9 47 01 00 00       	jmp    7eb <printf+0x196>
      } else {
        putc(fd, c);
 6a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a7:	0f be c0             	movsbl %al,%eax
 6aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	89 04 24             	mov    %eax,(%esp)
 6b4:	e8 bf fe ff ff       	call   578 <putc>
 6b9:	e9 2d 01 00 00       	jmp    7eb <printf+0x196>
      }
    } else if(state == '%'){
 6be:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6c2:	0f 85 23 01 00 00    	jne    7eb <printf+0x196>
      if(c == 'd'){
 6c8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6cc:	75 2d                	jne    6fb <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d1:	8b 00                	mov    (%eax),%eax
 6d3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6da:	00 
 6db:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6e2:	00 
 6e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ea:	89 04 24             	mov    %eax,(%esp)
 6ed:	e8 ae fe ff ff       	call   5a0 <printint>
        ap++;
 6f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f6:	e9 e9 00 00 00       	jmp    7e4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6fb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ff:	74 06                	je     707 <printf+0xb2>
 701:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 705:	75 2d                	jne    734 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 707:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 713:	00 
 714:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 71b:	00 
 71c:	89 44 24 04          	mov    %eax,0x4(%esp)
 720:	8b 45 08             	mov    0x8(%ebp),%eax
 723:	89 04 24             	mov    %eax,(%esp)
 726:	e8 75 fe ff ff       	call   5a0 <printint>
        ap++;
 72b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72f:	e9 b0 00 00 00       	jmp    7e4 <printf+0x18f>
      } else if(c == 's'){
 734:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 738:	75 42                	jne    77c <printf+0x127>
        s = (char*)*ap;
 73a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73d:	8b 00                	mov    (%eax),%eax
 73f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 742:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 746:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74a:	75 09                	jne    755 <printf+0x100>
          s = "(null)";
 74c:	c7 45 f4 4e 0a 00 00 	movl   $0xa4e,-0xc(%ebp)
        while(*s != 0){
 753:	eb 1c                	jmp    771 <printf+0x11c>
 755:	eb 1a                	jmp    771 <printf+0x11c>
          putc(fd, *s);
 757:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75a:	8a 00                	mov    (%eax),%al
 75c:	0f be c0             	movsbl %al,%eax
 75f:	89 44 24 04          	mov    %eax,0x4(%esp)
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 0a fe ff ff       	call   578 <putc>
          s++;
 76e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	8a 00                	mov    (%eax),%al
 776:	84 c0                	test   %al,%al
 778:	75 dd                	jne    757 <printf+0x102>
 77a:	eb 68                	jmp    7e4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 77c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 780:	75 1d                	jne    79f <printf+0x14a>
        putc(fd, *ap);
 782:	8b 45 e8             	mov    -0x18(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	0f be c0             	movsbl %al,%eax
 78a:	89 44 24 04          	mov    %eax,0x4(%esp)
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
 791:	89 04 24             	mov    %eax,(%esp)
 794:	e8 df fd ff ff       	call   578 <putc>
        ap++;
 799:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79d:	eb 45                	jmp    7e4 <printf+0x18f>
      } else if(c == '%'){
 79f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7a3:	75 17                	jne    7bc <printf+0x167>
        putc(fd, c);
 7a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a8:	0f be c0             	movsbl %al,%eax
 7ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
 7b2:	89 04 24             	mov    %eax,(%esp)
 7b5:	e8 be fd ff ff       	call   578 <putc>
 7ba:	eb 28                	jmp    7e4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7bc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7c3:	00 
 7c4:	8b 45 08             	mov    0x8(%ebp),%eax
 7c7:	89 04 24             	mov    %eax,(%esp)
 7ca:	e8 a9 fd ff ff       	call   578 <putc>
        putc(fd, c);
 7cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d2:	0f be c0             	movsbl %al,%eax
 7d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d9:	8b 45 08             	mov    0x8(%ebp),%eax
 7dc:	89 04 24             	mov    %eax,(%esp)
 7df:	e8 94 fd ff ff       	call   578 <putc>
      }
      state = 0;
 7e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7eb:	ff 45 f0             	incl   -0x10(%ebp)
 7ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 7f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f4:	01 d0                	add    %edx,%eax
 7f6:	8a 00                	mov    (%eax),%al
 7f8:	84 c0                	test   %al,%al
 7fa:	0f 85 77 fe ff ff    	jne    677 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 800:	c9                   	leave  
 801:	c3                   	ret    
 802:	90                   	nop
 803:	90                   	nop

00000804 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 804:	55                   	push   %ebp
 805:	89 e5                	mov    %esp,%ebp
 807:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80a:	8b 45 08             	mov    0x8(%ebp),%eax
 80d:	83 e8 08             	sub    $0x8,%eax
 810:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 813:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 818:	89 45 fc             	mov    %eax,-0x4(%ebp)
 81b:	eb 24                	jmp    841 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 825:	77 12                	ja     839 <free+0x35>
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 82d:	77 24                	ja     853 <free+0x4f>
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	8b 00                	mov    (%eax),%eax
 834:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 837:	77 1a                	ja     853 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 841:	8b 45 f8             	mov    -0x8(%ebp),%eax
 844:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 847:	76 d4                	jbe    81d <free+0x19>
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 851:	76 ca                	jbe    81d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 853:	8b 45 f8             	mov    -0x8(%ebp),%eax
 856:	8b 40 04             	mov    0x4(%eax),%eax
 859:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 860:	8b 45 f8             	mov    -0x8(%ebp),%eax
 863:	01 c2                	add    %eax,%edx
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	39 c2                	cmp    %eax,%edx
 86c:	75 24                	jne    892 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 86e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 871:	8b 50 04             	mov    0x4(%eax),%edx
 874:	8b 45 fc             	mov    -0x4(%ebp),%eax
 877:	8b 00                	mov    (%eax),%eax
 879:	8b 40 04             	mov    0x4(%eax),%eax
 87c:	01 c2                	add    %eax,%edx
 87e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 881:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	8b 00                	mov    (%eax),%eax
 889:	8b 10                	mov    (%eax),%edx
 88b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88e:	89 10                	mov    %edx,(%eax)
 890:	eb 0a                	jmp    89c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 892:	8b 45 fc             	mov    -0x4(%ebp),%eax
 895:	8b 10                	mov    (%eax),%edx
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 89c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89f:	8b 40 04             	mov    0x4(%eax),%eax
 8a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	01 d0                	add    %edx,%eax
 8ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b1:	75 20                	jne    8d3 <free+0xcf>
    p->s.size += bp->s.size;
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	8b 50 04             	mov    0x4(%eax),%edx
 8b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bc:	8b 40 04             	mov    0x4(%eax),%eax
 8bf:	01 c2                	add    %eax,%edx
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ca:	8b 10                	mov    (%eax),%edx
 8cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cf:	89 10                	mov    %edx,(%eax)
 8d1:	eb 08                	jmp    8db <free+0xd7>
  } else
    p->s.ptr = bp;
 8d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8d9:	89 10                	mov    %edx,(%eax)
  freep = p;
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	a3 dc 0c 00 00       	mov    %eax,0xcdc
}
 8e3:	c9                   	leave  
 8e4:	c3                   	ret    

000008e5 <morecore>:

static Header*
morecore(uint nu)
{
 8e5:	55                   	push   %ebp
 8e6:	89 e5                	mov    %esp,%ebp
 8e8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8eb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8f2:	77 07                	ja     8fb <morecore+0x16>
    nu = 4096;
 8f4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8fb:	8b 45 08             	mov    0x8(%ebp),%eax
 8fe:	c1 e0 03             	shl    $0x3,%eax
 901:	89 04 24             	mov    %eax,(%esp)
 904:	e8 47 fb ff ff       	call   450 <sbrk>
 909:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 90c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 910:	75 07                	jne    919 <morecore+0x34>
    return 0;
 912:	b8 00 00 00 00       	mov    $0x0,%eax
 917:	eb 22                	jmp    93b <morecore+0x56>
  hp = (Header*)p;
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 91f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 922:	8b 55 08             	mov    0x8(%ebp),%edx
 925:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 928:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92b:	83 c0 08             	add    $0x8,%eax
 92e:	89 04 24             	mov    %eax,(%esp)
 931:	e8 ce fe ff ff       	call   804 <free>
  return freep;
 936:	a1 dc 0c 00 00       	mov    0xcdc,%eax
}
 93b:	c9                   	leave  
 93c:	c3                   	ret    

0000093d <malloc>:

void*
malloc(uint nbytes)
{
 93d:	55                   	push   %ebp
 93e:	89 e5                	mov    %esp,%ebp
 940:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 943:	8b 45 08             	mov    0x8(%ebp),%eax
 946:	83 c0 07             	add    $0x7,%eax
 949:	c1 e8 03             	shr    $0x3,%eax
 94c:	40                   	inc    %eax
 94d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 950:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 955:	89 45 f0             	mov    %eax,-0x10(%ebp)
 958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 95c:	75 23                	jne    981 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 95e:	c7 45 f0 d4 0c 00 00 	movl   $0xcd4,-0x10(%ebp)
 965:	8b 45 f0             	mov    -0x10(%ebp),%eax
 968:	a3 dc 0c 00 00       	mov    %eax,0xcdc
 96d:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 972:	a3 d4 0c 00 00       	mov    %eax,0xcd4
    base.s.size = 0;
 977:	c7 05 d8 0c 00 00 00 	movl   $0x0,0xcd8
 97e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 981:	8b 45 f0             	mov    -0x10(%ebp),%eax
 984:	8b 00                	mov    (%eax),%eax
 986:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 989:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98c:	8b 40 04             	mov    0x4(%eax),%eax
 98f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 992:	72 4d                	jb     9e1 <malloc+0xa4>
      if(p->s.size == nunits)
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 40 04             	mov    0x4(%eax),%eax
 99a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 99d:	75 0c                	jne    9ab <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 99f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a2:	8b 10                	mov    (%eax),%edx
 9a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a7:	89 10                	mov    %edx,(%eax)
 9a9:	eb 26                	jmp    9d1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ae:	8b 40 04             	mov    0x4(%eax),%eax
 9b1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9b4:	89 c2                	mov    %eax,%edx
 9b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	8b 40 04             	mov    0x4(%eax),%eax
 9c2:	c1 e0 03             	shl    $0x3,%eax
 9c5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ce:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d4:	a3 dc 0c 00 00       	mov    %eax,0xcdc
      return (void*)(p + 1);
 9d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dc:	83 c0 08             	add    $0x8,%eax
 9df:	eb 38                	jmp    a19 <malloc+0xdc>
    }
    if(p == freep)
 9e1:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 9e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9e9:	75 1b                	jne    a06 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9ee:	89 04 24             	mov    %eax,(%esp)
 9f1:	e8 ef fe ff ff       	call   8e5 <morecore>
 9f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9fd:	75 07                	jne    a06 <malloc+0xc9>
        return 0;
 9ff:	b8 00 00 00 00       	mov    $0x0,%eax
 a04:	eb 13                	jmp    a19 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a09:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0f:	8b 00                	mov    (%eax),%eax
 a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a14:	e9 70 ff ff ff       	jmp    989 <malloc+0x4c>
}
 a19:	c9                   	leave  
 a1a:	c3                   	ret    
