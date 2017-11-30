
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 62                	jmp    84 <wc+0x84>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 51                	jmp    7c <wc+0x7c>
      c++;
  2b:	ff 45 e8             	incl   -0x18(%ebp)
      if(buf[i] == '\n')
  2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  31:	05 00 0d 00 00       	add    $0xd00,%eax
  36:	8a 00                	mov    (%eax),%al
  38:	3c 0a                	cmp    $0xa,%al
  3a:	75 03                	jne    3f <wc+0x3f>
        l++;
  3c:	ff 45 f0             	incl   -0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  42:	05 00 0d 00 00       	add    $0xd00,%eax
  47:	8a 00                	mov    (%eax),%al
  49:	0f be c0             	movsbl %al,%eax
  4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  50:	c7 04 24 13 0a 00 00 	movl   $0xa13,(%esp)
  57:	e8 4c 02 00 00       	call   2a8 <strchr>
  5c:	85 c0                	test   %eax,%eax
  5e:	74 09                	je     69 <wc+0x69>
        inword = 0;
  60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  67:	eb 10                	jmp    79 <wc+0x79>
      else if(!inword){
  69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  6d:	75 0a                	jne    79 <wc+0x79>
        w++;
  6f:	ff 45 ec             	incl   -0x14(%ebp)
        inword = 1;
  72:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  79:	ff 45 f4             	incl   -0xc(%ebp)
  7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  82:	7c a7                	jl     2b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  84:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8b:	00 
  8c:	c7 44 24 04 00 0d 00 	movl   $0xd00,0x4(%esp)
  93:	00 
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	89 04 24             	mov    %eax,(%esp)
  9a:	e8 a1 03 00 00       	call   440 <read>
  9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  a6:	0f 8f 76 ff ff ff    	jg     22 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
  ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b0:	79 19                	jns    cb <wc+0xcb>
    printf(1, "wc: read error\n");
  b2:	c7 44 24 04 19 0a 00 	movl   $0xa19,0x4(%esp)
  b9:	00 
  ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c1:	e8 87 05 00 00       	call   64d <printf>
    exit();
  c6:	e8 5d 03 00 00       	call   428 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ce:	89 44 24 14          	mov    %eax,0x14(%esp)
  d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  e7:	c7 44 24 04 29 0a 00 	movl   $0xa29,0x4(%esp)
  ee:	00 
  ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f6:	e8 52 05 00 00       	call   64d <printf>
}
  fb:	c9                   	leave  
  fc:	c3                   	ret    

000000fd <main>:

int
main(int argc, char *argv[])
{
  fd:	55                   	push   %ebp
  fe:	89 e5                	mov    %esp,%ebp
 100:	83 e4 f0             	and    $0xfffffff0,%esp
 103:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
 106:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 10a:	7f 19                	jg     125 <main+0x28>
    wc(0, "");
 10c:	c7 44 24 04 36 0a 00 	movl   $0xa36,0x4(%esp)
 113:	00 
 114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 11b:	e8 e0 fe ff ff       	call   0 <wc>
    exit();
 120:	e8 03 03 00 00       	call   428 <exit>
  }

  for(i = 1; i < argc; i++){
 125:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 12c:	00 
 12d:	e9 8e 00 00 00       	jmp    1c0 <main+0xc3>
    if((fd = open(argv[i], 0)) < 0){
 132:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 13d:	8b 45 0c             	mov    0xc(%ebp),%eax
 140:	01 d0                	add    %edx,%eax
 142:	8b 00                	mov    (%eax),%eax
 144:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 14b:	00 
 14c:	89 04 24             	mov    %eax,(%esp)
 14f:	e8 14 03 00 00       	call   468 <open>
 154:	89 44 24 18          	mov    %eax,0x18(%esp)
 158:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 15d:	79 2f                	jns    18e <main+0x91>
      printf(1, "wc: cannot open %s\n", argv[i]);
 15f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 163:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 16a:	8b 45 0c             	mov    0xc(%ebp),%eax
 16d:	01 d0                	add    %edx,%eax
 16f:	8b 00                	mov    (%eax),%eax
 171:	89 44 24 08          	mov    %eax,0x8(%esp)
 175:	c7 44 24 04 37 0a 00 	movl   $0xa37,0x4(%esp)
 17c:	00 
 17d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 184:	e8 c4 04 00 00       	call   64d <printf>
      exit();
 189:	e8 9a 02 00 00       	call   428 <exit>
    }
    wc(fd, argv[i]);
 18e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 192:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 199:	8b 45 0c             	mov    0xc(%ebp),%eax
 19c:	01 d0                	add    %edx,%eax
 19e:	8b 00                	mov    (%eax),%eax
 1a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a4:	8b 44 24 18          	mov    0x18(%esp),%eax
 1a8:	89 04 24             	mov    %eax,(%esp)
 1ab:	e8 50 fe ff ff       	call   0 <wc>
    close(fd);
 1b0:	8b 44 24 18          	mov    0x18(%esp),%eax
 1b4:	89 04 24             	mov    %eax,(%esp)
 1b7:	e8 94 02 00 00       	call   450 <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
 1bc:	ff 44 24 1c          	incl   0x1c(%esp)
 1c0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1c4:	3b 45 08             	cmp    0x8(%ebp),%eax
 1c7:	0f 8c 65 ff ff ff    	jl     132 <main+0x35>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
 1cd:	e8 56 02 00 00       	call   428 <exit>
 1d2:	90                   	nop
 1d3:	90                   	nop

000001d4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	57                   	push   %edi
 1d8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1dc:	8b 55 10             	mov    0x10(%ebp),%edx
 1df:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e2:	89 cb                	mov    %ecx,%ebx
 1e4:	89 df                	mov    %ebx,%edi
 1e6:	89 d1                	mov    %edx,%ecx
 1e8:	fc                   	cld    
 1e9:	f3 aa                	rep stos %al,%es:(%edi)
 1eb:	89 ca                	mov    %ecx,%edx
 1ed:	89 fb                	mov    %edi,%ebx
 1ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f5:	5b                   	pop    %ebx
 1f6:	5f                   	pop    %edi
 1f7:	5d                   	pop    %ebp
 1f8:	c3                   	ret    

000001f9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 205:	90                   	nop
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	8d 50 01             	lea    0x1(%eax),%edx
 20c:	89 55 08             	mov    %edx,0x8(%ebp)
 20f:	8b 55 0c             	mov    0xc(%ebp),%edx
 212:	8d 4a 01             	lea    0x1(%edx),%ecx
 215:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 218:	8a 12                	mov    (%edx),%dl
 21a:	88 10                	mov    %dl,(%eax)
 21c:	8a 00                	mov    (%eax),%al
 21e:	84 c0                	test   %al,%al
 220:	75 e4                	jne    206 <strcpy+0xd>
    ;
  return os;
 222:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 225:	c9                   	leave  
 226:	c3                   	ret    

00000227 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 227:	55                   	push   %ebp
 228:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 22a:	eb 06                	jmp    232 <strcmp+0xb>
    p++, q++;
 22c:	ff 45 08             	incl   0x8(%ebp)
 22f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 232:	8b 45 08             	mov    0x8(%ebp),%eax
 235:	8a 00                	mov    (%eax),%al
 237:	84 c0                	test   %al,%al
 239:	74 0e                	je     249 <strcmp+0x22>
 23b:	8b 45 08             	mov    0x8(%ebp),%eax
 23e:	8a 10                	mov    (%eax),%dl
 240:	8b 45 0c             	mov    0xc(%ebp),%eax
 243:	8a 00                	mov    (%eax),%al
 245:	38 c2                	cmp    %al,%dl
 247:	74 e3                	je     22c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	8a 00                	mov    (%eax),%al
 24e:	0f b6 d0             	movzbl %al,%edx
 251:	8b 45 0c             	mov    0xc(%ebp),%eax
 254:	8a 00                	mov    (%eax),%al
 256:	0f b6 c0             	movzbl %al,%eax
 259:	29 c2                	sub    %eax,%edx
 25b:	89 d0                	mov    %edx,%eax
}
 25d:	5d                   	pop    %ebp
 25e:	c3                   	ret    

0000025f <strlen>:

uint
strlen(char *s)
{
 25f:	55                   	push   %ebp
 260:	89 e5                	mov    %esp,%ebp
 262:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 265:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 26c:	eb 03                	jmp    271 <strlen+0x12>
 26e:	ff 45 fc             	incl   -0x4(%ebp)
 271:	8b 55 fc             	mov    -0x4(%ebp),%edx
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	01 d0                	add    %edx,%eax
 279:	8a 00                	mov    (%eax),%al
 27b:	84 c0                	test   %al,%al
 27d:	75 ef                	jne    26e <strlen+0xf>
    ;
  return n;
 27f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 282:	c9                   	leave  
 283:	c3                   	ret    

00000284 <memset>:

void*
memset(void *dst, int c, uint n)
{
 284:	55                   	push   %ebp
 285:	89 e5                	mov    %esp,%ebp
 287:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 28a:	8b 45 10             	mov    0x10(%ebp),%eax
 28d:	89 44 24 08          	mov    %eax,0x8(%esp)
 291:	8b 45 0c             	mov    0xc(%ebp),%eax
 294:	89 44 24 04          	mov    %eax,0x4(%esp)
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	89 04 24             	mov    %eax,(%esp)
 29e:	e8 31 ff ff ff       	call   1d4 <stosb>
  return dst;
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a6:	c9                   	leave  
 2a7:	c3                   	ret    

000002a8 <strchr>:

char*
strchr(const char *s, char c)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 04             	sub    $0x4,%esp
 2ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b4:	eb 12                	jmp    2c8 <strchr+0x20>
    if(*s == c)
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
 2b9:	8a 00                	mov    (%eax),%al
 2bb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2be:	75 05                	jne    2c5 <strchr+0x1d>
      return (char*)s;
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	eb 11                	jmp    2d6 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2c5:	ff 45 08             	incl   0x8(%ebp)
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	8a 00                	mov    (%eax),%al
 2cd:	84 c0                	test   %al,%al
 2cf:	75 e5                	jne    2b6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d6:	c9                   	leave  
 2d7:	c3                   	ret    

000002d8 <gets>:

char*
gets(char *buf, int max)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
 2db:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e5:	eb 49                	jmp    330 <gets+0x58>
    cc = read(0, &c, 1);
 2e7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2ee:	00 
 2ef:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2fd:	e8 3e 01 00 00       	call   440 <read>
 302:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 305:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 309:	7f 02                	jg     30d <gets+0x35>
      break;
 30b:	eb 2c                	jmp    339 <gets+0x61>
    buf[i++] = c;
 30d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 310:	8d 50 01             	lea    0x1(%eax),%edx
 313:	89 55 f4             	mov    %edx,-0xc(%ebp)
 316:	89 c2                	mov    %eax,%edx
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	01 c2                	add    %eax,%edx
 31d:	8a 45 ef             	mov    -0x11(%ebp),%al
 320:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 322:	8a 45 ef             	mov    -0x11(%ebp),%al
 325:	3c 0a                	cmp    $0xa,%al
 327:	74 10                	je     339 <gets+0x61>
 329:	8a 45 ef             	mov    -0x11(%ebp),%al
 32c:	3c 0d                	cmp    $0xd,%al
 32e:	74 09                	je     339 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 330:	8b 45 f4             	mov    -0xc(%ebp),%eax
 333:	40                   	inc    %eax
 334:	3b 45 0c             	cmp    0xc(%ebp),%eax
 337:	7c ae                	jl     2e7 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 339:	8b 55 f4             	mov    -0xc(%ebp),%edx
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	01 d0                	add    %edx,%eax
 341:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <stat>:

int
stat(char *n, struct stat *st)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 356:	00 
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	89 04 24             	mov    %eax,(%esp)
 35d:	e8 06 01 00 00       	call   468 <open>
 362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 365:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 369:	79 07                	jns    372 <stat+0x29>
    return -1;
 36b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 370:	eb 23                	jmp    395 <stat+0x4c>
  r = fstat(fd, st);
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	89 44 24 04          	mov    %eax,0x4(%esp)
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 fc 00 00 00       	call   480 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 be 00 00 00       	call   450 <close>
  return r;
 392:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 395:	c9                   	leave  
 396:	c3                   	ret    

00000397 <atoi>:

int
atoi(const char *s)
{
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 39d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3a4:	eb 24                	jmp    3ca <atoi+0x33>
    n = n*10 + *s++ - '0';
 3a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a9:	89 d0                	mov    %edx,%eax
 3ab:	c1 e0 02             	shl    $0x2,%eax
 3ae:	01 d0                	add    %edx,%eax
 3b0:	01 c0                	add    %eax,%eax
 3b2:	89 c1                	mov    %eax,%ecx
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	8d 50 01             	lea    0x1(%eax),%edx
 3ba:	89 55 08             	mov    %edx,0x8(%ebp)
 3bd:	8a 00                	mov    (%eax),%al
 3bf:	0f be c0             	movsbl %al,%eax
 3c2:	01 c8                	add    %ecx,%eax
 3c4:	83 e8 30             	sub    $0x30,%eax
 3c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ca:	8b 45 08             	mov    0x8(%ebp),%eax
 3cd:	8a 00                	mov    (%eax),%al
 3cf:	3c 2f                	cmp    $0x2f,%al
 3d1:	7e 09                	jle    3dc <atoi+0x45>
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	8a 00                	mov    (%eax),%al
 3d8:	3c 39                	cmp    $0x39,%al
 3da:	7e ca                	jle    3a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3df:	c9                   	leave  
 3e0:	c3                   	ret    

000003e1 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3e1:	55                   	push   %ebp
 3e2:	89 e5                	mov    %esp,%ebp
 3e4:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f3:	eb 16                	jmp    40b <memmove+0x2a>
    *dst++ = *src++;
 3f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3f8:	8d 50 01             	lea    0x1(%eax),%edx
 3fb:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3fe:	8b 55 f8             	mov    -0x8(%ebp),%edx
 401:	8d 4a 01             	lea    0x1(%edx),%ecx
 404:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 407:	8a 12                	mov    (%edx),%dl
 409:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 40b:	8b 45 10             	mov    0x10(%ebp),%eax
 40e:	8d 50 ff             	lea    -0x1(%eax),%edx
 411:	89 55 10             	mov    %edx,0x10(%ebp)
 414:	85 c0                	test   %eax,%eax
 416:	7f dd                	jg     3f5 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 418:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41b:	c9                   	leave  
 41c:	c3                   	ret    
 41d:	90                   	nop
 41e:	90                   	nop
 41f:	90                   	nop

00000420 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 420:	b8 01 00 00 00       	mov    $0x1,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <exit>:
SYSCALL(exit)
 428:	b8 02 00 00 00       	mov    $0x2,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <wait>:
SYSCALL(wait)
 430:	b8 03 00 00 00       	mov    $0x3,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <pipe>:
SYSCALL(pipe)
 438:	b8 04 00 00 00       	mov    $0x4,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <read>:
SYSCALL(read)
 440:	b8 05 00 00 00       	mov    $0x5,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <write>:
SYSCALL(write)
 448:	b8 10 00 00 00       	mov    $0x10,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <close>:
SYSCALL(close)
 450:	b8 15 00 00 00       	mov    $0x15,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <kill>:
SYSCALL(kill)
 458:	b8 06 00 00 00       	mov    $0x6,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <exec>:
SYSCALL(exec)
 460:	b8 07 00 00 00       	mov    $0x7,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <open>:
SYSCALL(open)
 468:	b8 0f 00 00 00       	mov    $0xf,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <mknod>:
SYSCALL(mknod)
 470:	b8 11 00 00 00       	mov    $0x11,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <unlink>:
SYSCALL(unlink)
 478:	b8 12 00 00 00       	mov    $0x12,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <fstat>:
SYSCALL(fstat)
 480:	b8 08 00 00 00       	mov    $0x8,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <link>:
SYSCALL(link)
 488:	b8 13 00 00 00       	mov    $0x13,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <mkdir>:
SYSCALL(mkdir)
 490:	b8 14 00 00 00       	mov    $0x14,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <chdir>:
SYSCALL(chdir)
 498:	b8 09 00 00 00       	mov    $0x9,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <dup>:
SYSCALL(dup)
 4a0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <getpid>:
SYSCALL(getpid)
 4a8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <sbrk>:
SYSCALL(sbrk)
 4b0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <sleep>:
SYSCALL(sleep)
 4b8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <uptime>:
SYSCALL(uptime)
 4c0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <getticks>:
SYSCALL(getticks)
 4c8:	b8 16 00 00 00       	mov    $0x16,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <get_name>:
SYSCALL(get_name)
 4d0:	b8 17 00 00 00       	mov    $0x17,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <get_max_proc>:
SYSCALL(get_max_proc)
 4d8:	b8 18 00 00 00       	mov    $0x18,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <get_max_mem>:
SYSCALL(get_max_mem)
 4e0:	b8 19 00 00 00       	mov    $0x19,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <get_max_disk>:
SYSCALL(get_max_disk)
 4e8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <get_curr_proc>:
SYSCALL(get_curr_proc)
 4f0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <get_curr_mem>:
SYSCALL(get_curr_mem)
 4f8:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <get_curr_disk>:
SYSCALL(get_curr_disk)
 500:	b8 1d 00 00 00       	mov    $0x1d,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <set_name>:
SYSCALL(set_name)
 508:	b8 1e 00 00 00       	mov    $0x1e,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <set_max_mem>:
SYSCALL(set_max_mem)
 510:	b8 1f 00 00 00       	mov    $0x1f,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <set_max_disk>:
SYSCALL(set_max_disk)
 518:	b8 20 00 00 00       	mov    $0x20,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <set_max_proc>:
SYSCALL(set_max_proc)
 520:	b8 21 00 00 00       	mov    $0x21,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <set_curr_mem>:
SYSCALL(set_curr_mem)
 528:	b8 22 00 00 00       	mov    $0x22,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <set_curr_disk>:
SYSCALL(set_curr_disk)
 530:	b8 23 00 00 00       	mov    $0x23,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <set_curr_proc>:
SYSCALL(set_curr_proc)
 538:	b8 24 00 00 00       	mov    $0x24,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <find>:
SYSCALL(find)
 540:	b8 25 00 00 00       	mov    $0x25,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <is_full>:
SYSCALL(is_full)
 548:	b8 26 00 00 00       	mov    $0x26,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <container_init>:
SYSCALL(container_init)
 550:	b8 27 00 00 00       	mov    $0x27,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <cont_proc_set>:
SYSCALL(cont_proc_set)
 558:	b8 28 00 00 00       	mov    $0x28,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <ps>:
SYSCALL(ps)
 560:	b8 29 00 00 00       	mov    $0x29,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 568:	b8 2a 00 00 00       	mov    $0x2a,%eax
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
 591:	e8 b2 fe ff ff       	call   448 <write>
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
 5e9:	8a 80 b8 0c 00 00    	mov    0xcb8(%eax),%al
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
 744:	c7 45 f4 4b 0a 00 00 	movl   $0xa4b,-0xc(%ebp)
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
 80b:	a1 e8 0c 00 00       	mov    0xce8,%eax
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
 8d6:	a3 e8 0c 00 00       	mov    %eax,0xce8
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
 8fc:	e8 af fb ff ff       	call   4b0 <sbrk>
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
 92e:	a1 e8 0c 00 00       	mov    0xce8,%eax
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
 948:	a1 e8 0c 00 00       	mov    0xce8,%eax
 94d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 954:	75 23                	jne    979 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 956:	c7 45 f0 e0 0c 00 00 	movl   $0xce0,-0x10(%ebp)
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	a3 e8 0c 00 00       	mov    %eax,0xce8
 965:	a1 e8 0c 00 00       	mov    0xce8,%eax
 96a:	a3 e0 0c 00 00       	mov    %eax,0xce0
    base.s.size = 0;
 96f:	c7 05 e4 0c 00 00 00 	movl   $0x0,0xce4
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
 9cc:	a3 e8 0c 00 00       	mov    %eax,0xce8
      return (void*)(p + 1);
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	83 c0 08             	add    $0x8,%eax
 9d7:	eb 38                	jmp    a11 <malloc+0xdc>
    }
    if(p == freep)
 9d9:	a1 e8 0c 00 00       	mov    0xce8,%eax
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
