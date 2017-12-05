
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
  31:	05 60 0e 00 00       	add    $0xe60,%eax
  36:	8a 00                	mov    (%eax),%al
  38:	3c 0a                	cmp    $0xa,%al
  3a:	75 03                	jne    3f <wc+0x3f>
        l++;
  3c:	ff 45 f0             	incl   -0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  42:	05 60 0e 00 00       	add    $0xe60,%eax
  47:	8a 00                	mov    (%eax),%al
  49:	0f be c0             	movsbl %al,%eax
  4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  50:	c7 04 24 5f 0b 00 00 	movl   $0xb5f,(%esp)
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
  8c:	c7 44 24 04 60 0e 00 	movl   $0xe60,0x4(%esp)
  93:	00 
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	89 04 24             	mov    %eax,(%esp)
  9a:	e8 85 04 00 00       	call   524 <read>
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
  b2:	c7 44 24 04 65 0b 00 	movl   $0xb65,0x4(%esp)
  b9:	00 
  ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c1:	e8 d3 06 00 00       	call   799 <printf>
    exit();
  c6:	e8 41 04 00 00       	call   50c <exit>
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
  e7:	c7 44 24 04 75 0b 00 	movl   $0xb75,0x4(%esp)
  ee:	00 
  ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f6:	e8 9e 06 00 00       	call   799 <printf>
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
 10c:	c7 44 24 04 82 0b 00 	movl   $0xb82,0x4(%esp)
 113:	00 
 114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 11b:	e8 e0 fe ff ff       	call   0 <wc>
    exit();
 120:	e8 e7 03 00 00       	call   50c <exit>
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
 14f:	e8 f8 03 00 00       	call   54c <open>
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
 175:	c7 44 24 04 83 0b 00 	movl   $0xb83,0x4(%esp)
 17c:	00 
 17d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 184:	e8 10 06 00 00       	call   799 <printf>
      exit();
 189:	e8 7e 03 00 00       	call   50c <exit>
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
 1b7:	e8 78 03 00 00       	call   534 <close>
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
 1cd:	e8 3a 03 00 00       	call   50c <exit>
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
 2fd:	e8 22 02 00 00       	call   524 <read>
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
 35d:	e8 ea 01 00 00       	call   54c <open>
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
 37f:	e8 e0 01 00 00       	call   564 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 a2 01 00 00       	call   534 <close>
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

0000041d <itoa>:

int itoa(int value, char *sp, int radix)
{
 41d:	55                   	push   %ebp
 41e:	89 e5                	mov    %esp,%ebp
 420:	53                   	push   %ebx
 421:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 424:	8d 45 d8             	lea    -0x28(%ebp),%eax
 427:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 42a:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 42e:	75 0d                	jne    43d <itoa+0x20>
 430:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 434:	79 07                	jns    43d <itoa+0x20>
 436:	b8 01 00 00 00       	mov    $0x1,%eax
 43b:	eb 05                	jmp    442 <itoa+0x25>
 43d:	b8 00 00 00 00       	mov    $0x0,%eax
 442:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 445:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 449:	74 0a                	je     455 <itoa+0x38>
      v = -value;
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	f7 d8                	neg    %eax
 450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 453:	eb 54                	jmp    4a9 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 45b:	eb 4c                	jmp    4a9 <itoa+0x8c>
  {
    i = v % radix;
 45d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 460:	8b 45 f4             	mov    -0xc(%ebp),%eax
 463:	ba 00 00 00 00       	mov    $0x0,%edx
 468:	f7 f1                	div    %ecx
 46a:	89 d0                	mov    %edx,%eax
 46c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 46f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 472:	8b 45 f4             	mov    -0xc(%ebp),%eax
 475:	ba 00 00 00 00       	mov    $0x0,%edx
 47a:	f7 f3                	div    %ebx
 47c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 47f:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 483:	7f 13                	jg     498 <itoa+0x7b>
      *tp++ = i+'0';
 485:	8b 45 f8             	mov    -0x8(%ebp),%eax
 488:	8d 50 01             	lea    0x1(%eax),%edx
 48b:	89 55 f8             	mov    %edx,-0x8(%ebp)
 48e:	8b 55 e8             	mov    -0x18(%ebp),%edx
 491:	83 c2 30             	add    $0x30,%edx
 494:	88 10                	mov    %dl,(%eax)
 496:	eb 11                	jmp    4a9 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 498:	8b 45 f8             	mov    -0x8(%ebp),%eax
 49b:	8d 50 01             	lea    0x1(%eax),%edx
 49e:	89 55 f8             	mov    %edx,-0x8(%ebp)
 4a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
 4a4:	83 c2 57             	add    $0x57,%edx
 4a7:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 4a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ad:	75 ae                	jne    45d <itoa+0x40>
 4af:	8d 45 d8             	lea    -0x28(%ebp),%eax
 4b2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 4b5:	74 a6                	je     45d <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 4b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ba:	8d 45 d8             	lea    -0x28(%ebp),%eax
 4bd:	29 c2                	sub    %eax,%edx
 4bf:	89 d0                	mov    %edx,%eax
 4c1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 4c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c8:	74 11                	je     4db <itoa+0xbe>
  {
    *sp++ = '-';
 4ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cd:	8d 50 01             	lea    0x1(%eax),%edx
 4d0:	89 55 0c             	mov    %edx,0xc(%ebp)
 4d3:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 4d6:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 4d9:	eb 15                	jmp    4f0 <itoa+0xd3>
 4db:	eb 13                	jmp    4f0 <itoa+0xd3>
    *sp++ = *--tp;
 4dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e0:	8d 50 01             	lea    0x1(%eax),%edx
 4e3:	89 55 0c             	mov    %edx,0xc(%ebp)
 4e6:	ff 4d f8             	decl   -0x8(%ebp)
 4e9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ec:	8a 12                	mov    (%edx),%dl
 4ee:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 4f0:	8d 45 d8             	lea    -0x28(%ebp),%eax
 4f3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 4f6:	77 e5                	ja     4dd <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 4f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4fb:	83 c4 30             	add    $0x30,%esp
 4fe:	5b                   	pop    %ebx
 4ff:	5d                   	pop    %ebp
 500:	c3                   	ret    
 501:	90                   	nop
 502:	90                   	nop
 503:	90                   	nop

00000504 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 504:	b8 01 00 00 00       	mov    $0x1,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <exit>:
SYSCALL(exit)
 50c:	b8 02 00 00 00       	mov    $0x2,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <wait>:
SYSCALL(wait)
 514:	b8 03 00 00 00       	mov    $0x3,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <pipe>:
SYSCALL(pipe)
 51c:	b8 04 00 00 00       	mov    $0x4,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <read>:
SYSCALL(read)
 524:	b8 05 00 00 00       	mov    $0x5,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <write>:
SYSCALL(write)
 52c:	b8 10 00 00 00       	mov    $0x10,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <close>:
SYSCALL(close)
 534:	b8 15 00 00 00       	mov    $0x15,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <kill>:
SYSCALL(kill)
 53c:	b8 06 00 00 00       	mov    $0x6,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <exec>:
SYSCALL(exec)
 544:	b8 07 00 00 00       	mov    $0x7,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <open>:
SYSCALL(open)
 54c:	b8 0f 00 00 00       	mov    $0xf,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <mknod>:
SYSCALL(mknod)
 554:	b8 11 00 00 00       	mov    $0x11,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <unlink>:
SYSCALL(unlink)
 55c:	b8 12 00 00 00       	mov    $0x12,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <fstat>:
SYSCALL(fstat)
 564:	b8 08 00 00 00       	mov    $0x8,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <link>:
SYSCALL(link)
 56c:	b8 13 00 00 00       	mov    $0x13,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <mkdir>:
SYSCALL(mkdir)
 574:	b8 14 00 00 00       	mov    $0x14,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <chdir>:
SYSCALL(chdir)
 57c:	b8 09 00 00 00       	mov    $0x9,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <dup>:
SYSCALL(dup)
 584:	b8 0a 00 00 00       	mov    $0xa,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <getpid>:
SYSCALL(getpid)
 58c:	b8 0b 00 00 00       	mov    $0xb,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <sbrk>:
SYSCALL(sbrk)
 594:	b8 0c 00 00 00       	mov    $0xc,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <sleep>:
SYSCALL(sleep)
 59c:	b8 0d 00 00 00       	mov    $0xd,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <uptime>:
SYSCALL(uptime)
 5a4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <getticks>:
SYSCALL(getticks)
 5ac:	b8 16 00 00 00       	mov    $0x16,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <get_name>:
SYSCALL(get_name)
 5b4:	b8 17 00 00 00       	mov    $0x17,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <get_max_proc>:
SYSCALL(get_max_proc)
 5bc:	b8 18 00 00 00       	mov    $0x18,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <get_max_mem>:
SYSCALL(get_max_mem)
 5c4:	b8 19 00 00 00       	mov    $0x19,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <get_max_disk>:
SYSCALL(get_max_disk)
 5cc:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <get_curr_proc>:
SYSCALL(get_curr_proc)
 5d4:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <get_curr_mem>:
SYSCALL(get_curr_mem)
 5dc:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <get_curr_disk>:
SYSCALL(get_curr_disk)
 5e4:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <set_name>:
SYSCALL(set_name)
 5ec:	b8 1e 00 00 00       	mov    $0x1e,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <set_max_mem>:
SYSCALL(set_max_mem)
 5f4:	b8 1f 00 00 00       	mov    $0x1f,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <set_max_disk>:
SYSCALL(set_max_disk)
 5fc:	b8 20 00 00 00       	mov    $0x20,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <set_max_proc>:
SYSCALL(set_max_proc)
 604:	b8 21 00 00 00       	mov    $0x21,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <set_curr_mem>:
SYSCALL(set_curr_mem)
 60c:	b8 22 00 00 00       	mov    $0x22,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <set_curr_disk>:
SYSCALL(set_curr_disk)
 614:	b8 23 00 00 00       	mov    $0x23,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <set_curr_proc>:
SYSCALL(set_curr_proc)
 61c:	b8 24 00 00 00       	mov    $0x24,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <find>:
SYSCALL(find)
 624:	b8 25 00 00 00       	mov    $0x25,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <is_full>:
SYSCALL(is_full)
 62c:	b8 26 00 00 00       	mov    $0x26,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <container_init>:
SYSCALL(container_init)
 634:	b8 27 00 00 00       	mov    $0x27,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <cont_proc_set>:
SYSCALL(cont_proc_set)
 63c:	b8 28 00 00 00       	mov    $0x28,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <ps>:
SYSCALL(ps)
 644:	b8 29 00 00 00       	mov    $0x29,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 64c:	b8 2a 00 00 00       	mov    $0x2a,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <set_root_inode>:
SYSCALL(set_root_inode)
 654:	b8 2b 00 00 00       	mov    $0x2b,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <cstop>:
SYSCALL(cstop)
 65c:	b8 2c 00 00 00       	mov    $0x2c,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <df>:
SYSCALL(df)
 664:	b8 2d 00 00 00       	mov    $0x2d,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <max_containers>:
SYSCALL(max_containers)
 66c:	b8 2e 00 00 00       	mov    $0x2e,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <container_reset>:
SYSCALL(container_reset)
 674:	b8 2f 00 00 00       	mov    $0x2f,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <pause>:
SYSCALL(pause)
 67c:	b8 30 00 00 00       	mov    $0x30,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <resume>:
SYSCALL(resume)
 684:	b8 31 00 00 00       	mov    $0x31,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <tmem>:
SYSCALL(tmem)
 68c:	b8 32 00 00 00       	mov    $0x32,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <amem>:
SYSCALL(amem)
 694:	b8 33 00 00 00       	mov    $0x33,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	ret    

0000069c <c_ps>:
SYSCALL(c_ps)
 69c:	b8 34 00 00 00       	mov    $0x34,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	ret    

000006a4 <get_used>:
SYSCALL(get_used)
 6a4:	b8 35 00 00 00       	mov    $0x35,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	ret    

000006ac <get_os>:
SYSCALL(get_os)
 6ac:	b8 36 00 00 00       	mov    $0x36,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	ret    

000006b4 <set_os>:
SYSCALL(set_os)
 6b4:	b8 37 00 00 00       	mov    $0x37,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	ret    

000006bc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 18             	sub    $0x18,%esp
 6c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6c8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6cf:	00 
 6d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d7:	8b 45 08             	mov    0x8(%ebp),%eax
 6da:	89 04 24             	mov    %eax,(%esp)
 6dd:	e8 4a fe ff ff       	call   52c <write>
}
 6e2:	c9                   	leave  
 6e3:	c3                   	ret    

000006e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6e4:	55                   	push   %ebp
 6e5:	89 e5                	mov    %esp,%ebp
 6e7:	56                   	push   %esi
 6e8:	53                   	push   %ebx
 6e9:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6f3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6f7:	74 17                	je     710 <printint+0x2c>
 6f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6fd:	79 11                	jns    710 <printint+0x2c>
    neg = 1;
 6ff:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 706:	8b 45 0c             	mov    0xc(%ebp),%eax
 709:	f7 d8                	neg    %eax
 70b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70e:	eb 06                	jmp    716 <printint+0x32>
  } else {
    x = xx;
 710:	8b 45 0c             	mov    0xc(%ebp),%eax
 713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 71d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 720:	8d 41 01             	lea    0x1(%ecx),%eax
 723:	89 45 f4             	mov    %eax,-0xc(%ebp)
 726:	8b 5d 10             	mov    0x10(%ebp),%ebx
 729:	8b 45 ec             	mov    -0x14(%ebp),%eax
 72c:	ba 00 00 00 00       	mov    $0x0,%edx
 731:	f7 f3                	div    %ebx
 733:	89 d0                	mov    %edx,%eax
 735:	8a 80 28 0e 00 00    	mov    0xe28(%eax),%al
 73b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 73f:	8b 75 10             	mov    0x10(%ebp),%esi
 742:	8b 45 ec             	mov    -0x14(%ebp),%eax
 745:	ba 00 00 00 00       	mov    $0x0,%edx
 74a:	f7 f6                	div    %esi
 74c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 74f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 753:	75 c8                	jne    71d <printint+0x39>
  if(neg)
 755:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 759:	74 10                	je     76b <printint+0x87>
    buf[i++] = '-';
 75b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75e:	8d 50 01             	lea    0x1(%eax),%edx
 761:	89 55 f4             	mov    %edx,-0xc(%ebp)
 764:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 769:	eb 1e                	jmp    789 <printint+0xa5>
 76b:	eb 1c                	jmp    789 <printint+0xa5>
    putc(fd, buf[i]);
 76d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	01 d0                	add    %edx,%eax
 775:	8a 00                	mov    (%eax),%al
 777:	0f be c0             	movsbl %al,%eax
 77a:	89 44 24 04          	mov    %eax,0x4(%esp)
 77e:	8b 45 08             	mov    0x8(%ebp),%eax
 781:	89 04 24             	mov    %eax,(%esp)
 784:	e8 33 ff ff ff       	call   6bc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 789:	ff 4d f4             	decl   -0xc(%ebp)
 78c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 790:	79 db                	jns    76d <printint+0x89>
    putc(fd, buf[i]);
}
 792:	83 c4 30             	add    $0x30,%esp
 795:	5b                   	pop    %ebx
 796:	5e                   	pop    %esi
 797:	5d                   	pop    %ebp
 798:	c3                   	ret    

00000799 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 799:	55                   	push   %ebp
 79a:	89 e5                	mov    %esp,%ebp
 79c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 79f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7a6:	8d 45 0c             	lea    0xc(%ebp),%eax
 7a9:	83 c0 04             	add    $0x4,%eax
 7ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7b6:	e9 77 01 00 00       	jmp    932 <printf+0x199>
    c = fmt[i] & 0xff;
 7bb:	8b 55 0c             	mov    0xc(%ebp),%edx
 7be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c1:	01 d0                	add    %edx,%eax
 7c3:	8a 00                	mov    (%eax),%al
 7c5:	0f be c0             	movsbl %al,%eax
 7c8:	25 ff 00 00 00       	and    $0xff,%eax
 7cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7d4:	75 2c                	jne    802 <printf+0x69>
      if(c == '%'){
 7d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7da:	75 0c                	jne    7e8 <printf+0x4f>
        state = '%';
 7dc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7e3:	e9 47 01 00 00       	jmp    92f <printf+0x196>
      } else {
        putc(fd, c);
 7e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	89 04 24             	mov    %eax,(%esp)
 7f8:	e8 bf fe ff ff       	call   6bc <putc>
 7fd:	e9 2d 01 00 00       	jmp    92f <printf+0x196>
      }
    } else if(state == '%'){
 802:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 806:	0f 85 23 01 00 00    	jne    92f <printf+0x196>
      if(c == 'd'){
 80c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 810:	75 2d                	jne    83f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 812:	8b 45 e8             	mov    -0x18(%ebp),%eax
 815:	8b 00                	mov    (%eax),%eax
 817:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 81e:	00 
 81f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 826:	00 
 827:	89 44 24 04          	mov    %eax,0x4(%esp)
 82b:	8b 45 08             	mov    0x8(%ebp),%eax
 82e:	89 04 24             	mov    %eax,(%esp)
 831:	e8 ae fe ff ff       	call   6e4 <printint>
        ap++;
 836:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 83a:	e9 e9 00 00 00       	jmp    928 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 83f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 843:	74 06                	je     84b <printf+0xb2>
 845:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 849:	75 2d                	jne    878 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 84b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 84e:	8b 00                	mov    (%eax),%eax
 850:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 857:	00 
 858:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 85f:	00 
 860:	89 44 24 04          	mov    %eax,0x4(%esp)
 864:	8b 45 08             	mov    0x8(%ebp),%eax
 867:	89 04 24             	mov    %eax,(%esp)
 86a:	e8 75 fe ff ff       	call   6e4 <printint>
        ap++;
 86f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 873:	e9 b0 00 00 00       	jmp    928 <printf+0x18f>
      } else if(c == 's'){
 878:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 87c:	75 42                	jne    8c0 <printf+0x127>
        s = (char*)*ap;
 87e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 881:	8b 00                	mov    (%eax),%eax
 883:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 886:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 88a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 88e:	75 09                	jne    899 <printf+0x100>
          s = "(null)";
 890:	c7 45 f4 97 0b 00 00 	movl   $0xb97,-0xc(%ebp)
        while(*s != 0){
 897:	eb 1c                	jmp    8b5 <printf+0x11c>
 899:	eb 1a                	jmp    8b5 <printf+0x11c>
          putc(fd, *s);
 89b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89e:	8a 00                	mov    (%eax),%al
 8a0:	0f be c0             	movsbl %al,%eax
 8a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 8a7:	8b 45 08             	mov    0x8(%ebp),%eax
 8aa:	89 04 24             	mov    %eax,(%esp)
 8ad:	e8 0a fe ff ff       	call   6bc <putc>
          s++;
 8b2:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 8b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b8:	8a 00                	mov    (%eax),%al
 8ba:	84 c0                	test   %al,%al
 8bc:	75 dd                	jne    89b <printf+0x102>
 8be:	eb 68                	jmp    928 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8c0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8c4:	75 1d                	jne    8e3 <printf+0x14a>
        putc(fd, *ap);
 8c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8c9:	8b 00                	mov    (%eax),%eax
 8cb:	0f be c0             	movsbl %al,%eax
 8ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d2:	8b 45 08             	mov    0x8(%ebp),%eax
 8d5:	89 04 24             	mov    %eax,(%esp)
 8d8:	e8 df fd ff ff       	call   6bc <putc>
        ap++;
 8dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8e1:	eb 45                	jmp    928 <printf+0x18f>
      } else if(c == '%'){
 8e3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8e7:	75 17                	jne    900 <printf+0x167>
        putc(fd, c);
 8e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ec:	0f be c0             	movsbl %al,%eax
 8ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f3:	8b 45 08             	mov    0x8(%ebp),%eax
 8f6:	89 04 24             	mov    %eax,(%esp)
 8f9:	e8 be fd ff ff       	call   6bc <putc>
 8fe:	eb 28                	jmp    928 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 900:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 907:	00 
 908:	8b 45 08             	mov    0x8(%ebp),%eax
 90b:	89 04 24             	mov    %eax,(%esp)
 90e:	e8 a9 fd ff ff       	call   6bc <putc>
        putc(fd, c);
 913:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 916:	0f be c0             	movsbl %al,%eax
 919:	89 44 24 04          	mov    %eax,0x4(%esp)
 91d:	8b 45 08             	mov    0x8(%ebp),%eax
 920:	89 04 24             	mov    %eax,(%esp)
 923:	e8 94 fd ff ff       	call   6bc <putc>
      }
      state = 0;
 928:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 92f:	ff 45 f0             	incl   -0x10(%ebp)
 932:	8b 55 0c             	mov    0xc(%ebp),%edx
 935:	8b 45 f0             	mov    -0x10(%ebp),%eax
 938:	01 d0                	add    %edx,%eax
 93a:	8a 00                	mov    (%eax),%al
 93c:	84 c0                	test   %al,%al
 93e:	0f 85 77 fe ff ff    	jne    7bb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 944:	c9                   	leave  
 945:	c3                   	ret    
 946:	90                   	nop
 947:	90                   	nop

00000948 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 948:	55                   	push   %ebp
 949:	89 e5                	mov    %esp,%ebp
 94b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 94e:	8b 45 08             	mov    0x8(%ebp),%eax
 951:	83 e8 08             	sub    $0x8,%eax
 954:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 957:	a1 48 0e 00 00       	mov    0xe48,%eax
 95c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 95f:	eb 24                	jmp    985 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 969:	77 12                	ja     97d <free+0x35>
 96b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 971:	77 24                	ja     997 <free+0x4f>
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	8b 00                	mov    (%eax),%eax
 978:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 97b:	77 1a                	ja     997 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	8b 00                	mov    (%eax),%eax
 982:	89 45 fc             	mov    %eax,-0x4(%ebp)
 985:	8b 45 f8             	mov    -0x8(%ebp),%eax
 988:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 98b:	76 d4                	jbe    961 <free+0x19>
 98d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 990:	8b 00                	mov    (%eax),%eax
 992:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 995:	76 ca                	jbe    961 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 997:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99a:	8b 40 04             	mov    0x4(%eax),%eax
 99d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a7:	01 c2                	add    %eax,%edx
 9a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ac:	8b 00                	mov    (%eax),%eax
 9ae:	39 c2                	cmp    %eax,%edx
 9b0:	75 24                	jne    9d6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b5:	8b 50 04             	mov    0x4(%eax),%edx
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	8b 00                	mov    (%eax),%eax
 9bd:	8b 40 04             	mov    0x4(%eax),%eax
 9c0:	01 c2                	add    %eax,%edx
 9c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cb:	8b 00                	mov    (%eax),%eax
 9cd:	8b 10                	mov    (%eax),%edx
 9cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d2:	89 10                	mov    %edx,(%eax)
 9d4:	eb 0a                	jmp    9e0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d9:	8b 10                	mov    (%eax),%edx
 9db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9de:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e3:	8b 40 04             	mov    0x4(%eax),%eax
 9e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f0:	01 d0                	add    %edx,%eax
 9f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9f5:	75 20                	jne    a17 <free+0xcf>
    p->s.size += bp->s.size;
 9f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fa:	8b 50 04             	mov    0x4(%eax),%edx
 9fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a00:	8b 40 04             	mov    0x4(%eax),%eax
 a03:	01 c2                	add    %eax,%edx
 a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a08:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0e:	8b 10                	mov    (%eax),%edx
 a10:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a13:	89 10                	mov    %edx,(%eax)
 a15:	eb 08                	jmp    a1f <free+0xd7>
  } else
    p->s.ptr = bp;
 a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a1d:	89 10                	mov    %edx,(%eax)
  freep = p;
 a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a22:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 a27:	c9                   	leave  
 a28:	c3                   	ret    

00000a29 <morecore>:

static Header*
morecore(uint nu)
{
 a29:	55                   	push   %ebp
 a2a:	89 e5                	mov    %esp,%ebp
 a2c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a2f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a36:	77 07                	ja     a3f <morecore+0x16>
    nu = 4096;
 a38:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a3f:	8b 45 08             	mov    0x8(%ebp),%eax
 a42:	c1 e0 03             	shl    $0x3,%eax
 a45:	89 04 24             	mov    %eax,(%esp)
 a48:	e8 47 fb ff ff       	call   594 <sbrk>
 a4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a50:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a54:	75 07                	jne    a5d <morecore+0x34>
    return 0;
 a56:	b8 00 00 00 00       	mov    $0x0,%eax
 a5b:	eb 22                	jmp    a7f <morecore+0x56>
  hp = (Header*)p;
 a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a66:	8b 55 08             	mov    0x8(%ebp),%edx
 a69:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6f:	83 c0 08             	add    $0x8,%eax
 a72:	89 04 24             	mov    %eax,(%esp)
 a75:	e8 ce fe ff ff       	call   948 <free>
  return freep;
 a7a:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 a7f:	c9                   	leave  
 a80:	c3                   	ret    

00000a81 <malloc>:

void*
malloc(uint nbytes)
{
 a81:	55                   	push   %ebp
 a82:	89 e5                	mov    %esp,%ebp
 a84:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a87:	8b 45 08             	mov    0x8(%ebp),%eax
 a8a:	83 c0 07             	add    $0x7,%eax
 a8d:	c1 e8 03             	shr    $0x3,%eax
 a90:	40                   	inc    %eax
 a91:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a94:	a1 48 0e 00 00       	mov    0xe48,%eax
 a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aa0:	75 23                	jne    ac5 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 aa2:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aac:	a3 48 0e 00 00       	mov    %eax,0xe48
 ab1:	a1 48 0e 00 00       	mov    0xe48,%eax
 ab6:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 abb:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 ac2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac8:	8b 00                	mov    (%eax),%eax
 aca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad0:	8b 40 04             	mov    0x4(%eax),%eax
 ad3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ad6:	72 4d                	jb     b25 <malloc+0xa4>
      if(p->s.size == nunits)
 ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adb:	8b 40 04             	mov    0x4(%eax),%eax
 ade:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ae1:	75 0c                	jne    aef <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae6:	8b 10                	mov    (%eax),%edx
 ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aeb:	89 10                	mov    %edx,(%eax)
 aed:	eb 26                	jmp    b15 <malloc+0x94>
      else {
        p->s.size -= nunits;
 aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af2:	8b 40 04             	mov    0x4(%eax),%eax
 af5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 af8:	89 c2                	mov    %eax,%edx
 afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b03:	8b 40 04             	mov    0x4(%eax),%eax
 b06:	c1 e0 03             	shl    $0x3,%eax
 b09:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b12:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b18:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b20:	83 c0 08             	add    $0x8,%eax
 b23:	eb 38                	jmp    b5d <malloc+0xdc>
    }
    if(p == freep)
 b25:	a1 48 0e 00 00       	mov    0xe48,%eax
 b2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b2d:	75 1b                	jne    b4a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 b2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b32:	89 04 24             	mov    %eax,(%esp)
 b35:	e8 ef fe ff ff       	call   a29 <morecore>
 b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b41:	75 07                	jne    b4a <malloc+0xc9>
        return 0;
 b43:	b8 00 00 00 00       	mov    $0x0,%eax
 b48:	eb 13                	jmp    b5d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b53:	8b 00                	mov    (%eax),%eax
 b55:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b58:	e9 70 ff ff ff       	jmp    acd <malloc+0x4c>
}
 b5d:	c9                   	leave  
 b5e:	c3                   	ret    
