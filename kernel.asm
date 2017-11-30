
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
8010002d:	b8 62 39 10 80       	mov    $0x80103962,%eax
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
8010003a:	c7 44 24 04 60 8f 10 	movl   $0x80108f60,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100049:	e8 18 51 00 00       	call   80105166 <initlock>

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
80100087:	c7 44 24 04 67 8f 10 	movl   $0x80108f67,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 91 4f 00 00       	call   80105028 <initsleeplock>
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
801000c9:	e8 b9 50 00 00       	call   80105187 <acquire>

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
80100104:	e8 e8 50 00 00       	call   801051f1 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 4b 4f 00 00       	call   80105062 <acquiresleep>
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
8010017d:	e8 6f 50 00 00       	call   801051f1 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 d2 4e 00 00       	call   80105062 <acquiresleep>
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
801001a7:	c7 04 24 6e 8f 10 80 	movl   $0x80108f6e,(%esp)
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
801001fb:	e8 ff 4e 00 00       	call   801050ff <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 7f 8f 10 80 	movl   $0x80108f7f,(%esp)
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
8010023b:	e8 bf 4e 00 00       	call   801050ff <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 86 8f 10 80 	movl   $0x80108f86,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 5f 4e 00 00       	call   801050bd <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100265:	e8 1d 4f 00 00       	call   80105187 <acquire>
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
801002d1:	e8 1b 4f 00 00       	call   801051f1 <release>
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
801003dc:	e8 a6 4d 00 00       	call   80105187 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 8d 8f 10 80 	movl   $0x80108f8d,(%esp)
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
801004cf:	c7 45 ec 96 8f 10 80 	movl   $0x80108f96,-0x14(%ebp)
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
8010054d:	e8 9f 4c 00 00       	call   801051f1 <release>
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
80100569:	e8 c7 2b 00 00       	call   80103135 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 9d 8f 10 80 	movl   $0x80108f9d,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 b1 8f 10 80 	movl   $0x80108fb1,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 97 4c 00 00       	call   8010523e <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 b3 8f 10 80 	movl   $0x80108fb3,(%esp)
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
80100695:	c7 04 24 b7 8f 10 80 	movl   $0x80108fb7,(%esp)
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
801006c9:	e8 e5 4d 00 00       	call   801054b3 <memmove>
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
801006f8:	e8 ed 4c 00 00       	call   801053ea <memset>
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
8010078e:	e8 2d 69 00 00       	call   801070c0 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 21 69 00 00       	call   801070c0 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 15 69 00 00       	call   801070c0 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 08 69 00 00       	call   801070c0 <uartputc>
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
80100813:	e8 6f 49 00 00       	call   80105187 <acquire>
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
80100a00:	e8 ca 42 00 00       	call   80104ccf <wakeup>
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
80100a21:	e8 cb 47 00 00       	call   801051f1 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 ca 8f 10 80 	movl   $0x80108fca,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 38 43 00 00       	call   80104d75 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 e2 8f 10 80 	movl   $0x80108fe2,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 fc 8f 10 80 	movl   $0x80108ffc,(%esp)
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
80100a8a:	e8 f8 46 00 00       	call   80105187 <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 e4 38 00 00       	call   8010437f <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100aa9:	e8 43 47 00 00       	call   801051f1 <release>
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
80100ad2:	e8 21 41 00 00       	call   80104bf8 <sleep>

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
80100b5c:	e8 90 46 00 00       	call   801051f1 <release>
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
80100ba2:	e8 e0 45 00 00       	call   80105187 <acquire>
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
80100bda:	e8 12 46 00 00       	call   801051f1 <release>
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
80100bf5:	c7 44 24 04 15 90 10 	movl   $0x80109015,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100c04:	e8 5d 45 00 00       	call   80105166 <initlock>

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
80100c49:	e8 31 37 00 00       	call   8010437f <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 29 2a 00 00       	call   8010367f <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 86 19 00 00       	call   801025e7 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 92 2a 00 00       	call   80103701 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 1d 90 10 80 	movl   $0x8010901d,(%esp)
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
80100cd8:	e8 c5 73 00 00       	call   801080a2 <setupkvm>
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
80100d96:	e8 d3 76 00 00       	call   8010846e <allocuvm>
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
80100de8:	e8 9e 75 00 00       	call   8010838b <loaduvm>
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
80100e1f:	e8 dd 28 00 00       	call   80103701 <end_op>
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
80100e54:	e8 15 76 00 00       	call   8010846e <allocuvm>
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
80100e79:	e8 60 78 00 00       	call   801086de <clearpteu>
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
80100eaf:	e8 89 47 00 00       	call   8010563d <strlen>
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
80100ed6:	e8 62 47 00 00       	call   8010563d <strlen>
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
80100f04:	e8 8d 79 00 00       	call   80108896 <copyout>
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
80100fa8:	e8 e9 78 00 00       	call   80108896 <copyout>
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
80100ff8:	e8 f9 45 00 00       	call   801055f6 <safestrcpy>

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
80101038:	e8 3f 71 00 00       	call   8010817c <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 00 76 00 00       	call   80108648 <freevm>
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
8010105b:	e8 e8 75 00 00       	call   80108648 <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 8b 26 00 00       	call   80103701 <end_op>
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
801010ec:	c7 44 24 04 29 90 10 	movl   $0x80109029,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801010fb:	e8 66 40 00 00       	call   80105166 <initlock>
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
8010110f:	e8 73 40 00 00       	call   80105187 <acquire>
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
80101138:	e8 b4 40 00 00       	call   801051f1 <release>
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
80101156:	e8 96 40 00 00       	call   801051f1 <release>
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
8010116f:	e8 13 40 00 00       	call   80105187 <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 30 90 10 80 	movl   $0x80109030,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011a0:	e8 4c 40 00 00       	call   801051f1 <release>
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
801011ba:	e8 c8 3f 00 00       	call   80105187 <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 38 90 10 80 	movl   $0x80109038,(%esp)
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
801011f5:	e8 f7 3f 00 00       	call   801051f1 <release>
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
8010122b:	e8 c1 3f 00 00       	call   801051f1 <release>

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
80101248:	e8 ca 2d 00 00       	call   80104017 <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 23 24 00 00       	call   8010367f <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 95 24 00 00       	call   80103701 <end_op>
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
801012fe:	e8 92 2e 00 00       	call   80104195 <piperead>
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
80101370:	c7 04 24 42 90 10 80 	movl   $0x80109042,(%esp)
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
801013ba:	e8 ea 2c 00 00       	call   801040a9 <pipewrite>
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
80101400:	e8 7a 22 00 00       	call   8010367f <begin_op>
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
80101466:	e8 96 22 00 00       	call   80103701 <end_op>

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
8010147b:	c7 04 24 4b 90 10 80 	movl   $0x8010904b,(%esp)
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
801014ad:	c7 04 24 5b 90 10 80 	movl   $0x8010905b,(%esp)
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
801014f4:	e8 ba 3f 00 00       	call   801054b3 <memmove>
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
8010153a:	e8 ab 3e 00 00       	call   801053ea <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 39 23 00 00       	call   80103883 <log_write>
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
8010160d:	e8 71 22 00 00       	call   80103883 <log_write>
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
80101683:	c7 04 24 68 90 10 80 	movl   $0x80109068,(%esp)
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
80101713:	c7 04 24 7e 90 10 80 	movl   $0x8010907e,(%esp)
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
80101749:	e8 35 21 00 00       	call   80103883 <log_write>
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
8010176b:	c7 44 24 04 91 90 10 	movl   $0x80109091,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
8010177a:	e8 e7 39 00 00       	call   80105166 <initlock>
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
801017a0:	c7 44 24 04 98 90 10 	movl   $0x80109098,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 78 38 00 00       	call   80105028 <initsleeplock>
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
80101819:	c7 04 24 a0 90 10 80 	movl   $0x801090a0,(%esp)
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
8010189b:	e8 4a 3b 00 00       	call   801053ea <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 cf 1f 00 00       	call   80103883 <log_write>
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
801018f1:	c7 04 24 f3 90 10 80 	movl   $0x801090f3,(%esp)
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
8010199e:	e8 10 3b 00 00       	call   801054b3 <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 d5 1e 00 00       	call   80103883 <log_write>
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
801019c8:	e8 ba 37 00 00       	call   80105187 <acquire>

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
80101a12:	e8 da 37 00 00       	call   801051f1 <release>
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
80101a48:	c7 04 24 05 91 10 80 	movl   $0x80109105,(%esp)
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
80101a86:	e8 66 37 00 00       	call   801051f1 <release>

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
80101a9d:	e8 e5 36 00 00       	call   80105187 <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101ab8:	e8 34 37 00 00       	call   801051f1 <release>
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
80101ad8:	c7 04 24 15 91 10 80 	movl   $0x80109115,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 70 35 00 00       	call   80105062 <acquiresleep>

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
80101b99:	e8 15 39 00 00       	call   801054b3 <memmove>
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
80101bbe:	c7 04 24 1b 91 10 80 	movl   $0x8010911b,(%esp)
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
80101be1:	e8 19 35 00 00       	call   801050ff <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 2a 91 10 80 	movl   $0x8010912a,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 af 34 00 00       	call   801050bd <releasesleep>
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
80101c1f:	e8 3e 34 00 00       	call   80105062 <acquiresleep>
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
80101c41:	e8 41 35 00 00       	call   80105187 <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c56:	e8 96 35 00 00       	call   801051f1 <release>
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
80101c93:	e8 25 34 00 00       	call   801050bd <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c9f:	e8 e3 34 00 00       	call   80105187 <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101cba:	e8 32 35 00 00       	call   801051f1 <release>
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
80101dcb:	e8 b3 1a 00 00       	call   80103883 <log_write>
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
80101de0:	c7 04 24 32 91 10 80 	movl   $0x80109132,(%esp)
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
8010208a:	e8 24 34 00 00       	call   801054b3 <memmove>
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
801021e9:	e8 c5 32 00 00       	call   801054b3 <memmove>
    log_write(bp);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 8a 16 00 00       	call   80103883 <log_write>
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
80102267:	e8 e6 32 00 00       	call   80105552 <strncmp>
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
80102280:	c7 04 24 45 91 10 80 	movl   $0x80109145,(%esp)
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
801022be:	c7 04 24 57 91 10 80 	movl   $0x80109157,(%esp)
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
801023a1:	c7 04 24 66 91 10 80 	movl   $0x80109166,(%esp)
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
801023e5:	e8 b6 31 00 00       	call   801055a0 <strncpy>
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
80102417:	c7 04 24 73 91 10 80 	movl   $0x80109173,(%esp)
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
80102496:	e8 18 30 00 00       	call   801054b3 <memmove>
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
801024b1:	e8 fd 2f 00 00       	call   801054b3 <memmove>
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
801024ff:	e8 7b 1e 00 00       	call   8010437f <myproc>
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
801026f7:	c7 44 24 04 7b 91 10 	movl   $0x8010917b,0x4(%esp)
801026fe:	80 
801026ff:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102706:	e8 5b 2a 00 00       	call   80105166 <initlock>
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
80102794:	c7 04 24 7f 91 10 80 	movl   $0x8010917f,(%esp)
8010279b:	e8 b4 dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801027a0:	8b 45 08             	mov    0x8(%ebp),%eax
801027a3:	8b 40 08             	mov    0x8(%eax),%eax
801027a6:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
801027ab:	76 0c                	jbe    801027b9 <idestart+0x31>
    panic("incorrect blockno");
801027ad:	c7 04 24 88 91 10 80 	movl   $0x80109188,(%esp)
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
801027ff:	c7 04 24 7f 91 10 80 	movl   $0x8010917f,(%esp)
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
8010291f:	e8 63 28 00 00       	call   80105187 <acquire>

  if((b = idequeue) == 0){
80102924:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102929:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010292c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102930:	75 11                	jne    80102943 <ideintr+0x31>
    release(&idelock);
80102932:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102939:	e8 b3 28 00 00       	call   801051f1 <release>
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
801029ac:	e8 1e 23 00 00       	call   80104ccf <wakeup>

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
801029ce:	e8 1e 28 00 00       	call   801051f1 <release>
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
801029e4:	e8 16 27 00 00       	call   801050ff <holdingsleep>
801029e9:	85 c0                	test   %eax,%eax
801029eb:	75 0c                	jne    801029f9 <iderw+0x24>
    panic("iderw: buf not locked");
801029ed:	c7 04 24 9a 91 10 80 	movl   $0x8010919a,(%esp)
801029f4:	e8 5b db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	8b 00                	mov    (%eax),%eax
801029fe:	83 e0 06             	and    $0x6,%eax
80102a01:	83 f8 02             	cmp    $0x2,%eax
80102a04:	75 0c                	jne    80102a12 <iderw+0x3d>
    panic("iderw: nothing to do");
80102a06:	c7 04 24 b0 91 10 80 	movl   $0x801091b0,(%esp)
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
80102a25:	c7 04 24 c5 91 10 80 	movl   $0x801091c5,(%esp)
80102a2c:	e8 23 db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a31:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102a38:	e8 4a 27 00 00       	call   80105187 <acquire>

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
80102a93:	e8 60 21 00 00       	call   80104bf8 <sleep>
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
80102aac:	e8 40 27 00 00       	call   801051f1 <release>
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
80102b2b:	c7 04 24 e4 91 10 80 	movl   $0x801091e4,(%esp)
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
80102bce:	c7 44 24 04 16 92 10 	movl   $0x80109216,0x4(%esp)
80102bd5:	80 
80102bd6:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102bdd:	e8 84 25 00 00       	call   80105166 <initlock>
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
80102c87:	c7 04 24 1b 92 10 80 	movl   $0x8010921b,(%esp)
80102c8e:	e8 c1 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c93:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102c9a:	00 
80102c9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ca2:	00 
80102ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca6:	89 04 24             	mov    %eax,(%esp)
80102ca9:	e8 3c 27 00 00       	call   801053ea <memset>

  if(kmem.use_lock){
80102cae:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102cb3:	85 c0                	test   %eax,%eax
80102cb5:	74 6a                	je     80102d21 <kfree+0xc4>
    acquire(&kmem.lock);
80102cb7:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102cbe:	e8 c4 24 00 00       	call   80105187 <acquire>
    if(ticks > 1){
80102cc3:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102cc8:	83 f8 01             	cmp    $0x1,%eax
80102ccb:	76 54                	jbe    80102d21 <kfree+0xc4>
    int x = find(myproc()->cont->name);
80102ccd:	e8 ad 16 00 00       	call   8010437f <myproc>
80102cd2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102cd8:	83 c0 18             	add    $0x18,%eax
80102cdb:	89 04 24             	mov    %eax,(%esp)
80102cde:	e8 b7 5d 00 00       	call   80108a9a <find>
80102ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(x >= 0){
80102ce6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cea:	78 13                	js     80102cff <kfree+0xa2>
      reduce_curr_mem(1, x);
80102cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cef:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cf3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102cfa:	e8 9d 60 00 00       	call   80108d9c <reduce_curr_mem>
    }
    struct proc *p = initp();
80102cff:	e8 18 23 00 00       	call   8010501c <initp>
80102d04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cprintf(p->name);
80102d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d0a:	83 c0 6c             	add    $0x6c,%eax
80102d0d:	89 04 24             	mov    %eax,(%esp)
80102d10:	e8 ac d6 ff ff       	call   801003c1 <cprintf>
    cprintf("goodbye \n");
80102d15:	c7 04 24 21 92 10 80 	movl   $0x80109221,(%esp)
80102d1c:	e8 a0 d6 ff ff       	call   801003c1 <cprintf>
  }
  }
  r = (struct run*)v;
80102d21:	8b 45 08             	mov    0x8(%ebp),%eax
80102d24:	89 45 ec             	mov    %eax,-0x14(%ebp)
  r->next = kmem.freelist;
80102d27:	8b 15 78 4b 11 80    	mov    0x80114b78,%edx
80102d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102d30:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102d35:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102d3a:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d3f:	85 c0                	test   %eax,%eax
80102d41:	74 0c                	je     80102d4f <kfree+0xf2>
    release(&kmem.lock);
80102d43:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d4a:	e8 a2 24 00 00       	call   801051f1 <release>
}
80102d4f:	c9                   	leave  
80102d50:	c3                   	ret    

80102d51 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d51:	55                   	push   %ebp
80102d52:	89 e5                	mov    %esp,%ebp
80102d54:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102d57:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d5c:	85 c0                	test   %eax,%eax
80102d5e:	74 0c                	je     80102d6c <kalloc+0x1b>
    acquire(&kmem.lock);
80102d60:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d67:	e8 1b 24 00 00       	call   80105187 <acquire>
  }
  r = kmem.freelist;
80102d6c:	a1 78 4b 11 80       	mov    0x80114b78,%eax
80102d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d78:	74 0a                	je     80102d84 <kalloc+0x33>
    kmem.freelist = r->next;
80102d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d7d:	8b 00                	mov    (%eax),%eax
80102d7f:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102d84:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d89:	85 c0                	test   %eax,%eax
80102d8b:	74 0c                	je     80102d99 <kalloc+0x48>
    release(&kmem.lock);
80102d8d:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d94:	e8 58 24 00 00       	call   801051f1 <release>
  if((char*)r != 0){
80102d99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d9d:	74 5e                	je     80102dfd <kalloc+0xac>
    if(ticks > 1){
80102d9f:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102da4:	83 f8 01             	cmp    $0x1,%eax
80102da7:	76 54                	jbe    80102dfd <kalloc+0xac>
      int x = find(myproc()->cont->name);
80102da9:	e8 d1 15 00 00       	call   8010437f <myproc>
80102dae:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102db4:	83 c0 18             	add    $0x18,%eax
80102db7:	89 04 24             	mov    %eax,(%esp)
80102dba:	e8 db 5c 00 00       	call   80108a9a <find>
80102dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102dc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102dc6:	78 13                	js     80102ddb <kalloc+0x8a>
        set_curr_mem(1, x);
80102dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102dd6:	e8 7f 5f 00 00       	call   80108d5a <set_curr_mem>
      }
      struct proc *p = initp();
80102ddb:	e8 3c 22 00 00       	call   8010501c <initp>
80102de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      cprintf(p->name);
80102de3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102de6:	83 c0 6c             	add    $0x6c,%eax
80102de9:	89 04 24             	mov    %eax,(%esp)
80102dec:	e8 d0 d5 ff ff       	call   801003c1 <cprintf>
      cprintf("hello \n");
80102df1:	c7 04 24 2b 92 10 80 	movl   $0x8010922b,(%esp)
80102df8:	e8 c4 d5 ff ff       	call   801003c1 <cprintf>

    }
  }
  return (char*)r;
80102dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e00:	c9                   	leave  
80102e01:	c3                   	ret    
	...

80102e04 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e04:	55                   	push   %ebp
80102e05:	89 e5                	mov    %esp,%ebp
80102e07:	83 ec 14             	sub    $0x14,%esp
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e14:	89 c2                	mov    %eax,%edx
80102e16:	ec                   	in     (%dx),%al
80102e17:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e1a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102e1d:	c9                   	leave  
80102e1e:	c3                   	ret    

80102e1f <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e25:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102e2c:	e8 d3 ff ff ff       	call   80102e04 <inb>
80102e31:	0f b6 c0             	movzbl %al,%eax
80102e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3a:	83 e0 01             	and    $0x1,%eax
80102e3d:	85 c0                	test   %eax,%eax
80102e3f:	75 0a                	jne    80102e4b <kbdgetc+0x2c>
    return -1;
80102e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e46:	e9 21 01 00 00       	jmp    80102f6c <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102e4b:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e52:	e8 ad ff ff ff       	call   80102e04 <inb>
80102e57:	0f b6 c0             	movzbl %al,%eax
80102e5a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e5d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e64:	75 17                	jne    80102e7d <kbdgetc+0x5e>
    shift |= E0ESC;
80102e66:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e6b:	83 c8 40             	or     $0x40,%eax
80102e6e:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102e73:	b8 00 00 00 00       	mov    $0x0,%eax
80102e78:	e9 ef 00 00 00       	jmp    80102f6c <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e80:	25 80 00 00 00       	and    $0x80,%eax
80102e85:	85 c0                	test   %eax,%eax
80102e87:	74 44                	je     80102ecd <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e89:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e8e:	83 e0 40             	and    $0x40,%eax
80102e91:	85 c0                	test   %eax,%eax
80102e93:	75 08                	jne    80102e9d <kbdgetc+0x7e>
80102e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e98:	83 e0 7f             	and    $0x7f,%eax
80102e9b:	eb 03                	jmp    80102ea0 <kbdgetc+0x81>
80102e9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ea0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ea6:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102eab:	8a 00                	mov    (%eax),%al
80102ead:	83 c8 40             	or     $0x40,%eax
80102eb0:	0f b6 c0             	movzbl %al,%eax
80102eb3:	f7 d0                	not    %eax
80102eb5:	89 c2                	mov    %eax,%edx
80102eb7:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ebc:	21 d0                	and    %edx,%eax
80102ebe:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102ec3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ec8:	e9 9f 00 00 00       	jmp    80102f6c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102ecd:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ed2:	83 e0 40             	and    $0x40,%eax
80102ed5:	85 c0                	test   %eax,%eax
80102ed7:	74 14                	je     80102eed <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ed9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ee0:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ee5:	83 e0 bf             	and    $0xffffffbf,%eax
80102ee8:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  }

  shift |= shiftcode[data];
80102eed:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef0:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ef5:	8a 00                	mov    (%eax),%al
80102ef7:	0f b6 d0             	movzbl %al,%edx
80102efa:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102eff:	09 d0                	or     %edx,%eax
80102f01:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  shift ^= togglecode[data];
80102f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f09:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f0e:	8a 00                	mov    (%eax),%al
80102f10:	0f b6 d0             	movzbl %al,%edx
80102f13:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f18:	31 d0                	xor    %edx,%eax
80102f1a:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102f1f:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f24:	83 e0 03             	and    $0x3,%eax
80102f27:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f31:	01 d0                	add    %edx,%eax
80102f33:	8a 00                	mov    (%eax),%al
80102f35:	0f b6 c0             	movzbl %al,%eax
80102f38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f3b:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f40:	83 e0 08             	and    $0x8,%eax
80102f43:	85 c0                	test   %eax,%eax
80102f45:	74 22                	je     80102f69 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102f47:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f4b:	76 0c                	jbe    80102f59 <kbdgetc+0x13a>
80102f4d:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f51:	77 06                	ja     80102f59 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f53:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f57:	eb 10                	jmp    80102f69 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f59:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f5d:	76 0a                	jbe    80102f69 <kbdgetc+0x14a>
80102f5f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f63:	77 04                	ja     80102f69 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f65:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f69:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f6c:	c9                   	leave  
80102f6d:	c3                   	ret    

80102f6e <kbdintr>:

void
kbdintr(void)
{
80102f6e:	55                   	push   %ebp
80102f6f:	89 e5                	mov    %esp,%ebp
80102f71:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f74:	c7 04 24 1f 2e 10 80 	movl   $0x80102e1f,(%esp)
80102f7b:	e8 75 d8 ff ff       	call   801007f5 <consoleintr>
}
80102f80:	c9                   	leave  
80102f81:	c3                   	ret    
	...

80102f84 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f84:	55                   	push   %ebp
80102f85:	89 e5                	mov    %esp,%ebp
80102f87:	83 ec 14             	sub    $0x14,%esp
80102f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f8d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f94:	89 c2                	mov    %eax,%edx
80102f96:	ec                   	in     (%dx),%al
80102f97:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f9a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f9d:	c9                   	leave  
80102f9e:	c3                   	ret    

80102f9f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f9f:	55                   	push   %ebp
80102fa0:	89 e5                	mov    %esp,%ebp
80102fa2:	83 ec 08             	sub    $0x8,%esp
80102fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa8:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fab:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102faf:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fb2:	8a 45 f8             	mov    -0x8(%ebp),%al
80102fb5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102fb8:	ee                   	out    %al,(%dx)
}
80102fb9:	c9                   	leave  
80102fba:	c3                   	ret    

80102fbb <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fbb:	55                   	push   %ebp
80102fbc:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fbe:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102fc3:	8b 55 08             	mov    0x8(%ebp),%edx
80102fc6:	c1 e2 02             	shl    $0x2,%edx
80102fc9:	01 c2                	add    %eax,%edx
80102fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fce:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fd0:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102fd5:	83 c0 20             	add    $0x20,%eax
80102fd8:	8b 00                	mov    (%eax),%eax
}
80102fda:	5d                   	pop    %ebp
80102fdb:	c3                   	ret    

80102fdc <lapicinit>:

void
lapicinit(void)
{
80102fdc:	55                   	push   %ebp
80102fdd:	89 e5                	mov    %esp,%ebp
80102fdf:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102fe2:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102fe7:	85 c0                	test   %eax,%eax
80102fe9:	75 05                	jne    80102ff0 <lapicinit+0x14>
    return;
80102feb:	e9 43 01 00 00       	jmp    80103133 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ff0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102ff7:	00 
80102ff8:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102fff:	e8 b7 ff ff ff       	call   80102fbb <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103004:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010300b:	00 
8010300c:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103013:	e8 a3 ff ff ff       	call   80102fbb <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103018:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010301f:	00 
80103020:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103027:	e8 8f ff ff ff       	call   80102fbb <lapicw>
  lapicw(TICR, 10000000);
8010302c:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103033:	00 
80103034:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010303b:	e8 7b ff ff ff       	call   80102fbb <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103040:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103047:	00 
80103048:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010304f:	e8 67 ff ff ff       	call   80102fbb <lapicw>
  lapicw(LINT1, MASKED);
80103054:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010305b:	00 
8010305c:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103063:	e8 53 ff ff ff       	call   80102fbb <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103068:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010306d:	83 c0 30             	add    $0x30,%eax
80103070:	8b 00                	mov    (%eax),%eax
80103072:	c1 e8 10             	shr    $0x10,%eax
80103075:	0f b6 c0             	movzbl %al,%eax
80103078:	83 f8 03             	cmp    $0x3,%eax
8010307b:	76 14                	jbe    80103091 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
8010307d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103084:	00 
80103085:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
8010308c:	e8 2a ff ff ff       	call   80102fbb <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103091:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103098:	00 
80103099:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801030a0:	e8 16 ff ff ff       	call   80102fbb <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030ac:	00 
801030ad:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030b4:	e8 02 ff ff ff       	call   80102fbb <lapicw>
  lapicw(ESR, 0);
801030b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030c0:	00 
801030c1:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030c8:	e8 ee fe ff ff       	call   80102fbb <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030d4:	00 
801030d5:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801030dc:	e8 da fe ff ff       	call   80102fbb <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030e8:	00 
801030e9:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030f0:	e8 c6 fe ff ff       	call   80102fbb <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030f5:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801030fc:	00 
801030fd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103104:	e8 b2 fe ff ff       	call   80102fbb <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103109:	90                   	nop
8010310a:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010310f:	05 00 03 00 00       	add    $0x300,%eax
80103114:	8b 00                	mov    (%eax),%eax
80103116:	25 00 10 00 00       	and    $0x1000,%eax
8010311b:	85 c0                	test   %eax,%eax
8010311d:	75 eb                	jne    8010310a <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010311f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103126:	00 
80103127:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010312e:	e8 88 fe ff ff       	call   80102fbb <lapicw>
}
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <lapicid>:

int
lapicid(void)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103138:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010313d:	85 c0                	test   %eax,%eax
8010313f:	75 07                	jne    80103148 <lapicid+0x13>
    return 0;
80103141:	b8 00 00 00 00       	mov    $0x0,%eax
80103146:	eb 0d                	jmp    80103155 <lapicid+0x20>
  return lapic[ID] >> 24;
80103148:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010314d:	83 c0 20             	add    $0x20,%eax
80103150:	8b 00                	mov    (%eax),%eax
80103152:	c1 e8 18             	shr    $0x18,%eax
}
80103155:	5d                   	pop    %ebp
80103156:	c3                   	ret    

80103157 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103157:	55                   	push   %ebp
80103158:	89 e5                	mov    %esp,%ebp
8010315a:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
8010315d:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103162:	85 c0                	test   %eax,%eax
80103164:	74 14                	je     8010317a <lapiceoi+0x23>
    lapicw(EOI, 0);
80103166:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010316d:	00 
8010316e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103175:	e8 41 fe ff ff       	call   80102fbb <lapicw>
}
8010317a:	c9                   	leave  
8010317b:	c3                   	ret    

8010317c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010317c:	55                   	push   %ebp
8010317d:	89 e5                	mov    %esp,%ebp
}
8010317f:	5d                   	pop    %ebp
80103180:	c3                   	ret    

80103181 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103181:	55                   	push   %ebp
80103182:	89 e5                	mov    %esp,%ebp
80103184:	83 ec 1c             	sub    $0x1c,%esp
80103187:	8b 45 08             	mov    0x8(%ebp),%eax
8010318a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010318d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103194:	00 
80103195:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010319c:	e8 fe fd ff ff       	call   80102f9f <outb>
  outb(CMOS_PORT+1, 0x0A);
801031a1:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801031a8:	00 
801031a9:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801031b0:	e8 ea fd ff ff       	call   80102f9f <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031b5:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031bf:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031c7:	8d 50 02             	lea    0x2(%eax),%edx
801031ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801031cd:	c1 e8 04             	shr    $0x4,%eax
801031d0:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031d3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031d7:	c1 e0 18             	shl    $0x18,%eax
801031da:	89 44 24 04          	mov    %eax,0x4(%esp)
801031de:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031e5:	e8 d1 fd ff ff       	call   80102fbb <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031ea:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801031f1:	00 
801031f2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031f9:	e8 bd fd ff ff       	call   80102fbb <lapicw>
  microdelay(200);
801031fe:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103205:	e8 72 ff ff ff       	call   8010317c <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010320a:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103211:	00 
80103212:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103219:	e8 9d fd ff ff       	call   80102fbb <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010321e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103225:	e8 52 ff ff ff       	call   8010317c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010322a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103231:	eb 3f                	jmp    80103272 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103233:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103237:	c1 e0 18             	shl    $0x18,%eax
8010323a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010323e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103245:	e8 71 fd ff ff       	call   80102fbb <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010324a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010324d:	c1 e8 0c             	shr    $0xc,%eax
80103250:	80 cc 06             	or     $0x6,%ah
80103253:	89 44 24 04          	mov    %eax,0x4(%esp)
80103257:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010325e:	e8 58 fd ff ff       	call   80102fbb <lapicw>
    microdelay(200);
80103263:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010326a:	e8 0d ff ff ff       	call   8010317c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010326f:	ff 45 fc             	incl   -0x4(%ebp)
80103272:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103276:	7e bb                	jle    80103233 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103278:	c9                   	leave  
80103279:	c3                   	ret    

8010327a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010327a:	55                   	push   %ebp
8010327b:	89 e5                	mov    %esp,%ebp
8010327d:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103280:	8b 45 08             	mov    0x8(%ebp),%eax
80103283:	0f b6 c0             	movzbl %al,%eax
80103286:	89 44 24 04          	mov    %eax,0x4(%esp)
8010328a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103291:	e8 09 fd ff ff       	call   80102f9f <outb>
  microdelay(200);
80103296:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010329d:	e8 da fe ff ff       	call   8010317c <microdelay>

  return inb(CMOS_RETURN);
801032a2:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032a9:	e8 d6 fc ff ff       	call   80102f84 <inb>
801032ae:	0f b6 c0             	movzbl %al,%eax
}
801032b1:	c9                   	leave  
801032b2:	c3                   	ret    

801032b3 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801032b3:	55                   	push   %ebp
801032b4:	89 e5                	mov    %esp,%ebp
801032b6:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801032b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801032c0:	e8 b5 ff ff ff       	call   8010327a <cmos_read>
801032c5:	8b 55 08             	mov    0x8(%ebp),%edx
801032c8:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032ca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801032d1:	e8 a4 ff ff ff       	call   8010327a <cmos_read>
801032d6:	8b 55 08             	mov    0x8(%ebp),%edx
801032d9:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801032dc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801032e3:	e8 92 ff ff ff       	call   8010327a <cmos_read>
801032e8:	8b 55 08             	mov    0x8(%ebp),%edx
801032eb:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801032ee:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801032f5:	e8 80 ff ff ff       	call   8010327a <cmos_read>
801032fa:	8b 55 08             	mov    0x8(%ebp),%edx
801032fd:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103300:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103307:	e8 6e ff ff ff       	call   8010327a <cmos_read>
8010330c:	8b 55 08             	mov    0x8(%ebp),%edx
8010330f:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103312:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103319:	e8 5c ff ff ff       	call   8010327a <cmos_read>
8010331e:	8b 55 08             	mov    0x8(%ebp),%edx
80103321:	89 42 14             	mov    %eax,0x14(%edx)
}
80103324:	c9                   	leave  
80103325:	c3                   	ret    

80103326 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103326:	55                   	push   %ebp
80103327:	89 e5                	mov    %esp,%ebp
80103329:	57                   	push   %edi
8010332a:	56                   	push   %esi
8010332b:	53                   	push   %ebx
8010332c:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010332f:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103336:	e8 3f ff ff ff       	call   8010327a <cmos_read>
8010333b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010333e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103341:	83 e0 04             	and    $0x4,%eax
80103344:	85 c0                	test   %eax,%eax
80103346:	0f 94 c0             	sete   %al
80103349:	0f b6 c0             	movzbl %al,%eax
8010334c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010334f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103352:	89 04 24             	mov    %eax,(%esp)
80103355:	e8 59 ff ff ff       	call   801032b3 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010335a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103361:	e8 14 ff ff ff       	call   8010327a <cmos_read>
80103366:	25 80 00 00 00       	and    $0x80,%eax
8010336b:	85 c0                	test   %eax,%eax
8010336d:	74 02                	je     80103371 <cmostime+0x4b>
        continue;
8010336f:	eb 36                	jmp    801033a7 <cmostime+0x81>
    fill_rtcdate(&t2);
80103371:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103374:	89 04 24             	mov    %eax,(%esp)
80103377:	e8 37 ff ff ff       	call   801032b3 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010337c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103383:	00 
80103384:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103387:	89 44 24 04          	mov    %eax,0x4(%esp)
8010338b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010338e:	89 04 24             	mov    %eax,(%esp)
80103391:	e8 cb 20 00 00       	call   80105461 <memcmp>
80103396:	85 c0                	test   %eax,%eax
80103398:	75 0d                	jne    801033a7 <cmostime+0x81>
      break;
8010339a:	90                   	nop
  }

  // convert
  if(bcd) {
8010339b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010339f:	0f 84 ac 00 00 00    	je     80103451 <cmostime+0x12b>
801033a5:	eb 02                	jmp    801033a9 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801033a7:	eb a6                	jmp    8010334f <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033a9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801033ac:	c1 e8 04             	shr    $0x4,%eax
801033af:	89 c2                	mov    %eax,%edx
801033b1:	89 d0                	mov    %edx,%eax
801033b3:	c1 e0 02             	shl    $0x2,%eax
801033b6:	01 d0                	add    %edx,%eax
801033b8:	01 c0                	add    %eax,%eax
801033ba:	8b 55 c8             	mov    -0x38(%ebp),%edx
801033bd:	83 e2 0f             	and    $0xf,%edx
801033c0:	01 d0                	add    %edx,%eax
801033c2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801033c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
801033c8:	c1 e8 04             	shr    $0x4,%eax
801033cb:	89 c2                	mov    %eax,%edx
801033cd:	89 d0                	mov    %edx,%eax
801033cf:	c1 e0 02             	shl    $0x2,%eax
801033d2:	01 d0                	add    %edx,%eax
801033d4:	01 c0                	add    %eax,%eax
801033d6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801033d9:	83 e2 0f             	and    $0xf,%edx
801033dc:	01 d0                	add    %edx,%eax
801033de:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
801033e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801033e4:	c1 e8 04             	shr    $0x4,%eax
801033e7:	89 c2                	mov    %eax,%edx
801033e9:	89 d0                	mov    %edx,%eax
801033eb:	c1 e0 02             	shl    $0x2,%eax
801033ee:	01 d0                	add    %edx,%eax
801033f0:	01 c0                	add    %eax,%eax
801033f2:	8b 55 d0             	mov    -0x30(%ebp),%edx
801033f5:	83 e2 0f             	and    $0xf,%edx
801033f8:	01 d0                	add    %edx,%eax
801033fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801033fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103400:	c1 e8 04             	shr    $0x4,%eax
80103403:	89 c2                	mov    %eax,%edx
80103405:	89 d0                	mov    %edx,%eax
80103407:	c1 e0 02             	shl    $0x2,%eax
8010340a:	01 d0                	add    %edx,%eax
8010340c:	01 c0                	add    %eax,%eax
8010340e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103411:	83 e2 0f             	and    $0xf,%edx
80103414:	01 d0                	add    %edx,%eax
80103416:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103419:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010341c:	c1 e8 04             	shr    $0x4,%eax
8010341f:	89 c2                	mov    %eax,%edx
80103421:	89 d0                	mov    %edx,%eax
80103423:	c1 e0 02             	shl    $0x2,%eax
80103426:	01 d0                	add    %edx,%eax
80103428:	01 c0                	add    %eax,%eax
8010342a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010342d:	83 e2 0f             	and    $0xf,%edx
80103430:	01 d0                	add    %edx,%eax
80103432:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103435:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103438:	c1 e8 04             	shr    $0x4,%eax
8010343b:	89 c2                	mov    %eax,%edx
8010343d:	89 d0                	mov    %edx,%eax
8010343f:	c1 e0 02             	shl    $0x2,%eax
80103442:	01 d0                	add    %edx,%eax
80103444:	01 c0                	add    %eax,%eax
80103446:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103449:	83 e2 0f             	and    $0xf,%edx
8010344c:	01 d0                	add    %edx,%eax
8010344e:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103451:	8b 45 08             	mov    0x8(%ebp),%eax
80103454:	89 c2                	mov    %eax,%edx
80103456:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103459:	b8 06 00 00 00       	mov    $0x6,%eax
8010345e:	89 d7                	mov    %edx,%edi
80103460:	89 de                	mov    %ebx,%esi
80103462:	89 c1                	mov    %eax,%ecx
80103464:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
80103466:	8b 45 08             	mov    0x8(%ebp),%eax
80103469:	8b 40 14             	mov    0x14(%eax),%eax
8010346c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	89 50 14             	mov    %edx,0x14(%eax)
}
80103478:	83 c4 5c             	add    $0x5c,%esp
8010347b:	5b                   	pop    %ebx
8010347c:	5e                   	pop    %esi
8010347d:	5f                   	pop    %edi
8010347e:	5d                   	pop    %ebp
8010347f:	c3                   	ret    

80103480 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103480:	55                   	push   %ebp
80103481:	89 e5                	mov    %esp,%ebp
80103483:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103486:	c7 44 24 04 33 92 10 	movl   $0x80109233,0x4(%esp)
8010348d:	80 
8010348e:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103495:	e8 cc 1c 00 00       	call   80105166 <initlock>
  readsb(dev, &sb);
8010349a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010349d:	89 44 24 04          	mov    %eax,0x4(%esp)
801034a1:	8b 45 08             	mov    0x8(%ebp),%eax
801034a4:	89 04 24             	mov    %eax,(%esp)
801034a7:	e8 14 e0 ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	a3 b4 4b 11 80       	mov    %eax,0x80114bb4
  log.size = sb.nlog;
801034b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034b7:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
  log.dev = dev;
801034bc:	8b 45 08             	mov    0x8(%ebp),%eax
801034bf:	a3 c4 4b 11 80       	mov    %eax,0x80114bc4
  recover_from_log();
801034c4:	e8 95 01 00 00       	call   8010365e <recover_from_log>
}
801034c9:	c9                   	leave  
801034ca:	c3                   	ret    

801034cb <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801034cb:	55                   	push   %ebp
801034cc:	89 e5                	mov    %esp,%ebp
801034ce:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034d8:	e9 89 00 00 00       	jmp    80103566 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801034dd:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
801034e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e6:	01 d0                	add    %edx,%eax
801034e8:	40                   	inc    %eax
801034e9:	89 c2                	mov    %eax,%edx
801034eb:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801034f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801034f4:	89 04 24             	mov    %eax,(%esp)
801034f7:	e8 b9 cc ff ff       	call   801001b5 <bread>
801034fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103502:	83 c0 10             	add    $0x10,%eax
80103505:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010350c:	89 c2                	mov    %eax,%edx
8010350e:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103513:	89 54 24 04          	mov    %edx,0x4(%esp)
80103517:	89 04 24             	mov    %eax,(%esp)
8010351a:	e8 96 cc ff ff       	call   801001b5 <bread>
8010351f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103522:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103525:	8d 50 5c             	lea    0x5c(%eax),%edx
80103528:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010352b:	83 c0 5c             	add    $0x5c,%eax
8010352e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103535:	00 
80103536:	89 54 24 04          	mov    %edx,0x4(%esp)
8010353a:	89 04 24             	mov    %eax,(%esp)
8010353d:	e8 71 1f 00 00       	call   801054b3 <memmove>
    bwrite(dbuf);  // write dst to disk
80103542:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103545:	89 04 24             	mov    %eax,(%esp)
80103548:	e8 9f cc ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
8010354d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103550:	89 04 24             	mov    %eax,(%esp)
80103553:	e8 d4 cc ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103558:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010355b:	89 04 24             	mov    %eax,(%esp)
8010355e:	e8 c9 cc ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103563:	ff 45 f4             	incl   -0xc(%ebp)
80103566:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010356b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010356e:	0f 8f 69 ff ff ff    	jg     801034dd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103574:	c9                   	leave  
80103575:	c3                   	ret    

80103576 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103576:	55                   	push   %ebp
80103577:	89 e5                	mov    %esp,%ebp
80103579:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010357c:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
80103581:	89 c2                	mov    %eax,%edx
80103583:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358c:	89 04 24             	mov    %eax,(%esp)
8010358f:	e8 21 cc ff ff       	call   801001b5 <bread>
80103594:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103597:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010359a:	83 c0 5c             	add    $0x5c,%eax
8010359d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a3:	8b 00                	mov    (%eax),%eax
801035a5:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  for (i = 0; i < log.lh.n; i++) {
801035aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035b1:	eb 1a                	jmp    801035cd <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801035b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035b9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801035bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035c0:	83 c2 10             	add    $0x10,%edx
801035c3:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801035ca:	ff 45 f4             	incl   -0xc(%ebp)
801035cd:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801035d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035d5:	7f dc                	jg     801035b3 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801035d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035da:	89 04 24             	mov    %eax,(%esp)
801035dd:	e8 4a cc ff ff       	call   8010022c <brelse>
}
801035e2:	c9                   	leave  
801035e3:	c3                   	ret    

801035e4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035e4:	55                   	push   %ebp
801035e5:	89 e5                	mov    %esp,%ebp
801035e7:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801035ea:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
801035ef:	89 c2                	mov    %eax,%edx
801035f1:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801035f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801035fa:	89 04 24             	mov    %eax,(%esp)
801035fd:	e8 b3 cb ff ff       	call   801001b5 <bread>
80103602:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103605:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103608:	83 c0 5c             	add    $0x5c,%eax
8010360b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010360e:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
80103614:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103617:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103619:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103620:	eb 1a                	jmp    8010363c <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103625:	83 c0 10             	add    $0x10,%eax
80103628:	8b 0c 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%ecx
8010362f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103635:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103639:	ff 45 f4             	incl   -0xc(%ebp)
8010363c:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103641:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103644:	7f dc                	jg     80103622 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103649:	89 04 24             	mov    %eax,(%esp)
8010364c:	e8 9b cb ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103654:	89 04 24             	mov    %eax,(%esp)
80103657:	e8 d0 cb ff ff       	call   8010022c <brelse>
}
8010365c:	c9                   	leave  
8010365d:	c3                   	ret    

8010365e <recover_from_log>:

static void
recover_from_log(void)
{
8010365e:	55                   	push   %ebp
8010365f:	89 e5                	mov    %esp,%ebp
80103661:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103664:	e8 0d ff ff ff       	call   80103576 <read_head>
  install_trans(); // if committed, copy from log to disk
80103669:	e8 5d fe ff ff       	call   801034cb <install_trans>
  log.lh.n = 0;
8010366e:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103675:	00 00 00 
  write_head(); // clear the log
80103678:	e8 67 ff ff ff       	call   801035e4 <write_head>
}
8010367d:	c9                   	leave  
8010367e:	c3                   	ret    

8010367f <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010367f:	55                   	push   %ebp
80103680:	89 e5                	mov    %esp,%ebp
80103682:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103685:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010368c:	e8 f6 1a 00 00       	call   80105187 <acquire>
  while(1){
    if(log.committing){
80103691:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
80103696:	85 c0                	test   %eax,%eax
80103698:	74 16                	je     801036b0 <begin_op+0x31>
      sleep(&log, &log.lock);
8010369a:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
801036a1:	80 
801036a2:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036a9:	e8 4a 15 00 00       	call   80104bf8 <sleep>
801036ae:	eb 4d                	jmp    801036fd <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801036b0:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
801036b6:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036bb:	8d 48 01             	lea    0x1(%eax),%ecx
801036be:	89 c8                	mov    %ecx,%eax
801036c0:	c1 e0 02             	shl    $0x2,%eax
801036c3:	01 c8                	add    %ecx,%eax
801036c5:	01 c0                	add    %eax,%eax
801036c7:	01 d0                	add    %edx,%eax
801036c9:	83 f8 1e             	cmp    $0x1e,%eax
801036cc:	7e 16                	jle    801036e4 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036ce:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
801036d5:	80 
801036d6:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036dd:	e8 16 15 00 00       	call   80104bf8 <sleep>
801036e2:	eb 19                	jmp    801036fd <begin_op+0x7e>
    } else {
      log.outstanding += 1;
801036e4:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036e9:	40                   	inc    %eax
801036ea:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
      release(&log.lock);
801036ef:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036f6:	e8 f6 1a 00 00       	call   801051f1 <release>
      break;
801036fb:	eb 02                	jmp    801036ff <begin_op+0x80>
    }
  }
801036fd:	eb 92                	jmp    80103691 <begin_op+0x12>
}
801036ff:	c9                   	leave  
80103700:	c3                   	ret    

80103701 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103701:	55                   	push   %ebp
80103702:	89 e5                	mov    %esp,%ebp
80103704:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103707:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010370e:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103715:	e8 6d 1a 00 00       	call   80105187 <acquire>
  log.outstanding -= 1;
8010371a:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
8010371f:	48                   	dec    %eax
80103720:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
  if(log.committing)
80103725:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
8010372a:	85 c0                	test   %eax,%eax
8010372c:	74 0c                	je     8010373a <end_op+0x39>
    panic("log.committing");
8010372e:	c7 04 24 37 92 10 80 	movl   $0x80109237,(%esp)
80103735:	e8 1a ce ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010373a:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
8010373f:	85 c0                	test   %eax,%eax
80103741:	75 13                	jne    80103756 <end_op+0x55>
    do_commit = 1;
80103743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010374a:	c7 05 c0 4b 11 80 01 	movl   $0x1,0x80114bc0
80103751:	00 00 00 
80103754:	eb 0c                	jmp    80103762 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103756:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010375d:	e8 6d 15 00 00       	call   80104ccf <wakeup>
  }
  release(&log.lock);
80103762:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103769:	e8 83 1a 00 00       	call   801051f1 <release>

  if(do_commit){
8010376e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103772:	74 33                	je     801037a7 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103774:	e8 db 00 00 00       	call   80103854 <commit>
    acquire(&log.lock);
80103779:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103780:	e8 02 1a 00 00       	call   80105187 <acquire>
    log.committing = 0;
80103785:	c7 05 c0 4b 11 80 00 	movl   $0x0,0x80114bc0
8010378c:	00 00 00 
    wakeup(&log);
8010378f:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103796:	e8 34 15 00 00       	call   80104ccf <wakeup>
    release(&log.lock);
8010379b:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037a2:	e8 4a 1a 00 00       	call   801051f1 <release>
  }
}
801037a7:	c9                   	leave  
801037a8:	c3                   	ret    

801037a9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b6:	e9 89 00 00 00       	jmp    80103844 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037bb:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
801037c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c4:	01 d0                	add    %edx,%eax
801037c6:	40                   	inc    %eax
801037c7:	89 c2                	mov    %eax,%edx
801037c9:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801037ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801037d2:	89 04 24             	mov    %eax,(%esp)
801037d5:	e8 db c9 ff ff       	call   801001b5 <bread>
801037da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e0:	83 c0 10             	add    $0x10,%eax
801037e3:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
801037ea:	89 c2                	mov    %eax,%edx
801037ec:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801037f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801037f5:	89 04 24             	mov    %eax,(%esp)
801037f8:	e8 b8 c9 ff ff       	call   801001b5 <bread>
801037fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103800:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103803:	8d 50 5c             	lea    0x5c(%eax),%edx
80103806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103809:	83 c0 5c             	add    $0x5c,%eax
8010380c:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103813:	00 
80103814:	89 54 24 04          	mov    %edx,0x4(%esp)
80103818:	89 04 24             	mov    %eax,(%esp)
8010381b:	e8 93 1c 00 00       	call   801054b3 <memmove>
    bwrite(to);  // write the log
80103820:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103823:	89 04 24             	mov    %eax,(%esp)
80103826:	e8 c1 c9 ff ff       	call   801001ec <bwrite>
    brelse(from);
8010382b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010382e:	89 04 24             	mov    %eax,(%esp)
80103831:	e8 f6 c9 ff ff       	call   8010022c <brelse>
    brelse(to);
80103836:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103839:	89 04 24             	mov    %eax,(%esp)
8010383c:	e8 eb c9 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103841:	ff 45 f4             	incl   -0xc(%ebp)
80103844:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103849:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010384c:	0f 8f 69 ff ff ff    	jg     801037bb <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103852:	c9                   	leave  
80103853:	c3                   	ret    

80103854 <commit>:

static void
commit()
{
80103854:	55                   	push   %ebp
80103855:	89 e5                	mov    %esp,%ebp
80103857:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010385a:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010385f:	85 c0                	test   %eax,%eax
80103861:	7e 1e                	jle    80103881 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103863:	e8 41 ff ff ff       	call   801037a9 <write_log>
    write_head();    // Write header to disk -- the real commit
80103868:	e8 77 fd ff ff       	call   801035e4 <write_head>
    install_trans(); // Now install writes to home locations
8010386d:	e8 59 fc ff ff       	call   801034cb <install_trans>
    log.lh.n = 0;
80103872:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103879:	00 00 00 
    write_head();    // Erase the transaction from the log
8010387c:	e8 63 fd ff ff       	call   801035e4 <write_head>
  }
}
80103881:	c9                   	leave  
80103882:	c3                   	ret    

80103883 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103883:	55                   	push   %ebp
80103884:	89 e5                	mov    %esp,%ebp
80103886:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103889:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010388e:	83 f8 1d             	cmp    $0x1d,%eax
80103891:	7f 10                	jg     801038a3 <log_write+0x20>
80103893:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103898:	8b 15 b8 4b 11 80    	mov    0x80114bb8,%edx
8010389e:	4a                   	dec    %edx
8010389f:	39 d0                	cmp    %edx,%eax
801038a1:	7c 0c                	jl     801038af <log_write+0x2c>
    panic("too big a transaction");
801038a3:	c7 04 24 46 92 10 80 	movl   $0x80109246,(%esp)
801038aa:	e8 a5 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801038af:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801038b4:	85 c0                	test   %eax,%eax
801038b6:	7f 0c                	jg     801038c4 <log_write+0x41>
    panic("log_write outside of trans");
801038b8:	c7 04 24 5c 92 10 80 	movl   $0x8010925c,(%esp)
801038bf:	e8 90 cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801038c4:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801038cb:	e8 b7 18 00 00       	call   80105187 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801038d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038d7:	eb 1e                	jmp    801038f7 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801038d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038dc:	83 c0 10             	add    $0x10,%eax
801038df:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
801038e6:	89 c2                	mov    %eax,%edx
801038e8:	8b 45 08             	mov    0x8(%ebp),%eax
801038eb:	8b 40 08             	mov    0x8(%eax),%eax
801038ee:	39 c2                	cmp    %eax,%edx
801038f0:	75 02                	jne    801038f4 <log_write+0x71>
      break;
801038f2:	eb 0d                	jmp    80103901 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801038f4:	ff 45 f4             	incl   -0xc(%ebp)
801038f7:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ff:	7f d8                	jg     801038d9 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103901:	8b 45 08             	mov    0x8(%ebp),%eax
80103904:	8b 40 08             	mov    0x8(%eax),%eax
80103907:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010390a:	83 c2 10             	add    $0x10,%edx
8010390d:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
  if (i == log.lh.n)
80103914:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103919:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010391c:	75 0b                	jne    80103929 <log_write+0xa6>
    log.lh.n++;
8010391e:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103923:	40                   	inc    %eax
80103924:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  b->flags |= B_DIRTY; // prevent eviction
80103929:	8b 45 08             	mov    0x8(%ebp),%eax
8010392c:	8b 00                	mov    (%eax),%eax
8010392e:	83 c8 04             	or     $0x4,%eax
80103931:	89 c2                	mov    %eax,%edx
80103933:	8b 45 08             	mov    0x8(%ebp),%eax
80103936:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103938:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010393f:	e8 ad 18 00 00       	call   801051f1 <release>
}
80103944:	c9                   	leave  
80103945:	c3                   	ret    
	...

80103948 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103948:	55                   	push   %ebp
80103949:	89 e5                	mov    %esp,%ebp
8010394b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010394e:	8b 55 08             	mov    0x8(%ebp),%edx
80103951:	8b 45 0c             	mov    0xc(%ebp),%eax
80103954:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103957:	f0 87 02             	lock xchg %eax,(%edx)
8010395a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010395d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103960:	c9                   	leave  
80103961:	c3                   	ret    

80103962 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103962:	55                   	push   %ebp
80103963:	89 e5                	mov    %esp,%ebp
80103965:	83 e4 f0             	and    $0xfffffff0,%esp
80103968:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010396b:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103972:	80 
80103973:	c7 04 24 b0 7c 11 80 	movl   $0x80117cb0,(%esp)
8010397a:	e8 49 f2 ff ff       	call   80102bc8 <kinit1>
  kvmalloc();      // kernel page table
8010397f:	e8 c7 47 00 00       	call   8010814b <kvmalloc>
  mpinit();        // detect other processors
80103984:	e8 cc 03 00 00       	call   80103d55 <mpinit>
  lapicinit();     // interrupt controller
80103989:	e8 4e f6 ff ff       	call   80102fdc <lapicinit>
  seginit();       // segment descriptors
8010398e:	e8 a0 42 00 00       	call   80107c33 <seginit>
  picinit();       // disable pic
80103993:	e8 0c 05 00 00       	call   80103ea4 <picinit>
  ioapicinit();    // another interrupt controller
80103998:	e8 48 f1 ff ff       	call   80102ae5 <ioapicinit>
  consoleinit();   // console hardware
8010399d:	e8 4d d2 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
801039a2:	e8 18 36 00 00       	call   80106fbf <uartinit>
  pinit();         // process table
801039a7:	e8 ee 08 00 00       	call   8010429a <pinit>
  tvinit();        // trap vectors
801039ac:	e8 db 31 00 00       	call   80106b8c <tvinit>
  binit();         // buffer cache
801039b1:	e8 7e c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039b6:	e8 2b d7 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
801039bb:	e8 31 ed ff ff       	call   801026f1 <ideinit>
  startothers();   // start other processors
801039c0:	e8 88 00 00 00       	call   80103a4d <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039c5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801039cc:	8e 
801039cd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801039d4:	e8 27 f2 ff ff       	call   80102c00 <kinit2>
  userinit();      // first user process
801039d9:	e8 e6 0a 00 00       	call   801044c4 <userinit>
  container_init();
801039de:	e8 65 54 00 00       	call   80108e48 <container_init>
  mpmain();        // finish this processor's setup
801039e3:	e8 1a 00 00 00       	call   80103a02 <mpmain>

801039e8 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039e8:	55                   	push   %ebp
801039e9:	89 e5                	mov    %esp,%ebp
801039eb:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801039ee:	e8 6f 47 00 00       	call   80108162 <switchkvm>
  seginit();
801039f3:	e8 3b 42 00 00       	call   80107c33 <seginit>
  lapicinit();
801039f8:	e8 df f5 ff ff       	call   80102fdc <lapicinit>
  mpmain();
801039fd:	e8 00 00 00 00       	call   80103a02 <mpmain>

80103a02 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a02:	55                   	push   %ebp
80103a03:	89 e5                	mov    %esp,%ebp
80103a05:	53                   	push   %ebx
80103a06:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a09:	e8 a8 08 00 00       	call   801042b6 <cpuid>
80103a0e:	89 c3                	mov    %eax,%ebx
80103a10:	e8 a1 08 00 00       	call   801042b6 <cpuid>
80103a15:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103a19:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a1d:	c7 04 24 77 92 10 80 	movl   $0x80109277,(%esp)
80103a24:	e8 98 c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103a29:	e8 bb 32 00 00       	call   80106ce9 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a2e:	e8 c8 08 00 00       	call   801042fb <mycpu>
80103a33:	05 a0 00 00 00       	add    $0xa0,%eax
80103a38:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103a3f:	00 
80103a40:	89 04 24             	mov    %eax,(%esp)
80103a43:	e8 00 ff ff ff       	call   80103948 <xchg>
  scheduler();     // start running processes
80103a48:	e8 de 0f 00 00       	call   80104a2b <scheduler>

80103a4d <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a4d:	55                   	push   %ebp
80103a4e:	89 e5                	mov    %esp,%ebp
80103a50:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103a53:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a5a:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a63:	c7 44 24 04 6c c5 10 	movl   $0x8010c56c,0x4(%esp)
80103a6a:	80 
80103a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6e:	89 04 24             	mov    %eax,(%esp)
80103a71:	e8 3d 1a 00 00       	call   801054b3 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a76:	c7 45 f4 80 4c 11 80 	movl   $0x80114c80,-0xc(%ebp)
80103a7d:	eb 75                	jmp    80103af4 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103a7f:	e8 77 08 00 00       	call   801042fb <mycpu>
80103a84:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a87:	75 02                	jne    80103a8b <startothers+0x3e>
      continue;
80103a89:	eb 62                	jmp    80103aed <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a8b:	e8 c1 f2 ff ff       	call   80102d51 <kalloc>
80103a90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a96:	83 e8 04             	sub    $0x4,%eax
80103a99:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a9c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103aa2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa7:	83 e8 08             	sub    $0x8,%eax
80103aaa:	c7 00 e8 39 10 80    	movl   $0x801039e8,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab3:	8d 50 f4             	lea    -0xc(%eax),%edx
80103ab6:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103abb:	05 00 00 00 80       	add    $0x80000000,%eax
80103ac0:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	8a 00                	mov    (%eax),%al
80103ad0:	0f b6 c0             	movzbl %al,%eax
80103ad3:	89 54 24 04          	mov    %edx,0x4(%esp)
80103ad7:	89 04 24             	mov    %eax,(%esp)
80103ada:	e8 a2 f6 ff ff       	call   80103181 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103adf:	90                   	nop
80103ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103ae9:	85 c0                	test   %eax,%eax
80103aeb:	74 f3                	je     80103ae0 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103aed:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103af4:	a1 00 52 11 80       	mov    0x80115200,%eax
80103af9:	89 c2                	mov    %eax,%edx
80103afb:	89 d0                	mov    %edx,%eax
80103afd:	c1 e0 02             	shl    $0x2,%eax
80103b00:	01 d0                	add    %edx,%eax
80103b02:	01 c0                	add    %eax,%eax
80103b04:	01 d0                	add    %edx,%eax
80103b06:	c1 e0 04             	shl    $0x4,%eax
80103b09:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103b0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b11:	0f 87 68 ff ff ff    	ja     80103a7f <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b17:	c9                   	leave  
80103b18:	c3                   	ret    
80103b19:	00 00                	add    %al,(%eax)
	...

80103b1c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103b1c:	55                   	push   %ebp
80103b1d:	89 e5                	mov    %esp,%ebp
80103b1f:	83 ec 14             	sub    $0x14,%esp
80103b22:	8b 45 08             	mov    0x8(%ebp),%eax
80103b25:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b2c:	89 c2                	mov    %eax,%edx
80103b2e:	ec                   	in     (%dx),%al
80103b2f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b32:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103b35:	c9                   	leave  
80103b36:	c3                   	ret    

80103b37 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b37:	55                   	push   %ebp
80103b38:	89 e5                	mov    %esp,%ebp
80103b3a:	83 ec 08             	sub    $0x8,%esp
80103b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b40:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b43:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b47:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b4a:	8a 45 f8             	mov    -0x8(%ebp),%al
80103b4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b50:	ee                   	out    %al,(%dx)
}
80103b51:	c9                   	leave  
80103b52:	c3                   	ret    

80103b53 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103b53:	55                   	push   %ebp
80103b54:	89 e5                	mov    %esp,%ebp
80103b56:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103b59:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b67:	eb 13                	jmp    80103b7c <sum+0x29>
    sum += addr[i];
80103b69:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6f:	01 d0                	add    %edx,%eax
80103b71:	8a 00                	mov    (%eax),%al
80103b73:	0f b6 c0             	movzbl %al,%eax
80103b76:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b79:	ff 45 fc             	incl   -0x4(%ebp)
80103b7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b7f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b82:	7c e5                	jl     80103b69 <sum+0x16>
    sum += addr[i];
  return sum;
80103b84:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b87:	c9                   	leave  
80103b88:	c3                   	ret    

80103b89 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b89:	55                   	push   %ebp
80103b8a:	89 e5                	mov    %esp,%ebp
80103b8c:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b92:	05 00 00 00 80       	add    $0x80000000,%eax
80103b97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba0:	01 d0                	add    %edx,%eax
80103ba2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bab:	eb 3f                	jmp    80103bec <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bad:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bb4:	00 
80103bb5:	c7 44 24 04 8c 92 10 	movl   $0x8010928c,0x4(%esp)
80103bbc:	80 
80103bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc0:	89 04 24             	mov    %eax,(%esp)
80103bc3:	e8 99 18 00 00       	call   80105461 <memcmp>
80103bc8:	85 c0                	test   %eax,%eax
80103bca:	75 1c                	jne    80103be8 <mpsearch1+0x5f>
80103bcc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103bd3:	00 
80103bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd7:	89 04 24             	mov    %eax,(%esp)
80103bda:	e8 74 ff ff ff       	call   80103b53 <sum>
80103bdf:	84 c0                	test   %al,%al
80103be1:	75 05                	jne    80103be8 <mpsearch1+0x5f>
      return (struct mp*)p;
80103be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be6:	eb 11                	jmp    80103bf9 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103be8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bf2:	72 b9                	jb     80103bad <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bf9:	c9                   	leave  
80103bfa:	c3                   	ret    

80103bfb <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bfb:	55                   	push   %ebp
80103bfc:	89 e5                	mov    %esp,%ebp
80103bfe:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c01:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0b:	83 c0 0f             	add    $0xf,%eax
80103c0e:	8a 00                	mov    (%eax),%al
80103c10:	0f b6 c0             	movzbl %al,%eax
80103c13:	c1 e0 08             	shl    $0x8,%eax
80103c16:	89 c2                	mov    %eax,%edx
80103c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1b:	83 c0 0e             	add    $0xe,%eax
80103c1e:	8a 00                	mov    (%eax),%al
80103c20:	0f b6 c0             	movzbl %al,%eax
80103c23:	09 d0                	or     %edx,%eax
80103c25:	c1 e0 04             	shl    $0x4,%eax
80103c28:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c2f:	74 21                	je     80103c52 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103c31:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c38:	00 
80103c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3c:	89 04 24             	mov    %eax,(%esp)
80103c3f:	e8 45 ff ff ff       	call   80103b89 <mpsearch1>
80103c44:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c4b:	74 4e                	je     80103c9b <mpsearch+0xa0>
      return mp;
80103c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c50:	eb 5d                	jmp    80103caf <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c55:	83 c0 14             	add    $0x14,%eax
80103c58:	8a 00                	mov    (%eax),%al
80103c5a:	0f b6 c0             	movzbl %al,%eax
80103c5d:	c1 e0 08             	shl    $0x8,%eax
80103c60:	89 c2                	mov    %eax,%edx
80103c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c65:	83 c0 13             	add    $0x13,%eax
80103c68:	8a 00                	mov    (%eax),%al
80103c6a:	0f b6 c0             	movzbl %al,%eax
80103c6d:	09 d0                	or     %edx,%eax
80103c6f:	c1 e0 0a             	shl    $0xa,%eax
80103c72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c78:	2d 00 04 00 00       	sub    $0x400,%eax
80103c7d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c84:	00 
80103c85:	89 04 24             	mov    %eax,(%esp)
80103c88:	e8 fc fe ff ff       	call   80103b89 <mpsearch1>
80103c8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c94:	74 05                	je     80103c9b <mpsearch+0xa0>
      return mp;
80103c96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c99:	eb 14                	jmp    80103caf <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c9b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ca2:	00 
80103ca3:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103caa:	e8 da fe ff ff       	call   80103b89 <mpsearch1>
}
80103caf:	c9                   	leave  
80103cb0:	c3                   	ret    

80103cb1 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103cb1:	55                   	push   %ebp
80103cb2:	89 e5                	mov    %esp,%ebp
80103cb4:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103cb7:	e8 3f ff ff ff       	call   80103bfb <mpsearch>
80103cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cc3:	74 0a                	je     80103ccf <mpconfig+0x1e>
80103cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc8:	8b 40 04             	mov    0x4(%eax),%eax
80103ccb:	85 c0                	test   %eax,%eax
80103ccd:	75 07                	jne    80103cd6 <mpconfig+0x25>
    return 0;
80103ccf:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd4:	eb 7d                	jmp    80103d53 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd9:	8b 40 04             	mov    0x4(%eax),%eax
80103cdc:	05 00 00 00 80       	add    $0x80000000,%eax
80103ce1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103ce4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ceb:	00 
80103cec:	c7 44 24 04 91 92 10 	movl   $0x80109291,0x4(%esp)
80103cf3:	80 
80103cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf7:	89 04 24             	mov    %eax,(%esp)
80103cfa:	e8 62 17 00 00       	call   80105461 <memcmp>
80103cff:	85 c0                	test   %eax,%eax
80103d01:	74 07                	je     80103d0a <mpconfig+0x59>
    return 0;
80103d03:	b8 00 00 00 00       	mov    $0x0,%eax
80103d08:	eb 49                	jmp    80103d53 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d0d:	8a 40 06             	mov    0x6(%eax),%al
80103d10:	3c 01                	cmp    $0x1,%al
80103d12:	74 11                	je     80103d25 <mpconfig+0x74>
80103d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d17:	8a 40 06             	mov    0x6(%eax),%al
80103d1a:	3c 04                	cmp    $0x4,%al
80103d1c:	74 07                	je     80103d25 <mpconfig+0x74>
    return 0;
80103d1e:	b8 00 00 00 00       	mov    $0x0,%eax
80103d23:	eb 2e                	jmp    80103d53 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d28:	8b 40 04             	mov    0x4(%eax),%eax
80103d2b:	0f b7 c0             	movzwl %ax,%eax
80103d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d35:	89 04 24             	mov    %eax,(%esp)
80103d38:	e8 16 fe ff ff       	call   80103b53 <sum>
80103d3d:	84 c0                	test   %al,%al
80103d3f:	74 07                	je     80103d48 <mpconfig+0x97>
    return 0;
80103d41:	b8 00 00 00 00       	mov    $0x0,%eax
80103d46:	eb 0b                	jmp    80103d53 <mpconfig+0xa2>
  *pmp = mp;
80103d48:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d4e:	89 10                	mov    %edx,(%eax)
  return conf;
80103d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d53:	c9                   	leave  
80103d54:	c3                   	ret    

80103d55 <mpinit>:

void
mpinit(void)
{
80103d55:	55                   	push   %ebp
80103d56:	89 e5                	mov    %esp,%ebp
80103d58:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103d5b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103d5e:	89 04 24             	mov    %eax,(%esp)
80103d61:	e8 4b ff ff ff       	call   80103cb1 <mpconfig>
80103d66:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d69:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d6d:	75 0c                	jne    80103d7b <mpinit+0x26>
    panic("Expect to run on an SMP");
80103d6f:	c7 04 24 96 92 10 80 	movl   $0x80109296,(%esp)
80103d76:	e8 d9 c7 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d7b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d85:	8b 40 24             	mov    0x24(%eax),%eax
80103d88:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d90:	83 c0 2c             	add    $0x2c,%eax
80103d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d99:	8b 40 04             	mov    0x4(%eax),%eax
80103d9c:	0f b7 d0             	movzwl %ax,%edx
80103d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103da2:	01 d0                	add    %edx,%eax
80103da4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103da7:	eb 7d                	jmp    80103e26 <mpinit+0xd1>
    switch(*p){
80103da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dac:	8a 00                	mov    (%eax),%al
80103dae:	0f b6 c0             	movzbl %al,%eax
80103db1:	83 f8 04             	cmp    $0x4,%eax
80103db4:	77 68                	ja     80103e1e <mpinit+0xc9>
80103db6:	8b 04 85 d0 92 10 80 	mov    -0x7fef6d30(,%eax,4),%eax
80103dbd:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103dc5:	a1 00 52 11 80       	mov    0x80115200,%eax
80103dca:	83 f8 07             	cmp    $0x7,%eax
80103dcd:	7f 2c                	jg     80103dfb <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103dcf:	8b 15 00 52 11 80    	mov    0x80115200,%edx
80103dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dd8:	8a 48 01             	mov    0x1(%eax),%cl
80103ddb:	89 d0                	mov    %edx,%eax
80103ddd:	c1 e0 02             	shl    $0x2,%eax
80103de0:	01 d0                	add    %edx,%eax
80103de2:	01 c0                	add    %eax,%eax
80103de4:	01 d0                	add    %edx,%eax
80103de6:	c1 e0 04             	shl    $0x4,%eax
80103de9:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103dee:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103df0:	a1 00 52 11 80       	mov    0x80115200,%eax
80103df5:	40                   	inc    %eax
80103df6:	a3 00 52 11 80       	mov    %eax,0x80115200
      }
      p += sizeof(struct mpproc);
80103dfb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103dff:	eb 25                	jmp    80103e26 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e04:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0a:	8a 40 01             	mov    0x1(%eax),%al
80103e0d:	a2 60 4c 11 80       	mov    %al,0x80114c60
      p += sizeof(struct mpioapic);
80103e12:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e16:	eb 0e                	jmp    80103e26 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e18:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e1c:	eb 08                	jmp    80103e26 <mpinit+0xd1>
    default:
      ismp = 0;
80103e1e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103e25:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e29:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103e2c:	0f 82 77 ff ff ff    	jb     80103da9 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103e32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e36:	75 0c                	jne    80103e44 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103e38:	c7 04 24 b0 92 10 80 	movl   $0x801092b0,(%esp)
80103e3f:	e8 10 c7 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103e44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e47:	8a 40 0c             	mov    0xc(%eax),%al
80103e4a:	84 c0                	test   %al,%al
80103e4c:	74 36                	je     80103e84 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e4e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103e55:	00 
80103e56:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103e5d:	e8 d5 fc ff ff       	call   80103b37 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e62:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e69:	e8 ae fc ff ff       	call   80103b1c <inb>
80103e6e:	83 c8 01             	or     $0x1,%eax
80103e71:	0f b6 c0             	movzbl %al,%eax
80103e74:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e78:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e7f:	e8 b3 fc ff ff       	call   80103b37 <outb>
  }
}
80103e84:	c9                   	leave  
80103e85:	c3                   	ret    
	...

80103e88 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e88:	55                   	push   %ebp
80103e89:	89 e5                	mov    %esp,%ebp
80103e8b:	83 ec 08             	sub    $0x8,%esp
80103e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e91:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e94:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103e98:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e9b:	8a 45 f8             	mov    -0x8(%ebp),%al
80103e9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ea1:	ee                   	out    %al,(%dx)
}
80103ea2:	c9                   	leave  
80103ea3:	c3                   	ret    

80103ea4 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103ea4:	55                   	push   %ebp
80103ea5:	89 e5                	mov    %esp,%ebp
80103ea7:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103eaa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103eb1:	00 
80103eb2:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eb9:	e8 ca ff ff ff       	call   80103e88 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ebe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ec5:	00 
80103ec6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ecd:	e8 b6 ff ff ff       	call   80103e88 <outb>
}
80103ed2:	c9                   	leave  
80103ed3:	c3                   	ret    

80103ed4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ed4:	55                   	push   %ebp
80103ed5:	89 e5                	mov    %esp,%ebp
80103ed7:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103eda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eed:	8b 10                	mov    (%eax),%edx
80103eef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef2:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ef4:	e8 09 d2 ff ff       	call   80101102 <filealloc>
80103ef9:	8b 55 08             	mov    0x8(%ebp),%edx
80103efc:	89 02                	mov    %eax,(%edx)
80103efe:	8b 45 08             	mov    0x8(%ebp),%eax
80103f01:	8b 00                	mov    (%eax),%eax
80103f03:	85 c0                	test   %eax,%eax
80103f05:	0f 84 c8 00 00 00    	je     80103fd3 <pipealloc+0xff>
80103f0b:	e8 f2 d1 ff ff       	call   80101102 <filealloc>
80103f10:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f13:	89 02                	mov    %eax,(%edx)
80103f15:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f18:	8b 00                	mov    (%eax),%eax
80103f1a:	85 c0                	test   %eax,%eax
80103f1c:	0f 84 b1 00 00 00    	je     80103fd3 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f22:	e8 2a ee ff ff       	call   80102d51 <kalloc>
80103f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f2e:	75 05                	jne    80103f35 <pipealloc+0x61>
    goto bad;
80103f30:	e9 9e 00 00 00       	jmp    80103fd3 <pipealloc+0xff>
  p->readopen = 1;
80103f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f38:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f3f:	00 00 00 
  p->writeopen = 1;
80103f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f45:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f4c:	00 00 00 
  p->nwrite = 0;
80103f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f52:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f59:	00 00 00 
  p->nread = 0;
80103f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f66:	00 00 00 
  initlock(&p->lock, "pipe");
80103f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6c:	c7 44 24 04 e4 92 10 	movl   $0x801092e4,0x4(%esp)
80103f73:	80 
80103f74:	89 04 24             	mov    %eax,(%esp)
80103f77:	e8 ea 11 00 00       	call   80105166 <initlock>
  (*f0)->type = FD_PIPE;
80103f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7f:	8b 00                	mov    (%eax),%eax
80103f81:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f87:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8a:	8b 00                	mov    (%eax),%eax
80103f8c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f90:	8b 45 08             	mov    0x8(%ebp),%eax
80103f93:	8b 00                	mov    (%eax),%eax
80103f95:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f99:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9c:	8b 00                	mov    (%eax),%eax
80103f9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa1:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa7:	8b 00                	mov    (%eax),%eax
80103fa9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103faf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb2:	8b 00                	mov    (%eax),%eax
80103fb4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fbb:	8b 00                	mov    (%eax),%eax
80103fbd:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc4:	8b 00                	mov    (%eax),%eax
80103fc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc9:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103fcc:	b8 00 00 00 00       	mov    $0x0,%eax
80103fd1:	eb 42                	jmp    80104015 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103fd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fd7:	74 0b                	je     80103fe4 <pipealloc+0x110>
    kfree((char*)p);
80103fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdc:	89 04 24             	mov    %eax,(%esp)
80103fdf:	e8 79 ec ff ff       	call   80102c5d <kfree>
  if(*f0)
80103fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe7:	8b 00                	mov    (%eax),%eax
80103fe9:	85 c0                	test   %eax,%eax
80103feb:	74 0d                	je     80103ffa <pipealloc+0x126>
    fileclose(*f0);
80103fed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff0:	8b 00                	mov    (%eax),%eax
80103ff2:	89 04 24             	mov    %eax,(%esp)
80103ff5:	e8 b0 d1 ff ff       	call   801011aa <fileclose>
  if(*f1)
80103ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffd:	8b 00                	mov    (%eax),%eax
80103fff:	85 c0                	test   %eax,%eax
80104001:	74 0d                	je     80104010 <pipealloc+0x13c>
    fileclose(*f1);
80104003:	8b 45 0c             	mov    0xc(%ebp),%eax
80104006:	8b 00                	mov    (%eax),%eax
80104008:	89 04 24             	mov    %eax,(%esp)
8010400b:	e8 9a d1 ff ff       	call   801011aa <fileclose>
  return -1;
80104010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104015:	c9                   	leave  
80104016:	c3                   	ret    

80104017 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104017:	55                   	push   %ebp
80104018:	89 e5                	mov    %esp,%ebp
8010401a:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010401d:	8b 45 08             	mov    0x8(%ebp),%eax
80104020:	89 04 24             	mov    %eax,(%esp)
80104023:	e8 5f 11 00 00       	call   80105187 <acquire>
  if(writable){
80104028:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010402c:	74 1f                	je     8010404d <pipeclose+0x36>
    p->writeopen = 0;
8010402e:	8b 45 08             	mov    0x8(%ebp),%eax
80104031:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104038:	00 00 00 
    wakeup(&p->nread);
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	05 34 02 00 00       	add    $0x234,%eax
80104043:	89 04 24             	mov    %eax,(%esp)
80104046:	e8 84 0c 00 00       	call   80104ccf <wakeup>
8010404b:	eb 1d                	jmp    8010406a <pipeclose+0x53>
  } else {
    p->readopen = 0;
8010404d:	8b 45 08             	mov    0x8(%ebp),%eax
80104050:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104057:	00 00 00 
    wakeup(&p->nwrite);
8010405a:	8b 45 08             	mov    0x8(%ebp),%eax
8010405d:	05 38 02 00 00       	add    $0x238,%eax
80104062:	89 04 24             	mov    %eax,(%esp)
80104065:	e8 65 0c 00 00       	call   80104ccf <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010406a:	8b 45 08             	mov    0x8(%ebp),%eax
8010406d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104073:	85 c0                	test   %eax,%eax
80104075:	75 25                	jne    8010409c <pipeclose+0x85>
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104080:	85 c0                	test   %eax,%eax
80104082:	75 18                	jne    8010409c <pipeclose+0x85>
    release(&p->lock);
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	89 04 24             	mov    %eax,(%esp)
8010408a:	e8 62 11 00 00       	call   801051f1 <release>
    kfree((char*)p);
8010408f:	8b 45 08             	mov    0x8(%ebp),%eax
80104092:	89 04 24             	mov    %eax,(%esp)
80104095:	e8 c3 eb ff ff       	call   80102c5d <kfree>
8010409a:	eb 0b                	jmp    801040a7 <pipeclose+0x90>
  } else
    release(&p->lock);
8010409c:	8b 45 08             	mov    0x8(%ebp),%eax
8010409f:	89 04 24             	mov    %eax,(%esp)
801040a2:	e8 4a 11 00 00       	call   801051f1 <release>
}
801040a7:	c9                   	leave  
801040a8:	c3                   	ret    

801040a9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040a9:	55                   	push   %ebp
801040aa:	89 e5                	mov    %esp,%ebp
801040ac:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040af:	8b 45 08             	mov    0x8(%ebp),%eax
801040b2:	89 04 24             	mov    %eax,(%esp)
801040b5:	e8 cd 10 00 00       	call   80105187 <acquire>
  for(i = 0; i < n; i++){
801040ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040c1:	e9 a3 00 00 00       	jmp    80104169 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040c6:	eb 56                	jmp    8010411e <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
801040c8:	8b 45 08             	mov    0x8(%ebp),%eax
801040cb:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040d1:	85 c0                	test   %eax,%eax
801040d3:	74 0c                	je     801040e1 <pipewrite+0x38>
801040d5:	e8 a5 02 00 00       	call   8010437f <myproc>
801040da:	8b 40 24             	mov    0x24(%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	74 15                	je     801040f6 <pipewrite+0x4d>
        release(&p->lock);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	89 04 24             	mov    %eax,(%esp)
801040e7:	e8 05 11 00 00       	call   801051f1 <release>
        return -1;
801040ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f1:	e9 9d 00 00 00       	jmp    80104193 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801040f6:	8b 45 08             	mov    0x8(%ebp),%eax
801040f9:	05 34 02 00 00       	add    $0x234,%eax
801040fe:	89 04 24             	mov    %eax,(%esp)
80104101:	e8 c9 0b 00 00       	call   80104ccf <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104106:	8b 45 08             	mov    0x8(%ebp),%eax
80104109:	8b 55 08             	mov    0x8(%ebp),%edx
8010410c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104112:	89 44 24 04          	mov    %eax,0x4(%esp)
80104116:	89 14 24             	mov    %edx,(%esp)
80104119:	e8 da 0a 00 00       	call   80104bf8 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010411e:	8b 45 08             	mov    0x8(%ebp),%eax
80104121:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104127:	8b 45 08             	mov    0x8(%ebp),%eax
8010412a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104130:	05 00 02 00 00       	add    $0x200,%eax
80104135:	39 c2                	cmp    %eax,%edx
80104137:	74 8f                	je     801040c8 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104139:	8b 45 08             	mov    0x8(%ebp),%eax
8010413c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104142:	8d 48 01             	lea    0x1(%eax),%ecx
80104145:	8b 55 08             	mov    0x8(%ebp),%edx
80104148:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010414e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104153:	89 c1                	mov    %eax,%ecx
80104155:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	01 d0                	add    %edx,%eax
8010415d:	8a 10                	mov    (%eax),%dl
8010415f:	8b 45 08             	mov    0x8(%ebp),%eax
80104162:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104166:	ff 45 f4             	incl   -0xc(%ebp)
80104169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010416f:	0f 8c 51 ff ff ff    	jl     801040c6 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	05 34 02 00 00       	add    $0x234,%eax
8010417d:	89 04 24             	mov    %eax,(%esp)
80104180:	e8 4a 0b 00 00       	call   80104ccf <wakeup>
  release(&p->lock);
80104185:	8b 45 08             	mov    0x8(%ebp),%eax
80104188:	89 04 24             	mov    %eax,(%esp)
8010418b:	e8 61 10 00 00       	call   801051f1 <release>
  return n;
80104190:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104193:	c9                   	leave  
80104194:	c3                   	ret    

80104195 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104195:	55                   	push   %ebp
80104196:	89 e5                	mov    %esp,%ebp
80104198:	53                   	push   %ebx
80104199:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010419c:	8b 45 08             	mov    0x8(%ebp),%eax
8010419f:	89 04 24             	mov    %eax,(%esp)
801041a2:	e8 e0 0f 00 00       	call   80105187 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041a7:	eb 39                	jmp    801041e2 <piperead+0x4d>
    if(myproc()->killed){
801041a9:	e8 d1 01 00 00       	call   8010437f <myproc>
801041ae:	8b 40 24             	mov    0x24(%eax),%eax
801041b1:	85 c0                	test   %eax,%eax
801041b3:	74 15                	je     801041ca <piperead+0x35>
      release(&p->lock);
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	89 04 24             	mov    %eax,(%esp)
801041bb:	e8 31 10 00 00       	call   801051f1 <release>
      return -1;
801041c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c5:	e9 b3 00 00 00       	jmp    8010427d <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801041ca:	8b 45 08             	mov    0x8(%ebp),%eax
801041cd:	8b 55 08             	mov    0x8(%ebp),%edx
801041d0:	81 c2 34 02 00 00    	add    $0x234,%edx
801041d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801041da:	89 14 24             	mov    %edx,(%esp)
801041dd:	e8 16 0a 00 00       	call   80104bf8 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041f4:	39 c2                	cmp    %eax,%edx
801041f6:	75 0d                	jne    80104205 <piperead+0x70>
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104201:	85 c0                	test   %eax,%eax
80104203:	75 a4                	jne    801041a9 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104205:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010420c:	eb 49                	jmp    80104257 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104220:	39 c2                	cmp    %eax,%edx
80104222:	75 02                	jne    80104226 <piperead+0x91>
      break;
80104224:	eb 39                	jmp    8010425f <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104226:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104229:	8b 45 0c             	mov    0xc(%ebp),%eax
8010422c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010422f:	8b 45 08             	mov    0x8(%ebp),%eax
80104232:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104238:	8d 48 01             	lea    0x1(%eax),%ecx
8010423b:	8b 55 08             	mov    0x8(%ebp),%edx
8010423e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104244:	25 ff 01 00 00       	and    $0x1ff,%eax
80104249:	89 c2                	mov    %eax,%edx
8010424b:	8b 45 08             	mov    0x8(%ebp),%eax
8010424e:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104252:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104254:	ff 45 f4             	incl   -0xc(%ebp)
80104257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010425d:	7c af                	jl     8010420e <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	05 38 02 00 00       	add    $0x238,%eax
80104267:	89 04 24             	mov    %eax,(%esp)
8010426a:	e8 60 0a 00 00       	call   80104ccf <wakeup>
  release(&p->lock);
8010426f:	8b 45 08             	mov    0x8(%ebp),%eax
80104272:	89 04 24             	mov    %eax,(%esp)
80104275:	e8 77 0f 00 00       	call   801051f1 <release>
  return i;
8010427a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010427d:	83 c4 24             	add    $0x24,%esp
80104280:	5b                   	pop    %ebx
80104281:	5d                   	pop    %ebp
80104282:	c3                   	ret    
	...

80104284 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104284:	55                   	push   %ebp
80104285:	89 e5                	mov    %esp,%ebp
80104287:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010428a:	9c                   	pushf  
8010428b:	58                   	pop    %eax
8010428c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010428f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104292:	c9                   	leave  
80104293:	c3                   	ret    

80104294 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104294:	55                   	push   %ebp
80104295:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104297:	fb                   	sti    
}
80104298:	5d                   	pop    %ebp
80104299:	c3                   	ret    

8010429a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010429a:	55                   	push   %ebp
8010429b:	89 e5                	mov    %esp,%ebp
8010429d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801042a0:	c7 44 24 04 ec 92 10 	movl   $0x801092ec,0x4(%esp)
801042a7:	80 
801042a8:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801042af:	e8 b2 0e 00 00       	call   80105166 <initlock>
}
801042b4:	c9                   	leave  
801042b5:	c3                   	ret    

801042b6 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801042b6:	55                   	push   %ebp
801042b7:	89 e5                	mov    %esp,%ebp
801042b9:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801042bc:	e8 3a 00 00 00       	call   801042fb <mycpu>
801042c1:	89 c2                	mov    %eax,%edx
801042c3:	b8 80 4c 11 80       	mov    $0x80114c80,%eax
801042c8:	29 c2                	sub    %eax,%edx
801042ca:	89 d0                	mov    %edx,%eax
801042cc:	c1 f8 04             	sar    $0x4,%eax
801042cf:	89 c1                	mov    %eax,%ecx
801042d1:	89 ca                	mov    %ecx,%edx
801042d3:	c1 e2 03             	shl    $0x3,%edx
801042d6:	01 ca                	add    %ecx,%edx
801042d8:	89 d0                	mov    %edx,%eax
801042da:	c1 e0 05             	shl    $0x5,%eax
801042dd:	29 d0                	sub    %edx,%eax
801042df:	c1 e0 02             	shl    $0x2,%eax
801042e2:	01 c8                	add    %ecx,%eax
801042e4:	c1 e0 03             	shl    $0x3,%eax
801042e7:	01 c8                	add    %ecx,%eax
801042e9:	89 c2                	mov    %eax,%edx
801042eb:	c1 e2 0f             	shl    $0xf,%edx
801042ee:	29 c2                	sub    %eax,%edx
801042f0:	c1 e2 02             	shl    $0x2,%edx
801042f3:	01 ca                	add    %ecx,%edx
801042f5:	89 d0                	mov    %edx,%eax
801042f7:	f7 d8                	neg    %eax
}
801042f9:	c9                   	leave  
801042fa:	c3                   	ret    

801042fb <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801042fb:	55                   	push   %ebp
801042fc:	89 e5                	mov    %esp,%ebp
801042fe:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104301:	e8 7e ff ff ff       	call   80104284 <readeflags>
80104306:	25 00 02 00 00       	and    $0x200,%eax
8010430b:	85 c0                	test   %eax,%eax
8010430d:	74 0c                	je     8010431b <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010430f:	c7 04 24 f4 92 10 80 	movl   $0x801092f4,(%esp)
80104316:	e8 39 c2 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010431b:	e8 15 ee ff ff       	call   80103135 <lapicid>
80104320:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104323:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010432a:	eb 3b                	jmp    80104367 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
8010432c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010432f:	89 d0                	mov    %edx,%eax
80104331:	c1 e0 02             	shl    $0x2,%eax
80104334:	01 d0                	add    %edx,%eax
80104336:	01 c0                	add    %eax,%eax
80104338:	01 d0                	add    %edx,%eax
8010433a:	c1 e0 04             	shl    $0x4,%eax
8010433d:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104342:	8a 00                	mov    (%eax),%al
80104344:	0f b6 c0             	movzbl %al,%eax
80104347:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010434a:	75 18                	jne    80104364 <mycpu+0x69>
      return &cpus[i];
8010434c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010434f:	89 d0                	mov    %edx,%eax
80104351:	c1 e0 02             	shl    $0x2,%eax
80104354:	01 d0                	add    %edx,%eax
80104356:	01 c0                	add    %eax,%eax
80104358:	01 d0                	add    %edx,%eax
8010435a:	c1 e0 04             	shl    $0x4,%eax
8010435d:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104362:	eb 19                	jmp    8010437d <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104364:	ff 45 f4             	incl   -0xc(%ebp)
80104367:	a1 00 52 11 80       	mov    0x80115200,%eax
8010436c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010436f:	7c bb                	jl     8010432c <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104371:	c7 04 24 1a 93 10 80 	movl   $0x8010931a,(%esp)
80104378:	e8 d7 c1 ff ff       	call   80100554 <panic>
}
8010437d:	c9                   	leave  
8010437e:	c3                   	ret    

8010437f <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010437f:	55                   	push   %ebp
80104380:	89 e5                	mov    %esp,%ebp
80104382:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104385:	e8 5c 0f 00 00       	call   801052e6 <pushcli>
  c = mycpu();
8010438a:	e8 6c ff ff ff       	call   801042fb <mycpu>
8010438f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104395:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010439b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010439e:	e8 8d 0f 00 00       	call   80105330 <popcli>
  return p;
801043a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801043a6:	c9                   	leave  
801043a7:	c3                   	ret    

801043a8 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043a8:	55                   	push   %ebp
801043a9:	89 e5                	mov    %esp,%ebp
801043ab:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);
801043ae:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043b5:	e8 cd 0d 00 00       	call   80105187 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043ba:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801043c1:	eb 53                	jmp    80104416 <allocproc+0x6e>
    if(p->state == UNUSED)
801043c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c6:	8b 40 0c             	mov    0xc(%eax),%eax
801043c9:	85 c0                	test   %eax,%eax
801043cb:	75 42                	jne    8010440f <allocproc+0x67>
      goto found;
801043cd:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043d8:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801043dd:	8d 50 01             	lea    0x1(%eax),%edx
801043e0:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801043e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e9:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801043ec:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043f3:	e8 f9 0d 00 00       	call   801051f1 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043f8:	e8 54 e9 ff ff       	call   80102d51 <kalloc>
801043fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104400:	89 42 08             	mov    %eax,0x8(%edx)
80104403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104406:	8b 40 08             	mov    0x8(%eax),%eax
80104409:	85 c0                	test   %eax,%eax
8010440b:	75 39                	jne    80104446 <allocproc+0x9e>
8010440d:	eb 26                	jmp    80104435 <allocproc+0x8d>
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010440f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104416:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
8010441d:	72 a4                	jb     801043c3 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010441f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104426:	e8 c6 0d 00 00       	call   801051f1 <release>
  return 0;
8010442b:	b8 00 00 00 00       	mov    $0x0,%eax
80104430:	e9 8d 00 00 00       	jmp    801044c2 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104438:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010443f:	b8 00 00 00 00       	mov    $0x0,%eax
80104444:	eb 7c                	jmp    801044c2 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 40 08             	mov    0x8(%eax),%eax
8010444c:	05 00 10 00 00       	add    $0x1000,%eax
80104451:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104454:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010445e:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104461:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104465:	ba 48 6b 10 80       	mov    $0x80106b48,%edx
8010446a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010446d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010446f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104476:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104479:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104482:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104489:	00 
8010448a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104491:	00 
80104492:	89 04 24             	mov    %eax,(%esp)
80104495:	e8 50 0f 00 00       	call   801053ea <memset>
  p->context->eip = (uint)forkret;
8010449a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449d:	8b 40 1c             	mov    0x1c(%eax),%eax
801044a0:	ba b9 4b 10 80       	mov    $0x80104bb9,%edx
801044a5:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
801044a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ab:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
801044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b5:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801044bc:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
801044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044c2:	c9                   	leave  
801044c3:	c3                   	ret    

801044c4 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044c4:	55                   	push   %ebp
801044c5:	89 e5                	mov    %esp,%ebp
801044c7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801044ca:	e8 d9 fe ff ff       	call   801043a8 <allocproc>
801044cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801044d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d5:	a3 00 c9 10 80       	mov    %eax,0x8010c900
  if((p->pgdir = setupkvm()) == 0)
801044da:	e8 c3 3b 00 00       	call   801080a2 <setupkvm>
801044df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e2:	89 42 04             	mov    %eax,0x4(%edx)
801044e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e8:	8b 40 04             	mov    0x4(%eax),%eax
801044eb:	85 c0                	test   %eax,%eax
801044ed:	75 0c                	jne    801044fb <userinit+0x37>
    panic("userinit: out of memory?");
801044ef:	c7 04 24 2a 93 10 80 	movl   $0x8010932a,(%esp)
801044f6:	e8 59 c0 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044fb:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	8b 40 04             	mov    0x4(%eax),%eax
80104506:	89 54 24 08          	mov    %edx,0x8(%esp)
8010450a:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
80104511:	80 
80104512:	89 04 24             	mov    %eax,(%esp)
80104515:	e8 e9 3d 00 00       	call   80108303 <inituvm>
  p->sz = PGSIZE;
8010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	8b 40 18             	mov    0x18(%eax),%eax
80104529:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104530:	00 
80104531:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104538:	00 
80104539:	89 04 24             	mov    %eax,(%esp)
8010453c:	e8 a9 0e 00 00       	call   801053ea <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 18             	mov    0x18(%eax),%eax
80104547:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	8b 40 18             	mov    0x18(%eax),%eax
80104553:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455c:	8b 50 18             	mov    0x18(%eax),%edx
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	8b 40 18             	mov    0x18(%eax),%eax
80104565:	8b 40 2c             	mov    0x2c(%eax),%eax
80104568:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
8010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456f:	8b 50 18             	mov    0x18(%eax),%edx
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	8b 40 18             	mov    0x18(%eax),%eax
80104578:	8b 40 2c             	mov    0x2c(%eax),%eax
8010457b:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
8010457f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104582:	8b 40 18             	mov    0x18(%eax),%eax
80104585:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010458c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458f:	8b 40 18             	mov    0x18(%eax),%eax
80104592:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459c:	8b 40 18             	mov    0x18(%eax),%eax
8010459f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	83 c0 6c             	add    $0x6c,%eax
801045ac:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045b3:	00 
801045b4:	c7 44 24 04 43 93 10 	movl   $0x80109343,0x4(%esp)
801045bb:	80 
801045bc:	89 04 24             	mov    %eax,(%esp)
801045bf:	e8 32 10 00 00       	call   801055f6 <safestrcpy>
  p->cwd = namei("/");
801045c4:	c7 04 24 4c 93 10 80 	movl   $0x8010934c,(%esp)
801045cb:	e8 17 e0 ff ff       	call   801025e7 <namei>
801045d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d3:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801045d6:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801045dd:	e8 a5 0b 00 00       	call   80105187 <acquire>

  p->state = RUNNABLE;
801045e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801045ec:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801045f3:	e8 f9 0b 00 00       	call   801051f1 <release>
}
801045f8:	c9                   	leave  
801045f9:	c3                   	ret    

801045fa <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045fa:	55                   	push   %ebp
801045fb:	89 e5                	mov    %esp,%ebp
801045fd:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104600:	e8 7a fd ff ff       	call   8010437f <myproc>
80104605:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010460b:	8b 00                	mov    (%eax),%eax
8010460d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104610:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104614:	7e 31                	jle    80104647 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104616:	8b 55 08             	mov    0x8(%ebp),%edx
80104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461c:	01 c2                	add    %eax,%edx
8010461e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104621:	8b 40 04             	mov    0x4(%eax),%eax
80104624:	89 54 24 08          	mov    %edx,0x8(%esp)
80104628:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010462b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010462f:	89 04 24             	mov    %eax,(%esp)
80104632:	e8 37 3e 00 00       	call   8010846e <allocuvm>
80104637:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010463a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463e:	75 3e                	jne    8010467e <growproc+0x84>
      return -1;
80104640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104645:	eb 4f                	jmp    80104696 <growproc+0x9c>
  } else if(n < 0){
80104647:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010464b:	79 31                	jns    8010467e <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010464d:	8b 55 08             	mov    0x8(%ebp),%edx
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	01 c2                	add    %eax,%edx
80104655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104658:	8b 40 04             	mov    0x4(%eax),%eax
8010465b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010465f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104662:	89 54 24 04          	mov    %edx,0x4(%esp)
80104666:	89 04 24             	mov    %eax,(%esp)
80104669:	e8 16 3f 00 00       	call   80108584 <deallocuvm>
8010466e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104675:	75 07                	jne    8010467e <growproc+0x84>
      return -1;
80104677:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467c:	eb 18                	jmp    80104696 <growproc+0x9c>
  }
  curproc->sz = sz;
8010467e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104681:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104684:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104686:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104689:	89 04 24             	mov    %eax,(%esp)
8010468c:	e8 eb 3a 00 00       	call   8010817c <switchuvm>
  return 0;
80104691:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104696:	c9                   	leave  
80104697:	c3                   	ret    

80104698 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104698:	55                   	push   %ebp
80104699:	89 e5                	mov    %esp,%ebp
8010469b:	57                   	push   %edi
8010469c:	56                   	push   %esi
8010469d:	53                   	push   %ebx
8010469e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801046a1:	e8 d9 fc ff ff       	call   8010437f <myproc>
801046a6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801046a9:	e8 fa fc ff ff       	call   801043a8 <allocproc>
801046ae:	89 45 dc             	mov    %eax,-0x24(%ebp)
801046b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801046b5:	75 0a                	jne    801046c1 <fork+0x29>
    return -1;
801046b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046bc:	e9 47 01 00 00       	jmp    80104808 <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801046c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c4:	8b 10                	mov    (%eax),%edx
801046c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c9:	8b 40 04             	mov    0x4(%eax),%eax
801046cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801046d0:	89 04 24             	mov    %eax,(%esp)
801046d3:	e8 4c 40 00 00       	call   80108724 <copyuvm>
801046d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046db:	89 42 04             	mov    %eax,0x4(%edx)
801046de:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046e1:	8b 40 04             	mov    0x4(%eax),%eax
801046e4:	85 c0                	test   %eax,%eax
801046e6:	75 2c                	jne    80104714 <fork+0x7c>
    kfree(np->kstack);
801046e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046eb:	8b 40 08             	mov    0x8(%eax),%eax
801046ee:	89 04 24             	mov    %eax,(%esp)
801046f1:	e8 67 e5 ff ff       	call   80102c5d <kfree>
    np->kstack = 0;
801046f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104700:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104703:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010470a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010470f:	e9 f4 00 00 00       	jmp    80104808 <fork+0x170>
  }
  np->sz = curproc->sz;
80104714:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104717:	8b 10                	mov    (%eax),%edx
80104719:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010471c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010471e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104721:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104724:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104727:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010472a:	8b 50 18             	mov    0x18(%eax),%edx
8010472d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104730:	8b 40 18             	mov    0x18(%eax),%eax
80104733:	89 c3                	mov    %eax,%ebx
80104735:	b8 13 00 00 00       	mov    $0x13,%eax
8010473a:	89 d7                	mov    %edx,%edi
8010473c:	89 de                	mov    %ebx,%esi
8010473e:	89 c1                	mov    %eax,%ecx
80104740:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104742:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104745:	8b 40 18             	mov    0x18(%eax),%eax
80104748:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010474f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104756:	eb 36                	jmp    8010478e <fork+0xf6>
    if(curproc->ofile[i])
80104758:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010475e:	83 c2 08             	add    $0x8,%edx
80104761:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104765:	85 c0                	test   %eax,%eax
80104767:	74 22                	je     8010478b <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104769:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010476c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010476f:	83 c2 08             	add    $0x8,%edx
80104772:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104776:	89 04 24             	mov    %eax,(%esp)
80104779:	e8 e4 c9 ff ff       	call   80101162 <filedup>
8010477e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104781:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104784:	83 c1 08             	add    $0x8,%ecx
80104787:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010478b:	ff 45 e4             	incl   -0x1c(%ebp)
8010478e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104792:	7e c4                	jle    80104758 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104794:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104797:	8b 40 68             	mov    0x68(%eax),%eax
8010479a:	89 04 24             	mov    %eax,(%esp)
8010479d:	e8 ee d2 ff ff       	call   80101a90 <idup>
801047a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047a5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801047a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ab:	8d 50 6c             	lea    0x6c(%eax),%edx
801047ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047b1:	83 c0 6c             	add    $0x6c,%eax
801047b4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047bb:	00 
801047bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801047c0:	89 04 24             	mov    %eax,(%esp)
801047c3:	e8 2e 0e 00 00       	call   801055f6 <safestrcpy>



  pid = np->pid;
801047c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047cb:	8b 40 10             	mov    0x10(%eax),%eax
801047ce:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801047d1:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801047d8:	e8 aa 09 00 00       	call   80105187 <acquire>

  np->state = RUNNABLE;
801047dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047e0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
801047e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ea:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801047f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047f3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
801047f9:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104800:	e8 ec 09 00 00       	call   801051f1 <release>

  return pid;
80104805:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104808:	83 c4 2c             	add    $0x2c,%esp
8010480b:	5b                   	pop    %ebx
8010480c:	5e                   	pop    %esi
8010480d:	5f                   	pop    %edi
8010480e:	5d                   	pop    %ebp
8010480f:	c3                   	ret    

80104810 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104816:	e8 64 fb ff ff       	call   8010437f <myproc>
8010481b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010481e:	a1 00 c9 10 80       	mov    0x8010c900,%eax
80104823:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104826:	75 0c                	jne    80104834 <exit+0x24>
    panic("init exiting");
80104828:	c7 04 24 4e 93 10 80 	movl   $0x8010934e,(%esp)
8010482f:	e8 20 bd ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104834:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010483b:	eb 3a                	jmp    80104877 <exit+0x67>
    if(curproc->ofile[fd]){
8010483d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104840:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104843:	83 c2 08             	add    $0x8,%edx
80104846:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010484a:	85 c0                	test   %eax,%eax
8010484c:	74 26                	je     80104874 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010484e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104851:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104854:	83 c2 08             	add    $0x8,%edx
80104857:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010485b:	89 04 24             	mov    %eax,(%esp)
8010485e:	e8 47 c9 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104866:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104869:	83 c2 08             	add    $0x8,%edx
8010486c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104873:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104874:	ff 45 f0             	incl   -0x10(%ebp)
80104877:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010487b:	7e c0                	jle    8010483d <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010487d:	e8 fd ed ff ff       	call   8010367f <begin_op>
  iput(curproc->cwd);
80104882:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104885:	8b 40 68             	mov    0x68(%eax),%eax
80104888:	89 04 24             	mov    %eax,(%esp)
8010488b:	e8 80 d3 ff ff       	call   80101c10 <iput>
  end_op();
80104890:	e8 6c ee ff ff       	call   80103701 <end_op>
  curproc->cwd = 0;
80104895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104898:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010489f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801048a6:	e8 dc 08 00 00       	call   80105187 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801048ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048ae:	8b 40 14             	mov    0x14(%eax),%eax
801048b1:	89 04 24             	mov    %eax,(%esp)
801048b4:	e8 d5 03 00 00       	call   80104c8e <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b9:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801048c0:	eb 36                	jmp    801048f8 <exit+0xe8>
    if(p->parent == curproc){
801048c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c5:	8b 40 14             	mov    0x14(%eax),%eax
801048c8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048cb:	75 24                	jne    801048f1 <exit+0xe1>
      p->parent = initproc;
801048cd:	8b 15 00 c9 10 80    	mov    0x8010c900,%edx
801048d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d6:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048dc:	8b 40 0c             	mov    0xc(%eax),%eax
801048df:	83 f8 05             	cmp    $0x5,%eax
801048e2:	75 0d                	jne    801048f1 <exit+0xe1>
        wakeup1(initproc);
801048e4:	a1 00 c9 10 80       	mov    0x8010c900,%eax
801048e9:	89 04 24             	mov    %eax,(%esp)
801048ec:	e8 9d 03 00 00       	call   80104c8e <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f1:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048f8:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801048ff:	72 c1                	jb     801048c2 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104901:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104904:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010490b:	e8 c9 01 00 00       	call   80104ad9 <sched>
  panic("zombie exit");
80104910:	c7 04 24 5b 93 10 80 	movl   $0x8010935b,(%esp)
80104917:	e8 38 bc ff ff       	call   80100554 <panic>

8010491c <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010491c:	55                   	push   %ebp
8010491d:	89 e5                	mov    %esp,%ebp
8010491f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104922:	e8 58 fa ff ff       	call   8010437f <myproc>
80104927:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010492a:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104931:	e8 51 08 00 00       	call   80105187 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104936:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010493d:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104944:	e9 98 00 00 00       	jmp    801049e1 <wait+0xc5>
      if(p->parent != curproc)
80104949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494c:	8b 40 14             	mov    0x14(%eax),%eax
8010494f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104952:	74 05                	je     80104959 <wait+0x3d>
        continue;
80104954:	e9 81 00 00 00       	jmp    801049da <wait+0xbe>
      havekids = 1;
80104959:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104963:	8b 40 0c             	mov    0xc(%eax),%eax
80104966:	83 f8 05             	cmp    $0x5,%eax
80104969:	75 6f                	jne    801049da <wait+0xbe>
        // Found one.
        pid = p->pid;
8010496b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496e:	8b 40 10             	mov    0x10(%eax),%eax
80104971:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	8b 40 08             	mov    0x8(%eax),%eax
8010497a:	89 04 24             	mov    %eax,(%esp)
8010497d:	e8 db e2 ff ff       	call   80102c5d <kfree>
        p->kstack = 0;
80104982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104985:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498f:	8b 40 04             	mov    0x4(%eax),%eax
80104992:	89 04 24             	mov    %eax,(%esp)
80104995:	e8 ae 3c 00 00       	call   80108648 <freevm>
        p->pid = 0;
8010499a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801049bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049c9:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801049d0:	e8 1c 08 00 00       	call   801051f1 <release>
        return pid;
801049d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049d8:	eb 4f                	jmp    80104a29 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049da:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049e1:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801049e8:	0f 82 5b ff ff ff    	jb     80104949 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f2:	74 0a                	je     801049fe <wait+0xe2>
801049f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f7:	8b 40 24             	mov    0x24(%eax),%eax
801049fa:	85 c0                	test   %eax,%eax
801049fc:	74 13                	je     80104a11 <wait+0xf5>
      release(&ptable.lock);
801049fe:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a05:	e8 e7 07 00 00       	call   801051f1 <release>
      return -1;
80104a0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0f:	eb 18                	jmp    80104a29 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104a11:	c7 44 24 04 20 52 11 	movl   $0x80115220,0x4(%esp)
80104a18:	80 
80104a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1c:	89 04 24             	mov    %eax,(%esp)
80104a1f:	e8 d4 01 00 00       	call   80104bf8 <sleep>
  }
80104a24:	e9 0d ff ff ff       	jmp    80104936 <wait+0x1a>
}
80104a29:	c9                   	leave  
80104a2a:	c3                   	ret    

80104a2b <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a2b:	55                   	push   %ebp
80104a2c:	89 e5                	mov    %esp,%ebp
80104a2e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a31:	e8 c5 f8 ff ff       	call   801042fb <mycpu>
80104a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a3c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a43:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a46:	e8 49 f8 ff ff       	call   80104294 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a4b:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a52:	e8 30 07 00 00       	call   80105187 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a57:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104a5e:	eb 5f                	jmp    80104abf <scheduler+0x94>
      if(p->state != RUNNABLE)
80104a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a63:	8b 40 0c             	mov    0xc(%eax),%eax
80104a66:	83 f8 03             	cmp    $0x3,%eax
80104a69:	74 02                	je     80104a6d <scheduler+0x42>
        continue;
80104a6b:	eb 4b                	jmp    80104ab8 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a73:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7c:	89 04 24             	mov    %eax,(%esp)
80104a7f:	e8 f8 36 00 00       	call   8010817c <switchuvm>
      p->state = RUNNING;
80104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a87:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a91:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a97:	83 c2 04             	add    $0x4,%edx
80104a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a9e:	89 14 24             	mov    %edx,(%esp)
80104aa1:	e8 be 0b 00 00       	call   80105664 <swtch>
      switchkvm();
80104aa6:	e8 b7 36 00 00       	call   80108162 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aae:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ab5:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab8:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104abf:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104ac6:	72 98                	jb     80104a60 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104ac8:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104acf:	e8 1d 07 00 00       	call   801051f1 <release>

  }
80104ad4:	e9 6d ff ff ff       	jmp    80104a46 <scheduler+0x1b>

80104ad9 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ad9:	55                   	push   %ebp
80104ada:	89 e5                	mov    %esp,%ebp
80104adc:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104adf:	e8 9b f8 ff ff       	call   8010437f <myproc>
80104ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104ae7:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104aee:	e8 c2 07 00 00       	call   801052b5 <holding>
80104af3:	85 c0                	test   %eax,%eax
80104af5:	75 0c                	jne    80104b03 <sched+0x2a>
    panic("sched ptable.lock");
80104af7:	c7 04 24 67 93 10 80 	movl   $0x80109367,(%esp)
80104afe:	e8 51 ba ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104b03:	e8 f3 f7 ff ff       	call   801042fb <mycpu>
80104b08:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b0e:	83 f8 01             	cmp    $0x1,%eax
80104b11:	74 0c                	je     80104b1f <sched+0x46>
    panic("sched locks");
80104b13:	c7 04 24 79 93 10 80 	movl   $0x80109379,(%esp)
80104b1a:	e8 35 ba ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b22:	8b 40 0c             	mov    0xc(%eax),%eax
80104b25:	83 f8 04             	cmp    $0x4,%eax
80104b28:	75 0c                	jne    80104b36 <sched+0x5d>
    panic("sched running");
80104b2a:	c7 04 24 85 93 10 80 	movl   $0x80109385,(%esp)
80104b31:	e8 1e ba ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104b36:	e8 49 f7 ff ff       	call   80104284 <readeflags>
80104b3b:	25 00 02 00 00       	and    $0x200,%eax
80104b40:	85 c0                	test   %eax,%eax
80104b42:	74 0c                	je     80104b50 <sched+0x77>
    panic("sched interruptible");
80104b44:	c7 04 24 93 93 10 80 	movl   $0x80109393,(%esp)
80104b4b:	e8 04 ba ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104b50:	e8 a6 f7 ff ff       	call   801042fb <mycpu>
80104b55:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b5e:	e8 98 f7 ff ff       	call   801042fb <mycpu>
80104b63:	8b 40 04             	mov    0x4(%eax),%eax
80104b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b69:	83 c2 1c             	add    $0x1c,%edx
80104b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b70:	89 14 24             	mov    %edx,(%esp)
80104b73:	e8 ec 0a 00 00       	call   80105664 <swtch>
  mycpu()->intena = intena;
80104b78:	e8 7e f7 ff ff       	call   801042fb <mycpu>
80104b7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b80:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104b86:	c9                   	leave  
80104b87:	c3                   	ret    

80104b88 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b88:	55                   	push   %ebp
80104b89:	89 e5                	mov    %esp,%ebp
80104b8b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b8e:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b95:	e8 ed 05 00 00       	call   80105187 <acquire>
  myproc()->state = RUNNABLE;
80104b9a:	e8 e0 f7 ff ff       	call   8010437f <myproc>
80104b9f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ba6:	e8 2e ff ff ff       	call   80104ad9 <sched>
  release(&ptable.lock);
80104bab:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104bb2:	e8 3a 06 00 00       	call   801051f1 <release>
}
80104bb7:	c9                   	leave  
80104bb8:	c3                   	ret    

80104bb9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bb9:	55                   	push   %ebp
80104bba:	89 e5                	mov    %esp,%ebp
80104bbc:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bbf:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104bc6:	e8 26 06 00 00       	call   801051f1 <release>

  if (first) {
80104bcb:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104bd0:	85 c0                	test   %eax,%eax
80104bd2:	74 22                	je     80104bf6 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bd4:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104bdb:	00 00 00 
    iinit(ROOTDEV);
80104bde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104be5:	e8 71 cb ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104bea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bf1:	e8 8a e8 ff ff       	call   80103480 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104bf6:	c9                   	leave  
80104bf7:	c3                   	ret    

80104bf8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bf8:	55                   	push   %ebp
80104bf9:	89 e5                	mov    %esp,%ebp
80104bfb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104bfe:	e8 7c f7 ff ff       	call   8010437f <myproc>
80104c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c0a:	75 0c                	jne    80104c18 <sleep+0x20>
    panic("sleep");
80104c0c:	c7 04 24 a7 93 10 80 	movl   $0x801093a7,(%esp)
80104c13:	e8 3c b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104c18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c1c:	75 0c                	jne    80104c2a <sleep+0x32>
    panic("sleep without lk");
80104c1e:	c7 04 24 ad 93 10 80 	movl   $0x801093ad,(%esp)
80104c25:	e8 2a b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c2a:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104c31:	74 17                	je     80104c4a <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c33:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c3a:	e8 48 05 00 00       	call   80105187 <acquire>
    release(lk);
80104c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c42:	89 04 24             	mov    %eax,(%esp)
80104c45:	e8 a7 05 00 00       	call   801051f1 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4d:	8b 55 08             	mov    0x8(%ebp),%edx
80104c50:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c56:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c5d:	e8 77 fe ff ff       	call   80104ad9 <sched>

  // Tidy up.
  p->chan = 0;
80104c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c65:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c6c:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104c73:	74 17                	je     80104c8c <sleep+0x94>
    release(&ptable.lock);
80104c75:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c7c:	e8 70 05 00 00       	call   801051f1 <release>
    acquire(lk);
80104c81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c84:	89 04 24             	mov    %eax,(%esp)
80104c87:	e8 fb 04 00 00       	call   80105187 <acquire>
  }
}
80104c8c:	c9                   	leave  
80104c8d:	c3                   	ret    

80104c8e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c8e:	55                   	push   %ebp
80104c8f:	89 e5                	mov    %esp,%ebp
80104c91:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c94:	c7 45 fc 54 52 11 80 	movl   $0x80115254,-0x4(%ebp)
80104c9b:	eb 27                	jmp    80104cc4 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca3:	83 f8 02             	cmp    $0x2,%eax
80104ca6:	75 15                	jne    80104cbd <wakeup1+0x2f>
80104ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cab:	8b 40 20             	mov    0x20(%eax),%eax
80104cae:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cb1:	75 0a                	jne    80104cbd <wakeup1+0x2f>
      p->state = RUNNABLE;
80104cb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cb6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cbd:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104cc4:	81 7d fc 54 73 11 80 	cmpl   $0x80117354,-0x4(%ebp)
80104ccb:	72 d0                	jb     80104c9d <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104ccd:	c9                   	leave  
80104cce:	c3                   	ret    

80104ccf <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ccf:	55                   	push   %ebp
80104cd0:	89 e5                	mov    %esp,%ebp
80104cd2:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104cd5:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cdc:	e8 a6 04 00 00       	call   80105187 <acquire>
  wakeup1(chan);
80104ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce4:	89 04 24             	mov    %eax,(%esp)
80104ce7:	e8 a2 ff ff ff       	call   80104c8e <wakeup1>
  release(&ptable.lock);
80104cec:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cf3:	e8 f9 04 00 00       	call   801051f1 <release>
}
80104cf8:	c9                   	leave  
80104cf9:	c3                   	ret    

80104cfa <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cfa:	55                   	push   %ebp
80104cfb:	89 e5                	mov    %esp,%ebp
80104cfd:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d00:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d07:	e8 7b 04 00 00       	call   80105187 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d0c:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104d13:	eb 44                	jmp    80104d59 <kill+0x5f>
    if(p->pid == pid){
80104d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d18:	8b 40 10             	mov    0x10(%eax),%eax
80104d1b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d1e:	75 32                	jne    80104d52 <kill+0x58>
      p->killed = 1;
80104d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d23:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d30:	83 f8 02             	cmp    $0x2,%eax
80104d33:	75 0a                	jne    80104d3f <kill+0x45>
        p->state = RUNNABLE;
80104d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d38:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d3f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d46:	e8 a6 04 00 00       	call   801051f1 <release>
      return 0;
80104d4b:	b8 00 00 00 00       	mov    $0x0,%eax
80104d50:	eb 21                	jmp    80104d73 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d52:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d59:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104d60:	72 b3                	jb     80104d15 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d62:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d69:	e8 83 04 00 00       	call   801051f1 <release>
  return -1;
80104d6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d73:	c9                   	leave  
80104d74:	c3                   	ret    

80104d75 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d75:	55                   	push   %ebp
80104d76:	89 e5                	mov    %esp,%ebp
80104d78:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d7b:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104d82:	e9 1e 01 00 00       	jmp    80104ea5 <procdump+0x130>
    if(p->state == UNUSED)
80104d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d8a:	8b 40 0c             	mov    0xc(%eax),%eax
80104d8d:	85 c0                	test   %eax,%eax
80104d8f:	75 05                	jne    80104d96 <procdump+0x21>
      continue;
80104d91:	e9 08 01 00 00       	jmp    80104e9e <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d99:	8b 40 0c             	mov    0xc(%eax),%eax
80104d9c:	83 f8 05             	cmp    $0x5,%eax
80104d9f:	77 23                	ja     80104dc4 <procdump+0x4f>
80104da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da4:	8b 40 0c             	mov    0xc(%eax),%eax
80104da7:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104dae:	85 c0                	test   %eax,%eax
80104db0:	74 12                	je     80104dc4 <procdump+0x4f>
      state = states[p->state];
80104db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db5:	8b 40 0c             	mov    0xc(%eax),%eax
80104db8:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104dbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104dc2:	eb 07                	jmp    80104dcb <procdump+0x56>
    else
      state = "???";
80104dc4:	c7 45 ec be 93 10 80 	movl   $0x801093be,-0x14(%ebp)

    if(p->cont == NULL){
80104dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dce:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104dd4:	85 c0                	test   %eax,%eax
80104dd6:	75 29                	jne    80104e01 <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ddb:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de1:	8b 40 10             	mov    0x10(%eax),%eax
80104de4:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104de8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104deb:	89 54 24 08          	mov    %edx,0x8(%esp)
80104def:	89 44 24 04          	mov    %eax,0x4(%esp)
80104df3:	c7 04 24 c2 93 10 80 	movl   $0x801093c2,(%esp)
80104dfa:	e8 c2 b5 ff ff       	call   801003c1 <cprintf>
80104dff:	eb 37                	jmp    80104e38 <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e04:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e0a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104e10:	8d 48 18             	lea    0x18(%eax),%ecx
80104e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e16:	8b 40 10             	mov    0x10(%eax),%eax
80104e19:	89 54 24 10          	mov    %edx,0x10(%esp)
80104e1d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e20:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104e24:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104e28:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e2c:	c7 04 24 d0 93 10 80 	movl   $0x801093d0,(%esp)
80104e33:	e8 89 b5 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80104e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3b:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3e:	83 f8 02             	cmp    $0x2,%eax
80104e41:	75 4f                	jne    80104e92 <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e46:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e49:	8b 40 0c             	mov    0xc(%eax),%eax
80104e4c:	83 c0 08             	add    $0x8,%eax
80104e4f:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e52:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e56:	89 04 24             	mov    %eax,(%esp)
80104e59:	e8 e0 03 00 00       	call   8010523e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e65:	eb 1a                	jmp    80104e81 <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e72:	c7 04 24 dc 93 10 80 	movl   $0x801093dc,(%esp)
80104e79:	e8 43 b5 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e7e:	ff 45 f4             	incl   -0xc(%ebp)
80104e81:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e85:	7f 0b                	jg     80104e92 <procdump+0x11d>
80104e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e8e:	85 c0                	test   %eax,%eax
80104e90:	75 d5                	jne    80104e67 <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e92:	c7 04 24 e0 93 10 80 	movl   $0x801093e0,(%esp)
80104e99:	e8 23 b5 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e9e:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104ea5:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80104eac:	0f 82 d5 fe ff ff    	jb     80104d87 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104eb2:	c9                   	leave  
80104eb3:	c3                   	ret    

80104eb4 <strcmp1>:
//   return os;
// }

int
strcmp1(const char *p, const char *q)
{
80104eb4:	55                   	push   %ebp
80104eb5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104eb7:	eb 06                	jmp    80104ebf <strcmp1+0xb>
    p++, q++;
80104eb9:	ff 45 08             	incl   0x8(%ebp)
80104ebc:	ff 45 0c             	incl   0xc(%ebp)
// }

int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec2:	8a 00                	mov    (%eax),%al
80104ec4:	84 c0                	test   %al,%al
80104ec6:	74 0e                	je     80104ed6 <strcmp1+0x22>
80104ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecb:	8a 10                	mov    (%eax),%dl
80104ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed0:	8a 00                	mov    (%eax),%al
80104ed2:	38 c2                	cmp    %al,%dl
80104ed4:	74 e3                	je     80104eb9 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed9:	8a 00                	mov    (%eax),%al
80104edb:	0f b6 d0             	movzbl %al,%edx
80104ede:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee1:	8a 00                	mov    (%eax),%al
80104ee3:	0f b6 c0             	movzbl %al,%eax
80104ee6:	29 c2                	sub    %eax,%edx
80104ee8:	89 d0                	mov    %edx,%eax
}
80104eea:	5d                   	pop    %ebp
80104eeb:	c3                   	ret    

80104eec <c_procdump>:

void
c_procdump(char* name)
{
80104eec:	55                   	push   %ebp
80104eed:	89 e5                	mov    %esp,%ebp
80104eef:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef2:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104ef9:	e9 0f 01 00 00       	jmp    8010500d <c_procdump+0x121>

    // if(p->cont == NULL){
    //   cprintf("p_cont is null in %s.\n", name);
    // }
    if(p->state == UNUSED || p->cont == NULL)
80104efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f01:	8b 40 0c             	mov    0xc(%eax),%eax
80104f04:	85 c0                	test   %eax,%eax
80104f06:	74 0d                	je     80104f15 <c_procdump+0x29>
80104f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f11:	85 c0                	test   %eax,%eax
80104f13:	75 05                	jne    80104f1a <c_procdump+0x2e>
      continue;
80104f15:	e9 ec 00 00 00       	jmp    80105006 <c_procdump+0x11a>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f1d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f20:	83 f8 05             	cmp    $0x5,%eax
80104f23:	77 23                	ja     80104f48 <c_procdump+0x5c>
80104f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f28:	8b 40 0c             	mov    0xc(%eax),%eax
80104f2b:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80104f32:	85 c0                	test   %eax,%eax
80104f34:	74 12                	je     80104f48 <c_procdump+0x5c>
      state = states[p->state];
80104f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f39:	8b 40 0c             	mov    0xc(%eax),%eax
80104f3c:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80104f43:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f46:	eb 07                	jmp    80104f4f <c_procdump+0x63>
    else
      state = "???";
80104f48:	c7 45 ec be 93 10 80 	movl   $0x801093be,-0x14(%ebp)

    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
80104f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f52:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f58:	8d 50 18             	lea    0x18(%eax),%edx
80104f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f62:	89 14 24             	mov    %edx,(%esp)
80104f65:	e8 4a ff ff ff       	call   80104eb4 <strcmp1>
80104f6a:	85 c0                	test   %eax,%eax
80104f6c:	0f 85 94 00 00 00    	jne    80105006 <c_procdump+0x11a>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
80104f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f75:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f7b:	8b 40 10             	mov    0x10(%eax),%eax
80104f7e:	89 54 24 10          	mov    %edx,0x10(%esp)
80104f82:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f85:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f89:	8b 55 08             	mov    0x8(%ebp),%edx
80104f8c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f90:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f94:	c7 04 24 d0 93 10 80 	movl   $0x801093d0,(%esp)
80104f9b:	e8 21 b4 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
80104fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa3:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa6:	83 f8 02             	cmp    $0x2,%eax
80104fa9:	75 4f                	jne    80104ffa <c_procdump+0x10e>
        getcallerpcs((uint*)p->context->ebp+2, pc);
80104fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fae:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fb1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb4:	83 c0 08             	add    $0x8,%eax
80104fb7:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104fba:	89 54 24 04          	mov    %edx,0x4(%esp)
80104fbe:	89 04 24             	mov    %eax,(%esp)
80104fc1:	e8 78 02 00 00       	call   8010523e <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
80104fc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fcd:	eb 1a                	jmp    80104fe9 <c_procdump+0xfd>
          cprintf(" %p", pc[i]);
80104fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fda:	c7 04 24 dc 93 10 80 	movl   $0x801093dc,(%esp)
80104fe1:	e8 db b3 ff ff       	call   801003c1 <cprintf>
    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
80104fe6:	ff 45 f4             	incl   -0xc(%ebp)
80104fe9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fed:	7f 0b                	jg     80104ffa <c_procdump+0x10e>
80104fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ff6:	85 c0                	test   %eax,%eax
80104ff8:	75 d5                	jne    80104fcf <c_procdump+0xe3>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
80104ffa:	c7 04 24 e0 93 10 80 	movl   $0x801093e0,(%esp)
80105001:	e8 bb b3 ff ff       	call   801003c1 <cprintf>
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105006:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
8010500d:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80105014:	0f 82 e4 fe ff ff    	jb     80104efe <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
8010501a:	c9                   	leave  
8010501b:	c3                   	ret    

8010501c <initp>:



struct proc* initp(void){
8010501c:	55                   	push   %ebp
8010501d:	89 e5                	mov    %esp,%ebp
  return initproc;
8010501f:	a1 00 c9 10 80       	mov    0x8010c900,%eax
}
80105024:	5d                   	pop    %ebp
80105025:	c3                   	ret    
	...

80105028 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010502e:	8b 45 08             	mov    0x8(%ebp),%eax
80105031:	83 c0 04             	add    $0x4,%eax
80105034:	c7 44 24 04 0c 94 10 	movl   $0x8010940c,0x4(%esp)
8010503b:	80 
8010503c:	89 04 24             	mov    %eax,(%esp)
8010503f:	e8 22 01 00 00       	call   80105166 <initlock>
  lk->name = name;
80105044:	8b 45 08             	mov    0x8(%ebp),%eax
80105047:	8b 55 0c             	mov    0xc(%ebp),%edx
8010504a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010504d:	8b 45 08             	mov    0x8(%ebp),%eax
80105050:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105056:	8b 45 08             	mov    0x8(%ebp),%eax
80105059:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105060:	c9                   	leave  
80105061:	c3                   	ret    

80105062 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105062:	55                   	push   %ebp
80105063:	89 e5                	mov    %esp,%ebp
80105065:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105068:	8b 45 08             	mov    0x8(%ebp),%eax
8010506b:	83 c0 04             	add    $0x4,%eax
8010506e:	89 04 24             	mov    %eax,(%esp)
80105071:	e8 11 01 00 00       	call   80105187 <acquire>
  while (lk->locked) {
80105076:	eb 15                	jmp    8010508d <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105078:	8b 45 08             	mov    0x8(%ebp),%eax
8010507b:	83 c0 04             	add    $0x4,%eax
8010507e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105082:	8b 45 08             	mov    0x8(%ebp),%eax
80105085:	89 04 24             	mov    %eax,(%esp)
80105088:	e8 6b fb ff ff       	call   80104bf8 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
8010508d:	8b 45 08             	mov    0x8(%ebp),%eax
80105090:	8b 00                	mov    (%eax),%eax
80105092:	85 c0                	test   %eax,%eax
80105094:	75 e2                	jne    80105078 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80105096:	8b 45 08             	mov    0x8(%ebp),%eax
80105099:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010509f:	e8 db f2 ff ff       	call   8010437f <myproc>
801050a4:	8b 50 10             	mov    0x10(%eax),%edx
801050a7:	8b 45 08             	mov    0x8(%ebp),%eax
801050aa:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801050ad:	8b 45 08             	mov    0x8(%ebp),%eax
801050b0:	83 c0 04             	add    $0x4,%eax
801050b3:	89 04 24             	mov    %eax,(%esp)
801050b6:	e8 36 01 00 00       	call   801051f1 <release>
}
801050bb:	c9                   	leave  
801050bc:	c3                   	ret    

801050bd <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801050bd:	55                   	push   %ebp
801050be:	89 e5                	mov    %esp,%ebp
801050c0:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801050c3:	8b 45 08             	mov    0x8(%ebp),%eax
801050c6:	83 c0 04             	add    $0x4,%eax
801050c9:	89 04 24             	mov    %eax,(%esp)
801050cc:	e8 b6 00 00 00       	call   80105187 <acquire>
  lk->locked = 0;
801050d1:	8b 45 08             	mov    0x8(%ebp),%eax
801050d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050da:	8b 45 08             	mov    0x8(%ebp),%eax
801050dd:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801050e4:	8b 45 08             	mov    0x8(%ebp),%eax
801050e7:	89 04 24             	mov    %eax,(%esp)
801050ea:	e8 e0 fb ff ff       	call   80104ccf <wakeup>
  release(&lk->lk);
801050ef:	8b 45 08             	mov    0x8(%ebp),%eax
801050f2:	83 c0 04             	add    $0x4,%eax
801050f5:	89 04 24             	mov    %eax,(%esp)
801050f8:	e8 f4 00 00 00       	call   801051f1 <release>
}
801050fd:	c9                   	leave  
801050fe:	c3                   	ret    

801050ff <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801050ff:	55                   	push   %ebp
80105100:	89 e5                	mov    %esp,%ebp
80105102:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105105:	8b 45 08             	mov    0x8(%ebp),%eax
80105108:	83 c0 04             	add    $0x4,%eax
8010510b:	89 04 24             	mov    %eax,(%esp)
8010510e:	e8 74 00 00 00       	call   80105187 <acquire>
  r = lk->locked;
80105113:	8b 45 08             	mov    0x8(%ebp),%eax
80105116:	8b 00                	mov    (%eax),%eax
80105118:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010511b:	8b 45 08             	mov    0x8(%ebp),%eax
8010511e:	83 c0 04             	add    $0x4,%eax
80105121:	89 04 24             	mov    %eax,(%esp)
80105124:	e8 c8 00 00 00       	call   801051f1 <release>
  return r;
80105129:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010512c:	c9                   	leave  
8010512d:	c3                   	ret    
	...

80105130 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105130:	55                   	push   %ebp
80105131:	89 e5                	mov    %esp,%ebp
80105133:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105136:	9c                   	pushf  
80105137:	58                   	pop    %eax
80105138:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010513b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010513e:	c9                   	leave  
8010513f:	c3                   	ret    

80105140 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105143:	fa                   	cli    
}
80105144:	5d                   	pop    %ebp
80105145:	c3                   	ret    

80105146 <sti>:

static inline void
sti(void)
{
80105146:	55                   	push   %ebp
80105147:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105149:	fb                   	sti    
}
8010514a:	5d                   	pop    %ebp
8010514b:	c3                   	ret    

8010514c <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010514c:	55                   	push   %ebp
8010514d:	89 e5                	mov    %esp,%ebp
8010514f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105152:	8b 55 08             	mov    0x8(%ebp),%edx
80105155:	8b 45 0c             	mov    0xc(%ebp),%eax
80105158:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010515b:	f0 87 02             	lock xchg %eax,(%edx)
8010515e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105161:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105164:	c9                   	leave  
80105165:	c3                   	ret    

80105166 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105166:	55                   	push   %ebp
80105167:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010516f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105172:	8b 45 08             	mov    0x8(%ebp),%eax
80105175:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010517b:	8b 45 08             	mov    0x8(%ebp),%eax
8010517e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105185:	5d                   	pop    %ebp
80105186:	c3                   	ret    

80105187 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105187:	55                   	push   %ebp
80105188:	89 e5                	mov    %esp,%ebp
8010518a:	53                   	push   %ebx
8010518b:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010518e:	e8 53 01 00 00       	call   801052e6 <pushcli>
  if(holding(lk))
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	89 04 24             	mov    %eax,(%esp)
80105199:	e8 17 01 00 00       	call   801052b5 <holding>
8010519e:	85 c0                	test   %eax,%eax
801051a0:	74 0c                	je     801051ae <acquire+0x27>
    panic("acquire");
801051a2:	c7 04 24 17 94 10 80 	movl   $0x80109417,(%esp)
801051a9:	e8 a6 b3 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801051ae:	90                   	nop
801051af:	8b 45 08             	mov    0x8(%ebp),%eax
801051b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051b9:	00 
801051ba:	89 04 24             	mov    %eax,(%esp)
801051bd:	e8 8a ff ff ff       	call   8010514c <xchg>
801051c2:	85 c0                	test   %eax,%eax
801051c4:	75 e9                	jne    801051af <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801051c6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801051cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
801051ce:	e8 28 f1 ff ff       	call   801042fb <mycpu>
801051d3:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	83 c0 0c             	add    $0xc,%eax
801051dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801051e0:	8d 45 08             	lea    0x8(%ebp),%eax
801051e3:	89 04 24             	mov    %eax,(%esp)
801051e6:	e8 53 00 00 00       	call   8010523e <getcallerpcs>
}
801051eb:	83 c4 14             	add    $0x14,%esp
801051ee:	5b                   	pop    %ebx
801051ef:	5d                   	pop    %ebp
801051f0:	c3                   	ret    

801051f1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801051f1:	55                   	push   %ebp
801051f2:	89 e5                	mov    %esp,%ebp
801051f4:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801051f7:	8b 45 08             	mov    0x8(%ebp),%eax
801051fa:	89 04 24             	mov    %eax,(%esp)
801051fd:	e8 b3 00 00 00       	call   801052b5 <holding>
80105202:	85 c0                	test   %eax,%eax
80105204:	75 0c                	jne    80105212 <release+0x21>
    panic("release");
80105206:	c7 04 24 1f 94 10 80 	movl   $0x8010941f,(%esp)
8010520d:	e8 42 b3 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80105212:	8b 45 08             	mov    0x8(%ebp),%eax
80105215:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010521c:	8b 45 08             	mov    0x8(%ebp),%eax
8010521f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105226:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010522b:	8b 45 08             	mov    0x8(%ebp),%eax
8010522e:	8b 55 08             	mov    0x8(%ebp),%edx
80105231:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105237:	e8 f4 00 00 00       	call   80105330 <popcli>
}
8010523c:	c9                   	leave  
8010523d:	c3                   	ret    

8010523e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010523e:	55                   	push   %ebp
8010523f:	89 e5                	mov    %esp,%ebp
80105241:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105244:	8b 45 08             	mov    0x8(%ebp),%eax
80105247:	83 e8 08             	sub    $0x8,%eax
8010524a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010524d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105254:	eb 37                	jmp    8010528d <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105256:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010525a:	74 37                	je     80105293 <getcallerpcs+0x55>
8010525c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105263:	76 2e                	jbe    80105293 <getcallerpcs+0x55>
80105265:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105269:	74 28                	je     80105293 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010526b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010526e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105275:	8b 45 0c             	mov    0xc(%ebp),%eax
80105278:	01 c2                	add    %eax,%edx
8010527a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010527d:	8b 40 04             	mov    0x4(%eax),%eax
80105280:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105282:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105285:	8b 00                	mov    (%eax),%eax
80105287:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010528a:	ff 45 f8             	incl   -0x8(%ebp)
8010528d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105291:	7e c3                	jle    80105256 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105293:	eb 18                	jmp    801052ad <getcallerpcs+0x6f>
    pcs[i] = 0;
80105295:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105298:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010529f:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a2:	01 d0                	add    %edx,%eax
801052a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052aa:	ff 45 f8             	incl   -0x8(%ebp)
801052ad:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052b1:	7e e2                	jle    80105295 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801052b3:	c9                   	leave  
801052b4:	c3                   	ret    

801052b5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052b5:	55                   	push   %ebp
801052b6:	89 e5                	mov    %esp,%ebp
801052b8:	53                   	push   %ebx
801052b9:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801052bc:	8b 45 08             	mov    0x8(%ebp),%eax
801052bf:	8b 00                	mov    (%eax),%eax
801052c1:	85 c0                	test   %eax,%eax
801052c3:	74 16                	je     801052db <holding+0x26>
801052c5:	8b 45 08             	mov    0x8(%ebp),%eax
801052c8:	8b 58 08             	mov    0x8(%eax),%ebx
801052cb:	e8 2b f0 ff ff       	call   801042fb <mycpu>
801052d0:	39 c3                	cmp    %eax,%ebx
801052d2:	75 07                	jne    801052db <holding+0x26>
801052d4:	b8 01 00 00 00       	mov    $0x1,%eax
801052d9:	eb 05                	jmp    801052e0 <holding+0x2b>
801052db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052e0:	83 c4 04             	add    $0x4,%esp
801052e3:	5b                   	pop    %ebx
801052e4:	5d                   	pop    %ebp
801052e5:	c3                   	ret    

801052e6 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052e6:	55                   	push   %ebp
801052e7:	89 e5                	mov    %esp,%ebp
801052e9:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801052ec:	e8 3f fe ff ff       	call   80105130 <readeflags>
801052f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801052f4:	e8 47 fe ff ff       	call   80105140 <cli>
  if(mycpu()->ncli == 0)
801052f9:	e8 fd ef ff ff       	call   801042fb <mycpu>
801052fe:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105304:	85 c0                	test   %eax,%eax
80105306:	75 14                	jne    8010531c <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105308:	e8 ee ef ff ff       	call   801042fb <mycpu>
8010530d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105310:	81 e2 00 02 00 00    	and    $0x200,%edx
80105316:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010531c:	e8 da ef ff ff       	call   801042fb <mycpu>
80105321:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105327:	42                   	inc    %edx
80105328:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010532e:	c9                   	leave  
8010532f:	c3                   	ret    

80105330 <popcli>:

void
popcli(void)
{
80105330:	55                   	push   %ebp
80105331:	89 e5                	mov    %esp,%ebp
80105333:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105336:	e8 f5 fd ff ff       	call   80105130 <readeflags>
8010533b:	25 00 02 00 00       	and    $0x200,%eax
80105340:	85 c0                	test   %eax,%eax
80105342:	74 0c                	je     80105350 <popcli+0x20>
    panic("popcli - interruptible");
80105344:	c7 04 24 27 94 10 80 	movl   $0x80109427,(%esp)
8010534b:	e8 04 b2 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105350:	e8 a6 ef ff ff       	call   801042fb <mycpu>
80105355:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010535b:	4a                   	dec    %edx
8010535c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105362:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105368:	85 c0                	test   %eax,%eax
8010536a:	79 0c                	jns    80105378 <popcli+0x48>
    panic("popcli");
8010536c:	c7 04 24 3e 94 10 80 	movl   $0x8010943e,(%esp)
80105373:	e8 dc b1 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105378:	e8 7e ef ff ff       	call   801042fb <mycpu>
8010537d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105383:	85 c0                	test   %eax,%eax
80105385:	75 14                	jne    8010539b <popcli+0x6b>
80105387:	e8 6f ef ff ff       	call   801042fb <mycpu>
8010538c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105392:	85 c0                	test   %eax,%eax
80105394:	74 05                	je     8010539b <popcli+0x6b>
    sti();
80105396:	e8 ab fd ff ff       	call   80105146 <sti>
}
8010539b:	c9                   	leave  
8010539c:	c3                   	ret    
8010539d:	00 00                	add    %al,(%eax)
	...

801053a0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053a0:	55                   	push   %ebp
801053a1:	89 e5                	mov    %esp,%ebp
801053a3:	57                   	push   %edi
801053a4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053a8:	8b 55 10             	mov    0x10(%ebp),%edx
801053ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ae:	89 cb                	mov    %ecx,%ebx
801053b0:	89 df                	mov    %ebx,%edi
801053b2:	89 d1                	mov    %edx,%ecx
801053b4:	fc                   	cld    
801053b5:	f3 aa                	rep stos %al,%es:(%edi)
801053b7:	89 ca                	mov    %ecx,%edx
801053b9:	89 fb                	mov    %edi,%ebx
801053bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053be:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053c1:	5b                   	pop    %ebx
801053c2:	5f                   	pop    %edi
801053c3:	5d                   	pop    %ebp
801053c4:	c3                   	ret    

801053c5 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053c5:	55                   	push   %ebp
801053c6:	89 e5                	mov    %esp,%ebp
801053c8:	57                   	push   %edi
801053c9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053cd:	8b 55 10             	mov    0x10(%ebp),%edx
801053d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d3:	89 cb                	mov    %ecx,%ebx
801053d5:	89 df                	mov    %ebx,%edi
801053d7:	89 d1                	mov    %edx,%ecx
801053d9:	fc                   	cld    
801053da:	f3 ab                	rep stos %eax,%es:(%edi)
801053dc:	89 ca                	mov    %ecx,%edx
801053de:	89 fb                	mov    %edi,%ebx
801053e0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053e3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053e6:	5b                   	pop    %ebx
801053e7:	5f                   	pop    %edi
801053e8:	5d                   	pop    %ebp
801053e9:	c3                   	ret    

801053ea <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801053ea:	55                   	push   %ebp
801053eb:	89 e5                	mov    %esp,%ebp
801053ed:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801053f0:	8b 45 08             	mov    0x8(%ebp),%eax
801053f3:	83 e0 03             	and    $0x3,%eax
801053f6:	85 c0                	test   %eax,%eax
801053f8:	75 49                	jne    80105443 <memset+0x59>
801053fa:	8b 45 10             	mov    0x10(%ebp),%eax
801053fd:	83 e0 03             	and    $0x3,%eax
80105400:	85 c0                	test   %eax,%eax
80105402:	75 3f                	jne    80105443 <memset+0x59>
    c &= 0xFF;
80105404:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010540b:	8b 45 10             	mov    0x10(%ebp),%eax
8010540e:	c1 e8 02             	shr    $0x2,%eax
80105411:	89 c2                	mov    %eax,%edx
80105413:	8b 45 0c             	mov    0xc(%ebp),%eax
80105416:	c1 e0 18             	shl    $0x18,%eax
80105419:	89 c1                	mov    %eax,%ecx
8010541b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541e:	c1 e0 10             	shl    $0x10,%eax
80105421:	09 c1                	or     %eax,%ecx
80105423:	8b 45 0c             	mov    0xc(%ebp),%eax
80105426:	c1 e0 08             	shl    $0x8,%eax
80105429:	09 c8                	or     %ecx,%eax
8010542b:	0b 45 0c             	or     0xc(%ebp),%eax
8010542e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105432:	89 44 24 04          	mov    %eax,0x4(%esp)
80105436:	8b 45 08             	mov    0x8(%ebp),%eax
80105439:	89 04 24             	mov    %eax,(%esp)
8010543c:	e8 84 ff ff ff       	call   801053c5 <stosl>
80105441:	eb 19                	jmp    8010545c <memset+0x72>
  } else
    stosb(dst, c, n);
80105443:	8b 45 10             	mov    0x10(%ebp),%eax
80105446:	89 44 24 08          	mov    %eax,0x8(%esp)
8010544a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010544d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105451:	8b 45 08             	mov    0x8(%ebp),%eax
80105454:	89 04 24             	mov    %eax,(%esp)
80105457:	e8 44 ff ff ff       	call   801053a0 <stosb>
  return dst;
8010545c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010545f:	c9                   	leave  
80105460:	c3                   	ret    

80105461 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105461:	55                   	push   %ebp
80105462:	89 e5                	mov    %esp,%ebp
80105464:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105467:	8b 45 08             	mov    0x8(%ebp),%eax
8010546a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010546d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105470:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105473:	eb 2a                	jmp    8010549f <memcmp+0x3e>
    if(*s1 != *s2)
80105475:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105478:	8a 10                	mov    (%eax),%dl
8010547a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010547d:	8a 00                	mov    (%eax),%al
8010547f:	38 c2                	cmp    %al,%dl
80105481:	74 16                	je     80105499 <memcmp+0x38>
      return *s1 - *s2;
80105483:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105486:	8a 00                	mov    (%eax),%al
80105488:	0f b6 d0             	movzbl %al,%edx
8010548b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010548e:	8a 00                	mov    (%eax),%al
80105490:	0f b6 c0             	movzbl %al,%eax
80105493:	29 c2                	sub    %eax,%edx
80105495:	89 d0                	mov    %edx,%eax
80105497:	eb 18                	jmp    801054b1 <memcmp+0x50>
    s1++, s2++;
80105499:	ff 45 fc             	incl   -0x4(%ebp)
8010549c:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010549f:	8b 45 10             	mov    0x10(%ebp),%eax
801054a2:	8d 50 ff             	lea    -0x1(%eax),%edx
801054a5:	89 55 10             	mov    %edx,0x10(%ebp)
801054a8:	85 c0                	test   %eax,%eax
801054aa:	75 c9                	jne    80105475 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054b1:	c9                   	leave  
801054b2:	c3                   	ret    

801054b3 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054b3:	55                   	push   %ebp
801054b4:	89 e5                	mov    %esp,%ebp
801054b6:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054bf:	8b 45 08             	mov    0x8(%ebp),%eax
801054c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054c8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054cb:	73 3a                	jae    80105507 <memmove+0x54>
801054cd:	8b 45 10             	mov    0x10(%ebp),%eax
801054d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054d3:	01 d0                	add    %edx,%eax
801054d5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054d8:	76 2d                	jbe    80105507 <memmove+0x54>
    s += n;
801054da:	8b 45 10             	mov    0x10(%ebp),%eax
801054dd:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054e0:	8b 45 10             	mov    0x10(%ebp),%eax
801054e3:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054e6:	eb 10                	jmp    801054f8 <memmove+0x45>
      *--d = *--s;
801054e8:	ff 4d f8             	decl   -0x8(%ebp)
801054eb:	ff 4d fc             	decl   -0x4(%ebp)
801054ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f1:	8a 10                	mov    (%eax),%dl
801054f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054f6:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801054f8:	8b 45 10             	mov    0x10(%ebp),%eax
801054fb:	8d 50 ff             	lea    -0x1(%eax),%edx
801054fe:	89 55 10             	mov    %edx,0x10(%ebp)
80105501:	85 c0                	test   %eax,%eax
80105503:	75 e3                	jne    801054e8 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105505:	eb 25                	jmp    8010552c <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105507:	eb 16                	jmp    8010551f <memmove+0x6c>
      *d++ = *s++;
80105509:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010550c:	8d 50 01             	lea    0x1(%eax),%edx
8010550f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105512:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105515:	8d 4a 01             	lea    0x1(%edx),%ecx
80105518:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010551b:	8a 12                	mov    (%edx),%dl
8010551d:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010551f:	8b 45 10             	mov    0x10(%ebp),%eax
80105522:	8d 50 ff             	lea    -0x1(%eax),%edx
80105525:	89 55 10             	mov    %edx,0x10(%ebp)
80105528:	85 c0                	test   %eax,%eax
8010552a:	75 dd                	jne    80105509 <memmove+0x56>
      *d++ = *s++;

  return dst;
8010552c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010552f:	c9                   	leave  
80105530:	c3                   	ret    

80105531 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
80105534:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105537:	8b 45 10             	mov    0x10(%ebp),%eax
8010553a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010553e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105541:	89 44 24 04          	mov    %eax,0x4(%esp)
80105545:	8b 45 08             	mov    0x8(%ebp),%eax
80105548:	89 04 24             	mov    %eax,(%esp)
8010554b:	e8 63 ff ff ff       	call   801054b3 <memmove>
}
80105550:	c9                   	leave  
80105551:	c3                   	ret    

80105552 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105552:	55                   	push   %ebp
80105553:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105555:	eb 09                	jmp    80105560 <strncmp+0xe>
    n--, p++, q++;
80105557:	ff 4d 10             	decl   0x10(%ebp)
8010555a:	ff 45 08             	incl   0x8(%ebp)
8010555d:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105560:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105564:	74 17                	je     8010557d <strncmp+0x2b>
80105566:	8b 45 08             	mov    0x8(%ebp),%eax
80105569:	8a 00                	mov    (%eax),%al
8010556b:	84 c0                	test   %al,%al
8010556d:	74 0e                	je     8010557d <strncmp+0x2b>
8010556f:	8b 45 08             	mov    0x8(%ebp),%eax
80105572:	8a 10                	mov    (%eax),%dl
80105574:	8b 45 0c             	mov    0xc(%ebp),%eax
80105577:	8a 00                	mov    (%eax),%al
80105579:	38 c2                	cmp    %al,%dl
8010557b:	74 da                	je     80105557 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010557d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105581:	75 07                	jne    8010558a <strncmp+0x38>
    return 0;
80105583:	b8 00 00 00 00       	mov    $0x0,%eax
80105588:	eb 14                	jmp    8010559e <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010558a:	8b 45 08             	mov    0x8(%ebp),%eax
8010558d:	8a 00                	mov    (%eax),%al
8010558f:	0f b6 d0             	movzbl %al,%edx
80105592:	8b 45 0c             	mov    0xc(%ebp),%eax
80105595:	8a 00                	mov    (%eax),%al
80105597:	0f b6 c0             	movzbl %al,%eax
8010559a:	29 c2                	sub    %eax,%edx
8010559c:	89 d0                	mov    %edx,%eax
}
8010559e:	5d                   	pop    %ebp
8010559f:	c3                   	ret    

801055a0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055a0:	55                   	push   %ebp
801055a1:	89 e5                	mov    %esp,%ebp
801055a3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801055a6:	8b 45 08             	mov    0x8(%ebp),%eax
801055a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055ac:	90                   	nop
801055ad:	8b 45 10             	mov    0x10(%ebp),%eax
801055b0:	8d 50 ff             	lea    -0x1(%eax),%edx
801055b3:	89 55 10             	mov    %edx,0x10(%ebp)
801055b6:	85 c0                	test   %eax,%eax
801055b8:	7e 1c                	jle    801055d6 <strncpy+0x36>
801055ba:	8b 45 08             	mov    0x8(%ebp),%eax
801055bd:	8d 50 01             	lea    0x1(%eax),%edx
801055c0:	89 55 08             	mov    %edx,0x8(%ebp)
801055c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801055c6:	8d 4a 01             	lea    0x1(%edx),%ecx
801055c9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055cc:	8a 12                	mov    (%edx),%dl
801055ce:	88 10                	mov    %dl,(%eax)
801055d0:	8a 00                	mov    (%eax),%al
801055d2:	84 c0                	test   %al,%al
801055d4:	75 d7                	jne    801055ad <strncpy+0xd>
    ;
  while(n-- > 0)
801055d6:	eb 0c                	jmp    801055e4 <strncpy+0x44>
    *s++ = 0;
801055d8:	8b 45 08             	mov    0x8(%ebp),%eax
801055db:	8d 50 01             	lea    0x1(%eax),%edx
801055de:	89 55 08             	mov    %edx,0x8(%ebp)
801055e1:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801055e4:	8b 45 10             	mov    0x10(%ebp),%eax
801055e7:	8d 50 ff             	lea    -0x1(%eax),%edx
801055ea:	89 55 10             	mov    %edx,0x10(%ebp)
801055ed:	85 c0                	test   %eax,%eax
801055ef:	7f e7                	jg     801055d8 <strncpy+0x38>
    *s++ = 0;
  return os;
801055f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055f4:	c9                   	leave  
801055f5:	c3                   	ret    

801055f6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055f6:	55                   	push   %ebp
801055f7:	89 e5                	mov    %esp,%ebp
801055f9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801055fc:	8b 45 08             	mov    0x8(%ebp),%eax
801055ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105602:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105606:	7f 05                	jg     8010560d <safestrcpy+0x17>
    return os;
80105608:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560b:	eb 2e                	jmp    8010563b <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
8010560d:	ff 4d 10             	decl   0x10(%ebp)
80105610:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105614:	7e 1c                	jle    80105632 <safestrcpy+0x3c>
80105616:	8b 45 08             	mov    0x8(%ebp),%eax
80105619:	8d 50 01             	lea    0x1(%eax),%edx
8010561c:	89 55 08             	mov    %edx,0x8(%ebp)
8010561f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105622:	8d 4a 01             	lea    0x1(%edx),%ecx
80105625:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105628:	8a 12                	mov    (%edx),%dl
8010562a:	88 10                	mov    %dl,(%eax)
8010562c:	8a 00                	mov    (%eax),%al
8010562e:	84 c0                	test   %al,%al
80105630:	75 db                	jne    8010560d <safestrcpy+0x17>
    ;
  *s = 0;
80105632:	8b 45 08             	mov    0x8(%ebp),%eax
80105635:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105638:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010563b:	c9                   	leave  
8010563c:	c3                   	ret    

8010563d <strlen>:

int
strlen(const char *s)
{
8010563d:	55                   	push   %ebp
8010563e:	89 e5                	mov    %esp,%ebp
80105640:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105643:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010564a:	eb 03                	jmp    8010564f <strlen+0x12>
8010564c:	ff 45 fc             	incl   -0x4(%ebp)
8010564f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105652:	8b 45 08             	mov    0x8(%ebp),%eax
80105655:	01 d0                	add    %edx,%eax
80105657:	8a 00                	mov    (%eax),%al
80105659:	84 c0                	test   %al,%al
8010565b:	75 ef                	jne    8010564c <strlen+0xf>
    ;
  return n;
8010565d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105660:	c9                   	leave  
80105661:	c3                   	ret    
	...

80105664 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105664:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105668:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010566c:	55                   	push   %ebp
  pushl %ebx
8010566d:	53                   	push   %ebx
  pushl %esi
8010566e:	56                   	push   %esi
  pushl %edi
8010566f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105670:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105672:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105674:	5f                   	pop    %edi
  popl %esi
80105675:	5e                   	pop    %esi
  popl %ebx
80105676:	5b                   	pop    %ebx
  popl %ebp
80105677:	5d                   	pop    %ebp
  ret
80105678:	c3                   	ret    
80105679:	00 00                	add    %al,(%eax)
	...

8010567c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010567c:	55                   	push   %ebp
8010567d:	89 e5                	mov    %esp,%ebp
8010567f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105682:	e8 f8 ec ff ff       	call   8010437f <myproc>
80105687:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010568a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568d:	8b 00                	mov    (%eax),%eax
8010568f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105692:	76 0f                	jbe    801056a3 <fetchint+0x27>
80105694:	8b 45 08             	mov    0x8(%ebp),%eax
80105697:	8d 50 04             	lea    0x4(%eax),%edx
8010569a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569d:	8b 00                	mov    (%eax),%eax
8010569f:	39 c2                	cmp    %eax,%edx
801056a1:	76 07                	jbe    801056aa <fetchint+0x2e>
    return -1;
801056a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a8:	eb 0f                	jmp    801056b9 <fetchint+0x3d>
  *ip = *(int*)(addr);
801056aa:	8b 45 08             	mov    0x8(%ebp),%eax
801056ad:	8b 10                	mov    (%eax),%edx
801056af:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b2:	89 10                	mov    %edx,(%eax)
  return 0;
801056b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056b9:	c9                   	leave  
801056ba:	c3                   	ret    

801056bb <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801056bb:	55                   	push   %ebp
801056bc:	89 e5                	mov    %esp,%ebp
801056be:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801056c1:	e8 b9 ec ff ff       	call   8010437f <myproc>
801056c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801056c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056cc:	8b 00                	mov    (%eax),%eax
801056ce:	3b 45 08             	cmp    0x8(%ebp),%eax
801056d1:	77 07                	ja     801056da <fetchstr+0x1f>
    return -1;
801056d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d8:	eb 41                	jmp    8010571b <fetchstr+0x60>
  *pp = (char*)addr;
801056da:	8b 55 08             	mov    0x8(%ebp),%edx
801056dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e0:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801056e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e5:	8b 00                	mov    (%eax),%eax
801056e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801056ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ed:	8b 00                	mov    (%eax),%eax
801056ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056f2:	eb 1a                	jmp    8010570e <fetchstr+0x53>
    if(*s == 0)
801056f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f7:	8a 00                	mov    (%eax),%al
801056f9:	84 c0                	test   %al,%al
801056fb:	75 0e                	jne    8010570b <fetchstr+0x50>
      return s - *pp;
801056fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105700:	8b 45 0c             	mov    0xc(%ebp),%eax
80105703:	8b 00                	mov    (%eax),%eax
80105705:	29 c2                	sub    %eax,%edx
80105707:	89 d0                	mov    %edx,%eax
80105709:	eb 10                	jmp    8010571b <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
8010570b:	ff 45 f4             	incl   -0xc(%ebp)
8010570e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105711:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105714:	72 de                	jb     801056f4 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010571b:	c9                   	leave  
8010571c:	c3                   	ret    

8010571d <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010571d:	55                   	push   %ebp
8010571e:	89 e5                	mov    %esp,%ebp
80105720:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105723:	e8 57 ec ff ff       	call   8010437f <myproc>
80105728:	8b 40 18             	mov    0x18(%eax),%eax
8010572b:	8b 50 44             	mov    0x44(%eax),%edx
8010572e:	8b 45 08             	mov    0x8(%ebp),%eax
80105731:	c1 e0 02             	shl    $0x2,%eax
80105734:	01 d0                	add    %edx,%eax
80105736:	8d 50 04             	lea    0x4(%eax),%edx
80105739:	8b 45 0c             	mov    0xc(%ebp),%eax
8010573c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105740:	89 14 24             	mov    %edx,(%esp)
80105743:	e8 34 ff ff ff       	call   8010567c <fetchint>
}
80105748:	c9                   	leave  
80105749:	c3                   	ret    

8010574a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010574a:	55                   	push   %ebp
8010574b:	89 e5                	mov    %esp,%ebp
8010574d:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105750:	e8 2a ec ff ff       	call   8010437f <myproc>
80105755:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105758:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010575b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010575f:	8b 45 08             	mov    0x8(%ebp),%eax
80105762:	89 04 24             	mov    %eax,(%esp)
80105765:	e8 b3 ff ff ff       	call   8010571d <argint>
8010576a:	85 c0                	test   %eax,%eax
8010576c:	79 07                	jns    80105775 <argptr+0x2b>
    return -1;
8010576e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105773:	eb 3d                	jmp    801057b2 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105775:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105779:	78 21                	js     8010579c <argptr+0x52>
8010577b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577e:	89 c2                	mov    %eax,%edx
80105780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105783:	8b 00                	mov    (%eax),%eax
80105785:	39 c2                	cmp    %eax,%edx
80105787:	73 13                	jae    8010579c <argptr+0x52>
80105789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578c:	89 c2                	mov    %eax,%edx
8010578e:	8b 45 10             	mov    0x10(%ebp),%eax
80105791:	01 c2                	add    %eax,%edx
80105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105796:	8b 00                	mov    (%eax),%eax
80105798:	39 c2                	cmp    %eax,%edx
8010579a:	76 07                	jbe    801057a3 <argptr+0x59>
    return -1;
8010579c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a1:	eb 0f                	jmp    801057b2 <argptr+0x68>
  *pp = (char*)i;
801057a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a6:	89 c2                	mov    %eax,%edx
801057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ab:	89 10                	mov    %edx,(%eax)
  return 0;
801057ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057b2:	c9                   	leave  
801057b3:	c3                   	ret    

801057b4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057b4:	55                   	push   %ebp
801057b5:	89 e5                	mov    %esp,%ebp
801057b7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c1:	8b 45 08             	mov    0x8(%ebp),%eax
801057c4:	89 04 24             	mov    %eax,(%esp)
801057c7:	e8 51 ff ff ff       	call   8010571d <argint>
801057cc:	85 c0                	test   %eax,%eax
801057ce:	79 07                	jns    801057d7 <argstr+0x23>
    return -1;
801057d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d5:	eb 12                	jmp    801057e9 <argstr+0x35>
  return fetchstr(addr, pp);
801057d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057da:	8b 55 0c             	mov    0xc(%ebp),%edx
801057dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801057e1:	89 04 24             	mov    %eax,(%esp)
801057e4:	e8 d2 fe ff ff       	call   801056bb <fetchstr>
}
801057e9:	c9                   	leave  
801057ea:	c3                   	ret    

801057eb <syscall>:
[SYS_reduce_curr_mem] sys_reduce_curr_mem,
};

void
syscall(void)
{
801057eb:	55                   	push   %ebp
801057ec:	89 e5                	mov    %esp,%ebp
801057ee:	53                   	push   %ebx
801057ef:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801057f2:	e8 88 eb ff ff       	call   8010437f <myproc>
801057f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801057fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fd:	8b 40 18             	mov    0x18(%eax),%eax
80105800:	8b 40 1c             	mov    0x1c(%eax),%eax
80105803:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105806:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010580a:	7e 2d                	jle    80105839 <syscall+0x4e>
8010580c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580f:	83 f8 2a             	cmp    $0x2a,%eax
80105812:	77 25                	ja     80105839 <syscall+0x4e>
80105814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105817:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010581e:	85 c0                	test   %eax,%eax
80105820:	74 17                	je     80105839 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105825:	8b 58 18             	mov    0x18(%eax),%ebx
80105828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582b:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105832:	ff d0                	call   *%eax
80105834:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105837:	eb 34                	jmp    8010586d <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583c:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010583f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105842:	8b 40 10             	mov    0x10(%eax),%eax
80105845:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105848:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010584c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105850:	89 44 24 04          	mov    %eax,0x4(%esp)
80105854:	c7 04 24 45 94 10 80 	movl   $0x80109445,(%esp)
8010585b:	e8 61 ab ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105863:	8b 40 18             	mov    0x18(%eax),%eax
80105866:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010586d:	83 c4 24             	add    $0x24,%esp
80105870:	5b                   	pop    %ebx
80105871:	5d                   	pop    %ebp
80105872:	c3                   	ret    
	...

80105874 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105874:	55                   	push   %ebp
80105875:	89 e5                	mov    %esp,%ebp
80105877:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010587a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010587d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105881:	8b 45 08             	mov    0x8(%ebp),%eax
80105884:	89 04 24             	mov    %eax,(%esp)
80105887:	e8 91 fe ff ff       	call   8010571d <argint>
8010588c:	85 c0                	test   %eax,%eax
8010588e:	79 07                	jns    80105897 <argfd+0x23>
    return -1;
80105890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105895:	eb 4f                	jmp    801058e6 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589a:	85 c0                	test   %eax,%eax
8010589c:	78 20                	js     801058be <argfd+0x4a>
8010589e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a1:	83 f8 0f             	cmp    $0xf,%eax
801058a4:	7f 18                	jg     801058be <argfd+0x4a>
801058a6:	e8 d4 ea ff ff       	call   8010437f <myproc>
801058ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ae:	83 c2 08             	add    $0x8,%edx
801058b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058bc:	75 07                	jne    801058c5 <argfd+0x51>
    return -1;
801058be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c3:	eb 21                	jmp    801058e6 <argfd+0x72>
  if(pfd)
801058c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058c9:	74 08                	je     801058d3 <argfd+0x5f>
    *pfd = fd;
801058cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d1:	89 10                	mov    %edx,(%eax)
  if(pf)
801058d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058d7:	74 08                	je     801058e1 <argfd+0x6d>
    *pf = f;
801058d9:	8b 45 10             	mov    0x10(%ebp),%eax
801058dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058df:	89 10                	mov    %edx,(%eax)
  return 0;
801058e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058e6:	c9                   	leave  
801058e7:	c3                   	ret    

801058e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
801058eb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801058ee:	e8 8c ea ff ff       	call   8010437f <myproc>
801058f3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801058f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058fd:	eb 29                	jmp    80105928 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
801058ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105902:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105905:	83 c2 08             	add    $0x8,%edx
80105908:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010590c:	85 c0                	test   %eax,%eax
8010590e:	75 15                	jne    80105925 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105913:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105916:	8d 4a 08             	lea    0x8(%edx),%ecx
80105919:	8b 55 08             	mov    0x8(%ebp),%edx
8010591c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105923:	eb 0e                	jmp    80105933 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105925:	ff 45 f4             	incl   -0xc(%ebp)
80105928:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010592c:	7e d1                	jle    801058ff <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010592e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105933:	c9                   	leave  
80105934:	c3                   	ret    

80105935 <sys_dup>:

int
sys_dup(void)
{
80105935:	55                   	push   %ebp
80105936:	89 e5                	mov    %esp,%ebp
80105938:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010593b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010593e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105942:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105949:	00 
8010594a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105951:	e8 1e ff ff ff       	call   80105874 <argfd>
80105956:	85 c0                	test   %eax,%eax
80105958:	79 07                	jns    80105961 <sys_dup+0x2c>
    return -1;
8010595a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595f:	eb 29                	jmp    8010598a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105964:	89 04 24             	mov    %eax,(%esp)
80105967:	e8 7c ff ff ff       	call   801058e8 <fdalloc>
8010596c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010596f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105973:	79 07                	jns    8010597c <sys_dup+0x47>
    return -1;
80105975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597a:	eb 0e                	jmp    8010598a <sys_dup+0x55>
  filedup(f);
8010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597f:	89 04 24             	mov    %eax,(%esp)
80105982:	e8 db b7 ff ff       	call   80101162 <filedup>
  return fd;
80105987:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010598a:	c9                   	leave  
8010598b:	c3                   	ret    

8010598c <sys_read>:

int
sys_read(void)
{
8010598c:	55                   	push   %ebp
8010598d:	89 e5                	mov    %esp,%ebp
8010598f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105992:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105995:	89 44 24 08          	mov    %eax,0x8(%esp)
80105999:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059a0:	00 
801059a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059a8:	e8 c7 fe ff ff       	call   80105874 <argfd>
801059ad:	85 c0                	test   %eax,%eax
801059af:	78 35                	js     801059e6 <sys_read+0x5a>
801059b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059b8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059bf:	e8 59 fd ff ff       	call   8010571d <argint>
801059c4:	85 c0                	test   %eax,%eax
801059c6:	78 1e                	js     801059e6 <sys_read+0x5a>
801059c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059dd:	e8 68 fd ff ff       	call   8010574a <argptr>
801059e2:	85 c0                	test   %eax,%eax
801059e4:	79 07                	jns    801059ed <sys_read+0x61>
    return -1;
801059e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059eb:	eb 19                	jmp    80105a06 <sys_read+0x7a>
  return fileread(f, p, n);
801059ed:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801059fe:	89 04 24             	mov    %eax,(%esp)
80105a01:	e8 bd b8 ff ff       	call   801012c3 <fileread>
}
80105a06:	c9                   	leave  
80105a07:	c3                   	ret    

80105a08 <sys_write>:

int
sys_write(void)
{
80105a08:	55                   	push   %ebp
80105a09:	89 e5                	mov    %esp,%ebp
80105a0b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a11:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a1c:	00 
80105a1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a24:	e8 4b fe ff ff       	call   80105874 <argfd>
80105a29:	85 c0                	test   %eax,%eax
80105a2b:	78 35                	js     80105a62 <sys_write+0x5a>
80105a2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a34:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a3b:	e8 dd fc ff ff       	call   8010571d <argint>
80105a40:	85 c0                	test   %eax,%eax
80105a42:	78 1e                	js     80105a62 <sys_write+0x5a>
80105a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a59:	e8 ec fc ff ff       	call   8010574a <argptr>
80105a5e:	85 c0                	test   %eax,%eax
80105a60:	79 07                	jns    80105a69 <sys_write+0x61>
    return -1;
80105a62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a67:	eb 19                	jmp    80105a82 <sys_write+0x7a>
  return filewrite(f, p, n);
80105a69:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a76:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a7a:	89 04 24             	mov    %eax,(%esp)
80105a7d:	e8 fc b8 ff ff       	call   8010137e <filewrite>
}
80105a82:	c9                   	leave  
80105a83:	c3                   	ret    

80105a84 <sys_close>:

int
sys_close(void)
{
80105a84:	55                   	push   %ebp
80105a85:	89 e5                	mov    %esp,%ebp
80105a87:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105a8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a91:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a9f:	e8 d0 fd ff ff       	call   80105874 <argfd>
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	79 07                	jns    80105aaf <sys_close+0x2b>
    return -1;
80105aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aad:	eb 23                	jmp    80105ad2 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105aaf:	e8 cb e8 ff ff       	call   8010437f <myproc>
80105ab4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ab7:	83 c2 08             	add    $0x8,%edx
80105aba:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ac1:	00 
  fileclose(f);
80105ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac5:	89 04 24             	mov    %eax,(%esp)
80105ac8:	e8 dd b6 ff ff       	call   801011aa <fileclose>
  return 0;
80105acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ad2:	c9                   	leave  
80105ad3:	c3                   	ret    

80105ad4 <sys_fstat>:

int
sys_fstat(void)
{
80105ad4:	55                   	push   %ebp
80105ad5:	89 e5                	mov    %esp,%ebp
80105ad7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105ada:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105add:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ae1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ae8:	00 
80105ae9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105af0:	e8 7f fd ff ff       	call   80105874 <argfd>
80105af5:	85 c0                	test   %eax,%eax
80105af7:	78 1f                	js     80105b18 <sys_fstat+0x44>
80105af9:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b00:	00 
80105b01:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b04:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b0f:	e8 36 fc ff ff       	call   8010574a <argptr>
80105b14:	85 c0                	test   %eax,%eax
80105b16:	79 07                	jns    80105b1f <sys_fstat+0x4b>
    return -1;
80105b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1d:	eb 12                	jmp    80105b31 <sys_fstat+0x5d>
  return filestat(f, st);
80105b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b25:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 43 b7 ff ff       	call   80101274 <filestat>
}
80105b31:	c9                   	leave  
80105b32:	c3                   	ret    

80105b33 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b33:	55                   	push   %ebp
80105b34:	89 e5                	mov    %esp,%ebp
80105b36:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b39:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b47:	e8 68 fc ff ff       	call   801057b4 <argstr>
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	78 17                	js     80105b67 <sys_link+0x34>
80105b50:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b53:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b5e:	e8 51 fc ff ff       	call   801057b4 <argstr>
80105b63:	85 c0                	test   %eax,%eax
80105b65:	79 0a                	jns    80105b71 <sys_link+0x3e>
    return -1;
80105b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6c:	e9 3d 01 00 00       	jmp    80105cae <sys_link+0x17b>

  begin_op();
80105b71:	e8 09 db ff ff       	call   8010367f <begin_op>
  if((ip = namei(old)) == 0){
80105b76:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b79:	89 04 24             	mov    %eax,(%esp)
80105b7c:	e8 66 ca ff ff       	call   801025e7 <namei>
80105b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b88:	75 0f                	jne    80105b99 <sys_link+0x66>
    end_op();
80105b8a:	e8 72 db ff ff       	call   80103701 <end_op>
    return -1;
80105b8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b94:	e9 15 01 00 00       	jmp    80105cae <sys_link+0x17b>
  }

  ilock(ip);
80105b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9c:	89 04 24             	mov    %eax,(%esp)
80105b9f:	e8 1e bf ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba7:	8b 40 50             	mov    0x50(%eax),%eax
80105baa:	66 83 f8 01          	cmp    $0x1,%ax
80105bae:	75 1a                	jne    80105bca <sys_link+0x97>
    iunlockput(ip);
80105bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb3:	89 04 24             	mov    %eax,(%esp)
80105bb6:	e8 06 c1 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105bbb:	e8 41 db ff ff       	call   80103701 <end_op>
    return -1;
80105bc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc5:	e9 e4 00 00 00       	jmp    80105cae <sys_link+0x17b>
  }

  ip->nlink++;
80105bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcd:	66 8b 40 56          	mov    0x56(%eax),%ax
80105bd1:	40                   	inc    %eax
80105bd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bd5:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdc:	89 04 24             	mov    %eax,(%esp)
80105bdf:	e8 1b bd ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be7:	89 04 24             	mov    %eax,(%esp)
80105bea:	e8 dd bf ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105bef:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105bf2:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105bf5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bf9:	89 04 24             	mov    %eax,(%esp)
80105bfc:	e8 08 ca ff ff       	call   80102609 <nameiparent>
80105c01:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c08:	75 02                	jne    80105c0c <sys_link+0xd9>
    goto bad;
80105c0a:	eb 68                	jmp    80105c74 <sys_link+0x141>
  ilock(dp);
80105c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0f:	89 04 24             	mov    %eax,(%esp)
80105c12:	e8 ab be ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1a:	8b 10                	mov    (%eax),%edx
80105c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1f:	8b 00                	mov    (%eax),%eax
80105c21:	39 c2                	cmp    %eax,%edx
80105c23:	75 20                	jne    80105c45 <sys_link+0x112>
80105c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c28:	8b 40 04             	mov    0x4(%eax),%eax
80105c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c2f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c32:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c39:	89 04 24             	mov    %eax,(%esp)
80105c3c:	e8 f3 c6 ff ff       	call   80102334 <dirlink>
80105c41:	85 c0                	test   %eax,%eax
80105c43:	79 0d                	jns    80105c52 <sys_link+0x11f>
    iunlockput(dp);
80105c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c48:	89 04 24             	mov    %eax,(%esp)
80105c4b:	e8 71 c0 ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105c50:	eb 22                	jmp    80105c74 <sys_link+0x141>
  }
  iunlockput(dp);
80105c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c55:	89 04 24             	mov    %eax,(%esp)
80105c58:	e8 64 c0 ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c60:	89 04 24             	mov    %eax,(%esp)
80105c63:	e8 a8 bf ff ff       	call   80101c10 <iput>

  end_op();
80105c68:	e8 94 da ff ff       	call   80103701 <end_op>

  return 0;
80105c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c72:	eb 3a                	jmp    80105cae <sys_link+0x17b>

bad:
  ilock(ip);
80105c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c77:	89 04 24             	mov    %eax,(%esp)
80105c7a:	e8 43 be ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c82:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c86:	48                   	dec    %eax
80105c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c8a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c91:	89 04 24             	mov    %eax,(%esp)
80105c94:	e8 66 bc ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9c:	89 04 24             	mov    %eax,(%esp)
80105c9f:	e8 1d c0 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105ca4:	e8 58 da ff ff       	call   80103701 <end_op>
  return -1;
80105ca9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cae:	c9                   	leave  
80105caf:	c3                   	ret    

80105cb0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105cb0:	55                   	push   %ebp
80105cb1:	89 e5                	mov    %esp,%ebp
80105cb3:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cb6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105cbd:	eb 4a                	jmp    80105d09 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105cc9:	00 
80105cca:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd8:	89 04 24             	mov    %eax,(%esp)
80105cdb:	e8 79 c2 ff ff       	call   80101f59 <readi>
80105ce0:	83 f8 10             	cmp    $0x10,%eax
80105ce3:	74 0c                	je     80105cf1 <isdirempty+0x41>
      panic("isdirempty: readi");
80105ce5:	c7 04 24 61 94 10 80 	movl   $0x80109461,(%esp)
80105cec:	e8 63 a8 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105cf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cf4:	66 85 c0             	test   %ax,%ax
80105cf7:	74 07                	je     80105d00 <isdirempty+0x50>
      return 0;
80105cf9:	b8 00 00 00 00       	mov    $0x0,%eax
80105cfe:	eb 1b                	jmp    80105d1b <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d03:	83 c0 10             	add    $0x10,%eax
80105d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80105d0f:	8b 40 58             	mov    0x58(%eax),%eax
80105d12:	39 c2                	cmp    %eax,%edx
80105d14:	72 a9                	jb     80105cbf <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d16:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d1b:	c9                   	leave  
80105d1c:	c3                   	ret    

80105d1d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d1d:	55                   	push   %ebp
80105d1e:	89 e5                	mov    %esp,%ebp
80105d20:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d23:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d26:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d31:	e8 7e fa ff ff       	call   801057b4 <argstr>
80105d36:	85 c0                	test   %eax,%eax
80105d38:	79 0a                	jns    80105d44 <sys_unlink+0x27>
    return -1;
80105d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3f:	e9 a9 01 00 00       	jmp    80105eed <sys_unlink+0x1d0>

  begin_op();
80105d44:	e8 36 d9 ff ff       	call   8010367f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d49:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d4c:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d4f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d53:	89 04 24             	mov    %eax,(%esp)
80105d56:	e8 ae c8 ff ff       	call   80102609 <nameiparent>
80105d5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d62:	75 0f                	jne    80105d73 <sys_unlink+0x56>
    end_op();
80105d64:	e8 98 d9 ff ff       	call   80103701 <end_op>
    return -1;
80105d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6e:	e9 7a 01 00 00       	jmp    80105eed <sys_unlink+0x1d0>
  }

  ilock(dp);
80105d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d76:	89 04 24             	mov    %eax,(%esp)
80105d79:	e8 44 bd ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d7e:	c7 44 24 04 73 94 10 	movl   $0x80109473,0x4(%esp)
80105d85:	80 
80105d86:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d89:	89 04 24             	mov    %eax,(%esp)
80105d8c:	e8 bb c4 ff ff       	call   8010224c <namecmp>
80105d91:	85 c0                	test   %eax,%eax
80105d93:	0f 84 3f 01 00 00    	je     80105ed8 <sys_unlink+0x1bb>
80105d99:	c7 44 24 04 75 94 10 	movl   $0x80109475,0x4(%esp)
80105da0:	80 
80105da1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105da4:	89 04 24             	mov    %eax,(%esp)
80105da7:	e8 a0 c4 ff ff       	call   8010224c <namecmp>
80105dac:	85 c0                	test   %eax,%eax
80105dae:	0f 84 24 01 00 00    	je     80105ed8 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105db4:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105db7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dbb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105dbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc5:	89 04 24             	mov    %eax,(%esp)
80105dc8:	e8 a1 c4 ff ff       	call   8010226e <dirlookup>
80105dcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dd4:	75 05                	jne    80105ddb <sys_unlink+0xbe>
    goto bad;
80105dd6:	e9 fd 00 00 00       	jmp    80105ed8 <sys_unlink+0x1bb>
  ilock(ip);
80105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dde:	89 04 24             	mov    %eax,(%esp)
80105de1:	e8 dc bc ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
80105de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ded:	66 85 c0             	test   %ax,%ax
80105df0:	7f 0c                	jg     80105dfe <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105df2:	c7 04 24 78 94 10 80 	movl   $0x80109478,(%esp)
80105df9:	e8 56 a7 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e01:	8b 40 50             	mov    0x50(%eax),%eax
80105e04:	66 83 f8 01          	cmp    $0x1,%ax
80105e08:	75 1f                	jne    80105e29 <sys_unlink+0x10c>
80105e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0d:	89 04 24             	mov    %eax,(%esp)
80105e10:	e8 9b fe ff ff       	call   80105cb0 <isdirempty>
80105e15:	85 c0                	test   %eax,%eax
80105e17:	75 10                	jne    80105e29 <sys_unlink+0x10c>
    iunlockput(ip);
80105e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1c:	89 04 24             	mov    %eax,(%esp)
80105e1f:	e8 9d be ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105e24:	e9 af 00 00 00       	jmp    80105ed8 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105e29:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e30:	00 
80105e31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e38:	00 
80105e39:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e3c:	89 04 24             	mov    %eax,(%esp)
80105e3f:	e8 a6 f5 ff ff       	call   801053ea <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e44:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e47:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e4e:	00 
80105e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e53:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e56:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5d:	89 04 24             	mov    %eax,(%esp)
80105e60:	e8 58 c2 ff ff       	call   801020bd <writei>
80105e65:	83 f8 10             	cmp    $0x10,%eax
80105e68:	74 0c                	je     80105e76 <sys_unlink+0x159>
    panic("unlink: writei");
80105e6a:	c7 04 24 8a 94 10 80 	movl   $0x8010948a,(%esp)
80105e71:	e8 de a6 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e79:	8b 40 50             	mov    0x50(%eax),%eax
80105e7c:	66 83 f8 01          	cmp    $0x1,%ax
80105e80:	75 1a                	jne    80105e9c <sys_unlink+0x17f>
    dp->nlink--;
80105e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e85:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e89:	48                   	dec    %eax
80105e8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e8d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e94:	89 04 24             	mov    %eax,(%esp)
80105e97:	e8 63 ba ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
80105e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9f:	89 04 24             	mov    %eax,(%esp)
80105ea2:	e8 1a be ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
80105ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eaa:	66 8b 40 56          	mov    0x56(%eax),%ax
80105eae:	48                   	dec    %eax
80105eaf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105eb2:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb9:	89 04 24             	mov    %eax,(%esp)
80105ebc:	e8 3e ba ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec4:	89 04 24             	mov    %eax,(%esp)
80105ec7:	e8 f5 bd ff ff       	call   80101cc1 <iunlockput>

  end_op();
80105ecc:	e8 30 d8 ff ff       	call   80103701 <end_op>

  return 0;
80105ed1:	b8 00 00 00 00       	mov    $0x0,%eax
80105ed6:	eb 15                	jmp    80105eed <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edb:	89 04 24             	mov    %eax,(%esp)
80105ede:	e8 de bd ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105ee3:	e8 19 d8 ff ff       	call   80103701 <end_op>
  return -1;
80105ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eed:	c9                   	leave  
80105eee:	c3                   	ret    

80105eef <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105eef:	55                   	push   %ebp
80105ef0:	89 e5                	mov    %esp,%ebp
80105ef2:	83 ec 48             	sub    $0x48,%esp
80105ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ef8:	8b 55 10             	mov    0x10(%ebp),%edx
80105efb:	8b 45 14             	mov    0x14(%ebp),%eax
80105efe:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f02:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f06:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f0a:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f11:	8b 45 08             	mov    0x8(%ebp),%eax
80105f14:	89 04 24             	mov    %eax,(%esp)
80105f17:	e8 ed c6 ff ff       	call   80102609 <nameiparent>
80105f1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f23:	75 0a                	jne    80105f2f <create+0x40>
    return 0;
80105f25:	b8 00 00 00 00       	mov    $0x0,%eax
80105f2a:	e9 79 01 00 00       	jmp    801060a8 <create+0x1b9>
  ilock(dp);
80105f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f32:	89 04 24             	mov    %eax,(%esp)
80105f35:	e8 88 bb ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f41:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f44:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4b:	89 04 24             	mov    %eax,(%esp)
80105f4e:	e8 1b c3 ff ff       	call   8010226e <dirlookup>
80105f53:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f5a:	74 46                	je     80105fa2 <create+0xb3>
    iunlockput(dp);
80105f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5f:	89 04 24             	mov    %eax,(%esp)
80105f62:	e8 5a bd ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
80105f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6a:	89 04 24             	mov    %eax,(%esp)
80105f6d:	e8 50 bb ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f72:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f77:	75 14                	jne    80105f8d <create+0x9e>
80105f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7c:	8b 40 50             	mov    0x50(%eax),%eax
80105f7f:	66 83 f8 02          	cmp    $0x2,%ax
80105f83:	75 08                	jne    80105f8d <create+0x9e>
      return ip;
80105f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f88:	e9 1b 01 00 00       	jmp    801060a8 <create+0x1b9>
    iunlockput(ip);
80105f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f90:	89 04 24             	mov    %eax,(%esp)
80105f93:	e8 29 bd ff ff       	call   80101cc1 <iunlockput>
    return 0;
80105f98:	b8 00 00 00 00       	mov    $0x0,%eax
80105f9d:	e9 06 01 00 00       	jmp    801060a8 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105fa2:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	8b 00                	mov    (%eax),%eax
80105fab:	89 54 24 04          	mov    %edx,0x4(%esp)
80105faf:	89 04 24             	mov    %eax,(%esp)
80105fb2:	e8 76 b8 ff ff       	call   8010182d <ialloc>
80105fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fbe:	75 0c                	jne    80105fcc <create+0xdd>
    panic("create: ialloc");
80105fc0:	c7 04 24 99 94 10 80 	movl   $0x80109499,(%esp)
80105fc7:	e8 88 a5 ff ff       	call   80100554 <panic>

  ilock(ip);
80105fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcf:	89 04 24             	mov    %eax,(%esp)
80105fd2:	e8 eb ba ff ff       	call   80101ac2 <ilock>
  ip->major = major;
80105fd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fda:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105fdd:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105fe1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fe4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105fe7:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fee:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff7:	89 04 24             	mov    %eax,(%esp)
80105ffa:	e8 00 b9 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105fff:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106004:	75 68                	jne    8010606e <create+0x17f>
    dp->nlink++;  // for ".."
80106006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106009:	66 8b 40 56          	mov    0x56(%eax),%ax
8010600d:	40                   	inc    %eax
8010600e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106011:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106018:	89 04 24             	mov    %eax,(%esp)
8010601b:	e8 df b8 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106023:	8b 40 04             	mov    0x4(%eax),%eax
80106026:	89 44 24 08          	mov    %eax,0x8(%esp)
8010602a:	c7 44 24 04 73 94 10 	movl   $0x80109473,0x4(%esp)
80106031:	80 
80106032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106035:	89 04 24             	mov    %eax,(%esp)
80106038:	e8 f7 c2 ff ff       	call   80102334 <dirlink>
8010603d:	85 c0                	test   %eax,%eax
8010603f:	78 21                	js     80106062 <create+0x173>
80106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106044:	8b 40 04             	mov    0x4(%eax),%eax
80106047:	89 44 24 08          	mov    %eax,0x8(%esp)
8010604b:	c7 44 24 04 75 94 10 	movl   $0x80109475,0x4(%esp)
80106052:	80 
80106053:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106056:	89 04 24             	mov    %eax,(%esp)
80106059:	e8 d6 c2 ff ff       	call   80102334 <dirlink>
8010605e:	85 c0                	test   %eax,%eax
80106060:	79 0c                	jns    8010606e <create+0x17f>
      panic("create dots");
80106062:	c7 04 24 a8 94 10 80 	movl   $0x801094a8,(%esp)
80106069:	e8 e6 a4 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010606e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106071:	8b 40 04             	mov    0x4(%eax),%eax
80106074:	89 44 24 08          	mov    %eax,0x8(%esp)
80106078:	8d 45 de             	lea    -0x22(%ebp),%eax
8010607b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106082:	89 04 24             	mov    %eax,(%esp)
80106085:	e8 aa c2 ff ff       	call   80102334 <dirlink>
8010608a:	85 c0                	test   %eax,%eax
8010608c:	79 0c                	jns    8010609a <create+0x1ab>
    panic("create: dirlink");
8010608e:	c7 04 24 b4 94 10 80 	movl   $0x801094b4,(%esp)
80106095:	e8 ba a4 ff ff       	call   80100554 <panic>

  iunlockput(dp);
8010609a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 1c bc ff ff       	call   80101cc1 <iunlockput>

  return ip;
801060a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060a8:	c9                   	leave  
801060a9:	c3                   	ret    

801060aa <sys_open>:

int
sys_open(void)
{
801060aa:	55                   	push   %ebp
801060ab:	89 e5                	mov    %esp,%ebp
801060ad:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801060b0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801060b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060be:	e8 f1 f6 ff ff       	call   801057b4 <argstr>
801060c3:	85 c0                	test   %eax,%eax
801060c5:	78 17                	js     801060de <sys_open+0x34>
801060c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060d5:	e8 43 f6 ff ff       	call   8010571d <argint>
801060da:	85 c0                	test   %eax,%eax
801060dc:	79 0a                	jns    801060e8 <sys_open+0x3e>
    return -1;
801060de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e3:	e9 64 01 00 00       	jmp    8010624c <sys_open+0x1a2>

  begin_op();
801060e8:	e8 92 d5 ff ff       	call   8010367f <begin_op>

  if(omode & O_CREATE){
801060ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f0:	25 00 02 00 00       	and    $0x200,%eax
801060f5:	85 c0                	test   %eax,%eax
801060f7:	74 3b                	je     80106134 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801060f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106103:	00 
80106104:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010610b:	00 
8010610c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106113:	00 
80106114:	89 04 24             	mov    %eax,(%esp)
80106117:	e8 d3 fd ff ff       	call   80105eef <create>
8010611c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010611f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106123:	75 6a                	jne    8010618f <sys_open+0xe5>
      end_op();
80106125:	e8 d7 d5 ff ff       	call   80103701 <end_op>
      return -1;
8010612a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612f:	e9 18 01 00 00       	jmp    8010624c <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106134:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106137:	89 04 24             	mov    %eax,(%esp)
8010613a:	e8 a8 c4 ff ff       	call   801025e7 <namei>
8010613f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106142:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106146:	75 0f                	jne    80106157 <sys_open+0xad>
      end_op();
80106148:	e8 b4 d5 ff ff       	call   80103701 <end_op>
      return -1;
8010614d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106152:	e9 f5 00 00 00       	jmp    8010624c <sys_open+0x1a2>
    }
    ilock(ip);
80106157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615a:	89 04 24             	mov    %eax,(%esp)
8010615d:	e8 60 b9 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106165:	8b 40 50             	mov    0x50(%eax),%eax
80106168:	66 83 f8 01          	cmp    $0x1,%ax
8010616c:	75 21                	jne    8010618f <sys_open+0xe5>
8010616e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106171:	85 c0                	test   %eax,%eax
80106173:	74 1a                	je     8010618f <sys_open+0xe5>
      iunlockput(ip);
80106175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106178:	89 04 24             	mov    %eax,(%esp)
8010617b:	e8 41 bb ff ff       	call   80101cc1 <iunlockput>
      end_op();
80106180:	e8 7c d5 ff ff       	call   80103701 <end_op>
      return -1;
80106185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618a:	e9 bd 00 00 00       	jmp    8010624c <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010618f:	e8 6e af ff ff       	call   80101102 <filealloc>
80106194:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010619b:	74 14                	je     801061b1 <sys_open+0x107>
8010619d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a0:	89 04 24             	mov    %eax,(%esp)
801061a3:	e8 40 f7 ff ff       	call   801058e8 <fdalloc>
801061a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801061ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801061af:	79 28                	jns    801061d9 <sys_open+0x12f>
    if(f)
801061b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061b5:	74 0b                	je     801061c2 <sys_open+0x118>
      fileclose(f);
801061b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ba:	89 04 24             	mov    %eax,(%esp)
801061bd:	e8 e8 af ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
801061c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c5:	89 04 24             	mov    %eax,(%esp)
801061c8:	e8 f4 ba ff ff       	call   80101cc1 <iunlockput>
    end_op();
801061cd:	e8 2f d5 ff ff       	call   80103701 <end_op>
    return -1;
801061d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d7:	eb 73                	jmp    8010624c <sys_open+0x1a2>
  }
  iunlock(ip);
801061d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dc:	89 04 24             	mov    %eax,(%esp)
801061df:	e8 e8 b9 ff ff       	call   80101bcc <iunlock>
  end_op();
801061e4:	e8 18 d5 ff ff       	call   80103701 <end_op>

  f->type = FD_INODE;
801061e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ec:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061f8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106205:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106208:	83 e0 01             	and    $0x1,%eax
8010620b:	85 c0                	test   %eax,%eax
8010620d:	0f 94 c0             	sete   %al
80106210:	88 c2                	mov    %al,%dl
80106212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106215:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010621b:	83 e0 01             	and    $0x1,%eax
8010621e:	85 c0                	test   %eax,%eax
80106220:	75 0a                	jne    8010622c <sys_open+0x182>
80106222:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106225:	83 e0 02             	and    $0x2,%eax
80106228:	85 c0                	test   %eax,%eax
8010622a:	74 07                	je     80106233 <sys_open+0x189>
8010622c:	b8 01 00 00 00       	mov    $0x1,%eax
80106231:	eb 05                	jmp    80106238 <sys_open+0x18e>
80106233:	b8 00 00 00 00       	mov    $0x0,%eax
80106238:	88 c2                	mov    %al,%dl
8010623a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623d:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
80106240:	8b 55 e8             	mov    -0x18(%ebp),%edx
80106243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106246:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
80106249:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010624c:	c9                   	leave  
8010624d:	c3                   	ret    

8010624e <sys_mkdir>:

int
sys_mkdir(void)
{
8010624e:	55                   	push   %ebp
8010624f:	89 e5                	mov    %esp,%ebp
80106251:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106254:	e8 26 d4 ff ff       	call   8010367f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106259:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010625c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106267:	e8 48 f5 ff ff       	call   801057b4 <argstr>
8010626c:	85 c0                	test   %eax,%eax
8010626e:	78 2c                	js     8010629c <sys_mkdir+0x4e>
80106270:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010627a:	00 
8010627b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106282:	00 
80106283:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010628a:	00 
8010628b:	89 04 24             	mov    %eax,(%esp)
8010628e:	e8 5c fc ff ff       	call   80105eef <create>
80106293:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106296:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010629a:	75 0c                	jne    801062a8 <sys_mkdir+0x5a>
    end_op();
8010629c:	e8 60 d4 ff ff       	call   80103701 <end_op>
    return -1;
801062a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a6:	eb 15                	jmp    801062bd <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801062a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ab:	89 04 24             	mov    %eax,(%esp)
801062ae:	e8 0e ba ff ff       	call   80101cc1 <iunlockput>
  end_op();
801062b3:	e8 49 d4 ff ff       	call   80103701 <end_op>
  return 0;
801062b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bd:	c9                   	leave  
801062be:	c3                   	ret    

801062bf <sys_mknod>:

int
sys_mknod(void)
{
801062bf:	55                   	push   %ebp
801062c0:	89 e5                	mov    %esp,%ebp
801062c2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801062c5:	e8 b5 d3 ff ff       	call   8010367f <begin_op>
  if((argstr(0, &path)) < 0 ||
801062ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062d8:	e8 d7 f4 ff ff       	call   801057b4 <argstr>
801062dd:	85 c0                	test   %eax,%eax
801062df:	78 5e                	js     8010633f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801062e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062ef:	e8 29 f4 ff ff       	call   8010571d <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801062f4:	85 c0                	test   %eax,%eax
801062f6:	78 47                	js     8010633f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062f8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801062ff:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106306:	e8 12 f4 ff ff       	call   8010571d <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010630b:	85 c0                	test   %eax,%eax
8010630d:	78 30                	js     8010633f <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010630f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106312:	0f bf c8             	movswl %ax,%ecx
80106315:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106318:	0f bf d0             	movswl %ax,%edx
8010631b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010631e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106322:	89 54 24 08          	mov    %edx,0x8(%esp)
80106326:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010632d:	00 
8010632e:	89 04 24             	mov    %eax,(%esp)
80106331:	e8 b9 fb ff ff       	call   80105eef <create>
80106336:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010633d:	75 0c                	jne    8010634b <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010633f:	e8 bd d3 ff ff       	call   80103701 <end_op>
    return -1;
80106344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106349:	eb 15                	jmp    80106360 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010634b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634e:	89 04 24             	mov    %eax,(%esp)
80106351:	e8 6b b9 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106356:	e8 a6 d3 ff ff       	call   80103701 <end_op>
  return 0;
8010635b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106360:	c9                   	leave  
80106361:	c3                   	ret    

80106362 <sys_chdir>:

int
sys_chdir(void)
{
80106362:	55                   	push   %ebp
80106363:	89 e5                	mov    %esp,%ebp
80106365:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106368:	e8 12 e0 ff ff       	call   8010437f <myproc>
8010636d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106370:	e8 0a d3 ff ff       	call   8010367f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106375:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106378:	89 44 24 04          	mov    %eax,0x4(%esp)
8010637c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106383:	e8 2c f4 ff ff       	call   801057b4 <argstr>
80106388:	85 c0                	test   %eax,%eax
8010638a:	78 14                	js     801063a0 <sys_chdir+0x3e>
8010638c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010638f:	89 04 24             	mov    %eax,(%esp)
80106392:	e8 50 c2 ff ff       	call   801025e7 <namei>
80106397:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010639a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010639e:	75 0c                	jne    801063ac <sys_chdir+0x4a>
    end_op();
801063a0:	e8 5c d3 ff ff       	call   80103701 <end_op>
    return -1;
801063a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063aa:	eb 5a                	jmp    80106406 <sys_chdir+0xa4>
  }
  ilock(ip);
801063ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063af:	89 04 24             	mov    %eax,(%esp)
801063b2:	e8 0b b7 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
801063b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ba:	8b 40 50             	mov    0x50(%eax),%eax
801063bd:	66 83 f8 01          	cmp    $0x1,%ax
801063c1:	74 17                	je     801063da <sys_chdir+0x78>
    iunlockput(ip);
801063c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c6:	89 04 24             	mov    %eax,(%esp)
801063c9:	e8 f3 b8 ff ff       	call   80101cc1 <iunlockput>
    end_op();
801063ce:	e8 2e d3 ff ff       	call   80103701 <end_op>
    return -1;
801063d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d8:	eb 2c                	jmp    80106406 <sys_chdir+0xa4>
  }
  iunlock(ip);
801063da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063dd:	89 04 24             	mov    %eax,(%esp)
801063e0:	e8 e7 b7 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
801063e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e8:	8b 40 68             	mov    0x68(%eax),%eax
801063eb:	89 04 24             	mov    %eax,(%esp)
801063ee:	e8 1d b8 ff ff       	call   80101c10 <iput>
  end_op();
801063f3:	e8 09 d3 ff ff       	call   80103701 <end_op>
  curproc->cwd = ip;
801063f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063fe:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106401:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106406:	c9                   	leave  
80106407:	c3                   	ret    

80106408 <sys_exec>:

int
sys_exec(void)
{
80106408:	55                   	push   %ebp
80106409:	89 e5                	mov    %esp,%ebp
8010640b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106411:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106414:	89 44 24 04          	mov    %eax,0x4(%esp)
80106418:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010641f:	e8 90 f3 ff ff       	call   801057b4 <argstr>
80106424:	85 c0                	test   %eax,%eax
80106426:	78 1a                	js     80106442 <sys_exec+0x3a>
80106428:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010642e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106432:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106439:	e8 df f2 ff ff       	call   8010571d <argint>
8010643e:	85 c0                	test   %eax,%eax
80106440:	79 0a                	jns    8010644c <sys_exec+0x44>
    return -1;
80106442:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106447:	e9 c7 00 00 00       	jmp    80106513 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
8010644c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106453:	00 
80106454:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010645b:	00 
8010645c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106462:	89 04 24             	mov    %eax,(%esp)
80106465:	e8 80 ef ff ff       	call   801053ea <memset>
  for(i=0;; i++){
8010646a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106474:	83 f8 1f             	cmp    $0x1f,%eax
80106477:	76 0a                	jbe    80106483 <sys_exec+0x7b>
      return -1;
80106479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647e:	e9 90 00 00 00       	jmp    80106513 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106486:	c1 e0 02             	shl    $0x2,%eax
80106489:	89 c2                	mov    %eax,%edx
8010648b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106491:	01 c2                	add    %eax,%edx
80106493:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106499:	89 44 24 04          	mov    %eax,0x4(%esp)
8010649d:	89 14 24             	mov    %edx,(%esp)
801064a0:	e8 d7 f1 ff ff       	call   8010567c <fetchint>
801064a5:	85 c0                	test   %eax,%eax
801064a7:	79 07                	jns    801064b0 <sys_exec+0xa8>
      return -1;
801064a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ae:	eb 63                	jmp    80106513 <sys_exec+0x10b>
    if(uarg == 0){
801064b0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064b6:	85 c0                	test   %eax,%eax
801064b8:	75 26                	jne    801064e0 <sys_exec+0xd8>
      argv[i] = 0;
801064ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bd:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801064c4:	00 00 00 00 
      break;
801064c8:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cc:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801064d6:	89 04 24             	mov    %eax,(%esp)
801064d9:	e8 62 a7 ff ff       	call   80100c40 <exec>
801064de:	eb 33                	jmp    80106513 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801064e0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064e9:	c1 e2 02             	shl    $0x2,%edx
801064ec:	01 c2                	add    %eax,%edx
801064ee:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064f4:	89 54 24 04          	mov    %edx,0x4(%esp)
801064f8:	89 04 24             	mov    %eax,(%esp)
801064fb:	e8 bb f1 ff ff       	call   801056bb <fetchstr>
80106500:	85 c0                	test   %eax,%eax
80106502:	79 07                	jns    8010650b <sys_exec+0x103>
      return -1;
80106504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106509:	eb 08                	jmp    80106513 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010650b:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010650e:	e9 5e ff ff ff       	jmp    80106471 <sys_exec+0x69>
  return exec(path, argv);
}
80106513:	c9                   	leave  
80106514:	c3                   	ret    

80106515 <sys_pipe>:

int
sys_pipe(void)
{
80106515:	55                   	push   %ebp
80106516:	89 e5                	mov    %esp,%ebp
80106518:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010651b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106522:	00 
80106523:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106526:	89 44 24 04          	mov    %eax,0x4(%esp)
8010652a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106531:	e8 14 f2 ff ff       	call   8010574a <argptr>
80106536:	85 c0                	test   %eax,%eax
80106538:	79 0a                	jns    80106544 <sys_pipe+0x2f>
    return -1;
8010653a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653f:	e9 9a 00 00 00       	jmp    801065de <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106544:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106547:	89 44 24 04          	mov    %eax,0x4(%esp)
8010654b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010654e:	89 04 24             	mov    %eax,(%esp)
80106551:	e8 7e d9 ff ff       	call   80103ed4 <pipealloc>
80106556:	85 c0                	test   %eax,%eax
80106558:	79 07                	jns    80106561 <sys_pipe+0x4c>
    return -1;
8010655a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655f:	eb 7d                	jmp    801065de <sys_pipe+0xc9>
  fd0 = -1;
80106561:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106568:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010656b:	89 04 24             	mov    %eax,(%esp)
8010656e:	e8 75 f3 ff ff       	call   801058e8 <fdalloc>
80106573:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106576:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010657a:	78 14                	js     80106590 <sys_pipe+0x7b>
8010657c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010657f:	89 04 24             	mov    %eax,(%esp)
80106582:	e8 61 f3 ff ff       	call   801058e8 <fdalloc>
80106587:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010658a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010658e:	79 36                	jns    801065c6 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106590:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106594:	78 13                	js     801065a9 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106596:	e8 e4 dd ff ff       	call   8010437f <myproc>
8010659b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010659e:	83 c2 08             	add    $0x8,%edx
801065a1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801065a8:	00 
    fileclose(rf);
801065a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065ac:	89 04 24             	mov    %eax,(%esp)
801065af:	e8 f6 ab ff ff       	call   801011aa <fileclose>
    fileclose(wf);
801065b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065b7:	89 04 24             	mov    %eax,(%esp)
801065ba:	e8 eb ab ff ff       	call   801011aa <fileclose>
    return -1;
801065bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c4:	eb 18                	jmp    801065de <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801065c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065cc:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065d1:	8d 50 04             	lea    0x4(%eax),%edx
801065d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d7:	89 02                	mov    %eax,(%edx)
  return 0;
801065d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065de:	c9                   	leave  
801065df:	c3                   	ret    

801065e0 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
801065e0:	55                   	push   %ebp
801065e1:	89 e5                	mov    %esp,%ebp
801065e3:	83 ec 08             	sub    $0x8,%esp
  return fork();
801065e6:	e8 ad e0 ff ff       	call   80104698 <fork>
}
801065eb:	c9                   	leave  
801065ec:	c3                   	ret    

801065ed <sys_exit>:

int
sys_exit(void)
{
801065ed:	55                   	push   %ebp
801065ee:	89 e5                	mov    %esp,%ebp
801065f0:	83 ec 08             	sub    $0x8,%esp
  exit();
801065f3:	e8 18 e2 ff ff       	call   80104810 <exit>
  return 0;  // not reached
801065f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065fd:	c9                   	leave  
801065fe:	c3                   	ret    

801065ff <sys_wait>:

int
sys_wait(void)
{
801065ff:	55                   	push   %ebp
80106600:	89 e5                	mov    %esp,%ebp
80106602:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106605:	e8 12 e3 ff ff       	call   8010491c <wait>
}
8010660a:	c9                   	leave  
8010660b:	c3                   	ret    

8010660c <sys_kill>:

int
sys_kill(void)
{
8010660c:	55                   	push   %ebp
8010660d:	89 e5                	mov    %esp,%ebp
8010660f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106612:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106615:	89 44 24 04          	mov    %eax,0x4(%esp)
80106619:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106620:	e8 f8 f0 ff ff       	call   8010571d <argint>
80106625:	85 c0                	test   %eax,%eax
80106627:	79 07                	jns    80106630 <sys_kill+0x24>
    return -1;
80106629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662e:	eb 0b                	jmp    8010663b <sys_kill+0x2f>
  return kill(pid);
80106630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106633:	89 04 24             	mov    %eax,(%esp)
80106636:	e8 bf e6 ff ff       	call   80104cfa <kill>
}
8010663b:	c9                   	leave  
8010663c:	c3                   	ret    

8010663d <sys_getpid>:

int
sys_getpid(void)
{
8010663d:	55                   	push   %ebp
8010663e:	89 e5                	mov    %esp,%ebp
80106640:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106643:	e8 37 dd ff ff       	call   8010437f <myproc>
80106648:	8b 40 10             	mov    0x10(%eax),%eax
}
8010664b:	c9                   	leave  
8010664c:	c3                   	ret    

8010664d <sys_sbrk>:

int
sys_sbrk(void)
{
8010664d:	55                   	push   %ebp
8010664e:	89 e5                	mov    %esp,%ebp
80106650:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106653:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106656:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106661:	e8 b7 f0 ff ff       	call   8010571d <argint>
80106666:	85 c0                	test   %eax,%eax
80106668:	79 07                	jns    80106671 <sys_sbrk+0x24>
    return -1;
8010666a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666f:	eb 23                	jmp    80106694 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106671:	e8 09 dd ff ff       	call   8010437f <myproc>
80106676:	8b 00                	mov    (%eax),%eax
80106678:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010667b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010667e:	89 04 24             	mov    %eax,(%esp)
80106681:	e8 74 df ff ff       	call   801045fa <growproc>
80106686:	85 c0                	test   %eax,%eax
80106688:	79 07                	jns    80106691 <sys_sbrk+0x44>
    return -1;
8010668a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668f:	eb 03                	jmp    80106694 <sys_sbrk+0x47>
  return addr;
80106691:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106694:	c9                   	leave  
80106695:	c3                   	ret    

80106696 <sys_sleep>:

int
sys_sleep(void)
{
80106696:	55                   	push   %ebp
80106697:	89 e5                	mov    %esp,%ebp
80106699:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010669c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010669f:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066aa:	e8 6e f0 ff ff       	call   8010571d <argint>
801066af:	85 c0                	test   %eax,%eax
801066b1:	79 07                	jns    801066ba <sys_sleep+0x24>
    return -1;
801066b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b8:	eb 6b                	jmp    80106725 <sys_sleep+0x8f>
  acquire(&tickslock);
801066ba:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801066c1:	e8 c1 ea ff ff       	call   80105187 <acquire>
  ticks0 = ticks;
801066c6:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
801066cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801066ce:	eb 33                	jmp    80106703 <sys_sleep+0x6d>
    if(myproc()->killed){
801066d0:	e8 aa dc ff ff       	call   8010437f <myproc>
801066d5:	8b 40 24             	mov    0x24(%eax),%eax
801066d8:	85 c0                	test   %eax,%eax
801066da:	74 13                	je     801066ef <sys_sleep+0x59>
      release(&tickslock);
801066dc:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801066e3:	e8 09 eb ff ff       	call   801051f1 <release>
      return -1;
801066e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ed:	eb 36                	jmp    80106725 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
801066ef:	c7 44 24 04 60 73 11 	movl   $0x80117360,0x4(%esp)
801066f6:	80 
801066f7:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
801066fe:	e8 f5 e4 ff ff       	call   80104bf8 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106703:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010670b:	89 c2                	mov    %eax,%edx
8010670d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106710:	39 c2                	cmp    %eax,%edx
80106712:	72 bc                	jb     801066d0 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106714:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010671b:	e8 d1 ea ff ff       	call   801051f1 <release>
  return 0;
80106720:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106725:	c9                   	leave  
80106726:	c3                   	ret    

80106727 <sys_ps>:

void sys_ps(){
80106727:	55                   	push   %ebp
80106728:	89 e5                	mov    %esp,%ebp
8010672a:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
8010672d:	e8 4d dc ff ff       	call   8010437f <myproc>
80106732:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106738:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
8010673b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010673f:	75 07                	jne    80106748 <sys_ps+0x21>
    procdump();
80106741:	e8 2f e6 ff ff       	call   80104d75 <procdump>
80106746:	eb 0e                	jmp    80106756 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674b:	83 c0 18             	add    $0x18,%eax
8010674e:	89 04 24             	mov    %eax,(%esp)
80106751:	e8 96 e7 ff ff       	call   80104eec <c_procdump>
  }
}
80106756:	c9                   	leave  
80106757:	c3                   	ret    

80106758 <sys_container_init>:

void sys_container_init(){
80106758:	55                   	push   %ebp
80106759:	89 e5                	mov    %esp,%ebp
8010675b:	83 ec 08             	sub    $0x8,%esp
  container_init();
8010675e:	e8 e5 26 00 00       	call   80108e48 <container_init>
}
80106763:	c9                   	leave  
80106764:	c3                   	ret    

80106765 <sys_is_full>:

int sys_is_full(void){
80106765:	55                   	push   %ebp
80106766:	89 e5                	mov    %esp,%ebp
80106768:	83 ec 08             	sub    $0x8,%esp
  return is_full();
8010676b:	e8 da 22 00 00       	call   80108a4a <is_full>
}
80106770:	c9                   	leave  
80106771:	c3                   	ret    

80106772 <sys_find>:

int sys_find(void){
80106772:	55                   	push   %ebp
80106773:	89 e5                	mov    %esp,%ebp
80106775:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106778:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010677b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010677f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106786:	e8 29 f0 ff ff       	call   801057b4 <argstr>

  return find(name);
8010678b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678e:	89 04 24             	mov    %eax,(%esp)
80106791:	e8 04 23 00 00       	call   80108a9a <find>
}
80106796:	c9                   	leave  
80106797:	c3                   	ret    

80106798 <sys_get_name>:

void sys_get_name(void){
80106798:	55                   	push   %ebp
80106799:	89 e5                	mov    %esp,%ebp
8010679b:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
8010679e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801067a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067ac:	e8 6c ef ff ff       	call   8010571d <argint>
  argstr(1, &name);
801067b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801067bf:	e8 f0 ef ff ff       	call   801057b4 <argstr>

  get_name(vc_num, name);
801067c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801067ce:	89 04 24             	mov    %eax,(%esp)
801067d1:	e8 f1 21 00 00       	call   801089c7 <get_name>
}
801067d6:	c9                   	leave  
801067d7:	c3                   	ret    

801067d8 <sys_get_max_proc>:

int sys_get_max_proc(void){
801067d8:	55                   	push   %ebp
801067d9:	89 e5                	mov    %esp,%ebp
801067db:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801067de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801067e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067ec:	e8 2c ef ff ff       	call   8010571d <argint>


  return get_max_proc(vc_num);  
801067f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f4:	89 04 24             	mov    %eax,(%esp)
801067f7:	e8 0e 23 00 00       	call   80108b0a <get_max_proc>
}
801067fc:	c9                   	leave  
801067fd:	c3                   	ret    

801067fe <sys_get_max_mem>:

int sys_get_max_mem(void){
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106804:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106807:	89 44 24 04          	mov    %eax,0x4(%esp)
8010680b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106812:	e8 06 ef ff ff       	call   8010571d <argint>


  return get_max_mem(vc_num);
80106817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681a:	89 04 24             	mov    %eax,(%esp)
8010681d:	e8 50 23 00 00       	call   80108b72 <get_max_mem>
}
80106822:	c9                   	leave  
80106823:	c3                   	ret    

80106824 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106824:	55                   	push   %ebp
80106825:	89 e5                	mov    %esp,%ebp
80106827:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010682a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010682d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106831:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106838:	e8 e0 ee ff ff       	call   8010571d <argint>


  return get_max_disk(vc_num);
8010683d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106840:	89 04 24             	mov    %eax,(%esp)
80106843:	e8 6a 23 00 00       	call   80108bb2 <get_max_disk>

}
80106848:	c9                   	leave  
80106849:	c3                   	ret    

8010684a <sys_get_curr_proc>:

int sys_get_curr_proc(void){
8010684a:	55                   	push   %ebp
8010684b:	89 e5                	mov    %esp,%ebp
8010684d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106850:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106853:	89 44 24 04          	mov    %eax,0x4(%esp)
80106857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010685e:	e8 ba ee ff ff       	call   8010571d <argint>


  return get_curr_proc(vc_num);
80106863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106866:	89 04 24             	mov    %eax,(%esp)
80106869:	e8 84 23 00 00       	call   80108bf2 <get_curr_proc>
}
8010686e:	c9                   	leave  
8010686f:	c3                   	ret    

80106870 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106876:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106879:	89 44 24 04          	mov    %eax,0x4(%esp)
8010687d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106884:	e8 94 ee ff ff       	call   8010571d <argint>


  return get_curr_mem(vc_num);
80106889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688c:	89 04 24             	mov    %eax,(%esp)
8010688f:	e8 9e 23 00 00       	call   80108c32 <get_curr_mem>
}
80106894:	c9                   	leave  
80106895:	c3                   	ret    

80106896 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106896:	55                   	push   %ebp
80106897:	89 e5                	mov    %esp,%ebp
80106899:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010689c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010689f:	89 44 24 04          	mov    %eax,0x4(%esp)
801068a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068aa:	e8 6e ee ff ff       	call   8010571d <argint>


  return get_curr_disk(vc_num);
801068af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b2:	89 04 24             	mov    %eax,(%esp)
801068b5:	e8 b8 23 00 00       	call   80108c72 <get_curr_disk>
}
801068ba:	c9                   	leave  
801068bb:	c3                   	ret    

801068bc <sys_set_name>:

void sys_set_name(void){
801068bc:	55                   	push   %ebp
801068bd:	89 e5                	mov    %esp,%ebp
801068bf:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
801068c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801068c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068d0:	e8 df ee ff ff       	call   801057b4 <argstr>

  int vc_num;
  argint(1, &vc_num);
801068d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801068dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801068e3:	e8 35 ee ff ff       	call   8010571d <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
801068e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801068eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801068f2:	89 04 24             	mov    %eax,(%esp)
801068f5:	e8 b8 23 00 00       	call   80108cb2 <set_name>
  //cprintf("Done setting name.\n");
}
801068fa:	c9                   	leave  
801068fb:	c3                   	ret    

801068fc <sys_cont_proc_set>:

void sys_cont_proc_set(void){
801068fc:	55                   	push   %ebp
801068fd:	89 e5                	mov    %esp,%ebp
801068ff:	53                   	push   %ebx
80106900:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106903:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106906:	89 44 24 04          	mov    %eax,0x4(%esp)
8010690a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106911:	e8 07 ee ff ff       	call   8010571d <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106916:	e8 64 da ff ff       	call   8010437f <myproc>
8010691b:	89 c3                	mov    %eax,%ebx
8010691d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106920:	89 04 24             	mov    %eax,(%esp)
80106923:	e8 22 22 00 00       	call   80108b4a <get_container>
80106928:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
8010692e:	83 c4 24             	add    $0x24,%esp
80106931:	5b                   	pop    %ebx
80106932:	5d                   	pop    %ebp
80106933:	c3                   	ret    

80106934 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106934:	55                   	push   %ebp
80106935:	89 e5                	mov    %esp,%ebp
80106937:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
8010693a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010693d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106941:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106948:	e8 d0 ed ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
8010694d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106950:	89 44 24 04          	mov    %eax,0x4(%esp)
80106954:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010695b:	e8 bd ed ff ff       	call   8010571d <argint>

  set_max_mem(mem, vc_num);
80106960:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106966:	89 54 24 04          	mov    %edx,0x4(%esp)
8010696a:	89 04 24             	mov    %eax,(%esp)
8010696d:	e8 77 23 00 00       	call   80108ce9 <set_max_mem>
}
80106972:	c9                   	leave  
80106973:	c3                   	ret    

80106974 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106974:	55                   	push   %ebp
80106975:	89 e5                	mov    %esp,%ebp
80106977:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
8010697a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010697d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106981:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106988:	e8 90 ed ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
8010698d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106990:	89 44 24 04          	mov    %eax,0x4(%esp)
80106994:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010699b:	e8 7d ed ff ff       	call   8010571d <argint>

  set_max_disk(disk, vc_num);
801069a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801069aa:	89 04 24             	mov    %eax,(%esp)
801069ad:	e8 5c 23 00 00       	call   80108d0e <set_max_disk>
}
801069b2:	c9                   	leave  
801069b3:	c3                   	ret    

801069b4 <sys_set_max_proc>:

void sys_set_max_proc(void){
801069b4:	55                   	push   %ebp
801069b5:	89 e5                	mov    %esp,%ebp
801069b7:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801069ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801069c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069c8:	e8 50 ed ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
801069cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069db:	e8 3d ed ff ff       	call   8010571d <argint>

  set_max_proc(proc, vc_num);
801069e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801069ea:	89 04 24             	mov    %eax,(%esp)
801069ed:	e8 42 23 00 00       	call   80108d34 <set_max_proc>
}
801069f2:	c9                   	leave  
801069f3:	c3                   	ret    

801069f4 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
801069f4:	55                   	push   %ebp
801069f5:	89 e5                	mov    %esp,%ebp
801069f7:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801069fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a08:	e8 10 ed ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
80106a0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a10:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a1b:	e8 fd ec ff ff       	call   8010571d <argint>

  set_curr_mem(mem, vc_num);
80106a20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a26:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a2a:	89 04 24             	mov    %eax,(%esp)
80106a2d:	e8 28 23 00 00       	call   80108d5a <set_curr_mem>
}
80106a32:	c9                   	leave  
80106a33:	c3                   	ret    

80106a34 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106a34:	55                   	push   %ebp
80106a35:	89 e5                	mov    %esp,%ebp
80106a37:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106a3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a48:	e8 d0 ec ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
80106a4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a50:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a5b:	e8 bd ec ff ff       	call   8010571d <argint>

  set_curr_mem(mem, vc_num);
80106a60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a66:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a6a:	89 04 24             	mov    %eax,(%esp)
80106a6d:	e8 e8 22 00 00       	call   80108d5a <set_curr_mem>
}
80106a72:	c9                   	leave  
80106a73:	c3                   	ret    

80106a74 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106a74:	55                   	push   %ebp
80106a75:	89 e5                	mov    %esp,%ebp
80106a77:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a88:	e8 90 ec ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
80106a8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a90:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a9b:	e8 7d ec ff ff       	call   8010571d <argint>

  set_curr_disk(disk, vc_num);
80106aa0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106aaa:	89 04 24             	mov    %eax,(%esp)
80106aad:	e8 2c 23 00 00       	call   80108dde <set_curr_disk>
}
80106ab2:	c9                   	leave  
80106ab3:	c3                   	ret    

80106ab4 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106ab4:	55                   	push   %ebp
80106ab5:	89 e5                	mov    %esp,%ebp
80106ab7:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106abd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ac8:	e8 50 ec ff ff       	call   8010571d <argint>

  int vc_num;
  argint(1, &vc_num);
80106acd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ad4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106adb:	e8 3d ec ff ff       	call   8010571d <argint>

  set_curr_proc(proc, vc_num);
80106ae0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106aea:	89 04 24             	mov    %eax,(%esp)
80106aed:	e8 31 23 00 00       	call   80108e23 <set_curr_proc>
}
80106af2:	c9                   	leave  
80106af3:	c3                   	ret    

80106af4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106af4:	55                   	push   %ebp
80106af5:	89 e5                	mov    %esp,%ebp
80106af7:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106afa:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106b01:	e8 81 e6 ff ff       	call   80105187 <acquire>
  xticks = ticks;
80106b06:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106b0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106b0e:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106b15:	e8 d7 e6 ff ff       	call   801051f1 <release>
  return xticks;
80106b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106b1d:	c9                   	leave  
80106b1e:	c3                   	ret    

80106b1f <sys_getticks>:

int
sys_getticks(void)
{
80106b1f:	55                   	push   %ebp
80106b20:	89 e5                	mov    %esp,%ebp
80106b22:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106b25:	e8 55 d8 ff ff       	call   8010437f <myproc>
80106b2a:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106b2d:	c9                   	leave  
80106b2e:	c3                   	ret    
	...

80106b30 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106b30:	1e                   	push   %ds
  pushl %es
80106b31:	06                   	push   %es
  pushl %fs
80106b32:	0f a0                	push   %fs
  pushl %gs
80106b34:	0f a8                	push   %gs
  pushal
80106b36:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106b37:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b3b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b3d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b3f:	54                   	push   %esp
  call trap
80106b40:	e8 c0 01 00 00       	call   80106d05 <trap>
  addl $4, %esp
80106b45:	83 c4 04             	add    $0x4,%esp

80106b48 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b48:	61                   	popa   
  popl %gs
80106b49:	0f a9                	pop    %gs
  popl %fs
80106b4b:	0f a1                	pop    %fs
  popl %es
80106b4d:	07                   	pop    %es
  popl %ds
80106b4e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b4f:	83 c4 08             	add    $0x8,%esp
  iret
80106b52:	cf                   	iret   
	...

80106b54 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106b54:	55                   	push   %ebp
80106b55:	89 e5                	mov    %esp,%ebp
80106b57:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b5d:	48                   	dec    %eax
80106b5e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b62:	8b 45 08             	mov    0x8(%ebp),%eax
80106b65:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b69:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6c:	c1 e8 10             	shr    $0x10,%eax
80106b6f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106b73:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b76:	0f 01 18             	lidtl  (%eax)
}
80106b79:	c9                   	leave  
80106b7a:	c3                   	ret    

80106b7b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b7b:	55                   	push   %ebp
80106b7c:	89 e5                	mov    %esp,%ebp
80106b7e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b81:	0f 20 d0             	mov    %cr2,%eax
80106b84:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b8a:	c9                   	leave  
80106b8b:	c3                   	ret    

80106b8c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b8c:	55                   	push   %ebp
80106b8d:	89 e5                	mov    %esp,%ebp
80106b8f:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b99:	e9 b8 00 00 00       	jmp    80106c56 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba1:	8b 04 85 ec c0 10 80 	mov    -0x7fef3f14(,%eax,4),%eax
80106ba8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bab:	66 89 04 d5 a0 73 11 	mov    %ax,-0x7fee8c60(,%edx,8)
80106bb2:	80 
80106bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb6:	66 c7 04 c5 a2 73 11 	movw   $0x8,-0x7fee8c5e(,%eax,8)
80106bbd:	80 08 00 
80106bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc3:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106bca:	83 e2 e0             	and    $0xffffffe0,%edx
80106bcd:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd7:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106bde:	83 e2 1f             	and    $0x1f,%edx
80106be1:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106beb:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106bf2:	83 e2 f0             	and    $0xfffffff0,%edx
80106bf5:	83 ca 0e             	or     $0xe,%edx
80106bf8:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c02:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106c09:	83 e2 ef             	and    $0xffffffef,%edx
80106c0c:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c16:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106c1d:	83 e2 9f             	and    $0xffffff9f,%edx
80106c20:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2a:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106c31:	83 ca 80             	or     $0xffffff80,%edx
80106c34:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3e:	8b 04 85 ec c0 10 80 	mov    -0x7fef3f14(,%eax,4),%eax
80106c45:	c1 e8 10             	shr    $0x10,%eax
80106c48:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c4b:	66 89 04 d5 a6 73 11 	mov    %ax,-0x7fee8c5a(,%edx,8)
80106c52:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106c53:	ff 45 f4             	incl   -0xc(%ebp)
80106c56:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c5d:	0f 8e 3b ff ff ff    	jle    80106b9e <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c63:	a1 ec c1 10 80       	mov    0x8010c1ec,%eax
80106c68:	66 a3 a0 75 11 80    	mov    %ax,0x801175a0
80106c6e:	66 c7 05 a2 75 11 80 	movw   $0x8,0x801175a2
80106c75:	08 00 
80106c77:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106c7c:	83 e0 e0             	and    $0xffffffe0,%eax
80106c7f:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106c84:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106c89:	83 e0 1f             	and    $0x1f,%eax
80106c8c:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106c91:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106c96:	83 c8 0f             	or     $0xf,%eax
80106c99:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106c9e:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106ca3:	83 e0 ef             	and    $0xffffffef,%eax
80106ca6:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106cab:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106cb0:	83 c8 60             	or     $0x60,%eax
80106cb3:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106cb8:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106cbd:	83 c8 80             	or     $0xffffff80,%eax
80106cc0:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106cc5:	a1 ec c1 10 80       	mov    0x8010c1ec,%eax
80106cca:	c1 e8 10             	shr    $0x10,%eax
80106ccd:	66 a3 a6 75 11 80    	mov    %ax,0x801175a6

  initlock(&tickslock, "time");
80106cd3:	c7 44 24 04 c4 94 10 	movl   $0x801094c4,0x4(%esp)
80106cda:	80 
80106cdb:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106ce2:	e8 7f e4 ff ff       	call   80105166 <initlock>
}
80106ce7:	c9                   	leave  
80106ce8:	c3                   	ret    

80106ce9 <idtinit>:

void
idtinit(void)
{
80106ce9:	55                   	push   %ebp
80106cea:	89 e5                	mov    %esp,%ebp
80106cec:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106cef:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106cf6:	00 
80106cf7:	c7 04 24 a0 73 11 80 	movl   $0x801173a0,(%esp)
80106cfe:	e8 51 fe ff ff       	call   80106b54 <lidt>
}
80106d03:	c9                   	leave  
80106d04:	c3                   	ret    

80106d05 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106d05:	55                   	push   %ebp
80106d06:	89 e5                	mov    %esp,%ebp
80106d08:	57                   	push   %edi
80106d09:	56                   	push   %esi
80106d0a:	53                   	push   %ebx
80106d0b:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d11:	8b 40 30             	mov    0x30(%eax),%eax
80106d14:	83 f8 40             	cmp    $0x40,%eax
80106d17:	75 3c                	jne    80106d55 <trap+0x50>
    if(myproc()->killed)
80106d19:	e8 61 d6 ff ff       	call   8010437f <myproc>
80106d1e:	8b 40 24             	mov    0x24(%eax),%eax
80106d21:	85 c0                	test   %eax,%eax
80106d23:	74 05                	je     80106d2a <trap+0x25>
      exit();
80106d25:	e8 e6 da ff ff       	call   80104810 <exit>
    myproc()->tf = tf;
80106d2a:	e8 50 d6 ff ff       	call   8010437f <myproc>
80106d2f:	8b 55 08             	mov    0x8(%ebp),%edx
80106d32:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d35:	e8 b1 ea ff ff       	call   801057eb <syscall>
    if(myproc()->killed)
80106d3a:	e8 40 d6 ff ff       	call   8010437f <myproc>
80106d3f:	8b 40 24             	mov    0x24(%eax),%eax
80106d42:	85 c0                	test   %eax,%eax
80106d44:	74 0a                	je     80106d50 <trap+0x4b>
      exit();
80106d46:	e8 c5 da ff ff       	call   80104810 <exit>
    return;
80106d4b:	e9 30 02 00 00       	jmp    80106f80 <trap+0x27b>
80106d50:	e9 2b 02 00 00       	jmp    80106f80 <trap+0x27b>
  }

  switch(tf->trapno){
80106d55:	8b 45 08             	mov    0x8(%ebp),%eax
80106d58:	8b 40 30             	mov    0x30(%eax),%eax
80106d5b:	83 e8 20             	sub    $0x20,%eax
80106d5e:	83 f8 1f             	cmp    $0x1f,%eax
80106d61:	0f 87 cb 00 00 00    	ja     80106e32 <trap+0x12d>
80106d67:	8b 04 85 6c 95 10 80 	mov    -0x7fef6a94(,%eax,4),%eax
80106d6e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d70:	e8 41 d5 ff ff       	call   801042b6 <cpuid>
80106d75:	85 c0                	test   %eax,%eax
80106d77:	75 2f                	jne    80106da8 <trap+0xa3>
      acquire(&tickslock);
80106d79:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d80:	e8 02 e4 ff ff       	call   80105187 <acquire>
      ticks++;
80106d85:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106d8a:	40                   	inc    %eax
80106d8b:	a3 a0 7b 11 80       	mov    %eax,0x80117ba0
      wakeup(&ticks);
80106d90:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
80106d97:	e8 33 df ff ff       	call   80104ccf <wakeup>
      release(&tickslock);
80106d9c:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106da3:	e8 49 e4 ff ff       	call   801051f1 <release>
    }
    p = myproc();
80106da8:	e8 d2 d5 ff ff       	call   8010437f <myproc>
80106dad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80106db0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106db4:	74 0f                	je     80106dc5 <trap+0xc0>
      p->ticks++;
80106db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106db9:	8b 40 7c             	mov    0x7c(%eax),%eax
80106dbc:	8d 50 01             	lea    0x1(%eax),%edx
80106dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dc2:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106dc5:	e8 8d c3 ff ff       	call   80103157 <lapiceoi>
    break;
80106dca:	e9 35 01 00 00       	jmp    80106f04 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106dcf:	e8 3e bb ff ff       	call   80102912 <ideintr>
    lapiceoi();
80106dd4:	e8 7e c3 ff ff       	call   80103157 <lapiceoi>
    break;
80106dd9:	e9 26 01 00 00       	jmp    80106f04 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106dde:	e8 8b c1 ff ff       	call   80102f6e <kbdintr>
    lapiceoi();
80106de3:	e8 6f c3 ff ff       	call   80103157 <lapiceoi>
    break;
80106de8:	e9 17 01 00 00       	jmp    80106f04 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ded:	e8 6f 03 00 00       	call   80107161 <uartintr>
    lapiceoi();
80106df2:	e8 60 c3 ff ff       	call   80103157 <lapiceoi>
    break;
80106df7:	e9 08 01 00 00       	jmp    80106f04 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80106dff:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106e02:	8b 45 08             	mov    0x8(%ebp),%eax
80106e05:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e08:	0f b7 d8             	movzwl %ax,%ebx
80106e0b:	e8 a6 d4 ff ff       	call   801042b6 <cpuid>
80106e10:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106e14:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106e18:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e1c:	c7 04 24 cc 94 10 80 	movl   $0x801094cc,(%esp)
80106e23:	e8 99 95 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106e28:	e8 2a c3 ff ff       	call   80103157 <lapiceoi>
    break;
80106e2d:	e9 d2 00 00 00       	jmp    80106f04 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e32:	e8 48 d5 ff ff       	call   8010437f <myproc>
80106e37:	85 c0                	test   %eax,%eax
80106e39:	74 10                	je     80106e4b <trap+0x146>
80106e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e3e:	8b 40 3c             	mov    0x3c(%eax),%eax
80106e41:	0f b7 c0             	movzwl %ax,%eax
80106e44:	83 e0 03             	and    $0x3,%eax
80106e47:	85 c0                	test   %eax,%eax
80106e49:	75 40                	jne    80106e8b <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e4b:	e8 2b fd ff ff       	call   80106b7b <rcr2>
80106e50:	89 c3                	mov    %eax,%ebx
80106e52:	8b 45 08             	mov    0x8(%ebp),%eax
80106e55:	8b 70 38             	mov    0x38(%eax),%esi
80106e58:	e8 59 d4 ff ff       	call   801042b6 <cpuid>
80106e5d:	8b 55 08             	mov    0x8(%ebp),%edx
80106e60:	8b 52 30             	mov    0x30(%edx),%edx
80106e63:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106e67:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106e6b:	89 44 24 08          	mov    %eax,0x8(%esp)
80106e6f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e73:	c7 04 24 f0 94 10 80 	movl   $0x801094f0,(%esp)
80106e7a:	e8 42 95 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e7f:	c7 04 24 22 95 10 80 	movl   $0x80109522,(%esp)
80106e86:	e8 c9 96 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e8b:	e8 eb fc ff ff       	call   80106b7b <rcr2>
80106e90:	89 c6                	mov    %eax,%esi
80106e92:	8b 45 08             	mov    0x8(%ebp),%eax
80106e95:	8b 40 38             	mov    0x38(%eax),%eax
80106e98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e9b:	e8 16 d4 ff ff       	call   801042b6 <cpuid>
80106ea0:	89 c3                	mov    %eax,%ebx
80106ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea5:	8b 78 34             	mov    0x34(%eax),%edi
80106ea8:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106eab:	8b 45 08             	mov    0x8(%ebp),%eax
80106eae:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106eb1:	e8 c9 d4 ff ff       	call   8010437f <myproc>
80106eb6:	8d 50 6c             	lea    0x6c(%eax),%edx
80106eb9:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106ebc:	e8 be d4 ff ff       	call   8010437f <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ec1:	8b 40 10             	mov    0x10(%eax),%eax
80106ec4:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106ec8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106ecb:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106ecf:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106ed3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106ed6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106eda:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106ede:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106ee1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ee9:	c7 04 24 28 95 10 80 	movl   $0x80109528,(%esp)
80106ef0:	e8 cc 94 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ef5:	e8 85 d4 ff ff       	call   8010437f <myproc>
80106efa:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f01:	eb 01                	jmp    80106f04 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106f03:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f04:	e8 76 d4 ff ff       	call   8010437f <myproc>
80106f09:	85 c0                	test   %eax,%eax
80106f0b:	74 22                	je     80106f2f <trap+0x22a>
80106f0d:	e8 6d d4 ff ff       	call   8010437f <myproc>
80106f12:	8b 40 24             	mov    0x24(%eax),%eax
80106f15:	85 c0                	test   %eax,%eax
80106f17:	74 16                	je     80106f2f <trap+0x22a>
80106f19:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1c:	8b 40 3c             	mov    0x3c(%eax),%eax
80106f1f:	0f b7 c0             	movzwl %ax,%eax
80106f22:	83 e0 03             	and    $0x3,%eax
80106f25:	83 f8 03             	cmp    $0x3,%eax
80106f28:	75 05                	jne    80106f2f <trap+0x22a>
    exit();
80106f2a:	e8 e1 d8 ff ff       	call   80104810 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f2f:	e8 4b d4 ff ff       	call   8010437f <myproc>
80106f34:	85 c0                	test   %eax,%eax
80106f36:	74 1d                	je     80106f55 <trap+0x250>
80106f38:	e8 42 d4 ff ff       	call   8010437f <myproc>
80106f3d:	8b 40 0c             	mov    0xc(%eax),%eax
80106f40:	83 f8 04             	cmp    $0x4,%eax
80106f43:	75 10                	jne    80106f55 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f45:	8b 45 08             	mov    0x8(%ebp),%eax
80106f48:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f4b:	83 f8 20             	cmp    $0x20,%eax
80106f4e:	75 05                	jne    80106f55 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106f50:	e8 33 dc ff ff       	call   80104b88 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f55:	e8 25 d4 ff ff       	call   8010437f <myproc>
80106f5a:	85 c0                	test   %eax,%eax
80106f5c:	74 22                	je     80106f80 <trap+0x27b>
80106f5e:	e8 1c d4 ff ff       	call   8010437f <myproc>
80106f63:	8b 40 24             	mov    0x24(%eax),%eax
80106f66:	85 c0                	test   %eax,%eax
80106f68:	74 16                	je     80106f80 <trap+0x27b>
80106f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f6d:	8b 40 3c             	mov    0x3c(%eax),%eax
80106f70:	0f b7 c0             	movzwl %ax,%eax
80106f73:	83 e0 03             	and    $0x3,%eax
80106f76:	83 f8 03             	cmp    $0x3,%eax
80106f79:	75 05                	jne    80106f80 <trap+0x27b>
    exit();
80106f7b:	e8 90 d8 ff ff       	call   80104810 <exit>
}
80106f80:	83 c4 4c             	add    $0x4c,%esp
80106f83:	5b                   	pop    %ebx
80106f84:	5e                   	pop    %esi
80106f85:	5f                   	pop    %edi
80106f86:	5d                   	pop    %ebp
80106f87:	c3                   	ret    

80106f88 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106f88:	55                   	push   %ebp
80106f89:	89 e5                	mov    %esp,%ebp
80106f8b:	83 ec 14             	sub    $0x14,%esp
80106f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f91:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f98:	89 c2                	mov    %eax,%edx
80106f9a:	ec                   	in     (%dx),%al
80106f9b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f9e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106fa1:	c9                   	leave  
80106fa2:	c3                   	ret    

80106fa3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106fa3:	55                   	push   %ebp
80106fa4:	89 e5                	mov    %esp,%ebp
80106fa6:	83 ec 08             	sub    $0x8,%esp
80106fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80106fac:	8b 55 0c             	mov    0xc(%ebp),%edx
80106faf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106fb3:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106fb6:	8a 45 f8             	mov    -0x8(%ebp),%al
80106fb9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fbc:	ee                   	out    %al,(%dx)
}
80106fbd:	c9                   	leave  
80106fbe:	c3                   	ret    

80106fbf <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fbf:	55                   	push   %ebp
80106fc0:	89 e5                	mov    %esp,%ebp
80106fc2:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fcc:	00 
80106fcd:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106fd4:	e8 ca ff ff ff       	call   80106fa3 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fd9:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106fe0:	00 
80106fe1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106fe8:	e8 b6 ff ff ff       	call   80106fa3 <outb>
  outb(COM1+0, 115200/9600);
80106fed:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106ff4:	00 
80106ff5:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ffc:	e8 a2 ff ff ff       	call   80106fa3 <outb>
  outb(COM1+1, 0);
80107001:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107008:	00 
80107009:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107010:	e8 8e ff ff ff       	call   80106fa3 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107015:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010701c:	00 
8010701d:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107024:	e8 7a ff ff ff       	call   80106fa3 <outb>
  outb(COM1+4, 0);
80107029:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107030:	00 
80107031:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107038:	e8 66 ff ff ff       	call   80106fa3 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010703d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107044:	00 
80107045:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010704c:	e8 52 ff ff ff       	call   80106fa3 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107051:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107058:	e8 2b ff ff ff       	call   80106f88 <inb>
8010705d:	3c ff                	cmp    $0xff,%al
8010705f:	75 02                	jne    80107063 <uartinit+0xa4>
    return;
80107061:	eb 5b                	jmp    801070be <uartinit+0xff>
  uart = 1;
80107063:	c7 05 04 c9 10 80 01 	movl   $0x1,0x8010c904
8010706a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010706d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107074:	e8 0f ff ff ff       	call   80106f88 <inb>
  inb(COM1+0);
80107079:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107080:	e8 03 ff ff ff       	call   80106f88 <inb>
  ioapicenable(IRQ_COM1, 0);
80107085:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010708c:	00 
8010708d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107094:	e8 ee ba ff ff       	call   80102b87 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107099:	c7 45 f4 ec 95 10 80 	movl   $0x801095ec,-0xc(%ebp)
801070a0:	eb 13                	jmp    801070b5 <uartinit+0xf6>
    uartputc(*p);
801070a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a5:	8a 00                	mov    (%eax),%al
801070a7:	0f be c0             	movsbl %al,%eax
801070aa:	89 04 24             	mov    %eax,(%esp)
801070ad:	e8 0e 00 00 00       	call   801070c0 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070b2:	ff 45 f4             	incl   -0xc(%ebp)
801070b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b8:	8a 00                	mov    (%eax),%al
801070ba:	84 c0                	test   %al,%al
801070bc:	75 e4                	jne    801070a2 <uartinit+0xe3>
    uartputc(*p);
}
801070be:	c9                   	leave  
801070bf:	c3                   	ret    

801070c0 <uartputc>:

void
uartputc(int c)
{
801070c0:	55                   	push   %ebp
801070c1:	89 e5                	mov    %esp,%ebp
801070c3:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801070c6:	a1 04 c9 10 80       	mov    0x8010c904,%eax
801070cb:	85 c0                	test   %eax,%eax
801070cd:	75 02                	jne    801070d1 <uartputc+0x11>
    return;
801070cf:	eb 4a                	jmp    8010711b <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070d8:	eb 0f                	jmp    801070e9 <uartputc+0x29>
    microdelay(10);
801070da:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801070e1:	e8 96 c0 ff ff       	call   8010317c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070e6:	ff 45 f4             	incl   -0xc(%ebp)
801070e9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070ed:	7f 16                	jg     80107105 <uartputc+0x45>
801070ef:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070f6:	e8 8d fe ff ff       	call   80106f88 <inb>
801070fb:	0f b6 c0             	movzbl %al,%eax
801070fe:	83 e0 20             	and    $0x20,%eax
80107101:	85 c0                	test   %eax,%eax
80107103:	74 d5                	je     801070da <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107105:	8b 45 08             	mov    0x8(%ebp),%eax
80107108:	0f b6 c0             	movzbl %al,%eax
8010710b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010710f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107116:	e8 88 fe ff ff       	call   80106fa3 <outb>
}
8010711b:	c9                   	leave  
8010711c:	c3                   	ret    

8010711d <uartgetc>:

static int
uartgetc(void)
{
8010711d:	55                   	push   %ebp
8010711e:	89 e5                	mov    %esp,%ebp
80107120:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107123:	a1 04 c9 10 80       	mov    0x8010c904,%eax
80107128:	85 c0                	test   %eax,%eax
8010712a:	75 07                	jne    80107133 <uartgetc+0x16>
    return -1;
8010712c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107131:	eb 2c                	jmp    8010715f <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107133:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010713a:	e8 49 fe ff ff       	call   80106f88 <inb>
8010713f:	0f b6 c0             	movzbl %al,%eax
80107142:	83 e0 01             	and    $0x1,%eax
80107145:	85 c0                	test   %eax,%eax
80107147:	75 07                	jne    80107150 <uartgetc+0x33>
    return -1;
80107149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010714e:	eb 0f                	jmp    8010715f <uartgetc+0x42>
  return inb(COM1+0);
80107150:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107157:	e8 2c fe ff ff       	call   80106f88 <inb>
8010715c:	0f b6 c0             	movzbl %al,%eax
}
8010715f:	c9                   	leave  
80107160:	c3                   	ret    

80107161 <uartintr>:

void
uartintr(void)
{
80107161:	55                   	push   %ebp
80107162:	89 e5                	mov    %esp,%ebp
80107164:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107167:	c7 04 24 1d 71 10 80 	movl   $0x8010711d,(%esp)
8010716e:	e8 82 96 ff ff       	call   801007f5 <consoleintr>
}
80107173:	c9                   	leave  
80107174:	c3                   	ret    
80107175:	00 00                	add    %al,(%eax)
	...

80107178 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $0
8010717a:	6a 00                	push   $0x0
  jmp alltraps
8010717c:	e9 af f9 ff ff       	jmp    80106b30 <alltraps>

80107181 <vector1>:
.globl vector1
vector1:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $1
80107183:	6a 01                	push   $0x1
  jmp alltraps
80107185:	e9 a6 f9 ff ff       	jmp    80106b30 <alltraps>

8010718a <vector2>:
.globl vector2
vector2:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $2
8010718c:	6a 02                	push   $0x2
  jmp alltraps
8010718e:	e9 9d f9 ff ff       	jmp    80106b30 <alltraps>

80107193 <vector3>:
.globl vector3
vector3:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $3
80107195:	6a 03                	push   $0x3
  jmp alltraps
80107197:	e9 94 f9 ff ff       	jmp    80106b30 <alltraps>

8010719c <vector4>:
.globl vector4
vector4:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $4
8010719e:	6a 04                	push   $0x4
  jmp alltraps
801071a0:	e9 8b f9 ff ff       	jmp    80106b30 <alltraps>

801071a5 <vector5>:
.globl vector5
vector5:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $5
801071a7:	6a 05                	push   $0x5
  jmp alltraps
801071a9:	e9 82 f9 ff ff       	jmp    80106b30 <alltraps>

801071ae <vector6>:
.globl vector6
vector6:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $6
801071b0:	6a 06                	push   $0x6
  jmp alltraps
801071b2:	e9 79 f9 ff ff       	jmp    80106b30 <alltraps>

801071b7 <vector7>:
.globl vector7
vector7:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $7
801071b9:	6a 07                	push   $0x7
  jmp alltraps
801071bb:	e9 70 f9 ff ff       	jmp    80106b30 <alltraps>

801071c0 <vector8>:
.globl vector8
vector8:
  pushl $8
801071c0:	6a 08                	push   $0x8
  jmp alltraps
801071c2:	e9 69 f9 ff ff       	jmp    80106b30 <alltraps>

801071c7 <vector9>:
.globl vector9
vector9:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $9
801071c9:	6a 09                	push   $0x9
  jmp alltraps
801071cb:	e9 60 f9 ff ff       	jmp    80106b30 <alltraps>

801071d0 <vector10>:
.globl vector10
vector10:
  pushl $10
801071d0:	6a 0a                	push   $0xa
  jmp alltraps
801071d2:	e9 59 f9 ff ff       	jmp    80106b30 <alltraps>

801071d7 <vector11>:
.globl vector11
vector11:
  pushl $11
801071d7:	6a 0b                	push   $0xb
  jmp alltraps
801071d9:	e9 52 f9 ff ff       	jmp    80106b30 <alltraps>

801071de <vector12>:
.globl vector12
vector12:
  pushl $12
801071de:	6a 0c                	push   $0xc
  jmp alltraps
801071e0:	e9 4b f9 ff ff       	jmp    80106b30 <alltraps>

801071e5 <vector13>:
.globl vector13
vector13:
  pushl $13
801071e5:	6a 0d                	push   $0xd
  jmp alltraps
801071e7:	e9 44 f9 ff ff       	jmp    80106b30 <alltraps>

801071ec <vector14>:
.globl vector14
vector14:
  pushl $14
801071ec:	6a 0e                	push   $0xe
  jmp alltraps
801071ee:	e9 3d f9 ff ff       	jmp    80106b30 <alltraps>

801071f3 <vector15>:
.globl vector15
vector15:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $15
801071f5:	6a 0f                	push   $0xf
  jmp alltraps
801071f7:	e9 34 f9 ff ff       	jmp    80106b30 <alltraps>

801071fc <vector16>:
.globl vector16
vector16:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $16
801071fe:	6a 10                	push   $0x10
  jmp alltraps
80107200:	e9 2b f9 ff ff       	jmp    80106b30 <alltraps>

80107205 <vector17>:
.globl vector17
vector17:
  pushl $17
80107205:	6a 11                	push   $0x11
  jmp alltraps
80107207:	e9 24 f9 ff ff       	jmp    80106b30 <alltraps>

8010720c <vector18>:
.globl vector18
vector18:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $18
8010720e:	6a 12                	push   $0x12
  jmp alltraps
80107210:	e9 1b f9 ff ff       	jmp    80106b30 <alltraps>

80107215 <vector19>:
.globl vector19
vector19:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $19
80107217:	6a 13                	push   $0x13
  jmp alltraps
80107219:	e9 12 f9 ff ff       	jmp    80106b30 <alltraps>

8010721e <vector20>:
.globl vector20
vector20:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $20
80107220:	6a 14                	push   $0x14
  jmp alltraps
80107222:	e9 09 f9 ff ff       	jmp    80106b30 <alltraps>

80107227 <vector21>:
.globl vector21
vector21:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $21
80107229:	6a 15                	push   $0x15
  jmp alltraps
8010722b:	e9 00 f9 ff ff       	jmp    80106b30 <alltraps>

80107230 <vector22>:
.globl vector22
vector22:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $22
80107232:	6a 16                	push   $0x16
  jmp alltraps
80107234:	e9 f7 f8 ff ff       	jmp    80106b30 <alltraps>

80107239 <vector23>:
.globl vector23
vector23:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $23
8010723b:	6a 17                	push   $0x17
  jmp alltraps
8010723d:	e9 ee f8 ff ff       	jmp    80106b30 <alltraps>

80107242 <vector24>:
.globl vector24
vector24:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $24
80107244:	6a 18                	push   $0x18
  jmp alltraps
80107246:	e9 e5 f8 ff ff       	jmp    80106b30 <alltraps>

8010724b <vector25>:
.globl vector25
vector25:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $25
8010724d:	6a 19                	push   $0x19
  jmp alltraps
8010724f:	e9 dc f8 ff ff       	jmp    80106b30 <alltraps>

80107254 <vector26>:
.globl vector26
vector26:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $26
80107256:	6a 1a                	push   $0x1a
  jmp alltraps
80107258:	e9 d3 f8 ff ff       	jmp    80106b30 <alltraps>

8010725d <vector27>:
.globl vector27
vector27:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $27
8010725f:	6a 1b                	push   $0x1b
  jmp alltraps
80107261:	e9 ca f8 ff ff       	jmp    80106b30 <alltraps>

80107266 <vector28>:
.globl vector28
vector28:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $28
80107268:	6a 1c                	push   $0x1c
  jmp alltraps
8010726a:	e9 c1 f8 ff ff       	jmp    80106b30 <alltraps>

8010726f <vector29>:
.globl vector29
vector29:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $29
80107271:	6a 1d                	push   $0x1d
  jmp alltraps
80107273:	e9 b8 f8 ff ff       	jmp    80106b30 <alltraps>

80107278 <vector30>:
.globl vector30
vector30:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $30
8010727a:	6a 1e                	push   $0x1e
  jmp alltraps
8010727c:	e9 af f8 ff ff       	jmp    80106b30 <alltraps>

80107281 <vector31>:
.globl vector31
vector31:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $31
80107283:	6a 1f                	push   $0x1f
  jmp alltraps
80107285:	e9 a6 f8 ff ff       	jmp    80106b30 <alltraps>

8010728a <vector32>:
.globl vector32
vector32:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $32
8010728c:	6a 20                	push   $0x20
  jmp alltraps
8010728e:	e9 9d f8 ff ff       	jmp    80106b30 <alltraps>

80107293 <vector33>:
.globl vector33
vector33:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $33
80107295:	6a 21                	push   $0x21
  jmp alltraps
80107297:	e9 94 f8 ff ff       	jmp    80106b30 <alltraps>

8010729c <vector34>:
.globl vector34
vector34:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $34
8010729e:	6a 22                	push   $0x22
  jmp alltraps
801072a0:	e9 8b f8 ff ff       	jmp    80106b30 <alltraps>

801072a5 <vector35>:
.globl vector35
vector35:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $35
801072a7:	6a 23                	push   $0x23
  jmp alltraps
801072a9:	e9 82 f8 ff ff       	jmp    80106b30 <alltraps>

801072ae <vector36>:
.globl vector36
vector36:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $36
801072b0:	6a 24                	push   $0x24
  jmp alltraps
801072b2:	e9 79 f8 ff ff       	jmp    80106b30 <alltraps>

801072b7 <vector37>:
.globl vector37
vector37:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $37
801072b9:	6a 25                	push   $0x25
  jmp alltraps
801072bb:	e9 70 f8 ff ff       	jmp    80106b30 <alltraps>

801072c0 <vector38>:
.globl vector38
vector38:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $38
801072c2:	6a 26                	push   $0x26
  jmp alltraps
801072c4:	e9 67 f8 ff ff       	jmp    80106b30 <alltraps>

801072c9 <vector39>:
.globl vector39
vector39:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $39
801072cb:	6a 27                	push   $0x27
  jmp alltraps
801072cd:	e9 5e f8 ff ff       	jmp    80106b30 <alltraps>

801072d2 <vector40>:
.globl vector40
vector40:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $40
801072d4:	6a 28                	push   $0x28
  jmp alltraps
801072d6:	e9 55 f8 ff ff       	jmp    80106b30 <alltraps>

801072db <vector41>:
.globl vector41
vector41:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $41
801072dd:	6a 29                	push   $0x29
  jmp alltraps
801072df:	e9 4c f8 ff ff       	jmp    80106b30 <alltraps>

801072e4 <vector42>:
.globl vector42
vector42:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $42
801072e6:	6a 2a                	push   $0x2a
  jmp alltraps
801072e8:	e9 43 f8 ff ff       	jmp    80106b30 <alltraps>

801072ed <vector43>:
.globl vector43
vector43:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $43
801072ef:	6a 2b                	push   $0x2b
  jmp alltraps
801072f1:	e9 3a f8 ff ff       	jmp    80106b30 <alltraps>

801072f6 <vector44>:
.globl vector44
vector44:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $44
801072f8:	6a 2c                	push   $0x2c
  jmp alltraps
801072fa:	e9 31 f8 ff ff       	jmp    80106b30 <alltraps>

801072ff <vector45>:
.globl vector45
vector45:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $45
80107301:	6a 2d                	push   $0x2d
  jmp alltraps
80107303:	e9 28 f8 ff ff       	jmp    80106b30 <alltraps>

80107308 <vector46>:
.globl vector46
vector46:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $46
8010730a:	6a 2e                	push   $0x2e
  jmp alltraps
8010730c:	e9 1f f8 ff ff       	jmp    80106b30 <alltraps>

80107311 <vector47>:
.globl vector47
vector47:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $47
80107313:	6a 2f                	push   $0x2f
  jmp alltraps
80107315:	e9 16 f8 ff ff       	jmp    80106b30 <alltraps>

8010731a <vector48>:
.globl vector48
vector48:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $48
8010731c:	6a 30                	push   $0x30
  jmp alltraps
8010731e:	e9 0d f8 ff ff       	jmp    80106b30 <alltraps>

80107323 <vector49>:
.globl vector49
vector49:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $49
80107325:	6a 31                	push   $0x31
  jmp alltraps
80107327:	e9 04 f8 ff ff       	jmp    80106b30 <alltraps>

8010732c <vector50>:
.globl vector50
vector50:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $50
8010732e:	6a 32                	push   $0x32
  jmp alltraps
80107330:	e9 fb f7 ff ff       	jmp    80106b30 <alltraps>

80107335 <vector51>:
.globl vector51
vector51:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $51
80107337:	6a 33                	push   $0x33
  jmp alltraps
80107339:	e9 f2 f7 ff ff       	jmp    80106b30 <alltraps>

8010733e <vector52>:
.globl vector52
vector52:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $52
80107340:	6a 34                	push   $0x34
  jmp alltraps
80107342:	e9 e9 f7 ff ff       	jmp    80106b30 <alltraps>

80107347 <vector53>:
.globl vector53
vector53:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $53
80107349:	6a 35                	push   $0x35
  jmp alltraps
8010734b:	e9 e0 f7 ff ff       	jmp    80106b30 <alltraps>

80107350 <vector54>:
.globl vector54
vector54:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $54
80107352:	6a 36                	push   $0x36
  jmp alltraps
80107354:	e9 d7 f7 ff ff       	jmp    80106b30 <alltraps>

80107359 <vector55>:
.globl vector55
vector55:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $55
8010735b:	6a 37                	push   $0x37
  jmp alltraps
8010735d:	e9 ce f7 ff ff       	jmp    80106b30 <alltraps>

80107362 <vector56>:
.globl vector56
vector56:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $56
80107364:	6a 38                	push   $0x38
  jmp alltraps
80107366:	e9 c5 f7 ff ff       	jmp    80106b30 <alltraps>

8010736b <vector57>:
.globl vector57
vector57:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $57
8010736d:	6a 39                	push   $0x39
  jmp alltraps
8010736f:	e9 bc f7 ff ff       	jmp    80106b30 <alltraps>

80107374 <vector58>:
.globl vector58
vector58:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $58
80107376:	6a 3a                	push   $0x3a
  jmp alltraps
80107378:	e9 b3 f7 ff ff       	jmp    80106b30 <alltraps>

8010737d <vector59>:
.globl vector59
vector59:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $59
8010737f:	6a 3b                	push   $0x3b
  jmp alltraps
80107381:	e9 aa f7 ff ff       	jmp    80106b30 <alltraps>

80107386 <vector60>:
.globl vector60
vector60:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $60
80107388:	6a 3c                	push   $0x3c
  jmp alltraps
8010738a:	e9 a1 f7 ff ff       	jmp    80106b30 <alltraps>

8010738f <vector61>:
.globl vector61
vector61:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $61
80107391:	6a 3d                	push   $0x3d
  jmp alltraps
80107393:	e9 98 f7 ff ff       	jmp    80106b30 <alltraps>

80107398 <vector62>:
.globl vector62
vector62:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $62
8010739a:	6a 3e                	push   $0x3e
  jmp alltraps
8010739c:	e9 8f f7 ff ff       	jmp    80106b30 <alltraps>

801073a1 <vector63>:
.globl vector63
vector63:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $63
801073a3:	6a 3f                	push   $0x3f
  jmp alltraps
801073a5:	e9 86 f7 ff ff       	jmp    80106b30 <alltraps>

801073aa <vector64>:
.globl vector64
vector64:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $64
801073ac:	6a 40                	push   $0x40
  jmp alltraps
801073ae:	e9 7d f7 ff ff       	jmp    80106b30 <alltraps>

801073b3 <vector65>:
.globl vector65
vector65:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $65
801073b5:	6a 41                	push   $0x41
  jmp alltraps
801073b7:	e9 74 f7 ff ff       	jmp    80106b30 <alltraps>

801073bc <vector66>:
.globl vector66
vector66:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $66
801073be:	6a 42                	push   $0x42
  jmp alltraps
801073c0:	e9 6b f7 ff ff       	jmp    80106b30 <alltraps>

801073c5 <vector67>:
.globl vector67
vector67:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $67
801073c7:	6a 43                	push   $0x43
  jmp alltraps
801073c9:	e9 62 f7 ff ff       	jmp    80106b30 <alltraps>

801073ce <vector68>:
.globl vector68
vector68:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $68
801073d0:	6a 44                	push   $0x44
  jmp alltraps
801073d2:	e9 59 f7 ff ff       	jmp    80106b30 <alltraps>

801073d7 <vector69>:
.globl vector69
vector69:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $69
801073d9:	6a 45                	push   $0x45
  jmp alltraps
801073db:	e9 50 f7 ff ff       	jmp    80106b30 <alltraps>

801073e0 <vector70>:
.globl vector70
vector70:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $70
801073e2:	6a 46                	push   $0x46
  jmp alltraps
801073e4:	e9 47 f7 ff ff       	jmp    80106b30 <alltraps>

801073e9 <vector71>:
.globl vector71
vector71:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $71
801073eb:	6a 47                	push   $0x47
  jmp alltraps
801073ed:	e9 3e f7 ff ff       	jmp    80106b30 <alltraps>

801073f2 <vector72>:
.globl vector72
vector72:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $72
801073f4:	6a 48                	push   $0x48
  jmp alltraps
801073f6:	e9 35 f7 ff ff       	jmp    80106b30 <alltraps>

801073fb <vector73>:
.globl vector73
vector73:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $73
801073fd:	6a 49                	push   $0x49
  jmp alltraps
801073ff:	e9 2c f7 ff ff       	jmp    80106b30 <alltraps>

80107404 <vector74>:
.globl vector74
vector74:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $74
80107406:	6a 4a                	push   $0x4a
  jmp alltraps
80107408:	e9 23 f7 ff ff       	jmp    80106b30 <alltraps>

8010740d <vector75>:
.globl vector75
vector75:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $75
8010740f:	6a 4b                	push   $0x4b
  jmp alltraps
80107411:	e9 1a f7 ff ff       	jmp    80106b30 <alltraps>

80107416 <vector76>:
.globl vector76
vector76:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $76
80107418:	6a 4c                	push   $0x4c
  jmp alltraps
8010741a:	e9 11 f7 ff ff       	jmp    80106b30 <alltraps>

8010741f <vector77>:
.globl vector77
vector77:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $77
80107421:	6a 4d                	push   $0x4d
  jmp alltraps
80107423:	e9 08 f7 ff ff       	jmp    80106b30 <alltraps>

80107428 <vector78>:
.globl vector78
vector78:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $78
8010742a:	6a 4e                	push   $0x4e
  jmp alltraps
8010742c:	e9 ff f6 ff ff       	jmp    80106b30 <alltraps>

80107431 <vector79>:
.globl vector79
vector79:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $79
80107433:	6a 4f                	push   $0x4f
  jmp alltraps
80107435:	e9 f6 f6 ff ff       	jmp    80106b30 <alltraps>

8010743a <vector80>:
.globl vector80
vector80:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $80
8010743c:	6a 50                	push   $0x50
  jmp alltraps
8010743e:	e9 ed f6 ff ff       	jmp    80106b30 <alltraps>

80107443 <vector81>:
.globl vector81
vector81:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $81
80107445:	6a 51                	push   $0x51
  jmp alltraps
80107447:	e9 e4 f6 ff ff       	jmp    80106b30 <alltraps>

8010744c <vector82>:
.globl vector82
vector82:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $82
8010744e:	6a 52                	push   $0x52
  jmp alltraps
80107450:	e9 db f6 ff ff       	jmp    80106b30 <alltraps>

80107455 <vector83>:
.globl vector83
vector83:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $83
80107457:	6a 53                	push   $0x53
  jmp alltraps
80107459:	e9 d2 f6 ff ff       	jmp    80106b30 <alltraps>

8010745e <vector84>:
.globl vector84
vector84:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $84
80107460:	6a 54                	push   $0x54
  jmp alltraps
80107462:	e9 c9 f6 ff ff       	jmp    80106b30 <alltraps>

80107467 <vector85>:
.globl vector85
vector85:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $85
80107469:	6a 55                	push   $0x55
  jmp alltraps
8010746b:	e9 c0 f6 ff ff       	jmp    80106b30 <alltraps>

80107470 <vector86>:
.globl vector86
vector86:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $86
80107472:	6a 56                	push   $0x56
  jmp alltraps
80107474:	e9 b7 f6 ff ff       	jmp    80106b30 <alltraps>

80107479 <vector87>:
.globl vector87
vector87:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $87
8010747b:	6a 57                	push   $0x57
  jmp alltraps
8010747d:	e9 ae f6 ff ff       	jmp    80106b30 <alltraps>

80107482 <vector88>:
.globl vector88
vector88:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $88
80107484:	6a 58                	push   $0x58
  jmp alltraps
80107486:	e9 a5 f6 ff ff       	jmp    80106b30 <alltraps>

8010748b <vector89>:
.globl vector89
vector89:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $89
8010748d:	6a 59                	push   $0x59
  jmp alltraps
8010748f:	e9 9c f6 ff ff       	jmp    80106b30 <alltraps>

80107494 <vector90>:
.globl vector90
vector90:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $90
80107496:	6a 5a                	push   $0x5a
  jmp alltraps
80107498:	e9 93 f6 ff ff       	jmp    80106b30 <alltraps>

8010749d <vector91>:
.globl vector91
vector91:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $91
8010749f:	6a 5b                	push   $0x5b
  jmp alltraps
801074a1:	e9 8a f6 ff ff       	jmp    80106b30 <alltraps>

801074a6 <vector92>:
.globl vector92
vector92:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $92
801074a8:	6a 5c                	push   $0x5c
  jmp alltraps
801074aa:	e9 81 f6 ff ff       	jmp    80106b30 <alltraps>

801074af <vector93>:
.globl vector93
vector93:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $93
801074b1:	6a 5d                	push   $0x5d
  jmp alltraps
801074b3:	e9 78 f6 ff ff       	jmp    80106b30 <alltraps>

801074b8 <vector94>:
.globl vector94
vector94:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $94
801074ba:	6a 5e                	push   $0x5e
  jmp alltraps
801074bc:	e9 6f f6 ff ff       	jmp    80106b30 <alltraps>

801074c1 <vector95>:
.globl vector95
vector95:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $95
801074c3:	6a 5f                	push   $0x5f
  jmp alltraps
801074c5:	e9 66 f6 ff ff       	jmp    80106b30 <alltraps>

801074ca <vector96>:
.globl vector96
vector96:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $96
801074cc:	6a 60                	push   $0x60
  jmp alltraps
801074ce:	e9 5d f6 ff ff       	jmp    80106b30 <alltraps>

801074d3 <vector97>:
.globl vector97
vector97:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $97
801074d5:	6a 61                	push   $0x61
  jmp alltraps
801074d7:	e9 54 f6 ff ff       	jmp    80106b30 <alltraps>

801074dc <vector98>:
.globl vector98
vector98:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $98
801074de:	6a 62                	push   $0x62
  jmp alltraps
801074e0:	e9 4b f6 ff ff       	jmp    80106b30 <alltraps>

801074e5 <vector99>:
.globl vector99
vector99:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $99
801074e7:	6a 63                	push   $0x63
  jmp alltraps
801074e9:	e9 42 f6 ff ff       	jmp    80106b30 <alltraps>

801074ee <vector100>:
.globl vector100
vector100:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $100
801074f0:	6a 64                	push   $0x64
  jmp alltraps
801074f2:	e9 39 f6 ff ff       	jmp    80106b30 <alltraps>

801074f7 <vector101>:
.globl vector101
vector101:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $101
801074f9:	6a 65                	push   $0x65
  jmp alltraps
801074fb:	e9 30 f6 ff ff       	jmp    80106b30 <alltraps>

80107500 <vector102>:
.globl vector102
vector102:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $102
80107502:	6a 66                	push   $0x66
  jmp alltraps
80107504:	e9 27 f6 ff ff       	jmp    80106b30 <alltraps>

80107509 <vector103>:
.globl vector103
vector103:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $103
8010750b:	6a 67                	push   $0x67
  jmp alltraps
8010750d:	e9 1e f6 ff ff       	jmp    80106b30 <alltraps>

80107512 <vector104>:
.globl vector104
vector104:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $104
80107514:	6a 68                	push   $0x68
  jmp alltraps
80107516:	e9 15 f6 ff ff       	jmp    80106b30 <alltraps>

8010751b <vector105>:
.globl vector105
vector105:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $105
8010751d:	6a 69                	push   $0x69
  jmp alltraps
8010751f:	e9 0c f6 ff ff       	jmp    80106b30 <alltraps>

80107524 <vector106>:
.globl vector106
vector106:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $106
80107526:	6a 6a                	push   $0x6a
  jmp alltraps
80107528:	e9 03 f6 ff ff       	jmp    80106b30 <alltraps>

8010752d <vector107>:
.globl vector107
vector107:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $107
8010752f:	6a 6b                	push   $0x6b
  jmp alltraps
80107531:	e9 fa f5 ff ff       	jmp    80106b30 <alltraps>

80107536 <vector108>:
.globl vector108
vector108:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $108
80107538:	6a 6c                	push   $0x6c
  jmp alltraps
8010753a:	e9 f1 f5 ff ff       	jmp    80106b30 <alltraps>

8010753f <vector109>:
.globl vector109
vector109:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $109
80107541:	6a 6d                	push   $0x6d
  jmp alltraps
80107543:	e9 e8 f5 ff ff       	jmp    80106b30 <alltraps>

80107548 <vector110>:
.globl vector110
vector110:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $110
8010754a:	6a 6e                	push   $0x6e
  jmp alltraps
8010754c:	e9 df f5 ff ff       	jmp    80106b30 <alltraps>

80107551 <vector111>:
.globl vector111
vector111:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $111
80107553:	6a 6f                	push   $0x6f
  jmp alltraps
80107555:	e9 d6 f5 ff ff       	jmp    80106b30 <alltraps>

8010755a <vector112>:
.globl vector112
vector112:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $112
8010755c:	6a 70                	push   $0x70
  jmp alltraps
8010755e:	e9 cd f5 ff ff       	jmp    80106b30 <alltraps>

80107563 <vector113>:
.globl vector113
vector113:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $113
80107565:	6a 71                	push   $0x71
  jmp alltraps
80107567:	e9 c4 f5 ff ff       	jmp    80106b30 <alltraps>

8010756c <vector114>:
.globl vector114
vector114:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $114
8010756e:	6a 72                	push   $0x72
  jmp alltraps
80107570:	e9 bb f5 ff ff       	jmp    80106b30 <alltraps>

80107575 <vector115>:
.globl vector115
vector115:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $115
80107577:	6a 73                	push   $0x73
  jmp alltraps
80107579:	e9 b2 f5 ff ff       	jmp    80106b30 <alltraps>

8010757e <vector116>:
.globl vector116
vector116:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $116
80107580:	6a 74                	push   $0x74
  jmp alltraps
80107582:	e9 a9 f5 ff ff       	jmp    80106b30 <alltraps>

80107587 <vector117>:
.globl vector117
vector117:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $117
80107589:	6a 75                	push   $0x75
  jmp alltraps
8010758b:	e9 a0 f5 ff ff       	jmp    80106b30 <alltraps>

80107590 <vector118>:
.globl vector118
vector118:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $118
80107592:	6a 76                	push   $0x76
  jmp alltraps
80107594:	e9 97 f5 ff ff       	jmp    80106b30 <alltraps>

80107599 <vector119>:
.globl vector119
vector119:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $119
8010759b:	6a 77                	push   $0x77
  jmp alltraps
8010759d:	e9 8e f5 ff ff       	jmp    80106b30 <alltraps>

801075a2 <vector120>:
.globl vector120
vector120:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $120
801075a4:	6a 78                	push   $0x78
  jmp alltraps
801075a6:	e9 85 f5 ff ff       	jmp    80106b30 <alltraps>

801075ab <vector121>:
.globl vector121
vector121:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $121
801075ad:	6a 79                	push   $0x79
  jmp alltraps
801075af:	e9 7c f5 ff ff       	jmp    80106b30 <alltraps>

801075b4 <vector122>:
.globl vector122
vector122:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $122
801075b6:	6a 7a                	push   $0x7a
  jmp alltraps
801075b8:	e9 73 f5 ff ff       	jmp    80106b30 <alltraps>

801075bd <vector123>:
.globl vector123
vector123:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $123
801075bf:	6a 7b                	push   $0x7b
  jmp alltraps
801075c1:	e9 6a f5 ff ff       	jmp    80106b30 <alltraps>

801075c6 <vector124>:
.globl vector124
vector124:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $124
801075c8:	6a 7c                	push   $0x7c
  jmp alltraps
801075ca:	e9 61 f5 ff ff       	jmp    80106b30 <alltraps>

801075cf <vector125>:
.globl vector125
vector125:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $125
801075d1:	6a 7d                	push   $0x7d
  jmp alltraps
801075d3:	e9 58 f5 ff ff       	jmp    80106b30 <alltraps>

801075d8 <vector126>:
.globl vector126
vector126:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $126
801075da:	6a 7e                	push   $0x7e
  jmp alltraps
801075dc:	e9 4f f5 ff ff       	jmp    80106b30 <alltraps>

801075e1 <vector127>:
.globl vector127
vector127:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $127
801075e3:	6a 7f                	push   $0x7f
  jmp alltraps
801075e5:	e9 46 f5 ff ff       	jmp    80106b30 <alltraps>

801075ea <vector128>:
.globl vector128
vector128:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $128
801075ec:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075f1:	e9 3a f5 ff ff       	jmp    80106b30 <alltraps>

801075f6 <vector129>:
.globl vector129
vector129:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $129
801075f8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075fd:	e9 2e f5 ff ff       	jmp    80106b30 <alltraps>

80107602 <vector130>:
.globl vector130
vector130:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $130
80107604:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107609:	e9 22 f5 ff ff       	jmp    80106b30 <alltraps>

8010760e <vector131>:
.globl vector131
vector131:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $131
80107610:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107615:	e9 16 f5 ff ff       	jmp    80106b30 <alltraps>

8010761a <vector132>:
.globl vector132
vector132:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $132
8010761c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107621:	e9 0a f5 ff ff       	jmp    80106b30 <alltraps>

80107626 <vector133>:
.globl vector133
vector133:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $133
80107628:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010762d:	e9 fe f4 ff ff       	jmp    80106b30 <alltraps>

80107632 <vector134>:
.globl vector134
vector134:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $134
80107634:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107639:	e9 f2 f4 ff ff       	jmp    80106b30 <alltraps>

8010763e <vector135>:
.globl vector135
vector135:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $135
80107640:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107645:	e9 e6 f4 ff ff       	jmp    80106b30 <alltraps>

8010764a <vector136>:
.globl vector136
vector136:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $136
8010764c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107651:	e9 da f4 ff ff       	jmp    80106b30 <alltraps>

80107656 <vector137>:
.globl vector137
vector137:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $137
80107658:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010765d:	e9 ce f4 ff ff       	jmp    80106b30 <alltraps>

80107662 <vector138>:
.globl vector138
vector138:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $138
80107664:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107669:	e9 c2 f4 ff ff       	jmp    80106b30 <alltraps>

8010766e <vector139>:
.globl vector139
vector139:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $139
80107670:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107675:	e9 b6 f4 ff ff       	jmp    80106b30 <alltraps>

8010767a <vector140>:
.globl vector140
vector140:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $140
8010767c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107681:	e9 aa f4 ff ff       	jmp    80106b30 <alltraps>

80107686 <vector141>:
.globl vector141
vector141:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $141
80107688:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010768d:	e9 9e f4 ff ff       	jmp    80106b30 <alltraps>

80107692 <vector142>:
.globl vector142
vector142:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $142
80107694:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107699:	e9 92 f4 ff ff       	jmp    80106b30 <alltraps>

8010769e <vector143>:
.globl vector143
vector143:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $143
801076a0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801076a5:	e9 86 f4 ff ff       	jmp    80106b30 <alltraps>

801076aa <vector144>:
.globl vector144
vector144:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $144
801076ac:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076b1:	e9 7a f4 ff ff       	jmp    80106b30 <alltraps>

801076b6 <vector145>:
.globl vector145
vector145:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $145
801076b8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076bd:	e9 6e f4 ff ff       	jmp    80106b30 <alltraps>

801076c2 <vector146>:
.globl vector146
vector146:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $146
801076c4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076c9:	e9 62 f4 ff ff       	jmp    80106b30 <alltraps>

801076ce <vector147>:
.globl vector147
vector147:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $147
801076d0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076d5:	e9 56 f4 ff ff       	jmp    80106b30 <alltraps>

801076da <vector148>:
.globl vector148
vector148:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $148
801076dc:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076e1:	e9 4a f4 ff ff       	jmp    80106b30 <alltraps>

801076e6 <vector149>:
.globl vector149
vector149:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $149
801076e8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076ed:	e9 3e f4 ff ff       	jmp    80106b30 <alltraps>

801076f2 <vector150>:
.globl vector150
vector150:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $150
801076f4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076f9:	e9 32 f4 ff ff       	jmp    80106b30 <alltraps>

801076fe <vector151>:
.globl vector151
vector151:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $151
80107700:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107705:	e9 26 f4 ff ff       	jmp    80106b30 <alltraps>

8010770a <vector152>:
.globl vector152
vector152:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $152
8010770c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107711:	e9 1a f4 ff ff       	jmp    80106b30 <alltraps>

80107716 <vector153>:
.globl vector153
vector153:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $153
80107718:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010771d:	e9 0e f4 ff ff       	jmp    80106b30 <alltraps>

80107722 <vector154>:
.globl vector154
vector154:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $154
80107724:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107729:	e9 02 f4 ff ff       	jmp    80106b30 <alltraps>

8010772e <vector155>:
.globl vector155
vector155:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $155
80107730:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107735:	e9 f6 f3 ff ff       	jmp    80106b30 <alltraps>

8010773a <vector156>:
.globl vector156
vector156:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $156
8010773c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107741:	e9 ea f3 ff ff       	jmp    80106b30 <alltraps>

80107746 <vector157>:
.globl vector157
vector157:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $157
80107748:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010774d:	e9 de f3 ff ff       	jmp    80106b30 <alltraps>

80107752 <vector158>:
.globl vector158
vector158:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $158
80107754:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107759:	e9 d2 f3 ff ff       	jmp    80106b30 <alltraps>

8010775e <vector159>:
.globl vector159
vector159:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $159
80107760:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107765:	e9 c6 f3 ff ff       	jmp    80106b30 <alltraps>

8010776a <vector160>:
.globl vector160
vector160:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $160
8010776c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107771:	e9 ba f3 ff ff       	jmp    80106b30 <alltraps>

80107776 <vector161>:
.globl vector161
vector161:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $161
80107778:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010777d:	e9 ae f3 ff ff       	jmp    80106b30 <alltraps>

80107782 <vector162>:
.globl vector162
vector162:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $162
80107784:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107789:	e9 a2 f3 ff ff       	jmp    80106b30 <alltraps>

8010778e <vector163>:
.globl vector163
vector163:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $163
80107790:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107795:	e9 96 f3 ff ff       	jmp    80106b30 <alltraps>

8010779a <vector164>:
.globl vector164
vector164:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $164
8010779c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801077a1:	e9 8a f3 ff ff       	jmp    80106b30 <alltraps>

801077a6 <vector165>:
.globl vector165
vector165:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $165
801077a8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801077ad:	e9 7e f3 ff ff       	jmp    80106b30 <alltraps>

801077b2 <vector166>:
.globl vector166
vector166:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $166
801077b4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077b9:	e9 72 f3 ff ff       	jmp    80106b30 <alltraps>

801077be <vector167>:
.globl vector167
vector167:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $167
801077c0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077c5:	e9 66 f3 ff ff       	jmp    80106b30 <alltraps>

801077ca <vector168>:
.globl vector168
vector168:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $168
801077cc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077d1:	e9 5a f3 ff ff       	jmp    80106b30 <alltraps>

801077d6 <vector169>:
.globl vector169
vector169:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $169
801077d8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077dd:	e9 4e f3 ff ff       	jmp    80106b30 <alltraps>

801077e2 <vector170>:
.globl vector170
vector170:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $170
801077e4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077e9:	e9 42 f3 ff ff       	jmp    80106b30 <alltraps>

801077ee <vector171>:
.globl vector171
vector171:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $171
801077f0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077f5:	e9 36 f3 ff ff       	jmp    80106b30 <alltraps>

801077fa <vector172>:
.globl vector172
vector172:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $172
801077fc:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107801:	e9 2a f3 ff ff       	jmp    80106b30 <alltraps>

80107806 <vector173>:
.globl vector173
vector173:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $173
80107808:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010780d:	e9 1e f3 ff ff       	jmp    80106b30 <alltraps>

80107812 <vector174>:
.globl vector174
vector174:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $174
80107814:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107819:	e9 12 f3 ff ff       	jmp    80106b30 <alltraps>

8010781e <vector175>:
.globl vector175
vector175:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $175
80107820:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107825:	e9 06 f3 ff ff       	jmp    80106b30 <alltraps>

8010782a <vector176>:
.globl vector176
vector176:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $176
8010782c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107831:	e9 fa f2 ff ff       	jmp    80106b30 <alltraps>

80107836 <vector177>:
.globl vector177
vector177:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $177
80107838:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010783d:	e9 ee f2 ff ff       	jmp    80106b30 <alltraps>

80107842 <vector178>:
.globl vector178
vector178:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $178
80107844:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107849:	e9 e2 f2 ff ff       	jmp    80106b30 <alltraps>

8010784e <vector179>:
.globl vector179
vector179:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $179
80107850:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107855:	e9 d6 f2 ff ff       	jmp    80106b30 <alltraps>

8010785a <vector180>:
.globl vector180
vector180:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $180
8010785c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107861:	e9 ca f2 ff ff       	jmp    80106b30 <alltraps>

80107866 <vector181>:
.globl vector181
vector181:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $181
80107868:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010786d:	e9 be f2 ff ff       	jmp    80106b30 <alltraps>

80107872 <vector182>:
.globl vector182
vector182:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $182
80107874:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107879:	e9 b2 f2 ff ff       	jmp    80106b30 <alltraps>

8010787e <vector183>:
.globl vector183
vector183:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $183
80107880:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107885:	e9 a6 f2 ff ff       	jmp    80106b30 <alltraps>

8010788a <vector184>:
.globl vector184
vector184:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $184
8010788c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107891:	e9 9a f2 ff ff       	jmp    80106b30 <alltraps>

80107896 <vector185>:
.globl vector185
vector185:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $185
80107898:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010789d:	e9 8e f2 ff ff       	jmp    80106b30 <alltraps>

801078a2 <vector186>:
.globl vector186
vector186:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $186
801078a4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801078a9:	e9 82 f2 ff ff       	jmp    80106b30 <alltraps>

801078ae <vector187>:
.globl vector187
vector187:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $187
801078b0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078b5:	e9 76 f2 ff ff       	jmp    80106b30 <alltraps>

801078ba <vector188>:
.globl vector188
vector188:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $188
801078bc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078c1:	e9 6a f2 ff ff       	jmp    80106b30 <alltraps>

801078c6 <vector189>:
.globl vector189
vector189:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $189
801078c8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078cd:	e9 5e f2 ff ff       	jmp    80106b30 <alltraps>

801078d2 <vector190>:
.globl vector190
vector190:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $190
801078d4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078d9:	e9 52 f2 ff ff       	jmp    80106b30 <alltraps>

801078de <vector191>:
.globl vector191
vector191:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $191
801078e0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078e5:	e9 46 f2 ff ff       	jmp    80106b30 <alltraps>

801078ea <vector192>:
.globl vector192
vector192:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $192
801078ec:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078f1:	e9 3a f2 ff ff       	jmp    80106b30 <alltraps>

801078f6 <vector193>:
.globl vector193
vector193:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $193
801078f8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078fd:	e9 2e f2 ff ff       	jmp    80106b30 <alltraps>

80107902 <vector194>:
.globl vector194
vector194:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $194
80107904:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107909:	e9 22 f2 ff ff       	jmp    80106b30 <alltraps>

8010790e <vector195>:
.globl vector195
vector195:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $195
80107910:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107915:	e9 16 f2 ff ff       	jmp    80106b30 <alltraps>

8010791a <vector196>:
.globl vector196
vector196:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $196
8010791c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107921:	e9 0a f2 ff ff       	jmp    80106b30 <alltraps>

80107926 <vector197>:
.globl vector197
vector197:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $197
80107928:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010792d:	e9 fe f1 ff ff       	jmp    80106b30 <alltraps>

80107932 <vector198>:
.globl vector198
vector198:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $198
80107934:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107939:	e9 f2 f1 ff ff       	jmp    80106b30 <alltraps>

8010793e <vector199>:
.globl vector199
vector199:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $199
80107940:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107945:	e9 e6 f1 ff ff       	jmp    80106b30 <alltraps>

8010794a <vector200>:
.globl vector200
vector200:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $200
8010794c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107951:	e9 da f1 ff ff       	jmp    80106b30 <alltraps>

80107956 <vector201>:
.globl vector201
vector201:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $201
80107958:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010795d:	e9 ce f1 ff ff       	jmp    80106b30 <alltraps>

80107962 <vector202>:
.globl vector202
vector202:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $202
80107964:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107969:	e9 c2 f1 ff ff       	jmp    80106b30 <alltraps>

8010796e <vector203>:
.globl vector203
vector203:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $203
80107970:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107975:	e9 b6 f1 ff ff       	jmp    80106b30 <alltraps>

8010797a <vector204>:
.globl vector204
vector204:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $204
8010797c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107981:	e9 aa f1 ff ff       	jmp    80106b30 <alltraps>

80107986 <vector205>:
.globl vector205
vector205:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $205
80107988:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010798d:	e9 9e f1 ff ff       	jmp    80106b30 <alltraps>

80107992 <vector206>:
.globl vector206
vector206:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $206
80107994:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107999:	e9 92 f1 ff ff       	jmp    80106b30 <alltraps>

8010799e <vector207>:
.globl vector207
vector207:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $207
801079a0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801079a5:	e9 86 f1 ff ff       	jmp    80106b30 <alltraps>

801079aa <vector208>:
.globl vector208
vector208:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $208
801079ac:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079b1:	e9 7a f1 ff ff       	jmp    80106b30 <alltraps>

801079b6 <vector209>:
.globl vector209
vector209:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $209
801079b8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079bd:	e9 6e f1 ff ff       	jmp    80106b30 <alltraps>

801079c2 <vector210>:
.globl vector210
vector210:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $210
801079c4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079c9:	e9 62 f1 ff ff       	jmp    80106b30 <alltraps>

801079ce <vector211>:
.globl vector211
vector211:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $211
801079d0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079d5:	e9 56 f1 ff ff       	jmp    80106b30 <alltraps>

801079da <vector212>:
.globl vector212
vector212:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $212
801079dc:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079e1:	e9 4a f1 ff ff       	jmp    80106b30 <alltraps>

801079e6 <vector213>:
.globl vector213
vector213:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $213
801079e8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079ed:	e9 3e f1 ff ff       	jmp    80106b30 <alltraps>

801079f2 <vector214>:
.globl vector214
vector214:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $214
801079f4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079f9:	e9 32 f1 ff ff       	jmp    80106b30 <alltraps>

801079fe <vector215>:
.globl vector215
vector215:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $215
80107a00:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a05:	e9 26 f1 ff ff       	jmp    80106b30 <alltraps>

80107a0a <vector216>:
.globl vector216
vector216:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $216
80107a0c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a11:	e9 1a f1 ff ff       	jmp    80106b30 <alltraps>

80107a16 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $217
80107a18:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a1d:	e9 0e f1 ff ff       	jmp    80106b30 <alltraps>

80107a22 <vector218>:
.globl vector218
vector218:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $218
80107a24:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a29:	e9 02 f1 ff ff       	jmp    80106b30 <alltraps>

80107a2e <vector219>:
.globl vector219
vector219:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $219
80107a30:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a35:	e9 f6 f0 ff ff       	jmp    80106b30 <alltraps>

80107a3a <vector220>:
.globl vector220
vector220:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $220
80107a3c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a41:	e9 ea f0 ff ff       	jmp    80106b30 <alltraps>

80107a46 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $221
80107a48:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a4d:	e9 de f0 ff ff       	jmp    80106b30 <alltraps>

80107a52 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $222
80107a54:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a59:	e9 d2 f0 ff ff       	jmp    80106b30 <alltraps>

80107a5e <vector223>:
.globl vector223
vector223:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $223
80107a60:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a65:	e9 c6 f0 ff ff       	jmp    80106b30 <alltraps>

80107a6a <vector224>:
.globl vector224
vector224:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $224
80107a6c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a71:	e9 ba f0 ff ff       	jmp    80106b30 <alltraps>

80107a76 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $225
80107a78:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a7d:	e9 ae f0 ff ff       	jmp    80106b30 <alltraps>

80107a82 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $226
80107a84:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a89:	e9 a2 f0 ff ff       	jmp    80106b30 <alltraps>

80107a8e <vector227>:
.globl vector227
vector227:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $227
80107a90:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a95:	e9 96 f0 ff ff       	jmp    80106b30 <alltraps>

80107a9a <vector228>:
.globl vector228
vector228:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $228
80107a9c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107aa1:	e9 8a f0 ff ff       	jmp    80106b30 <alltraps>

80107aa6 <vector229>:
.globl vector229
vector229:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $229
80107aa8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107aad:	e9 7e f0 ff ff       	jmp    80106b30 <alltraps>

80107ab2 <vector230>:
.globl vector230
vector230:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $230
80107ab4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107ab9:	e9 72 f0 ff ff       	jmp    80106b30 <alltraps>

80107abe <vector231>:
.globl vector231
vector231:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $231
80107ac0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107ac5:	e9 66 f0 ff ff       	jmp    80106b30 <alltraps>

80107aca <vector232>:
.globl vector232
vector232:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $232
80107acc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ad1:	e9 5a f0 ff ff       	jmp    80106b30 <alltraps>

80107ad6 <vector233>:
.globl vector233
vector233:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $233
80107ad8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107add:	e9 4e f0 ff ff       	jmp    80106b30 <alltraps>

80107ae2 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $234
80107ae4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ae9:	e9 42 f0 ff ff       	jmp    80106b30 <alltraps>

80107aee <vector235>:
.globl vector235
vector235:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $235
80107af0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107af5:	e9 36 f0 ff ff       	jmp    80106b30 <alltraps>

80107afa <vector236>:
.globl vector236
vector236:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $236
80107afc:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b01:	e9 2a f0 ff ff       	jmp    80106b30 <alltraps>

80107b06 <vector237>:
.globl vector237
vector237:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $237
80107b08:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b0d:	e9 1e f0 ff ff       	jmp    80106b30 <alltraps>

80107b12 <vector238>:
.globl vector238
vector238:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $238
80107b14:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b19:	e9 12 f0 ff ff       	jmp    80106b30 <alltraps>

80107b1e <vector239>:
.globl vector239
vector239:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $239
80107b20:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b25:	e9 06 f0 ff ff       	jmp    80106b30 <alltraps>

80107b2a <vector240>:
.globl vector240
vector240:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $240
80107b2c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b31:	e9 fa ef ff ff       	jmp    80106b30 <alltraps>

80107b36 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $241
80107b38:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b3d:	e9 ee ef ff ff       	jmp    80106b30 <alltraps>

80107b42 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $242
80107b44:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b49:	e9 e2 ef ff ff       	jmp    80106b30 <alltraps>

80107b4e <vector243>:
.globl vector243
vector243:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $243
80107b50:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b55:	e9 d6 ef ff ff       	jmp    80106b30 <alltraps>

80107b5a <vector244>:
.globl vector244
vector244:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $244
80107b5c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b61:	e9 ca ef ff ff       	jmp    80106b30 <alltraps>

80107b66 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $245
80107b68:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b6d:	e9 be ef ff ff       	jmp    80106b30 <alltraps>

80107b72 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $246
80107b74:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b79:	e9 b2 ef ff ff       	jmp    80106b30 <alltraps>

80107b7e <vector247>:
.globl vector247
vector247:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $247
80107b80:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b85:	e9 a6 ef ff ff       	jmp    80106b30 <alltraps>

80107b8a <vector248>:
.globl vector248
vector248:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $248
80107b8c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b91:	e9 9a ef ff ff       	jmp    80106b30 <alltraps>

80107b96 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $249
80107b98:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b9d:	e9 8e ef ff ff       	jmp    80106b30 <alltraps>

80107ba2 <vector250>:
.globl vector250
vector250:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $250
80107ba4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ba9:	e9 82 ef ff ff       	jmp    80106b30 <alltraps>

80107bae <vector251>:
.globl vector251
vector251:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $251
80107bb0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107bb5:	e9 76 ef ff ff       	jmp    80106b30 <alltraps>

80107bba <vector252>:
.globl vector252
vector252:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $252
80107bbc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107bc1:	e9 6a ef ff ff       	jmp    80106b30 <alltraps>

80107bc6 <vector253>:
.globl vector253
vector253:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $253
80107bc8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bcd:	e9 5e ef ff ff       	jmp    80106b30 <alltraps>

80107bd2 <vector254>:
.globl vector254
vector254:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $254
80107bd4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bd9:	e9 52 ef ff ff       	jmp    80106b30 <alltraps>

80107bde <vector255>:
.globl vector255
vector255:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $255
80107be0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107be5:	e9 46 ef ff ff       	jmp    80106b30 <alltraps>
	...

80107bec <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107bec:	55                   	push   %ebp
80107bed:	89 e5                	mov    %esp,%ebp
80107bef:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bf5:	48                   	dec    %eax
80107bf6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80107bfd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c01:	8b 45 08             	mov    0x8(%ebp),%eax
80107c04:	c1 e8 10             	shr    $0x10,%eax
80107c07:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107c0b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c0e:	0f 01 10             	lgdtl  (%eax)
}
80107c11:	c9                   	leave  
80107c12:	c3                   	ret    

80107c13 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107c13:	55                   	push   %ebp
80107c14:	89 e5                	mov    %esp,%ebp
80107c16:	83 ec 04             	sub    $0x4,%esp
80107c19:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c20:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107c23:	0f 00 d8             	ltr    %ax
}
80107c26:	c9                   	leave  
80107c27:	c3                   	ret    

80107c28 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107c28:	55                   	push   %ebp
80107c29:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c2e:	0f 22 d8             	mov    %eax,%cr3
}
80107c31:	5d                   	pop    %ebp
80107c32:	c3                   	ret    

80107c33 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c33:	55                   	push   %ebp
80107c34:	89 e5                	mov    %esp,%ebp
80107c36:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c39:	e8 78 c6 ff ff       	call   801042b6 <cpuid>
80107c3e:	89 c2                	mov    %eax,%edx
80107c40:	89 d0                	mov    %edx,%eax
80107c42:	c1 e0 02             	shl    $0x2,%eax
80107c45:	01 d0                	add    %edx,%eax
80107c47:	01 c0                	add    %eax,%eax
80107c49:	01 d0                	add    %edx,%eax
80107c4b:	c1 e0 04             	shl    $0x4,%eax
80107c4e:	05 80 4c 11 80       	add    $0x80114c80,%eax
80107c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c59:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c72:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c75:	83 e2 f0             	and    $0xfffffff0,%edx
80107c78:	83 ca 0a             	or     $0xa,%edx
80107c7b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c81:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c84:	83 ca 10             	or     $0x10,%edx
80107c87:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8d:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c90:	83 e2 9f             	and    $0xffffff9f,%edx
80107c93:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c99:	8a 50 7d             	mov    0x7d(%eax),%dl
80107c9c:	83 ca 80             	or     $0xffffff80,%edx
80107c9f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca5:	8a 50 7e             	mov    0x7e(%eax),%dl
80107ca8:	83 ca 0f             	or     $0xf,%edx
80107cab:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb1:	8a 50 7e             	mov    0x7e(%eax),%dl
80107cb4:	83 e2 ef             	and    $0xffffffef,%edx
80107cb7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbd:	8a 50 7e             	mov    0x7e(%eax),%dl
80107cc0:	83 e2 df             	and    $0xffffffdf,%edx
80107cc3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc9:	8a 50 7e             	mov    0x7e(%eax),%dl
80107ccc:	83 ca 40             	or     $0x40,%edx
80107ccf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	8a 50 7e             	mov    0x7e(%eax),%dl
80107cd8:	83 ca 80             	or     $0xffffff80,%edx
80107cdb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce1:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cef:	ff ff 
80107cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf4:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cfb:	00 00 
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107d10:	83 e2 f0             	and    $0xfffffff0,%edx
80107d13:	83 ca 02             	or     $0x2,%edx
80107d16:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107d25:	83 ca 10             	or     $0x10,%edx
80107d28:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d31:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107d37:	83 e2 9f             	and    $0xffffff9f,%edx
80107d3a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d43:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107d49:	83 ca 80             	or     $0xffffff80,%edx
80107d4c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d5b:	83 ca 0f             	or     $0xf,%edx
80107d5e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d67:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d6d:	83 e2 ef             	and    $0xffffffef,%edx
80107d70:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d79:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d7f:	83 e2 df             	and    $0xffffffdf,%edx
80107d82:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107d91:	83 ca 40             	or     $0x40,%edx
80107d94:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107da3:	83 ca 80             	or     $0xffffff80,%edx
80107da6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107dc0:	ff ff 
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107dcc:	00 00 
80107dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd1:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddb:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107de1:	83 e2 f0             	and    $0xfffffff0,%edx
80107de4:	83 ca 0a             	or     $0xa,%edx
80107de7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df0:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107df6:	83 ca 10             	or     $0x10,%edx
80107df9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e02:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107e08:	83 ca 60             	or     $0x60,%edx
80107e0b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e14:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107e1a:	83 ca 80             	or     $0xffffff80,%edx
80107e1d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e2c:	83 ca 0f             	or     $0xf,%edx
80107e2f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e3e:	83 e2 ef             	and    $0xffffffef,%edx
80107e41:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e50:	83 e2 df             	and    $0xffffffdf,%edx
80107e53:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e62:	83 ca 40             	or     $0x40,%edx
80107e65:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107e74:	83 ca 80             	or     $0xffffff80,%edx
80107e77:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e91:	ff ff 
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e9d:	00 00 
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eac:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107eb2:	83 e2 f0             	and    $0xfffffff0,%edx
80107eb5:	83 ca 02             	or     $0x2,%edx
80107eb8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec1:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107ec7:	83 ca 10             	or     $0x10,%edx
80107eca:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed3:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107ed9:	83 ca 60             	or     $0x60,%edx
80107edc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee5:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107eeb:	83 ca 80             	or     $0xffffff80,%edx
80107eee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef7:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107efd:	83 ca 0f             	or     $0xf,%edx
80107f00:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f09:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107f0f:	83 e2 ef             	and    $0xffffffef,%edx
80107f12:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107f21:	83 e2 df             	and    $0xffffffdf,%edx
80107f24:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107f33:	83 ca 40             	or     $0x40,%edx
80107f36:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107f45:	83 ca 80             	or     $0xffffff80,%edx
80107f48:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f51:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5b:	83 c0 70             	add    $0x70,%eax
80107f5e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107f65:	00 
80107f66:	89 04 24             	mov    %eax,(%esp)
80107f69:	e8 7e fc ff ff       	call   80107bec <lgdt>
}
80107f6e:	c9                   	leave  
80107f6f:	c3                   	ret    

80107f70 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f70:	55                   	push   %ebp
80107f71:	89 e5                	mov    %esp,%ebp
80107f73:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f76:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f79:	c1 e8 16             	shr    $0x16,%eax
80107f7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f83:	8b 45 08             	mov    0x8(%ebp),%eax
80107f86:	01 d0                	add    %edx,%eax
80107f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8e:	8b 00                	mov    (%eax),%eax
80107f90:	83 e0 01             	and    $0x1,%eax
80107f93:	85 c0                	test   %eax,%eax
80107f95:	74 14                	je     80107fab <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9a:	8b 00                	mov    (%eax),%eax
80107f9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa1:	05 00 00 00 80       	add    $0x80000000,%eax
80107fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fa9:	eb 48                	jmp    80107ff3 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107faf:	74 0e                	je     80107fbf <walkpgdir+0x4f>
80107fb1:	e8 9b ad ff ff       	call   80102d51 <kalloc>
80107fb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fbd:	75 07                	jne    80107fc6 <walkpgdir+0x56>
      return 0;
80107fbf:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc4:	eb 44                	jmp    8010800a <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fcd:	00 
80107fce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fd5:	00 
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	89 04 24             	mov    %eax,(%esp)
80107fdc:	e8 09 d4 ff ff       	call   801053ea <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe4:	05 00 00 00 80       	add    $0x80000000,%eax
80107fe9:	83 c8 07             	or     $0x7,%eax
80107fec:	89 c2                	mov    %eax,%edx
80107fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff6:	c1 e8 0c             	shr    $0xc,%eax
80107ff9:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ffe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108008:	01 d0                	add    %edx,%eax
}
8010800a:	c9                   	leave  
8010800b:	c3                   	ret    

8010800c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010800c:	55                   	push   %ebp
8010800d:	89 e5                	mov    %esp,%ebp
8010800f:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108012:	8b 45 0c             	mov    0xc(%ebp),%eax
80108015:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010801d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108020:	8b 45 10             	mov    0x10(%ebp),%eax
80108023:	01 d0                	add    %edx,%eax
80108025:	48                   	dec    %eax
80108026:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010802b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010802e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108035:	00 
80108036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108039:	89 44 24 04          	mov    %eax,0x4(%esp)
8010803d:	8b 45 08             	mov    0x8(%ebp),%eax
80108040:	89 04 24             	mov    %eax,(%esp)
80108043:	e8 28 ff ff ff       	call   80107f70 <walkpgdir>
80108048:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010804b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010804f:	75 07                	jne    80108058 <mappages+0x4c>
      return -1;
80108051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108056:	eb 48                	jmp    801080a0 <mappages+0x94>
    if(*pte & PTE_P)
80108058:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010805b:	8b 00                	mov    (%eax),%eax
8010805d:	83 e0 01             	and    $0x1,%eax
80108060:	85 c0                	test   %eax,%eax
80108062:	74 0c                	je     80108070 <mappages+0x64>
      panic("remap");
80108064:	c7 04 24 f4 95 10 80 	movl   $0x801095f4,(%esp)
8010806b:	e8 e4 84 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108070:	8b 45 18             	mov    0x18(%ebp),%eax
80108073:	0b 45 14             	or     0x14(%ebp),%eax
80108076:	83 c8 01             	or     $0x1,%eax
80108079:	89 c2                	mov    %eax,%edx
8010807b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010807e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108086:	75 08                	jne    80108090 <mappages+0x84>
      break;
80108088:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108089:	b8 00 00 00 00       	mov    $0x0,%eax
8010808e:	eb 10                	jmp    801080a0 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108090:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108097:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010809e:	eb 8e                	jmp    8010802e <mappages+0x22>
  return 0;
}
801080a0:	c9                   	leave  
801080a1:	c3                   	ret    

801080a2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080a2:	55                   	push   %ebp
801080a3:	89 e5                	mov    %esp,%ebp
801080a5:	53                   	push   %ebx
801080a6:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080a9:	e8 a3 ac ff ff       	call   80102d51 <kalloc>
801080ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080b5:	75 0a                	jne    801080c1 <setupkvm+0x1f>
    return 0;
801080b7:	b8 00 00 00 00       	mov    $0x0,%eax
801080bc:	e9 84 00 00 00       	jmp    80108145 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801080c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080c8:	00 
801080c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801080d0:	00 
801080d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d4:	89 04 24             	mov    %eax,(%esp)
801080d7:	e8 0e d3 ff ff       	call   801053ea <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080dc:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
801080e3:	eb 54                	jmp    80108139 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e8:	8b 48 0c             	mov    0xc(%eax),%ecx
801080eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ee:	8b 50 04             	mov    0x4(%eax),%edx
801080f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f4:	8b 58 08             	mov    0x8(%eax),%ebx
801080f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fa:	8b 40 04             	mov    0x4(%eax),%eax
801080fd:	29 c3                	sub    %eax,%ebx
801080ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108102:	8b 00                	mov    (%eax),%eax
80108104:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108108:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010810c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108110:	89 44 24 04          	mov    %eax,0x4(%esp)
80108114:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108117:	89 04 24             	mov    %eax,(%esp)
8010811a:	e8 ed fe ff ff       	call   8010800c <mappages>
8010811f:	85 c0                	test   %eax,%eax
80108121:	79 12                	jns    80108135 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80108123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108126:	89 04 24             	mov    %eax,(%esp)
80108129:	e8 1a 05 00 00       	call   80108648 <freevm>
      return 0;
8010812e:	b8 00 00 00 00       	mov    $0x0,%eax
80108133:	eb 10                	jmp    80108145 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108135:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108139:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
80108140:	72 a3                	jb     801080e5 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108142:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108145:	83 c4 34             	add    $0x34,%esp
80108148:	5b                   	pop    %ebx
80108149:	5d                   	pop    %ebp
8010814a:	c3                   	ret    

8010814b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010814b:	55                   	push   %ebp
8010814c:	89 e5                	mov    %esp,%ebp
8010814e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108151:	e8 4c ff ff ff       	call   801080a2 <setupkvm>
80108156:	a3 a4 7b 11 80       	mov    %eax,0x80117ba4
  switchkvm();
8010815b:	e8 02 00 00 00       	call   80108162 <switchkvm>
}
80108160:	c9                   	leave  
80108161:	c3                   	ret    

80108162 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108162:	55                   	push   %ebp
80108163:	89 e5                	mov    %esp,%ebp
80108165:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108168:	a1 a4 7b 11 80       	mov    0x80117ba4,%eax
8010816d:	05 00 00 00 80       	add    $0x80000000,%eax
80108172:	89 04 24             	mov    %eax,(%esp)
80108175:	e8 ae fa ff ff       	call   80107c28 <lcr3>
}
8010817a:	c9                   	leave  
8010817b:	c3                   	ret    

8010817c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010817c:	55                   	push   %ebp
8010817d:	89 e5                	mov    %esp,%ebp
8010817f:	57                   	push   %edi
80108180:	56                   	push   %esi
80108181:	53                   	push   %ebx
80108182:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108185:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108189:	75 0c                	jne    80108197 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010818b:	c7 04 24 fa 95 10 80 	movl   $0x801095fa,(%esp)
80108192:	e8 bd 83 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108197:	8b 45 08             	mov    0x8(%ebp),%eax
8010819a:	8b 40 08             	mov    0x8(%eax),%eax
8010819d:	85 c0                	test   %eax,%eax
8010819f:	75 0c                	jne    801081ad <switchuvm+0x31>
    panic("switchuvm: no kstack");
801081a1:	c7 04 24 10 96 10 80 	movl   $0x80109610,(%esp)
801081a8:	e8 a7 83 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801081ad:	8b 45 08             	mov    0x8(%ebp),%eax
801081b0:	8b 40 04             	mov    0x4(%eax),%eax
801081b3:	85 c0                	test   %eax,%eax
801081b5:	75 0c                	jne    801081c3 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801081b7:	c7 04 24 25 96 10 80 	movl   $0x80109625,(%esp)
801081be:	e8 91 83 ff ff       	call   80100554 <panic>

  pushcli();
801081c3:	e8 1e d1 ff ff       	call   801052e6 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801081c8:	e8 2e c1 ff ff       	call   801042fb <mycpu>
801081cd:	89 c3                	mov    %eax,%ebx
801081cf:	e8 27 c1 ff ff       	call   801042fb <mycpu>
801081d4:	83 c0 08             	add    $0x8,%eax
801081d7:	89 c6                	mov    %eax,%esi
801081d9:	e8 1d c1 ff ff       	call   801042fb <mycpu>
801081de:	83 c0 08             	add    $0x8,%eax
801081e1:	c1 e8 10             	shr    $0x10,%eax
801081e4:	89 c7                	mov    %eax,%edi
801081e6:	e8 10 c1 ff ff       	call   801042fb <mycpu>
801081eb:	83 c0 08             	add    $0x8,%eax
801081ee:	c1 e8 18             	shr    $0x18,%eax
801081f1:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801081f8:	67 00 
801081fa:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108201:	89 f9                	mov    %edi,%ecx
80108203:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108209:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010820f:	83 e2 f0             	and    $0xfffffff0,%edx
80108212:	83 ca 09             	or     $0x9,%edx
80108215:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010821b:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108221:	83 ca 10             	or     $0x10,%edx
80108224:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010822a:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108230:	83 e2 9f             	and    $0xffffff9f,%edx
80108233:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108239:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010823f:	83 ca 80             	or     $0xffffff80,%edx
80108242:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108248:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010824e:	83 e2 f0             	and    $0xfffffff0,%edx
80108251:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108257:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010825d:	83 e2 ef             	and    $0xffffffef,%edx
80108260:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108266:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010826c:	83 e2 df             	and    $0xffffffdf,%edx
8010826f:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108275:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010827b:	83 ca 40             	or     $0x40,%edx
8010827e:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108284:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010828a:	83 e2 7f             	and    $0x7f,%edx
8010828d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108293:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108299:	e8 5d c0 ff ff       	call   801042fb <mycpu>
8010829e:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801082a4:	83 e2 ef             	and    $0xffffffef,%edx
801082a7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082ad:	e8 49 c0 ff ff       	call   801042fb <mycpu>
801082b2:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082b8:	e8 3e c0 ff ff       	call   801042fb <mycpu>
801082bd:	8b 55 08             	mov    0x8(%ebp),%edx
801082c0:	8b 52 08             	mov    0x8(%edx),%edx
801082c3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801082c9:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801082cc:	e8 2a c0 ff ff       	call   801042fb <mycpu>
801082d1:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801082d7:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
801082de:	e8 30 f9 ff ff       	call   80107c13 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801082e3:	8b 45 08             	mov    0x8(%ebp),%eax
801082e6:	8b 40 04             	mov    0x4(%eax),%eax
801082e9:	05 00 00 00 80       	add    $0x80000000,%eax
801082ee:	89 04 24             	mov    %eax,(%esp)
801082f1:	e8 32 f9 ff ff       	call   80107c28 <lcr3>
  popcli();
801082f6:	e8 35 d0 ff ff       	call   80105330 <popcli>
}
801082fb:	83 c4 1c             	add    $0x1c,%esp
801082fe:	5b                   	pop    %ebx
801082ff:	5e                   	pop    %esi
80108300:	5f                   	pop    %edi
80108301:	5d                   	pop    %ebp
80108302:	c3                   	ret    

80108303 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108303:	55                   	push   %ebp
80108304:	89 e5                	mov    %esp,%ebp
80108306:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108309:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108310:	76 0c                	jbe    8010831e <inituvm+0x1b>
    panic("inituvm: more than a page");
80108312:	c7 04 24 39 96 10 80 	movl   $0x80109639,(%esp)
80108319:	e8 36 82 ff ff       	call   80100554 <panic>
  mem = kalloc();
8010831e:	e8 2e aa ff ff       	call   80102d51 <kalloc>
80108323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108326:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010832d:	00 
8010832e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108335:	00 
80108336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108339:	89 04 24             	mov    %eax,(%esp)
8010833c:	e8 a9 d0 ff ff       	call   801053ea <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108344:	05 00 00 00 80       	add    $0x80000000,%eax
80108349:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108350:	00 
80108351:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108355:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010835c:	00 
8010835d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108364:	00 
80108365:	8b 45 08             	mov    0x8(%ebp),%eax
80108368:	89 04 24             	mov    %eax,(%esp)
8010836b:	e8 9c fc ff ff       	call   8010800c <mappages>
  memmove(mem, init, sz);
80108370:	8b 45 10             	mov    0x10(%ebp),%eax
80108373:	89 44 24 08          	mov    %eax,0x8(%esp)
80108377:	8b 45 0c             	mov    0xc(%ebp),%eax
8010837a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010837e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108381:	89 04 24             	mov    %eax,(%esp)
80108384:	e8 2a d1 ff ff       	call   801054b3 <memmove>
}
80108389:	c9                   	leave  
8010838a:	c3                   	ret    

8010838b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010838b:	55                   	push   %ebp
8010838c:	89 e5                	mov    %esp,%ebp
8010838e:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108391:	8b 45 0c             	mov    0xc(%ebp),%eax
80108394:	25 ff 0f 00 00       	and    $0xfff,%eax
80108399:	85 c0                	test   %eax,%eax
8010839b:	74 0c                	je     801083a9 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
8010839d:	c7 04 24 54 96 10 80 	movl   $0x80109654,(%esp)
801083a4:	e8 ab 81 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083b0:	e9 a6 00 00 00       	jmp    8010845b <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801083bb:	01 d0                	add    %edx,%eax
801083bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083c4:	00 
801083c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801083c9:	8b 45 08             	mov    0x8(%ebp),%eax
801083cc:	89 04 24             	mov    %eax,(%esp)
801083cf:	e8 9c fb ff ff       	call   80107f70 <walkpgdir>
801083d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083db:	75 0c                	jne    801083e9 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801083dd:	c7 04 24 77 96 10 80 	movl   $0x80109677,(%esp)
801083e4:	e8 6b 81 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801083e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ec:	8b 00                	mov    (%eax),%eax
801083ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f9:	8b 55 18             	mov    0x18(%ebp),%edx
801083fc:	29 c2                	sub    %eax,%edx
801083fe:	89 d0                	mov    %edx,%eax
80108400:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108405:	77 0f                	ja     80108416 <loaduvm+0x8b>
      n = sz - i;
80108407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840a:	8b 55 18             	mov    0x18(%ebp),%edx
8010840d:	29 c2                	sub    %eax,%edx
8010840f:	89 d0                	mov    %edx,%eax
80108411:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108414:	eb 07                	jmp    8010841d <loaduvm+0x92>
    else
      n = PGSIZE;
80108416:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010841d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108420:	8b 55 14             	mov    0x14(%ebp),%edx
80108423:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108426:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108429:	05 00 00 00 80       	add    $0x80000000,%eax
8010842e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108431:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108435:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108439:	89 44 24 04          	mov    %eax,0x4(%esp)
8010843d:	8b 45 10             	mov    0x10(%ebp),%eax
80108440:	89 04 24             	mov    %eax,(%esp)
80108443:	e8 11 9b ff ff       	call   80101f59 <readi>
80108448:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010844b:	74 07                	je     80108454 <loaduvm+0xc9>
      return -1;
8010844d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108452:	eb 18                	jmp    8010846c <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108454:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010845b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108461:	0f 82 4e ff ff ff    	jb     801083b5 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108467:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010846c:	c9                   	leave  
8010846d:	c3                   	ret    

8010846e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010846e:	55                   	push   %ebp
8010846f:	89 e5                	mov    %esp,%ebp
80108471:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108474:	8b 45 10             	mov    0x10(%ebp),%eax
80108477:	85 c0                	test   %eax,%eax
80108479:	79 0a                	jns    80108485 <allocuvm+0x17>
    return 0;
8010847b:	b8 00 00 00 00       	mov    $0x0,%eax
80108480:	e9 fd 00 00 00       	jmp    80108582 <allocuvm+0x114>
  if(newsz < oldsz)
80108485:	8b 45 10             	mov    0x10(%ebp),%eax
80108488:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010848b:	73 08                	jae    80108495 <allocuvm+0x27>
    return oldsz;
8010848d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108490:	e9 ed 00 00 00       	jmp    80108582 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108495:	8b 45 0c             	mov    0xc(%ebp),%eax
80108498:	05 ff 0f 00 00       	add    $0xfff,%eax
8010849d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084a5:	e9 c9 00 00 00       	jmp    80108573 <allocuvm+0x105>
    mem = kalloc();
801084aa:	e8 a2 a8 ff ff       	call   80102d51 <kalloc>
801084af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084b6:	75 2f                	jne    801084e7 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801084b8:	c7 04 24 95 96 10 80 	movl   $0x80109695,(%esp)
801084bf:	e8 fd 7e ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801084c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801084cb:	8b 45 10             	mov    0x10(%ebp),%eax
801084ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801084d2:	8b 45 08             	mov    0x8(%ebp),%eax
801084d5:	89 04 24             	mov    %eax,(%esp)
801084d8:	e8 a7 00 00 00       	call   80108584 <deallocuvm>
      return 0;
801084dd:	b8 00 00 00 00       	mov    $0x0,%eax
801084e2:	e9 9b 00 00 00       	jmp    80108582 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
801084e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084ee:	00 
801084ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084f6:	00 
801084f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084fa:	89 04 24             	mov    %eax,(%esp)
801084fd:	e8 e8 ce ff ff       	call   801053ea <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108505:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010850b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108515:	00 
80108516:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010851a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108521:	00 
80108522:	89 44 24 04          	mov    %eax,0x4(%esp)
80108526:	8b 45 08             	mov    0x8(%ebp),%eax
80108529:	89 04 24             	mov    %eax,(%esp)
8010852c:	e8 db fa ff ff       	call   8010800c <mappages>
80108531:	85 c0                	test   %eax,%eax
80108533:	79 37                	jns    8010856c <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108535:	c7 04 24 ad 96 10 80 	movl   $0x801096ad,(%esp)
8010853c:	e8 80 7e ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108541:	8b 45 0c             	mov    0xc(%ebp),%eax
80108544:	89 44 24 08          	mov    %eax,0x8(%esp)
80108548:	8b 45 10             	mov    0x10(%ebp),%eax
8010854b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010854f:	8b 45 08             	mov    0x8(%ebp),%eax
80108552:	89 04 24             	mov    %eax,(%esp)
80108555:	e8 2a 00 00 00       	call   80108584 <deallocuvm>
      kfree(mem);
8010855a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010855d:	89 04 24             	mov    %eax,(%esp)
80108560:	e8 f8 a6 ff ff       	call   80102c5d <kfree>
      return 0;
80108565:	b8 00 00 00 00       	mov    $0x0,%eax
8010856a:	eb 16                	jmp    80108582 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010856c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108576:	3b 45 10             	cmp    0x10(%ebp),%eax
80108579:	0f 82 2b ff ff ff    	jb     801084aa <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
8010857f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108582:	c9                   	leave  
80108583:	c3                   	ret    

80108584 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108584:	55                   	push   %ebp
80108585:	89 e5                	mov    %esp,%ebp
80108587:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010858a:	8b 45 10             	mov    0x10(%ebp),%eax
8010858d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108590:	72 08                	jb     8010859a <deallocuvm+0x16>
    return oldsz;
80108592:	8b 45 0c             	mov    0xc(%ebp),%eax
80108595:	e9 ac 00 00 00       	jmp    80108646 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010859a:	8b 45 10             	mov    0x10(%ebp),%eax
8010859d:	05 ff 0f 00 00       	add    $0xfff,%eax
801085a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085aa:	e9 88 00 00 00       	jmp    80108637 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085b9:	00 
801085ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801085be:	8b 45 08             	mov    0x8(%ebp),%eax
801085c1:	89 04 24             	mov    %eax,(%esp)
801085c4:	e8 a7 f9 ff ff       	call   80107f70 <walkpgdir>
801085c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085d0:	75 14                	jne    801085e6 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801085d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d5:	c1 e8 16             	shr    $0x16,%eax
801085d8:	40                   	inc    %eax
801085d9:	c1 e0 16             	shl    $0x16,%eax
801085dc:	2d 00 10 00 00       	sub    $0x1000,%eax
801085e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085e4:	eb 4a                	jmp    80108630 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801085e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e9:	8b 00                	mov    (%eax),%eax
801085eb:	83 e0 01             	and    $0x1,%eax
801085ee:	85 c0                	test   %eax,%eax
801085f0:	74 3e                	je     80108630 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801085f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f5:	8b 00                	mov    (%eax),%eax
801085f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108603:	75 0c                	jne    80108611 <deallocuvm+0x8d>
        panic("kfree");
80108605:	c7 04 24 c9 96 10 80 	movl   $0x801096c9,(%esp)
8010860c:	e8 43 7f ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108611:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108614:	05 00 00 00 80       	add    $0x80000000,%eax
80108619:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010861c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010861f:	89 04 24             	mov    %eax,(%esp)
80108622:	e8 36 a6 ff ff       	call   80102c5d <kfree>
      *pte = 0;
80108627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010862a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108630:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010863d:	0f 82 6c ff ff ff    	jb     801085af <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108643:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108646:	c9                   	leave  
80108647:	c3                   	ret    

80108648 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108648:	55                   	push   %ebp
80108649:	89 e5                	mov    %esp,%ebp
8010864b:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010864e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108652:	75 0c                	jne    80108660 <freevm+0x18>
    panic("freevm: no pgdir");
80108654:	c7 04 24 cf 96 10 80 	movl   $0x801096cf,(%esp)
8010865b:	e8 f4 7e ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108660:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108667:	00 
80108668:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010866f:	80 
80108670:	8b 45 08             	mov    0x8(%ebp),%eax
80108673:	89 04 24             	mov    %eax,(%esp)
80108676:	e8 09 ff ff ff       	call   80108584 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010867b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108682:	eb 44                	jmp    801086c8 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108687:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010868e:	8b 45 08             	mov    0x8(%ebp),%eax
80108691:	01 d0                	add    %edx,%eax
80108693:	8b 00                	mov    (%eax),%eax
80108695:	83 e0 01             	and    $0x1,%eax
80108698:	85 c0                	test   %eax,%eax
8010869a:	74 29                	je     801086c5 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010869c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086a6:	8b 45 08             	mov    0x8(%ebp),%eax
801086a9:	01 d0                	add    %edx,%eax
801086ab:	8b 00                	mov    (%eax),%eax
801086ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086b2:	05 00 00 00 80       	add    $0x80000000,%eax
801086b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801086ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086bd:	89 04 24             	mov    %eax,(%esp)
801086c0:	e8 98 a5 ff ff       	call   80102c5d <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801086c5:	ff 45 f4             	incl   -0xc(%ebp)
801086c8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086cf:	76 b3                	jbe    80108684 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801086d1:	8b 45 08             	mov    0x8(%ebp),%eax
801086d4:	89 04 24             	mov    %eax,(%esp)
801086d7:	e8 81 a5 ff ff       	call   80102c5d <kfree>
}
801086dc:	c9                   	leave  
801086dd:	c3                   	ret    

801086de <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086de:	55                   	push   %ebp
801086df:	89 e5                	mov    %esp,%ebp
801086e1:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086eb:	00 
801086ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801086ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801086f3:	8b 45 08             	mov    0x8(%ebp),%eax
801086f6:	89 04 24             	mov    %eax,(%esp)
801086f9:	e8 72 f8 ff ff       	call   80107f70 <walkpgdir>
801086fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108701:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108705:	75 0c                	jne    80108713 <clearpteu+0x35>
    panic("clearpteu");
80108707:	c7 04 24 e0 96 10 80 	movl   $0x801096e0,(%esp)
8010870e:	e8 41 7e ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108716:	8b 00                	mov    (%eax),%eax
80108718:	83 e0 fb             	and    $0xfffffffb,%eax
8010871b:	89 c2                	mov    %eax,%edx
8010871d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108720:	89 10                	mov    %edx,(%eax)
}
80108722:	c9                   	leave  
80108723:	c3                   	ret    

80108724 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108724:	55                   	push   %ebp
80108725:	89 e5                	mov    %esp,%ebp
80108727:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010872a:	e8 73 f9 ff ff       	call   801080a2 <setupkvm>
8010872f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108732:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108736:	75 0a                	jne    80108742 <copyuvm+0x1e>
    return 0;
80108738:	b8 00 00 00 00       	mov    $0x0,%eax
8010873d:	e9 f8 00 00 00       	jmp    8010883a <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108749:	e9 cb 00 00 00       	jmp    80108819 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108758:	00 
80108759:	89 44 24 04          	mov    %eax,0x4(%esp)
8010875d:	8b 45 08             	mov    0x8(%ebp),%eax
80108760:	89 04 24             	mov    %eax,(%esp)
80108763:	e8 08 f8 ff ff       	call   80107f70 <walkpgdir>
80108768:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010876b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010876f:	75 0c                	jne    8010877d <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108771:	c7 04 24 ea 96 10 80 	movl   $0x801096ea,(%esp)
80108778:	e8 d7 7d ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
8010877d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108780:	8b 00                	mov    (%eax),%eax
80108782:	83 e0 01             	and    $0x1,%eax
80108785:	85 c0                	test   %eax,%eax
80108787:	75 0c                	jne    80108795 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108789:	c7 04 24 04 97 10 80 	movl   $0x80109704,(%esp)
80108790:	e8 bf 7d ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108795:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108798:	8b 00                	mov    (%eax),%eax
8010879a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010879f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a5:	8b 00                	mov    (%eax),%eax
801087a7:	25 ff 0f 00 00       	and    $0xfff,%eax
801087ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087af:	e8 9d a5 ff ff       	call   80102d51 <kalloc>
801087b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801087b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087bb:	75 02                	jne    801087bf <copyuvm+0x9b>
      goto bad;
801087bd:	eb 6b                	jmp    8010882a <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
801087bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087c2:	05 00 00 00 80       	add    $0x80000000,%eax
801087c7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087ce:	00 
801087cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801087d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d6:	89 04 24             	mov    %eax,(%esp)
801087d9:	e8 d5 cc ff ff       	call   801054b3 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801087de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087e4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801087ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ed:	89 54 24 10          	mov    %edx,0x10(%esp)
801087f1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801087f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087fc:	00 
801087fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108804:	89 04 24             	mov    %eax,(%esp)
80108807:	e8 00 f8 ff ff       	call   8010800c <mappages>
8010880c:	85 c0                	test   %eax,%eax
8010880e:	79 02                	jns    80108812 <copyuvm+0xee>
      goto bad;
80108810:	eb 18                	jmp    8010882a <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108812:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010881f:	0f 82 29 ff ff ff    	jb     8010874e <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108828:	eb 10                	jmp    8010883a <copyuvm+0x116>

bad:
  freevm(d);
8010882a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882d:	89 04 24             	mov    %eax,(%esp)
80108830:	e8 13 fe ff ff       	call   80108648 <freevm>
  return 0;
80108835:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010883a:	c9                   	leave  
8010883b:	c3                   	ret    

8010883c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010883c:	55                   	push   %ebp
8010883d:	89 e5                	mov    %esp,%ebp
8010883f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108842:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108849:	00 
8010884a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010884d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108851:	8b 45 08             	mov    0x8(%ebp),%eax
80108854:	89 04 24             	mov    %eax,(%esp)
80108857:	e8 14 f7 ff ff       	call   80107f70 <walkpgdir>
8010885c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010885f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108862:	8b 00                	mov    (%eax),%eax
80108864:	83 e0 01             	and    $0x1,%eax
80108867:	85 c0                	test   %eax,%eax
80108869:	75 07                	jne    80108872 <uva2ka+0x36>
    return 0;
8010886b:	b8 00 00 00 00       	mov    $0x0,%eax
80108870:	eb 22                	jmp    80108894 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108875:	8b 00                	mov    (%eax),%eax
80108877:	83 e0 04             	and    $0x4,%eax
8010887a:	85 c0                	test   %eax,%eax
8010887c:	75 07                	jne    80108885 <uva2ka+0x49>
    return 0;
8010887e:	b8 00 00 00 00       	mov    $0x0,%eax
80108883:	eb 0f                	jmp    80108894 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108888:	8b 00                	mov    (%eax),%eax
8010888a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010888f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108894:	c9                   	leave  
80108895:	c3                   	ret    

80108896 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108896:	55                   	push   %ebp
80108897:	89 e5                	mov    %esp,%ebp
80108899:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010889c:	8b 45 10             	mov    0x10(%ebp),%eax
8010889f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088a2:	e9 87 00 00 00       	jmp    8010892e <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801088a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801088aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801088b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801088b9:	8b 45 08             	mov    0x8(%ebp),%eax
801088bc:	89 04 24             	mov    %eax,(%esp)
801088bf:	e8 78 ff ff ff       	call   8010883c <uva2ka>
801088c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088cb:	75 07                	jne    801088d4 <copyout+0x3e>
      return -1;
801088cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088d2:	eb 69                	jmp    8010893d <copyout+0xa7>
    n = PGSIZE - (va - va0);
801088d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801088d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801088da:	29 c2                	sub    %eax,%edx
801088dc:	89 d0                	mov    %edx,%eax
801088de:	05 00 10 00 00       	add    $0x1000,%eax
801088e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e9:	3b 45 14             	cmp    0x14(%ebp),%eax
801088ec:	76 06                	jbe    801088f4 <copyout+0x5e>
      n = len;
801088ee:	8b 45 14             	mov    0x14(%ebp),%eax
801088f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801088fa:	29 c2                	sub    %eax,%edx
801088fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088ff:	01 c2                	add    %eax,%edx
80108901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108904:	89 44 24 08          	mov    %eax,0x8(%esp)
80108908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010890f:	89 14 24             	mov    %edx,(%esp)
80108912:	e8 9c cb ff ff       	call   801054b3 <memmove>
    len -= n;
80108917:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010891d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108920:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108923:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108926:	05 00 10 00 00       	add    $0x1000,%eax
8010892b:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010892e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108932:	0f 85 6f ff ff ff    	jne    801088a7 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108938:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010893d:	c9                   	leave  
8010893e:	c3                   	ret    
	...

80108940 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80108940:	55                   	push   %ebp
80108941:	89 e5                	mov    %esp,%ebp
80108943:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
80108946:	8b 45 10             	mov    0x10(%ebp),%eax
80108949:	89 44 24 08          	mov    %eax,0x8(%esp)
8010894d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108950:	89 44 24 04          	mov    %eax,0x4(%esp)
80108954:	8b 45 08             	mov    0x8(%ebp),%eax
80108957:	89 04 24             	mov    %eax,(%esp)
8010895a:	e8 54 cb ff ff       	call   801054b3 <memmove>
}
8010895f:	c9                   	leave  
80108960:	c3                   	ret    

80108961 <strcpy>:

char* strcpy(char *s, char *t){
80108961:	55                   	push   %ebp
80108962:	89 e5                	mov    %esp,%ebp
80108964:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108967:	8b 45 08             	mov    0x8(%ebp),%eax
8010896a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010896d:	90                   	nop
8010896e:	8b 45 08             	mov    0x8(%ebp),%eax
80108971:	8d 50 01             	lea    0x1(%eax),%edx
80108974:	89 55 08             	mov    %edx,0x8(%ebp)
80108977:	8b 55 0c             	mov    0xc(%ebp),%edx
8010897a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010897d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108980:	8a 12                	mov    (%edx),%dl
80108982:	88 10                	mov    %dl,(%eax)
80108984:	8a 00                	mov    (%eax),%al
80108986:	84 c0                	test   %al,%al
80108988:	75 e4                	jne    8010896e <strcpy+0xd>
    ;
  return os;
8010898a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010898d:	c9                   	leave  
8010898e:	c3                   	ret    

8010898f <strcmp>:

int
strcmp(const char *p, const char *q)
{
8010898f:	55                   	push   %ebp
80108990:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108992:	eb 06                	jmp    8010899a <strcmp+0xb>
    p++, q++;
80108994:	ff 45 08             	incl   0x8(%ebp)
80108997:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
8010899a:	8b 45 08             	mov    0x8(%ebp),%eax
8010899d:	8a 00                	mov    (%eax),%al
8010899f:	84 c0                	test   %al,%al
801089a1:	74 0e                	je     801089b1 <strcmp+0x22>
801089a3:	8b 45 08             	mov    0x8(%ebp),%eax
801089a6:	8a 10                	mov    (%eax),%dl
801089a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801089ab:	8a 00                	mov    (%eax),%al
801089ad:	38 c2                	cmp    %al,%dl
801089af:	74 e3                	je     80108994 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801089b1:	8b 45 08             	mov    0x8(%ebp),%eax
801089b4:	8a 00                	mov    (%eax),%al
801089b6:	0f b6 d0             	movzbl %al,%edx
801089b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801089bc:	8a 00                	mov    (%eax),%al
801089be:	0f b6 c0             	movzbl %al,%eax
801089c1:	29 c2                	sub    %eax,%edx
801089c3:	89 d0                	mov    %edx,%eax
}
801089c5:	5d                   	pop    %ebp
801089c6:	c3                   	ret    

801089c7 <get_name>:

// struct con

void get_name(int vc_num, char* name){
801089c7:	55                   	push   %ebp
801089c8:	89 e5                	mov    %esp,%ebp
801089ca:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
801089cd:	8b 55 08             	mov    0x8(%ebp),%edx
801089d0:	89 d0                	mov    %edx,%eax
801089d2:	01 c0                	add    %eax,%eax
801089d4:	01 d0                	add    %edx,%eax
801089d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089dd:	01 d0                	add    %edx,%eax
801089df:	c1 e0 02             	shl    $0x2,%eax
801089e2:	83 c0 10             	add    $0x10,%eax
801089e5:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801089ea:	83 c0 08             	add    $0x8,%eax
801089ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
801089f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
801089f7:	eb 03                	jmp    801089fc <get_name+0x35>
	{
		i++;
801089f9:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
801089fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a02:	01 d0                	add    %edx,%eax
80108a04:	8a 00                	mov    (%eax),%al
80108a06:	84 c0                	test   %al,%al
80108a08:	75 ef                	jne    801089f9 <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80108a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0d:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a14:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a18:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a1b:	89 04 24             	mov    %eax,(%esp)
80108a1e:	e8 1d ff ff ff       	call   80108940 <memcpy2>
}
80108a23:	c9                   	leave  
80108a24:	c3                   	ret    

80108a25 <g_name>:

char* g_name(int vc_bun){
80108a25:	55                   	push   %ebp
80108a26:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
80108a28:	8b 55 08             	mov    0x8(%ebp),%edx
80108a2b:	89 d0                	mov    %edx,%eax
80108a2d:	01 c0                	add    %eax,%eax
80108a2f:	01 d0                	add    %edx,%eax
80108a31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a38:	01 d0                	add    %edx,%eax
80108a3a:	c1 e0 02             	shl    $0x2,%eax
80108a3d:	83 c0 10             	add    $0x10,%eax
80108a40:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108a45:	83 c0 08             	add    $0x8,%eax
}
80108a48:	5d                   	pop    %ebp
80108a49:	c3                   	ret    

80108a4a <is_full>:

int is_full(){
80108a4a:	55                   	push   %ebp
80108a4b:	89 e5                	mov    %esp,%ebp
80108a4d:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108a50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a57:	eb 34                	jmp    80108a8d <is_full+0x43>
		if(strlen(containers[i].name) == 0){
80108a59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a5c:	89 d0                	mov    %edx,%eax
80108a5e:	01 c0                	add    %eax,%eax
80108a60:	01 d0                	add    %edx,%eax
80108a62:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a69:	01 d0                	add    %edx,%eax
80108a6b:	c1 e0 02             	shl    $0x2,%eax
80108a6e:	83 c0 10             	add    $0x10,%eax
80108a71:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108a76:	83 c0 08             	add    $0x8,%eax
80108a79:	89 04 24             	mov    %eax,(%esp)
80108a7c:	e8 bc cb ff ff       	call   8010563d <strlen>
80108a81:	85 c0                	test   %eax,%eax
80108a83:	75 05                	jne    80108a8a <is_full+0x40>
			return i;
80108a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a88:	eb 0e                	jmp    80108a98 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108a8a:	ff 45 f4             	incl   -0xc(%ebp)
80108a8d:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80108a91:	7e c6                	jle    80108a59 <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108a98:	c9                   	leave  
80108a99:	c3                   	ret    

80108a9a <find>:

int find(char* name){
80108a9a:	55                   	push   %ebp
80108a9b:	89 e5                	mov    %esp,%ebp
80108a9d:	83 ec 18             	sub    $0x18,%esp
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108aa0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108aa7:	eb 54                	jmp    80108afd <find+0x63>
		if(strcmp(name, "") == 0){
80108aa9:	c7 44 24 04 1e 97 10 	movl   $0x8010971e,0x4(%esp)
80108ab0:	80 
80108ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab4:	89 04 24             	mov    %eax,(%esp)
80108ab7:	e8 d3 fe ff ff       	call   8010898f <strcmp>
80108abc:	85 c0                	test   %eax,%eax
80108abe:	75 02                	jne    80108ac2 <find+0x28>
			continue;
80108ac0:	eb 38                	jmp    80108afa <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80108ac2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ac5:	89 d0                	mov    %edx,%eax
80108ac7:	01 c0                	add    %eax,%eax
80108ac9:	01 d0                	add    %edx,%eax
80108acb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ad2:	01 d0                	add    %edx,%eax
80108ad4:	c1 e0 02             	shl    $0x2,%eax
80108ad7:	83 c0 10             	add    $0x10,%eax
80108ada:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108adf:	83 c0 08             	add    $0x8,%eax
80108ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae9:	89 04 24             	mov    %eax,(%esp)
80108aec:	e8 9e fe ff ff       	call   8010898f <strcmp>
80108af1:	85 c0                	test   %eax,%eax
80108af3:	75 05                	jne    80108afa <find+0x60>
			//cprintf("in hereI");
			return i;
80108af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108af8:	eb 0e                	jmp    80108b08 <find+0x6e>
}

int find(char* name){
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108afa:	ff 45 fc             	incl   -0x4(%ebp)
80108afd:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108b01:	7e a6                	jle    80108aa9 <find+0xf>
		if(strcmp(name, containers[i].name) == 0){
			//cprintf("in hereI");
			return i;
		}
	}
	return -1;
80108b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108b08:	c9                   	leave  
80108b09:	c3                   	ret    

80108b0a <get_max_proc>:

int get_max_proc(int vc_num){
80108b0a:	55                   	push   %ebp
80108b0b:	89 e5                	mov    %esp,%ebp
80108b0d:	57                   	push   %edi
80108b0e:	56                   	push   %esi
80108b0f:	53                   	push   %ebx
80108b10:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108b13:	8b 55 08             	mov    0x8(%ebp),%edx
80108b16:	89 d0                	mov    %edx,%eax
80108b18:	01 c0                	add    %eax,%eax
80108b1a:	01 d0                	add    %edx,%eax
80108b1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b23:	01 d0                	add    %edx,%eax
80108b25:	c1 e0 02             	shl    $0x2,%eax
80108b28:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b2d:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108b30:	89 c3                	mov    %eax,%ebx
80108b32:	b8 0f 00 00 00       	mov    $0xf,%eax
80108b37:	89 d7                	mov    %edx,%edi
80108b39:	89 de                	mov    %ebx,%esi
80108b3b:	89 c1                	mov    %eax,%ecx
80108b3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108b3f:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80108b42:	83 c4 40             	add    $0x40,%esp
80108b45:	5b                   	pop    %ebx
80108b46:	5e                   	pop    %esi
80108b47:	5f                   	pop    %edi
80108b48:	5d                   	pop    %ebp
80108b49:	c3                   	ret    

80108b4a <get_container>:

struct container* get_container(int vc_num){
80108b4a:	55                   	push   %ebp
80108b4b:	89 e5                	mov    %esp,%ebp
80108b4d:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80108b50:	8b 55 08             	mov    0x8(%ebp),%edx
80108b53:	89 d0                	mov    %edx,%eax
80108b55:	01 c0                	add    %eax,%eax
80108b57:	01 d0                	add    %edx,%eax
80108b59:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b60:	01 d0                	add    %edx,%eax
80108b62:	c1 e0 02             	shl    $0x2,%eax
80108b65:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	// cprintf("vc num given is %d\n.", vc_num);
	// cprintf("The name for this container is %s.\n", cont->name);
	return cont;
80108b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108b70:	c9                   	leave  
80108b71:	c3                   	ret    

80108b72 <get_max_mem>:

int get_max_mem(int vc_num){
80108b72:	55                   	push   %ebp
80108b73:	89 e5                	mov    %esp,%ebp
80108b75:	57                   	push   %edi
80108b76:	56                   	push   %esi
80108b77:	53                   	push   %ebx
80108b78:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108b7b:	8b 55 08             	mov    0x8(%ebp),%edx
80108b7e:	89 d0                	mov    %edx,%eax
80108b80:	01 c0                	add    %eax,%eax
80108b82:	01 d0                	add    %edx,%eax
80108b84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b8b:	01 d0                	add    %edx,%eax
80108b8d:	c1 e0 02             	shl    $0x2,%eax
80108b90:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b95:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108b98:	89 c3                	mov    %eax,%ebx
80108b9a:	b8 0f 00 00 00       	mov    $0xf,%eax
80108b9f:	89 d7                	mov    %edx,%edi
80108ba1:	89 de                	mov    %ebx,%esi
80108ba3:	89 c1                	mov    %eax,%ecx
80108ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108ba7:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108baa:	83 c4 40             	add    $0x40,%esp
80108bad:	5b                   	pop    %ebx
80108bae:	5e                   	pop    %esi
80108baf:	5f                   	pop    %edi
80108bb0:	5d                   	pop    %ebp
80108bb1:	c3                   	ret    

80108bb2 <get_max_disk>:

int get_max_disk(int vc_num){
80108bb2:	55                   	push   %ebp
80108bb3:	89 e5                	mov    %esp,%ebp
80108bb5:	57                   	push   %edi
80108bb6:	56                   	push   %esi
80108bb7:	53                   	push   %ebx
80108bb8:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108bbb:	8b 55 08             	mov    0x8(%ebp),%edx
80108bbe:	89 d0                	mov    %edx,%eax
80108bc0:	01 c0                	add    %eax,%eax
80108bc2:	01 d0                	add    %edx,%eax
80108bc4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bcb:	01 d0                	add    %edx,%eax
80108bcd:	c1 e0 02             	shl    $0x2,%eax
80108bd0:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108bd5:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108bd8:	89 c3                	mov    %eax,%ebx
80108bda:	b8 0f 00 00 00       	mov    $0xf,%eax
80108bdf:	89 d7                	mov    %edx,%edi
80108be1:	89 de                	mov    %ebx,%esi
80108be3:	89 c1                	mov    %eax,%ecx
80108be5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80108be7:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80108bea:	83 c4 40             	add    $0x40,%esp
80108bed:	5b                   	pop    %ebx
80108bee:	5e                   	pop    %esi
80108bef:	5f                   	pop    %edi
80108bf0:	5d                   	pop    %ebp
80108bf1:	c3                   	ret    

80108bf2 <get_curr_proc>:

int get_curr_proc(int vc_num){
80108bf2:	55                   	push   %ebp
80108bf3:	89 e5                	mov    %esp,%ebp
80108bf5:	57                   	push   %edi
80108bf6:	56                   	push   %esi
80108bf7:	53                   	push   %ebx
80108bf8:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108bfb:	8b 55 08             	mov    0x8(%ebp),%edx
80108bfe:	89 d0                	mov    %edx,%eax
80108c00:	01 c0                	add    %eax,%eax
80108c02:	01 d0                	add    %edx,%eax
80108c04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c0b:	01 d0                	add    %edx,%eax
80108c0d:	c1 e0 02             	shl    $0x2,%eax
80108c10:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c15:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108c18:	89 c3                	mov    %eax,%ebx
80108c1a:	b8 0f 00 00 00       	mov    $0xf,%eax
80108c1f:	89 d7                	mov    %edx,%edi
80108c21:	89 de                	mov    %ebx,%esi
80108c23:	89 c1                	mov    %eax,%ecx
80108c25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108c27:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80108c2a:	83 c4 40             	add    $0x40,%esp
80108c2d:	5b                   	pop    %ebx
80108c2e:	5e                   	pop    %esi
80108c2f:	5f                   	pop    %edi
80108c30:	5d                   	pop    %ebp
80108c31:	c3                   	ret    

80108c32 <get_curr_mem>:

int get_curr_mem(int vc_num){
80108c32:	55                   	push   %ebp
80108c33:	89 e5                	mov    %esp,%ebp
80108c35:	57                   	push   %edi
80108c36:	56                   	push   %esi
80108c37:	53                   	push   %ebx
80108c38:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108c3b:	8b 55 08             	mov    0x8(%ebp),%edx
80108c3e:	89 d0                	mov    %edx,%eax
80108c40:	01 c0                	add    %eax,%eax
80108c42:	01 d0                	add    %edx,%eax
80108c44:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c4b:	01 d0                	add    %edx,%eax
80108c4d:	c1 e0 02             	shl    $0x2,%eax
80108c50:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c55:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108c58:	89 c3                	mov    %eax,%ebx
80108c5a:	b8 0f 00 00 00       	mov    $0xf,%eax
80108c5f:	89 d7                	mov    %edx,%edi
80108c61:	89 de                	mov    %ebx,%esi
80108c63:	89 c1                	mov    %eax,%ecx
80108c65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_mem; 
80108c67:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
80108c6a:	83 c4 40             	add    $0x40,%esp
80108c6d:	5b                   	pop    %ebx
80108c6e:	5e                   	pop    %esi
80108c6f:	5f                   	pop    %edi
80108c70:	5d                   	pop    %ebp
80108c71:	c3                   	ret    

80108c72 <get_curr_disk>:

int get_curr_disk(int vc_num){
80108c72:	55                   	push   %ebp
80108c73:	89 e5                	mov    %esp,%ebp
80108c75:	57                   	push   %edi
80108c76:	56                   	push   %esi
80108c77:	53                   	push   %ebx
80108c78:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108c7b:	8b 55 08             	mov    0x8(%ebp),%edx
80108c7e:	89 d0                	mov    %edx,%eax
80108c80:	01 c0                	add    %eax,%eax
80108c82:	01 d0                	add    %edx,%eax
80108c84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c8b:	01 d0                	add    %edx,%eax
80108c8d:	c1 e0 02             	shl    $0x2,%eax
80108c90:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c95:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108c98:	89 c3                	mov    %eax,%ebx
80108c9a:	b8 0f 00 00 00       	mov    $0xf,%eax
80108c9f:	89 d7                	mov    %edx,%edi
80108ca1:	89 de                	mov    %ebx,%esi
80108ca3:	89 c1                	mov    %eax,%ecx
80108ca5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80108ca7:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
80108caa:	83 c4 40             	add    $0x40,%esp
80108cad:	5b                   	pop    %ebx
80108cae:	5e                   	pop    %esi
80108caf:	5f                   	pop    %edi
80108cb0:	5d                   	pop    %ebp
80108cb1:	c3                   	ret    

80108cb2 <set_name>:

void set_name(char* name, int vc_num){
80108cb2:	55                   	push   %ebp
80108cb3:	89 e5                	mov    %esp,%ebp
80108cb5:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80108cb8:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cbb:	89 d0                	mov    %edx,%eax
80108cbd:	01 c0                	add    %eax,%eax
80108cbf:	01 d0                	add    %edx,%eax
80108cc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cc8:	01 d0                	add    %edx,%eax
80108cca:	c1 e0 02             	shl    $0x2,%eax
80108ccd:	83 c0 10             	add    $0x10,%eax
80108cd0:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108cd5:	8d 50 08             	lea    0x8(%eax),%edx
80108cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80108cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cdf:	89 14 24             	mov    %edx,(%esp)
80108ce2:	e8 7a fc ff ff       	call   80108961 <strcpy>
}
80108ce7:	c9                   	leave  
80108ce8:	c3                   	ret    

80108ce9 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80108ce9:	55                   	push   %ebp
80108cea:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80108cec:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cef:	89 d0                	mov    %edx,%eax
80108cf1:	01 c0                	add    %eax,%eax
80108cf3:	01 d0                	add    %edx,%eax
80108cf5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cfc:	01 d0                	add    %edx,%eax
80108cfe:	c1 e0 02             	shl    $0x2,%eax
80108d01:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108d07:	8b 45 08             	mov    0x8(%ebp),%eax
80108d0a:	89 02                	mov    %eax,(%edx)
}
80108d0c:	5d                   	pop    %ebp
80108d0d:	c3                   	ret    

80108d0e <set_max_disk>:

void set_max_disk(int disk, int vc_num){
80108d0e:	55                   	push   %ebp
80108d0f:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
80108d11:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d14:	89 d0                	mov    %edx,%eax
80108d16:	01 c0                	add    %eax,%eax
80108d18:	01 d0                	add    %edx,%eax
80108d1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d21:	01 d0                	add    %edx,%eax
80108d23:	c1 e0 02             	shl    $0x2,%eax
80108d26:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80108d2f:	89 42 08             	mov    %eax,0x8(%edx)
}
80108d32:	5d                   	pop    %ebp
80108d33:	c3                   	ret    

80108d34 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80108d34:	55                   	push   %ebp
80108d35:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80108d37:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d3a:	89 d0                	mov    %edx,%eax
80108d3c:	01 c0                	add    %eax,%eax
80108d3e:	01 d0                	add    %edx,%eax
80108d40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d47:	01 d0                	add    %edx,%eax
80108d49:	c1 e0 02             	shl    $0x2,%eax
80108d4c:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108d52:	8b 45 08             	mov    0x8(%ebp),%eax
80108d55:	89 42 04             	mov    %eax,0x4(%edx)
}
80108d58:	5d                   	pop    %ebp
80108d59:	c3                   	ret    

80108d5a <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
80108d5a:	55                   	push   %ebp
80108d5b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;	
80108d5d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d60:	89 d0                	mov    %edx,%eax
80108d62:	01 c0                	add    %eax,%eax
80108d64:	01 d0                	add    %edx,%eax
80108d66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d6d:	01 d0                	add    %edx,%eax
80108d6f:	c1 e0 02             	shl    $0x2,%eax
80108d72:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d77:	8b 40 0c             	mov    0xc(%eax),%eax
80108d7a:	8d 48 01             	lea    0x1(%eax),%ecx
80108d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d80:	89 d0                	mov    %edx,%eax
80108d82:	01 c0                	add    %eax,%eax
80108d84:	01 d0                	add    %edx,%eax
80108d86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d8d:	01 d0                	add    %edx,%eax
80108d8f:	c1 e0 02             	shl    $0x2,%eax
80108d92:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d97:	89 48 0c             	mov    %ecx,0xc(%eax)
}
80108d9a:	5d                   	pop    %ebp
80108d9b:	c3                   	ret    

80108d9c <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
80108d9c:	55                   	push   %ebp
80108d9d:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
80108d9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108da2:	89 d0                	mov    %edx,%eax
80108da4:	01 c0                	add    %eax,%eax
80108da6:	01 d0                	add    %edx,%eax
80108da8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108daf:	01 d0                	add    %edx,%eax
80108db1:	c1 e0 02             	shl    $0x2,%eax
80108db4:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108db9:	8b 40 0c             	mov    0xc(%eax),%eax
80108dbc:	8d 48 ff             	lea    -0x1(%eax),%ecx
80108dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
80108dc2:	89 d0                	mov    %edx,%eax
80108dc4:	01 c0                	add    %eax,%eax
80108dc6:	01 d0                	add    %edx,%eax
80108dc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108dcf:	01 d0                	add    %edx,%eax
80108dd1:	c1 e0 02             	shl    $0x2,%eax
80108dd4:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108dd9:	89 48 0c             	mov    %ecx,0xc(%eax)
}
80108ddc:	5d                   	pop    %ebp
80108ddd:	c3                   	ret    

80108dde <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80108dde:	55                   	push   %ebp
80108ddf:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
80108de1:	8b 55 0c             	mov    0xc(%ebp),%edx
80108de4:	89 d0                	mov    %edx,%eax
80108de6:	01 c0                	add    %eax,%eax
80108de8:	01 d0                	add    %edx,%eax
80108dea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108df1:	01 d0                	add    %edx,%eax
80108df3:	c1 e0 02             	shl    $0x2,%eax
80108df6:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108dfb:	8b 50 04             	mov    0x4(%eax),%edx
80108dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80108e01:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108e04:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e07:	89 d0                	mov    %edx,%eax
80108e09:	01 c0                	add    %eax,%eax
80108e0b:	01 d0                	add    %edx,%eax
80108e0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e14:	01 d0                	add    %edx,%eax
80108e16:	c1 e0 02             	shl    $0x2,%eax
80108e19:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108e1e:	89 48 04             	mov    %ecx,0x4(%eax)
}
80108e21:	5d                   	pop    %ebp
80108e22:	c3                   	ret    

80108e23 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80108e23:	55                   	push   %ebp
80108e24:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80108e26:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e29:	89 d0                	mov    %edx,%eax
80108e2b:	01 c0                	add    %eax,%eax
80108e2d:	01 d0                	add    %edx,%eax
80108e2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e36:	01 d0                	add    %edx,%eax
80108e38:	c1 e0 02             	shl    $0x2,%eax
80108e3b:	8d 90 d0 7b 11 80    	lea    -0x7fee8430(%eax),%edx
80108e41:	8b 45 08             	mov    0x8(%ebp),%eax
80108e44:	89 02                	mov    %eax,(%edx)
}
80108e46:	5d                   	pop    %ebp
80108e47:	c3                   	ret    

80108e48 <container_init>:

void container_init(){
80108e48:	55                   	push   %ebp
80108e49:	89 e5                	mov    %esp,%ebp
80108e4b:	83 ec 18             	sub    $0x18,%esp

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108e4e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108e55:	e9 f7 00 00 00       	jmp    80108f51 <container_init+0x109>
		strcpy(containers[i].name, "");
80108e5a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e5d:	89 d0                	mov    %edx,%eax
80108e5f:	01 c0                	add    %eax,%eax
80108e61:	01 d0                	add    %edx,%eax
80108e63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e6a:	01 d0                	add    %edx,%eax
80108e6c:	c1 e0 02             	shl    $0x2,%eax
80108e6f:	83 c0 10             	add    $0x10,%eax
80108e72:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e77:	83 c0 08             	add    $0x8,%eax
80108e7a:	c7 44 24 04 1e 97 10 	movl   $0x8010971e,0x4(%esp)
80108e81:	80 
80108e82:	89 04 24             	mov    %eax,(%esp)
80108e85:	e8 d7 fa ff ff       	call   80108961 <strcpy>
		containers[i].max_proc = 4;
80108e8a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e8d:	89 d0                	mov    %edx,%eax
80108e8f:	01 c0                	add    %eax,%eax
80108e91:	01 d0                	add    %edx,%eax
80108e93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e9a:	01 d0                	add    %edx,%eax
80108e9c:	c1 e0 02             	shl    $0x2,%eax
80108e9f:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ea4:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80108eab:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108eae:	89 d0                	mov    %edx,%eax
80108eb0:	01 c0                	add    %eax,%eax
80108eb2:	01 d0                	add    %edx,%eax
80108eb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ebb:	01 d0                	add    %edx,%eax
80108ebd:	c1 e0 02             	shl    $0x2,%eax
80108ec0:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ec5:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
80108ecc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ecf:	89 d0                	mov    %edx,%eax
80108ed1:	01 c0                	add    %eax,%eax
80108ed3:	01 d0                	add    %edx,%eax
80108ed5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108edc:	01 d0                	add    %edx,%eax
80108ede:	c1 e0 02             	shl    $0x2,%eax
80108ee1:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ee6:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 1;
80108eec:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108eef:	89 d0                	mov    %edx,%eax
80108ef1:	01 c0                	add    %eax,%eax
80108ef3:	01 d0                	add    %edx,%eax
80108ef5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108efc:	01 d0                	add    %edx,%eax
80108efe:	c1 e0 02             	shl    $0x2,%eax
80108f01:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108f06:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
80108f0c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108f0f:	89 d0                	mov    %edx,%eax
80108f11:	01 c0                	add    %eax,%eax
80108f13:	01 d0                	add    %edx,%eax
80108f15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f1c:	01 d0                	add    %edx,%eax
80108f1e:	c1 e0 02             	shl    $0x2,%eax
80108f21:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108f26:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
80108f2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108f30:	89 d0                	mov    %edx,%eax
80108f32:	01 c0                	add    %eax,%eax
80108f34:	01 d0                	add    %edx,%eax
80108f36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f3d:	01 d0                	add    %edx,%eax
80108f3f:	c1 e0 02             	shl    $0x2,%eax
80108f42:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f47:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

void container_init(){

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108f4e:	ff 45 fc             	incl   -0x4(%ebp)
80108f51:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108f55:	0f 8e ff fe ff ff    	jle    80108e5a <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
80108f5b:	c9                   	leave  
80108f5c:	c3                   	ret    
