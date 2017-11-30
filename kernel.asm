
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 10 d9 10 80       	mov    $0x8010d910,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 16 39 10 80       	mov    $0x80103916,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 14 8f 10 	movl   $0x80108f14,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100049:	e8 cc 50 00 00       	call   8010511a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 6c 20 11 80 1c 	movl   $0x8011201c,0x8011206c
80100055:	20 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 70 20 11 80 1c 	movl   $0x8011201c,0x80112070
8010005f:	20 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 54 d9 10 80 	movl   $0x8010d954,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 70 20 11 80    	mov    0x80112070,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 1c 20 11 80 	movl   $0x8011201c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 1b 8f 10 	movl   $0x80108f1b,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 45 4f 00 00       	call   80104fdc <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 70 20 11 80       	mov    0x80112070,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 70 20 11 80       	mov    %eax,0x80112070

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 1c 20 11 80 	cmpl   $0x8011201c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
801000c9:	e8 6d 50 00 00       	call   8010513b <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 70 20 11 80       	mov    0x80112070,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100104:	e8 9c 50 00 00       	call   801051a5 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 ff 4e 00 00       	call   80105016 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 1c 20 11 80 	cmpl   $0x8011201c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 6c 20 11 80       	mov    0x8011206c,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
8010017d:	e8 23 50 00 00       	call   801051a5 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 86 4e 00 00       	call   80105016 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 1c 20 11 80 	cmpl   $0x8011201c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 22 8f 10 80 	movl   $0x80108f22,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 ee 27 00 00       	call   801029d5 <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 b3 4e 00 00       	call   801050b3 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 33 8f 10 80 	movl   $0x80108f33,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 ab 27 00 00       	call   801029d5 <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 73 4e 00 00       	call   801050b3 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 3a 8f 10 80 	movl   $0x80108f3a,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 13 4e 00 00       	call   80105071 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100265:	e8 d1 4e 00 00       	call   8010513b <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 70 20 11 80    	mov    0x80112070,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 1c 20 11 80 	movl   $0x8011201c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 70 20 11 80       	mov    0x80112070,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 70 20 11 80       	mov    %eax,0x80112070
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
801002d1:	e8 cf 4e 00 00       	call   801051a5 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 08 a0 10 80    	mov    -0x7fef5ff8(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 b7 03 00 00       	call   80100768 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
801003dc:	e8 5a 4d 00 00       	call   8010513b <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 41 8f 10 80 	movl   $0x80108f41,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 51 03 00 00       	call   80100768 <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec 4a 8f 10 80 	movl   $0x80108f4a,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 7e 02 00 00       	call   80100768 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 64 02 00 00       	call   80100768 <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 56 02 00 00       	call   80100768 <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 4b 02 00 00       	call   80100768 <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
8010054d:	e8 53 4c 00 00       	call   801051a5 <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 b4 c8 10 80 00 	movl   $0x0,0x8010c8b4
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 7b 2b 00 00       	call   801030e9 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 51 8f 10 80 	movl   $0x80108f51,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 65 8f 10 80 	movl   $0x80108f65,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 4b 4c 00 00       	call   801051f2 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 67 8f 10 80 	movl   $0x80108f67,(%esp)
801005c2:	e8 fa fd ff ff       	call   801003c1 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c7:	ff 45 f4             	incl   -0xc(%ebp)
801005ca:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005ce:	7e e0                	jle    801005b0 <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d0:	c7 05 6c c8 10 80 01 	movl   $0x1,0x8010c86c
801005d7:	00 00 00 
  for(;;)
    ;
801005da:	eb fe                	jmp    801005da <panic+0x86>

801005dc <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005dc:	55                   	push   %ebp
801005dd:	89 e5                	mov    %esp,%ebp
801005df:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e2:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e9:	00 
801005ea:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f1:	e8 fd fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005f6:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005fd:	e8 d6 fc ff ff       	call   801002d8 <inb>
80100602:	0f b6 c0             	movzbl %al,%eax
80100605:	c1 e0 08             	shl    $0x8,%eax
80100608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010060b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100612:	00 
80100613:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010061a:	e8 d4 fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
8010061f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100626:	e8 ad fc ff ff       	call   801002d8 <inb>
8010062b:	0f b6 c0             	movzbl %al,%eax
8010062e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100631:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100635:	75 1b                	jne    80100652 <cgaputc+0x76>
    pos += 80 - pos%80;
80100637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063a:	b9 50 00 00 00       	mov    $0x50,%ecx
8010063f:	99                   	cltd   
80100640:	f7 f9                	idiv   %ecx
80100642:	89 d0                	mov    %edx,%eax
80100644:	ba 50 00 00 00       	mov    $0x50,%edx
80100649:	29 c2                	sub    %eax,%edx
8010064b:	89 d0                	mov    %edx,%eax
8010064d:	01 45 f4             	add    %eax,-0xc(%ebp)
80100650:	eb 34                	jmp    80100686 <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100652:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100659:	75 0b                	jne    80100666 <cgaputc+0x8a>
    if(pos > 0) --pos;
8010065b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010065f:	7e 25                	jle    80100686 <cgaputc+0xaa>
80100661:	ff 4d f4             	decl   -0xc(%ebp)
80100664:	eb 20                	jmp    80100686 <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100666:	8b 0d 04 a0 10 80    	mov    0x8010a004,%ecx
8010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066f:	8d 50 01             	lea    0x1(%eax),%edx
80100672:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100675:	01 c0                	add    %eax,%eax
80100677:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067a:	8b 45 08             	mov    0x8(%ebp),%eax
8010067d:	0f b6 c0             	movzbl %al,%eax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068a:	78 09                	js     80100695 <cgaputc+0xb9>
8010068c:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100693:	7e 0c                	jle    801006a1 <cgaputc+0xc5>
    panic("pos under/overflow");
80100695:	c7 04 24 6b 8f 10 80 	movl   $0x80108f6b,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 99 4d 00 00       	call   80105467 <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 a0 10 80    	mov    0x8010a004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 a1 4c 00 00       	call   8010539e <memset>
  }

  outb(CRTPORT, 14);
801006fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100704:	00 
80100705:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070c:	e8 e2 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100714:	c1 f8 08             	sar    $0x8,%eax
80100717:	0f b6 c0             	movzbl %al,%eax
8010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010071e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100725:	e8 c9 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
8010072a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100731:	00 
80100732:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100739:	e8 b5 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
8010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 44 24 04          	mov    %eax,0x4(%esp)
80100748:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074f:	e8 9f fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
80100754:	8b 15 04 a0 10 80    	mov    0x8010a004,%edx
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	01 c0                	add    %eax,%eax
8010075f:	01 d0                	add    %edx,%eax
80100761:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100766:	c9                   	leave  
80100767:	c3                   	ret    

80100768 <consputc>:

void
consputc(int c)
{
80100768:	55                   	push   %ebp
80100769:	89 e5                	mov    %esp,%ebp
8010076b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010076e:	a1 6c c8 10 80       	mov    0x8010c86c,%eax
80100773:	85 c0                	test   %eax,%eax
80100775:	74 07                	je     8010077e <consputc+0x16>
    cli();
80100777:	e8 93 fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
8010077c:	eb fe                	jmp    8010077c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010077e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100785:	75 26                	jne    801007ad <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 e1 68 00 00       	call   80107074 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 d5 68 00 00       	call   80107074 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 c9 68 00 00       	call   80107074 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 bc 68 00 00       	call   80107074 <uartputc>
  cgaputc(c);
801007b8:	8b 45 08             	mov    0x8(%ebp),%eax
801007bb:	89 04 24             	mov    %eax,(%esp)
801007be:	e8 19 fe ff ff       	call   801005dc <cgaputc>
}
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <copy_buf>:

#define C(x)  ((x)-'@')  // Control-x


void copy_buf(char *dst, char *src, int len)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for (i = 0; i < len; i++) {
801007cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801007d2:	eb 17                	jmp    801007eb <copy_buf+0x26>
    dst[i] = src[i];
801007d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007d7:	8b 45 08             	mov    0x8(%ebp),%eax
801007da:	01 c2                	add    %eax,%edx
801007dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
801007df:	8b 45 0c             	mov    0xc(%ebp),%eax
801007e2:	01 c8                	add    %ecx,%eax
801007e4:	8a 00                	mov    (%eax),%al
801007e6:	88 02                	mov    %al,(%edx)

void copy_buf(char *dst, char *src, int len)
{
  int i;

  for (i = 0; i < len; i++) {
801007e8:	ff 45 fc             	incl   -0x4(%ebp)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801007f1:	7c e1                	jl     801007d4 <copy_buf+0xf>
    dst[i] = src[i];
  }
}
801007f3:	c9                   	leave  
801007f4:	c3                   	ret    

801007f5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801007f5:	55                   	push   %ebp
801007f6:	89 e5                	mov    %esp,%ebp
801007f8:	57                   	push   %edi
801007f9:	56                   	push   %esi
801007fa:	53                   	push   %ebx
801007fb:	83 ec 2c             	sub    $0x2c,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100805:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  acquire(&cons.lock);
8010080c:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100813:	e8 23 49 00 00       	call   8010513b <acquire>
  while((c = getc()) >= 0){
80100818:	e9 eb 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    switch(c){
8010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100820:	83 f8 14             	cmp    $0x14,%eax
80100823:	74 3b                	je     80100860 <consoleintr+0x6b>
80100825:	83 f8 14             	cmp    $0x14,%eax
80100828:	7f 13                	jg     8010083d <consoleintr+0x48>
8010082a:	83 f8 08             	cmp    $0x8,%eax
8010082d:	0f 84 16 01 00 00    	je     80100949 <consoleintr+0x154>
80100833:	83 f8 10             	cmp    $0x10,%eax
80100836:	74 1c                	je     80100854 <consoleintr+0x5f>
80100838:	e9 3c 01 00 00       	jmp    80100979 <consoleintr+0x184>
8010083d:	83 f8 15             	cmp    $0x15,%eax
80100840:	0f 84 db 00 00 00    	je     80100921 <consoleintr+0x12c>
80100846:	83 f8 7f             	cmp    $0x7f,%eax
80100849:	0f 84 fa 00 00 00    	je     80100949 <consoleintr+0x154>
8010084f:	e9 25 01 00 00       	jmp    80100979 <consoleintr+0x184>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      // cprintf("PID of myPROC is %d\n.", myproc()->pid);
      doprocdump = 1;
80100854:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
8010085b:	e9 a8 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active+1 > MAX_VC){
80100860:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100865:	40                   	inc    %eax
80100866:	83 f8 04             	cmp    $0x4,%eax
80100869:	7e 23                	jle    8010088e <consoleintr+0x99>
        active = 1;
8010086b:	c7 05 00 a0 10 80 01 	movl   $0x1,0x8010a000
80100872:	00 00 00 
        input = buf1;
80100875:	ba 80 22 11 80       	mov    $0x80112280,%edx
8010087a:	bb 00 c6 10 80       	mov    $0x8010c600,%ebx
8010087f:	b8 23 00 00 00       	mov    $0x23,%eax
80100884:	89 d7                	mov    %edx,%edi
80100886:	89 de                	mov    %ebx,%esi
80100888:	89 c1                	mov    %eax,%ecx
8010088a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
8010088c:	eb 6e                	jmp    801008fc <consoleintr+0x107>
      } else{
        active = active + 1;
8010088e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100893:	40                   	inc    %eax
80100894:	a3 00 a0 10 80       	mov    %eax,0x8010a000
        if(active == 2){
80100899:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010089e:	83 f8 02             	cmp    $0x2,%eax
801008a1:	75 17                	jne    801008ba <consoleintr+0xc5>
          buf2 = input;
801008a3:	ba a0 c6 10 80       	mov    $0x8010c6a0,%edx
801008a8:	bb 80 22 11 80       	mov    $0x80112280,%ebx
801008ad:	b8 23 00 00 00       	mov    $0x23,%eax
801008b2:	89 d7                	mov    %edx,%edi
801008b4:	89 de                	mov    %ebx,%esi
801008b6:	89 c1                	mov    %eax,%ecx
801008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 3){
801008ba:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801008bf:	83 f8 03             	cmp    $0x3,%eax
801008c2:	75 17                	jne    801008db <consoleintr+0xe6>
          buf3 = input;
801008c4:	ba 40 c7 10 80       	mov    $0x8010c740,%edx
801008c9:	bb 80 22 11 80       	mov    $0x80112280,%ebx
801008ce:	b8 23 00 00 00       	mov    $0x23,%eax
801008d3:	89 d7                	mov    %edx,%edi
801008d5:	89 de                	mov    %ebx,%esi
801008d7:	89 c1                	mov    %eax,%ecx
801008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 4){
801008db:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801008e0:	83 f8 04             	cmp    $0x4,%eax
801008e3:	75 17                	jne    801008fc <consoleintr+0x107>
          buf4 = input;
801008e5:	ba e0 c7 10 80       	mov    $0x8010c7e0,%edx
801008ea:	bb 80 22 11 80       	mov    $0x80112280,%ebx
801008ef:	b8 23 00 00 00       	mov    $0x23,%eax
801008f4:	89 d7                	mov    %edx,%edi
801008f6:	89 de                	mov    %ebx,%esi
801008f8:	89 c1                	mov    %eax,%ecx
801008fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
      }
      doconsoleswitch = 1;
801008fc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      break;
80100903:	e9 00 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100908:	a1 08 23 11 80       	mov    0x80112308,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 08 23 11 80       	mov    %eax,0x80112308
        consputc(BACKSPACE);
80100913:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010091a:	e8 49 fe ff ff       	call   80100768 <consputc>
8010091f:	eb 01                	jmp    80100922 <consoleintr+0x12d>
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100921:	90                   	nop
80100922:	8b 15 08 23 11 80    	mov    0x80112308,%edx
80100928:	a1 04 23 11 80       	mov    0x80112304,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 08 23 11 80       	mov    0x80112308,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 80 22 11 80    	mov    -0x7feedd80(%eax),%al
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100940:	3c 0a                	cmp    $0xa,%al
80100942:	75 c4                	jne    80100908 <consoleintr+0x113>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100944:	e9 bf 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100949:	8b 15 08 23 11 80    	mov    0x80112308,%edx
8010094f:	a1 04 23 11 80       	mov    0x80112304,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 08 23 11 80       	mov    0x80112308,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 08 23 11 80       	mov    %eax,0x80112308
        consputc(BACKSPACE);
80100963:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010096a:	e8 f9 fd ff ff       	call   80100768 <consputc>
      }
      break;
8010096f:	e9 94 00 00 00       	jmp    80100a08 <consoleintr+0x213>
80100974:	e9 8f 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100979:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010097d:	0f 84 84 00 00 00    	je     80100a07 <consoleintr+0x212>
80100983:	8b 15 08 23 11 80    	mov    0x80112308,%edx
80100989:	a1 00 23 11 80       	mov    0x80112300,%eax
8010098e:	29 c2                	sub    %eax,%edx
80100990:	89 d0                	mov    %edx,%eax
80100992:	83 f8 7f             	cmp    $0x7f,%eax
80100995:	77 70                	ja     80100a07 <consoleintr+0x212>
        c = (c == '\r') ? '\n' : c;
80100997:	83 7d dc 0d          	cmpl   $0xd,-0x24(%ebp)
8010099b:	74 05                	je     801009a2 <consoleintr+0x1ad>
8010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a0:	eb 05                	jmp    801009a7 <consoleintr+0x1b2>
801009a2:	b8 0a 00 00 00       	mov    $0xa,%eax
801009a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009aa:	a1 08 23 11 80       	mov    0x80112308,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 08 23 11 80    	mov    %edx,0x80112308
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 80 22 11 80    	mov    %al,-0x7feedd80(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 08 23 11 80       	mov    0x80112308,%eax
801009e2:	8b 15 00 23 11 80    	mov    0x80112300,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 08 23 11 80       	mov    0x80112308,%eax
801009f4:	a3 04 23 11 80       	mov    %eax,0x80112304
          wakeup(&input.r);
801009f9:	c7 04 24 00 23 11 80 	movl   $0x80112300,(%esp)
80100a00:	e8 7e 42 00 00       	call   80104c83 <wakeup>
        }
      }
      break;
80100a05:	eb 00                	jmp    80100a07 <consoleintr+0x212>
80100a07:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100a08:	8b 45 08             	mov    0x8(%ebp),%eax
80100a0b:	ff d0                	call   *%eax
80100a0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100a10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80100a14:	0f 89 03 fe ff ff    	jns    8010081d <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100a1a:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100a21:	e8 7f 47 00 00       	call   801051a5 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 7e 8f 10 80 	movl   $0x80108f7e,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 ec 42 00 00       	call   80104d29 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 96 8f 10 80 	movl   $0x80108f96,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 b0 8f 10 80 	movl   $0x80108fb0,(%esp)
80100a5f:	e8 5d f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100a64:	83 c4 2c             	add    $0x2c,%esp
80100a67:	5b                   	pop    %ebx
80100a68:	5e                   	pop    %esi
80100a69:	5f                   	pop    %edi
80100a6a:	5d                   	pop    %ebp
80100a6b:	c3                   	ret    

80100a6c <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a6c:	55                   	push   %ebp
80100a6d:	89 e5                	mov    %esp,%ebp
80100a6f:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100a72:	8b 45 08             	mov    0x8(%ebp),%eax
80100a75:	89 04 24             	mov    %eax,(%esp)
80100a78:	e8 4f 11 00 00       	call   80101bcc <iunlock>
  target = n;
80100a7d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a83:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100a8a:	e8 ac 46 00 00       	call   8010513b <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 98 38 00 00       	call   80104333 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100aa9:	e8 f7 46 00 00       	call   801051a5 <release>
        ilock(ip);
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 09 10 00 00       	call   80101ac2 <ilock>
        return -1;
80100ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100abe:	e9 b3 00 00 00       	jmp    80100b76 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100ac3:	c7 44 24 04 80 c8 10 	movl   $0x8010c880,0x4(%esp)
80100aca:	80 
80100acb:	c7 04 24 00 23 11 80 	movl   $0x80112300,(%esp)
80100ad2:	e8 d5 40 00 00       	call   80104bac <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100ad7:	8b 15 00 23 11 80    	mov    0x80112300,%edx
80100add:	a1 04 23 11 80       	mov    0x80112304,%eax
80100ae2:	39 c2                	cmp    %eax,%edx
80100ae4:	74 b0                	je     80100a96 <consoleread+0x2a>
80100ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ae9:	8b 40 54             	mov    0x54(%eax),%eax
80100aec:	0f bf d0             	movswl %ax,%edx
80100aef:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100af4:	39 c2                	cmp    %eax,%edx
80100af6:	75 9e                	jne    80100a96 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100af8:	a1 00 23 11 80       	mov    0x80112300,%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 15 00 23 11 80    	mov    %edx,0x80112300
80100b06:	83 e0 7f             	and    $0x7f,%eax
80100b09:	8a 80 80 22 11 80    	mov    -0x7feedd80(%eax),%al
80100b0f:	0f be c0             	movsbl %al,%eax
80100b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100b15:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b19:	75 17                	jne    80100b32 <consoleread+0xc6>
      if(n < target){
80100b1b:	8b 45 10             	mov    0x10(%ebp),%eax
80100b1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b21:	73 0d                	jae    80100b30 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b23:	a1 00 23 11 80       	mov    0x80112300,%eax
80100b28:	48                   	dec    %eax
80100b29:	a3 00 23 11 80       	mov    %eax,0x80112300
      }
      break;
80100b2e:	eb 25                	jmp    80100b55 <consoleread+0xe9>
80100b30:	eb 23                	jmp    80100b55 <consoleread+0xe9>
    }
    *dst++ = c;
80100b32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b35:	8d 50 01             	lea    0x1(%eax),%edx
80100b38:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b3e:	88 10                	mov    %dl,(%eax)
    --n;
80100b40:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b43:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b47:	75 02                	jne    80100b4b <consoleread+0xdf>
      break;
80100b49:	eb 0a                	jmp    80100b55 <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b4f:	0f 8f 3f ff ff ff    	jg     80100a94 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100b55:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100b5c:	e8 44 46 00 00       	call   801051a5 <release>
  ilock(ip);
80100b61:	8b 45 08             	mov    0x8(%ebp),%eax
80100b64:	89 04 24             	mov    %eax,(%esp)
80100b67:	e8 56 0f 00 00       	call   80101ac2 <ilock>

  return target - n;
80100b6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b72:	29 c2                	sub    %eax,%edx
80100b74:	89 d0                	mov    %edx,%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b81:	8b 40 54             	mov    0x54(%eax),%eax
80100b84:	0f bf d0             	movswl %ax,%edx
80100b87:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100b8c:	39 c2                	cmp    %eax,%edx
80100b8e:	75 5a                	jne    80100bea <consolewrite+0x72>
    iunlock(ip);
80100b90:	8b 45 08             	mov    0x8(%ebp),%eax
80100b93:	89 04 24             	mov    %eax,(%esp)
80100b96:	e8 31 10 00 00       	call   80101bcc <iunlock>
    acquire(&cons.lock);
80100b9b:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100ba2:	e8 94 45 00 00       	call   8010513b <acquire>
    for(i = 0; i < n; i++)
80100ba7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100bae:	eb 1b                	jmp    80100bcb <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bb6:	01 d0                	add    %edx,%eax
80100bb8:	8a 00                	mov    (%eax),%al
80100bba:	0f be c0             	movsbl %al,%eax
80100bbd:	0f b6 c0             	movzbl %al,%eax
80100bc0:	89 04 24             	mov    %eax,(%esp)
80100bc3:	e8 a0 fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100bc8:	ff 45 f4             	incl   -0xc(%ebp)
80100bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bce:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bd1:	7c dd                	jl     80100bb0 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100bd3:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100bda:	e8 c6 45 00 00       	call   801051a5 <release>
    ilock(ip);
80100bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80100be2:	89 04 24             	mov    %eax,(%esp)
80100be5:	e8 d8 0e 00 00       	call   80101ac2 <ilock>
  }
  return n;
80100bea:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bed:	c9                   	leave  
80100bee:	c3                   	ret    

80100bef <consoleinit>:

void
consoleinit(void)
{
80100bef:	55                   	push   %ebp
80100bf0:	89 e5                	mov    %esp,%ebp
80100bf2:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100bf5:	c7 44 24 04 c9 8f 10 	movl   $0x80108fc9,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100c04:	e8 11 45 00 00       	call   8010511a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c09:	c7 05 6c 2e 11 80 78 	movl   $0x80100b78,0x80112e6c
80100c10:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c13:	c7 05 68 2e 11 80 6c 	movl   $0x80100a6c,0x80112e68
80100c1a:	0a 10 80 
  cons.locking = 1;
80100c1d:	c7 05 b4 c8 10 80 01 	movl   $0x1,0x8010c8b4
80100c24:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c2e:	00 
80100c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c36:	e8 4c 1f 00 00       	call   80102b87 <ioapicenable>
}
80100c3b:	c9                   	leave  
80100c3c:	c3                   	ret    
80100c3d:	00 00                	add    %al,(%eax)
	...

80100c40 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c40:	55                   	push   %ebp
80100c41:	89 e5                	mov    %esp,%ebp
80100c43:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c49:	e8 e5 36 00 00       	call   80104333 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 dd 29 00 00       	call   80103633 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 86 19 00 00       	call   801025e7 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 46 2a 00 00       	call   801036b5 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 d1 8f 10 80 	movl   $0x80108fd1,(%esp)
80100c76:	e8 46 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c80:	e9 f6 03 00 00       	jmp    8010107b <exec+0x43b>
  }
  ilock(ip);
80100c85:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c88:	89 04 24             	mov    %eax,(%esp)
80100c8b:	e8 32 0e 00 00       	call   80101ac2 <ilock>
  pgdir = 0;
80100c90:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c97:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100c9e:	00 
80100c9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100ca6:	00 
80100ca7:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cad:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cb4:	89 04 24             	mov    %eax,(%esp)
80100cb7:	e8 9d 12 00 00       	call   80101f59 <readi>
80100cbc:	83 f8 34             	cmp    $0x34,%eax
80100cbf:	74 05                	je     80100cc6 <exec+0x86>
    goto bad;
80100cc1:	e9 89 03 00 00       	jmp    8010104f <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100cc6:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100ccc:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cd1:	74 05                	je     80100cd8 <exec+0x98>
    goto bad;
80100cd3:	e9 77 03 00 00       	jmp    8010104f <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100cd8:	e8 79 73 00 00       	call   80108056 <setupkvm>
80100cdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ce0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ce4:	75 05                	jne    80100ceb <exec+0xab>
    goto bad;
80100ce6:	e9 64 03 00 00       	jmp    8010104f <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100ceb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cf2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cf9:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100cff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d02:	e9 fb 00 00 00       	jmp    80100e02 <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d0a:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d11:	00 
80100d12:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d16:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d23:	89 04 24             	mov    %eax,(%esp)
80100d26:	e8 2e 12 00 00       	call   80101f59 <readi>
80100d2b:	83 f8 20             	cmp    $0x20,%eax
80100d2e:	74 05                	je     80100d35 <exec+0xf5>
      goto bad;
80100d30:	e9 1a 03 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100d35:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d3b:	83 f8 01             	cmp    $0x1,%eax
80100d3e:	74 05                	je     80100d45 <exec+0x105>
      continue;
80100d40:	e9 b1 00 00 00       	jmp    80100df6 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d45:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d4b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d51:	39 c2                	cmp    %eax,%edx
80100d53:	73 05                	jae    80100d5a <exec+0x11a>
      goto bad;
80100d55:	e9 f5 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d5a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d60:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d66:	01 c2                	add    %eax,%edx
80100d68:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d6e:	39 c2                	cmp    %eax,%edx
80100d70:	73 05                	jae    80100d77 <exec+0x137>
      goto bad;
80100d72:	e9 d8 02 00 00       	jmp    8010104f <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d77:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d7d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d83:	01 d0                	add    %edx,%eax
80100d85:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d93:	89 04 24             	mov    %eax,(%esp)
80100d96:	e8 87 76 00 00       	call   80108422 <allocuvm>
80100d9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d9e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100da2:	75 05                	jne    80100da9 <exec+0x169>
      goto bad;
80100da4:	e9 a6 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100da9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100daf:	25 ff 0f 00 00       	and    $0xfff,%eax
80100db4:	85 c0                	test   %eax,%eax
80100db6:	74 05                	je     80100dbd <exec+0x17d>
      goto bad;
80100db8:	e9 92 02 00 00       	jmp    8010104f <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dbd:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dc3:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100dc9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dcf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100dd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100dd7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dda:	89 54 24 08          	mov    %edx,0x8(%esp)
80100dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100de5:	89 04 24             	mov    %eax,(%esp)
80100de8:	e8 52 75 00 00       	call   8010833f <loaduvm>
80100ded:	85 c0                	test   %eax,%eax
80100def:	79 05                	jns    80100df6 <exec+0x1b6>
      goto bad;
80100df1:	e9 59 02 00 00       	jmp    8010104f <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100df6:	ff 45 ec             	incl   -0x14(%ebp)
80100df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dfc:	83 c0 20             	add    $0x20,%eax
80100dff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e02:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100e08:	0f b7 c0             	movzwl %ax,%eax
80100e0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e0e:	0f 8f f3 fe ff ff    	jg     80100d07 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e17:	89 04 24             	mov    %eax,(%esp)
80100e1a:	e8 a2 0e 00 00       	call   80101cc1 <iunlockput>
  end_op();
80100e1f:	e8 91 28 00 00       	call   801036b5 <end_op>
  ip = 0;
80100e24:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e2e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e3e:	05 00 20 00 00       	add    $0x2000,%eax
80100e43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e51:	89 04 24             	mov    %eax,(%esp)
80100e54:	e8 c9 75 00 00       	call   80108422 <allocuvm>
80100e59:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e60:	75 05                	jne    80100e67 <exec+0x227>
    goto bad;
80100e62:	e9 e8 01 00 00       	jmp    8010104f <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e6a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e76:	89 04 24             	mov    %eax,(%esp)
80100e79:	e8 14 78 00 00       	call   80108692 <clearpteu>
  sp = sz;
80100e7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e81:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e84:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e8b:	e9 95 00 00 00       	jmp    80100f25 <exec+0x2e5>
    if(argc >= MAXARG)
80100e90:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e94:	76 05                	jbe    80100e9b <exec+0x25b>
      goto bad;
80100e96:	e9 b4 01 00 00       	jmp    8010104f <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea8:	01 d0                	add    %edx,%eax
80100eaa:	8b 00                	mov    (%eax),%eax
80100eac:	89 04 24             	mov    %eax,(%esp)
80100eaf:	e8 3d 47 00 00       	call   801055f1 <strlen>
80100eb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb7:	29 c2                	sub    %eax,%edx
80100eb9:	89 d0                	mov    %edx,%eax
80100ebb:	48                   	dec    %eax
80100ebc:	83 e0 fc             	and    $0xfffffffc,%eax
80100ebf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ecf:	01 d0                	add    %edx,%eax
80100ed1:	8b 00                	mov    (%eax),%eax
80100ed3:	89 04 24             	mov    %eax,(%esp)
80100ed6:	e8 16 47 00 00       	call   801055f1 <strlen>
80100edb:	40                   	inc    %eax
80100edc:	89 c2                	mov    %eax,%edx
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eeb:	01 c8                	add    %ecx,%eax
80100eed:	8b 00                	mov    (%eax),%eax
80100eef:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100ef3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ef7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100efa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f01:	89 04 24             	mov    %eax,(%esp)
80100f04:	e8 41 79 00 00       	call   8010884a <copyout>
80100f09:	85 c0                	test   %eax,%eax
80100f0b:	79 05                	jns    80100f12 <exec+0x2d2>
      goto bad;
80100f0d:	e9 3d 01 00 00       	jmp    8010104f <exec+0x40f>
    ustack[3+argc] = sp;
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	8d 50 03             	lea    0x3(%eax),%edx
80100f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f1b:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f22:	ff 45 e4             	incl   -0x1c(%ebp)
80100f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f32:	01 d0                	add    %edx,%eax
80100f34:	8b 00                	mov    (%eax),%eax
80100f36:	85 c0                	test   %eax,%eax
80100f38:	0f 85 52 ff ff ff    	jne    80100e90 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	83 c0 03             	add    $0x3,%eax
80100f44:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f4b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f4f:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f56:	ff ff ff 
  ustack[1] = argc;
80100f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5c:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f65:	40                   	inc    %eax
80100f66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f70:	29 d0                	sub    %edx,%eax
80100f72:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7b:	83 c0 04             	add    $0x4,%eax
80100f7e:	c1 e0 02             	shl    $0x2,%eax
80100f81:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f87:	83 c0 04             	add    $0x4,%eax
80100f8a:	c1 e0 02             	shl    $0x2,%eax
80100f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100f91:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f97:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa5:	89 04 24             	mov    %eax,(%esp)
80100fa8:	e8 9d 78 00 00       	call   8010884a <copyout>
80100fad:	85 c0                	test   %eax,%eax
80100faf:	79 05                	jns    80100fb6 <exec+0x376>
    goto bad;
80100fb1:	e9 99 00 00 00       	jmp    8010104f <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fc2:	eb 13                	jmp    80100fd7 <exec+0x397>
    if(*s == '/')
80100fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc7:	8a 00                	mov    (%eax),%al
80100fc9:	3c 2f                	cmp    $0x2f,%al
80100fcb:	75 07                	jne    80100fd4 <exec+0x394>
      last = s+1;
80100fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd0:	40                   	inc    %eax
80100fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fd4:	ff 45 f4             	incl   -0xc(%ebp)
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	8a 00                	mov    (%eax),%al
80100fdc:	84 c0                	test   %al,%al
80100fde:	75 e4                	jne    80100fc4 <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fe0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe3:	8d 50 6c             	lea    0x6c(%eax),%edx
80100fe6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100fed:	00 
80100fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ff5:	89 14 24             	mov    %edx,(%esp)
80100ff8:	e8 ad 45 00 00       	call   801055aa <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ffd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80101006:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101009:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010100c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010100f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101012:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101015:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101017:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010101a:	8b 40 18             	mov    0x18(%eax),%eax
8010101d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101023:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101026:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101029:	8b 40 18             	mov    0x18(%eax),%eax
8010102c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010102f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101032:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101035:	89 04 24             	mov    %eax,(%esp)
80101038:	e8 f3 70 00 00       	call   80108130 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 b4 75 00 00       	call   801085fc <freevm>
  return 0;
80101048:	b8 00 00 00 00       	mov    $0x0,%eax
8010104d:	eb 2c                	jmp    8010107b <exec+0x43b>

 bad:
  if(pgdir)
8010104f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101053:	74 0b                	je     80101060 <exec+0x420>
    freevm(pgdir);
80101055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101058:	89 04 24             	mov    %eax,(%esp)
8010105b:	e8 9c 75 00 00       	call   801085fc <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 3f 26 00 00       	call   801036b5 <end_op>
  }
  return -1;
80101076:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010107b:	c9                   	leave  
8010107c:	c3                   	ret    
8010107d:	00 00                	add    %al,(%eax)
	...

80101080 <strcpy1>:
#include "file.h"
#include "container.h"



char* strcpy1(char *s, char *t){
80101080:	55                   	push   %ebp
80101081:	89 e5                	mov    %esp,%ebp
80101083:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80101086:	8b 45 08             	mov    0x8(%ebp),%eax
80101089:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010108c:	90                   	nop
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8d 50 01             	lea    0x1(%eax),%edx
80101093:	89 55 08             	mov    %edx,0x8(%ebp)
80101096:	8b 55 0c             	mov    0xc(%ebp),%edx
80101099:	8d 4a 01             	lea    0x1(%edx),%ecx
8010109c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010109f:	8a 12                	mov    (%edx),%dl
801010a1:	88 10                	mov    %dl,(%eax)
801010a3:	8a 00                	mov    (%eax),%al
801010a5:	84 c0                	test   %al,%al
801010a7:	75 e4                	jne    8010108d <strcpy1+0xd>
    ;
  return os;
801010a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801010ac:	c9                   	leave  
801010ad:	c3                   	ret    

801010ae <strcmp2>:

int
strcmp2(const char *p, const char *q){
801010ae:	55                   	push   %ebp
801010af:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801010b1:	eb 06                	jmp    801010b9 <strcmp2+0xb>
    p++, q++;
801010b3:	ff 45 08             	incl   0x8(%ebp)
801010b6:	ff 45 0c             	incl   0xc(%ebp)
  return os;
}

int
strcmp2(const char *p, const char *q){
  while(*p && *p == *q)
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	8a 00                	mov    (%eax),%al
801010be:	84 c0                	test   %al,%al
801010c0:	74 0e                	je     801010d0 <strcmp2+0x22>
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8a 10                	mov    (%eax),%dl
801010c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801010ca:	8a 00                	mov    (%eax),%al
801010cc:	38 c2                	cmp    %al,%dl
801010ce:	74 e3                	je     801010b3 <strcmp2+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801010d0:	8b 45 08             	mov    0x8(%ebp),%eax
801010d3:	8a 00                	mov    (%eax),%al
801010d5:	0f b6 d0             	movzbl %al,%edx
801010d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801010db:	8a 00                	mov    (%eax),%al
801010dd:	0f b6 c0             	movzbl %al,%eax
801010e0:	29 c2                	sub    %eax,%edx
801010e2:	89 d0                	mov    %edx,%eax
}
801010e4:	5d                   	pop    %ebp
801010e5:	c3                   	ret    

801010e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010e6:	55                   	push   %ebp
801010e7:	89 e5                	mov    %esp,%ebp
801010e9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010ec:	c7 44 24 04 dd 8f 10 	movl   $0x80108fdd,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801010fb:	e8 1a 40 00 00       	call   8010511a <initlock>
}
80101100:	c9                   	leave  
80101101:	c3                   	ret    

80101102 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101102:	55                   	push   %ebp
80101103:	89 e5                	mov    %esp,%ebp
80101105:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101108:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
8010110f:	e8 27 40 00 00       	call   8010513b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101114:	c7 45 f4 54 23 11 80 	movl   $0x80112354,-0xc(%ebp)
8010111b:	eb 29                	jmp    80101146 <filealloc+0x44>
    if(f->ref == 0){
8010111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101120:	8b 40 04             	mov    0x4(%eax),%eax
80101123:	85 c0                	test   %eax,%eax
80101125:	75 1b                	jne    80101142 <filealloc+0x40>
      f->ref = 1;
80101127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101131:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
80101138:	e8 68 40 00 00       	call   801051a5 <release>
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 1e                	jmp    80101160 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
80101146:	81 7d f4 44 2e 11 80 	cmpl   $0x80112e44,-0xc(%ebp)
8010114d:	72 ce                	jb     8010111d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114f:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
80101156:	e8 4a 40 00 00       	call   801051a5 <release>
  return 0;
8010115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101160:	c9                   	leave  
80101161:	c3                   	ret    

80101162 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101162:	55                   	push   %ebp
80101163:	89 e5                	mov    %esp,%ebp
80101165:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101168:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
8010116f:	e8 c7 3f 00 00       	call   8010513b <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 e4 8f 10 80 	movl   $0x80108fe4,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011a0:	e8 00 40 00 00       	call   801051a5 <release>
  return f;
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011a8:	c9                   	leave  
801011a9:	c3                   	ret    

801011aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011aa:	55                   	push   %ebp
801011ab:	89 e5                	mov    %esp,%ebp
801011ad:	57                   	push   %edi
801011ae:	56                   	push   %esi
801011af:	53                   	push   %ebx
801011b0:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
801011b3:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011ba:	e8 7c 3f 00 00       	call   8010513b <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 ec 8f 10 80 	movl   $0x80108fec,(%esp)
801011d0:	e8 7f f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 04             	mov    0x4(%eax),%eax
801011db:	8d 50 ff             	lea    -0x1(%eax),%edx
801011de:	8b 45 08             	mov    0x8(%ebp),%eax
801011e1:	89 50 04             	mov    %edx,0x4(%eax)
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8b 40 04             	mov    0x4(%eax),%eax
801011ea:	85 c0                	test   %eax,%eax
801011ec:	7e 0e                	jle    801011fc <fileclose+0x52>
    release(&ftable.lock);
801011ee:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011f5:	e8 ab 3f 00 00       	call   801051a5 <release>
801011fa:	eb 70                	jmp    8010126c <fileclose+0xc2>
    return;
  }
  ff = *f;
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8d 55 cc             	lea    -0x34(%ebp),%edx
80101202:	89 c3                	mov    %eax,%ebx
80101204:	b8 07 00 00 00       	mov    $0x7,%eax
80101209:	89 d7                	mov    %edx,%edi
8010120b:	89 de                	mov    %ebx,%esi
8010120d:	89 c1                	mov    %eax,%ecx
8010120f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101224:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
8010122b:	e8 75 3f 00 00       	call   801051a5 <release>

  if(ff.type == FD_PIPE)
80101230:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101233:	83 f8 01             	cmp    $0x1,%eax
80101236:	75 17                	jne    8010124f <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101238:	8a 45 d5             	mov    -0x2b(%ebp),%al
8010123b:	0f be d0             	movsbl %al,%edx
8010123e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101241:	89 54 24 04          	mov    %edx,0x4(%esp)
80101245:	89 04 24             	mov    %eax,(%esp)
80101248:	e8 7e 2d 00 00       	call   80103fcb <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 d7 23 00 00       	call   80103633 <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 49 24 00 00       	call   801036b5 <end_op>
  }
}
8010126c:	83 c4 3c             	add    $0x3c,%esp
8010126f:	5b                   	pop    %ebx
80101270:	5e                   	pop    %esi
80101271:	5f                   	pop    %edi
80101272:	5d                   	pop    %ebp
80101273:	c3                   	ret    

80101274 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101274:	55                   	push   %ebp
80101275:	89 e5                	mov    %esp,%ebp
80101277:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 00                	mov    (%eax),%eax
8010127f:	83 f8 02             	cmp    $0x2,%eax
80101282:	75 38                	jne    801012bc <filestat+0x48>
    ilock(f->ip);
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 40 10             	mov    0x10(%eax),%eax
8010128a:	89 04 24             	mov    %eax,(%esp)
8010128d:	e8 30 08 00 00       	call   80101ac2 <ilock>
    stati(f->ip, st);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 6e 0c 00 00       	call   80101f15 <stati>
    iunlock(f->ip);
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	89 04 24             	mov    %eax,(%esp)
801012b0:	e8 17 09 00 00       	call   80101bcc <iunlock>
    return 0;
801012b5:	b8 00 00 00 00       	mov    $0x0,%eax
801012ba:	eb 05                	jmp    801012c1 <filestat+0x4d>
  }
  return -1;
801012bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012c1:	c9                   	leave  
801012c2:	c3                   	ret    

801012c3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012c3:	55                   	push   %ebp
801012c4:	89 e5                	mov    %esp,%ebp
801012c6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8a 40 08             	mov    0x8(%eax),%al
801012cf:	84 c0                	test   %al,%al
801012d1:	75 0a                	jne    801012dd <fileread+0x1a>
    return -1;
801012d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d8:	e9 9f 00 00 00       	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_PIPE)
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 00                	mov    (%eax),%eax
801012e2:	83 f8 01             	cmp    $0x1,%eax
801012e5:	75 1e                	jne    80101305 <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8b 40 0c             	mov    0xc(%eax),%eax
801012ed:	8b 55 10             	mov    0x10(%ebp),%edx
801012f0:	89 54 24 08          	mov    %edx,0x8(%esp)
801012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801012f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801012fb:	89 04 24             	mov    %eax,(%esp)
801012fe:	e8 46 2e 00 00       	call   80104149 <piperead>
80101303:	eb 77                	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_INODE){
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 00                	mov    (%eax),%eax
8010130a:	83 f8 02             	cmp    $0x2,%eax
8010130d:	75 61                	jne    80101370 <fileread+0xad>
    ilock(f->ip);
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 40 10             	mov    0x10(%eax),%eax
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 a5 07 00 00       	call   80101ac2 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010131d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 50 14             	mov    0x14(%eax),%edx
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 10             	mov    0x10(%eax),%eax
8010132c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101330:	89 54 24 08          	mov    %edx,0x8(%esp)
80101334:	8b 55 0c             	mov    0xc(%ebp),%edx
80101337:	89 54 24 04          	mov    %edx,0x4(%esp)
8010133b:	89 04 24             	mov    %eax,(%esp)
8010133e:	e8 16 0c 00 00       	call   80101f59 <readi>
80101343:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010134a:	7e 11                	jle    8010135d <fileread+0x9a>
      f->off += r;
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	8b 50 14             	mov    0x14(%eax),%edx
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	01 c2                	add    %eax,%edx
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	8b 40 10             	mov    0x10(%eax),%eax
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 61 08 00 00       	call   80101bcc <iunlock>
    return r;
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	eb 0c                	jmp    8010137c <fileread+0xb9>
  }
  panic("fileread");
80101370:	c7 04 24 f6 8f 10 80 	movl   $0x80108ff6,(%esp)
80101377:	e8 d8 f1 ff ff       	call   80100554 <panic>
}
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	53                   	push   %ebx
80101382:	83 ec 24             	sub    $0x24,%esp
  //     x[i] = '\0';
  //     break;
  //   }
  // }

  if(f->writable == 0)
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8a 40 09             	mov    0x9(%eax),%al
8010138b:	84 c0                	test   %al,%al
8010138d:	75 0a                	jne    80101399 <filewrite+0x1b>
    return -1;
8010138f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101394:	e9 20 01 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 00                	mov    (%eax),%eax
8010139e:	83 f8 01             	cmp    $0x1,%eax
801013a1:	75 21                	jne    801013c4 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	8b 40 0c             	mov    0xc(%eax),%eax
801013a9:	8b 55 10             	mov    0x10(%ebp),%edx
801013ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801013b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801013b7:	89 04 24             	mov    %eax,(%esp)
801013ba:	e8 9e 2c 00 00       	call   8010405d <pipewrite>
801013bf:	e9 f5 00 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013c4:	8b 45 08             	mov    0x8(%ebp),%eax
801013c7:	8b 00                	mov    (%eax),%eax
801013c9:	83 f8 02             	cmp    $0x2,%eax
801013cc:	0f 85 db 00 00 00    	jne    801014ad <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013d2:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013e0:	e9 a8 00 00 00       	jmp    8010148d <filewrite+0x10f>
      int n1 = n - i;
801013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e8:	8b 55 10             	mov    0x10(%ebp),%edx
801013eb:	29 c2                	sub    %eax,%edx
801013ed:	89 d0                	mov    %edx,%eax
801013ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013f8:	7e 06                	jle    80101400 <filewrite+0x82>
        n1 = max;
801013fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101400:	e8 2e 22 00 00       	call   80103633 <begin_op>
      ilock(f->ip);
80101405:	8b 45 08             	mov    0x8(%ebp),%eax
80101408:	8b 40 10             	mov    0x10(%eax),%eax
8010140b:	89 04 24             	mov    %eax,(%esp)
8010140e:	e8 af 06 00 00       	call   80101ac2 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0){
80101413:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101416:	8b 45 08             	mov    0x8(%ebp),%eax
80101419:	8b 50 14             	mov    0x14(%eax),%edx
8010141c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010141f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101422:	01 c3                	add    %eax,%ebx
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	8b 40 10             	mov    0x10(%eax),%eax
8010142a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010142e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101432:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101436:	89 04 24             	mov    %eax,(%esp)
80101439:	e8 7f 0c 00 00       	call   801020bd <writei>
8010143e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101441:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101445:	7e 11                	jle    80101458 <filewrite+0xda>
        f->off += r;
80101447:	8b 45 08             	mov    0x8(%ebp),%eax
8010144a:	8b 50 14             	mov    0x14(%eax),%edx
8010144d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101450:	01 c2                	add    %eax,%edx
80101452:	8b 45 08             	mov    0x8(%ebp),%eax
80101455:	89 50 14             	mov    %edx,0x14(%eax)
        // int c_num = find(x);
        // if(c_num >= 0){
        //   set_curr_disk(r, c_num);
        // }
      }
      iunlock(f->ip);
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 40 10             	mov    0x10(%eax),%eax
8010145e:	89 04 24             	mov    %eax,(%esp)
80101461:	e8 66 07 00 00       	call   80101bcc <iunlock>
      end_op();
80101466:	e8 4a 22 00 00       	call   801036b5 <end_op>

      if(r < 0)
8010146b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010146f:	79 02                	jns    80101473 <filewrite+0xf5>
        break;
80101471:	eb 26                	jmp    80101499 <filewrite+0x11b>
      if(r != n1)
80101473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101476:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101479:	74 0c                	je     80101487 <filewrite+0x109>
        panic("short filewrite");
8010147b:	c7 04 24 ff 8f 10 80 	movl   $0x80108fff,(%esp)
80101482:	e8 cd f0 ff ff       	call   80100554 <panic>
      i += r;
80101487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010148a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101490:	3b 45 10             	cmp    0x10(%ebp),%eax
80101493:	0f 8c 4c ff ff ff    	jl     801013e5 <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149f:	75 05                	jne    801014a6 <filewrite+0x128>
801014a1:	8b 45 10             	mov    0x10(%ebp),%eax
801014a4:	eb 05                	jmp    801014ab <filewrite+0x12d>
801014a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014ab:	eb 0c                	jmp    801014b9 <filewrite+0x13b>
  }
  panic("filewrite");
801014ad:	c7 04 24 0f 90 10 80 	movl   $0x8010900f,(%esp)
801014b4:	e8 9b f0 ff ff       	call   80100554 <panic>
}
801014b9:	83 c4 24             	add    $0x24,%esp
801014bc:	5b                   	pop    %ebx
801014bd:	5d                   	pop    %ebp
801014be:	c3                   	ret    
	...

801014c0 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014c0:	55                   	push   %ebp
801014c1:	89 e5                	mov    %esp,%ebp
801014c3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014c6:	8b 45 08             	mov    0x8(%ebp),%eax
801014c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014d0:	00 
801014d1:	89 04 24             	mov    %eax,(%esp)
801014d4:	e8 dc ec ff ff       	call   801001b5 <bread>
801014d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014df:	83 c0 5c             	add    $0x5c,%eax
801014e2:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801014e9:	00 
801014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	89 04 24             	mov    %eax,(%esp)
801014f4:	e8 6e 3f 00 00       	call   80105467 <memmove>
  brelse(bp);
801014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fc:	89 04 24             	mov    %eax,(%esp)
801014ff:	e8 28 ed ff ff       	call   8010022c <brelse>
}
80101504:	c9                   	leave  
80101505:	c3                   	ret    

80101506 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101506:	55                   	push   %ebp
80101507:	89 e5                	mov    %esp,%ebp
80101509:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010150c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010150f:	8b 45 08             	mov    0x8(%ebp),%eax
80101512:	89 54 24 04          	mov    %edx,0x4(%esp)
80101516:	89 04 24             	mov    %eax,(%esp)
80101519:	e8 97 ec ff ff       	call   801001b5 <bread>
8010151e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101524:	83 c0 5c             	add    $0x5c,%eax
80101527:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010152e:	00 
8010152f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101536:	00 
80101537:	89 04 24             	mov    %eax,(%esp)
8010153a:	e8 5f 3e 00 00       	call   8010539e <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 ed 22 00 00       	call   80103837 <log_write>
  brelse(bp);
8010154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154d:	89 04 24             	mov    %eax,(%esp)
80101550:	e8 d7 ec ff ff       	call   8010022c <brelse>
}
80101555:	c9                   	leave  
80101556:	c3                   	ret    

80101557 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101557:	55                   	push   %ebp
80101558:	89 e5                	mov    %esp,%ebp
8010155a:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010155d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010156b:	e9 03 01 00 00       	jmp    80101673 <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
80101570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101573:	85 c0                	test   %eax,%eax
80101575:	79 05                	jns    8010157c <balloc+0x25>
80101577:	05 ff 0f 00 00       	add    $0xfff,%eax
8010157c:	c1 f8 0c             	sar    $0xc,%eax
8010157f:	89 c2                	mov    %eax,%edx
80101581:	a1 d8 2e 11 80       	mov    0x80112ed8,%eax
80101586:	01 d0                	add    %edx,%eax
80101588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 1e ec ff ff       	call   801001b5 <bread>
80101597:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010159a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015a1:	e9 9b 00 00 00       	jmp    80101641 <balloc+0xea>
      m = 1 << (bi % 8);
801015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a9:	25 07 00 00 80       	and    $0x80000007,%eax
801015ae:	85 c0                	test   %eax,%eax
801015b0:	79 05                	jns    801015b7 <balloc+0x60>
801015b2:	48                   	dec    %eax
801015b3:	83 c8 f8             	or     $0xfffffff8,%eax
801015b6:	40                   	inc    %eax
801015b7:	ba 01 00 00 00       	mov    $0x1,%edx
801015bc:	88 c1                	mov    %al,%cl
801015be:	d3 e2                	shl    %cl,%edx
801015c0:	89 d0                	mov    %edx,%eax
801015c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c8:	85 c0                	test   %eax,%eax
801015ca:	79 03                	jns    801015cf <balloc+0x78>
801015cc:	83 c0 07             	add    $0x7,%eax
801015cf:	c1 f8 03             	sar    $0x3,%eax
801015d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015d5:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801015d9:	0f b6 c0             	movzbl %al,%eax
801015dc:	23 45 e8             	and    -0x18(%ebp),%eax
801015df:	85 c0                	test   %eax,%eax
801015e1:	75 5b                	jne    8010163e <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	79 03                	jns    801015ed <balloc+0x96>
801015ea:	83 c0 07             	add    $0x7,%eax
801015ed:	c1 f8 03             	sar    $0x3,%eax
801015f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f3:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801015f7:	88 d1                	mov    %dl,%cl
801015f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015fc:	09 ca                	or     %ecx,%edx
801015fe:	88 d1                	mov    %dl,%cl
80101600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101603:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101607:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 25 22 00 00       	call   80103837 <log_write>
        brelse(bp);
80101612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101615:	89 04 24             	mov    %eax,(%esp)
80101618:	e8 0f ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
8010161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101623:	01 c2                	add    %eax,%edx
80101625:	8b 45 08             	mov    0x8(%ebp),%eax
80101628:	89 54 24 04          	mov    %edx,0x4(%esp)
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 d2 fe ff ff       	call   80101506 <bzero>
        return b + bi;
80101634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163a:	01 d0                	add    %edx,%eax
8010163c:	eb 51                	jmp    8010168f <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010163e:	ff 45 f0             	incl   -0x10(%ebp)
80101641:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101648:	7f 17                	jg     80101661 <balloc+0x10a>
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101650:	01 d0                	add    %edx,%eax
80101652:	89 c2                	mov    %eax,%edx
80101654:	a1 c0 2e 11 80       	mov    0x80112ec0,%eax
80101659:	39 c2                	cmp    %eax,%edx
8010165b:	0f 82 45 ff ff ff    	jb     801015a6 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101661:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101664:	89 04 24             	mov    %eax,(%esp)
80101667:	e8 c0 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010166c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101676:	a1 c0 2e 11 80       	mov    0x80112ec0,%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 82 ed fe ff ff    	jb     80101570 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	c7 04 24 1c 90 10 80 	movl   $0x8010901c,(%esp)
8010168a:	e8 c5 ee ff ff       	call   80100554 <panic>
}
8010168f:	c9                   	leave  
80101690:	c3                   	ret    

80101691 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101691:	55                   	push   %ebp
80101692:	89 e5                	mov    %esp,%ebp
80101694:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101697:	c7 44 24 04 c0 2e 11 	movl   $0x80112ec0,0x4(%esp)
8010169e:	80 
8010169f:	8b 45 08             	mov    0x8(%ebp),%eax
801016a2:	89 04 24             	mov    %eax,(%esp)
801016a5:	e8 16 fe ff ff       	call   801014c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ad:	c1 e8 0c             	shr    $0xc,%eax
801016b0:	89 c2                	mov    %eax,%edx
801016b2:	a1 d8 2e 11 80       	mov    0x80112ed8,%eax
801016b7:	01 c2                	add    %eax,%edx
801016b9:	8b 45 08             	mov    0x8(%ebp),%eax
801016bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c0:	89 04 24             	mov    %eax,(%esp)
801016c3:	e8 ed ea ff ff       	call   801001b5 <bread>
801016c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801016d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d9:	25 07 00 00 80       	and    $0x80000007,%eax
801016de:	85 c0                	test   %eax,%eax
801016e0:	79 05                	jns    801016e7 <bfree+0x56>
801016e2:	48                   	dec    %eax
801016e3:	83 c8 f8             	or     $0xfffffff8,%eax
801016e6:	40                   	inc    %eax
801016e7:	ba 01 00 00 00       	mov    $0x1,%edx
801016ec:	88 c1                	mov    %al,%cl
801016ee:	d3 e2                	shl    %cl,%edx
801016f0:	89 d0                	mov    %edx,%eax
801016f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f8:	85 c0                	test   %eax,%eax
801016fa:	79 03                	jns    801016ff <bfree+0x6e>
801016fc:	83 c0 07             	add    $0x7,%eax
801016ff:	c1 f8 03             	sar    $0x3,%eax
80101702:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101705:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101709:	0f b6 c0             	movzbl %al,%eax
8010170c:	23 45 ec             	and    -0x14(%ebp),%eax
8010170f:	85 c0                	test   %eax,%eax
80101711:	75 0c                	jne    8010171f <bfree+0x8e>
    panic("freeing free block");
80101713:	c7 04 24 32 90 10 80 	movl   $0x80109032,(%esp)
8010171a:	e8 35 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101722:	85 c0                	test   %eax,%eax
80101724:	79 03                	jns    80101729 <bfree+0x98>
80101726:	83 c0 07             	add    $0x7,%eax
80101729:	c1 f8 03             	sar    $0x3,%eax
8010172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172f:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101733:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101736:	f7 d1                	not    %ecx
80101738:	21 ca                	and    %ecx,%edx
8010173a:	88 d1                	mov    %dl,%cl
8010173c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010173f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101746:	89 04 24             	mov    %eax,(%esp)
80101749:	e8 e9 20 00 00       	call   80103837 <log_write>
  brelse(bp);
8010174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101751:	89 04 24             	mov    %eax,(%esp)
80101754:	e8 d3 ea ff ff       	call   8010022c <brelse>
}
80101759:	c9                   	leave  
8010175a:	c3                   	ret    

8010175b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	57                   	push   %edi
8010175f:	56                   	push   %esi
80101760:	53                   	push   %ebx
80101761:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101764:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010176b:	c7 44 24 04 45 90 10 	movl   $0x80109045,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
8010177a:	e8 9b 39 00 00       	call   8010511a <initlock>
  for(i = 0; i < NINODE; i++) {
8010177f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101786:	eb 2b                	jmp    801017b3 <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010178b:	89 d0                	mov    %edx,%eax
8010178d:	c1 e0 03             	shl    $0x3,%eax
80101790:	01 d0                	add    %edx,%eax
80101792:	c1 e0 04             	shl    $0x4,%eax
80101795:	83 c0 30             	add    $0x30,%eax
80101798:	05 e0 2e 11 80       	add    $0x80112ee0,%eax
8010179d:	83 c0 10             	add    $0x10,%eax
801017a0:	c7 44 24 04 4c 90 10 	movl   $0x8010904c,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 2c 38 00 00       	call   80104fdc <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801017b0:	ff 45 e4             	incl   -0x1c(%ebp)
801017b3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017b7:	7e cf                	jle    80101788 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801017b9:	c7 44 24 04 c0 2e 11 	movl   $0x80112ec0,0x4(%esp)
801017c0:	80 
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 f4 fc ff ff       	call   801014c0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 d8 2e 11 80       	mov    0x80112ed8,%eax
801017d1:	8b 3d d4 2e 11 80    	mov    0x80112ed4,%edi
801017d7:	8b 35 d0 2e 11 80    	mov    0x80112ed0,%esi
801017dd:	8b 1d cc 2e 11 80    	mov    0x80112ecc,%ebx
801017e3:	8b 0d c8 2e 11 80    	mov    0x80112ec8,%ecx
801017e9:	8b 15 c4 2e 11 80    	mov    0x80112ec4,%edx
801017ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017f2:	8b 15 c0 2e 11 80    	mov    0x80112ec0,%edx
801017f8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017fc:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101800:	89 74 24 14          	mov    %esi,0x14(%esp)
80101804:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101808:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010180c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010180f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101813:	89 d0                	mov    %edx,%eax
80101815:	89 44 24 04          	mov    %eax,0x4(%esp)
80101819:	c7 04 24 54 90 10 80 	movl   $0x80109054,(%esp)
80101820:	e8 9c eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101825:	83 c4 4c             	add    $0x4c,%esp
80101828:	5b                   	pop    %ebx
80101829:	5e                   	pop    %esi
8010182a:	5f                   	pop    %edi
8010182b:	5d                   	pop    %ebp
8010182c:	c3                   	ret    

8010182d <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010182d:	55                   	push   %ebp
8010182e:	89 e5                	mov    %esp,%ebp
80101830:	83 ec 28             	sub    $0x28,%esp
80101833:	8b 45 0c             	mov    0xc(%ebp),%eax
80101836:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010183a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101841:	e9 9b 00 00 00       	jmp    801018e1 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
80101846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101849:	c1 e8 03             	shr    $0x3,%eax
8010184c:	89 c2                	mov    %eax,%edx
8010184e:	a1 d4 2e 11 80       	mov    0x80112ed4,%eax
80101853:	01 d0                	add    %edx,%eax
80101855:	89 44 24 04          	mov    %eax,0x4(%esp)
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	89 04 24             	mov    %eax,(%esp)
8010185f:	e8 51 e9 ff ff       	call   801001b5 <bread>
80101864:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010186d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101870:	83 e0 07             	and    $0x7,%eax
80101873:	c1 e0 06             	shl    $0x6,%eax
80101876:	01 d0                	add    %edx,%eax
80101878:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010187b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010187e:	8b 00                	mov    (%eax),%eax
80101880:	66 85 c0             	test   %ax,%ax
80101883:	75 4e                	jne    801018d3 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
80101885:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010188c:	00 
8010188d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101894:	00 
80101895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101898:	89 04 24             	mov    %eax,(%esp)
8010189b:	e8 fe 3a 00 00       	call   8010539e <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 83 1f 00 00       	call   80103837 <log_write>
      brelse(bp);
801018b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b7:	89 04 24             	mov    %eax,(%esp)
801018ba:	e8 6d e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
801018bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	89 04 24             	mov    %eax,(%esp)
801018cc:	e8 ea 00 00 00       	call   801019bb <iget>
801018d1:	eb 2a                	jmp    801018fd <ialloc+0xd0>
    }
    brelse(bp);
801018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d6:	89 04 24             	mov    %eax,(%esp)
801018d9:	e8 4e e9 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018de:	ff 45 f4             	incl   -0xc(%ebp)
801018e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018e4:	a1 c8 2e 11 80       	mov    0x80112ec8,%eax
801018e9:	39 c2                	cmp    %eax,%edx
801018eb:	0f 82 55 ff ff ff    	jb     80101846 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018f1:	c7 04 24 a7 90 10 80 	movl   $0x801090a7,(%esp)
801018f8:	e8 57 ec ff ff       	call   80100554 <panic>
}
801018fd:	c9                   	leave  
801018fe:	c3                   	ret    

801018ff <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018ff:	55                   	push   %ebp
80101900:	89 e5                	mov    %esp,%ebp
80101902:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101905:	8b 45 08             	mov    0x8(%ebp),%eax
80101908:	8b 40 04             	mov    0x4(%eax),%eax
8010190b:	c1 e8 03             	shr    $0x3,%eax
8010190e:	89 c2                	mov    %eax,%edx
80101910:	a1 d4 2e 11 80       	mov    0x80112ed4,%eax
80101915:	01 c2                	add    %eax,%edx
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	8b 00                	mov    (%eax),%eax
8010191c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101920:	89 04 24             	mov    %eax,(%esp)
80101923:	e8 8d e8 ff ff       	call   801001b5 <bread>
80101928:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	8b 40 04             	mov    0x4(%eax),%eax
80101937:	83 e0 07             	and    $0x7,%eax
8010193a:	c1 e0 06             	shl    $0x6,%eax
8010193d:	01 d0                	add    %edx,%eax
8010193f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101942:	8b 45 08             	mov    0x8(%ebp),%eax
80101945:	8b 40 50             	mov    0x50(%eax),%eax
80101948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010194b:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	66 8b 40 52          	mov    0x52(%eax),%ax
80101955:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101958:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
8010195c:	8b 45 08             	mov    0x8(%ebp),%eax
8010195f:	8b 40 54             	mov    0x54(%eax),%eax
80101962:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101965:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
80101969:	8b 45 08             	mov    0x8(%ebp),%eax
8010196c:	66 8b 40 56          	mov    0x56(%eax),%ax
80101970:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101973:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
80101977:	8b 45 08             	mov    0x8(%ebp),%eax
8010197a:	8b 50 58             	mov    0x58(%eax),%edx
8010197d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101980:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101983:	8b 45 08             	mov    0x8(%ebp),%eax
80101986:	8d 50 5c             	lea    0x5c(%eax),%edx
80101989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198c:	83 c0 0c             	add    $0xc,%eax
8010198f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101996:	00 
80101997:	89 54 24 04          	mov    %edx,0x4(%esp)
8010199b:	89 04 24             	mov    %eax,(%esp)
8010199e:	e8 c4 3a 00 00       	call   80105467 <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 89 1e 00 00       	call   80103837 <log_write>
  brelse(bp);
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	89 04 24             	mov    %eax,(%esp)
801019b4:	e8 73 e8 ff ff       	call   8010022c <brelse>
}
801019b9:	c9                   	leave  
801019ba:	c3                   	ret    

801019bb <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019bb:	55                   	push   %ebp
801019bc:	89 e5                	mov    %esp,%ebp
801019be:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019c1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
801019c8:	e8 6e 37 00 00       	call   8010513b <acquire>

  // Is the inode already cached?
  empty = 0;
801019cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019d4:	c7 45 f4 14 2f 11 80 	movl   $0x80112f14,-0xc(%ebp)
801019db:	eb 5c                	jmp    80101a39 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e0:	8b 40 08             	mov    0x8(%eax),%eax
801019e3:	85 c0                	test   %eax,%eax
801019e5:	7e 35                	jle    80101a1c <iget+0x61>
801019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ea:	8b 00                	mov    (%eax),%eax
801019ec:	3b 45 08             	cmp    0x8(%ebp),%eax
801019ef:	75 2b                	jne    80101a1c <iget+0x61>
801019f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f4:	8b 40 04             	mov    0x4(%eax),%eax
801019f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801019fa:	75 20                	jne    80101a1c <iget+0x61>
      ip->ref++;
801019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ff:	8b 40 08             	mov    0x8(%eax),%eax
80101a02:	8d 50 01             	lea    0x1(%eax),%edx
80101a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a08:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a0b:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101a12:	e8 8e 37 00 00       	call   801051a5 <release>
      return ip;
80101a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1a:	eb 72                	jmp    80101a8e <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a20:	75 10                	jne    80101a32 <iget+0x77>
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8b 40 08             	mov    0x8(%eax),%eax
80101a28:	85 c0                	test   %eax,%eax
80101a2a:	75 06                	jne    80101a32 <iget+0x77>
      empty = ip;
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a32:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a39:	81 7d f4 34 4b 11 80 	cmpl   $0x80114b34,-0xc(%ebp)
80101a40:	72 9b                	jb     801019dd <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a46:	75 0c                	jne    80101a54 <iget+0x99>
    panic("iget: no inodes");
80101a48:	c7 04 24 b9 90 10 80 	movl   $0x801090b9,(%esp)
80101a4f:	e8 00 eb ff ff       	call   80100554 <panic>

  ip = empty;
80101a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80101a60:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a68:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a7f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101a86:	e8 1a 37 00 00       	call   801051a5 <release>

  return ip;
80101a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a8e:	c9                   	leave  
80101a8f:	c3                   	ret    

80101a90 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a90:	55                   	push   %ebp
80101a91:	89 e5                	mov    %esp,%ebp
80101a93:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a96:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101a9d:	e8 99 36 00 00       	call   8010513b <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101ab8:	e8 e8 36 00 00       	call   801051a5 <release>
  return ip;
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ac0:	c9                   	leave  
80101ac1:	c3                   	ret    

80101ac2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ac2:	55                   	push   %ebp
80101ac3:	89 e5                	mov    %esp,%ebp
80101ac5:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ac8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101acc:	74 0a                	je     80101ad8 <ilock+0x16>
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	8b 40 08             	mov    0x8(%eax),%eax
80101ad4:	85 c0                	test   %eax,%eax
80101ad6:	7f 0c                	jg     80101ae4 <ilock+0x22>
    panic("ilock");
80101ad8:	c7 04 24 c9 90 10 80 	movl   $0x801090c9,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 24 35 00 00       	call   80105016 <acquiresleep>

  if(ip->valid == 0){
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101af8:	85 c0                	test   %eax,%eax
80101afa:	0f 85 ca 00 00 00    	jne    80101bca <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 04             	mov    0x4(%eax),%eax
80101b06:	c1 e8 03             	shr    $0x3,%eax
80101b09:	89 c2                	mov    %eax,%edx
80101b0b:	a1 d4 2e 11 80       	mov    0x80112ed4,%eax
80101b10:	01 c2                	add    %eax,%edx
80101b12:	8b 45 08             	mov    0x8(%ebp),%eax
80101b15:	8b 00                	mov    (%eax),%eax
80101b17:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b1b:	89 04 24             	mov    %eax,(%esp)
80101b1e:	e8 92 e6 ff ff       	call   801001b5 <bread>
80101b23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b29:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	8b 40 04             	mov    0x4(%eax),%eax
80101b32:	83 e0 07             	and    $0x7,%eax
80101b35:	c1 e0 06             	shl    $0x6,%eax
80101b38:	01 d0                	add    %edx,%eax
80101b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b40:	8b 00                	mov    (%eax),%eax
80101b42:	8b 55 08             	mov    0x8(%ebp),%edx
80101b45:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b4c:	66 8b 40 02          	mov    0x2(%eax),%ax
80101b50:	8b 55 08             	mov    0x8(%ebp),%edx
80101b53:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5a:	8b 40 04             	mov    0x4(%eax),%eax
80101b5d:	8b 55 08             	mov    0x8(%ebp),%edx
80101b60:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b67:	66 8b 40 06          	mov    0x6(%eax),%ax
80101b6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b6e:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b75:	8b 50 08             	mov    0x8(%eax),%edx
80101b78:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7b:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b81:	8d 50 0c             	lea    0xc(%eax),%edx
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	83 c0 5c             	add    $0x5c,%eax
80101b8a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101b91:	00 
80101b92:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b96:	89 04 24             	mov    %eax,(%esp)
80101b99:	e8 c9 38 00 00       	call   80105467 <memmove>
    brelse(bp);
80101b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba1:	89 04 24             	mov    %eax,(%esp)
80101ba4:	e8 83 e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb6:	8b 40 50             	mov    0x50(%eax),%eax
80101bb9:	66 85 c0             	test   %ax,%ax
80101bbc:	75 0c                	jne    80101bca <ilock+0x108>
      panic("ilock: no type");
80101bbe:	c7 04 24 cf 90 10 80 	movl   $0x801090cf,(%esp)
80101bc5:	e8 8a e9 ff ff       	call   80100554 <panic>
  }
}
80101bca:	c9                   	leave  
80101bcb:	c3                   	ret    

80101bcc <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bcc:	55                   	push   %ebp
80101bcd:	89 e5                	mov    %esp,%ebp
80101bcf:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bd2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bd6:	74 1c                	je     80101bf4 <iunlock+0x28>
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	83 c0 0c             	add    $0xc,%eax
80101bde:	89 04 24             	mov    %eax,(%esp)
80101be1:	e8 cd 34 00 00       	call   801050b3 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 de 90 10 80 	movl   $0x801090de,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 63 34 00 00       	call   80105071 <releasesleep>
}
80101c0e:	c9                   	leave  
80101c0f:	c3                   	ret    

80101c10 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c10:	55                   	push   %ebp
80101c11:	89 e5                	mov    %esp,%ebp
80101c13:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c16:	8b 45 08             	mov    0x8(%ebp),%eax
80101c19:	83 c0 0c             	add    $0xc,%eax
80101c1c:	89 04 24             	mov    %eax,(%esp)
80101c1f:	e8 f2 33 00 00       	call   80105016 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c24:	8b 45 08             	mov    0x8(%ebp),%eax
80101c27:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c2a:	85 c0                	test   %eax,%eax
80101c2c:	74 5c                	je     80101c8a <iput+0x7a>
80101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c31:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c35:	66 85 c0             	test   %ax,%ax
80101c38:	75 50                	jne    80101c8a <iput+0x7a>
    acquire(&icache.lock);
80101c3a:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c41:	e8 f5 34 00 00       	call   8010513b <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c56:	e8 4a 35 00 00       	call   801051a5 <release>
    if(r == 1){
80101c5b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c5f:	75 29                	jne    80101c8a <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c61:	8b 45 08             	mov    0x8(%ebp),%eax
80101c64:	89 04 24             	mov    %eax,(%esp)
80101c67:	e8 86 01 00 00       	call   80101df2 <itrunc>
      ip->type = 0;
80101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6f:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	89 04 24             	mov    %eax,(%esp)
80101c7b:	e8 7f fc ff ff       	call   801018ff <iupdate>
      ip->valid = 0;
80101c80:	8b 45 08             	mov    0x8(%ebp),%eax
80101c83:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	83 c0 0c             	add    $0xc,%eax
80101c90:	89 04 24             	mov    %eax,(%esp)
80101c93:	e8 d9 33 00 00       	call   80105071 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c9f:	e8 97 34 00 00       	call   8010513b <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101cba:	e8 e6 34 00 00       	call   801051a5 <release>
}
80101cbf:	c9                   	leave  
80101cc0:	c3                   	ret    

80101cc1 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cc1:	55                   	push   %ebp
80101cc2:	89 e5                	mov    %esp,%ebp
80101cc4:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	89 04 24             	mov    %eax,(%esp)
80101ccd:	e8 fa fe ff ff       	call   80101bcc <iunlock>
  iput(ip);
80101cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd5:	89 04 24             	mov    %eax,(%esp)
80101cd8:	e8 33 ff ff ff       	call   80101c10 <iput>
}
80101cdd:	c9                   	leave  
80101cde:	c3                   	ret    

80101cdf <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cdf:	55                   	push   %ebp
80101ce0:	89 e5                	mov    %esp,%ebp
80101ce2:	53                   	push   %ebx
80101ce3:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ce6:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cea:	77 3e                	ja     80101d2a <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101cec:	8b 45 08             	mov    0x8(%ebp),%eax
80101cef:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf2:	83 c2 14             	add    $0x14,%edx
80101cf5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d00:	75 20                	jne    80101d22 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 04 24             	mov    %eax,(%esp)
80101d0a:	e8 48 f8 ff ff       	call   80101557 <balloc>
80101d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d18:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1e:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d25:	e9 c2 00 00 00       	jmp    80101dec <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d2a:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d2e:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d32:	0f 87 a8 00 00 00    	ja     80101de0 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d48:	75 1c                	jne    80101d66 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	8b 00                	mov    (%eax),%eax
80101d4f:	89 04 24             	mov    %eax,(%esp)
80101d52:	e8 00 f8 ff ff       	call   80101557 <balloc>
80101d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d60:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	8b 00                	mov    (%eax),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d72:	89 04 24             	mov    %eax,(%esp)
80101d75:	e8 3b e4 ff ff       	call   801001b5 <bread>
80101d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d80:	83 c0 5c             	add    $0x5c,%eax
80101d83:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d86:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d93:	01 d0                	add    %edx,%eax
80101d95:	8b 00                	mov    (%eax),%eax
80101d97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d9e:	75 30                	jne    80101dd0 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dad:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 00                	mov    (%eax),%eax
80101db5:	89 04 24             	mov    %eax,(%esp)
80101db8:	e8 9a f7 ff ff       	call   80101557 <balloc>
80101dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc3:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc8:	89 04 24             	mov    %eax,(%esp)
80101dcb:	e8 67 1a 00 00       	call   80103837 <log_write>
    }
    brelse(bp);
80101dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd3:	89 04 24             	mov    %eax,(%esp)
80101dd6:	e8 51 e4 ff ff       	call   8010022c <brelse>
    return addr;
80101ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dde:	eb 0c                	jmp    80101dec <bmap+0x10d>
  }

  panic("bmap: out of range");
80101de0:	c7 04 24 e6 90 10 80 	movl   $0x801090e6,(%esp)
80101de7:	e8 68 e7 ff ff       	call   80100554 <panic>
}
80101dec:	83 c4 24             	add    $0x24,%esp
80101def:	5b                   	pop    %ebx
80101df0:	5d                   	pop    %ebp
80101df1:	c3                   	ret    

80101df2 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101df2:	55                   	push   %ebp
80101df3:	89 e5                	mov    %esp,%ebp
80101df5:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101df8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101dff:	eb 43                	jmp    80101e44 <itrunc+0x52>
    if(ip->addrs[i]){
80101e01:	8b 45 08             	mov    0x8(%ebp),%eax
80101e04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e07:	83 c2 14             	add    $0x14,%edx
80101e0a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e0e:	85 c0                	test   %eax,%eax
80101e10:	74 2f                	je     80101e41 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e18:	83 c2 14             	add    $0x14,%edx
80101e1b:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 00                	mov    (%eax),%eax
80101e24:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e28:	89 04 24             	mov    %eax,(%esp)
80101e2b:	e8 61 f8 ff ff       	call   80101691 <bfree>
      ip->addrs[i] = 0;
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e36:	83 c2 14             	add    $0x14,%edx
80101e39:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e40:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e41:	ff 45 f4             	incl   -0xc(%ebp)
80101e44:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e48:	7e b7                	jle    80101e01 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e53:	85 c0                	test   %eax,%eax
80101e55:	0f 84 a3 00 00 00    	je     80101efe <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 00                	mov    (%eax),%eax
80101e69:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e6d:	89 04 24             	mov    %eax,(%esp)
80101e70:	e8 40 e3 ff ff       	call   801001b5 <bread>
80101e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e7b:	83 c0 5c             	add    $0x5c,%eax
80101e7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e88:	eb 3a                	jmp    80101ec4 <itrunc+0xd2>
      if(a[j])
80101e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e97:	01 d0                	add    %edx,%eax
80101e99:	8b 00                	mov    (%eax),%eax
80101e9b:	85 c0                	test   %eax,%eax
80101e9d:	74 22                	je     80101ec1 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eac:	01 d0                	add    %edx,%eax
80101eae:	8b 10                	mov    (%eax),%edx
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	8b 00                	mov    (%eax),%eax
80101eb5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eb9:	89 04 24             	mov    %eax,(%esp)
80101ebc:	e8 d0 f7 ff ff       	call   80101691 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ec1:	ff 45 f0             	incl   -0x10(%ebp)
80101ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec7:	83 f8 7f             	cmp    $0x7f,%eax
80101eca:	76 be                	jbe    80101e8a <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecf:	89 04 24             	mov    %eax,(%esp)
80101ed2:	e8 55 e3 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee3:	8b 00                	mov    (%eax),%eax
80101ee5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ee9:	89 04 24             	mov    %eax,(%esp)
80101eec:	e8 a0 f7 ff ff       	call   80101691 <bfree>
    ip->addrs[NDIRECT] = 0;
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101efb:	00 00 00 
  }

  ip->size = 0;
80101efe:	8b 45 08             	mov    0x8(%ebp),%eax
80101f01:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	89 04 24             	mov    %eax,(%esp)
80101f0e:	e8 ec f9 ff ff       	call   801018ff <iupdate>
}
80101f13:	c9                   	leave  
80101f14:	c3                   	ret    

80101f15 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f15:	55                   	push   %ebp
80101f16:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f18:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1b:	8b 00                	mov    (%eax),%eax
80101f1d:	89 c2                	mov    %eax,%edx
80101f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f22:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	8b 50 04             	mov    0x4(%eax),%edx
80101f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	8b 40 50             	mov    0x50(%eax),%eax
80101f37:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f3a:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f40:	66 8b 40 56          	mov    0x56(%eax),%ax
80101f44:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f47:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 50 58             	mov    0x58(%eax),%edx
80101f51:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f54:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f57:	5d                   	pop    %ebp
80101f58:	c3                   	ret    

80101f59 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f59:	55                   	push   %ebp
80101f5a:	89 e5                	mov    %esp,%ebp
80101f5c:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f62:	8b 40 50             	mov    0x50(%eax),%eax
80101f65:	66 83 f8 03          	cmp    $0x3,%ax
80101f69:	75 60                	jne    80101fcb <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f72:	66 85 c0             	test   %ax,%ax
80101f75:	78 20                	js     80101f97 <readi+0x3e>
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f7e:	66 83 f8 09          	cmp    $0x9,%ax
80101f82:	7f 13                	jg     80101f97 <readi+0x3e>
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f8b:	98                   	cwtl   
80101f8c:	8b 04 c5 60 2e 11 80 	mov    -0x7feed1a0(,%eax,8),%eax
80101f93:	85 c0                	test   %eax,%eax
80101f95:	75 0a                	jne    80101fa1 <readi+0x48>
      return -1;
80101f97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f9c:	e9 1a 01 00 00       	jmp    801020bb <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fa8:	98                   	cwtl   
80101fa9:	8b 04 c5 60 2e 11 80 	mov    -0x7feed1a0(,%eax,8),%eax
80101fb0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fb3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fba:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fbe:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc1:	89 14 24             	mov    %edx,(%esp)
80101fc4:	ff d0                	call   *%eax
80101fc6:	e9 f0 00 00 00       	jmp    801020bb <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	8b 40 58             	mov    0x58(%eax),%eax
80101fd1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd4:	72 0d                	jb     80101fe3 <readi+0x8a>
80101fd6:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd9:	8b 55 10             	mov    0x10(%ebp),%edx
80101fdc:	01 d0                	add    %edx,%eax
80101fde:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fe1:	73 0a                	jae    80101fed <readi+0x94>
    return -1;
80101fe3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fe8:	e9 ce 00 00 00       	jmp    801020bb <readi+0x162>
  if(off + n > ip->size)
80101fed:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff0:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff3:	01 c2                	add    %eax,%edx
80101ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff8:	8b 40 58             	mov    0x58(%eax),%eax
80101ffb:	39 c2                	cmp    %eax,%edx
80101ffd:	76 0c                	jbe    8010200b <readi+0xb2>
    n = ip->size - off;
80101fff:	8b 45 08             	mov    0x8(%ebp),%eax
80102002:	8b 40 58             	mov    0x58(%eax),%eax
80102005:	2b 45 10             	sub    0x10(%ebp),%eax
80102008:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102012:	e9 95 00 00 00       	jmp    801020ac <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102017:	8b 45 10             	mov    0x10(%ebp),%eax
8010201a:	c1 e8 09             	shr    $0x9,%eax
8010201d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	89 04 24             	mov    %eax,(%esp)
80102027:	e8 b3 fc ff ff       	call   80101cdf <bmap>
8010202c:	8b 55 08             	mov    0x8(%ebp),%edx
8010202f:	8b 12                	mov    (%edx),%edx
80102031:	89 44 24 04          	mov    %eax,0x4(%esp)
80102035:	89 14 24             	mov    %edx,(%esp)
80102038:	e8 78 e1 ff ff       	call   801001b5 <bread>
8010203d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102040:	8b 45 10             	mov    0x10(%ebp),%eax
80102043:	25 ff 01 00 00       	and    $0x1ff,%eax
80102048:	89 c2                	mov    %eax,%edx
8010204a:	b8 00 02 00 00       	mov    $0x200,%eax
8010204f:	29 d0                	sub    %edx,%eax
80102051:	89 c1                	mov    %eax,%ecx
80102053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102056:	8b 55 14             	mov    0x14(%ebp),%edx
80102059:	29 c2                	sub    %eax,%edx
8010205b:	89 c8                	mov    %ecx,%eax
8010205d:	39 d0                	cmp    %edx,%eax
8010205f:	76 02                	jbe    80102063 <readi+0x10a>
80102061:	89 d0                	mov    %edx,%eax
80102063:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102066:	8b 45 10             	mov    0x10(%ebp),%eax
80102069:	25 ff 01 00 00       	and    $0x1ff,%eax
8010206e:	8d 50 50             	lea    0x50(%eax),%edx
80102071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102074:	01 d0                	add    %edx,%eax
80102076:	8d 50 0c             	lea    0xc(%eax),%edx
80102079:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102080:	89 54 24 04          	mov    %edx,0x4(%esp)
80102084:	8b 45 0c             	mov    0xc(%ebp),%eax
80102087:	89 04 24             	mov    %eax,(%esp)
8010208a:	e8 d8 33 00 00       	call   80105467 <memmove>
    brelse(bp);
8010208f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102092:	89 04 24             	mov    %eax,(%esp)
80102095:	e8 92 e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010209a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209d:	01 45 f4             	add    %eax,-0xc(%ebp)
801020a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a3:	01 45 10             	add    %eax,0x10(%ebp)
801020a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a9:	01 45 0c             	add    %eax,0xc(%ebp)
801020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020af:	3b 45 14             	cmp    0x14(%ebp),%eax
801020b2:	0f 82 5f ff ff ff    	jb     80102017 <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020b8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020bb:	c9                   	leave  
801020bc:	c3                   	ret    

801020bd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020bd:	55                   	push   %ebp
801020be:	89 e5                	mov    %esp,%ebp
801020c0:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020c3:	8b 45 08             	mov    0x8(%ebp),%eax
801020c6:	8b 40 50             	mov    0x50(%eax),%eax
801020c9:	66 83 f8 03          	cmp    $0x3,%ax
801020cd:	75 60                	jne    8010212f <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020cf:	8b 45 08             	mov    0x8(%ebp),%eax
801020d2:	66 8b 40 52          	mov    0x52(%eax),%ax
801020d6:	66 85 c0             	test   %ax,%ax
801020d9:	78 20                	js     801020fb <writei+0x3e>
801020db:	8b 45 08             	mov    0x8(%ebp),%eax
801020de:	66 8b 40 52          	mov    0x52(%eax),%ax
801020e2:	66 83 f8 09          	cmp    $0x9,%ax
801020e6:	7f 13                	jg     801020fb <writei+0x3e>
801020e8:	8b 45 08             	mov    0x8(%ebp),%eax
801020eb:	66 8b 40 52          	mov    0x52(%eax),%ax
801020ef:	98                   	cwtl   
801020f0:	8b 04 c5 64 2e 11 80 	mov    -0x7feed19c(,%eax,8),%eax
801020f7:	85 c0                	test   %eax,%eax
801020f9:	75 0a                	jne    80102105 <writei+0x48>
      return -1;
801020fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102100:	e9 45 01 00 00       	jmp    8010224a <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102105:	8b 45 08             	mov    0x8(%ebp),%eax
80102108:	66 8b 40 52          	mov    0x52(%eax),%ax
8010210c:	98                   	cwtl   
8010210d:	8b 04 c5 64 2e 11 80 	mov    -0x7feed19c(,%eax,8),%eax
80102114:	8b 55 14             	mov    0x14(%ebp),%edx
80102117:	89 54 24 08          	mov    %edx,0x8(%esp)
8010211b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010211e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102122:	8b 55 08             	mov    0x8(%ebp),%edx
80102125:	89 14 24             	mov    %edx,(%esp)
80102128:	ff d0                	call   *%eax
8010212a:	e9 1b 01 00 00       	jmp    8010224a <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010212f:	8b 45 08             	mov    0x8(%ebp),%eax
80102132:	8b 40 58             	mov    0x58(%eax),%eax
80102135:	3b 45 10             	cmp    0x10(%ebp),%eax
80102138:	72 0d                	jb     80102147 <writei+0x8a>
8010213a:	8b 45 14             	mov    0x14(%ebp),%eax
8010213d:	8b 55 10             	mov    0x10(%ebp),%edx
80102140:	01 d0                	add    %edx,%eax
80102142:	3b 45 10             	cmp    0x10(%ebp),%eax
80102145:	73 0a                	jae    80102151 <writei+0x94>
    return -1;
80102147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010214c:	e9 f9 00 00 00       	jmp    8010224a <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80102151:	8b 45 14             	mov    0x14(%ebp),%eax
80102154:	8b 55 10             	mov    0x10(%ebp),%edx
80102157:	01 d0                	add    %edx,%eax
80102159:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010215e:	76 0a                	jbe    8010216a <writei+0xad>
    return -1;
80102160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102165:	e9 e0 00 00 00       	jmp    8010224a <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102171:	e9 a0 00 00 00       	jmp    80102216 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102176:	8b 45 10             	mov    0x10(%ebp),%eax
80102179:	c1 e8 09             	shr    $0x9,%eax
8010217c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	89 04 24             	mov    %eax,(%esp)
80102186:	e8 54 fb ff ff       	call   80101cdf <bmap>
8010218b:	8b 55 08             	mov    0x8(%ebp),%edx
8010218e:	8b 12                	mov    (%edx),%edx
80102190:	89 44 24 04          	mov    %eax,0x4(%esp)
80102194:	89 14 24             	mov    %edx,(%esp)
80102197:	e8 19 e0 ff ff       	call   801001b5 <bread>
8010219c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010219f:	8b 45 10             	mov    0x10(%ebp),%eax
801021a2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021a7:	89 c2                	mov    %eax,%edx
801021a9:	b8 00 02 00 00       	mov    $0x200,%eax
801021ae:	29 d0                	sub    %edx,%eax
801021b0:	89 c1                	mov    %eax,%ecx
801021b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b5:	8b 55 14             	mov    0x14(%ebp),%edx
801021b8:	29 c2                	sub    %eax,%edx
801021ba:	89 c8                	mov    %ecx,%eax
801021bc:	39 d0                	cmp    %edx,%eax
801021be:	76 02                	jbe    801021c2 <writei+0x105>
801021c0:	89 d0                	mov    %edx,%eax
801021c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021c5:	8b 45 10             	mov    0x10(%ebp),%eax
801021c8:	25 ff 01 00 00       	and    $0x1ff,%eax
801021cd:	8d 50 50             	lea    0x50(%eax),%edx
801021d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021d3:	01 d0                	add    %edx,%eax
801021d5:	8d 50 0c             	lea    0xc(%eax),%edx
801021d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021db:	89 44 24 08          	mov    %eax,0x8(%esp)
801021df:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801021e6:	89 14 24             	mov    %edx,(%esp)
801021e9:	e8 79 32 00 00       	call   80105467 <memmove>
    log_write(bp);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 3e 16 00 00       	call   80103837 <log_write>
    brelse(bp);
801021f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021fc:	89 04 24             	mov    %eax,(%esp)
801021ff:	e8 28 e0 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102204:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102207:	01 45 f4             	add    %eax,-0xc(%ebp)
8010220a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220d:	01 45 10             	add    %eax,0x10(%ebp)
80102210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102213:	01 45 0c             	add    %eax,0xc(%ebp)
80102216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102219:	3b 45 14             	cmp    0x14(%ebp),%eax
8010221c:	0f 82 54 ff ff ff    	jb     80102176 <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102222:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102226:	74 1f                	je     80102247 <writei+0x18a>
80102228:	8b 45 08             	mov    0x8(%ebp),%eax
8010222b:	8b 40 58             	mov    0x58(%eax),%eax
8010222e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102231:	73 14                	jae    80102247 <writei+0x18a>
    ip->size = off;
80102233:	8b 45 08             	mov    0x8(%ebp),%eax
80102236:	8b 55 10             	mov    0x10(%ebp),%edx
80102239:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010223c:	8b 45 08             	mov    0x8(%ebp),%eax
8010223f:	89 04 24             	mov    %eax,(%esp)
80102242:	e8 b8 f6 ff ff       	call   801018ff <iupdate>
  }
  return n;
80102247:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010224a:	c9                   	leave  
8010224b:	c3                   	ret    

8010224c <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010224c:	55                   	push   %ebp
8010224d:	89 e5                	mov    %esp,%ebp
8010224f:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102252:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102259:	00 
8010225a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010225d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102261:	8b 45 08             	mov    0x8(%ebp),%eax
80102264:	89 04 24             	mov    %eax,(%esp)
80102267:	e8 9a 32 00 00       	call   80105506 <strncmp>
}
8010226c:	c9                   	leave  
8010226d:	c3                   	ret    

8010226e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010226e:	55                   	push   %ebp
8010226f:	89 e5                	mov    %esp,%ebp
80102271:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102274:	8b 45 08             	mov    0x8(%ebp),%eax
80102277:	8b 40 50             	mov    0x50(%eax),%eax
8010227a:	66 83 f8 01          	cmp    $0x1,%ax
8010227e:	74 0c                	je     8010228c <dirlookup+0x1e>
    panic("dirlookup not DIR");
80102280:	c7 04 24 f9 90 10 80 	movl   $0x801090f9,(%esp)
80102287:	e8 c8 e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010228c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102293:	e9 86 00 00 00       	jmp    8010231e <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102298:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010229f:	00 
801022a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801022a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ae:	8b 45 08             	mov    0x8(%ebp),%eax
801022b1:	89 04 24             	mov    %eax,(%esp)
801022b4:	e8 a0 fc ff ff       	call   80101f59 <readi>
801022b9:	83 f8 10             	cmp    $0x10,%eax
801022bc:	74 0c                	je     801022ca <dirlookup+0x5c>
      panic("dirlookup read");
801022be:	c7 04 24 0b 91 10 80 	movl   $0x8010910b,(%esp)
801022c5:	e8 8a e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801022ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022cd:	66 85 c0             	test   %ax,%ax
801022d0:	75 02                	jne    801022d4 <dirlookup+0x66>
      continue;
801022d2:	eb 46                	jmp    8010231a <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801022d4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d7:	83 c0 02             	add    $0x2,%eax
801022da:	89 44 24 04          	mov    %eax,0x4(%esp)
801022de:	8b 45 0c             	mov    0xc(%ebp),%eax
801022e1:	89 04 24             	mov    %eax,(%esp)
801022e4:	e8 63 ff ff ff       	call   8010224c <namecmp>
801022e9:	85 c0                	test   %eax,%eax
801022eb:	75 2d                	jne    8010231a <dirlookup+0xac>
      // entry matches path element
      if(poff)
801022ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022f1:	74 08                	je     801022fb <dirlookup+0x8d>
        *poff = off;
801022f3:	8b 45 10             	mov    0x10(%ebp),%eax
801022f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f9:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022fe:	0f b7 c0             	movzwl %ax,%eax
80102301:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102304:	8b 45 08             	mov    0x8(%ebp),%eax
80102307:	8b 00                	mov    (%eax),%eax
80102309:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010230c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102310:	89 04 24             	mov    %eax,(%esp)
80102313:	e8 a3 f6 ff ff       	call   801019bb <iget>
80102318:	eb 18                	jmp    80102332 <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010231a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 40 58             	mov    0x58(%eax),%eax
80102324:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102327:	0f 87 6b ff ff ff    	ja     80102298 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010232d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102332:	c9                   	leave  
80102333:	c3                   	ret    

80102334 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102334:	55                   	push   %ebp
80102335:	89 e5                	mov    %esp,%ebp
80102337:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010233a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102341:	00 
80102342:	8b 45 0c             	mov    0xc(%ebp),%eax
80102345:	89 44 24 04          	mov    %eax,0x4(%esp)
80102349:	8b 45 08             	mov    0x8(%ebp),%eax
8010234c:	89 04 24             	mov    %eax,(%esp)
8010234f:	e8 1a ff ff ff       	call   8010226e <dirlookup>
80102354:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102357:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010235b:	74 15                	je     80102372 <dirlink+0x3e>
    iput(ip);
8010235d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102360:	89 04 24             	mov    %eax,(%esp)
80102363:	e8 a8 f8 ff ff       	call   80101c10 <iput>
    return -1;
80102368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010236d:	e9 b6 00 00 00       	jmp    80102428 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102372:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102379:	eb 45                	jmp    801023c0 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010237b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102385:	00 
80102386:	89 44 24 08          	mov    %eax,0x8(%esp)
8010238a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	89 04 24             	mov    %eax,(%esp)
80102397:	e8 bd fb ff ff       	call   80101f59 <readi>
8010239c:	83 f8 10             	cmp    $0x10,%eax
8010239f:	74 0c                	je     801023ad <dirlink+0x79>
      panic("dirlink read");
801023a1:	c7 04 24 1a 91 10 80 	movl   $0x8010911a,(%esp)
801023a8:	e8 a7 e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801023ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023b0:	66 85 c0             	test   %ax,%ax
801023b3:	75 02                	jne    801023b7 <dirlink+0x83>
      break;
801023b5:	eb 16                	jmp    801023cd <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ba:	83 c0 10             	add    $0x10,%eax
801023bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023c3:	8b 45 08             	mov    0x8(%ebp),%eax
801023c6:	8b 40 58             	mov    0x58(%eax),%eax
801023c9:	39 c2                	cmp    %eax,%edx
801023cb:	72 ae                	jb     8010237b <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801023cd:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023d4:	00 
801023d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	89 04 24             	mov    %eax,(%esp)
801023e5:	e8 6a 31 00 00       	call   80105554 <strncpy>
  de.inum = inum;
801023ea:	8b 45 10             	mov    0x10(%ebp),%eax
801023ed:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023fb:	00 
801023fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80102400:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102403:	89 44 24 04          	mov    %eax,0x4(%esp)
80102407:	8b 45 08             	mov    0x8(%ebp),%eax
8010240a:	89 04 24             	mov    %eax,(%esp)
8010240d:	e8 ab fc ff ff       	call   801020bd <writei>
80102412:	83 f8 10             	cmp    $0x10,%eax
80102415:	74 0c                	je     80102423 <dirlink+0xef>
    panic("dirlink");
80102417:	c7 04 24 27 91 10 80 	movl   $0x80109127,(%esp)
8010241e:	e8 31 e1 ff ff       	call   80100554 <panic>

  return 0;
80102423:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102428:	c9                   	leave  
80102429:	c3                   	ret    

8010242a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010242a:	55                   	push   %ebp
8010242b:	89 e5                	mov    %esp,%ebp
8010242d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102430:	eb 03                	jmp    80102435 <skipelem+0xb>
    path++;
80102432:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102435:	8b 45 08             	mov    0x8(%ebp),%eax
80102438:	8a 00                	mov    (%eax),%al
8010243a:	3c 2f                	cmp    $0x2f,%al
8010243c:	74 f4                	je     80102432 <skipelem+0x8>
    path++;
  if(*path == 0)
8010243e:	8b 45 08             	mov    0x8(%ebp),%eax
80102441:	8a 00                	mov    (%eax),%al
80102443:	84 c0                	test   %al,%al
80102445:	75 0a                	jne    80102451 <skipelem+0x27>
    return 0;
80102447:	b8 00 00 00 00       	mov    $0x0,%eax
8010244c:	e9 81 00 00 00       	jmp    801024d2 <skipelem+0xa8>
  s = path;
80102451:	8b 45 08             	mov    0x8(%ebp),%eax
80102454:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102457:	eb 03                	jmp    8010245c <skipelem+0x32>
    path++;
80102459:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010245c:	8b 45 08             	mov    0x8(%ebp),%eax
8010245f:	8a 00                	mov    (%eax),%al
80102461:	3c 2f                	cmp    $0x2f,%al
80102463:	74 09                	je     8010246e <skipelem+0x44>
80102465:	8b 45 08             	mov    0x8(%ebp),%eax
80102468:	8a 00                	mov    (%eax),%al
8010246a:	84 c0                	test   %al,%al
8010246c:	75 eb                	jne    80102459 <skipelem+0x2f>
    path++;
  len = path - s;
8010246e:	8b 55 08             	mov    0x8(%ebp),%edx
80102471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102474:	29 c2                	sub    %eax,%edx
80102476:	89 d0                	mov    %edx,%eax
80102478:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010247b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010247f:	7e 1c                	jle    8010249d <skipelem+0x73>
    memmove(name, s, DIRSIZ);
80102481:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102488:	00 
80102489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010248c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102490:	8b 45 0c             	mov    0xc(%ebp),%eax
80102493:	89 04 24             	mov    %eax,(%esp)
80102496:	e8 cc 2f 00 00       	call   80105467 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010249b:	eb 29                	jmp    801024c6 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
8010249d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a0:	89 44 24 08          	mov    %eax,0x8(%esp)
801024a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ae:	89 04 24             	mov    %eax,(%esp)
801024b1:	e8 b1 2f 00 00       	call   80105467 <memmove>
    name[len] = 0;
801024b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801024bc:	01 d0                	add    %edx,%eax
801024be:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024c1:	eb 03                	jmp    801024c6 <skipelem+0x9c>
    path++;
801024c3:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024c6:	8b 45 08             	mov    0x8(%ebp),%eax
801024c9:	8a 00                	mov    (%eax),%al
801024cb:	3c 2f                	cmp    $0x2f,%al
801024cd:	74 f4                	je     801024c3 <skipelem+0x99>
    path++;
  return path;
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024d2:	c9                   	leave  
801024d3:	c3                   	ret    

801024d4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024d4:	55                   	push   %ebp
801024d5:	89 e5                	mov    %esp,%ebp
801024d7:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024da:	8b 45 08             	mov    0x8(%ebp),%eax
801024dd:	8a 00                	mov    (%eax),%al
801024df:	3c 2f                	cmp    $0x2f,%al
801024e1:	75 1c                	jne    801024ff <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024ea:	00 
801024eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801024f2:	e8 c4 f4 ff ff       	call   801019bb <iget>
801024f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801024fa:	e9 ac 00 00 00       	jmp    801025ab <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801024ff:	e8 2f 1e 00 00       	call   80104333 <myproc>
80102504:	8b 40 68             	mov    0x68(%eax),%eax
80102507:	89 04 24             	mov    %eax,(%esp)
8010250a:	e8 81 f5 ff ff       	call   80101a90 <idup>
8010250f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102512:	e9 94 00 00 00       	jmp    801025ab <namex+0xd7>
    ilock(ip);
80102517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251a:	89 04 24             	mov    %eax,(%esp)
8010251d:	e8 a0 f5 ff ff       	call   80101ac2 <ilock>
    if(ip->type != T_DIR){
80102522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102525:	8b 40 50             	mov    0x50(%eax),%eax
80102528:	66 83 f8 01          	cmp    $0x1,%ax
8010252c:	74 15                	je     80102543 <namex+0x6f>
      iunlockput(ip);
8010252e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102531:	89 04 24             	mov    %eax,(%esp)
80102534:	e8 88 f7 ff ff       	call   80101cc1 <iunlockput>
      return 0;
80102539:	b8 00 00 00 00       	mov    $0x0,%eax
8010253e:	e9 a2 00 00 00       	jmp    801025e5 <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
80102543:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102547:	74 1c                	je     80102565 <namex+0x91>
80102549:	8b 45 08             	mov    0x8(%ebp),%eax
8010254c:	8a 00                	mov    (%eax),%al
8010254e:	84 c0                	test   %al,%al
80102550:	75 13                	jne    80102565 <namex+0x91>
      // Stop one level early.
      iunlock(ip);
80102552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102555:	89 04 24             	mov    %eax,(%esp)
80102558:	e8 6f f6 ff ff       	call   80101bcc <iunlock>
      return ip;
8010255d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102560:	e9 80 00 00 00       	jmp    801025e5 <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102565:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010256c:	00 
8010256d:	8b 45 10             	mov    0x10(%ebp),%eax
80102570:	89 44 24 04          	mov    %eax,0x4(%esp)
80102574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102577:	89 04 24             	mov    %eax,(%esp)
8010257a:	e8 ef fc ff ff       	call   8010226e <dirlookup>
8010257f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102582:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102586:	75 12                	jne    8010259a <namex+0xc6>
      iunlockput(ip);
80102588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010258b:	89 04 24             	mov    %eax,(%esp)
8010258e:	e8 2e f7 ff ff       	call   80101cc1 <iunlockput>
      return 0;
80102593:	b8 00 00 00 00       	mov    $0x0,%eax
80102598:	eb 4b                	jmp    801025e5 <namex+0x111>
    }
    iunlockput(ip);
8010259a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010259d:	89 04 24             	mov    %eax,(%esp)
801025a0:	e8 1c f7 ff ff       	call   80101cc1 <iunlockput>
    ip = next;
801025a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801025ab:	8b 45 10             	mov    0x10(%ebp),%eax
801025ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801025b2:	8b 45 08             	mov    0x8(%ebp),%eax
801025b5:	89 04 24             	mov    %eax,(%esp)
801025b8:	e8 6d fe ff ff       	call   8010242a <skipelem>
801025bd:	89 45 08             	mov    %eax,0x8(%ebp)
801025c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c4:	0f 85 4d ff ff ff    	jne    80102517 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025ce:	74 12                	je     801025e2 <namex+0x10e>
    iput(ip);
801025d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d3:	89 04 24             	mov    %eax,(%esp)
801025d6:	e8 35 f6 ff ff       	call   80101c10 <iput>
    return 0;
801025db:	b8 00 00 00 00       	mov    $0x0,%eax
801025e0:	eb 03                	jmp    801025e5 <namex+0x111>
  }
  return ip;
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e5:	c9                   	leave  
801025e6:	c3                   	ret    

801025e7 <namei>:

struct inode*
namei(char *path)
{
801025e7:	55                   	push   %ebp
801025e8:	89 e5                	mov    %esp,%ebp
801025ea:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025ed:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025f0:	89 44 24 08          	mov    %eax,0x8(%esp)
801025f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025fb:	00 
801025fc:	8b 45 08             	mov    0x8(%ebp),%eax
801025ff:	89 04 24             	mov    %eax,(%esp)
80102602:	e8 cd fe ff ff       	call   801024d4 <namex>
}
80102607:	c9                   	leave  
80102608:	c3                   	ret    

80102609 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102609:	55                   	push   %ebp
8010260a:	89 e5                	mov    %esp,%ebp
8010260c:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010260f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102612:	89 44 24 08          	mov    %eax,0x8(%esp)
80102616:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010261d:	00 
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	89 04 24             	mov    %eax,(%esp)
80102624:	e8 ab fe ff ff       	call   801024d4 <namex>
}
80102629:	c9                   	leave  
8010262a:	c3                   	ret    
	...

8010262c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010262c:	55                   	push   %ebp
8010262d:	89 e5                	mov    %esp,%ebp
8010262f:	83 ec 14             	sub    $0x14,%esp
80102632:	8b 45 08             	mov    0x8(%ebp),%eax
80102635:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010263c:	89 c2                	mov    %eax,%edx
8010263e:	ec                   	in     (%dx),%al
8010263f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102642:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102645:	c9                   	leave  
80102646:	c3                   	ret    

80102647 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102647:	55                   	push   %ebp
80102648:	89 e5                	mov    %esp,%ebp
8010264a:	57                   	push   %edi
8010264b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010264c:	8b 55 08             	mov    0x8(%ebp),%edx
8010264f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102652:	8b 45 10             	mov    0x10(%ebp),%eax
80102655:	89 cb                	mov    %ecx,%ebx
80102657:	89 df                	mov    %ebx,%edi
80102659:	89 c1                	mov    %eax,%ecx
8010265b:	fc                   	cld    
8010265c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010265e:	89 c8                	mov    %ecx,%eax
80102660:	89 fb                	mov    %edi,%ebx
80102662:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102665:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102668:	5b                   	pop    %ebx
80102669:	5f                   	pop    %edi
8010266a:	5d                   	pop    %ebp
8010266b:	c3                   	ret    

8010266c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010266c:	55                   	push   %ebp
8010266d:	89 e5                	mov    %esp,%ebp
8010266f:	83 ec 08             	sub    $0x8,%esp
80102672:	8b 45 08             	mov    0x8(%ebp),%eax
80102675:	8b 55 0c             	mov    0xc(%ebp),%edx
80102678:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010267c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010267f:	8a 45 f8             	mov    -0x8(%ebp),%al
80102682:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102685:	ee                   	out    %al,(%dx)
}
80102686:	c9                   	leave  
80102687:	c3                   	ret    

80102688 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102688:	55                   	push   %ebp
80102689:	89 e5                	mov    %esp,%ebp
8010268b:	56                   	push   %esi
8010268c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010268d:	8b 55 08             	mov    0x8(%ebp),%edx
80102690:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102693:	8b 45 10             	mov    0x10(%ebp),%eax
80102696:	89 cb                	mov    %ecx,%ebx
80102698:	89 de                	mov    %ebx,%esi
8010269a:	89 c1                	mov    %eax,%ecx
8010269c:	fc                   	cld    
8010269d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010269f:	89 c8                	mov    %ecx,%eax
801026a1:	89 f3                	mov    %esi,%ebx
801026a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026a6:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801026a9:	5b                   	pop    %ebx
801026aa:	5e                   	pop    %esi
801026ab:	5d                   	pop    %ebp
801026ac:	c3                   	ret    

801026ad <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026ad:	55                   	push   %ebp
801026ae:	89 e5                	mov    %esp,%ebp
801026b0:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026b3:	90                   	nop
801026b4:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026bb:	e8 6c ff ff ff       	call   8010262c <inb>
801026c0:	0f b6 c0             	movzbl %al,%eax
801026c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026c9:	25 c0 00 00 00       	and    $0xc0,%eax
801026ce:	83 f8 40             	cmp    $0x40,%eax
801026d1:	75 e1                	jne    801026b4 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026d7:	74 11                	je     801026ea <idewait+0x3d>
801026d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026dc:	83 e0 21             	and    $0x21,%eax
801026df:	85 c0                	test   %eax,%eax
801026e1:	74 07                	je     801026ea <idewait+0x3d>
    return -1;
801026e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026e8:	eb 05                	jmp    801026ef <idewait+0x42>
  return 0;
801026ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026ef:	c9                   	leave  
801026f0:	c3                   	ret    

801026f1 <ideinit>:

void
ideinit(void)
{
801026f1:	55                   	push   %ebp
801026f2:	89 e5                	mov    %esp,%ebp
801026f4:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801026f7:	c7 44 24 04 2f 91 10 	movl   $0x8010912f,0x4(%esp)
801026fe:	80 
801026ff:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102706:	e8 0f 2a 00 00       	call   8010511a <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010270b:	a1 00 52 11 80       	mov    0x80115200,%eax
80102710:	48                   	dec    %eax
80102711:	89 44 24 04          	mov    %eax,0x4(%esp)
80102715:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010271c:	e8 66 04 00 00       	call   80102b87 <ioapicenable>
  idewait(0);
80102721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102728:	e8 80 ff ff ff       	call   801026ad <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010272d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102734:	00 
80102735:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010273c:	e8 2b ff ff ff       	call   8010266c <outb>
  for(i=0; i<1000; i++){
80102741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102748:	eb 1f                	jmp    80102769 <ideinit+0x78>
    if(inb(0x1f7) != 0){
8010274a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102751:	e8 d6 fe ff ff       	call   8010262c <inb>
80102756:	84 c0                	test   %al,%al
80102758:	74 0c                	je     80102766 <ideinit+0x75>
      havedisk1 = 1;
8010275a:	c7 05 f8 c8 10 80 01 	movl   $0x1,0x8010c8f8
80102761:	00 00 00 
      break;
80102764:	eb 0c                	jmp    80102772 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102766:	ff 45 f4             	incl   -0xc(%ebp)
80102769:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102770:	7e d8                	jle    8010274a <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102772:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102779:	00 
8010277a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102781:	e8 e6 fe ff ff       	call   8010266c <outb>
}
80102786:	c9                   	leave  
80102787:	c3                   	ret    

80102788 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102788:	55                   	push   %ebp
80102789:	89 e5                	mov    %esp,%ebp
8010278b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010278e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102792:	75 0c                	jne    801027a0 <idestart+0x18>
    panic("idestart");
80102794:	c7 04 24 33 91 10 80 	movl   $0x80109133,(%esp)
8010279b:	e8 b4 dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801027a0:	8b 45 08             	mov    0x8(%ebp),%eax
801027a3:	8b 40 08             	mov    0x8(%eax),%eax
801027a6:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027ab:	76 0c                	jbe    801027b9 <idestart+0x31>
    panic("incorrect blockno");
801027ad:	c7 04 24 3c 91 10 80 	movl   $0x8010913c,(%esp)
801027b4:	e8 9b dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027b9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027c0:	8b 45 08             	mov    0x8(%ebp),%eax
801027c3:	8b 50 08             	mov    0x8(%eax),%edx
801027c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c9:	0f af c2             	imul   %edx,%eax
801027cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027cf:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027d3:	75 07                	jne    801027dc <idestart+0x54>
801027d5:	b8 20 00 00 00       	mov    $0x20,%eax
801027da:	eb 05                	jmp    801027e1 <idestart+0x59>
801027dc:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027e4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027e8:	75 07                	jne    801027f1 <idestart+0x69>
801027ea:	b8 30 00 00 00       	mov    $0x30,%eax
801027ef:	eb 05                	jmp    801027f6 <idestart+0x6e>
801027f1:	b8 c5 00 00 00       	mov    $0xc5,%eax
801027f6:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027f9:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027fd:	7e 0c                	jle    8010280b <idestart+0x83>
801027ff:	c7 04 24 33 91 10 80 	movl   $0x80109133,(%esp)
80102806:	e8 49 dd ff ff       	call   80100554 <panic>

  idewait(0);
8010280b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102812:	e8 96 fe ff ff       	call   801026ad <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102817:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010281e:	00 
8010281f:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102826:	e8 41 fe ff ff       	call   8010266c <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010282b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282e:	0f b6 c0             	movzbl %al,%eax
80102831:	89 44 24 04          	mov    %eax,0x4(%esp)
80102835:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010283c:	e8 2b fe ff ff       	call   8010266c <outb>
  outb(0x1f3, sector & 0xff);
80102841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102844:	0f b6 c0             	movzbl %al,%eax
80102847:	89 44 24 04          	mov    %eax,0x4(%esp)
8010284b:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102852:	e8 15 fe ff ff       	call   8010266c <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010285a:	c1 f8 08             	sar    $0x8,%eax
8010285d:	0f b6 c0             	movzbl %al,%eax
80102860:	89 44 24 04          	mov    %eax,0x4(%esp)
80102864:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010286b:	e8 fc fd ff ff       	call   8010266c <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102873:	c1 f8 10             	sar    $0x10,%eax
80102876:	0f b6 c0             	movzbl %al,%eax
80102879:	89 44 24 04          	mov    %eax,0x4(%esp)
8010287d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102884:	e8 e3 fd ff ff       	call   8010266c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102889:	8b 45 08             	mov    0x8(%ebp),%eax
8010288c:	8b 40 04             	mov    0x4(%eax),%eax
8010288f:	83 e0 01             	and    $0x1,%eax
80102892:	c1 e0 04             	shl    $0x4,%eax
80102895:	88 c2                	mov    %al,%dl
80102897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010289a:	c1 f8 18             	sar    $0x18,%eax
8010289d:	83 e0 0f             	and    $0xf,%eax
801028a0:	09 d0                	or     %edx,%eax
801028a2:	83 c8 e0             	or     $0xffffffe0,%eax
801028a5:	0f b6 c0             	movzbl %al,%eax
801028a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ac:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028b3:	e8 b4 fd ff ff       	call   8010266c <outb>
  if(b->flags & B_DIRTY){
801028b8:	8b 45 08             	mov    0x8(%ebp),%eax
801028bb:	8b 00                	mov    (%eax),%eax
801028bd:	83 e0 04             	and    $0x4,%eax
801028c0:	85 c0                	test   %eax,%eax
801028c2:	74 36                	je     801028fa <idestart+0x172>
    outb(0x1f7, write_cmd);
801028c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028c7:	0f b6 c0             	movzbl %al,%eax
801028ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ce:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028d5:	e8 92 fd ff ff       	call   8010266c <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801028da:	8b 45 08             	mov    0x8(%ebp),%eax
801028dd:	83 c0 5c             	add    $0x5c,%eax
801028e0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028e7:	00 
801028e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ec:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028f3:	e8 90 fd ff ff       	call   80102688 <outsl>
801028f8:	eb 16                	jmp    80102910 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
801028fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028fd:	0f b6 c0             	movzbl %al,%eax
80102900:	89 44 24 04          	mov    %eax,0x4(%esp)
80102904:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010290b:	e8 5c fd ff ff       	call   8010266c <outb>
  }
}
80102910:	c9                   	leave  
80102911:	c3                   	ret    

80102912 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102912:	55                   	push   %ebp
80102913:	89 e5                	mov    %esp,%ebp
80102915:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102918:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
8010291f:	e8 17 28 00 00       	call   8010513b <acquire>

  if((b = idequeue) == 0){
80102924:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102929:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010292c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102930:	75 11                	jne    80102943 <ideintr+0x31>
    release(&idelock);
80102932:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102939:	e8 67 28 00 00       	call   801051a5 <release>
    return;
8010293e:	e9 90 00 00 00       	jmp    801029d3 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102946:	8b 40 58             	mov    0x58(%eax),%eax
80102949:	a3 f4 c8 10 80       	mov    %eax,0x8010c8f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010294e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102951:	8b 00                	mov    (%eax),%eax
80102953:	83 e0 04             	and    $0x4,%eax
80102956:	85 c0                	test   %eax,%eax
80102958:	75 2e                	jne    80102988 <ideintr+0x76>
8010295a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102961:	e8 47 fd ff ff       	call   801026ad <idewait>
80102966:	85 c0                	test   %eax,%eax
80102968:	78 1e                	js     80102988 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
8010296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296d:	83 c0 5c             	add    $0x5c,%eax
80102970:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102977:	00 
80102978:	89 44 24 04          	mov    %eax,0x4(%esp)
8010297c:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102983:	e8 bf fc ff ff       	call   80102647 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298b:	8b 00                	mov    (%eax),%eax
8010298d:	83 c8 02             	or     $0x2,%eax
80102990:	89 c2                	mov    %eax,%edx
80102992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102995:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299a:	8b 00                	mov    (%eax),%eax
8010299c:	83 e0 fb             	and    $0xfffffffb,%eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a4:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	89 04 24             	mov    %eax,(%esp)
801029ac:	e8 d2 22 00 00       	call   80104c83 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029b1:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
801029b6:	85 c0                	test   %eax,%eax
801029b8:	74 0d                	je     801029c7 <ideintr+0xb5>
    idestart(idequeue);
801029ba:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
801029bf:	89 04 24             	mov    %eax,(%esp)
801029c2:	e8 c1 fd ff ff       	call   80102788 <idestart>

  release(&idelock);
801029c7:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
801029ce:	e8 d2 27 00 00       	call   801051a5 <release>
}
801029d3:	c9                   	leave  
801029d4:	c3                   	ret    

801029d5 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029d5:	55                   	push   %ebp
801029d6:	89 e5                	mov    %esp,%ebp
801029d8:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801029db:	8b 45 08             	mov    0x8(%ebp),%eax
801029de:	83 c0 0c             	add    $0xc,%eax
801029e1:	89 04 24             	mov    %eax,(%esp)
801029e4:	e8 ca 26 00 00       	call   801050b3 <holdingsleep>
801029e9:	85 c0                	test   %eax,%eax
801029eb:	75 0c                	jne    801029f9 <iderw+0x24>
    panic("iderw: buf not locked");
801029ed:	c7 04 24 4e 91 10 80 	movl   $0x8010914e,(%esp)
801029f4:	e8 5b db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	8b 00                	mov    (%eax),%eax
801029fe:	83 e0 06             	and    $0x6,%eax
80102a01:	83 f8 02             	cmp    $0x2,%eax
80102a04:	75 0c                	jne    80102a12 <iderw+0x3d>
    panic("iderw: nothing to do");
80102a06:	c7 04 24 64 91 10 80 	movl   $0x80109164,(%esp)
80102a0d:	e8 42 db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102a12:	8b 45 08             	mov    0x8(%ebp),%eax
80102a15:	8b 40 04             	mov    0x4(%eax),%eax
80102a18:	85 c0                	test   %eax,%eax
80102a1a:	74 15                	je     80102a31 <iderw+0x5c>
80102a1c:	a1 f8 c8 10 80       	mov    0x8010c8f8,%eax
80102a21:	85 c0                	test   %eax,%eax
80102a23:	75 0c                	jne    80102a31 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102a25:	c7 04 24 79 91 10 80 	movl   $0x80109179,(%esp)
80102a2c:	e8 23 db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a31:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102a38:	e8 fe 26 00 00       	call   8010513b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a40:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a47:	c7 45 f4 f4 c8 10 80 	movl   $0x8010c8f4,-0xc(%ebp)
80102a4e:	eb 0b                	jmp    80102a5b <iderw+0x86>
80102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a53:	8b 00                	mov    (%eax),%eax
80102a55:	83 c0 58             	add    $0x58,%eax
80102a58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	85 c0                	test   %eax,%eax
80102a62:	75 ec                	jne    80102a50 <iderw+0x7b>
    ;
  *pp = b;
80102a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a67:	8b 55 08             	mov    0x8(%ebp),%edx
80102a6a:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a6c:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102a71:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a74:	75 0d                	jne    80102a83 <iderw+0xae>
    idestart(b);
80102a76:	8b 45 08             	mov    0x8(%ebp),%eax
80102a79:	89 04 24             	mov    %eax,(%esp)
80102a7c:	e8 07 fd ff ff       	call   80102788 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a81:	eb 15                	jmp    80102a98 <iderw+0xc3>
80102a83:	eb 13                	jmp    80102a98 <iderw+0xc3>
    sleep(b, &idelock);
80102a85:	c7 44 24 04 c0 c8 10 	movl   $0x8010c8c0,0x4(%esp)
80102a8c:	80 
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	89 04 24             	mov    %eax,(%esp)
80102a93:	e8 14 21 00 00       	call   80104bac <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a98:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9b:	8b 00                	mov    (%eax),%eax
80102a9d:	83 e0 06             	and    $0x6,%eax
80102aa0:	83 f8 02             	cmp    $0x2,%eax
80102aa3:	75 e0                	jne    80102a85 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102aa5:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102aac:	e8 f4 26 00 00       	call   801051a5 <release>
}
80102ab1:	c9                   	leave  
80102ab2:	c3                   	ret    
	...

80102ab4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ab4:	55                   	push   %ebp
80102ab5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ab7:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102abc:	8b 55 08             	mov    0x8(%ebp),%edx
80102abf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ac1:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102ac6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ac9:	5d                   	pop    %ebp
80102aca:	c3                   	ret    

80102acb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102acb:	55                   	push   %ebp
80102acc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ace:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102ad3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ad8:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102add:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ae0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ae3:	5d                   	pop    %ebp
80102ae4:	c3                   	ret    

80102ae5 <ioapicinit>:

void
ioapicinit(void)
{
80102ae5:	55                   	push   %ebp
80102ae6:	89 e5                	mov    %esp,%ebp
80102ae8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102aeb:	c7 05 34 4b 11 80 00 	movl   $0xfec00000,0x80114b34
80102af2:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102af5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102afc:	e8 b3 ff ff ff       	call   80102ab4 <ioapicread>
80102b01:	c1 e8 10             	shr    $0x10,%eax
80102b04:	25 ff 00 00 00       	and    $0xff,%eax
80102b09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102b13:	e8 9c ff ff ff       	call   80102ab4 <ioapicread>
80102b18:	c1 e8 18             	shr    $0x18,%eax
80102b1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b1e:	a0 60 4c 11 80       	mov    0x80114c60,%al
80102b23:	0f b6 c0             	movzbl %al,%eax
80102b26:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b29:	74 0c                	je     80102b37 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b2b:	c7 04 24 98 91 10 80 	movl   $0x80109198,(%esp)
80102b32:	e8 8a d8 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b3e:	eb 3d                	jmp    80102b7d <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b43:	83 c0 20             	add    $0x20,%eax
80102b46:	0d 00 00 01 00       	or     $0x10000,%eax
80102b4b:	89 c2                	mov    %eax,%edx
80102b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b50:	83 c0 08             	add    $0x8,%eax
80102b53:	01 c0                	add    %eax,%eax
80102b55:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b59:	89 04 24             	mov    %eax,(%esp)
80102b5c:	e8 6a ff ff ff       	call   80102acb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b64:	83 c0 08             	add    $0x8,%eax
80102b67:	01 c0                	add    %eax,%eax
80102b69:	40                   	inc    %eax
80102b6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b71:	00 
80102b72:	89 04 24             	mov    %eax,(%esp)
80102b75:	e8 51 ff ff ff       	call   80102acb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b7a:	ff 45 f4             	incl   -0xc(%ebp)
80102b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b80:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b83:	7e bb                	jle    80102b40 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b85:	c9                   	leave  
80102b86:	c3                   	ret    

80102b87 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b87:	55                   	push   %ebp
80102b88:	89 e5                	mov    %esp,%ebp
80102b8a:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b90:	83 c0 20             	add    $0x20,%eax
80102b93:	89 c2                	mov    %eax,%edx
80102b95:	8b 45 08             	mov    0x8(%ebp),%eax
80102b98:	83 c0 08             	add    $0x8,%eax
80102b9b:	01 c0                	add    %eax,%eax
80102b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ba1:	89 04 24             	mov    %eax,(%esp)
80102ba4:	e8 22 ff ff ff       	call   80102acb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bac:	c1 e0 18             	shl    $0x18,%eax
80102baf:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb2:	83 c2 08             	add    $0x8,%edx
80102bb5:	01 d2                	add    %edx,%edx
80102bb7:	42                   	inc    %edx
80102bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bbc:	89 14 24             	mov    %edx,(%esp)
80102bbf:	e8 07 ff ff ff       	call   80102acb <ioapicwrite>
}
80102bc4:	c9                   	leave  
80102bc5:	c3                   	ret    
	...

80102bc8 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bc8:	55                   	push   %ebp
80102bc9:	89 e5                	mov    %esp,%ebp
80102bcb:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102bce:	c7 44 24 04 ca 91 10 	movl   $0x801091ca,0x4(%esp)
80102bd5:	80 
80102bd6:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102bdd:	e8 38 25 00 00       	call   8010511a <initlock>
  kmem.use_lock = 0;
80102be2:	c7 05 74 4b 11 80 00 	movl   $0x0,0x80114b74
80102be9:	00 00 00 
  freerange(vstart, vend);
80102bec:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bef:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf6:	89 04 24             	mov    %eax,(%esp)
80102bf9:	e8 26 00 00 00       	call   80102c24 <freerange>
}
80102bfe:	c9                   	leave  
80102bff:	c3                   	ret    

80102c00 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c00:	55                   	push   %ebp
80102c01:	89 e5                	mov    %esp,%ebp
80102c03:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c09:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c10:	89 04 24             	mov    %eax,(%esp)
80102c13:	e8 0c 00 00 00       	call   80102c24 <freerange>
  kmem.use_lock = 1;
80102c18:	c7 05 74 4b 11 80 01 	movl   $0x1,0x80114b74
80102c1f:	00 00 00 
}
80102c22:	c9                   	leave  
80102c23:	c3                   	ret    

80102c24 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c24:	55                   	push   %ebp
80102c25:	89 e5                	mov    %esp,%ebp
80102c27:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c3a:	eb 12                	jmp    80102c4e <freerange+0x2a>
    kfree(p);
80102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3f:	89 04 24             	mov    %eax,(%esp)
80102c42:	e8 16 00 00 00       	call   80102c5d <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c47:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c51:	05 00 10 00 00       	add    $0x1000,%eax
80102c56:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c59:	76 e1                	jbe    80102c3c <freerange+0x18>
    kfree(p);
}
80102c5b:	c9                   	leave  
80102c5c:	c3                   	ret    

80102c5d <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c5d:	55                   	push   %ebp
80102c5e:	89 e5                	mov    %esp,%ebp
80102c60:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c63:	8b 45 08             	mov    0x8(%ebp),%eax
80102c66:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c6b:	85 c0                	test   %eax,%eax
80102c6d:	75 18                	jne    80102c87 <kfree+0x2a>
80102c6f:	81 7d 08 b0 7c 11 80 	cmpl   $0x80117cb0,0x8(%ebp)
80102c76:	72 0f                	jb     80102c87 <kfree+0x2a>
80102c78:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7b:	05 00 00 00 80       	add    $0x80000000,%eax
80102c80:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c85:	76 0c                	jbe    80102c93 <kfree+0x36>
    panic("kfree");
80102c87:	c7 04 24 cf 91 10 80 	movl   $0x801091cf,(%esp)
80102c8e:	e8 c1 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c93:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102c9a:	00 
80102c9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ca2:	00 
80102ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca6:	89 04 24             	mov    %eax,(%esp)
80102ca9:	e8 f0 26 00 00       	call   8010539e <memset>

  if(ticks > 1){
80102cae:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102cb3:	83 f8 01             	cmp    $0x1,%eax
80102cb6:	76 32                	jbe    80102cea <kfree+0x8d>
    int x = find(myproc()->cont->name);
80102cb8:	e8 76 16 00 00       	call   80104333 <myproc>
80102cbd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102cc3:	83 c0 18             	add    $0x18,%eax
80102cc6:	89 04 24             	mov    %eax,(%esp)
80102cc9:	e8 80 5d 00 00       	call   80108a4e <find>
80102cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(x >= 0){
80102cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cd5:	78 13                	js     80102cea <kfree+0x8d>
      reduce_curr_mem(1, x);
80102cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cda:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ce5:	e8 66 60 00 00       	call   80108d50 <reduce_curr_mem>
    }
  }

  if(kmem.use_lock)
80102cea:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102cef:	85 c0                	test   %eax,%eax
80102cf1:	74 0c                	je     80102cff <kfree+0xa2>
    acquire(&kmem.lock);
80102cf3:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102cfa:	e8 3c 24 00 00       	call   8010513b <acquire>
  r = (struct run*)v;
80102cff:	8b 45 08             	mov    0x8(%ebp),%eax
80102d02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102d05:	8b 15 78 4b 11 80    	mov    0x80114b78,%edx
80102d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d0e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d13:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102d18:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d1d:	85 c0                	test   %eax,%eax
80102d1f:	74 0c                	je     80102d2d <kfree+0xd0>
    release(&kmem.lock);
80102d21:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d28:	e8 78 24 00 00       	call   801051a5 <release>
}
80102d2d:	c9                   	leave  
80102d2e:	c3                   	ret    

80102d2f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d2f:	55                   	push   %ebp
80102d30:	89 e5                	mov    %esp,%ebp
80102d32:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  
  if(ticks > 1){
80102d35:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102d3a:	83 f8 01             	cmp    $0x1,%eax
80102d3d:	76 32                	jbe    80102d71 <kalloc+0x42>
    int x = find(myproc()->cont->name);
80102d3f:	e8 ef 15 00 00       	call   80104333 <myproc>
80102d44:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102d4a:	83 c0 18             	add    $0x18,%eax
80102d4d:	89 04 24             	mov    %eax,(%esp)
80102d50:	e8 f9 5c 00 00       	call   80108a4e <find>
80102d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(x >= 0){
80102d58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d5c:	78 13                	js     80102d71 <kalloc+0x42>
      set_curr_mem(1, x);
80102d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d61:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102d6c:	e8 9d 5f 00 00       	call   80108d0e <set_curr_mem>
    }
  }

  if(kmem.use_lock)
80102d71:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d76:	85 c0                	test   %eax,%eax
80102d78:	74 0c                	je     80102d86 <kalloc+0x57>
    acquire(&kmem.lock);
80102d7a:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d81:	e8 b5 23 00 00       	call   8010513b <acquire>
  r = kmem.freelist;
80102d86:	a1 78 4b 11 80       	mov    0x80114b78,%eax
80102d8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(r)
80102d8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d92:	74 0a                	je     80102d9e <kalloc+0x6f>
    kmem.freelist = r->next;
80102d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d97:	8b 00                	mov    (%eax),%eax
80102d99:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102d9e:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102da3:	85 c0                	test   %eax,%eax
80102da5:	74 0c                	je     80102db3 <kalloc+0x84>
    release(&kmem.lock);
80102da7:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102dae:	e8 f2 23 00 00       	call   801051a5 <release>
  return (char*)r;
80102db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80102db6:	c9                   	leave  
80102db7:	c3                   	ret    

80102db8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102db8:	55                   	push   %ebp
80102db9:	89 e5                	mov    %esp,%ebp
80102dbb:	83 ec 14             	sub    $0x14,%esp
80102dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc8:	89 c2                	mov    %eax,%edx
80102dca:	ec                   	in     (%dx),%al
80102dcb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dce:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102dd1:	c9                   	leave  
80102dd2:	c3                   	ret    

80102dd3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102dd3:	55                   	push   %ebp
80102dd4:	89 e5                	mov    %esp,%ebp
80102dd6:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102dd9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102de0:	e8 d3 ff ff ff       	call   80102db8 <inb>
80102de5:	0f b6 c0             	movzbl %al,%eax
80102de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dee:	83 e0 01             	and    $0x1,%eax
80102df1:	85 c0                	test   %eax,%eax
80102df3:	75 0a                	jne    80102dff <kbdgetc+0x2c>
    return -1;
80102df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dfa:	e9 21 01 00 00       	jmp    80102f20 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102dff:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e06:	e8 ad ff ff ff       	call   80102db8 <inb>
80102e0b:	0f b6 c0             	movzbl %al,%eax
80102e0e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e11:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e18:	75 17                	jne    80102e31 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e1a:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e1f:	83 c8 40             	or     $0x40,%eax
80102e22:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102e27:	b8 00 00 00 00       	mov    $0x0,%eax
80102e2c:	e9 ef 00 00 00       	jmp    80102f20 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e34:	25 80 00 00 00       	and    $0x80,%eax
80102e39:	85 c0                	test   %eax,%eax
80102e3b:	74 44                	je     80102e81 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e3d:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e42:	83 e0 40             	and    $0x40,%eax
80102e45:	85 c0                	test   %eax,%eax
80102e47:	75 08                	jne    80102e51 <kbdgetc+0x7e>
80102e49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e4c:	83 e0 7f             	and    $0x7f,%eax
80102e4f:	eb 03                	jmp    80102e54 <kbdgetc+0x81>
80102e51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e54:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e5a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e5f:	8a 00                	mov    (%eax),%al
80102e61:	83 c8 40             	or     $0x40,%eax
80102e64:	0f b6 c0             	movzbl %al,%eax
80102e67:	f7 d0                	not    %eax
80102e69:	89 c2                	mov    %eax,%edx
80102e6b:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e70:	21 d0                	and    %edx,%eax
80102e72:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102e77:	b8 00 00 00 00       	mov    $0x0,%eax
80102e7c:	e9 9f 00 00 00       	jmp    80102f20 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e81:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e86:	83 e0 40             	and    $0x40,%eax
80102e89:	85 c0                	test   %eax,%eax
80102e8b:	74 14                	je     80102ea1 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e8d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e94:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e99:	83 e0 bf             	and    $0xffffffbf,%eax
80102e9c:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  }

  shift |= shiftcode[data];
80102ea1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ea4:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ea9:	8a 00                	mov    (%eax),%al
80102eab:	0f b6 d0             	movzbl %al,%edx
80102eae:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102eb3:	09 d0                	or     %edx,%eax
80102eb5:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  shift ^= togglecode[data];
80102eba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ebd:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102ec2:	8a 00                	mov    (%eax),%al
80102ec4:	0f b6 d0             	movzbl %al,%edx
80102ec7:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ecc:	31 d0                	xor    %edx,%eax
80102ece:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102ed3:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ed8:	83 e0 03             	and    $0x3,%eax
80102edb:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102ee2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ee5:	01 d0                	add    %edx,%eax
80102ee7:	8a 00                	mov    (%eax),%al
80102ee9:	0f b6 c0             	movzbl %al,%eax
80102eec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102eef:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ef4:	83 e0 08             	and    $0x8,%eax
80102ef7:	85 c0                	test   %eax,%eax
80102ef9:	74 22                	je     80102f1d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102efb:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102eff:	76 0c                	jbe    80102f0d <kbdgetc+0x13a>
80102f01:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f05:	77 06                	ja     80102f0d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f07:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f0b:	eb 10                	jmp    80102f1d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f0d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f11:	76 0a                	jbe    80102f1d <kbdgetc+0x14a>
80102f13:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f17:	77 04                	ja     80102f1d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f19:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f20:	c9                   	leave  
80102f21:	c3                   	ret    

80102f22 <kbdintr>:

void
kbdintr(void)
{
80102f22:	55                   	push   %ebp
80102f23:	89 e5                	mov    %esp,%ebp
80102f25:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f28:	c7 04 24 d3 2d 10 80 	movl   $0x80102dd3,(%esp)
80102f2f:	e8 c1 d8 ff ff       	call   801007f5 <consoleintr>
}
80102f34:	c9                   	leave  
80102f35:	c3                   	ret    
	...

80102f38 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f38:	55                   	push   %ebp
80102f39:	89 e5                	mov    %esp,%ebp
80102f3b:	83 ec 14             	sub    $0x14,%esp
80102f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102f41:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f48:	89 c2                	mov    %eax,%edx
80102f4a:	ec                   	in     (%dx),%al
80102f4b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f4e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f51:	c9                   	leave  
80102f52:	c3                   	ret    

80102f53 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f53:	55                   	push   %ebp
80102f54:	89 e5                	mov    %esp,%ebp
80102f56:	83 ec 08             	sub    $0x8,%esp
80102f59:	8b 45 08             	mov    0x8(%ebp),%eax
80102f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f5f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f63:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f66:	8a 45 f8             	mov    -0x8(%ebp),%al
80102f69:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102f6c:	ee                   	out    %al,(%dx)
}
80102f6d:	c9                   	leave  
80102f6e:	c3                   	ret    

80102f6f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f6f:	55                   	push   %ebp
80102f70:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f72:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102f77:	8b 55 08             	mov    0x8(%ebp),%edx
80102f7a:	c1 e2 02             	shl    $0x2,%edx
80102f7d:	01 c2                	add    %eax,%edx
80102f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f82:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f84:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102f89:	83 c0 20             	add    $0x20,%eax
80102f8c:	8b 00                	mov    (%eax),%eax
}
80102f8e:	5d                   	pop    %ebp
80102f8f:	c3                   	ret    

80102f90 <lapicinit>:

void
lapicinit(void)
{
80102f90:	55                   	push   %ebp
80102f91:	89 e5                	mov    %esp,%ebp
80102f93:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102f96:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102f9b:	85 c0                	test   %eax,%eax
80102f9d:	75 05                	jne    80102fa4 <lapicinit+0x14>
    return;
80102f9f:	e9 43 01 00 00       	jmp    801030e7 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fa4:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102fab:	00 
80102fac:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102fb3:	e8 b7 ff ff ff       	call   80102f6f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102fb8:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102fbf:	00 
80102fc0:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102fc7:	e8 a3 ff ff ff       	call   80102f6f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102fcc:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102fd3:	00 
80102fd4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fdb:	e8 8f ff ff ff       	call   80102f6f <lapicw>
  lapicw(TICR, 10000000);
80102fe0:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102fe7:	00 
80102fe8:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102fef:	e8 7b ff ff ff       	call   80102f6f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ff4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ffb:	00 
80102ffc:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103003:	e8 67 ff ff ff       	call   80102f6f <lapicw>
  lapicw(LINT1, MASKED);
80103008:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010300f:	00 
80103010:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103017:	e8 53 ff ff ff       	call   80102f6f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010301c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103021:	83 c0 30             	add    $0x30,%eax
80103024:	8b 00                	mov    (%eax),%eax
80103026:	c1 e8 10             	shr    $0x10,%eax
80103029:	0f b6 c0             	movzbl %al,%eax
8010302c:	83 f8 03             	cmp    $0x3,%eax
8010302f:	76 14                	jbe    80103045 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103031:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103038:	00 
80103039:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103040:	e8 2a ff ff ff       	call   80102f6f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103045:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010304c:	00 
8010304d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103054:	e8 16 ff ff ff       	call   80102f6f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103060:	00 
80103061:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103068:	e8 02 ff ff ff       	call   80102f6f <lapicw>
  lapicw(ESR, 0);
8010306d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103074:	00 
80103075:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010307c:	e8 ee fe ff ff       	call   80102f6f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103081:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103088:	00 
80103089:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103090:	e8 da fe ff ff       	call   80102f6f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010309c:	00 
8010309d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030a4:	e8 c6 fe ff ff       	call   80102f6f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030a9:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801030b0:	00 
801030b1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030b8:	e8 b2 fe ff ff       	call   80102f6f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801030bd:	90                   	nop
801030be:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030c3:	05 00 03 00 00       	add    $0x300,%eax
801030c8:	8b 00                	mov    (%eax),%eax
801030ca:	25 00 10 00 00       	and    $0x1000,%eax
801030cf:	85 c0                	test   %eax,%eax
801030d1:	75 eb                	jne    801030be <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030da:	00 
801030db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801030e2:	e8 88 fe ff ff       	call   80102f6f <lapicw>
}
801030e7:	c9                   	leave  
801030e8:	c3                   	ret    

801030e9 <lapicid>:

int
lapicid(void)
{
801030e9:	55                   	push   %ebp
801030ea:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801030ec:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030f1:	85 c0                	test   %eax,%eax
801030f3:	75 07                	jne    801030fc <lapicid+0x13>
    return 0;
801030f5:	b8 00 00 00 00       	mov    $0x0,%eax
801030fa:	eb 0d                	jmp    80103109 <lapicid+0x20>
  return lapic[ID] >> 24;
801030fc:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103101:	83 c0 20             	add    $0x20,%eax
80103104:	8b 00                	mov    (%eax),%eax
80103106:	c1 e8 18             	shr    $0x18,%eax
}
80103109:	5d                   	pop    %ebp
8010310a:	c3                   	ret    

8010310b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010310b:	55                   	push   %ebp
8010310c:	89 e5                	mov    %esp,%ebp
8010310e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103111:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103116:	85 c0                	test   %eax,%eax
80103118:	74 14                	je     8010312e <lapiceoi+0x23>
    lapicw(EOI, 0);
8010311a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103121:	00 
80103122:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103129:	e8 41 fe ff ff       	call   80102f6f <lapicw>
}
8010312e:	c9                   	leave  
8010312f:	c3                   	ret    

80103130 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103130:	55                   	push   %ebp
80103131:	89 e5                	mov    %esp,%ebp
}
80103133:	5d                   	pop    %ebp
80103134:	c3                   	ret    

80103135 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
80103138:	83 ec 1c             	sub    $0x1c,%esp
8010313b:	8b 45 08             	mov    0x8(%ebp),%eax
8010313e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103141:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103148:	00 
80103149:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103150:	e8 fe fd ff ff       	call   80102f53 <outb>
  outb(CMOS_PORT+1, 0x0A);
80103155:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010315c:	00 
8010315d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103164:	e8 ea fd ff ff       	call   80102f53 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103169:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103170:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103173:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103178:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010317b:	8d 50 02             	lea    0x2(%eax),%edx
8010317e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103181:	c1 e8 04             	shr    $0x4,%eax
80103184:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103187:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010318b:	c1 e0 18             	shl    $0x18,%eax
8010318e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103192:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103199:	e8 d1 fd ff ff       	call   80102f6f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010319e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801031a5:	00 
801031a6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031ad:	e8 bd fd ff ff       	call   80102f6f <lapicw>
  microdelay(200);
801031b2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031b9:	e8 72 ff ff ff       	call   80103130 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801031be:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801031c5:	00 
801031c6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031cd:	e8 9d fd ff ff       	call   80102f6f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031d2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801031d9:	e8 52 ff ff ff       	call   80103130 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031e5:	eb 3f                	jmp    80103226 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801031e7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031eb:	c1 e0 18             	shl    $0x18,%eax
801031ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801031f2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031f9:	e8 71 fd ff ff       	call   80102f6f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801031fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103201:	c1 e8 0c             	shr    $0xc,%eax
80103204:	80 cc 06             	or     $0x6,%ah
80103207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010320b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103212:	e8 58 fd ff ff       	call   80102f6f <lapicw>
    microdelay(200);
80103217:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010321e:	e8 0d ff ff ff       	call   80103130 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103223:	ff 45 fc             	incl   -0x4(%ebp)
80103226:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010322a:	7e bb                	jle    801031e7 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010322c:	c9                   	leave  
8010322d:	c3                   	ret    

8010322e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010322e:	55                   	push   %ebp
8010322f:	89 e5                	mov    %esp,%ebp
80103231:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103234:	8b 45 08             	mov    0x8(%ebp),%eax
80103237:	0f b6 c0             	movzbl %al,%eax
8010323a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010323e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103245:	e8 09 fd ff ff       	call   80102f53 <outb>
  microdelay(200);
8010324a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103251:	e8 da fe ff ff       	call   80103130 <microdelay>

  return inb(CMOS_RETURN);
80103256:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010325d:	e8 d6 fc ff ff       	call   80102f38 <inb>
80103262:	0f b6 c0             	movzbl %al,%eax
}
80103265:	c9                   	leave  
80103266:	c3                   	ret    

80103267 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103267:	55                   	push   %ebp
80103268:	89 e5                	mov    %esp,%ebp
8010326a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010326d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103274:	e8 b5 ff ff ff       	call   8010322e <cmos_read>
80103279:	8b 55 08             	mov    0x8(%ebp),%edx
8010327c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010327e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103285:	e8 a4 ff ff ff       	call   8010322e <cmos_read>
8010328a:	8b 55 08             	mov    0x8(%ebp),%edx
8010328d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103290:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103297:	e8 92 ff ff ff       	call   8010322e <cmos_read>
8010329c:	8b 55 08             	mov    0x8(%ebp),%edx
8010329f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801032a2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801032a9:	e8 80 ff ff ff       	call   8010322e <cmos_read>
801032ae:	8b 55 08             	mov    0x8(%ebp),%edx
801032b1:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801032b4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801032bb:	e8 6e ff ff ff       	call   8010322e <cmos_read>
801032c0:	8b 55 08             	mov    0x8(%ebp),%edx
801032c3:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032c6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801032cd:	e8 5c ff ff ff       	call   8010322e <cmos_read>
801032d2:	8b 55 08             	mov    0x8(%ebp),%edx
801032d5:	89 42 14             	mov    %eax,0x14(%edx)
}
801032d8:	c9                   	leave  
801032d9:	c3                   	ret    

801032da <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032da:	55                   	push   %ebp
801032db:	89 e5                	mov    %esp,%ebp
801032dd:	57                   	push   %edi
801032de:	56                   	push   %esi
801032df:	53                   	push   %ebx
801032e0:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032e3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801032ea:	e8 3f ff ff ff       	call   8010322e <cmos_read>
801032ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032f5:	83 e0 04             	and    $0x4,%eax
801032f8:	85 c0                	test   %eax,%eax
801032fa:	0f 94 c0             	sete   %al
801032fd:	0f b6 c0             	movzbl %al,%eax
80103300:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103303:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103306:	89 04 24             	mov    %eax,(%esp)
80103309:	e8 59 ff ff ff       	call   80103267 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010330e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103315:	e8 14 ff ff ff       	call   8010322e <cmos_read>
8010331a:	25 80 00 00 00       	and    $0x80,%eax
8010331f:	85 c0                	test   %eax,%eax
80103321:	74 02                	je     80103325 <cmostime+0x4b>
        continue;
80103323:	eb 36                	jmp    8010335b <cmostime+0x81>
    fill_rtcdate(&t2);
80103325:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103328:	89 04 24             	mov    %eax,(%esp)
8010332b:	e8 37 ff ff ff       	call   80103267 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103330:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103337:	00 
80103338:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010333b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010333f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103342:	89 04 24             	mov    %eax,(%esp)
80103345:	e8 cb 20 00 00       	call   80105415 <memcmp>
8010334a:	85 c0                	test   %eax,%eax
8010334c:	75 0d                	jne    8010335b <cmostime+0x81>
      break;
8010334e:	90                   	nop
  }

  // convert
  if(bcd) {
8010334f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103353:	0f 84 ac 00 00 00    	je     80103405 <cmostime+0x12b>
80103359:	eb 02                	jmp    8010335d <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010335b:	eb a6                	jmp    80103303 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010335d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103360:	c1 e8 04             	shr    $0x4,%eax
80103363:	89 c2                	mov    %eax,%edx
80103365:	89 d0                	mov    %edx,%eax
80103367:	c1 e0 02             	shl    $0x2,%eax
8010336a:	01 d0                	add    %edx,%eax
8010336c:	01 c0                	add    %eax,%eax
8010336e:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103371:	83 e2 0f             	and    $0xf,%edx
80103374:	01 d0                	add    %edx,%eax
80103376:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103379:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010337c:	c1 e8 04             	shr    $0x4,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	89 d0                	mov    %edx,%eax
80103383:	c1 e0 02             	shl    $0x2,%eax
80103386:	01 d0                	add    %edx,%eax
80103388:	01 c0                	add    %eax,%eax
8010338a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010338d:	83 e2 0f             	and    $0xf,%edx
80103390:	01 d0                	add    %edx,%eax
80103392:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103395:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103398:	c1 e8 04             	shr    $0x4,%eax
8010339b:	89 c2                	mov    %eax,%edx
8010339d:	89 d0                	mov    %edx,%eax
8010339f:	c1 e0 02             	shl    $0x2,%eax
801033a2:	01 d0                	add    %edx,%eax
801033a4:	01 c0                	add    %eax,%eax
801033a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
801033a9:	83 e2 0f             	and    $0xf,%edx
801033ac:	01 d0                	add    %edx,%eax
801033ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801033b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801033b4:	c1 e8 04             	shr    $0x4,%eax
801033b7:	89 c2                	mov    %eax,%edx
801033b9:	89 d0                	mov    %edx,%eax
801033bb:	c1 e0 02             	shl    $0x2,%eax
801033be:	01 d0                	add    %edx,%eax
801033c0:	01 c0                	add    %eax,%eax
801033c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801033c5:	83 e2 0f             	and    $0xf,%edx
801033c8:	01 d0                	add    %edx,%eax
801033ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801033cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033d0:	c1 e8 04             	shr    $0x4,%eax
801033d3:	89 c2                	mov    %eax,%edx
801033d5:	89 d0                	mov    %edx,%eax
801033d7:	c1 e0 02             	shl    $0x2,%eax
801033da:	01 d0                	add    %edx,%eax
801033dc:	01 c0                	add    %eax,%eax
801033de:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033e1:	83 e2 0f             	and    $0xf,%edx
801033e4:	01 d0                	add    %edx,%eax
801033e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801033e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033ec:	c1 e8 04             	shr    $0x4,%eax
801033ef:	89 c2                	mov    %eax,%edx
801033f1:	89 d0                	mov    %edx,%eax
801033f3:	c1 e0 02             	shl    $0x2,%eax
801033f6:	01 d0                	add    %edx,%eax
801033f8:	01 c0                	add    %eax,%eax
801033fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033fd:	83 e2 0f             	and    $0xf,%edx
80103400:	01 d0                	add    %edx,%eax
80103402:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103405:	8b 45 08             	mov    0x8(%ebp),%eax
80103408:	89 c2                	mov    %eax,%edx
8010340a:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010340d:	b8 06 00 00 00       	mov    $0x6,%eax
80103412:	89 d7                	mov    %edx,%edi
80103414:	89 de                	mov    %ebx,%esi
80103416:	89 c1                	mov    %eax,%ecx
80103418:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010341a:	8b 45 08             	mov    0x8(%ebp),%eax
8010341d:	8b 40 14             	mov    0x14(%eax),%eax
80103420:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103426:	8b 45 08             	mov    0x8(%ebp),%eax
80103429:	89 50 14             	mov    %edx,0x14(%eax)
}
8010342c:	83 c4 5c             	add    $0x5c,%esp
8010342f:	5b                   	pop    %ebx
80103430:	5e                   	pop    %esi
80103431:	5f                   	pop    %edi
80103432:	5d                   	pop    %ebp
80103433:	c3                   	ret    

80103434 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103434:	55                   	push   %ebp
80103435:	89 e5                	mov    %esp,%ebp
80103437:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010343a:	c7 44 24 04 d5 91 10 	movl   $0x801091d5,0x4(%esp)
80103441:	80 
80103442:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103449:	e8 cc 1c 00 00       	call   8010511a <initlock>
  readsb(dev, &sb);
8010344e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103451:	89 44 24 04          	mov    %eax,0x4(%esp)
80103455:	8b 45 08             	mov    0x8(%ebp),%eax
80103458:	89 04 24             	mov    %eax,(%esp)
8010345b:	e8 60 e0 ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
80103460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103463:	a3 b4 4b 11 80       	mov    %eax,0x80114bb4
  log.size = sb.nlog;
80103468:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010346b:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
  log.dev = dev;
80103470:	8b 45 08             	mov    0x8(%ebp),%eax
80103473:	a3 c4 4b 11 80       	mov    %eax,0x80114bc4
  recover_from_log();
80103478:	e8 95 01 00 00       	call   80103612 <recover_from_log>
}
8010347d:	c9                   	leave  
8010347e:	c3                   	ret    

8010347f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010347f:	55                   	push   %ebp
80103480:	89 e5                	mov    %esp,%ebp
80103482:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103485:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010348c:	e9 89 00 00 00       	jmp    8010351a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103491:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
80103497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010349a:	01 d0                	add    %edx,%eax
8010349c:	40                   	inc    %eax
8010349d:	89 c2                	mov    %eax,%edx
8010349f:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801034a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801034a8:	89 04 24             	mov    %eax,(%esp)
801034ab:	e8 05 cd ff ff       	call   801001b5 <bread>
801034b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b6:	83 c0 10             	add    $0x10,%eax
801034b9:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
801034c0:	89 c2                	mov    %eax,%edx
801034c2:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801034c7:	89 54 24 04          	mov    %edx,0x4(%esp)
801034cb:	89 04 24             	mov    %eax,(%esp)
801034ce:	e8 e2 cc ff ff       	call   801001b5 <bread>
801034d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d9:	8d 50 5c             	lea    0x5c(%eax),%edx
801034dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034df:	83 c0 5c             	add    $0x5c,%eax
801034e2:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801034e9:	00 
801034ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ee:	89 04 24             	mov    %eax,(%esp)
801034f1:	e8 71 1f 00 00       	call   80105467 <memmove>
    bwrite(dbuf);  // write dst to disk
801034f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f9:	89 04 24             	mov    %eax,(%esp)
801034fc:	e8 eb cc ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103501:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103504:	89 04 24             	mov    %eax,(%esp)
80103507:	e8 20 cd ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010350c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010350f:	89 04 24             	mov    %eax,(%esp)
80103512:	e8 15 cd ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103517:	ff 45 f4             	incl   -0xc(%ebp)
8010351a:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010351f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103522:	0f 8f 69 ff ff ff    	jg     80103491 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103528:	c9                   	leave  
80103529:	c3                   	ret    

8010352a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010352a:	55                   	push   %ebp
8010352b:	89 e5                	mov    %esp,%ebp
8010352d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103530:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
80103535:	89 c2                	mov    %eax,%edx
80103537:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
8010353c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103540:	89 04 24             	mov    %eax,(%esp)
80103543:	e8 6d cc ff ff       	call   801001b5 <bread>
80103548:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010354b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010354e:	83 c0 5c             	add    $0x5c,%eax
80103551:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103554:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103557:	8b 00                	mov    (%eax),%eax
80103559:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  for (i = 0; i < log.lh.n; i++) {
8010355e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103565:	eb 1a                	jmp    80103581 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103567:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010356a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010356d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103574:	83 c2 10             	add    $0x10,%edx
80103577:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010357e:	ff 45 f4             	incl   -0xc(%ebp)
80103581:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103586:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103589:	7f dc                	jg     80103567 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010358b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010358e:	89 04 24             	mov    %eax,(%esp)
80103591:	e8 96 cc ff ff       	call   8010022c <brelse>
}
80103596:	c9                   	leave  
80103597:	c3                   	ret    

80103598 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103598:	55                   	push   %ebp
80103599:	89 e5                	mov    %esp,%ebp
8010359b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010359e:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
801035a3:	89 c2                	mov    %eax,%edx
801035a5:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801035aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801035ae:	89 04 24             	mov    %eax,(%esp)
801035b1:	e8 ff cb ff ff       	call   801001b5 <bread>
801035b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035bc:	83 c0 5c             	add    $0x5c,%eax
801035bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035c2:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
801035c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035cb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035d4:	eb 1a                	jmp    801035f0 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801035d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d9:	83 c0 10             	add    $0x10,%eax
801035dc:	8b 0c 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%ecx
801035e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035e9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035ed:	ff 45 f4             	incl   -0xc(%ebp)
801035f0:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801035f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035f8:	7f dc                	jg     801035d6 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fd:	89 04 24             	mov    %eax,(%esp)
80103600:	e8 e7 cb ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103605:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103608:	89 04 24             	mov    %eax,(%esp)
8010360b:	e8 1c cc ff ff       	call   8010022c <brelse>
}
80103610:	c9                   	leave  
80103611:	c3                   	ret    

80103612 <recover_from_log>:

static void
recover_from_log(void)
{
80103612:	55                   	push   %ebp
80103613:	89 e5                	mov    %esp,%ebp
80103615:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103618:	e8 0d ff ff ff       	call   8010352a <read_head>
  install_trans(); // if committed, copy from log to disk
8010361d:	e8 5d fe ff ff       	call   8010347f <install_trans>
  log.lh.n = 0;
80103622:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103629:	00 00 00 
  write_head(); // clear the log
8010362c:	e8 67 ff ff ff       	call   80103598 <write_head>
}
80103631:	c9                   	leave  
80103632:	c3                   	ret    

80103633 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103633:	55                   	push   %ebp
80103634:	89 e5                	mov    %esp,%ebp
80103636:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103639:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103640:	e8 f6 1a 00 00       	call   8010513b <acquire>
  while(1){
    if(log.committing){
80103645:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
8010364a:	85 c0                	test   %eax,%eax
8010364c:	74 16                	je     80103664 <begin_op+0x31>
      sleep(&log, &log.lock);
8010364e:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
80103655:	80 
80103656:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010365d:	e8 4a 15 00 00       	call   80104bac <sleep>
80103662:	eb 4d                	jmp    801036b1 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103664:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
8010366a:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
8010366f:	8d 48 01             	lea    0x1(%eax),%ecx
80103672:	89 c8                	mov    %ecx,%eax
80103674:	c1 e0 02             	shl    $0x2,%eax
80103677:	01 c8                	add    %ecx,%eax
80103679:	01 c0                	add    %eax,%eax
8010367b:	01 d0                	add    %edx,%eax
8010367d:	83 f8 1e             	cmp    $0x1e,%eax
80103680:	7e 16                	jle    80103698 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103682:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
80103689:	80 
8010368a:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103691:	e8 16 15 00 00       	call   80104bac <sleep>
80103696:	eb 19                	jmp    801036b1 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103698:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
8010369d:	40                   	inc    %eax
8010369e:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
      release(&log.lock);
801036a3:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036aa:	e8 f6 1a 00 00       	call   801051a5 <release>
      break;
801036af:	eb 02                	jmp    801036b3 <begin_op+0x80>
    }
  }
801036b1:	eb 92                	jmp    80103645 <begin_op+0x12>
}
801036b3:	c9                   	leave  
801036b4:	c3                   	ret    

801036b5 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036b5:	55                   	push   %ebp
801036b6:	89 e5                	mov    %esp,%ebp
801036b8:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801036bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801036c2:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036c9:	e8 6d 1a 00 00       	call   8010513b <acquire>
  log.outstanding -= 1;
801036ce:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036d3:	48                   	dec    %eax
801036d4:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
  if(log.committing)
801036d9:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
801036de:	85 c0                	test   %eax,%eax
801036e0:	74 0c                	je     801036ee <end_op+0x39>
    panic("log.committing");
801036e2:	c7 04 24 d9 91 10 80 	movl   $0x801091d9,(%esp)
801036e9:	e8 66 ce ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801036ee:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036f3:	85 c0                	test   %eax,%eax
801036f5:	75 13                	jne    8010370a <end_op+0x55>
    do_commit = 1;
801036f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036fe:	c7 05 c0 4b 11 80 01 	movl   $0x1,0x80114bc0
80103705:	00 00 00 
80103708:	eb 0c                	jmp    80103716 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010370a:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103711:	e8 6d 15 00 00       	call   80104c83 <wakeup>
  }
  release(&log.lock);
80103716:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010371d:	e8 83 1a 00 00       	call   801051a5 <release>

  if(do_commit){
80103722:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103726:	74 33                	je     8010375b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103728:	e8 db 00 00 00       	call   80103808 <commit>
    acquire(&log.lock);
8010372d:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103734:	e8 02 1a 00 00       	call   8010513b <acquire>
    log.committing = 0;
80103739:	c7 05 c0 4b 11 80 00 	movl   $0x0,0x80114bc0
80103740:	00 00 00 
    wakeup(&log);
80103743:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010374a:	e8 34 15 00 00       	call   80104c83 <wakeup>
    release(&log.lock);
8010374f:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103756:	e8 4a 1a 00 00       	call   801051a5 <release>
  }
}
8010375b:	c9                   	leave  
8010375c:	c3                   	ret    

8010375d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010375d:	55                   	push   %ebp
8010375e:	89 e5                	mov    %esp,%ebp
80103760:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103763:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010376a:	e9 89 00 00 00       	jmp    801037f8 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010376f:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
80103775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103778:	01 d0                	add    %edx,%eax
8010377a:	40                   	inc    %eax
8010377b:	89 c2                	mov    %eax,%edx
8010377d:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103782:	89 54 24 04          	mov    %edx,0x4(%esp)
80103786:	89 04 24             	mov    %eax,(%esp)
80103789:	e8 27 ca ff ff       	call   801001b5 <bread>
8010378e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103794:	83 c0 10             	add    $0x10,%eax
80103797:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010379e:	89 c2                	mov    %eax,%edx
801037a0:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801037a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801037a9:	89 04 24             	mov    %eax,(%esp)
801037ac:	e8 04 ca ff ff       	call   801001b5 <bread>
801037b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801037b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037b7:	8d 50 5c             	lea    0x5c(%eax),%edx
801037ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037bd:	83 c0 5c             	add    $0x5c,%eax
801037c0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801037c7:	00 
801037c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801037cc:	89 04 24             	mov    %eax,(%esp)
801037cf:	e8 93 1c 00 00       	call   80105467 <memmove>
    bwrite(to);  // write the log
801037d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d7:	89 04 24             	mov    %eax,(%esp)
801037da:	e8 0d ca ff ff       	call   801001ec <bwrite>
    brelse(from);
801037df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037e2:	89 04 24             	mov    %eax,(%esp)
801037e5:	e8 42 ca ff ff       	call   8010022c <brelse>
    brelse(to);
801037ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ed:	89 04 24             	mov    %eax,(%esp)
801037f0:	e8 37 ca ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037f5:	ff 45 f4             	incl   -0xc(%ebp)
801037f8:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801037fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103800:	0f 8f 69 ff ff ff    	jg     8010376f <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103806:	c9                   	leave  
80103807:	c3                   	ret    

80103808 <commit>:

static void
commit()
{
80103808:	55                   	push   %ebp
80103809:	89 e5                	mov    %esp,%ebp
8010380b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010380e:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103813:	85 c0                	test   %eax,%eax
80103815:	7e 1e                	jle    80103835 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103817:	e8 41 ff ff ff       	call   8010375d <write_log>
    write_head();    // Write header to disk -- the real commit
8010381c:	e8 77 fd ff ff       	call   80103598 <write_head>
    install_trans(); // Now install writes to home locations
80103821:	e8 59 fc ff ff       	call   8010347f <install_trans>
    log.lh.n = 0;
80103826:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
8010382d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103830:	e8 63 fd ff ff       	call   80103598 <write_head>
  }
}
80103835:	c9                   	leave  
80103836:	c3                   	ret    

80103837 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103837:	55                   	push   %ebp
80103838:	89 e5                	mov    %esp,%ebp
8010383a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010383d:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103842:	83 f8 1d             	cmp    $0x1d,%eax
80103845:	7f 10                	jg     80103857 <log_write+0x20>
80103847:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010384c:	8b 15 b8 4b 11 80    	mov    0x80114bb8,%edx
80103852:	4a                   	dec    %edx
80103853:	39 d0                	cmp    %edx,%eax
80103855:	7c 0c                	jl     80103863 <log_write+0x2c>
    panic("too big a transaction");
80103857:	c7 04 24 e8 91 10 80 	movl   $0x801091e8,(%esp)
8010385e:	e8 f1 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103863:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103868:	85 c0                	test   %eax,%eax
8010386a:	7f 0c                	jg     80103878 <log_write+0x41>
    panic("log_write outside of trans");
8010386c:	c7 04 24 fe 91 10 80 	movl   $0x801091fe,(%esp)
80103873:	e8 dc cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103878:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010387f:	e8 b7 18 00 00       	call   8010513b <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103884:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010388b:	eb 1e                	jmp    801038ab <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010388d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103890:	83 c0 10             	add    $0x10,%eax
80103893:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010389a:	89 c2                	mov    %eax,%edx
8010389c:	8b 45 08             	mov    0x8(%ebp),%eax
8010389f:	8b 40 08             	mov    0x8(%eax),%eax
801038a2:	39 c2                	cmp    %eax,%edx
801038a4:	75 02                	jne    801038a8 <log_write+0x71>
      break;
801038a6:	eb 0d                	jmp    801038b5 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801038a8:	ff 45 f4             	incl   -0xc(%ebp)
801038ab:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038b3:	7f d8                	jg     8010388d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801038b5:	8b 45 08             	mov    0x8(%ebp),%eax
801038b8:	8b 40 08             	mov    0x8(%eax),%eax
801038bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038be:	83 c2 10             	add    $0x10,%edx
801038c1:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
  if (i == log.lh.n)
801038c8:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038d0:	75 0b                	jne    801038dd <log_write+0xa6>
    log.lh.n++;
801038d2:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038d7:	40                   	inc    %eax
801038d8:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  b->flags |= B_DIRTY; // prevent eviction
801038dd:	8b 45 08             	mov    0x8(%ebp),%eax
801038e0:	8b 00                	mov    (%eax),%eax
801038e2:	83 c8 04             	or     $0x4,%eax
801038e5:	89 c2                	mov    %eax,%edx
801038e7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ea:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038ec:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801038f3:	e8 ad 18 00 00       	call   801051a5 <release>
}
801038f8:	c9                   	leave  
801038f9:	c3                   	ret    
	...

801038fc <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038fc:	55                   	push   %ebp
801038fd:	89 e5                	mov    %esp,%ebp
801038ff:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103902:	8b 55 08             	mov    0x8(%ebp),%edx
80103905:	8b 45 0c             	mov    0xc(%ebp),%eax
80103908:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010390b:	f0 87 02             	lock xchg %eax,(%edx)
8010390e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103911:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103914:	c9                   	leave  
80103915:	c3                   	ret    

80103916 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103916:	55                   	push   %ebp
80103917:	89 e5                	mov    %esp,%ebp
80103919:	83 e4 f0             	and    $0xfffffff0,%esp
8010391c:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010391f:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103926:	80 
80103927:	c7 04 24 b0 7c 11 80 	movl   $0x80117cb0,(%esp)
8010392e:	e8 95 f2 ff ff       	call   80102bc8 <kinit1>
  kvmalloc();      // kernel page table
80103933:	e8 c7 47 00 00       	call   801080ff <kvmalloc>
  mpinit();        // detect other processors
80103938:	e8 cc 03 00 00       	call   80103d09 <mpinit>
  lapicinit();     // interrupt controller
8010393d:	e8 4e f6 ff ff       	call   80102f90 <lapicinit>
  seginit();       // segment descriptors
80103942:	e8 a0 42 00 00       	call   80107be7 <seginit>
  picinit();       // disable pic
80103947:	e8 0c 05 00 00       	call   80103e58 <picinit>
  ioapicinit();    // another interrupt controller
8010394c:	e8 94 f1 ff ff       	call   80102ae5 <ioapicinit>
  consoleinit();   // console hardware
80103951:	e8 99 d2 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103956:	e8 18 36 00 00       	call   80106f73 <uartinit>
  pinit();         // process table
8010395b:	e8 ee 08 00 00       	call   8010424e <pinit>
  tvinit();        // trap vectors
80103960:	e8 db 31 00 00       	call   80106b40 <tvinit>
  binit();         // buffer cache
80103965:	e8 ca c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010396a:	e8 77 d7 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
8010396f:	e8 7d ed ff ff       	call   801026f1 <ideinit>
  startothers();   // start other processors
80103974:	e8 88 00 00 00       	call   80103a01 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103979:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103980:	8e 
80103981:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103988:	e8 73 f2 ff ff       	call   80102c00 <kinit2>
  userinit();      // first user process
8010398d:	e8 e6 0a 00 00       	call   80104478 <userinit>
  container_init();
80103992:	e8 65 54 00 00       	call   80108dfc <container_init>
  mpmain();        // finish this processor's setup
80103997:	e8 1a 00 00 00       	call   801039b6 <mpmain>

8010399c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010399c:	55                   	push   %ebp
8010399d:	89 e5                	mov    %esp,%ebp
8010399f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801039a2:	e8 6f 47 00 00       	call   80108116 <switchkvm>
  seginit();
801039a7:	e8 3b 42 00 00       	call   80107be7 <seginit>
  lapicinit();
801039ac:	e8 df f5 ff ff       	call   80102f90 <lapicinit>
  mpmain();
801039b1:	e8 00 00 00 00       	call   801039b6 <mpmain>

801039b6 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039b6:	55                   	push   %ebp
801039b7:	89 e5                	mov    %esp,%ebp
801039b9:	53                   	push   %ebx
801039ba:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801039bd:	e8 a8 08 00 00       	call   8010426a <cpuid>
801039c2:	89 c3                	mov    %eax,%ebx
801039c4:	e8 a1 08 00 00       	call   8010426a <cpuid>
801039c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801039cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801039d1:	c7 04 24 19 92 10 80 	movl   $0x80109219,(%esp)
801039d8:	e8 e4 c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801039dd:	e8 bb 32 00 00       	call   80106c9d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039e2:	e8 c8 08 00 00       	call   801042af <mycpu>
801039e7:	05 a0 00 00 00       	add    $0xa0,%eax
801039ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801039f3:	00 
801039f4:	89 04 24             	mov    %eax,(%esp)
801039f7:	e8 00 ff ff ff       	call   801038fc <xchg>
  scheduler();     // start running processes
801039fc:	e8 de 0f 00 00       	call   801049df <scheduler>

80103a01 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a01:	55                   	push   %ebp
80103a02:	89 e5                	mov    %esp,%ebp
80103a04:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103a07:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a0e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a13:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a17:	c7 44 24 04 6c c5 10 	movl   $0x8010c56c,0x4(%esp)
80103a1e:	80 
80103a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a22:	89 04 24             	mov    %eax,(%esp)
80103a25:	e8 3d 1a 00 00       	call   80105467 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a2a:	c7 45 f4 80 4c 11 80 	movl   $0x80114c80,-0xc(%ebp)
80103a31:	eb 75                	jmp    80103aa8 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103a33:	e8 77 08 00 00       	call   801042af <mycpu>
80103a38:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a3b:	75 02                	jne    80103a3f <startothers+0x3e>
      continue;
80103a3d:	eb 62                	jmp    80103aa1 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a3f:	e8 eb f2 ff ff       	call   80102d2f <kalloc>
80103a44:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a4a:	83 e8 04             	sub    $0x4,%eax
80103a4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a50:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a56:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a5b:	83 e8 08             	sub    $0x8,%eax
80103a5e:	c7 00 9c 39 10 80    	movl   $0x8010399c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a67:	8d 50 f4             	lea    -0xc(%eax),%edx
80103a6a:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103a6f:	05 00 00 00 80       	add    $0x80000000,%eax
80103a74:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a79:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a82:	8a 00                	mov    (%eax),%al
80103a84:	0f b6 c0             	movzbl %al,%eax
80103a87:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a8b:	89 04 24             	mov    %eax,(%esp)
80103a8e:	e8 a2 f6 ff ff       	call   80103135 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a93:	90                   	nop
80103a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a97:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a9d:	85 c0                	test   %eax,%eax
80103a9f:	74 f3                	je     80103a94 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103aa1:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103aa8:	a1 00 52 11 80       	mov    0x80115200,%eax
80103aad:	89 c2                	mov    %eax,%edx
80103aaf:	89 d0                	mov    %edx,%eax
80103ab1:	c1 e0 02             	shl    $0x2,%eax
80103ab4:	01 d0                	add    %edx,%eax
80103ab6:	01 c0                	add    %eax,%eax
80103ab8:	01 d0                	add    %edx,%eax
80103aba:	c1 e0 04             	shl    $0x4,%eax
80103abd:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103ac2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ac5:	0f 87 68 ff ff ff    	ja     80103a33 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103acb:	c9                   	leave  
80103acc:	c3                   	ret    
80103acd:	00 00                	add    %al,(%eax)
	...

80103ad0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ad0:	55                   	push   %ebp
80103ad1:	89 e5                	mov    %esp,%ebp
80103ad3:	83 ec 14             	sub    $0x14,%esp
80103ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103add:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae0:	89 c2                	mov    %eax,%edx
80103ae2:	ec                   	in     (%dx),%al
80103ae3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ae6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103ae9:	c9                   	leave  
80103aea:	c3                   	ret    

80103aeb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103aeb:	55                   	push   %ebp
80103aec:	89 e5                	mov    %esp,%ebp
80103aee:	83 ec 08             	sub    $0x8,%esp
80103af1:	8b 45 08             	mov    0x8(%ebp),%eax
80103af4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103af7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103afb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103afe:	8a 45 f8             	mov    -0x8(%ebp),%al
80103b01:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b04:	ee                   	out    %al,(%dx)
}
80103b05:	c9                   	leave  
80103b06:	c3                   	ret    

80103b07 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103b07:	55                   	push   %ebp
80103b08:	89 e5                	mov    %esp,%ebp
80103b0a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103b0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b14:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b1b:	eb 13                	jmp    80103b30 <sum+0x29>
    sum += addr[i];
80103b1d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b20:	8b 45 08             	mov    0x8(%ebp),%eax
80103b23:	01 d0                	add    %edx,%eax
80103b25:	8a 00                	mov    (%eax),%al
80103b27:	0f b6 c0             	movzbl %al,%eax
80103b2a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b2d:	ff 45 fc             	incl   -0x4(%ebp)
80103b30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b33:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b36:	7c e5                	jl     80103b1d <sum+0x16>
    sum += addr[i];
  return sum;
80103b38:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b3b:	c9                   	leave  
80103b3c:	c3                   	ret    

80103b3d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b3d:	55                   	push   %ebp
80103b3e:	89 e5                	mov    %esp,%ebp
80103b40:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b43:	8b 45 08             	mov    0x8(%ebp),%eax
80103b46:	05 00 00 00 80       	add    $0x80000000,%eax
80103b4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b54:	01 d0                	add    %edx,%eax
80103b56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b5f:	eb 3f                	jmp    80103ba0 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b61:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b68:	00 
80103b69:	c7 44 24 04 30 92 10 	movl   $0x80109230,0x4(%esp)
80103b70:	80 
80103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b74:	89 04 24             	mov    %eax,(%esp)
80103b77:	e8 99 18 00 00       	call   80105415 <memcmp>
80103b7c:	85 c0                	test   %eax,%eax
80103b7e:	75 1c                	jne    80103b9c <mpsearch1+0x5f>
80103b80:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103b87:	00 
80103b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8b:	89 04 24             	mov    %eax,(%esp)
80103b8e:	e8 74 ff ff ff       	call   80103b07 <sum>
80103b93:	84 c0                	test   %al,%al
80103b95:	75 05                	jne    80103b9c <mpsearch1+0x5f>
      return (struct mp*)p;
80103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9a:	eb 11                	jmp    80103bad <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b9c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ba6:	72 b9                	jb     80103b61 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bad:	c9                   	leave  
80103bae:	c3                   	ret    

80103baf <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103baf:	55                   	push   %ebp
80103bb0:	89 e5                	mov    %esp,%ebp
80103bb2:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bb5:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbf:	83 c0 0f             	add    $0xf,%eax
80103bc2:	8a 00                	mov    (%eax),%al
80103bc4:	0f b6 c0             	movzbl %al,%eax
80103bc7:	c1 e0 08             	shl    $0x8,%eax
80103bca:	89 c2                	mov    %eax,%edx
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	83 c0 0e             	add    $0xe,%eax
80103bd2:	8a 00                	mov    (%eax),%al
80103bd4:	0f b6 c0             	movzbl %al,%eax
80103bd7:	09 d0                	or     %edx,%eax
80103bd9:	c1 e0 04             	shl    $0x4,%eax
80103bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bdf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103be3:	74 21                	je     80103c06 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103be5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103bec:	00 
80103bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf0:	89 04 24             	mov    %eax,(%esp)
80103bf3:	e8 45 ff ff ff       	call   80103b3d <mpsearch1>
80103bf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bff:	74 4e                	je     80103c4f <mpsearch+0xa0>
      return mp;
80103c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c04:	eb 5d                	jmp    80103c63 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c09:	83 c0 14             	add    $0x14,%eax
80103c0c:	8a 00                	mov    (%eax),%al
80103c0e:	0f b6 c0             	movzbl %al,%eax
80103c11:	c1 e0 08             	shl    $0x8,%eax
80103c14:	89 c2                	mov    %eax,%edx
80103c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c19:	83 c0 13             	add    $0x13,%eax
80103c1c:	8a 00                	mov    (%eax),%al
80103c1e:	0f b6 c0             	movzbl %al,%eax
80103c21:	09 d0                	or     %edx,%eax
80103c23:	c1 e0 0a             	shl    $0xa,%eax
80103c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2c:	2d 00 04 00 00       	sub    $0x400,%eax
80103c31:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c38:	00 
80103c39:	89 04 24             	mov    %eax,(%esp)
80103c3c:	e8 fc fe ff ff       	call   80103b3d <mpsearch1>
80103c41:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c48:	74 05                	je     80103c4f <mpsearch+0xa0>
      return mp;
80103c4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c4d:	eb 14                	jmp    80103c63 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c4f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103c56:	00 
80103c57:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103c5e:	e8 da fe ff ff       	call   80103b3d <mpsearch1>
}
80103c63:	c9                   	leave  
80103c64:	c3                   	ret    

80103c65 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c65:	55                   	push   %ebp
80103c66:	89 e5                	mov    %esp,%ebp
80103c68:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c6b:	e8 3f ff ff ff       	call   80103baf <mpsearch>
80103c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c77:	74 0a                	je     80103c83 <mpconfig+0x1e>
80103c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7c:	8b 40 04             	mov    0x4(%eax),%eax
80103c7f:	85 c0                	test   %eax,%eax
80103c81:	75 07                	jne    80103c8a <mpconfig+0x25>
    return 0;
80103c83:	b8 00 00 00 00       	mov    $0x0,%eax
80103c88:	eb 7d                	jmp    80103d07 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8d:	8b 40 04             	mov    0x4(%eax),%eax
80103c90:	05 00 00 00 80       	add    $0x80000000,%eax
80103c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c98:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103c9f:	00 
80103ca0:	c7 44 24 04 35 92 10 	movl   $0x80109235,0x4(%esp)
80103ca7:	80 
80103ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cab:	89 04 24             	mov    %eax,(%esp)
80103cae:	e8 62 17 00 00       	call   80105415 <memcmp>
80103cb3:	85 c0                	test   %eax,%eax
80103cb5:	74 07                	je     80103cbe <mpconfig+0x59>
    return 0;
80103cb7:	b8 00 00 00 00       	mov    $0x0,%eax
80103cbc:	eb 49                	jmp    80103d07 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc1:	8a 40 06             	mov    0x6(%eax),%al
80103cc4:	3c 01                	cmp    $0x1,%al
80103cc6:	74 11                	je     80103cd9 <mpconfig+0x74>
80103cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ccb:	8a 40 06             	mov    0x6(%eax),%al
80103cce:	3c 04                	cmp    $0x4,%al
80103cd0:	74 07                	je     80103cd9 <mpconfig+0x74>
    return 0;
80103cd2:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd7:	eb 2e                	jmp    80103d07 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdc:	8b 40 04             	mov    0x4(%eax),%eax
80103cdf:	0f b7 c0             	movzwl %ax,%eax
80103ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce9:	89 04 24             	mov    %eax,(%esp)
80103cec:	e8 16 fe ff ff       	call   80103b07 <sum>
80103cf1:	84 c0                	test   %al,%al
80103cf3:	74 07                	je     80103cfc <mpconfig+0x97>
    return 0;
80103cf5:	b8 00 00 00 00       	mov    $0x0,%eax
80103cfa:	eb 0b                	jmp    80103d07 <mpconfig+0xa2>
  *pmp = mp;
80103cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d02:	89 10                	mov    %edx,(%eax)
  return conf;
80103d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d07:	c9                   	leave  
80103d08:	c3                   	ret    

80103d09 <mpinit>:

void
mpinit(void)
{
80103d09:	55                   	push   %ebp
80103d0a:	89 e5                	mov    %esp,%ebp
80103d0c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103d0f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103d12:	89 04 24             	mov    %eax,(%esp)
80103d15:	e8 4b ff ff ff       	call   80103c65 <mpconfig>
80103d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d21:	75 0c                	jne    80103d2f <mpinit+0x26>
    panic("Expect to run on an SMP");
80103d23:	c7 04 24 3a 92 10 80 	movl   $0x8010923a,(%esp)
80103d2a:	e8 25 c8 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d2f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d39:	8b 40 24             	mov    0x24(%eax),%eax
80103d3c:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d44:	83 c0 2c             	add    $0x2c,%eax
80103d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d4d:	8b 40 04             	mov    0x4(%eax),%eax
80103d50:	0f b7 d0             	movzwl %ax,%edx
80103d53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d56:	01 d0                	add    %edx,%eax
80103d58:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d5b:	eb 7d                	jmp    80103dda <mpinit+0xd1>
    switch(*p){
80103d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d60:	8a 00                	mov    (%eax),%al
80103d62:	0f b6 c0             	movzbl %al,%eax
80103d65:	83 f8 04             	cmp    $0x4,%eax
80103d68:	77 68                	ja     80103dd2 <mpinit+0xc9>
80103d6a:	8b 04 85 74 92 10 80 	mov    -0x7fef6d8c(,%eax,4),%eax
80103d71:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d79:	a1 00 52 11 80       	mov    0x80115200,%eax
80103d7e:	83 f8 07             	cmp    $0x7,%eax
80103d81:	7f 2c                	jg     80103daf <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d83:	8b 15 00 52 11 80    	mov    0x80115200,%edx
80103d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d8c:	8a 48 01             	mov    0x1(%eax),%cl
80103d8f:	89 d0                	mov    %edx,%eax
80103d91:	c1 e0 02             	shl    $0x2,%eax
80103d94:	01 d0                	add    %edx,%eax
80103d96:	01 c0                	add    %eax,%eax
80103d98:	01 d0                	add    %edx,%eax
80103d9a:	c1 e0 04             	shl    $0x4,%eax
80103d9d:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103da2:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103da4:	a1 00 52 11 80       	mov    0x80115200,%eax
80103da9:	40                   	inc    %eax
80103daa:	a3 00 52 11 80       	mov    %eax,0x80115200
      }
      p += sizeof(struct mpproc);
80103daf:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103db3:	eb 25                	jmp    80103dda <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103dbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dbe:	8a 40 01             	mov    0x1(%eax),%al
80103dc1:	a2 60 4c 11 80       	mov    %al,0x80114c60
      p += sizeof(struct mpioapic);
80103dc6:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103dca:	eb 0e                	jmp    80103dda <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103dcc:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103dd0:	eb 08                	jmp    80103dda <mpinit+0xd1>
    default:
      ismp = 0;
80103dd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103dd9:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103de0:	0f 82 77 ff ff ff    	jb     80103d5d <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103de6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dea:	75 0c                	jne    80103df8 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103dec:	c7 04 24 54 92 10 80 	movl   $0x80109254,(%esp)
80103df3:	e8 5c c7 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103df8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dfb:	8a 40 0c             	mov    0xc(%eax),%al
80103dfe:	84 c0                	test   %al,%al
80103e00:	74 36                	je     80103e38 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e02:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103e09:	00 
80103e0a:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103e11:	e8 d5 fc ff ff       	call   80103aeb <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e16:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e1d:	e8 ae fc ff ff       	call   80103ad0 <inb>
80103e22:	83 c8 01             	or     $0x1,%eax
80103e25:	0f b6 c0             	movzbl %al,%eax
80103e28:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e2c:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e33:	e8 b3 fc ff ff       	call   80103aeb <outb>
  }
}
80103e38:	c9                   	leave  
80103e39:	c3                   	ret    
	...

80103e3c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e3c:	55                   	push   %ebp
80103e3d:	89 e5                	mov    %esp,%ebp
80103e3f:	83 ec 08             	sub    $0x8,%esp
80103e42:	8b 45 08             	mov    0x8(%ebp),%eax
80103e45:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e48:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103e4c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e4f:	8a 45 f8             	mov    -0x8(%ebp),%al
80103e52:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e55:	ee                   	out    %al,(%dx)
}
80103e56:	c9                   	leave  
80103e57:	c3                   	ret    

80103e58 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e58:	55                   	push   %ebp
80103e59:	89 e5                	mov    %esp,%ebp
80103e5b:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e5e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e65:	00 
80103e66:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e6d:	e8 ca ff ff ff       	call   80103e3c <outb>
  outb(IO_PIC2+1, 0xFF);
80103e72:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e79:	00 
80103e7a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e81:	e8 b6 ff ff ff       	call   80103e3c <outb>
}
80103e86:	c9                   	leave  
80103e87:	c3                   	ret    

80103e88 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e88:	55                   	push   %ebp
80103e89:	89 e5                	mov    %esp,%ebp
80103e8b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103e8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e95:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea1:	8b 10                	mov    (%eax),%edx
80103ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ea8:	e8 55 d2 ff ff       	call   80101102 <filealloc>
80103ead:	8b 55 08             	mov    0x8(%ebp),%edx
80103eb0:	89 02                	mov    %eax,(%edx)
80103eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb5:	8b 00                	mov    (%eax),%eax
80103eb7:	85 c0                	test   %eax,%eax
80103eb9:	0f 84 c8 00 00 00    	je     80103f87 <pipealloc+0xff>
80103ebf:	e8 3e d2 ff ff       	call   80101102 <filealloc>
80103ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ec7:	89 02                	mov    %eax,(%edx)
80103ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ecc:	8b 00                	mov    (%eax),%eax
80103ece:	85 c0                	test   %eax,%eax
80103ed0:	0f 84 b1 00 00 00    	je     80103f87 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ed6:	e8 54 ee ff ff       	call   80102d2f <kalloc>
80103edb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ede:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ee2:	75 05                	jne    80103ee9 <pipealloc+0x61>
    goto bad;
80103ee4:	e9 9e 00 00 00       	jmp    80103f87 <pipealloc+0xff>
  p->readopen = 1;
80103ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eec:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ef3:	00 00 00 
  p->writeopen = 1;
80103ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef9:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f00:	00 00 00 
  p->nwrite = 0;
80103f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f06:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f0d:	00 00 00 
  p->nread = 0;
80103f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f13:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f1a:	00 00 00 
  initlock(&p->lock, "pipe");
80103f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f20:	c7 44 24 04 88 92 10 	movl   $0x80109288,0x4(%esp)
80103f27:	80 
80103f28:	89 04 24             	mov    %eax,(%esp)
80103f2b:	e8 ea 11 00 00       	call   8010511a <initlock>
  (*f0)->type = FD_PIPE;
80103f30:	8b 45 08             	mov    0x8(%ebp),%eax
80103f33:	8b 00                	mov    (%eax),%eax
80103f35:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3e:	8b 00                	mov    (%eax),%eax
80103f40:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f44:	8b 45 08             	mov    0x8(%ebp),%eax
80103f47:	8b 00                	mov    (%eax),%eax
80103f49:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f50:	8b 00                	mov    (%eax),%eax
80103f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f55:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f5b:	8b 00                	mov    (%eax),%eax
80103f5d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f63:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f66:	8b 00                	mov    (%eax),%eax
80103f68:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f6f:	8b 00                	mov    (%eax),%eax
80103f71:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f78:	8b 00                	mov    (%eax),%eax
80103f7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f7d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f80:	b8 00 00 00 00       	mov    $0x0,%eax
80103f85:	eb 42                	jmp    80103fc9 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103f87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f8b:	74 0b                	je     80103f98 <pipealloc+0x110>
    kfree((char*)p);
80103f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f90:	89 04 24             	mov    %eax,(%esp)
80103f93:	e8 c5 ec ff ff       	call   80102c5d <kfree>
  if(*f0)
80103f98:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9b:	8b 00                	mov    (%eax),%eax
80103f9d:	85 c0                	test   %eax,%eax
80103f9f:	74 0d                	je     80103fae <pipealloc+0x126>
    fileclose(*f0);
80103fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa4:	8b 00                	mov    (%eax),%eax
80103fa6:	89 04 24             	mov    %eax,(%esp)
80103fa9:	e8 fc d1 ff ff       	call   801011aa <fileclose>
  if(*f1)
80103fae:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb1:	8b 00                	mov    (%eax),%eax
80103fb3:	85 c0                	test   %eax,%eax
80103fb5:	74 0d                	je     80103fc4 <pipealloc+0x13c>
    fileclose(*f1);
80103fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fba:	8b 00                	mov    (%eax),%eax
80103fbc:	89 04 24             	mov    %eax,(%esp)
80103fbf:	e8 e6 d1 ff ff       	call   801011aa <fileclose>
  return -1;
80103fc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fc9:	c9                   	leave  
80103fca:	c3                   	ret    

80103fcb <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fcb:	55                   	push   %ebp
80103fcc:	89 e5                	mov    %esp,%ebp
80103fce:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd4:	89 04 24             	mov    %eax,(%esp)
80103fd7:	e8 5f 11 00 00       	call   8010513b <acquire>
  if(writable){
80103fdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fe0:	74 1f                	je     80104001 <pipeclose+0x36>
    p->writeopen = 0;
80103fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fec:	00 00 00 
    wakeup(&p->nread);
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	05 34 02 00 00       	add    $0x234,%eax
80103ff7:	89 04 24             	mov    %eax,(%esp)
80103ffa:	e8 84 0c 00 00       	call   80104c83 <wakeup>
80103fff:	eb 1d                	jmp    8010401e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104001:	8b 45 08             	mov    0x8(%ebp),%eax
80104004:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010400b:	00 00 00 
    wakeup(&p->nwrite);
8010400e:	8b 45 08             	mov    0x8(%ebp),%eax
80104011:	05 38 02 00 00       	add    $0x238,%eax
80104016:	89 04 24             	mov    %eax,(%esp)
80104019:	e8 65 0c 00 00       	call   80104c83 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010401e:	8b 45 08             	mov    0x8(%ebp),%eax
80104021:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104027:	85 c0                	test   %eax,%eax
80104029:	75 25                	jne    80104050 <pipeclose+0x85>
8010402b:	8b 45 08             	mov    0x8(%ebp),%eax
8010402e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104034:	85 c0                	test   %eax,%eax
80104036:	75 18                	jne    80104050 <pipeclose+0x85>
    release(&p->lock);
80104038:	8b 45 08             	mov    0x8(%ebp),%eax
8010403b:	89 04 24             	mov    %eax,(%esp)
8010403e:	e8 62 11 00 00       	call   801051a5 <release>
    kfree((char*)p);
80104043:	8b 45 08             	mov    0x8(%ebp),%eax
80104046:	89 04 24             	mov    %eax,(%esp)
80104049:	e8 0f ec ff ff       	call   80102c5d <kfree>
8010404e:	eb 0b                	jmp    8010405b <pipeclose+0x90>
  } else
    release(&p->lock);
80104050:	8b 45 08             	mov    0x8(%ebp),%eax
80104053:	89 04 24             	mov    %eax,(%esp)
80104056:	e8 4a 11 00 00       	call   801051a5 <release>
}
8010405b:	c9                   	leave  
8010405c:	c3                   	ret    

8010405d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010405d:	55                   	push   %ebp
8010405e:	89 e5                	mov    %esp,%ebp
80104060:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104063:	8b 45 08             	mov    0x8(%ebp),%eax
80104066:	89 04 24             	mov    %eax,(%esp)
80104069:	e8 cd 10 00 00       	call   8010513b <acquire>
  for(i = 0; i < n; i++){
8010406e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104075:	e9 a3 00 00 00       	jmp    8010411d <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010407a:	eb 56                	jmp    801040d2 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
8010407c:	8b 45 08             	mov    0x8(%ebp),%eax
8010407f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104085:	85 c0                	test   %eax,%eax
80104087:	74 0c                	je     80104095 <pipewrite+0x38>
80104089:	e8 a5 02 00 00       	call   80104333 <myproc>
8010408e:	8b 40 24             	mov    0x24(%eax),%eax
80104091:	85 c0                	test   %eax,%eax
80104093:	74 15                	je     801040aa <pipewrite+0x4d>
        release(&p->lock);
80104095:	8b 45 08             	mov    0x8(%ebp),%eax
80104098:	89 04 24             	mov    %eax,(%esp)
8010409b:	e8 05 11 00 00       	call   801051a5 <release>
        return -1;
801040a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a5:	e9 9d 00 00 00       	jmp    80104147 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	05 34 02 00 00       	add    $0x234,%eax
801040b2:	89 04 24             	mov    %eax,(%esp)
801040b5:	e8 c9 0b 00 00       	call   80104c83 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801040ba:	8b 45 08             	mov    0x8(%ebp),%eax
801040bd:	8b 55 08             	mov    0x8(%ebp),%edx
801040c0:	81 c2 38 02 00 00    	add    $0x238,%edx
801040c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801040ca:	89 14 24             	mov    %edx,(%esp)
801040cd:	e8 da 0a 00 00       	call   80104bac <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040d2:	8b 45 08             	mov    0x8(%ebp),%eax
801040d5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040db:	8b 45 08             	mov    0x8(%ebp),%eax
801040de:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040e4:	05 00 02 00 00       	add    $0x200,%eax
801040e9:	39 c2                	cmp    %eax,%edx
801040eb:	74 8f                	je     8010407c <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040ed:	8b 45 08             	mov    0x8(%ebp),%eax
801040f0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040f6:	8d 48 01             	lea    0x1(%eax),%ecx
801040f9:	8b 55 08             	mov    0x8(%ebp),%edx
801040fc:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104102:	25 ff 01 00 00       	and    $0x1ff,%eax
80104107:	89 c1                	mov    %eax,%ecx
80104109:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010410c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410f:	01 d0                	add    %edx,%eax
80104111:	8a 10                	mov    (%eax),%dl
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010411a:	ff 45 f4             	incl   -0xc(%ebp)
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	3b 45 10             	cmp    0x10(%ebp),%eax
80104123:	0f 8c 51 ff ff ff    	jl     8010407a <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	05 34 02 00 00       	add    $0x234,%eax
80104131:	89 04 24             	mov    %eax,(%esp)
80104134:	e8 4a 0b 00 00       	call   80104c83 <wakeup>
  release(&p->lock);
80104139:	8b 45 08             	mov    0x8(%ebp),%eax
8010413c:	89 04 24             	mov    %eax,(%esp)
8010413f:	e8 61 10 00 00       	call   801051a5 <release>
  return n;
80104144:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104147:	c9                   	leave  
80104148:	c3                   	ret    

80104149 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104149:	55                   	push   %ebp
8010414a:	89 e5                	mov    %esp,%ebp
8010414c:	53                   	push   %ebx
8010414d:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	89 04 24             	mov    %eax,(%esp)
80104156:	e8 e0 0f 00 00       	call   8010513b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010415b:	eb 39                	jmp    80104196 <piperead+0x4d>
    if(myproc()->killed){
8010415d:	e8 d1 01 00 00       	call   80104333 <myproc>
80104162:	8b 40 24             	mov    0x24(%eax),%eax
80104165:	85 c0                	test   %eax,%eax
80104167:	74 15                	je     8010417e <piperead+0x35>
      release(&p->lock);
80104169:	8b 45 08             	mov    0x8(%ebp),%eax
8010416c:	89 04 24             	mov    %eax,(%esp)
8010416f:	e8 31 10 00 00       	call   801051a5 <release>
      return -1;
80104174:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104179:	e9 b3 00 00 00       	jmp    80104231 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010417e:	8b 45 08             	mov    0x8(%ebp),%eax
80104181:	8b 55 08             	mov    0x8(%ebp),%edx
80104184:	81 c2 34 02 00 00    	add    $0x234,%edx
8010418a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010418e:	89 14 24             	mov    %edx,(%esp)
80104191:	e8 16 0a 00 00       	call   80104bac <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104196:	8b 45 08             	mov    0x8(%ebp),%eax
80104199:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010419f:	8b 45 08             	mov    0x8(%ebp),%eax
801041a2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041a8:	39 c2                	cmp    %eax,%edx
801041aa:	75 0d                	jne    801041b9 <piperead+0x70>
801041ac:	8b 45 08             	mov    0x8(%ebp),%eax
801041af:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041b5:	85 c0                	test   %eax,%eax
801041b7:	75 a4                	jne    8010415d <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041c0:	eb 49                	jmp    8010420b <piperead+0xc2>
    if(p->nread == p->nwrite)
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041cb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ce:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041d4:	39 c2                	cmp    %eax,%edx
801041d6:	75 02                	jne    801041da <piperead+0x91>
      break;
801041d8:	eb 39                	jmp    80104213 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041e3:	8b 45 08             	mov    0x8(%ebp),%eax
801041e6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ec:	8d 48 01             	lea    0x1(%eax),%ecx
801041ef:	8b 55 08             	mov    0x8(%ebp),%edx
801041f2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041f8:	25 ff 01 00 00       	and    $0x1ff,%eax
801041fd:	89 c2                	mov    %eax,%edx
801041ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104202:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104206:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104208:	ff 45 f4             	incl   -0xc(%ebp)
8010420b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104211:	7c af                	jl     801041c2 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	05 38 02 00 00       	add    $0x238,%eax
8010421b:	89 04 24             	mov    %eax,(%esp)
8010421e:	e8 60 0a 00 00       	call   80104c83 <wakeup>
  release(&p->lock);
80104223:	8b 45 08             	mov    0x8(%ebp),%eax
80104226:	89 04 24             	mov    %eax,(%esp)
80104229:	e8 77 0f 00 00       	call   801051a5 <release>
  return i;
8010422e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104231:	83 c4 24             	add    $0x24,%esp
80104234:	5b                   	pop    %ebx
80104235:	5d                   	pop    %ebp
80104236:	c3                   	ret    
	...

80104238 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104238:	55                   	push   %ebp
80104239:	89 e5                	mov    %esp,%ebp
8010423b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010423e:	9c                   	pushf  
8010423f:	58                   	pop    %eax
80104240:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104243:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104246:	c9                   	leave  
80104247:	c3                   	ret    

80104248 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104248:	55                   	push   %ebp
80104249:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010424b:	fb                   	sti    
}
8010424c:	5d                   	pop    %ebp
8010424d:	c3                   	ret    

8010424e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010424e:	55                   	push   %ebp
8010424f:	89 e5                	mov    %esp,%ebp
80104251:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104254:	c7 44 24 04 90 92 10 	movl   $0x80109290,0x4(%esp)
8010425b:	80 
8010425c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104263:	e8 b2 0e 00 00       	call   8010511a <initlock>
}
80104268:	c9                   	leave  
80104269:	c3                   	ret    

8010426a <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010426a:	55                   	push   %ebp
8010426b:	89 e5                	mov    %esp,%ebp
8010426d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104270:	e8 3a 00 00 00       	call   801042af <mycpu>
80104275:	89 c2                	mov    %eax,%edx
80104277:	b8 80 4c 11 80       	mov    $0x80114c80,%eax
8010427c:	29 c2                	sub    %eax,%edx
8010427e:	89 d0                	mov    %edx,%eax
80104280:	c1 f8 04             	sar    $0x4,%eax
80104283:	89 c1                	mov    %eax,%ecx
80104285:	89 ca                	mov    %ecx,%edx
80104287:	c1 e2 03             	shl    $0x3,%edx
8010428a:	01 ca                	add    %ecx,%edx
8010428c:	89 d0                	mov    %edx,%eax
8010428e:	c1 e0 05             	shl    $0x5,%eax
80104291:	29 d0                	sub    %edx,%eax
80104293:	c1 e0 02             	shl    $0x2,%eax
80104296:	01 c8                	add    %ecx,%eax
80104298:	c1 e0 03             	shl    $0x3,%eax
8010429b:	01 c8                	add    %ecx,%eax
8010429d:	89 c2                	mov    %eax,%edx
8010429f:	c1 e2 0f             	shl    $0xf,%edx
801042a2:	29 c2                	sub    %eax,%edx
801042a4:	c1 e2 02             	shl    $0x2,%edx
801042a7:	01 ca                	add    %ecx,%edx
801042a9:	89 d0                	mov    %edx,%eax
801042ab:	f7 d8                	neg    %eax
}
801042ad:	c9                   	leave  
801042ae:	c3                   	ret    

801042af <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801042af:	55                   	push   %ebp
801042b0:	89 e5                	mov    %esp,%ebp
801042b2:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801042b5:	e8 7e ff ff ff       	call   80104238 <readeflags>
801042ba:	25 00 02 00 00       	and    $0x200,%eax
801042bf:	85 c0                	test   %eax,%eax
801042c1:	74 0c                	je     801042cf <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801042c3:	c7 04 24 98 92 10 80 	movl   $0x80109298,(%esp)
801042ca:	e8 85 c2 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801042cf:	e8 15 ee ff ff       	call   801030e9 <lapicid>
801042d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042de:	eb 3b                	jmp    8010431b <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801042e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e3:	89 d0                	mov    %edx,%eax
801042e5:	c1 e0 02             	shl    $0x2,%eax
801042e8:	01 d0                	add    %edx,%eax
801042ea:	01 c0                	add    %eax,%eax
801042ec:	01 d0                	add    %edx,%eax
801042ee:	c1 e0 04             	shl    $0x4,%eax
801042f1:	05 80 4c 11 80       	add    $0x80114c80,%eax
801042f6:	8a 00                	mov    (%eax),%al
801042f8:	0f b6 c0             	movzbl %al,%eax
801042fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801042fe:	75 18                	jne    80104318 <mycpu+0x69>
      return &cpus[i];
80104300:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104303:	89 d0                	mov    %edx,%eax
80104305:	c1 e0 02             	shl    $0x2,%eax
80104308:	01 d0                	add    %edx,%eax
8010430a:	01 c0                	add    %eax,%eax
8010430c:	01 d0                	add    %edx,%eax
8010430e:	c1 e0 04             	shl    $0x4,%eax
80104311:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104316:	eb 19                	jmp    80104331 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104318:	ff 45 f4             	incl   -0xc(%ebp)
8010431b:	a1 00 52 11 80       	mov    0x80115200,%eax
80104320:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104323:	7c bb                	jl     801042e0 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104325:	c7 04 24 be 92 10 80 	movl   $0x801092be,(%esp)
8010432c:	e8 23 c2 ff ff       	call   80100554 <panic>
}
80104331:	c9                   	leave  
80104332:	c3                   	ret    

80104333 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104333:	55                   	push   %ebp
80104334:	89 e5                	mov    %esp,%ebp
80104336:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104339:	e8 5c 0f 00 00       	call   8010529a <pushcli>
  c = mycpu();
8010433e:	e8 6c ff ff ff       	call   801042af <mycpu>
80104343:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104349:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010434f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104352:	e8 8d 0f 00 00       	call   801052e4 <popcli>
  return p;
80104357:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010435a:	c9                   	leave  
8010435b:	c3                   	ret    

8010435c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010435c:	55                   	push   %ebp
8010435d:	89 e5                	mov    %esp,%ebp
8010435f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);
80104362:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104369:	e8 cd 0d 00 00       	call   8010513b <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010436e:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104375:	eb 53                	jmp    801043ca <allocproc+0x6e>
    if(p->state == UNUSED)
80104377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437a:	8b 40 0c             	mov    0xc(%eax),%eax
8010437d:	85 c0                	test   %eax,%eax
8010437f:	75 42                	jne    801043c3 <allocproc+0x67>
      goto found;
80104381:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010438c:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104391:	8d 50 01             	lea    0x1(%eax),%edx
80104394:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
8010439a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439d:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801043a0:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043a7:	e8 f9 0d 00 00       	call   801051a5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043ac:	e8 7e e9 ff ff       	call   80102d2f <kalloc>
801043b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b4:	89 42 08             	mov    %eax,0x8(%edx)
801043b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ba:	8b 40 08             	mov    0x8(%eax),%eax
801043bd:	85 c0                	test   %eax,%eax
801043bf:	75 39                	jne    801043fa <allocproc+0x9e>
801043c1:	eb 26                	jmp    801043e9 <allocproc+0x8d>
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c3:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801043ca:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801043d1:	72 a4                	jb     80104377 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801043d3:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043da:	e8 c6 0d 00 00       	call   801051a5 <release>
  return 0;
801043df:	b8 00 00 00 00       	mov    $0x0,%eax
801043e4:	e9 8d 00 00 00       	jmp    80104476 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ec:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043f3:	b8 00 00 00 00       	mov    $0x0,%eax
801043f8:	eb 7c                	jmp    80104476 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
801043fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fd:	8b 40 08             	mov    0x8(%eax),%eax
80104400:	05 00 10 00 00       	add    $0x1000,%eax
80104405:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104408:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010440c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104412:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104415:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104419:	ba fc 6a 10 80       	mov    $0x80106afc,%edx
8010441e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104421:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104423:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010442d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104433:	8b 40 1c             	mov    0x1c(%eax),%eax
80104436:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010443d:	00 
8010443e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104445:	00 
80104446:	89 04 24             	mov    %eax,(%esp)
80104449:	e8 50 0f 00 00       	call   8010539e <memset>
  p->context->eip = (uint)forkret;
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104451:	8b 40 1c             	mov    0x1c(%eax),%eax
80104454:	ba 6d 4b 10 80       	mov    $0x80104b6d,%edx
80104459:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
80104466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104469:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104470:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
80104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104476:	c9                   	leave  
80104477:	c3                   	ret    

80104478 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104478:	55                   	push   %ebp
80104479:	89 e5                	mov    %esp,%ebp
8010447b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010447e:	e8 d9 fe ff ff       	call   8010435c <allocproc>
80104483:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	a3 00 c9 10 80       	mov    %eax,0x8010c900
  if((p->pgdir = setupkvm()) == 0)
8010448e:	e8 c3 3b 00 00       	call   80108056 <setupkvm>
80104493:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104496:	89 42 04             	mov    %eax,0x4(%edx)
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	8b 40 04             	mov    0x4(%eax),%eax
8010449f:	85 c0                	test   %eax,%eax
801044a1:	75 0c                	jne    801044af <userinit+0x37>
    panic("userinit: out of memory?");
801044a3:	c7 04 24 ce 92 10 80 	movl   $0x801092ce,(%esp)
801044aa:	e8 a5 c0 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044af:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b7:	8b 40 04             	mov    0x4(%eax),%eax
801044ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801044be:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
801044c5:	80 
801044c6:	89 04 24             	mov    %eax,(%esp)
801044c9:	e8 e9 3d 00 00       	call   801082b7 <inituvm>
  p->sz = PGSIZE;
801044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044da:	8b 40 18             	mov    0x18(%eax),%eax
801044dd:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044e4:	00 
801044e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044ec:	00 
801044ed:	89 04 24             	mov    %eax,(%esp)
801044f0:	e8 a9 0e 00 00       	call   8010539e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f8:	8b 40 18             	mov    0x18(%eax),%eax
801044fb:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 18             	mov    0x18(%eax),%eax
80104507:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 50 18             	mov    0x18(%eax),%edx
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	8b 40 18             	mov    0x18(%eax),%eax
80104519:	8b 40 2c             	mov    0x2c(%eax),%eax
8010451c:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 50 18             	mov    0x18(%eax),%edx
80104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104529:	8b 40 18             	mov    0x18(%eax),%eax
8010452c:	8b 40 2c             	mov    0x2c(%eax),%eax
8010452f:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	8b 40 18             	mov    0x18(%eax),%eax
80104539:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104543:	8b 40 18             	mov    0x18(%eax),%eax
80104546:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	8b 40 18             	mov    0x18(%eax),%eax
80104553:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	83 c0 6c             	add    $0x6c,%eax
80104560:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104567:	00 
80104568:	c7 44 24 04 e7 92 10 	movl   $0x801092e7,0x4(%esp)
8010456f:	80 
80104570:	89 04 24             	mov    %eax,(%esp)
80104573:	e8 32 10 00 00       	call   801055aa <safestrcpy>
  p->cwd = namei("/");
80104578:	c7 04 24 f0 92 10 80 	movl   $0x801092f0,(%esp)
8010457f:	e8 63 e0 ff ff       	call   801025e7 <namei>
80104584:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104587:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010458a:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104591:	e8 a5 0b 00 00       	call   8010513b <acquire>

  p->state = RUNNABLE;
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801045a0:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801045a7:	e8 f9 0b 00 00       	call   801051a5 <release>
}
801045ac:	c9                   	leave  
801045ad:	c3                   	ret    

801045ae <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045ae:	55                   	push   %ebp
801045af:	89 e5                	mov    %esp,%ebp
801045b1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801045b4:	e8 7a fd ff ff       	call   80104333 <myproc>
801045b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801045bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045bf:	8b 00                	mov    (%eax),%eax
801045c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045c8:	7e 31                	jle    801045fb <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045ca:	8b 55 08             	mov    0x8(%ebp),%edx
801045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d0:	01 c2                	add    %eax,%edx
801045d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045d5:	8b 40 04             	mov    0x4(%eax),%eax
801045d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801045dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045df:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e3:	89 04 24             	mov    %eax,(%esp)
801045e6:	e8 37 3e 00 00       	call   80108422 <allocuvm>
801045eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045f2:	75 3e                	jne    80104632 <growproc+0x84>
      return -1;
801045f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f9:	eb 4f                	jmp    8010464a <growproc+0x9c>
  } else if(n < 0){
801045fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045ff:	79 31                	jns    80104632 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104601:	8b 55 08             	mov    0x8(%ebp),%edx
80104604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104607:	01 c2                	add    %eax,%edx
80104609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010460c:	8b 40 04             	mov    0x4(%eax),%eax
8010460f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104613:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104616:	89 54 24 04          	mov    %edx,0x4(%esp)
8010461a:	89 04 24             	mov    %eax,(%esp)
8010461d:	e8 16 3f 00 00       	call   80108538 <deallocuvm>
80104622:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104625:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104629:	75 07                	jne    80104632 <growproc+0x84>
      return -1;
8010462b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104630:	eb 18                	jmp    8010464a <growproc+0x9c>
  }
  curproc->sz = sz;
80104632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104638:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010463d:	89 04 24             	mov    %eax,(%esp)
80104640:	e8 eb 3a 00 00       	call   80108130 <switchuvm>
  return 0;
80104645:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010464a:	c9                   	leave  
8010464b:	c3                   	ret    

8010464c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010464c:	55                   	push   %ebp
8010464d:	89 e5                	mov    %esp,%ebp
8010464f:	57                   	push   %edi
80104650:	56                   	push   %esi
80104651:	53                   	push   %ebx
80104652:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104655:	e8 d9 fc ff ff       	call   80104333 <myproc>
8010465a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010465d:	e8 fa fc ff ff       	call   8010435c <allocproc>
80104662:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104665:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104669:	75 0a                	jne    80104675 <fork+0x29>
    return -1;
8010466b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104670:	e9 47 01 00 00       	jmp    801047bc <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104675:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104678:	8b 10                	mov    (%eax),%edx
8010467a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467d:	8b 40 04             	mov    0x4(%eax),%eax
80104680:	89 54 24 04          	mov    %edx,0x4(%esp)
80104684:	89 04 24             	mov    %eax,(%esp)
80104687:	e8 4c 40 00 00       	call   801086d8 <copyuvm>
8010468c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010468f:	89 42 04             	mov    %eax,0x4(%edx)
80104692:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104695:	8b 40 04             	mov    0x4(%eax),%eax
80104698:	85 c0                	test   %eax,%eax
8010469a:	75 2c                	jne    801046c8 <fork+0x7c>
    kfree(np->kstack);
8010469c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010469f:	8b 40 08             	mov    0x8(%eax),%eax
801046a2:	89 04 24             	mov    %eax,(%esp)
801046a5:	e8 b3 e5 ff ff       	call   80102c5d <kfree>
    np->kstack = 0;
801046aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c3:	e9 f4 00 00 00       	jmp    801047bc <fork+0x170>
  }
  np->sz = curproc->sz;
801046c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cb:	8b 10                	mov    (%eax),%edx
801046cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d0:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801046d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046d8:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046de:	8b 50 18             	mov    0x18(%eax),%edx
801046e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e4:	8b 40 18             	mov    0x18(%eax),%eax
801046e7:	89 c3                	mov    %eax,%ebx
801046e9:	b8 13 00 00 00       	mov    $0x13,%eax
801046ee:	89 d7                	mov    %edx,%edi
801046f0:	89 de                	mov    %ebx,%esi
801046f2:	89 c1                	mov    %eax,%ecx
801046f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f9:	8b 40 18             	mov    0x18(%eax),%eax
801046fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010470a:	eb 36                	jmp    80104742 <fork+0xf6>
    if(curproc->ofile[i])
8010470c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010470f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104712:	83 c2 08             	add    $0x8,%edx
80104715:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104719:	85 c0                	test   %eax,%eax
8010471b:	74 22                	je     8010473f <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010471d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104720:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104723:	83 c2 08             	add    $0x8,%edx
80104726:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010472a:	89 04 24             	mov    %eax,(%esp)
8010472d:	e8 30 ca ff ff       	call   80101162 <filedup>
80104732:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104735:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104738:	83 c1 08             	add    $0x8,%ecx
8010473b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010473f:	ff 45 e4             	incl   -0x1c(%ebp)
80104742:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104746:	7e c4                	jle    8010470c <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104748:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010474b:	8b 40 68             	mov    0x68(%eax),%eax
8010474e:	89 04 24             	mov    %eax,(%esp)
80104751:	e8 3a d3 ff ff       	call   80101a90 <idup>
80104756:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104759:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010475c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104762:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104765:	83 c0 6c             	add    $0x6c,%eax
80104768:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010476f:	00 
80104770:	89 54 24 04          	mov    %edx,0x4(%esp)
80104774:	89 04 24             	mov    %eax,(%esp)
80104777:	e8 2e 0e 00 00       	call   801055aa <safestrcpy>



  pid = np->pid;
8010477c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010477f:	8b 40 10             	mov    0x10(%eax),%eax
80104782:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104785:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010478c:	e8 aa 09 00 00       	call   8010513b <acquire>

  np->state = RUNNABLE;
80104791:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104794:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
8010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801047a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047a7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
801047ad:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801047b4:	e8 ec 09 00 00       	call   801051a5 <release>

  return pid;
801047b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801047bc:	83 c4 2c             	add    $0x2c,%esp
801047bf:	5b                   	pop    %ebx
801047c0:	5e                   	pop    %esi
801047c1:	5f                   	pop    %edi
801047c2:	5d                   	pop    %ebp
801047c3:	c3                   	ret    

801047c4 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047c4:	55                   	push   %ebp
801047c5:	89 e5                	mov    %esp,%ebp
801047c7:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801047ca:	e8 64 fb ff ff       	call   80104333 <myproc>
801047cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801047d2:	a1 00 c9 10 80       	mov    0x8010c900,%eax
801047d7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047da:	75 0c                	jne    801047e8 <exit+0x24>
    panic("init exiting");
801047dc:	c7 04 24 f2 92 10 80 	movl   $0x801092f2,(%esp)
801047e3:	e8 6c bd ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047ef:	eb 3a                	jmp    8010482b <exit+0x67>
    if(curproc->ofile[fd]){
801047f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047f7:	83 c2 08             	add    $0x8,%edx
801047fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047fe:	85 c0                	test   %eax,%eax
80104800:	74 26                	je     80104828 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104802:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104805:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104808:	83 c2 08             	add    $0x8,%edx
8010480b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010480f:	89 04 24             	mov    %eax,(%esp)
80104812:	e8 93 c9 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104817:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010481a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010481d:	83 c2 08             	add    $0x8,%edx
80104820:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104827:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104828:	ff 45 f0             	incl   -0x10(%ebp)
8010482b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010482f:	7e c0                	jle    801047f1 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104831:	e8 fd ed ff ff       	call   80103633 <begin_op>
  iput(curproc->cwd);
80104836:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104839:	8b 40 68             	mov    0x68(%eax),%eax
8010483c:	89 04 24             	mov    %eax,(%esp)
8010483f:	e8 cc d3 ff ff       	call   80101c10 <iput>
  end_op();
80104844:	e8 6c ee ff ff       	call   801036b5 <end_op>
  curproc->cwd = 0;
80104849:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010484c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104853:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010485a:	e8 dc 08 00 00       	call   8010513b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010485f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104862:	8b 40 14             	mov    0x14(%eax),%eax
80104865:	89 04 24             	mov    %eax,(%esp)
80104868:	e8 d5 03 00 00       	call   80104c42 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010486d:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104874:	eb 36                	jmp    801048ac <exit+0xe8>
    if(p->parent == curproc){
80104876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104879:	8b 40 14             	mov    0x14(%eax),%eax
8010487c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010487f:	75 24                	jne    801048a5 <exit+0xe1>
      p->parent = initproc;
80104881:	8b 15 00 c9 10 80    	mov    0x8010c900,%edx
80104887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010488d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104890:	8b 40 0c             	mov    0xc(%eax),%eax
80104893:	83 f8 05             	cmp    $0x5,%eax
80104896:	75 0d                	jne    801048a5 <exit+0xe1>
        wakeup1(initproc);
80104898:	a1 00 c9 10 80       	mov    0x8010c900,%eax
8010489d:	89 04 24             	mov    %eax,(%esp)
801048a0:	e8 9d 03 00 00       	call   80104c42 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a5:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048ac:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801048b3:	72 c1                	jb     80104876 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801048b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048b8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048bf:	e8 c9 01 00 00       	call   80104a8d <sched>
  panic("zombie exit");
801048c4:	c7 04 24 ff 92 10 80 	movl   $0x801092ff,(%esp)
801048cb:	e8 84 bc ff ff       	call   80100554 <panic>

801048d0 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048d0:	55                   	push   %ebp
801048d1:	89 e5                	mov    %esp,%ebp
801048d3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048d6:	e8 58 fa ff ff       	call   80104333 <myproc>
801048db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801048de:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801048e5:	e8 51 08 00 00       	call   8010513b <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801048ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f1:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801048f8:	e9 98 00 00 00       	jmp    80104995 <wait+0xc5>
      if(p->parent != curproc)
801048fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104900:	8b 40 14             	mov    0x14(%eax),%eax
80104903:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104906:	74 05                	je     8010490d <wait+0x3d>
        continue;
80104908:	e9 81 00 00 00       	jmp    8010498e <wait+0xbe>
      havekids = 1;
8010490d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104917:	8b 40 0c             	mov    0xc(%eax),%eax
8010491a:	83 f8 05             	cmp    $0x5,%eax
8010491d:	75 6f                	jne    8010498e <wait+0xbe>
        // Found one.
        pid = p->pid;
8010491f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104922:	8b 40 10             	mov    0x10(%eax),%eax
80104925:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492b:	8b 40 08             	mov    0x8(%eax),%eax
8010492e:	89 04 24             	mov    %eax,(%esp)
80104931:	e8 27 e3 ff ff       	call   80102c5d <kfree>
        p->kstack = 0;
80104936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104939:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104943:	8b 40 04             	mov    0x4(%eax),%eax
80104946:	89 04 24             	mov    %eax,(%esp)
80104949:	e8 ae 3c 00 00       	call   801085fc <freevm>
        p->pid = 0;
8010494e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104951:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104965:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104976:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010497d:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104984:	e8 1c 08 00 00       	call   801051a5 <release>
        return pid;
80104989:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010498c:	eb 4f                	jmp    801049dd <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010498e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104995:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
8010499c:	0f 82 5b ff ff ff    	jb     801048fd <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049a6:	74 0a                	je     801049b2 <wait+0xe2>
801049a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ab:	8b 40 24             	mov    0x24(%eax),%eax
801049ae:	85 c0                	test   %eax,%eax
801049b0:	74 13                	je     801049c5 <wait+0xf5>
      release(&ptable.lock);
801049b2:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801049b9:	e8 e7 07 00 00       	call   801051a5 <release>
      return -1;
801049be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c3:	eb 18                	jmp    801049dd <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801049c5:	c7 44 24 04 20 52 11 	movl   $0x80115220,0x4(%esp)
801049cc:	80 
801049cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049d0:	89 04 24             	mov    %eax,(%esp)
801049d3:	e8 d4 01 00 00       	call   80104bac <sleep>
  }
801049d8:	e9 0d ff ff ff       	jmp    801048ea <wait+0x1a>
}
801049dd:	c9                   	leave  
801049de:	c3                   	ret    

801049df <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801049df:	55                   	push   %ebp
801049e0:	89 e5                	mov    %esp,%ebp
801049e2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801049e5:	e8 c5 f8 ff ff       	call   801042af <mycpu>
801049ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801049ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049f0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801049f7:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801049fa:	e8 49 f8 ff ff       	call   80104248 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049ff:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a06:	e8 30 07 00 00       	call   8010513b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a0b:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104a12:	eb 5f                	jmp    80104a73 <scheduler+0x94>
      if(p->state != RUNNABLE)
80104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a17:	8b 40 0c             	mov    0xc(%eax),%eax
80104a1a:	83 f8 03             	cmp    $0x3,%eax
80104a1d:	74 02                	je     80104a21 <scheduler+0x42>
        continue;
80104a1f:	eb 4b                	jmp    80104a6c <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a27:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a30:	89 04 24             	mov    %eax,(%esp)
80104a33:	e8 f8 36 00 00       	call   80108130 <switchuvm>
      p->state = RUNNING;
80104a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a45:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a48:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a4b:	83 c2 04             	add    $0x4,%edx
80104a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a52:	89 14 24             	mov    %edx,(%esp)
80104a55:	e8 be 0b 00 00       	call   80105618 <swtch>
      switchkvm();
80104a5a:	e8 b7 36 00 00       	call   80108116 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a62:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a69:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a73:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104a7a:	72 98                	jb     80104a14 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104a7c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a83:	e8 1d 07 00 00       	call   801051a5 <release>

  }
80104a88:	e9 6d ff ff ff       	jmp    801049fa <scheduler+0x1b>

80104a8d <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104a8d:	55                   	push   %ebp
80104a8e:	89 e5                	mov    %esp,%ebp
80104a90:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104a93:	e8 9b f8 ff ff       	call   80104333 <myproc>
80104a98:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104a9b:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104aa2:	e8 c2 07 00 00       	call   80105269 <holding>
80104aa7:	85 c0                	test   %eax,%eax
80104aa9:	75 0c                	jne    80104ab7 <sched+0x2a>
    panic("sched ptable.lock");
80104aab:	c7 04 24 0b 93 10 80 	movl   $0x8010930b,(%esp)
80104ab2:	e8 9d ba ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104ab7:	e8 f3 f7 ff ff       	call   801042af <mycpu>
80104abc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ac2:	83 f8 01             	cmp    $0x1,%eax
80104ac5:	74 0c                	je     80104ad3 <sched+0x46>
    panic("sched locks");
80104ac7:	c7 04 24 1d 93 10 80 	movl   $0x8010931d,(%esp)
80104ace:	e8 81 ba ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad9:	83 f8 04             	cmp    $0x4,%eax
80104adc:	75 0c                	jne    80104aea <sched+0x5d>
    panic("sched running");
80104ade:	c7 04 24 29 93 10 80 	movl   $0x80109329,(%esp)
80104ae5:	e8 6a ba ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104aea:	e8 49 f7 ff ff       	call   80104238 <readeflags>
80104aef:	25 00 02 00 00       	and    $0x200,%eax
80104af4:	85 c0                	test   %eax,%eax
80104af6:	74 0c                	je     80104b04 <sched+0x77>
    panic("sched interruptible");
80104af8:	c7 04 24 37 93 10 80 	movl   $0x80109337,(%esp)
80104aff:	e8 50 ba ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104b04:	e8 a6 f7 ff ff       	call   801042af <mycpu>
80104b09:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b12:	e8 98 f7 ff ff       	call   801042af <mycpu>
80104b17:	8b 40 04             	mov    0x4(%eax),%eax
80104b1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b1d:	83 c2 1c             	add    $0x1c,%edx
80104b20:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b24:	89 14 24             	mov    %edx,(%esp)
80104b27:	e8 ec 0a 00 00       	call   80105618 <swtch>
  mycpu()->intena = intena;
80104b2c:	e8 7e f7 ff ff       	call   801042af <mycpu>
80104b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b34:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104b3a:	c9                   	leave  
80104b3b:	c3                   	ret    

80104b3c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b3c:	55                   	push   %ebp
80104b3d:	89 e5                	mov    %esp,%ebp
80104b3f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b42:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b49:	e8 ed 05 00 00       	call   8010513b <acquire>
  myproc()->state = RUNNABLE;
80104b4e:	e8 e0 f7 ff ff       	call   80104333 <myproc>
80104b53:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b5a:	e8 2e ff ff ff       	call   80104a8d <sched>
  release(&ptable.lock);
80104b5f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b66:	e8 3a 06 00 00       	call   801051a5 <release>
}
80104b6b:	c9                   	leave  
80104b6c:	c3                   	ret    

80104b6d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b6d:	55                   	push   %ebp
80104b6e:	89 e5                	mov    %esp,%ebp
80104b70:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b73:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b7a:	e8 26 06 00 00       	call   801051a5 <release>

  if (first) {
80104b7f:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b84:	85 c0                	test   %eax,%eax
80104b86:	74 22                	je     80104baa <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b88:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104b8f:	00 00 00 
    iinit(ROOTDEV);
80104b92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b99:	e8 bd cb ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104b9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ba5:	e8 8a e8 ff ff       	call   80103434 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104baa:	c9                   	leave  
80104bab:	c3                   	ret    

80104bac <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bac:	55                   	push   %ebp
80104bad:	89 e5                	mov    %esp,%ebp
80104baf:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104bb2:	e8 7c f7 ff ff       	call   80104333 <myproc>
80104bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104bba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bbe:	75 0c                	jne    80104bcc <sleep+0x20>
    panic("sleep");
80104bc0:	c7 04 24 4b 93 10 80 	movl   $0x8010934b,(%esp)
80104bc7:	e8 88 b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104bd0:	75 0c                	jne    80104bde <sleep+0x32>
    panic("sleep without lk");
80104bd2:	c7 04 24 51 93 10 80 	movl   $0x80109351,(%esp)
80104bd9:	e8 76 b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104bde:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104be5:	74 17                	je     80104bfe <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104be7:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104bee:	e8 48 05 00 00       	call   8010513b <acquire>
    release(lk);
80104bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf6:	89 04 24             	mov    %eax,(%esp)
80104bf9:	e8 a7 05 00 00       	call   801051a5 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c01:	8b 55 08             	mov    0x8(%ebp),%edx
80104c04:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c11:	e8 77 fe ff ff       	call   80104a8d <sched>

  // Tidy up.
  p->chan = 0;
80104c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c19:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c20:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104c27:	74 17                	je     80104c40 <sleep+0x94>
    release(&ptable.lock);
80104c29:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c30:	e8 70 05 00 00       	call   801051a5 <release>
    acquire(lk);
80104c35:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c38:	89 04 24             	mov    %eax,(%esp)
80104c3b:	e8 fb 04 00 00       	call   8010513b <acquire>
  }
}
80104c40:	c9                   	leave  
80104c41:	c3                   	ret    

80104c42 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c42:	55                   	push   %ebp
80104c43:	89 e5                	mov    %esp,%ebp
80104c45:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c48:	c7 45 fc 54 52 11 80 	movl   $0x80115254,-0x4(%ebp)
80104c4f:	eb 27                	jmp    80104c78 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c54:	8b 40 0c             	mov    0xc(%eax),%eax
80104c57:	83 f8 02             	cmp    $0x2,%eax
80104c5a:	75 15                	jne    80104c71 <wakeup1+0x2f>
80104c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c5f:	8b 40 20             	mov    0x20(%eax),%eax
80104c62:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c65:	75 0a                	jne    80104c71 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c6a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c71:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104c78:	81 7d fc 54 73 11 80 	cmpl   $0x80117354,-0x4(%ebp)
80104c7f:	72 d0                	jb     80104c51 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c81:	c9                   	leave  
80104c82:	c3                   	ret    

80104c83 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c83:	55                   	push   %ebp
80104c84:	89 e5                	mov    %esp,%ebp
80104c86:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c89:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c90:	e8 a6 04 00 00       	call   8010513b <acquire>
  wakeup1(chan);
80104c95:	8b 45 08             	mov    0x8(%ebp),%eax
80104c98:	89 04 24             	mov    %eax,(%esp)
80104c9b:	e8 a2 ff ff ff       	call   80104c42 <wakeup1>
  release(&ptable.lock);
80104ca0:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104ca7:	e8 f9 04 00 00       	call   801051a5 <release>
}
80104cac:	c9                   	leave  
80104cad:	c3                   	ret    

80104cae <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cae:	55                   	push   %ebp
80104caf:	89 e5                	mov    %esp,%ebp
80104cb1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104cb4:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cbb:	e8 7b 04 00 00       	call   8010513b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cc0:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104cc7:	eb 44                	jmp    80104d0d <kill+0x5f>
    if(p->pid == pid){
80104cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccc:	8b 40 10             	mov    0x10(%eax),%eax
80104ccf:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cd2:	75 32                	jne    80104d06 <kill+0x58>
      p->killed = 1;
80104cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ce4:	83 f8 02             	cmp    $0x2,%eax
80104ce7:	75 0a                	jne    80104cf3 <kill+0x45>
        p->state = RUNNABLE;
80104ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cec:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104cf3:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cfa:	e8 a6 04 00 00       	call   801051a5 <release>
      return 0;
80104cff:	b8 00 00 00 00       	mov    $0x0,%eax
80104d04:	eb 21                	jmp    80104d27 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d06:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d0d:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104d14:	72 b3                	jb     80104cc9 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d16:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d1d:	e8 83 04 00 00       	call   801051a5 <release>
  return -1;
80104d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d27:	c9                   	leave  
80104d28:	c3                   	ret    

80104d29 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d29:	55                   	push   %ebp
80104d2a:	89 e5                	mov    %esp,%ebp
80104d2c:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d2f:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104d36:	e9 1e 01 00 00       	jmp    80104e59 <procdump+0x130>
    if(p->state == UNUSED)
80104d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d41:	85 c0                	test   %eax,%eax
80104d43:	75 05                	jne    80104d4a <procdump+0x21>
      continue;
80104d45:	e9 08 01 00 00       	jmp    80104e52 <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d50:	83 f8 05             	cmp    $0x5,%eax
80104d53:	77 23                	ja     80104d78 <procdump+0x4f>
80104d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d58:	8b 40 0c             	mov    0xc(%eax),%eax
80104d5b:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d62:	85 c0                	test   %eax,%eax
80104d64:	74 12                	je     80104d78 <procdump+0x4f>
      state = states[p->state];
80104d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d69:	8b 40 0c             	mov    0xc(%eax),%eax
80104d6c:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d73:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d76:	eb 07                	jmp    80104d7f <procdump+0x56>
    else
      state = "???";
80104d78:	c7 45 ec 62 93 10 80 	movl   $0x80109362,-0x14(%ebp)

    if(p->cont == NULL){
80104d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d82:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d88:	85 c0                	test   %eax,%eax
80104d8a:	75 29                	jne    80104db5 <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d8f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d95:	8b 40 10             	mov    0x10(%eax),%eax
80104d98:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104d9c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d9f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104da3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104da7:	c7 04 24 66 93 10 80 	movl   $0x80109366,(%esp)
80104dae:	e8 0e b6 ff ff       	call   801003c1 <cprintf>
80104db3:	eb 37                	jmp    80104dec <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db8:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dbe:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104dc4:	8d 48 18             	lea    0x18(%eax),%ecx
80104dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dca:	8b 40 10             	mov    0x10(%eax),%eax
80104dcd:	89 54 24 10          	mov    %edx,0x10(%esp)
80104dd1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104dd4:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104de0:	c7 04 24 74 93 10 80 	movl   $0x80109374,(%esp)
80104de7:	e8 d5 b5 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80104dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104def:	8b 40 0c             	mov    0xc(%eax),%eax
80104df2:	83 f8 02             	cmp    $0x2,%eax
80104df5:	75 4f                	jne    80104e46 <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfa:	8b 40 1c             	mov    0x1c(%eax),%eax
80104dfd:	8b 40 0c             	mov    0xc(%eax),%eax
80104e00:	83 c0 08             	add    $0x8,%eax
80104e03:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e06:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e0a:	89 04 24             	mov    %eax,(%esp)
80104e0d:	e8 e0 03 00 00       	call   801051f2 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e19:	eb 1a                	jmp    80104e35 <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e22:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e26:	c7 04 24 80 93 10 80 	movl   $0x80109380,(%esp)
80104e2d:	e8 8f b5 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e32:	ff 45 f4             	incl   -0xc(%ebp)
80104e35:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e39:	7f 0b                	jg     80104e46 <procdump+0x11d>
80104e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e42:	85 c0                	test   %eax,%eax
80104e44:	75 d5                	jne    80104e1b <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e46:	c7 04 24 84 93 10 80 	movl   $0x80109384,(%esp)
80104e4d:	e8 6f b5 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e52:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e59:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80104e60:	0f 82 d5 fe ff ff    	jb     80104d3b <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e66:	c9                   	leave  
80104e67:	c3                   	ret    

80104e68 <strcmp1>:
//   return os;
// }

int
strcmp1(const char *p, const char *q)
{
80104e68:	55                   	push   %ebp
80104e69:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104e6b:	eb 06                	jmp    80104e73 <strcmp1+0xb>
    p++, q++;
80104e6d:	ff 45 08             	incl   0x8(%ebp)
80104e70:	ff 45 0c             	incl   0xc(%ebp)
// }

int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104e73:	8b 45 08             	mov    0x8(%ebp),%eax
80104e76:	8a 00                	mov    (%eax),%al
80104e78:	84 c0                	test   %al,%al
80104e7a:	74 0e                	je     80104e8a <strcmp1+0x22>
80104e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7f:	8a 10                	mov    (%eax),%dl
80104e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e84:	8a 00                	mov    (%eax),%al
80104e86:	38 c2                	cmp    %al,%dl
80104e88:	74 e3                	je     80104e6d <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8d:	8a 00                	mov    (%eax),%al
80104e8f:	0f b6 d0             	movzbl %al,%edx
80104e92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e95:	8a 00                	mov    (%eax),%al
80104e97:	0f b6 c0             	movzbl %al,%eax
80104e9a:	29 c2                	sub    %eax,%edx
80104e9c:	89 d0                	mov    %edx,%eax
}
80104e9e:	5d                   	pop    %ebp
80104e9f:	c3                   	ret    

80104ea0 <c_procdump>:

void
c_procdump(char* name)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea6:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104ead:	e9 0f 01 00 00       	jmp    80104fc1 <c_procdump+0x121>

    // if(p->cont == NULL){
    //   cprintf("p_cont is null in %s.\n", name);
    // }
    if(p->state == UNUSED || p->cont == NULL)
80104eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb5:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb8:	85 c0                	test   %eax,%eax
80104eba:	74 0d                	je     80104ec9 <c_procdump+0x29>
80104ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104ec5:	85 c0                	test   %eax,%eax
80104ec7:	75 05                	jne    80104ece <c_procdump+0x2e>
      continue;
80104ec9:	e9 ec 00 00 00       	jmp    80104fba <c_procdump+0x11a>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed4:	83 f8 05             	cmp    $0x5,%eax
80104ed7:	77 23                	ja     80104efc <c_procdump+0x5c>
80104ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edc:	8b 40 0c             	mov    0xc(%eax),%eax
80104edf:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80104ee6:	85 c0                	test   %eax,%eax
80104ee8:	74 12                	je     80104efc <c_procdump+0x5c>
      state = states[p->state];
80104eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eed:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef0:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80104ef7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104efa:	eb 07                	jmp    80104f03 <c_procdump+0x63>
    else
      state = "???";
80104efc:	c7 45 ec 62 93 10 80 	movl   $0x80109362,-0x14(%ebp)

    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
80104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f06:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f0c:	8d 50 18             	lea    0x18(%eax),%edx
80104f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f12:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f16:	89 14 24             	mov    %edx,(%esp)
80104f19:	e8 4a ff ff ff       	call   80104e68 <strcmp1>
80104f1e:	85 c0                	test   %eax,%eax
80104f20:	0f 85 94 00 00 00    	jne    80104fba <c_procdump+0x11a>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
80104f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f29:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f2f:	8b 40 10             	mov    0x10(%eax),%eax
80104f32:	89 54 24 10          	mov    %edx,0x10(%esp)
80104f36:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f39:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f3d:	8b 55 08             	mov    0x8(%ebp),%edx
80104f40:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f44:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f48:	c7 04 24 74 93 10 80 	movl   $0x80109374,(%esp)
80104f4f:	e8 6d b4 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
80104f54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f57:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5a:	83 f8 02             	cmp    $0x2,%eax
80104f5d:	75 4f                	jne    80104fae <c_procdump+0x10e>
        getcallerpcs((uint*)p->context->ebp+2, pc);
80104f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f62:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f65:	8b 40 0c             	mov    0xc(%eax),%eax
80104f68:	83 c0 08             	add    $0x8,%eax
80104f6b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f6e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f72:	89 04 24             	mov    %eax,(%esp)
80104f75:	e8 78 02 00 00       	call   801051f2 <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
80104f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f81:	eb 1a                	jmp    80104f9d <c_procdump+0xfd>
          cprintf(" %p", pc[i]);
80104f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f86:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f8e:	c7 04 24 80 93 10 80 	movl   $0x80109380,(%esp)
80104f95:	e8 27 b4 ff ff       	call   801003c1 <cprintf>
    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
80104f9a:	ff 45 f4             	incl   -0xc(%ebp)
80104f9d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fa1:	7f 0b                	jg     80104fae <c_procdump+0x10e>
80104fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104faa:	85 c0                	test   %eax,%eax
80104fac:	75 d5                	jne    80104f83 <c_procdump+0xe3>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
80104fae:	c7 04 24 84 93 10 80 	movl   $0x80109384,(%esp)
80104fb5:	e8 07 b4 ff ff       	call   801003c1 <cprintf>
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fba:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104fc1:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80104fc8:	0f 82 e4 fe ff ff    	jb     80104eb2 <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
80104fce:	c9                   	leave  
80104fcf:	c3                   	ret    

80104fd0 <initp>:



struct proc* initp(void){
80104fd0:	55                   	push   %ebp
80104fd1:	89 e5                	mov    %esp,%ebp
  return initproc;
80104fd3:	a1 00 c9 10 80       	mov    0x8010c900,%eax
}
80104fd8:	5d                   	pop    %ebp
80104fd9:	c3                   	ret    
	...

80104fdc <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104fdc:	55                   	push   %ebp
80104fdd:	89 e5                	mov    %esp,%ebp
80104fdf:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe5:	83 c0 04             	add    $0x4,%eax
80104fe8:	c7 44 24 04 b0 93 10 	movl   $0x801093b0,0x4(%esp)
80104fef:	80 
80104ff0:	89 04 24             	mov    %eax,(%esp)
80104ff3:	e8 22 01 00 00       	call   8010511a <initlock>
  lk->name = name;
80104ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ffe:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105001:	8b 45 08             	mov    0x8(%ebp),%eax
80105004:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010500a:	8b 45 08             	mov    0x8(%ebp),%eax
8010500d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105014:	c9                   	leave  
80105015:	c3                   	ret    

80105016 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105016:	55                   	push   %ebp
80105017:	89 e5                	mov    %esp,%ebp
80105019:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010501c:	8b 45 08             	mov    0x8(%ebp),%eax
8010501f:	83 c0 04             	add    $0x4,%eax
80105022:	89 04 24             	mov    %eax,(%esp)
80105025:	e8 11 01 00 00       	call   8010513b <acquire>
  while (lk->locked) {
8010502a:	eb 15                	jmp    80105041 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
8010502c:	8b 45 08             	mov    0x8(%ebp),%eax
8010502f:	83 c0 04             	add    $0x4,%eax
80105032:	89 44 24 04          	mov    %eax,0x4(%esp)
80105036:	8b 45 08             	mov    0x8(%ebp),%eax
80105039:	89 04 24             	mov    %eax,(%esp)
8010503c:	e8 6b fb ff ff       	call   80104bac <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105041:	8b 45 08             	mov    0x8(%ebp),%eax
80105044:	8b 00                	mov    (%eax),%eax
80105046:	85 c0                	test   %eax,%eax
80105048:	75 e2                	jne    8010502c <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010504a:	8b 45 08             	mov    0x8(%ebp),%eax
8010504d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105053:	e8 db f2 ff ff       	call   80104333 <myproc>
80105058:	8b 50 10             	mov    0x10(%eax),%edx
8010505b:	8b 45 08             	mov    0x8(%ebp),%eax
8010505e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105061:	8b 45 08             	mov    0x8(%ebp),%eax
80105064:	83 c0 04             	add    $0x4,%eax
80105067:	89 04 24             	mov    %eax,(%esp)
8010506a:	e8 36 01 00 00       	call   801051a5 <release>
}
8010506f:	c9                   	leave  
80105070:	c3                   	ret    

80105071 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105071:	55                   	push   %ebp
80105072:	89 e5                	mov    %esp,%ebp
80105074:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105077:	8b 45 08             	mov    0x8(%ebp),%eax
8010507a:	83 c0 04             	add    $0x4,%eax
8010507d:	89 04 24             	mov    %eax,(%esp)
80105080:	e8 b6 00 00 00       	call   8010513b <acquire>
  lk->locked = 0;
80105085:	8b 45 08             	mov    0x8(%ebp),%eax
80105088:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010508e:	8b 45 08             	mov    0x8(%ebp),%eax
80105091:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105098:	8b 45 08             	mov    0x8(%ebp),%eax
8010509b:	89 04 24             	mov    %eax,(%esp)
8010509e:	e8 e0 fb ff ff       	call   80104c83 <wakeup>
  release(&lk->lk);
801050a3:	8b 45 08             	mov    0x8(%ebp),%eax
801050a6:	83 c0 04             	add    $0x4,%eax
801050a9:	89 04 24             	mov    %eax,(%esp)
801050ac:	e8 f4 00 00 00       	call   801051a5 <release>
}
801050b1:	c9                   	leave  
801050b2:	c3                   	ret    

801050b3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801050b3:	55                   	push   %ebp
801050b4:	89 e5                	mov    %esp,%ebp
801050b6:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801050b9:	8b 45 08             	mov    0x8(%ebp),%eax
801050bc:	83 c0 04             	add    $0x4,%eax
801050bf:	89 04 24             	mov    %eax,(%esp)
801050c2:	e8 74 00 00 00       	call   8010513b <acquire>
  r = lk->locked;
801050c7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ca:	8b 00                	mov    (%eax),%eax
801050cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801050cf:	8b 45 08             	mov    0x8(%ebp),%eax
801050d2:	83 c0 04             	add    $0x4,%eax
801050d5:	89 04 24             	mov    %eax,(%esp)
801050d8:	e8 c8 00 00 00       	call   801051a5 <release>
  return r;
801050dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801050e0:	c9                   	leave  
801050e1:	c3                   	ret    
	...

801050e4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801050e4:	55                   	push   %ebp
801050e5:	89 e5                	mov    %esp,%ebp
801050e7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801050ea:	9c                   	pushf  
801050eb:	58                   	pop    %eax
801050ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801050ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050f2:	c9                   	leave  
801050f3:	c3                   	ret    

801050f4 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801050f4:	55                   	push   %ebp
801050f5:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801050f7:	fa                   	cli    
}
801050f8:	5d                   	pop    %ebp
801050f9:	c3                   	ret    

801050fa <sti>:

static inline void
sti(void)
{
801050fa:	55                   	push   %ebp
801050fb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801050fd:	fb                   	sti    
}
801050fe:	5d                   	pop    %ebp
801050ff:	c3                   	ret    

80105100 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105100:	55                   	push   %ebp
80105101:	89 e5                	mov    %esp,%ebp
80105103:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105106:	8b 55 08             	mov    0x8(%ebp),%edx
80105109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010510f:	f0 87 02             	lock xchg %eax,(%edx)
80105112:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105115:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105118:	c9                   	leave  
80105119:	c3                   	ret    

8010511a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010511a:	55                   	push   %ebp
8010511b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010511d:	8b 45 08             	mov    0x8(%ebp),%eax
80105120:	8b 55 0c             	mov    0xc(%ebp),%edx
80105123:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105126:	8b 45 08             	mov    0x8(%ebp),%eax
80105129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010512f:	8b 45 08             	mov    0x8(%ebp),%eax
80105132:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105139:	5d                   	pop    %ebp
8010513a:	c3                   	ret    

8010513b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	53                   	push   %ebx
8010513f:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105142:	e8 53 01 00 00       	call   8010529a <pushcli>
  if(holding(lk))
80105147:	8b 45 08             	mov    0x8(%ebp),%eax
8010514a:	89 04 24             	mov    %eax,(%esp)
8010514d:	e8 17 01 00 00       	call   80105269 <holding>
80105152:	85 c0                	test   %eax,%eax
80105154:	74 0c                	je     80105162 <acquire+0x27>
    panic("acquire");
80105156:	c7 04 24 bb 93 10 80 	movl   $0x801093bb,(%esp)
8010515d:	e8 f2 b3 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105162:	90                   	nop
80105163:	8b 45 08             	mov    0x8(%ebp),%eax
80105166:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010516d:	00 
8010516e:	89 04 24             	mov    %eax,(%esp)
80105171:	e8 8a ff ff ff       	call   80105100 <xchg>
80105176:	85 c0                	test   %eax,%eax
80105178:	75 e9                	jne    80105163 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010517a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010517f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105182:	e8 28 f1 ff ff       	call   801042af <mycpu>
80105187:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	83 c0 0c             	add    $0xc,%eax
80105190:	89 44 24 04          	mov    %eax,0x4(%esp)
80105194:	8d 45 08             	lea    0x8(%ebp),%eax
80105197:	89 04 24             	mov    %eax,(%esp)
8010519a:	e8 53 00 00 00       	call   801051f2 <getcallerpcs>
}
8010519f:	83 c4 14             	add    $0x14,%esp
801051a2:	5b                   	pop    %ebx
801051a3:	5d                   	pop    %ebp
801051a4:	c3                   	ret    

801051a5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801051a5:	55                   	push   %ebp
801051a6:	89 e5                	mov    %esp,%ebp
801051a8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801051ab:	8b 45 08             	mov    0x8(%ebp),%eax
801051ae:	89 04 24             	mov    %eax,(%esp)
801051b1:	e8 b3 00 00 00       	call   80105269 <holding>
801051b6:	85 c0                	test   %eax,%eax
801051b8:	75 0c                	jne    801051c6 <release+0x21>
    panic("release");
801051ba:	c7 04 24 c3 93 10 80 	movl   $0x801093c3,(%esp)
801051c1:	e8 8e b3 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801051c6:	8b 45 08             	mov    0x8(%ebp),%eax
801051c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801051da:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801051df:	8b 45 08             	mov    0x8(%ebp),%eax
801051e2:	8b 55 08             	mov    0x8(%ebp),%edx
801051e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801051eb:	e8 f4 00 00 00       	call   801052e4 <popcli>
}
801051f0:	c9                   	leave  
801051f1:	c3                   	ret    

801051f2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801051f2:	55                   	push   %ebp
801051f3:	89 e5                	mov    %esp,%ebp
801051f5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801051f8:	8b 45 08             	mov    0x8(%ebp),%eax
801051fb:	83 e8 08             	sub    $0x8,%eax
801051fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105201:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105208:	eb 37                	jmp    80105241 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010520a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010520e:	74 37                	je     80105247 <getcallerpcs+0x55>
80105210:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105217:	76 2e                	jbe    80105247 <getcallerpcs+0x55>
80105219:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010521d:	74 28                	je     80105247 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010521f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105222:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105229:	8b 45 0c             	mov    0xc(%ebp),%eax
8010522c:	01 c2                	add    %eax,%edx
8010522e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105231:	8b 40 04             	mov    0x4(%eax),%eax
80105234:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105236:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105239:	8b 00                	mov    (%eax),%eax
8010523b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010523e:	ff 45 f8             	incl   -0x8(%ebp)
80105241:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105245:	7e c3                	jle    8010520a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105247:	eb 18                	jmp    80105261 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105249:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010524c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105253:	8b 45 0c             	mov    0xc(%ebp),%eax
80105256:	01 d0                	add    %edx,%eax
80105258:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010525e:	ff 45 f8             	incl   -0x8(%ebp)
80105261:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105265:	7e e2                	jle    80105249 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105267:	c9                   	leave  
80105268:	c3                   	ret    

80105269 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105269:	55                   	push   %ebp
8010526a:	89 e5                	mov    %esp,%ebp
8010526c:	53                   	push   %ebx
8010526d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105270:	8b 45 08             	mov    0x8(%ebp),%eax
80105273:	8b 00                	mov    (%eax),%eax
80105275:	85 c0                	test   %eax,%eax
80105277:	74 16                	je     8010528f <holding+0x26>
80105279:	8b 45 08             	mov    0x8(%ebp),%eax
8010527c:	8b 58 08             	mov    0x8(%eax),%ebx
8010527f:	e8 2b f0 ff ff       	call   801042af <mycpu>
80105284:	39 c3                	cmp    %eax,%ebx
80105286:	75 07                	jne    8010528f <holding+0x26>
80105288:	b8 01 00 00 00       	mov    $0x1,%eax
8010528d:	eb 05                	jmp    80105294 <holding+0x2b>
8010528f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105294:	83 c4 04             	add    $0x4,%esp
80105297:	5b                   	pop    %ebx
80105298:	5d                   	pop    %ebp
80105299:	c3                   	ret    

8010529a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010529a:	55                   	push   %ebp
8010529b:	89 e5                	mov    %esp,%ebp
8010529d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801052a0:	e8 3f fe ff ff       	call   801050e4 <readeflags>
801052a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801052a8:	e8 47 fe ff ff       	call   801050f4 <cli>
  if(mycpu()->ncli == 0)
801052ad:	e8 fd ef ff ff       	call   801042af <mycpu>
801052b2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052b8:	85 c0                	test   %eax,%eax
801052ba:	75 14                	jne    801052d0 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801052bc:	e8 ee ef ff ff       	call   801042af <mycpu>
801052c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052c4:	81 e2 00 02 00 00    	and    $0x200,%edx
801052ca:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801052d0:	e8 da ef ff ff       	call   801042af <mycpu>
801052d5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801052db:	42                   	inc    %edx
801052dc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801052e2:	c9                   	leave  
801052e3:	c3                   	ret    

801052e4 <popcli>:

void
popcli(void)
{
801052e4:	55                   	push   %ebp
801052e5:	89 e5                	mov    %esp,%ebp
801052e7:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801052ea:	e8 f5 fd ff ff       	call   801050e4 <readeflags>
801052ef:	25 00 02 00 00       	and    $0x200,%eax
801052f4:	85 c0                	test   %eax,%eax
801052f6:	74 0c                	je     80105304 <popcli+0x20>
    panic("popcli - interruptible");
801052f8:	c7 04 24 cb 93 10 80 	movl   $0x801093cb,(%esp)
801052ff:	e8 50 b2 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105304:	e8 a6 ef ff ff       	call   801042af <mycpu>
80105309:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010530f:	4a                   	dec    %edx
80105310:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105316:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010531c:	85 c0                	test   %eax,%eax
8010531e:	79 0c                	jns    8010532c <popcli+0x48>
    panic("popcli");
80105320:	c7 04 24 e2 93 10 80 	movl   $0x801093e2,(%esp)
80105327:	e8 28 b2 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010532c:	e8 7e ef ff ff       	call   801042af <mycpu>
80105331:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105337:	85 c0                	test   %eax,%eax
80105339:	75 14                	jne    8010534f <popcli+0x6b>
8010533b:	e8 6f ef ff ff       	call   801042af <mycpu>
80105340:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105346:	85 c0                	test   %eax,%eax
80105348:	74 05                	je     8010534f <popcli+0x6b>
    sti();
8010534a:	e8 ab fd ff ff       	call   801050fa <sti>
}
8010534f:	c9                   	leave  
80105350:	c3                   	ret    
80105351:	00 00                	add    %al,(%eax)
	...

80105354 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105354:	55                   	push   %ebp
80105355:	89 e5                	mov    %esp,%ebp
80105357:	57                   	push   %edi
80105358:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105359:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010535c:	8b 55 10             	mov    0x10(%ebp),%edx
8010535f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105362:	89 cb                	mov    %ecx,%ebx
80105364:	89 df                	mov    %ebx,%edi
80105366:	89 d1                	mov    %edx,%ecx
80105368:	fc                   	cld    
80105369:	f3 aa                	rep stos %al,%es:(%edi)
8010536b:	89 ca                	mov    %ecx,%edx
8010536d:	89 fb                	mov    %edi,%ebx
8010536f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105372:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105375:	5b                   	pop    %ebx
80105376:	5f                   	pop    %edi
80105377:	5d                   	pop    %ebp
80105378:	c3                   	ret    

80105379 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105379:	55                   	push   %ebp
8010537a:	89 e5                	mov    %esp,%ebp
8010537c:	57                   	push   %edi
8010537d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010537e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105381:	8b 55 10             	mov    0x10(%ebp),%edx
80105384:	8b 45 0c             	mov    0xc(%ebp),%eax
80105387:	89 cb                	mov    %ecx,%ebx
80105389:	89 df                	mov    %ebx,%edi
8010538b:	89 d1                	mov    %edx,%ecx
8010538d:	fc                   	cld    
8010538e:	f3 ab                	rep stos %eax,%es:(%edi)
80105390:	89 ca                	mov    %ecx,%edx
80105392:	89 fb                	mov    %edi,%ebx
80105394:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105397:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010539a:	5b                   	pop    %ebx
8010539b:	5f                   	pop    %edi
8010539c:	5d                   	pop    %ebp
8010539d:	c3                   	ret    

8010539e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010539e:	55                   	push   %ebp
8010539f:	89 e5                	mov    %esp,%ebp
801053a1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801053a4:	8b 45 08             	mov    0x8(%ebp),%eax
801053a7:	83 e0 03             	and    $0x3,%eax
801053aa:	85 c0                	test   %eax,%eax
801053ac:	75 49                	jne    801053f7 <memset+0x59>
801053ae:	8b 45 10             	mov    0x10(%ebp),%eax
801053b1:	83 e0 03             	and    $0x3,%eax
801053b4:	85 c0                	test   %eax,%eax
801053b6:	75 3f                	jne    801053f7 <memset+0x59>
    c &= 0xFF;
801053b8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801053bf:	8b 45 10             	mov    0x10(%ebp),%eax
801053c2:	c1 e8 02             	shr    $0x2,%eax
801053c5:	89 c2                	mov    %eax,%edx
801053c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ca:	c1 e0 18             	shl    $0x18,%eax
801053cd:	89 c1                	mov    %eax,%ecx
801053cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d2:	c1 e0 10             	shl    $0x10,%eax
801053d5:	09 c1                	or     %eax,%ecx
801053d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053da:	c1 e0 08             	shl    $0x8,%eax
801053dd:	09 c8                	or     %ecx,%eax
801053df:	0b 45 0c             	or     0xc(%ebp),%eax
801053e2:	89 54 24 08          	mov    %edx,0x8(%esp)
801053e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801053ea:	8b 45 08             	mov    0x8(%ebp),%eax
801053ed:	89 04 24             	mov    %eax,(%esp)
801053f0:	e8 84 ff ff ff       	call   80105379 <stosl>
801053f5:	eb 19                	jmp    80105410 <memset+0x72>
  } else
    stosb(dst, c, n);
801053f7:	8b 45 10             	mov    0x10(%ebp),%eax
801053fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801053fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105401:	89 44 24 04          	mov    %eax,0x4(%esp)
80105405:	8b 45 08             	mov    0x8(%ebp),%eax
80105408:	89 04 24             	mov    %eax,(%esp)
8010540b:	e8 44 ff ff ff       	call   80105354 <stosb>
  return dst;
80105410:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105413:	c9                   	leave  
80105414:	c3                   	ret    

80105415 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105415:	55                   	push   %ebp
80105416:	89 e5                	mov    %esp,%ebp
80105418:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010541b:	8b 45 08             	mov    0x8(%ebp),%eax
8010541e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105421:	8b 45 0c             	mov    0xc(%ebp),%eax
80105424:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105427:	eb 2a                	jmp    80105453 <memcmp+0x3e>
    if(*s1 != *s2)
80105429:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542c:	8a 10                	mov    (%eax),%dl
8010542e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105431:	8a 00                	mov    (%eax),%al
80105433:	38 c2                	cmp    %al,%dl
80105435:	74 16                	je     8010544d <memcmp+0x38>
      return *s1 - *s2;
80105437:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543a:	8a 00                	mov    (%eax),%al
8010543c:	0f b6 d0             	movzbl %al,%edx
8010543f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105442:	8a 00                	mov    (%eax),%al
80105444:	0f b6 c0             	movzbl %al,%eax
80105447:	29 c2                	sub    %eax,%edx
80105449:	89 d0                	mov    %edx,%eax
8010544b:	eb 18                	jmp    80105465 <memcmp+0x50>
    s1++, s2++;
8010544d:	ff 45 fc             	incl   -0x4(%ebp)
80105450:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105453:	8b 45 10             	mov    0x10(%ebp),%eax
80105456:	8d 50 ff             	lea    -0x1(%eax),%edx
80105459:	89 55 10             	mov    %edx,0x10(%ebp)
8010545c:	85 c0                	test   %eax,%eax
8010545e:	75 c9                	jne    80105429 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105460:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105465:	c9                   	leave  
80105466:	c3                   	ret    

80105467 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105467:	55                   	push   %ebp
80105468:	89 e5                	mov    %esp,%ebp
8010546a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010546d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105470:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105473:	8b 45 08             	mov    0x8(%ebp),%eax
80105476:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010547c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010547f:	73 3a                	jae    801054bb <memmove+0x54>
80105481:	8b 45 10             	mov    0x10(%ebp),%eax
80105484:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105487:	01 d0                	add    %edx,%eax
80105489:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010548c:	76 2d                	jbe    801054bb <memmove+0x54>
    s += n;
8010548e:	8b 45 10             	mov    0x10(%ebp),%eax
80105491:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105494:	8b 45 10             	mov    0x10(%ebp),%eax
80105497:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010549a:	eb 10                	jmp    801054ac <memmove+0x45>
      *--d = *--s;
8010549c:	ff 4d f8             	decl   -0x8(%ebp)
8010549f:	ff 4d fc             	decl   -0x4(%ebp)
801054a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054a5:	8a 10                	mov    (%eax),%dl
801054a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054aa:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801054ac:	8b 45 10             	mov    0x10(%ebp),%eax
801054af:	8d 50 ff             	lea    -0x1(%eax),%edx
801054b2:	89 55 10             	mov    %edx,0x10(%ebp)
801054b5:	85 c0                	test   %eax,%eax
801054b7:	75 e3                	jne    8010549c <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801054b9:	eb 25                	jmp    801054e0 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801054bb:	eb 16                	jmp    801054d3 <memmove+0x6c>
      *d++ = *s++;
801054bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054c0:	8d 50 01             	lea    0x1(%eax),%edx
801054c3:	89 55 f8             	mov    %edx,-0x8(%ebp)
801054c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054c9:	8d 4a 01             	lea    0x1(%edx),%ecx
801054cc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801054cf:	8a 12                	mov    (%edx),%dl
801054d1:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801054d3:	8b 45 10             	mov    0x10(%ebp),%eax
801054d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801054d9:	89 55 10             	mov    %edx,0x10(%ebp)
801054dc:	85 c0                	test   %eax,%eax
801054de:	75 dd                	jne    801054bd <memmove+0x56>
      *d++ = *s++;

  return dst;
801054e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054e3:	c9                   	leave  
801054e4:	c3                   	ret    

801054e5 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801054e5:	55                   	push   %ebp
801054e6:	89 e5                	mov    %esp,%ebp
801054e8:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801054eb:	8b 45 10             	mov    0x10(%ebp),%eax
801054ee:	89 44 24 08          	mov    %eax,0x8(%esp)
801054f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f9:	8b 45 08             	mov    0x8(%ebp),%eax
801054fc:	89 04 24             	mov    %eax,(%esp)
801054ff:	e8 63 ff ff ff       	call   80105467 <memmove>
}
80105504:	c9                   	leave  
80105505:	c3                   	ret    

80105506 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105506:	55                   	push   %ebp
80105507:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105509:	eb 09                	jmp    80105514 <strncmp+0xe>
    n--, p++, q++;
8010550b:	ff 4d 10             	decl   0x10(%ebp)
8010550e:	ff 45 08             	incl   0x8(%ebp)
80105511:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105514:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105518:	74 17                	je     80105531 <strncmp+0x2b>
8010551a:	8b 45 08             	mov    0x8(%ebp),%eax
8010551d:	8a 00                	mov    (%eax),%al
8010551f:	84 c0                	test   %al,%al
80105521:	74 0e                	je     80105531 <strncmp+0x2b>
80105523:	8b 45 08             	mov    0x8(%ebp),%eax
80105526:	8a 10                	mov    (%eax),%dl
80105528:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552b:	8a 00                	mov    (%eax),%al
8010552d:	38 c2                	cmp    %al,%dl
8010552f:	74 da                	je     8010550b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105531:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105535:	75 07                	jne    8010553e <strncmp+0x38>
    return 0;
80105537:	b8 00 00 00 00       	mov    $0x0,%eax
8010553c:	eb 14                	jmp    80105552 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010553e:	8b 45 08             	mov    0x8(%ebp),%eax
80105541:	8a 00                	mov    (%eax),%al
80105543:	0f b6 d0             	movzbl %al,%edx
80105546:	8b 45 0c             	mov    0xc(%ebp),%eax
80105549:	8a 00                	mov    (%eax),%al
8010554b:	0f b6 c0             	movzbl %al,%eax
8010554e:	29 c2                	sub    %eax,%edx
80105550:	89 d0                	mov    %edx,%eax
}
80105552:	5d                   	pop    %ebp
80105553:	c3                   	ret    

80105554 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105554:	55                   	push   %ebp
80105555:	89 e5                	mov    %esp,%ebp
80105557:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010555a:	8b 45 08             	mov    0x8(%ebp),%eax
8010555d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105560:	90                   	nop
80105561:	8b 45 10             	mov    0x10(%ebp),%eax
80105564:	8d 50 ff             	lea    -0x1(%eax),%edx
80105567:	89 55 10             	mov    %edx,0x10(%ebp)
8010556a:	85 c0                	test   %eax,%eax
8010556c:	7e 1c                	jle    8010558a <strncpy+0x36>
8010556e:	8b 45 08             	mov    0x8(%ebp),%eax
80105571:	8d 50 01             	lea    0x1(%eax),%edx
80105574:	89 55 08             	mov    %edx,0x8(%ebp)
80105577:	8b 55 0c             	mov    0xc(%ebp),%edx
8010557a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010557d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105580:	8a 12                	mov    (%edx),%dl
80105582:	88 10                	mov    %dl,(%eax)
80105584:	8a 00                	mov    (%eax),%al
80105586:	84 c0                	test   %al,%al
80105588:	75 d7                	jne    80105561 <strncpy+0xd>
    ;
  while(n-- > 0)
8010558a:	eb 0c                	jmp    80105598 <strncpy+0x44>
    *s++ = 0;
8010558c:	8b 45 08             	mov    0x8(%ebp),%eax
8010558f:	8d 50 01             	lea    0x1(%eax),%edx
80105592:	89 55 08             	mov    %edx,0x8(%ebp)
80105595:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105598:	8b 45 10             	mov    0x10(%ebp),%eax
8010559b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010559e:	89 55 10             	mov    %edx,0x10(%ebp)
801055a1:	85 c0                	test   %eax,%eax
801055a3:	7f e7                	jg     8010558c <strncpy+0x38>
    *s++ = 0;
  return os;
801055a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055a8:	c9                   	leave  
801055a9:	c3                   	ret    

801055aa <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055aa:	55                   	push   %ebp
801055ab:	89 e5                	mov    %esp,%ebp
801055ad:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801055b0:	8b 45 08             	mov    0x8(%ebp),%eax
801055b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ba:	7f 05                	jg     801055c1 <safestrcpy+0x17>
    return os;
801055bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055bf:	eb 2e                	jmp    801055ef <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801055c1:	ff 4d 10             	decl   0x10(%ebp)
801055c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055c8:	7e 1c                	jle    801055e6 <safestrcpy+0x3c>
801055ca:	8b 45 08             	mov    0x8(%ebp),%eax
801055cd:	8d 50 01             	lea    0x1(%eax),%edx
801055d0:	89 55 08             	mov    %edx,0x8(%ebp)
801055d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801055d6:	8d 4a 01             	lea    0x1(%edx),%ecx
801055d9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055dc:	8a 12                	mov    (%edx),%dl
801055de:	88 10                	mov    %dl,(%eax)
801055e0:	8a 00                	mov    (%eax),%al
801055e2:	84 c0                	test   %al,%al
801055e4:	75 db                	jne    801055c1 <safestrcpy+0x17>
    ;
  *s = 0;
801055e6:	8b 45 08             	mov    0x8(%ebp),%eax
801055e9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801055ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055ef:	c9                   	leave  
801055f0:	c3                   	ret    

801055f1 <strlen>:

int
strlen(const char *s)
{
801055f1:	55                   	push   %ebp
801055f2:	89 e5                	mov    %esp,%ebp
801055f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055fe:	eb 03                	jmp    80105603 <strlen+0x12>
80105600:	ff 45 fc             	incl   -0x4(%ebp)
80105603:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	01 d0                	add    %edx,%eax
8010560b:	8a 00                	mov    (%eax),%al
8010560d:	84 c0                	test   %al,%al
8010560f:	75 ef                	jne    80105600 <strlen+0xf>
    ;
  return n;
80105611:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105614:	c9                   	leave  
80105615:	c3                   	ret    
	...

80105618 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105618:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010561c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105620:	55                   	push   %ebp
  pushl %ebx
80105621:	53                   	push   %ebx
  pushl %esi
80105622:	56                   	push   %esi
  pushl %edi
80105623:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105624:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105626:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105628:	5f                   	pop    %edi
  popl %esi
80105629:	5e                   	pop    %esi
  popl %ebx
8010562a:	5b                   	pop    %ebx
  popl %ebp
8010562b:	5d                   	pop    %ebp
  ret
8010562c:	c3                   	ret    
8010562d:	00 00                	add    %al,(%eax)
	...

80105630 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105630:	55                   	push   %ebp
80105631:	89 e5                	mov    %esp,%ebp
80105633:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105636:	e8 f8 ec ff ff       	call   80104333 <myproc>
8010563b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010563e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105641:	8b 00                	mov    (%eax),%eax
80105643:	3b 45 08             	cmp    0x8(%ebp),%eax
80105646:	76 0f                	jbe    80105657 <fetchint+0x27>
80105648:	8b 45 08             	mov    0x8(%ebp),%eax
8010564b:	8d 50 04             	lea    0x4(%eax),%edx
8010564e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105651:	8b 00                	mov    (%eax),%eax
80105653:	39 c2                	cmp    %eax,%edx
80105655:	76 07                	jbe    8010565e <fetchint+0x2e>
    return -1;
80105657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565c:	eb 0f                	jmp    8010566d <fetchint+0x3d>
  *ip = *(int*)(addr);
8010565e:	8b 45 08             	mov    0x8(%ebp),%eax
80105661:	8b 10                	mov    (%eax),%edx
80105663:	8b 45 0c             	mov    0xc(%ebp),%eax
80105666:	89 10                	mov    %edx,(%eax)
  return 0;
80105668:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566d:	c9                   	leave  
8010566e:	c3                   	ret    

8010566f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105675:	e8 b9 ec ff ff       	call   80104333 <myproc>
8010567a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010567d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105680:	8b 00                	mov    (%eax),%eax
80105682:	3b 45 08             	cmp    0x8(%ebp),%eax
80105685:	77 07                	ja     8010568e <fetchstr+0x1f>
    return -1;
80105687:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568c:	eb 41                	jmp    801056cf <fetchstr+0x60>
  *pp = (char*)addr;
8010568e:	8b 55 08             	mov    0x8(%ebp),%edx
80105691:	8b 45 0c             	mov    0xc(%ebp),%eax
80105694:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105699:	8b 00                	mov    (%eax),%eax
8010569b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010569e:	8b 45 0c             	mov    0xc(%ebp),%eax
801056a1:	8b 00                	mov    (%eax),%eax
801056a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056a6:	eb 1a                	jmp    801056c2 <fetchstr+0x53>
    if(*s == 0)
801056a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ab:	8a 00                	mov    (%eax),%al
801056ad:	84 c0                	test   %al,%al
801056af:	75 0e                	jne    801056bf <fetchstr+0x50>
      return s - *pp;
801056b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b7:	8b 00                	mov    (%eax),%eax
801056b9:	29 c2                	sub    %eax,%edx
801056bb:	89 d0                	mov    %edx,%eax
801056bd:	eb 10                	jmp    801056cf <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801056bf:	ff 45 f4             	incl   -0xc(%ebp)
801056c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801056c8:	72 de                	jb     801056a8 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801056ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056cf:	c9                   	leave  
801056d0:	c3                   	ret    

801056d1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801056d1:	55                   	push   %ebp
801056d2:	89 e5                	mov    %esp,%ebp
801056d4:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801056d7:	e8 57 ec ff ff       	call   80104333 <myproc>
801056dc:	8b 40 18             	mov    0x18(%eax),%eax
801056df:	8b 50 44             	mov    0x44(%eax),%edx
801056e2:	8b 45 08             	mov    0x8(%ebp),%eax
801056e5:	c1 e0 02             	shl    $0x2,%eax
801056e8:	01 d0                	add    %edx,%eax
801056ea:	8d 50 04             	lea    0x4(%eax),%edx
801056ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f4:	89 14 24             	mov    %edx,(%esp)
801056f7:	e8 34 ff ff ff       	call   80105630 <fetchint>
}
801056fc:	c9                   	leave  
801056fd:	c3                   	ret    

801056fe <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056fe:	55                   	push   %ebp
801056ff:	89 e5                	mov    %esp,%ebp
80105701:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105704:	e8 2a ec ff ff       	call   80104333 <myproc>
80105709:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010570c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010570f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105713:	8b 45 08             	mov    0x8(%ebp),%eax
80105716:	89 04 24             	mov    %eax,(%esp)
80105719:	e8 b3 ff ff ff       	call   801056d1 <argint>
8010571e:	85 c0                	test   %eax,%eax
80105720:	79 07                	jns    80105729 <argptr+0x2b>
    return -1;
80105722:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105727:	eb 3d                	jmp    80105766 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105729:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010572d:	78 21                	js     80105750 <argptr+0x52>
8010572f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105732:	89 c2                	mov    %eax,%edx
80105734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105737:	8b 00                	mov    (%eax),%eax
80105739:	39 c2                	cmp    %eax,%edx
8010573b:	73 13                	jae    80105750 <argptr+0x52>
8010573d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105740:	89 c2                	mov    %eax,%edx
80105742:	8b 45 10             	mov    0x10(%ebp),%eax
80105745:	01 c2                	add    %eax,%edx
80105747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574a:	8b 00                	mov    (%eax),%eax
8010574c:	39 c2                	cmp    %eax,%edx
8010574e:	76 07                	jbe    80105757 <argptr+0x59>
    return -1;
80105750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105755:	eb 0f                	jmp    80105766 <argptr+0x68>
  *pp = (char*)i;
80105757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575a:	89 c2                	mov    %eax,%edx
8010575c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575f:	89 10                	mov    %edx,(%eax)
  return 0;
80105761:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105766:	c9                   	leave  
80105767:	c3                   	ret    

80105768 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105768:	55                   	push   %ebp
80105769:	89 e5                	mov    %esp,%ebp
8010576b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010576e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105771:	89 44 24 04          	mov    %eax,0x4(%esp)
80105775:	8b 45 08             	mov    0x8(%ebp),%eax
80105778:	89 04 24             	mov    %eax,(%esp)
8010577b:	e8 51 ff ff ff       	call   801056d1 <argint>
80105780:	85 c0                	test   %eax,%eax
80105782:	79 07                	jns    8010578b <argstr+0x23>
    return -1;
80105784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105789:	eb 12                	jmp    8010579d <argstr+0x35>
  return fetchstr(addr, pp);
8010578b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105791:	89 54 24 04          	mov    %edx,0x4(%esp)
80105795:	89 04 24             	mov    %eax,(%esp)
80105798:	e8 d2 fe ff ff       	call   8010566f <fetchstr>
}
8010579d:	c9                   	leave  
8010579e:	c3                   	ret    

8010579f <syscall>:
[SYS_reduce_curr_mem] sys_reduce_curr_mem,
};

void
syscall(void)
{
8010579f:	55                   	push   %ebp
801057a0:	89 e5                	mov    %esp,%ebp
801057a2:	53                   	push   %ebx
801057a3:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801057a6:	e8 88 eb ff ff       	call   80104333 <myproc>
801057ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801057ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b1:	8b 40 18             	mov    0x18(%eax),%eax
801057b4:	8b 40 1c             	mov    0x1c(%eax),%eax
801057b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801057ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057be:	7e 2d                	jle    801057ed <syscall+0x4e>
801057c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c3:	83 f8 2a             	cmp    $0x2a,%eax
801057c6:	77 25                	ja     801057ed <syscall+0x4e>
801057c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057cb:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801057d2:	85 c0                	test   %eax,%eax
801057d4:	74 17                	je     801057ed <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801057d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d9:	8b 58 18             	mov    0x18(%eax),%ebx
801057dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057df:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801057e6:	ff d0                	call   *%eax
801057e8:	89 43 1c             	mov    %eax,0x1c(%ebx)
801057eb:	eb 34                	jmp    80105821 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801057ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f0:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801057f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f6:	8b 40 10             	mov    0x10(%eax),%eax
801057f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105800:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105804:	89 44 24 04          	mov    %eax,0x4(%esp)
80105808:	c7 04 24 e9 93 10 80 	movl   $0x801093e9,(%esp)
8010580f:	e8 ad ab ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105817:	8b 40 18             	mov    0x18(%eax),%eax
8010581a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105821:	83 c4 24             	add    $0x24,%esp
80105824:	5b                   	pop    %ebx
80105825:	5d                   	pop    %ebp
80105826:	c3                   	ret    
	...

80105828 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105828:	55                   	push   %ebp
80105829:	89 e5                	mov    %esp,%ebp
8010582b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010582e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105831:	89 44 24 04          	mov    %eax,0x4(%esp)
80105835:	8b 45 08             	mov    0x8(%ebp),%eax
80105838:	89 04 24             	mov    %eax,(%esp)
8010583b:	e8 91 fe ff ff       	call   801056d1 <argint>
80105840:	85 c0                	test   %eax,%eax
80105842:	79 07                	jns    8010584b <argfd+0x23>
    return -1;
80105844:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105849:	eb 4f                	jmp    8010589a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010584b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584e:	85 c0                	test   %eax,%eax
80105850:	78 20                	js     80105872 <argfd+0x4a>
80105852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105855:	83 f8 0f             	cmp    $0xf,%eax
80105858:	7f 18                	jg     80105872 <argfd+0x4a>
8010585a:	e8 d4 ea ff ff       	call   80104333 <myproc>
8010585f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105862:	83 c2 08             	add    $0x8,%edx
80105865:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105869:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010586c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105870:	75 07                	jne    80105879 <argfd+0x51>
    return -1;
80105872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105877:	eb 21                	jmp    8010589a <argfd+0x72>
  if(pfd)
80105879:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010587d:	74 08                	je     80105887 <argfd+0x5f>
    *pfd = fd;
8010587f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105882:	8b 45 0c             	mov    0xc(%ebp),%eax
80105885:	89 10                	mov    %edx,(%eax)
  if(pf)
80105887:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010588b:	74 08                	je     80105895 <argfd+0x6d>
    *pf = f;
8010588d:	8b 45 10             	mov    0x10(%ebp),%eax
80105890:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105893:	89 10                	mov    %edx,(%eax)
  return 0;
80105895:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010589a:	c9                   	leave  
8010589b:	c3                   	ret    

8010589c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010589c:	55                   	push   %ebp
8010589d:	89 e5                	mov    %esp,%ebp
8010589f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801058a2:	e8 8c ea ff ff       	call   80104333 <myproc>
801058a7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801058aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058b1:	eb 29                	jmp    801058dc <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b9:	83 c2 08             	add    $0x8,%edx
801058bc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058c0:	85 c0                	test   %eax,%eax
801058c2:	75 15                	jne    801058d9 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801058c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058ca:	8d 4a 08             	lea    0x8(%edx),%ecx
801058cd:	8b 55 08             	mov    0x8(%ebp),%edx
801058d0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801058d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d7:	eb 0e                	jmp    801058e7 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801058d9:	ff 45 f4             	incl   -0xc(%ebp)
801058dc:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801058e0:	7e d1                	jle    801058b3 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801058e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058e7:	c9                   	leave  
801058e8:	c3                   	ret    

801058e9 <sys_dup>:

int
sys_dup(void)
{
801058e9:	55                   	push   %ebp
801058ea:	89 e5                	mov    %esp,%ebp
801058ec:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801058ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058f2:	89 44 24 08          	mov    %eax,0x8(%esp)
801058f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058fd:	00 
801058fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105905:	e8 1e ff ff ff       	call   80105828 <argfd>
8010590a:	85 c0                	test   %eax,%eax
8010590c:	79 07                	jns    80105915 <sys_dup+0x2c>
    return -1;
8010590e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105913:	eb 29                	jmp    8010593e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105918:	89 04 24             	mov    %eax,(%esp)
8010591b:	e8 7c ff ff ff       	call   8010589c <fdalloc>
80105920:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105923:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105927:	79 07                	jns    80105930 <sys_dup+0x47>
    return -1;
80105929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592e:	eb 0e                	jmp    8010593e <sys_dup+0x55>
  filedup(f);
80105930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105933:	89 04 24             	mov    %eax,(%esp)
80105936:	e8 27 b8 ff ff       	call   80101162 <filedup>
  return fd;
8010593b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010593e:	c9                   	leave  
8010593f:	c3                   	ret    

80105940 <sys_read>:

int
sys_read(void)
{
80105940:	55                   	push   %ebp
80105941:	89 e5                	mov    %esp,%ebp
80105943:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105946:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105949:	89 44 24 08          	mov    %eax,0x8(%esp)
8010594d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105954:	00 
80105955:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010595c:	e8 c7 fe ff ff       	call   80105828 <argfd>
80105961:	85 c0                	test   %eax,%eax
80105963:	78 35                	js     8010599a <sys_read+0x5a>
80105965:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105968:	89 44 24 04          	mov    %eax,0x4(%esp)
8010596c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105973:	e8 59 fd ff ff       	call   801056d1 <argint>
80105978:	85 c0                	test   %eax,%eax
8010597a:	78 1e                	js     8010599a <sys_read+0x5a>
8010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105983:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105986:	89 44 24 04          	mov    %eax,0x4(%esp)
8010598a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105991:	e8 68 fd ff ff       	call   801056fe <argptr>
80105996:	85 c0                	test   %eax,%eax
80105998:	79 07                	jns    801059a1 <sys_read+0x61>
    return -1;
8010599a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599f:	eb 19                	jmp    801059ba <sys_read+0x7a>
  return fileread(f, p, n);
801059a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801059b2:	89 04 24             	mov    %eax,(%esp)
801059b5:	e8 09 b9 ff ff       	call   801012c3 <fileread>
}
801059ba:	c9                   	leave  
801059bb:	c3                   	ret    

801059bc <sys_write>:

int
sys_write(void)
{
801059bc:	55                   	push   %ebp
801059bd:	89 e5                	mov    %esp,%ebp
801059bf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059c5:	89 44 24 08          	mov    %eax,0x8(%esp)
801059c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059d0:	00 
801059d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059d8:	e8 4b fe ff ff       	call   80105828 <argfd>
801059dd:	85 c0                	test   %eax,%eax
801059df:	78 35                	js     80105a16 <sys_write+0x5a>
801059e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059ef:	e8 dd fc ff ff       	call   801056d1 <argint>
801059f4:	85 c0                	test   %eax,%eax
801059f6:	78 1e                	js     80105a16 <sys_write+0x5a>
801059f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a0d:	e8 ec fc ff ff       	call   801056fe <argptr>
80105a12:	85 c0                	test   %eax,%eax
80105a14:	79 07                	jns    80105a1d <sys_write+0x61>
    return -1;
80105a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1b:	eb 19                	jmp    80105a36 <sys_write+0x7a>
  return filewrite(f, p, n);
80105a1d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a2a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a2e:	89 04 24             	mov    %eax,(%esp)
80105a31:	e8 48 b9 ff ff       	call   8010137e <filewrite>
}
80105a36:	c9                   	leave  
80105a37:	c3                   	ret    

80105a38 <sys_close>:

int
sys_close(void)
{
80105a38:	55                   	push   %ebp
80105a39:	89 e5                	mov    %esp,%ebp
80105a3b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105a3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a41:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a45:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a53:	e8 d0 fd ff ff       	call   80105828 <argfd>
80105a58:	85 c0                	test   %eax,%eax
80105a5a:	79 07                	jns    80105a63 <sys_close+0x2b>
    return -1;
80105a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a61:	eb 23                	jmp    80105a86 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105a63:	e8 cb e8 ff ff       	call   80104333 <myproc>
80105a68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a6b:	83 c2 08             	add    $0x8,%edx
80105a6e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a75:	00 
  fileclose(f);
80105a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a79:	89 04 24             	mov    %eax,(%esp)
80105a7c:	e8 29 b7 ff ff       	call   801011aa <fileclose>
  return 0;
80105a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a86:	c9                   	leave  
80105a87:	c3                   	ret    

80105a88 <sys_fstat>:

int
sys_fstat(void)
{
80105a88:	55                   	push   %ebp
80105a89:	89 e5                	mov    %esp,%ebp
80105a8b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a91:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a9c:	00 
80105a9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105aa4:	e8 7f fd ff ff       	call   80105828 <argfd>
80105aa9:	85 c0                	test   %eax,%eax
80105aab:	78 1f                	js     80105acc <sys_fstat+0x44>
80105aad:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105ab4:	00 
80105ab5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105abc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ac3:	e8 36 fc ff ff       	call   801056fe <argptr>
80105ac8:	85 c0                	test   %eax,%eax
80105aca:	79 07                	jns    80105ad3 <sys_fstat+0x4b>
    return -1;
80105acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad1:	eb 12                	jmp    80105ae5 <sys_fstat+0x5d>
  return filestat(f, st);
80105ad3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105add:	89 04 24             	mov    %eax,(%esp)
80105ae0:	e8 8f b7 ff ff       	call   80101274 <filestat>
}
80105ae5:	c9                   	leave  
80105ae6:	c3                   	ret    

80105ae7 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ae7:	55                   	push   %ebp
80105ae8:	89 e5                	mov    %esp,%ebp
80105aea:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105aed:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105afb:	e8 68 fc ff ff       	call   80105768 <argstr>
80105b00:	85 c0                	test   %eax,%eax
80105b02:	78 17                	js     80105b1b <sys_link+0x34>
80105b04:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b07:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b12:	e8 51 fc ff ff       	call   80105768 <argstr>
80105b17:	85 c0                	test   %eax,%eax
80105b19:	79 0a                	jns    80105b25 <sys_link+0x3e>
    return -1;
80105b1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b20:	e9 3d 01 00 00       	jmp    80105c62 <sys_link+0x17b>

  begin_op();
80105b25:	e8 09 db ff ff       	call   80103633 <begin_op>
  if((ip = namei(old)) == 0){
80105b2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b2d:	89 04 24             	mov    %eax,(%esp)
80105b30:	e8 b2 ca ff ff       	call   801025e7 <namei>
80105b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b3c:	75 0f                	jne    80105b4d <sys_link+0x66>
    end_op();
80105b3e:	e8 72 db ff ff       	call   801036b5 <end_op>
    return -1;
80105b43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b48:	e9 15 01 00 00       	jmp    80105c62 <sys_link+0x17b>
  }

  ilock(ip);
80105b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b50:	89 04 24             	mov    %eax,(%esp)
80105b53:	e8 6a bf ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5b:	8b 40 50             	mov    0x50(%eax),%eax
80105b5e:	66 83 f8 01          	cmp    $0x1,%ax
80105b62:	75 1a                	jne    80105b7e <sys_link+0x97>
    iunlockput(ip);
80105b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b67:	89 04 24             	mov    %eax,(%esp)
80105b6a:	e8 52 c1 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105b6f:	e8 41 db ff ff       	call   801036b5 <end_op>
    return -1;
80105b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b79:	e9 e4 00 00 00       	jmp    80105c62 <sys_link+0x17b>
  }

  ip->nlink++;
80105b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b81:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b85:	40                   	inc    %eax
80105b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b89:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b90:	89 04 24             	mov    %eax,(%esp)
80105b93:	e8 67 bd ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9b:	89 04 24             	mov    %eax,(%esp)
80105b9e:	e8 29 c0 ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105ba3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ba6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ba9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bad:	89 04 24             	mov    %eax,(%esp)
80105bb0:	e8 54 ca ff ff       	call   80102609 <nameiparent>
80105bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bb8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bbc:	75 02                	jne    80105bc0 <sys_link+0xd9>
    goto bad;
80105bbe:	eb 68                	jmp    80105c28 <sys_link+0x141>
  ilock(dp);
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	89 04 24             	mov    %eax,(%esp)
80105bc6:	e8 f7 be ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bce:	8b 10                	mov    (%eax),%edx
80105bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd3:	8b 00                	mov    (%eax),%eax
80105bd5:	39 c2                	cmp    %eax,%edx
80105bd7:	75 20                	jne    80105bf9 <sys_link+0x112>
80105bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdc:	8b 40 04             	mov    0x4(%eax),%eax
80105bdf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105be3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105be6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bed:	89 04 24             	mov    %eax,(%esp)
80105bf0:	e8 3f c7 ff ff       	call   80102334 <dirlink>
80105bf5:	85 c0                	test   %eax,%eax
80105bf7:	79 0d                	jns    80105c06 <sys_link+0x11f>
    iunlockput(dp);
80105bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfc:	89 04 24             	mov    %eax,(%esp)
80105bff:	e8 bd c0 ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105c04:	eb 22                	jmp    80105c28 <sys_link+0x141>
  }
  iunlockput(dp);
80105c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c09:	89 04 24             	mov    %eax,(%esp)
80105c0c:	e8 b0 c0 ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c14:	89 04 24             	mov    %eax,(%esp)
80105c17:	e8 f4 bf ff ff       	call   80101c10 <iput>

  end_op();
80105c1c:	e8 94 da ff ff       	call   801036b5 <end_op>

  return 0;
80105c21:	b8 00 00 00 00       	mov    $0x0,%eax
80105c26:	eb 3a                	jmp    80105c62 <sys_link+0x17b>

bad:
  ilock(ip);
80105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2b:	89 04 24             	mov    %eax,(%esp)
80105c2e:	e8 8f be ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c36:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c3a:	48                   	dec    %eax
80105c3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c3e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c45:	89 04 24             	mov    %eax,(%esp)
80105c48:	e8 b2 bc ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c50:	89 04 24             	mov    %eax,(%esp)
80105c53:	e8 69 c0 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105c58:	e8 58 da ff ff       	call   801036b5 <end_op>
  return -1;
80105c5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c62:	c9                   	leave  
80105c63:	c3                   	ret    

80105c64 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c64:	55                   	push   %ebp
80105c65:	89 e5                	mov    %esp,%ebp
80105c67:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c6a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c71:	eb 4a                	jmp    80105cbd <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c76:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c7d:	00 
80105c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c85:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c89:	8b 45 08             	mov    0x8(%ebp),%eax
80105c8c:	89 04 24             	mov    %eax,(%esp)
80105c8f:	e8 c5 c2 ff ff       	call   80101f59 <readi>
80105c94:	83 f8 10             	cmp    $0x10,%eax
80105c97:	74 0c                	je     80105ca5 <isdirempty+0x41>
      panic("isdirempty: readi");
80105c99:	c7 04 24 05 94 10 80 	movl   $0x80109405,(%esp)
80105ca0:	e8 af a8 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ca8:	66 85 c0             	test   %ax,%ax
80105cab:	74 07                	je     80105cb4 <isdirempty+0x50>
      return 0;
80105cad:	b8 00 00 00 00       	mov    $0x0,%eax
80105cb2:	eb 1b                	jmp    80105ccf <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb7:	83 c0 10             	add    $0x10,%eax
80105cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc3:	8b 40 58             	mov    0x58(%eax),%eax
80105cc6:	39 c2                	cmp    %eax,%edx
80105cc8:	72 a9                	jb     80105c73 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105cca:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ccf:	c9                   	leave  
80105cd0:	c3                   	ret    

80105cd1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105cd1:	55                   	push   %ebp
80105cd2:	89 e5                	mov    %esp,%ebp
80105cd4:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105cd7:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105cda:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ce5:	e8 7e fa ff ff       	call   80105768 <argstr>
80105cea:	85 c0                	test   %eax,%eax
80105cec:	79 0a                	jns    80105cf8 <sys_unlink+0x27>
    return -1;
80105cee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf3:	e9 a9 01 00 00       	jmp    80105ea1 <sys_unlink+0x1d0>

  begin_op();
80105cf8:	e8 36 d9 ff ff       	call   80103633 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105cfd:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d00:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d03:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d07:	89 04 24             	mov    %eax,(%esp)
80105d0a:	e8 fa c8 ff ff       	call   80102609 <nameiparent>
80105d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d16:	75 0f                	jne    80105d27 <sys_unlink+0x56>
    end_op();
80105d18:	e8 98 d9 ff ff       	call   801036b5 <end_op>
    return -1;
80105d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d22:	e9 7a 01 00 00       	jmp    80105ea1 <sys_unlink+0x1d0>
  }

  ilock(dp);
80105d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2a:	89 04 24             	mov    %eax,(%esp)
80105d2d:	e8 90 bd ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d32:	c7 44 24 04 17 94 10 	movl   $0x80109417,0x4(%esp)
80105d39:	80 
80105d3a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d3d:	89 04 24             	mov    %eax,(%esp)
80105d40:	e8 07 c5 ff ff       	call   8010224c <namecmp>
80105d45:	85 c0                	test   %eax,%eax
80105d47:	0f 84 3f 01 00 00    	je     80105e8c <sys_unlink+0x1bb>
80105d4d:	c7 44 24 04 19 94 10 	movl   $0x80109419,0x4(%esp)
80105d54:	80 
80105d55:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d58:	89 04 24             	mov    %eax,(%esp)
80105d5b:	e8 ec c4 ff ff       	call   8010224c <namecmp>
80105d60:	85 c0                	test   %eax,%eax
80105d62:	0f 84 24 01 00 00    	je     80105e8c <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d68:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d6b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d6f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d72:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d79:	89 04 24             	mov    %eax,(%esp)
80105d7c:	e8 ed c4 ff ff       	call   8010226e <dirlookup>
80105d81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d88:	75 05                	jne    80105d8f <sys_unlink+0xbe>
    goto bad;
80105d8a:	e9 fd 00 00 00       	jmp    80105e8c <sys_unlink+0x1bb>
  ilock(ip);
80105d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d92:	89 04 24             	mov    %eax,(%esp)
80105d95:	e8 28 bd ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
80105d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105da1:	66 85 c0             	test   %ax,%ax
80105da4:	7f 0c                	jg     80105db2 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105da6:	c7 04 24 1c 94 10 80 	movl   $0x8010941c,(%esp)
80105dad:	e8 a2 a7 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db5:	8b 40 50             	mov    0x50(%eax),%eax
80105db8:	66 83 f8 01          	cmp    $0x1,%ax
80105dbc:	75 1f                	jne    80105ddd <sys_unlink+0x10c>
80105dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc1:	89 04 24             	mov    %eax,(%esp)
80105dc4:	e8 9b fe ff ff       	call   80105c64 <isdirempty>
80105dc9:	85 c0                	test   %eax,%eax
80105dcb:	75 10                	jne    80105ddd <sys_unlink+0x10c>
    iunlockput(ip);
80105dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd0:	89 04 24             	mov    %eax,(%esp)
80105dd3:	e8 e9 be ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105dd8:	e9 af 00 00 00       	jmp    80105e8c <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105ddd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105de4:	00 
80105de5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105dec:	00 
80105ded:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105df0:	89 04 24             	mov    %eax,(%esp)
80105df3:	e8 a6 f5 ff ff       	call   8010539e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105df8:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105dfb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e02:	00 
80105e03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e07:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e11:	89 04 24             	mov    %eax,(%esp)
80105e14:	e8 a4 c2 ff ff       	call   801020bd <writei>
80105e19:	83 f8 10             	cmp    $0x10,%eax
80105e1c:	74 0c                	je     80105e2a <sys_unlink+0x159>
    panic("unlink: writei");
80105e1e:	c7 04 24 2e 94 10 80 	movl   $0x8010942e,(%esp)
80105e25:	e8 2a a7 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2d:	8b 40 50             	mov    0x50(%eax),%eax
80105e30:	66 83 f8 01          	cmp    $0x1,%ax
80105e34:	75 1a                	jne    80105e50 <sys_unlink+0x17f>
    dp->nlink--;
80105e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e39:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e3d:	48                   	dec    %eax
80105e3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e41:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e48:	89 04 24             	mov    %eax,(%esp)
80105e4b:	e8 af ba ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
80105e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e53:	89 04 24             	mov    %eax,(%esp)
80105e56:	e8 66 be ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
80105e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5e:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e62:	48                   	dec    %eax
80105e63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e66:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6d:	89 04 24             	mov    %eax,(%esp)
80105e70:	e8 8a ba ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e78:	89 04 24             	mov    %eax,(%esp)
80105e7b:	e8 41 be ff ff       	call   80101cc1 <iunlockput>

  end_op();
80105e80:	e8 30 d8 ff ff       	call   801036b5 <end_op>

  return 0;
80105e85:	b8 00 00 00 00       	mov    $0x0,%eax
80105e8a:	eb 15                	jmp    80105ea1 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8f:	89 04 24             	mov    %eax,(%esp)
80105e92:	e8 2a be ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105e97:	e8 19 d8 ff ff       	call   801036b5 <end_op>
  return -1;
80105e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ea1:	c9                   	leave  
80105ea2:	c3                   	ret    

80105ea3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ea3:	55                   	push   %ebp
80105ea4:	89 e5                	mov    %esp,%ebp
80105ea6:	83 ec 48             	sub    $0x48,%esp
80105ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105eac:	8b 55 10             	mov    0x10(%ebp),%edx
80105eaf:	8b 45 14             	mov    0x14(%ebp),%eax
80105eb2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105eb6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105eba:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ebe:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec8:	89 04 24             	mov    %eax,(%esp)
80105ecb:	e8 39 c7 ff ff       	call   80102609 <nameiparent>
80105ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ed3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ed7:	75 0a                	jne    80105ee3 <create+0x40>
    return 0;
80105ed9:	b8 00 00 00 00       	mov    $0x0,%eax
80105ede:	e9 79 01 00 00       	jmp    8010605c <create+0x1b9>
  ilock(dp);
80105ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee6:	89 04 24             	mov    %eax,(%esp)
80105ee9:	e8 d4 bb ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105eee:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ef1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ef5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	89 04 24             	mov    %eax,(%esp)
80105f02:	e8 67 c3 ff ff       	call   8010226e <dirlookup>
80105f07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f0e:	74 46                	je     80105f56 <create+0xb3>
    iunlockput(dp);
80105f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f13:	89 04 24             	mov    %eax,(%esp)
80105f16:	e8 a6 bd ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
80105f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1e:	89 04 24             	mov    %eax,(%esp)
80105f21:	e8 9c bb ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f26:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f2b:	75 14                	jne    80105f41 <create+0x9e>
80105f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f30:	8b 40 50             	mov    0x50(%eax),%eax
80105f33:	66 83 f8 02          	cmp    $0x2,%ax
80105f37:	75 08                	jne    80105f41 <create+0x9e>
      return ip;
80105f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f3c:	e9 1b 01 00 00       	jmp    8010605c <create+0x1b9>
    iunlockput(ip);
80105f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f44:	89 04 24             	mov    %eax,(%esp)
80105f47:	e8 75 bd ff ff       	call   80101cc1 <iunlockput>
    return 0;
80105f4c:	b8 00 00 00 00       	mov    $0x0,%eax
80105f51:	e9 06 01 00 00       	jmp    8010605c <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f56:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5d:	8b 00                	mov    (%eax),%eax
80105f5f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f63:	89 04 24             	mov    %eax,(%esp)
80105f66:	e8 c2 b8 ff ff       	call   8010182d <ialloc>
80105f6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f72:	75 0c                	jne    80105f80 <create+0xdd>
    panic("create: ialloc");
80105f74:	c7 04 24 3d 94 10 80 	movl   $0x8010943d,(%esp)
80105f7b:	e8 d4 a5 ff ff       	call   80100554 <panic>

  ilock(ip);
80105f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f83:	89 04 24             	mov    %eax,(%esp)
80105f86:	e8 37 bb ff ff       	call   80101ac2 <ilock>
  ip->major = major;
80105f8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f8e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105f91:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105f95:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f98:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f9b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fab:	89 04 24             	mov    %eax,(%esp)
80105fae:	e8 4c b9 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105fb3:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105fb8:	75 68                	jne    80106022 <create+0x17f>
    dp->nlink++;  // for ".."
80105fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbd:	66 8b 40 56          	mov    0x56(%eax),%ax
80105fc1:	40                   	inc    %eax
80105fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fc5:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcc:	89 04 24             	mov    %eax,(%esp)
80105fcf:	e8 2b b9 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd7:	8b 40 04             	mov    0x4(%eax),%eax
80105fda:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fde:	c7 44 24 04 17 94 10 	movl   $0x80109417,0x4(%esp)
80105fe5:	80 
80105fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe9:	89 04 24             	mov    %eax,(%esp)
80105fec:	e8 43 c3 ff ff       	call   80102334 <dirlink>
80105ff1:	85 c0                	test   %eax,%eax
80105ff3:	78 21                	js     80106016 <create+0x173>
80105ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff8:	8b 40 04             	mov    0x4(%eax),%eax
80105ffb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fff:	c7 44 24 04 19 94 10 	movl   $0x80109419,0x4(%esp)
80106006:	80 
80106007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600a:	89 04 24             	mov    %eax,(%esp)
8010600d:	e8 22 c3 ff ff       	call   80102334 <dirlink>
80106012:	85 c0                	test   %eax,%eax
80106014:	79 0c                	jns    80106022 <create+0x17f>
      panic("create dots");
80106016:	c7 04 24 4c 94 10 80 	movl   $0x8010944c,(%esp)
8010601d:	e8 32 a5 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106022:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106025:	8b 40 04             	mov    0x4(%eax),%eax
80106028:	89 44 24 08          	mov    %eax,0x8(%esp)
8010602c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010602f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106036:	89 04 24             	mov    %eax,(%esp)
80106039:	e8 f6 c2 ff ff       	call   80102334 <dirlink>
8010603e:	85 c0                	test   %eax,%eax
80106040:	79 0c                	jns    8010604e <create+0x1ab>
    panic("create: dirlink");
80106042:	c7 04 24 58 94 10 80 	movl   $0x80109458,(%esp)
80106049:	e8 06 a5 ff ff       	call   80100554 <panic>

  iunlockput(dp);
8010604e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106051:	89 04 24             	mov    %eax,(%esp)
80106054:	e8 68 bc ff ff       	call   80101cc1 <iunlockput>

  return ip;
80106059:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010605c:	c9                   	leave  
8010605d:	c3                   	ret    

8010605e <sys_open>:

int
sys_open(void)
{
8010605e:	55                   	push   %ebp
8010605f:	89 e5                	mov    %esp,%ebp
80106061:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106064:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106067:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106072:	e8 f1 f6 ff ff       	call   80105768 <argstr>
80106077:	85 c0                	test   %eax,%eax
80106079:	78 17                	js     80106092 <sys_open+0x34>
8010607b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010607e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106089:	e8 43 f6 ff ff       	call   801056d1 <argint>
8010608e:	85 c0                	test   %eax,%eax
80106090:	79 0a                	jns    8010609c <sys_open+0x3e>
    return -1;
80106092:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106097:	e9 64 01 00 00       	jmp    80106200 <sys_open+0x1a2>

  begin_op();
8010609c:	e8 92 d5 ff ff       	call   80103633 <begin_op>

  if(omode & O_CREATE){
801060a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060a4:	25 00 02 00 00       	and    $0x200,%eax
801060a9:	85 c0                	test   %eax,%eax
801060ab:	74 3b                	je     801060e8 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801060ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801060b7:	00 
801060b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801060bf:	00 
801060c0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801060c7:	00 
801060c8:	89 04 24             	mov    %eax,(%esp)
801060cb:	e8 d3 fd ff ff       	call   80105ea3 <create>
801060d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801060d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060d7:	75 6a                	jne    80106143 <sys_open+0xe5>
      end_op();
801060d9:	e8 d7 d5 ff ff       	call   801036b5 <end_op>
      return -1;
801060de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e3:	e9 18 01 00 00       	jmp    80106200 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
801060e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060eb:	89 04 24             	mov    %eax,(%esp)
801060ee:	e8 f4 c4 ff ff       	call   801025e7 <namei>
801060f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060fa:	75 0f                	jne    8010610b <sys_open+0xad>
      end_op();
801060fc:	e8 b4 d5 ff ff       	call   801036b5 <end_op>
      return -1;
80106101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106106:	e9 f5 00 00 00       	jmp    80106200 <sys_open+0x1a2>
    }
    ilock(ip);
8010610b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610e:	89 04 24             	mov    %eax,(%esp)
80106111:	e8 ac b9 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106119:	8b 40 50             	mov    0x50(%eax),%eax
8010611c:	66 83 f8 01          	cmp    $0x1,%ax
80106120:	75 21                	jne    80106143 <sys_open+0xe5>
80106122:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106125:	85 c0                	test   %eax,%eax
80106127:	74 1a                	je     80106143 <sys_open+0xe5>
      iunlockput(ip);
80106129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612c:	89 04 24             	mov    %eax,(%esp)
8010612f:	e8 8d bb ff ff       	call   80101cc1 <iunlockput>
      end_op();
80106134:	e8 7c d5 ff ff       	call   801036b5 <end_op>
      return -1;
80106139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613e:	e9 bd 00 00 00       	jmp    80106200 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106143:	e8 ba af ff ff       	call   80101102 <filealloc>
80106148:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010614b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010614f:	74 14                	je     80106165 <sys_open+0x107>
80106151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106154:	89 04 24             	mov    %eax,(%esp)
80106157:	e8 40 f7 ff ff       	call   8010589c <fdalloc>
8010615c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010615f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106163:	79 28                	jns    8010618d <sys_open+0x12f>
    if(f)
80106165:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106169:	74 0b                	je     80106176 <sys_open+0x118>
      fileclose(f);
8010616b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616e:	89 04 24             	mov    %eax,(%esp)
80106171:	e8 34 b0 ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106179:	89 04 24             	mov    %eax,(%esp)
8010617c:	e8 40 bb ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106181:	e8 2f d5 ff ff       	call   801036b5 <end_op>
    return -1;
80106186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618b:	eb 73                	jmp    80106200 <sys_open+0x1a2>
  }
  iunlock(ip);
8010618d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106190:	89 04 24             	mov    %eax,(%esp)
80106193:	e8 34 ba ff ff       	call   80101bcc <iunlock>
  end_op();
80106198:	e8 18 d5 ff ff       	call   801036b5 <end_op>

  f->type = FD_INODE;
8010619d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ac:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801061b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061bc:	83 e0 01             	and    $0x1,%eax
801061bf:	85 c0                	test   %eax,%eax
801061c1:	0f 94 c0             	sete   %al
801061c4:	88 c2                	mov    %al,%dl
801061c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801061cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061cf:	83 e0 01             	and    $0x1,%eax
801061d2:	85 c0                	test   %eax,%eax
801061d4:	75 0a                	jne    801061e0 <sys_open+0x182>
801061d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061d9:	83 e0 02             	and    $0x2,%eax
801061dc:	85 c0                	test   %eax,%eax
801061de:	74 07                	je     801061e7 <sys_open+0x189>
801061e0:	b8 01 00 00 00       	mov    $0x1,%eax
801061e5:	eb 05                	jmp    801061ec <sys_open+0x18e>
801061e7:	b8 00 00 00 00       	mov    $0x0,%eax
801061ec:	88 c2                	mov    %al,%dl
801061ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f1:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
801061f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801061f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fa:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
801061fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106200:	c9                   	leave  
80106201:	c3                   	ret    

80106202 <sys_mkdir>:

int
sys_mkdir(void)
{
80106202:	55                   	push   %ebp
80106203:	89 e5                	mov    %esp,%ebp
80106205:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106208:	e8 26 d4 ff ff       	call   80103633 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010620d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106210:	89 44 24 04          	mov    %eax,0x4(%esp)
80106214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010621b:	e8 48 f5 ff ff       	call   80105768 <argstr>
80106220:	85 c0                	test   %eax,%eax
80106222:	78 2c                	js     80106250 <sys_mkdir+0x4e>
80106224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106227:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010622e:	00 
8010622f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106236:	00 
80106237:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010623e:	00 
8010623f:	89 04 24             	mov    %eax,(%esp)
80106242:	e8 5c fc ff ff       	call   80105ea3 <create>
80106247:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010624a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010624e:	75 0c                	jne    8010625c <sys_mkdir+0x5a>
    end_op();
80106250:	e8 60 d4 ff ff       	call   801036b5 <end_op>
    return -1;
80106255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625a:	eb 15                	jmp    80106271 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625f:	89 04 24             	mov    %eax,(%esp)
80106262:	e8 5a ba ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106267:	e8 49 d4 ff ff       	call   801036b5 <end_op>
  return 0;
8010626c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106271:	c9                   	leave  
80106272:	c3                   	ret    

80106273 <sys_mknod>:

int
sys_mknod(void)
{
80106273:	55                   	push   %ebp
80106274:	89 e5                	mov    %esp,%ebp
80106276:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106279:	e8 b5 d3 ff ff       	call   80103633 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010627e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106281:	89 44 24 04          	mov    %eax,0x4(%esp)
80106285:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010628c:	e8 d7 f4 ff ff       	call   80105768 <argstr>
80106291:	85 c0                	test   %eax,%eax
80106293:	78 5e                	js     801062f3 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106295:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106298:	89 44 24 04          	mov    %eax,0x4(%esp)
8010629c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062a3:	e8 29 f4 ff ff       	call   801056d1 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801062a8:	85 c0                	test   %eax,%eax
801062aa:	78 47                	js     801062f3 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062ac:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062af:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062ba:	e8 12 f4 ff ff       	call   801056d1 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801062bf:	85 c0                	test   %eax,%eax
801062c1:	78 30                	js     801062f3 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801062c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062c6:	0f bf c8             	movswl %ax,%ecx
801062c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062cc:	0f bf d0             	movswl %ax,%edx
801062cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062d2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801062d6:	89 54 24 08          	mov    %edx,0x8(%esp)
801062da:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801062e1:	00 
801062e2:	89 04 24             	mov    %eax,(%esp)
801062e5:	e8 b9 fb ff ff       	call   80105ea3 <create>
801062ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f1:	75 0c                	jne    801062ff <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801062f3:	e8 bd d3 ff ff       	call   801036b5 <end_op>
    return -1;
801062f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fd:	eb 15                	jmp    80106314 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801062ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106302:	89 04 24             	mov    %eax,(%esp)
80106305:	e8 b7 b9 ff ff       	call   80101cc1 <iunlockput>
  end_op();
8010630a:	e8 a6 d3 ff ff       	call   801036b5 <end_op>
  return 0;
8010630f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106314:	c9                   	leave  
80106315:	c3                   	ret    

80106316 <sys_chdir>:

int
sys_chdir(void)
{
80106316:	55                   	push   %ebp
80106317:	89 e5                	mov    %esp,%ebp
80106319:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010631c:	e8 12 e0 ff ff       	call   80104333 <myproc>
80106321:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106324:	e8 0a d3 ff ff       	call   80103633 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106329:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010632c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106330:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106337:	e8 2c f4 ff ff       	call   80105768 <argstr>
8010633c:	85 c0                	test   %eax,%eax
8010633e:	78 14                	js     80106354 <sys_chdir+0x3e>
80106340:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106343:	89 04 24             	mov    %eax,(%esp)
80106346:	e8 9c c2 ff ff       	call   801025e7 <namei>
8010634b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010634e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106352:	75 0c                	jne    80106360 <sys_chdir+0x4a>
    end_op();
80106354:	e8 5c d3 ff ff       	call   801036b5 <end_op>
    return -1;
80106359:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635e:	eb 5a                	jmp    801063ba <sys_chdir+0xa4>
  }
  ilock(ip);
80106360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106363:	89 04 24             	mov    %eax,(%esp)
80106366:	e8 57 b7 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
8010636b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636e:	8b 40 50             	mov    0x50(%eax),%eax
80106371:	66 83 f8 01          	cmp    $0x1,%ax
80106375:	74 17                	je     8010638e <sys_chdir+0x78>
    iunlockput(ip);
80106377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637a:	89 04 24             	mov    %eax,(%esp)
8010637d:	e8 3f b9 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106382:	e8 2e d3 ff ff       	call   801036b5 <end_op>
    return -1;
80106387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638c:	eb 2c                	jmp    801063ba <sys_chdir+0xa4>
  }
  iunlock(ip);
8010638e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106391:	89 04 24             	mov    %eax,(%esp)
80106394:	e8 33 b8 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639c:	8b 40 68             	mov    0x68(%eax),%eax
8010639f:	89 04 24             	mov    %eax,(%esp)
801063a2:	e8 69 b8 ff ff       	call   80101c10 <iput>
  end_op();
801063a7:	e8 09 d3 ff ff       	call   801036b5 <end_op>
  curproc->cwd = ip;
801063ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063b2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801063b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063ba:	c9                   	leave  
801063bb:	c3                   	ret    

801063bc <sys_exec>:

int
sys_exec(void)
{
801063bc:	55                   	push   %ebp
801063bd:	89 e5                	mov    %esp,%ebp
801063bf:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801063cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063d3:	e8 90 f3 ff ff       	call   80105768 <argstr>
801063d8:	85 c0                	test   %eax,%eax
801063da:	78 1a                	js     801063f6 <sys_exec+0x3a>
801063dc:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801063e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801063e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063ed:	e8 df f2 ff ff       	call   801056d1 <argint>
801063f2:	85 c0                	test   %eax,%eax
801063f4:	79 0a                	jns    80106400 <sys_exec+0x44>
    return -1;
801063f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fb:	e9 c7 00 00 00       	jmp    801064c7 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106400:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106407:	00 
80106408:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010640f:	00 
80106410:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106416:	89 04 24             	mov    %eax,(%esp)
80106419:	e8 80 ef ff ff       	call   8010539e <memset>
  for(i=0;; i++){
8010641e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106428:	83 f8 1f             	cmp    $0x1f,%eax
8010642b:	76 0a                	jbe    80106437 <sys_exec+0x7b>
      return -1;
8010642d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106432:	e9 90 00 00 00       	jmp    801064c7 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643a:	c1 e0 02             	shl    $0x2,%eax
8010643d:	89 c2                	mov    %eax,%edx
8010643f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106445:	01 c2                	add    %eax,%edx
80106447:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010644d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106451:	89 14 24             	mov    %edx,(%esp)
80106454:	e8 d7 f1 ff ff       	call   80105630 <fetchint>
80106459:	85 c0                	test   %eax,%eax
8010645b:	79 07                	jns    80106464 <sys_exec+0xa8>
      return -1;
8010645d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106462:	eb 63                	jmp    801064c7 <sys_exec+0x10b>
    if(uarg == 0){
80106464:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010646a:	85 c0                	test   %eax,%eax
8010646c:	75 26                	jne    80106494 <sys_exec+0xd8>
      argv[i] = 0;
8010646e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106471:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106478:	00 00 00 00 
      break;
8010647c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010647d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106480:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106486:	89 54 24 04          	mov    %edx,0x4(%esp)
8010648a:	89 04 24             	mov    %eax,(%esp)
8010648d:	e8 ae a7 ff ff       	call   80100c40 <exec>
80106492:	eb 33                	jmp    801064c7 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106494:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010649a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010649d:	c1 e2 02             	shl    $0x2,%edx
801064a0:	01 c2                	add    %eax,%edx
801064a2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801064ac:	89 04 24             	mov    %eax,(%esp)
801064af:	e8 bb f1 ff ff       	call   8010566f <fetchstr>
801064b4:	85 c0                	test   %eax,%eax
801064b6:	79 07                	jns    801064bf <sys_exec+0x103>
      return -1;
801064b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bd:	eb 08                	jmp    801064c7 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801064bf:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801064c2:	e9 5e ff ff ff       	jmp    80106425 <sys_exec+0x69>
  return exec(path, argv);
}
801064c7:	c9                   	leave  
801064c8:	c3                   	ret    

801064c9 <sys_pipe>:

int
sys_pipe(void)
{
801064c9:	55                   	push   %ebp
801064ca:	89 e5                	mov    %esp,%ebp
801064cc:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064cf:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801064d6:	00 
801064d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064da:	89 44 24 04          	mov    %eax,0x4(%esp)
801064de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064e5:	e8 14 f2 ff ff       	call   801056fe <argptr>
801064ea:	85 c0                	test   %eax,%eax
801064ec:	79 0a                	jns    801064f8 <sys_pipe+0x2f>
    return -1;
801064ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f3:	e9 9a 00 00 00       	jmp    80106592 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801064f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ff:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106502:	89 04 24             	mov    %eax,(%esp)
80106505:	e8 7e d9 ff ff       	call   80103e88 <pipealloc>
8010650a:	85 c0                	test   %eax,%eax
8010650c:	79 07                	jns    80106515 <sys_pipe+0x4c>
    return -1;
8010650e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106513:	eb 7d                	jmp    80106592 <sys_pipe+0xc9>
  fd0 = -1;
80106515:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010651c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010651f:	89 04 24             	mov    %eax,(%esp)
80106522:	e8 75 f3 ff ff       	call   8010589c <fdalloc>
80106527:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010652a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010652e:	78 14                	js     80106544 <sys_pipe+0x7b>
80106530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106533:	89 04 24             	mov    %eax,(%esp)
80106536:	e8 61 f3 ff ff       	call   8010589c <fdalloc>
8010653b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010653e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106542:	79 36                	jns    8010657a <sys_pipe+0xb1>
    if(fd0 >= 0)
80106544:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106548:	78 13                	js     8010655d <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
8010654a:	e8 e4 dd ff ff       	call   80104333 <myproc>
8010654f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106552:	83 c2 08             	add    $0x8,%edx
80106555:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010655c:	00 
    fileclose(rf);
8010655d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106560:	89 04 24             	mov    %eax,(%esp)
80106563:	e8 42 ac ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010656b:	89 04 24             	mov    %eax,(%esp)
8010656e:	e8 37 ac ff ff       	call   801011aa <fileclose>
    return -1;
80106573:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106578:	eb 18                	jmp    80106592 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
8010657a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010657d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106580:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106582:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106585:	8d 50 04             	lea    0x4(%eax),%edx
80106588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658b:	89 02                	mov    %eax,(%edx)
  return 0;
8010658d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106592:	c9                   	leave  
80106593:	c3                   	ret    

80106594 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106594:	55                   	push   %ebp
80106595:	89 e5                	mov    %esp,%ebp
80106597:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010659a:	e8 ad e0 ff ff       	call   8010464c <fork>
}
8010659f:	c9                   	leave  
801065a0:	c3                   	ret    

801065a1 <sys_exit>:

int
sys_exit(void)
{
801065a1:	55                   	push   %ebp
801065a2:	89 e5                	mov    %esp,%ebp
801065a4:	83 ec 08             	sub    $0x8,%esp
  exit();
801065a7:	e8 18 e2 ff ff       	call   801047c4 <exit>
  return 0;  // not reached
801065ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065b1:	c9                   	leave  
801065b2:	c3                   	ret    

801065b3 <sys_wait>:

int
sys_wait(void)
{
801065b3:	55                   	push   %ebp
801065b4:	89 e5                	mov    %esp,%ebp
801065b6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065b9:	e8 12 e3 ff ff       	call   801048d0 <wait>
}
801065be:	c9                   	leave  
801065bf:	c3                   	ret    

801065c0 <sys_kill>:

int
sys_kill(void)
{
801065c0:	55                   	push   %ebp
801065c1:	89 e5                	mov    %esp,%ebp
801065c3:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065d4:	e8 f8 f0 ff ff       	call   801056d1 <argint>
801065d9:	85 c0                	test   %eax,%eax
801065db:	79 07                	jns    801065e4 <sys_kill+0x24>
    return -1;
801065dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e2:	eb 0b                	jmp    801065ef <sys_kill+0x2f>
  return kill(pid);
801065e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e7:	89 04 24             	mov    %eax,(%esp)
801065ea:	e8 bf e6 ff ff       	call   80104cae <kill>
}
801065ef:	c9                   	leave  
801065f0:	c3                   	ret    

801065f1 <sys_getpid>:

int
sys_getpid(void)
{
801065f1:	55                   	push   %ebp
801065f2:	89 e5                	mov    %esp,%ebp
801065f4:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801065f7:	e8 37 dd ff ff       	call   80104333 <myproc>
801065fc:	8b 40 10             	mov    0x10(%eax),%eax
}
801065ff:	c9                   	leave  
80106600:	c3                   	ret    

80106601 <sys_sbrk>:

int
sys_sbrk(void)
{
80106601:	55                   	push   %ebp
80106602:	89 e5                	mov    %esp,%ebp
80106604:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106607:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010660a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010660e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106615:	e8 b7 f0 ff ff       	call   801056d1 <argint>
8010661a:	85 c0                	test   %eax,%eax
8010661c:	79 07                	jns    80106625 <sys_sbrk+0x24>
    return -1;
8010661e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106623:	eb 23                	jmp    80106648 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106625:	e8 09 dd ff ff       	call   80104333 <myproc>
8010662a:	8b 00                	mov    (%eax),%eax
8010662c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010662f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106632:	89 04 24             	mov    %eax,(%esp)
80106635:	e8 74 df ff ff       	call   801045ae <growproc>
8010663a:	85 c0                	test   %eax,%eax
8010663c:	79 07                	jns    80106645 <sys_sbrk+0x44>
    return -1;
8010663e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106643:	eb 03                	jmp    80106648 <sys_sbrk+0x47>
  return addr;
80106645:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106648:	c9                   	leave  
80106649:	c3                   	ret    

8010664a <sys_sleep>:

int
sys_sleep(void)
{
8010664a:	55                   	push   %ebp
8010664b:	89 e5                	mov    %esp,%ebp
8010664d:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106650:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106653:	89 44 24 04          	mov    %eax,0x4(%esp)
80106657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010665e:	e8 6e f0 ff ff       	call   801056d1 <argint>
80106663:	85 c0                	test   %eax,%eax
80106665:	79 07                	jns    8010666e <sys_sleep+0x24>
    return -1;
80106667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666c:	eb 6b                	jmp    801066d9 <sys_sleep+0x8f>
  acquire(&tickslock);
8010666e:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106675:	e8 c1 ea ff ff       	call   8010513b <acquire>
  ticks0 = ticks;
8010667a:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
8010667f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106682:	eb 33                	jmp    801066b7 <sys_sleep+0x6d>
    if(myproc()->killed){
80106684:	e8 aa dc ff ff       	call   80104333 <myproc>
80106689:	8b 40 24             	mov    0x24(%eax),%eax
8010668c:	85 c0                	test   %eax,%eax
8010668e:	74 13                	je     801066a3 <sys_sleep+0x59>
      release(&tickslock);
80106690:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106697:	e8 09 eb ff ff       	call   801051a5 <release>
      return -1;
8010669c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a1:	eb 36                	jmp    801066d9 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
801066a3:	c7 44 24 04 60 73 11 	movl   $0x80117360,0x4(%esp)
801066aa:	80 
801066ab:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
801066b2:	e8 f5 e4 ff ff       	call   80104bac <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801066b7:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
801066bc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801066bf:	89 c2                	mov    %eax,%edx
801066c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c4:	39 c2                	cmp    %eax,%edx
801066c6:	72 bc                	jb     80106684 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801066c8:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801066cf:	e8 d1 ea ff ff       	call   801051a5 <release>
  return 0;
801066d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066d9:	c9                   	leave  
801066da:	c3                   	ret    

801066db <sys_ps>:

void sys_ps(){
801066db:	55                   	push   %ebp
801066dc:	89 e5                	mov    %esp,%ebp
801066de:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
801066e1:	e8 4d dc ff ff       	call   80104333 <myproc>
801066e6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801066ec:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801066ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066f3:	75 07                	jne    801066fc <sys_ps+0x21>
    procdump();
801066f5:	e8 2f e6 ff ff       	call   80104d29 <procdump>
801066fa:	eb 0e                	jmp    8010670a <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
801066fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ff:	83 c0 18             	add    $0x18,%eax
80106702:	89 04 24             	mov    %eax,(%esp)
80106705:	e8 96 e7 ff ff       	call   80104ea0 <c_procdump>
  }
}
8010670a:	c9                   	leave  
8010670b:	c3                   	ret    

8010670c <sys_container_init>:

void sys_container_init(){
8010670c:	55                   	push   %ebp
8010670d:	89 e5                	mov    %esp,%ebp
8010670f:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106712:	e8 e5 26 00 00       	call   80108dfc <container_init>
}
80106717:	c9                   	leave  
80106718:	c3                   	ret    

80106719 <sys_is_full>:

int sys_is_full(void){
80106719:	55                   	push   %ebp
8010671a:	89 e5                	mov    %esp,%ebp
8010671c:	83 ec 08             	sub    $0x8,%esp
  return is_full();
8010671f:	e8 da 22 00 00       	call   801089fe <is_full>
}
80106724:	c9                   	leave  
80106725:	c3                   	ret    

80106726 <sys_find>:

int sys_find(void){
80106726:	55                   	push   %ebp
80106727:	89 e5                	mov    %esp,%ebp
80106729:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
8010672c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010672f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106733:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010673a:	e8 29 f0 ff ff       	call   80105768 <argstr>

  return find(name);
8010673f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106742:	89 04 24             	mov    %eax,(%esp)
80106745:	e8 04 23 00 00       	call   80108a4e <find>
}
8010674a:	c9                   	leave  
8010674b:	c3                   	ret    

8010674c <sys_get_name>:

void sys_get_name(void){
8010674c:	55                   	push   %ebp
8010674d:	89 e5                	mov    %esp,%ebp
8010674f:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106752:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106755:	89 44 24 04          	mov    %eax,0x4(%esp)
80106759:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106760:	e8 6c ef ff ff       	call   801056d1 <argint>
  argstr(1, &name);
80106765:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106768:	89 44 24 04          	mov    %eax,0x4(%esp)
8010676c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106773:	e8 f0 ef ff ff       	call   80105768 <argstr>

  get_name(vc_num, name);
80106778:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010677b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106782:	89 04 24             	mov    %eax,(%esp)
80106785:	e8 f1 21 00 00       	call   8010897b <get_name>
}
8010678a:	c9                   	leave  
8010678b:	c3                   	ret    

8010678c <sys_get_max_proc>:

int sys_get_max_proc(void){
8010678c:	55                   	push   %ebp
8010678d:	89 e5                	mov    %esp,%ebp
8010678f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106792:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106795:	89 44 24 04          	mov    %eax,0x4(%esp)
80106799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067a0:	e8 2c ef ff ff       	call   801056d1 <argint>


  return get_max_proc(vc_num);  
801067a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a8:	89 04 24             	mov    %eax,(%esp)
801067ab:	e8 0e 23 00 00       	call   80108abe <get_max_proc>
}
801067b0:	c9                   	leave  
801067b1:	c3                   	ret    

801067b2 <sys_get_max_mem>:

int sys_get_max_mem(void){
801067b2:	55                   	push   %ebp
801067b3:	89 e5                	mov    %esp,%ebp
801067b5:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801067b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801067bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c6:	e8 06 ef ff ff       	call   801056d1 <argint>


  return get_max_mem(vc_num);
801067cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ce:	89 04 24             	mov    %eax,(%esp)
801067d1:	e8 50 23 00 00       	call   80108b26 <get_max_mem>
}
801067d6:	c9                   	leave  
801067d7:	c3                   	ret    

801067d8 <sys_get_max_disk>:

int sys_get_max_disk(void){
801067d8:	55                   	push   %ebp
801067d9:	89 e5                	mov    %esp,%ebp
801067db:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801067de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801067e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067ec:	e8 e0 ee ff ff       	call   801056d1 <argint>


  return get_max_disk(vc_num);
801067f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f4:	89 04 24             	mov    %eax,(%esp)
801067f7:	e8 6a 23 00 00       	call   80108b66 <get_max_disk>

}
801067fc:	c9                   	leave  
801067fd:	c3                   	ret    

801067fe <sys_get_curr_proc>:

int sys_get_curr_proc(void){
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106804:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106807:	89 44 24 04          	mov    %eax,0x4(%esp)
8010680b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106812:	e8 ba ee ff ff       	call   801056d1 <argint>


  return get_curr_proc(vc_num);
80106817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681a:	89 04 24             	mov    %eax,(%esp)
8010681d:	e8 84 23 00 00       	call   80108ba6 <get_curr_proc>
}
80106822:	c9                   	leave  
80106823:	c3                   	ret    

80106824 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106824:	55                   	push   %ebp
80106825:	89 e5                	mov    %esp,%ebp
80106827:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010682a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010682d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106831:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106838:	e8 94 ee ff ff       	call   801056d1 <argint>


  return get_curr_mem(vc_num);
8010683d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106840:	89 04 24             	mov    %eax,(%esp)
80106843:	e8 9e 23 00 00       	call   80108be6 <get_curr_mem>
}
80106848:	c9                   	leave  
80106849:	c3                   	ret    

8010684a <sys_get_curr_disk>:

int sys_get_curr_disk(void){
8010684a:	55                   	push   %ebp
8010684b:	89 e5                	mov    %esp,%ebp
8010684d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106850:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106853:	89 44 24 04          	mov    %eax,0x4(%esp)
80106857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010685e:	e8 6e ee ff ff       	call   801056d1 <argint>


  return get_curr_disk(vc_num);
80106863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106866:	89 04 24             	mov    %eax,(%esp)
80106869:	e8 b8 23 00 00       	call   80108c26 <get_curr_disk>
}
8010686e:	c9                   	leave  
8010686f:	c3                   	ret    

80106870 <sys_set_name>:

void sys_set_name(void){
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106876:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106879:	89 44 24 04          	mov    %eax,0x4(%esp)
8010687d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106884:	e8 df ee ff ff       	call   80105768 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106889:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010688c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106890:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106897:	e8 35 ee ff ff       	call   801056d1 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
8010689c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010689f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801068a6:	89 04 24             	mov    %eax,(%esp)
801068a9:	e8 b8 23 00 00       	call   80108c66 <set_name>
  //cprintf("Done setting name.\n");
}
801068ae:	c9                   	leave  
801068af:	c3                   	ret    

801068b0 <sys_cont_proc_set>:

void sys_cont_proc_set(void){
801068b0:	55                   	push   %ebp
801068b1:	89 e5                	mov    %esp,%ebp
801068b3:	53                   	push   %ebx
801068b4:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
801068b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801068be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068c5:	e8 07 ee ff ff       	call   801056d1 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
801068ca:	e8 64 da ff ff       	call   80104333 <myproc>
801068cf:	89 c3                	mov    %eax,%ebx
801068d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d4:	89 04 24             	mov    %eax,(%esp)
801068d7:	e8 22 22 00 00       	call   80108afe <get_container>
801068dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
801068e2:	83 c4 24             	add    $0x24,%esp
801068e5:	5b                   	pop    %ebx
801068e6:	5d                   	pop    %ebp
801068e7:	c3                   	ret    

801068e8 <sys_set_max_mem>:

void sys_set_max_mem(void){
801068e8:	55                   	push   %ebp
801068e9:	89 e5                	mov    %esp,%ebp
801068eb:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801068ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801068f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068fc:	e8 d0 ed ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106901:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106904:	89 44 24 04          	mov    %eax,0x4(%esp)
80106908:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010690f:	e8 bd ed ff ff       	call   801056d1 <argint>

  set_max_mem(mem, vc_num);
80106914:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010691e:	89 04 24             	mov    %eax,(%esp)
80106921:	e8 77 23 00 00       	call   80108c9d <set_max_mem>
}
80106926:	c9                   	leave  
80106927:	c3                   	ret    

80106928 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106928:	55                   	push   %ebp
80106929:	89 e5                	mov    %esp,%ebp
8010692b:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
8010692e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106931:	89 44 24 04          	mov    %eax,0x4(%esp)
80106935:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010693c:	e8 90 ed ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106941:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106944:	89 44 24 04          	mov    %eax,0x4(%esp)
80106948:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010694f:	e8 7d ed ff ff       	call   801056d1 <argint>

  set_max_disk(disk, vc_num);
80106954:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010695a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010695e:	89 04 24             	mov    %eax,(%esp)
80106961:	e8 5c 23 00 00       	call   80108cc2 <set_max_disk>
}
80106966:	c9                   	leave  
80106967:	c3                   	ret    

80106968 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106968:	55                   	push   %ebp
80106969:	89 e5                	mov    %esp,%ebp
8010696b:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
8010696e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106971:	89 44 24 04          	mov    %eax,0x4(%esp)
80106975:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010697c:	e8 50 ed ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106981:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106984:	89 44 24 04          	mov    %eax,0x4(%esp)
80106988:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010698f:	e8 3d ed ff ff       	call   801056d1 <argint>

  set_max_proc(proc, vc_num);
80106994:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010699e:	89 04 24             	mov    %eax,(%esp)
801069a1:	e8 42 23 00 00       	call   80108ce8 <set_max_proc>
}
801069a6:	c9                   	leave  
801069a7:	c3                   	ret    

801069a8 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
801069a8:	55                   	push   %ebp
801069a9:	89 e5                	mov    %esp,%ebp
801069ab:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801069ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801069b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069bc:	e8 10 ed ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
801069c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801069c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069cf:	e8 fd ec ff ff       	call   801056d1 <argint>

  set_curr_mem(mem, vc_num);
801069d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069da:	89 54 24 04          	mov    %edx,0x4(%esp)
801069de:	89 04 24             	mov    %eax,(%esp)
801069e1:	e8 28 23 00 00       	call   80108d0e <set_curr_mem>
}
801069e6:	c9                   	leave  
801069e7:	c3                   	ret    

801069e8 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
801069e8:	55                   	push   %ebp
801069e9:	89 e5                	mov    %esp,%ebp
801069eb:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801069ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069fc:	e8 d0 ec ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106a01:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a04:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a0f:	e8 bd ec ff ff       	call   801056d1 <argint>

  set_curr_mem(mem, vc_num);
80106a14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a1e:	89 04 24             	mov    %eax,(%esp)
80106a21:	e8 e8 22 00 00       	call   80108d0e <set_curr_mem>
}
80106a26:	c9                   	leave  
80106a27:	c3                   	ret    

80106a28 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106a28:	55                   	push   %ebp
80106a29:	89 e5                	mov    %esp,%ebp
80106a2b:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106a2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a31:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a3c:	e8 90 ec ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106a41:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a44:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a4f:	e8 7d ec ff ff       	call   801056d1 <argint>

  set_curr_disk(disk, vc_num);
80106a54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a5e:	89 04 24             	mov    %eax,(%esp)
80106a61:	e8 2c 23 00 00       	call   80108d92 <set_curr_disk>
}
80106a66:	c9                   	leave  
80106a67:	c3                   	ret    

80106a68 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106a68:	55                   	push   %ebp
80106a69:	89 e5                	mov    %esp,%ebp
80106a6b:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106a6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a71:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a7c:	e8 50 ec ff ff       	call   801056d1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106a81:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a84:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a8f:	e8 3d ec ff ff       	call   801056d1 <argint>

  set_curr_proc(proc, vc_num);
80106a94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a9e:	89 04 24             	mov    %eax,(%esp)
80106aa1:	e8 31 23 00 00       	call   80108dd7 <set_curr_proc>
}
80106aa6:	c9                   	leave  
80106aa7:	c3                   	ret    

80106aa8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106aa8:	55                   	push   %ebp
80106aa9:	89 e5                	mov    %esp,%ebp
80106aab:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106aae:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106ab5:	e8 81 e6 ff ff       	call   8010513b <acquire>
  xticks = ticks;
80106aba:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106ac2:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106ac9:	e8 d7 e6 ff ff       	call   801051a5 <release>
  return xticks;
80106ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106ad1:	c9                   	leave  
80106ad2:	c3                   	ret    

80106ad3 <sys_getticks>:

int
sys_getticks(void)
{
80106ad3:	55                   	push   %ebp
80106ad4:	89 e5                	mov    %esp,%ebp
80106ad6:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106ad9:	e8 55 d8 ff ff       	call   80104333 <myproc>
80106ade:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106ae1:	c9                   	leave  
80106ae2:	c3                   	ret    
	...

80106ae4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ae4:	1e                   	push   %ds
  pushl %es
80106ae5:	06                   	push   %es
  pushl %fs
80106ae6:	0f a0                	push   %fs
  pushl %gs
80106ae8:	0f a8                	push   %gs
  pushal
80106aea:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106aeb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aef:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106af1:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106af3:	54                   	push   %esp
  call trap
80106af4:	e8 c0 01 00 00       	call   80106cb9 <trap>
  addl $4, %esp
80106af9:	83 c4 04             	add    $0x4,%esp

80106afc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106afc:	61                   	popa   
  popl %gs
80106afd:	0f a9                	pop    %gs
  popl %fs
80106aff:	0f a1                	pop    %fs
  popl %es
80106b01:	07                   	pop    %es
  popl %ds
80106b02:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b03:	83 c4 08             	add    $0x8,%esp
  iret
80106b06:	cf                   	iret   
	...

80106b08 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106b08:	55                   	push   %ebp
80106b09:	89 e5                	mov    %esp,%ebp
80106b0b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b11:	48                   	dec    %eax
80106b12:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b16:	8b 45 08             	mov    0x8(%ebp),%eax
80106b19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b20:	c1 e8 10             	shr    $0x10,%eax
80106b23:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106b27:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b2a:	0f 01 18             	lidtl  (%eax)
}
80106b2d:	c9                   	leave  
80106b2e:	c3                   	ret    

80106b2f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b2f:	55                   	push   %ebp
80106b30:	89 e5                	mov    %esp,%ebp
80106b32:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b35:	0f 20 d0             	mov    %cr2,%eax
80106b38:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b3e:	c9                   	leave  
80106b3f:	c3                   	ret    

80106b40 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b40:	55                   	push   %ebp
80106b41:	89 e5                	mov    %esp,%ebp
80106b43:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b4d:	e9 b8 00 00 00       	jmp    80106c0a <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b55:	8b 04 85 ec c0 10 80 	mov    -0x7fef3f14(,%eax,4),%eax
80106b5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b5f:	66 89 04 d5 a0 73 11 	mov    %ax,-0x7fee8c60(,%edx,8)
80106b66:	80 
80106b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6a:	66 c7 04 c5 a2 73 11 	movw   $0x8,-0x7fee8c5e(,%eax,8)
80106b71:	80 08 00 
80106b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b77:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106b7e:	83 e2 e0             	and    $0xffffffe0,%edx
80106b81:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8b:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106b92:	83 e2 1f             	and    $0x1f,%edx
80106b95:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9f:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106ba6:	83 e2 f0             	and    $0xfffffff0,%edx
80106ba9:	83 ca 0e             	or     $0xe,%edx
80106bac:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb6:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106bbd:	83 e2 ef             	and    $0xffffffef,%edx
80106bc0:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bca:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106bd1:	83 e2 9f             	and    $0xffffff9f,%edx
80106bd4:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bde:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106be5:	83 ca 80             	or     $0xffffff80,%edx
80106be8:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf2:	8b 04 85 ec c0 10 80 	mov    -0x7fef3f14(,%eax,4),%eax
80106bf9:	c1 e8 10             	shr    $0x10,%eax
80106bfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bff:	66 89 04 d5 a6 73 11 	mov    %ax,-0x7fee8c5a(,%edx,8)
80106c06:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106c07:	ff 45 f4             	incl   -0xc(%ebp)
80106c0a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c11:	0f 8e 3b ff ff ff    	jle    80106b52 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c17:	a1 ec c1 10 80       	mov    0x8010c1ec,%eax
80106c1c:	66 a3 a0 75 11 80    	mov    %ax,0x801175a0
80106c22:	66 c7 05 a2 75 11 80 	movw   $0x8,0x801175a2
80106c29:	08 00 
80106c2b:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106c30:	83 e0 e0             	and    $0xffffffe0,%eax
80106c33:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106c38:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106c3d:	83 e0 1f             	and    $0x1f,%eax
80106c40:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106c45:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106c4a:	83 c8 0f             	or     $0xf,%eax
80106c4d:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106c52:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106c57:	83 e0 ef             	and    $0xffffffef,%eax
80106c5a:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106c5f:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106c64:	83 c8 60             	or     $0x60,%eax
80106c67:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106c6c:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106c71:	83 c8 80             	or     $0xffffff80,%eax
80106c74:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106c79:	a1 ec c1 10 80       	mov    0x8010c1ec,%eax
80106c7e:	c1 e8 10             	shr    $0x10,%eax
80106c81:	66 a3 a6 75 11 80    	mov    %ax,0x801175a6

  initlock(&tickslock, "time");
80106c87:	c7 44 24 04 68 94 10 	movl   $0x80109468,0x4(%esp)
80106c8e:	80 
80106c8f:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106c96:	e8 7f e4 ff ff       	call   8010511a <initlock>
}
80106c9b:	c9                   	leave  
80106c9c:	c3                   	ret    

80106c9d <idtinit>:

void
idtinit(void)
{
80106c9d:	55                   	push   %ebp
80106c9e:	89 e5                	mov    %esp,%ebp
80106ca0:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ca3:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106caa:	00 
80106cab:	c7 04 24 a0 73 11 80 	movl   $0x801173a0,(%esp)
80106cb2:	e8 51 fe ff ff       	call   80106b08 <lidt>
}
80106cb7:	c9                   	leave  
80106cb8:	c3                   	ret    

80106cb9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cb9:	55                   	push   %ebp
80106cba:	89 e5                	mov    %esp,%ebp
80106cbc:	57                   	push   %edi
80106cbd:	56                   	push   %esi
80106cbe:	53                   	push   %ebx
80106cbf:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc5:	8b 40 30             	mov    0x30(%eax),%eax
80106cc8:	83 f8 40             	cmp    $0x40,%eax
80106ccb:	75 3c                	jne    80106d09 <trap+0x50>
    if(myproc()->killed)
80106ccd:	e8 61 d6 ff ff       	call   80104333 <myproc>
80106cd2:	8b 40 24             	mov    0x24(%eax),%eax
80106cd5:	85 c0                	test   %eax,%eax
80106cd7:	74 05                	je     80106cde <trap+0x25>
      exit();
80106cd9:	e8 e6 da ff ff       	call   801047c4 <exit>
    myproc()->tf = tf;
80106cde:	e8 50 d6 ff ff       	call   80104333 <myproc>
80106ce3:	8b 55 08             	mov    0x8(%ebp),%edx
80106ce6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ce9:	e8 b1 ea ff ff       	call   8010579f <syscall>
    if(myproc()->killed)
80106cee:	e8 40 d6 ff ff       	call   80104333 <myproc>
80106cf3:	8b 40 24             	mov    0x24(%eax),%eax
80106cf6:	85 c0                	test   %eax,%eax
80106cf8:	74 0a                	je     80106d04 <trap+0x4b>
      exit();
80106cfa:	e8 c5 da ff ff       	call   801047c4 <exit>
    return;
80106cff:	e9 30 02 00 00       	jmp    80106f34 <trap+0x27b>
80106d04:	e9 2b 02 00 00       	jmp    80106f34 <trap+0x27b>
  }

  switch(tf->trapno){
80106d09:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0c:	8b 40 30             	mov    0x30(%eax),%eax
80106d0f:	83 e8 20             	sub    $0x20,%eax
80106d12:	83 f8 1f             	cmp    $0x1f,%eax
80106d15:	0f 87 cb 00 00 00    	ja     80106de6 <trap+0x12d>
80106d1b:	8b 04 85 10 95 10 80 	mov    -0x7fef6af0(,%eax,4),%eax
80106d22:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d24:	e8 41 d5 ff ff       	call   8010426a <cpuid>
80106d29:	85 c0                	test   %eax,%eax
80106d2b:	75 2f                	jne    80106d5c <trap+0xa3>
      acquire(&tickslock);
80106d2d:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d34:	e8 02 e4 ff ff       	call   8010513b <acquire>
      ticks++;
80106d39:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106d3e:	40                   	inc    %eax
80106d3f:	a3 a0 7b 11 80       	mov    %eax,0x80117ba0
      wakeup(&ticks);
80106d44:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
80106d4b:	e8 33 df ff ff       	call   80104c83 <wakeup>
      release(&tickslock);
80106d50:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d57:	e8 49 e4 ff ff       	call   801051a5 <release>
    }
    p = myproc();
80106d5c:	e8 d2 d5 ff ff       	call   80104333 <myproc>
80106d61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80106d64:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106d68:	74 0f                	je     80106d79 <trap+0xc0>
      p->ticks++;
80106d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d6d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106d70:	8d 50 01             	lea    0x1(%eax),%edx
80106d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d76:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106d79:	e8 8d c3 ff ff       	call   8010310b <lapiceoi>
    break;
80106d7e:	e9 35 01 00 00       	jmp    80106eb8 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d83:	e8 8a bb ff ff       	call   80102912 <ideintr>
    lapiceoi();
80106d88:	e8 7e c3 ff ff       	call   8010310b <lapiceoi>
    break;
80106d8d:	e9 26 01 00 00       	jmp    80106eb8 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d92:	e8 8b c1 ff ff       	call   80102f22 <kbdintr>
    lapiceoi();
80106d97:	e8 6f c3 ff ff       	call   8010310b <lapiceoi>
    break;
80106d9c:	e9 17 01 00 00       	jmp    80106eb8 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106da1:	e8 6f 03 00 00       	call   80107115 <uartintr>
    lapiceoi();
80106da6:	e8 60 c3 ff ff       	call   8010310b <lapiceoi>
    break;
80106dab:	e9 08 01 00 00       	jmp    80106eb8 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106db0:	8b 45 08             	mov    0x8(%ebp),%eax
80106db3:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106db6:	8b 45 08             	mov    0x8(%ebp),%eax
80106db9:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dbc:	0f b7 d8             	movzwl %ax,%ebx
80106dbf:	e8 a6 d4 ff ff       	call   8010426a <cpuid>
80106dc4:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106dc8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dd0:	c7 04 24 70 94 10 80 	movl   $0x80109470,(%esp)
80106dd7:	e8 e5 95 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106ddc:	e8 2a c3 ff ff       	call   8010310b <lapiceoi>
    break;
80106de1:	e9 d2 00 00 00       	jmp    80106eb8 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106de6:	e8 48 d5 ff ff       	call   80104333 <myproc>
80106deb:	85 c0                	test   %eax,%eax
80106ded:	74 10                	je     80106dff <trap+0x146>
80106def:	8b 45 08             	mov    0x8(%ebp),%eax
80106df2:	8b 40 3c             	mov    0x3c(%eax),%eax
80106df5:	0f b7 c0             	movzwl %ax,%eax
80106df8:	83 e0 03             	and    $0x3,%eax
80106dfb:	85 c0                	test   %eax,%eax
80106dfd:	75 40                	jne    80106e3f <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dff:	e8 2b fd ff ff       	call   80106b2f <rcr2>
80106e04:	89 c3                	mov    %eax,%ebx
80106e06:	8b 45 08             	mov    0x8(%ebp),%eax
80106e09:	8b 70 38             	mov    0x38(%eax),%esi
80106e0c:	e8 59 d4 ff ff       	call   8010426a <cpuid>
80106e11:	8b 55 08             	mov    0x8(%ebp),%edx
80106e14:	8b 52 30             	mov    0x30(%edx),%edx
80106e17:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106e1b:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106e1f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106e23:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e27:	c7 04 24 94 94 10 80 	movl   $0x80109494,(%esp)
80106e2e:	e8 8e 95 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e33:	c7 04 24 c6 94 10 80 	movl   $0x801094c6,(%esp)
80106e3a:	e8 15 97 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e3f:	e8 eb fc ff ff       	call   80106b2f <rcr2>
80106e44:	89 c6                	mov    %eax,%esi
80106e46:	8b 45 08             	mov    0x8(%ebp),%eax
80106e49:	8b 40 38             	mov    0x38(%eax),%eax
80106e4c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e4f:	e8 16 d4 ff ff       	call   8010426a <cpuid>
80106e54:	89 c3                	mov    %eax,%ebx
80106e56:	8b 45 08             	mov    0x8(%ebp),%eax
80106e59:	8b 78 34             	mov    0x34(%eax),%edi
80106e5c:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e62:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e65:	e8 c9 d4 ff ff       	call   80104333 <myproc>
80106e6a:	8d 50 6c             	lea    0x6c(%eax),%edx
80106e6d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106e70:	e8 be d4 ff ff       	call   80104333 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e75:	8b 40 10             	mov    0x10(%eax),%eax
80106e78:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106e7c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106e7f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106e83:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106e87:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106e8a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106e8e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106e92:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106e95:	89 54 24 08          	mov    %edx,0x8(%esp)
80106e99:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e9d:	c7 04 24 cc 94 10 80 	movl   $0x801094cc,(%esp)
80106ea4:	e8 18 95 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ea9:	e8 85 d4 ff ff       	call   80104333 <myproc>
80106eae:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106eb5:	eb 01                	jmp    80106eb8 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106eb7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106eb8:	e8 76 d4 ff ff       	call   80104333 <myproc>
80106ebd:	85 c0                	test   %eax,%eax
80106ebf:	74 22                	je     80106ee3 <trap+0x22a>
80106ec1:	e8 6d d4 ff ff       	call   80104333 <myproc>
80106ec6:	8b 40 24             	mov    0x24(%eax),%eax
80106ec9:	85 c0                	test   %eax,%eax
80106ecb:	74 16                	je     80106ee3 <trap+0x22a>
80106ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed0:	8b 40 3c             	mov    0x3c(%eax),%eax
80106ed3:	0f b7 c0             	movzwl %ax,%eax
80106ed6:	83 e0 03             	and    $0x3,%eax
80106ed9:	83 f8 03             	cmp    $0x3,%eax
80106edc:	75 05                	jne    80106ee3 <trap+0x22a>
    exit();
80106ede:	e8 e1 d8 ff ff       	call   801047c4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106ee3:	e8 4b d4 ff ff       	call   80104333 <myproc>
80106ee8:	85 c0                	test   %eax,%eax
80106eea:	74 1d                	je     80106f09 <trap+0x250>
80106eec:	e8 42 d4 ff ff       	call   80104333 <myproc>
80106ef1:	8b 40 0c             	mov    0xc(%eax),%eax
80106ef4:	83 f8 04             	cmp    $0x4,%eax
80106ef7:	75 10                	jne    80106f09 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80106efc:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106eff:	83 f8 20             	cmp    $0x20,%eax
80106f02:	75 05                	jne    80106f09 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106f04:	e8 33 dc ff ff       	call   80104b3c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f09:	e8 25 d4 ff ff       	call   80104333 <myproc>
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	74 22                	je     80106f34 <trap+0x27b>
80106f12:	e8 1c d4 ff ff       	call   80104333 <myproc>
80106f17:	8b 40 24             	mov    0x24(%eax),%eax
80106f1a:	85 c0                	test   %eax,%eax
80106f1c:	74 16                	je     80106f34 <trap+0x27b>
80106f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f21:	8b 40 3c             	mov    0x3c(%eax),%eax
80106f24:	0f b7 c0             	movzwl %ax,%eax
80106f27:	83 e0 03             	and    $0x3,%eax
80106f2a:	83 f8 03             	cmp    $0x3,%eax
80106f2d:	75 05                	jne    80106f34 <trap+0x27b>
    exit();
80106f2f:	e8 90 d8 ff ff       	call   801047c4 <exit>
}
80106f34:	83 c4 4c             	add    $0x4c,%esp
80106f37:	5b                   	pop    %ebx
80106f38:	5e                   	pop    %esi
80106f39:	5f                   	pop    %edi
80106f3a:	5d                   	pop    %ebp
80106f3b:	c3                   	ret    

80106f3c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106f3c:	55                   	push   %ebp
80106f3d:	89 e5                	mov    %esp,%ebp
80106f3f:	83 ec 14             	sub    $0x14,%esp
80106f42:	8b 45 08             	mov    0x8(%ebp),%eax
80106f45:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f4c:	89 c2                	mov    %eax,%edx
80106f4e:	ec                   	in     (%dx),%al
80106f4f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f52:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106f55:	c9                   	leave  
80106f56:	c3                   	ret    

80106f57 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106f57:	55                   	push   %ebp
80106f58:	89 e5                	mov    %esp,%ebp
80106f5a:	83 ec 08             	sub    $0x8,%esp
80106f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f60:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f63:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f67:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f6a:	8a 45 f8             	mov    -0x8(%ebp),%al
80106f6d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106f70:	ee                   	out    %al,(%dx)
}
80106f71:	c9                   	leave  
80106f72:	c3                   	ret    

80106f73 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f73:	55                   	push   %ebp
80106f74:	89 e5                	mov    %esp,%ebp
80106f76:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f80:	00 
80106f81:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106f88:	e8 ca ff ff ff       	call   80106f57 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f8d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106f94:	00 
80106f95:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106f9c:	e8 b6 ff ff ff       	call   80106f57 <outb>
  outb(COM1+0, 115200/9600);
80106fa1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106fa8:	00 
80106fa9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106fb0:	e8 a2 ff ff ff       	call   80106f57 <outb>
  outb(COM1+1, 0);
80106fb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fbc:	00 
80106fbd:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106fc4:	e8 8e ff ff ff       	call   80106f57 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fc9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106fd0:	00 
80106fd1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106fd8:	e8 7a ff ff ff       	call   80106f57 <outb>
  outb(COM1+4, 0);
80106fdd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fe4:	00 
80106fe5:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106fec:	e8 66 ff ff ff       	call   80106f57 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ff1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106ff8:	00 
80106ff9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107000:	e8 52 ff ff ff       	call   80106f57 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107005:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010700c:	e8 2b ff ff ff       	call   80106f3c <inb>
80107011:	3c ff                	cmp    $0xff,%al
80107013:	75 02                	jne    80107017 <uartinit+0xa4>
    return;
80107015:	eb 5b                	jmp    80107072 <uartinit+0xff>
  uart = 1;
80107017:	c7 05 04 c9 10 80 01 	movl   $0x1,0x8010c904
8010701e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107021:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107028:	e8 0f ff ff ff       	call   80106f3c <inb>
  inb(COM1+0);
8010702d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107034:	e8 03 ff ff ff       	call   80106f3c <inb>
  ioapicenable(IRQ_COM1, 0);
80107039:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107040:	00 
80107041:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107048:	e8 3a bb ff ff       	call   80102b87 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010704d:	c7 45 f4 90 95 10 80 	movl   $0x80109590,-0xc(%ebp)
80107054:	eb 13                	jmp    80107069 <uartinit+0xf6>
    uartputc(*p);
80107056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107059:	8a 00                	mov    (%eax),%al
8010705b:	0f be c0             	movsbl %al,%eax
8010705e:	89 04 24             	mov    %eax,(%esp)
80107061:	e8 0e 00 00 00       	call   80107074 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107066:	ff 45 f4             	incl   -0xc(%ebp)
80107069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706c:	8a 00                	mov    (%eax),%al
8010706e:	84 c0                	test   %al,%al
80107070:	75 e4                	jne    80107056 <uartinit+0xe3>
    uartputc(*p);
}
80107072:	c9                   	leave  
80107073:	c3                   	ret    

80107074 <uartputc>:

void
uartputc(int c)
{
80107074:	55                   	push   %ebp
80107075:	89 e5                	mov    %esp,%ebp
80107077:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010707a:	a1 04 c9 10 80       	mov    0x8010c904,%eax
8010707f:	85 c0                	test   %eax,%eax
80107081:	75 02                	jne    80107085 <uartputc+0x11>
    return;
80107083:	eb 4a                	jmp    801070cf <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010708c:	eb 0f                	jmp    8010709d <uartputc+0x29>
    microdelay(10);
8010708e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107095:	e8 96 c0 ff ff       	call   80103130 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010709a:	ff 45 f4             	incl   -0xc(%ebp)
8010709d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070a1:	7f 16                	jg     801070b9 <uartputc+0x45>
801070a3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070aa:	e8 8d fe ff ff       	call   80106f3c <inb>
801070af:	0f b6 c0             	movzbl %al,%eax
801070b2:	83 e0 20             	and    $0x20,%eax
801070b5:	85 c0                	test   %eax,%eax
801070b7:	74 d5                	je     8010708e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801070b9:	8b 45 08             	mov    0x8(%ebp),%eax
801070bc:	0f b6 c0             	movzbl %al,%eax
801070bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801070c3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070ca:	e8 88 fe ff ff       	call   80106f57 <outb>
}
801070cf:	c9                   	leave  
801070d0:	c3                   	ret    

801070d1 <uartgetc>:

static int
uartgetc(void)
{
801070d1:	55                   	push   %ebp
801070d2:	89 e5                	mov    %esp,%ebp
801070d4:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801070d7:	a1 04 c9 10 80       	mov    0x8010c904,%eax
801070dc:	85 c0                	test   %eax,%eax
801070de:	75 07                	jne    801070e7 <uartgetc+0x16>
    return -1;
801070e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070e5:	eb 2c                	jmp    80107113 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801070e7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070ee:	e8 49 fe ff ff       	call   80106f3c <inb>
801070f3:	0f b6 c0             	movzbl %al,%eax
801070f6:	83 e0 01             	and    $0x1,%eax
801070f9:	85 c0                	test   %eax,%eax
801070fb:	75 07                	jne    80107104 <uartgetc+0x33>
    return -1;
801070fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107102:	eb 0f                	jmp    80107113 <uartgetc+0x42>
  return inb(COM1+0);
80107104:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010710b:	e8 2c fe ff ff       	call   80106f3c <inb>
80107110:	0f b6 c0             	movzbl %al,%eax
}
80107113:	c9                   	leave  
80107114:	c3                   	ret    

80107115 <uartintr>:

void
uartintr(void)
{
80107115:	55                   	push   %ebp
80107116:	89 e5                	mov    %esp,%ebp
80107118:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010711b:	c7 04 24 d1 70 10 80 	movl   $0x801070d1,(%esp)
80107122:	e8 ce 96 ff ff       	call   801007f5 <consoleintr>
}
80107127:	c9                   	leave  
80107128:	c3                   	ret    
80107129:	00 00                	add    %al,(%eax)
	...

8010712c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $0
8010712e:	6a 00                	push   $0x0
  jmp alltraps
80107130:	e9 af f9 ff ff       	jmp    80106ae4 <alltraps>

80107135 <vector1>:
.globl vector1
vector1:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $1
80107137:	6a 01                	push   $0x1
  jmp alltraps
80107139:	e9 a6 f9 ff ff       	jmp    80106ae4 <alltraps>

8010713e <vector2>:
.globl vector2
vector2:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $2
80107140:	6a 02                	push   $0x2
  jmp alltraps
80107142:	e9 9d f9 ff ff       	jmp    80106ae4 <alltraps>

80107147 <vector3>:
.globl vector3
vector3:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $3
80107149:	6a 03                	push   $0x3
  jmp alltraps
8010714b:	e9 94 f9 ff ff       	jmp    80106ae4 <alltraps>

80107150 <vector4>:
.globl vector4
vector4:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $4
80107152:	6a 04                	push   $0x4
  jmp alltraps
80107154:	e9 8b f9 ff ff       	jmp    80106ae4 <alltraps>

80107159 <vector5>:
.globl vector5
vector5:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $5
8010715b:	6a 05                	push   $0x5
  jmp alltraps
8010715d:	e9 82 f9 ff ff       	jmp    80106ae4 <alltraps>

80107162 <vector6>:
.globl vector6
vector6:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $6
80107164:	6a 06                	push   $0x6
  jmp alltraps
80107166:	e9 79 f9 ff ff       	jmp    80106ae4 <alltraps>

8010716b <vector7>:
.globl vector7
vector7:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $7
8010716d:	6a 07                	push   $0x7
  jmp alltraps
8010716f:	e9 70 f9 ff ff       	jmp    80106ae4 <alltraps>

80107174 <vector8>:
.globl vector8
vector8:
  pushl $8
80107174:	6a 08                	push   $0x8
  jmp alltraps
80107176:	e9 69 f9 ff ff       	jmp    80106ae4 <alltraps>

8010717b <vector9>:
.globl vector9
vector9:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $9
8010717d:	6a 09                	push   $0x9
  jmp alltraps
8010717f:	e9 60 f9 ff ff       	jmp    80106ae4 <alltraps>

80107184 <vector10>:
.globl vector10
vector10:
  pushl $10
80107184:	6a 0a                	push   $0xa
  jmp alltraps
80107186:	e9 59 f9 ff ff       	jmp    80106ae4 <alltraps>

8010718b <vector11>:
.globl vector11
vector11:
  pushl $11
8010718b:	6a 0b                	push   $0xb
  jmp alltraps
8010718d:	e9 52 f9 ff ff       	jmp    80106ae4 <alltraps>

80107192 <vector12>:
.globl vector12
vector12:
  pushl $12
80107192:	6a 0c                	push   $0xc
  jmp alltraps
80107194:	e9 4b f9 ff ff       	jmp    80106ae4 <alltraps>

80107199 <vector13>:
.globl vector13
vector13:
  pushl $13
80107199:	6a 0d                	push   $0xd
  jmp alltraps
8010719b:	e9 44 f9 ff ff       	jmp    80106ae4 <alltraps>

801071a0 <vector14>:
.globl vector14
vector14:
  pushl $14
801071a0:	6a 0e                	push   $0xe
  jmp alltraps
801071a2:	e9 3d f9 ff ff       	jmp    80106ae4 <alltraps>

801071a7 <vector15>:
.globl vector15
vector15:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $15
801071a9:	6a 0f                	push   $0xf
  jmp alltraps
801071ab:	e9 34 f9 ff ff       	jmp    80106ae4 <alltraps>

801071b0 <vector16>:
.globl vector16
vector16:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $16
801071b2:	6a 10                	push   $0x10
  jmp alltraps
801071b4:	e9 2b f9 ff ff       	jmp    80106ae4 <alltraps>

801071b9 <vector17>:
.globl vector17
vector17:
  pushl $17
801071b9:	6a 11                	push   $0x11
  jmp alltraps
801071bb:	e9 24 f9 ff ff       	jmp    80106ae4 <alltraps>

801071c0 <vector18>:
.globl vector18
vector18:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $18
801071c2:	6a 12                	push   $0x12
  jmp alltraps
801071c4:	e9 1b f9 ff ff       	jmp    80106ae4 <alltraps>

801071c9 <vector19>:
.globl vector19
vector19:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $19
801071cb:	6a 13                	push   $0x13
  jmp alltraps
801071cd:	e9 12 f9 ff ff       	jmp    80106ae4 <alltraps>

801071d2 <vector20>:
.globl vector20
vector20:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $20
801071d4:	6a 14                	push   $0x14
  jmp alltraps
801071d6:	e9 09 f9 ff ff       	jmp    80106ae4 <alltraps>

801071db <vector21>:
.globl vector21
vector21:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $21
801071dd:	6a 15                	push   $0x15
  jmp alltraps
801071df:	e9 00 f9 ff ff       	jmp    80106ae4 <alltraps>

801071e4 <vector22>:
.globl vector22
vector22:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $22
801071e6:	6a 16                	push   $0x16
  jmp alltraps
801071e8:	e9 f7 f8 ff ff       	jmp    80106ae4 <alltraps>

801071ed <vector23>:
.globl vector23
vector23:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $23
801071ef:	6a 17                	push   $0x17
  jmp alltraps
801071f1:	e9 ee f8 ff ff       	jmp    80106ae4 <alltraps>

801071f6 <vector24>:
.globl vector24
vector24:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $24
801071f8:	6a 18                	push   $0x18
  jmp alltraps
801071fa:	e9 e5 f8 ff ff       	jmp    80106ae4 <alltraps>

801071ff <vector25>:
.globl vector25
vector25:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $25
80107201:	6a 19                	push   $0x19
  jmp alltraps
80107203:	e9 dc f8 ff ff       	jmp    80106ae4 <alltraps>

80107208 <vector26>:
.globl vector26
vector26:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $26
8010720a:	6a 1a                	push   $0x1a
  jmp alltraps
8010720c:	e9 d3 f8 ff ff       	jmp    80106ae4 <alltraps>

80107211 <vector27>:
.globl vector27
vector27:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $27
80107213:	6a 1b                	push   $0x1b
  jmp alltraps
80107215:	e9 ca f8 ff ff       	jmp    80106ae4 <alltraps>

8010721a <vector28>:
.globl vector28
vector28:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $28
8010721c:	6a 1c                	push   $0x1c
  jmp alltraps
8010721e:	e9 c1 f8 ff ff       	jmp    80106ae4 <alltraps>

80107223 <vector29>:
.globl vector29
vector29:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $29
80107225:	6a 1d                	push   $0x1d
  jmp alltraps
80107227:	e9 b8 f8 ff ff       	jmp    80106ae4 <alltraps>

8010722c <vector30>:
.globl vector30
vector30:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $30
8010722e:	6a 1e                	push   $0x1e
  jmp alltraps
80107230:	e9 af f8 ff ff       	jmp    80106ae4 <alltraps>

80107235 <vector31>:
.globl vector31
vector31:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $31
80107237:	6a 1f                	push   $0x1f
  jmp alltraps
80107239:	e9 a6 f8 ff ff       	jmp    80106ae4 <alltraps>

8010723e <vector32>:
.globl vector32
vector32:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $32
80107240:	6a 20                	push   $0x20
  jmp alltraps
80107242:	e9 9d f8 ff ff       	jmp    80106ae4 <alltraps>

80107247 <vector33>:
.globl vector33
vector33:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $33
80107249:	6a 21                	push   $0x21
  jmp alltraps
8010724b:	e9 94 f8 ff ff       	jmp    80106ae4 <alltraps>

80107250 <vector34>:
.globl vector34
vector34:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $34
80107252:	6a 22                	push   $0x22
  jmp alltraps
80107254:	e9 8b f8 ff ff       	jmp    80106ae4 <alltraps>

80107259 <vector35>:
.globl vector35
vector35:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $35
8010725b:	6a 23                	push   $0x23
  jmp alltraps
8010725d:	e9 82 f8 ff ff       	jmp    80106ae4 <alltraps>

80107262 <vector36>:
.globl vector36
vector36:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $36
80107264:	6a 24                	push   $0x24
  jmp alltraps
80107266:	e9 79 f8 ff ff       	jmp    80106ae4 <alltraps>

8010726b <vector37>:
.globl vector37
vector37:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $37
8010726d:	6a 25                	push   $0x25
  jmp alltraps
8010726f:	e9 70 f8 ff ff       	jmp    80106ae4 <alltraps>

80107274 <vector38>:
.globl vector38
vector38:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $38
80107276:	6a 26                	push   $0x26
  jmp alltraps
80107278:	e9 67 f8 ff ff       	jmp    80106ae4 <alltraps>

8010727d <vector39>:
.globl vector39
vector39:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $39
8010727f:	6a 27                	push   $0x27
  jmp alltraps
80107281:	e9 5e f8 ff ff       	jmp    80106ae4 <alltraps>

80107286 <vector40>:
.globl vector40
vector40:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $40
80107288:	6a 28                	push   $0x28
  jmp alltraps
8010728a:	e9 55 f8 ff ff       	jmp    80106ae4 <alltraps>

8010728f <vector41>:
.globl vector41
vector41:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $41
80107291:	6a 29                	push   $0x29
  jmp alltraps
80107293:	e9 4c f8 ff ff       	jmp    80106ae4 <alltraps>

80107298 <vector42>:
.globl vector42
vector42:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $42
8010729a:	6a 2a                	push   $0x2a
  jmp alltraps
8010729c:	e9 43 f8 ff ff       	jmp    80106ae4 <alltraps>

801072a1 <vector43>:
.globl vector43
vector43:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $43
801072a3:	6a 2b                	push   $0x2b
  jmp alltraps
801072a5:	e9 3a f8 ff ff       	jmp    80106ae4 <alltraps>

801072aa <vector44>:
.globl vector44
vector44:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $44
801072ac:	6a 2c                	push   $0x2c
  jmp alltraps
801072ae:	e9 31 f8 ff ff       	jmp    80106ae4 <alltraps>

801072b3 <vector45>:
.globl vector45
vector45:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $45
801072b5:	6a 2d                	push   $0x2d
  jmp alltraps
801072b7:	e9 28 f8 ff ff       	jmp    80106ae4 <alltraps>

801072bc <vector46>:
.globl vector46
vector46:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $46
801072be:	6a 2e                	push   $0x2e
  jmp alltraps
801072c0:	e9 1f f8 ff ff       	jmp    80106ae4 <alltraps>

801072c5 <vector47>:
.globl vector47
vector47:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $47
801072c7:	6a 2f                	push   $0x2f
  jmp alltraps
801072c9:	e9 16 f8 ff ff       	jmp    80106ae4 <alltraps>

801072ce <vector48>:
.globl vector48
vector48:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $48
801072d0:	6a 30                	push   $0x30
  jmp alltraps
801072d2:	e9 0d f8 ff ff       	jmp    80106ae4 <alltraps>

801072d7 <vector49>:
.globl vector49
vector49:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $49
801072d9:	6a 31                	push   $0x31
  jmp alltraps
801072db:	e9 04 f8 ff ff       	jmp    80106ae4 <alltraps>

801072e0 <vector50>:
.globl vector50
vector50:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $50
801072e2:	6a 32                	push   $0x32
  jmp alltraps
801072e4:	e9 fb f7 ff ff       	jmp    80106ae4 <alltraps>

801072e9 <vector51>:
.globl vector51
vector51:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $51
801072eb:	6a 33                	push   $0x33
  jmp alltraps
801072ed:	e9 f2 f7 ff ff       	jmp    80106ae4 <alltraps>

801072f2 <vector52>:
.globl vector52
vector52:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $52
801072f4:	6a 34                	push   $0x34
  jmp alltraps
801072f6:	e9 e9 f7 ff ff       	jmp    80106ae4 <alltraps>

801072fb <vector53>:
.globl vector53
vector53:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $53
801072fd:	6a 35                	push   $0x35
  jmp alltraps
801072ff:	e9 e0 f7 ff ff       	jmp    80106ae4 <alltraps>

80107304 <vector54>:
.globl vector54
vector54:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $54
80107306:	6a 36                	push   $0x36
  jmp alltraps
80107308:	e9 d7 f7 ff ff       	jmp    80106ae4 <alltraps>

8010730d <vector55>:
.globl vector55
vector55:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $55
8010730f:	6a 37                	push   $0x37
  jmp alltraps
80107311:	e9 ce f7 ff ff       	jmp    80106ae4 <alltraps>

80107316 <vector56>:
.globl vector56
vector56:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $56
80107318:	6a 38                	push   $0x38
  jmp alltraps
8010731a:	e9 c5 f7 ff ff       	jmp    80106ae4 <alltraps>

8010731f <vector57>:
.globl vector57
vector57:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $57
80107321:	6a 39                	push   $0x39
  jmp alltraps
80107323:	e9 bc f7 ff ff       	jmp    80106ae4 <alltraps>

80107328 <vector58>:
.globl vector58
vector58:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $58
8010732a:	6a 3a                	push   $0x3a
  jmp alltraps
8010732c:	e9 b3 f7 ff ff       	jmp    80106ae4 <alltraps>

80107331 <vector59>:
.globl vector59
vector59:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $59
80107333:	6a 3b                	push   $0x3b
  jmp alltraps
80107335:	e9 aa f7 ff ff       	jmp    80106ae4 <alltraps>

8010733a <vector60>:
.globl vector60
vector60:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $60
8010733c:	6a 3c                	push   $0x3c
  jmp alltraps
8010733e:	e9 a1 f7 ff ff       	jmp    80106ae4 <alltraps>

80107343 <vector61>:
.globl vector61
vector61:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $61
80107345:	6a 3d                	push   $0x3d
  jmp alltraps
80107347:	e9 98 f7 ff ff       	jmp    80106ae4 <alltraps>

8010734c <vector62>:
.globl vector62
vector62:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $62
8010734e:	6a 3e                	push   $0x3e
  jmp alltraps
80107350:	e9 8f f7 ff ff       	jmp    80106ae4 <alltraps>

80107355 <vector63>:
.globl vector63
vector63:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $63
80107357:	6a 3f                	push   $0x3f
  jmp alltraps
80107359:	e9 86 f7 ff ff       	jmp    80106ae4 <alltraps>

8010735e <vector64>:
.globl vector64
vector64:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $64
80107360:	6a 40                	push   $0x40
  jmp alltraps
80107362:	e9 7d f7 ff ff       	jmp    80106ae4 <alltraps>

80107367 <vector65>:
.globl vector65
vector65:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $65
80107369:	6a 41                	push   $0x41
  jmp alltraps
8010736b:	e9 74 f7 ff ff       	jmp    80106ae4 <alltraps>

80107370 <vector66>:
.globl vector66
vector66:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $66
80107372:	6a 42                	push   $0x42
  jmp alltraps
80107374:	e9 6b f7 ff ff       	jmp    80106ae4 <alltraps>

80107379 <vector67>:
.globl vector67
vector67:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $67
8010737b:	6a 43                	push   $0x43
  jmp alltraps
8010737d:	e9 62 f7 ff ff       	jmp    80106ae4 <alltraps>

80107382 <vector68>:
.globl vector68
vector68:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $68
80107384:	6a 44                	push   $0x44
  jmp alltraps
80107386:	e9 59 f7 ff ff       	jmp    80106ae4 <alltraps>

8010738b <vector69>:
.globl vector69
vector69:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $69
8010738d:	6a 45                	push   $0x45
  jmp alltraps
8010738f:	e9 50 f7 ff ff       	jmp    80106ae4 <alltraps>

80107394 <vector70>:
.globl vector70
vector70:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $70
80107396:	6a 46                	push   $0x46
  jmp alltraps
80107398:	e9 47 f7 ff ff       	jmp    80106ae4 <alltraps>

8010739d <vector71>:
.globl vector71
vector71:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $71
8010739f:	6a 47                	push   $0x47
  jmp alltraps
801073a1:	e9 3e f7 ff ff       	jmp    80106ae4 <alltraps>

801073a6 <vector72>:
.globl vector72
vector72:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $72
801073a8:	6a 48                	push   $0x48
  jmp alltraps
801073aa:	e9 35 f7 ff ff       	jmp    80106ae4 <alltraps>

801073af <vector73>:
.globl vector73
vector73:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $73
801073b1:	6a 49                	push   $0x49
  jmp alltraps
801073b3:	e9 2c f7 ff ff       	jmp    80106ae4 <alltraps>

801073b8 <vector74>:
.globl vector74
vector74:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $74
801073ba:	6a 4a                	push   $0x4a
  jmp alltraps
801073bc:	e9 23 f7 ff ff       	jmp    80106ae4 <alltraps>

801073c1 <vector75>:
.globl vector75
vector75:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $75
801073c3:	6a 4b                	push   $0x4b
  jmp alltraps
801073c5:	e9 1a f7 ff ff       	jmp    80106ae4 <alltraps>

801073ca <vector76>:
.globl vector76
vector76:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $76
801073cc:	6a 4c                	push   $0x4c
  jmp alltraps
801073ce:	e9 11 f7 ff ff       	jmp    80106ae4 <alltraps>

801073d3 <vector77>:
.globl vector77
vector77:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $77
801073d5:	6a 4d                	push   $0x4d
  jmp alltraps
801073d7:	e9 08 f7 ff ff       	jmp    80106ae4 <alltraps>

801073dc <vector78>:
.globl vector78
vector78:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $78
801073de:	6a 4e                	push   $0x4e
  jmp alltraps
801073e0:	e9 ff f6 ff ff       	jmp    80106ae4 <alltraps>

801073e5 <vector79>:
.globl vector79
vector79:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $79
801073e7:	6a 4f                	push   $0x4f
  jmp alltraps
801073e9:	e9 f6 f6 ff ff       	jmp    80106ae4 <alltraps>

801073ee <vector80>:
.globl vector80
vector80:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $80
801073f0:	6a 50                	push   $0x50
  jmp alltraps
801073f2:	e9 ed f6 ff ff       	jmp    80106ae4 <alltraps>

801073f7 <vector81>:
.globl vector81
vector81:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $81
801073f9:	6a 51                	push   $0x51
  jmp alltraps
801073fb:	e9 e4 f6 ff ff       	jmp    80106ae4 <alltraps>

80107400 <vector82>:
.globl vector82
vector82:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $82
80107402:	6a 52                	push   $0x52
  jmp alltraps
80107404:	e9 db f6 ff ff       	jmp    80106ae4 <alltraps>

80107409 <vector83>:
.globl vector83
vector83:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $83
8010740b:	6a 53                	push   $0x53
  jmp alltraps
8010740d:	e9 d2 f6 ff ff       	jmp    80106ae4 <alltraps>

80107412 <vector84>:
.globl vector84
vector84:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $84
80107414:	6a 54                	push   $0x54
  jmp alltraps
80107416:	e9 c9 f6 ff ff       	jmp    80106ae4 <alltraps>

8010741b <vector85>:
.globl vector85
vector85:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $85
8010741d:	6a 55                	push   $0x55
  jmp alltraps
8010741f:	e9 c0 f6 ff ff       	jmp    80106ae4 <alltraps>

80107424 <vector86>:
.globl vector86
vector86:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $86
80107426:	6a 56                	push   $0x56
  jmp alltraps
80107428:	e9 b7 f6 ff ff       	jmp    80106ae4 <alltraps>

8010742d <vector87>:
.globl vector87
vector87:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $87
8010742f:	6a 57                	push   $0x57
  jmp alltraps
80107431:	e9 ae f6 ff ff       	jmp    80106ae4 <alltraps>

80107436 <vector88>:
.globl vector88
vector88:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $88
80107438:	6a 58                	push   $0x58
  jmp alltraps
8010743a:	e9 a5 f6 ff ff       	jmp    80106ae4 <alltraps>

8010743f <vector89>:
.globl vector89
vector89:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $89
80107441:	6a 59                	push   $0x59
  jmp alltraps
80107443:	e9 9c f6 ff ff       	jmp    80106ae4 <alltraps>

80107448 <vector90>:
.globl vector90
vector90:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $90
8010744a:	6a 5a                	push   $0x5a
  jmp alltraps
8010744c:	e9 93 f6 ff ff       	jmp    80106ae4 <alltraps>

80107451 <vector91>:
.globl vector91
vector91:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $91
80107453:	6a 5b                	push   $0x5b
  jmp alltraps
80107455:	e9 8a f6 ff ff       	jmp    80106ae4 <alltraps>

8010745a <vector92>:
.globl vector92
vector92:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $92
8010745c:	6a 5c                	push   $0x5c
  jmp alltraps
8010745e:	e9 81 f6 ff ff       	jmp    80106ae4 <alltraps>

80107463 <vector93>:
.globl vector93
vector93:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $93
80107465:	6a 5d                	push   $0x5d
  jmp alltraps
80107467:	e9 78 f6 ff ff       	jmp    80106ae4 <alltraps>

8010746c <vector94>:
.globl vector94
vector94:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $94
8010746e:	6a 5e                	push   $0x5e
  jmp alltraps
80107470:	e9 6f f6 ff ff       	jmp    80106ae4 <alltraps>

80107475 <vector95>:
.globl vector95
vector95:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $95
80107477:	6a 5f                	push   $0x5f
  jmp alltraps
80107479:	e9 66 f6 ff ff       	jmp    80106ae4 <alltraps>

8010747e <vector96>:
.globl vector96
vector96:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $96
80107480:	6a 60                	push   $0x60
  jmp alltraps
80107482:	e9 5d f6 ff ff       	jmp    80106ae4 <alltraps>

80107487 <vector97>:
.globl vector97
vector97:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $97
80107489:	6a 61                	push   $0x61
  jmp alltraps
8010748b:	e9 54 f6 ff ff       	jmp    80106ae4 <alltraps>

80107490 <vector98>:
.globl vector98
vector98:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $98
80107492:	6a 62                	push   $0x62
  jmp alltraps
80107494:	e9 4b f6 ff ff       	jmp    80106ae4 <alltraps>

80107499 <vector99>:
.globl vector99
vector99:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $99
8010749b:	6a 63                	push   $0x63
  jmp alltraps
8010749d:	e9 42 f6 ff ff       	jmp    80106ae4 <alltraps>

801074a2 <vector100>:
.globl vector100
vector100:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $100
801074a4:	6a 64                	push   $0x64
  jmp alltraps
801074a6:	e9 39 f6 ff ff       	jmp    80106ae4 <alltraps>

801074ab <vector101>:
.globl vector101
vector101:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $101
801074ad:	6a 65                	push   $0x65
  jmp alltraps
801074af:	e9 30 f6 ff ff       	jmp    80106ae4 <alltraps>

801074b4 <vector102>:
.globl vector102
vector102:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $102
801074b6:	6a 66                	push   $0x66
  jmp alltraps
801074b8:	e9 27 f6 ff ff       	jmp    80106ae4 <alltraps>

801074bd <vector103>:
.globl vector103
vector103:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $103
801074bf:	6a 67                	push   $0x67
  jmp alltraps
801074c1:	e9 1e f6 ff ff       	jmp    80106ae4 <alltraps>

801074c6 <vector104>:
.globl vector104
vector104:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $104
801074c8:	6a 68                	push   $0x68
  jmp alltraps
801074ca:	e9 15 f6 ff ff       	jmp    80106ae4 <alltraps>

801074cf <vector105>:
.globl vector105
vector105:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $105
801074d1:	6a 69                	push   $0x69
  jmp alltraps
801074d3:	e9 0c f6 ff ff       	jmp    80106ae4 <alltraps>

801074d8 <vector106>:
.globl vector106
vector106:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $106
801074da:	6a 6a                	push   $0x6a
  jmp alltraps
801074dc:	e9 03 f6 ff ff       	jmp    80106ae4 <alltraps>

801074e1 <vector107>:
.globl vector107
vector107:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $107
801074e3:	6a 6b                	push   $0x6b
  jmp alltraps
801074e5:	e9 fa f5 ff ff       	jmp    80106ae4 <alltraps>

801074ea <vector108>:
.globl vector108
vector108:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $108
801074ec:	6a 6c                	push   $0x6c
  jmp alltraps
801074ee:	e9 f1 f5 ff ff       	jmp    80106ae4 <alltraps>

801074f3 <vector109>:
.globl vector109
vector109:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $109
801074f5:	6a 6d                	push   $0x6d
  jmp alltraps
801074f7:	e9 e8 f5 ff ff       	jmp    80106ae4 <alltraps>

801074fc <vector110>:
.globl vector110
vector110:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $110
801074fe:	6a 6e                	push   $0x6e
  jmp alltraps
80107500:	e9 df f5 ff ff       	jmp    80106ae4 <alltraps>

80107505 <vector111>:
.globl vector111
vector111:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $111
80107507:	6a 6f                	push   $0x6f
  jmp alltraps
80107509:	e9 d6 f5 ff ff       	jmp    80106ae4 <alltraps>

8010750e <vector112>:
.globl vector112
vector112:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $112
80107510:	6a 70                	push   $0x70
  jmp alltraps
80107512:	e9 cd f5 ff ff       	jmp    80106ae4 <alltraps>

80107517 <vector113>:
.globl vector113
vector113:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $113
80107519:	6a 71                	push   $0x71
  jmp alltraps
8010751b:	e9 c4 f5 ff ff       	jmp    80106ae4 <alltraps>

80107520 <vector114>:
.globl vector114
vector114:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $114
80107522:	6a 72                	push   $0x72
  jmp alltraps
80107524:	e9 bb f5 ff ff       	jmp    80106ae4 <alltraps>

80107529 <vector115>:
.globl vector115
vector115:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $115
8010752b:	6a 73                	push   $0x73
  jmp alltraps
8010752d:	e9 b2 f5 ff ff       	jmp    80106ae4 <alltraps>

80107532 <vector116>:
.globl vector116
vector116:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $116
80107534:	6a 74                	push   $0x74
  jmp alltraps
80107536:	e9 a9 f5 ff ff       	jmp    80106ae4 <alltraps>

8010753b <vector117>:
.globl vector117
vector117:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $117
8010753d:	6a 75                	push   $0x75
  jmp alltraps
8010753f:	e9 a0 f5 ff ff       	jmp    80106ae4 <alltraps>

80107544 <vector118>:
.globl vector118
vector118:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $118
80107546:	6a 76                	push   $0x76
  jmp alltraps
80107548:	e9 97 f5 ff ff       	jmp    80106ae4 <alltraps>

8010754d <vector119>:
.globl vector119
vector119:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $119
8010754f:	6a 77                	push   $0x77
  jmp alltraps
80107551:	e9 8e f5 ff ff       	jmp    80106ae4 <alltraps>

80107556 <vector120>:
.globl vector120
vector120:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $120
80107558:	6a 78                	push   $0x78
  jmp alltraps
8010755a:	e9 85 f5 ff ff       	jmp    80106ae4 <alltraps>

8010755f <vector121>:
.globl vector121
vector121:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $121
80107561:	6a 79                	push   $0x79
  jmp alltraps
80107563:	e9 7c f5 ff ff       	jmp    80106ae4 <alltraps>

80107568 <vector122>:
.globl vector122
vector122:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $122
8010756a:	6a 7a                	push   $0x7a
  jmp alltraps
8010756c:	e9 73 f5 ff ff       	jmp    80106ae4 <alltraps>

80107571 <vector123>:
.globl vector123
vector123:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $123
80107573:	6a 7b                	push   $0x7b
  jmp alltraps
80107575:	e9 6a f5 ff ff       	jmp    80106ae4 <alltraps>

8010757a <vector124>:
.globl vector124
vector124:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $124
8010757c:	6a 7c                	push   $0x7c
  jmp alltraps
8010757e:	e9 61 f5 ff ff       	jmp    80106ae4 <alltraps>

80107583 <vector125>:
.globl vector125
vector125:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $125
80107585:	6a 7d                	push   $0x7d
  jmp alltraps
80107587:	e9 58 f5 ff ff       	jmp    80106ae4 <alltraps>

8010758c <vector126>:
.globl vector126
vector126:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $126
8010758e:	6a 7e                	push   $0x7e
  jmp alltraps
80107590:	e9 4f f5 ff ff       	jmp    80106ae4 <alltraps>

80107595 <vector127>:
.globl vector127
vector127:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $127
80107597:	6a 7f                	push   $0x7f
  jmp alltraps
80107599:	e9 46 f5 ff ff       	jmp    80106ae4 <alltraps>

8010759e <vector128>:
.globl vector128
vector128:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $128
801075a0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075a5:	e9 3a f5 ff ff       	jmp    80106ae4 <alltraps>

801075aa <vector129>:
.globl vector129
vector129:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $129
801075ac:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075b1:	e9 2e f5 ff ff       	jmp    80106ae4 <alltraps>

801075b6 <vector130>:
.globl vector130
vector130:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $130
801075b8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075bd:	e9 22 f5 ff ff       	jmp    80106ae4 <alltraps>

801075c2 <vector131>:
.globl vector131
vector131:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $131
801075c4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075c9:	e9 16 f5 ff ff       	jmp    80106ae4 <alltraps>

801075ce <vector132>:
.globl vector132
vector132:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $132
801075d0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075d5:	e9 0a f5 ff ff       	jmp    80106ae4 <alltraps>

801075da <vector133>:
.globl vector133
vector133:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $133
801075dc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075e1:	e9 fe f4 ff ff       	jmp    80106ae4 <alltraps>

801075e6 <vector134>:
.globl vector134
vector134:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $134
801075e8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075ed:	e9 f2 f4 ff ff       	jmp    80106ae4 <alltraps>

801075f2 <vector135>:
.globl vector135
vector135:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $135
801075f4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075f9:	e9 e6 f4 ff ff       	jmp    80106ae4 <alltraps>

801075fe <vector136>:
.globl vector136
vector136:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $136
80107600:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107605:	e9 da f4 ff ff       	jmp    80106ae4 <alltraps>

8010760a <vector137>:
.globl vector137
vector137:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $137
8010760c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107611:	e9 ce f4 ff ff       	jmp    80106ae4 <alltraps>

80107616 <vector138>:
.globl vector138
vector138:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $138
80107618:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010761d:	e9 c2 f4 ff ff       	jmp    80106ae4 <alltraps>

80107622 <vector139>:
.globl vector139
vector139:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $139
80107624:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107629:	e9 b6 f4 ff ff       	jmp    80106ae4 <alltraps>

8010762e <vector140>:
.globl vector140
vector140:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $140
80107630:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107635:	e9 aa f4 ff ff       	jmp    80106ae4 <alltraps>

8010763a <vector141>:
.globl vector141
vector141:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $141
8010763c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107641:	e9 9e f4 ff ff       	jmp    80106ae4 <alltraps>

80107646 <vector142>:
.globl vector142
vector142:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $142
80107648:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010764d:	e9 92 f4 ff ff       	jmp    80106ae4 <alltraps>

80107652 <vector143>:
.globl vector143
vector143:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $143
80107654:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107659:	e9 86 f4 ff ff       	jmp    80106ae4 <alltraps>

8010765e <vector144>:
.globl vector144
vector144:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $144
80107660:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107665:	e9 7a f4 ff ff       	jmp    80106ae4 <alltraps>

8010766a <vector145>:
.globl vector145
vector145:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $145
8010766c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107671:	e9 6e f4 ff ff       	jmp    80106ae4 <alltraps>

80107676 <vector146>:
.globl vector146
vector146:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $146
80107678:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010767d:	e9 62 f4 ff ff       	jmp    80106ae4 <alltraps>

80107682 <vector147>:
.globl vector147
vector147:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $147
80107684:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107689:	e9 56 f4 ff ff       	jmp    80106ae4 <alltraps>

8010768e <vector148>:
.globl vector148
vector148:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $148
80107690:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107695:	e9 4a f4 ff ff       	jmp    80106ae4 <alltraps>

8010769a <vector149>:
.globl vector149
vector149:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $149
8010769c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076a1:	e9 3e f4 ff ff       	jmp    80106ae4 <alltraps>

801076a6 <vector150>:
.globl vector150
vector150:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $150
801076a8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076ad:	e9 32 f4 ff ff       	jmp    80106ae4 <alltraps>

801076b2 <vector151>:
.globl vector151
vector151:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $151
801076b4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076b9:	e9 26 f4 ff ff       	jmp    80106ae4 <alltraps>

801076be <vector152>:
.globl vector152
vector152:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $152
801076c0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076c5:	e9 1a f4 ff ff       	jmp    80106ae4 <alltraps>

801076ca <vector153>:
.globl vector153
vector153:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $153
801076cc:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076d1:	e9 0e f4 ff ff       	jmp    80106ae4 <alltraps>

801076d6 <vector154>:
.globl vector154
vector154:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $154
801076d8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076dd:	e9 02 f4 ff ff       	jmp    80106ae4 <alltraps>

801076e2 <vector155>:
.globl vector155
vector155:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $155
801076e4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076e9:	e9 f6 f3 ff ff       	jmp    80106ae4 <alltraps>

801076ee <vector156>:
.globl vector156
vector156:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $156
801076f0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076f5:	e9 ea f3 ff ff       	jmp    80106ae4 <alltraps>

801076fa <vector157>:
.globl vector157
vector157:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $157
801076fc:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107701:	e9 de f3 ff ff       	jmp    80106ae4 <alltraps>

80107706 <vector158>:
.globl vector158
vector158:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $158
80107708:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010770d:	e9 d2 f3 ff ff       	jmp    80106ae4 <alltraps>

80107712 <vector159>:
.globl vector159
vector159:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $159
80107714:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107719:	e9 c6 f3 ff ff       	jmp    80106ae4 <alltraps>

8010771e <vector160>:
.globl vector160
vector160:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $160
80107720:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107725:	e9 ba f3 ff ff       	jmp    80106ae4 <alltraps>

8010772a <vector161>:
.globl vector161
vector161:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $161
8010772c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107731:	e9 ae f3 ff ff       	jmp    80106ae4 <alltraps>

80107736 <vector162>:
.globl vector162
vector162:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $162
80107738:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010773d:	e9 a2 f3 ff ff       	jmp    80106ae4 <alltraps>

80107742 <vector163>:
.globl vector163
vector163:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $163
80107744:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107749:	e9 96 f3 ff ff       	jmp    80106ae4 <alltraps>

8010774e <vector164>:
.globl vector164
vector164:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $164
80107750:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107755:	e9 8a f3 ff ff       	jmp    80106ae4 <alltraps>

8010775a <vector165>:
.globl vector165
vector165:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $165
8010775c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107761:	e9 7e f3 ff ff       	jmp    80106ae4 <alltraps>

80107766 <vector166>:
.globl vector166
vector166:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $166
80107768:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010776d:	e9 72 f3 ff ff       	jmp    80106ae4 <alltraps>

80107772 <vector167>:
.globl vector167
vector167:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $167
80107774:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107779:	e9 66 f3 ff ff       	jmp    80106ae4 <alltraps>

8010777e <vector168>:
.globl vector168
vector168:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $168
80107780:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107785:	e9 5a f3 ff ff       	jmp    80106ae4 <alltraps>

8010778a <vector169>:
.globl vector169
vector169:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $169
8010778c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107791:	e9 4e f3 ff ff       	jmp    80106ae4 <alltraps>

80107796 <vector170>:
.globl vector170
vector170:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $170
80107798:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010779d:	e9 42 f3 ff ff       	jmp    80106ae4 <alltraps>

801077a2 <vector171>:
.globl vector171
vector171:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $171
801077a4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077a9:	e9 36 f3 ff ff       	jmp    80106ae4 <alltraps>

801077ae <vector172>:
.globl vector172
vector172:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $172
801077b0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077b5:	e9 2a f3 ff ff       	jmp    80106ae4 <alltraps>

801077ba <vector173>:
.globl vector173
vector173:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $173
801077bc:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077c1:	e9 1e f3 ff ff       	jmp    80106ae4 <alltraps>

801077c6 <vector174>:
.globl vector174
vector174:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $174
801077c8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077cd:	e9 12 f3 ff ff       	jmp    80106ae4 <alltraps>

801077d2 <vector175>:
.globl vector175
vector175:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $175
801077d4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077d9:	e9 06 f3 ff ff       	jmp    80106ae4 <alltraps>

801077de <vector176>:
.globl vector176
vector176:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $176
801077e0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077e5:	e9 fa f2 ff ff       	jmp    80106ae4 <alltraps>

801077ea <vector177>:
.globl vector177
vector177:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $177
801077ec:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077f1:	e9 ee f2 ff ff       	jmp    80106ae4 <alltraps>

801077f6 <vector178>:
.globl vector178
vector178:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $178
801077f8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077fd:	e9 e2 f2 ff ff       	jmp    80106ae4 <alltraps>

80107802 <vector179>:
.globl vector179
vector179:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $179
80107804:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107809:	e9 d6 f2 ff ff       	jmp    80106ae4 <alltraps>

8010780e <vector180>:
.globl vector180
vector180:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $180
80107810:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107815:	e9 ca f2 ff ff       	jmp    80106ae4 <alltraps>

8010781a <vector181>:
.globl vector181
vector181:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $181
8010781c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107821:	e9 be f2 ff ff       	jmp    80106ae4 <alltraps>

80107826 <vector182>:
.globl vector182
vector182:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $182
80107828:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010782d:	e9 b2 f2 ff ff       	jmp    80106ae4 <alltraps>

80107832 <vector183>:
.globl vector183
vector183:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $183
80107834:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107839:	e9 a6 f2 ff ff       	jmp    80106ae4 <alltraps>

8010783e <vector184>:
.globl vector184
vector184:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $184
80107840:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107845:	e9 9a f2 ff ff       	jmp    80106ae4 <alltraps>

8010784a <vector185>:
.globl vector185
vector185:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $185
8010784c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107851:	e9 8e f2 ff ff       	jmp    80106ae4 <alltraps>

80107856 <vector186>:
.globl vector186
vector186:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $186
80107858:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010785d:	e9 82 f2 ff ff       	jmp    80106ae4 <alltraps>

80107862 <vector187>:
.globl vector187
vector187:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $187
80107864:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107869:	e9 76 f2 ff ff       	jmp    80106ae4 <alltraps>

8010786e <vector188>:
.globl vector188
vector188:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $188
80107870:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107875:	e9 6a f2 ff ff       	jmp    80106ae4 <alltraps>

8010787a <vector189>:
.globl vector189
vector189:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $189
8010787c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107881:	e9 5e f2 ff ff       	jmp    80106ae4 <alltraps>

80107886 <vector190>:
.globl vector190
vector190:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $190
80107888:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010788d:	e9 52 f2 ff ff       	jmp    80106ae4 <alltraps>

80107892 <vector191>:
.globl vector191
vector191:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $191
80107894:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107899:	e9 46 f2 ff ff       	jmp    80106ae4 <alltraps>

8010789e <vector192>:
.globl vector192
vector192:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $192
801078a0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078a5:	e9 3a f2 ff ff       	jmp    80106ae4 <alltraps>

801078aa <vector193>:
.globl vector193
vector193:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $193
801078ac:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078b1:	e9 2e f2 ff ff       	jmp    80106ae4 <alltraps>

801078b6 <vector194>:
.globl vector194
vector194:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $194
801078b8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078bd:	e9 22 f2 ff ff       	jmp    80106ae4 <alltraps>

801078c2 <vector195>:
.globl vector195
vector195:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $195
801078c4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078c9:	e9 16 f2 ff ff       	jmp    80106ae4 <alltraps>

801078ce <vector196>:
.globl vector196
vector196:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $196
801078d0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078d5:	e9 0a f2 ff ff       	jmp    80106ae4 <alltraps>

801078da <vector197>:
.globl vector197
vector197:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $197
801078dc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078e1:	e9 fe f1 ff ff       	jmp    80106ae4 <alltraps>

801078e6 <vector198>:
.globl vector198
vector198:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $198
801078e8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078ed:	e9 f2 f1 ff ff       	jmp    80106ae4 <alltraps>

801078f2 <vector199>:
.globl vector199
vector199:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $199
801078f4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078f9:	e9 e6 f1 ff ff       	jmp    80106ae4 <alltraps>

801078fe <vector200>:
.globl vector200
vector200:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $200
80107900:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107905:	e9 da f1 ff ff       	jmp    80106ae4 <alltraps>

8010790a <vector201>:
.globl vector201
vector201:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $201
8010790c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107911:	e9 ce f1 ff ff       	jmp    80106ae4 <alltraps>

80107916 <vector202>:
.globl vector202
vector202:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $202
80107918:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010791d:	e9 c2 f1 ff ff       	jmp    80106ae4 <alltraps>

80107922 <vector203>:
.globl vector203
vector203:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $203
80107924:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107929:	e9 b6 f1 ff ff       	jmp    80106ae4 <alltraps>

8010792e <vector204>:
.globl vector204
vector204:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $204
80107930:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107935:	e9 aa f1 ff ff       	jmp    80106ae4 <alltraps>

8010793a <vector205>:
.globl vector205
vector205:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $205
8010793c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107941:	e9 9e f1 ff ff       	jmp    80106ae4 <alltraps>

80107946 <vector206>:
.globl vector206
vector206:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $206
80107948:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010794d:	e9 92 f1 ff ff       	jmp    80106ae4 <alltraps>

80107952 <vector207>:
.globl vector207
vector207:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $207
80107954:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107959:	e9 86 f1 ff ff       	jmp    80106ae4 <alltraps>

8010795e <vector208>:
.globl vector208
vector208:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $208
80107960:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107965:	e9 7a f1 ff ff       	jmp    80106ae4 <alltraps>

8010796a <vector209>:
.globl vector209
vector209:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $209
8010796c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107971:	e9 6e f1 ff ff       	jmp    80106ae4 <alltraps>

80107976 <vector210>:
.globl vector210
vector210:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $210
80107978:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010797d:	e9 62 f1 ff ff       	jmp    80106ae4 <alltraps>

80107982 <vector211>:
.globl vector211
vector211:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $211
80107984:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107989:	e9 56 f1 ff ff       	jmp    80106ae4 <alltraps>

8010798e <vector212>:
.globl vector212
vector212:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $212
80107990:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107995:	e9 4a f1 ff ff       	jmp    80106ae4 <alltraps>

8010799a <vector213>:
.globl vector213
vector213:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $213
8010799c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079a1:	e9 3e f1 ff ff       	jmp    80106ae4 <alltraps>

801079a6 <vector214>:
.globl vector214
vector214:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $214
801079a8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079ad:	e9 32 f1 ff ff       	jmp    80106ae4 <alltraps>

801079b2 <vector215>:
.globl vector215
vector215:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $215
801079b4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079b9:	e9 26 f1 ff ff       	jmp    80106ae4 <alltraps>

801079be <vector216>:
.globl vector216
vector216:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $216
801079c0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079c5:	e9 1a f1 ff ff       	jmp    80106ae4 <alltraps>

801079ca <vector217>:
.globl vector217
vector217:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $217
801079cc:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079d1:	e9 0e f1 ff ff       	jmp    80106ae4 <alltraps>

801079d6 <vector218>:
.globl vector218
vector218:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $218
801079d8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079dd:	e9 02 f1 ff ff       	jmp    80106ae4 <alltraps>

801079e2 <vector219>:
.globl vector219
vector219:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $219
801079e4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079e9:	e9 f6 f0 ff ff       	jmp    80106ae4 <alltraps>

801079ee <vector220>:
.globl vector220
vector220:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $220
801079f0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079f5:	e9 ea f0 ff ff       	jmp    80106ae4 <alltraps>

801079fa <vector221>:
.globl vector221
vector221:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $221
801079fc:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a01:	e9 de f0 ff ff       	jmp    80106ae4 <alltraps>

80107a06 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a06:	6a 00                	push   $0x0
  pushl $222
80107a08:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a0d:	e9 d2 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a12 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $223
80107a14:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a19:	e9 c6 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a1e <vector224>:
.globl vector224
vector224:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $224
80107a20:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a25:	e9 ba f0 ff ff       	jmp    80106ae4 <alltraps>

80107a2a <vector225>:
.globl vector225
vector225:
  pushl $0
80107a2a:	6a 00                	push   $0x0
  pushl $225
80107a2c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a31:	e9 ae f0 ff ff       	jmp    80106ae4 <alltraps>

80107a36 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $226
80107a38:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a3d:	e9 a2 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a42 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $227
80107a44:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a49:	e9 96 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a4e <vector228>:
.globl vector228
vector228:
  pushl $0
80107a4e:	6a 00                	push   $0x0
  pushl $228
80107a50:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a55:	e9 8a f0 ff ff       	jmp    80106ae4 <alltraps>

80107a5a <vector229>:
.globl vector229
vector229:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $229
80107a5c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a61:	e9 7e f0 ff ff       	jmp    80106ae4 <alltraps>

80107a66 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $230
80107a68:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a6d:	e9 72 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a72 <vector231>:
.globl vector231
vector231:
  pushl $0
80107a72:	6a 00                	push   $0x0
  pushl $231
80107a74:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a79:	e9 66 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a7e <vector232>:
.globl vector232
vector232:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $232
80107a80:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a85:	e9 5a f0 ff ff       	jmp    80106ae4 <alltraps>

80107a8a <vector233>:
.globl vector233
vector233:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $233
80107a8c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a91:	e9 4e f0 ff ff       	jmp    80106ae4 <alltraps>

80107a96 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a96:	6a 00                	push   $0x0
  pushl $234
80107a98:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a9d:	e9 42 f0 ff ff       	jmp    80106ae4 <alltraps>

80107aa2 <vector235>:
.globl vector235
vector235:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $235
80107aa4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107aa9:	e9 36 f0 ff ff       	jmp    80106ae4 <alltraps>

80107aae <vector236>:
.globl vector236
vector236:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $236
80107ab0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ab5:	e9 2a f0 ff ff       	jmp    80106ae4 <alltraps>

80107aba <vector237>:
.globl vector237
vector237:
  pushl $0
80107aba:	6a 00                	push   $0x0
  pushl $237
80107abc:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ac1:	e9 1e f0 ff ff       	jmp    80106ae4 <alltraps>

80107ac6 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $238
80107ac8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107acd:	e9 12 f0 ff ff       	jmp    80106ae4 <alltraps>

80107ad2 <vector239>:
.globl vector239
vector239:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $239
80107ad4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ad9:	e9 06 f0 ff ff       	jmp    80106ae4 <alltraps>

80107ade <vector240>:
.globl vector240
vector240:
  pushl $0
80107ade:	6a 00                	push   $0x0
  pushl $240
80107ae0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107ae5:	e9 fa ef ff ff       	jmp    80106ae4 <alltraps>

80107aea <vector241>:
.globl vector241
vector241:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $241
80107aec:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107af1:	e9 ee ef ff ff       	jmp    80106ae4 <alltraps>

80107af6 <vector242>:
.globl vector242
vector242:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $242
80107af8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107afd:	e9 e2 ef ff ff       	jmp    80106ae4 <alltraps>

80107b02 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b02:	6a 00                	push   $0x0
  pushl $243
80107b04:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b09:	e9 d6 ef ff ff       	jmp    80106ae4 <alltraps>

80107b0e <vector244>:
.globl vector244
vector244:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $244
80107b10:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b15:	e9 ca ef ff ff       	jmp    80106ae4 <alltraps>

80107b1a <vector245>:
.globl vector245
vector245:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $245
80107b1c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b21:	e9 be ef ff ff       	jmp    80106ae4 <alltraps>

80107b26 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $246
80107b28:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b2d:	e9 b2 ef ff ff       	jmp    80106ae4 <alltraps>

80107b32 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $247
80107b34:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b39:	e9 a6 ef ff ff       	jmp    80106ae4 <alltraps>

80107b3e <vector248>:
.globl vector248
vector248:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $248
80107b40:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b45:	e9 9a ef ff ff       	jmp    80106ae4 <alltraps>

80107b4a <vector249>:
.globl vector249
vector249:
  pushl $0
80107b4a:	6a 00                	push   $0x0
  pushl $249
80107b4c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b51:	e9 8e ef ff ff       	jmp    80106ae4 <alltraps>

80107b56 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $250
80107b58:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b5d:	e9 82 ef ff ff       	jmp    80106ae4 <alltraps>

80107b62 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $251
80107b64:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b69:	e9 76 ef ff ff       	jmp    80106ae4 <alltraps>

80107b6e <vector252>:
.globl vector252
vector252:
  pushl $0
80107b6e:	6a 00                	push   $0x0
  pushl $252
80107b70:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b75:	e9 6a ef ff ff       	jmp    80106ae4 <alltraps>

80107b7a <vector253>:
.globl vector253
vector253:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $253
80107b7c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b81:	e9 5e ef ff ff       	jmp    80106ae4 <alltraps>

80107b86 <vector254>:
.globl vector254
vector254:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $254
80107b88:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b8d:	e9 52 ef ff ff       	jmp    80106ae4 <alltraps>

80107b92 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b92:	6a 00                	push   $0x0
  pushl $255
80107b94:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b99:	e9 46 ef ff ff       	jmp    80106ae4 <alltraps>
	...

80107ba0 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107ba0:	55                   	push   %ebp
80107ba1:	89 e5                	mov    %esp,%ebp
80107ba3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ba9:	48                   	dec    %eax
80107baa:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bae:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb8:	c1 e8 10             	shr    $0x10,%eax
80107bbb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107bbf:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bc2:	0f 01 10             	lgdtl  (%eax)
}
80107bc5:	c9                   	leave  
80107bc6:	c3                   	ret    

80107bc7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107bc7:	55                   	push   %ebp
80107bc8:	89 e5                	mov    %esp,%ebp
80107bca:	83 ec 04             	sub    $0x4,%esp
80107bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107bd7:	0f 00 d8             	ltr    %ax
}
80107bda:	c9                   	leave  
80107bdb:	c3                   	ret    

80107bdc <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107bdc:	55                   	push   %ebp
80107bdd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80107be2:	0f 22 d8             	mov    %eax,%cr3
}
80107be5:	5d                   	pop    %ebp
80107be6:	c3                   	ret    

80107be7 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107be7:	55                   	push   %ebp
80107be8:	89 e5                	mov    %esp,%ebp
80107bea:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107bed:	e8 78 c6 ff ff       	call   8010426a <cpuid>
80107bf2:	89 c2                	mov    %eax,%edx
80107bf4:	89 d0                	mov    %edx,%eax
80107bf6:	c1 e0 02             	shl    $0x2,%eax
80107bf9:	01 d0                	add    %edx,%eax
80107bfb:	01 c0                	add    %eax,%eax
80107bfd:	01 d0                	add    %edx,%eax
80107bff:	c1 e0 04             	shl    $0x4,%eax
80107c02:	05 80 4c 11 80       	add    $0x80114c80,%eax
80107c07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c16:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c29:	83 e2 f0             	and    $0xfffffff0,%edx
80107c2c:	83 ca 0a             	or     $0xa,%edx
80107c2f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c35:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c38:	83 ca 10             	or     $0x10,%edx
80107c3b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c44:	83 e2 9f             	and    $0xffffff9f,%edx
80107c47:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4d:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c50:	83 ca 80             	or     $0xffffff80,%edx
80107c53:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c59:	8a 50 7e             	mov    0x7e(%eax),%dl
80107c5c:	83 ca 0f             	or     $0xf,%edx
80107c5f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c65:	8a 50 7e             	mov    0x7e(%eax),%dl
80107c68:	83 e2 ef             	and    $0xffffffef,%edx
80107c6b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	8a 50 7e             	mov    0x7e(%eax),%dl
80107c74:	83 e2 df             	and    $0xffffffdf,%edx
80107c77:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107c80:	83 ca 40             	or     $0x40,%edx
80107c83:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	8a 50 7e             	mov    0x7e(%eax),%dl
80107c8c:	83 ca 80             	or     $0xffffff80,%edx
80107c8f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c95:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ca3:	ff ff 
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107caf:	00 00 
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbe:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107cc4:	83 e2 f0             	and    $0xfffffff0,%edx
80107cc7:	83 ca 02             	or     $0x2,%edx
80107cca:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107cd9:	83 ca 10             	or     $0x10,%edx
80107cdc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce5:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107ceb:	83 e2 9f             	and    $0xffffff9f,%edx
80107cee:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf7:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107cfd:	83 ca 80             	or     $0xffffff80,%edx
80107d00:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d0f:	83 ca 0f             	or     $0xf,%edx
80107d12:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d21:	83 e2 ef             	and    $0xffffffef,%edx
80107d24:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d33:	83 e2 df             	and    $0xffffffdf,%edx
80107d36:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d45:	83 ca 40             	or     $0x40,%edx
80107d48:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d51:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d57:	83 ca 80             	or     $0xffffff80,%edx
80107d5a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d63:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107d74:	ff ff 
80107d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d79:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107d80:	00 00 
80107d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d85:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107d95:	83 e2 f0             	and    $0xfffffff0,%edx
80107d98:	83 ca 0a             	or     $0xa,%edx
80107d9b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da4:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107daa:	83 ca 10             	or     $0x10,%edx
80107dad:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db6:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107dbc:	83 ca 60             	or     $0x60,%edx
80107dbf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107dce:	83 ca 80             	or     $0xffffff80,%edx
80107dd1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dda:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107de0:	83 ca 0f             	or     $0xf,%edx
80107de3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107df2:	83 e2 ef             	and    $0xffffffef,%edx
80107df5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfe:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e04:	83 e2 df             	and    $0xffffffdf,%edx
80107e07:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e10:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e16:	83 ca 40             	or     $0x40,%edx
80107e19:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e22:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e28:	83 ca 80             	or     $0xffffff80,%edx
80107e2b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e45:	ff ff 
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e51:	00 00 
80107e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e56:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e60:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107e66:	83 e2 f0             	and    $0xfffffff0,%edx
80107e69:	83 ca 02             	or     $0x2,%edx
80107e6c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107e7b:	83 ca 10             	or     $0x10,%edx
80107e7e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e87:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107e8d:	83 ca 60             	or     $0x60,%edx
80107e90:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e99:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107e9f:	83 ca 80             	or     $0xffffff80,%edx
80107ea2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eab:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107eb1:	83 ca 0f             	or     $0xf,%edx
80107eb4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107ec3:	83 e2 ef             	and    $0xffffffef,%edx
80107ec6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecf:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107ed5:	83 e2 df             	and    $0xffffffdf,%edx
80107ed8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee1:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107ee7:	83 ca 40             	or     $0x40,%edx
80107eea:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107ef9:	83 ca 80             	or     $0xffffff80,%edx
80107efc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f05:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0f:	83 c0 70             	add    $0x70,%eax
80107f12:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107f19:	00 
80107f1a:	89 04 24             	mov    %eax,(%esp)
80107f1d:	e8 7e fc ff ff       	call   80107ba0 <lgdt>
}
80107f22:	c9                   	leave  
80107f23:	c3                   	ret    

80107f24 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f24:	55                   	push   %ebp
80107f25:	89 e5                	mov    %esp,%ebp
80107f27:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f2d:	c1 e8 16             	shr    $0x16,%eax
80107f30:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f37:	8b 45 08             	mov    0x8(%ebp),%eax
80107f3a:	01 d0                	add    %edx,%eax
80107f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f42:	8b 00                	mov    (%eax),%eax
80107f44:	83 e0 01             	and    $0x1,%eax
80107f47:	85 c0                	test   %eax,%eax
80107f49:	74 14                	je     80107f5f <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f4e:	8b 00                	mov    (%eax),%eax
80107f50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f55:	05 00 00 00 80       	add    $0x80000000,%eax
80107f5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f5d:	eb 48                	jmp    80107fa7 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f63:	74 0e                	je     80107f73 <walkpgdir+0x4f>
80107f65:	e8 c5 ad ff ff       	call   80102d2f <kalloc>
80107f6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f71:	75 07                	jne    80107f7a <walkpgdir+0x56>
      return 0;
80107f73:	b8 00 00 00 00       	mov    $0x0,%eax
80107f78:	eb 44                	jmp    80107fbe <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f7a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f81:	00 
80107f82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f89:	00 
80107f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8d:	89 04 24             	mov    %eax,(%esp)
80107f90:	e8 09 d4 ff ff       	call   8010539e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f98:	05 00 00 00 80       	add    $0x80000000,%eax
80107f9d:	83 c8 07             	or     $0x7,%eax
80107fa0:	89 c2                	mov    %eax,%edx
80107fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107faa:	c1 e8 0c             	shr    $0xc,%eax
80107fad:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	01 d0                	add    %edx,%eax
}
80107fbe:	c9                   	leave  
80107fbf:	c3                   	ret    

80107fc0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fc0:	55                   	push   %ebp
80107fc1:	89 e5                	mov    %esp,%ebp
80107fc3:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107fd1:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80107fd7:	01 d0                	add    %edx,%eax
80107fd9:	48                   	dec    %eax
80107fda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fe2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107fe9:	00 
80107fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fed:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ff4:	89 04 24             	mov    %eax,(%esp)
80107ff7:	e8 28 ff ff ff       	call   80107f24 <walkpgdir>
80107ffc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108003:	75 07                	jne    8010800c <mappages+0x4c>
      return -1;
80108005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010800a:	eb 48                	jmp    80108054 <mappages+0x94>
    if(*pte & PTE_P)
8010800c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010800f:	8b 00                	mov    (%eax),%eax
80108011:	83 e0 01             	and    $0x1,%eax
80108014:	85 c0                	test   %eax,%eax
80108016:	74 0c                	je     80108024 <mappages+0x64>
      panic("remap");
80108018:	c7 04 24 98 95 10 80 	movl   $0x80109598,(%esp)
8010801f:	e8 30 85 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108024:	8b 45 18             	mov    0x18(%ebp),%eax
80108027:	0b 45 14             	or     0x14(%ebp),%eax
8010802a:	83 c8 01             	or     $0x1,%eax
8010802d:	89 c2                	mov    %eax,%edx
8010802f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108032:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108037:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010803a:	75 08                	jne    80108044 <mappages+0x84>
      break;
8010803c:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010803d:	b8 00 00 00 00       	mov    $0x0,%eax
80108042:	eb 10                	jmp    80108054 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108044:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010804b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108052:	eb 8e                	jmp    80107fe2 <mappages+0x22>
  return 0;
}
80108054:	c9                   	leave  
80108055:	c3                   	ret    

80108056 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108056:	55                   	push   %ebp
80108057:	89 e5                	mov    %esp,%ebp
80108059:	53                   	push   %ebx
8010805a:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010805d:	e8 cd ac ff ff       	call   80102d2f <kalloc>
80108062:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108065:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108069:	75 0a                	jne    80108075 <setupkvm+0x1f>
    return 0;
8010806b:	b8 00 00 00 00       	mov    $0x0,%eax
80108070:	e9 84 00 00 00       	jmp    801080f9 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108075:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010807c:	00 
8010807d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108084:	00 
80108085:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108088:	89 04 24             	mov    %eax,(%esp)
8010808b:	e8 0e d3 ff ff       	call   8010539e <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108090:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
80108097:	eb 54                	jmp    801080ed <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809c:	8b 48 0c             	mov    0xc(%eax),%ecx
8010809f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a2:	8b 50 04             	mov    0x4(%eax),%edx
801080a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a8:	8b 58 08             	mov    0x8(%eax),%ebx
801080ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ae:	8b 40 04             	mov    0x4(%eax),%eax
801080b1:	29 c3                	sub    %eax,%ebx
801080b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b6:	8b 00                	mov    (%eax),%eax
801080b8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801080bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801080c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cb:	89 04 24             	mov    %eax,(%esp)
801080ce:	e8 ed fe ff ff       	call   80107fc0 <mappages>
801080d3:	85 c0                	test   %eax,%eax
801080d5:	79 12                	jns    801080e9 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
801080d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080da:	89 04 24             	mov    %eax,(%esp)
801080dd:	e8 1a 05 00 00       	call   801085fc <freevm>
      return 0;
801080e2:	b8 00 00 00 00       	mov    $0x0,%eax
801080e7:	eb 10                	jmp    801080f9 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080e9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080ed:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
801080f4:	72 a3                	jb     80108099 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
801080f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080f9:	83 c4 34             	add    $0x34,%esp
801080fc:	5b                   	pop    %ebx
801080fd:	5d                   	pop    %ebp
801080fe:	c3                   	ret    

801080ff <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080ff:	55                   	push   %ebp
80108100:	89 e5                	mov    %esp,%ebp
80108102:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108105:	e8 4c ff ff ff       	call   80108056 <setupkvm>
8010810a:	a3 a4 7b 11 80       	mov    %eax,0x80117ba4
  switchkvm();
8010810f:	e8 02 00 00 00       	call   80108116 <switchkvm>
}
80108114:	c9                   	leave  
80108115:	c3                   	ret    

80108116 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108116:	55                   	push   %ebp
80108117:	89 e5                	mov    %esp,%ebp
80108119:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010811c:	a1 a4 7b 11 80       	mov    0x80117ba4,%eax
80108121:	05 00 00 00 80       	add    $0x80000000,%eax
80108126:	89 04 24             	mov    %eax,(%esp)
80108129:	e8 ae fa ff ff       	call   80107bdc <lcr3>
}
8010812e:	c9                   	leave  
8010812f:	c3                   	ret    

80108130 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108130:	55                   	push   %ebp
80108131:	89 e5                	mov    %esp,%ebp
80108133:	57                   	push   %edi
80108134:	56                   	push   %esi
80108135:	53                   	push   %ebx
80108136:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108139:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010813d:	75 0c                	jne    8010814b <switchuvm+0x1b>
    panic("switchuvm: no process");
8010813f:	c7 04 24 9e 95 10 80 	movl   $0x8010959e,(%esp)
80108146:	e8 09 84 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
8010814b:	8b 45 08             	mov    0x8(%ebp),%eax
8010814e:	8b 40 08             	mov    0x8(%eax),%eax
80108151:	85 c0                	test   %eax,%eax
80108153:	75 0c                	jne    80108161 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108155:	c7 04 24 b4 95 10 80 	movl   $0x801095b4,(%esp)
8010815c:	e8 f3 83 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80108161:	8b 45 08             	mov    0x8(%ebp),%eax
80108164:	8b 40 04             	mov    0x4(%eax),%eax
80108167:	85 c0                	test   %eax,%eax
80108169:	75 0c                	jne    80108177 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
8010816b:	c7 04 24 c9 95 10 80 	movl   $0x801095c9,(%esp)
80108172:	e8 dd 83 ff ff       	call   80100554 <panic>

  pushcli();
80108177:	e8 1e d1 ff ff       	call   8010529a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010817c:	e8 2e c1 ff ff       	call   801042af <mycpu>
80108181:	89 c3                	mov    %eax,%ebx
80108183:	e8 27 c1 ff ff       	call   801042af <mycpu>
80108188:	83 c0 08             	add    $0x8,%eax
8010818b:	89 c6                	mov    %eax,%esi
8010818d:	e8 1d c1 ff ff       	call   801042af <mycpu>
80108192:	83 c0 08             	add    $0x8,%eax
80108195:	c1 e8 10             	shr    $0x10,%eax
80108198:	89 c7                	mov    %eax,%edi
8010819a:	e8 10 c1 ff ff       	call   801042af <mycpu>
8010819f:	83 c0 08             	add    $0x8,%eax
801081a2:	c1 e8 18             	shr    $0x18,%eax
801081a5:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801081ac:	67 00 
801081ae:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801081b5:	89 f9                	mov    %edi,%ecx
801081b7:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801081bd:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801081c3:	83 e2 f0             	and    $0xfffffff0,%edx
801081c6:	83 ca 09             	or     $0x9,%edx
801081c9:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801081cf:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801081d5:	83 ca 10             	or     $0x10,%edx
801081d8:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801081de:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801081e4:	83 e2 9f             	and    $0xffffff9f,%edx
801081e7:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801081ed:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801081f3:	83 ca 80             	or     $0xffffff80,%edx
801081f6:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801081fc:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108202:	83 e2 f0             	and    $0xfffffff0,%edx
80108205:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010820b:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108211:	83 e2 ef             	and    $0xffffffef,%edx
80108214:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010821a:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108220:	83 e2 df             	and    $0xffffffdf,%edx
80108223:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108229:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010822f:	83 ca 40             	or     $0x40,%edx
80108232:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108238:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010823e:	83 e2 7f             	and    $0x7f,%edx
80108241:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108247:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010824d:	e8 5d c0 ff ff       	call   801042af <mycpu>
80108252:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108258:	83 e2 ef             	and    $0xffffffef,%edx
8010825b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108261:	e8 49 c0 ff ff       	call   801042af <mycpu>
80108266:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010826c:	e8 3e c0 ff ff       	call   801042af <mycpu>
80108271:	8b 55 08             	mov    0x8(%ebp),%edx
80108274:	8b 52 08             	mov    0x8(%edx),%edx
80108277:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010827d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108280:	e8 2a c0 ff ff       	call   801042af <mycpu>
80108285:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010828b:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108292:	e8 30 f9 ff ff       	call   80107bc7 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108297:	8b 45 08             	mov    0x8(%ebp),%eax
8010829a:	8b 40 04             	mov    0x4(%eax),%eax
8010829d:	05 00 00 00 80       	add    $0x80000000,%eax
801082a2:	89 04 24             	mov    %eax,(%esp)
801082a5:	e8 32 f9 ff ff       	call   80107bdc <lcr3>
  popcli();
801082aa:	e8 35 d0 ff ff       	call   801052e4 <popcli>
}
801082af:	83 c4 1c             	add    $0x1c,%esp
801082b2:	5b                   	pop    %ebx
801082b3:	5e                   	pop    %esi
801082b4:	5f                   	pop    %edi
801082b5:	5d                   	pop    %ebp
801082b6:	c3                   	ret    

801082b7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801082b7:	55                   	push   %ebp
801082b8:	89 e5                	mov    %esp,%ebp
801082ba:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
801082bd:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801082c4:	76 0c                	jbe    801082d2 <inituvm+0x1b>
    panic("inituvm: more than a page");
801082c6:	c7 04 24 dd 95 10 80 	movl   $0x801095dd,(%esp)
801082cd:	e8 82 82 ff ff       	call   80100554 <panic>
  mem = kalloc();
801082d2:	e8 58 aa ff ff       	call   80102d2f <kalloc>
801082d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082da:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082e1:	00 
801082e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082e9:	00 
801082ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ed:	89 04 24             	mov    %eax,(%esp)
801082f0:	e8 a9 d0 ff ff       	call   8010539e <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801082f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f8:	05 00 00 00 80       	add    $0x80000000,%eax
801082fd:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108304:	00 
80108305:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108309:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108310:	00 
80108311:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108318:	00 
80108319:	8b 45 08             	mov    0x8(%ebp),%eax
8010831c:	89 04 24             	mov    %eax,(%esp)
8010831f:	e8 9c fc ff ff       	call   80107fc0 <mappages>
  memmove(mem, init, sz);
80108324:	8b 45 10             	mov    0x10(%ebp),%eax
80108327:	89 44 24 08          	mov    %eax,0x8(%esp)
8010832b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010832e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108335:	89 04 24             	mov    %eax,(%esp)
80108338:	e8 2a d1 ff ff       	call   80105467 <memmove>
}
8010833d:	c9                   	leave  
8010833e:	c3                   	ret    

8010833f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010833f:	55                   	push   %ebp
80108340:	89 e5                	mov    %esp,%ebp
80108342:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108345:	8b 45 0c             	mov    0xc(%ebp),%eax
80108348:	25 ff 0f 00 00       	and    $0xfff,%eax
8010834d:	85 c0                	test   %eax,%eax
8010834f:	74 0c                	je     8010835d <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108351:	c7 04 24 f8 95 10 80 	movl   $0x801095f8,(%esp)
80108358:	e8 f7 81 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010835d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108364:	e9 a6 00 00 00       	jmp    8010840f <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010836f:	01 d0                	add    %edx,%eax
80108371:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108378:	00 
80108379:	89 44 24 04          	mov    %eax,0x4(%esp)
8010837d:	8b 45 08             	mov    0x8(%ebp),%eax
80108380:	89 04 24             	mov    %eax,(%esp)
80108383:	e8 9c fb ff ff       	call   80107f24 <walkpgdir>
80108388:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010838b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010838f:	75 0c                	jne    8010839d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108391:	c7 04 24 1b 96 10 80 	movl   $0x8010961b,(%esp)
80108398:	e8 b7 81 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
8010839d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a0:	8b 00                	mov    (%eax),%eax
801083a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ad:	8b 55 18             	mov    0x18(%ebp),%edx
801083b0:	29 c2                	sub    %eax,%edx
801083b2:	89 d0                	mov    %edx,%eax
801083b4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083b9:	77 0f                	ja     801083ca <loaduvm+0x8b>
      n = sz - i;
801083bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083be:	8b 55 18             	mov    0x18(%ebp),%edx
801083c1:	29 c2                	sub    %eax,%edx
801083c3:	89 d0                	mov    %edx,%eax
801083c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083c8:	eb 07                	jmp    801083d1 <loaduvm+0x92>
    else
      n = PGSIZE;
801083ca:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801083d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d4:	8b 55 14             	mov    0x14(%ebp),%edx
801083d7:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801083da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083dd:	05 00 00 00 80       	add    $0x80000000,%eax
801083e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801083ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801083f1:	8b 45 10             	mov    0x10(%ebp),%eax
801083f4:	89 04 24             	mov    %eax,(%esp)
801083f7:	e8 5d 9b ff ff       	call   80101f59 <readi>
801083fc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083ff:	74 07                	je     80108408 <loaduvm+0xc9>
      return -1;
80108401:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108406:	eb 18                	jmp    80108420 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108408:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010840f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108412:	3b 45 18             	cmp    0x18(%ebp),%eax
80108415:	0f 82 4e ff ff ff    	jb     80108369 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010841b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108420:	c9                   	leave  
80108421:	c3                   	ret    

80108422 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108422:	55                   	push   %ebp
80108423:	89 e5                	mov    %esp,%ebp
80108425:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108428:	8b 45 10             	mov    0x10(%ebp),%eax
8010842b:	85 c0                	test   %eax,%eax
8010842d:	79 0a                	jns    80108439 <allocuvm+0x17>
    return 0;
8010842f:	b8 00 00 00 00       	mov    $0x0,%eax
80108434:	e9 fd 00 00 00       	jmp    80108536 <allocuvm+0x114>
  if(newsz < oldsz)
80108439:	8b 45 10             	mov    0x10(%ebp),%eax
8010843c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010843f:	73 08                	jae    80108449 <allocuvm+0x27>
    return oldsz;
80108441:	8b 45 0c             	mov    0xc(%ebp),%eax
80108444:	e9 ed 00 00 00       	jmp    80108536 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108449:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108451:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108456:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108459:	e9 c9 00 00 00       	jmp    80108527 <allocuvm+0x105>
    mem = kalloc();
8010845e:	e8 cc a8 ff ff       	call   80102d2f <kalloc>
80108463:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108466:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010846a:	75 2f                	jne    8010849b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
8010846c:	c7 04 24 39 96 10 80 	movl   $0x80109639,(%esp)
80108473:	e8 49 7f ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108478:	8b 45 0c             	mov    0xc(%ebp),%eax
8010847b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010847f:	8b 45 10             	mov    0x10(%ebp),%eax
80108482:	89 44 24 04          	mov    %eax,0x4(%esp)
80108486:	8b 45 08             	mov    0x8(%ebp),%eax
80108489:	89 04 24             	mov    %eax,(%esp)
8010848c:	e8 a7 00 00 00       	call   80108538 <deallocuvm>
      return 0;
80108491:	b8 00 00 00 00       	mov    $0x0,%eax
80108496:	e9 9b 00 00 00       	jmp    80108536 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
8010849b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084a2:	00 
801084a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084aa:	00 
801084ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ae:	89 04 24             	mov    %eax,(%esp)
801084b1:	e8 e8 ce ff ff       	call   8010539e <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801084b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801084bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c2:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084c9:	00 
801084ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
801084ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084d5:	00 
801084d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801084da:	8b 45 08             	mov    0x8(%ebp),%eax
801084dd:	89 04 24             	mov    %eax,(%esp)
801084e0:	e8 db fa ff ff       	call   80107fc0 <mappages>
801084e5:	85 c0                	test   %eax,%eax
801084e7:	79 37                	jns    80108520 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
801084e9:	c7 04 24 51 96 10 80 	movl   $0x80109651,(%esp)
801084f0:	e8 cc 7e ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801084f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f8:	89 44 24 08          	mov    %eax,0x8(%esp)
801084fc:	8b 45 10             	mov    0x10(%ebp),%eax
801084ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108503:	8b 45 08             	mov    0x8(%ebp),%eax
80108506:	89 04 24             	mov    %eax,(%esp)
80108509:	e8 2a 00 00 00       	call   80108538 <deallocuvm>
      kfree(mem);
8010850e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108511:	89 04 24             	mov    %eax,(%esp)
80108514:	e8 44 a7 ff ff       	call   80102c5d <kfree>
      return 0;
80108519:	b8 00 00 00 00       	mov    $0x0,%eax
8010851e:	eb 16                	jmp    80108536 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108520:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010852d:	0f 82 2b ff ff ff    	jb     8010845e <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108533:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108536:	c9                   	leave  
80108537:	c3                   	ret    

80108538 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108538:	55                   	push   %ebp
80108539:	89 e5                	mov    %esp,%ebp
8010853b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010853e:	8b 45 10             	mov    0x10(%ebp),%eax
80108541:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108544:	72 08                	jb     8010854e <deallocuvm+0x16>
    return oldsz;
80108546:	8b 45 0c             	mov    0xc(%ebp),%eax
80108549:	e9 ac 00 00 00       	jmp    801085fa <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010854e:	8b 45 10             	mov    0x10(%ebp),%eax
80108551:	05 ff 0f 00 00       	add    $0xfff,%eax
80108556:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010855b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010855e:	e9 88 00 00 00       	jmp    801085eb <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108566:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010856d:	00 
8010856e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108572:	8b 45 08             	mov    0x8(%ebp),%eax
80108575:	89 04 24             	mov    %eax,(%esp)
80108578:	e8 a7 f9 ff ff       	call   80107f24 <walkpgdir>
8010857d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108580:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108584:	75 14                	jne    8010859a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108589:	c1 e8 16             	shr    $0x16,%eax
8010858c:	40                   	inc    %eax
8010858d:	c1 e0 16             	shl    $0x16,%eax
80108590:	2d 00 10 00 00       	sub    $0x1000,%eax
80108595:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108598:	eb 4a                	jmp    801085e4 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010859a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010859d:	8b 00                	mov    (%eax),%eax
8010859f:	83 e0 01             	and    $0x1,%eax
801085a2:	85 c0                	test   %eax,%eax
801085a4:	74 3e                	je     801085e4 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801085a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085a9:	8b 00                	mov    (%eax),%eax
801085ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085b7:	75 0c                	jne    801085c5 <deallocuvm+0x8d>
        panic("kfree");
801085b9:	c7 04 24 6d 96 10 80 	movl   $0x8010966d,(%esp)
801085c0:	e8 8f 7f ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
801085c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c8:	05 00 00 00 80       	add    $0x80000000,%eax
801085cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801085d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085d3:	89 04 24             	mov    %eax,(%esp)
801085d6:	e8 82 a6 ff ff       	call   80102c5d <kfree>
      *pte = 0;
801085db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801085e4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085f1:	0f 82 6c ff ff ff    	jb     80108563 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801085f7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085fa:	c9                   	leave  
801085fb:	c3                   	ret    

801085fc <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801085fc:	55                   	push   %ebp
801085fd:	89 e5                	mov    %esp,%ebp
801085ff:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108602:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108606:	75 0c                	jne    80108614 <freevm+0x18>
    panic("freevm: no pgdir");
80108608:	c7 04 24 73 96 10 80 	movl   $0x80109673,(%esp)
8010860f:	e8 40 7f ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108614:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010861b:	00 
8010861c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108623:	80 
80108624:	8b 45 08             	mov    0x8(%ebp),%eax
80108627:	89 04 24             	mov    %eax,(%esp)
8010862a:	e8 09 ff ff ff       	call   80108538 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010862f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108636:	eb 44                	jmp    8010867c <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108642:	8b 45 08             	mov    0x8(%ebp),%eax
80108645:	01 d0                	add    %edx,%eax
80108647:	8b 00                	mov    (%eax),%eax
80108649:	83 e0 01             	and    $0x1,%eax
8010864c:	85 c0                	test   %eax,%eax
8010864e:	74 29                	je     80108679 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108653:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010865a:	8b 45 08             	mov    0x8(%ebp),%eax
8010865d:	01 d0                	add    %edx,%eax
8010865f:	8b 00                	mov    (%eax),%eax
80108661:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108666:	05 00 00 00 80       	add    $0x80000000,%eax
8010866b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010866e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108671:	89 04 24             	mov    %eax,(%esp)
80108674:	e8 e4 a5 ff ff       	call   80102c5d <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108679:	ff 45 f4             	incl   -0xc(%ebp)
8010867c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108683:	76 b3                	jbe    80108638 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108685:	8b 45 08             	mov    0x8(%ebp),%eax
80108688:	89 04 24             	mov    %eax,(%esp)
8010868b:	e8 cd a5 ff ff       	call   80102c5d <kfree>
}
80108690:	c9                   	leave  
80108691:	c3                   	ret    

80108692 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108692:	55                   	push   %ebp
80108693:	89 e5                	mov    %esp,%ebp
80108695:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108698:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010869f:	00 
801086a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801086a7:	8b 45 08             	mov    0x8(%ebp),%eax
801086aa:	89 04 24             	mov    %eax,(%esp)
801086ad:	e8 72 f8 ff ff       	call   80107f24 <walkpgdir>
801086b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086b9:	75 0c                	jne    801086c7 <clearpteu+0x35>
    panic("clearpteu");
801086bb:	c7 04 24 84 96 10 80 	movl   $0x80109684,(%esp)
801086c2:	e8 8d 7e ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
801086c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ca:	8b 00                	mov    (%eax),%eax
801086cc:	83 e0 fb             	and    $0xfffffffb,%eax
801086cf:	89 c2                	mov    %eax,%edx
801086d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d4:	89 10                	mov    %edx,(%eax)
}
801086d6:	c9                   	leave  
801086d7:	c3                   	ret    

801086d8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801086d8:	55                   	push   %ebp
801086d9:	89 e5                	mov    %esp,%ebp
801086db:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801086de:	e8 73 f9 ff ff       	call   80108056 <setupkvm>
801086e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086ea:	75 0a                	jne    801086f6 <copyuvm+0x1e>
    return 0;
801086ec:	b8 00 00 00 00       	mov    $0x0,%eax
801086f1:	e9 f8 00 00 00       	jmp    801087ee <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
801086f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086fd:	e9 cb 00 00 00       	jmp    801087cd <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010870c:	00 
8010870d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108711:	8b 45 08             	mov    0x8(%ebp),%eax
80108714:	89 04 24             	mov    %eax,(%esp)
80108717:	e8 08 f8 ff ff       	call   80107f24 <walkpgdir>
8010871c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010871f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108723:	75 0c                	jne    80108731 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108725:	c7 04 24 8e 96 10 80 	movl   $0x8010968e,(%esp)
8010872c:	e8 23 7e ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108731:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108734:	8b 00                	mov    (%eax),%eax
80108736:	83 e0 01             	and    $0x1,%eax
80108739:	85 c0                	test   %eax,%eax
8010873b:	75 0c                	jne    80108749 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010873d:	c7 04 24 a8 96 10 80 	movl   $0x801096a8,(%esp)
80108744:	e8 0b 7e ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108749:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874c:	8b 00                	mov    (%eax),%eax
8010874e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108753:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108756:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108759:	8b 00                	mov    (%eax),%eax
8010875b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108763:	e8 c7 a5 ff ff       	call   80102d2f <kalloc>
80108768:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010876b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010876f:	75 02                	jne    80108773 <copyuvm+0x9b>
      goto bad;
80108771:	eb 6b                	jmp    801087de <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108773:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108776:	05 00 00 00 80       	add    $0x80000000,%eax
8010877b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108782:	00 
80108783:	89 44 24 04          	mov    %eax,0x4(%esp)
80108787:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010878a:	89 04 24             	mov    %eax,(%esp)
8010878d:	e8 d5 cc ff ff       	call   80105467 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108792:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108795:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108798:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010879e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a1:	89 54 24 10          	mov    %edx,0x10(%esp)
801087a5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801087a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087b0:	00 
801087b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801087b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b8:	89 04 24             	mov    %eax,(%esp)
801087bb:	e8 00 f8 ff ff       	call   80107fc0 <mappages>
801087c0:	85 c0                	test   %eax,%eax
801087c2:	79 02                	jns    801087c6 <copyuvm+0xee>
      goto bad;
801087c4:	eb 18                	jmp    801087de <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801087c6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087d3:	0f 82 29 ff ff ff    	jb     80108702 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
801087d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087dc:	eb 10                	jmp    801087ee <copyuvm+0x116>

bad:
  freevm(d);
801087de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087e1:	89 04 24             	mov    %eax,(%esp)
801087e4:	e8 13 fe ff ff       	call   801085fc <freevm>
  return 0;
801087e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087ee:	c9                   	leave  
801087ef:	c3                   	ret    

801087f0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801087f0:	55                   	push   %ebp
801087f1:	89 e5                	mov    %esp,%ebp
801087f3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087fd:	00 
801087fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80108801:	89 44 24 04          	mov    %eax,0x4(%esp)
80108805:	8b 45 08             	mov    0x8(%ebp),%eax
80108808:	89 04 24             	mov    %eax,(%esp)
8010880b:	e8 14 f7 ff ff       	call   80107f24 <walkpgdir>
80108810:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108816:	8b 00                	mov    (%eax),%eax
80108818:	83 e0 01             	and    $0x1,%eax
8010881b:	85 c0                	test   %eax,%eax
8010881d:	75 07                	jne    80108826 <uva2ka+0x36>
    return 0;
8010881f:	b8 00 00 00 00       	mov    $0x0,%eax
80108824:	eb 22                	jmp    80108848 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108829:	8b 00                	mov    (%eax),%eax
8010882b:	83 e0 04             	and    $0x4,%eax
8010882e:	85 c0                	test   %eax,%eax
80108830:	75 07                	jne    80108839 <uva2ka+0x49>
    return 0;
80108832:	b8 00 00 00 00       	mov    $0x0,%eax
80108837:	eb 0f                	jmp    80108848 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883c:	8b 00                	mov    (%eax),%eax
8010883e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108843:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108848:	c9                   	leave  
80108849:	c3                   	ret    

8010884a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010884a:	55                   	push   %ebp
8010884b:	89 e5                	mov    %esp,%ebp
8010884d:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108850:	8b 45 10             	mov    0x10(%ebp),%eax
80108853:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108856:	e9 87 00 00 00       	jmp    801088e2 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010885b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010885e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108863:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108866:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108869:	89 44 24 04          	mov    %eax,0x4(%esp)
8010886d:	8b 45 08             	mov    0x8(%ebp),%eax
80108870:	89 04 24             	mov    %eax,(%esp)
80108873:	e8 78 ff ff ff       	call   801087f0 <uva2ka>
80108878:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010887b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010887f:	75 07                	jne    80108888 <copyout+0x3e>
      return -1;
80108881:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108886:	eb 69                	jmp    801088f1 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010888b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010888e:	29 c2                	sub    %eax,%edx
80108890:	89 d0                	mov    %edx,%eax
80108892:	05 00 10 00 00       	add    $0x1000,%eax
80108897:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010889a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010889d:	3b 45 14             	cmp    0x14(%ebp),%eax
801088a0:	76 06                	jbe    801088a8 <copyout+0x5e>
      n = len;
801088a2:	8b 45 14             	mov    0x14(%ebp),%eax
801088a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801088ae:	29 c2                	sub    %eax,%edx
801088b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088b3:	01 c2                	add    %eax,%edx
801088b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801088bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801088c3:	89 14 24             	mov    %edx,(%esp)
801088c6:	e8 9c cb ff ff       	call   80105467 <memmove>
    len -= n;
801088cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ce:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801088d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801088d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088da:	05 00 10 00 00       	add    $0x1000,%eax
801088df:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801088e2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801088e6:	0f 85 6f ff ff ff    	jne    8010885b <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801088ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088f1:	c9                   	leave  
801088f2:	c3                   	ret    
	...

801088f4 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
801088f4:	55                   	push   %ebp
801088f5:	89 e5                	mov    %esp,%ebp
801088f7:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
801088fa:	8b 45 10             	mov    0x10(%ebp),%eax
801088fd:	89 44 24 08          	mov    %eax,0x8(%esp)
80108901:	8b 45 0c             	mov    0xc(%ebp),%eax
80108904:	89 44 24 04          	mov    %eax,0x4(%esp)
80108908:	8b 45 08             	mov    0x8(%ebp),%eax
8010890b:	89 04 24             	mov    %eax,(%esp)
8010890e:	e8 54 cb ff ff       	call   80105467 <memmove>
}
80108913:	c9                   	leave  
80108914:	c3                   	ret    

80108915 <strcpy>:

char* strcpy(char *s, char *t){
80108915:	55                   	push   %ebp
80108916:	89 e5                	mov    %esp,%ebp
80108918:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010891b:	8b 45 08             	mov    0x8(%ebp),%eax
8010891e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108921:	90                   	nop
80108922:	8b 45 08             	mov    0x8(%ebp),%eax
80108925:	8d 50 01             	lea    0x1(%eax),%edx
80108928:	89 55 08             	mov    %edx,0x8(%ebp)
8010892b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010892e:	8d 4a 01             	lea    0x1(%edx),%ecx
80108931:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108934:	8a 12                	mov    (%edx),%dl
80108936:	88 10                	mov    %dl,(%eax)
80108938:	8a 00                	mov    (%eax),%al
8010893a:	84 c0                	test   %al,%al
8010893c:	75 e4                	jne    80108922 <strcpy+0xd>
    ;
  return os;
8010893e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108941:	c9                   	leave  
80108942:	c3                   	ret    

80108943 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80108943:	55                   	push   %ebp
80108944:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108946:	eb 06                	jmp    8010894e <strcmp+0xb>
    p++, q++;
80108948:	ff 45 08             	incl   0x8(%ebp)
8010894b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
8010894e:	8b 45 08             	mov    0x8(%ebp),%eax
80108951:	8a 00                	mov    (%eax),%al
80108953:	84 c0                	test   %al,%al
80108955:	74 0e                	je     80108965 <strcmp+0x22>
80108957:	8b 45 08             	mov    0x8(%ebp),%eax
8010895a:	8a 10                	mov    (%eax),%dl
8010895c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895f:	8a 00                	mov    (%eax),%al
80108961:	38 c2                	cmp    %al,%dl
80108963:	74 e3                	je     80108948 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80108965:	8b 45 08             	mov    0x8(%ebp),%eax
80108968:	8a 00                	mov    (%eax),%al
8010896a:	0f b6 d0             	movzbl %al,%edx
8010896d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108970:	8a 00                	mov    (%eax),%al
80108972:	0f b6 c0             	movzbl %al,%eax
80108975:	29 c2                	sub    %eax,%edx
80108977:	89 d0                	mov    %edx,%eax
}
80108979:	5d                   	pop    %ebp
8010897a:	c3                   	ret    

8010897b <get_name>:

// struct con

void get_name(int vc_num, char* name){
8010897b:	55                   	push   %ebp
8010897c:	89 e5                	mov    %esp,%ebp
8010897e:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80108981:	8b 55 08             	mov    0x8(%ebp),%edx
80108984:	89 d0                	mov    %edx,%eax
80108986:	01 c0                	add    %eax,%eax
80108988:	01 d0                	add    %edx,%eax
8010898a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108991:	01 d0                	add    %edx,%eax
80108993:	c1 e0 02             	shl    $0x2,%eax
80108996:	83 c0 10             	add    $0x10,%eax
80108999:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010899e:	83 c0 08             	add    $0x8,%eax
801089a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
801089a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
801089ab:	eb 03                	jmp    801089b0 <get_name+0x35>
	{
		i++;
801089ad:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
801089b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b6:	01 d0                	add    %edx,%eax
801089b8:	8a 00                	mov    (%eax),%al
801089ba:	84 c0                	test   %al,%al
801089bc:	75 ef                	jne    801089ad <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
801089be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801089c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801089cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801089cf:	89 04 24             	mov    %eax,(%esp)
801089d2:	e8 1d ff ff ff       	call   801088f4 <memcpy2>
}
801089d7:	c9                   	leave  
801089d8:	c3                   	ret    

801089d9 <g_name>:

char* g_name(int vc_bun){
801089d9:	55                   	push   %ebp
801089da:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
801089dc:	8b 55 08             	mov    0x8(%ebp),%edx
801089df:	89 d0                	mov    %edx,%eax
801089e1:	01 c0                	add    %eax,%eax
801089e3:	01 d0                	add    %edx,%eax
801089e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089ec:	01 d0                	add    %edx,%eax
801089ee:	c1 e0 02             	shl    $0x2,%eax
801089f1:	83 c0 10             	add    $0x10,%eax
801089f4:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801089f9:	83 c0 08             	add    $0x8,%eax
}
801089fc:	5d                   	pop    %ebp
801089fd:	c3                   	ret    

801089fe <is_full>:

int is_full(){
801089fe:	55                   	push   %ebp
801089ff:	89 e5                	mov    %esp,%ebp
80108a01:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108a04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a0b:	eb 34                	jmp    80108a41 <is_full+0x43>
		if(strlen(containers[i].name) == 0){
80108a0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a10:	89 d0                	mov    %edx,%eax
80108a12:	01 c0                	add    %eax,%eax
80108a14:	01 d0                	add    %edx,%eax
80108a16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a1d:	01 d0                	add    %edx,%eax
80108a1f:	c1 e0 02             	shl    $0x2,%eax
80108a22:	83 c0 10             	add    $0x10,%eax
80108a25:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108a2a:	83 c0 08             	add    $0x8,%eax
80108a2d:	89 04 24             	mov    %eax,(%esp)
80108a30:	e8 bc cb ff ff       	call   801055f1 <strlen>
80108a35:	85 c0                	test   %eax,%eax
80108a37:	75 05                	jne    80108a3e <is_full+0x40>
			return i;
80108a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3c:	eb 0e                	jmp    80108a4c <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108a3e:	ff 45 f4             	incl   -0xc(%ebp)
80108a41:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80108a45:	7e c6                	jle    80108a0d <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108a47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108a4c:	c9                   	leave  
80108a4d:	c3                   	ret    

80108a4e <find>:

int find(char* name){
80108a4e:	55                   	push   %ebp
80108a4f:	89 e5                	mov    %esp,%ebp
80108a51:	83 ec 18             	sub    $0x18,%esp
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108a54:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108a5b:	eb 54                	jmp    80108ab1 <find+0x63>
		if(strcmp(name, "") == 0){
80108a5d:	c7 44 24 04 c2 96 10 	movl   $0x801096c2,0x4(%esp)
80108a64:	80 
80108a65:	8b 45 08             	mov    0x8(%ebp),%eax
80108a68:	89 04 24             	mov    %eax,(%esp)
80108a6b:	e8 d3 fe ff ff       	call   80108943 <strcmp>
80108a70:	85 c0                	test   %eax,%eax
80108a72:	75 02                	jne    80108a76 <find+0x28>
			continue;
80108a74:	eb 38                	jmp    80108aae <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80108a76:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108a79:	89 d0                	mov    %edx,%eax
80108a7b:	01 c0                	add    %eax,%eax
80108a7d:	01 d0                	add    %edx,%eax
80108a7f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a86:	01 d0                	add    %edx,%eax
80108a88:	c1 e0 02             	shl    $0x2,%eax
80108a8b:	83 c0 10             	add    $0x10,%eax
80108a8e:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108a93:	83 c0 08             	add    $0x8,%eax
80108a96:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a9d:	89 04 24             	mov    %eax,(%esp)
80108aa0:	e8 9e fe ff ff       	call   80108943 <strcmp>
80108aa5:	85 c0                	test   %eax,%eax
80108aa7:	75 05                	jne    80108aae <find+0x60>
			//cprintf("in hereI");
			return i;
80108aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108aac:	eb 0e                	jmp    80108abc <find+0x6e>
}

int find(char* name){
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108aae:	ff 45 fc             	incl   -0x4(%ebp)
80108ab1:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108ab5:	7e a6                	jle    80108a5d <find+0xf>
		if(strcmp(name, containers[i].name) == 0){
			//cprintf("in hereI");
			return i;
		}
	}
	return -1;
80108ab7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108abc:	c9                   	leave  
80108abd:	c3                   	ret    

80108abe <get_max_proc>:

int get_max_proc(int vc_num){
80108abe:	55                   	push   %ebp
80108abf:	89 e5                	mov    %esp,%ebp
80108ac1:	57                   	push   %edi
80108ac2:	56                   	push   %esi
80108ac3:	53                   	push   %ebx
80108ac4:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108ac7:	8b 55 08             	mov    0x8(%ebp),%edx
80108aca:	89 d0                	mov    %edx,%eax
80108acc:	01 c0                	add    %eax,%eax
80108ace:	01 d0                	add    %edx,%eax
80108ad0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ad7:	01 d0                	add    %edx,%eax
80108ad9:	c1 e0 02             	shl    $0x2,%eax
80108adc:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ae1:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108ae4:	89 c3                	mov    %eax,%ebx
80108ae6:	b8 0f 00 00 00       	mov    $0xf,%eax
80108aeb:	89 d7                	mov    %edx,%edi
80108aed:	89 de                	mov    %ebx,%esi
80108aef:	89 c1                	mov    %eax,%ecx
80108af1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108af3:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80108af6:	83 c4 40             	add    $0x40,%esp
80108af9:	5b                   	pop    %ebx
80108afa:	5e                   	pop    %esi
80108afb:	5f                   	pop    %edi
80108afc:	5d                   	pop    %ebp
80108afd:	c3                   	ret    

80108afe <get_container>:

struct container* get_container(int vc_num){
80108afe:	55                   	push   %ebp
80108aff:	89 e5                	mov    %esp,%ebp
80108b01:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80108b04:	8b 55 08             	mov    0x8(%ebp),%edx
80108b07:	89 d0                	mov    %edx,%eax
80108b09:	01 c0                	add    %eax,%eax
80108b0b:	01 d0                	add    %edx,%eax
80108b0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b14:	01 d0                	add    %edx,%eax
80108b16:	c1 e0 02             	shl    $0x2,%eax
80108b19:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	// cprintf("vc num given is %d\n.", vc_num);
	// cprintf("The name for this container is %s.\n", cont->name);
	return cont;
80108b21:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108b24:	c9                   	leave  
80108b25:	c3                   	ret    

80108b26 <get_max_mem>:

int get_max_mem(int vc_num){
80108b26:	55                   	push   %ebp
80108b27:	89 e5                	mov    %esp,%ebp
80108b29:	57                   	push   %edi
80108b2a:	56                   	push   %esi
80108b2b:	53                   	push   %ebx
80108b2c:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108b2f:	8b 55 08             	mov    0x8(%ebp),%edx
80108b32:	89 d0                	mov    %edx,%eax
80108b34:	01 c0                	add    %eax,%eax
80108b36:	01 d0                	add    %edx,%eax
80108b38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b3f:	01 d0                	add    %edx,%eax
80108b41:	c1 e0 02             	shl    $0x2,%eax
80108b44:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b49:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108b4c:	89 c3                	mov    %eax,%ebx
80108b4e:	b8 0f 00 00 00       	mov    $0xf,%eax
80108b53:	89 d7                	mov    %edx,%edi
80108b55:	89 de                	mov    %ebx,%esi
80108b57:	89 c1                	mov    %eax,%ecx
80108b59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108b5b:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108b5e:	83 c4 40             	add    $0x40,%esp
80108b61:	5b                   	pop    %ebx
80108b62:	5e                   	pop    %esi
80108b63:	5f                   	pop    %edi
80108b64:	5d                   	pop    %ebp
80108b65:	c3                   	ret    

80108b66 <get_max_disk>:

int get_max_disk(int vc_num){
80108b66:	55                   	push   %ebp
80108b67:	89 e5                	mov    %esp,%ebp
80108b69:	57                   	push   %edi
80108b6a:	56                   	push   %esi
80108b6b:	53                   	push   %ebx
80108b6c:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108b6f:	8b 55 08             	mov    0x8(%ebp),%edx
80108b72:	89 d0                	mov    %edx,%eax
80108b74:	01 c0                	add    %eax,%eax
80108b76:	01 d0                	add    %edx,%eax
80108b78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b7f:	01 d0                	add    %edx,%eax
80108b81:	c1 e0 02             	shl    $0x2,%eax
80108b84:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b89:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108b8c:	89 c3                	mov    %eax,%ebx
80108b8e:	b8 0f 00 00 00       	mov    $0xf,%eax
80108b93:	89 d7                	mov    %edx,%edi
80108b95:	89 de                	mov    %ebx,%esi
80108b97:	89 c1                	mov    %eax,%ecx
80108b99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80108b9b:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80108b9e:	83 c4 40             	add    $0x40,%esp
80108ba1:	5b                   	pop    %ebx
80108ba2:	5e                   	pop    %esi
80108ba3:	5f                   	pop    %edi
80108ba4:	5d                   	pop    %ebp
80108ba5:	c3                   	ret    

80108ba6 <get_curr_proc>:

int get_curr_proc(int vc_num){
80108ba6:	55                   	push   %ebp
80108ba7:	89 e5                	mov    %esp,%ebp
80108ba9:	57                   	push   %edi
80108baa:	56                   	push   %esi
80108bab:	53                   	push   %ebx
80108bac:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108baf:	8b 55 08             	mov    0x8(%ebp),%edx
80108bb2:	89 d0                	mov    %edx,%eax
80108bb4:	01 c0                	add    %eax,%eax
80108bb6:	01 d0                	add    %edx,%eax
80108bb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bbf:	01 d0                	add    %edx,%eax
80108bc1:	c1 e0 02             	shl    $0x2,%eax
80108bc4:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108bc9:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108bcc:	89 c3                	mov    %eax,%ebx
80108bce:	b8 0f 00 00 00       	mov    $0xf,%eax
80108bd3:	89 d7                	mov    %edx,%edi
80108bd5:	89 de                	mov    %ebx,%esi
80108bd7:	89 c1                	mov    %eax,%ecx
80108bd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108bdb:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80108bde:	83 c4 40             	add    $0x40,%esp
80108be1:	5b                   	pop    %ebx
80108be2:	5e                   	pop    %esi
80108be3:	5f                   	pop    %edi
80108be4:	5d                   	pop    %ebp
80108be5:	c3                   	ret    

80108be6 <get_curr_mem>:

int get_curr_mem(int vc_num){
80108be6:	55                   	push   %ebp
80108be7:	89 e5                	mov    %esp,%ebp
80108be9:	57                   	push   %edi
80108bea:	56                   	push   %esi
80108beb:	53                   	push   %ebx
80108bec:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108bef:	8b 55 08             	mov    0x8(%ebp),%edx
80108bf2:	89 d0                	mov    %edx,%eax
80108bf4:	01 c0                	add    %eax,%eax
80108bf6:	01 d0                	add    %edx,%eax
80108bf8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bff:	01 d0                	add    %edx,%eax
80108c01:	c1 e0 02             	shl    $0x2,%eax
80108c04:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c09:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108c0c:	89 c3                	mov    %eax,%ebx
80108c0e:	b8 0f 00 00 00       	mov    $0xf,%eax
80108c13:	89 d7                	mov    %edx,%edi
80108c15:	89 de                	mov    %ebx,%esi
80108c17:	89 c1                	mov    %eax,%ecx
80108c19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_mem; 
80108c1b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
80108c1e:	83 c4 40             	add    $0x40,%esp
80108c21:	5b                   	pop    %ebx
80108c22:	5e                   	pop    %esi
80108c23:	5f                   	pop    %edi
80108c24:	5d                   	pop    %ebp
80108c25:	c3                   	ret    

80108c26 <get_curr_disk>:

int get_curr_disk(int vc_num){
80108c26:	55                   	push   %ebp
80108c27:	89 e5                	mov    %esp,%ebp
80108c29:	57                   	push   %edi
80108c2a:	56                   	push   %esi
80108c2b:	53                   	push   %ebx
80108c2c:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108c2f:	8b 55 08             	mov    0x8(%ebp),%edx
80108c32:	89 d0                	mov    %edx,%eax
80108c34:	01 c0                	add    %eax,%eax
80108c36:	01 d0                	add    %edx,%eax
80108c38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c3f:	01 d0                	add    %edx,%eax
80108c41:	c1 e0 02             	shl    $0x2,%eax
80108c44:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c49:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108c4c:	89 c3                	mov    %eax,%ebx
80108c4e:	b8 0f 00 00 00       	mov    $0xf,%eax
80108c53:	89 d7                	mov    %edx,%edi
80108c55:	89 de                	mov    %ebx,%esi
80108c57:	89 c1                	mov    %eax,%ecx
80108c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80108c5b:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
80108c5e:	83 c4 40             	add    $0x40,%esp
80108c61:	5b                   	pop    %ebx
80108c62:	5e                   	pop    %esi
80108c63:	5f                   	pop    %edi
80108c64:	5d                   	pop    %ebp
80108c65:	c3                   	ret    

80108c66 <set_name>:

void set_name(char* name, int vc_num){
80108c66:	55                   	push   %ebp
80108c67:	89 e5                	mov    %esp,%ebp
80108c69:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80108c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c6f:	89 d0                	mov    %edx,%eax
80108c71:	01 c0                	add    %eax,%eax
80108c73:	01 d0                	add    %edx,%eax
80108c75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c7c:	01 d0                	add    %edx,%eax
80108c7e:	c1 e0 02             	shl    $0x2,%eax
80108c81:	83 c0 10             	add    $0x10,%eax
80108c84:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c89:	8d 50 08             	lea    0x8(%eax),%edx
80108c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c93:	89 14 24             	mov    %edx,(%esp)
80108c96:	e8 7a fc ff ff       	call   80108915 <strcpy>
}
80108c9b:	c9                   	leave  
80108c9c:	c3                   	ret    

80108c9d <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80108c9d:	55                   	push   %ebp
80108c9e:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80108ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ca3:	89 d0                	mov    %edx,%eax
80108ca5:	01 c0                	add    %eax,%eax
80108ca7:	01 d0                	add    %edx,%eax
80108ca9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cb0:	01 d0                	add    %edx,%eax
80108cb2:	c1 e0 02             	shl    $0x2,%eax
80108cb5:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80108cbe:	89 02                	mov    %eax,(%edx)
}
80108cc0:	5d                   	pop    %ebp
80108cc1:	c3                   	ret    

80108cc2 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
80108cc2:	55                   	push   %ebp
80108cc3:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
80108cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cc8:	89 d0                	mov    %edx,%eax
80108cca:	01 c0                	add    %eax,%eax
80108ccc:	01 d0                	add    %edx,%eax
80108cce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cd5:	01 d0                	add    %edx,%eax
80108cd7:	c1 e0 02             	shl    $0x2,%eax
80108cda:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce3:	89 42 08             	mov    %eax,0x8(%edx)
}
80108ce6:	5d                   	pop    %ebp
80108ce7:	c3                   	ret    

80108ce8 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80108ce8:	55                   	push   %ebp
80108ce9:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80108ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cee:	89 d0                	mov    %edx,%eax
80108cf0:	01 c0                	add    %eax,%eax
80108cf2:	01 d0                	add    %edx,%eax
80108cf4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cfb:	01 d0                	add    %edx,%eax
80108cfd:	c1 e0 02             	shl    $0x2,%eax
80108d00:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108d06:	8b 45 08             	mov    0x8(%ebp),%eax
80108d09:	89 42 04             	mov    %eax,0x4(%edx)
}
80108d0c:	5d                   	pop    %ebp
80108d0d:	c3                   	ret    

80108d0e <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
80108d0e:	55                   	push   %ebp
80108d0f:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;	
80108d11:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d14:	89 d0                	mov    %edx,%eax
80108d16:	01 c0                	add    %eax,%eax
80108d18:	01 d0                	add    %edx,%eax
80108d1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d21:	01 d0                	add    %edx,%eax
80108d23:	c1 e0 02             	shl    $0x2,%eax
80108d26:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d2b:	8b 40 0c             	mov    0xc(%eax),%eax
80108d2e:	8d 48 01             	lea    0x1(%eax),%ecx
80108d31:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d34:	89 d0                	mov    %edx,%eax
80108d36:	01 c0                	add    %eax,%eax
80108d38:	01 d0                	add    %edx,%eax
80108d3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d41:	01 d0                	add    %edx,%eax
80108d43:	c1 e0 02             	shl    $0x2,%eax
80108d46:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d4b:	89 48 0c             	mov    %ecx,0xc(%eax)
}
80108d4e:	5d                   	pop    %ebp
80108d4f:	c3                   	ret    

80108d50 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
80108d50:	55                   	push   %ebp
80108d51:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
80108d53:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d56:	89 d0                	mov    %edx,%eax
80108d58:	01 c0                	add    %eax,%eax
80108d5a:	01 d0                	add    %edx,%eax
80108d5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d63:	01 d0                	add    %edx,%eax
80108d65:	c1 e0 02             	shl    $0x2,%eax
80108d68:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d6d:	8b 40 0c             	mov    0xc(%eax),%eax
80108d70:	8d 48 ff             	lea    -0x1(%eax),%ecx
80108d73:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d76:	89 d0                	mov    %edx,%eax
80108d78:	01 c0                	add    %eax,%eax
80108d7a:	01 d0                	add    %edx,%eax
80108d7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d83:	01 d0                	add    %edx,%eax
80108d85:	c1 e0 02             	shl    $0x2,%eax
80108d88:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d8d:	89 48 0c             	mov    %ecx,0xc(%eax)
}
80108d90:	5d                   	pop    %ebp
80108d91:	c3                   	ret    

80108d92 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80108d92:	55                   	push   %ebp
80108d93:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
80108d95:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d98:	89 d0                	mov    %edx,%eax
80108d9a:	01 c0                	add    %eax,%eax
80108d9c:	01 d0                	add    %edx,%eax
80108d9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108da5:	01 d0                	add    %edx,%eax
80108da7:	c1 e0 02             	shl    $0x2,%eax
80108daa:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108daf:	8b 50 04             	mov    0x4(%eax),%edx
80108db2:	8b 45 08             	mov    0x8(%ebp),%eax
80108db5:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108db8:	8b 55 0c             	mov    0xc(%ebp),%edx
80108dbb:	89 d0                	mov    %edx,%eax
80108dbd:	01 c0                	add    %eax,%eax
80108dbf:	01 d0                	add    %edx,%eax
80108dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108dc8:	01 d0                	add    %edx,%eax
80108dca:	c1 e0 02             	shl    $0x2,%eax
80108dcd:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108dd2:	89 48 04             	mov    %ecx,0x4(%eax)
}
80108dd5:	5d                   	pop    %ebp
80108dd6:	c3                   	ret    

80108dd7 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80108dd7:	55                   	push   %ebp
80108dd8:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80108dda:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ddd:	89 d0                	mov    %edx,%eax
80108ddf:	01 c0                	add    %eax,%eax
80108de1:	01 d0                	add    %edx,%eax
80108de3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108dea:	01 d0                	add    %edx,%eax
80108dec:	c1 e0 02             	shl    $0x2,%eax
80108def:	8d 90 d0 7b 11 80    	lea    -0x7fee8430(%eax),%edx
80108df5:	8b 45 08             	mov    0x8(%ebp),%eax
80108df8:	89 02                	mov    %eax,(%edx)
}
80108dfa:	5d                   	pop    %ebp
80108dfb:	c3                   	ret    

80108dfc <container_init>:

void container_init(){
80108dfc:	55                   	push   %ebp
80108dfd:	89 e5                	mov    %esp,%ebp
80108dff:	83 ec 18             	sub    $0x18,%esp

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108e02:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108e09:	e9 f7 00 00 00       	jmp    80108f05 <container_init+0x109>
		strcpy(containers[i].name, "");
80108e0e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e11:	89 d0                	mov    %edx,%eax
80108e13:	01 c0                	add    %eax,%eax
80108e15:	01 d0                	add    %edx,%eax
80108e17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e1e:	01 d0                	add    %edx,%eax
80108e20:	c1 e0 02             	shl    $0x2,%eax
80108e23:	83 c0 10             	add    $0x10,%eax
80108e26:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e2b:	83 c0 08             	add    $0x8,%eax
80108e2e:	c7 44 24 04 c2 96 10 	movl   $0x801096c2,0x4(%esp)
80108e35:	80 
80108e36:	89 04 24             	mov    %eax,(%esp)
80108e39:	e8 d7 fa ff ff       	call   80108915 <strcpy>
		containers[i].max_proc = 4;
80108e3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e41:	89 d0                	mov    %edx,%eax
80108e43:	01 c0                	add    %eax,%eax
80108e45:	01 d0                	add    %edx,%eax
80108e47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e4e:	01 d0                	add    %edx,%eax
80108e50:	c1 e0 02             	shl    $0x2,%eax
80108e53:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e58:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80108e5f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e62:	89 d0                	mov    %edx,%eax
80108e64:	01 c0                	add    %eax,%eax
80108e66:	01 d0                	add    %edx,%eax
80108e68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e6f:	01 d0                	add    %edx,%eax
80108e71:	c1 e0 02             	shl    $0x2,%eax
80108e74:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e79:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
80108e80:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e83:	89 d0                	mov    %edx,%eax
80108e85:	01 c0                	add    %eax,%eax
80108e87:	01 d0                	add    %edx,%eax
80108e89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e90:	01 d0                	add    %edx,%eax
80108e92:	c1 e0 02             	shl    $0x2,%eax
80108e95:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e9a:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 1;
80108ea0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ea3:	89 d0                	mov    %edx,%eax
80108ea5:	01 c0                	add    %eax,%eax
80108ea7:	01 d0                	add    %edx,%eax
80108ea9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108eb0:	01 d0                	add    %edx,%eax
80108eb2:	c1 e0 02             	shl    $0x2,%eax
80108eb5:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108eba:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
80108ec0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ec3:	89 d0                	mov    %edx,%eax
80108ec5:	01 c0                	add    %eax,%eax
80108ec7:	01 d0                	add    %edx,%eax
80108ec9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ed0:	01 d0                	add    %edx,%eax
80108ed2:	c1 e0 02             	shl    $0x2,%eax
80108ed5:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108eda:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
80108ee1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ee4:	89 d0                	mov    %edx,%eax
80108ee6:	01 c0                	add    %eax,%eax
80108ee8:	01 d0                	add    %edx,%eax
80108eea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ef1:	01 d0                	add    %edx,%eax
80108ef3:	c1 e0 02             	shl    $0x2,%eax
80108ef6:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108efb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

void container_init(){

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108f02:	ff 45 fc             	incl   -0x4(%ebp)
80108f05:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108f09:	0f 8e ff fe ff ff    	jle    80108e0e <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
80108f0f:	c9                   	leave  
80108f10:	c3                   	ret    
