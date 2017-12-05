
_forkbomb:     file format elf32-i386


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
  int i = 0;
   9:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  10:	00 
  int id;

  printf(1, "forkbomb: started\n");
  11:	c7 44 24 04 14 0a 00 	movl   $0xa14,0x4(%esp)
  18:	00 
  19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  20:	e8 28 06 00 00       	call   64d <printf>
  while(1) {
    id = fork();
  25:	e8 8e 03 00 00       	call   3b8 <fork>
  2a:	89 44 24 18          	mov    %eax,0x18(%esp)
    if (id < 0) {
  2e:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  33:	79 19                	jns    4e <main+0x4e>
      printf(1, "forkbomb: fork() failed, exiting");
  35:	c7 44 24 04 28 0a 00 	movl   $0xa28,0x4(%esp)
  3c:	00 
  3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  44:	e8 04 06 00 00       	call   64d <printf>
      exit();
  49:	e8 72 03 00 00       	call   3c0 <exit>
    }

    if (id == 0) {
  4e:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  53:	75 0e                	jne    63 <main+0x63>
      /* In child, just loop forever. Use sleep so that we don't consume CPU */
      while (1) {
        sleep(10);
  55:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  5c:	e8 ef 03 00 00       	call   450 <sleep>
      }
  61:	eb f2                	jmp    55 <main+0x55>
    }

    i += 1;
  63:	ff 44 24 1c          	incl   0x1c(%esp)
    printf(1, "forkbomb: fork count = %d\n", i);
  67:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  6f:	c7 44 24 04 49 0a 00 	movl   $0xa49,0x4(%esp)
  76:	00 
  77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7e:	e8 ca 05 00 00       	call   64d <printf>
  }
  83:	eb a0                	jmp    25 <main+0x25>
  85:	90                   	nop
  86:	90                   	nop
  87:	90                   	nop

00000088 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  88:	55                   	push   %ebp
  89:	89 e5                	mov    %esp,%ebp
  8b:	57                   	push   %edi
  8c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  90:	8b 55 10             	mov    0x10(%ebp),%edx
  93:	8b 45 0c             	mov    0xc(%ebp),%eax
  96:	89 cb                	mov    %ecx,%ebx
  98:	89 df                	mov    %ebx,%edi
  9a:	89 d1                	mov    %edx,%ecx
  9c:	fc                   	cld    
  9d:	f3 aa                	rep stos %al,%es:(%edi)
  9f:	89 ca                	mov    %ecx,%edx
  a1:	89 fb                	mov    %edi,%ebx
  a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
  a6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a9:	5b                   	pop    %ebx
  aa:	5f                   	pop    %edi
  ab:	5d                   	pop    %ebp
  ac:	c3                   	ret    

000000ad <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  b0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  b3:	8b 45 08             	mov    0x8(%ebp),%eax
  b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b9:	90                   	nop
  ba:	8b 45 08             	mov    0x8(%ebp),%eax
  bd:	8d 50 01             	lea    0x1(%eax),%edx
  c0:	89 55 08             	mov    %edx,0x8(%ebp)
  c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  c9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  cc:	8a 12                	mov    (%edx),%dl
  ce:	88 10                	mov    %dl,(%eax)
  d0:	8a 00                	mov    (%eax),%al
  d2:	84 c0                	test   %al,%al
  d4:	75 e4                	jne    ba <strcpy+0xd>
    ;
  return os;
  d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d9:	c9                   	leave  
  da:	c3                   	ret    

000000db <strcmp>:

int
strcmp(const char *p, const char *q)
{
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  de:	eb 06                	jmp    e6 <strcmp+0xb>
    p++, q++;
  e0:	ff 45 08             	incl   0x8(%ebp)
  e3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  e6:	8b 45 08             	mov    0x8(%ebp),%eax
  e9:	8a 00                	mov    (%eax),%al
  eb:	84 c0                	test   %al,%al
  ed:	74 0e                	je     fd <strcmp+0x22>
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	8a 10                	mov    (%eax),%dl
  f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  f7:	8a 00                	mov    (%eax),%al
  f9:	38 c2                	cmp    %al,%dl
  fb:	74 e3                	je     e0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	8a 00                	mov    (%eax),%al
 102:	0f b6 d0             	movzbl %al,%edx
 105:	8b 45 0c             	mov    0xc(%ebp),%eax
 108:	8a 00                	mov    (%eax),%al
 10a:	0f b6 c0             	movzbl %al,%eax
 10d:	29 c2                	sub    %eax,%edx
 10f:	89 d0                	mov    %edx,%eax
}
 111:	5d                   	pop    %ebp
 112:	c3                   	ret    

00000113 <strlen>:

uint
strlen(char *s)
{
 113:	55                   	push   %ebp
 114:	89 e5                	mov    %esp,%ebp
 116:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 119:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 120:	eb 03                	jmp    125 <strlen+0x12>
 122:	ff 45 fc             	incl   -0x4(%ebp)
 125:	8b 55 fc             	mov    -0x4(%ebp),%edx
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	01 d0                	add    %edx,%eax
 12d:	8a 00                	mov    (%eax),%al
 12f:	84 c0                	test   %al,%al
 131:	75 ef                	jne    122 <strlen+0xf>
    ;
  return n;
 133:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 136:	c9                   	leave  
 137:	c3                   	ret    

00000138 <memset>:

void*
memset(void *dst, int c, uint n)
{
 138:	55                   	push   %ebp
 139:	89 e5                	mov    %esp,%ebp
 13b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 13e:	8b 45 10             	mov    0x10(%ebp),%eax
 141:	89 44 24 08          	mov    %eax,0x8(%esp)
 145:	8b 45 0c             	mov    0xc(%ebp),%eax
 148:	89 44 24 04          	mov    %eax,0x4(%esp)
 14c:	8b 45 08             	mov    0x8(%ebp),%eax
 14f:	89 04 24             	mov    %eax,(%esp)
 152:	e8 31 ff ff ff       	call   88 <stosb>
  return dst;
 157:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15a:	c9                   	leave  
 15b:	c3                   	ret    

0000015c <strchr>:

char*
strchr(const char *s, char c)
{
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
 15f:	83 ec 04             	sub    $0x4,%esp
 162:	8b 45 0c             	mov    0xc(%ebp),%eax
 165:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 168:	eb 12                	jmp    17c <strchr+0x20>
    if(*s == c)
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	8a 00                	mov    (%eax),%al
 16f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 172:	75 05                	jne    179 <strchr+0x1d>
      return (char*)s;
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	eb 11                	jmp    18a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 179:	ff 45 08             	incl   0x8(%ebp)
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	8a 00                	mov    (%eax),%al
 181:	84 c0                	test   %al,%al
 183:	75 e5                	jne    16a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 185:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18a:	c9                   	leave  
 18b:	c3                   	ret    

0000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 199:	eb 49                	jmp    1e4 <gets+0x58>
    cc = read(0, &c, 1);
 19b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a2:	00 
 1a3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b1:	e8 22 02 00 00       	call   3d8 <read>
 1b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1bd:	7f 02                	jg     1c1 <gets+0x35>
      break;
 1bf:	eb 2c                	jmp    1ed <gets+0x61>
    buf[i++] = c;
 1c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c4:	8d 50 01             	lea    0x1(%eax),%edx
 1c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ca:	89 c2                	mov    %eax,%edx
 1cc:	8b 45 08             	mov    0x8(%ebp),%eax
 1cf:	01 c2                	add    %eax,%edx
 1d1:	8a 45 ef             	mov    -0x11(%ebp),%al
 1d4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1d9:	3c 0a                	cmp    $0xa,%al
 1db:	74 10                	je     1ed <gets+0x61>
 1dd:	8a 45 ef             	mov    -0x11(%ebp),%al
 1e0:	3c 0d                	cmp    $0xd,%al
 1e2:	74 09                	je     1ed <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e7:	40                   	inc    %eax
 1e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1eb:	7c ae                	jl     19b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	01 d0                	add    %edx,%eax
 1f5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fb:	c9                   	leave  
 1fc:	c3                   	ret    

000001fd <stat>:

int
stat(char *n, struct stat *st)
{
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 203:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 20a:	00 
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	89 04 24             	mov    %eax,(%esp)
 211:	e8 ea 01 00 00       	call   400 <open>
 216:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 219:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21d:	79 07                	jns    226 <stat+0x29>
    return -1;
 21f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 224:	eb 23                	jmp    249 <stat+0x4c>
  r = fstat(fd, st);
 226:	8b 45 0c             	mov    0xc(%ebp),%eax
 229:	89 44 24 04          	mov    %eax,0x4(%esp)
 22d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 230:	89 04 24             	mov    %eax,(%esp)
 233:	e8 e0 01 00 00       	call   418 <fstat>
 238:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23e:	89 04 24             	mov    %eax,(%esp)
 241:	e8 a2 01 00 00       	call   3e8 <close>
  return r;
 246:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 249:	c9                   	leave  
 24a:	c3                   	ret    

0000024b <atoi>:

int
atoi(const char *s)
{
 24b:	55                   	push   %ebp
 24c:	89 e5                	mov    %esp,%ebp
 24e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 251:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 258:	eb 24                	jmp    27e <atoi+0x33>
    n = n*10 + *s++ - '0';
 25a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25d:	89 d0                	mov    %edx,%eax
 25f:	c1 e0 02             	shl    $0x2,%eax
 262:	01 d0                	add    %edx,%eax
 264:	01 c0                	add    %eax,%eax
 266:	89 c1                	mov    %eax,%ecx
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	8d 50 01             	lea    0x1(%eax),%edx
 26e:	89 55 08             	mov    %edx,0x8(%ebp)
 271:	8a 00                	mov    (%eax),%al
 273:	0f be c0             	movsbl %al,%eax
 276:	01 c8                	add    %ecx,%eax
 278:	83 e8 30             	sub    $0x30,%eax
 27b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	8a 00                	mov    (%eax),%al
 283:	3c 2f                	cmp    $0x2f,%al
 285:	7e 09                	jle    290 <atoi+0x45>
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	8a 00                	mov    (%eax),%al
 28c:	3c 39                	cmp    $0x39,%al
 28e:	7e ca                	jle    25a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 290:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2a7:	eb 16                	jmp    2bf <memmove+0x2a>
    *dst++ = *src++;
 2a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ac:	8d 50 01             	lea    0x1(%eax),%edx
 2af:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2b5:	8d 4a 01             	lea    0x1(%edx),%ecx
 2b8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2bb:	8a 12                	mov    (%edx),%dl
 2bd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2bf:	8b 45 10             	mov    0x10(%ebp),%eax
 2c2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2c5:	89 55 10             	mov    %edx,0x10(%ebp)
 2c8:	85 c0                	test   %eax,%eax
 2ca:	7f dd                	jg     2a9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2cf:	c9                   	leave  
 2d0:	c3                   	ret    

000002d1 <itoa>:

int itoa(int value, char *sp, int radix)
{
 2d1:	55                   	push   %ebp
 2d2:	89 e5                	mov    %esp,%ebp
 2d4:	53                   	push   %ebx
 2d5:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 2d8:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2db:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 2de:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 2e2:	75 0d                	jne    2f1 <itoa+0x20>
 2e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e8:	79 07                	jns    2f1 <itoa+0x20>
 2ea:	b8 01 00 00 00       	mov    $0x1,%eax
 2ef:	eb 05                	jmp    2f6 <itoa+0x25>
 2f1:	b8 00 00 00 00       	mov    $0x0,%eax
 2f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 2f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2fd:	74 0a                	je     309 <itoa+0x38>
      v = -value;
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	f7 d8                	neg    %eax
 304:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 307:	eb 54                	jmp    35d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 30f:	eb 4c                	jmp    35d <itoa+0x8c>
  {
    i = v % radix;
 311:	8b 4d 10             	mov    0x10(%ebp),%ecx
 314:	8b 45 f4             	mov    -0xc(%ebp),%eax
 317:	ba 00 00 00 00       	mov    $0x0,%edx
 31c:	f7 f1                	div    %ecx
 31e:	89 d0                	mov    %edx,%eax
 320:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 323:	8b 5d 10             	mov    0x10(%ebp),%ebx
 326:	8b 45 f4             	mov    -0xc(%ebp),%eax
 329:	ba 00 00 00 00       	mov    $0x0,%edx
 32e:	f7 f3                	div    %ebx
 330:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 333:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 337:	7f 13                	jg     34c <itoa+0x7b>
      *tp++ = i+'0';
 339:	8b 45 f8             	mov    -0x8(%ebp),%eax
 33c:	8d 50 01             	lea    0x1(%eax),%edx
 33f:	89 55 f8             	mov    %edx,-0x8(%ebp)
 342:	8b 55 e8             	mov    -0x18(%ebp),%edx
 345:	83 c2 30             	add    $0x30,%edx
 348:	88 10                	mov    %dl,(%eax)
 34a:	eb 11                	jmp    35d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 34c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 34f:	8d 50 01             	lea    0x1(%eax),%edx
 352:	89 55 f8             	mov    %edx,-0x8(%ebp)
 355:	8b 55 e8             	mov    -0x18(%ebp),%edx
 358:	83 c2 57             	add    $0x57,%edx
 35b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 35d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 361:	75 ae                	jne    311 <itoa+0x40>
 363:	8d 45 d8             	lea    -0x28(%ebp),%eax
 366:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 369:	74 a6                	je     311 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 36b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 36e:	8d 45 d8             	lea    -0x28(%ebp),%eax
 371:	29 c2                	sub    %eax,%edx
 373:	89 d0                	mov    %edx,%eax
 375:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 378:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 37c:	74 11                	je     38f <itoa+0xbe>
  {
    *sp++ = '-';
 37e:	8b 45 0c             	mov    0xc(%ebp),%eax
 381:	8d 50 01             	lea    0x1(%eax),%edx
 384:	89 55 0c             	mov    %edx,0xc(%ebp)
 387:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 38a:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 38d:	eb 15                	jmp    3a4 <itoa+0xd3>
 38f:	eb 13                	jmp    3a4 <itoa+0xd3>
    *sp++ = *--tp;
 391:	8b 45 0c             	mov    0xc(%ebp),%eax
 394:	8d 50 01             	lea    0x1(%eax),%edx
 397:	89 55 0c             	mov    %edx,0xc(%ebp)
 39a:	ff 4d f8             	decl   -0x8(%ebp)
 39d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3a0:	8a 12                	mov    (%edx),%dl
 3a2:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 3a4:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3a7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3aa:	77 e5                	ja     391 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 3ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3af:	83 c4 30             	add    $0x30,%esp
 3b2:	5b                   	pop    %ebx
 3b3:	5d                   	pop    %ebp
 3b4:	c3                   	ret    
 3b5:	90                   	nop
 3b6:	90                   	nop
 3b7:	90                   	nop

000003b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3b8:	b8 01 00 00 00       	mov    $0x1,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <exit>:
SYSCALL(exit)
 3c0:	b8 02 00 00 00       	mov    $0x2,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <wait>:
SYSCALL(wait)
 3c8:	b8 03 00 00 00       	mov    $0x3,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <pipe>:
SYSCALL(pipe)
 3d0:	b8 04 00 00 00       	mov    $0x4,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <read>:
SYSCALL(read)
 3d8:	b8 05 00 00 00       	mov    $0x5,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <write>:
SYSCALL(write)
 3e0:	b8 10 00 00 00       	mov    $0x10,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <close>:
SYSCALL(close)
 3e8:	b8 15 00 00 00       	mov    $0x15,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <kill>:
SYSCALL(kill)
 3f0:	b8 06 00 00 00       	mov    $0x6,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <exec>:
SYSCALL(exec)
 3f8:	b8 07 00 00 00       	mov    $0x7,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <open>:
SYSCALL(open)
 400:	b8 0f 00 00 00       	mov    $0xf,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <mknod>:
SYSCALL(mknod)
 408:	b8 11 00 00 00       	mov    $0x11,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <unlink>:
SYSCALL(unlink)
 410:	b8 12 00 00 00       	mov    $0x12,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <fstat>:
SYSCALL(fstat)
 418:	b8 08 00 00 00       	mov    $0x8,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <link>:
SYSCALL(link)
 420:	b8 13 00 00 00       	mov    $0x13,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <mkdir>:
SYSCALL(mkdir)
 428:	b8 14 00 00 00       	mov    $0x14,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <chdir>:
SYSCALL(chdir)
 430:	b8 09 00 00 00       	mov    $0x9,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <dup>:
SYSCALL(dup)
 438:	b8 0a 00 00 00       	mov    $0xa,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <getpid>:
SYSCALL(getpid)
 440:	b8 0b 00 00 00       	mov    $0xb,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <sbrk>:
SYSCALL(sbrk)
 448:	b8 0c 00 00 00       	mov    $0xc,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <sleep>:
SYSCALL(sleep)
 450:	b8 0d 00 00 00       	mov    $0xd,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <uptime>:
SYSCALL(uptime)
 458:	b8 0e 00 00 00       	mov    $0xe,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <getticks>:
SYSCALL(getticks)
 460:	b8 16 00 00 00       	mov    $0x16,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <get_name>:
SYSCALL(get_name)
 468:	b8 17 00 00 00       	mov    $0x17,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <get_max_proc>:
SYSCALL(get_max_proc)
 470:	b8 18 00 00 00       	mov    $0x18,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <get_max_mem>:
SYSCALL(get_max_mem)
 478:	b8 19 00 00 00       	mov    $0x19,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <get_max_disk>:
SYSCALL(get_max_disk)
 480:	b8 1a 00 00 00       	mov    $0x1a,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <get_curr_proc>:
SYSCALL(get_curr_proc)
 488:	b8 1b 00 00 00       	mov    $0x1b,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <get_curr_mem>:
SYSCALL(get_curr_mem)
 490:	b8 1c 00 00 00       	mov    $0x1c,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <get_curr_disk>:
SYSCALL(get_curr_disk)
 498:	b8 1d 00 00 00       	mov    $0x1d,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <set_name>:
SYSCALL(set_name)
 4a0:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <set_max_mem>:
SYSCALL(set_max_mem)
 4a8:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <set_max_disk>:
SYSCALL(set_max_disk)
 4b0:	b8 20 00 00 00       	mov    $0x20,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <set_max_proc>:
SYSCALL(set_max_proc)
 4b8:	b8 21 00 00 00       	mov    $0x21,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <set_curr_mem>:
SYSCALL(set_curr_mem)
 4c0:	b8 22 00 00 00       	mov    $0x22,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <set_curr_disk>:
SYSCALL(set_curr_disk)
 4c8:	b8 23 00 00 00       	mov    $0x23,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4d0:	b8 24 00 00 00       	mov    $0x24,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <find>:
SYSCALL(find)
 4d8:	b8 25 00 00 00       	mov    $0x25,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <is_full>:
SYSCALL(is_full)
 4e0:	b8 26 00 00 00       	mov    $0x26,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <container_init>:
SYSCALL(container_init)
 4e8:	b8 27 00 00 00       	mov    $0x27,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <cont_proc_set>:
SYSCALL(cont_proc_set)
 4f0:	b8 28 00 00 00       	mov    $0x28,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <ps>:
SYSCALL(ps)
 4f8:	b8 29 00 00 00       	mov    $0x29,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 500:	b8 2a 00 00 00       	mov    $0x2a,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <set_root_inode>:
SYSCALL(set_root_inode)
 508:	b8 2b 00 00 00       	mov    $0x2b,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <cstop>:
SYSCALL(cstop)
 510:	b8 2c 00 00 00       	mov    $0x2c,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <df>:
SYSCALL(df)
 518:	b8 2d 00 00 00       	mov    $0x2d,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <max_containers>:
SYSCALL(max_containers)
 520:	b8 2e 00 00 00       	mov    $0x2e,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <container_reset>:
SYSCALL(container_reset)
 528:	b8 2f 00 00 00       	mov    $0x2f,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <pause>:
SYSCALL(pause)
 530:	b8 30 00 00 00       	mov    $0x30,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <resume>:
SYSCALL(resume)
 538:	b8 31 00 00 00       	mov    $0x31,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <tmem>:
SYSCALL(tmem)
 540:	b8 32 00 00 00       	mov    $0x32,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <amem>:
SYSCALL(amem)
 548:	b8 33 00 00 00       	mov    $0x33,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <c_ps>:
SYSCALL(c_ps)
 550:	b8 34 00 00 00       	mov    $0x34,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <get_used>:
SYSCALL(get_used)
 558:	b8 35 00 00 00       	mov    $0x35,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <get_os>:
SYSCALL(get_os)
 560:	b8 36 00 00 00       	mov    $0x36,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <set_os>:
SYSCALL(set_os)
 568:	b8 37 00 00 00       	mov    $0x37,%eax
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
 591:	e8 4a fe ff ff       	call   3e0 <write>
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
 5e9:	8a 80 d4 0c 00 00    	mov    0xcd4(%eax),%al
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
 744:	c7 45 f4 64 0a 00 00 	movl   $0xa64,-0xc(%ebp)
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
 80b:	a1 f0 0c 00 00       	mov    0xcf0,%eax
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
 8d6:	a3 f0 0c 00 00       	mov    %eax,0xcf0
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
 8fc:	e8 47 fb ff ff       	call   448 <sbrk>
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
 92e:	a1 f0 0c 00 00       	mov    0xcf0,%eax
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
 948:	a1 f0 0c 00 00       	mov    0xcf0,%eax
 94d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 954:	75 23                	jne    979 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 956:	c7 45 f0 e8 0c 00 00 	movl   $0xce8,-0x10(%ebp)
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	a3 f0 0c 00 00       	mov    %eax,0xcf0
 965:	a1 f0 0c 00 00       	mov    0xcf0,%eax
 96a:	a3 e8 0c 00 00       	mov    %eax,0xce8
    base.s.size = 0;
 96f:	c7 05 ec 0c 00 00 00 	movl   $0x0,0xcec
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
 9cc:	a3 f0 0c 00 00       	mov    %eax,0xcf0
      return (void*)(p + 1);
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	83 c0 08             	add    $0x8,%eax
 9d7:	eb 38                	jmp    a11 <malloc+0xdc>
    }
    if(p == freep)
 9d9:	a1 f0 0c 00 00       	mov    0xcf0,%eax
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
