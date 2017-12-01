
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
8010003a:	c7 44 24 04 b4 92 10 	movl   $0x801092b4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100049:	e8 20 52 00 00       	call   8010526e <initlock>

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
80100087:	c7 44 24 04 bb 92 10 	movl   $0x801092bb,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 99 50 00 00       	call   80105130 <initsleeplock>
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
801000c9:	e8 c1 51 00 00       	call   8010528f <acquire>

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
80100104:	e8 f0 51 00 00       	call   801052f9 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 53 50 00 00       	call   8010516a <acquiresleep>
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
8010017d:	e8 77 51 00 00       	call   801052f9 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 da 4f 00 00       	call   8010516a <acquiresleep>
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
801001a7:	c7 04 24 c2 92 10 80 	movl   $0x801092c2,(%esp)
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
801001fb:	e8 07 50 00 00       	call   80105207 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 d3 92 10 80 	movl   $0x801092d3,(%esp)
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
8010023b:	e8 c7 4f 00 00       	call   80105207 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 da 92 10 80 	movl   $0x801092da,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 67 4f 00 00       	call   801051c5 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100265:	e8 25 50 00 00       	call   8010528f <acquire>
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
801002d1:	e8 23 50 00 00       	call   801052f9 <release>
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
801003dc:	e8 ae 4e 00 00       	call   8010528f <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 e1 92 10 80 	movl   $0x801092e1,(%esp)
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
801004cf:	c7 45 ec ea 92 10 80 	movl   $0x801092ea,-0x14(%ebp)
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
8010054d:	e8 a7 4d 00 00       	call   801052f9 <release>
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
80100572:	c7 04 24 f1 92 10 80 	movl   $0x801092f1,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 05 93 10 80 	movl   $0x80109305,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 9f 4d 00 00       	call   80105346 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 07 93 10 80 	movl   $0x80109307,(%esp)
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
80100695:	c7 04 24 0b 93 10 80 	movl   $0x8010930b,(%esp)
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
801006c9:	e8 ed 4e 00 00       	call   801055bb <memmove>
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
801006f8:	e8 f5 4d 00 00       	call   801054f2 <memset>
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
8010078e:	e8 25 6c 00 00       	call   801073b8 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 19 6c 00 00       	call   801073b8 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 0d 6c 00 00       	call   801073b8 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 00 6c 00 00       	call   801073b8 <uartputc>
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
80100813:	e8 77 4a 00 00       	call   8010528f <acquire>
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
80100a21:	e8 d3 48 00 00       	call   801052f9 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 1e 93 10 80 	movl   $0x8010931e,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 94 43 00 00       	call   80104dd1 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 36 93 10 80 	movl   $0x80109336,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 50 93 10 80 	movl   $0x80109350,(%esp)
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
80100a8a:	e8 00 48 00 00       	call   8010528f <acquire>
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
80100aa9:	e8 4b 48 00 00       	call   801052f9 <release>
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
80100b5c:	e8 98 47 00 00       	call   801052f9 <release>
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
80100ba2:	e8 e8 46 00 00       	call   8010528f <acquire>
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
80100bda:	e8 1a 47 00 00       	call   801052f9 <release>
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
80100bf5:	c7 44 24 04 69 93 10 	movl   $0x80109369,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100c04:	e8 65 46 00 00       	call   8010526e <initlock>

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
80100c6f:	c7 04 24 71 93 10 80 	movl   $0x80109371,(%esp)
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
80100cd8:	e8 bd 76 00 00       	call   8010839a <setupkvm>
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
80100d96:	e8 cb 79 00 00       	call   80108766 <allocuvm>
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
80100de8:	e8 96 78 00 00       	call   80108683 <loaduvm>
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
80100e54:	e8 0d 79 00 00       	call   80108766 <allocuvm>
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
80100e79:	e8 58 7b 00 00       	call   801089d6 <clearpteu>
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
80100eaf:	e8 91 48 00 00       	call   80105745 <strlen>
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
80100ed6:	e8 6a 48 00 00       	call   80105745 <strlen>
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
80100f04:	e8 85 7c 00 00       	call   80108b8e <copyout>
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
80100fa8:	e8 e1 7b 00 00       	call   80108b8e <copyout>
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
80100ff8:	e8 01 47 00 00       	call   801056fe <safestrcpy>

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
80101038:	e8 37 74 00 00       	call   80108474 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 f8 78 00 00       	call   80108940 <freevm>
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
8010105b:	e8 e0 78 00 00       	call   80108940 <freevm>
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
801010ec:	c7 44 24 04 7d 93 10 	movl   $0x8010937d,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801010fb:	e8 6e 41 00 00       	call   8010526e <initlock>
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
8010110f:	e8 7b 41 00 00       	call   8010528f <acquire>
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
80101138:	e8 bc 41 00 00       	call   801052f9 <release>
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
80101156:	e8 9e 41 00 00       	call   801052f9 <release>
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
8010116f:	e8 1b 41 00 00       	call   8010528f <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 84 93 10 80 	movl   $0x80109384,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011a0:	e8 54 41 00 00       	call   801052f9 <release>
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
801011ba:	e8 d0 40 00 00       	call   8010528f <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 8c 93 10 80 	movl   $0x8010938c,(%esp)
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
801011f5:	e8 ff 40 00 00       	call   801052f9 <release>
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
8010122b:	e8 c9 40 00 00       	call   801052f9 <release>

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
80101370:	c7 04 24 96 93 10 80 	movl   $0x80109396,(%esp)
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
8010147b:	c7 04 24 9f 93 10 80 	movl   $0x8010939f,(%esp)
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
801014ad:	c7 04 24 af 93 10 80 	movl   $0x801093af,(%esp)
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
801014f4:	e8 c2 40 00 00       	call   801055bb <memmove>
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
8010153a:	e8 b3 3f 00 00       	call   801054f2 <memset>
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
80101683:	c7 04 24 bc 93 10 80 	movl   $0x801093bc,(%esp)
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
80101713:	c7 04 24 d2 93 10 80 	movl   $0x801093d2,(%esp)
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
8010176b:	c7 44 24 04 e5 93 10 	movl   $0x801093e5,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
8010177a:	e8 ef 3a 00 00       	call   8010526e <initlock>
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
801017a0:	c7 44 24 04 ec 93 10 	movl   $0x801093ec,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 80 39 00 00       	call   80105130 <initsleeplock>
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
80101819:	c7 04 24 f4 93 10 80 	movl   $0x801093f4,(%esp)
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
8010189b:	e8 52 3c 00 00       	call   801054f2 <memset>
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
801018f1:	c7 04 24 47 94 10 80 	movl   $0x80109447,(%esp)
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
8010199e:	e8 18 3c 00 00       	call   801055bb <memmove>
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
801019c8:	e8 c2 38 00 00       	call   8010528f <acquire>

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
80101a12:	e8 e2 38 00 00       	call   801052f9 <release>
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
80101a48:	c7 04 24 59 94 10 80 	movl   $0x80109459,(%esp)
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
80101a86:	e8 6e 38 00 00       	call   801052f9 <release>

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
80101a9d:	e8 ed 37 00 00       	call   8010528f <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101ab8:	e8 3c 38 00 00       	call   801052f9 <release>
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
80101ad8:	c7 04 24 69 94 10 80 	movl   $0x80109469,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 78 36 00 00       	call   8010516a <acquiresleep>

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
80101b99:	e8 1d 3a 00 00       	call   801055bb <memmove>
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
80101bbe:	c7 04 24 6f 94 10 80 	movl   $0x8010946f,(%esp)
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
80101be1:	e8 21 36 00 00       	call   80105207 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 7e 94 10 80 	movl   $0x8010947e,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 b7 35 00 00       	call   801051c5 <releasesleep>
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
80101c1f:	e8 46 35 00 00       	call   8010516a <acquiresleep>
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
80101c41:	e8 49 36 00 00       	call   8010528f <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c56:	e8 9e 36 00 00       	call   801052f9 <release>
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
80101c93:	e8 2d 35 00 00       	call   801051c5 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c9f:	e8 eb 35 00 00       	call   8010528f <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101cba:	e8 3a 36 00 00       	call   801052f9 <release>
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
80101de0:	c7 04 24 86 94 10 80 	movl   $0x80109486,(%esp)
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
8010208a:	e8 2c 35 00 00       	call   801055bb <memmove>
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
801020da:	e8 f4 6c 00 00       	call   80108dd3 <find>
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
8010211a:	c7 04 24 99 94 10 80 	movl   $0x80109499,(%esp)
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
8010218b:	c7 04 24 a0 94 10 80 	movl   $0x801094a0,(%esp)
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
80102220:	e8 96 33 00 00       	call   801055bb <memmove>
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
80102266:	c7 04 24 a7 94 10 80 	movl   $0x801094a7,(%esp)
8010226d:	e8 4f e1 ff ff       	call   801003c1 <cprintf>
    if(tot == 1){
80102272:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102276:	75 13                	jne    8010228b <writei+0x1ce>
      set_curr_disk(1, x);
80102278:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102286:	e8 9f 6e 00 00       	call   8010912a <set_curr_disk>
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
801022d0:	e8 85 33 00 00       	call   8010565a <strncmp>
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
801022e9:	c7 04 24 ab 94 10 80 	movl   $0x801094ab,(%esp)
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
80102327:	c7 04 24 bd 94 10 80 	movl   $0x801094bd,(%esp)
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
8010240a:	c7 04 24 cc 94 10 80 	movl   $0x801094cc,(%esp)
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
8010244e:	e8 55 32 00 00       	call   801056a8 <strncpy>
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
80102480:	c7 04 24 d9 94 10 80 	movl   $0x801094d9,(%esp)
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
801024ff:	e8 b7 30 00 00       	call   801055bb <memmove>
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
8010251a:	e8 9c 30 00 00       	call   801055bb <memmove>
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
8010275f:	c7 44 24 04 e1 94 10 	movl   $0x801094e1,0x4(%esp)
80102766:	80 
80102767:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
8010276e:	e8 fb 2a 00 00       	call   8010526e <initlock>
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
801027fc:	c7 04 24 e5 94 10 80 	movl   $0x801094e5,(%esp)
80102803:	e8 4c dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102808:	8b 45 08             	mov    0x8(%ebp),%eax
8010280b:	8b 40 08             	mov    0x8(%eax),%eax
8010280e:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
80102813:	76 0c                	jbe    80102821 <idestart+0x31>
    panic("incorrect blockno");
80102815:	c7 04 24 ee 94 10 80 	movl   $0x801094ee,(%esp)
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
80102867:	c7 04 24 e5 94 10 80 	movl   $0x801094e5,(%esp)
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
80102987:	e8 03 29 00 00       	call   8010528f <acquire>

  if((b = idequeue) == 0){
8010298c:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102994:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102998:	75 11                	jne    801029ab <ideintr+0x31>
    release(&idelock);
8010299a:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
801029a1:	e8 53 29 00 00       	call   801052f9 <release>
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
80102a36:	e8 be 28 00 00       	call   801052f9 <release>
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
80102a4c:	e8 b6 27 00 00       	call   80105207 <holdingsleep>
80102a51:	85 c0                	test   %eax,%eax
80102a53:	75 0c                	jne    80102a61 <iderw+0x24>
    panic("iderw: buf not locked");
80102a55:	c7 04 24 00 95 10 80 	movl   $0x80109500,(%esp)
80102a5c:	e8 f3 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a61:	8b 45 08             	mov    0x8(%ebp),%eax
80102a64:	8b 00                	mov    (%eax),%eax
80102a66:	83 e0 06             	and    $0x6,%eax
80102a69:	83 f8 02             	cmp    $0x2,%eax
80102a6c:	75 0c                	jne    80102a7a <iderw+0x3d>
    panic("iderw: nothing to do");
80102a6e:	c7 04 24 16 95 10 80 	movl   $0x80109516,(%esp)
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
80102a8d:	c7 04 24 2b 95 10 80 	movl   $0x8010952b,(%esp)
80102a94:	e8 bb da ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a99:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102aa0:	e8 ea 27 00 00       	call   8010528f <acquire>

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
80102b14:	e8 e0 27 00 00       	call   801052f9 <release>
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
80102b93:	c7 04 24 4c 95 10 80 	movl   $0x8010954c,(%esp)
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
80102c36:	c7 44 24 04 7e 95 10 	movl   $0x8010957e,0x4(%esp)
80102c3d:	80 
80102c3e:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102c45:	e8 24 26 00 00       	call   8010526e <initlock>
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
80102cef:	c7 04 24 83 95 10 80 	movl   $0x80109583,(%esp)
80102cf6:	e8 59 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cfb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102d02:	00 
80102d03:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d0a:	00 
80102d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0e:	89 04 24             	mov    %eax,(%esp)
80102d11:	e8 dc 27 00 00       	call   801054f2 <memset>

  if(kmem.use_lock){
80102d16:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 48                	je     80102d67 <kfree+0xa2>
    acquire(&kmem.lock);
80102d1f:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d26:	e8 64 25 00 00       	call   8010528f <acquire>
    if(ticks > 1){
80102d2b:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102d30:	83 f8 01             	cmp    $0x1,%eax
80102d33:	76 32                	jbe    80102d67 <kfree+0xa2>
      int x = find(myproc()->cont->name);
80102d35:	e8 69 16 00 00       	call   801043a3 <myproc>
80102d3a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102d40:	83 c0 18             	add    $0x18,%eax
80102d43:	89 04 24             	mov    %eax,(%esp)
80102d46:	e8 88 60 00 00       	call   80108dd3 <find>
80102d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d52:	78 13                	js     80102d67 <kfree+0xa2>
        reduce_curr_mem(1, x);
80102d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d57:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102d62:	e8 81 63 00 00       	call   801090e8 <reduce_curr_mem>
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
80102d90:	e8 64 25 00 00       	call   801052f9 <release>
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
80102dad:	e8 dd 24 00 00       	call   8010528f <acquire>
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
80102dea:	e8 e4 5f 00 00       	call   80108dd3 <find>
80102def:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102df2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102df6:	78 13                	js     80102e0b <kalloc+0x74>
        set_curr_mem(1, x);
80102df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e06:	e8 9b 62 00 00       	call   801090a6 <set_curr_mem>
      }
   }
  }
  if(kmem.use_lock)
80102e0b:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102e10:	85 c0                	test   %eax,%eax
80102e12:	74 0c                	je     80102e20 <kalloc+0x89>
    release(&kmem.lock);
80102e14:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102e1b:	e8 d9 24 00 00       	call   801052f9 <release>
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
801033b5:	e8 af 21 00 00       	call   80105569 <memcmp>
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
801034aa:	c7 44 24 04 89 95 10 	movl   $0x80109589,0x4(%esp)
801034b1:	80 
801034b2:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801034b9:	e8 b0 1d 00 00       	call   8010526e <initlock>
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
80103561:	e8 55 20 00 00       	call   801055bb <memmove>
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
801036b0:	e8 da 1b 00 00       	call   8010528f <acquire>
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
8010371a:	e8 da 1b 00 00       	call   801052f9 <release>
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
80103739:	e8 51 1b 00 00       	call   8010528f <acquire>
  log.outstanding -= 1;
8010373e:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103743:	48                   	dec    %eax
80103744:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
  if(log.committing)
80103749:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
8010374e:	85 c0                	test   %eax,%eax
80103750:	74 0c                	je     8010375e <end_op+0x39>
    panic("log.committing");
80103752:	c7 04 24 8d 95 10 80 	movl   $0x8010958d,(%esp)
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
8010378d:	e8 67 1b 00 00       	call   801052f9 <release>

  if(do_commit){
80103792:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103796:	74 33                	je     801037cb <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103798:	e8 db 00 00 00       	call   80103878 <commit>
    acquire(&log.lock);
8010379d:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037a4:	e8 e6 1a 00 00       	call   8010528f <acquire>
    log.committing = 0;
801037a9:	c7 05 c0 4b 11 80 00 	movl   $0x0,0x80114bc0
801037b0:	00 00 00 
    wakeup(&log);
801037b3:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037ba:	e8 6c 15 00 00       	call   80104d2b <wakeup>
    release(&log.lock);
801037bf:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037c6:	e8 2e 1b 00 00       	call   801052f9 <release>
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
8010383f:	e8 77 1d 00 00       	call   801055bb <memmove>
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
801038c7:	c7 04 24 9c 95 10 80 	movl   $0x8010959c,(%esp)
801038ce:	e8 81 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801038d3:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801038d8:	85 c0                	test   %eax,%eax
801038da:	7f 0c                	jg     801038e8 <log_write+0x41>
    panic("log_write outside of trans");
801038dc:	c7 04 24 b2 95 10 80 	movl   $0x801095b2,(%esp)
801038e3:	e8 6c cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801038e8:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801038ef:	e8 9b 19 00 00       	call   8010528f <acquire>
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
80103963:	e8 91 19 00 00       	call   801052f9 <release>
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
801039a3:	e8 9b 4a 00 00       	call   80108443 <kvmalloc>
  mpinit();        // detect other processors
801039a8:	e8 cc 03 00 00       	call   80103d79 <mpinit>
  lapicinit();     // interrupt controller
801039ad:	e8 4e f6 ff ff       	call   80103000 <lapicinit>
  seginit();       // segment descriptors
801039b2:	e8 74 45 00 00       	call   80107f2b <seginit>
  picinit();       // disable pic
801039b7:	e8 0c 05 00 00       	call   80103ec8 <picinit>
  ioapicinit();    // another interrupt controller
801039bc:	e8 8c f1 ff ff       	call   80102b4d <ioapicinit>
  consoleinit();   // console hardware
801039c1:	e8 29 d2 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
801039c6:	e8 ec 38 00 00       	call   801072b7 <uartinit>
  pinit();         // process table
801039cb:	e8 ee 08 00 00       	call   801042be <pinit>
  tvinit();        // trap vectors
801039d0:	e8 af 34 00 00       	call   80106e84 <tvinit>
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
80103a02:	e8 97 57 00 00       	call   8010919e <container_init>
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
80103a12:	e8 43 4a 00 00       	call   8010845a <switchkvm>
  seginit();
80103a17:	e8 0f 45 00 00       	call   80107f2b <seginit>
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
80103a41:	c7 04 24 cd 95 10 80 	movl   $0x801095cd,(%esp)
80103a48:	e8 74 c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103a4d:	e8 8f 35 00 00       	call   80106fe1 <idtinit>
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
80103a95:	e8 21 1b 00 00       	call   801055bb <memmove>

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
80103bd9:	c7 44 24 04 e4 95 10 	movl   $0x801095e4,0x4(%esp)
80103be0:	80 
80103be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be4:	89 04 24             	mov    %eax,(%esp)
80103be7:	e8 7d 19 00 00       	call   80105569 <memcmp>
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
80103d10:	c7 44 24 04 e9 95 10 	movl   $0x801095e9,0x4(%esp)
80103d17:	80 
80103d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d1b:	89 04 24             	mov    %eax,(%esp)
80103d1e:	e8 46 18 00 00       	call   80105569 <memcmp>
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
80103d93:	c7 04 24 ee 95 10 80 	movl   $0x801095ee,(%esp)
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
80103dda:	8b 04 85 28 96 10 80 	mov    -0x7fef69d8(,%eax,4),%eax
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
80103e5c:	c7 04 24 08 96 10 80 	movl   $0x80109608,(%esp)
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
80103f90:	c7 44 24 04 3c 96 10 	movl   $0x8010963c,0x4(%esp)
80103f97:	80 
80103f98:	89 04 24             	mov    %eax,(%esp)
80103f9b:	e8 ce 12 00 00       	call   8010526e <initlock>
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
80104047:	e8 43 12 00 00       	call   8010528f <acquire>
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
801040ae:	e8 46 12 00 00       	call   801052f9 <release>
    kfree((char*)p);
801040b3:	8b 45 08             	mov    0x8(%ebp),%eax
801040b6:	89 04 24             	mov    %eax,(%esp)
801040b9:	e8 07 ec ff ff       	call   80102cc5 <kfree>
801040be:	eb 0b                	jmp    801040cb <pipeclose+0x90>
  } else
    release(&p->lock);
801040c0:	8b 45 08             	mov    0x8(%ebp),%eax
801040c3:	89 04 24             	mov    %eax,(%esp)
801040c6:	e8 2e 12 00 00       	call   801052f9 <release>
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
801040d9:	e8 b1 11 00 00       	call   8010528f <acquire>
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
8010410b:	e8 e9 11 00 00       	call   801052f9 <release>
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
801041af:	e8 45 11 00 00       	call   801052f9 <release>
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
801041c6:	e8 c4 10 00 00       	call   8010528f <acquire>
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
801041df:	e8 15 11 00 00       	call   801052f9 <release>
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
80104299:	e8 5b 10 00 00       	call   801052f9 <release>
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
801042c4:	c7 44 24 04 44 96 10 	movl   $0x80109644,0x4(%esp)
801042cb:	80 
801042cc:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801042d3:	e8 96 0f 00 00       	call   8010526e <initlock>
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
80104333:	c7 04 24 4c 96 10 80 	movl   $0x8010964c,(%esp)
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
80104395:	c7 04 24 72 96 10 80 	movl   $0x80109672,(%esp)
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
801043a9:	e8 40 10 00 00       	call   801053ee <pushcli>
  c = mycpu();
801043ae:	e8 6c ff ff ff       	call   8010431f <mycpu>
801043b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801043b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801043bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801043c2:	e8 71 10 00 00       	call   80105438 <popcli>
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
801043d9:	e8 b1 0e 00 00       	call   8010528f <acquire>

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
80104417:	e8 dd 0e 00 00       	call   801052f9 <release>

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
8010444a:	e8 aa 0e 00 00       	call   801052f9 <release>
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
80104489:	ba 40 6e 10 80       	mov    $0x80106e40,%edx
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
801044b9:	e8 34 10 00 00       	call   801054f2 <memset>
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
801044fe:	e8 97 3e 00 00       	call   8010839a <setupkvm>
80104503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104506:	89 42 04             	mov    %eax,0x4(%edx)
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450c:	8b 40 04             	mov    0x4(%eax),%eax
8010450f:	85 c0                	test   %eax,%eax
80104511:	75 0c                	jne    8010451f <userinit+0x37>
    panic("userinit: out of memory?");
80104513:	c7 04 24 82 96 10 80 	movl   $0x80109682,(%esp)
8010451a:	e8 35 c0 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010451f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 04             	mov    0x4(%eax),%eax
8010452a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010452e:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
80104535:	80 
80104536:	89 04 24             	mov    %eax,(%esp)
80104539:	e8 bd 40 00 00       	call   801085fb <inituvm>
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
80104560:	e8 8d 0f 00 00       	call   801054f2 <memset>
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
801045d8:	c7 44 24 04 9b 96 10 	movl   $0x8010969b,0x4(%esp)
801045df:	80 
801045e0:	89 04 24             	mov    %eax,(%esp)
801045e3:	e8 16 11 00 00       	call   801056fe <safestrcpy>
  p->cwd = namei("/");
801045e8:	c7 04 24 a4 96 10 80 	movl   $0x801096a4,(%esp)
801045ef:	e8 5c e0 ff ff       	call   80102650 <namei>
801045f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801045fa:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104601:	e8 89 0c 00 00       	call   8010528f <acquire>

  p->state = RUNNABLE;
80104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104609:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104610:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104617:	e8 dd 0c 00 00       	call   801052f9 <release>
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
80104656:	e8 0b 41 00 00       	call   80108766 <allocuvm>
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
8010468d:	e8 ea 41 00 00       	call   8010887c <deallocuvm>
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
801046b0:	e8 bf 3d 00 00       	call   80108474 <switchuvm>
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
801046f7:	e8 20 43 00 00       	call   80108a1c <copyuvm>
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
801047e7:	e8 12 0f 00 00       	call   801056fe <safestrcpy>



  pid = np->pid;
801047ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047ef:	8b 40 10             	mov    0x10(%eax),%eax
801047f2:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801047f5:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801047fc:	e8 8e 0a 00 00       	call   8010528f <acquire>

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
80104824:	e8 d0 0a 00 00       	call   801052f9 <release>

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
8010484c:	c7 04 24 a6 96 10 80 	movl   $0x801096a6,(%esp)
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
801048ca:	e8 c0 09 00 00       	call   8010528f <acquire>

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
80104934:	c7 04 24 b3 96 10 80 	movl   $0x801096b3,(%esp)
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
8010498d:	e8 fd 08 00 00       	call   8010528f <acquire>
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
801049f1:	e8 4a 3f 00 00       	call   80108940 <freevm>
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
80104a2c:	e8 c8 08 00 00       	call   801052f9 <release>
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
80104a61:	e8 93 08 00 00       	call   801052f9 <release>
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
80104aae:	e8 dc 07 00 00       	call   8010528f <acquire>
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
80104adb:	e8 94 39 00 00       	call   80108474 <switchuvm>
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
80104afd:	e8 6a 0c 00 00       	call   8010576c <swtch>
      switchkvm();
80104b02:	e8 53 39 00 00       	call   8010845a <switchkvm>

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
80104b2b:	e8 c9 07 00 00       	call   801052f9 <release>

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
80104b4a:	e8 6e 08 00 00       	call   801053bd <holding>
80104b4f:	85 c0                	test   %eax,%eax
80104b51:	75 0c                	jne    80104b5f <sched+0x2a>
    panic("sched ptable.lock");
80104b53:	c7 04 24 bf 96 10 80 	movl   $0x801096bf,(%esp)
80104b5a:	e8 f5 b9 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104b5f:	e8 bb f7 ff ff       	call   8010431f <mycpu>
80104b64:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b6a:	83 f8 01             	cmp    $0x1,%eax
80104b6d:	74 0c                	je     80104b7b <sched+0x46>
    panic("sched locks");
80104b6f:	c7 04 24 d1 96 10 80 	movl   $0x801096d1,(%esp)
80104b76:	e8 d9 b9 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7e:	8b 40 0c             	mov    0xc(%eax),%eax
80104b81:	83 f8 04             	cmp    $0x4,%eax
80104b84:	75 0c                	jne    80104b92 <sched+0x5d>
    panic("sched running");
80104b86:	c7 04 24 dd 96 10 80 	movl   $0x801096dd,(%esp)
80104b8d:	e8 c2 b9 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104b92:	e8 11 f7 ff ff       	call   801042a8 <readeflags>
80104b97:	25 00 02 00 00       	and    $0x200,%eax
80104b9c:	85 c0                	test   %eax,%eax
80104b9e:	74 0c                	je     80104bac <sched+0x77>
    panic("sched interruptible");
80104ba0:	c7 04 24 eb 96 10 80 	movl   $0x801096eb,(%esp)
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
80104bcf:	e8 98 0b 00 00       	call   8010576c <swtch>
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
80104bf1:	e8 99 06 00 00       	call   8010528f <acquire>
  myproc()->state = RUNNABLE;
80104bf6:	e8 a8 f7 ff ff       	call   801043a3 <myproc>
80104bfb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c02:	e8 2e ff ff ff       	call   80104b35 <sched>
  release(&ptable.lock);
80104c07:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c0e:	e8 e6 06 00 00       	call   801052f9 <release>
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
80104c22:	e8 d2 06 00 00       	call   801052f9 <release>

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
80104c68:	c7 04 24 ff 96 10 80 	movl   $0x801096ff,(%esp)
80104c6f:	e8 e0 b8 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104c74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c78:	75 0c                	jne    80104c86 <sleep+0x32>
    panic("sleep without lk");
80104c7a:	c7 04 24 05 97 10 80 	movl   $0x80109705,(%esp)
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
80104c96:	e8 f4 05 00 00       	call   8010528f <acquire>
    release(lk);
80104c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9e:	89 04 24             	mov    %eax,(%esp)
80104ca1:	e8 53 06 00 00       	call   801052f9 <release>
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
80104cd8:	e8 1c 06 00 00       	call   801052f9 <release>
    acquire(lk);
80104cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce0:	89 04 24             	mov    %eax,(%esp)
80104ce3:	e8 a7 05 00 00       	call   8010528f <acquire>
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
80104d38:	e8 52 05 00 00       	call   8010528f <acquire>
  wakeup1(chan);
80104d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d40:	89 04 24             	mov    %eax,(%esp)
80104d43:	e8 a2 ff ff ff       	call   80104cea <wakeup1>
  release(&ptable.lock);
80104d48:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d4f:	e8 a5 05 00 00       	call   801052f9 <release>
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
80104d63:	e8 27 05 00 00       	call   8010528f <acquire>
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
80104da2:	e8 52 05 00 00       	call   801052f9 <release>
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
80104dc5:	e8 2f 05 00 00       	call   801052f9 <release>
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
80104e20:	c7 45 ec 16 97 10 80 	movl   $0x80109716,-0x14(%ebp)

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
80104e4f:	c7 04 24 1a 97 10 80 	movl   $0x8010971a,(%esp)
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
80104e88:	c7 04 24 28 97 10 80 	movl   $0x80109728,(%esp)
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
80104eb5:	e8 8c 04 00 00       	call   80105346 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104eba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ec1:	eb 1a                	jmp    80104edd <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eca:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ece:	c7 04 24 34 97 10 80 	movl   $0x80109734,(%esp)
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
80104eee:	c7 04 24 38 97 10 80 	movl   $0x80109738,(%esp)
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
80104fb8:	c7 04 24 3c 97 10 80 	movl   $0x8010973c,(%esp)
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
}
80104fe2:	c9                   	leave  
80104fe3:	c3                   	ret    

80104fe4 <c_procdump>:
//   return os;
// }

void
c_procdump(char* name)
{
80104fe4:	55                   	push   %ebp
80104fe5:	89 e5                	mov    %esp,%ebp
80104fe7:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fea:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104ff1:	e9 0f 01 00 00       	jmp    80105105 <c_procdump+0x121>

    // if(p->cont == NULL){
    //   cprintf("p_cont is null in %s.\n", name);
    // }
    if(p->state == UNUSED || p->cont == NULL)
80104ff6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff9:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffc:	85 c0                	test   %eax,%eax
80104ffe:	74 0d                	je     8010500d <c_procdump+0x29>
80105000:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105003:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105009:	85 c0                	test   %eax,%eax
8010500b:	75 05                	jne    80105012 <c_procdump+0x2e>
      continue;
8010500d:	e9 ec 00 00 00       	jmp    801050fe <c_procdump+0x11a>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105015:	8b 40 0c             	mov    0xc(%eax),%eax
80105018:	83 f8 05             	cmp    $0x5,%eax
8010501b:	77 23                	ja     80105040 <c_procdump+0x5c>
8010501d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105020:	8b 40 0c             	mov    0xc(%eax),%eax
80105023:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010502a:	85 c0                	test   %eax,%eax
8010502c:	74 12                	je     80105040 <c_procdump+0x5c>
      state = states[p->state];
8010502e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105031:	8b 40 0c             	mov    0xc(%eax),%eax
80105034:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010503b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010503e:	eb 07                	jmp    80105047 <c_procdump+0x63>
    else
      state = "???";
80105040:	c7 45 ec 16 97 10 80 	movl   $0x80109716,-0x14(%ebp)

    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
80105047:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105050:	8d 50 18             	lea    0x18(%eax),%edx
80105053:	8b 45 08             	mov    0x8(%ebp),%eax
80105056:	89 44 24 04          	mov    %eax,0x4(%esp)
8010505a:	89 14 24             	mov    %edx,(%esp)
8010505d:	e8 de f8 ff ff       	call   80104940 <strcmp1>
80105062:	85 c0                	test   %eax,%eax
80105064:	0f 85 94 00 00 00    	jne    801050fe <c_procdump+0x11a>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
8010506a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506d:	8d 50 6c             	lea    0x6c(%eax),%edx
80105070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105073:	8b 40 10             	mov    0x10(%eax),%eax
80105076:	89 54 24 10          	mov    %edx,0x10(%esp)
8010507a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010507d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105081:	8b 55 08             	mov    0x8(%ebp),%edx
80105084:	89 54 24 08          	mov    %edx,0x8(%esp)
80105088:	89 44 24 04          	mov    %eax,0x4(%esp)
8010508c:	c7 04 24 28 97 10 80 	movl   $0x80109728,(%esp)
80105093:	e8 29 b3 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
80105098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509b:	8b 40 0c             	mov    0xc(%eax),%eax
8010509e:	83 f8 02             	cmp    $0x2,%eax
801050a1:	75 4f                	jne    801050f2 <c_procdump+0x10e>
        getcallerpcs((uint*)p->context->ebp+2, pc);
801050a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801050a9:	8b 40 0c             	mov    0xc(%eax),%eax
801050ac:	83 c0 08             	add    $0x8,%eax
801050af:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801050b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801050b6:	89 04 24             	mov    %eax,(%esp)
801050b9:	e8 88 02 00 00       	call   80105346 <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
801050be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050c5:	eb 1a                	jmp    801050e1 <c_procdump+0xfd>
          cprintf(" %p", pc[i]);
801050c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ca:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801050d2:	c7 04 24 34 97 10 80 	movl   $0x80109734,(%esp)
801050d9:	e8 e3 b2 ff ff       	call   801003c1 <cprintf>
    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
801050de:	ff 45 f4             	incl   -0xc(%ebp)
801050e1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050e5:	7f 0b                	jg     801050f2 <c_procdump+0x10e>
801050e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ea:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050ee:	85 c0                	test   %eax,%eax
801050f0:	75 d5                	jne    801050c7 <c_procdump+0xe3>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
801050f2:	c7 04 24 38 97 10 80 	movl   $0x80109738,(%esp)
801050f9:	e8 c3 b2 ff ff       	call   801003c1 <cprintf>
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050fe:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105105:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
8010510c:	0f 82 e4 fe ff ff    	jb     80104ff6 <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
80105112:	c9                   	leave  
80105113:	c3                   	ret    

80105114 <cont_disk>:

void
cont_disk(void){
80105114:	55                   	push   %ebp
80105115:	89 e5                	mov    %esp,%ebp
  
}
80105117:	5d                   	pop    %ebp
80105118:	c3                   	ret    

80105119 <initp>:


struct proc* initp(void){
80105119:	55                   	push   %ebp
8010511a:	89 e5                	mov    %esp,%ebp
  return initproc;
8010511c:	a1 00 c9 10 80       	mov    0x8010c900,%eax
}
80105121:	5d                   	pop    %ebp
80105122:	c3                   	ret    

80105123 <c_proc>:

struct proc* c_proc(void){
80105123:	55                   	push   %ebp
80105124:	89 e5                	mov    %esp,%ebp
80105126:	83 ec 08             	sub    $0x8,%esp
  return myproc();
80105129:	e8 75 f2 ff ff       	call   801043a3 <myproc>
}
8010512e:	c9                   	leave  
8010512f:	c3                   	ret    

80105130 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105130:	55                   	push   %ebp
80105131:	89 e5                	mov    %esp,%ebp
80105133:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105136:	8b 45 08             	mov    0x8(%ebp),%eax
80105139:	83 c0 04             	add    $0x4,%eax
8010513c:	c7 44 24 04 86 97 10 	movl   $0x80109786,0x4(%esp)
80105143:	80 
80105144:	89 04 24             	mov    %eax,(%esp)
80105147:	e8 22 01 00 00       	call   8010526e <initlock>
  lk->name = name;
8010514c:	8b 45 08             	mov    0x8(%ebp),%eax
8010514f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105152:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105155:	8b 45 08             	mov    0x8(%ebp),%eax
80105158:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010515e:	8b 45 08             	mov    0x8(%ebp),%eax
80105161:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105168:	c9                   	leave  
80105169:	c3                   	ret    

8010516a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010516a:	55                   	push   %ebp
8010516b:	89 e5                	mov    %esp,%ebp
8010516d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105170:	8b 45 08             	mov    0x8(%ebp),%eax
80105173:	83 c0 04             	add    $0x4,%eax
80105176:	89 04 24             	mov    %eax,(%esp)
80105179:	e8 11 01 00 00       	call   8010528f <acquire>
  while (lk->locked) {
8010517e:	eb 15                	jmp    80105195 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105180:	8b 45 08             	mov    0x8(%ebp),%eax
80105183:	83 c0 04             	add    $0x4,%eax
80105186:	89 44 24 04          	mov    %eax,0x4(%esp)
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	89 04 24             	mov    %eax,(%esp)
80105190:	e8 bf fa ff ff       	call   80104c54 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105195:	8b 45 08             	mov    0x8(%ebp),%eax
80105198:	8b 00                	mov    (%eax),%eax
8010519a:	85 c0                	test   %eax,%eax
8010519c:	75 e2                	jne    80105180 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010519e:	8b 45 08             	mov    0x8(%ebp),%eax
801051a1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051a7:	e8 f7 f1 ff ff       	call   801043a3 <myproc>
801051ac:	8b 50 10             	mov    0x10(%eax),%edx
801051af:	8b 45 08             	mov    0x8(%ebp),%eax
801051b2:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051b5:	8b 45 08             	mov    0x8(%ebp),%eax
801051b8:	83 c0 04             	add    $0x4,%eax
801051bb:	89 04 24             	mov    %eax,(%esp)
801051be:	e8 36 01 00 00       	call   801052f9 <release>
}
801051c3:	c9                   	leave  
801051c4:	c3                   	ret    

801051c5 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051c5:	55                   	push   %ebp
801051c6:	89 e5                	mov    %esp,%ebp
801051c8:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801051cb:	8b 45 08             	mov    0x8(%ebp),%eax
801051ce:	83 c0 04             	add    $0x4,%eax
801051d1:	89 04 24             	mov    %eax,(%esp)
801051d4:	e8 b6 00 00 00       	call   8010528f <acquire>
  lk->locked = 0;
801051d9:	8b 45 08             	mov    0x8(%ebp),%eax
801051dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051e2:	8b 45 08             	mov    0x8(%ebp),%eax
801051e5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051ec:	8b 45 08             	mov    0x8(%ebp),%eax
801051ef:	89 04 24             	mov    %eax,(%esp)
801051f2:	e8 34 fb ff ff       	call   80104d2b <wakeup>
  release(&lk->lk);
801051f7:	8b 45 08             	mov    0x8(%ebp),%eax
801051fa:	83 c0 04             	add    $0x4,%eax
801051fd:	89 04 24             	mov    %eax,(%esp)
80105200:	e8 f4 00 00 00       	call   801052f9 <release>
}
80105205:	c9                   	leave  
80105206:	c3                   	ret    

80105207 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105207:	55                   	push   %ebp
80105208:	89 e5                	mov    %esp,%ebp
8010520a:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
8010520d:	8b 45 08             	mov    0x8(%ebp),%eax
80105210:	83 c0 04             	add    $0x4,%eax
80105213:	89 04 24             	mov    %eax,(%esp)
80105216:	e8 74 00 00 00       	call   8010528f <acquire>
  r = lk->locked;
8010521b:	8b 45 08             	mov    0x8(%ebp),%eax
8010521e:	8b 00                	mov    (%eax),%eax
80105220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105223:	8b 45 08             	mov    0x8(%ebp),%eax
80105226:	83 c0 04             	add    $0x4,%eax
80105229:	89 04 24             	mov    %eax,(%esp)
8010522c:	e8 c8 00 00 00       	call   801052f9 <release>
  return r;
80105231:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105234:	c9                   	leave  
80105235:	c3                   	ret    
	...

80105238 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105238:	55                   	push   %ebp
80105239:	89 e5                	mov    %esp,%ebp
8010523b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010523e:	9c                   	pushf  
8010523f:	58                   	pop    %eax
80105240:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105243:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105246:	c9                   	leave  
80105247:	c3                   	ret    

80105248 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105248:	55                   	push   %ebp
80105249:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010524b:	fa                   	cli    
}
8010524c:	5d                   	pop    %ebp
8010524d:	c3                   	ret    

8010524e <sti>:

static inline void
sti(void)
{
8010524e:	55                   	push   %ebp
8010524f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105251:	fb                   	sti    
}
80105252:	5d                   	pop    %ebp
80105253:	c3                   	ret    

80105254 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105254:	55                   	push   %ebp
80105255:	89 e5                	mov    %esp,%ebp
80105257:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010525a:	8b 55 08             	mov    0x8(%ebp),%edx
8010525d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105260:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105263:	f0 87 02             	lock xchg %eax,(%edx)
80105266:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105269:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010526c:	c9                   	leave  
8010526d:	c3                   	ret    

8010526e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010526e:	55                   	push   %ebp
8010526f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	8b 55 0c             	mov    0xc(%ebp),%edx
80105277:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010527a:	8b 45 08             	mov    0x8(%ebp),%eax
8010527d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105283:	8b 45 08             	mov    0x8(%ebp),%eax
80105286:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010528d:	5d                   	pop    %ebp
8010528e:	c3                   	ret    

8010528f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010528f:	55                   	push   %ebp
80105290:	89 e5                	mov    %esp,%ebp
80105292:	53                   	push   %ebx
80105293:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105296:	e8 53 01 00 00       	call   801053ee <pushcli>
  if(holding(lk))
8010529b:	8b 45 08             	mov    0x8(%ebp),%eax
8010529e:	89 04 24             	mov    %eax,(%esp)
801052a1:	e8 17 01 00 00       	call   801053bd <holding>
801052a6:	85 c0                	test   %eax,%eax
801052a8:	74 0c                	je     801052b6 <acquire+0x27>
    panic("acquire");
801052aa:	c7 04 24 91 97 10 80 	movl   $0x80109791,(%esp)
801052b1:	e8 9e b2 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052b6:	90                   	nop
801052b7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801052c1:	00 
801052c2:	89 04 24             	mov    %eax,(%esp)
801052c5:	e8 8a ff ff ff       	call   80105254 <xchg>
801052ca:	85 c0                	test   %eax,%eax
801052cc:	75 e9                	jne    801052b7 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801052ce:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801052d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
801052d6:	e8 44 f0 ff ff       	call   8010431f <mycpu>
801052db:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801052de:	8b 45 08             	mov    0x8(%ebp),%eax
801052e1:	83 c0 0c             	add    $0xc,%eax
801052e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801052e8:	8d 45 08             	lea    0x8(%ebp),%eax
801052eb:	89 04 24             	mov    %eax,(%esp)
801052ee:	e8 53 00 00 00       	call   80105346 <getcallerpcs>
}
801052f3:	83 c4 14             	add    $0x14,%esp
801052f6:	5b                   	pop    %ebx
801052f7:	5d                   	pop    %ebp
801052f8:	c3                   	ret    

801052f9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801052f9:	55                   	push   %ebp
801052fa:	89 e5                	mov    %esp,%ebp
801052fc:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801052ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105302:	89 04 24             	mov    %eax,(%esp)
80105305:	e8 b3 00 00 00       	call   801053bd <holding>
8010530a:	85 c0                	test   %eax,%eax
8010530c:	75 0c                	jne    8010531a <release+0x21>
    panic("release");
8010530e:	c7 04 24 99 97 10 80 	movl   $0x80109799,(%esp)
80105315:	e8 3a b2 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010531a:	8b 45 08             	mov    0x8(%ebp),%eax
8010531d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105324:	8b 45 08             	mov    0x8(%ebp),%eax
80105327:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010532e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105333:	8b 45 08             	mov    0x8(%ebp),%eax
80105336:	8b 55 08             	mov    0x8(%ebp),%edx
80105339:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010533f:	e8 f4 00 00 00       	call   80105438 <popcli>
}
80105344:	c9                   	leave  
80105345:	c3                   	ret    

80105346 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105346:	55                   	push   %ebp
80105347:	89 e5                	mov    %esp,%ebp
80105349:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010534c:	8b 45 08             	mov    0x8(%ebp),%eax
8010534f:	83 e8 08             	sub    $0x8,%eax
80105352:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105355:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010535c:	eb 37                	jmp    80105395 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010535e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105362:	74 37                	je     8010539b <getcallerpcs+0x55>
80105364:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010536b:	76 2e                	jbe    8010539b <getcallerpcs+0x55>
8010536d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105371:	74 28                	je     8010539b <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105373:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105376:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010537d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105380:	01 c2                	add    %eax,%edx
80105382:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105385:	8b 40 04             	mov    0x4(%eax),%eax
80105388:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010538a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538d:	8b 00                	mov    (%eax),%eax
8010538f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105392:	ff 45 f8             	incl   -0x8(%ebp)
80105395:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105399:	7e c3                	jle    8010535e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010539b:	eb 18                	jmp    801053b5 <getcallerpcs+0x6f>
    pcs[i] = 0;
8010539d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053aa:	01 d0                	add    %edx,%eax
801053ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053b2:	ff 45 f8             	incl   -0x8(%ebp)
801053b5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053b9:	7e e2                	jle    8010539d <getcallerpcs+0x57>
    pcs[i] = 0;
}
801053bb:	c9                   	leave  
801053bc:	c3                   	ret    

801053bd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053bd:	55                   	push   %ebp
801053be:	89 e5                	mov    %esp,%ebp
801053c0:	53                   	push   %ebx
801053c1:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801053c4:	8b 45 08             	mov    0x8(%ebp),%eax
801053c7:	8b 00                	mov    (%eax),%eax
801053c9:	85 c0                	test   %eax,%eax
801053cb:	74 16                	je     801053e3 <holding+0x26>
801053cd:	8b 45 08             	mov    0x8(%ebp),%eax
801053d0:	8b 58 08             	mov    0x8(%eax),%ebx
801053d3:	e8 47 ef ff ff       	call   8010431f <mycpu>
801053d8:	39 c3                	cmp    %eax,%ebx
801053da:	75 07                	jne    801053e3 <holding+0x26>
801053dc:	b8 01 00 00 00       	mov    $0x1,%eax
801053e1:	eb 05                	jmp    801053e8 <holding+0x2b>
801053e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053e8:	83 c4 04             	add    $0x4,%esp
801053eb:	5b                   	pop    %ebx
801053ec:	5d                   	pop    %ebp
801053ed:	c3                   	ret    

801053ee <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801053ee:	55                   	push   %ebp
801053ef:	89 e5                	mov    %esp,%ebp
801053f1:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801053f4:	e8 3f fe ff ff       	call   80105238 <readeflags>
801053f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801053fc:	e8 47 fe ff ff       	call   80105248 <cli>
  if(mycpu()->ncli == 0)
80105401:	e8 19 ef ff ff       	call   8010431f <mycpu>
80105406:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010540c:	85 c0                	test   %eax,%eax
8010540e:	75 14                	jne    80105424 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105410:	e8 0a ef ff ff       	call   8010431f <mycpu>
80105415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105418:	81 e2 00 02 00 00    	and    $0x200,%edx
8010541e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105424:	e8 f6 ee ff ff       	call   8010431f <mycpu>
80105429:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010542f:	42                   	inc    %edx
80105430:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105436:	c9                   	leave  
80105437:	c3                   	ret    

80105438 <popcli>:

void
popcli(void)
{
80105438:	55                   	push   %ebp
80105439:	89 e5                	mov    %esp,%ebp
8010543b:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010543e:	e8 f5 fd ff ff       	call   80105238 <readeflags>
80105443:	25 00 02 00 00       	and    $0x200,%eax
80105448:	85 c0                	test   %eax,%eax
8010544a:	74 0c                	je     80105458 <popcli+0x20>
    panic("popcli - interruptible");
8010544c:	c7 04 24 a1 97 10 80 	movl   $0x801097a1,(%esp)
80105453:	e8 fc b0 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105458:	e8 c2 ee ff ff       	call   8010431f <mycpu>
8010545d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105463:	4a                   	dec    %edx
80105464:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010546a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105470:	85 c0                	test   %eax,%eax
80105472:	79 0c                	jns    80105480 <popcli+0x48>
    panic("popcli");
80105474:	c7 04 24 b8 97 10 80 	movl   $0x801097b8,(%esp)
8010547b:	e8 d4 b0 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105480:	e8 9a ee ff ff       	call   8010431f <mycpu>
80105485:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010548b:	85 c0                	test   %eax,%eax
8010548d:	75 14                	jne    801054a3 <popcli+0x6b>
8010548f:	e8 8b ee ff ff       	call   8010431f <mycpu>
80105494:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010549a:	85 c0                	test   %eax,%eax
8010549c:	74 05                	je     801054a3 <popcli+0x6b>
    sti();
8010549e:	e8 ab fd ff ff       	call   8010524e <sti>
}
801054a3:	c9                   	leave  
801054a4:	c3                   	ret    
801054a5:	00 00                	add    %al,(%eax)
	...

801054a8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801054a8:	55                   	push   %ebp
801054a9:	89 e5                	mov    %esp,%ebp
801054ab:	57                   	push   %edi
801054ac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054b0:	8b 55 10             	mov    0x10(%ebp),%edx
801054b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b6:	89 cb                	mov    %ecx,%ebx
801054b8:	89 df                	mov    %ebx,%edi
801054ba:	89 d1                	mov    %edx,%ecx
801054bc:	fc                   	cld    
801054bd:	f3 aa                	rep stos %al,%es:(%edi)
801054bf:	89 ca                	mov    %ecx,%edx
801054c1:	89 fb                	mov    %edi,%ebx
801054c3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054c6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801054c9:	5b                   	pop    %ebx
801054ca:	5f                   	pop    %edi
801054cb:	5d                   	pop    %ebp
801054cc:	c3                   	ret    

801054cd <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801054cd:	55                   	push   %ebp
801054ce:	89 e5                	mov    %esp,%ebp
801054d0:	57                   	push   %edi
801054d1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054d5:	8b 55 10             	mov    0x10(%ebp),%edx
801054d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801054db:	89 cb                	mov    %ecx,%ebx
801054dd:	89 df                	mov    %ebx,%edi
801054df:	89 d1                	mov    %edx,%ecx
801054e1:	fc                   	cld    
801054e2:	f3 ab                	rep stos %eax,%es:(%edi)
801054e4:	89 ca                	mov    %ecx,%edx
801054e6:	89 fb                	mov    %edi,%ebx
801054e8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054eb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801054ee:	5b                   	pop    %ebx
801054ef:	5f                   	pop    %edi
801054f0:	5d                   	pop    %ebp
801054f1:	c3                   	ret    

801054f2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801054f2:	55                   	push   %ebp
801054f3:	89 e5                	mov    %esp,%ebp
801054f5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801054f8:	8b 45 08             	mov    0x8(%ebp),%eax
801054fb:	83 e0 03             	and    $0x3,%eax
801054fe:	85 c0                	test   %eax,%eax
80105500:	75 49                	jne    8010554b <memset+0x59>
80105502:	8b 45 10             	mov    0x10(%ebp),%eax
80105505:	83 e0 03             	and    $0x3,%eax
80105508:	85 c0                	test   %eax,%eax
8010550a:	75 3f                	jne    8010554b <memset+0x59>
    c &= 0xFF;
8010550c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105513:	8b 45 10             	mov    0x10(%ebp),%eax
80105516:	c1 e8 02             	shr    $0x2,%eax
80105519:	89 c2                	mov    %eax,%edx
8010551b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551e:	c1 e0 18             	shl    $0x18,%eax
80105521:	89 c1                	mov    %eax,%ecx
80105523:	8b 45 0c             	mov    0xc(%ebp),%eax
80105526:	c1 e0 10             	shl    $0x10,%eax
80105529:	09 c1                	or     %eax,%ecx
8010552b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552e:	c1 e0 08             	shl    $0x8,%eax
80105531:	09 c8                	or     %ecx,%eax
80105533:	0b 45 0c             	or     0xc(%ebp),%eax
80105536:	89 54 24 08          	mov    %edx,0x8(%esp)
8010553a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010553e:	8b 45 08             	mov    0x8(%ebp),%eax
80105541:	89 04 24             	mov    %eax,(%esp)
80105544:	e8 84 ff ff ff       	call   801054cd <stosl>
80105549:	eb 19                	jmp    80105564 <memset+0x72>
  } else
    stosb(dst, c, n);
8010554b:	8b 45 10             	mov    0x10(%ebp),%eax
8010554e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105552:	8b 45 0c             	mov    0xc(%ebp),%eax
80105555:	89 44 24 04          	mov    %eax,0x4(%esp)
80105559:	8b 45 08             	mov    0x8(%ebp),%eax
8010555c:	89 04 24             	mov    %eax,(%esp)
8010555f:	e8 44 ff ff ff       	call   801054a8 <stosb>
  return dst;
80105564:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105567:	c9                   	leave  
80105568:	c3                   	ret    

80105569 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105569:	55                   	push   %ebp
8010556a:	89 e5                	mov    %esp,%ebp
8010556c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010556f:	8b 45 08             	mov    0x8(%ebp),%eax
80105572:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105575:	8b 45 0c             	mov    0xc(%ebp),%eax
80105578:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010557b:	eb 2a                	jmp    801055a7 <memcmp+0x3e>
    if(*s1 != *s2)
8010557d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105580:	8a 10                	mov    (%eax),%dl
80105582:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105585:	8a 00                	mov    (%eax),%al
80105587:	38 c2                	cmp    %al,%dl
80105589:	74 16                	je     801055a1 <memcmp+0x38>
      return *s1 - *s2;
8010558b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010558e:	8a 00                	mov    (%eax),%al
80105590:	0f b6 d0             	movzbl %al,%edx
80105593:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105596:	8a 00                	mov    (%eax),%al
80105598:	0f b6 c0             	movzbl %al,%eax
8010559b:	29 c2                	sub    %eax,%edx
8010559d:	89 d0                	mov    %edx,%eax
8010559f:	eb 18                	jmp    801055b9 <memcmp+0x50>
    s1++, s2++;
801055a1:	ff 45 fc             	incl   -0x4(%ebp)
801055a4:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801055a7:	8b 45 10             	mov    0x10(%ebp),%eax
801055aa:	8d 50 ff             	lea    -0x1(%eax),%edx
801055ad:	89 55 10             	mov    %edx,0x10(%ebp)
801055b0:	85 c0                	test   %eax,%eax
801055b2:	75 c9                	jne    8010557d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801055b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055b9:	c9                   	leave  
801055ba:	c3                   	ret    

801055bb <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055bb:	55                   	push   %ebp
801055bc:	89 e5                	mov    %esp,%ebp
801055be:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801055c7:	8b 45 08             	mov    0x8(%ebp),%eax
801055ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801055cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055d3:	73 3a                	jae    8010560f <memmove+0x54>
801055d5:	8b 45 10             	mov    0x10(%ebp),%eax
801055d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055db:	01 d0                	add    %edx,%eax
801055dd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055e0:	76 2d                	jbe    8010560f <memmove+0x54>
    s += n;
801055e2:	8b 45 10             	mov    0x10(%ebp),%eax
801055e5:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801055e8:	8b 45 10             	mov    0x10(%ebp),%eax
801055eb:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801055ee:	eb 10                	jmp    80105600 <memmove+0x45>
      *--d = *--s;
801055f0:	ff 4d f8             	decl   -0x8(%ebp)
801055f3:	ff 4d fc             	decl   -0x4(%ebp)
801055f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f9:	8a 10                	mov    (%eax),%dl
801055fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055fe:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105600:	8b 45 10             	mov    0x10(%ebp),%eax
80105603:	8d 50 ff             	lea    -0x1(%eax),%edx
80105606:	89 55 10             	mov    %edx,0x10(%ebp)
80105609:	85 c0                	test   %eax,%eax
8010560b:	75 e3                	jne    801055f0 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010560d:	eb 25                	jmp    80105634 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010560f:	eb 16                	jmp    80105627 <memmove+0x6c>
      *d++ = *s++;
80105611:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105614:	8d 50 01             	lea    0x1(%eax),%edx
80105617:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010561a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010561d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105620:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105623:	8a 12                	mov    (%edx),%dl
80105625:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105627:	8b 45 10             	mov    0x10(%ebp),%eax
8010562a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010562d:	89 55 10             	mov    %edx,0x10(%ebp)
80105630:	85 c0                	test   %eax,%eax
80105632:	75 dd                	jne    80105611 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105634:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105637:	c9                   	leave  
80105638:	c3                   	ret    

80105639 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105639:	55                   	push   %ebp
8010563a:	89 e5                	mov    %esp,%ebp
8010563c:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010563f:	8b 45 10             	mov    0x10(%ebp),%eax
80105642:	89 44 24 08          	mov    %eax,0x8(%esp)
80105646:	8b 45 0c             	mov    0xc(%ebp),%eax
80105649:	89 44 24 04          	mov    %eax,0x4(%esp)
8010564d:	8b 45 08             	mov    0x8(%ebp),%eax
80105650:	89 04 24             	mov    %eax,(%esp)
80105653:	e8 63 ff ff ff       	call   801055bb <memmove>
}
80105658:	c9                   	leave  
80105659:	c3                   	ret    

8010565a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010565a:	55                   	push   %ebp
8010565b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010565d:	eb 09                	jmp    80105668 <strncmp+0xe>
    n--, p++, q++;
8010565f:	ff 4d 10             	decl   0x10(%ebp)
80105662:	ff 45 08             	incl   0x8(%ebp)
80105665:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105668:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010566c:	74 17                	je     80105685 <strncmp+0x2b>
8010566e:	8b 45 08             	mov    0x8(%ebp),%eax
80105671:	8a 00                	mov    (%eax),%al
80105673:	84 c0                	test   %al,%al
80105675:	74 0e                	je     80105685 <strncmp+0x2b>
80105677:	8b 45 08             	mov    0x8(%ebp),%eax
8010567a:	8a 10                	mov    (%eax),%dl
8010567c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010567f:	8a 00                	mov    (%eax),%al
80105681:	38 c2                	cmp    %al,%dl
80105683:	74 da                	je     8010565f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105685:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105689:	75 07                	jne    80105692 <strncmp+0x38>
    return 0;
8010568b:	b8 00 00 00 00       	mov    $0x0,%eax
80105690:	eb 14                	jmp    801056a6 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105692:	8b 45 08             	mov    0x8(%ebp),%eax
80105695:	8a 00                	mov    (%eax),%al
80105697:	0f b6 d0             	movzbl %al,%edx
8010569a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569d:	8a 00                	mov    (%eax),%al
8010569f:	0f b6 c0             	movzbl %al,%eax
801056a2:	29 c2                	sub    %eax,%edx
801056a4:	89 d0                	mov    %edx,%eax
}
801056a6:	5d                   	pop    %ebp
801056a7:	c3                   	ret    

801056a8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056a8:	55                   	push   %ebp
801056a9:	89 e5                	mov    %esp,%ebp
801056ab:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056ae:	8b 45 08             	mov    0x8(%ebp),%eax
801056b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056b4:	90                   	nop
801056b5:	8b 45 10             	mov    0x10(%ebp),%eax
801056b8:	8d 50 ff             	lea    -0x1(%eax),%edx
801056bb:	89 55 10             	mov    %edx,0x10(%ebp)
801056be:	85 c0                	test   %eax,%eax
801056c0:	7e 1c                	jle    801056de <strncpy+0x36>
801056c2:	8b 45 08             	mov    0x8(%ebp),%eax
801056c5:	8d 50 01             	lea    0x1(%eax),%edx
801056c8:	89 55 08             	mov    %edx,0x8(%ebp)
801056cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801056ce:	8d 4a 01             	lea    0x1(%edx),%ecx
801056d1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801056d4:	8a 12                	mov    (%edx),%dl
801056d6:	88 10                	mov    %dl,(%eax)
801056d8:	8a 00                	mov    (%eax),%al
801056da:	84 c0                	test   %al,%al
801056dc:	75 d7                	jne    801056b5 <strncpy+0xd>
    ;
  while(n-- > 0)
801056de:	eb 0c                	jmp    801056ec <strncpy+0x44>
    *s++ = 0;
801056e0:	8b 45 08             	mov    0x8(%ebp),%eax
801056e3:	8d 50 01             	lea    0x1(%eax),%edx
801056e6:	89 55 08             	mov    %edx,0x8(%ebp)
801056e9:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801056ec:	8b 45 10             	mov    0x10(%ebp),%eax
801056ef:	8d 50 ff             	lea    -0x1(%eax),%edx
801056f2:	89 55 10             	mov    %edx,0x10(%ebp)
801056f5:	85 c0                	test   %eax,%eax
801056f7:	7f e7                	jg     801056e0 <strncpy+0x38>
    *s++ = 0;
  return os;
801056f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056fc:	c9                   	leave  
801056fd:	c3                   	ret    

801056fe <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801056fe:	55                   	push   %ebp
801056ff:	89 e5                	mov    %esp,%ebp
80105701:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105704:	8b 45 08             	mov    0x8(%ebp),%eax
80105707:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010570a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010570e:	7f 05                	jg     80105715 <safestrcpy+0x17>
    return os;
80105710:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105713:	eb 2e                	jmp    80105743 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105715:	ff 4d 10             	decl   0x10(%ebp)
80105718:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010571c:	7e 1c                	jle    8010573a <safestrcpy+0x3c>
8010571e:	8b 45 08             	mov    0x8(%ebp),%eax
80105721:	8d 50 01             	lea    0x1(%eax),%edx
80105724:	89 55 08             	mov    %edx,0x8(%ebp)
80105727:	8b 55 0c             	mov    0xc(%ebp),%edx
8010572a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010572d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105730:	8a 12                	mov    (%edx),%dl
80105732:	88 10                	mov    %dl,(%eax)
80105734:	8a 00                	mov    (%eax),%al
80105736:	84 c0                	test   %al,%al
80105738:	75 db                	jne    80105715 <safestrcpy+0x17>
    ;
  *s = 0;
8010573a:	8b 45 08             	mov    0x8(%ebp),%eax
8010573d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105740:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105743:	c9                   	leave  
80105744:	c3                   	ret    

80105745 <strlen>:

int
strlen(const char *s)
{
80105745:	55                   	push   %ebp
80105746:	89 e5                	mov    %esp,%ebp
80105748:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010574b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105752:	eb 03                	jmp    80105757 <strlen+0x12>
80105754:	ff 45 fc             	incl   -0x4(%ebp)
80105757:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010575a:	8b 45 08             	mov    0x8(%ebp),%eax
8010575d:	01 d0                	add    %edx,%eax
8010575f:	8a 00                	mov    (%eax),%al
80105761:	84 c0                	test   %al,%al
80105763:	75 ef                	jne    80105754 <strlen+0xf>
    ;
  return n;
80105765:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105768:	c9                   	leave  
80105769:	c3                   	ret    
	...

8010576c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010576c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105770:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105774:	55                   	push   %ebp
  pushl %ebx
80105775:	53                   	push   %ebx
  pushl %esi
80105776:	56                   	push   %esi
  pushl %edi
80105777:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105778:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010577a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010577c:	5f                   	pop    %edi
  popl %esi
8010577d:	5e                   	pop    %esi
  popl %ebx
8010577e:	5b                   	pop    %ebx
  popl %ebp
8010577f:	5d                   	pop    %ebp
  ret
80105780:	c3                   	ret    
80105781:	00 00                	add    %al,(%eax)
	...

80105784 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105784:	55                   	push   %ebp
80105785:	89 e5                	mov    %esp,%ebp
80105787:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010578a:	e8 14 ec ff ff       	call   801043a3 <myproc>
8010578f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105795:	8b 00                	mov    (%eax),%eax
80105797:	3b 45 08             	cmp    0x8(%ebp),%eax
8010579a:	76 0f                	jbe    801057ab <fetchint+0x27>
8010579c:	8b 45 08             	mov    0x8(%ebp),%eax
8010579f:	8d 50 04             	lea    0x4(%eax),%edx
801057a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a5:	8b 00                	mov    (%eax),%eax
801057a7:	39 c2                	cmp    %eax,%edx
801057a9:	76 07                	jbe    801057b2 <fetchint+0x2e>
    return -1;
801057ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b0:	eb 0f                	jmp    801057c1 <fetchint+0x3d>
  *ip = *(int*)(addr);
801057b2:	8b 45 08             	mov    0x8(%ebp),%eax
801057b5:	8b 10                	mov    (%eax),%edx
801057b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ba:	89 10                	mov    %edx,(%eax)
  return 0;
801057bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057c1:	c9                   	leave  
801057c2:	c3                   	ret    

801057c3 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801057c3:	55                   	push   %ebp
801057c4:	89 e5                	mov    %esp,%ebp
801057c6:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801057c9:	e8 d5 eb ff ff       	call   801043a3 <myproc>
801057ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801057d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d4:	8b 00                	mov    (%eax),%eax
801057d6:	3b 45 08             	cmp    0x8(%ebp),%eax
801057d9:	77 07                	ja     801057e2 <fetchstr+0x1f>
    return -1;
801057db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e0:	eb 41                	jmp    80105823 <fetchstr+0x60>
  *pp = (char*)addr;
801057e2:	8b 55 08             	mov    0x8(%ebp),%edx
801057e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e8:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801057ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ed:	8b 00                	mov    (%eax),%eax
801057ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801057f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f5:	8b 00                	mov    (%eax),%eax
801057f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057fa:	eb 1a                	jmp    80105816 <fetchstr+0x53>
    if(*s == 0)
801057fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ff:	8a 00                	mov    (%eax),%al
80105801:	84 c0                	test   %al,%al
80105803:	75 0e                	jne    80105813 <fetchstr+0x50>
      return s - *pp;
80105805:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010580b:	8b 00                	mov    (%eax),%eax
8010580d:	29 c2                	sub    %eax,%edx
8010580f:	89 d0                	mov    %edx,%eax
80105811:	eb 10                	jmp    80105823 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105813:	ff 45 f4             	incl   -0xc(%ebp)
80105816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105819:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010581c:	72 de                	jb     801057fc <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
8010581e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105823:	c9                   	leave  
80105824:	c3                   	ret    

80105825 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105825:	55                   	push   %ebp
80105826:	89 e5                	mov    %esp,%ebp
80105828:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010582b:	e8 73 eb ff ff       	call   801043a3 <myproc>
80105830:	8b 40 18             	mov    0x18(%eax),%eax
80105833:	8b 50 44             	mov    0x44(%eax),%edx
80105836:	8b 45 08             	mov    0x8(%ebp),%eax
80105839:	c1 e0 02             	shl    $0x2,%eax
8010583c:	01 d0                	add    %edx,%eax
8010583e:	8d 50 04             	lea    0x4(%eax),%edx
80105841:	8b 45 0c             	mov    0xc(%ebp),%eax
80105844:	89 44 24 04          	mov    %eax,0x4(%esp)
80105848:	89 14 24             	mov    %edx,(%esp)
8010584b:	e8 34 ff ff ff       	call   80105784 <fetchint>
}
80105850:	c9                   	leave  
80105851:	c3                   	ret    

80105852 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105852:	55                   	push   %ebp
80105853:	89 e5                	mov    %esp,%ebp
80105855:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105858:	e8 46 eb ff ff       	call   801043a3 <myproc>
8010585d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105860:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105863:	89 44 24 04          	mov    %eax,0x4(%esp)
80105867:	8b 45 08             	mov    0x8(%ebp),%eax
8010586a:	89 04 24             	mov    %eax,(%esp)
8010586d:	e8 b3 ff ff ff       	call   80105825 <argint>
80105872:	85 c0                	test   %eax,%eax
80105874:	79 07                	jns    8010587d <argptr+0x2b>
    return -1;
80105876:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587b:	eb 3d                	jmp    801058ba <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010587d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105881:	78 21                	js     801058a4 <argptr+0x52>
80105883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105886:	89 c2                	mov    %eax,%edx
80105888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588b:	8b 00                	mov    (%eax),%eax
8010588d:	39 c2                	cmp    %eax,%edx
8010588f:	73 13                	jae    801058a4 <argptr+0x52>
80105891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105894:	89 c2                	mov    %eax,%edx
80105896:	8b 45 10             	mov    0x10(%ebp),%eax
80105899:	01 c2                	add    %eax,%edx
8010589b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589e:	8b 00                	mov    (%eax),%eax
801058a0:	39 c2                	cmp    %eax,%edx
801058a2:	76 07                	jbe    801058ab <argptr+0x59>
    return -1;
801058a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a9:	eb 0f                	jmp    801058ba <argptr+0x68>
  *pp = (char*)i;
801058ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ae:	89 c2                	mov    %eax,%edx
801058b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b3:	89 10                	mov    %edx,(%eax)
  return 0;
801058b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058ba:	c9                   	leave  
801058bb:	c3                   	ret    

801058bc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801058bc:	55                   	push   %ebp
801058bd:	89 e5                	mov    %esp,%ebp
801058bf:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801058c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c9:	8b 45 08             	mov    0x8(%ebp),%eax
801058cc:	89 04 24             	mov    %eax,(%esp)
801058cf:	e8 51 ff ff ff       	call   80105825 <argint>
801058d4:	85 c0                	test   %eax,%eax
801058d6:	79 07                	jns    801058df <argstr+0x23>
    return -1;
801058d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058dd:	eb 12                	jmp    801058f1 <argstr+0x35>
  return fetchstr(addr, pp);
801058df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801058e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801058e9:	89 04 24             	mov    %eax,(%esp)
801058ec:	e8 d2 fe ff ff       	call   801057c3 <fetchstr>
}
801058f1:	c9                   	leave  
801058f2:	c3                   	ret    

801058f3 <syscall>:
[SYS_max_containers] sys_max_containers,
};

void
syscall(void)
{
801058f3:	55                   	push   %ebp
801058f4:	89 e5                	mov    %esp,%ebp
801058f6:	53                   	push   %ebx
801058f7:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801058fa:	e8 a4 ea ff ff       	call   801043a3 <myproc>
801058ff:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105905:	8b 40 18             	mov    0x18(%eax),%eax
80105908:	8b 40 1c             	mov    0x1c(%eax),%eax
8010590b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010590e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105912:	7e 2d                	jle    80105941 <syscall+0x4e>
80105914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105917:	83 f8 2e             	cmp    $0x2e,%eax
8010591a:	77 25                	ja     80105941 <syscall+0x4e>
8010591c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591f:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105926:	85 c0                	test   %eax,%eax
80105928:	74 17                	je     80105941 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
8010592a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592d:	8b 58 18             	mov    0x18(%eax),%ebx
80105930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105933:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010593a:	ff d0                	call   *%eax
8010593c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010593f:	eb 34                	jmp    80105975 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105944:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594a:	8b 40 10             	mov    0x10(%eax),%eax
8010594d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105950:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105954:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105958:	89 44 24 04          	mov    %eax,0x4(%esp)
8010595c:	c7 04 24 bf 97 10 80 	movl   $0x801097bf,(%esp)
80105963:	e8 59 aa ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596b:	8b 40 18             	mov    0x18(%eax),%eax
8010596e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105975:	83 c4 24             	add    $0x24,%esp
80105978:	5b                   	pop    %ebx
80105979:	5d                   	pop    %ebp
8010597a:	c3                   	ret    
	...

8010597c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010597c:	55                   	push   %ebp
8010597d:	89 e5                	mov    %esp,%ebp
8010597f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105982:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105985:	89 44 24 04          	mov    %eax,0x4(%esp)
80105989:	8b 45 08             	mov    0x8(%ebp),%eax
8010598c:	89 04 24             	mov    %eax,(%esp)
8010598f:	e8 91 fe ff ff       	call   80105825 <argint>
80105994:	85 c0                	test   %eax,%eax
80105996:	79 07                	jns    8010599f <argfd+0x23>
    return -1;
80105998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599d:	eb 4f                	jmp    801059ee <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010599f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a2:	85 c0                	test   %eax,%eax
801059a4:	78 20                	js     801059c6 <argfd+0x4a>
801059a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a9:	83 f8 0f             	cmp    $0xf,%eax
801059ac:	7f 18                	jg     801059c6 <argfd+0x4a>
801059ae:	e8 f0 e9 ff ff       	call   801043a3 <myproc>
801059b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059b6:	83 c2 08             	add    $0x8,%edx
801059b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059c4:	75 07                	jne    801059cd <argfd+0x51>
    return -1;
801059c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cb:	eb 21                	jmp    801059ee <argfd+0x72>
  if(pfd)
801059cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059d1:	74 08                	je     801059db <argfd+0x5f>
    *pfd = fd;
801059d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801059d9:	89 10                	mov    %edx,(%eax)
  if(pf)
801059db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059df:	74 08                	je     801059e9 <argfd+0x6d>
    *pf = f;
801059e1:	8b 45 10             	mov    0x10(%ebp),%eax
801059e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059e7:	89 10                	mov    %edx,(%eax)
  return 0;
801059e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059ee:	c9                   	leave  
801059ef:	c3                   	ret    

801059f0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801059f0:	55                   	push   %ebp
801059f1:	89 e5                	mov    %esp,%ebp
801059f3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801059f6:	e8 a8 e9 ff ff       	call   801043a3 <myproc>
801059fb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801059fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a05:	eb 29                	jmp    80105a30 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a0d:	83 c2 08             	add    $0x8,%edx
80105a10:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a14:	85 c0                	test   %eax,%eax
80105a16:	75 15                	jne    80105a2d <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a1e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a21:	8b 55 08             	mov    0x8(%ebp),%edx
80105a24:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2b:	eb 0e                	jmp    80105a3b <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105a2d:	ff 45 f4             	incl   -0xc(%ebp)
80105a30:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a34:	7e d1                	jle    80105a07 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105a36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a3b:	c9                   	leave  
80105a3c:	c3                   	ret    

80105a3d <sys_dup>:

int
sys_dup(void)
{
80105a3d:	55                   	push   %ebp
80105a3e:	89 e5                	mov    %esp,%ebp
80105a40:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105a43:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a46:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a51:	00 
80105a52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a59:	e8 1e ff ff ff       	call   8010597c <argfd>
80105a5e:	85 c0                	test   %eax,%eax
80105a60:	79 07                	jns    80105a69 <sys_dup+0x2c>
    return -1;
80105a62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a67:	eb 29                	jmp    80105a92 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6c:	89 04 24             	mov    %eax,(%esp)
80105a6f:	e8 7c ff ff ff       	call   801059f0 <fdalloc>
80105a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a7b:	79 07                	jns    80105a84 <sys_dup+0x47>
    return -1;
80105a7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a82:	eb 0e                	jmp    80105a92 <sys_dup+0x55>
  filedup(f);
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	89 04 24             	mov    %eax,(%esp)
80105a8a:	e8 d3 b6 ff ff       	call   80101162 <filedup>
  return fd;
80105a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a92:	c9                   	leave  
80105a93:	c3                   	ret    

80105a94 <sys_read>:

int
sys_read(void)
{
80105a94:	55                   	push   %ebp
80105a95:	89 e5                	mov    %esp,%ebp
80105a97:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105aa8:	00 
80105aa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ab0:	e8 c7 fe ff ff       	call   8010597c <argfd>
80105ab5:	85 c0                	test   %eax,%eax
80105ab7:	78 35                	js     80105aee <sys_read+0x5a>
80105ab9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105abc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ac0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105ac7:	e8 59 fd ff ff       	call   80105825 <argint>
80105acc:	85 c0                	test   %eax,%eax
80105ace:	78 1e                	js     80105aee <sys_read+0x5a>
80105ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ada:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ade:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ae5:	e8 68 fd ff ff       	call   80105852 <argptr>
80105aea:	85 c0                	test   %eax,%eax
80105aec:	79 07                	jns    80105af5 <sys_read+0x61>
    return -1;
80105aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af3:	eb 19                	jmp    80105b0e <sys_read+0x7a>
  return fileread(f, p, n);
80105af5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105af8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b02:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b06:	89 04 24             	mov    %eax,(%esp)
80105b09:	e8 b5 b7 ff ff       	call   801012c3 <fileread>
}
80105b0e:	c9                   	leave  
80105b0f:	c3                   	ret    

80105b10 <sys_write>:

int
sys_write(void)
{
80105b10:	55                   	push   %ebp
80105b11:	89 e5                	mov    %esp,%ebp
80105b13:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b19:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b24:	00 
80105b25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b2c:	e8 4b fe ff ff       	call   8010597c <argfd>
80105b31:	85 c0                	test   %eax,%eax
80105b33:	78 35                	js     80105b6a <sys_write+0x5a>
80105b35:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b38:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b3c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b43:	e8 dd fc ff ff       	call   80105825 <argint>
80105b48:	85 c0                	test   %eax,%eax
80105b4a:	78 1e                	js     80105b6a <sys_write+0x5a>
80105b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b53:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b56:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b61:	e8 ec fc ff ff       	call   80105852 <argptr>
80105b66:	85 c0                	test   %eax,%eax
80105b68:	79 07                	jns    80105b71 <sys_write+0x61>
    return -1;
80105b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6f:	eb 19                	jmp    80105b8a <sys_write+0x7a>
  return filewrite(f, p, n);
80105b71:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b74:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b82:	89 04 24             	mov    %eax,(%esp)
80105b85:	e8 f4 b7 ff ff       	call   8010137e <filewrite>
}
80105b8a:	c9                   	leave  
80105b8b:	c3                   	ret    

80105b8c <sys_close>:

int
sys_close(void)
{
80105b8c:	55                   	push   %ebp
80105b8d:	89 e5                	mov    %esp,%ebp
80105b8f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105b92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b95:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b99:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ba0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ba7:	e8 d0 fd ff ff       	call   8010597c <argfd>
80105bac:	85 c0                	test   %eax,%eax
80105bae:	79 07                	jns    80105bb7 <sys_close+0x2b>
    return -1;
80105bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb5:	eb 23                	jmp    80105bda <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105bb7:	e8 e7 e7 ff ff       	call   801043a3 <myproc>
80105bbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bbf:	83 c2 08             	add    $0x8,%edx
80105bc2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bc9:	00 
  fileclose(f);
80105bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcd:	89 04 24             	mov    %eax,(%esp)
80105bd0:	e8 d5 b5 ff ff       	call   801011aa <fileclose>
  return 0;
80105bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bda:	c9                   	leave  
80105bdb:	c3                   	ret    

80105bdc <sys_fstat>:

int
sys_fstat(void)
{
80105bdc:	55                   	push   %ebp
80105bdd:	89 e5                	mov    %esp,%ebp
80105bdf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105be5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105be9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bf0:	00 
80105bf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bf8:	e8 7f fd ff ff       	call   8010597c <argfd>
80105bfd:	85 c0                	test   %eax,%eax
80105bff:	78 1f                	js     80105c20 <sys_fstat+0x44>
80105c01:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105c08:	00 
80105c09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c17:	e8 36 fc ff ff       	call   80105852 <argptr>
80105c1c:	85 c0                	test   %eax,%eax
80105c1e:	79 07                	jns    80105c27 <sys_fstat+0x4b>
    return -1;
80105c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c25:	eb 12                	jmp    80105c39 <sys_fstat+0x5d>
  return filestat(f, st);
80105c27:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c31:	89 04 24             	mov    %eax,(%esp)
80105c34:	e8 3b b6 ff ff       	call   80101274 <filestat>
}
80105c39:	c9                   	leave  
80105c3a:	c3                   	ret    

80105c3b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c3b:	55                   	push   %ebp
80105c3c:	89 e5                	mov    %esp,%ebp
80105c3e:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c41:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c44:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c4f:	e8 68 fc ff ff       	call   801058bc <argstr>
80105c54:	85 c0                	test   %eax,%eax
80105c56:	78 17                	js     80105c6f <sys_link+0x34>
80105c58:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c66:	e8 51 fc ff ff       	call   801058bc <argstr>
80105c6b:	85 c0                	test   %eax,%eax
80105c6d:	79 0a                	jns    80105c79 <sys_link+0x3e>
    return -1;
80105c6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c74:	e9 3d 01 00 00       	jmp    80105db6 <sys_link+0x17b>

  begin_op();
80105c79:	e8 25 da ff ff       	call   801036a3 <begin_op>
  if((ip = namei(old)) == 0){
80105c7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c81:	89 04 24             	mov    %eax,(%esp)
80105c84:	e8 c7 c9 ff ff       	call   80102650 <namei>
80105c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c90:	75 0f                	jne    80105ca1 <sys_link+0x66>
    end_op();
80105c92:	e8 8e da ff ff       	call   80103725 <end_op>
    return -1;
80105c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9c:	e9 15 01 00 00       	jmp    80105db6 <sys_link+0x17b>
  }

  ilock(ip);
80105ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca4:	89 04 24             	mov    %eax,(%esp)
80105ca7:	e8 16 be ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caf:	8b 40 50             	mov    0x50(%eax),%eax
80105cb2:	66 83 f8 01          	cmp    $0x1,%ax
80105cb6:	75 1a                	jne    80105cd2 <sys_link+0x97>
    iunlockput(ip);
80105cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbb:	89 04 24             	mov    %eax,(%esp)
80105cbe:	e8 fe bf ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105cc3:	e8 5d da ff ff       	call   80103725 <end_op>
    return -1;
80105cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccd:	e9 e4 00 00 00       	jmp    80105db6 <sys_link+0x17b>
  }

  ip->nlink++;
80105cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd5:	66 8b 40 56          	mov    0x56(%eax),%ax
80105cd9:	40                   	inc    %eax
80105cda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cdd:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce4:	89 04 24             	mov    %eax,(%esp)
80105ce7:	e8 13 bc ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cef:	89 04 24             	mov    %eax,(%esp)
80105cf2:	e8 d5 be ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105cf7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cfa:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105cfd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 69 c9 ff ff       	call   80102672 <nameiparent>
80105d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d10:	75 02                	jne    80105d14 <sys_link+0xd9>
    goto bad;
80105d12:	eb 68                	jmp    80105d7c <sys_link+0x141>
  ilock(dp);
80105d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d17:	89 04 24             	mov    %eax,(%esp)
80105d1a:	e8 a3 bd ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d22:	8b 10                	mov    (%eax),%edx
80105d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d27:	8b 00                	mov    (%eax),%eax
80105d29:	39 c2                	cmp    %eax,%edx
80105d2b:	75 20                	jne    80105d4d <sys_link+0x112>
80105d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d30:	8b 40 04             	mov    0x4(%eax),%eax
80105d33:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d37:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d41:	89 04 24             	mov    %eax,(%esp)
80105d44:	e8 54 c6 ff ff       	call   8010239d <dirlink>
80105d49:	85 c0                	test   %eax,%eax
80105d4b:	79 0d                	jns    80105d5a <sys_link+0x11f>
    iunlockput(dp);
80105d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d50:	89 04 24             	mov    %eax,(%esp)
80105d53:	e8 69 bf ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105d58:	eb 22                	jmp    80105d7c <sys_link+0x141>
  }
  iunlockput(dp);
80105d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5d:	89 04 24             	mov    %eax,(%esp)
80105d60:	e8 5c bf ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d68:	89 04 24             	mov    %eax,(%esp)
80105d6b:	e8 a0 be ff ff       	call   80101c10 <iput>

  end_op();
80105d70:	e8 b0 d9 ff ff       	call   80103725 <end_op>

  return 0;
80105d75:	b8 00 00 00 00       	mov    $0x0,%eax
80105d7a:	eb 3a                	jmp    80105db6 <sys_link+0x17b>

bad:
  ilock(ip);
80105d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7f:	89 04 24             	mov    %eax,(%esp)
80105d82:	e8 3b bd ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8a:	66 8b 40 56          	mov    0x56(%eax),%ax
80105d8e:	48                   	dec    %eax
80105d8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d92:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d99:	89 04 24             	mov    %eax,(%esp)
80105d9c:	e8 5e bb ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da4:	89 04 24             	mov    %eax,(%esp)
80105da7:	e8 15 bf ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105dac:	e8 74 d9 ff ff       	call   80103725 <end_op>
  return -1;
80105db1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105db6:	c9                   	leave  
80105db7:	c3                   	ret    

80105db8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105db8:	55                   	push   %ebp
80105db9:	89 e5                	mov    %esp,%ebp
80105dbb:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105dbe:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105dc5:	eb 4a                	jmp    80105e11 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dca:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105dd1:	00 
80105dd2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dd6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80105de0:	89 04 24             	mov    %eax,(%esp)
80105de3:	e8 71 c1 ff ff       	call   80101f59 <readi>
80105de8:	83 f8 10             	cmp    $0x10,%eax
80105deb:	74 0c                	je     80105df9 <isdirempty+0x41>
      panic("isdirempty: readi");
80105ded:	c7 04 24 db 97 10 80 	movl   $0x801097db,(%esp)
80105df4:	e8 5b a7 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dfc:	66 85 c0             	test   %ax,%ax
80105dff:	74 07                	je     80105e08 <isdirempty+0x50>
      return 0;
80105e01:	b8 00 00 00 00       	mov    $0x0,%eax
80105e06:	eb 1b                	jmp    80105e23 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0b:	83 c0 10             	add    $0x10,%eax
80105e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e14:	8b 45 08             	mov    0x8(%ebp),%eax
80105e17:	8b 40 58             	mov    0x58(%eax),%eax
80105e1a:	39 c2                	cmp    %eax,%edx
80105e1c:	72 a9                	jb     80105dc7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105e1e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e23:	c9                   	leave  
80105e24:	c3                   	ret    

80105e25 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e25:	55                   	push   %ebp
80105e26:	89 e5                	mov    %esp,%ebp
80105e28:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e2b:	8d 45 bc             	lea    -0x44(%ebp),%eax
80105e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e39:	e8 7e fa ff ff       	call   801058bc <argstr>
80105e3e:	85 c0                	test   %eax,%eax
80105e40:	79 0a                	jns    80105e4c <sys_unlink+0x27>
    return -1;
80105e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e47:	e9 f1 01 00 00       	jmp    8010603d <sys_unlink+0x218>

  begin_op();
80105e4c:	e8 52 d8 ff ff       	call   801036a3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e51:	8b 45 bc             	mov    -0x44(%ebp),%eax
80105e54:	8d 55 c2             	lea    -0x3e(%ebp),%edx
80105e57:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e5b:	89 04 24             	mov    %eax,(%esp)
80105e5e:	e8 0f c8 ff ff       	call   80102672 <nameiparent>
80105e63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e6a:	75 0f                	jne    80105e7b <sys_unlink+0x56>
    end_op();
80105e6c:	e8 b4 d8 ff ff       	call   80103725 <end_op>
    return -1;
80105e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e76:	e9 c2 01 00 00       	jmp    8010603d <sys_unlink+0x218>
  }

  ilock(dp);
80105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7e:	89 04 24             	mov    %eax,(%esp)
80105e81:	e8 3c bc ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e86:	c7 44 24 04 ed 97 10 	movl   $0x801097ed,0x4(%esp)
80105e8d:	80 
80105e8e:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105e91:	89 04 24             	mov    %eax,(%esp)
80105e94:	e8 1c c4 ff ff       	call   801022b5 <namecmp>
80105e99:	85 c0                	test   %eax,%eax
80105e9b:	0f 84 87 01 00 00    	je     80106028 <sys_unlink+0x203>
80105ea1:	c7 44 24 04 ef 97 10 	movl   $0x801097ef,0x4(%esp)
80105ea8:	80 
80105ea9:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105eac:	89 04 24             	mov    %eax,(%esp)
80105eaf:	e8 01 c4 ff ff       	call   801022b5 <namecmp>
80105eb4:	85 c0                	test   %eax,%eax
80105eb6:	0f 84 6c 01 00 00    	je     80106028 <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ebc:	8d 45 b8             	lea    -0x48(%ebp),%eax
80105ebf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ec3:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecd:	89 04 24             	mov    %eax,(%esp)
80105ed0:	e8 02 c4 ff ff       	call   801022d7 <dirlookup>
80105ed5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ed8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105edc:	75 05                	jne    80105ee3 <sys_unlink+0xbe>
    goto bad;
80105ede:	e9 45 01 00 00       	jmp    80106028 <sys_unlink+0x203>
  ilock(ip);
80105ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee6:	89 04 24             	mov    %eax,(%esp)
80105ee9:	e8 d4 bb ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
80105eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef1:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ef5:	66 85 c0             	test   %ax,%ax
80105ef8:	7f 0c                	jg     80105f06 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105efa:	c7 04 24 f2 97 10 80 	movl   $0x801097f2,(%esp)
80105f01:	e8 4e a6 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f09:	8b 40 50             	mov    0x50(%eax),%eax
80105f0c:	66 83 f8 01          	cmp    $0x1,%ax
80105f10:	75 1f                	jne    80105f31 <sys_unlink+0x10c>
80105f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f15:	89 04 24             	mov    %eax,(%esp)
80105f18:	e8 9b fe ff ff       	call   80105db8 <isdirempty>
80105f1d:	85 c0                	test   %eax,%eax
80105f1f:	75 10                	jne    80105f31 <sys_unlink+0x10c>
    iunlockput(ip);
80105f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f24:	89 04 24             	mov    %eax,(%esp)
80105f27:	e8 95 bd ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105f2c:	e9 f7 00 00 00       	jmp    80106028 <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80105f31:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105f38:	00 
80105f39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f40:	00 
80105f41:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105f44:	89 04 24             	mov    %eax,(%esp)
80105f47:	e8 a6 f5 ff ff       	call   801054f2 <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80105f4c:	8b 45 b8             	mov    -0x48(%ebp),%eax
80105f4f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f56:	00 
80105f57:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f5b:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f65:	89 04 24             	mov    %eax,(%esp)
80105f68:	e8 50 c1 ff ff       	call   801020bd <writei>
80105f6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
80105f70:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80105f74:	74 0c                	je     80105f82 <sys_unlink+0x15d>
    panic("unlink: writei");
80105f76:	c7 04 24 04 98 10 80 	movl   $0x80109804,(%esp)
80105f7d:	e8 d2 a5 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
80105f82:	e8 1c e4 ff ff       	call   801043a3 <myproc>
80105f87:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105f8d:	83 c0 18             	add    $0x18,%eax
80105f90:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
80105f93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f96:	89 04 24             	mov    %eax,(%esp)
80105f99:	e8 35 2e 00 00       	call   80108dd3 <find>
80105f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
80105fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fa4:	89 c2                	mov    %eax,%edx
80105fa6:	c1 ea 1f             	shr    $0x1f,%edx
80105fa9:	01 d0                	add    %edx,%eax
80105fab:	d1 f8                	sar    %eax
80105fad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
80105fb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fb3:	f7 d8                	neg    %eax
80105fb5:	89 c2                	mov    %eax,%edx
80105fb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fba:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fbe:	89 14 24             	mov    %edx,(%esp)
80105fc1:	e8 64 31 00 00       	call   8010912a <set_curr_disk>
  if(ip->type == T_DIR){
80105fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc9:	8b 40 50             	mov    0x50(%eax),%eax
80105fcc:	66 83 f8 01          	cmp    $0x1,%ax
80105fd0:	75 1a                	jne    80105fec <sys_unlink+0x1c7>
    dp->nlink--;
80105fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd5:	66 8b 40 56          	mov    0x56(%eax),%ax
80105fd9:	48                   	dec    %eax
80105fda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fdd:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe4:	89 04 24             	mov    %eax,(%esp)
80105fe7:	e8 13 b9 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
80105fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fef:	89 04 24             	mov    %eax,(%esp)
80105ff2:	e8 ca bc ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
80105ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffa:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ffe:	48                   	dec    %eax
80105fff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106002:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106009:	89 04 24             	mov    %eax,(%esp)
8010600c:	e8 ee b8 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80106011:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106014:	89 04 24             	mov    %eax,(%esp)
80106017:	e8 a5 bc ff ff       	call   80101cc1 <iunlockput>

  end_op();
8010601c:	e8 04 d7 ff ff       	call   80103725 <end_op>

  return 0;
80106021:	b8 00 00 00 00       	mov    $0x0,%eax
80106026:	eb 15                	jmp    8010603d <sys_unlink+0x218>

bad:
  iunlockput(dp);
80106028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602b:	89 04 24             	mov    %eax,(%esp)
8010602e:	e8 8e bc ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106033:	e8 ed d6 ff ff       	call   80103725 <end_op>
  return -1;
80106038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010603d:	c9                   	leave  
8010603e:	c3                   	ret    

8010603f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010603f:	55                   	push   %ebp
80106040:	89 e5                	mov    %esp,%ebp
80106042:	83 ec 48             	sub    $0x48,%esp
80106045:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106048:	8b 55 10             	mov    0x10(%ebp),%edx
8010604b:	8b 45 14             	mov    0x14(%ebp),%eax
8010604e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106052:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106056:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010605a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010605d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106061:	8b 45 08             	mov    0x8(%ebp),%eax
80106064:	89 04 24             	mov    %eax,(%esp)
80106067:	e8 06 c6 ff ff       	call   80102672 <nameiparent>
8010606c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010606f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106073:	75 0a                	jne    8010607f <create+0x40>
    return 0;
80106075:	b8 00 00 00 00       	mov    $0x0,%eax
8010607a:	e9 79 01 00 00       	jmp    801061f8 <create+0x1b9>
  ilock(dp);
8010607f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106082:	89 04 24             	mov    %eax,(%esp)
80106085:	e8 38 ba ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010608a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010608d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106091:	8d 45 de             	lea    -0x22(%ebp),%eax
80106094:	89 44 24 04          	mov    %eax,0x4(%esp)
80106098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609b:	89 04 24             	mov    %eax,(%esp)
8010609e:	e8 34 c2 ff ff       	call   801022d7 <dirlookup>
801060a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060aa:	74 46                	je     801060f2 <create+0xb3>
    iunlockput(dp);
801060ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060af:	89 04 24             	mov    %eax,(%esp)
801060b2:	e8 0a bc ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
801060b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ba:	89 04 24             	mov    %eax,(%esp)
801060bd:	e8 00 ba ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801060c2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801060c7:	75 14                	jne    801060dd <create+0x9e>
801060c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cc:	8b 40 50             	mov    0x50(%eax),%eax
801060cf:	66 83 f8 02          	cmp    $0x2,%ax
801060d3:	75 08                	jne    801060dd <create+0x9e>
      return ip;
801060d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d8:	e9 1b 01 00 00       	jmp    801061f8 <create+0x1b9>
    iunlockput(ip);
801060dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e0:	89 04 24             	mov    %eax,(%esp)
801060e3:	e8 d9 bb ff ff       	call   80101cc1 <iunlockput>
    return 0;
801060e8:	b8 00 00 00 00       	mov    $0x0,%eax
801060ed:	e9 06 01 00 00       	jmp    801061f8 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801060f2:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801060f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f9:	8b 00                	mov    (%eax),%eax
801060fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801060ff:	89 04 24             	mov    %eax,(%esp)
80106102:	e8 26 b7 ff ff       	call   8010182d <ialloc>
80106107:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010610a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010610e:	75 0c                	jne    8010611c <create+0xdd>
    panic("create: ialloc");
80106110:	c7 04 24 13 98 10 80 	movl   $0x80109813,(%esp)
80106117:	e8 38 a4 ff ff       	call   80100554 <panic>

  ilock(ip);
8010611c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611f:	89 04 24             	mov    %eax,(%esp)
80106122:	e8 9b b9 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
80106127:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010612a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010612d:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106131:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106134:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106137:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010613b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106147:	89 04 24             	mov    %eax,(%esp)
8010614a:	e8 b0 b7 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010614f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106154:	75 68                	jne    801061be <create+0x17f>
    dp->nlink++;  // for ".."
80106156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106159:	66 8b 40 56          	mov    0x56(%eax),%ax
8010615d:	40                   	inc    %eax
8010615e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106161:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106168:	89 04 24             	mov    %eax,(%esp)
8010616b:	e8 8f b7 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106170:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106173:	8b 40 04             	mov    0x4(%eax),%eax
80106176:	89 44 24 08          	mov    %eax,0x8(%esp)
8010617a:	c7 44 24 04 ed 97 10 	movl   $0x801097ed,0x4(%esp)
80106181:	80 
80106182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106185:	89 04 24             	mov    %eax,(%esp)
80106188:	e8 10 c2 ff ff       	call   8010239d <dirlink>
8010618d:	85 c0                	test   %eax,%eax
8010618f:	78 21                	js     801061b2 <create+0x173>
80106191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106194:	8b 40 04             	mov    0x4(%eax),%eax
80106197:	89 44 24 08          	mov    %eax,0x8(%esp)
8010619b:	c7 44 24 04 ef 97 10 	movl   $0x801097ef,0x4(%esp)
801061a2:	80 
801061a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a6:	89 04 24             	mov    %eax,(%esp)
801061a9:	e8 ef c1 ff ff       	call   8010239d <dirlink>
801061ae:	85 c0                	test   %eax,%eax
801061b0:	79 0c                	jns    801061be <create+0x17f>
      panic("create dots");
801061b2:	c7 04 24 22 98 10 80 	movl   $0x80109822,(%esp)
801061b9:	e8 96 a3 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c1:	8b 40 04             	mov    0x4(%eax),%eax
801061c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801061c8:	8d 45 de             	lea    -0x22(%ebp),%eax
801061cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801061cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d2:	89 04 24             	mov    %eax,(%esp)
801061d5:	e8 c3 c1 ff ff       	call   8010239d <dirlink>
801061da:	85 c0                	test   %eax,%eax
801061dc:	79 0c                	jns    801061ea <create+0x1ab>
    panic("create: dirlink");
801061de:	c7 04 24 2e 98 10 80 	movl   $0x8010982e,(%esp)
801061e5:	e8 6a a3 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801061ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ed:	89 04 24             	mov    %eax,(%esp)
801061f0:	e8 cc ba ff ff       	call   80101cc1 <iunlockput>

  return ip;
801061f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801061f8:	c9                   	leave  
801061f9:	c3                   	ret    

801061fa <sys_open>:

int
sys_open(void)
{
801061fa:	55                   	push   %ebp
801061fb:	89 e5                	mov    %esp,%ebp
801061fd:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106200:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106203:	89 44 24 04          	mov    %eax,0x4(%esp)
80106207:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010620e:	e8 a9 f6 ff ff       	call   801058bc <argstr>
80106213:	85 c0                	test   %eax,%eax
80106215:	78 17                	js     8010622e <sys_open+0x34>
80106217:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010621a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010621e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106225:	e8 fb f5 ff ff       	call   80105825 <argint>
8010622a:	85 c0                	test   %eax,%eax
8010622c:	79 0a                	jns    80106238 <sys_open+0x3e>
    return -1;
8010622e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106233:	e9 64 01 00 00       	jmp    8010639c <sys_open+0x1a2>

  begin_op();
80106238:	e8 66 d4 ff ff       	call   801036a3 <begin_op>

  if(omode & O_CREATE){
8010623d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106240:	25 00 02 00 00       	and    $0x200,%eax
80106245:	85 c0                	test   %eax,%eax
80106247:	74 3b                	je     80106284 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106249:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106253:	00 
80106254:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010625b:	00 
8010625c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106263:	00 
80106264:	89 04 24             	mov    %eax,(%esp)
80106267:	e8 d3 fd ff ff       	call   8010603f <create>
8010626c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010626f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106273:	75 6a                	jne    801062df <sys_open+0xe5>
      end_op();
80106275:	e8 ab d4 ff ff       	call   80103725 <end_op>
      return -1;
8010627a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627f:	e9 18 01 00 00       	jmp    8010639c <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106284:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106287:	89 04 24             	mov    %eax,(%esp)
8010628a:	e8 c1 c3 ff ff       	call   80102650 <namei>
8010628f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106292:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106296:	75 0f                	jne    801062a7 <sys_open+0xad>
      end_op();
80106298:	e8 88 d4 ff ff       	call   80103725 <end_op>
      return -1;
8010629d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a2:	e9 f5 00 00 00       	jmp    8010639c <sys_open+0x1a2>
    }
    ilock(ip);
801062a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062aa:	89 04 24             	mov    %eax,(%esp)
801062ad:	e8 10 b8 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801062b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b5:	8b 40 50             	mov    0x50(%eax),%eax
801062b8:	66 83 f8 01          	cmp    $0x1,%ax
801062bc:	75 21                	jne    801062df <sys_open+0xe5>
801062be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062c1:	85 c0                	test   %eax,%eax
801062c3:	74 1a                	je     801062df <sys_open+0xe5>
      iunlockput(ip);
801062c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c8:	89 04 24             	mov    %eax,(%esp)
801062cb:	e8 f1 b9 ff ff       	call   80101cc1 <iunlockput>
      end_op();
801062d0:	e8 50 d4 ff ff       	call   80103725 <end_op>
      return -1;
801062d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062da:	e9 bd 00 00 00       	jmp    8010639c <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062df:	e8 1e ae ff ff       	call   80101102 <filealloc>
801062e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062eb:	74 14                	je     80106301 <sys_open+0x107>
801062ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f0:	89 04 24             	mov    %eax,(%esp)
801062f3:	e8 f8 f6 ff ff       	call   801059f0 <fdalloc>
801062f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801062fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801062ff:	79 28                	jns    80106329 <sys_open+0x12f>
    if(f)
80106301:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106305:	74 0b                	je     80106312 <sys_open+0x118>
      fileclose(f);
80106307:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630a:	89 04 24             	mov    %eax,(%esp)
8010630d:	e8 98 ae ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106315:	89 04 24             	mov    %eax,(%esp)
80106318:	e8 a4 b9 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010631d:	e8 03 d4 ff ff       	call   80103725 <end_op>
    return -1;
80106322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106327:	eb 73                	jmp    8010639c <sys_open+0x1a2>
  }
  iunlock(ip);
80106329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632c:	89 04 24             	mov    %eax,(%esp)
8010632f:	e8 98 b8 ff ff       	call   80101bcc <iunlock>
  end_op();
80106334:	e8 ec d3 ff ff       	call   80103725 <end_op>

  f->type = FD_INODE;
80106339:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106342:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106345:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106348:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010634b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106355:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106358:	83 e0 01             	and    $0x1,%eax
8010635b:	85 c0                	test   %eax,%eax
8010635d:	0f 94 c0             	sete   %al
80106360:	88 c2                	mov    %al,%dl
80106362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106365:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010636b:	83 e0 01             	and    $0x1,%eax
8010636e:	85 c0                	test   %eax,%eax
80106370:	75 0a                	jne    8010637c <sys_open+0x182>
80106372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106375:	83 e0 02             	and    $0x2,%eax
80106378:	85 c0                	test   %eax,%eax
8010637a:	74 07                	je     80106383 <sys_open+0x189>
8010637c:	b8 01 00 00 00       	mov    $0x1,%eax
80106381:	eb 05                	jmp    80106388 <sys_open+0x18e>
80106383:	b8 00 00 00 00       	mov    $0x0,%eax
80106388:	88 c2                	mov    %al,%dl
8010638a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638d:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
80106390:	8b 55 e8             	mov    -0x18(%ebp),%edx
80106393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106396:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
80106399:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010639c:	c9                   	leave  
8010639d:	c3                   	ret    

8010639e <sys_mkdir>:

int
sys_mkdir(void)
{
8010639e:	55                   	push   %ebp
8010639f:	89 e5                	mov    %esp,%ebp
801063a1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063a4:	e8 fa d2 ff ff       	call   801036a3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801063b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063b7:	e8 00 f5 ff ff       	call   801058bc <argstr>
801063bc:	85 c0                	test   %eax,%eax
801063be:	78 2c                	js     801063ec <sys_mkdir+0x4e>
801063c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063ca:	00 
801063cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063d2:	00 
801063d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801063da:	00 
801063db:	89 04 24             	mov    %eax,(%esp)
801063de:	e8 5c fc ff ff       	call   8010603f <create>
801063e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ea:	75 0c                	jne    801063f8 <sys_mkdir+0x5a>
    end_op();
801063ec:	e8 34 d3 ff ff       	call   80103725 <end_op>
    return -1;
801063f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f6:	eb 15                	jmp    8010640d <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801063f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fb:	89 04 24             	mov    %eax,(%esp)
801063fe:	e8 be b8 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106403:	e8 1d d3 ff ff       	call   80103725 <end_op>
  return 0;
80106408:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640d:	c9                   	leave  
8010640e:	c3                   	ret    

8010640f <sys_mknod>:

int
sys_mknod(void)
{
8010640f:	55                   	push   %ebp
80106410:	89 e5                	mov    %esp,%ebp
80106412:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106415:	e8 89 d2 ff ff       	call   801036a3 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010641a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010641d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106421:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106428:	e8 8f f4 ff ff       	call   801058bc <argstr>
8010642d:	85 c0                	test   %eax,%eax
8010642f:	78 5e                	js     8010648f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106431:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106434:	89 44 24 04          	mov    %eax,0x4(%esp)
80106438:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010643f:	e8 e1 f3 ff ff       	call   80105825 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106444:	85 c0                	test   %eax,%eax
80106446:	78 47                	js     8010648f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106448:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010644b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010644f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106456:	e8 ca f3 ff ff       	call   80105825 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010645b:	85 c0                	test   %eax,%eax
8010645d:	78 30                	js     8010648f <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010645f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106462:	0f bf c8             	movswl %ax,%ecx
80106465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106468:	0f bf d0             	movswl %ax,%edx
8010646b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010646e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106472:	89 54 24 08          	mov    %edx,0x8(%esp)
80106476:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010647d:	00 
8010647e:	89 04 24             	mov    %eax,(%esp)
80106481:	e8 b9 fb ff ff       	call   8010603f <create>
80106486:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106489:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010648d:	75 0c                	jne    8010649b <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010648f:	e8 91 d2 ff ff       	call   80103725 <end_op>
    return -1;
80106494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106499:	eb 15                	jmp    801064b0 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010649b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649e:	89 04 24             	mov    %eax,(%esp)
801064a1:	e8 1b b8 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801064a6:	e8 7a d2 ff ff       	call   80103725 <end_op>
  return 0;
801064ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b0:	c9                   	leave  
801064b1:	c3                   	ret    

801064b2 <sys_chdir>:

int
sys_chdir(void)
{
801064b2:	55                   	push   %ebp
801064b3:	89 e5                	mov    %esp,%ebp
801064b5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801064b8:	e8 e6 de ff ff       	call   801043a3 <myproc>
801064bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801064c0:	e8 de d1 ff ff       	call   801036a3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801064cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064d3:	e8 e4 f3 ff ff       	call   801058bc <argstr>
801064d8:	85 c0                	test   %eax,%eax
801064da:	78 14                	js     801064f0 <sys_chdir+0x3e>
801064dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064df:	89 04 24             	mov    %eax,(%esp)
801064e2:	e8 69 c1 ff ff       	call   80102650 <namei>
801064e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064ee:	75 0c                	jne    801064fc <sys_chdir+0x4a>
    end_op();
801064f0:	e8 30 d2 ff ff       	call   80103725 <end_op>
    return -1;
801064f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fa:	eb 5a                	jmp    80106556 <sys_chdir+0xa4>
  }
  ilock(ip);
801064fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ff:	89 04 24             	mov    %eax,(%esp)
80106502:	e8 bb b5 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
80106507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650a:	8b 40 50             	mov    0x50(%eax),%eax
8010650d:	66 83 f8 01          	cmp    $0x1,%ax
80106511:	74 17                	je     8010652a <sys_chdir+0x78>
    iunlockput(ip);
80106513:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106516:	89 04 24             	mov    %eax,(%esp)
80106519:	e8 a3 b7 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010651e:	e8 02 d2 ff ff       	call   80103725 <end_op>
    return -1;
80106523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106528:	eb 2c                	jmp    80106556 <sys_chdir+0xa4>
  }
  iunlock(ip);
8010652a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010652d:	89 04 24             	mov    %eax,(%esp)
80106530:	e8 97 b6 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106538:	8b 40 68             	mov    0x68(%eax),%eax
8010653b:	89 04 24             	mov    %eax,(%esp)
8010653e:	e8 cd b6 ff ff       	call   80101c10 <iput>
  end_op();
80106543:	e8 dd d1 ff ff       	call   80103725 <end_op>
  curproc->cwd = ip;
80106548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010654e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106551:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106556:	c9                   	leave  
80106557:	c3                   	ret    

80106558 <sys_exec>:

int
sys_exec(void)
{
80106558:	55                   	push   %ebp
80106559:	89 e5                	mov    %esp,%ebp
8010655b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106561:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106564:	89 44 24 04          	mov    %eax,0x4(%esp)
80106568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010656f:	e8 48 f3 ff ff       	call   801058bc <argstr>
80106574:	85 c0                	test   %eax,%eax
80106576:	78 1a                	js     80106592 <sys_exec+0x3a>
80106578:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010657e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106582:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106589:	e8 97 f2 ff ff       	call   80105825 <argint>
8010658e:	85 c0                	test   %eax,%eax
80106590:	79 0a                	jns    8010659c <sys_exec+0x44>
    return -1;
80106592:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106597:	e9 c7 00 00 00       	jmp    80106663 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
8010659c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801065a3:	00 
801065a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065ab:	00 
801065ac:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065b2:	89 04 24             	mov    %eax,(%esp)
801065b5:	e8 38 ef ff ff       	call   801054f2 <memset>
  for(i=0;; i++){
801065ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c4:	83 f8 1f             	cmp    $0x1f,%eax
801065c7:	76 0a                	jbe    801065d3 <sys_exec+0x7b>
      return -1;
801065c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ce:	e9 90 00 00 00       	jmp    80106663 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801065d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d6:	c1 e0 02             	shl    $0x2,%eax
801065d9:	89 c2                	mov    %eax,%edx
801065db:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065e1:	01 c2                	add    %eax,%edx
801065e3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ed:	89 14 24             	mov    %edx,(%esp)
801065f0:	e8 8f f1 ff ff       	call   80105784 <fetchint>
801065f5:	85 c0                	test   %eax,%eax
801065f7:	79 07                	jns    80106600 <sys_exec+0xa8>
      return -1;
801065f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fe:	eb 63                	jmp    80106663 <sys_exec+0x10b>
    if(uarg == 0){
80106600:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106606:	85 c0                	test   %eax,%eax
80106608:	75 26                	jne    80106630 <sys_exec+0xd8>
      argv[i] = 0;
8010660a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106614:	00 00 00 00 
      break;
80106618:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106622:	89 54 24 04          	mov    %edx,0x4(%esp)
80106626:	89 04 24             	mov    %eax,(%esp)
80106629:	e8 12 a6 ff ff       	call   80100c40 <exec>
8010662e:	eb 33                	jmp    80106663 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106630:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106636:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106639:	c1 e2 02             	shl    $0x2,%edx
8010663c:	01 c2                	add    %eax,%edx
8010663e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106644:	89 54 24 04          	mov    %edx,0x4(%esp)
80106648:	89 04 24             	mov    %eax,(%esp)
8010664b:	e8 73 f1 ff ff       	call   801057c3 <fetchstr>
80106650:	85 c0                	test   %eax,%eax
80106652:	79 07                	jns    8010665b <sys_exec+0x103>
      return -1;
80106654:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106659:	eb 08                	jmp    80106663 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010665b:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010665e:	e9 5e ff ff ff       	jmp    801065c1 <sys_exec+0x69>
  return exec(path, argv);
}
80106663:	c9                   	leave  
80106664:	c3                   	ret    

80106665 <sys_pipe>:

int
sys_pipe(void)
{
80106665:	55                   	push   %ebp
80106666:	89 e5                	mov    %esp,%ebp
80106668:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010666b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106672:	00 
80106673:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106676:	89 44 24 04          	mov    %eax,0x4(%esp)
8010667a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106681:	e8 cc f1 ff ff       	call   80105852 <argptr>
80106686:	85 c0                	test   %eax,%eax
80106688:	79 0a                	jns    80106694 <sys_pipe+0x2f>
    return -1;
8010668a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668f:	e9 9a 00 00 00       	jmp    8010672e <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106694:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010669b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010669e:	89 04 24             	mov    %eax,(%esp)
801066a1:	e8 52 d8 ff ff       	call   80103ef8 <pipealloc>
801066a6:	85 c0                	test   %eax,%eax
801066a8:	79 07                	jns    801066b1 <sys_pipe+0x4c>
    return -1;
801066aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066af:	eb 7d                	jmp    8010672e <sys_pipe+0xc9>
  fd0 = -1;
801066b1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066bb:	89 04 24             	mov    %eax,(%esp)
801066be:	e8 2d f3 ff ff       	call   801059f0 <fdalloc>
801066c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ca:	78 14                	js     801066e0 <sys_pipe+0x7b>
801066cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066cf:	89 04 24             	mov    %eax,(%esp)
801066d2:	e8 19 f3 ff ff       	call   801059f0 <fdalloc>
801066d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066de:	79 36                	jns    80106716 <sys_pipe+0xb1>
    if(fd0 >= 0)
801066e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066e4:	78 13                	js     801066f9 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801066e6:	e8 b8 dc ff ff       	call   801043a3 <myproc>
801066eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066ee:	83 c2 08             	add    $0x8,%edx
801066f1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801066f8:	00 
    fileclose(rf);
801066f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066fc:	89 04 24             	mov    %eax,(%esp)
801066ff:	e8 a6 aa ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106707:	89 04 24             	mov    %eax,(%esp)
8010670a:	e8 9b aa ff ff       	call   801011aa <fileclose>
    return -1;
8010670f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106714:	eb 18                	jmp    8010672e <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106716:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010671c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010671e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106721:	8d 50 04             	lea    0x4(%eax),%edx
80106724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106727:	89 02                	mov    %eax,(%edx)
  return 0;
80106729:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010672e:	c9                   	leave  
8010672f:	c3                   	ret    

80106730 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106730:	55                   	push   %ebp
80106731:	89 e5                	mov    %esp,%ebp
80106733:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106736:	e8 81 df ff ff       	call   801046bc <fork>
}
8010673b:	c9                   	leave  
8010673c:	c3                   	ret    

8010673d <sys_exit>:

int
sys_exit(void)
{
8010673d:	55                   	push   %ebp
8010673e:	89 e5                	mov    %esp,%ebp
80106740:	83 ec 08             	sub    $0x8,%esp
  exit();
80106743:	e8 ec e0 ff ff       	call   80104834 <exit>
  return 0;  // not reached
80106748:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010674d:	c9                   	leave  
8010674e:	c3                   	ret    

8010674f <sys_wait>:

int
sys_wait(void)
{
8010674f:	55                   	push   %ebp
80106750:	89 e5                	mov    %esp,%ebp
80106752:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106755:	e8 1e e2 ff ff       	call   80104978 <wait>
}
8010675a:	c9                   	leave  
8010675b:	c3                   	ret    

8010675c <sys_kill>:

int
sys_kill(void)
{
8010675c:	55                   	push   %ebp
8010675d:	89 e5                	mov    %esp,%ebp
8010675f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106762:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106765:	89 44 24 04          	mov    %eax,0x4(%esp)
80106769:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106770:	e8 b0 f0 ff ff       	call   80105825 <argint>
80106775:	85 c0                	test   %eax,%eax
80106777:	79 07                	jns    80106780 <sys_kill+0x24>
    return -1;
80106779:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677e:	eb 0b                	jmp    8010678b <sys_kill+0x2f>
  return kill(pid);
80106780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106783:	89 04 24             	mov    %eax,(%esp)
80106786:	e8 cb e5 ff ff       	call   80104d56 <kill>
}
8010678b:	c9                   	leave  
8010678c:	c3                   	ret    

8010678d <sys_getpid>:

int
sys_getpid(void)
{
8010678d:	55                   	push   %ebp
8010678e:	89 e5                	mov    %esp,%ebp
80106790:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106793:	e8 0b dc ff ff       	call   801043a3 <myproc>
80106798:	8b 40 10             	mov    0x10(%eax),%eax
}
8010679b:	c9                   	leave  
8010679c:	c3                   	ret    

8010679d <sys_sbrk>:

int
sys_sbrk(void)
{
8010679d:	55                   	push   %ebp
8010679e:	89 e5                	mov    %esp,%ebp
801067a0:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801067a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801067aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067b1:	e8 6f f0 ff ff       	call   80105825 <argint>
801067b6:	85 c0                	test   %eax,%eax
801067b8:	79 07                	jns    801067c1 <sys_sbrk+0x24>
    return -1;
801067ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bf:	eb 23                	jmp    801067e4 <sys_sbrk+0x47>
  addr = myproc()->sz;
801067c1:	e8 dd db ff ff       	call   801043a3 <myproc>
801067c6:	8b 00                	mov    (%eax),%eax
801067c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ce:	89 04 24             	mov    %eax,(%esp)
801067d1:	e8 48 de ff ff       	call   8010461e <growproc>
801067d6:	85 c0                	test   %eax,%eax
801067d8:	79 07                	jns    801067e1 <sys_sbrk+0x44>
    return -1;
801067da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067df:	eb 03                	jmp    801067e4 <sys_sbrk+0x47>
  return addr;
801067e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067e4:	c9                   	leave  
801067e5:	c3                   	ret    

801067e6 <sys_sleep>:

int
sys_sleep(void)
{
801067e6:	55                   	push   %ebp
801067e7:	89 e5                	mov    %esp,%ebp
801067e9:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801067ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801067f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067fa:	e8 26 f0 ff ff       	call   80105825 <argint>
801067ff:	85 c0                	test   %eax,%eax
80106801:	79 07                	jns    8010680a <sys_sleep+0x24>
    return -1;
80106803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106808:	eb 6b                	jmp    80106875 <sys_sleep+0x8f>
  acquire(&tickslock);
8010680a:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106811:	e8 79 ea ff ff       	call   8010528f <acquire>
  ticks0 = ticks;
80106816:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
8010681b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010681e:	eb 33                	jmp    80106853 <sys_sleep+0x6d>
    if(myproc()->killed){
80106820:	e8 7e db ff ff       	call   801043a3 <myproc>
80106825:	8b 40 24             	mov    0x24(%eax),%eax
80106828:	85 c0                	test   %eax,%eax
8010682a:	74 13                	je     8010683f <sys_sleep+0x59>
      release(&tickslock);
8010682c:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106833:	e8 c1 ea ff ff       	call   801052f9 <release>
      return -1;
80106838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683d:	eb 36                	jmp    80106875 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010683f:	c7 44 24 04 60 73 11 	movl   $0x80117360,0x4(%esp)
80106846:	80 
80106847:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
8010684e:	e8 01 e4 ff ff       	call   80104c54 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106853:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106858:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010685b:	89 c2                	mov    %eax,%edx
8010685d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106860:	39 c2                	cmp    %eax,%edx
80106862:	72 bc                	jb     80106820 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106864:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010686b:	e8 89 ea ff ff       	call   801052f9 <release>
  return 0;
80106870:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106875:	c9                   	leave  
80106876:	c3                   	ret    

80106877 <sys_cstop>:

void sys_cstop(){
80106877:	55                   	push   %ebp
80106878:	89 e5                	mov    %esp,%ebp
8010687a:	53                   	push   %ebx
8010687b:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
8010687e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106881:	89 44 24 04          	mov    %eax,0x4(%esp)
80106885:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010688c:	e8 2b f0 ff ff       	call   801058bc <argstr>

  if(myproc()->cont != NULL){
80106891:	e8 0d db ff ff       	call   801043a3 <myproc>
80106896:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010689c:	85 c0                	test   %eax,%eax
8010689e:	74 72                	je     80106912 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
801068a0:	e8 fe da ff ff       	call   801043a3 <myproc>
801068a5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801068ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
801068ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b1:	89 04 24             	mov    %eax,(%esp)
801068b4:	e8 8c ee ff ff       	call   80105745 <strlen>
801068b9:	89 c3                	mov    %eax,%ebx
801068bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068be:	83 c0 18             	add    $0x18,%eax
801068c1:	89 04 24             	mov    %eax,(%esp)
801068c4:	e8 7c ee ff ff       	call   80105745 <strlen>
801068c9:	39 c3                	cmp    %eax,%ebx
801068cb:	75 37                	jne    80106904 <sys_cstop+0x8d>
801068cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068d0:	89 04 24             	mov    %eax,(%esp)
801068d3:	e8 6d ee ff ff       	call   80105745 <strlen>
801068d8:	89 c2                	mov    %eax,%edx
801068da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068dd:	8d 48 18             	lea    0x18(%eax),%ecx
801068e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e3:	89 54 24 08          	mov    %edx,0x8(%esp)
801068e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801068eb:	89 04 24             	mov    %eax,(%esp)
801068ee:	e8 67 ed ff ff       	call   8010565a <strncmp>
801068f3:	85 c0                	test   %eax,%eax
801068f5:	75 0d                	jne    80106904 <sys_cstop+0x8d>
      cstop_container_helper(cont);
801068f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fa:	89 04 24             	mov    %eax,(%esp)
801068fd:	e8 0e e6 ff ff       	call   80104f10 <cstop_container_helper>
80106902:	eb 19                	jmp    8010691d <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106904:	c7 04 24 40 98 10 80 	movl   $0x80109840,(%esp)
8010690b:	e8 b1 9a ff ff       	call   801003c1 <cprintf>
80106910:	eb 0b                	jmp    8010691d <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106915:	89 04 24             	mov    %eax,(%esp)
80106918:	e8 44 e6 ff ff       	call   80104f61 <cstop_helper>
  }

  //kill the processes with name as the id

}
8010691d:	83 c4 24             	add    $0x24,%esp
80106920:	5b                   	pop    %ebx
80106921:	5d                   	pop    %ebp
80106922:	c3                   	ret    

80106923 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106923:	55                   	push   %ebp
80106924:	89 e5                	mov    %esp,%ebp
80106926:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106929:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010692c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106930:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106937:	e8 80 ef ff ff       	call   801058bc <argstr>

  set_root_inode(name);
8010693c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693f:	89 04 24             	mov    %eax,(%esp)
80106942:	e8 78 23 00 00       	call   80108cbf <set_root_inode>
  cprintf("success\n");
80106947:	c7 04 24 64 98 10 80 	movl   $0x80109864,(%esp)
8010694e:	e8 6e 9a ff ff       	call   801003c1 <cprintf>

}
80106953:	c9                   	leave  
80106954:	c3                   	ret    

80106955 <sys_ps>:

void sys_ps(void){
80106955:	55                   	push   %ebp
80106956:	89 e5                	mov    %esp,%ebp
80106958:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
8010695b:	e8 43 da ff ff       	call   801043a3 <myproc>
80106960:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106966:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106969:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010696d:	75 07                	jne    80106976 <sys_ps+0x21>
    procdump();
8010696f:	e8 5d e4 ff ff       	call   80104dd1 <procdump>
80106974:	eb 0e                	jmp    80106984 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106979:	83 c0 18             	add    $0x18,%eax
8010697c:	89 04 24             	mov    %eax,(%esp)
8010697f:	e8 60 e6 ff ff       	call   80104fe4 <c_procdump>
  }
}
80106984:	c9                   	leave  
80106985:	c3                   	ret    

80106986 <sys_container_init>:

void sys_container_init(){
80106986:	55                   	push   %ebp
80106987:	89 e5                	mov    %esp,%ebp
80106989:	83 ec 08             	sub    $0x8,%esp
  container_init();
8010698c:	e8 0d 28 00 00       	call   8010919e <container_init>
}
80106991:	c9                   	leave  
80106992:	c3                   	ret    

80106993 <sys_is_full>:

int sys_is_full(void){
80106993:	55                   	push   %ebp
80106994:	89 e5                	mov    %esp,%ebp
80106996:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106999:	e8 e5 23 00 00       	call   80108d83 <is_full>
}
8010699e:	c9                   	leave  
8010699f:	c3                   	ret    

801069a0 <sys_find>:

int sys_find(void){
801069a0:	55                   	push   %ebp
801069a1:	89 e5                	mov    %esp,%ebp
801069a3:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
801069a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069b4:	e8 03 ef ff ff       	call   801058bc <argstr>

  return find(name);
801069b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069bc:	89 04 24             	mov    %eax,(%esp)
801069bf:	e8 0f 24 00 00       	call   80108dd3 <find>
}
801069c4:	c9                   	leave  
801069c5:	c3                   	ret    

801069c6 <sys_get_name>:

void sys_get_name(void){
801069c6:	55                   	push   %ebp
801069c7:	89 e5                	mov    %esp,%ebp
801069c9:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
801069cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069da:	e8 46 ee ff ff       	call   80105825 <argint>
  argstr(1, &name);
801069df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069ed:	e8 ca ee ff ff       	call   801058bc <argstr>

  get_name(vc_num, name);
801069f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801069fc:	89 04 24             	mov    %eax,(%esp)
801069ff:	e8 fc 22 00 00       	call   80108d00 <get_name>
}
80106a04:	c9                   	leave  
80106a05:	c3                   	ret    

80106a06 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106a06:	55                   	push   %ebp
80106a07:	89 e5                	mov    %esp,%ebp
80106a09:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a1a:	e8 06 ee ff ff       	call   80105825 <argint>


  return get_max_proc(vc_num);  
80106a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a22:	89 04 24             	mov    %eax,(%esp)
80106a25:	e8 19 24 00 00       	call   80108e43 <get_max_proc>
}
80106a2a:	c9                   	leave  
80106a2b:	c3                   	ret    

80106a2c <sys_get_max_mem>:

int sys_get_max_mem(void){
80106a2c:	55                   	push   %ebp
80106a2d:	89 e5                	mov    %esp,%ebp
80106a2f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a40:	e8 e0 ed ff ff       	call   80105825 <argint>


  return get_max_mem(vc_num);
80106a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a48:	89 04 24             	mov    %eax,(%esp)
80106a4b:	e8 5b 24 00 00       	call   80108eab <get_max_mem>
}
80106a50:	c9                   	leave  
80106a51:	c3                   	ret    

80106a52 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106a52:	55                   	push   %ebp
80106a53:	89 e5                	mov    %esp,%ebp
80106a55:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a58:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a66:	e8 ba ed ff ff       	call   80105825 <argint>


  return get_max_disk(vc_num);
80106a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6e:	89 04 24             	mov    %eax,(%esp)
80106a71:	e8 75 24 00 00       	call   80108eeb <get_max_disk>

}
80106a76:	c9                   	leave  
80106a77:	c3                   	ret    

80106a78 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106a78:	55                   	push   %ebp
80106a79:	89 e5                	mov    %esp,%ebp
80106a7b:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a81:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a8c:	e8 94 ed ff ff       	call   80105825 <argint>


  return get_curr_proc(vc_num);
80106a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a94:	89 04 24             	mov    %eax,(%esp)
80106a97:	e8 8f 24 00 00       	call   80108f2b <get_curr_proc>
}
80106a9c:	c9                   	leave  
80106a9d:	c3                   	ret    

80106a9e <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106a9e:	55                   	push   %ebp
80106a9f:	89 e5                	mov    %esp,%ebp
80106aa1:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ab2:	e8 6e ed ff ff       	call   80105825 <argint>


  return get_curr_mem(vc_num);
80106ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aba:	89 04 24             	mov    %eax,(%esp)
80106abd:	e8 a9 24 00 00       	call   80108f6b <get_curr_mem>
}
80106ac2:	c9                   	leave  
80106ac3:	c3                   	ret    

80106ac4 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106ac4:	55                   	push   %ebp
80106ac5:	89 e5                	mov    %esp,%ebp
80106ac7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106acd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ad1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ad8:	e8 48 ed ff ff       	call   80105825 <argint>


  return get_curr_disk(vc_num);
80106add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae0:	89 04 24             	mov    %eax,(%esp)
80106ae3:	e8 d6 24 00 00       	call   80108fbe <get_curr_disk>
}
80106ae8:	c9                   	leave  
80106ae9:	c3                   	ret    

80106aea <sys_set_name>:

void sys_set_name(void){
80106aea:	55                   	push   %ebp
80106aeb:	89 e5                	mov    %esp,%ebp
80106aed:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106af0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106af3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106afe:	e8 b9 ed ff ff       	call   801058bc <argstr>

  int vc_num;
  argint(1, &vc_num);
80106b03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b06:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b11:	e8 0f ed ff ff       	call   80105825 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106b16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b20:	89 04 24             	mov    %eax,(%esp)
80106b23:	e8 d6 24 00 00       	call   80108ffe <set_name>
  //cprintf("Done setting name.\n");
}
80106b28:	c9                   	leave  
80106b29:	c3                   	ret    

80106b2a <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106b2a:	55                   	push   %ebp
80106b2b:	89 e5                	mov    %esp,%ebp
80106b2d:	53                   	push   %ebx
80106b2e:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b3f:	e8 e1 ec ff ff       	call   80105825 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106b44:	e8 5a d8 ff ff       	call   801043a3 <myproc>
80106b49:	89 c3                	mov    %eax,%ebx
80106b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4e:	89 04 24             	mov    %eax,(%esp)
80106b51:	e8 2d 23 00 00       	call   80108e83 <get_container>
80106b56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106b5c:	83 c4 24             	add    $0x24,%esp
80106b5f:	5b                   	pop    %ebx
80106b60:	5d                   	pop    %ebp
80106b61:	c3                   	ret    

80106b62 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106b62:	55                   	push   %ebp
80106b63:	89 e5                	mov    %esp,%ebp
80106b65:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106b68:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b76:	e8 aa ec ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106b7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b89:	e8 97 ec ff ff       	call   80105825 <argint>

  set_max_mem(mem, vc_num);
80106b8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b94:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b98:	89 04 24             	mov    %eax,(%esp)
80106b9b:	e8 95 24 00 00       	call   80109035 <set_max_mem>
}
80106ba0:	c9                   	leave  
80106ba1:	c3                   	ret    

80106ba2 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106ba2:	55                   	push   %ebp
80106ba3:	89 e5                	mov    %esp,%ebp
80106ba5:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bab:	89 44 24 04          	mov    %eax,0x4(%esp)
80106baf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bb6:	e8 6a ec ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106bbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bc2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106bc9:	e8 57 ec ff ff       	call   80105825 <argint>

  set_max_disk(disk, vc_num);
80106bce:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd4:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bd8:	89 04 24             	mov    %eax,(%esp)
80106bdb:	e8 7a 24 00 00       	call   8010905a <set_max_disk>
}
80106be0:	c9                   	leave  
80106be1:	c3                   	ret    

80106be2 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106be2:	55                   	push   %ebp
80106be3:	89 e5                	mov    %esp,%ebp
80106be5:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106beb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bf6:	e8 2a ec ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c09:	e8 17 ec ff ff       	call   80105825 <argint>

  set_max_proc(proc, vc_num);
80106c0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c14:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c18:	89 04 24             	mov    %eax,(%esp)
80106c1b:	e8 60 24 00 00       	call   80109080 <set_max_proc>
}
80106c20:	c9                   	leave  
80106c21:	c3                   	ret    

80106c22 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106c22:	55                   	push   %ebp
80106c23:	89 e5                	mov    %esp,%ebp
80106c25:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106c28:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c36:	e8 ea eb ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c49:	e8 d7 eb ff ff       	call   80105825 <argint>

  set_curr_mem(mem, vc_num);
80106c4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c54:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c58:	89 04 24             	mov    %eax,(%esp)
80106c5b:	e8 46 24 00 00       	call   801090a6 <set_curr_mem>
}
80106c60:	c9                   	leave  
80106c61:	c3                   	ret    

80106c62 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106c62:	55                   	push   %ebp
80106c63:	89 e5                	mov    %esp,%ebp
80106c65:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106c68:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c76:	e8 aa eb ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c89:	e8 97 eb ff ff       	call   80105825 <argint>

  set_curr_mem(mem, vc_num);
80106c8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c94:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c98:	89 04 24             	mov    %eax,(%esp)
80106c9b:	e8 06 24 00 00       	call   801090a6 <set_curr_mem>
}
80106ca0:	c9                   	leave  
80106ca1:	c3                   	ret    

80106ca2 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106ca2:	55                   	push   %ebp
80106ca3:	89 e5                	mov    %esp,%ebp
80106ca5:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106ca8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cab:	89 44 24 04          	mov    %eax,0x4(%esp)
80106caf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cb6:	e8 6a eb ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106cbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cc2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106cc9:	e8 57 eb ff ff       	call   80105825 <argint>

  set_curr_disk(disk, vc_num);
80106cce:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd4:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cd8:	89 04 24             	mov    %eax,(%esp)
80106cdb:	e8 4a 24 00 00       	call   8010912a <set_curr_disk>
}
80106ce0:	c9                   	leave  
80106ce1:	c3                   	ret    

80106ce2 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106ce2:	55                   	push   %ebp
80106ce3:	89 e5                	mov    %esp,%ebp
80106ce5:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cf6:	e8 2a eb ff ff       	call   80105825 <argint>

  int vc_num;
  argint(1, &vc_num);
80106cfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d09:	e8 17 eb ff ff       	call   80105825 <argint>

  set_curr_proc(proc, vc_num);
80106d0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d14:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d18:	89 04 24             	mov    %eax,(%esp)
80106d1b:	e8 4f 24 00 00       	call   8010916f <set_curr_proc>
}
80106d20:	c9                   	leave  
80106d21:	c3                   	ret    

80106d22 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106d22:	55                   	push   %ebp
80106d23:	89 e5                	mov    %esp,%ebp
80106d25:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106d28:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d2f:	e8 5b e5 ff ff       	call   8010528f <acquire>
  xticks = ticks;
80106d34:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106d3c:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106d43:	e8 b1 e5 ff ff       	call   801052f9 <release>
  return xticks;
80106d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d4b:	c9                   	leave  
80106d4c:	c3                   	ret    

80106d4d <sys_getticks>:

int
sys_getticks(void){
80106d4d:	55                   	push   %ebp
80106d4e:	89 e5                	mov    %esp,%ebp
80106d50:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106d53:	e8 4b d6 ff ff       	call   801043a3 <myproc>
80106d58:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106d5b:	c9                   	leave  
80106d5c:	c3                   	ret    

80106d5d <sys_max_containers>:

int sys_max_containers(void){
80106d5d:	55                   	push   %ebp
80106d5e:	89 e5                	mov    %esp,%ebp
80106d60:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
80106d63:	e8 2c 24 00 00       	call   80109194 <max_containers>
}
80106d68:	c9                   	leave  
80106d69:	c3                   	ret    

80106d6a <sys_df>:


void sys_df(void){
80106d6a:	55                   	push   %ebp
80106d6b:	89 e5                	mov    %esp,%ebp
80106d6d:	83 ec 38             	sub    $0x38,%esp
  struct container* cont = myproc()->cont;
80106d70:	e8 2e d6 ff ff       	call   801043a3 <myproc>
80106d75:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106d7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int used = 0;
80106d7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80106d85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106d89:	75 4b                	jne    80106dd6 <sys_df+0x6c>
    int max = max_containers();
80106d8b:	e8 04 24 00 00       	call   80109194 <max_containers>
80106d90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
80106d93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106d9a:	eb 1d                	jmp    80106db9 <sys_df+0x4f>
      used = used + (int)(get_curr_disk(i) / 1024);
80106d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9f:	89 04 24             	mov    %eax,(%esp)
80106da2:	e8 17 22 00 00       	call   80108fbe <get_curr_disk>
80106da7:	85 c0                	test   %eax,%eax
80106da9:	79 05                	jns    80106db0 <sys_df+0x46>
80106dab:	05 ff 03 00 00       	add    $0x3ff,%eax
80106db0:	c1 f8 0a             	sar    $0xa,%eax
80106db3:	01 45 f4             	add    %eax,-0xc(%ebp)
  struct container* cont = myproc()->cont;
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
80106db6:	ff 45 f0             	incl   -0x10(%ebp)
80106db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dbc:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80106dbf:	7c db                	jl     80106d9c <sys_df+0x32>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: TBD\n", used);
80106dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dc8:	c7 04 24 70 98 10 80 	movl   $0x80109870,(%esp)
80106dcf:	e8 ed 95 ff ff       	call   801003c1 <cprintf>
80106dd4:	eb 4d                	jmp    80106e23 <sys_df+0xb9>
  }
  else{
    int x = find(cont->name);
80106dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106dd9:	83 c0 18             	add    $0x18,%eax
80106ddc:	89 04 24             	mov    %eax,(%esp)
80106ddf:	e8 ef 1f 00 00       	call   80108dd3 <find>
80106de4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
80106de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dea:	89 04 24             	mov    %eax,(%esp)
80106ded:	e8 cc 21 00 00       	call   80108fbe <get_curr_disk>
80106df2:	85 c0                	test   %eax,%eax
80106df4:	79 05                	jns    80106dfb <sys_df+0x91>
80106df6:	05 ff 03 00 00       	add    $0x3ff,%eax
80106dfb:	c1 f8 0a             	sar    $0xa,%eax
80106dfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d / Disk Available: %d\n", used, get_max_disk(x));
80106e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e04:	89 04 24             	mov    %eax,(%esp)
80106e07:	e8 df 20 00 00       	call   80108eeb <get_max_disk>
80106e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e13:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e17:	c7 04 24 a4 98 10 80 	movl   $0x801098a4,(%esp)
80106e1e:	e8 9e 95 ff ff       	call   801003c1 <cprintf>
  }
}
80106e23:	c9                   	leave  
80106e24:	c3                   	ret    
80106e25:	00 00                	add    %al,(%eax)
	...

80106e28 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106e28:	1e                   	push   %ds
  pushl %es
80106e29:	06                   	push   %es
  pushl %fs
80106e2a:	0f a0                	push   %fs
  pushl %gs
80106e2c:	0f a8                	push   %gs
  pushal
80106e2e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106e2f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106e33:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106e35:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106e37:	54                   	push   %esp
  call trap
80106e38:	e8 c0 01 00 00       	call   80106ffd <trap>
  addl $4, %esp
80106e3d:	83 c4 04             	add    $0x4,%esp

80106e40 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106e40:	61                   	popa   
  popl %gs
80106e41:	0f a9                	pop    %gs
  popl %fs
80106e43:	0f a1                	pop    %fs
  popl %es
80106e45:	07                   	pop    %es
  popl %ds
80106e46:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106e47:	83 c4 08             	add    $0x8,%esp
  iret
80106e4a:	cf                   	iret   
	...

80106e4c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106e4c:	55                   	push   %ebp
80106e4d:	89 e5                	mov    %esp,%ebp
80106e4f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106e52:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e55:	48                   	dec    %eax
80106e56:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e61:	8b 45 08             	mov    0x8(%ebp),%eax
80106e64:	c1 e8 10             	shr    $0x10,%eax
80106e67:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106e6b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e6e:	0f 01 18             	lidtl  (%eax)
}
80106e71:	c9                   	leave  
80106e72:	c3                   	ret    

80106e73 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106e73:	55                   	push   %ebp
80106e74:	89 e5                	mov    %esp,%ebp
80106e76:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106e79:	0f 20 d0             	mov    %cr2,%eax
80106e7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106e7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106e82:	c9                   	leave  
80106e83:	c3                   	ret    

80106e84 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106e84:	55                   	push   %ebp
80106e85:	89 e5                	mov    %esp,%ebp
80106e87:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106e8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e91:	e9 b8 00 00 00       	jmp    80106f4e <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e99:	8b 04 85 fc c0 10 80 	mov    -0x7fef3f04(,%eax,4),%eax
80106ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ea3:	66 89 04 d5 a0 73 11 	mov    %ax,-0x7fee8c60(,%edx,8)
80106eaa:	80 
80106eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eae:	66 c7 04 c5 a2 73 11 	movw   $0x8,-0x7fee8c5e(,%eax,8)
80106eb5:	80 08 00 
80106eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebb:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106ec2:	83 e2 e0             	and    $0xffffffe0,%edx
80106ec5:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ecf:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106ed6:	83 e2 1f             	and    $0x1f,%edx
80106ed9:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee3:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106eea:	83 e2 f0             	and    $0xfffffff0,%edx
80106eed:	83 ca 0e             	or     $0xe,%edx
80106ef0:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106efa:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f01:	83 e2 ef             	and    $0xffffffef,%edx
80106f04:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0e:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f15:	83 e2 9f             	and    $0xffffff9f,%edx
80106f18:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f22:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106f29:	83 ca 80             	or     $0xffffff80,%edx
80106f2c:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f36:	8b 04 85 fc c0 10 80 	mov    -0x7fef3f04(,%eax,4),%eax
80106f3d:	c1 e8 10             	shr    $0x10,%eax
80106f40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f43:	66 89 04 d5 a6 73 11 	mov    %ax,-0x7fee8c5a(,%edx,8)
80106f4a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106f4b:	ff 45 f4             	incl   -0xc(%ebp)
80106f4e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106f55:	0f 8e 3b ff ff ff    	jle    80106e96 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106f5b:	a1 fc c1 10 80       	mov    0x8010c1fc,%eax
80106f60:	66 a3 a0 75 11 80    	mov    %ax,0x801175a0
80106f66:	66 c7 05 a2 75 11 80 	movw   $0x8,0x801175a2
80106f6d:	08 00 
80106f6f:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106f74:	83 e0 e0             	and    $0xffffffe0,%eax
80106f77:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106f7c:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106f81:	83 e0 1f             	and    $0x1f,%eax
80106f84:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106f89:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106f8e:	83 c8 0f             	or     $0xf,%eax
80106f91:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106f96:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106f9b:	83 e0 ef             	and    $0xffffffef,%eax
80106f9e:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106fa3:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106fa8:	83 c8 60             	or     $0x60,%eax
80106fab:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106fb0:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106fb5:	83 c8 80             	or     $0xffffff80,%eax
80106fb8:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106fbd:	a1 fc c1 10 80       	mov    0x8010c1fc,%eax
80106fc2:	c1 e8 10             	shr    $0x10,%eax
80106fc5:	66 a3 a6 75 11 80    	mov    %ax,0x801175a6

  initlock(&tickslock, "time");
80106fcb:	c7 44 24 04 cc 98 10 	movl   $0x801098cc,0x4(%esp)
80106fd2:	80 
80106fd3:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106fda:	e8 8f e2 ff ff       	call   8010526e <initlock>
}
80106fdf:	c9                   	leave  
80106fe0:	c3                   	ret    

80106fe1 <idtinit>:

void
idtinit(void)
{
80106fe1:	55                   	push   %ebp
80106fe2:	89 e5                	mov    %esp,%ebp
80106fe4:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106fe7:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106fee:	00 
80106fef:	c7 04 24 a0 73 11 80 	movl   $0x801173a0,(%esp)
80106ff6:	e8 51 fe ff ff       	call   80106e4c <lidt>
}
80106ffb:	c9                   	leave  
80106ffc:	c3                   	ret    

80106ffd <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ffd:	55                   	push   %ebp
80106ffe:	89 e5                	mov    %esp,%ebp
80107000:	57                   	push   %edi
80107001:	56                   	push   %esi
80107002:	53                   	push   %ebx
80107003:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80107006:	8b 45 08             	mov    0x8(%ebp),%eax
80107009:	8b 40 30             	mov    0x30(%eax),%eax
8010700c:	83 f8 40             	cmp    $0x40,%eax
8010700f:	75 3c                	jne    8010704d <trap+0x50>
    if(myproc()->killed)
80107011:	e8 8d d3 ff ff       	call   801043a3 <myproc>
80107016:	8b 40 24             	mov    0x24(%eax),%eax
80107019:	85 c0                	test   %eax,%eax
8010701b:	74 05                	je     80107022 <trap+0x25>
      exit();
8010701d:	e8 12 d8 ff ff       	call   80104834 <exit>
    myproc()->tf = tf;
80107022:	e8 7c d3 ff ff       	call   801043a3 <myproc>
80107027:	8b 55 08             	mov    0x8(%ebp),%edx
8010702a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010702d:	e8 c1 e8 ff ff       	call   801058f3 <syscall>
    if(myproc()->killed)
80107032:	e8 6c d3 ff ff       	call   801043a3 <myproc>
80107037:	8b 40 24             	mov    0x24(%eax),%eax
8010703a:	85 c0                	test   %eax,%eax
8010703c:	74 0a                	je     80107048 <trap+0x4b>
      exit();
8010703e:	e8 f1 d7 ff ff       	call   80104834 <exit>
    return;
80107043:	e9 30 02 00 00       	jmp    80107278 <trap+0x27b>
80107048:	e9 2b 02 00 00       	jmp    80107278 <trap+0x27b>
  }

  switch(tf->trapno){
8010704d:	8b 45 08             	mov    0x8(%ebp),%eax
80107050:	8b 40 30             	mov    0x30(%eax),%eax
80107053:	83 e8 20             	sub    $0x20,%eax
80107056:	83 f8 1f             	cmp    $0x1f,%eax
80107059:	0f 87 cb 00 00 00    	ja     8010712a <trap+0x12d>
8010705f:	8b 04 85 74 99 10 80 	mov    -0x7fef668c(,%eax,4),%eax
80107066:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107068:	e8 6d d2 ff ff       	call   801042da <cpuid>
8010706d:	85 c0                	test   %eax,%eax
8010706f:	75 2f                	jne    801070a0 <trap+0xa3>
      acquire(&tickslock);
80107071:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80107078:	e8 12 e2 ff ff       	call   8010528f <acquire>
      ticks++;
8010707d:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80107082:	40                   	inc    %eax
80107083:	a3 a0 7b 11 80       	mov    %eax,0x80117ba0
      wakeup(&ticks);
80107088:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
8010708f:	e8 97 dc ff ff       	call   80104d2b <wakeup>
      release(&tickslock);
80107094:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010709b:	e8 59 e2 ff ff       	call   801052f9 <release>
    }
    p = myproc();
801070a0:	e8 fe d2 ff ff       	call   801043a3 <myproc>
801070a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801070a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801070ac:	74 0f                	je     801070bd <trap+0xc0>
      p->ticks++;
801070ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070b1:	8b 40 7c             	mov    0x7c(%eax),%eax
801070b4:	8d 50 01             	lea    0x1(%eax),%edx
801070b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070ba:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801070bd:	e8 b9 c0 ff ff       	call   8010317b <lapiceoi>
    break;
801070c2:	e9 35 01 00 00       	jmp    801071fc <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801070c7:	e8 ae b8 ff ff       	call   8010297a <ideintr>
    lapiceoi();
801070cc:	e8 aa c0 ff ff       	call   8010317b <lapiceoi>
    break;
801070d1:	e9 26 01 00 00       	jmp    801071fc <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801070d6:	e8 b7 be ff ff       	call   80102f92 <kbdintr>
    lapiceoi();
801070db:	e8 9b c0 ff ff       	call   8010317b <lapiceoi>
    break;
801070e0:	e9 17 01 00 00       	jmp    801071fc <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801070e5:	e8 6f 03 00 00       	call   80107459 <uartintr>
    lapiceoi();
801070ea:	e8 8c c0 ff ff       	call   8010317b <lapiceoi>
    break;
801070ef:	e9 08 01 00 00       	jmp    801071fc <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801070f4:	8b 45 08             	mov    0x8(%ebp),%eax
801070f7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801070fa:	8b 45 08             	mov    0x8(%ebp),%eax
801070fd:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107100:	0f b7 d8             	movzwl %ax,%ebx
80107103:	e8 d2 d1 ff ff       	call   801042da <cpuid>
80107108:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010710c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107110:	89 44 24 04          	mov    %eax,0x4(%esp)
80107114:	c7 04 24 d4 98 10 80 	movl   $0x801098d4,(%esp)
8010711b:	e8 a1 92 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107120:	e8 56 c0 ff ff       	call   8010317b <lapiceoi>
    break;
80107125:	e9 d2 00 00 00       	jmp    801071fc <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010712a:	e8 74 d2 ff ff       	call   801043a3 <myproc>
8010712f:	85 c0                	test   %eax,%eax
80107131:	74 10                	je     80107143 <trap+0x146>
80107133:	8b 45 08             	mov    0x8(%ebp),%eax
80107136:	8b 40 3c             	mov    0x3c(%eax),%eax
80107139:	0f b7 c0             	movzwl %ax,%eax
8010713c:	83 e0 03             	and    $0x3,%eax
8010713f:	85 c0                	test   %eax,%eax
80107141:	75 40                	jne    80107183 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107143:	e8 2b fd ff ff       	call   80106e73 <rcr2>
80107148:	89 c3                	mov    %eax,%ebx
8010714a:	8b 45 08             	mov    0x8(%ebp),%eax
8010714d:	8b 70 38             	mov    0x38(%eax),%esi
80107150:	e8 85 d1 ff ff       	call   801042da <cpuid>
80107155:	8b 55 08             	mov    0x8(%ebp),%edx
80107158:	8b 52 30             	mov    0x30(%edx),%edx
8010715b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010715f:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107163:	89 44 24 08          	mov    %eax,0x8(%esp)
80107167:	89 54 24 04          	mov    %edx,0x4(%esp)
8010716b:	c7 04 24 f8 98 10 80 	movl   $0x801098f8,(%esp)
80107172:	e8 4a 92 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107177:	c7 04 24 2a 99 10 80 	movl   $0x8010992a,(%esp)
8010717e:	e8 d1 93 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107183:	e8 eb fc ff ff       	call   80106e73 <rcr2>
80107188:	89 c6                	mov    %eax,%esi
8010718a:	8b 45 08             	mov    0x8(%ebp),%eax
8010718d:	8b 40 38             	mov    0x38(%eax),%eax
80107190:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107193:	e8 42 d1 ff ff       	call   801042da <cpuid>
80107198:	89 c3                	mov    %eax,%ebx
8010719a:	8b 45 08             	mov    0x8(%ebp),%eax
8010719d:	8b 78 34             	mov    0x34(%eax),%edi
801071a0:	89 7d d0             	mov    %edi,-0x30(%ebp)
801071a3:	8b 45 08             	mov    0x8(%ebp),%eax
801071a6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801071a9:	e8 f5 d1 ff ff       	call   801043a3 <myproc>
801071ae:	8d 50 6c             	lea    0x6c(%eax),%edx
801071b1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801071b4:	e8 ea d1 ff ff       	call   801043a3 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801071b9:	8b 40 10             	mov    0x10(%eax),%eax
801071bc:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801071c0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801071c3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801071c7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801071cb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801071ce:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801071d2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801071d6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801071d9:	89 54 24 08          	mov    %edx,0x8(%esp)
801071dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801071e1:	c7 04 24 30 99 10 80 	movl   $0x80109930,(%esp)
801071e8:	e8 d4 91 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801071ed:	e8 b1 d1 ff ff       	call   801043a3 <myproc>
801071f2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801071f9:	eb 01                	jmp    801071fc <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801071fb:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801071fc:	e8 a2 d1 ff ff       	call   801043a3 <myproc>
80107201:	85 c0                	test   %eax,%eax
80107203:	74 22                	je     80107227 <trap+0x22a>
80107205:	e8 99 d1 ff ff       	call   801043a3 <myproc>
8010720a:	8b 40 24             	mov    0x24(%eax),%eax
8010720d:	85 c0                	test   %eax,%eax
8010720f:	74 16                	je     80107227 <trap+0x22a>
80107211:	8b 45 08             	mov    0x8(%ebp),%eax
80107214:	8b 40 3c             	mov    0x3c(%eax),%eax
80107217:	0f b7 c0             	movzwl %ax,%eax
8010721a:	83 e0 03             	and    $0x3,%eax
8010721d:	83 f8 03             	cmp    $0x3,%eax
80107220:	75 05                	jne    80107227 <trap+0x22a>
    exit();
80107222:	e8 0d d6 ff ff       	call   80104834 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107227:	e8 77 d1 ff ff       	call   801043a3 <myproc>
8010722c:	85 c0                	test   %eax,%eax
8010722e:	74 1d                	je     8010724d <trap+0x250>
80107230:	e8 6e d1 ff ff       	call   801043a3 <myproc>
80107235:	8b 40 0c             	mov    0xc(%eax),%eax
80107238:	83 f8 04             	cmp    $0x4,%eax
8010723b:	75 10                	jne    8010724d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010723d:	8b 45 08             	mov    0x8(%ebp),%eax
80107240:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107243:	83 f8 20             	cmp    $0x20,%eax
80107246:	75 05                	jne    8010724d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107248:	e8 97 d9 ff ff       	call   80104be4 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010724d:	e8 51 d1 ff ff       	call   801043a3 <myproc>
80107252:	85 c0                	test   %eax,%eax
80107254:	74 22                	je     80107278 <trap+0x27b>
80107256:	e8 48 d1 ff ff       	call   801043a3 <myproc>
8010725b:	8b 40 24             	mov    0x24(%eax),%eax
8010725e:	85 c0                	test   %eax,%eax
80107260:	74 16                	je     80107278 <trap+0x27b>
80107262:	8b 45 08             	mov    0x8(%ebp),%eax
80107265:	8b 40 3c             	mov    0x3c(%eax),%eax
80107268:	0f b7 c0             	movzwl %ax,%eax
8010726b:	83 e0 03             	and    $0x3,%eax
8010726e:	83 f8 03             	cmp    $0x3,%eax
80107271:	75 05                	jne    80107278 <trap+0x27b>
    exit();
80107273:	e8 bc d5 ff ff       	call   80104834 <exit>
}
80107278:	83 c4 4c             	add    $0x4c,%esp
8010727b:	5b                   	pop    %ebx
8010727c:	5e                   	pop    %esi
8010727d:	5f                   	pop    %edi
8010727e:	5d                   	pop    %ebp
8010727f:	c3                   	ret    

80107280 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107280:	55                   	push   %ebp
80107281:	89 e5                	mov    %esp,%ebp
80107283:	83 ec 14             	sub    $0x14,%esp
80107286:	8b 45 08             	mov    0x8(%ebp),%eax
80107289:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010728d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107290:	89 c2                	mov    %eax,%edx
80107292:	ec                   	in     (%dx),%al
80107293:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107296:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80107299:	c9                   	leave  
8010729a:	c3                   	ret    

8010729b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010729b:	55                   	push   %ebp
8010729c:	89 e5                	mov    %esp,%ebp
8010729e:	83 ec 08             	sub    $0x8,%esp
801072a1:	8b 45 08             	mov    0x8(%ebp),%eax
801072a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801072a7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801072ab:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801072ae:	8a 45 f8             	mov    -0x8(%ebp),%al
801072b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801072b4:	ee                   	out    %al,(%dx)
}
801072b5:	c9                   	leave  
801072b6:	c3                   	ret    

801072b7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801072b7:	55                   	push   %ebp
801072b8:	89 e5                	mov    %esp,%ebp
801072ba:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801072bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801072c4:	00 
801072c5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801072cc:	e8 ca ff ff ff       	call   8010729b <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801072d1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801072d8:	00 
801072d9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801072e0:	e8 b6 ff ff ff       	call   8010729b <outb>
  outb(COM1+0, 115200/9600);
801072e5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801072ec:	00 
801072ed:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801072f4:	e8 a2 ff ff ff       	call   8010729b <outb>
  outb(COM1+1, 0);
801072f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107300:	00 
80107301:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107308:	e8 8e ff ff ff       	call   8010729b <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010730d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107314:	00 
80107315:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010731c:	e8 7a ff ff ff       	call   8010729b <outb>
  outb(COM1+4, 0);
80107321:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107328:	00 
80107329:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107330:	e8 66 ff ff ff       	call   8010729b <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107335:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010733c:	00 
8010733d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107344:	e8 52 ff ff ff       	call   8010729b <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107349:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107350:	e8 2b ff ff ff       	call   80107280 <inb>
80107355:	3c ff                	cmp    $0xff,%al
80107357:	75 02                	jne    8010735b <uartinit+0xa4>
    return;
80107359:	eb 5b                	jmp    801073b6 <uartinit+0xff>
  uart = 1;
8010735b:	c7 05 04 c9 10 80 01 	movl   $0x1,0x8010c904
80107362:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107365:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010736c:	e8 0f ff ff ff       	call   80107280 <inb>
  inb(COM1+0);
80107371:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107378:	e8 03 ff ff ff       	call   80107280 <inb>
  ioapicenable(IRQ_COM1, 0);
8010737d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107384:	00 
80107385:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010738c:	e8 5e b8 ff ff       	call   80102bef <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107391:	c7 45 f4 f4 99 10 80 	movl   $0x801099f4,-0xc(%ebp)
80107398:	eb 13                	jmp    801073ad <uartinit+0xf6>
    uartputc(*p);
8010739a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739d:	8a 00                	mov    (%eax),%al
8010739f:	0f be c0             	movsbl %al,%eax
801073a2:	89 04 24             	mov    %eax,(%esp)
801073a5:	e8 0e 00 00 00       	call   801073b8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801073aa:	ff 45 f4             	incl   -0xc(%ebp)
801073ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b0:	8a 00                	mov    (%eax),%al
801073b2:	84 c0                	test   %al,%al
801073b4:	75 e4                	jne    8010739a <uartinit+0xe3>
    uartputc(*p);
}
801073b6:	c9                   	leave  
801073b7:	c3                   	ret    

801073b8 <uartputc>:

void
uartputc(int c)
{
801073b8:	55                   	push   %ebp
801073b9:	89 e5                	mov    %esp,%ebp
801073bb:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801073be:	a1 04 c9 10 80       	mov    0x8010c904,%eax
801073c3:	85 c0                	test   %eax,%eax
801073c5:	75 02                	jne    801073c9 <uartputc+0x11>
    return;
801073c7:	eb 4a                	jmp    80107413 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801073c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801073d0:	eb 0f                	jmp    801073e1 <uartputc+0x29>
    microdelay(10);
801073d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801073d9:	e8 c2 bd ff ff       	call   801031a0 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801073de:	ff 45 f4             	incl   -0xc(%ebp)
801073e1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801073e5:	7f 16                	jg     801073fd <uartputc+0x45>
801073e7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801073ee:	e8 8d fe ff ff       	call   80107280 <inb>
801073f3:	0f b6 c0             	movzbl %al,%eax
801073f6:	83 e0 20             	and    $0x20,%eax
801073f9:	85 c0                	test   %eax,%eax
801073fb:	74 d5                	je     801073d2 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801073fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107400:	0f b6 c0             	movzbl %al,%eax
80107403:	89 44 24 04          	mov    %eax,0x4(%esp)
80107407:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010740e:	e8 88 fe ff ff       	call   8010729b <outb>
}
80107413:	c9                   	leave  
80107414:	c3                   	ret    

80107415 <uartgetc>:

static int
uartgetc(void)
{
80107415:	55                   	push   %ebp
80107416:	89 e5                	mov    %esp,%ebp
80107418:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010741b:	a1 04 c9 10 80       	mov    0x8010c904,%eax
80107420:	85 c0                	test   %eax,%eax
80107422:	75 07                	jne    8010742b <uartgetc+0x16>
    return -1;
80107424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107429:	eb 2c                	jmp    80107457 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010742b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107432:	e8 49 fe ff ff       	call   80107280 <inb>
80107437:	0f b6 c0             	movzbl %al,%eax
8010743a:	83 e0 01             	and    $0x1,%eax
8010743d:	85 c0                	test   %eax,%eax
8010743f:	75 07                	jne    80107448 <uartgetc+0x33>
    return -1;
80107441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107446:	eb 0f                	jmp    80107457 <uartgetc+0x42>
  return inb(COM1+0);
80107448:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010744f:	e8 2c fe ff ff       	call   80107280 <inb>
80107454:	0f b6 c0             	movzbl %al,%eax
}
80107457:	c9                   	leave  
80107458:	c3                   	ret    

80107459 <uartintr>:

void
uartintr(void)
{
80107459:	55                   	push   %ebp
8010745a:	89 e5                	mov    %esp,%ebp
8010745c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010745f:	c7 04 24 15 74 10 80 	movl   $0x80107415,(%esp)
80107466:	e8 8a 93 ff ff       	call   801007f5 <consoleintr>
}
8010746b:	c9                   	leave  
8010746c:	c3                   	ret    
8010746d:	00 00                	add    %al,(%eax)
	...

80107470 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $0
80107472:	6a 00                	push   $0x0
  jmp alltraps
80107474:	e9 af f9 ff ff       	jmp    80106e28 <alltraps>

80107479 <vector1>:
.globl vector1
vector1:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $1
8010747b:	6a 01                	push   $0x1
  jmp alltraps
8010747d:	e9 a6 f9 ff ff       	jmp    80106e28 <alltraps>

80107482 <vector2>:
.globl vector2
vector2:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $2
80107484:	6a 02                	push   $0x2
  jmp alltraps
80107486:	e9 9d f9 ff ff       	jmp    80106e28 <alltraps>

8010748b <vector3>:
.globl vector3
vector3:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $3
8010748d:	6a 03                	push   $0x3
  jmp alltraps
8010748f:	e9 94 f9 ff ff       	jmp    80106e28 <alltraps>

80107494 <vector4>:
.globl vector4
vector4:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $4
80107496:	6a 04                	push   $0x4
  jmp alltraps
80107498:	e9 8b f9 ff ff       	jmp    80106e28 <alltraps>

8010749d <vector5>:
.globl vector5
vector5:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $5
8010749f:	6a 05                	push   $0x5
  jmp alltraps
801074a1:	e9 82 f9 ff ff       	jmp    80106e28 <alltraps>

801074a6 <vector6>:
.globl vector6
vector6:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $6
801074a8:	6a 06                	push   $0x6
  jmp alltraps
801074aa:	e9 79 f9 ff ff       	jmp    80106e28 <alltraps>

801074af <vector7>:
.globl vector7
vector7:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $7
801074b1:	6a 07                	push   $0x7
  jmp alltraps
801074b3:	e9 70 f9 ff ff       	jmp    80106e28 <alltraps>

801074b8 <vector8>:
.globl vector8
vector8:
  pushl $8
801074b8:	6a 08                	push   $0x8
  jmp alltraps
801074ba:	e9 69 f9 ff ff       	jmp    80106e28 <alltraps>

801074bf <vector9>:
.globl vector9
vector9:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $9
801074c1:	6a 09                	push   $0x9
  jmp alltraps
801074c3:	e9 60 f9 ff ff       	jmp    80106e28 <alltraps>

801074c8 <vector10>:
.globl vector10
vector10:
  pushl $10
801074c8:	6a 0a                	push   $0xa
  jmp alltraps
801074ca:	e9 59 f9 ff ff       	jmp    80106e28 <alltraps>

801074cf <vector11>:
.globl vector11
vector11:
  pushl $11
801074cf:	6a 0b                	push   $0xb
  jmp alltraps
801074d1:	e9 52 f9 ff ff       	jmp    80106e28 <alltraps>

801074d6 <vector12>:
.globl vector12
vector12:
  pushl $12
801074d6:	6a 0c                	push   $0xc
  jmp alltraps
801074d8:	e9 4b f9 ff ff       	jmp    80106e28 <alltraps>

801074dd <vector13>:
.globl vector13
vector13:
  pushl $13
801074dd:	6a 0d                	push   $0xd
  jmp alltraps
801074df:	e9 44 f9 ff ff       	jmp    80106e28 <alltraps>

801074e4 <vector14>:
.globl vector14
vector14:
  pushl $14
801074e4:	6a 0e                	push   $0xe
  jmp alltraps
801074e6:	e9 3d f9 ff ff       	jmp    80106e28 <alltraps>

801074eb <vector15>:
.globl vector15
vector15:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $15
801074ed:	6a 0f                	push   $0xf
  jmp alltraps
801074ef:	e9 34 f9 ff ff       	jmp    80106e28 <alltraps>

801074f4 <vector16>:
.globl vector16
vector16:
  pushl $0
801074f4:	6a 00                	push   $0x0
  pushl $16
801074f6:	6a 10                	push   $0x10
  jmp alltraps
801074f8:	e9 2b f9 ff ff       	jmp    80106e28 <alltraps>

801074fd <vector17>:
.globl vector17
vector17:
  pushl $17
801074fd:	6a 11                	push   $0x11
  jmp alltraps
801074ff:	e9 24 f9 ff ff       	jmp    80106e28 <alltraps>

80107504 <vector18>:
.globl vector18
vector18:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $18
80107506:	6a 12                	push   $0x12
  jmp alltraps
80107508:	e9 1b f9 ff ff       	jmp    80106e28 <alltraps>

8010750d <vector19>:
.globl vector19
vector19:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $19
8010750f:	6a 13                	push   $0x13
  jmp alltraps
80107511:	e9 12 f9 ff ff       	jmp    80106e28 <alltraps>

80107516 <vector20>:
.globl vector20
vector20:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $20
80107518:	6a 14                	push   $0x14
  jmp alltraps
8010751a:	e9 09 f9 ff ff       	jmp    80106e28 <alltraps>

8010751f <vector21>:
.globl vector21
vector21:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $21
80107521:	6a 15                	push   $0x15
  jmp alltraps
80107523:	e9 00 f9 ff ff       	jmp    80106e28 <alltraps>

80107528 <vector22>:
.globl vector22
vector22:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $22
8010752a:	6a 16                	push   $0x16
  jmp alltraps
8010752c:	e9 f7 f8 ff ff       	jmp    80106e28 <alltraps>

80107531 <vector23>:
.globl vector23
vector23:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $23
80107533:	6a 17                	push   $0x17
  jmp alltraps
80107535:	e9 ee f8 ff ff       	jmp    80106e28 <alltraps>

8010753a <vector24>:
.globl vector24
vector24:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $24
8010753c:	6a 18                	push   $0x18
  jmp alltraps
8010753e:	e9 e5 f8 ff ff       	jmp    80106e28 <alltraps>

80107543 <vector25>:
.globl vector25
vector25:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $25
80107545:	6a 19                	push   $0x19
  jmp alltraps
80107547:	e9 dc f8 ff ff       	jmp    80106e28 <alltraps>

8010754c <vector26>:
.globl vector26
vector26:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $26
8010754e:	6a 1a                	push   $0x1a
  jmp alltraps
80107550:	e9 d3 f8 ff ff       	jmp    80106e28 <alltraps>

80107555 <vector27>:
.globl vector27
vector27:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $27
80107557:	6a 1b                	push   $0x1b
  jmp alltraps
80107559:	e9 ca f8 ff ff       	jmp    80106e28 <alltraps>

8010755e <vector28>:
.globl vector28
vector28:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $28
80107560:	6a 1c                	push   $0x1c
  jmp alltraps
80107562:	e9 c1 f8 ff ff       	jmp    80106e28 <alltraps>

80107567 <vector29>:
.globl vector29
vector29:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $29
80107569:	6a 1d                	push   $0x1d
  jmp alltraps
8010756b:	e9 b8 f8 ff ff       	jmp    80106e28 <alltraps>

80107570 <vector30>:
.globl vector30
vector30:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $30
80107572:	6a 1e                	push   $0x1e
  jmp alltraps
80107574:	e9 af f8 ff ff       	jmp    80106e28 <alltraps>

80107579 <vector31>:
.globl vector31
vector31:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $31
8010757b:	6a 1f                	push   $0x1f
  jmp alltraps
8010757d:	e9 a6 f8 ff ff       	jmp    80106e28 <alltraps>

80107582 <vector32>:
.globl vector32
vector32:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $32
80107584:	6a 20                	push   $0x20
  jmp alltraps
80107586:	e9 9d f8 ff ff       	jmp    80106e28 <alltraps>

8010758b <vector33>:
.globl vector33
vector33:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $33
8010758d:	6a 21                	push   $0x21
  jmp alltraps
8010758f:	e9 94 f8 ff ff       	jmp    80106e28 <alltraps>

80107594 <vector34>:
.globl vector34
vector34:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $34
80107596:	6a 22                	push   $0x22
  jmp alltraps
80107598:	e9 8b f8 ff ff       	jmp    80106e28 <alltraps>

8010759d <vector35>:
.globl vector35
vector35:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $35
8010759f:	6a 23                	push   $0x23
  jmp alltraps
801075a1:	e9 82 f8 ff ff       	jmp    80106e28 <alltraps>

801075a6 <vector36>:
.globl vector36
vector36:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $36
801075a8:	6a 24                	push   $0x24
  jmp alltraps
801075aa:	e9 79 f8 ff ff       	jmp    80106e28 <alltraps>

801075af <vector37>:
.globl vector37
vector37:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $37
801075b1:	6a 25                	push   $0x25
  jmp alltraps
801075b3:	e9 70 f8 ff ff       	jmp    80106e28 <alltraps>

801075b8 <vector38>:
.globl vector38
vector38:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $38
801075ba:	6a 26                	push   $0x26
  jmp alltraps
801075bc:	e9 67 f8 ff ff       	jmp    80106e28 <alltraps>

801075c1 <vector39>:
.globl vector39
vector39:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $39
801075c3:	6a 27                	push   $0x27
  jmp alltraps
801075c5:	e9 5e f8 ff ff       	jmp    80106e28 <alltraps>

801075ca <vector40>:
.globl vector40
vector40:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $40
801075cc:	6a 28                	push   $0x28
  jmp alltraps
801075ce:	e9 55 f8 ff ff       	jmp    80106e28 <alltraps>

801075d3 <vector41>:
.globl vector41
vector41:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $41
801075d5:	6a 29                	push   $0x29
  jmp alltraps
801075d7:	e9 4c f8 ff ff       	jmp    80106e28 <alltraps>

801075dc <vector42>:
.globl vector42
vector42:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $42
801075de:	6a 2a                	push   $0x2a
  jmp alltraps
801075e0:	e9 43 f8 ff ff       	jmp    80106e28 <alltraps>

801075e5 <vector43>:
.globl vector43
vector43:
  pushl $0
801075e5:	6a 00                	push   $0x0
  pushl $43
801075e7:	6a 2b                	push   $0x2b
  jmp alltraps
801075e9:	e9 3a f8 ff ff       	jmp    80106e28 <alltraps>

801075ee <vector44>:
.globl vector44
vector44:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $44
801075f0:	6a 2c                	push   $0x2c
  jmp alltraps
801075f2:	e9 31 f8 ff ff       	jmp    80106e28 <alltraps>

801075f7 <vector45>:
.globl vector45
vector45:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $45
801075f9:	6a 2d                	push   $0x2d
  jmp alltraps
801075fb:	e9 28 f8 ff ff       	jmp    80106e28 <alltraps>

80107600 <vector46>:
.globl vector46
vector46:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $46
80107602:	6a 2e                	push   $0x2e
  jmp alltraps
80107604:	e9 1f f8 ff ff       	jmp    80106e28 <alltraps>

80107609 <vector47>:
.globl vector47
vector47:
  pushl $0
80107609:	6a 00                	push   $0x0
  pushl $47
8010760b:	6a 2f                	push   $0x2f
  jmp alltraps
8010760d:	e9 16 f8 ff ff       	jmp    80106e28 <alltraps>

80107612 <vector48>:
.globl vector48
vector48:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $48
80107614:	6a 30                	push   $0x30
  jmp alltraps
80107616:	e9 0d f8 ff ff       	jmp    80106e28 <alltraps>

8010761b <vector49>:
.globl vector49
vector49:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $49
8010761d:	6a 31                	push   $0x31
  jmp alltraps
8010761f:	e9 04 f8 ff ff       	jmp    80106e28 <alltraps>

80107624 <vector50>:
.globl vector50
vector50:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $50
80107626:	6a 32                	push   $0x32
  jmp alltraps
80107628:	e9 fb f7 ff ff       	jmp    80106e28 <alltraps>

8010762d <vector51>:
.globl vector51
vector51:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $51
8010762f:	6a 33                	push   $0x33
  jmp alltraps
80107631:	e9 f2 f7 ff ff       	jmp    80106e28 <alltraps>

80107636 <vector52>:
.globl vector52
vector52:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $52
80107638:	6a 34                	push   $0x34
  jmp alltraps
8010763a:	e9 e9 f7 ff ff       	jmp    80106e28 <alltraps>

8010763f <vector53>:
.globl vector53
vector53:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $53
80107641:	6a 35                	push   $0x35
  jmp alltraps
80107643:	e9 e0 f7 ff ff       	jmp    80106e28 <alltraps>

80107648 <vector54>:
.globl vector54
vector54:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $54
8010764a:	6a 36                	push   $0x36
  jmp alltraps
8010764c:	e9 d7 f7 ff ff       	jmp    80106e28 <alltraps>

80107651 <vector55>:
.globl vector55
vector55:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $55
80107653:	6a 37                	push   $0x37
  jmp alltraps
80107655:	e9 ce f7 ff ff       	jmp    80106e28 <alltraps>

8010765a <vector56>:
.globl vector56
vector56:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $56
8010765c:	6a 38                	push   $0x38
  jmp alltraps
8010765e:	e9 c5 f7 ff ff       	jmp    80106e28 <alltraps>

80107663 <vector57>:
.globl vector57
vector57:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $57
80107665:	6a 39                	push   $0x39
  jmp alltraps
80107667:	e9 bc f7 ff ff       	jmp    80106e28 <alltraps>

8010766c <vector58>:
.globl vector58
vector58:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $58
8010766e:	6a 3a                	push   $0x3a
  jmp alltraps
80107670:	e9 b3 f7 ff ff       	jmp    80106e28 <alltraps>

80107675 <vector59>:
.globl vector59
vector59:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $59
80107677:	6a 3b                	push   $0x3b
  jmp alltraps
80107679:	e9 aa f7 ff ff       	jmp    80106e28 <alltraps>

8010767e <vector60>:
.globl vector60
vector60:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $60
80107680:	6a 3c                	push   $0x3c
  jmp alltraps
80107682:	e9 a1 f7 ff ff       	jmp    80106e28 <alltraps>

80107687 <vector61>:
.globl vector61
vector61:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $61
80107689:	6a 3d                	push   $0x3d
  jmp alltraps
8010768b:	e9 98 f7 ff ff       	jmp    80106e28 <alltraps>

80107690 <vector62>:
.globl vector62
vector62:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $62
80107692:	6a 3e                	push   $0x3e
  jmp alltraps
80107694:	e9 8f f7 ff ff       	jmp    80106e28 <alltraps>

80107699 <vector63>:
.globl vector63
vector63:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $63
8010769b:	6a 3f                	push   $0x3f
  jmp alltraps
8010769d:	e9 86 f7 ff ff       	jmp    80106e28 <alltraps>

801076a2 <vector64>:
.globl vector64
vector64:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $64
801076a4:	6a 40                	push   $0x40
  jmp alltraps
801076a6:	e9 7d f7 ff ff       	jmp    80106e28 <alltraps>

801076ab <vector65>:
.globl vector65
vector65:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $65
801076ad:	6a 41                	push   $0x41
  jmp alltraps
801076af:	e9 74 f7 ff ff       	jmp    80106e28 <alltraps>

801076b4 <vector66>:
.globl vector66
vector66:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $66
801076b6:	6a 42                	push   $0x42
  jmp alltraps
801076b8:	e9 6b f7 ff ff       	jmp    80106e28 <alltraps>

801076bd <vector67>:
.globl vector67
vector67:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $67
801076bf:	6a 43                	push   $0x43
  jmp alltraps
801076c1:	e9 62 f7 ff ff       	jmp    80106e28 <alltraps>

801076c6 <vector68>:
.globl vector68
vector68:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $68
801076c8:	6a 44                	push   $0x44
  jmp alltraps
801076ca:	e9 59 f7 ff ff       	jmp    80106e28 <alltraps>

801076cf <vector69>:
.globl vector69
vector69:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $69
801076d1:	6a 45                	push   $0x45
  jmp alltraps
801076d3:	e9 50 f7 ff ff       	jmp    80106e28 <alltraps>

801076d8 <vector70>:
.globl vector70
vector70:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $70
801076da:	6a 46                	push   $0x46
  jmp alltraps
801076dc:	e9 47 f7 ff ff       	jmp    80106e28 <alltraps>

801076e1 <vector71>:
.globl vector71
vector71:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $71
801076e3:	6a 47                	push   $0x47
  jmp alltraps
801076e5:	e9 3e f7 ff ff       	jmp    80106e28 <alltraps>

801076ea <vector72>:
.globl vector72
vector72:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $72
801076ec:	6a 48                	push   $0x48
  jmp alltraps
801076ee:	e9 35 f7 ff ff       	jmp    80106e28 <alltraps>

801076f3 <vector73>:
.globl vector73
vector73:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $73
801076f5:	6a 49                	push   $0x49
  jmp alltraps
801076f7:	e9 2c f7 ff ff       	jmp    80106e28 <alltraps>

801076fc <vector74>:
.globl vector74
vector74:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $74
801076fe:	6a 4a                	push   $0x4a
  jmp alltraps
80107700:	e9 23 f7 ff ff       	jmp    80106e28 <alltraps>

80107705 <vector75>:
.globl vector75
vector75:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $75
80107707:	6a 4b                	push   $0x4b
  jmp alltraps
80107709:	e9 1a f7 ff ff       	jmp    80106e28 <alltraps>

8010770e <vector76>:
.globl vector76
vector76:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $76
80107710:	6a 4c                	push   $0x4c
  jmp alltraps
80107712:	e9 11 f7 ff ff       	jmp    80106e28 <alltraps>

80107717 <vector77>:
.globl vector77
vector77:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $77
80107719:	6a 4d                	push   $0x4d
  jmp alltraps
8010771b:	e9 08 f7 ff ff       	jmp    80106e28 <alltraps>

80107720 <vector78>:
.globl vector78
vector78:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $78
80107722:	6a 4e                	push   $0x4e
  jmp alltraps
80107724:	e9 ff f6 ff ff       	jmp    80106e28 <alltraps>

80107729 <vector79>:
.globl vector79
vector79:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $79
8010772b:	6a 4f                	push   $0x4f
  jmp alltraps
8010772d:	e9 f6 f6 ff ff       	jmp    80106e28 <alltraps>

80107732 <vector80>:
.globl vector80
vector80:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $80
80107734:	6a 50                	push   $0x50
  jmp alltraps
80107736:	e9 ed f6 ff ff       	jmp    80106e28 <alltraps>

8010773b <vector81>:
.globl vector81
vector81:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $81
8010773d:	6a 51                	push   $0x51
  jmp alltraps
8010773f:	e9 e4 f6 ff ff       	jmp    80106e28 <alltraps>

80107744 <vector82>:
.globl vector82
vector82:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $82
80107746:	6a 52                	push   $0x52
  jmp alltraps
80107748:	e9 db f6 ff ff       	jmp    80106e28 <alltraps>

8010774d <vector83>:
.globl vector83
vector83:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $83
8010774f:	6a 53                	push   $0x53
  jmp alltraps
80107751:	e9 d2 f6 ff ff       	jmp    80106e28 <alltraps>

80107756 <vector84>:
.globl vector84
vector84:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $84
80107758:	6a 54                	push   $0x54
  jmp alltraps
8010775a:	e9 c9 f6 ff ff       	jmp    80106e28 <alltraps>

8010775f <vector85>:
.globl vector85
vector85:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $85
80107761:	6a 55                	push   $0x55
  jmp alltraps
80107763:	e9 c0 f6 ff ff       	jmp    80106e28 <alltraps>

80107768 <vector86>:
.globl vector86
vector86:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $86
8010776a:	6a 56                	push   $0x56
  jmp alltraps
8010776c:	e9 b7 f6 ff ff       	jmp    80106e28 <alltraps>

80107771 <vector87>:
.globl vector87
vector87:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $87
80107773:	6a 57                	push   $0x57
  jmp alltraps
80107775:	e9 ae f6 ff ff       	jmp    80106e28 <alltraps>

8010777a <vector88>:
.globl vector88
vector88:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $88
8010777c:	6a 58                	push   $0x58
  jmp alltraps
8010777e:	e9 a5 f6 ff ff       	jmp    80106e28 <alltraps>

80107783 <vector89>:
.globl vector89
vector89:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $89
80107785:	6a 59                	push   $0x59
  jmp alltraps
80107787:	e9 9c f6 ff ff       	jmp    80106e28 <alltraps>

8010778c <vector90>:
.globl vector90
vector90:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $90
8010778e:	6a 5a                	push   $0x5a
  jmp alltraps
80107790:	e9 93 f6 ff ff       	jmp    80106e28 <alltraps>

80107795 <vector91>:
.globl vector91
vector91:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $91
80107797:	6a 5b                	push   $0x5b
  jmp alltraps
80107799:	e9 8a f6 ff ff       	jmp    80106e28 <alltraps>

8010779e <vector92>:
.globl vector92
vector92:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $92
801077a0:	6a 5c                	push   $0x5c
  jmp alltraps
801077a2:	e9 81 f6 ff ff       	jmp    80106e28 <alltraps>

801077a7 <vector93>:
.globl vector93
vector93:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $93
801077a9:	6a 5d                	push   $0x5d
  jmp alltraps
801077ab:	e9 78 f6 ff ff       	jmp    80106e28 <alltraps>

801077b0 <vector94>:
.globl vector94
vector94:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $94
801077b2:	6a 5e                	push   $0x5e
  jmp alltraps
801077b4:	e9 6f f6 ff ff       	jmp    80106e28 <alltraps>

801077b9 <vector95>:
.globl vector95
vector95:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $95
801077bb:	6a 5f                	push   $0x5f
  jmp alltraps
801077bd:	e9 66 f6 ff ff       	jmp    80106e28 <alltraps>

801077c2 <vector96>:
.globl vector96
vector96:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $96
801077c4:	6a 60                	push   $0x60
  jmp alltraps
801077c6:	e9 5d f6 ff ff       	jmp    80106e28 <alltraps>

801077cb <vector97>:
.globl vector97
vector97:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $97
801077cd:	6a 61                	push   $0x61
  jmp alltraps
801077cf:	e9 54 f6 ff ff       	jmp    80106e28 <alltraps>

801077d4 <vector98>:
.globl vector98
vector98:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $98
801077d6:	6a 62                	push   $0x62
  jmp alltraps
801077d8:	e9 4b f6 ff ff       	jmp    80106e28 <alltraps>

801077dd <vector99>:
.globl vector99
vector99:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $99
801077df:	6a 63                	push   $0x63
  jmp alltraps
801077e1:	e9 42 f6 ff ff       	jmp    80106e28 <alltraps>

801077e6 <vector100>:
.globl vector100
vector100:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $100
801077e8:	6a 64                	push   $0x64
  jmp alltraps
801077ea:	e9 39 f6 ff ff       	jmp    80106e28 <alltraps>

801077ef <vector101>:
.globl vector101
vector101:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $101
801077f1:	6a 65                	push   $0x65
  jmp alltraps
801077f3:	e9 30 f6 ff ff       	jmp    80106e28 <alltraps>

801077f8 <vector102>:
.globl vector102
vector102:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $102
801077fa:	6a 66                	push   $0x66
  jmp alltraps
801077fc:	e9 27 f6 ff ff       	jmp    80106e28 <alltraps>

80107801 <vector103>:
.globl vector103
vector103:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $103
80107803:	6a 67                	push   $0x67
  jmp alltraps
80107805:	e9 1e f6 ff ff       	jmp    80106e28 <alltraps>

8010780a <vector104>:
.globl vector104
vector104:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $104
8010780c:	6a 68                	push   $0x68
  jmp alltraps
8010780e:	e9 15 f6 ff ff       	jmp    80106e28 <alltraps>

80107813 <vector105>:
.globl vector105
vector105:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $105
80107815:	6a 69                	push   $0x69
  jmp alltraps
80107817:	e9 0c f6 ff ff       	jmp    80106e28 <alltraps>

8010781c <vector106>:
.globl vector106
vector106:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $106
8010781e:	6a 6a                	push   $0x6a
  jmp alltraps
80107820:	e9 03 f6 ff ff       	jmp    80106e28 <alltraps>

80107825 <vector107>:
.globl vector107
vector107:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $107
80107827:	6a 6b                	push   $0x6b
  jmp alltraps
80107829:	e9 fa f5 ff ff       	jmp    80106e28 <alltraps>

8010782e <vector108>:
.globl vector108
vector108:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $108
80107830:	6a 6c                	push   $0x6c
  jmp alltraps
80107832:	e9 f1 f5 ff ff       	jmp    80106e28 <alltraps>

80107837 <vector109>:
.globl vector109
vector109:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $109
80107839:	6a 6d                	push   $0x6d
  jmp alltraps
8010783b:	e9 e8 f5 ff ff       	jmp    80106e28 <alltraps>

80107840 <vector110>:
.globl vector110
vector110:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $110
80107842:	6a 6e                	push   $0x6e
  jmp alltraps
80107844:	e9 df f5 ff ff       	jmp    80106e28 <alltraps>

80107849 <vector111>:
.globl vector111
vector111:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $111
8010784b:	6a 6f                	push   $0x6f
  jmp alltraps
8010784d:	e9 d6 f5 ff ff       	jmp    80106e28 <alltraps>

80107852 <vector112>:
.globl vector112
vector112:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $112
80107854:	6a 70                	push   $0x70
  jmp alltraps
80107856:	e9 cd f5 ff ff       	jmp    80106e28 <alltraps>

8010785b <vector113>:
.globl vector113
vector113:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $113
8010785d:	6a 71                	push   $0x71
  jmp alltraps
8010785f:	e9 c4 f5 ff ff       	jmp    80106e28 <alltraps>

80107864 <vector114>:
.globl vector114
vector114:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $114
80107866:	6a 72                	push   $0x72
  jmp alltraps
80107868:	e9 bb f5 ff ff       	jmp    80106e28 <alltraps>

8010786d <vector115>:
.globl vector115
vector115:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $115
8010786f:	6a 73                	push   $0x73
  jmp alltraps
80107871:	e9 b2 f5 ff ff       	jmp    80106e28 <alltraps>

80107876 <vector116>:
.globl vector116
vector116:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $116
80107878:	6a 74                	push   $0x74
  jmp alltraps
8010787a:	e9 a9 f5 ff ff       	jmp    80106e28 <alltraps>

8010787f <vector117>:
.globl vector117
vector117:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $117
80107881:	6a 75                	push   $0x75
  jmp alltraps
80107883:	e9 a0 f5 ff ff       	jmp    80106e28 <alltraps>

80107888 <vector118>:
.globl vector118
vector118:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $118
8010788a:	6a 76                	push   $0x76
  jmp alltraps
8010788c:	e9 97 f5 ff ff       	jmp    80106e28 <alltraps>

80107891 <vector119>:
.globl vector119
vector119:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $119
80107893:	6a 77                	push   $0x77
  jmp alltraps
80107895:	e9 8e f5 ff ff       	jmp    80106e28 <alltraps>

8010789a <vector120>:
.globl vector120
vector120:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $120
8010789c:	6a 78                	push   $0x78
  jmp alltraps
8010789e:	e9 85 f5 ff ff       	jmp    80106e28 <alltraps>

801078a3 <vector121>:
.globl vector121
vector121:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $121
801078a5:	6a 79                	push   $0x79
  jmp alltraps
801078a7:	e9 7c f5 ff ff       	jmp    80106e28 <alltraps>

801078ac <vector122>:
.globl vector122
vector122:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $122
801078ae:	6a 7a                	push   $0x7a
  jmp alltraps
801078b0:	e9 73 f5 ff ff       	jmp    80106e28 <alltraps>

801078b5 <vector123>:
.globl vector123
vector123:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $123
801078b7:	6a 7b                	push   $0x7b
  jmp alltraps
801078b9:	e9 6a f5 ff ff       	jmp    80106e28 <alltraps>

801078be <vector124>:
.globl vector124
vector124:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $124
801078c0:	6a 7c                	push   $0x7c
  jmp alltraps
801078c2:	e9 61 f5 ff ff       	jmp    80106e28 <alltraps>

801078c7 <vector125>:
.globl vector125
vector125:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $125
801078c9:	6a 7d                	push   $0x7d
  jmp alltraps
801078cb:	e9 58 f5 ff ff       	jmp    80106e28 <alltraps>

801078d0 <vector126>:
.globl vector126
vector126:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $126
801078d2:	6a 7e                	push   $0x7e
  jmp alltraps
801078d4:	e9 4f f5 ff ff       	jmp    80106e28 <alltraps>

801078d9 <vector127>:
.globl vector127
vector127:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $127
801078db:	6a 7f                	push   $0x7f
  jmp alltraps
801078dd:	e9 46 f5 ff ff       	jmp    80106e28 <alltraps>

801078e2 <vector128>:
.globl vector128
vector128:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $128
801078e4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801078e9:	e9 3a f5 ff ff       	jmp    80106e28 <alltraps>

801078ee <vector129>:
.globl vector129
vector129:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $129
801078f0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801078f5:	e9 2e f5 ff ff       	jmp    80106e28 <alltraps>

801078fa <vector130>:
.globl vector130
vector130:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $130
801078fc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107901:	e9 22 f5 ff ff       	jmp    80106e28 <alltraps>

80107906 <vector131>:
.globl vector131
vector131:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $131
80107908:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010790d:	e9 16 f5 ff ff       	jmp    80106e28 <alltraps>

80107912 <vector132>:
.globl vector132
vector132:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $132
80107914:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107919:	e9 0a f5 ff ff       	jmp    80106e28 <alltraps>

8010791e <vector133>:
.globl vector133
vector133:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $133
80107920:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107925:	e9 fe f4 ff ff       	jmp    80106e28 <alltraps>

8010792a <vector134>:
.globl vector134
vector134:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $134
8010792c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107931:	e9 f2 f4 ff ff       	jmp    80106e28 <alltraps>

80107936 <vector135>:
.globl vector135
vector135:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $135
80107938:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010793d:	e9 e6 f4 ff ff       	jmp    80106e28 <alltraps>

80107942 <vector136>:
.globl vector136
vector136:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $136
80107944:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107949:	e9 da f4 ff ff       	jmp    80106e28 <alltraps>

8010794e <vector137>:
.globl vector137
vector137:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $137
80107950:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107955:	e9 ce f4 ff ff       	jmp    80106e28 <alltraps>

8010795a <vector138>:
.globl vector138
vector138:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $138
8010795c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107961:	e9 c2 f4 ff ff       	jmp    80106e28 <alltraps>

80107966 <vector139>:
.globl vector139
vector139:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $139
80107968:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010796d:	e9 b6 f4 ff ff       	jmp    80106e28 <alltraps>

80107972 <vector140>:
.globl vector140
vector140:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $140
80107974:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107979:	e9 aa f4 ff ff       	jmp    80106e28 <alltraps>

8010797e <vector141>:
.globl vector141
vector141:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $141
80107980:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107985:	e9 9e f4 ff ff       	jmp    80106e28 <alltraps>

8010798a <vector142>:
.globl vector142
vector142:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $142
8010798c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107991:	e9 92 f4 ff ff       	jmp    80106e28 <alltraps>

80107996 <vector143>:
.globl vector143
vector143:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $143
80107998:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010799d:	e9 86 f4 ff ff       	jmp    80106e28 <alltraps>

801079a2 <vector144>:
.globl vector144
vector144:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $144
801079a4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801079a9:	e9 7a f4 ff ff       	jmp    80106e28 <alltraps>

801079ae <vector145>:
.globl vector145
vector145:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $145
801079b0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801079b5:	e9 6e f4 ff ff       	jmp    80106e28 <alltraps>

801079ba <vector146>:
.globl vector146
vector146:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $146
801079bc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801079c1:	e9 62 f4 ff ff       	jmp    80106e28 <alltraps>

801079c6 <vector147>:
.globl vector147
vector147:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $147
801079c8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801079cd:	e9 56 f4 ff ff       	jmp    80106e28 <alltraps>

801079d2 <vector148>:
.globl vector148
vector148:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $148
801079d4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801079d9:	e9 4a f4 ff ff       	jmp    80106e28 <alltraps>

801079de <vector149>:
.globl vector149
vector149:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $149
801079e0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801079e5:	e9 3e f4 ff ff       	jmp    80106e28 <alltraps>

801079ea <vector150>:
.globl vector150
vector150:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $150
801079ec:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801079f1:	e9 32 f4 ff ff       	jmp    80106e28 <alltraps>

801079f6 <vector151>:
.globl vector151
vector151:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $151
801079f8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801079fd:	e9 26 f4 ff ff       	jmp    80106e28 <alltraps>

80107a02 <vector152>:
.globl vector152
vector152:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $152
80107a04:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107a09:	e9 1a f4 ff ff       	jmp    80106e28 <alltraps>

80107a0e <vector153>:
.globl vector153
vector153:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $153
80107a10:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107a15:	e9 0e f4 ff ff       	jmp    80106e28 <alltraps>

80107a1a <vector154>:
.globl vector154
vector154:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $154
80107a1c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107a21:	e9 02 f4 ff ff       	jmp    80106e28 <alltraps>

80107a26 <vector155>:
.globl vector155
vector155:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $155
80107a28:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107a2d:	e9 f6 f3 ff ff       	jmp    80106e28 <alltraps>

80107a32 <vector156>:
.globl vector156
vector156:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $156
80107a34:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107a39:	e9 ea f3 ff ff       	jmp    80106e28 <alltraps>

80107a3e <vector157>:
.globl vector157
vector157:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $157
80107a40:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107a45:	e9 de f3 ff ff       	jmp    80106e28 <alltraps>

80107a4a <vector158>:
.globl vector158
vector158:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $158
80107a4c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107a51:	e9 d2 f3 ff ff       	jmp    80106e28 <alltraps>

80107a56 <vector159>:
.globl vector159
vector159:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $159
80107a58:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107a5d:	e9 c6 f3 ff ff       	jmp    80106e28 <alltraps>

80107a62 <vector160>:
.globl vector160
vector160:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $160
80107a64:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107a69:	e9 ba f3 ff ff       	jmp    80106e28 <alltraps>

80107a6e <vector161>:
.globl vector161
vector161:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $161
80107a70:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107a75:	e9 ae f3 ff ff       	jmp    80106e28 <alltraps>

80107a7a <vector162>:
.globl vector162
vector162:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $162
80107a7c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107a81:	e9 a2 f3 ff ff       	jmp    80106e28 <alltraps>

80107a86 <vector163>:
.globl vector163
vector163:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $163
80107a88:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107a8d:	e9 96 f3 ff ff       	jmp    80106e28 <alltraps>

80107a92 <vector164>:
.globl vector164
vector164:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $164
80107a94:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107a99:	e9 8a f3 ff ff       	jmp    80106e28 <alltraps>

80107a9e <vector165>:
.globl vector165
vector165:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $165
80107aa0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107aa5:	e9 7e f3 ff ff       	jmp    80106e28 <alltraps>

80107aaa <vector166>:
.globl vector166
vector166:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $166
80107aac:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ab1:	e9 72 f3 ff ff       	jmp    80106e28 <alltraps>

80107ab6 <vector167>:
.globl vector167
vector167:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $167
80107ab8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107abd:	e9 66 f3 ff ff       	jmp    80106e28 <alltraps>

80107ac2 <vector168>:
.globl vector168
vector168:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $168
80107ac4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107ac9:	e9 5a f3 ff ff       	jmp    80106e28 <alltraps>

80107ace <vector169>:
.globl vector169
vector169:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $169
80107ad0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107ad5:	e9 4e f3 ff ff       	jmp    80106e28 <alltraps>

80107ada <vector170>:
.globl vector170
vector170:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $170
80107adc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107ae1:	e9 42 f3 ff ff       	jmp    80106e28 <alltraps>

80107ae6 <vector171>:
.globl vector171
vector171:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $171
80107ae8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107aed:	e9 36 f3 ff ff       	jmp    80106e28 <alltraps>

80107af2 <vector172>:
.globl vector172
vector172:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $172
80107af4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107af9:	e9 2a f3 ff ff       	jmp    80106e28 <alltraps>

80107afe <vector173>:
.globl vector173
vector173:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $173
80107b00:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107b05:	e9 1e f3 ff ff       	jmp    80106e28 <alltraps>

80107b0a <vector174>:
.globl vector174
vector174:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $174
80107b0c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107b11:	e9 12 f3 ff ff       	jmp    80106e28 <alltraps>

80107b16 <vector175>:
.globl vector175
vector175:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $175
80107b18:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107b1d:	e9 06 f3 ff ff       	jmp    80106e28 <alltraps>

80107b22 <vector176>:
.globl vector176
vector176:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $176
80107b24:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107b29:	e9 fa f2 ff ff       	jmp    80106e28 <alltraps>

80107b2e <vector177>:
.globl vector177
vector177:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $177
80107b30:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107b35:	e9 ee f2 ff ff       	jmp    80106e28 <alltraps>

80107b3a <vector178>:
.globl vector178
vector178:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $178
80107b3c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107b41:	e9 e2 f2 ff ff       	jmp    80106e28 <alltraps>

80107b46 <vector179>:
.globl vector179
vector179:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $179
80107b48:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107b4d:	e9 d6 f2 ff ff       	jmp    80106e28 <alltraps>

80107b52 <vector180>:
.globl vector180
vector180:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $180
80107b54:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107b59:	e9 ca f2 ff ff       	jmp    80106e28 <alltraps>

80107b5e <vector181>:
.globl vector181
vector181:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $181
80107b60:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107b65:	e9 be f2 ff ff       	jmp    80106e28 <alltraps>

80107b6a <vector182>:
.globl vector182
vector182:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $182
80107b6c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107b71:	e9 b2 f2 ff ff       	jmp    80106e28 <alltraps>

80107b76 <vector183>:
.globl vector183
vector183:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $183
80107b78:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107b7d:	e9 a6 f2 ff ff       	jmp    80106e28 <alltraps>

80107b82 <vector184>:
.globl vector184
vector184:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $184
80107b84:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107b89:	e9 9a f2 ff ff       	jmp    80106e28 <alltraps>

80107b8e <vector185>:
.globl vector185
vector185:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $185
80107b90:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107b95:	e9 8e f2 ff ff       	jmp    80106e28 <alltraps>

80107b9a <vector186>:
.globl vector186
vector186:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $186
80107b9c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107ba1:	e9 82 f2 ff ff       	jmp    80106e28 <alltraps>

80107ba6 <vector187>:
.globl vector187
vector187:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $187
80107ba8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107bad:	e9 76 f2 ff ff       	jmp    80106e28 <alltraps>

80107bb2 <vector188>:
.globl vector188
vector188:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $188
80107bb4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107bb9:	e9 6a f2 ff ff       	jmp    80106e28 <alltraps>

80107bbe <vector189>:
.globl vector189
vector189:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $189
80107bc0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107bc5:	e9 5e f2 ff ff       	jmp    80106e28 <alltraps>

80107bca <vector190>:
.globl vector190
vector190:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $190
80107bcc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107bd1:	e9 52 f2 ff ff       	jmp    80106e28 <alltraps>

80107bd6 <vector191>:
.globl vector191
vector191:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $191
80107bd8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107bdd:	e9 46 f2 ff ff       	jmp    80106e28 <alltraps>

80107be2 <vector192>:
.globl vector192
vector192:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $192
80107be4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107be9:	e9 3a f2 ff ff       	jmp    80106e28 <alltraps>

80107bee <vector193>:
.globl vector193
vector193:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $193
80107bf0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107bf5:	e9 2e f2 ff ff       	jmp    80106e28 <alltraps>

80107bfa <vector194>:
.globl vector194
vector194:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $194
80107bfc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107c01:	e9 22 f2 ff ff       	jmp    80106e28 <alltraps>

80107c06 <vector195>:
.globl vector195
vector195:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $195
80107c08:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107c0d:	e9 16 f2 ff ff       	jmp    80106e28 <alltraps>

80107c12 <vector196>:
.globl vector196
vector196:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $196
80107c14:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107c19:	e9 0a f2 ff ff       	jmp    80106e28 <alltraps>

80107c1e <vector197>:
.globl vector197
vector197:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $197
80107c20:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107c25:	e9 fe f1 ff ff       	jmp    80106e28 <alltraps>

80107c2a <vector198>:
.globl vector198
vector198:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $198
80107c2c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107c31:	e9 f2 f1 ff ff       	jmp    80106e28 <alltraps>

80107c36 <vector199>:
.globl vector199
vector199:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $199
80107c38:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107c3d:	e9 e6 f1 ff ff       	jmp    80106e28 <alltraps>

80107c42 <vector200>:
.globl vector200
vector200:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $200
80107c44:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107c49:	e9 da f1 ff ff       	jmp    80106e28 <alltraps>

80107c4e <vector201>:
.globl vector201
vector201:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $201
80107c50:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107c55:	e9 ce f1 ff ff       	jmp    80106e28 <alltraps>

80107c5a <vector202>:
.globl vector202
vector202:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $202
80107c5c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107c61:	e9 c2 f1 ff ff       	jmp    80106e28 <alltraps>

80107c66 <vector203>:
.globl vector203
vector203:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $203
80107c68:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107c6d:	e9 b6 f1 ff ff       	jmp    80106e28 <alltraps>

80107c72 <vector204>:
.globl vector204
vector204:
  pushl $0
80107c72:	6a 00                	push   $0x0
  pushl $204
80107c74:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107c79:	e9 aa f1 ff ff       	jmp    80106e28 <alltraps>

80107c7e <vector205>:
.globl vector205
vector205:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $205
80107c80:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107c85:	e9 9e f1 ff ff       	jmp    80106e28 <alltraps>

80107c8a <vector206>:
.globl vector206
vector206:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $206
80107c8c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107c91:	e9 92 f1 ff ff       	jmp    80106e28 <alltraps>

80107c96 <vector207>:
.globl vector207
vector207:
  pushl $0
80107c96:	6a 00                	push   $0x0
  pushl $207
80107c98:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107c9d:	e9 86 f1 ff ff       	jmp    80106e28 <alltraps>

80107ca2 <vector208>:
.globl vector208
vector208:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $208
80107ca4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107ca9:	e9 7a f1 ff ff       	jmp    80106e28 <alltraps>

80107cae <vector209>:
.globl vector209
vector209:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $209
80107cb0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107cb5:	e9 6e f1 ff ff       	jmp    80106e28 <alltraps>

80107cba <vector210>:
.globl vector210
vector210:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $210
80107cbc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107cc1:	e9 62 f1 ff ff       	jmp    80106e28 <alltraps>

80107cc6 <vector211>:
.globl vector211
vector211:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $211
80107cc8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107ccd:	e9 56 f1 ff ff       	jmp    80106e28 <alltraps>

80107cd2 <vector212>:
.globl vector212
vector212:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $212
80107cd4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107cd9:	e9 4a f1 ff ff       	jmp    80106e28 <alltraps>

80107cde <vector213>:
.globl vector213
vector213:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $213
80107ce0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107ce5:	e9 3e f1 ff ff       	jmp    80106e28 <alltraps>

80107cea <vector214>:
.globl vector214
vector214:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $214
80107cec:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107cf1:	e9 32 f1 ff ff       	jmp    80106e28 <alltraps>

80107cf6 <vector215>:
.globl vector215
vector215:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $215
80107cf8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107cfd:	e9 26 f1 ff ff       	jmp    80106e28 <alltraps>

80107d02 <vector216>:
.globl vector216
vector216:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $216
80107d04:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107d09:	e9 1a f1 ff ff       	jmp    80106e28 <alltraps>

80107d0e <vector217>:
.globl vector217
vector217:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $217
80107d10:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107d15:	e9 0e f1 ff ff       	jmp    80106e28 <alltraps>

80107d1a <vector218>:
.globl vector218
vector218:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $218
80107d1c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107d21:	e9 02 f1 ff ff       	jmp    80106e28 <alltraps>

80107d26 <vector219>:
.globl vector219
vector219:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $219
80107d28:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107d2d:	e9 f6 f0 ff ff       	jmp    80106e28 <alltraps>

80107d32 <vector220>:
.globl vector220
vector220:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $220
80107d34:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107d39:	e9 ea f0 ff ff       	jmp    80106e28 <alltraps>

80107d3e <vector221>:
.globl vector221
vector221:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $221
80107d40:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107d45:	e9 de f0 ff ff       	jmp    80106e28 <alltraps>

80107d4a <vector222>:
.globl vector222
vector222:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $222
80107d4c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107d51:	e9 d2 f0 ff ff       	jmp    80106e28 <alltraps>

80107d56 <vector223>:
.globl vector223
vector223:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $223
80107d58:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107d5d:	e9 c6 f0 ff ff       	jmp    80106e28 <alltraps>

80107d62 <vector224>:
.globl vector224
vector224:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $224
80107d64:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107d69:	e9 ba f0 ff ff       	jmp    80106e28 <alltraps>

80107d6e <vector225>:
.globl vector225
vector225:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $225
80107d70:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107d75:	e9 ae f0 ff ff       	jmp    80106e28 <alltraps>

80107d7a <vector226>:
.globl vector226
vector226:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $226
80107d7c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107d81:	e9 a2 f0 ff ff       	jmp    80106e28 <alltraps>

80107d86 <vector227>:
.globl vector227
vector227:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $227
80107d88:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107d8d:	e9 96 f0 ff ff       	jmp    80106e28 <alltraps>

80107d92 <vector228>:
.globl vector228
vector228:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $228
80107d94:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107d99:	e9 8a f0 ff ff       	jmp    80106e28 <alltraps>

80107d9e <vector229>:
.globl vector229
vector229:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $229
80107da0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107da5:	e9 7e f0 ff ff       	jmp    80106e28 <alltraps>

80107daa <vector230>:
.globl vector230
vector230:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $230
80107dac:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107db1:	e9 72 f0 ff ff       	jmp    80106e28 <alltraps>

80107db6 <vector231>:
.globl vector231
vector231:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $231
80107db8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107dbd:	e9 66 f0 ff ff       	jmp    80106e28 <alltraps>

80107dc2 <vector232>:
.globl vector232
vector232:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $232
80107dc4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107dc9:	e9 5a f0 ff ff       	jmp    80106e28 <alltraps>

80107dce <vector233>:
.globl vector233
vector233:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $233
80107dd0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107dd5:	e9 4e f0 ff ff       	jmp    80106e28 <alltraps>

80107dda <vector234>:
.globl vector234
vector234:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $234
80107ddc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107de1:	e9 42 f0 ff ff       	jmp    80106e28 <alltraps>

80107de6 <vector235>:
.globl vector235
vector235:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $235
80107de8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ded:	e9 36 f0 ff ff       	jmp    80106e28 <alltraps>

80107df2 <vector236>:
.globl vector236
vector236:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $236
80107df4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107df9:	e9 2a f0 ff ff       	jmp    80106e28 <alltraps>

80107dfe <vector237>:
.globl vector237
vector237:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $237
80107e00:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107e05:	e9 1e f0 ff ff       	jmp    80106e28 <alltraps>

80107e0a <vector238>:
.globl vector238
vector238:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $238
80107e0c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107e11:	e9 12 f0 ff ff       	jmp    80106e28 <alltraps>

80107e16 <vector239>:
.globl vector239
vector239:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $239
80107e18:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107e1d:	e9 06 f0 ff ff       	jmp    80106e28 <alltraps>

80107e22 <vector240>:
.globl vector240
vector240:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $240
80107e24:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107e29:	e9 fa ef ff ff       	jmp    80106e28 <alltraps>

80107e2e <vector241>:
.globl vector241
vector241:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $241
80107e30:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107e35:	e9 ee ef ff ff       	jmp    80106e28 <alltraps>

80107e3a <vector242>:
.globl vector242
vector242:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $242
80107e3c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107e41:	e9 e2 ef ff ff       	jmp    80106e28 <alltraps>

80107e46 <vector243>:
.globl vector243
vector243:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $243
80107e48:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107e4d:	e9 d6 ef ff ff       	jmp    80106e28 <alltraps>

80107e52 <vector244>:
.globl vector244
vector244:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $244
80107e54:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107e59:	e9 ca ef ff ff       	jmp    80106e28 <alltraps>

80107e5e <vector245>:
.globl vector245
vector245:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $245
80107e60:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107e65:	e9 be ef ff ff       	jmp    80106e28 <alltraps>

80107e6a <vector246>:
.globl vector246
vector246:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $246
80107e6c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107e71:	e9 b2 ef ff ff       	jmp    80106e28 <alltraps>

80107e76 <vector247>:
.globl vector247
vector247:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $247
80107e78:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107e7d:	e9 a6 ef ff ff       	jmp    80106e28 <alltraps>

80107e82 <vector248>:
.globl vector248
vector248:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $248
80107e84:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107e89:	e9 9a ef ff ff       	jmp    80106e28 <alltraps>

80107e8e <vector249>:
.globl vector249
vector249:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $249
80107e90:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107e95:	e9 8e ef ff ff       	jmp    80106e28 <alltraps>

80107e9a <vector250>:
.globl vector250
vector250:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $250
80107e9c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ea1:	e9 82 ef ff ff       	jmp    80106e28 <alltraps>

80107ea6 <vector251>:
.globl vector251
vector251:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $251
80107ea8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ead:	e9 76 ef ff ff       	jmp    80106e28 <alltraps>

80107eb2 <vector252>:
.globl vector252
vector252:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $252
80107eb4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107eb9:	e9 6a ef ff ff       	jmp    80106e28 <alltraps>

80107ebe <vector253>:
.globl vector253
vector253:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $253
80107ec0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107ec5:	e9 5e ef ff ff       	jmp    80106e28 <alltraps>

80107eca <vector254>:
.globl vector254
vector254:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $254
80107ecc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107ed1:	e9 52 ef ff ff       	jmp    80106e28 <alltraps>

80107ed6 <vector255>:
.globl vector255
vector255:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $255
80107ed8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107edd:	e9 46 ef ff ff       	jmp    80106e28 <alltraps>
	...

80107ee4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107ee4:	55                   	push   %ebp
80107ee5:	89 e5                	mov    %esp,%ebp
80107ee7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eed:	48                   	dec    %eax
80107eee:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80107efc:	c1 e8 10             	shr    $0x10,%eax
80107eff:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107f03:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107f06:	0f 01 10             	lgdtl  (%eax)
}
80107f09:	c9                   	leave  
80107f0a:	c3                   	ret    

80107f0b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107f0b:	55                   	push   %ebp
80107f0c:	89 e5                	mov    %esp,%ebp
80107f0e:	83 ec 04             	sub    $0x4,%esp
80107f11:	8b 45 08             	mov    0x8(%ebp),%eax
80107f14:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107f18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f1b:	0f 00 d8             	ltr    %ax
}
80107f1e:	c9                   	leave  
80107f1f:	c3                   	ret    

80107f20 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107f20:	55                   	push   %ebp
80107f21:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107f23:	8b 45 08             	mov    0x8(%ebp),%eax
80107f26:	0f 22 d8             	mov    %eax,%cr3
}
80107f29:	5d                   	pop    %ebp
80107f2a:	c3                   	ret    

80107f2b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107f2b:	55                   	push   %ebp
80107f2c:	89 e5                	mov    %esp,%ebp
80107f2e:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107f31:	e8 a4 c3 ff ff       	call   801042da <cpuid>
80107f36:	89 c2                	mov    %eax,%edx
80107f38:	89 d0                	mov    %edx,%eax
80107f3a:	c1 e0 02             	shl    $0x2,%eax
80107f3d:	01 d0                	add    %edx,%eax
80107f3f:	01 c0                	add    %eax,%eax
80107f41:	01 d0                	add    %edx,%eax
80107f43:	c1 e0 04             	shl    $0x4,%eax
80107f46:	05 80 4c 11 80       	add    $0x80114c80,%eax
80107f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f51:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f63:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	8a 50 7d             	mov    0x7d(%eax),%dl
80107f6d:	83 e2 f0             	and    $0xfffffff0,%edx
80107f70:	83 ca 0a             	or     $0xa,%edx
80107f73:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f79:	8a 50 7d             	mov    0x7d(%eax),%dl
80107f7c:	83 ca 10             	or     $0x10,%edx
80107f7f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f85:	8a 50 7d             	mov    0x7d(%eax),%dl
80107f88:	83 e2 9f             	and    $0xffffff9f,%edx
80107f8b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f91:	8a 50 7d             	mov    0x7d(%eax),%dl
80107f94:	83 ca 80             	or     $0xffffff80,%edx
80107f97:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fa0:	83 ca 0f             	or     $0xf,%edx
80107fa3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fac:	83 e2 ef             	and    $0xffffffef,%edx
80107faf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb5:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fb8:	83 e2 df             	and    $0xffffffdf,%edx
80107fbb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc1:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fc4:	83 ca 40             	or     $0x40,%edx
80107fc7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcd:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fd0:	83 ca 80             	or     $0xffffff80,%edx
80107fd3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107fe7:	ff ff 
80107fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fec:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ff3:	00 00 
80107ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108002:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108008:	83 e2 f0             	and    $0xfffffff0,%edx
8010800b:	83 ca 02             	or     $0x2,%edx
8010800e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108017:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010801d:	83 ca 10             	or     $0x10,%edx
80108020:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108029:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010802f:	83 e2 9f             	and    $0xffffff9f,%edx
80108032:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108041:	83 ca 80             	or     $0xffffff80,%edx
80108044:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108053:	83 ca 0f             	or     $0xf,%edx
80108056:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010805c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108065:	83 e2 ef             	and    $0xffffffef,%edx
80108068:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010806e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108071:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108077:	83 e2 df             	and    $0xffffffdf,%edx
8010807a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108089:	83 ca 40             	or     $0x40,%edx
8010808c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108095:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010809b:	83 ca 80             	or     $0xffffff80,%edx
8010809e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801080ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801080b8:	ff ff 
801080ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801080c4:	00 00 
801080c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c9:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801080d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d3:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801080d9:	83 e2 f0             	and    $0xfffffff0,%edx
801080dc:	83 ca 0a             	or     $0xa,%edx
801080df:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801080e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801080ee:	83 ca 10             	or     $0x10,%edx
801080f1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801080f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fa:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108100:	83 ca 60             	or     $0x60,%edx
80108103:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810c:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108112:	83 ca 80             	or     $0xffffff80,%edx
80108115:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010811b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108124:	83 ca 0f             	or     $0xf,%edx
80108127:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010812d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108130:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108136:	83 e2 ef             	and    $0xffffffef,%edx
80108139:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108142:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108148:	83 e2 df             	and    $0xffffffdf,%edx
8010814b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108154:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010815a:	83 ca 40             	or     $0x40,%edx
8010815d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108166:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010816c:	83 ca 80             	or     $0xffffff80,%edx
8010816f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108178:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108182:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108189:	ff ff 
8010818b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108195:	00 00 
80108197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801081a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a4:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081aa:	83 e2 f0             	and    $0xfffffff0,%edx
801081ad:	83 ca 02             	or     $0x2,%edx
801081b0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081bf:	83 ca 10             	or     $0x10,%edx
801081c2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081cb:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081d1:	83 ca 60             	or     $0x60,%edx
801081d4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081e3:	83 ca 80             	or     $0xffffff80,%edx
801081e6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ef:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801081f5:	83 ca 0f             	or     $0xf,%edx
801081f8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801081fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108201:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108207:	83 e2 ef             	and    $0xffffffef,%edx
8010820a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108213:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108219:	83 e2 df             	and    $0xffffffdf,%edx
8010821c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108225:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010822b:	83 ca 40             	or     $0x40,%edx
8010822e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108237:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010823d:	83 ca 80             	or     $0xffffff80,%edx
80108240:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108249:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108253:	83 c0 70             	add    $0x70,%eax
80108256:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010825d:	00 
8010825e:	89 04 24             	mov    %eax,(%esp)
80108261:	e8 7e fc ff ff       	call   80107ee4 <lgdt>
}
80108266:	c9                   	leave  
80108267:	c3                   	ret    

80108268 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108268:	55                   	push   %ebp
80108269:	89 e5                	mov    %esp,%ebp
8010826b:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010826e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108271:	c1 e8 16             	shr    $0x16,%eax
80108274:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010827b:	8b 45 08             	mov    0x8(%ebp),%eax
8010827e:	01 d0                	add    %edx,%eax
80108280:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108283:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108286:	8b 00                	mov    (%eax),%eax
80108288:	83 e0 01             	and    $0x1,%eax
8010828b:	85 c0                	test   %eax,%eax
8010828d:	74 14                	je     801082a3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010828f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108292:	8b 00                	mov    (%eax),%eax
80108294:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108299:	05 00 00 00 80       	add    $0x80000000,%eax
8010829e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082a1:	eb 48                	jmp    801082eb <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801082a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801082a7:	74 0e                	je     801082b7 <walkpgdir+0x4f>
801082a9:	e8 e9 aa ff ff       	call   80102d97 <kalloc>
801082ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082b5:	75 07                	jne    801082be <walkpgdir+0x56>
      return 0;
801082b7:	b8 00 00 00 00       	mov    $0x0,%eax
801082bc:	eb 44                	jmp    80108302 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801082be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082c5:	00 
801082c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082cd:	00 
801082ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d1:	89 04 24             	mov    %eax,(%esp)
801082d4:	e8 19 d2 ff ff       	call   801054f2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801082d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082dc:	05 00 00 00 80       	add    $0x80000000,%eax
801082e1:	83 c8 07             	or     $0x7,%eax
801082e4:	89 c2                	mov    %eax,%edx
801082e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e9:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801082eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ee:	c1 e8 0c             	shr    $0xc,%eax
801082f1:	25 ff 03 00 00       	and    $0x3ff,%eax
801082f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108300:	01 d0                	add    %edx,%eax
}
80108302:	c9                   	leave  
80108303:	c3                   	ret    

80108304 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108304:	55                   	push   %ebp
80108305:	89 e5                	mov    %esp,%ebp
80108307:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010830a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108312:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108315:	8b 55 0c             	mov    0xc(%ebp),%edx
80108318:	8b 45 10             	mov    0x10(%ebp),%eax
8010831b:	01 d0                	add    %edx,%eax
8010831d:	48                   	dec    %eax
8010831e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108326:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010832d:	00 
8010832e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108331:	89 44 24 04          	mov    %eax,0x4(%esp)
80108335:	8b 45 08             	mov    0x8(%ebp),%eax
80108338:	89 04 24             	mov    %eax,(%esp)
8010833b:	e8 28 ff ff ff       	call   80108268 <walkpgdir>
80108340:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108343:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108347:	75 07                	jne    80108350 <mappages+0x4c>
      return -1;
80108349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010834e:	eb 48                	jmp    80108398 <mappages+0x94>
    if(*pte & PTE_P)
80108350:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108353:	8b 00                	mov    (%eax),%eax
80108355:	83 e0 01             	and    $0x1,%eax
80108358:	85 c0                	test   %eax,%eax
8010835a:	74 0c                	je     80108368 <mappages+0x64>
      panic("remap");
8010835c:	c7 04 24 fc 99 10 80 	movl   $0x801099fc,(%esp)
80108363:	e8 ec 81 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108368:	8b 45 18             	mov    0x18(%ebp),%eax
8010836b:	0b 45 14             	or     0x14(%ebp),%eax
8010836e:	83 c8 01             	or     $0x1,%eax
80108371:	89 c2                	mov    %eax,%edx
80108373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108376:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010837e:	75 08                	jne    80108388 <mappages+0x84>
      break;
80108380:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108381:	b8 00 00 00 00       	mov    $0x0,%eax
80108386:	eb 10                	jmp    80108398 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108388:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010838f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108396:	eb 8e                	jmp    80108326 <mappages+0x22>
  return 0;
}
80108398:	c9                   	leave  
80108399:	c3                   	ret    

8010839a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010839a:	55                   	push   %ebp
8010839b:	89 e5                	mov    %esp,%ebp
8010839d:	53                   	push   %ebx
8010839e:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801083a1:	e8 f1 a9 ff ff       	call   80102d97 <kalloc>
801083a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083ad:	75 0a                	jne    801083b9 <setupkvm+0x1f>
    return 0;
801083af:	b8 00 00 00 00       	mov    $0x0,%eax
801083b4:	e9 84 00 00 00       	jmp    8010843d <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801083b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083c0:	00 
801083c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083c8:	00 
801083c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083cc:	89 04 24             	mov    %eax,(%esp)
801083cf:	e8 1e d1 ff ff       	call   801054f2 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801083d4:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
801083db:	eb 54                	jmp    80108431 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801083dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e0:	8b 48 0c             	mov    0xc(%eax),%ecx
801083e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e6:	8b 50 04             	mov    0x4(%eax),%edx
801083e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ec:	8b 58 08             	mov    0x8(%eax),%ebx
801083ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f2:	8b 40 04             	mov    0x4(%eax),%eax
801083f5:	29 c3                	sub    %eax,%ebx
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	8b 00                	mov    (%eax),%eax
801083fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108400:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108404:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108408:	89 44 24 04          	mov    %eax,0x4(%esp)
8010840c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010840f:	89 04 24             	mov    %eax,(%esp)
80108412:	e8 ed fe ff ff       	call   80108304 <mappages>
80108417:	85 c0                	test   %eax,%eax
80108419:	79 12                	jns    8010842d <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010841b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010841e:	89 04 24             	mov    %eax,(%esp)
80108421:	e8 1a 05 00 00       	call   80108940 <freevm>
      return 0;
80108426:	b8 00 00 00 00       	mov    $0x0,%eax
8010842b:	eb 10                	jmp    8010843d <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010842d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108431:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
80108438:	72 a3                	jb     801083dd <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010843a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010843d:	83 c4 34             	add    $0x34,%esp
80108440:	5b                   	pop    %ebx
80108441:	5d                   	pop    %ebp
80108442:	c3                   	ret    

80108443 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108443:	55                   	push   %ebp
80108444:	89 e5                	mov    %esp,%ebp
80108446:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108449:	e8 4c ff ff ff       	call   8010839a <setupkvm>
8010844e:	a3 a4 7b 11 80       	mov    %eax,0x80117ba4
  switchkvm();
80108453:	e8 02 00 00 00       	call   8010845a <switchkvm>
}
80108458:	c9                   	leave  
80108459:	c3                   	ret    

8010845a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010845a:	55                   	push   %ebp
8010845b:	89 e5                	mov    %esp,%ebp
8010845d:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108460:	a1 a4 7b 11 80       	mov    0x80117ba4,%eax
80108465:	05 00 00 00 80       	add    $0x80000000,%eax
8010846a:	89 04 24             	mov    %eax,(%esp)
8010846d:	e8 ae fa ff ff       	call   80107f20 <lcr3>
}
80108472:	c9                   	leave  
80108473:	c3                   	ret    

80108474 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108474:	55                   	push   %ebp
80108475:	89 e5                	mov    %esp,%ebp
80108477:	57                   	push   %edi
80108478:	56                   	push   %esi
80108479:	53                   	push   %ebx
8010847a:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
8010847d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108481:	75 0c                	jne    8010848f <switchuvm+0x1b>
    panic("switchuvm: no process");
80108483:	c7 04 24 02 9a 10 80 	movl   $0x80109a02,(%esp)
8010848a:	e8 c5 80 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
8010848f:	8b 45 08             	mov    0x8(%ebp),%eax
80108492:	8b 40 08             	mov    0x8(%eax),%eax
80108495:	85 c0                	test   %eax,%eax
80108497:	75 0c                	jne    801084a5 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108499:	c7 04 24 18 9a 10 80 	movl   $0x80109a18,(%esp)
801084a0:	e8 af 80 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801084a5:	8b 45 08             	mov    0x8(%ebp),%eax
801084a8:	8b 40 04             	mov    0x4(%eax),%eax
801084ab:	85 c0                	test   %eax,%eax
801084ad:	75 0c                	jne    801084bb <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801084af:	c7 04 24 2d 9a 10 80 	movl   $0x80109a2d,(%esp)
801084b6:	e8 99 80 ff ff       	call   80100554 <panic>

  pushcli();
801084bb:	e8 2e cf ff ff       	call   801053ee <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801084c0:	e8 5a be ff ff       	call   8010431f <mycpu>
801084c5:	89 c3                	mov    %eax,%ebx
801084c7:	e8 53 be ff ff       	call   8010431f <mycpu>
801084cc:	83 c0 08             	add    $0x8,%eax
801084cf:	89 c6                	mov    %eax,%esi
801084d1:	e8 49 be ff ff       	call   8010431f <mycpu>
801084d6:	83 c0 08             	add    $0x8,%eax
801084d9:	c1 e8 10             	shr    $0x10,%eax
801084dc:	89 c7                	mov    %eax,%edi
801084de:	e8 3c be ff ff       	call   8010431f <mycpu>
801084e3:	83 c0 08             	add    $0x8,%eax
801084e6:	c1 e8 18             	shr    $0x18,%eax
801084e9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801084f0:	67 00 
801084f2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801084f9:	89 f9                	mov    %edi,%ecx
801084fb:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108501:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108507:	83 e2 f0             	and    $0xfffffff0,%edx
8010850a:	83 ca 09             	or     $0x9,%edx
8010850d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108513:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108519:	83 ca 10             	or     $0x10,%edx
8010851c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108522:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108528:	83 e2 9f             	and    $0xffffff9f,%edx
8010852b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108531:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108537:	83 ca 80             	or     $0xffffff80,%edx
8010853a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108540:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108546:	83 e2 f0             	and    $0xfffffff0,%edx
80108549:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010854f:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108555:	83 e2 ef             	and    $0xffffffef,%edx
80108558:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010855e:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108564:	83 e2 df             	and    $0xffffffdf,%edx
80108567:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010856d:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108573:	83 ca 40             	or     $0x40,%edx
80108576:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010857c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108582:	83 e2 7f             	and    $0x7f,%edx
80108585:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010858b:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108591:	e8 89 bd ff ff       	call   8010431f <mycpu>
80108596:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
8010859c:	83 e2 ef             	and    $0xffffffef,%edx
8010859f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801085a5:	e8 75 bd ff ff       	call   8010431f <mycpu>
801085aa:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801085b0:	e8 6a bd ff ff       	call   8010431f <mycpu>
801085b5:	8b 55 08             	mov    0x8(%ebp),%edx
801085b8:	8b 52 08             	mov    0x8(%edx),%edx
801085bb:	81 c2 00 10 00 00    	add    $0x1000,%edx
801085c1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801085c4:	e8 56 bd ff ff       	call   8010431f <mycpu>
801085c9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801085cf:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
801085d6:	e8 30 f9 ff ff       	call   80107f0b <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801085db:	8b 45 08             	mov    0x8(%ebp),%eax
801085de:	8b 40 04             	mov    0x4(%eax),%eax
801085e1:	05 00 00 00 80       	add    $0x80000000,%eax
801085e6:	89 04 24             	mov    %eax,(%esp)
801085e9:	e8 32 f9 ff ff       	call   80107f20 <lcr3>
  popcli();
801085ee:	e8 45 ce ff ff       	call   80105438 <popcli>
}
801085f3:	83 c4 1c             	add    $0x1c,%esp
801085f6:	5b                   	pop    %ebx
801085f7:	5e                   	pop    %esi
801085f8:	5f                   	pop    %edi
801085f9:	5d                   	pop    %ebp
801085fa:	c3                   	ret    

801085fb <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801085fb:	55                   	push   %ebp
801085fc:	89 e5                	mov    %esp,%ebp
801085fe:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108601:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108608:	76 0c                	jbe    80108616 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010860a:	c7 04 24 41 9a 10 80 	movl   $0x80109a41,(%esp)
80108611:	e8 3e 7f ff ff       	call   80100554 <panic>
  mem = kalloc();
80108616:	e8 7c a7 ff ff       	call   80102d97 <kalloc>
8010861b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010861e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108625:	00 
80108626:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010862d:	00 
8010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108631:	89 04 24             	mov    %eax,(%esp)
80108634:	e8 b9 ce ff ff       	call   801054f2 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863c:	05 00 00 00 80       	add    $0x80000000,%eax
80108641:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108648:	00 
80108649:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010864d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108654:	00 
80108655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010865c:	00 
8010865d:	8b 45 08             	mov    0x8(%ebp),%eax
80108660:	89 04 24             	mov    %eax,(%esp)
80108663:	e8 9c fc ff ff       	call   80108304 <mappages>
  memmove(mem, init, sz);
80108668:	8b 45 10             	mov    0x10(%ebp),%eax
8010866b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010866f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108672:	89 44 24 04          	mov    %eax,0x4(%esp)
80108676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108679:	89 04 24             	mov    %eax,(%esp)
8010867c:	e8 3a cf ff ff       	call   801055bb <memmove>
}
80108681:	c9                   	leave  
80108682:	c3                   	ret    

80108683 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108683:	55                   	push   %ebp
80108684:	89 e5                	mov    %esp,%ebp
80108686:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108689:	8b 45 0c             	mov    0xc(%ebp),%eax
8010868c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108691:	85 c0                	test   %eax,%eax
80108693:	74 0c                	je     801086a1 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108695:	c7 04 24 5c 9a 10 80 	movl   $0x80109a5c,(%esp)
8010869c:	e8 b3 7e ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801086a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a8:	e9 a6 00 00 00       	jmp    80108753 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801086ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801086b3:	01 d0                	add    %edx,%eax
801086b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086bc:	00 
801086bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801086c1:	8b 45 08             	mov    0x8(%ebp),%eax
801086c4:	89 04 24             	mov    %eax,(%esp)
801086c7:	e8 9c fb ff ff       	call   80108268 <walkpgdir>
801086cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086d3:	75 0c                	jne    801086e1 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801086d5:	c7 04 24 7f 9a 10 80 	movl   $0x80109a7f,(%esp)
801086dc:	e8 73 7e ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801086e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e4:	8b 00                	mov    (%eax),%eax
801086e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801086ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f1:	8b 55 18             	mov    0x18(%ebp),%edx
801086f4:	29 c2                	sub    %eax,%edx
801086f6:	89 d0                	mov    %edx,%eax
801086f8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801086fd:	77 0f                	ja     8010870e <loaduvm+0x8b>
      n = sz - i;
801086ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108702:	8b 55 18             	mov    0x18(%ebp),%edx
80108705:	29 c2                	sub    %eax,%edx
80108707:	89 d0                	mov    %edx,%eax
80108709:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010870c:	eb 07                	jmp    80108715 <loaduvm+0x92>
    else
      n = PGSIZE;
8010870e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	8b 55 14             	mov    0x14(%ebp),%edx
8010871b:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010871e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108721:	05 00 00 00 80       	add    $0x80000000,%eax
80108726:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108729:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010872d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108731:	89 44 24 04          	mov    %eax,0x4(%esp)
80108735:	8b 45 10             	mov    0x10(%ebp),%eax
80108738:	89 04 24             	mov    %eax,(%esp)
8010873b:	e8 19 98 ff ff       	call   80101f59 <readi>
80108740:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108743:	74 07                	je     8010874c <loaduvm+0xc9>
      return -1;
80108745:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010874a:	eb 18                	jmp    80108764 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010874c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108756:	3b 45 18             	cmp    0x18(%ebp),%eax
80108759:	0f 82 4e ff ff ff    	jb     801086ad <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010875f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108764:	c9                   	leave  
80108765:	c3                   	ret    

80108766 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108766:	55                   	push   %ebp
80108767:	89 e5                	mov    %esp,%ebp
80108769:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010876c:	8b 45 10             	mov    0x10(%ebp),%eax
8010876f:	85 c0                	test   %eax,%eax
80108771:	79 0a                	jns    8010877d <allocuvm+0x17>
    return 0;
80108773:	b8 00 00 00 00       	mov    $0x0,%eax
80108778:	e9 fd 00 00 00       	jmp    8010887a <allocuvm+0x114>
  if(newsz < oldsz)
8010877d:	8b 45 10             	mov    0x10(%ebp),%eax
80108780:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108783:	73 08                	jae    8010878d <allocuvm+0x27>
    return oldsz;
80108785:	8b 45 0c             	mov    0xc(%ebp),%eax
80108788:	e9 ed 00 00 00       	jmp    8010887a <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
8010878d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108790:	05 ff 0f 00 00       	add    $0xfff,%eax
80108795:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010879a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010879d:	e9 c9 00 00 00       	jmp    8010886b <allocuvm+0x105>
    mem = kalloc();
801087a2:	e8 f0 a5 ff ff       	call   80102d97 <kalloc>
801087a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801087aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087ae:	75 2f                	jne    801087df <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801087b0:	c7 04 24 9d 9a 10 80 	movl   $0x80109a9d,(%esp)
801087b7:	e8 05 7c ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801087bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801087bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801087c3:	8b 45 10             	mov    0x10(%ebp),%eax
801087c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801087ca:	8b 45 08             	mov    0x8(%ebp),%eax
801087cd:	89 04 24             	mov    %eax,(%esp)
801087d0:	e8 a7 00 00 00       	call   8010887c <deallocuvm>
      return 0;
801087d5:	b8 00 00 00 00       	mov    $0x0,%eax
801087da:	e9 9b 00 00 00       	jmp    8010887a <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
801087df:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087e6:	00 
801087e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087ee:	00 
801087ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f2:	89 04 24             	mov    %eax,(%esp)
801087f5:	e8 f8 cc ff ff       	call   801054f2 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801087fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087fd:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108806:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010880d:	00 
8010880e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108812:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108819:	00 
8010881a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010881e:	8b 45 08             	mov    0x8(%ebp),%eax
80108821:	89 04 24             	mov    %eax,(%esp)
80108824:	e8 db fa ff ff       	call   80108304 <mappages>
80108829:	85 c0                	test   %eax,%eax
8010882b:	79 37                	jns    80108864 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
8010882d:	c7 04 24 b5 9a 10 80 	movl   $0x80109ab5,(%esp)
80108834:	e8 88 7b ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010883c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108840:	8b 45 10             	mov    0x10(%ebp),%eax
80108843:	89 44 24 04          	mov    %eax,0x4(%esp)
80108847:	8b 45 08             	mov    0x8(%ebp),%eax
8010884a:	89 04 24             	mov    %eax,(%esp)
8010884d:	e8 2a 00 00 00       	call   8010887c <deallocuvm>
      kfree(mem);
80108852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108855:	89 04 24             	mov    %eax,(%esp)
80108858:	e8 68 a4 ff ff       	call   80102cc5 <kfree>
      return 0;
8010885d:	b8 00 00 00 00       	mov    $0x0,%eax
80108862:	eb 16                	jmp    8010887a <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108864:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108871:	0f 82 2b ff ff ff    	jb     801087a2 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108877:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010887a:	c9                   	leave  
8010887b:	c3                   	ret    

8010887c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010887c:	55                   	push   %ebp
8010887d:	89 e5                	mov    %esp,%ebp
8010887f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108882:	8b 45 10             	mov    0x10(%ebp),%eax
80108885:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108888:	72 08                	jb     80108892 <deallocuvm+0x16>
    return oldsz;
8010888a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010888d:	e9 ac 00 00 00       	jmp    8010893e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108892:	8b 45 10             	mov    0x10(%ebp),%eax
80108895:	05 ff 0f 00 00       	add    $0xfff,%eax
8010889a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010889f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801088a2:	e9 88 00 00 00       	jmp    8010892f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801088a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088b1:	00 
801088b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801088b6:	8b 45 08             	mov    0x8(%ebp),%eax
801088b9:	89 04 24             	mov    %eax,(%esp)
801088bc:	e8 a7 f9 ff ff       	call   80108268 <walkpgdir>
801088c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801088c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088c8:	75 14                	jne    801088de <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801088ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cd:	c1 e8 16             	shr    $0x16,%eax
801088d0:	40                   	inc    %eax
801088d1:	c1 e0 16             	shl    $0x16,%eax
801088d4:	2d 00 10 00 00       	sub    $0x1000,%eax
801088d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801088dc:	eb 4a                	jmp    80108928 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801088de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e1:	8b 00                	mov    (%eax),%eax
801088e3:	83 e0 01             	and    $0x1,%eax
801088e6:	85 c0                	test   %eax,%eax
801088e8:	74 3e                	je     80108928 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801088ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ed:	8b 00                	mov    (%eax),%eax
801088ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801088f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088fb:	75 0c                	jne    80108909 <deallocuvm+0x8d>
        panic("kfree");
801088fd:	c7 04 24 d1 9a 10 80 	movl   $0x80109ad1,(%esp)
80108904:	e8 4b 7c ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108909:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010890c:	05 00 00 00 80       	add    $0x80000000,%eax
80108911:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108914:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108917:	89 04 24             	mov    %eax,(%esp)
8010891a:	e8 a6 a3 ff ff       	call   80102cc5 <kfree>
      *pte = 0;
8010891f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108922:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108928:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010892f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108932:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108935:	0f 82 6c ff ff ff    	jb     801088a7 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010893b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010893e:	c9                   	leave  
8010893f:	c3                   	ret    

80108940 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108940:	55                   	push   %ebp
80108941:	89 e5                	mov    %esp,%ebp
80108943:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108946:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010894a:	75 0c                	jne    80108958 <freevm+0x18>
    panic("freevm: no pgdir");
8010894c:	c7 04 24 d7 9a 10 80 	movl   $0x80109ad7,(%esp)
80108953:	e8 fc 7b ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108958:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010895f:	00 
80108960:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108967:	80 
80108968:	8b 45 08             	mov    0x8(%ebp),%eax
8010896b:	89 04 24             	mov    %eax,(%esp)
8010896e:	e8 09 ff ff ff       	call   8010887c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108973:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010897a:	eb 44                	jmp    801089c0 <freevm+0x80>
    if(pgdir[i] & PTE_P){
8010897c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108986:	8b 45 08             	mov    0x8(%ebp),%eax
80108989:	01 d0                	add    %edx,%eax
8010898b:	8b 00                	mov    (%eax),%eax
8010898d:	83 e0 01             	and    $0x1,%eax
80108990:	85 c0                	test   %eax,%eax
80108992:	74 29                	je     801089bd <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108997:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010899e:	8b 45 08             	mov    0x8(%ebp),%eax
801089a1:	01 d0                	add    %edx,%eax
801089a3:	8b 00                	mov    (%eax),%eax
801089a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089aa:	05 00 00 00 80       	add    $0x80000000,%eax
801089af:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801089b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b5:	89 04 24             	mov    %eax,(%esp)
801089b8:	e8 08 a3 ff ff       	call   80102cc5 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801089bd:	ff 45 f4             	incl   -0xc(%ebp)
801089c0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801089c7:	76 b3                	jbe    8010897c <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801089c9:	8b 45 08             	mov    0x8(%ebp),%eax
801089cc:	89 04 24             	mov    %eax,(%esp)
801089cf:	e8 f1 a2 ff ff       	call   80102cc5 <kfree>
}
801089d4:	c9                   	leave  
801089d5:	c3                   	ret    

801089d6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801089d6:	55                   	push   %ebp
801089d7:	89 e5                	mov    %esp,%ebp
801089d9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801089dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801089e3:	00 
801089e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801089eb:	8b 45 08             	mov    0x8(%ebp),%eax
801089ee:	89 04 24             	mov    %eax,(%esp)
801089f1:	e8 72 f8 ff ff       	call   80108268 <walkpgdir>
801089f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801089f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089fd:	75 0c                	jne    80108a0b <clearpteu+0x35>
    panic("clearpteu");
801089ff:	c7 04 24 e8 9a 10 80 	movl   $0x80109ae8,(%esp)
80108a06:	e8 49 7b ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0e:	8b 00                	mov    (%eax),%eax
80108a10:	83 e0 fb             	and    $0xfffffffb,%eax
80108a13:	89 c2                	mov    %eax,%edx
80108a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a18:	89 10                	mov    %edx,(%eax)
}
80108a1a:	c9                   	leave  
80108a1b:	c3                   	ret    

80108a1c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108a1c:	55                   	push   %ebp
80108a1d:	89 e5                	mov    %esp,%ebp
80108a1f:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108a22:	e8 73 f9 ff ff       	call   8010839a <setupkvm>
80108a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a2e:	75 0a                	jne    80108a3a <copyuvm+0x1e>
    return 0;
80108a30:	b8 00 00 00 00       	mov    $0x0,%eax
80108a35:	e9 f8 00 00 00       	jmp    80108b32 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108a3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a41:	e9 cb 00 00 00       	jmp    80108b11 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a50:	00 
80108a51:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a55:	8b 45 08             	mov    0x8(%ebp),%eax
80108a58:	89 04 24             	mov    %eax,(%esp)
80108a5b:	e8 08 f8 ff ff       	call   80108268 <walkpgdir>
80108a60:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a63:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a67:	75 0c                	jne    80108a75 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108a69:	c7 04 24 f2 9a 10 80 	movl   $0x80109af2,(%esp)
80108a70:	e8 df 7a ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108a75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a78:	8b 00                	mov    (%eax),%eax
80108a7a:	83 e0 01             	and    $0x1,%eax
80108a7d:	85 c0                	test   %eax,%eax
80108a7f:	75 0c                	jne    80108a8d <copyuvm+0x71>
      panic("copyuvm: page not present");
80108a81:	c7 04 24 0c 9b 10 80 	movl   $0x80109b0c,(%esp)
80108a88:	e8 c7 7a ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108a8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a90:	8b 00                	mov    (%eax),%eax
80108a92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a97:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a9d:	8b 00                	mov    (%eax),%eax
80108a9f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108aa4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108aa7:	e8 eb a2 ff ff       	call   80102d97 <kalloc>
80108aac:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108aaf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108ab3:	75 02                	jne    80108ab7 <copyuvm+0x9b>
      goto bad;
80108ab5:	eb 6b                	jmp    80108b22 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108ab7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aba:	05 00 00 00 80       	add    $0x80000000,%eax
80108abf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ac6:	00 
80108ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
80108acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ace:	89 04 24             	mov    %eax,(%esp)
80108ad1:	e8 e5 ca ff ff       	call   801055bb <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108ad6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108adc:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae5:	89 54 24 10          	mov    %edx,0x10(%esp)
80108ae9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108aed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108af4:	00 
80108af5:	89 44 24 04          	mov    %eax,0x4(%esp)
80108af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108afc:	89 04 24             	mov    %eax,(%esp)
80108aff:	e8 00 f8 ff ff       	call   80108304 <mappages>
80108b04:	85 c0                	test   %eax,%eax
80108b06:	79 02                	jns    80108b0a <copyuvm+0xee>
      goto bad;
80108b08:	eb 18                	jmp    80108b22 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108b0a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b14:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b17:	0f 82 29 ff ff ff    	jb     80108a46 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b20:	eb 10                	jmp    80108b32 <copyuvm+0x116>

bad:
  freevm(d);
80108b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b25:	89 04 24             	mov    %eax,(%esp)
80108b28:	e8 13 fe ff ff       	call   80108940 <freevm>
  return 0;
80108b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b32:	c9                   	leave  
80108b33:	c3                   	ret    

80108b34 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108b34:	55                   	push   %ebp
80108b35:	89 e5                	mov    %esp,%ebp
80108b37:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b41:	00 
80108b42:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b45:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b49:	8b 45 08             	mov    0x8(%ebp),%eax
80108b4c:	89 04 24             	mov    %eax,(%esp)
80108b4f:	e8 14 f7 ff ff       	call   80108268 <walkpgdir>
80108b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5a:	8b 00                	mov    (%eax),%eax
80108b5c:	83 e0 01             	and    $0x1,%eax
80108b5f:	85 c0                	test   %eax,%eax
80108b61:	75 07                	jne    80108b6a <uva2ka+0x36>
    return 0;
80108b63:	b8 00 00 00 00       	mov    $0x0,%eax
80108b68:	eb 22                	jmp    80108b8c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6d:	8b 00                	mov    (%eax),%eax
80108b6f:	83 e0 04             	and    $0x4,%eax
80108b72:	85 c0                	test   %eax,%eax
80108b74:	75 07                	jne    80108b7d <uva2ka+0x49>
    return 0;
80108b76:	b8 00 00 00 00       	mov    $0x0,%eax
80108b7b:	eb 0f                	jmp    80108b8c <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b80:	8b 00                	mov    (%eax),%eax
80108b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b87:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108b8c:	c9                   	leave  
80108b8d:	c3                   	ret    

80108b8e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108b8e:	55                   	push   %ebp
80108b8f:	89 e5                	mov    %esp,%ebp
80108b91:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108b94:	8b 45 10             	mov    0x10(%ebp),%eax
80108b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108b9a:	e9 87 00 00 00       	jmp    80108c26 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ba7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bad:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80108bb4:	89 04 24             	mov    %eax,(%esp)
80108bb7:	e8 78 ff ff ff       	call   80108b34 <uva2ka>
80108bbc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108bbf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108bc3:	75 07                	jne    80108bcc <copyout+0x3e>
      return -1;
80108bc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bca:	eb 69                	jmp    80108c35 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108bd2:	29 c2                	sub    %eax,%edx
80108bd4:	89 d0                	mov    %edx,%eax
80108bd6:	05 00 10 00 00       	add    $0x1000,%eax
80108bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be1:	3b 45 14             	cmp    0x14(%ebp),%eax
80108be4:	76 06                	jbe    80108bec <copyout+0x5e>
      n = len;
80108be6:	8b 45 14             	mov    0x14(%ebp),%eax
80108be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bef:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bf2:	29 c2                	sub    %eax,%edx
80108bf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bf7:	01 c2                	add    %eax,%edx
80108bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bfc:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c03:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c07:	89 14 24             	mov    %edx,(%esp)
80108c0a:	e8 ac c9 ff ff       	call   801055bb <memmove>
    len -= n;
80108c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c12:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c18:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108c1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c1e:	05 00 10 00 00       	add    $0x1000,%eax
80108c23:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108c26:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108c2a:	0f 85 6f ff ff ff    	jne    80108b9f <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c35:	c9                   	leave  
80108c36:	c3                   	ret    
	...

80108c38 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80108c38:	55                   	push   %ebp
80108c39:	89 e5                	mov    %esp,%ebp
80108c3b:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
80108c3e:	8b 45 10             	mov    0x10(%ebp),%eax
80108c41:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c45:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4f:	89 04 24             	mov    %eax,(%esp)
80108c52:	e8 64 c9 ff ff       	call   801055bb <memmove>
}
80108c57:	c9                   	leave  
80108c58:	c3                   	ret    

80108c59 <strcpy>:

char* strcpy(char *s, char *t){
80108c59:	55                   	push   %ebp
80108c5a:	89 e5                	mov    %esp,%ebp
80108c5c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108c65:	90                   	nop
80108c66:	8b 45 08             	mov    0x8(%ebp),%eax
80108c69:	8d 50 01             	lea    0x1(%eax),%edx
80108c6c:	89 55 08             	mov    %edx,0x8(%ebp)
80108c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c72:	8d 4a 01             	lea    0x1(%edx),%ecx
80108c75:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108c78:	8a 12                	mov    (%edx),%dl
80108c7a:	88 10                	mov    %dl,(%eax)
80108c7c:	8a 00                	mov    (%eax),%al
80108c7e:	84 c0                	test   %al,%al
80108c80:	75 e4                	jne    80108c66 <strcpy+0xd>
    ;
  return os;
80108c82:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108c85:	c9                   	leave  
80108c86:	c3                   	ret    

80108c87 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80108c87:	55                   	push   %ebp
80108c88:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108c8a:	eb 06                	jmp    80108c92 <strcmp+0xb>
    p++, q++;
80108c8c:	ff 45 08             	incl   0x8(%ebp)
80108c8f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
80108c92:	8b 45 08             	mov    0x8(%ebp),%eax
80108c95:	8a 00                	mov    (%eax),%al
80108c97:	84 c0                	test   %al,%al
80108c99:	74 0e                	je     80108ca9 <strcmp+0x22>
80108c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c9e:	8a 10                	mov    (%eax),%dl
80108ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ca3:	8a 00                	mov    (%eax),%al
80108ca5:	38 c2                	cmp    %al,%dl
80108ca7:	74 e3                	je     80108c8c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80108ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80108cac:	8a 00                	mov    (%eax),%al
80108cae:	0f b6 d0             	movzbl %al,%edx
80108cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cb4:	8a 00                	mov    (%eax),%al
80108cb6:	0f b6 c0             	movzbl %al,%eax
80108cb9:	29 c2                	sub    %eax,%edx
80108cbb:	89 d0                	mov    %edx,%eax
}
80108cbd:	5d                   	pop    %ebp
80108cbe:	c3                   	ret    

80108cbf <set_root_inode>:

// struct con

void set_root_inode(char* name){
80108cbf:	55                   	push   %ebp
80108cc0:	89 e5                	mov    %esp,%ebp
80108cc2:	53                   	push   %ebx
80108cc3:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
80108cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc9:	89 04 24             	mov    %eax,(%esp)
80108ccc:	e8 02 01 00 00       	call   80108dd3 <find>
80108cd1:	89 c3                	mov    %eax,%ebx
80108cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd6:	89 04 24             	mov    %eax,(%esp)
80108cd9:	e8 72 99 ff ff       	call   80102650 <namei>
80108cde:	89 c2                	mov    %eax,%edx
80108ce0:	89 d8                	mov    %ebx,%eax
80108ce2:	01 c0                	add    %eax,%eax
80108ce4:	01 d8                	add    %ebx,%eax
80108ce6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80108ced:	01 c8                	add    %ecx,%eax
80108cef:	c1 e0 02             	shl    $0x2,%eax
80108cf2:	05 f0 7b 11 80       	add    $0x80117bf0,%eax
80108cf7:	89 50 08             	mov    %edx,0x8(%eax)

}
80108cfa:	83 c4 14             	add    $0x14,%esp
80108cfd:	5b                   	pop    %ebx
80108cfe:	5d                   	pop    %ebp
80108cff:	c3                   	ret    

80108d00 <get_name>:

void get_name(int vc_num, char* name){
80108d00:	55                   	push   %ebp
80108d01:	89 e5                	mov    %esp,%ebp
80108d03:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80108d06:	8b 55 08             	mov    0x8(%ebp),%edx
80108d09:	89 d0                	mov    %edx,%eax
80108d0b:	01 c0                	add    %eax,%eax
80108d0d:	01 d0                	add    %edx,%eax
80108d0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d16:	01 d0                	add    %edx,%eax
80108d18:	c1 e0 02             	shl    $0x2,%eax
80108d1b:	83 c0 10             	add    $0x10,%eax
80108d1e:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d23:	83 c0 08             	add    $0x8,%eax
80108d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80108d29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
80108d30:	eb 03                	jmp    80108d35 <get_name+0x35>
	{
		i++;
80108d32:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80108d35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d3b:	01 d0                	add    %edx,%eax
80108d3d:	8a 00                	mov    (%eax),%al
80108d3f:	84 c0                	test   %al,%al
80108d41:	75 ef                	jne    80108d32 <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80108d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d46:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d54:	89 04 24             	mov    %eax,(%esp)
80108d57:	e8 dc fe ff ff       	call   80108c38 <memcpy2>
}
80108d5c:	c9                   	leave  
80108d5d:	c3                   	ret    

80108d5e <g_name>:

char* g_name(int vc_bun){
80108d5e:	55                   	push   %ebp
80108d5f:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
80108d61:	8b 55 08             	mov    0x8(%ebp),%edx
80108d64:	89 d0                	mov    %edx,%eax
80108d66:	01 c0                	add    %eax,%eax
80108d68:	01 d0                	add    %edx,%eax
80108d6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d71:	01 d0                	add    %edx,%eax
80108d73:	c1 e0 02             	shl    $0x2,%eax
80108d76:	83 c0 10             	add    $0x10,%eax
80108d79:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d7e:	83 c0 08             	add    $0x8,%eax
}
80108d81:	5d                   	pop    %ebp
80108d82:	c3                   	ret    

80108d83 <is_full>:

int is_full(){
80108d83:	55                   	push   %ebp
80108d84:	89 e5                	mov    %esp,%ebp
80108d86:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108d89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d90:	eb 34                	jmp    80108dc6 <is_full+0x43>
		if(strlen(containers[i].name) == 0){
80108d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d95:	89 d0                	mov    %edx,%eax
80108d97:	01 c0                	add    %eax,%eax
80108d99:	01 d0                	add    %edx,%eax
80108d9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108da2:	01 d0                	add    %edx,%eax
80108da4:	c1 e0 02             	shl    $0x2,%eax
80108da7:	83 c0 10             	add    $0x10,%eax
80108daa:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108daf:	83 c0 08             	add    $0x8,%eax
80108db2:	89 04 24             	mov    %eax,(%esp)
80108db5:	e8 8b c9 ff ff       	call   80105745 <strlen>
80108dba:	85 c0                	test   %eax,%eax
80108dbc:	75 05                	jne    80108dc3 <is_full+0x40>
			return i;
80108dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc1:	eb 0e                	jmp    80108dd1 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108dc3:	ff 45 f4             	incl   -0xc(%ebp)
80108dc6:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80108dca:	7e c6                	jle    80108d92 <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108dd1:	c9                   	leave  
80108dd2:	c3                   	ret    

80108dd3 <find>:

int find(char* name){
80108dd3:	55                   	push   %ebp
80108dd4:	89 e5                	mov    %esp,%ebp
80108dd6:	83 ec 18             	sub    $0x18,%esp
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108dd9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108de0:	eb 54                	jmp    80108e36 <find+0x63>
		if(strcmp(name, "") == 0){
80108de2:	c7 44 24 04 28 9b 10 	movl   $0x80109b28,0x4(%esp)
80108de9:	80 
80108dea:	8b 45 08             	mov    0x8(%ebp),%eax
80108ded:	89 04 24             	mov    %eax,(%esp)
80108df0:	e8 92 fe ff ff       	call   80108c87 <strcmp>
80108df5:	85 c0                	test   %eax,%eax
80108df7:	75 02                	jne    80108dfb <find+0x28>
			continue;
80108df9:	eb 38                	jmp    80108e33 <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80108dfb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108dfe:	89 d0                	mov    %edx,%eax
80108e00:	01 c0                	add    %eax,%eax
80108e02:	01 d0                	add    %edx,%eax
80108e04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e0b:	01 d0                	add    %edx,%eax
80108e0d:	c1 e0 02             	shl    $0x2,%eax
80108e10:	83 c0 10             	add    $0x10,%eax
80108e13:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e18:	83 c0 08             	add    $0x8,%eax
80108e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80108e22:	89 04 24             	mov    %eax,(%esp)
80108e25:	e8 5d fe ff ff       	call   80108c87 <strcmp>
80108e2a:	85 c0                	test   %eax,%eax
80108e2c:	75 05                	jne    80108e33 <find+0x60>
			//cprintf("in hereI");
			return i;
80108e2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108e31:	eb 0e                	jmp    80108e41 <find+0x6e>
}

int find(char* name){
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108e33:	ff 45 fc             	incl   -0x4(%ebp)
80108e36:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108e3a:	7e a6                	jle    80108de2 <find+0xf>
		if(strcmp(name, containers[i].name) == 0){
			//cprintf("in hereI");
			return i;
		}
	}
	return -1;
80108e3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108e41:	c9                   	leave  
80108e42:	c3                   	ret    

80108e43 <get_max_proc>:

int get_max_proc(int vc_num){
80108e43:	55                   	push   %ebp
80108e44:	89 e5                	mov    %esp,%ebp
80108e46:	57                   	push   %edi
80108e47:	56                   	push   %esi
80108e48:	53                   	push   %ebx
80108e49:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80108e4f:	89 d0                	mov    %edx,%eax
80108e51:	01 c0                	add    %eax,%eax
80108e53:	01 d0                	add    %edx,%eax
80108e55:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e5c:	01 d0                	add    %edx,%eax
80108e5e:	c1 e0 02             	shl    $0x2,%eax
80108e61:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e66:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108e69:	89 c3                	mov    %eax,%ebx
80108e6b:	b8 0f 00 00 00       	mov    $0xf,%eax
80108e70:	89 d7                	mov    %edx,%edi
80108e72:	89 de                	mov    %ebx,%esi
80108e74:	89 c1                	mov    %eax,%ecx
80108e76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108e78:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80108e7b:	83 c4 40             	add    $0x40,%esp
80108e7e:	5b                   	pop    %ebx
80108e7f:	5e                   	pop    %esi
80108e80:	5f                   	pop    %edi
80108e81:	5d                   	pop    %ebp
80108e82:	c3                   	ret    

80108e83 <get_container>:

struct container* get_container(int vc_num){
80108e83:	55                   	push   %ebp
80108e84:	89 e5                	mov    %esp,%ebp
80108e86:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80108e89:	8b 55 08             	mov    0x8(%ebp),%edx
80108e8c:	89 d0                	mov    %edx,%eax
80108e8e:	01 c0                	add    %eax,%eax
80108e90:	01 d0                	add    %edx,%eax
80108e92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e99:	01 d0                	add    %edx,%eax
80108e9b:	c1 e0 02             	shl    $0x2,%eax
80108e9e:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ea3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	// cprintf("vc num given is %d\n.", vc_num);
	// cprintf("The name for this container is %s.\n", cont->name);
	return cont;
80108ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108ea9:	c9                   	leave  
80108eaa:	c3                   	ret    

80108eab <get_max_mem>:

int get_max_mem(int vc_num){
80108eab:	55                   	push   %ebp
80108eac:	89 e5                	mov    %esp,%ebp
80108eae:	57                   	push   %edi
80108eaf:	56                   	push   %esi
80108eb0:	53                   	push   %ebx
80108eb1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108eb4:	8b 55 08             	mov    0x8(%ebp),%edx
80108eb7:	89 d0                	mov    %edx,%eax
80108eb9:	01 c0                	add    %eax,%eax
80108ebb:	01 d0                	add    %edx,%eax
80108ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ec4:	01 d0                	add    %edx,%eax
80108ec6:	c1 e0 02             	shl    $0x2,%eax
80108ec9:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ece:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108ed1:	89 c3                	mov    %eax,%ebx
80108ed3:	b8 0f 00 00 00       	mov    $0xf,%eax
80108ed8:	89 d7                	mov    %edx,%edi
80108eda:	89 de                	mov    %ebx,%esi
80108edc:	89 c1                	mov    %eax,%ecx
80108ede:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108ee0:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108ee3:	83 c4 40             	add    $0x40,%esp
80108ee6:	5b                   	pop    %ebx
80108ee7:	5e                   	pop    %esi
80108ee8:	5f                   	pop    %edi
80108ee9:	5d                   	pop    %ebp
80108eea:	c3                   	ret    

80108eeb <get_max_disk>:

int get_max_disk(int vc_num){
80108eeb:	55                   	push   %ebp
80108eec:	89 e5                	mov    %esp,%ebp
80108eee:	57                   	push   %edi
80108eef:	56                   	push   %esi
80108ef0:	53                   	push   %ebx
80108ef1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108ef4:	8b 55 08             	mov    0x8(%ebp),%edx
80108ef7:	89 d0                	mov    %edx,%eax
80108ef9:	01 c0                	add    %eax,%eax
80108efb:	01 d0                	add    %edx,%eax
80108efd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f04:	01 d0                	add    %edx,%eax
80108f06:	c1 e0 02             	shl    $0x2,%eax
80108f09:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f0e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108f11:	89 c3                	mov    %eax,%ebx
80108f13:	b8 0f 00 00 00       	mov    $0xf,%eax
80108f18:	89 d7                	mov    %edx,%edi
80108f1a:	89 de                	mov    %ebx,%esi
80108f1c:	89 c1                	mov    %eax,%ecx
80108f1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80108f20:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80108f23:	83 c4 40             	add    $0x40,%esp
80108f26:	5b                   	pop    %ebx
80108f27:	5e                   	pop    %esi
80108f28:	5f                   	pop    %edi
80108f29:	5d                   	pop    %ebp
80108f2a:	c3                   	ret    

80108f2b <get_curr_proc>:

int get_curr_proc(int vc_num){
80108f2b:	55                   	push   %ebp
80108f2c:	89 e5                	mov    %esp,%ebp
80108f2e:	57                   	push   %edi
80108f2f:	56                   	push   %esi
80108f30:	53                   	push   %ebx
80108f31:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108f34:	8b 55 08             	mov    0x8(%ebp),%edx
80108f37:	89 d0                	mov    %edx,%eax
80108f39:	01 c0                	add    %eax,%eax
80108f3b:	01 d0                	add    %edx,%eax
80108f3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f44:	01 d0                	add    %edx,%eax
80108f46:	c1 e0 02             	shl    $0x2,%eax
80108f49:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f4e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108f51:	89 c3                	mov    %eax,%ebx
80108f53:	b8 0f 00 00 00       	mov    $0xf,%eax
80108f58:	89 d7                	mov    %edx,%edi
80108f5a:	89 de                	mov    %ebx,%esi
80108f5c:	89 c1                	mov    %eax,%ecx
80108f5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108f60:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80108f63:	83 c4 40             	add    $0x40,%esp
80108f66:	5b                   	pop    %ebx
80108f67:	5e                   	pop    %esi
80108f68:	5f                   	pop    %edi
80108f69:	5d                   	pop    %ebp
80108f6a:	c3                   	ret    

80108f6b <get_curr_mem>:

int get_curr_mem(int vc_num){
80108f6b:	55                   	push   %ebp
80108f6c:	89 e5                	mov    %esp,%ebp
80108f6e:	57                   	push   %edi
80108f6f:	56                   	push   %esi
80108f70:	53                   	push   %ebx
80108f71:	83 ec 5c             	sub    $0x5c,%esp
	struct container x = containers[vc_num];
80108f74:	8b 55 08             	mov    0x8(%ebp),%edx
80108f77:	89 d0                	mov    %edx,%eax
80108f79:	01 c0                	add    %eax,%eax
80108f7b:	01 d0                	add    %edx,%eax
80108f7d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f84:	01 d0                	add    %edx,%eax
80108f86:	c1 e0 02             	shl    $0x2,%eax
80108f89:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f8e:	8d 55 ac             	lea    -0x54(%ebp),%edx
80108f91:	89 c3                	mov    %eax,%ebx
80108f93:	b8 0f 00 00 00       	mov    $0xf,%eax
80108f98:	89 d7                	mov    %edx,%edi
80108f9a:	89 de                	mov    %ebx,%esi
80108f9c:	89 c1                	mov    %eax,%ecx
80108f9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
80108fa0:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fa7:	c7 04 24 2c 9b 10 80 	movl   $0x80109b2c,(%esp)
80108fae:	e8 0e 74 ff ff       	call   801003c1 <cprintf>
	return x.curr_mem; 
80108fb3:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108fb6:	83 c4 5c             	add    $0x5c,%esp
80108fb9:	5b                   	pop    %ebx
80108fba:	5e                   	pop    %esi
80108fbb:	5f                   	pop    %edi
80108fbc:	5d                   	pop    %ebp
80108fbd:	c3                   	ret    

80108fbe <get_curr_disk>:

int get_curr_disk(int vc_num){
80108fbe:	55                   	push   %ebp
80108fbf:	89 e5                	mov    %esp,%ebp
80108fc1:	57                   	push   %edi
80108fc2:	56                   	push   %esi
80108fc3:	53                   	push   %ebx
80108fc4:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108fc7:	8b 55 08             	mov    0x8(%ebp),%edx
80108fca:	89 d0                	mov    %edx,%eax
80108fcc:	01 c0                	add    %eax,%eax
80108fce:	01 d0                	add    %edx,%eax
80108fd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fd7:	01 d0                	add    %edx,%eax
80108fd9:	c1 e0 02             	shl    $0x2,%eax
80108fdc:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108fe1:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108fe4:	89 c3                	mov    %eax,%ebx
80108fe6:	b8 0f 00 00 00       	mov    $0xf,%eax
80108feb:	89 d7                	mov    %edx,%edi
80108fed:	89 de                	mov    %ebx,%esi
80108fef:	89 c1                	mov    %eax,%ecx
80108ff1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80108ff3:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
80108ff6:	83 c4 40             	add    $0x40,%esp
80108ff9:	5b                   	pop    %ebx
80108ffa:	5e                   	pop    %esi
80108ffb:	5f                   	pop    %edi
80108ffc:	5d                   	pop    %ebp
80108ffd:	c3                   	ret    

80108ffe <set_name>:

void set_name(char* name, int vc_num){
80108ffe:	55                   	push   %ebp
80108fff:	89 e5                	mov    %esp,%ebp
80109001:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109004:	8b 55 0c             	mov    0xc(%ebp),%edx
80109007:	89 d0                	mov    %edx,%eax
80109009:	01 c0                	add    %eax,%eax
8010900b:	01 d0                	add    %edx,%eax
8010900d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109014:	01 d0                	add    %edx,%eax
80109016:	c1 e0 02             	shl    $0x2,%eax
80109019:	83 c0 10             	add    $0x10,%eax
8010901c:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109021:	8d 50 08             	lea    0x8(%eax),%edx
80109024:	8b 45 08             	mov    0x8(%ebp),%eax
80109027:	89 44 24 04          	mov    %eax,0x4(%esp)
8010902b:	89 14 24             	mov    %edx,(%esp)
8010902e:	e8 26 fc ff ff       	call   80108c59 <strcpy>
}
80109033:	c9                   	leave  
80109034:	c3                   	ret    

80109035 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80109035:	55                   	push   %ebp
80109036:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80109038:	8b 55 0c             	mov    0xc(%ebp),%edx
8010903b:	89 d0                	mov    %edx,%eax
8010903d:	01 c0                	add    %eax,%eax
8010903f:	01 d0                	add    %edx,%eax
80109041:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109048:	01 d0                	add    %edx,%eax
8010904a:	c1 e0 02             	shl    $0x2,%eax
8010904d:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80109053:	8b 45 08             	mov    0x8(%ebp),%eax
80109056:	89 02                	mov    %eax,(%edx)
}
80109058:	5d                   	pop    %ebp
80109059:	c3                   	ret    

8010905a <set_max_disk>:

void set_max_disk(int disk, int vc_num){
8010905a:	55                   	push   %ebp
8010905b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
8010905d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109060:	89 d0                	mov    %edx,%eax
80109062:	01 c0                	add    %eax,%eax
80109064:	01 d0                	add    %edx,%eax
80109066:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010906d:	01 d0                	add    %edx,%eax
8010906f:	c1 e0 02             	shl    $0x2,%eax
80109072:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80109078:	8b 45 08             	mov    0x8(%ebp),%eax
8010907b:	89 42 08             	mov    %eax,0x8(%edx)
}
8010907e:	5d                   	pop    %ebp
8010907f:	c3                   	ret    

80109080 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80109080:	55                   	push   %ebp
80109081:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80109083:	8b 55 0c             	mov    0xc(%ebp),%edx
80109086:	89 d0                	mov    %edx,%eax
80109088:	01 c0                	add    %eax,%eax
8010908a:	01 d0                	add    %edx,%eax
8010908c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109093:	01 d0                	add    %edx,%eax
80109095:	c1 e0 02             	shl    $0x2,%eax
80109098:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
8010909e:	8b 45 08             	mov    0x8(%ebp),%eax
801090a1:	89 42 04             	mov    %eax,0x4(%edx)
}
801090a4:	5d                   	pop    %ebp
801090a5:	c3                   	ret    

801090a6 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
801090a6:	55                   	push   %ebp
801090a7:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
801090a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801090ac:	89 d0                	mov    %edx,%eax
801090ae:	01 c0                	add    %eax,%eax
801090b0:	01 d0                	add    %edx,%eax
801090b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090b9:	01 d0                	add    %edx,%eax
801090bb:	c1 e0 02             	shl    $0x2,%eax
801090be:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801090c3:	8b 40 0c             	mov    0xc(%eax),%eax
801090c6:	8d 48 01             	lea    0x1(%eax),%ecx
801090c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801090cc:	89 d0                	mov    %edx,%eax
801090ce:	01 c0                	add    %eax,%eax
801090d0:	01 d0                	add    %edx,%eax
801090d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090d9:	01 d0                	add    %edx,%eax
801090db:	c1 e0 02             	shl    $0x2,%eax
801090de:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801090e3:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem-1, containers[vc_num].curr_mem);	
}
801090e6:	5d                   	pop    %ebp
801090e7:	c3                   	ret    

801090e8 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
801090e8:	55                   	push   %ebp
801090e9:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;
801090eb:	8b 55 0c             	mov    0xc(%ebp),%edx
801090ee:	89 d0                	mov    %edx,%eax
801090f0:	01 c0                	add    %eax,%eax
801090f2:	01 d0                	add    %edx,%eax
801090f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090fb:	01 d0                	add    %edx,%eax
801090fd:	c1 e0 02             	shl    $0x2,%eax
80109100:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109105:	8b 40 0c             	mov    0xc(%eax),%eax
80109108:	8d 48 ff             	lea    -0x1(%eax),%ecx
8010910b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010910e:	89 d0                	mov    %edx,%eax
80109110:	01 c0                	add    %eax,%eax
80109112:	01 d0                	add    %edx,%eax
80109114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010911b:	01 d0                	add    %edx,%eax
8010911d:	c1 e0 02             	shl    $0x2,%eax
80109120:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109125:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem, containers[vc_num].curr_mem-1);	
}
80109128:	5d                   	pop    %ebp
80109129:	c3                   	ret    

8010912a <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
8010912a:	55                   	push   %ebp
8010912b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
8010912d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109130:	89 d0                	mov    %edx,%eax
80109132:	01 c0                	add    %eax,%eax
80109134:	01 d0                	add    %edx,%eax
80109136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010913d:	01 d0                	add    %edx,%eax
8010913f:	c1 e0 02             	shl    $0x2,%eax
80109142:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80109147:	8b 50 04             	mov    0x4(%eax),%edx
8010914a:	8b 45 08             	mov    0x8(%ebp),%eax
8010914d:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109150:	8b 55 0c             	mov    0xc(%ebp),%edx
80109153:	89 d0                	mov    %edx,%eax
80109155:	01 c0                	add    %eax,%eax
80109157:	01 d0                	add    %edx,%eax
80109159:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109160:	01 d0                	add    %edx,%eax
80109162:	c1 e0 02             	shl    $0x2,%eax
80109165:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010916a:	89 48 04             	mov    %ecx,0x4(%eax)
}
8010916d:	5d                   	pop    %ebp
8010916e:	c3                   	ret    

8010916f <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
8010916f:	55                   	push   %ebp
80109170:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80109172:	8b 55 0c             	mov    0xc(%ebp),%edx
80109175:	89 d0                	mov    %edx,%eax
80109177:	01 c0                	add    %eax,%eax
80109179:	01 d0                	add    %edx,%eax
8010917b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109182:	01 d0                	add    %edx,%eax
80109184:	c1 e0 02             	shl    $0x2,%eax
80109187:	8d 90 d0 7b 11 80    	lea    -0x7fee8430(%eax),%edx
8010918d:	8b 45 08             	mov    0x8(%ebp),%eax
80109190:	89 02                	mov    %eax,(%edx)
}
80109192:	5d                   	pop    %ebp
80109193:	c3                   	ret    

80109194 <max_containers>:

int max_containers(){
80109194:	55                   	push   %ebp
80109195:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
80109197:	b8 04 00 00 00       	mov    $0x4,%eax
}
8010919c:	5d                   	pop    %ebp
8010919d:	c3                   	ret    

8010919e <container_init>:

void container_init(){
8010919e:	55                   	push   %ebp
8010919f:	89 e5                	mov    %esp,%ebp
801091a1:	83 ec 18             	sub    $0x18,%esp

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801091a4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801091ab:	e9 f7 00 00 00       	jmp    801092a7 <container_init+0x109>
		strcpy(containers[i].name, "");
801091b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801091b3:	89 d0                	mov    %edx,%eax
801091b5:	01 c0                	add    %eax,%eax
801091b7:	01 d0                	add    %edx,%eax
801091b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091c0:	01 d0                	add    %edx,%eax
801091c2:	c1 e0 02             	shl    $0x2,%eax
801091c5:	83 c0 10             	add    $0x10,%eax
801091c8:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801091cd:	83 c0 08             	add    $0x8,%eax
801091d0:	c7 44 24 04 28 9b 10 	movl   $0x80109b28,0x4(%esp)
801091d7:	80 
801091d8:	89 04 24             	mov    %eax,(%esp)
801091db:	e8 79 fa ff ff       	call   80108c59 <strcpy>
		containers[i].max_proc = 4;
801091e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801091e3:	89 d0                	mov    %edx,%eax
801091e5:	01 c0                	add    %eax,%eax
801091e7:	01 d0                	add    %edx,%eax
801091e9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091f0:	01 d0                	add    %edx,%eax
801091f2:	c1 e0 02             	shl    $0x2,%eax
801091f5:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801091fa:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80109201:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109204:	89 d0                	mov    %edx,%eax
80109206:	01 c0                	add    %eax,%eax
80109208:	01 d0                	add    %edx,%eax
8010920a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109211:	01 d0                	add    %edx,%eax
80109213:	c1 e0 02             	shl    $0x2,%eax
80109216:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010921b:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
80109222:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109225:	89 d0                	mov    %edx,%eax
80109227:	01 c0                	add    %eax,%eax
80109229:	01 d0                	add    %edx,%eax
8010922b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109232:	01 d0                	add    %edx,%eax
80109234:	c1 e0 02             	shl    $0x2,%eax
80109237:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010923c:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 1;
80109242:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109245:	89 d0                	mov    %edx,%eax
80109247:	01 c0                	add    %eax,%eax
80109249:	01 d0                	add    %edx,%eax
8010924b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109252:	01 d0                	add    %edx,%eax
80109254:	c1 e0 02             	shl    $0x2,%eax
80109257:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010925c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
80109262:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109265:	89 d0                	mov    %edx,%eax
80109267:	01 c0                	add    %eax,%eax
80109269:	01 d0                	add    %edx,%eax
8010926b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109272:	01 d0                	add    %edx,%eax
80109274:	c1 e0 02             	shl    $0x2,%eax
80109277:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010927c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
80109283:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109286:	89 d0                	mov    %edx,%eax
80109288:	01 c0                	add    %eax,%eax
8010928a:	01 d0                	add    %edx,%eax
8010928c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109293:	01 d0                	add    %edx,%eax
80109295:	c1 e0 02             	shl    $0x2,%eax
80109298:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010929d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

void container_init(){

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801092a4:	ff 45 fc             	incl   -0x4(%ebp)
801092a7:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801092ab:	0f 8e ff fe ff ff    	jle    801091b0 <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
801092b1:	c9                   	leave  
801092b2:	c3                   	ret    
