
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
  1b:	05 20 0e 00 00       	add    $0xe20,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 20 0e 00 00 	movl   $0xe20,-0x10(%ebp)
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
  6d:	e8 4a 05 00 00       	call   5bc <write>
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
  95:	81 7d f0 20 0e 00 00 	cmpl   $0xe20,-0x10(%ebp)
  9c:	75 07                	jne    a5 <grep+0xa5>
      m = 0;
  9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a9:	7e 29                	jle    d4 <grep+0xd4>
      m -= p - buf;
  ab:	ba 20 0e 00 00       	mov    $0xe20,%edx
  b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b3:	29 c2                	sub    %eax,%edx
  b5:	89 d0                	mov    %edx,%eax
  b7:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  c8:	c7 04 24 20 0e 00 00 	movl   $0xe20,(%esp)
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
  e3:	81 c2 20 0e 00 00    	add    $0xe20,%edx
  e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  f4:	89 04 24             	mov    %eax,(%esp)
  f7:	e8 b8 04 00 00       	call   5b4 <read>
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
 11a:	c7 44 24 04 e8 0a 00 	movl   $0xae8,0x4(%esp)
 121:	00 
 122:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 129:	e8 f3 05 00 00       	call   721 <printf>
    exit();
 12e:	e8 69 04 00 00       	call   59c <exit>
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
 157:	e8 40 04 00 00       	call   59c <exit>
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
 186:	e8 51 04 00 00       	call   5dc <open>
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
 1ac:	c7 44 24 04 08 0b 00 	movl   $0xb08,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 61 05 00 00       	call   721 <printf>
      exit();
 1c0:	e8 d7 03 00 00       	call   59c <exit>
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
 1e0:	e8 df 03 00 00       	call   5c4 <close>
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
 1f6:	e8 a1 03 00 00       	call   59c <exit>

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
 471:	e8 3e 01 00 00       	call   5b4 <read>
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
 4d1:	e8 06 01 00 00       	call   5dc <open>
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
 4f3:	e8 fc 00 00 00       	call   5f4 <fstat>
 4f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fe:	89 04 24             	mov    %eax,(%esp)
 501:	e8 be 00 00 00       	call   5c4 <close>
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
 591:	90                   	nop
 592:	90                   	nop
 593:	90                   	nop

00000594 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 594:	b8 01 00 00 00       	mov    $0x1,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <exit>:
SYSCALL(exit)
 59c:	b8 02 00 00 00       	mov    $0x2,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <wait>:
SYSCALL(wait)
 5a4:	b8 03 00 00 00       	mov    $0x3,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <pipe>:
SYSCALL(pipe)
 5ac:	b8 04 00 00 00       	mov    $0x4,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <read>:
SYSCALL(read)
 5b4:	b8 05 00 00 00       	mov    $0x5,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <write>:
SYSCALL(write)
 5bc:	b8 10 00 00 00       	mov    $0x10,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <close>:
SYSCALL(close)
 5c4:	b8 15 00 00 00       	mov    $0x15,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <kill>:
SYSCALL(kill)
 5cc:	b8 06 00 00 00       	mov    $0x6,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <exec>:
SYSCALL(exec)
 5d4:	b8 07 00 00 00       	mov    $0x7,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <open>:
SYSCALL(open)
 5dc:	b8 0f 00 00 00       	mov    $0xf,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <mknod>:
SYSCALL(mknod)
 5e4:	b8 11 00 00 00       	mov    $0x11,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <unlink>:
SYSCALL(unlink)
 5ec:	b8 12 00 00 00       	mov    $0x12,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <fstat>:
SYSCALL(fstat)
 5f4:	b8 08 00 00 00       	mov    $0x8,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <link>:
SYSCALL(link)
 5fc:	b8 13 00 00 00       	mov    $0x13,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <mkdir>:
SYSCALL(mkdir)
 604:	b8 14 00 00 00       	mov    $0x14,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <chdir>:
SYSCALL(chdir)
 60c:	b8 09 00 00 00       	mov    $0x9,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <dup>:
SYSCALL(dup)
 614:	b8 0a 00 00 00       	mov    $0xa,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <getpid>:
SYSCALL(getpid)
 61c:	b8 0b 00 00 00       	mov    $0xb,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <sbrk>:
SYSCALL(sbrk)
 624:	b8 0c 00 00 00       	mov    $0xc,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <sleep>:
SYSCALL(sleep)
 62c:	b8 0d 00 00 00       	mov    $0xd,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <uptime>:
SYSCALL(uptime)
 634:	b8 0e 00 00 00       	mov    $0xe,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <getticks>:
 63c:	b8 16 00 00 00       	mov    $0x16,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 644:	55                   	push   %ebp
 645:	89 e5                	mov    %esp,%ebp
 647:	83 ec 18             	sub    $0x18,%esp
 64a:	8b 45 0c             	mov    0xc(%ebp),%eax
 64d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 650:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 657:	00 
 658:	8d 45 f4             	lea    -0xc(%ebp),%eax
 65b:	89 44 24 04          	mov    %eax,0x4(%esp)
 65f:	8b 45 08             	mov    0x8(%ebp),%eax
 662:	89 04 24             	mov    %eax,(%esp)
 665:	e8 52 ff ff ff       	call   5bc <write>
}
 66a:	c9                   	leave  
 66b:	c3                   	ret    

0000066c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 66c:	55                   	push   %ebp
 66d:	89 e5                	mov    %esp,%ebp
 66f:	56                   	push   %esi
 670:	53                   	push   %ebx
 671:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 674:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 67b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 67f:	74 17                	je     698 <printint+0x2c>
 681:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 685:	79 11                	jns    698 <printint+0x2c>
    neg = 1;
 687:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 68e:	8b 45 0c             	mov    0xc(%ebp),%eax
 691:	f7 d8                	neg    %eax
 693:	89 45 ec             	mov    %eax,-0x14(%ebp)
 696:	eb 06                	jmp    69e <printint+0x32>
  } else {
    x = xx;
 698:	8b 45 0c             	mov    0xc(%ebp),%eax
 69b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 69e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6a5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6a8:	8d 41 01             	lea    0x1(%ecx),%eax
 6ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b4:	ba 00 00 00 00       	mov    $0x0,%edx
 6b9:	f7 f3                	div    %ebx
 6bb:	89 d0                	mov    %edx,%eax
 6bd:	8a 80 ec 0d 00 00    	mov    0xdec(%eax),%al
 6c3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6c7:	8b 75 10             	mov    0x10(%ebp),%esi
 6ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6cd:	ba 00 00 00 00       	mov    $0x0,%edx
 6d2:	f7 f6                	div    %esi
 6d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6db:	75 c8                	jne    6a5 <printint+0x39>
  if(neg)
 6dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e1:	74 10                	je     6f3 <printint+0x87>
    buf[i++] = '-';
 6e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e6:	8d 50 01             	lea    0x1(%eax),%edx
 6e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6ec:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6f1:	eb 1e                	jmp    711 <printint+0xa5>
 6f3:	eb 1c                	jmp    711 <printint+0xa5>
    putc(fd, buf[i]);
 6f5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fb:	01 d0                	add    %edx,%eax
 6fd:	8a 00                	mov    (%eax),%al
 6ff:	0f be c0             	movsbl %al,%eax
 702:	89 44 24 04          	mov    %eax,0x4(%esp)
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	89 04 24             	mov    %eax,(%esp)
 70c:	e8 33 ff ff ff       	call   644 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 711:	ff 4d f4             	decl   -0xc(%ebp)
 714:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 718:	79 db                	jns    6f5 <printint+0x89>
    putc(fd, buf[i]);
}
 71a:	83 c4 30             	add    $0x30,%esp
 71d:	5b                   	pop    %ebx
 71e:	5e                   	pop    %esi
 71f:	5d                   	pop    %ebp
 720:	c3                   	ret    

00000721 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 721:	55                   	push   %ebp
 722:	89 e5                	mov    %esp,%ebp
 724:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 727:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 72e:	8d 45 0c             	lea    0xc(%ebp),%eax
 731:	83 c0 04             	add    $0x4,%eax
 734:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 737:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 73e:	e9 77 01 00 00       	jmp    8ba <printf+0x199>
    c = fmt[i] & 0xff;
 743:	8b 55 0c             	mov    0xc(%ebp),%edx
 746:	8b 45 f0             	mov    -0x10(%ebp),%eax
 749:	01 d0                	add    %edx,%eax
 74b:	8a 00                	mov    (%eax),%al
 74d:	0f be c0             	movsbl %al,%eax
 750:	25 ff 00 00 00       	and    $0xff,%eax
 755:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 758:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 75c:	75 2c                	jne    78a <printf+0x69>
      if(c == '%'){
 75e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 762:	75 0c                	jne    770 <printf+0x4f>
        state = '%';
 764:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 76b:	e9 47 01 00 00       	jmp    8b7 <printf+0x196>
      } else {
        putc(fd, c);
 770:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 773:	0f be c0             	movsbl %al,%eax
 776:	89 44 24 04          	mov    %eax,0x4(%esp)
 77a:	8b 45 08             	mov    0x8(%ebp),%eax
 77d:	89 04 24             	mov    %eax,(%esp)
 780:	e8 bf fe ff ff       	call   644 <putc>
 785:	e9 2d 01 00 00       	jmp    8b7 <printf+0x196>
      }
    } else if(state == '%'){
 78a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 78e:	0f 85 23 01 00 00    	jne    8b7 <printf+0x196>
      if(c == 'd'){
 794:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 798:	75 2d                	jne    7c7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 79a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7a6:	00 
 7a7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7ae:	00 
 7af:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b3:	8b 45 08             	mov    0x8(%ebp),%eax
 7b6:	89 04 24             	mov    %eax,(%esp)
 7b9:	e8 ae fe ff ff       	call   66c <printint>
        ap++;
 7be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c2:	e9 e9 00 00 00       	jmp    8b0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 7c7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7cb:	74 06                	je     7d3 <printf+0xb2>
 7cd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7d1:	75 2d                	jne    800 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 7d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d6:	8b 00                	mov    (%eax),%eax
 7d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7df:	00 
 7e0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7e7:	00 
 7e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ec:	8b 45 08             	mov    0x8(%ebp),%eax
 7ef:	89 04 24             	mov    %eax,(%esp)
 7f2:	e8 75 fe ff ff       	call   66c <printint>
        ap++;
 7f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7fb:	e9 b0 00 00 00       	jmp    8b0 <printf+0x18f>
      } else if(c == 's'){
 800:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 804:	75 42                	jne    848 <printf+0x127>
        s = (char*)*ap;
 806:	8b 45 e8             	mov    -0x18(%ebp),%eax
 809:	8b 00                	mov    (%eax),%eax
 80b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 80e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 812:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 816:	75 09                	jne    821 <printf+0x100>
          s = "(null)";
 818:	c7 45 f4 1e 0b 00 00 	movl   $0xb1e,-0xc(%ebp)
        while(*s != 0){
 81f:	eb 1c                	jmp    83d <printf+0x11c>
 821:	eb 1a                	jmp    83d <printf+0x11c>
          putc(fd, *s);
 823:	8b 45 f4             	mov    -0xc(%ebp),%eax
 826:	8a 00                	mov    (%eax),%al
 828:	0f be c0             	movsbl %al,%eax
 82b:	89 44 24 04          	mov    %eax,0x4(%esp)
 82f:	8b 45 08             	mov    0x8(%ebp),%eax
 832:	89 04 24             	mov    %eax,(%esp)
 835:	e8 0a fe ff ff       	call   644 <putc>
          s++;
 83a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 840:	8a 00                	mov    (%eax),%al
 842:	84 c0                	test   %al,%al
 844:	75 dd                	jne    823 <printf+0x102>
 846:	eb 68                	jmp    8b0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 848:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 84c:	75 1d                	jne    86b <printf+0x14a>
        putc(fd, *ap);
 84e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 851:	8b 00                	mov    (%eax),%eax
 853:	0f be c0             	movsbl %al,%eax
 856:	89 44 24 04          	mov    %eax,0x4(%esp)
 85a:	8b 45 08             	mov    0x8(%ebp),%eax
 85d:	89 04 24             	mov    %eax,(%esp)
 860:	e8 df fd ff ff       	call   644 <putc>
        ap++;
 865:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 869:	eb 45                	jmp    8b0 <printf+0x18f>
      } else if(c == '%'){
 86b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 86f:	75 17                	jne    888 <printf+0x167>
        putc(fd, c);
 871:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 874:	0f be c0             	movsbl %al,%eax
 877:	89 44 24 04          	mov    %eax,0x4(%esp)
 87b:	8b 45 08             	mov    0x8(%ebp),%eax
 87e:	89 04 24             	mov    %eax,(%esp)
 881:	e8 be fd ff ff       	call   644 <putc>
 886:	eb 28                	jmp    8b0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 888:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 88f:	00 
 890:	8b 45 08             	mov    0x8(%ebp),%eax
 893:	89 04 24             	mov    %eax,(%esp)
 896:	e8 a9 fd ff ff       	call   644 <putc>
        putc(fd, c);
 89b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 89e:	0f be c0             	movsbl %al,%eax
 8a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 8a5:	8b 45 08             	mov    0x8(%ebp),%eax
 8a8:	89 04 24             	mov    %eax,(%esp)
 8ab:	e8 94 fd ff ff       	call   644 <putc>
      }
      state = 0;
 8b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8b7:	ff 45 f0             	incl   -0x10(%ebp)
 8ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 8bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c0:	01 d0                	add    %edx,%eax
 8c2:	8a 00                	mov    (%eax),%al
 8c4:	84 c0                	test   %al,%al
 8c6:	0f 85 77 fe ff ff    	jne    743 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8cc:	c9                   	leave  
 8cd:	c3                   	ret    
 8ce:	90                   	nop
 8cf:	90                   	nop

000008d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d0:	55                   	push   %ebp
 8d1:	89 e5                	mov    %esp,%ebp
 8d3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d6:	8b 45 08             	mov    0x8(%ebp),%eax
 8d9:	83 e8 08             	sub    $0x8,%eax
 8dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8df:	a1 08 0e 00 00       	mov    0xe08,%eax
 8e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8e7:	eb 24                	jmp    90d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 00                	mov    (%eax),%eax
 8ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f1:	77 12                	ja     905 <free+0x35>
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f9:	77 24                	ja     91f <free+0x4f>
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	8b 00                	mov    (%eax),%eax
 900:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 903:	77 1a                	ja     91f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	8b 00                	mov    (%eax),%eax
 90a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 90d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 910:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 913:	76 d4                	jbe    8e9 <free+0x19>
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 91d:	76 ca                	jbe    8e9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 91f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 922:	8b 40 04             	mov    0x4(%eax),%eax
 925:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 92c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92f:	01 c2                	add    %eax,%edx
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	8b 00                	mov    (%eax),%eax
 936:	39 c2                	cmp    %eax,%edx
 938:	75 24                	jne    95e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 93a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93d:	8b 50 04             	mov    0x4(%eax),%edx
 940:	8b 45 fc             	mov    -0x4(%ebp),%eax
 943:	8b 00                	mov    (%eax),%eax
 945:	8b 40 04             	mov    0x4(%eax),%eax
 948:	01 c2                	add    %eax,%edx
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 00                	mov    (%eax),%eax
 955:	8b 10                	mov    (%eax),%edx
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	89 10                	mov    %edx,(%eax)
 95c:	eb 0a                	jmp    968 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 95e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 961:	8b 10                	mov    (%eax),%edx
 963:	8b 45 f8             	mov    -0x8(%ebp),%eax
 966:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 968:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96b:	8b 40 04             	mov    0x4(%eax),%eax
 96e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	01 d0                	add    %edx,%eax
 97a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 97d:	75 20                	jne    99f <free+0xcf>
    p->s.size += bp->s.size;
 97f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 982:	8b 50 04             	mov    0x4(%eax),%edx
 985:	8b 45 f8             	mov    -0x8(%ebp),%eax
 988:	8b 40 04             	mov    0x4(%eax),%eax
 98b:	01 c2                	add    %eax,%edx
 98d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 990:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 993:	8b 45 f8             	mov    -0x8(%ebp),%eax
 996:	8b 10                	mov    (%eax),%edx
 998:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99b:	89 10                	mov    %edx,(%eax)
 99d:	eb 08                	jmp    9a7 <free+0xd7>
  } else
    p->s.ptr = bp;
 99f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9a5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9aa:	a3 08 0e 00 00       	mov    %eax,0xe08
}
 9af:	c9                   	leave  
 9b0:	c3                   	ret    

000009b1 <morecore>:

static Header*
morecore(uint nu)
{
 9b1:	55                   	push   %ebp
 9b2:	89 e5                	mov    %esp,%ebp
 9b4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9b7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9be:	77 07                	ja     9c7 <morecore+0x16>
    nu = 4096;
 9c0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9c7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ca:	c1 e0 03             	shl    $0x3,%eax
 9cd:	89 04 24             	mov    %eax,(%esp)
 9d0:	e8 4f fc ff ff       	call   624 <sbrk>
 9d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9d8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9dc:	75 07                	jne    9e5 <morecore+0x34>
    return 0;
 9de:	b8 00 00 00 00       	mov    $0x0,%eax
 9e3:	eb 22                	jmp    a07 <morecore+0x56>
  hp = (Header*)p;
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ee:	8b 55 08             	mov    0x8(%ebp),%edx
 9f1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f7:	83 c0 08             	add    $0x8,%eax
 9fa:	89 04 24             	mov    %eax,(%esp)
 9fd:	e8 ce fe ff ff       	call   8d0 <free>
  return freep;
 a02:	a1 08 0e 00 00       	mov    0xe08,%eax
}
 a07:	c9                   	leave  
 a08:	c3                   	ret    

00000a09 <malloc>:

void*
malloc(uint nbytes)
{
 a09:	55                   	push   %ebp
 a0a:	89 e5                	mov    %esp,%ebp
 a0c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a0f:	8b 45 08             	mov    0x8(%ebp),%eax
 a12:	83 c0 07             	add    $0x7,%eax
 a15:	c1 e8 03             	shr    $0x3,%eax
 a18:	40                   	inc    %eax
 a19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a1c:	a1 08 0e 00 00       	mov    0xe08,%eax
 a21:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a28:	75 23                	jne    a4d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a2a:	c7 45 f0 00 0e 00 00 	movl   $0xe00,-0x10(%ebp)
 a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a34:	a3 08 0e 00 00       	mov    %eax,0xe08
 a39:	a1 08 0e 00 00       	mov    0xe08,%eax
 a3e:	a3 00 0e 00 00       	mov    %eax,0xe00
    base.s.size = 0;
 a43:	c7 05 04 0e 00 00 00 	movl   $0x0,0xe04
 a4a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a50:	8b 00                	mov    (%eax),%eax
 a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a58:	8b 40 04             	mov    0x4(%eax),%eax
 a5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a5e:	72 4d                	jb     aad <malloc+0xa4>
      if(p->s.size == nunits)
 a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a63:	8b 40 04             	mov    0x4(%eax),%eax
 a66:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a69:	75 0c                	jne    a77 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6e:	8b 10                	mov    (%eax),%edx
 a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a73:	89 10                	mov    %edx,(%eax)
 a75:	eb 26                	jmp    a9d <malloc+0x94>
      else {
        p->s.size -= nunits;
 a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7a:	8b 40 04             	mov    0x4(%eax),%eax
 a7d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a80:	89 c2                	mov    %eax,%edx
 a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a85:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8b:	8b 40 04             	mov    0x4(%eax),%eax
 a8e:	c1 e0 03             	shl    $0x3,%eax
 a91:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a9a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa0:	a3 08 0e 00 00       	mov    %eax,0xe08
      return (void*)(p + 1);
 aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa8:	83 c0 08             	add    $0x8,%eax
 aab:	eb 38                	jmp    ae5 <malloc+0xdc>
    }
    if(p == freep)
 aad:	a1 08 0e 00 00       	mov    0xe08,%eax
 ab2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ab5:	75 1b                	jne    ad2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 ab7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 aba:	89 04 24             	mov    %eax,(%esp)
 abd:	e8 ef fe ff ff       	call   9b1 <morecore>
 ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ac5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ac9:	75 07                	jne    ad2 <malloc+0xc9>
        return 0;
 acb:	b8 00 00 00 00       	mov    $0x0,%eax
 ad0:	eb 13                	jmp    ae5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adb:	8b 00                	mov    (%eax),%eax
 add:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ae0:	e9 70 ff ff ff       	jmp    a55 <malloc+0x4c>
}
 ae5:	c9                   	leave  
 ae6:	c3                   	ret    
