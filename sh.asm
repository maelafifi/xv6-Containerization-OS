
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 07 10 00 00       	call   1018 <exit>

  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 98 16 00 00 	mov    0x1698(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	c7 04 24 6c 16 00 00 	movl   $0x166c,(%esp)
      2b:	e8 1e 03 00 00       	call   34e <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      30:	8b 45 08             	mov    0x8(%ebp),%eax
      33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	8b 40 04             	mov    0x4(%eax),%eax
      3c:	85 c0                	test   %eax,%eax
      3e:	75 05                	jne    45 <runcmd+0x45>
      exit();
      40:	e8 d3 0f 00 00       	call   1018 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      45:	8b 45 f4             	mov    -0xc(%ebp),%eax
      48:	8d 50 04             	lea    0x4(%eax),%edx
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	8b 40 04             	mov    0x4(%eax),%eax
      51:	89 54 24 04          	mov    %edx,0x4(%esp)
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 f3 0f 00 00       	call   1050 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      60:	8b 40 04             	mov    0x4(%eax),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 73 16 00 	movl   $0x1673,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 2a 12 00 00       	call   12a5 <printf>
    break;
      7b:	e9 86 01 00 00       	jmp    206 <runcmd+0x206>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 ac 0f 00 00       	call   1040 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 50 10             	mov    0x10(%eax),%edx
      9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9d:	8b 40 08             	mov    0x8(%eax),%eax
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 ac 0f 00 00       	call   1058 <open>
      ac:	85 c0                	test   %eax,%eax
      ae:	79 23                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b3:	8b 40 08             	mov    0x8(%eax),%eax
      b6:	89 44 24 08          	mov    %eax,0x8(%esp)
      ba:	c7 44 24 04 83 16 00 	movl   $0x1683,0x4(%esp)
      c1:	00 
      c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c9:	e8 d7 11 00 00       	call   12a5 <printf>
      exit();
      ce:	e8 45 0f 00 00       	call   1018 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	89 04 24             	mov    %eax,(%esp)
      dc:	e8 1f ff ff ff       	call   0 <runcmd>
    break;
      e1:	e9 20 01 00 00       	jmp    206 <runcmd+0x206>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      e6:	8b 45 08             	mov    0x8(%ebp),%eax
      e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      ec:	e8 83 02 00 00       	call   374 <fork1>
      f1:	85 c0                	test   %eax,%eax
      f3:	75 0e                	jne    103 <runcmd+0x103>
      runcmd(lcmd->left);
      f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
      f8:	8b 40 04             	mov    0x4(%eax),%eax
      fb:	89 04 24             	mov    %eax,(%esp)
      fe:	e8 fd fe ff ff       	call   0 <runcmd>
    wait();
     103:	e8 18 0f 00 00       	call   1020 <wait>
    runcmd(lcmd->right);
     108:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10b:	8b 40 08             	mov    0x8(%eax),%eax
     10e:	89 04 24             	mov    %eax,(%esp)
     111:	e8 ea fe ff ff       	call   0 <runcmd>
    break;
     116:	e9 eb 00 00 00       	jmp    206 <runcmd+0x206>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     11b:	8b 45 08             	mov    0x8(%ebp),%eax
     11e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     121:	8d 45 dc             	lea    -0x24(%ebp),%eax
     124:	89 04 24             	mov    %eax,(%esp)
     127:	e8 fc 0e 00 00       	call   1028 <pipe>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 0c                	jns    13c <runcmd+0x13c>
      panic("pipe");
     130:	c7 04 24 93 16 00 00 	movl   $0x1693,(%esp)
     137:	e8 12 02 00 00       	call   34e <panic>
    if(fork1() == 0){
     13c:	e8 33 02 00 00       	call   374 <fork1>
     141:	85 c0                	test   %eax,%eax
     143:	75 3b                	jne    180 <runcmd+0x180>
      close(1);
     145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     14c:	e8 ef 0e 00 00       	call   1040 <close>
      dup(p[1]);
     151:	8b 45 e0             	mov    -0x20(%ebp),%eax
     154:	89 04 24             	mov    %eax,(%esp)
     157:	e8 34 0f 00 00       	call   1090 <dup>
      close(p[0]);
     15c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     15f:	89 04 24             	mov    %eax,(%esp)
     162:	e8 d9 0e 00 00       	call   1040 <close>
      close(p[1]);
     167:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 ce 0e 00 00       	call   1040 <close>
      runcmd(pcmd->left);
     172:	8b 45 e8             	mov    -0x18(%ebp),%eax
     175:	8b 40 04             	mov    0x4(%eax),%eax
     178:	89 04 24             	mov    %eax,(%esp)
     17b:	e8 80 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     180:	e8 ef 01 00 00       	call   374 <fork1>
     185:	85 c0                	test   %eax,%eax
     187:	75 3b                	jne    1c4 <runcmd+0x1c4>
      close(0);
     189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     190:	e8 ab 0e 00 00       	call   1040 <close>
      dup(p[0]);
     195:	8b 45 dc             	mov    -0x24(%ebp),%eax
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 f0 0e 00 00       	call   1090 <dup>
      close(p[0]);
     1a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 95 0e 00 00       	call   1040 <close>
      close(p[1]);
     1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ae:	89 04 24             	mov    %eax,(%esp)
     1b1:	e8 8a 0e 00 00       	call   1040 <close>
      runcmd(pcmd->right);
     1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1b9:	8b 40 08             	mov    0x8(%eax),%eax
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 3c fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c7:	89 04 24             	mov    %eax,(%esp)
     1ca:	e8 71 0e 00 00       	call   1040 <close>
    close(p[1]);
     1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 66 0e 00 00       	call   1040 <close>
    wait();
     1da:	e8 41 0e 00 00       	call   1020 <wait>
    wait();
     1df:	e8 3c 0e 00 00       	call   1020 <wait>
    break;
     1e4:	eb 20                	jmp    206 <runcmd+0x206>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     1e6:	8b 45 08             	mov    0x8(%ebp),%eax
     1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     1ec:	e8 83 01 00 00       	call   374 <fork1>
     1f1:	85 c0                	test   %eax,%eax
     1f3:	75 10                	jne    205 <runcmd+0x205>
      runcmd(bcmd->cmd);
     1f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1f8:	8b 40 04             	mov    0x4(%eax),%eax
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 fd fd ff ff       	call   0 <runcmd>
    break;
     203:	eb 00                	jmp    205 <runcmd+0x205>
     205:	90                   	nop
  }
  exit();
     206:	e8 0d 0e 00 00       	call   1018 <exit>

0000020b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     20b:	55                   	push   %ebp
     20c:	89 e5                	mov    %esp,%ebp
     20e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     211:	c7 44 24 04 b0 16 00 	movl   $0x16b0,0x4(%esp)
     218:	00 
     219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     220:	e8 80 10 00 00       	call   12a5 <printf>
  memset(buf, 0, nbuf);
     225:	8b 45 0c             	mov    0xc(%ebp),%eax
     228:	89 44 24 08          	mov    %eax,0x8(%esp)
     22c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     233:	00 
     234:	8b 45 08             	mov    0x8(%ebp),%eax
     237:	89 04 24             	mov    %eax,(%esp)
     23a:	e8 51 0b 00 00       	call   d90 <memset>
  gets(buf, nbuf);
     23f:	8b 45 0c             	mov    0xc(%ebp),%eax
     242:	89 44 24 04          	mov    %eax,0x4(%esp)
     246:	8b 45 08             	mov    0x8(%ebp),%eax
     249:	89 04 24             	mov    %eax,(%esp)
     24c:	e8 93 0b 00 00       	call   de4 <gets>
  if(buf[0] == 0) // EOF
     251:	8b 45 08             	mov    0x8(%ebp),%eax
     254:	8a 00                	mov    (%eax),%al
     256:	84 c0                	test   %al,%al
     258:	75 07                	jne    261 <getcmd+0x56>
    return -1;
     25a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     25f:	eb 05                	jmp    266 <getcmd+0x5b>
  return 0;
     261:	b8 00 00 00 00       	mov    $0x0,%eax
}
     266:	c9                   	leave  
     267:	c3                   	ret    

00000268 <main>:

int
main(void)
{
     268:	55                   	push   %ebp
     269:	89 e5                	mov    %esp,%ebp
     26b:	83 e4 f0             	and    $0xfffffff0,%esp
     26e:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
     271:	eb 15                	jmp    288 <main+0x20>
    if(fd >= 3){
     273:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     278:	7e 0e                	jle    288 <main+0x20>
      close(fd);
     27a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     27e:	89 04 24             	mov    %eax,(%esp)
     281:	e8 ba 0d 00 00       	call   1040 <close>
      break;
     286:	eb 1f                	jmp    2a7 <main+0x3f>
{
  static char buf[100];
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
     288:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     28f:	00 
     290:	c7 04 24 b3 16 00 00 	movl   $0x16b3,(%esp)
     297:	e8 bc 0d 00 00       	call   1058 <open>
     29c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2a0:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2a5:	79 cc                	jns    273 <main+0xb>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2a7:	e9 81 00 00 00       	jmp    32d <main+0xc5>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2ac:	a0 40 1c 00 00       	mov    0x1c40,%al
     2b1:	3c 63                	cmp    $0x63,%al
     2b3:	75 56                	jne    30b <main+0xa3>
     2b5:	a0 41 1c 00 00       	mov    0x1c41,%al
     2ba:	3c 64                	cmp    $0x64,%al
     2bc:	75 4d                	jne    30b <main+0xa3>
     2be:	a0 42 1c 00 00       	mov    0x1c42,%al
     2c3:	3c 20                	cmp    $0x20,%al
     2c5:	75 44                	jne    30b <main+0xa3>
      // Chdir must be called by the parent, not the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2c7:	c7 04 24 40 1c 00 00 	movl   $0x1c40,(%esp)
     2ce:	e8 98 0a 00 00       	call   d6b <strlen>
     2d3:	48                   	dec    %eax
     2d4:	c6 80 40 1c 00 00 00 	movb   $0x0,0x1c40(%eax)
      if(chdir(buf+3) < 0)
     2db:	c7 04 24 43 1c 00 00 	movl   $0x1c43,(%esp)
     2e2:	e8 a1 0d 00 00       	call   1088 <chdir>
     2e7:	85 c0                	test   %eax,%eax
     2e9:	79 1e                	jns    309 <main+0xa1>
        printf(2, "cannot cd %s\n", buf+3);
     2eb:	c7 44 24 08 43 1c 00 	movl   $0x1c43,0x8(%esp)
     2f2:	00 
     2f3:	c7 44 24 04 bb 16 00 	movl   $0x16bb,0x4(%esp)
     2fa:	00 
     2fb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     302:	e8 9e 0f 00 00       	call   12a5 <printf>
      continue;
     307:	eb 24                	jmp    32d <main+0xc5>
     309:	eb 22                	jmp    32d <main+0xc5>
    }
    if(fork1() == 0)
     30b:	e8 64 00 00 00       	call   374 <fork1>
     310:	85 c0                	test   %eax,%eax
     312:	75 14                	jne    328 <main+0xc0>
      runcmd(parsecmd(buf));
     314:	c7 04 24 40 1c 00 00 	movl   $0x1c40,(%esp)
     31b:	e8 b8 03 00 00       	call   6d8 <parsecmd>
     320:	89 04 24             	mov    %eax,(%esp)
     323:	e8 d8 fc ff ff       	call   0 <runcmd>
    wait();
     328:	e8 f3 0c 00 00       	call   1020 <wait>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     32d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     334:	00 
     335:	c7 04 24 40 1c 00 00 	movl   $0x1c40,(%esp)
     33c:	e8 ca fe ff ff       	call   20b <getcmd>
     341:	85 c0                	test   %eax,%eax
     343:	0f 89 63 ff ff ff    	jns    2ac <main+0x44>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     349:	e8 ca 0c 00 00       	call   1018 <exit>

0000034e <panic>:
}

void
panic(char *s)
{
     34e:	55                   	push   %ebp
     34f:	89 e5                	mov    %esp,%ebp
     351:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     354:	8b 45 08             	mov    0x8(%ebp),%eax
     357:	89 44 24 08          	mov    %eax,0x8(%esp)
     35b:	c7 44 24 04 c9 16 00 	movl   $0x16c9,0x4(%esp)
     362:	00 
     363:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     36a:	e8 36 0f 00 00       	call   12a5 <printf>
  exit();
     36f:	e8 a4 0c 00 00       	call   1018 <exit>

00000374 <fork1>:
}

int
fork1(void)
{
     374:	55                   	push   %ebp
     375:	89 e5                	mov    %esp,%ebp
     377:	83 ec 28             	sub    $0x28,%esp
  int pid;

  pid = fork();
     37a:	e8 91 0c 00 00       	call   1010 <fork>
     37f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     382:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     386:	75 0c                	jne    394 <fork1+0x20>
    panic("fork");
     388:	c7 04 24 cd 16 00 00 	movl   $0x16cd,(%esp)
     38f:	e8 ba ff ff ff       	call   34e <panic>
  return pid;
     394:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     397:	c9                   	leave  
     398:	c3                   	ret    

00000399 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     399:	55                   	push   %ebp
     39a:	89 e5                	mov    %esp,%ebp
     39c:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     39f:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3a6:	e8 e2 11 00 00       	call   158d <malloc>
     3ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3ae:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     3b5:	00 
     3b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3bd:	00 
     3be:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3c1:	89 04 24             	mov    %eax,(%esp)
     3c4:	e8 c7 09 00 00       	call   d90 <memset>
  cmd->type = EXEC;
     3c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3cc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3d5:	c9                   	leave  
     3d6:	c3                   	ret    

000003d7 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     3d7:	55                   	push   %ebp
     3d8:	89 e5                	mov    %esp,%ebp
     3da:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3dd:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     3e4:	e8 a4 11 00 00       	call   158d <malloc>
     3e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3ec:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     3f3:	00 
     3f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3fb:	00 
     3fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3ff:	89 04 24             	mov    %eax,(%esp)
     402:	e8 89 09 00 00       	call   d90 <memset>
  cmd->type = REDIR;
     407:	8b 45 f4             	mov    -0xc(%ebp),%eax
     40a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	8b 55 08             	mov    0x8(%ebp),%edx
     416:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     419:	8b 45 f4             	mov    -0xc(%ebp),%eax
     41c:	8b 55 0c             	mov    0xc(%ebp),%edx
     41f:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     422:	8b 45 f4             	mov    -0xc(%ebp),%eax
     425:	8b 55 10             	mov    0x10(%ebp),%edx
     428:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     42b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     42e:	8b 55 14             	mov    0x14(%ebp),%edx
     431:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     434:	8b 45 f4             	mov    -0xc(%ebp),%eax
     437:	8b 55 18             	mov    0x18(%ebp),%edx
     43a:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     43d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     440:	c9                   	leave  
     441:	c3                   	ret    

00000442 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     442:	55                   	push   %ebp
     443:	89 e5                	mov    %esp,%ebp
     445:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     448:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     44f:	e8 39 11 00 00       	call   158d <malloc>
     454:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     457:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     45e:	00 
     45f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     466:	00 
     467:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46a:	89 04 24             	mov    %eax,(%esp)
     46d:	e8 1e 09 00 00       	call   d90 <memset>
  cmd->type = PIPE;
     472:	8b 45 f4             	mov    -0xc(%ebp),%eax
     475:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     47b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     47e:	8b 55 08             	mov    0x8(%ebp),%edx
     481:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     484:	8b 45 f4             	mov    -0xc(%ebp),%eax
     487:	8b 55 0c             	mov    0xc(%ebp),%edx
     48a:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     48d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     490:	c9                   	leave  
     491:	c3                   	ret    

00000492 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     492:	55                   	push   %ebp
     493:	89 e5                	mov    %esp,%ebp
     495:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     498:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     49f:	e8 e9 10 00 00       	call   158d <malloc>
     4a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4a7:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4ae:	00 
     4af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4b6:	00 
     4b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ba:	89 04 24             	mov    %eax,(%esp)
     4bd:	e8 ce 08 00 00       	call   d90 <memset>
  cmd->type = LIST;
     4c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c5:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ce:	8b 55 08             	mov    0x8(%ebp),%edx
     4d1:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d7:	8b 55 0c             	mov    0xc(%ebp),%edx
     4da:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4e0:	c9                   	leave  
     4e1:	c3                   	ret    

000004e2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     4e2:	55                   	push   %ebp
     4e3:	89 e5                	mov    %esp,%ebp
     4e5:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4e8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     4ef:	e8 99 10 00 00       	call   158d <malloc>
     4f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4f7:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     4fe:	00 
     4ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     506:	00 
     507:	8b 45 f4             	mov    -0xc(%ebp),%eax
     50a:	89 04 24             	mov    %eax,(%esp)
     50d:	e8 7e 08 00 00       	call   d90 <memset>
  cmd->type = BACK;
     512:	8b 45 f4             	mov    -0xc(%ebp),%eax
     515:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     51b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     51e:	8b 55 08             	mov    0x8(%ebp),%edx
     521:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     524:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     527:	c9                   	leave  
     528:	c3                   	ret    

00000529 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     529:	55                   	push   %ebp
     52a:	89 e5                	mov    %esp,%ebp
     52c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;

  s = *ps;
     52f:	8b 45 08             	mov    0x8(%ebp),%eax
     532:	8b 00                	mov    (%eax),%eax
     534:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     537:	eb 03                	jmp    53c <gettoken+0x13>
    s++;
     539:	ff 45 f4             	incl   -0xc(%ebp)
{
  char *s;
  int ret;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
     53c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     53f:	3b 45 0c             	cmp    0xc(%ebp),%eax
     542:	73 1c                	jae    560 <gettoken+0x37>
     544:	8b 45 f4             	mov    -0xc(%ebp),%eax
     547:	8a 00                	mov    (%eax),%al
     549:	0f be c0             	movsbl %al,%eax
     54c:	89 44 24 04          	mov    %eax,0x4(%esp)
     550:	c7 04 24 08 1c 00 00 	movl   $0x1c08,(%esp)
     557:	e8 58 08 00 00       	call   db4 <strchr>
     55c:	85 c0                	test   %eax,%eax
     55e:	75 d9                	jne    539 <gettoken+0x10>
    s++;
  if(q)
     560:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     564:	74 08                	je     56e <gettoken+0x45>
    *q = s;
     566:	8b 45 10             	mov    0x10(%ebp),%eax
     569:	8b 55 f4             	mov    -0xc(%ebp),%edx
     56c:	89 10                	mov    %edx,(%eax)
  ret = *s;
     56e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     571:	8a 00                	mov    (%eax),%al
     573:	0f be c0             	movsbl %al,%eax
     576:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     579:	8b 45 f4             	mov    -0xc(%ebp),%eax
     57c:	8a 00                	mov    (%eax),%al
     57e:	0f be c0             	movsbl %al,%eax
     581:	83 f8 29             	cmp    $0x29,%eax
     584:	7f 14                	jg     59a <gettoken+0x71>
     586:	83 f8 28             	cmp    $0x28,%eax
     589:	7d 28                	jge    5b3 <gettoken+0x8a>
     58b:	85 c0                	test   %eax,%eax
     58d:	0f 84 8d 00 00 00    	je     620 <gettoken+0xf7>
     593:	83 f8 26             	cmp    $0x26,%eax
     596:	74 1b                	je     5b3 <gettoken+0x8a>
     598:	eb 38                	jmp    5d2 <gettoken+0xa9>
     59a:	83 f8 3e             	cmp    $0x3e,%eax
     59d:	74 19                	je     5b8 <gettoken+0x8f>
     59f:	83 f8 3e             	cmp    $0x3e,%eax
     5a2:	7f 0a                	jg     5ae <gettoken+0x85>
     5a4:	83 e8 3b             	sub    $0x3b,%eax
     5a7:	83 f8 01             	cmp    $0x1,%eax
     5aa:	77 26                	ja     5d2 <gettoken+0xa9>
     5ac:	eb 05                	jmp    5b3 <gettoken+0x8a>
     5ae:	83 f8 7c             	cmp    $0x7c,%eax
     5b1:	75 1f                	jne    5d2 <gettoken+0xa9>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5b3:	ff 45 f4             	incl   -0xc(%ebp)
    break;
     5b6:	eb 69                	jmp    621 <gettoken+0xf8>
  case '>':
    s++;
     5b8:	ff 45 f4             	incl   -0xc(%ebp)
    if(*s == '>'){
     5bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5be:	8a 00                	mov    (%eax),%al
     5c0:	3c 3e                	cmp    $0x3e,%al
     5c2:	75 0c                	jne    5d0 <gettoken+0xa7>
      ret = '+';
     5c4:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     5cb:	ff 45 f4             	incl   -0xc(%ebp)
    }
    break;
     5ce:	eb 51                	jmp    621 <gettoken+0xf8>
     5d0:	eb 4f                	jmp    621 <gettoken+0xf8>
  default:
    ret = 'a';
     5d2:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5d9:	eb 03                	jmp    5de <gettoken+0xb5>
      s++;
     5db:	ff 45 f4             	incl   -0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5de:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
     5e4:	73 38                	jae    61e <gettoken+0xf5>
     5e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5e9:	8a 00                	mov    (%eax),%al
     5eb:	0f be c0             	movsbl %al,%eax
     5ee:	89 44 24 04          	mov    %eax,0x4(%esp)
     5f2:	c7 04 24 08 1c 00 00 	movl   $0x1c08,(%esp)
     5f9:	e8 b6 07 00 00       	call   db4 <strchr>
     5fe:	85 c0                	test   %eax,%eax
     600:	75 1c                	jne    61e <gettoken+0xf5>
     602:	8b 45 f4             	mov    -0xc(%ebp),%eax
     605:	8a 00                	mov    (%eax),%al
     607:	0f be c0             	movsbl %al,%eax
     60a:	89 44 24 04          	mov    %eax,0x4(%esp)
     60e:	c7 04 24 0e 1c 00 00 	movl   $0x1c0e,(%esp)
     615:	e8 9a 07 00 00       	call   db4 <strchr>
     61a:	85 c0                	test   %eax,%eax
     61c:	74 bd                	je     5db <gettoken+0xb2>
      s++;
    break;
     61e:	eb 01                	jmp    621 <gettoken+0xf8>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     620:	90                   	nop
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     621:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     625:	74 0a                	je     631 <gettoken+0x108>
    *eq = s;
     627:	8b 45 14             	mov    0x14(%ebp),%eax
     62a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     62d:	89 10                	mov    %edx,(%eax)

  while(s < es && strchr(whitespace, *s))
     62f:	eb 05                	jmp    636 <gettoken+0x10d>
     631:	eb 03                	jmp    636 <gettoken+0x10d>
    s++;
     633:	ff 45 f4             	incl   -0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;

  while(s < es && strchr(whitespace, *s))
     636:	8b 45 f4             	mov    -0xc(%ebp),%eax
     639:	3b 45 0c             	cmp    0xc(%ebp),%eax
     63c:	73 1c                	jae    65a <gettoken+0x131>
     63e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     641:	8a 00                	mov    (%eax),%al
     643:	0f be c0             	movsbl %al,%eax
     646:	89 44 24 04          	mov    %eax,0x4(%esp)
     64a:	c7 04 24 08 1c 00 00 	movl   $0x1c08,(%esp)
     651:	e8 5e 07 00 00       	call   db4 <strchr>
     656:	85 c0                	test   %eax,%eax
     658:	75 d9                	jne    633 <gettoken+0x10a>
    s++;
  *ps = s;
     65a:	8b 45 08             	mov    0x8(%ebp),%eax
     65d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     660:	89 10                	mov    %edx,(%eax)
  return ret;
     662:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     665:	c9                   	leave  
     666:	c3                   	ret    

00000667 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     667:	55                   	push   %ebp
     668:	89 e5                	mov    %esp,%ebp
     66a:	83 ec 28             	sub    $0x28,%esp
  char *s;

  s = *ps;
     66d:	8b 45 08             	mov    0x8(%ebp),%eax
     670:	8b 00                	mov    (%eax),%eax
     672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     675:	eb 03                	jmp    67a <peek+0x13>
    s++;
     677:	ff 45 f4             	incl   -0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
     67a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     67d:	3b 45 0c             	cmp    0xc(%ebp),%eax
     680:	73 1c                	jae    69e <peek+0x37>
     682:	8b 45 f4             	mov    -0xc(%ebp),%eax
     685:	8a 00                	mov    (%eax),%al
     687:	0f be c0             	movsbl %al,%eax
     68a:	89 44 24 04          	mov    %eax,0x4(%esp)
     68e:	c7 04 24 08 1c 00 00 	movl   $0x1c08,(%esp)
     695:	e8 1a 07 00 00       	call   db4 <strchr>
     69a:	85 c0                	test   %eax,%eax
     69c:	75 d9                	jne    677 <peek+0x10>
    s++;
  *ps = s;
     69e:	8b 45 08             	mov    0x8(%ebp),%eax
     6a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6a4:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a9:	8a 00                	mov    (%eax),%al
     6ab:	84 c0                	test   %al,%al
     6ad:	74 22                	je     6d1 <peek+0x6a>
     6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6b2:	8a 00                	mov    (%eax),%al
     6b4:	0f be c0             	movsbl %al,%eax
     6b7:	89 44 24 04          	mov    %eax,0x4(%esp)
     6bb:	8b 45 10             	mov    0x10(%ebp),%eax
     6be:	89 04 24             	mov    %eax,(%esp)
     6c1:	e8 ee 06 00 00       	call   db4 <strchr>
     6c6:	85 c0                	test   %eax,%eax
     6c8:	74 07                	je     6d1 <peek+0x6a>
     6ca:	b8 01 00 00 00       	mov    $0x1,%eax
     6cf:	eb 05                	jmp    6d6 <peek+0x6f>
     6d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
     6d6:	c9                   	leave  
     6d7:	c3                   	ret    

000006d8 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     6d8:	55                   	push   %ebp
     6d9:	89 e5                	mov    %esp,%ebp
     6db:	53                   	push   %ebx
     6dc:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     6df:	8b 5d 08             	mov    0x8(%ebp),%ebx
     6e2:	8b 45 08             	mov    0x8(%ebp),%eax
     6e5:	89 04 24             	mov    %eax,(%esp)
     6e8:	e8 7e 06 00 00       	call   d6b <strlen>
     6ed:	01 d8                	add    %ebx,%eax
     6ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     6f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f5:	89 44 24 04          	mov    %eax,0x4(%esp)
     6f9:	8d 45 08             	lea    0x8(%ebp),%eax
     6fc:	89 04 24             	mov    %eax,(%esp)
     6ff:	e8 60 00 00 00       	call   764 <parseline>
     704:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     707:	c7 44 24 08 d2 16 00 	movl   $0x16d2,0x8(%esp)
     70e:	00 
     70f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     712:	89 44 24 04          	mov    %eax,0x4(%esp)
     716:	8d 45 08             	lea    0x8(%ebp),%eax
     719:	89 04 24             	mov    %eax,(%esp)
     71c:	e8 46 ff ff ff       	call   667 <peek>
  if(s != es){
     721:	8b 45 08             	mov    0x8(%ebp),%eax
     724:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     727:	74 27                	je     750 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     729:	8b 45 08             	mov    0x8(%ebp),%eax
     72c:	89 44 24 08          	mov    %eax,0x8(%esp)
     730:	c7 44 24 04 d3 16 00 	movl   $0x16d3,0x4(%esp)
     737:	00 
     738:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     73f:	e8 61 0b 00 00       	call   12a5 <printf>
    panic("syntax");
     744:	c7 04 24 e2 16 00 00 	movl   $0x16e2,(%esp)
     74b:	e8 fe fb ff ff       	call   34e <panic>
  }
  nulterminate(cmd);
     750:	8b 45 f0             	mov    -0x10(%ebp),%eax
     753:	89 04 24             	mov    %eax,(%esp)
     756:	e8 a2 04 00 00       	call   bfd <nulterminate>
  return cmd;
     75b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     75e:	83 c4 24             	add    $0x24,%esp
     761:	5b                   	pop    %ebx
     762:	5d                   	pop    %ebp
     763:	c3                   	ret    

00000764 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     764:	55                   	push   %ebp
     765:	89 e5                	mov    %esp,%ebp
     767:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     76a:	8b 45 0c             	mov    0xc(%ebp),%eax
     76d:	89 44 24 04          	mov    %eax,0x4(%esp)
     771:	8b 45 08             	mov    0x8(%ebp),%eax
     774:	89 04 24             	mov    %eax,(%esp)
     777:	e8 bc 00 00 00       	call   838 <parsepipe>
     77c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     77f:	eb 30                	jmp    7b1 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     781:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     788:	00 
     789:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     790:	00 
     791:	8b 45 0c             	mov    0xc(%ebp),%eax
     794:	89 44 24 04          	mov    %eax,0x4(%esp)
     798:	8b 45 08             	mov    0x8(%ebp),%eax
     79b:	89 04 24             	mov    %eax,(%esp)
     79e:	e8 86 fd ff ff       	call   529 <gettoken>
    cmd = backcmd(cmd);
     7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7a6:	89 04 24             	mov    %eax,(%esp)
     7a9:	e8 34 fd ff ff       	call   4e2 <backcmd>
     7ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7b1:	c7 44 24 08 e9 16 00 	movl   $0x16e9,0x8(%esp)
     7b8:	00 
     7b9:	8b 45 0c             	mov    0xc(%ebp),%eax
     7bc:	89 44 24 04          	mov    %eax,0x4(%esp)
     7c0:	8b 45 08             	mov    0x8(%ebp),%eax
     7c3:	89 04 24             	mov    %eax,(%esp)
     7c6:	e8 9c fe ff ff       	call   667 <peek>
     7cb:	85 c0                	test   %eax,%eax
     7cd:	75 b2                	jne    781 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     7cf:	c7 44 24 08 eb 16 00 	movl   $0x16eb,0x8(%esp)
     7d6:	00 
     7d7:	8b 45 0c             	mov    0xc(%ebp),%eax
     7da:	89 44 24 04          	mov    %eax,0x4(%esp)
     7de:	8b 45 08             	mov    0x8(%ebp),%eax
     7e1:	89 04 24             	mov    %eax,(%esp)
     7e4:	e8 7e fe ff ff       	call   667 <peek>
     7e9:	85 c0                	test   %eax,%eax
     7eb:	74 46                	je     833 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     7ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7f4:	00 
     7f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7fc:	00 
     7fd:	8b 45 0c             	mov    0xc(%ebp),%eax
     800:	89 44 24 04          	mov    %eax,0x4(%esp)
     804:	8b 45 08             	mov    0x8(%ebp),%eax
     807:	89 04 24             	mov    %eax,(%esp)
     80a:	e8 1a fd ff ff       	call   529 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     80f:	8b 45 0c             	mov    0xc(%ebp),%eax
     812:	89 44 24 04          	mov    %eax,0x4(%esp)
     816:	8b 45 08             	mov    0x8(%ebp),%eax
     819:	89 04 24             	mov    %eax,(%esp)
     81c:	e8 43 ff ff ff       	call   764 <parseline>
     821:	89 44 24 04          	mov    %eax,0x4(%esp)
     825:	8b 45 f4             	mov    -0xc(%ebp),%eax
     828:	89 04 24             	mov    %eax,(%esp)
     82b:	e8 62 fc ff ff       	call   492 <listcmd>
     830:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     833:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     836:	c9                   	leave  
     837:	c3                   	ret    

00000838 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     838:	55                   	push   %ebp
     839:	89 e5                	mov    %esp,%ebp
     83b:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     83e:	8b 45 0c             	mov    0xc(%ebp),%eax
     841:	89 44 24 04          	mov    %eax,0x4(%esp)
     845:	8b 45 08             	mov    0x8(%ebp),%eax
     848:	89 04 24             	mov    %eax,(%esp)
     84b:	e8 68 02 00 00       	call   ab8 <parseexec>
     850:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     853:	c7 44 24 08 ed 16 00 	movl   $0x16ed,0x8(%esp)
     85a:	00 
     85b:	8b 45 0c             	mov    0xc(%ebp),%eax
     85e:	89 44 24 04          	mov    %eax,0x4(%esp)
     862:	8b 45 08             	mov    0x8(%ebp),%eax
     865:	89 04 24             	mov    %eax,(%esp)
     868:	e8 fa fd ff ff       	call   667 <peek>
     86d:	85 c0                	test   %eax,%eax
     86f:	74 46                	je     8b7 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     871:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     878:	00 
     879:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     880:	00 
     881:	8b 45 0c             	mov    0xc(%ebp),%eax
     884:	89 44 24 04          	mov    %eax,0x4(%esp)
     888:	8b 45 08             	mov    0x8(%ebp),%eax
     88b:	89 04 24             	mov    %eax,(%esp)
     88e:	e8 96 fc ff ff       	call   529 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     893:	8b 45 0c             	mov    0xc(%ebp),%eax
     896:	89 44 24 04          	mov    %eax,0x4(%esp)
     89a:	8b 45 08             	mov    0x8(%ebp),%eax
     89d:	89 04 24             	mov    %eax,(%esp)
     8a0:	e8 93 ff ff ff       	call   838 <parsepipe>
     8a5:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ac:	89 04 24             	mov    %eax,(%esp)
     8af:	e8 8e fb ff ff       	call   442 <pipecmd>
     8b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8ba:	c9                   	leave  
     8bb:	c3                   	ret    

000008bc <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8bc:	55                   	push   %ebp
     8bd:	89 e5                	mov    %esp,%ebp
     8bf:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8c2:	e9 f6 00 00 00       	jmp    9bd <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     8c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8ce:	00 
     8cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8d6:	00 
     8d7:	8b 45 10             	mov    0x10(%ebp),%eax
     8da:	89 44 24 04          	mov    %eax,0x4(%esp)
     8de:	8b 45 0c             	mov    0xc(%ebp),%eax
     8e1:	89 04 24             	mov    %eax,(%esp)
     8e4:	e8 40 fc ff ff       	call   529 <gettoken>
     8e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     8ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
     8ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
     8f6:	89 44 24 08          	mov    %eax,0x8(%esp)
     8fa:	8b 45 10             	mov    0x10(%ebp),%eax
     8fd:	89 44 24 04          	mov    %eax,0x4(%esp)
     901:	8b 45 0c             	mov    0xc(%ebp),%eax
     904:	89 04 24             	mov    %eax,(%esp)
     907:	e8 1d fc ff ff       	call   529 <gettoken>
     90c:	83 f8 61             	cmp    $0x61,%eax
     90f:	74 0c                	je     91d <parseredirs+0x61>
      panic("missing file for redirection");
     911:	c7 04 24 ef 16 00 00 	movl   $0x16ef,(%esp)
     918:	e8 31 fa ff ff       	call   34e <panic>
    switch(tok){
     91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     920:	83 f8 3c             	cmp    $0x3c,%eax
     923:	74 0f                	je     934 <parseredirs+0x78>
     925:	83 f8 3e             	cmp    $0x3e,%eax
     928:	74 38                	je     962 <parseredirs+0xa6>
     92a:	83 f8 2b             	cmp    $0x2b,%eax
     92d:	74 61                	je     990 <parseredirs+0xd4>
     92f:	e9 89 00 00 00       	jmp    9bd <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     934:	8b 55 ec             	mov    -0x14(%ebp),%edx
     937:	8b 45 f0             	mov    -0x10(%ebp),%eax
     93a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     941:	00 
     942:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     949:	00 
     94a:	89 54 24 08          	mov    %edx,0x8(%esp)
     94e:	89 44 24 04          	mov    %eax,0x4(%esp)
     952:	8b 45 08             	mov    0x8(%ebp),%eax
     955:	89 04 24             	mov    %eax,(%esp)
     958:	e8 7a fa ff ff       	call   3d7 <redircmd>
     95d:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     960:	eb 5b                	jmp    9bd <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     962:	8b 55 ec             	mov    -0x14(%ebp),%edx
     965:	8b 45 f0             	mov    -0x10(%ebp),%eax
     968:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     96f:	00 
     970:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     977:	00 
     978:	89 54 24 08          	mov    %edx,0x8(%esp)
     97c:	89 44 24 04          	mov    %eax,0x4(%esp)
     980:	8b 45 08             	mov    0x8(%ebp),%eax
     983:	89 04 24             	mov    %eax,(%esp)
     986:	e8 4c fa ff ff       	call   3d7 <redircmd>
     98b:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     98e:	eb 2d                	jmp    9bd <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     990:	8b 55 ec             	mov    -0x14(%ebp),%edx
     993:	8b 45 f0             	mov    -0x10(%ebp),%eax
     996:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     99d:	00 
     99e:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9a5:	00 
     9a6:	89 54 24 08          	mov    %edx,0x8(%esp)
     9aa:	89 44 24 04          	mov    %eax,0x4(%esp)
     9ae:	8b 45 08             	mov    0x8(%ebp),%eax
     9b1:	89 04 24             	mov    %eax,(%esp)
     9b4:	e8 1e fa ff ff       	call   3d7 <redircmd>
     9b9:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9bc:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9bd:	c7 44 24 08 0c 17 00 	movl   $0x170c,0x8(%esp)
     9c4:	00 
     9c5:	8b 45 10             	mov    0x10(%ebp),%eax
     9c8:	89 44 24 04          	mov    %eax,0x4(%esp)
     9cc:	8b 45 0c             	mov    0xc(%ebp),%eax
     9cf:	89 04 24             	mov    %eax,(%esp)
     9d2:	e8 90 fc ff ff       	call   667 <peek>
     9d7:	85 c0                	test   %eax,%eax
     9d9:	0f 85 e8 fe ff ff    	jne    8c7 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     9df:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9e2:	c9                   	leave  
     9e3:	c3                   	ret    

000009e4 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     9e4:	55                   	push   %ebp
     9e5:	89 e5                	mov    %esp,%ebp
     9e7:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     9ea:	c7 44 24 08 0f 17 00 	movl   $0x170f,0x8(%esp)
     9f1:	00 
     9f2:	8b 45 0c             	mov    0xc(%ebp),%eax
     9f5:	89 44 24 04          	mov    %eax,0x4(%esp)
     9f9:	8b 45 08             	mov    0x8(%ebp),%eax
     9fc:	89 04 24             	mov    %eax,(%esp)
     9ff:	e8 63 fc ff ff       	call   667 <peek>
     a04:	85 c0                	test   %eax,%eax
     a06:	75 0c                	jne    a14 <parseblock+0x30>
    panic("parseblock");
     a08:	c7 04 24 11 17 00 00 	movl   $0x1711,(%esp)
     a0f:	e8 3a f9 ff ff       	call   34e <panic>
  gettoken(ps, es, 0, 0);
     a14:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a1b:	00 
     a1c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a23:	00 
     a24:	8b 45 0c             	mov    0xc(%ebp),%eax
     a27:	89 44 24 04          	mov    %eax,0x4(%esp)
     a2b:	8b 45 08             	mov    0x8(%ebp),%eax
     a2e:	89 04 24             	mov    %eax,(%esp)
     a31:	e8 f3 fa ff ff       	call   529 <gettoken>
  cmd = parseline(ps, es);
     a36:	8b 45 0c             	mov    0xc(%ebp),%eax
     a39:	89 44 24 04          	mov    %eax,0x4(%esp)
     a3d:	8b 45 08             	mov    0x8(%ebp),%eax
     a40:	89 04 24             	mov    %eax,(%esp)
     a43:	e8 1c fd ff ff       	call   764 <parseline>
     a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a4b:	c7 44 24 08 1c 17 00 	movl   $0x171c,0x8(%esp)
     a52:	00 
     a53:	8b 45 0c             	mov    0xc(%ebp),%eax
     a56:	89 44 24 04          	mov    %eax,0x4(%esp)
     a5a:	8b 45 08             	mov    0x8(%ebp),%eax
     a5d:	89 04 24             	mov    %eax,(%esp)
     a60:	e8 02 fc ff ff       	call   667 <peek>
     a65:	85 c0                	test   %eax,%eax
     a67:	75 0c                	jne    a75 <parseblock+0x91>
    panic("syntax - missing )");
     a69:	c7 04 24 1e 17 00 00 	movl   $0x171e,(%esp)
     a70:	e8 d9 f8 ff ff       	call   34e <panic>
  gettoken(ps, es, 0, 0);
     a75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a7c:	00 
     a7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a84:	00 
     a85:	8b 45 0c             	mov    0xc(%ebp),%eax
     a88:	89 44 24 04          	mov    %eax,0x4(%esp)
     a8c:	8b 45 08             	mov    0x8(%ebp),%eax
     a8f:	89 04 24             	mov    %eax,(%esp)
     a92:	e8 92 fa ff ff       	call   529 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     a97:	8b 45 0c             	mov    0xc(%ebp),%eax
     a9a:	89 44 24 08          	mov    %eax,0x8(%esp)
     a9e:	8b 45 08             	mov    0x8(%ebp),%eax
     aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
     aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aa8:	89 04 24             	mov    %eax,(%esp)
     aab:	e8 0c fe ff ff       	call   8bc <parseredirs>
     ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     ab6:	c9                   	leave  
     ab7:	c3                   	ret    

00000ab8 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     ab8:	55                   	push   %ebp
     ab9:	89 e5                	mov    %esp,%ebp
     abb:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     abe:	c7 44 24 08 0f 17 00 	movl   $0x170f,0x8(%esp)
     ac5:	00 
     ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
     ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
     acd:	8b 45 08             	mov    0x8(%ebp),%eax
     ad0:	89 04 24             	mov    %eax,(%esp)
     ad3:	e8 8f fb ff ff       	call   667 <peek>
     ad8:	85 c0                	test   %eax,%eax
     ada:	74 17                	je     af3 <parseexec+0x3b>
    return parseblock(ps, es);
     adc:	8b 45 0c             	mov    0xc(%ebp),%eax
     adf:	89 44 24 04          	mov    %eax,0x4(%esp)
     ae3:	8b 45 08             	mov    0x8(%ebp),%eax
     ae6:	89 04 24             	mov    %eax,(%esp)
     ae9:	e8 f6 fe ff ff       	call   9e4 <parseblock>
     aee:	e9 08 01 00 00       	jmp    bfb <parseexec+0x143>

  ret = execcmd();
     af3:	e8 a1 f8 ff ff       	call   399 <execcmd>
     af8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     afe:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b08:	8b 45 0c             	mov    0xc(%ebp),%eax
     b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
     b0f:	8b 45 08             	mov    0x8(%ebp),%eax
     b12:	89 44 24 04          	mov    %eax,0x4(%esp)
     b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b19:	89 04 24             	mov    %eax,(%esp)
     b1c:	e8 9b fd ff ff       	call   8bc <parseredirs>
     b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b24:	e9 8e 00 00 00       	jmp    bb7 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b29:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b33:	89 44 24 08          	mov    %eax,0x8(%esp)
     b37:	8b 45 0c             	mov    0xc(%ebp),%eax
     b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
     b3e:	8b 45 08             	mov    0x8(%ebp),%eax
     b41:	89 04 24             	mov    %eax,(%esp)
     b44:	e8 e0 f9 ff ff       	call   529 <gettoken>
     b49:	89 45 e8             	mov    %eax,-0x18(%ebp)
     b4c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b50:	75 05                	jne    b57 <parseexec+0x9f>
      break;
     b52:	e9 82 00 00 00       	jmp    bd9 <parseexec+0x121>
    if(tok != 'a')
     b57:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b5b:	74 0c                	je     b69 <parseexec+0xb1>
      panic("syntax");
     b5d:	c7 04 24 e2 16 00 00 	movl   $0x16e2,(%esp)
     b64:	e8 e5 f7 ff ff       	call   34e <panic>
    cmd->argv[argc] = q;
     b69:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b72:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     b76:	8b 55 e0             	mov    -0x20(%ebp),%edx
     b79:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b7c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     b7f:	83 c1 08             	add    $0x8,%ecx
     b82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     b86:	ff 45 f4             	incl   -0xc(%ebp)
    if(argc >= MAXARGS)
     b89:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b8d:	7e 0c                	jle    b9b <parseexec+0xe3>
      panic("too many args");
     b8f:	c7 04 24 31 17 00 00 	movl   $0x1731,(%esp)
     b96:	e8 b3 f7 ff ff       	call   34e <panic>
    ret = parseredirs(ret, ps, es);
     b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
     b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
     ba2:	8b 45 08             	mov    0x8(%ebp),%eax
     ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bac:	89 04 24             	mov    %eax,(%esp)
     baf:	e8 08 fd ff ff       	call   8bc <parseredirs>
     bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     bb7:	c7 44 24 08 3f 17 00 	movl   $0x173f,0x8(%esp)
     bbe:	00 
     bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
     bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
     bc6:	8b 45 08             	mov    0x8(%ebp),%eax
     bc9:	89 04 24             	mov    %eax,(%esp)
     bcc:	e8 96 fa ff ff       	call   667 <peek>
     bd1:	85 c0                	test   %eax,%eax
     bd3:	0f 84 50 ff ff ff    	je     b29 <parseexec+0x71>
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bdf:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     be6:	00 
  cmd->eargv[argc] = 0;
     be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bed:	83 c2 08             	add    $0x8,%edx
     bf0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     bf7:	00 
  return ret;
     bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     bfb:	c9                   	leave  
     bfc:	c3                   	ret    

00000bfd <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     bfd:	55                   	push   %ebp
     bfe:	89 e5                	mov    %esp,%ebp
     c00:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c07:	75 0a                	jne    c13 <nulterminate+0x16>
    return 0;
     c09:	b8 00 00 00 00       	mov    $0x0,%eax
     c0e:	e9 c8 00 00 00       	jmp    cdb <nulterminate+0xde>

  switch(cmd->type){
     c13:	8b 45 08             	mov    0x8(%ebp),%eax
     c16:	8b 00                	mov    (%eax),%eax
     c18:	83 f8 05             	cmp    $0x5,%eax
     c1b:	0f 87 b7 00 00 00    	ja     cd8 <nulterminate+0xdb>
     c21:	8b 04 85 44 17 00 00 	mov    0x1744(,%eax,4),%eax
     c28:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c2a:	8b 45 08             	mov    0x8(%ebp),%eax
     c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c37:	eb 13                	jmp    c4c <nulterminate+0x4f>
      *ecmd->eargv[i] = 0;
     c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c3f:	83 c2 08             	add    $0x8,%edx
     c42:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     c46:	c6 00 00             	movb   $0x0,(%eax)
    return 0;

  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     c49:	ff 45 f4             	incl   -0xc(%ebp)
     c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c52:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c56:	85 c0                	test   %eax,%eax
     c58:	75 df                	jne    c39 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     c5a:	eb 7c                	jmp    cd8 <nulterminate+0xdb>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     c5c:	8b 45 08             	mov    0x8(%ebp),%eax
     c5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c65:	8b 40 04             	mov    0x4(%eax),%eax
     c68:	89 04 24             	mov    %eax,(%esp)
     c6b:	e8 8d ff ff ff       	call   bfd <nulterminate>
    *rcmd->efile = 0;
     c70:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c73:	8b 40 0c             	mov    0xc(%eax),%eax
     c76:	c6 00 00             	movb   $0x0,(%eax)
    break;
     c79:	eb 5d                	jmp    cd8 <nulterminate+0xdb>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c7b:	8b 45 08             	mov    0x8(%ebp),%eax
     c7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c84:	8b 40 04             	mov    0x4(%eax),%eax
     c87:	89 04 24             	mov    %eax,(%esp)
     c8a:	e8 6e ff ff ff       	call   bfd <nulterminate>
    nulterminate(pcmd->right);
     c8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c92:	8b 40 08             	mov    0x8(%eax),%eax
     c95:	89 04 24             	mov    %eax,(%esp)
     c98:	e8 60 ff ff ff       	call   bfd <nulterminate>
    break;
     c9d:	eb 39                	jmp    cd8 <nulterminate+0xdb>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     c9f:	8b 45 08             	mov    0x8(%ebp),%eax
     ca2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ca8:	8b 40 04             	mov    0x4(%eax),%eax
     cab:	89 04 24             	mov    %eax,(%esp)
     cae:	e8 4a ff ff ff       	call   bfd <nulterminate>
    nulterminate(lcmd->right);
     cb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cb6:	8b 40 08             	mov    0x8(%eax),%eax
     cb9:	89 04 24             	mov    %eax,(%esp)
     cbc:	e8 3c ff ff ff       	call   bfd <nulterminate>
    break;
     cc1:	eb 15                	jmp    cd8 <nulterminate+0xdb>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     cc3:	8b 45 08             	mov    0x8(%ebp),%eax
     cc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     cc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     ccc:	8b 40 04             	mov    0x4(%eax),%eax
     ccf:	89 04 24             	mov    %eax,(%esp)
     cd2:	e8 26 ff ff ff       	call   bfd <nulterminate>
    break;
     cd7:	90                   	nop
  }
  return cmd;
     cd8:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cdb:	c9                   	leave  
     cdc:	c3                   	ret    
     cdd:	90                   	nop
     cde:	90                   	nop
     cdf:	90                   	nop

00000ce0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     ce0:	55                   	push   %ebp
     ce1:	89 e5                	mov    %esp,%ebp
     ce3:	57                   	push   %edi
     ce4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
     ce8:	8b 55 10             	mov    0x10(%ebp),%edx
     ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
     cee:	89 cb                	mov    %ecx,%ebx
     cf0:	89 df                	mov    %ebx,%edi
     cf2:	89 d1                	mov    %edx,%ecx
     cf4:	fc                   	cld    
     cf5:	f3 aa                	rep stos %al,%es:(%edi)
     cf7:	89 ca                	mov    %ecx,%edx
     cf9:	89 fb                	mov    %edi,%ebx
     cfb:	89 5d 08             	mov    %ebx,0x8(%ebp)
     cfe:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d01:	5b                   	pop    %ebx
     d02:	5f                   	pop    %edi
     d03:	5d                   	pop    %ebp
     d04:	c3                   	ret    

00000d05 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d05:	55                   	push   %ebp
     d06:	89 e5                	mov    %esp,%ebp
     d08:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d0b:	8b 45 08             	mov    0x8(%ebp),%eax
     d0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d11:	90                   	nop
     d12:	8b 45 08             	mov    0x8(%ebp),%eax
     d15:	8d 50 01             	lea    0x1(%eax),%edx
     d18:	89 55 08             	mov    %edx,0x8(%ebp)
     d1b:	8b 55 0c             	mov    0xc(%ebp),%edx
     d1e:	8d 4a 01             	lea    0x1(%edx),%ecx
     d21:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     d24:	8a 12                	mov    (%edx),%dl
     d26:	88 10                	mov    %dl,(%eax)
     d28:	8a 00                	mov    (%eax),%al
     d2a:	84 c0                	test   %al,%al
     d2c:	75 e4                	jne    d12 <strcpy+0xd>
    ;
  return os;
     d2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d31:	c9                   	leave  
     d32:	c3                   	ret    

00000d33 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d33:	55                   	push   %ebp
     d34:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     d36:	eb 06                	jmp    d3e <strcmp+0xb>
    p++, q++;
     d38:	ff 45 08             	incl   0x8(%ebp)
     d3b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d3e:	8b 45 08             	mov    0x8(%ebp),%eax
     d41:	8a 00                	mov    (%eax),%al
     d43:	84 c0                	test   %al,%al
     d45:	74 0e                	je     d55 <strcmp+0x22>
     d47:	8b 45 08             	mov    0x8(%ebp),%eax
     d4a:	8a 10                	mov    (%eax),%dl
     d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
     d4f:	8a 00                	mov    (%eax),%al
     d51:	38 c2                	cmp    %al,%dl
     d53:	74 e3                	je     d38 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     d55:	8b 45 08             	mov    0x8(%ebp),%eax
     d58:	8a 00                	mov    (%eax),%al
     d5a:	0f b6 d0             	movzbl %al,%edx
     d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
     d60:	8a 00                	mov    (%eax),%al
     d62:	0f b6 c0             	movzbl %al,%eax
     d65:	29 c2                	sub    %eax,%edx
     d67:	89 d0                	mov    %edx,%eax
}
     d69:	5d                   	pop    %ebp
     d6a:	c3                   	ret    

00000d6b <strlen>:

uint
strlen(char *s)
{
     d6b:	55                   	push   %ebp
     d6c:	89 e5                	mov    %esp,%ebp
     d6e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     d71:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     d78:	eb 03                	jmp    d7d <strlen+0x12>
     d7a:	ff 45 fc             	incl   -0x4(%ebp)
     d7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
     d80:	8b 45 08             	mov    0x8(%ebp),%eax
     d83:	01 d0                	add    %edx,%eax
     d85:	8a 00                	mov    (%eax),%al
     d87:	84 c0                	test   %al,%al
     d89:	75 ef                	jne    d7a <strlen+0xf>
    ;
  return n;
     d8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d8e:	c9                   	leave  
     d8f:	c3                   	ret    

00000d90 <memset>:

void*
memset(void *dst, int c, uint n)
{
     d90:	55                   	push   %ebp
     d91:	89 e5                	mov    %esp,%ebp
     d93:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     d96:	8b 45 10             	mov    0x10(%ebp),%eax
     d99:	89 44 24 08          	mov    %eax,0x8(%esp)
     d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
     da0:	89 44 24 04          	mov    %eax,0x4(%esp)
     da4:	8b 45 08             	mov    0x8(%ebp),%eax
     da7:	89 04 24             	mov    %eax,(%esp)
     daa:	e8 31 ff ff ff       	call   ce0 <stosb>
  return dst;
     daf:	8b 45 08             	mov    0x8(%ebp),%eax
}
     db2:	c9                   	leave  
     db3:	c3                   	ret    

00000db4 <strchr>:

char*
strchr(const char *s, char c)
{
     db4:	55                   	push   %ebp
     db5:	89 e5                	mov    %esp,%ebp
     db7:	83 ec 04             	sub    $0x4,%esp
     dba:	8b 45 0c             	mov    0xc(%ebp),%eax
     dbd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     dc0:	eb 12                	jmp    dd4 <strchr+0x20>
    if(*s == c)
     dc2:	8b 45 08             	mov    0x8(%ebp),%eax
     dc5:	8a 00                	mov    (%eax),%al
     dc7:	3a 45 fc             	cmp    -0x4(%ebp),%al
     dca:	75 05                	jne    dd1 <strchr+0x1d>
      return (char*)s;
     dcc:	8b 45 08             	mov    0x8(%ebp),%eax
     dcf:	eb 11                	jmp    de2 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     dd1:	ff 45 08             	incl   0x8(%ebp)
     dd4:	8b 45 08             	mov    0x8(%ebp),%eax
     dd7:	8a 00                	mov    (%eax),%al
     dd9:	84 c0                	test   %al,%al
     ddb:	75 e5                	jne    dc2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
     de2:	c9                   	leave  
     de3:	c3                   	ret    

00000de4 <gets>:

char*
gets(char *buf, int max)
{
     de4:	55                   	push   %ebp
     de5:	89 e5                	mov    %esp,%ebp
     de7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     dea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     df1:	eb 49                	jmp    e3c <gets+0x58>
    cc = read(0, &c, 1);
     df3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     dfa:	00 
     dfb:	8d 45 ef             	lea    -0x11(%ebp),%eax
     dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
     e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e09:	e8 22 02 00 00       	call   1030 <read>
     e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e15:	7f 02                	jg     e19 <gets+0x35>
      break;
     e17:	eb 2c                	jmp    e45 <gets+0x61>
    buf[i++] = c;
     e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e1c:	8d 50 01             	lea    0x1(%eax),%edx
     e1f:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e22:	89 c2                	mov    %eax,%edx
     e24:	8b 45 08             	mov    0x8(%ebp),%eax
     e27:	01 c2                	add    %eax,%edx
     e29:	8a 45 ef             	mov    -0x11(%ebp),%al
     e2c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     e2e:	8a 45 ef             	mov    -0x11(%ebp),%al
     e31:	3c 0a                	cmp    $0xa,%al
     e33:	74 10                	je     e45 <gets+0x61>
     e35:	8a 45 ef             	mov    -0x11(%ebp),%al
     e38:	3c 0d                	cmp    $0xd,%al
     e3a:	74 09                	je     e45 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e3f:	40                   	inc    %eax
     e40:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e43:	7c ae                	jl     df3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e45:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e48:	8b 45 08             	mov    0x8(%ebp),%eax
     e4b:	01 d0                	add    %edx,%eax
     e4d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     e50:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e53:	c9                   	leave  
     e54:	c3                   	ret    

00000e55 <stat>:

int
stat(char *n, struct stat *st)
{
     e55:	55                   	push   %ebp
     e56:	89 e5                	mov    %esp,%ebp
     e58:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e62:	00 
     e63:	8b 45 08             	mov    0x8(%ebp),%eax
     e66:	89 04 24             	mov    %eax,(%esp)
     e69:	e8 ea 01 00 00       	call   1058 <open>
     e6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     e71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e75:	79 07                	jns    e7e <stat+0x29>
    return -1;
     e77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     e7c:	eb 23                	jmp    ea1 <stat+0x4c>
  r = fstat(fd, st);
     e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
     e81:	89 44 24 04          	mov    %eax,0x4(%esp)
     e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e88:	89 04 24             	mov    %eax,(%esp)
     e8b:	e8 e0 01 00 00       	call   1070 <fstat>
     e90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e96:	89 04 24             	mov    %eax,(%esp)
     e99:	e8 a2 01 00 00       	call   1040 <close>
  return r;
     e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ea1:	c9                   	leave  
     ea2:	c3                   	ret    

00000ea3 <atoi>:

int
atoi(const char *s)
{
     ea3:	55                   	push   %ebp
     ea4:	89 e5                	mov    %esp,%ebp
     ea6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     ea9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     eb0:	eb 24                	jmp    ed6 <atoi+0x33>
    n = n*10 + *s++ - '0';
     eb2:	8b 55 fc             	mov    -0x4(%ebp),%edx
     eb5:	89 d0                	mov    %edx,%eax
     eb7:	c1 e0 02             	shl    $0x2,%eax
     eba:	01 d0                	add    %edx,%eax
     ebc:	01 c0                	add    %eax,%eax
     ebe:	89 c1                	mov    %eax,%ecx
     ec0:	8b 45 08             	mov    0x8(%ebp),%eax
     ec3:	8d 50 01             	lea    0x1(%eax),%edx
     ec6:	89 55 08             	mov    %edx,0x8(%ebp)
     ec9:	8a 00                	mov    (%eax),%al
     ecb:	0f be c0             	movsbl %al,%eax
     ece:	01 c8                	add    %ecx,%eax
     ed0:	83 e8 30             	sub    $0x30,%eax
     ed3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     ed6:	8b 45 08             	mov    0x8(%ebp),%eax
     ed9:	8a 00                	mov    (%eax),%al
     edb:	3c 2f                	cmp    $0x2f,%al
     edd:	7e 09                	jle    ee8 <atoi+0x45>
     edf:	8b 45 08             	mov    0x8(%ebp),%eax
     ee2:	8a 00                	mov    (%eax),%al
     ee4:	3c 39                	cmp    $0x39,%al
     ee6:	7e ca                	jle    eb2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     ee8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     eeb:	c9                   	leave  
     eec:	c3                   	ret    

00000eed <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     eed:	55                   	push   %ebp
     eee:	89 e5                	mov    %esp,%ebp
     ef0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
     ef3:	8b 45 08             	mov    0x8(%ebp),%eax
     ef6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
     efc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     eff:	eb 16                	jmp    f17 <memmove+0x2a>
    *dst++ = *src++;
     f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f04:	8d 50 01             	lea    0x1(%eax),%edx
     f07:	89 55 fc             	mov    %edx,-0x4(%ebp)
     f0a:	8b 55 f8             	mov    -0x8(%ebp),%edx
     f0d:	8d 4a 01             	lea    0x1(%edx),%ecx
     f10:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     f13:	8a 12                	mov    (%edx),%dl
     f15:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f17:	8b 45 10             	mov    0x10(%ebp),%eax
     f1a:	8d 50 ff             	lea    -0x1(%eax),%edx
     f1d:	89 55 10             	mov    %edx,0x10(%ebp)
     f20:	85 c0                	test   %eax,%eax
     f22:	7f dd                	jg     f01 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f24:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f27:	c9                   	leave  
     f28:	c3                   	ret    

00000f29 <itoa>:

int itoa(int value, char *sp, int radix)
{
     f29:	55                   	push   %ebp
     f2a:	89 e5                	mov    %esp,%ebp
     f2c:	53                   	push   %ebx
     f2d:	83 ec 30             	sub    $0x30,%esp
  char tmp[16];
  char *tp = tmp;
     f30:	8d 45 d8             	lea    -0x28(%ebp),%eax
     f33:	89 45 f8             	mov    %eax,-0x8(%ebp)
  int i;
  unsigned v;

  int sign = (radix == 10 && value < 0);    
     f36:	83 7d 10 0a          	cmpl   $0xa,0x10(%ebp)
     f3a:	75 0d                	jne    f49 <itoa+0x20>
     f3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     f40:	79 07                	jns    f49 <itoa+0x20>
     f42:	b8 01 00 00 00       	mov    $0x1,%eax
     f47:	eb 05                	jmp    f4e <itoa+0x25>
     f49:	b8 00 00 00 00       	mov    $0x0,%eax
     f4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (sign)
     f51:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     f55:	74 0a                	je     f61 <itoa+0x38>
      v = -value;
     f57:	8b 45 08             	mov    0x8(%ebp),%eax
     f5a:	f7 d8                	neg    %eax
     f5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     f5f:	eb 54                	jmp    fb5 <itoa+0x8c>

  int sign = (radix == 10 && value < 0);    
  if (sign)
      v = -value;
  else
      v = (unsigned)value;
     f61:	8b 45 08             	mov    0x8(%ebp),%eax
     f64:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (v || tp == tmp)
     f67:	eb 4c                	jmp    fb5 <itoa+0x8c>
  {
    i = v % radix;
     f69:	8b 4d 10             	mov    0x10(%ebp),%ecx
     f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f6f:	ba 00 00 00 00       	mov    $0x0,%edx
     f74:	f7 f1                	div    %ecx
     f76:	89 d0                	mov    %edx,%eax
     f78:	89 45 e8             	mov    %eax,-0x18(%ebp)
    v /= radix; // v/=radix uses less CPU clocks than v=v/radix does
     f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
     f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f81:	ba 00 00 00 00       	mov    $0x0,%edx
     f86:	f7 f3                	div    %ebx
     f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (i < 10)
     f8b:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
     f8f:	7f 13                	jg     fa4 <itoa+0x7b>
      *tp++ = i+'0';
     f91:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f94:	8d 50 01             	lea    0x1(%eax),%edx
     f97:	89 55 f8             	mov    %edx,-0x8(%ebp)
     f9a:	8b 55 e8             	mov    -0x18(%ebp),%edx
     f9d:	83 c2 30             	add    $0x30,%edx
     fa0:	88 10                	mov    %dl,(%eax)
     fa2:	eb 11                	jmp    fb5 <itoa+0x8c>
    else
      *tp++ = i + 'a' - 10;
     fa4:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fa7:	8d 50 01             	lea    0x1(%eax),%edx
     faa:	89 55 f8             	mov    %edx,-0x8(%ebp)
     fad:	8b 55 e8             	mov    -0x18(%ebp),%edx
     fb0:	83 c2 57             	add    $0x57,%edx
     fb3:	88 10                	mov    %dl,(%eax)
  if (sign)
      v = -value;
  else
      v = (unsigned)value;

  while (v || tp == tmp)
     fb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     fb9:	75 ae                	jne    f69 <itoa+0x40>
     fbb:	8d 45 d8             	lea    -0x28(%ebp),%eax
     fbe:	39 45 f8             	cmp    %eax,-0x8(%ebp)
     fc1:	74 a6                	je     f69 <itoa+0x40>
      *tp++ = i+'0';
    else
      *tp++ = i + 'a' - 10;
  }

  int len = tp - tmp;
     fc3:	8b 55 f8             	mov    -0x8(%ebp),%edx
     fc6:	8d 45 d8             	lea    -0x28(%ebp),%eax
     fc9:	29 c2                	sub    %eax,%edx
     fcb:	89 d0                	mov    %edx,%eax
     fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sign) 
     fd0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     fd4:	74 11                	je     fe7 <itoa+0xbe>
  {
    *sp++ = '-';
     fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
     fd9:	8d 50 01             	lea    0x1(%eax),%edx
     fdc:	89 55 0c             	mov    %edx,0xc(%ebp)
     fdf:	c6 00 2d             	movb   $0x2d,(%eax)
    len++;
     fe2:	ff 45 f0             	incl   -0x10(%ebp)
  }

  while (tp > tmp)
     fe5:	eb 15                	jmp    ffc <itoa+0xd3>
     fe7:	eb 13                	jmp    ffc <itoa+0xd3>
    *sp++ = *--tp;
     fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
     fec:	8d 50 01             	lea    0x1(%eax),%edx
     fef:	89 55 0c             	mov    %edx,0xc(%ebp)
     ff2:	ff 4d f8             	decl   -0x8(%ebp)
     ff5:	8b 55 f8             	mov    -0x8(%ebp),%edx
     ff8:	8a 12                	mov    (%edx),%dl
     ffa:	88 10                	mov    %dl,(%eax)
  {
    *sp++ = '-';
    len++;
  }

  while (tp > tmp)
     ffc:	8d 45 d8             	lea    -0x28(%ebp),%eax
     fff:	39 45 f8             	cmp    %eax,-0x8(%ebp)
    1002:	77 e5                	ja     fe9 <itoa+0xc0>
    *sp++ = *--tp;

  return len;
    1004:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1007:	83 c4 30             	add    $0x30,%esp
    100a:	5b                   	pop    %ebx
    100b:	5d                   	pop    %ebp
    100c:	c3                   	ret    
    100d:	90                   	nop
    100e:	90                   	nop
    100f:	90                   	nop

00001010 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1010:	b8 01 00 00 00       	mov    $0x1,%eax
    1015:	cd 40                	int    $0x40
    1017:	c3                   	ret    

00001018 <exit>:
SYSCALL(exit)
    1018:	b8 02 00 00 00       	mov    $0x2,%eax
    101d:	cd 40                	int    $0x40
    101f:	c3                   	ret    

00001020 <wait>:
SYSCALL(wait)
    1020:	b8 03 00 00 00       	mov    $0x3,%eax
    1025:	cd 40                	int    $0x40
    1027:	c3                   	ret    

00001028 <pipe>:
SYSCALL(pipe)
    1028:	b8 04 00 00 00       	mov    $0x4,%eax
    102d:	cd 40                	int    $0x40
    102f:	c3                   	ret    

00001030 <read>:
SYSCALL(read)
    1030:	b8 05 00 00 00       	mov    $0x5,%eax
    1035:	cd 40                	int    $0x40
    1037:	c3                   	ret    

00001038 <write>:
SYSCALL(write)
    1038:	b8 10 00 00 00       	mov    $0x10,%eax
    103d:	cd 40                	int    $0x40
    103f:	c3                   	ret    

00001040 <close>:
SYSCALL(close)
    1040:	b8 15 00 00 00       	mov    $0x15,%eax
    1045:	cd 40                	int    $0x40
    1047:	c3                   	ret    

00001048 <kill>:
SYSCALL(kill)
    1048:	b8 06 00 00 00       	mov    $0x6,%eax
    104d:	cd 40                	int    $0x40
    104f:	c3                   	ret    

00001050 <exec>:
SYSCALL(exec)
    1050:	b8 07 00 00 00       	mov    $0x7,%eax
    1055:	cd 40                	int    $0x40
    1057:	c3                   	ret    

00001058 <open>:
SYSCALL(open)
    1058:	b8 0f 00 00 00       	mov    $0xf,%eax
    105d:	cd 40                	int    $0x40
    105f:	c3                   	ret    

00001060 <mknod>:
SYSCALL(mknod)
    1060:	b8 11 00 00 00       	mov    $0x11,%eax
    1065:	cd 40                	int    $0x40
    1067:	c3                   	ret    

00001068 <unlink>:
SYSCALL(unlink)
    1068:	b8 12 00 00 00       	mov    $0x12,%eax
    106d:	cd 40                	int    $0x40
    106f:	c3                   	ret    

00001070 <fstat>:
SYSCALL(fstat)
    1070:	b8 08 00 00 00       	mov    $0x8,%eax
    1075:	cd 40                	int    $0x40
    1077:	c3                   	ret    

00001078 <link>:
SYSCALL(link)
    1078:	b8 13 00 00 00       	mov    $0x13,%eax
    107d:	cd 40                	int    $0x40
    107f:	c3                   	ret    

00001080 <mkdir>:
SYSCALL(mkdir)
    1080:	b8 14 00 00 00       	mov    $0x14,%eax
    1085:	cd 40                	int    $0x40
    1087:	c3                   	ret    

00001088 <chdir>:
SYSCALL(chdir)
    1088:	b8 09 00 00 00       	mov    $0x9,%eax
    108d:	cd 40                	int    $0x40
    108f:	c3                   	ret    

00001090 <dup>:
SYSCALL(dup)
    1090:	b8 0a 00 00 00       	mov    $0xa,%eax
    1095:	cd 40                	int    $0x40
    1097:	c3                   	ret    

00001098 <getpid>:
SYSCALL(getpid)
    1098:	b8 0b 00 00 00       	mov    $0xb,%eax
    109d:	cd 40                	int    $0x40
    109f:	c3                   	ret    

000010a0 <sbrk>:
SYSCALL(sbrk)
    10a0:	b8 0c 00 00 00       	mov    $0xc,%eax
    10a5:	cd 40                	int    $0x40
    10a7:	c3                   	ret    

000010a8 <sleep>:
SYSCALL(sleep)
    10a8:	b8 0d 00 00 00       	mov    $0xd,%eax
    10ad:	cd 40                	int    $0x40
    10af:	c3                   	ret    

000010b0 <uptime>:
SYSCALL(uptime)
    10b0:	b8 0e 00 00 00       	mov    $0xe,%eax
    10b5:	cd 40                	int    $0x40
    10b7:	c3                   	ret    

000010b8 <getticks>:
SYSCALL(getticks)
    10b8:	b8 16 00 00 00       	mov    $0x16,%eax
    10bd:	cd 40                	int    $0x40
    10bf:	c3                   	ret    

000010c0 <get_name>:
SYSCALL(get_name)
    10c0:	b8 17 00 00 00       	mov    $0x17,%eax
    10c5:	cd 40                	int    $0x40
    10c7:	c3                   	ret    

000010c8 <get_max_proc>:
SYSCALL(get_max_proc)
    10c8:	b8 18 00 00 00       	mov    $0x18,%eax
    10cd:	cd 40                	int    $0x40
    10cf:	c3                   	ret    

000010d0 <get_max_mem>:
SYSCALL(get_max_mem)
    10d0:	b8 19 00 00 00       	mov    $0x19,%eax
    10d5:	cd 40                	int    $0x40
    10d7:	c3                   	ret    

000010d8 <get_max_disk>:
SYSCALL(get_max_disk)
    10d8:	b8 1a 00 00 00       	mov    $0x1a,%eax
    10dd:	cd 40                	int    $0x40
    10df:	c3                   	ret    

000010e0 <get_curr_proc>:
SYSCALL(get_curr_proc)
    10e0:	b8 1b 00 00 00       	mov    $0x1b,%eax
    10e5:	cd 40                	int    $0x40
    10e7:	c3                   	ret    

000010e8 <get_curr_mem>:
SYSCALL(get_curr_mem)
    10e8:	b8 1c 00 00 00       	mov    $0x1c,%eax
    10ed:	cd 40                	int    $0x40
    10ef:	c3                   	ret    

000010f0 <get_curr_disk>:
SYSCALL(get_curr_disk)
    10f0:	b8 1d 00 00 00       	mov    $0x1d,%eax
    10f5:	cd 40                	int    $0x40
    10f7:	c3                   	ret    

000010f8 <set_name>:
SYSCALL(set_name)
    10f8:	b8 1e 00 00 00       	mov    $0x1e,%eax
    10fd:	cd 40                	int    $0x40
    10ff:	c3                   	ret    

00001100 <set_max_mem>:
SYSCALL(set_max_mem)
    1100:	b8 1f 00 00 00       	mov    $0x1f,%eax
    1105:	cd 40                	int    $0x40
    1107:	c3                   	ret    

00001108 <set_max_disk>:
SYSCALL(set_max_disk)
    1108:	b8 20 00 00 00       	mov    $0x20,%eax
    110d:	cd 40                	int    $0x40
    110f:	c3                   	ret    

00001110 <set_max_proc>:
SYSCALL(set_max_proc)
    1110:	b8 21 00 00 00       	mov    $0x21,%eax
    1115:	cd 40                	int    $0x40
    1117:	c3                   	ret    

00001118 <set_curr_mem>:
SYSCALL(set_curr_mem)
    1118:	b8 22 00 00 00       	mov    $0x22,%eax
    111d:	cd 40                	int    $0x40
    111f:	c3                   	ret    

00001120 <set_curr_disk>:
SYSCALL(set_curr_disk)
    1120:	b8 23 00 00 00       	mov    $0x23,%eax
    1125:	cd 40                	int    $0x40
    1127:	c3                   	ret    

00001128 <set_curr_proc>:
SYSCALL(set_curr_proc)
    1128:	b8 24 00 00 00       	mov    $0x24,%eax
    112d:	cd 40                	int    $0x40
    112f:	c3                   	ret    

00001130 <find>:
SYSCALL(find)
    1130:	b8 25 00 00 00       	mov    $0x25,%eax
    1135:	cd 40                	int    $0x40
    1137:	c3                   	ret    

00001138 <is_full>:
SYSCALL(is_full)
    1138:	b8 26 00 00 00       	mov    $0x26,%eax
    113d:	cd 40                	int    $0x40
    113f:	c3                   	ret    

00001140 <container_init>:
SYSCALL(container_init)
    1140:	b8 27 00 00 00       	mov    $0x27,%eax
    1145:	cd 40                	int    $0x40
    1147:	c3                   	ret    

00001148 <cont_proc_set>:
SYSCALL(cont_proc_set)
    1148:	b8 28 00 00 00       	mov    $0x28,%eax
    114d:	cd 40                	int    $0x40
    114f:	c3                   	ret    

00001150 <ps>:
SYSCALL(ps)
    1150:	b8 29 00 00 00       	mov    $0x29,%eax
    1155:	cd 40                	int    $0x40
    1157:	c3                   	ret    

00001158 <reduce_curr_mem>:
SYSCALL(reduce_curr_mem)
    1158:	b8 2a 00 00 00       	mov    $0x2a,%eax
    115d:	cd 40                	int    $0x40
    115f:	c3                   	ret    

00001160 <set_root_inode>:
SYSCALL(set_root_inode)
    1160:	b8 2b 00 00 00       	mov    $0x2b,%eax
    1165:	cd 40                	int    $0x40
    1167:	c3                   	ret    

00001168 <cstop>:
SYSCALL(cstop)
    1168:	b8 2c 00 00 00       	mov    $0x2c,%eax
    116d:	cd 40                	int    $0x40
    116f:	c3                   	ret    

00001170 <df>:
SYSCALL(df)
    1170:	b8 2d 00 00 00       	mov    $0x2d,%eax
    1175:	cd 40                	int    $0x40
    1177:	c3                   	ret    

00001178 <max_containers>:
SYSCALL(max_containers)
    1178:	b8 2e 00 00 00       	mov    $0x2e,%eax
    117d:	cd 40                	int    $0x40
    117f:	c3                   	ret    

00001180 <container_reset>:
SYSCALL(container_reset)
    1180:	b8 2f 00 00 00       	mov    $0x2f,%eax
    1185:	cd 40                	int    $0x40
    1187:	c3                   	ret    

00001188 <pause>:
SYSCALL(pause)
    1188:	b8 30 00 00 00       	mov    $0x30,%eax
    118d:	cd 40                	int    $0x40
    118f:	c3                   	ret    

00001190 <resume>:
SYSCALL(resume)
    1190:	b8 31 00 00 00       	mov    $0x31,%eax
    1195:	cd 40                	int    $0x40
    1197:	c3                   	ret    

00001198 <tmem>:
SYSCALL(tmem)
    1198:	b8 32 00 00 00       	mov    $0x32,%eax
    119d:	cd 40                	int    $0x40
    119f:	c3                   	ret    

000011a0 <amem>:
SYSCALL(amem)
    11a0:	b8 33 00 00 00       	mov    $0x33,%eax
    11a5:	cd 40                	int    $0x40
    11a7:	c3                   	ret    

000011a8 <c_ps>:
SYSCALL(c_ps)
    11a8:	b8 34 00 00 00       	mov    $0x34,%eax
    11ad:	cd 40                	int    $0x40
    11af:	c3                   	ret    

000011b0 <get_used>:
SYSCALL(get_used)
    11b0:	b8 35 00 00 00       	mov    $0x35,%eax
    11b5:	cd 40                	int    $0x40
    11b7:	c3                   	ret    

000011b8 <get_os>:
SYSCALL(get_os)
    11b8:	b8 36 00 00 00       	mov    $0x36,%eax
    11bd:	cd 40                	int    $0x40
    11bf:	c3                   	ret    

000011c0 <set_os>:
SYSCALL(set_os)
    11c0:	b8 37 00 00 00       	mov    $0x37,%eax
    11c5:	cd 40                	int    $0x40
    11c7:	c3                   	ret    

000011c8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    11c8:	55                   	push   %ebp
    11c9:	89 e5                	mov    %esp,%ebp
    11cb:	83 ec 18             	sub    $0x18,%esp
    11ce:	8b 45 0c             	mov    0xc(%ebp),%eax
    11d1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    11d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    11db:	00 
    11dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
    11df:	89 44 24 04          	mov    %eax,0x4(%esp)
    11e3:	8b 45 08             	mov    0x8(%ebp),%eax
    11e6:	89 04 24             	mov    %eax,(%esp)
    11e9:	e8 4a fe ff ff       	call   1038 <write>
}
    11ee:	c9                   	leave  
    11ef:	c3                   	ret    

000011f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    11f0:	55                   	push   %ebp
    11f1:	89 e5                	mov    %esp,%ebp
    11f3:	56                   	push   %esi
    11f4:	53                   	push   %ebx
    11f5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    11f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    11ff:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1203:	74 17                	je     121c <printint+0x2c>
    1205:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1209:	79 11                	jns    121c <printint+0x2c>
    neg = 1;
    120b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1212:	8b 45 0c             	mov    0xc(%ebp),%eax
    1215:	f7 d8                	neg    %eax
    1217:	89 45 ec             	mov    %eax,-0x14(%ebp)
    121a:	eb 06                	jmp    1222 <printint+0x32>
  } else {
    x = xx;
    121c:	8b 45 0c             	mov    0xc(%ebp),%eax
    121f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1222:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1229:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    122c:	8d 41 01             	lea    0x1(%ecx),%eax
    122f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1232:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1235:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1238:	ba 00 00 00 00       	mov    $0x0,%edx
    123d:	f7 f3                	div    %ebx
    123f:	89 d0                	mov    %edx,%eax
    1241:	8a 80 18 1c 00 00    	mov    0x1c18(%eax),%al
    1247:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    124b:	8b 75 10             	mov    0x10(%ebp),%esi
    124e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1251:	ba 00 00 00 00       	mov    $0x0,%edx
    1256:	f7 f6                	div    %esi
    1258:	89 45 ec             	mov    %eax,-0x14(%ebp)
    125b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    125f:	75 c8                	jne    1229 <printint+0x39>
  if(neg)
    1261:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1265:	74 10                	je     1277 <printint+0x87>
    buf[i++] = '-';
    1267:	8b 45 f4             	mov    -0xc(%ebp),%eax
    126a:	8d 50 01             	lea    0x1(%eax),%edx
    126d:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1270:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1275:	eb 1e                	jmp    1295 <printint+0xa5>
    1277:	eb 1c                	jmp    1295 <printint+0xa5>
    putc(fd, buf[i]);
    1279:	8d 55 dc             	lea    -0x24(%ebp),%edx
    127c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    127f:	01 d0                	add    %edx,%eax
    1281:	8a 00                	mov    (%eax),%al
    1283:	0f be c0             	movsbl %al,%eax
    1286:	89 44 24 04          	mov    %eax,0x4(%esp)
    128a:	8b 45 08             	mov    0x8(%ebp),%eax
    128d:	89 04 24             	mov    %eax,(%esp)
    1290:	e8 33 ff ff ff       	call   11c8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1295:	ff 4d f4             	decl   -0xc(%ebp)
    1298:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    129c:	79 db                	jns    1279 <printint+0x89>
    putc(fd, buf[i]);
}
    129e:	83 c4 30             	add    $0x30,%esp
    12a1:	5b                   	pop    %ebx
    12a2:	5e                   	pop    %esi
    12a3:	5d                   	pop    %ebp
    12a4:	c3                   	ret    

000012a5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    12a5:	55                   	push   %ebp
    12a6:	89 e5                	mov    %esp,%ebp
    12a8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    12ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    12b2:	8d 45 0c             	lea    0xc(%ebp),%eax
    12b5:	83 c0 04             	add    $0x4,%eax
    12b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    12bb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    12c2:	e9 77 01 00 00       	jmp    143e <printf+0x199>
    c = fmt[i] & 0xff;
    12c7:	8b 55 0c             	mov    0xc(%ebp),%edx
    12ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12cd:	01 d0                	add    %edx,%eax
    12cf:	8a 00                	mov    (%eax),%al
    12d1:	0f be c0             	movsbl %al,%eax
    12d4:	25 ff 00 00 00       	and    $0xff,%eax
    12d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    12dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12e0:	75 2c                	jne    130e <printf+0x69>
      if(c == '%'){
    12e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    12e6:	75 0c                	jne    12f4 <printf+0x4f>
        state = '%';
    12e8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    12ef:	e9 47 01 00 00       	jmp    143b <printf+0x196>
      } else {
        putc(fd, c);
    12f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12f7:	0f be c0             	movsbl %al,%eax
    12fa:	89 44 24 04          	mov    %eax,0x4(%esp)
    12fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1301:	89 04 24             	mov    %eax,(%esp)
    1304:	e8 bf fe ff ff       	call   11c8 <putc>
    1309:	e9 2d 01 00 00       	jmp    143b <printf+0x196>
      }
    } else if(state == '%'){
    130e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1312:	0f 85 23 01 00 00    	jne    143b <printf+0x196>
      if(c == 'd'){
    1318:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    131c:	75 2d                	jne    134b <printf+0xa6>
        printint(fd, *ap, 10, 1);
    131e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1321:	8b 00                	mov    (%eax),%eax
    1323:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    132a:	00 
    132b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1332:	00 
    1333:	89 44 24 04          	mov    %eax,0x4(%esp)
    1337:	8b 45 08             	mov    0x8(%ebp),%eax
    133a:	89 04 24             	mov    %eax,(%esp)
    133d:	e8 ae fe ff ff       	call   11f0 <printint>
        ap++;
    1342:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1346:	e9 e9 00 00 00       	jmp    1434 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    134b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    134f:	74 06                	je     1357 <printf+0xb2>
    1351:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1355:	75 2d                	jne    1384 <printf+0xdf>
        printint(fd, *ap, 16, 0);
    1357:	8b 45 e8             	mov    -0x18(%ebp),%eax
    135a:	8b 00                	mov    (%eax),%eax
    135c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1363:	00 
    1364:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    136b:	00 
    136c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1370:	8b 45 08             	mov    0x8(%ebp),%eax
    1373:	89 04 24             	mov    %eax,(%esp)
    1376:	e8 75 fe ff ff       	call   11f0 <printint>
        ap++;
    137b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    137f:	e9 b0 00 00 00       	jmp    1434 <printf+0x18f>
      } else if(c == 's'){
    1384:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1388:	75 42                	jne    13cc <printf+0x127>
        s = (char*)*ap;
    138a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    138d:	8b 00                	mov    (%eax),%eax
    138f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1392:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1396:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    139a:	75 09                	jne    13a5 <printf+0x100>
          s = "(null)";
    139c:	c7 45 f4 5c 17 00 00 	movl   $0x175c,-0xc(%ebp)
        while(*s != 0){
    13a3:	eb 1c                	jmp    13c1 <printf+0x11c>
    13a5:	eb 1a                	jmp    13c1 <printf+0x11c>
          putc(fd, *s);
    13a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13aa:	8a 00                	mov    (%eax),%al
    13ac:	0f be c0             	movsbl %al,%eax
    13af:	89 44 24 04          	mov    %eax,0x4(%esp)
    13b3:	8b 45 08             	mov    0x8(%ebp),%eax
    13b6:	89 04 24             	mov    %eax,(%esp)
    13b9:	e8 0a fe ff ff       	call   11c8 <putc>
          s++;
    13be:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    13c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c4:	8a 00                	mov    (%eax),%al
    13c6:	84 c0                	test   %al,%al
    13c8:	75 dd                	jne    13a7 <printf+0x102>
    13ca:	eb 68                	jmp    1434 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    13cc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    13d0:	75 1d                	jne    13ef <printf+0x14a>
        putc(fd, *ap);
    13d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    13d5:	8b 00                	mov    (%eax),%eax
    13d7:	0f be c0             	movsbl %al,%eax
    13da:	89 44 24 04          	mov    %eax,0x4(%esp)
    13de:	8b 45 08             	mov    0x8(%ebp),%eax
    13e1:	89 04 24             	mov    %eax,(%esp)
    13e4:	e8 df fd ff ff       	call   11c8 <putc>
        ap++;
    13e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    13ed:	eb 45                	jmp    1434 <printf+0x18f>
      } else if(c == '%'){
    13ef:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    13f3:	75 17                	jne    140c <printf+0x167>
        putc(fd, c);
    13f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    13f8:	0f be c0             	movsbl %al,%eax
    13fb:	89 44 24 04          	mov    %eax,0x4(%esp)
    13ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1402:	89 04 24             	mov    %eax,(%esp)
    1405:	e8 be fd ff ff       	call   11c8 <putc>
    140a:	eb 28                	jmp    1434 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    140c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1413:	00 
    1414:	8b 45 08             	mov    0x8(%ebp),%eax
    1417:	89 04 24             	mov    %eax,(%esp)
    141a:	e8 a9 fd ff ff       	call   11c8 <putc>
        putc(fd, c);
    141f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1422:	0f be c0             	movsbl %al,%eax
    1425:	89 44 24 04          	mov    %eax,0x4(%esp)
    1429:	8b 45 08             	mov    0x8(%ebp),%eax
    142c:	89 04 24             	mov    %eax,(%esp)
    142f:	e8 94 fd ff ff       	call   11c8 <putc>
      }
      state = 0;
    1434:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    143b:	ff 45 f0             	incl   -0x10(%ebp)
    143e:	8b 55 0c             	mov    0xc(%ebp),%edx
    1441:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1444:	01 d0                	add    %edx,%eax
    1446:	8a 00                	mov    (%eax),%al
    1448:	84 c0                	test   %al,%al
    144a:	0f 85 77 fe ff ff    	jne    12c7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1450:	c9                   	leave  
    1451:	c3                   	ret    
    1452:	90                   	nop
    1453:	90                   	nop

00001454 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1454:	55                   	push   %ebp
    1455:	89 e5                	mov    %esp,%ebp
    1457:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    145a:	8b 45 08             	mov    0x8(%ebp),%eax
    145d:	83 e8 08             	sub    $0x8,%eax
    1460:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1463:	a1 ac 1c 00 00       	mov    0x1cac,%eax
    1468:	89 45 fc             	mov    %eax,-0x4(%ebp)
    146b:	eb 24                	jmp    1491 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    146d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1470:	8b 00                	mov    (%eax),%eax
    1472:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1475:	77 12                	ja     1489 <free+0x35>
    1477:	8b 45 f8             	mov    -0x8(%ebp),%eax
    147a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    147d:	77 24                	ja     14a3 <free+0x4f>
    147f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1482:	8b 00                	mov    (%eax),%eax
    1484:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1487:	77 1a                	ja     14a3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1489:	8b 45 fc             	mov    -0x4(%ebp),%eax
    148c:	8b 00                	mov    (%eax),%eax
    148e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1491:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1494:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1497:	76 d4                	jbe    146d <free+0x19>
    1499:	8b 45 fc             	mov    -0x4(%ebp),%eax
    149c:	8b 00                	mov    (%eax),%eax
    149e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    14a1:	76 ca                	jbe    146d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    14a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14a6:	8b 40 04             	mov    0x4(%eax),%eax
    14a9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    14b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14b3:	01 c2                	add    %eax,%edx
    14b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14b8:	8b 00                	mov    (%eax),%eax
    14ba:	39 c2                	cmp    %eax,%edx
    14bc:	75 24                	jne    14e2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    14be:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14c1:	8b 50 04             	mov    0x4(%eax),%edx
    14c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14c7:	8b 00                	mov    (%eax),%eax
    14c9:	8b 40 04             	mov    0x4(%eax),%eax
    14cc:	01 c2                	add    %eax,%edx
    14ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14d1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    14d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14d7:	8b 00                	mov    (%eax),%eax
    14d9:	8b 10                	mov    (%eax),%edx
    14db:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14de:	89 10                	mov    %edx,(%eax)
    14e0:	eb 0a                	jmp    14ec <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    14e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14e5:	8b 10                	mov    (%eax),%edx
    14e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    14ea:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    14ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14ef:	8b 40 04             	mov    0x4(%eax),%eax
    14f2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    14f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14fc:	01 d0                	add    %edx,%eax
    14fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1501:	75 20                	jne    1523 <free+0xcf>
    p->s.size += bp->s.size;
    1503:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1506:	8b 50 04             	mov    0x4(%eax),%edx
    1509:	8b 45 f8             	mov    -0x8(%ebp),%eax
    150c:	8b 40 04             	mov    0x4(%eax),%eax
    150f:	01 c2                	add    %eax,%edx
    1511:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1514:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1517:	8b 45 f8             	mov    -0x8(%ebp),%eax
    151a:	8b 10                	mov    (%eax),%edx
    151c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    151f:	89 10                	mov    %edx,(%eax)
    1521:	eb 08                	jmp    152b <free+0xd7>
  } else
    p->s.ptr = bp;
    1523:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1526:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1529:	89 10                	mov    %edx,(%eax)
  freep = p;
    152b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    152e:	a3 ac 1c 00 00       	mov    %eax,0x1cac
}
    1533:	c9                   	leave  
    1534:	c3                   	ret    

00001535 <morecore>:

static Header*
morecore(uint nu)
{
    1535:	55                   	push   %ebp
    1536:	89 e5                	mov    %esp,%ebp
    1538:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    153b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1542:	77 07                	ja     154b <morecore+0x16>
    nu = 4096;
    1544:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    154b:	8b 45 08             	mov    0x8(%ebp),%eax
    154e:	c1 e0 03             	shl    $0x3,%eax
    1551:	89 04 24             	mov    %eax,(%esp)
    1554:	e8 47 fb ff ff       	call   10a0 <sbrk>
    1559:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    155c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1560:	75 07                	jne    1569 <morecore+0x34>
    return 0;
    1562:	b8 00 00 00 00       	mov    $0x0,%eax
    1567:	eb 22                	jmp    158b <morecore+0x56>
  hp = (Header*)p;
    1569:	8b 45 f4             	mov    -0xc(%ebp),%eax
    156c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1572:	8b 55 08             	mov    0x8(%ebp),%edx
    1575:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1578:	8b 45 f0             	mov    -0x10(%ebp),%eax
    157b:	83 c0 08             	add    $0x8,%eax
    157e:	89 04 24             	mov    %eax,(%esp)
    1581:	e8 ce fe ff ff       	call   1454 <free>
  return freep;
    1586:	a1 ac 1c 00 00       	mov    0x1cac,%eax
}
    158b:	c9                   	leave  
    158c:	c3                   	ret    

0000158d <malloc>:

void*
malloc(uint nbytes)
{
    158d:	55                   	push   %ebp
    158e:	89 e5                	mov    %esp,%ebp
    1590:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1593:	8b 45 08             	mov    0x8(%ebp),%eax
    1596:	83 c0 07             	add    $0x7,%eax
    1599:	c1 e8 03             	shr    $0x3,%eax
    159c:	40                   	inc    %eax
    159d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    15a0:	a1 ac 1c 00 00       	mov    0x1cac,%eax
    15a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    15a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    15ac:	75 23                	jne    15d1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    15ae:	c7 45 f0 a4 1c 00 00 	movl   $0x1ca4,-0x10(%ebp)
    15b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15b8:	a3 ac 1c 00 00       	mov    %eax,0x1cac
    15bd:	a1 ac 1c 00 00       	mov    0x1cac,%eax
    15c2:	a3 a4 1c 00 00       	mov    %eax,0x1ca4
    base.s.size = 0;
    15c7:	c7 05 a8 1c 00 00 00 	movl   $0x0,0x1ca8
    15ce:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    15d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15d4:	8b 00                	mov    (%eax),%eax
    15d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    15d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15dc:	8b 40 04             	mov    0x4(%eax),%eax
    15df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    15e2:	72 4d                	jb     1631 <malloc+0xa4>
      if(p->s.size == nunits)
    15e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15e7:	8b 40 04             	mov    0x4(%eax),%eax
    15ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    15ed:	75 0c                	jne    15fb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    15ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15f2:	8b 10                	mov    (%eax),%edx
    15f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15f7:	89 10                	mov    %edx,(%eax)
    15f9:	eb 26                	jmp    1621 <malloc+0x94>
      else {
        p->s.size -= nunits;
    15fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15fe:	8b 40 04             	mov    0x4(%eax),%eax
    1601:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1604:	89 c2                	mov    %eax,%edx
    1606:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1609:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    160f:	8b 40 04             	mov    0x4(%eax),%eax
    1612:	c1 e0 03             	shl    $0x3,%eax
    1615:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1618:	8b 45 f4             	mov    -0xc(%ebp),%eax
    161b:	8b 55 ec             	mov    -0x14(%ebp),%edx
    161e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1621:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1624:	a3 ac 1c 00 00       	mov    %eax,0x1cac
      return (void*)(p + 1);
    1629:	8b 45 f4             	mov    -0xc(%ebp),%eax
    162c:	83 c0 08             	add    $0x8,%eax
    162f:	eb 38                	jmp    1669 <malloc+0xdc>
    }
    if(p == freep)
    1631:	a1 ac 1c 00 00       	mov    0x1cac,%eax
    1636:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1639:	75 1b                	jne    1656 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    163b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    163e:	89 04 24             	mov    %eax,(%esp)
    1641:	e8 ef fe ff ff       	call   1535 <morecore>
    1646:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1649:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    164d:	75 07                	jne    1656 <malloc+0xc9>
        return 0;
    164f:	b8 00 00 00 00       	mov    $0x0,%eax
    1654:	eb 13                	jmp    1669 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1656:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1659:	89 45 f0             	mov    %eax,-0x10(%ebp)
    165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    165f:	8b 00                	mov    (%eax),%eax
    1661:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1664:	e9 70 ff ff ff       	jmp    15d9 <malloc+0x4c>
}
    1669:	c9                   	leave  
    166a:	c3                   	ret    
