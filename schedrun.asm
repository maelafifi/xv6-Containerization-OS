
_schedrun:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
//schedtest

#include "user.h"

int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 50             	sub    $0x50,%esp
	int pid;
	if((pid = fork()) == 0){
   c:	e8 ef 03 00 00       	call   400 <fork>
  11:	89 44 24 4c          	mov    %eax,0x4c(%esp)
  15:	83 7c 24 4c 00       	cmpl   $0x0,0x4c(%esp)
  1a:	75 2a                	jne    46 <main+0x46>
		char *executable[] = {"ctool","start", "vc0", "c1", "0","0","0", "schedtest", "3", "1500", 0};
  1c:	8d 54 24 18          	lea    0x18(%esp),%edx
  20:	bb a0 0a 00 00       	mov    $0xaa0,%ebx
  25:	b8 0b 00 00 00       	mov    $0xb,%eax
  2a:	89 d7                	mov    %edx,%edi
  2c:	89 de                	mov    %ebx,%esi
  2e:	89 c1                	mov    %eax,%ecx
  30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		exec("ctool", executable);
  32:	8d 44 24 18          	lea    0x18(%esp),%eax
  36:	89 44 24 04          	mov    %eax,0x4(%esp)
  3a:	c7 04 24 60 0a 00 00 	movl   $0xa60,(%esp)
  41:	e8 fa 03 00 00       	call   440 <exec>
	}
	if((pid = fork()) == 0){
  46:	e8 b5 03 00 00       	call   400 <fork>
  4b:	89 44 24 4c          	mov    %eax,0x4c(%esp)
  4f:	83 7c 24 4c 00       	cmpl   $0x0,0x4c(%esp)
  54:	75 2a                	jne    80 <main+0x80>
		char *executable[] = {"ctool","start", "vc2", "c2","0","0","0","schedtest", "1", "1500", 0};
  56:	8d 54 24 18          	lea    0x18(%esp),%edx
  5a:	bb e0 0a 00 00       	mov    $0xae0,%ebx
  5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  64:	89 d7                	mov    %edx,%edi
  66:	89 de                	mov    %ebx,%esi
  68:	89 c1                	mov    %eax,%ecx
  6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		exec("ctool", executable);
  6c:	8d 44 24 18          	lea    0x18(%esp),%eax
  70:	89 44 24 04          	mov    %eax,0x4(%esp)
  74:	c7 04 24 60 0a 00 00 	movl   $0xa60,(%esp)
  7b:	e8 c0 03 00 00       	call   440 <exec>
	}
	if((pid = fork()) == 0){
  80:	e8 7b 03 00 00       	call   400 <fork>
  85:	89 44 24 4c          	mov    %eax,0x4c(%esp)
  89:	83 7c 24 4c 00       	cmpl   $0x0,0x4c(%esp)
  8e:	75 24                	jne    b4 <main+0xb4>
		char *executable[] = {"sh", 0};
  90:	c7 44 24 44 66 0a 00 	movl   $0xa66,0x44(%esp)
  97:	00 
  98:	c7 44 24 48 00 00 00 	movl   $0x0,0x48(%esp)
  9f:	00 
		exec("sh", executable);
  a0:	8d 44 24 44          	lea    0x44(%esp),%eax
  a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  a8:	c7 04 24 66 0a 00 00 	movl   $0xa66,(%esp)
  af:	e8 8c 03 00 00       	call   440 <exec>
	}
	wait();
  b4:	e8 57 03 00 00       	call   410 <wait>
	wait();
  b9:	e8 52 03 00 00       	call   410 <wait>
	wait();
  be:	e8 4d 03 00 00       	call   410 <wait>
	//exit();
	return 1;
  c3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  cb:	5b                   	pop    %ebx
  cc:	5e                   	pop    %esi
  cd:	5f                   	pop    %edi
  ce:	5d                   	pop    %ebp
  cf:	c3                   	ret    

000000d0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	57                   	push   %edi
  d4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  d8:	8b 55 10             	mov    0x10(%ebp),%edx
  db:	8b 45 0c             	mov    0xc(%ebp),%eax
  de:	89 cb                	mov    %ecx,%ebx
  e0:	89 df                	mov    %ebx,%edi
  e2:	89 d1                	mov    %edx,%ecx
  e4:	fc                   	cld    
  e5:	f3 aa                	rep stos %al,%es:(%edi)
  e7:	89 ca                	mov    %ecx,%edx
  e9:	89 fb                	mov    %edi,%ebx
  eb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ee:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  f1:	5b                   	pop    %ebx
  f2:	5f                   	pop    %edi
  f3:	5d                   	pop    %ebp
  f4:	c3                   	ret    

000000f5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  f5:	55                   	push   %ebp
  f6:	89 e5                	mov    %esp,%ebp
  f8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  fb:	8b 45 08             	mov    0x8(%ebp),%eax
  fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 101:	90                   	nop
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	8d 50 01             	lea    0x1(%eax),%edx
 108:	89 55 08             	mov    %edx,0x8(%ebp)
 10b:	8b 55 0c             	mov    0xc(%ebp),%edx
 10e:	8d 4a 01             	lea    0x1(%edx),%ecx
 111:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 114:	8a 12                	mov    (%edx),%dl
 116:	88 10                	mov    %dl,(%eax)
 118:	8a 00                	mov    (%eax),%al
 11a:	84 c0                	test   %al,%al
 11c:	75 e4                	jne    102 <strcpy+0xd>
    ;
  return os;
 11e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 121:	c9                   	leave  
 122:	c3                   	ret    

00000123 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 126:	eb 06                	jmp    12e <strcmp+0xb>
    p++, q++;
 128:	ff 45 08             	incl   0x8(%ebp)
 12b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 12e:	8b 45 08             	mov    0x8(%ebp),%eax
 131:	8a 00                	mov    (%eax),%al
 133:	84 c0                	test   %al,%al
 135:	74 0e                	je     145 <strcmp+0x22>
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	8a 10                	mov    (%eax),%dl
 13c:	8b 45 0c             	mov    0xc(%ebp),%eax
 13f:	8a 00                	mov    (%eax),%al
 141:	38 c2                	cmp    %al,%dl
 143:	74 e3                	je     128 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	8a 00                	mov    (%eax),%al
 14a:	0f b6 d0             	movzbl %al,%edx
 14d:	8b 45 0c             	mov    0xc(%ebp),%eax
 150:	8a 00                	mov    (%eax),%al
 152:	0f b6 c0             	movzbl %al,%eax
 155:	29 c2                	sub    %eax,%edx
 157:	89 d0                	mov    %edx,%eax
}
 159:	5d                   	pop    %ebp
 15a:	c3                   	ret    

0000015b <strlen>:

uint
strlen(char *s)
{
 15b:	55                   	push   %ebp
 15c:	89 e5                	mov    %esp,%ebp
 15e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 161:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 168:	eb 03                	jmp    16d <strlen+0x12>
 16a:	ff 45 fc             	incl   -0x4(%ebp)
 16d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	01 d0                	add    %edx,%eax
 175:	8a 00                	mov    (%eax),%al
 177:	84 c0                	test   %al,%al
 179:	75 ef                	jne    16a <strlen+0xf>
    ;
  return n;
 17b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17e:	c9                   	leave  
 17f:	c3                   	ret    

00000180 <memset>:

void*
memset(void *dst, int c, uint n)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 186:	8b 45 10             	mov    0x10(%ebp),%eax
 189:	89 44 24 08          	mov    %eax,0x8(%esp)
 18d:	8b 45 0c             	mov    0xc(%ebp),%eax
 190:	89 44 24 04          	mov    %eax,0x4(%esp)
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	89 04 24             	mov    %eax,(%esp)
 19a:	e8 31 ff ff ff       	call   d0 <stosb>
  return dst;
 19f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a2:	c9                   	leave  
 1a3:	c3                   	ret    

000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 04             	sub    $0x4,%esp
 1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ad:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1b0:	eb 12                	jmp    1c4 <strchr+0x20>
    if(*s == c)
 1b2:	8b 45 08             	mov    0x8(%ebp),%eax
 1b5:	8a 00                	mov    (%eax),%al
 1b7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ba:	75 05                	jne    1c1 <strchr+0x1d>
      return (char*)s;
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	eb 11                	jmp    1d2 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1c1:	ff 45 08             	incl   0x8(%ebp)
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	8a 00                	mov    (%eax),%al
 1c9:	84 c0                	test   %al,%al
 1cb:	75 e5                	jne    1b2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d2:	c9                   	leave  
 1d3:	c3                   	ret    

000001d4 <gets>:

char*
gets(char *buf, int max)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e1:	eb 49                	jmp    22c <gets+0x58>
    cc = read(0, &c, 1);
 1e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1ea:	00 
 1eb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1f9:	e8 22 02 00 00       	call   420 <read>
 1fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 201:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 205:	7f 02                	jg     209 <gets+0x35>
      break;
 207:	eb 2c                	jmp    235 <gets+0x61>
    buf[i++] = c;
 209:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20c:	8d 50 01             	lea    0x1(%eax),%edx
 20f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 212:	89 c2                	mov    %eax,%edx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	01 c2                	add    %eax,%edx
 219:	8a 45 ef             	mov    -0x11(%ebp),%al
 21c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 21e:	8a 45 ef             	mov    -0x11(%ebp),%al
 221:	3c 0a                	cmp    $0xa,%al
 223:	74 10                	je     235 <gets+0x61>
 225:	8a 45 ef             	mov    -0x11(%ebp),%al
 228:	3c 0d                	cmp    $0xd,%al
 22a:	74 09                	je     235 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22f:	40                   	inc    %eax
 230:	3b 45 0c             	cmp    0xc(%ebp),%eax
 233:	7c ae                	jl     1e3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 235:	8b 55 f4             	mov    -0xc(%ebp),%edx
 238:	8b 45 08             	mov    0x8(%ebp),%eax
 23b:	01 d0                	add    %edx,%eax
 23d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 240:	8b 45 08             	mov    0x8(%ebp),%eax
}
 243:	c9                   	leave  
 244:	c3                   	ret    

00000245 <stat>:

int
stat(char *n, struct stat *st)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 252:	00 
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	89 04 24             	mov    %eax,(%esp)
 259:	e8 ea 01 00 00       	call   448 <open>
 25e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 261:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 265:	79 07                	jns    26e <stat+0x29>
    return -1;
 267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 26c:	eb 23                	jmp    291 <stat+0x4c>
  r = fstat(fd, st);
 26e:	8b 45 0c             	mov    0xc(%ebp),%eax
 271:	89 44 24 04          	mov    %eax,0x4(%esp)
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	89 04 24             	mov    %eax,(%esp)
 27b:	e8 e0 01 00 00       	call   460 <fstat>
 280:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 283:	8b 45 f4             	mov    -0xc(%ebp),%eax
 286:	89 04 24             	mov    %eax,(%esp)
 289:	e8 a2 01 00 00       	call   430 <close>
  return r;
 28e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 291:	c9                   	leave  
 292:	c3                   	ret    

00000293 <atoi>:

int
atoi(const char *s)
{
 293:	55                   	push   %ebp
 294:	89 e5                	mov    %esp,%ebp
 296:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 299:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2a0:	eb 24                	jmp    2c6 <atoi+0x33>
    n = n*10 + *s++ - '0';
 2a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2a5:	89 d0                	mov    %edx,%eax
 2a7:	c1 e0 02             	shl    $0x2,%eax
 2aa:	01 d0                	add    %edx,%eax
 2ac:	01 c0                	add    %eax,%eax
 2ae:	89 c1                	mov    %eax,%ecx
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	8d 50 01             	lea    0x1(%eax),%edx
 2b6:	89 55 08             	mov    %edx,0x8(%ebp)
 2b9:	8a 00                	mov    (%eax),%al
 2bb:	0f be c0             	movsbl %al,%eax
 2be:	01 c8                	add    %ecx,%eax
 2c0:	83 e8 30             	sub    $0x30,%eax
 2c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	8a 00                	mov    (%eax),%al
 2cb:	3c 2f                	cmp    $0x2f,%al
 2cd:	7e 09                	jle    2d8 <atoi+0x45>
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	8a 00                	mov    (%eax),%al
 2d4:	3c 39                	cmp    $0x39,%al
 2d6:	7e ca                	jle    2a2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2db:	c9                   	leave  
 2dc:	c3                   	ret    

000002dd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ef:	eb 16                	jmp    307 <memmove+0x2a>
    *dst++ = *src++;
 2f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2f4:	8d 50 01             	lea    0x1(%eax),%edx
 2f7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2fd:	8d 4a 01             	lea    0x1(%edx),%ecx
 300:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 303:	8a 12                	mov    (%edx),%dl
 305:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 307:	8b 45 10             	mov    0x10(%ebp),%eax
 30a:	8d 50 ff             	lea    -0x1(%eax),%edx
 30d:	89 55 10             	mov    %edx,0x10(%ebp)
 310:	85 c0                	test   %eax,%eax
 312:	7f dd                	jg     2f1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 314:	8b 45 08             	mov    0x8(%ebp),%eax
}
 317:	c9                   	leave  
 318:	c3                   	ret    

00000319 <itoa>:

int itoa(int value, char *sp, int radix)
{
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
 31c:	53                   	push   %ebx
 31d:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 320:	8d 45 d8             	lea    -0x28(%ebp),%eax
 323:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 326:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 32a:	75 0d                	jne    339 <itoa+0x20>
 32c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 330:	79 07                	jns    339 <itoa+0x20>
 332:	b8 01 00 00 00       	mov    $0x1,%eax
 337:	eb 05                	jmp    33e <itoa+0x25>
 339:	b8 00 00 00 00       	mov    $0x0,%eax
 33e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 341:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 345:	74 0a                	je     351 <itoa+0x38>
      v = -value;
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	f7 d8                	neg    %eax
 34c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 34f:	eb 54                	jmp    3a5 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 357:	eb 4c                	jmp    3a5 <itoa+0x8c>
  {
    i = v % radix;
 359:	8b 4d 10             	mov    0x10(%ebp),%ecx
 35c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 35f:	ba 00 00 00 00       	mov    $0x0,%edx
 364:	f7 f1                	div    %ecx
 366:	89 d0                	mov    %edx,%eax
 368:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 36b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 36e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 371:	ba 00 00 00 00       	mov    $0x0,%edx
 376:	f7 f3                	div    %ebx
 378:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 37b:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 37f:	7f 13                	jg     394 <itoa+0x7b>
      *tp++ = i+'0';
 381:	8b 45 f8             	mov    -0x8(%ebp),%eax
 384:	8d 50 01             	lea    0x1(%eax),%edx
 387:	89 55 f8             	mov    %edx,-0x8(%ebp)
 38a:	8b 55 e8             	mov    -0x18(%ebp),%edx
 38d:	83 c2 30             	add    $0x30,%edx
 390:	88 10                	mov    %dl,(%eax)
 392:	eb 11                	jmp    3a5 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 394:	8b 45 f8             	mov    -0x8(%ebp),%eax
 397:	8d 50 01             	lea    0x1(%eax),%edx
 39a:	89 55 f8             	mov    %edx,-0x8(%ebp)
 39d:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3a0:	83 c2 57             	add    $0x57,%edx
 3a3:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 3a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3a9:	75 ae                	jne    359 <itoa+0x40>
 3ab:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3ae:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3b1:	74 a6                	je     359 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 3b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3b6:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3b9:	29 c2                	sub    %eax,%edx
 3bb:	89 d0                	mov    %edx,%eax
 3bd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 3c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c4:	74 11                	je     3d7 <itoa+0xbe>
  {
    *sp++ = '-';
 3c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c9:	8d 50 01             	lea    0x1(%eax),%edx
 3cc:	89 55 0c             	mov    %edx,0xc(%ebp)
 3cf:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 3d2:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 3d5:	eb 15                	jmp    3ec <itoa+0xd3>
 3d7:	eb 13                	jmp    3ec <itoa+0xd3>
    *sp++ = *--tp;
 3d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dc:	8d 50 01             	lea    0x1(%eax),%edx
 3df:	89 55 0c             	mov    %edx,0xc(%ebp)
 3e2:	ff 4d f8             	decl   -0x8(%ebp)
 3e5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3e8:	8a 12                	mov    (%edx),%dl
 3ea:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 3ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
 3ef:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 3f2:	77 e5                	ja     3d9 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 3f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3f7:	83 c4 30             	add    $0x30,%esp
 3fa:	5b                   	pop    %ebx
 3fb:	5d                   	pop    %ebp
 3fc:	c3                   	ret    
 3fd:	90                   	nop
 3fe:	90                   	nop
 3ff:	90                   	nop

00000400 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 400:	b8 01 00 00 00       	mov    $0x1,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <exit>:
SYSCALL(exit)
 408:	b8 02 00 00 00       	mov    $0x2,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <wait>:
SYSCALL(wait)
 410:	b8 03 00 00 00       	mov    $0x3,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <pipe>:
SYSCALL(pipe)
 418:	b8 04 00 00 00       	mov    $0x4,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <read>:
SYSCALL(read)
 420:	b8 05 00 00 00       	mov    $0x5,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <write>:
SYSCALL(write)
 428:	b8 10 00 00 00       	mov    $0x10,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <close>:
SYSCALL(close)
 430:	b8 15 00 00 00       	mov    $0x15,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <kill>:
SYSCALL(kill)
 438:	b8 06 00 00 00       	mov    $0x6,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <exec>:
SYSCALL(exec)
 440:	b8 07 00 00 00       	mov    $0x7,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <open>:
SYSCALL(open)
 448:	b8 0f 00 00 00       	mov    $0xf,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <mknod>:
SYSCALL(mknod)
 450:	b8 11 00 00 00       	mov    $0x11,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <unlink>:
SYSCALL(unlink)
 458:	b8 12 00 00 00       	mov    $0x12,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <fstat>:
SYSCALL(fstat)
 460:	b8 08 00 00 00       	mov    $0x8,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <link>:
SYSCALL(link)
 468:	b8 13 00 00 00       	mov    $0x13,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <mkdir>:
SYSCALL(mkdir)
 470:	b8 14 00 00 00       	mov    $0x14,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <chdir>:
SYSCALL(chdir)
 478:	b8 09 00 00 00       	mov    $0x9,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <dup>:
SYSCALL(dup)
 480:	b8 0a 00 00 00       	mov    $0xa,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <getpid>:
SYSCALL(getpid)
 488:	b8 0b 00 00 00       	mov    $0xb,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <sbrk>:
SYSCALL(sbrk)
 490:	b8 0c 00 00 00       	mov    $0xc,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <sleep>:
SYSCALL(sleep)
 498:	b8 0d 00 00 00       	mov    $0xd,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <uptime>:
SYSCALL(uptime)
 4a0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <getticks>:
SYSCALL(getticks)
 4a8:	b8 16 00 00 00       	mov    $0x16,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <get_name>:
SYSCALL(get_name)
 4b0:	b8 17 00 00 00       	mov    $0x17,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <get_max_proc>:
SYSCALL(get_max_proc)
 4b8:	b8 18 00 00 00       	mov    $0x18,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <get_max_mem>:
SYSCALL(get_max_mem)
 4c0:	b8 19 00 00 00       	mov    $0x19,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <get_max_disk>:
SYSCALL(get_max_disk)
 4c8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <get_curr_proc>:
SYSCALL(get_curr_proc)
 4d0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <get_curr_mem>:
SYSCALL(get_curr_mem)
 4d8:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <get_curr_disk>:
SYSCALL(get_curr_disk)
 4e0:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <set_name>:
SYSCALL(set_name)
 4e8:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <set_max_mem>:
SYSCALL(set_max_mem)
 4f0:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <set_max_disk>:
SYSCALL(set_max_disk)
 4f8:	b8 20 00 00 00       	mov    $0x20,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <set_max_proc>:
SYSCALL(set_max_proc)
 500:	b8 21 00 00 00       	mov    $0x21,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <set_curr_mem>:
SYSCALL(set_curr_mem)
 508:	b8 22 00 00 00       	mov    $0x22,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <set_curr_disk>:
SYSCALL(set_curr_disk)
 510:	b8 23 00 00 00       	mov    $0x23,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <set_curr_proc>:
SYSCALL(set_curr_proc)
 518:	b8 24 00 00 00       	mov    $0x24,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <find>:
SYSCALL(find)
 520:	b8 25 00 00 00       	mov    $0x25,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <is_full>:
SYSCALL(is_full)
 528:	b8 26 00 00 00       	mov    $0x26,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <container_init>:
SYSCALL(container_init)
 530:	b8 27 00 00 00       	mov    $0x27,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <cont_proc_set>:
SYSCALL(cont_proc_set)
 538:	b8 28 00 00 00       	mov    $0x28,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <ps>:
SYSCALL(ps)
 540:	b8 29 00 00 00       	mov    $0x29,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 548:	b8 2a 00 00 00       	mov    $0x2a,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <set_root_inode>:
SYSCALL(set_root_inode)
 550:	b8 2b 00 00 00       	mov    $0x2b,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <cstop>:
SYSCALL(cstop)
 558:	b8 2c 00 00 00       	mov    $0x2c,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <df>:
SYSCALL(df)
 560:	b8 2d 00 00 00       	mov    $0x2d,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <max_containers>:
SYSCALL(max_containers)
 568:	b8 2e 00 00 00       	mov    $0x2e,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <container_reset>:
SYSCALL(container_reset)
 570:	b8 2f 00 00 00       	mov    $0x2f,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <pause>:
SYSCALL(pause)
 578:	b8 30 00 00 00       	mov    $0x30,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <resume>:
SYSCALL(resume)
 580:	b8 31 00 00 00       	mov    $0x31,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <tmem>:
SYSCALL(tmem)
 588:	b8 32 00 00 00       	mov    $0x32,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <amem>:
SYSCALL(amem)
 590:	b8 33 00 00 00       	mov    $0x33,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <c_ps>:
SYSCALL(c_ps)
 598:	b8 34 00 00 00       	mov    $0x34,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <get_used>:
SYSCALL(get_used)
 5a0:	b8 35 00 00 00       	mov    $0x35,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <get_os>:
SYSCALL(get_os)
 5a8:	b8 36 00 00 00       	mov    $0x36,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <set_os>:
SYSCALL(set_os)
 5b0:	b8 37 00 00 00       	mov    $0x37,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5b8:	55                   	push   %ebp
 5b9:	89 e5                	mov    %esp,%ebp
 5bb:	83 ec 18             	sub    $0x18,%esp
 5be:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5cb:	00 
 5cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	89 04 24             	mov    %eax,(%esp)
 5d9:	e8 4a fe ff ff       	call   428 <write>
}
 5de:	c9                   	leave  
 5df:	c3                   	ret    

000005e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	56                   	push   %esi
 5e4:	53                   	push   %ebx
 5e5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5f3:	74 17                	je     60c <printint+0x2c>
 5f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f9:	79 11                	jns    60c <printint+0x2c>
    neg = 1;
 5fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 602:	8b 45 0c             	mov    0xc(%ebp),%eax
 605:	f7 d8                	neg    %eax
 607:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60a:	eb 06                	jmp    612 <printint+0x32>
  } else {
    x = xx;
 60c:	8b 45 0c             	mov    0xc(%ebp),%eax
 60f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 619:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 61c:	8d 41 01             	lea    0x1(%ecx),%eax
 61f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 622:	8b 5d 10             	mov    0x10(%ebp),%ebx
 625:	8b 45 ec             	mov    -0x14(%ebp),%eax
 628:	ba 00 00 00 00       	mov    $0x0,%edx
 62d:	f7 f3                	div    %ebx
 62f:	89 d0                	mov    %edx,%eax
 631:	8a 80 8c 0d 00 00    	mov    0xd8c(%eax),%al
 637:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 63b:	8b 75 10             	mov    0x10(%ebp),%esi
 63e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 641:	ba 00 00 00 00       	mov    $0x0,%edx
 646:	f7 f6                	div    %esi
 648:	89 45 ec             	mov    %eax,-0x14(%ebp)
 64b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64f:	75 c8                	jne    619 <printint+0x39>
  if(neg)
 651:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 655:	74 10                	je     667 <printint+0x87>
    buf[i++] = '-';
 657:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65a:	8d 50 01             	lea    0x1(%eax),%edx
 65d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 660:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 665:	eb 1e                	jmp    685 <printint+0xa5>
 667:	eb 1c                	jmp    685 <printint+0xa5>
    putc(fd, buf[i]);
 669:	8d 55 dc             	lea    -0x24(%ebp),%edx
 66c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66f:	01 d0                	add    %edx,%eax
 671:	8a 00                	mov    (%eax),%al
 673:	0f be c0             	movsbl %al,%eax
 676:	89 44 24 04          	mov    %eax,0x4(%esp)
 67a:	8b 45 08             	mov    0x8(%ebp),%eax
 67d:	89 04 24             	mov    %eax,(%esp)
 680:	e8 33 ff ff ff       	call   5b8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 685:	ff 4d f4             	decl   -0xc(%ebp)
 688:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68c:	79 db                	jns    669 <printint+0x89>
    putc(fd, buf[i]);
}
 68e:	83 c4 30             	add    $0x30,%esp
 691:	5b                   	pop    %ebx
 692:	5e                   	pop    %esi
 693:	5d                   	pop    %ebp
 694:	c3                   	ret    

00000695 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 695:	55                   	push   %ebp
 696:	89 e5                	mov    %esp,%ebp
 698:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 69b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6a2:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a5:	83 c0 04             	add    $0x4,%eax
 6a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6b2:	e9 77 01 00 00       	jmp    82e <printf+0x199>
    c = fmt[i] & 0xff;
 6b7:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bd:	01 d0                	add    %edx,%eax
 6bf:	8a 00                	mov    (%eax),%al
 6c1:	0f be c0             	movsbl %al,%eax
 6c4:	25 ff 00 00 00       	and    $0xff,%eax
 6c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d0:	75 2c                	jne    6fe <printf+0x69>
      if(c == '%'){
 6d2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d6:	75 0c                	jne    6e4 <printf+0x4f>
        state = '%';
 6d8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6df:	e9 47 01 00 00       	jmp    82b <printf+0x196>
      } else {
        putc(fd, c);
 6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	89 04 24             	mov    %eax,(%esp)
 6f4:	e8 bf fe ff ff       	call   5b8 <putc>
 6f9:	e9 2d 01 00 00       	jmp    82b <printf+0x196>
      }
    } else if(state == '%'){
 6fe:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 702:	0f 85 23 01 00 00    	jne    82b <printf+0x196>
      if(c == 'd'){
 708:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 70c:	75 2d                	jne    73b <printf+0xa6>
        printint(fd, *ap, 10, 1);
 70e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 711:	8b 00                	mov    (%eax),%eax
 713:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 71a:	00 
 71b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 722:	00 
 723:	89 44 24 04          	mov    %eax,0x4(%esp)
 727:	8b 45 08             	mov    0x8(%ebp),%eax
 72a:	89 04 24             	mov    %eax,(%esp)
 72d:	e8 ae fe ff ff       	call   5e0 <printint>
        ap++;
 732:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 736:	e9 e9 00 00 00       	jmp    824 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 73b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 73f:	74 06                	je     747 <printf+0xb2>
 741:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 745:	75 2d                	jne    774 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 747:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74a:	8b 00                	mov    (%eax),%eax
 74c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 753:	00 
 754:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 75b:	00 
 75c:	89 44 24 04          	mov    %eax,0x4(%esp)
 760:	8b 45 08             	mov    0x8(%ebp),%eax
 763:	89 04 24             	mov    %eax,(%esp)
 766:	e8 75 fe ff ff       	call   5e0 <printint>
        ap++;
 76b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76f:	e9 b0 00 00 00       	jmp    824 <printf+0x18f>
      } else if(c == 's'){
 774:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 778:	75 42                	jne    7bc <printf+0x127>
        s = (char*)*ap;
 77a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77d:	8b 00                	mov    (%eax),%eax
 77f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 782:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 786:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78a:	75 09                	jne    795 <printf+0x100>
          s = "(null)";
 78c:	c7 45 f4 0c 0b 00 00 	movl   $0xb0c,-0xc(%ebp)
        while(*s != 0){
 793:	eb 1c                	jmp    7b1 <printf+0x11c>
 795:	eb 1a                	jmp    7b1 <printf+0x11c>
          putc(fd, *s);
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	8a 00                	mov    (%eax),%al
 79c:	0f be c0             	movsbl %al,%eax
 79f:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a3:	8b 45 08             	mov    0x8(%ebp),%eax
 7a6:	89 04 24             	mov    %eax,(%esp)
 7a9:	e8 0a fe ff ff       	call   5b8 <putc>
          s++;
 7ae:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8a 00                	mov    (%eax),%al
 7b6:	84 c0                	test   %al,%al
 7b8:	75 dd                	jne    797 <printf+0x102>
 7ba:	eb 68                	jmp    824 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7bc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c0:	75 1d                	jne    7df <printf+0x14a>
        putc(fd, *ap);
 7c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c5:	8b 00                	mov    (%eax),%eax
 7c7:	0f be c0             	movsbl %al,%eax
 7ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ce:	8b 45 08             	mov    0x8(%ebp),%eax
 7d1:	89 04 24             	mov    %eax,(%esp)
 7d4:	e8 df fd ff ff       	call   5b8 <putc>
        ap++;
 7d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7dd:	eb 45                	jmp    824 <printf+0x18f>
      } else if(c == '%'){
 7df:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e3:	75 17                	jne    7fc <printf+0x167>
        putc(fd, c);
 7e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e8:	0f be c0             	movsbl %al,%eax
 7eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ef:	8b 45 08             	mov    0x8(%ebp),%eax
 7f2:	89 04 24             	mov    %eax,(%esp)
 7f5:	e8 be fd ff ff       	call   5b8 <putc>
 7fa:	eb 28                	jmp    824 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7fc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 803:	00 
 804:	8b 45 08             	mov    0x8(%ebp),%eax
 807:	89 04 24             	mov    %eax,(%esp)
 80a:	e8 a9 fd ff ff       	call   5b8 <putc>
        putc(fd, c);
 80f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 812:	0f be c0             	movsbl %al,%eax
 815:	89 44 24 04          	mov    %eax,0x4(%esp)
 819:	8b 45 08             	mov    0x8(%ebp),%eax
 81c:	89 04 24             	mov    %eax,(%esp)
 81f:	e8 94 fd ff ff       	call   5b8 <putc>
      }
      state = 0;
 824:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 82b:	ff 45 f0             	incl   -0x10(%ebp)
 82e:	8b 55 0c             	mov    0xc(%ebp),%edx
 831:	8b 45 f0             	mov    -0x10(%ebp),%eax
 834:	01 d0                	add    %edx,%eax
 836:	8a 00                	mov    (%eax),%al
 838:	84 c0                	test   %al,%al
 83a:	0f 85 77 fe ff ff    	jne    6b7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 840:	c9                   	leave  
 841:	c3                   	ret    
 842:	90                   	nop
 843:	90                   	nop

00000844 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 844:	55                   	push   %ebp
 845:	89 e5                	mov    %esp,%ebp
 847:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84a:	8b 45 08             	mov    0x8(%ebp),%eax
 84d:	83 e8 08             	sub    $0x8,%eax
 850:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 853:	a1 a8 0d 00 00       	mov    0xda8,%eax
 858:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85b:	eb 24                	jmp    881 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	8b 00                	mov    (%eax),%eax
 862:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 865:	77 12                	ja     879 <free+0x35>
 867:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86d:	77 24                	ja     893 <free+0x4f>
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	8b 00                	mov    (%eax),%eax
 874:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 877:	77 1a                	ja     893 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 881:	8b 45 f8             	mov    -0x8(%ebp),%eax
 884:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 887:	76 d4                	jbe    85d <free+0x19>
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	8b 00                	mov    (%eax),%eax
 88e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 891:	76 ca                	jbe    85d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 893:	8b 45 f8             	mov    -0x8(%ebp),%eax
 896:	8b 40 04             	mov    0x4(%eax),%eax
 899:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	01 c2                	add    %eax,%edx
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	39 c2                	cmp    %eax,%edx
 8ac:	75 24                	jne    8d2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b1:	8b 50 04             	mov    0x4(%eax),%edx
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	8b 40 04             	mov    0x4(%eax),%eax
 8bc:	01 c2                	add    %eax,%edx
 8be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	8b 10                	mov    (%eax),%edx
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	89 10                	mov    %edx,(%eax)
 8d0:	eb 0a                	jmp    8dc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d5:	8b 10                	mov    (%eax),%edx
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 40 04             	mov    0x4(%eax),%eax
 8e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	01 d0                	add    %edx,%eax
 8ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f1:	75 20                	jne    913 <free+0xcf>
    p->s.size += bp->s.size;
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	8b 50 04             	mov    0x4(%eax),%edx
 8f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fc:	8b 40 04             	mov    0x4(%eax),%eax
 8ff:	01 c2                	add    %eax,%edx
 901:	8b 45 fc             	mov    -0x4(%ebp),%eax
 904:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	8b 10                	mov    (%eax),%edx
 90c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90f:	89 10                	mov    %edx,(%eax)
 911:	eb 08                	jmp    91b <free+0xd7>
  } else
    p->s.ptr = bp;
 913:	8b 45 fc             	mov    -0x4(%ebp),%eax
 916:	8b 55 f8             	mov    -0x8(%ebp),%edx
 919:	89 10                	mov    %edx,(%eax)
  freep = p;
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	a3 a8 0d 00 00       	mov    %eax,0xda8
}
 923:	c9                   	leave  
 924:	c3                   	ret    

00000925 <morecore>:

static Header*
morecore(uint nu)
{
 925:	55                   	push   %ebp
 926:	89 e5                	mov    %esp,%ebp
 928:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 92b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 932:	77 07                	ja     93b <morecore+0x16>
    nu = 4096;
 934:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 93b:	8b 45 08             	mov    0x8(%ebp),%eax
 93e:	c1 e0 03             	shl    $0x3,%eax
 941:	89 04 24             	mov    %eax,(%esp)
 944:	e8 47 fb ff ff       	call   490 <sbrk>
 949:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 94c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 950:	75 07                	jne    959 <morecore+0x34>
    return 0;
 952:	b8 00 00 00 00       	mov    $0x0,%eax
 957:	eb 22                	jmp    97b <morecore+0x56>
  hp = (Header*)p;
 959:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 95f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 962:	8b 55 08             	mov    0x8(%ebp),%edx
 965:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 968:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96b:	83 c0 08             	add    $0x8,%eax
 96e:	89 04 24             	mov    %eax,(%esp)
 971:	e8 ce fe ff ff       	call   844 <free>
  return freep;
 976:	a1 a8 0d 00 00       	mov    0xda8,%eax
}
 97b:	c9                   	leave  
 97c:	c3                   	ret    

0000097d <malloc>:

void*
malloc(uint nbytes)
{
 97d:	55                   	push   %ebp
 97e:	89 e5                	mov    %esp,%ebp
 980:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 983:	8b 45 08             	mov    0x8(%ebp),%eax
 986:	83 c0 07             	add    $0x7,%eax
 989:	c1 e8 03             	shr    $0x3,%eax
 98c:	40                   	inc    %eax
 98d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 990:	a1 a8 0d 00 00       	mov    0xda8,%eax
 995:	89 45 f0             	mov    %eax,-0x10(%ebp)
 998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 99c:	75 23                	jne    9c1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 99e:	c7 45 f0 a0 0d 00 00 	movl   $0xda0,-0x10(%ebp)
 9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a8:	a3 a8 0d 00 00       	mov    %eax,0xda8
 9ad:	a1 a8 0d 00 00       	mov    0xda8,%eax
 9b2:	a3 a0 0d 00 00       	mov    %eax,0xda0
    base.s.size = 0;
 9b7:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
 9be:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c4:	8b 00                	mov    (%eax),%eax
 9c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cc:	8b 40 04             	mov    0x4(%eax),%eax
 9cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d2:	72 4d                	jb     a21 <malloc+0xa4>
      if(p->s.size == nunits)
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	8b 40 04             	mov    0x4(%eax),%eax
 9da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9dd:	75 0c                	jne    9eb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 9df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e2:	8b 10                	mov    (%eax),%edx
 9e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e7:	89 10                	mov    %edx,(%eax)
 9e9:	eb 26                	jmp    a11 <malloc+0x94>
      else {
        p->s.size -= nunits;
 9eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ee:	8b 40 04             	mov    0x4(%eax),%eax
 9f1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9f4:	89 c2                	mov    %eax,%edx
 9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 40 04             	mov    0x4(%eax),%eax
 a02:	c1 e0 03             	shl    $0x3,%eax
 a05:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a0e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a14:	a3 a8 0d 00 00       	mov    %eax,0xda8
      return (void*)(p + 1);
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	83 c0 08             	add    $0x8,%eax
 a1f:	eb 38                	jmp    a59 <malloc+0xdc>
    }
    if(p == freep)
 a21:	a1 a8 0d 00 00       	mov    0xda8,%eax
 a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a29:	75 1b                	jne    a46 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 a2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a2e:	89 04 24             	mov    %eax,(%esp)
 a31:	e8 ef fe ff ff       	call   925 <morecore>
 a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a3d:	75 07                	jne    a46 <malloc+0xc9>
        return 0;
 a3f:	b8 00 00 00 00       	mov    $0x0,%eax
 a44:	eb 13                	jmp    a59 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	8b 00                	mov    (%eax),%eax
 a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a54:	e9 70 ff ff ff       	jmp    9c9 <malloc+0x4c>
}
 a59:	c9                   	leave  
 a5a:	c3                   	ret    
