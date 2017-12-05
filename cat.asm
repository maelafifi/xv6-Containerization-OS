
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   6:	eb 39                	jmp    41 <cat+0x41>
    if (write(1, buf, n) != n) {
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 e0 0d 00 	movl   $0xde0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 71 04 00 00       	call   494 <write>
  23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  26:	74 19                	je     41 <cat+0x41>
      printf(1, "cat: write error\n");
  28:	c7 44 24 04 c7 0a 00 	movl   $0xac7,0x4(%esp)
  2f:	00 
  30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  37:	e8 c5 06 00 00       	call   701 <printf>
      exit();
  3c:	e8 33 04 00 00       	call   474 <exit>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  41:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  48:	00 
  49:	c7 44 24 04 e0 0d 00 	movl   $0xde0,0x4(%esp)
  50:	00 
  51:	8b 45 08             	mov    0x8(%ebp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 30 04 00 00       	call   48c <read>
  5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  63:	7f a3                	jg     8 <cat+0x8>
    if (write(1, buf, n) != n) {
      printf(1, "cat: write error\n");
      exit();
    }
  }
  if(n < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <cat+0x84>
    printf(1, "cat: read error\n");
  6b:	c7 44 24 04 d9 0a 00 	movl   $0xad9,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 82 06 00 00       	call   701 <printf>
    exit();
  7f:	e8 f0 03 00 00       	call   474 <exit>
  }
}
  84:	c9                   	leave  
  85:	c3                   	ret    

00000086 <main>:

int
main(int argc, char *argv[])
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	83 e4 f0             	and    $0xfffffff0,%esp
  8c:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  8f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  93:	7f 11                	jg     a6 <main+0x20>
    cat(0);
  95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  9c:	e8 5f ff ff ff       	call   0 <cat>
    exit();
  a1:	e8 ce 03 00 00       	call   474 <exit>
  }

  for(i = 1; i < argc; i++){
  a6:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  ad:	00 
  ae:	eb 78                	jmp    128 <main+0xa2>
    if((fd = open(argv[i], 0)) < 0){
  b0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  be:	01 d0                	add    %edx,%eax
  c0:	8b 00                	mov    (%eax),%eax
  c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c9:	00 
  ca:	89 04 24             	mov    %eax,(%esp)
  cd:	e8 e2 03 00 00       	call   4b4 <open>
  d2:	89 44 24 18          	mov    %eax,0x18(%esp)
  d6:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  db:	79 2f                	jns    10c <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  dd:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  eb:	01 d0                	add    %edx,%eax
  ed:	8b 00                	mov    (%eax),%eax
  ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  f3:	c7 44 24 04 ea 0a 00 	movl   $0xaea,0x4(%esp)
  fa:	00 
  fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 102:	e8 fa 05 00 00       	call   701 <printf>
      exit();
 107:	e8 68 03 00 00       	call   474 <exit>
    }
    cat(fd);
 10c:	8b 44 24 18          	mov    0x18(%esp),%eax
 110:	89 04 24             	mov    %eax,(%esp)
 113:	e8 e8 fe ff ff       	call   0 <cat>
    close(fd);
 118:	8b 44 24 18          	mov    0x18(%esp),%eax
 11c:	89 04 24             	mov    %eax,(%esp)
 11f:	e8 78 03 00 00       	call   49c <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
 124:	ff 44 24 1c          	incl   0x1c(%esp)
 128:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 12c:	3b 45 08             	cmp    0x8(%ebp),%eax
 12f:	0f 8c 7b ff ff ff    	jl     b0 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 135:	e8 3a 03 00 00       	call   474 <exit>
 13a:	90                   	nop
 13b:	90                   	nop

0000013c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	57                   	push   %edi
 140:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 141:	8b 4d 08             	mov    0x8(%ebp),%ecx
 144:	8b 55 10             	mov    0x10(%ebp),%edx
 147:	8b 45 0c             	mov    0xc(%ebp),%eax
 14a:	89 cb                	mov    %ecx,%ebx
 14c:	89 df                	mov    %ebx,%edi
 14e:	89 d1                	mov    %edx,%ecx
 150:	fc                   	cld    
 151:	f3 aa                	rep stos %al,%es:(%edi)
 153:	89 ca                	mov    %ecx,%edx
 155:	89 fb                	mov    %edi,%ebx
 157:	89 5d 08             	mov    %ebx,0x8(%ebp)
 15a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 15d:	5b                   	pop    %ebx
 15e:	5f                   	pop    %edi
 15f:	5d                   	pop    %ebp
 160:	c3                   	ret    

00000161 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 167:	8b 45 08             	mov    0x8(%ebp),%eax
 16a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 16d:	90                   	nop
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	8d 50 01             	lea    0x1(%eax),%edx
 174:	89 55 08             	mov    %edx,0x8(%ebp)
 177:	8b 55 0c             	mov    0xc(%ebp),%edx
 17a:	8d 4a 01             	lea    0x1(%edx),%ecx
 17d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 180:	8a 12                	mov    (%edx),%dl
 182:	88 10                	mov    %dl,(%eax)
 184:	8a 00                	mov    (%eax),%al
 186:	84 c0                	test   %al,%al
 188:	75 e4                	jne    16e <strcpy+0xd>
    ;
  return os;
 18a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 18d:	c9                   	leave  
 18e:	c3                   	ret    

0000018f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 192:	eb 06                	jmp    19a <strcmp+0xb>
    p++, q++;
 194:	ff 45 08             	incl   0x8(%ebp)
 197:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	8a 00                	mov    (%eax),%al
 19f:	84 c0                	test   %al,%al
 1a1:	74 0e                	je     1b1 <strcmp+0x22>
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
 1a6:	8a 10                	mov    (%eax),%dl
 1a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ab:	8a 00                	mov    (%eax),%al
 1ad:	38 c2                	cmp    %al,%dl
 1af:	74 e3                	je     194 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	8a 00                	mov    (%eax),%al
 1b6:	0f b6 d0             	movzbl %al,%edx
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	8a 00                	mov    (%eax),%al
 1be:	0f b6 c0             	movzbl %al,%eax
 1c1:	29 c2                	sub    %eax,%edx
 1c3:	89 d0                	mov    %edx,%eax
}
 1c5:	5d                   	pop    %ebp
 1c6:	c3                   	ret    

000001c7 <strlen>:

uint
strlen(char *s)
{
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1d4:	eb 03                	jmp    1d9 <strlen+0x12>
 1d6:	ff 45 fc             	incl   -0x4(%ebp)
 1d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	01 d0                	add    %edx,%eax
 1e1:	8a 00                	mov    (%eax),%al
 1e3:	84 c0                	test   %al,%al
 1e5:	75 ef                	jne    1d6 <strlen+0xf>
    ;
  return n;
 1e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ea:	c9                   	leave  
 1eb:	c3                   	ret    

000001ec <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1f2:	8b 45 10             	mov    0x10(%ebp),%eax
 1f5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	89 04 24             	mov    %eax,(%esp)
 206:	e8 31 ff ff ff       	call   13c <stosb>
  return dst;
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20e:	c9                   	leave  
 20f:	c3                   	ret    

00000210 <strchr>:

char*
strchr(const char *s, char c)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	83 ec 04             	sub    $0x4,%esp
 216:	8b 45 0c             	mov    0xc(%ebp),%eax
 219:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 21c:	eb 12                	jmp    230 <strchr+0x20>
    if(*s == c)
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	8a 00                	mov    (%eax),%al
 223:	3a 45 fc             	cmp    -0x4(%ebp),%al
 226:	75 05                	jne    22d <strchr+0x1d>
      return (char*)s;
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	eb 11                	jmp    23e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 22d:	ff 45 08             	incl   0x8(%ebp)
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	8a 00                	mov    (%eax),%al
 235:	84 c0                	test   %al,%al
 237:	75 e5                	jne    21e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 239:	b8 00 00 00 00       	mov    $0x0,%eax
}
 23e:	c9                   	leave  
 23f:	c3                   	ret    

00000240 <gets>:

char*
gets(char *buf, int max)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 246:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 24d:	eb 49                	jmp    298 <gets+0x58>
    cc = read(0, &c, 1);
 24f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 256:	00 
 257:	8d 45 ef             	lea    -0x11(%ebp),%eax
 25a:	89 44 24 04          	mov    %eax,0x4(%esp)
 25e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 265:	e8 22 02 00 00       	call   48c <read>
 26a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 26d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 271:	7f 02                	jg     275 <gets+0x35>
      break;
 273:	eb 2c                	jmp    2a1 <gets+0x61>
    buf[i++] = c;
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	8d 50 01             	lea    0x1(%eax),%edx
 27b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 27e:	89 c2                	mov    %eax,%edx
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	01 c2                	add    %eax,%edx
 285:	8a 45 ef             	mov    -0x11(%ebp),%al
 288:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 28a:	8a 45 ef             	mov    -0x11(%ebp),%al
 28d:	3c 0a                	cmp    $0xa,%al
 28f:	74 10                	je     2a1 <gets+0x61>
 291:	8a 45 ef             	mov    -0x11(%ebp),%al
 294:	3c 0d                	cmp    $0xd,%al
 296:	74 09                	je     2a1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 298:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29b:	40                   	inc    %eax
 29c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 29f:	7c ae                	jl     24f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	01 d0                	add    %edx,%eax
 2a9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave  
 2b0:	c3                   	ret    

000002b1 <stat>:

int
stat(char *n, struct stat *st)
{
 2b1:	55                   	push   %ebp
 2b2:	89 e5                	mov    %esp,%ebp
 2b4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2be:	00 
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	89 04 24             	mov    %eax,(%esp)
 2c5:	e8 ea 01 00 00       	call   4b4 <open>
 2ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d1:	79 07                	jns    2da <stat+0x29>
    return -1;
 2d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d8:	eb 23                	jmp    2fd <stat+0x4c>
  r = fstat(fd, st);
 2da:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e4:	89 04 24             	mov    %eax,(%esp)
 2e7:	e8 e0 01 00 00       	call   4cc <fstat>
 2ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f2:	89 04 24             	mov    %eax,(%esp)
 2f5:	e8 a2 01 00 00       	call   49c <close>
  return r;
 2fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2fd:	c9                   	leave  
 2fe:	c3                   	ret    

000002ff <atoi>:

int
atoi(const char *s)
{
 2ff:	55                   	push   %ebp
 300:	89 e5                	mov    %esp,%ebp
 302:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 305:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 30c:	eb 24                	jmp    332 <atoi+0x33>
    n = n*10 + *s++ - '0';
 30e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 311:	89 d0                	mov    %edx,%eax
 313:	c1 e0 02             	shl    $0x2,%eax
 316:	01 d0                	add    %edx,%eax
 318:	01 c0                	add    %eax,%eax
 31a:	89 c1                	mov    %eax,%ecx
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	8d 50 01             	lea    0x1(%eax),%edx
 322:	89 55 08             	mov    %edx,0x8(%ebp)
 325:	8a 00                	mov    (%eax),%al
 327:	0f be c0             	movsbl %al,%eax
 32a:	01 c8                	add    %ecx,%eax
 32c:	83 e8 30             	sub    $0x30,%eax
 32f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	8a 00                	mov    (%eax),%al
 337:	3c 2f                	cmp    $0x2f,%al
 339:	7e 09                	jle    344 <atoi+0x45>
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	8a 00                	mov    (%eax),%al
 340:	3c 39                	cmp    $0x39,%al
 342:	7e ca                	jle    30e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 344:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 355:	8b 45 0c             	mov    0xc(%ebp),%eax
 358:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 35b:	eb 16                	jmp    373 <memmove+0x2a>
    *dst++ = *src++;
 35d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 360:	8d 50 01             	lea    0x1(%eax),%edx
 363:	89 55 fc             	mov    %edx,-0x4(%ebp)
 366:	8b 55 f8             	mov    -0x8(%ebp),%edx
 369:	8d 4a 01             	lea    0x1(%edx),%ecx
 36c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 36f:	8a 12                	mov    (%edx),%dl
 371:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 373:	8b 45 10             	mov    0x10(%ebp),%eax
 376:	8d 50 ff             	lea    -0x1(%eax),%edx
 379:	89 55 10             	mov    %edx,0x10(%ebp)
 37c:	85 c0                	test   %eax,%eax
 37e:	7f dd                	jg     35d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
}
 383:	c9                   	leave  
 384:	c3                   	ret    

00000385 <itoa>:

int itoa(int value, char *sp, int radix)
{
 385:	55                   	push   %ebp
 386:	89 e5                	mov    %esp,%ebp
 388:	53                   	push   %ebx
 389:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 38c:	8d 45 d8             	lea    -0x28(%ebp),%eax
 38f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 392:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 396:	75 0d                	jne    3a5 <itoa+0x20>
 398:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 39c:	79 07                	jns    3a5 <itoa+0x20>
 39e:	b8 01 00 00 00       	mov    $0x1,%eax
 3a3:	eb 05                	jmp    3aa <itoa+0x25>
 3a5:	b8 00 00 00 00       	mov    $0x0,%eax
 3aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 3ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3b1:	74 0a                	je     3bd <itoa+0x38>
      v = -value;
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	f7 d8                	neg    %eax
 3b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 3bb:	eb 54                	jmp    411 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 3c3:	eb 4c                	jmp    411 <itoa+0x8c>
  {
    i = v % radix;
 3c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cb:	ba 00 00 00 00       	mov    $0x0,%edx
 3d0:	f7 f1                	div    %ecx
 3d2:	89 d0                	mov    %edx,%eax
 3d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 3d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3dd:	ba 00 00 00 00       	mov    $0x0,%edx
 3e2:	f7 f3                	div    %ebx
 3e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 3e7:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 3eb:	7f 13                	jg     400 <itoa+0x7b>
      *tp++ = i+'0';
 3ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f0:	8d 50 01             	lea    0x1(%eax),%edx
 3f3:	89 55 f8             	mov    %edx,-0x8(%ebp)
 3f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3f9:	83 c2 30             	add    $0x30,%edx
 3fc:	88 10                	mov    %dl,(%eax)
 3fe:	eb 11                	jmp    411 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 400:	8b 45 f8             	mov    -0x8(%ebp),%eax
 403:	8d 50 01             	lea    0x1(%eax),%edx
 406:	89 55 f8             	mov    %edx,-0x8(%ebp)
 409:	8b 55 e8             	mov    -0x18(%ebp),%edx
 40c:	83 c2 57             	add    $0x57,%edx
 40f:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 411:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 415:	75 ae                	jne    3c5 <itoa+0x40>
 417:	8d 45 d8             	lea    -0x28(%ebp),%eax
 41a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 41d:	74 a6                	je     3c5 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 41f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 422:	8d 45 d8             	lea    -0x28(%ebp),%eax
 425:	29 c2                	sub    %eax,%edx
 427:	89 d0                	mov    %edx,%eax
 429:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 42c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 430:	74 11                	je     443 <itoa+0xbe>
  {
    *sp++ = '-';
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	8d 50 01             	lea    0x1(%eax),%edx
 438:	89 55 0c             	mov    %edx,0xc(%ebp)
 43b:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 43e:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 441:	eb 15                	jmp    458 <itoa+0xd3>
 443:	eb 13                	jmp    458 <itoa+0xd3>
    *sp++ = *--tp;
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	8d 50 01             	lea    0x1(%eax),%edx
 44b:	89 55 0c             	mov    %edx,0xc(%ebp)
 44e:	ff 4d f8             	decl   -0x8(%ebp)
 451:	8b 55 f8             	mov    -0x8(%ebp),%edx
 454:	8a 12                	mov    (%edx),%dl
 456:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 458:	8d 45 d8             	lea    -0x28(%ebp),%eax
 45b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 45e:	77 e5                	ja     445 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 460:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 463:	83 c4 30             	add    $0x30,%esp
 466:	5b                   	pop    %ebx
 467:	5d                   	pop    %ebp
 468:	c3                   	ret    
 469:	90                   	nop
 46a:	90                   	nop
 46b:	90                   	nop

0000046c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 46c:	b8 01 00 00 00       	mov    $0x1,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <exit>:
SYSCALL(exit)
 474:	b8 02 00 00 00       	mov    $0x2,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <wait>:
SYSCALL(wait)
 47c:	b8 03 00 00 00       	mov    $0x3,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <pipe>:
SYSCALL(pipe)
 484:	b8 04 00 00 00       	mov    $0x4,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <read>:
SYSCALL(read)
 48c:	b8 05 00 00 00       	mov    $0x5,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <write>:
SYSCALL(write)
 494:	b8 10 00 00 00       	mov    $0x10,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <close>:
SYSCALL(close)
 49c:	b8 15 00 00 00       	mov    $0x15,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <kill>:
SYSCALL(kill)
 4a4:	b8 06 00 00 00       	mov    $0x6,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <exec>:
SYSCALL(exec)
 4ac:	b8 07 00 00 00       	mov    $0x7,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <open>:
SYSCALL(open)
 4b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <mknod>:
SYSCALL(mknod)
 4bc:	b8 11 00 00 00       	mov    $0x11,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <unlink>:
SYSCALL(unlink)
 4c4:	b8 12 00 00 00       	mov    $0x12,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <fstat>:
SYSCALL(fstat)
 4cc:	b8 08 00 00 00       	mov    $0x8,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <link>:
SYSCALL(link)
 4d4:	b8 13 00 00 00       	mov    $0x13,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <mkdir>:
SYSCALL(mkdir)
 4dc:	b8 14 00 00 00       	mov    $0x14,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <chdir>:
SYSCALL(chdir)
 4e4:	b8 09 00 00 00       	mov    $0x9,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <dup>:
SYSCALL(dup)
 4ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <getpid>:
SYSCALL(getpid)
 4f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <sbrk>:
SYSCALL(sbrk)
 4fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <sleep>:
SYSCALL(sleep)
 504:	b8 0d 00 00 00       	mov    $0xd,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <uptime>:
SYSCALL(uptime)
 50c:	b8 0e 00 00 00       	mov    $0xe,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <getticks>:
SYSCALL(getticks)
 514:	b8 16 00 00 00       	mov    $0x16,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <get_name>:
SYSCALL(get_name)
 51c:	b8 17 00 00 00       	mov    $0x17,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <get_max_proc>:
SYSCALL(get_max_proc)
 524:	b8 18 00 00 00       	mov    $0x18,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <get_max_mem>:
SYSCALL(get_max_mem)
 52c:	b8 19 00 00 00       	mov    $0x19,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <get_max_disk>:
SYSCALL(get_max_disk)
 534:	b8 1a 00 00 00       	mov    $0x1a,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <get_curr_proc>:
SYSCALL(get_curr_proc)
 53c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <get_curr_mem>:
SYSCALL(get_curr_mem)
 544:	b8 1c 00 00 00       	mov    $0x1c,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <get_curr_disk>:
SYSCALL(get_curr_disk)
 54c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <set_name>:
SYSCALL(set_name)
 554:	b8 1e 00 00 00       	mov    $0x1e,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <set_max_mem>:
SYSCALL(set_max_mem)
 55c:	b8 1f 00 00 00       	mov    $0x1f,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <set_max_disk>:
SYSCALL(set_max_disk)
 564:	b8 20 00 00 00       	mov    $0x20,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <set_max_proc>:
SYSCALL(set_max_proc)
 56c:	b8 21 00 00 00       	mov    $0x21,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <set_curr_mem>:
SYSCALL(set_curr_mem)
 574:	b8 22 00 00 00       	mov    $0x22,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <set_curr_disk>:
SYSCALL(set_curr_disk)
 57c:	b8 23 00 00 00       	mov    $0x23,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <set_curr_proc>:
SYSCALL(set_curr_proc)
 584:	b8 24 00 00 00       	mov    $0x24,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <find>:
SYSCALL(find)
 58c:	b8 25 00 00 00       	mov    $0x25,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <is_full>:
SYSCALL(is_full)
 594:	b8 26 00 00 00       	mov    $0x26,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <container_init>:
SYSCALL(container_init)
 59c:	b8 27 00 00 00       	mov    $0x27,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <cont_proc_set>:
SYSCALL(cont_proc_set)
 5a4:	b8 28 00 00 00       	mov    $0x28,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <ps>:
SYSCALL(ps)
 5ac:	b8 29 00 00 00       	mov    $0x29,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 5b4:	b8 2a 00 00 00       	mov    $0x2a,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <set_root_inode>:
SYSCALL(set_root_inode)
 5bc:	b8 2b 00 00 00       	mov    $0x2b,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <cstop>:
SYSCALL(cstop)
 5c4:	b8 2c 00 00 00       	mov    $0x2c,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <df>:
SYSCALL(df)
 5cc:	b8 2d 00 00 00       	mov    $0x2d,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <max_containers>:
SYSCALL(max_containers)
 5d4:	b8 2e 00 00 00       	mov    $0x2e,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <container_reset>:
SYSCALL(container_reset)
 5dc:	b8 2f 00 00 00       	mov    $0x2f,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <pause>:
SYSCALL(pause)
 5e4:	b8 30 00 00 00       	mov    $0x30,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <resume>:
SYSCALL(resume)
 5ec:	b8 31 00 00 00       	mov    $0x31,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <tmem>:
SYSCALL(tmem)
 5f4:	b8 32 00 00 00       	mov    $0x32,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <amem>:
SYSCALL(amem)
 5fc:	b8 33 00 00 00       	mov    $0x33,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <c_ps>:
SYSCALL(c_ps)
 604:	b8 34 00 00 00       	mov    $0x34,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <get_used>:
SYSCALL(get_used)
 60c:	b8 35 00 00 00       	mov    $0x35,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <get_os>:
SYSCALL(get_os)
 614:	b8 36 00 00 00       	mov    $0x36,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <set_os>:
SYSCALL(set_os)
 61c:	b8 37 00 00 00       	mov    $0x37,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	83 ec 18             	sub    $0x18,%esp
 62a:	8b 45 0c             	mov    0xc(%ebp),%eax
 62d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 630:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 637:	00 
 638:	8d 45 f4             	lea    -0xc(%ebp),%eax
 63b:	89 44 24 04          	mov    %eax,0x4(%esp)
 63f:	8b 45 08             	mov    0x8(%ebp),%eax
 642:	89 04 24             	mov    %eax,(%esp)
 645:	e8 4a fe ff ff       	call   494 <write>
}
 64a:	c9                   	leave  
 64b:	c3                   	ret    

0000064c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 64c:	55                   	push   %ebp
 64d:	89 e5                	mov    %esp,%ebp
 64f:	56                   	push   %esi
 650:	53                   	push   %ebx
 651:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 654:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 65b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 65f:	74 17                	je     678 <printint+0x2c>
 661:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 665:	79 11                	jns    678 <printint+0x2c>
    neg = 1;
 667:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 66e:	8b 45 0c             	mov    0xc(%ebp),%eax
 671:	f7 d8                	neg    %eax
 673:	89 45 ec             	mov    %eax,-0x14(%ebp)
 676:	eb 06                	jmp    67e <printint+0x32>
  } else {
    x = xx;
 678:	8b 45 0c             	mov    0xc(%ebp),%eax
 67b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 67e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 685:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 688:	8d 41 01             	lea    0x1(%ecx),%eax
 68b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 68e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 691:	8b 45 ec             	mov    -0x14(%ebp),%eax
 694:	ba 00 00 00 00       	mov    $0x0,%edx
 699:	f7 f3                	div    %ebx
 69b:	89 d0                	mov    %edx,%eax
 69d:	8a 80 90 0d 00 00    	mov    0xd90(%eax),%al
 6a3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6a7:	8b 75 10             	mov    0x10(%ebp),%esi
 6aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6ad:	ba 00 00 00 00       	mov    $0x0,%edx
 6b2:	f7 f6                	div    %esi
 6b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6bb:	75 c8                	jne    685 <printint+0x39>
  if(neg)
 6bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6c1:	74 10                	je     6d3 <printint+0x87>
    buf[i++] = '-';
 6c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c6:	8d 50 01             	lea    0x1(%eax),%edx
 6c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6cc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6d1:	eb 1e                	jmp    6f1 <printint+0xa5>
 6d3:	eb 1c                	jmp    6f1 <printint+0xa5>
    putc(fd, buf[i]);
 6d5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6db:	01 d0                	add    %edx,%eax
 6dd:	8a 00                	mov    (%eax),%al
 6df:	0f be c0             	movsbl %al,%eax
 6e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	89 04 24             	mov    %eax,(%esp)
 6ec:	e8 33 ff ff ff       	call   624 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6f1:	ff 4d f4             	decl   -0xc(%ebp)
 6f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f8:	79 db                	jns    6d5 <printint+0x89>
    putc(fd, buf[i]);
}
 6fa:	83 c4 30             	add    $0x30,%esp
 6fd:	5b                   	pop    %ebx
 6fe:	5e                   	pop    %esi
 6ff:	5d                   	pop    %ebp
 700:	c3                   	ret    

00000701 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 701:	55                   	push   %ebp
 702:	89 e5                	mov    %esp,%ebp
 704:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 707:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 70e:	8d 45 0c             	lea    0xc(%ebp),%eax
 711:	83 c0 04             	add    $0x4,%eax
 714:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 717:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 71e:	e9 77 01 00 00       	jmp    89a <printf+0x199>
    c = fmt[i] & 0xff;
 723:	8b 55 0c             	mov    0xc(%ebp),%edx
 726:	8b 45 f0             	mov    -0x10(%ebp),%eax
 729:	01 d0                	add    %edx,%eax
 72b:	8a 00                	mov    (%eax),%al
 72d:	0f be c0             	movsbl %al,%eax
 730:	25 ff 00 00 00       	and    $0xff,%eax
 735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 738:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 73c:	75 2c                	jne    76a <printf+0x69>
      if(c == '%'){
 73e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 742:	75 0c                	jne    750 <printf+0x4f>
        state = '%';
 744:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 74b:	e9 47 01 00 00       	jmp    897 <printf+0x196>
      } else {
        putc(fd, c);
 750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 753:	0f be c0             	movsbl %al,%eax
 756:	89 44 24 04          	mov    %eax,0x4(%esp)
 75a:	8b 45 08             	mov    0x8(%ebp),%eax
 75d:	89 04 24             	mov    %eax,(%esp)
 760:	e8 bf fe ff ff       	call   624 <putc>
 765:	e9 2d 01 00 00       	jmp    897 <printf+0x196>
      }
    } else if(state == '%'){
 76a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 76e:	0f 85 23 01 00 00    	jne    897 <printf+0x196>
      if(c == 'd'){
 774:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 778:	75 2d                	jne    7a7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 77a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77d:	8b 00                	mov    (%eax),%eax
 77f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 786:	00 
 787:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 78e:	00 
 78f:	89 44 24 04          	mov    %eax,0x4(%esp)
 793:	8b 45 08             	mov    0x8(%ebp),%eax
 796:	89 04 24             	mov    %eax,(%esp)
 799:	e8 ae fe ff ff       	call   64c <printint>
        ap++;
 79e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a2:	e9 e9 00 00 00       	jmp    890 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 7a7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ab:	74 06                	je     7b3 <printf+0xb2>
 7ad:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7b1:	75 2d                	jne    7e0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 7b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b6:	8b 00                	mov    (%eax),%eax
 7b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7bf:	00 
 7c0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7c7:	00 
 7c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cc:	8b 45 08             	mov    0x8(%ebp),%eax
 7cf:	89 04 24             	mov    %eax,(%esp)
 7d2:	e8 75 fe ff ff       	call   64c <printint>
        ap++;
 7d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7db:	e9 b0 00 00 00       	jmp    890 <printf+0x18f>
      } else if(c == 's'){
 7e0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7e4:	75 42                	jne    828 <printf+0x127>
        s = (char*)*ap;
 7e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e9:	8b 00                	mov    (%eax),%eax
 7eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f6:	75 09                	jne    801 <printf+0x100>
          s = "(null)";
 7f8:	c7 45 f4 ff 0a 00 00 	movl   $0xaff,-0xc(%ebp)
        while(*s != 0){
 7ff:	eb 1c                	jmp    81d <printf+0x11c>
 801:	eb 1a                	jmp    81d <printf+0x11c>
          putc(fd, *s);
 803:	8b 45 f4             	mov    -0xc(%ebp),%eax
 806:	8a 00                	mov    (%eax),%al
 808:	0f be c0             	movsbl %al,%eax
 80b:	89 44 24 04          	mov    %eax,0x4(%esp)
 80f:	8b 45 08             	mov    0x8(%ebp),%eax
 812:	89 04 24             	mov    %eax,(%esp)
 815:	e8 0a fe ff ff       	call   624 <putc>
          s++;
 81a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 81d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 820:	8a 00                	mov    (%eax),%al
 822:	84 c0                	test   %al,%al
 824:	75 dd                	jne    803 <printf+0x102>
 826:	eb 68                	jmp    890 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 828:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 82c:	75 1d                	jne    84b <printf+0x14a>
        putc(fd, *ap);
 82e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 831:	8b 00                	mov    (%eax),%eax
 833:	0f be c0             	movsbl %al,%eax
 836:	89 44 24 04          	mov    %eax,0x4(%esp)
 83a:	8b 45 08             	mov    0x8(%ebp),%eax
 83d:	89 04 24             	mov    %eax,(%esp)
 840:	e8 df fd ff ff       	call   624 <putc>
        ap++;
 845:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 849:	eb 45                	jmp    890 <printf+0x18f>
      } else if(c == '%'){
 84b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84f:	75 17                	jne    868 <printf+0x167>
        putc(fd, c);
 851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 854:	0f be c0             	movsbl %al,%eax
 857:	89 44 24 04          	mov    %eax,0x4(%esp)
 85b:	8b 45 08             	mov    0x8(%ebp),%eax
 85e:	89 04 24             	mov    %eax,(%esp)
 861:	e8 be fd ff ff       	call   624 <putc>
 866:	eb 28                	jmp    890 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 868:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 86f:	00 
 870:	8b 45 08             	mov    0x8(%ebp),%eax
 873:	89 04 24             	mov    %eax,(%esp)
 876:	e8 a9 fd ff ff       	call   624 <putc>
        putc(fd, c);
 87b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 87e:	0f be c0             	movsbl %al,%eax
 881:	89 44 24 04          	mov    %eax,0x4(%esp)
 885:	8b 45 08             	mov    0x8(%ebp),%eax
 888:	89 04 24             	mov    %eax,(%esp)
 88b:	e8 94 fd ff ff       	call   624 <putc>
      }
      state = 0;
 890:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 897:	ff 45 f0             	incl   -0x10(%ebp)
 89a:	8b 55 0c             	mov    0xc(%ebp),%edx
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	01 d0                	add    %edx,%eax
 8a2:	8a 00                	mov    (%eax),%al
 8a4:	84 c0                	test   %al,%al
 8a6:	0f 85 77 fe ff ff    	jne    723 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8ac:	c9                   	leave  
 8ad:	c3                   	ret    
 8ae:	90                   	nop
 8af:	90                   	nop

000008b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b0:	55                   	push   %ebp
 8b1:	89 e5                	mov    %esp,%ebp
 8b3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b6:	8b 45 08             	mov    0x8(%ebp),%eax
 8b9:	83 e8 08             	sub    $0x8,%eax
 8bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bf:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 8c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c7:	eb 24                	jmp    8ed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d1:	77 12                	ja     8e5 <free+0x35>
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d9:	77 24                	ja     8ff <free+0x4f>
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	8b 00                	mov    (%eax),%eax
 8e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e3:	77 1a                	ja     8ff <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e8:	8b 00                	mov    (%eax),%eax
 8ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f3:	76 d4                	jbe    8c9 <free+0x19>
 8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f8:	8b 00                	mov    (%eax),%eax
 8fa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8fd:	76 ca                	jbe    8c9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 902:	8b 40 04             	mov    0x4(%eax),%eax
 905:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 90c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90f:	01 c2                	add    %eax,%edx
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	8b 00                	mov    (%eax),%eax
 916:	39 c2                	cmp    %eax,%edx
 918:	75 24                	jne    93e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	8b 50 04             	mov    0x4(%eax),%edx
 920:	8b 45 fc             	mov    -0x4(%ebp),%eax
 923:	8b 00                	mov    (%eax),%eax
 925:	8b 40 04             	mov    0x4(%eax),%eax
 928:	01 c2                	add    %eax,%edx
 92a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	8b 00                	mov    (%eax),%eax
 935:	8b 10                	mov    (%eax),%edx
 937:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93a:	89 10                	mov    %edx,(%eax)
 93c:	eb 0a                	jmp    948 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	8b 10                	mov    (%eax),%edx
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 948:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94b:	8b 40 04             	mov    0x4(%eax),%eax
 94e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	01 d0                	add    %edx,%eax
 95a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 95d:	75 20                	jne    97f <free+0xcf>
    p->s.size += bp->s.size;
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	8b 50 04             	mov    0x4(%eax),%edx
 965:	8b 45 f8             	mov    -0x8(%ebp),%eax
 968:	8b 40 04             	mov    0x4(%eax),%eax
 96b:	01 c2                	add    %eax,%edx
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 973:	8b 45 f8             	mov    -0x8(%ebp),%eax
 976:	8b 10                	mov    (%eax),%edx
 978:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97b:	89 10                	mov    %edx,(%eax)
 97d:	eb 08                	jmp    987 <free+0xd7>
  } else
    p->s.ptr = bp;
 97f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 982:	8b 55 f8             	mov    -0x8(%ebp),%edx
 985:	89 10                	mov    %edx,(%eax)
  freep = p;
 987:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98a:	a3 c8 0d 00 00       	mov    %eax,0xdc8
}
 98f:	c9                   	leave  
 990:	c3                   	ret    

00000991 <morecore>:

static Header*
morecore(uint nu)
{
 991:	55                   	push   %ebp
 992:	89 e5                	mov    %esp,%ebp
 994:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 997:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 99e:	77 07                	ja     9a7 <morecore+0x16>
    nu = 4096;
 9a0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9a7:	8b 45 08             	mov    0x8(%ebp),%eax
 9aa:	c1 e0 03             	shl    $0x3,%eax
 9ad:	89 04 24             	mov    %eax,(%esp)
 9b0:	e8 47 fb ff ff       	call   4fc <sbrk>
 9b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9b8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9bc:	75 07                	jne    9c5 <morecore+0x34>
    return 0;
 9be:	b8 00 00 00 00       	mov    $0x0,%eax
 9c3:	eb 22                	jmp    9e7 <morecore+0x56>
  hp = (Header*)p;
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ce:	8b 55 08             	mov    0x8(%ebp),%edx
 9d1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d7:	83 c0 08             	add    $0x8,%eax
 9da:	89 04 24             	mov    %eax,(%esp)
 9dd:	e8 ce fe ff ff       	call   8b0 <free>
  return freep;
 9e2:	a1 c8 0d 00 00       	mov    0xdc8,%eax
}
 9e7:	c9                   	leave  
 9e8:	c3                   	ret    

000009e9 <malloc>:

void*
malloc(uint nbytes)
{
 9e9:	55                   	push   %ebp
 9ea:	89 e5                	mov    %esp,%ebp
 9ec:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ef:	8b 45 08             	mov    0x8(%ebp),%eax
 9f2:	83 c0 07             	add    $0x7,%eax
 9f5:	c1 e8 03             	shr    $0x3,%eax
 9f8:	40                   	inc    %eax
 9f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9fc:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a08:	75 23                	jne    a2d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a0a:	c7 45 f0 c0 0d 00 00 	movl   $0xdc0,-0x10(%ebp)
 a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a14:	a3 c8 0d 00 00       	mov    %eax,0xdc8
 a19:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 a1e:	a3 c0 0d 00 00       	mov    %eax,0xdc0
    base.s.size = 0;
 a23:	c7 05 c4 0d 00 00 00 	movl   $0x0,0xdc4
 a2a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a30:	8b 00                	mov    (%eax),%eax
 a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	8b 40 04             	mov    0x4(%eax),%eax
 a3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a3e:	72 4d                	jb     a8d <malloc+0xa4>
      if(p->s.size == nunits)
 a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a43:	8b 40 04             	mov    0x4(%eax),%eax
 a46:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a49:	75 0c                	jne    a57 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 10                	mov    (%eax),%edx
 a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a53:	89 10                	mov    %edx,(%eax)
 a55:	eb 26                	jmp    a7d <malloc+0x94>
      else {
        p->s.size -= nunits;
 a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5a:	8b 40 04             	mov    0x4(%eax),%eax
 a5d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a60:	89 c2                	mov    %eax,%edx
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	8b 40 04             	mov    0x4(%eax),%eax
 a6e:	c1 e0 03             	shl    $0x3,%eax
 a71:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a7a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a80:	a3 c8 0d 00 00       	mov    %eax,0xdc8
      return (void*)(p + 1);
 a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a88:	83 c0 08             	add    $0x8,%eax
 a8b:	eb 38                	jmp    ac5 <malloc+0xdc>
    }
    if(p == freep)
 a8d:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 a92:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a95:	75 1b                	jne    ab2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a97:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a9a:	89 04 24             	mov    %eax,(%esp)
 a9d:	e8 ef fe ff ff       	call   991 <morecore>
 aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aa5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa9:	75 07                	jne    ab2 <malloc+0xc9>
        return 0;
 aab:	b8 00 00 00 00       	mov    $0x0,%eax
 ab0:	eb 13                	jmp    ac5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	8b 00                	mov    (%eax),%eax
 abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ac0:	e9 70 ff ff ff       	jmp    a35 <malloc+0x4c>
}
 ac5:	c9                   	leave  
 ac6:	c3                   	ret    
