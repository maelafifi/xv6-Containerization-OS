
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
   f:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 8d 03 00 00       	call   3b0 <write>
  23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  26:	74 19                	je     41 <cat+0x41>
      printf(1, "cat: write error\n");
  28:	c7 44 24 04 b3 09 00 	movl   $0x9b3,0x4(%esp)
  2f:	00 
  30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  37:	e8 b1 05 00 00       	call   5ed <printf>
      exit();
  3c:	e8 4f 03 00 00       	call   390 <exit>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  41:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  48:	00 
  49:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
  50:	00 
  51:	8b 45 08             	mov    0x8(%ebp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 4c 03 00 00       	call   3a8 <read>
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
  6b:	c7 44 24 04 c5 09 00 	movl   $0x9c5,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 6e 05 00 00       	call   5ed <printf>
    exit();
  7f:	e8 0c 03 00 00       	call   390 <exit>
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
  a1:	e8 ea 02 00 00       	call   390 <exit>
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
  cd:	e8 fe 02 00 00       	call   3d0 <open>
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
  f3:	c7 44 24 04 d6 09 00 	movl   $0x9d6,0x4(%esp)
  fa:	00 
  fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 102:	e8 e6 04 00 00       	call   5ed <printf>
      exit();
 107:	e8 84 02 00 00       	call   390 <exit>
    }
    cat(fd);
 10c:	8b 44 24 18          	mov    0x18(%esp),%eax
 110:	89 04 24             	mov    %eax,(%esp)
 113:	e8 e8 fe ff ff       	call   0 <cat>
    close(fd);
 118:	8b 44 24 18          	mov    0x18(%esp),%eax
 11c:	89 04 24             	mov    %eax,(%esp)
 11f:	e8 94 02 00 00       	call   3b8 <close>
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
 135:	e8 56 02 00 00       	call   390 <exit>
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
 265:	e8 3e 01 00 00       	call   3a8 <read>
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
 2c5:	e8 06 01 00 00       	call   3d0 <open>
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
 2e7:	e8 fc 00 00 00       	call   3e8 <fstat>
 2ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f2:	89 04 24             	mov    %eax,(%esp)
 2f5:	e8 be 00 00 00       	call   3b8 <close>
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
 385:	90                   	nop
 386:	90                   	nop
 387:	90                   	nop

00000388 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 388:	b8 01 00 00 00       	mov    $0x1,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <exit>:
SYSCALL(exit)
 390:	b8 02 00 00 00       	mov    $0x2,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <wait>:
SYSCALL(wait)
 398:	b8 03 00 00 00       	mov    $0x3,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <pipe>:
SYSCALL(pipe)
 3a0:	b8 04 00 00 00       	mov    $0x4,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <read>:
SYSCALL(read)
 3a8:	b8 05 00 00 00       	mov    $0x5,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <write>:
SYSCALL(write)
 3b0:	b8 10 00 00 00       	mov    $0x10,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <close>:
SYSCALL(close)
 3b8:	b8 15 00 00 00       	mov    $0x15,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <kill>:
SYSCALL(kill)
 3c0:	b8 06 00 00 00       	mov    $0x6,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <exec>:
SYSCALL(exec)
 3c8:	b8 07 00 00 00       	mov    $0x7,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <open>:
SYSCALL(open)
 3d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <mknod>:
SYSCALL(mknod)
 3d8:	b8 11 00 00 00       	mov    $0x11,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <unlink>:
SYSCALL(unlink)
 3e0:	b8 12 00 00 00       	mov    $0x12,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <fstat>:
SYSCALL(fstat)
 3e8:	b8 08 00 00 00       	mov    $0x8,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <link>:
SYSCALL(link)
 3f0:	b8 13 00 00 00       	mov    $0x13,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <mkdir>:
SYSCALL(mkdir)
 3f8:	b8 14 00 00 00       	mov    $0x14,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <chdir>:
SYSCALL(chdir)
 400:	b8 09 00 00 00       	mov    $0x9,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <dup>:
SYSCALL(dup)
 408:	b8 0a 00 00 00       	mov    $0xa,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <getpid>:
SYSCALL(getpid)
 410:	b8 0b 00 00 00       	mov    $0xb,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <sbrk>:
SYSCALL(sbrk)
 418:	b8 0c 00 00 00       	mov    $0xc,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <sleep>:
SYSCALL(sleep)
 420:	b8 0d 00 00 00       	mov    $0xd,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <uptime>:
SYSCALL(uptime)
 428:	b8 0e 00 00 00       	mov    $0xe,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <getticks>:
SYSCALL(getticks)
 430:	b8 16 00 00 00       	mov    $0x16,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <get_name>:
SYSCALL(get_name)
 438:	b8 17 00 00 00       	mov    $0x17,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <get_max_proc>:
SYSCALL(get_max_proc)
 440:	b8 18 00 00 00       	mov    $0x18,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <get_max_mem>:
SYSCALL(get_max_mem)
 448:	b8 19 00 00 00       	mov    $0x19,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <get_max_disk>:
SYSCALL(get_max_disk)
 450:	b8 1a 00 00 00       	mov    $0x1a,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <get_curr_proc>:
SYSCALL(get_curr_proc)
 458:	b8 1b 00 00 00       	mov    $0x1b,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <get_curr_mem>:
SYSCALL(get_curr_mem)
 460:	b8 1c 00 00 00       	mov    $0x1c,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <get_curr_disk>:
SYSCALL(get_curr_disk)
 468:	b8 1d 00 00 00       	mov    $0x1d,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <set_name>:
SYSCALL(set_name)
 470:	b8 1e 00 00 00       	mov    $0x1e,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <set_max_mem>:
SYSCALL(set_max_mem)
 478:	b8 1f 00 00 00       	mov    $0x1f,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <set_max_disk>:
SYSCALL(set_max_disk)
 480:	b8 20 00 00 00       	mov    $0x20,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <set_max_proc>:
SYSCALL(set_max_proc)
 488:	b8 21 00 00 00       	mov    $0x21,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <set_curr_mem>:
SYSCALL(set_curr_mem)
 490:	b8 22 00 00 00       	mov    $0x22,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <set_curr_disk>:
SYSCALL(set_curr_disk)
 498:	b8 23 00 00 00       	mov    $0x23,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <set_curr_proc>:
SYSCALL(set_curr_proc)
 4a0:	b8 24 00 00 00       	mov    $0x24,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <find>:
SYSCALL(find)
 4a8:	b8 25 00 00 00       	mov    $0x25,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <is_full>:
SYSCALL(is_full)
 4b0:	b8 26 00 00 00       	mov    $0x26,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <container_init>:
SYSCALL(container_init)
 4b8:	b8 27 00 00 00       	mov    $0x27,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <cont_proc_set>:
SYSCALL(cont_proc_set)
 4c0:	b8 28 00 00 00       	mov    $0x28,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <ps>:
SYSCALL(ps)
 4c8:	b8 29 00 00 00       	mov    $0x29,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 4d0:	b8 2a 00 00 00       	mov    $0x2a,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <set_root_inode>:
SYSCALL(set_root_inode)
 4d8:	b8 2b 00 00 00       	mov    $0x2b,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <cstop>:
SYSCALL(cstop)
 4e0:	b8 2c 00 00 00       	mov    $0x2c,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <df>:
SYSCALL(df)
 4e8:	b8 2d 00 00 00       	mov    $0x2d,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <max_containers>:
SYSCALL(max_containers)
 4f0:	b8 2e 00 00 00       	mov    $0x2e,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <container_reset>:
SYSCALL(container_reset)
 4f8:	b8 2f 00 00 00       	mov    $0x2f,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <pause>:
SYSCALL(pause)
 500:	b8 30 00 00 00       	mov    $0x30,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <resume>:
SYSCALL(resume)
 508:	b8 31 00 00 00       	mov    $0x31,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 18             	sub    $0x18,%esp
 516:	8b 45 0c             	mov    0xc(%ebp),%eax
 519:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 51c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 523:	00 
 524:	8d 45 f4             	lea    -0xc(%ebp),%eax
 527:	89 44 24 04          	mov    %eax,0x4(%esp)
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
 52e:	89 04 24             	mov    %eax,(%esp)
 531:	e8 7a fe ff ff       	call   3b0 <write>
}
 536:	c9                   	leave  
 537:	c3                   	ret    

00000538 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	56                   	push   %esi
 53c:	53                   	push   %ebx
 53d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 540:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 547:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 54b:	74 17                	je     564 <printint+0x2c>
 54d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 551:	79 11                	jns    564 <printint+0x2c>
    neg = 1;
 553:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 55a:	8b 45 0c             	mov    0xc(%ebp),%eax
 55d:	f7 d8                	neg    %eax
 55f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 562:	eb 06                	jmp    56a <printint+0x32>
  } else {
    x = xx;
 564:	8b 45 0c             	mov    0xc(%ebp),%eax
 567:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 56a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 571:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 574:	8d 41 01             	lea    0x1(%ecx),%eax
 577:	89 45 f4             	mov    %eax,-0xc(%ebp)
 57a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 57d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 580:	ba 00 00 00 00       	mov    $0x0,%edx
 585:	f7 f3                	div    %ebx
 587:	89 d0                	mov    %edx,%eax
 589:	8a 80 58 0c 00 00    	mov    0xc58(%eax),%al
 58f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 593:	8b 75 10             	mov    0x10(%ebp),%esi
 596:	8b 45 ec             	mov    -0x14(%ebp),%eax
 599:	ba 00 00 00 00       	mov    $0x0,%edx
 59e:	f7 f6                	div    %esi
 5a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a7:	75 c8                	jne    571 <printint+0x39>
  if(neg)
 5a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5ad:	74 10                	je     5bf <printint+0x87>
    buf[i++] = '-';
 5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b2:	8d 50 01             	lea    0x1(%eax),%edx
 5b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5bd:	eb 1e                	jmp    5dd <printint+0xa5>
 5bf:	eb 1c                	jmp    5dd <printint+0xa5>
    putc(fd, buf[i]);
 5c1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c7:	01 d0                	add    %edx,%eax
 5c9:	8a 00                	mov    (%eax),%al
 5cb:	0f be c0             	movsbl %al,%eax
 5ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d2:	8b 45 08             	mov    0x8(%ebp),%eax
 5d5:	89 04 24             	mov    %eax,(%esp)
 5d8:	e8 33 ff ff ff       	call   510 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5dd:	ff 4d f4             	decl   -0xc(%ebp)
 5e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e4:	79 db                	jns    5c1 <printint+0x89>
    putc(fd, buf[i]);
}
 5e6:	83 c4 30             	add    $0x30,%esp
 5e9:	5b                   	pop    %ebx
 5ea:	5e                   	pop    %esi
 5eb:	5d                   	pop    %ebp
 5ec:	c3                   	ret    

000005ed <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ed:	55                   	push   %ebp
 5ee:	89 e5                	mov    %esp,%ebp
 5f0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5fa:	8d 45 0c             	lea    0xc(%ebp),%eax
 5fd:	83 c0 04             	add    $0x4,%eax
 600:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 603:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 60a:	e9 77 01 00 00       	jmp    786 <printf+0x199>
    c = fmt[i] & 0xff;
 60f:	8b 55 0c             	mov    0xc(%ebp),%edx
 612:	8b 45 f0             	mov    -0x10(%ebp),%eax
 615:	01 d0                	add    %edx,%eax
 617:	8a 00                	mov    (%eax),%al
 619:	0f be c0             	movsbl %al,%eax
 61c:	25 ff 00 00 00       	and    $0xff,%eax
 621:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 624:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 628:	75 2c                	jne    656 <printf+0x69>
      if(c == '%'){
 62a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62e:	75 0c                	jne    63c <printf+0x4f>
        state = '%';
 630:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 637:	e9 47 01 00 00       	jmp    783 <printf+0x196>
      } else {
        putc(fd, c);
 63c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 63f:	0f be c0             	movsbl %al,%eax
 642:	89 44 24 04          	mov    %eax,0x4(%esp)
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	89 04 24             	mov    %eax,(%esp)
 64c:	e8 bf fe ff ff       	call   510 <putc>
 651:	e9 2d 01 00 00       	jmp    783 <printf+0x196>
      }
    } else if(state == '%'){
 656:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 65a:	0f 85 23 01 00 00    	jne    783 <printf+0x196>
      if(c == 'd'){
 660:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 664:	75 2d                	jne    693 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 666:	8b 45 e8             	mov    -0x18(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 672:	00 
 673:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 67a:	00 
 67b:	89 44 24 04          	mov    %eax,0x4(%esp)
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	89 04 24             	mov    %eax,(%esp)
 685:	e8 ae fe ff ff       	call   538 <printint>
        ap++;
 68a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68e:	e9 e9 00 00 00       	jmp    77c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 693:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 697:	74 06                	je     69f <printf+0xb2>
 699:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 69d:	75 2d                	jne    6cc <printf+0xdf>
        printint(fd, *ap, 16, 0);
 69f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a2:	8b 00                	mov    (%eax),%eax
 6a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ab:	00 
 6ac:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6b3:	00 
 6b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b8:	8b 45 08             	mov    0x8(%ebp),%eax
 6bb:	89 04 24             	mov    %eax,(%esp)
 6be:	e8 75 fe ff ff       	call   538 <printint>
        ap++;
 6c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c7:	e9 b0 00 00 00       	jmp    77c <printf+0x18f>
      } else if(c == 's'){
 6cc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6d0:	75 42                	jne    714 <printf+0x127>
        s = (char*)*ap;
 6d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d5:	8b 00                	mov    (%eax),%eax
 6d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e2:	75 09                	jne    6ed <printf+0x100>
          s = "(null)";
 6e4:	c7 45 f4 eb 09 00 00 	movl   $0x9eb,-0xc(%ebp)
        while(*s != 0){
 6eb:	eb 1c                	jmp    709 <printf+0x11c>
 6ed:	eb 1a                	jmp    709 <printf+0x11c>
          putc(fd, *s);
 6ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f2:	8a 00                	mov    (%eax),%al
 6f4:	0f be c0             	movsbl %al,%eax
 6f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fb:	8b 45 08             	mov    0x8(%ebp),%eax
 6fe:	89 04 24             	mov    %eax,(%esp)
 701:	e8 0a fe ff ff       	call   510 <putc>
          s++;
 706:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 709:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70c:	8a 00                	mov    (%eax),%al
 70e:	84 c0                	test   %al,%al
 710:	75 dd                	jne    6ef <printf+0x102>
 712:	eb 68                	jmp    77c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 714:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 718:	75 1d                	jne    737 <printf+0x14a>
        putc(fd, *ap);
 71a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71d:	8b 00                	mov    (%eax),%eax
 71f:	0f be c0             	movsbl %al,%eax
 722:	89 44 24 04          	mov    %eax,0x4(%esp)
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 df fd ff ff       	call   510 <putc>
        ap++;
 731:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 735:	eb 45                	jmp    77c <printf+0x18f>
      } else if(c == '%'){
 737:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 73b:	75 17                	jne    754 <printf+0x167>
        putc(fd, c);
 73d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 740:	0f be c0             	movsbl %al,%eax
 743:	89 44 24 04          	mov    %eax,0x4(%esp)
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	89 04 24             	mov    %eax,(%esp)
 74d:	e8 be fd ff ff       	call   510 <putc>
 752:	eb 28                	jmp    77c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 754:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 75b:	00 
 75c:	8b 45 08             	mov    0x8(%ebp),%eax
 75f:	89 04 24             	mov    %eax,(%esp)
 762:	e8 a9 fd ff ff       	call   510 <putc>
        putc(fd, c);
 767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76a:	0f be c0             	movsbl %al,%eax
 76d:	89 44 24 04          	mov    %eax,0x4(%esp)
 771:	8b 45 08             	mov    0x8(%ebp),%eax
 774:	89 04 24             	mov    %eax,(%esp)
 777:	e8 94 fd ff ff       	call   510 <putc>
      }
      state = 0;
 77c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 783:	ff 45 f0             	incl   -0x10(%ebp)
 786:	8b 55 0c             	mov    0xc(%ebp),%edx
 789:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78c:	01 d0                	add    %edx,%eax
 78e:	8a 00                	mov    (%eax),%al
 790:	84 c0                	test   %al,%al
 792:	0f 85 77 fe ff ff    	jne    60f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 798:	c9                   	leave  
 799:	c3                   	ret    
 79a:	90                   	nop
 79b:	90                   	nop

0000079c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79c:	55                   	push   %ebp
 79d:	89 e5                	mov    %esp,%ebp
 79f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	83 e8 08             	sub    $0x8,%eax
 7a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ab:	a1 88 0c 00 00       	mov    0xc88,%eax
 7b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b3:	eb 24                	jmp    7d9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 12                	ja     7d1 <free+0x35>
 7bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c5:	77 24                	ja     7eb <free+0x4f>
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7cf:	77 1a                	ja     7eb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7df:	76 d4                	jbe    7b5 <free+0x19>
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e9:	76 ca                	jbe    7b5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	8b 40 04             	mov    0x4(%eax),%eax
 7f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fb:	01 c2                	add    %eax,%edx
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	39 c2                	cmp    %eax,%edx
 804:	75 24                	jne    82a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 806:	8b 45 f8             	mov    -0x8(%ebp),%eax
 809:	8b 50 04             	mov    0x4(%eax),%edx
 80c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80f:	8b 00                	mov    (%eax),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	01 c2                	add    %eax,%edx
 816:	8b 45 f8             	mov    -0x8(%ebp),%eax
 819:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	8b 10                	mov    (%eax),%edx
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	89 10                	mov    %edx,(%eax)
 828:	eb 0a                	jmp    834 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 82a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82d:	8b 10                	mov    (%eax),%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	8b 40 04             	mov    0x4(%eax),%eax
 83a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	01 d0                	add    %edx,%eax
 846:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 849:	75 20                	jne    86b <free+0xcf>
    p->s.size += bp->s.size;
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	8b 50 04             	mov    0x4(%eax),%edx
 851:	8b 45 f8             	mov    -0x8(%ebp),%eax
 854:	8b 40 04             	mov    0x4(%eax),%eax
 857:	01 c2                	add    %eax,%edx
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 85f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 862:	8b 10                	mov    (%eax),%edx
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	89 10                	mov    %edx,(%eax)
 869:	eb 08                	jmp    873 <free+0xd7>
  } else
    p->s.ptr = bp;
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 871:	89 10                	mov    %edx,(%eax)
  freep = p;
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	a3 88 0c 00 00       	mov    %eax,0xc88
}
 87b:	c9                   	leave  
 87c:	c3                   	ret    

0000087d <morecore>:

static Header*
morecore(uint nu)
{
 87d:	55                   	push   %ebp
 87e:	89 e5                	mov    %esp,%ebp
 880:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 883:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 88a:	77 07                	ja     893 <morecore+0x16>
    nu = 4096;
 88c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 893:	8b 45 08             	mov    0x8(%ebp),%eax
 896:	c1 e0 03             	shl    $0x3,%eax
 899:	89 04 24             	mov    %eax,(%esp)
 89c:	e8 77 fb ff ff       	call   418 <sbrk>
 8a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a8:	75 07                	jne    8b1 <morecore+0x34>
    return 0;
 8aa:	b8 00 00 00 00       	mov    $0x0,%eax
 8af:	eb 22                	jmp    8d3 <morecore+0x56>
  hp = (Header*)p;
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ba:	8b 55 08             	mov    0x8(%ebp),%edx
 8bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c3:	83 c0 08             	add    $0x8,%eax
 8c6:	89 04 24             	mov    %eax,(%esp)
 8c9:	e8 ce fe ff ff       	call   79c <free>
  return freep;
 8ce:	a1 88 0c 00 00       	mov    0xc88,%eax
}
 8d3:	c9                   	leave  
 8d4:	c3                   	ret    

000008d5 <malloc>:

void*
malloc(uint nbytes)
{
 8d5:	55                   	push   %ebp
 8d6:	89 e5                	mov    %esp,%ebp
 8d8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8db:	8b 45 08             	mov    0x8(%ebp),%eax
 8de:	83 c0 07             	add    $0x7,%eax
 8e1:	c1 e8 03             	shr    $0x3,%eax
 8e4:	40                   	inc    %eax
 8e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e8:	a1 88 0c 00 00       	mov    0xc88,%eax
 8ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8f4:	75 23                	jne    919 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8f6:	c7 45 f0 80 0c 00 00 	movl   $0xc80,-0x10(%ebp)
 8fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 900:	a3 88 0c 00 00       	mov    %eax,0xc88
 905:	a1 88 0c 00 00       	mov    0xc88,%eax
 90a:	a3 80 0c 00 00       	mov    %eax,0xc80
    base.s.size = 0;
 90f:	c7 05 84 0c 00 00 00 	movl   $0x0,0xc84
 916:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 919:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 921:	8b 45 f4             	mov    -0xc(%ebp),%eax
 924:	8b 40 04             	mov    0x4(%eax),%eax
 927:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 92a:	72 4d                	jb     979 <malloc+0xa4>
      if(p->s.size == nunits)
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 935:	75 0c                	jne    943 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	8b 10                	mov    (%eax),%edx
 93c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93f:	89 10                	mov    %edx,(%eax)
 941:	eb 26                	jmp    969 <malloc+0x94>
      else {
        p->s.size -= nunits;
 943:	8b 45 f4             	mov    -0xc(%ebp),%eax
 946:	8b 40 04             	mov    0x4(%eax),%eax
 949:	2b 45 ec             	sub    -0x14(%ebp),%eax
 94c:	89 c2                	mov    %eax,%edx
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	8b 40 04             	mov    0x4(%eax),%eax
 95a:	c1 e0 03             	shl    $0x3,%eax
 95d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	8b 55 ec             	mov    -0x14(%ebp),%edx
 966:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 969:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96c:	a3 88 0c 00 00       	mov    %eax,0xc88
      return (void*)(p + 1);
 971:	8b 45 f4             	mov    -0xc(%ebp),%eax
 974:	83 c0 08             	add    $0x8,%eax
 977:	eb 38                	jmp    9b1 <malloc+0xdc>
    }
    if(p == freep)
 979:	a1 88 0c 00 00       	mov    0xc88,%eax
 97e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 981:	75 1b                	jne    99e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 983:	8b 45 ec             	mov    -0x14(%ebp),%eax
 986:	89 04 24             	mov    %eax,(%esp)
 989:	e8 ef fe ff ff       	call   87d <morecore>
 98e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 991:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 995:	75 07                	jne    99e <malloc+0xc9>
        return 0;
 997:	b8 00 00 00 00       	mov    $0x0,%eax
 99c:	eb 13                	jmp    9b1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a7:	8b 00                	mov    (%eax),%eax
 9a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ac:	e9 70 ff ff ff       	jmp    921 <malloc+0x4c>
}
 9b1:	c9                   	leave  
 9b2:	c3                   	ret    
