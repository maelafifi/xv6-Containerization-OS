
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
8010002d:	b8 86 39 10 80       	mov    $0x80103986,%eax
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
8010003a:	c7 44 24 04 e8 93 10 	movl   $0x801093e8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100049:	e8 34 52 00 00       	call   80105282 <initlock>

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
80100087:	c7 44 24 04 ef 93 10 	movl   $0x801093ef,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 ad 50 00 00       	call   80105144 <initsleeplock>
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
801000c9:	e8 d5 51 00 00       	call   801052a3 <acquire>

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
80100104:	e8 04 52 00 00       	call   8010530d <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 67 50 00 00       	call   8010517e <acquiresleep>
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
8010017d:	e8 8b 51 00 00       	call   8010530d <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 ee 4f 00 00       	call   8010517e <acquiresleep>
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
801001a7:	c7 04 24 f6 93 10 80 	movl   $0x801093f6,(%esp)
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
801001e2:	e8 56 28 00 00       	call   80102a3d <iderw>
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
801001fb:	e8 1b 50 00 00       	call   8010521b <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 07 94 10 80 	movl   $0x80109407,(%esp)
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
80100225:	e8 13 28 00 00       	call   80102a3d <iderw>
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
8010023b:	e8 db 4f 00 00       	call   8010521b <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 0e 94 10 80 	movl   $0x8010940e,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 7b 4f 00 00       	call   801051d9 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100265:	e8 39 50 00 00       	call   801052a3 <acquire>
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
801002d1:	e8 37 50 00 00       	call   8010530d <release>
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
801003dc:	e8 c2 4e 00 00       	call   801052a3 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 15 94 10 80 	movl   $0x80109415,(%esp)
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
801004cf:	c7 45 ec 1e 94 10 80 	movl   $0x8010941e,-0x14(%ebp)
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
8010054d:	e8 bb 4d 00 00       	call   8010530d <release>
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
80100569:	e8 eb 2b 00 00       	call   80103159 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 25 94 10 80 	movl   $0x80109425,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 39 94 10 80 	movl   $0x80109439,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 b3 4d 00 00       	call   8010535a <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 3b 94 10 80 	movl   $0x8010943b,(%esp)
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
80100695:	c7 04 24 3f 94 10 80 	movl   $0x8010943f,(%esp)
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
801006c9:	e8 01 4f 00 00       	call   801055cf <memmove>
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
801006f8:	e8 09 4e 00 00       	call   80105506 <memset>
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
8010078e:	e8 5d 6c 00 00       	call   801073f0 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 51 6c 00 00       	call   801073f0 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 45 6c 00 00       	call   801073f0 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 38 6c 00 00       	call   801073f0 <uartputc>
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
80100813:	e8 8b 4a 00 00       	call   801052a3 <acquire>
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
80100a00:	e8 26 43 00 00       	call   80104d2b <wakeup>
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
80100a21:	e8 e7 48 00 00       	call   8010530d <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 52 94 10 80 	movl   $0x80109452,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 94 43 00 00       	call   80104dd1 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 6a 94 10 80 	movl   $0x8010946a,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 84 94 10 80 	movl   $0x80109484,(%esp)
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
80100a8a:	e8 14 48 00 00       	call   801052a3 <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 08 39 00 00       	call   801043a3 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100aa9:	e8 5f 48 00 00       	call   8010530d <release>
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
80100ad2:	e8 7d 41 00 00       	call   80104c54 <sleep>

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
80100b5c:	e8 ac 47 00 00       	call   8010530d <release>
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
80100ba2:	e8 fc 46 00 00       	call   801052a3 <acquire>
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
80100bda:	e8 2e 47 00 00       	call   8010530d <release>
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
80100bf5:	c7 44 24 04 9d 94 10 	movl   $0x8010949d,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100c04:	e8 79 46 00 00       	call   80105282 <initlock>

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
80100c36:	e8 b4 1f 00 00       	call   80102bef <ioapicenable>
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
80100c49:	e8 55 37 00 00       	call   801043a3 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 4d 2a 00 00       	call   801036a3 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 ef 19 00 00       	call   80102650 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 b6 2a 00 00       	call   80103725 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 a5 94 10 80 	movl   $0x801094a5,(%esp)
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
80100cd8:	e8 f5 76 00 00       	call   801083d2 <setupkvm>
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
80100d96:	e8 03 7a 00 00       	call   8010879e <allocuvm>
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
80100de8:	e8 ce 78 00 00       	call   801086bb <loaduvm>
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
80100e1f:	e8 01 29 00 00       	call   80103725 <end_op>
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
80100e54:	e8 45 79 00 00       	call   8010879e <allocuvm>
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
80100e79:	e8 90 7b 00 00       	call   80108a0e <clearpteu>
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
80100eaf:	e8 a5 48 00 00       	call   80105759 <strlen>
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
80100ed6:	e8 7e 48 00 00       	call   80105759 <strlen>
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
80100f04:	e8 bd 7c 00 00       	call   80108bc6 <copyout>
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
80100fa8:	e8 19 7c 00 00       	call   80108bc6 <copyout>
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
80100ff8:	e8 15 47 00 00       	call   80105712 <safestrcpy>

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
80101038:	e8 6f 74 00 00       	call   801084ac <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 30 79 00 00       	call   80108978 <freevm>
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
8010105b:	e8 18 79 00 00       	call   80108978 <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 af 26 00 00       	call   80103725 <end_op>
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
801010ec:	c7 44 24 04 b1 94 10 	movl   $0x801094b1,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801010fb:	e8 82 41 00 00       	call   80105282 <initlock>
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
8010110f:	e8 8f 41 00 00       	call   801052a3 <acquire>
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
80101138:	e8 d0 41 00 00       	call   8010530d <release>
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
80101156:	e8 b2 41 00 00       	call   8010530d <release>
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
8010116f:	e8 2f 41 00 00       	call   801052a3 <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 b8 94 10 80 	movl   $0x801094b8,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011a0:	e8 68 41 00 00       	call   8010530d <release>
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
801011ba:	e8 e4 40 00 00       	call   801052a3 <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 c0 94 10 80 	movl   $0x801094c0,(%esp)
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
801011f5:	e8 13 41 00 00       	call   8010530d <release>
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
8010122b:	e8 dd 40 00 00       	call   8010530d <release>

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
80101248:	e8 ee 2d 00 00       	call   8010403b <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 47 24 00 00       	call   801036a3 <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 b9 24 00 00       	call   80103725 <end_op>
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
801012fe:	e8 b6 2e 00 00       	call   801041b9 <piperead>
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
80101370:	c7 04 24 ca 94 10 80 	movl   $0x801094ca,(%esp)
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
801013ba:	e8 0e 2d 00 00       	call   801040cd <pipewrite>
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
80101400:	e8 9e 22 00 00       	call   801036a3 <begin_op>
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
80101466:	e8 ba 22 00 00       	call   80103725 <end_op>

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
8010147b:	c7 04 24 d3 94 10 80 	movl   $0x801094d3,(%esp)
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
801014ad:	c7 04 24 e3 94 10 80 	movl   $0x801094e3,(%esp)
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
801014f4:	e8 d6 40 00 00       	call   801055cf <memmove>
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
8010153a:	e8 c7 3f 00 00       	call   80105506 <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 5d 23 00 00       	call   801038a7 <log_write>
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
8010160d:	e8 95 22 00 00       	call   801038a7 <log_write>
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
80101683:	c7 04 24 f0 94 10 80 	movl   $0x801094f0,(%esp)
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
80101713:	c7 04 24 06 95 10 80 	movl   $0x80109506,(%esp)
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
80101749:	e8 59 21 00 00       	call   801038a7 <log_write>
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
8010176b:	c7 44 24 04 19 95 10 	movl   $0x80109519,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
8010177a:	e8 03 3b 00 00       	call   80105282 <initlock>
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
801017a0:	c7 44 24 04 20 95 10 	movl   $0x80109520,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 94 39 00 00       	call   80105144 <initsleeplock>
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
80101819:	c7 04 24 28 95 10 80 	movl   $0x80109528,(%esp)
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
8010189b:	e8 66 3c 00 00       	call   80105506 <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 f3 1f 00 00       	call   801038a7 <log_write>
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
801018f1:	c7 04 24 7b 95 10 80 	movl   $0x8010957b,(%esp)
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
8010199e:	e8 2c 3c 00 00       	call   801055cf <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 f9 1e 00 00       	call   801038a7 <log_write>
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
801019c8:	e8 d6 38 00 00       	call   801052a3 <acquire>

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
80101a12:	e8 f6 38 00 00       	call   8010530d <release>
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
80101a48:	c7 04 24 8d 95 10 80 	movl   $0x8010958d,(%esp)
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
80101a86:	e8 82 38 00 00       	call   8010530d <release>

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
80101a9d:	e8 01 38 00 00       	call   801052a3 <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101ab8:	e8 50 38 00 00       	call   8010530d <release>
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
80101ad8:	c7 04 24 9d 95 10 80 	movl   $0x8010959d,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 8c 36 00 00       	call   8010517e <acquiresleep>

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
80101b99:	e8 31 3a 00 00       	call   801055cf <memmove>
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
80101bbe:	c7 04 24 a3 95 10 80 	movl   $0x801095a3,(%esp)
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
80101be1:	e8 35 36 00 00       	call   8010521b <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 b2 95 10 80 	movl   $0x801095b2,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 cb 35 00 00       	call   801051d9 <releasesleep>
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
80101c1f:	e8 5a 35 00 00       	call   8010517e <acquiresleep>
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
80101c41:	e8 5d 36 00 00       	call   801052a3 <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c56:	e8 b2 36 00 00       	call   8010530d <release>
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
80101c93:	e8 41 35 00 00       	call   801051d9 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c9f:	e8 ff 35 00 00       	call   801052a3 <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101cba:	e8 4e 36 00 00       	call   8010530d <release>
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
80101dcb:	e8 d7 1a 00 00       	call   801038a7 <log_write>
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
80101de0:	c7 04 24 ba 95 10 80 	movl   $0x801095ba,(%esp)
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
8010208a:	e8 40 35 00 00       	call   801055cf <memmove>
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
801020c0:	83 ec 38             	sub    $0x38,%esp
  uint tot, m;
  struct buf *bp;
  struct container* cont = myproc()->cont;
801020c3:	e8 db 22 00 00       	call   801043a3 <myproc>
801020c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	83 c0 18             	add    $0x18,%eax
801020d7:	89 04 24             	mov    %eax,(%esp)
801020da:	e8 2c 6d 00 00       	call   80108e0b <find>
801020df:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if(ip->type == T_DEV){
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	8b 40 50             	mov    0x50(%eax),%eax
801020e8:	66 83 f8 03          	cmp    $0x3,%ax
801020ec:	75 6c                	jne    8010215a <writei+0x9d>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write){
801020ee:	8b 45 08             	mov    0x8(%ebp),%eax
801020f1:	66 8b 40 52          	mov    0x52(%eax),%ax
801020f5:	66 85 c0             	test   %ax,%ax
801020f8:	78 20                	js     8010211a <writei+0x5d>
801020fa:	8b 45 08             	mov    0x8(%ebp),%eax
801020fd:	66 8b 40 52          	mov    0x52(%eax),%ax
80102101:	66 83 f8 09          	cmp    $0x9,%ax
80102105:	7f 13                	jg     8010211a <writei+0x5d>
80102107:	8b 45 08             	mov    0x8(%ebp),%eax
8010210a:	66 8b 40 52          	mov    0x52(%eax),%ax
8010210e:	98                   	cwtl   
8010210f:	8b 04 c5 64 2e 11 80 	mov    -0x7feed19c(,%eax,8),%eax
80102116:	85 c0                	test   %eax,%eax
80102118:	75 16                	jne    80102130 <writei+0x73>
      cprintf("hello1");
8010211a:	c7 04 24 cd 95 10 80 	movl   $0x801095cd,(%esp)
80102121:	e8 9b e2 ff ff       	call   801003c1 <cprintf>
      return -1;
80102126:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010212b:	e9 83 01 00 00       	jmp    801022b3 <writei+0x1f6>
    }
    //cprintf("hello2");
    return devsw[ip->major].write(ip, src, n);
80102130:	8b 45 08             	mov    0x8(%ebp),%eax
80102133:	66 8b 40 52          	mov    0x52(%eax),%ax
80102137:	98                   	cwtl   
80102138:	8b 04 c5 64 2e 11 80 	mov    -0x7feed19c(,%eax,8),%eax
8010213f:	8b 55 14             	mov    0x14(%ebp),%edx
80102142:	89 54 24 08          	mov    %edx,0x8(%esp)
80102146:	8b 55 0c             	mov    0xc(%ebp),%edx
80102149:	89 54 24 04          	mov    %edx,0x4(%esp)
8010214d:	8b 55 08             	mov    0x8(%ebp),%edx
80102150:	89 14 24             	mov    %edx,(%esp)
80102153:	ff d0                	call   *%eax
80102155:	e9 59 01 00 00       	jmp    801022b3 <writei+0x1f6>
  }


  if(off > ip->size || off + n < off){
8010215a:	8b 45 08             	mov    0x8(%ebp),%eax
8010215d:	8b 40 58             	mov    0x58(%eax),%eax
80102160:	3b 45 10             	cmp    0x10(%ebp),%eax
80102163:	72 0d                	jb     80102172 <writei+0xb5>
80102165:	8b 45 14             	mov    0x14(%ebp),%eax
80102168:	8b 55 10             	mov    0x10(%ebp),%edx
8010216b:	01 d0                	add    %edx,%eax
8010216d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102170:	73 0a                	jae    8010217c <writei+0xbf>
    return -1;
80102172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102177:	e9 37 01 00 00       	jmp    801022b3 <writei+0x1f6>
  }
  if(off + n > MAXFILE*BSIZE){
8010217c:	8b 45 14             	mov    0x14(%ebp),%eax
8010217f:	8b 55 10             	mov    0x10(%ebp),%edx
80102182:	01 d0                	add    %edx,%eax
80102184:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102189:	76 16                	jbe    801021a1 <writei+0xe4>
    cprintf("hello4");
8010218b:	c7 04 24 d4 95 10 80 	movl   $0x801095d4,(%esp)
80102192:	e8 2a e2 ff ff       	call   801003c1 <cprintf>
    return -1;
80102197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010219c:	e9 12 01 00 00       	jmp    801022b3 <writei+0x1f6>
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021a8:	e9 a0 00 00 00       	jmp    8010224d <writei+0x190>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021ad:	8b 45 10             	mov    0x10(%ebp),%eax
801021b0:	c1 e8 09             	shr    $0x9,%eax
801021b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ba:	89 04 24             	mov    %eax,(%esp)
801021bd:	e8 1d fb ff ff       	call   80101cdf <bmap>
801021c2:	8b 55 08             	mov    0x8(%ebp),%edx
801021c5:	8b 12                	mov    (%edx),%edx
801021c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801021cb:	89 14 24             	mov    %edx,(%esp)
801021ce:	e8 e2 df ff ff       	call   801001b5 <bread>
801021d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021d6:	8b 45 10             	mov    0x10(%ebp),%eax
801021d9:	25 ff 01 00 00       	and    $0x1ff,%eax
801021de:	89 c2                	mov    %eax,%edx
801021e0:	b8 00 02 00 00       	mov    $0x200,%eax
801021e5:	29 d0                	sub    %edx,%eax
801021e7:	89 c1                	mov    %eax,%ecx
801021e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ec:	8b 55 14             	mov    0x14(%ebp),%edx
801021ef:	29 c2                	sub    %eax,%edx
801021f1:	89 c8                	mov    %ecx,%eax
801021f3:	39 d0                	cmp    %edx,%eax
801021f5:	76 02                	jbe    801021f9 <writei+0x13c>
801021f7:	89 d0                	mov    %edx,%eax
801021f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021fc:	8b 45 10             	mov    0x10(%ebp),%eax
801021ff:	25 ff 01 00 00       	and    $0x1ff,%eax
80102204:	8d 50 50             	lea    0x50(%eax),%edx
80102207:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010220a:	01 d0                	add    %edx,%eax
8010220c:	8d 50 0c             	lea    0xc(%eax),%edx
8010220f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102212:	89 44 24 08          	mov    %eax,0x8(%esp)
80102216:	8b 45 0c             	mov    0xc(%ebp),%eax
80102219:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221d:	89 14 24             	mov    %edx,(%esp)
80102220:	e8 aa 33 00 00       	call   801055cf <memmove>
    log_write(bp);
80102225:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102228:	89 04 24             	mov    %eax,(%esp)
8010222b:	e8 77 16 00 00       	call   801038a7 <log_write>
    brelse(bp);
80102230:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102233:	89 04 24             	mov    %eax,(%esp)
80102236:	e8 f1 df ff ff       	call   8010022c <brelse>
  if(off + n > MAXFILE*BSIZE){
    cprintf("hello4");
    return -1;
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010223b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010223e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102244:	01 45 10             	add    %eax,0x10(%ebp)
80102247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010224a:	01 45 0c             	add    %eax,0xc(%ebp)
8010224d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102250:	3b 45 14             	cmp    0x14(%ebp),%eax
80102253:	0f 82 54 ff ff ff    	jb     801021ad <writei+0xf0>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(x >= 0){
80102259:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010225d:	78 2c                	js     8010228b <writei+0x1ce>
    cprintf("%d\n", tot);
8010225f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102262:	89 44 24 04          	mov    %eax,0x4(%esp)
80102266:	c7 04 24 db 95 10 80 	movl   $0x801095db,(%esp)
8010226d:	e8 4f e1 ff ff       	call   801003c1 <cprintf>
    if(tot == 1){
80102272:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102276:	75 13                	jne    8010228b <writei+0x1ce>
      set_curr_disk(1, x);
80102278:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102286:	e8 d7 6e 00 00       	call   80109162 <set_curr_disk>
    }
  }
  if(n > 0 && off > ip->size){
8010228b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010228f:	74 1f                	je     801022b0 <writei+0x1f3>
80102291:	8b 45 08             	mov    0x8(%ebp),%eax
80102294:	8b 40 58             	mov    0x58(%eax),%eax
80102297:	3b 45 10             	cmp    0x10(%ebp),%eax
8010229a:	73 14                	jae    801022b0 <writei+0x1f3>
    ip->size = off;
8010229c:	8b 45 08             	mov    0x8(%ebp),%eax
8010229f:	8b 55 10             	mov    0x10(%ebp),%edx
801022a2:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	89 04 24             	mov    %eax,(%esp)
801022ab:	e8 4f f6 ff ff       	call   801018ff <iupdate>
  }
  return n;
801022b0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022b3:	c9                   	leave  
801022b4:	c3                   	ret    

801022b5 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022b5:	55                   	push   %ebp
801022b6:	89 e5                	mov    %esp,%ebp
801022b8:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801022bb:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022c2:	00 
801022c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ca:	8b 45 08             	mov    0x8(%ebp),%eax
801022cd:	89 04 24             	mov    %eax,(%esp)
801022d0:	e8 99 33 00 00       	call   8010566e <strncmp>
}
801022d5:	c9                   	leave  
801022d6:	c3                   	ret    

801022d7 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022d7:	55                   	push   %ebp
801022d8:	89 e5                	mov    %esp,%ebp
801022da:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022dd:	8b 45 08             	mov    0x8(%ebp),%eax
801022e0:	8b 40 50             	mov    0x50(%eax),%eax
801022e3:	66 83 f8 01          	cmp    $0x1,%ax
801022e7:	74 0c                	je     801022f5 <dirlookup+0x1e>
    panic("dirlookup not DIR");
801022e9:	c7 04 24 df 95 10 80 	movl   $0x801095df,(%esp)
801022f0:	e8 5f e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022fc:	e9 86 00 00 00       	jmp    80102387 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102301:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102308:	00 
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102310:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102313:	89 44 24 04          	mov    %eax,0x4(%esp)
80102317:	8b 45 08             	mov    0x8(%ebp),%eax
8010231a:	89 04 24             	mov    %eax,(%esp)
8010231d:	e8 37 fc ff ff       	call   80101f59 <readi>
80102322:	83 f8 10             	cmp    $0x10,%eax
80102325:	74 0c                	je     80102333 <dirlookup+0x5c>
      panic("dirlookup read");
80102327:	c7 04 24 f1 95 10 80 	movl   $0x801095f1,(%esp)
8010232e:	e8 21 e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102333:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102336:	66 85 c0             	test   %ax,%ax
80102339:	75 02                	jne    8010233d <dirlookup+0x66>
      continue;
8010233b:	eb 46                	jmp    80102383 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
8010233d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102340:	83 c0 02             	add    $0x2,%eax
80102343:	89 44 24 04          	mov    %eax,0x4(%esp)
80102347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010234a:	89 04 24             	mov    %eax,(%esp)
8010234d:	e8 63 ff ff ff       	call   801022b5 <namecmp>
80102352:	85 c0                	test   %eax,%eax
80102354:	75 2d                	jne    80102383 <dirlookup+0xac>
      // entry matches path element
      if(poff)
80102356:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010235a:	74 08                	je     80102364 <dirlookup+0x8d>
        *poff = off;
8010235c:	8b 45 10             	mov    0x10(%ebp),%eax
8010235f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102362:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102364:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102367:	0f b7 c0             	movzwl %ax,%eax
8010236a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010236d:	8b 45 08             	mov    0x8(%ebp),%eax
80102370:	8b 00                	mov    (%eax),%eax
80102372:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102375:	89 54 24 04          	mov    %edx,0x4(%esp)
80102379:	89 04 24             	mov    %eax,(%esp)
8010237c:	e8 3a f6 ff ff       	call   801019bb <iget>
80102381:	eb 18                	jmp    8010239b <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102383:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	8b 40 58             	mov    0x58(%eax),%eax
8010238d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102390:	0f 87 6b ff ff ff    	ja     80102301 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102396:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010239b:	c9                   	leave  
8010239c:	c3                   	ret    

8010239d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010239d:	55                   	push   %ebp
8010239e:	89 e5                	mov    %esp,%ebp
801023a0:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023aa:	00 
801023ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801023b2:	8b 45 08             	mov    0x8(%ebp),%eax
801023b5:	89 04 24             	mov    %eax,(%esp)
801023b8:	e8 1a ff ff ff       	call   801022d7 <dirlookup>
801023bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023c4:	74 15                	je     801023db <dirlink+0x3e>
    iput(ip);
801023c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c9:	89 04 24             	mov    %eax,(%esp)
801023cc:	e8 3f f8 ff ff       	call   80101c10 <iput>
    return -1;
801023d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023d6:	e9 b6 00 00 00       	jmp    80102491 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023e2:	eb 45                	jmp    80102429 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023ee:	00 
801023ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801023f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
801023fd:	89 04 24             	mov    %eax,(%esp)
80102400:	e8 54 fb ff ff       	call   80101f59 <readi>
80102405:	83 f8 10             	cmp    $0x10,%eax
80102408:	74 0c                	je     80102416 <dirlink+0x79>
      panic("dirlink read");
8010240a:	c7 04 24 00 96 10 80 	movl   $0x80109600,(%esp)
80102411:	e8 3e e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102416:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102419:	66 85 c0             	test   %ax,%ax
8010241c:	75 02                	jne    80102420 <dirlink+0x83>
      break;
8010241e:	eb 16                	jmp    80102436 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102423:	83 c0 10             	add    $0x10,%eax
80102426:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102429:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010242c:	8b 45 08             	mov    0x8(%ebp),%eax
8010242f:	8b 40 58             	mov    0x58(%eax),%eax
80102432:	39 c2                	cmp    %eax,%edx
80102434:	72 ae                	jb     801023e4 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102436:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010243d:	00 
8010243e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102448:	83 c0 02             	add    $0x2,%eax
8010244b:	89 04 24             	mov    %eax,(%esp)
8010244e:	e8 69 32 00 00       	call   801056bc <strncpy>
  de.inum = inum;
80102453:	8b 45 10             	mov    0x10(%ebp),%eax
80102456:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102464:	00 
80102465:	89 44 24 08          	mov    %eax,0x8(%esp)
80102469:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010246c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102470:	8b 45 08             	mov    0x8(%ebp),%eax
80102473:	89 04 24             	mov    %eax,(%esp)
80102476:	e8 42 fc ff ff       	call   801020bd <writei>
8010247b:	83 f8 10             	cmp    $0x10,%eax
8010247e:	74 0c                	je     8010248c <dirlink+0xef>
    panic("dirlink");
80102480:	c7 04 24 0d 96 10 80 	movl   $0x8010960d,(%esp)
80102487:	e8 c8 e0 ff ff       	call   80100554 <panic>

  return 0;
8010248c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102491:	c9                   	leave  
80102492:	c3                   	ret    

80102493 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102493:	55                   	push   %ebp
80102494:	89 e5                	mov    %esp,%ebp
80102496:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102499:	eb 03                	jmp    8010249e <skipelem+0xb>
    path++;
8010249b:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010249e:	8b 45 08             	mov    0x8(%ebp),%eax
801024a1:	8a 00                	mov    (%eax),%al
801024a3:	3c 2f                	cmp    $0x2f,%al
801024a5:	74 f4                	je     8010249b <skipelem+0x8>
    path++;
  if(*path == 0)
801024a7:	8b 45 08             	mov    0x8(%ebp),%eax
801024aa:	8a 00                	mov    (%eax),%al
801024ac:	84 c0                	test   %al,%al
801024ae:	75 0a                	jne    801024ba <skipelem+0x27>
    return 0;
801024b0:	b8 00 00 00 00       	mov    $0x0,%eax
801024b5:	e9 81 00 00 00       	jmp    8010253b <skipelem+0xa8>
  s = path;
801024ba:	8b 45 08             	mov    0x8(%ebp),%eax
801024bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024c0:	eb 03                	jmp    801024c5 <skipelem+0x32>
    path++;
801024c2:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801024c5:	8b 45 08             	mov    0x8(%ebp),%eax
801024c8:	8a 00                	mov    (%eax),%al
801024ca:	3c 2f                	cmp    $0x2f,%al
801024cc:	74 09                	je     801024d7 <skipelem+0x44>
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	8a 00                	mov    (%eax),%al
801024d3:	84 c0                	test   %al,%al
801024d5:	75 eb                	jne    801024c2 <skipelem+0x2f>
    path++;
  len = path - s;
801024d7:	8b 55 08             	mov    0x8(%ebp),%edx
801024da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024dd:	29 c2                	sub    %eax,%edx
801024df:	89 d0                	mov    %edx,%eax
801024e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024e4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024e8:	7e 1c                	jle    80102506 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801024ea:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024f1:	00 
801024f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801024f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801024fc:	89 04 24             	mov    %eax,(%esp)
801024ff:	e8 cb 30 00 00       	call   801055cf <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102504:	eb 29                	jmp    8010252f <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102509:	89 44 24 08          	mov    %eax,0x8(%esp)
8010250d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102510:	89 44 24 04          	mov    %eax,0x4(%esp)
80102514:	8b 45 0c             	mov    0xc(%ebp),%eax
80102517:	89 04 24             	mov    %eax,(%esp)
8010251a:	e8 b0 30 00 00       	call   801055cf <memmove>
    name[len] = 0;
8010251f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102522:	8b 45 0c             	mov    0xc(%ebp),%eax
80102525:	01 d0                	add    %edx,%eax
80102527:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010252a:	eb 03                	jmp    8010252f <skipelem+0x9c>
    path++;
8010252c:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010252f:	8b 45 08             	mov    0x8(%ebp),%eax
80102532:	8a 00                	mov    (%eax),%al
80102534:	3c 2f                	cmp    $0x2f,%al
80102536:	74 f4                	je     8010252c <skipelem+0x99>
    path++;
  return path;
80102538:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010253b:	c9                   	leave  
8010253c:	c3                   	ret    

8010253d <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102543:	8b 45 08             	mov    0x8(%ebp),%eax
80102546:	8a 00                	mov    (%eax),%al
80102548:	3c 2f                	cmp    $0x2f,%al
8010254a:	75 1c                	jne    80102568 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010254c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102553:	00 
80102554:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010255b:	e8 5b f4 ff ff       	call   801019bb <iget>
80102560:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102563:	e9 ac 00 00 00       	jmp    80102614 <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80102568:	e8 36 1e 00 00       	call   801043a3 <myproc>
8010256d:	8b 40 68             	mov    0x68(%eax),%eax
80102570:	89 04 24             	mov    %eax,(%esp)
80102573:	e8 18 f5 ff ff       	call   80101a90 <idup>
80102578:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010257b:	e9 94 00 00 00       	jmp    80102614 <namex+0xd7>
    ilock(ip);
80102580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102583:	89 04 24             	mov    %eax,(%esp)
80102586:	e8 37 f5 ff ff       	call   80101ac2 <ilock>
    if(ip->type != T_DIR){
8010258b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010258e:	8b 40 50             	mov    0x50(%eax),%eax
80102591:	66 83 f8 01          	cmp    $0x1,%ax
80102595:	74 15                	je     801025ac <namex+0x6f>
      iunlockput(ip);
80102597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010259a:	89 04 24             	mov    %eax,(%esp)
8010259d:	e8 1f f7 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801025a2:	b8 00 00 00 00       	mov    $0x0,%eax
801025a7:	e9 a2 00 00 00       	jmp    8010264e <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
801025ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025b0:	74 1c                	je     801025ce <namex+0x91>
801025b2:	8b 45 08             	mov    0x8(%ebp),%eax
801025b5:	8a 00                	mov    (%eax),%al
801025b7:	84 c0                	test   %al,%al
801025b9:	75 13                	jne    801025ce <namex+0x91>
      // Stop one level early.
      iunlock(ip);
801025bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025be:	89 04 24             	mov    %eax,(%esp)
801025c1:	e8 06 f6 ff ff       	call   80101bcc <iunlock>
      return ip;
801025c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c9:	e9 80 00 00 00       	jmp    8010264e <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801025d5:	00 
801025d6:	8b 45 10             	mov    0x10(%ebp),%eax
801025d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801025dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e0:	89 04 24             	mov    %eax,(%esp)
801025e3:	e8 ef fc ff ff       	call   801022d7 <dirlookup>
801025e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025ef:	75 12                	jne    80102603 <namex+0xc6>
      iunlockput(ip);
801025f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f4:	89 04 24             	mov    %eax,(%esp)
801025f7:	e8 c5 f6 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801025fc:	b8 00 00 00 00       	mov    $0x0,%eax
80102601:	eb 4b                	jmp    8010264e <namex+0x111>
    }
    iunlockput(ip);
80102603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102606:	89 04 24             	mov    %eax,(%esp)
80102609:	e8 b3 f6 ff ff       	call   80101cc1 <iunlockput>
    ip = next;
8010260e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102611:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102614:	8b 45 10             	mov    0x10(%ebp),%eax
80102617:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261b:	8b 45 08             	mov    0x8(%ebp),%eax
8010261e:	89 04 24             	mov    %eax,(%esp)
80102621:	e8 6d fe ff ff       	call   80102493 <skipelem>
80102626:	89 45 08             	mov    %eax,0x8(%ebp)
80102629:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010262d:	0f 85 4d ff ff ff    	jne    80102580 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102633:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102637:	74 12                	je     8010264b <namex+0x10e>
    iput(ip);
80102639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010263c:	89 04 24             	mov    %eax,(%esp)
8010263f:	e8 cc f5 ff ff       	call   80101c10 <iput>
    return 0;
80102644:	b8 00 00 00 00       	mov    $0x0,%eax
80102649:	eb 03                	jmp    8010264e <namex+0x111>
  //     else{
  //       temp = 
  //     }
  //   }
  // }
  return ip;
8010264b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010264e:	c9                   	leave  
8010264f:	c3                   	ret    

80102650 <namei>:

struct inode*
namei(char *path)
{
80102650:	55                   	push   %ebp
80102651:	89 e5                	mov    %esp,%ebp
80102653:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102656:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102659:	89 44 24 08          	mov    %eax,0x8(%esp)
8010265d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102664:	00 
80102665:	8b 45 08             	mov    0x8(%ebp),%eax
80102668:	89 04 24             	mov    %eax,(%esp)
8010266b:	e8 cd fe ff ff       	call   8010253d <namex>
}
80102670:	c9                   	leave  
80102671:	c3                   	ret    

80102672 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102672:	55                   	push   %ebp
80102673:	89 e5                	mov    %esp,%ebp
80102675:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102678:	8b 45 0c             	mov    0xc(%ebp),%eax
8010267b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010267f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102686:	00 
80102687:	8b 45 08             	mov    0x8(%ebp),%eax
8010268a:	89 04 24             	mov    %eax,(%esp)
8010268d:	e8 ab fe ff ff       	call   8010253d <namex>
}
80102692:	c9                   	leave  
80102693:	c3                   	ret    

80102694 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102694:	55                   	push   %ebp
80102695:	89 e5                	mov    %esp,%ebp
80102697:	83 ec 14             	sub    $0x14,%esp
8010269a:	8b 45 08             	mov    0x8(%ebp),%eax
8010269d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026a4:	89 c2                	mov    %eax,%edx
801026a6:	ec                   	in     (%dx),%al
801026a7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026aa:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801026ad:	c9                   	leave  
801026ae:	c3                   	ret    

801026af <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801026af:	55                   	push   %ebp
801026b0:	89 e5                	mov    %esp,%ebp
801026b2:	57                   	push   %edi
801026b3:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026b4:	8b 55 08             	mov    0x8(%ebp),%edx
801026b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026ba:	8b 45 10             	mov    0x10(%ebp),%eax
801026bd:	89 cb                	mov    %ecx,%ebx
801026bf:	89 df                	mov    %ebx,%edi
801026c1:	89 c1                	mov    %eax,%ecx
801026c3:	fc                   	cld    
801026c4:	f3 6d                	rep insl (%dx),%es:(%edi)
801026c6:	89 c8                	mov    %ecx,%eax
801026c8:	89 fb                	mov    %edi,%ebx
801026ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026cd:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801026d0:	5b                   	pop    %ebx
801026d1:	5f                   	pop    %edi
801026d2:	5d                   	pop    %ebp
801026d3:	c3                   	ret    

801026d4 <outb>:

static inline void
outb(ushort port, uchar data)
{
801026d4:	55                   	push   %ebp
801026d5:	89 e5                	mov    %esp,%ebp
801026d7:	83 ec 08             	sub    $0x8,%esp
801026da:	8b 45 08             	mov    0x8(%ebp),%eax
801026dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801026e0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801026e4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801026e7:	8a 45 f8             	mov    -0x8(%ebp),%al
801026ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
801026ed:	ee                   	out    %al,(%dx)
}
801026ee:	c9                   	leave  
801026ef:	c3                   	ret    

801026f0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801026f0:	55                   	push   %ebp
801026f1:	89 e5                	mov    %esp,%ebp
801026f3:	56                   	push   %esi
801026f4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801026f5:	8b 55 08             	mov    0x8(%ebp),%edx
801026f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026fb:	8b 45 10             	mov    0x10(%ebp),%eax
801026fe:	89 cb                	mov    %ecx,%ebx
80102700:	89 de                	mov    %ebx,%esi
80102702:	89 c1                	mov    %eax,%ecx
80102704:	fc                   	cld    
80102705:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102707:	89 c8                	mov    %ecx,%eax
80102709:	89 f3                	mov    %esi,%ebx
8010270b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010270e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102711:	5b                   	pop    %ebx
80102712:	5e                   	pop    %esi
80102713:	5d                   	pop    %ebp
80102714:	c3                   	ret    

80102715 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102715:	55                   	push   %ebp
80102716:	89 e5                	mov    %esp,%ebp
80102718:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010271b:	90                   	nop
8010271c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102723:	e8 6c ff ff ff       	call   80102694 <inb>
80102728:	0f b6 c0             	movzbl %al,%eax
8010272b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010272e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102731:	25 c0 00 00 00       	and    $0xc0,%eax
80102736:	83 f8 40             	cmp    $0x40,%eax
80102739:	75 e1                	jne    8010271c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010273b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010273f:	74 11                	je     80102752 <idewait+0x3d>
80102741:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102744:	83 e0 21             	and    $0x21,%eax
80102747:	85 c0                	test   %eax,%eax
80102749:	74 07                	je     80102752 <idewait+0x3d>
    return -1;
8010274b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102750:	eb 05                	jmp    80102757 <idewait+0x42>
  return 0;
80102752:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102757:	c9                   	leave  
80102758:	c3                   	ret    

80102759 <ideinit>:

void
ideinit(void)
{
80102759:	55                   	push   %ebp
8010275a:	89 e5                	mov    %esp,%ebp
8010275c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010275f:	c7 44 24 04 15 96 10 	movl   $0x80109615,0x4(%esp)
80102766:	80 
80102767:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
8010276e:	e8 0f 2b 00 00       	call   80105282 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102773:	a1 00 52 11 80       	mov    0x80115200,%eax
80102778:	48                   	dec    %eax
80102779:	89 44 24 04          	mov    %eax,0x4(%esp)
8010277d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102784:	e8 66 04 00 00       	call   80102bef <ioapicenable>
  idewait(0);
80102789:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102790:	e8 80 ff ff ff       	call   80102715 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102795:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010279c:	00 
8010279d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027a4:	e8 2b ff ff ff       	call   801026d4 <outb>
  for(i=0; i<1000; i++){
801027a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027b0:	eb 1f                	jmp    801027d1 <ideinit+0x78>
    if(inb(0x1f7) != 0){
801027b2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027b9:	e8 d6 fe ff ff       	call   80102694 <inb>
801027be:	84 c0                	test   %al,%al
801027c0:	74 0c                	je     801027ce <ideinit+0x75>
      havedisk1 = 1;
801027c2:	c7 05 f8 c8 10 80 01 	movl   $0x1,0x8010c8f8
801027c9:	00 00 00 
      break;
801027cc:	eb 0c                	jmp    801027da <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801027ce:	ff 45 f4             	incl   -0xc(%ebp)
801027d1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801027d8:	7e d8                	jle    801027b2 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801027da:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801027e1:	00 
801027e2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027e9:	e8 e6 fe ff ff       	call   801026d4 <outb>
}
801027ee:	c9                   	leave  
801027ef:	c3                   	ret    

801027f0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801027f0:	55                   	push   %ebp
801027f1:	89 e5                	mov    %esp,%ebp
801027f3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801027f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027fa:	75 0c                	jne    80102808 <idestart+0x18>
    panic("idestart");
801027fc:	c7 04 24 19 96 10 80 	movl   $0x80109619,(%esp)
80102803:	e8 4c dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102808:	8b 45 08             	mov    0x8(%ebp),%eax
8010280b:	8b 40 08             	mov    0x8(%eax),%eax
8010280e:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
80102813:	76 0c                	jbe    80102821 <idestart+0x31>
    panic("incorrect blockno");
80102815:	c7 04 24 22 96 10 80 	movl   $0x80109622,(%esp)
8010281c:	e8 33 dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102821:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102828:	8b 45 08             	mov    0x8(%ebp),%eax
8010282b:	8b 50 08             	mov    0x8(%eax),%edx
8010282e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102831:	0f af c2             	imul   %edx,%eax
80102834:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102837:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010283b:	75 07                	jne    80102844 <idestart+0x54>
8010283d:	b8 20 00 00 00       	mov    $0x20,%eax
80102842:	eb 05                	jmp    80102849 <idestart+0x59>
80102844:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010284c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102850:	75 07                	jne    80102859 <idestart+0x69>
80102852:	b8 30 00 00 00       	mov    $0x30,%eax
80102857:	eb 05                	jmp    8010285e <idestart+0x6e>
80102859:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010285e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102861:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102865:	7e 0c                	jle    80102873 <idestart+0x83>
80102867:	c7 04 24 19 96 10 80 	movl   $0x80109619,(%esp)
8010286e:	e8 e1 dc ff ff       	call   80100554 <panic>

  idewait(0);
80102873:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010287a:	e8 96 fe ff ff       	call   80102715 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010287f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102886:	00 
80102887:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010288e:	e8 41 fe ff ff       	call   801026d4 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102896:	0f b6 c0             	movzbl %al,%eax
80102899:	89 44 24 04          	mov    %eax,0x4(%esp)
8010289d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801028a4:	e8 2b fe ff ff       	call   801026d4 <outb>
  outb(0x1f3, sector & 0xff);
801028a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ac:	0f b6 c0             	movzbl %al,%eax
801028af:	89 44 24 04          	mov    %eax,0x4(%esp)
801028b3:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801028ba:	e8 15 fe ff ff       	call   801026d4 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801028bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028c2:	c1 f8 08             	sar    $0x8,%eax
801028c5:	0f b6 c0             	movzbl %al,%eax
801028c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028cc:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801028d3:	e8 fc fd ff ff       	call   801026d4 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801028d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028db:	c1 f8 10             	sar    $0x10,%eax
801028de:	0f b6 c0             	movzbl %al,%eax
801028e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801028e5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801028ec:	e8 e3 fd ff ff       	call   801026d4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028f1:	8b 45 08             	mov    0x8(%ebp),%eax
801028f4:	8b 40 04             	mov    0x4(%eax),%eax
801028f7:	83 e0 01             	and    $0x1,%eax
801028fa:	c1 e0 04             	shl    $0x4,%eax
801028fd:	88 c2                	mov    %al,%dl
801028ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102902:	c1 f8 18             	sar    $0x18,%eax
80102905:	83 e0 0f             	and    $0xf,%eax
80102908:	09 d0                	or     %edx,%eax
8010290a:	83 c8 e0             	or     $0xffffffe0,%eax
8010290d:	0f b6 c0             	movzbl %al,%eax
80102910:	89 44 24 04          	mov    %eax,0x4(%esp)
80102914:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010291b:	e8 b4 fd ff ff       	call   801026d4 <outb>
  if(b->flags & B_DIRTY){
80102920:	8b 45 08             	mov    0x8(%ebp),%eax
80102923:	8b 00                	mov    (%eax),%eax
80102925:	83 e0 04             	and    $0x4,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	74 36                	je     80102962 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010292c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010292f:	0f b6 c0             	movzbl %al,%eax
80102932:	89 44 24 04          	mov    %eax,0x4(%esp)
80102936:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010293d:	e8 92 fd ff ff       	call   801026d4 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102942:	8b 45 08             	mov    0x8(%ebp),%eax
80102945:	83 c0 5c             	add    $0x5c,%eax
80102948:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010294f:	00 
80102950:	89 44 24 04          	mov    %eax,0x4(%esp)
80102954:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010295b:	e8 90 fd ff ff       	call   801026f0 <outsl>
80102960:	eb 16                	jmp    80102978 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102962:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102965:	0f b6 c0             	movzbl %al,%eax
80102968:	89 44 24 04          	mov    %eax,0x4(%esp)
8010296c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102973:	e8 5c fd ff ff       	call   801026d4 <outb>
  }
}
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102980:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102987:	e8 17 29 00 00       	call   801052a3 <acquire>

  if((b = idequeue) == 0){
8010298c:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102994:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102998:	75 11                	jne    801029ab <ideintr+0x31>
    release(&idelock);
8010299a:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
801029a1:	e8 67 29 00 00       	call   8010530d <release>
    return;
801029a6:	e9 90 00 00 00       	jmp    80102a3b <ideintr+0xc1>
  }
  idequeue = b->qnext;
801029ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ae:	8b 40 58             	mov    0x58(%eax),%eax
801029b1:	a3 f4 c8 10 80       	mov    %eax,0x8010c8f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801029b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b9:	8b 00                	mov    (%eax),%eax
801029bb:	83 e0 04             	and    $0x4,%eax
801029be:	85 c0                	test   %eax,%eax
801029c0:	75 2e                	jne    801029f0 <ideintr+0x76>
801029c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801029c9:	e8 47 fd ff ff       	call   80102715 <idewait>
801029ce:	85 c0                	test   %eax,%eax
801029d0:	78 1e                	js     801029f0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801029d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d5:	83 c0 5c             	add    $0x5c,%eax
801029d8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029df:	00 
801029e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029eb:	e8 bf fc ff ff       	call   801026af <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f3:	8b 00                	mov    (%eax),%eax
801029f5:	83 c8 02             	or     $0x2,%eax
801029f8:	89 c2                	mov    %eax,%edx
801029fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fd:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a02:	8b 00                	mov    (%eax),%eax
80102a04:	83 e0 fb             	and    $0xfffffffb,%eax
80102a07:	89 c2                	mov    %eax,%edx
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a11:	89 04 24             	mov    %eax,(%esp)
80102a14:	e8 12 23 00 00       	call   80104d2b <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a19:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102a1e:	85 c0                	test   %eax,%eax
80102a20:	74 0d                	je     80102a2f <ideintr+0xb5>
    idestart(idequeue);
80102a22:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102a27:	89 04 24             	mov    %eax,(%esp)
80102a2a:	e8 c1 fd ff ff       	call   801027f0 <idestart>

  release(&idelock);
80102a2f:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102a36:	e8 d2 28 00 00       	call   8010530d <release>
}
80102a3b:	c9                   	leave  
80102a3c:	c3                   	ret    

80102a3d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a3d:	55                   	push   %ebp
80102a3e:	89 e5                	mov    %esp,%ebp
80102a40:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102a43:	8b 45 08             	mov    0x8(%ebp),%eax
80102a46:	83 c0 0c             	add    $0xc,%eax
80102a49:	89 04 24             	mov    %eax,(%esp)
80102a4c:	e8 ca 27 00 00       	call   8010521b <holdingsleep>
80102a51:	85 c0                	test   %eax,%eax
80102a53:	75 0c                	jne    80102a61 <iderw+0x24>
    panic("iderw: buf not locked");
80102a55:	c7 04 24 34 96 10 80 	movl   $0x80109634,(%esp)
80102a5c:	e8 f3 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a61:	8b 45 08             	mov    0x8(%ebp),%eax
80102a64:	8b 00                	mov    (%eax),%eax
80102a66:	83 e0 06             	and    $0x6,%eax
80102a69:	83 f8 02             	cmp    $0x2,%eax
80102a6c:	75 0c                	jne    80102a7a <iderw+0x3d>
    panic("iderw: nothing to do");
80102a6e:	c7 04 24 4a 96 10 80 	movl   $0x8010964a,(%esp)
80102a75:	e8 da da ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7d:	8b 40 04             	mov    0x4(%eax),%eax
80102a80:	85 c0                	test   %eax,%eax
80102a82:	74 15                	je     80102a99 <iderw+0x5c>
80102a84:	a1 f8 c8 10 80       	mov    0x8010c8f8,%eax
80102a89:	85 c0                	test   %eax,%eax
80102a8b:	75 0c                	jne    80102a99 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102a8d:	c7 04 24 5f 96 10 80 	movl   $0x8010965f,(%esp)
80102a94:	e8 bb da ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a99:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102aa0:	e8 fe 27 00 00       	call   801052a3 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102aaf:	c7 45 f4 f4 c8 10 80 	movl   $0x8010c8f4,-0xc(%ebp)
80102ab6:	eb 0b                	jmp    80102ac3 <iderw+0x86>
80102ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abb:	8b 00                	mov    (%eax),%eax
80102abd:	83 c0 58             	add    $0x58,%eax
80102ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac6:	8b 00                	mov    (%eax),%eax
80102ac8:	85 c0                	test   %eax,%eax
80102aca:	75 ec                	jne    80102ab8 <iderw+0x7b>
    ;
  *pp = b;
80102acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ad4:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102ad9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102adc:	75 0d                	jne    80102aeb <iderw+0xae>
    idestart(b);
80102ade:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae1:	89 04 24             	mov    %eax,(%esp)
80102ae4:	e8 07 fd ff ff       	call   801027f0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ae9:	eb 15                	jmp    80102b00 <iderw+0xc3>
80102aeb:	eb 13                	jmp    80102b00 <iderw+0xc3>
    sleep(b, &idelock);
80102aed:	c7 44 24 04 c0 c8 10 	movl   $0x8010c8c0,0x4(%esp)
80102af4:	80 
80102af5:	8b 45 08             	mov    0x8(%ebp),%eax
80102af8:	89 04 24             	mov    %eax,(%esp)
80102afb:	e8 54 21 00 00       	call   80104c54 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b00:	8b 45 08             	mov    0x8(%ebp),%eax
80102b03:	8b 00                	mov    (%eax),%eax
80102b05:	83 e0 06             	and    $0x6,%eax
80102b08:	83 f8 02             	cmp    $0x2,%eax
80102b0b:	75 e0                	jne    80102aed <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102b0d:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102b14:	e8 f4 27 00 00       	call   8010530d <release>
}
80102b19:	c9                   	leave  
80102b1a:	c3                   	ret    
	...

80102b1c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b1f:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102b24:	8b 55 08             	mov    0x8(%ebp),%edx
80102b27:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b29:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102b2e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b31:	5d                   	pop    %ebp
80102b32:	c3                   	ret    

80102b33 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b33:	55                   	push   %ebp
80102b34:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b36:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102b3b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b3e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b40:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102b45:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b48:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b4b:	5d                   	pop    %ebp
80102b4c:	c3                   	ret    

80102b4d <ioapicinit>:

void
ioapicinit(void)
{
80102b4d:	55                   	push   %ebp
80102b4e:	89 e5                	mov    %esp,%ebp
80102b50:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b53:	c7 05 34 4b 11 80 00 	movl   $0xfec00000,0x80114b34
80102b5a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b64:	e8 b3 ff ff ff       	call   80102b1c <ioapicread>
80102b69:	c1 e8 10             	shr    $0x10,%eax
80102b6c:	25 ff 00 00 00       	and    $0xff,%eax
80102b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102b7b:	e8 9c ff ff ff       	call   80102b1c <ioapicread>
80102b80:	c1 e8 18             	shr    $0x18,%eax
80102b83:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b86:	a0 60 4c 11 80       	mov    0x80114c60,%al
80102b8b:	0f b6 c0             	movzbl %al,%eax
80102b8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b91:	74 0c                	je     80102b9f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b93:	c7 04 24 80 96 10 80 	movl   $0x80109680,(%esp)
80102b9a:	e8 22 d8 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ba6:	eb 3d                	jmp    80102be5 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bab:	83 c0 20             	add    $0x20,%eax
80102bae:	0d 00 00 01 00       	or     $0x10000,%eax
80102bb3:	89 c2                	mov    %eax,%edx
80102bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb8:	83 c0 08             	add    $0x8,%eax
80102bbb:	01 c0                	add    %eax,%eax
80102bbd:	89 54 24 04          	mov    %edx,0x4(%esp)
80102bc1:	89 04 24             	mov    %eax,(%esp)
80102bc4:	e8 6a ff ff ff       	call   80102b33 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bcc:	83 c0 08             	add    $0x8,%eax
80102bcf:	01 c0                	add    %eax,%eax
80102bd1:	40                   	inc    %eax
80102bd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102bd9:	00 
80102bda:	89 04 24             	mov    %eax,(%esp)
80102bdd:	e8 51 ff ff ff       	call   80102b33 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102be2:	ff 45 f4             	incl   -0xc(%ebp)
80102be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102beb:	7e bb                	jle    80102ba8 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102bed:	c9                   	leave  
80102bee:	c3                   	ret    

80102bef <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102bef:	55                   	push   %ebp
80102bf0:	89 e5                	mov    %esp,%ebp
80102bf2:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf8:	83 c0 20             	add    $0x20,%eax
80102bfb:	89 c2                	mov    %eax,%edx
80102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80102c00:	83 c0 08             	add    $0x8,%eax
80102c03:	01 c0                	add    %eax,%eax
80102c05:	89 54 24 04          	mov    %edx,0x4(%esp)
80102c09:	89 04 24             	mov    %eax,(%esp)
80102c0c:	e8 22 ff ff ff       	call   80102b33 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c14:	c1 e0 18             	shl    $0x18,%eax
80102c17:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1a:	83 c2 08             	add    $0x8,%edx
80102c1d:	01 d2                	add    %edx,%edx
80102c1f:	42                   	inc    %edx
80102c20:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c24:	89 14 24             	mov    %edx,(%esp)
80102c27:	e8 07 ff ff ff       	call   80102b33 <ioapicwrite>
}
80102c2c:	c9                   	leave  
80102c2d:	c3                   	ret    
	...

80102c30 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c30:	55                   	push   %ebp
80102c31:	89 e5                	mov    %esp,%ebp
80102c33:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102c36:	c7 44 24 04 b2 96 10 	movl   $0x801096b2,0x4(%esp)
80102c3d:	80 
80102c3e:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102c45:	e8 38 26 00 00       	call   80105282 <initlock>
  kmem.use_lock = 0;
80102c4a:	c7 05 74 4b 11 80 00 	movl   $0x0,0x80114b74
80102c51:	00 00 00 
  freerange(vstart, vend);
80102c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c57:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5e:	89 04 24             	mov    %eax,(%esp)
80102c61:	e8 26 00 00 00       	call   80102c8c <freerange>
}
80102c66:	c9                   	leave  
80102c67:	c3                   	ret    

80102c68 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c68:	55                   	push   %ebp
80102c69:	89 e5                	mov    %esp,%ebp
80102c6b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c71:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c75:	8b 45 08             	mov    0x8(%ebp),%eax
80102c78:	89 04 24             	mov    %eax,(%esp)
80102c7b:	e8 0c 00 00 00       	call   80102c8c <freerange>
  kmem.use_lock = 1;
80102c80:	c7 05 74 4b 11 80 01 	movl   $0x1,0x80114b74
80102c87:	00 00 00 
}
80102c8a:	c9                   	leave  
80102c8b:	c3                   	ret    

80102c8c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c8c:	55                   	push   %ebp
80102c8d:	89 e5                	mov    %esp,%ebp
80102c8f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c92:	8b 45 08             	mov    0x8(%ebp),%eax
80102c95:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ca2:	eb 12                	jmp    80102cb6 <freerange+0x2a>
    kfree(p);
80102ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca7:	89 04 24             	mov    %eax,(%esp)
80102caa:	e8 16 00 00 00       	call   80102cc5 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102caf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb9:	05 00 10 00 00       	add    $0x1000,%eax
80102cbe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102cc1:	76 e1                	jbe    80102ca4 <freerange+0x18>
    kfree(p);
}
80102cc3:	c9                   	leave  
80102cc4:	c3                   	ret    

80102cc5 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cc5:	55                   	push   %ebp
80102cc6:	89 e5                	mov    %esp,%ebp
80102cc8:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cce:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cd3:	85 c0                	test   %eax,%eax
80102cd5:	75 18                	jne    80102cef <kfree+0x2a>
80102cd7:	81 7d 08 b0 7c 11 80 	cmpl   $0x80117cb0,0x8(%ebp)
80102cde:	72 0f                	jb     80102cef <kfree+0x2a>
80102ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce3:	05 00 00 00 80       	add    $0x80000000,%eax
80102ce8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ced:	76 0c                	jbe    80102cfb <kfree+0x36>
    panic("kfree");
80102cef:	c7 04 24 b7 96 10 80 	movl   $0x801096b7,(%esp)
80102cf6:	e8 59 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cfb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102d02:	00 
80102d03:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d0a:	00 
80102d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0e:	89 04 24             	mov    %eax,(%esp)
80102d11:	e8 f0 27 00 00       	call   80105506 <memset>

  if(kmem.use_lock){
80102d16:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 48                	je     80102d67 <kfree+0xa2>
    acquire(&kmem.lock);
80102d1f:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d26:	e8 78 25 00 00       	call   801052a3 <acquire>
    if(ticks > 1){
80102d2b:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102d30:	83 f8 01             	cmp    $0x1,%eax
80102d33:	76 32                	jbe    80102d67 <kfree+0xa2>
      int x = find(myproc()->cont->name);
80102d35:	e8 69 16 00 00       	call   801043a3 <myproc>
80102d3a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102d40:	83 c0 18             	add    $0x18,%eax
80102d43:	89 04 24             	mov    %eax,(%esp)
80102d46:	e8 c0 60 00 00       	call   80108e0b <find>
80102d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d52:	78 13                	js     80102d67 <kfree+0xa2>
        reduce_curr_mem(1, x);
80102d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d57:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102d62:	e8 b9 63 00 00       	call   80109120 <reduce_curr_mem>
      }
    }
  }
  r = (struct run*)v;
80102d67:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102d6d:	8b 15 78 4b 11 80    	mov    0x80114b78,%edx
80102d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d76:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d7b:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102d80:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d85:	85 c0                	test   %eax,%eax
80102d87:	74 0c                	je     80102d95 <kfree+0xd0>
    release(&kmem.lock);
80102d89:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d90:	e8 78 25 00 00       	call   8010530d <release>
}
80102d95:	c9                   	leave  
80102d96:	c3                   	ret    

80102d97 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d97:	55                   	push   %ebp
80102d98:	89 e5                	mov    %esp,%ebp
80102d9a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102d9d:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102da2:	85 c0                	test   %eax,%eax
80102da4:	74 0c                	je     80102db2 <kalloc+0x1b>
    acquire(&kmem.lock);
80102da6:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102dad:	e8 f1 24 00 00       	call   801052a3 <acquire>
  }
  r = kmem.freelist;
80102db2:	a1 78 4b 11 80       	mov    0x80114b78,%eax
80102db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102dba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dbe:	74 0a                	je     80102dca <kalloc+0x33>
    kmem.freelist = r->next;
80102dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dc3:	8b 00                	mov    (%eax),%eax
80102dc5:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if((char*)r != 0){
80102dca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dce:	74 3b                	je     80102e0b <kalloc+0x74>
    if(ticks > 0){
80102dd0:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102dd5:	85 c0                	test   %eax,%eax
80102dd7:	74 32                	je     80102e0b <kalloc+0x74>
      int x = find(myproc()->cont->name);
80102dd9:	e8 c5 15 00 00       	call   801043a3 <myproc>
80102dde:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102de4:	83 c0 18             	add    $0x18,%eax
80102de7:	89 04 24             	mov    %eax,(%esp)
80102dea:	e8 1c 60 00 00       	call   80108e0b <find>
80102def:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102df2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102df6:	78 13                	js     80102e0b <kalloc+0x74>
        set_curr_mem(1, x);
80102df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e06:	e8 d3 62 00 00       	call   801090de <set_curr_mem>
      }
   }
  }
  if(kmem.use_lock)
80102e0b:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102e10:	85 c0                	test   %eax,%eax
80102e12:	74 0c                	je     80102e20 <kalloc+0x89>
    release(&kmem.lock);
80102e14:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102e1b:	e8 ed 24 00 00       	call   8010530d <release>
  return (char*)r;
80102e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e23:	c9                   	leave  
80102e24:	c3                   	ret    
80102e25:	00 00                	add    %al,(%eax)
	...

80102e28 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e28:	55                   	push   %ebp
80102e29:	89 e5                	mov    %esp,%ebp
80102e2b:	83 ec 14             	sub    $0x14,%esp
80102e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e31:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e38:	89 c2                	mov    %eax,%edx
80102e3a:	ec                   	in     (%dx),%al
80102e3b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e3e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102e41:	c9                   	leave  
80102e42:	c3                   	ret    

80102e43 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e43:	55                   	push   %ebp
80102e44:	89 e5                	mov    %esp,%ebp
80102e46:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e49:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102e50:	e8 d3 ff ff ff       	call   80102e28 <inb>
80102e55:	0f b6 c0             	movzbl %al,%eax
80102e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e5e:	83 e0 01             	and    $0x1,%eax
80102e61:	85 c0                	test   %eax,%eax
80102e63:	75 0a                	jne    80102e6f <kbdgetc+0x2c>
    return -1;
80102e65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e6a:	e9 21 01 00 00       	jmp    80102f90 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102e6f:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e76:	e8 ad ff ff ff       	call   80102e28 <inb>
80102e7b:	0f b6 c0             	movzbl %al,%eax
80102e7e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e81:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e88:	75 17                	jne    80102ea1 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e8a:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e8f:	83 c8 40             	or     $0x40,%eax
80102e92:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102e97:	b8 00 00 00 00       	mov    $0x0,%eax
80102e9c:	e9 ef 00 00 00       	jmp    80102f90 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102ea1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ea4:	25 80 00 00 00       	and    $0x80,%eax
80102ea9:	85 c0                	test   %eax,%eax
80102eab:	74 44                	je     80102ef1 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ead:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102eb2:	83 e0 40             	and    $0x40,%eax
80102eb5:	85 c0                	test   %eax,%eax
80102eb7:	75 08                	jne    80102ec1 <kbdgetc+0x7e>
80102eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ebc:	83 e0 7f             	and    $0x7f,%eax
80102ebf:	eb 03                	jmp    80102ec4 <kbdgetc+0x81>
80102ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eca:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ecf:	8a 00                	mov    (%eax),%al
80102ed1:	83 c8 40             	or     $0x40,%eax
80102ed4:	0f b6 c0             	movzbl %al,%eax
80102ed7:	f7 d0                	not    %eax
80102ed9:	89 c2                	mov    %eax,%edx
80102edb:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ee0:	21 d0                	and    %edx,%eax
80102ee2:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102ee7:	b8 00 00 00 00       	mov    $0x0,%eax
80102eec:	e9 9f 00 00 00       	jmp    80102f90 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102ef1:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ef6:	83 e0 40             	and    $0x40,%eax
80102ef9:	85 c0                	test   %eax,%eax
80102efb:	74 14                	je     80102f11 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102efd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f04:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f09:	83 e0 bf             	and    $0xffffffbf,%eax
80102f0c:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  }

  shift |= shiftcode[data];
80102f11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f14:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f19:	8a 00                	mov    (%eax),%al
80102f1b:	0f b6 d0             	movzbl %al,%edx
80102f1e:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f23:	09 d0                	or     %edx,%eax
80102f25:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  shift ^= togglecode[data];
80102f2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2d:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f32:	8a 00                	mov    (%eax),%al
80102f34:	0f b6 d0             	movzbl %al,%edx
80102f37:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f3c:	31 d0                	xor    %edx,%eax
80102f3e:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102f43:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f48:	83 e0 03             	and    $0x3,%eax
80102f4b:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f55:	01 d0                	add    %edx,%eax
80102f57:	8a 00                	mov    (%eax),%al
80102f59:	0f b6 c0             	movzbl %al,%eax
80102f5c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f5f:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f64:	83 e0 08             	and    $0x8,%eax
80102f67:	85 c0                	test   %eax,%eax
80102f69:	74 22                	je     80102f8d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102f6b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f6f:	76 0c                	jbe    80102f7d <kbdgetc+0x13a>
80102f71:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f75:	77 06                	ja     80102f7d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f77:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f7b:	eb 10                	jmp    80102f8d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f7d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f81:	76 0a                	jbe    80102f8d <kbdgetc+0x14a>
80102f83:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f87:	77 04                	ja     80102f8d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f89:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f90:	c9                   	leave  
80102f91:	c3                   	ret    

80102f92 <kbdintr>:

void
kbdintr(void)
{
80102f92:	55                   	push   %ebp
80102f93:	89 e5                	mov    %esp,%ebp
80102f95:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f98:	c7 04 24 43 2e 10 80 	movl   $0x80102e43,(%esp)
80102f9f:	e8 51 d8 ff ff       	call   801007f5 <consoleintr>
}
80102fa4:	c9                   	leave  
80102fa5:	c3                   	ret    
	...

80102fa8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102fa8:	55                   	push   %ebp
80102fa9:	89 e5                	mov    %esp,%ebp
80102fab:	83 ec 14             	sub    $0x14,%esp
80102fae:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fb8:	89 c2                	mov    %eax,%edx
80102fba:	ec                   	in     (%dx),%al
80102fbb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102fbe:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102fc1:	c9                   	leave  
80102fc2:	c3                   	ret    

80102fc3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102fc3:	55                   	push   %ebp
80102fc4:	89 e5                	mov    %esp,%ebp
80102fc6:	83 ec 08             	sub    $0x8,%esp
80102fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fcf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102fd3:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fd6:	8a 45 f8             	mov    -0x8(%ebp),%al
80102fd9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102fdc:	ee                   	out    %al,(%dx)
}
80102fdd:	c9                   	leave  
80102fde:	c3                   	ret    

80102fdf <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fdf:	55                   	push   %ebp
80102fe0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fe2:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102fe7:	8b 55 08             	mov    0x8(%ebp),%edx
80102fea:	c1 e2 02             	shl    $0x2,%edx
80102fed:	01 c2                	add    %eax,%edx
80102fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ff2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ff4:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102ff9:	83 c0 20             	add    $0x20,%eax
80102ffc:	8b 00                	mov    (%eax),%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret    

80103000 <lapicinit>:

void
lapicinit(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
80103003:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80103006:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010300b:	85 c0                	test   %eax,%eax
8010300d:	75 05                	jne    80103014 <lapicinit+0x14>
    return;
8010300f:	e9 43 01 00 00       	jmp    80103157 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103014:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010301b:	00 
8010301c:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103023:	e8 b7 ff ff ff       	call   80102fdf <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103028:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010302f:	00 
80103030:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103037:	e8 a3 ff ff ff       	call   80102fdf <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010303c:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103043:	00 
80103044:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010304b:	e8 8f ff ff ff       	call   80102fdf <lapicw>
  lapicw(TICR, 10000000);
80103050:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103057:	00 
80103058:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010305f:	e8 7b ff ff ff       	call   80102fdf <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103064:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010306b:	00 
8010306c:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103073:	e8 67 ff ff ff       	call   80102fdf <lapicw>
  lapicw(LINT1, MASKED);
80103078:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010307f:	00 
80103080:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103087:	e8 53 ff ff ff       	call   80102fdf <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010308c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103091:	83 c0 30             	add    $0x30,%eax
80103094:	8b 00                	mov    (%eax),%eax
80103096:	c1 e8 10             	shr    $0x10,%eax
80103099:	0f b6 c0             	movzbl %al,%eax
8010309c:	83 f8 03             	cmp    $0x3,%eax
8010309f:	76 14                	jbe    801030b5 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801030a1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030a8:	00 
801030a9:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801030b0:	e8 2a ff ff ff       	call   80102fdf <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030b5:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801030bc:	00 
801030bd:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801030c4:	e8 16 ff ff ff       	call   80102fdf <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030d0:	00 
801030d1:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030d8:	e8 02 ff ff ff       	call   80102fdf <lapicw>
  lapicw(ESR, 0);
801030dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030e4:	00 
801030e5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030ec:	e8 ee fe ff ff       	call   80102fdf <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030f8:	00 
801030f9:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103100:	e8 da fe ff ff       	call   80102fdf <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010310c:	00 
8010310d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103114:	e8 c6 fe ff ff       	call   80102fdf <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103119:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103120:	00 
80103121:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103128:	e8 b2 fe ff ff       	call   80102fdf <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010312d:	90                   	nop
8010312e:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103133:	05 00 03 00 00       	add    $0x300,%eax
80103138:	8b 00                	mov    (%eax),%eax
8010313a:	25 00 10 00 00       	and    $0x1000,%eax
8010313f:	85 c0                	test   %eax,%eax
80103141:	75 eb                	jne    8010312e <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010314a:	00 
8010314b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103152:	e8 88 fe ff ff       	call   80102fdf <lapicw>
}
80103157:	c9                   	leave  
80103158:	c3                   	ret    

80103159 <lapicid>:

int
lapicid(void)
{
80103159:	55                   	push   %ebp
8010315a:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010315c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103161:	85 c0                	test   %eax,%eax
80103163:	75 07                	jne    8010316c <lapicid+0x13>
    return 0;
80103165:	b8 00 00 00 00       	mov    $0x0,%eax
8010316a:	eb 0d                	jmp    80103179 <lapicid+0x20>
  return lapic[ID] >> 24;
8010316c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103171:	83 c0 20             	add    $0x20,%eax
80103174:	8b 00                	mov    (%eax),%eax
80103176:	c1 e8 18             	shr    $0x18,%eax
}
80103179:	5d                   	pop    %ebp
8010317a:	c3                   	ret    

8010317b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010317b:	55                   	push   %ebp
8010317c:	89 e5                	mov    %esp,%ebp
8010317e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103181:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103186:	85 c0                	test   %eax,%eax
80103188:	74 14                	je     8010319e <lapiceoi+0x23>
    lapicw(EOI, 0);
8010318a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103191:	00 
80103192:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103199:	e8 41 fe ff ff       	call   80102fdf <lapicw>
}
8010319e:	c9                   	leave  
8010319f:	c3                   	ret    

801031a0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031a0:	55                   	push   %ebp
801031a1:	89 e5                	mov    %esp,%ebp
}
801031a3:	5d                   	pop    %ebp
801031a4:	c3                   	ret    

801031a5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031a5:	55                   	push   %ebp
801031a6:	89 e5                	mov    %esp,%ebp
801031a8:	83 ec 1c             	sub    $0x1c,%esp
801031ab:	8b 45 08             	mov    0x8(%ebp),%eax
801031ae:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801031b8:	00 
801031b9:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801031c0:	e8 fe fd ff ff       	call   80102fc3 <outb>
  outb(CMOS_PORT+1, 0x0A);
801031c5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801031cc:	00 
801031cd:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801031d4:	e8 ea fd ff ff       	call   80102fc3 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031d9:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031e3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031eb:	8d 50 02             	lea    0x2(%eax),%edx
801031ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f1:	c1 e8 04             	shr    $0x4,%eax
801031f4:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031f7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031fb:	c1 e0 18             	shl    $0x18,%eax
801031fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103202:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103209:	e8 d1 fd ff ff       	call   80102fdf <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010320e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103215:	00 
80103216:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010321d:	e8 bd fd ff ff       	call   80102fdf <lapicw>
  microdelay(200);
80103222:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103229:	e8 72 ff ff ff       	call   801031a0 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010322e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103235:	00 
80103236:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010323d:	e8 9d fd ff ff       	call   80102fdf <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103242:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103249:	e8 52 ff ff ff       	call   801031a0 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010324e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103255:	eb 3f                	jmp    80103296 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103257:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010325b:	c1 e0 18             	shl    $0x18,%eax
8010325e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103262:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103269:	e8 71 fd ff ff       	call   80102fdf <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010326e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103271:	c1 e8 0c             	shr    $0xc,%eax
80103274:	80 cc 06             	or     $0x6,%ah
80103277:	89 44 24 04          	mov    %eax,0x4(%esp)
8010327b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103282:	e8 58 fd ff ff       	call   80102fdf <lapicw>
    microdelay(200);
80103287:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010328e:	e8 0d ff ff ff       	call   801031a0 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103293:	ff 45 fc             	incl   -0x4(%ebp)
80103296:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010329a:	7e bb                	jle    80103257 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010329c:	c9                   	leave  
8010329d:	c3                   	ret    

8010329e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010329e:	55                   	push   %ebp
8010329f:	89 e5                	mov    %esp,%ebp
801032a1:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801032a4:	8b 45 08             	mov    0x8(%ebp),%eax
801032a7:	0f b6 c0             	movzbl %al,%eax
801032aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801032ae:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801032b5:	e8 09 fd ff ff       	call   80102fc3 <outb>
  microdelay(200);
801032ba:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032c1:	e8 da fe ff ff       	call   801031a0 <microdelay>

  return inb(CMOS_RETURN);
801032c6:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032cd:	e8 d6 fc ff ff       	call   80102fa8 <inb>
801032d2:	0f b6 c0             	movzbl %al,%eax
}
801032d5:	c9                   	leave  
801032d6:	c3                   	ret    

801032d7 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801032d7:	55                   	push   %ebp
801032d8:	89 e5                	mov    %esp,%ebp
801032da:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801032dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801032e4:	e8 b5 ff ff ff       	call   8010329e <cmos_read>
801032e9:	8b 55 08             	mov    0x8(%ebp),%edx
801032ec:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032ee:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801032f5:	e8 a4 ff ff ff       	call   8010329e <cmos_read>
801032fa:	8b 55 08             	mov    0x8(%ebp),%edx
801032fd:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103300:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103307:	e8 92 ff ff ff       	call   8010329e <cmos_read>
8010330c:	8b 55 08             	mov    0x8(%ebp),%edx
8010330f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103312:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103319:	e8 80 ff ff ff       	call   8010329e <cmos_read>
8010331e:	8b 55 08             	mov    0x8(%ebp),%edx
80103321:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103324:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010332b:	e8 6e ff ff ff       	call   8010329e <cmos_read>
80103330:	8b 55 08             	mov    0x8(%ebp),%edx
80103333:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103336:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010333d:	e8 5c ff ff ff       	call   8010329e <cmos_read>
80103342:	8b 55 08             	mov    0x8(%ebp),%edx
80103345:	89 42 14             	mov    %eax,0x14(%edx)
}
80103348:	c9                   	leave  
80103349:	c3                   	ret    

8010334a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010334a:	55                   	push   %ebp
8010334b:	89 e5                	mov    %esp,%ebp
8010334d:	57                   	push   %edi
8010334e:	56                   	push   %esi
8010334f:	53                   	push   %ebx
80103350:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103353:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010335a:	e8 3f ff ff ff       	call   8010329e <cmos_read>
8010335f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103365:	83 e0 04             	and    $0x4,%eax
80103368:	85 c0                	test   %eax,%eax
8010336a:	0f 94 c0             	sete   %al
8010336d:	0f b6 c0             	movzbl %al,%eax
80103370:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103373:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103376:	89 04 24             	mov    %eax,(%esp)
80103379:	e8 59 ff ff ff       	call   801032d7 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010337e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103385:	e8 14 ff ff ff       	call   8010329e <cmos_read>
8010338a:	25 80 00 00 00       	and    $0x80,%eax
8010338f:	85 c0                	test   %eax,%eax
80103391:	74 02                	je     80103395 <cmostime+0x4b>
        continue;
80103393:	eb 36                	jmp    801033cb <cmostime+0x81>
    fill_rtcdate(&t2);
80103395:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103398:	89 04 24             	mov    %eax,(%esp)
8010339b:	e8 37 ff ff ff       	call   801032d7 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033a0:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801033a7:	00 
801033a8:	8d 45 b0             	lea    -0x50(%ebp),%eax
801033ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801033af:	8d 45 c8             	lea    -0x38(%ebp),%eax
801033b2:	89 04 24             	mov    %eax,(%esp)
801033b5:	e8 c3 21 00 00       	call   8010557d <memcmp>
801033ba:	85 c0                	test   %eax,%eax
801033bc:	75 0d                	jne    801033cb <cmostime+0x81>
      break;
801033be:	90                   	nop
  }

  // convert
  if(bcd) {
801033bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801033c3:	0f 84 ac 00 00 00    	je     80103475 <cmostime+0x12b>
801033c9:	eb 02                	jmp    801033cd <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801033cb:	eb a6                	jmp    80103373 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033cd:	8b 45 c8             	mov    -0x38(%ebp),%eax
801033d0:	c1 e8 04             	shr    $0x4,%eax
801033d3:	89 c2                	mov    %eax,%edx
801033d5:	89 d0                	mov    %edx,%eax
801033d7:	c1 e0 02             	shl    $0x2,%eax
801033da:	01 d0                	add    %edx,%eax
801033dc:	01 c0                	add    %eax,%eax
801033de:	8b 55 c8             	mov    -0x38(%ebp),%edx
801033e1:	83 e2 0f             	and    $0xf,%edx
801033e4:	01 d0                	add    %edx,%eax
801033e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801033e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801033ec:	c1 e8 04             	shr    $0x4,%eax
801033ef:	89 c2                	mov    %eax,%edx
801033f1:	89 d0                	mov    %edx,%eax
801033f3:	c1 e0 02             	shl    $0x2,%eax
801033f6:	01 d0                	add    %edx,%eax
801033f8:	01 c0                	add    %eax,%eax
801033fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
801033fd:	83 e2 0f             	and    $0xf,%edx
80103400:	01 d0                	add    %edx,%eax
80103402:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103405:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103408:	c1 e8 04             	shr    $0x4,%eax
8010340b:	89 c2                	mov    %eax,%edx
8010340d:	89 d0                	mov    %edx,%eax
8010340f:	c1 e0 02             	shl    $0x2,%eax
80103412:	01 d0                	add    %edx,%eax
80103414:	01 c0                	add    %eax,%eax
80103416:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103419:	83 e2 0f             	and    $0xf,%edx
8010341c:	01 d0                	add    %edx,%eax
8010341e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103424:	c1 e8 04             	shr    $0x4,%eax
80103427:	89 c2                	mov    %eax,%edx
80103429:	89 d0                	mov    %edx,%eax
8010342b:	c1 e0 02             	shl    $0x2,%eax
8010342e:	01 d0                	add    %edx,%eax
80103430:	01 c0                	add    %eax,%eax
80103432:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103435:	83 e2 0f             	and    $0xf,%edx
80103438:	01 d0                	add    %edx,%eax
8010343a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
8010343d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103440:	c1 e8 04             	shr    $0x4,%eax
80103443:	89 c2                	mov    %eax,%edx
80103445:	89 d0                	mov    %edx,%eax
80103447:	c1 e0 02             	shl    $0x2,%eax
8010344a:	01 d0                	add    %edx,%eax
8010344c:	01 c0                	add    %eax,%eax
8010344e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103451:	83 e2 0f             	and    $0xf,%edx
80103454:	01 d0                	add    %edx,%eax
80103456:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103459:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010345c:	c1 e8 04             	shr    $0x4,%eax
8010345f:	89 c2                	mov    %eax,%edx
80103461:	89 d0                	mov    %edx,%eax
80103463:	c1 e0 02             	shl    $0x2,%eax
80103466:	01 d0                	add    %edx,%eax
80103468:	01 c0                	add    %eax,%eax
8010346a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010346d:	83 e2 0f             	and    $0xf,%edx
80103470:	01 d0                	add    %edx,%eax
80103472:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103475:	8b 45 08             	mov    0x8(%ebp),%eax
80103478:	89 c2                	mov    %eax,%edx
8010347a:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010347d:	b8 06 00 00 00       	mov    $0x6,%eax
80103482:	89 d7                	mov    %edx,%edi
80103484:	89 de                	mov    %ebx,%esi
80103486:	89 c1                	mov    %eax,%ecx
80103488:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010348a:	8b 45 08             	mov    0x8(%ebp),%eax
8010348d:	8b 40 14             	mov    0x14(%eax),%eax
80103490:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103496:	8b 45 08             	mov    0x8(%ebp),%eax
80103499:	89 50 14             	mov    %edx,0x14(%eax)
}
8010349c:	83 c4 5c             	add    $0x5c,%esp
8010349f:	5b                   	pop    %ebx
801034a0:	5e                   	pop    %esi
801034a1:	5f                   	pop    %edi
801034a2:	5d                   	pop    %ebp
801034a3:	c3                   	ret    

801034a4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034a4:	55                   	push   %ebp
801034a5:	89 e5                	mov    %esp,%ebp
801034a7:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034aa:	c7 44 24 04 bd 96 10 	movl   $0x801096bd,0x4(%esp)
801034b1:	80 
801034b2:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801034b9:	e8 c4 1d 00 00       	call   80105282 <initlock>
  readsb(dev, &sb);
801034be:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801034c5:	8b 45 08             	mov    0x8(%ebp),%eax
801034c8:	89 04 24             	mov    %eax,(%esp)
801034cb:	e8 f0 df ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
801034d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d3:	a3 b4 4b 11 80       	mov    %eax,0x80114bb4
  log.size = sb.nlog;
801034d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034db:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
  log.dev = dev;
801034e0:	8b 45 08             	mov    0x8(%ebp),%eax
801034e3:	a3 c4 4b 11 80       	mov    %eax,0x80114bc4
  recover_from_log();
801034e8:	e8 95 01 00 00       	call   80103682 <recover_from_log>
}
801034ed:	c9                   	leave  
801034ee:	c3                   	ret    

801034ef <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801034ef:	55                   	push   %ebp
801034f0:	89 e5                	mov    %esp,%ebp
801034f2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034fc:	e9 89 00 00 00       	jmp    8010358a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103501:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
80103507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010350a:	01 d0                	add    %edx,%eax
8010350c:	40                   	inc    %eax
8010350d:	89 c2                	mov    %eax,%edx
8010350f:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103514:	89 54 24 04          	mov    %edx,0x4(%esp)
80103518:	89 04 24             	mov    %eax,(%esp)
8010351b:	e8 95 cc ff ff       	call   801001b5 <bread>
80103520:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103526:	83 c0 10             	add    $0x10,%eax
80103529:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
80103530:	89 c2                	mov    %eax,%edx
80103532:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103537:	89 54 24 04          	mov    %edx,0x4(%esp)
8010353b:	89 04 24             	mov    %eax,(%esp)
8010353e:	e8 72 cc ff ff       	call   801001b5 <bread>
80103543:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103549:	8d 50 5c             	lea    0x5c(%eax),%edx
8010354c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010354f:	83 c0 5c             	add    $0x5c,%eax
80103552:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103559:	00 
8010355a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010355e:	89 04 24             	mov    %eax,(%esp)
80103561:	e8 69 20 00 00       	call   801055cf <memmove>
    bwrite(dbuf);  // write dst to disk
80103566:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 7b cc ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103574:	89 04 24             	mov    %eax,(%esp)
80103577:	e8 b0 cc ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010357c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010357f:	89 04 24             	mov    %eax,(%esp)
80103582:	e8 a5 cc ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103587:	ff 45 f4             	incl   -0xc(%ebp)
8010358a:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010358f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103592:	0f 8f 69 ff ff ff    	jg     80103501 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103598:	c9                   	leave  
80103599:	c3                   	ret    

8010359a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010359a:	55                   	push   %ebp
8010359b:	89 e5                	mov    %esp,%ebp
8010359d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801035a0:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
801035a5:	89 c2                	mov    %eax,%edx
801035a7:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801035ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801035b0:	89 04 24             	mov    %eax,(%esp)
801035b3:	e8 fd cb ff ff       	call   801001b5 <bread>
801035b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035be:	83 c0 5c             	add    $0x5c,%eax
801035c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c7:	8b 00                	mov    (%eax),%eax
801035c9:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  for (i = 0; i < log.lh.n; i++) {
801035ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035d5:	eb 1a                	jmp    801035f1 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801035d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035dd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801035e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035e4:	83 c2 10             	add    $0x10,%edx
801035e7:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801035ee:	ff 45 f4             	incl   -0xc(%ebp)
801035f1:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801035f6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035f9:	7f dc                	jg     801035d7 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801035fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fe:	89 04 24             	mov    %eax,(%esp)
80103601:	e8 26 cc ff ff       	call   8010022c <brelse>
}
80103606:	c9                   	leave  
80103607:	c3                   	ret    

80103608 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103608:	55                   	push   %ebp
80103609:	89 e5                	mov    %esp,%ebp
8010360b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010360e:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
80103613:	89 c2                	mov    %eax,%edx
80103615:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
8010361a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010361e:	89 04 24             	mov    %eax,(%esp)
80103621:	e8 8f cb ff ff       	call   801001b5 <bread>
80103626:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362c:	83 c0 5c             	add    $0x5c,%eax
8010362f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103632:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
80103638:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010363b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010363d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103644:	eb 1a                	jmp    80103660 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103649:	83 c0 10             	add    $0x10,%eax
8010364c:	8b 0c 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%ecx
80103653:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103656:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103659:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010365d:	ff 45 f4             	incl   -0xc(%ebp)
80103660:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103665:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103668:	7f dc                	jg     80103646 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010366a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010366d:	89 04 24             	mov    %eax,(%esp)
80103670:	e8 77 cb ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103675:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103678:	89 04 24             	mov    %eax,(%esp)
8010367b:	e8 ac cb ff ff       	call   8010022c <brelse>
}
80103680:	c9                   	leave  
80103681:	c3                   	ret    

80103682 <recover_from_log>:

static void
recover_from_log(void)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
80103685:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103688:	e8 0d ff ff ff       	call   8010359a <read_head>
  install_trans(); // if committed, copy from log to disk
8010368d:	e8 5d fe ff ff       	call   801034ef <install_trans>
  log.lh.n = 0;
80103692:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103699:	00 00 00 
  write_head(); // clear the log
8010369c:	e8 67 ff ff ff       	call   80103608 <write_head>
}
801036a1:	c9                   	leave  
801036a2:	c3                   	ret    

801036a3 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801036a3:	55                   	push   %ebp
801036a4:	89 e5                	mov    %esp,%ebp
801036a6:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801036a9:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036b0:	e8 ee 1b 00 00       	call   801052a3 <acquire>
  while(1){
    if(log.committing){
801036b5:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
801036ba:	85 c0                	test   %eax,%eax
801036bc:	74 16                	je     801036d4 <begin_op+0x31>
      sleep(&log, &log.lock);
801036be:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
801036c5:	80 
801036c6:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036cd:	e8 82 15 00 00       	call   80104c54 <sleep>
801036d2:	eb 4d                	jmp    80103721 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801036d4:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
801036da:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036df:	8d 48 01             	lea    0x1(%eax),%ecx
801036e2:	89 c8                	mov    %ecx,%eax
801036e4:	c1 e0 02             	shl    $0x2,%eax
801036e7:	01 c8                	add    %ecx,%eax
801036e9:	01 c0                	add    %eax,%eax
801036eb:	01 d0                	add    %edx,%eax
801036ed:	83 f8 1e             	cmp    $0x1e,%eax
801036f0:	7e 16                	jle    80103708 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036f2:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
801036f9:	80 
801036fa:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103701:	e8 4e 15 00 00       	call   80104c54 <sleep>
80103706:	eb 19                	jmp    80103721 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103708:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
8010370d:	40                   	inc    %eax
8010370e:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
      release(&log.lock);
80103713:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010371a:	e8 ee 1b 00 00       	call   8010530d <release>
      break;
8010371f:	eb 02                	jmp    80103723 <begin_op+0x80>
    }
  }
80103721:	eb 92                	jmp    801036b5 <begin_op+0x12>
}
80103723:	c9                   	leave  
80103724:	c3                   	ret    

80103725 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103725:	55                   	push   %ebp
80103726:	89 e5                	mov    %esp,%ebp
80103728:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010372b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103732:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103739:	e8 65 1b 00 00       	call   801052a3 <acquire>
  log.outstanding -= 1;
8010373e:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103743:	48                   	dec    %eax
80103744:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
  if(log.committing)
80103749:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
8010374e:	85 c0                	test   %eax,%eax
80103750:	74 0c                	je     8010375e <end_op+0x39>
    panic("log.committing");
80103752:	c7 04 24 c1 96 10 80 	movl   $0x801096c1,(%esp)
80103759:	e8 f6 cd ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010375e:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103763:	85 c0                	test   %eax,%eax
80103765:	75 13                	jne    8010377a <end_op+0x55>
    do_commit = 1;
80103767:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010376e:	c7 05 c0 4b 11 80 01 	movl   $0x1,0x80114bc0
80103775:	00 00 00 
80103778:	eb 0c                	jmp    80103786 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010377a:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103781:	e8 a5 15 00 00       	call   80104d2b <wakeup>
  }
  release(&log.lock);
80103786:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010378d:	e8 7b 1b 00 00       	call   8010530d <release>

  if(do_commit){
80103792:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103796:	74 33                	je     801037cb <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103798:	e8 db 00 00 00       	call   80103878 <commit>
    acquire(&log.lock);
8010379d:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037a4:	e8 fa 1a 00 00       	call   801052a3 <acquire>
    log.committing = 0;
801037a9:	c7 05 c0 4b 11 80 00 	movl   $0x0,0x80114bc0
801037b0:	00 00 00 
    wakeup(&log);
801037b3:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037ba:	e8 6c 15 00 00       	call   80104d2b <wakeup>
    release(&log.lock);
801037bf:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037c6:	e8 42 1b 00 00       	call   8010530d <release>
  }
}
801037cb:	c9                   	leave  
801037cc:	c3                   	ret    

801037cd <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037cd:	55                   	push   %ebp
801037ce:	89 e5                	mov    %esp,%ebp
801037d0:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037da:	e9 89 00 00 00       	jmp    80103868 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037df:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
801037e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e8:	01 d0                	add    %edx,%eax
801037ea:	40                   	inc    %eax
801037eb:	89 c2                	mov    %eax,%edx
801037ed:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801037f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801037f6:	89 04 24             	mov    %eax,(%esp)
801037f9:	e8 b7 c9 ff ff       	call   801001b5 <bread>
801037fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103804:	83 c0 10             	add    $0x10,%eax
80103807:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010380e:	89 c2                	mov    %eax,%edx
80103810:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103815:	89 54 24 04          	mov    %edx,0x4(%esp)
80103819:	89 04 24             	mov    %eax,(%esp)
8010381c:	e8 94 c9 ff ff       	call   801001b5 <bread>
80103821:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103824:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103827:	8d 50 5c             	lea    0x5c(%eax),%edx
8010382a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010382d:	83 c0 5c             	add    $0x5c,%eax
80103830:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103837:	00 
80103838:	89 54 24 04          	mov    %edx,0x4(%esp)
8010383c:	89 04 24             	mov    %eax,(%esp)
8010383f:	e8 8b 1d 00 00       	call   801055cf <memmove>
    bwrite(to);  // write the log
80103844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103847:	89 04 24             	mov    %eax,(%esp)
8010384a:	e8 9d c9 ff ff       	call   801001ec <bwrite>
    brelse(from);
8010384f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103852:	89 04 24             	mov    %eax,(%esp)
80103855:	e8 d2 c9 ff ff       	call   8010022c <brelse>
    brelse(to);
8010385a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385d:	89 04 24             	mov    %eax,(%esp)
80103860:	e8 c7 c9 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103865:	ff 45 f4             	incl   -0xc(%ebp)
80103868:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010386d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103870:	0f 8f 69 ff ff ff    	jg     801037df <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103876:	c9                   	leave  
80103877:	c3                   	ret    

80103878 <commit>:

static void
commit()
{
80103878:	55                   	push   %ebp
80103879:	89 e5                	mov    %esp,%ebp
8010387b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010387e:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103883:	85 c0                	test   %eax,%eax
80103885:	7e 1e                	jle    801038a5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103887:	e8 41 ff ff ff       	call   801037cd <write_log>
    write_head();    // Write header to disk -- the real commit
8010388c:	e8 77 fd ff ff       	call   80103608 <write_head>
    install_trans(); // Now install writes to home locations
80103891:	e8 59 fc ff ff       	call   801034ef <install_trans>
    log.lh.n = 0;
80103896:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
8010389d:	00 00 00 
    write_head();    // Erase the transaction from the log
801038a0:	e8 63 fd ff ff       	call   80103608 <write_head>
  }
}
801038a5:	c9                   	leave  
801038a6:	c3                   	ret    

801038a7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801038a7:	55                   	push   %ebp
801038a8:	89 e5                	mov    %esp,%ebp
801038aa:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038ad:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038b2:	83 f8 1d             	cmp    $0x1d,%eax
801038b5:	7f 10                	jg     801038c7 <log_write+0x20>
801038b7:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038bc:	8b 15 b8 4b 11 80    	mov    0x80114bb8,%edx
801038c2:	4a                   	dec    %edx
801038c3:	39 d0                	cmp    %edx,%eax
801038c5:	7c 0c                	jl     801038d3 <log_write+0x2c>
    panic("too big a transaction");
801038c7:	c7 04 24 d0 96 10 80 	movl   $0x801096d0,(%esp)
801038ce:	e8 81 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801038d3:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801038d8:	85 c0                	test   %eax,%eax
801038da:	7f 0c                	jg     801038e8 <log_write+0x41>
    panic("log_write outside of trans");
801038dc:	c7 04 24 e6 96 10 80 	movl   $0x801096e6,(%esp)
801038e3:	e8 6c cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801038e8:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801038ef:	e8 af 19 00 00       	call   801052a3 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801038f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038fb:	eb 1e                	jmp    8010391b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801038fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103900:	83 c0 10             	add    $0x10,%eax
80103903:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010390a:	89 c2                	mov    %eax,%edx
8010390c:	8b 45 08             	mov    0x8(%ebp),%eax
8010390f:	8b 40 08             	mov    0x8(%eax),%eax
80103912:	39 c2                	cmp    %eax,%edx
80103914:	75 02                	jne    80103918 <log_write+0x71>
      break;
80103916:	eb 0d                	jmp    80103925 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103918:	ff 45 f4             	incl   -0xc(%ebp)
8010391b:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103920:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103923:	7f d8                	jg     801038fd <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103925:	8b 45 08             	mov    0x8(%ebp),%eax
80103928:	8b 40 08             	mov    0x8(%eax),%eax
8010392b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010392e:	83 c2 10             	add    $0x10,%edx
80103931:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
  if (i == log.lh.n)
80103938:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010393d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103940:	75 0b                	jne    8010394d <log_write+0xa6>
    log.lh.n++;
80103942:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103947:	40                   	inc    %eax
80103948:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  b->flags |= B_DIRTY; // prevent eviction
8010394d:	8b 45 08             	mov    0x8(%ebp),%eax
80103950:	8b 00                	mov    (%eax),%eax
80103952:	83 c8 04             	or     $0x4,%eax
80103955:	89 c2                	mov    %eax,%edx
80103957:	8b 45 08             	mov    0x8(%ebp),%eax
8010395a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010395c:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103963:	e8 a5 19 00 00       	call   8010530d <release>
}
80103968:	c9                   	leave  
80103969:	c3                   	ret    
	...

8010396c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010396c:	55                   	push   %ebp
8010396d:	89 e5                	mov    %esp,%ebp
8010396f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103972:	8b 55 08             	mov    0x8(%ebp),%edx
80103975:	8b 45 0c             	mov    0xc(%ebp),%eax
80103978:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010397b:	f0 87 02             	lock xchg %eax,(%edx)
8010397e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103981:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103984:	c9                   	leave  
80103985:	c3                   	ret    

80103986 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103986:	55                   	push   %ebp
80103987:	89 e5                	mov    %esp,%ebp
80103989:	83 e4 f0             	and    $0xfffffff0,%esp
8010398c:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010398f:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103996:	80 
80103997:	c7 04 24 b0 7c 11 80 	movl   $0x80117cb0,(%esp)
8010399e:	e8 8d f2 ff ff       	call   80102c30 <kinit1>
  kvmalloc();      // kernel page table
801039a3:	e8 d3 4a 00 00       	call   8010847b <kvmalloc>
  mpinit();        // detect other processors
801039a8:	e8 cc 03 00 00       	call   80103d79 <mpinit>
  lapicinit();     // interrupt controller
801039ad:	e8 4e f6 ff ff       	call   80103000 <lapicinit>
  seginit();       // segment descriptors
801039b2:	e8 ac 45 00 00       	call   80107f63 <seginit>
  picinit();       // disable pic
801039b7:	e8 0c 05 00 00       	call   80103ec8 <picinit>
  ioapicinit();    // another interrupt controller
801039bc:	e8 8c f1 ff ff       	call   80102b4d <ioapicinit>
  consoleinit();   // console hardware
801039c1:	e8 29 d2 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
801039c6:	e8 24 39 00 00       	call   801072ef <uartinit>
  pinit();         // process table
801039cb:	e8 ee 08 00 00       	call   801042be <pinit>
  tvinit();        // trap vectors
801039d0:	e8 e7 34 00 00       	call   80106ebc <tvinit>
  binit();         // buffer cache
801039d5:	e8 5a c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039da:	e8 07 d7 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
801039df:	e8 75 ed ff ff       	call   80102759 <ideinit>
  startothers();   // start other processors
801039e4:	e8 88 00 00 00       	call   80103a71 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039e9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801039f0:	8e 
801039f1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801039f8:	e8 6b f2 ff ff       	call   80102c68 <kinit2>
  userinit();      // first user process
801039fd:	e8 e6 0a 00 00       	call   801044e8 <userinit>
  container_init();
80103a02:	e8 cf 57 00 00       	call   801091d6 <container_init>
  mpmain();        // finish this processor's setup
80103a07:	e8 1a 00 00 00       	call   80103a26 <mpmain>

80103a0c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a0c:	55                   	push   %ebp
80103a0d:	89 e5                	mov    %esp,%ebp
80103a0f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a12:	e8 7b 4a 00 00       	call   80108492 <switchkvm>
  seginit();
80103a17:	e8 47 45 00 00       	call   80107f63 <seginit>
  lapicinit();
80103a1c:	e8 df f5 ff ff       	call   80103000 <lapicinit>
  mpmain();
80103a21:	e8 00 00 00 00       	call   80103a26 <mpmain>

80103a26 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a26:	55                   	push   %ebp
80103a27:	89 e5                	mov    %esp,%ebp
80103a29:	53                   	push   %ebx
80103a2a:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a2d:	e8 a8 08 00 00       	call   801042da <cpuid>
80103a32:	89 c3                	mov    %eax,%ebx
80103a34:	e8 a1 08 00 00       	call   801042da <cpuid>
80103a39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a41:	c7 04 24 01 97 10 80 	movl   $0x80109701,(%esp)
80103a48:	e8 74 c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103a4d:	e8 c7 35 00 00       	call   80107019 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a52:	e8 c8 08 00 00       	call   8010431f <mycpu>
80103a57:	05 a0 00 00 00       	add    $0xa0,%eax
80103a5c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103a63:	00 
80103a64:	89 04 24             	mov    %eax,(%esp)
80103a67:	e8 00 ff ff ff       	call   8010396c <xchg>
  scheduler();     // start running processes
80103a6c:	e8 16 10 00 00       	call   80104a87 <scheduler>

80103a71 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a71:	55                   	push   %ebp
80103a72:	89 e5                	mov    %esp,%ebp
80103a74:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103a77:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a7e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a83:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a87:	c7 44 24 04 6c c5 10 	movl   $0x8010c56c,0x4(%esp)
80103a8e:	80 
80103a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a92:	89 04 24             	mov    %eax,(%esp)
80103a95:	e8 35 1b 00 00       	call   801055cf <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a9a:	c7 45 f4 80 4c 11 80 	movl   $0x80114c80,-0xc(%ebp)
80103aa1:	eb 75                	jmp    80103b18 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103aa3:	e8 77 08 00 00       	call   8010431f <mycpu>
80103aa8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aab:	75 02                	jne    80103aaf <startothers+0x3e>
      continue;
80103aad:	eb 62                	jmp    80103b11 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103aaf:	e8 e3 f2 ff ff       	call   80102d97 <kalloc>
80103ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aba:	83 e8 04             	sub    $0x4,%eax
80103abd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ac0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103ac6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103acb:	83 e8 08             	sub    $0x8,%eax
80103ace:	c7 00 0c 3a 10 80    	movl   $0x80103a0c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad7:	8d 50 f4             	lea    -0xc(%eax),%edx
80103ada:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103adf:	05 00 00 00 80       	add    $0x80000000,%eax
80103ae4:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af2:	8a 00                	mov    (%eax),%al
80103af4:	0f b6 c0             	movzbl %al,%eax
80103af7:	89 54 24 04          	mov    %edx,0x4(%esp)
80103afb:	89 04 24             	mov    %eax,(%esp)
80103afe:	e8 a2 f6 ff ff       	call   801031a5 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b03:	90                   	nop
80103b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b07:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b0d:	85 c0                	test   %eax,%eax
80103b0f:	74 f3                	je     80103b04 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b11:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b18:	a1 00 52 11 80       	mov    0x80115200,%eax
80103b1d:	89 c2                	mov    %eax,%edx
80103b1f:	89 d0                	mov    %edx,%eax
80103b21:	c1 e0 02             	shl    $0x2,%eax
80103b24:	01 d0                	add    %edx,%eax
80103b26:	01 c0                	add    %eax,%eax
80103b28:	01 d0                	add    %edx,%eax
80103b2a:	c1 e0 04             	shl    $0x4,%eax
80103b2d:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103b32:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b35:	0f 87 68 ff ff ff    	ja     80103aa3 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b3b:	c9                   	leave  
80103b3c:	c3                   	ret    
80103b3d:	00 00                	add    %al,(%eax)
	...

80103b40 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	83 ec 14             	sub    $0x14,%esp
80103b46:	8b 45 08             	mov    0x8(%ebp),%eax
80103b49:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b50:	89 c2                	mov    %eax,%edx
80103b52:	ec                   	in     (%dx),%al
80103b53:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b56:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103b59:	c9                   	leave  
80103b5a:	c3                   	ret    

80103b5b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b5b:	55                   	push   %ebp
80103b5c:	89 e5                	mov    %esp,%ebp
80103b5e:	83 ec 08             	sub    $0x8,%esp
80103b61:	8b 45 08             	mov    0x8(%ebp),%eax
80103b64:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b67:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b6b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b6e:	8a 45 f8             	mov    -0x8(%ebp),%al
80103b71:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b74:	ee                   	out    %al,(%dx)
}
80103b75:	c9                   	leave  
80103b76:	c3                   	ret    

80103b77 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103b77:	55                   	push   %ebp
80103b78:	89 e5                	mov    %esp,%ebp
80103b7a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103b7d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b84:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b8b:	eb 13                	jmp    80103ba0 <sum+0x29>
    sum += addr[i];
80103b8d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b90:	8b 45 08             	mov    0x8(%ebp),%eax
80103b93:	01 d0                	add    %edx,%eax
80103b95:	8a 00                	mov    (%eax),%al
80103b97:	0f b6 c0             	movzbl %al,%eax
80103b9a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b9d:	ff 45 fc             	incl   -0x4(%ebp)
80103ba0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103ba3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ba6:	7c e5                	jl     80103b8d <sum+0x16>
    sum += addr[i];
  return sum;
80103ba8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103bab:	c9                   	leave  
80103bac:	c3                   	ret    

80103bad <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb6:	05 00 00 00 80       	add    $0x80000000,%eax
80103bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc4:	01 d0                	add    %edx,%eax
80103bc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bcf:	eb 3f                	jmp    80103c10 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bd1:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bd8:	00 
80103bd9:	c7 44 24 04 18 97 10 	movl   $0x80109718,0x4(%esp)
80103be0:	80 
80103be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be4:	89 04 24             	mov    %eax,(%esp)
80103be7:	e8 91 19 00 00       	call   8010557d <memcmp>
80103bec:	85 c0                	test   %eax,%eax
80103bee:	75 1c                	jne    80103c0c <mpsearch1+0x5f>
80103bf0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103bf7:	00 
80103bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfb:	89 04 24             	mov    %eax,(%esp)
80103bfe:	e8 74 ff ff ff       	call   80103b77 <sum>
80103c03:	84 c0                	test   %al,%al
80103c05:	75 05                	jne    80103c0c <mpsearch1+0x5f>
      return (struct mp*)p;
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	eb 11                	jmp    80103c1d <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c0c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c16:	72 b9                	jb     80103bd1 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c18:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c1d:	c9                   	leave  
80103c1e:	c3                   	ret    

80103c1f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c1f:	55                   	push   %ebp
80103c20:	89 e5                	mov    %esp,%ebp
80103c22:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c25:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	83 c0 0f             	add    $0xf,%eax
80103c32:	8a 00                	mov    (%eax),%al
80103c34:	0f b6 c0             	movzbl %al,%eax
80103c37:	c1 e0 08             	shl    $0x8,%eax
80103c3a:	89 c2                	mov    %eax,%edx
80103c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3f:	83 c0 0e             	add    $0xe,%eax
80103c42:	8a 00                	mov    (%eax),%al
80103c44:	0f b6 c0             	movzbl %al,%eax
80103c47:	09 d0                	or     %edx,%eax
80103c49:	c1 e0 04             	shl    $0x4,%eax
80103c4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c53:	74 21                	je     80103c76 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103c55:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c5c:	00 
80103c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c60:	89 04 24             	mov    %eax,(%esp)
80103c63:	e8 45 ff ff ff       	call   80103bad <mpsearch1>
80103c68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c6f:	74 4e                	je     80103cbf <mpsearch+0xa0>
      return mp;
80103c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c74:	eb 5d                	jmp    80103cd3 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c79:	83 c0 14             	add    $0x14,%eax
80103c7c:	8a 00                	mov    (%eax),%al
80103c7e:	0f b6 c0             	movzbl %al,%eax
80103c81:	c1 e0 08             	shl    $0x8,%eax
80103c84:	89 c2                	mov    %eax,%edx
80103c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c89:	83 c0 13             	add    $0x13,%eax
80103c8c:	8a 00                	mov    (%eax),%al
80103c8e:	0f b6 c0             	movzbl %al,%eax
80103c91:	09 d0                	or     %edx,%eax
80103c93:	c1 e0 0a             	shl    $0xa,%eax
80103c96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9c:	2d 00 04 00 00       	sub    $0x400,%eax
80103ca1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ca8:	00 
80103ca9:	89 04 24             	mov    %eax,(%esp)
80103cac:	e8 fc fe ff ff       	call   80103bad <mpsearch1>
80103cb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cb4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cb8:	74 05                	je     80103cbf <mpsearch+0xa0>
      return mp;
80103cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cbd:	eb 14                	jmp    80103cd3 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103cbf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103cc6:	00 
80103cc7:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103cce:	e8 da fe ff ff       	call   80103bad <mpsearch1>
}
80103cd3:	c9                   	leave  
80103cd4:	c3                   	ret    

80103cd5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103cd5:	55                   	push   %ebp
80103cd6:	89 e5                	mov    %esp,%ebp
80103cd8:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103cdb:	e8 3f ff ff ff       	call   80103c1f <mpsearch>
80103ce0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ce3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ce7:	74 0a                	je     80103cf3 <mpconfig+0x1e>
80103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cec:	8b 40 04             	mov    0x4(%eax),%eax
80103cef:	85 c0                	test   %eax,%eax
80103cf1:	75 07                	jne    80103cfa <mpconfig+0x25>
    return 0;
80103cf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf8:	eb 7d                	jmp    80103d77 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfd:	8b 40 04             	mov    0x4(%eax),%eax
80103d00:	05 00 00 00 80       	add    $0x80000000,%eax
80103d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d08:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d0f:	00 
80103d10:	c7 44 24 04 1d 97 10 	movl   $0x8010971d,0x4(%esp)
80103d17:	80 
80103d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d1b:	89 04 24             	mov    %eax,(%esp)
80103d1e:	e8 5a 18 00 00       	call   8010557d <memcmp>
80103d23:	85 c0                	test   %eax,%eax
80103d25:	74 07                	je     80103d2e <mpconfig+0x59>
    return 0;
80103d27:	b8 00 00 00 00       	mov    $0x0,%eax
80103d2c:	eb 49                	jmp    80103d77 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d31:	8a 40 06             	mov    0x6(%eax),%al
80103d34:	3c 01                	cmp    $0x1,%al
80103d36:	74 11                	je     80103d49 <mpconfig+0x74>
80103d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3b:	8a 40 06             	mov    0x6(%eax),%al
80103d3e:	3c 04                	cmp    $0x4,%al
80103d40:	74 07                	je     80103d49 <mpconfig+0x74>
    return 0;
80103d42:	b8 00 00 00 00       	mov    $0x0,%eax
80103d47:	eb 2e                	jmp    80103d77 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4c:	8b 40 04             	mov    0x4(%eax),%eax
80103d4f:	0f b7 c0             	movzwl %ax,%eax
80103d52:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d59:	89 04 24             	mov    %eax,(%esp)
80103d5c:	e8 16 fe ff ff       	call   80103b77 <sum>
80103d61:	84 c0                	test   %al,%al
80103d63:	74 07                	je     80103d6c <mpconfig+0x97>
    return 0;
80103d65:	b8 00 00 00 00       	mov    $0x0,%eax
80103d6a:	eb 0b                	jmp    80103d77 <mpconfig+0xa2>
  *pmp = mp;
80103d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d72:	89 10                	mov    %edx,(%eax)
  return conf;
80103d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d77:	c9                   	leave  
80103d78:	c3                   	ret    

80103d79 <mpinit>:

void
mpinit(void)
{
80103d79:	55                   	push   %ebp
80103d7a:	89 e5                	mov    %esp,%ebp
80103d7c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103d7f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103d82:	89 04 24             	mov    %eax,(%esp)
80103d85:	e8 4b ff ff ff       	call   80103cd5 <mpconfig>
80103d8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d8d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d91:	75 0c                	jne    80103d9f <mpinit+0x26>
    panic("Expect to run on an SMP");
80103d93:	c7 04 24 22 97 10 80 	movl   $0x80109722,(%esp)
80103d9a:	e8 b5 c7 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d9f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103da6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103da9:	8b 40 24             	mov    0x24(%eax),%eax
80103dac:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103db1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103db4:	83 c0 2c             	add    $0x2c,%eax
80103db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dbd:	8b 40 04             	mov    0x4(%eax),%eax
80103dc0:	0f b7 d0             	movzwl %ax,%edx
80103dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dc6:	01 d0                	add    %edx,%eax
80103dc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103dcb:	eb 7d                	jmp    80103e4a <mpinit+0xd1>
    switch(*p){
80103dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd0:	8a 00                	mov    (%eax),%al
80103dd2:	0f b6 c0             	movzbl %al,%eax
80103dd5:	83 f8 04             	cmp    $0x4,%eax
80103dd8:	77 68                	ja     80103e42 <mpinit+0xc9>
80103dda:	8b 04 85 5c 97 10 80 	mov    -0x7fef68a4(,%eax,4),%eax
80103de1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103de9:	a1 00 52 11 80       	mov    0x80115200,%eax
80103dee:	83 f8 07             	cmp    $0x7,%eax
80103df1:	7f 2c                	jg     80103e1f <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103df3:	8b 15 00 52 11 80    	mov    0x80115200,%edx
80103df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dfc:	8a 48 01             	mov    0x1(%eax),%cl
80103dff:	89 d0                	mov    %edx,%eax
80103e01:	c1 e0 02             	shl    $0x2,%eax
80103e04:	01 d0                	add    %edx,%eax
80103e06:	01 c0                	add    %eax,%eax
80103e08:	01 d0                	add    %edx,%eax
80103e0a:	c1 e0 04             	shl    $0x4,%eax
80103e0d:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103e12:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103e14:	a1 00 52 11 80       	mov    0x80115200,%eax
80103e19:	40                   	inc    %eax
80103e1a:	a3 00 52 11 80       	mov    %eax,0x80115200
      }
      p += sizeof(struct mpproc);
80103e1f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e23:	eb 25                	jmp    80103e4a <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e2e:	8a 40 01             	mov    0x1(%eax),%al
80103e31:	a2 60 4c 11 80       	mov    %al,0x80114c60
      p += sizeof(struct mpioapic);
80103e36:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e3a:	eb 0e                	jmp    80103e4a <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e3c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e40:	eb 08                	jmp    80103e4a <mpinit+0xd1>
    default:
      ismp = 0;
80103e42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103e49:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e4d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103e50:	0f 82 77 ff ff ff    	jb     80103dcd <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103e56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e5a:	75 0c                	jne    80103e68 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103e5c:	c7 04 24 3c 97 10 80 	movl   $0x8010973c,(%esp)
80103e63:	e8 ec c6 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103e68:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6b:	8a 40 0c             	mov    0xc(%eax),%al
80103e6e:	84 c0                	test   %al,%al
80103e70:	74 36                	je     80103ea8 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e72:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103e79:	00 
80103e7a:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103e81:	e8 d5 fc ff ff       	call   80103b5b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e86:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e8d:	e8 ae fc ff ff       	call   80103b40 <inb>
80103e92:	83 c8 01             	or     $0x1,%eax
80103e95:	0f b6 c0             	movzbl %al,%eax
80103e98:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e9c:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103ea3:	e8 b3 fc ff ff       	call   80103b5b <outb>
  }
}
80103ea8:	c9                   	leave  
80103ea9:	c3                   	ret    
	...

80103eac <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103eac:	55                   	push   %ebp
80103ead:	89 e5                	mov    %esp,%ebp
80103eaf:	83 ec 08             	sub    $0x8,%esp
80103eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
80103eb8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ebc:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ebf:	8a 45 f8             	mov    -0x8(%ebp),%al
80103ec2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ec5:	ee                   	out    %al,(%dx)
}
80103ec6:	c9                   	leave  
80103ec7:	c3                   	ret    

80103ec8 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103ec8:	55                   	push   %ebp
80103ec9:	89 e5                	mov    %esp,%ebp
80103ecb:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ece:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ed5:	00 
80103ed6:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103edd:	e8 ca ff ff ff       	call   80103eac <outb>
  outb(IO_PIC2+1, 0xFF);
80103ee2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ee9:	00 
80103eea:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ef1:	e8 b6 ff ff ff       	call   80103eac <outb>
}
80103ef6:	c9                   	leave  
80103ef7:	c3                   	ret    

80103ef8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ef8:	55                   	push   %ebp
80103ef9:	89 e5                	mov    %esp,%ebp
80103efb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103efe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f05:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f11:	8b 10                	mov    (%eax),%edx
80103f13:	8b 45 08             	mov    0x8(%ebp),%eax
80103f16:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f18:	e8 e5 d1 ff ff       	call   80101102 <filealloc>
80103f1d:	8b 55 08             	mov    0x8(%ebp),%edx
80103f20:	89 02                	mov    %eax,(%edx)
80103f22:	8b 45 08             	mov    0x8(%ebp),%eax
80103f25:	8b 00                	mov    (%eax),%eax
80103f27:	85 c0                	test   %eax,%eax
80103f29:	0f 84 c8 00 00 00    	je     80103ff7 <pipealloc+0xff>
80103f2f:	e8 ce d1 ff ff       	call   80101102 <filealloc>
80103f34:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f37:	89 02                	mov    %eax,(%edx)
80103f39:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3c:	8b 00                	mov    (%eax),%eax
80103f3e:	85 c0                	test   %eax,%eax
80103f40:	0f 84 b1 00 00 00    	je     80103ff7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f46:	e8 4c ee ff ff       	call   80102d97 <kalloc>
80103f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f52:	75 05                	jne    80103f59 <pipealloc+0x61>
    goto bad;
80103f54:	e9 9e 00 00 00       	jmp    80103ff7 <pipealloc+0xff>
  p->readopen = 1;
80103f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f63:	00 00 00 
  p->writeopen = 1;
80103f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f69:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f70:	00 00 00 
  p->nwrite = 0;
80103f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f76:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f7d:	00 00 00 
  p->nread = 0;
80103f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f83:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f8a:	00 00 00 
  initlock(&p->lock, "pipe");
80103f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f90:	c7 44 24 04 70 97 10 	movl   $0x80109770,0x4(%esp)
80103f97:	80 
80103f98:	89 04 24             	mov    %eax,(%esp)
80103f9b:	e8 e2 12 00 00       	call   80105282 <initlock>
  (*f0)->type = FD_PIPE;
80103fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa3:	8b 00                	mov    (%eax),%eax
80103fa5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fab:	8b 45 08             	mov    0x8(%ebp),%eax
80103fae:	8b 00                	mov    (%eax),%eax
80103fb0:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb7:	8b 00                	mov    (%eax),%eax
80103fb9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	8b 00                	mov    (%eax),%eax
80103fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc5:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fcb:	8b 00                	mov    (%eax),%eax
80103fcd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd6:	8b 00                	mov    (%eax),%eax
80103fd8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fdf:	8b 00                	mov    (%eax),%eax
80103fe1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe8:	8b 00                	mov    (%eax),%eax
80103fea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fed:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ff0:	b8 00 00 00 00       	mov    $0x0,%eax
80103ff5:	eb 42                	jmp    80104039 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103ff7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ffb:	74 0b                	je     80104008 <pipealloc+0x110>
    kfree((char*)p);
80103ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104000:	89 04 24             	mov    %eax,(%esp)
80104003:	e8 bd ec ff ff       	call   80102cc5 <kfree>
  if(*f0)
80104008:	8b 45 08             	mov    0x8(%ebp),%eax
8010400b:	8b 00                	mov    (%eax),%eax
8010400d:	85 c0                	test   %eax,%eax
8010400f:	74 0d                	je     8010401e <pipealloc+0x126>
    fileclose(*f0);
80104011:	8b 45 08             	mov    0x8(%ebp),%eax
80104014:	8b 00                	mov    (%eax),%eax
80104016:	89 04 24             	mov    %eax,(%esp)
80104019:	e8 8c d1 ff ff       	call   801011aa <fileclose>
  if(*f1)
8010401e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104021:	8b 00                	mov    (%eax),%eax
80104023:	85 c0                	test   %eax,%eax
80104025:	74 0d                	je     80104034 <pipealloc+0x13c>
    fileclose(*f1);
80104027:	8b 45 0c             	mov    0xc(%ebp),%eax
8010402a:	8b 00                	mov    (%eax),%eax
8010402c:	89 04 24             	mov    %eax,(%esp)
8010402f:	e8 76 d1 ff ff       	call   801011aa <fileclose>
  return -1;
80104034:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104039:	c9                   	leave  
8010403a:	c3                   	ret    

8010403b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010403b:	55                   	push   %ebp
8010403c:	89 e5                	mov    %esp,%ebp
8010403e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104041:	8b 45 08             	mov    0x8(%ebp),%eax
80104044:	89 04 24             	mov    %eax,(%esp)
80104047:	e8 57 12 00 00       	call   801052a3 <acquire>
  if(writable){
8010404c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104050:	74 1f                	je     80104071 <pipeclose+0x36>
    p->writeopen = 0;
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010405c:	00 00 00 
    wakeup(&p->nread);
8010405f:	8b 45 08             	mov    0x8(%ebp),%eax
80104062:	05 34 02 00 00       	add    $0x234,%eax
80104067:	89 04 24             	mov    %eax,(%esp)
8010406a:	e8 bc 0c 00 00       	call   80104d2b <wakeup>
8010406f:	eb 1d                	jmp    8010408e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104071:	8b 45 08             	mov    0x8(%ebp),%eax
80104074:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010407b:	00 00 00 
    wakeup(&p->nwrite);
8010407e:	8b 45 08             	mov    0x8(%ebp),%eax
80104081:	05 38 02 00 00       	add    $0x238,%eax
80104086:	89 04 24             	mov    %eax,(%esp)
80104089:	e8 9d 0c 00 00       	call   80104d2b <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010408e:	8b 45 08             	mov    0x8(%ebp),%eax
80104091:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104097:	85 c0                	test   %eax,%eax
80104099:	75 25                	jne    801040c0 <pipeclose+0x85>
8010409b:	8b 45 08             	mov    0x8(%ebp),%eax
8010409e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040a4:	85 c0                	test   %eax,%eax
801040a6:	75 18                	jne    801040c0 <pipeclose+0x85>
    release(&p->lock);
801040a8:	8b 45 08             	mov    0x8(%ebp),%eax
801040ab:	89 04 24             	mov    %eax,(%esp)
801040ae:	e8 5a 12 00 00       	call   8010530d <release>
    kfree((char*)p);
801040b3:	8b 45 08             	mov    0x8(%ebp),%eax
801040b6:	89 04 24             	mov    %eax,(%esp)
801040b9:	e8 07 ec ff ff       	call   80102cc5 <kfree>
801040be:	eb 0b                	jmp    801040cb <pipeclose+0x90>
  } else
    release(&p->lock);
801040c0:	8b 45 08             	mov    0x8(%ebp),%eax
801040c3:	89 04 24             	mov    %eax,(%esp)
801040c6:	e8 42 12 00 00       	call   8010530d <release>
}
801040cb:	c9                   	leave  
801040cc:	c3                   	ret    

801040cd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040cd:	55                   	push   %ebp
801040ce:	89 e5                	mov    %esp,%ebp
801040d0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040d3:	8b 45 08             	mov    0x8(%ebp),%eax
801040d6:	89 04 24             	mov    %eax,(%esp)
801040d9:	e8 c5 11 00 00       	call   801052a3 <acquire>
  for(i = 0; i < n; i++){
801040de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040e5:	e9 a3 00 00 00       	jmp    8010418d <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040ea:	eb 56                	jmp    80104142 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
801040ec:	8b 45 08             	mov    0x8(%ebp),%eax
801040ef:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040f5:	85 c0                	test   %eax,%eax
801040f7:	74 0c                	je     80104105 <pipewrite+0x38>
801040f9:	e8 a5 02 00 00       	call   801043a3 <myproc>
801040fe:	8b 40 24             	mov    0x24(%eax),%eax
80104101:	85 c0                	test   %eax,%eax
80104103:	74 15                	je     8010411a <pipewrite+0x4d>
        release(&p->lock);
80104105:	8b 45 08             	mov    0x8(%ebp),%eax
80104108:	89 04 24             	mov    %eax,(%esp)
8010410b:	e8 fd 11 00 00       	call   8010530d <release>
        return -1;
80104110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104115:	e9 9d 00 00 00       	jmp    801041b7 <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010411a:	8b 45 08             	mov    0x8(%ebp),%eax
8010411d:	05 34 02 00 00       	add    $0x234,%eax
80104122:	89 04 24             	mov    %eax,(%esp)
80104125:	e8 01 0c 00 00       	call   80104d2b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010412a:	8b 45 08             	mov    0x8(%ebp),%eax
8010412d:	8b 55 08             	mov    0x8(%ebp),%edx
80104130:	81 c2 38 02 00 00    	add    $0x238,%edx
80104136:	89 44 24 04          	mov    %eax,0x4(%esp)
8010413a:	89 14 24             	mov    %edx,(%esp)
8010413d:	e8 12 0b 00 00       	call   80104c54 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104142:	8b 45 08             	mov    0x8(%ebp),%eax
80104145:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104154:	05 00 02 00 00       	add    $0x200,%eax
80104159:	39 c2                	cmp    %eax,%edx
8010415b:	74 8f                	je     801040ec <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010415d:	8b 45 08             	mov    0x8(%ebp),%eax
80104160:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104166:	8d 48 01             	lea    0x1(%eax),%ecx
80104169:	8b 55 08             	mov    0x8(%ebp),%edx
8010416c:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104172:	25 ff 01 00 00       	and    $0x1ff,%eax
80104177:	89 c1                	mov    %eax,%ecx
80104179:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417f:	01 d0                	add    %edx,%eax
80104181:	8a 10                	mov    (%eax),%dl
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010418a:	ff 45 f4             	incl   -0xc(%ebp)
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	3b 45 10             	cmp    0x10(%ebp),%eax
80104193:	0f 8c 51 ff ff ff    	jl     801040ea <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	05 34 02 00 00       	add    $0x234,%eax
801041a1:	89 04 24             	mov    %eax,(%esp)
801041a4:	e8 82 0b 00 00       	call   80104d2b <wakeup>
  release(&p->lock);
801041a9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ac:	89 04 24             	mov    %eax,(%esp)
801041af:	e8 59 11 00 00       	call   8010530d <release>
  return n;
801041b4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041b7:	c9                   	leave  
801041b8:	c3                   	ret    

801041b9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041b9:	55                   	push   %ebp
801041ba:	89 e5                	mov    %esp,%ebp
801041bc:	53                   	push   %ebx
801041bd:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041c0:	8b 45 08             	mov    0x8(%ebp),%eax
801041c3:	89 04 24             	mov    %eax,(%esp)
801041c6:	e8 d8 10 00 00       	call   801052a3 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041cb:	eb 39                	jmp    80104206 <piperead+0x4d>
    if(myproc()->killed){
801041cd:	e8 d1 01 00 00       	call   801043a3 <myproc>
801041d2:	8b 40 24             	mov    0x24(%eax),%eax
801041d5:	85 c0                	test   %eax,%eax
801041d7:	74 15                	je     801041ee <piperead+0x35>
      release(&p->lock);
801041d9:	8b 45 08             	mov    0x8(%ebp),%eax
801041dc:	89 04 24             	mov    %eax,(%esp)
801041df:	e8 29 11 00 00       	call   8010530d <release>
      return -1;
801041e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e9:	e9 b3 00 00 00       	jmp    801042a1 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801041ee:	8b 45 08             	mov    0x8(%ebp),%eax
801041f1:	8b 55 08             	mov    0x8(%ebp),%edx
801041f4:	81 c2 34 02 00 00    	add    $0x234,%edx
801041fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801041fe:	89 14 24             	mov    %edx,(%esp)
80104201:	e8 4e 0a 00 00       	call   80104c54 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010420f:	8b 45 08             	mov    0x8(%ebp),%eax
80104212:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104218:	39 c2                	cmp    %eax,%edx
8010421a:	75 0d                	jne    80104229 <piperead+0x70>
8010421c:	8b 45 08             	mov    0x8(%ebp),%eax
8010421f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104225:	85 c0                	test   %eax,%eax
80104227:	75 a4                	jne    801041cd <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104229:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104230:	eb 49                	jmp    8010427b <piperead+0xc2>
    if(p->nread == p->nwrite)
80104232:	8b 45 08             	mov    0x8(%ebp),%eax
80104235:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010423b:	8b 45 08             	mov    0x8(%ebp),%eax
8010423e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104244:	39 c2                	cmp    %eax,%edx
80104246:	75 02                	jne    8010424a <piperead+0x91>
      break;
80104248:	eb 39                	jmp    80104283 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010424a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104250:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010425c:	8d 48 01             	lea    0x1(%eax),%ecx
8010425f:	8b 55 08             	mov    0x8(%ebp),%edx
80104262:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104268:	25 ff 01 00 00       	and    $0x1ff,%eax
8010426d:	89 c2                	mov    %eax,%edx
8010426f:	8b 45 08             	mov    0x8(%ebp),%eax
80104272:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104276:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104278:	ff 45 f4             	incl   -0xc(%ebp)
8010427b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104281:	7c af                	jl     80104232 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104283:	8b 45 08             	mov    0x8(%ebp),%eax
80104286:	05 38 02 00 00       	add    $0x238,%eax
8010428b:	89 04 24             	mov    %eax,(%esp)
8010428e:	e8 98 0a 00 00       	call   80104d2b <wakeup>
  release(&p->lock);
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	89 04 24             	mov    %eax,(%esp)
80104299:	e8 6f 10 00 00       	call   8010530d <release>
  return i;
8010429e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042a1:	83 c4 24             	add    $0x24,%esp
801042a4:	5b                   	pop    %ebx
801042a5:	5d                   	pop    %ebp
801042a6:	c3                   	ret    
	...

801042a8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042a8:	55                   	push   %ebp
801042a9:	89 e5                	mov    %esp,%ebp
801042ab:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042ae:	9c                   	pushf  
801042af:	58                   	pop    %eax
801042b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042b6:	c9                   	leave  
801042b7:	c3                   	ret    

801042b8 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042b8:	55                   	push   %ebp
801042b9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042bb:	fb                   	sti    
}
801042bc:	5d                   	pop    %ebp
801042bd:	c3                   	ret    

801042be <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801042be:	55                   	push   %ebp
801042bf:	89 e5                	mov    %esp,%ebp
801042c1:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801042c4:	c7 44 24 04 78 97 10 	movl   $0x80109778,0x4(%esp)
801042cb:	80 
801042cc:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801042d3:	e8 aa 0f 00 00       	call   80105282 <initlock>
}
801042d8:	c9                   	leave  
801042d9:	c3                   	ret    

801042da <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801042da:	55                   	push   %ebp
801042db:	89 e5                	mov    %esp,%ebp
801042dd:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801042e0:	e8 3a 00 00 00       	call   8010431f <mycpu>
801042e5:	89 c2                	mov    %eax,%edx
801042e7:	b8 80 4c 11 80       	mov    $0x80114c80,%eax
801042ec:	29 c2                	sub    %eax,%edx
801042ee:	89 d0                	mov    %edx,%eax
801042f0:	c1 f8 04             	sar    $0x4,%eax
801042f3:	89 c1                	mov    %eax,%ecx
801042f5:	89 ca                	mov    %ecx,%edx
801042f7:	c1 e2 03             	shl    $0x3,%edx
801042fa:	01 ca                	add    %ecx,%edx
801042fc:	89 d0                	mov    %edx,%eax
801042fe:	c1 e0 05             	shl    $0x5,%eax
80104301:	29 d0                	sub    %edx,%eax
80104303:	c1 e0 02             	shl    $0x2,%eax
80104306:	01 c8                	add    %ecx,%eax
80104308:	c1 e0 03             	shl    $0x3,%eax
8010430b:	01 c8                	add    %ecx,%eax
8010430d:	89 c2                	mov    %eax,%edx
8010430f:	c1 e2 0f             	shl    $0xf,%edx
80104312:	29 c2                	sub    %eax,%edx
80104314:	c1 e2 02             	shl    $0x2,%edx
80104317:	01 ca                	add    %ecx,%edx
80104319:	89 d0                	mov    %edx,%eax
8010431b:	f7 d8                	neg    %eax
}
8010431d:	c9                   	leave  
8010431e:	c3                   	ret    

8010431f <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010431f:	55                   	push   %ebp
80104320:	89 e5                	mov    %esp,%ebp
80104322:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104325:	e8 7e ff ff ff       	call   801042a8 <readeflags>
8010432a:	25 00 02 00 00       	and    $0x200,%eax
8010432f:	85 c0                	test   %eax,%eax
80104331:	74 0c                	je     8010433f <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104333:	c7 04 24 80 97 10 80 	movl   $0x80109780,(%esp)
8010433a:	e8 15 c2 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010433f:	e8 15 ee ff ff       	call   80103159 <lapicid>
80104344:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104347:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010434e:	eb 3b                	jmp    8010438b <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104350:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104353:	89 d0                	mov    %edx,%eax
80104355:	c1 e0 02             	shl    $0x2,%eax
80104358:	01 d0                	add    %edx,%eax
8010435a:	01 c0                	add    %eax,%eax
8010435c:	01 d0                	add    %edx,%eax
8010435e:	c1 e0 04             	shl    $0x4,%eax
80104361:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104366:	8a 00                	mov    (%eax),%al
80104368:	0f b6 c0             	movzbl %al,%eax
8010436b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010436e:	75 18                	jne    80104388 <mycpu+0x69>
      return &cpus[i];
80104370:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104373:	89 d0                	mov    %edx,%eax
80104375:	c1 e0 02             	shl    $0x2,%eax
80104378:	01 d0                	add    %edx,%eax
8010437a:	01 c0                	add    %eax,%eax
8010437c:	01 d0                	add    %edx,%eax
8010437e:	c1 e0 04             	shl    $0x4,%eax
80104381:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104386:	eb 19                	jmp    801043a1 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104388:	ff 45 f4             	incl   -0xc(%ebp)
8010438b:	a1 00 52 11 80       	mov    0x80115200,%eax
80104390:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104393:	7c bb                	jl     80104350 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104395:	c7 04 24 a6 97 10 80 	movl   $0x801097a6,(%esp)
8010439c:	e8 b3 c1 ff ff       	call   80100554 <panic>
}
801043a1:	c9                   	leave  
801043a2:	c3                   	ret    

801043a3 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801043a3:	55                   	push   %ebp
801043a4:	89 e5                	mov    %esp,%ebp
801043a6:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801043a9:	e8 54 10 00 00       	call   80105402 <pushcli>
  c = mycpu();
801043ae:	e8 6c ff ff ff       	call   8010431f <mycpu>
801043b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801043b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801043bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801043c2:	e8 85 10 00 00       	call   8010544c <popcli>
  return p;
801043c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801043ca:	c9                   	leave  
801043cb:	c3                   	ret    

801043cc <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043cc:	55                   	push   %ebp
801043cd:	89 e5                	mov    %esp,%ebp
801043cf:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);
801043d2:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043d9:	e8 c5 0e 00 00       	call   801052a3 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043de:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801043e5:	eb 53                	jmp    8010443a <allocproc+0x6e>
    if(p->state == UNUSED)
801043e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ea:	8b 40 0c             	mov    0xc(%eax),%eax
801043ed:	85 c0                	test   %eax,%eax
801043ef:	75 42                	jne    80104433 <allocproc+0x67>
      goto found;
801043f1:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f5:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043fc:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104401:	8d 50 01             	lea    0x1(%eax),%edx
80104404:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
8010440a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010440d:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104410:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104417:	e8 f1 0e 00 00       	call   8010530d <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010441c:	e8 76 e9 ff ff       	call   80102d97 <kalloc>
80104421:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104424:	89 42 08             	mov    %eax,0x8(%edx)
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	8b 40 08             	mov    0x8(%eax),%eax
8010442d:	85 c0                	test   %eax,%eax
8010442f:	75 39                	jne    8010446a <allocproc+0x9e>
80104431:	eb 26                	jmp    80104459 <allocproc+0x8d>
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104433:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010443a:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104441:	72 a4                	jb     801043e7 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104443:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010444a:	e8 be 0e 00 00       	call   8010530d <release>
  return 0;
8010444f:	b8 00 00 00 00       	mov    $0x0,%eax
80104454:	e9 8d 00 00 00       	jmp    801044e6 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104463:	b8 00 00 00 00       	mov    $0x0,%eax
80104468:	eb 7c                	jmp    801044e6 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 40 08             	mov    0x8(%eax),%eax
80104470:	05 00 10 00 00       	add    $0x1000,%eax
80104475:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104478:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104482:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104485:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104489:	ba 78 6e 10 80       	mov    $0x80106e78,%edx
8010448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104491:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104493:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010449d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801044a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a3:	8b 40 1c             	mov    0x1c(%eax),%eax
801044a6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044ad:	00 
801044ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044b5:	00 
801044b6:	89 04 24             	mov    %eax,(%esp)
801044b9:	e8 48 10 00 00       	call   80105506 <memset>
  p->context->eip = (uint)forkret;
801044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c1:	8b 40 1c             	mov    0x1c(%eax),%eax
801044c4:	ba 15 4c 10 80       	mov    $0x80104c15,%edx
801044c9:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
801044cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cf:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
801044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801044e0:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044e6:	c9                   	leave  
801044e7:	c3                   	ret    

801044e8 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044e8:	55                   	push   %ebp
801044e9:	89 e5                	mov    %esp,%ebp
801044eb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801044ee:	e8 d9 fe ff ff       	call   801043cc <allocproc>
801044f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801044f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f9:	a3 00 c9 10 80       	mov    %eax,0x8010c900
  if((p->pgdir = setupkvm()) == 0)
801044fe:	e8 cf 3e 00 00       	call   801083d2 <setupkvm>
80104503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104506:	89 42 04             	mov    %eax,0x4(%edx)
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450c:	8b 40 04             	mov    0x4(%eax),%eax
8010450f:	85 c0                	test   %eax,%eax
80104511:	75 0c                	jne    8010451f <userinit+0x37>
    panic("userinit: out of memory?");
80104513:	c7 04 24 b6 97 10 80 	movl   $0x801097b6,(%esp)
8010451a:	e8 35 c0 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010451f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 04             	mov    0x4(%eax),%eax
8010452a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010452e:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
80104535:	80 
80104536:	89 04 24             	mov    %eax,(%esp)
80104539:	e8 f5 40 00 00       	call   80108633 <inituvm>
  p->sz = PGSIZE;
8010453e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104541:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	8b 40 18             	mov    0x18(%eax),%eax
8010454d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104554:	00 
80104555:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010455c:	00 
8010455d:	89 04 24             	mov    %eax,(%esp)
80104560:	e8 a1 0f 00 00       	call   80105506 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104568:	8b 40 18             	mov    0x18(%eax),%eax
8010456b:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104574:	8b 40 18             	mov    0x18(%eax),%eax
80104577:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	8b 50 18             	mov    0x18(%eax),%edx
80104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104586:	8b 40 18             	mov    0x18(%eax),%eax
80104589:	8b 40 2c             	mov    0x2c(%eax),%eax
8010458c:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	8b 50 18             	mov    0x18(%eax),%edx
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 40 18             	mov    0x18(%eax),%eax
8010459c:	8b 40 2c             	mov    0x2c(%eax),%eax
8010459f:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	8b 40 18             	mov    0x18(%eax),%eax
801045a9:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801045b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b3:	8b 40 18             	mov    0x18(%eax),%eax
801045b6:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	8b 40 18             	mov    0x18(%eax),%eax
801045c3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cd:	83 c0 6c             	add    $0x6c,%eax
801045d0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045d7:	00 
801045d8:	c7 44 24 04 cf 97 10 	movl   $0x801097cf,0x4(%esp)
801045df:	80 
801045e0:	89 04 24             	mov    %eax,(%esp)
801045e3:	e8 2a 11 00 00       	call   80105712 <safestrcpy>
  p->cwd = namei("/");
801045e8:	c7 04 24 d8 97 10 80 	movl   $0x801097d8,(%esp)
801045ef:	e8 5c e0 ff ff       	call   80102650 <namei>
801045f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801045fa:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104601:	e8 9d 0c 00 00       	call   801052a3 <acquire>

  p->state = RUNNABLE;
80104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104609:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104610:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104617:	e8 f1 0c 00 00       	call   8010530d <release>
}
8010461c:	c9                   	leave  
8010461d:	c3                   	ret    

8010461e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010461e:	55                   	push   %ebp
8010461f:	89 e5                	mov    %esp,%ebp
80104621:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104624:	e8 7a fd ff ff       	call   801043a3 <myproc>
80104629:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
8010462c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010462f:	8b 00                	mov    (%eax),%eax
80104631:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104634:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104638:	7e 31                	jle    8010466b <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010463a:	8b 55 08             	mov    0x8(%ebp),%edx
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	01 c2                	add    %eax,%edx
80104642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104645:	8b 40 04             	mov    0x4(%eax),%eax
80104648:	89 54 24 08          	mov    %edx,0x8(%esp)
8010464c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104653:	89 04 24             	mov    %eax,(%esp)
80104656:	e8 43 41 00 00       	call   8010879e <allocuvm>
8010465b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010465e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104662:	75 3e                	jne    801046a2 <growproc+0x84>
      return -1;
80104664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104669:	eb 4f                	jmp    801046ba <growproc+0x9c>
  } else if(n < 0){
8010466b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010466f:	79 31                	jns    801046a2 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104671:	8b 55 08             	mov    0x8(%ebp),%edx
80104674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104677:	01 c2                	add    %eax,%edx
80104679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010467c:	8b 40 04             	mov    0x4(%eax),%eax
8010467f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104686:	89 54 24 04          	mov    %edx,0x4(%esp)
8010468a:	89 04 24             	mov    %eax,(%esp)
8010468d:	e8 22 42 00 00       	call   801088b4 <deallocuvm>
80104692:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104695:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104699:	75 07                	jne    801046a2 <growproc+0x84>
      return -1;
8010469b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a0:	eb 18                	jmp    801046ba <growproc+0x9c>
  }
  curproc->sz = sz;
801046a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046a8:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801046aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ad:	89 04 24             	mov    %eax,(%esp)
801046b0:	e8 f7 3d 00 00       	call   801084ac <switchuvm>
  return 0;
801046b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046ba:	c9                   	leave  
801046bb:	c3                   	ret    

801046bc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	57                   	push   %edi
801046c0:	56                   	push   %esi
801046c1:	53                   	push   %ebx
801046c2:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801046c5:	e8 d9 fc ff ff       	call   801043a3 <myproc>
801046ca:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801046cd:	e8 fa fc ff ff       	call   801043cc <allocproc>
801046d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
801046d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801046d9:	75 0a                	jne    801046e5 <fork+0x29>
    return -1;
801046db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e0:	e9 47 01 00 00       	jmp    8010482c <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801046e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e8:	8b 10                	mov    (%eax),%edx
801046ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ed:	8b 40 04             	mov    0x4(%eax),%eax
801046f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801046f4:	89 04 24             	mov    %eax,(%esp)
801046f7:	e8 58 43 00 00       	call   80108a54 <copyuvm>
801046fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046ff:	89 42 04             	mov    %eax,0x4(%edx)
80104702:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104705:	8b 40 04             	mov    0x4(%eax),%eax
80104708:	85 c0                	test   %eax,%eax
8010470a:	75 2c                	jne    80104738 <fork+0x7c>
    kfree(np->kstack);
8010470c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010470f:	8b 40 08             	mov    0x8(%eax),%eax
80104712:	89 04 24             	mov    %eax,(%esp)
80104715:	e8 ab e5 ff ff       	call   80102cc5 <kfree>
    np->kstack = 0;
8010471a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010471d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104724:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104727:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010472e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104733:	e9 f4 00 00 00       	jmp    8010482c <fork+0x170>
  }
  np->sz = curproc->sz;
80104738:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473b:	8b 10                	mov    (%eax),%edx
8010473d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104740:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104742:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104745:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104748:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010474b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010474e:	8b 50 18             	mov    0x18(%eax),%edx
80104751:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104754:	8b 40 18             	mov    0x18(%eax),%eax
80104757:	89 c3                	mov    %eax,%ebx
80104759:	b8 13 00 00 00       	mov    $0x13,%eax
8010475e:	89 d7                	mov    %edx,%edi
80104760:	89 de                	mov    %ebx,%esi
80104762:	89 c1                	mov    %eax,%ecx
80104764:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104766:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104769:	8b 40 18             	mov    0x18(%eax),%eax
8010476c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104773:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010477a:	eb 36                	jmp    801047b2 <fork+0xf6>
    if(curproc->ofile[i])
8010477c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104782:	83 c2 08             	add    $0x8,%edx
80104785:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104789:	85 c0                	test   %eax,%eax
8010478b:	74 22                	je     801047af <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010478d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104790:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104793:	83 c2 08             	add    $0x8,%edx
80104796:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010479a:	89 04 24             	mov    %eax,(%esp)
8010479d:	e8 c0 c9 ff ff       	call   80101162 <filedup>
801047a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801047a8:	83 c1 08             	add    $0x8,%ecx
801047ab:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801047af:	ff 45 e4             	incl   -0x1c(%ebp)
801047b2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801047b6:	7e c4                	jle    8010477c <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801047b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bb:	8b 40 68             	mov    0x68(%eax),%eax
801047be:	89 04 24             	mov    %eax,(%esp)
801047c1:	e8 ca d2 ff ff       	call   80101a90 <idup>
801047c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047c9:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801047cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cf:	8d 50 6c             	lea    0x6c(%eax),%edx
801047d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047d5:	83 c0 6c             	add    $0x6c,%eax
801047d8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047df:	00 
801047e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801047e4:	89 04 24             	mov    %eax,(%esp)
801047e7:	e8 26 0f 00 00       	call   80105712 <safestrcpy>



  pid = np->pid;
801047ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047ef:	8b 40 10             	mov    0x10(%eax),%eax
801047f2:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801047f5:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801047fc:	e8 a2 0a 00 00       	call   801052a3 <acquire>

  np->state = RUNNABLE;
80104801:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104804:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
8010480b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104814:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104817:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
8010481d:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104824:	e8 e4 0a 00 00       	call   8010530d <release>

  return pid;
80104829:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010482c:	83 c4 2c             	add    $0x2c,%esp
8010482f:	5b                   	pop    %ebx
80104830:	5e                   	pop    %esi
80104831:	5f                   	pop    %edi
80104832:	5d                   	pop    %ebp
80104833:	c3                   	ret    

80104834 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104834:	55                   	push   %ebp
80104835:	89 e5                	mov    %esp,%ebp
80104837:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
8010483a:	e8 64 fb ff ff       	call   801043a3 <myproc>
8010483f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104842:	a1 00 c9 10 80       	mov    0x8010c900,%eax
80104847:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010484a:	75 0c                	jne    80104858 <exit+0x24>
    panic("init exiting");
8010484c:	c7 04 24 da 97 10 80 	movl   $0x801097da,(%esp)
80104853:	e8 fc bc ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104858:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010485f:	eb 3a                	jmp    8010489b <exit+0x67>
    if(curproc->ofile[fd]){
80104861:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104864:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104867:	83 c2 08             	add    $0x8,%edx
8010486a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010486e:	85 c0                	test   %eax,%eax
80104870:	74 26                	je     80104898 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104872:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104875:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104878:	83 c2 08             	add    $0x8,%edx
8010487b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010487f:	89 04 24             	mov    %eax,(%esp)
80104882:	e8 23 c9 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104887:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010488a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010488d:	83 c2 08             	add    $0x8,%edx
80104890:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104897:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104898:	ff 45 f0             	incl   -0x10(%ebp)
8010489b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010489f:	7e c0                	jle    80104861 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
801048a1:	e8 fd ed ff ff       	call   801036a3 <begin_op>
  iput(curproc->cwd);
801048a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048a9:	8b 40 68             	mov    0x68(%eax),%eax
801048ac:	89 04 24             	mov    %eax,(%esp)
801048af:	e8 5c d3 ff ff       	call   80101c10 <iput>
  end_op();
801048b4:	e8 6c ee ff ff       	call   80103725 <end_op>
  curproc->cwd = 0;
801048b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048bc:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801048c3:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801048ca:	e8 d4 09 00 00       	call   801052a3 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801048cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048d2:	8b 40 14             	mov    0x14(%eax),%eax
801048d5:	89 04 24             	mov    %eax,(%esp)
801048d8:	e8 0d 04 00 00       	call   80104cea <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048dd:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801048e4:	eb 36                	jmp    8010491c <exit+0xe8>
    if(p->parent == curproc){
801048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e9:	8b 40 14             	mov    0x14(%eax),%eax
801048ec:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048ef:	75 24                	jne    80104915 <exit+0xe1>
      p->parent = initproc;
801048f1:	8b 15 00 c9 10 80    	mov    0x8010c900,%edx
801048f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fa:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104900:	8b 40 0c             	mov    0xc(%eax),%eax
80104903:	83 f8 05             	cmp    $0x5,%eax
80104906:	75 0d                	jne    80104915 <exit+0xe1>
        wakeup1(initproc);
80104908:	a1 00 c9 10 80       	mov    0x8010c900,%eax
8010490d:	89 04 24             	mov    %eax,(%esp)
80104910:	e8 d5 03 00 00       	call   80104cea <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104915:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010491c:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104923:	72 c1                	jb     801048e6 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104925:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104928:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010492f:	e8 01 02 00 00       	call   80104b35 <sched>
  panic("zombie exit");
80104934:	c7 04 24 e7 97 10 80 	movl   $0x801097e7,(%esp)
8010493b:	e8 14 bc ff ff       	call   80100554 <panic>

80104940 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104943:	eb 06                	jmp    8010494b <strcmp1+0xb>
    p++, q++;
80104945:	ff 45 08             	incl   0x8(%ebp)
80104948:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
8010494b:	8b 45 08             	mov    0x8(%ebp),%eax
8010494e:	8a 00                	mov    (%eax),%al
80104950:	84 c0                	test   %al,%al
80104952:	74 0e                	je     80104962 <strcmp1+0x22>
80104954:	8b 45 08             	mov    0x8(%ebp),%eax
80104957:	8a 10                	mov    (%eax),%dl
80104959:	8b 45 0c             	mov    0xc(%ebp),%eax
8010495c:	8a 00                	mov    (%eax),%al
8010495e:	38 c2                	cmp    %al,%dl
80104960:	74 e3                	je     80104945 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104962:	8b 45 08             	mov    0x8(%ebp),%eax
80104965:	8a 00                	mov    (%eax),%al
80104967:	0f b6 d0             	movzbl %al,%edx
8010496a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010496d:	8a 00                	mov    (%eax),%al
8010496f:	0f b6 c0             	movzbl %al,%eax
80104972:	29 c2                	sub    %eax,%edx
80104974:	89 d0                	mov    %edx,%eax
}
80104976:	5d                   	pop    %ebp
80104977:	c3                   	ret    

80104978 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104978:	55                   	push   %ebp
80104979:	89 e5                	mov    %esp,%ebp
8010497b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010497e:	e8 20 fa ff ff       	call   801043a3 <myproc>
80104983:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104986:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010498d:	e8 11 09 00 00       	call   801052a3 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104992:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104999:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801049a0:	e9 98 00 00 00       	jmp    80104a3d <wait+0xc5>
      if(p->parent != curproc)
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	8b 40 14             	mov    0x14(%eax),%eax
801049ab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801049ae:	74 05                	je     801049b5 <wait+0x3d>
        continue;
801049b0:	e9 81 00 00 00       	jmp    80104a36 <wait+0xbe>
      havekids = 1;
801049b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801049bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bf:	8b 40 0c             	mov    0xc(%eax),%eax
801049c2:	83 f8 05             	cmp    $0x5,%eax
801049c5:	75 6f                	jne    80104a36 <wait+0xbe>
        // Found one.
        pid = p->pid;
801049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ca:	8b 40 10             	mov    0x10(%eax),%eax
801049cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801049d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d3:	8b 40 08             	mov    0x8(%eax),%eax
801049d6:	89 04 24             	mov    %eax,(%esp)
801049d9:	e8 e7 e2 ff ff       	call   80102cc5 <kfree>
        p->kstack = 0;
801049de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049eb:	8b 40 04             	mov    0x4(%eax),%eax
801049ee:	89 04 24             	mov    %eax,(%esp)
801049f1:	e8 82 3f 00 00       	call   80108978 <freevm>
        p->pid = 0;
801049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a03:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a14:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104a25:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a2c:	e8 dc 08 00 00       	call   8010530d <release>
        return pid;
80104a31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a34:	eb 4f                	jmp    80104a85 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a36:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a3d:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104a44:	0f 82 5b ff ff ff    	jb     801049a5 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104a4a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a4e:	74 0a                	je     80104a5a <wait+0xe2>
80104a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a53:	8b 40 24             	mov    0x24(%eax),%eax
80104a56:	85 c0                	test   %eax,%eax
80104a58:	74 13                	je     80104a6d <wait+0xf5>
      release(&ptable.lock);
80104a5a:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a61:	e8 a7 08 00 00       	call   8010530d <release>
      return -1;
80104a66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a6b:	eb 18                	jmp    80104a85 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104a6d:	c7 44 24 04 20 52 11 	movl   $0x80115220,0x4(%esp)
80104a74:	80 
80104a75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a78:	89 04 24             	mov    %eax,(%esp)
80104a7b:	e8 d4 01 00 00       	call   80104c54 <sleep>
  }
80104a80:	e9 0d ff ff ff       	jmp    80104992 <wait+0x1a>
}
80104a85:	c9                   	leave  
80104a86:	c3                   	ret    

80104a87 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a87:	55                   	push   %ebp
80104a88:	89 e5                	mov    %esp,%ebp
80104a8a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a8d:	e8 8d f8 ff ff       	call   8010431f <mycpu>
80104a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a98:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a9f:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104aa2:	e8 11 f8 ff ff       	call   801042b8 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104aa7:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104aae:	e8 f0 07 00 00       	call   801052a3 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab3:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104aba:	eb 5f                	jmp    80104b1b <scheduler+0x94>
      if(p->state != RUNNABLE)
80104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac2:	83 f8 03             	cmp    $0x3,%eax
80104ac5:	74 02                	je     80104ac9 <scheduler+0x42>
        continue;
80104ac7:	eb 4b                	jmp    80104b14 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104acc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104acf:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad8:	89 04 24             	mov    %eax,(%esp)
80104adb:	e8 cc 39 00 00       	call   801084ac <switchuvm>
      p->state = RUNNING;
80104ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae3:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	8b 40 1c             	mov    0x1c(%eax),%eax
80104af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104af3:	83 c2 04             	add    $0x4,%edx
80104af6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104afa:	89 14 24             	mov    %edx,(%esp)
80104afd:	e8 7e 0c 00 00       	call   80105780 <swtch>
      switchkvm();
80104b02:	e8 8b 39 00 00       	call   80108492 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b0a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104b11:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b14:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104b1b:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104b22:	72 98                	jb     80104abc <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104b24:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b2b:	e8 dd 07 00 00       	call   8010530d <release>

  }
80104b30:	e9 6d ff ff ff       	jmp    80104aa2 <scheduler+0x1b>

80104b35 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104b35:	55                   	push   %ebp
80104b36:	89 e5                	mov    %esp,%ebp
80104b38:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104b3b:	e8 63 f8 ff ff       	call   801043a3 <myproc>
80104b40:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104b43:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b4a:	e8 82 08 00 00       	call   801053d1 <holding>
80104b4f:	85 c0                	test   %eax,%eax
80104b51:	75 0c                	jne    80104b5f <sched+0x2a>
    panic("sched ptable.lock");
80104b53:	c7 04 24 f3 97 10 80 	movl   $0x801097f3,(%esp)
80104b5a:	e8 f5 b9 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104b5f:	e8 bb f7 ff ff       	call   8010431f <mycpu>
80104b64:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b6a:	83 f8 01             	cmp    $0x1,%eax
80104b6d:	74 0c                	je     80104b7b <sched+0x46>
    panic("sched locks");
80104b6f:	c7 04 24 05 98 10 80 	movl   $0x80109805,(%esp)
80104b76:	e8 d9 b9 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7e:	8b 40 0c             	mov    0xc(%eax),%eax
80104b81:	83 f8 04             	cmp    $0x4,%eax
80104b84:	75 0c                	jne    80104b92 <sched+0x5d>
    panic("sched running");
80104b86:	c7 04 24 11 98 10 80 	movl   $0x80109811,(%esp)
80104b8d:	e8 c2 b9 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104b92:	e8 11 f7 ff ff       	call   801042a8 <readeflags>
80104b97:	25 00 02 00 00       	and    $0x200,%eax
80104b9c:	85 c0                	test   %eax,%eax
80104b9e:	74 0c                	je     80104bac <sched+0x77>
    panic("sched interruptible");
80104ba0:	c7 04 24 1f 98 10 80 	movl   $0x8010981f,(%esp)
80104ba7:	e8 a8 b9 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104bac:	e8 6e f7 ff ff       	call   8010431f <mycpu>
80104bb1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104bba:	e8 60 f7 ff ff       	call   8010431f <mycpu>
80104bbf:	8b 40 04             	mov    0x4(%eax),%eax
80104bc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bc5:	83 c2 1c             	add    $0x1c,%edx
80104bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bcc:	89 14 24             	mov    %edx,(%esp)
80104bcf:	e8 ac 0b 00 00       	call   80105780 <swtch>
  mycpu()->intena = intena;
80104bd4:	e8 46 f7 ff ff       	call   8010431f <mycpu>
80104bd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bdc:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104be2:	c9                   	leave  
80104be3:	c3                   	ret    

80104be4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104be4:	55                   	push   %ebp
80104be5:	89 e5                	mov    %esp,%ebp
80104be7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104bea:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104bf1:	e8 ad 06 00 00       	call   801052a3 <acquire>
  myproc()->state = RUNNABLE;
80104bf6:	e8 a8 f7 ff ff       	call   801043a3 <myproc>
80104bfb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c02:	e8 2e ff ff ff       	call   80104b35 <sched>
  release(&ptable.lock);
80104c07:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c0e:	e8 fa 06 00 00       	call   8010530d <release>
}
80104c13:	c9                   	leave  
80104c14:	c3                   	ret    

80104c15 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104c15:	55                   	push   %ebp
80104c16:	89 e5                	mov    %esp,%ebp
80104c18:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104c1b:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c22:	e8 e6 06 00 00       	call   8010530d <release>

  if (first) {
80104c27:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104c2c:	85 c0                	test   %eax,%eax
80104c2e:	74 22                	je     80104c52 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104c30:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104c37:	00 00 00 
    iinit(ROOTDEV);
80104c3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c41:	e8 15 cb ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104c46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c4d:	e8 52 e8 ff ff       	call   801034a4 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c52:	c9                   	leave  
80104c53:	c3                   	ret    

80104c54 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c54:	55                   	push   %ebp
80104c55:	89 e5                	mov    %esp,%ebp
80104c57:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104c5a:	e8 44 f7 ff ff       	call   801043a3 <myproc>
80104c5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c66:	75 0c                	jne    80104c74 <sleep+0x20>
    panic("sleep");
80104c68:	c7 04 24 33 98 10 80 	movl   $0x80109833,(%esp)
80104c6f:	e8 e0 b8 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104c74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c78:	75 0c                	jne    80104c86 <sleep+0x32>
    panic("sleep without lk");
80104c7a:	c7 04 24 39 98 10 80 	movl   $0x80109839,(%esp)
80104c81:	e8 ce b8 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c86:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104c8d:	74 17                	je     80104ca6 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c8f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c96:	e8 08 06 00 00       	call   801052a3 <acquire>
    release(lk);
80104c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9e:	89 04 24             	mov    %eax,(%esp)
80104ca1:	e8 67 06 00 00       	call   8010530d <release>
  }
  // Go to sleep.
  p->chan = chan;
80104ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca9:	8b 55 08             	mov    0x8(%ebp),%edx
80104cac:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb2:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104cb9:	e8 77 fe ff ff       	call   80104b35 <sched>

  // Tidy up.
  p->chan = 0;
80104cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104cc8:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104ccf:	74 17                	je     80104ce8 <sleep+0x94>
    release(&ptable.lock);
80104cd1:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cd8:	e8 30 06 00 00       	call   8010530d <release>
    acquire(lk);
80104cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce0:	89 04 24             	mov    %eax,(%esp)
80104ce3:	e8 bb 05 00 00       	call   801052a3 <acquire>
  }
}
80104ce8:	c9                   	leave  
80104ce9:	c3                   	ret    

80104cea <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cea:	55                   	push   %ebp
80104ceb:	89 e5                	mov    %esp,%ebp
80104ced:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cf0:	c7 45 fc 54 52 11 80 	movl   $0x80115254,-0x4(%ebp)
80104cf7:	eb 27                	jmp    80104d20 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cfc:	8b 40 0c             	mov    0xc(%eax),%eax
80104cff:	83 f8 02             	cmp    $0x2,%eax
80104d02:	75 15                	jne    80104d19 <wakeup1+0x2f>
80104d04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d07:	8b 40 20             	mov    0x20(%eax),%eax
80104d0a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d0d:	75 0a                	jne    80104d19 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104d0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d12:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d19:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104d20:	81 7d fc 54 73 11 80 	cmpl   $0x80117354,-0x4(%ebp)
80104d27:	72 d0                	jb     80104cf9 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104d29:	c9                   	leave  
80104d2a:	c3                   	ret    

80104d2b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d2b:	55                   	push   %ebp
80104d2c:	89 e5                	mov    %esp,%ebp
80104d2e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104d31:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d38:	e8 66 05 00 00       	call   801052a3 <acquire>
  wakeup1(chan);
80104d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d40:	89 04 24             	mov    %eax,(%esp)
80104d43:	e8 a2 ff ff ff       	call   80104cea <wakeup1>
  release(&ptable.lock);
80104d48:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d4f:	e8 b9 05 00 00       	call   8010530d <release>
}
80104d54:	c9                   	leave  
80104d55:	c3                   	ret    

80104d56 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d56:	55                   	push   %ebp
80104d57:	89 e5                	mov    %esp,%ebp
80104d59:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d5c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d63:	e8 3b 05 00 00       	call   801052a3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d68:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104d6f:	eb 44                	jmp    80104db5 <kill+0x5f>
    if(p->pid == pid){
80104d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d74:	8b 40 10             	mov    0x10(%eax),%eax
80104d77:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d7a:	75 32                	jne    80104dae <kill+0x58>
      p->killed = 1;
80104d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d89:	8b 40 0c             	mov    0xc(%eax),%eax
80104d8c:	83 f8 02             	cmp    $0x2,%eax
80104d8f:	75 0a                	jne    80104d9b <kill+0x45>
        p->state = RUNNABLE;
80104d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d94:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d9b:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104da2:	e8 66 05 00 00       	call   8010530d <release>
      return 0;
80104da7:	b8 00 00 00 00       	mov    $0x0,%eax
80104dac:	eb 21                	jmp    80104dcf <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dae:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104db5:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104dbc:	72 b3                	jb     80104d71 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104dbe:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104dc5:	e8 43 05 00 00       	call   8010530d <release>
  return -1;
80104dca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dcf:	c9                   	leave  
80104dd0:	c3                   	ret    

80104dd1 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dd1:	55                   	push   %ebp
80104dd2:	89 e5                	mov    %esp,%ebp
80104dd4:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd7:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104dde:	e9 1e 01 00 00       	jmp    80104f01 <procdump+0x130>
    if(p->state == UNUSED)
80104de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de6:	8b 40 0c             	mov    0xc(%eax),%eax
80104de9:	85 c0                	test   %eax,%eax
80104deb:	75 05                	jne    80104df2 <procdump+0x21>
      continue;
80104ded:	e9 08 01 00 00       	jmp    80104efa <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df5:	8b 40 0c             	mov    0xc(%eax),%eax
80104df8:	83 f8 05             	cmp    $0x5,%eax
80104dfb:	77 23                	ja     80104e20 <procdump+0x4f>
80104dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e00:	8b 40 0c             	mov    0xc(%eax),%eax
80104e03:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104e0a:	85 c0                	test   %eax,%eax
80104e0c:	74 12                	je     80104e20 <procdump+0x4f>
      state = states[p->state];
80104e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e11:	8b 40 0c             	mov    0xc(%eax),%eax
80104e14:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104e1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e1e:	eb 07                	jmp    80104e27 <procdump+0x56>
    else
      state = "???";
80104e20:	c7 45 ec 4a 98 10 80 	movl   $0x8010984a,-0x14(%ebp)

    if(p->cont == NULL){
80104e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104e30:	85 c0                	test   %eax,%eax
80104e32:	75 29                	jne    80104e5d <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e37:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3d:	8b 40 10             	mov    0x10(%eax),%eax
80104e40:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104e44:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e47:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e4f:	c7 04 24 4e 98 10 80 	movl   $0x8010984e,(%esp)
80104e56:	e8 66 b5 ff ff       	call   801003c1 <cprintf>
80104e5b:	eb 37                	jmp    80104e94 <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e60:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e66:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104e6c:	8d 48 18             	lea    0x18(%eax),%ecx
80104e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e72:	8b 40 10             	mov    0x10(%eax),%eax
80104e75:	89 54 24 10          	mov    %edx,0x10(%esp)
80104e79:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104e80:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104e84:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e88:	c7 04 24 5c 98 10 80 	movl   $0x8010985c,(%esp)
80104e8f:	e8 2d b5 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80104e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e97:	8b 40 0c             	mov    0xc(%eax),%eax
80104e9a:	83 f8 02             	cmp    $0x2,%eax
80104e9d:	75 4f                	jne    80104eee <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea2:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ea5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea8:	83 c0 08             	add    $0x8,%eax
80104eab:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104eae:	89 54 24 04          	mov    %edx,0x4(%esp)
80104eb2:	89 04 24             	mov    %eax,(%esp)
80104eb5:	e8 a0 04 00 00       	call   8010535a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104eba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ec1:	eb 1a                	jmp    80104edd <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eca:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ece:	c7 04 24 68 98 10 80 	movl   $0x80109868,(%esp)
80104ed5:	e8 e7 b4 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104eda:	ff 45 f4             	incl   -0xc(%ebp)
80104edd:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ee1:	7f 0b                	jg     80104eee <procdump+0x11d>
80104ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eea:	85 c0                	test   %eax,%eax
80104eec:	75 d5                	jne    80104ec3 <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104eee:	c7 04 24 6c 98 10 80 	movl   $0x8010986c,(%esp)
80104ef5:	e8 c7 b4 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104efa:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104f01:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80104f08:	0f 82 d5 fe ff ff    	jb     80104de3 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f0e:	c9                   	leave  
80104f0f:	c3                   	ret    

80104f10 <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
80104f10:	55                   	push   %ebp
80104f11:	89 e5                	mov    %esp,%ebp
80104f13:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  // cprintf("In procdump\n.");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f16:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104f1d:	eb 37                	jmp    80104f56 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
80104f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f22:	8d 50 18             	lea    0x18(%eax),%edx
80104f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f28:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f2e:	83 c0 18             	add    $0x18,%eax
80104f31:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f35:	89 04 24             	mov    %eax,(%esp)
80104f38:	e8 03 fa ff ff       	call   80104940 <strcmp1>
80104f3d:	85 c0                	test   %eax,%eax
80104f3f:	75 0e                	jne    80104f4f <cstop_container_helper+0x3f>
      kill(p->pid);
80104f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f44:	8b 40 10             	mov    0x10(%eax),%eax
80104f47:	89 04 24             	mov    %eax,(%esp)
80104f4a:	e8 07 fe ff ff       	call   80104d56 <kill>

void cstop_container_helper(struct container* cont){

  struct proc *p;
  // cprintf("In procdump\n.");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f4f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104f56:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104f5d:	72 c0                	jb     80104f1f <cstop_container_helper+0xf>

    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }
}
80104f5f:	c9                   	leave  
80104f60:	c3                   	ret    

80104f61 <cstop_helper>:

void cstop_helper(char* name){
80104f61:	55                   	push   %ebp
80104f62:	89 e5                	mov    %esp,%ebp
80104f64:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f67:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104f6e:	eb 69                	jmp    80104fd9 <cstop_helper+0x78>

    if(p->cont == NULL){
80104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f73:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f79:	85 c0                	test   %eax,%eax
80104f7b:	75 02                	jne    80104f7f <cstop_helper+0x1e>
      continue;
80104f7d:	eb 53                	jmp    80104fd2 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
80104f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f82:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f88:	8d 50 18             	lea    0x18(%eax),%edx
80104f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f92:	89 14 24             	mov    %edx,(%esp)
80104f95:	e8 a6 f9 ff ff       	call   80104940 <strcmp1>
80104f9a:	85 c0                	test   %eax,%eax
80104f9c:	75 34                	jne    80104fd2 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80104f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa1:	8b 40 10             	mov    0x10(%eax),%eax
80104fa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fa7:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
80104fad:	83 c2 18             	add    $0x18,%edx
80104fb0:	89 44 24 08          	mov    %eax,0x8(%esp)
80104fb4:	89 54 24 04          	mov    %edx,0x4(%esp)
80104fb8:	c7 04 24 70 98 10 80 	movl   $0x80109870,(%esp)
80104fbf:	e8 fd b3 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
80104fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc7:	8b 40 10             	mov    0x10(%eax),%eax
80104fca:	89 04 24             	mov    %eax,(%esp)
80104fcd:	e8 84 fd ff ff       	call   80104d56 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fd2:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104fd9:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104fe0:	72 8e                	jb     80104f70 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
80104fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe5:	89 04 24             	mov    %eax,(%esp)
80104fe8:	e8 1e 3e 00 00       	call   80108e0b <find>
80104fed:	89 04 24             	mov    %eax,(%esp)
80104ff0:	e8 f6 42 00 00       	call   801092eb <container_reset>
}
80104ff5:	c9                   	leave  
80104ff6:	c3                   	ret    

80104ff7 <c_procdump>:
//   return os;
// }

void
c_procdump(char* name)
{
80104ff7:	55                   	push   %ebp
80104ff8:	89 e5                	mov    %esp,%ebp
80104ffa:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ffd:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80105004:	e9 0f 01 00 00       	jmp    80105118 <c_procdump+0x121>

    // if(p->cont == NULL){
    //   cprintf("p_cont is null in %s.\n", name);
    // }
    if(p->state == UNUSED || p->cont == NULL)
80105009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500c:	8b 40 0c             	mov    0xc(%eax),%eax
8010500f:	85 c0                	test   %eax,%eax
80105011:	74 0d                	je     80105020 <c_procdump+0x29>
80105013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105016:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010501c:	85 c0                	test   %eax,%eax
8010501e:	75 05                	jne    80105025 <c_procdump+0x2e>
      continue;
80105020:	e9 ec 00 00 00       	jmp    80105111 <c_procdump+0x11a>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105028:	8b 40 0c             	mov    0xc(%eax),%eax
8010502b:	83 f8 05             	cmp    $0x5,%eax
8010502e:	77 23                	ja     80105053 <c_procdump+0x5c>
80105030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105033:	8b 40 0c             	mov    0xc(%eax),%eax
80105036:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010503d:	85 c0                	test   %eax,%eax
8010503f:	74 12                	je     80105053 <c_procdump+0x5c>
      state = states[p->state];
80105041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105044:	8b 40 0c             	mov    0xc(%eax),%eax
80105047:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010504e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105051:	eb 07                	jmp    8010505a <c_procdump+0x63>
    else
      state = "???";
80105053:	c7 45 ec 4a 98 10 80 	movl   $0x8010984a,-0x14(%ebp)

    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
8010505a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105063:	8d 50 18             	lea    0x18(%eax),%edx
80105066:	8b 45 08             	mov    0x8(%ebp),%eax
80105069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010506d:	89 14 24             	mov    %edx,(%esp)
80105070:	e8 cb f8 ff ff       	call   80104940 <strcmp1>
80105075:	85 c0                	test   %eax,%eax
80105077:	0f 85 94 00 00 00    	jne    80105111 <c_procdump+0x11a>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
8010507d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105080:	8d 50 6c             	lea    0x6c(%eax),%edx
80105083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105086:	8b 40 10             	mov    0x10(%eax),%eax
80105089:	89 54 24 10          	mov    %edx,0x10(%esp)
8010508d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105090:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105094:	8b 55 08             	mov    0x8(%ebp),%edx
80105097:	89 54 24 08          	mov    %edx,0x8(%esp)
8010509b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010509f:	c7 04 24 5c 98 10 80 	movl   $0x8010985c,(%esp)
801050a6:	e8 16 b3 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
801050ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ae:	8b 40 0c             	mov    0xc(%eax),%eax
801050b1:	83 f8 02             	cmp    $0x2,%eax
801050b4:	75 4f                	jne    80105105 <c_procdump+0x10e>
        getcallerpcs((uint*)p->context->ebp+2, pc);
801050b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b9:	8b 40 1c             	mov    0x1c(%eax),%eax
801050bc:	8b 40 0c             	mov    0xc(%eax),%eax
801050bf:	83 c0 08             	add    $0x8,%eax
801050c2:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801050c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801050c9:	89 04 24             	mov    %eax,(%esp)
801050cc:	e8 89 02 00 00       	call   8010535a <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
801050d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050d8:	eb 1a                	jmp    801050f4 <c_procdump+0xfd>
          cprintf(" %p", pc[i]);
801050da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050dd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801050e5:	c7 04 24 68 98 10 80 	movl   $0x80109868,(%esp)
801050ec:	e8 d0 b2 ff ff       	call   801003c1 <cprintf>
    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
801050f1:	ff 45 f4             	incl   -0xc(%ebp)
801050f4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050f8:	7f 0b                	jg     80105105 <c_procdump+0x10e>
801050fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105101:	85 c0                	test   %eax,%eax
80105103:	75 d5                	jne    801050da <c_procdump+0xe3>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
80105105:	c7 04 24 6c 98 10 80 	movl   $0x8010986c,(%esp)
8010510c:	e8 b0 b2 ff ff       	call   801003c1 <cprintf>
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105111:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105118:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
8010511f:	0f 82 e4 fe ff ff    	jb     80105009 <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
80105125:	c9                   	leave  
80105126:	c3                   	ret    

80105127 <cont_disk>:

void
cont_disk(void){
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
  
}
8010512a:	5d                   	pop    %ebp
8010512b:	c3                   	ret    

8010512c <initp>:


struct proc* initp(void){
8010512c:	55                   	push   %ebp
8010512d:	89 e5                	mov    %esp,%ebp
  return initproc;
8010512f:	a1 00 c9 10 80       	mov    0x8010c900,%eax
}
80105134:	5d                   	pop    %ebp
80105135:	c3                   	ret    

80105136 <c_proc>:

struct proc* c_proc(void){
80105136:	55                   	push   %ebp
80105137:	89 e5                	mov    %esp,%ebp
80105139:	83 ec 08             	sub    $0x8,%esp
  return myproc();
8010513c:	e8 62 f2 ff ff       	call   801043a3 <myproc>
}
80105141:	c9                   	leave  
80105142:	c3                   	ret    
	...

80105144 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105144:	55                   	push   %ebp
80105145:	89 e5                	mov    %esp,%ebp
80105147:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010514a:	8b 45 08             	mov    0x8(%ebp),%eax
8010514d:	83 c0 04             	add    $0x4,%eax
80105150:	c7 44 24 04 ba 98 10 	movl   $0x801098ba,0x4(%esp)
80105157:	80 
80105158:	89 04 24             	mov    %eax,(%esp)
8010515b:	e8 22 01 00 00       	call   80105282 <initlock>
  lk->name = name;
80105160:	8b 45 08             	mov    0x8(%ebp),%eax
80105163:	8b 55 0c             	mov    0xc(%ebp),%edx
80105166:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105172:	8b 45 08             	mov    0x8(%ebp),%eax
80105175:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010517c:	c9                   	leave  
8010517d:	c3                   	ret    

8010517e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010517e:	55                   	push   %ebp
8010517f:	89 e5                	mov    %esp,%ebp
80105181:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105184:	8b 45 08             	mov    0x8(%ebp),%eax
80105187:	83 c0 04             	add    $0x4,%eax
8010518a:	89 04 24             	mov    %eax,(%esp)
8010518d:	e8 11 01 00 00       	call   801052a3 <acquire>
  while (lk->locked) {
80105192:	eb 15                	jmp    801051a9 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105194:	8b 45 08             	mov    0x8(%ebp),%eax
80105197:	83 c0 04             	add    $0x4,%eax
8010519a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010519e:	8b 45 08             	mov    0x8(%ebp),%eax
801051a1:	89 04 24             	mov    %eax,(%esp)
801051a4:	e8 ab fa ff ff       	call   80104c54 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
801051a9:	8b 45 08             	mov    0x8(%ebp),%eax
801051ac:	8b 00                	mov    (%eax),%eax
801051ae:	85 c0                	test   %eax,%eax
801051b0:	75 e2                	jne    80105194 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
801051b2:	8b 45 08             	mov    0x8(%ebp),%eax
801051b5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051bb:	e8 e3 f1 ff ff       	call   801043a3 <myproc>
801051c0:	8b 50 10             	mov    0x10(%eax),%edx
801051c3:	8b 45 08             	mov    0x8(%ebp),%eax
801051c6:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051c9:	8b 45 08             	mov    0x8(%ebp),%eax
801051cc:	83 c0 04             	add    $0x4,%eax
801051cf:	89 04 24             	mov    %eax,(%esp)
801051d2:	e8 36 01 00 00       	call   8010530d <release>
}
801051d7:	c9                   	leave  
801051d8:	c3                   	ret    

801051d9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051d9:	55                   	push   %ebp
801051da:	89 e5                	mov    %esp,%ebp
801051dc:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801051df:	8b 45 08             	mov    0x8(%ebp),%eax
801051e2:	83 c0 04             	add    $0x4,%eax
801051e5:	89 04 24             	mov    %eax,(%esp)
801051e8:	e8 b6 00 00 00       	call   801052a3 <acquire>
  lk->locked = 0;
801051ed:	8b 45 08             	mov    0x8(%ebp),%eax
801051f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051f6:	8b 45 08             	mov    0x8(%ebp),%eax
801051f9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105200:	8b 45 08             	mov    0x8(%ebp),%eax
80105203:	89 04 24             	mov    %eax,(%esp)
80105206:	e8 20 fb ff ff       	call   80104d2b <wakeup>
  release(&lk->lk);
8010520b:	8b 45 08             	mov    0x8(%ebp),%eax
8010520e:	83 c0 04             	add    $0x4,%eax
80105211:	89 04 24             	mov    %eax,(%esp)
80105214:	e8 f4 00 00 00       	call   8010530d <release>
}
80105219:	c9                   	leave  
8010521a:	c3                   	ret    

8010521b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010521b:	55                   	push   %ebp
8010521c:	89 e5                	mov    %esp,%ebp
8010521e:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105221:	8b 45 08             	mov    0x8(%ebp),%eax
80105224:	83 c0 04             	add    $0x4,%eax
80105227:	89 04 24             	mov    %eax,(%esp)
8010522a:	e8 74 00 00 00       	call   801052a3 <acquire>
  r = lk->locked;
8010522f:	8b 45 08             	mov    0x8(%ebp),%eax
80105232:	8b 00                	mov    (%eax),%eax
80105234:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105237:	8b 45 08             	mov    0x8(%ebp),%eax
8010523a:	83 c0 04             	add    $0x4,%eax
8010523d:	89 04 24             	mov    %eax,(%esp)
80105240:	e8 c8 00 00 00       	call   8010530d <release>
  return r;
80105245:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105248:	c9                   	leave  
80105249:	c3                   	ret    
	...

8010524c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010524c:	55                   	push   %ebp
8010524d:	89 e5                	mov    %esp,%ebp
8010524f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105252:	9c                   	pushf  
80105253:	58                   	pop    %eax
80105254:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105257:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010525a:	c9                   	leave  
8010525b:	c3                   	ret    

8010525c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010525f:	fa                   	cli    
}
80105260:	5d                   	pop    %ebp
80105261:	c3                   	ret    

80105262 <sti>:

static inline void
sti(void)
{
80105262:	55                   	push   %ebp
80105263:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105265:	fb                   	sti    
}
80105266:	5d                   	pop    %ebp
80105267:	c3                   	ret    

80105268 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105268:	55                   	push   %ebp
80105269:	89 e5                	mov    %esp,%ebp
8010526b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010526e:	8b 55 08             	mov    0x8(%ebp),%edx
80105271:	8b 45 0c             	mov    0xc(%ebp),%eax
80105274:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105277:	f0 87 02             	lock xchg %eax,(%edx)
8010527a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010527d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105280:	c9                   	leave  
80105281:	c3                   	ret    

80105282 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105282:	55                   	push   %ebp
80105283:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105285:	8b 45 08             	mov    0x8(%ebp),%eax
80105288:	8b 55 0c             	mov    0xc(%ebp),%edx
8010528b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010528e:	8b 45 08             	mov    0x8(%ebp),%eax
80105291:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105297:	8b 45 08             	mov    0x8(%ebp),%eax
8010529a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052a1:	5d                   	pop    %ebp
801052a2:	c3                   	ret    

801052a3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052a3:	55                   	push   %ebp
801052a4:	89 e5                	mov    %esp,%ebp
801052a6:	53                   	push   %ebx
801052a7:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052aa:	e8 53 01 00 00       	call   80105402 <pushcli>
  if(holding(lk))
801052af:	8b 45 08             	mov    0x8(%ebp),%eax
801052b2:	89 04 24             	mov    %eax,(%esp)
801052b5:	e8 17 01 00 00       	call   801053d1 <holding>
801052ba:	85 c0                	test   %eax,%eax
801052bc:	74 0c                	je     801052ca <acquire+0x27>
    panic("acquire");
801052be:	c7 04 24 c5 98 10 80 	movl   $0x801098c5,(%esp)
801052c5:	e8 8a b2 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052ca:	90                   	nop
801052cb:	8b 45 08             	mov    0x8(%ebp),%eax
801052ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801052d5:	00 
801052d6:	89 04 24             	mov    %eax,(%esp)
801052d9:	e8 8a ff ff ff       	call   80105268 <xchg>
801052de:	85 c0                	test   %eax,%eax
801052e0:	75 e9                	jne    801052cb <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801052e2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801052e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
801052ea:	e8 30 f0 ff ff       	call   8010431f <mycpu>
801052ef:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801052f2:	8b 45 08             	mov    0x8(%ebp),%eax
801052f5:	83 c0 0c             	add    $0xc,%eax
801052f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801052fc:	8d 45 08             	lea    0x8(%ebp),%eax
801052ff:	89 04 24             	mov    %eax,(%esp)
80105302:	e8 53 00 00 00       	call   8010535a <getcallerpcs>
}
80105307:	83 c4 14             	add    $0x14,%esp
8010530a:	5b                   	pop    %ebx
8010530b:	5d                   	pop    %ebp
8010530c:	c3                   	ret    

8010530d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
80105310:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105313:	8b 45 08             	mov    0x8(%ebp),%eax
80105316:	89 04 24             	mov    %eax,(%esp)
80105319:	e8 b3 00 00 00       	call   801053d1 <holding>
8010531e:	85 c0                	test   %eax,%eax
80105320:	75 0c                	jne    8010532e <release+0x21>
    panic("release");
80105322:	c7 04 24 cd 98 10 80 	movl   $0x801098cd,(%esp)
80105329:	e8 26 b2 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010532e:	8b 45 08             	mov    0x8(%ebp),%eax
80105331:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105338:	8b 45 08             	mov    0x8(%ebp),%eax
8010533b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105342:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105347:	8b 45 08             	mov    0x8(%ebp),%eax
8010534a:	8b 55 08             	mov    0x8(%ebp),%edx
8010534d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105353:	e8 f4 00 00 00       	call   8010544c <popcli>
}
80105358:	c9                   	leave  
80105359:	c3                   	ret    

8010535a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010535a:	55                   	push   %ebp
8010535b:	89 e5                	mov    %esp,%ebp
8010535d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105360:	8b 45 08             	mov    0x8(%ebp),%eax
80105363:	83 e8 08             	sub    $0x8,%eax
80105366:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105369:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105370:	eb 37                	jmp    801053a9 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105372:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105376:	74 37                	je     801053af <getcallerpcs+0x55>
80105378:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010537f:	76 2e                	jbe    801053af <getcallerpcs+0x55>
80105381:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105385:	74 28                	je     801053af <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105387:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010538a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105391:	8b 45 0c             	mov    0xc(%ebp),%eax
80105394:	01 c2                	add    %eax,%edx
80105396:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105399:	8b 40 04             	mov    0x4(%eax),%eax
8010539c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010539e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053a1:	8b 00                	mov    (%eax),%eax
801053a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801053a6:	ff 45 f8             	incl   -0x8(%ebp)
801053a9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053ad:	7e c3                	jle    80105372 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053af:	eb 18                	jmp    801053c9 <getcallerpcs+0x6f>
    pcs[i] = 0;
801053b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801053be:	01 d0                	add    %edx,%eax
801053c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053c6:	ff 45 f8             	incl   -0x8(%ebp)
801053c9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053cd:	7e e2                	jle    801053b1 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801053cf:	c9                   	leave  
801053d0:	c3                   	ret    

801053d1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053d1:	55                   	push   %ebp
801053d2:	89 e5                	mov    %esp,%ebp
801053d4:	53                   	push   %ebx
801053d5:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801053d8:	8b 45 08             	mov    0x8(%ebp),%eax
801053db:	8b 00                	mov    (%eax),%eax
801053dd:	85 c0                	test   %eax,%eax
801053df:	74 16                	je     801053f7 <holding+0x26>
801053e1:	8b 45 08             	mov    0x8(%ebp),%eax
801053e4:	8b 58 08             	mov    0x8(%eax),%ebx
801053e7:	e8 33 ef ff ff       	call   8010431f <mycpu>
801053ec:	39 c3                	cmp    %eax,%ebx
801053ee:	75 07                	jne    801053f7 <holding+0x26>
801053f0:	b8 01 00 00 00       	mov    $0x1,%eax
801053f5:	eb 05                	jmp    801053fc <holding+0x2b>
801053f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053fc:	83 c4 04             	add    $0x4,%esp
801053ff:	5b                   	pop    %ebx
80105400:	5d                   	pop    %ebp
80105401:	c3                   	ret    

80105402 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105402:	55                   	push   %ebp
80105403:	89 e5                	mov    %esp,%ebp
80105405:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105408:	e8 3f fe ff ff       	call   8010524c <readeflags>
8010540d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105410:	e8 47 fe ff ff       	call   8010525c <cli>
  if(mycpu()->ncli == 0)
80105415:	e8 05 ef ff ff       	call   8010431f <mycpu>
8010541a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105420:	85 c0                	test   %eax,%eax
80105422:	75 14                	jne    80105438 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105424:	e8 f6 ee ff ff       	call   8010431f <mycpu>
80105429:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010542c:	81 e2 00 02 00 00    	and    $0x200,%edx
80105432:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105438:	e8 e2 ee ff ff       	call   8010431f <mycpu>
8010543d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105443:	42                   	inc    %edx
80105444:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010544a:	c9                   	leave  
8010544b:	c3                   	ret    

8010544c <popcli>:

void
popcli(void)
{
8010544c:	55                   	push   %ebp
8010544d:	89 e5                	mov    %esp,%ebp
8010544f:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105452:	e8 f5 fd ff ff       	call   8010524c <readeflags>
80105457:	25 00 02 00 00       	and    $0x200,%eax
8010545c:	85 c0                	test   %eax,%eax
8010545e:	74 0c                	je     8010546c <popcli+0x20>
    panic("popcli - interruptible");
80105460:	c7 04 24 d5 98 10 80 	movl   $0x801098d5,(%esp)
80105467:	e8 e8 b0 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
8010546c:	e8 ae ee ff ff       	call   8010431f <mycpu>
80105471:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105477:	4a                   	dec    %edx
80105478:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010547e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105484:	85 c0                	test   %eax,%eax
80105486:	79 0c                	jns    80105494 <popcli+0x48>
    panic("popcli");
80105488:	c7 04 24 ec 98 10 80 	movl   $0x801098ec,(%esp)
8010548f:	e8 c0 b0 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105494:	e8 86 ee ff ff       	call   8010431f <mycpu>
80105499:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010549f:	85 c0                	test   %eax,%eax
801054a1:	75 14                	jne    801054b7 <popcli+0x6b>
801054a3:	e8 77 ee ff ff       	call   8010431f <mycpu>
801054a8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801054ae:	85 c0                	test   %eax,%eax
801054b0:	74 05                	je     801054b7 <popcli+0x6b>
    sti();
801054b2:	e8 ab fd ff ff       	call   80105262 <sti>
}
801054b7:	c9                   	leave  
801054b8:	c3                   	ret    
801054b9:	00 00                	add    %al,(%eax)
	...

801054bc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801054bc:	55                   	push   %ebp
801054bd:	89 e5                	mov    %esp,%ebp
801054bf:	57                   	push   %edi
801054c0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054c4:	8b 55 10             	mov    0x10(%ebp),%edx
801054c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ca:	89 cb                	mov    %ecx,%ebx
801054cc:	89 df                	mov    %ebx,%edi
801054ce:	89 d1                	mov    %edx,%ecx
801054d0:	fc                   	cld    
801054d1:	f3 aa                	rep stos %al,%es:(%edi)
801054d3:	89 ca                	mov    %ecx,%edx
801054d5:	89 fb                	mov    %edi,%ebx
801054d7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054da:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801054dd:	5b                   	pop    %ebx
801054de:	5f                   	pop    %edi
801054df:	5d                   	pop    %ebp
801054e0:	c3                   	ret    

801054e1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
801054e4:	57                   	push   %edi
801054e5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054e9:	8b 55 10             	mov    0x10(%ebp),%edx
801054ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ef:	89 cb                	mov    %ecx,%ebx
801054f1:	89 df                	mov    %ebx,%edi
801054f3:	89 d1                	mov    %edx,%ecx
801054f5:	fc                   	cld    
801054f6:	f3 ab                	rep stos %eax,%es:(%edi)
801054f8:	89 ca                	mov    %ecx,%edx
801054fa:	89 fb                	mov    %edi,%ebx
801054fc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054ff:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105502:	5b                   	pop    %ebx
80105503:	5f                   	pop    %edi
80105504:	5d                   	pop    %ebp
80105505:	c3                   	ret    

80105506 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105506:	55                   	push   %ebp
80105507:	89 e5                	mov    %esp,%ebp
80105509:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010550c:	8b 45 08             	mov    0x8(%ebp),%eax
8010550f:	83 e0 03             	and    $0x3,%eax
80105512:	85 c0                	test   %eax,%eax
80105514:	75 49                	jne    8010555f <memset+0x59>
80105516:	8b 45 10             	mov    0x10(%ebp),%eax
80105519:	83 e0 03             	and    $0x3,%eax
8010551c:	85 c0                	test   %eax,%eax
8010551e:	75 3f                	jne    8010555f <memset+0x59>
    c &= 0xFF;
80105520:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105527:	8b 45 10             	mov    0x10(%ebp),%eax
8010552a:	c1 e8 02             	shr    $0x2,%eax
8010552d:	89 c2                	mov    %eax,%edx
8010552f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105532:	c1 e0 18             	shl    $0x18,%eax
80105535:	89 c1                	mov    %eax,%ecx
80105537:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553a:	c1 e0 10             	shl    $0x10,%eax
8010553d:	09 c1                	or     %eax,%ecx
8010553f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105542:	c1 e0 08             	shl    $0x8,%eax
80105545:	09 c8                	or     %ecx,%eax
80105547:	0b 45 0c             	or     0xc(%ebp),%eax
8010554a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010554e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105552:	8b 45 08             	mov    0x8(%ebp),%eax
80105555:	89 04 24             	mov    %eax,(%esp)
80105558:	e8 84 ff ff ff       	call   801054e1 <stosl>
8010555d:	eb 19                	jmp    80105578 <memset+0x72>
  } else
    stosb(dst, c, n);
8010555f:	8b 45 10             	mov    0x10(%ebp),%eax
80105562:	89 44 24 08          	mov    %eax,0x8(%esp)
80105566:	8b 45 0c             	mov    0xc(%ebp),%eax
80105569:	89 44 24 04          	mov    %eax,0x4(%esp)
8010556d:	8b 45 08             	mov    0x8(%ebp),%eax
80105570:	89 04 24             	mov    %eax,(%esp)
80105573:	e8 44 ff ff ff       	call   801054bc <stosb>
  return dst;
80105578:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010557b:	c9                   	leave  
8010557c:	c3                   	ret    

8010557d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010557d:	55                   	push   %ebp
8010557e:	89 e5                	mov    %esp,%ebp
80105580:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105583:	8b 45 08             	mov    0x8(%ebp),%eax
80105586:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105589:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010558f:	eb 2a                	jmp    801055bb <memcmp+0x3e>
    if(*s1 != *s2)
80105591:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105594:	8a 10                	mov    (%eax),%dl
80105596:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105599:	8a 00                	mov    (%eax),%al
8010559b:	38 c2                	cmp    %al,%dl
8010559d:	74 16                	je     801055b5 <memcmp+0x38>
      return *s1 - *s2;
8010559f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055a2:	8a 00                	mov    (%eax),%al
801055a4:	0f b6 d0             	movzbl %al,%edx
801055a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055aa:	8a 00                	mov    (%eax),%al
801055ac:	0f b6 c0             	movzbl %al,%eax
801055af:	29 c2                	sub    %eax,%edx
801055b1:	89 d0                	mov    %edx,%eax
801055b3:	eb 18                	jmp    801055cd <memcmp+0x50>
    s1++, s2++;
801055b5:	ff 45 fc             	incl   -0x4(%ebp)
801055b8:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801055bb:	8b 45 10             	mov    0x10(%ebp),%eax
801055be:	8d 50 ff             	lea    -0x1(%eax),%edx
801055c1:	89 55 10             	mov    %edx,0x10(%ebp)
801055c4:	85 c0                	test   %eax,%eax
801055c6:	75 c9                	jne    80105591 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801055c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055cd:	c9                   	leave  
801055ce:	c3                   	ret    

801055cf <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055cf:	55                   	push   %ebp
801055d0:	89 e5                	mov    %esp,%ebp
801055d2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801055db:	8b 45 08             	mov    0x8(%ebp),%eax
801055de:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801055e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055e7:	73 3a                	jae    80105623 <memmove+0x54>
801055e9:	8b 45 10             	mov    0x10(%ebp),%eax
801055ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055ef:	01 d0                	add    %edx,%eax
801055f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055f4:	76 2d                	jbe    80105623 <memmove+0x54>
    s += n;
801055f6:	8b 45 10             	mov    0x10(%ebp),%eax
801055f9:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801055fc:	8b 45 10             	mov    0x10(%ebp),%eax
801055ff:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105602:	eb 10                	jmp    80105614 <memmove+0x45>
      *--d = *--s;
80105604:	ff 4d f8             	decl   -0x8(%ebp)
80105607:	ff 4d fc             	decl   -0x4(%ebp)
8010560a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560d:	8a 10                	mov    (%eax),%dl
8010560f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105612:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105614:	8b 45 10             	mov    0x10(%ebp),%eax
80105617:	8d 50 ff             	lea    -0x1(%eax),%edx
8010561a:	89 55 10             	mov    %edx,0x10(%ebp)
8010561d:	85 c0                	test   %eax,%eax
8010561f:	75 e3                	jne    80105604 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105621:	eb 25                	jmp    80105648 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105623:	eb 16                	jmp    8010563b <memmove+0x6c>
      *d++ = *s++;
80105625:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105628:	8d 50 01             	lea    0x1(%eax),%edx
8010562b:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010562e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105631:	8d 4a 01             	lea    0x1(%edx),%ecx
80105634:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105637:	8a 12                	mov    (%edx),%dl
80105639:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010563b:	8b 45 10             	mov    0x10(%ebp),%eax
8010563e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105641:	89 55 10             	mov    %edx,0x10(%ebp)
80105644:	85 c0                	test   %eax,%eax
80105646:	75 dd                	jne    80105625 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105648:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010564b:	c9                   	leave  
8010564c:	c3                   	ret    

8010564d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010564d:	55                   	push   %ebp
8010564e:	89 e5                	mov    %esp,%ebp
80105650:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105653:	8b 45 10             	mov    0x10(%ebp),%eax
80105656:	89 44 24 08          	mov    %eax,0x8(%esp)
8010565a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105661:	8b 45 08             	mov    0x8(%ebp),%eax
80105664:	89 04 24             	mov    %eax,(%esp)
80105667:	e8 63 ff ff ff       	call   801055cf <memmove>
}
8010566c:	c9                   	leave  
8010566d:	c3                   	ret    

8010566e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010566e:	55                   	push   %ebp
8010566f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105671:	eb 09                	jmp    8010567c <strncmp+0xe>
    n--, p++, q++;
80105673:	ff 4d 10             	decl   0x10(%ebp)
80105676:	ff 45 08             	incl   0x8(%ebp)
80105679:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010567c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105680:	74 17                	je     80105699 <strncmp+0x2b>
80105682:	8b 45 08             	mov    0x8(%ebp),%eax
80105685:	8a 00                	mov    (%eax),%al
80105687:	84 c0                	test   %al,%al
80105689:	74 0e                	je     80105699 <strncmp+0x2b>
8010568b:	8b 45 08             	mov    0x8(%ebp),%eax
8010568e:	8a 10                	mov    (%eax),%dl
80105690:	8b 45 0c             	mov    0xc(%ebp),%eax
80105693:	8a 00                	mov    (%eax),%al
80105695:	38 c2                	cmp    %al,%dl
80105697:	74 da                	je     80105673 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105699:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010569d:	75 07                	jne    801056a6 <strncmp+0x38>
    return 0;
8010569f:	b8 00 00 00 00       	mov    $0x0,%eax
801056a4:	eb 14                	jmp    801056ba <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801056a6:	8b 45 08             	mov    0x8(%ebp),%eax
801056a9:	8a 00                	mov    (%eax),%al
801056ab:	0f b6 d0             	movzbl %al,%edx
801056ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b1:	8a 00                	mov    (%eax),%al
801056b3:	0f b6 c0             	movzbl %al,%eax
801056b6:	29 c2                	sub    %eax,%edx
801056b8:	89 d0                	mov    %edx,%eax
}
801056ba:	5d                   	pop    %ebp
801056bb:	c3                   	ret    

801056bc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056bc:	55                   	push   %ebp
801056bd:	89 e5                	mov    %esp,%ebp
801056bf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056c2:	8b 45 08             	mov    0x8(%ebp),%eax
801056c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056c8:	90                   	nop
801056c9:	8b 45 10             	mov    0x10(%ebp),%eax
801056cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801056cf:	89 55 10             	mov    %edx,0x10(%ebp)
801056d2:	85 c0                	test   %eax,%eax
801056d4:	7e 1c                	jle    801056f2 <strncpy+0x36>
801056d6:	8b 45 08             	mov    0x8(%ebp),%eax
801056d9:	8d 50 01             	lea    0x1(%eax),%edx
801056dc:	89 55 08             	mov    %edx,0x8(%ebp)
801056df:	8b 55 0c             	mov    0xc(%ebp),%edx
801056e2:	8d 4a 01             	lea    0x1(%edx),%ecx
801056e5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801056e8:	8a 12                	mov    (%edx),%dl
801056ea:	88 10                	mov    %dl,(%eax)
801056ec:	8a 00                	mov    (%eax),%al
801056ee:	84 c0                	test   %al,%al
801056f0:	75 d7                	jne    801056c9 <strncpy+0xd>
    ;
  while(n-- > 0)
801056f2:	eb 0c                	jmp    80105700 <strncpy+0x44>
    *s++ = 0;
801056f4:	8b 45 08             	mov    0x8(%ebp),%eax
801056f7:	8d 50 01             	lea    0x1(%eax),%edx
801056fa:	89 55 08             	mov    %edx,0x8(%ebp)
801056fd:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105700:	8b 45 10             	mov    0x10(%ebp),%eax
80105703:	8d 50 ff             	lea    -0x1(%eax),%edx
80105706:	89 55 10             	mov    %edx,0x10(%ebp)
80105709:	85 c0                	test   %eax,%eax
8010570b:	7f e7                	jg     801056f4 <strncpy+0x38>
    *s++ = 0;
  return os;
8010570d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105710:	c9                   	leave  
80105711:	c3                   	ret    

80105712 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105712:	55                   	push   %ebp
80105713:	89 e5                	mov    %esp,%ebp
80105715:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105718:	8b 45 08             	mov    0x8(%ebp),%eax
8010571b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010571e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105722:	7f 05                	jg     80105729 <safestrcpy+0x17>
    return os;
80105724:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105727:	eb 2e                	jmp    80105757 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105729:	ff 4d 10             	decl   0x10(%ebp)
8010572c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105730:	7e 1c                	jle    8010574e <safestrcpy+0x3c>
80105732:	8b 45 08             	mov    0x8(%ebp),%eax
80105735:	8d 50 01             	lea    0x1(%eax),%edx
80105738:	89 55 08             	mov    %edx,0x8(%ebp)
8010573b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010573e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105741:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105744:	8a 12                	mov    (%edx),%dl
80105746:	88 10                	mov    %dl,(%eax)
80105748:	8a 00                	mov    (%eax),%al
8010574a:	84 c0                	test   %al,%al
8010574c:	75 db                	jne    80105729 <safestrcpy+0x17>
    ;
  *s = 0;
8010574e:	8b 45 08             	mov    0x8(%ebp),%eax
80105751:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105754:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105757:	c9                   	leave  
80105758:	c3                   	ret    

80105759 <strlen>:

int
strlen(const char *s)
{
80105759:	55                   	push   %ebp
8010575a:	89 e5                	mov    %esp,%ebp
8010575c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010575f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105766:	eb 03                	jmp    8010576b <strlen+0x12>
80105768:	ff 45 fc             	incl   -0x4(%ebp)
8010576b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010576e:	8b 45 08             	mov    0x8(%ebp),%eax
80105771:	01 d0                	add    %edx,%eax
80105773:	8a 00                	mov    (%eax),%al
80105775:	84 c0                	test   %al,%al
80105777:	75 ef                	jne    80105768 <strlen+0xf>
    ;
  return n;
80105779:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010577c:	c9                   	leave  
8010577d:	c3                   	ret    
	...

80105780 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105780:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105784:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105788:	55                   	push   %ebp
  pushl %ebx
80105789:	53                   	push   %ebx
  pushl %esi
8010578a:	56                   	push   %esi
  pushl %edi
8010578b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010578c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010578e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105790:	5f                   	pop    %edi
  popl %esi
80105791:	5e                   	pop    %esi
  popl %ebx
80105792:	5b                   	pop    %ebx
  popl %ebp
80105793:	5d                   	pop    %ebp
  ret
80105794:	c3                   	ret    
80105795:	00 00                	add    %al,(%eax)
	...

80105798 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105798:	55                   	push   %ebp
80105799:	89 e5                	mov    %esp,%ebp
8010579b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010579e:	e8 00 ec ff ff       	call   801043a3 <myproc>
801057a3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801057a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a9:	8b 00                	mov    (%eax),%eax
801057ab:	3b 45 08             	cmp    0x8(%ebp),%eax
801057ae:	76 0f                	jbe    801057bf <fetchint+0x27>
801057b0:	8b 45 08             	mov    0x8(%ebp),%eax
801057b3:	8d 50 04             	lea    0x4(%eax),%edx
801057b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b9:	8b 00                	mov    (%eax),%eax
801057bb:	39 c2                	cmp    %eax,%edx
801057bd:	76 07                	jbe    801057c6 <fetchint+0x2e>
    return -1;
801057bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c4:	eb 0f                	jmp    801057d5 <fetchint+0x3d>
  *ip = *(int*)(addr);
801057c6:	8b 45 08             	mov    0x8(%ebp),%eax
801057c9:	8b 10                	mov    (%eax),%edx
801057cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ce:	89 10                	mov    %edx,(%eax)
  return 0;
801057d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057d5:	c9                   	leave  
801057d6:	c3                   	ret    

801057d7 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801057d7:	55                   	push   %ebp
801057d8:	89 e5                	mov    %esp,%ebp
801057da:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801057dd:	e8 c1 eb ff ff       	call   801043a3 <myproc>
801057e2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801057e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e8:	8b 00                	mov    (%eax),%eax
801057ea:	3b 45 08             	cmp    0x8(%ebp),%eax
801057ed:	77 07                	ja     801057f6 <fetchstr+0x1f>
    return -1;
801057ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f4:	eb 41                	jmp    80105837 <fetchstr+0x60>
  *pp = (char*)addr;
801057f6:	8b 55 08             	mov    0x8(%ebp),%edx
801057f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057fc:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801057fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105801:	8b 00                	mov    (%eax),%eax
80105803:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105806:	8b 45 0c             	mov    0xc(%ebp),%eax
80105809:	8b 00                	mov    (%eax),%eax
8010580b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580e:	eb 1a                	jmp    8010582a <fetchstr+0x53>
    if(*s == 0)
80105810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105813:	8a 00                	mov    (%eax),%al
80105815:	84 c0                	test   %al,%al
80105817:	75 0e                	jne    80105827 <fetchstr+0x50>
      return s - *pp;
80105819:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010581c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010581f:	8b 00                	mov    (%eax),%eax
80105821:	29 c2                	sub    %eax,%edx
80105823:	89 d0                	mov    %edx,%eax
80105825:	eb 10                	jmp    80105837 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105827:	ff 45 f4             	incl   -0xc(%ebp)
8010582a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105830:	72 de                	jb     80105810 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105837:	c9                   	leave  
80105838:	c3                   	ret    

80105839 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105839:	55                   	push   %ebp
8010583a:	89 e5                	mov    %esp,%ebp
8010583c:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010583f:	e8 5f eb ff ff       	call   801043a3 <myproc>
80105844:	8b 40 18             	mov    0x18(%eax),%eax
80105847:	8b 50 44             	mov    0x44(%eax),%edx
8010584a:	8b 45 08             	mov    0x8(%ebp),%eax
8010584d:	c1 e0 02             	shl    $0x2,%eax
80105850:	01 d0                	add    %edx,%eax
80105852:	8d 50 04             	lea    0x4(%eax),%edx
80105855:	8b 45 0c             	mov    0xc(%ebp),%eax
80105858:	89 44 24 04          	mov    %eax,0x4(%esp)
8010585c:	89 14 24             	mov    %edx,(%esp)
8010585f:	e8 34 ff ff ff       	call   80105798 <fetchint>
}
80105864:	c9                   	leave  
80105865:	c3                   	ret    

80105866 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105866:	55                   	push   %ebp
80105867:	89 e5                	mov    %esp,%ebp
80105869:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
8010586c:	e8 32 eb ff ff       	call   801043a3 <myproc>
80105871:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105874:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105877:	89 44 24 04          	mov    %eax,0x4(%esp)
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	89 04 24             	mov    %eax,(%esp)
80105881:	e8 b3 ff ff ff       	call   80105839 <argint>
80105886:	85 c0                	test   %eax,%eax
80105888:	79 07                	jns    80105891 <argptr+0x2b>
    return -1;
8010588a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588f:	eb 3d                	jmp    801058ce <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105891:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105895:	78 21                	js     801058b8 <argptr+0x52>
80105897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589a:	89 c2                	mov    %eax,%edx
8010589c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589f:	8b 00                	mov    (%eax),%eax
801058a1:	39 c2                	cmp    %eax,%edx
801058a3:	73 13                	jae    801058b8 <argptr+0x52>
801058a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a8:	89 c2                	mov    %eax,%edx
801058aa:	8b 45 10             	mov    0x10(%ebp),%eax
801058ad:	01 c2                	add    %eax,%edx
801058af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b2:	8b 00                	mov    (%eax),%eax
801058b4:	39 c2                	cmp    %eax,%edx
801058b6:	76 07                	jbe    801058bf <argptr+0x59>
    return -1;
801058b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bd:	eb 0f                	jmp    801058ce <argptr+0x68>
  *pp = (char*)i;
801058bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c2:	89 c2                	mov    %eax,%edx
801058c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c7:	89 10                	mov    %edx,(%eax)
  return 0;
801058c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058ce:	c9                   	leave  
801058cf:	c3                   	ret    

801058d0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801058d0:	55                   	push   %ebp
801058d1:	89 e5                	mov    %esp,%ebp
801058d3:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801058d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801058dd:	8b 45 08             	mov    0x8(%ebp),%eax
801058e0:	89 04 24             	mov    %eax,(%esp)
801058e3:	e8 51 ff ff ff       	call   80105839 <argint>
801058e8:	85 c0                	test   %eax,%eax
801058ea:	79 07                	jns    801058f3 <argstr+0x23>
    return -1;
801058ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f1:	eb 12                	jmp    80105905 <argstr+0x35>
  return fetchstr(addr, pp);
801058f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801058f9:	89 54 24 04          	mov    %edx,0x4(%esp)
801058fd:	89 04 24             	mov    %eax,(%esp)
80105900:	e8 d2 fe ff ff       	call   801057d7 <fetchstr>
}
80105905:	c9                   	leave  
80105906:	c3                   	ret    

80105907 <syscall>:
[SYS_container_reset] sys_container_reset,
};

void
syscall(void)
{
80105907:	55                   	push   %ebp
80105908:	89 e5                	mov    %esp,%ebp
8010590a:	53                   	push   %ebx
8010590b:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
8010590e:	e8 90 ea ff ff       	call   801043a3 <myproc>
80105913:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105919:	8b 40 18             	mov    0x18(%eax),%eax
8010591c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010591f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105922:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105926:	7e 2d                	jle    80105955 <syscall+0x4e>
80105928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592b:	83 f8 2f             	cmp    $0x2f,%eax
8010592e:	77 25                	ja     80105955 <syscall+0x4e>
80105930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105933:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010593a:	85 c0                	test   %eax,%eax
8010593c:	74 17                	je     80105955 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
8010593e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105941:	8b 58 18             	mov    0x18(%eax),%ebx
80105944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105947:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010594e:	ff d0                	call   *%eax
80105950:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105953:	eb 34                	jmp    80105989 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105958:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010595b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595e:	8b 40 10             	mov    0x10(%eax),%eax
80105961:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105964:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010596c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105970:	c7 04 24 f3 98 10 80 	movl   $0x801098f3,(%esp)
80105977:	e8 45 aa ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
8010597c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597f:	8b 40 18             	mov    0x18(%eax),%eax
80105982:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105989:	83 c4 24             	add    $0x24,%esp
8010598c:	5b                   	pop    %ebx
8010598d:	5d                   	pop    %ebp
8010598e:	c3                   	ret    
	...

80105990 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105996:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105999:	89 44 24 04          	mov    %eax,0x4(%esp)
8010599d:	8b 45 08             	mov    0x8(%ebp),%eax
801059a0:	89 04 24             	mov    %eax,(%esp)
801059a3:	e8 91 fe ff ff       	call   80105839 <argint>
801059a8:	85 c0                	test   %eax,%eax
801059aa:	79 07                	jns    801059b3 <argfd+0x23>
    return -1;
801059ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b1:	eb 4f                	jmp    80105a02 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801059b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b6:	85 c0                	test   %eax,%eax
801059b8:	78 20                	js     801059da <argfd+0x4a>
801059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bd:	83 f8 0f             	cmp    $0xf,%eax
801059c0:	7f 18                	jg     801059da <argfd+0x4a>
801059c2:	e8 dc e9 ff ff       	call   801043a3 <myproc>
801059c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059ca:	83 c2 08             	add    $0x8,%edx
801059cd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059d8:	75 07                	jne    801059e1 <argfd+0x51>
    return -1;
801059da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059df:	eb 21                	jmp    80105a02 <argfd+0x72>
  if(pfd)
801059e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059e5:	74 08                	je     801059ef <argfd+0x5f>
    *pfd = fd;
801059e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ed:	89 10                	mov    %edx,(%eax)
  if(pf)
801059ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059f3:	74 08                	je     801059fd <argfd+0x6d>
    *pf = f;
801059f5:	8b 45 10             	mov    0x10(%ebp),%eax
801059f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059fb:	89 10                	mov    %edx,(%eax)
  return 0;
801059fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a02:	c9                   	leave  
80105a03:	c3                   	ret    

80105a04 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a04:	55                   	push   %ebp
80105a05:	89 e5                	mov    %esp,%ebp
80105a07:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a0a:	e8 94 e9 ff ff       	call   801043a3 <myproc>
80105a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a19:	eb 29                	jmp    80105a44 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a21:	83 c2 08             	add    $0x8,%edx
80105a24:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	75 15                	jne    80105a41 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a32:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a35:	8b 55 08             	mov    0x8(%ebp),%edx
80105a38:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3f:	eb 0e                	jmp    80105a4f <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105a41:	ff 45 f4             	incl   -0xc(%ebp)
80105a44:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a48:	7e d1                	jle    80105a1b <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a4f:	c9                   	leave  
80105a50:	c3                   	ret    

80105a51 <sys_dup>:

int
sys_dup(void)
{
80105a51:	55                   	push   %ebp
80105a52:	89 e5                	mov    %esp,%ebp
80105a54:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105a57:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a65:	00 
80105a66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a6d:	e8 1e ff ff ff       	call   80105990 <argfd>
80105a72:	85 c0                	test   %eax,%eax
80105a74:	79 07                	jns    80105a7d <sys_dup+0x2c>
    return -1;
80105a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7b:	eb 29                	jmp    80105aa6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 7c ff ff ff       	call   80105a04 <fdalloc>
80105a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a8f:	79 07                	jns    80105a98 <sys_dup+0x47>
    return -1;
80105a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a96:	eb 0e                	jmp    80105aa6 <sys_dup+0x55>
  filedup(f);
80105a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9b:	89 04 24             	mov    %eax,(%esp)
80105a9e:	e8 bf b6 ff ff       	call   80101162 <filedup>
  return fd;
80105aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105aa6:	c9                   	leave  
80105aa7:	c3                   	ret    

80105aa8 <sys_read>:

int
sys_read(void)
{
80105aa8:	55                   	push   %ebp
80105aa9:	89 e5                	mov    %esp,%ebp
80105aab:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ab5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105abc:	00 
80105abd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ac4:	e8 c7 fe ff ff       	call   80105990 <argfd>
80105ac9:	85 c0                	test   %eax,%eax
80105acb:	78 35                	js     80105b02 <sys_read+0x5a>
80105acd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105adb:	e8 59 fd ff ff       	call   80105839 <argint>
80105ae0:	85 c0                	test   %eax,%eax
80105ae2:	78 1e                	js     80105b02 <sys_read+0x5a>
80105ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aeb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aee:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105af9:	e8 68 fd ff ff       	call   80105866 <argptr>
80105afe:	85 c0                	test   %eax,%eax
80105b00:	79 07                	jns    80105b09 <sys_read+0x61>
    return -1;
80105b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b07:	eb 19                	jmp    80105b22 <sys_read+0x7a>
  return fileread(f, p, n);
80105b09:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b12:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b16:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b1a:	89 04 24             	mov    %eax,(%esp)
80105b1d:	e8 a1 b7 ff ff       	call   801012c3 <fileread>
}
80105b22:	c9                   	leave  
80105b23:	c3                   	ret    

80105b24 <sys_write>:

int
sys_write(void)
{
80105b24:	55                   	push   %ebp
80105b25:	89 e5                	mov    %esp,%ebp
80105b27:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b2d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b38:	00 
80105b39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b40:	e8 4b fe ff ff       	call   80105990 <argfd>
80105b45:	85 c0                	test   %eax,%eax
80105b47:	78 35                	js     80105b7e <sys_write+0x5a>
80105b49:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b50:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b57:	e8 dd fc ff ff       	call   80105839 <argint>
80105b5c:	85 c0                	test   %eax,%eax
80105b5e:	78 1e                	js     80105b7e <sys_write+0x5a>
80105b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b63:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b67:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b75:	e8 ec fc ff ff       	call   80105866 <argptr>
80105b7a:	85 c0                	test   %eax,%eax
80105b7c:	79 07                	jns    80105b85 <sys_write+0x61>
    return -1;
80105b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b83:	eb 19                	jmp    80105b9e <sys_write+0x7a>
  return filewrite(f, p, n);
80105b85:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b88:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b92:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b96:	89 04 24             	mov    %eax,(%esp)
80105b99:	e8 e0 b7 ff ff       	call   8010137e <filewrite>
}
80105b9e:	c9                   	leave  
80105b9f:	c3                   	ret    

80105ba0 <sys_close>:

int
sys_close(void)
{
80105ba0:	55                   	push   %ebp
80105ba1:	89 e5                	mov    %esp,%ebp
80105ba3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105ba6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bad:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bbb:	e8 d0 fd ff ff       	call   80105990 <argfd>
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	79 07                	jns    80105bcb <sys_close+0x2b>
    return -1;
80105bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc9:	eb 23                	jmp    80105bee <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105bcb:	e8 d3 e7 ff ff       	call   801043a3 <myproc>
80105bd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bd3:	83 c2 08             	add    $0x8,%edx
80105bd6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bdd:	00 
  fileclose(f);
80105bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be1:	89 04 24             	mov    %eax,(%esp)
80105be4:	e8 c1 b5 ff ff       	call   801011aa <fileclose>
  return 0;
80105be9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bee:	c9                   	leave  
80105bef:	c3                   	ret    

80105bf0 <sys_fstat>:

int
sys_fstat(void)
{
80105bf0:	55                   	push   %ebp
80105bf1:	89 e5                	mov    %esp,%ebp
80105bf3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c04:	00 
80105c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c0c:	e8 7f fd ff ff       	call   80105990 <argfd>
80105c11:	85 c0                	test   %eax,%eax
80105c13:	78 1f                	js     80105c34 <sys_fstat+0x44>
80105c15:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105c1c:	00 
80105c1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c2b:	e8 36 fc ff ff       	call   80105866 <argptr>
80105c30:	85 c0                	test   %eax,%eax
80105c32:	79 07                	jns    80105c3b <sys_fstat+0x4b>
    return -1;
80105c34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c39:	eb 12                	jmp    80105c4d <sys_fstat+0x5d>
  return filestat(f, st);
80105c3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c41:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c45:	89 04 24             	mov    %eax,(%esp)
80105c48:	e8 27 b6 ff ff       	call   80101274 <filestat>
}
80105c4d:	c9                   	leave  
80105c4e:	c3                   	ret    

80105c4f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c4f:	55                   	push   %ebp
80105c50:	89 e5                	mov    %esp,%ebp
80105c52:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c55:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c58:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c63:	e8 68 fc ff ff       	call   801058d0 <argstr>
80105c68:	85 c0                	test   %eax,%eax
80105c6a:	78 17                	js     80105c83 <sys_link+0x34>
80105c6c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c7a:	e8 51 fc ff ff       	call   801058d0 <argstr>
80105c7f:	85 c0                	test   %eax,%eax
80105c81:	79 0a                	jns    80105c8d <sys_link+0x3e>
    return -1;
80105c83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c88:	e9 3d 01 00 00       	jmp    80105dca <sys_link+0x17b>

  begin_op();
80105c8d:	e8 11 da ff ff       	call   801036a3 <begin_op>
  if((ip = namei(old)) == 0){
80105c92:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c95:	89 04 24             	mov    %eax,(%esp)
80105c98:	e8 b3 c9 ff ff       	call   80102650 <namei>
80105c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ca0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca4:	75 0f                	jne    80105cb5 <sys_link+0x66>
    end_op();
80105ca6:	e8 7a da ff ff       	call   80103725 <end_op>
    return -1;
80105cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb0:	e9 15 01 00 00       	jmp    80105dca <sys_link+0x17b>
  }

  ilock(ip);
80105cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb8:	89 04 24             	mov    %eax,(%esp)
80105cbb:	e8 02 be ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc3:	8b 40 50             	mov    0x50(%eax),%eax
80105cc6:	66 83 f8 01          	cmp    $0x1,%ax
80105cca:	75 1a                	jne    80105ce6 <sys_link+0x97>
    iunlockput(ip);
80105ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccf:	89 04 24             	mov    %eax,(%esp)
80105cd2:	e8 ea bf ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105cd7:	e8 49 da ff ff       	call   80103725 <end_op>
    return -1;
80105cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce1:	e9 e4 00 00 00       	jmp    80105dca <sys_link+0x17b>
  }

  ip->nlink++;
80105ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ced:	40                   	inc    %eax
80105cee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cf1:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf8:	89 04 24             	mov    %eax,(%esp)
80105cfb:	e8 ff bb ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d03:	89 04 24             	mov    %eax,(%esp)
80105d06:	e8 c1 be ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105d0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d0e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d11:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d15:	89 04 24             	mov    %eax,(%esp)
80105d18:	e8 55 c9 ff ff       	call   80102672 <nameiparent>
80105d1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d24:	75 02                	jne    80105d28 <sys_link+0xd9>
    goto bad;
80105d26:	eb 68                	jmp    80105d90 <sys_link+0x141>
  ilock(dp);
80105d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2b:	89 04 24             	mov    %eax,(%esp)
80105d2e:	e8 8f bd ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d36:	8b 10                	mov    (%eax),%edx
80105d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3b:	8b 00                	mov    (%eax),%eax
80105d3d:	39 c2                	cmp    %eax,%edx
80105d3f:	75 20                	jne    80105d61 <sys_link+0x112>
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	8b 40 04             	mov    0x4(%eax),%eax
80105d47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d4b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 40 c6 ff ff       	call   8010239d <dirlink>
80105d5d:	85 c0                	test   %eax,%eax
80105d5f:	79 0d                	jns    80105d6e <sys_link+0x11f>
    iunlockput(dp);
80105d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d64:	89 04 24             	mov    %eax,(%esp)
80105d67:	e8 55 bf ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105d6c:	eb 22                	jmp    80105d90 <sys_link+0x141>
  }
  iunlockput(dp);
80105d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d71:	89 04 24             	mov    %eax,(%esp)
80105d74:	e8 48 bf ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7c:	89 04 24             	mov    %eax,(%esp)
80105d7f:	e8 8c be ff ff       	call   80101c10 <iput>

  end_op();
80105d84:	e8 9c d9 ff ff       	call   80103725 <end_op>

  return 0;
80105d89:	b8 00 00 00 00       	mov    $0x0,%eax
80105d8e:	eb 3a                	jmp    80105dca <sys_link+0x17b>

bad:
  ilock(ip);
80105d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d93:	89 04 24             	mov    %eax,(%esp)
80105d96:	e8 27 bd ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9e:	66 8b 40 56          	mov    0x56(%eax),%ax
80105da2:	48                   	dec    %eax
80105da3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105da6:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dad:	89 04 24             	mov    %eax,(%esp)
80105db0:	e8 4a bb ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db8:	89 04 24             	mov    %eax,(%esp)
80105dbb:	e8 01 bf ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105dc0:	e8 60 d9 ff ff       	call   80103725 <end_op>
  return -1;
80105dc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dca:	c9                   	leave  
80105dcb:	c3                   	ret    

80105dcc <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105dcc:	55                   	push   %ebp
80105dcd:	89 e5                	mov    %esp,%ebp
80105dcf:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105dd2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105dd9:	eb 4a                	jmp    80105e25 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dde:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105de5:	00 
80105de6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80105df1:	8b 45 08             	mov    0x8(%ebp),%eax
80105df4:	89 04 24             	mov    %eax,(%esp)
80105df7:	e8 5d c1 ff ff       	call   80101f59 <readi>
80105dfc:	83 f8 10             	cmp    $0x10,%eax
80105dff:	74 0c                	je     80105e0d <isdirempty+0x41>
      panic("isdirempty: readi");
80105e01:	c7 04 24 0f 99 10 80 	movl   $0x8010990f,(%esp)
80105e08:	e8 47 a7 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e10:	66 85 c0             	test   %ax,%ax
80105e13:	74 07                	je     80105e1c <isdirempty+0x50>
      return 0;
80105e15:	b8 00 00 00 00       	mov    $0x0,%eax
80105e1a:	eb 1b                	jmp    80105e37 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1f:	83 c0 10             	add    $0x10,%eax
80105e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e28:	8b 45 08             	mov    0x8(%ebp),%eax
80105e2b:	8b 40 58             	mov    0x58(%eax),%eax
80105e2e:	39 c2                	cmp    %eax,%edx
80105e30:	72 a9                	jb     80105ddb <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105e32:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e37:	c9                   	leave  
80105e38:	c3                   	ret    

80105e39 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e39:	55                   	push   %ebp
80105e3a:	89 e5                	mov    %esp,%ebp
80105e3c:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e3f:	8d 45 bc             	lea    -0x44(%ebp),%eax
80105e42:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e4d:	e8 7e fa ff ff       	call   801058d0 <argstr>
80105e52:	85 c0                	test   %eax,%eax
80105e54:	79 0a                	jns    80105e60 <sys_unlink+0x27>
    return -1;
80105e56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5b:	e9 f1 01 00 00       	jmp    80106051 <sys_unlink+0x218>

  begin_op();
80105e60:	e8 3e d8 ff ff       	call   801036a3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e65:	8b 45 bc             	mov    -0x44(%ebp),%eax
80105e68:	8d 55 c2             	lea    -0x3e(%ebp),%edx
80105e6b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e6f:	89 04 24             	mov    %eax,(%esp)
80105e72:	e8 fb c7 ff ff       	call   80102672 <nameiparent>
80105e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e7e:	75 0f                	jne    80105e8f <sys_unlink+0x56>
    end_op();
80105e80:	e8 a0 d8 ff ff       	call   80103725 <end_op>
    return -1;
80105e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8a:	e9 c2 01 00 00       	jmp    80106051 <sys_unlink+0x218>
  }

  ilock(dp);
80105e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e92:	89 04 24             	mov    %eax,(%esp)
80105e95:	e8 28 bc ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e9a:	c7 44 24 04 21 99 10 	movl   $0x80109921,0x4(%esp)
80105ea1:	80 
80105ea2:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105ea5:	89 04 24             	mov    %eax,(%esp)
80105ea8:	e8 08 c4 ff ff       	call   801022b5 <namecmp>
80105ead:	85 c0                	test   %eax,%eax
80105eaf:	0f 84 87 01 00 00    	je     8010603c <sys_unlink+0x203>
80105eb5:	c7 44 24 04 23 99 10 	movl   $0x80109923,0x4(%esp)
80105ebc:	80 
80105ebd:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105ec0:	89 04 24             	mov    %eax,(%esp)
80105ec3:	e8 ed c3 ff ff       	call   801022b5 <namecmp>
80105ec8:	85 c0                	test   %eax,%eax
80105eca:	0f 84 6c 01 00 00    	je     8010603c <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ed0:	8d 45 b8             	lea    -0x48(%ebp),%eax
80105ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ed7:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105eda:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee1:	89 04 24             	mov    %eax,(%esp)
80105ee4:	e8 ee c3 ff ff       	call   801022d7 <dirlookup>
80105ee9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ef0:	75 05                	jne    80105ef7 <sys_unlink+0xbe>
    goto bad;
80105ef2:	e9 45 01 00 00       	jmp    8010603c <sys_unlink+0x203>
  ilock(ip);
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	89 04 24             	mov    %eax,(%esp)
80105efd:	e8 c0 bb ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
80105f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f05:	66 8b 40 56          	mov    0x56(%eax),%ax
80105f09:	66 85 c0             	test   %ax,%ax
80105f0c:	7f 0c                	jg     80105f1a <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105f0e:	c7 04 24 26 99 10 80 	movl   $0x80109926,(%esp)
80105f15:	e8 3a a6 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1d:	8b 40 50             	mov    0x50(%eax),%eax
80105f20:	66 83 f8 01          	cmp    $0x1,%ax
80105f24:	75 1f                	jne    80105f45 <sys_unlink+0x10c>
80105f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f29:	89 04 24             	mov    %eax,(%esp)
80105f2c:	e8 9b fe ff ff       	call   80105dcc <isdirempty>
80105f31:	85 c0                	test   %eax,%eax
80105f33:	75 10                	jne    80105f45 <sys_unlink+0x10c>
    iunlockput(ip);
80105f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f38:	89 04 24             	mov    %eax,(%esp)
80105f3b:	e8 81 bd ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105f40:	e9 f7 00 00 00       	jmp    8010603c <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80105f45:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105f4c:	00 
80105f4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f54:	00 
80105f55:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105f58:	89 04 24             	mov    %eax,(%esp)
80105f5b:	e8 a6 f5 ff ff       	call   80105506 <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80105f60:	8b 45 b8             	mov    -0x48(%ebp),%eax
80105f63:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f6a:	00 
80105f6b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f6f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105f72:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f79:	89 04 24             	mov    %eax,(%esp)
80105f7c:	e8 3c c1 ff ff       	call   801020bd <writei>
80105f81:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
80105f84:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80105f88:	74 0c                	je     80105f96 <sys_unlink+0x15d>
    panic("unlink: writei");
80105f8a:	c7 04 24 38 99 10 80 	movl   $0x80109938,(%esp)
80105f91:	e8 be a5 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
80105f96:	e8 08 e4 ff ff       	call   801043a3 <myproc>
80105f9b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105fa1:	83 c0 18             	add    $0x18,%eax
80105fa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
80105fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105faa:	89 04 24             	mov    %eax,(%esp)
80105fad:	e8 59 2e 00 00       	call   80108e0b <find>
80105fb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
80105fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fb8:	89 c2                	mov    %eax,%edx
80105fba:	c1 ea 1f             	shr    $0x1f,%edx
80105fbd:	01 d0                	add    %edx,%eax
80105fbf:	d1 f8                	sar    %eax
80105fc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
80105fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fc7:	f7 d8                	neg    %eax
80105fc9:	89 c2                	mov    %eax,%edx
80105fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fce:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd2:	89 14 24             	mov    %edx,(%esp)
80105fd5:	e8 88 31 00 00       	call   80109162 <set_curr_disk>
  if(ip->type == T_DIR){
80105fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdd:	8b 40 50             	mov    0x50(%eax),%eax
80105fe0:	66 83 f8 01          	cmp    $0x1,%ax
80105fe4:	75 1a                	jne    80106000 <sys_unlink+0x1c7>
    dp->nlink--;
80105fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105fed:	48                   	dec    %eax
80105fee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff8:	89 04 24             	mov    %eax,(%esp)
80105ffb:	e8 ff b8 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
80106000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106003:	89 04 24             	mov    %eax,(%esp)
80106006:	e8 b6 bc ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
8010600b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600e:	66 8b 40 56          	mov    0x56(%eax),%ax
80106012:	48                   	dec    %eax
80106013:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106016:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010601a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601d:	89 04 24             	mov    %eax,(%esp)
80106020:	e8 da b8 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	89 04 24             	mov    %eax,(%esp)
8010602b:	e8 91 bc ff ff       	call   80101cc1 <iunlockput>

  end_op();
80106030:	e8 f0 d6 ff ff       	call   80103725 <end_op>

  return 0;
80106035:	b8 00 00 00 00       	mov    $0x0,%eax
8010603a:	eb 15                	jmp    80106051 <sys_unlink+0x218>

bad:
  iunlockput(dp);
8010603c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603f:	89 04 24             	mov    %eax,(%esp)
80106042:	e8 7a bc ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106047:	e8 d9 d6 ff ff       	call   80103725 <end_op>
  return -1;
8010604c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106051:	c9                   	leave  
80106052:	c3                   	ret    

80106053 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106053:	55                   	push   %ebp
80106054:	89 e5                	mov    %esp,%ebp
80106056:	83 ec 48             	sub    $0x48,%esp
80106059:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010605c:	8b 55 10             	mov    0x10(%ebp),%edx
8010605f:	8b 45 14             	mov    0x14(%ebp),%eax
80106062:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106066:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010606a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010606e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106071:	89 44 24 04          	mov    %eax,0x4(%esp)
80106075:	8b 45 08             	mov    0x8(%ebp),%eax
80106078:	89 04 24             	mov    %eax,(%esp)
8010607b:	e8 f2 c5 ff ff       	call   80102672 <nameiparent>
80106080:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106083:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106087:	75 0a                	jne    80106093 <create+0x40>
    return 0;
80106089:	b8 00 00 00 00       	mov    $0x0,%eax
8010608e:	e9 79 01 00 00       	jmp    8010620c <create+0x1b9>
  ilock(dp);
80106093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106096:	89 04 24             	mov    %eax,(%esp)
80106099:	e8 24 ba ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010609e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801060a5:	8d 45 de             	lea    -0x22(%ebp),%eax
801060a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060af:	89 04 24             	mov    %eax,(%esp)
801060b2:	e8 20 c2 ff ff       	call   801022d7 <dirlookup>
801060b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060be:	74 46                	je     80106106 <create+0xb3>
    iunlockput(dp);
801060c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c3:	89 04 24             	mov    %eax,(%esp)
801060c6:	e8 f6 bb ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
801060cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ce:	89 04 24             	mov    %eax,(%esp)
801060d1:	e8 ec b9 ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801060d6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801060db:	75 14                	jne    801060f1 <create+0x9e>
801060dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e0:	8b 40 50             	mov    0x50(%eax),%eax
801060e3:	66 83 f8 02          	cmp    $0x2,%ax
801060e7:	75 08                	jne    801060f1 <create+0x9e>
      return ip;
801060e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ec:	e9 1b 01 00 00       	jmp    8010620c <create+0x1b9>
    iunlockput(ip);
801060f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f4:	89 04 24             	mov    %eax,(%esp)
801060f7:	e8 c5 bb ff ff       	call   80101cc1 <iunlockput>
    return 0;
801060fc:	b8 00 00 00 00       	mov    $0x0,%eax
80106101:	e9 06 01 00 00       	jmp    8010620c <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106106:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010610a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610d:	8b 00                	mov    (%eax),%eax
8010610f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106113:	89 04 24             	mov    %eax,(%esp)
80106116:	e8 12 b7 ff ff       	call   8010182d <ialloc>
8010611b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010611e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106122:	75 0c                	jne    80106130 <create+0xdd>
    panic("create: ialloc");
80106124:	c7 04 24 47 99 10 80 	movl   $0x80109947,(%esp)
8010612b:	e8 24 a4 ff ff       	call   80100554 <panic>

  ilock(ip);
80106130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106133:	89 04 24             	mov    %eax,(%esp)
80106136:	e8 87 b9 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
8010613b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010613e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106141:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106145:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106148:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010614b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010614f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106152:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615b:	89 04 24             	mov    %eax,(%esp)
8010615e:	e8 9c b7 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106163:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106168:	75 68                	jne    801061d2 <create+0x17f>
    dp->nlink++;  // for ".."
8010616a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106171:	40                   	inc    %eax
80106172:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106175:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617c:	89 04 24             	mov    %eax,(%esp)
8010617f:	e8 7b b7 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106187:	8b 40 04             	mov    0x4(%eax),%eax
8010618a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010618e:	c7 44 24 04 21 99 10 	movl   $0x80109921,0x4(%esp)
80106195:	80 
80106196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106199:	89 04 24             	mov    %eax,(%esp)
8010619c:	e8 fc c1 ff ff       	call   8010239d <dirlink>
801061a1:	85 c0                	test   %eax,%eax
801061a3:	78 21                	js     801061c6 <create+0x173>
801061a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a8:	8b 40 04             	mov    0x4(%eax),%eax
801061ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801061af:	c7 44 24 04 23 99 10 	movl   $0x80109923,0x4(%esp)
801061b6:	80 
801061b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ba:	89 04 24             	mov    %eax,(%esp)
801061bd:	e8 db c1 ff ff       	call   8010239d <dirlink>
801061c2:	85 c0                	test   %eax,%eax
801061c4:	79 0c                	jns    801061d2 <create+0x17f>
      panic("create dots");
801061c6:	c7 04 24 56 99 10 80 	movl   $0x80109956,(%esp)
801061cd:	e8 82 a3 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d5:	8b 40 04             	mov    0x4(%eax),%eax
801061d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801061dc:	8d 45 de             	lea    -0x22(%ebp),%eax
801061df:	89 44 24 04          	mov    %eax,0x4(%esp)
801061e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e6:	89 04 24             	mov    %eax,(%esp)
801061e9:	e8 af c1 ff ff       	call   8010239d <dirlink>
801061ee:	85 c0                	test   %eax,%eax
801061f0:	79 0c                	jns    801061fe <create+0x1ab>
    panic("create: dirlink");
801061f2:	c7 04 24 62 99 10 80 	movl   $0x80109962,(%esp)
801061f9:	e8 56 a3 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801061fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106201:	89 04 24             	mov    %eax,(%esp)
80106204:	e8 b8 ba ff ff       	call   80101cc1 <iunlockput>

  return ip;
80106209:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010620c:	c9                   	leave  
8010620d:	c3                   	ret    

8010620e <sys_open>:

int
sys_open(void)
{
8010620e:	55                   	push   %ebp
8010620f:	89 e5                	mov    %esp,%ebp
80106211:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106214:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106217:	89 44 24 04          	mov    %eax,0x4(%esp)
8010621b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106222:	e8 a9 f6 ff ff       	call   801058d0 <argstr>
80106227:	85 c0                	test   %eax,%eax
80106229:	78 17                	js     80106242 <sys_open+0x34>
8010622b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010622e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106232:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106239:	e8 fb f5 ff ff       	call   80105839 <argint>
8010623e:	85 c0                	test   %eax,%eax
80106240:	79 0a                	jns    8010624c <sys_open+0x3e>
    return -1;
80106242:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106247:	e9 64 01 00 00       	jmp    801063b0 <sys_open+0x1a2>

  begin_op();
8010624c:	e8 52 d4 ff ff       	call   801036a3 <begin_op>

  if(omode & O_CREATE){
80106251:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106254:	25 00 02 00 00       	and    $0x200,%eax
80106259:	85 c0                	test   %eax,%eax
8010625b:	74 3b                	je     80106298 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010625d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106260:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106267:	00 
80106268:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010626f:	00 
80106270:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106277:	00 
80106278:	89 04 24             	mov    %eax,(%esp)
8010627b:	e8 d3 fd ff ff       	call   80106053 <create>
80106280:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106283:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106287:	75 6a                	jne    801062f3 <sys_open+0xe5>
      end_op();
80106289:	e8 97 d4 ff ff       	call   80103725 <end_op>
      return -1;
8010628e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106293:	e9 18 01 00 00       	jmp    801063b0 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106298:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010629b:	89 04 24             	mov    %eax,(%esp)
8010629e:	e8 ad c3 ff ff       	call   80102650 <namei>
801062a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062aa:	75 0f                	jne    801062bb <sys_open+0xad>
      end_op();
801062ac:	e8 74 d4 ff ff       	call   80103725 <end_op>
      return -1;
801062b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b6:	e9 f5 00 00 00       	jmp    801063b0 <sys_open+0x1a2>
    }
    ilock(ip);
801062bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062be:	89 04 24             	mov    %eax,(%esp)
801062c1:	e8 fc b7 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801062c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c9:	8b 40 50             	mov    0x50(%eax),%eax
801062cc:	66 83 f8 01          	cmp    $0x1,%ax
801062d0:	75 21                	jne    801062f3 <sys_open+0xe5>
801062d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d5:	85 c0                	test   %eax,%eax
801062d7:	74 1a                	je     801062f3 <sys_open+0xe5>
      iunlockput(ip);
801062d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dc:	89 04 24             	mov    %eax,(%esp)
801062df:	e8 dd b9 ff ff       	call   80101cc1 <iunlockput>
      end_op();
801062e4:	e8 3c d4 ff ff       	call   80103725 <end_op>
      return -1;
801062e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ee:	e9 bd 00 00 00       	jmp    801063b0 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062f3:	e8 0a ae ff ff       	call   80101102 <filealloc>
801062f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062ff:	74 14                	je     80106315 <sys_open+0x107>
80106301:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106304:	89 04 24             	mov    %eax,(%esp)
80106307:	e8 f8 f6 ff ff       	call   80105a04 <fdalloc>
8010630c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010630f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106313:	79 28                	jns    8010633d <sys_open+0x12f>
    if(f)
80106315:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106319:	74 0b                	je     80106326 <sys_open+0x118>
      fileclose(f);
8010631b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631e:	89 04 24             	mov    %eax,(%esp)
80106321:	e8 84 ae ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106329:	89 04 24             	mov    %eax,(%esp)
8010632c:	e8 90 b9 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106331:	e8 ef d3 ff ff       	call   80103725 <end_op>
    return -1;
80106336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633b:	eb 73                	jmp    801063b0 <sys_open+0x1a2>
  }
  iunlock(ip);
8010633d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106340:	89 04 24             	mov    %eax,(%esp)
80106343:	e8 84 b8 ff ff       	call   80101bcc <iunlock>
  end_op();
80106348:	e8 d8 d3 ff ff       	call   80103725 <end_op>

  f->type = FD_INODE;
8010634d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106350:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106356:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106359:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010635c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010635f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106362:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010636c:	83 e0 01             	and    $0x1,%eax
8010636f:	85 c0                	test   %eax,%eax
80106371:	0f 94 c0             	sete   %al
80106374:	88 c2                	mov    %al,%dl
80106376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106379:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010637c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637f:	83 e0 01             	and    $0x1,%eax
80106382:	85 c0                	test   %eax,%eax
80106384:	75 0a                	jne    80106390 <sys_open+0x182>
80106386:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106389:	83 e0 02             	and    $0x2,%eax
8010638c:	85 c0                	test   %eax,%eax
8010638e:	74 07                	je     80106397 <sys_open+0x189>
80106390:	b8 01 00 00 00       	mov    $0x1,%eax
80106395:	eb 05                	jmp    8010639c <sys_open+0x18e>
80106397:	b8 00 00 00 00       	mov    $0x0,%eax
8010639c:	88 c2                	mov    %al,%dl
8010639e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a1:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
801063a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801063a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063aa:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
801063ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801063b0:	c9                   	leave  
801063b1:	c3                   	ret    

801063b2 <sys_mkdir>:

int
sys_mkdir(void)
{
801063b2:	55                   	push   %ebp
801063b3:	89 e5                	mov    %esp,%ebp
801063b5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063b8:	e8 e6 d2 ff ff       	call   801036a3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801063c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063cb:	e8 00 f5 ff ff       	call   801058d0 <argstr>
801063d0:	85 c0                	test   %eax,%eax
801063d2:	78 2c                	js     80106400 <sys_mkdir+0x4e>
801063d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063de:	00 
801063df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063e6:	00 
801063e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801063ee:	00 
801063ef:	89 04 24             	mov    %eax,(%esp)
801063f2:	e8 5c fc ff ff       	call   80106053 <create>
801063f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063fe:	75 0c                	jne    8010640c <sys_mkdir+0x5a>
    end_op();
80106400:	e8 20 d3 ff ff       	call   80103725 <end_op>
    return -1;
80106405:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640a:	eb 15                	jmp    80106421 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010640c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640f:	89 04 24             	mov    %eax,(%esp)
80106412:	e8 aa b8 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106417:	e8 09 d3 ff ff       	call   80103725 <end_op>
  return 0;
8010641c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106421:	c9                   	leave  
80106422:	c3                   	ret    

80106423 <sys_mknod>:

int
sys_mknod(void)
{
80106423:	55                   	push   %ebp
80106424:	89 e5                	mov    %esp,%ebp
80106426:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106429:	e8 75 d2 ff ff       	call   801036a3 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010642e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106431:	89 44 24 04          	mov    %eax,0x4(%esp)
80106435:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010643c:	e8 8f f4 ff ff       	call   801058d0 <argstr>
80106441:	85 c0                	test   %eax,%eax
80106443:	78 5e                	js     801064a3 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106445:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106448:	89 44 24 04          	mov    %eax,0x4(%esp)
8010644c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106453:	e8 e1 f3 ff ff       	call   80105839 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106458:	85 c0                	test   %eax,%eax
8010645a:	78 47                	js     801064a3 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010645c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010645f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106463:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010646a:	e8 ca f3 ff ff       	call   80105839 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010646f:	85 c0                	test   %eax,%eax
80106471:	78 30                	js     801064a3 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106476:	0f bf c8             	movswl %ax,%ecx
80106479:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010647c:	0f bf d0             	movswl %ax,%edx
8010647f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106482:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106486:	89 54 24 08          	mov    %edx,0x8(%esp)
8010648a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106491:	00 
80106492:	89 04 24             	mov    %eax,(%esp)
80106495:	e8 b9 fb ff ff       	call   80106053 <create>
8010649a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010649d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064a1:	75 0c                	jne    801064af <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801064a3:	e8 7d d2 ff ff       	call   80103725 <end_op>
    return -1;
801064a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ad:	eb 15                	jmp    801064c4 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801064af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b2:	89 04 24             	mov    %eax,(%esp)
801064b5:	e8 07 b8 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801064ba:	e8 66 d2 ff ff       	call   80103725 <end_op>
  return 0;
801064bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c4:	c9                   	leave  
801064c5:	c3                   	ret    

801064c6 <sys_chdir>:

int
sys_chdir(void)
{
801064c6:	55                   	push   %ebp
801064c7:	89 e5                	mov    %esp,%ebp
801064c9:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801064cc:	e8 d2 de ff ff       	call   801043a3 <myproc>
801064d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801064d4:	e8 ca d1 ff ff       	call   801036a3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064e7:	e8 e4 f3 ff ff       	call   801058d0 <argstr>
801064ec:	85 c0                	test   %eax,%eax
801064ee:	78 14                	js     80106504 <sys_chdir+0x3e>
801064f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064f3:	89 04 24             	mov    %eax,(%esp)
801064f6:	e8 55 c1 ff ff       	call   80102650 <namei>
801064fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106502:	75 0c                	jne    80106510 <sys_chdir+0x4a>
    end_op();
80106504:	e8 1c d2 ff ff       	call   80103725 <end_op>
    return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	eb 5a                	jmp    8010656a <sys_chdir+0xa4>
  }
  ilock(ip);
80106510:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106513:	89 04 24             	mov    %eax,(%esp)
80106516:	e8 a7 b5 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
8010651b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651e:	8b 40 50             	mov    0x50(%eax),%eax
80106521:	66 83 f8 01          	cmp    $0x1,%ax
80106525:	74 17                	je     8010653e <sys_chdir+0x78>
    iunlockput(ip);
80106527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010652a:	89 04 24             	mov    %eax,(%esp)
8010652d:	e8 8f b7 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106532:	e8 ee d1 ff ff       	call   80103725 <end_op>
    return -1;
80106537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653c:	eb 2c                	jmp    8010656a <sys_chdir+0xa4>
  }
  iunlock(ip);
8010653e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106541:	89 04 24             	mov    %eax,(%esp)
80106544:	e8 83 b6 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654c:	8b 40 68             	mov    0x68(%eax),%eax
8010654f:	89 04 24             	mov    %eax,(%esp)
80106552:	e8 b9 b6 ff ff       	call   80101c10 <iput>
  end_op();
80106557:	e8 c9 d1 ff ff       	call   80103725 <end_op>
  curproc->cwd = ip;
8010655c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106562:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106565:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010656a:	c9                   	leave  
8010656b:	c3                   	ret    

8010656c <sys_exec>:

int
sys_exec(void)
{
8010656c:	55                   	push   %ebp
8010656d:	89 e5                	mov    %esp,%ebp
8010656f:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106575:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106578:	89 44 24 04          	mov    %eax,0x4(%esp)
8010657c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106583:	e8 48 f3 ff ff       	call   801058d0 <argstr>
80106588:	85 c0                	test   %eax,%eax
8010658a:	78 1a                	js     801065a6 <sys_exec+0x3a>
8010658c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106592:	89 44 24 04          	mov    %eax,0x4(%esp)
80106596:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010659d:	e8 97 f2 ff ff       	call   80105839 <argint>
801065a2:	85 c0                	test   %eax,%eax
801065a4:	79 0a                	jns    801065b0 <sys_exec+0x44>
    return -1;
801065a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ab:	e9 c7 00 00 00       	jmp    80106677 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
801065b0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801065b7:	00 
801065b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065bf:	00 
801065c0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065c6:	89 04 24             	mov    %eax,(%esp)
801065c9:	e8 38 ef ff ff       	call   80105506 <memset>
  for(i=0;; i++){
801065ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d8:	83 f8 1f             	cmp    $0x1f,%eax
801065db:	76 0a                	jbe    801065e7 <sys_exec+0x7b>
      return -1;
801065dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e2:	e9 90 00 00 00       	jmp    80106677 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801065e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ea:	c1 e0 02             	shl    $0x2,%eax
801065ed:	89 c2                	mov    %eax,%edx
801065ef:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065f5:	01 c2                	add    %eax,%edx
801065f7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106601:	89 14 24             	mov    %edx,(%esp)
80106604:	e8 8f f1 ff ff       	call   80105798 <fetchint>
80106609:	85 c0                	test   %eax,%eax
8010660b:	79 07                	jns    80106614 <sys_exec+0xa8>
      return -1;
8010660d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106612:	eb 63                	jmp    80106677 <sys_exec+0x10b>
    if(uarg == 0){
80106614:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010661a:	85 c0                	test   %eax,%eax
8010661c:	75 26                	jne    80106644 <sys_exec+0xd8>
      argv[i] = 0;
8010661e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106621:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106628:	00 00 00 00 
      break;
8010662c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010662d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106630:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106636:	89 54 24 04          	mov    %edx,0x4(%esp)
8010663a:	89 04 24             	mov    %eax,(%esp)
8010663d:	e8 fe a5 ff ff       	call   80100c40 <exec>
80106642:	eb 33                	jmp    80106677 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106644:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010664a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010664d:	c1 e2 02             	shl    $0x2,%edx
80106650:	01 c2                	add    %eax,%edx
80106652:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106658:	89 54 24 04          	mov    %edx,0x4(%esp)
8010665c:	89 04 24             	mov    %eax,(%esp)
8010665f:	e8 73 f1 ff ff       	call   801057d7 <fetchstr>
80106664:	85 c0                	test   %eax,%eax
80106666:	79 07                	jns    8010666f <sys_exec+0x103>
      return -1;
80106668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666d:	eb 08                	jmp    80106677 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010666f:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106672:	e9 5e ff ff ff       	jmp    801065d5 <sys_exec+0x69>
  return exec(path, argv);
}
80106677:	c9                   	leave  
80106678:	c3                   	ret    

80106679 <sys_pipe>:

int
sys_pipe(void)
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010667f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106686:	00 
80106687:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010668a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010668e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106695:	e8 cc f1 ff ff       	call   80105866 <argptr>
8010669a:	85 c0                	test   %eax,%eax
8010669c:	79 0a                	jns    801066a8 <sys_pipe+0x2f>
    return -1;
8010669e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a3:	e9 9a 00 00 00       	jmp    80106742 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801066a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801066af:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066b2:	89 04 24             	mov    %eax,(%esp)
801066b5:	e8 3e d8 ff ff       	call   80103ef8 <pipealloc>
801066ba:	85 c0                	test   %eax,%eax
801066bc:	79 07                	jns    801066c5 <sys_pipe+0x4c>
    return -1;
801066be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c3:	eb 7d                	jmp    80106742 <sys_pipe+0xc9>
  fd0 = -1;
801066c5:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066cf:	89 04 24             	mov    %eax,(%esp)
801066d2:	e8 2d f3 ff ff       	call   80105a04 <fdalloc>
801066d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066de:	78 14                	js     801066f4 <sys_pipe+0x7b>
801066e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066e3:	89 04 24             	mov    %eax,(%esp)
801066e6:	e8 19 f3 ff ff       	call   80105a04 <fdalloc>
801066eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066f2:	79 36                	jns    8010672a <sys_pipe+0xb1>
    if(fd0 >= 0)
801066f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066f8:	78 13                	js     8010670d <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801066fa:	e8 a4 dc ff ff       	call   801043a3 <myproc>
801066ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106702:	83 c2 08             	add    $0x8,%edx
80106705:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010670c:	00 
    fileclose(rf);
8010670d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106710:	89 04 24             	mov    %eax,(%esp)
80106713:	e8 92 aa ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010671b:	89 04 24             	mov    %eax,(%esp)
8010671e:	e8 87 aa ff ff       	call   801011aa <fileclose>
    return -1;
80106723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106728:	eb 18                	jmp    80106742 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
8010672a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010672d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106730:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106732:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106735:	8d 50 04             	lea    0x4(%eax),%edx
80106738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673b:	89 02                	mov    %eax,(%edx)
  return 0;
8010673d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106742:	c9                   	leave  
80106743:	c3                   	ret    

80106744 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106744:	55                   	push   %ebp
80106745:	89 e5                	mov    %esp,%ebp
80106747:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010674a:	e8 6d df ff ff       	call   801046bc <fork>
}
8010674f:	c9                   	leave  
80106750:	c3                   	ret    

80106751 <sys_exit>:

int
sys_exit(void)
{
80106751:	55                   	push   %ebp
80106752:	89 e5                	mov    %esp,%ebp
80106754:	83 ec 08             	sub    $0x8,%esp
  exit();
80106757:	e8 d8 e0 ff ff       	call   80104834 <exit>
  return 0;  // not reached
8010675c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106761:	c9                   	leave  
80106762:	c3                   	ret    

80106763 <sys_wait>:

int
sys_wait(void)
{
80106763:	55                   	push   %ebp
80106764:	89 e5                	mov    %esp,%ebp
80106766:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106769:	e8 0a e2 ff ff       	call   80104978 <wait>
}
8010676e:	c9                   	leave  
8010676f:	c3                   	ret    

80106770 <sys_kill>:

int
sys_kill(void)
{
80106770:	55                   	push   %ebp
80106771:	89 e5                	mov    %esp,%ebp
80106773:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106776:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106779:	89 44 24 04          	mov    %eax,0x4(%esp)
8010677d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106784:	e8 b0 f0 ff ff       	call   80105839 <argint>
80106789:	85 c0                	test   %eax,%eax
8010678b:	79 07                	jns    80106794 <sys_kill+0x24>
    return -1;
8010678d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106792:	eb 0b                	jmp    8010679f <sys_kill+0x2f>
  return kill(pid);
80106794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106797:	89 04 24             	mov    %eax,(%esp)
8010679a:	e8 b7 e5 ff ff       	call   80104d56 <kill>
}
8010679f:	c9                   	leave  
801067a0:	c3                   	ret    

801067a1 <sys_getpid>:

int
sys_getpid(void)
{
801067a1:	55                   	push   %ebp
801067a2:	89 e5                	mov    %esp,%ebp
801067a4:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801067a7:	e8 f7 db ff ff       	call   801043a3 <myproc>
801067ac:	8b 40 10             	mov    0x10(%eax),%eax
}
801067af:	c9                   	leave  
801067b0:	c3                   	ret    

801067b1 <sys_sbrk>:

int
sys_sbrk(void)
{
801067b1:	55                   	push   %ebp
801067b2:	89 e5                	mov    %esp,%ebp
801067b4:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801067b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801067be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c5:	e8 6f f0 ff ff       	call   80105839 <argint>
801067ca:	85 c0                	test   %eax,%eax
801067cc:	79 07                	jns    801067d5 <sys_sbrk+0x24>
    return -1;
801067ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d3:	eb 23                	jmp    801067f8 <sys_sbrk+0x47>
  addr = myproc()->sz;
801067d5:	e8 c9 db ff ff       	call   801043a3 <myproc>
801067da:	8b 00                	mov    (%eax),%eax
801067dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e2:	89 04 24             	mov    %eax,(%esp)
801067e5:	e8 34 de ff ff       	call   8010461e <growproc>
801067ea:	85 c0                	test   %eax,%eax
801067ec:	79 07                	jns    801067f5 <sys_sbrk+0x44>
    return -1;
801067ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f3:	eb 03                	jmp    801067f8 <sys_sbrk+0x47>
  return addr;
801067f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067f8:	c9                   	leave  
801067f9:	c3                   	ret    

801067fa <sys_sleep>:

int
sys_sleep(void)
{
801067fa:	55                   	push   %ebp
801067fb:	89 e5                	mov    %esp,%ebp
801067fd:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106800:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106803:	89 44 24 04          	mov    %eax,0x4(%esp)
80106807:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010680e:	e8 26 f0 ff ff       	call   80105839 <argint>
80106813:	85 c0                	test   %eax,%eax
80106815:	79 07                	jns    8010681e <sys_sleep+0x24>
    return -1;
80106817:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010681c:	eb 6b                	jmp    80106889 <sys_sleep+0x8f>
  acquire(&tickslock);
8010681e:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106825:	e8 79 ea ff ff       	call   801052a3 <acquire>
  ticks0 = ticks;
8010682a:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
8010682f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106832:	eb 33                	jmp    80106867 <sys_sleep+0x6d>
    if(myproc()->killed){
80106834:	e8 6a db ff ff       	call   801043a3 <myproc>
80106839:	8b 40 24             	mov    0x24(%eax),%eax
8010683c:	85 c0                	test   %eax,%eax
8010683e:	74 13                	je     80106853 <sys_sleep+0x59>
      release(&tickslock);
80106840:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106847:	e8 c1 ea ff ff       	call   8010530d <release>
      return -1;
8010684c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106851:	eb 36                	jmp    80106889 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106853:	c7 44 24 04 60 73 11 	movl   $0x80117360,0x4(%esp)
8010685a:	80 
8010685b:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
80106862:	e8 ed e3 ff ff       	call   80104c54 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106867:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
8010686c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010686f:	89 c2                	mov    %eax,%edx
80106871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106874:	39 c2                	cmp    %eax,%edx
80106876:	72 bc                	jb     80106834 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106878:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010687f:	e8 89 ea ff ff       	call   8010530d <release>
  return 0;
80106884:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106889:	c9                   	leave  
8010688a:	c3                   	ret    

8010688b <sys_cstop>:

void sys_cstop(){
8010688b:	55                   	push   %ebp
8010688c:	89 e5                	mov    %esp,%ebp
8010688e:	53                   	push   %ebx
8010688f:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106892:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106895:	89 44 24 04          	mov    %eax,0x4(%esp)
80106899:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068a0:	e8 2b f0 ff ff       	call   801058d0 <argstr>

  if(myproc()->cont != NULL){
801068a5:	e8 f9 da ff ff       	call   801043a3 <myproc>
801068aa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801068b0:	85 c0                	test   %eax,%eax
801068b2:	74 72                	je     80106926 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
801068b4:	e8 ea da ff ff       	call   801043a3 <myproc>
801068b9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801068bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
801068c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c5:	89 04 24             	mov    %eax,(%esp)
801068c8:	e8 8c ee ff ff       	call   80105759 <strlen>
801068cd:	89 c3                	mov    %eax,%ebx
801068cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d2:	83 c0 18             	add    $0x18,%eax
801068d5:	89 04 24             	mov    %eax,(%esp)
801068d8:	e8 7c ee ff ff       	call   80105759 <strlen>
801068dd:	39 c3                	cmp    %eax,%ebx
801068df:	75 37                	jne    80106918 <sys_cstop+0x8d>
801068e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e4:	89 04 24             	mov    %eax,(%esp)
801068e7:	e8 6d ee ff ff       	call   80105759 <strlen>
801068ec:	89 c2                	mov    %eax,%edx
801068ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f1:	8d 48 18             	lea    0x18(%eax),%ecx
801068f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f7:	89 54 24 08          	mov    %edx,0x8(%esp)
801068fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801068ff:	89 04 24             	mov    %eax,(%esp)
80106902:	e8 67 ed ff ff       	call   8010566e <strncmp>
80106907:	85 c0                	test   %eax,%eax
80106909:	75 0d                	jne    80106918 <sys_cstop+0x8d>
      cstop_container_helper(cont);
8010690b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690e:	89 04 24             	mov    %eax,(%esp)
80106911:	e8 fa e5 ff ff       	call   80104f10 <cstop_container_helper>
80106916:	eb 19                	jmp    80106931 <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106918:	c7 04 24 74 99 10 80 	movl   $0x80109974,(%esp)
8010691f:	e8 9d 9a ff ff       	call   801003c1 <cprintf>
80106924:	eb 0b                	jmp    80106931 <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106929:	89 04 24             	mov    %eax,(%esp)
8010692c:	e8 30 e6 ff ff       	call   80104f61 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106931:	83 c4 24             	add    $0x24,%esp
80106934:	5b                   	pop    %ebx
80106935:	5d                   	pop    %ebp
80106936:	c3                   	ret    

80106937 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106937:	55                   	push   %ebp
80106938:	89 e5                	mov    %esp,%ebp
8010693a:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
8010693d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106940:	89 44 24 04          	mov    %eax,0x4(%esp)
80106944:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010694b:	e8 80 ef ff ff       	call   801058d0 <argstr>

  set_root_inode(name);
80106950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106953:	89 04 24             	mov    %eax,(%esp)
80106956:	e8 9c 23 00 00       	call   80108cf7 <set_root_inode>
  cprintf("success\n");
8010695b:	c7 04 24 98 99 10 80 	movl   $0x80109998,(%esp)
80106962:	e8 5a 9a ff ff       	call   801003c1 <cprintf>

}
80106967:	c9                   	leave  
80106968:	c3                   	ret    

80106969 <sys_ps>:

void sys_ps(void){
80106969:	55                   	push   %ebp
8010696a:	89 e5                	mov    %esp,%ebp
8010696c:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
8010696f:	e8 2f da ff ff       	call   801043a3 <myproc>
80106974:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010697a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
8010697d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106981:	75 07                	jne    8010698a <sys_ps+0x21>
    procdump();
80106983:	e8 49 e4 ff ff       	call   80104dd1 <procdump>
80106988:	eb 0e                	jmp    80106998 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
8010698a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698d:	83 c0 18             	add    $0x18,%eax
80106990:	89 04 24             	mov    %eax,(%esp)
80106993:	e8 5f e6 ff ff       	call   80104ff7 <c_procdump>
  }
}
80106998:	c9                   	leave  
80106999:	c3                   	ret    

8010699a <sys_container_init>:

void sys_container_init(){
8010699a:	55                   	push   %ebp
8010699b:	89 e5                	mov    %esp,%ebp
8010699d:	83 ec 08             	sub    $0x8,%esp
  container_init();
801069a0:	e8 31 28 00 00       	call   801091d6 <container_init>
}
801069a5:	c9                   	leave  
801069a6:	c3                   	ret    

801069a7 <sys_is_full>:

int sys_is_full(void){
801069a7:	55                   	push   %ebp
801069a8:	89 e5                	mov    %esp,%ebp
801069aa:	83 ec 08             	sub    $0x8,%esp
  return is_full();
801069ad:	e8 09 24 00 00       	call   80108dbb <is_full>
}
801069b2:	c9                   	leave  
801069b3:	c3                   	ret    

801069b4 <sys_find>:

int sys_find(void){
801069b4:	55                   	push   %ebp
801069b5:	89 e5                	mov    %esp,%ebp
801069b7:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
801069ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801069c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069c8:	e8 03 ef ff ff       	call   801058d0 <argstr>

  return find(name);
801069cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d0:	89 04 24             	mov    %eax,(%esp)
801069d3:	e8 33 24 00 00       	call   80108e0b <find>
}
801069d8:	c9                   	leave  
801069d9:	c3                   	ret    

801069da <sys_get_name>:

void sys_get_name(void){
801069da:	55                   	push   %ebp
801069db:	89 e5                	mov    %esp,%ebp
801069dd:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
801069e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069ee:	e8 46 ee ff ff       	call   80105839 <argint>
  argstr(1, &name);
801069f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801069fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a01:	e8 ca ee ff ff       	call   801058d0 <argstr>

  get_name(vc_num, name);
80106a06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a10:	89 04 24             	mov    %eax,(%esp)
80106a13:	e8 20 23 00 00       	call   80108d38 <get_name>
}
80106a18:	c9                   	leave  
80106a19:	c3                   	ret    

80106a1a <sys_get_max_proc>:

int sys_get_max_proc(void){
80106a1a:	55                   	push   %ebp
80106a1b:	89 e5                	mov    %esp,%ebp
80106a1d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a20:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a23:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a2e:	e8 06 ee ff ff       	call   80105839 <argint>


  return get_max_proc(vc_num);  
80106a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a36:	89 04 24             	mov    %eax,(%esp)
80106a39:	e8 3d 24 00 00       	call   80108e7b <get_max_proc>
}
80106a3e:	c9                   	leave  
80106a3f:	c3                   	ret    

80106a40 <sys_get_max_mem>:

int sys_get_max_mem(void){
80106a40:	55                   	push   %ebp
80106a41:	89 e5                	mov    %esp,%ebp
80106a43:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a49:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a54:	e8 e0 ed ff ff       	call   80105839 <argint>


  return get_max_mem(vc_num);
80106a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5c:	89 04 24             	mov    %eax,(%esp)
80106a5f:	e8 7f 24 00 00       	call   80108ee3 <get_max_mem>
}
80106a64:	c9                   	leave  
80106a65:	c3                   	ret    

80106a66 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106a66:	55                   	push   %ebp
80106a67:	89 e5                	mov    %esp,%ebp
80106a69:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a7a:	e8 ba ed ff ff       	call   80105839 <argint>


  return get_max_disk(vc_num);
80106a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a82:	89 04 24             	mov    %eax,(%esp)
80106a85:	e8 99 24 00 00       	call   80108f23 <get_max_disk>

}
80106a8a:	c9                   	leave  
80106a8b:	c3                   	ret    

80106a8c <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106a8c:	55                   	push   %ebp
80106a8d:	89 e5                	mov    %esp,%ebp
80106a8f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a95:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aa0:	e8 94 ed ff ff       	call   80105839 <argint>


  return get_curr_proc(vc_num);
80106aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa8:	89 04 24             	mov    %eax,(%esp)
80106aab:	e8 b3 24 00 00       	call   80108f63 <get_curr_proc>
}
80106ab0:	c9                   	leave  
80106ab1:	c3                   	ret    

80106ab2 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106ab2:	55                   	push   %ebp
80106ab3:	89 e5                	mov    %esp,%ebp
80106ab5:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106ab8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106abb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106abf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ac6:	e8 6e ed ff ff       	call   80105839 <argint>


  return get_curr_mem(vc_num);
80106acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ace:	89 04 24             	mov    %eax,(%esp)
80106ad1:	e8 cd 24 00 00       	call   80108fa3 <get_curr_mem>
}
80106ad6:	c9                   	leave  
80106ad7:	c3                   	ret    

80106ad8 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106ad8:	55                   	push   %ebp
80106ad9:	89 e5                	mov    %esp,%ebp
80106adb:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ae5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aec:	e8 48 ed ff ff       	call   80105839 <argint>


  return get_curr_disk(vc_num);
80106af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af4:	89 04 24             	mov    %eax,(%esp)
80106af7:	e8 fa 24 00 00       	call   80108ff6 <get_curr_disk>
}
80106afc:	c9                   	leave  
80106afd:	c3                   	ret    

80106afe <sys_set_name>:

void sys_set_name(void){
80106afe:	55                   	push   %ebp
80106aff:	89 e5                	mov    %esp,%ebp
80106b01:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b12:	e8 b9 ed ff ff       	call   801058d0 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106b17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b25:	e8 0f ed ff ff       	call   80105839 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106b2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b30:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b34:	89 04 24             	mov    %eax,(%esp)
80106b37:	e8 fa 24 00 00       	call   80109036 <set_name>
  //cprintf("Done setting name.\n");
}
80106b3c:	c9                   	leave  
80106b3d:	c3                   	ret    

80106b3e <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106b3e:	55                   	push   %ebp
80106b3f:	89 e5                	mov    %esp,%ebp
80106b41:	53                   	push   %ebx
80106b42:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106b45:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b53:	e8 e1 ec ff ff       	call   80105839 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106b58:	e8 46 d8 ff ff       	call   801043a3 <myproc>
80106b5d:	89 c3                	mov    %eax,%ebx
80106b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b62:	89 04 24             	mov    %eax,(%esp)
80106b65:	e8 51 23 00 00       	call   80108ebb <get_container>
80106b6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106b70:	83 c4 24             	add    $0x24,%esp
80106b73:	5b                   	pop    %ebx
80106b74:	5d                   	pop    %ebp
80106b75:	c3                   	ret    

80106b76 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106b76:	55                   	push   %ebp
80106b77:	89 e5                	mov    %esp,%ebp
80106b79:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b8a:	e8 aa ec ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106b8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b92:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b9d:	e8 97 ec ff ff       	call   80105839 <argint>

  set_max_mem(mem, vc_num);
80106ba2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bac:	89 04 24             	mov    %eax,(%esp)
80106baf:	e8 b9 24 00 00       	call   8010906d <set_max_mem>
}
80106bb4:	c9                   	leave  
80106bb5:	c3                   	ret    

80106bb6 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106bb6:	55                   	push   %ebp
80106bb7:	89 e5                	mov    %esp,%ebp
80106bb9:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bca:	e8 6a ec ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106bdd:	e8 57 ec ff ff       	call   80105839 <argint>

  set_max_disk(disk, vc_num);
80106be2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bec:	89 04 24             	mov    %eax,(%esp)
80106bef:	e8 9e 24 00 00       	call   80109092 <set_max_disk>
}
80106bf4:	c9                   	leave  
80106bf5:	c3                   	ret    

80106bf6 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106bf6:	55                   	push   %ebp
80106bf7:	89 e5                	mov    %esp,%ebp
80106bf9:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106bfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c0a:	e8 2a ec ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c12:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c1d:	e8 17 ec ff ff       	call   80105839 <argint>

  set_max_proc(proc, vc_num);
80106c22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c28:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c2c:	89 04 24             	mov    %eax,(%esp)
80106c2f:	e8 84 24 00 00       	call   801090b8 <set_max_proc>
}
80106c34:	c9                   	leave  
80106c35:	c3                   	ret    

80106c36 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106c36:	55                   	push   %ebp
80106c37:	89 e5                	mov    %esp,%ebp
80106c39:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106c3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c4a:	e8 ea eb ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c52:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c5d:	e8 d7 eb ff ff       	call   80105839 <argint>

  set_curr_mem(mem, vc_num);
80106c62:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c68:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c6c:	89 04 24             	mov    %eax,(%esp)
80106c6f:	e8 6a 24 00 00       	call   801090de <set_curr_mem>
}
80106c74:	c9                   	leave  
80106c75:	c3                   	ret    

80106c76 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106c76:	55                   	push   %ebp
80106c77:	89 e5                	mov    %esp,%ebp
80106c79:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c8a:	e8 aa eb ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c9d:	e8 97 eb ff ff       	call   80105839 <argint>

  set_curr_mem(mem, vc_num);
80106ca2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cac:	89 04 24             	mov    %eax,(%esp)
80106caf:	e8 2a 24 00 00       	call   801090de <set_curr_mem>
}
80106cb4:	c9                   	leave  
80106cb5:	c3                   	ret    

80106cb6 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106cb6:	55                   	push   %ebp
80106cb7:	89 e5                	mov    %esp,%ebp
80106cb9:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cca:	e8 6a eb ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106ccf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106cdd:	e8 57 eb ff ff       	call   80105839 <argint>

  set_curr_disk(disk, vc_num);
80106ce2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cec:	89 04 24             	mov    %eax,(%esp)
80106cef:	e8 6e 24 00 00       	call   80109162 <set_curr_disk>
}
80106cf4:	c9                   	leave  
80106cf5:	c3                   	ret    

80106cf6 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106cf6:	55                   	push   %ebp
80106cf7:	89 e5                	mov    %esp,%ebp
80106cf9:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d0a:	e8 2a eb ff ff       	call   80105839 <argint>

  int vc_num;
  argint(1, &vc_num);
80106d0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d12:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d1d:	e8 17 eb ff ff       	call   80105839 <argint>

  set_curr_proc(proc, vc_num);
80106d22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d28:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d2c:	89 04 24             	mov    %eax,(%esp)
80106d2f:	e8 73 24 00 00       	call   801091a7 <set_curr_proc>
}
80106d34:	c9                   	leave  
80106d35:	c3                   	ret    

80106d36 <sys_container_reset>:

void sys_container_reset(void){
80106d36:	55                   	push   %ebp
80106d37:	89 e5                	mov    %esp,%ebp
80106d39:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
80106d3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d4a:	e8 ea ea ff ff       	call   80105839 <argint>
  container_reset(vc_num);
80106d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d52:	89 04 24             	mov    %eax,(%esp)
80106d55:	e8 91 25 00 00       	call   801092eb <container_reset>
}
80106d5a:	c9                   	leave  
80106d5b:	c3                   	ret    

80106d5c <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106d5c:	55                   	push   %ebp
80106d5d:	89 e5                	mov    %esp,%ebp
80106d5f:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106d62:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d69:	e8 35 e5 ff ff       	call   801052a3 <acquire>
  xticks = ticks;
80106d6e:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106d76:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d7d:	e8 8b e5 ff ff       	call   8010530d <release>
  return xticks;
80106d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d85:	c9                   	leave  
80106d86:	c3                   	ret    

80106d87 <sys_getticks>:

int
sys_getticks(void){
80106d87:	55                   	push   %ebp
80106d88:	89 e5                	mov    %esp,%ebp
80106d8a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106d8d:	e8 11 d6 ff ff       	call   801043a3 <myproc>
80106d92:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106d95:	c9                   	leave  
80106d96:	c3                   	ret    

80106d97 <sys_max_containers>:

int sys_max_containers(void){
80106d97:	55                   	push   %ebp
80106d98:	89 e5                	mov    %esp,%ebp
80106d9a:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
80106d9d:	e8 2a 24 00 00       	call   801091cc <max_containers>
}
80106da2:	c9                   	leave  
80106da3:	c3                   	ret    

80106da4 <sys_df>:


void sys_df(void){
80106da4:	55                   	push   %ebp
80106da5:	89 e5                	mov    %esp,%ebp
80106da7:	83 ec 38             	sub    $0x38,%esp
  struct container* cont = myproc()->cont;
80106daa:	e8 f4 d5 ff ff       	call   801043a3 <myproc>
80106daf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106db5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int used = 0;
80106db8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80106dbf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106dc3:	75 4b                	jne    80106e10 <sys_df+0x6c>
    int max = max_containers();
80106dc5:	e8 02 24 00 00       	call   801091cc <max_containers>
80106dca:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
80106dcd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106dd4:	eb 1d                	jmp    80106df3 <sys_df+0x4f>
      used = used + (int)(get_curr_disk(i) / 1024);
80106dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dd9:	89 04 24             	mov    %eax,(%esp)
80106ddc:	e8 15 22 00 00       	call   80108ff6 <get_curr_disk>
80106de1:	85 c0                	test   %eax,%eax
80106de3:	79 05                	jns    80106dea <sys_df+0x46>
80106de5:	05 ff 03 00 00       	add    $0x3ff,%eax
80106dea:	c1 f8 0a             	sar    $0xa,%eax
80106ded:	01 45 f4             	add    %eax,-0xc(%ebp)
  struct container* cont = myproc()->cont;
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
80106df0:	ff 45 f0             	incl   -0x10(%ebp)
80106df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106df6:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80106df9:	7c db                	jl     80106dd6 <sys_df+0x32>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: TBD\n", used);
80106dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e02:	c7 04 24 a4 99 10 80 	movl   $0x801099a4,(%esp)
80106e09:	e8 b3 95 ff ff       	call   801003c1 <cprintf>
80106e0e:	eb 4d                	jmp    80106e5d <sys_df+0xb9>
  }
  else{
    int x = find(cont->name);
80106e10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106e13:	83 c0 18             	add    $0x18,%eax
80106e16:	89 04 24             	mov    %eax,(%esp)
80106e19:	e8 ed 1f 00 00       	call   80108e0b <find>
80106e1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
80106e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e24:	89 04 24             	mov    %eax,(%esp)
80106e27:	e8 ca 21 00 00       	call   80108ff6 <get_curr_disk>
80106e2c:	85 c0                	test   %eax,%eax
80106e2e:	79 05                	jns    80106e35 <sys_df+0x91>
80106e30:	05 ff 03 00 00       	add    $0x3ff,%eax
80106e35:	c1 f8 0a             	sar    $0xa,%eax
80106e38:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d / Disk Available: %d\n", used, get_max_disk(x));
80106e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e3e:	89 04 24             	mov    %eax,(%esp)
80106e41:	e8 dd 20 00 00       	call   80108f23 <get_max_disk>
80106e46:	89 44 24 08          	mov    %eax,0x8(%esp)
80106e4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e51:	c7 04 24 d8 99 10 80 	movl   $0x801099d8,(%esp)
80106e58:	e8 64 95 ff ff       	call   801003c1 <cprintf>
  }
}
80106e5d:	c9                   	leave  
80106e5e:	c3                   	ret    
	...

80106e60 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106e60:	1e                   	push   %ds
  pushl %es
80106e61:	06                   	push   %es
  pushl %fs
80106e62:	0f a0                	push   %fs
  pushl %gs
80106e64:	0f a8                	push   %gs
  pushal
80106e66:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106e67:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106e6b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106e6d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106e6f:	54                   	push   %esp
  call trap
80106e70:	e8 c0 01 00 00       	call   80107035 <trap>
  addl $4, %esp
80106e75:	83 c4 04             	add    $0x4,%esp

80106e78 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106e78:	61                   	popa   
  popl %gs
80106e79:	0f a9                	pop    %gs
  popl %fs
80106e7b:	0f a1                	pop    %fs
  popl %es
80106e7d:	07                   	pop    %es
  popl %ds
80106e7e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106e7f:	83 c4 08             	add    $0x8,%esp
  iret
80106e82:	cf                   	iret   
	...

80106e84 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106e84:	55                   	push   %ebp
80106e85:	89 e5                	mov    %esp,%ebp
80106e87:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e8d:	48                   	dec    %eax
80106e8e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e92:	8b 45 08             	mov    0x8(%ebp),%eax
80106e95:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e99:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9c:	c1 e8 10             	shr    $0x10,%eax
80106e9f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106ea3:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ea6:	0f 01 18             	lidtl  (%eax)
}
80106ea9:	c9                   	leave  
80106eaa:	c3                   	ret    

80106eab <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106eab:	55                   	push   %ebp
80106eac:	89 e5                	mov    %esp,%ebp
80106eae:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106eb1:	0f 20 d0             	mov    %cr2,%eax
80106eb4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106eba:	c9                   	leave  
80106ebb:	c3                   	ret    

80106ebc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106ebc:	55                   	push   %ebp
80106ebd:	89 e5                	mov    %esp,%ebp
80106ebf:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106ec2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ec9:	e9 b8 00 00 00       	jmp    80106f86 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed1:	8b 04 85 00 c1 10 80 	mov    -0x7fef3f00(,%eax,4),%eax
80106ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106edb:	66 89 04 d5 a0 73 11 	mov    %ax,-0x7fee8c60(,%edx,8)
80106ee2:	80 
80106ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee6:	66 c7 04 c5 a2 73 11 	movw   $0x8,-0x7fee8c5e(,%eax,8)
80106eed:	80 08 00 
80106ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef3:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106efa:	83 e2 e0             	and    $0xffffffe0,%edx
80106efd:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f07:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106f0e:	83 e2 1f             	and    $0x1f,%edx
80106f11:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1b:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f22:	83 e2 f0             	and    $0xfffffff0,%edx
80106f25:	83 ca 0e             	or     $0xe,%edx
80106f28:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f32:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f39:	83 e2 ef             	and    $0xffffffef,%edx
80106f3c:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f46:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f4d:	83 e2 9f             	and    $0xffffff9f,%edx
80106f50:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f5a:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f61:	83 ca 80             	or     $0xffffff80,%edx
80106f64:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6e:	8b 04 85 00 c1 10 80 	mov    -0x7fef3f00(,%eax,4),%eax
80106f75:	c1 e8 10             	shr    $0x10,%eax
80106f78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f7b:	66 89 04 d5 a6 73 11 	mov    %ax,-0x7fee8c5a(,%edx,8)
80106f82:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106f83:	ff 45 f4             	incl   -0xc(%ebp)
80106f86:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106f8d:	0f 8e 3b ff ff ff    	jle    80106ece <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106f93:	a1 00 c2 10 80       	mov    0x8010c200,%eax
80106f98:	66 a3 a0 75 11 80    	mov    %ax,0x801175a0
80106f9e:	66 c7 05 a2 75 11 80 	movw   $0x8,0x801175a2
80106fa5:	08 00 
80106fa7:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106fac:	83 e0 e0             	and    $0xffffffe0,%eax
80106faf:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106fb4:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106fb9:	83 e0 1f             	and    $0x1f,%eax
80106fbc:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106fc1:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106fc6:	83 c8 0f             	or     $0xf,%eax
80106fc9:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106fce:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106fd3:	83 e0 ef             	and    $0xffffffef,%eax
80106fd6:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106fdb:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106fe0:	83 c8 60             	or     $0x60,%eax
80106fe3:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106fe8:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106fed:	83 c8 80             	or     $0xffffff80,%eax
80106ff0:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106ff5:	a1 00 c2 10 80       	mov    0x8010c200,%eax
80106ffa:	c1 e8 10             	shr    $0x10,%eax
80106ffd:	66 a3 a6 75 11 80    	mov    %ax,0x801175a6

  initlock(&tickslock, "time");
80107003:	c7 44 24 04 00 9a 10 	movl   $0x80109a00,0x4(%esp)
8010700a:	80 
8010700b:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80107012:	e8 6b e2 ff ff       	call   80105282 <initlock>
}
80107017:	c9                   	leave  
80107018:	c3                   	ret    

80107019 <idtinit>:

void
idtinit(void)
{
80107019:	55                   	push   %ebp
8010701a:	89 e5                	mov    %esp,%ebp
8010701c:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010701f:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107026:	00 
80107027:	c7 04 24 a0 73 11 80 	movl   $0x801173a0,(%esp)
8010702e:	e8 51 fe ff ff       	call   80106e84 <lidt>
}
80107033:	c9                   	leave  
80107034:	c3                   	ret    

80107035 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107035:	55                   	push   %ebp
80107036:	89 e5                	mov    %esp,%ebp
80107038:	57                   	push   %edi
80107039:	56                   	push   %esi
8010703a:	53                   	push   %ebx
8010703b:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010703e:	8b 45 08             	mov    0x8(%ebp),%eax
80107041:	8b 40 30             	mov    0x30(%eax),%eax
80107044:	83 f8 40             	cmp    $0x40,%eax
80107047:	75 3c                	jne    80107085 <trap+0x50>
    if(myproc()->killed)
80107049:	e8 55 d3 ff ff       	call   801043a3 <myproc>
8010704e:	8b 40 24             	mov    0x24(%eax),%eax
80107051:	85 c0                	test   %eax,%eax
80107053:	74 05                	je     8010705a <trap+0x25>
      exit();
80107055:	e8 da d7 ff ff       	call   80104834 <exit>
    myproc()->tf = tf;
8010705a:	e8 44 d3 ff ff       	call   801043a3 <myproc>
8010705f:	8b 55 08             	mov    0x8(%ebp),%edx
80107062:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107065:	e8 9d e8 ff ff       	call   80105907 <syscall>
    if(myproc()->killed)
8010706a:	e8 34 d3 ff ff       	call   801043a3 <myproc>
8010706f:	8b 40 24             	mov    0x24(%eax),%eax
80107072:	85 c0                	test   %eax,%eax
80107074:	74 0a                	je     80107080 <trap+0x4b>
      exit();
80107076:	e8 b9 d7 ff ff       	call   80104834 <exit>
    return;
8010707b:	e9 30 02 00 00       	jmp    801072b0 <trap+0x27b>
80107080:	e9 2b 02 00 00       	jmp    801072b0 <trap+0x27b>
  }

  switch(tf->trapno){
80107085:	8b 45 08             	mov    0x8(%ebp),%eax
80107088:	8b 40 30             	mov    0x30(%eax),%eax
8010708b:	83 e8 20             	sub    $0x20,%eax
8010708e:	83 f8 1f             	cmp    $0x1f,%eax
80107091:	0f 87 cb 00 00 00    	ja     80107162 <trap+0x12d>
80107097:	8b 04 85 a8 9a 10 80 	mov    -0x7fef6558(,%eax,4),%eax
8010709e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801070a0:	e8 35 d2 ff ff       	call   801042da <cpuid>
801070a5:	85 c0                	test   %eax,%eax
801070a7:	75 2f                	jne    801070d8 <trap+0xa3>
      acquire(&tickslock);
801070a9:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801070b0:	e8 ee e1 ff ff       	call   801052a3 <acquire>
      ticks++;
801070b5:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
801070ba:	40                   	inc    %eax
801070bb:	a3 a0 7b 11 80       	mov    %eax,0x80117ba0
      wakeup(&ticks);
801070c0:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
801070c7:	e8 5f dc ff ff       	call   80104d2b <wakeup>
      release(&tickslock);
801070cc:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801070d3:	e8 35 e2 ff ff       	call   8010530d <release>
    }
    p = myproc();
801070d8:	e8 c6 d2 ff ff       	call   801043a3 <myproc>
801070dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801070e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801070e4:	74 0f                	je     801070f5 <trap+0xc0>
      p->ticks++;
801070e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070e9:	8b 40 7c             	mov    0x7c(%eax),%eax
801070ec:	8d 50 01             	lea    0x1(%eax),%edx
801070ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070f2:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801070f5:	e8 81 c0 ff ff       	call   8010317b <lapiceoi>
    break;
801070fa:	e9 35 01 00 00       	jmp    80107234 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801070ff:	e8 76 b8 ff ff       	call   8010297a <ideintr>
    lapiceoi();
80107104:	e8 72 c0 ff ff       	call   8010317b <lapiceoi>
    break;
80107109:	e9 26 01 00 00       	jmp    80107234 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010710e:	e8 7f be ff ff       	call   80102f92 <kbdintr>
    lapiceoi();
80107113:	e8 63 c0 ff ff       	call   8010317b <lapiceoi>
    break;
80107118:	e9 17 01 00 00       	jmp    80107234 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010711d:	e8 6f 03 00 00       	call   80107491 <uartintr>
    lapiceoi();
80107122:	e8 54 c0 ff ff       	call   8010317b <lapiceoi>
    break;
80107127:	e9 08 01 00 00       	jmp    80107234 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010712c:	8b 45 08             	mov    0x8(%ebp),%eax
8010712f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107132:	8b 45 08             	mov    0x8(%ebp),%eax
80107135:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107138:	0f b7 d8             	movzwl %ax,%ebx
8010713b:	e8 9a d1 ff ff       	call   801042da <cpuid>
80107140:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107144:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107148:	89 44 24 04          	mov    %eax,0x4(%esp)
8010714c:	c7 04 24 08 9a 10 80 	movl   $0x80109a08,(%esp)
80107153:	e8 69 92 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107158:	e8 1e c0 ff ff       	call   8010317b <lapiceoi>
    break;
8010715d:	e9 d2 00 00 00       	jmp    80107234 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80107162:	e8 3c d2 ff ff       	call   801043a3 <myproc>
80107167:	85 c0                	test   %eax,%eax
80107169:	74 10                	je     8010717b <trap+0x146>
8010716b:	8b 45 08             	mov    0x8(%ebp),%eax
8010716e:	8b 40 3c             	mov    0x3c(%eax),%eax
80107171:	0f b7 c0             	movzwl %ax,%eax
80107174:	83 e0 03             	and    $0x3,%eax
80107177:	85 c0                	test   %eax,%eax
80107179:	75 40                	jne    801071bb <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010717b:	e8 2b fd ff ff       	call   80106eab <rcr2>
80107180:	89 c3                	mov    %eax,%ebx
80107182:	8b 45 08             	mov    0x8(%ebp),%eax
80107185:	8b 70 38             	mov    0x38(%eax),%esi
80107188:	e8 4d d1 ff ff       	call   801042da <cpuid>
8010718d:	8b 55 08             	mov    0x8(%ebp),%edx
80107190:	8b 52 30             	mov    0x30(%edx),%edx
80107193:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107197:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010719b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010719f:	89 54 24 04          	mov    %edx,0x4(%esp)
801071a3:	c7 04 24 2c 9a 10 80 	movl   $0x80109a2c,(%esp)
801071aa:	e8 12 92 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801071af:	c7 04 24 5e 9a 10 80 	movl   $0x80109a5e,(%esp)
801071b6:	e8 99 93 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801071bb:	e8 eb fc ff ff       	call   80106eab <rcr2>
801071c0:	89 c6                	mov    %eax,%esi
801071c2:	8b 45 08             	mov    0x8(%ebp),%eax
801071c5:	8b 40 38             	mov    0x38(%eax),%eax
801071c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801071cb:	e8 0a d1 ff ff       	call   801042da <cpuid>
801071d0:	89 c3                	mov    %eax,%ebx
801071d2:	8b 45 08             	mov    0x8(%ebp),%eax
801071d5:	8b 78 34             	mov    0x34(%eax),%edi
801071d8:	89 7d d0             	mov    %edi,-0x30(%ebp)
801071db:	8b 45 08             	mov    0x8(%ebp),%eax
801071de:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801071e1:	e8 bd d1 ff ff       	call   801043a3 <myproc>
801071e6:	8d 50 6c             	lea    0x6c(%eax),%edx
801071e9:	89 55 cc             	mov    %edx,-0x34(%ebp)
801071ec:	e8 b2 d1 ff ff       	call   801043a3 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801071f1:	8b 40 10             	mov    0x10(%eax),%eax
801071f4:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801071f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801071fb:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801071ff:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107203:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80107206:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010720a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010720e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107211:	89 54 24 08          	mov    %edx,0x8(%esp)
80107215:	89 44 24 04          	mov    %eax,0x4(%esp)
80107219:	c7 04 24 64 9a 10 80 	movl   $0x80109a64,(%esp)
80107220:	e8 9c 91 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107225:	e8 79 d1 ff ff       	call   801043a3 <myproc>
8010722a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107231:	eb 01                	jmp    80107234 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107233:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107234:	e8 6a d1 ff ff       	call   801043a3 <myproc>
80107239:	85 c0                	test   %eax,%eax
8010723b:	74 22                	je     8010725f <trap+0x22a>
8010723d:	e8 61 d1 ff ff       	call   801043a3 <myproc>
80107242:	8b 40 24             	mov    0x24(%eax),%eax
80107245:	85 c0                	test   %eax,%eax
80107247:	74 16                	je     8010725f <trap+0x22a>
80107249:	8b 45 08             	mov    0x8(%ebp),%eax
8010724c:	8b 40 3c             	mov    0x3c(%eax),%eax
8010724f:	0f b7 c0             	movzwl %ax,%eax
80107252:	83 e0 03             	and    $0x3,%eax
80107255:	83 f8 03             	cmp    $0x3,%eax
80107258:	75 05                	jne    8010725f <trap+0x22a>
    exit();
8010725a:	e8 d5 d5 ff ff       	call   80104834 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010725f:	e8 3f d1 ff ff       	call   801043a3 <myproc>
80107264:	85 c0                	test   %eax,%eax
80107266:	74 1d                	je     80107285 <trap+0x250>
80107268:	e8 36 d1 ff ff       	call   801043a3 <myproc>
8010726d:	8b 40 0c             	mov    0xc(%eax),%eax
80107270:	83 f8 04             	cmp    $0x4,%eax
80107273:	75 10                	jne    80107285 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107275:	8b 45 08             	mov    0x8(%ebp),%eax
80107278:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010727b:	83 f8 20             	cmp    $0x20,%eax
8010727e:	75 05                	jne    80107285 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107280:	e8 5f d9 ff ff       	call   80104be4 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107285:	e8 19 d1 ff ff       	call   801043a3 <myproc>
8010728a:	85 c0                	test   %eax,%eax
8010728c:	74 22                	je     801072b0 <trap+0x27b>
8010728e:	e8 10 d1 ff ff       	call   801043a3 <myproc>
80107293:	8b 40 24             	mov    0x24(%eax),%eax
80107296:	85 c0                	test   %eax,%eax
80107298:	74 16                	je     801072b0 <trap+0x27b>
8010729a:	8b 45 08             	mov    0x8(%ebp),%eax
8010729d:	8b 40 3c             	mov    0x3c(%eax),%eax
801072a0:	0f b7 c0             	movzwl %ax,%eax
801072a3:	83 e0 03             	and    $0x3,%eax
801072a6:	83 f8 03             	cmp    $0x3,%eax
801072a9:	75 05                	jne    801072b0 <trap+0x27b>
    exit();
801072ab:	e8 84 d5 ff ff       	call   80104834 <exit>
}
801072b0:	83 c4 4c             	add    $0x4c,%esp
801072b3:	5b                   	pop    %ebx
801072b4:	5e                   	pop    %esi
801072b5:	5f                   	pop    %edi
801072b6:	5d                   	pop    %ebp
801072b7:	c3                   	ret    

801072b8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801072b8:	55                   	push   %ebp
801072b9:	89 e5                	mov    %esp,%ebp
801072bb:	83 ec 14             	sub    $0x14,%esp
801072be:	8b 45 08             	mov    0x8(%ebp),%eax
801072c1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801072c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072c8:	89 c2                	mov    %eax,%edx
801072ca:	ec                   	in     (%dx),%al
801072cb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801072ce:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801072d1:	c9                   	leave  
801072d2:	c3                   	ret    

801072d3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801072d3:	55                   	push   %ebp
801072d4:	89 e5                	mov    %esp,%ebp
801072d6:	83 ec 08             	sub    $0x8,%esp
801072d9:	8b 45 08             	mov    0x8(%ebp),%eax
801072dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801072df:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801072e3:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801072e6:	8a 45 f8             	mov    -0x8(%ebp),%al
801072e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801072ec:	ee                   	out    %al,(%dx)
}
801072ed:	c9                   	leave  
801072ee:	c3                   	ret    

801072ef <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801072ef:	55                   	push   %ebp
801072f0:	89 e5                	mov    %esp,%ebp
801072f2:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801072f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801072fc:	00 
801072fd:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107304:	e8 ca ff ff ff       	call   801072d3 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107309:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107310:	00 
80107311:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107318:	e8 b6 ff ff ff       	call   801072d3 <outb>
  outb(COM1+0, 115200/9600);
8010731d:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107324:	00 
80107325:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010732c:	e8 a2 ff ff ff       	call   801072d3 <outb>
  outb(COM1+1, 0);
80107331:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107338:	00 
80107339:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107340:	e8 8e ff ff ff       	call   801072d3 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107345:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010734c:	00 
8010734d:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107354:	e8 7a ff ff ff       	call   801072d3 <outb>
  outb(COM1+4, 0);
80107359:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107360:	00 
80107361:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107368:	e8 66 ff ff ff       	call   801072d3 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010736d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107374:	00 
80107375:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010737c:	e8 52 ff ff ff       	call   801072d3 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107381:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107388:	e8 2b ff ff ff       	call   801072b8 <inb>
8010738d:	3c ff                	cmp    $0xff,%al
8010738f:	75 02                	jne    80107393 <uartinit+0xa4>
    return;
80107391:	eb 5b                	jmp    801073ee <uartinit+0xff>
  uart = 1;
80107393:	c7 05 04 c9 10 80 01 	movl   $0x1,0x8010c904
8010739a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010739d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801073a4:	e8 0f ff ff ff       	call   801072b8 <inb>
  inb(COM1+0);
801073a9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801073b0:	e8 03 ff ff ff       	call   801072b8 <inb>
  ioapicenable(IRQ_COM1, 0);
801073b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801073bc:	00 
801073bd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801073c4:	e8 26 b8 ff ff       	call   80102bef <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801073c9:	c7 45 f4 28 9b 10 80 	movl   $0x80109b28,-0xc(%ebp)
801073d0:	eb 13                	jmp    801073e5 <uartinit+0xf6>
    uartputc(*p);
801073d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d5:	8a 00                	mov    (%eax),%al
801073d7:	0f be c0             	movsbl %al,%eax
801073da:	89 04 24             	mov    %eax,(%esp)
801073dd:	e8 0e 00 00 00       	call   801073f0 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801073e2:	ff 45 f4             	incl   -0xc(%ebp)
801073e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e8:	8a 00                	mov    (%eax),%al
801073ea:	84 c0                	test   %al,%al
801073ec:	75 e4                	jne    801073d2 <uartinit+0xe3>
    uartputc(*p);
}
801073ee:	c9                   	leave  
801073ef:	c3                   	ret    

801073f0 <uartputc>:

void
uartputc(int c)
{
801073f0:	55                   	push   %ebp
801073f1:	89 e5                	mov    %esp,%ebp
801073f3:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801073f6:	a1 04 c9 10 80       	mov    0x8010c904,%eax
801073fb:	85 c0                	test   %eax,%eax
801073fd:	75 02                	jne    80107401 <uartputc+0x11>
    return;
801073ff:	eb 4a                	jmp    8010744b <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107408:	eb 0f                	jmp    80107419 <uartputc+0x29>
    microdelay(10);
8010740a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107411:	e8 8a bd ff ff       	call   801031a0 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107416:	ff 45 f4             	incl   -0xc(%ebp)
80107419:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010741d:	7f 16                	jg     80107435 <uartputc+0x45>
8010741f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107426:	e8 8d fe ff ff       	call   801072b8 <inb>
8010742b:	0f b6 c0             	movzbl %al,%eax
8010742e:	83 e0 20             	and    $0x20,%eax
80107431:	85 c0                	test   %eax,%eax
80107433:	74 d5                	je     8010740a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107435:	8b 45 08             	mov    0x8(%ebp),%eax
80107438:	0f b6 c0             	movzbl %al,%eax
8010743b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010743f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107446:	e8 88 fe ff ff       	call   801072d3 <outb>
}
8010744b:	c9                   	leave  
8010744c:	c3                   	ret    

8010744d <uartgetc>:

static int
uartgetc(void)
{
8010744d:	55                   	push   %ebp
8010744e:	89 e5                	mov    %esp,%ebp
80107450:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107453:	a1 04 c9 10 80       	mov    0x8010c904,%eax
80107458:	85 c0                	test   %eax,%eax
8010745a:	75 07                	jne    80107463 <uartgetc+0x16>
    return -1;
8010745c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107461:	eb 2c                	jmp    8010748f <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107463:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010746a:	e8 49 fe ff ff       	call   801072b8 <inb>
8010746f:	0f b6 c0             	movzbl %al,%eax
80107472:	83 e0 01             	and    $0x1,%eax
80107475:	85 c0                	test   %eax,%eax
80107477:	75 07                	jne    80107480 <uartgetc+0x33>
    return -1;
80107479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010747e:	eb 0f                	jmp    8010748f <uartgetc+0x42>
  return inb(COM1+0);
80107480:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107487:	e8 2c fe ff ff       	call   801072b8 <inb>
8010748c:	0f b6 c0             	movzbl %al,%eax
}
8010748f:	c9                   	leave  
80107490:	c3                   	ret    

80107491 <uartintr>:

void
uartintr(void)
{
80107491:	55                   	push   %ebp
80107492:	89 e5                	mov    %esp,%ebp
80107494:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107497:	c7 04 24 4d 74 10 80 	movl   $0x8010744d,(%esp)
8010749e:	e8 52 93 ff ff       	call   801007f5 <consoleintr>
}
801074a3:	c9                   	leave  
801074a4:	c3                   	ret    
801074a5:	00 00                	add    %al,(%eax)
	...

801074a8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $0
801074aa:	6a 00                	push   $0x0
  jmp alltraps
801074ac:	e9 af f9 ff ff       	jmp    80106e60 <alltraps>

801074b1 <vector1>:
.globl vector1
vector1:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $1
801074b3:	6a 01                	push   $0x1
  jmp alltraps
801074b5:	e9 a6 f9 ff ff       	jmp    80106e60 <alltraps>

801074ba <vector2>:
.globl vector2
vector2:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $2
801074bc:	6a 02                	push   $0x2
  jmp alltraps
801074be:	e9 9d f9 ff ff       	jmp    80106e60 <alltraps>

801074c3 <vector3>:
.globl vector3
vector3:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $3
801074c5:	6a 03                	push   $0x3
  jmp alltraps
801074c7:	e9 94 f9 ff ff       	jmp    80106e60 <alltraps>

801074cc <vector4>:
.globl vector4
vector4:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $4
801074ce:	6a 04                	push   $0x4
  jmp alltraps
801074d0:	e9 8b f9 ff ff       	jmp    80106e60 <alltraps>

801074d5 <vector5>:
.globl vector5
vector5:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $5
801074d7:	6a 05                	push   $0x5
  jmp alltraps
801074d9:	e9 82 f9 ff ff       	jmp    80106e60 <alltraps>

801074de <vector6>:
.globl vector6
vector6:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $6
801074e0:	6a 06                	push   $0x6
  jmp alltraps
801074e2:	e9 79 f9 ff ff       	jmp    80106e60 <alltraps>

801074e7 <vector7>:
.globl vector7
vector7:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $7
801074e9:	6a 07                	push   $0x7
  jmp alltraps
801074eb:	e9 70 f9 ff ff       	jmp    80106e60 <alltraps>

801074f0 <vector8>:
.globl vector8
vector8:
  pushl $8
801074f0:	6a 08                	push   $0x8
  jmp alltraps
801074f2:	e9 69 f9 ff ff       	jmp    80106e60 <alltraps>

801074f7 <vector9>:
.globl vector9
vector9:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $9
801074f9:	6a 09                	push   $0x9
  jmp alltraps
801074fb:	e9 60 f9 ff ff       	jmp    80106e60 <alltraps>

80107500 <vector10>:
.globl vector10
vector10:
  pushl $10
80107500:	6a 0a                	push   $0xa
  jmp alltraps
80107502:	e9 59 f9 ff ff       	jmp    80106e60 <alltraps>

80107507 <vector11>:
.globl vector11
vector11:
  pushl $11
80107507:	6a 0b                	push   $0xb
  jmp alltraps
80107509:	e9 52 f9 ff ff       	jmp    80106e60 <alltraps>

8010750e <vector12>:
.globl vector12
vector12:
  pushl $12
8010750e:	6a 0c                	push   $0xc
  jmp alltraps
80107510:	e9 4b f9 ff ff       	jmp    80106e60 <alltraps>

80107515 <vector13>:
.globl vector13
vector13:
  pushl $13
80107515:	6a 0d                	push   $0xd
  jmp alltraps
80107517:	e9 44 f9 ff ff       	jmp    80106e60 <alltraps>

8010751c <vector14>:
.globl vector14
vector14:
  pushl $14
8010751c:	6a 0e                	push   $0xe
  jmp alltraps
8010751e:	e9 3d f9 ff ff       	jmp    80106e60 <alltraps>

80107523 <vector15>:
.globl vector15
vector15:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $15
80107525:	6a 0f                	push   $0xf
  jmp alltraps
80107527:	e9 34 f9 ff ff       	jmp    80106e60 <alltraps>

8010752c <vector16>:
.globl vector16
vector16:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $16
8010752e:	6a 10                	push   $0x10
  jmp alltraps
80107530:	e9 2b f9 ff ff       	jmp    80106e60 <alltraps>

80107535 <vector17>:
.globl vector17
vector17:
  pushl $17
80107535:	6a 11                	push   $0x11
  jmp alltraps
80107537:	e9 24 f9 ff ff       	jmp    80106e60 <alltraps>

8010753c <vector18>:
.globl vector18
vector18:
  pushl $0
8010753c:	6a 00                	push   $0x0
  pushl $18
8010753e:	6a 12                	push   $0x12
  jmp alltraps
80107540:	e9 1b f9 ff ff       	jmp    80106e60 <alltraps>

80107545 <vector19>:
.globl vector19
vector19:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $19
80107547:	6a 13                	push   $0x13
  jmp alltraps
80107549:	e9 12 f9 ff ff       	jmp    80106e60 <alltraps>

8010754e <vector20>:
.globl vector20
vector20:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $20
80107550:	6a 14                	push   $0x14
  jmp alltraps
80107552:	e9 09 f9 ff ff       	jmp    80106e60 <alltraps>

80107557 <vector21>:
.globl vector21
vector21:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $21
80107559:	6a 15                	push   $0x15
  jmp alltraps
8010755b:	e9 00 f9 ff ff       	jmp    80106e60 <alltraps>

80107560 <vector22>:
.globl vector22
vector22:
  pushl $0
80107560:	6a 00                	push   $0x0
  pushl $22
80107562:	6a 16                	push   $0x16
  jmp alltraps
80107564:	e9 f7 f8 ff ff       	jmp    80106e60 <alltraps>

80107569 <vector23>:
.globl vector23
vector23:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $23
8010756b:	6a 17                	push   $0x17
  jmp alltraps
8010756d:	e9 ee f8 ff ff       	jmp    80106e60 <alltraps>

80107572 <vector24>:
.globl vector24
vector24:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $24
80107574:	6a 18                	push   $0x18
  jmp alltraps
80107576:	e9 e5 f8 ff ff       	jmp    80106e60 <alltraps>

8010757b <vector25>:
.globl vector25
vector25:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $25
8010757d:	6a 19                	push   $0x19
  jmp alltraps
8010757f:	e9 dc f8 ff ff       	jmp    80106e60 <alltraps>

80107584 <vector26>:
.globl vector26
vector26:
  pushl $0
80107584:	6a 00                	push   $0x0
  pushl $26
80107586:	6a 1a                	push   $0x1a
  jmp alltraps
80107588:	e9 d3 f8 ff ff       	jmp    80106e60 <alltraps>

8010758d <vector27>:
.globl vector27
vector27:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $27
8010758f:	6a 1b                	push   $0x1b
  jmp alltraps
80107591:	e9 ca f8 ff ff       	jmp    80106e60 <alltraps>

80107596 <vector28>:
.globl vector28
vector28:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $28
80107598:	6a 1c                	push   $0x1c
  jmp alltraps
8010759a:	e9 c1 f8 ff ff       	jmp    80106e60 <alltraps>

8010759f <vector29>:
.globl vector29
vector29:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $29
801075a1:	6a 1d                	push   $0x1d
  jmp alltraps
801075a3:	e9 b8 f8 ff ff       	jmp    80106e60 <alltraps>

801075a8 <vector30>:
.globl vector30
vector30:
  pushl $0
801075a8:	6a 00                	push   $0x0
  pushl $30
801075aa:	6a 1e                	push   $0x1e
  jmp alltraps
801075ac:	e9 af f8 ff ff       	jmp    80106e60 <alltraps>

801075b1 <vector31>:
.globl vector31
vector31:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $31
801075b3:	6a 1f                	push   $0x1f
  jmp alltraps
801075b5:	e9 a6 f8 ff ff       	jmp    80106e60 <alltraps>

801075ba <vector32>:
.globl vector32
vector32:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $32
801075bc:	6a 20                	push   $0x20
  jmp alltraps
801075be:	e9 9d f8 ff ff       	jmp    80106e60 <alltraps>

801075c3 <vector33>:
.globl vector33
vector33:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $33
801075c5:	6a 21                	push   $0x21
  jmp alltraps
801075c7:	e9 94 f8 ff ff       	jmp    80106e60 <alltraps>

801075cc <vector34>:
.globl vector34
vector34:
  pushl $0
801075cc:	6a 00                	push   $0x0
  pushl $34
801075ce:	6a 22                	push   $0x22
  jmp alltraps
801075d0:	e9 8b f8 ff ff       	jmp    80106e60 <alltraps>

801075d5 <vector35>:
.globl vector35
vector35:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $35
801075d7:	6a 23                	push   $0x23
  jmp alltraps
801075d9:	e9 82 f8 ff ff       	jmp    80106e60 <alltraps>

801075de <vector36>:
.globl vector36
vector36:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $36
801075e0:	6a 24                	push   $0x24
  jmp alltraps
801075e2:	e9 79 f8 ff ff       	jmp    80106e60 <alltraps>

801075e7 <vector37>:
.globl vector37
vector37:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $37
801075e9:	6a 25                	push   $0x25
  jmp alltraps
801075eb:	e9 70 f8 ff ff       	jmp    80106e60 <alltraps>

801075f0 <vector38>:
.globl vector38
vector38:
  pushl $0
801075f0:	6a 00                	push   $0x0
  pushl $38
801075f2:	6a 26                	push   $0x26
  jmp alltraps
801075f4:	e9 67 f8 ff ff       	jmp    80106e60 <alltraps>

801075f9 <vector39>:
.globl vector39
vector39:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $39
801075fb:	6a 27                	push   $0x27
  jmp alltraps
801075fd:	e9 5e f8 ff ff       	jmp    80106e60 <alltraps>

80107602 <vector40>:
.globl vector40
vector40:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $40
80107604:	6a 28                	push   $0x28
  jmp alltraps
80107606:	e9 55 f8 ff ff       	jmp    80106e60 <alltraps>

8010760b <vector41>:
.globl vector41
vector41:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $41
8010760d:	6a 29                	push   $0x29
  jmp alltraps
8010760f:	e9 4c f8 ff ff       	jmp    80106e60 <alltraps>

80107614 <vector42>:
.globl vector42
vector42:
  pushl $0
80107614:	6a 00                	push   $0x0
  pushl $42
80107616:	6a 2a                	push   $0x2a
  jmp alltraps
80107618:	e9 43 f8 ff ff       	jmp    80106e60 <alltraps>

8010761d <vector43>:
.globl vector43
vector43:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $43
8010761f:	6a 2b                	push   $0x2b
  jmp alltraps
80107621:	e9 3a f8 ff ff       	jmp    80106e60 <alltraps>

80107626 <vector44>:
.globl vector44
vector44:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $44
80107628:	6a 2c                	push   $0x2c
  jmp alltraps
8010762a:	e9 31 f8 ff ff       	jmp    80106e60 <alltraps>

8010762f <vector45>:
.globl vector45
vector45:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $45
80107631:	6a 2d                	push   $0x2d
  jmp alltraps
80107633:	e9 28 f8 ff ff       	jmp    80106e60 <alltraps>

80107638 <vector46>:
.globl vector46
vector46:
  pushl $0
80107638:	6a 00                	push   $0x0
  pushl $46
8010763a:	6a 2e                	push   $0x2e
  jmp alltraps
8010763c:	e9 1f f8 ff ff       	jmp    80106e60 <alltraps>

80107641 <vector47>:
.globl vector47
vector47:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $47
80107643:	6a 2f                	push   $0x2f
  jmp alltraps
80107645:	e9 16 f8 ff ff       	jmp    80106e60 <alltraps>

8010764a <vector48>:
.globl vector48
vector48:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $48
8010764c:	6a 30                	push   $0x30
  jmp alltraps
8010764e:	e9 0d f8 ff ff       	jmp    80106e60 <alltraps>

80107653 <vector49>:
.globl vector49
vector49:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $49
80107655:	6a 31                	push   $0x31
  jmp alltraps
80107657:	e9 04 f8 ff ff       	jmp    80106e60 <alltraps>

8010765c <vector50>:
.globl vector50
vector50:
  pushl $0
8010765c:	6a 00                	push   $0x0
  pushl $50
8010765e:	6a 32                	push   $0x32
  jmp alltraps
80107660:	e9 fb f7 ff ff       	jmp    80106e60 <alltraps>

80107665 <vector51>:
.globl vector51
vector51:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $51
80107667:	6a 33                	push   $0x33
  jmp alltraps
80107669:	e9 f2 f7 ff ff       	jmp    80106e60 <alltraps>

8010766e <vector52>:
.globl vector52
vector52:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $52
80107670:	6a 34                	push   $0x34
  jmp alltraps
80107672:	e9 e9 f7 ff ff       	jmp    80106e60 <alltraps>

80107677 <vector53>:
.globl vector53
vector53:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $53
80107679:	6a 35                	push   $0x35
  jmp alltraps
8010767b:	e9 e0 f7 ff ff       	jmp    80106e60 <alltraps>

80107680 <vector54>:
.globl vector54
vector54:
  pushl $0
80107680:	6a 00                	push   $0x0
  pushl $54
80107682:	6a 36                	push   $0x36
  jmp alltraps
80107684:	e9 d7 f7 ff ff       	jmp    80106e60 <alltraps>

80107689 <vector55>:
.globl vector55
vector55:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $55
8010768b:	6a 37                	push   $0x37
  jmp alltraps
8010768d:	e9 ce f7 ff ff       	jmp    80106e60 <alltraps>

80107692 <vector56>:
.globl vector56
vector56:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $56
80107694:	6a 38                	push   $0x38
  jmp alltraps
80107696:	e9 c5 f7 ff ff       	jmp    80106e60 <alltraps>

8010769b <vector57>:
.globl vector57
vector57:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $57
8010769d:	6a 39                	push   $0x39
  jmp alltraps
8010769f:	e9 bc f7 ff ff       	jmp    80106e60 <alltraps>

801076a4 <vector58>:
.globl vector58
vector58:
  pushl $0
801076a4:	6a 00                	push   $0x0
  pushl $58
801076a6:	6a 3a                	push   $0x3a
  jmp alltraps
801076a8:	e9 b3 f7 ff ff       	jmp    80106e60 <alltraps>

801076ad <vector59>:
.globl vector59
vector59:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $59
801076af:	6a 3b                	push   $0x3b
  jmp alltraps
801076b1:	e9 aa f7 ff ff       	jmp    80106e60 <alltraps>

801076b6 <vector60>:
.globl vector60
vector60:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $60
801076b8:	6a 3c                	push   $0x3c
  jmp alltraps
801076ba:	e9 a1 f7 ff ff       	jmp    80106e60 <alltraps>

801076bf <vector61>:
.globl vector61
vector61:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $61
801076c1:	6a 3d                	push   $0x3d
  jmp alltraps
801076c3:	e9 98 f7 ff ff       	jmp    80106e60 <alltraps>

801076c8 <vector62>:
.globl vector62
vector62:
  pushl $0
801076c8:	6a 00                	push   $0x0
  pushl $62
801076ca:	6a 3e                	push   $0x3e
  jmp alltraps
801076cc:	e9 8f f7 ff ff       	jmp    80106e60 <alltraps>

801076d1 <vector63>:
.globl vector63
vector63:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $63
801076d3:	6a 3f                	push   $0x3f
  jmp alltraps
801076d5:	e9 86 f7 ff ff       	jmp    80106e60 <alltraps>

801076da <vector64>:
.globl vector64
vector64:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $64
801076dc:	6a 40                	push   $0x40
  jmp alltraps
801076de:	e9 7d f7 ff ff       	jmp    80106e60 <alltraps>

801076e3 <vector65>:
.globl vector65
vector65:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $65
801076e5:	6a 41                	push   $0x41
  jmp alltraps
801076e7:	e9 74 f7 ff ff       	jmp    80106e60 <alltraps>

801076ec <vector66>:
.globl vector66
vector66:
  pushl $0
801076ec:	6a 00                	push   $0x0
  pushl $66
801076ee:	6a 42                	push   $0x42
  jmp alltraps
801076f0:	e9 6b f7 ff ff       	jmp    80106e60 <alltraps>

801076f5 <vector67>:
.globl vector67
vector67:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $67
801076f7:	6a 43                	push   $0x43
  jmp alltraps
801076f9:	e9 62 f7 ff ff       	jmp    80106e60 <alltraps>

801076fe <vector68>:
.globl vector68
vector68:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $68
80107700:	6a 44                	push   $0x44
  jmp alltraps
80107702:	e9 59 f7 ff ff       	jmp    80106e60 <alltraps>

80107707 <vector69>:
.globl vector69
vector69:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $69
80107709:	6a 45                	push   $0x45
  jmp alltraps
8010770b:	e9 50 f7 ff ff       	jmp    80106e60 <alltraps>

80107710 <vector70>:
.globl vector70
vector70:
  pushl $0
80107710:	6a 00                	push   $0x0
  pushl $70
80107712:	6a 46                	push   $0x46
  jmp alltraps
80107714:	e9 47 f7 ff ff       	jmp    80106e60 <alltraps>

80107719 <vector71>:
.globl vector71
vector71:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $71
8010771b:	6a 47                	push   $0x47
  jmp alltraps
8010771d:	e9 3e f7 ff ff       	jmp    80106e60 <alltraps>

80107722 <vector72>:
.globl vector72
vector72:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $72
80107724:	6a 48                	push   $0x48
  jmp alltraps
80107726:	e9 35 f7 ff ff       	jmp    80106e60 <alltraps>

8010772b <vector73>:
.globl vector73
vector73:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $73
8010772d:	6a 49                	push   $0x49
  jmp alltraps
8010772f:	e9 2c f7 ff ff       	jmp    80106e60 <alltraps>

80107734 <vector74>:
.globl vector74
vector74:
  pushl $0
80107734:	6a 00                	push   $0x0
  pushl $74
80107736:	6a 4a                	push   $0x4a
  jmp alltraps
80107738:	e9 23 f7 ff ff       	jmp    80106e60 <alltraps>

8010773d <vector75>:
.globl vector75
vector75:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $75
8010773f:	6a 4b                	push   $0x4b
  jmp alltraps
80107741:	e9 1a f7 ff ff       	jmp    80106e60 <alltraps>

80107746 <vector76>:
.globl vector76
vector76:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $76
80107748:	6a 4c                	push   $0x4c
  jmp alltraps
8010774a:	e9 11 f7 ff ff       	jmp    80106e60 <alltraps>

8010774f <vector77>:
.globl vector77
vector77:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $77
80107751:	6a 4d                	push   $0x4d
  jmp alltraps
80107753:	e9 08 f7 ff ff       	jmp    80106e60 <alltraps>

80107758 <vector78>:
.globl vector78
vector78:
  pushl $0
80107758:	6a 00                	push   $0x0
  pushl $78
8010775a:	6a 4e                	push   $0x4e
  jmp alltraps
8010775c:	e9 ff f6 ff ff       	jmp    80106e60 <alltraps>

80107761 <vector79>:
.globl vector79
vector79:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $79
80107763:	6a 4f                	push   $0x4f
  jmp alltraps
80107765:	e9 f6 f6 ff ff       	jmp    80106e60 <alltraps>

8010776a <vector80>:
.globl vector80
vector80:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $80
8010776c:	6a 50                	push   $0x50
  jmp alltraps
8010776e:	e9 ed f6 ff ff       	jmp    80106e60 <alltraps>

80107773 <vector81>:
.globl vector81
vector81:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $81
80107775:	6a 51                	push   $0x51
  jmp alltraps
80107777:	e9 e4 f6 ff ff       	jmp    80106e60 <alltraps>

8010777c <vector82>:
.globl vector82
vector82:
  pushl $0
8010777c:	6a 00                	push   $0x0
  pushl $82
8010777e:	6a 52                	push   $0x52
  jmp alltraps
80107780:	e9 db f6 ff ff       	jmp    80106e60 <alltraps>

80107785 <vector83>:
.globl vector83
vector83:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $83
80107787:	6a 53                	push   $0x53
  jmp alltraps
80107789:	e9 d2 f6 ff ff       	jmp    80106e60 <alltraps>

8010778e <vector84>:
.globl vector84
vector84:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $84
80107790:	6a 54                	push   $0x54
  jmp alltraps
80107792:	e9 c9 f6 ff ff       	jmp    80106e60 <alltraps>

80107797 <vector85>:
.globl vector85
vector85:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $85
80107799:	6a 55                	push   $0x55
  jmp alltraps
8010779b:	e9 c0 f6 ff ff       	jmp    80106e60 <alltraps>

801077a0 <vector86>:
.globl vector86
vector86:
  pushl $0
801077a0:	6a 00                	push   $0x0
  pushl $86
801077a2:	6a 56                	push   $0x56
  jmp alltraps
801077a4:	e9 b7 f6 ff ff       	jmp    80106e60 <alltraps>

801077a9 <vector87>:
.globl vector87
vector87:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $87
801077ab:	6a 57                	push   $0x57
  jmp alltraps
801077ad:	e9 ae f6 ff ff       	jmp    80106e60 <alltraps>

801077b2 <vector88>:
.globl vector88
vector88:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $88
801077b4:	6a 58                	push   $0x58
  jmp alltraps
801077b6:	e9 a5 f6 ff ff       	jmp    80106e60 <alltraps>

801077bb <vector89>:
.globl vector89
vector89:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $89
801077bd:	6a 59                	push   $0x59
  jmp alltraps
801077bf:	e9 9c f6 ff ff       	jmp    80106e60 <alltraps>

801077c4 <vector90>:
.globl vector90
vector90:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $90
801077c6:	6a 5a                	push   $0x5a
  jmp alltraps
801077c8:	e9 93 f6 ff ff       	jmp    80106e60 <alltraps>

801077cd <vector91>:
.globl vector91
vector91:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $91
801077cf:	6a 5b                	push   $0x5b
  jmp alltraps
801077d1:	e9 8a f6 ff ff       	jmp    80106e60 <alltraps>

801077d6 <vector92>:
.globl vector92
vector92:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $92
801077d8:	6a 5c                	push   $0x5c
  jmp alltraps
801077da:	e9 81 f6 ff ff       	jmp    80106e60 <alltraps>

801077df <vector93>:
.globl vector93
vector93:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $93
801077e1:	6a 5d                	push   $0x5d
  jmp alltraps
801077e3:	e9 78 f6 ff ff       	jmp    80106e60 <alltraps>

801077e8 <vector94>:
.globl vector94
vector94:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $94
801077ea:	6a 5e                	push   $0x5e
  jmp alltraps
801077ec:	e9 6f f6 ff ff       	jmp    80106e60 <alltraps>

801077f1 <vector95>:
.globl vector95
vector95:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $95
801077f3:	6a 5f                	push   $0x5f
  jmp alltraps
801077f5:	e9 66 f6 ff ff       	jmp    80106e60 <alltraps>

801077fa <vector96>:
.globl vector96
vector96:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $96
801077fc:	6a 60                	push   $0x60
  jmp alltraps
801077fe:	e9 5d f6 ff ff       	jmp    80106e60 <alltraps>

80107803 <vector97>:
.globl vector97
vector97:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $97
80107805:	6a 61                	push   $0x61
  jmp alltraps
80107807:	e9 54 f6 ff ff       	jmp    80106e60 <alltraps>

8010780c <vector98>:
.globl vector98
vector98:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $98
8010780e:	6a 62                	push   $0x62
  jmp alltraps
80107810:	e9 4b f6 ff ff       	jmp    80106e60 <alltraps>

80107815 <vector99>:
.globl vector99
vector99:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $99
80107817:	6a 63                	push   $0x63
  jmp alltraps
80107819:	e9 42 f6 ff ff       	jmp    80106e60 <alltraps>

8010781e <vector100>:
.globl vector100
vector100:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $100
80107820:	6a 64                	push   $0x64
  jmp alltraps
80107822:	e9 39 f6 ff ff       	jmp    80106e60 <alltraps>

80107827 <vector101>:
.globl vector101
vector101:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $101
80107829:	6a 65                	push   $0x65
  jmp alltraps
8010782b:	e9 30 f6 ff ff       	jmp    80106e60 <alltraps>

80107830 <vector102>:
.globl vector102
vector102:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $102
80107832:	6a 66                	push   $0x66
  jmp alltraps
80107834:	e9 27 f6 ff ff       	jmp    80106e60 <alltraps>

80107839 <vector103>:
.globl vector103
vector103:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $103
8010783b:	6a 67                	push   $0x67
  jmp alltraps
8010783d:	e9 1e f6 ff ff       	jmp    80106e60 <alltraps>

80107842 <vector104>:
.globl vector104
vector104:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $104
80107844:	6a 68                	push   $0x68
  jmp alltraps
80107846:	e9 15 f6 ff ff       	jmp    80106e60 <alltraps>

8010784b <vector105>:
.globl vector105
vector105:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $105
8010784d:	6a 69                	push   $0x69
  jmp alltraps
8010784f:	e9 0c f6 ff ff       	jmp    80106e60 <alltraps>

80107854 <vector106>:
.globl vector106
vector106:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $106
80107856:	6a 6a                	push   $0x6a
  jmp alltraps
80107858:	e9 03 f6 ff ff       	jmp    80106e60 <alltraps>

8010785d <vector107>:
.globl vector107
vector107:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $107
8010785f:	6a 6b                	push   $0x6b
  jmp alltraps
80107861:	e9 fa f5 ff ff       	jmp    80106e60 <alltraps>

80107866 <vector108>:
.globl vector108
vector108:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $108
80107868:	6a 6c                	push   $0x6c
  jmp alltraps
8010786a:	e9 f1 f5 ff ff       	jmp    80106e60 <alltraps>

8010786f <vector109>:
.globl vector109
vector109:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $109
80107871:	6a 6d                	push   $0x6d
  jmp alltraps
80107873:	e9 e8 f5 ff ff       	jmp    80106e60 <alltraps>

80107878 <vector110>:
.globl vector110
vector110:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $110
8010787a:	6a 6e                	push   $0x6e
  jmp alltraps
8010787c:	e9 df f5 ff ff       	jmp    80106e60 <alltraps>

80107881 <vector111>:
.globl vector111
vector111:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $111
80107883:	6a 6f                	push   $0x6f
  jmp alltraps
80107885:	e9 d6 f5 ff ff       	jmp    80106e60 <alltraps>

8010788a <vector112>:
.globl vector112
vector112:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $112
8010788c:	6a 70                	push   $0x70
  jmp alltraps
8010788e:	e9 cd f5 ff ff       	jmp    80106e60 <alltraps>

80107893 <vector113>:
.globl vector113
vector113:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $113
80107895:	6a 71                	push   $0x71
  jmp alltraps
80107897:	e9 c4 f5 ff ff       	jmp    80106e60 <alltraps>

8010789c <vector114>:
.globl vector114
vector114:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $114
8010789e:	6a 72                	push   $0x72
  jmp alltraps
801078a0:	e9 bb f5 ff ff       	jmp    80106e60 <alltraps>

801078a5 <vector115>:
.globl vector115
vector115:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $115
801078a7:	6a 73                	push   $0x73
  jmp alltraps
801078a9:	e9 b2 f5 ff ff       	jmp    80106e60 <alltraps>

801078ae <vector116>:
.globl vector116
vector116:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $116
801078b0:	6a 74                	push   $0x74
  jmp alltraps
801078b2:	e9 a9 f5 ff ff       	jmp    80106e60 <alltraps>

801078b7 <vector117>:
.globl vector117
vector117:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $117
801078b9:	6a 75                	push   $0x75
  jmp alltraps
801078bb:	e9 a0 f5 ff ff       	jmp    80106e60 <alltraps>

801078c0 <vector118>:
.globl vector118
vector118:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $118
801078c2:	6a 76                	push   $0x76
  jmp alltraps
801078c4:	e9 97 f5 ff ff       	jmp    80106e60 <alltraps>

801078c9 <vector119>:
.globl vector119
vector119:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $119
801078cb:	6a 77                	push   $0x77
  jmp alltraps
801078cd:	e9 8e f5 ff ff       	jmp    80106e60 <alltraps>

801078d2 <vector120>:
.globl vector120
vector120:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $120
801078d4:	6a 78                	push   $0x78
  jmp alltraps
801078d6:	e9 85 f5 ff ff       	jmp    80106e60 <alltraps>

801078db <vector121>:
.globl vector121
vector121:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $121
801078dd:	6a 79                	push   $0x79
  jmp alltraps
801078df:	e9 7c f5 ff ff       	jmp    80106e60 <alltraps>

801078e4 <vector122>:
.globl vector122
vector122:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $122
801078e6:	6a 7a                	push   $0x7a
  jmp alltraps
801078e8:	e9 73 f5 ff ff       	jmp    80106e60 <alltraps>

801078ed <vector123>:
.globl vector123
vector123:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $123
801078ef:	6a 7b                	push   $0x7b
  jmp alltraps
801078f1:	e9 6a f5 ff ff       	jmp    80106e60 <alltraps>

801078f6 <vector124>:
.globl vector124
vector124:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $124
801078f8:	6a 7c                	push   $0x7c
  jmp alltraps
801078fa:	e9 61 f5 ff ff       	jmp    80106e60 <alltraps>

801078ff <vector125>:
.globl vector125
vector125:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $125
80107901:	6a 7d                	push   $0x7d
  jmp alltraps
80107903:	e9 58 f5 ff ff       	jmp    80106e60 <alltraps>

80107908 <vector126>:
.globl vector126
vector126:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $126
8010790a:	6a 7e                	push   $0x7e
  jmp alltraps
8010790c:	e9 4f f5 ff ff       	jmp    80106e60 <alltraps>

80107911 <vector127>:
.globl vector127
vector127:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $127
80107913:	6a 7f                	push   $0x7f
  jmp alltraps
80107915:	e9 46 f5 ff ff       	jmp    80106e60 <alltraps>

8010791a <vector128>:
.globl vector128
vector128:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $128
8010791c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107921:	e9 3a f5 ff ff       	jmp    80106e60 <alltraps>

80107926 <vector129>:
.globl vector129
vector129:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $129
80107928:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010792d:	e9 2e f5 ff ff       	jmp    80106e60 <alltraps>

80107932 <vector130>:
.globl vector130
vector130:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $130
80107934:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107939:	e9 22 f5 ff ff       	jmp    80106e60 <alltraps>

8010793e <vector131>:
.globl vector131
vector131:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $131
80107940:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107945:	e9 16 f5 ff ff       	jmp    80106e60 <alltraps>

8010794a <vector132>:
.globl vector132
vector132:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $132
8010794c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107951:	e9 0a f5 ff ff       	jmp    80106e60 <alltraps>

80107956 <vector133>:
.globl vector133
vector133:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $133
80107958:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010795d:	e9 fe f4 ff ff       	jmp    80106e60 <alltraps>

80107962 <vector134>:
.globl vector134
vector134:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $134
80107964:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107969:	e9 f2 f4 ff ff       	jmp    80106e60 <alltraps>

8010796e <vector135>:
.globl vector135
vector135:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $135
80107970:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107975:	e9 e6 f4 ff ff       	jmp    80106e60 <alltraps>

8010797a <vector136>:
.globl vector136
vector136:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $136
8010797c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107981:	e9 da f4 ff ff       	jmp    80106e60 <alltraps>

80107986 <vector137>:
.globl vector137
vector137:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $137
80107988:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010798d:	e9 ce f4 ff ff       	jmp    80106e60 <alltraps>

80107992 <vector138>:
.globl vector138
vector138:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $138
80107994:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107999:	e9 c2 f4 ff ff       	jmp    80106e60 <alltraps>

8010799e <vector139>:
.globl vector139
vector139:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $139
801079a0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801079a5:	e9 b6 f4 ff ff       	jmp    80106e60 <alltraps>

801079aa <vector140>:
.globl vector140
vector140:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $140
801079ac:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801079b1:	e9 aa f4 ff ff       	jmp    80106e60 <alltraps>

801079b6 <vector141>:
.globl vector141
vector141:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $141
801079b8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801079bd:	e9 9e f4 ff ff       	jmp    80106e60 <alltraps>

801079c2 <vector142>:
.globl vector142
vector142:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $142
801079c4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801079c9:	e9 92 f4 ff ff       	jmp    80106e60 <alltraps>

801079ce <vector143>:
.globl vector143
vector143:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $143
801079d0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801079d5:	e9 86 f4 ff ff       	jmp    80106e60 <alltraps>

801079da <vector144>:
.globl vector144
vector144:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $144
801079dc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801079e1:	e9 7a f4 ff ff       	jmp    80106e60 <alltraps>

801079e6 <vector145>:
.globl vector145
vector145:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $145
801079e8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801079ed:	e9 6e f4 ff ff       	jmp    80106e60 <alltraps>

801079f2 <vector146>:
.globl vector146
vector146:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $146
801079f4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801079f9:	e9 62 f4 ff ff       	jmp    80106e60 <alltraps>

801079fe <vector147>:
.globl vector147
vector147:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $147
80107a00:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107a05:	e9 56 f4 ff ff       	jmp    80106e60 <alltraps>

80107a0a <vector148>:
.globl vector148
vector148:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $148
80107a0c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107a11:	e9 4a f4 ff ff       	jmp    80106e60 <alltraps>

80107a16 <vector149>:
.globl vector149
vector149:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $149
80107a18:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107a1d:	e9 3e f4 ff ff       	jmp    80106e60 <alltraps>

80107a22 <vector150>:
.globl vector150
vector150:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $150
80107a24:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107a29:	e9 32 f4 ff ff       	jmp    80106e60 <alltraps>

80107a2e <vector151>:
.globl vector151
vector151:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $151
80107a30:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107a35:	e9 26 f4 ff ff       	jmp    80106e60 <alltraps>

80107a3a <vector152>:
.globl vector152
vector152:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $152
80107a3c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107a41:	e9 1a f4 ff ff       	jmp    80106e60 <alltraps>

80107a46 <vector153>:
.globl vector153
vector153:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $153
80107a48:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107a4d:	e9 0e f4 ff ff       	jmp    80106e60 <alltraps>

80107a52 <vector154>:
.globl vector154
vector154:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $154
80107a54:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107a59:	e9 02 f4 ff ff       	jmp    80106e60 <alltraps>

80107a5e <vector155>:
.globl vector155
vector155:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $155
80107a60:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107a65:	e9 f6 f3 ff ff       	jmp    80106e60 <alltraps>

80107a6a <vector156>:
.globl vector156
vector156:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $156
80107a6c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107a71:	e9 ea f3 ff ff       	jmp    80106e60 <alltraps>

80107a76 <vector157>:
.globl vector157
vector157:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $157
80107a78:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107a7d:	e9 de f3 ff ff       	jmp    80106e60 <alltraps>

80107a82 <vector158>:
.globl vector158
vector158:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $158
80107a84:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107a89:	e9 d2 f3 ff ff       	jmp    80106e60 <alltraps>

80107a8e <vector159>:
.globl vector159
vector159:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $159
80107a90:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107a95:	e9 c6 f3 ff ff       	jmp    80106e60 <alltraps>

80107a9a <vector160>:
.globl vector160
vector160:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $160
80107a9c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107aa1:	e9 ba f3 ff ff       	jmp    80106e60 <alltraps>

80107aa6 <vector161>:
.globl vector161
vector161:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $161
80107aa8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107aad:	e9 ae f3 ff ff       	jmp    80106e60 <alltraps>

80107ab2 <vector162>:
.globl vector162
vector162:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $162
80107ab4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107ab9:	e9 a2 f3 ff ff       	jmp    80106e60 <alltraps>

80107abe <vector163>:
.globl vector163
vector163:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $163
80107ac0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107ac5:	e9 96 f3 ff ff       	jmp    80106e60 <alltraps>

80107aca <vector164>:
.globl vector164
vector164:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $164
80107acc:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107ad1:	e9 8a f3 ff ff       	jmp    80106e60 <alltraps>

80107ad6 <vector165>:
.globl vector165
vector165:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $165
80107ad8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107add:	e9 7e f3 ff ff       	jmp    80106e60 <alltraps>

80107ae2 <vector166>:
.globl vector166
vector166:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $166
80107ae4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ae9:	e9 72 f3 ff ff       	jmp    80106e60 <alltraps>

80107aee <vector167>:
.globl vector167
vector167:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $167
80107af0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107af5:	e9 66 f3 ff ff       	jmp    80106e60 <alltraps>

80107afa <vector168>:
.globl vector168
vector168:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $168
80107afc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107b01:	e9 5a f3 ff ff       	jmp    80106e60 <alltraps>

80107b06 <vector169>:
.globl vector169
vector169:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $169
80107b08:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107b0d:	e9 4e f3 ff ff       	jmp    80106e60 <alltraps>

80107b12 <vector170>:
.globl vector170
vector170:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $170
80107b14:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107b19:	e9 42 f3 ff ff       	jmp    80106e60 <alltraps>

80107b1e <vector171>:
.globl vector171
vector171:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $171
80107b20:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107b25:	e9 36 f3 ff ff       	jmp    80106e60 <alltraps>

80107b2a <vector172>:
.globl vector172
vector172:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $172
80107b2c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107b31:	e9 2a f3 ff ff       	jmp    80106e60 <alltraps>

80107b36 <vector173>:
.globl vector173
vector173:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $173
80107b38:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107b3d:	e9 1e f3 ff ff       	jmp    80106e60 <alltraps>

80107b42 <vector174>:
.globl vector174
vector174:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $174
80107b44:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107b49:	e9 12 f3 ff ff       	jmp    80106e60 <alltraps>

80107b4e <vector175>:
.globl vector175
vector175:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $175
80107b50:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107b55:	e9 06 f3 ff ff       	jmp    80106e60 <alltraps>

80107b5a <vector176>:
.globl vector176
vector176:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $176
80107b5c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107b61:	e9 fa f2 ff ff       	jmp    80106e60 <alltraps>

80107b66 <vector177>:
.globl vector177
vector177:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $177
80107b68:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107b6d:	e9 ee f2 ff ff       	jmp    80106e60 <alltraps>

80107b72 <vector178>:
.globl vector178
vector178:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $178
80107b74:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107b79:	e9 e2 f2 ff ff       	jmp    80106e60 <alltraps>

80107b7e <vector179>:
.globl vector179
vector179:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $179
80107b80:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107b85:	e9 d6 f2 ff ff       	jmp    80106e60 <alltraps>

80107b8a <vector180>:
.globl vector180
vector180:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $180
80107b8c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107b91:	e9 ca f2 ff ff       	jmp    80106e60 <alltraps>

80107b96 <vector181>:
.globl vector181
vector181:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $181
80107b98:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107b9d:	e9 be f2 ff ff       	jmp    80106e60 <alltraps>

80107ba2 <vector182>:
.globl vector182
vector182:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $182
80107ba4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107ba9:	e9 b2 f2 ff ff       	jmp    80106e60 <alltraps>

80107bae <vector183>:
.globl vector183
vector183:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $183
80107bb0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107bb5:	e9 a6 f2 ff ff       	jmp    80106e60 <alltraps>

80107bba <vector184>:
.globl vector184
vector184:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $184
80107bbc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107bc1:	e9 9a f2 ff ff       	jmp    80106e60 <alltraps>

80107bc6 <vector185>:
.globl vector185
vector185:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $185
80107bc8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107bcd:	e9 8e f2 ff ff       	jmp    80106e60 <alltraps>

80107bd2 <vector186>:
.globl vector186
vector186:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $186
80107bd4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107bd9:	e9 82 f2 ff ff       	jmp    80106e60 <alltraps>

80107bde <vector187>:
.globl vector187
vector187:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $187
80107be0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107be5:	e9 76 f2 ff ff       	jmp    80106e60 <alltraps>

80107bea <vector188>:
.globl vector188
vector188:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $188
80107bec:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107bf1:	e9 6a f2 ff ff       	jmp    80106e60 <alltraps>

80107bf6 <vector189>:
.globl vector189
vector189:
  pushl $0
80107bf6:	6a 00                	push   $0x0
  pushl $189
80107bf8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107bfd:	e9 5e f2 ff ff       	jmp    80106e60 <alltraps>

80107c02 <vector190>:
.globl vector190
vector190:
  pushl $0
80107c02:	6a 00                	push   $0x0
  pushl $190
80107c04:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107c09:	e9 52 f2 ff ff       	jmp    80106e60 <alltraps>

80107c0e <vector191>:
.globl vector191
vector191:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $191
80107c10:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107c15:	e9 46 f2 ff ff       	jmp    80106e60 <alltraps>

80107c1a <vector192>:
.globl vector192
vector192:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $192
80107c1c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107c21:	e9 3a f2 ff ff       	jmp    80106e60 <alltraps>

80107c26 <vector193>:
.globl vector193
vector193:
  pushl $0
80107c26:	6a 00                	push   $0x0
  pushl $193
80107c28:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107c2d:	e9 2e f2 ff ff       	jmp    80106e60 <alltraps>

80107c32 <vector194>:
.globl vector194
vector194:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $194
80107c34:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107c39:	e9 22 f2 ff ff       	jmp    80106e60 <alltraps>

80107c3e <vector195>:
.globl vector195
vector195:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $195
80107c40:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107c45:	e9 16 f2 ff ff       	jmp    80106e60 <alltraps>

80107c4a <vector196>:
.globl vector196
vector196:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $196
80107c4c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107c51:	e9 0a f2 ff ff       	jmp    80106e60 <alltraps>

80107c56 <vector197>:
.globl vector197
vector197:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $197
80107c58:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107c5d:	e9 fe f1 ff ff       	jmp    80106e60 <alltraps>

80107c62 <vector198>:
.globl vector198
vector198:
  pushl $0
80107c62:	6a 00                	push   $0x0
  pushl $198
80107c64:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107c69:	e9 f2 f1 ff ff       	jmp    80106e60 <alltraps>

80107c6e <vector199>:
.globl vector199
vector199:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $199
80107c70:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107c75:	e9 e6 f1 ff ff       	jmp    80106e60 <alltraps>

80107c7a <vector200>:
.globl vector200
vector200:
  pushl $0
80107c7a:	6a 00                	push   $0x0
  pushl $200
80107c7c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107c81:	e9 da f1 ff ff       	jmp    80106e60 <alltraps>

80107c86 <vector201>:
.globl vector201
vector201:
  pushl $0
80107c86:	6a 00                	push   $0x0
  pushl $201
80107c88:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107c8d:	e9 ce f1 ff ff       	jmp    80106e60 <alltraps>

80107c92 <vector202>:
.globl vector202
vector202:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $202
80107c94:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107c99:	e9 c2 f1 ff ff       	jmp    80106e60 <alltraps>

80107c9e <vector203>:
.globl vector203
vector203:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $203
80107ca0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107ca5:	e9 b6 f1 ff ff       	jmp    80106e60 <alltraps>

80107caa <vector204>:
.globl vector204
vector204:
  pushl $0
80107caa:	6a 00                	push   $0x0
  pushl $204
80107cac:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107cb1:	e9 aa f1 ff ff       	jmp    80106e60 <alltraps>

80107cb6 <vector205>:
.globl vector205
vector205:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $205
80107cb8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107cbd:	e9 9e f1 ff ff       	jmp    80106e60 <alltraps>

80107cc2 <vector206>:
.globl vector206
vector206:
  pushl $0
80107cc2:	6a 00                	push   $0x0
  pushl $206
80107cc4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107cc9:	e9 92 f1 ff ff       	jmp    80106e60 <alltraps>

80107cce <vector207>:
.globl vector207
vector207:
  pushl $0
80107cce:	6a 00                	push   $0x0
  pushl $207
80107cd0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107cd5:	e9 86 f1 ff ff       	jmp    80106e60 <alltraps>

80107cda <vector208>:
.globl vector208
vector208:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $208
80107cdc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107ce1:	e9 7a f1 ff ff       	jmp    80106e60 <alltraps>

80107ce6 <vector209>:
.globl vector209
vector209:
  pushl $0
80107ce6:	6a 00                	push   $0x0
  pushl $209
80107ce8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107ced:	e9 6e f1 ff ff       	jmp    80106e60 <alltraps>

80107cf2 <vector210>:
.globl vector210
vector210:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $210
80107cf4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107cf9:	e9 62 f1 ff ff       	jmp    80106e60 <alltraps>

80107cfe <vector211>:
.globl vector211
vector211:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $211
80107d00:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107d05:	e9 56 f1 ff ff       	jmp    80106e60 <alltraps>

80107d0a <vector212>:
.globl vector212
vector212:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $212
80107d0c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107d11:	e9 4a f1 ff ff       	jmp    80106e60 <alltraps>

80107d16 <vector213>:
.globl vector213
vector213:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $213
80107d18:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107d1d:	e9 3e f1 ff ff       	jmp    80106e60 <alltraps>

80107d22 <vector214>:
.globl vector214
vector214:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $214
80107d24:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107d29:	e9 32 f1 ff ff       	jmp    80106e60 <alltraps>

80107d2e <vector215>:
.globl vector215
vector215:
  pushl $0
80107d2e:	6a 00                	push   $0x0
  pushl $215
80107d30:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107d35:	e9 26 f1 ff ff       	jmp    80106e60 <alltraps>

80107d3a <vector216>:
.globl vector216
vector216:
  pushl $0
80107d3a:	6a 00                	push   $0x0
  pushl $216
80107d3c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107d41:	e9 1a f1 ff ff       	jmp    80106e60 <alltraps>

80107d46 <vector217>:
.globl vector217
vector217:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $217
80107d48:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107d4d:	e9 0e f1 ff ff       	jmp    80106e60 <alltraps>

80107d52 <vector218>:
.globl vector218
vector218:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $218
80107d54:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107d59:	e9 02 f1 ff ff       	jmp    80106e60 <alltraps>

80107d5e <vector219>:
.globl vector219
vector219:
  pushl $0
80107d5e:	6a 00                	push   $0x0
  pushl $219
80107d60:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107d65:	e9 f6 f0 ff ff       	jmp    80106e60 <alltraps>

80107d6a <vector220>:
.globl vector220
vector220:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $220
80107d6c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107d71:	e9 ea f0 ff ff       	jmp    80106e60 <alltraps>

80107d76 <vector221>:
.globl vector221
vector221:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $221
80107d78:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107d7d:	e9 de f0 ff ff       	jmp    80106e60 <alltraps>

80107d82 <vector222>:
.globl vector222
vector222:
  pushl $0
80107d82:	6a 00                	push   $0x0
  pushl $222
80107d84:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107d89:	e9 d2 f0 ff ff       	jmp    80106e60 <alltraps>

80107d8e <vector223>:
.globl vector223
vector223:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $223
80107d90:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107d95:	e9 c6 f0 ff ff       	jmp    80106e60 <alltraps>

80107d9a <vector224>:
.globl vector224
vector224:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $224
80107d9c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107da1:	e9 ba f0 ff ff       	jmp    80106e60 <alltraps>

80107da6 <vector225>:
.globl vector225
vector225:
  pushl $0
80107da6:	6a 00                	push   $0x0
  pushl $225
80107da8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107dad:	e9 ae f0 ff ff       	jmp    80106e60 <alltraps>

80107db2 <vector226>:
.globl vector226
vector226:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $226
80107db4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107db9:	e9 a2 f0 ff ff       	jmp    80106e60 <alltraps>

80107dbe <vector227>:
.globl vector227
vector227:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $227
80107dc0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107dc5:	e9 96 f0 ff ff       	jmp    80106e60 <alltraps>

80107dca <vector228>:
.globl vector228
vector228:
  pushl $0
80107dca:	6a 00                	push   $0x0
  pushl $228
80107dcc:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107dd1:	e9 8a f0 ff ff       	jmp    80106e60 <alltraps>

80107dd6 <vector229>:
.globl vector229
vector229:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $229
80107dd8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107ddd:	e9 7e f0 ff ff       	jmp    80106e60 <alltraps>

80107de2 <vector230>:
.globl vector230
vector230:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $230
80107de4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107de9:	e9 72 f0 ff ff       	jmp    80106e60 <alltraps>

80107dee <vector231>:
.globl vector231
vector231:
  pushl $0
80107dee:	6a 00                	push   $0x0
  pushl $231
80107df0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107df5:	e9 66 f0 ff ff       	jmp    80106e60 <alltraps>

80107dfa <vector232>:
.globl vector232
vector232:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $232
80107dfc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107e01:	e9 5a f0 ff ff       	jmp    80106e60 <alltraps>

80107e06 <vector233>:
.globl vector233
vector233:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $233
80107e08:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107e0d:	e9 4e f0 ff ff       	jmp    80106e60 <alltraps>

80107e12 <vector234>:
.globl vector234
vector234:
  pushl $0
80107e12:	6a 00                	push   $0x0
  pushl $234
80107e14:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107e19:	e9 42 f0 ff ff       	jmp    80106e60 <alltraps>

80107e1e <vector235>:
.globl vector235
vector235:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $235
80107e20:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107e25:	e9 36 f0 ff ff       	jmp    80106e60 <alltraps>

80107e2a <vector236>:
.globl vector236
vector236:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $236
80107e2c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107e31:	e9 2a f0 ff ff       	jmp    80106e60 <alltraps>

80107e36 <vector237>:
.globl vector237
vector237:
  pushl $0
80107e36:	6a 00                	push   $0x0
  pushl $237
80107e38:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107e3d:	e9 1e f0 ff ff       	jmp    80106e60 <alltraps>

80107e42 <vector238>:
.globl vector238
vector238:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $238
80107e44:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107e49:	e9 12 f0 ff ff       	jmp    80106e60 <alltraps>

80107e4e <vector239>:
.globl vector239
vector239:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $239
80107e50:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107e55:	e9 06 f0 ff ff       	jmp    80106e60 <alltraps>

80107e5a <vector240>:
.globl vector240
vector240:
  pushl $0
80107e5a:	6a 00                	push   $0x0
  pushl $240
80107e5c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107e61:	e9 fa ef ff ff       	jmp    80106e60 <alltraps>

80107e66 <vector241>:
.globl vector241
vector241:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $241
80107e68:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107e6d:	e9 ee ef ff ff       	jmp    80106e60 <alltraps>

80107e72 <vector242>:
.globl vector242
vector242:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $242
80107e74:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107e79:	e9 e2 ef ff ff       	jmp    80106e60 <alltraps>

80107e7e <vector243>:
.globl vector243
vector243:
  pushl $0
80107e7e:	6a 00                	push   $0x0
  pushl $243
80107e80:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107e85:	e9 d6 ef ff ff       	jmp    80106e60 <alltraps>

80107e8a <vector244>:
.globl vector244
vector244:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $244
80107e8c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107e91:	e9 ca ef ff ff       	jmp    80106e60 <alltraps>

80107e96 <vector245>:
.globl vector245
vector245:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $245
80107e98:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107e9d:	e9 be ef ff ff       	jmp    80106e60 <alltraps>

80107ea2 <vector246>:
.globl vector246
vector246:
  pushl $0
80107ea2:	6a 00                	push   $0x0
  pushl $246
80107ea4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107ea9:	e9 b2 ef ff ff       	jmp    80106e60 <alltraps>

80107eae <vector247>:
.globl vector247
vector247:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $247
80107eb0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107eb5:	e9 a6 ef ff ff       	jmp    80106e60 <alltraps>

80107eba <vector248>:
.globl vector248
vector248:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $248
80107ebc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107ec1:	e9 9a ef ff ff       	jmp    80106e60 <alltraps>

80107ec6 <vector249>:
.globl vector249
vector249:
  pushl $0
80107ec6:	6a 00                	push   $0x0
  pushl $249
80107ec8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107ecd:	e9 8e ef ff ff       	jmp    80106e60 <alltraps>

80107ed2 <vector250>:
.globl vector250
vector250:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $250
80107ed4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ed9:	e9 82 ef ff ff       	jmp    80106e60 <alltraps>

80107ede <vector251>:
.globl vector251
vector251:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $251
80107ee0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ee5:	e9 76 ef ff ff       	jmp    80106e60 <alltraps>

80107eea <vector252>:
.globl vector252
vector252:
  pushl $0
80107eea:	6a 00                	push   $0x0
  pushl $252
80107eec:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107ef1:	e9 6a ef ff ff       	jmp    80106e60 <alltraps>

80107ef6 <vector253>:
.globl vector253
vector253:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $253
80107ef8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107efd:	e9 5e ef ff ff       	jmp    80106e60 <alltraps>

80107f02 <vector254>:
.globl vector254
vector254:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $254
80107f04:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107f09:	e9 52 ef ff ff       	jmp    80106e60 <alltraps>

80107f0e <vector255>:
.globl vector255
vector255:
  pushl $0
80107f0e:	6a 00                	push   $0x0
  pushl $255
80107f10:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107f15:	e9 46 ef ff ff       	jmp    80106e60 <alltraps>
	...

80107f1c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107f1c:	55                   	push   %ebp
80107f1d:	89 e5                	mov    %esp,%ebp
80107f1f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f25:	48                   	dec    %eax
80107f26:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107f31:	8b 45 08             	mov    0x8(%ebp),%eax
80107f34:	c1 e8 10             	shr    $0x10,%eax
80107f37:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107f3b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107f3e:	0f 01 10             	lgdtl  (%eax)
}
80107f41:	c9                   	leave  
80107f42:	c3                   	ret    

80107f43 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107f43:	55                   	push   %ebp
80107f44:	89 e5                	mov    %esp,%ebp
80107f46:	83 ec 04             	sub    $0x4,%esp
80107f49:	8b 45 08             	mov    0x8(%ebp),%eax
80107f4c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107f50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f53:	0f 00 d8             	ltr    %ax
}
80107f56:	c9                   	leave  
80107f57:	c3                   	ret    

80107f58 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107f58:	55                   	push   %ebp
80107f59:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f5e:	0f 22 d8             	mov    %eax,%cr3
}
80107f61:	5d                   	pop    %ebp
80107f62:	c3                   	ret    

80107f63 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107f63:	55                   	push   %ebp
80107f64:	89 e5                	mov    %esp,%ebp
80107f66:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107f69:	e8 6c c3 ff ff       	call   801042da <cpuid>
80107f6e:	89 c2                	mov    %eax,%edx
80107f70:	89 d0                	mov    %edx,%eax
80107f72:	c1 e0 02             	shl    $0x2,%eax
80107f75:	01 d0                	add    %edx,%eax
80107f77:	01 c0                	add    %eax,%eax
80107f79:	01 d0                	add    %edx,%eax
80107f7b:	c1 e0 04             	shl    $0x4,%eax
80107f7e:	05 80 4c 11 80       	add    $0x80114c80,%eax
80107f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f89:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f92:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa2:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fa5:	83 e2 f0             	and    $0xfffffff0,%edx
80107fa8:	83 ca 0a             	or     $0xa,%edx
80107fab:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb1:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fb4:	83 ca 10             	or     $0x10,%edx
80107fb7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbd:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fc0:	83 e2 9f             	and    $0xffffff9f,%edx
80107fc3:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc9:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fcc:	83 ca 80             	or     $0xffffff80,%edx
80107fcf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd5:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fd8:	83 ca 0f             	or     $0xf,%edx
80107fdb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe1:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fe4:	83 e2 ef             	and    $0xffffffef,%edx
80107fe7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fed:	8a 50 7e             	mov    0x7e(%eax),%dl
80107ff0:	83 e2 df             	and    $0xffffffdf,%edx
80107ff3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff9:	8a 50 7e             	mov    0x7e(%eax),%dl
80107ffc:	83 ca 40             	or     $0x40,%edx
80107fff:	88 50 7e             	mov    %dl,0x7e(%eax)
80108002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108005:	8a 50 7e             	mov    0x7e(%eax),%dl
80108008:	83 ca 80             	or     $0xffffff80,%edx
8010800b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010800e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108011:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108018:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010801f:	ff ff 
80108021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108024:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010802b:	00 00 
8010802d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108030:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108040:	83 e2 f0             	and    $0xfffffff0,%edx
80108043:	83 ca 02             	or     $0x2,%edx
80108046:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010804c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108055:	83 ca 10             	or     $0x10,%edx
80108058:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010805e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108061:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108067:	83 e2 9f             	and    $0xffffff9f,%edx
8010806a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108073:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108079:	83 ca 80             	or     $0xffffff80,%edx
8010807c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108085:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010808b:	83 ca 0f             	or     $0xf,%edx
8010808e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108097:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010809d:	83 e2 ef             	and    $0xffffffef,%edx
801080a0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801080af:	83 e2 df             	and    $0xffffffdf,%edx
801080b2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bb:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801080c1:	83 ca 40             	or     $0x40,%edx
801080c4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cd:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801080d3:	83 ca 80             	or     $0xffffff80,%edx
801080d6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080df:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801080e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e9:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801080f0:	ff ff 
801080f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f5:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801080fc:	00 00 
801080fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108101:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80108108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810b:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108111:	83 e2 f0             	and    $0xfffffff0,%edx
80108114:	83 ca 0a             	or     $0xa,%edx
80108117:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010811d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108120:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108126:	83 ca 10             	or     $0x10,%edx
80108129:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010812f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108132:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108138:	83 ca 60             	or     $0x60,%edx
8010813b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108144:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010814a:	83 ca 80             	or     $0xffffff80,%edx
8010814d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108156:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010815c:	83 ca 0f             	or     $0xf,%edx
8010815f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108168:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010816e:	83 e2 ef             	and    $0xffffffef,%edx
80108171:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108180:	83 e2 df             	and    $0xffffffdf,%edx
80108183:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108192:	83 ca 40             	or     $0x40,%edx
80108195:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010819b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801081a4:	83 ca 80             	or     $0xffffff80,%edx
801081a7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801081ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801081b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ba:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801081c1:	ff ff 
801081c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801081cd:	00 00 
801081cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801081d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dc:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081e2:	83 e2 f0             	and    $0xfffffff0,%edx
801081e5:	83 ca 02             	or     $0x2,%edx
801081e8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f1:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081f7:	83 ca 10             	or     $0x10,%edx
801081fa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108203:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108209:	83 ca 60             	or     $0x60,%edx
8010820c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108215:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010821b:	83 ca 80             	or     $0xffffff80,%edx
8010821e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108227:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010822d:	83 ca 0f             	or     $0xf,%edx
80108230:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108239:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010823f:	83 e2 ef             	and    $0xffffffef,%edx
80108242:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108251:	83 e2 df             	and    $0xffffffdf,%edx
80108254:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010825a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108263:	83 ca 40             	or     $0x40,%edx
80108266:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010826c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108275:	83 ca 80             	or     $0xffffff80,%edx
80108278:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010827e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108281:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828b:	83 c0 70             	add    $0x70,%eax
8010828e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108295:	00 
80108296:	89 04 24             	mov    %eax,(%esp)
80108299:	e8 7e fc ff ff       	call   80107f1c <lgdt>
}
8010829e:	c9                   	leave  
8010829f:	c3                   	ret    

801082a0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801082a0:	55                   	push   %ebp
801082a1:	89 e5                	mov    %esp,%ebp
801082a3:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801082a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801082a9:	c1 e8 16             	shr    $0x16,%eax
801082ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082b3:	8b 45 08             	mov    0x8(%ebp),%eax
801082b6:	01 d0                	add    %edx,%eax
801082b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801082bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082be:	8b 00                	mov    (%eax),%eax
801082c0:	83 e0 01             	and    $0x1,%eax
801082c3:	85 c0                	test   %eax,%eax
801082c5:	74 14                	je     801082db <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801082c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ca:	8b 00                	mov    (%eax),%eax
801082cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082d1:	05 00 00 00 80       	add    $0x80000000,%eax
801082d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082d9:	eb 48                	jmp    80108323 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801082db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801082df:	74 0e                	je     801082ef <walkpgdir+0x4f>
801082e1:	e8 b1 aa ff ff       	call   80102d97 <kalloc>
801082e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082ed:	75 07                	jne    801082f6 <walkpgdir+0x56>
      return 0;
801082ef:	b8 00 00 00 00       	mov    $0x0,%eax
801082f4:	eb 44                	jmp    8010833a <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801082f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082fd:	00 
801082fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108305:	00 
80108306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108309:	89 04 24             	mov    %eax,(%esp)
8010830c:	e8 f5 d1 ff ff       	call   80105506 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108314:	05 00 00 00 80       	add    $0x80000000,%eax
80108319:	83 c8 07             	or     $0x7,%eax
8010831c:	89 c2                	mov    %eax,%edx
8010831e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108321:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108323:	8b 45 0c             	mov    0xc(%ebp),%eax
80108326:	c1 e8 0c             	shr    $0xc,%eax
80108329:	25 ff 03 00 00       	and    $0x3ff,%eax
8010832e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108338:	01 d0                	add    %edx,%eax
}
8010833a:	c9                   	leave  
8010833b:	c3                   	ret    

8010833c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010833c:	55                   	push   %ebp
8010833d:	89 e5                	mov    %esp,%ebp
8010833f:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108342:	8b 45 0c             	mov    0xc(%ebp),%eax
80108345:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010834a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010834d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108350:	8b 45 10             	mov    0x10(%ebp),%eax
80108353:	01 d0                	add    %edx,%eax
80108355:	48                   	dec    %eax
80108356:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010835b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010835e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108365:	00 
80108366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108369:	89 44 24 04          	mov    %eax,0x4(%esp)
8010836d:	8b 45 08             	mov    0x8(%ebp),%eax
80108370:	89 04 24             	mov    %eax,(%esp)
80108373:	e8 28 ff ff ff       	call   801082a0 <walkpgdir>
80108378:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010837b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010837f:	75 07                	jne    80108388 <mappages+0x4c>
      return -1;
80108381:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108386:	eb 48                	jmp    801083d0 <mappages+0x94>
    if(*pte & PTE_P)
80108388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838b:	8b 00                	mov    (%eax),%eax
8010838d:	83 e0 01             	and    $0x1,%eax
80108390:	85 c0                	test   %eax,%eax
80108392:	74 0c                	je     801083a0 <mappages+0x64>
      panic("remap");
80108394:	c7 04 24 30 9b 10 80 	movl   $0x80109b30,(%esp)
8010839b:	e8 b4 81 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
801083a0:	8b 45 18             	mov    0x18(%ebp),%eax
801083a3:	0b 45 14             	or     0x14(%ebp),%eax
801083a6:	83 c8 01             	or     $0x1,%eax
801083a9:	89 c2                	mov    %eax,%edx
801083ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ae:	89 10                	mov    %edx,(%eax)
    if(a == last)
801083b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083b6:	75 08                	jne    801083c0 <mappages+0x84>
      break;
801083b8:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801083b9:	b8 00 00 00 00       	mov    $0x0,%eax
801083be:	eb 10                	jmp    801083d0 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801083c0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801083c7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801083ce:	eb 8e                	jmp    8010835e <mappages+0x22>
  return 0;
}
801083d0:	c9                   	leave  
801083d1:	c3                   	ret    

801083d2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801083d2:	55                   	push   %ebp
801083d3:	89 e5                	mov    %esp,%ebp
801083d5:	53                   	push   %ebx
801083d6:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801083d9:	e8 b9 a9 ff ff       	call   80102d97 <kalloc>
801083de:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083e5:	75 0a                	jne    801083f1 <setupkvm+0x1f>
    return 0;
801083e7:	b8 00 00 00 00       	mov    $0x0,%eax
801083ec:	e9 84 00 00 00       	jmp    80108475 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801083f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083f8:	00 
801083f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108400:	00 
80108401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108404:	89 04 24             	mov    %eax,(%esp)
80108407:	e8 fa d0 ff ff       	call   80105506 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010840c:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
80108413:	eb 54                	jmp    80108469 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	8b 48 0c             	mov    0xc(%eax),%ecx
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	8b 50 04             	mov    0x4(%eax),%edx
80108421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108424:	8b 58 08             	mov    0x8(%eax),%ebx
80108427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842a:	8b 40 04             	mov    0x4(%eax),%eax
8010842d:	29 c3                	sub    %eax,%ebx
8010842f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108432:	8b 00                	mov    (%eax),%eax
80108434:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108438:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010843c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108440:	89 44 24 04          	mov    %eax,0x4(%esp)
80108444:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108447:	89 04 24             	mov    %eax,(%esp)
8010844a:	e8 ed fe ff ff       	call   8010833c <mappages>
8010844f:	85 c0                	test   %eax,%eax
80108451:	79 12                	jns    80108465 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80108453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108456:	89 04 24             	mov    %eax,(%esp)
80108459:	e8 1a 05 00 00       	call   80108978 <freevm>
      return 0;
8010845e:	b8 00 00 00 00       	mov    $0x0,%eax
80108463:	eb 10                	jmp    80108475 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108465:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108469:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
80108470:	72 a3                	jb     80108415 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108472:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108475:	83 c4 34             	add    $0x34,%esp
80108478:	5b                   	pop    %ebx
80108479:	5d                   	pop    %ebp
8010847a:	c3                   	ret    

8010847b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010847b:	55                   	push   %ebp
8010847c:	89 e5                	mov    %esp,%ebp
8010847e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108481:	e8 4c ff ff ff       	call   801083d2 <setupkvm>
80108486:	a3 a4 7b 11 80       	mov    %eax,0x80117ba4
  switchkvm();
8010848b:	e8 02 00 00 00       	call   80108492 <switchkvm>
}
80108490:	c9                   	leave  
80108491:	c3                   	ret    

80108492 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108492:	55                   	push   %ebp
80108493:	89 e5                	mov    %esp,%ebp
80108495:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108498:	a1 a4 7b 11 80       	mov    0x80117ba4,%eax
8010849d:	05 00 00 00 80       	add    $0x80000000,%eax
801084a2:	89 04 24             	mov    %eax,(%esp)
801084a5:	e8 ae fa ff ff       	call   80107f58 <lcr3>
}
801084aa:	c9                   	leave  
801084ab:	c3                   	ret    

801084ac <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801084ac:	55                   	push   %ebp
801084ad:	89 e5                	mov    %esp,%ebp
801084af:	57                   	push   %edi
801084b0:	56                   	push   %esi
801084b1:	53                   	push   %ebx
801084b2:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
801084b5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084b9:	75 0c                	jne    801084c7 <switchuvm+0x1b>
    panic("switchuvm: no process");
801084bb:	c7 04 24 36 9b 10 80 	movl   $0x80109b36,(%esp)
801084c2:	e8 8d 80 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
801084c7:	8b 45 08             	mov    0x8(%ebp),%eax
801084ca:	8b 40 08             	mov    0x8(%eax),%eax
801084cd:	85 c0                	test   %eax,%eax
801084cf:	75 0c                	jne    801084dd <switchuvm+0x31>
    panic("switchuvm: no kstack");
801084d1:	c7 04 24 4c 9b 10 80 	movl   $0x80109b4c,(%esp)
801084d8:	e8 77 80 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801084dd:	8b 45 08             	mov    0x8(%ebp),%eax
801084e0:	8b 40 04             	mov    0x4(%eax),%eax
801084e3:	85 c0                	test   %eax,%eax
801084e5:	75 0c                	jne    801084f3 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801084e7:	c7 04 24 61 9b 10 80 	movl   $0x80109b61,(%esp)
801084ee:	e8 61 80 ff ff       	call   80100554 <panic>

  pushcli();
801084f3:	e8 0a cf ff ff       	call   80105402 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801084f8:	e8 22 be ff ff       	call   8010431f <mycpu>
801084fd:	89 c3                	mov    %eax,%ebx
801084ff:	e8 1b be ff ff       	call   8010431f <mycpu>
80108504:	83 c0 08             	add    $0x8,%eax
80108507:	89 c6                	mov    %eax,%esi
80108509:	e8 11 be ff ff       	call   8010431f <mycpu>
8010850e:	83 c0 08             	add    $0x8,%eax
80108511:	c1 e8 10             	shr    $0x10,%eax
80108514:	89 c7                	mov    %eax,%edi
80108516:	e8 04 be ff ff       	call   8010431f <mycpu>
8010851b:	83 c0 08             	add    $0x8,%eax
8010851e:	c1 e8 18             	shr    $0x18,%eax
80108521:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108528:	67 00 
8010852a:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108531:	89 f9                	mov    %edi,%ecx
80108533:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108539:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010853f:	83 e2 f0             	and    $0xfffffff0,%edx
80108542:	83 ca 09             	or     $0x9,%edx
80108545:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010854b:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108551:	83 ca 10             	or     $0x10,%edx
80108554:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010855a:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108560:	83 e2 9f             	and    $0xffffff9f,%edx
80108563:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108569:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010856f:	83 ca 80             	or     $0xffffff80,%edx
80108572:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108578:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010857e:	83 e2 f0             	and    $0xfffffff0,%edx
80108581:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108587:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010858d:	83 e2 ef             	and    $0xffffffef,%edx
80108590:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108596:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010859c:	83 e2 df             	and    $0xffffffdf,%edx
8010859f:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801085a5:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801085ab:	83 ca 40             	or     $0x40,%edx
801085ae:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801085b4:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801085ba:	83 e2 7f             	and    $0x7f,%edx
801085bd:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801085c3:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801085c9:	e8 51 bd ff ff       	call   8010431f <mycpu>
801085ce:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801085d4:	83 e2 ef             	and    $0xffffffef,%edx
801085d7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801085dd:	e8 3d bd ff ff       	call   8010431f <mycpu>
801085e2:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801085e8:	e8 32 bd ff ff       	call   8010431f <mycpu>
801085ed:	8b 55 08             	mov    0x8(%ebp),%edx
801085f0:	8b 52 08             	mov    0x8(%edx),%edx
801085f3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801085f9:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801085fc:	e8 1e bd ff ff       	call   8010431f <mycpu>
80108601:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108607:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
8010860e:	e8 30 f9 ff ff       	call   80107f43 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108613:	8b 45 08             	mov    0x8(%ebp),%eax
80108616:	8b 40 04             	mov    0x4(%eax),%eax
80108619:	05 00 00 00 80       	add    $0x80000000,%eax
8010861e:	89 04 24             	mov    %eax,(%esp)
80108621:	e8 32 f9 ff ff       	call   80107f58 <lcr3>
  popcli();
80108626:	e8 21 ce ff ff       	call   8010544c <popcli>
}
8010862b:	83 c4 1c             	add    $0x1c,%esp
8010862e:	5b                   	pop    %ebx
8010862f:	5e                   	pop    %esi
80108630:	5f                   	pop    %edi
80108631:	5d                   	pop    %ebp
80108632:	c3                   	ret    

80108633 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108633:	55                   	push   %ebp
80108634:	89 e5                	mov    %esp,%ebp
80108636:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108639:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108640:	76 0c                	jbe    8010864e <inituvm+0x1b>
    panic("inituvm: more than a page");
80108642:	c7 04 24 75 9b 10 80 	movl   $0x80109b75,(%esp)
80108649:	e8 06 7f ff ff       	call   80100554 <panic>
  mem = kalloc();
8010864e:	e8 44 a7 ff ff       	call   80102d97 <kalloc>
80108653:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108656:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010865d:	00 
8010865e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108665:	00 
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	89 04 24             	mov    %eax,(%esp)
8010866c:	e8 95 ce ff ff       	call   80105506 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108674:	05 00 00 00 80       	add    $0x80000000,%eax
80108679:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108680:	00 
80108681:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108685:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010868c:	00 
8010868d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108694:	00 
80108695:	8b 45 08             	mov    0x8(%ebp),%eax
80108698:	89 04 24             	mov    %eax,(%esp)
8010869b:	e8 9c fc ff ff       	call   8010833c <mappages>
  memmove(mem, init, sz);
801086a0:	8b 45 10             	mov    0x10(%ebp),%eax
801086a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801086a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801086aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801086ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b1:	89 04 24             	mov    %eax,(%esp)
801086b4:	e8 16 cf ff ff       	call   801055cf <memmove>
}
801086b9:	c9                   	leave  
801086ba:	c3                   	ret    

801086bb <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801086bb:	55                   	push   %ebp
801086bc:	89 e5                	mov    %esp,%ebp
801086be:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801086c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086c4:	25 ff 0f 00 00       	and    $0xfff,%eax
801086c9:	85 c0                	test   %eax,%eax
801086cb:	74 0c                	je     801086d9 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
801086cd:	c7 04 24 90 9b 10 80 	movl   $0x80109b90,(%esp)
801086d4:	e8 7b 7e ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801086d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086e0:	e9 a6 00 00 00       	jmp    8010878b <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801086e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801086eb:	01 d0                	add    %edx,%eax
801086ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086f4:	00 
801086f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801086f9:	8b 45 08             	mov    0x8(%ebp),%eax
801086fc:	89 04 24             	mov    %eax,(%esp)
801086ff:	e8 9c fb ff ff       	call   801082a0 <walkpgdir>
80108704:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108707:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010870b:	75 0c                	jne    80108719 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
8010870d:	c7 04 24 b3 9b 10 80 	movl   $0x80109bb3,(%esp)
80108714:	e8 3b 7e ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108719:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871c:	8b 00                	mov    (%eax),%eax
8010871e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108723:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108729:	8b 55 18             	mov    0x18(%ebp),%edx
8010872c:	29 c2                	sub    %eax,%edx
8010872e:	89 d0                	mov    %edx,%eax
80108730:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108735:	77 0f                	ja     80108746 <loaduvm+0x8b>
      n = sz - i;
80108737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873a:	8b 55 18             	mov    0x18(%ebp),%edx
8010873d:	29 c2                	sub    %eax,%edx
8010873f:	89 d0                	mov    %edx,%eax
80108741:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108744:	eb 07                	jmp    8010874d <loaduvm+0x92>
    else
      n = PGSIZE;
80108746:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010874d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108750:	8b 55 14             	mov    0x14(%ebp),%edx
80108753:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108756:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108759:	05 00 00 00 80       	add    $0x80000000,%eax
8010875e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108761:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108765:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108769:	89 44 24 04          	mov    %eax,0x4(%esp)
8010876d:	8b 45 10             	mov    0x10(%ebp),%eax
80108770:	89 04 24             	mov    %eax,(%esp)
80108773:	e8 e1 97 ff ff       	call   80101f59 <readi>
80108778:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010877b:	74 07                	je     80108784 <loaduvm+0xc9>
      return -1;
8010877d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108782:	eb 18                	jmp    8010879c <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108784:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010878b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108791:	0f 82 4e ff ff ff    	jb     801086e5 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108797:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010879c:	c9                   	leave  
8010879d:	c3                   	ret    

8010879e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010879e:	55                   	push   %ebp
8010879f:	89 e5                	mov    %esp,%ebp
801087a1:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801087a4:	8b 45 10             	mov    0x10(%ebp),%eax
801087a7:	85 c0                	test   %eax,%eax
801087a9:	79 0a                	jns    801087b5 <allocuvm+0x17>
    return 0;
801087ab:	b8 00 00 00 00       	mov    $0x0,%eax
801087b0:	e9 fd 00 00 00       	jmp    801088b2 <allocuvm+0x114>
  if(newsz < oldsz)
801087b5:	8b 45 10             	mov    0x10(%ebp),%eax
801087b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087bb:	73 08                	jae    801087c5 <allocuvm+0x27>
    return oldsz;
801087bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c0:	e9 ed 00 00 00       	jmp    801088b2 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801087c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c8:	05 ff 0f 00 00       	add    $0xfff,%eax
801087cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801087d5:	e9 c9 00 00 00       	jmp    801088a3 <allocuvm+0x105>
    mem = kalloc();
801087da:	e8 b8 a5 ff ff       	call   80102d97 <kalloc>
801087df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801087e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087e6:	75 2f                	jne    80108817 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801087e8:	c7 04 24 d1 9b 10 80 	movl   $0x80109bd1,(%esp)
801087ef:	e8 cd 7b ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801087f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801087f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801087fb:	8b 45 10             	mov    0x10(%ebp),%eax
801087fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80108802:	8b 45 08             	mov    0x8(%ebp),%eax
80108805:	89 04 24             	mov    %eax,(%esp)
80108808:	e8 a7 00 00 00       	call   801088b4 <deallocuvm>
      return 0;
8010880d:	b8 00 00 00 00       	mov    $0x0,%eax
80108812:	e9 9b 00 00 00       	jmp    801088b2 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108817:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010881e:	00 
8010881f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108826:	00 
80108827:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882a:	89 04 24             	mov    %eax,(%esp)
8010882d:	e8 d4 cc ff ff       	call   80105506 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108835:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010883b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108845:	00 
80108846:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010884a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108851:	00 
80108852:	89 44 24 04          	mov    %eax,0x4(%esp)
80108856:	8b 45 08             	mov    0x8(%ebp),%eax
80108859:	89 04 24             	mov    %eax,(%esp)
8010885c:	e8 db fa ff ff       	call   8010833c <mappages>
80108861:	85 c0                	test   %eax,%eax
80108863:	79 37                	jns    8010889c <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108865:	c7 04 24 e9 9b 10 80 	movl   $0x80109be9,(%esp)
8010886c:	e8 50 7b ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108871:	8b 45 0c             	mov    0xc(%ebp),%eax
80108874:	89 44 24 08          	mov    %eax,0x8(%esp)
80108878:	8b 45 10             	mov    0x10(%ebp),%eax
8010887b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010887f:	8b 45 08             	mov    0x8(%ebp),%eax
80108882:	89 04 24             	mov    %eax,(%esp)
80108885:	e8 2a 00 00 00       	call   801088b4 <deallocuvm>
      kfree(mem);
8010888a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010888d:	89 04 24             	mov    %eax,(%esp)
80108890:	e8 30 a4 ff ff       	call   80102cc5 <kfree>
      return 0;
80108895:	b8 00 00 00 00       	mov    $0x0,%eax
8010889a:	eb 16                	jmp    801088b2 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010889c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801088a9:	0f 82 2b ff ff ff    	jb     801087da <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
801088af:	8b 45 10             	mov    0x10(%ebp),%eax
}
801088b2:	c9                   	leave  
801088b3:	c3                   	ret    

801088b4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801088b4:	55                   	push   %ebp
801088b5:	89 e5                	mov    %esp,%ebp
801088b7:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801088ba:	8b 45 10             	mov    0x10(%ebp),%eax
801088bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088c0:	72 08                	jb     801088ca <deallocuvm+0x16>
    return oldsz;
801088c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801088c5:	e9 ac 00 00 00       	jmp    80108976 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801088ca:	8b 45 10             	mov    0x10(%ebp),%eax
801088cd:	05 ff 0f 00 00       	add    $0xfff,%eax
801088d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801088da:	e9 88 00 00 00       	jmp    80108967 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801088df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088e9:	00 
801088ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801088ee:	8b 45 08             	mov    0x8(%ebp),%eax
801088f1:	89 04 24             	mov    %eax,(%esp)
801088f4:	e8 a7 f9 ff ff       	call   801082a0 <walkpgdir>
801088f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801088fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108900:	75 14                	jne    80108916 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108905:	c1 e8 16             	shr    $0x16,%eax
80108908:	40                   	inc    %eax
80108909:	c1 e0 16             	shl    $0x16,%eax
8010890c:	2d 00 10 00 00       	sub    $0x1000,%eax
80108911:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108914:	eb 4a                	jmp    80108960 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108919:	8b 00                	mov    (%eax),%eax
8010891b:	83 e0 01             	and    $0x1,%eax
8010891e:	85 c0                	test   %eax,%eax
80108920:	74 3e                	je     80108960 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108925:	8b 00                	mov    (%eax),%eax
80108927:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010892c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010892f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108933:	75 0c                	jne    80108941 <deallocuvm+0x8d>
        panic("kfree");
80108935:	c7 04 24 05 9c 10 80 	movl   $0x80109c05,(%esp)
8010893c:	e8 13 7c ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108941:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108944:	05 00 00 00 80       	add    $0x80000000,%eax
80108949:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010894c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010894f:	89 04 24             	mov    %eax,(%esp)
80108952:	e8 6e a3 ff ff       	call   80102cc5 <kfree>
      *pte = 0;
80108957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010895a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108960:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010896d:	0f 82 6c ff ff ff    	jb     801088df <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108973:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108976:	c9                   	leave  
80108977:	c3                   	ret    

80108978 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108978:	55                   	push   %ebp
80108979:	89 e5                	mov    %esp,%ebp
8010897b:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010897e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108982:	75 0c                	jne    80108990 <freevm+0x18>
    panic("freevm: no pgdir");
80108984:	c7 04 24 0b 9c 10 80 	movl   $0x80109c0b,(%esp)
8010898b:	e8 c4 7b ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108990:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108997:	00 
80108998:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010899f:	80 
801089a0:	8b 45 08             	mov    0x8(%ebp),%eax
801089a3:	89 04 24             	mov    %eax,(%esp)
801089a6:	e8 09 ff ff ff       	call   801088b4 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801089ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089b2:	eb 44                	jmp    801089f8 <freevm+0x80>
    if(pgdir[i] & PTE_P){
801089b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089be:	8b 45 08             	mov    0x8(%ebp),%eax
801089c1:	01 d0                	add    %edx,%eax
801089c3:	8b 00                	mov    (%eax),%eax
801089c5:	83 e0 01             	and    $0x1,%eax
801089c8:	85 c0                	test   %eax,%eax
801089ca:	74 29                	je     801089f5 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801089cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089d6:	8b 45 08             	mov    0x8(%ebp),%eax
801089d9:	01 d0                	add    %edx,%eax
801089db:	8b 00                	mov    (%eax),%eax
801089dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089e2:	05 00 00 00 80       	add    $0x80000000,%eax
801089e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801089ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ed:	89 04 24             	mov    %eax,(%esp)
801089f0:	e8 d0 a2 ff ff       	call   80102cc5 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801089f5:	ff 45 f4             	incl   -0xc(%ebp)
801089f8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801089ff:	76 b3                	jbe    801089b4 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108a01:	8b 45 08             	mov    0x8(%ebp),%eax
80108a04:	89 04 24             	mov    %eax,(%esp)
80108a07:	e8 b9 a2 ff ff       	call   80102cc5 <kfree>
}
80108a0c:	c9                   	leave  
80108a0d:	c3                   	ret    

80108a0e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108a0e:	55                   	push   %ebp
80108a0f:	89 e5                	mov    %esp,%ebp
80108a11:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108a14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a1b:	00 
80108a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a23:	8b 45 08             	mov    0x8(%ebp),%eax
80108a26:	89 04 24             	mov    %eax,(%esp)
80108a29:	e8 72 f8 ff ff       	call   801082a0 <walkpgdir>
80108a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108a31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a35:	75 0c                	jne    80108a43 <clearpteu+0x35>
    panic("clearpteu");
80108a37:	c7 04 24 1c 9c 10 80 	movl   $0x80109c1c,(%esp)
80108a3e:	e8 11 7b ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a46:	8b 00                	mov    (%eax),%eax
80108a48:	83 e0 fb             	and    $0xfffffffb,%eax
80108a4b:	89 c2                	mov    %eax,%edx
80108a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a50:	89 10                	mov    %edx,(%eax)
}
80108a52:	c9                   	leave  
80108a53:	c3                   	ret    

80108a54 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108a54:	55                   	push   %ebp
80108a55:	89 e5                	mov    %esp,%ebp
80108a57:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108a5a:	e8 73 f9 ff ff       	call   801083d2 <setupkvm>
80108a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a66:	75 0a                	jne    80108a72 <copyuvm+0x1e>
    return 0;
80108a68:	b8 00 00 00 00       	mov    $0x0,%eax
80108a6d:	e9 f8 00 00 00       	jmp    80108b6a <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108a72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a79:	e9 cb 00 00 00       	jmp    80108b49 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a88:	00 
80108a89:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80108a90:	89 04 24             	mov    %eax,(%esp)
80108a93:	e8 08 f8 ff ff       	call   801082a0 <walkpgdir>
80108a98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a9f:	75 0c                	jne    80108aad <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108aa1:	c7 04 24 26 9c 10 80 	movl   $0x80109c26,(%esp)
80108aa8:	e8 a7 7a ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab0:	8b 00                	mov    (%eax),%eax
80108ab2:	83 e0 01             	and    $0x1,%eax
80108ab5:	85 c0                	test   %eax,%eax
80108ab7:	75 0c                	jne    80108ac5 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108ab9:	c7 04 24 40 9c 10 80 	movl   $0x80109c40,(%esp)
80108ac0:	e8 8f 7a ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108ac5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac8:	8b 00                	mov    (%eax),%eax
80108aca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108acf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ad5:	8b 00                	mov    (%eax),%eax
80108ad7:	25 ff 0f 00 00       	and    $0xfff,%eax
80108adc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108adf:	e8 b3 a2 ff ff       	call   80102d97 <kalloc>
80108ae4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108ae7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108aeb:	75 02                	jne    80108aef <copyuvm+0x9b>
      goto bad;
80108aed:	eb 6b                	jmp    80108b5a <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108aef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108af2:	05 00 00 00 80       	add    $0x80000000,%eax
80108af7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108afe:	00 
80108aff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b06:	89 04 24             	mov    %eax,(%esp)
80108b09:	e8 c1 ca ff ff       	call   801055cf <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108b0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b14:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1d:	89 54 24 10          	mov    %edx,0x10(%esp)
80108b21:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108b25:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b2c:	00 
80108b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b34:	89 04 24             	mov    %eax,(%esp)
80108b37:	e8 00 f8 ff ff       	call   8010833c <mappages>
80108b3c:	85 c0                	test   %eax,%eax
80108b3e:	79 02                	jns    80108b42 <copyuvm+0xee>
      goto bad;
80108b40:	eb 18                	jmp    80108b5a <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108b42:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b4f:	0f 82 29 ff ff ff    	jb     80108a7e <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b58:	eb 10                	jmp    80108b6a <copyuvm+0x116>

bad:
  freevm(d);
80108b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b5d:	89 04 24             	mov    %eax,(%esp)
80108b60:	e8 13 fe ff ff       	call   80108978 <freevm>
  return 0;
80108b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b6a:	c9                   	leave  
80108b6b:	c3                   	ret    

80108b6c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108b6c:	55                   	push   %ebp
80108b6d:	89 e5                	mov    %esp,%ebp
80108b6f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b79:	00 
80108b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b81:	8b 45 08             	mov    0x8(%ebp),%eax
80108b84:	89 04 24             	mov    %eax,(%esp)
80108b87:	e8 14 f7 ff ff       	call   801082a0 <walkpgdir>
80108b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b92:	8b 00                	mov    (%eax),%eax
80108b94:	83 e0 01             	and    $0x1,%eax
80108b97:	85 c0                	test   %eax,%eax
80108b99:	75 07                	jne    80108ba2 <uva2ka+0x36>
    return 0;
80108b9b:	b8 00 00 00 00       	mov    $0x0,%eax
80108ba0:	eb 22                	jmp    80108bc4 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba5:	8b 00                	mov    (%eax),%eax
80108ba7:	83 e0 04             	and    $0x4,%eax
80108baa:	85 c0                	test   %eax,%eax
80108bac:	75 07                	jne    80108bb5 <uva2ka+0x49>
    return 0;
80108bae:	b8 00 00 00 00       	mov    $0x0,%eax
80108bb3:	eb 0f                	jmp    80108bc4 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb8:	8b 00                	mov    (%eax),%eax
80108bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bbf:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108bc4:	c9                   	leave  
80108bc5:	c3                   	ret    

80108bc6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108bc6:	55                   	push   %ebp
80108bc7:	89 e5                	mov    %esp,%ebp
80108bc9:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108bcc:	8b 45 10             	mov    0x10(%ebp),%eax
80108bcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108bd2:	e9 87 00 00 00       	jmp    80108c5e <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108be2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be5:	89 44 24 04          	mov    %eax,0x4(%esp)
80108be9:	8b 45 08             	mov    0x8(%ebp),%eax
80108bec:	89 04 24             	mov    %eax,(%esp)
80108bef:	e8 78 ff ff ff       	call   80108b6c <uva2ka>
80108bf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108bf7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108bfb:	75 07                	jne    80108c04 <copyout+0x3e>
      return -1;
80108bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c02:	eb 69                	jmp    80108c6d <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108c04:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c07:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108c0a:	29 c2                	sub    %eax,%edx
80108c0c:	89 d0                	mov    %edx,%eax
80108c0e:	05 00 10 00 00       	add    $0x1000,%eax
80108c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c19:	3b 45 14             	cmp    0x14(%ebp),%eax
80108c1c:	76 06                	jbe    80108c24 <copyout+0x5e>
      n = len;
80108c1e:	8b 45 14             	mov    0x14(%ebp),%eax
80108c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c27:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c2a:	29 c2                	sub    %eax,%edx
80108c2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c2f:	01 c2                	add    %eax,%edx
80108c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c34:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c3f:	89 14 24             	mov    %edx,(%esp)
80108c42:	e8 88 c9 ff ff       	call   801055cf <memmove>
    len -= n;
80108c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c4a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c50:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c56:	05 00 10 00 00       	add    $0x1000,%eax
80108c5b:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108c5e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108c62:	0f 85 6f ff ff ff    	jne    80108bd7 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c6d:	c9                   	leave  
80108c6e:	c3                   	ret    
	...

80108c70 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80108c70:	55                   	push   %ebp
80108c71:	89 e5                	mov    %esp,%ebp
80108c73:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
80108c76:	8b 45 10             	mov    0x10(%ebp),%eax
80108c79:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c80:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c84:	8b 45 08             	mov    0x8(%ebp),%eax
80108c87:	89 04 24             	mov    %eax,(%esp)
80108c8a:	e8 40 c9 ff ff       	call   801055cf <memmove>
}
80108c8f:	c9                   	leave  
80108c90:	c3                   	ret    

80108c91 <strcpy>:

char* strcpy(char *s, char *t){
80108c91:	55                   	push   %ebp
80108c92:	89 e5                	mov    %esp,%ebp
80108c94:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108c97:	8b 45 08             	mov    0x8(%ebp),%eax
80108c9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108c9d:	90                   	nop
80108c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca1:	8d 50 01             	lea    0x1(%eax),%edx
80108ca4:	89 55 08             	mov    %edx,0x8(%ebp)
80108ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
80108caa:	8d 4a 01             	lea    0x1(%edx),%ecx
80108cad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108cb0:	8a 12                	mov    (%edx),%dl
80108cb2:	88 10                	mov    %dl,(%eax)
80108cb4:	8a 00                	mov    (%eax),%al
80108cb6:	84 c0                	test   %al,%al
80108cb8:	75 e4                	jne    80108c9e <strcpy+0xd>
    ;
  return os;
80108cba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108cbd:	c9                   	leave  
80108cbe:	c3                   	ret    

80108cbf <strcmp>:

int
strcmp(const char *p, const char *q)
{
80108cbf:	55                   	push   %ebp
80108cc0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108cc2:	eb 06                	jmp    80108cca <strcmp+0xb>
    p++, q++;
80108cc4:	ff 45 08             	incl   0x8(%ebp)
80108cc7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
80108cca:	8b 45 08             	mov    0x8(%ebp),%eax
80108ccd:	8a 00                	mov    (%eax),%al
80108ccf:	84 c0                	test   %al,%al
80108cd1:	74 0e                	je     80108ce1 <strcmp+0x22>
80108cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd6:	8a 10                	mov    (%eax),%dl
80108cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cdb:	8a 00                	mov    (%eax),%al
80108cdd:	38 c2                	cmp    %al,%dl
80108cdf:	74 e3                	je     80108cc4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80108ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce4:	8a 00                	mov    (%eax),%al
80108ce6:	0f b6 d0             	movzbl %al,%edx
80108ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cec:	8a 00                	mov    (%eax),%al
80108cee:	0f b6 c0             	movzbl %al,%eax
80108cf1:	29 c2                	sub    %eax,%edx
80108cf3:	89 d0                	mov    %edx,%eax
}
80108cf5:	5d                   	pop    %ebp
80108cf6:	c3                   	ret    

80108cf7 <set_root_inode>:

// struct con

void set_root_inode(char* name){
80108cf7:	55                   	push   %ebp
80108cf8:	89 e5                	mov    %esp,%ebp
80108cfa:	53                   	push   %ebx
80108cfb:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
80108cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80108d01:	89 04 24             	mov    %eax,(%esp)
80108d04:	e8 02 01 00 00       	call   80108e0b <find>
80108d09:	89 c3                	mov    %eax,%ebx
80108d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d0e:	89 04 24             	mov    %eax,(%esp)
80108d11:	e8 3a 99 ff ff       	call   80102650 <namei>
80108d16:	89 c2                	mov    %eax,%edx
80108d18:	89 d8                	mov    %ebx,%eax
80108d1a:	01 c0                	add    %eax,%eax
80108d1c:	01 d8                	add    %ebx,%eax
80108d1e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80108d25:	01 c8                	add    %ecx,%eax
80108d27:	c1 e0 02             	shl    $0x2,%eax
80108d2a:	05 f0 7b 11 80       	add    $0x80117bf0,%eax
80108d2f:	89 50 08             	mov    %edx,0x8(%eax)

}
80108d32:	83 c4 14             	add    $0x14,%esp
80108d35:	5b                   	pop    %ebx
80108d36:	5d                   	pop    %ebp
80108d37:	c3                   	ret    

80108d38 <get_name>:

void get_name(int vc_num, char* name){
80108d38:	55                   	push   %ebp
80108d39:	89 e5                	mov    %esp,%ebp
80108d3b:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80108d3e:	8b 55 08             	mov    0x8(%ebp),%edx
80108d41:	89 d0                	mov    %edx,%eax
80108d43:	01 c0                	add    %eax,%eax
80108d45:	01 d0                	add    %edx,%eax
80108d47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d4e:	01 d0                	add    %edx,%eax
80108d50:	c1 e0 02             	shl    $0x2,%eax
80108d53:	83 c0 10             	add    $0x10,%eax
80108d56:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d5b:	83 c0 08             	add    $0x8,%eax
80108d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80108d61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
80108d68:	eb 03                	jmp    80108d6d <get_name+0x35>
	{
		i++;
80108d6a:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80108d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d73:	01 d0                	add    %edx,%eax
80108d75:	8a 00                	mov    (%eax),%al
80108d77:	84 c0                	test   %al,%al
80108d79:	75 ef                	jne    80108d6a <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80108d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d8c:	89 04 24             	mov    %eax,(%esp)
80108d8f:	e8 dc fe ff ff       	call   80108c70 <memcpy2>
}
80108d94:	c9                   	leave  
80108d95:	c3                   	ret    

80108d96 <g_name>:

char* g_name(int vc_bun){
80108d96:	55                   	push   %ebp
80108d97:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
80108d99:	8b 55 08             	mov    0x8(%ebp),%edx
80108d9c:	89 d0                	mov    %edx,%eax
80108d9e:	01 c0                	add    %eax,%eax
80108da0:	01 d0                	add    %edx,%eax
80108da2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108da9:	01 d0                	add    %edx,%eax
80108dab:	c1 e0 02             	shl    $0x2,%eax
80108dae:	83 c0 10             	add    $0x10,%eax
80108db1:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108db6:	83 c0 08             	add    $0x8,%eax
}
80108db9:	5d                   	pop    %ebp
80108dba:	c3                   	ret    

80108dbb <is_full>:

int is_full(){
80108dbb:	55                   	push   %ebp
80108dbc:	89 e5                	mov    %esp,%ebp
80108dbe:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108dc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108dc8:	eb 34                	jmp    80108dfe <is_full+0x43>
		if(strlen(containers[i].name) == 0){
80108dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108dcd:	89 d0                	mov    %edx,%eax
80108dcf:	01 c0                	add    %eax,%eax
80108dd1:	01 d0                	add    %edx,%eax
80108dd3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108dda:	01 d0                	add    %edx,%eax
80108ddc:	c1 e0 02             	shl    $0x2,%eax
80108ddf:	83 c0 10             	add    $0x10,%eax
80108de2:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108de7:	83 c0 08             	add    $0x8,%eax
80108dea:	89 04 24             	mov    %eax,(%esp)
80108ded:	e8 67 c9 ff ff       	call   80105759 <strlen>
80108df2:	85 c0                	test   %eax,%eax
80108df4:	75 05                	jne    80108dfb <is_full+0x40>
			return i;
80108df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df9:	eb 0e                	jmp    80108e09 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108dfb:	ff 45 f4             	incl   -0xc(%ebp)
80108dfe:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80108e02:	7e c6                	jle    80108dca <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108e09:	c9                   	leave  
80108e0a:	c3                   	ret    

80108e0b <find>:

int find(char* name){
80108e0b:	55                   	push   %ebp
80108e0c:	89 e5                	mov    %esp,%ebp
80108e0e:	83 ec 18             	sub    $0x18,%esp
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108e11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108e18:	eb 54                	jmp    80108e6e <find+0x63>
		if(strcmp(name, "") == 0){
80108e1a:	c7 44 24 04 5c 9c 10 	movl   $0x80109c5c,0x4(%esp)
80108e21:	80 
80108e22:	8b 45 08             	mov    0x8(%ebp),%eax
80108e25:	89 04 24             	mov    %eax,(%esp)
80108e28:	e8 92 fe ff ff       	call   80108cbf <strcmp>
80108e2d:	85 c0                	test   %eax,%eax
80108e2f:	75 02                	jne    80108e33 <find+0x28>
			continue;
80108e31:	eb 38                	jmp    80108e6b <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80108e33:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108e36:	89 d0                	mov    %edx,%eax
80108e38:	01 c0                	add    %eax,%eax
80108e3a:	01 d0                	add    %edx,%eax
80108e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e43:	01 d0                	add    %edx,%eax
80108e45:	c1 e0 02             	shl    $0x2,%eax
80108e48:	83 c0 10             	add    $0x10,%eax
80108e4b:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e50:	83 c0 08             	add    $0x8,%eax
80108e53:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e57:	8b 45 08             	mov    0x8(%ebp),%eax
80108e5a:	89 04 24             	mov    %eax,(%esp)
80108e5d:	e8 5d fe ff ff       	call   80108cbf <strcmp>
80108e62:	85 c0                	test   %eax,%eax
80108e64:	75 05                	jne    80108e6b <find+0x60>
			//cprintf("in hereI");
			return i;
80108e66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108e69:	eb 0e                	jmp    80108e79 <find+0x6e>
}

int find(char* name){
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108e6b:	ff 45 fc             	incl   -0x4(%ebp)
80108e6e:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108e72:	7e a6                	jle    80108e1a <find+0xf>
		if(strcmp(name, containers[i].name) == 0){
			//cprintf("in hereI");
			return i;
		}
	}
	return -1;
80108e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108e79:	c9                   	leave  
80108e7a:	c3                   	ret    

80108e7b <get_max_proc>:

int get_max_proc(int vc_num){
80108e7b:	55                   	push   %ebp
80108e7c:	89 e5                	mov    %esp,%ebp
80108e7e:	57                   	push   %edi
80108e7f:	56                   	push   %esi
80108e80:	53                   	push   %ebx
80108e81:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108e84:	8b 55 08             	mov    0x8(%ebp),%edx
80108e87:	89 d0                	mov    %edx,%eax
80108e89:	01 c0                	add    %eax,%eax
80108e8b:	01 d0                	add    %edx,%eax
80108e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e94:	01 d0                	add    %edx,%eax
80108e96:	c1 e0 02             	shl    $0x2,%eax
80108e99:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e9e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108ea1:	89 c3                	mov    %eax,%ebx
80108ea3:	b8 0f 00 00 00       	mov    $0xf,%eax
80108ea8:	89 d7                	mov    %edx,%edi
80108eaa:	89 de                	mov    %ebx,%esi
80108eac:	89 c1                	mov    %eax,%ecx
80108eae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108eb0:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80108eb3:	83 c4 40             	add    $0x40,%esp
80108eb6:	5b                   	pop    %ebx
80108eb7:	5e                   	pop    %esi
80108eb8:	5f                   	pop    %edi
80108eb9:	5d                   	pop    %ebp
80108eba:	c3                   	ret    

80108ebb <get_container>:

struct container* get_container(int vc_num){
80108ebb:	55                   	push   %ebp
80108ebc:	89 e5                	mov    %esp,%ebp
80108ebe:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80108ec1:	8b 55 08             	mov    0x8(%ebp),%edx
80108ec4:	89 d0                	mov    %edx,%eax
80108ec6:	01 c0                	add    %eax,%eax
80108ec8:	01 d0                	add    %edx,%eax
80108eca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ed1:	01 d0                	add    %edx,%eax
80108ed3:	c1 e0 02             	shl    $0x2,%eax
80108ed6:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108edb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	// cprintf("vc num given is %d\n.", vc_num);
	// cprintf("The name for this container is %s.\n", cont->name);
	return cont;
80108ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108ee1:	c9                   	leave  
80108ee2:	c3                   	ret    

80108ee3 <get_max_mem>:

int get_max_mem(int vc_num){
80108ee3:	55                   	push   %ebp
80108ee4:	89 e5                	mov    %esp,%ebp
80108ee6:	57                   	push   %edi
80108ee7:	56                   	push   %esi
80108ee8:	53                   	push   %ebx
80108ee9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108eec:	8b 55 08             	mov    0x8(%ebp),%edx
80108eef:	89 d0                	mov    %edx,%eax
80108ef1:	01 c0                	add    %eax,%eax
80108ef3:	01 d0                	add    %edx,%eax
80108ef5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108efc:	01 d0                	add    %edx,%eax
80108efe:	c1 e0 02             	shl    $0x2,%eax
80108f01:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f06:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108f09:	89 c3                	mov    %eax,%ebx
80108f0b:	b8 0f 00 00 00       	mov    $0xf,%eax
80108f10:	89 d7                	mov    %edx,%edi
80108f12:	89 de                	mov    %ebx,%esi
80108f14:	89 c1                	mov    %eax,%ecx
80108f16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108f18:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108f1b:	83 c4 40             	add    $0x40,%esp
80108f1e:	5b                   	pop    %ebx
80108f1f:	5e                   	pop    %esi
80108f20:	5f                   	pop    %edi
80108f21:	5d                   	pop    %ebp
80108f22:	c3                   	ret    

80108f23 <get_max_disk>:

int get_max_disk(int vc_num){
80108f23:	55                   	push   %ebp
80108f24:	89 e5                	mov    %esp,%ebp
80108f26:	57                   	push   %edi
80108f27:	56                   	push   %esi
80108f28:	53                   	push   %ebx
80108f29:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108f2c:	8b 55 08             	mov    0x8(%ebp),%edx
80108f2f:	89 d0                	mov    %edx,%eax
80108f31:	01 c0                	add    %eax,%eax
80108f33:	01 d0                	add    %edx,%eax
80108f35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f3c:	01 d0                	add    %edx,%eax
80108f3e:	c1 e0 02             	shl    $0x2,%eax
80108f41:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f46:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108f49:	89 c3                	mov    %eax,%ebx
80108f4b:	b8 0f 00 00 00       	mov    $0xf,%eax
80108f50:	89 d7                	mov    %edx,%edi
80108f52:	89 de                	mov    %ebx,%esi
80108f54:	89 c1                	mov    %eax,%ecx
80108f56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80108f58:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80108f5b:	83 c4 40             	add    $0x40,%esp
80108f5e:	5b                   	pop    %ebx
80108f5f:	5e                   	pop    %esi
80108f60:	5f                   	pop    %edi
80108f61:	5d                   	pop    %ebp
80108f62:	c3                   	ret    

80108f63 <get_curr_proc>:

int get_curr_proc(int vc_num){
80108f63:	55                   	push   %ebp
80108f64:	89 e5                	mov    %esp,%ebp
80108f66:	57                   	push   %edi
80108f67:	56                   	push   %esi
80108f68:	53                   	push   %ebx
80108f69:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108f6c:	8b 55 08             	mov    0x8(%ebp),%edx
80108f6f:	89 d0                	mov    %edx,%eax
80108f71:	01 c0                	add    %eax,%eax
80108f73:	01 d0                	add    %edx,%eax
80108f75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f7c:	01 d0                	add    %edx,%eax
80108f7e:	c1 e0 02             	shl    $0x2,%eax
80108f81:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f86:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108f89:	89 c3                	mov    %eax,%ebx
80108f8b:	b8 0f 00 00 00       	mov    $0xf,%eax
80108f90:	89 d7                	mov    %edx,%edi
80108f92:	89 de                	mov    %ebx,%esi
80108f94:	89 c1                	mov    %eax,%ecx
80108f96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108f98:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80108f9b:	83 c4 40             	add    $0x40,%esp
80108f9e:	5b                   	pop    %ebx
80108f9f:	5e                   	pop    %esi
80108fa0:	5f                   	pop    %edi
80108fa1:	5d                   	pop    %ebp
80108fa2:	c3                   	ret    

80108fa3 <get_curr_mem>:

int get_curr_mem(int vc_num){
80108fa3:	55                   	push   %ebp
80108fa4:	89 e5                	mov    %esp,%ebp
80108fa6:	57                   	push   %edi
80108fa7:	56                   	push   %esi
80108fa8:	53                   	push   %ebx
80108fa9:	83 ec 5c             	sub    $0x5c,%esp
	struct container x = containers[vc_num];
80108fac:	8b 55 08             	mov    0x8(%ebp),%edx
80108faf:	89 d0                	mov    %edx,%eax
80108fb1:	01 c0                	add    %eax,%eax
80108fb3:	01 d0                	add    %edx,%eax
80108fb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fbc:	01 d0                	add    %edx,%eax
80108fbe:	c1 e0 02             	shl    $0x2,%eax
80108fc1:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108fc6:	8d 55 ac             	lea    -0x54(%ebp),%edx
80108fc9:	89 c3                	mov    %eax,%ebx
80108fcb:	b8 0f 00 00 00       	mov    $0xf,%eax
80108fd0:	89 d7                	mov    %edx,%edi
80108fd2:	89 de                	mov    %ebx,%esi
80108fd4:	89 c1                	mov    %eax,%ecx
80108fd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
80108fd8:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fdf:	c7 04 24 60 9c 10 80 	movl   $0x80109c60,(%esp)
80108fe6:	e8 d6 73 ff ff       	call   801003c1 <cprintf>
	return x.curr_mem; 
80108feb:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108fee:	83 c4 5c             	add    $0x5c,%esp
80108ff1:	5b                   	pop    %ebx
80108ff2:	5e                   	pop    %esi
80108ff3:	5f                   	pop    %edi
80108ff4:	5d                   	pop    %ebp
80108ff5:	c3                   	ret    

80108ff6 <get_curr_disk>:

int get_curr_disk(int vc_num){
80108ff6:	55                   	push   %ebp
80108ff7:	89 e5                	mov    %esp,%ebp
80108ff9:	57                   	push   %edi
80108ffa:	56                   	push   %esi
80108ffb:	53                   	push   %ebx
80108ffc:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108fff:	8b 55 08             	mov    0x8(%ebp),%edx
80109002:	89 d0                	mov    %edx,%eax
80109004:	01 c0                	add    %eax,%eax
80109006:	01 d0                	add    %edx,%eax
80109008:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010900f:	01 d0                	add    %edx,%eax
80109011:	c1 e0 02             	shl    $0x2,%eax
80109014:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109019:	8d 55 b8             	lea    -0x48(%ebp),%edx
8010901c:	89 c3                	mov    %eax,%ebx
8010901e:	b8 0f 00 00 00       	mov    $0xf,%eax
80109023:	89 d7                	mov    %edx,%edi
80109025:	89 de                	mov    %ebx,%esi
80109027:	89 c1                	mov    %eax,%ecx
80109029:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
8010902b:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
8010902e:	83 c4 40             	add    $0x40,%esp
80109031:	5b                   	pop    %ebx
80109032:	5e                   	pop    %esi
80109033:	5f                   	pop    %edi
80109034:	5d                   	pop    %ebp
80109035:	c3                   	ret    

80109036 <set_name>:

void set_name(char* name, int vc_num){
80109036:	55                   	push   %ebp
80109037:	89 e5                	mov    %esp,%ebp
80109039:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
8010903c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010903f:	89 d0                	mov    %edx,%eax
80109041:	01 c0                	add    %eax,%eax
80109043:	01 d0                	add    %edx,%eax
80109045:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010904c:	01 d0                	add    %edx,%eax
8010904e:	c1 e0 02             	shl    $0x2,%eax
80109051:	83 c0 10             	add    $0x10,%eax
80109054:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109059:	8d 50 08             	lea    0x8(%eax),%edx
8010905c:	8b 45 08             	mov    0x8(%ebp),%eax
8010905f:	89 44 24 04          	mov    %eax,0x4(%esp)
80109063:	89 14 24             	mov    %edx,(%esp)
80109066:	e8 26 fc ff ff       	call   80108c91 <strcpy>
}
8010906b:	c9                   	leave  
8010906c:	c3                   	ret    

8010906d <set_max_mem>:

void set_max_mem(int mem, int vc_num){
8010906d:	55                   	push   %ebp
8010906e:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80109070:	8b 55 0c             	mov    0xc(%ebp),%edx
80109073:	89 d0                	mov    %edx,%eax
80109075:	01 c0                	add    %eax,%eax
80109077:	01 d0                	add    %edx,%eax
80109079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109080:	01 d0                	add    %edx,%eax
80109082:	c1 e0 02             	shl    $0x2,%eax
80109085:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
8010908b:	8b 45 08             	mov    0x8(%ebp),%eax
8010908e:	89 02                	mov    %eax,(%edx)
}
80109090:	5d                   	pop    %ebp
80109091:	c3                   	ret    

80109092 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
80109092:	55                   	push   %ebp
80109093:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
80109095:	8b 55 0c             	mov    0xc(%ebp),%edx
80109098:	89 d0                	mov    %edx,%eax
8010909a:	01 c0                	add    %eax,%eax
8010909c:	01 d0                	add    %edx,%eax
8010909e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090a5:	01 d0                	add    %edx,%eax
801090a7:	c1 e0 02             	shl    $0x2,%eax
801090aa:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
801090b0:	8b 45 08             	mov    0x8(%ebp),%eax
801090b3:	89 42 08             	mov    %eax,0x8(%edx)
}
801090b6:	5d                   	pop    %ebp
801090b7:	c3                   	ret    

801090b8 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
801090b8:	55                   	push   %ebp
801090b9:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
801090bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801090be:	89 d0                	mov    %edx,%eax
801090c0:	01 c0                	add    %eax,%eax
801090c2:	01 d0                	add    %edx,%eax
801090c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090cb:	01 d0                	add    %edx,%eax
801090cd:	c1 e0 02             	shl    $0x2,%eax
801090d0:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
801090d6:	8b 45 08             	mov    0x8(%ebp),%eax
801090d9:	89 42 04             	mov    %eax,0x4(%edx)
}
801090dc:	5d                   	pop    %ebp
801090dd:	c3                   	ret    

801090de <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
801090de:	55                   	push   %ebp
801090df:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
801090e1:	8b 55 0c             	mov    0xc(%ebp),%edx
801090e4:	89 d0                	mov    %edx,%eax
801090e6:	01 c0                	add    %eax,%eax
801090e8:	01 d0                	add    %edx,%eax
801090ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090f1:	01 d0                	add    %edx,%eax
801090f3:	c1 e0 02             	shl    $0x2,%eax
801090f6:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801090fb:	8b 40 0c             	mov    0xc(%eax),%eax
801090fe:	8d 48 01             	lea    0x1(%eax),%ecx
80109101:	8b 55 0c             	mov    0xc(%ebp),%edx
80109104:	89 d0                	mov    %edx,%eax
80109106:	01 c0                	add    %eax,%eax
80109108:	01 d0                	add    %edx,%eax
8010910a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109111:	01 d0                	add    %edx,%eax
80109113:	c1 e0 02             	shl    $0x2,%eax
80109116:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010911b:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem-1, containers[vc_num].curr_mem);	
}
8010911e:	5d                   	pop    %ebp
8010911f:	c3                   	ret    

80109120 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
80109120:	55                   	push   %ebp
80109121:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;
80109123:	8b 55 0c             	mov    0xc(%ebp),%edx
80109126:	89 d0                	mov    %edx,%eax
80109128:	01 c0                	add    %eax,%eax
8010912a:	01 d0                	add    %edx,%eax
8010912c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109133:	01 d0                	add    %edx,%eax
80109135:	c1 e0 02             	shl    $0x2,%eax
80109138:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010913d:	8b 40 0c             	mov    0xc(%eax),%eax
80109140:	8d 48 ff             	lea    -0x1(%eax),%ecx
80109143:	8b 55 0c             	mov    0xc(%ebp),%edx
80109146:	89 d0                	mov    %edx,%eax
80109148:	01 c0                	add    %eax,%eax
8010914a:	01 d0                	add    %edx,%eax
8010914c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109153:	01 d0                	add    %edx,%eax
80109155:	c1 e0 02             	shl    $0x2,%eax
80109158:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010915d:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem, containers[vc_num].curr_mem-1);	
}
80109160:	5d                   	pop    %ebp
80109161:	c3                   	ret    

80109162 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80109162:	55                   	push   %ebp
80109163:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
80109165:	8b 55 0c             	mov    0xc(%ebp),%edx
80109168:	89 d0                	mov    %edx,%eax
8010916a:	01 c0                	add    %eax,%eax
8010916c:	01 d0                	add    %edx,%eax
8010916e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109175:	01 d0                	add    %edx,%eax
80109177:	c1 e0 02             	shl    $0x2,%eax
8010917a:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010917f:	8b 50 04             	mov    0x4(%eax),%edx
80109182:	8b 45 08             	mov    0x8(%ebp),%eax
80109185:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109188:	8b 55 0c             	mov    0xc(%ebp),%edx
8010918b:	89 d0                	mov    %edx,%eax
8010918d:	01 c0                	add    %eax,%eax
8010918f:	01 d0                	add    %edx,%eax
80109191:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109198:	01 d0                	add    %edx,%eax
8010919a:	c1 e0 02             	shl    $0x2,%eax
8010919d:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
801091a2:	89 48 04             	mov    %ecx,0x4(%eax)
}
801091a5:	5d                   	pop    %ebp
801091a6:	c3                   	ret    

801091a7 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
801091a7:	55                   	push   %ebp
801091a8:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
801091aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801091ad:	89 d0                	mov    %edx,%eax
801091af:	01 c0                	add    %eax,%eax
801091b1:	01 d0                	add    %edx,%eax
801091b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091ba:	01 d0                	add    %edx,%eax
801091bc:	c1 e0 02             	shl    $0x2,%eax
801091bf:	8d 90 d0 7b 11 80    	lea    -0x7fee8430(%eax),%edx
801091c5:	8b 45 08             	mov    0x8(%ebp),%eax
801091c8:	89 02                	mov    %eax,(%edx)
}
801091ca:	5d                   	pop    %ebp
801091cb:	c3                   	ret    

801091cc <max_containers>:

int max_containers(){
801091cc:	55                   	push   %ebp
801091cd:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
801091cf:	b8 04 00 00 00       	mov    $0x4,%eax
}
801091d4:	5d                   	pop    %ebp
801091d5:	c3                   	ret    

801091d6 <container_init>:

void container_init(){
801091d6:	55                   	push   %ebp
801091d7:	89 e5                	mov    %esp,%ebp
801091d9:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801091dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801091e3:	e9 f7 00 00 00       	jmp    801092df <container_init+0x109>
		strcpy(containers[i].name, "");
801091e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801091eb:	89 d0                	mov    %edx,%eax
801091ed:	01 c0                	add    %eax,%eax
801091ef:	01 d0                	add    %edx,%eax
801091f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091f8:	01 d0                	add    %edx,%eax
801091fa:	c1 e0 02             	shl    $0x2,%eax
801091fd:	83 c0 10             	add    $0x10,%eax
80109200:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109205:	83 c0 08             	add    $0x8,%eax
80109208:	c7 44 24 04 5c 9c 10 	movl   $0x80109c5c,0x4(%esp)
8010920f:	80 
80109210:	89 04 24             	mov    %eax,(%esp)
80109213:	e8 79 fa ff ff       	call   80108c91 <strcpy>
		containers[i].max_proc = 4;
80109218:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010921b:	89 d0                	mov    %edx,%eax
8010921d:	01 c0                	add    %eax,%eax
8010921f:	01 d0                	add    %edx,%eax
80109221:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109228:	01 d0                	add    %edx,%eax
8010922a:	c1 e0 02             	shl    $0x2,%eax
8010922d:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109232:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80109239:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010923c:	89 d0                	mov    %edx,%eax
8010923e:	01 c0                	add    %eax,%eax
80109240:	01 d0                	add    %edx,%eax
80109242:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109249:	01 d0                	add    %edx,%eax
8010924b:	c1 e0 02             	shl    $0x2,%eax
8010924e:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109253:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
8010925a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010925d:	89 d0                	mov    %edx,%eax
8010925f:	01 c0                	add    %eax,%eax
80109261:	01 d0                	add    %edx,%eax
80109263:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010926a:	01 d0                	add    %edx,%eax
8010926c:	c1 e0 02             	shl    $0x2,%eax
8010926f:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109274:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 1;
8010927a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010927d:	89 d0                	mov    %edx,%eax
8010927f:	01 c0                	add    %eax,%eax
80109281:	01 d0                	add    %edx,%eax
80109283:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010928a:	01 d0                	add    %edx,%eax
8010928c:	c1 e0 02             	shl    $0x2,%eax
8010928f:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80109294:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
8010929a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010929d:	89 d0                	mov    %edx,%eax
8010929f:	01 c0                	add    %eax,%eax
801092a1:	01 d0                	add    %edx,%eax
801092a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092aa:	01 d0                	add    %edx,%eax
801092ac:	c1 e0 02             	shl    $0x2,%eax
801092af:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
801092b4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
801092bb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801092be:	89 d0                	mov    %edx,%eax
801092c0:	01 c0                	add    %eax,%eax
801092c2:	01 d0                	add    %edx,%eax
801092c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092cb:	01 d0                	add    %edx,%eax
801092cd:	c1 e0 02             	shl    $0x2,%eax
801092d0:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801092d5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801092dc:	ff 45 fc             	incl   -0x4(%ebp)
801092df:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801092e3:	0f 8e ff fe ff ff    	jle    801091e8 <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
801092e9:	c9                   	leave  
801092ea:	c3                   	ret    

801092eb <container_reset>:

void container_reset(int vc_num){
801092eb:	55                   	push   %ebp
801092ec:	89 e5                	mov    %esp,%ebp
801092ee:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
801092f1:	8b 55 08             	mov    0x8(%ebp),%edx
801092f4:	89 d0                	mov    %edx,%eax
801092f6:	01 c0                	add    %eax,%eax
801092f8:	01 d0                	add    %edx,%eax
801092fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109301:	01 d0                	add    %edx,%eax
80109303:	c1 e0 02             	shl    $0x2,%eax
80109306:	83 c0 10             	add    $0x10,%eax
80109309:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010930e:	83 c0 08             	add    $0x8,%eax
80109311:	c7 44 24 04 5c 9c 10 	movl   $0x80109c5c,0x4(%esp)
80109318:	80 
80109319:	89 04 24             	mov    %eax,(%esp)
8010931c:	e8 70 f9 ff ff       	call   80108c91 <strcpy>
	containers[vc_num].max_proc = 4;
80109321:	8b 55 08             	mov    0x8(%ebp),%edx
80109324:	89 d0                	mov    %edx,%eax
80109326:	01 c0                	add    %eax,%eax
80109328:	01 d0                	add    %edx,%eax
8010932a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109331:	01 d0                	add    %edx,%eax
80109333:	c1 e0 02             	shl    $0x2,%eax
80109336:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010933b:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
	containers[vc_num].max_disk = 100;
80109342:	8b 55 08             	mov    0x8(%ebp),%edx
80109345:	89 d0                	mov    %edx,%eax
80109347:	01 c0                	add    %eax,%eax
80109349:	01 d0                	add    %edx,%eax
8010934b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109352:	01 d0                	add    %edx,%eax
80109354:	c1 e0 02             	shl    $0x2,%eax
80109357:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010935c:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 100;
80109363:	8b 55 08             	mov    0x8(%ebp),%edx
80109366:	89 d0                	mov    %edx,%eax
80109368:	01 c0                	add    %eax,%eax
8010936a:	01 d0                	add    %edx,%eax
8010936c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109373:	01 d0                	add    %edx,%eax
80109375:	c1 e0 02             	shl    $0x2,%eax
80109378:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010937d:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
	containers[vc_num].curr_proc = 1;
80109383:	8b 55 08             	mov    0x8(%ebp),%edx
80109386:	89 d0                	mov    %edx,%eax
80109388:	01 c0                	add    %eax,%eax
8010938a:	01 d0                	add    %edx,%eax
8010938c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109393:	01 d0                	add    %edx,%eax
80109395:	c1 e0 02             	shl    $0x2,%eax
80109398:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010939d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	containers[vc_num].curr_disk = 0;
801093a3:	8b 55 08             	mov    0x8(%ebp),%edx
801093a6:	89 d0                	mov    %edx,%eax
801093a8:	01 c0                	add    %eax,%eax
801093aa:	01 d0                	add    %edx,%eax
801093ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093b3:	01 d0                	add    %edx,%eax
801093b5:	c1 e0 02             	shl    $0x2,%eax
801093b8:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
801093bd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
801093c4:	8b 55 08             	mov    0x8(%ebp),%edx
801093c7:	89 d0                	mov    %edx,%eax
801093c9:	01 c0                	add    %eax,%eax
801093cb:	01 d0                	add    %edx,%eax
801093cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093d4:	01 d0                	add    %edx,%eax
801093d6:	c1 e0 02             	shl    $0x2,%eax
801093d9:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801093de:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
801093e5:	c9                   	leave  
801093e6:	c3                   	ret    
