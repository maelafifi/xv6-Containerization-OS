
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
  1b:	05 c0 0e 00 00       	add    $0xec0,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 c0 0e 00 00 	movl   $0xec0,-0x10(%ebp)
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
  95:	81 7d f0 c0 0e 00 00 	cmpl   $0xec0,-0x10(%ebp)
  9c:	75 07                	jne    a5 <grep+0xa5>
      m = 0;
  9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a9:	7e 29                	jle    d4 <grep+0xd4>
      m -= p - buf;
  ab:	ba c0 0e 00 00       	mov    $0xec0,%edx
  b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b3:	29 c2                	sub    %eax,%edx
  b5:	89 d0                	mov    %edx,%eax
  b7:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  c8:	c7 04 24 c0 0e 00 00 	movl   $0xec0,(%esp)
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
  e3:	81 c2 c0 0e 00 00    	add    $0xec0,%edx
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
 11a:	c7 44 24 04 88 0b 00 	movl   $0xb88,0x4(%esp)
 121:	00 
 122:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 129:	e8 93 06 00 00       	call   7c1 <printf>
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
 1ac:	c7 44 24 04 a8 0b 00 	movl   $0xba8,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 01 06 00 00       	call   7c1 <printf>
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
SYSCALL(getticks)
 63c:	b8 16 00 00 00       	mov    $0x16,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <get_name>:
SYSCALL(get_name)
 644:	b8 17 00 00 00       	mov    $0x17,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <get_max_proc>:
SYSCALL(get_max_proc)
 64c:	b8 18 00 00 00       	mov    $0x18,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <get_max_mem>:
SYSCALL(get_max_mem)
 654:	b8 19 00 00 00       	mov    $0x19,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <get_max_disk>:
SYSCALL(get_max_disk)
 65c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <get_curr_proc>:
SYSCALL(get_curr_proc)
 664:	b8 1b 00 00 00       	mov    $0x1b,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <get_curr_mem>:
SYSCALL(get_curr_mem)
 66c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <get_curr_disk>:
SYSCALL(get_curr_disk)
 674:	b8 1d 00 00 00       	mov    $0x1d,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <set_name>:
SYSCALL(set_name)
 67c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <set_max_mem>:
SYSCALL(set_max_mem)
 684:	b8 1f 00 00 00       	mov    $0x1f,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <set_max_disk>:
SYSCALL(set_max_disk)
 68c:	b8 20 00 00 00       	mov    $0x20,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <set_max_proc>:
SYSCALL(set_max_proc)
 694:	b8 21 00 00 00       	mov    $0x21,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	ret    

0000069c <set_curr_mem>:
SYSCALL(set_curr_mem)
 69c:	b8 22 00 00 00       	mov    $0x22,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	ret    

000006a4 <set_curr_disk>:
SYSCALL(set_curr_disk)
 6a4:	b8 23 00 00 00       	mov    $0x23,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	ret    

000006ac <set_curr_proc>:
SYSCALL(set_curr_proc)
 6ac:	b8 24 00 00 00       	mov    $0x24,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	ret    

000006b4 <find>:
SYSCALL(find)
 6b4:	b8 25 00 00 00       	mov    $0x25,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	ret    

000006bc <is_full>:
SYSCALL(is_full)
 6bc:	b8 26 00 00 00       	mov    $0x26,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	ret    

000006c4 <container_init>:
SYSCALL(container_init)
 6c4:	b8 27 00 00 00       	mov    $0x27,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	ret    

000006cc <cont_proc_set>:
SYSCALL(cont_proc_set)
 6cc:	b8 28 00 00 00       	mov    $0x28,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	ret    

000006d4 <ps>:
SYSCALL(ps)
 6d4:	b8 29 00 00 00       	mov    $0x29,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	ret    

000006dc <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 6dc:	b8 2a 00 00 00       	mov    $0x2a,%eax
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
 705:	e8 b2 fe ff ff       	call   5bc <write>
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
 75d:	8a 80 8c 0e 00 00    	mov    0xe8c(%eax),%al
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
 8b8:	c7 45 f4 be 0b 00 00 	movl   $0xbbe,-0xc(%ebp)
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
 97f:	a1 a8 0e 00 00       	mov    0xea8,%eax
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
 a4a:	a3 a8 0e 00 00       	mov    %eax,0xea8
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
 a70:	e8 af fb ff ff       	call   624 <sbrk>
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
 aa2:	a1 a8 0e 00 00       	mov    0xea8,%eax
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
 abc:	a1 a8 0e 00 00       	mov    0xea8,%eax
 ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ac8:	75 23                	jne    aed <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 aca:	c7 45 f0 a0 0e 00 00 	movl   $0xea0,-0x10(%ebp)
 ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad4:	a3 a8 0e 00 00       	mov    %eax,0xea8
 ad9:	a1 a8 0e 00 00       	mov    0xea8,%eax
 ade:	a3 a0 0e 00 00       	mov    %eax,0xea0
    base.s.size = 0;
 ae3:	c7 05 a4 0e 00 00 00 	movl   $0x0,0xea4
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
 b40:	a3 a8 0e 00 00       	mov    %eax,0xea8
      return (void*)(p + 1);
 b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b48:	83 c0 08             	add    $0x8,%eax
 b4b:	eb 38                	jmp    b85 <malloc+0xdc>
    }
    if(p == freep)
 b4d:	a1 a8 0e 00 00       	mov    0xea8,%eax
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
