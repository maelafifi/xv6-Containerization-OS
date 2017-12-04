
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
   6:	c7 45 f0 0a 0b 00 00 	movl   $0xb0a,-0x10(%ebp)

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
  87:	c7 04 24 0e 0b 00 00 	movl   $0xb0e,(%esp)
  8e:	e8 71 04 00 00       	call   504 <open>
  93:	85 c0                	test   %eax,%eax
  95:	79 30                	jns    c7 <main+0x51>
    mknod("console", 1, 1);
  97:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  9e:	00 
  9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  a6:	00 
  a7:	c7 04 24 0e 0b 00 00 	movl   $0xb0e,(%esp)
  ae:	e8 59 04 00 00       	call   50c <mknod>
    open("console", O_RDWR);
  b3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  ba:	00 
  bb:	c7 04 24 0e 0b 00 00 	movl   $0xb0e,(%esp)
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
  e4:	c7 44 24 04 16 0b 00 	movl   $0xb16,0x4(%esp)
  eb:	00 
  ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f3:	e8 49 06 00 00       	call   741 <printf>
    pid = fork();
  f8:	e8 bf 03 00 00       	call   4bc <fork>
  fd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
 101:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
 106:	79 19                	jns    121 <main+0xab>
      printf(1, "init: fork failed\n");
 108:	c7 44 24 04 29 0b 00 	movl   $0xb29,0x4(%esp)
 10f:	00 
 110:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 117:	e8 25 06 00 00       	call   741 <printf>
      exit();
 11c:	e8 a3 03 00 00       	call   4c4 <exit>
    }
    if(pid == 0){
 121:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
 126:	75 2d                	jne    155 <main+0xdf>
      exec("sh", argv);
 128:	c7 44 24 04 ec 0d 00 	movl   $0xdec,0x4(%esp)
 12f:	00 
 130:	c7 04 24 07 0b 00 00 	movl   $0xb07,(%esp)
 137:	e8 c0 03 00 00       	call   4fc <exec>
      printf(1, "init: exec sh failed\n");
 13c:	c7 44 24 04 3c 0b 00 	movl   $0xb3c,0x4(%esp)
 143:	00 
 144:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 14b:	e8 f1 05 00 00       	call   741 <printf>
      exit();
 150:	e8 6f 03 00 00       	call   4c4 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
 155:	eb 14                	jmp    16b <main+0xf5>
      printf(1, "zombie!\n");
 157:	c7 44 24 04 52 0b 00 	movl   $0xb52,0x4(%esp)
 15e:	00 
 15f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 166:	e8 d6 05 00 00       	call   741 <printf>
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

00000664 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 664:	55                   	push   %ebp
 665:	89 e5                	mov    %esp,%ebp
 667:	83 ec 18             	sub    $0x18,%esp
 66a:	8b 45 0c             	mov    0xc(%ebp),%eax
 66d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 670:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 677:	00 
 678:	8d 45 f4             	lea    -0xc(%ebp),%eax
 67b:	89 44 24 04          	mov    %eax,0x4(%esp)
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	89 04 24             	mov    %eax,(%esp)
 685:	e8 5a fe ff ff       	call   4e4 <write>
}
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	56                   	push   %esi
 690:	53                   	push   %ebx
 691:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 694:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 69b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 69f:	74 17                	je     6b8 <printint+0x2c>
 6a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6a5:	79 11                	jns    6b8 <printint+0x2c>
    neg = 1;
 6a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b1:	f7 d8                	neg    %eax
 6b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b6:	eb 06                	jmp    6be <printint+0x32>
  } else {
    x = xx;
 6b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6c5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6c8:	8d 41 01             	lea    0x1(%ecx),%eax
 6cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d4:	ba 00 00 00 00       	mov    $0x0,%edx
 6d9:	f7 f3                	div    %ebx
 6db:	89 d0                	mov    %edx,%eax
 6dd:	8a 80 f4 0d 00 00    	mov    0xdf4(%eax),%al
 6e3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6e7:	8b 75 10             	mov    0x10(%ebp),%esi
 6ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6ed:	ba 00 00 00 00       	mov    $0x0,%edx
 6f2:	f7 f6                	div    %esi
 6f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6fb:	75 c8                	jne    6c5 <printint+0x39>
  if(neg)
 6fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 701:	74 10                	je     713 <printint+0x87>
    buf[i++] = '-';
 703:	8b 45 f4             	mov    -0xc(%ebp),%eax
 706:	8d 50 01             	lea    0x1(%eax),%edx
 709:	89 55 f4             	mov    %edx,-0xc(%ebp)
 70c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 711:	eb 1e                	jmp    731 <printint+0xa5>
 713:	eb 1c                	jmp    731 <printint+0xa5>
    putc(fd, buf[i]);
 715:	8d 55 dc             	lea    -0x24(%ebp),%edx
 718:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71b:	01 d0                	add    %edx,%eax
 71d:	8a 00                	mov    (%eax),%al
 71f:	0f be c0             	movsbl %al,%eax
 722:	89 44 24 04          	mov    %eax,0x4(%esp)
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 33 ff ff ff       	call   664 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 731:	ff 4d f4             	decl   -0xc(%ebp)
 734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 738:	79 db                	jns    715 <printint+0x89>
    putc(fd, buf[i]);
}
 73a:	83 c4 30             	add    $0x30,%esp
 73d:	5b                   	pop    %ebx
 73e:	5e                   	pop    %esi
 73f:	5d                   	pop    %ebp
 740:	c3                   	ret    

00000741 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 741:	55                   	push   %ebp
 742:	89 e5                	mov    %esp,%ebp
 744:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 747:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 74e:	8d 45 0c             	lea    0xc(%ebp),%eax
 751:	83 c0 04             	add    $0x4,%eax
 754:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 757:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 75e:	e9 77 01 00 00       	jmp    8da <printf+0x199>
    c = fmt[i] & 0xff;
 763:	8b 55 0c             	mov    0xc(%ebp),%edx
 766:	8b 45 f0             	mov    -0x10(%ebp),%eax
 769:	01 d0                	add    %edx,%eax
 76b:	8a 00                	mov    (%eax),%al
 76d:	0f be c0             	movsbl %al,%eax
 770:	25 ff 00 00 00       	and    $0xff,%eax
 775:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 778:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 77c:	75 2c                	jne    7aa <printf+0x69>
      if(c == '%'){
 77e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 782:	75 0c                	jne    790 <printf+0x4f>
        state = '%';
 784:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 78b:	e9 47 01 00 00       	jmp    8d7 <printf+0x196>
      } else {
        putc(fd, c);
 790:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 793:	0f be c0             	movsbl %al,%eax
 796:	89 44 24 04          	mov    %eax,0x4(%esp)
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	89 04 24             	mov    %eax,(%esp)
 7a0:	e8 bf fe ff ff       	call   664 <putc>
 7a5:	e9 2d 01 00 00       	jmp    8d7 <printf+0x196>
      }
    } else if(state == '%'){
 7aa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7ae:	0f 85 23 01 00 00    	jne    8d7 <printf+0x196>
      if(c == 'd'){
 7b4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7b8:	75 2d                	jne    7e7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 7ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bd:	8b 00                	mov    (%eax),%eax
 7bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7c6:	00 
 7c7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7ce:	00 
 7cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d3:	8b 45 08             	mov    0x8(%ebp),%eax
 7d6:	89 04 24             	mov    %eax,(%esp)
 7d9:	e8 ae fe ff ff       	call   68c <printint>
        ap++;
 7de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e2:	e9 e9 00 00 00       	jmp    8d0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 7e7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7eb:	74 06                	je     7f3 <printf+0xb2>
 7ed:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f1:	75 2d                	jne    820 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 7f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7ff:	00 
 800:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 807:	00 
 808:	89 44 24 04          	mov    %eax,0x4(%esp)
 80c:	8b 45 08             	mov    0x8(%ebp),%eax
 80f:	89 04 24             	mov    %eax,(%esp)
 812:	e8 75 fe ff ff       	call   68c <printint>
        ap++;
 817:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 81b:	e9 b0 00 00 00       	jmp    8d0 <printf+0x18f>
      } else if(c == 's'){
 820:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 824:	75 42                	jne    868 <printf+0x127>
        s = (char*)*ap;
 826:	8b 45 e8             	mov    -0x18(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 82e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 832:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 836:	75 09                	jne    841 <printf+0x100>
          s = "(null)";
 838:	c7 45 f4 5b 0b 00 00 	movl   $0xb5b,-0xc(%ebp)
        while(*s != 0){
 83f:	eb 1c                	jmp    85d <printf+0x11c>
 841:	eb 1a                	jmp    85d <printf+0x11c>
          putc(fd, *s);
 843:	8b 45 f4             	mov    -0xc(%ebp),%eax
 846:	8a 00                	mov    (%eax),%al
 848:	0f be c0             	movsbl %al,%eax
 84b:	89 44 24 04          	mov    %eax,0x4(%esp)
 84f:	8b 45 08             	mov    0x8(%ebp),%eax
 852:	89 04 24             	mov    %eax,(%esp)
 855:	e8 0a fe ff ff       	call   664 <putc>
          s++;
 85a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	8a 00                	mov    (%eax),%al
 862:	84 c0                	test   %al,%al
 864:	75 dd                	jne    843 <printf+0x102>
 866:	eb 68                	jmp    8d0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 868:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 86c:	75 1d                	jne    88b <printf+0x14a>
        putc(fd, *ap);
 86e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 871:	8b 00                	mov    (%eax),%eax
 873:	0f be c0             	movsbl %al,%eax
 876:	89 44 24 04          	mov    %eax,0x4(%esp)
 87a:	8b 45 08             	mov    0x8(%ebp),%eax
 87d:	89 04 24             	mov    %eax,(%esp)
 880:	e8 df fd ff ff       	call   664 <putc>
        ap++;
 885:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 889:	eb 45                	jmp    8d0 <printf+0x18f>
      } else if(c == '%'){
 88b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 88f:	75 17                	jne    8a8 <printf+0x167>
        putc(fd, c);
 891:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 894:	0f be c0             	movsbl %al,%eax
 897:	89 44 24 04          	mov    %eax,0x4(%esp)
 89b:	8b 45 08             	mov    0x8(%ebp),%eax
 89e:	89 04 24             	mov    %eax,(%esp)
 8a1:	e8 be fd ff ff       	call   664 <putc>
 8a6:	eb 28                	jmp    8d0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8a8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8af:	00 
 8b0:	8b 45 08             	mov    0x8(%ebp),%eax
 8b3:	89 04 24             	mov    %eax,(%esp)
 8b6:	e8 a9 fd ff ff       	call   664 <putc>
        putc(fd, c);
 8bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8be:	0f be c0             	movsbl %al,%eax
 8c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c5:	8b 45 08             	mov    0x8(%ebp),%eax
 8c8:	89 04 24             	mov    %eax,(%esp)
 8cb:	e8 94 fd ff ff       	call   664 <putc>
      }
      state = 0;
 8d0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8d7:	ff 45 f0             	incl   -0x10(%ebp)
 8da:	8b 55 0c             	mov    0xc(%ebp),%edx
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	01 d0                	add    %edx,%eax
 8e2:	8a 00                	mov    (%eax),%al
 8e4:	84 c0                	test   %al,%al
 8e6:	0f 85 77 fe ff ff    	jne    763 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8ec:	c9                   	leave  
 8ed:	c3                   	ret    
 8ee:	90                   	nop
 8ef:	90                   	nop

000008f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f0:	55                   	push   %ebp
 8f1:	89 e5                	mov    %esp,%ebp
 8f3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f6:	8b 45 08             	mov    0x8(%ebp),%eax
 8f9:	83 e8 08             	sub    $0x8,%eax
 8fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ff:	a1 10 0e 00 00       	mov    0xe10,%eax
 904:	89 45 fc             	mov    %eax,-0x4(%ebp)
 907:	eb 24                	jmp    92d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 911:	77 12                	ja     925 <free+0x35>
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 919:	77 24                	ja     93f <free+0x4f>
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	8b 00                	mov    (%eax),%eax
 920:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 923:	77 1a                	ja     93f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 92d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 930:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 933:	76 d4                	jbe    909 <free+0x19>
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 93d:	76 ca                	jbe    909 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 94c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94f:	01 c2                	add    %eax,%edx
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	39 c2                	cmp    %eax,%edx
 958:	75 24                	jne    97e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 95a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95d:	8b 50 04             	mov    0x4(%eax),%edx
 960:	8b 45 fc             	mov    -0x4(%ebp),%eax
 963:	8b 00                	mov    (%eax),%eax
 965:	8b 40 04             	mov    0x4(%eax),%eax
 968:	01 c2                	add    %eax,%edx
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	8b 10                	mov    (%eax),%edx
 977:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97a:	89 10                	mov    %edx,(%eax)
 97c:	eb 0a                	jmp    988 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 97e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 981:	8b 10                	mov    (%eax),%edx
 983:	8b 45 f8             	mov    -0x8(%ebp),%eax
 986:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	8b 40 04             	mov    0x4(%eax),%eax
 98e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 995:	8b 45 fc             	mov    -0x4(%ebp),%eax
 998:	01 d0                	add    %edx,%eax
 99a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 99d:	75 20                	jne    9bf <free+0xcf>
    p->s.size += bp->s.size;
 99f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a2:	8b 50 04             	mov    0x4(%eax),%edx
 9a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a8:	8b 40 04             	mov    0x4(%eax),%eax
 9ab:	01 c2                	add    %eax,%edx
 9ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b6:	8b 10                	mov    (%eax),%edx
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	89 10                	mov    %edx,(%eax)
 9bd:	eb 08                	jmp    9c7 <free+0xd7>
  } else
    p->s.ptr = bp;
 9bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9c5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ca:	a3 10 0e 00 00       	mov    %eax,0xe10
}
 9cf:	c9                   	leave  
 9d0:	c3                   	ret    

000009d1 <morecore>:

static Header*
morecore(uint nu)
{
 9d1:	55                   	push   %ebp
 9d2:	89 e5                	mov    %esp,%ebp
 9d4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9d7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9de:	77 07                	ja     9e7 <morecore+0x16>
    nu = 4096;
 9e0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9e7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ea:	c1 e0 03             	shl    $0x3,%eax
 9ed:	89 04 24             	mov    %eax,(%esp)
 9f0:	e8 57 fb ff ff       	call   54c <sbrk>
 9f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9f8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9fc:	75 07                	jne    a05 <morecore+0x34>
    return 0;
 9fe:	b8 00 00 00 00       	mov    $0x0,%eax
 a03:	eb 22                	jmp    a27 <morecore+0x56>
  hp = (Header*)p;
 a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0e:	8b 55 08             	mov    0x8(%ebp),%edx
 a11:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a17:	83 c0 08             	add    $0x8,%eax
 a1a:	89 04 24             	mov    %eax,(%esp)
 a1d:	e8 ce fe ff ff       	call   8f0 <free>
  return freep;
 a22:	a1 10 0e 00 00       	mov    0xe10,%eax
}
 a27:	c9                   	leave  
 a28:	c3                   	ret    

00000a29 <malloc>:

void*
malloc(uint nbytes)
{
 a29:	55                   	push   %ebp
 a2a:	89 e5                	mov    %esp,%ebp
 a2c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a2f:	8b 45 08             	mov    0x8(%ebp),%eax
 a32:	83 c0 07             	add    $0x7,%eax
 a35:	c1 e8 03             	shr    $0x3,%eax
 a38:	40                   	inc    %eax
 a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a3c:	a1 10 0e 00 00       	mov    0xe10,%eax
 a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a48:	75 23                	jne    a6d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a4a:	c7 45 f0 08 0e 00 00 	movl   $0xe08,-0x10(%ebp)
 a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a54:	a3 10 0e 00 00       	mov    %eax,0xe10
 a59:	a1 10 0e 00 00       	mov    0xe10,%eax
 a5e:	a3 08 0e 00 00       	mov    %eax,0xe08
    base.s.size = 0;
 a63:	c7 05 0c 0e 00 00 00 	movl   $0x0,0xe0c
 a6a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a70:	8b 00                	mov    (%eax),%eax
 a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a78:	8b 40 04             	mov    0x4(%eax),%eax
 a7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a7e:	72 4d                	jb     acd <malloc+0xa4>
      if(p->s.size == nunits)
 a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a83:	8b 40 04             	mov    0x4(%eax),%eax
 a86:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a89:	75 0c                	jne    a97 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8e:	8b 10                	mov    (%eax),%edx
 a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a93:	89 10                	mov    %edx,(%eax)
 a95:	eb 26                	jmp    abd <malloc+0x94>
      else {
        p->s.size -= nunits;
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	8b 40 04             	mov    0x4(%eax),%eax
 a9d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aa0:	89 c2                	mov    %eax,%edx
 aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aab:	8b 40 04             	mov    0x4(%eax),%eax
 aae:	c1 e0 03             	shl    $0x3,%eax
 ab1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aba:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac0:	a3 10 0e 00 00       	mov    %eax,0xe10
      return (void*)(p + 1);
 ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac8:	83 c0 08             	add    $0x8,%eax
 acb:	eb 38                	jmp    b05 <malloc+0xdc>
    }
    if(p == freep)
 acd:	a1 10 0e 00 00       	mov    0xe10,%eax
 ad2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad5:	75 1b                	jne    af2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 ad7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ada:	89 04 24             	mov    %eax,(%esp)
 add:	e8 ef fe ff ff       	call   9d1 <morecore>
 ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae9:	75 07                	jne    af2 <malloc+0xc9>
        return 0;
 aeb:	b8 00 00 00 00       	mov    $0x0,%eax
 af0:	eb 13                	jmp    b05 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afb:	8b 00                	mov    (%eax),%eax
 afd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b00:	e9 70 ff ff ff       	jmp    a75 <malloc+0x4c>
}
 b05:	c9                   	leave  
 b06:	c3                   	ret    
