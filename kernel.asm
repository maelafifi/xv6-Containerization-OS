
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
80100028:	bc d0 d8 10 80       	mov    $0x8010d8d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 22 38 10 80       	mov    $0x80103822,%eax
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
8010003a:	c7 44 24 04 14 89 10 	movl   $0x80108914,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100049:	e8 e4 4d 00 00       	call   80104e32 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 2c 20 11 80 dc 	movl   $0x80111fdc,0x8011202c
80100055:	1f 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 30 20 11 80 dc 	movl   $0x80111fdc,0x80112030
8010005f:	1f 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 14 d9 10 80 	movl   $0x8010d914,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 30 20 11 80    	mov    0x80112030,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 dc 1f 11 80 	movl   $0x80111fdc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 1b 89 10 	movl   $0x8010891b,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 5d 4c 00 00       	call   80104cf4 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 30 20 11 80       	mov    0x80112030,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 30 20 11 80       	mov    %eax,0x80112030

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 dc 1f 11 80 	cmpl   $0x80111fdc,-0xc(%ebp)
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
801000c2:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
801000c9:	e8 85 4d 00 00       	call   80104e53 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 30 20 11 80       	mov    0x80112030,%eax
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
801000fd:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100104:	e8 b4 4d 00 00       	call   80104ebd <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 17 4c 00 00       	call   80104d2e <acquiresleep>
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
80100128:	81 7d f4 dc 1f 11 80 	cmpl   $0x80111fdc,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 2c 20 11 80       	mov    0x8011202c,%eax
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
80100176:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
8010017d:	e8 3b 4d 00 00       	call   80104ebd <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 9e 4b 00 00       	call   80104d2e <acquiresleep>
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
8010019e:	81 7d f4 dc 1f 11 80 	cmpl   $0x80111fdc,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 22 89 10 80 	movl   $0x80108922,(%esp)
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
801001e2:	e8 72 27 00 00       	call   80102959 <iderw>
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
801001fb:	e8 cb 4b 00 00       	call   80104dcb <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 33 89 10 80 	movl   $0x80108933,(%esp)
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
80100225:	e8 2f 27 00 00       	call   80102959 <iderw>
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
8010023b:	e8 8b 4b 00 00       	call   80104dcb <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 3a 89 10 80 	movl   $0x8010893a,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 2b 4b 00 00       	call   80104d89 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100265:	e8 e9 4b 00 00       	call   80104e53 <acquire>
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
801002a1:	8b 15 30 20 11 80    	mov    0x80112030,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 dc 1f 11 80 	movl   $0x80111fdc,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 30 20 11 80       	mov    0x80112030,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 30 20 11 80       	mov    %eax,0x80112030
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
801002d1:	e8 e7 4b 00 00       	call   80104ebd <release>
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
801003c7:	a1 74 c8 10 80       	mov    0x8010c874,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
801003dc:	e8 72 4a 00 00       	call   80104e53 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 41 89 10 80 	movl   $0x80108941,(%esp)
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
801004cf:	c7 45 ec 4a 89 10 80 	movl   $0x8010894a,-0x14(%ebp)
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
80100546:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
8010054d:	e8 6b 49 00 00       	call   80104ebd <release>
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
8010055f:	c7 05 74 c8 10 80 00 	movl   $0x0,0x8010c874
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 87 2a 00 00       	call   80102ff5 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 51 89 10 80 	movl   $0x80108951,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 65 89 10 80 	movl   $0x80108965,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 63 49 00 00       	call   80104f0a <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 67 89 10 80 	movl   $0x80108967,(%esp)
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
801005d0:	c7 05 2c c8 10 80 01 	movl   $0x1,0x8010c82c
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
80100695:	c7 04 24 6b 89 10 80 	movl   $0x8010896b,(%esp)
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
801006c9:	e8 b1 4a 00 00       	call   8010517f <memmove>
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
801006f8:	e8 b9 49 00 00       	call   801050b6 <memset>
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
8010076e:	a1 2c c8 10 80       	mov    0x8010c82c,%eax
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
8010078e:	e8 09 65 00 00       	call   80106c9c <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 fd 64 00 00       	call   80106c9c <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 f1 64 00 00       	call   80106c9c <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 e4 64 00 00       	call   80106c9c <uartputc>
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
8010080c:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100813:	e8 3b 46 00 00       	call   80104e53 <acquire>
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
80100875:	ba 40 22 11 80       	mov    $0x80112240,%edx
8010087a:	bb c0 c5 10 80       	mov    $0x8010c5c0,%ebx
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
801008a3:	ba 60 c6 10 80       	mov    $0x8010c660,%edx
801008a8:	bb 40 22 11 80       	mov    $0x80112240,%ebx
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
801008c4:	ba 00 c7 10 80       	mov    $0x8010c700,%edx
801008c9:	bb 40 22 11 80       	mov    $0x80112240,%ebx
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
801008e5:	ba a0 c7 10 80       	mov    $0x8010c7a0,%edx
801008ea:	bb 40 22 11 80       	mov    $0x80112240,%ebx
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
80100908:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 c8 22 11 80       	mov    %eax,0x801122c8
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
80100922:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
80100928:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 40 22 11 80    	mov    -0x7feeddc0(%eax),%al
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
80100949:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
8010094f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 c8 22 11 80       	mov    %eax,0x801122c8
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
80100983:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
80100989:	a1 c0 22 11 80       	mov    0x801122c0,%eax
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
801009aa:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 c8 22 11 80    	mov    %edx,0x801122c8
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 40 22 11 80    	mov    %al,-0x7feeddc0(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801009e2:	8b 15 c0 22 11 80    	mov    0x801122c0,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801009f4:	a3 c4 22 11 80       	mov    %eax,0x801122c4
          wakeup(&input.r);
801009f9:	c7 04 24 c0 22 11 80 	movl   $0x801122c0,(%esp)
80100a00:	e8 54 41 00 00       	call   80104b59 <wakeup>
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
80100a1a:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100a21:	e8 97 44 00 00       	call   80104ebd <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 05                	je     80100a31 <consoleintr+0x23c>
    procdump();  // now call procdump() wo. cons.lock held
80100a2c:	e8 cb 41 00 00       	call   80104bfc <procdump>
  }
  if(doconsoleswitch){
80100a31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a35:	74 15                	je     80100a4c <consoleintr+0x257>
    cprintf("\nActive console now: %d\n", active);
80100a37:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a40:	c7 04 24 7e 89 10 80 	movl   $0x8010897e,(%esp)
80100a47:	e8 75 f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100a4c:	83 c4 2c             	add    $0x2c,%esp
80100a4f:	5b                   	pop    %ebx
80100a50:	5e                   	pop    %esi
80100a51:	5f                   	pop    %edi
80100a52:	5d                   	pop    %ebp
80100a53:	c3                   	ret    

80100a54 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb 10 00 00       	call   80101b50 <iunlock>
  target = n;
80100a65:	8b 45 10             	mov    0x10(%ebp),%eax
80100a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6b:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100a72:	e8 dc 43 00 00       	call   80104e53 <acquire>
  while(n > 0){
80100a77:	e9 b7 00 00 00       	jmp    80100b33 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a7c:	eb 41                	jmp    80100abf <consoleread+0x6b>
      if(myproc()->killed){
80100a7e:	e8 b4 37 00 00       	call   80104237 <myproc>
80100a83:	8b 40 24             	mov    0x24(%eax),%eax
80100a86:	85 c0                	test   %eax,%eax
80100a88:	74 21                	je     80100aab <consoleread+0x57>
        release(&cons.lock);
80100a8a:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100a91:	e8 27 44 00 00       	call   80104ebd <release>
        ilock(ip);
80100a96:	8b 45 08             	mov    0x8(%ebp),%eax
80100a99:	89 04 24             	mov    %eax,(%esp)
80100a9c:	e8 a5 0f 00 00       	call   80101a46 <ilock>
        return -1;
80100aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100aa6:	e9 b3 00 00 00       	jmp    80100b5e <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100aab:	c7 44 24 04 40 c8 10 	movl   $0x8010c840,0x4(%esp)
80100ab2:	80 
80100ab3:	c7 04 24 c0 22 11 80 	movl   $0x801122c0,(%esp)
80100aba:	e8 c6 3f 00 00       	call   80104a85 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100abf:	8b 15 c0 22 11 80    	mov    0x801122c0,%edx
80100ac5:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80100aca:	39 c2                	cmp    %eax,%edx
80100acc:	74 b0                	je     80100a7e <consoleread+0x2a>
80100ace:	8b 45 08             	mov    0x8(%ebp),%eax
80100ad1:	8b 40 54             	mov    0x54(%eax),%eax
80100ad4:	0f bf d0             	movswl %ax,%edx
80100ad7:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100adc:	39 c2                	cmp    %eax,%edx
80100ade:	75 9e                	jne    80100a7e <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ae0:	a1 c0 22 11 80       	mov    0x801122c0,%eax
80100ae5:	8d 50 01             	lea    0x1(%eax),%edx
80100ae8:	89 15 c0 22 11 80    	mov    %edx,0x801122c0
80100aee:	83 e0 7f             	and    $0x7f,%eax
80100af1:	8a 80 40 22 11 80    	mov    -0x7feeddc0(%eax),%al
80100af7:	0f be c0             	movsbl %al,%eax
80100afa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100afd:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b01:	75 17                	jne    80100b1a <consoleread+0xc6>
      if(n < target){
80100b03:	8b 45 10             	mov    0x10(%ebp),%eax
80100b06:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b09:	73 0d                	jae    80100b18 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b0b:	a1 c0 22 11 80       	mov    0x801122c0,%eax
80100b10:	48                   	dec    %eax
80100b11:	a3 c0 22 11 80       	mov    %eax,0x801122c0
      }
      break;
80100b16:	eb 25                	jmp    80100b3d <consoleread+0xe9>
80100b18:	eb 23                	jmp    80100b3d <consoleread+0xe9>
    }
    *dst++ = c;
80100b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b1d:	8d 50 01             	lea    0x1(%eax),%edx
80100b20:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b23:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b26:	88 10                	mov    %dl,(%eax)
    --n;
80100b28:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b2b:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2f:	75 02                	jne    80100b33 <consoleread+0xdf>
      break;
80100b31:	eb 0a                	jmp    80100b3d <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b37:	0f 8f 3f ff ff ff    	jg     80100a7c <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100b3d:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100b44:	e8 74 43 00 00       	call   80104ebd <release>
  ilock(ip);
80100b49:	8b 45 08             	mov    0x8(%ebp),%eax
80100b4c:	89 04 24             	mov    %eax,(%esp)
80100b4f:	e8 f2 0e 00 00       	call   80101a46 <ilock>

  return target - n;
80100b54:	8b 45 10             	mov    0x10(%ebp),%eax
80100b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5a:	29 c2                	sub    %eax,%edx
80100b5c:	89 d0                	mov    %edx,%eax
}
80100b5e:	c9                   	leave  
80100b5f:	c3                   	ret    

80100b60 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b60:	55                   	push   %ebp
80100b61:	89 e5                	mov    %esp,%ebp
80100b63:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100b66:	8b 45 08             	mov    0x8(%ebp),%eax
80100b69:	8b 40 54             	mov    0x54(%eax),%eax
80100b6c:	0f bf d0             	movswl %ax,%edx
80100b6f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100b74:	39 c2                	cmp    %eax,%edx
80100b76:	75 5a                	jne    80100bd2 <consolewrite+0x72>
    iunlock(ip);
80100b78:	8b 45 08             	mov    0x8(%ebp),%eax
80100b7b:	89 04 24             	mov    %eax,(%esp)
80100b7e:	e8 cd 0f 00 00       	call   80101b50 <iunlock>
    acquire(&cons.lock);
80100b83:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100b8a:	e8 c4 42 00 00       	call   80104e53 <acquire>
    for(i = 0; i < n; i++)
80100b8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b96:	eb 1b                	jmp    80100bb3 <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100b98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9e:	01 d0                	add    %edx,%eax
80100ba0:	8a 00                	mov    (%eax),%al
80100ba2:	0f be c0             	movsbl %al,%eax
80100ba5:	0f b6 c0             	movzbl %al,%eax
80100ba8:	89 04 24             	mov    %eax,(%esp)
80100bab:	e8 b8 fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100bb0:	ff 45 f4             	incl   -0xc(%ebp)
80100bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb6:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bb9:	7c dd                	jl     80100b98 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100bbb:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100bc2:	e8 f6 42 00 00       	call   80104ebd <release>
    ilock(ip);
80100bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80100bca:	89 04 24             	mov    %eax,(%esp)
80100bcd:	e8 74 0e 00 00       	call   80101a46 <ilock>
  }
  return n;
80100bd2:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bd5:	c9                   	leave  
80100bd6:	c3                   	ret    

80100bd7 <consoleinit>:

void
consoleinit(void)
{
80100bd7:	55                   	push   %ebp
80100bd8:	89 e5                	mov    %esp,%ebp
80100bda:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100bdd:	c7 44 24 04 97 89 10 	movl   $0x80108997,0x4(%esp)
80100be4:	80 
80100be5:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100bec:	e8 41 42 00 00       	call   80104e32 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100bf1:	c7 05 8c 2c 11 80 60 	movl   $0x80100b60,0x80112c8c
80100bf8:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bfb:	c7 05 88 2c 11 80 54 	movl   $0x80100a54,0x80112c88
80100c02:	0a 10 80 
  cons.locking = 1;
80100c05:	c7 05 74 c8 10 80 01 	movl   $0x1,0x8010c874
80100c0c:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c16:	00 
80100c17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c1e:	e8 e8 1e 00 00       	call   80102b0b <ioapicenable>
}
80100c23:	c9                   	leave  
80100c24:	c3                   	ret    
80100c25:	00 00                	add    %al,(%eax)
	...

80100c28 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c28:	55                   	push   %ebp
80100c29:	89 e5                	mov    %esp,%ebp
80100c2b:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c31:	e8 01 36 00 00       	call   80104237 <myproc>
80100c36:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c39:	e8 01 29 00 00       	call   8010353f <begin_op>

  if((ip = namei(path)) == 0){
80100c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c41:	89 04 24             	mov    %eax,(%esp)
80100c44:	e8 22 19 00 00       	call   8010256b <namei>
80100c49:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c4c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c50:	75 1b                	jne    80100c6d <exec+0x45>
    end_op();
80100c52:	e8 6a 29 00 00       	call   801035c1 <end_op>
    cprintf("exec: fail\n");
80100c57:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
80100c5e:	e8 5e f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c68:	e9 f6 03 00 00       	jmp    80101063 <exec+0x43b>
  }
  ilock(ip);
80100c6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c70:	89 04 24             	mov    %eax,(%esp)
80100c73:	e8 ce 0d 00 00       	call   80101a46 <ilock>
  pgdir = 0;
80100c78:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c7f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100c86:	00 
80100c87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100c8e:	00 
80100c8f:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c95:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c99:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c9c:	89 04 24             	mov    %eax,(%esp)
80100c9f:	e8 39 12 00 00       	call   80101edd <readi>
80100ca4:	83 f8 34             	cmp    $0x34,%eax
80100ca7:	74 05                	je     80100cae <exec+0x86>
    goto bad;
80100ca9:	e9 89 03 00 00       	jmp    80101037 <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100cae:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100cb4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cb9:	74 05                	je     80100cc0 <exec+0x98>
    goto bad;
80100cbb:	e9 77 03 00 00       	jmp    80101037 <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100cc0:	e8 b9 6f 00 00       	call   80107c7e <setupkvm>
80100cc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100cc8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0xab>
    goto bad;
80100cce:	e9 64 03 00 00       	jmp    80101037 <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100cd3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cda:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ce1:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100ce7:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cea:	e9 fb 00 00 00       	jmp    80100dea <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cf2:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100cf9:	00 
80100cfa:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cfe:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d08:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d0b:	89 04 24             	mov    %eax,(%esp)
80100d0e:	e8 ca 11 00 00       	call   80101edd <readi>
80100d13:	83 f8 20             	cmp    $0x20,%eax
80100d16:	74 05                	je     80100d1d <exec+0xf5>
      goto bad;
80100d18:	e9 1a 03 00 00       	jmp    80101037 <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100d1d:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d23:	83 f8 01             	cmp    $0x1,%eax
80100d26:	74 05                	je     80100d2d <exec+0x105>
      continue;
80100d28:	e9 b1 00 00 00       	jmp    80100dde <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d2d:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d33:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d39:	39 c2                	cmp    %eax,%edx
80100d3b:	73 05                	jae    80100d42 <exec+0x11a>
      goto bad;
80100d3d:	e9 f5 02 00 00       	jmp    80101037 <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d42:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d48:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d4e:	01 c2                	add    %eax,%edx
80100d50:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d56:	39 c2                	cmp    %eax,%edx
80100d58:	73 05                	jae    80100d5f <exec+0x137>
      goto bad;
80100d5a:	e9 d8 02 00 00       	jmp    80101037 <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d5f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d65:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d6b:	01 d0                	add    %edx,%eax
80100d6d:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d74:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d7b:	89 04 24             	mov    %eax,(%esp)
80100d7e:	e8 c7 72 00 00       	call   8010804a <allocuvm>
80100d83:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d86:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d8a:	75 05                	jne    80100d91 <exec+0x169>
      goto bad;
80100d8c:	e9 a6 02 00 00       	jmp    80101037 <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100d91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d97:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d9c:	85 c0                	test   %eax,%eax
80100d9e:	74 05                	je     80100da5 <exec+0x17d>
      goto bad;
80100da0:	e9 92 02 00 00       	jmp    80101037 <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100da5:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dab:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100db1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100db7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100dbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100dbf:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dc2:	89 54 24 08          	mov    %edx,0x8(%esp)
80100dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dcd:	89 04 24             	mov    %eax,(%esp)
80100dd0:	e8 92 71 00 00       	call   80107f67 <loaduvm>
80100dd5:	85 c0                	test   %eax,%eax
80100dd7:	79 05                	jns    80100dde <exec+0x1b6>
      goto bad;
80100dd9:	e9 59 02 00 00       	jmp    80101037 <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dde:	ff 45 ec             	incl   -0x14(%ebp)
80100de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100de4:	83 c0 20             	add    $0x20,%eax
80100de7:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dea:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100df0:	0f b7 c0             	movzwl %ax,%eax
80100df3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100df6:	0f 8f f3 fe ff ff    	jg     80100cef <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100dfc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100dff:	89 04 24             	mov    %eax,(%esp)
80100e02:	e8 3e 0e 00 00       	call   80101c45 <iunlockput>
  end_op();
80100e07:	e8 b5 27 00 00       	call   801035c1 <end_op>
  ip = 0;
80100e0c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e16:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e26:	05 00 20 00 00       	add    $0x2000,%eax
80100e2b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e32:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e39:	89 04 24             	mov    %eax,(%esp)
80100e3c:	e8 09 72 00 00       	call   8010804a <allocuvm>
80100e41:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e44:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e48:	75 05                	jne    80100e4f <exec+0x227>
    goto bad;
80100e4a:	e9 e8 01 00 00       	jmp    80101037 <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e52:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e57:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e5e:	89 04 24             	mov    %eax,(%esp)
80100e61:	e8 54 74 00 00       	call   801082ba <clearpteu>
  sp = sz;
80100e66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e69:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e73:	e9 95 00 00 00       	jmp    80100f0d <exec+0x2e5>
    if(argc >= MAXARG)
80100e78:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e7c:	76 05                	jbe    80100e83 <exec+0x25b>
      goto bad;
80100e7e:	e9 b4 01 00 00       	jmp    80101037 <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e90:	01 d0                	add    %edx,%eax
80100e92:	8b 00                	mov    (%eax),%eax
80100e94:	89 04 24             	mov    %eax,(%esp)
80100e97:	e8 6d 44 00 00       	call   80105309 <strlen>
80100e9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e9f:	29 c2                	sub    %eax,%edx
80100ea1:	89 d0                	mov    %edx,%eax
80100ea3:	48                   	dec    %eax
80100ea4:	83 e0 fc             	and    $0xfffffffc,%eax
80100ea7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ead:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eb7:	01 d0                	add    %edx,%eax
80100eb9:	8b 00                	mov    (%eax),%eax
80100ebb:	89 04 24             	mov    %eax,(%esp)
80100ebe:	e8 46 44 00 00       	call   80105309 <strlen>
80100ec3:	40                   	inc    %eax
80100ec4:	89 c2                	mov    %eax,%edx
80100ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ed3:	01 c8                	add    %ecx,%eax
80100ed5:	8b 00                	mov    (%eax),%eax
80100ed7:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100edb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100edf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ee6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee9:	89 04 24             	mov    %eax,(%esp)
80100eec:	e8 81 75 00 00       	call   80108472 <copyout>
80100ef1:	85 c0                	test   %eax,%eax
80100ef3:	79 05                	jns    80100efa <exec+0x2d2>
      goto bad;
80100ef5:	e9 3d 01 00 00       	jmp    80101037 <exec+0x40f>
    ustack[3+argc] = sp;
80100efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efd:	8d 50 03             	lea    0x3(%eax),%edx
80100f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f03:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f0a:	ff 45 e4             	incl   -0x1c(%ebp)
80100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f1a:	01 d0                	add    %edx,%eax
80100f1c:	8b 00                	mov    (%eax),%eax
80100f1e:	85 c0                	test   %eax,%eax
80100f20:	0f 85 52 ff ff ff    	jne    80100e78 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f29:	83 c0 03             	add    $0x3,%eax
80100f2c:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f33:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f37:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f3e:	ff ff ff 
  ustack[1] = argc;
80100f41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f44:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4d:	40                   	inc    %eax
80100f4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f58:	29 d0                	sub    %edx,%eax
80100f5a:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f63:	83 c0 04             	add    $0x4,%eax
80100f66:	c1 e0 02             	shl    $0x2,%eax
80100f69:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f6f:	83 c0 04             	add    $0x4,%eax
80100f72:	c1 e0 02             	shl    $0x2,%eax
80100f75:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100f79:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f86:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f8d:	89 04 24             	mov    %eax,(%esp)
80100f90:	e8 dd 74 00 00       	call   80108472 <copyout>
80100f95:	85 c0                	test   %eax,%eax
80100f97:	79 05                	jns    80100f9e <exec+0x376>
    goto bad;
80100f99:	e9 99 00 00 00       	jmp    80101037 <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100faa:	eb 13                	jmp    80100fbf <exec+0x397>
    if(*s == '/')
80100fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100faf:	8a 00                	mov    (%eax),%al
80100fb1:	3c 2f                	cmp    $0x2f,%al
80100fb3:	75 07                	jne    80100fbc <exec+0x394>
      last = s+1;
80100fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb8:	40                   	inc    %eax
80100fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fbc:	ff 45 f4             	incl   -0xc(%ebp)
80100fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc2:	8a 00                	mov    (%eax),%al
80100fc4:	84 c0                	test   %al,%al
80100fc6:	75 e4                	jne    80100fac <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fcb:	8d 50 6c             	lea    0x6c(%eax),%edx
80100fce:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100fd5:	00 
80100fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fdd:	89 14 24             	mov    %edx,(%esp)
80100fe0:	e8 dd 42 00 00       	call   801052c2 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fe5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe8:	8b 40 04             	mov    0x4(%eax),%eax
80100feb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100fee:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ff1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ff4:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100ff7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ffa:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ffd:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101002:	8b 40 18             	mov    0x18(%eax),%eax
80101005:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
8010100b:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
8010100e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101011:	8b 40 18             	mov    0x18(%eax),%eax
80101014:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101017:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
8010101a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010101d:	89 04 24             	mov    %eax,(%esp)
80101020:	e8 33 6d 00 00       	call   80107d58 <switchuvm>
  freevm(oldpgdir);
80101025:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101028:	89 04 24             	mov    %eax,(%esp)
8010102b:	e8 f4 71 00 00       	call   80108224 <freevm>
  return 0;
80101030:	b8 00 00 00 00       	mov    $0x0,%eax
80101035:	eb 2c                	jmp    80101063 <exec+0x43b>

 bad:
  if(pgdir)
80101037:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010103b:	74 0b                	je     80101048 <exec+0x420>
    freevm(pgdir);
8010103d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 dc 71 00 00       	call   80108224 <freevm>
  if(ip){
80101048:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010104c:	74 10                	je     8010105e <exec+0x436>
    iunlockput(ip);
8010104e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101051:	89 04 24             	mov    %eax,(%esp)
80101054:	e8 ec 0b 00 00       	call   80101c45 <iunlockput>
    end_op();
80101059:	e8 63 25 00 00       	call   801035c1 <end_op>
  }
  return -1;
8010105e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101063:	c9                   	leave  
80101064:	c3                   	ret    
80101065:	00 00                	add    %al,(%eax)
	...

80101068 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101068:	55                   	push   %ebp
80101069:	89 e5                	mov    %esp,%ebp
8010106b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010106e:	c7 44 24 04 ab 89 10 	movl   $0x801089ab,0x4(%esp)
80101075:	80 
80101076:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
8010107d:	e8 b0 3d 00 00       	call   80104e32 <initlock>
}
80101082:	c9                   	leave  
80101083:	c3                   	ret    

80101084 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101084:	55                   	push   %ebp
80101085:	89 e5                	mov    %esp,%ebp
80101087:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010108a:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101091:	e8 bd 3d 00 00       	call   80104e53 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101096:	c7 45 f4 14 23 11 80 	movl   $0x80112314,-0xc(%ebp)
8010109d:	eb 29                	jmp    801010c8 <filealloc+0x44>
    if(f->ref == 0){
8010109f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a2:	8b 40 04             	mov    0x4(%eax),%eax
801010a5:	85 c0                	test   %eax,%eax
801010a7:	75 1b                	jne    801010c4 <filealloc+0x40>
      f->ref = 1;
801010a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010ac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010b3:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801010ba:	e8 fe 3d 00 00       	call   80104ebd <release>
      return f;
801010bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010c2:	eb 1e                	jmp    801010e2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010c4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010c8:	81 7d f4 74 2c 11 80 	cmpl   $0x80112c74,-0xc(%ebp)
801010cf:	72 ce                	jb     8010109f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801010d1:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801010d8:	e8 e0 3d 00 00       	call   80104ebd <release>
  return 0;
801010dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010e2:	c9                   	leave  
801010e3:	c3                   	ret    

801010e4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010e4:	55                   	push   %ebp
801010e5:	89 e5                	mov    %esp,%ebp
801010e7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801010ea:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801010f1:	e8 5d 3d 00 00       	call   80104e53 <acquire>
  if(f->ref < 1)
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 40 04             	mov    0x4(%eax),%eax
801010fc:	85 c0                	test   %eax,%eax
801010fe:	7f 0c                	jg     8010110c <filedup+0x28>
    panic("filedup");
80101100:	c7 04 24 b2 89 10 80 	movl   $0x801089b2,(%esp)
80101107:	e8 48 f4 ff ff       	call   80100554 <panic>
  f->ref++;
8010110c:	8b 45 08             	mov    0x8(%ebp),%eax
8010110f:	8b 40 04             	mov    0x4(%eax),%eax
80101112:	8d 50 01             	lea    0x1(%eax),%edx
80101115:	8b 45 08             	mov    0x8(%ebp),%eax
80101118:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010111b:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101122:	e8 96 3d 00 00       	call   80104ebd <release>
  return f;
80101127:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010112a:	c9                   	leave  
8010112b:	c3                   	ret    

8010112c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010112c:	55                   	push   %ebp
8010112d:	89 e5                	mov    %esp,%ebp
8010112f:	57                   	push   %edi
80101130:	56                   	push   %esi
80101131:	53                   	push   %ebx
80101132:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
80101135:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
8010113c:	e8 12 3d 00 00       	call   80104e53 <acquire>
  if(f->ref < 1)
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 40 04             	mov    0x4(%eax),%eax
80101147:	85 c0                	test   %eax,%eax
80101149:	7f 0c                	jg     80101157 <fileclose+0x2b>
    panic("fileclose");
8010114b:	c7 04 24 ba 89 10 80 	movl   $0x801089ba,(%esp)
80101152:	e8 fd f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 04             	mov    0x4(%eax),%eax
8010115d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101160:	8b 45 08             	mov    0x8(%ebp),%eax
80101163:	89 50 04             	mov    %edx,0x4(%eax)
80101166:	8b 45 08             	mov    0x8(%ebp),%eax
80101169:	8b 40 04             	mov    0x4(%eax),%eax
8010116c:	85 c0                	test   %eax,%eax
8010116e:	7e 0e                	jle    8010117e <fileclose+0x52>
    release(&ftable.lock);
80101170:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101177:	e8 41 3d 00 00       	call   80104ebd <release>
8010117c:	eb 70                	jmp    801011ee <fileclose+0xc2>
    return;
  }
  ff = *f;
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	8d 55 d0             	lea    -0x30(%ebp),%edx
80101184:	89 c3                	mov    %eax,%ebx
80101186:	b8 06 00 00 00       	mov    $0x6,%eax
8010118b:	89 d7                	mov    %edx,%edi
8010118d:	89 de                	mov    %ebx,%esi
8010118f:	89 c1                	mov    %eax,%ecx
80101191:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011a6:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801011ad:	e8 0b 3d 00 00       	call   80104ebd <release>

  if(ff.type == FD_PIPE)
801011b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011b5:	83 f8 01             	cmp    $0x1,%eax
801011b8:	75 17                	jne    801011d1 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
801011ba:	8a 45 d9             	mov    -0x27(%ebp),%al
801011bd:	0f be d0             	movsbl %al,%edx
801011c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801011c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801011c7:	89 04 24             	mov    %eax,(%esp)
801011ca:	e8 00 2d 00 00       	call   80103ecf <pipeclose>
801011cf:	eb 1d                	jmp    801011ee <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801011d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011d4:	83 f8 02             	cmp    $0x2,%eax
801011d7:	75 15                	jne    801011ee <fileclose+0xc2>
    begin_op();
801011d9:	e8 61 23 00 00       	call   8010353f <begin_op>
    iput(ff.ip);
801011de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011e1:	89 04 24             	mov    %eax,(%esp)
801011e4:	e8 ab 09 00 00       	call   80101b94 <iput>
    end_op();
801011e9:	e8 d3 23 00 00       	call   801035c1 <end_op>
  }
}
801011ee:	83 c4 3c             	add    $0x3c,%esp
801011f1:	5b                   	pop    %ebx
801011f2:	5e                   	pop    %esi
801011f3:	5f                   	pop    %edi
801011f4:	5d                   	pop    %ebp
801011f5:	c3                   	ret    

801011f6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011f6:	55                   	push   %ebp
801011f7:	89 e5                	mov    %esp,%ebp
801011f9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8b 00                	mov    (%eax),%eax
80101201:	83 f8 02             	cmp    $0x2,%eax
80101204:	75 38                	jne    8010123e <filestat+0x48>
    ilock(f->ip);
80101206:	8b 45 08             	mov    0x8(%ebp),%eax
80101209:	8b 40 10             	mov    0x10(%eax),%eax
8010120c:	89 04 24             	mov    %eax,(%esp)
8010120f:	e8 32 08 00 00       	call   80101a46 <ilock>
    stati(f->ip, st);
80101214:	8b 45 08             	mov    0x8(%ebp),%eax
80101217:	8b 40 10             	mov    0x10(%eax),%eax
8010121a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010121d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101221:	89 04 24             	mov    %eax,(%esp)
80101224:	e8 70 0c 00 00       	call   80101e99 <stati>
    iunlock(f->ip);
80101229:	8b 45 08             	mov    0x8(%ebp),%eax
8010122c:	8b 40 10             	mov    0x10(%eax),%eax
8010122f:	89 04 24             	mov    %eax,(%esp)
80101232:	e8 19 09 00 00       	call   80101b50 <iunlock>
    return 0;
80101237:	b8 00 00 00 00       	mov    $0x0,%eax
8010123c:	eb 05                	jmp    80101243 <filestat+0x4d>
  }
  return -1;
8010123e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101243:	c9                   	leave  
80101244:	c3                   	ret    

80101245 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101245:	55                   	push   %ebp
80101246:	89 e5                	mov    %esp,%ebp
80101248:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010124b:	8b 45 08             	mov    0x8(%ebp),%eax
8010124e:	8a 40 08             	mov    0x8(%eax),%al
80101251:	84 c0                	test   %al,%al
80101253:	75 0a                	jne    8010125f <fileread+0x1a>
    return -1;
80101255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010125a:	e9 9f 00 00 00       	jmp    801012fe <fileread+0xb9>
  if(f->type == FD_PIPE)
8010125f:	8b 45 08             	mov    0x8(%ebp),%eax
80101262:	8b 00                	mov    (%eax),%eax
80101264:	83 f8 01             	cmp    $0x1,%eax
80101267:	75 1e                	jne    80101287 <fileread+0x42>
    return piperead(f->pipe, addr, n);
80101269:	8b 45 08             	mov    0x8(%ebp),%eax
8010126c:	8b 40 0c             	mov    0xc(%eax),%eax
8010126f:	8b 55 10             	mov    0x10(%ebp),%edx
80101272:	89 54 24 08          	mov    %edx,0x8(%esp)
80101276:	8b 55 0c             	mov    0xc(%ebp),%edx
80101279:	89 54 24 04          	mov    %edx,0x4(%esp)
8010127d:	89 04 24             	mov    %eax,(%esp)
80101280:	e8 c8 2d 00 00       	call   8010404d <piperead>
80101285:	eb 77                	jmp    801012fe <fileread+0xb9>
  if(f->type == FD_INODE){
80101287:	8b 45 08             	mov    0x8(%ebp),%eax
8010128a:	8b 00                	mov    (%eax),%eax
8010128c:	83 f8 02             	cmp    $0x2,%eax
8010128f:	75 61                	jne    801012f2 <fileread+0xad>
    ilock(f->ip);
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 40 10             	mov    0x10(%eax),%eax
80101297:	89 04 24             	mov    %eax,(%esp)
8010129a:	e8 a7 07 00 00       	call   80101a46 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010129f:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012a2:	8b 45 08             	mov    0x8(%ebp),%eax
801012a5:	8b 50 14             	mov    0x14(%eax),%edx
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 40 10             	mov    0x10(%eax),%eax
801012ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801012b2:	89 54 24 08          	mov    %edx,0x8(%esp)
801012b6:	8b 55 0c             	mov    0xc(%ebp),%edx
801012b9:	89 54 24 04          	mov    %edx,0x4(%esp)
801012bd:	89 04 24             	mov    %eax,(%esp)
801012c0:	e8 18 0c 00 00       	call   80101edd <readi>
801012c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012cc:	7e 11                	jle    801012df <fileread+0x9a>
      f->off += r;
801012ce:	8b 45 08             	mov    0x8(%ebp),%eax
801012d1:	8b 50 14             	mov    0x14(%eax),%edx
801012d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d7:	01 c2                	add    %eax,%edx
801012d9:	8b 45 08             	mov    0x8(%ebp),%eax
801012dc:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 40 10             	mov    0x10(%eax),%eax
801012e5:	89 04 24             	mov    %eax,(%esp)
801012e8:	e8 63 08 00 00       	call   80101b50 <iunlock>
    return r;
801012ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012f0:	eb 0c                	jmp    801012fe <fileread+0xb9>
  }
  panic("fileread");
801012f2:	c7 04 24 c4 89 10 80 	movl   $0x801089c4,(%esp)
801012f9:	e8 56 f2 ff ff       	call   80100554 <panic>
}
801012fe:	c9                   	leave  
801012ff:	c3                   	ret    

80101300 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101300:	55                   	push   %ebp
80101301:	89 e5                	mov    %esp,%ebp
80101303:	53                   	push   %ebx
80101304:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101307:	8b 45 08             	mov    0x8(%ebp),%eax
8010130a:	8a 40 09             	mov    0x9(%eax),%al
8010130d:	84 c0                	test   %al,%al
8010130f:	75 0a                	jne    8010131b <filewrite+0x1b>
    return -1;
80101311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101316:	e9 20 01 00 00       	jmp    8010143b <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010131b:	8b 45 08             	mov    0x8(%ebp),%eax
8010131e:	8b 00                	mov    (%eax),%eax
80101320:	83 f8 01             	cmp    $0x1,%eax
80101323:	75 21                	jne    80101346 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
80101325:	8b 45 08             	mov    0x8(%ebp),%eax
80101328:	8b 40 0c             	mov    0xc(%eax),%eax
8010132b:	8b 55 10             	mov    0x10(%ebp),%edx
8010132e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101332:	8b 55 0c             	mov    0xc(%ebp),%edx
80101335:	89 54 24 04          	mov    %edx,0x4(%esp)
80101339:	89 04 24             	mov    %eax,(%esp)
8010133c:	e8 20 2c 00 00       	call   80103f61 <pipewrite>
80101341:	e9 f5 00 00 00       	jmp    8010143b <filewrite+0x13b>
  if(f->type == FD_INODE){
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
80101349:	8b 00                	mov    (%eax),%eax
8010134b:	83 f8 02             	cmp    $0x2,%eax
8010134e:	0f 85 db 00 00 00    	jne    8010142f <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101354:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010135b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101362:	e9 a8 00 00 00       	jmp    8010140f <filewrite+0x10f>
      int n1 = n - i;
80101367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136a:	8b 55 10             	mov    0x10(%ebp),%edx
8010136d:	29 c2                	sub    %eax,%edx
8010136f:	89 d0                	mov    %edx,%eax
80101371:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101377:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010137a:	7e 06                	jle    80101382 <filewrite+0x82>
        n1 = max;
8010137c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010137f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101382:	e8 b8 21 00 00       	call   8010353f <begin_op>
      ilock(f->ip);
80101387:	8b 45 08             	mov    0x8(%ebp),%eax
8010138a:	8b 40 10             	mov    0x10(%eax),%eax
8010138d:	89 04 24             	mov    %eax,(%esp)
80101390:	e8 b1 06 00 00       	call   80101a46 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101395:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101398:	8b 45 08             	mov    0x8(%ebp),%eax
8010139b:	8b 50 14             	mov    0x14(%eax),%edx
8010139e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801013a4:	01 c3                	add    %eax,%ebx
801013a6:	8b 45 08             	mov    0x8(%ebp),%eax
801013a9:	8b 40 10             	mov    0x10(%eax),%eax
801013ac:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801013b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801013b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801013b8:	89 04 24             	mov    %eax,(%esp)
801013bb:	e8 81 0c 00 00       	call   80102041 <writei>
801013c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013c7:	7e 11                	jle    801013da <filewrite+0xda>
        f->off += r;
801013c9:	8b 45 08             	mov    0x8(%ebp),%eax
801013cc:	8b 50 14             	mov    0x14(%eax),%edx
801013cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d2:	01 c2                	add    %eax,%edx
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013da:	8b 45 08             	mov    0x8(%ebp),%eax
801013dd:	8b 40 10             	mov    0x10(%eax),%eax
801013e0:	89 04 24             	mov    %eax,(%esp)
801013e3:	e8 68 07 00 00       	call   80101b50 <iunlock>
      end_op();
801013e8:	e8 d4 21 00 00       	call   801035c1 <end_op>

      if(r < 0)
801013ed:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013f1:	79 02                	jns    801013f5 <filewrite+0xf5>
        break;
801013f3:	eb 26                	jmp    8010141b <filewrite+0x11b>
      if(r != n1)
801013f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013fb:	74 0c                	je     80101409 <filewrite+0x109>
        panic("short filewrite");
801013fd:	c7 04 24 cd 89 10 80 	movl   $0x801089cd,(%esp)
80101404:	e8 4b f1 ff ff       	call   80100554 <panic>
      i += r;
80101409:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010140c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101412:	3b 45 10             	cmp    0x10(%ebp),%eax
80101415:	0f 8c 4c ff ff ff    	jl     80101367 <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101421:	75 05                	jne    80101428 <filewrite+0x128>
80101423:	8b 45 10             	mov    0x10(%ebp),%eax
80101426:	eb 05                	jmp    8010142d <filewrite+0x12d>
80101428:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010142d:	eb 0c                	jmp    8010143b <filewrite+0x13b>
  }
  panic("filewrite");
8010142f:	c7 04 24 dd 89 10 80 	movl   $0x801089dd,(%esp)
80101436:	e8 19 f1 ff ff       	call   80100554 <panic>
}
8010143b:	83 c4 24             	add    $0x24,%esp
8010143e:	5b                   	pop    %ebx
8010143f:	5d                   	pop    %ebp
80101440:	c3                   	ret    
80101441:	00 00                	add    %al,(%eax)
	...

80101444 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101444:	55                   	push   %ebp
80101445:	89 e5                	mov    %esp,%ebp
80101447:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010144a:	8b 45 08             	mov    0x8(%ebp),%eax
8010144d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101454:	00 
80101455:	89 04 24             	mov    %eax,(%esp)
80101458:	e8 58 ed ff ff       	call   801001b5 <bread>
8010145d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101463:	83 c0 5c             	add    $0x5c,%eax
80101466:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
8010146d:	00 
8010146e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101472:	8b 45 0c             	mov    0xc(%ebp),%eax
80101475:	89 04 24             	mov    %eax,(%esp)
80101478:	e8 02 3d 00 00       	call   8010517f <memmove>
  brelse(bp);
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	89 04 24             	mov    %eax,(%esp)
80101483:	e8 a4 ed ff ff       	call   8010022c <brelse>
}
80101488:	c9                   	leave  
80101489:	c3                   	ret    

8010148a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010148a:	55                   	push   %ebp
8010148b:	89 e5                	mov    %esp,%ebp
8010148d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101490:	8b 55 0c             	mov    0xc(%ebp),%edx
80101493:	8b 45 08             	mov    0x8(%ebp),%eax
80101496:	89 54 24 04          	mov    %edx,0x4(%esp)
8010149a:	89 04 24             	mov    %eax,(%esp)
8010149d:	e8 13 ed ff ff       	call   801001b5 <bread>
801014a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a8:	83 c0 5c             	add    $0x5c,%eax
801014ab:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801014b2:	00 
801014b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801014ba:	00 
801014bb:	89 04 24             	mov    %eax,(%esp)
801014be:	e8 f3 3b 00 00       	call   801050b6 <memset>
  log_write(bp);
801014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c6:	89 04 24             	mov    %eax,(%esp)
801014c9:	e8 75 22 00 00       	call   80103743 <log_write>
  brelse(bp);
801014ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d1:	89 04 24             	mov    %eax,(%esp)
801014d4:	e8 53 ed ff ff       	call   8010022c <brelse>
}
801014d9:	c9                   	leave  
801014da:	c3                   	ret    

801014db <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014db:	55                   	push   %ebp
801014dc:	89 e5                	mov    %esp,%ebp
801014de:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014ef:	e9 03 01 00 00       	jmp    801015f7 <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
801014f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014f7:	85 c0                	test   %eax,%eax
801014f9:	79 05                	jns    80101500 <balloc+0x25>
801014fb:	05 ff 0f 00 00       	add    $0xfff,%eax
80101500:	c1 f8 0c             	sar    $0xc,%eax
80101503:	89 c2                	mov    %eax,%edx
80101505:	a1 f8 2c 11 80       	mov    0x80112cf8,%eax
8010150a:	01 d0                	add    %edx,%eax
8010150c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101510:	8b 45 08             	mov    0x8(%ebp),%eax
80101513:	89 04 24             	mov    %eax,(%esp)
80101516:	e8 9a ec ff ff       	call   801001b5 <bread>
8010151b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010151e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101525:	e9 9b 00 00 00       	jmp    801015c5 <balloc+0xea>
      m = 1 << (bi % 8);
8010152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152d:	25 07 00 00 80       	and    $0x80000007,%eax
80101532:	85 c0                	test   %eax,%eax
80101534:	79 05                	jns    8010153b <balloc+0x60>
80101536:	48                   	dec    %eax
80101537:	83 c8 f8             	or     $0xfffffff8,%eax
8010153a:	40                   	inc    %eax
8010153b:	ba 01 00 00 00       	mov    $0x1,%edx
80101540:	88 c1                	mov    %al,%cl
80101542:	d3 e2                	shl    %cl,%edx
80101544:	89 d0                	mov    %edx,%eax
80101546:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154c:	85 c0                	test   %eax,%eax
8010154e:	79 03                	jns    80101553 <balloc+0x78>
80101550:	83 c0 07             	add    $0x7,%eax
80101553:	c1 f8 03             	sar    $0x3,%eax
80101556:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101559:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
8010155d:	0f b6 c0             	movzbl %al,%eax
80101560:	23 45 e8             	and    -0x18(%ebp),%eax
80101563:	85 c0                	test   %eax,%eax
80101565:	75 5b                	jne    801015c2 <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156a:	85 c0                	test   %eax,%eax
8010156c:	79 03                	jns    80101571 <balloc+0x96>
8010156e:	83 c0 07             	add    $0x7,%eax
80101571:	c1 f8 03             	sar    $0x3,%eax
80101574:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101577:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010157b:	88 d1                	mov    %dl,%cl
8010157d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101580:	09 ca                	or     %ecx,%edx
80101582:	88 d1                	mov    %dl,%cl
80101584:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101587:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010158b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010158e:	89 04 24             	mov    %eax,(%esp)
80101591:	e8 ad 21 00 00       	call   80103743 <log_write>
        brelse(bp);
80101596:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101599:	89 04 24             	mov    %eax,(%esp)
8010159c:	e8 8b ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
801015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a7:	01 c2                	add    %eax,%edx
801015a9:	8b 45 08             	mov    0x8(%ebp),%eax
801015ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801015b0:	89 04 24             	mov    %eax,(%esp)
801015b3:	e8 d2 fe ff ff       	call   8010148a <bzero>
        return b + bi;
801015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015be:	01 d0                	add    %edx,%eax
801015c0:	eb 51                	jmp    80101613 <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c2:	ff 45 f0             	incl   -0x10(%ebp)
801015c5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015cc:	7f 17                	jg     801015e5 <balloc+0x10a>
801015ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d4:	01 d0                	add    %edx,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	a1 e0 2c 11 80       	mov    0x80112ce0,%eax
801015dd:	39 c2                	cmp    %eax,%edx
801015df:	0f 82 45 ff ff ff    	jb     8010152a <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015e8:	89 04 24             	mov    %eax,(%esp)
801015eb:	e8 3c ec ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015f0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015fa:	a1 e0 2c 11 80       	mov    0x80112ce0,%eax
801015ff:	39 c2                	cmp    %eax,%edx
80101601:	0f 82 ed fe ff ff    	jb     801014f4 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101607:	c7 04 24 e8 89 10 80 	movl   $0x801089e8,(%esp)
8010160e:	e8 41 ef ff ff       	call   80100554 <panic>
}
80101613:	c9                   	leave  
80101614:	c3                   	ret    

80101615 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101615:	55                   	push   %ebp
80101616:	89 e5                	mov    %esp,%ebp
80101618:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010161b:	c7 44 24 04 e0 2c 11 	movl   $0x80112ce0,0x4(%esp)
80101622:	80 
80101623:	8b 45 08             	mov    0x8(%ebp),%eax
80101626:	89 04 24             	mov    %eax,(%esp)
80101629:	e8 16 fe ff ff       	call   80101444 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010162e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101631:	c1 e8 0c             	shr    $0xc,%eax
80101634:	89 c2                	mov    %eax,%edx
80101636:	a1 f8 2c 11 80       	mov    0x80112cf8,%eax
8010163b:	01 c2                	add    %eax,%edx
8010163d:	8b 45 08             	mov    0x8(%ebp),%eax
80101640:	89 54 24 04          	mov    %edx,0x4(%esp)
80101644:	89 04 24             	mov    %eax,(%esp)
80101647:	e8 69 eb ff ff       	call   801001b5 <bread>
8010164c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010164f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101652:	25 ff 0f 00 00       	and    $0xfff,%eax
80101657:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165d:	25 07 00 00 80       	and    $0x80000007,%eax
80101662:	85 c0                	test   %eax,%eax
80101664:	79 05                	jns    8010166b <bfree+0x56>
80101666:	48                   	dec    %eax
80101667:	83 c8 f8             	or     $0xfffffff8,%eax
8010166a:	40                   	inc    %eax
8010166b:	ba 01 00 00 00       	mov    $0x1,%edx
80101670:	88 c1                	mov    %al,%cl
80101672:	d3 e2                	shl    %cl,%edx
80101674:	89 d0                	mov    %edx,%eax
80101676:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167c:	85 c0                	test   %eax,%eax
8010167e:	79 03                	jns    80101683 <bfree+0x6e>
80101680:	83 c0 07             	add    $0x7,%eax
80101683:	c1 f8 03             	sar    $0x3,%eax
80101686:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101689:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
8010168d:	0f b6 c0             	movzbl %al,%eax
80101690:	23 45 ec             	and    -0x14(%ebp),%eax
80101693:	85 c0                	test   %eax,%eax
80101695:	75 0c                	jne    801016a3 <bfree+0x8e>
    panic("freeing free block");
80101697:	c7 04 24 fe 89 10 80 	movl   $0x801089fe,(%esp)
8010169e:	e8 b1 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
801016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a6:	85 c0                	test   %eax,%eax
801016a8:	79 03                	jns    801016ad <bfree+0x98>
801016aa:	83 c0 07             	add    $0x7,%eax
801016ad:	c1 f8 03             	sar    $0x3,%eax
801016b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b3:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801016b7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801016ba:	f7 d1                	not    %ecx
801016bc:	21 ca                	and    %ecx,%edx
801016be:	88 d1                	mov    %dl,%cl
801016c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ca:	89 04 24             	mov    %eax,(%esp)
801016cd:	e8 71 20 00 00       	call   80103743 <log_write>
  brelse(bp);
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	89 04 24             	mov    %eax,(%esp)
801016d8:	e8 4f eb ff ff       	call   8010022c <brelse>
}
801016dd:	c9                   	leave  
801016de:	c3                   	ret    

801016df <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016df:	55                   	push   %ebp
801016e0:	89 e5                	mov    %esp,%ebp
801016e2:	57                   	push   %edi
801016e3:	56                   	push   %esi
801016e4:	53                   	push   %ebx
801016e5:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801016e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016ef:	c7 44 24 04 11 8a 10 	movl   $0x80108a11,0x4(%esp)
801016f6:	80 
801016f7:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
801016fe:	e8 2f 37 00 00       	call   80104e32 <initlock>
  for(i = 0; i < NINODE; i++) {
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010170a:	eb 2b                	jmp    80101737 <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
8010170c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010170f:	89 d0                	mov    %edx,%eax
80101711:	c1 e0 03             	shl    $0x3,%eax
80101714:	01 d0                	add    %edx,%eax
80101716:	c1 e0 04             	shl    $0x4,%eax
80101719:	83 c0 30             	add    $0x30,%eax
8010171c:	05 00 2d 11 80       	add    $0x80112d00,%eax
80101721:	83 c0 10             	add    $0x10,%eax
80101724:	c7 44 24 04 18 8a 10 	movl   $0x80108a18,0x4(%esp)
8010172b:	80 
8010172c:	89 04 24             	mov    %eax,(%esp)
8010172f:	e8 c0 35 00 00       	call   80104cf4 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101734:	ff 45 e4             	incl   -0x1c(%ebp)
80101737:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010173b:	7e cf                	jle    8010170c <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
8010173d:	c7 44 24 04 e0 2c 11 	movl   $0x80112ce0,0x4(%esp)
80101744:	80 
80101745:	8b 45 08             	mov    0x8(%ebp),%eax
80101748:	89 04 24             	mov    %eax,(%esp)
8010174b:	e8 f4 fc ff ff       	call   80101444 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101750:	a1 f8 2c 11 80       	mov    0x80112cf8,%eax
80101755:	8b 3d f4 2c 11 80    	mov    0x80112cf4,%edi
8010175b:	8b 35 f0 2c 11 80    	mov    0x80112cf0,%esi
80101761:	8b 1d ec 2c 11 80    	mov    0x80112cec,%ebx
80101767:	8b 0d e8 2c 11 80    	mov    0x80112ce8,%ecx
8010176d:	8b 15 e4 2c 11 80    	mov    0x80112ce4,%edx
80101773:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101776:	8b 15 e0 2c 11 80    	mov    0x80112ce0,%edx
8010177c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101780:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101784:	89 74 24 14          	mov    %esi,0x14(%esp)
80101788:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010178c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101790:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101793:	89 44 24 08          	mov    %eax,0x8(%esp)
80101797:	89 d0                	mov    %edx,%eax
80101799:	89 44 24 04          	mov    %eax,0x4(%esp)
8010179d:	c7 04 24 20 8a 10 80 	movl   $0x80108a20,(%esp)
801017a4:	e8 18 ec ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017a9:	83 c4 4c             	add    $0x4c,%esp
801017ac:	5b                   	pop    %ebx
801017ad:	5e                   	pop    %esi
801017ae:	5f                   	pop    %edi
801017af:	5d                   	pop    %ebp
801017b0:	c3                   	ret    

801017b1 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017b1:	55                   	push   %ebp
801017b2:	89 e5                	mov    %esp,%ebp
801017b4:	83 ec 28             	sub    $0x28,%esp
801017b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801017ba:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017be:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017c5:	e9 9b 00 00 00       	jmp    80101865 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801017ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cd:	c1 e8 03             	shr    $0x3,%eax
801017d0:	89 c2                	mov    %eax,%edx
801017d2:	a1 f4 2c 11 80       	mov    0x80112cf4,%eax
801017d7:	01 d0                	add    %edx,%eax
801017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801017dd:	8b 45 08             	mov    0x8(%ebp),%eax
801017e0:	89 04 24             	mov    %eax,(%esp)
801017e3:	e8 cd e9 ff ff       	call   801001b5 <bread>
801017e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ee:	8d 50 5c             	lea    0x5c(%eax),%edx
801017f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f4:	83 e0 07             	and    $0x7,%eax
801017f7:	c1 e0 06             	shl    $0x6,%eax
801017fa:	01 d0                	add    %edx,%eax
801017fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101802:	8b 00                	mov    (%eax),%eax
80101804:	66 85 c0             	test   %ax,%ax
80101807:	75 4e                	jne    80101857 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
80101809:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101810:	00 
80101811:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101818:	00 
80101819:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010181c:	89 04 24             	mov    %eax,(%esp)
8010181f:	e8 92 38 00 00       	call   801050b6 <memset>
      dip->type = type;
80101824:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101827:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010182a:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101830:	89 04 24             	mov    %eax,(%esp)
80101833:	e8 0b 1f 00 00       	call   80103743 <log_write>
      brelse(bp);
80101838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183b:	89 04 24             	mov    %eax,(%esp)
8010183e:	e8 e9 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101846:	89 44 24 04          	mov    %eax,0x4(%esp)
8010184a:	8b 45 08             	mov    0x8(%ebp),%eax
8010184d:	89 04 24             	mov    %eax,(%esp)
80101850:	e8 ea 00 00 00       	call   8010193f <iget>
80101855:	eb 2a                	jmp    80101881 <ialloc+0xd0>
    }
    brelse(bp);
80101857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185a:	89 04 24             	mov    %eax,(%esp)
8010185d:	e8 ca e9 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101862:	ff 45 f4             	incl   -0xc(%ebp)
80101865:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101868:	a1 e8 2c 11 80       	mov    0x80112ce8,%eax
8010186d:	39 c2                	cmp    %eax,%edx
8010186f:	0f 82 55 ff ff ff    	jb     801017ca <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101875:	c7 04 24 73 8a 10 80 	movl   $0x80108a73,(%esp)
8010187c:	e8 d3 ec ff ff       	call   80100554 <panic>
}
80101881:	c9                   	leave  
80101882:	c3                   	ret    

80101883 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101883:	55                   	push   %ebp
80101884:	89 e5                	mov    %esp,%ebp
80101886:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101889:	8b 45 08             	mov    0x8(%ebp),%eax
8010188c:	8b 40 04             	mov    0x4(%eax),%eax
8010188f:	c1 e8 03             	shr    $0x3,%eax
80101892:	89 c2                	mov    %eax,%edx
80101894:	a1 f4 2c 11 80       	mov    0x80112cf4,%eax
80101899:	01 c2                	add    %eax,%edx
8010189b:	8b 45 08             	mov    0x8(%ebp),%eax
8010189e:	8b 00                	mov    (%eax),%eax
801018a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801018a4:	89 04 24             	mov    %eax,(%esp)
801018a7:	e8 09 e9 ff ff       	call   801001b5 <bread>
801018ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b2:	8d 50 5c             	lea    0x5c(%eax),%edx
801018b5:	8b 45 08             	mov    0x8(%ebp),%eax
801018b8:	8b 40 04             	mov    0x4(%eax),%eax
801018bb:	83 e0 07             	and    $0x7,%eax
801018be:	c1 e0 06             	shl    $0x6,%eax
801018c1:	01 d0                	add    %edx,%eax
801018c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	8b 40 50             	mov    0x50(%eax),%eax
801018cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018cf:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801018d2:	8b 45 08             	mov    0x8(%ebp),%eax
801018d5:	66 8b 40 52          	mov    0x52(%eax),%ax
801018d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018dc:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801018e0:	8b 45 08             	mov    0x8(%ebp),%eax
801018e3:	8b 40 54             	mov    0x54(%eax),%eax
801018e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018e9:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801018ed:	8b 45 08             	mov    0x8(%ebp),%eax
801018f0:	66 8b 40 56          	mov    0x56(%eax),%ax
801018f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018f7:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801018fb:	8b 45 08             	mov    0x8(%ebp),%eax
801018fe:	8b 50 58             	mov    0x58(%eax),%edx
80101901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101904:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101907:	8b 45 08             	mov    0x8(%ebp),%eax
8010190a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101910:	83 c0 0c             	add    $0xc,%eax
80101913:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010191a:	00 
8010191b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010191f:	89 04 24             	mov    %eax,(%esp)
80101922:	e8 58 38 00 00       	call   8010517f <memmove>
  log_write(bp);
80101927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192a:	89 04 24             	mov    %eax,(%esp)
8010192d:	e8 11 1e 00 00       	call   80103743 <log_write>
  brelse(bp);
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	89 04 24             	mov    %eax,(%esp)
80101938:	e8 ef e8 ff ff       	call   8010022c <brelse>
}
8010193d:	c9                   	leave  
8010193e:	c3                   	ret    

8010193f <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010193f:	55                   	push   %ebp
80101940:	89 e5                	mov    %esp,%ebp
80101942:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101945:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
8010194c:	e8 02 35 00 00       	call   80104e53 <acquire>

  // Is the inode already cached?
  empty = 0;
80101951:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101958:	c7 45 f4 34 2d 11 80 	movl   $0x80112d34,-0xc(%ebp)
8010195f:	eb 5c                	jmp    801019bd <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101964:	8b 40 08             	mov    0x8(%eax),%eax
80101967:	85 c0                	test   %eax,%eax
80101969:	7e 35                	jle    801019a0 <iget+0x61>
8010196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196e:	8b 00                	mov    (%eax),%eax
80101970:	3b 45 08             	cmp    0x8(%ebp),%eax
80101973:	75 2b                	jne    801019a0 <iget+0x61>
80101975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101978:	8b 40 04             	mov    0x4(%eax),%eax
8010197b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010197e:	75 20                	jne    801019a0 <iget+0x61>
      ip->ref++;
80101980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101983:	8b 40 08             	mov    0x8(%eax),%eax
80101986:	8d 50 01             	lea    0x1(%eax),%edx
80101989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010198f:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101996:	e8 22 35 00 00       	call   80104ebd <release>
      return ip;
8010199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199e:	eb 72                	jmp    80101a12 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019a4:	75 10                	jne    801019b6 <iget+0x77>
801019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a9:	8b 40 08             	mov    0x8(%eax),%eax
801019ac:	85 c0                	test   %eax,%eax
801019ae:	75 06                	jne    801019b6 <iget+0x77>
      empty = ip;
801019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019b6:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019bd:	81 7d f4 54 49 11 80 	cmpl   $0x80114954,-0xc(%ebp)
801019c4:	72 9b                	jb     80101961 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ca:	75 0c                	jne    801019d8 <iget+0x99>
    panic("iget: no inodes");
801019cc:	c7 04 24 85 8a 10 80 	movl   $0x80108a85,(%esp)
801019d3:	e8 7c eb ff ff       	call   80100554 <panic>

  ip = empty;
801019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e1:	8b 55 08             	mov    0x8(%ebp),%edx
801019e4:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801019ec:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fc:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a03:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101a0a:	e8 ae 34 00 00       	call   80104ebd <release>

  return ip;
80101a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a12:	c9                   	leave  
80101a13:	c3                   	ret    

80101a14 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a14:	55                   	push   %ebp
80101a15:	89 e5                	mov    %esp,%ebp
80101a17:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a1a:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101a21:	e8 2d 34 00 00       	call   80104e53 <acquire>
  ip->ref++;
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	8b 40 08             	mov    0x8(%eax),%eax
80101a2c:	8d 50 01             	lea    0x1(%eax),%edx
80101a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a32:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a35:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101a3c:	e8 7c 34 00 00       	call   80104ebd <release>
  return ip;
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a44:	c9                   	leave  
80101a45:	c3                   	ret    

80101a46 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a46:	55                   	push   %ebp
80101a47:	89 e5                	mov    %esp,%ebp
80101a49:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a50:	74 0a                	je     80101a5c <ilock+0x16>
80101a52:	8b 45 08             	mov    0x8(%ebp),%eax
80101a55:	8b 40 08             	mov    0x8(%eax),%eax
80101a58:	85 c0                	test   %eax,%eax
80101a5a:	7f 0c                	jg     80101a68 <ilock+0x22>
    panic("ilock");
80101a5c:	c7 04 24 95 8a 10 80 	movl   $0x80108a95,(%esp)
80101a63:	e8 ec ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101a68:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6b:	83 c0 0c             	add    $0xc,%eax
80101a6e:	89 04 24             	mov    %eax,(%esp)
80101a71:	e8 b8 32 00 00       	call   80104d2e <acquiresleep>

  if(ip->valid == 0){
80101a76:	8b 45 08             	mov    0x8(%ebp),%eax
80101a79:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a7c:	85 c0                	test   %eax,%eax
80101a7e:	0f 85 ca 00 00 00    	jne    80101b4e <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	8b 40 04             	mov    0x4(%eax),%eax
80101a8a:	c1 e8 03             	shr    $0x3,%eax
80101a8d:	89 c2                	mov    %eax,%edx
80101a8f:	a1 f4 2c 11 80       	mov    0x80112cf4,%eax
80101a94:	01 c2                	add    %eax,%edx
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	8b 00                	mov    (%eax),%eax
80101a9b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a9f:	89 04 24             	mov    %eax,(%esp)
80101aa2:	e8 0e e7 ff ff       	call   801001b5 <bread>
80101aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aad:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	8b 40 04             	mov    0x4(%eax),%eax
80101ab6:	83 e0 07             	and    $0x7,%eax
80101ab9:	c1 e0 06             	shl    $0x6,%eax
80101abc:	01 d0                	add    %edx,%eax
80101abe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac4:	8b 00                	mov    (%eax),%eax
80101ac6:	8b 55 08             	mov    0x8(%ebp),%edx
80101ac9:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad0:	66 8b 40 02          	mov    0x2(%eax),%ax
80101ad4:	8b 55 08             	mov    0x8(%ebp),%edx
80101ad7:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ade:	8b 40 04             	mov    0x4(%eax),%eax
80101ae1:	8b 55 08             	mov    0x8(%ebp),%edx
80101ae4:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aeb:	66 8b 40 06          	mov    0x6(%eax),%ax
80101aef:	8b 55 08             	mov    0x8(%ebp),%edx
80101af2:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af9:	8b 50 08             	mov    0x8(%eax),%edx
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b05:	8d 50 0c             	lea    0xc(%eax),%edx
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	83 c0 5c             	add    $0x5c,%eax
80101b0e:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101b15:	00 
80101b16:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b1a:	89 04 24             	mov    %eax,(%esp)
80101b1d:	e8 5d 36 00 00       	call   8010517f <memmove>
    brelse(bp);
80101b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b25:	89 04 24             	mov    %eax,(%esp)
80101b28:	e8 ff e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	8b 40 50             	mov    0x50(%eax),%eax
80101b3d:	66 85 c0             	test   %ax,%ax
80101b40:	75 0c                	jne    80101b4e <ilock+0x108>
      panic("ilock: no type");
80101b42:	c7 04 24 9b 8a 10 80 	movl   $0x80108a9b,(%esp)
80101b49:	e8 06 ea ff ff       	call   80100554 <panic>
  }
}
80101b4e:	c9                   	leave  
80101b4f:	c3                   	ret    

80101b50 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b50:	55                   	push   %ebp
80101b51:	89 e5                	mov    %esp,%ebp
80101b53:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b56:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b5a:	74 1c                	je     80101b78 <iunlock+0x28>
80101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5f:	83 c0 0c             	add    $0xc,%eax
80101b62:	89 04 24             	mov    %eax,(%esp)
80101b65:	e8 61 32 00 00       	call   80104dcb <holdingsleep>
80101b6a:	85 c0                	test   %eax,%eax
80101b6c:	74 0a                	je     80101b78 <iunlock+0x28>
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	8b 40 08             	mov    0x8(%eax),%eax
80101b74:	85 c0                	test   %eax,%eax
80101b76:	7f 0c                	jg     80101b84 <iunlock+0x34>
    panic("iunlock");
80101b78:	c7 04 24 aa 8a 10 80 	movl   $0x80108aaa,(%esp)
80101b7f:	e8 d0 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	83 c0 0c             	add    $0xc,%eax
80101b8a:	89 04 24             	mov    %eax,(%esp)
80101b8d:	e8 f7 31 00 00       	call   80104d89 <releasesleep>
}
80101b92:	c9                   	leave  
80101b93:	c3                   	ret    

80101b94 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b94:	55                   	push   %ebp
80101b95:	89 e5                	mov    %esp,%ebp
80101b97:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9d:	83 c0 0c             	add    $0xc,%eax
80101ba0:	89 04 24             	mov    %eax,(%esp)
80101ba3:	e8 86 31 00 00       	call   80104d2e <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bab:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bae:	85 c0                	test   %eax,%eax
80101bb0:	74 5c                	je     80101c0e <iput+0x7a>
80101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb5:	66 8b 40 56          	mov    0x56(%eax),%ax
80101bb9:	66 85 c0             	test   %ax,%ax
80101bbc:	75 50                	jne    80101c0e <iput+0x7a>
    acquire(&icache.lock);
80101bbe:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101bc5:	e8 89 32 00 00       	call   80104e53 <acquire>
    int r = ip->ref;
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	8b 40 08             	mov    0x8(%eax),%eax
80101bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bd3:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101bda:	e8 de 32 00 00       	call   80104ebd <release>
    if(r == 1){
80101bdf:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101be3:	75 29                	jne    80101c0e <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101be5:	8b 45 08             	mov    0x8(%ebp),%eax
80101be8:	89 04 24             	mov    %eax,(%esp)
80101beb:	e8 86 01 00 00       	call   80101d76 <itrunc>
      ip->type = 0;
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	89 04 24             	mov    %eax,(%esp)
80101bff:	e8 7f fc ff ff       	call   80101883 <iupdate>
      ip->valid = 0;
80101c04:	8b 45 08             	mov    0x8(%ebp),%eax
80101c07:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	83 c0 0c             	add    $0xc,%eax
80101c14:	89 04 24             	mov    %eax,(%esp)
80101c17:	e8 6d 31 00 00       	call   80104d89 <releasesleep>

  acquire(&icache.lock);
80101c1c:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101c23:	e8 2b 32 00 00       	call   80104e53 <acquire>
  ip->ref--;
80101c28:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2b:	8b 40 08             	mov    0x8(%eax),%eax
80101c2e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c31:	8b 45 08             	mov    0x8(%ebp),%eax
80101c34:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c37:	c7 04 24 00 2d 11 80 	movl   $0x80112d00,(%esp)
80101c3e:	e8 7a 32 00 00       	call   80104ebd <release>
}
80101c43:	c9                   	leave  
80101c44:	c3                   	ret    

80101c45 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c45:	55                   	push   %ebp
80101c46:	89 e5                	mov    %esp,%ebp
80101c48:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4e:	89 04 24             	mov    %eax,(%esp)
80101c51:	e8 fa fe ff ff       	call   80101b50 <iunlock>
  iput(ip);
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	89 04 24             	mov    %eax,(%esp)
80101c5c:	e8 33 ff ff ff       	call   80101b94 <iput>
}
80101c61:	c9                   	leave  
80101c62:	c3                   	ret    

80101c63 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c63:	55                   	push   %ebp
80101c64:	89 e5                	mov    %esp,%ebp
80101c66:	53                   	push   %ebx
80101c67:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c6a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c6e:	77 3e                	ja     80101cae <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c76:	83 c2 14             	add    $0x14,%edx
80101c79:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c80:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c84:	75 20                	jne    80101ca6 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 00                	mov    (%eax),%eax
80101c8b:	89 04 24             	mov    %eax,(%esp)
80101c8e:	e8 48 f8 ff ff       	call   801014db <balloc>
80101c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c9c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca2:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ca9:	e9 c2 00 00 00       	jmp    80101d70 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101cae:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cb2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cb6:	0f 87 a8 00 00 00    	ja     80101d64 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ccc:	75 1c                	jne    80101cea <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	89 04 24             	mov    %eax,(%esp)
80101cd6:	e8 00 f8 ff ff       	call   801014db <balloc>
80101cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ce4:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	8b 00                	mov    (%eax),%eax
80101cef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cf6:	89 04 24             	mov    %eax,(%esp)
80101cf9:	e8 b7 e4 ff ff       	call   801001b5 <bread>
80101cfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d04:	83 c0 5c             	add    $0x5c,%eax
80101d07:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d17:	01 d0                	add    %edx,%eax
80101d19:	8b 00                	mov    (%eax),%eax
80101d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d22:	75 30                	jne    80101d54 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d34:	8b 45 08             	mov    0x8(%ebp),%eax
80101d37:	8b 00                	mov    (%eax),%eax
80101d39:	89 04 24             	mov    %eax,(%esp)
80101d3c:	e8 9a f7 ff ff       	call   801014db <balloc>
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d47:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4c:	89 04 24             	mov    %eax,(%esp)
80101d4f:	e8 ef 19 00 00       	call   80103743 <log_write>
    }
    brelse(bp);
80101d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d57:	89 04 24             	mov    %eax,(%esp)
80101d5a:	e8 cd e4 ff ff       	call   8010022c <brelse>
    return addr;
80101d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d62:	eb 0c                	jmp    80101d70 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101d64:	c7 04 24 b2 8a 10 80 	movl   $0x80108ab2,(%esp)
80101d6b:	e8 e4 e7 ff ff       	call   80100554 <panic>
}
80101d70:	83 c4 24             	add    $0x24,%esp
80101d73:	5b                   	pop    %ebx
80101d74:	5d                   	pop    %ebp
80101d75:	c3                   	ret    

80101d76 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d76:	55                   	push   %ebp
80101d77:	89 e5                	mov    %esp,%ebp
80101d79:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d83:	eb 43                	jmp    80101dc8 <itrunc+0x52>
    if(ip->addrs[i]){
80101d85:	8b 45 08             	mov    0x8(%ebp),%eax
80101d88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8b:	83 c2 14             	add    $0x14,%edx
80101d8e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d92:	85 c0                	test   %eax,%eax
80101d94:	74 2f                	je     80101dc5 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9c:	83 c2 14             	add    $0x14,%edx
80101d9f:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101da3:	8b 45 08             	mov    0x8(%ebp),%eax
80101da6:	8b 00                	mov    (%eax),%eax
80101da8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dac:	89 04 24             	mov    %eax,(%esp)
80101daf:	e8 61 f8 ff ff       	call   80101615 <bfree>
      ip->addrs[i] = 0;
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dba:	83 c2 14             	add    $0x14,%edx
80101dbd:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dc4:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dc5:	ff 45 f4             	incl   -0xc(%ebp)
80101dc8:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dcc:	7e b7                	jle    80101d85 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dd7:	85 c0                	test   %eax,%eax
80101dd9:	0f 84 a3 00 00 00    	je     80101e82 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80101de2:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101de8:	8b 45 08             	mov    0x8(%ebp),%eax
80101deb:	8b 00                	mov    (%eax),%eax
80101ded:	89 54 24 04          	mov    %edx,0x4(%esp)
80101df1:	89 04 24             	mov    %eax,(%esp)
80101df4:	e8 bc e3 ff ff       	call   801001b5 <bread>
80101df9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dff:	83 c0 5c             	add    $0x5c,%eax
80101e02:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e05:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e0c:	eb 3a                	jmp    80101e48 <itrunc+0xd2>
      if(a[j])
80101e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e11:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1b:	01 d0                	add    %edx,%eax
80101e1d:	8b 00                	mov    (%eax),%eax
80101e1f:	85 c0                	test   %eax,%eax
80101e21:	74 22                	je     80101e45 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e30:	01 d0                	add    %edx,%eax
80101e32:	8b 10                	mov    (%eax),%edx
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	8b 00                	mov    (%eax),%eax
80101e39:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e3d:	89 04 24             	mov    %eax,(%esp)
80101e40:	e8 d0 f7 ff ff       	call   80101615 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e45:	ff 45 f0             	incl   -0x10(%ebp)
80101e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e4b:	83 f8 7f             	cmp    $0x7f,%eax
80101e4e:	76 be                	jbe    80101e0e <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e53:	89 04 24             	mov    %eax,(%esp)
80101e56:	e8 d1 e3 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 00                	mov    (%eax),%eax
80101e69:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e6d:	89 04 24             	mov    %eax,(%esp)
80101e70:	e8 a0 f7 ff ff       	call   80101615 <bfree>
    ip->addrs[NDIRECT] = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7f:	00 00 00 
  }

  ip->size = 0;
80101e82:	8b 45 08             	mov    0x8(%ebp),%eax
80101e85:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8f:	89 04 24             	mov    %eax,(%esp)
80101e92:	e8 ec f9 ff ff       	call   80101883 <iupdate>
}
80101e97:	c9                   	leave  
80101e98:	c3                   	ret    

80101e99 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e99:	55                   	push   %ebp
80101e9a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9f:	8b 00                	mov    (%eax),%eax
80101ea1:	89 c2                	mov    %eax,%edx
80101ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea6:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eac:	8b 50 04             	mov    0x4(%eax),%edx
80101eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb2:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb8:	8b 40 50             	mov    0x50(%eax),%eax
80101ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ebe:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	66 8b 40 56          	mov    0x56(%eax),%ax
80101ec8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ecb:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	5d                   	pop    %ebp
80101edc:	c3                   	ret    

80101edd <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101edd:	55                   	push   %ebp
80101ede:	89 e5                	mov    %esp,%ebp
80101ee0:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	8b 40 50             	mov    0x50(%eax),%eax
80101ee9:	66 83 f8 03          	cmp    $0x3,%ax
80101eed:	75 60                	jne    80101f4f <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef2:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ef6:	66 85 c0             	test   %ax,%ax
80101ef9:	78 20                	js     80101f1b <readi+0x3e>
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f02:	66 83 f8 09          	cmp    $0x9,%ax
80101f06:	7f 13                	jg     80101f1b <readi+0x3e>
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f0f:	98                   	cwtl   
80101f10:	8b 04 c5 80 2c 11 80 	mov    -0x7feed380(,%eax,8),%eax
80101f17:	85 c0                	test   %eax,%eax
80101f19:	75 0a                	jne    80101f25 <readi+0x48>
      return -1;
80101f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f20:	e9 1a 01 00 00       	jmp    8010203f <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f2c:	98                   	cwtl   
80101f2d:	8b 04 c5 80 2c 11 80 	mov    -0x7feed380(,%eax,8),%eax
80101f34:	8b 55 14             	mov    0x14(%ebp),%edx
80101f37:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f3e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f42:	8b 55 08             	mov    0x8(%ebp),%edx
80101f45:	89 14 24             	mov    %edx,(%esp)
80101f48:	ff d0                	call   *%eax
80101f4a:	e9 f0 00 00 00       	jmp    8010203f <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	8b 40 58             	mov    0x58(%eax),%eax
80101f55:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f58:	72 0d                	jb     80101f67 <readi+0x8a>
80101f5a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f60:	01 d0                	add    %edx,%eax
80101f62:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f65:	73 0a                	jae    80101f71 <readi+0x94>
    return -1;
80101f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6c:	e9 ce 00 00 00       	jmp    8010203f <readi+0x162>
  if(off + n > ip->size)
80101f71:	8b 45 14             	mov    0x14(%ebp),%eax
80101f74:	8b 55 10             	mov    0x10(%ebp),%edx
80101f77:	01 c2                	add    %eax,%edx
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	39 c2                	cmp    %eax,%edx
80101f81:	76 0c                	jbe    80101f8f <readi+0xb2>
    n = ip->size - off;
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	8b 40 58             	mov    0x58(%eax),%eax
80101f89:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8c:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f96:	e9 95 00 00 00       	jmp    80102030 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f9b:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9e:	c1 e8 09             	shr    $0x9,%eax
80101fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa8:	89 04 24             	mov    %eax,(%esp)
80101fab:	e8 b3 fc ff ff       	call   80101c63 <bmap>
80101fb0:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb3:	8b 12                	mov    (%edx),%edx
80101fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fb9:	89 14 24             	mov    %edx,(%esp)
80101fbc:	e8 f4 e1 ff ff       	call   801001b5 <bread>
80101fc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcc:	89 c2                	mov    %eax,%edx
80101fce:	b8 00 02 00 00       	mov    $0x200,%eax
80101fd3:	29 d0                	sub    %edx,%eax
80101fd5:	89 c1                	mov    %eax,%ecx
80101fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fda:	8b 55 14             	mov    0x14(%ebp),%edx
80101fdd:	29 c2                	sub    %eax,%edx
80101fdf:	89 c8                	mov    %ecx,%eax
80101fe1:	39 d0                	cmp    %edx,%eax
80101fe3:	76 02                	jbe    80101fe7 <readi+0x10a>
80101fe5:	89 d0                	mov    %edx,%eax
80101fe7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fea:	8b 45 10             	mov    0x10(%ebp),%eax
80101fed:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff2:	8d 50 50             	lea    0x50(%eax),%edx
80101ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff8:	01 d0                	add    %edx,%eax
80101ffa:	8d 50 0c             	lea    0xc(%eax),%edx
80101ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102000:	89 44 24 08          	mov    %eax,0x8(%esp)
80102004:	89 54 24 04          	mov    %edx,0x4(%esp)
80102008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 6c 31 00 00       	call   8010517f <memmove>
    brelse(bp);
80102013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102016:	89 04 24             	mov    %eax,(%esp)
80102019:	e8 0e e2 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010201e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102021:	01 45 f4             	add    %eax,-0xc(%ebp)
80102024:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102027:	01 45 10             	add    %eax,0x10(%ebp)
8010202a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202d:	01 45 0c             	add    %eax,0xc(%ebp)
80102030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102033:	3b 45 14             	cmp    0x14(%ebp),%eax
80102036:	0f 82 5f ff ff ff    	jb     80101f9b <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010203c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010203f:	c9                   	leave  
80102040:	c3                   	ret    

80102041 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102041:	55                   	push   %ebp
80102042:	89 e5                	mov    %esp,%ebp
80102044:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	8b 40 50             	mov    0x50(%eax),%eax
8010204d:	66 83 f8 03          	cmp    $0x3,%ax
80102051:	75 60                	jne    801020b3 <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102053:	8b 45 08             	mov    0x8(%ebp),%eax
80102056:	66 8b 40 52          	mov    0x52(%eax),%ax
8010205a:	66 85 c0             	test   %ax,%ax
8010205d:	78 20                	js     8010207f <writei+0x3e>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	66 8b 40 52          	mov    0x52(%eax),%ax
80102066:	66 83 f8 09          	cmp    $0x9,%ax
8010206a:	7f 13                	jg     8010207f <writei+0x3e>
8010206c:	8b 45 08             	mov    0x8(%ebp),%eax
8010206f:	66 8b 40 52          	mov    0x52(%eax),%ax
80102073:	98                   	cwtl   
80102074:	8b 04 c5 84 2c 11 80 	mov    -0x7feed37c(,%eax,8),%eax
8010207b:	85 c0                	test   %eax,%eax
8010207d:	75 0a                	jne    80102089 <writei+0x48>
      return -1;
8010207f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102084:	e9 45 01 00 00       	jmp    801021ce <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102089:	8b 45 08             	mov    0x8(%ebp),%eax
8010208c:	66 8b 40 52          	mov    0x52(%eax),%ax
80102090:	98                   	cwtl   
80102091:	8b 04 c5 84 2c 11 80 	mov    -0x7feed37c(,%eax,8),%eax
80102098:	8b 55 14             	mov    0x14(%ebp),%edx
8010209b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010209f:	8b 55 0c             	mov    0xc(%ebp),%edx
801020a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801020a6:	8b 55 08             	mov    0x8(%ebp),%edx
801020a9:	89 14 24             	mov    %edx,(%esp)
801020ac:	ff d0                	call   *%eax
801020ae:	e9 1b 01 00 00       	jmp    801021ce <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
801020b3:	8b 45 08             	mov    0x8(%ebp),%eax
801020b6:	8b 40 58             	mov    0x58(%eax),%eax
801020b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bc:	72 0d                	jb     801020cb <writei+0x8a>
801020be:	8b 45 14             	mov    0x14(%ebp),%eax
801020c1:	8b 55 10             	mov    0x10(%ebp),%edx
801020c4:	01 d0                	add    %edx,%eax
801020c6:	3b 45 10             	cmp    0x10(%ebp),%eax
801020c9:	73 0a                	jae    801020d5 <writei+0x94>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 f9 00 00 00       	jmp    801021ce <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
801020d5:	8b 45 14             	mov    0x14(%ebp),%eax
801020d8:	8b 55 10             	mov    0x10(%ebp),%edx
801020db:	01 d0                	add    %edx,%eax
801020dd:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020e2:	76 0a                	jbe    801020ee <writei+0xad>
    return -1;
801020e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020e9:	e9 e0 00 00 00       	jmp    801021ce <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f5:	e9 a0 00 00 00       	jmp    8010219a <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fa:	8b 45 10             	mov    0x10(%ebp),%eax
801020fd:	c1 e8 09             	shr    $0x9,%eax
80102100:	89 44 24 04          	mov    %eax,0x4(%esp)
80102104:	8b 45 08             	mov    0x8(%ebp),%eax
80102107:	89 04 24             	mov    %eax,(%esp)
8010210a:	e8 54 fb ff ff       	call   80101c63 <bmap>
8010210f:	8b 55 08             	mov    0x8(%ebp),%edx
80102112:	8b 12                	mov    (%edx),%edx
80102114:	89 44 24 04          	mov    %eax,0x4(%esp)
80102118:	89 14 24             	mov    %edx,(%esp)
8010211b:	e8 95 e0 ff ff       	call   801001b5 <bread>
80102120:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102123:	8b 45 10             	mov    0x10(%ebp),%eax
80102126:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212b:	89 c2                	mov    %eax,%edx
8010212d:	b8 00 02 00 00       	mov    $0x200,%eax
80102132:	29 d0                	sub    %edx,%eax
80102134:	89 c1                	mov    %eax,%ecx
80102136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	29 c2                	sub    %eax,%edx
8010213e:	89 c8                	mov    %ecx,%eax
80102140:	39 d0                	cmp    %edx,%eax
80102142:	76 02                	jbe    80102146 <writei+0x105>
80102144:	89 d0                	mov    %edx,%eax
80102146:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102149:	8b 45 10             	mov    0x10(%ebp),%eax
8010214c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102151:	8d 50 50             	lea    0x50(%eax),%edx
80102154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102157:	01 d0                	add    %edx,%eax
80102159:	8d 50 0c             	lea    0xc(%eax),%edx
8010215c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102163:	8b 45 0c             	mov    0xc(%ebp),%eax
80102166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216a:	89 14 24             	mov    %edx,(%esp)
8010216d:	e8 0d 30 00 00       	call   8010517f <memmove>
    log_write(bp);
80102172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102175:	89 04 24             	mov    %eax,(%esp)
80102178:	e8 c6 15 00 00       	call   80103743 <log_write>
    brelse(bp);
8010217d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102180:	89 04 24             	mov    %eax,(%esp)
80102183:	e8 a4 e0 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010218e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102191:	01 45 10             	add    %eax,0x10(%ebp)
80102194:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102197:	01 45 0c             	add    %eax,0xc(%ebp)
8010219a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219d:	3b 45 14             	cmp    0x14(%ebp),%eax
801021a0:	0f 82 54 ff ff ff    	jb     801020fa <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801021a6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021aa:	74 1f                	je     801021cb <writei+0x18a>
801021ac:	8b 45 08             	mov    0x8(%ebp),%eax
801021af:	8b 40 58             	mov    0x58(%eax),%eax
801021b2:	3b 45 10             	cmp    0x10(%ebp),%eax
801021b5:	73 14                	jae    801021cb <writei+0x18a>
    ip->size = off;
801021b7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ba:	8b 55 10             	mov    0x10(%ebp),%edx
801021bd:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021c0:	8b 45 08             	mov    0x8(%ebp),%eax
801021c3:	89 04 24             	mov    %eax,(%esp)
801021c6:	e8 b8 f6 ff ff       	call   80101883 <iupdate>
  }
  return n;
801021cb:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021ce:	c9                   	leave  
801021cf:	c3                   	ret    

801021d0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021d0:	55                   	push   %ebp
801021d1:	89 e5                	mov    %esp,%ebp
801021d3:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801021d6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021dd:	00 
801021de:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801021e5:	8b 45 08             	mov    0x8(%ebp),%eax
801021e8:	89 04 24             	mov    %eax,(%esp)
801021eb:	e8 2e 30 00 00       	call   8010521e <strncmp>
}
801021f0:	c9                   	leave  
801021f1:	c3                   	ret    

801021f2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021f2:	55                   	push   %ebp
801021f3:	89 e5                	mov    %esp,%ebp
801021f5:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021f8:	8b 45 08             	mov    0x8(%ebp),%eax
801021fb:	8b 40 50             	mov    0x50(%eax),%eax
801021fe:	66 83 f8 01          	cmp    $0x1,%ax
80102202:	74 0c                	je     80102210 <dirlookup+0x1e>
    panic("dirlookup not DIR");
80102204:	c7 04 24 c5 8a 10 80 	movl   $0x80108ac5,(%esp)
8010220b:	e8 44 e3 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102210:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102217:	e9 86 00 00 00       	jmp    801022a2 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010221c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102223:	00 
80102224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102227:	89 44 24 08          	mov    %eax,0x8(%esp)
8010222b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102232:	8b 45 08             	mov    0x8(%ebp),%eax
80102235:	89 04 24             	mov    %eax,(%esp)
80102238:	e8 a0 fc ff ff       	call   80101edd <readi>
8010223d:	83 f8 10             	cmp    $0x10,%eax
80102240:	74 0c                	je     8010224e <dirlookup+0x5c>
      panic("dirlookup read");
80102242:	c7 04 24 d7 8a 10 80 	movl   $0x80108ad7,(%esp)
80102249:	e8 06 e3 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
8010224e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102251:	66 85 c0             	test   %ax,%ax
80102254:	75 02                	jne    80102258 <dirlookup+0x66>
      continue;
80102256:	eb 46                	jmp    8010229e <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
80102258:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225b:	83 c0 02             	add    $0x2,%eax
8010225e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102262:	8b 45 0c             	mov    0xc(%ebp),%eax
80102265:	89 04 24             	mov    %eax,(%esp)
80102268:	e8 63 ff ff ff       	call   801021d0 <namecmp>
8010226d:	85 c0                	test   %eax,%eax
8010226f:	75 2d                	jne    8010229e <dirlookup+0xac>
      // entry matches path element
      if(poff)
80102271:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102275:	74 08                	je     8010227f <dirlookup+0x8d>
        *poff = off;
80102277:	8b 45 10             	mov    0x10(%ebp),%eax
8010227a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010227d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010227f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102282:	0f b7 c0             	movzwl %ax,%eax
80102285:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102288:	8b 45 08             	mov    0x8(%ebp),%eax
8010228b:	8b 00                	mov    (%eax),%eax
8010228d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102290:	89 54 24 04          	mov    %edx,0x4(%esp)
80102294:	89 04 24             	mov    %eax,(%esp)
80102297:	e8 a3 f6 ff ff       	call   8010193f <iget>
8010229c:	eb 18                	jmp    801022b6 <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010229e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022a2:	8b 45 08             	mov    0x8(%ebp),%eax
801022a5:	8b 40 58             	mov    0x58(%eax),%eax
801022a8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801022ab:	0f 87 6b ff ff ff    	ja     8010221c <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801022b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022b6:	c9                   	leave  
801022b7:	c3                   	ret    

801022b8 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022b8:	55                   	push   %ebp
801022b9:	89 e5                	mov    %esp,%ebp
801022bb:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801022c5:	00 
801022c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801022cd:	8b 45 08             	mov    0x8(%ebp),%eax
801022d0:	89 04 24             	mov    %eax,(%esp)
801022d3:	e8 1a ff ff ff       	call   801021f2 <dirlookup>
801022d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022df:	74 15                	je     801022f6 <dirlink+0x3e>
    iput(ip);
801022e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e4:	89 04 24             	mov    %eax,(%esp)
801022e7:	e8 a8 f8 ff ff       	call   80101b94 <iput>
    return -1;
801022ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022f1:	e9 b6 00 00 00       	jmp    801023ac <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022fd:	eb 45                	jmp    80102344 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102302:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102309:	00 
8010230a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010230e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102311:	89 44 24 04          	mov    %eax,0x4(%esp)
80102315:	8b 45 08             	mov    0x8(%ebp),%eax
80102318:	89 04 24             	mov    %eax,(%esp)
8010231b:	e8 bd fb ff ff       	call   80101edd <readi>
80102320:	83 f8 10             	cmp    $0x10,%eax
80102323:	74 0c                	je     80102331 <dirlink+0x79>
      panic("dirlink read");
80102325:	c7 04 24 e6 8a 10 80 	movl   $0x80108ae6,(%esp)
8010232c:	e8 23 e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102331:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102334:	66 85 c0             	test   %ax,%ax
80102337:	75 02                	jne    8010233b <dirlink+0x83>
      break;
80102339:	eb 16                	jmp    80102351 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010233b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233e:	83 c0 10             	add    $0x10,%eax
80102341:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102344:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102347:	8b 45 08             	mov    0x8(%ebp),%eax
8010234a:	8b 40 58             	mov    0x58(%eax),%eax
8010234d:	39 c2                	cmp    %eax,%edx
8010234f:	72 ae                	jb     801022ff <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102351:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102358:	00 
80102359:	8b 45 0c             	mov    0xc(%ebp),%eax
8010235c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102360:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102363:	83 c0 02             	add    $0x2,%eax
80102366:	89 04 24             	mov    %eax,(%esp)
80102369:	e8 fe 2e 00 00       	call   8010526c <strncpy>
  de.inum = inum;
8010236e:	8b 45 10             	mov    0x10(%ebp),%eax
80102371:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102378:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010237f:	00 
80102380:	89 44 24 08          	mov    %eax,0x8(%esp)
80102384:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102387:	89 44 24 04          	mov    %eax,0x4(%esp)
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	89 04 24             	mov    %eax,(%esp)
80102391:	e8 ab fc ff ff       	call   80102041 <writei>
80102396:	83 f8 10             	cmp    $0x10,%eax
80102399:	74 0c                	je     801023a7 <dirlink+0xef>
    panic("dirlink");
8010239b:	c7 04 24 f3 8a 10 80 	movl   $0x80108af3,(%esp)
801023a2:	e8 ad e1 ff ff       	call   80100554 <panic>

  return 0;
801023a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023ac:	c9                   	leave  
801023ad:	c3                   	ret    

801023ae <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023ae:	55                   	push   %ebp
801023af:	89 e5                	mov    %esp,%ebp
801023b1:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801023b4:	eb 03                	jmp    801023b9 <skipelem+0xb>
    path++;
801023b6:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023b9:	8b 45 08             	mov    0x8(%ebp),%eax
801023bc:	8a 00                	mov    (%eax),%al
801023be:	3c 2f                	cmp    $0x2f,%al
801023c0:	74 f4                	je     801023b6 <skipelem+0x8>
    path++;
  if(*path == 0)
801023c2:	8b 45 08             	mov    0x8(%ebp),%eax
801023c5:	8a 00                	mov    (%eax),%al
801023c7:	84 c0                	test   %al,%al
801023c9:	75 0a                	jne    801023d5 <skipelem+0x27>
    return 0;
801023cb:	b8 00 00 00 00       	mov    $0x0,%eax
801023d0:	e9 81 00 00 00       	jmp    80102456 <skipelem+0xa8>
  s = path;
801023d5:	8b 45 08             	mov    0x8(%ebp),%eax
801023d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023db:	eb 03                	jmp    801023e0 <skipelem+0x32>
    path++;
801023dd:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023e0:	8b 45 08             	mov    0x8(%ebp),%eax
801023e3:	8a 00                	mov    (%eax),%al
801023e5:	3c 2f                	cmp    $0x2f,%al
801023e7:	74 09                	je     801023f2 <skipelem+0x44>
801023e9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ec:	8a 00                	mov    (%eax),%al
801023ee:	84 c0                	test   %al,%al
801023f0:	75 eb                	jne    801023dd <skipelem+0x2f>
    path++;
  len = path - s;
801023f2:	8b 55 08             	mov    0x8(%ebp),%edx
801023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f8:	29 c2                	sub    %eax,%edx
801023fa:	89 d0                	mov    %edx,%eax
801023fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ff:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102403:	7e 1c                	jle    80102421 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
80102405:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010240c:	00 
8010240d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102410:	89 44 24 04          	mov    %eax,0x4(%esp)
80102414:	8b 45 0c             	mov    0xc(%ebp),%eax
80102417:	89 04 24             	mov    %eax,(%esp)
8010241a:	e8 60 2d 00 00       	call   8010517f <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010241f:	eb 29                	jmp    8010244a <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102424:	89 44 24 08          	mov    %eax,0x8(%esp)
80102428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010242f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102432:	89 04 24             	mov    %eax,(%esp)
80102435:	e8 45 2d 00 00       	call   8010517f <memmove>
    name[len] = 0;
8010243a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010243d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102440:	01 d0                	add    %edx,%eax
80102442:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102445:	eb 03                	jmp    8010244a <skipelem+0x9c>
    path++;
80102447:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010244a:	8b 45 08             	mov    0x8(%ebp),%eax
8010244d:	8a 00                	mov    (%eax),%al
8010244f:	3c 2f                	cmp    $0x2f,%al
80102451:	74 f4                	je     80102447 <skipelem+0x99>
    path++;
  return path;
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102456:	c9                   	leave  
80102457:	c3                   	ret    

80102458 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102458:	55                   	push   %ebp
80102459:	89 e5                	mov    %esp,%ebp
8010245b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010245e:	8b 45 08             	mov    0x8(%ebp),%eax
80102461:	8a 00                	mov    (%eax),%al
80102463:	3c 2f                	cmp    $0x2f,%al
80102465:	75 1c                	jne    80102483 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102467:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010246e:	00 
8010246f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102476:	e8 c4 f4 ff ff       	call   8010193f <iget>
8010247b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010247e:	e9 ac 00 00 00       	jmp    8010252f <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80102483:	e8 af 1d 00 00       	call   80104237 <myproc>
80102488:	8b 40 68             	mov    0x68(%eax),%eax
8010248b:	89 04 24             	mov    %eax,(%esp)
8010248e:	e8 81 f5 ff ff       	call   80101a14 <idup>
80102493:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102496:	e9 94 00 00 00       	jmp    8010252f <namex+0xd7>
    ilock(ip);
8010249b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249e:	89 04 24             	mov    %eax,(%esp)
801024a1:	e8 a0 f5 ff ff       	call   80101a46 <ilock>
    if(ip->type != T_DIR){
801024a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a9:	8b 40 50             	mov    0x50(%eax),%eax
801024ac:	66 83 f8 01          	cmp    $0x1,%ax
801024b0:	74 15                	je     801024c7 <namex+0x6f>
      iunlockput(ip);
801024b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b5:	89 04 24             	mov    %eax,(%esp)
801024b8:	e8 88 f7 ff ff       	call   80101c45 <iunlockput>
      return 0;
801024bd:	b8 00 00 00 00       	mov    $0x0,%eax
801024c2:	e9 a2 00 00 00       	jmp    80102569 <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
801024c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024cb:	74 1c                	je     801024e9 <namex+0x91>
801024cd:	8b 45 08             	mov    0x8(%ebp),%eax
801024d0:	8a 00                	mov    (%eax),%al
801024d2:	84 c0                	test   %al,%al
801024d4:	75 13                	jne    801024e9 <namex+0x91>
      // Stop one level early.
      iunlock(ip);
801024d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d9:	89 04 24             	mov    %eax,(%esp)
801024dc:	e8 6f f6 ff ff       	call   80101b50 <iunlock>
      return ip;
801024e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e4:	e9 80 00 00 00       	jmp    80102569 <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024f0:	00 
801024f1:	8b 45 10             	mov    0x10(%ebp),%eax
801024f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fb:	89 04 24             	mov    %eax,(%esp)
801024fe:	e8 ef fc ff ff       	call   801021f2 <dirlookup>
80102503:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102506:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010250a:	75 12                	jne    8010251e <namex+0xc6>
      iunlockput(ip);
8010250c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250f:	89 04 24             	mov    %eax,(%esp)
80102512:	e8 2e f7 ff ff       	call   80101c45 <iunlockput>
      return 0;
80102517:	b8 00 00 00 00       	mov    $0x0,%eax
8010251c:	eb 4b                	jmp    80102569 <namex+0x111>
    }
    iunlockput(ip);
8010251e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102521:	89 04 24             	mov    %eax,(%esp)
80102524:	e8 1c f7 ff ff       	call   80101c45 <iunlockput>
    ip = next;
80102529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010252c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010252f:	8b 45 10             	mov    0x10(%ebp),%eax
80102532:	89 44 24 04          	mov    %eax,0x4(%esp)
80102536:	8b 45 08             	mov    0x8(%ebp),%eax
80102539:	89 04 24             	mov    %eax,(%esp)
8010253c:	e8 6d fe ff ff       	call   801023ae <skipelem>
80102541:	89 45 08             	mov    %eax,0x8(%ebp)
80102544:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102548:	0f 85 4d ff ff ff    	jne    8010249b <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010254e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102552:	74 12                	je     80102566 <namex+0x10e>
    iput(ip);
80102554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102557:	89 04 24             	mov    %eax,(%esp)
8010255a:	e8 35 f6 ff ff       	call   80101b94 <iput>
    return 0;
8010255f:	b8 00 00 00 00       	mov    $0x0,%eax
80102564:	eb 03                	jmp    80102569 <namex+0x111>
  }
  return ip;
80102566:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102569:	c9                   	leave  
8010256a:	c3                   	ret    

8010256b <namei>:

struct inode*
namei(char *path)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
8010256e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102571:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102574:	89 44 24 08          	mov    %eax,0x8(%esp)
80102578:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010257f:	00 
80102580:	8b 45 08             	mov    0x8(%ebp),%eax
80102583:	89 04 24             	mov    %eax,(%esp)
80102586:	e8 cd fe ff ff       	call   80102458 <namex>
}
8010258b:	c9                   	leave  
8010258c:	c3                   	ret    

8010258d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010258d:	55                   	push   %ebp
8010258e:	89 e5                	mov    %esp,%ebp
80102590:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102593:	8b 45 0c             	mov    0xc(%ebp),%eax
80102596:	89 44 24 08          	mov    %eax,0x8(%esp)
8010259a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025a1:	00 
801025a2:	8b 45 08             	mov    0x8(%ebp),%eax
801025a5:	89 04 24             	mov    %eax,(%esp)
801025a8:	e8 ab fe ff ff       	call   80102458 <namex>
}
801025ad:	c9                   	leave  
801025ae:	c3                   	ret    
	...

801025b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025b0:	55                   	push   %ebp
801025b1:	89 e5                	mov    %esp,%ebp
801025b3:	83 ec 14             	sub    $0x14,%esp
801025b6:	8b 45 08             	mov    0x8(%ebp),%eax
801025b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025c0:	89 c2                	mov    %eax,%edx
801025c2:	ec                   	in     (%dx),%al
801025c3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801025c6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801025c9:	c9                   	leave  
801025ca:	c3                   	ret    

801025cb <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801025cb:	55                   	push   %ebp
801025cc:	89 e5                	mov    %esp,%ebp
801025ce:	57                   	push   %edi
801025cf:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025d0:	8b 55 08             	mov    0x8(%ebp),%edx
801025d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d6:	8b 45 10             	mov    0x10(%ebp),%eax
801025d9:	89 cb                	mov    %ecx,%ebx
801025db:	89 df                	mov    %ebx,%edi
801025dd:	89 c1                	mov    %eax,%ecx
801025df:	fc                   	cld    
801025e0:	f3 6d                	rep insl (%dx),%es:(%edi)
801025e2:	89 c8                	mov    %ecx,%eax
801025e4:	89 fb                	mov    %edi,%ebx
801025e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025ec:	5b                   	pop    %ebx
801025ed:	5f                   	pop    %edi
801025ee:	5d                   	pop    %ebp
801025ef:	c3                   	ret    

801025f0 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025f0:	55                   	push   %ebp
801025f1:	89 e5                	mov    %esp,%ebp
801025f3:	83 ec 08             	sub    $0x8,%esp
801025f6:	8b 45 08             	mov    0x8(%ebp),%eax
801025f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801025fc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102600:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102603:	8a 45 f8             	mov    -0x8(%ebp),%al
80102606:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102609:	ee                   	out    %al,(%dx)
}
8010260a:	c9                   	leave  
8010260b:	c3                   	ret    

8010260c <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010260c:	55                   	push   %ebp
8010260d:	89 e5                	mov    %esp,%ebp
8010260f:	56                   	push   %esi
80102610:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102611:	8b 55 08             	mov    0x8(%ebp),%edx
80102614:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102617:	8b 45 10             	mov    0x10(%ebp),%eax
8010261a:	89 cb                	mov    %ecx,%ebx
8010261c:	89 de                	mov    %ebx,%esi
8010261e:	89 c1                	mov    %eax,%ecx
80102620:	fc                   	cld    
80102621:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102623:	89 c8                	mov    %ecx,%eax
80102625:	89 f3                	mov    %esi,%ebx
80102627:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010262a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010262d:	5b                   	pop    %ebx
8010262e:	5e                   	pop    %esi
8010262f:	5d                   	pop    %ebp
80102630:	c3                   	ret    

80102631 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102631:	55                   	push   %ebp
80102632:	89 e5                	mov    %esp,%ebp
80102634:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102637:	90                   	nop
80102638:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010263f:	e8 6c ff ff ff       	call   801025b0 <inb>
80102644:	0f b6 c0             	movzbl %al,%eax
80102647:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010264a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010264d:	25 c0 00 00 00       	and    $0xc0,%eax
80102652:	83 f8 40             	cmp    $0x40,%eax
80102655:	75 e1                	jne    80102638 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102657:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010265b:	74 11                	je     8010266e <idewait+0x3d>
8010265d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102660:	83 e0 21             	and    $0x21,%eax
80102663:	85 c0                	test   %eax,%eax
80102665:	74 07                	je     8010266e <idewait+0x3d>
    return -1;
80102667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010266c:	eb 05                	jmp    80102673 <idewait+0x42>
  return 0;
8010266e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102673:	c9                   	leave  
80102674:	c3                   	ret    

80102675 <ideinit>:

void
ideinit(void)
{
80102675:	55                   	push   %ebp
80102676:	89 e5                	mov    %esp,%ebp
80102678:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010267b:	c7 44 24 04 fb 8a 10 	movl   $0x80108afb,0x4(%esp)
80102682:	80 
80102683:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
8010268a:	e8 a3 27 00 00       	call   80104e32 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010268f:	a1 20 50 11 80       	mov    0x80115020,%eax
80102694:	48                   	dec    %eax
80102695:	89 44 24 04          	mov    %eax,0x4(%esp)
80102699:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801026a0:	e8 66 04 00 00       	call   80102b0b <ioapicenable>
  idewait(0);
801026a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801026ac:	e8 80 ff ff ff       	call   80102631 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801026b1:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801026b8:	00 
801026b9:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026c0:	e8 2b ff ff ff       	call   801025f0 <outb>
  for(i=0; i<1000; i++){
801026c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026cc:	eb 1f                	jmp    801026ed <ideinit+0x78>
    if(inb(0x1f7) != 0){
801026ce:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026d5:	e8 d6 fe ff ff       	call   801025b0 <inb>
801026da:	84 c0                	test   %al,%al
801026dc:	74 0c                	je     801026ea <ideinit+0x75>
      havedisk1 = 1;
801026de:	c7 05 b8 c8 10 80 01 	movl   $0x1,0x8010c8b8
801026e5:	00 00 00 
      break;
801026e8:	eb 0c                	jmp    801026f6 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026ea:	ff 45 f4             	incl   -0xc(%ebp)
801026ed:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026f4:	7e d8                	jle    801026ce <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026f6:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801026fd:	00 
801026fe:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102705:	e8 e6 fe ff ff       	call   801025f0 <outb>
}
8010270a:	c9                   	leave  
8010270b:	c3                   	ret    

8010270c <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010270c:	55                   	push   %ebp
8010270d:	89 e5                	mov    %esp,%ebp
8010270f:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102712:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102716:	75 0c                	jne    80102724 <idestart+0x18>
    panic("idestart");
80102718:	c7 04 24 ff 8a 10 80 	movl   $0x80108aff,(%esp)
8010271f:	e8 30 de ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102724:	8b 45 08             	mov    0x8(%ebp),%eax
80102727:	8b 40 08             	mov    0x8(%eax),%eax
8010272a:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010272f:	76 0c                	jbe    8010273d <idestart+0x31>
    panic("incorrect blockno");
80102731:	c7 04 24 08 8b 10 80 	movl   $0x80108b08,(%esp)
80102738:	e8 17 de ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010273d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102744:	8b 45 08             	mov    0x8(%ebp),%eax
80102747:	8b 50 08             	mov    0x8(%eax),%edx
8010274a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274d:	0f af c2             	imul   %edx,%eax
80102750:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102753:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102757:	75 07                	jne    80102760 <idestart+0x54>
80102759:	b8 20 00 00 00       	mov    $0x20,%eax
8010275e:	eb 05                	jmp    80102765 <idestart+0x59>
80102760:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102765:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102768:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010276c:	75 07                	jne    80102775 <idestart+0x69>
8010276e:	b8 30 00 00 00       	mov    $0x30,%eax
80102773:	eb 05                	jmp    8010277a <idestart+0x6e>
80102775:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010277a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010277d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102781:	7e 0c                	jle    8010278f <idestart+0x83>
80102783:	c7 04 24 ff 8a 10 80 	movl   $0x80108aff,(%esp)
8010278a:	e8 c5 dd ff ff       	call   80100554 <panic>

  idewait(0);
8010278f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102796:	e8 96 fe ff ff       	call   80102631 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010279b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801027a2:	00 
801027a3:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801027aa:	e8 41 fe ff ff       	call   801025f0 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801027af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b2:	0f b6 c0             	movzbl %al,%eax
801027b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801027b9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801027c0:	e8 2b fe ff ff       	call   801025f0 <outb>
  outb(0x1f3, sector & 0xff);
801027c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c8:	0f b6 c0             	movzbl %al,%eax
801027cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801027cf:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801027d6:	e8 15 fe ff ff       	call   801025f0 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801027db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027de:	c1 f8 08             	sar    $0x8,%eax
801027e1:	0f b6 c0             	movzbl %al,%eax
801027e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801027e8:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801027ef:	e8 fc fd ff ff       	call   801025f0 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801027f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027f7:	c1 f8 10             	sar    $0x10,%eax
801027fa:	0f b6 c0             	movzbl %al,%eax
801027fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102801:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102808:	e8 e3 fd ff ff       	call   801025f0 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010280d:	8b 45 08             	mov    0x8(%ebp),%eax
80102810:	8b 40 04             	mov    0x4(%eax),%eax
80102813:	83 e0 01             	and    $0x1,%eax
80102816:	c1 e0 04             	shl    $0x4,%eax
80102819:	88 c2                	mov    %al,%dl
8010281b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010281e:	c1 f8 18             	sar    $0x18,%eax
80102821:	83 e0 0f             	and    $0xf,%eax
80102824:	09 d0                	or     %edx,%eax
80102826:	83 c8 e0             	or     $0xffffffe0,%eax
80102829:	0f b6 c0             	movzbl %al,%eax
8010282c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102830:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102837:	e8 b4 fd ff ff       	call   801025f0 <outb>
  if(b->flags & B_DIRTY){
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	8b 00                	mov    (%eax),%eax
80102841:	83 e0 04             	and    $0x4,%eax
80102844:	85 c0                	test   %eax,%eax
80102846:	74 36                	je     8010287e <idestart+0x172>
    outb(0x1f7, write_cmd);
80102848:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010284b:	0f b6 c0             	movzbl %al,%eax
8010284e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102852:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102859:	e8 92 fd ff ff       	call   801025f0 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	83 c0 5c             	add    $0x5c,%eax
80102864:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010286b:	00 
8010286c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102870:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102877:	e8 90 fd ff ff       	call   8010260c <outsl>
8010287c:	eb 16                	jmp    80102894 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
8010287e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102881:	0f b6 c0             	movzbl %al,%eax
80102884:	89 44 24 04          	mov    %eax,0x4(%esp)
80102888:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010288f:	e8 5c fd ff ff       	call   801025f0 <outb>
  }
}
80102894:	c9                   	leave  
80102895:	c3                   	ret    

80102896 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010289c:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
801028a3:	e8 ab 25 00 00       	call   80104e53 <acquire>

  if((b = idequeue) == 0){
801028a8:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
801028ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028b4:	75 11                	jne    801028c7 <ideintr+0x31>
    release(&idelock);
801028b6:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
801028bd:	e8 fb 25 00 00       	call   80104ebd <release>
    return;
801028c2:	e9 90 00 00 00       	jmp    80102957 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 40 58             	mov    0x58(%eax),%eax
801028cd:	a3 b4 c8 10 80       	mov    %eax,0x8010c8b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d5:	8b 00                	mov    (%eax),%eax
801028d7:	83 e0 04             	and    $0x4,%eax
801028da:	85 c0                	test   %eax,%eax
801028dc:	75 2e                	jne    8010290c <ideintr+0x76>
801028de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028e5:	e8 47 fd ff ff       	call   80102631 <idewait>
801028ea:	85 c0                	test   %eax,%eax
801028ec:	78 1e                	js     8010290c <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801028ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f1:	83 c0 5c             	add    $0x5c,%eax
801028f4:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028fb:	00 
801028fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102900:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102907:	e8 bf fc ff ff       	call   801025cb <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010290c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290f:	8b 00                	mov    (%eax),%eax
80102911:	83 c8 02             	or     $0x2,%eax
80102914:	89 c2                	mov    %eax,%edx
80102916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102919:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010291b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291e:	8b 00                	mov    (%eax),%eax
80102920:	83 e0 fb             	and    $0xfffffffb,%eax
80102923:	89 c2                	mov    %eax,%edx
80102925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102928:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010292a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010292d:	89 04 24             	mov    %eax,(%esp)
80102930:	e8 24 22 00 00       	call   80104b59 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102935:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
8010293a:	85 c0                	test   %eax,%eax
8010293c:	74 0d                	je     8010294b <ideintr+0xb5>
    idestart(idequeue);
8010293e:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
80102943:	89 04 24             	mov    %eax,(%esp)
80102946:	e8 c1 fd ff ff       	call   8010270c <idestart>

  release(&idelock);
8010294b:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102952:	e8 66 25 00 00       	call   80104ebd <release>
}
80102957:	c9                   	leave  
80102958:	c3                   	ret    

80102959 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102959:	55                   	push   %ebp
8010295a:	89 e5                	mov    %esp,%ebp
8010295c:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010295f:	8b 45 08             	mov    0x8(%ebp),%eax
80102962:	83 c0 0c             	add    $0xc,%eax
80102965:	89 04 24             	mov    %eax,(%esp)
80102968:	e8 5e 24 00 00       	call   80104dcb <holdingsleep>
8010296d:	85 c0                	test   %eax,%eax
8010296f:	75 0c                	jne    8010297d <iderw+0x24>
    panic("iderw: buf not locked");
80102971:	c7 04 24 1a 8b 10 80 	movl   $0x80108b1a,(%esp)
80102978:	e8 d7 db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010297d:	8b 45 08             	mov    0x8(%ebp),%eax
80102980:	8b 00                	mov    (%eax),%eax
80102982:	83 e0 06             	and    $0x6,%eax
80102985:	83 f8 02             	cmp    $0x2,%eax
80102988:	75 0c                	jne    80102996 <iderw+0x3d>
    panic("iderw: nothing to do");
8010298a:	c7 04 24 30 8b 10 80 	movl   $0x80108b30,(%esp)
80102991:	e8 be db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102996:	8b 45 08             	mov    0x8(%ebp),%eax
80102999:	8b 40 04             	mov    0x4(%eax),%eax
8010299c:	85 c0                	test   %eax,%eax
8010299e:	74 15                	je     801029b5 <iderw+0x5c>
801029a0:	a1 b8 c8 10 80       	mov    0x8010c8b8,%eax
801029a5:	85 c0                	test   %eax,%eax
801029a7:	75 0c                	jne    801029b5 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
801029a9:	c7 04 24 45 8b 10 80 	movl   $0x80108b45,(%esp)
801029b0:	e8 9f db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029b5:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
801029bc:	e8 92 24 00 00       	call   80104e53 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029cb:	c7 45 f4 b4 c8 10 80 	movl   $0x8010c8b4,-0xc(%ebp)
801029d2:	eb 0b                	jmp    801029df <iderw+0x86>
801029d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d7:	8b 00                	mov    (%eax),%eax
801029d9:	83 c0 58             	add    $0x58,%eax
801029dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e2:	8b 00                	mov    (%eax),%eax
801029e4:	85 c0                	test   %eax,%eax
801029e6:	75 ec                	jne    801029d4 <iderw+0x7b>
    ;
  *pp = b;
801029e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029eb:	8b 55 08             	mov    0x8(%ebp),%edx
801029ee:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029f0:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
801029f5:	3b 45 08             	cmp    0x8(%ebp),%eax
801029f8:	75 0d                	jne    80102a07 <iderw+0xae>
    idestart(b);
801029fa:	8b 45 08             	mov    0x8(%ebp),%eax
801029fd:	89 04 24             	mov    %eax,(%esp)
80102a00:	e8 07 fd ff ff       	call   8010270c <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a05:	eb 15                	jmp    80102a1c <iderw+0xc3>
80102a07:	eb 13                	jmp    80102a1c <iderw+0xc3>
    sleep(b, &idelock);
80102a09:	c7 44 24 04 80 c8 10 	movl   $0x8010c880,0x4(%esp)
80102a10:	80 
80102a11:	8b 45 08             	mov    0x8(%ebp),%eax
80102a14:	89 04 24             	mov    %eax,(%esp)
80102a17:	e8 69 20 00 00       	call   80104a85 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1f:	8b 00                	mov    (%eax),%eax
80102a21:	83 e0 06             	and    $0x6,%eax
80102a24:	83 f8 02             	cmp    $0x2,%eax
80102a27:	75 e0                	jne    80102a09 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a29:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102a30:	e8 88 24 00 00       	call   80104ebd <release>
}
80102a35:	c9                   	leave  
80102a36:	c3                   	ret    
	...

80102a38 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3b:	a1 54 49 11 80       	mov    0x80114954,%eax
80102a40:	8b 55 08             	mov    0x8(%ebp),%edx
80102a43:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a45:	a1 54 49 11 80       	mov    0x80114954,%eax
80102a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4d:	5d                   	pop    %ebp
80102a4e:	c3                   	ret    

80102a4f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a4f:	55                   	push   %ebp
80102a50:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a52:	a1 54 49 11 80       	mov    0x80114954,%eax
80102a57:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5c:	a1 54 49 11 80       	mov    0x80114954,%eax
80102a61:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a64:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a67:	5d                   	pop    %ebp
80102a68:	c3                   	ret    

80102a69 <ioapicinit>:

void
ioapicinit(void)
{
80102a69:	55                   	push   %ebp
80102a6a:	89 e5                	mov    %esp,%ebp
80102a6c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a6f:	c7 05 54 49 11 80 00 	movl   $0xfec00000,0x80114954
80102a76:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a80:	e8 b3 ff ff ff       	call   80102a38 <ioapicread>
80102a85:	c1 e8 10             	shr    $0x10,%eax
80102a88:	25 ff 00 00 00       	and    $0xff,%eax
80102a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102a97:	e8 9c ff ff ff       	call   80102a38 <ioapicread>
80102a9c:	c1 e8 18             	shr    $0x18,%eax
80102a9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aa2:	a0 80 4a 11 80       	mov    0x80114a80,%al
80102aa7:	0f b6 c0             	movzbl %al,%eax
80102aaa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102aad:	74 0c                	je     80102abb <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aaf:	c7 04 24 64 8b 10 80 	movl   $0x80108b64,(%esp)
80102ab6:	e8 06 d9 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac2:	eb 3d                	jmp    80102b01 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac7:	83 c0 20             	add    $0x20,%eax
80102aca:	0d 00 00 01 00       	or     $0x10000,%eax
80102acf:	89 c2                	mov    %eax,%edx
80102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad4:	83 c0 08             	add    $0x8,%eax
80102ad7:	01 c0                	add    %eax,%eax
80102ad9:	89 54 24 04          	mov    %edx,0x4(%esp)
80102add:	89 04 24             	mov    %eax,(%esp)
80102ae0:	e8 6a ff ff ff       	call   80102a4f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae8:	83 c0 08             	add    $0x8,%eax
80102aeb:	01 c0                	add    %eax,%eax
80102aed:	40                   	inc    %eax
80102aee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102af5:	00 
80102af6:	89 04 24             	mov    %eax,(%esp)
80102af9:	e8 51 ff ff ff       	call   80102a4f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102afe:	ff 45 f4             	incl   -0xc(%ebp)
80102b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b04:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b07:	7e bb                	jle    80102ac4 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b09:	c9                   	leave  
80102b0a:	c3                   	ret    

80102b0b <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b0b:	55                   	push   %ebp
80102b0c:	89 e5                	mov    %esp,%ebp
80102b0e:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b11:	8b 45 08             	mov    0x8(%ebp),%eax
80102b14:	83 c0 20             	add    $0x20,%eax
80102b17:	89 c2                	mov    %eax,%edx
80102b19:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1c:	83 c0 08             	add    $0x8,%eax
80102b1f:	01 c0                	add    %eax,%eax
80102b21:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b25:	89 04 24             	mov    %eax,(%esp)
80102b28:	e8 22 ff ff ff       	call   80102a4f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b30:	c1 e0 18             	shl    $0x18,%eax
80102b33:	8b 55 08             	mov    0x8(%ebp),%edx
80102b36:	83 c2 08             	add    $0x8,%edx
80102b39:	01 d2                	add    %edx,%edx
80102b3b:	42                   	inc    %edx
80102b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b40:	89 14 24             	mov    %edx,(%esp)
80102b43:	e8 07 ff ff ff       	call   80102a4f <ioapicwrite>
}
80102b48:	c9                   	leave  
80102b49:	c3                   	ret    
	...

80102b4c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b52:	c7 44 24 04 96 8b 10 	movl   $0x80108b96,0x4(%esp)
80102b59:	80 
80102b5a:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80102b61:	e8 cc 22 00 00       	call   80104e32 <initlock>
  kmem.use_lock = 0;
80102b66:	c7 05 94 49 11 80 00 	movl   $0x0,0x80114994
80102b6d:	00 00 00 
  freerange(vstart, vend);
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	89 04 24             	mov    %eax,(%esp)
80102b7d:	e8 26 00 00 00       	call   80102ba8 <freerange>
}
80102b82:	c9                   	leave  
80102b83:	c3                   	ret    

80102b84 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b84:	55                   	push   %ebp
80102b85:	89 e5                	mov    %esp,%ebp
80102b87:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b91:	8b 45 08             	mov    0x8(%ebp),%eax
80102b94:	89 04 24             	mov    %eax,(%esp)
80102b97:	e8 0c 00 00 00       	call   80102ba8 <freerange>
  kmem.use_lock = 1;
80102b9c:	c7 05 94 49 11 80 01 	movl   $0x1,0x80114994
80102ba3:	00 00 00 
}
80102ba6:	c9                   	leave  
80102ba7:	c3                   	ret    

80102ba8 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ba8:	55                   	push   %ebp
80102ba9:	89 e5                	mov    %esp,%ebp
80102bab:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bae:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb1:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bbe:	eb 12                	jmp    80102bd2 <freerange+0x2a>
    kfree(p);
80102bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc3:	89 04 24             	mov    %eax,(%esp)
80102bc6:	e8 16 00 00 00       	call   80102be1 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bcb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd5:	05 00 10 00 00       	add    $0x1000,%eax
80102bda:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bdd:	76 e1                	jbe    80102bc0 <freerange+0x18>
    kfree(p);
}
80102bdf:	c9                   	leave  
80102be0:	c3                   	ret    

80102be1 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102be1:	55                   	push   %ebp
80102be2:	89 e5                	mov    %esp,%ebp
80102be4:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102be7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bea:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bef:	85 c0                	test   %eax,%eax
80102bf1:	75 18                	jne    80102c0b <kfree+0x2a>
80102bf3:	81 7d 08 50 79 11 80 	cmpl   $0x80117950,0x8(%ebp)
80102bfa:	72 0f                	jb     80102c0b <kfree+0x2a>
80102bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bff:	05 00 00 00 80       	add    $0x80000000,%eax
80102c04:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c09:	76 0c                	jbe    80102c17 <kfree+0x36>
    panic("kfree");
80102c0b:	c7 04 24 9b 8b 10 80 	movl   $0x80108b9b,(%esp)
80102c12:	e8 3d d9 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102c1e:	00 
80102c1f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c26:	00 
80102c27:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2a:	89 04 24             	mov    %eax,(%esp)
80102c2d:	e8 84 24 00 00       	call   801050b6 <memset>

  if(kmem.use_lock)
80102c32:	a1 94 49 11 80       	mov    0x80114994,%eax
80102c37:	85 c0                	test   %eax,%eax
80102c39:	74 0c                	je     80102c47 <kfree+0x66>
    acquire(&kmem.lock);
80102c3b:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80102c42:	e8 0c 22 00 00       	call   80104e53 <acquire>
  r = (struct run*)v;
80102c47:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c4d:	8b 15 98 49 11 80    	mov    0x80114998,%edx
80102c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c56:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5b:	a3 98 49 11 80       	mov    %eax,0x80114998
  if(kmem.use_lock)
80102c60:	a1 94 49 11 80       	mov    0x80114994,%eax
80102c65:	85 c0                	test   %eax,%eax
80102c67:	74 0c                	je     80102c75 <kfree+0x94>
    release(&kmem.lock);
80102c69:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80102c70:	e8 48 22 00 00       	call   80104ebd <release>
}
80102c75:	c9                   	leave  
80102c76:	c3                   	ret    

80102c77 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c77:	55                   	push   %ebp
80102c78:	89 e5                	mov    %esp,%ebp
80102c7a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102c7d:	a1 94 49 11 80       	mov    0x80114994,%eax
80102c82:	85 c0                	test   %eax,%eax
80102c84:	74 0c                	je     80102c92 <kalloc+0x1b>
    acquire(&kmem.lock);
80102c86:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80102c8d:	e8 c1 21 00 00       	call   80104e53 <acquire>
  r = kmem.freelist;
80102c92:	a1 98 49 11 80       	mov    0x80114998,%eax
80102c97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c9e:	74 0a                	je     80102caa <kalloc+0x33>
    kmem.freelist = r->next;
80102ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca3:	8b 00                	mov    (%eax),%eax
80102ca5:	a3 98 49 11 80       	mov    %eax,0x80114998
  if(kmem.use_lock)
80102caa:	a1 94 49 11 80       	mov    0x80114994,%eax
80102caf:	85 c0                	test   %eax,%eax
80102cb1:	74 0c                	je     80102cbf <kalloc+0x48>
    release(&kmem.lock);
80102cb3:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80102cba:	e8 fe 21 00 00       	call   80104ebd <release>
  return (char*)r;
80102cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cc2:	c9                   	leave  
80102cc3:	c3                   	ret    

80102cc4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cc4:	55                   	push   %ebp
80102cc5:	89 e5                	mov    %esp,%ebp
80102cc7:	83 ec 14             	sub    $0x14,%esp
80102cca:	8b 45 08             	mov    0x8(%ebp),%eax
80102ccd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102cd4:	89 c2                	mov    %eax,%edx
80102cd6:	ec                   	in     (%dx),%al
80102cd7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cda:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102cdd:	c9                   	leave  
80102cde:	c3                   	ret    

80102cdf <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cdf:	55                   	push   %ebp
80102ce0:	89 e5                	mov    %esp,%ebp
80102ce2:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ce5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102cec:	e8 d3 ff ff ff       	call   80102cc4 <inb>
80102cf1:	0f b6 c0             	movzbl %al,%eax
80102cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cfa:	83 e0 01             	and    $0x1,%eax
80102cfd:	85 c0                	test   %eax,%eax
80102cff:	75 0a                	jne    80102d0b <kbdgetc+0x2c>
    return -1;
80102d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d06:	e9 21 01 00 00       	jmp    80102e2c <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d0b:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102d12:	e8 ad ff ff ff       	call   80102cc4 <inb>
80102d17:	0f b6 c0             	movzbl %al,%eax
80102d1a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d1d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d24:	75 17                	jne    80102d3d <kbdgetc+0x5e>
    shift |= E0ESC;
80102d26:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102d2b:	83 c8 40             	or     $0x40,%eax
80102d2e:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
    return 0;
80102d33:	b8 00 00 00 00       	mov    $0x0,%eax
80102d38:	e9 ef 00 00 00       	jmp    80102e2c <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d40:	25 80 00 00 00       	and    $0x80,%eax
80102d45:	85 c0                	test   %eax,%eax
80102d47:	74 44                	je     80102d8d <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d49:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102d4e:	83 e0 40             	and    $0x40,%eax
80102d51:	85 c0                	test   %eax,%eax
80102d53:	75 08                	jne    80102d5d <kbdgetc+0x7e>
80102d55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d58:	83 e0 7f             	and    $0x7f,%eax
80102d5b:	eb 03                	jmp    80102d60 <kbdgetc+0x81>
80102d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d60:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d66:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d6b:	8a 00                	mov    (%eax),%al
80102d6d:	83 c8 40             	or     $0x40,%eax
80102d70:	0f b6 c0             	movzbl %al,%eax
80102d73:	f7 d0                	not    %eax
80102d75:	89 c2                	mov    %eax,%edx
80102d77:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102d7c:	21 d0                	and    %edx,%eax
80102d7e:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
    return 0;
80102d83:	b8 00 00 00 00       	mov    $0x0,%eax
80102d88:	e9 9f 00 00 00       	jmp    80102e2c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d8d:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102d92:	83 e0 40             	and    $0x40,%eax
80102d95:	85 c0                	test   %eax,%eax
80102d97:	74 14                	je     80102dad <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d99:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102da0:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102da5:	83 e0 bf             	and    $0xffffffbf,%eax
80102da8:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
  }

  shift |= shiftcode[data];
80102dad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db0:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102db5:	8a 00                	mov    (%eax),%al
80102db7:	0f b6 d0             	movzbl %al,%edx
80102dba:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102dbf:	09 d0                	or     %edx,%eax
80102dc1:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
  shift ^= togglecode[data];
80102dc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc9:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102dce:	8a 00                	mov    (%eax),%al
80102dd0:	0f b6 d0             	movzbl %al,%edx
80102dd3:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102dd8:	31 d0                	xor    %edx,%eax
80102dda:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102ddf:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102de4:	83 e0 03             	and    $0x3,%eax
80102de7:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df1:	01 d0                	add    %edx,%eax
80102df3:	8a 00                	mov    (%eax),%al
80102df5:	0f b6 c0             	movzbl %al,%eax
80102df8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102dfb:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102e00:	83 e0 08             	and    $0x8,%eax
80102e03:	85 c0                	test   %eax,%eax
80102e05:	74 22                	je     80102e29 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e07:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e0b:	76 0c                	jbe    80102e19 <kbdgetc+0x13a>
80102e0d:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e11:	77 06                	ja     80102e19 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e13:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e17:	eb 10                	jmp    80102e29 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e19:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e1d:	76 0a                	jbe    80102e29 <kbdgetc+0x14a>
80102e1f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e23:	77 04                	ja     80102e29 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e25:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e29:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e2c:	c9                   	leave  
80102e2d:	c3                   	ret    

80102e2e <kbdintr>:

void
kbdintr(void)
{
80102e2e:	55                   	push   %ebp
80102e2f:	89 e5                	mov    %esp,%ebp
80102e31:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102e34:	c7 04 24 df 2c 10 80 	movl   $0x80102cdf,(%esp)
80102e3b:	e8 b5 d9 ff ff       	call   801007f5 <consoleintr>
}
80102e40:	c9                   	leave  
80102e41:	c3                   	ret    
	...

80102e44 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e44:	55                   	push   %ebp
80102e45:	89 e5                	mov    %esp,%ebp
80102e47:	83 ec 14             	sub    $0x14,%esp
80102e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e54:	89 c2                	mov    %eax,%edx
80102e56:	ec                   	in     (%dx),%al
80102e57:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e5a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102e5d:	c9                   	leave  
80102e5e:	c3                   	ret    

80102e5f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e5f:	55                   	push   %ebp
80102e60:	89 e5                	mov    %esp,%ebp
80102e62:	83 ec 08             	sub    $0x8,%esp
80102e65:	8b 45 08             	mov    0x8(%ebp),%eax
80102e68:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e6b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e6f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e72:	8a 45 f8             	mov    -0x8(%ebp),%al
80102e75:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102e78:	ee                   	out    %al,(%dx)
}
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    

80102e7b <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e7e:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80102e83:	8b 55 08             	mov    0x8(%ebp),%edx
80102e86:	c1 e2 02             	shl    $0x2,%edx
80102e89:	01 c2                	add    %eax,%edx
80102e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e8e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e90:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80102e95:	83 c0 20             	add    $0x20,%eax
80102e98:	8b 00                	mov    (%eax),%eax
}
80102e9a:	5d                   	pop    %ebp
80102e9b:	c3                   	ret    

80102e9c <lapicinit>:

void
lapicinit(void)
{
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
80102e9f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102ea2:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80102ea7:	85 c0                	test   %eax,%eax
80102ea9:	75 05                	jne    80102eb0 <lapicinit+0x14>
    return;
80102eab:	e9 43 01 00 00       	jmp    80102ff3 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102eb0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102eb7:	00 
80102eb8:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102ebf:	e8 b7 ff ff ff       	call   80102e7b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ec4:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102ecb:	00 
80102ecc:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102ed3:	e8 a3 ff ff ff       	call   80102e7b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ed8:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102edf:	00 
80102ee0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ee7:	e8 8f ff ff ff       	call   80102e7b <lapicw>
  lapicw(TICR, 10000000);
80102eec:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102ef3:	00 
80102ef4:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102efb:	e8 7b ff ff ff       	call   80102e7b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f00:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f07:	00 
80102f08:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102f0f:	e8 67 ff ff ff       	call   80102e7b <lapicw>
  lapicw(LINT1, MASKED);
80102f14:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f1b:	00 
80102f1c:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102f23:	e8 53 ff ff ff       	call   80102e7b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f28:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80102f2d:	83 c0 30             	add    $0x30,%eax
80102f30:	8b 00                	mov    (%eax),%eax
80102f32:	c1 e8 10             	shr    $0x10,%eax
80102f35:	0f b6 c0             	movzbl %al,%eax
80102f38:	83 f8 03             	cmp    $0x3,%eax
80102f3b:	76 14                	jbe    80102f51 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f3d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f44:	00 
80102f45:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102f4c:	e8 2a ff ff ff       	call   80102e7b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f51:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102f58:	00 
80102f59:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102f60:	e8 16 ff ff ff       	call   80102e7b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f6c:	00 
80102f6d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f74:	e8 02 ff ff ff       	call   80102e7b <lapicw>
  lapicw(ESR, 0);
80102f79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f80:	00 
80102f81:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f88:	e8 ee fe ff ff       	call   80102e7b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f94:	00 
80102f95:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f9c:	e8 da fe ff ff       	call   80102e7b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fa8:	00 
80102fa9:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fb0:	e8 c6 fe ff ff       	call   80102e7b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fb5:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102fbc:	00 
80102fbd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fc4:	e8 b2 fe ff ff       	call   80102e7b <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102fc9:	90                   	nop
80102fca:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80102fcf:	05 00 03 00 00       	add    $0x300,%eax
80102fd4:	8b 00                	mov    (%eax),%eax
80102fd6:	25 00 10 00 00       	and    $0x1000,%eax
80102fdb:	85 c0                	test   %eax,%eax
80102fdd:	75 eb                	jne    80102fca <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fdf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fe6:	00 
80102fe7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102fee:	e8 88 fe ff ff       	call   80102e7b <lapicw>
}
80102ff3:	c9                   	leave  
80102ff4:	c3                   	ret    

80102ff5 <lapicid>:

int
lapicid(void)
{
80102ff5:	55                   	push   %ebp
80102ff6:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102ff8:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80102ffd:	85 c0                	test   %eax,%eax
80102fff:	75 07                	jne    80103008 <lapicid+0x13>
    return 0;
80103001:	b8 00 00 00 00       	mov    $0x0,%eax
80103006:	eb 0d                	jmp    80103015 <lapicid+0x20>
  return lapic[ID] >> 24;
80103008:	a1 9c 49 11 80       	mov    0x8011499c,%eax
8010300d:	83 c0 20             	add    $0x20,%eax
80103010:	8b 00                	mov    (%eax),%eax
80103012:	c1 e8 18             	shr    $0x18,%eax
}
80103015:	5d                   	pop    %ebp
80103016:	c3                   	ret    

80103017 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103017:	55                   	push   %ebp
80103018:	89 e5                	mov    %esp,%ebp
8010301a:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
8010301d:	a1 9c 49 11 80       	mov    0x8011499c,%eax
80103022:	85 c0                	test   %eax,%eax
80103024:	74 14                	je     8010303a <lapiceoi+0x23>
    lapicw(EOI, 0);
80103026:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010302d:	00 
8010302e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103035:	e8 41 fe ff ff       	call   80102e7b <lapicw>
}
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
}
8010303f:	5d                   	pop    %ebp
80103040:	c3                   	ret    

80103041 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103041:	55                   	push   %ebp
80103042:	89 e5                	mov    %esp,%ebp
80103044:	83 ec 1c             	sub    $0x1c,%esp
80103047:	8b 45 08             	mov    0x8(%ebp),%eax
8010304a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010304d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103054:	00 
80103055:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010305c:	e8 fe fd ff ff       	call   80102e5f <outb>
  outb(CMOS_PORT+1, 0x0A);
80103061:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103068:	00 
80103069:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103070:	e8 ea fd ff ff       	call   80102e5f <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103075:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010307c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103084:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103087:	8d 50 02             	lea    0x2(%eax),%edx
8010308a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308d:	c1 e8 04             	shr    $0x4,%eax
80103090:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103093:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103097:	c1 e0 18             	shl    $0x18,%eax
8010309a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010309e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030a5:	e8 d1 fd ff ff       	call   80102e7b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030aa:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801030b1:	00 
801030b2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030b9:	e8 bd fd ff ff       	call   80102e7b <lapicw>
  microdelay(200);
801030be:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030c5:	e8 72 ff ff ff       	call   8010303c <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801030ca:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801030d1:	00 
801030d2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030d9:	e8 9d fd ff ff       	call   80102e7b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030de:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801030e5:	e8 52 ff ff ff       	call   8010303c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030f1:	eb 3f                	jmp    80103132 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801030f3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030f7:	c1 e0 18             	shl    $0x18,%eax
801030fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801030fe:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103105:	e8 71 fd ff ff       	call   80102e7b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010310a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010310d:	c1 e8 0c             	shr    $0xc,%eax
80103110:	80 cc 06             	or     $0x6,%ah
80103113:	89 44 24 04          	mov    %eax,0x4(%esp)
80103117:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010311e:	e8 58 fd ff ff       	call   80102e7b <lapicw>
    microdelay(200);
80103123:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010312a:	e8 0d ff ff ff       	call   8010303c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010312f:	ff 45 fc             	incl   -0x4(%ebp)
80103132:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103136:	7e bb                	jle    801030f3 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103138:	c9                   	leave  
80103139:	c3                   	ret    

8010313a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010313a:	55                   	push   %ebp
8010313b:	89 e5                	mov    %esp,%ebp
8010313d:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103140:	8b 45 08             	mov    0x8(%ebp),%eax
80103143:	0f b6 c0             	movzbl %al,%eax
80103146:	89 44 24 04          	mov    %eax,0x4(%esp)
8010314a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103151:	e8 09 fd ff ff       	call   80102e5f <outb>
  microdelay(200);
80103156:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010315d:	e8 da fe ff ff       	call   8010303c <microdelay>

  return inb(CMOS_RETURN);
80103162:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103169:	e8 d6 fc ff ff       	call   80102e44 <inb>
8010316e:	0f b6 c0             	movzbl %al,%eax
}
80103171:	c9                   	leave  
80103172:	c3                   	ret    

80103173 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103173:	55                   	push   %ebp
80103174:	89 e5                	mov    %esp,%ebp
80103176:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103180:	e8 b5 ff ff ff       	call   8010313a <cmos_read>
80103185:	8b 55 08             	mov    0x8(%ebp),%edx
80103188:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010318a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103191:	e8 a4 ff ff ff       	call   8010313a <cmos_read>
80103196:	8b 55 08             	mov    0x8(%ebp),%edx
80103199:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010319c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801031a3:	e8 92 ff ff ff       	call   8010313a <cmos_read>
801031a8:	8b 55 08             	mov    0x8(%ebp),%edx
801031ab:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031ae:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801031b5:	e8 80 ff ff ff       	call   8010313a <cmos_read>
801031ba:	8b 55 08             	mov    0x8(%ebp),%edx
801031bd:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031c0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801031c7:	e8 6e ff ff ff       	call   8010313a <cmos_read>
801031cc:	8b 55 08             	mov    0x8(%ebp),%edx
801031cf:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031d2:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801031d9:	e8 5c ff ff ff       	call   8010313a <cmos_read>
801031de:	8b 55 08             	mov    0x8(%ebp),%edx
801031e1:	89 42 14             	mov    %eax,0x14(%edx)
}
801031e4:	c9                   	leave  
801031e5:	c3                   	ret    

801031e6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031e6:	55                   	push   %ebp
801031e7:	89 e5                	mov    %esp,%ebp
801031e9:	57                   	push   %edi
801031ea:	56                   	push   %esi
801031eb:	53                   	push   %ebx
801031ec:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ef:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801031f6:	e8 3f ff ff ff       	call   8010313a <cmos_read>
801031fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103201:	83 e0 04             	and    $0x4,%eax
80103204:	85 c0                	test   %eax,%eax
80103206:	0f 94 c0             	sete   %al
80103209:	0f b6 c0             	movzbl %al,%eax
8010320c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010320f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103212:	89 04 24             	mov    %eax,(%esp)
80103215:	e8 59 ff ff ff       	call   80103173 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010321a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103221:	e8 14 ff ff ff       	call   8010313a <cmos_read>
80103226:	25 80 00 00 00       	and    $0x80,%eax
8010322b:	85 c0                	test   %eax,%eax
8010322d:	74 02                	je     80103231 <cmostime+0x4b>
        continue;
8010322f:	eb 36                	jmp    80103267 <cmostime+0x81>
    fill_rtcdate(&t2);
80103231:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103234:	89 04 24             	mov    %eax,(%esp)
80103237:	e8 37 ff ff ff       	call   80103173 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010323c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103243:	00 
80103244:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103247:	89 44 24 04          	mov    %eax,0x4(%esp)
8010324b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010324e:	89 04 24             	mov    %eax,(%esp)
80103251:	e8 d7 1e 00 00       	call   8010512d <memcmp>
80103256:	85 c0                	test   %eax,%eax
80103258:	75 0d                	jne    80103267 <cmostime+0x81>
      break;
8010325a:	90                   	nop
  }

  // convert
  if(bcd) {
8010325b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010325f:	0f 84 ac 00 00 00    	je     80103311 <cmostime+0x12b>
80103265:	eb 02                	jmp    80103269 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103267:	eb a6                	jmp    8010320f <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103269:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010326c:	c1 e8 04             	shr    $0x4,%eax
8010326f:	89 c2                	mov    %eax,%edx
80103271:	89 d0                	mov    %edx,%eax
80103273:	c1 e0 02             	shl    $0x2,%eax
80103276:	01 d0                	add    %edx,%eax
80103278:	01 c0                	add    %eax,%eax
8010327a:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010327d:	83 e2 0f             	and    $0xf,%edx
80103280:	01 d0                	add    %edx,%eax
80103282:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103285:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103288:	c1 e8 04             	shr    $0x4,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	89 d0                	mov    %edx,%eax
8010328f:	c1 e0 02             	shl    $0x2,%eax
80103292:	01 d0                	add    %edx,%eax
80103294:	01 c0                	add    %eax,%eax
80103296:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103299:	83 e2 0f             	and    $0xf,%edx
8010329c:	01 d0                	add    %edx,%eax
8010329e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
801032a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801032a4:	c1 e8 04             	shr    $0x4,%eax
801032a7:	89 c2                	mov    %eax,%edx
801032a9:	89 d0                	mov    %edx,%eax
801032ab:	c1 e0 02             	shl    $0x2,%eax
801032ae:	01 d0                	add    %edx,%eax
801032b0:	01 c0                	add    %eax,%eax
801032b2:	8b 55 d0             	mov    -0x30(%ebp),%edx
801032b5:	83 e2 0f             	and    $0xf,%edx
801032b8:	01 d0                	add    %edx,%eax
801032ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801032bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801032c0:	c1 e8 04             	shr    $0x4,%eax
801032c3:	89 c2                	mov    %eax,%edx
801032c5:	89 d0                	mov    %edx,%eax
801032c7:	c1 e0 02             	shl    $0x2,%eax
801032ca:	01 d0                	add    %edx,%eax
801032cc:	01 c0                	add    %eax,%eax
801032ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801032d1:	83 e2 0f             	and    $0xf,%edx
801032d4:	01 d0                	add    %edx,%eax
801032d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801032d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032dc:	c1 e8 04             	shr    $0x4,%eax
801032df:	89 c2                	mov    %eax,%edx
801032e1:	89 d0                	mov    %edx,%eax
801032e3:	c1 e0 02             	shl    $0x2,%eax
801032e6:	01 d0                	add    %edx,%eax
801032e8:	01 c0                	add    %eax,%eax
801032ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032ed:	83 e2 0f             	and    $0xf,%edx
801032f0:	01 d0                	add    %edx,%eax
801032f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801032f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032f8:	c1 e8 04             	shr    $0x4,%eax
801032fb:	89 c2                	mov    %eax,%edx
801032fd:	89 d0                	mov    %edx,%eax
801032ff:	c1 e0 02             	shl    $0x2,%eax
80103302:	01 d0                	add    %edx,%eax
80103304:	01 c0                	add    %eax,%eax
80103306:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103309:	83 e2 0f             	and    $0xf,%edx
8010330c:	01 d0                	add    %edx,%eax
8010330e:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103311:	8b 45 08             	mov    0x8(%ebp),%eax
80103314:	89 c2                	mov    %eax,%edx
80103316:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103319:	b8 06 00 00 00       	mov    $0x6,%eax
8010331e:	89 d7                	mov    %edx,%edi
80103320:	89 de                	mov    %ebx,%esi
80103322:	89 c1                	mov    %eax,%ecx
80103324:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
80103326:	8b 45 08             	mov    0x8(%ebp),%eax
80103329:	8b 40 14             	mov    0x14(%eax),%eax
8010332c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103332:	8b 45 08             	mov    0x8(%ebp),%eax
80103335:	89 50 14             	mov    %edx,0x14(%eax)
}
80103338:	83 c4 5c             	add    $0x5c,%esp
8010333b:	5b                   	pop    %ebx
8010333c:	5e                   	pop    %esi
8010333d:	5f                   	pop    %edi
8010333e:	5d                   	pop    %ebp
8010333f:	c3                   	ret    

80103340 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103340:	55                   	push   %ebp
80103341:	89 e5                	mov    %esp,%ebp
80103343:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103346:	c7 44 24 04 a1 8b 10 	movl   $0x80108ba1,0x4(%esp)
8010334d:	80 
8010334e:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80103355:	e8 d8 1a 00 00       	call   80104e32 <initlock>
  readsb(dev, &sb);
8010335a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010335d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103361:	8b 45 08             	mov    0x8(%ebp),%eax
80103364:	89 04 24             	mov    %eax,(%esp)
80103367:	e8 d8 e0 ff ff       	call   80101444 <readsb>
  log.start = sb.logstart;
8010336c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010336f:	a3 d4 49 11 80       	mov    %eax,0x801149d4
  log.size = sb.nlog;
80103374:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103377:	a3 d8 49 11 80       	mov    %eax,0x801149d8
  log.dev = dev;
8010337c:	8b 45 08             	mov    0x8(%ebp),%eax
8010337f:	a3 e4 49 11 80       	mov    %eax,0x801149e4
  recover_from_log();
80103384:	e8 95 01 00 00       	call   8010351e <recover_from_log>
}
80103389:	c9                   	leave  
8010338a:	c3                   	ret    

8010338b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010338b:	55                   	push   %ebp
8010338c:	89 e5                	mov    %esp,%ebp
8010338e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103391:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103398:	e9 89 00 00 00       	jmp    80103426 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010339d:	8b 15 d4 49 11 80    	mov    0x801149d4,%edx
801033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a6:	01 d0                	add    %edx,%eax
801033a8:	40                   	inc    %eax
801033a9:	89 c2                	mov    %eax,%edx
801033ab:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801033b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801033b4:	89 04 24             	mov    %eax,(%esp)
801033b7:	e8 f9 cd ff ff       	call   801001b5 <bread>
801033bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c2:	83 c0 10             	add    $0x10,%eax
801033c5:	8b 04 85 ac 49 11 80 	mov    -0x7feeb654(,%eax,4),%eax
801033cc:	89 c2                	mov    %eax,%edx
801033ce:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801033d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033d7:	89 04 24             	mov    %eax,(%esp)
801033da:	e8 d6 cd ff ff       	call   801001b5 <bread>
801033df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e5:	8d 50 5c             	lea    0x5c(%eax),%edx
801033e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033eb:	83 c0 5c             	add    $0x5c,%eax
801033ee:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033f5:	00 
801033f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801033fa:	89 04 24             	mov    %eax,(%esp)
801033fd:	e8 7d 1d 00 00       	call   8010517f <memmove>
    bwrite(dbuf);  // write dst to disk
80103402:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103405:	89 04 24             	mov    %eax,(%esp)
80103408:	e8 df cd ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
8010340d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103410:	89 04 24             	mov    %eax,(%esp)
80103413:	e8 14 ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103418:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341b:	89 04 24             	mov    %eax,(%esp)
8010341e:	e8 09 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103423:	ff 45 f4             	incl   -0xc(%ebp)
80103426:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010342b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342e:	0f 8f 69 ff ff ff    	jg     8010339d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103434:	c9                   	leave  
80103435:	c3                   	ret    

80103436 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103436:	55                   	push   %ebp
80103437:	89 e5                	mov    %esp,%ebp
80103439:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010343c:	a1 d4 49 11 80       	mov    0x801149d4,%eax
80103441:	89 c2                	mov    %eax,%edx
80103443:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80103448:	89 54 24 04          	mov    %edx,0x4(%esp)
8010344c:	89 04 24             	mov    %eax,(%esp)
8010344f:	e8 61 cd ff ff       	call   801001b5 <bread>
80103454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010345a:	83 c0 5c             	add    $0x5c,%eax
8010345d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103463:	8b 00                	mov    (%eax),%eax
80103465:	a3 e8 49 11 80       	mov    %eax,0x801149e8
  for (i = 0; i < log.lh.n; i++) {
8010346a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103471:	eb 1a                	jmp    8010348d <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103473:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103479:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010347d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103480:	83 c2 10             	add    $0x10,%edx
80103483:	89 04 95 ac 49 11 80 	mov    %eax,-0x7feeb654(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010348a:	ff 45 f4             	incl   -0xc(%ebp)
8010348d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80103492:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103495:	7f dc                	jg     80103473 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349a:	89 04 24             	mov    %eax,(%esp)
8010349d:	e8 8a cd ff ff       	call   8010022c <brelse>
}
801034a2:	c9                   	leave  
801034a3:	c3                   	ret    

801034a4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034a4:	55                   	push   %ebp
801034a5:	89 e5                	mov    %esp,%ebp
801034a7:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034aa:	a1 d4 49 11 80       	mov    0x801149d4,%eax
801034af:	89 c2                	mov    %eax,%edx
801034b1:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801034b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ba:	89 04 24             	mov    %eax,(%esp)
801034bd:	e8 f3 cc ff ff       	call   801001b5 <bread>
801034c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c8:	83 c0 5c             	add    $0x5c,%eax
801034cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034ce:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
801034d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e0:	eb 1a                	jmp    801034fc <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801034e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e5:	83 c0 10             	add    $0x10,%eax
801034e8:	8b 0c 85 ac 49 11 80 	mov    -0x7feeb654(,%eax,4),%ecx
801034ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034f5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034f9:	ff 45 f4             	incl   -0xc(%ebp)
801034fc:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80103501:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103504:	7f dc                	jg     801034e2 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103509:	89 04 24             	mov    %eax,(%esp)
8010350c:	e8 db cc ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103514:	89 04 24             	mov    %eax,(%esp)
80103517:	e8 10 cd ff ff       	call   8010022c <brelse>
}
8010351c:	c9                   	leave  
8010351d:	c3                   	ret    

8010351e <recover_from_log>:

static void
recover_from_log(void)
{
8010351e:	55                   	push   %ebp
8010351f:	89 e5                	mov    %esp,%ebp
80103521:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103524:	e8 0d ff ff ff       	call   80103436 <read_head>
  install_trans(); // if committed, copy from log to disk
80103529:	e8 5d fe ff ff       	call   8010338b <install_trans>
  log.lh.n = 0;
8010352e:	c7 05 e8 49 11 80 00 	movl   $0x0,0x801149e8
80103535:	00 00 00 
  write_head(); // clear the log
80103538:	e8 67 ff ff ff       	call   801034a4 <write_head>
}
8010353d:	c9                   	leave  
8010353e:	c3                   	ret    

8010353f <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010353f:	55                   	push   %ebp
80103540:	89 e5                	mov    %esp,%ebp
80103542:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103545:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010354c:	e8 02 19 00 00       	call   80104e53 <acquire>
  while(1){
    if(log.committing){
80103551:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80103556:	85 c0                	test   %eax,%eax
80103558:	74 16                	je     80103570 <begin_op+0x31>
      sleep(&log, &log.lock);
8010355a:	c7 44 24 04 a0 49 11 	movl   $0x801149a0,0x4(%esp)
80103561:	80 
80103562:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80103569:	e8 17 15 00 00       	call   80104a85 <sleep>
8010356e:	eb 4d                	jmp    801035bd <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103570:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80103576:	a1 dc 49 11 80       	mov    0x801149dc,%eax
8010357b:	8d 48 01             	lea    0x1(%eax),%ecx
8010357e:	89 c8                	mov    %ecx,%eax
80103580:	c1 e0 02             	shl    $0x2,%eax
80103583:	01 c8                	add    %ecx,%eax
80103585:	01 c0                	add    %eax,%eax
80103587:	01 d0                	add    %edx,%eax
80103589:	83 f8 1e             	cmp    $0x1e,%eax
8010358c:	7e 16                	jle    801035a4 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010358e:	c7 44 24 04 a0 49 11 	movl   $0x801149a0,0x4(%esp)
80103595:	80 
80103596:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010359d:	e8 e3 14 00 00       	call   80104a85 <sleep>
801035a2:	eb 19                	jmp    801035bd <begin_op+0x7e>
    } else {
      log.outstanding += 1;
801035a4:	a1 dc 49 11 80       	mov    0x801149dc,%eax
801035a9:	40                   	inc    %eax
801035aa:	a3 dc 49 11 80       	mov    %eax,0x801149dc
      release(&log.lock);
801035af:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801035b6:	e8 02 19 00 00       	call   80104ebd <release>
      break;
801035bb:	eb 02                	jmp    801035bf <begin_op+0x80>
    }
  }
801035bd:	eb 92                	jmp    80103551 <begin_op+0x12>
}
801035bf:	c9                   	leave  
801035c0:	c3                   	ret    

801035c1 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035c1:	55                   	push   %ebp
801035c2:	89 e5                	mov    %esp,%ebp
801035c4:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801035c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035ce:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801035d5:	e8 79 18 00 00       	call   80104e53 <acquire>
  log.outstanding -= 1;
801035da:	a1 dc 49 11 80       	mov    0x801149dc,%eax
801035df:	48                   	dec    %eax
801035e0:	a3 dc 49 11 80       	mov    %eax,0x801149dc
  if(log.committing)
801035e5:	a1 e0 49 11 80       	mov    0x801149e0,%eax
801035ea:	85 c0                	test   %eax,%eax
801035ec:	74 0c                	je     801035fa <end_op+0x39>
    panic("log.committing");
801035ee:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
801035f5:	e8 5a cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801035fa:	a1 dc 49 11 80       	mov    0x801149dc,%eax
801035ff:	85 c0                	test   %eax,%eax
80103601:	75 13                	jne    80103616 <end_op+0x55>
    do_commit = 1;
80103603:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010360a:	c7 05 e0 49 11 80 01 	movl   $0x1,0x801149e0
80103611:	00 00 00 
80103614:	eb 0c                	jmp    80103622 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103616:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010361d:	e8 37 15 00 00       	call   80104b59 <wakeup>
  }
  release(&log.lock);
80103622:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80103629:	e8 8f 18 00 00       	call   80104ebd <release>

  if(do_commit){
8010362e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103632:	74 33                	je     80103667 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103634:	e8 db 00 00 00       	call   80103714 <commit>
    acquire(&log.lock);
80103639:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80103640:	e8 0e 18 00 00       	call   80104e53 <acquire>
    log.committing = 0;
80103645:	c7 05 e0 49 11 80 00 	movl   $0x0,0x801149e0
8010364c:	00 00 00 
    wakeup(&log);
8010364f:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80103656:	e8 fe 14 00 00       	call   80104b59 <wakeup>
    release(&log.lock);
8010365b:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80103662:	e8 56 18 00 00       	call   80104ebd <release>
  }
}
80103667:	c9                   	leave  
80103668:	c3                   	ret    

80103669 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103669:	55                   	push   %ebp
8010366a:	89 e5                	mov    %esp,%ebp
8010366c:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010366f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103676:	e9 89 00 00 00       	jmp    80103704 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010367b:	8b 15 d4 49 11 80    	mov    0x801149d4,%edx
80103681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103684:	01 d0                	add    %edx,%eax
80103686:	40                   	inc    %eax
80103687:	89 c2                	mov    %eax,%edx
80103689:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010368e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103692:	89 04 24             	mov    %eax,(%esp)
80103695:	e8 1b cb ff ff       	call   801001b5 <bread>
8010369a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010369d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a0:	83 c0 10             	add    $0x10,%eax
801036a3:	8b 04 85 ac 49 11 80 	mov    -0x7feeb654(,%eax,4),%eax
801036aa:	89 c2                	mov    %eax,%edx
801036ac:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801036b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b5:	89 04 24             	mov    %eax,(%esp)
801036b8:	e8 f8 ca ff ff       	call   801001b5 <bread>
801036bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036c3:	8d 50 5c             	lea    0x5c(%eax),%edx
801036c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036c9:	83 c0 5c             	add    $0x5c,%eax
801036cc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036d3:	00 
801036d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801036d8:	89 04 24             	mov    %eax,(%esp)
801036db:	e8 9f 1a 00 00       	call   8010517f <memmove>
    bwrite(to);  // write the log
801036e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e3:	89 04 24             	mov    %eax,(%esp)
801036e6:	e8 01 cb ff ff       	call   801001ec <bwrite>
    brelse(from);
801036eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ee:	89 04 24             	mov    %eax,(%esp)
801036f1:	e8 36 cb ff ff       	call   8010022c <brelse>
    brelse(to);
801036f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036f9:	89 04 24             	mov    %eax,(%esp)
801036fc:	e8 2b cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103701:	ff 45 f4             	incl   -0xc(%ebp)
80103704:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80103709:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010370c:	0f 8f 69 ff ff ff    	jg     8010367b <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103712:	c9                   	leave  
80103713:	c3                   	ret    

80103714 <commit>:

static void
commit()
{
80103714:	55                   	push   %ebp
80103715:	89 e5                	mov    %esp,%ebp
80103717:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010371a:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010371f:	85 c0                	test   %eax,%eax
80103721:	7e 1e                	jle    80103741 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103723:	e8 41 ff ff ff       	call   80103669 <write_log>
    write_head();    // Write header to disk -- the real commit
80103728:	e8 77 fd ff ff       	call   801034a4 <write_head>
    install_trans(); // Now install writes to home locations
8010372d:	e8 59 fc ff ff       	call   8010338b <install_trans>
    log.lh.n = 0;
80103732:	c7 05 e8 49 11 80 00 	movl   $0x0,0x801149e8
80103739:	00 00 00 
    write_head();    // Erase the transaction from the log
8010373c:	e8 63 fd ff ff       	call   801034a4 <write_head>
  }
}
80103741:	c9                   	leave  
80103742:	c3                   	ret    

80103743 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103743:	55                   	push   %ebp
80103744:	89 e5                	mov    %esp,%ebp
80103746:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103749:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010374e:	83 f8 1d             	cmp    $0x1d,%eax
80103751:	7f 10                	jg     80103763 <log_write+0x20>
80103753:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80103758:	8b 15 d8 49 11 80    	mov    0x801149d8,%edx
8010375e:	4a                   	dec    %edx
8010375f:	39 d0                	cmp    %edx,%eax
80103761:	7c 0c                	jl     8010376f <log_write+0x2c>
    panic("too big a transaction");
80103763:	c7 04 24 b4 8b 10 80 	movl   $0x80108bb4,(%esp)
8010376a:	e8 e5 cd ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
8010376f:	a1 dc 49 11 80       	mov    0x801149dc,%eax
80103774:	85 c0                	test   %eax,%eax
80103776:	7f 0c                	jg     80103784 <log_write+0x41>
    panic("log_write outside of trans");
80103778:	c7 04 24 ca 8b 10 80 	movl   $0x80108bca,(%esp)
8010377f:	e8 d0 cd ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103784:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010378b:	e8 c3 16 00 00       	call   80104e53 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103790:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103797:	eb 1e                	jmp    801037b7 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010379c:	83 c0 10             	add    $0x10,%eax
8010379f:	8b 04 85 ac 49 11 80 	mov    -0x7feeb654(,%eax,4),%eax
801037a6:	89 c2                	mov    %eax,%edx
801037a8:	8b 45 08             	mov    0x8(%ebp),%eax
801037ab:	8b 40 08             	mov    0x8(%eax),%eax
801037ae:	39 c2                	cmp    %eax,%edx
801037b0:	75 02                	jne    801037b4 <log_write+0x71>
      break;
801037b2:	eb 0d                	jmp    801037c1 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037b4:	ff 45 f4             	incl   -0xc(%ebp)
801037b7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801037bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037bf:	7f d8                	jg     80103799 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801037c1:	8b 45 08             	mov    0x8(%ebp),%eax
801037c4:	8b 40 08             	mov    0x8(%eax),%eax
801037c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037ca:	83 c2 10             	add    $0x10,%edx
801037cd:	89 04 95 ac 49 11 80 	mov    %eax,-0x7feeb654(,%edx,4)
  if (i == log.lh.n)
801037d4:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801037d9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037dc:	75 0b                	jne    801037e9 <log_write+0xa6>
    log.lh.n++;
801037de:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801037e3:	40                   	inc    %eax
801037e4:	a3 e8 49 11 80       	mov    %eax,0x801149e8
  b->flags |= B_DIRTY; // prevent eviction
801037e9:	8b 45 08             	mov    0x8(%ebp),%eax
801037ec:	8b 00                	mov    (%eax),%eax
801037ee:	83 c8 04             	or     $0x4,%eax
801037f1:	89 c2                	mov    %eax,%edx
801037f3:	8b 45 08             	mov    0x8(%ebp),%eax
801037f6:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037f8:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801037ff:	e8 b9 16 00 00       	call   80104ebd <release>
}
80103804:	c9                   	leave  
80103805:	c3                   	ret    
	...

80103808 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103808:	55                   	push   %ebp
80103809:	89 e5                	mov    %esp,%ebp
8010380b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010380e:	8b 55 08             	mov    0x8(%ebp),%edx
80103811:	8b 45 0c             	mov    0xc(%ebp),%eax
80103814:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103817:	f0 87 02             	lock xchg %eax,(%edx)
8010381a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010381d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103820:	c9                   	leave  
80103821:	c3                   	ret    

80103822 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103822:	55                   	push   %ebp
80103823:	89 e5                	mov    %esp,%ebp
80103825:	83 e4 f0             	and    $0xfffffff0,%esp
80103828:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010382b:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103832:	80 
80103833:	c7 04 24 50 79 11 80 	movl   $0x80117950,(%esp)
8010383a:	e8 0d f3 ff ff       	call   80102b4c <kinit1>
  kvmalloc();      // kernel page table
8010383f:	e8 e3 44 00 00       	call   80107d27 <kvmalloc>
  mpinit();        // detect other processors
80103844:	e8 c4 03 00 00       	call   80103c0d <mpinit>
  lapicinit();     // interrupt controller
80103849:	e8 4e f6 ff ff       	call   80102e9c <lapicinit>
  seginit();       // segment descriptors
8010384e:	e8 bc 3f 00 00       	call   8010780f <seginit>
  picinit();       // disable pic
80103853:	e8 04 05 00 00       	call   80103d5c <picinit>
  ioapicinit();    // another interrupt controller
80103858:	e8 0c f2 ff ff       	call   80102a69 <ioapicinit>
  consoleinit();   // console hardware
8010385d:	e8 75 d3 ff ff       	call   80100bd7 <consoleinit>
  uartinit();      // serial port
80103862:	e8 34 33 00 00       	call   80106b9b <uartinit>
  pinit();         // process table
80103867:	e8 e6 08 00 00       	call   80104152 <pinit>
  tvinit();        // trap vectors
8010386c:	e8 f7 2e 00 00       	call   80106768 <tvinit>
  binit();         // buffer cache
80103871:	e8 be c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103876:	e8 ed d7 ff ff       	call   80101068 <fileinit>
  ideinit();       // disk 
8010387b:	e8 f5 ed ff ff       	call   80102675 <ideinit>
  startothers();   // start other processors
80103880:	e8 83 00 00 00       	call   80103908 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103885:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010388c:	8e 
8010388d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103894:	e8 eb f2 ff ff       	call   80102b84 <kinit2>
  userinit();      // first user process
80103899:	e8 ce 0a 00 00       	call   8010436c <userinit>
  mpmain();        // finish this processor's setup
8010389e:	e8 1a 00 00 00       	call   801038bd <mpmain>

801038a3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038a3:	55                   	push   %ebp
801038a4:	89 e5                	mov    %esp,%ebp
801038a6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038a9:	e8 90 44 00 00       	call   80107d3e <switchkvm>
  seginit();
801038ae:	e8 5c 3f 00 00       	call   8010780f <seginit>
  lapicinit();
801038b3:	e8 e4 f5 ff ff       	call   80102e9c <lapicinit>
  mpmain();
801038b8:	e8 00 00 00 00       	call   801038bd <mpmain>

801038bd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038bd:	55                   	push   %ebp
801038be:	89 e5                	mov    %esp,%ebp
801038c0:	53                   	push   %ebx
801038c1:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801038c4:	e8 a5 08 00 00       	call   8010416e <cpuid>
801038c9:	89 c3                	mov    %eax,%ebx
801038cb:	e8 9e 08 00 00       	call   8010416e <cpuid>
801038d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801038d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801038d8:	c7 04 24 e5 8b 10 80 	movl   $0x80108be5,(%esp)
801038df:	e8 dd ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801038e4:	e8 dc 2f 00 00       	call   801068c5 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801038e9:	e8 c5 08 00 00       	call   801041b3 <mycpu>
801038ee:	05 a0 00 00 00       	add    $0xa0,%eax
801038f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038fa:	00 
801038fb:	89 04 24             	mov    %eax,(%esp)
801038fe:	e8 05 ff ff ff       	call   80103808 <xchg>
  scheduler();     // start running processes
80103903:	e8 b3 0f 00 00       	call   801048bb <scheduler>

80103908 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103908:	55                   	push   %ebp
80103909:	89 e5                	mov    %esp,%ebp
8010390b:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010390e:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103915:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010391a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010391e:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103925:	80 
80103926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103929:	89 04 24             	mov    %eax,(%esp)
8010392c:	e8 4e 18 00 00       	call   8010517f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103931:	c7 45 f4 a0 4a 11 80 	movl   $0x80114aa0,-0xc(%ebp)
80103938:	eb 75                	jmp    801039af <startothers+0xa7>
    if(c == mycpu())  // We've started already.
8010393a:	e8 74 08 00 00       	call   801041b3 <mycpu>
8010393f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103942:	75 02                	jne    80103946 <startothers+0x3e>
      continue;
80103944:	eb 62                	jmp    801039a8 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103946:	e8 2c f3 ff ff       	call   80102c77 <kalloc>
8010394b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010394e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103951:	83 e8 04             	sub    $0x4,%eax
80103954:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103957:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010395d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010395f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103962:	83 e8 08             	sub    $0x8,%eax
80103965:	c7 00 a3 38 10 80    	movl   $0x801038a3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010396b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010396e:	8d 50 f4             	lea    -0xc(%eax),%edx
80103971:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103976:	05 00 00 00 80       	add    $0x80000000,%eax
8010397b:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
8010397d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103980:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103989:	8a 00                	mov    (%eax),%al
8010398b:	0f b6 c0             	movzbl %al,%eax
8010398e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103992:	89 04 24             	mov    %eax,(%esp)
80103995:	e8 a7 f6 ff ff       	call   80103041 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010399a:	90                   	nop
8010399b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010399e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039a4:	85 c0                	test   %eax,%eax
801039a6:	74 f3                	je     8010399b <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039a8:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039af:	a1 20 50 11 80       	mov    0x80115020,%eax
801039b4:	89 c2                	mov    %eax,%edx
801039b6:	89 d0                	mov    %edx,%eax
801039b8:	c1 e0 02             	shl    $0x2,%eax
801039bb:	01 d0                	add    %edx,%eax
801039bd:	01 c0                	add    %eax,%eax
801039bf:	01 d0                	add    %edx,%eax
801039c1:	c1 e0 04             	shl    $0x4,%eax
801039c4:	05 a0 4a 11 80       	add    $0x80114aa0,%eax
801039c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039cc:	0f 87 68 ff ff ff    	ja     8010393a <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039d2:	c9                   	leave  
801039d3:	c3                   	ret    

801039d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039d4:	55                   	push   %ebp
801039d5:	89 e5                	mov    %esp,%ebp
801039d7:	83 ec 14             	sub    $0x14,%esp
801039da:	8b 45 08             	mov    0x8(%ebp),%eax
801039dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039e4:	89 c2                	mov    %eax,%edx
801039e6:	ec                   	in     (%dx),%al
801039e7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039ea:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801039ed:	c9                   	leave  
801039ee:	c3                   	ret    

801039ef <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039ef:	55                   	push   %ebp
801039f0:	89 e5                	mov    %esp,%ebp
801039f2:	83 ec 08             	sub    $0x8,%esp
801039f5:	8b 45 08             	mov    0x8(%ebp),%eax
801039f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801039fb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801039ff:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a02:	8a 45 f8             	mov    -0x8(%ebp),%al
80103a05:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a08:	ee                   	out    %al,(%dx)
}
80103a09:	c9                   	leave  
80103a0a:	c3                   	ret    

80103a0b <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a0b:	55                   	push   %ebp
80103a0c:	89 e5                	mov    %esp,%ebp
80103a0e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a11:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a1f:	eb 13                	jmp    80103a34 <sum+0x29>
    sum += addr[i];
80103a21:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a24:	8b 45 08             	mov    0x8(%ebp),%eax
80103a27:	01 d0                	add    %edx,%eax
80103a29:	8a 00                	mov    (%eax),%al
80103a2b:	0f b6 c0             	movzbl %al,%eax
80103a2e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a31:	ff 45 fc             	incl   -0x4(%ebp)
80103a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a37:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a3a:	7c e5                	jl     80103a21 <sum+0x16>
    sum += addr[i];
  return sum;
80103a3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a3f:	c9                   	leave  
80103a40:	c3                   	ret    

80103a41 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a41:	55                   	push   %ebp
80103a42:	89 e5                	mov    %esp,%ebp
80103a44:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a47:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4a:	05 00 00 00 80       	add    $0x80000000,%eax
80103a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a52:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a58:	01 d0                	add    %edx,%eax
80103a5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a63:	eb 3f                	jmp    80103aa4 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a65:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a6c:	00 
80103a6d:	c7 44 24 04 fc 8b 10 	movl   $0x80108bfc,0x4(%esp)
80103a74:	80 
80103a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a78:	89 04 24             	mov    %eax,(%esp)
80103a7b:	e8 ad 16 00 00       	call   8010512d <memcmp>
80103a80:	85 c0                	test   %eax,%eax
80103a82:	75 1c                	jne    80103aa0 <mpsearch1+0x5f>
80103a84:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a8b:	00 
80103a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8f:	89 04 24             	mov    %eax,(%esp)
80103a92:	e8 74 ff ff ff       	call   80103a0b <sum>
80103a97:	84 c0                	test   %al,%al
80103a99:	75 05                	jne    80103aa0 <mpsearch1+0x5f>
      return (struct mp*)p;
80103a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9e:	eb 11                	jmp    80103ab1 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103aa0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103aaa:	72 b9                	jb     80103a65 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103aac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ab1:	c9                   	leave  
80103ab2:	c3                   	ret    

80103ab3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ab3:	55                   	push   %ebp
80103ab4:	89 e5                	mov    %esp,%ebp
80103ab6:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ab9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac3:	83 c0 0f             	add    $0xf,%eax
80103ac6:	8a 00                	mov    (%eax),%al
80103ac8:	0f b6 c0             	movzbl %al,%eax
80103acb:	c1 e0 08             	shl    $0x8,%eax
80103ace:	89 c2                	mov    %eax,%edx
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad3:	83 c0 0e             	add    $0xe,%eax
80103ad6:	8a 00                	mov    (%eax),%al
80103ad8:	0f b6 c0             	movzbl %al,%eax
80103adb:	09 d0                	or     %edx,%eax
80103add:	c1 e0 04             	shl    $0x4,%eax
80103ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ae3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ae7:	74 21                	je     80103b0a <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103ae9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103af0:	00 
80103af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af4:	89 04 24             	mov    %eax,(%esp)
80103af7:	e8 45 ff ff ff       	call   80103a41 <mpsearch1>
80103afc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103aff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b03:	74 4e                	je     80103b53 <mpsearch+0xa0>
      return mp;
80103b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b08:	eb 5d                	jmp    80103b67 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0d:	83 c0 14             	add    $0x14,%eax
80103b10:	8a 00                	mov    (%eax),%al
80103b12:	0f b6 c0             	movzbl %al,%eax
80103b15:	c1 e0 08             	shl    $0x8,%eax
80103b18:	89 c2                	mov    %eax,%edx
80103b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1d:	83 c0 13             	add    $0x13,%eax
80103b20:	8a 00                	mov    (%eax),%al
80103b22:	0f b6 c0             	movzbl %al,%eax
80103b25:	09 d0                	or     %edx,%eax
80103b27:	c1 e0 0a             	shl    $0xa,%eax
80103b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	2d 00 04 00 00       	sub    $0x400,%eax
80103b35:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b3c:	00 
80103b3d:	89 04 24             	mov    %eax,(%esp)
80103b40:	e8 fc fe ff ff       	call   80103a41 <mpsearch1>
80103b45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b4c:	74 05                	je     80103b53 <mpsearch+0xa0>
      return mp;
80103b4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b51:	eb 14                	jmp    80103b67 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b53:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b5a:	00 
80103b5b:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b62:	e8 da fe ff ff       	call   80103a41 <mpsearch1>
}
80103b67:	c9                   	leave  
80103b68:	c3                   	ret    

80103b69 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b69:	55                   	push   %ebp
80103b6a:	89 e5                	mov    %esp,%ebp
80103b6c:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b6f:	e8 3f ff ff ff       	call   80103ab3 <mpsearch>
80103b74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b7b:	74 0a                	je     80103b87 <mpconfig+0x1e>
80103b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b80:	8b 40 04             	mov    0x4(%eax),%eax
80103b83:	85 c0                	test   %eax,%eax
80103b85:	75 07                	jne    80103b8e <mpconfig+0x25>
    return 0;
80103b87:	b8 00 00 00 00       	mov    $0x0,%eax
80103b8c:	eb 7d                	jmp    80103c0b <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b91:	8b 40 04             	mov    0x4(%eax),%eax
80103b94:	05 00 00 00 80       	add    $0x80000000,%eax
80103b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b9c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ba3:	00 
80103ba4:	c7 44 24 04 01 8c 10 	movl   $0x80108c01,0x4(%esp)
80103bab:	80 
80103bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103baf:	89 04 24             	mov    %eax,(%esp)
80103bb2:	e8 76 15 00 00       	call   8010512d <memcmp>
80103bb7:	85 c0                	test   %eax,%eax
80103bb9:	74 07                	je     80103bc2 <mpconfig+0x59>
    return 0;
80103bbb:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc0:	eb 49                	jmp    80103c0b <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc5:	8a 40 06             	mov    0x6(%eax),%al
80103bc8:	3c 01                	cmp    $0x1,%al
80103bca:	74 11                	je     80103bdd <mpconfig+0x74>
80103bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcf:	8a 40 06             	mov    0x6(%eax),%al
80103bd2:	3c 04                	cmp    $0x4,%al
80103bd4:	74 07                	je     80103bdd <mpconfig+0x74>
    return 0;
80103bd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bdb:	eb 2e                	jmp    80103c0b <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be0:	8b 40 04             	mov    0x4(%eax),%eax
80103be3:	0f b7 c0             	movzwl %ax,%eax
80103be6:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bed:	89 04 24             	mov    %eax,(%esp)
80103bf0:	e8 16 fe ff ff       	call   80103a0b <sum>
80103bf5:	84 c0                	test   %al,%al
80103bf7:	74 07                	je     80103c00 <mpconfig+0x97>
    return 0;
80103bf9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bfe:	eb 0b                	jmp    80103c0b <mpconfig+0xa2>
  *pmp = mp;
80103c00:	8b 45 08             	mov    0x8(%ebp),%eax
80103c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c06:	89 10                	mov    %edx,(%eax)
  return conf;
80103c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c0b:	c9                   	leave  
80103c0c:	c3                   	ret    

80103c0d <mpinit>:

void
mpinit(void)
{
80103c0d:	55                   	push   %ebp
80103c0e:	89 e5                	mov    %esp,%ebp
80103c10:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c13:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c16:	89 04 24             	mov    %eax,(%esp)
80103c19:	e8 4b ff ff ff       	call   80103b69 <mpconfig>
80103c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c25:	75 0c                	jne    80103c33 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103c27:	c7 04 24 06 8c 10 80 	movl   $0x80108c06,(%esp)
80103c2e:	e8 21 c9 ff ff       	call   80100554 <panic>
  ismp = 1;
80103c33:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3d:	8b 40 24             	mov    0x24(%eax),%eax
80103c40:	a3 9c 49 11 80       	mov    %eax,0x8011499c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c48:	83 c0 2c             	add    $0x2c,%eax
80103c4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c51:	8b 40 04             	mov    0x4(%eax),%eax
80103c54:	0f b7 d0             	movzwl %ax,%edx
80103c57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c5a:	01 d0                	add    %edx,%eax
80103c5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103c5f:	eb 7d                	jmp    80103cde <mpinit+0xd1>
    switch(*p){
80103c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c64:	8a 00                	mov    (%eax),%al
80103c66:	0f b6 c0             	movzbl %al,%eax
80103c69:	83 f8 04             	cmp    $0x4,%eax
80103c6c:	77 68                	ja     80103cd6 <mpinit+0xc9>
80103c6e:	8b 04 85 40 8c 10 80 	mov    -0x7fef73c0(,%eax,4),%eax
80103c75:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103c7d:	a1 20 50 11 80       	mov    0x80115020,%eax
80103c82:	83 f8 07             	cmp    $0x7,%eax
80103c85:	7f 2c                	jg     80103cb3 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103c87:	8b 15 20 50 11 80    	mov    0x80115020,%edx
80103c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c90:	8a 48 01             	mov    0x1(%eax),%cl
80103c93:	89 d0                	mov    %edx,%eax
80103c95:	c1 e0 02             	shl    $0x2,%eax
80103c98:	01 d0                	add    %edx,%eax
80103c9a:	01 c0                	add    %eax,%eax
80103c9c:	01 d0                	add    %edx,%eax
80103c9e:	c1 e0 04             	shl    $0x4,%eax
80103ca1:	05 a0 4a 11 80       	add    $0x80114aa0,%eax
80103ca6:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103ca8:	a1 20 50 11 80       	mov    0x80115020,%eax
80103cad:	40                   	inc    %eax
80103cae:	a3 20 50 11 80       	mov    %eax,0x80115020
      }
      p += sizeof(struct mpproc);
80103cb3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cb7:	eb 25                	jmp    80103cde <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103cbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cc2:	8a 40 01             	mov    0x1(%eax),%al
80103cc5:	a2 80 4a 11 80       	mov    %al,0x80114a80
      p += sizeof(struct mpioapic);
80103cca:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cce:	eb 0e                	jmp    80103cde <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cd0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cd4:	eb 08                	jmp    80103cde <mpinit+0xd1>
    default:
      ismp = 0;
80103cd6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103cdd:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce1:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103ce4:	0f 82 77 ff ff ff    	jb     80103c61 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103cea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cee:	75 0c                	jne    80103cfc <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103cf0:	c7 04 24 20 8c 10 80 	movl   $0x80108c20,(%esp)
80103cf7:	e8 58 c8 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103cfc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103cff:	8a 40 0c             	mov    0xc(%eax),%al
80103d02:	84 c0                	test   %al,%al
80103d04:	74 36                	je     80103d3c <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d06:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d0d:	00 
80103d0e:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d15:	e8 d5 fc ff ff       	call   801039ef <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d1a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d21:	e8 ae fc ff ff       	call   801039d4 <inb>
80103d26:	83 c8 01             	or     $0x1,%eax
80103d29:	0f b6 c0             	movzbl %al,%eax
80103d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d30:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d37:	e8 b3 fc ff ff       	call   801039ef <outb>
  }
}
80103d3c:	c9                   	leave  
80103d3d:	c3                   	ret    
	...

80103d40 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d40:	55                   	push   %ebp
80103d41:	89 e5                	mov    %esp,%ebp
80103d43:	83 ec 08             	sub    $0x8,%esp
80103d46:	8b 45 08             	mov    0x8(%ebp),%eax
80103d49:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d4c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d50:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d53:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d56:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d59:	ee                   	out    %al,(%dx)
}
80103d5a:	c9                   	leave  
80103d5b:	c3                   	ret    

80103d5c <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103d5c:	55                   	push   %ebp
80103d5d:	89 e5                	mov    %esp,%ebp
80103d5f:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d62:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d69:	00 
80103d6a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d71:	e8 ca ff ff ff       	call   80103d40 <outb>
  outb(IO_PIC2+1, 0xFF);
80103d76:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d7d:	00 
80103d7e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d85:	e8 b6 ff ff ff       	call   80103d40 <outb>
}
80103d8a:	c9                   	leave  
80103d8b:	c3                   	ret    

80103d8c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103d8c:	55                   	push   %ebp
80103d8d:	89 e5                	mov    %esp,%ebp
80103d8f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103d92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103d99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103da5:	8b 10                	mov    (%eax),%edx
80103da7:	8b 45 08             	mov    0x8(%ebp),%eax
80103daa:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103dac:	e8 d3 d2 ff ff       	call   80101084 <filealloc>
80103db1:	8b 55 08             	mov    0x8(%ebp),%edx
80103db4:	89 02                	mov    %eax,(%edx)
80103db6:	8b 45 08             	mov    0x8(%ebp),%eax
80103db9:	8b 00                	mov    (%eax),%eax
80103dbb:	85 c0                	test   %eax,%eax
80103dbd:	0f 84 c8 00 00 00    	je     80103e8b <pipealloc+0xff>
80103dc3:	e8 bc d2 ff ff       	call   80101084 <filealloc>
80103dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dcb:	89 02                	mov    %eax,(%edx)
80103dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd0:	8b 00                	mov    (%eax),%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	0f 84 b1 00 00 00    	je     80103e8b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103dda:	e8 98 ee ff ff       	call   80102c77 <kalloc>
80103ddf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103de2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103de6:	75 05                	jne    80103ded <pipealloc+0x61>
    goto bad;
80103de8:	e9 9e 00 00 00       	jmp    80103e8b <pipealloc+0xff>
  p->readopen = 1;
80103ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103df7:	00 00 00 
  p->writeopen = 1;
80103dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e04:	00 00 00 
  p->nwrite = 0;
80103e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e11:	00 00 00 
  p->nread = 0;
80103e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e17:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e1e:	00 00 00 
  initlock(&p->lock, "pipe");
80103e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e24:	c7 44 24 04 54 8c 10 	movl   $0x80108c54,0x4(%esp)
80103e2b:	80 
80103e2c:	89 04 24             	mov    %eax,(%esp)
80103e2f:	e8 fe 0f 00 00       	call   80104e32 <initlock>
  (*f0)->type = FD_PIPE;
80103e34:	8b 45 08             	mov    0x8(%ebp),%eax
80103e37:	8b 00                	mov    (%eax),%eax
80103e39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e42:	8b 00                	mov    (%eax),%eax
80103e44:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e48:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4b:	8b 00                	mov    (%eax),%eax
80103e4d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e51:	8b 45 08             	mov    0x8(%ebp),%eax
80103e54:	8b 00                	mov    (%eax),%eax
80103e56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e59:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5f:	8b 00                	mov    (%eax),%eax
80103e61:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e67:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e6a:	8b 00                	mov    (%eax),%eax
80103e6c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e73:	8b 00                	mov    (%eax),%eax
80103e75:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103e79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e7c:	8b 00                	mov    (%eax),%eax
80103e7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e81:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103e84:	b8 00 00 00 00       	mov    $0x0,%eax
80103e89:	eb 42                	jmp    80103ecd <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103e8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e8f:	74 0b                	je     80103e9c <pipealloc+0x110>
    kfree((char*)p);
80103e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e94:	89 04 24             	mov    %eax,(%esp)
80103e97:	e8 45 ed ff ff       	call   80102be1 <kfree>
  if(*f0)
80103e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9f:	8b 00                	mov    (%eax),%eax
80103ea1:	85 c0                	test   %eax,%eax
80103ea3:	74 0d                	je     80103eb2 <pipealloc+0x126>
    fileclose(*f0);
80103ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea8:	8b 00                	mov    (%eax),%eax
80103eaa:	89 04 24             	mov    %eax,(%esp)
80103ead:	e8 7a d2 ff ff       	call   8010112c <fileclose>
  if(*f1)
80103eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb5:	8b 00                	mov    (%eax),%eax
80103eb7:	85 c0                	test   %eax,%eax
80103eb9:	74 0d                	je     80103ec8 <pipealloc+0x13c>
    fileclose(*f1);
80103ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ebe:	8b 00                	mov    (%eax),%eax
80103ec0:	89 04 24             	mov    %eax,(%esp)
80103ec3:	e8 64 d2 ff ff       	call   8010112c <fileclose>
  return -1;
80103ec8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ecd:	c9                   	leave  
80103ece:	c3                   	ret    

80103ecf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ecf:	55                   	push   %ebp
80103ed0:	89 e5                	mov    %esp,%ebp
80103ed2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed8:	89 04 24             	mov    %eax,(%esp)
80103edb:	e8 73 0f 00 00       	call   80104e53 <acquire>
  if(writable){
80103ee0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103ee4:	74 1f                	je     80103f05 <pipeclose+0x36>
    p->writeopen = 0;
80103ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103ef0:	00 00 00 
    wakeup(&p->nread);
80103ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef6:	05 34 02 00 00       	add    $0x234,%eax
80103efb:	89 04 24             	mov    %eax,(%esp)
80103efe:	e8 56 0c 00 00       	call   80104b59 <wakeup>
80103f03:	eb 1d                	jmp    80103f22 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103f05:	8b 45 08             	mov    0x8(%ebp),%eax
80103f08:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f0f:	00 00 00 
    wakeup(&p->nwrite);
80103f12:	8b 45 08             	mov    0x8(%ebp),%eax
80103f15:	05 38 02 00 00       	add    $0x238,%eax
80103f1a:	89 04 24             	mov    %eax,(%esp)
80103f1d:	e8 37 0c 00 00       	call   80104b59 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f22:	8b 45 08             	mov    0x8(%ebp),%eax
80103f25:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f2b:	85 c0                	test   %eax,%eax
80103f2d:	75 25                	jne    80103f54 <pipeclose+0x85>
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f38:	85 c0                	test   %eax,%eax
80103f3a:	75 18                	jne    80103f54 <pipeclose+0x85>
    release(&p->lock);
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	89 04 24             	mov    %eax,(%esp)
80103f42:	e8 76 0f 00 00       	call   80104ebd <release>
    kfree((char*)p);
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	89 04 24             	mov    %eax,(%esp)
80103f4d:	e8 8f ec ff ff       	call   80102be1 <kfree>
80103f52:	eb 0b                	jmp    80103f5f <pipeclose+0x90>
  } else
    release(&p->lock);
80103f54:	8b 45 08             	mov    0x8(%ebp),%eax
80103f57:	89 04 24             	mov    %eax,(%esp)
80103f5a:	e8 5e 0f 00 00       	call   80104ebd <release>
}
80103f5f:	c9                   	leave  
80103f60:	c3                   	ret    

80103f61 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103f61:	55                   	push   %ebp
80103f62:	89 e5                	mov    %esp,%ebp
80103f64:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103f67:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6a:	89 04 24             	mov    %eax,(%esp)
80103f6d:	e8 e1 0e 00 00       	call   80104e53 <acquire>
  for(i = 0; i < n; i++){
80103f72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f79:	e9 a3 00 00 00       	jmp    80104021 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f7e:	eb 56                	jmp    80103fd6 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103f80:	8b 45 08             	mov    0x8(%ebp),%eax
80103f83:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f89:	85 c0                	test   %eax,%eax
80103f8b:	74 0c                	je     80103f99 <pipewrite+0x38>
80103f8d:	e8 a5 02 00 00       	call   80104237 <myproc>
80103f92:	8b 40 24             	mov    0x24(%eax),%eax
80103f95:	85 c0                	test   %eax,%eax
80103f97:	74 15                	je     80103fae <pipewrite+0x4d>
        release(&p->lock);
80103f99:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9c:	89 04 24             	mov    %eax,(%esp)
80103f9f:	e8 19 0f 00 00       	call   80104ebd <release>
        return -1;
80103fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa9:	e9 9d 00 00 00       	jmp    8010404b <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103fae:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb1:	05 34 02 00 00       	add    $0x234,%eax
80103fb6:	89 04 24             	mov    %eax,(%esp)
80103fb9:	e8 9b 0b 00 00       	call   80104b59 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fc4:	81 c2 38 02 00 00    	add    $0x238,%edx
80103fca:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fce:	89 14 24             	mov    %edx,(%esp)
80103fd1:	e8 af 0a 00 00       	call   80104a85 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd9:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fe8:	05 00 02 00 00       	add    $0x200,%eax
80103fed:	39 c2                	cmp    %eax,%edx
80103fef:	74 8f                	je     80103f80 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ffa:	8d 48 01             	lea    0x1(%eax),%ecx
80103ffd:	8b 55 08             	mov    0x8(%ebp),%edx
80104000:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104006:	25 ff 01 00 00       	and    $0x1ff,%eax
8010400b:	89 c1                	mov    %eax,%ecx
8010400d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104010:	8b 45 0c             	mov    0xc(%ebp),%eax
80104013:	01 d0                	add    %edx,%eax
80104015:	8a 10                	mov    (%eax),%dl
80104017:	8b 45 08             	mov    0x8(%ebp),%eax
8010401a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010401e:	ff 45 f4             	incl   -0xc(%ebp)
80104021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104024:	3b 45 10             	cmp    0x10(%ebp),%eax
80104027:	0f 8c 51 ff ff ff    	jl     80103f7e <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010402d:	8b 45 08             	mov    0x8(%ebp),%eax
80104030:	05 34 02 00 00       	add    $0x234,%eax
80104035:	89 04 24             	mov    %eax,(%esp)
80104038:	e8 1c 0b 00 00       	call   80104b59 <wakeup>
  release(&p->lock);
8010403d:	8b 45 08             	mov    0x8(%ebp),%eax
80104040:	89 04 24             	mov    %eax,(%esp)
80104043:	e8 75 0e 00 00       	call   80104ebd <release>
  return n;
80104048:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010404b:	c9                   	leave  
8010404c:	c3                   	ret    

8010404d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010404d:	55                   	push   %ebp
8010404e:	89 e5                	mov    %esp,%ebp
80104050:	53                   	push   %ebx
80104051:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	89 04 24             	mov    %eax,(%esp)
8010405a:	e8 f4 0d 00 00       	call   80104e53 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010405f:	eb 39                	jmp    8010409a <piperead+0x4d>
    if(myproc()->killed){
80104061:	e8 d1 01 00 00       	call   80104237 <myproc>
80104066:	8b 40 24             	mov    0x24(%eax),%eax
80104069:	85 c0                	test   %eax,%eax
8010406b:	74 15                	je     80104082 <piperead+0x35>
      release(&p->lock);
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	89 04 24             	mov    %eax,(%esp)
80104073:	e8 45 0e 00 00       	call   80104ebd <release>
      return -1;
80104078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010407d:	e9 b3 00 00 00       	jmp    80104135 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104082:	8b 45 08             	mov    0x8(%ebp),%eax
80104085:	8b 55 08             	mov    0x8(%ebp),%edx
80104088:	81 c2 34 02 00 00    	add    $0x234,%edx
8010408e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104092:	89 14 24             	mov    %edx,(%esp)
80104095:	e8 eb 09 00 00       	call   80104a85 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040ac:	39 c2                	cmp    %eax,%edx
801040ae:	75 0d                	jne    801040bd <piperead+0x70>
801040b0:	8b 45 08             	mov    0x8(%ebp),%eax
801040b3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040b9:	85 c0                	test   %eax,%eax
801040bb:	75 a4                	jne    80104061 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801040bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040c4:	eb 49                	jmp    8010410f <piperead+0xc2>
    if(p->nread == p->nwrite)
801040c6:	8b 45 08             	mov    0x8(%ebp),%eax
801040c9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801040cf:	8b 45 08             	mov    0x8(%ebp),%eax
801040d2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040d8:	39 c2                	cmp    %eax,%edx
801040da:	75 02                	jne    801040de <piperead+0x91>
      break;
801040dc:	eb 39                	jmp    80104117 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801040de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040f0:	8d 48 01             	lea    0x1(%eax),%ecx
801040f3:	8b 55 08             	mov    0x8(%ebp),%edx
801040f6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801040fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80104101:	89 c2                	mov    %eax,%edx
80104103:	8b 45 08             	mov    0x8(%ebp),%eax
80104106:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
8010410a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010410c:	ff 45 f4             	incl   -0xc(%ebp)
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	3b 45 10             	cmp    0x10(%ebp),%eax
80104115:	7c af                	jl     801040c6 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	05 38 02 00 00       	add    $0x238,%eax
8010411f:	89 04 24             	mov    %eax,(%esp)
80104122:	e8 32 0a 00 00       	call   80104b59 <wakeup>
  release(&p->lock);
80104127:	8b 45 08             	mov    0x8(%ebp),%eax
8010412a:	89 04 24             	mov    %eax,(%esp)
8010412d:	e8 8b 0d 00 00       	call   80104ebd <release>
  return i;
80104132:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104135:	83 c4 24             	add    $0x24,%esp
80104138:	5b                   	pop    %ebx
80104139:	5d                   	pop    %ebp
8010413a:	c3                   	ret    
	...

8010413c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010413c:	55                   	push   %ebp
8010413d:	89 e5                	mov    %esp,%ebp
8010413f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104142:	9c                   	pushf  
80104143:	58                   	pop    %eax
80104144:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104147:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010414a:	c9                   	leave  
8010414b:	c3                   	ret    

8010414c <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010414c:	55                   	push   %ebp
8010414d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010414f:	fb                   	sti    
}
80104150:	5d                   	pop    %ebp
80104151:	c3                   	ret    

80104152 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104152:	55                   	push   %ebp
80104153:	89 e5                	mov    %esp,%ebp
80104155:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104158:	c7 44 24 04 5c 8c 10 	movl   $0x80108c5c,0x4(%esp)
8010415f:	80 
80104160:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104167:	e8 c6 0c 00 00       	call   80104e32 <initlock>
}
8010416c:	c9                   	leave  
8010416d:	c3                   	ret    

8010416e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010416e:	55                   	push   %ebp
8010416f:	89 e5                	mov    %esp,%ebp
80104171:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104174:	e8 3a 00 00 00       	call   801041b3 <mycpu>
80104179:	89 c2                	mov    %eax,%edx
8010417b:	b8 a0 4a 11 80       	mov    $0x80114aa0,%eax
80104180:	29 c2                	sub    %eax,%edx
80104182:	89 d0                	mov    %edx,%eax
80104184:	c1 f8 04             	sar    $0x4,%eax
80104187:	89 c1                	mov    %eax,%ecx
80104189:	89 ca                	mov    %ecx,%edx
8010418b:	c1 e2 03             	shl    $0x3,%edx
8010418e:	01 ca                	add    %ecx,%edx
80104190:	89 d0                	mov    %edx,%eax
80104192:	c1 e0 05             	shl    $0x5,%eax
80104195:	29 d0                	sub    %edx,%eax
80104197:	c1 e0 02             	shl    $0x2,%eax
8010419a:	01 c8                	add    %ecx,%eax
8010419c:	c1 e0 03             	shl    $0x3,%eax
8010419f:	01 c8                	add    %ecx,%eax
801041a1:	89 c2                	mov    %eax,%edx
801041a3:	c1 e2 0f             	shl    $0xf,%edx
801041a6:	29 c2                	sub    %eax,%edx
801041a8:	c1 e2 02             	shl    $0x2,%edx
801041ab:	01 ca                	add    %ecx,%edx
801041ad:	89 d0                	mov    %edx,%eax
801041af:	f7 d8                	neg    %eax
}
801041b1:	c9                   	leave  
801041b2:	c3                   	ret    

801041b3 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801041b3:	55                   	push   %ebp
801041b4:	89 e5                	mov    %esp,%ebp
801041b6:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801041b9:	e8 7e ff ff ff       	call   8010413c <readeflags>
801041be:	25 00 02 00 00       	and    $0x200,%eax
801041c3:	85 c0                	test   %eax,%eax
801041c5:	74 0c                	je     801041d3 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801041c7:	c7 04 24 64 8c 10 80 	movl   $0x80108c64,(%esp)
801041ce:	e8 81 c3 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801041d3:	e8 1d ee ff ff       	call   80102ff5 <lapicid>
801041d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801041db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041e2:	eb 3b                	jmp    8010421f <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801041e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e7:	89 d0                	mov    %edx,%eax
801041e9:	c1 e0 02             	shl    $0x2,%eax
801041ec:	01 d0                	add    %edx,%eax
801041ee:	01 c0                	add    %eax,%eax
801041f0:	01 d0                	add    %edx,%eax
801041f2:	c1 e0 04             	shl    $0x4,%eax
801041f5:	05 a0 4a 11 80       	add    $0x80114aa0,%eax
801041fa:	8a 00                	mov    (%eax),%al
801041fc:	0f b6 c0             	movzbl %al,%eax
801041ff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104202:	75 18                	jne    8010421c <mycpu+0x69>
      return &cpus[i];
80104204:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104207:	89 d0                	mov    %edx,%eax
80104209:	c1 e0 02             	shl    $0x2,%eax
8010420c:	01 d0                	add    %edx,%eax
8010420e:	01 c0                	add    %eax,%eax
80104210:	01 d0                	add    %edx,%eax
80104212:	c1 e0 04             	shl    $0x4,%eax
80104215:	05 a0 4a 11 80       	add    $0x80114aa0,%eax
8010421a:	eb 19                	jmp    80104235 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010421c:	ff 45 f4             	incl   -0xc(%ebp)
8010421f:	a1 20 50 11 80       	mov    0x80115020,%eax
80104224:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104227:	7c bb                	jl     801041e4 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104229:	c7 04 24 8a 8c 10 80 	movl   $0x80108c8a,(%esp)
80104230:	e8 1f c3 ff ff       	call   80100554 <panic>
}
80104235:	c9                   	leave  
80104236:	c3                   	ret    

80104237 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104237:	55                   	push   %ebp
80104238:	89 e5                	mov    %esp,%ebp
8010423a:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010423d:	e8 70 0d 00 00       	call   80104fb2 <pushcli>
  c = mycpu();
80104242:	e8 6c ff ff ff       	call   801041b3 <mycpu>
80104247:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010424a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104253:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104256:	e8 a1 0d 00 00       	call   80104ffc <popcli>
  return p;
8010425b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010425e:	c9                   	leave  
8010425f:	c3                   	ret    

80104260 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104260:	55                   	push   %ebp
80104261:	89 e5                	mov    %esp,%ebp
80104263:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104266:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
8010426d:	e8 e1 0b 00 00       	call   80104e53 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104272:	c7 45 f4 74 50 11 80 	movl   $0x80115074,-0xc(%ebp)
80104279:	eb 50                	jmp    801042cb <allocproc+0x6b>
    if(p->state == UNUSED)
8010427b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427e:	8b 40 0c             	mov    0xc(%eax),%eax
80104281:	85 c0                	test   %eax,%eax
80104283:	75 42                	jne    801042c7 <allocproc+0x67>
      goto found;
80104285:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104289:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104290:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104295:	8d 50 01             	lea    0x1(%eax),%edx
80104298:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
8010429e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042a1:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801042a4:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
801042ab:	e8 0d 0c 00 00       	call   80104ebd <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801042b0:	e8 c2 e9 ff ff       	call   80102c77 <kalloc>
801042b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042b8:	89 42 08             	mov    %eax,0x8(%edx)
801042bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042be:	8b 40 08             	mov    0x8(%eax),%eax
801042c1:	85 c0                	test   %eax,%eax
801042c3:	75 36                	jne    801042fb <allocproc+0x9b>
801042c5:	eb 23                	jmp    801042ea <allocproc+0x8a>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042c7:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042cb:	81 7d f4 74 70 11 80 	cmpl   $0x80117074,-0xc(%ebp)
801042d2:	72 a7                	jb     8010427b <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801042d4:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
801042db:	e8 dd 0b 00 00       	call   80104ebd <release>
  return 0;
801042e0:	b8 00 00 00 00       	mov    $0x0,%eax
801042e5:	e9 80 00 00 00       	jmp    8010436a <allocproc+0x10a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801042ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801042f4:	b8 00 00 00 00       	mov    $0x0,%eax
801042f9:	eb 6f                	jmp    8010436a <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	8b 40 08             	mov    0x8(%eax),%eax
80104301:	05 00 10 00 00       	add    $0x1000,%eax
80104306:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104309:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104310:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104313:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104316:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010431a:	ba 24 67 10 80       	mov    $0x80106724,%edx
8010431f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104322:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104324:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010432e:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104334:	8b 40 1c             	mov    0x1c(%eax),%eax
80104337:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010433e:	00 
8010433f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104346:	00 
80104347:	89 04 24             	mov    %eax,(%esp)
8010434a:	e8 67 0d 00 00       	call   801050b6 <memset>
  p->context->eip = (uint)forkret;
8010434f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104352:	8b 40 1c             	mov    0x1c(%eax),%eax
80104355:	ba 46 4a 10 80       	mov    $0x80104a46,%edx
8010435a:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104360:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  return p;
80104367:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010436a:	c9                   	leave  
8010436b:	c3                   	ret    

8010436c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010436c:	55                   	push   %ebp
8010436d:	89 e5                	mov    %esp,%ebp
8010436f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104372:	e8 e9 fe ff ff       	call   80104260 <allocproc>
80104377:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437d:	a3 c0 c8 10 80       	mov    %eax,0x8010c8c0
  if((p->pgdir = setupkvm()) == 0)
80104382:	e8 f7 38 00 00       	call   80107c7e <setupkvm>
80104387:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438a:	89 42 04             	mov    %eax,0x4(%edx)
8010438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104390:	8b 40 04             	mov    0x4(%eax),%eax
80104393:	85 c0                	test   %eax,%eax
80104395:	75 0c                	jne    801043a3 <userinit+0x37>
    panic("userinit: out of memory?");
80104397:	c7 04 24 9a 8c 10 80 	movl   $0x80108c9a,(%esp)
8010439e:	e8 b1 c1 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801043a3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ab:	8b 40 04             	mov    0x4(%eax),%eax
801043ae:	89 54 24 08          	mov    %edx,0x8(%esp)
801043b2:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801043b9:	80 
801043ba:	89 04 24             	mov    %eax,(%esp)
801043bd:	e8 1d 3b 00 00       	call   80107edf <inituvm>
  p->sz = PGSIZE;
801043c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801043cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ce:	8b 40 18             	mov    0x18(%eax),%eax
801043d1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801043d8:	00 
801043d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043e0:	00 
801043e1:	89 04 24             	mov    %eax,(%esp)
801043e4:	e8 cd 0c 00 00       	call   801050b6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ec:	8b 40 18             	mov    0x18(%eax),%eax
801043ef:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801043f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f8:	8b 40 18             	mov    0x18(%eax),%eax
801043fb:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104404:	8b 50 18             	mov    0x18(%eax),%edx
80104407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440a:	8b 40 18             	mov    0x18(%eax),%eax
8010440d:	8b 40 2c             	mov    0x2c(%eax),%eax
80104410:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104417:	8b 50 18             	mov    0x18(%eax),%edx
8010441a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441d:	8b 40 18             	mov    0x18(%eax),%eax
80104420:	8b 40 2c             	mov    0x2c(%eax),%eax
80104423:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	8b 40 18             	mov    0x18(%eax),%eax
8010442d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104437:	8b 40 18             	mov    0x18(%eax),%eax
8010443a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104444:	8b 40 18             	mov    0x18(%eax),%eax
80104447:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104451:	83 c0 6c             	add    $0x6c,%eax
80104454:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010445b:	00 
8010445c:	c7 44 24 04 b3 8c 10 	movl   $0x80108cb3,0x4(%esp)
80104463:	80 
80104464:	89 04 24             	mov    %eax,(%esp)
80104467:	e8 56 0e 00 00       	call   801052c2 <safestrcpy>
  p->cwd = namei("/");
8010446c:	c7 04 24 bc 8c 10 80 	movl   $0x80108cbc,(%esp)
80104473:	e8 f3 e0 ff ff       	call   8010256b <namei>
80104478:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010447e:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104485:	e8 c9 09 00 00       	call   80104e53 <acquire>

  p->state = RUNNABLE;
8010448a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104494:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
8010449b:	e8 1d 0a 00 00       	call   80104ebd <release>
}
801044a0:	c9                   	leave  
801044a1:	c3                   	ret    

801044a2 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801044a2:	55                   	push   %ebp
801044a3:	89 e5                	mov    %esp,%ebp
801044a5:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801044a8:	e8 8a fd ff ff       	call   80104237 <myproc>
801044ad:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801044b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b3:	8b 00                	mov    (%eax),%eax
801044b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801044b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044bc:	7e 31                	jle    801044ef <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801044be:	8b 55 08             	mov    0x8(%ebp),%edx
801044c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c4:	01 c2                	add    %eax,%edx
801044c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c9:	8b 40 04             	mov    0x4(%eax),%eax
801044cc:	89 54 24 08          	mov    %edx,0x8(%esp)
801044d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801044d7:	89 04 24             	mov    %eax,(%esp)
801044da:	e8 6b 3b 00 00       	call   8010804a <allocuvm>
801044df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044e6:	75 3e                	jne    80104526 <growproc+0x84>
      return -1;
801044e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ed:	eb 4f                	jmp    8010453e <growproc+0x9c>
  } else if(n < 0){
801044ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044f3:	79 31                	jns    80104526 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801044f5:	8b 55 08             	mov    0x8(%ebp),%edx
801044f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fb:	01 c2                	add    %eax,%edx
801044fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104500:	8b 40 04             	mov    0x4(%eax),%eax
80104503:	89 54 24 08          	mov    %edx,0x8(%esp)
80104507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010450e:	89 04 24             	mov    %eax,(%esp)
80104511:	e8 4a 3c 00 00       	call   80108160 <deallocuvm>
80104516:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104519:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010451d:	75 07                	jne    80104526 <growproc+0x84>
      return -1;
8010451f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104524:	eb 18                	jmp    8010453e <growproc+0x9c>
  }
  curproc->sz = sz;
80104526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104529:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010452c:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010452e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104531:	89 04 24             	mov    %eax,(%esp)
80104534:	e8 1f 38 00 00       	call   80107d58 <switchuvm>
  return 0;
80104539:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010453e:	c9                   	leave  
8010453f:	c3                   	ret    

80104540 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104540:	55                   	push   %ebp
80104541:	89 e5                	mov    %esp,%ebp
80104543:	57                   	push   %edi
80104544:	56                   	push   %esi
80104545:	53                   	push   %ebx
80104546:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104549:	e8 e9 fc ff ff       	call   80104237 <myproc>
8010454e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104551:	e8 0a fd ff ff       	call   80104260 <allocproc>
80104556:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104559:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010455d:	75 0a                	jne    80104569 <fork+0x29>
    return -1;
8010455f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104564:	e9 35 01 00 00       	jmp    8010469e <fork+0x15e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104569:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010456c:	8b 10                	mov    (%eax),%edx
8010456e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104571:	8b 40 04             	mov    0x4(%eax),%eax
80104574:	89 54 24 04          	mov    %edx,0x4(%esp)
80104578:	89 04 24             	mov    %eax,(%esp)
8010457b:	e8 80 3d 00 00       	call   80108300 <copyuvm>
80104580:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104583:	89 42 04             	mov    %eax,0x4(%edx)
80104586:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104589:	8b 40 04             	mov    0x4(%eax),%eax
8010458c:	85 c0                	test   %eax,%eax
8010458e:	75 2c                	jne    801045bc <fork+0x7c>
    kfree(np->kstack);
80104590:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104593:	8b 40 08             	mov    0x8(%eax),%eax
80104596:	89 04 24             	mov    %eax,(%esp)
80104599:	e8 43 e6 ff ff       	call   80102be1 <kfree>
    np->kstack = 0;
8010459e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801045a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045ab:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801045b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b7:	e9 e2 00 00 00       	jmp    8010469e <fork+0x15e>
  }
  np->sz = curproc->sz;
801045bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045bf:	8b 10                	mov    (%eax),%edx
801045c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045c4:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801045c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801045cc:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801045cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d2:	8b 50 18             	mov    0x18(%eax),%edx
801045d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045d8:	8b 40 18             	mov    0x18(%eax),%eax
801045db:	89 c3                	mov    %eax,%ebx
801045dd:	b8 13 00 00 00       	mov    $0x13,%eax
801045e2:	89 d7                	mov    %edx,%edi
801045e4:	89 de                	mov    %ebx,%esi
801045e6:	89 c1                	mov    %eax,%ecx
801045e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801045ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045ed:	8b 40 18             	mov    0x18(%eax),%eax
801045f0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801045f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801045fe:	eb 36                	jmp    80104636 <fork+0xf6>
    if(curproc->ofile[i])
80104600:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104603:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104606:	83 c2 08             	add    $0x8,%edx
80104609:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010460d:	85 c0                	test   %eax,%eax
8010460f:	74 22                	je     80104633 <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104611:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104614:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104617:	83 c2 08             	add    $0x8,%edx
8010461a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010461e:	89 04 24             	mov    %eax,(%esp)
80104621:	e8 be ca ff ff       	call   801010e4 <filedup>
80104626:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104629:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010462c:	83 c1 08             	add    $0x8,%ecx
8010462f:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104633:	ff 45 e4             	incl   -0x1c(%ebp)
80104636:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010463a:	7e c4                	jle    80104600 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
8010463c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010463f:	8b 40 68             	mov    0x68(%eax),%eax
80104642:	89 04 24             	mov    %eax,(%esp)
80104645:	e8 ca d3 ff ff       	call   80101a14 <idup>
8010464a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010464d:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104650:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104653:	8d 50 6c             	lea    0x6c(%eax),%edx
80104656:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104659:	83 c0 6c             	add    $0x6c,%eax
8010465c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104663:	00 
80104664:	89 54 24 04          	mov    %edx,0x4(%esp)
80104668:	89 04 24             	mov    %eax,(%esp)
8010466b:	e8 52 0c 00 00       	call   801052c2 <safestrcpy>

  pid = np->pid;
80104670:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104673:	8b 40 10             	mov    0x10(%eax),%eax
80104676:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104679:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104680:	e8 ce 07 00 00       	call   80104e53 <acquire>

  np->state = RUNNABLE;
80104685:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104688:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010468f:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104696:	e8 22 08 00 00       	call   80104ebd <release>

  return pid;
8010469b:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010469e:	83 c4 2c             	add    $0x2c,%esp
801046a1:	5b                   	pop    %ebx
801046a2:	5e                   	pop    %esi
801046a3:	5f                   	pop    %edi
801046a4:	5d                   	pop    %ebp
801046a5:	c3                   	ret    

801046a6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801046a6:	55                   	push   %ebp
801046a7:	89 e5                	mov    %esp,%ebp
801046a9:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801046ac:	e8 86 fb ff ff       	call   80104237 <myproc>
801046b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801046b4:	a1 c0 c8 10 80       	mov    0x8010c8c0,%eax
801046b9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801046bc:	75 0c                	jne    801046ca <exit+0x24>
    panic("init exiting");
801046be:	c7 04 24 be 8c 10 80 	movl   $0x80108cbe,(%esp)
801046c5:	e8 8a be ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801046ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801046d1:	eb 3a                	jmp    8010470d <exit+0x67>
    if(curproc->ofile[fd]){
801046d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046d9:	83 c2 08             	add    $0x8,%edx
801046dc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046e0:	85 c0                	test   %eax,%eax
801046e2:	74 26                	je     8010470a <exit+0x64>
      fileclose(curproc->ofile[fd]);
801046e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046ea:	83 c2 08             	add    $0x8,%edx
801046ed:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f1:	89 04 24             	mov    %eax,(%esp)
801046f4:	e8 33 ca ff ff       	call   8010112c <fileclose>
      curproc->ofile[fd] = 0;
801046f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046ff:	83 c2 08             	add    $0x8,%edx
80104702:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104709:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010470a:	ff 45 f0             	incl   -0x10(%ebp)
8010470d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104711:	7e c0                	jle    801046d3 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104713:	e8 27 ee ff ff       	call   8010353f <begin_op>
  iput(curproc->cwd);
80104718:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010471b:	8b 40 68             	mov    0x68(%eax),%eax
8010471e:	89 04 24             	mov    %eax,(%esp)
80104721:	e8 6e d4 ff ff       	call   80101b94 <iput>
  end_op();
80104726:	e8 96 ee ff ff       	call   801035c1 <end_op>
  curproc->cwd = 0;
8010472b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010472e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104735:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
8010473c:	e8 12 07 00 00       	call   80104e53 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104741:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104744:	8b 40 14             	mov    0x14(%eax),%eax
80104747:	89 04 24             	mov    %eax,(%esp)
8010474a:	e8 cc 03 00 00       	call   80104b1b <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010474f:	c7 45 f4 74 50 11 80 	movl   $0x80115074,-0xc(%ebp)
80104756:	eb 33                	jmp    8010478b <exit+0xe5>
    if(p->parent == curproc){
80104758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475b:	8b 40 14             	mov    0x14(%eax),%eax
8010475e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104761:	75 24                	jne    80104787 <exit+0xe1>
      p->parent = initproc;
80104763:	8b 15 c0 c8 10 80    	mov    0x8010c8c0,%edx
80104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010476f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104772:	8b 40 0c             	mov    0xc(%eax),%eax
80104775:	83 f8 05             	cmp    $0x5,%eax
80104778:	75 0d                	jne    80104787 <exit+0xe1>
        wakeup1(initproc);
8010477a:	a1 c0 c8 10 80       	mov    0x8010c8c0,%eax
8010477f:	89 04 24             	mov    %eax,(%esp)
80104782:	e8 94 03 00 00       	call   80104b1b <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104787:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010478b:	81 7d f4 74 70 11 80 	cmpl   $0x80117074,-0xc(%ebp)
80104792:	72 c4                	jb     80104758 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104794:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104797:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010479e:	e8 c3 01 00 00       	call   80104966 <sched>
  panic("zombie exit");
801047a3:	c7 04 24 cb 8c 10 80 	movl   $0x80108ccb,(%esp)
801047aa:	e8 a5 bd ff ff       	call   80100554 <panic>

801047af <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801047af:	55                   	push   %ebp
801047b0:	89 e5                	mov    %esp,%ebp
801047b2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801047b5:	e8 7d fa ff ff       	call   80104237 <myproc>
801047ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801047bd:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
801047c4:	e8 8a 06 00 00       	call   80104e53 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801047c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047d0:	c7 45 f4 74 50 11 80 	movl   $0x80115074,-0xc(%ebp)
801047d7:	e9 95 00 00 00       	jmp    80104871 <wait+0xc2>
      if(p->parent != curproc)
801047dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047df:	8b 40 14             	mov    0x14(%eax),%eax
801047e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801047e5:	74 05                	je     801047ec <wait+0x3d>
        continue;
801047e7:	e9 81 00 00 00       	jmp    8010486d <wait+0xbe>
      havekids = 1;
801047ec:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801047f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f6:	8b 40 0c             	mov    0xc(%eax),%eax
801047f9:	83 f8 05             	cmp    $0x5,%eax
801047fc:	75 6f                	jne    8010486d <wait+0xbe>
        // Found one.
        pid = p->pid;
801047fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104801:	8b 40 10             	mov    0x10(%eax),%eax
80104804:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480a:	8b 40 08             	mov    0x8(%eax),%eax
8010480d:	89 04 24             	mov    %eax,(%esp)
80104810:	e8 cc e3 ff ff       	call   80102be1 <kfree>
        p->kstack = 0;
80104815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104818:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104822:	8b 40 04             	mov    0x4(%eax),%eax
80104825:	89 04 24             	mov    %eax,(%esp)
80104828:	e8 f7 39 00 00       	call   80108224 <freevm>
        p->pid = 0;
8010482d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104830:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104844:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104855:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010485c:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104863:	e8 55 06 00 00       	call   80104ebd <release>
        return pid;
80104868:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010486b:	eb 4c                	jmp    801048b9 <wait+0x10a>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010486d:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104871:	81 7d f4 74 70 11 80 	cmpl   $0x80117074,-0xc(%ebp)
80104878:	0f 82 5e ff ff ff    	jb     801047dc <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010487e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104882:	74 0a                	je     8010488e <wait+0xdf>
80104884:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104887:	8b 40 24             	mov    0x24(%eax),%eax
8010488a:	85 c0                	test   %eax,%eax
8010488c:	74 13                	je     801048a1 <wait+0xf2>
      release(&ptable.lock);
8010488e:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104895:	e8 23 06 00 00       	call   80104ebd <release>
      return -1;
8010489a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010489f:	eb 18                	jmp    801048b9 <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801048a1:	c7 44 24 04 40 50 11 	movl   $0x80115040,0x4(%esp)
801048a8:	80 
801048a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048ac:	89 04 24             	mov    %eax,(%esp)
801048af:	e8 d1 01 00 00       	call   80104a85 <sleep>
  }
801048b4:	e9 10 ff ff ff       	jmp    801047c9 <wait+0x1a>
}
801048b9:	c9                   	leave  
801048ba:	c3                   	ret    

801048bb <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801048bb:	55                   	push   %ebp
801048bc:	89 e5                	mov    %esp,%ebp
801048be:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801048c1:	e8 ed f8 ff ff       	call   801041b3 <mycpu>
801048c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801048c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cc:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801048d3:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801048d6:	e8 71 f8 ff ff       	call   8010414c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801048db:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
801048e2:	e8 6c 05 00 00       	call   80104e53 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048e7:	c7 45 f4 74 50 11 80 	movl   $0x80115074,-0xc(%ebp)
801048ee:	eb 5c                	jmp    8010494c <scheduler+0x91>
      if(p->state != RUNNABLE)
801048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f3:	8b 40 0c             	mov    0xc(%eax),%eax
801048f6:	83 f8 03             	cmp    $0x3,%eax
801048f9:	74 02                	je     801048fd <scheduler+0x42>
        continue;
801048fb:	eb 4b                	jmp    80104948 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801048fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104900:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104903:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490c:	89 04 24             	mov    %eax,(%esp)
8010490f:	e8 44 34 00 00       	call   80107d58 <switchuvm>
      p->state = RUNNING;
80104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104917:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010491e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104921:	8b 40 1c             	mov    0x1c(%eax),%eax
80104924:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104927:	83 c2 04             	add    $0x4,%edx
8010492a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010492e:	89 14 24             	mov    %edx,(%esp)
80104931:	e8 fa 09 00 00       	call   80105330 <swtch>
      switchkvm();
80104936:	e8 03 34 00 00       	call   80107d3e <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010493b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010493e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104945:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104948:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010494c:	81 7d f4 74 70 11 80 	cmpl   $0x80117074,-0xc(%ebp)
80104953:	72 9b                	jb     801048f0 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104955:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
8010495c:	e8 5c 05 00 00       	call   80104ebd <release>

  }
80104961:	e9 70 ff ff ff       	jmp    801048d6 <scheduler+0x1b>

80104966 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104966:	55                   	push   %ebp
80104967:	89 e5                	mov    %esp,%ebp
80104969:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
8010496c:	e8 c6 f8 ff ff       	call   80104237 <myproc>
80104971:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104974:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
8010497b:	e8 01 06 00 00       	call   80104f81 <holding>
80104980:	85 c0                	test   %eax,%eax
80104982:	75 0c                	jne    80104990 <sched+0x2a>
    panic("sched ptable.lock");
80104984:	c7 04 24 d7 8c 10 80 	movl   $0x80108cd7,(%esp)
8010498b:	e8 c4 bb ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104990:	e8 1e f8 ff ff       	call   801041b3 <mycpu>
80104995:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010499b:	83 f8 01             	cmp    $0x1,%eax
8010499e:	74 0c                	je     801049ac <sched+0x46>
    panic("sched locks");
801049a0:	c7 04 24 e9 8c 10 80 	movl   $0x80108ce9,(%esp)
801049a7:	e8 a8 bb ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
801049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049af:	8b 40 0c             	mov    0xc(%eax),%eax
801049b2:	83 f8 04             	cmp    $0x4,%eax
801049b5:	75 0c                	jne    801049c3 <sched+0x5d>
    panic("sched running");
801049b7:	c7 04 24 f5 8c 10 80 	movl   $0x80108cf5,(%esp)
801049be:	e8 91 bb ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
801049c3:	e8 74 f7 ff ff       	call   8010413c <readeflags>
801049c8:	25 00 02 00 00       	and    $0x200,%eax
801049cd:	85 c0                	test   %eax,%eax
801049cf:	74 0c                	je     801049dd <sched+0x77>
    panic("sched interruptible");
801049d1:	c7 04 24 03 8d 10 80 	movl   $0x80108d03,(%esp)
801049d8:	e8 77 bb ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
801049dd:	e8 d1 f7 ff ff       	call   801041b3 <mycpu>
801049e2:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801049e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801049eb:	e8 c3 f7 ff ff       	call   801041b3 <mycpu>
801049f0:	8b 40 04             	mov    0x4(%eax),%eax
801049f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049f6:	83 c2 1c             	add    $0x1c,%edx
801049f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801049fd:	89 14 24             	mov    %edx,(%esp)
80104a00:	e8 2b 09 00 00       	call   80105330 <swtch>
  mycpu()->intena = intena;
80104a05:	e8 a9 f7 ff ff       	call   801041b3 <mycpu>
80104a0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a0d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104a13:	c9                   	leave  
80104a14:	c3                   	ret    

80104a15 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a15:	55                   	push   %ebp
80104a16:	89 e5                	mov    %esp,%ebp
80104a18:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a1b:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104a22:	e8 2c 04 00 00       	call   80104e53 <acquire>
  myproc()->state = RUNNABLE;
80104a27:	e8 0b f8 ff ff       	call   80104237 <myproc>
80104a2c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a33:	e8 2e ff ff ff       	call   80104966 <sched>
  release(&ptable.lock);
80104a38:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104a3f:	e8 79 04 00 00       	call   80104ebd <release>
}
80104a44:	c9                   	leave  
80104a45:	c3                   	ret    

80104a46 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a46:	55                   	push   %ebp
80104a47:	89 e5                	mov    %esp,%ebp
80104a49:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a4c:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104a53:	e8 65 04 00 00       	call   80104ebd <release>

  if (first) {
80104a58:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104a5d:	85 c0                	test   %eax,%eax
80104a5f:	74 22                	je     80104a83 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104a61:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104a68:	00 00 00 
    iinit(ROOTDEV);
80104a6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104a72:	e8 68 cc ff ff       	call   801016df <iinit>
    initlog(ROOTDEV);
80104a77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104a7e:	e8 bd e8 ff ff       	call   80103340 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104a83:	c9                   	leave  
80104a84:	c3                   	ret    

80104a85 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a85:	55                   	push   %ebp
80104a86:	89 e5                	mov    %esp,%ebp
80104a88:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104a8b:	e8 a7 f7 ff ff       	call   80104237 <myproc>
80104a90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104a93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a97:	75 0c                	jne    80104aa5 <sleep+0x20>
    panic("sleep");
80104a99:	c7 04 24 17 8d 10 80 	movl   $0x80108d17,(%esp)
80104aa0:	e8 af ba ff ff       	call   80100554 <panic>

  if(lk == 0)
80104aa5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104aa9:	75 0c                	jne    80104ab7 <sleep+0x32>
    panic("sleep without lk");
80104aab:	c7 04 24 1d 8d 10 80 	movl   $0x80108d1d,(%esp)
80104ab2:	e8 9d ba ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104ab7:	81 7d 0c 40 50 11 80 	cmpl   $0x80115040,0xc(%ebp)
80104abe:	74 17                	je     80104ad7 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ac0:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104ac7:	e8 87 03 00 00       	call   80104e53 <acquire>
    release(lk);
80104acc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104acf:	89 04 24             	mov    %eax,(%esp)
80104ad2:	e8 e6 03 00 00       	call   80104ebd <release>
  }
  // Go to sleep.
  p->chan = chan;
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	8b 55 08             	mov    0x8(%ebp),%edx
80104add:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104aea:	e8 77 fe ff ff       	call   80104966 <sched>

  // Tidy up.
  p->chan = 0;
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104af9:	81 7d 0c 40 50 11 80 	cmpl   $0x80115040,0xc(%ebp)
80104b00:	74 17                	je     80104b19 <sleep+0x94>
    release(&ptable.lock);
80104b02:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104b09:	e8 af 03 00 00       	call   80104ebd <release>
    acquire(lk);
80104b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b11:	89 04 24             	mov    %eax,(%esp)
80104b14:	e8 3a 03 00 00       	call   80104e53 <acquire>
  }
}
80104b19:	c9                   	leave  
80104b1a:	c3                   	ret    

80104b1b <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b1b:	55                   	push   %ebp
80104b1c:	89 e5                	mov    %esp,%ebp
80104b1e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b21:	c7 45 fc 74 50 11 80 	movl   $0x80115074,-0x4(%ebp)
80104b28:	eb 24                	jmp    80104b4e <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104b2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b2d:	8b 40 0c             	mov    0xc(%eax),%eax
80104b30:	83 f8 02             	cmp    $0x2,%eax
80104b33:	75 15                	jne    80104b4a <wakeup1+0x2f>
80104b35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b38:	8b 40 20             	mov    0x20(%eax),%eax
80104b3b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b3e:	75 0a                	jne    80104b4a <wakeup1+0x2f>
      p->state = RUNNABLE;
80104b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b43:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b4a:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104b4e:	81 7d fc 74 70 11 80 	cmpl   $0x80117074,-0x4(%ebp)
80104b55:	72 d3                	jb     80104b2a <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104b57:	c9                   	leave  
80104b58:	c3                   	ret    

80104b59 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b59:	55                   	push   %ebp
80104b5a:	89 e5                	mov    %esp,%ebp
80104b5c:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104b5f:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104b66:	e8 e8 02 00 00       	call   80104e53 <acquire>
  wakeup1(chan);
80104b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6e:	89 04 24             	mov    %eax,(%esp)
80104b71:	e8 a5 ff ff ff       	call   80104b1b <wakeup1>
  release(&ptable.lock);
80104b76:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104b7d:	e8 3b 03 00 00       	call   80104ebd <release>
}
80104b82:	c9                   	leave  
80104b83:	c3                   	ret    

80104b84 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104b84:	55                   	push   %ebp
80104b85:	89 e5                	mov    %esp,%ebp
80104b87:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104b8a:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104b91:	e8 bd 02 00 00       	call   80104e53 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b96:	c7 45 f4 74 50 11 80 	movl   $0x80115074,-0xc(%ebp)
80104b9d:	eb 41                	jmp    80104be0 <kill+0x5c>
    if(p->pid == pid){
80104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba2:	8b 40 10             	mov    0x10(%eax),%eax
80104ba5:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ba8:	75 32                	jne    80104bdc <kill+0x58>
      p->killed = 1;
80104baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bad:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb7:	8b 40 0c             	mov    0xc(%eax),%eax
80104bba:	83 f8 02             	cmp    $0x2,%eax
80104bbd:	75 0a                	jne    80104bc9 <kill+0x45>
        p->state = RUNNABLE;
80104bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104bc9:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104bd0:	e8 e8 02 00 00       	call   80104ebd <release>
      return 0;
80104bd5:	b8 00 00 00 00       	mov    $0x0,%eax
80104bda:	eb 1e                	jmp    80104bfa <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bdc:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104be0:	81 7d f4 74 70 11 80 	cmpl   $0x80117074,-0xc(%ebp)
80104be7:	72 b6                	jb     80104b9f <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104be9:	c7 04 24 40 50 11 80 	movl   $0x80115040,(%esp)
80104bf0:	e8 c8 02 00 00       	call   80104ebd <release>
  return -1;
80104bf5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104bfa:	c9                   	leave  
80104bfb:	c3                   	ret    

80104bfc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104bfc:	55                   	push   %ebp
80104bfd:	89 e5                	mov    %esp,%ebp
80104bff:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c02:	c7 45 f0 74 50 11 80 	movl   $0x80115074,-0x10(%ebp)
80104c09:	e9 d5 00 00 00       	jmp    80104ce3 <procdump+0xe7>
    if(p->state == UNUSED)
80104c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c11:	8b 40 0c             	mov    0xc(%eax),%eax
80104c14:	85 c0                	test   %eax,%eax
80104c16:	75 05                	jne    80104c1d <procdump+0x21>
      continue;
80104c18:	e9 c2 00 00 00       	jmp    80104cdf <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c20:	8b 40 0c             	mov    0xc(%eax),%eax
80104c23:	83 f8 05             	cmp    $0x5,%eax
80104c26:	77 23                	ja     80104c4b <procdump+0x4f>
80104c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c2b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c2e:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104c35:	85 c0                	test   %eax,%eax
80104c37:	74 12                	je     80104c4b <procdump+0x4f>
      state = states[p->state];
80104c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c3f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104c46:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c49:	eb 07                	jmp    80104c52 <procdump+0x56>
    else
      state = "???";
80104c4b:	c7 45 ec 2e 8d 10 80 	movl   $0x80108d2e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c55:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c5b:	8b 40 10             	mov    0x10(%eax),%eax
80104c5e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104c62:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c65:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c69:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c6d:	c7 04 24 32 8d 10 80 	movl   $0x80108d32,(%esp)
80104c74:	e8 48 b7 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c7f:	83 f8 02             	cmp    $0x2,%eax
80104c82:	75 4f                	jne    80104cd3 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c87:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c8a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8d:	83 c0 08             	add    $0x8,%eax
80104c90:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104c93:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c97:	89 04 24             	mov    %eax,(%esp)
80104c9a:	e8 6b 02 00 00       	call   80104f0a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104c9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ca6:	eb 1a                	jmp    80104cc2 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cab:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104caf:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cb3:	c7 04 24 3b 8d 10 80 	movl   $0x80108d3b,(%esp)
80104cba:	e8 02 b7 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104cbf:	ff 45 f4             	incl   -0xc(%ebp)
80104cc2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104cc6:	7f 0b                	jg     80104cd3 <procdump+0xd7>
80104cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ccf:	85 c0                	test   %eax,%eax
80104cd1:	75 d5                	jne    80104ca8 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104cd3:	c7 04 24 3f 8d 10 80 	movl   $0x80108d3f,(%esp)
80104cda:	e8 e2 b6 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cdf:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104ce3:	81 7d f0 74 70 11 80 	cmpl   $0x80117074,-0x10(%ebp)
80104cea:	0f 82 1e ff ff ff    	jb     80104c0e <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104cf0:	c9                   	leave  
80104cf1:	c3                   	ret    
	...

80104cf4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104cf4:	55                   	push   %ebp
80104cf5:	89 e5                	mov    %esp,%ebp
80104cf7:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfd:	83 c0 04             	add    $0x4,%eax
80104d00:	c7 44 24 04 6b 8d 10 	movl   $0x80108d6b,0x4(%esp)
80104d07:	80 
80104d08:	89 04 24             	mov    %eax,(%esp)
80104d0b:	e8 22 01 00 00       	call   80104e32 <initlock>
  lk->name = name;
80104d10:	8b 45 08             	mov    0x8(%ebp),%eax
80104d13:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d16:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104d19:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104d22:	8b 45 08             	mov    0x8(%ebp),%eax
80104d25:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104d2c:	c9                   	leave  
80104d2d:	c3                   	ret    

80104d2e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104d2e:	55                   	push   %ebp
80104d2f:	89 e5                	mov    %esp,%ebp
80104d31:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104d34:	8b 45 08             	mov    0x8(%ebp),%eax
80104d37:	83 c0 04             	add    $0x4,%eax
80104d3a:	89 04 24             	mov    %eax,(%esp)
80104d3d:	e8 11 01 00 00       	call   80104e53 <acquire>
  while (lk->locked) {
80104d42:	eb 15                	jmp    80104d59 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104d44:	8b 45 08             	mov    0x8(%ebp),%eax
80104d47:	83 c0 04             	add    $0x4,%eax
80104d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d51:	89 04 24             	mov    %eax,(%esp)
80104d54:	e8 2c fd ff ff       	call   80104a85 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104d59:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5c:	8b 00                	mov    (%eax),%eax
80104d5e:	85 c0                	test   %eax,%eax
80104d60:	75 e2                	jne    80104d44 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104d62:	8b 45 08             	mov    0x8(%ebp),%eax
80104d65:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104d6b:	e8 c7 f4 ff ff       	call   80104237 <myproc>
80104d70:	8b 50 10             	mov    0x10(%eax),%edx
80104d73:	8b 45 08             	mov    0x8(%ebp),%eax
80104d76:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104d79:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7c:	83 c0 04             	add    $0x4,%eax
80104d7f:	89 04 24             	mov    %eax,(%esp)
80104d82:	e8 36 01 00 00       	call   80104ebd <release>
}
80104d87:	c9                   	leave  
80104d88:	c3                   	ret    

80104d89 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104d89:	55                   	push   %ebp
80104d8a:	89 e5                	mov    %esp,%ebp
80104d8c:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d92:	83 c0 04             	add    $0x4,%eax
80104d95:	89 04 24             	mov    %eax,(%esp)
80104d98:	e8 b6 00 00 00       	call   80104e53 <acquire>
  lk->locked = 0;
80104d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104da0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104da6:	8b 45 08             	mov    0x8(%ebp),%eax
80104da9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104db0:	8b 45 08             	mov    0x8(%ebp),%eax
80104db3:	89 04 24             	mov    %eax,(%esp)
80104db6:	e8 9e fd ff ff       	call   80104b59 <wakeup>
  release(&lk->lk);
80104dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbe:	83 c0 04             	add    $0x4,%eax
80104dc1:	89 04 24             	mov    %eax,(%esp)
80104dc4:	e8 f4 00 00 00       	call   80104ebd <release>
}
80104dc9:	c9                   	leave  
80104dca:	c3                   	ret    

80104dcb <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104dcb:	55                   	push   %ebp
80104dcc:	89 e5                	mov    %esp,%ebp
80104dce:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd4:	83 c0 04             	add    $0x4,%eax
80104dd7:	89 04 24             	mov    %eax,(%esp)
80104dda:	e8 74 00 00 00       	call   80104e53 <acquire>
  r = lk->locked;
80104ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80104de2:	8b 00                	mov    (%eax),%eax
80104de4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104de7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dea:	83 c0 04             	add    $0x4,%eax
80104ded:	89 04 24             	mov    %eax,(%esp)
80104df0:	e8 c8 00 00 00       	call   80104ebd <release>
  return r;
80104df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104df8:	c9                   	leave  
80104df9:	c3                   	ret    
	...

80104dfc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104dfc:	55                   	push   %ebp
80104dfd:	89 e5                	mov    %esp,%ebp
80104dff:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e02:	9c                   	pushf  
80104e03:	58                   	pop    %eax
80104e04:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104e07:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e0a:	c9                   	leave  
80104e0b:	c3                   	ret    

80104e0c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e0c:	55                   	push   %ebp
80104e0d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e0f:	fa                   	cli    
}
80104e10:	5d                   	pop    %ebp
80104e11:	c3                   	ret    

80104e12 <sti>:

static inline void
sti(void)
{
80104e12:	55                   	push   %ebp
80104e13:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e15:	fb                   	sti    
}
80104e16:	5d                   	pop    %ebp
80104e17:	c3                   	ret    

80104e18 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e18:	55                   	push   %ebp
80104e19:	89 e5                	mov    %esp,%ebp
80104e1b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e1e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e27:	f0 87 02             	lock xchg %eax,(%edx)
80104e2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e30:	c9                   	leave  
80104e31:	c3                   	ret    

80104e32 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e32:	55                   	push   %ebp
80104e33:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e35:	8b 45 08             	mov    0x8(%ebp),%eax
80104e38:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e3b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104e51:	5d                   	pop    %ebp
80104e52:	c3                   	ret    

80104e53 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104e53:	55                   	push   %ebp
80104e54:	89 e5                	mov    %esp,%ebp
80104e56:	53                   	push   %ebx
80104e57:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104e5a:	e8 53 01 00 00       	call   80104fb2 <pushcli>
  if(holding(lk))
80104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e62:	89 04 24             	mov    %eax,(%esp)
80104e65:	e8 17 01 00 00       	call   80104f81 <holding>
80104e6a:	85 c0                	test   %eax,%eax
80104e6c:	74 0c                	je     80104e7a <acquire+0x27>
    panic("acquire");
80104e6e:	c7 04 24 76 8d 10 80 	movl   $0x80108d76,(%esp)
80104e75:	e8 da b6 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104e7a:	90                   	nop
80104e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104e85:	00 
80104e86:	89 04 24             	mov    %eax,(%esp)
80104e89:	e8 8a ff ff ff       	call   80104e18 <xchg>
80104e8e:	85 c0                	test   %eax,%eax
80104e90:	75 e9                	jne    80104e7b <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104e92:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104e97:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104e9a:	e8 14 f3 ff ff       	call   801041b3 <mycpu>
80104e9f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea5:	83 c0 0c             	add    $0xc,%eax
80104ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104eac:	8d 45 08             	lea    0x8(%ebp),%eax
80104eaf:	89 04 24             	mov    %eax,(%esp)
80104eb2:	e8 53 00 00 00       	call   80104f0a <getcallerpcs>
}
80104eb7:	83 c4 14             	add    $0x14,%esp
80104eba:	5b                   	pop    %ebx
80104ebb:	5d                   	pop    %ebp
80104ebc:	c3                   	ret    

80104ebd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ebd:	55                   	push   %ebp
80104ebe:	89 e5                	mov    %esp,%ebp
80104ec0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec6:	89 04 24             	mov    %eax,(%esp)
80104ec9:	e8 b3 00 00 00       	call   80104f81 <holding>
80104ece:	85 c0                	test   %eax,%eax
80104ed0:	75 0c                	jne    80104ede <release+0x21>
    panic("release");
80104ed2:	c7 04 24 7e 8d 10 80 	movl   $0x80108d7e,(%esp)
80104ed9:	e8 76 b6 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80104ede:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eeb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104ef2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80104efa:	8b 55 08             	mov    0x8(%ebp),%edx
80104efd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104f03:	e8 f4 00 00 00       	call   80104ffc <popcli>
}
80104f08:	c9                   	leave  
80104f09:	c3                   	ret    

80104f0a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f0a:	55                   	push   %ebp
80104f0b:	89 e5                	mov    %esp,%ebp
80104f0d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104f10:	8b 45 08             	mov    0x8(%ebp),%eax
80104f13:	83 e8 08             	sub    $0x8,%eax
80104f16:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f19:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f20:	eb 37                	jmp    80104f59 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f22:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f26:	74 37                	je     80104f5f <getcallerpcs+0x55>
80104f28:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f2f:	76 2e                	jbe    80104f5f <getcallerpcs+0x55>
80104f31:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f35:	74 28                	je     80104f5f <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f37:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f44:	01 c2                	add    %eax,%edx
80104f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f49:	8b 40 04             	mov    0x4(%eax),%eax
80104f4c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104f4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f51:	8b 00                	mov    (%eax),%eax
80104f53:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104f56:	ff 45 f8             	incl   -0x8(%ebp)
80104f59:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f5d:	7e c3                	jle    80104f22 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f5f:	eb 18                	jmp    80104f79 <getcallerpcs+0x6f>
    pcs[i] = 0;
80104f61:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f64:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f6e:	01 d0                	add    %edx,%eax
80104f70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f76:	ff 45 f8             	incl   -0x8(%ebp)
80104f79:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f7d:	7e e2                	jle    80104f61 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80104f7f:	c9                   	leave  
80104f80:	c3                   	ret    

80104f81 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104f81:	55                   	push   %ebp
80104f82:	89 e5                	mov    %esp,%ebp
80104f84:	53                   	push   %ebx
80104f85:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104f88:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8b:	8b 00                	mov    (%eax),%eax
80104f8d:	85 c0                	test   %eax,%eax
80104f8f:	74 16                	je     80104fa7 <holding+0x26>
80104f91:	8b 45 08             	mov    0x8(%ebp),%eax
80104f94:	8b 58 08             	mov    0x8(%eax),%ebx
80104f97:	e8 17 f2 ff ff       	call   801041b3 <mycpu>
80104f9c:	39 c3                	cmp    %eax,%ebx
80104f9e:	75 07                	jne    80104fa7 <holding+0x26>
80104fa0:	b8 01 00 00 00       	mov    $0x1,%eax
80104fa5:	eb 05                	jmp    80104fac <holding+0x2b>
80104fa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fac:	83 c4 04             	add    $0x4,%esp
80104faf:	5b                   	pop    %ebx
80104fb0:	5d                   	pop    %ebp
80104fb1:	c3                   	ret    

80104fb2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104fb2:	55                   	push   %ebp
80104fb3:	89 e5                	mov    %esp,%ebp
80104fb5:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104fb8:	e8 3f fe ff ff       	call   80104dfc <readeflags>
80104fbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104fc0:	e8 47 fe ff ff       	call   80104e0c <cli>
  if(mycpu()->ncli == 0)
80104fc5:	e8 e9 f1 ff ff       	call   801041b3 <mycpu>
80104fca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fd0:	85 c0                	test   %eax,%eax
80104fd2:	75 14                	jne    80104fe8 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104fd4:	e8 da f1 ff ff       	call   801041b3 <mycpu>
80104fd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fdc:	81 e2 00 02 00 00    	and    $0x200,%edx
80104fe2:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104fe8:	e8 c6 f1 ff ff       	call   801041b3 <mycpu>
80104fed:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ff3:	42                   	inc    %edx
80104ff4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104ffa:	c9                   	leave  
80104ffb:	c3                   	ret    

80104ffc <popcli>:

void
popcli(void)
{
80104ffc:	55                   	push   %ebp
80104ffd:	89 e5                	mov    %esp,%ebp
80104fff:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105002:	e8 f5 fd ff ff       	call   80104dfc <readeflags>
80105007:	25 00 02 00 00       	and    $0x200,%eax
8010500c:	85 c0                	test   %eax,%eax
8010500e:	74 0c                	je     8010501c <popcli+0x20>
    panic("popcli - interruptible");
80105010:	c7 04 24 86 8d 10 80 	movl   $0x80108d86,(%esp)
80105017:	e8 38 b5 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
8010501c:	e8 92 f1 ff ff       	call   801041b3 <mycpu>
80105021:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105027:	4a                   	dec    %edx
80105028:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010502e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105034:	85 c0                	test   %eax,%eax
80105036:	79 0c                	jns    80105044 <popcli+0x48>
    panic("popcli");
80105038:	c7 04 24 9d 8d 10 80 	movl   $0x80108d9d,(%esp)
8010503f:	e8 10 b5 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105044:	e8 6a f1 ff ff       	call   801041b3 <mycpu>
80105049:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010504f:	85 c0                	test   %eax,%eax
80105051:	75 14                	jne    80105067 <popcli+0x6b>
80105053:	e8 5b f1 ff ff       	call   801041b3 <mycpu>
80105058:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010505e:	85 c0                	test   %eax,%eax
80105060:	74 05                	je     80105067 <popcli+0x6b>
    sti();
80105062:	e8 ab fd ff ff       	call   80104e12 <sti>
}
80105067:	c9                   	leave  
80105068:	c3                   	ret    
80105069:	00 00                	add    %al,(%eax)
	...

8010506c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010506c:	55                   	push   %ebp
8010506d:	89 e5                	mov    %esp,%ebp
8010506f:	57                   	push   %edi
80105070:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105071:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105074:	8b 55 10             	mov    0x10(%ebp),%edx
80105077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010507a:	89 cb                	mov    %ecx,%ebx
8010507c:	89 df                	mov    %ebx,%edi
8010507e:	89 d1                	mov    %edx,%ecx
80105080:	fc                   	cld    
80105081:	f3 aa                	rep stos %al,%es:(%edi)
80105083:	89 ca                	mov    %ecx,%edx
80105085:	89 fb                	mov    %edi,%ebx
80105087:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010508a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010508d:	5b                   	pop    %ebx
8010508e:	5f                   	pop    %edi
8010508f:	5d                   	pop    %ebp
80105090:	c3                   	ret    

80105091 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105091:	55                   	push   %ebp
80105092:	89 e5                	mov    %esp,%ebp
80105094:	57                   	push   %edi
80105095:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105096:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105099:	8b 55 10             	mov    0x10(%ebp),%edx
8010509c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010509f:	89 cb                	mov    %ecx,%ebx
801050a1:	89 df                	mov    %ebx,%edi
801050a3:	89 d1                	mov    %edx,%ecx
801050a5:	fc                   	cld    
801050a6:	f3 ab                	rep stos %eax,%es:(%edi)
801050a8:	89 ca                	mov    %ecx,%edx
801050aa:	89 fb                	mov    %edi,%ebx
801050ac:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050af:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050b2:	5b                   	pop    %ebx
801050b3:	5f                   	pop    %edi
801050b4:	5d                   	pop    %ebp
801050b5:	c3                   	ret    

801050b6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801050b6:	55                   	push   %ebp
801050b7:	89 e5                	mov    %esp,%ebp
801050b9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801050bc:	8b 45 08             	mov    0x8(%ebp),%eax
801050bf:	83 e0 03             	and    $0x3,%eax
801050c2:	85 c0                	test   %eax,%eax
801050c4:	75 49                	jne    8010510f <memset+0x59>
801050c6:	8b 45 10             	mov    0x10(%ebp),%eax
801050c9:	83 e0 03             	and    $0x3,%eax
801050cc:	85 c0                	test   %eax,%eax
801050ce:	75 3f                	jne    8010510f <memset+0x59>
    c &= 0xFF;
801050d0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801050d7:	8b 45 10             	mov    0x10(%ebp),%eax
801050da:	c1 e8 02             	shr    $0x2,%eax
801050dd:	89 c2                	mov    %eax,%edx
801050df:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e2:	c1 e0 18             	shl    $0x18,%eax
801050e5:	89 c1                	mov    %eax,%ecx
801050e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ea:	c1 e0 10             	shl    $0x10,%eax
801050ed:	09 c1                	or     %eax,%ecx
801050ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f2:	c1 e0 08             	shl    $0x8,%eax
801050f5:	09 c8                	or     %ecx,%eax
801050f7:	0b 45 0c             	or     0xc(%ebp),%eax
801050fa:	89 54 24 08          	mov    %edx,0x8(%esp)
801050fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105102:	8b 45 08             	mov    0x8(%ebp),%eax
80105105:	89 04 24             	mov    %eax,(%esp)
80105108:	e8 84 ff ff ff       	call   80105091 <stosl>
8010510d:	eb 19                	jmp    80105128 <memset+0x72>
  } else
    stosb(dst, c, n);
8010510f:	8b 45 10             	mov    0x10(%ebp),%eax
80105112:	89 44 24 08          	mov    %eax,0x8(%esp)
80105116:	8b 45 0c             	mov    0xc(%ebp),%eax
80105119:	89 44 24 04          	mov    %eax,0x4(%esp)
8010511d:	8b 45 08             	mov    0x8(%ebp),%eax
80105120:	89 04 24             	mov    %eax,(%esp)
80105123:	e8 44 ff ff ff       	call   8010506c <stosb>
  return dst;
80105128:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010512b:	c9                   	leave  
8010512c:	c3                   	ret    

8010512d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010512d:	55                   	push   %ebp
8010512e:	89 e5                	mov    %esp,%ebp
80105130:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105133:	8b 45 08             	mov    0x8(%ebp),%eax
80105136:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010513f:	eb 2a                	jmp    8010516b <memcmp+0x3e>
    if(*s1 != *s2)
80105141:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105144:	8a 10                	mov    (%eax),%dl
80105146:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105149:	8a 00                	mov    (%eax),%al
8010514b:	38 c2                	cmp    %al,%dl
8010514d:	74 16                	je     80105165 <memcmp+0x38>
      return *s1 - *s2;
8010514f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105152:	8a 00                	mov    (%eax),%al
80105154:	0f b6 d0             	movzbl %al,%edx
80105157:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010515a:	8a 00                	mov    (%eax),%al
8010515c:	0f b6 c0             	movzbl %al,%eax
8010515f:	29 c2                	sub    %eax,%edx
80105161:	89 d0                	mov    %edx,%eax
80105163:	eb 18                	jmp    8010517d <memcmp+0x50>
    s1++, s2++;
80105165:	ff 45 fc             	incl   -0x4(%ebp)
80105168:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010516b:	8b 45 10             	mov    0x10(%ebp),%eax
8010516e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105171:	89 55 10             	mov    %edx,0x10(%ebp)
80105174:	85 c0                	test   %eax,%eax
80105176:	75 c9                	jne    80105141 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105178:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010517d:	c9                   	leave  
8010517e:	c3                   	ret    

8010517f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010517f:	55                   	push   %ebp
80105180:	89 e5                	mov    %esp,%ebp
80105182:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105185:	8b 45 0c             	mov    0xc(%ebp),%eax
80105188:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010518b:	8b 45 08             	mov    0x8(%ebp),%eax
8010518e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105191:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105194:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105197:	73 3a                	jae    801051d3 <memmove+0x54>
80105199:	8b 45 10             	mov    0x10(%ebp),%eax
8010519c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010519f:	01 d0                	add    %edx,%eax
801051a1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051a4:	76 2d                	jbe    801051d3 <memmove+0x54>
    s += n;
801051a6:	8b 45 10             	mov    0x10(%ebp),%eax
801051a9:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801051ac:	8b 45 10             	mov    0x10(%ebp),%eax
801051af:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801051b2:	eb 10                	jmp    801051c4 <memmove+0x45>
      *--d = *--s;
801051b4:	ff 4d f8             	decl   -0x8(%ebp)
801051b7:	ff 4d fc             	decl   -0x4(%ebp)
801051ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051bd:	8a 10                	mov    (%eax),%dl
801051bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051c2:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801051c4:	8b 45 10             	mov    0x10(%ebp),%eax
801051c7:	8d 50 ff             	lea    -0x1(%eax),%edx
801051ca:	89 55 10             	mov    %edx,0x10(%ebp)
801051cd:	85 c0                	test   %eax,%eax
801051cf:	75 e3                	jne    801051b4 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801051d1:	eb 25                	jmp    801051f8 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801051d3:	eb 16                	jmp    801051eb <memmove+0x6c>
      *d++ = *s++;
801051d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051d8:	8d 50 01             	lea    0x1(%eax),%edx
801051db:	89 55 f8             	mov    %edx,-0x8(%ebp)
801051de:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051e1:	8d 4a 01             	lea    0x1(%edx),%ecx
801051e4:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801051e7:	8a 12                	mov    (%edx),%dl
801051e9:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801051eb:	8b 45 10             	mov    0x10(%ebp),%eax
801051ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801051f1:	89 55 10             	mov    %edx,0x10(%ebp)
801051f4:	85 c0                	test   %eax,%eax
801051f6:	75 dd                	jne    801051d5 <memmove+0x56>
      *d++ = *s++;

  return dst;
801051f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051fb:	c9                   	leave  
801051fc:	c3                   	ret    

801051fd <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801051fd:	55                   	push   %ebp
801051fe:	89 e5                	mov    %esp,%ebp
80105200:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105203:	8b 45 10             	mov    0x10(%ebp),%eax
80105206:	89 44 24 08          	mov    %eax,0x8(%esp)
8010520a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105211:	8b 45 08             	mov    0x8(%ebp),%eax
80105214:	89 04 24             	mov    %eax,(%esp)
80105217:	e8 63 ff ff ff       	call   8010517f <memmove>
}
8010521c:	c9                   	leave  
8010521d:	c3                   	ret    

8010521e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010521e:	55                   	push   %ebp
8010521f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105221:	eb 09                	jmp    8010522c <strncmp+0xe>
    n--, p++, q++;
80105223:	ff 4d 10             	decl   0x10(%ebp)
80105226:	ff 45 08             	incl   0x8(%ebp)
80105229:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010522c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105230:	74 17                	je     80105249 <strncmp+0x2b>
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	8a 00                	mov    (%eax),%al
80105237:	84 c0                	test   %al,%al
80105239:	74 0e                	je     80105249 <strncmp+0x2b>
8010523b:	8b 45 08             	mov    0x8(%ebp),%eax
8010523e:	8a 10                	mov    (%eax),%dl
80105240:	8b 45 0c             	mov    0xc(%ebp),%eax
80105243:	8a 00                	mov    (%eax),%al
80105245:	38 c2                	cmp    %al,%dl
80105247:	74 da                	je     80105223 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105249:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010524d:	75 07                	jne    80105256 <strncmp+0x38>
    return 0;
8010524f:	b8 00 00 00 00       	mov    $0x0,%eax
80105254:	eb 14                	jmp    8010526a <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105256:	8b 45 08             	mov    0x8(%ebp),%eax
80105259:	8a 00                	mov    (%eax),%al
8010525b:	0f b6 d0             	movzbl %al,%edx
8010525e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105261:	8a 00                	mov    (%eax),%al
80105263:	0f b6 c0             	movzbl %al,%eax
80105266:	29 c2                	sub    %eax,%edx
80105268:	89 d0                	mov    %edx,%eax
}
8010526a:	5d                   	pop    %ebp
8010526b:	c3                   	ret    

8010526c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010526c:	55                   	push   %ebp
8010526d:	89 e5                	mov    %esp,%ebp
8010526f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105272:	8b 45 08             	mov    0x8(%ebp),%eax
80105275:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105278:	90                   	nop
80105279:	8b 45 10             	mov    0x10(%ebp),%eax
8010527c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010527f:	89 55 10             	mov    %edx,0x10(%ebp)
80105282:	85 c0                	test   %eax,%eax
80105284:	7e 1c                	jle    801052a2 <strncpy+0x36>
80105286:	8b 45 08             	mov    0x8(%ebp),%eax
80105289:	8d 50 01             	lea    0x1(%eax),%edx
8010528c:	89 55 08             	mov    %edx,0x8(%ebp)
8010528f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105292:	8d 4a 01             	lea    0x1(%edx),%ecx
80105295:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105298:	8a 12                	mov    (%edx),%dl
8010529a:	88 10                	mov    %dl,(%eax)
8010529c:	8a 00                	mov    (%eax),%al
8010529e:	84 c0                	test   %al,%al
801052a0:	75 d7                	jne    80105279 <strncpy+0xd>
    ;
  while(n-- > 0)
801052a2:	eb 0c                	jmp    801052b0 <strncpy+0x44>
    *s++ = 0;
801052a4:	8b 45 08             	mov    0x8(%ebp),%eax
801052a7:	8d 50 01             	lea    0x1(%eax),%edx
801052aa:	89 55 08             	mov    %edx,0x8(%ebp)
801052ad:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801052b0:	8b 45 10             	mov    0x10(%ebp),%eax
801052b3:	8d 50 ff             	lea    -0x1(%eax),%edx
801052b6:	89 55 10             	mov    %edx,0x10(%ebp)
801052b9:	85 c0                	test   %eax,%eax
801052bb:	7f e7                	jg     801052a4 <strncpy+0x38>
    *s++ = 0;
  return os;
801052bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052c0:	c9                   	leave  
801052c1:	c3                   	ret    

801052c2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801052c2:	55                   	push   %ebp
801052c3:	89 e5                	mov    %esp,%ebp
801052c5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801052c8:	8b 45 08             	mov    0x8(%ebp),%eax
801052cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801052ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052d2:	7f 05                	jg     801052d9 <safestrcpy+0x17>
    return os;
801052d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d7:	eb 2e                	jmp    80105307 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801052d9:	ff 4d 10             	decl   0x10(%ebp)
801052dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052e0:	7e 1c                	jle    801052fe <safestrcpy+0x3c>
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	8d 50 01             	lea    0x1(%eax),%edx
801052e8:	89 55 08             	mov    %edx,0x8(%ebp)
801052eb:	8b 55 0c             	mov    0xc(%ebp),%edx
801052ee:	8d 4a 01             	lea    0x1(%edx),%ecx
801052f1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801052f4:	8a 12                	mov    (%edx),%dl
801052f6:	88 10                	mov    %dl,(%eax)
801052f8:	8a 00                	mov    (%eax),%al
801052fa:	84 c0                	test   %al,%al
801052fc:	75 db                	jne    801052d9 <safestrcpy+0x17>
    ;
  *s = 0;
801052fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105301:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105304:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105307:	c9                   	leave  
80105308:	c3                   	ret    

80105309 <strlen>:

int
strlen(const char *s)
{
80105309:	55                   	push   %ebp
8010530a:	89 e5                	mov    %esp,%ebp
8010530c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010530f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105316:	eb 03                	jmp    8010531b <strlen+0x12>
80105318:	ff 45 fc             	incl   -0x4(%ebp)
8010531b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010531e:	8b 45 08             	mov    0x8(%ebp),%eax
80105321:	01 d0                	add    %edx,%eax
80105323:	8a 00                	mov    (%eax),%al
80105325:	84 c0                	test   %al,%al
80105327:	75 ef                	jne    80105318 <strlen+0xf>
    ;
  return n;
80105329:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010532c:	c9                   	leave  
8010532d:	c3                   	ret    
	...

80105330 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105330:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105334:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105338:	55                   	push   %ebp
  pushl %ebx
80105339:	53                   	push   %ebx
  pushl %esi
8010533a:	56                   	push   %esi
  pushl %edi
8010533b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010533c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010533e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105340:	5f                   	pop    %edi
  popl %esi
80105341:	5e                   	pop    %esi
  popl %ebx
80105342:	5b                   	pop    %ebx
  popl %ebp
80105343:	5d                   	pop    %ebp
  ret
80105344:	c3                   	ret    
80105345:	00 00                	add    %al,(%eax)
	...

80105348 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105348:	55                   	push   %ebp
80105349:	89 e5                	mov    %esp,%ebp
8010534b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010534e:	e8 e4 ee ff ff       	call   80104237 <myproc>
80105353:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105359:	8b 00                	mov    (%eax),%eax
8010535b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010535e:	76 0f                	jbe    8010536f <fetchint+0x27>
80105360:	8b 45 08             	mov    0x8(%ebp),%eax
80105363:	8d 50 04             	lea    0x4(%eax),%edx
80105366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105369:	8b 00                	mov    (%eax),%eax
8010536b:	39 c2                	cmp    %eax,%edx
8010536d:	76 07                	jbe    80105376 <fetchint+0x2e>
    return -1;
8010536f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105374:	eb 0f                	jmp    80105385 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105376:	8b 45 08             	mov    0x8(%ebp),%eax
80105379:	8b 10                	mov    (%eax),%edx
8010537b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010537e:	89 10                	mov    %edx,(%eax)
  return 0;
80105380:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105385:	c9                   	leave  
80105386:	c3                   	ret    

80105387 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105387:	55                   	push   %ebp
80105388:	89 e5                	mov    %esp,%ebp
8010538a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010538d:	e8 a5 ee ff ff       	call   80104237 <myproc>
80105392:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105398:	8b 00                	mov    (%eax),%eax
8010539a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010539d:	77 07                	ja     801053a6 <fetchstr+0x1f>
    return -1;
8010539f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a4:	eb 41                	jmp    801053e7 <fetchstr+0x60>
  *pp = (char*)addr;
801053a6:	8b 55 08             	mov    0x8(%ebp),%edx
801053a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ac:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801053ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b1:	8b 00                	mov    (%eax),%eax
801053b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801053b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b9:	8b 00                	mov    (%eax),%eax
801053bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053be:	eb 1a                	jmp    801053da <fetchstr+0x53>
    if(*s == 0)
801053c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c3:	8a 00                	mov    (%eax),%al
801053c5:	84 c0                	test   %al,%al
801053c7:	75 0e                	jne    801053d7 <fetchstr+0x50>
      return s - *pp;
801053c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cf:	8b 00                	mov    (%eax),%eax
801053d1:	29 c2                	sub    %eax,%edx
801053d3:	89 d0                	mov    %edx,%eax
801053d5:	eb 10                	jmp    801053e7 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801053d7:	ff 45 f4             	incl   -0xc(%ebp)
801053da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801053e0:	72 de                	jb     801053c0 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801053e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053e7:	c9                   	leave  
801053e8:	c3                   	ret    

801053e9 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801053e9:	55                   	push   %ebp
801053ea:	89 e5                	mov    %esp,%ebp
801053ec:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801053ef:	e8 43 ee ff ff       	call   80104237 <myproc>
801053f4:	8b 40 18             	mov    0x18(%eax),%eax
801053f7:	8b 50 44             	mov    0x44(%eax),%edx
801053fa:	8b 45 08             	mov    0x8(%ebp),%eax
801053fd:	c1 e0 02             	shl    $0x2,%eax
80105400:	01 d0                	add    %edx,%eax
80105402:	8d 50 04             	lea    0x4(%eax),%edx
80105405:	8b 45 0c             	mov    0xc(%ebp),%eax
80105408:	89 44 24 04          	mov    %eax,0x4(%esp)
8010540c:	89 14 24             	mov    %edx,(%esp)
8010540f:	e8 34 ff ff ff       	call   80105348 <fetchint>
}
80105414:	c9                   	leave  
80105415:	c3                   	ret    

80105416 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105416:	55                   	push   %ebp
80105417:	89 e5                	mov    %esp,%ebp
80105419:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
8010541c:	e8 16 ee ff ff       	call   80104237 <myproc>
80105421:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105424:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105427:	89 44 24 04          	mov    %eax,0x4(%esp)
8010542b:	8b 45 08             	mov    0x8(%ebp),%eax
8010542e:	89 04 24             	mov    %eax,(%esp)
80105431:	e8 b3 ff ff ff       	call   801053e9 <argint>
80105436:	85 c0                	test   %eax,%eax
80105438:	79 07                	jns    80105441 <argptr+0x2b>
    return -1;
8010543a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543f:	eb 3d                	jmp    8010547e <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105441:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105445:	78 21                	js     80105468 <argptr+0x52>
80105447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010544a:	89 c2                	mov    %eax,%edx
8010544c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544f:	8b 00                	mov    (%eax),%eax
80105451:	39 c2                	cmp    %eax,%edx
80105453:	73 13                	jae    80105468 <argptr+0x52>
80105455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105458:	89 c2                	mov    %eax,%edx
8010545a:	8b 45 10             	mov    0x10(%ebp),%eax
8010545d:	01 c2                	add    %eax,%edx
8010545f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105462:	8b 00                	mov    (%eax),%eax
80105464:	39 c2                	cmp    %eax,%edx
80105466:	76 07                	jbe    8010546f <argptr+0x59>
    return -1;
80105468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546d:	eb 0f                	jmp    8010547e <argptr+0x68>
  *pp = (char*)i;
8010546f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105472:	89 c2                	mov    %eax,%edx
80105474:	8b 45 0c             	mov    0xc(%ebp),%eax
80105477:	89 10                	mov    %edx,(%eax)
  return 0;
80105479:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010547e:	c9                   	leave  
8010547f:	c3                   	ret    

80105480 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105480:	55                   	push   %ebp
80105481:	89 e5                	mov    %esp,%ebp
80105483:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105486:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105489:	89 44 24 04          	mov    %eax,0x4(%esp)
8010548d:	8b 45 08             	mov    0x8(%ebp),%eax
80105490:	89 04 24             	mov    %eax,(%esp)
80105493:	e8 51 ff ff ff       	call   801053e9 <argint>
80105498:	85 c0                	test   %eax,%eax
8010549a:	79 07                	jns    801054a3 <argstr+0x23>
    return -1;
8010549c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a1:	eb 12                	jmp    801054b5 <argstr+0x35>
  return fetchstr(addr, pp);
801054a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a6:	8b 55 0c             	mov    0xc(%ebp),%edx
801054a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801054ad:	89 04 24             	mov    %eax,(%esp)
801054b0:	e8 d2 fe ff ff       	call   80105387 <fetchstr>
}
801054b5:	c9                   	leave  
801054b6:	c3                   	ret    

801054b7 <syscall>:
[SYS_set_curr_proc] sys_set_curr_proc,
};

void
syscall(void)
{
801054b7:	55                   	push   %ebp
801054b8:	89 e5                	mov    %esp,%ebp
801054ba:	53                   	push   %ebx
801054bb:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801054be:	e8 74 ed ff ff       	call   80104237 <myproc>
801054c3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801054c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c9:	8b 40 18             	mov    0x18(%eax),%eax
801054cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801054cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801054d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054d6:	7e 2d                	jle    80105505 <syscall+0x4e>
801054d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054db:	83 f8 24             	cmp    $0x24,%eax
801054de:	77 25                	ja     80105505 <syscall+0x4e>
801054e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e3:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801054ea:	85 c0                	test   %eax,%eax
801054ec:	74 17                	je     80105505 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801054ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f1:	8b 58 18             	mov    0x18(%eax),%ebx
801054f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f7:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801054fe:	ff d0                	call   *%eax
80105500:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105503:	eb 34                	jmp    80105539 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105508:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010550b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550e:	8b 40 10             	mov    0x10(%eax),%eax
80105511:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105514:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010551c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105520:	c7 04 24 a4 8d 10 80 	movl   $0x80108da4,(%esp)
80105527:	e8 95 ae ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
8010552c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552f:	8b 40 18             	mov    0x18(%eax),%eax
80105532:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105539:	83 c4 24             	add    $0x24,%esp
8010553c:	5b                   	pop    %ebx
8010553d:	5d                   	pop    %ebp
8010553e:	c3                   	ret    
	...

80105540 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105546:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105549:	89 44 24 04          	mov    %eax,0x4(%esp)
8010554d:	8b 45 08             	mov    0x8(%ebp),%eax
80105550:	89 04 24             	mov    %eax,(%esp)
80105553:	e8 91 fe ff ff       	call   801053e9 <argint>
80105558:	85 c0                	test   %eax,%eax
8010555a:	79 07                	jns    80105563 <argfd+0x23>
    return -1;
8010555c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105561:	eb 4f                	jmp    801055b2 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105566:	85 c0                	test   %eax,%eax
80105568:	78 20                	js     8010558a <argfd+0x4a>
8010556a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556d:	83 f8 0f             	cmp    $0xf,%eax
80105570:	7f 18                	jg     8010558a <argfd+0x4a>
80105572:	e8 c0 ec ff ff       	call   80104237 <myproc>
80105577:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010557a:	83 c2 08             	add    $0x8,%edx
8010557d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105581:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105584:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105588:	75 07                	jne    80105591 <argfd+0x51>
    return -1;
8010558a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010558f:	eb 21                	jmp    801055b2 <argfd+0x72>
  if(pfd)
80105591:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105595:	74 08                	je     8010559f <argfd+0x5f>
    *pfd = fd;
80105597:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010559a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559d:	89 10                	mov    %edx,(%eax)
  if(pf)
8010559f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055a3:	74 08                	je     801055ad <argfd+0x6d>
    *pf = f;
801055a5:	8b 45 10             	mov    0x10(%ebp),%eax
801055a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055ab:	89 10                	mov    %edx,(%eax)
  return 0;
801055ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055b2:	c9                   	leave  
801055b3:	c3                   	ret    

801055b4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801055b4:	55                   	push   %ebp
801055b5:	89 e5                	mov    %esp,%ebp
801055b7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801055ba:	e8 78 ec ff ff       	call   80104237 <myproc>
801055bf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801055c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801055c9:	eb 29                	jmp    801055f4 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
801055cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055d1:	83 c2 08             	add    $0x8,%edx
801055d4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055d8:	85 c0                	test   %eax,%eax
801055da:	75 15                	jne    801055f1 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801055dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055e2:	8d 4a 08             	lea    0x8(%edx),%ecx
801055e5:	8b 55 08             	mov    0x8(%ebp),%edx
801055e8:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801055ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ef:	eb 0e                	jmp    801055ff <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801055f1:	ff 45 f4             	incl   -0xc(%ebp)
801055f4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801055f8:	7e d1                	jle    801055cb <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801055fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055ff:	c9                   	leave  
80105600:	c3                   	ret    

80105601 <sys_dup>:

int
sys_dup(void)
{
80105601:	55                   	push   %ebp
80105602:	89 e5                	mov    %esp,%ebp
80105604:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105607:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010560a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010560e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105615:	00 
80105616:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010561d:	e8 1e ff ff ff       	call   80105540 <argfd>
80105622:	85 c0                	test   %eax,%eax
80105624:	79 07                	jns    8010562d <sys_dup+0x2c>
    return -1;
80105626:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010562b:	eb 29                	jmp    80105656 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010562d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105630:	89 04 24             	mov    %eax,(%esp)
80105633:	e8 7c ff ff ff       	call   801055b4 <fdalloc>
80105638:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010563b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010563f:	79 07                	jns    80105648 <sys_dup+0x47>
    return -1;
80105641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105646:	eb 0e                	jmp    80105656 <sys_dup+0x55>
  filedup(f);
80105648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564b:	89 04 24             	mov    %eax,(%esp)
8010564e:	e8 91 ba ff ff       	call   801010e4 <filedup>
  return fd;
80105653:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105656:	c9                   	leave  
80105657:	c3                   	ret    

80105658 <sys_read>:

int
sys_read(void)
{
80105658:	55                   	push   %ebp
80105659:	89 e5                	mov    %esp,%ebp
8010565b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010565e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105661:	89 44 24 08          	mov    %eax,0x8(%esp)
80105665:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010566c:	00 
8010566d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105674:	e8 c7 fe ff ff       	call   80105540 <argfd>
80105679:	85 c0                	test   %eax,%eax
8010567b:	78 35                	js     801056b2 <sys_read+0x5a>
8010567d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105680:	89 44 24 04          	mov    %eax,0x4(%esp)
80105684:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010568b:	e8 59 fd ff ff       	call   801053e9 <argint>
80105690:	85 c0                	test   %eax,%eax
80105692:	78 1e                	js     801056b2 <sys_read+0x5a>
80105694:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105697:	89 44 24 08          	mov    %eax,0x8(%esp)
8010569b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010569e:	89 44 24 04          	mov    %eax,0x4(%esp)
801056a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056a9:	e8 68 fd ff ff       	call   80105416 <argptr>
801056ae:	85 c0                	test   %eax,%eax
801056b0:	79 07                	jns    801056b9 <sys_read+0x61>
    return -1;
801056b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b7:	eb 19                	jmp    801056d2 <sys_read+0x7a>
  return fileread(f, p, n);
801056b9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801056ca:	89 04 24             	mov    %eax,(%esp)
801056cd:	e8 73 bb ff ff       	call   80101245 <fileread>
}
801056d2:	c9                   	leave  
801056d3:	c3                   	ret    

801056d4 <sys_write>:

int
sys_write(void)
{
801056d4:	55                   	push   %ebp
801056d5:	89 e5                	mov    %esp,%ebp
801056d7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056da:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801056e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056e8:	00 
801056e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056f0:	e8 4b fe ff ff       	call   80105540 <argfd>
801056f5:	85 c0                	test   %eax,%eax
801056f7:	78 35                	js     8010572e <sys_write+0x5a>
801056f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105700:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105707:	e8 dd fc ff ff       	call   801053e9 <argint>
8010570c:	85 c0                	test   %eax,%eax
8010570e:	78 1e                	js     8010572e <sys_write+0x5a>
80105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105713:	89 44 24 08          	mov    %eax,0x8(%esp)
80105717:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010571a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010571e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105725:	e8 ec fc ff ff       	call   80105416 <argptr>
8010572a:	85 c0                	test   %eax,%eax
8010572c:	79 07                	jns    80105735 <sys_write+0x61>
    return -1;
8010572e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105733:	eb 19                	jmp    8010574e <sys_write+0x7a>
  return filewrite(f, p, n);
80105735:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105738:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010573b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105742:	89 54 24 04          	mov    %edx,0x4(%esp)
80105746:	89 04 24             	mov    %eax,(%esp)
80105749:	e8 b2 bb ff ff       	call   80101300 <filewrite>
}
8010574e:	c9                   	leave  
8010574f:	c3                   	ret    

80105750 <sys_close>:

int
sys_close(void)
{
80105750:	55                   	push   %ebp
80105751:	89 e5                	mov    %esp,%ebp
80105753:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105756:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105759:	89 44 24 08          	mov    %eax,0x8(%esp)
8010575d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105760:	89 44 24 04          	mov    %eax,0x4(%esp)
80105764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010576b:	e8 d0 fd ff ff       	call   80105540 <argfd>
80105770:	85 c0                	test   %eax,%eax
80105772:	79 07                	jns    8010577b <sys_close+0x2b>
    return -1;
80105774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105779:	eb 23                	jmp    8010579e <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
8010577b:	e8 b7 ea ff ff       	call   80104237 <myproc>
80105780:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105783:	83 c2 08             	add    $0x8,%edx
80105786:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010578d:	00 
  fileclose(f);
8010578e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105791:	89 04 24             	mov    %eax,(%esp)
80105794:	e8 93 b9 ff ff       	call   8010112c <fileclose>
  return 0;
80105799:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010579e:	c9                   	leave  
8010579f:	c3                   	ret    

801057a0 <sys_fstat>:

int
sys_fstat(void)
{
801057a0:	55                   	push   %ebp
801057a1:	89 e5                	mov    %esp,%ebp
801057a3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801057a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057a9:	89 44 24 08          	mov    %eax,0x8(%esp)
801057ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057b4:	00 
801057b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057bc:	e8 7f fd ff ff       	call   80105540 <argfd>
801057c1:	85 c0                	test   %eax,%eax
801057c3:	78 1f                	js     801057e4 <sys_fstat+0x44>
801057c5:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801057cc:	00 
801057cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057db:	e8 36 fc ff ff       	call   80105416 <argptr>
801057e0:	85 c0                	test   %eax,%eax
801057e2:	79 07                	jns    801057eb <sys_fstat+0x4b>
    return -1;
801057e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e9:	eb 12                	jmp    801057fd <sys_fstat+0x5d>
  return filestat(f, st);
801057eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801057f5:	89 04 24             	mov    %eax,(%esp)
801057f8:	e8 f9 b9 ff ff       	call   801011f6 <filestat>
}
801057fd:	c9                   	leave  
801057fe:	c3                   	ret    

801057ff <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801057ff:	55                   	push   %ebp
80105800:	89 e5                	mov    %esp,%ebp
80105802:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105805:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105808:	89 44 24 04          	mov    %eax,0x4(%esp)
8010580c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105813:	e8 68 fc ff ff       	call   80105480 <argstr>
80105818:	85 c0                	test   %eax,%eax
8010581a:	78 17                	js     80105833 <sys_link+0x34>
8010581c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010581f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105823:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010582a:	e8 51 fc ff ff       	call   80105480 <argstr>
8010582f:	85 c0                	test   %eax,%eax
80105831:	79 0a                	jns    8010583d <sys_link+0x3e>
    return -1;
80105833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105838:	e9 3d 01 00 00       	jmp    8010597a <sys_link+0x17b>

  begin_op();
8010583d:	e8 fd dc ff ff       	call   8010353f <begin_op>
  if((ip = namei(old)) == 0){
80105842:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105845:	89 04 24             	mov    %eax,(%esp)
80105848:	e8 1e cd ff ff       	call   8010256b <namei>
8010584d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105850:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105854:	75 0f                	jne    80105865 <sys_link+0x66>
    end_op();
80105856:	e8 66 dd ff ff       	call   801035c1 <end_op>
    return -1;
8010585b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105860:	e9 15 01 00 00       	jmp    8010597a <sys_link+0x17b>
  }

  ilock(ip);
80105865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105868:	89 04 24             	mov    %eax,(%esp)
8010586b:	e8 d6 c1 ff ff       	call   80101a46 <ilock>
  if(ip->type == T_DIR){
80105870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105873:	8b 40 50             	mov    0x50(%eax),%eax
80105876:	66 83 f8 01          	cmp    $0x1,%ax
8010587a:	75 1a                	jne    80105896 <sys_link+0x97>
    iunlockput(ip);
8010587c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587f:	89 04 24             	mov    %eax,(%esp)
80105882:	e8 be c3 ff ff       	call   80101c45 <iunlockput>
    end_op();
80105887:	e8 35 dd ff ff       	call   801035c1 <end_op>
    return -1;
8010588c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105891:	e9 e4 00 00 00       	jmp    8010597a <sys_link+0x17b>
  }

  ip->nlink++;
80105896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105899:	66 8b 40 56          	mov    0x56(%eax),%ax
8010589d:	40                   	inc    %eax
8010589e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058a1:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801058a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a8:	89 04 24             	mov    %eax,(%esp)
801058ab:	e8 d3 bf ff ff       	call   80101883 <iupdate>
  iunlock(ip);
801058b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b3:	89 04 24             	mov    %eax,(%esp)
801058b6:	e8 95 c2 ff ff       	call   80101b50 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801058bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801058be:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801058c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801058c5:	89 04 24             	mov    %eax,(%esp)
801058c8:	e8 c0 cc ff ff       	call   8010258d <nameiparent>
801058cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058d4:	75 02                	jne    801058d8 <sys_link+0xd9>
    goto bad;
801058d6:	eb 68                	jmp    80105940 <sys_link+0x141>
  ilock(dp);
801058d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058db:	89 04 24             	mov    %eax,(%esp)
801058de:	e8 63 c1 ff ff       	call   80101a46 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801058e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e6:	8b 10                	mov    (%eax),%edx
801058e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058eb:	8b 00                	mov    (%eax),%eax
801058ed:	39 c2                	cmp    %eax,%edx
801058ef:	75 20                	jne    80105911 <sys_link+0x112>
801058f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f4:	8b 40 04             	mov    0x4(%eax),%eax
801058f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801058fb:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801058fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105902:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105905:	89 04 24             	mov    %eax,(%esp)
80105908:	e8 ab c9 ff ff       	call   801022b8 <dirlink>
8010590d:	85 c0                	test   %eax,%eax
8010590f:	79 0d                	jns    8010591e <sys_link+0x11f>
    iunlockput(dp);
80105911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105914:	89 04 24             	mov    %eax,(%esp)
80105917:	e8 29 c3 ff ff       	call   80101c45 <iunlockput>
    goto bad;
8010591c:	eb 22                	jmp    80105940 <sys_link+0x141>
  }
  iunlockput(dp);
8010591e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105921:	89 04 24             	mov    %eax,(%esp)
80105924:	e8 1c c3 ff ff       	call   80101c45 <iunlockput>
  iput(ip);
80105929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592c:	89 04 24             	mov    %eax,(%esp)
8010592f:	e8 60 c2 ff ff       	call   80101b94 <iput>

  end_op();
80105934:	e8 88 dc ff ff       	call   801035c1 <end_op>

  return 0;
80105939:	b8 00 00 00 00       	mov    $0x0,%eax
8010593e:	eb 3a                	jmp    8010597a <sys_link+0x17b>

bad:
  ilock(ip);
80105940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105943:	89 04 24             	mov    %eax,(%esp)
80105946:	e8 fb c0 ff ff       	call   80101a46 <ilock>
  ip->nlink--;
8010594b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594e:	66 8b 40 56          	mov    0x56(%eax),%ax
80105952:	48                   	dec    %eax
80105953:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105956:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010595a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595d:	89 04 24             	mov    %eax,(%esp)
80105960:	e8 1e bf ff ff       	call   80101883 <iupdate>
  iunlockput(ip);
80105965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105968:	89 04 24             	mov    %eax,(%esp)
8010596b:	e8 d5 c2 ff ff       	call   80101c45 <iunlockput>
  end_op();
80105970:	e8 4c dc ff ff       	call   801035c1 <end_op>
  return -1;
80105975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010597a:	c9                   	leave  
8010597b:	c3                   	ret    

8010597c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010597c:	55                   	push   %ebp
8010597d:	89 e5                	mov    %esp,%ebp
8010597f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105982:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105989:	eb 4a                	jmp    801059d5 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010598b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105995:	00 
80105996:	89 44 24 08          	mov    %eax,0x8(%esp)
8010599a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010599d:	89 44 24 04          	mov    %eax,0x4(%esp)
801059a1:	8b 45 08             	mov    0x8(%ebp),%eax
801059a4:	89 04 24             	mov    %eax,(%esp)
801059a7:	e8 31 c5 ff ff       	call   80101edd <readi>
801059ac:	83 f8 10             	cmp    $0x10,%eax
801059af:	74 0c                	je     801059bd <isdirempty+0x41>
      panic("isdirempty: readi");
801059b1:	c7 04 24 c0 8d 10 80 	movl   $0x80108dc0,(%esp)
801059b8:	e8 97 ab ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801059bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059c0:	66 85 c0             	test   %ax,%ax
801059c3:	74 07                	je     801059cc <isdirempty+0x50>
      return 0;
801059c5:	b8 00 00 00 00       	mov    $0x0,%eax
801059ca:	eb 1b                	jmp    801059e7 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801059cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cf:	83 c0 10             	add    $0x10,%eax
801059d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d8:	8b 45 08             	mov    0x8(%ebp),%eax
801059db:	8b 40 58             	mov    0x58(%eax),%eax
801059de:	39 c2                	cmp    %eax,%edx
801059e0:	72 a9                	jb     8010598b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801059e2:	b8 01 00 00 00       	mov    $0x1,%eax
}
801059e7:	c9                   	leave  
801059e8:	c3                   	ret    

801059e9 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801059e9:	55                   	push   %ebp
801059ea:	89 e5                	mov    %esp,%ebp
801059ec:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801059ef:	8d 45 cc             	lea    -0x34(%ebp),%eax
801059f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059fd:	e8 7e fa ff ff       	call   80105480 <argstr>
80105a02:	85 c0                	test   %eax,%eax
80105a04:	79 0a                	jns    80105a10 <sys_unlink+0x27>
    return -1;
80105a06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0b:	e9 a9 01 00 00       	jmp    80105bb9 <sys_unlink+0x1d0>

  begin_op();
80105a10:	e8 2a db ff ff       	call   8010353f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105a15:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105a18:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a1f:	89 04 24             	mov    %eax,(%esp)
80105a22:	e8 66 cb ff ff       	call   8010258d <nameiparent>
80105a27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a2e:	75 0f                	jne    80105a3f <sys_unlink+0x56>
    end_op();
80105a30:	e8 8c db ff ff       	call   801035c1 <end_op>
    return -1;
80105a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3a:	e9 7a 01 00 00       	jmp    80105bb9 <sys_unlink+0x1d0>
  }

  ilock(dp);
80105a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a42:	89 04 24             	mov    %eax,(%esp)
80105a45:	e8 fc bf ff ff       	call   80101a46 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105a4a:	c7 44 24 04 d2 8d 10 	movl   $0x80108dd2,0x4(%esp)
80105a51:	80 
80105a52:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a55:	89 04 24             	mov    %eax,(%esp)
80105a58:	e8 73 c7 ff ff       	call   801021d0 <namecmp>
80105a5d:	85 c0                	test   %eax,%eax
80105a5f:	0f 84 3f 01 00 00    	je     80105ba4 <sys_unlink+0x1bb>
80105a65:	c7 44 24 04 d4 8d 10 	movl   $0x80108dd4,0x4(%esp)
80105a6c:	80 
80105a6d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a70:	89 04 24             	mov    %eax,(%esp)
80105a73:	e8 58 c7 ff ff       	call   801021d0 <namecmp>
80105a78:	85 c0                	test   %eax,%eax
80105a7a:	0f 84 24 01 00 00    	je     80105ba4 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105a80:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105a83:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a87:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a91:	89 04 24             	mov    %eax,(%esp)
80105a94:	e8 59 c7 ff ff       	call   801021f2 <dirlookup>
80105a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aa0:	75 05                	jne    80105aa7 <sys_unlink+0xbe>
    goto bad;
80105aa2:	e9 fd 00 00 00       	jmp    80105ba4 <sys_unlink+0x1bb>
  ilock(ip);
80105aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aaa:	89 04 24             	mov    %eax,(%esp)
80105aad:	e8 94 bf ff ff       	call   80101a46 <ilock>

  if(ip->nlink < 1)
80105ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab5:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ab9:	66 85 c0             	test   %ax,%ax
80105abc:	7f 0c                	jg     80105aca <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105abe:	c7 04 24 d7 8d 10 80 	movl   $0x80108dd7,(%esp)
80105ac5:	e8 8a aa ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acd:	8b 40 50             	mov    0x50(%eax),%eax
80105ad0:	66 83 f8 01          	cmp    $0x1,%ax
80105ad4:	75 1f                	jne    80105af5 <sys_unlink+0x10c>
80105ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad9:	89 04 24             	mov    %eax,(%esp)
80105adc:	e8 9b fe ff ff       	call   8010597c <isdirempty>
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	75 10                	jne    80105af5 <sys_unlink+0x10c>
    iunlockput(ip);
80105ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae8:	89 04 24             	mov    %eax,(%esp)
80105aeb:	e8 55 c1 ff ff       	call   80101c45 <iunlockput>
    goto bad;
80105af0:	e9 af 00 00 00       	jmp    80105ba4 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105af5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105afc:	00 
80105afd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b04:	00 
80105b05:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b08:	89 04 24             	mov    %eax,(%esp)
80105b0b:	e8 a6 f5 ff ff       	call   801050b6 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b10:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105b13:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b1a:	00 
80105b1b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b1f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b22:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 10 c5 ff ff       	call   80102041 <writei>
80105b31:	83 f8 10             	cmp    $0x10,%eax
80105b34:	74 0c                	je     80105b42 <sys_unlink+0x159>
    panic("unlink: writei");
80105b36:	c7 04 24 e9 8d 10 80 	movl   $0x80108de9,(%esp)
80105b3d:	e8 12 aa ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b45:	8b 40 50             	mov    0x50(%eax),%eax
80105b48:	66 83 f8 01          	cmp    $0x1,%ax
80105b4c:	75 1a                	jne    80105b68 <sys_unlink+0x17f>
    dp->nlink--;
80105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b51:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b55:	48                   	dec    %eax
80105b56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b59:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b60:	89 04 24             	mov    %eax,(%esp)
80105b63:	e8 1b bd ff ff       	call   80101883 <iupdate>
  }
  iunlockput(dp);
80105b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6b:	89 04 24             	mov    %eax,(%esp)
80105b6e:	e8 d2 c0 ff ff       	call   80101c45 <iunlockput>

  ip->nlink--;
80105b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b76:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b7a:	48                   	dec    %eax
80105b7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b7e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b85:	89 04 24             	mov    %eax,(%esp)
80105b88:	e8 f6 bc ff ff       	call   80101883 <iupdate>
  iunlockput(ip);
80105b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b90:	89 04 24             	mov    %eax,(%esp)
80105b93:	e8 ad c0 ff ff       	call   80101c45 <iunlockput>

  end_op();
80105b98:	e8 24 da ff ff       	call   801035c1 <end_op>

  return 0;
80105b9d:	b8 00 00 00 00       	mov    $0x0,%eax
80105ba2:	eb 15                	jmp    80105bb9 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba7:	89 04 24             	mov    %eax,(%esp)
80105baa:	e8 96 c0 ff ff       	call   80101c45 <iunlockput>
  end_op();
80105baf:	e8 0d da ff ff       	call   801035c1 <end_op>
  return -1;
80105bb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bb9:	c9                   	leave  
80105bba:	c3                   	ret    

80105bbb <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105bbb:	55                   	push   %ebp
80105bbc:	89 e5                	mov    %esp,%ebp
80105bbe:	83 ec 48             	sub    $0x48,%esp
80105bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105bc4:	8b 55 10             	mov    0x10(%ebp),%edx
80105bc7:	8b 45 14             	mov    0x14(%ebp),%eax
80105bca:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105bce:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105bd2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105bd6:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80105be0:	89 04 24             	mov    %eax,(%esp)
80105be3:	e8 a5 c9 ff ff       	call   8010258d <nameiparent>
80105be8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105beb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bef:	75 0a                	jne    80105bfb <create+0x40>
    return 0;
80105bf1:	b8 00 00 00 00       	mov    $0x0,%eax
80105bf6:	e9 79 01 00 00       	jmp    80105d74 <create+0x1b9>
  ilock(dp);
80105bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfe:	89 04 24             	mov    %eax,(%esp)
80105c01:	e8 40 be ff ff       	call   80101a46 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c06:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c09:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c0d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c10:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c17:	89 04 24             	mov    %eax,(%esp)
80105c1a:	e8 d3 c5 ff ff       	call   801021f2 <dirlookup>
80105c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c26:	74 46                	je     80105c6e <create+0xb3>
    iunlockput(dp);
80105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2b:	89 04 24             	mov    %eax,(%esp)
80105c2e:	e8 12 c0 ff ff       	call   80101c45 <iunlockput>
    ilock(ip);
80105c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c36:	89 04 24             	mov    %eax,(%esp)
80105c39:	e8 08 be ff ff       	call   80101a46 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105c3e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c43:	75 14                	jne    80105c59 <create+0x9e>
80105c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c48:	8b 40 50             	mov    0x50(%eax),%eax
80105c4b:	66 83 f8 02          	cmp    $0x2,%ax
80105c4f:	75 08                	jne    80105c59 <create+0x9e>
      return ip;
80105c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c54:	e9 1b 01 00 00       	jmp    80105d74 <create+0x1b9>
    iunlockput(ip);
80105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5c:	89 04 24             	mov    %eax,(%esp)
80105c5f:	e8 e1 bf ff ff       	call   80101c45 <iunlockput>
    return 0;
80105c64:	b8 00 00 00 00       	mov    $0x0,%eax
80105c69:	e9 06 01 00 00       	jmp    80105d74 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105c6e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c75:	8b 00                	mov    (%eax),%eax
80105c77:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c7b:	89 04 24             	mov    %eax,(%esp)
80105c7e:	e8 2e bb ff ff       	call   801017b1 <ialloc>
80105c83:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c8a:	75 0c                	jne    80105c98 <create+0xdd>
    panic("create: ialloc");
80105c8c:	c7 04 24 f8 8d 10 80 	movl   $0x80108df8,(%esp)
80105c93:	e8 bc a8 ff ff       	call   80100554 <panic>

  ilock(ip);
80105c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9b:	89 04 24             	mov    %eax,(%esp)
80105c9e:	e8 a3 bd ff ff       	call   80101a46 <ilock>
  ip->major = major;
80105ca3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105ca9:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105cad:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cb0:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105cb3:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cba:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc3:	89 04 24             	mov    %eax,(%esp)
80105cc6:	e8 b8 bb ff ff       	call   80101883 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105ccb:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105cd0:	75 68                	jne    80105d3a <create+0x17f>
    dp->nlink++;  // for ".."
80105cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd5:	66 8b 40 56          	mov    0x56(%eax),%ax
80105cd9:	40                   	inc    %eax
80105cda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cdd:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce4:	89 04 24             	mov    %eax,(%esp)
80105ce7:	e8 97 bb ff ff       	call   80101883 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cef:	8b 40 04             	mov    0x4(%eax),%eax
80105cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf6:	c7 44 24 04 d2 8d 10 	movl   $0x80108dd2,0x4(%esp)
80105cfd:	80 
80105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 af c5 ff ff       	call   801022b8 <dirlink>
80105d09:	85 c0                	test   %eax,%eax
80105d0b:	78 21                	js     80105d2e <create+0x173>
80105d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d10:	8b 40 04             	mov    0x4(%eax),%eax
80105d13:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d17:	c7 44 24 04 d4 8d 10 	movl   $0x80108dd4,0x4(%esp)
80105d1e:	80 
80105d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d22:	89 04 24             	mov    %eax,(%esp)
80105d25:	e8 8e c5 ff ff       	call   801022b8 <dirlink>
80105d2a:	85 c0                	test   %eax,%eax
80105d2c:	79 0c                	jns    80105d3a <create+0x17f>
      panic("create dots");
80105d2e:	c7 04 24 07 8e 10 80 	movl   $0x80108e07,(%esp)
80105d35:	e8 1a a8 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3d:	8b 40 04             	mov    0x4(%eax),%eax
80105d40:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d44:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d47:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4e:	89 04 24             	mov    %eax,(%esp)
80105d51:	e8 62 c5 ff ff       	call   801022b8 <dirlink>
80105d56:	85 c0                	test   %eax,%eax
80105d58:	79 0c                	jns    80105d66 <create+0x1ab>
    panic("create: dirlink");
80105d5a:	c7 04 24 13 8e 10 80 	movl   $0x80108e13,(%esp)
80105d61:	e8 ee a7 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80105d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d69:	89 04 24             	mov    %eax,(%esp)
80105d6c:	e8 d4 be ff ff       	call   80101c45 <iunlockput>

  return ip;
80105d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d74:	c9                   	leave  
80105d75:	c3                   	ret    

80105d76 <sys_open>:

int
sys_open(void)
{
80105d76:	55                   	push   %ebp
80105d77:	89 e5                	mov    %esp,%ebp
80105d79:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105d7c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d8a:	e8 f1 f6 ff ff       	call   80105480 <argstr>
80105d8f:	85 c0                	test   %eax,%eax
80105d91:	78 17                	js     80105daa <sys_open+0x34>
80105d93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d96:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105da1:	e8 43 f6 ff ff       	call   801053e9 <argint>
80105da6:	85 c0                	test   %eax,%eax
80105da8:	79 0a                	jns    80105db4 <sys_open+0x3e>
    return -1;
80105daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105daf:	e9 5b 01 00 00       	jmp    80105f0f <sys_open+0x199>

  begin_op();
80105db4:	e8 86 d7 ff ff       	call   8010353f <begin_op>

  if(omode & O_CREATE){
80105db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dbc:	25 00 02 00 00       	and    $0x200,%eax
80105dc1:	85 c0                	test   %eax,%eax
80105dc3:	74 3b                	je     80105e00 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105dcf:	00 
80105dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105dd7:	00 
80105dd8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105ddf:	00 
80105de0:	89 04 24             	mov    %eax,(%esp)
80105de3:	e8 d3 fd ff ff       	call   80105bbb <create>
80105de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105deb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105def:	75 6a                	jne    80105e5b <sys_open+0xe5>
      end_op();
80105df1:	e8 cb d7 ff ff       	call   801035c1 <end_op>
      return -1;
80105df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfb:	e9 0f 01 00 00       	jmp    80105f0f <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e00:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e03:	89 04 24             	mov    %eax,(%esp)
80105e06:	e8 60 c7 ff ff       	call   8010256b <namei>
80105e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e12:	75 0f                	jne    80105e23 <sys_open+0xad>
      end_op();
80105e14:	e8 a8 d7 ff ff       	call   801035c1 <end_op>
      return -1;
80105e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1e:	e9 ec 00 00 00       	jmp    80105f0f <sys_open+0x199>
    }
    ilock(ip);
80105e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e26:	89 04 24             	mov    %eax,(%esp)
80105e29:	e8 18 bc ff ff       	call   80101a46 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e31:	8b 40 50             	mov    0x50(%eax),%eax
80105e34:	66 83 f8 01          	cmp    $0x1,%ax
80105e38:	75 21                	jne    80105e5b <sys_open+0xe5>
80105e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e3d:	85 c0                	test   %eax,%eax
80105e3f:	74 1a                	je     80105e5b <sys_open+0xe5>
      iunlockput(ip);
80105e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e44:	89 04 24             	mov    %eax,(%esp)
80105e47:	e8 f9 bd ff ff       	call   80101c45 <iunlockput>
      end_op();
80105e4c:	e8 70 d7 ff ff       	call   801035c1 <end_op>
      return -1;
80105e51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e56:	e9 b4 00 00 00       	jmp    80105f0f <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105e5b:	e8 24 b2 ff ff       	call   80101084 <filealloc>
80105e60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e67:	74 14                	je     80105e7d <sys_open+0x107>
80105e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6c:	89 04 24             	mov    %eax,(%esp)
80105e6f:	e8 40 f7 ff ff       	call   801055b4 <fdalloc>
80105e74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105e77:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e7b:	79 28                	jns    80105ea5 <sys_open+0x12f>
    if(f)
80105e7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e81:	74 0b                	je     80105e8e <sys_open+0x118>
      fileclose(f);
80105e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e86:	89 04 24             	mov    %eax,(%esp)
80105e89:	e8 9e b2 ff ff       	call   8010112c <fileclose>
    iunlockput(ip);
80105e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e91:	89 04 24             	mov    %eax,(%esp)
80105e94:	e8 ac bd ff ff       	call   80101c45 <iunlockput>
    end_op();
80105e99:	e8 23 d7 ff ff       	call   801035c1 <end_op>
    return -1;
80105e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea3:	eb 6a                	jmp    80105f0f <sys_open+0x199>
  }
  iunlock(ip);
80105ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea8:	89 04 24             	mov    %eax,(%esp)
80105eab:	e8 a0 bc ff ff       	call   80101b50 <iunlock>
  end_op();
80105eb0:	e8 0c d7 ff ff       	call   801035c1 <end_op>

  f->type = FD_INODE;
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ec4:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eca:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ed4:	83 e0 01             	and    $0x1,%eax
80105ed7:	85 c0                	test   %eax,%eax
80105ed9:	0f 94 c0             	sete   %al
80105edc:	88 c2                	mov    %al,%dl
80105ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ee7:	83 e0 01             	and    $0x1,%eax
80105eea:	85 c0                	test   %eax,%eax
80105eec:	75 0a                	jne    80105ef8 <sys_open+0x182>
80105eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ef1:	83 e0 02             	and    $0x2,%eax
80105ef4:	85 c0                	test   %eax,%eax
80105ef6:	74 07                	je     80105eff <sys_open+0x189>
80105ef8:	b8 01 00 00 00       	mov    $0x1,%eax
80105efd:	eb 05                	jmp    80105f04 <sys_open+0x18e>
80105eff:	b8 00 00 00 00       	mov    $0x0,%eax
80105f04:	88 c2                	mov    %al,%dl
80105f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f09:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f0f:	c9                   	leave  
80105f10:	c3                   	ret    

80105f11 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f11:	55                   	push   %ebp
80105f12:	89 e5                	mov    %esp,%ebp
80105f14:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f17:	e8 23 d6 ff ff       	call   8010353f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f2a:	e8 51 f5 ff ff       	call   80105480 <argstr>
80105f2f:	85 c0                	test   %eax,%eax
80105f31:	78 2c                	js     80105f5f <sys_mkdir+0x4e>
80105f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f36:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105f3d:	00 
80105f3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105f45:	00 
80105f46:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105f4d:	00 
80105f4e:	89 04 24             	mov    %eax,(%esp)
80105f51:	e8 65 fc ff ff       	call   80105bbb <create>
80105f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f5d:	75 0c                	jne    80105f6b <sys_mkdir+0x5a>
    end_op();
80105f5f:	e8 5d d6 ff ff       	call   801035c1 <end_op>
    return -1;
80105f64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f69:	eb 15                	jmp    80105f80 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6e:	89 04 24             	mov    %eax,(%esp)
80105f71:	e8 cf bc ff ff       	call   80101c45 <iunlockput>
  end_op();
80105f76:	e8 46 d6 ff ff       	call   801035c1 <end_op>
  return 0;
80105f7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f80:	c9                   	leave  
80105f81:	c3                   	ret    

80105f82 <sys_mknod>:

int
sys_mknod(void)
{
80105f82:	55                   	push   %ebp
80105f83:	89 e5                	mov    %esp,%ebp
80105f85:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105f88:	e8 b2 d5 ff ff       	call   8010353f <begin_op>
  if((argstr(0, &path)) < 0 ||
80105f8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f9b:	e8 e0 f4 ff ff       	call   80105480 <argstr>
80105fa0:	85 c0                	test   %eax,%eax
80105fa2:	78 5e                	js     80106002 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105fa4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105fb2:	e8 32 f4 ff ff       	call   801053e9 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80105fb7:	85 c0                	test   %eax,%eax
80105fb9:	78 47                	js     80106002 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105fbb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fc2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105fc9:	e8 1b f4 ff ff       	call   801053e9 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105fce:	85 c0                	test   %eax,%eax
80105fd0:	78 30                	js     80106002 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105fd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fd5:	0f bf c8             	movswl %ax,%ecx
80105fd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fdb:	0f bf d0             	movswl %ax,%edx
80105fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105fe1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105fe5:	89 54 24 08          	mov    %edx,0x8(%esp)
80105fe9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105ff0:	00 
80105ff1:	89 04 24             	mov    %eax,(%esp)
80105ff4:	e8 c2 fb ff ff       	call   80105bbb <create>
80105ff9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ffc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106000:	75 0c                	jne    8010600e <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106002:	e8 ba d5 ff ff       	call   801035c1 <end_op>
    return -1;
80106007:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010600c:	eb 15                	jmp    80106023 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010600e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106011:	89 04 24             	mov    %eax,(%esp)
80106014:	e8 2c bc ff ff       	call   80101c45 <iunlockput>
  end_op();
80106019:	e8 a3 d5 ff ff       	call   801035c1 <end_op>
  return 0;
8010601e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106023:	c9                   	leave  
80106024:	c3                   	ret    

80106025 <sys_chdir>:

int
sys_chdir(void)
{
80106025:	55                   	push   %ebp
80106026:	89 e5                	mov    %esp,%ebp
80106028:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010602b:	e8 07 e2 ff ff       	call   80104237 <myproc>
80106030:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106033:	e8 07 d5 ff ff       	call   8010353f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106038:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010603b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010603f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106046:	e8 35 f4 ff ff       	call   80105480 <argstr>
8010604b:	85 c0                	test   %eax,%eax
8010604d:	78 14                	js     80106063 <sys_chdir+0x3e>
8010604f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106052:	89 04 24             	mov    %eax,(%esp)
80106055:	e8 11 c5 ff ff       	call   8010256b <namei>
8010605a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010605d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106061:	75 0c                	jne    8010606f <sys_chdir+0x4a>
    end_op();
80106063:	e8 59 d5 ff ff       	call   801035c1 <end_op>
    return -1;
80106068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606d:	eb 5a                	jmp    801060c9 <sys_chdir+0xa4>
  }
  ilock(ip);
8010606f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106072:	89 04 24             	mov    %eax,(%esp)
80106075:	e8 cc b9 ff ff       	call   80101a46 <ilock>
  if(ip->type != T_DIR){
8010607a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607d:	8b 40 50             	mov    0x50(%eax),%eax
80106080:	66 83 f8 01          	cmp    $0x1,%ax
80106084:	74 17                	je     8010609d <sys_chdir+0x78>
    iunlockput(ip);
80106086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106089:	89 04 24             	mov    %eax,(%esp)
8010608c:	e8 b4 bb ff ff       	call   80101c45 <iunlockput>
    end_op();
80106091:	e8 2b d5 ff ff       	call   801035c1 <end_op>
    return -1;
80106096:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609b:	eb 2c                	jmp    801060c9 <sys_chdir+0xa4>
  }
  iunlock(ip);
8010609d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a0:	89 04 24             	mov    %eax,(%esp)
801060a3:	e8 a8 ba ff ff       	call   80101b50 <iunlock>
  iput(curproc->cwd);
801060a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ab:	8b 40 68             	mov    0x68(%eax),%eax
801060ae:	89 04 24             	mov    %eax,(%esp)
801060b1:	e8 de ba ff ff       	call   80101b94 <iput>
  end_op();
801060b6:	e8 06 d5 ff ff       	call   801035c1 <end_op>
  curproc->cwd = ip;
801060bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060c1:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801060c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060c9:	c9                   	leave  
801060ca:	c3                   	ret    

801060cb <sys_exec>:

int
sys_exec(void)
{
801060cb:	55                   	push   %ebp
801060cc:	89 e5                	mov    %esp,%ebp
801060ce:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801060d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801060db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060e2:	e8 99 f3 ff ff       	call   80105480 <argstr>
801060e7:	85 c0                	test   %eax,%eax
801060e9:	78 1a                	js     80106105 <sys_exec+0x3a>
801060eb:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801060f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801060f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060fc:	e8 e8 f2 ff ff       	call   801053e9 <argint>
80106101:	85 c0                	test   %eax,%eax
80106103:	79 0a                	jns    8010610f <sys_exec+0x44>
    return -1;
80106105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610a:	e9 c7 00 00 00       	jmp    801061d6 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
8010610f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106116:	00 
80106117:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010611e:	00 
8010611f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106125:	89 04 24             	mov    %eax,(%esp)
80106128:	e8 89 ef ff ff       	call   801050b6 <memset>
  for(i=0;; i++){
8010612d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106137:	83 f8 1f             	cmp    $0x1f,%eax
8010613a:	76 0a                	jbe    80106146 <sys_exec+0x7b>
      return -1;
8010613c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106141:	e9 90 00 00 00       	jmp    801061d6 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106149:	c1 e0 02             	shl    $0x2,%eax
8010614c:	89 c2                	mov    %eax,%edx
8010614e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106154:	01 c2                	add    %eax,%edx
80106156:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010615c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106160:	89 14 24             	mov    %edx,(%esp)
80106163:	e8 e0 f1 ff ff       	call   80105348 <fetchint>
80106168:	85 c0                	test   %eax,%eax
8010616a:	79 07                	jns    80106173 <sys_exec+0xa8>
      return -1;
8010616c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106171:	eb 63                	jmp    801061d6 <sys_exec+0x10b>
    if(uarg == 0){
80106173:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106179:	85 c0                	test   %eax,%eax
8010617b:	75 26                	jne    801061a3 <sys_exec+0xd8>
      argv[i] = 0;
8010617d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106180:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106187:	00 00 00 00 
      break;
8010618b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010618c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106195:	89 54 24 04          	mov    %edx,0x4(%esp)
80106199:	89 04 24             	mov    %eax,(%esp)
8010619c:	e8 87 aa ff ff       	call   80100c28 <exec>
801061a1:	eb 33                	jmp    801061d6 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801061a3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ac:	c1 e2 02             	shl    $0x2,%edx
801061af:	01 c2                	add    %eax,%edx
801061b1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801061bb:	89 04 24             	mov    %eax,(%esp)
801061be:	e8 c4 f1 ff ff       	call   80105387 <fetchstr>
801061c3:	85 c0                	test   %eax,%eax
801061c5:	79 07                	jns    801061ce <sys_exec+0x103>
      return -1;
801061c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cc:	eb 08                	jmp    801061d6 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801061ce:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801061d1:	e9 5e ff ff ff       	jmp    80106134 <sys_exec+0x69>
  return exec(path, argv);
}
801061d6:	c9                   	leave  
801061d7:	c3                   	ret    

801061d8 <sys_pipe>:

int
sys_pipe(void)
{
801061d8:	55                   	push   %ebp
801061d9:	89 e5                	mov    %esp,%ebp
801061db:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801061de:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801061e5:	00 
801061e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061f4:	e8 1d f2 ff ff       	call   80105416 <argptr>
801061f9:	85 c0                	test   %eax,%eax
801061fb:	79 0a                	jns    80106207 <sys_pipe+0x2f>
    return -1;
801061fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106202:	e9 9a 00 00 00       	jmp    801062a1 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106207:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010620a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106211:	89 04 24             	mov    %eax,(%esp)
80106214:	e8 73 db ff ff       	call   80103d8c <pipealloc>
80106219:	85 c0                	test   %eax,%eax
8010621b:	79 07                	jns    80106224 <sys_pipe+0x4c>
    return -1;
8010621d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106222:	eb 7d                	jmp    801062a1 <sys_pipe+0xc9>
  fd0 = -1;
80106224:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010622b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010622e:	89 04 24             	mov    %eax,(%esp)
80106231:	e8 7e f3 ff ff       	call   801055b4 <fdalloc>
80106236:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106239:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010623d:	78 14                	js     80106253 <sys_pipe+0x7b>
8010623f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106242:	89 04 24             	mov    %eax,(%esp)
80106245:	e8 6a f3 ff ff       	call   801055b4 <fdalloc>
8010624a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010624d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106251:	79 36                	jns    80106289 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106253:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106257:	78 13                	js     8010626c <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106259:	e8 d9 df ff ff       	call   80104237 <myproc>
8010625e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106261:	83 c2 08             	add    $0x8,%edx
80106264:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010626b:	00 
    fileclose(rf);
8010626c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010626f:	89 04 24             	mov    %eax,(%esp)
80106272:	e8 b5 ae ff ff       	call   8010112c <fileclose>
    fileclose(wf);
80106277:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010627a:	89 04 24             	mov    %eax,(%esp)
8010627d:	e8 aa ae ff ff       	call   8010112c <fileclose>
    return -1;
80106282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106287:	eb 18                	jmp    801062a1 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106289:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010628c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010628f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106291:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106294:	8d 50 04             	lea    0x4(%eax),%edx
80106297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629a:	89 02                	mov    %eax,(%edx)
  return 0;
8010629c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a1:	c9                   	leave  
801062a2:	c3                   	ret    
	...

801062a4 <sys_fork>:
#include "proc.h"
#include "container.h"

int
sys_fork(void)
{
801062a4:	55                   	push   %ebp
801062a5:	89 e5                	mov    %esp,%ebp
801062a7:	83 ec 08             	sub    $0x8,%esp
  return fork();
801062aa:	e8 91 e2 ff ff       	call   80104540 <fork>
}
801062af:	c9                   	leave  
801062b0:	c3                   	ret    

801062b1 <sys_exit>:

int
sys_exit(void)
{
801062b1:	55                   	push   %ebp
801062b2:	89 e5                	mov    %esp,%ebp
801062b4:	83 ec 08             	sub    $0x8,%esp
  exit();
801062b7:	e8 ea e3 ff ff       	call   801046a6 <exit>
  return 0;  // not reached
801062bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c1:	c9                   	leave  
801062c2:	c3                   	ret    

801062c3 <sys_wait>:

int
sys_wait(void)
{
801062c3:	55                   	push   %ebp
801062c4:	89 e5                	mov    %esp,%ebp
801062c6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801062c9:	e8 e1 e4 ff ff       	call   801047af <wait>
}
801062ce:	c9                   	leave  
801062cf:	c3                   	ret    

801062d0 <sys_kill>:

int
sys_kill(void)
{
801062d0:	55                   	push   %ebp
801062d1:	89 e5                	mov    %esp,%ebp
801062d3:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801062d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801062dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062e4:	e8 00 f1 ff ff       	call   801053e9 <argint>
801062e9:	85 c0                	test   %eax,%eax
801062eb:	79 07                	jns    801062f4 <sys_kill+0x24>
    return -1;
801062ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f2:	eb 0b                	jmp    801062ff <sys_kill+0x2f>
  return kill(pid);
801062f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f7:	89 04 24             	mov    %eax,(%esp)
801062fa:	e8 85 e8 ff ff       	call   80104b84 <kill>
}
801062ff:	c9                   	leave  
80106300:	c3                   	ret    

80106301 <sys_getpid>:

int
sys_getpid(void)
{
80106301:	55                   	push   %ebp
80106302:	89 e5                	mov    %esp,%ebp
80106304:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106307:	e8 2b df ff ff       	call   80104237 <myproc>
8010630c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010630f:	c9                   	leave  
80106310:	c3                   	ret    

80106311 <sys_sbrk>:

int
sys_sbrk(void)
{
80106311:	55                   	push   %ebp
80106312:	89 e5                	mov    %esp,%ebp
80106314:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106317:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010631a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010631e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106325:	e8 bf f0 ff ff       	call   801053e9 <argint>
8010632a:	85 c0                	test   %eax,%eax
8010632c:	79 07                	jns    80106335 <sys_sbrk+0x24>
    return -1;
8010632e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106333:	eb 23                	jmp    80106358 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106335:	e8 fd de ff ff       	call   80104237 <myproc>
8010633a:	8b 00                	mov    (%eax),%eax
8010633c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010633f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106342:	89 04 24             	mov    %eax,(%esp)
80106345:	e8 58 e1 ff ff       	call   801044a2 <growproc>
8010634a:	85 c0                	test   %eax,%eax
8010634c:	79 07                	jns    80106355 <sys_sbrk+0x44>
    return -1;
8010634e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106353:	eb 03                	jmp    80106358 <sys_sbrk+0x47>
  return addr;
80106355:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106358:	c9                   	leave  
80106359:	c3                   	ret    

8010635a <sys_sleep>:

int
sys_sleep(void)
{
8010635a:	55                   	push   %ebp
8010635b:	89 e5                	mov    %esp,%ebp
8010635d:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106360:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106363:	89 44 24 04          	mov    %eax,0x4(%esp)
80106367:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010636e:	e8 76 f0 ff ff       	call   801053e9 <argint>
80106373:	85 c0                	test   %eax,%eax
80106375:	79 07                	jns    8010637e <sys_sleep+0x24>
    return -1;
80106377:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637c:	eb 6b                	jmp    801063e9 <sys_sleep+0x8f>
  acquire(&tickslock);
8010637e:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
80106385:	e8 c9 ea ff ff       	call   80104e53 <acquire>
  ticks0 = ticks;
8010638a:	a1 c0 78 11 80       	mov    0x801178c0,%eax
8010638f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106392:	eb 33                	jmp    801063c7 <sys_sleep+0x6d>
    if(myproc()->killed){
80106394:	e8 9e de ff ff       	call   80104237 <myproc>
80106399:	8b 40 24             	mov    0x24(%eax),%eax
8010639c:	85 c0                	test   %eax,%eax
8010639e:	74 13                	je     801063b3 <sys_sleep+0x59>
      release(&tickslock);
801063a0:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
801063a7:	e8 11 eb ff ff       	call   80104ebd <release>
      return -1;
801063ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b1:	eb 36                	jmp    801063e9 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
801063b3:	c7 44 24 04 80 70 11 	movl   $0x80117080,0x4(%esp)
801063ba:	80 
801063bb:	c7 04 24 c0 78 11 80 	movl   $0x801178c0,(%esp)
801063c2:	e8 be e6 ff ff       	call   80104a85 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801063c7:	a1 c0 78 11 80       	mov    0x801178c0,%eax
801063cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801063cf:	89 c2                	mov    %eax,%edx
801063d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d4:	39 c2                	cmp    %eax,%edx
801063d6:	72 bc                	jb     80106394 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801063d8:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
801063df:	e8 d9 ea ff ff       	call   80104ebd <release>
  return 0;
801063e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063e9:	c9                   	leave  
801063ea:	c3                   	ret    

801063eb <sys_get_name>:

void sys_get_name(void){
801063eb:	55                   	push   %ebp
801063ec:	89 e5                	mov    %esp,%ebp
801063ee:	83 ec 28             	sub    $0x28,%esp

  char* name;
  fetchstr(0, &name);
801063f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063ff:	e8 83 ef ff ff       	call   80105387 <fetchstr>

  int vc_num;
  fetchint(1, &vc_num);
80106404:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106407:	89 44 24 04          	mov    %eax,0x4(%esp)
8010640b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106412:	e8 31 ef ff ff       	call   80105348 <fetchint>

  get_name(name, vc_num);
80106417:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010641a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106421:	89 04 24             	mov    %eax,(%esp)
80106424:	e8 59 21 00 00       	call   80108582 <get_name>
  return;
80106429:	90                   	nop
}
8010642a:	c9                   	leave  
8010642b:	c3                   	ret    

8010642c <sys_get_max_proc>:

int sys_get_max_proc(void){
8010642c:	55                   	push   %ebp
8010642d:	89 e5                	mov    %esp,%ebp
8010642f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
80106432:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106435:	89 44 24 04          	mov    %eax,0x4(%esp)
80106439:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106440:	e8 03 ef ff ff       	call   80105348 <fetchint>


  return get_max_proc(vc_num);  
80106445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106448:	89 04 24             	mov    %eax,(%esp)
8010644b:	e8 3b 22 00 00       	call   8010868b <get_max_proc>
}
80106450:	c9                   	leave  
80106451:	c3                   	ret    

80106452 <sys_get_max_mem>:

int sys_get_max_mem(void){
80106452:	55                   	push   %ebp
80106453:	89 e5                	mov    %esp,%ebp
80106455:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
80106458:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010645b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010645f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106466:	e8 dd ee ff ff       	call   80105348 <fetchint>


  return get_max_mem(vc_num);
8010646b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010646e:	89 04 24             	mov    %eax,(%esp)
80106471:	e8 54 22 00 00       	call   801086ca <get_max_mem>
}
80106476:	c9                   	leave  
80106477:	c3                   	ret    

80106478 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106478:	55                   	push   %ebp
80106479:	89 e5                	mov    %esp,%ebp
8010647b:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
8010647e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106481:	89 44 24 04          	mov    %eax,0x4(%esp)
80106485:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010648c:	e8 b7 ee ff ff       	call   80105348 <fetchint>


  return get_max_disk(vc_num);
80106491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106494:	89 04 24             	mov    %eax,(%esp)
80106497:	e8 6d 22 00 00       	call   80108709 <get_max_disk>

}
8010649c:	c9                   	leave  
8010649d:	c3                   	ret    

8010649e <sys_get_curr_proc>:

int sys_get_curr_proc(void){
8010649e:	55                   	push   %ebp
8010649f:	89 e5                	mov    %esp,%ebp
801064a1:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801064a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b2:	e8 91 ee ff ff       	call   80105348 <fetchint>


  return get_curr_proc(vc_num);
801064b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ba:	89 04 24             	mov    %eax,(%esp)
801064bd:	e8 86 22 00 00       	call   80108748 <get_curr_proc>
}
801064c2:	c9                   	leave  
801064c3:	c3                   	ret    

801064c4 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
801064c4:	55                   	push   %ebp
801064c5:	89 e5                	mov    %esp,%ebp
801064c7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801064ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801064d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064d8:	e8 6b ee ff ff       	call   80105348 <fetchint>


  return get_curr_mem(vc_num);
801064dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e0:	89 04 24             	mov    %eax,(%esp)
801064e3:	e8 9f 22 00 00       	call   80108787 <get_curr_mem>
}
801064e8:	c9                   	leave  
801064e9:	c3                   	ret    

801064ea <sys_get_curr_disk>:

int sys_get_curr_disk(void){
801064ea:	55                   	push   %ebp
801064eb:	89 e5                	mov    %esp,%ebp
801064ed:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801064f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801064f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064fe:	e8 45 ee ff ff       	call   80105348 <fetchint>


  return get_curr_disk(vc_num);
80106503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106506:	89 04 24             	mov    %eax,(%esp)
80106509:	e8 b8 22 00 00       	call   801087c6 <get_curr_disk>
}
8010650e:	c9                   	leave  
8010650f:	c3                   	ret    

80106510 <sys_set_name>:

void sys_set_name(void){
80106510:	55                   	push   %ebp
80106511:	89 e5                	mov    %esp,%ebp
80106513:	83 ec 28             	sub    $0x28,%esp
  char* name;
  fetchstr(0, &name);
80106516:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106519:	89 44 24 04          	mov    %eax,0x4(%esp)
8010651d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106524:	e8 5e ee ff ff       	call   80105387 <fetchstr>

  int vc_num;
  fetchint(1, &vc_num);
80106529:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010652c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106530:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106537:	e8 0c ee ff ff       	call   80105348 <fetchint>

  set_name(name, vc_num);
8010653c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010653f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106542:	89 54 24 04          	mov    %edx,0x4(%esp)
80106546:	89 04 24             	mov    %eax,(%esp)
80106549:	e8 b7 22 00 00       	call   80108805 <set_name>
}
8010654e:	c9                   	leave  
8010654f:	c3                   	ret    

80106550 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106550:	55                   	push   %ebp
80106551:	89 e5                	mov    %esp,%ebp
80106553:	83 ec 28             	sub    $0x28,%esp
  int mem;
  fetchint(0, &mem);
80106556:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106559:	89 44 24 04          	mov    %eax,0x4(%esp)
8010655d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106564:	e8 df ed ff ff       	call   80105348 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106569:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010656c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106570:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106577:	e8 cc ed ff ff       	call   80105348 <fetchint>

  set_max_mem(mem, vc_num);
8010657c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106582:	89 54 24 04          	mov    %edx,0x4(%esp)
80106586:	89 04 24             	mov    %eax,(%esp)
80106589:	e8 aa 22 00 00       	call   80108838 <set_max_mem>
}
8010658e:	c9                   	leave  
8010658f:	c3                   	ret    

80106590 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106590:	55                   	push   %ebp
80106591:	89 e5                	mov    %esp,%ebp
80106593:	83 ec 28             	sub    $0x28,%esp
  int disk;
  fetchint(0, &disk);
80106596:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106599:	89 44 24 04          	mov    %eax,0x4(%esp)
8010659d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065a4:	e8 9f ed ff ff       	call   80105348 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801065a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065b7:	e8 8c ed ff ff       	call   80105348 <fetchint>

  set_max_disk(disk, vc_num);
801065bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801065c6:	89 04 24             	mov    %eax,(%esp)
801065c9:	e8 8e 22 00 00       	call   8010885c <set_max_disk>
}
801065ce:	c9                   	leave  
801065cf:	c3                   	ret    

801065d0 <sys_set_max_proc>:

void sys_set_max_proc(void){
801065d0:	55                   	push   %ebp
801065d1:	89 e5                	mov    %esp,%ebp
801065d3:	83 ec 28             	sub    $0x28,%esp
  int proc;
  fetchint(0, &proc);
801065d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065e4:	e8 5f ed ff ff       	call   80105348 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801065e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801065f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065f7:	e8 4c ed ff ff       	call   80105348 <fetchint>

  set_max_proc(proc, vc_num);
801065fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106602:	89 54 24 04          	mov    %edx,0x4(%esp)
80106606:	89 04 24             	mov    %eax,(%esp)
80106609:	e8 73 22 00 00       	call   80108881 <set_max_proc>
}
8010660e:	c9                   	leave  
8010660f:	c3                   	ret    

80106610 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106610:	55                   	push   %ebp
80106611:	89 e5                	mov    %esp,%ebp
80106613:	83 ec 28             	sub    $0x28,%esp
  int mem;
  fetchint(0, &mem);
80106616:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106619:	89 44 24 04          	mov    %eax,0x4(%esp)
8010661d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106624:	e8 1f ed ff ff       	call   80105348 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106629:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010662c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106630:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106637:	e8 0c ed ff ff       	call   80105348 <fetchint>

  set_curr_mem(mem, vc_num);
8010663c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010663f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106642:	89 54 24 04          	mov    %edx,0x4(%esp)
80106646:	89 04 24             	mov    %eax,(%esp)
80106649:	e8 58 22 00 00       	call   801088a6 <set_curr_mem>
}
8010664e:	c9                   	leave  
8010664f:	c3                   	ret    

80106650 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106650:	55                   	push   %ebp
80106651:	89 e5                	mov    %esp,%ebp
80106653:	83 ec 28             	sub    $0x28,%esp
  int disk;
  fetchint(0, &disk);
80106656:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106659:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106664:	e8 df ec ff ff       	call   80105348 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106669:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010666c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106670:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106677:	e8 cc ec ff ff       	call   80105348 <fetchint>

  set_curr_disk(disk, vc_num);
8010667c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010667f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106682:	89 54 24 04          	mov    %edx,0x4(%esp)
80106686:	89 04 24             	mov    %eax,(%esp)
80106689:	e8 3d 22 00 00       	call   801088cb <set_curr_disk>
}
8010668e:	c9                   	leave  
8010668f:	c3                   	ret    

80106690 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	83 ec 28             	sub    $0x28,%esp
  int proc;
  fetchint(0, &proc);
80106696:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106699:	89 44 24 04          	mov    %eax,0x4(%esp)
8010669d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066a4:	e8 9f ec ff ff       	call   80105348 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801066a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066b7:	e8 8c ec ff ff       	call   80105348 <fetchint>

  set_curr_proc(proc, vc_num);
801066bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801066c6:	89 04 24             	mov    %eax,(%esp)
801066c9:	e8 22 22 00 00       	call   801088f0 <set_curr_proc>
}
801066ce:	c9                   	leave  
801066cf:	c3                   	ret    

801066d0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066d0:	55                   	push   %ebp
801066d1:	89 e5                	mov    %esp,%ebp
801066d3:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801066d6:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
801066dd:	e8 71 e7 ff ff       	call   80104e53 <acquire>
  xticks = ticks;
801066e2:	a1 c0 78 11 80       	mov    0x801178c0,%eax
801066e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066ea:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
801066f1:	e8 c7 e7 ff ff       	call   80104ebd <release>
  return xticks;
801066f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066f9:	c9                   	leave  
801066fa:	c3                   	ret    

801066fb <sys_getticks>:

int
sys_getticks(void)
{
801066fb:	55                   	push   %ebp
801066fc:	89 e5                	mov    %esp,%ebp
801066fe:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106701:	e8 31 db ff ff       	call   80104237 <myproc>
80106706:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106709:	c9                   	leave  
8010670a:	c3                   	ret    
	...

8010670c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010670c:	1e                   	push   %ds
  pushl %es
8010670d:	06                   	push   %es
  pushl %fs
8010670e:	0f a0                	push   %fs
  pushl %gs
80106710:	0f a8                	push   %gs
  pushal
80106712:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106713:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106717:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106719:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010671b:	54                   	push   %esp
  call trap
8010671c:	e8 c0 01 00 00       	call   801068e1 <trap>
  addl $4, %esp
80106721:	83 c4 04             	add    $0x4,%esp

80106724 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106724:	61                   	popa   
  popl %gs
80106725:	0f a9                	pop    %gs
  popl %fs
80106727:	0f a1                	pop    %fs
  popl %es
80106729:	07                   	pop    %es
  popl %ds
8010672a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010672b:	83 c4 08             	add    $0x8,%esp
  iret
8010672e:	cf                   	iret   
	...

80106730 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106730:	55                   	push   %ebp
80106731:	89 e5                	mov    %esp,%ebp
80106733:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106736:	8b 45 0c             	mov    0xc(%ebp),%eax
80106739:	48                   	dec    %eax
8010673a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010673e:	8b 45 08             	mov    0x8(%ebp),%eax
80106741:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106745:	8b 45 08             	mov    0x8(%ebp),%eax
80106748:	c1 e8 10             	shr    $0x10,%eax
8010674b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010674f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106752:	0f 01 18             	lidtl  (%eax)
}
80106755:	c9                   	leave  
80106756:	c3                   	ret    

80106757 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106757:	55                   	push   %ebp
80106758:	89 e5                	mov    %esp,%ebp
8010675a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010675d:	0f 20 d0             	mov    %cr2,%eax
80106760:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106763:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106766:	c9                   	leave  
80106767:	c3                   	ret    

80106768 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106768:	55                   	push   %ebp
80106769:	89 e5                	mov    %esp,%ebp
8010676b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010676e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106775:	e9 b8 00 00 00       	jmp    80106832 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010677a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677d:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
80106784:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106787:	66 89 04 d5 c0 70 11 	mov    %ax,-0x7fee8f40(,%edx,8)
8010678e:	80 
8010678f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106792:	66 c7 04 c5 c2 70 11 	movw   $0x8,-0x7fee8f3e(,%eax,8)
80106799:	80 08 00 
8010679c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679f:	8a 14 c5 c4 70 11 80 	mov    -0x7fee8f3c(,%eax,8),%dl
801067a6:	83 e2 e0             	and    $0xffffffe0,%edx
801067a9:	88 14 c5 c4 70 11 80 	mov    %dl,-0x7fee8f3c(,%eax,8)
801067b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b3:	8a 14 c5 c4 70 11 80 	mov    -0x7fee8f3c(,%eax,8),%dl
801067ba:	83 e2 1f             	and    $0x1f,%edx
801067bd:	88 14 c5 c4 70 11 80 	mov    %dl,-0x7fee8f3c(,%eax,8)
801067c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c7:	8a 14 c5 c5 70 11 80 	mov    -0x7fee8f3b(,%eax,8),%dl
801067ce:	83 e2 f0             	and    $0xfffffff0,%edx
801067d1:	83 ca 0e             	or     $0xe,%edx
801067d4:	88 14 c5 c5 70 11 80 	mov    %dl,-0x7fee8f3b(,%eax,8)
801067db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067de:	8a 14 c5 c5 70 11 80 	mov    -0x7fee8f3b(,%eax,8),%dl
801067e5:	83 e2 ef             	and    $0xffffffef,%edx
801067e8:	88 14 c5 c5 70 11 80 	mov    %dl,-0x7fee8f3b(,%eax,8)
801067ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f2:	8a 14 c5 c5 70 11 80 	mov    -0x7fee8f3b(,%eax,8),%dl
801067f9:	83 e2 9f             	and    $0xffffff9f,%edx
801067fc:	88 14 c5 c5 70 11 80 	mov    %dl,-0x7fee8f3b(,%eax,8)
80106803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106806:	8a 14 c5 c5 70 11 80 	mov    -0x7fee8f3b(,%eax,8),%dl
8010680d:	83 ca 80             	or     $0xffffff80,%edx
80106810:	88 14 c5 c5 70 11 80 	mov    %dl,-0x7fee8f3b(,%eax,8)
80106817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681a:	8b 04 85 b4 c0 10 80 	mov    -0x7fef3f4c(,%eax,4),%eax
80106821:	c1 e8 10             	shr    $0x10,%eax
80106824:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106827:	66 89 04 d5 c6 70 11 	mov    %ax,-0x7fee8f3a(,%edx,8)
8010682e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010682f:	ff 45 f4             	incl   -0xc(%ebp)
80106832:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106839:	0f 8e 3b ff ff ff    	jle    8010677a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010683f:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
80106844:	66 a3 c0 72 11 80    	mov    %ax,0x801172c0
8010684a:	66 c7 05 c2 72 11 80 	movw   $0x8,0x801172c2
80106851:	08 00 
80106853:	a0 c4 72 11 80       	mov    0x801172c4,%al
80106858:	83 e0 e0             	and    $0xffffffe0,%eax
8010685b:	a2 c4 72 11 80       	mov    %al,0x801172c4
80106860:	a0 c4 72 11 80       	mov    0x801172c4,%al
80106865:	83 e0 1f             	and    $0x1f,%eax
80106868:	a2 c4 72 11 80       	mov    %al,0x801172c4
8010686d:	a0 c5 72 11 80       	mov    0x801172c5,%al
80106872:	83 c8 0f             	or     $0xf,%eax
80106875:	a2 c5 72 11 80       	mov    %al,0x801172c5
8010687a:	a0 c5 72 11 80       	mov    0x801172c5,%al
8010687f:	83 e0 ef             	and    $0xffffffef,%eax
80106882:	a2 c5 72 11 80       	mov    %al,0x801172c5
80106887:	a0 c5 72 11 80       	mov    0x801172c5,%al
8010688c:	83 c8 60             	or     $0x60,%eax
8010688f:	a2 c5 72 11 80       	mov    %al,0x801172c5
80106894:	a0 c5 72 11 80       	mov    0x801172c5,%al
80106899:	83 c8 80             	or     $0xffffff80,%eax
8010689c:	a2 c5 72 11 80       	mov    %al,0x801172c5
801068a1:	a1 b4 c1 10 80       	mov    0x8010c1b4,%eax
801068a6:	c1 e8 10             	shr    $0x10,%eax
801068a9:	66 a3 c6 72 11 80    	mov    %ax,0x801172c6

  initlock(&tickslock, "time");
801068af:	c7 44 24 04 24 8e 10 	movl   $0x80108e24,0x4(%esp)
801068b6:	80 
801068b7:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
801068be:	e8 6f e5 ff ff       	call   80104e32 <initlock>
}
801068c3:	c9                   	leave  
801068c4:	c3                   	ret    

801068c5 <idtinit>:

void
idtinit(void)
{
801068c5:	55                   	push   %ebp
801068c6:	89 e5                	mov    %esp,%ebp
801068c8:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801068cb:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801068d2:	00 
801068d3:	c7 04 24 c0 70 11 80 	movl   $0x801170c0,(%esp)
801068da:	e8 51 fe ff ff       	call   80106730 <lidt>
}
801068df:	c9                   	leave  
801068e0:	c3                   	ret    

801068e1 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068e1:	55                   	push   %ebp
801068e2:	89 e5                	mov    %esp,%ebp
801068e4:	57                   	push   %edi
801068e5:	56                   	push   %esi
801068e6:	53                   	push   %ebx
801068e7:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
801068ea:	8b 45 08             	mov    0x8(%ebp),%eax
801068ed:	8b 40 30             	mov    0x30(%eax),%eax
801068f0:	83 f8 40             	cmp    $0x40,%eax
801068f3:	75 3c                	jne    80106931 <trap+0x50>
    if(myproc()->killed)
801068f5:	e8 3d d9 ff ff       	call   80104237 <myproc>
801068fa:	8b 40 24             	mov    0x24(%eax),%eax
801068fd:	85 c0                	test   %eax,%eax
801068ff:	74 05                	je     80106906 <trap+0x25>
      exit();
80106901:	e8 a0 dd ff ff       	call   801046a6 <exit>
    myproc()->tf = tf;
80106906:	e8 2c d9 ff ff       	call   80104237 <myproc>
8010690b:	8b 55 08             	mov    0x8(%ebp),%edx
8010690e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106911:	e8 a1 eb ff ff       	call   801054b7 <syscall>
    if(myproc()->killed)
80106916:	e8 1c d9 ff ff       	call   80104237 <myproc>
8010691b:	8b 40 24             	mov    0x24(%eax),%eax
8010691e:	85 c0                	test   %eax,%eax
80106920:	74 0a                	je     8010692c <trap+0x4b>
      exit();
80106922:	e8 7f dd ff ff       	call   801046a6 <exit>
    return;
80106927:	e9 30 02 00 00       	jmp    80106b5c <trap+0x27b>
8010692c:	e9 2b 02 00 00       	jmp    80106b5c <trap+0x27b>
  }

  switch(tf->trapno){
80106931:	8b 45 08             	mov    0x8(%ebp),%eax
80106934:	8b 40 30             	mov    0x30(%eax),%eax
80106937:	83 e8 20             	sub    $0x20,%eax
8010693a:	83 f8 1f             	cmp    $0x1f,%eax
8010693d:	0f 87 cb 00 00 00    	ja     80106a0e <trap+0x12d>
80106943:	8b 04 85 cc 8e 10 80 	mov    -0x7fef7134(,%eax,4),%eax
8010694a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010694c:	e8 1d d8 ff ff       	call   8010416e <cpuid>
80106951:	85 c0                	test   %eax,%eax
80106953:	75 2f                	jne    80106984 <trap+0xa3>
      acquire(&tickslock);
80106955:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
8010695c:	e8 f2 e4 ff ff       	call   80104e53 <acquire>
      ticks++;
80106961:	a1 c0 78 11 80       	mov    0x801178c0,%eax
80106966:	40                   	inc    %eax
80106967:	a3 c0 78 11 80       	mov    %eax,0x801178c0
      wakeup(&ticks);
8010696c:	c7 04 24 c0 78 11 80 	movl   $0x801178c0,(%esp)
80106973:	e8 e1 e1 ff ff       	call   80104b59 <wakeup>
      release(&tickslock);
80106978:	c7 04 24 80 70 11 80 	movl   $0x80117080,(%esp)
8010697f:	e8 39 e5 ff ff       	call   80104ebd <release>
    }
    p = myproc();
80106984:	e8 ae d8 ff ff       	call   80104237 <myproc>
80106989:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
8010698c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106990:	74 0f                	je     801069a1 <trap+0xc0>
      p->ticks++;
80106992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106995:	8b 40 7c             	mov    0x7c(%eax),%eax
80106998:	8d 50 01             	lea    0x1(%eax),%edx
8010699b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010699e:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801069a1:	e8 71 c6 ff ff       	call   80103017 <lapiceoi>
    break;
801069a6:	e9 35 01 00 00       	jmp    80106ae0 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801069ab:	e8 e6 be ff ff       	call   80102896 <ideintr>
    lapiceoi();
801069b0:	e8 62 c6 ff ff       	call   80103017 <lapiceoi>
    break;
801069b5:	e9 26 01 00 00       	jmp    80106ae0 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801069ba:	e8 6f c4 ff ff       	call   80102e2e <kbdintr>
    lapiceoi();
801069bf:	e8 53 c6 ff ff       	call   80103017 <lapiceoi>
    break;
801069c4:	e9 17 01 00 00       	jmp    80106ae0 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801069c9:	e8 6f 03 00 00       	call   80106d3d <uartintr>
    lapiceoi();
801069ce:	e8 44 c6 ff ff       	call   80103017 <lapiceoi>
    break;
801069d3:	e9 08 01 00 00       	jmp    80106ae0 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069d8:	8b 45 08             	mov    0x8(%ebp),%eax
801069db:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801069de:	8b 45 08             	mov    0x8(%ebp),%eax
801069e1:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069e4:	0f b7 d8             	movzwl %ax,%ebx
801069e7:	e8 82 d7 ff ff       	call   8010416e <cpuid>
801069ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
801069f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801069f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f8:	c7 04 24 2c 8e 10 80 	movl   $0x80108e2c,(%esp)
801069ff:	e8 bd 99 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106a04:	e8 0e c6 ff ff       	call   80103017 <lapiceoi>
    break;
80106a09:	e9 d2 00 00 00       	jmp    80106ae0 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106a0e:	e8 24 d8 ff ff       	call   80104237 <myproc>
80106a13:	85 c0                	test   %eax,%eax
80106a15:	74 10                	je     80106a27 <trap+0x146>
80106a17:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1a:	8b 40 3c             	mov    0x3c(%eax),%eax
80106a1d:	0f b7 c0             	movzwl %ax,%eax
80106a20:	83 e0 03             	and    $0x3,%eax
80106a23:	85 c0                	test   %eax,%eax
80106a25:	75 40                	jne    80106a67 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a27:	e8 2b fd ff ff       	call   80106757 <rcr2>
80106a2c:	89 c3                	mov    %eax,%ebx
80106a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a31:	8b 70 38             	mov    0x38(%eax),%esi
80106a34:	e8 35 d7 ff ff       	call   8010416e <cpuid>
80106a39:	8b 55 08             	mov    0x8(%ebp),%edx
80106a3c:	8b 52 30             	mov    0x30(%edx),%edx
80106a3f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106a43:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106a47:	89 44 24 08          	mov    %eax,0x8(%esp)
80106a4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a4f:	c7 04 24 50 8e 10 80 	movl   $0x80108e50,(%esp)
80106a56:	e8 66 99 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106a5b:	c7 04 24 82 8e 10 80 	movl   $0x80108e82,(%esp)
80106a62:	e8 ed 9a ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a67:	e8 eb fc ff ff       	call   80106757 <rcr2>
80106a6c:	89 c6                	mov    %eax,%esi
80106a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a71:	8b 40 38             	mov    0x38(%eax),%eax
80106a74:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106a77:	e8 f2 d6 ff ff       	call   8010416e <cpuid>
80106a7c:	89 c3                	mov    %eax,%ebx
80106a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a81:	8b 78 34             	mov    0x34(%eax),%edi
80106a84:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106a87:	8b 45 08             	mov    0x8(%ebp),%eax
80106a8a:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106a8d:	e8 a5 d7 ff ff       	call   80104237 <myproc>
80106a92:	8d 50 6c             	lea    0x6c(%eax),%edx
80106a95:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106a98:	e8 9a d7 ff ff       	call   80104237 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a9d:	8b 40 10             	mov    0x10(%eax),%eax
80106aa0:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106aa4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106aa7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106aab:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106aaf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106ab2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106ab6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106aba:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106abd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac5:	c7 04 24 88 8e 10 80 	movl   $0x80108e88,(%esp)
80106acc:	e8 f0 98 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ad1:	e8 61 d7 ff ff       	call   80104237 <myproc>
80106ad6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106add:	eb 01                	jmp    80106ae0 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106adf:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ae0:	e8 52 d7 ff ff       	call   80104237 <myproc>
80106ae5:	85 c0                	test   %eax,%eax
80106ae7:	74 22                	je     80106b0b <trap+0x22a>
80106ae9:	e8 49 d7 ff ff       	call   80104237 <myproc>
80106aee:	8b 40 24             	mov    0x24(%eax),%eax
80106af1:	85 c0                	test   %eax,%eax
80106af3:	74 16                	je     80106b0b <trap+0x22a>
80106af5:	8b 45 08             	mov    0x8(%ebp),%eax
80106af8:	8b 40 3c             	mov    0x3c(%eax),%eax
80106afb:	0f b7 c0             	movzwl %ax,%eax
80106afe:	83 e0 03             	and    $0x3,%eax
80106b01:	83 f8 03             	cmp    $0x3,%eax
80106b04:	75 05                	jne    80106b0b <trap+0x22a>
    exit();
80106b06:	e8 9b db ff ff       	call   801046a6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b0b:	e8 27 d7 ff ff       	call   80104237 <myproc>
80106b10:	85 c0                	test   %eax,%eax
80106b12:	74 1d                	je     80106b31 <trap+0x250>
80106b14:	e8 1e d7 ff ff       	call   80104237 <myproc>
80106b19:	8b 40 0c             	mov    0xc(%eax),%eax
80106b1c:	83 f8 04             	cmp    $0x4,%eax
80106b1f:	75 10                	jne    80106b31 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b21:	8b 45 08             	mov    0x8(%ebp),%eax
80106b24:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b27:	83 f8 20             	cmp    $0x20,%eax
80106b2a:	75 05                	jne    80106b31 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106b2c:	e8 e4 de ff ff       	call   80104a15 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b31:	e8 01 d7 ff ff       	call   80104237 <myproc>
80106b36:	85 c0                	test   %eax,%eax
80106b38:	74 22                	je     80106b5c <trap+0x27b>
80106b3a:	e8 f8 d6 ff ff       	call   80104237 <myproc>
80106b3f:	8b 40 24             	mov    0x24(%eax),%eax
80106b42:	85 c0                	test   %eax,%eax
80106b44:	74 16                	je     80106b5c <trap+0x27b>
80106b46:	8b 45 08             	mov    0x8(%ebp),%eax
80106b49:	8b 40 3c             	mov    0x3c(%eax),%eax
80106b4c:	0f b7 c0             	movzwl %ax,%eax
80106b4f:	83 e0 03             	and    $0x3,%eax
80106b52:	83 f8 03             	cmp    $0x3,%eax
80106b55:	75 05                	jne    80106b5c <trap+0x27b>
    exit();
80106b57:	e8 4a db ff ff       	call   801046a6 <exit>
}
80106b5c:	83 c4 4c             	add    $0x4c,%esp
80106b5f:	5b                   	pop    %ebx
80106b60:	5e                   	pop    %esi
80106b61:	5f                   	pop    %edi
80106b62:	5d                   	pop    %ebp
80106b63:	c3                   	ret    

80106b64 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b64:	55                   	push   %ebp
80106b65:	89 e5                	mov    %esp,%ebp
80106b67:	83 ec 14             	sub    $0x14,%esp
80106b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b74:	89 c2                	mov    %eax,%edx
80106b76:	ec                   	in     (%dx),%al
80106b77:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b7a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106b7d:	c9                   	leave  
80106b7e:	c3                   	ret    

80106b7f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b7f:	55                   	push   %ebp
80106b80:	89 e5                	mov    %esp,%ebp
80106b82:	83 ec 08             	sub    $0x8,%esp
80106b85:	8b 45 08             	mov    0x8(%ebp),%eax
80106b88:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b8b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106b8f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b92:	8a 45 f8             	mov    -0x8(%ebp),%al
80106b95:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106b98:	ee                   	out    %al,(%dx)
}
80106b99:	c9                   	leave  
80106b9a:	c3                   	ret    

80106b9b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b9b:	55                   	push   %ebp
80106b9c:	89 e5                	mov    %esp,%ebp
80106b9e:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ba1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ba8:	00 
80106ba9:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106bb0:	e8 ca ff ff ff       	call   80106b7f <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bb5:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106bbc:	00 
80106bbd:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106bc4:	e8 b6 ff ff ff       	call   80106b7f <outb>
  outb(COM1+0, 115200/9600);
80106bc9:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106bd0:	00 
80106bd1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106bd8:	e8 a2 ff ff ff       	call   80106b7f <outb>
  outb(COM1+1, 0);
80106bdd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106be4:	00 
80106be5:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106bec:	e8 8e ff ff ff       	call   80106b7f <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106bf1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106bf8:	00 
80106bf9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c00:	e8 7a ff ff ff       	call   80106b7f <outb>
  outb(COM1+4, 0);
80106c05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c0c:	00 
80106c0d:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106c14:	e8 66 ff ff ff       	call   80106b7f <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106c20:	00 
80106c21:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c28:	e8 52 ff ff ff       	call   80106b7f <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c2d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c34:	e8 2b ff ff ff       	call   80106b64 <inb>
80106c39:	3c ff                	cmp    $0xff,%al
80106c3b:	75 02                	jne    80106c3f <uartinit+0xa4>
    return;
80106c3d:	eb 5b                	jmp    80106c9a <uartinit+0xff>
  uart = 1;
80106c3f:	c7 05 c4 c8 10 80 01 	movl   $0x1,0x8010c8c4
80106c46:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c49:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c50:	e8 0f ff ff ff       	call   80106b64 <inb>
  inb(COM1+0);
80106c55:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c5c:	e8 03 ff ff ff       	call   80106b64 <inb>
  ioapicenable(IRQ_COM1, 0);
80106c61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c68:	00 
80106c69:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106c70:	e8 96 be ff ff       	call   80102b0b <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c75:	c7 45 f4 4c 8f 10 80 	movl   $0x80108f4c,-0xc(%ebp)
80106c7c:	eb 13                	jmp    80106c91 <uartinit+0xf6>
    uartputc(*p);
80106c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c81:	8a 00                	mov    (%eax),%al
80106c83:	0f be c0             	movsbl %al,%eax
80106c86:	89 04 24             	mov    %eax,(%esp)
80106c89:	e8 0e 00 00 00       	call   80106c9c <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c8e:	ff 45 f4             	incl   -0xc(%ebp)
80106c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c94:	8a 00                	mov    (%eax),%al
80106c96:	84 c0                	test   %al,%al
80106c98:	75 e4                	jne    80106c7e <uartinit+0xe3>
    uartputc(*p);
}
80106c9a:	c9                   	leave  
80106c9b:	c3                   	ret    

80106c9c <uartputc>:

void
uartputc(int c)
{
80106c9c:	55                   	push   %ebp
80106c9d:	89 e5                	mov    %esp,%ebp
80106c9f:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106ca2:	a1 c4 c8 10 80       	mov    0x8010c8c4,%eax
80106ca7:	85 c0                	test   %eax,%eax
80106ca9:	75 02                	jne    80106cad <uartputc+0x11>
    return;
80106cab:	eb 4a                	jmp    80106cf7 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106cb4:	eb 0f                	jmp    80106cc5 <uartputc+0x29>
    microdelay(10);
80106cb6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106cbd:	e8 7a c3 ff ff       	call   8010303c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cc2:	ff 45 f4             	incl   -0xc(%ebp)
80106cc5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106cc9:	7f 16                	jg     80106ce1 <uartputc+0x45>
80106ccb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cd2:	e8 8d fe ff ff       	call   80106b64 <inb>
80106cd7:	0f b6 c0             	movzbl %al,%eax
80106cda:	83 e0 20             	and    $0x20,%eax
80106cdd:	85 c0                	test   %eax,%eax
80106cdf:	74 d5                	je     80106cb6 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce4:	0f b6 c0             	movzbl %al,%eax
80106ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ceb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cf2:	e8 88 fe ff ff       	call   80106b7f <outb>
}
80106cf7:	c9                   	leave  
80106cf8:	c3                   	ret    

80106cf9 <uartgetc>:

static int
uartgetc(void)
{
80106cf9:	55                   	push   %ebp
80106cfa:	89 e5                	mov    %esp,%ebp
80106cfc:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106cff:	a1 c4 c8 10 80       	mov    0x8010c8c4,%eax
80106d04:	85 c0                	test   %eax,%eax
80106d06:	75 07                	jne    80106d0f <uartgetc+0x16>
    return -1;
80106d08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d0d:	eb 2c                	jmp    80106d3b <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106d0f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d16:	e8 49 fe ff ff       	call   80106b64 <inb>
80106d1b:	0f b6 c0             	movzbl %al,%eax
80106d1e:	83 e0 01             	and    $0x1,%eax
80106d21:	85 c0                	test   %eax,%eax
80106d23:	75 07                	jne    80106d2c <uartgetc+0x33>
    return -1;
80106d25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d2a:	eb 0f                	jmp    80106d3b <uartgetc+0x42>
  return inb(COM1+0);
80106d2c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d33:	e8 2c fe ff ff       	call   80106b64 <inb>
80106d38:	0f b6 c0             	movzbl %al,%eax
}
80106d3b:	c9                   	leave  
80106d3c:	c3                   	ret    

80106d3d <uartintr>:

void
uartintr(void)
{
80106d3d:	55                   	push   %ebp
80106d3e:	89 e5                	mov    %esp,%ebp
80106d40:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106d43:	c7 04 24 f9 6c 10 80 	movl   $0x80106cf9,(%esp)
80106d4a:	e8 a6 9a ff ff       	call   801007f5 <consoleintr>
}
80106d4f:	c9                   	leave  
80106d50:	c3                   	ret    
80106d51:	00 00                	add    %al,(%eax)
	...

80106d54 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $0
80106d56:	6a 00                	push   $0x0
  jmp alltraps
80106d58:	e9 af f9 ff ff       	jmp    8010670c <alltraps>

80106d5d <vector1>:
.globl vector1
vector1:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $1
80106d5f:	6a 01                	push   $0x1
  jmp alltraps
80106d61:	e9 a6 f9 ff ff       	jmp    8010670c <alltraps>

80106d66 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $2
80106d68:	6a 02                	push   $0x2
  jmp alltraps
80106d6a:	e9 9d f9 ff ff       	jmp    8010670c <alltraps>

80106d6f <vector3>:
.globl vector3
vector3:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $3
80106d71:	6a 03                	push   $0x3
  jmp alltraps
80106d73:	e9 94 f9 ff ff       	jmp    8010670c <alltraps>

80106d78 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $4
80106d7a:	6a 04                	push   $0x4
  jmp alltraps
80106d7c:	e9 8b f9 ff ff       	jmp    8010670c <alltraps>

80106d81 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $5
80106d83:	6a 05                	push   $0x5
  jmp alltraps
80106d85:	e9 82 f9 ff ff       	jmp    8010670c <alltraps>

80106d8a <vector6>:
.globl vector6
vector6:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $6
80106d8c:	6a 06                	push   $0x6
  jmp alltraps
80106d8e:	e9 79 f9 ff ff       	jmp    8010670c <alltraps>

80106d93 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $7
80106d95:	6a 07                	push   $0x7
  jmp alltraps
80106d97:	e9 70 f9 ff ff       	jmp    8010670c <alltraps>

80106d9c <vector8>:
.globl vector8
vector8:
  pushl $8
80106d9c:	6a 08                	push   $0x8
  jmp alltraps
80106d9e:	e9 69 f9 ff ff       	jmp    8010670c <alltraps>

80106da3 <vector9>:
.globl vector9
vector9:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $9
80106da5:	6a 09                	push   $0x9
  jmp alltraps
80106da7:	e9 60 f9 ff ff       	jmp    8010670c <alltraps>

80106dac <vector10>:
.globl vector10
vector10:
  pushl $10
80106dac:	6a 0a                	push   $0xa
  jmp alltraps
80106dae:	e9 59 f9 ff ff       	jmp    8010670c <alltraps>

80106db3 <vector11>:
.globl vector11
vector11:
  pushl $11
80106db3:	6a 0b                	push   $0xb
  jmp alltraps
80106db5:	e9 52 f9 ff ff       	jmp    8010670c <alltraps>

80106dba <vector12>:
.globl vector12
vector12:
  pushl $12
80106dba:	6a 0c                	push   $0xc
  jmp alltraps
80106dbc:	e9 4b f9 ff ff       	jmp    8010670c <alltraps>

80106dc1 <vector13>:
.globl vector13
vector13:
  pushl $13
80106dc1:	6a 0d                	push   $0xd
  jmp alltraps
80106dc3:	e9 44 f9 ff ff       	jmp    8010670c <alltraps>

80106dc8 <vector14>:
.globl vector14
vector14:
  pushl $14
80106dc8:	6a 0e                	push   $0xe
  jmp alltraps
80106dca:	e9 3d f9 ff ff       	jmp    8010670c <alltraps>

80106dcf <vector15>:
.globl vector15
vector15:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $15
80106dd1:	6a 0f                	push   $0xf
  jmp alltraps
80106dd3:	e9 34 f9 ff ff       	jmp    8010670c <alltraps>

80106dd8 <vector16>:
.globl vector16
vector16:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $16
80106dda:	6a 10                	push   $0x10
  jmp alltraps
80106ddc:	e9 2b f9 ff ff       	jmp    8010670c <alltraps>

80106de1 <vector17>:
.globl vector17
vector17:
  pushl $17
80106de1:	6a 11                	push   $0x11
  jmp alltraps
80106de3:	e9 24 f9 ff ff       	jmp    8010670c <alltraps>

80106de8 <vector18>:
.globl vector18
vector18:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $18
80106dea:	6a 12                	push   $0x12
  jmp alltraps
80106dec:	e9 1b f9 ff ff       	jmp    8010670c <alltraps>

80106df1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $19
80106df3:	6a 13                	push   $0x13
  jmp alltraps
80106df5:	e9 12 f9 ff ff       	jmp    8010670c <alltraps>

80106dfa <vector20>:
.globl vector20
vector20:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $20
80106dfc:	6a 14                	push   $0x14
  jmp alltraps
80106dfe:	e9 09 f9 ff ff       	jmp    8010670c <alltraps>

80106e03 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $21
80106e05:	6a 15                	push   $0x15
  jmp alltraps
80106e07:	e9 00 f9 ff ff       	jmp    8010670c <alltraps>

80106e0c <vector22>:
.globl vector22
vector22:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $22
80106e0e:	6a 16                	push   $0x16
  jmp alltraps
80106e10:	e9 f7 f8 ff ff       	jmp    8010670c <alltraps>

80106e15 <vector23>:
.globl vector23
vector23:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $23
80106e17:	6a 17                	push   $0x17
  jmp alltraps
80106e19:	e9 ee f8 ff ff       	jmp    8010670c <alltraps>

80106e1e <vector24>:
.globl vector24
vector24:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $24
80106e20:	6a 18                	push   $0x18
  jmp alltraps
80106e22:	e9 e5 f8 ff ff       	jmp    8010670c <alltraps>

80106e27 <vector25>:
.globl vector25
vector25:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $25
80106e29:	6a 19                	push   $0x19
  jmp alltraps
80106e2b:	e9 dc f8 ff ff       	jmp    8010670c <alltraps>

80106e30 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $26
80106e32:	6a 1a                	push   $0x1a
  jmp alltraps
80106e34:	e9 d3 f8 ff ff       	jmp    8010670c <alltraps>

80106e39 <vector27>:
.globl vector27
vector27:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $27
80106e3b:	6a 1b                	push   $0x1b
  jmp alltraps
80106e3d:	e9 ca f8 ff ff       	jmp    8010670c <alltraps>

80106e42 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $28
80106e44:	6a 1c                	push   $0x1c
  jmp alltraps
80106e46:	e9 c1 f8 ff ff       	jmp    8010670c <alltraps>

80106e4b <vector29>:
.globl vector29
vector29:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $29
80106e4d:	6a 1d                	push   $0x1d
  jmp alltraps
80106e4f:	e9 b8 f8 ff ff       	jmp    8010670c <alltraps>

80106e54 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $30
80106e56:	6a 1e                	push   $0x1e
  jmp alltraps
80106e58:	e9 af f8 ff ff       	jmp    8010670c <alltraps>

80106e5d <vector31>:
.globl vector31
vector31:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $31
80106e5f:	6a 1f                	push   $0x1f
  jmp alltraps
80106e61:	e9 a6 f8 ff ff       	jmp    8010670c <alltraps>

80106e66 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $32
80106e68:	6a 20                	push   $0x20
  jmp alltraps
80106e6a:	e9 9d f8 ff ff       	jmp    8010670c <alltraps>

80106e6f <vector33>:
.globl vector33
vector33:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $33
80106e71:	6a 21                	push   $0x21
  jmp alltraps
80106e73:	e9 94 f8 ff ff       	jmp    8010670c <alltraps>

80106e78 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $34
80106e7a:	6a 22                	push   $0x22
  jmp alltraps
80106e7c:	e9 8b f8 ff ff       	jmp    8010670c <alltraps>

80106e81 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $35
80106e83:	6a 23                	push   $0x23
  jmp alltraps
80106e85:	e9 82 f8 ff ff       	jmp    8010670c <alltraps>

80106e8a <vector36>:
.globl vector36
vector36:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $36
80106e8c:	6a 24                	push   $0x24
  jmp alltraps
80106e8e:	e9 79 f8 ff ff       	jmp    8010670c <alltraps>

80106e93 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $37
80106e95:	6a 25                	push   $0x25
  jmp alltraps
80106e97:	e9 70 f8 ff ff       	jmp    8010670c <alltraps>

80106e9c <vector38>:
.globl vector38
vector38:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $38
80106e9e:	6a 26                	push   $0x26
  jmp alltraps
80106ea0:	e9 67 f8 ff ff       	jmp    8010670c <alltraps>

80106ea5 <vector39>:
.globl vector39
vector39:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $39
80106ea7:	6a 27                	push   $0x27
  jmp alltraps
80106ea9:	e9 5e f8 ff ff       	jmp    8010670c <alltraps>

80106eae <vector40>:
.globl vector40
vector40:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $40
80106eb0:	6a 28                	push   $0x28
  jmp alltraps
80106eb2:	e9 55 f8 ff ff       	jmp    8010670c <alltraps>

80106eb7 <vector41>:
.globl vector41
vector41:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $41
80106eb9:	6a 29                	push   $0x29
  jmp alltraps
80106ebb:	e9 4c f8 ff ff       	jmp    8010670c <alltraps>

80106ec0 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $42
80106ec2:	6a 2a                	push   $0x2a
  jmp alltraps
80106ec4:	e9 43 f8 ff ff       	jmp    8010670c <alltraps>

80106ec9 <vector43>:
.globl vector43
vector43:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $43
80106ecb:	6a 2b                	push   $0x2b
  jmp alltraps
80106ecd:	e9 3a f8 ff ff       	jmp    8010670c <alltraps>

80106ed2 <vector44>:
.globl vector44
vector44:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $44
80106ed4:	6a 2c                	push   $0x2c
  jmp alltraps
80106ed6:	e9 31 f8 ff ff       	jmp    8010670c <alltraps>

80106edb <vector45>:
.globl vector45
vector45:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $45
80106edd:	6a 2d                	push   $0x2d
  jmp alltraps
80106edf:	e9 28 f8 ff ff       	jmp    8010670c <alltraps>

80106ee4 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $46
80106ee6:	6a 2e                	push   $0x2e
  jmp alltraps
80106ee8:	e9 1f f8 ff ff       	jmp    8010670c <alltraps>

80106eed <vector47>:
.globl vector47
vector47:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $47
80106eef:	6a 2f                	push   $0x2f
  jmp alltraps
80106ef1:	e9 16 f8 ff ff       	jmp    8010670c <alltraps>

80106ef6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $48
80106ef8:	6a 30                	push   $0x30
  jmp alltraps
80106efa:	e9 0d f8 ff ff       	jmp    8010670c <alltraps>

80106eff <vector49>:
.globl vector49
vector49:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $49
80106f01:	6a 31                	push   $0x31
  jmp alltraps
80106f03:	e9 04 f8 ff ff       	jmp    8010670c <alltraps>

80106f08 <vector50>:
.globl vector50
vector50:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $50
80106f0a:	6a 32                	push   $0x32
  jmp alltraps
80106f0c:	e9 fb f7 ff ff       	jmp    8010670c <alltraps>

80106f11 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $51
80106f13:	6a 33                	push   $0x33
  jmp alltraps
80106f15:	e9 f2 f7 ff ff       	jmp    8010670c <alltraps>

80106f1a <vector52>:
.globl vector52
vector52:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $52
80106f1c:	6a 34                	push   $0x34
  jmp alltraps
80106f1e:	e9 e9 f7 ff ff       	jmp    8010670c <alltraps>

80106f23 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $53
80106f25:	6a 35                	push   $0x35
  jmp alltraps
80106f27:	e9 e0 f7 ff ff       	jmp    8010670c <alltraps>

80106f2c <vector54>:
.globl vector54
vector54:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $54
80106f2e:	6a 36                	push   $0x36
  jmp alltraps
80106f30:	e9 d7 f7 ff ff       	jmp    8010670c <alltraps>

80106f35 <vector55>:
.globl vector55
vector55:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $55
80106f37:	6a 37                	push   $0x37
  jmp alltraps
80106f39:	e9 ce f7 ff ff       	jmp    8010670c <alltraps>

80106f3e <vector56>:
.globl vector56
vector56:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $56
80106f40:	6a 38                	push   $0x38
  jmp alltraps
80106f42:	e9 c5 f7 ff ff       	jmp    8010670c <alltraps>

80106f47 <vector57>:
.globl vector57
vector57:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $57
80106f49:	6a 39                	push   $0x39
  jmp alltraps
80106f4b:	e9 bc f7 ff ff       	jmp    8010670c <alltraps>

80106f50 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $58
80106f52:	6a 3a                	push   $0x3a
  jmp alltraps
80106f54:	e9 b3 f7 ff ff       	jmp    8010670c <alltraps>

80106f59 <vector59>:
.globl vector59
vector59:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $59
80106f5b:	6a 3b                	push   $0x3b
  jmp alltraps
80106f5d:	e9 aa f7 ff ff       	jmp    8010670c <alltraps>

80106f62 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $60
80106f64:	6a 3c                	push   $0x3c
  jmp alltraps
80106f66:	e9 a1 f7 ff ff       	jmp    8010670c <alltraps>

80106f6b <vector61>:
.globl vector61
vector61:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $61
80106f6d:	6a 3d                	push   $0x3d
  jmp alltraps
80106f6f:	e9 98 f7 ff ff       	jmp    8010670c <alltraps>

80106f74 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $62
80106f76:	6a 3e                	push   $0x3e
  jmp alltraps
80106f78:	e9 8f f7 ff ff       	jmp    8010670c <alltraps>

80106f7d <vector63>:
.globl vector63
vector63:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $63
80106f7f:	6a 3f                	push   $0x3f
  jmp alltraps
80106f81:	e9 86 f7 ff ff       	jmp    8010670c <alltraps>

80106f86 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $64
80106f88:	6a 40                	push   $0x40
  jmp alltraps
80106f8a:	e9 7d f7 ff ff       	jmp    8010670c <alltraps>

80106f8f <vector65>:
.globl vector65
vector65:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $65
80106f91:	6a 41                	push   $0x41
  jmp alltraps
80106f93:	e9 74 f7 ff ff       	jmp    8010670c <alltraps>

80106f98 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f98:	6a 00                	push   $0x0
  pushl $66
80106f9a:	6a 42                	push   $0x42
  jmp alltraps
80106f9c:	e9 6b f7 ff ff       	jmp    8010670c <alltraps>

80106fa1 <vector67>:
.globl vector67
vector67:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $67
80106fa3:	6a 43                	push   $0x43
  jmp alltraps
80106fa5:	e9 62 f7 ff ff       	jmp    8010670c <alltraps>

80106faa <vector68>:
.globl vector68
vector68:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $68
80106fac:	6a 44                	push   $0x44
  jmp alltraps
80106fae:	e9 59 f7 ff ff       	jmp    8010670c <alltraps>

80106fb3 <vector69>:
.globl vector69
vector69:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $69
80106fb5:	6a 45                	push   $0x45
  jmp alltraps
80106fb7:	e9 50 f7 ff ff       	jmp    8010670c <alltraps>

80106fbc <vector70>:
.globl vector70
vector70:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $70
80106fbe:	6a 46                	push   $0x46
  jmp alltraps
80106fc0:	e9 47 f7 ff ff       	jmp    8010670c <alltraps>

80106fc5 <vector71>:
.globl vector71
vector71:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $71
80106fc7:	6a 47                	push   $0x47
  jmp alltraps
80106fc9:	e9 3e f7 ff ff       	jmp    8010670c <alltraps>

80106fce <vector72>:
.globl vector72
vector72:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $72
80106fd0:	6a 48                	push   $0x48
  jmp alltraps
80106fd2:	e9 35 f7 ff ff       	jmp    8010670c <alltraps>

80106fd7 <vector73>:
.globl vector73
vector73:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $73
80106fd9:	6a 49                	push   $0x49
  jmp alltraps
80106fdb:	e9 2c f7 ff ff       	jmp    8010670c <alltraps>

80106fe0 <vector74>:
.globl vector74
vector74:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $74
80106fe2:	6a 4a                	push   $0x4a
  jmp alltraps
80106fe4:	e9 23 f7 ff ff       	jmp    8010670c <alltraps>

80106fe9 <vector75>:
.globl vector75
vector75:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $75
80106feb:	6a 4b                	push   $0x4b
  jmp alltraps
80106fed:	e9 1a f7 ff ff       	jmp    8010670c <alltraps>

80106ff2 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $76
80106ff4:	6a 4c                	push   $0x4c
  jmp alltraps
80106ff6:	e9 11 f7 ff ff       	jmp    8010670c <alltraps>

80106ffb <vector77>:
.globl vector77
vector77:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $77
80106ffd:	6a 4d                	push   $0x4d
  jmp alltraps
80106fff:	e9 08 f7 ff ff       	jmp    8010670c <alltraps>

80107004 <vector78>:
.globl vector78
vector78:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $78
80107006:	6a 4e                	push   $0x4e
  jmp alltraps
80107008:	e9 ff f6 ff ff       	jmp    8010670c <alltraps>

8010700d <vector79>:
.globl vector79
vector79:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $79
8010700f:	6a 4f                	push   $0x4f
  jmp alltraps
80107011:	e9 f6 f6 ff ff       	jmp    8010670c <alltraps>

80107016 <vector80>:
.globl vector80
vector80:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $80
80107018:	6a 50                	push   $0x50
  jmp alltraps
8010701a:	e9 ed f6 ff ff       	jmp    8010670c <alltraps>

8010701f <vector81>:
.globl vector81
vector81:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $81
80107021:	6a 51                	push   $0x51
  jmp alltraps
80107023:	e9 e4 f6 ff ff       	jmp    8010670c <alltraps>

80107028 <vector82>:
.globl vector82
vector82:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $82
8010702a:	6a 52                	push   $0x52
  jmp alltraps
8010702c:	e9 db f6 ff ff       	jmp    8010670c <alltraps>

80107031 <vector83>:
.globl vector83
vector83:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $83
80107033:	6a 53                	push   $0x53
  jmp alltraps
80107035:	e9 d2 f6 ff ff       	jmp    8010670c <alltraps>

8010703a <vector84>:
.globl vector84
vector84:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $84
8010703c:	6a 54                	push   $0x54
  jmp alltraps
8010703e:	e9 c9 f6 ff ff       	jmp    8010670c <alltraps>

80107043 <vector85>:
.globl vector85
vector85:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $85
80107045:	6a 55                	push   $0x55
  jmp alltraps
80107047:	e9 c0 f6 ff ff       	jmp    8010670c <alltraps>

8010704c <vector86>:
.globl vector86
vector86:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $86
8010704e:	6a 56                	push   $0x56
  jmp alltraps
80107050:	e9 b7 f6 ff ff       	jmp    8010670c <alltraps>

80107055 <vector87>:
.globl vector87
vector87:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $87
80107057:	6a 57                	push   $0x57
  jmp alltraps
80107059:	e9 ae f6 ff ff       	jmp    8010670c <alltraps>

8010705e <vector88>:
.globl vector88
vector88:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $88
80107060:	6a 58                	push   $0x58
  jmp alltraps
80107062:	e9 a5 f6 ff ff       	jmp    8010670c <alltraps>

80107067 <vector89>:
.globl vector89
vector89:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $89
80107069:	6a 59                	push   $0x59
  jmp alltraps
8010706b:	e9 9c f6 ff ff       	jmp    8010670c <alltraps>

80107070 <vector90>:
.globl vector90
vector90:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $90
80107072:	6a 5a                	push   $0x5a
  jmp alltraps
80107074:	e9 93 f6 ff ff       	jmp    8010670c <alltraps>

80107079 <vector91>:
.globl vector91
vector91:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $91
8010707b:	6a 5b                	push   $0x5b
  jmp alltraps
8010707d:	e9 8a f6 ff ff       	jmp    8010670c <alltraps>

80107082 <vector92>:
.globl vector92
vector92:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $92
80107084:	6a 5c                	push   $0x5c
  jmp alltraps
80107086:	e9 81 f6 ff ff       	jmp    8010670c <alltraps>

8010708b <vector93>:
.globl vector93
vector93:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $93
8010708d:	6a 5d                	push   $0x5d
  jmp alltraps
8010708f:	e9 78 f6 ff ff       	jmp    8010670c <alltraps>

80107094 <vector94>:
.globl vector94
vector94:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $94
80107096:	6a 5e                	push   $0x5e
  jmp alltraps
80107098:	e9 6f f6 ff ff       	jmp    8010670c <alltraps>

8010709d <vector95>:
.globl vector95
vector95:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $95
8010709f:	6a 5f                	push   $0x5f
  jmp alltraps
801070a1:	e9 66 f6 ff ff       	jmp    8010670c <alltraps>

801070a6 <vector96>:
.globl vector96
vector96:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $96
801070a8:	6a 60                	push   $0x60
  jmp alltraps
801070aa:	e9 5d f6 ff ff       	jmp    8010670c <alltraps>

801070af <vector97>:
.globl vector97
vector97:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $97
801070b1:	6a 61                	push   $0x61
  jmp alltraps
801070b3:	e9 54 f6 ff ff       	jmp    8010670c <alltraps>

801070b8 <vector98>:
.globl vector98
vector98:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $98
801070ba:	6a 62                	push   $0x62
  jmp alltraps
801070bc:	e9 4b f6 ff ff       	jmp    8010670c <alltraps>

801070c1 <vector99>:
.globl vector99
vector99:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $99
801070c3:	6a 63                	push   $0x63
  jmp alltraps
801070c5:	e9 42 f6 ff ff       	jmp    8010670c <alltraps>

801070ca <vector100>:
.globl vector100
vector100:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $100
801070cc:	6a 64                	push   $0x64
  jmp alltraps
801070ce:	e9 39 f6 ff ff       	jmp    8010670c <alltraps>

801070d3 <vector101>:
.globl vector101
vector101:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $101
801070d5:	6a 65                	push   $0x65
  jmp alltraps
801070d7:	e9 30 f6 ff ff       	jmp    8010670c <alltraps>

801070dc <vector102>:
.globl vector102
vector102:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $102
801070de:	6a 66                	push   $0x66
  jmp alltraps
801070e0:	e9 27 f6 ff ff       	jmp    8010670c <alltraps>

801070e5 <vector103>:
.globl vector103
vector103:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $103
801070e7:	6a 67                	push   $0x67
  jmp alltraps
801070e9:	e9 1e f6 ff ff       	jmp    8010670c <alltraps>

801070ee <vector104>:
.globl vector104
vector104:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $104
801070f0:	6a 68                	push   $0x68
  jmp alltraps
801070f2:	e9 15 f6 ff ff       	jmp    8010670c <alltraps>

801070f7 <vector105>:
.globl vector105
vector105:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $105
801070f9:	6a 69                	push   $0x69
  jmp alltraps
801070fb:	e9 0c f6 ff ff       	jmp    8010670c <alltraps>

80107100 <vector106>:
.globl vector106
vector106:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $106
80107102:	6a 6a                	push   $0x6a
  jmp alltraps
80107104:	e9 03 f6 ff ff       	jmp    8010670c <alltraps>

80107109 <vector107>:
.globl vector107
vector107:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $107
8010710b:	6a 6b                	push   $0x6b
  jmp alltraps
8010710d:	e9 fa f5 ff ff       	jmp    8010670c <alltraps>

80107112 <vector108>:
.globl vector108
vector108:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $108
80107114:	6a 6c                	push   $0x6c
  jmp alltraps
80107116:	e9 f1 f5 ff ff       	jmp    8010670c <alltraps>

8010711b <vector109>:
.globl vector109
vector109:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $109
8010711d:	6a 6d                	push   $0x6d
  jmp alltraps
8010711f:	e9 e8 f5 ff ff       	jmp    8010670c <alltraps>

80107124 <vector110>:
.globl vector110
vector110:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $110
80107126:	6a 6e                	push   $0x6e
  jmp alltraps
80107128:	e9 df f5 ff ff       	jmp    8010670c <alltraps>

8010712d <vector111>:
.globl vector111
vector111:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $111
8010712f:	6a 6f                	push   $0x6f
  jmp alltraps
80107131:	e9 d6 f5 ff ff       	jmp    8010670c <alltraps>

80107136 <vector112>:
.globl vector112
vector112:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $112
80107138:	6a 70                	push   $0x70
  jmp alltraps
8010713a:	e9 cd f5 ff ff       	jmp    8010670c <alltraps>

8010713f <vector113>:
.globl vector113
vector113:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $113
80107141:	6a 71                	push   $0x71
  jmp alltraps
80107143:	e9 c4 f5 ff ff       	jmp    8010670c <alltraps>

80107148 <vector114>:
.globl vector114
vector114:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $114
8010714a:	6a 72                	push   $0x72
  jmp alltraps
8010714c:	e9 bb f5 ff ff       	jmp    8010670c <alltraps>

80107151 <vector115>:
.globl vector115
vector115:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $115
80107153:	6a 73                	push   $0x73
  jmp alltraps
80107155:	e9 b2 f5 ff ff       	jmp    8010670c <alltraps>

8010715a <vector116>:
.globl vector116
vector116:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $116
8010715c:	6a 74                	push   $0x74
  jmp alltraps
8010715e:	e9 a9 f5 ff ff       	jmp    8010670c <alltraps>

80107163 <vector117>:
.globl vector117
vector117:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $117
80107165:	6a 75                	push   $0x75
  jmp alltraps
80107167:	e9 a0 f5 ff ff       	jmp    8010670c <alltraps>

8010716c <vector118>:
.globl vector118
vector118:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $118
8010716e:	6a 76                	push   $0x76
  jmp alltraps
80107170:	e9 97 f5 ff ff       	jmp    8010670c <alltraps>

80107175 <vector119>:
.globl vector119
vector119:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $119
80107177:	6a 77                	push   $0x77
  jmp alltraps
80107179:	e9 8e f5 ff ff       	jmp    8010670c <alltraps>

8010717e <vector120>:
.globl vector120
vector120:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $120
80107180:	6a 78                	push   $0x78
  jmp alltraps
80107182:	e9 85 f5 ff ff       	jmp    8010670c <alltraps>

80107187 <vector121>:
.globl vector121
vector121:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $121
80107189:	6a 79                	push   $0x79
  jmp alltraps
8010718b:	e9 7c f5 ff ff       	jmp    8010670c <alltraps>

80107190 <vector122>:
.globl vector122
vector122:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $122
80107192:	6a 7a                	push   $0x7a
  jmp alltraps
80107194:	e9 73 f5 ff ff       	jmp    8010670c <alltraps>

80107199 <vector123>:
.globl vector123
vector123:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $123
8010719b:	6a 7b                	push   $0x7b
  jmp alltraps
8010719d:	e9 6a f5 ff ff       	jmp    8010670c <alltraps>

801071a2 <vector124>:
.globl vector124
vector124:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $124
801071a4:	6a 7c                	push   $0x7c
  jmp alltraps
801071a6:	e9 61 f5 ff ff       	jmp    8010670c <alltraps>

801071ab <vector125>:
.globl vector125
vector125:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $125
801071ad:	6a 7d                	push   $0x7d
  jmp alltraps
801071af:	e9 58 f5 ff ff       	jmp    8010670c <alltraps>

801071b4 <vector126>:
.globl vector126
vector126:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $126
801071b6:	6a 7e                	push   $0x7e
  jmp alltraps
801071b8:	e9 4f f5 ff ff       	jmp    8010670c <alltraps>

801071bd <vector127>:
.globl vector127
vector127:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $127
801071bf:	6a 7f                	push   $0x7f
  jmp alltraps
801071c1:	e9 46 f5 ff ff       	jmp    8010670c <alltraps>

801071c6 <vector128>:
.globl vector128
vector128:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $128
801071c8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071cd:	e9 3a f5 ff ff       	jmp    8010670c <alltraps>

801071d2 <vector129>:
.globl vector129
vector129:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $129
801071d4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071d9:	e9 2e f5 ff ff       	jmp    8010670c <alltraps>

801071de <vector130>:
.globl vector130
vector130:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $130
801071e0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801071e5:	e9 22 f5 ff ff       	jmp    8010670c <alltraps>

801071ea <vector131>:
.globl vector131
vector131:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $131
801071ec:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071f1:	e9 16 f5 ff ff       	jmp    8010670c <alltraps>

801071f6 <vector132>:
.globl vector132
vector132:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $132
801071f8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071fd:	e9 0a f5 ff ff       	jmp    8010670c <alltraps>

80107202 <vector133>:
.globl vector133
vector133:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $133
80107204:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107209:	e9 fe f4 ff ff       	jmp    8010670c <alltraps>

8010720e <vector134>:
.globl vector134
vector134:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $134
80107210:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107215:	e9 f2 f4 ff ff       	jmp    8010670c <alltraps>

8010721a <vector135>:
.globl vector135
vector135:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $135
8010721c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107221:	e9 e6 f4 ff ff       	jmp    8010670c <alltraps>

80107226 <vector136>:
.globl vector136
vector136:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $136
80107228:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010722d:	e9 da f4 ff ff       	jmp    8010670c <alltraps>

80107232 <vector137>:
.globl vector137
vector137:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $137
80107234:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107239:	e9 ce f4 ff ff       	jmp    8010670c <alltraps>

8010723e <vector138>:
.globl vector138
vector138:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $138
80107240:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107245:	e9 c2 f4 ff ff       	jmp    8010670c <alltraps>

8010724a <vector139>:
.globl vector139
vector139:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $139
8010724c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107251:	e9 b6 f4 ff ff       	jmp    8010670c <alltraps>

80107256 <vector140>:
.globl vector140
vector140:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $140
80107258:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010725d:	e9 aa f4 ff ff       	jmp    8010670c <alltraps>

80107262 <vector141>:
.globl vector141
vector141:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $141
80107264:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107269:	e9 9e f4 ff ff       	jmp    8010670c <alltraps>

8010726e <vector142>:
.globl vector142
vector142:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $142
80107270:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107275:	e9 92 f4 ff ff       	jmp    8010670c <alltraps>

8010727a <vector143>:
.globl vector143
vector143:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $143
8010727c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107281:	e9 86 f4 ff ff       	jmp    8010670c <alltraps>

80107286 <vector144>:
.globl vector144
vector144:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $144
80107288:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010728d:	e9 7a f4 ff ff       	jmp    8010670c <alltraps>

80107292 <vector145>:
.globl vector145
vector145:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $145
80107294:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107299:	e9 6e f4 ff ff       	jmp    8010670c <alltraps>

8010729e <vector146>:
.globl vector146
vector146:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $146
801072a0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072a5:	e9 62 f4 ff ff       	jmp    8010670c <alltraps>

801072aa <vector147>:
.globl vector147
vector147:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $147
801072ac:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072b1:	e9 56 f4 ff ff       	jmp    8010670c <alltraps>

801072b6 <vector148>:
.globl vector148
vector148:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $148
801072b8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072bd:	e9 4a f4 ff ff       	jmp    8010670c <alltraps>

801072c2 <vector149>:
.globl vector149
vector149:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $149
801072c4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072c9:	e9 3e f4 ff ff       	jmp    8010670c <alltraps>

801072ce <vector150>:
.globl vector150
vector150:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $150
801072d0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072d5:	e9 32 f4 ff ff       	jmp    8010670c <alltraps>

801072da <vector151>:
.globl vector151
vector151:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $151
801072dc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801072e1:	e9 26 f4 ff ff       	jmp    8010670c <alltraps>

801072e6 <vector152>:
.globl vector152
vector152:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $152
801072e8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072ed:	e9 1a f4 ff ff       	jmp    8010670c <alltraps>

801072f2 <vector153>:
.globl vector153
vector153:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $153
801072f4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072f9:	e9 0e f4 ff ff       	jmp    8010670c <alltraps>

801072fe <vector154>:
.globl vector154
vector154:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $154
80107300:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107305:	e9 02 f4 ff ff       	jmp    8010670c <alltraps>

8010730a <vector155>:
.globl vector155
vector155:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $155
8010730c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107311:	e9 f6 f3 ff ff       	jmp    8010670c <alltraps>

80107316 <vector156>:
.globl vector156
vector156:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $156
80107318:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010731d:	e9 ea f3 ff ff       	jmp    8010670c <alltraps>

80107322 <vector157>:
.globl vector157
vector157:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $157
80107324:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107329:	e9 de f3 ff ff       	jmp    8010670c <alltraps>

8010732e <vector158>:
.globl vector158
vector158:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $158
80107330:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107335:	e9 d2 f3 ff ff       	jmp    8010670c <alltraps>

8010733a <vector159>:
.globl vector159
vector159:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $159
8010733c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107341:	e9 c6 f3 ff ff       	jmp    8010670c <alltraps>

80107346 <vector160>:
.globl vector160
vector160:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $160
80107348:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010734d:	e9 ba f3 ff ff       	jmp    8010670c <alltraps>

80107352 <vector161>:
.globl vector161
vector161:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $161
80107354:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107359:	e9 ae f3 ff ff       	jmp    8010670c <alltraps>

8010735e <vector162>:
.globl vector162
vector162:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $162
80107360:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107365:	e9 a2 f3 ff ff       	jmp    8010670c <alltraps>

8010736a <vector163>:
.globl vector163
vector163:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $163
8010736c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107371:	e9 96 f3 ff ff       	jmp    8010670c <alltraps>

80107376 <vector164>:
.globl vector164
vector164:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $164
80107378:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010737d:	e9 8a f3 ff ff       	jmp    8010670c <alltraps>

80107382 <vector165>:
.globl vector165
vector165:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $165
80107384:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107389:	e9 7e f3 ff ff       	jmp    8010670c <alltraps>

8010738e <vector166>:
.globl vector166
vector166:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $166
80107390:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107395:	e9 72 f3 ff ff       	jmp    8010670c <alltraps>

8010739a <vector167>:
.globl vector167
vector167:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $167
8010739c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073a1:	e9 66 f3 ff ff       	jmp    8010670c <alltraps>

801073a6 <vector168>:
.globl vector168
vector168:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $168
801073a8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073ad:	e9 5a f3 ff ff       	jmp    8010670c <alltraps>

801073b2 <vector169>:
.globl vector169
vector169:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $169
801073b4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073b9:	e9 4e f3 ff ff       	jmp    8010670c <alltraps>

801073be <vector170>:
.globl vector170
vector170:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $170
801073c0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073c5:	e9 42 f3 ff ff       	jmp    8010670c <alltraps>

801073ca <vector171>:
.globl vector171
vector171:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $171
801073cc:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073d1:	e9 36 f3 ff ff       	jmp    8010670c <alltraps>

801073d6 <vector172>:
.globl vector172
vector172:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $172
801073d8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801073dd:	e9 2a f3 ff ff       	jmp    8010670c <alltraps>

801073e2 <vector173>:
.globl vector173
vector173:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $173
801073e4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801073e9:	e9 1e f3 ff ff       	jmp    8010670c <alltraps>

801073ee <vector174>:
.globl vector174
vector174:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $174
801073f0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073f5:	e9 12 f3 ff ff       	jmp    8010670c <alltraps>

801073fa <vector175>:
.globl vector175
vector175:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $175
801073fc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107401:	e9 06 f3 ff ff       	jmp    8010670c <alltraps>

80107406 <vector176>:
.globl vector176
vector176:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $176
80107408:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010740d:	e9 fa f2 ff ff       	jmp    8010670c <alltraps>

80107412 <vector177>:
.globl vector177
vector177:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $177
80107414:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107419:	e9 ee f2 ff ff       	jmp    8010670c <alltraps>

8010741e <vector178>:
.globl vector178
vector178:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $178
80107420:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107425:	e9 e2 f2 ff ff       	jmp    8010670c <alltraps>

8010742a <vector179>:
.globl vector179
vector179:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $179
8010742c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107431:	e9 d6 f2 ff ff       	jmp    8010670c <alltraps>

80107436 <vector180>:
.globl vector180
vector180:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $180
80107438:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010743d:	e9 ca f2 ff ff       	jmp    8010670c <alltraps>

80107442 <vector181>:
.globl vector181
vector181:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $181
80107444:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107449:	e9 be f2 ff ff       	jmp    8010670c <alltraps>

8010744e <vector182>:
.globl vector182
vector182:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $182
80107450:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107455:	e9 b2 f2 ff ff       	jmp    8010670c <alltraps>

8010745a <vector183>:
.globl vector183
vector183:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $183
8010745c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107461:	e9 a6 f2 ff ff       	jmp    8010670c <alltraps>

80107466 <vector184>:
.globl vector184
vector184:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $184
80107468:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010746d:	e9 9a f2 ff ff       	jmp    8010670c <alltraps>

80107472 <vector185>:
.globl vector185
vector185:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $185
80107474:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107479:	e9 8e f2 ff ff       	jmp    8010670c <alltraps>

8010747e <vector186>:
.globl vector186
vector186:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $186
80107480:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107485:	e9 82 f2 ff ff       	jmp    8010670c <alltraps>

8010748a <vector187>:
.globl vector187
vector187:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $187
8010748c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107491:	e9 76 f2 ff ff       	jmp    8010670c <alltraps>

80107496 <vector188>:
.globl vector188
vector188:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $188
80107498:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010749d:	e9 6a f2 ff ff       	jmp    8010670c <alltraps>

801074a2 <vector189>:
.globl vector189
vector189:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $189
801074a4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074a9:	e9 5e f2 ff ff       	jmp    8010670c <alltraps>

801074ae <vector190>:
.globl vector190
vector190:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $190
801074b0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074b5:	e9 52 f2 ff ff       	jmp    8010670c <alltraps>

801074ba <vector191>:
.globl vector191
vector191:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $191
801074bc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074c1:	e9 46 f2 ff ff       	jmp    8010670c <alltraps>

801074c6 <vector192>:
.globl vector192
vector192:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $192
801074c8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074cd:	e9 3a f2 ff ff       	jmp    8010670c <alltraps>

801074d2 <vector193>:
.globl vector193
vector193:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $193
801074d4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074d9:	e9 2e f2 ff ff       	jmp    8010670c <alltraps>

801074de <vector194>:
.globl vector194
vector194:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $194
801074e0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801074e5:	e9 22 f2 ff ff       	jmp    8010670c <alltraps>

801074ea <vector195>:
.globl vector195
vector195:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $195
801074ec:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074f1:	e9 16 f2 ff ff       	jmp    8010670c <alltraps>

801074f6 <vector196>:
.globl vector196
vector196:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $196
801074f8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074fd:	e9 0a f2 ff ff       	jmp    8010670c <alltraps>

80107502 <vector197>:
.globl vector197
vector197:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $197
80107504:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107509:	e9 fe f1 ff ff       	jmp    8010670c <alltraps>

8010750e <vector198>:
.globl vector198
vector198:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $198
80107510:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107515:	e9 f2 f1 ff ff       	jmp    8010670c <alltraps>

8010751a <vector199>:
.globl vector199
vector199:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $199
8010751c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107521:	e9 e6 f1 ff ff       	jmp    8010670c <alltraps>

80107526 <vector200>:
.globl vector200
vector200:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $200
80107528:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010752d:	e9 da f1 ff ff       	jmp    8010670c <alltraps>

80107532 <vector201>:
.globl vector201
vector201:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $201
80107534:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107539:	e9 ce f1 ff ff       	jmp    8010670c <alltraps>

8010753e <vector202>:
.globl vector202
vector202:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $202
80107540:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107545:	e9 c2 f1 ff ff       	jmp    8010670c <alltraps>

8010754a <vector203>:
.globl vector203
vector203:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $203
8010754c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107551:	e9 b6 f1 ff ff       	jmp    8010670c <alltraps>

80107556 <vector204>:
.globl vector204
vector204:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $204
80107558:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010755d:	e9 aa f1 ff ff       	jmp    8010670c <alltraps>

80107562 <vector205>:
.globl vector205
vector205:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $205
80107564:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107569:	e9 9e f1 ff ff       	jmp    8010670c <alltraps>

8010756e <vector206>:
.globl vector206
vector206:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $206
80107570:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107575:	e9 92 f1 ff ff       	jmp    8010670c <alltraps>

8010757a <vector207>:
.globl vector207
vector207:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $207
8010757c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107581:	e9 86 f1 ff ff       	jmp    8010670c <alltraps>

80107586 <vector208>:
.globl vector208
vector208:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $208
80107588:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010758d:	e9 7a f1 ff ff       	jmp    8010670c <alltraps>

80107592 <vector209>:
.globl vector209
vector209:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $209
80107594:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107599:	e9 6e f1 ff ff       	jmp    8010670c <alltraps>

8010759e <vector210>:
.globl vector210
vector210:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $210
801075a0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075a5:	e9 62 f1 ff ff       	jmp    8010670c <alltraps>

801075aa <vector211>:
.globl vector211
vector211:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $211
801075ac:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075b1:	e9 56 f1 ff ff       	jmp    8010670c <alltraps>

801075b6 <vector212>:
.globl vector212
vector212:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $212
801075b8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075bd:	e9 4a f1 ff ff       	jmp    8010670c <alltraps>

801075c2 <vector213>:
.globl vector213
vector213:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $213
801075c4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075c9:	e9 3e f1 ff ff       	jmp    8010670c <alltraps>

801075ce <vector214>:
.globl vector214
vector214:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $214
801075d0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075d5:	e9 32 f1 ff ff       	jmp    8010670c <alltraps>

801075da <vector215>:
.globl vector215
vector215:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $215
801075dc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801075e1:	e9 26 f1 ff ff       	jmp    8010670c <alltraps>

801075e6 <vector216>:
.globl vector216
vector216:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $216
801075e8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075ed:	e9 1a f1 ff ff       	jmp    8010670c <alltraps>

801075f2 <vector217>:
.globl vector217
vector217:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $217
801075f4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075f9:	e9 0e f1 ff ff       	jmp    8010670c <alltraps>

801075fe <vector218>:
.globl vector218
vector218:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $218
80107600:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107605:	e9 02 f1 ff ff       	jmp    8010670c <alltraps>

8010760a <vector219>:
.globl vector219
vector219:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $219
8010760c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107611:	e9 f6 f0 ff ff       	jmp    8010670c <alltraps>

80107616 <vector220>:
.globl vector220
vector220:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $220
80107618:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010761d:	e9 ea f0 ff ff       	jmp    8010670c <alltraps>

80107622 <vector221>:
.globl vector221
vector221:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $221
80107624:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107629:	e9 de f0 ff ff       	jmp    8010670c <alltraps>

8010762e <vector222>:
.globl vector222
vector222:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $222
80107630:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107635:	e9 d2 f0 ff ff       	jmp    8010670c <alltraps>

8010763a <vector223>:
.globl vector223
vector223:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $223
8010763c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107641:	e9 c6 f0 ff ff       	jmp    8010670c <alltraps>

80107646 <vector224>:
.globl vector224
vector224:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $224
80107648:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010764d:	e9 ba f0 ff ff       	jmp    8010670c <alltraps>

80107652 <vector225>:
.globl vector225
vector225:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $225
80107654:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107659:	e9 ae f0 ff ff       	jmp    8010670c <alltraps>

8010765e <vector226>:
.globl vector226
vector226:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $226
80107660:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107665:	e9 a2 f0 ff ff       	jmp    8010670c <alltraps>

8010766a <vector227>:
.globl vector227
vector227:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $227
8010766c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107671:	e9 96 f0 ff ff       	jmp    8010670c <alltraps>

80107676 <vector228>:
.globl vector228
vector228:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $228
80107678:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010767d:	e9 8a f0 ff ff       	jmp    8010670c <alltraps>

80107682 <vector229>:
.globl vector229
vector229:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $229
80107684:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107689:	e9 7e f0 ff ff       	jmp    8010670c <alltraps>

8010768e <vector230>:
.globl vector230
vector230:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $230
80107690:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107695:	e9 72 f0 ff ff       	jmp    8010670c <alltraps>

8010769a <vector231>:
.globl vector231
vector231:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $231
8010769c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076a1:	e9 66 f0 ff ff       	jmp    8010670c <alltraps>

801076a6 <vector232>:
.globl vector232
vector232:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $232
801076a8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076ad:	e9 5a f0 ff ff       	jmp    8010670c <alltraps>

801076b2 <vector233>:
.globl vector233
vector233:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $233
801076b4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076b9:	e9 4e f0 ff ff       	jmp    8010670c <alltraps>

801076be <vector234>:
.globl vector234
vector234:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $234
801076c0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076c5:	e9 42 f0 ff ff       	jmp    8010670c <alltraps>

801076ca <vector235>:
.globl vector235
vector235:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $235
801076cc:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076d1:	e9 36 f0 ff ff       	jmp    8010670c <alltraps>

801076d6 <vector236>:
.globl vector236
vector236:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $236
801076d8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801076dd:	e9 2a f0 ff ff       	jmp    8010670c <alltraps>

801076e2 <vector237>:
.globl vector237
vector237:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $237
801076e4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801076e9:	e9 1e f0 ff ff       	jmp    8010670c <alltraps>

801076ee <vector238>:
.globl vector238
vector238:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $238
801076f0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076f5:	e9 12 f0 ff ff       	jmp    8010670c <alltraps>

801076fa <vector239>:
.globl vector239
vector239:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $239
801076fc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107701:	e9 06 f0 ff ff       	jmp    8010670c <alltraps>

80107706 <vector240>:
.globl vector240
vector240:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $240
80107708:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010770d:	e9 fa ef ff ff       	jmp    8010670c <alltraps>

80107712 <vector241>:
.globl vector241
vector241:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $241
80107714:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107719:	e9 ee ef ff ff       	jmp    8010670c <alltraps>

8010771e <vector242>:
.globl vector242
vector242:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $242
80107720:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107725:	e9 e2 ef ff ff       	jmp    8010670c <alltraps>

8010772a <vector243>:
.globl vector243
vector243:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $243
8010772c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107731:	e9 d6 ef ff ff       	jmp    8010670c <alltraps>

80107736 <vector244>:
.globl vector244
vector244:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $244
80107738:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010773d:	e9 ca ef ff ff       	jmp    8010670c <alltraps>

80107742 <vector245>:
.globl vector245
vector245:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $245
80107744:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107749:	e9 be ef ff ff       	jmp    8010670c <alltraps>

8010774e <vector246>:
.globl vector246
vector246:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $246
80107750:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107755:	e9 b2 ef ff ff       	jmp    8010670c <alltraps>

8010775a <vector247>:
.globl vector247
vector247:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $247
8010775c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107761:	e9 a6 ef ff ff       	jmp    8010670c <alltraps>

80107766 <vector248>:
.globl vector248
vector248:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $248
80107768:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010776d:	e9 9a ef ff ff       	jmp    8010670c <alltraps>

80107772 <vector249>:
.globl vector249
vector249:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $249
80107774:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107779:	e9 8e ef ff ff       	jmp    8010670c <alltraps>

8010777e <vector250>:
.globl vector250
vector250:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $250
80107780:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107785:	e9 82 ef ff ff       	jmp    8010670c <alltraps>

8010778a <vector251>:
.globl vector251
vector251:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $251
8010778c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107791:	e9 76 ef ff ff       	jmp    8010670c <alltraps>

80107796 <vector252>:
.globl vector252
vector252:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $252
80107798:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010779d:	e9 6a ef ff ff       	jmp    8010670c <alltraps>

801077a2 <vector253>:
.globl vector253
vector253:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $253
801077a4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077a9:	e9 5e ef ff ff       	jmp    8010670c <alltraps>

801077ae <vector254>:
.globl vector254
vector254:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $254
801077b0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077b5:	e9 52 ef ff ff       	jmp    8010670c <alltraps>

801077ba <vector255>:
.globl vector255
vector255:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $255
801077bc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077c1:	e9 46 ef ff ff       	jmp    8010670c <alltraps>
	...

801077c8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801077c8:	55                   	push   %ebp
801077c9:	89 e5                	mov    %esp,%ebp
801077cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801077ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801077d1:	48                   	dec    %eax
801077d2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077d6:	8b 45 08             	mov    0x8(%ebp),%eax
801077d9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801077dd:	8b 45 08             	mov    0x8(%ebp),%eax
801077e0:	c1 e8 10             	shr    $0x10,%eax
801077e3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801077e7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801077ea:	0f 01 10             	lgdtl  (%eax)
}
801077ed:	c9                   	leave  
801077ee:	c3                   	ret    

801077ef <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801077ef:	55                   	push   %ebp
801077f0:	89 e5                	mov    %esp,%ebp
801077f2:	83 ec 04             	sub    $0x4,%esp
801077f5:	8b 45 08             	mov    0x8(%ebp),%eax
801077f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801077ff:	0f 00 d8             	ltr    %ax
}
80107802:	c9                   	leave  
80107803:	c3                   	ret    

80107804 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107804:	55                   	push   %ebp
80107805:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107807:	8b 45 08             	mov    0x8(%ebp),%eax
8010780a:	0f 22 d8             	mov    %eax,%cr3
}
8010780d:	5d                   	pop    %ebp
8010780e:	c3                   	ret    

8010780f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010780f:	55                   	push   %ebp
80107810:	89 e5                	mov    %esp,%ebp
80107812:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107815:	e8 54 c9 ff ff       	call   8010416e <cpuid>
8010781a:	89 c2                	mov    %eax,%edx
8010781c:	89 d0                	mov    %edx,%eax
8010781e:	c1 e0 02             	shl    $0x2,%eax
80107821:	01 d0                	add    %edx,%eax
80107823:	01 c0                	add    %eax,%eax
80107825:	01 d0                	add    %edx,%eax
80107827:	c1 e0 04             	shl    $0x4,%eax
8010782a:	05 a0 4a 11 80       	add    $0x80114aa0,%eax
8010782f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107835:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107847:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	8a 50 7d             	mov    0x7d(%eax),%dl
80107851:	83 e2 f0             	and    $0xfffffff0,%edx
80107854:	83 ca 0a             	or     $0xa,%edx
80107857:	88 50 7d             	mov    %dl,0x7d(%eax)
8010785a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785d:	8a 50 7d             	mov    0x7d(%eax),%dl
80107860:	83 ca 10             	or     $0x10,%edx
80107863:	88 50 7d             	mov    %dl,0x7d(%eax)
80107866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107869:	8a 50 7d             	mov    0x7d(%eax),%dl
8010786c:	83 e2 9f             	and    $0xffffff9f,%edx
8010786f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	8a 50 7d             	mov    0x7d(%eax),%dl
80107878:	83 ca 80             	or     $0xffffff80,%edx
8010787b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010787e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107881:	8a 50 7e             	mov    0x7e(%eax),%dl
80107884:	83 ca 0f             	or     $0xf,%edx
80107887:	88 50 7e             	mov    %dl,0x7e(%eax)
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107890:	83 e2 ef             	and    $0xffffffef,%edx
80107893:	88 50 7e             	mov    %dl,0x7e(%eax)
80107896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107899:	8a 50 7e             	mov    0x7e(%eax),%dl
8010789c:	83 e2 df             	and    $0xffffffdf,%edx
8010789f:	88 50 7e             	mov    %dl,0x7e(%eax)
801078a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a5:	8a 50 7e             	mov    0x7e(%eax),%dl
801078a8:	83 ca 40             	or     $0x40,%edx
801078ab:	88 50 7e             	mov    %dl,0x7e(%eax)
801078ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b1:	8a 50 7e             	mov    0x7e(%eax),%dl
801078b4:	83 ca 80             	or     $0xffffff80,%edx
801078b7:	88 50 7e             	mov    %dl,0x7e(%eax)
801078ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078cb:	ff ff 
801078cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078d7:	00 00 
801078d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e6:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801078ec:	83 e2 f0             	and    $0xfffffff0,%edx
801078ef:	83 ca 02             	or     $0x2,%edx
801078f2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fb:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107901:	83 ca 10             	or     $0x10,%edx
80107904:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107913:	83 e2 9f             	and    $0xffffff9f,%edx
80107916:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010791c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107925:	83 ca 80             	or     $0xffffff80,%edx
80107928:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010792e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107931:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107937:	83 ca 0f             	or     $0xf,%edx
8010793a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107943:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107949:	83 e2 ef             	and    $0xffffffef,%edx
8010794c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107955:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010795b:	83 e2 df             	and    $0xffffffdf,%edx
8010795e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010796d:	83 ca 40             	or     $0x40,%edx
80107970:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107979:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010797f:	83 ca 80             	or     $0xffffff80,%edx
80107982:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010799c:	ff ff 
8010799e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a1:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801079a8:	00 00 
801079aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ad:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801079b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b7:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801079bd:	83 e2 f0             	and    $0xfffffff0,%edx
801079c0:	83 ca 0a             	or     $0xa,%edx
801079c3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cc:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801079d2:	83 ca 10             	or     $0x10,%edx
801079d5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801079e4:	83 ca 60             	or     $0x60,%edx
801079e7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f0:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801079f6:	83 ca 80             	or     $0xffffff80,%edx
801079f9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a08:	83 ca 0f             	or     $0xf,%edx
80107a0b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a14:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a1a:	83 e2 ef             	and    $0xffffffef,%edx
80107a1d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a2c:	83 e2 df             	and    $0xffffffdf,%edx
80107a2f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a38:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a3e:	83 ca 40             	or     $0x40,%edx
80107a41:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a50:	83 ca 80             	or     $0xffffff80,%edx
80107a53:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a66:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a6d:	ff ff 
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a79:	00 00 
80107a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107a8e:	83 e2 f0             	and    $0xfffffff0,%edx
80107a91:	83 ca 02             	or     $0x2,%edx
80107a94:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9d:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107aa3:	83 ca 10             	or     $0x10,%edx
80107aa6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaf:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107ab5:	83 ca 60             	or     $0x60,%edx
80107ab8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac1:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107ac7:	83 ca 80             	or     $0xffffff80,%edx
80107aca:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107ad9:	83 ca 0f             	or     $0xf,%edx
80107adc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae5:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107aeb:	83 e2 ef             	and    $0xffffffef,%edx
80107aee:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af7:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107afd:	83 e2 df             	and    $0xffffffdf,%edx
80107b00:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b09:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b0f:	83 ca 40             	or     $0x40,%edx
80107b12:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b21:	83 ca 80             	or     $0xffffff80,%edx
80107b24:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b37:	83 c0 70             	add    $0x70,%eax
80107b3a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107b41:	00 
80107b42:	89 04 24             	mov    %eax,(%esp)
80107b45:	e8 7e fc ff ff       	call   801077c8 <lgdt>
}
80107b4a:	c9                   	leave  
80107b4b:	c3                   	ret    

80107b4c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b4c:	55                   	push   %ebp
80107b4d:	89 e5                	mov    %esp,%ebp
80107b4f:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b52:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b55:	c1 e8 16             	shr    $0x16,%eax
80107b58:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b62:	01 d0                	add    %edx,%eax
80107b64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b6a:	8b 00                	mov    (%eax),%eax
80107b6c:	83 e0 01             	and    $0x1,%eax
80107b6f:	85 c0                	test   %eax,%eax
80107b71:	74 14                	je     80107b87 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b76:	8b 00                	mov    (%eax),%eax
80107b78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b7d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b85:	eb 48                	jmp    80107bcf <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b8b:	74 0e                	je     80107b9b <walkpgdir+0x4f>
80107b8d:	e8 e5 b0 ff ff       	call   80102c77 <kalloc>
80107b92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b99:	75 07                	jne    80107ba2 <walkpgdir+0x56>
      return 0;
80107b9b:	b8 00 00 00 00       	mov    $0x0,%eax
80107ba0:	eb 44                	jmp    80107be6 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ba2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ba9:	00 
80107baa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107bb1:	00 
80107bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb5:	89 04 24             	mov    %eax,(%esp)
80107bb8:	e8 f9 d4 ff ff       	call   801050b6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	05 00 00 00 80       	add    $0x80000000,%eax
80107bc5:	83 c8 07             	or     $0x7,%eax
80107bc8:	89 c2                	mov    %eax,%edx
80107bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bcd:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bd2:	c1 e8 0c             	shr    $0xc,%eax
80107bd5:	25 ff 03 00 00       	and    $0x3ff,%eax
80107bda:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be4:	01 d0                	add    %edx,%eax
}
80107be6:	c9                   	leave  
80107be7:	c3                   	ret    

80107be8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107be8:	55                   	push   %ebp
80107be9:	89 e5                	mov    %esp,%ebp
80107beb:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107bee:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bf1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
80107bfc:	8b 45 10             	mov    0x10(%ebp),%eax
80107bff:	01 d0                	add    %edx,%eax
80107c01:	48                   	dec    %eax
80107c02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c07:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c0a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107c11:	00 
80107c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c15:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c19:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1c:	89 04 24             	mov    %eax,(%esp)
80107c1f:	e8 28 ff ff ff       	call   80107b4c <walkpgdir>
80107c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c27:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c2b:	75 07                	jne    80107c34 <mappages+0x4c>
      return -1;
80107c2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c32:	eb 48                	jmp    80107c7c <mappages+0x94>
    if(*pte & PTE_P)
80107c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c37:	8b 00                	mov    (%eax),%eax
80107c39:	83 e0 01             	and    $0x1,%eax
80107c3c:	85 c0                	test   %eax,%eax
80107c3e:	74 0c                	je     80107c4c <mappages+0x64>
      panic("remap");
80107c40:	c7 04 24 54 8f 10 80 	movl   $0x80108f54,(%esp)
80107c47:	e8 08 89 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107c4c:	8b 45 18             	mov    0x18(%ebp),%eax
80107c4f:	0b 45 14             	or     0x14(%ebp),%eax
80107c52:	83 c8 01             	or     $0x1,%eax
80107c55:	89 c2                	mov    %eax,%edx
80107c57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c5a:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c62:	75 08                	jne    80107c6c <mappages+0x84>
      break;
80107c64:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c65:	b8 00 00 00 00       	mov    $0x0,%eax
80107c6a:	eb 10                	jmp    80107c7c <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107c6c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c73:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107c7a:	eb 8e                	jmp    80107c0a <mappages+0x22>
  return 0;
}
80107c7c:	c9                   	leave  
80107c7d:	c3                   	ret    

80107c7e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c7e:	55                   	push   %ebp
80107c7f:	89 e5                	mov    %esp,%ebp
80107c81:	53                   	push   %ebx
80107c82:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107c85:	e8 ed af ff ff       	call   80102c77 <kalloc>
80107c8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c91:	75 0a                	jne    80107c9d <setupkvm+0x1f>
    return 0;
80107c93:	b8 00 00 00 00       	mov    $0x0,%eax
80107c98:	e9 84 00 00 00       	jmp    80107d21 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107c9d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ca4:	00 
80107ca5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107cac:	00 
80107cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb0:	89 04 24             	mov    %eax,(%esp)
80107cb3:	e8 fe d3 ff ff       	call   801050b6 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cb8:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80107cbf:	eb 54                	jmp    80107d15 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	8b 48 0c             	mov    0xc(%eax),%ecx
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	8b 50 04             	mov    0x4(%eax),%edx
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	8b 58 08             	mov    0x8(%eax),%ebx
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	8b 40 04             	mov    0x4(%eax),%eax
80107cd9:	29 c3                	sub    %eax,%ebx
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	8b 00                	mov    (%eax),%eax
80107ce0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107ce4:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107ce8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107cec:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cf3:	89 04 24             	mov    %eax,(%esp)
80107cf6:	e8 ed fe ff ff       	call   80107be8 <mappages>
80107cfb:	85 c0                	test   %eax,%eax
80107cfd:	79 12                	jns    80107d11 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d02:	89 04 24             	mov    %eax,(%esp)
80107d05:	e8 1a 05 00 00       	call   80108224 <freevm>
      return 0;
80107d0a:	b8 00 00 00 00       	mov    $0x0,%eax
80107d0f:	eb 10                	jmp    80107d21 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d11:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d15:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80107d1c:	72 a3                	jb     80107cc1 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d21:	83 c4 34             	add    $0x34,%esp
80107d24:	5b                   	pop    %ebx
80107d25:	5d                   	pop    %ebp
80107d26:	c3                   	ret    

80107d27 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d27:	55                   	push   %ebp
80107d28:	89 e5                	mov    %esp,%ebp
80107d2a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d2d:	e8 4c ff ff ff       	call   80107c7e <setupkvm>
80107d32:	a3 c4 78 11 80       	mov    %eax,0x801178c4
  switchkvm();
80107d37:	e8 02 00 00 00       	call   80107d3e <switchkvm>
}
80107d3c:	c9                   	leave  
80107d3d:	c3                   	ret    

80107d3e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d3e:	55                   	push   %ebp
80107d3f:	89 e5                	mov    %esp,%ebp
80107d41:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d44:	a1 c4 78 11 80       	mov    0x801178c4,%eax
80107d49:	05 00 00 00 80       	add    $0x80000000,%eax
80107d4e:	89 04 24             	mov    %eax,(%esp)
80107d51:	e8 ae fa ff ff       	call   80107804 <lcr3>
}
80107d56:	c9                   	leave  
80107d57:	c3                   	ret    

80107d58 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d58:	55                   	push   %ebp
80107d59:	89 e5                	mov    %esp,%ebp
80107d5b:	57                   	push   %edi
80107d5c:	56                   	push   %esi
80107d5d:	53                   	push   %ebx
80107d5e:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107d61:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d65:	75 0c                	jne    80107d73 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107d67:	c7 04 24 5a 8f 10 80 	movl   $0x80108f5a,(%esp)
80107d6e:	e8 e1 87 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80107d73:	8b 45 08             	mov    0x8(%ebp),%eax
80107d76:	8b 40 08             	mov    0x8(%eax),%eax
80107d79:	85 c0                	test   %eax,%eax
80107d7b:	75 0c                	jne    80107d89 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107d7d:	c7 04 24 70 8f 10 80 	movl   $0x80108f70,(%esp)
80107d84:	e8 cb 87 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80107d89:	8b 45 08             	mov    0x8(%ebp),%eax
80107d8c:	8b 40 04             	mov    0x4(%eax),%eax
80107d8f:	85 c0                	test   %eax,%eax
80107d91:	75 0c                	jne    80107d9f <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107d93:	c7 04 24 85 8f 10 80 	movl   $0x80108f85,(%esp)
80107d9a:	e8 b5 87 ff ff       	call   80100554 <panic>

  pushcli();
80107d9f:	e8 0e d2 ff ff       	call   80104fb2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107da4:	e8 0a c4 ff ff       	call   801041b3 <mycpu>
80107da9:	89 c3                	mov    %eax,%ebx
80107dab:	e8 03 c4 ff ff       	call   801041b3 <mycpu>
80107db0:	83 c0 08             	add    $0x8,%eax
80107db3:	89 c6                	mov    %eax,%esi
80107db5:	e8 f9 c3 ff ff       	call   801041b3 <mycpu>
80107dba:	83 c0 08             	add    $0x8,%eax
80107dbd:	c1 e8 10             	shr    $0x10,%eax
80107dc0:	89 c7                	mov    %eax,%edi
80107dc2:	e8 ec c3 ff ff       	call   801041b3 <mycpu>
80107dc7:	83 c0 08             	add    $0x8,%eax
80107dca:	c1 e8 18             	shr    $0x18,%eax
80107dcd:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107dd4:	67 00 
80107dd6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107ddd:	89 f9                	mov    %edi,%ecx
80107ddf:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107de5:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107deb:	83 e2 f0             	and    $0xfffffff0,%edx
80107dee:	83 ca 09             	or     $0x9,%edx
80107df1:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107df7:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107dfd:	83 ca 10             	or     $0x10,%edx
80107e00:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e06:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107e0c:	83 e2 9f             	and    $0xffffff9f,%edx
80107e0f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e15:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107e1b:	83 ca 80             	or     $0xffffff80,%edx
80107e1e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e24:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107e2a:	83 e2 f0             	and    $0xfffffff0,%edx
80107e2d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107e33:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107e39:	83 e2 ef             	and    $0xffffffef,%edx
80107e3c:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107e42:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107e48:	83 e2 df             	and    $0xffffffdf,%edx
80107e4b:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107e51:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107e57:	83 ca 40             	or     $0x40,%edx
80107e5a:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107e60:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107e66:	83 e2 7f             	and    $0x7f,%edx
80107e69:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107e6f:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107e75:	e8 39 c3 ff ff       	call   801041b3 <mycpu>
80107e7a:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107e80:	83 e2 ef             	and    $0xffffffef,%edx
80107e83:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107e89:	e8 25 c3 ff ff       	call   801041b3 <mycpu>
80107e8e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107e94:	e8 1a c3 ff ff       	call   801041b3 <mycpu>
80107e99:	8b 55 08             	mov    0x8(%ebp),%edx
80107e9c:	8b 52 08             	mov    0x8(%edx),%edx
80107e9f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107ea5:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107ea8:	e8 06 c3 ff ff       	call   801041b3 <mycpu>
80107ead:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107eb3:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107eba:	e8 30 f9 ff ff       	call   801077ef <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec2:	8b 40 04             	mov    0x4(%eax),%eax
80107ec5:	05 00 00 00 80       	add    $0x80000000,%eax
80107eca:	89 04 24             	mov    %eax,(%esp)
80107ecd:	e8 32 f9 ff ff       	call   80107804 <lcr3>
  popcli();
80107ed2:	e8 25 d1 ff ff       	call   80104ffc <popcli>
}
80107ed7:	83 c4 1c             	add    $0x1c,%esp
80107eda:	5b                   	pop    %ebx
80107edb:	5e                   	pop    %esi
80107edc:	5f                   	pop    %edi
80107edd:	5d                   	pop    %ebp
80107ede:	c3                   	ret    

80107edf <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107edf:	55                   	push   %ebp
80107ee0:	89 e5                	mov    %esp,%ebp
80107ee2:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ee5:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107eec:	76 0c                	jbe    80107efa <inituvm+0x1b>
    panic("inituvm: more than a page");
80107eee:	c7 04 24 99 8f 10 80 	movl   $0x80108f99,(%esp)
80107ef5:	e8 5a 86 ff ff       	call   80100554 <panic>
  mem = kalloc();
80107efa:	e8 78 ad ff ff       	call   80102c77 <kalloc>
80107eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f02:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f09:	00 
80107f0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f11:	00 
80107f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f15:	89 04 24             	mov    %eax,(%esp)
80107f18:	e8 99 d1 ff ff       	call   801050b6 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	05 00 00 00 80       	add    $0x80000000,%eax
80107f25:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107f2c:	00 
80107f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107f31:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f38:	00 
80107f39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f40:	00 
80107f41:	8b 45 08             	mov    0x8(%ebp),%eax
80107f44:	89 04 24             	mov    %eax,(%esp)
80107f47:	e8 9c fc ff ff       	call   80107be8 <mappages>
  memmove(mem, init, sz);
80107f4c:	8b 45 10             	mov    0x10(%ebp),%eax
80107f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f56:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5d:	89 04 24             	mov    %eax,(%esp)
80107f60:	e8 1a d2 ff ff       	call   8010517f <memmove>
}
80107f65:	c9                   	leave  
80107f66:	c3                   	ret    

80107f67 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f67:	55                   	push   %ebp
80107f68:	89 e5                	mov    %esp,%ebp
80107f6a:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f70:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f75:	85 c0                	test   %eax,%eax
80107f77:	74 0c                	je     80107f85 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107f79:	c7 04 24 b4 8f 10 80 	movl   $0x80108fb4,(%esp)
80107f80:	e8 cf 85 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f8c:	e9 a6 00 00 00       	jmp    80108037 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f94:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f97:	01 d0                	add    %edx,%eax
80107f99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fa0:	00 
80107fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa8:	89 04 24             	mov    %eax,(%esp)
80107fab:	e8 9c fb ff ff       	call   80107b4c <walkpgdir>
80107fb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fb3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fb7:	75 0c                	jne    80107fc5 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107fb9:	c7 04 24 d7 8f 10 80 	movl   $0x80108fd7,(%esp)
80107fc0:	e8 8f 85 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80107fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fc8:	8b 00                	mov    (%eax),%eax
80107fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fcf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd5:	8b 55 18             	mov    0x18(%ebp),%edx
80107fd8:	29 c2                	sub    %eax,%edx
80107fda:	89 d0                	mov    %edx,%eax
80107fdc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fe1:	77 0f                	ja     80107ff2 <loaduvm+0x8b>
      n = sz - i;
80107fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe6:	8b 55 18             	mov    0x18(%ebp),%edx
80107fe9:	29 c2                	sub    %eax,%edx
80107feb:	89 d0                	mov    %edx,%eax
80107fed:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ff0:	eb 07                	jmp    80107ff9 <loaduvm+0x92>
    else
      n = PGSIZE;
80107ff2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffc:	8b 55 14             	mov    0x14(%ebp),%edx
80107fff:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108002:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108005:	05 00 00 00 80       	add    $0x80000000,%eax
8010800a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010800d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108011:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108015:	89 44 24 04          	mov    %eax,0x4(%esp)
80108019:	8b 45 10             	mov    0x10(%ebp),%eax
8010801c:	89 04 24             	mov    %eax,(%esp)
8010801f:	e8 b9 9e ff ff       	call   80101edd <readi>
80108024:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108027:	74 07                	je     80108030 <loaduvm+0xc9>
      return -1;
80108029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010802e:	eb 18                	jmp    80108048 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108030:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803a:	3b 45 18             	cmp    0x18(%ebp),%eax
8010803d:	0f 82 4e ff ff ff    	jb     80107f91 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108048:	c9                   	leave  
80108049:	c3                   	ret    

8010804a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010804a:	55                   	push   %ebp
8010804b:	89 e5                	mov    %esp,%ebp
8010804d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108050:	8b 45 10             	mov    0x10(%ebp),%eax
80108053:	85 c0                	test   %eax,%eax
80108055:	79 0a                	jns    80108061 <allocuvm+0x17>
    return 0;
80108057:	b8 00 00 00 00       	mov    $0x0,%eax
8010805c:	e9 fd 00 00 00       	jmp    8010815e <allocuvm+0x114>
  if(newsz < oldsz)
80108061:	8b 45 10             	mov    0x10(%ebp),%eax
80108064:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108067:	73 08                	jae    80108071 <allocuvm+0x27>
    return oldsz;
80108069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806c:	e9 ed 00 00 00       	jmp    8010815e <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108071:	8b 45 0c             	mov    0xc(%ebp),%eax
80108074:	05 ff 0f 00 00       	add    $0xfff,%eax
80108079:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010807e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108081:	e9 c9 00 00 00       	jmp    8010814f <allocuvm+0x105>
    mem = kalloc();
80108086:	e8 ec ab ff ff       	call   80102c77 <kalloc>
8010808b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010808e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108092:	75 2f                	jne    801080c3 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108094:	c7 04 24 f5 8f 10 80 	movl   $0x80108ff5,(%esp)
8010809b:	e8 21 83 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801080a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801080a7:	8b 45 10             	mov    0x10(%ebp),%eax
801080aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801080ae:	8b 45 08             	mov    0x8(%ebp),%eax
801080b1:	89 04 24             	mov    %eax,(%esp)
801080b4:	e8 a7 00 00 00       	call   80108160 <deallocuvm>
      return 0;
801080b9:	b8 00 00 00 00       	mov    $0x0,%eax
801080be:	e9 9b 00 00 00       	jmp    8010815e <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
801080c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080ca:	00 
801080cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801080d2:	00 
801080d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d6:	89 04 24             	mov    %eax,(%esp)
801080d9:	e8 d8 cf ff ff       	call   801050b6 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801080de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801080e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ea:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801080f1:	00 
801080f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080fd:	00 
801080fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80108102:	8b 45 08             	mov    0x8(%ebp),%eax
80108105:	89 04 24             	mov    %eax,(%esp)
80108108:	e8 db fa ff ff       	call   80107be8 <mappages>
8010810d:	85 c0                	test   %eax,%eax
8010810f:	79 37                	jns    80108148 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108111:	c7 04 24 0d 90 10 80 	movl   $0x8010900d,(%esp)
80108118:	e8 a4 82 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010811d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108120:	89 44 24 08          	mov    %eax,0x8(%esp)
80108124:	8b 45 10             	mov    0x10(%ebp),%eax
80108127:	89 44 24 04          	mov    %eax,0x4(%esp)
8010812b:	8b 45 08             	mov    0x8(%ebp),%eax
8010812e:	89 04 24             	mov    %eax,(%esp)
80108131:	e8 2a 00 00 00       	call   80108160 <deallocuvm>
      kfree(mem);
80108136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108139:	89 04 24             	mov    %eax,(%esp)
8010813c:	e8 a0 aa ff ff       	call   80102be1 <kfree>
      return 0;
80108141:	b8 00 00 00 00       	mov    $0x0,%eax
80108146:	eb 16                	jmp    8010815e <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108148:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010814f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108152:	3b 45 10             	cmp    0x10(%ebp),%eax
80108155:	0f 82 2b ff ff ff    	jb     80108086 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
8010815b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010815e:	c9                   	leave  
8010815f:	c3                   	ret    

80108160 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108160:	55                   	push   %ebp
80108161:	89 e5                	mov    %esp,%ebp
80108163:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108166:	8b 45 10             	mov    0x10(%ebp),%eax
80108169:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010816c:	72 08                	jb     80108176 <deallocuvm+0x16>
    return oldsz;
8010816e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108171:	e9 ac 00 00 00       	jmp    80108222 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108176:	8b 45 10             	mov    0x10(%ebp),%eax
80108179:	05 ff 0f 00 00       	add    $0xfff,%eax
8010817e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108183:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108186:	e9 88 00 00 00       	jmp    80108213 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010818b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108195:	00 
80108196:	89 44 24 04          	mov    %eax,0x4(%esp)
8010819a:	8b 45 08             	mov    0x8(%ebp),%eax
8010819d:	89 04 24             	mov    %eax,(%esp)
801081a0:	e8 a7 f9 ff ff       	call   80107b4c <walkpgdir>
801081a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081ac:	75 14                	jne    801081c2 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801081ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b1:	c1 e8 16             	shr    $0x16,%eax
801081b4:	40                   	inc    %eax
801081b5:	c1 e0 16             	shl    $0x16,%eax
801081b8:	2d 00 10 00 00       	sub    $0x1000,%eax
801081bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081c0:	eb 4a                	jmp    8010820c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801081c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c5:	8b 00                	mov    (%eax),%eax
801081c7:	83 e0 01             	and    $0x1,%eax
801081ca:	85 c0                	test   %eax,%eax
801081cc:	74 3e                	je     8010820c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801081ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d1:	8b 00                	mov    (%eax),%eax
801081d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801081db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081df:	75 0c                	jne    801081ed <deallocuvm+0x8d>
        panic("kfree");
801081e1:	c7 04 24 29 90 10 80 	movl   $0x80109029,(%esp)
801081e8:	e8 67 83 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
801081ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081f0:	05 00 00 00 80       	add    $0x80000000,%eax
801081f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081fb:	89 04 24             	mov    %eax,(%esp)
801081fe:	e8 de a9 ff ff       	call   80102be1 <kfree>
      *pte = 0;
80108203:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108206:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010820c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108216:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108219:	0f 82 6c ff ff ff    	jb     8010818b <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010821f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108222:	c9                   	leave  
80108223:	c3                   	ret    

80108224 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108224:	55                   	push   %ebp
80108225:	89 e5                	mov    %esp,%ebp
80108227:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010822a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010822e:	75 0c                	jne    8010823c <freevm+0x18>
    panic("freevm: no pgdir");
80108230:	c7 04 24 2f 90 10 80 	movl   $0x8010902f,(%esp)
80108237:	e8 18 83 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010823c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108243:	00 
80108244:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010824b:	80 
8010824c:	8b 45 08             	mov    0x8(%ebp),%eax
8010824f:	89 04 24             	mov    %eax,(%esp)
80108252:	e8 09 ff ff ff       	call   80108160 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108257:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010825e:	eb 44                	jmp    801082a4 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108263:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010826a:	8b 45 08             	mov    0x8(%ebp),%eax
8010826d:	01 d0                	add    %edx,%eax
8010826f:	8b 00                	mov    (%eax),%eax
80108271:	83 e0 01             	and    $0x1,%eax
80108274:	85 c0                	test   %eax,%eax
80108276:	74 29                	je     801082a1 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108282:	8b 45 08             	mov    0x8(%ebp),%eax
80108285:	01 d0                	add    %edx,%eax
80108287:	8b 00                	mov    (%eax),%eax
80108289:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010828e:	05 00 00 00 80       	add    $0x80000000,%eax
80108293:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108296:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108299:	89 04 24             	mov    %eax,(%esp)
8010829c:	e8 40 a9 ff ff       	call   80102be1 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801082a1:	ff 45 f4             	incl   -0xc(%ebp)
801082a4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082ab:	76 b3                	jbe    80108260 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801082ad:	8b 45 08             	mov    0x8(%ebp),%eax
801082b0:	89 04 24             	mov    %eax,(%esp)
801082b3:	e8 29 a9 ff ff       	call   80102be1 <kfree>
}
801082b8:	c9                   	leave  
801082b9:	c3                   	ret    

801082ba <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801082ba:	55                   	push   %ebp
801082bb:	89 e5                	mov    %esp,%ebp
801082bd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082c7:	00 
801082c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801082cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801082cf:	8b 45 08             	mov    0x8(%ebp),%eax
801082d2:	89 04 24             	mov    %eax,(%esp)
801082d5:	e8 72 f8 ff ff       	call   80107b4c <walkpgdir>
801082da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801082dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082e1:	75 0c                	jne    801082ef <clearpteu+0x35>
    panic("clearpteu");
801082e3:	c7 04 24 40 90 10 80 	movl   $0x80109040,(%esp)
801082ea:	e8 65 82 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
801082ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f2:	8b 00                	mov    (%eax),%eax
801082f4:	83 e0 fb             	and    $0xfffffffb,%eax
801082f7:	89 c2                	mov    %eax,%edx
801082f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fc:	89 10                	mov    %edx,(%eax)
}
801082fe:	c9                   	leave  
801082ff:	c3                   	ret    

80108300 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108300:	55                   	push   %ebp
80108301:	89 e5                	mov    %esp,%ebp
80108303:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108306:	e8 73 f9 ff ff       	call   80107c7e <setupkvm>
8010830b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010830e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108312:	75 0a                	jne    8010831e <copyuvm+0x1e>
    return 0;
80108314:	b8 00 00 00 00       	mov    $0x0,%eax
80108319:	e9 f8 00 00 00       	jmp    80108416 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
8010831e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108325:	e9 cb 00 00 00       	jmp    801083f5 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010832a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108334:	00 
80108335:	89 44 24 04          	mov    %eax,0x4(%esp)
80108339:	8b 45 08             	mov    0x8(%ebp),%eax
8010833c:	89 04 24             	mov    %eax,(%esp)
8010833f:	e8 08 f8 ff ff       	call   80107b4c <walkpgdir>
80108344:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108347:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010834b:	75 0c                	jne    80108359 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010834d:	c7 04 24 4a 90 10 80 	movl   $0x8010904a,(%esp)
80108354:	e8 fb 81 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108359:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835c:	8b 00                	mov    (%eax),%eax
8010835e:	83 e0 01             	and    $0x1,%eax
80108361:	85 c0                	test   %eax,%eax
80108363:	75 0c                	jne    80108371 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108365:	c7 04 24 64 90 10 80 	movl   $0x80109064,(%esp)
8010836c:	e8 e3 81 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108371:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108374:	8b 00                	mov    (%eax),%eax
80108376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010837b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010837e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108381:	8b 00                	mov    (%eax),%eax
80108383:	25 ff 0f 00 00       	and    $0xfff,%eax
80108388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010838b:	e8 e7 a8 ff ff       	call   80102c77 <kalloc>
80108390:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108397:	75 02                	jne    8010839b <copyuvm+0x9b>
      goto bad;
80108399:	eb 6b                	jmp    80108406 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010839b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010839e:	05 00 00 00 80       	add    $0x80000000,%eax
801083a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083aa:	00 
801083ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801083af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083b2:	89 04 24             	mov    %eax,(%esp)
801083b5:	e8 c5 cd ff ff       	call   8010517f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801083ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801083bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083c0:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c9:	89 54 24 10          	mov    %edx,0x10(%esp)
801083cd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801083d1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083d8:	00 
801083d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801083dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e0:	89 04 24             	mov    %eax,(%esp)
801083e3:	e8 00 f8 ff ff       	call   80107be8 <mappages>
801083e8:	85 c0                	test   %eax,%eax
801083ea:	79 02                	jns    801083ee <copyuvm+0xee>
      goto bad;
801083ec:	eb 18                	jmp    80108406 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801083ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083fb:	0f 82 29 ff ff ff    	jb     8010832a <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108404:	eb 10                	jmp    80108416 <copyuvm+0x116>

bad:
  freevm(d);
80108406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108409:	89 04 24             	mov    %eax,(%esp)
8010840c:	e8 13 fe ff ff       	call   80108224 <freevm>
  return 0;
80108411:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108416:	c9                   	leave  
80108417:	c3                   	ret    

80108418 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108418:	55                   	push   %ebp
80108419:	89 e5                	mov    %esp,%ebp
8010841b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010841e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108425:	00 
80108426:	8b 45 0c             	mov    0xc(%ebp),%eax
80108429:	89 44 24 04          	mov    %eax,0x4(%esp)
8010842d:	8b 45 08             	mov    0x8(%ebp),%eax
80108430:	89 04 24             	mov    %eax,(%esp)
80108433:	e8 14 f7 ff ff       	call   80107b4c <walkpgdir>
80108438:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010843b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843e:	8b 00                	mov    (%eax),%eax
80108440:	83 e0 01             	and    $0x1,%eax
80108443:	85 c0                	test   %eax,%eax
80108445:	75 07                	jne    8010844e <uva2ka+0x36>
    return 0;
80108447:	b8 00 00 00 00       	mov    $0x0,%eax
8010844c:	eb 22                	jmp    80108470 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	8b 00                	mov    (%eax),%eax
80108453:	83 e0 04             	and    $0x4,%eax
80108456:	85 c0                	test   %eax,%eax
80108458:	75 07                	jne    80108461 <uva2ka+0x49>
    return 0;
8010845a:	b8 00 00 00 00       	mov    $0x0,%eax
8010845f:	eb 0f                	jmp    80108470 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108464:	8b 00                	mov    (%eax),%eax
80108466:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010846b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108470:	c9                   	leave  
80108471:	c3                   	ret    

80108472 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108472:	55                   	push   %ebp
80108473:	89 e5                	mov    %esp,%ebp
80108475:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108478:	8b 45 10             	mov    0x10(%ebp),%eax
8010847b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010847e:	e9 87 00 00 00       	jmp    8010850a <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108483:	8b 45 0c             	mov    0xc(%ebp),%eax
80108486:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010848b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010848e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108491:	89 44 24 04          	mov    %eax,0x4(%esp)
80108495:	8b 45 08             	mov    0x8(%ebp),%eax
80108498:	89 04 24             	mov    %eax,(%esp)
8010849b:	e8 78 ff ff ff       	call   80108418 <uva2ka>
801084a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801084a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801084a7:	75 07                	jne    801084b0 <copyout+0x3e>
      return -1;
801084a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084ae:	eb 69                	jmp    80108519 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801084b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801084b6:	29 c2                	sub    %eax,%edx
801084b8:	89 d0                	mov    %edx,%eax
801084ba:	05 00 10 00 00       	add    $0x1000,%eax
801084bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801084c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c5:	3b 45 14             	cmp    0x14(%ebp),%eax
801084c8:	76 06                	jbe    801084d0 <copyout+0x5e>
      n = len;
801084ca:	8b 45 14             	mov    0x14(%ebp),%eax
801084cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801084d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801084d6:	29 c2                	sub    %eax,%edx
801084d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084db:	01 c2                	add    %eax,%edx
801084dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801084e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084eb:	89 14 24             	mov    %edx,(%esp)
801084ee:	e8 8c cc ff ff       	call   8010517f <memmove>
    len -= n;
801084f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f6:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801084f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084fc:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108502:	05 00 10 00 00       	add    $0x1000,%eax
80108507:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010850a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010850e:	0f 85 6f ff ff ff    	jne    80108483 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108514:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108519:	c9                   	leave  
8010851a:	c3                   	ret    
	...

8010851c <strcpy>:
#define NULL ((void*)0)
#define MAX_CONTAINERS 4

struct container containers[MAX_CONTAINERS];

char* strcpy(char *s, char *t){
8010851c:	55                   	push   %ebp
8010851d:	89 e5                	mov    %esp,%ebp
8010851f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108522:	8b 45 08             	mov    0x8(%ebp),%eax
80108525:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108528:	90                   	nop
80108529:	8b 45 08             	mov    0x8(%ebp),%eax
8010852c:	8d 50 01             	lea    0x1(%eax),%edx
8010852f:	89 55 08             	mov    %edx,0x8(%ebp)
80108532:	8b 55 0c             	mov    0xc(%ebp),%edx
80108535:	8d 4a 01             	lea    0x1(%edx),%ecx
80108538:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010853b:	8a 12                	mov    (%edx),%dl
8010853d:	88 10                	mov    %dl,(%eax)
8010853f:	8a 00                	mov    (%eax),%al
80108541:	84 c0                	test   %al,%al
80108543:	75 e4                	jne    80108529 <strcpy+0xd>
    ;
  return os;
80108545:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108548:	c9                   	leave  
80108549:	c3                   	ret    

8010854a <strcmp>:

int
strcmp(const char *p, const char *q)
{
8010854a:	55                   	push   %ebp
8010854b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
8010854d:	eb 06                	jmp    80108555 <strcmp+0xb>
    p++, q++;
8010854f:	ff 45 08             	incl   0x8(%ebp)
80108552:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
80108555:	8b 45 08             	mov    0x8(%ebp),%eax
80108558:	8a 00                	mov    (%eax),%al
8010855a:	84 c0                	test   %al,%al
8010855c:	74 0e                	je     8010856c <strcmp+0x22>
8010855e:	8b 45 08             	mov    0x8(%ebp),%eax
80108561:	8a 10                	mov    (%eax),%dl
80108563:	8b 45 0c             	mov    0xc(%ebp),%eax
80108566:	8a 00                	mov    (%eax),%al
80108568:	38 c2                	cmp    %al,%dl
8010856a:	74 e3                	je     8010854f <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
8010856c:	8b 45 08             	mov    0x8(%ebp),%eax
8010856f:	8a 00                	mov    (%eax),%al
80108571:	0f b6 d0             	movzbl %al,%edx
80108574:	8b 45 0c             	mov    0xc(%ebp),%eax
80108577:	8a 00                	mov    (%eax),%al
80108579:	0f b6 c0             	movzbl %al,%eax
8010857c:	29 c2                	sub    %eax,%edx
8010857e:	89 d0                	mov    %edx,%eax
}
80108580:	5d                   	pop    %ebp
80108581:	c3                   	ret    

80108582 <get_name>:

void get_name(char* name, int vc_num){
80108582:	55                   	push   %ebp
80108583:	89 e5                	mov    %esp,%ebp
80108585:	57                   	push   %edi
80108586:	56                   	push   %esi
80108587:	53                   	push   %ebx
80108588:	83 ec 28             	sub    $0x28,%esp

	struct container x = containers[vc_num];
8010858b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010858e:	89 d0                	mov    %edx,%eax
80108590:	01 c0                	add    %eax,%eax
80108592:	01 d0                	add    %edx,%eax
80108594:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010859b:	01 c8                	add    %ecx,%eax
8010859d:	01 d0                	add    %edx,%eax
8010859f:	05 e0 78 11 80       	add    $0x801178e0,%eax
801085a4:	8d 55 d8             	lea    -0x28(%ebp),%edx
801085a7:	89 c3                	mov    %eax,%ebx
801085a9:	b8 07 00 00 00       	mov    $0x7,%eax
801085ae:	89 d7                	mov    %edx,%edi
801085b0:	89 de                	mov    %ebx,%esi
801085b2:	89 c1                	mov    %eax,%ecx
801085b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	strcpy(name, x.name);
801085b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801085bd:	8b 45 08             	mov    0x8(%ebp),%eax
801085c0:	89 04 24             	mov    %eax,(%esp)
801085c3:	e8 54 ff ff ff       	call   8010851c <strcpy>
}
801085c8:	83 c4 28             	add    $0x28,%esp
801085cb:	5b                   	pop    %ebx
801085cc:	5e                   	pop    %esi
801085cd:	5f                   	pop    %edi
801085ce:	5d                   	pop    %ebp
801085cf:	c3                   	ret    

801085d0 <next_open_index>:

int next_open_index(){
801085d0:	55                   	push   %ebp
801085d1:	89 e5                	mov    %esp,%ebp
801085d3:	83 ec 10             	sub    $0x10,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801085d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801085dd:	eb 28                	jmp    80108607 <next_open_index+0x37>
		if(containers[i].name != NULL){
801085df:	8b 55 fc             	mov    -0x4(%ebp),%edx
801085e2:	89 d0                	mov    %edx,%eax
801085e4:	01 c0                	add    %eax,%eax
801085e6:	01 d0                	add    %edx,%eax
801085e8:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801085ef:	01 c8                	add    %ecx,%eax
801085f1:	01 d0                	add    %edx,%eax
801085f3:	05 f0 78 11 80       	add    $0x801178f0,%eax
801085f8:	8b 40 08             	mov    0x8(%eax),%eax
801085fb:	85 c0                	test   %eax,%eax
801085fd:	74 05                	je     80108604 <next_open_index+0x34>
			return i;
801085ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108602:	eb 0e                	jmp    80108612 <next_open_index+0x42>
	strcpy(name, x.name);
}

int next_open_index(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108604:	ff 45 fc             	incl   -0x4(%ebp)
80108607:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
8010860b:	7e d2                	jle    801085df <next_open_index+0xf>
		if(containers[i].name != NULL){
			return i;
		}
	}
	return -1;
8010860d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108612:	c9                   	leave  
80108613:	c3                   	ret    

80108614 <find>:

int find(char* name){
80108614:	55                   	push   %ebp
80108615:	89 e5                	mov    %esp,%ebp
80108617:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010861a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108621:	eb 5b                	jmp    8010867e <find+0x6a>
		if(containers[i].name == NULL){
80108623:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108626:	89 d0                	mov    %edx,%eax
80108628:	01 c0                	add    %eax,%eax
8010862a:	01 d0                	add    %edx,%eax
8010862c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108633:	01 c8                	add    %ecx,%eax
80108635:	01 d0                	add    %edx,%eax
80108637:	05 f0 78 11 80       	add    $0x801178f0,%eax
8010863c:	8b 40 08             	mov    0x8(%eax),%eax
8010863f:	85 c0                	test   %eax,%eax
80108641:	75 02                	jne    80108645 <find+0x31>
			continue;
80108643:	eb 36                	jmp    8010867b <find+0x67>
		}
		if(strcmp(name, containers[i].name) == 0){
80108645:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108648:	89 d0                	mov    %edx,%eax
8010864a:	01 c0                	add    %eax,%eax
8010864c:	01 d0                	add    %edx,%eax
8010864e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108655:	01 c8                	add    %ecx,%eax
80108657:	01 d0                	add    %edx,%eax
80108659:	05 f0 78 11 80       	add    $0x801178f0,%eax
8010865e:	8b 40 08             	mov    0x8(%eax),%eax
80108661:	89 44 24 04          	mov    %eax,0x4(%esp)
80108665:	8b 45 08             	mov    0x8(%ebp),%eax
80108668:	89 04 24             	mov    %eax,(%esp)
8010866b:	e8 da fe ff ff       	call   8010854a <strcmp>
80108670:	85 c0                	test   %eax,%eax
80108672:	75 07                	jne    8010867b <find+0x67>
			return 0;
80108674:	b8 00 00 00 00       	mov    $0x0,%eax
80108679:	eb 0e                	jmp    80108689 <find+0x75>
	return -1;
}

int find(char* name){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010867b:	ff 45 fc             	incl   -0x4(%ebp)
8010867e:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108682:	7e 9f                	jle    80108623 <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return 0;
		}
	}
	return -1;
80108684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108689:	c9                   	leave  
8010868a:	c3                   	ret    

8010868b <get_max_proc>:

int get_max_proc(int vc_num){
8010868b:	55                   	push   %ebp
8010868c:	89 e5                	mov    %esp,%ebp
8010868e:	57                   	push   %edi
8010868f:	56                   	push   %esi
80108690:	53                   	push   %ebx
80108691:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108694:	8b 55 08             	mov    0x8(%ebp),%edx
80108697:	89 d0                	mov    %edx,%eax
80108699:	01 c0                	add    %eax,%eax
8010869b:	01 d0                	add    %edx,%eax
8010869d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801086a4:	01 c8                	add    %ecx,%eax
801086a6:	01 d0                	add    %edx,%eax
801086a8:	05 e0 78 11 80       	add    $0x801178e0,%eax
801086ad:	8d 55 d8             	lea    -0x28(%ebp),%edx
801086b0:	89 c3                	mov    %eax,%ebx
801086b2:	b8 07 00 00 00       	mov    $0x7,%eax
801086b7:	89 d7                	mov    %edx,%edi
801086b9:	89 de                	mov    %ebx,%esi
801086bb:	89 c1                	mov    %eax,%ecx
801086bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
801086bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801086c2:	83 c4 20             	add    $0x20,%esp
801086c5:	5b                   	pop    %ebx
801086c6:	5e                   	pop    %esi
801086c7:	5f                   	pop    %edi
801086c8:	5d                   	pop    %ebp
801086c9:	c3                   	ret    

801086ca <get_max_mem>:

int get_max_mem(int vc_num){
801086ca:	55                   	push   %ebp
801086cb:	89 e5                	mov    %esp,%ebp
801086cd:	57                   	push   %edi
801086ce:	56                   	push   %esi
801086cf:	53                   	push   %ebx
801086d0:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
801086d3:	8b 55 08             	mov    0x8(%ebp),%edx
801086d6:	89 d0                	mov    %edx,%eax
801086d8:	01 c0                	add    %eax,%eax
801086da:	01 d0                	add    %edx,%eax
801086dc:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801086e3:	01 c8                	add    %ecx,%eax
801086e5:	01 d0                	add    %edx,%eax
801086e7:	05 e0 78 11 80       	add    $0x801178e0,%eax
801086ec:	8d 55 d8             	lea    -0x28(%ebp),%edx
801086ef:	89 c3                	mov    %eax,%ebx
801086f1:	b8 07 00 00 00       	mov    $0x7,%eax
801086f6:	89 d7                	mov    %edx,%edi
801086f8:	89 de                	mov    %ebx,%esi
801086fa:	89 c1                	mov    %eax,%ecx
801086fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
801086fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80108701:	83 c4 20             	add    $0x20,%esp
80108704:	5b                   	pop    %ebx
80108705:	5e                   	pop    %esi
80108706:	5f                   	pop    %edi
80108707:	5d                   	pop    %ebp
80108708:	c3                   	ret    

80108709 <get_max_disk>:

int get_max_disk(int vc_num){
80108709:	55                   	push   %ebp
8010870a:	89 e5                	mov    %esp,%ebp
8010870c:	57                   	push   %edi
8010870d:	56                   	push   %esi
8010870e:	53                   	push   %ebx
8010870f:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108712:	8b 55 08             	mov    0x8(%ebp),%edx
80108715:	89 d0                	mov    %edx,%eax
80108717:	01 c0                	add    %eax,%eax
80108719:	01 d0                	add    %edx,%eax
8010871b:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108722:	01 c8                	add    %ecx,%eax
80108724:	01 d0                	add    %edx,%eax
80108726:	05 e0 78 11 80       	add    $0x801178e0,%eax
8010872b:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010872e:	89 c3                	mov    %eax,%ebx
80108730:	b8 07 00 00 00       	mov    $0x7,%eax
80108735:	89 d7                	mov    %edx,%edi
80108737:	89 de                	mov    %ebx,%esi
80108739:	89 c1                	mov    %eax,%ecx
8010873b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
8010873d:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80108740:	83 c4 20             	add    $0x20,%esp
80108743:	5b                   	pop    %ebx
80108744:	5e                   	pop    %esi
80108745:	5f                   	pop    %edi
80108746:	5d                   	pop    %ebp
80108747:	c3                   	ret    

80108748 <get_curr_proc>:

int get_curr_proc(int vc_num){
80108748:	55                   	push   %ebp
80108749:	89 e5                	mov    %esp,%ebp
8010874b:	57                   	push   %edi
8010874c:	56                   	push   %esi
8010874d:	53                   	push   %ebx
8010874e:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108751:	8b 55 08             	mov    0x8(%ebp),%edx
80108754:	89 d0                	mov    %edx,%eax
80108756:	01 c0                	add    %eax,%eax
80108758:	01 d0                	add    %edx,%eax
8010875a:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108761:	01 c8                	add    %ecx,%eax
80108763:	01 d0                	add    %edx,%eax
80108765:	05 e0 78 11 80       	add    $0x801178e0,%eax
8010876a:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010876d:	89 c3                	mov    %eax,%ebx
8010876f:	b8 07 00 00 00       	mov    $0x7,%eax
80108774:	89 d7                	mov    %edx,%edi
80108776:	89 de                	mov    %ebx,%esi
80108778:	89 c1                	mov    %eax,%ecx
8010877a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
8010877c:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
8010877f:	83 c4 20             	add    $0x20,%esp
80108782:	5b                   	pop    %ebx
80108783:	5e                   	pop    %esi
80108784:	5f                   	pop    %edi
80108785:	5d                   	pop    %ebp
80108786:	c3                   	ret    

80108787 <get_curr_mem>:

int get_curr_mem(int vc_num){
80108787:	55                   	push   %ebp
80108788:	89 e5                	mov    %esp,%ebp
8010878a:	57                   	push   %edi
8010878b:	56                   	push   %esi
8010878c:	53                   	push   %ebx
8010878d:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108790:	8b 55 08             	mov    0x8(%ebp),%edx
80108793:	89 d0                	mov    %edx,%eax
80108795:	01 c0                	add    %eax,%eax
80108797:	01 d0                	add    %edx,%eax
80108799:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801087a0:	01 c8                	add    %ecx,%eax
801087a2:	01 d0                	add    %edx,%eax
801087a4:	05 e0 78 11 80       	add    $0x801178e0,%eax
801087a9:	8d 55 d8             	lea    -0x28(%ebp),%edx
801087ac:	89 c3                	mov    %eax,%ebx
801087ae:	b8 07 00 00 00       	mov    $0x7,%eax
801087b3:	89 d7                	mov    %edx,%edi
801087b5:	89 de                	mov    %ebx,%esi
801087b7:	89 c1                	mov    %eax,%ecx
801087b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_mem; 
801087bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801087be:	83 c4 20             	add    $0x20,%esp
801087c1:	5b                   	pop    %ebx
801087c2:	5e                   	pop    %esi
801087c3:	5f                   	pop    %edi
801087c4:	5d                   	pop    %ebp
801087c5:	c3                   	ret    

801087c6 <get_curr_disk>:

int get_curr_disk(int vc_num){
801087c6:	55                   	push   %ebp
801087c7:	89 e5                	mov    %esp,%ebp
801087c9:	57                   	push   %edi
801087ca:	56                   	push   %esi
801087cb:	53                   	push   %ebx
801087cc:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
801087cf:	8b 55 08             	mov    0x8(%ebp),%edx
801087d2:	89 d0                	mov    %edx,%eax
801087d4:	01 c0                	add    %eax,%eax
801087d6:	01 d0                	add    %edx,%eax
801087d8:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801087df:	01 c8                	add    %ecx,%eax
801087e1:	01 d0                	add    %edx,%eax
801087e3:	05 e0 78 11 80       	add    $0x801178e0,%eax
801087e8:	8d 55 d8             	lea    -0x28(%ebp),%edx
801087eb:	89 c3                	mov    %eax,%ebx
801087ed:	b8 07 00 00 00       	mov    $0x7,%eax
801087f2:	89 d7                	mov    %edx,%edi
801087f4:	89 de                	mov    %ebx,%esi
801087f6:	89 c1                	mov    %eax,%ecx
801087f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
801087fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801087fd:	83 c4 20             	add    $0x20,%esp
80108800:	5b                   	pop    %ebx
80108801:	5e                   	pop    %esi
80108802:	5f                   	pop    %edi
80108803:	5d                   	pop    %ebp
80108804:	c3                   	ret    

80108805 <set_name>:

void set_name(char* name, int vc_num){
80108805:	55                   	push   %ebp
80108806:	89 e5                	mov    %esp,%ebp
80108808:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
8010880b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010880e:	89 d0                	mov    %edx,%eax
80108810:	01 c0                	add    %eax,%eax
80108812:	01 d0                	add    %edx,%eax
80108814:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010881b:	01 c8                	add    %ecx,%eax
8010881d:	01 d0                	add    %edx,%eax
8010881f:	05 f0 78 11 80       	add    $0x801178f0,%eax
80108824:	8b 40 08             	mov    0x8(%eax),%eax
80108827:	8b 55 08             	mov    0x8(%ebp),%edx
8010882a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010882e:	89 04 24             	mov    %eax,(%esp)
80108831:	e8 e6 fc ff ff       	call   8010851c <strcpy>
}
80108836:	c9                   	leave  
80108837:	c3                   	ret    

80108838 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80108838:	55                   	push   %ebp
80108839:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
8010883b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010883e:	89 d0                	mov    %edx,%eax
80108840:	01 c0                	add    %eax,%eax
80108842:	01 d0                	add    %edx,%eax
80108844:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010884b:	01 c8                	add    %ecx,%eax
8010884d:	01 d0                	add    %edx,%eax
8010884f:	8d 90 e0 78 11 80    	lea    -0x7fee8720(%eax),%edx
80108855:	8b 45 08             	mov    0x8(%ebp),%eax
80108858:	89 02                	mov    %eax,(%edx)
}
8010885a:	5d                   	pop    %ebp
8010885b:	c3                   	ret    

8010885c <set_max_disk>:

void set_max_disk(int disk, int vc_num){
8010885c:	55                   	push   %ebp
8010885d:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
8010885f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108862:	89 d0                	mov    %edx,%eax
80108864:	01 c0                	add    %eax,%eax
80108866:	01 d0                	add    %edx,%eax
80108868:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010886f:	01 c8                	add    %ecx,%eax
80108871:	01 d0                	add    %edx,%eax
80108873:	8d 90 e0 78 11 80    	lea    -0x7fee8720(%eax),%edx
80108879:	8b 45 08             	mov    0x8(%ebp),%eax
8010887c:	89 42 08             	mov    %eax,0x8(%edx)
}
8010887f:	5d                   	pop    %ebp
80108880:	c3                   	ret    

80108881 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80108881:	55                   	push   %ebp
80108882:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80108884:	8b 55 0c             	mov    0xc(%ebp),%edx
80108887:	89 d0                	mov    %edx,%eax
80108889:	01 c0                	add    %eax,%eax
8010888b:	01 d0                	add    %edx,%eax
8010888d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108894:	01 c8                	add    %ecx,%eax
80108896:	01 d0                	add    %edx,%eax
80108898:	8d 90 e0 78 11 80    	lea    -0x7fee8720(%eax),%edx
8010889e:	8b 45 08             	mov    0x8(%ebp),%eax
801088a1:	89 42 04             	mov    %eax,0x4(%edx)
}
801088a4:	5d                   	pop    %ebp
801088a5:	c3                   	ret    

801088a6 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
801088a6:	55                   	push   %ebp
801088a7:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = mem;	
801088a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801088ac:	89 d0                	mov    %edx,%eax
801088ae:	01 c0                	add    %eax,%eax
801088b0:	01 d0                	add    %edx,%eax
801088b2:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801088b9:	01 c8                	add    %ecx,%eax
801088bb:	01 d0                	add    %edx,%eax
801088bd:	8d 90 e0 78 11 80    	lea    -0x7fee8720(%eax),%edx
801088c3:	8b 45 08             	mov    0x8(%ebp),%eax
801088c6:	89 42 0c             	mov    %eax,0xc(%edx)
}
801088c9:	5d                   	pop    %ebp
801088ca:	c3                   	ret    

801088cb <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
801088cb:	55                   	push   %ebp
801088cc:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk = disk;
801088ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801088d1:	89 d0                	mov    %edx,%eax
801088d3:	01 c0                	add    %eax,%eax
801088d5:	01 d0                	add    %edx,%eax
801088d7:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801088de:	01 c8                	add    %ecx,%eax
801088e0:	01 d0                	add    %edx,%eax
801088e2:	8d 90 f0 78 11 80    	lea    -0x7fee8710(%eax),%edx
801088e8:	8b 45 08             	mov    0x8(%ebp),%eax
801088eb:	89 42 04             	mov    %eax,0x4(%edx)
}
801088ee:	5d                   	pop    %ebp
801088ef:	c3                   	ret    

801088f0 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
801088f0:	55                   	push   %ebp
801088f1:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
801088f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801088f6:	89 d0                	mov    %edx,%eax
801088f8:	01 c0                	add    %eax,%eax
801088fa:	01 d0                	add    %edx,%eax
801088fc:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108903:	01 c8                	add    %ecx,%eax
80108905:	01 d0                	add    %edx,%eax
80108907:	8d 90 f0 78 11 80    	lea    -0x7fee8710(%eax),%edx
8010890d:	8b 45 08             	mov    0x8(%ebp),%eax
80108910:	89 02                	mov    %eax,(%edx)
}
80108912:	5d                   	pop    %ebp
80108913:	c3                   	ret    
