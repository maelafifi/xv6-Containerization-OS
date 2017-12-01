
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
  50:	c7 04 24 33 0a 00 00 	movl   $0xa33,(%esp)
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
  b2:	c7 44 24 04 39 0a 00 	movl   $0xa39,0x4(%esp)
  b9:	00 
  ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c1:	e8 a7 05 00 00       	call   66d <printf>
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
  e7:	c7 44 24 04 49 0a 00 	movl   $0xa49,0x4(%esp)
  ee:	00 
  ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f6:	e8 72 05 00 00       	call   66d <printf>
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
 10c:	c7 44 24 04 56 0a 00 	movl   $0xa56,0x4(%esp)
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
 175:	c7 44 24 04 57 0a 00 	movl   $0xa57,0x4(%esp)
 17c:	00 
 17d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 184:	e8 e4 04 00 00       	call   66d <printf>
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

00000588 <max_containers>:
SYSCALL(max_containers)
 588:	b8 2e 00 00 00       	mov    $0x2e,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 590:	55                   	push   %ebp
 591:	89 e5                	mov    %esp,%ebp
 593:	83 ec 18             	sub    $0x18,%esp
 596:	8b 45 0c             	mov    0xc(%ebp),%eax
 599:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 59c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5a3:	00 
 5a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ab:	8b 45 08             	mov    0x8(%ebp),%eax
 5ae:	89 04 24             	mov    %eax,(%esp)
 5b1:	e8 92 fe ff ff       	call   448 <write>
}
 5b6:	c9                   	leave  
 5b7:	c3                   	ret    

000005b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b8:	55                   	push   %ebp
 5b9:	89 e5                	mov    %esp,%ebp
 5bb:	56                   	push   %esi
 5bc:	53                   	push   %ebx
 5bd:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5c7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5cb:	74 17                	je     5e4 <printint+0x2c>
 5cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5d1:	79 11                	jns    5e4 <printint+0x2c>
    neg = 1;
 5d3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5da:	8b 45 0c             	mov    0xc(%ebp),%eax
 5dd:	f7 d8                	neg    %eax
 5df:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5e2:	eb 06                	jmp    5ea <printint+0x32>
  } else {
    x = xx;
 5e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5f1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5f4:	8d 41 01             	lea    0x1(%ecx),%eax
 5f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 600:	ba 00 00 00 00       	mov    $0x0,%edx
 605:	f7 f3                	div    %ebx
 607:	89 d0                	mov    %edx,%eax
 609:	8a 80 d8 0c 00 00    	mov    0xcd8(%eax),%al
 60f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 613:	8b 75 10             	mov    0x10(%ebp),%esi
 616:	8b 45 ec             	mov    -0x14(%ebp),%eax
 619:	ba 00 00 00 00       	mov    $0x0,%edx
 61e:	f7 f6                	div    %esi
 620:	89 45 ec             	mov    %eax,-0x14(%ebp)
 623:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 627:	75 c8                	jne    5f1 <printint+0x39>
  if(neg)
 629:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 62d:	74 10                	je     63f <printint+0x87>
    buf[i++] = '-';
 62f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 632:	8d 50 01             	lea    0x1(%eax),%edx
 635:	89 55 f4             	mov    %edx,-0xc(%ebp)
 638:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 63d:	eb 1e                	jmp    65d <printint+0xa5>
 63f:	eb 1c                	jmp    65d <printint+0xa5>
    putc(fd, buf[i]);
 641:	8d 55 dc             	lea    -0x24(%ebp),%edx
 644:	8b 45 f4             	mov    -0xc(%ebp),%eax
 647:	01 d0                	add    %edx,%eax
 649:	8a 00                	mov    (%eax),%al
 64b:	0f be c0             	movsbl %al,%eax
 64e:	89 44 24 04          	mov    %eax,0x4(%esp)
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	89 04 24             	mov    %eax,(%esp)
 658:	e8 33 ff ff ff       	call   590 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 65d:	ff 4d f4             	decl   -0xc(%ebp)
 660:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 664:	79 db                	jns    641 <printint+0x89>
    putc(fd, buf[i]);
}
 666:	83 c4 30             	add    $0x30,%esp
 669:	5b                   	pop    %ebx
 66a:	5e                   	pop    %esi
 66b:	5d                   	pop    %ebp
 66c:	c3                   	ret    

0000066d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 66d:	55                   	push   %ebp
 66e:	89 e5                	mov    %esp,%ebp
 670:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 673:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 67a:	8d 45 0c             	lea    0xc(%ebp),%eax
 67d:	83 c0 04             	add    $0x4,%eax
 680:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 683:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 68a:	e9 77 01 00 00       	jmp    806 <printf+0x199>
    c = fmt[i] & 0xff;
 68f:	8b 55 0c             	mov    0xc(%ebp),%edx
 692:	8b 45 f0             	mov    -0x10(%ebp),%eax
 695:	01 d0                	add    %edx,%eax
 697:	8a 00                	mov    (%eax),%al
 699:	0f be c0             	movsbl %al,%eax
 69c:	25 ff 00 00 00       	and    $0xff,%eax
 6a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a8:	75 2c                	jne    6d6 <printf+0x69>
      if(c == '%'){
 6aa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ae:	75 0c                	jne    6bc <printf+0x4f>
        state = '%';
 6b0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6b7:	e9 47 01 00 00       	jmp    803 <printf+0x196>
      } else {
        putc(fd, c);
 6bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6bf:	0f be c0             	movsbl %al,%eax
 6c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c6:	8b 45 08             	mov    0x8(%ebp),%eax
 6c9:	89 04 24             	mov    %eax,(%esp)
 6cc:	e8 bf fe ff ff       	call   590 <putc>
 6d1:	e9 2d 01 00 00       	jmp    803 <printf+0x196>
      }
    } else if(state == '%'){
 6d6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6da:	0f 85 23 01 00 00    	jne    803 <printf+0x196>
      if(c == 'd'){
 6e0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6e4:	75 2d                	jne    713 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e9:	8b 00                	mov    (%eax),%eax
 6eb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6f2:	00 
 6f3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6fa:	00 
 6fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ff:	8b 45 08             	mov    0x8(%ebp),%eax
 702:	89 04 24             	mov    %eax,(%esp)
 705:	e8 ae fe ff ff       	call   5b8 <printint>
        ap++;
 70a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70e:	e9 e9 00 00 00       	jmp    7fc <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 713:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 717:	74 06                	je     71f <printf+0xb2>
 719:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 71d:	75 2d                	jne    74c <printf+0xdf>
        printint(fd, *ap, 16, 0);
 71f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 72b:	00 
 72c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 733:	00 
 734:	89 44 24 04          	mov    %eax,0x4(%esp)
 738:	8b 45 08             	mov    0x8(%ebp),%eax
 73b:	89 04 24             	mov    %eax,(%esp)
 73e:	e8 75 fe ff ff       	call   5b8 <printint>
        ap++;
 743:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 747:	e9 b0 00 00 00       	jmp    7fc <printf+0x18f>
      } else if(c == 's'){
 74c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 750:	75 42                	jne    794 <printf+0x127>
        s = (char*)*ap;
 752:	8b 45 e8             	mov    -0x18(%ebp),%eax
 755:	8b 00                	mov    (%eax),%eax
 757:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 75a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 75e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 762:	75 09                	jne    76d <printf+0x100>
          s = "(null)";
 764:	c7 45 f4 6b 0a 00 00 	movl   $0xa6b,-0xc(%ebp)
        while(*s != 0){
 76b:	eb 1c                	jmp    789 <printf+0x11c>
 76d:	eb 1a                	jmp    789 <printf+0x11c>
          putc(fd, *s);
 76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 772:	8a 00                	mov    (%eax),%al
 774:	0f be c0             	movsbl %al,%eax
 777:	89 44 24 04          	mov    %eax,0x4(%esp)
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	89 04 24             	mov    %eax,(%esp)
 781:	e8 0a fe ff ff       	call   590 <putc>
          s++;
 786:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 789:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78c:	8a 00                	mov    (%eax),%al
 78e:	84 c0                	test   %al,%al
 790:	75 dd                	jne    76f <printf+0x102>
 792:	eb 68                	jmp    7fc <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 794:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 798:	75 1d                	jne    7b7 <printf+0x14a>
        putc(fd, *ap);
 79a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	0f be c0             	movsbl %al,%eax
 7a2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	89 04 24             	mov    %eax,(%esp)
 7ac:	e8 df fd ff ff       	call   590 <putc>
        ap++;
 7b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b5:	eb 45                	jmp    7fc <printf+0x18f>
      } else if(c == '%'){
 7b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7bb:	75 17                	jne    7d4 <printf+0x167>
        putc(fd, c);
 7bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c0:	0f be c0             	movsbl %al,%eax
 7c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ca:	89 04 24             	mov    %eax,(%esp)
 7cd:	e8 be fd ff ff       	call   590 <putc>
 7d2:	eb 28                	jmp    7fc <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7db:	00 
 7dc:	8b 45 08             	mov    0x8(%ebp),%eax
 7df:	89 04 24             	mov    %eax,(%esp)
 7e2:	e8 a9 fd ff ff       	call   590 <putc>
        putc(fd, c);
 7e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ea:	0f be c0             	movsbl %al,%eax
 7ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f1:	8b 45 08             	mov    0x8(%ebp),%eax
 7f4:	89 04 24             	mov    %eax,(%esp)
 7f7:	e8 94 fd ff ff       	call   590 <putc>
      }
      state = 0;
 7fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 803:	ff 45 f0             	incl   -0x10(%ebp)
 806:	8b 55 0c             	mov    0xc(%ebp),%edx
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	01 d0                	add    %edx,%eax
 80e:	8a 00                	mov    (%eax),%al
 810:	84 c0                	test   %al,%al
 812:	0f 85 77 fe ff ff    	jne    68f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 818:	c9                   	leave  
 819:	c3                   	ret    
 81a:	90                   	nop
 81b:	90                   	nop

0000081c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81c:	55                   	push   %ebp
 81d:	89 e5                	mov    %esp,%ebp
 81f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 822:	8b 45 08             	mov    0x8(%ebp),%eax
 825:	83 e8 08             	sub    $0x8,%eax
 828:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82b:	a1 08 0d 00 00       	mov    0xd08,%eax
 830:	89 45 fc             	mov    %eax,-0x4(%ebp)
 833:	eb 24                	jmp    859 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83d:	77 12                	ja     851 <free+0x35>
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 845:	77 24                	ja     86b <free+0x4f>
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	8b 00                	mov    (%eax),%eax
 84c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 84f:	77 1a                	ja     86b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	89 45 fc             	mov    %eax,-0x4(%ebp)
 859:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 85f:	76 d4                	jbe    835 <free+0x19>
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 869:	76 ca                	jbe    835 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	8b 40 04             	mov    0x4(%eax),%eax
 871:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 878:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87b:	01 c2                	add    %eax,%edx
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	39 c2                	cmp    %eax,%edx
 884:	75 24                	jne    8aa <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 886:	8b 45 f8             	mov    -0x8(%ebp),%eax
 889:	8b 50 04             	mov    0x4(%eax),%edx
 88c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88f:	8b 00                	mov    (%eax),%eax
 891:	8b 40 04             	mov    0x4(%eax),%eax
 894:	01 c2                	add    %eax,%edx
 896:	8b 45 f8             	mov    -0x8(%ebp),%eax
 899:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 89c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89f:	8b 00                	mov    (%eax),%eax
 8a1:	8b 10                	mov    (%eax),%edx
 8a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a6:	89 10                	mov    %edx,(%eax)
 8a8:	eb 0a                	jmp    8b4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	8b 10                	mov    (%eax),%edx
 8af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	8b 40 04             	mov    0x4(%eax),%eax
 8ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	01 d0                	add    %edx,%eax
 8c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8c9:	75 20                	jne    8eb <free+0xcf>
    p->s.size += bp->s.size;
 8cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ce:	8b 50 04             	mov    0x4(%eax),%edx
 8d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d4:	8b 40 04             	mov    0x4(%eax),%eax
 8d7:	01 c2                	add    %eax,%edx
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e2:	8b 10                	mov    (%eax),%edx
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	89 10                	mov    %edx,(%eax)
 8e9:	eb 08                	jmp    8f3 <free+0xd7>
  } else
    p->s.ptr = bp;
 8eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ee:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f1:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	a3 08 0d 00 00       	mov    %eax,0xd08
}
 8fb:	c9                   	leave  
 8fc:	c3                   	ret    

000008fd <morecore>:

static Header*
morecore(uint nu)
{
 8fd:	55                   	push   %ebp
 8fe:	89 e5                	mov    %esp,%ebp
 900:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 903:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 90a:	77 07                	ja     913 <morecore+0x16>
    nu = 4096;
 90c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 913:	8b 45 08             	mov    0x8(%ebp),%eax
 916:	c1 e0 03             	shl    $0x3,%eax
 919:	89 04 24             	mov    %eax,(%esp)
 91c:	e8 8f fb ff ff       	call   4b0 <sbrk>
 921:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 924:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 928:	75 07                	jne    931 <morecore+0x34>
    return 0;
 92a:	b8 00 00 00 00       	mov    $0x0,%eax
 92f:	eb 22                	jmp    953 <morecore+0x56>
  hp = (Header*)p;
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 937:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93a:	8b 55 08             	mov    0x8(%ebp),%edx
 93d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 940:	8b 45 f0             	mov    -0x10(%ebp),%eax
 943:	83 c0 08             	add    $0x8,%eax
 946:	89 04 24             	mov    %eax,(%esp)
 949:	e8 ce fe ff ff       	call   81c <free>
  return freep;
 94e:	a1 08 0d 00 00       	mov    0xd08,%eax
}
 953:	c9                   	leave  
 954:	c3                   	ret    

00000955 <malloc>:

void*
malloc(uint nbytes)
{
 955:	55                   	push   %ebp
 956:	89 e5                	mov    %esp,%ebp
 958:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95b:	8b 45 08             	mov    0x8(%ebp),%eax
 95e:	83 c0 07             	add    $0x7,%eax
 961:	c1 e8 03             	shr    $0x3,%eax
 964:	40                   	inc    %eax
 965:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 968:	a1 08 0d 00 00       	mov    0xd08,%eax
 96d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 970:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 974:	75 23                	jne    999 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 976:	c7 45 f0 00 0d 00 00 	movl   $0xd00,-0x10(%ebp)
 97d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 980:	a3 08 0d 00 00       	mov    %eax,0xd08
 985:	a1 08 0d 00 00       	mov    0xd08,%eax
 98a:	a3 00 0d 00 00       	mov    %eax,0xd00
    base.s.size = 0;
 98f:	c7 05 04 0d 00 00 00 	movl   $0x0,0xd04
 996:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 999:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99c:	8b 00                	mov    (%eax),%eax
 99e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a4:	8b 40 04             	mov    0x4(%eax),%eax
 9a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9aa:	72 4d                	jb     9f9 <malloc+0xa4>
      if(p->s.size == nunits)
 9ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9af:	8b 40 04             	mov    0x4(%eax),%eax
 9b2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9b5:	75 0c                	jne    9c3 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 9b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ba:	8b 10                	mov    (%eax),%edx
 9bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bf:	89 10                	mov    %edx,(%eax)
 9c1:	eb 26                	jmp    9e9 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c6:	8b 40 04             	mov    0x4(%eax),%eax
 9c9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9cc:	89 c2                	mov    %eax,%edx
 9ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	8b 40 04             	mov    0x4(%eax),%eax
 9da:	c1 e0 03             	shl    $0x3,%eax
 9dd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ec:	a3 08 0d 00 00       	mov    %eax,0xd08
      return (void*)(p + 1);
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	83 c0 08             	add    $0x8,%eax
 9f7:	eb 38                	jmp    a31 <malloc+0xdc>
    }
    if(p == freep)
 9f9:	a1 08 0d 00 00       	mov    0xd08,%eax
 9fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a01:	75 1b                	jne    a1e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a06:	89 04 24             	mov    %eax,(%esp)
 a09:	e8 ef fe ff ff       	call   8fd <morecore>
 a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a15:	75 07                	jne    a1e <malloc+0xc9>
        return 0;
 a17:	b8 00 00 00 00       	mov    $0x0,%eax
 a1c:	eb 13                	jmp    a31 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a21:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 00                	mov    (%eax),%eax
 a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a2c:	e9 70 ff ff ff       	jmp    9a1 <malloc+0x4c>
}
 a31:	c9                   	leave  
 a32:	c3                   	ret    
