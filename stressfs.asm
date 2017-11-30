
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   f:	8d 94 24 1e 02 00 00 	lea    0x21e(%esp),%edx
  16:	bb 1e 0a 00 00       	mov    $0xa1e,%ebx
  1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  20:	89 d7                	mov    %edx,%edi
  22:	89 de                	mov    %ebx,%esi
  24:	89 c1                	mov    %eax,%ecx
  26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  char data[512];

  printf(1, "stressfs starting\n");
  28:	c7 44 24 04 fb 09 00 	movl   $0x9fb,0x4(%esp)
  2f:	00 
  30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  37:	e8 f9 05 00 00       	call   635 <printf>
  memset(data, 'a', sizeof(data));
  3c:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  43:	00 
  44:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4b:	00 
  4c:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  50:	89 04 24             	mov    %eax,(%esp)
  53:	e8 04 02 00 00       	call   25c <memset>

  for(i = 0; i < 4; i++)
  58:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  5f:	00 00 00 00 
  63:	eb 12                	jmp    77 <main+0x77>
    if(fork() > 0)
  65:	e8 8e 03 00 00       	call   3f8 <fork>
  6a:	85 c0                	test   %eax,%eax
  6c:	7e 02                	jle    70 <main+0x70>
      break;
  6e:	eb 11                	jmp    81 <main+0x81>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  70:	ff 84 24 2c 02 00 00 	incl   0x22c(%esp)
  77:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
  7e:	03 
  7f:	7e e4                	jle    65 <main+0x65>
    if(fork() > 0)
      break;

  printf(1, "write %d\n", i);
  81:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  88:	89 44 24 08          	mov    %eax,0x8(%esp)
  8c:	c7 44 24 04 0e 0a 00 	movl   $0xa0e,0x4(%esp)
  93:	00 
  94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9b:	e8 95 05 00 00       	call   635 <printf>

  path[8] += i;
  a0:	8a 84 24 26 02 00 00 	mov    0x226(%esp),%al
  a7:	88 c2                	mov    %al,%dl
  a9:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  b0:	01 d0                	add    %edx,%eax
  b2:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  b9:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  c0:	00 
  c1:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
  c8:	89 04 24             	mov    %eax,(%esp)
  cb:	e8 70 03 00 00       	call   440 <open>
  d0:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
  d7:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  de:	00 00 00 00 
  e2:	eb 26                	jmp    10a <main+0x10a>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  e4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  eb:	00 
  ec:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  f4:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
  fb:	89 04 24             	mov    %eax,(%esp)
  fe:	e8 1d 03 00 00       	call   420 <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
 103:	ff 84 24 2c 02 00 00 	incl   0x22c(%esp)
 10a:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 111:	13 
 112:	7e d0                	jle    e4 <main+0xe4>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
 114:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 11b:	89 04 24             	mov    %eax,(%esp)
 11e:	e8 05 03 00 00       	call   428 <close>

  printf(1, "read\n");
 123:	c7 44 24 04 18 0a 00 	movl   $0xa18,0x4(%esp)
 12a:	00 
 12b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 132:	e8 fe 04 00 00       	call   635 <printf>

  fd = open(path, O_RDONLY);
 137:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 13e:	00 
 13f:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 146:	89 04 24             	mov    %eax,(%esp)
 149:	e8 f2 02 00 00       	call   440 <open>
 14e:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
 155:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 15c:	00 00 00 00 
 160:	eb 26                	jmp    188 <main+0x188>
    read(fd, data, sizeof(data));
 162:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 169:	00 
 16a:	8d 44 24 1e          	lea    0x1e(%esp),%eax
 16e:	89 44 24 04          	mov    %eax,0x4(%esp)
 172:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 179:	89 04 24             	mov    %eax,(%esp)
 17c:	e8 97 02 00 00       	call   418 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 181:	ff 84 24 2c 02 00 00 	incl   0x22c(%esp)
 188:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 18f:	13 
 190:	7e d0                	jle    162 <main+0x162>
    read(fd, data, sizeof(data));
  close(fd);
 192:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 199:	89 04 24             	mov    %eax,(%esp)
 19c:	e8 87 02 00 00       	call   428 <close>

  wait();
 1a1:	e8 62 02 00 00       	call   408 <wait>

  exit();
 1a6:	e8 55 02 00 00       	call   400 <exit>
 1ab:	90                   	nop

000001ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	57                   	push   %edi
 1b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1b4:	8b 55 10             	mov    0x10(%ebp),%edx
 1b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ba:	89 cb                	mov    %ecx,%ebx
 1bc:	89 df                	mov    %ebx,%edi
 1be:	89 d1                	mov    %edx,%ecx
 1c0:	fc                   	cld    
 1c1:	f3 aa                	rep stos %al,%es:(%edi)
 1c3:	89 ca                	mov    %ecx,%edx
 1c5:	89 fb                	mov    %edi,%ebx
 1c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1cd:	5b                   	pop    %ebx
 1ce:	5f                   	pop    %edi
 1cf:	5d                   	pop    %ebp
 1d0:	c3                   	ret    

000001d1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
 1d4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
 1da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1dd:	90                   	nop
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	8d 50 01             	lea    0x1(%eax),%edx
 1e4:	89 55 08             	mov    %edx,0x8(%ebp)
 1e7:	8b 55 0c             	mov    0xc(%ebp),%edx
 1ea:	8d 4a 01             	lea    0x1(%edx),%ecx
 1ed:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1f0:	8a 12                	mov    (%edx),%dl
 1f2:	88 10                	mov    %dl,(%eax)
 1f4:	8a 00                	mov    (%eax),%al
 1f6:	84 c0                	test   %al,%al
 1f8:	75 e4                	jne    1de <strcpy+0xd>
    ;
  return os;
 1fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1fd:	c9                   	leave  
 1fe:	c3                   	ret    

000001ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 202:	eb 06                	jmp    20a <strcmp+0xb>
    p++, q++;
 204:	ff 45 08             	incl   0x8(%ebp)
 207:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	8a 00                	mov    (%eax),%al
 20f:	84 c0                	test   %al,%al
 211:	74 0e                	je     221 <strcmp+0x22>
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	8a 10                	mov    (%eax),%dl
 218:	8b 45 0c             	mov    0xc(%ebp),%eax
 21b:	8a 00                	mov    (%eax),%al
 21d:	38 c2                	cmp    %al,%dl
 21f:	74 e3                	je     204 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 221:	8b 45 08             	mov    0x8(%ebp),%eax
 224:	8a 00                	mov    (%eax),%al
 226:	0f b6 d0             	movzbl %al,%edx
 229:	8b 45 0c             	mov    0xc(%ebp),%eax
 22c:	8a 00                	mov    (%eax),%al
 22e:	0f b6 c0             	movzbl %al,%eax
 231:	29 c2                	sub    %eax,%edx
 233:	89 d0                	mov    %edx,%eax
}
 235:	5d                   	pop    %ebp
 236:	c3                   	ret    

00000237 <strlen>:

uint
strlen(char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 244:	eb 03                	jmp    249 <strlen+0x12>
 246:	ff 45 fc             	incl   -0x4(%ebp)
 249:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	01 d0                	add    %edx,%eax
 251:	8a 00                	mov    (%eax),%al
 253:	84 c0                	test   %al,%al
 255:	75 ef                	jne    246 <strlen+0xf>
    ;
  return n;
 257:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 25a:	c9                   	leave  
 25b:	c3                   	ret    

0000025c <memset>:

void*
memset(void *dst, int c, uint n)
{
 25c:	55                   	push   %ebp
 25d:	89 e5                	mov    %esp,%ebp
 25f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 262:	8b 45 10             	mov    0x10(%ebp),%eax
 265:	89 44 24 08          	mov    %eax,0x8(%esp)
 269:	8b 45 0c             	mov    0xc(%ebp),%eax
 26c:	89 44 24 04          	mov    %eax,0x4(%esp)
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	89 04 24             	mov    %eax,(%esp)
 276:	e8 31 ff ff ff       	call   1ac <stosb>
  return dst;
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27e:	c9                   	leave  
 27f:	c3                   	ret    

00000280 <strchr>:

char*
strchr(const char *s, char c)
{
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	83 ec 04             	sub    $0x4,%esp
 286:	8b 45 0c             	mov    0xc(%ebp),%eax
 289:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 28c:	eb 12                	jmp    2a0 <strchr+0x20>
    if(*s == c)
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	8a 00                	mov    (%eax),%al
 293:	3a 45 fc             	cmp    -0x4(%ebp),%al
 296:	75 05                	jne    29d <strchr+0x1d>
      return (char*)s;
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	eb 11                	jmp    2ae <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 29d:	ff 45 08             	incl   0x8(%ebp)
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	8a 00                	mov    (%eax),%al
 2a5:	84 c0                	test   %al,%al
 2a7:	75 e5                	jne    28e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2ae:	c9                   	leave  
 2af:	c3                   	ret    

000002b0 <gets>:

char*
gets(char *buf, int max)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2bd:	eb 49                	jmp    308 <gets+0x58>
    cc = read(0, &c, 1);
 2bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2c6:	00 
 2c7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2d5:	e8 3e 01 00 00       	call   418 <read>
 2da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2e1:	7f 02                	jg     2e5 <gets+0x35>
      break;
 2e3:	eb 2c                	jmp    311 <gets+0x61>
    buf[i++] = c;
 2e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e8:	8d 50 01             	lea    0x1(%eax),%edx
 2eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2ee:	89 c2                	mov    %eax,%edx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	01 c2                	add    %eax,%edx
 2f5:	8a 45 ef             	mov    -0x11(%ebp),%al
 2f8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2fa:	8a 45 ef             	mov    -0x11(%ebp),%al
 2fd:	3c 0a                	cmp    $0xa,%al
 2ff:	74 10                	je     311 <gets+0x61>
 301:	8a 45 ef             	mov    -0x11(%ebp),%al
 304:	3c 0d                	cmp    $0xd,%al
 306:	74 09                	je     311 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 308:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30b:	40                   	inc    %eax
 30c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 30f:	7c ae                	jl     2bf <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 311:	8b 55 f4             	mov    -0xc(%ebp),%edx
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	01 d0                	add    %edx,%eax
 319:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 31f:	c9                   	leave  
 320:	c3                   	ret    

00000321 <stat>:

int
stat(char *n, struct stat *st)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
 324:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 327:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 32e:	00 
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	89 04 24             	mov    %eax,(%esp)
 335:	e8 06 01 00 00       	call   440 <open>
 33a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 33d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 341:	79 07                	jns    34a <stat+0x29>
    return -1;
 343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 348:	eb 23                	jmp    36d <stat+0x4c>
  r = fstat(fd, st);
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	89 44 24 04          	mov    %eax,0x4(%esp)
 351:	8b 45 f4             	mov    -0xc(%ebp),%eax
 354:	89 04 24             	mov    %eax,(%esp)
 357:	e8 fc 00 00 00       	call   458 <fstat>
 35c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 35f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 362:	89 04 24             	mov    %eax,(%esp)
 365:	e8 be 00 00 00       	call   428 <close>
  return r;
 36a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <atoi>:

int
atoi(const char *s)
{
 36f:	55                   	push   %ebp
 370:	89 e5                	mov    %esp,%ebp
 372:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 375:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 37c:	eb 24                	jmp    3a2 <atoi+0x33>
    n = n*10 + *s++ - '0';
 37e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 381:	89 d0                	mov    %edx,%eax
 383:	c1 e0 02             	shl    $0x2,%eax
 386:	01 d0                	add    %edx,%eax
 388:	01 c0                	add    %eax,%eax
 38a:	89 c1                	mov    %eax,%ecx
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	8d 50 01             	lea    0x1(%eax),%edx
 392:	89 55 08             	mov    %edx,0x8(%ebp)
 395:	8a 00                	mov    (%eax),%al
 397:	0f be c0             	movsbl %al,%eax
 39a:	01 c8                	add    %ecx,%eax
 39c:	83 e8 30             	sub    $0x30,%eax
 39f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	8a 00                	mov    (%eax),%al
 3a7:	3c 2f                	cmp    $0x2f,%al
 3a9:	7e 09                	jle    3b4 <atoi+0x45>
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	8a 00                	mov    (%eax),%al
 3b0:	3c 39                	cmp    $0x39,%al
 3b2:	7e ca                	jle    37e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b7:	c9                   	leave  
 3b8:	c3                   	ret    

000003b9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3b9:	55                   	push   %ebp
 3ba:	89 e5                	mov    %esp,%ebp
 3bc:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3cb:	eb 16                	jmp    3e3 <memmove+0x2a>
    *dst++ = *src++;
 3cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3d0:	8d 50 01             	lea    0x1(%eax),%edx
 3d3:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3d6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3d9:	8d 4a 01             	lea    0x1(%edx),%ecx
 3dc:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3df:	8a 12                	mov    (%edx),%dl
 3e1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3e3:	8b 45 10             	mov    0x10(%ebp),%eax
 3e6:	8d 50 ff             	lea    -0x1(%eax),%edx
 3e9:	89 55 10             	mov    %edx,0x10(%ebp)
 3ec:	85 c0                	test   %eax,%eax
 3ee:	7f dd                	jg     3cd <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f3:	c9                   	leave  
 3f4:	c3                   	ret    
 3f5:	90                   	nop
 3f6:	90                   	nop
 3f7:	90                   	nop

000003f8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3f8:	b8 01 00 00 00       	mov    $0x1,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <exit>:
SYSCALL(exit)
 400:	b8 02 00 00 00       	mov    $0x2,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <wait>:
SYSCALL(wait)
 408:	b8 03 00 00 00       	mov    $0x3,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <pipe>:
SYSCALL(pipe)
 410:	b8 04 00 00 00       	mov    $0x4,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <read>:
SYSCALL(read)
 418:	b8 05 00 00 00       	mov    $0x5,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <write>:
SYSCALL(write)
 420:	b8 10 00 00 00       	mov    $0x10,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <close>:
SYSCALL(close)
 428:	b8 15 00 00 00       	mov    $0x15,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <kill>:
SYSCALL(kill)
 430:	b8 06 00 00 00       	mov    $0x6,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <exec>:
SYSCALL(exec)
 438:	b8 07 00 00 00       	mov    $0x7,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <open>:
SYSCALL(open)
 440:	b8 0f 00 00 00       	mov    $0xf,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <mknod>:
SYSCALL(mknod)
 448:	b8 11 00 00 00       	mov    $0x11,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <unlink>:
SYSCALL(unlink)
 450:	b8 12 00 00 00       	mov    $0x12,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <fstat>:
SYSCALL(fstat)
 458:	b8 08 00 00 00       	mov    $0x8,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <link>:
SYSCALL(link)
 460:	b8 13 00 00 00       	mov    $0x13,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <mkdir>:
SYSCALL(mkdir)
 468:	b8 14 00 00 00       	mov    $0x14,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <chdir>:
SYSCALL(chdir)
 470:	b8 09 00 00 00       	mov    $0x9,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <dup>:
SYSCALL(dup)
 478:	b8 0a 00 00 00       	mov    $0xa,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <getpid>:
SYSCALL(getpid)
 480:	b8 0b 00 00 00       	mov    $0xb,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <sbrk>:
SYSCALL(sbrk)
 488:	b8 0c 00 00 00       	mov    $0xc,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <sleep>:
SYSCALL(sleep)
 490:	b8 0d 00 00 00       	mov    $0xd,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <uptime>:
SYSCALL(uptime)
 498:	b8 0e 00 00 00       	mov    $0xe,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <getticks>:
SYSCALL(getticks)
 4a0:	b8 16 00 00 00       	mov    $0x16,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <get_name>:
SYSCALL(get_name)
 4a8:	b8 17 00 00 00       	mov    $0x17,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <get_max_proc>:
SYSCALL(get_max_proc)
 4b0:	b8 18 00 00 00       	mov    $0x18,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <get_max_mem>:
SYSCALL(get_max_mem)
 4b8:	b8 19 00 00 00       	mov    $0x19,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <get_max_disk>:
SYSCALL(get_max_disk)
 4c0:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <get_curr_proc>:
SYSCALL(get_curr_proc)
 4c8:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <get_curr_mem>:
SYSCALL(get_curr_mem)
 4d0:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <get_curr_disk>:
SYSCALL(get_curr_disk)
 4d8:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <set_name>:
SYSCALL(set_name)
 4e0:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <set_max_mem>:
SYSCALL(set_max_mem)
 4e8:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <set_max_disk>:
SYSCALL(set_max_disk)
 4f0:	b8 20 00 00 00       	mov    $0x20,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <set_max_proc>:
SYSCALL(set_max_proc)
 4f8:	b8 21 00 00 00       	mov    $0x21,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <set_curr_mem>:
SYSCALL(set_curr_mem)
 500:	b8 22 00 00 00       	mov    $0x22,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <set_curr_disk>:
SYSCALL(set_curr_disk)
 508:	b8 23 00 00 00       	mov    $0x23,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <set_curr_proc>:
SYSCALL(set_curr_proc)
 510:	b8 24 00 00 00       	mov    $0x24,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <find>:
SYSCALL(find)
 518:	b8 25 00 00 00       	mov    $0x25,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <is_full>:
SYSCALL(is_full)
 520:	b8 26 00 00 00       	mov    $0x26,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <container_init>:
SYSCALL(container_init)
 528:	b8 27 00 00 00       	mov    $0x27,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <cont_proc_set>:
SYSCALL(cont_proc_set)
 530:	b8 28 00 00 00       	mov    $0x28,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <ps>:
SYSCALL(ps)
 538:	b8 29 00 00 00       	mov    $0x29,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 540:	b8 2a 00 00 00       	mov    $0x2a,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <set_root_inode>:
SYSCALL(set_root_inode)
 548:	b8 2b 00 00 00       	mov    $0x2b,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <cstop>:
 550:	b8 2c 00 00 00       	mov    $0x2c,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	83 ec 18             	sub    $0x18,%esp
 55e:	8b 45 0c             	mov    0xc(%ebp),%eax
 561:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 564:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 56b:	00 
 56c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 56f:	89 44 24 04          	mov    %eax,0x4(%esp)
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	89 04 24             	mov    %eax,(%esp)
 579:	e8 a2 fe ff ff       	call   420 <write>
}
 57e:	c9                   	leave  
 57f:	c3                   	ret    

00000580 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	56                   	push   %esi
 584:	53                   	push   %ebx
 585:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 588:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 58f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 593:	74 17                	je     5ac <printint+0x2c>
 595:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 599:	79 11                	jns    5ac <printint+0x2c>
    neg = 1;
 59b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a5:	f7 d8                	neg    %eax
 5a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5aa:	eb 06                	jmp    5b2 <printint+0x32>
  } else {
    x = xx;
 5ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 5af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5bc:	8d 41 01             	lea    0x1(%ecx),%eax
 5bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c8:	ba 00 00 00 00       	mov    $0x0,%edx
 5cd:	f7 f3                	div    %ebx
 5cf:	89 d0                	mov    %edx,%eax
 5d1:	8a 80 78 0c 00 00    	mov    0xc78(%eax),%al
 5d7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5db:	8b 75 10             	mov    0x10(%ebp),%esi
 5de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5e1:	ba 00 00 00 00       	mov    $0x0,%edx
 5e6:	f7 f6                	div    %esi
 5e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ef:	75 c8                	jne    5b9 <printint+0x39>
  if(neg)
 5f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5f5:	74 10                	je     607 <printint+0x87>
    buf[i++] = '-';
 5f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fa:	8d 50 01             	lea    0x1(%eax),%edx
 5fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 600:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 605:	eb 1e                	jmp    625 <printint+0xa5>
 607:	eb 1c                	jmp    625 <printint+0xa5>
    putc(fd, buf[i]);
 609:	8d 55 dc             	lea    -0x24(%ebp),%edx
 60c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60f:	01 d0                	add    %edx,%eax
 611:	8a 00                	mov    (%eax),%al
 613:	0f be c0             	movsbl %al,%eax
 616:	89 44 24 04          	mov    %eax,0x4(%esp)
 61a:	8b 45 08             	mov    0x8(%ebp),%eax
 61d:	89 04 24             	mov    %eax,(%esp)
 620:	e8 33 ff ff ff       	call   558 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 625:	ff 4d f4             	decl   -0xc(%ebp)
 628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62c:	79 db                	jns    609 <printint+0x89>
    putc(fd, buf[i]);
}
 62e:	83 c4 30             	add    $0x30,%esp
 631:	5b                   	pop    %ebx
 632:	5e                   	pop    %esi
 633:	5d                   	pop    %ebp
 634:	c3                   	ret    

00000635 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 635:	55                   	push   %ebp
 636:	89 e5                	mov    %esp,%ebp
 638:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 63b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 642:	8d 45 0c             	lea    0xc(%ebp),%eax
 645:	83 c0 04             	add    $0x4,%eax
 648:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 64b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 652:	e9 77 01 00 00       	jmp    7ce <printf+0x199>
    c = fmt[i] & 0xff;
 657:	8b 55 0c             	mov    0xc(%ebp),%edx
 65a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 65d:	01 d0                	add    %edx,%eax
 65f:	8a 00                	mov    (%eax),%al
 661:	0f be c0             	movsbl %al,%eax
 664:	25 ff 00 00 00       	and    $0xff,%eax
 669:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 66c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 670:	75 2c                	jne    69e <printf+0x69>
      if(c == '%'){
 672:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 676:	75 0c                	jne    684 <printf+0x4f>
        state = '%';
 678:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 67f:	e9 47 01 00 00       	jmp    7cb <printf+0x196>
      } else {
        putc(fd, c);
 684:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 687:	0f be c0             	movsbl %al,%eax
 68a:	89 44 24 04          	mov    %eax,0x4(%esp)
 68e:	8b 45 08             	mov    0x8(%ebp),%eax
 691:	89 04 24             	mov    %eax,(%esp)
 694:	e8 bf fe ff ff       	call   558 <putc>
 699:	e9 2d 01 00 00       	jmp    7cb <printf+0x196>
      }
    } else if(state == '%'){
 69e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6a2:	0f 85 23 01 00 00    	jne    7cb <printf+0x196>
      if(c == 'd'){
 6a8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6ac:	75 2d                	jne    6db <printf+0xa6>
        printint(fd, *ap, 10, 1);
 6ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b1:	8b 00                	mov    (%eax),%eax
 6b3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6ba:	00 
 6bb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6c2:	00 
 6c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	89 04 24             	mov    %eax,(%esp)
 6cd:	e8 ae fe ff ff       	call   580 <printint>
        ap++;
 6d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d6:	e9 e9 00 00 00       	jmp    7c4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 6db:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6df:	74 06                	je     6e7 <printf+0xb2>
 6e1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6e5:	75 2d                	jne    714 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 6e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ea:	8b 00                	mov    (%eax),%eax
 6ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6f3:	00 
 6f4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6fb:	00 
 6fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 700:	8b 45 08             	mov    0x8(%ebp),%eax
 703:	89 04 24             	mov    %eax,(%esp)
 706:	e8 75 fe ff ff       	call   580 <printint>
        ap++;
 70b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70f:	e9 b0 00 00 00       	jmp    7c4 <printf+0x18f>
      } else if(c == 's'){
 714:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 718:	75 42                	jne    75c <printf+0x127>
        s = (char*)*ap;
 71a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71d:	8b 00                	mov    (%eax),%eax
 71f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 722:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 726:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 72a:	75 09                	jne    735 <printf+0x100>
          s = "(null)";
 72c:	c7 45 f4 28 0a 00 00 	movl   $0xa28,-0xc(%ebp)
        while(*s != 0){
 733:	eb 1c                	jmp    751 <printf+0x11c>
 735:	eb 1a                	jmp    751 <printf+0x11c>
          putc(fd, *s);
 737:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73a:	8a 00                	mov    (%eax),%al
 73c:	0f be c0             	movsbl %al,%eax
 73f:	89 44 24 04          	mov    %eax,0x4(%esp)
 743:	8b 45 08             	mov    0x8(%ebp),%eax
 746:	89 04 24             	mov    %eax,(%esp)
 749:	e8 0a fe ff ff       	call   558 <putc>
          s++;
 74e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 751:	8b 45 f4             	mov    -0xc(%ebp),%eax
 754:	8a 00                	mov    (%eax),%al
 756:	84 c0                	test   %al,%al
 758:	75 dd                	jne    737 <printf+0x102>
 75a:	eb 68                	jmp    7c4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 75c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 760:	75 1d                	jne    77f <printf+0x14a>
        putc(fd, *ap);
 762:	8b 45 e8             	mov    -0x18(%ebp),%eax
 765:	8b 00                	mov    (%eax),%eax
 767:	0f be c0             	movsbl %al,%eax
 76a:	89 44 24 04          	mov    %eax,0x4(%esp)
 76e:	8b 45 08             	mov    0x8(%ebp),%eax
 771:	89 04 24             	mov    %eax,(%esp)
 774:	e8 df fd ff ff       	call   558 <putc>
        ap++;
 779:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 77d:	eb 45                	jmp    7c4 <printf+0x18f>
      } else if(c == '%'){
 77f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 783:	75 17                	jne    79c <printf+0x167>
        putc(fd, c);
 785:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 788:	0f be c0             	movsbl %al,%eax
 78b:	89 44 24 04          	mov    %eax,0x4(%esp)
 78f:	8b 45 08             	mov    0x8(%ebp),%eax
 792:	89 04 24             	mov    %eax,(%esp)
 795:	e8 be fd ff ff       	call   558 <putc>
 79a:	eb 28                	jmp    7c4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 79c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7a3:	00 
 7a4:	8b 45 08             	mov    0x8(%ebp),%eax
 7a7:	89 04 24             	mov    %eax,(%esp)
 7aa:	e8 a9 fd ff ff       	call   558 <putc>
        putc(fd, c);
 7af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b2:	0f be c0             	movsbl %al,%eax
 7b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b9:	8b 45 08             	mov    0x8(%ebp),%eax
 7bc:	89 04 24             	mov    %eax,(%esp)
 7bf:	e8 94 fd ff ff       	call   558 <putc>
      }
      state = 0;
 7c4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7cb:	ff 45 f0             	incl   -0x10(%ebp)
 7ce:	8b 55 0c             	mov    0xc(%ebp),%edx
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	01 d0                	add    %edx,%eax
 7d6:	8a 00                	mov    (%eax),%al
 7d8:	84 c0                	test   %al,%al
 7da:	0f 85 77 fe ff ff    	jne    657 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7e0:	c9                   	leave  
 7e1:	c3                   	ret    
 7e2:	90                   	nop
 7e3:	90                   	nop

000007e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e4:	55                   	push   %ebp
 7e5:	89 e5                	mov    %esp,%ebp
 7e7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ea:	8b 45 08             	mov    0x8(%ebp),%eax
 7ed:	83 e8 08             	sub    $0x8,%eax
 7f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f3:	a1 94 0c 00 00       	mov    0xc94,%eax
 7f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7fb:	eb 24                	jmp    821 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 805:	77 12                	ja     819 <free+0x35>
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 80d:	77 24                	ja     833 <free+0x4f>
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8b 00                	mov    (%eax),%eax
 814:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 817:	77 1a                	ja     833 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 821:	8b 45 f8             	mov    -0x8(%ebp),%eax
 824:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 827:	76 d4                	jbe    7fd <free+0x19>
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	8b 00                	mov    (%eax),%eax
 82e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 831:	76 ca                	jbe    7fd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 833:	8b 45 f8             	mov    -0x8(%ebp),%eax
 836:	8b 40 04             	mov    0x4(%eax),%eax
 839:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 840:	8b 45 f8             	mov    -0x8(%ebp),%eax
 843:	01 c2                	add    %eax,%edx
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	39 c2                	cmp    %eax,%edx
 84c:	75 24                	jne    872 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 84e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 851:	8b 50 04             	mov    0x4(%eax),%edx
 854:	8b 45 fc             	mov    -0x4(%ebp),%eax
 857:	8b 00                	mov    (%eax),%eax
 859:	8b 40 04             	mov    0x4(%eax),%eax
 85c:	01 c2                	add    %eax,%edx
 85e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 861:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	8b 00                	mov    (%eax),%eax
 869:	8b 10                	mov    (%eax),%edx
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	89 10                	mov    %edx,(%eax)
 870:	eb 0a                	jmp    87c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	8b 10                	mov    (%eax),%edx
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 40 04             	mov    0x4(%eax),%eax
 882:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	01 d0                	add    %edx,%eax
 88e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 891:	75 20                	jne    8b3 <free+0xcf>
    p->s.size += bp->s.size;
 893:	8b 45 fc             	mov    -0x4(%ebp),%eax
 896:	8b 50 04             	mov    0x4(%eax),%edx
 899:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89c:	8b 40 04             	mov    0x4(%eax),%eax
 89f:	01 c2                	add    %eax,%edx
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	8b 10                	mov    (%eax),%edx
 8ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8af:	89 10                	mov    %edx,(%eax)
 8b1:	eb 08                	jmp    8bb <free+0xd7>
  } else
    p->s.ptr = bp;
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b9:	89 10                	mov    %edx,(%eax)
  freep = p;
 8bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8be:	a3 94 0c 00 00       	mov    %eax,0xc94
}
 8c3:	c9                   	leave  
 8c4:	c3                   	ret    

000008c5 <morecore>:

static Header*
morecore(uint nu)
{
 8c5:	55                   	push   %ebp
 8c6:	89 e5                	mov    %esp,%ebp
 8c8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8cb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8d2:	77 07                	ja     8db <morecore+0x16>
    nu = 4096;
 8d4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8db:	8b 45 08             	mov    0x8(%ebp),%eax
 8de:	c1 e0 03             	shl    $0x3,%eax
 8e1:	89 04 24             	mov    %eax,(%esp)
 8e4:	e8 9f fb ff ff       	call   488 <sbrk>
 8e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ec:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8f0:	75 07                	jne    8f9 <morecore+0x34>
    return 0;
 8f2:	b8 00 00 00 00       	mov    $0x0,%eax
 8f7:	eb 22                	jmp    91b <morecore+0x56>
  hp = (Header*)p;
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 902:	8b 55 08             	mov    0x8(%ebp),%edx
 905:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 908:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90b:	83 c0 08             	add    $0x8,%eax
 90e:	89 04 24             	mov    %eax,(%esp)
 911:	e8 ce fe ff ff       	call   7e4 <free>
  return freep;
 916:	a1 94 0c 00 00       	mov    0xc94,%eax
}
 91b:	c9                   	leave  
 91c:	c3                   	ret    

0000091d <malloc>:

void*
malloc(uint nbytes)
{
 91d:	55                   	push   %ebp
 91e:	89 e5                	mov    %esp,%ebp
 920:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 923:	8b 45 08             	mov    0x8(%ebp),%eax
 926:	83 c0 07             	add    $0x7,%eax
 929:	c1 e8 03             	shr    $0x3,%eax
 92c:	40                   	inc    %eax
 92d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 930:	a1 94 0c 00 00       	mov    0xc94,%eax
 935:	89 45 f0             	mov    %eax,-0x10(%ebp)
 938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 93c:	75 23                	jne    961 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 93e:	c7 45 f0 8c 0c 00 00 	movl   $0xc8c,-0x10(%ebp)
 945:	8b 45 f0             	mov    -0x10(%ebp),%eax
 948:	a3 94 0c 00 00       	mov    %eax,0xc94
 94d:	a1 94 0c 00 00       	mov    0xc94,%eax
 952:	a3 8c 0c 00 00       	mov    %eax,0xc8c
    base.s.size = 0;
 957:	c7 05 90 0c 00 00 00 	movl   $0x0,0xc90
 95e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	8b 40 04             	mov    0x4(%eax),%eax
 96f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 972:	72 4d                	jb     9c1 <malloc+0xa4>
      if(p->s.size == nunits)
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	8b 40 04             	mov    0x4(%eax),%eax
 97a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97d:	75 0c                	jne    98b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	8b 10                	mov    (%eax),%edx
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	89 10                	mov    %edx,(%eax)
 989:	eb 26                	jmp    9b1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	8b 40 04             	mov    0x4(%eax),%eax
 991:	2b 45 ec             	sub    -0x14(%ebp),%eax
 994:	89 c2                	mov    %eax,%edx
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 40 04             	mov    0x4(%eax),%eax
 9a2:	c1 e0 03             	shl    $0x3,%eax
 9a5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b4:	a3 94 0c 00 00       	mov    %eax,0xc94
      return (void*)(p + 1);
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	83 c0 08             	add    $0x8,%eax
 9bf:	eb 38                	jmp    9f9 <malloc+0xdc>
    }
    if(p == freep)
 9c1:	a1 94 0c 00 00       	mov    0xc94,%eax
 9c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c9:	75 1b                	jne    9e6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 9cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9ce:	89 04 24             	mov    %eax,(%esp)
 9d1:	e8 ef fe ff ff       	call   8c5 <morecore>
 9d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9dd:	75 07                	jne    9e6 <malloc+0xc9>
        return 0;
 9df:	b8 00 00 00 00       	mov    $0x0,%eax
 9e4:	eb 13                	jmp    9f9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 00                	mov    (%eax),%eax
 9f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9f4:	e9 70 ff ff ff       	jmp    969 <malloc+0x4c>
}
 9f9:	c9                   	leave  
 9fa:	c3                   	ret    
