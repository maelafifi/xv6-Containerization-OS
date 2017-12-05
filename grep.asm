
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;

  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
   d:	e9 c2 00 00 00       	jmp    d4 <grep+0xd4>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    buf[m] = '\0';
  18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1b:	05 40 10 00 00       	add    $0x1040,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 40 10 00 00 	movl   $0x1040,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  2a:	eb 4d                	jmp    79 <grep+0x79>
      *q = 0;
  2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  2f:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  35:	89 44 24 04          	mov    %eax,0x4(%esp)
  39:	8b 45 08             	mov    0x8(%ebp),%eax
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 b7 01 00 00       	call   1fb <match>
  44:	85 c0                	test   %eax,%eax
  46:	74 2a                	je     72 <grep+0x72>
        *q = '\n';
  48:	8b 45 e8             	mov    -0x18(%ebp),%eax
  4b:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  51:	40                   	inc    %eax
  52:	89 c2                	mov    %eax,%edx
  54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  57:	29 c2                	sub    %eax,%edx
  59:	89 d0                	mov    %edx,%eax
  5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  62:	89 44 24 04          	mov    %eax,0x4(%esp)
  66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6d:	e8 2e 06 00 00       	call   6a0 <write>
      }
      p = q+1;
  72:	8b 45 e8             	mov    -0x18(%ebp),%eax
  75:	40                   	inc    %eax
  76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
    m += n;
    buf[m] = '\0';
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  79:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80:	00 
  81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  84:	89 04 24             	mov    %eax,(%esp)
  87:	e8 90 03 00 00       	call   41c <strchr>
  8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  93:	75 97                	jne    2c <grep+0x2c>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  95:	81 7d f0 40 10 00 00 	cmpl   $0x1040,-0x10(%ebp)
  9c:	75 07                	jne    a5 <grep+0xa5>
      m = 0;
  9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a9:	7e 29                	jle    d4 <grep+0xd4>
      m -= p - buf;
  ab:	ba 40 10 00 00       	mov    $0x1040,%edx
  b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b3:	29 c2                	sub    %eax,%edx
  b5:	89 d0                	mov    %edx,%eax
  b7:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  c8:	c7 04 24 40 10 00 00 	movl   $0x1040,(%esp)
  cf:	e8 81 04 00 00       	call   555 <memmove>
{
  int n, m;
  char *p, *q;

  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
  d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d7:	ba ff 03 00 00       	mov    $0x3ff,%edx
  dc:	29 c2                	sub    %eax,%edx
  de:	89 d0                	mov    %edx,%eax
  e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  e3:	81 c2 40 10 00 00    	add    $0x1040,%edx
  e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  f4:	89 04 24             	mov    %eax,(%esp)
  f7:	e8 9c 05 00 00       	call   698 <read>
  fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 103:	0f 8f 09 ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 109:	c9                   	leave  
 10a:	c3                   	ret    

0000010b <main>:

int
main(int argc, char *argv[])
{
 10b:	55                   	push   %ebp
 10c:	89 e5                	mov    %esp,%ebp
 10e:	83 e4 f0             	and    $0xfffffff0,%esp
 111:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;

  if(argc <= 1){
 114:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 118:	7f 19                	jg     133 <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 11a:	c7 44 24 04 d4 0c 00 	movl   $0xcd4,0x4(%esp)
 121:	00 
 122:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 129:	e8 df 07 00 00       	call   90d <printf>
    exit();
 12e:	e8 4d 05 00 00       	call   680 <exit>
  }
  pattern = argv[1];
 133:	8b 45 0c             	mov    0xc(%ebp),%eax
 136:	8b 40 04             	mov    0x4(%eax),%eax
 139:	89 44 24 18          	mov    %eax,0x18(%esp)

  if(argc <= 2){
 13d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 141:	7f 19                	jg     15c <main+0x51>
    grep(pattern, 0);
 143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 14a:	00 
 14b:	8b 44 24 18          	mov    0x18(%esp),%eax
 14f:	89 04 24             	mov    %eax,(%esp)
 152:	e8 a9 fe ff ff       	call   0 <grep>
    exit();
 157:	e8 24 05 00 00       	call   680 <exit>
  }

  for(i = 2; i < argc; i++){
 15c:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 163:	00 
 164:	e9 80 00 00 00       	jmp    1e9 <main+0xde>
    if((fd = open(argv[i], 0)) < 0){
 169:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 16d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 174:	8b 45 0c             	mov    0xc(%ebp),%eax
 177:	01 d0                	add    %edx,%eax
 179:	8b 00                	mov    (%eax),%eax
 17b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 182:	00 
 183:	89 04 24             	mov    %eax,(%esp)
 186:	e8 35 05 00 00       	call   6c0 <open>
 18b:	89 44 24 14          	mov    %eax,0x14(%esp)
 18f:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 194:	79 2f                	jns    1c5 <main+0xba>
      printf(1, "grep: cannot open %s\n", argv[i]);
 196:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 19a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a4:	01 d0                	add    %edx,%eax
 1a6:	8b 00                	mov    (%eax),%eax
 1a8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ac:	c7 44 24 04 f4 0c 00 	movl   $0xcf4,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 4d 07 00 00       	call   90d <printf>
      exit();
 1c0:	e8 bb 04 00 00       	call   680 <exit>
    }
    grep(pattern, fd);
 1c5:	8b 44 24 14          	mov    0x14(%esp),%eax
 1c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cd:	8b 44 24 18          	mov    0x18(%esp),%eax
 1d1:	89 04 24             	mov    %eax,(%esp)
 1d4:	e8 27 fe ff ff       	call   0 <grep>
    close(fd);
 1d9:	8b 44 24 14          	mov    0x14(%esp),%eax
 1dd:	89 04 24             	mov    %eax,(%esp)
 1e0:	e8 c3 04 00 00       	call   6a8 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1e5:	ff 44 24 1c          	incl   0x1c(%esp)
 1e9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1ed:	3b 45 08             	cmp    0x8(%ebp),%eax
 1f0:	0f 8c 73 ff ff ff    	jl     169 <main+0x5e>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1f6:	e8 85 04 00 00       	call   680 <exit>

000001fb <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	8a 00                	mov    (%eax),%al
 206:	3c 5e                	cmp    $0x5e,%al
 208:	75 17                	jne    221 <match+0x26>
    return matchhere(re+1, text);
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	8d 50 01             	lea    0x1(%eax),%edx
 210:	8b 45 0c             	mov    0xc(%ebp),%eax
 213:	89 44 24 04          	mov    %eax,0x4(%esp)
 217:	89 14 24             	mov    %edx,(%esp)
 21a:	e8 35 00 00 00       	call   254 <matchhere>
 21f:	eb 31                	jmp    252 <match+0x57>
  do{  // must look at empty string
    if(matchhere(re, text))
 221:	8b 45 0c             	mov    0xc(%ebp),%eax
 224:	89 44 24 04          	mov    %eax,0x4(%esp)
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	89 04 24             	mov    %eax,(%esp)
 22e:	e8 21 00 00 00       	call   254 <matchhere>
 233:	85 c0                	test   %eax,%eax
 235:	74 07                	je     23e <match+0x43>
      return 1;
 237:	b8 01 00 00 00       	mov    $0x1,%eax
 23c:	eb 14                	jmp    252 <match+0x57>
  }while(*text++ != '\0');
 23e:	8b 45 0c             	mov    0xc(%ebp),%eax
 241:	8d 50 01             	lea    0x1(%eax),%edx
 244:	89 55 0c             	mov    %edx,0xc(%ebp)
 247:	8a 00                	mov    (%eax),%al
 249:	84 c0                	test   %al,%al
 24b:	75 d4                	jne    221 <match+0x26>
  return 0;
 24d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 252:	c9                   	leave  
 253:	c3                   	ret    

00000254 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 254:	55                   	push   %ebp
 255:	89 e5                	mov    %esp,%ebp
 257:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	8a 00                	mov    (%eax),%al
 25f:	84 c0                	test   %al,%al
 261:	75 0a                	jne    26d <matchhere+0x19>
    return 1;
 263:	b8 01 00 00 00       	mov    $0x1,%eax
 268:	e9 8c 00 00 00       	jmp    2f9 <matchhere+0xa5>
  if(re[1] == '*')
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	40                   	inc    %eax
 271:	8a 00                	mov    (%eax),%al
 273:	3c 2a                	cmp    $0x2a,%al
 275:	75 23                	jne    29a <matchhere+0x46>
    return matchstar(re[0], re+2, text);
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	8d 48 02             	lea    0x2(%eax),%ecx
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	8a 00                	mov    (%eax),%al
 282:	0f be c0             	movsbl %al,%eax
 285:	8b 55 0c             	mov    0xc(%ebp),%edx
 288:	89 54 24 08          	mov    %edx,0x8(%esp)
 28c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 290:	89 04 24             	mov    %eax,(%esp)
 293:	e8 63 00 00 00       	call   2fb <matchstar>
 298:	eb 5f                	jmp    2f9 <matchhere+0xa5>
  if(re[0] == '$' && re[1] == '\0')
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	8a 00                	mov    (%eax),%al
 29f:	3c 24                	cmp    $0x24,%al
 2a1:	75 19                	jne    2bc <matchhere+0x68>
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	40                   	inc    %eax
 2a7:	8a 00                	mov    (%eax),%al
 2a9:	84 c0                	test   %al,%al
 2ab:	75 0f                	jne    2bc <matchhere+0x68>
    return *text == '\0';
 2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b0:	8a 00                	mov    (%eax),%al
 2b2:	84 c0                	test   %al,%al
 2b4:	0f 94 c0             	sete   %al
 2b7:	0f b6 c0             	movzbl %al,%eax
 2ba:	eb 3d                	jmp    2f9 <matchhere+0xa5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bf:	8a 00                	mov    (%eax),%al
 2c1:	84 c0                	test   %al,%al
 2c3:	74 2f                	je     2f4 <matchhere+0xa0>
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	8a 00                	mov    (%eax),%al
 2ca:	3c 2e                	cmp    $0x2e,%al
 2cc:	74 0e                	je     2dc <matchhere+0x88>
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	8a 10                	mov    (%eax),%dl
 2d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d6:	8a 00                	mov    (%eax),%al
 2d8:	38 c2                	cmp    %al,%dl
 2da:	75 18                	jne    2f4 <matchhere+0xa0>
    return matchhere(re+1, text+1);
 2dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2df:	8d 50 01             	lea    0x1(%eax),%edx
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	40                   	inc    %eax
 2e6:	89 54 24 04          	mov    %edx,0x4(%esp)
 2ea:	89 04 24             	mov    %eax,(%esp)
 2ed:	e8 62 ff ff ff       	call   254 <matchhere>
 2f2:	eb 05                	jmp    2f9 <matchhere+0xa5>
  return 0;
 2f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2f9:	c9                   	leave  
 2fa:	c3                   	ret    

000002fb <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 2fb:	55                   	push   %ebp
 2fc:	89 e5                	mov    %esp,%ebp
 2fe:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 301:	8b 45 10             	mov    0x10(%ebp),%eax
 304:	89 44 24 04          	mov    %eax,0x4(%esp)
 308:	8b 45 0c             	mov    0xc(%ebp),%eax
 30b:	89 04 24             	mov    %eax,(%esp)
 30e:	e8 41 ff ff ff       	call   254 <matchhere>
 313:	85 c0                	test   %eax,%eax
 315:	74 07                	je     31e <matchstar+0x23>
      return 1;
 317:	b8 01 00 00 00       	mov    $0x1,%eax
 31c:	eb 27                	jmp    345 <matchstar+0x4a>
  }while(*text!='\0' && (*text++==c || c=='.'));
 31e:	8b 45 10             	mov    0x10(%ebp),%eax
 321:	8a 00                	mov    (%eax),%al
 323:	84 c0                	test   %al,%al
 325:	74 19                	je     340 <matchstar+0x45>
 327:	8b 45 10             	mov    0x10(%ebp),%eax
 32a:	8d 50 01             	lea    0x1(%eax),%edx
 32d:	89 55 10             	mov    %edx,0x10(%ebp)
 330:	8a 00                	mov    (%eax),%al
 332:	0f be c0             	movsbl %al,%eax
 335:	3b 45 08             	cmp    0x8(%ebp),%eax
 338:	74 c7                	je     301 <matchstar+0x6>
 33a:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 33e:	74 c1                	je     301 <matchstar+0x6>
  return 0;
 340:	b8 00 00 00 00       	mov    $0x0,%eax
}
 345:	c9                   	leave  
 346:	c3                   	ret    
 347:	90                   	nop

00000348 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	57                   	push   %edi
 34c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 34d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 350:	8b 55 10             	mov    0x10(%ebp),%edx
 353:	8b 45 0c             	mov    0xc(%ebp),%eax
 356:	89 cb                	mov    %ecx,%ebx
 358:	89 df                	mov    %ebx,%edi
 35a:	89 d1                	mov    %edx,%ecx
 35c:	fc                   	cld    
 35d:	f3 aa                	rep stos %al,%es:(%edi)
 35f:	89 ca                	mov    %ecx,%edx
 361:	89 fb                	mov    %edi,%ebx
 363:	89 5d 08             	mov    %ebx,0x8(%ebp)
 366:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 369:	5b                   	pop    %ebx
 36a:	5f                   	pop    %edi
 36b:	5d                   	pop    %ebp
 36c:	c3                   	ret    

0000036d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
 370:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 379:	90                   	nop
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
 37d:	8d 50 01             	lea    0x1(%eax),%edx
 380:	89 55 08             	mov    %edx,0x8(%ebp)
 383:	8b 55 0c             	mov    0xc(%ebp),%edx
 386:	8d 4a 01             	lea    0x1(%edx),%ecx
 389:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 38c:	8a 12                	mov    (%edx),%dl
 38e:	88 10                	mov    %dl,(%eax)
 390:	8a 00                	mov    (%eax),%al
 392:	84 c0                	test   %al,%al
 394:	75 e4                	jne    37a <strcpy+0xd>
    ;
  return os;
 396:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 39e:	eb 06                	jmp    3a6 <strcmp+0xb>
    p++, q++;
 3a0:	ff 45 08             	incl   0x8(%ebp)
 3a3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	8a 00                	mov    (%eax),%al
 3ab:	84 c0                	test   %al,%al
 3ad:	74 0e                	je     3bd <strcmp+0x22>
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	8a 10                	mov    (%eax),%dl
 3b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b7:	8a 00                	mov    (%eax),%al
 3b9:	38 c2                	cmp    %al,%dl
 3bb:	74 e3                	je     3a0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	8a 00                	mov    (%eax),%al
 3c2:	0f b6 d0             	movzbl %al,%edx
 3c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c8:	8a 00                	mov    (%eax),%al
 3ca:	0f b6 c0             	movzbl %al,%eax
 3cd:	29 c2                	sub    %eax,%edx
 3cf:	89 d0                	mov    %edx,%eax
}
 3d1:	5d                   	pop    %ebp
 3d2:	c3                   	ret    

000003d3 <strlen>:

uint
strlen(char *s)
{
 3d3:	55                   	push   %ebp
 3d4:	89 e5                	mov    %esp,%ebp
 3d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3e0:	eb 03                	jmp    3e5 <strlen+0x12>
 3e2:	ff 45 fc             	incl   -0x4(%ebp)
 3e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
 3eb:	01 d0                	add    %edx,%eax
 3ed:	8a 00                	mov    (%eax),%al
 3ef:	84 c0                	test   %al,%al
 3f1:	75 ef                	jne    3e2 <strlen+0xf>
    ;
  return n;
 3f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f6:	c9                   	leave  
 3f7:	c3                   	ret    

000003f8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3fe:	8b 45 10             	mov    0x10(%ebp),%eax
 401:	89 44 24 08          	mov    %eax,0x8(%esp)
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	89 44 24 04          	mov    %eax,0x4(%esp)
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	89 04 24             	mov    %eax,(%esp)
 412:	e8 31 ff ff ff       	call   348 <stosb>
  return dst;
 417:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41a:	c9                   	leave  
 41b:	c3                   	ret    

0000041c <strchr>:

char*
strchr(const char *s, char c)
{
 41c:	55                   	push   %ebp
 41d:	89 e5                	mov    %esp,%ebp
 41f:	83 ec 04             	sub    $0x4,%esp
 422:	8b 45 0c             	mov    0xc(%ebp),%eax
 425:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 428:	eb 12                	jmp    43c <strchr+0x20>
    if(*s == c)
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	8a 00                	mov    (%eax),%al
 42f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 432:	75 05                	jne    439 <strchr+0x1d>
      return (char*)s;
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	eb 11                	jmp    44a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 439:	ff 45 08             	incl   0x8(%ebp)
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	8a 00                	mov    (%eax),%al
 441:	84 c0                	test   %al,%al
 443:	75 e5                	jne    42a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 445:	b8 00 00 00 00       	mov    $0x0,%eax
}
 44a:	c9                   	leave  
 44b:	c3                   	ret    

0000044c <gets>:

char*
gets(char *buf, int max)
{
 44c:	55                   	push   %ebp
 44d:	89 e5                	mov    %esp,%ebp
 44f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 452:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 459:	eb 49                	jmp    4a4 <gets+0x58>
    cc = read(0, &c, 1);
 45b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 462:	00 
 463:	8d 45 ef             	lea    -0x11(%ebp),%eax
 466:	89 44 24 04          	mov    %eax,0x4(%esp)
 46a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 471:	e8 22 02 00 00       	call   698 <read>
 476:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 479:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47d:	7f 02                	jg     481 <gets+0x35>
      break;
 47f:	eb 2c                	jmp    4ad <gets+0x61>
    buf[i++] = c;
 481:	8b 45 f4             	mov    -0xc(%ebp),%eax
 484:	8d 50 01             	lea    0x1(%eax),%edx
 487:	89 55 f4             	mov    %edx,-0xc(%ebp)
 48a:	89 c2                	mov    %eax,%edx
 48c:	8b 45 08             	mov    0x8(%ebp),%eax
 48f:	01 c2                	add    %eax,%edx
 491:	8a 45 ef             	mov    -0x11(%ebp),%al
 494:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 496:	8a 45 ef             	mov    -0x11(%ebp),%al
 499:	3c 0a                	cmp    $0xa,%al
 49b:	74 10                	je     4ad <gets+0x61>
 49d:	8a 45 ef             	mov    -0x11(%ebp),%al
 4a0:	3c 0d                	cmp    $0xd,%al
 4a2:	74 09                	je     4ad <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a7:	40                   	inc    %eax
 4a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4ab:	7c ae                	jl     45b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4b0:	8b 45 08             	mov    0x8(%ebp),%eax
 4b3:	01 d0                	add    %edx,%eax
 4b5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4bb:	c9                   	leave  
 4bc:	c3                   	ret    

000004bd <stat>:

int
stat(char *n, struct stat *st)
{
 4bd:	55                   	push   %ebp
 4be:	89 e5                	mov    %esp,%ebp
 4c0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4ca:	00 
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ce:	89 04 24             	mov    %eax,(%esp)
 4d1:	e8 ea 01 00 00       	call   6c0 <open>
 4d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4dd:	79 07                	jns    4e6 <stat+0x29>
    return -1;
 4df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4e4:	eb 23                	jmp    509 <stat+0x4c>
  r = fstat(fd, st);
 4e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f0:	89 04 24             	mov    %eax,(%esp)
 4f3:	e8 e0 01 00 00       	call   6d8 <fstat>
 4f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fe:	89 04 24             	mov    %eax,(%esp)
 501:	e8 a2 01 00 00       	call   6a8 <close>
  return r;
 506:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 509:	c9                   	leave  
 50a:	c3                   	ret    

0000050b <atoi>:

int
atoi(const char *s)
{
 50b:	55                   	push   %ebp
 50c:	89 e5                	mov    %esp,%ebp
 50e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 511:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 518:	eb 24                	jmp    53e <atoi+0x33>
    n = n*10 + *s++ - '0';
 51a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 51d:	89 d0                	mov    %edx,%eax
 51f:	c1 e0 02             	shl    $0x2,%eax
 522:	01 d0                	add    %edx,%eax
 524:	01 c0                	add    %eax,%eax
 526:	89 c1                	mov    %eax,%ecx
 528:	8b 45 08             	mov    0x8(%ebp),%eax
 52b:	8d 50 01             	lea    0x1(%eax),%edx
 52e:	89 55 08             	mov    %edx,0x8(%ebp)
 531:	8a 00                	mov    (%eax),%al
 533:	0f be c0             	movsbl %al,%eax
 536:	01 c8                	add    %ecx,%eax
 538:	83 e8 30             	sub    $0x30,%eax
 53b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 53e:	8b 45 08             	mov    0x8(%ebp),%eax
 541:	8a 00                	mov    (%eax),%al
 543:	3c 2f                	cmp    $0x2f,%al
 545:	7e 09                	jle    550 <atoi+0x45>
 547:	8b 45 08             	mov    0x8(%ebp),%eax
 54a:	8a 00                	mov    (%eax),%al
 54c:	3c 39                	cmp    $0x39,%al
 54e:	7e ca                	jle    51a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 550:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 553:	c9                   	leave  
 554:	c3                   	ret    

00000555 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 555:	55                   	push   %ebp
 556:	89 e5                	mov    %esp,%ebp
 558:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 55b:	8b 45 08             	mov    0x8(%ebp),%eax
 55e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 561:	8b 45 0c             	mov    0xc(%ebp),%eax
 564:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 567:	eb 16                	jmp    57f <memmove+0x2a>
    *dst++ = *src++;
 569:	8b 45 fc             	mov    -0x4(%ebp),%eax
 56c:	8d 50 01             	lea    0x1(%eax),%edx
 56f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 572:	8b 55 f8             	mov    -0x8(%ebp),%edx
 575:	8d 4a 01             	lea    0x1(%edx),%ecx
 578:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 57b:	8a 12                	mov    (%edx),%dl
 57d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 57f:	8b 45 10             	mov    0x10(%ebp),%eax
 582:	8d 50 ff             	lea    -0x1(%eax),%edx
 585:	89 55 10             	mov    %edx,0x10(%ebp)
 588:	85 c0                	test   %eax,%eax
 58a:	7f dd                	jg     569 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 58f:	c9                   	leave  
 590:	c3                   	ret    

00000591 <itoa>:

int itoa(int value, char *sp, int radix)
{
 591:	55                   	push   %ebp
 592:	89 e5                	mov    %esp,%ebp
 594:	53                   	push   %ebx
 595:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 598:	8d 45 d8             	lea    -0x28(%ebp),%eax
 59b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 59e:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 5a2:	75 0d                	jne    5b1 <itoa+0x20>
 5a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 5a8:	79 07                	jns    5b1 <itoa+0x20>
 5aa:	b8 01 00 00 00       	mov    $0x1,%eax
 5af:	eb 05                	jmp    5b6 <itoa+0x25>
 5b1:	b8 00 00 00 00       	mov    $0x0,%eax
 5b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 5b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5bd:	74 0a                	je     5c9 <itoa+0x38>
      v = -value;
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	f7 d8                	neg    %eax
 5c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 5c7:	eb 54                	jmp    61d <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 5c9:	8b 45 08             	mov    0x8(%ebp),%eax
 5cc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 5cf:	eb 4c                	jmp    61d <itoa+0x8c>
  {
    i = v % radix;
 5d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d7:	ba 00 00 00 00       	mov    $0x0,%edx
 5dc:	f7 f1                	div    %ecx
 5de:	89 d0                	mov    %edx,%eax
 5e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 5e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e9:	ba 00 00 00 00       	mov    $0x0,%edx
 5ee:	f7 f3                	div    %ebx
 5f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 5f3:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 5f7:	7f 13                	jg     60c <itoa+0x7b>
      *tp++ = i+'0';
 5f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fc:	8d 50 01             	lea    0x1(%eax),%edx
 5ff:	89 55 f8             	mov    %edx,-0x8(%ebp)
 602:	8b 55 e8             	mov    -0x18(%ebp),%edx
 605:	83 c2 30             	add    $0x30,%edx
 608:	88 10                	mov    %dl,(%eax)
 60a:	eb 11                	jmp    61d <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 60c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60f:	8d 50 01             	lea    0x1(%eax),%edx
 612:	89 55 f8             	mov    %edx,-0x8(%ebp)
 615:	8b 55 e8             	mov    -0x18(%ebp),%edx
 618:	83 c2 57             	add    $0x57,%edx
 61b:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 61d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 621:	75 ae                	jne    5d1 <itoa+0x40>
 623:	8d 45 d8             	lea    -0x28(%ebp),%eax
 626:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 629:	74 a6                	je     5d1 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 62b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 62e:	8d 45 d8             	lea    -0x28(%ebp),%eax
 631:	29 c2                	sub    %eax,%edx
 633:	89 d0                	mov    %edx,%eax
 635:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 638:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63c:	74 11                	je     64f <itoa+0xbe>
  {
    *sp++ = '-';
 63e:	8b 45 0c             	mov    0xc(%ebp),%eax
 641:	8d 50 01             	lea    0x1(%eax),%edx
 644:	89 55 0c             	mov    %edx,0xc(%ebp)
 647:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 64a:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 64d:	eb 15                	jmp    664 <itoa+0xd3>
 64f:	eb 13                	jmp    664 <itoa+0xd3>
    *sp++ = *--tp;
 651:	8b 45 0c             	mov    0xc(%ebp),%eax
 654:	8d 50 01             	lea    0x1(%eax),%edx
 657:	89 55 0c             	mov    %edx,0xc(%ebp)
 65a:	ff 4d f8             	decl   -0x8(%ebp)
 65d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 660:	8a 12                	mov    (%edx),%dl
 662:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 664:	8d 45 d8             	lea    -0x28(%ebp),%eax
 667:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 66a:	77 e5                	ja     651 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 66c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 66f:	83 c4 30             	add    $0x30,%esp
 672:	5b                   	pop    %ebx
 673:	5d                   	pop    %ebp
 674:	c3                   	ret    
 675:	90                   	nop
 676:	90                   	nop
 677:	90                   	nop

00000678 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 678:	b8 01 00 00 00       	mov    $0x1,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <exit>:
SYSCALL(exit)
 680:	b8 02 00 00 00       	mov    $0x2,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <wait>:
SYSCALL(wait)
 688:	b8 03 00 00 00       	mov    $0x3,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <pipe>:
SYSCALL(pipe)
 690:	b8 04 00 00 00       	mov    $0x4,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <read>:
SYSCALL(read)
 698:	b8 05 00 00 00       	mov    $0x5,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <write>:
SYSCALL(write)
 6a0:	b8 10 00 00 00       	mov    $0x10,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <close>:
SYSCALL(close)
 6a8:	b8 15 00 00 00       	mov    $0x15,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <kill>:
SYSCALL(kill)
 6b0:	b8 06 00 00 00       	mov    $0x6,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <exec>:
SYSCALL(exec)
 6b8:	b8 07 00 00 00       	mov    $0x7,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <open>:
SYSCALL(open)
 6c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <mknod>:
SYSCALL(mknod)
 6c8:	b8 11 00 00 00       	mov    $0x11,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <unlink>:
SYSCALL(unlink)
 6d0:	b8 12 00 00 00       	mov    $0x12,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <fstat>:
SYSCALL(fstat)
 6d8:	b8 08 00 00 00       	mov    $0x8,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <link>:
SYSCALL(link)
 6e0:	b8 13 00 00 00       	mov    $0x13,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <mkdir>:
SYSCALL(mkdir)
 6e8:	b8 14 00 00 00       	mov    $0x14,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <chdir>:
SYSCALL(chdir)
 6f0:	b8 09 00 00 00       	mov    $0x9,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <dup>:
SYSCALL(dup)
 6f8:	b8 0a 00 00 00       	mov    $0xa,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <getpid>:
SYSCALL(getpid)
 700:	b8 0b 00 00 00       	mov    $0xb,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <sbrk>:
SYSCALL(sbrk)
 708:	b8 0c 00 00 00       	mov    $0xc,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <sleep>:
SYSCALL(sleep)
 710:	b8 0d 00 00 00       	mov    $0xd,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <uptime>:
SYSCALL(uptime)
 718:	b8 0e 00 00 00       	mov    $0xe,%eax
 71d:	cd 40                	int    $0x40
 71f:	c3                   	ret    

00000720 <getticks>:
SYSCALL(getticks)
 720:	b8 16 00 00 00       	mov    $0x16,%eax
 725:	cd 40                	int    $0x40
 727:	c3                   	ret    

00000728 <get_name>:
SYSCALL(get_name)
 728:	b8 17 00 00 00       	mov    $0x17,%eax
 72d:	cd 40                	int    $0x40
 72f:	c3                   	ret    

00000730 <get_max_proc>:
SYSCALL(get_max_proc)
 730:	b8 18 00 00 00       	mov    $0x18,%eax
 735:	cd 40                	int    $0x40
 737:	c3                   	ret    

00000738 <get_max_mem>:
SYSCALL(get_max_mem)
 738:	b8 19 00 00 00       	mov    $0x19,%eax
 73d:	cd 40                	int    $0x40
 73f:	c3                   	ret    

00000740 <get_max_disk>:
SYSCALL(get_max_disk)
 740:	b8 1a 00 00 00       	mov    $0x1a,%eax
 745:	cd 40                	int    $0x40
 747:	c3                   	ret    

00000748 <get_curr_proc>:
SYSCALL(get_curr_proc)
 748:	b8 1b 00 00 00       	mov    $0x1b,%eax
 74d:	cd 40                	int    $0x40
 74f:	c3                   	ret    

00000750 <get_curr_mem>:
SYSCALL(get_curr_mem)
 750:	b8 1c 00 00 00       	mov    $0x1c,%eax
 755:	cd 40                	int    $0x40
 757:	c3                   	ret    

00000758 <get_curr_disk>:
SYSCALL(get_curr_disk)
 758:	b8 1d 00 00 00       	mov    $0x1d,%eax
 75d:	cd 40                	int    $0x40
 75f:	c3                   	ret    

00000760 <set_name>:
SYSCALL(set_name)
 760:	b8 1e 00 00 00       	mov    $0x1e,%eax
 765:	cd 40                	int    $0x40
 767:	c3                   	ret    

00000768 <set_max_mem>:
SYSCALL(set_max_mem)
 768:	b8 1f 00 00 00       	mov    $0x1f,%eax
 76d:	cd 40                	int    $0x40
 76f:	c3                   	ret    

00000770 <set_max_disk>:
SYSCALL(set_max_disk)
 770:	b8 20 00 00 00       	mov    $0x20,%eax
 775:	cd 40                	int    $0x40
 777:	c3                   	ret    

00000778 <set_max_proc>:
SYSCALL(set_max_proc)
 778:	b8 21 00 00 00       	mov    $0x21,%eax
 77d:	cd 40                	int    $0x40
 77f:	c3                   	ret    

00000780 <set_curr_mem>:
SYSCALL(set_curr_mem)
 780:	b8 22 00 00 00       	mov    $0x22,%eax
 785:	cd 40                	int    $0x40
 787:	c3                   	ret    

00000788 <set_curr_disk>:
SYSCALL(set_curr_disk)
 788:	b8 23 00 00 00       	mov    $0x23,%eax
 78d:	cd 40                	int    $0x40
 78f:	c3                   	ret    

00000790 <set_curr_proc>:
SYSCALL(set_curr_proc)
 790:	b8 24 00 00 00       	mov    $0x24,%eax
 795:	cd 40                	int    $0x40
 797:	c3                   	ret    

00000798 <find>:
SYSCALL(find)
 798:	b8 25 00 00 00       	mov    $0x25,%eax
 79d:	cd 40                	int    $0x40
 79f:	c3                   	ret    

000007a0 <is_full>:
SYSCALL(is_full)
 7a0:	b8 26 00 00 00       	mov    $0x26,%eax
 7a5:	cd 40                	int    $0x40
 7a7:	c3                   	ret    

000007a8 <container_init>:
SYSCALL(container_init)
 7a8:	b8 27 00 00 00       	mov    $0x27,%eax
 7ad:	cd 40                	int    $0x40
 7af:	c3                   	ret    

000007b0 <cont_proc_set>:
SYSCALL(cont_proc_set)
 7b0:	b8 28 00 00 00       	mov    $0x28,%eax
 7b5:	cd 40                	int    $0x40
 7b7:	c3                   	ret    

000007b8 <ps>:
SYSCALL(ps)
 7b8:	b8 29 00 00 00       	mov    $0x29,%eax
 7bd:	cd 40                	int    $0x40
 7bf:	c3                   	ret    

000007c0 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 7c0:	b8 2a 00 00 00       	mov    $0x2a,%eax
 7c5:	cd 40                	int    $0x40
 7c7:	c3                   	ret    

000007c8 <set_root_inode>:
SYSCALL(set_root_inode)
 7c8:	b8 2b 00 00 00       	mov    $0x2b,%eax
 7cd:	cd 40                	int    $0x40
 7cf:	c3                   	ret    

000007d0 <cstop>:
SYSCALL(cstop)
 7d0:	b8 2c 00 00 00       	mov    $0x2c,%eax
 7d5:	cd 40                	int    $0x40
 7d7:	c3                   	ret    

000007d8 <df>:
SYSCALL(df)
 7d8:	b8 2d 00 00 00       	mov    $0x2d,%eax
 7dd:	cd 40                	int    $0x40
 7df:	c3                   	ret    

000007e0 <max_containers>:
SYSCALL(max_containers)
 7e0:	b8 2e 00 00 00       	mov    $0x2e,%eax
 7e5:	cd 40                	int    $0x40
 7e7:	c3                   	ret    

000007e8 <container_reset>:
SYSCALL(container_reset)
 7e8:	b8 2f 00 00 00       	mov    $0x2f,%eax
 7ed:	cd 40                	int    $0x40
 7ef:	c3                   	ret    

000007f0 <pause>:
SYSCALL(pause)
 7f0:	b8 30 00 00 00       	mov    $0x30,%eax
 7f5:	cd 40                	int    $0x40
 7f7:	c3                   	ret    

000007f8 <resume>:
SYSCALL(resume)
 7f8:	b8 31 00 00 00       	mov    $0x31,%eax
 7fd:	cd 40                	int    $0x40
 7ff:	c3                   	ret    

00000800 <tmem>:
SYSCALL(tmem)
 800:	b8 32 00 00 00       	mov    $0x32,%eax
 805:	cd 40                	int    $0x40
 807:	c3                   	ret    

00000808 <amem>:
SYSCALL(amem)
 808:	b8 33 00 00 00       	mov    $0x33,%eax
 80d:	cd 40                	int    $0x40
 80f:	c3                   	ret    

00000810 <c_ps>:
SYSCALL(c_ps)
 810:	b8 34 00 00 00       	mov    $0x34,%eax
 815:	cd 40                	int    $0x40
 817:	c3                   	ret    

00000818 <get_used>:
SYSCALL(get_used)
 818:	b8 35 00 00 00       	mov    $0x35,%eax
 81d:	cd 40                	int    $0x40
 81f:	c3                   	ret    

00000820 <get_os>:
SYSCALL(get_os)
 820:	b8 36 00 00 00       	mov    $0x36,%eax
 825:	cd 40                	int    $0x40
 827:	c3                   	ret    

00000828 <set_os>:
SYSCALL(set_os)
 828:	b8 37 00 00 00       	mov    $0x37,%eax
 82d:	cd 40                	int    $0x40
 82f:	c3                   	ret    

00000830 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 830:	55                   	push   %ebp
 831:	89 e5                	mov    %esp,%ebp
 833:	83 ec 18             	sub    $0x18,%esp
 836:	8b 45 0c             	mov    0xc(%ebp),%eax
 839:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 83c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 843:	00 
 844:	8d 45 f4             	lea    -0xc(%ebp),%eax
 847:	89 44 24 04          	mov    %eax,0x4(%esp)
 84b:	8b 45 08             	mov    0x8(%ebp),%eax
 84e:	89 04 24             	mov    %eax,(%esp)
 851:	e8 4a fe ff ff       	call   6a0 <write>
}
 856:	c9                   	leave  
 857:	c3                   	ret    

00000858 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 858:	55                   	push   %ebp
 859:	89 e5                	mov    %esp,%ebp
 85b:	56                   	push   %esi
 85c:	53                   	push   %ebx
 85d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 860:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 867:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 86b:	74 17                	je     884 <printint+0x2c>
 86d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 871:	79 11                	jns    884 <printint+0x2c>
    neg = 1;
 873:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 87a:	8b 45 0c             	mov    0xc(%ebp),%eax
 87d:	f7 d8                	neg    %eax
 87f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 882:	eb 06                	jmp    88a <printint+0x32>
  } else {
    x = xx;
 884:	8b 45 0c             	mov    0xc(%ebp),%eax
 887:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 88a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 891:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 894:	8d 41 01             	lea    0x1(%ecx),%eax
 897:	89 45 f4             	mov    %eax,-0xc(%ebp)
 89a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 89d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a0:	ba 00 00 00 00       	mov    $0x0,%edx
 8a5:	f7 f3                	div    %ebx
 8a7:	89 d0                	mov    %edx,%eax
 8a9:	8a 80 fc 0f 00 00    	mov    0xffc(%eax),%al
 8af:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 8b3:	8b 75 10             	mov    0x10(%ebp),%esi
 8b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8b9:	ba 00 00 00 00       	mov    $0x0,%edx
 8be:	f7 f6                	div    %esi
 8c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8c7:	75 c8                	jne    891 <printint+0x39>
  if(neg)
 8c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8cd:	74 10                	je     8df <printint+0x87>
    buf[i++] = '-';
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	8d 50 01             	lea    0x1(%eax),%edx
 8d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8d8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8dd:	eb 1e                	jmp    8fd <printint+0xa5>
 8df:	eb 1c                	jmp    8fd <printint+0xa5>
    putc(fd, buf[i]);
 8e1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	01 d0                	add    %edx,%eax
 8e9:	8a 00                	mov    (%eax),%al
 8eb:	0f be c0             	movsbl %al,%eax
 8ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f2:	8b 45 08             	mov    0x8(%ebp),%eax
 8f5:	89 04 24             	mov    %eax,(%esp)
 8f8:	e8 33 ff ff ff       	call   830 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8fd:	ff 4d f4             	decl   -0xc(%ebp)
 900:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 904:	79 db                	jns    8e1 <printint+0x89>
    putc(fd, buf[i]);
}
 906:	83 c4 30             	add    $0x30,%esp
 909:	5b                   	pop    %ebx
 90a:	5e                   	pop    %esi
 90b:	5d                   	pop    %ebp
 90c:	c3                   	ret    

0000090d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 90d:	55                   	push   %ebp
 90e:	89 e5                	mov    %esp,%ebp
 910:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 913:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 91a:	8d 45 0c             	lea    0xc(%ebp),%eax
 91d:	83 c0 04             	add    $0x4,%eax
 920:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 923:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 92a:	e9 77 01 00 00       	jmp    aa6 <printf+0x199>
    c = fmt[i] & 0xff;
 92f:	8b 55 0c             	mov    0xc(%ebp),%edx
 932:	8b 45 f0             	mov    -0x10(%ebp),%eax
 935:	01 d0                	add    %edx,%eax
 937:	8a 00                	mov    (%eax),%al
 939:	0f be c0             	movsbl %al,%eax
 93c:	25 ff 00 00 00       	and    $0xff,%eax
 941:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 944:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 948:	75 2c                	jne    976 <printf+0x69>
      if(c == '%'){
 94a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 94e:	75 0c                	jne    95c <printf+0x4f>
        state = '%';
 950:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 957:	e9 47 01 00 00       	jmp    aa3 <printf+0x196>
      } else {
        putc(fd, c);
 95c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 95f:	0f be c0             	movsbl %al,%eax
 962:	89 44 24 04          	mov    %eax,0x4(%esp)
 966:	8b 45 08             	mov    0x8(%ebp),%eax
 969:	89 04 24             	mov    %eax,(%esp)
 96c:	e8 bf fe ff ff       	call   830 <putc>
 971:	e9 2d 01 00 00       	jmp    aa3 <printf+0x196>
      }
    } else if(state == '%'){
 976:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 97a:	0f 85 23 01 00 00    	jne    aa3 <printf+0x196>
      if(c == 'd'){
 980:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 984:	75 2d                	jne    9b3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 986:	8b 45 e8             	mov    -0x18(%ebp),%eax
 989:	8b 00                	mov    (%eax),%eax
 98b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 992:	00 
 993:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 99a:	00 
 99b:	89 44 24 04          	mov    %eax,0x4(%esp)
 99f:	8b 45 08             	mov    0x8(%ebp),%eax
 9a2:	89 04 24             	mov    %eax,(%esp)
 9a5:	e8 ae fe ff ff       	call   858 <printint>
        ap++;
 9aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9ae:	e9 e9 00 00 00       	jmp    a9c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 9b3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9b7:	74 06                	je     9bf <printf+0xb2>
 9b9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9bd:	75 2d                	jne    9ec <printf+0xdf>
        printint(fd, *ap, 16, 0);
 9bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c2:	8b 00                	mov    (%eax),%eax
 9c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9cb:	00 
 9cc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9d3:	00 
 9d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 9d8:	8b 45 08             	mov    0x8(%ebp),%eax
 9db:	89 04 24             	mov    %eax,(%esp)
 9de:	e8 75 fe ff ff       	call   858 <printint>
        ap++;
 9e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9e7:	e9 b0 00 00 00       	jmp    a9c <printf+0x18f>
      } else if(c == 's'){
 9ec:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9f0:	75 42                	jne    a34 <printf+0x127>
        s = (char*)*ap;
 9f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9f5:	8b 00                	mov    (%eax),%eax
 9f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a02:	75 09                	jne    a0d <printf+0x100>
          s = "(null)";
 a04:	c7 45 f4 0a 0d 00 00 	movl   $0xd0a,-0xc(%ebp)
        while(*s != 0){
 a0b:	eb 1c                	jmp    a29 <printf+0x11c>
 a0d:	eb 1a                	jmp    a29 <printf+0x11c>
          putc(fd, *s);
 a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a12:	8a 00                	mov    (%eax),%al
 a14:	0f be c0             	movsbl %al,%eax
 a17:	89 44 24 04          	mov    %eax,0x4(%esp)
 a1b:	8b 45 08             	mov    0x8(%ebp),%eax
 a1e:	89 04 24             	mov    %eax,(%esp)
 a21:	e8 0a fe ff ff       	call   830 <putc>
          s++;
 a26:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2c:	8a 00                	mov    (%eax),%al
 a2e:	84 c0                	test   %al,%al
 a30:	75 dd                	jne    a0f <printf+0x102>
 a32:	eb 68                	jmp    a9c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a34:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a38:	75 1d                	jne    a57 <printf+0x14a>
        putc(fd, *ap);
 a3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a3d:	8b 00                	mov    (%eax),%eax
 a3f:	0f be c0             	movsbl %al,%eax
 a42:	89 44 24 04          	mov    %eax,0x4(%esp)
 a46:	8b 45 08             	mov    0x8(%ebp),%eax
 a49:	89 04 24             	mov    %eax,(%esp)
 a4c:	e8 df fd ff ff       	call   830 <putc>
        ap++;
 a51:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a55:	eb 45                	jmp    a9c <printf+0x18f>
      } else if(c == '%'){
 a57:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a5b:	75 17                	jne    a74 <printf+0x167>
        putc(fd, c);
 a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a60:	0f be c0             	movsbl %al,%eax
 a63:	89 44 24 04          	mov    %eax,0x4(%esp)
 a67:	8b 45 08             	mov    0x8(%ebp),%eax
 a6a:	89 04 24             	mov    %eax,(%esp)
 a6d:	e8 be fd ff ff       	call   830 <putc>
 a72:	eb 28                	jmp    a9c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a74:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a7b:	00 
 a7c:	8b 45 08             	mov    0x8(%ebp),%eax
 a7f:	89 04 24             	mov    %eax,(%esp)
 a82:	e8 a9 fd ff ff       	call   830 <putc>
        putc(fd, c);
 a87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a8a:	0f be c0             	movsbl %al,%eax
 a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
 a91:	8b 45 08             	mov    0x8(%ebp),%eax
 a94:	89 04 24             	mov    %eax,(%esp)
 a97:	e8 94 fd ff ff       	call   830 <putc>
      }
      state = 0;
 a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 aa3:	ff 45 f0             	incl   -0x10(%ebp)
 aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
 aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aac:	01 d0                	add    %edx,%eax
 aae:	8a 00                	mov    (%eax),%al
 ab0:	84 c0                	test   %al,%al
 ab2:	0f 85 77 fe ff ff    	jne    92f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 ab8:	c9                   	leave  
 ab9:	c3                   	ret    
 aba:	90                   	nop
 abb:	90                   	nop

00000abc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 abc:	55                   	push   %ebp
 abd:	89 e5                	mov    %esp,%ebp
 abf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ac2:	8b 45 08             	mov    0x8(%ebp),%eax
 ac5:	83 e8 08             	sub    $0x8,%eax
 ac8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 acb:	a1 28 10 00 00       	mov    0x1028,%eax
 ad0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ad3:	eb 24                	jmp    af9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ad5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad8:	8b 00                	mov    (%eax),%eax
 ada:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 add:	77 12                	ja     af1 <free+0x35>
 adf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ae5:	77 24                	ja     b0b <free+0x4f>
 ae7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aea:	8b 00                	mov    (%eax),%eax
 aec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 aef:	77 1a                	ja     b0b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 af1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af4:	8b 00                	mov    (%eax),%eax
 af6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 af9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aff:	76 d4                	jbe    ad5 <free+0x19>
 b01:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b04:	8b 00                	mov    (%eax),%eax
 b06:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b09:	76 ca                	jbe    ad5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0e:	8b 40 04             	mov    0x4(%eax),%eax
 b11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b18:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1b:	01 c2                	add    %eax,%edx
 b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b20:	8b 00                	mov    (%eax),%eax
 b22:	39 c2                	cmp    %eax,%edx
 b24:	75 24                	jne    b4a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b29:	8b 50 04             	mov    0x4(%eax),%edx
 b2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2f:	8b 00                	mov    (%eax),%eax
 b31:	8b 40 04             	mov    0x4(%eax),%eax
 b34:	01 c2                	add    %eax,%edx
 b36:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b39:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3f:	8b 00                	mov    (%eax),%eax
 b41:	8b 10                	mov    (%eax),%edx
 b43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b46:	89 10                	mov    %edx,(%eax)
 b48:	eb 0a                	jmp    b54 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4d:	8b 10                	mov    (%eax),%edx
 b4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b52:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b54:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b57:	8b 40 04             	mov    0x4(%eax),%eax
 b5a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b64:	01 d0                	add    %edx,%eax
 b66:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b69:	75 20                	jne    b8b <free+0xcf>
    p->s.size += bp->s.size;
 b6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b6e:	8b 50 04             	mov    0x4(%eax),%edx
 b71:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b74:	8b 40 04             	mov    0x4(%eax),%eax
 b77:	01 c2                	add    %eax,%edx
 b79:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b82:	8b 10                	mov    (%eax),%edx
 b84:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b87:	89 10                	mov    %edx,(%eax)
 b89:	eb 08                	jmp    b93 <free+0xd7>
  } else
    p->s.ptr = bp;
 b8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b91:	89 10                	mov    %edx,(%eax)
  freep = p;
 b93:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b96:	a3 28 10 00 00       	mov    %eax,0x1028
}
 b9b:	c9                   	leave  
 b9c:	c3                   	ret    

00000b9d <morecore>:

static Header*
morecore(uint nu)
{
 b9d:	55                   	push   %ebp
 b9e:	89 e5                	mov    %esp,%ebp
 ba0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ba3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 baa:	77 07                	ja     bb3 <morecore+0x16>
    nu = 4096;
 bac:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bb3:	8b 45 08             	mov    0x8(%ebp),%eax
 bb6:	c1 e0 03             	shl    $0x3,%eax
 bb9:	89 04 24             	mov    %eax,(%esp)
 bbc:	e8 47 fb ff ff       	call   708 <sbrk>
 bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bc4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bc8:	75 07                	jne    bd1 <morecore+0x34>
    return 0;
 bca:	b8 00 00 00 00       	mov    $0x0,%eax
 bcf:	eb 22                	jmp    bf3 <morecore+0x56>
  hp = (Header*)p;
 bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bda:	8b 55 08             	mov    0x8(%ebp),%edx
 bdd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be3:	83 c0 08             	add    $0x8,%eax
 be6:	89 04 24             	mov    %eax,(%esp)
 be9:	e8 ce fe ff ff       	call   abc <free>
  return freep;
 bee:	a1 28 10 00 00       	mov    0x1028,%eax
}
 bf3:	c9                   	leave  
 bf4:	c3                   	ret    

00000bf5 <malloc>:

void*
malloc(uint nbytes)
{
 bf5:	55                   	push   %ebp
 bf6:	89 e5                	mov    %esp,%ebp
 bf8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bfb:	8b 45 08             	mov    0x8(%ebp),%eax
 bfe:	83 c0 07             	add    $0x7,%eax
 c01:	c1 e8 03             	shr    $0x3,%eax
 c04:	40                   	inc    %eax
 c05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c08:	a1 28 10 00 00       	mov    0x1028,%eax
 c0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c14:	75 23                	jne    c39 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 c16:	c7 45 f0 20 10 00 00 	movl   $0x1020,-0x10(%ebp)
 c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c20:	a3 28 10 00 00       	mov    %eax,0x1028
 c25:	a1 28 10 00 00       	mov    0x1028,%eax
 c2a:	a3 20 10 00 00       	mov    %eax,0x1020
    base.s.size = 0;
 c2f:	c7 05 24 10 00 00 00 	movl   $0x0,0x1024
 c36:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c3c:	8b 00                	mov    (%eax),%eax
 c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c44:	8b 40 04             	mov    0x4(%eax),%eax
 c47:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c4a:	72 4d                	jb     c99 <malloc+0xa4>
      if(p->s.size == nunits)
 c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4f:	8b 40 04             	mov    0x4(%eax),%eax
 c52:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c55:	75 0c                	jne    c63 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5a:	8b 10                	mov    (%eax),%edx
 c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c5f:	89 10                	mov    %edx,(%eax)
 c61:	eb 26                	jmp    c89 <malloc+0x94>
      else {
        p->s.size -= nunits;
 c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c66:	8b 40 04             	mov    0x4(%eax),%eax
 c69:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c6c:	89 c2                	mov    %eax,%edx
 c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c71:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c77:	8b 40 04             	mov    0x4(%eax),%eax
 c7a:	c1 e0 03             	shl    $0x3,%eax
 c7d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c83:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c86:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c8c:	a3 28 10 00 00       	mov    %eax,0x1028
      return (void*)(p + 1);
 c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c94:	83 c0 08             	add    $0x8,%eax
 c97:	eb 38                	jmp    cd1 <malloc+0xdc>
    }
    if(p == freep)
 c99:	a1 28 10 00 00       	mov    0x1028,%eax
 c9e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ca1:	75 1b                	jne    cbe <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ca6:	89 04 24             	mov    %eax,(%esp)
 ca9:	e8 ef fe ff ff       	call   b9d <morecore>
 cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cb5:	75 07                	jne    cbe <malloc+0xc9>
        return 0;
 cb7:	b8 00 00 00 00       	mov    $0x0,%eax
 cbc:	eb 13                	jmp    cd1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc7:	8b 00                	mov    (%eax),%eax
 cc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ccc:	e9 70 ff ff ff       	jmp    c41 <malloc+0x4c>
}
 cd1:	c9                   	leave  
 cd2:	c3                   	ret    
