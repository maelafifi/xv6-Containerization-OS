
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  write(fd, s, strlen(s));
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	89 04 24             	mov    %eax,(%esp)
   c:	e8 8e 01 00 00       	call   19f <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 45 04 00 00       	call   46c <write>
}
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
  2f:	c7 44 24 04 ec 05 00 	movl   $0x5ec,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 1e                	jmp    6a <forktest+0x41>
    pid = fork();
  4c:	e8 f3 03 00 00       	call   444 <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	79 02                	jns    5c <forktest+0x33>
      break;
  5a:	eb 17                	jmp    73 <forktest+0x4a>
    if(pid == 0)
  5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  60:	75 05                	jne    67 <forktest+0x3e>
      exit();
  62:	e8 e5 03 00 00       	call   44c <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  67:	ff 45 f4             	incl   -0xc(%ebp)
  6a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  71:	7e d9                	jle    4c <forktest+0x23>
      break;
    if(pid == 0)
      exit();
  }

  if(n == N){
  73:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  7a:	75 21                	jne    9d <forktest+0x74>
    printf(1, "fork claimed to work N times!\n", N);
  7c:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  83:	00 
  84:	c7 44 24 04 f8 05 00 	movl   $0x5f8,0x4(%esp)
  8b:	00 
  8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  93:	e8 68 ff ff ff       	call   0 <printf>
    exit();
  98:	e8 af 03 00 00       	call   44c <exit>
  }

  for(; n > 0; n--){
  9d:	eb 25                	jmp    c4 <forktest+0x9b>
    if(wait() < 0){
  9f:	e8 b0 03 00 00       	call   454 <wait>
  a4:	85 c0                	test   %eax,%eax
  a6:	79 19                	jns    c1 <forktest+0x98>
      printf(1, "wait stopped early\n");
  a8:	c7 44 24 04 17 06 00 	movl   $0x617,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 44 ff ff ff       	call   0 <printf>
      exit();
  bc:	e8 8b 03 00 00       	call   44c <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
  c1:	ff 4d f4             	decl   -0xc(%ebp)
  c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c8:	7f d5                	jg     9f <forktest+0x76>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
  ca:	e8 85 03 00 00       	call   454 <wait>
  cf:	83 f8 ff             	cmp    $0xffffffff,%eax
  d2:	74 19                	je     ed <forktest+0xc4>
    printf(1, "wait got too many\n");
  d4:	c7 44 24 04 2b 06 00 	movl   $0x62b,0x4(%esp)
  db:	00 
  dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e3:	e8 18 ff ff ff       	call   0 <printf>
    exit();
  e8:	e8 5f 03 00 00       	call   44c <exit>
  }

  printf(1, "fork test OK\n");
  ed:	c7 44 24 04 3e 06 00 	movl   $0x63e,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 ff fe ff ff       	call   0 <printf>
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <main>:

int
main(void)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
 109:	e8 1b ff ff ff       	call   29 <forktest>
  exit();
 10e:	e8 39 03 00 00       	call   44c <exit>
 113:	90                   	nop

00000114 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	57                   	push   %edi
 118:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 119:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11c:	8b 55 10             	mov    0x10(%ebp),%edx
 11f:	8b 45 0c             	mov    0xc(%ebp),%eax
 122:	89 cb                	mov    %ecx,%ebx
 124:	89 df                	mov    %ebx,%edi
 126:	89 d1                	mov    %edx,%ecx
 128:	fc                   	cld    
 129:	f3 aa                	rep stos %al,%es:(%edi)
 12b:	89 ca                	mov    %ecx,%edx
 12d:	89 fb                	mov    %edi,%ebx
 12f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 132:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 135:	5b                   	pop    %ebx
 136:	5f                   	pop    %edi
 137:	5d                   	pop    %ebp
 138:	c3                   	ret    

00000139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 145:	90                   	nop
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	8d 50 01             	lea    0x1(%eax),%edx
 14c:	89 55 08             	mov    %edx,0x8(%ebp)
 14f:	8b 55 0c             	mov    0xc(%ebp),%edx
 152:	8d 4a 01             	lea    0x1(%edx),%ecx
 155:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 158:	8a 12                	mov    (%edx),%dl
 15a:	88 10                	mov    %dl,(%eax)
 15c:	8a 00                	mov    (%eax),%al
 15e:	84 c0                	test   %al,%al
 160:	75 e4                	jne    146 <strcpy+0xd>
    ;
  return os;
 162:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 165:	c9                   	leave  
 166:	c3                   	ret    

00000167 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16a:	eb 06                	jmp    172 <strcmp+0xb>
    p++, q++;
 16c:	ff 45 08             	incl   0x8(%ebp)
 16f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	8a 00                	mov    (%eax),%al
 177:	84 c0                	test   %al,%al
 179:	74 0e                	je     189 <strcmp+0x22>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	8a 10                	mov    (%eax),%dl
 180:	8b 45 0c             	mov    0xc(%ebp),%eax
 183:	8a 00                	mov    (%eax),%al
 185:	38 c2                	cmp    %al,%dl
 187:	74 e3                	je     16c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	8a 00                	mov    (%eax),%al
 18e:	0f b6 d0             	movzbl %al,%edx
 191:	8b 45 0c             	mov    0xc(%ebp),%eax
 194:	8a 00                	mov    (%eax),%al
 196:	0f b6 c0             	movzbl %al,%eax
 199:	29 c2                	sub    %eax,%edx
 19b:	89 d0                	mov    %edx,%eax
}
 19d:	5d                   	pop    %ebp
 19e:	c3                   	ret    

0000019f <strlen>:

uint
strlen(char *s)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1ac:	eb 03                	jmp    1b1 <strlen+0x12>
 1ae:	ff 45 fc             	incl   -0x4(%ebp)
 1b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b4:	8b 45 08             	mov    0x8(%ebp),%eax
 1b7:	01 d0                	add    %edx,%eax
 1b9:	8a 00                	mov    (%eax),%al
 1bb:	84 c0                	test   %al,%al
 1bd:	75 ef                	jne    1ae <strlen+0xf>
    ;
  return n;
 1bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c2:	c9                   	leave  
 1c3:	c3                   	ret    

000001c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1ca:	8b 45 10             	mov    0x10(%ebp),%eax
 1cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
 1db:	89 04 24             	mov    %eax,(%esp)
 1de:	e8 31 ff ff ff       	call   114 <stosb>
  return dst;
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e6:	c9                   	leave  
 1e7:	c3                   	ret    

000001e8 <strchr>:

char*
strchr(const char *s, char c)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	83 ec 04             	sub    $0x4,%esp
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f4:	eb 12                	jmp    208 <strchr+0x20>
    if(*s == c)
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	8a 00                	mov    (%eax),%al
 1fb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1fe:	75 05                	jne    205 <strchr+0x1d>
      return (char*)s;
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	eb 11                	jmp    216 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 205:	ff 45 08             	incl   0x8(%ebp)
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	8a 00                	mov    (%eax),%al
 20d:	84 c0                	test   %al,%al
 20f:	75 e5                	jne    1f6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 211:	b8 00 00 00 00       	mov    $0x0,%eax
}
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <gets>:

char*
gets(char *buf, int max)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 225:	eb 49                	jmp    270 <gets+0x58>
    cc = read(0, &c, 1);
 227:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 22e:	00 
 22f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 232:	89 44 24 04          	mov    %eax,0x4(%esp)
 236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 23d:	e8 22 02 00 00       	call   464 <read>
 242:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 245:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 249:	7f 02                	jg     24d <gets+0x35>
      break;
 24b:	eb 2c                	jmp    279 <gets+0x61>
    buf[i++] = c;
 24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 250:	8d 50 01             	lea    0x1(%eax),%edx
 253:	89 55 f4             	mov    %edx,-0xc(%ebp)
 256:	89 c2                	mov    %eax,%edx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	01 c2                	add    %eax,%edx
 25d:	8a 45 ef             	mov    -0x11(%ebp),%al
 260:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 262:	8a 45 ef             	mov    -0x11(%ebp),%al
 265:	3c 0a                	cmp    $0xa,%al
 267:	74 10                	je     279 <gets+0x61>
 269:	8a 45 ef             	mov    -0x11(%ebp),%al
 26c:	3c 0d                	cmp    $0xd,%al
 26e:	74 09                	je     279 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 270:	8b 45 f4             	mov    -0xc(%ebp),%eax
 273:	40                   	inc    %eax
 274:	3b 45 0c             	cmp    0xc(%ebp),%eax
 277:	7c ae                	jl     227 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 279:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 284:	8b 45 08             	mov    0x8(%ebp),%eax
}
 287:	c9                   	leave  
 288:	c3                   	ret    

00000289 <stat>:

int
stat(char *n, struct stat *st)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 296:	00 
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 ea 01 00 00       	call   48c <open>
 2a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a9:	79 07                	jns    2b2 <stat+0x29>
    return -1;
 2ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b0:	eb 23                	jmp    2d5 <stat+0x4c>
  r = fstat(fd, st);
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bc:	89 04 24             	mov    %eax,(%esp)
 2bf:	e8 e0 01 00 00       	call   4a4 <fstat>
 2c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 a2 01 00 00       	call   474 <close>
  return r;
 2d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d5:	c9                   	leave  
 2d6:	c3                   	ret    

000002d7 <atoi>:

int
atoi(const char *s)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e4:	eb 24                	jmp    30a <atoi+0x33>
    n = n*10 + *s++ - '0';
 2e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e9:	89 d0                	mov    %edx,%eax
 2eb:	c1 e0 02             	shl    $0x2,%eax
 2ee:	01 d0                	add    %edx,%eax
 2f0:	01 c0                	add    %eax,%eax
 2f2:	89 c1                	mov    %eax,%ecx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	8d 50 01             	lea    0x1(%eax),%edx
 2fa:	89 55 08             	mov    %edx,0x8(%ebp)
 2fd:	8a 00                	mov    (%eax),%al
 2ff:	0f be c0             	movsbl %al,%eax
 302:	01 c8                	add    %ecx,%eax
 304:	83 e8 30             	sub    $0x30,%eax
 307:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	8a 00                	mov    (%eax),%al
 30f:	3c 2f                	cmp    $0x2f,%al
 311:	7e 09                	jle    31c <atoi+0x45>
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	8a 00                	mov    (%eax),%al
 318:	3c 39                	cmp    $0x39,%al
 31a:	7e ca                	jle    2e6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 31c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31f:	c9                   	leave  
 320:	c3                   	ret    

00000321 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
 324:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32d:	8b 45 0c             	mov    0xc(%ebp),%eax
 330:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 333:	eb 16                	jmp    34b <memmove+0x2a>
    *dst++ = *src++;
 335:	8b 45 fc             	mov    -0x4(%ebp),%eax
 338:	8d 50 01             	lea    0x1(%eax),%edx
 33b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 33e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 341:	8d 4a 01             	lea    0x1(%edx),%ecx
 344:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 347:	8a 12                	mov    (%edx),%dl
 349:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 34b:	8b 45 10             	mov    0x10(%ebp),%eax
 34e:	8d 50 ff             	lea    -0x1(%eax),%edx
 351:	89 55 10             	mov    %edx,0x10(%ebp)
 354:	85 c0                	test   %eax,%eax
 356:	7f dd                	jg     335 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 358:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35b:	c9                   	leave  
 35c:	c3                   	ret    

0000035d <itoa>:

int itoa(int value, char *sp, int radix)
{
 35d:	55                   	push   %ebp
 35e:	89 e5                	mov    %esp,%ebp
 360:	53                   	push   %ebx
 361:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 364:	8d 45 d8             	lea    -0x28(%ebp),%eax
 367:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 36a:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 36e:	75 0d                	jne    37d <itoa+0x20>
 370:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 374:	79 07                	jns    37d <itoa+0x20>
 376:	b8 01 00 00 00       	mov    $0x1,%eax
 37b:	eb 05                	jmp    382 <itoa+0x25>
 37d:	b8 00 00 00 00       	mov    $0x0,%eax
 382:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 385:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 389:	74 0a                	je     395 <itoa+0x38>
      v = -value;
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	f7 d8                	neg    %eax
 390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 393:	eb 54                	jmp    3e9 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 395:	8b 45 08             	mov    0x8(%ebp),%eax
 398:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 39b:	eb 4c                	jmp    3e9 <itoa+0x8c>
  {
    i = v % radix;
 39d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a3:	ba 00 00 00 00       	mov    $0x0,%edx
 3a8:	f7 f1                	div    %ecx
 3aa:	89 d0                	mov    %edx,%eax
 3ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 3af:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b5:	ba 00 00 00 00       	mov    $0x0,%edx
 3ba:	f7 f3                	div    %ebx
 3bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 3bf:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 3c3:	7f 13                	jg     3d8 <itoa+0x7b>
      *tp++ = i+'0';
 3c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3c8:	8d 50 01             	lea    0x1(%eax),%edx
 3cb:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3d1:	83 c2 30             	add    $0x30,%edx
 3d4:	88 10                	mov    %dl,(%eax)
 3d6:	eb 11                	jmp    3e9 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 3d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3db:	8d 50 01             	lea    0x1(%eax),%edx
 3de:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3e4:	83 c2 57             	add    $0x57,%edx
 3e7:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 3e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3ed:	75 ae                	jne    39d <itoa+0x40>
 3ef:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3f2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3f5:	74 a6                	je     39d <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 3f7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3fa:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3fd:	29 c2                	sub    %eax,%edx
 3ff:	89 d0                	mov    %edx,%eax
 401:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 404:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 408:	74 11                	je     41b <itoa+0xbe>
  {
    *sp++ = '-';
 40a:	8b 45 0c             	mov    0xc(%ebp),%eax
 40d:	8d 50 01             	lea    0x1(%eax),%edx
 410:	89 55 0c             	mov    %edx,0xc(%ebp)
 413:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 416:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 419:	eb 15                	jmp    430 <itoa+0xd3>
 41b:	eb 13                	jmp    430 <itoa+0xd3>
    *sp++ = *--tp;
 41d:	8b 45 0c             	mov    0xc(%ebp),%eax
 420:	8d 50 01             	lea    0x1(%eax),%edx
 423:	89 55 0c             	mov    %edx,0xc(%ebp)
 426:	ff 4d f8             	decl   -0x8(%ebp)
 429:	8b 55 f8             	mov    -0x8(%ebp),%edx
 42c:	8a 12                	mov    (%edx),%dl
 42e:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 430:	8d 45 d8             	lea    -0x28(%ebp),%eax
 433:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 436:	77 e5                	ja     41d <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 438:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 43b:	83 c4 30             	add    $0x30,%esp
 43e:	5b                   	pop    %ebx
 43f:	5d                   	pop    %ebp
 440:	c3                   	ret    
 441:	90                   	nop
 442:	90                   	nop
 443:	90                   	nop

00000444 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 444:	b8 01 00 00 00       	mov    $0x1,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <exit>:
SYSCALL(exit)
 44c:	b8 02 00 00 00       	mov    $0x2,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <wait>:
SYSCALL(wait)
 454:	b8 03 00 00 00       	mov    $0x3,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <pipe>:
SYSCALL(pipe)
 45c:	b8 04 00 00 00       	mov    $0x4,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <read>:
SYSCALL(read)
 464:	b8 05 00 00 00       	mov    $0x5,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <write>:
SYSCALL(write)
 46c:	b8 10 00 00 00       	mov    $0x10,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <close>:
SYSCALL(close)
 474:	b8 15 00 00 00       	mov    $0x15,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <kill>:
SYSCALL(kill)
 47c:	b8 06 00 00 00       	mov    $0x6,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <exec>:
SYSCALL(exec)
 484:	b8 07 00 00 00       	mov    $0x7,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <open>:
SYSCALL(open)
 48c:	b8 0f 00 00 00       	mov    $0xf,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <mknod>:
SYSCALL(mknod)
 494:	b8 11 00 00 00       	mov    $0x11,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <unlink>:
SYSCALL(unlink)
 49c:	b8 12 00 00 00       	mov    $0x12,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <fstat>:
SYSCALL(fstat)
 4a4:	b8 08 00 00 00       	mov    $0x8,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <link>:
SYSCALL(link)
 4ac:	b8 13 00 00 00       	mov    $0x13,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <mkdir>:
SYSCALL(mkdir)
 4b4:	b8 14 00 00 00       	mov    $0x14,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <chdir>:
SYSCALL(chdir)
 4bc:	b8 09 00 00 00       	mov    $0x9,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <dup>:
SYSCALL(dup)
 4c4:	b8 0a 00 00 00       	mov    $0xa,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <getpid>:
SYSCALL(getpid)
 4cc:	b8 0b 00 00 00       	mov    $0xb,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <sbrk>:
SYSCALL(sbrk)
 4d4:	b8 0c 00 00 00       	mov    $0xc,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <sleep>:
SYSCALL(sleep)
 4dc:	b8 0d 00 00 00       	mov    $0xd,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <uptime>:
SYSCALL(uptime)
 4e4:	b8 0e 00 00 00       	mov    $0xe,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <getticks>:
SYSCALL(getticks)
 4ec:	b8 16 00 00 00       	mov    $0x16,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <get_name>:
SYSCALL(get_name)
 4f4:	b8 17 00 00 00       	mov    $0x17,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <get_max_proc>:
SYSCALL(get_max_proc)
 4fc:	b8 18 00 00 00       	mov    $0x18,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <get_max_mem>:
SYSCALL(get_max_mem)
 504:	b8 19 00 00 00       	mov    $0x19,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <get_max_disk>:
SYSCALL(get_max_disk)
 50c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <get_curr_proc>:
SYSCALL(get_curr_proc)
 514:	b8 1b 00 00 00       	mov    $0x1b,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <get_curr_mem>:
SYSCALL(get_curr_mem)
 51c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <get_curr_disk>:
SYSCALL(get_curr_disk)
 524:	b8 1d 00 00 00       	mov    $0x1d,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <set_name>:
SYSCALL(set_name)
 52c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <set_max_mem>:
SYSCALL(set_max_mem)
 534:	b8 1f 00 00 00       	mov    $0x1f,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <set_max_disk>:
SYSCALL(set_max_disk)
 53c:	b8 20 00 00 00       	mov    $0x20,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <set_max_proc>:
SYSCALL(set_max_proc)
 544:	b8 21 00 00 00       	mov    $0x21,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <set_curr_mem>:
SYSCALL(set_curr_mem)
 54c:	b8 22 00 00 00       	mov    $0x22,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <set_curr_disk>:
SYSCALL(set_curr_disk)
 554:	b8 23 00 00 00       	mov    $0x23,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <set_curr_proc>:
SYSCALL(set_curr_proc)
 55c:	b8 24 00 00 00       	mov    $0x24,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <find>:
SYSCALL(find)
 564:	b8 25 00 00 00       	mov    $0x25,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <is_full>:
SYSCALL(is_full)
 56c:	b8 26 00 00 00       	mov    $0x26,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <container_init>:
SYSCALL(container_init)
 574:	b8 27 00 00 00       	mov    $0x27,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <cont_proc_set>:
SYSCALL(cont_proc_set)
 57c:	b8 28 00 00 00       	mov    $0x28,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <ps>:
SYSCALL(ps)
 584:	b8 29 00 00 00       	mov    $0x29,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 58c:	b8 2a 00 00 00       	mov    $0x2a,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <set_root_inode>:
SYSCALL(set_root_inode)
 594:	b8 2b 00 00 00       	mov    $0x2b,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <cstop>:
SYSCALL(cstop)
 59c:	b8 2c 00 00 00       	mov    $0x2c,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <df>:
SYSCALL(df)
 5a4:	b8 2d 00 00 00       	mov    $0x2d,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <max_containers>:
SYSCALL(max_containers)
 5ac:	b8 2e 00 00 00       	mov    $0x2e,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <container_reset>:
SYSCALL(container_reset)
 5b4:	b8 2f 00 00 00       	mov    $0x2f,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <pause>:
SYSCALL(pause)
 5bc:	b8 30 00 00 00       	mov    $0x30,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <resume>:
SYSCALL(resume)
 5c4:	b8 31 00 00 00       	mov    $0x31,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <tmem>:
SYSCALL(tmem)
 5cc:	b8 32 00 00 00       	mov    $0x32,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <amem>:
SYSCALL(amem)
 5d4:	b8 33 00 00 00       	mov    $0x33,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <c_ps>:
SYSCALL(c_ps)
 5dc:	b8 34 00 00 00       	mov    $0x34,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <get_used>:
SYSCALL(get_used)
 5e4:	b8 35 00 00 00       	mov    $0x35,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    
