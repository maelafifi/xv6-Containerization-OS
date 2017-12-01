
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
  31:	05 20 0d 00 00       	add    $0xd20,%eax
  36:	8a 00                	mov    (%eax),%al
  38:	3c 0a                	cmp    $0xa,%al
  3a:	75 03                	jne    3f <wc+0x3f>
        l++;
  3c:	ff 45 f0             	incl   -0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  42:	05 20 0d 00 00       	add    $0xd20,%eax
  47:	8a 00                	mov    (%eax),%al
  49:	0f be c0             	movsbl %al,%eax
  4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  50:	c7 04 24 2b 0a 00 00 	movl   $0xa2b,(%esp)
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
  8c:	c7 44 24 04 20 0d 00 	movl   $0xd20,0x4(%esp)
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
  b2:	c7 44 24 04 31 0a 00 	movl   $0xa31,0x4(%esp)
  b9:	00 
  ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c1:	e8 9f 05 00 00       	call   665 <printf>
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
  e7:	c7 44 24 04 41 0a 00 	movl   $0xa41,0x4(%esp)
  ee:	00 
  ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f6:	e8 6a 05 00 00       	call   665 <printf>
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
 10c:	c7 44 24 04 4e 0a 00 	movl   $0xa4e,0x4(%esp)
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
 175:	c7 44 24 04 4f 0a 00 	movl   $0xa4f,0x4(%esp)
 17c:	00 
 17d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 184:	e8 dc 04 00 00       	call   665 <printf>
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

00000570 <set_root_inode>:
SYSCALL(set_root_inode)
 570:	b8 2b 00 00 00       	mov    $0x2b,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <cstop>:
SYSCALL(cstop)
 578:	b8 2c 00 00 00       	mov    $0x2c,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <df>:
SYSCALL(df)
 580:	b8 2d 00 00 00       	mov    $0x2d,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 588:	55                   	push   %ebp
 589:	89 e5                	mov    %esp,%ebp
 58b:	83 ec 18             	sub    $0x18,%esp
 58e:	8b 45 0c             	mov    0xc(%ebp),%eax
 591:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 594:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 59b:	00 
 59c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 59f:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	89 04 24             	mov    %eax,(%esp)
 5a9:	e8 9a fe ff ff       	call   448 <write>
}
 5ae:	c9                   	leave  
 5af:	c3                   	ret    

000005b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	56                   	push   %esi
 5b4:	53                   	push   %ebx
 5b5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5bf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5c3:	74 17                	je     5dc <printint+0x2c>
 5c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c9:	79 11                	jns    5dc <printint+0x2c>
    neg = 1;
 5cb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d5:	f7 d8                	neg    %eax
 5d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5da:	eb 06                	jmp    5e2 <printint+0x32>
  } else {
    x = xx;
 5dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5e9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5ec:	8d 41 01             	lea    0x1(%ecx),%eax
 5ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5f8:	ba 00 00 00 00       	mov    $0x0,%edx
 5fd:	f7 f3                	div    %ebx
 5ff:	89 d0                	mov    %edx,%eax
 601:	8a 80 d0 0c 00 00    	mov    0xcd0(%eax),%al
 607:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 60b:	8b 75 10             	mov    0x10(%ebp),%esi
 60e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 611:	ba 00 00 00 00       	mov    $0x0,%edx
 616:	f7 f6                	div    %esi
 618:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61f:	75 c8                	jne    5e9 <printint+0x39>
  if(neg)
 621:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 625:	74 10                	je     637 <printint+0x87>
    buf[i++] = '-';
 627:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62a:	8d 50 01             	lea    0x1(%eax),%edx
 62d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 630:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 635:	eb 1e                	jmp    655 <printint+0xa5>
 637:	eb 1c                	jmp    655 <printint+0xa5>
    putc(fd, buf[i]);
 639:	8d 55 dc             	lea    -0x24(%ebp),%edx
 63c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63f:	01 d0                	add    %edx,%eax
 641:	8a 00                	mov    (%eax),%al
 643:	0f be c0             	movsbl %al,%eax
 646:	89 44 24 04          	mov    %eax,0x4(%esp)
 64a:	8b 45 08             	mov    0x8(%ebp),%eax
 64d:	89 04 24             	mov    %eax,(%esp)
 650:	e8 33 ff ff ff       	call   588 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 655:	ff 4d f4             	decl   -0xc(%ebp)
 658:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 65c:	79 db                	jns    639 <printint+0x89>
    putc(fd, buf[i]);
}
 65e:	83 c4 30             	add    $0x30,%esp
 661:	5b                   	pop    %ebx
 662:	5e                   	pop    %esi
 663:	5d                   	pop    %ebp
 664:	c3                   	ret    

00000665 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 665:	55                   	push   %ebp
 666:	89 e5                	mov    %esp,%ebp
 668:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 66b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 672:	8d 45 0c             	lea    0xc(%ebp),%eax
 675:	83 c0 04             	add    $0x4,%eax
 678:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 67b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 682:	e9 77 01 00 00       	jmp    7fe <printf+0x199>
    c = fmt[i] & 0xff;
 687:	8b 55 0c             	mov    0xc(%ebp),%edx
 68a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 68d:	01 d0                	add    %edx,%eax
 68f:	8a 00                	mov    (%eax),%al
 691:	0f be c0             	movsbl %al,%eax
 694:	25 ff 00 00 00       	and    $0xff,%eax
 699:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 69c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a0:	75 2c                	jne    6ce <printf+0x69>
      if(c == '%'){
 6a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a6:	75 0c                	jne    6b4 <printf+0x4f>
        state = '%';
 6a8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6af:	e9 47 01 00 00       	jmp    7fb <printf+0x196>
      } else {
        putc(fd, c);
 6b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b7:	0f be c0             	movsbl %al,%eax
 6ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 6be:	8b 45 08             	mov    0x8(%ebp),%eax
 6c1:	89 04 24             	mov    %eax,(%esp)
 6c4:	e8 bf fe ff ff       	call   588 <putc>
 6c9:	e9 2d 01 00 00       	jmp    7fb <printf+0x196>
      }
    } else if(state == '%'){
 6ce:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6d2:	0f 85 23 01 00 00    	jne    7fb <printf+0x196>
      if(c == 'd'){
 6d8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6dc:	75 2d                	jne    70b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e1:	8b 00                	mov    (%eax),%eax
 6e3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6ea:	00 
 6eb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6f2:	00 
 6f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	89 04 24             	mov    %eax,(%esp)
 6fd:	e8 ae fe ff ff       	call   5b0 <printint>
        ap++;
 702:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 706:	e9 e9 00 00 00       	jmp    7f4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 70b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 70f:	74 06                	je     717 <printf+0xb2>
 711:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 715:	75 2d                	jne    744 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 717:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71a:	8b 00                	mov    (%eax),%eax
 71c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 723:	00 
 724:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 72b:	00 
 72c:	89 44 24 04          	mov    %eax,0x4(%esp)
 730:	8b 45 08             	mov    0x8(%ebp),%eax
 733:	89 04 24             	mov    %eax,(%esp)
 736:	e8 75 fe ff ff       	call   5b0 <printint>
        ap++;
 73b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73f:	e9 b0 00 00 00       	jmp    7f4 <printf+0x18f>
      } else if(c == 's'){
 744:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 748:	75 42                	jne    78c <printf+0x127>
        s = (char*)*ap;
 74a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 752:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 756:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75a:	75 09                	jne    765 <printf+0x100>
          s = "(null)";
 75c:	c7 45 f4 63 0a 00 00 	movl   $0xa63,-0xc(%ebp)
        while(*s != 0){
 763:	eb 1c                	jmp    781 <printf+0x11c>
 765:	eb 1a                	jmp    781 <printf+0x11c>
          putc(fd, *s);
 767:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76a:	8a 00                	mov    (%eax),%al
 76c:	0f be c0             	movsbl %al,%eax
 76f:	89 44 24 04          	mov    %eax,0x4(%esp)
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 04 24             	mov    %eax,(%esp)
 779:	e8 0a fe ff ff       	call   588 <putc>
          s++;
 77e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	8a 00                	mov    (%eax),%al
 786:	84 c0                	test   %al,%al
 788:	75 dd                	jne    767 <printf+0x102>
 78a:	eb 68                	jmp    7f4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 78c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 790:	75 1d                	jne    7af <printf+0x14a>
        putc(fd, *ap);
 792:	8b 45 e8             	mov    -0x18(%ebp),%eax
 795:	8b 00                	mov    (%eax),%eax
 797:	0f be c0             	movsbl %al,%eax
 79a:	89 44 24 04          	mov    %eax,0x4(%esp)
 79e:	8b 45 08             	mov    0x8(%ebp),%eax
 7a1:	89 04 24             	mov    %eax,(%esp)
 7a4:	e8 df fd ff ff       	call   588 <putc>
        ap++;
 7a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ad:	eb 45                	jmp    7f4 <printf+0x18f>
      } else if(c == '%'){
 7af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b3:	75 17                	jne    7cc <printf+0x167>
        putc(fd, c);
 7b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b8:	0f be c0             	movsbl %al,%eax
 7bb:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bf:	8b 45 08             	mov    0x8(%ebp),%eax
 7c2:	89 04 24             	mov    %eax,(%esp)
 7c5:	e8 be fd ff ff       	call   588 <putc>
 7ca:	eb 28                	jmp    7f4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7cc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7d3:	00 
 7d4:	8b 45 08             	mov    0x8(%ebp),%eax
 7d7:	89 04 24             	mov    %eax,(%esp)
 7da:	e8 a9 fd ff ff       	call   588 <putc>
        putc(fd, c);
 7df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e2:	0f be c0             	movsbl %al,%eax
 7e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ec:	89 04 24             	mov    %eax,(%esp)
 7ef:	e8 94 fd ff ff       	call   588 <putc>
      }
      state = 0;
 7f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7fb:	ff 45 f0             	incl   -0x10(%ebp)
 7fe:	8b 55 0c             	mov    0xc(%ebp),%edx
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	01 d0                	add    %edx,%eax
 806:	8a 00                	mov    (%eax),%al
 808:	84 c0                	test   %al,%al
 80a:	0f 85 77 fe ff ff    	jne    687 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 810:	c9                   	leave  
 811:	c3                   	ret    
 812:	90                   	nop
 813:	90                   	nop

00000814 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 814:	55                   	push   %ebp
 815:	89 e5                	mov    %esp,%ebp
 817:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81a:	8b 45 08             	mov    0x8(%ebp),%eax
 81d:	83 e8 08             	sub    $0x8,%eax
 820:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 823:	a1 08 0d 00 00       	mov    0xd08,%eax
 828:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82b:	eb 24                	jmp    851 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 835:	77 12                	ja     849 <free+0x35>
 837:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83d:	77 24                	ja     863 <free+0x4f>
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	8b 00                	mov    (%eax),%eax
 844:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 847:	77 1a                	ja     863 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 851:	8b 45 f8             	mov    -0x8(%ebp),%eax
 854:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 857:	76 d4                	jbe    82d <free+0x19>
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 861:	76 ca                	jbe    82d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 870:	8b 45 f8             	mov    -0x8(%ebp),%eax
 873:	01 c2                	add    %eax,%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	8b 00                	mov    (%eax),%eax
 87a:	39 c2                	cmp    %eax,%edx
 87c:	75 24                	jne    8a2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 87e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 881:	8b 50 04             	mov    0x4(%eax),%edx
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	8b 00                	mov    (%eax),%eax
 889:	8b 40 04             	mov    0x4(%eax),%eax
 88c:	01 c2                	add    %eax,%edx
 88e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 891:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	8b 45 fc             	mov    -0x4(%ebp),%eax
 897:	8b 00                	mov    (%eax),%eax
 899:	8b 10                	mov    (%eax),%edx
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	89 10                	mov    %edx,(%eax)
 8a0:	eb 0a                	jmp    8ac <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a5:	8b 10                	mov    (%eax),%edx
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8af:	8b 40 04             	mov    0x4(%eax),%eax
 8b2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	01 d0                	add    %edx,%eax
 8be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8c1:	75 20                	jne    8e3 <free+0xcf>
    p->s.size += bp->s.size;
 8c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c6:	8b 50 04             	mov    0x4(%eax),%edx
 8c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cc:	8b 40 04             	mov    0x4(%eax),%eax
 8cf:	01 c2                	add    %eax,%edx
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	8b 10                	mov    (%eax),%edx
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	89 10                	mov    %edx,(%eax)
 8e1:	eb 08                	jmp    8eb <free+0xd7>
  } else
    p->s.ptr = bp;
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e9:	89 10                	mov    %edx,(%eax)
  freep = p;
 8eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ee:	a3 08 0d 00 00       	mov    %eax,0xd08
}
 8f3:	c9                   	leave  
 8f4:	c3                   	ret    

000008f5 <morecore>:

static Header*
morecore(uint nu)
{
 8f5:	55                   	push   %ebp
 8f6:	89 e5                	mov    %esp,%ebp
 8f8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8fb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 902:	77 07                	ja     90b <morecore+0x16>
    nu = 4096;
 904:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 90b:	8b 45 08             	mov    0x8(%ebp),%eax
 90e:	c1 e0 03             	shl    $0x3,%eax
 911:	89 04 24             	mov    %eax,(%esp)
 914:	e8 97 fb ff ff       	call   4b0 <sbrk>
 919:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 91c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 920:	75 07                	jne    929 <morecore+0x34>
    return 0;
 922:	b8 00 00 00 00       	mov    $0x0,%eax
 927:	eb 22                	jmp    94b <morecore+0x56>
  hp = (Header*)p;
 929:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 92f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 932:	8b 55 08             	mov    0x8(%ebp),%edx
 935:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 938:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93b:	83 c0 08             	add    $0x8,%eax
 93e:	89 04 24             	mov    %eax,(%esp)
 941:	e8 ce fe ff ff       	call   814 <free>
  return freep;
 946:	a1 08 0d 00 00       	mov    0xd08,%eax
}
 94b:	c9                   	leave  
 94c:	c3                   	ret    

0000094d <malloc>:

void*
malloc(uint nbytes)
{
 94d:	55                   	push   %ebp
 94e:	89 e5                	mov    %esp,%ebp
 950:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 953:	8b 45 08             	mov    0x8(%ebp),%eax
 956:	83 c0 07             	add    $0x7,%eax
 959:	c1 e8 03             	shr    $0x3,%eax
 95c:	40                   	inc    %eax
 95d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 960:	a1 08 0d 00 00       	mov    0xd08,%eax
 965:	89 45 f0             	mov    %eax,-0x10(%ebp)
 968:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 96c:	75 23                	jne    991 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 96e:	c7 45 f0 00 0d 00 00 	movl   $0xd00,-0x10(%ebp)
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	a3 08 0d 00 00       	mov    %eax,0xd08
 97d:	a1 08 0d 00 00       	mov    0xd08,%eax
 982:	a3 00 0d 00 00       	mov    %eax,0xd00
    base.s.size = 0;
 987:	c7 05 04 0d 00 00 00 	movl   $0x0,0xd04
 98e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 991:	8b 45 f0             	mov    -0x10(%ebp),%eax
 994:	8b 00                	mov    (%eax),%eax
 996:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 999:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99c:	8b 40 04             	mov    0x4(%eax),%eax
 99f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9a2:	72 4d                	jb     9f1 <malloc+0xa4>
      if(p->s.size == nunits)
 9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a7:	8b 40 04             	mov    0x4(%eax),%eax
 9aa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ad:	75 0c                	jne    9bb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 9af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b2:	8b 10                	mov    (%eax),%edx
 9b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b7:	89 10                	mov    %edx,(%eax)
 9b9:	eb 26                	jmp    9e1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9be:	8b 40 04             	mov    0x4(%eax),%eax
 9c1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9c4:	89 c2                	mov    %eax,%edx
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	8b 40 04             	mov    0x4(%eax),%eax
 9d2:	c1 e0 03             	shl    $0x3,%eax
 9d5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9db:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9de:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e4:	a3 08 0d 00 00       	mov    %eax,0xd08
      return (void*)(p + 1);
 9e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ec:	83 c0 08             	add    $0x8,%eax
 9ef:	eb 38                	jmp    a29 <malloc+0xdc>
    }
    if(p == freep)
 9f1:	a1 08 0d 00 00       	mov    0xd08,%eax
 9f6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9f9:	75 1b                	jne    a16 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9fe:	89 04 24             	mov    %eax,(%esp)
 a01:	e8 ef fe ff ff       	call   8f5 <morecore>
 a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a0d:	75 07                	jne    a16 <malloc+0xc9>
        return 0;
 a0f:	b8 00 00 00 00       	mov    $0x0,%eax
 a14:	eb 13                	jmp    a29 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1f:	8b 00                	mov    (%eax),%eax
 a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a24:	e9 70 ff ff ff       	jmp    999 <malloc+0x4c>
}
 a29:	c9                   	leave  
 a2a:	c3                   	ret    
