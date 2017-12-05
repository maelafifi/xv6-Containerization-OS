
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <create_vcs>:

char *argv[] = { "sh", 0 };

void
create_vcs(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int i, fd;
  char *dname = "vc0";
   6:	c7 45 f0 1a 0b 00 00 	movl   $0xb1a,-0x10(%ebp)

  for (i = 0; i < 4; i++) {
   d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  14:	eb 58                	jmp    6e <create_vcs+0x6e>
    dname[2] = '0' + i;
  16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  19:	8d 50 02             	lea    0x2(%eax),%edx
  1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1f:	83 c0 30             	add    $0x30,%eax
  22:	88 02                	mov    %al,(%edx)
    if ((fd = open(dname, O_RDWR)) < 0){
  24:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  2b:	00 
  2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2f:	89 04 24             	mov    %eax,(%esp)
  32:	e8 cd 04 00 00       	call   504 <open>
  37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  3e:	79 20                	jns    60 <create_vcs+0x60>
      mknod(dname, 1, i + 2);
  40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  43:	83 c0 02             	add    $0x2,%eax
  46:	98                   	cwtl   
  47:	89 44 24 08          	mov    %eax,0x8(%esp)
  4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  52:	00 
  53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  56:	89 04 24             	mov    %eax,(%esp)
  59:	e8 ae 04 00 00       	call   50c <mknod>
  5e:	eb 0b                	jmp    6b <create_vcs+0x6b>
    } else {
      close(fd);
  60:	8b 45 ec             	mov    -0x14(%ebp),%eax
  63:	89 04 24             	mov    %eax,(%esp)
  66:	e8 81 04 00 00       	call   4ec <close>
create_vcs(void)
{
  int i, fd;
  char *dname = "vc0";

  for (i = 0; i < 4; i++) {
  6b:	ff 45 f4             	incl   -0xc(%ebp)
  6e:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  72:	7e a2                	jle    16 <create_vcs+0x16>
      mknod(dname, 1, i + 2);
    } else {
      close(fd);
    }
  }
}
  74:	c9                   	leave  
  75:	c3                   	ret    

00000076 <main>:

int
main(void)
{
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	83 e4 f0             	and    $0xfffffff0,%esp
  7c:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  7f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  86:	00 
  87:	c7 04 24 1e 0b 00 00 	movl   $0xb1e,(%esp)
  8e:	e8 71 04 00 00       	call   504 <open>
  93:	85 c0                	test   %eax,%eax
  95:	79 30                	jns    c7 <main+0x51>
    mknod("console", 1, 1);
  97:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  9e:	00 
  9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  a6:	00 
  a7:	c7 04 24 1e 0b 00 00 	movl   $0xb1e,(%esp)
  ae:	e8 59 04 00 00       	call   50c <mknod>
    open("console", O_RDWR);
  b3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  ba:	00 
  bb:	c7 04 24 1e 0b 00 00 	movl   $0xb1e,(%esp)
  c2:	e8 3d 04 00 00       	call   504 <open>
  }
  dup(0);  // stdout
  c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  ce:	e8 69 04 00 00       	call   53c <dup>
  dup(0);  // stderr
  d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  da:	e8 5d 04 00 00       	call   53c <dup>

  create_vcs();
  df:	e8 1c ff ff ff       	call   0 <create_vcs>

  for(;;){
    printf(1, "init: starting sh\n");
  e4:	c7 44 24 04 26 0b 00 	movl   $0xb26,0x4(%esp)
  eb:	00 
  ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f3:	e8 59 06 00 00       	call   751 <printf>
    pid = fork();
  f8:	e8 bf 03 00 00       	call   4bc <fork>
  fd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
 101:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
 106:	79 19                	jns    121 <main+0xab>
      printf(1, "init: fork failed\n");
 108:	c7 44 24 04 39 0b 00 	movl   $0xb39,0x4(%esp)
 10f:	00 
 110:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 117:	e8 35 06 00 00       	call   751 <printf>
      exit();
 11c:	e8 a3 03 00 00       	call   4c4 <exit>
    }
    if(pid == 0){
 121:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
 126:	75 2d                	jne    155 <main+0xdf>
      exec("sh", argv);
 128:	c7 44 24 04 fc 0d 00 	movl   $0xdfc,0x4(%esp)
 12f:	00 
 130:	c7 04 24 17 0b 00 00 	movl   $0xb17,(%esp)
 137:	e8 c0 03 00 00       	call   4fc <exec>
      printf(1, "init: exec sh failed\n");
 13c:	c7 44 24 04 4c 0b 00 	movl   $0xb4c,0x4(%esp)
 143:	00 
 144:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 14b:	e8 01 06 00 00       	call   751 <printf>
      exit();
 150:	e8 6f 03 00 00       	call   4c4 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
 155:	eb 14                	jmp    16b <main+0xf5>
      printf(1, "zombie!\n");
 157:	c7 44 24 04 62 0b 00 	movl   $0xb62,0x4(%esp)
 15e:	00 
 15f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 166:	e8 e6 05 00 00       	call   751 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
 16b:	e8 5c 03 00 00       	call   4cc <wait>
 170:	89 44 24 18          	mov    %eax,0x18(%esp)
 174:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 179:	78 0a                	js     185 <main+0x10f>
 17b:	8b 44 24 18          	mov    0x18(%esp),%eax
 17f:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 183:	75 d2                	jne    157 <main+0xe1>
      printf(1, "zombie!\n");
  }
 185:	e9 5a ff ff ff       	jmp    e4 <main+0x6e>
 18a:	90                   	nop
 18b:	90                   	nop

0000018c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	57                   	push   %edi
 190:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 191:	8b 4d 08             	mov    0x8(%ebp),%ecx
 194:	8b 55 10             	mov    0x10(%ebp),%edx
 197:	8b 45 0c             	mov    0xc(%ebp),%eax
 19a:	89 cb                	mov    %ecx,%ebx
 19c:	89 df                	mov    %ebx,%edi
 19e:	89 d1                	mov    %edx,%ecx
 1a0:	fc                   	cld    
 1a1:	f3 aa                	rep stos %al,%es:(%edi)
 1a3:	89 ca                	mov    %ecx,%edx
 1a5:	89 fb                	mov    %edi,%ebx
 1a7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1aa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1ad:	5b                   	pop    %ebx
 1ae:	5f                   	pop    %edi
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    

000001b1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1bd:	90                   	nop
 1be:	8b 45 08             	mov    0x8(%ebp),%eax
 1c1:	8d 50 01             	lea    0x1(%eax),%edx
 1c4:	89 55 08             	mov    %edx,0x8(%ebp)
 1c7:	8b 55 0c             	mov    0xc(%ebp),%edx
 1ca:	8d 4a 01             	lea    0x1(%edx),%ecx
 1cd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1d0:	8a 12                	mov    (%edx),%dl
 1d2:	88 10                	mov    %dl,(%eax)
 1d4:	8a 00                	mov    (%eax),%al
 1d6:	84 c0                	test   %al,%al
 1d8:	75 e4                	jne    1be <strcpy+0xd>
    ;
  return os;
 1da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1dd:	c9                   	leave  
 1de:	c3                   	ret    

000001df <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1e2:	eb 06                	jmp    1ea <strcmp+0xb>
    p++, q++;
 1e4:	ff 45 08             	incl   0x8(%ebp)
 1e7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
 1ed:	8a 00                	mov    (%eax),%al
 1ef:	84 c0                	test   %al,%al
 1f1:	74 0e                	je     201 <strcmp+0x22>
 1f3:	8b 45 08             	mov    0x8(%ebp),%eax
 1f6:	8a 10                	mov    (%eax),%dl
 1f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fb:	8a 00                	mov    (%eax),%al
 1fd:	38 c2                	cmp    %al,%dl
 1ff:	74 e3                	je     1e4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	8a 00                	mov    (%eax),%al
 206:	0f b6 d0             	movzbl %al,%edx
 209:	8b 45 0c             	mov    0xc(%ebp),%eax
 20c:	8a 00                	mov    (%eax),%al
 20e:	0f b6 c0             	movzbl %al,%eax
 211:	29 c2                	sub    %eax,%edx
 213:	89 d0                	mov    %edx,%eax
}
 215:	5d                   	pop    %ebp
 216:	c3                   	ret    

00000217 <strlen>:

uint
strlen(char *s)
{
 217:	55                   	push   %ebp
 218:	89 e5                	mov    %esp,%ebp
 21a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 21d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 224:	eb 03                	jmp    229 <strlen+0x12>
 226:	ff 45 fc             	incl   -0x4(%ebp)
 229:	8b 55 fc             	mov    -0x4(%ebp),%edx
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
 22f:	01 d0                	add    %edx,%eax
 231:	8a 00                	mov    (%eax),%al
 233:	84 c0                	test   %al,%al
 235:	75 ef                	jne    226 <strlen+0xf>
    ;
  return n;
 237:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 23a:	c9                   	leave  
 23b:	c3                   	ret    

0000023c <memset>:

void*
memset(void *dst, int c, uint n)
{
 23c:	55                   	push   %ebp
 23d:	89 e5                	mov    %esp,%ebp
 23f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 242:	8b 45 10             	mov    0x10(%ebp),%eax
 245:	89 44 24 08          	mov    %eax,0x8(%esp)
 249:	8b 45 0c             	mov    0xc(%ebp),%eax
 24c:	89 44 24 04          	mov    %eax,0x4(%esp)
 250:	8b 45 08             	mov    0x8(%ebp),%eax
 253:	89 04 24             	mov    %eax,(%esp)
 256:	e8 31 ff ff ff       	call   18c <stosb>
  return dst;
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 25e:	c9                   	leave  
 25f:	c3                   	ret    

00000260 <strchr>:

char*
strchr(const char *s, char c)
{
 260:	55                   	push   %ebp
 261:	89 e5                	mov    %esp,%ebp
 263:	83 ec 04             	sub    $0x4,%esp
 266:	8b 45 0c             	mov    0xc(%ebp),%eax
 269:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 26c:	eb 12                	jmp    280 <strchr+0x20>
    if(*s == c)
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
 271:	8a 00                	mov    (%eax),%al
 273:	3a 45 fc             	cmp    -0x4(%ebp),%al
 276:	75 05                	jne    27d <strchr+0x1d>
      return (char*)s;
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	eb 11                	jmp    28e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 27d:	ff 45 08             	incl   0x8(%ebp)
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	8a 00                	mov    (%eax),%al
 285:	84 c0                	test   %al,%al
 287:	75 e5                	jne    26e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 289:	b8 00 00 00 00       	mov    $0x0,%eax
}
 28e:	c9                   	leave  
 28f:	c3                   	ret    

00000290 <gets>:

char*
gets(char *buf, int max)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 296:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 29d:	eb 49                	jmp    2e8 <gets+0x58>
    cc = read(0, &c, 1);
 29f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2a6:	00 
 2a7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2b5:	e8 22 02 00 00       	call   4dc <read>
 2ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2c1:	7f 02                	jg     2c5 <gets+0x35>
      break;
 2c3:	eb 2c                	jmp    2f1 <gets+0x61>
    buf[i++] = c;
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	8d 50 01             	lea    0x1(%eax),%edx
 2cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2ce:	89 c2                	mov    %eax,%edx
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	01 c2                	add    %eax,%edx
 2d5:	8a 45 ef             	mov    -0x11(%ebp),%al
 2d8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2da:	8a 45 ef             	mov    -0x11(%ebp),%al
 2dd:	3c 0a                	cmp    $0xa,%al
 2df:	74 10                	je     2f1 <gets+0x61>
 2e1:	8a 45 ef             	mov    -0x11(%ebp),%al
 2e4:	3c 0d                	cmp    $0xd,%al
 2e6:	74 09                	je     2f1 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2eb:	40                   	inc    %eax
 2ec:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2ef:	7c ae                	jl     29f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	01 d0                	add    %edx,%eax
 2f9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ff:	c9                   	leave  
 300:	c3                   	ret    

00000301 <stat>:

int
stat(char *n, struct stat *st)
{
 301:	55                   	push   %ebp
 302:	89 e5                	mov    %esp,%ebp
 304:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 307:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 30e:	00 
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	89 04 24             	mov    %eax,(%esp)
 315:	e8 ea 01 00 00       	call   504 <open>
 31a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 31d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 321:	79 07                	jns    32a <stat+0x29>
    return -1;
 323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 328:	eb 23                	jmp    34d <stat+0x4c>
  r = fstat(fd, st);
 32a:	8b 45 0c             	mov    0xc(%ebp),%eax
 32d:	89 44 24 04          	mov    %eax,0x4(%esp)
 331:	8b 45 f4             	mov    -0xc(%ebp),%eax
 334:	89 04 24             	mov    %eax,(%esp)
 337:	e8 e0 01 00 00       	call   51c <fstat>
 33c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 33f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 342:	89 04 24             	mov    %eax,(%esp)
 345:	e8 a2 01 00 00       	call   4ec <close>
  return r;
 34a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 34d:	c9                   	leave  
 34e:	c3                   	ret    

0000034f <atoi>:

int
atoi(const char *s)
{
 34f:	55                   	push   %ebp
 350:	89 e5                	mov    %esp,%ebp
 352:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 355:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 35c:	eb 24                	jmp    382 <atoi+0x33>
    n = n*10 + *s++ - '0';
 35e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 361:	89 d0                	mov    %edx,%eax
 363:	c1 e0 02             	shl    $0x2,%eax
 366:	01 d0                	add    %edx,%eax
 368:	01 c0                	add    %eax,%eax
 36a:	89 c1                	mov    %eax,%ecx
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	8d 50 01             	lea    0x1(%eax),%edx
 372:	89 55 08             	mov    %edx,0x8(%ebp)
 375:	8a 00                	mov    (%eax),%al
 377:	0f be c0             	movsbl %al,%eax
 37a:	01 c8                	add    %ecx,%eax
 37c:	83 e8 30             	sub    $0x30,%eax
 37f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 382:	8b 45 08             	mov    0x8(%ebp),%eax
 385:	8a 00                	mov    (%eax),%al
 387:	3c 2f                	cmp    $0x2f,%al
 389:	7e 09                	jle    394 <atoi+0x45>
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	8a 00                	mov    (%eax),%al
 390:	3c 39                	cmp    $0x39,%al
 392:	7e ca                	jle    35e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 394:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 397:	c9                   	leave  
 398:	c3                   	ret    

00000399 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 399:	55                   	push   %ebp
 39a:	89 e5                	mov    %esp,%ebp
 39c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3ab:	eb 16                	jmp    3c3 <memmove+0x2a>
    *dst++ = *src++;
 3ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3b0:	8d 50 01             	lea    0x1(%eax),%edx
 3b3:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3b6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3b9:	8d 4a 01             	lea    0x1(%edx),%ecx
 3bc:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3bf:	8a 12                	mov    (%edx),%dl
 3c1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3c3:	8b 45 10             	mov    0x10(%ebp),%eax
 3c6:	8d 50 ff             	lea    -0x1(%eax),%edx
 3c9:	89 55 10             	mov    %edx,0x10(%ebp)
 3cc:	85 c0                	test   %eax,%eax
 3ce:	7f dd                	jg     3ad <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3d3:	c9                   	leave  
 3d4:	c3                   	ret    

000003d5 <itoa>:

int itoa(int value, char *sp, int radix)
{
 3d5:	55                   	push   %ebp
 3d6:	89 e5                	mov    %esp,%ebp
 3d8:	53                   	push   %ebx
 3d9:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 3dc:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3df:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 3e2:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 3e6:	75 0d                	jne    3f5 <itoa+0x20>
 3e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3ec:	79 07                	jns    3f5 <itoa+0x20>
 3ee:	b8 01 00 00 00       	mov    $0x1,%eax
 3f3:	eb 05                	jmp    3fa <itoa+0x25>
 3f5:	b8 00 00 00 00       	mov    $0x0,%eax
 3fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 3fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 401:	74 0a                	je     40d <itoa+0x38>
      v = -value;
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	f7 d8                	neg    %eax
 408:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 40b:	eb 54                	jmp    461 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 40d:	8b 45 08             	mov    0x8(%ebp),%eax
 410:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 413:	eb 4c                	jmp    461 <itoa+0x8c>
  {
    i = v % radix;
 415:	8b 4d 10             	mov    0x10(%ebp),%ecx
 418:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41b:	ba 00 00 00 00       	mov    $0x0,%edx
 420:	f7 f1                	div    %ecx
 422:	89 d0                	mov    %edx,%eax
 424:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 427:	8b 5d 10             	mov    0x10(%ebp),%ebx
 42a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42d:	ba 00 00 00 00       	mov    $0x0,%edx
 432:	f7 f3                	div    %ebx
 434:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 437:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 43b:	7f 13                	jg     450 <itoa+0x7b>
      *tp++ = i+'0';
 43d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 440:	8d 50 01             	lea    0x1(%eax),%edx
 443:	89 55 f8             	mov    %edx,-0x8(%ebp)
 446:	8b 55 e8             	mov    -0x18(%ebp),%edx
 449:	83 c2 30             	add    $0x30,%edx
 44c:	88 10                	mov    %dl,(%eax)
 44e:	eb 11                	jmp    461 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 450:	8b 45 f8             	mov    -0x8(%ebp),%eax
 453:	8d 50 01             	lea    0x1(%eax),%edx
 456:	89 55 f8             	mov    %edx,-0x8(%ebp)
 459:	8b 55 e8             	mov    -0x18(%ebp),%edx
 45c:	83 c2 57             	add    $0x57,%edx
 45f:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 461:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 465:	75 ae                	jne    415 <itoa+0x40>
 467:	8d 45 d8             	lea    -0x28(%ebp),%eax
 46a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 46d:	74 a6                	je     415 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 46f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 472:	8d 45 d8             	lea    -0x28(%ebp),%eax
 475:	29 c2                	sub    %eax,%edx
 477:	89 d0                	mov    %edx,%eax
 479:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 47c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 480:	74 11                	je     493 <itoa+0xbe>
  {
    *sp++ = '-';
 482:	8b 45 0c             	mov    0xc(%ebp),%eax
 485:	8d 50 01             	lea    0x1(%eax),%edx
 488:	89 55 0c             	mov    %edx,0xc(%ebp)
 48b:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 48e:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 491:	eb 15                	jmp    4a8 <itoa+0xd3>
 493:	eb 13                	jmp    4a8 <itoa+0xd3>
    *sp++ = *--tp;
 495:	8b 45 0c             	mov    0xc(%ebp),%eax
 498:	8d 50 01             	lea    0x1(%eax),%edx
 49b:	89 55 0c             	mov    %edx,0xc(%ebp)
 49e:	ff 4d f8             	decl   -0x8(%ebp)
 4a1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4a4:	8a 12                	mov    (%edx),%dl
 4a6:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 4a8:	8d 45 d8             	lea    -0x28(%ebp),%eax
 4ab:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 4ae:	77 e5                	ja     495 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 4b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4b3:	83 c4 30             	add    $0x30,%esp
 4b6:	5b                   	pop    %ebx
 4b7:	5d                   	pop    %ebp
 4b8:	c3                   	ret    
 4b9:	90                   	nop
 4ba:	90                   	nop
 4bb:	90                   	nop

000004bc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4bc:	b8 01 00 00 00       	mov    $0x1,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <exit>:
SYSCALL(exit)
 4c4:	b8 02 00 00 00       	mov    $0x2,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <wait>:
SYSCALL(wait)
 4cc:	b8 03 00 00 00       	mov    $0x3,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <pipe>:
SYSCALL(pipe)
 4d4:	b8 04 00 00 00       	mov    $0x4,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <read>:
SYSCALL(read)
 4dc:	b8 05 00 00 00       	mov    $0x5,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <write>:
SYSCALL(write)
 4e4:	b8 10 00 00 00       	mov    $0x10,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <close>:
SYSCALL(close)
 4ec:	b8 15 00 00 00       	mov    $0x15,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <kill>:
SYSCALL(kill)
 4f4:	b8 06 00 00 00       	mov    $0x6,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <exec>:
SYSCALL(exec)
 4fc:	b8 07 00 00 00       	mov    $0x7,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <open>:
SYSCALL(open)
 504:	b8 0f 00 00 00       	mov    $0xf,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <mknod>:
SYSCALL(mknod)
 50c:	b8 11 00 00 00       	mov    $0x11,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <unlink>:
SYSCALL(unlink)
 514:	b8 12 00 00 00       	mov    $0x12,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <fstat>:
SYSCALL(fstat)
 51c:	b8 08 00 00 00       	mov    $0x8,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <link>:
SYSCALL(link)
 524:	b8 13 00 00 00       	mov    $0x13,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <mkdir>:
SYSCALL(mkdir)
 52c:	b8 14 00 00 00       	mov    $0x14,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <chdir>:
SYSCALL(chdir)
 534:	b8 09 00 00 00       	mov    $0x9,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <dup>:
SYSCALL(dup)
 53c:	b8 0a 00 00 00       	mov    $0xa,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <getpid>:
SYSCALL(getpid)
 544:	b8 0b 00 00 00       	mov    $0xb,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <sbrk>:
SYSCALL(sbrk)
 54c:	b8 0c 00 00 00       	mov    $0xc,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <sleep>:
SYSCALL(sleep)
 554:	b8 0d 00 00 00       	mov    $0xd,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <uptime>:
SYSCALL(uptime)
 55c:	b8 0e 00 00 00       	mov    $0xe,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <getticks>:
SYSCALL(getticks)
 564:	b8 16 00 00 00       	mov    $0x16,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <get_name>:
SYSCALL(get_name)
 56c:	b8 17 00 00 00       	mov    $0x17,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <get_max_proc>:
SYSCALL(get_max_proc)
 574:	b8 18 00 00 00       	mov    $0x18,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <get_max_mem>:
SYSCALL(get_max_mem)
 57c:	b8 19 00 00 00       	mov    $0x19,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <get_max_disk>:
SYSCALL(get_max_disk)
 584:	b8 1a 00 00 00       	mov    $0x1a,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <get_curr_proc>:
SYSCALL(get_curr_proc)
 58c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <get_curr_mem>:
SYSCALL(get_curr_mem)
 594:	b8 1c 00 00 00       	mov    $0x1c,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <get_curr_disk>:
SYSCALL(get_curr_disk)
 59c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <set_name>:
SYSCALL(set_name)
 5a4:	b8 1e 00 00 00       	mov    $0x1e,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <set_max_mem>:
SYSCALL(set_max_mem)
 5ac:	b8 1f 00 00 00       	mov    $0x1f,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <set_max_disk>:
SYSCALL(set_max_disk)
 5b4:	b8 20 00 00 00       	mov    $0x20,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <set_max_proc>:
SYSCALL(set_max_proc)
 5bc:	b8 21 00 00 00       	mov    $0x21,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <set_curr_mem>:
SYSCALL(set_curr_mem)
 5c4:	b8 22 00 00 00       	mov    $0x22,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <set_curr_disk>:
SYSCALL(set_curr_disk)
 5cc:	b8 23 00 00 00       	mov    $0x23,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <set_curr_proc>:
SYSCALL(set_curr_proc)
 5d4:	b8 24 00 00 00       	mov    $0x24,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <find>:
SYSCALL(find)
 5dc:	b8 25 00 00 00       	mov    $0x25,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <is_full>:
SYSCALL(is_full)
 5e4:	b8 26 00 00 00       	mov    $0x26,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <container_init>:
SYSCALL(container_init)
 5ec:	b8 27 00 00 00       	mov    $0x27,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <cont_proc_set>:
SYSCALL(cont_proc_set)
 5f4:	b8 28 00 00 00       	mov    $0x28,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <ps>:
SYSCALL(ps)
 5fc:	b8 29 00 00 00       	mov    $0x29,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 604:	b8 2a 00 00 00       	mov    $0x2a,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <set_root_inode>:
SYSCALL(set_root_inode)
 60c:	b8 2b 00 00 00       	mov    $0x2b,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <cstop>:
SYSCALL(cstop)
 614:	b8 2c 00 00 00       	mov    $0x2c,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <df>:
SYSCALL(df)
 61c:	b8 2d 00 00 00       	mov    $0x2d,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <max_containers>:
SYSCALL(max_containers)
 624:	b8 2e 00 00 00       	mov    $0x2e,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <container_reset>:
SYSCALL(container_reset)
 62c:	b8 2f 00 00 00       	mov    $0x2f,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <pause>:
SYSCALL(pause)
 634:	b8 30 00 00 00       	mov    $0x30,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <resume>:
SYSCALL(resume)
 63c:	b8 31 00 00 00       	mov    $0x31,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <tmem>:
SYSCALL(tmem)
 644:	b8 32 00 00 00       	mov    $0x32,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <amem>:
SYSCALL(amem)
 64c:	b8 33 00 00 00       	mov    $0x33,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <c_ps>:
SYSCALL(c_ps)
 654:	b8 34 00 00 00       	mov    $0x34,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <get_used>:
SYSCALL(get_used)
 65c:	b8 35 00 00 00       	mov    $0x35,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <get_os>:
SYSCALL(get_os)
 664:	b8 36 00 00 00       	mov    $0x36,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <set_os>:
SYSCALL(set_os)
 66c:	b8 37 00 00 00       	mov    $0x37,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 674:	55                   	push   %ebp
 675:	89 e5                	mov    %esp,%ebp
 677:	83 ec 18             	sub    $0x18,%esp
 67a:	8b 45 0c             	mov    0xc(%ebp),%eax
 67d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 680:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 687:	00 
 688:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68b:	89 44 24 04          	mov    %eax,0x4(%esp)
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	89 04 24             	mov    %eax,(%esp)
 695:	e8 4a fe ff ff       	call   4e4 <write>
}
 69a:	c9                   	leave  
 69b:	c3                   	ret    

0000069c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69c:	55                   	push   %ebp
 69d:	89 e5                	mov    %esp,%ebp
 69f:	56                   	push   %esi
 6a0:	53                   	push   %ebx
 6a1:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ab:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6af:	74 17                	je     6c8 <printint+0x2c>
 6b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b5:	79 11                	jns    6c8 <printint+0x2c>
    neg = 1;
 6b7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6be:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c1:	f7 d8                	neg    %eax
 6c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c6:	eb 06                	jmp    6ce <printint+0x32>
  } else {
    x = xx;
 6c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6d8:	8d 41 01             	lea    0x1(%ecx),%eax
 6db:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6de:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e4:	ba 00 00 00 00       	mov    $0x0,%edx
 6e9:	f7 f3                	div    %ebx
 6eb:	89 d0                	mov    %edx,%eax
 6ed:	8a 80 04 0e 00 00    	mov    0xe04(%eax),%al
 6f3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6f7:	8b 75 10             	mov    0x10(%ebp),%esi
 6fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fd:	ba 00 00 00 00       	mov    $0x0,%edx
 702:	f7 f6                	div    %esi
 704:	89 45 ec             	mov    %eax,-0x14(%ebp)
 707:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70b:	75 c8                	jne    6d5 <printint+0x39>
  if(neg)
 70d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 711:	74 10                	je     723 <printint+0x87>
    buf[i++] = '-';
 713:	8b 45 f4             	mov    -0xc(%ebp),%eax
 716:	8d 50 01             	lea    0x1(%eax),%edx
 719:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 721:	eb 1e                	jmp    741 <printint+0xa5>
 723:	eb 1c                	jmp    741 <printint+0xa5>
    putc(fd, buf[i]);
 725:	8d 55 dc             	lea    -0x24(%ebp),%edx
 728:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72b:	01 d0                	add    %edx,%eax
 72d:	8a 00                	mov    (%eax),%al
 72f:	0f be c0             	movsbl %al,%eax
 732:	89 44 24 04          	mov    %eax,0x4(%esp)
 736:	8b 45 08             	mov    0x8(%ebp),%eax
 739:	89 04 24             	mov    %eax,(%esp)
 73c:	e8 33 ff ff ff       	call   674 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 741:	ff 4d f4             	decl   -0xc(%ebp)
 744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 748:	79 db                	jns    725 <printint+0x89>
    putc(fd, buf[i]);
}
 74a:	83 c4 30             	add    $0x30,%esp
 74d:	5b                   	pop    %ebx
 74e:	5e                   	pop    %esi
 74f:	5d                   	pop    %ebp
 750:	c3                   	ret    

00000751 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 751:	55                   	push   %ebp
 752:	89 e5                	mov    %esp,%ebp
 754:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 757:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 75e:	8d 45 0c             	lea    0xc(%ebp),%eax
 761:	83 c0 04             	add    $0x4,%eax
 764:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 767:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 76e:	e9 77 01 00 00       	jmp    8ea <printf+0x199>
    c = fmt[i] & 0xff;
 773:	8b 55 0c             	mov    0xc(%ebp),%edx
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	01 d0                	add    %edx,%eax
 77b:	8a 00                	mov    (%eax),%al
 77d:	0f be c0             	movsbl %al,%eax
 780:	25 ff 00 00 00       	and    $0xff,%eax
 785:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 788:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 78c:	75 2c                	jne    7ba <printf+0x69>
      if(c == '%'){
 78e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 792:	75 0c                	jne    7a0 <printf+0x4f>
        state = '%';
 794:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 79b:	e9 47 01 00 00       	jmp    8e7 <printf+0x196>
      } else {
        putc(fd, c);
 7a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a3:	0f be c0             	movsbl %al,%eax
 7a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7aa:	8b 45 08             	mov    0x8(%ebp),%eax
 7ad:	89 04 24             	mov    %eax,(%esp)
 7b0:	e8 bf fe ff ff       	call   674 <putc>
 7b5:	e9 2d 01 00 00       	jmp    8e7 <printf+0x196>
      }
    } else if(state == '%'){
 7ba:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7be:	0f 85 23 01 00 00    	jne    8e7 <printf+0x196>
      if(c == 'd'){
 7c4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c8:	75 2d                	jne    7f7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 7ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cd:	8b 00                	mov    (%eax),%eax
 7cf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7d6:	00 
 7d7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7de:	00 
 7df:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e3:	8b 45 08             	mov    0x8(%ebp),%eax
 7e6:	89 04 24             	mov    %eax,(%esp)
 7e9:	e8 ae fe ff ff       	call   69c <printint>
        ap++;
 7ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f2:	e9 e9 00 00 00       	jmp    8e0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 7f7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7fb:	74 06                	je     803 <printf+0xb2>
 7fd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 801:	75 2d                	jne    830 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 803:	8b 45 e8             	mov    -0x18(%ebp),%eax
 806:	8b 00                	mov    (%eax),%eax
 808:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 80f:	00 
 810:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 817:	00 
 818:	89 44 24 04          	mov    %eax,0x4(%esp)
 81c:	8b 45 08             	mov    0x8(%ebp),%eax
 81f:	89 04 24             	mov    %eax,(%esp)
 822:	e8 75 fe ff ff       	call   69c <printint>
        ap++;
 827:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82b:	e9 b0 00 00 00       	jmp    8e0 <printf+0x18f>
      } else if(c == 's'){
 830:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 834:	75 42                	jne    878 <printf+0x127>
        s = (char*)*ap;
 836:	8b 45 e8             	mov    -0x18(%ebp),%eax
 839:	8b 00                	mov    (%eax),%eax
 83b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 83e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 842:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 846:	75 09                	jne    851 <printf+0x100>
          s = "(null)";
 848:	c7 45 f4 6b 0b 00 00 	movl   $0xb6b,-0xc(%ebp)
        while(*s != 0){
 84f:	eb 1c                	jmp    86d <printf+0x11c>
 851:	eb 1a                	jmp    86d <printf+0x11c>
          putc(fd, *s);
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8a 00                	mov    (%eax),%al
 858:	0f be c0             	movsbl %al,%eax
 85b:	89 44 24 04          	mov    %eax,0x4(%esp)
 85f:	8b 45 08             	mov    0x8(%ebp),%eax
 862:	89 04 24             	mov    %eax,(%esp)
 865:	e8 0a fe ff ff       	call   674 <putc>
          s++;
 86a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 86d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 870:	8a 00                	mov    (%eax),%al
 872:	84 c0                	test   %al,%al
 874:	75 dd                	jne    853 <printf+0x102>
 876:	eb 68                	jmp    8e0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 878:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 87c:	75 1d                	jne    89b <printf+0x14a>
        putc(fd, *ap);
 87e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 881:	8b 00                	mov    (%eax),%eax
 883:	0f be c0             	movsbl %al,%eax
 886:	89 44 24 04          	mov    %eax,0x4(%esp)
 88a:	8b 45 08             	mov    0x8(%ebp),%eax
 88d:	89 04 24             	mov    %eax,(%esp)
 890:	e8 df fd ff ff       	call   674 <putc>
        ap++;
 895:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 899:	eb 45                	jmp    8e0 <printf+0x18f>
      } else if(c == '%'){
 89b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 89f:	75 17                	jne    8b8 <printf+0x167>
        putc(fd, c);
 8a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a4:	0f be c0             	movsbl %al,%eax
 8a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ab:	8b 45 08             	mov    0x8(%ebp),%eax
 8ae:	89 04 24             	mov    %eax,(%esp)
 8b1:	e8 be fd ff ff       	call   674 <putc>
 8b6:	eb 28                	jmp    8e0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8b8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8bf:	00 
 8c0:	8b 45 08             	mov    0x8(%ebp),%eax
 8c3:	89 04 24             	mov    %eax,(%esp)
 8c6:	e8 a9 fd ff ff       	call   674 <putc>
        putc(fd, c);
 8cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ce:	0f be c0             	movsbl %al,%eax
 8d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d5:	8b 45 08             	mov    0x8(%ebp),%eax
 8d8:	89 04 24             	mov    %eax,(%esp)
 8db:	e8 94 fd ff ff       	call   674 <putc>
      }
      state = 0;
 8e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8e7:	ff 45 f0             	incl   -0x10(%ebp)
 8ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	01 d0                	add    %edx,%eax
 8f2:	8a 00                	mov    (%eax),%al
 8f4:	84 c0                	test   %al,%al
 8f6:	0f 85 77 fe ff ff    	jne    773 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8fc:	c9                   	leave  
 8fd:	c3                   	ret    
 8fe:	90                   	nop
 8ff:	90                   	nop

00000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	55                   	push   %ebp
 901:	89 e5                	mov    %esp,%ebp
 903:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	8b 45 08             	mov    0x8(%ebp),%eax
 909:	83 e8 08             	sub    $0x8,%eax
 90c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90f:	a1 20 0e 00 00       	mov    0xe20,%eax
 914:	89 45 fc             	mov    %eax,-0x4(%ebp)
 917:	eb 24                	jmp    93d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 921:	77 12                	ja     935 <free+0x35>
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 929:	77 24                	ja     94f <free+0x4f>
 92b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92e:	8b 00                	mov    (%eax),%eax
 930:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 933:	77 1a                	ja     94f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 943:	76 d4                	jbe    919 <free+0x19>
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 94d:	76 ca                	jbe    919 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 94f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95f:	01 c2                	add    %eax,%edx
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	39 c2                	cmp    %eax,%edx
 968:	75 24                	jne    98e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	8b 50 04             	mov    0x4(%eax),%edx
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	8b 40 04             	mov    0x4(%eax),%eax
 978:	01 c2                	add    %eax,%edx
 97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 980:	8b 45 fc             	mov    -0x4(%ebp),%eax
 983:	8b 00                	mov    (%eax),%eax
 985:	8b 10                	mov    (%eax),%edx
 987:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98a:	89 10                	mov    %edx,(%eax)
 98c:	eb 0a                	jmp    998 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 991:	8b 10                	mov    (%eax),%edx
 993:	8b 45 f8             	mov    -0x8(%ebp),%eax
 996:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 998:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99b:	8b 40 04             	mov    0x4(%eax),%eax
 99e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	01 d0                	add    %edx,%eax
 9aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9ad:	75 20                	jne    9cf <free+0xcf>
    p->s.size += bp->s.size;
 9af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b2:	8b 50 04             	mov    0x4(%eax),%edx
 9b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b8:	8b 40 04             	mov    0x4(%eax),%eax
 9bb:	01 c2                	add    %eax,%edx
 9bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c6:	8b 10                	mov    (%eax),%edx
 9c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cb:	89 10                	mov    %edx,(%eax)
 9cd:	eb 08                	jmp    9d7 <free+0xd7>
  } else
    p->s.ptr = bp;
 9cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9d5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	a3 20 0e 00 00       	mov    %eax,0xe20
}
 9df:	c9                   	leave  
 9e0:	c3                   	ret    

000009e1 <morecore>:

static Header*
morecore(uint nu)
{
 9e1:	55                   	push   %ebp
 9e2:	89 e5                	mov    %esp,%ebp
 9e4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9ee:	77 07                	ja     9f7 <morecore+0x16>
    nu = 4096;
 9f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9f7:	8b 45 08             	mov    0x8(%ebp),%eax
 9fa:	c1 e0 03             	shl    $0x3,%eax
 9fd:	89 04 24             	mov    %eax,(%esp)
 a00:	e8 47 fb ff ff       	call   54c <sbrk>
 a05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a08:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a0c:	75 07                	jne    a15 <morecore+0x34>
    return 0;
 a0e:	b8 00 00 00 00       	mov    $0x0,%eax
 a13:	eb 22                	jmp    a37 <morecore+0x56>
  hp = (Header*)p;
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1e:	8b 55 08             	mov    0x8(%ebp),%edx
 a21:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a27:	83 c0 08             	add    $0x8,%eax
 a2a:	89 04 24             	mov    %eax,(%esp)
 a2d:	e8 ce fe ff ff       	call   900 <free>
  return freep;
 a32:	a1 20 0e 00 00       	mov    0xe20,%eax
}
 a37:	c9                   	leave  
 a38:	c3                   	ret    

00000a39 <malloc>:

void*
malloc(uint nbytes)
{
 a39:	55                   	push   %ebp
 a3a:	89 e5                	mov    %esp,%ebp
 a3c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3f:	8b 45 08             	mov    0x8(%ebp),%eax
 a42:	83 c0 07             	add    $0x7,%eax
 a45:	c1 e8 03             	shr    $0x3,%eax
 a48:	40                   	inc    %eax
 a49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a4c:	a1 20 0e 00 00       	mov    0xe20,%eax
 a51:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a58:	75 23                	jne    a7d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a5a:	c7 45 f0 18 0e 00 00 	movl   $0xe18,-0x10(%ebp)
 a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a64:	a3 20 0e 00 00       	mov    %eax,0xe20
 a69:	a1 20 0e 00 00       	mov    0xe20,%eax
 a6e:	a3 18 0e 00 00       	mov    %eax,0xe18
    base.s.size = 0;
 a73:	c7 05 1c 0e 00 00 00 	movl   $0x0,0xe1c
 a7a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a80:	8b 00                	mov    (%eax),%eax
 a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a88:	8b 40 04             	mov    0x4(%eax),%eax
 a8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a8e:	72 4d                	jb     add <malloc+0xa4>
      if(p->s.size == nunits)
 a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a93:	8b 40 04             	mov    0x4(%eax),%eax
 a96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a99:	75 0c                	jne    aa7 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9e:	8b 10                	mov    (%eax),%edx
 aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa3:	89 10                	mov    %edx,(%eax)
 aa5:	eb 26                	jmp    acd <malloc+0x94>
      else {
        p->s.size -= nunits;
 aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaa:	8b 40 04             	mov    0x4(%eax),%eax
 aad:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ab0:	89 c2                	mov    %eax,%edx
 ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	8b 40 04             	mov    0x4(%eax),%eax
 abe:	c1 e0 03             	shl    $0x3,%eax
 ac1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aca:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad0:	a3 20 0e 00 00       	mov    %eax,0xe20
      return (void*)(p + 1);
 ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad8:	83 c0 08             	add    $0x8,%eax
 adb:	eb 38                	jmp    b15 <malloc+0xdc>
    }
    if(p == freep)
 add:	a1 20 0e 00 00       	mov    0xe20,%eax
 ae2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae5:	75 1b                	jne    b02 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 aea:	89 04 24             	mov    %eax,(%esp)
 aed:	e8 ef fe ff ff       	call   9e1 <morecore>
 af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 af9:	75 07                	jne    b02 <malloc+0xc9>
        return 0;
 afb:	b8 00 00 00 00       	mov    $0x0,%eax
 b00:	eb 13                	jmp    b15 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b05:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0b:	8b 00                	mov    (%eax),%eax
 b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b10:	e9 70 ff ff ff       	jmp    a85 <malloc+0x4c>
}
 b15:	c9                   	leave  
 b16:	c3                   	ret    
