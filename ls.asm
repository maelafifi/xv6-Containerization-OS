
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 cd 03 00 00       	call   3df <strlen>
  12:	8b 55 08             	mov    0x8(%ebp),%edx
  15:	01 d0                	add    %edx,%eax
  17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1a:	eb 03                	jmp    1f <fmtname+0x1f>
  1c:	ff 4d f4             	decl   -0xc(%ebp)
  1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  22:	3b 45 08             	cmp    0x8(%ebp),%eax
  25:	72 09                	jb     30 <fmtname+0x30>
  27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2a:	8a 00                	mov    (%eax),%al
  2c:	3c 2f                	cmp    $0x2f,%al
  2e:	75 ec                	jne    1c <fmtname+0x1c>
    ;
  p++;
  30:	ff 45 f4             	incl   -0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 a1 03 00 00       	call   3df <strlen>
  3e:	83 f8 0d             	cmp    $0xd,%eax
  41:	76 05                	jbe    48 <fmtname+0x48>
    return p;
  43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  46:	eb 5f                	jmp    a7 <fmtname+0xa7>
  memmove(buf, p, strlen(p));
  48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4b:	89 04 24             	mov    %eax,(%esp)
  4e:	e8 8c 03 00 00       	call   3df <strlen>
  53:	89 44 24 08          	mov    %eax,0x8(%esp)
  57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  5e:	c7 04 24 b8 0e 00 00 	movl   $0xeb8,(%esp)
  65:	e8 f7 04 00 00       	call   561 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6d:	89 04 24             	mov    %eax,(%esp)
  70:	e8 6a 03 00 00       	call   3df <strlen>
  75:	ba 0e 00 00 00       	mov    $0xe,%edx
  7a:	89 d3                	mov    %edx,%ebx
  7c:	29 c3                	sub    %eax,%ebx
  7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  81:	89 04 24             	mov    %eax,(%esp)
  84:	e8 56 03 00 00       	call   3df <strlen>
  89:	05 b8 0e 00 00       	add    $0xeb8,%eax
  8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  92:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  99:	00 
  9a:	89 04 24             	mov    %eax,(%esp)
  9d:	e8 62 03 00 00       	call   404 <memset>
  return buf;
  a2:	b8 b8 0e 00 00       	mov    $0xeb8,%eax
}
  a7:	83 c4 24             	add    $0x24,%esp
  aa:	5b                   	pop    %ebx
  ab:	5d                   	pop    %ebp
  ac:	c3                   	ret    

000000ad <ls>:

void
ls(char *path)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  b0:	57                   	push   %edi
  b1:	56                   	push   %esi
  b2:	53                   	push   %ebx
  b3:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c0:	00 
  c1:	8b 45 08             	mov    0x8(%ebp),%eax
  c4:	89 04 24             	mov    %eax,(%esp)
  c7:	e8 1c 05 00 00       	call   5e8 <open>
  cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d3:	79 20                	jns    f5 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d5:	8b 45 08             	mov    0x8(%ebp),%eax
  d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  dc:	c7 44 24 04 bb 0b 00 	movl   $0xbbb,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  eb:	e8 05 07 00 00       	call   7f5 <printf>
    return;
  f0:	e9 fd 01 00 00       	jmp    2f2 <ls+0x245>
  }

  if(fstat(fd, &st) < 0){
  f5:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 f6 04 00 00       	call   600 <fstat>
 10a:	85 c0                	test   %eax,%eax
 10c:	79 2b                	jns    139 <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 10e:	8b 45 08             	mov    0x8(%ebp),%eax
 111:	89 44 24 08          	mov    %eax,0x8(%esp)
 115:	c7 44 24 04 cf 0b 00 	movl   $0xbcf,0x4(%esp)
 11c:	00 
 11d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 124:	e8 cc 06 00 00       	call   7f5 <printf>
    close(fd);
 129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12c:	89 04 24             	mov    %eax,(%esp)
 12f:	e8 9c 04 00 00       	call   5d0 <close>
    return;
 134:	e9 b9 01 00 00       	jmp    2f2 <ls+0x245>
  }

  switch(st.type){
 139:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
 13f:	98                   	cwtl   
 140:	83 f8 01             	cmp    $0x1,%eax
 143:	74 52                	je     197 <ls+0xea>
 145:	83 f8 02             	cmp    $0x2,%eax
 148:	0f 85 99 01 00 00    	jne    2e7 <ls+0x23a>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 14e:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 154:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15a:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
 160:	0f bf d8             	movswl %ax,%ebx
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	89 04 24             	mov    %eax,(%esp)
 169:	e8 92 fe ff ff       	call   0 <fmtname>
 16e:	89 7c 24 14          	mov    %edi,0x14(%esp)
 172:	89 74 24 10          	mov    %esi,0x10(%esp)
 176:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17a:	89 44 24 08          	mov    %eax,0x8(%esp)
 17e:	c7 44 24 04 e3 0b 00 	movl   $0xbe3,0x4(%esp)
 185:	00 
 186:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18d:	e8 63 06 00 00       	call   7f5 <printf>
    break;
 192:	e9 50 01 00 00       	jmp    2e7 <ls+0x23a>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 197:	8b 45 08             	mov    0x8(%ebp),%eax
 19a:	89 04 24             	mov    %eax,(%esp)
 19d:	e8 3d 02 00 00       	call   3df <strlen>
 1a2:	83 c0 10             	add    $0x10,%eax
 1a5:	3d 00 02 00 00       	cmp    $0x200,%eax
 1aa:	76 19                	jbe    1c5 <ls+0x118>
      printf(1, "ls: path too long\n");
 1ac:	c7 44 24 04 f0 0b 00 	movl   $0xbf0,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 35 06 00 00       	call   7f5 <printf>
      break;
 1c0:	e9 22 01 00 00       	jmp    2e7 <ls+0x23a>
    }
    strcpy(buf, path);
 1c5:	8b 45 08             	mov    0x8(%ebp),%eax
 1c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cc:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d2:	89 04 24             	mov    %eax,(%esp)
 1d5:	e8 9f 01 00 00       	call   379 <strcpy>
    p = buf+strlen(buf);
 1da:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e0:	89 04 24             	mov    %eax,(%esp)
 1e3:	e8 f7 01 00 00       	call   3df <strlen>
 1e8:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1ee:	01 d0                	add    %edx,%eax
 1f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f6:	8d 50 01             	lea    0x1(%eax),%edx
 1f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1fc:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ff:	e9 bc 00 00 00       	jmp    2c0 <ls+0x213>
      if(de.inum == 0)
 204:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
 20a:	66 85 c0             	test   %ax,%ax
 20d:	75 05                	jne    214 <ls+0x167>
        continue;
 20f:	e9 ac 00 00 00       	jmp    2c0 <ls+0x213>
      memmove(p, de.name, DIRSIZ);
 214:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 21b:	00 
 21c:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 222:	83 c0 02             	add    $0x2,%eax
 225:	89 44 24 04          	mov    %eax,0x4(%esp)
 229:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22c:	89 04 24             	mov    %eax,(%esp)
 22f:	e8 2d 03 00 00       	call   561 <memmove>
      p[DIRSIZ] = 0;
 234:	8b 45 e0             	mov    -0x20(%ebp),%eax
 237:	83 c0 0e             	add    $0xe,%eax
 23a:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 23d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 243:	89 44 24 04          	mov    %eax,0x4(%esp)
 247:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 24d:	89 04 24             	mov    %eax,(%esp)
 250:	e8 74 02 00 00       	call   4c9 <stat>
 255:	85 c0                	test   %eax,%eax
 257:	79 20                	jns    279 <ls+0x1cc>
        printf(1, "ls: cannot stat %s\n", buf);
 259:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 25f:	89 44 24 08          	mov    %eax,0x8(%esp)
 263:	c7 44 24 04 cf 0b 00 	movl   $0xbcf,0x4(%esp)
 26a:	00 
 26b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 272:	e8 7e 05 00 00       	call   7f5 <printf>
        continue;
 277:	eb 47                	jmp    2c0 <ls+0x213>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 279:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 27f:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 285:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
 28b:	0f bf d8             	movswl %ax,%ebx
 28e:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 294:	89 04 24             	mov    %eax,(%esp)
 297:	e8 64 fd ff ff       	call   0 <fmtname>
 29c:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a0:	89 74 24 10          	mov    %esi,0x10(%esp)
 2a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2a8:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ac:	c7 44 24 04 e3 0b 00 	movl   $0xbe3,0x4(%esp)
 2b3:	00 
 2b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bb:	e8 35 05 00 00       	call   7f5 <printf>
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2c7:	00 
 2c8:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2d5:	89 04 24             	mov    %eax,(%esp)
 2d8:	e8 e3 02 00 00       	call   5c0 <read>
 2dd:	83 f8 10             	cmp    $0x10,%eax
 2e0:	0f 84 1e ff ff ff    	je     204 <ls+0x157>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2e6:	90                   	nop
  }
  close(fd);
 2e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ea:	89 04 24             	mov    %eax,(%esp)
 2ed:	e8 de 02 00 00       	call   5d0 <close>
}
 2f2:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2f8:	5b                   	pop    %ebx
 2f9:	5e                   	pop    %esi
 2fa:	5f                   	pop    %edi
 2fb:	5d                   	pop    %ebp
 2fc:	c3                   	ret    

000002fd <main>:

int
main(int argc, char *argv[])
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 e4 f0             	and    $0xfffffff0,%esp
 303:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 306:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 30a:	7f 11                	jg     31d <main+0x20>
    ls(".");
 30c:	c7 04 24 03 0c 00 00 	movl   $0xc03,(%esp)
 313:	e8 95 fd ff ff       	call   ad <ls>
    exit();
 318:	e8 8b 02 00 00       	call   5a8 <exit>
  }
  for(i=1; i<argc; i++)
 31d:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 324:	00 
 325:	eb 1e                	jmp    345 <main+0x48>
    ls(argv[i]);
 327:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 32b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 332:	8b 45 0c             	mov    0xc(%ebp),%eax
 335:	01 d0                	add    %edx,%eax
 337:	8b 00                	mov    (%eax),%eax
 339:	89 04 24             	mov    %eax,(%esp)
 33c:	e8 6c fd ff ff       	call   ad <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 341:	ff 44 24 1c          	incl   0x1c(%esp)
 345:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 349:	3b 45 08             	cmp    0x8(%ebp),%eax
 34c:	7c d9                	jl     327 <main+0x2a>
    ls(argv[i]);
  exit();
 34e:	e8 55 02 00 00       	call   5a8 <exit>
 353:	90                   	nop

00000354 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	57                   	push   %edi
 358:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 359:	8b 4d 08             	mov    0x8(%ebp),%ecx
 35c:	8b 55 10             	mov    0x10(%ebp),%edx
 35f:	8b 45 0c             	mov    0xc(%ebp),%eax
 362:	89 cb                	mov    %ecx,%ebx
 364:	89 df                	mov    %ebx,%edi
 366:	89 d1                	mov    %edx,%ecx
 368:	fc                   	cld    
 369:	f3 aa                	rep stos %al,%es:(%edi)
 36b:	89 ca                	mov    %ecx,%edx
 36d:	89 fb                	mov    %edi,%ebx
 36f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 372:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 375:	5b                   	pop    %ebx
 376:	5f                   	pop    %edi
 377:	5d                   	pop    %ebp
 378:	c3                   	ret    

00000379 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 379:	55                   	push   %ebp
 37a:	89 e5                	mov    %esp,%ebp
 37c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 385:	90                   	nop
 386:	8b 45 08             	mov    0x8(%ebp),%eax
 389:	8d 50 01             	lea    0x1(%eax),%edx
 38c:	89 55 08             	mov    %edx,0x8(%ebp)
 38f:	8b 55 0c             	mov    0xc(%ebp),%edx
 392:	8d 4a 01             	lea    0x1(%edx),%ecx
 395:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 398:	8a 12                	mov    (%edx),%dl
 39a:	88 10                	mov    %dl,(%eax)
 39c:	8a 00                	mov    (%eax),%al
 39e:	84 c0                	test   %al,%al
 3a0:	75 e4                	jne    386 <strcpy+0xd>
    ;
  return os;
 3a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3aa:	eb 06                	jmp    3b2 <strcmp+0xb>
    p++, q++;
 3ac:	ff 45 08             	incl   0x8(%ebp)
 3af:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3b2:	8b 45 08             	mov    0x8(%ebp),%eax
 3b5:	8a 00                	mov    (%eax),%al
 3b7:	84 c0                	test   %al,%al
 3b9:	74 0e                	je     3c9 <strcmp+0x22>
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	8a 10                	mov    (%eax),%dl
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	8a 00                	mov    (%eax),%al
 3c5:	38 c2                	cmp    %al,%dl
 3c7:	74 e3                	je     3ac <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	8a 00                	mov    (%eax),%al
 3ce:	0f b6 d0             	movzbl %al,%edx
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	8a 00                	mov    (%eax),%al
 3d6:	0f b6 c0             	movzbl %al,%eax
 3d9:	29 c2                	sub    %eax,%edx
 3db:	89 d0                	mov    %edx,%eax
}
 3dd:	5d                   	pop    %ebp
 3de:	c3                   	ret    

000003df <strlen>:

uint
strlen(char *s)
{
 3df:	55                   	push   %ebp
 3e0:	89 e5                	mov    %esp,%ebp
 3e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ec:	eb 03                	jmp    3f1 <strlen+0x12>
 3ee:	ff 45 fc             	incl   -0x4(%ebp)
 3f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f4:	8b 45 08             	mov    0x8(%ebp),%eax
 3f7:	01 d0                	add    %edx,%eax
 3f9:	8a 00                	mov    (%eax),%al
 3fb:	84 c0                	test   %al,%al
 3fd:	75 ef                	jne    3ee <strlen+0xf>
    ;
  return n;
 3ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 402:	c9                   	leave  
 403:	c3                   	ret    

00000404 <memset>:

void*
memset(void *dst, int c, uint n)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
 407:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 40a:	8b 45 10             	mov    0x10(%ebp),%eax
 40d:	89 44 24 08          	mov    %eax,0x8(%esp)
 411:	8b 45 0c             	mov    0xc(%ebp),%eax
 414:	89 44 24 04          	mov    %eax,0x4(%esp)
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	89 04 24             	mov    %eax,(%esp)
 41e:	e8 31 ff ff ff       	call   354 <stosb>
  return dst;
 423:	8b 45 08             	mov    0x8(%ebp),%eax
}
 426:	c9                   	leave  
 427:	c3                   	ret    

00000428 <strchr>:

char*
strchr(const char *s, char c)
{
 428:	55                   	push   %ebp
 429:	89 e5                	mov    %esp,%ebp
 42b:	83 ec 04             	sub    $0x4,%esp
 42e:	8b 45 0c             	mov    0xc(%ebp),%eax
 431:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 434:	eb 12                	jmp    448 <strchr+0x20>
    if(*s == c)
 436:	8b 45 08             	mov    0x8(%ebp),%eax
 439:	8a 00                	mov    (%eax),%al
 43b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 43e:	75 05                	jne    445 <strchr+0x1d>
      return (char*)s;
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	eb 11                	jmp    456 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 445:	ff 45 08             	incl   0x8(%ebp)
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	8a 00                	mov    (%eax),%al
 44d:	84 c0                	test   %al,%al
 44f:	75 e5                	jne    436 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 451:	b8 00 00 00 00       	mov    $0x0,%eax
}
 456:	c9                   	leave  
 457:	c3                   	ret    

00000458 <gets>:

char*
gets(char *buf, int max)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 45e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 465:	eb 49                	jmp    4b0 <gets+0x58>
    cc = read(0, &c, 1);
 467:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 46e:	00 
 46f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 472:	89 44 24 04          	mov    %eax,0x4(%esp)
 476:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 47d:	e8 3e 01 00 00       	call   5c0 <read>
 482:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 485:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 489:	7f 02                	jg     48d <gets+0x35>
      break;
 48b:	eb 2c                	jmp    4b9 <gets+0x61>
    buf[i++] = c;
 48d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 490:	8d 50 01             	lea    0x1(%eax),%edx
 493:	89 55 f4             	mov    %edx,-0xc(%ebp)
 496:	89 c2                	mov    %eax,%edx
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	01 c2                	add    %eax,%edx
 49d:	8a 45 ef             	mov    -0x11(%ebp),%al
 4a0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4a2:	8a 45 ef             	mov    -0x11(%ebp),%al
 4a5:	3c 0a                	cmp    $0xa,%al
 4a7:	74 10                	je     4b9 <gets+0x61>
 4a9:	8a 45 ef             	mov    -0x11(%ebp),%al
 4ac:	3c 0d                	cmp    $0xd,%al
 4ae:	74 09                	je     4b9 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b3:	40                   	inc    %eax
 4b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4b7:	7c ae                	jl     467 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	01 d0                	add    %edx,%eax
 4c1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4c7:	c9                   	leave  
 4c8:	c3                   	ret    

000004c9 <stat>:

int
stat(char *n, struct stat *st)
{
 4c9:	55                   	push   %ebp
 4ca:	89 e5                	mov    %esp,%ebp
 4cc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4d6:	00 
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	89 04 24             	mov    %eax,(%esp)
 4dd:	e8 06 01 00 00       	call   5e8 <open>
 4e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e9:	79 07                	jns    4f2 <stat+0x29>
    return -1;
 4eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4f0:	eb 23                	jmp    515 <stat+0x4c>
  r = fstat(fd, st);
 4f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fc:	89 04 24             	mov    %eax,(%esp)
 4ff:	e8 fc 00 00 00       	call   600 <fstat>
 504:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 507:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50a:	89 04 24             	mov    %eax,(%esp)
 50d:	e8 be 00 00 00       	call   5d0 <close>
  return r;
 512:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 515:	c9                   	leave  
 516:	c3                   	ret    

00000517 <atoi>:

int
atoi(const char *s)
{
 517:	55                   	push   %ebp
 518:	89 e5                	mov    %esp,%ebp
 51a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 51d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 524:	eb 24                	jmp    54a <atoi+0x33>
    n = n*10 + *s++ - '0';
 526:	8b 55 fc             	mov    -0x4(%ebp),%edx
 529:	89 d0                	mov    %edx,%eax
 52b:	c1 e0 02             	shl    $0x2,%eax
 52e:	01 d0                	add    %edx,%eax
 530:	01 c0                	add    %eax,%eax
 532:	89 c1                	mov    %eax,%ecx
 534:	8b 45 08             	mov    0x8(%ebp),%eax
 537:	8d 50 01             	lea    0x1(%eax),%edx
 53a:	89 55 08             	mov    %edx,0x8(%ebp)
 53d:	8a 00                	mov    (%eax),%al
 53f:	0f be c0             	movsbl %al,%eax
 542:	01 c8                	add    %ecx,%eax
 544:	83 e8 30             	sub    $0x30,%eax
 547:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 54a:	8b 45 08             	mov    0x8(%ebp),%eax
 54d:	8a 00                	mov    (%eax),%al
 54f:	3c 2f                	cmp    $0x2f,%al
 551:	7e 09                	jle    55c <atoi+0x45>
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	8a 00                	mov    (%eax),%al
 558:	3c 39                	cmp    $0x39,%al
 55a:	7e ca                	jle    526 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 55c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 55f:	c9                   	leave  
 560:	c3                   	ret    

00000561 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 561:	55                   	push   %ebp
 562:	89 e5                	mov    %esp,%ebp
 564:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 56d:	8b 45 0c             	mov    0xc(%ebp),%eax
 570:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 573:	eb 16                	jmp    58b <memmove+0x2a>
    *dst++ = *src++;
 575:	8b 45 fc             	mov    -0x4(%ebp),%eax
 578:	8d 50 01             	lea    0x1(%eax),%edx
 57b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 57e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 581:	8d 4a 01             	lea    0x1(%edx),%ecx
 584:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 587:	8a 12                	mov    (%edx),%dl
 589:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 58b:	8b 45 10             	mov    0x10(%ebp),%eax
 58e:	8d 50 ff             	lea    -0x1(%eax),%edx
 591:	89 55 10             	mov    %edx,0x10(%ebp)
 594:	85 c0                	test   %eax,%eax
 596:	7f dd                	jg     575 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 598:	8b 45 08             	mov    0x8(%ebp),%eax
}
 59b:	c9                   	leave  
 59c:	c3                   	ret    
 59d:	90                   	nop
 59e:	90                   	nop
 59f:	90                   	nop

000005a0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5a0:	b8 01 00 00 00       	mov    $0x1,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <exit>:
SYSCALL(exit)
 5a8:	b8 02 00 00 00       	mov    $0x2,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <wait>:
SYSCALL(wait)
 5b0:	b8 03 00 00 00       	mov    $0x3,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <pipe>:
SYSCALL(pipe)
 5b8:	b8 04 00 00 00       	mov    $0x4,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <read>:
SYSCALL(read)
 5c0:	b8 05 00 00 00       	mov    $0x5,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <write>:
SYSCALL(write)
 5c8:	b8 10 00 00 00       	mov    $0x10,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <close>:
SYSCALL(close)
 5d0:	b8 15 00 00 00       	mov    $0x15,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <kill>:
SYSCALL(kill)
 5d8:	b8 06 00 00 00       	mov    $0x6,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <exec>:
SYSCALL(exec)
 5e0:	b8 07 00 00 00       	mov    $0x7,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <open>:
SYSCALL(open)
 5e8:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <mknod>:
SYSCALL(mknod)
 5f0:	b8 11 00 00 00       	mov    $0x11,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <unlink>:
SYSCALL(unlink)
 5f8:	b8 12 00 00 00       	mov    $0x12,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <fstat>:
SYSCALL(fstat)
 600:	b8 08 00 00 00       	mov    $0x8,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <link>:
SYSCALL(link)
 608:	b8 13 00 00 00       	mov    $0x13,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <mkdir>:
SYSCALL(mkdir)
 610:	b8 14 00 00 00       	mov    $0x14,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <chdir>:
SYSCALL(chdir)
 618:	b8 09 00 00 00       	mov    $0x9,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <dup>:
SYSCALL(dup)
 620:	b8 0a 00 00 00       	mov    $0xa,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <getpid>:
SYSCALL(getpid)
 628:	b8 0b 00 00 00       	mov    $0xb,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <sbrk>:
SYSCALL(sbrk)
 630:	b8 0c 00 00 00       	mov    $0xc,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <sleep>:
SYSCALL(sleep)
 638:	b8 0d 00 00 00       	mov    $0xd,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <uptime>:
SYSCALL(uptime)
 640:	b8 0e 00 00 00       	mov    $0xe,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <getticks>:
SYSCALL(getticks)
 648:	b8 16 00 00 00       	mov    $0x16,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <get_name>:
SYSCALL(get_name)
 650:	b8 17 00 00 00       	mov    $0x17,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <get_max_proc>:
SYSCALL(get_max_proc)
 658:	b8 18 00 00 00       	mov    $0x18,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <get_max_mem>:
SYSCALL(get_max_mem)
 660:	b8 19 00 00 00       	mov    $0x19,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <get_max_disk>:
SYSCALL(get_max_disk)
 668:	b8 1a 00 00 00       	mov    $0x1a,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <get_curr_proc>:
SYSCALL(get_curr_proc)
 670:	b8 1b 00 00 00       	mov    $0x1b,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <get_curr_mem>:
SYSCALL(get_curr_mem)
 678:	b8 1c 00 00 00       	mov    $0x1c,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <get_curr_disk>:
SYSCALL(get_curr_disk)
 680:	b8 1d 00 00 00       	mov    $0x1d,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <set_name>:
SYSCALL(set_name)
 688:	b8 1e 00 00 00       	mov    $0x1e,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <set_max_mem>:
SYSCALL(set_max_mem)
 690:	b8 1f 00 00 00       	mov    $0x1f,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <set_max_disk>:
SYSCALL(set_max_disk)
 698:	b8 20 00 00 00       	mov    $0x20,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <set_max_proc>:
SYSCALL(set_max_proc)
 6a0:	b8 21 00 00 00       	mov    $0x21,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <set_curr_mem>:
SYSCALL(set_curr_mem)
 6a8:	b8 22 00 00 00       	mov    $0x22,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <set_curr_disk>:
SYSCALL(set_curr_disk)
 6b0:	b8 23 00 00 00       	mov    $0x23,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <set_curr_proc>:
SYSCALL(set_curr_proc)
 6b8:	b8 24 00 00 00       	mov    $0x24,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <find>:
SYSCALL(find)
 6c0:	b8 25 00 00 00       	mov    $0x25,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <is_full>:
SYSCALL(is_full)
 6c8:	b8 26 00 00 00       	mov    $0x26,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <container_init>:
SYSCALL(container_init)
 6d0:	b8 27 00 00 00       	mov    $0x27,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <cont_proc_set>:
SYSCALL(cont_proc_set)
 6d8:	b8 28 00 00 00       	mov    $0x28,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <ps>:
SYSCALL(ps)
 6e0:	b8 29 00 00 00       	mov    $0x29,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 6e8:	b8 2a 00 00 00       	mov    $0x2a,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <set_root_inode>:
SYSCALL(set_root_inode)
 6f0:	b8 2b 00 00 00       	mov    $0x2b,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <cstop>:
SYSCALL(cstop)
 6f8:	b8 2c 00 00 00       	mov    $0x2c,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <df>:
SYSCALL(df)
 700:	b8 2d 00 00 00       	mov    $0x2d,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <max_containers>:
SYSCALL(max_containers)
 708:	b8 2e 00 00 00       	mov    $0x2e,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <container_reset>:
SYSCALL(container_reset)
 710:	b8 2f 00 00 00       	mov    $0x2f,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 718:	55                   	push   %ebp
 719:	89 e5                	mov    %esp,%ebp
 71b:	83 ec 18             	sub    $0x18,%esp
 71e:	8b 45 0c             	mov    0xc(%ebp),%eax
 721:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 724:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 72b:	00 
 72c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 72f:	89 44 24 04          	mov    %eax,0x4(%esp)
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 8a fe ff ff       	call   5c8 <write>
}
 73e:	c9                   	leave  
 73f:	c3                   	ret    

00000740 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 740:	55                   	push   %ebp
 741:	89 e5                	mov    %esp,%ebp
 743:	56                   	push   %esi
 744:	53                   	push   %ebx
 745:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 748:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 74f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 753:	74 17                	je     76c <printint+0x2c>
 755:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 759:	79 11                	jns    76c <printint+0x2c>
    neg = 1;
 75b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 762:	8b 45 0c             	mov    0xc(%ebp),%eax
 765:	f7 d8                	neg    %eax
 767:	89 45 ec             	mov    %eax,-0x14(%ebp)
 76a:	eb 06                	jmp    772 <printint+0x32>
  } else {
    x = xx;
 76c:	8b 45 0c             	mov    0xc(%ebp),%eax
 76f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 779:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 77c:	8d 41 01             	lea    0x1(%ecx),%eax
 77f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 782:	8b 5d 10             	mov    0x10(%ebp),%ebx
 785:	8b 45 ec             	mov    -0x14(%ebp),%eax
 788:	ba 00 00 00 00       	mov    $0x0,%edx
 78d:	f7 f3                	div    %ebx
 78f:	89 d0                	mov    %edx,%eax
 791:	8a 80 a4 0e 00 00    	mov    0xea4(%eax),%al
 797:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 79b:	8b 75 10             	mov    0x10(%ebp),%esi
 79e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7a1:	ba 00 00 00 00       	mov    $0x0,%edx
 7a6:	f7 f6                	div    %esi
 7a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7af:	75 c8                	jne    779 <printint+0x39>
  if(neg)
 7b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b5:	74 10                	je     7c7 <printint+0x87>
    buf[i++] = '-';
 7b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ba:	8d 50 01             	lea    0x1(%eax),%edx
 7bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7c0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7c5:	eb 1e                	jmp    7e5 <printint+0xa5>
 7c7:	eb 1c                	jmp    7e5 <printint+0xa5>
    putc(fd, buf[i]);
 7c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	01 d0                	add    %edx,%eax
 7d1:	8a 00                	mov    (%eax),%al
 7d3:	0f be c0             	movsbl %al,%eax
 7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7da:	8b 45 08             	mov    0x8(%ebp),%eax
 7dd:	89 04 24             	mov    %eax,(%esp)
 7e0:	e8 33 ff ff ff       	call   718 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7e5:	ff 4d f4             	decl   -0xc(%ebp)
 7e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ec:	79 db                	jns    7c9 <printint+0x89>
    putc(fd, buf[i]);
}
 7ee:	83 c4 30             	add    $0x30,%esp
 7f1:	5b                   	pop    %ebx
 7f2:	5e                   	pop    %esi
 7f3:	5d                   	pop    %ebp
 7f4:	c3                   	ret    

000007f5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7f5:	55                   	push   %ebp
 7f6:	89 e5                	mov    %esp,%ebp
 7f8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 802:	8d 45 0c             	lea    0xc(%ebp),%eax
 805:	83 c0 04             	add    $0x4,%eax
 808:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 80b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 812:	e9 77 01 00 00       	jmp    98e <printf+0x199>
    c = fmt[i] & 0xff;
 817:	8b 55 0c             	mov    0xc(%ebp),%edx
 81a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81d:	01 d0                	add    %edx,%eax
 81f:	8a 00                	mov    (%eax),%al
 821:	0f be c0             	movsbl %al,%eax
 824:	25 ff 00 00 00       	and    $0xff,%eax
 829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 82c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 830:	75 2c                	jne    85e <printf+0x69>
      if(c == '%'){
 832:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 836:	75 0c                	jne    844 <printf+0x4f>
        state = '%';
 838:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 83f:	e9 47 01 00 00       	jmp    98b <printf+0x196>
      } else {
        putc(fd, c);
 844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 847:	0f be c0             	movsbl %al,%eax
 84a:	89 44 24 04          	mov    %eax,0x4(%esp)
 84e:	8b 45 08             	mov    0x8(%ebp),%eax
 851:	89 04 24             	mov    %eax,(%esp)
 854:	e8 bf fe ff ff       	call   718 <putc>
 859:	e9 2d 01 00 00       	jmp    98b <printf+0x196>
      }
    } else if(state == '%'){
 85e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 862:	0f 85 23 01 00 00    	jne    98b <printf+0x196>
      if(c == 'd'){
 868:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 86c:	75 2d                	jne    89b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 86e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 871:	8b 00                	mov    (%eax),%eax
 873:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 87a:	00 
 87b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 882:	00 
 883:	89 44 24 04          	mov    %eax,0x4(%esp)
 887:	8b 45 08             	mov    0x8(%ebp),%eax
 88a:	89 04 24             	mov    %eax,(%esp)
 88d:	e8 ae fe ff ff       	call   740 <printint>
        ap++;
 892:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 896:	e9 e9 00 00 00       	jmp    984 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 89b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 89f:	74 06                	je     8a7 <printf+0xb2>
 8a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8a5:	75 2d                	jne    8d4 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 8a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8aa:	8b 00                	mov    (%eax),%eax
 8ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 8b3:	00 
 8b4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8bb:	00 
 8bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c0:	8b 45 08             	mov    0x8(%ebp),%eax
 8c3:	89 04 24             	mov    %eax,(%esp)
 8c6:	e8 75 fe ff ff       	call   740 <printint>
        ap++;
 8cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8cf:	e9 b0 00 00 00       	jmp    984 <printf+0x18f>
      } else if(c == 's'){
 8d4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8d8:	75 42                	jne    91c <printf+0x127>
        s = (char*)*ap;
 8da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8dd:	8b 00                	mov    (%eax),%eax
 8df:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ea:	75 09                	jne    8f5 <printf+0x100>
          s = "(null)";
 8ec:	c7 45 f4 05 0c 00 00 	movl   $0xc05,-0xc(%ebp)
        while(*s != 0){
 8f3:	eb 1c                	jmp    911 <printf+0x11c>
 8f5:	eb 1a                	jmp    911 <printf+0x11c>
          putc(fd, *s);
 8f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fa:	8a 00                	mov    (%eax),%al
 8fc:	0f be c0             	movsbl %al,%eax
 8ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 903:	8b 45 08             	mov    0x8(%ebp),%eax
 906:	89 04 24             	mov    %eax,(%esp)
 909:	e8 0a fe ff ff       	call   718 <putc>
          s++;
 90e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8a 00                	mov    (%eax),%al
 916:	84 c0                	test   %al,%al
 918:	75 dd                	jne    8f7 <printf+0x102>
 91a:	eb 68                	jmp    984 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 91c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 920:	75 1d                	jne    93f <printf+0x14a>
        putc(fd, *ap);
 922:	8b 45 e8             	mov    -0x18(%ebp),%eax
 925:	8b 00                	mov    (%eax),%eax
 927:	0f be c0             	movsbl %al,%eax
 92a:	89 44 24 04          	mov    %eax,0x4(%esp)
 92e:	8b 45 08             	mov    0x8(%ebp),%eax
 931:	89 04 24             	mov    %eax,(%esp)
 934:	e8 df fd ff ff       	call   718 <putc>
        ap++;
 939:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 93d:	eb 45                	jmp    984 <printf+0x18f>
      } else if(c == '%'){
 93f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 943:	75 17                	jne    95c <printf+0x167>
        putc(fd, c);
 945:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 948:	0f be c0             	movsbl %al,%eax
 94b:	89 44 24 04          	mov    %eax,0x4(%esp)
 94f:	8b 45 08             	mov    0x8(%ebp),%eax
 952:	89 04 24             	mov    %eax,(%esp)
 955:	e8 be fd ff ff       	call   718 <putc>
 95a:	eb 28                	jmp    984 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 95c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 963:	00 
 964:	8b 45 08             	mov    0x8(%ebp),%eax
 967:	89 04 24             	mov    %eax,(%esp)
 96a:	e8 a9 fd ff ff       	call   718 <putc>
        putc(fd, c);
 96f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 972:	0f be c0             	movsbl %al,%eax
 975:	89 44 24 04          	mov    %eax,0x4(%esp)
 979:	8b 45 08             	mov    0x8(%ebp),%eax
 97c:	89 04 24             	mov    %eax,(%esp)
 97f:	e8 94 fd ff ff       	call   718 <putc>
      }
      state = 0;
 984:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 98b:	ff 45 f0             	incl   -0x10(%ebp)
 98e:	8b 55 0c             	mov    0xc(%ebp),%edx
 991:	8b 45 f0             	mov    -0x10(%ebp),%eax
 994:	01 d0                	add    %edx,%eax
 996:	8a 00                	mov    (%eax),%al
 998:	84 c0                	test   %al,%al
 99a:	0f 85 77 fe ff ff    	jne    817 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 9a0:	c9                   	leave  
 9a1:	c3                   	ret    
 9a2:	90                   	nop
 9a3:	90                   	nop

000009a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9a4:	55                   	push   %ebp
 9a5:	89 e5                	mov    %esp,%ebp
 9a7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9aa:	8b 45 08             	mov    0x8(%ebp),%eax
 9ad:	83 e8 08             	sub    $0x8,%eax
 9b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b3:	a1 d0 0e 00 00       	mov    0xed0,%eax
 9b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9bb:	eb 24                	jmp    9e1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c0:	8b 00                	mov    (%eax),%eax
 9c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c5:	77 12                	ja     9d9 <free+0x35>
 9c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9cd:	77 24                	ja     9f3 <free+0x4f>
 9cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d2:	8b 00                	mov    (%eax),%eax
 9d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9d7:	77 1a                	ja     9f3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9dc:	8b 00                	mov    (%eax),%eax
 9de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e7:	76 d4                	jbe    9bd <free+0x19>
 9e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ec:	8b 00                	mov    (%eax),%eax
 9ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9f1:	76 ca                	jbe    9bd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 9f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f6:	8b 40 04             	mov    0x4(%eax),%eax
 9f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a00:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a03:	01 c2                	add    %eax,%edx
 a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a08:	8b 00                	mov    (%eax),%eax
 a0a:	39 c2                	cmp    %eax,%edx
 a0c:	75 24                	jne    a32 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a11:	8b 50 04             	mov    0x4(%eax),%edx
 a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a17:	8b 00                	mov    (%eax),%eax
 a19:	8b 40 04             	mov    0x4(%eax),%eax
 a1c:	01 c2                	add    %eax,%edx
 a1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a21:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a27:	8b 00                	mov    (%eax),%eax
 a29:	8b 10                	mov    (%eax),%edx
 a2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a2e:	89 10                	mov    %edx,(%eax)
 a30:	eb 0a                	jmp    a3c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a35:	8b 10                	mov    (%eax),%edx
 a37:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a3a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3f:	8b 40 04             	mov    0x4(%eax),%eax
 a42:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4c:	01 d0                	add    %edx,%eax
 a4e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a51:	75 20                	jne    a73 <free+0xcf>
    p->s.size += bp->s.size;
 a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a56:	8b 50 04             	mov    0x4(%eax),%edx
 a59:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5c:	8b 40 04             	mov    0x4(%eax),%eax
 a5f:	01 c2                	add    %eax,%edx
 a61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a64:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a67:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a6a:	8b 10                	mov    (%eax),%edx
 a6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6f:	89 10                	mov    %edx,(%eax)
 a71:	eb 08                	jmp    a7b <free+0xd7>
  } else
    p->s.ptr = bp;
 a73:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a76:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a79:	89 10                	mov    %edx,(%eax)
  freep = p;
 a7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a7e:	a3 d0 0e 00 00       	mov    %eax,0xed0
}
 a83:	c9                   	leave  
 a84:	c3                   	ret    

00000a85 <morecore>:

static Header*
morecore(uint nu)
{
 a85:	55                   	push   %ebp
 a86:	89 e5                	mov    %esp,%ebp
 a88:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a8b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a92:	77 07                	ja     a9b <morecore+0x16>
    nu = 4096;
 a94:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a9b:	8b 45 08             	mov    0x8(%ebp),%eax
 a9e:	c1 e0 03             	shl    $0x3,%eax
 aa1:	89 04 24             	mov    %eax,(%esp)
 aa4:	e8 87 fb ff ff       	call   630 <sbrk>
 aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 aac:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ab0:	75 07                	jne    ab9 <morecore+0x34>
    return 0;
 ab2:	b8 00 00 00 00       	mov    $0x0,%eax
 ab7:	eb 22                	jmp    adb <morecore+0x56>
  hp = (Header*)p;
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac2:	8b 55 08             	mov    0x8(%ebp),%edx
 ac5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acb:	83 c0 08             	add    $0x8,%eax
 ace:	89 04 24             	mov    %eax,(%esp)
 ad1:	e8 ce fe ff ff       	call   9a4 <free>
  return freep;
 ad6:	a1 d0 0e 00 00       	mov    0xed0,%eax
}
 adb:	c9                   	leave  
 adc:	c3                   	ret    

00000add <malloc>:

void*
malloc(uint nbytes)
{
 add:	55                   	push   %ebp
 ade:	89 e5                	mov    %esp,%ebp
 ae0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ae3:	8b 45 08             	mov    0x8(%ebp),%eax
 ae6:	83 c0 07             	add    $0x7,%eax
 ae9:	c1 e8 03             	shr    $0x3,%eax
 aec:	40                   	inc    %eax
 aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 af0:	a1 d0 0e 00 00       	mov    0xed0,%eax
 af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 afc:	75 23                	jne    b21 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 afe:	c7 45 f0 c8 0e 00 00 	movl   $0xec8,-0x10(%ebp)
 b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b08:	a3 d0 0e 00 00       	mov    %eax,0xed0
 b0d:	a1 d0 0e 00 00       	mov    0xed0,%eax
 b12:	a3 c8 0e 00 00       	mov    %eax,0xec8
    base.s.size = 0;
 b17:	c7 05 cc 0e 00 00 00 	movl   $0x0,0xecc
 b1e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b24:	8b 00                	mov    (%eax),%eax
 b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2c:	8b 40 04             	mov    0x4(%eax),%eax
 b2f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b32:	72 4d                	jb     b81 <malloc+0xa4>
      if(p->s.size == nunits)
 b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b37:	8b 40 04             	mov    0x4(%eax),%eax
 b3a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b3d:	75 0c                	jne    b4b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b42:	8b 10                	mov    (%eax),%edx
 b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b47:	89 10                	mov    %edx,(%eax)
 b49:	eb 26                	jmp    b71 <malloc+0x94>
      else {
        p->s.size -= nunits;
 b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4e:	8b 40 04             	mov    0x4(%eax),%eax
 b51:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b54:	89 c2                	mov    %eax,%edx
 b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b59:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5f:	8b 40 04             	mov    0x4(%eax),%eax
 b62:	c1 e0 03             	shl    $0x3,%eax
 b65:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b6e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b74:	a3 d0 0e 00 00       	mov    %eax,0xed0
      return (void*)(p + 1);
 b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b7c:	83 c0 08             	add    $0x8,%eax
 b7f:	eb 38                	jmp    bb9 <malloc+0xdc>
    }
    if(p == freep)
 b81:	a1 d0 0e 00 00       	mov    0xed0,%eax
 b86:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b89:	75 1b                	jne    ba6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 b8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b8e:	89 04 24             	mov    %eax,(%esp)
 b91:	e8 ef fe ff ff       	call   a85 <morecore>
 b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b9d:	75 07                	jne    ba6 <malloc+0xc9>
        return 0;
 b9f:	b8 00 00 00 00       	mov    $0x0,%eax
 ba4:	eb 13                	jmp    bb9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 baf:	8b 00                	mov    (%eax),%eax
 bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 bb4:	e9 70 ff ff ff       	jmp    b29 <malloc+0x4c>
}
 bb9:	c9                   	leave  
 bba:	c3                   	ret    
