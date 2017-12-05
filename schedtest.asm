
_schedtest:     file format elf32-i386


Disassembly of section .text:

00000000 <setchildname>:
  int fds[2];
};

void
setchildname(char *filename, int i)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  strcpy(filename, "Child:");
   6:	c7 44 24 04 e0 0c 00 	movl   $0xce0,0x4(%esp)
   d:	00 
   e:	8b 45 08             	mov    0x8(%ebp),%eax
  11:	89 04 24             	mov    %eax,(%esp)
  14:	e8 60 03 00 00       	call   379 <strcpy>
  itoa(i, &filename[6], 10);
  19:	8b 45 08             	mov    0x8(%ebp),%eax
  1c:	83 c0 06             	add    $0x6,%eax
  1f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
  26:	00 
  27:	89 44 24 04          	mov    %eax,0x4(%esp)
  2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  2e:	89 04 24             	mov    %eax,(%esp)
  31:	e8 67 05 00 00       	call   59d <itoa>
}
  36:	c9                   	leave  
  37:	c3                   	ret    

00000038 <sched_child>:

void
sched_child(struct child_info *ci, int child_num, uint wall_ticks, uint end_ticks)
{
  38:	55                   	push   %ebp
  39:	89 e5                	mov    %esp,%ebp
  3b:	83 ec 18             	sub    $0x18,%esp
  setchildname(ci->name, child_num);
  3e:	8b 45 08             	mov    0x8(%ebp),%eax
  41:	8b 55 0c             	mov    0xc(%ebp),%edx
  44:	89 54 24 04          	mov    %edx,0x4(%esp)
  48:	89 04 24             	mov    %eax,(%esp)
  4b:	e8 b0 ff ff ff       	call   0 <setchildname>
  while(uptime() < end_ticks) {
  50:	90                   	nop
  51:	e8 ce 06 00 00       	call   724 <uptime>
  56:	3b 45 14             	cmp    0x14(%ebp),%eax
  59:	72 f6                	jb     51 <sched_child+0x19>
    ;    
  }
  ci->ticks = getticks();
  5b:	e8 cc 06 00 00       	call   72c <getticks>
  60:	89 c2                	mov    %eax,%edx
  62:	8b 45 08             	mov    0x8(%ebp),%eax
  65:	89 50 10             	mov    %edx,0x10(%eax)
}
  68:	c9                   	leave  
  69:	c3                   	ret    

0000006a <main>:

int
main(int argc, char *argv[])
{
  6a:	55                   	push   %ebp
  6b:	89 e5                	mov    %esp,%ebp
  6d:	56                   	push   %esi
  6e:	53                   	push   %ebx
  6f:	83 e4 f0             	and    $0xfffffff0,%esp
  72:	81 ec 50 01 00 00    	sub    $0x150,%esp
  int i;
  int id;
  int nprocs = 0;
  78:	c7 84 24 48 01 00 00 	movl   $0x0,0x148(%esp)
  7f:	00 00 00 00 
  uint wall_ticks = 0;
  83:	c7 84 24 44 01 00 00 	movl   $0x0,0x144(%esp)
  8a:	00 00 00 00 
  uint start_ticks = 0;
  8e:	c7 84 24 40 01 00 00 	movl   $0x0,0x140(%esp)
  95:	00 00 00 00 
  uint end_ticks = 0;
  99:	c7 84 24 3c 01 00 00 	movl   $0x0,0x13c(%esp)
  a0:	00 00 00 00 
  struct child_info child_infos[MAX_PROCS];
  struct child_pipe child_pipes[MAX_PROCS];

  if (argc != 3) {
  a4:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  a8:	74 19                	je     c3 <main+0x59>
    printf(1, "usage: schedtest <num_procs> <wall_ticks>\n");
  aa:	c7 44 24 04 e8 0c 00 	movl   $0xce8,0x4(%esp)
  b1:	00 
  b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b9:	e8 5b 08 00 00       	call   919 <printf>
    exit();
  be:	e8 c9 05 00 00       	call   68c <exit>
  }

  nprocs = atoi(argv[1]);
  c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  c6:	83 c0 04             	add    $0x4,%eax
  c9:	8b 00                	mov    (%eax),%eax
  cb:	89 04 24             	mov    %eax,(%esp)
  ce:	e8 44 04 00 00       	call   517 <atoi>
  d3:	89 84 24 48 01 00 00 	mov    %eax,0x148(%esp)

  if (nprocs >= MAX_PROCS) {
  da:	83 bc 24 48 01 00 00 	cmpl   $0x9,0x148(%esp)
  e1:	09 
  e2:	7e 21                	jle    105 <main+0x9b>
    printf(1, "%d procs maximum, exiting\n", MAX_PROCS);
  e4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
  eb:	00 
  ec:	c7 44 24 04 13 0d 00 	movl   $0xd13,0x4(%esp)
  f3:	00 
  f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fb:	e8 19 08 00 00       	call   919 <printf>
    exit();
 100:	e8 87 05 00 00       	call   68c <exit>
  }

  wall_ticks = atoi(argv[2]);
 105:	8b 45 0c             	mov    0xc(%ebp),%eax
 108:	83 c0 08             	add    $0x8,%eax
 10b:	8b 00                	mov    (%eax),%eax
 10d:	89 04 24             	mov    %eax,(%esp)
 110:	e8 02 04 00 00       	call   517 <atoi>
 115:	89 84 24 44 01 00 00 	mov    %eax,0x144(%esp)
  start_ticks = uptime();
 11c:	e8 03 06 00 00       	call   724 <uptime>
 121:	89 84 24 40 01 00 00 	mov    %eax,0x140(%esp)
  end_ticks = start_ticks + wall_ticks;
 128:	8b 84 24 44 01 00 00 	mov    0x144(%esp),%eax
 12f:	8b 94 24 40 01 00 00 	mov    0x140(%esp),%edx
 136:	01 d0                	add    %edx,%eax
 138:	89 84 24 3c 01 00 00 	mov    %eax,0x13c(%esp)

  printf(1, "schedtest: started\n");
 13f:	c7 44 24 04 2e 0d 00 	movl   $0xd2e,0x4(%esp)
 146:	00 
 147:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 14e:	e8 c6 07 00 00       	call   919 <printf>

  /* Create 1 pipe for each child */
  for (i = 0; i < nprocs; i++) {
 153:	c7 84 24 4c 01 00 00 	movl   $0x0,0x14c(%esp)
 15a:	00 00 00 00 
 15e:	eb 1f                	jmp    17f <main+0x115>
    pipe(child_pipes[i].fds);
 160:	8d 44 24 20          	lea    0x20(%esp),%eax
 164:	8b 94 24 4c 01 00 00 	mov    0x14c(%esp),%edx
 16b:	c1 e2 03             	shl    $0x3,%edx
 16e:	01 d0                	add    %edx,%eax
 170:	89 04 24             	mov    %eax,(%esp)
 173:	e8 24 05 00 00       	call   69c <pipe>
  end_ticks = start_ticks + wall_ticks;

  printf(1, "schedtest: started\n");

  /* Create 1 pipe for each child */
  for (i = 0; i < nprocs; i++) {
 178:	ff 84 24 4c 01 00 00 	incl   0x14c(%esp)
 17f:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 186:	3b 84 24 48 01 00 00 	cmp    0x148(%esp),%eax
 18d:	7c d1                	jl     160 <main+0xf6>
    pipe(child_pipes[i].fds);
  }

  /* Start the children */
  for (i = 0; i < nprocs; i++) {
 18f:	c7 84 24 4c 01 00 00 	movl   $0x0,0x14c(%esp)
 196:	00 00 00 00 
 19a:	e9 9a 00 00 00       	jmp    239 <main+0x1cf>
    id = fork();
 19f:	e8 e0 04 00 00       	call   684 <fork>
 1a4:	89 84 24 38 01 00 00 	mov    %eax,0x138(%esp)
    if (id == 0) {
 1ab:	83 bc 24 38 01 00 00 	cmpl   $0x0,0x138(%esp)
 1b2:	00 
 1b3:	75 7d                	jne    232 <main+0x1c8>
      sched_child(&child_infos[i], i, wall_ticks, end_ticks);
 1b5:	8d 4c 24 70          	lea    0x70(%esp),%ecx
 1b9:	8b 94 24 4c 01 00 00 	mov    0x14c(%esp),%edx
 1c0:	89 d0                	mov    %edx,%eax
 1c2:	c1 e0 02             	shl    $0x2,%eax
 1c5:	01 d0                	add    %edx,%eax
 1c7:	c1 e0 02             	shl    $0x2,%eax
 1ca:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 1cd:	8b 84 24 3c 01 00 00 	mov    0x13c(%esp),%eax
 1d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
 1d8:	8b 84 24 44 01 00 00 	mov    0x144(%esp),%eax
 1df:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e3:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 1ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ee:	89 14 24             	mov    %edx,(%esp)
 1f1:	e8 42 fe ff ff       	call   38 <sched_child>
      /* Send child_info stats back to parent */
      write(child_pipes[i].fds[1], (void *) &child_infos[i], sizeof(struct child_info));
 1f6:	8d 4c 24 70          	lea    0x70(%esp),%ecx
 1fa:	8b 94 24 4c 01 00 00 	mov    0x14c(%esp),%edx
 201:	89 d0                	mov    %edx,%eax
 203:	c1 e0 02             	shl    $0x2,%eax
 206:	01 d0                	add    %edx,%eax
 208:	c1 e0 02             	shl    $0x2,%eax
 20b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 20e:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 215:	8b 44 c4 24          	mov    0x24(%esp,%eax,8),%eax
 219:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
 220:	00 
 221:	89 54 24 04          	mov    %edx,0x4(%esp)
 225:	89 04 24             	mov    %eax,(%esp)
 228:	e8 7f 04 00 00       	call   6ac <write>
      exit();
 22d:	e8 5a 04 00 00       	call   68c <exit>
  for (i = 0; i < nprocs; i++) {
    pipe(child_pipes[i].fds);
  }

  /* Start the children */
  for (i = 0; i < nprocs; i++) {
 232:	ff 84 24 4c 01 00 00 	incl   0x14c(%esp)
 239:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 240:	3b 84 24 48 01 00 00 	cmp    0x148(%esp),%eax
 247:	0f 8c 52 ff ff ff    	jl     19f <main+0x135>
      exit();
    }
  }

  /* Wait for childern to exit() */
  for (i = 0; i < nprocs; i++) {
 24d:	c7 84 24 4c 01 00 00 	movl   $0x0,0x14c(%esp)
 254:	00 00 00 00 
 258:	eb 0c                	jmp    266 <main+0x1fc>
    wait();
 25a:	e8 35 04 00 00       	call   694 <wait>
      exit();
    }
  }

  /* Wait for childern to exit() */
  for (i = 0; i < nprocs; i++) {
 25f:	ff 84 24 4c 01 00 00 	incl   0x14c(%esp)
 266:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 26d:	3b 84 24 48 01 00 00 	cmp    0x148(%esp),%eax
 274:	7c e4                	jl     25a <main+0x1f0>
    wait();
  }

  /* Print run time statistics. */
  for (i = 0; i < nprocs; i++) {
 276:	c7 84 24 4c 01 00 00 	movl   $0x0,0x14c(%esp)
 27d:	00 00 00 00 
 281:	e9 9e 00 00 00       	jmp    324 <main+0x2ba>
    read(child_pipes[i].fds[0], (void *) &child_infos[i], sizeof(struct child_info));
 286:	8d 4c 24 70          	lea    0x70(%esp),%ecx
 28a:	8b 94 24 4c 01 00 00 	mov    0x14c(%esp),%edx
 291:	89 d0                	mov    %edx,%eax
 293:	c1 e0 02             	shl    $0x2,%eax
 296:	01 d0                	add    %edx,%eax
 298:	c1 e0 02             	shl    $0x2,%eax
 29b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
 29e:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 2a5:	8b 44 c4 20          	mov    0x20(%esp,%eax,8),%eax
 2a9:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
 2b0:	00 
 2b1:	89 54 24 04          	mov    %edx,0x4(%esp)
 2b5:	89 04 24             	mov    %eax,(%esp)
 2b8:	e8 e7 03 00 00       	call   6a4 <read>
    printf(1, "Process [%s] ran for %d ticks out of %d total ticks\n",
 2bd:	8b 94 24 4c 01 00 00 	mov    0x14c(%esp),%edx
 2c4:	89 d0                	mov    %edx,%eax
 2c6:	c1 e0 02             	shl    $0x2,%eax
 2c9:	01 d0                	add    %edx,%eax
 2cb:	c1 e0 02             	shl    $0x2,%eax
 2ce:	8d b4 24 50 01 00 00 	lea    0x150(%esp),%esi
 2d5:	01 f0                	add    %esi,%eax
 2d7:	2d d0 00 00 00       	sub    $0xd0,%eax
 2dc:	8b 10                	mov    (%eax),%edx
           child_infos[i].name, child_infos[i].ticks, wall_ticks);
 2de:	8d 5c 24 70          	lea    0x70(%esp),%ebx
 2e2:	8b 8c 24 4c 01 00 00 	mov    0x14c(%esp),%ecx
 2e9:	89 c8                	mov    %ecx,%eax
 2eb:	c1 e0 02             	shl    $0x2,%eax
 2ee:	01 c8                	add    %ecx,%eax
 2f0:	c1 e0 02             	shl    $0x2,%eax
 2f3:	8d 0c 03             	lea    (%ebx,%eax,1),%ecx
  }

  /* Print run time statistics. */
  for (i = 0; i < nprocs; i++) {
    read(child_pipes[i].fds[0], (void *) &child_infos[i], sizeof(struct child_info));
    printf(1, "Process [%s] ran for %d ticks out of %d total ticks\n",
 2f6:	8b 84 24 44 01 00 00 	mov    0x144(%esp),%eax
 2fd:	89 44 24 10          	mov    %eax,0x10(%esp)
 301:	89 54 24 0c          	mov    %edx,0xc(%esp)
 305:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 309:	c7 44 24 04 44 0d 00 	movl   $0xd44,0x4(%esp)
 310:	00 
 311:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 318:	e8 fc 05 00 00       	call   919 <printf>
  for (i = 0; i < nprocs; i++) {
    wait();
  }

  /* Print run time statistics. */
  for (i = 0; i < nprocs; i++) {
 31d:	ff 84 24 4c 01 00 00 	incl   0x14c(%esp)
 324:	8b 84 24 4c 01 00 00 	mov    0x14c(%esp),%eax
 32b:	3b 84 24 48 01 00 00 	cmp    0x148(%esp),%eax
 332:	0f 8c 4e ff ff ff    	jl     286 <main+0x21c>
    read(child_pipes[i].fds[0], (void *) &child_infos[i], sizeof(struct child_info));
    printf(1, "Process [%s] ran for %d ticks out of %d total ticks\n",
           child_infos[i].name, child_infos[i].ticks, wall_ticks);
  }

  printf(1, "schedtest: finished\n");
 338:	c7 44 24 04 79 0d 00 	movl   $0xd79,0x4(%esp)
 33f:	00 
 340:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 347:	e8 cd 05 00 00       	call   919 <printf>
  exit();
 34c:	e8 3b 03 00 00       	call   68c <exit>
 351:	90                   	nop
 352:	90                   	nop
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
 47d:	e8 22 02 00 00       	call   6a4 <read>
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
 4dd:	e8 ea 01 00 00       	call   6cc <open>
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
 4ff:	e8 e0 01 00 00       	call   6e4 <fstat>
 504:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 507:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50a:	89 04 24             	mov    %eax,(%esp)
 50d:	e8 a2 01 00 00       	call   6b4 <close>
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

0000059d <itoa>:

int itoa(int value, char *sp, int radix)
{
 59d:	55                   	push   %ebp
 59e:	89 e5                	mov    %esp,%ebp
 5a0:	53                   	push   %ebx
 5a1:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
 5a4:	8d 45 d8             	lea    -0x28(%ebp),%eax
 5a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
 5aa:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
 5ae:	75 0d                	jne    5bd <itoa+0x20>
 5b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 5b4:	79 07                	jns    5bd <itoa+0x20>
 5b6:	b8 01 00 00 00       	mov    $0x1,%eax
 5bb:	eb 05                	jmp    5c2 <itoa+0x25>
 5bd:	b8 00 00 00 00       	mov    $0x0,%eax
 5c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
 5c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c9:	74 0a                	je     5d5 <itoa+0x38>
      v = -value;
 5cb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ce:	f7 d8                	neg    %eax
 5d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 5d3:	eb 54                	jmp    629 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
 5db:	eb 4c                	jmp    629 <itoa+0x8c>
  {
    i = v % radix;
 5dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e3:	ba 00 00 00 00       	mov    $0x0,%edx
 5e8:	f7 f1                	div    %ecx
 5ea:	89 d0                	mov    %edx,%eax
 5ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
 5ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f5:	ba 00 00 00 00       	mov    $0x0,%edx
 5fa:	f7 f3                	div    %ebx
 5fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
 5ff:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 603:	7f 13                	jg     618 <itoa+0x7b>
      *tp++ = i+'0';
 605:	8b 45 f8             	mov    -0x8(%ebp),%eax
 608:	8d 50 01             	lea    0x1(%eax),%edx
 60b:	89 55 f8             	mov    %edx,-0x8(%ebp)
 60e:	8b 55 e8             	mov    -0x18(%ebp),%edx
 611:	83 c2 30             	add    $0x30,%edx
 614:	88 10                	mov    %dl,(%eax)
 616:	eb 11                	jmp    629 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
 618:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61b:	8d 50 01             	lea    0x1(%eax),%edx
 61e:	89 55 f8             	mov    %edx,-0x8(%ebp)
 621:	8b 55 e8             	mov    -0x18(%ebp),%edx
 624:	83 c2 57             	add    $0x57,%edx
 627:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
 629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62d:	75 ae                	jne    5dd <itoa+0x40>
 62f:	8d 45 d8             	lea    -0x28(%ebp),%eax
 632:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 635:	74 a6                	je     5dd <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
 637:	8b 55 f8             	mov    -0x8(%ebp),%edx
 63a:	8d 45 d8             	lea    -0x28(%ebp),%eax
 63d:	29 c2                	sub    %eax,%edx
 63f:	89 d0                	mov    %edx,%eax
 641:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
 644:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 648:	74 11                	je     65b <itoa+0xbe>
  {
    *sp++ = '-';
 64a:	8b 45 0c             	mov    0xc(%ebp),%eax
 64d:	8d 50 01             	lea    0x1(%eax),%edx
 650:	89 55 0c             	mov    %edx,0xc(%ebp)
 653:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
 656:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
 659:	eb 15                	jmp    670 <itoa+0xd3>
 65b:	eb 13                	jmp    670 <itoa+0xd3>
    *sp++ = *--tp;
 65d:	8b 45 0c             	mov    0xc(%ebp),%eax
 660:	8d 50 01             	lea    0x1(%eax),%edx
 663:	89 55 0c             	mov    %edx,0xc(%ebp)
 666:	ff 4d f8             	decl   -0x8(%ebp)
 669:	8b 55 f8             	mov    -0x8(%ebp),%edx
 66c:	8a 12                	mov    (%edx),%dl
 66e:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
 670:	8d 45 d8             	lea    -0x28(%ebp),%eax
 673:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 676:	77 e5                	ja     65d <itoa+0xc0>
    *sp++ = *--tp;

  return len;
 678:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 67b:	83 c4 30             	add    $0x30,%esp
 67e:	5b                   	pop    %ebx
 67f:	5d                   	pop    %ebp
 680:	c3                   	ret    
 681:	90                   	nop
 682:	90                   	nop
 683:	90                   	nop

00000684 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 684:	b8 01 00 00 00       	mov    $0x1,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <exit>:
SYSCALL(exit)
 68c:	b8 02 00 00 00       	mov    $0x2,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <wait>:
SYSCALL(wait)
 694:	b8 03 00 00 00       	mov    $0x3,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	ret    

0000069c <pipe>:
SYSCALL(pipe)
 69c:	b8 04 00 00 00       	mov    $0x4,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	ret    

000006a4 <read>:
SYSCALL(read)
 6a4:	b8 05 00 00 00       	mov    $0x5,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	ret    

000006ac <write>:
SYSCALL(write)
 6ac:	b8 10 00 00 00       	mov    $0x10,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	ret    

000006b4 <close>:
SYSCALL(close)
 6b4:	b8 15 00 00 00       	mov    $0x15,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	ret    

000006bc <kill>:
SYSCALL(kill)
 6bc:	b8 06 00 00 00       	mov    $0x6,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	ret    

000006c4 <exec>:
SYSCALL(exec)
 6c4:	b8 07 00 00 00       	mov    $0x7,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	ret    

000006cc <open>:
SYSCALL(open)
 6cc:	b8 0f 00 00 00       	mov    $0xf,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	ret    

000006d4 <mknod>:
SYSCALL(mknod)
 6d4:	b8 11 00 00 00       	mov    $0x11,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	ret    

000006dc <unlink>:
SYSCALL(unlink)
 6dc:	b8 12 00 00 00       	mov    $0x12,%eax
 6e1:	cd 40                	int    $0x40
 6e3:	c3                   	ret    

000006e4 <fstat>:
SYSCALL(fstat)
 6e4:	b8 08 00 00 00       	mov    $0x8,%eax
 6e9:	cd 40                	int    $0x40
 6eb:	c3                   	ret    

000006ec <link>:
SYSCALL(link)
 6ec:	b8 13 00 00 00       	mov    $0x13,%eax
 6f1:	cd 40                	int    $0x40
 6f3:	c3                   	ret    

000006f4 <mkdir>:
SYSCALL(mkdir)
 6f4:	b8 14 00 00 00       	mov    $0x14,%eax
 6f9:	cd 40                	int    $0x40
 6fb:	c3                   	ret    

000006fc <chdir>:
SYSCALL(chdir)
 6fc:	b8 09 00 00 00       	mov    $0x9,%eax
 701:	cd 40                	int    $0x40
 703:	c3                   	ret    

00000704 <dup>:
SYSCALL(dup)
 704:	b8 0a 00 00 00       	mov    $0xa,%eax
 709:	cd 40                	int    $0x40
 70b:	c3                   	ret    

0000070c <getpid>:
SYSCALL(getpid)
 70c:	b8 0b 00 00 00       	mov    $0xb,%eax
 711:	cd 40                	int    $0x40
 713:	c3                   	ret    

00000714 <sbrk>:
SYSCALL(sbrk)
 714:	b8 0c 00 00 00       	mov    $0xc,%eax
 719:	cd 40                	int    $0x40
 71b:	c3                   	ret    

0000071c <sleep>:
SYSCALL(sleep)
 71c:	b8 0d 00 00 00       	mov    $0xd,%eax
 721:	cd 40                	int    $0x40
 723:	c3                   	ret    

00000724 <uptime>:
SYSCALL(uptime)
 724:	b8 0e 00 00 00       	mov    $0xe,%eax
 729:	cd 40                	int    $0x40
 72b:	c3                   	ret    

0000072c <getticks>:
SYSCALL(getticks)
 72c:	b8 16 00 00 00       	mov    $0x16,%eax
 731:	cd 40                	int    $0x40
 733:	c3                   	ret    

00000734 <get_name>:
SYSCALL(get_name)
 734:	b8 17 00 00 00       	mov    $0x17,%eax
 739:	cd 40                	int    $0x40
 73b:	c3                   	ret    

0000073c <get_max_proc>:
SYSCALL(get_max_proc)
 73c:	b8 18 00 00 00       	mov    $0x18,%eax
 741:	cd 40                	int    $0x40
 743:	c3                   	ret    

00000744 <get_max_mem>:
SYSCALL(get_max_mem)
 744:	b8 19 00 00 00       	mov    $0x19,%eax
 749:	cd 40                	int    $0x40
 74b:	c3                   	ret    

0000074c <get_max_disk>:
SYSCALL(get_max_disk)
 74c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 751:	cd 40                	int    $0x40
 753:	c3                   	ret    

00000754 <get_curr_proc>:
SYSCALL(get_curr_proc)
 754:	b8 1b 00 00 00       	mov    $0x1b,%eax
 759:	cd 40                	int    $0x40
 75b:	c3                   	ret    

0000075c <get_curr_mem>:
SYSCALL(get_curr_mem)
 75c:	b8 1c 00 00 00       	mov    $0x1c,%eax
 761:	cd 40                	int    $0x40
 763:	c3                   	ret    

00000764 <get_curr_disk>:
SYSCALL(get_curr_disk)
 764:	b8 1d 00 00 00       	mov    $0x1d,%eax
 769:	cd 40                	int    $0x40
 76b:	c3                   	ret    

0000076c <set_name>:
SYSCALL(set_name)
 76c:	b8 1e 00 00 00       	mov    $0x1e,%eax
 771:	cd 40                	int    $0x40
 773:	c3                   	ret    

00000774 <set_max_mem>:
SYSCALL(set_max_mem)
 774:	b8 1f 00 00 00       	mov    $0x1f,%eax
 779:	cd 40                	int    $0x40
 77b:	c3                   	ret    

0000077c <set_max_disk>:
SYSCALL(set_max_disk)
 77c:	b8 20 00 00 00       	mov    $0x20,%eax
 781:	cd 40                	int    $0x40
 783:	c3                   	ret    

00000784 <set_max_proc>:
SYSCALL(set_max_proc)
 784:	b8 21 00 00 00       	mov    $0x21,%eax
 789:	cd 40                	int    $0x40
 78b:	c3                   	ret    

0000078c <set_curr_mem>:
SYSCALL(set_curr_mem)
 78c:	b8 22 00 00 00       	mov    $0x22,%eax
 791:	cd 40                	int    $0x40
 793:	c3                   	ret    

00000794 <set_curr_disk>:
SYSCALL(set_curr_disk)
 794:	b8 23 00 00 00       	mov    $0x23,%eax
 799:	cd 40                	int    $0x40
 79b:	c3                   	ret    

0000079c <set_curr_proc>:
SYSCALL(set_curr_proc)
 79c:	b8 24 00 00 00       	mov    $0x24,%eax
 7a1:	cd 40                	int    $0x40
 7a3:	c3                   	ret    

000007a4 <find>:
SYSCALL(find)
 7a4:	b8 25 00 00 00       	mov    $0x25,%eax
 7a9:	cd 40                	int    $0x40
 7ab:	c3                   	ret    

000007ac <is_full>:
SYSCALL(is_full)
 7ac:	b8 26 00 00 00       	mov    $0x26,%eax
 7b1:	cd 40                	int    $0x40
 7b3:	c3                   	ret    

000007b4 <container_init>:
SYSCALL(container_init)
 7b4:	b8 27 00 00 00       	mov    $0x27,%eax
 7b9:	cd 40                	int    $0x40
 7bb:	c3                   	ret    

000007bc <cont_proc_set>:
SYSCALL(cont_proc_set)
 7bc:	b8 28 00 00 00       	mov    $0x28,%eax
 7c1:	cd 40                	int    $0x40
 7c3:	c3                   	ret    

000007c4 <ps>:
SYSCALL(ps)
 7c4:	b8 29 00 00 00       	mov    $0x29,%eax
 7c9:	cd 40                	int    $0x40
 7cb:	c3                   	ret    

000007cc <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
 7cc:	b8 2a 00 00 00       	mov    $0x2a,%eax
 7d1:	cd 40                	int    $0x40
 7d3:	c3                   	ret    

000007d4 <set_root_inode>:
SYSCALL(set_root_inode)
 7d4:	b8 2b 00 00 00       	mov    $0x2b,%eax
 7d9:	cd 40                	int    $0x40
 7db:	c3                   	ret    

000007dc <cstop>:
SYSCALL(cstop)
 7dc:	b8 2c 00 00 00       	mov    $0x2c,%eax
 7e1:	cd 40                	int    $0x40
 7e3:	c3                   	ret    

000007e4 <df>:
SYSCALL(df)
 7e4:	b8 2d 00 00 00       	mov    $0x2d,%eax
 7e9:	cd 40                	int    $0x40
 7eb:	c3                   	ret    

000007ec <max_containers>:
SYSCALL(max_containers)
 7ec:	b8 2e 00 00 00       	mov    $0x2e,%eax
 7f1:	cd 40                	int    $0x40
 7f3:	c3                   	ret    

000007f4 <container_reset>:
SYSCALL(container_reset)
 7f4:	b8 2f 00 00 00       	mov    $0x2f,%eax
 7f9:	cd 40                	int    $0x40
 7fb:	c3                   	ret    

000007fc <pause>:
SYSCALL(pause)
 7fc:	b8 30 00 00 00       	mov    $0x30,%eax
 801:	cd 40                	int    $0x40
 803:	c3                   	ret    

00000804 <resume>:
SYSCALL(resume)
 804:	b8 31 00 00 00       	mov    $0x31,%eax
 809:	cd 40                	int    $0x40
 80b:	c3                   	ret    

0000080c <tmem>:
SYSCALL(tmem)
 80c:	b8 32 00 00 00       	mov    $0x32,%eax
 811:	cd 40                	int    $0x40
 813:	c3                   	ret    

00000814 <amem>:
SYSCALL(amem)
 814:	b8 33 00 00 00       	mov    $0x33,%eax
 819:	cd 40                	int    $0x40
 81b:	c3                   	ret    

0000081c <c_ps>:
SYSCALL(c_ps)
 81c:	b8 34 00 00 00       	mov    $0x34,%eax
 821:	cd 40                	int    $0x40
 823:	c3                   	ret    

00000824 <get_used>:
SYSCALL(get_used)
 824:	b8 35 00 00 00       	mov    $0x35,%eax
 829:	cd 40                	int    $0x40
 82b:	c3                   	ret    

0000082c <get_os>:
SYSCALL(get_os)
 82c:	b8 36 00 00 00       	mov    $0x36,%eax
 831:	cd 40                	int    $0x40
 833:	c3                   	ret    

00000834 <set_os>:
SYSCALL(set_os)
 834:	b8 37 00 00 00       	mov    $0x37,%eax
 839:	cd 40                	int    $0x40
 83b:	c3                   	ret    

0000083c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 83c:	55                   	push   %ebp
 83d:	89 e5                	mov    %esp,%ebp
 83f:	83 ec 18             	sub    $0x18,%esp
 842:	8b 45 0c             	mov    0xc(%ebp),%eax
 845:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 848:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 84f:	00 
 850:	8d 45 f4             	lea    -0xc(%ebp),%eax
 853:	89 44 24 04          	mov    %eax,0x4(%esp)
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	89 04 24             	mov    %eax,(%esp)
 85d:	e8 4a fe ff ff       	call   6ac <write>
}
 862:	c9                   	leave  
 863:	c3                   	ret    

00000864 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 864:	55                   	push   %ebp
 865:	89 e5                	mov    %esp,%ebp
 867:	56                   	push   %esi
 868:	53                   	push   %ebx
 869:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 86c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 873:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 877:	74 17                	je     890 <printint+0x2c>
 879:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 87d:	79 11                	jns    890 <printint+0x2c>
    neg = 1;
 87f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 886:	8b 45 0c             	mov    0xc(%ebp),%eax
 889:	f7 d8                	neg    %eax
 88b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 88e:	eb 06                	jmp    896 <printint+0x32>
  } else {
    x = xx;
 890:	8b 45 0c             	mov    0xc(%ebp),%eax
 893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 89d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 8a0:	8d 41 01             	lea    0x1(%ecx),%eax
 8a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ac:	ba 00 00 00 00       	mov    $0x0,%edx
 8b1:	f7 f3                	div    %ebx
 8b3:	89 d0                	mov    %edx,%eax
 8b5:	8a 80 44 10 00 00    	mov    0x1044(%eax),%al
 8bb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 8bf:	8b 75 10             	mov    0x10(%ebp),%esi
 8c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c5:	ba 00 00 00 00       	mov    $0x0,%edx
 8ca:	f7 f6                	div    %esi
 8cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8d3:	75 c8                	jne    89d <printint+0x39>
  if(neg)
 8d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8d9:	74 10                	je     8eb <printint+0x87>
    buf[i++] = '-';
 8db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8de:	8d 50 01             	lea    0x1(%eax),%edx
 8e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8e4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8e9:	eb 1e                	jmp    909 <printint+0xa5>
 8eb:	eb 1c                	jmp    909 <printint+0xa5>
    putc(fd, buf[i]);
 8ed:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	01 d0                	add    %edx,%eax
 8f5:	8a 00                	mov    (%eax),%al
 8f7:	0f be c0             	movsbl %al,%eax
 8fa:	89 44 24 04          	mov    %eax,0x4(%esp)
 8fe:	8b 45 08             	mov    0x8(%ebp),%eax
 901:	89 04 24             	mov    %eax,(%esp)
 904:	e8 33 ff ff ff       	call   83c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 909:	ff 4d f4             	decl   -0xc(%ebp)
 90c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 910:	79 db                	jns    8ed <printint+0x89>
    putc(fd, buf[i]);
}
 912:	83 c4 30             	add    $0x30,%esp
 915:	5b                   	pop    %ebx
 916:	5e                   	pop    %esi
 917:	5d                   	pop    %ebp
 918:	c3                   	ret    

00000919 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 919:	55                   	push   %ebp
 91a:	89 e5                	mov    %esp,%ebp
 91c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 91f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 926:	8d 45 0c             	lea    0xc(%ebp),%eax
 929:	83 c0 04             	add    $0x4,%eax
 92c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 92f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 936:	e9 77 01 00 00       	jmp    ab2 <printf+0x199>
    c = fmt[i] & 0xff;
 93b:	8b 55 0c             	mov    0xc(%ebp),%edx
 93e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 941:	01 d0                	add    %edx,%eax
 943:	8a 00                	mov    (%eax),%al
 945:	0f be c0             	movsbl %al,%eax
 948:	25 ff 00 00 00       	and    $0xff,%eax
 94d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 950:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 954:	75 2c                	jne    982 <printf+0x69>
      if(c == '%'){
 956:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 95a:	75 0c                	jne    968 <printf+0x4f>
        state = '%';
 95c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 963:	e9 47 01 00 00       	jmp    aaf <printf+0x196>
      } else {
        putc(fd, c);
 968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 96b:	0f be c0             	movsbl %al,%eax
 96e:	89 44 24 04          	mov    %eax,0x4(%esp)
 972:	8b 45 08             	mov    0x8(%ebp),%eax
 975:	89 04 24             	mov    %eax,(%esp)
 978:	e8 bf fe ff ff       	call   83c <putc>
 97d:	e9 2d 01 00 00       	jmp    aaf <printf+0x196>
      }
    } else if(state == '%'){
 982:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 986:	0f 85 23 01 00 00    	jne    aaf <printf+0x196>
      if(c == 'd'){
 98c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 990:	75 2d                	jne    9bf <printf+0xa6>
        printint(fd, *ap, 10, 1);
 992:	8b 45 e8             	mov    -0x18(%ebp),%eax
 995:	8b 00                	mov    (%eax),%eax
 997:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 99e:	00 
 99f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 9a6:	00 
 9a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 9ab:	8b 45 08             	mov    0x8(%ebp),%eax
 9ae:	89 04 24             	mov    %eax,(%esp)
 9b1:	e8 ae fe ff ff       	call   864 <printint>
        ap++;
 9b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9ba:	e9 e9 00 00 00       	jmp    aa8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 9bf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9c3:	74 06                	je     9cb <printf+0xb2>
 9c5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9c9:	75 2d                	jne    9f8 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 9cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9ce:	8b 00                	mov    (%eax),%eax
 9d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9d7:	00 
 9d8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9df:	00 
 9e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 9e4:	8b 45 08             	mov    0x8(%ebp),%eax
 9e7:	89 04 24             	mov    %eax,(%esp)
 9ea:	e8 75 fe ff ff       	call   864 <printint>
        ap++;
 9ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9f3:	e9 b0 00 00 00       	jmp    aa8 <printf+0x18f>
      } else if(c == 's'){
 9f8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9fc:	75 42                	jne    a40 <printf+0x127>
        s = (char*)*ap;
 9fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a01:	8b 00                	mov    (%eax),%eax
 a03:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a06:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a0e:	75 09                	jne    a19 <printf+0x100>
          s = "(null)";
 a10:	c7 45 f4 8e 0d 00 00 	movl   $0xd8e,-0xc(%ebp)
        while(*s != 0){
 a17:	eb 1c                	jmp    a35 <printf+0x11c>
 a19:	eb 1a                	jmp    a35 <printf+0x11c>
          putc(fd, *s);
 a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1e:	8a 00                	mov    (%eax),%al
 a20:	0f be c0             	movsbl %al,%eax
 a23:	89 44 24 04          	mov    %eax,0x4(%esp)
 a27:	8b 45 08             	mov    0x8(%ebp),%eax
 a2a:	89 04 24             	mov    %eax,(%esp)
 a2d:	e8 0a fe ff ff       	call   83c <putc>
          s++;
 a32:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	8a 00                	mov    (%eax),%al
 a3a:	84 c0                	test   %al,%al
 a3c:	75 dd                	jne    a1b <printf+0x102>
 a3e:	eb 68                	jmp    aa8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a40:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a44:	75 1d                	jne    a63 <printf+0x14a>
        putc(fd, *ap);
 a46:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a49:	8b 00                	mov    (%eax),%eax
 a4b:	0f be c0             	movsbl %al,%eax
 a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
 a52:	8b 45 08             	mov    0x8(%ebp),%eax
 a55:	89 04 24             	mov    %eax,(%esp)
 a58:	e8 df fd ff ff       	call   83c <putc>
        ap++;
 a5d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a61:	eb 45                	jmp    aa8 <printf+0x18f>
      } else if(c == '%'){
 a63:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a67:	75 17                	jne    a80 <printf+0x167>
        putc(fd, c);
 a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a6c:	0f be c0             	movsbl %al,%eax
 a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
 a73:	8b 45 08             	mov    0x8(%ebp),%eax
 a76:	89 04 24             	mov    %eax,(%esp)
 a79:	e8 be fd ff ff       	call   83c <putc>
 a7e:	eb 28                	jmp    aa8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a80:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a87:	00 
 a88:	8b 45 08             	mov    0x8(%ebp),%eax
 a8b:	89 04 24             	mov    %eax,(%esp)
 a8e:	e8 a9 fd ff ff       	call   83c <putc>
        putc(fd, c);
 a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a96:	0f be c0             	movsbl %al,%eax
 a99:	89 44 24 04          	mov    %eax,0x4(%esp)
 a9d:	8b 45 08             	mov    0x8(%ebp),%eax
 aa0:	89 04 24             	mov    %eax,(%esp)
 aa3:	e8 94 fd ff ff       	call   83c <putc>
      }
      state = 0;
 aa8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 aaf:	ff 45 f0             	incl   -0x10(%ebp)
 ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
 ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab8:	01 d0                	add    %edx,%eax
 aba:	8a 00                	mov    (%eax),%al
 abc:	84 c0                	test   %al,%al
 abe:	0f 85 77 fe ff ff    	jne    93b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 ac4:	c9                   	leave  
 ac5:	c3                   	ret    
 ac6:	90                   	nop
 ac7:	90                   	nop

00000ac8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ac8:	55                   	push   %ebp
 ac9:	89 e5                	mov    %esp,%ebp
 acb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ace:	8b 45 08             	mov    0x8(%ebp),%eax
 ad1:	83 e8 08             	sub    $0x8,%eax
 ad4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad7:	a1 60 10 00 00       	mov    0x1060,%eax
 adc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 adf:	eb 24                	jmp    b05 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae4:	8b 00                	mov    (%eax),%eax
 ae6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ae9:	77 12                	ja     afd <free+0x35>
 aeb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af1:	77 24                	ja     b17 <free+0x4f>
 af3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af6:	8b 00                	mov    (%eax),%eax
 af8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 afb:	77 1a                	ja     b17 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b00:	8b 00                	mov    (%eax),%eax
 b02:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b05:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b08:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b0b:	76 d4                	jbe    ae1 <free+0x19>
 b0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b10:	8b 00                	mov    (%eax),%eax
 b12:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b15:	76 ca                	jbe    ae1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 b17:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1a:	8b 40 04             	mov    0x4(%eax),%eax
 b1d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b24:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b27:	01 c2                	add    %eax,%edx
 b29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2c:	8b 00                	mov    (%eax),%eax
 b2e:	39 c2                	cmp    %eax,%edx
 b30:	75 24                	jne    b56 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b32:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b35:	8b 50 04             	mov    0x4(%eax),%edx
 b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3b:	8b 00                	mov    (%eax),%eax
 b3d:	8b 40 04             	mov    0x4(%eax),%eax
 b40:	01 c2                	add    %eax,%edx
 b42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b45:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4b:	8b 00                	mov    (%eax),%eax
 b4d:	8b 10                	mov    (%eax),%edx
 b4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b52:	89 10                	mov    %edx,(%eax)
 b54:	eb 0a                	jmp    b60 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b56:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b59:	8b 10                	mov    (%eax),%edx
 b5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b5e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b63:	8b 40 04             	mov    0x4(%eax),%eax
 b66:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b70:	01 d0                	add    %edx,%eax
 b72:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b75:	75 20                	jne    b97 <free+0xcf>
    p->s.size += bp->s.size;
 b77:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7a:	8b 50 04             	mov    0x4(%eax),%edx
 b7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b80:	8b 40 04             	mov    0x4(%eax),%eax
 b83:	01 c2                	add    %eax,%edx
 b85:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b88:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b8e:	8b 10                	mov    (%eax),%edx
 b90:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b93:	89 10                	mov    %edx,(%eax)
 b95:	eb 08                	jmp    b9f <free+0xd7>
  } else
    p->s.ptr = bp;
 b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b9d:	89 10                	mov    %edx,(%eax)
  freep = p;
 b9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba2:	a3 60 10 00 00       	mov    %eax,0x1060
}
 ba7:	c9                   	leave  
 ba8:	c3                   	ret    

00000ba9 <morecore>:

static Header*
morecore(uint nu)
{
 ba9:	55                   	push   %ebp
 baa:	89 e5                	mov    %esp,%ebp
 bac:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 baf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bb6:	77 07                	ja     bbf <morecore+0x16>
    nu = 4096;
 bb8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bbf:	8b 45 08             	mov    0x8(%ebp),%eax
 bc2:	c1 e0 03             	shl    $0x3,%eax
 bc5:	89 04 24             	mov    %eax,(%esp)
 bc8:	e8 47 fb ff ff       	call   714 <sbrk>
 bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bd0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bd4:	75 07                	jne    bdd <morecore+0x34>
    return 0;
 bd6:	b8 00 00 00 00       	mov    $0x0,%eax
 bdb:	eb 22                	jmp    bff <morecore+0x56>
  hp = (Header*)p;
 bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be6:	8b 55 08             	mov    0x8(%ebp),%edx
 be9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bef:	83 c0 08             	add    $0x8,%eax
 bf2:	89 04 24             	mov    %eax,(%esp)
 bf5:	e8 ce fe ff ff       	call   ac8 <free>
  return freep;
 bfa:	a1 60 10 00 00       	mov    0x1060,%eax
}
 bff:	c9                   	leave  
 c00:	c3                   	ret    

00000c01 <malloc>:

void*
malloc(uint nbytes)
{
 c01:	55                   	push   %ebp
 c02:	89 e5                	mov    %esp,%ebp
 c04:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c07:	8b 45 08             	mov    0x8(%ebp),%eax
 c0a:	83 c0 07             	add    $0x7,%eax
 c0d:	c1 e8 03             	shr    $0x3,%eax
 c10:	40                   	inc    %eax
 c11:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c14:	a1 60 10 00 00       	mov    0x1060,%eax
 c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c20:	75 23                	jne    c45 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 c22:	c7 45 f0 58 10 00 00 	movl   $0x1058,-0x10(%ebp)
 c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c2c:	a3 60 10 00 00       	mov    %eax,0x1060
 c31:	a1 60 10 00 00       	mov    0x1060,%eax
 c36:	a3 58 10 00 00       	mov    %eax,0x1058
    base.s.size = 0;
 c3b:	c7 05 5c 10 00 00 00 	movl   $0x0,0x105c
 c42:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c48:	8b 00                	mov    (%eax),%eax
 c4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c50:	8b 40 04             	mov    0x4(%eax),%eax
 c53:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c56:	72 4d                	jb     ca5 <malloc+0xa4>
      if(p->s.size == nunits)
 c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5b:	8b 40 04             	mov    0x4(%eax),%eax
 c5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c61:	75 0c                	jne    c6f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c66:	8b 10                	mov    (%eax),%edx
 c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c6b:	89 10                	mov    %edx,(%eax)
 c6d:	eb 26                	jmp    c95 <malloc+0x94>
      else {
        p->s.size -= nunits;
 c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c72:	8b 40 04             	mov    0x4(%eax),%eax
 c75:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c78:	89 c2                	mov    %eax,%edx
 c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c83:	8b 40 04             	mov    0x4(%eax),%eax
 c86:	c1 e0 03             	shl    $0x3,%eax
 c89:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c92:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c98:	a3 60 10 00 00       	mov    %eax,0x1060
      return (void*)(p + 1);
 c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca0:	83 c0 08             	add    $0x8,%eax
 ca3:	eb 38                	jmp    cdd <malloc+0xdc>
    }
    if(p == freep)
 ca5:	a1 60 10 00 00       	mov    0x1060,%eax
 caa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cad:	75 1b                	jne    cca <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 cb2:	89 04 24             	mov    %eax,(%esp)
 cb5:	e8 ef fe ff ff       	call   ba9 <morecore>
 cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cc1:	75 07                	jne    cca <malloc+0xc9>
        return 0;
 cc3:	b8 00 00 00 00       	mov    $0x0,%eax
 cc8:	eb 13                	jmp    cdd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ccd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd3:	8b 00                	mov    (%eax),%eax
 cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 cd8:	e9 70 ff ff ff       	jmp    c4d <malloc+0x4c>
}
 cdd:	c9                   	leave  
 cde:	c3                   	ret    
