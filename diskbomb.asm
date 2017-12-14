
_diskbomb:     file format elf32-i386


Disassembly of section .text:

00000000 <createfile>:
#define BLOCKSIZE 512
#define NBLOCKS 140

void
createfile(char *filename, char *buf, int blocksize, int count, int *totalblocks)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;
  int rv;

  fd = open(filename, O_CREATE | O_WRONLY);
   6:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
   d:	00 
   e:	8b 45 08             	mov    0x8(%ebp),%eax
  11:	89 04 24             	mov    %eax,(%esp)
  14:	e8 4b 05 00 00       	call   564 <open>
  19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (fd < 0) {
  1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  20:	79 19                	jns    3b <createfile+0x3b>
    printf(1, "diskbomb: open() failed, exiting.\n");
  22:	c7 44 24 04 88 0b 00 	movl   $0xb88,0x4(%esp)
  29:	00 
  2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  31:	e8 8b 07 00 00       	call   7c1 <printf>
    exit();
  36:	e8 e9 04 00 00       	call   524 <exit>
  }

  for (i = 0; i < count; i++) {
  3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  42:	eb 6b                	jmp    af <createfile+0xaf>
    rv = write(fd, buf, blocksize);
  44:	8b 45 10             	mov    0x10(%ebp),%eax
  47:	89 44 24 08          	mov    %eax,0x8(%esp)
  4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  55:	89 04 24             	mov    %eax,(%esp)
  58:	e8 e7 04 00 00       	call   544 <write>
  5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (rv < 0) {
  60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  64:	79 19                	jns    7f <createfile+0x7f>
      printf(1, "diskbomb: write() failed, exiting.\n");
  66:	c7 44 24 04 ac 0b 00 	movl   $0xbac,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  75:	e8 47 07 00 00       	call   7c1 <printf>
      exit();
  7a:	e8 a5 04 00 00       	call   524 <exit>
    }

    *totalblocks += BLOCKSIZE;
  7f:	8b 45 18             	mov    0x18(%ebp),%eax
  82:	8b 00                	mov    (%eax),%eax
  84:	8d 90 00 02 00 00    	lea    0x200(%eax),%edx
  8a:	8b 45 18             	mov    0x18(%ebp),%eax
  8d:	89 10                	mov    %edx,(%eax)
    printf(1, "diskbomb: total blocks written: %d\n", *totalblocks);
  8f:	8b 45 18             	mov    0x18(%ebp),%eax
  92:	8b 00                	mov    (%eax),%eax
  94:	89 44 24 08          	mov    %eax,0x8(%esp)
  98:	c7 44 24 04 d0 0b 00 	movl   $0xbd0,0x4(%esp)
  9f:	00 
  a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a7:	e8 15 07 00 00       	call   7c1 <printf>
  if (fd < 0) {
    printf(1, "diskbomb: open() failed, exiting.\n");
    exit();
  }

  for (i = 0; i < count; i++) {
  ac:	ff 45 f4             	incl   -0xc(%ebp)
  af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b2:	3b 45 14             	cmp    0x14(%ebp),%eax
  b5:	7c 8d                	jl     44 <createfile+0x44>
    }

    *totalblocks += BLOCKSIZE;
    printf(1, "diskbomb: total blocks written: %d\n", *totalblocks);
  }
  close(fd);
  b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ba:	89 04 24             	mov    %eax,(%esp)
  bd:	e8 8a 04 00 00       	call   54c <close>
}
  c2:	c9                   	leave  
  c3:	c3                   	ret    

000000c4 <setfilename>:

void
setfilename(char *filename, int i)
{
  c4:	55                   	push   %ebp
  c5:	89 e5                	mov    %esp,%ebp
  c7:	83 ec 18             	sub    $0x18,%esp
  filename[0] = 'D';
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	c6 00 44             	movb   $0x44,(%eax)
  filename[1] = 'B';
  d0:	8b 45 08             	mov    0x8(%ebp),%eax
  d3:	40                   	inc    %eax
  d4:	c6 00 42             	movb   $0x42,(%eax)
  itoa(i, &filename[2], 10);
  d7:	8b 45 08             	mov    0x8(%ebp),%eax
  da:	83 c0 02             	add    $0x2,%eax
  dd:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
  e4:	00 
  e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  ec:	89 04 24             	mov    %eax,(%esp)
  ef:	e8 41 03 00 00       	call   435 <itoa>
}
  f4:	c9                   	leave  
  f5:	c3                   	ret    

000000f6 <main>:

int
main(int argc, char *argv[])
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  f9:	83 e4 f0             	and    $0xfffffff0,%esp
  fc:	81 ec 40 02 00 00    	sub    $0x240,%esp
  int i = 0;
 102:	c7 84 24 3c 02 00 00 	movl   $0x0,0x23c(%esp)
 109:	00 00 00 00 
  int totalblocks = 0;
 10d:	c7 84 24 34 02 00 00 	movl   $0x0,0x234(%esp)
 114:	00 00 00 00 
  int totalfiles = 0;
 118:	c7 84 24 38 02 00 00 	movl   $0x0,0x238(%esp)
 11f:	00 00 00 00 
  char filename[16];
  char buf[BLOCKSIZE];

  /* Initialize buf with 'a' */
  for (i = 0; i < BLOCKSIZE; i++) {
 123:	c7 84 24 3c 02 00 00 	movl   $0x0,0x23c(%esp)
 12a:	00 00 00 00 
 12e:	eb 17                	jmp    147 <main+0x51>
    buf[i] = 'a';
 130:	8d 54 24 24          	lea    0x24(%esp),%edx
 134:	8b 84 24 3c 02 00 00 	mov    0x23c(%esp),%eax
 13b:	01 d0                	add    %edx,%eax
 13d:	c6 00 61             	movb   $0x61,(%eax)
  int totalfiles = 0;
  char filename[16];
  char buf[BLOCKSIZE];

  /* Initialize buf with 'a' */
  for (i = 0; i < BLOCKSIZE; i++) {
 140:	ff 84 24 3c 02 00 00 	incl   0x23c(%esp)
 147:	81 bc 24 3c 02 00 00 	cmpl   $0x1ff,0x23c(%esp)
 14e:	ff 01 00 00 
 152:	7e dc                	jle    130 <main+0x3a>
    buf[i] = 'a';
  }

  while(1) {
    setfilename(filename, totalfiles);
 154:	8b 84 24 38 02 00 00 	mov    0x238(%esp),%eax
 15b:	89 44 24 04          	mov    %eax,0x4(%esp)
 15f:	8d 84 24 24 02 00 00 	lea    0x224(%esp),%eax
 166:	89 04 24             	mov    %eax,(%esp)
 169:	e8 56 ff ff ff       	call   c4 <setfilename>
    printf(1, "diskbomb: creating %s\n", filename);
 16e:	8d 84 24 24 02 00 00 	lea    0x224(%esp),%eax
 175:	89 44 24 08          	mov    %eax,0x8(%esp)
 179:	c7 44 24 04 f4 0b 00 	movl   $0xbf4,0x4(%esp)
 180:	00 
 181:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 188:	e8 34 06 00 00       	call   7c1 <printf>
    createfile(filename, buf, BLOCKSIZE, NBLOCKS, &totalblocks);
 18d:	8d 84 24 34 02 00 00 	lea    0x234(%esp),%eax
 194:	89 44 24 10          	mov    %eax,0x10(%esp)
 198:	c7 44 24 0c 8c 00 00 	movl   $0x8c,0xc(%esp)
 19f:	00 
 1a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 1a7:	00 
 1a8:	8d 44 24 24          	lea    0x24(%esp),%eax
 1ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b0:	8d 84 24 24 02 00 00 	lea    0x224(%esp),%eax
 1b7:	89 04 24             	mov    %eax,(%esp)
 1ba:	e8 41 fe ff ff       	call   0 <createfile>
    totalfiles += 1;
 1bf:	ff 84 24 38 02 00 00 	incl   0x238(%esp)
    printf(1, "diskbomb: total files created: %d\n", totalfiles);
 1c6:	8b 84 24 38 02 00 00 	mov    0x238(%esp),%eax
 1cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d1:	c7 44 24 04 0c 0c 00 	movl   $0xc0c,0x4(%esp)
 1d8:	00 
 1d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e0:	e8 dc 05 00 00       	call   7c1 <printf>
  }
 1e5:	e9 6a ff ff ff       	jmp    154 <main+0x5e>
 1ea:	90                   	nop
 1eb:	90                   	nop

000001ec <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	57                   	push   %edi
 1f0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1f4:	8b 55 10             	mov    0x10(%ebp),%edx
 1f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fa:	89 cb                	mov    %ecx,%ebx
 1fc:	89 df                	mov    %ebx,%edi
 1fe:	89 d1                	mov    %edx,%ecx
 200:	fc                   	cld    
 201:	f3 aa                	rep stos %al,%es:(%edi)
 203:	89 ca                	mov    %ecx,%edx
 205:	89 fb                	mov    %edi,%ebx
 207:	89 5d 08             	mov    %ebx,0x8(%ebp)
 20a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 20d:	5b                   	pop    %ebx
 20e:	5f                   	pop    %edi
 20f:	5d                   	pop    %ebp
 210:	c3                   	ret    

00000211 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 21d:	90                   	nop
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	8d 50 01             	lea    0x1(%eax),%edx
 224:	89 55 08             	mov    %edx,0x8(%ebp)
 227:	8b 55 0c             	mov    0xc(%ebp),%edx
 22a:	8d 4a 01             	lea    0x1(%edx),%ecx
 22d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 230:	8a 12                	mov    (%edx),%dl
 232:	88 10                	mov    %dl,(%eax)
 234:	8a 00                	mov    (%eax),%al
 236:	84 c0                	test   %al,%al
 238:	75 e4                	jne    21e <strcpy+0xd>
    ;
  return os;
 23a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 23d:	c9                   	leave  
 23e:	c3                   	ret    

0000023f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 23f:	55                   	push   %ebp
 240:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 242:	eb 06                	jmp    24a <strcmp+0xb>
    p++, q++;
 244:	ff 45 08             	incl   0x8(%ebp)
 247:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	8a 00                	mov    (%eax),%al
 24f:	84 c0                	test   %al,%al
 251:	74 0e                	je     261 <strcmp+0x22>
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	8a 10                	mov    (%eax),%dl
 258:	8b 45 0c             	mov    0xc(%ebp),%eax
 25b:	8a 00                	mov    (%eax),%al
 25d:	38 c2                	cmp    %al,%dl
 25f:	74 e3                	je     244 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	8a 00                	mov    (%eax),%al
 266:	0f b6 d0             	movzbl %al,%edx
 269:	8b 45 0c             	mov    0xc(%ebp),%eax
 26c:	8a 00                	mov    (%eax),%al
 26e:	0f b6 c0             	movzbl %al,%eax
 271:	29 c2                	sub    %eax,%edx
 273:	89 d0                	mov    %edx,%eax
}
 275:	5d                   	pop    %ebp
 276:	c3                   	ret    

00000277 <strlen>:

uint
strlen(char *s)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 27d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 284:	eb 03                	jmp    289 <strlen+0x12>
 286:	ff 45 fc             	incl   -0x4(%ebp)
 289:	8b 55 fc             	mov    -0x4(%ebp),%edx
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	01 d0                	add    %edx,%eax
 291:	8a 00                	mov    (%eax),%al
 293:	84 c0                	test   %al,%al
 295:	75 ef                	jne    286 <strlen+0xf>
    ;
  return n;
 297:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <memset>:

void*
memset(void *dst, int c, uint n)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2a2:	8b 45 10             	mov    0x10(%ebp),%eax
 2a5:	89 44 24 08          	mov    %eax,0x8(%esp)
 2a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	89 04 24             	mov    %eax,(%esp)
 2b6:	e8 31 ff ff ff       	call   1ec <stosb>
  return dst;
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2be:	c9                   	leave  
 2bf:	c3                   	ret    

000002c0 <strchr>:

char*
strchr(const char *s, char c)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 04             	sub    $0x4,%esp
 2c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2cc:	eb 12                	jmp    2e0 <strchr+0x20>
    if(*s == c)
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	8a 00                	mov    (%eax),%al
 2d3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2d6:	75 05                	jne    2dd <strchr+0x1d>
      return (char*)s;
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
 2db:	eb 11                	jmp    2ee <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2dd:	ff 45 08             	incl   0x8(%ebp)
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	8a 00                	mov    (%eax),%al
 2e5:	84 c0                	test   %al,%al
 2e7:	75 e5                	jne    2ce <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2ee:	c9                   	leave  
 2ef:	c3                   	ret    

000002f0 <gets>:

char*
gets(char *buf, int max)
{
 2f0:	55                   	push   %ebp
 2f1:	89 e5                	mov    %esp,%ebp
 2f3:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2fd:	eb 49                	jmp    348 <gets+0x58>
    cc = read(0, &c, 1);
 2ff:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 306:	00 
 307:	8d 45 ef             	lea    -0x11(%ebp),%eax
 30a:	89 44 24 04          	mov    %eax,0x4(%esp)
 30e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 315:	e8 22 02 00 00       	call   53c <read>
 31a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 31d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 321:	7f 02                	jg     325 <gets+0x35>
      break;
 323:	eb 2c                	jmp    351 <gets+0x61>
    buf[i++] = c;
 325:	8b 45 f4             	mov    -0xc(%ebp),%eax
 328:	8d 50 01             	lea    0x1(%eax),%edx
 32b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 32e:	89 c2                	mov    %eax,%edx
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	01 c2                	add    %eax,%edx
 335:	8a 45 ef             	mov    -0x11(%ebp),%al
 338:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 33a:	8a 45 ef             	mov    -0x11(%ebp),%al
 33d:	3c 0a                	cmp    $0xa,%al
 33f:	74 10                	je     351 <gets+0x61>
 341:	8a 45 ef             	mov    -0x11(%ebp),%al
 344:	3c 0d                	cmp    $0xd,%al
 346:	74 09                	je     351 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 348:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34b:	40                   	inc    %eax
 34c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 34f:	7c ae                	jl     2ff <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 351:	8b 55 f4             	mov    -0xc(%ebp),%edx
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	01 d0                	add    %edx,%eax
 359:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35f:	c9                   	leave  
 360:	c3                   	ret    

00000361 <stat>:

int
stat(char *n, struct stat *st)
{
 361:	55                   	push   %ebp
 362:	89 e5                	mov    %esp,%ebp
 364:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 367:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 36e:	00 
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
 372:	89 04 24             	mov    %eax,(%esp)
 375:	e8 ea 01 00 00       	call   564 <open>
 37a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 37d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 381:	79 07                	jns    38a <stat+0x29>
    return -1;
 383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 388:	eb 23                	jmp    3ad <stat+0x4c>
  r = fstat(fd, st);
 38a:	8b 45 0c             	mov    0xc(%ebp),%eax
 38d:	89 44 24 04          	mov    %eax,0x4(%esp)
 391:	8b 45 f4             	mov    -0xc(%ebp),%eax
 394:	89 04 24             	mov    %eax,(%esp)
 397:	e8 e0 01 00 00       	call   57c <fstat>
 39c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 39f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a2:	89 04 24             	mov    %eax,(%esp)
 3a5:	e8 a2 01 00 00       	call   54c <close>
  return r;
 3aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3ad:	c9                   	leave  
 3ae:	c3                   	ret    

000003af <atoi>:

int
atoi(const char *s)
{
 3af:	55                   	push   %ebp
 3b0:	89 e5                	mov    %esp,%ebp
 3b2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3bc:	eb 24                	jmp    3e2 <atoi+0x33>
    n = n*10 + *s++ - '0';
 3be:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3c1:	89 d0                	mov    %edx,%eax
 3c3:	c1 e0 02             	shl    $0x2,%eax
 3c6:	01 d0                	add    %edx,%eax
 3c8:	01 c0                	add    %eax,%eax
 3ca:	89 c1                	mov    %eax,%ecx
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	8d 50 01             	lea    0x1(%eax),%edx
 3d2:	89 55 08             	mov    %edx,0x8(%ebp)
 3d5:	8a 00                	mov    (%eax),%al
 3d7:	0f be c0             	movsbl %al,%eax
 3da:	01 c8                	add    %ecx,%eax
 3dc:	83 e8 30             	sub    $0x30,%eax
 3df:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
 3e5:	8a 00                	mov    (%eax),%al
 3e7:	3c 2f                	cmp    $0x2f,%al
 3e9:	7e 09                	jle    3f4 <atoi+0x45>
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	8a 00                	mov    (%eax),%al
 3f0:	3c 39                	cmp    $0x39,%al
 3f2:	7e ca                	jle    3be <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f7:	c9                   	leave  
 3f8:	c3                   	ret    

000003f9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3f9:	55                   	push   %ebp
 3fa:	89 e5                	mov    %esp,%ebp
 3fc:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 40b:	eb 16                	jmp    423 <memmove+0x2a>
    *dst++ = *src++;
 40d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 410:	8d 50 01             	lea    0x1(%eax),%edx
 413:	89 55 fc             	mov    %edx,-0x4(%ebp)
 416:	8b 55 f8             	mov    -0x8(%ebp),%edx
 419:	8d 4a 01             	lea    0x1(%edx),%ecx
 41c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 41f:	8a 12                	mov    (%edx),%dl
 421:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 423:	8b 45 10             	mov    0x10(%ebp),%eax
 426:	8d 50 ff             	lea    -0x1(%eax),%edx
 429:	89 55 10             	mov    %edx,0x10(%ebp)
 42c:	85 c0                	test   %eax,%eax
 42e:	7f dd                	jg     40d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 430:	8b 45 08             	mov    0x8(%ebp),%eax
}
 433:	c9                   	leave  
 434:	c3                   	ret    

00000435 <itoa>:

int itoa(int value, char *sp, int radix)
{
 435:	55                   	push   %ebp
 436:	89 e5                	mov    %esp,%ebp
 438:	53                   	push   %ebx
 439:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 43c:	8d 45 d8             	lea    -0x28(%ebp),%eax
 43f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 442:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 446:	75 0d                	jne    455 <itoa+0x20>
 448:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 44c:	79 07                	jns    455 <itoa+0x20>
 44e:	b8 01 00 00 00       	mov    $0x1,%eax
 453:	eb 05                	jmp    45a <itoa+0x25>
 455:	b8 00 00 00 00       	mov    $0x0,%eax
 45a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 45d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 461:	74 0a                	je     46d <itoa+0x38>
      v = -value;
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	f7 d8                	neg    %eax
 468:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 46b:	eb 54                	jmp    4c1 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 473:	eb 4c                	jmp    4c1 <itoa+0x8c>
  {
    i = v % radix;
 475:	8b 4d 10             	mov    0x10(%ebp),%ecx
 478:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47b:	ba 00 00 00 00       	mov    $0x0,%edx
 480:	f7 f1                	div    %ecx
 482:	89 d0                	mov    %edx,%eax
 484:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 487:	8b 5d 10             	mov    0x10(%ebp),%ebx
 48a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48d:	ba 00 00 00 00       	mov    $0x0,%edx
 492:	f7 f3                	div    %ebx
 494:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 497:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 49b:	7f 13                	jg     4b0 <itoa+0x7b>
      *tp++ = i+'0';
 49d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4a0:	8d 50 01             	lea    0x1(%eax),%edx
 4a3:	89 55 f8             	mov    %edx,-0x8(%ebp)
 4a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
 4a9:	83 c2 30             	add    $0x30,%edx
 4ac:	88 10                	mov    %dl,(%eax)
 4ae:	eb 11                	jmp    4c1 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 4b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4b3:	8d 50 01             	lea    0x1(%eax),%edx
 4b6:	89 55 f8             	mov    %edx,-0x8(%ebp)
 4b9:	8b 55 e8             	mov    -0x18(%ebp),%edx
 4bc:	83 c2 57             	add    $0x57,%edx
 4bf:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 4c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c5:	75 ae                	jne    475 <itoa+0x40>
 4c7:	8d 45 d8             	lea    -0x28(%ebp),%eax
 4ca:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 4cd:	74 a6                	je     475 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 4cf:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4d2:	8d 45 d8             	lea    -0x28(%ebp),%eax
 4d5:	29 c2                	sub    %eax,%edx
 4d7:	89 d0                	mov    %edx,%eax
 4d9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 4dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e0:	74 11                	je     4f3 <itoa+0xbe>
  {
    *sp++ = '-';
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	8d 50 01             	lea    0x1(%eax),%edx
 4e8:	89 55 0c             	mov    %edx,0xc(%ebp)
 4eb:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 4ee:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 4f1:	eb 15                	jmp    508 <itoa+0xd3>
 4f3:	eb 13                	jmp    508 <itoa+0xd3>
    *sp++ = *--tp;
 4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f8:	8d 50 01             	lea    0x1(%eax),%edx
 4fb:	89 55 0c             	mov    %edx,0xc(%ebp)
 4fe:	ff 4d f8             	decl   -0x8(%ebp)
 501:	8b 55 f8             	mov    -0x8(%ebp),%edx
 504:	8a 12                	mov    (%edx),%dl
 506:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 508:	8d 45 d8             	lea    -0x28(%ebp),%eax
 50b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 50e:	77 e5                	ja     4f5 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 510:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 513:	83 c4 30             	add    $0x30,%esp
 516:	5b                   	pop    %ebx
 517:	5d                   	pop    %ebp
 518:	c3                   	ret    
 519:	90                   	nop
 51a:	90                   	nop
 51b:	90                   	nop

0000051c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 51c:	b8 01 00 00 00       	mov    $0x1,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <exit>:
SYSCALL(exit)
 524:	b8 02 00 00 00       	mov    $0x2,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <wait>:
SYSCALL(wait)
 52c:	b8 03 00 00 00       	mov    $0x3,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <pipe>:
SYSCALL(pipe)
 534:	b8 04 00 00 00       	mov    $0x4,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <read>:
SYSCALL(read)
 53c:	b8 05 00 00 00       	mov    $0x5,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <write>:
SYSCALL(write)
 544:	b8 10 00 00 00       	mov    $0x10,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <close>:
SYSCALL(close)
 54c:	b8 15 00 00 00       	mov    $0x15,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <kill>:
SYSCALL(kill)
 554:	b8 06 00 00 00       	mov    $0x6,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <exec>:
SYSCALL(exec)
 55c:	b8 07 00 00 00       	mov    $0x7,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <open>:
SYSCALL(open)
 564:	b8 0f 00 00 00       	mov    $0xf,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <mknod>:
SYSCALL(mknod)
 56c:	b8 11 00 00 00       	mov    $0x11,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <unlink>:
SYSCALL(unlink)
 574:	b8 12 00 00 00       	mov    $0x12,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <fstat>:
SYSCALL(fstat)
 57c:	b8 08 00 00 00       	mov    $0x8,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <link>:
SYSCALL(link)
 584:	b8 13 00 00 00       	mov    $0x13,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <mkdir>:
SYSCALL(mkdir)
 58c:	b8 14 00 00 00       	mov    $0x14,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <chdir>:
SYSCALL(chdir)
 594:	b8 09 00 00 00       	mov    $0x9,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <dup>:
SYSCALL(dup)
 59c:	b8 0a 00 00 00       	mov    $0xa,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <getpid>:
SYSCALL(getpid)
 5a4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <sbrk>:
SYSCALL(sbrk)
 5ac:	b8 0c 00 00 00       	mov    $0xc,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <sleep>:
SYSCALL(sleep)
 5b4:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <uptime>:
SYSCALL(uptime)
 5bc:	b8 0e 00 00 00       	mov    $0xe,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <getticks>:
SYSCALL(getticks)
 5c4:	b8 16 00 00 00       	mov    $0x16,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <get_name>:
SYSCALL(get_name)
 5cc:	b8 17 00 00 00       	mov    $0x17,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <get_max_proc>:
SYSCALL(get_max_proc)
 5d4:	b8 18 00 00 00       	mov    $0x18,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <get_max_mem>:
SYSCALL(get_max_mem)
 5dc:	b8 19 00 00 00       	mov    $0x19,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <get_max_disk>:
SYSCALL(get_max_disk)
 5e4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <get_curr_proc>:
SYSCALL(get_curr_proc)
 5ec:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <get_curr_mem>:
SYSCALL(get_curr_mem)
 5f4:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <get_curr_disk>:
SYSCALL(get_curr_disk)
 5fc:	b8 1d 00 00 00       	mov    $0x1d,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <set_name>:
SYSCALL(set_name)
 604:	b8 1e 00 00 00       	mov    $0x1e,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <set_max_mem>:
SYSCALL(set_max_mem)
 60c:	b8 1f 00 00 00       	mov    $0x1f,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <set_max_disk>:
SYSCALL(set_max_disk)
 614:	b8 20 00 00 00       	mov    $0x20,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <set_max_proc>:
SYSCALL(set_max_proc)
 61c:	b8 21 00 00 00       	mov    $0x21,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <set_curr_mem>:
SYSCALL(set_curr_mem)
 624:	b8 22 00 00 00       	mov    $0x22,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <set_curr_disk>:
SYSCALL(set_curr_disk)
 62c:	b8 23 00 00 00       	mov    $0x23,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <set_curr_proc>:
SYSCALL(set_curr_proc)
 634:	b8 24 00 00 00       	mov    $0x24,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <find>:
SYSCALL(find)
 63c:	b8 25 00 00 00       	mov    $0x25,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <is_full>:
SYSCALL(is_full)
 644:	b8 26 00 00 00       	mov    $0x26,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <container_init>:
SYSCALL(container_init)
 64c:	b8 27 00 00 00       	mov    $0x27,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <cont_proc_set>:
SYSCALL(cont_proc_set)
 654:	b8 28 00 00 00       	mov    $0x28,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <ps>:
SYSCALL(ps)
 65c:	b8 29 00 00 00       	mov    $0x29,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 664:	b8 2a 00 00 00       	mov    $0x2a,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <set_root_inode>:
SYSCALL(set_root_inode)
 66c:	b8 2b 00 00 00       	mov    $0x2b,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <cstop>:
SYSCALL(cstop)
 674:	b8 2c 00 00 00       	mov    $0x2c,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <df>:
SYSCALL(df)
 67c:	b8 2d 00 00 00       	mov    $0x2d,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <max_containers>:
SYSCALL(max_containers)
 684:	b8 2e 00 00 00       	mov    $0x2e,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <container_reset>:
SYSCALL(container_reset)
 68c:	b8 2f 00 00 00       	mov    $0x2f,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <pause>:
SYSCALL(pause)
 694:	b8 30 00 00 00       	mov    $0x30,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	ret    

0000069c <resume>:
SYSCALL(resume)
 69c:	b8 31 00 00 00       	mov    $0x31,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	ret    

000006a4 <tmem>:
SYSCALL(tmem)
 6a4:	b8 32 00 00 00       	mov    $0x32,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	ret    

000006ac <amem>:
SYSCALL(amem)
 6ac:	b8 33 00 00 00       	mov    $0x33,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	ret    

000006b4 <c_ps>:
SYSCALL(c_ps)
 6b4:	b8 34 00 00 00       	mov    $0x34,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	ret    

000006bc <get_used>:
SYSCALL(get_used)
 6bc:	b8 35 00 00 00       	mov    $0x35,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	ret    

000006c4 <get_os>:
SYSCALL(get_os)
 6c4:	b8 36 00 00 00       	mov    $0x36,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	ret    

000006cc <set_os>:
SYSCALL(set_os)
 6cc:	b8 37 00 00 00       	mov    $0x37,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	ret    

000006d4 <get_cticks>:
SYSCALL(get_cticks)
 6d4:	b8 38 00 00 00       	mov    $0x38,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	ret    

000006dc <tick_reset2>:
SYSCALL(tick_reset2)
 6dc:	b8 39 00 00 00       	mov    $0x39,%eax
 6e1:	cd 40                	int    $0x40
 6e3:	c3                   	ret    

000006e4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6e4:	55                   	push   %ebp
 6e5:	89 e5                	mov    %esp,%ebp
 6e7:	83 ec 18             	sub    $0x18,%esp
 6ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ed:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6f0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6f7:	00 
 6f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ff:	8b 45 08             	mov    0x8(%ebp),%eax
 702:	89 04 24             	mov    %eax,(%esp)
 705:	e8 3a fe ff ff       	call   544 <write>
}
 70a:	c9                   	leave  
 70b:	c3                   	ret    

0000070c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 70c:	55                   	push   %ebp
 70d:	89 e5                	mov    %esp,%ebp
 70f:	56                   	push   %esi
 710:	53                   	push   %ebx
 711:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 714:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 71b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 71f:	74 17                	je     738 <printint+0x2c>
 721:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 725:	79 11                	jns    738 <printint+0x2c>
    neg = 1;
 727:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 72e:	8b 45 0c             	mov    0xc(%ebp),%eax
 731:	f7 d8                	neg    %eax
 733:	89 45 ec             	mov    %eax,-0x14(%ebp)
 736:	eb 06                	jmp    73e <printint+0x32>
  } else {
    x = xx;
 738:	8b 45 0c             	mov    0xc(%ebp),%eax
 73b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 73e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 745:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 748:	8d 41 01             	lea    0x1(%ecx),%eax
 74b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 74e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 751:	8b 45 ec             	mov    -0x14(%ebp),%eax
 754:	ba 00 00 00 00       	mov    $0x0,%edx
 759:	f7 f3                	div    %ebx
 75b:	89 d0                	mov    %edx,%eax
 75d:	8a 80 e0 0e 00 00    	mov    0xee0(%eax),%al
 763:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 767:	8b 75 10             	mov    0x10(%ebp),%esi
 76a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 76d:	ba 00 00 00 00       	mov    $0x0,%edx
 772:	f7 f6                	div    %esi
 774:	89 45 ec             	mov    %eax,-0x14(%ebp)
 777:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 77b:	75 c8                	jne    745 <printint+0x39>
  if(neg)
 77d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 781:	74 10                	je     793 <printint+0x87>
    buf[i++] = '-';
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	8d 50 01             	lea    0x1(%eax),%edx
 789:	89 55 f4             	mov    %edx,-0xc(%ebp)
 78c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 791:	eb 1e                	jmp    7b1 <printint+0xa5>
 793:	eb 1c                	jmp    7b1 <printint+0xa5>
    putc(fd, buf[i]);
 795:	8d 55 dc             	lea    -0x24(%ebp),%edx
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	01 d0                	add    %edx,%eax
 79d:	8a 00                	mov    (%eax),%al
 79f:	0f be c0             	movsbl %al,%eax
 7a2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	89 04 24             	mov    %eax,(%esp)
 7ac:	e8 33 ff ff ff       	call   6e4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7b1:	ff 4d f4             	decl   -0xc(%ebp)
 7b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b8:	79 db                	jns    795 <printint+0x89>
    putc(fd, buf[i]);
}
 7ba:	83 c4 30             	add    $0x30,%esp
 7bd:	5b                   	pop    %ebx
 7be:	5e                   	pop    %esi
 7bf:	5d                   	pop    %ebp
 7c0:	c3                   	ret    

000007c1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7c1:	55                   	push   %ebp
 7c2:	89 e5                	mov    %esp,%ebp
 7c4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7c7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7ce:	8d 45 0c             	lea    0xc(%ebp),%eax
 7d1:	83 c0 04             	add    $0x4,%eax
 7d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7de:	e9 77 01 00 00       	jmp    95a <printf+0x199>
    c = fmt[i] & 0xff;
 7e3:	8b 55 0c             	mov    0xc(%ebp),%edx
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	01 d0                	add    %edx,%eax
 7eb:	8a 00                	mov    (%eax),%al
 7ed:	0f be c0             	movsbl %al,%eax
 7f0:	25 ff 00 00 00       	and    $0xff,%eax
 7f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7fc:	75 2c                	jne    82a <printf+0x69>
      if(c == '%'){
 7fe:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 802:	75 0c                	jne    810 <printf+0x4f>
        state = '%';
 804:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 80b:	e9 47 01 00 00       	jmp    957 <printf+0x196>
      } else {
        putc(fd, c);
 810:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 813:	0f be c0             	movsbl %al,%eax
 816:	89 44 24 04          	mov    %eax,0x4(%esp)
 81a:	8b 45 08             	mov    0x8(%ebp),%eax
 81d:	89 04 24             	mov    %eax,(%esp)
 820:	e8 bf fe ff ff       	call   6e4 <putc>
 825:	e9 2d 01 00 00       	jmp    957 <printf+0x196>
      }
    } else if(state == '%'){
 82a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 82e:	0f 85 23 01 00 00    	jne    957 <printf+0x196>
      if(c == 'd'){
 834:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 838:	75 2d                	jne    867 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 83a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83d:	8b 00                	mov    (%eax),%eax
 83f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 846:	00 
 847:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 84e:	00 
 84f:	89 44 24 04          	mov    %eax,0x4(%esp)
 853:	8b 45 08             	mov    0x8(%ebp),%eax
 856:	89 04 24             	mov    %eax,(%esp)
 859:	e8 ae fe ff ff       	call   70c <printint>
        ap++;
 85e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 862:	e9 e9 00 00 00       	jmp    950 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 867:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 86b:	74 06                	je     873 <printf+0xb2>
 86d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 871:	75 2d                	jne    8a0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 873:	8b 45 e8             	mov    -0x18(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 87f:	00 
 880:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 887:	00 
 888:	89 44 24 04          	mov    %eax,0x4(%esp)
 88c:	8b 45 08             	mov    0x8(%ebp),%eax
 88f:	89 04 24             	mov    %eax,(%esp)
 892:	e8 75 fe ff ff       	call   70c <printint>
        ap++;
 897:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 89b:	e9 b0 00 00 00       	jmp    950 <printf+0x18f>
      } else if(c == 's'){
 8a0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8a4:	75 42                	jne    8e8 <printf+0x127>
        s = (char*)*ap;
 8a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a9:	8b 00                	mov    (%eax),%eax
 8ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8ae:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b6:	75 09                	jne    8c1 <printf+0x100>
          s = "(null)";
 8b8:	c7 45 f4 2f 0c 00 00 	movl   $0xc2f,-0xc(%ebp)
        while(*s != 0){
 8bf:	eb 1c                	jmp    8dd <printf+0x11c>
 8c1:	eb 1a                	jmp    8dd <printf+0x11c>
          putc(fd, *s);
 8c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c6:	8a 00                	mov    (%eax),%al
 8c8:	0f be c0             	movsbl %al,%eax
 8cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 8cf:	8b 45 08             	mov    0x8(%ebp),%eax
 8d2:	89 04 24             	mov    %eax,(%esp)
 8d5:	e8 0a fe ff ff       	call   6e4 <putc>
          s++;
 8da:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 8dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e0:	8a 00                	mov    (%eax),%al
 8e2:	84 c0                	test   %al,%al
 8e4:	75 dd                	jne    8c3 <printf+0x102>
 8e6:	eb 68                	jmp    950 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8e8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8ec:	75 1d                	jne    90b <printf+0x14a>
        putc(fd, *ap);
 8ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8f1:	8b 00                	mov    (%eax),%eax
 8f3:	0f be c0             	movsbl %al,%eax
 8f6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8fa:	8b 45 08             	mov    0x8(%ebp),%eax
 8fd:	89 04 24             	mov    %eax,(%esp)
 900:	e8 df fd ff ff       	call   6e4 <putc>
        ap++;
 905:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 909:	eb 45                	jmp    950 <printf+0x18f>
      } else if(c == '%'){
 90b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 90f:	75 17                	jne    928 <printf+0x167>
        putc(fd, c);
 911:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 914:	0f be c0             	movsbl %al,%eax
 917:	89 44 24 04          	mov    %eax,0x4(%esp)
 91b:	8b 45 08             	mov    0x8(%ebp),%eax
 91e:	89 04 24             	mov    %eax,(%esp)
 921:	e8 be fd ff ff       	call   6e4 <putc>
 926:	eb 28                	jmp    950 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 928:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 92f:	00 
 930:	8b 45 08             	mov    0x8(%ebp),%eax
 933:	89 04 24             	mov    %eax,(%esp)
 936:	e8 a9 fd ff ff       	call   6e4 <putc>
        putc(fd, c);
 93b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 93e:	0f be c0             	movsbl %al,%eax
 941:	89 44 24 04          	mov    %eax,0x4(%esp)
 945:	8b 45 08             	mov    0x8(%ebp),%eax
 948:	89 04 24             	mov    %eax,(%esp)
 94b:	e8 94 fd ff ff       	call   6e4 <putc>
      }
      state = 0;
 950:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 957:	ff 45 f0             	incl   -0x10(%ebp)
 95a:	8b 55 0c             	mov    0xc(%ebp),%edx
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	01 d0                	add    %edx,%eax
 962:	8a 00                	mov    (%eax),%al
 964:	84 c0                	test   %al,%al
 966:	0f 85 77 fe ff ff    	jne    7e3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 96c:	c9                   	leave  
 96d:	c3                   	ret    
 96e:	90                   	nop
 96f:	90                   	nop

00000970 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 970:	55                   	push   %ebp
 971:	89 e5                	mov    %esp,%ebp
 973:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 976:	8b 45 08             	mov    0x8(%ebp),%eax
 979:	83 e8 08             	sub    $0x8,%eax
 97c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97f:	a1 fc 0e 00 00       	mov    0xefc,%eax
 984:	89 45 fc             	mov    %eax,-0x4(%ebp)
 987:	eb 24                	jmp    9ad <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 989:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98c:	8b 00                	mov    (%eax),%eax
 98e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 991:	77 12                	ja     9a5 <free+0x35>
 993:	8b 45 f8             	mov    -0x8(%ebp),%eax
 996:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 999:	77 24                	ja     9bf <free+0x4f>
 99b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99e:	8b 00                	mov    (%eax),%eax
 9a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9a3:	77 1a                	ja     9bf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	8b 00                	mov    (%eax),%eax
 9aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9b3:	76 d4                	jbe    989 <free+0x19>
 9b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b8:	8b 00                	mov    (%eax),%eax
 9ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9bd:	76 ca                	jbe    989 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 9bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c2:	8b 40 04             	mov    0x4(%eax),%eax
 9c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9cf:	01 c2                	add    %eax,%edx
 9d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d4:	8b 00                	mov    (%eax),%eax
 9d6:	39 c2                	cmp    %eax,%edx
 9d8:	75 24                	jne    9fe <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dd:	8b 50 04             	mov    0x4(%eax),%edx
 9e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e3:	8b 00                	mov    (%eax),%eax
 9e5:	8b 40 04             	mov    0x4(%eax),%eax
 9e8:	01 c2                	add    %eax,%edx
 9ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ed:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f3:	8b 00                	mov    (%eax),%eax
 9f5:	8b 10                	mov    (%eax),%edx
 9f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fa:	89 10                	mov    %edx,(%eax)
 9fc:	eb 0a                	jmp    a08 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a01:	8b 10                	mov    (%eax),%edx
 a03:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a06:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a08:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0b:	8b 40 04             	mov    0x4(%eax),%eax
 a0e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a18:	01 d0                	add    %edx,%eax
 a1a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a1d:	75 20                	jne    a3f <free+0xcf>
    p->s.size += bp->s.size;
 a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a22:	8b 50 04             	mov    0x4(%eax),%edx
 a25:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a28:	8b 40 04             	mov    0x4(%eax),%eax
 a2b:	01 c2                	add    %eax,%edx
 a2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a30:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a33:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a36:	8b 10                	mov    (%eax),%edx
 a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3b:	89 10                	mov    %edx,(%eax)
 a3d:	eb 08                	jmp    a47 <free+0xd7>
  } else
    p->s.ptr = bp;
 a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a42:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a45:	89 10                	mov    %edx,(%eax)
  freep = p;
 a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4a:	a3 fc 0e 00 00       	mov    %eax,0xefc
}
 a4f:	c9                   	leave  
 a50:	c3                   	ret    

00000a51 <morecore>:

static Header*
morecore(uint nu)
{
 a51:	55                   	push   %ebp
 a52:	89 e5                	mov    %esp,%ebp
 a54:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a57:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a5e:	77 07                	ja     a67 <morecore+0x16>
    nu = 4096;
 a60:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a67:	8b 45 08             	mov    0x8(%ebp),%eax
 a6a:	c1 e0 03             	shl    $0x3,%eax
 a6d:	89 04 24             	mov    %eax,(%esp)
 a70:	e8 37 fb ff ff       	call   5ac <sbrk>
 a75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a78:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a7c:	75 07                	jne    a85 <morecore+0x34>
    return 0;
 a7e:	b8 00 00 00 00       	mov    $0x0,%eax
 a83:	eb 22                	jmp    aa7 <morecore+0x56>
  hp = (Header*)p;
 a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8e:	8b 55 08             	mov    0x8(%ebp),%edx
 a91:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a97:	83 c0 08             	add    $0x8,%eax
 a9a:	89 04 24             	mov    %eax,(%esp)
 a9d:	e8 ce fe ff ff       	call   970 <free>
  return freep;
 aa2:	a1 fc 0e 00 00       	mov    0xefc,%eax
}
 aa7:	c9                   	leave  
 aa8:	c3                   	ret    

00000aa9 <malloc>:

void*
malloc(uint nbytes)
{
 aa9:	55                   	push   %ebp
 aaa:	89 e5                	mov    %esp,%ebp
 aac:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aaf:	8b 45 08             	mov    0x8(%ebp),%eax
 ab2:	83 c0 07             	add    $0x7,%eax
 ab5:	c1 e8 03             	shr    $0x3,%eax
 ab8:	40                   	inc    %eax
 ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 abc:	a1 fc 0e 00 00       	mov    0xefc,%eax
 ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ac8:	75 23                	jne    aed <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 aca:	c7 45 f0 f4 0e 00 00 	movl   $0xef4,-0x10(%ebp)
 ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad4:	a3 fc 0e 00 00       	mov    %eax,0xefc
 ad9:	a1 fc 0e 00 00       	mov    0xefc,%eax
 ade:	a3 f4 0e 00 00       	mov    %eax,0xef4
    base.s.size = 0;
 ae3:	c7 05 f8 0e 00 00 00 	movl   $0x0,0xef8
 aea:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af0:	8b 00                	mov    (%eax),%eax
 af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af8:	8b 40 04             	mov    0x4(%eax),%eax
 afb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 afe:	72 4d                	jb     b4d <malloc+0xa4>
      if(p->s.size == nunits)
 b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b03:	8b 40 04             	mov    0x4(%eax),%eax
 b06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b09:	75 0c                	jne    b17 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0e:	8b 10                	mov    (%eax),%edx
 b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b13:	89 10                	mov    %edx,(%eax)
 b15:	eb 26                	jmp    b3d <malloc+0x94>
      else {
        p->s.size -= nunits;
 b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1a:	8b 40 04             	mov    0x4(%eax),%eax
 b1d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b20:	89 c2                	mov    %eax,%edx
 b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b25:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2b:	8b 40 04             	mov    0x4(%eax),%eax
 b2e:	c1 e0 03             	shl    $0x3,%eax
 b31:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b37:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b3a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b40:	a3 fc 0e 00 00       	mov    %eax,0xefc
      return (void*)(p + 1);
 b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b48:	83 c0 08             	add    $0x8,%eax
 b4b:	eb 38                	jmp    b85 <malloc+0xdc>
    }
    if(p == freep)
 b4d:	a1 fc 0e 00 00       	mov    0xefc,%eax
 b52:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b55:	75 1b                	jne    b72 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b5a:	89 04 24             	mov    %eax,(%esp)
 b5d:	e8 ef fe ff ff       	call   a51 <morecore>
 b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b69:	75 07                	jne    b72 <malloc+0xc9>
        return 0;
 b6b:	b8 00 00 00 00       	mov    $0x0,%eax
 b70:	eb 13                	jmp    b85 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b7b:	8b 00                	mov    (%eax),%eax
 b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b80:	e9 70 ff ff ff       	jmp    af5 <malloc+0x4c>
}
 b85:	c9                   	leave  
 b86:	c3                   	ret    
