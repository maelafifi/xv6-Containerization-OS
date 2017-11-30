
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
8010002d:	b8 f2 38 10 80       	mov    $0x801038f2,%eax
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
8010003a:	c7 44 24 04 f8 90 10 	movl   $0x801090f8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100049:	e8 7c 51 00 00       	call   801051ca <initlock>

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
80100087:	c7 44 24 04 ff 90 10 	movl   $0x801090ff,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 f5 4f 00 00       	call   8010508c <initsleeplock>
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
801000c9:	e8 1d 51 00 00       	call   801051eb <acquire>

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
80100104:	e8 4c 51 00 00       	call   80105255 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 af 4f 00 00       	call   801050c6 <acquiresleep>
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
8010017d:	e8 d3 50 00 00       	call   80105255 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 36 4f 00 00       	call   801050c6 <acquiresleep>
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
801001a7:	c7 04 24 06 91 10 80 	movl   $0x80109106,(%esp)
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
801001e2:	e8 fe 27 00 00       	call   801029e5 <iderw>
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
801001fb:	e8 63 4f 00 00       	call   80105163 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 17 91 10 80 	movl   $0x80109117,(%esp)
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
80100225:	e8 bb 27 00 00       	call   801029e5 <iderw>
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
8010023b:	e8 23 4f 00 00       	call   80105163 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 1e 91 10 80 	movl   $0x8010911e,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 c3 4e 00 00       	call   80105121 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100265:	e8 81 4f 00 00       	call   801051eb <acquire>
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
801002d1:	e8 7f 4f 00 00       	call   80105255 <release>
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
801003dc:	e8 0a 4e 00 00       	call   801051eb <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 25 91 10 80 	movl   $0x80109125,(%esp)
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
801004cf:	c7 45 ec 2e 91 10 80 	movl   $0x8010912e,-0x14(%ebp)
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
8010054d:	e8 03 4d 00 00       	call   80105255 <release>
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
80100569:	e8 57 2b 00 00       	call   801030c5 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 35 91 10 80 	movl   $0x80109135,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 49 91 10 80 	movl   $0x80109149,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 fb 4c 00 00       	call   801052a2 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 4b 91 10 80 	movl   $0x8010914b,(%esp)
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
80100695:	c7 04 24 4f 91 10 80 	movl   $0x8010914f,(%esp)
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
801006c9:	e8 49 4e 00 00       	call   80105517 <memmove>
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
801006f8:	e8 51 4d 00 00       	call   8010544e <memset>
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
8010078e:	e8 71 6a 00 00       	call   80107204 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 65 6a 00 00       	call   80107204 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 59 6a 00 00       	call   80107204 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 4c 6a 00 00       	call   80107204 <uartputc>
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
80100813:	e8 d3 49 00 00       	call   801051eb <acquire>
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
80100a00:	e8 92 42 00 00       	call   80104c97 <wakeup>
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
80100a21:	e8 2f 48 00 00       	call   80105255 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 62 91 10 80 	movl   $0x80109162,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 00 43 00 00       	call   80104d3d <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 7a 91 10 80 	movl   $0x8010917a,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 94 91 10 80 	movl   $0x80109194,(%esp)
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
80100a8a:	e8 5c 47 00 00       	call   801051eb <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 74 38 00 00       	call   8010430f <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100aa9:	e8 a7 47 00 00       	call   80105255 <release>
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
80100ad2:	e8 e9 40 00 00       	call   80104bc0 <sleep>

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
80100b5c:	e8 f4 46 00 00       	call   80105255 <release>
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
80100ba2:	e8 44 46 00 00       	call   801051eb <acquire>
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
80100bda:	e8 76 46 00 00       	call   80105255 <release>
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
80100bf5:	c7 44 24 04 ad 91 10 	movl   $0x801091ad,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100c04:	e8 c1 45 00 00       	call   801051ca <initlock>

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
80100c36:	e8 5c 1f 00 00       	call   80102b97 <ioapicenable>
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
80100c49:	e8 c1 36 00 00       	call   8010430f <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 b9 29 00 00       	call   8010360f <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 96 19 00 00       	call   801025f7 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 22 2a 00 00       	call   80103691 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 b5 91 10 80 	movl   $0x801091b5,(%esp)
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
80100cd8:	e8 09 75 00 00       	call   801081e6 <setupkvm>
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
80100d96:	e8 17 78 00 00       	call   801085b2 <allocuvm>
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
80100de8:	e8 e2 76 00 00       	call   801084cf <loaduvm>
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
80100e1f:	e8 6d 28 00 00       	call   80103691 <end_op>
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
80100e54:	e8 59 77 00 00       	call   801085b2 <allocuvm>
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
80100e79:	e8 a4 79 00 00       	call   80108822 <clearpteu>
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
80100eaf:	e8 ed 47 00 00       	call   801056a1 <strlen>
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
80100ed6:	e8 c6 47 00 00       	call   801056a1 <strlen>
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
80100f04:	e8 d1 7a 00 00       	call   801089da <copyout>
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
80100fa8:	e8 2d 7a 00 00       	call   801089da <copyout>
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
80100ff8:	e8 5d 46 00 00       	call   8010565a <safestrcpy>

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
80101038:	e8 83 72 00 00       	call   801082c0 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 44 77 00 00       	call   8010878c <freevm>
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
8010105b:	e8 2c 77 00 00       	call   8010878c <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 1b 26 00 00       	call   80103691 <end_op>
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
801010ec:	c7 44 24 04 c1 91 10 	movl   $0x801091c1,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801010fb:	e8 ca 40 00 00       	call   801051ca <initlock>
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
8010110f:	e8 d7 40 00 00       	call   801051eb <acquire>
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
80101138:	e8 18 41 00 00       	call   80105255 <release>
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
80101156:	e8 fa 40 00 00       	call   80105255 <release>
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
8010116f:	e8 77 40 00 00       	call   801051eb <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 c8 91 10 80 	movl   $0x801091c8,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011a0:	e8 b0 40 00 00       	call   80105255 <release>
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
801011ba:	e8 2c 40 00 00       	call   801051eb <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 d0 91 10 80 	movl   $0x801091d0,(%esp)
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
801011f5:	e8 5b 40 00 00       	call   80105255 <release>
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
8010122b:	e8 25 40 00 00       	call   80105255 <release>

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
80101248:	e8 5a 2d 00 00       	call   80103fa7 <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 b3 23 00 00       	call   8010360f <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 25 24 00 00       	call   80103691 <end_op>
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
801012fe:	e8 22 2e 00 00       	call   80104125 <piperead>
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
80101370:	c7 04 24 da 91 10 80 	movl   $0x801091da,(%esp)
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
801013ba:	e8 7a 2c 00 00       	call   80104039 <pipewrite>
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
80101400:	e8 0a 22 00 00       	call   8010360f <begin_op>
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
80101466:	e8 26 22 00 00       	call   80103691 <end_op>

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
8010147b:	c7 04 24 e3 91 10 80 	movl   $0x801091e3,(%esp)
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
801014ad:	c7 04 24 f3 91 10 80 	movl   $0x801091f3,(%esp)
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
801014f4:	e8 1e 40 00 00       	call   80105517 <memmove>
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
8010153a:	e8 0f 3f 00 00       	call   8010544e <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 c9 22 00 00       	call   80103813 <log_write>
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
8010160d:	e8 01 22 00 00       	call   80103813 <log_write>
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
80101683:	c7 04 24 00 92 10 80 	movl   $0x80109200,(%esp)
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
80101713:	c7 04 24 16 92 10 80 	movl   $0x80109216,(%esp)
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
80101749:	e8 c5 20 00 00       	call   80103813 <log_write>
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
8010176b:	c7 44 24 04 29 92 10 	movl   $0x80109229,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
8010177a:	e8 4b 3a 00 00       	call   801051ca <initlock>
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
801017a0:	c7 44 24 04 30 92 10 	movl   $0x80109230,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 dc 38 00 00       	call   8010508c <initsleeplock>
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
80101819:	c7 04 24 38 92 10 80 	movl   $0x80109238,(%esp)
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
8010189b:	e8 ae 3b 00 00       	call   8010544e <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 5f 1f 00 00       	call   80103813 <log_write>
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
801018f1:	c7 04 24 8b 92 10 80 	movl   $0x8010928b,(%esp)
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
8010199e:	e8 74 3b 00 00       	call   80105517 <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 65 1e 00 00       	call   80103813 <log_write>
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
801019c8:	e8 1e 38 00 00       	call   801051eb <acquire>

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
80101a12:	e8 3e 38 00 00       	call   80105255 <release>
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
80101a48:	c7 04 24 9d 92 10 80 	movl   $0x8010929d,(%esp)
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
80101a86:	e8 ca 37 00 00       	call   80105255 <release>

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
80101a9d:	e8 49 37 00 00       	call   801051eb <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101ab8:	e8 98 37 00 00       	call   80105255 <release>
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
80101ad8:	c7 04 24 ad 92 10 80 	movl   $0x801092ad,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 d4 35 00 00       	call   801050c6 <acquiresleep>

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
80101b99:	e8 79 39 00 00       	call   80105517 <memmove>
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
80101bbe:	c7 04 24 b3 92 10 80 	movl   $0x801092b3,(%esp)
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
80101be1:	e8 7d 35 00 00       	call   80105163 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 c2 92 10 80 	movl   $0x801092c2,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 13 35 00 00       	call   80105121 <releasesleep>
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
80101c1f:	e8 a2 34 00 00       	call   801050c6 <acquiresleep>
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
80101c41:	e8 a5 35 00 00       	call   801051eb <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c56:	e8 fa 35 00 00       	call   80105255 <release>
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
80101c93:	e8 89 34 00 00       	call   80105121 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c9f:	e8 47 35 00 00       	call   801051eb <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101cba:	e8 96 35 00 00       	call   80105255 <release>
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
80101dcb:	e8 43 1a 00 00       	call   80103813 <log_write>
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
80101de0:	c7 04 24 ca 92 10 80 	movl   $0x801092ca,(%esp)
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
8010208a:	e8 88 34 00 00       	call   80105517 <memmove>
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
801021e9:	e8 29 33 00 00       	call   80105517 <memmove>
    log_write(bp);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 1a 16 00 00       	call   80103813 <log_write>
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
80102267:	e8 4a 33 00 00       	call   801055b6 <strncmp>
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
80102280:	c7 04 24 dd 92 10 80 	movl   $0x801092dd,(%esp)
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
801022be:	c7 04 24 ef 92 10 80 	movl   $0x801092ef,(%esp)
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
801023a1:	c7 04 24 fe 92 10 80 	movl   $0x801092fe,(%esp)
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
801023e5:	e8 1a 32 00 00       	call   80105604 <strncpy>
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
80102417:	c7 04 24 0b 93 10 80 	movl   $0x8010930b,(%esp)
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
80102496:	e8 7c 30 00 00       	call   80105517 <memmove>
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
801024b1:	e8 61 30 00 00       	call   80105517 <memmove>
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
801024e1:	75 19                	jne    801024fc <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
801024e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024ea:	00 
801024eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801024f2:	e8 c4 f4 ff ff       	call   801019bb <iget>
801024f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024fa:	eb 13                	jmp    8010250f <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
801024fc:	e8 0e 1e 00 00       	call   8010430f <myproc>
80102501:	8b 40 68             	mov    0x68(%eax),%eax
80102504:	89 04 24             	mov    %eax,(%esp)
80102507:	e8 84 f5 ff ff       	call   80101a90 <idup>
8010250c:	89 45 f4             	mov    %eax,-0xc(%ebp)


  cprintf("path is %s.\n", path);
8010250f:	8b 45 08             	mov    0x8(%ebp),%eax
80102512:	89 44 24 04          	mov    %eax,0x4(%esp)
80102516:	c7 04 24 13 93 10 80 	movl   $0x80109313,(%esp)
8010251d:	e8 9f de ff ff       	call   801003c1 <cprintf>

  while((path = skipelem(path, name)) != 0){
80102522:	e9 94 00 00 00       	jmp    801025bb <namex+0xe7>
    ilock(ip);
80102527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252a:	89 04 24             	mov    %eax,(%esp)
8010252d:	e8 90 f5 ff ff       	call   80101ac2 <ilock>
    if(ip->type != T_DIR){
80102532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102535:	8b 40 50             	mov    0x50(%eax),%eax
80102538:	66 83 f8 01          	cmp    $0x1,%ax
8010253c:	74 15                	je     80102553 <namex+0x7f>
      iunlockput(ip);
8010253e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102541:	89 04 24             	mov    %eax,(%esp)
80102544:	e8 78 f7 ff ff       	call   80101cc1 <iunlockput>
      return 0;
80102549:	b8 00 00 00 00       	mov    $0x0,%eax
8010254e:	e9 a2 00 00 00       	jmp    801025f5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
80102553:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102557:	74 1c                	je     80102575 <namex+0xa1>
80102559:	8b 45 08             	mov    0x8(%ebp),%eax
8010255c:	8a 00                	mov    (%eax),%al
8010255e:	84 c0                	test   %al,%al
80102560:	75 13                	jne    80102575 <namex+0xa1>
      // Stop one level early.
      iunlock(ip);
80102562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102565:	89 04 24             	mov    %eax,(%esp)
80102568:	e8 5f f6 ff ff       	call   80101bcc <iunlock>
      return ip;
8010256d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102570:	e9 80 00 00 00       	jmp    801025f5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102575:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010257c:	00 
8010257d:	8b 45 10             	mov    0x10(%ebp),%eax
80102580:	89 44 24 04          	mov    %eax,0x4(%esp)
80102584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102587:	89 04 24             	mov    %eax,(%esp)
8010258a:	e8 df fc ff ff       	call   8010226e <dirlookup>
8010258f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102592:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102596:	75 12                	jne    801025aa <namex+0xd6>
      iunlockput(ip);
80102598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010259b:	89 04 24             	mov    %eax,(%esp)
8010259e:	e8 1e f7 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801025a3:	b8 00 00 00 00       	mov    $0x0,%eax
801025a8:	eb 4b                	jmp    801025f5 <namex+0x121>
    }
    iunlockput(ip);
801025aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ad:	89 04 24             	mov    %eax,(%esp)
801025b0:	e8 0c f7 ff ff       	call   80101cc1 <iunlockput>
    ip = next;
801025b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip = idup(myproc()->cwd);


  cprintf("path is %s.\n", path);

  while((path = skipelem(path, name)) != 0){
801025bb:	8b 45 10             	mov    0x10(%ebp),%eax
801025be:	89 44 24 04          	mov    %eax,0x4(%esp)
801025c2:	8b 45 08             	mov    0x8(%ebp),%eax
801025c5:	89 04 24             	mov    %eax,(%esp)
801025c8:	e8 5d fe ff ff       	call   8010242a <skipelem>
801025cd:	89 45 08             	mov    %eax,0x8(%ebp)
801025d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d4:	0f 85 4d ff ff ff    	jne    80102527 <namex+0x53>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025de:	74 12                	je     801025f2 <namex+0x11e>
    iput(ip);
801025e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e3:	89 04 24             	mov    %eax,(%esp)
801025e6:	e8 25 f6 ff ff       	call   80101c10 <iput>
    return 0;
801025eb:	b8 00 00 00 00       	mov    $0x0,%eax
801025f0:	eb 03                	jmp    801025f5 <namex+0x121>
  //       temp = 
  //     }
  //   }
  // }

  return ip;
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025f5:	c9                   	leave  
801025f6:	c3                   	ret    

801025f7 <namei>:

struct inode*
namei(char *path)
{
801025f7:	55                   	push   %ebp
801025f8:	89 e5                	mov    %esp,%ebp
801025fa:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025fd:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102600:	89 44 24 08          	mov    %eax,0x8(%esp)
80102604:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010260b:	00 
8010260c:	8b 45 08             	mov    0x8(%ebp),%eax
8010260f:	89 04 24             	mov    %eax,(%esp)
80102612:	e8 bd fe ff ff       	call   801024d4 <namex>
}
80102617:	c9                   	leave  
80102618:	c3                   	ret    

80102619 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102619:	55                   	push   %ebp
8010261a:	89 e5                	mov    %esp,%ebp
8010261c:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010261f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102622:	89 44 24 08          	mov    %eax,0x8(%esp)
80102626:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010262d:	00 
8010262e:	8b 45 08             	mov    0x8(%ebp),%eax
80102631:	89 04 24             	mov    %eax,(%esp)
80102634:	e8 9b fe ff ff       	call   801024d4 <namex>
}
80102639:	c9                   	leave  
8010263a:	c3                   	ret    
	...

8010263c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010263c:	55                   	push   %ebp
8010263d:	89 e5                	mov    %esp,%ebp
8010263f:	83 ec 14             	sub    $0x14,%esp
80102642:	8b 45 08             	mov    0x8(%ebp),%eax
80102645:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102649:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010264c:	89 c2                	mov    %eax,%edx
8010264e:	ec                   	in     (%dx),%al
8010264f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102652:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102655:	c9                   	leave  
80102656:	c3                   	ret    

80102657 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102657:	55                   	push   %ebp
80102658:	89 e5                	mov    %esp,%ebp
8010265a:	57                   	push   %edi
8010265b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010265c:	8b 55 08             	mov    0x8(%ebp),%edx
8010265f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102662:	8b 45 10             	mov    0x10(%ebp),%eax
80102665:	89 cb                	mov    %ecx,%ebx
80102667:	89 df                	mov    %ebx,%edi
80102669:	89 c1                	mov    %eax,%ecx
8010266b:	fc                   	cld    
8010266c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010266e:	89 c8                	mov    %ecx,%eax
80102670:	89 fb                	mov    %edi,%ebx
80102672:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102675:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102678:	5b                   	pop    %ebx
80102679:	5f                   	pop    %edi
8010267a:	5d                   	pop    %ebp
8010267b:	c3                   	ret    

8010267c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010267c:	55                   	push   %ebp
8010267d:	89 e5                	mov    %esp,%ebp
8010267f:	83 ec 08             	sub    $0x8,%esp
80102682:	8b 45 08             	mov    0x8(%ebp),%eax
80102685:	8b 55 0c             	mov    0xc(%ebp),%edx
80102688:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010268c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010268f:	8a 45 f8             	mov    -0x8(%ebp),%al
80102692:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102695:	ee                   	out    %al,(%dx)
}
80102696:	c9                   	leave  
80102697:	c3                   	ret    

80102698 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102698:	55                   	push   %ebp
80102699:	89 e5                	mov    %esp,%ebp
8010269b:	56                   	push   %esi
8010269c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010269d:	8b 55 08             	mov    0x8(%ebp),%edx
801026a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026a3:	8b 45 10             	mov    0x10(%ebp),%eax
801026a6:	89 cb                	mov    %ecx,%ebx
801026a8:	89 de                	mov    %ebx,%esi
801026aa:	89 c1                	mov    %eax,%ecx
801026ac:	fc                   	cld    
801026ad:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026af:	89 c8                	mov    %ecx,%eax
801026b1:	89 f3                	mov    %esi,%ebx
801026b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026b6:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801026b9:	5b                   	pop    %ebx
801026ba:	5e                   	pop    %esi
801026bb:	5d                   	pop    %ebp
801026bc:	c3                   	ret    

801026bd <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026bd:	55                   	push   %ebp
801026be:	89 e5                	mov    %esp,%ebp
801026c0:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026c3:	90                   	nop
801026c4:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026cb:	e8 6c ff ff ff       	call   8010263c <inb>
801026d0:	0f b6 c0             	movzbl %al,%eax
801026d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d9:	25 c0 00 00 00       	and    $0xc0,%eax
801026de:	83 f8 40             	cmp    $0x40,%eax
801026e1:	75 e1                	jne    801026c4 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e7:	74 11                	je     801026fa <idewait+0x3d>
801026e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026ec:	83 e0 21             	and    $0x21,%eax
801026ef:	85 c0                	test   %eax,%eax
801026f1:	74 07                	je     801026fa <idewait+0x3d>
    return -1;
801026f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026f8:	eb 05                	jmp    801026ff <idewait+0x42>
  return 0;
801026fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026ff:	c9                   	leave  
80102700:	c3                   	ret    

80102701 <ideinit>:

void
ideinit(void)
{
80102701:	55                   	push   %ebp
80102702:	89 e5                	mov    %esp,%ebp
80102704:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102707:	c7 44 24 04 20 93 10 	movl   $0x80109320,0x4(%esp)
8010270e:	80 
8010270f:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102716:	e8 af 2a 00 00       	call   801051ca <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010271b:	a1 00 52 11 80       	mov    0x80115200,%eax
80102720:	48                   	dec    %eax
80102721:	89 44 24 04          	mov    %eax,0x4(%esp)
80102725:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010272c:	e8 66 04 00 00       	call   80102b97 <ioapicenable>
  idewait(0);
80102731:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102738:	e8 80 ff ff ff       	call   801026bd <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010273d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102744:	00 
80102745:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010274c:	e8 2b ff ff ff       	call   8010267c <outb>
  for(i=0; i<1000; i++){
80102751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102758:	eb 1f                	jmp    80102779 <ideinit+0x78>
    if(inb(0x1f7) != 0){
8010275a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102761:	e8 d6 fe ff ff       	call   8010263c <inb>
80102766:	84 c0                	test   %al,%al
80102768:	74 0c                	je     80102776 <ideinit+0x75>
      havedisk1 = 1;
8010276a:	c7 05 f8 c8 10 80 01 	movl   $0x1,0x8010c8f8
80102771:	00 00 00 
      break;
80102774:	eb 0c                	jmp    80102782 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102776:	ff 45 f4             	incl   -0xc(%ebp)
80102779:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102780:	7e d8                	jle    8010275a <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102782:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102789:	00 
8010278a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102791:	e8 e6 fe ff ff       	call   8010267c <outb>
}
80102796:	c9                   	leave  
80102797:	c3                   	ret    

80102798 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102798:	55                   	push   %ebp
80102799:	89 e5                	mov    %esp,%ebp
8010279b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010279e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027a2:	75 0c                	jne    801027b0 <idestart+0x18>
    panic("idestart");
801027a4:	c7 04 24 24 93 10 80 	movl   $0x80109324,(%esp)
801027ab:	e8 a4 dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801027b0:	8b 45 08             	mov    0x8(%ebp),%eax
801027b3:	8b 40 08             	mov    0x8(%eax),%eax
801027b6:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
801027bb:	76 0c                	jbe    801027c9 <idestart+0x31>
    panic("incorrect blockno");
801027bd:	c7 04 24 2d 93 10 80 	movl   $0x8010932d,(%esp)
801027c4:	e8 8b dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027d0:	8b 45 08             	mov    0x8(%ebp),%eax
801027d3:	8b 50 08             	mov    0x8(%eax),%edx
801027d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d9:	0f af c2             	imul   %edx,%eax
801027dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027df:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027e3:	75 07                	jne    801027ec <idestart+0x54>
801027e5:	b8 20 00 00 00       	mov    $0x20,%eax
801027ea:	eb 05                	jmp    801027f1 <idestart+0x59>
801027ec:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027f4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027f8:	75 07                	jne    80102801 <idestart+0x69>
801027fa:	b8 30 00 00 00       	mov    $0x30,%eax
801027ff:	eb 05                	jmp    80102806 <idestart+0x6e>
80102801:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102806:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102809:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010280d:	7e 0c                	jle    8010281b <idestart+0x83>
8010280f:	c7 04 24 24 93 10 80 	movl   $0x80109324,(%esp)
80102816:	e8 39 dd ff ff       	call   80100554 <panic>

  idewait(0);
8010281b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102822:	e8 96 fe ff ff       	call   801026bd <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102827:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010282e:	00 
8010282f:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102836:	e8 41 fe ff ff       	call   8010267c <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010283b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283e:	0f b6 c0             	movzbl %al,%eax
80102841:	89 44 24 04          	mov    %eax,0x4(%esp)
80102845:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010284c:	e8 2b fe ff ff       	call   8010267c <outb>
  outb(0x1f3, sector & 0xff);
80102851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102854:	0f b6 c0             	movzbl %al,%eax
80102857:	89 44 24 04          	mov    %eax,0x4(%esp)
8010285b:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102862:	e8 15 fe ff ff       	call   8010267c <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010286a:	c1 f8 08             	sar    $0x8,%eax
8010286d:	0f b6 c0             	movzbl %al,%eax
80102870:	89 44 24 04          	mov    %eax,0x4(%esp)
80102874:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010287b:	e8 fc fd ff ff       	call   8010267c <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102883:	c1 f8 10             	sar    $0x10,%eax
80102886:	0f b6 c0             	movzbl %al,%eax
80102889:	89 44 24 04          	mov    %eax,0x4(%esp)
8010288d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102894:	e8 e3 fd ff ff       	call   8010267c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102899:	8b 45 08             	mov    0x8(%ebp),%eax
8010289c:	8b 40 04             	mov    0x4(%eax),%eax
8010289f:	83 e0 01             	and    $0x1,%eax
801028a2:	c1 e0 04             	shl    $0x4,%eax
801028a5:	88 c2                	mov    %al,%dl
801028a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028aa:	c1 f8 18             	sar    $0x18,%eax
801028ad:	83 e0 0f             	and    $0xf,%eax
801028b0:	09 d0                	or     %edx,%eax
801028b2:	83 c8 e0             	or     $0xffffffe0,%eax
801028b5:	0f b6 c0             	movzbl %al,%eax
801028b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028bc:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028c3:	e8 b4 fd ff ff       	call   8010267c <outb>
  if(b->flags & B_DIRTY){
801028c8:	8b 45 08             	mov    0x8(%ebp),%eax
801028cb:	8b 00                	mov    (%eax),%eax
801028cd:	83 e0 04             	and    $0x4,%eax
801028d0:	85 c0                	test   %eax,%eax
801028d2:	74 36                	je     8010290a <idestart+0x172>
    outb(0x1f7, write_cmd);
801028d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028d7:	0f b6 c0             	movzbl %al,%eax
801028da:	89 44 24 04          	mov    %eax,0x4(%esp)
801028de:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028e5:	e8 92 fd ff ff       	call   8010267c <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801028ea:	8b 45 08             	mov    0x8(%ebp),%eax
801028ed:	83 c0 5c             	add    $0x5c,%eax
801028f0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028f7:	00 
801028f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028fc:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102903:	e8 90 fd ff ff       	call   80102698 <outsl>
80102908:	eb 16                	jmp    80102920 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
8010290a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010290d:	0f b6 c0             	movzbl %al,%eax
80102910:	89 44 24 04          	mov    %eax,0x4(%esp)
80102914:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010291b:	e8 5c fd ff ff       	call   8010267c <outb>
  }
}
80102920:	c9                   	leave  
80102921:	c3                   	ret    

80102922 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102922:	55                   	push   %ebp
80102923:	89 e5                	mov    %esp,%ebp
80102925:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102928:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
8010292f:	e8 b7 28 00 00       	call   801051eb <acquire>

  if((b = idequeue) == 0){
80102934:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102939:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010293c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102940:	75 11                	jne    80102953 <ideintr+0x31>
    release(&idelock);
80102942:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102949:	e8 07 29 00 00       	call   80105255 <release>
    return;
8010294e:	e9 90 00 00 00       	jmp    801029e3 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	8b 40 58             	mov    0x58(%eax),%eax
80102959:	a3 f4 c8 10 80       	mov    %eax,0x8010c8f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010295e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102961:	8b 00                	mov    (%eax),%eax
80102963:	83 e0 04             	and    $0x4,%eax
80102966:	85 c0                	test   %eax,%eax
80102968:	75 2e                	jne    80102998 <ideintr+0x76>
8010296a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102971:	e8 47 fd ff ff       	call   801026bd <idewait>
80102976:	85 c0                	test   %eax,%eax
80102978:	78 1e                	js     80102998 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
8010297a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297d:	83 c0 5c             	add    $0x5c,%eax
80102980:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102987:	00 
80102988:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298c:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102993:	e8 bf fc ff ff       	call   80102657 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299b:	8b 00                	mov    (%eax),%eax
8010299d:	83 c8 02             	or     $0x2,%eax
801029a0:	89 c2                	mov    %eax,%edx
801029a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a5:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029aa:	8b 00                	mov    (%eax),%eax
801029ac:	83 e0 fb             	and    $0xfffffffb,%eax
801029af:	89 c2                	mov    %eax,%edx
801029b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b4:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b9:	89 04 24             	mov    %eax,(%esp)
801029bc:	e8 d6 22 00 00       	call   80104c97 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029c1:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
801029c6:	85 c0                	test   %eax,%eax
801029c8:	74 0d                	je     801029d7 <ideintr+0xb5>
    idestart(idequeue);
801029ca:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
801029cf:	89 04 24             	mov    %eax,(%esp)
801029d2:	e8 c1 fd ff ff       	call   80102798 <idestart>

  release(&idelock);
801029d7:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
801029de:	e8 72 28 00 00       	call   80105255 <release>
}
801029e3:	c9                   	leave  
801029e4:	c3                   	ret    

801029e5 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029e5:	55                   	push   %ebp
801029e6:	89 e5                	mov    %esp,%ebp
801029e8:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801029eb:	8b 45 08             	mov    0x8(%ebp),%eax
801029ee:	83 c0 0c             	add    $0xc,%eax
801029f1:	89 04 24             	mov    %eax,(%esp)
801029f4:	e8 6a 27 00 00       	call   80105163 <holdingsleep>
801029f9:	85 c0                	test   %eax,%eax
801029fb:	75 0c                	jne    80102a09 <iderw+0x24>
    panic("iderw: buf not locked");
801029fd:	c7 04 24 3f 93 10 80 	movl   $0x8010933f,(%esp)
80102a04:	e8 4b db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a09:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0c:	8b 00                	mov    (%eax),%eax
80102a0e:	83 e0 06             	and    $0x6,%eax
80102a11:	83 f8 02             	cmp    $0x2,%eax
80102a14:	75 0c                	jne    80102a22 <iderw+0x3d>
    panic("iderw: nothing to do");
80102a16:	c7 04 24 55 93 10 80 	movl   $0x80109355,(%esp)
80102a1d:	e8 32 db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	8b 40 04             	mov    0x4(%eax),%eax
80102a28:	85 c0                	test   %eax,%eax
80102a2a:	74 15                	je     80102a41 <iderw+0x5c>
80102a2c:	a1 f8 c8 10 80       	mov    0x8010c8f8,%eax
80102a31:	85 c0                	test   %eax,%eax
80102a33:	75 0c                	jne    80102a41 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102a35:	c7 04 24 6a 93 10 80 	movl   $0x8010936a,(%esp)
80102a3c:	e8 13 db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a41:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102a48:	e8 9e 27 00 00       	call   801051eb <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a50:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a57:	c7 45 f4 f4 c8 10 80 	movl   $0x8010c8f4,-0xc(%ebp)
80102a5e:	eb 0b                	jmp    80102a6b <iderw+0x86>
80102a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a63:	8b 00                	mov    (%eax),%eax
80102a65:	83 c0 58             	add    $0x58,%eax
80102a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6e:	8b 00                	mov    (%eax),%eax
80102a70:	85 c0                	test   %eax,%eax
80102a72:	75 ec                	jne    80102a60 <iderw+0x7b>
    ;
  *pp = b;
80102a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a77:	8b 55 08             	mov    0x8(%ebp),%edx
80102a7a:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a7c:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102a81:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a84:	75 0d                	jne    80102a93 <iderw+0xae>
    idestart(b);
80102a86:	8b 45 08             	mov    0x8(%ebp),%eax
80102a89:	89 04 24             	mov    %eax,(%esp)
80102a8c:	e8 07 fd ff ff       	call   80102798 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a91:	eb 15                	jmp    80102aa8 <iderw+0xc3>
80102a93:	eb 13                	jmp    80102aa8 <iderw+0xc3>
    sleep(b, &idelock);
80102a95:	c7 44 24 04 c0 c8 10 	movl   $0x8010c8c0,0x4(%esp)
80102a9c:	80 
80102a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa0:	89 04 24             	mov    %eax,(%esp)
80102aa3:	e8 18 21 00 00       	call   80104bc0 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80102aab:	8b 00                	mov    (%eax),%eax
80102aad:	83 e0 06             	and    $0x6,%eax
80102ab0:	83 f8 02             	cmp    $0x2,%eax
80102ab3:	75 e0                	jne    80102a95 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102ab5:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102abc:	e8 94 27 00 00       	call   80105255 <release>
}
80102ac1:	c9                   	leave  
80102ac2:	c3                   	ret    
	...

80102ac4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ac4:	55                   	push   %ebp
80102ac5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ac7:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102acc:	8b 55 08             	mov    0x8(%ebp),%edx
80102acf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ad1:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102ad6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ad9:	5d                   	pop    %ebp
80102ada:	c3                   	ret    

80102adb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102adb:	55                   	push   %ebp
80102adc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ade:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102ae3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ae6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ae8:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102aed:	8b 55 0c             	mov    0xc(%ebp),%edx
80102af0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102af3:	5d                   	pop    %ebp
80102af4:	c3                   	ret    

80102af5 <ioapicinit>:

void
ioapicinit(void)
{
80102af5:	55                   	push   %ebp
80102af6:	89 e5                	mov    %esp,%ebp
80102af8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102afb:	c7 05 34 4b 11 80 00 	movl   $0xfec00000,0x80114b34
80102b02:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b0c:	e8 b3 ff ff ff       	call   80102ac4 <ioapicread>
80102b11:	c1 e8 10             	shr    $0x10,%eax
80102b14:	25 ff 00 00 00       	and    $0xff,%eax
80102b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102b23:	e8 9c ff ff ff       	call   80102ac4 <ioapicread>
80102b28:	c1 e8 18             	shr    $0x18,%eax
80102b2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b2e:	a0 60 4c 11 80       	mov    0x80114c60,%al
80102b33:	0f b6 c0             	movzbl %al,%eax
80102b36:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b39:	74 0c                	je     80102b47 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b3b:	c7 04 24 88 93 10 80 	movl   $0x80109388,(%esp)
80102b42:	e8 7a d8 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b4e:	eb 3d                	jmp    80102b8d <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b53:	83 c0 20             	add    $0x20,%eax
80102b56:	0d 00 00 01 00       	or     $0x10000,%eax
80102b5b:	89 c2                	mov    %eax,%edx
80102b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b60:	83 c0 08             	add    $0x8,%eax
80102b63:	01 c0                	add    %eax,%eax
80102b65:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b69:	89 04 24             	mov    %eax,(%esp)
80102b6c:	e8 6a ff ff ff       	call   80102adb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b74:	83 c0 08             	add    $0x8,%eax
80102b77:	01 c0                	add    %eax,%eax
80102b79:	40                   	inc    %eax
80102b7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b81:	00 
80102b82:	89 04 24             	mov    %eax,(%esp)
80102b85:	e8 51 ff ff ff       	call   80102adb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b8a:	ff 45 f4             	incl   -0xc(%ebp)
80102b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b90:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b93:	7e bb                	jle    80102b50 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b95:	c9                   	leave  
80102b96:	c3                   	ret    

80102b97 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b97:	55                   	push   %ebp
80102b98:	89 e5                	mov    %esp,%ebp
80102b9a:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba0:	83 c0 20             	add    $0x20,%eax
80102ba3:	89 c2                	mov    %eax,%edx
80102ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba8:	83 c0 08             	add    $0x8,%eax
80102bab:	01 c0                	add    %eax,%eax
80102bad:	89 54 24 04          	mov    %edx,0x4(%esp)
80102bb1:	89 04 24             	mov    %eax,(%esp)
80102bb4:	e8 22 ff ff ff       	call   80102adb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bbc:	c1 e0 18             	shl    $0x18,%eax
80102bbf:	8b 55 08             	mov    0x8(%ebp),%edx
80102bc2:	83 c2 08             	add    $0x8,%edx
80102bc5:	01 d2                	add    %edx,%edx
80102bc7:	42                   	inc    %edx
80102bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bcc:	89 14 24             	mov    %edx,(%esp)
80102bcf:	e8 07 ff ff ff       	call   80102adb <ioapicwrite>
}
80102bd4:	c9                   	leave  
80102bd5:	c3                   	ret    
	...

80102bd8 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bd8:	55                   	push   %ebp
80102bd9:	89 e5                	mov    %esp,%ebp
80102bdb:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102bde:	c7 44 24 04 ba 93 10 	movl   $0x801093ba,0x4(%esp)
80102be5:	80 
80102be6:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102bed:	e8 d8 25 00 00       	call   801051ca <initlock>
  kmem.use_lock = 0;
80102bf2:	c7 05 74 4b 11 80 00 	movl   $0x0,0x80114b74
80102bf9:	00 00 00 
  freerange(vstart, vend);
80102bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c03:	8b 45 08             	mov    0x8(%ebp),%eax
80102c06:	89 04 24             	mov    %eax,(%esp)
80102c09:	e8 26 00 00 00       	call   80102c34 <freerange>
}
80102c0e:	c9                   	leave  
80102c0f:	c3                   	ret    

80102c10 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c10:	55                   	push   %ebp
80102c11:	89 e5                	mov    %esp,%ebp
80102c13:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102c16:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c19:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c20:	89 04 24             	mov    %eax,(%esp)
80102c23:	e8 0c 00 00 00       	call   80102c34 <freerange>
  kmem.use_lock = 1;
80102c28:	c7 05 74 4b 11 80 01 	movl   $0x1,0x80114b74
80102c2f:	00 00 00 
}
80102c32:	c9                   	leave  
80102c33:	c3                   	ret    

80102c34 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c34:	55                   	push   %ebp
80102c35:	89 e5                	mov    %esp,%ebp
80102c37:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c3d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c4a:	eb 12                	jmp    80102c5e <freerange+0x2a>
    kfree(p);
80102c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4f:	89 04 24             	mov    %eax,(%esp)
80102c52:	e8 16 00 00 00       	call   80102c6d <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c57:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c61:	05 00 10 00 00       	add    $0x1000,%eax
80102c66:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c69:	76 e1                	jbe    80102c4c <freerange+0x18>
    kfree(p);
}
80102c6b:	c9                   	leave  
80102c6c:	c3                   	ret    

80102c6d <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c6d:	55                   	push   %ebp
80102c6e:	89 e5                	mov    %esp,%ebp
80102c70:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c73:	8b 45 08             	mov    0x8(%ebp),%eax
80102c76:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c7b:	85 c0                	test   %eax,%eax
80102c7d:	75 18                	jne    80102c97 <kfree+0x2a>
80102c7f:	81 7d 08 b0 7c 11 80 	cmpl   $0x80117cb0,0x8(%ebp)
80102c86:	72 0f                	jb     80102c97 <kfree+0x2a>
80102c88:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8b:	05 00 00 00 80       	add    $0x80000000,%eax
80102c90:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c95:	76 0c                	jbe    80102ca3 <kfree+0x36>
    panic("kfree");
80102c97:	c7 04 24 bf 93 10 80 	movl   $0x801093bf,(%esp)
80102c9e:	e8 b1 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ca3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102caa:	00 
80102cab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102cb2:	00 
80102cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb6:	89 04 24             	mov    %eax,(%esp)
80102cb9:	e8 90 27 00 00       	call   8010544e <memset>

  if(kmem.use_lock){
80102cbe:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102cc3:	85 c0                	test   %eax,%eax
80102cc5:	74 0c                	je     80102cd3 <kfree+0x66>
    acquire(&kmem.lock);
80102cc7:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102cce:	e8 18 25 00 00       	call   801051eb <acquire>
    // struct proc *p = initp();
    // cprintf(p->name);
    // cprintf("goodbye \n");
  // }
  }
  r = (struct run*)v;
80102cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cd9:	8b 15 78 4b 11 80    	mov    0x80114b78,%edx
80102cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce7:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102cec:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102cf1:	85 c0                	test   %eax,%eax
80102cf3:	74 0c                	je     80102d01 <kfree+0x94>
    release(&kmem.lock);
80102cf5:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102cfc:	e8 54 25 00 00       	call   80105255 <release>
}
80102d01:	c9                   	leave  
80102d02:	c3                   	ret    

80102d03 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d03:	55                   	push   %ebp
80102d04:	89 e5                	mov    %esp,%ebp
80102d06:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102d09:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d0e:	85 c0                	test   %eax,%eax
80102d10:	74 0c                	je     80102d1e <kalloc+0x1b>
    acquire(&kmem.lock);
80102d12:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d19:	e8 cd 24 00 00       	call   801051eb <acquire>
  }
  r = kmem.freelist;
80102d1e:	a1 78 4b 11 80       	mov    0x80114b78,%eax
80102d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d2a:	74 0a                	je     80102d36 <kalloc+0x33>
    kmem.freelist = r->next;
80102d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2f:	8b 00                	mov    (%eax),%eax
80102d31:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102d36:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102d3b:	85 c0                	test   %eax,%eax
80102d3d:	74 0c                	je     80102d4b <kalloc+0x48>
    release(&kmem.lock);
80102d3f:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d46:	e8 0a 25 00 00       	call   80105255 <release>
  if(r){
80102d4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d4f:	74 3c                	je     80102d8d <kalloc+0x8a>
    if(ticks > 1){
80102d51:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102d56:	83 f8 01             	cmp    $0x1,%eax
80102d59:	76 32                	jbe    80102d8d <kalloc+0x8a>
      int x = find(myproc()->cont->name);
80102d5b:	e8 af 15 00 00       	call   8010430f <myproc>
80102d60:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102d66:	83 c0 18             	add    $0x18,%eax
80102d69:	89 04 24             	mov    %eax,(%esp)
80102d6c:	e8 ae 5e 00 00       	call   80108c1f <find>
80102d71:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102d74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d78:	78 13                	js     80102d8d <kalloc+0x8a>
        set_curr_mem(1, x);
80102d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102d88:	e8 65 61 00 00       	call   80108ef2 <set_curr_mem>
      // cprintf(p->name);
      // cprintf("hello \n");

    }
  }
  return (char*)r;
80102d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d90:	c9                   	leave  
80102d91:	c3                   	ret    
	...

80102d94 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d94:	55                   	push   %ebp
80102d95:	89 e5                	mov    %esp,%ebp
80102d97:	83 ec 14             	sub    $0x14,%esp
80102d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102da4:	89 c2                	mov    %eax,%edx
80102da6:	ec                   	in     (%dx),%al
80102da7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102daa:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102dad:	c9                   	leave  
80102dae:	c3                   	ret    

80102daf <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102daf:	55                   	push   %ebp
80102db0:	89 e5                	mov    %esp,%ebp
80102db2:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102db5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102dbc:	e8 d3 ff ff ff       	call   80102d94 <inb>
80102dc1:	0f b6 c0             	movzbl %al,%eax
80102dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dca:	83 e0 01             	and    $0x1,%eax
80102dcd:	85 c0                	test   %eax,%eax
80102dcf:	75 0a                	jne    80102ddb <kbdgetc+0x2c>
    return -1;
80102dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dd6:	e9 21 01 00 00       	jmp    80102efc <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ddb:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102de2:	e8 ad ff ff ff       	call   80102d94 <inb>
80102de7:	0f b6 c0             	movzbl %al,%eax
80102dea:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ded:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102df4:	75 17                	jne    80102e0d <kbdgetc+0x5e>
    shift |= E0ESC;
80102df6:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102dfb:	83 c8 40             	or     $0x40,%eax
80102dfe:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102e03:	b8 00 00 00 00       	mov    $0x0,%eax
80102e08:	e9 ef 00 00 00       	jmp    80102efc <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e10:	25 80 00 00 00       	and    $0x80,%eax
80102e15:	85 c0                	test   %eax,%eax
80102e17:	74 44                	je     80102e5d <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e19:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e1e:	83 e0 40             	and    $0x40,%eax
80102e21:	85 c0                	test   %eax,%eax
80102e23:	75 08                	jne    80102e2d <kbdgetc+0x7e>
80102e25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e28:	83 e0 7f             	and    $0x7f,%eax
80102e2b:	eb 03                	jmp    80102e30 <kbdgetc+0x81>
80102e2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e30:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e36:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e3b:	8a 00                	mov    (%eax),%al
80102e3d:	83 c8 40             	or     $0x40,%eax
80102e40:	0f b6 c0             	movzbl %al,%eax
80102e43:	f7 d0                	not    %eax
80102e45:	89 c2                	mov    %eax,%edx
80102e47:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e4c:	21 d0                	and    %edx,%eax
80102e4e:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102e53:	b8 00 00 00 00       	mov    $0x0,%eax
80102e58:	e9 9f 00 00 00       	jmp    80102efc <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e5d:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e62:	83 e0 40             	and    $0x40,%eax
80102e65:	85 c0                	test   %eax,%eax
80102e67:	74 14                	je     80102e7d <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e69:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e70:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e75:	83 e0 bf             	and    $0xffffffbf,%eax
80102e78:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  }

  shift |= shiftcode[data];
80102e7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e80:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e85:	8a 00                	mov    (%eax),%al
80102e87:	0f b6 d0             	movzbl %al,%edx
80102e8a:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102e8f:	09 d0                	or     %edx,%eax
80102e91:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  shift ^= togglecode[data];
80102e96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e99:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e9e:	8a 00                	mov    (%eax),%al
80102ea0:	0f b6 d0             	movzbl %al,%edx
80102ea3:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ea8:	31 d0                	xor    %edx,%eax
80102eaa:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102eaf:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102eb4:	83 e0 03             	and    $0x3,%eax
80102eb7:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102ebe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec1:	01 d0                	add    %edx,%eax
80102ec3:	8a 00                	mov    (%eax),%al
80102ec5:	0f b6 c0             	movzbl %al,%eax
80102ec8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ecb:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ed0:	83 e0 08             	and    $0x8,%eax
80102ed3:	85 c0                	test   %eax,%eax
80102ed5:	74 22                	je     80102ef9 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102ed7:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102edb:	76 0c                	jbe    80102ee9 <kbdgetc+0x13a>
80102edd:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ee1:	77 06                	ja     80102ee9 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102ee3:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ee7:	eb 10                	jmp    80102ef9 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ee9:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102eed:	76 0a                	jbe    80102ef9 <kbdgetc+0x14a>
80102eef:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ef3:	77 04                	ja     80102ef9 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ef5:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ef9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102efc:	c9                   	leave  
80102efd:	c3                   	ret    

80102efe <kbdintr>:

void
kbdintr(void)
{
80102efe:	55                   	push   %ebp
80102eff:	89 e5                	mov    %esp,%ebp
80102f01:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f04:	c7 04 24 af 2d 10 80 	movl   $0x80102daf,(%esp)
80102f0b:	e8 e5 d8 ff ff       	call   801007f5 <consoleintr>
}
80102f10:	c9                   	leave  
80102f11:	c3                   	ret    
	...

80102f14 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f14:	55                   	push   %ebp
80102f15:	89 e5                	mov    %esp,%ebp
80102f17:	83 ec 14             	sub    $0x14,%esp
80102f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f1d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f24:	89 c2                	mov    %eax,%edx
80102f26:	ec                   	in     (%dx),%al
80102f27:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f2a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f2d:	c9                   	leave  
80102f2e:	c3                   	ret    

80102f2f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f2f:	55                   	push   %ebp
80102f30:	89 e5                	mov    %esp,%ebp
80102f32:	83 ec 08             	sub    $0x8,%esp
80102f35:	8b 45 08             	mov    0x8(%ebp),%eax
80102f38:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f3b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f3f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f42:	8a 45 f8             	mov    -0x8(%ebp),%al
80102f45:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102f48:	ee                   	out    %al,(%dx)
}
80102f49:	c9                   	leave  
80102f4a:	c3                   	ret    

80102f4b <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f4b:	55                   	push   %ebp
80102f4c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f4e:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102f53:	8b 55 08             	mov    0x8(%ebp),%edx
80102f56:	c1 e2 02             	shl    $0x2,%edx
80102f59:	01 c2                	add    %eax,%edx
80102f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f5e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f60:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102f65:	83 c0 20             	add    $0x20,%eax
80102f68:	8b 00                	mov    (%eax),%eax
}
80102f6a:	5d                   	pop    %ebp
80102f6b:	c3                   	ret    

80102f6c <lapicinit>:

void
lapicinit(void)
{
80102f6c:	55                   	push   %ebp
80102f6d:	89 e5                	mov    %esp,%ebp
80102f6f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102f72:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102f77:	85 c0                	test   %eax,%eax
80102f79:	75 05                	jne    80102f80 <lapicinit+0x14>
    return;
80102f7b:	e9 43 01 00 00       	jmp    801030c3 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f80:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102f87:	00 
80102f88:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102f8f:	e8 b7 ff ff ff       	call   80102f4b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f94:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102f9b:	00 
80102f9c:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102fa3:	e8 a3 ff ff ff       	call   80102f4b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102fa8:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102faf:	00 
80102fb0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fb7:	e8 8f ff ff ff       	call   80102f4b <lapicw>
  lapicw(TICR, 10000000);
80102fbc:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102fc3:	00 
80102fc4:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102fcb:	e8 7b ff ff ff       	call   80102f4b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102fd0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fd7:	00 
80102fd8:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102fdf:	e8 67 ff ff ff       	call   80102f4b <lapicw>
  lapicw(LINT1, MASKED);
80102fe4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102feb:	00 
80102fec:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102ff3:	e8 53 ff ff ff       	call   80102f4b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ff8:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80102ffd:	83 c0 30             	add    $0x30,%eax
80103000:	8b 00                	mov    (%eax),%eax
80103002:	c1 e8 10             	shr    $0x10,%eax
80103005:	0f b6 c0             	movzbl %al,%eax
80103008:	83 f8 03             	cmp    $0x3,%eax
8010300b:	76 14                	jbe    80103021 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
8010300d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103014:	00 
80103015:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
8010301c:	e8 2a ff ff ff       	call   80102f4b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103021:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103028:	00 
80103029:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103030:	e8 16 ff ff ff       	call   80102f4b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103035:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010303c:	00 
8010303d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103044:	e8 02 ff ff ff       	call   80102f4b <lapicw>
  lapicw(ESR, 0);
80103049:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103050:	00 
80103051:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103058:	e8 ee fe ff ff       	call   80102f4b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010305d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103064:	00 
80103065:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010306c:	e8 da fe ff ff       	call   80102f4b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103071:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103078:	00 
80103079:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103080:	e8 c6 fe ff ff       	call   80102f4b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103085:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010308c:	00 
8010308d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103094:	e8 b2 fe ff ff       	call   80102f4b <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103099:	90                   	nop
8010309a:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010309f:	05 00 03 00 00       	add    $0x300,%eax
801030a4:	8b 00                	mov    (%eax),%eax
801030a6:	25 00 10 00 00       	and    $0x1000,%eax
801030ab:	85 c0                	test   %eax,%eax
801030ad:	75 eb                	jne    8010309a <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030b6:	00 
801030b7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801030be:	e8 88 fe ff ff       	call   80102f4b <lapicw>
}
801030c3:	c9                   	leave  
801030c4:	c3                   	ret    

801030c5 <lapicid>:

int
lapicid(void)
{
801030c5:	55                   	push   %ebp
801030c6:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801030c8:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030cd:	85 c0                	test   %eax,%eax
801030cf:	75 07                	jne    801030d8 <lapicid+0x13>
    return 0;
801030d1:	b8 00 00 00 00       	mov    $0x0,%eax
801030d6:	eb 0d                	jmp    801030e5 <lapicid+0x20>
  return lapic[ID] >> 24;
801030d8:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030dd:	83 c0 20             	add    $0x20,%eax
801030e0:	8b 00                	mov    (%eax),%eax
801030e2:	c1 e8 18             	shr    $0x18,%eax
}
801030e5:	5d                   	pop    %ebp
801030e6:	c3                   	ret    

801030e7 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030e7:	55                   	push   %ebp
801030e8:	89 e5                	mov    %esp,%ebp
801030ea:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801030ed:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030f2:	85 c0                	test   %eax,%eax
801030f4:	74 14                	je     8010310a <lapiceoi+0x23>
    lapicw(EOI, 0);
801030f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030fd:	00 
801030fe:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103105:	e8 41 fe ff ff       	call   80102f4b <lapicw>
}
8010310a:	c9                   	leave  
8010310b:	c3                   	ret    

8010310c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010310c:	55                   	push   %ebp
8010310d:	89 e5                	mov    %esp,%ebp
}
8010310f:	5d                   	pop    %ebp
80103110:	c3                   	ret    

80103111 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103111:	55                   	push   %ebp
80103112:	89 e5                	mov    %esp,%ebp
80103114:	83 ec 1c             	sub    $0x1c,%esp
80103117:	8b 45 08             	mov    0x8(%ebp),%eax
8010311a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010311d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103124:	00 
80103125:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010312c:	e8 fe fd ff ff       	call   80102f2f <outb>
  outb(CMOS_PORT+1, 0x0A);
80103131:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103138:	00 
80103139:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103140:	e8 ea fd ff ff       	call   80102f2f <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103145:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010314c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010314f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103154:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103157:	8d 50 02             	lea    0x2(%eax),%edx
8010315a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010315d:	c1 e8 04             	shr    $0x4,%eax
80103160:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103163:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103167:	c1 e0 18             	shl    $0x18,%eax
8010316a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010316e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103175:	e8 d1 fd ff ff       	call   80102f4b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010317a:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103181:	00 
80103182:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103189:	e8 bd fd ff ff       	call   80102f4b <lapicw>
  microdelay(200);
8010318e:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103195:	e8 72 ff ff ff       	call   8010310c <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010319a:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801031a1:	00 
801031a2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031a9:	e8 9d fd ff ff       	call   80102f4b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031ae:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801031b5:	e8 52 ff ff ff       	call   8010310c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031c1:	eb 3f                	jmp    80103202 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801031c3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031c7:	c1 e0 18             	shl    $0x18,%eax
801031ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ce:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031d5:	e8 71 fd ff ff       	call   80102f4b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801031da:	8b 45 0c             	mov    0xc(%ebp),%eax
801031dd:	c1 e8 0c             	shr    $0xc,%eax
801031e0:	80 cc 06             	or     $0x6,%ah
801031e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801031e7:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031ee:	e8 58 fd ff ff       	call   80102f4b <lapicw>
    microdelay(200);
801031f3:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031fa:	e8 0d ff ff ff       	call   8010310c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031ff:	ff 45 fc             	incl   -0x4(%ebp)
80103202:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103206:	7e bb                	jle    801031c3 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103208:	c9                   	leave  
80103209:	c3                   	ret    

8010320a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010320a:	55                   	push   %ebp
8010320b:	89 e5                	mov    %esp,%ebp
8010320d:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103210:	8b 45 08             	mov    0x8(%ebp),%eax
80103213:	0f b6 c0             	movzbl %al,%eax
80103216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010321a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103221:	e8 09 fd ff ff       	call   80102f2f <outb>
  microdelay(200);
80103226:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010322d:	e8 da fe ff ff       	call   8010310c <microdelay>

  return inb(CMOS_RETURN);
80103232:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103239:	e8 d6 fc ff ff       	call   80102f14 <inb>
8010323e:	0f b6 c0             	movzbl %al,%eax
}
80103241:	c9                   	leave  
80103242:	c3                   	ret    

80103243 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103243:	55                   	push   %ebp
80103244:	89 e5                	mov    %esp,%ebp
80103246:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103250:	e8 b5 ff ff ff       	call   8010320a <cmos_read>
80103255:	8b 55 08             	mov    0x8(%ebp),%edx
80103258:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010325a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103261:	e8 a4 ff ff ff       	call   8010320a <cmos_read>
80103266:	8b 55 08             	mov    0x8(%ebp),%edx
80103269:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010326c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103273:	e8 92 ff ff ff       	call   8010320a <cmos_read>
80103278:	8b 55 08             	mov    0x8(%ebp),%edx
8010327b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010327e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103285:	e8 80 ff ff ff       	call   8010320a <cmos_read>
8010328a:	8b 55 08             	mov    0x8(%ebp),%edx
8010328d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103290:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103297:	e8 6e ff ff ff       	call   8010320a <cmos_read>
8010329c:	8b 55 08             	mov    0x8(%ebp),%edx
8010329f:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032a2:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801032a9:	e8 5c ff ff ff       	call   8010320a <cmos_read>
801032ae:	8b 55 08             	mov    0x8(%ebp),%edx
801032b1:	89 42 14             	mov    %eax,0x14(%edx)
}
801032b4:	c9                   	leave  
801032b5:	c3                   	ret    

801032b6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032b6:	55                   	push   %ebp
801032b7:	89 e5                	mov    %esp,%ebp
801032b9:	57                   	push   %edi
801032ba:	56                   	push   %esi
801032bb:	53                   	push   %ebx
801032bc:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032bf:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801032c6:	e8 3f ff ff ff       	call   8010320a <cmos_read>
801032cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032d1:	83 e0 04             	and    $0x4,%eax
801032d4:	85 c0                	test   %eax,%eax
801032d6:	0f 94 c0             	sete   %al
801032d9:	0f b6 c0             	movzbl %al,%eax
801032dc:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032df:	8d 45 c8             	lea    -0x38(%ebp),%eax
801032e2:	89 04 24             	mov    %eax,(%esp)
801032e5:	e8 59 ff ff ff       	call   80103243 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801032ea:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801032f1:	e8 14 ff ff ff       	call   8010320a <cmos_read>
801032f6:	25 80 00 00 00       	and    $0x80,%eax
801032fb:	85 c0                	test   %eax,%eax
801032fd:	74 02                	je     80103301 <cmostime+0x4b>
        continue;
801032ff:	eb 36                	jmp    80103337 <cmostime+0x81>
    fill_rtcdate(&t2);
80103301:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103304:	89 04 24             	mov    %eax,(%esp)
80103307:	e8 37 ff ff ff       	call   80103243 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010330c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103313:	00 
80103314:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103317:	89 44 24 04          	mov    %eax,0x4(%esp)
8010331b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010331e:	89 04 24             	mov    %eax,(%esp)
80103321:	e8 9f 21 00 00       	call   801054c5 <memcmp>
80103326:	85 c0                	test   %eax,%eax
80103328:	75 0d                	jne    80103337 <cmostime+0x81>
      break;
8010332a:	90                   	nop
  }

  // convert
  if(bcd) {
8010332b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010332f:	0f 84 ac 00 00 00    	je     801033e1 <cmostime+0x12b>
80103335:	eb 02                	jmp    80103339 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103337:	eb a6                	jmp    801032df <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103339:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010333c:	c1 e8 04             	shr    $0x4,%eax
8010333f:	89 c2                	mov    %eax,%edx
80103341:	89 d0                	mov    %edx,%eax
80103343:	c1 e0 02             	shl    $0x2,%eax
80103346:	01 d0                	add    %edx,%eax
80103348:	01 c0                	add    %eax,%eax
8010334a:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010334d:	83 e2 0f             	and    $0xf,%edx
80103350:	01 d0                	add    %edx,%eax
80103352:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103355:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103358:	c1 e8 04             	shr    $0x4,%eax
8010335b:	89 c2                	mov    %eax,%edx
8010335d:	89 d0                	mov    %edx,%eax
8010335f:	c1 e0 02             	shl    $0x2,%eax
80103362:	01 d0                	add    %edx,%eax
80103364:	01 c0                	add    %eax,%eax
80103366:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103369:	83 e2 0f             	and    $0xf,%edx
8010336c:	01 d0                	add    %edx,%eax
8010336e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103371:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103374:	c1 e8 04             	shr    $0x4,%eax
80103377:	89 c2                	mov    %eax,%edx
80103379:	89 d0                	mov    %edx,%eax
8010337b:	c1 e0 02             	shl    $0x2,%eax
8010337e:	01 d0                	add    %edx,%eax
80103380:	01 c0                	add    %eax,%eax
80103382:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103385:	83 e2 0f             	and    $0xf,%edx
80103388:	01 d0                	add    %edx,%eax
8010338a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
8010338d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103390:	c1 e8 04             	shr    $0x4,%eax
80103393:	89 c2                	mov    %eax,%edx
80103395:	89 d0                	mov    %edx,%eax
80103397:	c1 e0 02             	shl    $0x2,%eax
8010339a:	01 d0                	add    %edx,%eax
8010339c:	01 c0                	add    %eax,%eax
8010339e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801033a1:	83 e2 0f             	and    $0xf,%edx
801033a4:	01 d0                	add    %edx,%eax
801033a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801033a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033ac:	c1 e8 04             	shr    $0x4,%eax
801033af:	89 c2                	mov    %eax,%edx
801033b1:	89 d0                	mov    %edx,%eax
801033b3:	c1 e0 02             	shl    $0x2,%eax
801033b6:	01 d0                	add    %edx,%eax
801033b8:	01 c0                	add    %eax,%eax
801033ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033bd:	83 e2 0f             	and    $0xf,%edx
801033c0:	01 d0                	add    %edx,%eax
801033c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801033c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033c8:	c1 e8 04             	shr    $0x4,%eax
801033cb:	89 c2                	mov    %eax,%edx
801033cd:	89 d0                	mov    %edx,%eax
801033cf:	c1 e0 02             	shl    $0x2,%eax
801033d2:	01 d0                	add    %edx,%eax
801033d4:	01 c0                	add    %eax,%eax
801033d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033d9:	83 e2 0f             	and    $0xf,%edx
801033dc:	01 d0                	add    %edx,%eax
801033de:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801033e1:	8b 45 08             	mov    0x8(%ebp),%eax
801033e4:	89 c2                	mov    %eax,%edx
801033e6:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801033e9:	b8 06 00 00 00       	mov    $0x6,%eax
801033ee:	89 d7                	mov    %edx,%edi
801033f0:	89 de                	mov    %ebx,%esi
801033f2:	89 c1                	mov    %eax,%ecx
801033f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801033f6:	8b 45 08             	mov    0x8(%ebp),%eax
801033f9:	8b 40 14             	mov    0x14(%eax),%eax
801033fc:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103402:	8b 45 08             	mov    0x8(%ebp),%eax
80103405:	89 50 14             	mov    %edx,0x14(%eax)
}
80103408:	83 c4 5c             	add    $0x5c,%esp
8010340b:	5b                   	pop    %ebx
8010340c:	5e                   	pop    %esi
8010340d:	5f                   	pop    %edi
8010340e:	5d                   	pop    %ebp
8010340f:	c3                   	ret    

80103410 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103410:	55                   	push   %ebp
80103411:	89 e5                	mov    %esp,%ebp
80103413:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103416:	c7 44 24 04 c5 93 10 	movl   $0x801093c5,0x4(%esp)
8010341d:	80 
8010341e:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103425:	e8 a0 1d 00 00       	call   801051ca <initlock>
  readsb(dev, &sb);
8010342a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010342d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103431:	8b 45 08             	mov    0x8(%ebp),%eax
80103434:	89 04 24             	mov    %eax,(%esp)
80103437:	e8 84 e0 ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
8010343c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010343f:	a3 b4 4b 11 80       	mov    %eax,0x80114bb4
  log.size = sb.nlog;
80103444:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103447:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
  log.dev = dev;
8010344c:	8b 45 08             	mov    0x8(%ebp),%eax
8010344f:	a3 c4 4b 11 80       	mov    %eax,0x80114bc4
  recover_from_log();
80103454:	e8 95 01 00 00       	call   801035ee <recover_from_log>
}
80103459:	c9                   	leave  
8010345a:	c3                   	ret    

8010345b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010345b:	55                   	push   %ebp
8010345c:	89 e5                	mov    %esp,%ebp
8010345e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103468:	e9 89 00 00 00       	jmp    801034f6 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010346d:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
80103473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103476:	01 d0                	add    %edx,%eax
80103478:	40                   	inc    %eax
80103479:	89 c2                	mov    %eax,%edx
8010347b:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103480:	89 54 24 04          	mov    %edx,0x4(%esp)
80103484:	89 04 24             	mov    %eax,(%esp)
80103487:	e8 29 cd ff ff       	call   801001b5 <bread>
8010348c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010348f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103492:	83 c0 10             	add    $0x10,%eax
80103495:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010349c:	89 c2                	mov    %eax,%edx
8010349e:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801034a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801034a7:	89 04 24             	mov    %eax,(%esp)
801034aa:	e8 06 cd ff ff       	call   801001b5 <bread>
801034af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	8d 50 5c             	lea    0x5c(%eax),%edx
801034b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034bb:	83 c0 5c             	add    $0x5c,%eax
801034be:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801034c5:	00 
801034c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ca:	89 04 24             	mov    %eax,(%esp)
801034cd:	e8 45 20 00 00       	call   80105517 <memmove>
    bwrite(dbuf);  // write dst to disk
801034d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d5:	89 04 24             	mov    %eax,(%esp)
801034d8:	e8 0f cd ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801034dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e0:	89 04 24             	mov    %eax,(%esp)
801034e3:	e8 44 cd ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801034e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034eb:	89 04 24             	mov    %eax,(%esp)
801034ee:	e8 39 cd ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034f3:	ff 45 f4             	incl   -0xc(%ebp)
801034f6:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801034fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034fe:	0f 8f 69 ff ff ff    	jg     8010346d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103504:	c9                   	leave  
80103505:	c3                   	ret    

80103506 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103506:	55                   	push   %ebp
80103507:	89 e5                	mov    %esp,%ebp
80103509:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010350c:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
80103511:	89 c2                	mov    %eax,%edx
80103513:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103518:	89 54 24 04          	mov    %edx,0x4(%esp)
8010351c:	89 04 24             	mov    %eax,(%esp)
8010351f:	e8 91 cc ff ff       	call   801001b5 <bread>
80103524:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352a:	83 c0 5c             	add    $0x5c,%eax
8010352d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103530:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103533:	8b 00                	mov    (%eax),%eax
80103535:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  for (i = 0; i < log.lh.n; i++) {
8010353a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103541:	eb 1a                	jmp    8010355d <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103543:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103549:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010354d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103550:	83 c2 10             	add    $0x10,%edx
80103553:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010355a:	ff 45 f4             	incl   -0xc(%ebp)
8010355d:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103562:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103565:	7f dc                	jg     80103543 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356a:	89 04 24             	mov    %eax,(%esp)
8010356d:	e8 ba cc ff ff       	call   8010022c <brelse>
}
80103572:	c9                   	leave  
80103573:	c3                   	ret    

80103574 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103574:	55                   	push   %ebp
80103575:	89 e5                	mov    %esp,%ebp
80103577:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010357a:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
8010357f:	89 c2                	mov    %eax,%edx
80103581:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103586:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358a:	89 04 24             	mov    %eax,(%esp)
8010358d:	e8 23 cc ff ff       	call   801001b5 <bread>
80103592:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103598:	83 c0 5c             	add    $0x5c,%eax
8010359b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010359e:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
801035a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035b0:	eb 1a                	jmp    801035cc <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801035b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035b5:	83 c0 10             	add    $0x10,%eax
801035b8:	8b 0c 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%ecx
801035bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035c5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035c9:	ff 45 f4             	incl   -0xc(%ebp)
801035cc:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801035d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035d4:	7f dc                	jg     801035b2 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d9:	89 04 24             	mov    %eax,(%esp)
801035dc:	e8 0b cc ff ff       	call   801001ec <bwrite>
  brelse(buf);
801035e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e4:	89 04 24             	mov    %eax,(%esp)
801035e7:	e8 40 cc ff ff       	call   8010022c <brelse>
}
801035ec:	c9                   	leave  
801035ed:	c3                   	ret    

801035ee <recover_from_log>:

static void
recover_from_log(void)
{
801035ee:	55                   	push   %ebp
801035ef:	89 e5                	mov    %esp,%ebp
801035f1:	83 ec 08             	sub    $0x8,%esp
  read_head();
801035f4:	e8 0d ff ff ff       	call   80103506 <read_head>
  install_trans(); // if committed, copy from log to disk
801035f9:	e8 5d fe ff ff       	call   8010345b <install_trans>
  log.lh.n = 0;
801035fe:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103605:	00 00 00 
  write_head(); // clear the log
80103608:	e8 67 ff ff ff       	call   80103574 <write_head>
}
8010360d:	c9                   	leave  
8010360e:	c3                   	ret    

8010360f <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010360f:	55                   	push   %ebp
80103610:	89 e5                	mov    %esp,%ebp
80103612:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103615:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010361c:	e8 ca 1b 00 00       	call   801051eb <acquire>
  while(1){
    if(log.committing){
80103621:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
80103626:	85 c0                	test   %eax,%eax
80103628:	74 16                	je     80103640 <begin_op+0x31>
      sleep(&log, &log.lock);
8010362a:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
80103631:	80 
80103632:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103639:	e8 82 15 00 00       	call   80104bc0 <sleep>
8010363e:	eb 4d                	jmp    8010368d <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103640:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
80103646:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
8010364b:	8d 48 01             	lea    0x1(%eax),%ecx
8010364e:	89 c8                	mov    %ecx,%eax
80103650:	c1 e0 02             	shl    $0x2,%eax
80103653:	01 c8                	add    %ecx,%eax
80103655:	01 c0                	add    %eax,%eax
80103657:	01 d0                	add    %edx,%eax
80103659:	83 f8 1e             	cmp    $0x1e,%eax
8010365c:	7e 16                	jle    80103674 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010365e:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
80103665:	80 
80103666:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010366d:	e8 4e 15 00 00       	call   80104bc0 <sleep>
80103672:	eb 19                	jmp    8010368d <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103674:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103679:	40                   	inc    %eax
8010367a:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
      release(&log.lock);
8010367f:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103686:	e8 ca 1b 00 00       	call   80105255 <release>
      break;
8010368b:	eb 02                	jmp    8010368f <begin_op+0x80>
    }
  }
8010368d:	eb 92                	jmp    80103621 <begin_op+0x12>
}
8010368f:	c9                   	leave  
80103690:	c3                   	ret    

80103691 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103691:	55                   	push   %ebp
80103692:	89 e5                	mov    %esp,%ebp
80103694:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010369e:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036a5:	e8 41 1b 00 00       	call   801051eb <acquire>
  log.outstanding -= 1;
801036aa:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036af:	48                   	dec    %eax
801036b0:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
  if(log.committing)
801036b5:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
801036ba:	85 c0                	test   %eax,%eax
801036bc:	74 0c                	je     801036ca <end_op+0x39>
    panic("log.committing");
801036be:	c7 04 24 c9 93 10 80 	movl   $0x801093c9,(%esp)
801036c5:	e8 8a ce ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801036ca:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801036cf:	85 c0                	test   %eax,%eax
801036d1:	75 13                	jne    801036e6 <end_op+0x55>
    do_commit = 1;
801036d3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036da:	c7 05 c0 4b 11 80 01 	movl   $0x1,0x80114bc0
801036e1:	00 00 00 
801036e4:	eb 0c                	jmp    801036f2 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801036e6:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036ed:	e8 a5 15 00 00       	call   80104c97 <wakeup>
  }
  release(&log.lock);
801036f2:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801036f9:	e8 57 1b 00 00       	call   80105255 <release>

  if(do_commit){
801036fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103702:	74 33                	je     80103737 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103704:	e8 db 00 00 00       	call   801037e4 <commit>
    acquire(&log.lock);
80103709:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103710:	e8 d6 1a 00 00       	call   801051eb <acquire>
    log.committing = 0;
80103715:	c7 05 c0 4b 11 80 00 	movl   $0x0,0x80114bc0
8010371c:	00 00 00 
    wakeup(&log);
8010371f:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103726:	e8 6c 15 00 00       	call   80104c97 <wakeup>
    release(&log.lock);
8010372b:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103732:	e8 1e 1b 00 00       	call   80105255 <release>
  }
}
80103737:	c9                   	leave  
80103738:	c3                   	ret    

80103739 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103739:	55                   	push   %ebp
8010373a:	89 e5                	mov    %esp,%ebp
8010373c:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010373f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103746:	e9 89 00 00 00       	jmp    801037d4 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010374b:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
80103751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103754:	01 d0                	add    %edx,%eax
80103756:	40                   	inc    %eax
80103757:	89 c2                	mov    %eax,%edx
80103759:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
8010375e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103762:	89 04 24             	mov    %eax,(%esp)
80103765:	e8 4b ca ff ff       	call   801001b5 <bread>
8010376a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010376d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103770:	83 c0 10             	add    $0x10,%eax
80103773:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
8010377a:	89 c2                	mov    %eax,%edx
8010377c:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103781:	89 54 24 04          	mov    %edx,0x4(%esp)
80103785:	89 04 24             	mov    %eax,(%esp)
80103788:	e8 28 ca ff ff       	call   801001b5 <bread>
8010378d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103790:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103793:	8d 50 5c             	lea    0x5c(%eax),%edx
80103796:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103799:	83 c0 5c             	add    $0x5c,%eax
8010379c:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801037a3:	00 
801037a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801037a8:	89 04 24             	mov    %eax,(%esp)
801037ab:	e8 67 1d 00 00       	call   80105517 <memmove>
    bwrite(to);  // write the log
801037b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037b3:	89 04 24             	mov    %eax,(%esp)
801037b6:	e8 31 ca ff ff       	call   801001ec <bwrite>
    brelse(from);
801037bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037be:	89 04 24             	mov    %eax,(%esp)
801037c1:	e8 66 ca ff ff       	call   8010022c <brelse>
    brelse(to);
801037c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037c9:	89 04 24             	mov    %eax,(%esp)
801037cc:	e8 5b ca ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037d1:	ff 45 f4             	incl   -0xc(%ebp)
801037d4:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801037d9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037dc:	0f 8f 69 ff ff ff    	jg     8010374b <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801037e2:	c9                   	leave  
801037e3:	c3                   	ret    

801037e4 <commit>:

static void
commit()
{
801037e4:	55                   	push   %ebp
801037e5:	89 e5                	mov    %esp,%ebp
801037e7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037ea:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801037ef:	85 c0                	test   %eax,%eax
801037f1:	7e 1e                	jle    80103811 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037f3:	e8 41 ff ff ff       	call   80103739 <write_log>
    write_head();    // Write header to disk -- the real commit
801037f8:	e8 77 fd ff ff       	call   80103574 <write_head>
    install_trans(); // Now install writes to home locations
801037fd:	e8 59 fc ff ff       	call   8010345b <install_trans>
    log.lh.n = 0;
80103802:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103809:	00 00 00 
    write_head();    // Erase the transaction from the log
8010380c:	e8 63 fd ff ff       	call   80103574 <write_head>
  }
}
80103811:	c9                   	leave  
80103812:	c3                   	ret    

80103813 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103813:	55                   	push   %ebp
80103814:	89 e5                	mov    %esp,%ebp
80103816:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103819:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010381e:	83 f8 1d             	cmp    $0x1d,%eax
80103821:	7f 10                	jg     80103833 <log_write+0x20>
80103823:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103828:	8b 15 b8 4b 11 80    	mov    0x80114bb8,%edx
8010382e:	4a                   	dec    %edx
8010382f:	39 d0                	cmp    %edx,%eax
80103831:	7c 0c                	jl     8010383f <log_write+0x2c>
    panic("too big a transaction");
80103833:	c7 04 24 d8 93 10 80 	movl   $0x801093d8,(%esp)
8010383a:	e8 15 cd ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
8010383f:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103844:	85 c0                	test   %eax,%eax
80103846:	7f 0c                	jg     80103854 <log_write+0x41>
    panic("log_write outside of trans");
80103848:	c7 04 24 ee 93 10 80 	movl   $0x801093ee,(%esp)
8010384f:	e8 00 cd ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103854:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010385b:	e8 8b 19 00 00       	call   801051eb <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103867:	eb 1e                	jmp    80103887 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010386c:	83 c0 10             	add    $0x10,%eax
8010386f:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
80103876:	89 c2                	mov    %eax,%edx
80103878:	8b 45 08             	mov    0x8(%ebp),%eax
8010387b:	8b 40 08             	mov    0x8(%eax),%eax
8010387e:	39 c2                	cmp    %eax,%edx
80103880:	75 02                	jne    80103884 <log_write+0x71>
      break;
80103882:	eb 0d                	jmp    80103891 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103884:	ff 45 f4             	incl   -0xc(%ebp)
80103887:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010388c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010388f:	7f d8                	jg     80103869 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103891:	8b 45 08             	mov    0x8(%ebp),%eax
80103894:	8b 40 08             	mov    0x8(%eax),%eax
80103897:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010389a:	83 c2 10             	add    $0x10,%edx
8010389d:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
  if (i == log.lh.n)
801038a4:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038a9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ac:	75 0b                	jne    801038b9 <log_write+0xa6>
    log.lh.n++;
801038ae:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801038b3:	40                   	inc    %eax
801038b4:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  b->flags |= B_DIRTY; // prevent eviction
801038b9:	8b 45 08             	mov    0x8(%ebp),%eax
801038bc:	8b 00                	mov    (%eax),%eax
801038be:	83 c8 04             	or     $0x4,%eax
801038c1:	89 c2                	mov    %eax,%edx
801038c3:	8b 45 08             	mov    0x8(%ebp),%eax
801038c6:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038c8:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801038cf:	e8 81 19 00 00       	call   80105255 <release>
}
801038d4:	c9                   	leave  
801038d5:	c3                   	ret    
	...

801038d8 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038d8:	55                   	push   %ebp
801038d9:	89 e5                	mov    %esp,%ebp
801038db:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038de:	8b 55 08             	mov    0x8(%ebp),%edx
801038e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801038e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038e7:	f0 87 02             	lock xchg %eax,(%edx)
801038ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038f0:	c9                   	leave  
801038f1:	c3                   	ret    

801038f2 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038f2:	55                   	push   %ebp
801038f3:	89 e5                	mov    %esp,%ebp
801038f5:	83 e4 f0             	and    $0xfffffff0,%esp
801038f8:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038fb:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103902:	80 
80103903:	c7 04 24 b0 7c 11 80 	movl   $0x80117cb0,(%esp)
8010390a:	e8 c9 f2 ff ff       	call   80102bd8 <kinit1>
  kvmalloc();      // kernel page table
8010390f:	e8 7b 49 00 00       	call   8010828f <kvmalloc>
  mpinit();        // detect other processors
80103914:	e8 cc 03 00 00       	call   80103ce5 <mpinit>
  lapicinit();     // interrupt controller
80103919:	e8 4e f6 ff ff       	call   80102f6c <lapicinit>
  seginit();       // segment descriptors
8010391e:	e8 54 44 00 00       	call   80107d77 <seginit>
  picinit();       // disable pic
80103923:	e8 0c 05 00 00       	call   80103e34 <picinit>
  ioapicinit();    // another interrupt controller
80103928:	e8 c8 f1 ff ff       	call   80102af5 <ioapicinit>
  consoleinit();   // console hardware
8010392d:	e8 bd d2 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103932:	e8 cc 37 00 00       	call   80107103 <uartinit>
  pinit();         // process table
80103937:	e8 ee 08 00 00       	call   8010422a <pinit>
  tvinit();        // trap vectors
8010393c:	e8 8f 33 00 00       	call   80106cd0 <tvinit>
  binit();         // buffer cache
80103941:	e8 ee c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103946:	e8 9b d7 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
8010394b:	e8 b1 ed ff ff       	call   80102701 <ideinit>
  startothers();   // start other processors
80103950:	e8 88 00 00 00       	call   801039dd <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103955:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010395c:	8e 
8010395d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103964:	e8 a7 f2 ff ff       	call   80102c10 <kinit2>
  userinit();      // first user process
80103969:	e8 e6 0a 00 00       	call   80104454 <userinit>
  container_init();
8010396e:	e8 6d 56 00 00       	call   80108fe0 <container_init>
  mpmain();        // finish this processor's setup
80103973:	e8 1a 00 00 00       	call   80103992 <mpmain>

80103978 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
8010397b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010397e:	e8 23 49 00 00       	call   801082a6 <switchkvm>
  seginit();
80103983:	e8 ef 43 00 00       	call   80107d77 <seginit>
  lapicinit();
80103988:	e8 df f5 ff ff       	call   80102f6c <lapicinit>
  mpmain();
8010398d:	e8 00 00 00 00       	call   80103992 <mpmain>

80103992 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103992:	55                   	push   %ebp
80103993:	89 e5                	mov    %esp,%ebp
80103995:	53                   	push   %ebx
80103996:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103999:	e8 a8 08 00 00       	call   80104246 <cpuid>
8010399e:	89 c3                	mov    %eax,%ebx
801039a0:	e8 a1 08 00 00       	call   80104246 <cpuid>
801039a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801039a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801039ad:	c7 04 24 09 94 10 80 	movl   $0x80109409,(%esp)
801039b4:	e8 08 ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801039b9:	e8 6f 34 00 00       	call   80106e2d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039be:	e8 c8 08 00 00       	call   8010428b <mycpu>
801039c3:	05 a0 00 00 00       	add    $0xa0,%eax
801039c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801039cf:	00 
801039d0:	89 04 24             	mov    %eax,(%esp)
801039d3:	e8 00 ff ff ff       	call   801038d8 <xchg>
  scheduler();     // start running processes
801039d8:	e8 16 10 00 00       	call   801049f3 <scheduler>

801039dd <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039dd:	55                   	push   %ebp
801039de:	89 e5                	mov    %esp,%ebp
801039e0:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801039e3:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039ea:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801039f3:	c7 44 24 04 6c c5 10 	movl   $0x8010c56c,0x4(%esp)
801039fa:	80 
801039fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039fe:	89 04 24             	mov    %eax,(%esp)
80103a01:	e8 11 1b 00 00       	call   80105517 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a06:	c7 45 f4 80 4c 11 80 	movl   $0x80114c80,-0xc(%ebp)
80103a0d:	eb 75                	jmp    80103a84 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103a0f:	e8 77 08 00 00       	call   8010428b <mycpu>
80103a14:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a17:	75 02                	jne    80103a1b <startothers+0x3e>
      continue;
80103a19:	eb 62                	jmp    80103a7d <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a1b:	e8 e3 f2 ff ff       	call   80102d03 <kalloc>
80103a20:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a26:	83 e8 04             	sub    $0x4,%eax
80103a29:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a32:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a37:	83 e8 08             	sub    $0x8,%eax
80103a3a:	c7 00 78 39 10 80    	movl   $0x80103978,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a43:	8d 50 f4             	lea    -0xc(%eax),%edx
80103a46:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103a4b:	05 00 00 00 80       	add    $0x80000000,%eax
80103a50:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a55:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	8a 00                	mov    (%eax),%al
80103a60:	0f b6 c0             	movzbl %al,%eax
80103a63:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a67:	89 04 24             	mov    %eax,(%esp)
80103a6a:	e8 a2 f6 ff ff       	call   80103111 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a6f:	90                   	nop
80103a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a73:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a79:	85 c0                	test   %eax,%eax
80103a7b:	74 f3                	je     80103a70 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a7d:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a84:	a1 00 52 11 80       	mov    0x80115200,%eax
80103a89:	89 c2                	mov    %eax,%edx
80103a8b:	89 d0                	mov    %edx,%eax
80103a8d:	c1 e0 02             	shl    $0x2,%eax
80103a90:	01 d0                	add    %edx,%eax
80103a92:	01 c0                	add    %eax,%eax
80103a94:	01 d0                	add    %edx,%eax
80103a96:	c1 e0 04             	shl    $0x4,%eax
80103a99:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103a9e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aa1:	0f 87 68 ff ff ff    	ja     80103a0f <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103aa7:	c9                   	leave  
80103aa8:	c3                   	ret    
80103aa9:	00 00                	add    %al,(%eax)
	...

80103aac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103aac:	55                   	push   %ebp
80103aad:	89 e5                	mov    %esp,%ebp
80103aaf:	83 ec 14             	sub    $0x14,%esp
80103ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ab9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103abc:	89 c2                	mov    %eax,%edx
80103abe:	ec                   	in     (%dx),%al
80103abf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ac2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103ac5:	c9                   	leave  
80103ac6:	c3                   	ret    

80103ac7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ac7:	55                   	push   %ebp
80103ac8:	89 e5                	mov    %esp,%ebp
80103aca:	83 ec 08             	sub    $0x8,%esp
80103acd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ad3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ad7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ada:	8a 45 f8             	mov    -0x8(%ebp),%al
80103add:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ae0:	ee                   	out    %al,(%dx)
}
80103ae1:	c9                   	leave  
80103ae2:	c3                   	ret    

80103ae3 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103ae3:	55                   	push   %ebp
80103ae4:	89 e5                	mov    %esp,%ebp
80103ae6:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103ae9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103af0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103af7:	eb 13                	jmp    80103b0c <sum+0x29>
    sum += addr[i];
80103af9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103afc:	8b 45 08             	mov    0x8(%ebp),%eax
80103aff:	01 d0                	add    %edx,%eax
80103b01:	8a 00                	mov    (%eax),%al
80103b03:	0f b6 c0             	movzbl %al,%eax
80103b06:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b09:	ff 45 fc             	incl   -0x4(%ebp)
80103b0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b0f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b12:	7c e5                	jl     80103af9 <sum+0x16>
    sum += addr[i];
  return sum;
80103b14:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b17:	c9                   	leave  
80103b18:	c3                   	ret    

80103b19 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b19:	55                   	push   %ebp
80103b1a:	89 e5                	mov    %esp,%ebp
80103b1c:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b22:	05 00 00 00 80       	add    $0x80000000,%eax
80103b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	01 d0                	add    %edx,%eax
80103b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b3b:	eb 3f                	jmp    80103b7c <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b3d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b44:	00 
80103b45:	c7 44 24 04 20 94 10 	movl   $0x80109420,0x4(%esp)
80103b4c:	80 
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	89 04 24             	mov    %eax,(%esp)
80103b53:	e8 6d 19 00 00       	call   801054c5 <memcmp>
80103b58:	85 c0                	test   %eax,%eax
80103b5a:	75 1c                	jne    80103b78 <mpsearch1+0x5f>
80103b5c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103b63:	00 
80103b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b67:	89 04 24             	mov    %eax,(%esp)
80103b6a:	e8 74 ff ff ff       	call   80103ae3 <sum>
80103b6f:	84 c0                	test   %al,%al
80103b71:	75 05                	jne    80103b78 <mpsearch1+0x5f>
      return (struct mp*)p;
80103b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b76:	eb 11                	jmp    80103b89 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b78:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b82:	72 b9                	jb     80103b3d <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b89:	c9                   	leave  
80103b8a:	c3                   	ret    

80103b8b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b8b:	55                   	push   %ebp
80103b8c:	89 e5                	mov    %esp,%ebp
80103b8e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b91:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9b:	83 c0 0f             	add    $0xf,%eax
80103b9e:	8a 00                	mov    (%eax),%al
80103ba0:	0f b6 c0             	movzbl %al,%eax
80103ba3:	c1 e0 08             	shl    $0x8,%eax
80103ba6:	89 c2                	mov    %eax,%edx
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	83 c0 0e             	add    $0xe,%eax
80103bae:	8a 00                	mov    (%eax),%al
80103bb0:	0f b6 c0             	movzbl %al,%eax
80103bb3:	09 d0                	or     %edx,%eax
80103bb5:	c1 e0 04             	shl    $0x4,%eax
80103bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bbf:	74 21                	je     80103be2 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103bc1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103bc8:	00 
80103bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcc:	89 04 24             	mov    %eax,(%esp)
80103bcf:	e8 45 ff ff ff       	call   80103b19 <mpsearch1>
80103bd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bd7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bdb:	74 4e                	je     80103c2b <mpsearch+0xa0>
      return mp;
80103bdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103be0:	eb 5d                	jmp    80103c3f <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be5:	83 c0 14             	add    $0x14,%eax
80103be8:	8a 00                	mov    (%eax),%al
80103bea:	0f b6 c0             	movzbl %al,%eax
80103bed:	c1 e0 08             	shl    $0x8,%eax
80103bf0:	89 c2                	mov    %eax,%edx
80103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf5:	83 c0 13             	add    $0x13,%eax
80103bf8:	8a 00                	mov    (%eax),%al
80103bfa:	0f b6 c0             	movzbl %al,%eax
80103bfd:	09 d0                	or     %edx,%eax
80103bff:	c1 e0 0a             	shl    $0xa,%eax
80103c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c08:	2d 00 04 00 00       	sub    $0x400,%eax
80103c0d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c14:	00 
80103c15:	89 04 24             	mov    %eax,(%esp)
80103c18:	e8 fc fe ff ff       	call   80103b19 <mpsearch1>
80103c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c20:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c24:	74 05                	je     80103c2b <mpsearch+0xa0>
      return mp;
80103c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c29:	eb 14                	jmp    80103c3f <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c2b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103c32:	00 
80103c33:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103c3a:	e8 da fe ff ff       	call   80103b19 <mpsearch1>
}
80103c3f:	c9                   	leave  
80103c40:	c3                   	ret    

80103c41 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c41:	55                   	push   %ebp
80103c42:	89 e5                	mov    %esp,%ebp
80103c44:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c47:	e8 3f ff ff ff       	call   80103b8b <mpsearch>
80103c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c53:	74 0a                	je     80103c5f <mpconfig+0x1e>
80103c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c58:	8b 40 04             	mov    0x4(%eax),%eax
80103c5b:	85 c0                	test   %eax,%eax
80103c5d:	75 07                	jne    80103c66 <mpconfig+0x25>
    return 0;
80103c5f:	b8 00 00 00 00       	mov    $0x0,%eax
80103c64:	eb 7d                	jmp    80103ce3 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c69:	8b 40 04             	mov    0x4(%eax),%eax
80103c6c:	05 00 00 00 80       	add    $0x80000000,%eax
80103c71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c74:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103c7b:	00 
80103c7c:	c7 44 24 04 25 94 10 	movl   $0x80109425,0x4(%esp)
80103c83:	80 
80103c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c87:	89 04 24             	mov    %eax,(%esp)
80103c8a:	e8 36 18 00 00       	call   801054c5 <memcmp>
80103c8f:	85 c0                	test   %eax,%eax
80103c91:	74 07                	je     80103c9a <mpconfig+0x59>
    return 0;
80103c93:	b8 00 00 00 00       	mov    $0x0,%eax
80103c98:	eb 49                	jmp    80103ce3 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9d:	8a 40 06             	mov    0x6(%eax),%al
80103ca0:	3c 01                	cmp    $0x1,%al
80103ca2:	74 11                	je     80103cb5 <mpconfig+0x74>
80103ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca7:	8a 40 06             	mov    0x6(%eax),%al
80103caa:	3c 04                	cmp    $0x4,%al
80103cac:	74 07                	je     80103cb5 <mpconfig+0x74>
    return 0;
80103cae:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb3:	eb 2e                	jmp    80103ce3 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb8:	8b 40 04             	mov    0x4(%eax),%eax
80103cbb:	0f b7 c0             	movzwl %ax,%eax
80103cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc5:	89 04 24             	mov    %eax,(%esp)
80103cc8:	e8 16 fe ff ff       	call   80103ae3 <sum>
80103ccd:	84 c0                	test   %al,%al
80103ccf:	74 07                	je     80103cd8 <mpconfig+0x97>
    return 0;
80103cd1:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd6:	eb 0b                	jmp    80103ce3 <mpconfig+0xa2>
  *pmp = mp;
80103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cde:	89 10                	mov    %edx,(%eax)
  return conf;
80103ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103ce3:	c9                   	leave  
80103ce4:	c3                   	ret    

80103ce5 <mpinit>:

void
mpinit(void)
{
80103ce5:	55                   	push   %ebp
80103ce6:	89 e5                	mov    %esp,%ebp
80103ce8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ceb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103cee:	89 04 24             	mov    %eax,(%esp)
80103cf1:	e8 4b ff ff ff       	call   80103c41 <mpconfig>
80103cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cf9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cfd:	75 0c                	jne    80103d0b <mpinit+0x26>
    panic("Expect to run on an SMP");
80103cff:	c7 04 24 2a 94 10 80 	movl   $0x8010942a,(%esp)
80103d06:	e8 49 c8 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d0b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d15:	8b 40 24             	mov    0x24(%eax),%eax
80103d18:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d20:	83 c0 2c             	add    $0x2c,%eax
80103d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d29:	8b 40 04             	mov    0x4(%eax),%eax
80103d2c:	0f b7 d0             	movzwl %ax,%edx
80103d2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d32:	01 d0                	add    %edx,%eax
80103d34:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d37:	eb 7d                	jmp    80103db6 <mpinit+0xd1>
    switch(*p){
80103d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3c:	8a 00                	mov    (%eax),%al
80103d3e:	0f b6 c0             	movzbl %al,%eax
80103d41:	83 f8 04             	cmp    $0x4,%eax
80103d44:	77 68                	ja     80103dae <mpinit+0xc9>
80103d46:	8b 04 85 64 94 10 80 	mov    -0x7fef6b9c(,%eax,4),%eax
80103d4d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d55:	a1 00 52 11 80       	mov    0x80115200,%eax
80103d5a:	83 f8 07             	cmp    $0x7,%eax
80103d5d:	7f 2c                	jg     80103d8b <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d5f:	8b 15 00 52 11 80    	mov    0x80115200,%edx
80103d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d68:	8a 48 01             	mov    0x1(%eax),%cl
80103d6b:	89 d0                	mov    %edx,%eax
80103d6d:	c1 e0 02             	shl    $0x2,%eax
80103d70:	01 d0                	add    %edx,%eax
80103d72:	01 c0                	add    %eax,%eax
80103d74:	01 d0                	add    %edx,%eax
80103d76:	c1 e0 04             	shl    $0x4,%eax
80103d79:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103d7e:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103d80:	a1 00 52 11 80       	mov    0x80115200,%eax
80103d85:	40                   	inc    %eax
80103d86:	a3 00 52 11 80       	mov    %eax,0x80115200
      }
      p += sizeof(struct mpproc);
80103d8b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d8f:	eb 25                	jmp    80103db6 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d94:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d9a:	8a 40 01             	mov    0x1(%eax),%al
80103d9d:	a2 60 4c 11 80       	mov    %al,0x80114c60
      p += sizeof(struct mpioapic);
80103da2:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da6:	eb 0e                	jmp    80103db6 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103da8:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103dac:	eb 08                	jmp    80103db6 <mpinit+0xd1>
    default:
      ismp = 0;
80103dae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103db5:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103dbc:	0f 82 77 ff ff ff    	jb     80103d39 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103dc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dc6:	75 0c                	jne    80103dd4 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103dc8:	c7 04 24 44 94 10 80 	movl   $0x80109444,(%esp)
80103dcf:	e8 80 c7 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103dd4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd7:	8a 40 0c             	mov    0xc(%eax),%al
80103dda:	84 c0                	test   %al,%al
80103ddc:	74 36                	je     80103e14 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dde:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103de5:	00 
80103de6:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103ded:	e8 d5 fc ff ff       	call   80103ac7 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103df2:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103df9:	e8 ae fc ff ff       	call   80103aac <inb>
80103dfe:	83 c8 01             	or     $0x1,%eax
80103e01:	0f b6 c0             	movzbl %al,%eax
80103e04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e08:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e0f:	e8 b3 fc ff ff       	call   80103ac7 <outb>
  }
}
80103e14:	c9                   	leave  
80103e15:	c3                   	ret    
	...

80103e18 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e18:	55                   	push   %ebp
80103e19:	89 e5                	mov    %esp,%ebp
80103e1b:	83 ec 08             	sub    $0x8,%esp
80103e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e21:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103e28:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e2b:	8a 45 f8             	mov    -0x8(%ebp),%al
80103e2e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e31:	ee                   	out    %al,(%dx)
}
80103e32:	c9                   	leave  
80103e33:	c3                   	ret    

80103e34 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e34:	55                   	push   %ebp
80103e35:	89 e5                	mov    %esp,%ebp
80103e37:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e3a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e41:	00 
80103e42:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e49:	e8 ca ff ff ff       	call   80103e18 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e4e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e55:	00 
80103e56:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e5d:	e8 b6 ff ff ff       	call   80103e18 <outb>
}
80103e62:	c9                   	leave  
80103e63:	c3                   	ret    

80103e64 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e64:	55                   	push   %ebp
80103e65:	89 e5                	mov    %esp,%ebp
80103e67:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103e6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e71:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e7d:	8b 10                	mov    (%eax),%edx
80103e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e82:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e84:	e8 79 d2 ff ff       	call   80101102 <filealloc>
80103e89:	8b 55 08             	mov    0x8(%ebp),%edx
80103e8c:	89 02                	mov    %eax,(%edx)
80103e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e91:	8b 00                	mov    (%eax),%eax
80103e93:	85 c0                	test   %eax,%eax
80103e95:	0f 84 c8 00 00 00    	je     80103f63 <pipealloc+0xff>
80103e9b:	e8 62 d2 ff ff       	call   80101102 <filealloc>
80103ea0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ea3:	89 02                	mov    %eax,(%edx)
80103ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea8:	8b 00                	mov    (%eax),%eax
80103eaa:	85 c0                	test   %eax,%eax
80103eac:	0f 84 b1 00 00 00    	je     80103f63 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103eb2:	e8 4c ee ff ff       	call   80102d03 <kalloc>
80103eb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ebe:	75 05                	jne    80103ec5 <pipealloc+0x61>
    goto bad;
80103ec0:	e9 9e 00 00 00       	jmp    80103f63 <pipealloc+0xff>
  p->readopen = 1;
80103ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ecf:	00 00 00 
  p->writeopen = 1;
80103ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103edc:	00 00 00 
  p->nwrite = 0;
80103edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ee9:	00 00 00 
  p->nread = 0;
80103eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eef:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ef6:	00 00 00 
  initlock(&p->lock, "pipe");
80103ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efc:	c7 44 24 04 78 94 10 	movl   $0x80109478,0x4(%esp)
80103f03:	80 
80103f04:	89 04 24             	mov    %eax,(%esp)
80103f07:	e8 be 12 00 00       	call   801051ca <initlock>
  (*f0)->type = FD_PIPE;
80103f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0f:	8b 00                	mov    (%eax),%eax
80103f11:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f17:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1a:	8b 00                	mov    (%eax),%eax
80103f1c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f20:	8b 45 08             	mov    0x8(%ebp),%eax
80103f23:	8b 00                	mov    (%eax),%eax
80103f25:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	8b 00                	mov    (%eax),%eax
80103f2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f31:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f34:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f37:	8b 00                	mov    (%eax),%eax
80103f39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f42:	8b 00                	mov    (%eax),%eax
80103f44:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4b:	8b 00                	mov    (%eax),%eax
80103f4d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f51:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f54:	8b 00                	mov    (%eax),%eax
80103f56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f59:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f5c:	b8 00 00 00 00       	mov    $0x0,%eax
80103f61:	eb 42                	jmp    80103fa5 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103f63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f67:	74 0b                	je     80103f74 <pipealloc+0x110>
    kfree((char*)p);
80103f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6c:	89 04 24             	mov    %eax,(%esp)
80103f6f:	e8 f9 ec ff ff       	call   80102c6d <kfree>
  if(*f0)
80103f74:	8b 45 08             	mov    0x8(%ebp),%eax
80103f77:	8b 00                	mov    (%eax),%eax
80103f79:	85 c0                	test   %eax,%eax
80103f7b:	74 0d                	je     80103f8a <pipealloc+0x126>
    fileclose(*f0);
80103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f80:	8b 00                	mov    (%eax),%eax
80103f82:	89 04 24             	mov    %eax,(%esp)
80103f85:	e8 20 d2 ff ff       	call   801011aa <fileclose>
  if(*f1)
80103f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8d:	8b 00                	mov    (%eax),%eax
80103f8f:	85 c0                	test   %eax,%eax
80103f91:	74 0d                	je     80103fa0 <pipealloc+0x13c>
    fileclose(*f1);
80103f93:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f96:	8b 00                	mov    (%eax),%eax
80103f98:	89 04 24             	mov    %eax,(%esp)
80103f9b:	e8 0a d2 ff ff       	call   801011aa <fileclose>
  return -1;
80103fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fa5:	c9                   	leave  
80103fa6:	c3                   	ret    

80103fa7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fa7:	55                   	push   %ebp
80103fa8:	89 e5                	mov    %esp,%ebp
80103faa:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103fad:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb0:	89 04 24             	mov    %eax,(%esp)
80103fb3:	e8 33 12 00 00       	call   801051eb <acquire>
  if(writable){
80103fb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fbc:	74 1f                	je     80103fdd <pipeclose+0x36>
    p->writeopen = 0;
80103fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fc8:	00 00 00 
    wakeup(&p->nread);
80103fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fce:	05 34 02 00 00       	add    $0x234,%eax
80103fd3:	89 04 24             	mov    %eax,(%esp)
80103fd6:	e8 bc 0c 00 00       	call   80104c97 <wakeup>
80103fdb:	eb 1d                	jmp    80103ffa <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe0:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103fe7:	00 00 00 
    wakeup(&p->nwrite);
80103fea:	8b 45 08             	mov    0x8(%ebp),%eax
80103fed:	05 38 02 00 00       	add    $0x238,%eax
80103ff2:	89 04 24             	mov    %eax,(%esp)
80103ff5:	e8 9d 0c 00 00       	call   80104c97 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104003:	85 c0                	test   %eax,%eax
80104005:	75 25                	jne    8010402c <pipeclose+0x85>
80104007:	8b 45 08             	mov    0x8(%ebp),%eax
8010400a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104010:	85 c0                	test   %eax,%eax
80104012:	75 18                	jne    8010402c <pipeclose+0x85>
    release(&p->lock);
80104014:	8b 45 08             	mov    0x8(%ebp),%eax
80104017:	89 04 24             	mov    %eax,(%esp)
8010401a:	e8 36 12 00 00       	call   80105255 <release>
    kfree((char*)p);
8010401f:	8b 45 08             	mov    0x8(%ebp),%eax
80104022:	89 04 24             	mov    %eax,(%esp)
80104025:	e8 43 ec ff ff       	call   80102c6d <kfree>
8010402a:	eb 0b                	jmp    80104037 <pipeclose+0x90>
  } else
    release(&p->lock);
8010402c:	8b 45 08             	mov    0x8(%ebp),%eax
8010402f:	89 04 24             	mov    %eax,(%esp)
80104032:	e8 1e 12 00 00       	call   80105255 <release>
}
80104037:	c9                   	leave  
80104038:	c3                   	ret    

80104039 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104039:	55                   	push   %ebp
8010403a:	89 e5                	mov    %esp,%ebp
8010403c:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010403f:	8b 45 08             	mov    0x8(%ebp),%eax
80104042:	89 04 24             	mov    %eax,(%esp)
80104045:	e8 a1 11 00 00       	call   801051eb <acquire>
  for(i = 0; i < n; i++){
8010404a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104051:	e9 a3 00 00 00       	jmp    801040f9 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104056:	eb 56                	jmp    801040ae <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80104058:	8b 45 08             	mov    0x8(%ebp),%eax
8010405b:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104061:	85 c0                	test   %eax,%eax
80104063:	74 0c                	je     80104071 <pipewrite+0x38>
80104065:	e8 a5 02 00 00       	call   8010430f <myproc>
8010406a:	8b 40 24             	mov    0x24(%eax),%eax
8010406d:	85 c0                	test   %eax,%eax
8010406f:	74 15                	je     80104086 <pipewrite+0x4d>
        release(&p->lock);
80104071:	8b 45 08             	mov    0x8(%ebp),%eax
80104074:	89 04 24             	mov    %eax,(%esp)
80104077:	e8 d9 11 00 00       	call   80105255 <release>
        return -1;
8010407c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104081:	e9 9d 00 00 00       	jmp    80104123 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104086:	8b 45 08             	mov    0x8(%ebp),%eax
80104089:	05 34 02 00 00       	add    $0x234,%eax
8010408e:	89 04 24             	mov    %eax,(%esp)
80104091:	e8 01 0c 00 00       	call   80104c97 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104096:	8b 45 08             	mov    0x8(%ebp),%eax
80104099:	8b 55 08             	mov    0x8(%ebp),%edx
8010409c:	81 c2 38 02 00 00    	add    $0x238,%edx
801040a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801040a6:	89 14 24             	mov    %edx,(%esp)
801040a9:	e8 12 0b 00 00       	call   80104bc0 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040ae:	8b 45 08             	mov    0x8(%ebp),%eax
801040b1:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040c0:	05 00 02 00 00       	add    $0x200,%eax
801040c5:	39 c2                	cmp    %eax,%edx
801040c7:	74 8f                	je     80104058 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040c9:	8b 45 08             	mov    0x8(%ebp),%eax
801040cc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040d2:	8d 48 01             	lea    0x1(%eax),%ecx
801040d5:	8b 55 08             	mov    0x8(%ebp),%edx
801040d8:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801040de:	25 ff 01 00 00       	and    $0x1ff,%eax
801040e3:	89 c1                	mov    %eax,%ecx
801040e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040eb:	01 d0                	add    %edx,%eax
801040ed:	8a 10                	mov    (%eax),%dl
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801040f6:	ff 45 f4             	incl   -0xc(%ebp)
801040f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fc:	3b 45 10             	cmp    0x10(%ebp),%eax
801040ff:	0f 8c 51 ff ff ff    	jl     80104056 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104105:	8b 45 08             	mov    0x8(%ebp),%eax
80104108:	05 34 02 00 00       	add    $0x234,%eax
8010410d:	89 04 24             	mov    %eax,(%esp)
80104110:	e8 82 0b 00 00       	call   80104c97 <wakeup>
  release(&p->lock);
80104115:	8b 45 08             	mov    0x8(%ebp),%eax
80104118:	89 04 24             	mov    %eax,(%esp)
8010411b:	e8 35 11 00 00       	call   80105255 <release>
  return n;
80104120:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104123:	c9                   	leave  
80104124:	c3                   	ret    

80104125 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104125:	55                   	push   %ebp
80104126:	89 e5                	mov    %esp,%ebp
80104128:	53                   	push   %ebx
80104129:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010412c:	8b 45 08             	mov    0x8(%ebp),%eax
8010412f:	89 04 24             	mov    %eax,(%esp)
80104132:	e8 b4 10 00 00       	call   801051eb <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104137:	eb 39                	jmp    80104172 <piperead+0x4d>
    if(myproc()->killed){
80104139:	e8 d1 01 00 00       	call   8010430f <myproc>
8010413e:	8b 40 24             	mov    0x24(%eax),%eax
80104141:	85 c0                	test   %eax,%eax
80104143:	74 15                	je     8010415a <piperead+0x35>
      release(&p->lock);
80104145:	8b 45 08             	mov    0x8(%ebp),%eax
80104148:	89 04 24             	mov    %eax,(%esp)
8010414b:	e8 05 11 00 00       	call   80105255 <release>
      return -1;
80104150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104155:	e9 b3 00 00 00       	jmp    8010420d <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010415a:	8b 45 08             	mov    0x8(%ebp),%eax
8010415d:	8b 55 08             	mov    0x8(%ebp),%edx
80104160:	81 c2 34 02 00 00    	add    $0x234,%edx
80104166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010416a:	89 14 24             	mov    %edx,(%esp)
8010416d:	e8 4e 0a 00 00       	call   80104bc0 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010417b:	8b 45 08             	mov    0x8(%ebp),%eax
8010417e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104184:	39 c2                	cmp    %eax,%edx
80104186:	75 0d                	jne    80104195 <piperead+0x70>
80104188:	8b 45 08             	mov    0x8(%ebp),%eax
8010418b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104191:	85 c0                	test   %eax,%eax
80104193:	75 a4                	jne    80104139 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010419c:	eb 49                	jmp    801041e7 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041a7:	8b 45 08             	mov    0x8(%ebp),%eax
801041aa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041b0:	39 c2                	cmp    %eax,%edx
801041b2:	75 02                	jne    801041b6 <piperead+0x91>
      break;
801041b4:	eb 39                	jmp    801041ef <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801041bc:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041bf:	8b 45 08             	mov    0x8(%ebp),%eax
801041c2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041c8:	8d 48 01             	lea    0x1(%eax),%ecx
801041cb:	8b 55 08             	mov    0x8(%ebp),%edx
801041ce:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041d4:	25 ff 01 00 00       	and    $0x1ff,%eax
801041d9:	89 c2                	mov    %eax,%edx
801041db:	8b 45 08             	mov    0x8(%ebp),%eax
801041de:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801041e2:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041e4:	ff 45 f4             	incl   -0xc(%ebp)
801041e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801041ed:	7c af                	jl     8010419e <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041ef:	8b 45 08             	mov    0x8(%ebp),%eax
801041f2:	05 38 02 00 00       	add    $0x238,%eax
801041f7:	89 04 24             	mov    %eax,(%esp)
801041fa:	e8 98 0a 00 00       	call   80104c97 <wakeup>
  release(&p->lock);
801041ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104202:	89 04 24             	mov    %eax,(%esp)
80104205:	e8 4b 10 00 00       	call   80105255 <release>
  return i;
8010420a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010420d:	83 c4 24             	add    $0x24,%esp
80104210:	5b                   	pop    %ebx
80104211:	5d                   	pop    %ebp
80104212:	c3                   	ret    
	...

80104214 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104214:	55                   	push   %ebp
80104215:	89 e5                	mov    %esp,%ebp
80104217:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010421a:	9c                   	pushf  
8010421b:	58                   	pop    %eax
8010421c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010421f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104222:	c9                   	leave  
80104223:	c3                   	ret    

80104224 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104224:	55                   	push   %ebp
80104225:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104227:	fb                   	sti    
}
80104228:	5d                   	pop    %ebp
80104229:	c3                   	ret    

8010422a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010422a:	55                   	push   %ebp
8010422b:	89 e5                	mov    %esp,%ebp
8010422d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104230:	c7 44 24 04 80 94 10 	movl   $0x80109480,0x4(%esp)
80104237:	80 
80104238:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010423f:	e8 86 0f 00 00       	call   801051ca <initlock>
}
80104244:	c9                   	leave  
80104245:	c3                   	ret    

80104246 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104246:	55                   	push   %ebp
80104247:	89 e5                	mov    %esp,%ebp
80104249:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010424c:	e8 3a 00 00 00       	call   8010428b <mycpu>
80104251:	89 c2                	mov    %eax,%edx
80104253:	b8 80 4c 11 80       	mov    $0x80114c80,%eax
80104258:	29 c2                	sub    %eax,%edx
8010425a:	89 d0                	mov    %edx,%eax
8010425c:	c1 f8 04             	sar    $0x4,%eax
8010425f:	89 c1                	mov    %eax,%ecx
80104261:	89 ca                	mov    %ecx,%edx
80104263:	c1 e2 03             	shl    $0x3,%edx
80104266:	01 ca                	add    %ecx,%edx
80104268:	89 d0                	mov    %edx,%eax
8010426a:	c1 e0 05             	shl    $0x5,%eax
8010426d:	29 d0                	sub    %edx,%eax
8010426f:	c1 e0 02             	shl    $0x2,%eax
80104272:	01 c8                	add    %ecx,%eax
80104274:	c1 e0 03             	shl    $0x3,%eax
80104277:	01 c8                	add    %ecx,%eax
80104279:	89 c2                	mov    %eax,%edx
8010427b:	c1 e2 0f             	shl    $0xf,%edx
8010427e:	29 c2                	sub    %eax,%edx
80104280:	c1 e2 02             	shl    $0x2,%edx
80104283:	01 ca                	add    %ecx,%edx
80104285:	89 d0                	mov    %edx,%eax
80104287:	f7 d8                	neg    %eax
}
80104289:	c9                   	leave  
8010428a:	c3                   	ret    

8010428b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010428b:	55                   	push   %ebp
8010428c:	89 e5                	mov    %esp,%ebp
8010428e:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104291:	e8 7e ff ff ff       	call   80104214 <readeflags>
80104296:	25 00 02 00 00       	and    $0x200,%eax
8010429b:	85 c0                	test   %eax,%eax
8010429d:	74 0c                	je     801042ab <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010429f:	c7 04 24 88 94 10 80 	movl   $0x80109488,(%esp)
801042a6:	e8 a9 c2 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801042ab:	e8 15 ee ff ff       	call   801030c5 <lapicid>
801042b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042ba:	eb 3b                	jmp    801042f7 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801042bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042bf:	89 d0                	mov    %edx,%eax
801042c1:	c1 e0 02             	shl    $0x2,%eax
801042c4:	01 d0                	add    %edx,%eax
801042c6:	01 c0                	add    %eax,%eax
801042c8:	01 d0                	add    %edx,%eax
801042ca:	c1 e0 04             	shl    $0x4,%eax
801042cd:	05 80 4c 11 80       	add    $0x80114c80,%eax
801042d2:	8a 00                	mov    (%eax),%al
801042d4:	0f b6 c0             	movzbl %al,%eax
801042d7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801042da:	75 18                	jne    801042f4 <mycpu+0x69>
      return &cpus[i];
801042dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042df:	89 d0                	mov    %edx,%eax
801042e1:	c1 e0 02             	shl    $0x2,%eax
801042e4:	01 d0                	add    %edx,%eax
801042e6:	01 c0                	add    %eax,%eax
801042e8:	01 d0                	add    %edx,%eax
801042ea:	c1 e0 04             	shl    $0x4,%eax
801042ed:	05 80 4c 11 80       	add    $0x80114c80,%eax
801042f2:	eb 19                	jmp    8010430d <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042f4:	ff 45 f4             	incl   -0xc(%ebp)
801042f7:	a1 00 52 11 80       	mov    0x80115200,%eax
801042fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042ff:	7c bb                	jl     801042bc <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104301:	c7 04 24 ae 94 10 80 	movl   $0x801094ae,(%esp)
80104308:	e8 47 c2 ff ff       	call   80100554 <panic>
}
8010430d:	c9                   	leave  
8010430e:	c3                   	ret    

8010430f <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010430f:	55                   	push   %ebp
80104310:	89 e5                	mov    %esp,%ebp
80104312:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104315:	e8 30 10 00 00       	call   8010534a <pushcli>
  c = mycpu();
8010431a:	e8 6c ff ff ff       	call   8010428b <mycpu>
8010431f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104325:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010432b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010432e:	e8 61 10 00 00       	call   80105394 <popcli>
  return p;
80104333:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104336:	c9                   	leave  
80104337:	c3                   	ret    

80104338 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104338:	55                   	push   %ebp
80104339:	89 e5                	mov    %esp,%ebp
8010433b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);
8010433e:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104345:	e8 a1 0e 00 00       	call   801051eb <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010434a:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104351:	eb 53                	jmp    801043a6 <allocproc+0x6e>
    if(p->state == UNUSED)
80104353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104356:	8b 40 0c             	mov    0xc(%eax),%eax
80104359:	85 c0                	test   %eax,%eax
8010435b:	75 42                	jne    8010439f <allocproc+0x67>
      goto found;
8010435d:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010435e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104361:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104368:	a1 00 c0 10 80       	mov    0x8010c000,%eax
8010436d:	8d 50 01             	lea    0x1(%eax),%edx
80104370:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104376:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104379:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010437c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104383:	e8 cd 0e 00 00       	call   80105255 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104388:	e8 76 e9 ff ff       	call   80102d03 <kalloc>
8010438d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104390:	89 42 08             	mov    %eax,0x8(%edx)
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	8b 40 08             	mov    0x8(%eax),%eax
80104399:	85 c0                	test   %eax,%eax
8010439b:	75 39                	jne    801043d6 <allocproc+0x9e>
8010439d:	eb 26                	jmp    801043c5 <allocproc+0x8d>
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010439f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801043a6:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801043ad:	72 a4                	jb     80104353 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801043af:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043b6:	e8 9a 0e 00 00       	call   80105255 <release>
  return 0;
801043bb:	b8 00 00 00 00       	mov    $0x0,%eax
801043c0:	e9 8d 00 00 00       	jmp    80104452 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043cf:	b8 00 00 00 00       	mov    $0x0,%eax
801043d4:	eb 7c                	jmp    80104452 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
801043d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d9:	8b 40 08             	mov    0x8(%eax),%eax
801043dc:	05 00 10 00 00       	add    $0x1000,%eax
801043e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043e4:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ee:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043f1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043f5:	ba 8c 6c 10 80       	mov    $0x80106c8c,%edx
801043fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043fd:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043ff:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104406:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104409:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010440c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104412:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104419:	00 
8010441a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104421:	00 
80104422:	89 04 24             	mov    %eax,(%esp)
80104425:	e8 24 10 00 00       	call   8010544e <memset>
  p->context->eip = (uint)forkret;
8010442a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104430:	ba 81 4b 10 80       	mov    $0x80104b81,%edx
80104435:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443b:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
80104442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104445:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010444c:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
8010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104452:	c9                   	leave  
80104453:	c3                   	ret    

80104454 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104454:	55                   	push   %ebp
80104455:	89 e5                	mov    %esp,%ebp
80104457:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010445a:	e8 d9 fe ff ff       	call   80104338 <allocproc>
8010445f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	a3 00 c9 10 80       	mov    %eax,0x8010c900
  if((p->pgdir = setupkvm()) == 0)
8010446a:	e8 77 3d 00 00       	call   801081e6 <setupkvm>
8010446f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104472:	89 42 04             	mov    %eax,0x4(%edx)
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	8b 40 04             	mov    0x4(%eax),%eax
8010447b:	85 c0                	test   %eax,%eax
8010447d:	75 0c                	jne    8010448b <userinit+0x37>
    panic("userinit: out of memory?");
8010447f:	c7 04 24 be 94 10 80 	movl   $0x801094be,(%esp)
80104486:	e8 c9 c0 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010448b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104493:	8b 40 04             	mov    0x4(%eax),%eax
80104496:	89 54 24 08          	mov    %edx,0x8(%esp)
8010449a:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
801044a1:	80 
801044a2:	89 04 24             	mov    %eax,(%esp)
801044a5:	e8 9d 3f 00 00       	call   80108447 <inituvm>
  p->sz = PGSIZE;
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b6:	8b 40 18             	mov    0x18(%eax),%eax
801044b9:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044c0:	00 
801044c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044c8:	00 
801044c9:	89 04 24             	mov    %eax,(%esp)
801044cc:	e8 7d 0f 00 00       	call   8010544e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d4:	8b 40 18             	mov    0x18(%eax),%eax
801044d7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e0:	8b 40 18             	mov    0x18(%eax),%eax
801044e3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ec:	8b 50 18             	mov    0x18(%eax),%edx
801044ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f2:	8b 40 18             	mov    0x18(%eax),%eax
801044f5:	8b 40 2c             	mov    0x2c(%eax),%eax
801044f8:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ff:	8b 50 18             	mov    0x18(%eax),%edx
80104502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104505:	8b 40 18             	mov    0x18(%eax),%eax
80104508:	8b 40 2c             	mov    0x2c(%eax),%eax
8010450b:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
8010450f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104512:	8b 40 18             	mov    0x18(%eax),%eax
80104515:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010451c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451f:	8b 40 18             	mov    0x18(%eax),%eax
80104522:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 18             	mov    0x18(%eax),%eax
8010452f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	83 c0 6c             	add    $0x6c,%eax
8010453c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104543:	00 
80104544:	c7 44 24 04 d7 94 10 	movl   $0x801094d7,0x4(%esp)
8010454b:	80 
8010454c:	89 04 24             	mov    %eax,(%esp)
8010454f:	e8 06 11 00 00       	call   8010565a <safestrcpy>
  p->cwd = namei("/");
80104554:	c7 04 24 e0 94 10 80 	movl   $0x801094e0,(%esp)
8010455b:	e8 97 e0 ff ff       	call   801025f7 <namei>
80104560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104563:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104566:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010456d:	e8 79 0c 00 00       	call   801051eb <acquire>

  p->state = RUNNABLE;
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010457c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104583:	e8 cd 0c 00 00       	call   80105255 <release>
}
80104588:	c9                   	leave  
80104589:	c3                   	ret    

8010458a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010458a:	55                   	push   %ebp
8010458b:	89 e5                	mov    %esp,%ebp
8010458d:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104590:	e8 7a fd ff ff       	call   8010430f <myproc>
80104595:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010459b:	8b 00                	mov    (%eax),%eax
8010459d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045a4:	7e 31                	jle    801045d7 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045a6:	8b 55 08             	mov    0x8(%ebp),%edx
801045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ac:	01 c2                	add    %eax,%edx
801045ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045b1:	8b 40 04             	mov    0x4(%eax),%eax
801045b4:	89 54 24 08          	mov    %edx,0x8(%esp)
801045b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801045bf:	89 04 24             	mov    %eax,(%esp)
801045c2:	e8 eb 3f 00 00       	call   801085b2 <allocuvm>
801045c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ce:	75 3e                	jne    8010460e <growproc+0x84>
      return -1;
801045d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d5:	eb 4f                	jmp    80104626 <growproc+0x9c>
  } else if(n < 0){
801045d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045db:	79 31                	jns    8010460e <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045dd:	8b 55 08             	mov    0x8(%ebp),%edx
801045e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e3:	01 c2                	add    %eax,%edx
801045e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045e8:	8b 40 04             	mov    0x4(%eax),%eax
801045eb:	89 54 24 08          	mov    %edx,0x8(%esp)
801045ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801045f6:	89 04 24             	mov    %eax,(%esp)
801045f9:	e8 ca 40 00 00       	call   801086c8 <deallocuvm>
801045fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104601:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104605:	75 07                	jne    8010460e <growproc+0x84>
      return -1;
80104607:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460c:	eb 18                	jmp    80104626 <growproc+0x9c>
  }
  curproc->sz = sz;
8010460e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104619:	89 04 24             	mov    %eax,(%esp)
8010461c:	e8 9f 3c 00 00       	call   801082c0 <switchuvm>
  return 0;
80104621:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104626:	c9                   	leave  
80104627:	c3                   	ret    

80104628 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104628:	55                   	push   %ebp
80104629:	89 e5                	mov    %esp,%ebp
8010462b:	57                   	push   %edi
8010462c:	56                   	push   %esi
8010462d:	53                   	push   %ebx
8010462e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104631:	e8 d9 fc ff ff       	call   8010430f <myproc>
80104636:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104639:	e8 fa fc ff ff       	call   80104338 <allocproc>
8010463e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104641:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104645:	75 0a                	jne    80104651 <fork+0x29>
    return -1;
80104647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464c:	e9 47 01 00 00       	jmp    80104798 <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104651:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104654:	8b 10                	mov    (%eax),%edx
80104656:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104659:	8b 40 04             	mov    0x4(%eax),%eax
8010465c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104660:	89 04 24             	mov    %eax,(%esp)
80104663:	e8 00 42 00 00       	call   80108868 <copyuvm>
80104668:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010466b:	89 42 04             	mov    %eax,0x4(%edx)
8010466e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104671:	8b 40 04             	mov    0x4(%eax),%eax
80104674:	85 c0                	test   %eax,%eax
80104676:	75 2c                	jne    801046a4 <fork+0x7c>
    kfree(np->kstack);
80104678:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010467b:	8b 40 08             	mov    0x8(%eax),%eax
8010467e:	89 04 24             	mov    %eax,(%esp)
80104681:	e8 e7 e5 ff ff       	call   80102c6d <kfree>
    np->kstack = 0;
80104686:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104689:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104690:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104693:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010469a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010469f:	e9 f4 00 00 00       	jmp    80104798 <fork+0x170>
  }
  np->sz = curproc->sz;
801046a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a7:	8b 10                	mov    (%eax),%edx
801046a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ac:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801046ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046b4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ba:	8b 50 18             	mov    0x18(%eax),%edx
801046bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c0:	8b 40 18             	mov    0x18(%eax),%eax
801046c3:	89 c3                	mov    %eax,%ebx
801046c5:	b8 13 00 00 00       	mov    $0x13,%eax
801046ca:	89 d7                	mov    %edx,%edi
801046cc:	89 de                	mov    %ebx,%esi
801046ce:	89 c1                	mov    %eax,%ecx
801046d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d5:	8b 40 18             	mov    0x18(%eax),%eax
801046d8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046e6:	eb 36                	jmp    8010471e <fork+0xf6>
    if(curproc->ofile[i])
801046e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046ee:	83 c2 08             	add    $0x8,%edx
801046f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f5:	85 c0                	test   %eax,%eax
801046f7:	74 22                	je     8010471b <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046ff:	83 c2 08             	add    $0x8,%edx
80104702:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104706:	89 04 24             	mov    %eax,(%esp)
80104709:	e8 54 ca ff ff       	call   80101162 <filedup>
8010470e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104711:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104714:	83 c1 08             	add    $0x8,%ecx
80104717:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010471b:	ff 45 e4             	incl   -0x1c(%ebp)
8010471e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104722:	7e c4                	jle    801046e8 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104724:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104727:	8b 40 68             	mov    0x68(%eax),%eax
8010472a:	89 04 24             	mov    %eax,(%esp)
8010472d:	e8 5e d3 ff ff       	call   80101a90 <idup>
80104732:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104735:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104738:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010473e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104741:	83 c0 6c             	add    $0x6c,%eax
80104744:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010474b:	00 
8010474c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104750:	89 04 24             	mov    %eax,(%esp)
80104753:	e8 02 0f 00 00       	call   8010565a <safestrcpy>



  pid = np->pid;
80104758:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010475b:	8b 40 10             	mov    0x10(%eax),%eax
8010475e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104761:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104768:	e8 7e 0a 00 00       	call   801051eb <acquire>

  np->state = RUNNABLE;
8010476d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104770:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
80104777:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104780:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104783:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
80104789:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104790:	e8 c0 0a 00 00       	call   80105255 <release>

  return pid;
80104795:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104798:	83 c4 2c             	add    $0x2c,%esp
8010479b:	5b                   	pop    %ebx
8010479c:	5e                   	pop    %esi
8010479d:	5f                   	pop    %edi
8010479e:	5d                   	pop    %ebp
8010479f:	c3                   	ret    

801047a0 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047a0:	55                   	push   %ebp
801047a1:	89 e5                	mov    %esp,%ebp
801047a3:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801047a6:	e8 64 fb ff ff       	call   8010430f <myproc>
801047ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801047ae:	a1 00 c9 10 80       	mov    0x8010c900,%eax
801047b3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047b6:	75 0c                	jne    801047c4 <exit+0x24>
    panic("init exiting");
801047b8:	c7 04 24 e2 94 10 80 	movl   $0x801094e2,(%esp)
801047bf:	e8 90 bd ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047cb:	eb 3a                	jmp    80104807 <exit+0x67>
    if(curproc->ofile[fd]){
801047cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047d3:	83 c2 08             	add    $0x8,%edx
801047d6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047da:	85 c0                	test   %eax,%eax
801047dc:	74 26                	je     80104804 <exit+0x64>
      fileclose(curproc->ofile[fd]);
801047de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047e4:	83 c2 08             	add    $0x8,%edx
801047e7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047eb:	89 04 24             	mov    %eax,(%esp)
801047ee:	e8 b7 c9 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
801047f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047f9:	83 c2 08             	add    $0x8,%edx
801047fc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104803:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104804:	ff 45 f0             	incl   -0x10(%ebp)
80104807:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010480b:	7e c0                	jle    801047cd <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010480d:	e8 fd ed ff ff       	call   8010360f <begin_op>
  iput(curproc->cwd);
80104812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104815:	8b 40 68             	mov    0x68(%eax),%eax
80104818:	89 04 24             	mov    %eax,(%esp)
8010481b:	e8 f0 d3 ff ff       	call   80101c10 <iput>
  end_op();
80104820:	e8 6c ee ff ff       	call   80103691 <end_op>
  curproc->cwd = 0;
80104825:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104828:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010482f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104836:	e8 b0 09 00 00       	call   801051eb <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010483b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010483e:	8b 40 14             	mov    0x14(%eax),%eax
80104841:	89 04 24             	mov    %eax,(%esp)
80104844:	e8 0d 04 00 00       	call   80104c56 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104849:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104850:	eb 36                	jmp    80104888 <exit+0xe8>
    if(p->parent == curproc){
80104852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104855:	8b 40 14             	mov    0x14(%eax),%eax
80104858:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010485b:	75 24                	jne    80104881 <exit+0xe1>
      p->parent = initproc;
8010485d:	8b 15 00 c9 10 80    	mov    0x8010c900,%edx
80104863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104866:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486c:	8b 40 0c             	mov    0xc(%eax),%eax
8010486f:	83 f8 05             	cmp    $0x5,%eax
80104872:	75 0d                	jne    80104881 <exit+0xe1>
        wakeup1(initproc);
80104874:	a1 00 c9 10 80       	mov    0x8010c900,%eax
80104879:	89 04 24             	mov    %eax,(%esp)
8010487c:	e8 d5 03 00 00       	call   80104c56 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104881:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104888:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
8010488f:	72 c1                	jb     80104852 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104891:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104894:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010489b:	e8 01 02 00 00       	call   80104aa1 <sched>
  panic("zombie exit");
801048a0:	c7 04 24 ef 94 10 80 	movl   $0x801094ef,(%esp)
801048a7:	e8 a8 bc ff ff       	call   80100554 <panic>

801048ac <strcmp1>:
}

int
strcmp1(const char *p, const char *q)
{
801048ac:	55                   	push   %ebp
801048ad:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801048af:	eb 06                	jmp    801048b7 <strcmp1+0xb>
    p++, q++;
801048b1:	ff 45 08             	incl   0x8(%ebp)
801048b4:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
801048b7:	8b 45 08             	mov    0x8(%ebp),%eax
801048ba:	8a 00                	mov    (%eax),%al
801048bc:	84 c0                	test   %al,%al
801048be:	74 0e                	je     801048ce <strcmp1+0x22>
801048c0:	8b 45 08             	mov    0x8(%ebp),%eax
801048c3:	8a 10                	mov    (%eax),%dl
801048c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801048c8:	8a 00                	mov    (%eax),%al
801048ca:	38 c2                	cmp    %al,%dl
801048cc:	74 e3                	je     801048b1 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801048ce:	8b 45 08             	mov    0x8(%ebp),%eax
801048d1:	8a 00                	mov    (%eax),%al
801048d3:	0f b6 d0             	movzbl %al,%edx
801048d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801048d9:	8a 00                	mov    (%eax),%al
801048db:	0f b6 c0             	movzbl %al,%eax
801048de:	29 c2                	sub    %eax,%edx
801048e0:	89 d0                	mov    %edx,%eax
}
801048e2:	5d                   	pop    %ebp
801048e3:	c3                   	ret    

801048e4 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048e4:	55                   	push   %ebp
801048e5:	89 e5                	mov    %esp,%ebp
801048e7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048ea:	e8 20 fa ff ff       	call   8010430f <myproc>
801048ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801048f2:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801048f9:	e8 ed 08 00 00       	call   801051eb <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801048fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104905:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
8010490c:	e9 98 00 00 00       	jmp    801049a9 <wait+0xc5>
      if(p->parent != curproc)
80104911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104914:	8b 40 14             	mov    0x14(%eax),%eax
80104917:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010491a:	74 05                	je     80104921 <wait+0x3d>
        continue;
8010491c:	e9 81 00 00 00       	jmp    801049a2 <wait+0xbe>
      havekids = 1;
80104921:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492b:	8b 40 0c             	mov    0xc(%eax),%eax
8010492e:	83 f8 05             	cmp    $0x5,%eax
80104931:	75 6f                	jne    801049a2 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104936:	8b 40 10             	mov    0x10(%eax),%eax
80104939:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 40 08             	mov    0x8(%eax),%eax
80104942:	89 04 24             	mov    %eax,(%esp)
80104945:	e8 23 e3 ff ff       	call   80102c6d <kfree>
        p->kstack = 0;
8010494a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104957:	8b 40 04             	mov    0x4(%eax),%eax
8010495a:	89 04 24             	mov    %eax,(%esp)
8010495d:	e8 2a 3e 00 00       	call   8010878c <freevm>
        p->pid = 0;
80104962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104965:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010496c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104979:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104980:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104991:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104998:	e8 b8 08 00 00       	call   80105255 <release>
        return pid;
8010499d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049a0:	eb 4f                	jmp    801049f1 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049a2:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049a9:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801049b0:	0f 82 5b ff ff ff    	jb     80104911 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049ba:	74 0a                	je     801049c6 <wait+0xe2>
801049bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049bf:	8b 40 24             	mov    0x24(%eax),%eax
801049c2:	85 c0                	test   %eax,%eax
801049c4:	74 13                	je     801049d9 <wait+0xf5>
      release(&ptable.lock);
801049c6:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801049cd:	e8 83 08 00 00       	call   80105255 <release>
      return -1;
801049d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049d7:	eb 18                	jmp    801049f1 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801049d9:	c7 44 24 04 20 52 11 	movl   $0x80115220,0x4(%esp)
801049e0:	80 
801049e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049e4:	89 04 24             	mov    %eax,(%esp)
801049e7:	e8 d4 01 00 00       	call   80104bc0 <sleep>
  }
801049ec:	e9 0d ff ff ff       	jmp    801048fe <wait+0x1a>
}
801049f1:	c9                   	leave  
801049f2:	c3                   	ret    

801049f3 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801049f3:	55                   	push   %ebp
801049f4:	89 e5                	mov    %esp,%ebp
801049f6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801049f9:	e8 8d f8 ff ff       	call   8010428b <mycpu>
801049fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a04:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a0b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a0e:	e8 11 f8 ff ff       	call   80104224 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a13:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a1a:	e8 cc 07 00 00       	call   801051eb <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a1f:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104a26:	eb 5f                	jmp    80104a87 <scheduler+0x94>
      if(p->state != RUNNABLE)
80104a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2b:	8b 40 0c             	mov    0xc(%eax),%eax
80104a2e:	83 f8 03             	cmp    $0x3,%eax
80104a31:	74 02                	je     80104a35 <scheduler+0x42>
        continue;
80104a33:	eb 4b                	jmp    80104a80 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a3b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a44:	89 04 24             	mov    %eax,(%esp)
80104a47:	e8 74 38 00 00       	call   801082c0 <switchuvm>
      p->state = RUNNING;
80104a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a59:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a5f:	83 c2 04             	add    $0x4,%edx
80104a62:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a66:	89 14 24             	mov    %edx,(%esp)
80104a69:	e8 5a 0c 00 00       	call   801056c8 <swtch>
      switchkvm();
80104a6e:	e8 33 38 00 00       	call   801082a6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a76:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a7d:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a80:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a87:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104a8e:	72 98                	jb     80104a28 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104a90:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a97:	e8 b9 07 00 00       	call   80105255 <release>

  }
80104a9c:	e9 6d ff ff ff       	jmp    80104a0e <scheduler+0x1b>

80104aa1 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104aa1:	55                   	push   %ebp
80104aa2:	89 e5                	mov    %esp,%ebp
80104aa4:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104aa7:	e8 63 f8 ff ff       	call   8010430f <myproc>
80104aac:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104aaf:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104ab6:	e8 5e 08 00 00       	call   80105319 <holding>
80104abb:	85 c0                	test   %eax,%eax
80104abd:	75 0c                	jne    80104acb <sched+0x2a>
    panic("sched ptable.lock");
80104abf:	c7 04 24 fb 94 10 80 	movl   $0x801094fb,(%esp)
80104ac6:	e8 89 ba ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104acb:	e8 bb f7 ff ff       	call   8010428b <mycpu>
80104ad0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ad6:	83 f8 01             	cmp    $0x1,%eax
80104ad9:	74 0c                	je     80104ae7 <sched+0x46>
    panic("sched locks");
80104adb:	c7 04 24 0d 95 10 80 	movl   $0x8010950d,(%esp)
80104ae2:	e8 6d ba ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aea:	8b 40 0c             	mov    0xc(%eax),%eax
80104aed:	83 f8 04             	cmp    $0x4,%eax
80104af0:	75 0c                	jne    80104afe <sched+0x5d>
    panic("sched running");
80104af2:	c7 04 24 19 95 10 80 	movl   $0x80109519,(%esp)
80104af9:	e8 56 ba ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104afe:	e8 11 f7 ff ff       	call   80104214 <readeflags>
80104b03:	25 00 02 00 00       	and    $0x200,%eax
80104b08:	85 c0                	test   %eax,%eax
80104b0a:	74 0c                	je     80104b18 <sched+0x77>
    panic("sched interruptible");
80104b0c:	c7 04 24 27 95 10 80 	movl   $0x80109527,(%esp)
80104b13:	e8 3c ba ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104b18:	e8 6e f7 ff ff       	call   8010428b <mycpu>
80104b1d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b26:	e8 60 f7 ff ff       	call   8010428b <mycpu>
80104b2b:	8b 40 04             	mov    0x4(%eax),%eax
80104b2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b31:	83 c2 1c             	add    $0x1c,%edx
80104b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b38:	89 14 24             	mov    %edx,(%esp)
80104b3b:	e8 88 0b 00 00       	call   801056c8 <swtch>
  mycpu()->intena = intena;
80104b40:	e8 46 f7 ff ff       	call   8010428b <mycpu>
80104b45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b48:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104b4e:	c9                   	leave  
80104b4f:	c3                   	ret    

80104b50 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b50:	55                   	push   %ebp
80104b51:	89 e5                	mov    %esp,%ebp
80104b53:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b56:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b5d:	e8 89 06 00 00       	call   801051eb <acquire>
  myproc()->state = RUNNABLE;
80104b62:	e8 a8 f7 ff ff       	call   8010430f <myproc>
80104b67:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b6e:	e8 2e ff ff ff       	call   80104aa1 <sched>
  release(&ptable.lock);
80104b73:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b7a:	e8 d6 06 00 00       	call   80105255 <release>
}
80104b7f:	c9                   	leave  
80104b80:	c3                   	ret    

80104b81 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b81:	55                   	push   %ebp
80104b82:	89 e5                	mov    %esp,%ebp
80104b84:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b87:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b8e:	e8 c2 06 00 00       	call   80105255 <release>

  if (first) {
80104b93:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b98:	85 c0                	test   %eax,%eax
80104b9a:	74 22                	je     80104bbe <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b9c:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104ba3:	00 00 00 
    iinit(ROOTDEV);
80104ba6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bad:	e8 a9 cb ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104bb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bb9:	e8 52 e8 ff ff       	call   80103410 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104bbe:	c9                   	leave  
80104bbf:	c3                   	ret    

80104bc0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
80104bc3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104bc6:	e8 44 f7 ff ff       	call   8010430f <myproc>
80104bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104bce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bd2:	75 0c                	jne    80104be0 <sleep+0x20>
    panic("sleep");
80104bd4:	c7 04 24 3b 95 10 80 	movl   $0x8010953b,(%esp)
80104bdb:	e8 74 b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104be0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104be4:	75 0c                	jne    80104bf2 <sleep+0x32>
    panic("sleep without lk");
80104be6:	c7 04 24 41 95 10 80 	movl   $0x80109541,(%esp)
80104bed:	e8 62 b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104bf2:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104bf9:	74 17                	je     80104c12 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104bfb:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c02:	e8 e4 05 00 00       	call   801051eb <acquire>
    release(lk);
80104c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c0a:	89 04 24             	mov    %eax,(%esp)
80104c0d:	e8 43 06 00 00       	call   80105255 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c15:	8b 55 08             	mov    0x8(%ebp),%edx
80104c18:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c25:	e8 77 fe ff ff       	call   80104aa1 <sched>

  // Tidy up.
  p->chan = 0;
80104c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c34:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104c3b:	74 17                	je     80104c54 <sleep+0x94>
    release(&ptable.lock);
80104c3d:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c44:	e8 0c 06 00 00       	call   80105255 <release>
    acquire(lk);
80104c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4c:	89 04 24             	mov    %eax,(%esp)
80104c4f:	e8 97 05 00 00       	call   801051eb <acquire>
  }
}
80104c54:	c9                   	leave  
80104c55:	c3                   	ret    

80104c56 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c56:	55                   	push   %ebp
80104c57:	89 e5                	mov    %esp,%ebp
80104c59:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c5c:	c7 45 fc 54 52 11 80 	movl   $0x80115254,-0x4(%ebp)
80104c63:	eb 27                	jmp    80104c8c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104c65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c68:	8b 40 0c             	mov    0xc(%eax),%eax
80104c6b:	83 f8 02             	cmp    $0x2,%eax
80104c6e:	75 15                	jne    80104c85 <wakeup1+0x2f>
80104c70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c73:	8b 40 20             	mov    0x20(%eax),%eax
80104c76:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c79:	75 0a                	jne    80104c85 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c7e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c85:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104c8c:	81 7d fc 54 73 11 80 	cmpl   $0x80117354,-0x4(%ebp)
80104c93:	72 d0                	jb     80104c65 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c95:	c9                   	leave  
80104c96:	c3                   	ret    

80104c97 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c97:	55                   	push   %ebp
80104c98:	89 e5                	mov    %esp,%ebp
80104c9a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c9d:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104ca4:	e8 42 05 00 00       	call   801051eb <acquire>
  wakeup1(chan);
80104ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cac:	89 04 24             	mov    %eax,(%esp)
80104caf:	e8 a2 ff ff ff       	call   80104c56 <wakeup1>
  release(&ptable.lock);
80104cb4:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cbb:	e8 95 05 00 00       	call   80105255 <release>
}
80104cc0:	c9                   	leave  
80104cc1:	c3                   	ret    

80104cc2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cc2:	55                   	push   %ebp
80104cc3:	89 e5                	mov    %esp,%ebp
80104cc5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104cc8:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104ccf:	e8 17 05 00 00       	call   801051eb <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd4:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104cdb:	eb 44                	jmp    80104d21 <kill+0x5f>
    if(p->pid == pid){
80104cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce0:	8b 40 10             	mov    0x10(%eax),%eax
80104ce3:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ce6:	75 32                	jne    80104d1a <kill+0x58>
      p->killed = 1;
80104ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ceb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf5:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf8:	83 f8 02             	cmp    $0x2,%eax
80104cfb:	75 0a                	jne    80104d07 <kill+0x45>
        p->state = RUNNABLE;
80104cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d00:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d07:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d0e:	e8 42 05 00 00       	call   80105255 <release>
      return 0;
80104d13:	b8 00 00 00 00       	mov    $0x0,%eax
80104d18:	eb 21                	jmp    80104d3b <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d1a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d21:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104d28:	72 b3                	jb     80104cdd <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d2a:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d31:	e8 1f 05 00 00       	call   80105255 <release>
  return -1;
80104d36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d3b:	c9                   	leave  
80104d3c:	c3                   	ret    

80104d3d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d3d:	55                   	push   %ebp
80104d3e:	89 e5                	mov    %esp,%ebp
80104d40:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d43:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104d4a:	e9 1e 01 00 00       	jmp    80104e6d <procdump+0x130>
    if(p->state == UNUSED)
80104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d52:	8b 40 0c             	mov    0xc(%eax),%eax
80104d55:	85 c0                	test   %eax,%eax
80104d57:	75 05                	jne    80104d5e <procdump+0x21>
      continue;
80104d59:	e9 08 01 00 00       	jmp    80104e66 <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d61:	8b 40 0c             	mov    0xc(%eax),%eax
80104d64:	83 f8 05             	cmp    $0x5,%eax
80104d67:	77 23                	ja     80104d8c <procdump+0x4f>
80104d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d6c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d6f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d76:	85 c0                	test   %eax,%eax
80104d78:	74 12                	je     80104d8c <procdump+0x4f>
      state = states[p->state];
80104d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d7d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d80:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d8a:	eb 07                	jmp    80104d93 <procdump+0x56>
    else
      state = "???";
80104d8c:	c7 45 ec 52 95 10 80 	movl   $0x80109552,-0x14(%ebp)

    if(p->cont == NULL){
80104d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d96:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d9c:	85 c0                	test   %eax,%eax
80104d9e:	75 29                	jne    80104dc9 <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da3:	8d 50 6c             	lea    0x6c(%eax),%edx
80104da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da9:	8b 40 10             	mov    0x10(%eax),%eax
80104dac:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104db0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104db3:	89 54 24 08          	mov    %edx,0x8(%esp)
80104db7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dbb:	c7 04 24 56 95 10 80 	movl   $0x80109556,(%esp)
80104dc2:	e8 fa b5 ff ff       	call   801003c1 <cprintf>
80104dc7:	eb 37                	jmp    80104e00 <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dcc:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104dd8:	8d 48 18             	lea    0x18(%eax),%ecx
80104ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dde:	8b 40 10             	mov    0x10(%eax),%eax
80104de1:	89 54 24 10          	mov    %edx,0x10(%esp)
80104de5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104de8:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104dec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104df0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104df4:	c7 04 24 64 95 10 80 	movl   $0x80109564,(%esp)
80104dfb:	e8 c1 b5 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80104e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e03:	8b 40 0c             	mov    0xc(%eax),%eax
80104e06:	83 f8 02             	cmp    $0x2,%eax
80104e09:	75 4f                	jne    80104e5a <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e0e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e11:	8b 40 0c             	mov    0xc(%eax),%eax
80104e14:	83 c0 08             	add    $0x8,%eax
80104e17:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e1e:	89 04 24             	mov    %eax,(%esp)
80104e21:	e8 7c 04 00 00       	call   801052a2 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e2d:	eb 1a                	jmp    80104e49 <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e32:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e36:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e3a:	c7 04 24 70 95 10 80 	movl   $0x80109570,(%esp)
80104e41:	e8 7b b5 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e46:	ff 45 f4             	incl   -0xc(%ebp)
80104e49:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e4d:	7f 0b                	jg     80104e5a <procdump+0x11d>
80104e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e52:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e56:	85 c0                	test   %eax,%eax
80104e58:	75 d5                	jne    80104e2f <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e5a:	c7 04 24 74 95 10 80 	movl   $0x80109574,(%esp)
80104e61:	e8 5b b5 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e66:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e6d:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80104e74:	0f 82 d5 fe ff ff    	jb     80104d4f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e7a:	c9                   	leave  
80104e7b:	c3                   	ret    

80104e7c <cstop_container_helper>:

void cstop_container_helper(struct container* cont){
80104e7c:	55                   	push   %ebp
80104e7d:	89 e5                	mov    %esp,%ebp
80104e7f:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  // cprintf("In procdump\n.");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e82:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104e89:	eb 37                	jmp    80104ec2 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
80104e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8e:	8d 50 18             	lea    0x18(%eax),%edx
80104e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e94:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104e9a:	83 c0 18             	add    $0x18,%eax
80104e9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ea1:	89 04 24             	mov    %eax,(%esp)
80104ea4:	e8 03 fa ff ff       	call   801048ac <strcmp1>
80104ea9:	85 c0                	test   %eax,%eax
80104eab:	75 0e                	jne    80104ebb <cstop_container_helper+0x3f>
      kill(p->pid);
80104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb0:	8b 40 10             	mov    0x10(%eax),%eax
80104eb3:	89 04 24             	mov    %eax,(%esp)
80104eb6:	e8 07 fe ff ff       	call   80104cc2 <kill>

void cstop_container_helper(struct container* cont){

  struct proc *p;
  // cprintf("In procdump\n.");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ebb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ec2:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104ec9:	72 c0                	jb     80104e8b <cstop_container_helper+0xf>

    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }
}
80104ecb:	c9                   	leave  
80104ecc:	c3                   	ret    

80104ecd <cstop_helper>:

void cstop_helper(char* name){
80104ecd:	55                   	push   %ebp
80104ece:	89 e5                	mov    %esp,%ebp
80104ed0:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed3:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104eda:	eb 69                	jmp    80104f45 <cstop_helper+0x78>

    if(p->cont == NULL){
80104edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104edf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104ee5:	85 c0                	test   %eax,%eax
80104ee7:	75 02                	jne    80104eeb <cstop_helper+0x1e>
      continue;
80104ee9:	eb 53                	jmp    80104f3e <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
80104eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eee:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104ef4:	8d 50 18             	lea    0x18(%eax),%edx
80104ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80104efa:	89 44 24 04          	mov    %eax,0x4(%esp)
80104efe:	89 14 24             	mov    %edx,(%esp)
80104f01:	e8 a6 f9 ff ff       	call   801048ac <strcmp1>
80104f06:	85 c0                	test   %eax,%eax
80104f08:	75 34                	jne    80104f3e <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80104f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0d:	8b 40 10             	mov    0x10(%eax),%eax
80104f10:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f13:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
80104f19:	83 c2 18             	add    $0x18,%edx
80104f1c:	89 44 24 08          	mov    %eax,0x8(%esp)
80104f20:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f24:	c7 04 24 78 95 10 80 	movl   $0x80109578,(%esp)
80104f2b:	e8 91 b4 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
80104f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f33:	8b 40 10             	mov    0x10(%eax),%eax
80104f36:	89 04 24             	mov    %eax,(%esp)
80104f39:	e8 84 fd ff ff       	call   80104cc2 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f3e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104f45:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104f4c:	72 8e                	jb     80104edc <cstop_helper+0xf>
    }
  }



}
80104f4e:	c9                   	leave  
80104f4f:	c3                   	ret    

80104f50 <c_procdump>:



void
c_procdump(char* name)
{
80104f50:	55                   	push   %ebp
80104f51:	89 e5                	mov    %esp,%ebp
80104f53:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f56:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104f5d:	e9 0f 01 00 00       	jmp    80105071 <c_procdump+0x121>

    // if(p->cont == NULL){
    //   cprintf("p_cont is null in %s.\n", name);
    // }
    if(p->state == UNUSED || p->cont == NULL)
80104f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f65:	8b 40 0c             	mov    0xc(%eax),%eax
80104f68:	85 c0                	test   %eax,%eax
80104f6a:	74 0d                	je     80104f79 <c_procdump+0x29>
80104f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f75:	85 c0                	test   %eax,%eax
80104f77:	75 05                	jne    80104f7e <c_procdump+0x2e>
      continue;
80104f79:	e9 ec 00 00 00       	jmp    8010506a <c_procdump+0x11a>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f81:	8b 40 0c             	mov    0xc(%eax),%eax
80104f84:	83 f8 05             	cmp    $0x5,%eax
80104f87:	77 23                	ja     80104fac <c_procdump+0x5c>
80104f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f8f:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80104f96:	85 c0                	test   %eax,%eax
80104f98:	74 12                	je     80104fac <c_procdump+0x5c>
      state = states[p->state];
80104f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9d:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa0:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80104fa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104faa:	eb 07                	jmp    80104fb3 <c_procdump+0x63>
    else
      state = "???";
80104fac:	c7 45 ec 52 95 10 80 	movl   $0x80109552,-0x14(%ebp)

    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
80104fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fbc:	8d 50 18             	lea    0x18(%eax),%edx
80104fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fc6:	89 14 24             	mov    %edx,(%esp)
80104fc9:	e8 de f8 ff ff       	call   801048ac <strcmp1>
80104fce:	85 c0                	test   %eax,%eax
80104fd0:	0f 85 94 00 00 00    	jne    8010506a <c_procdump+0x11a>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
80104fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd9:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdf:	8b 40 10             	mov    0x10(%eax),%eax
80104fe2:	89 54 24 10          	mov    %edx,0x10(%esp)
80104fe6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fe9:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fed:	8b 55 08             	mov    0x8(%ebp),%edx
80104ff0:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ff8:	c7 04 24 64 95 10 80 	movl   $0x80109564,(%esp)
80104fff:	e8 bd b3 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
80105004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105007:	8b 40 0c             	mov    0xc(%eax),%eax
8010500a:	83 f8 02             	cmp    $0x2,%eax
8010500d:	75 4f                	jne    8010505e <c_procdump+0x10e>
        getcallerpcs((uint*)p->context->ebp+2, pc);
8010500f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105012:	8b 40 1c             	mov    0x1c(%eax),%eax
80105015:	8b 40 0c             	mov    0xc(%eax),%eax
80105018:	83 c0 08             	add    $0x8,%eax
8010501b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010501e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105022:	89 04 24             	mov    %eax,(%esp)
80105025:	e8 78 02 00 00       	call   801052a2 <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
8010502a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105031:	eb 1a                	jmp    8010504d <c_procdump+0xfd>
          cprintf(" %p", pc[i]);
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010503a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010503e:	c7 04 24 70 95 10 80 	movl   $0x80109570,(%esp)
80105045:	e8 77 b3 ff ff       	call   801003c1 <cprintf>
    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
8010504a:	ff 45 f4             	incl   -0xc(%ebp)
8010504d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105051:	7f 0b                	jg     8010505e <c_procdump+0x10e>
80105053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105056:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010505a:	85 c0                	test   %eax,%eax
8010505c:	75 d5                	jne    80105033 <c_procdump+0xe3>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
8010505e:	c7 04 24 74 95 10 80 	movl   $0x80109574,(%esp)
80105065:	e8 57 b3 ff ff       	call   801003c1 <cprintf>
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010506a:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105071:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80105078:	0f 82 e4 fe ff ff    	jb     80104f62 <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
8010507e:	c9                   	leave  
8010507f:	c3                   	ret    

80105080 <initp>:



struct proc* initp(void){
80105080:	55                   	push   %ebp
80105081:	89 e5                	mov    %esp,%ebp
  return initproc;
80105083:	a1 00 c9 10 80       	mov    0x8010c900,%eax
}
80105088:	5d                   	pop    %ebp
80105089:	c3                   	ret    
	...

8010508c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105092:	8b 45 08             	mov    0x8(%ebp),%eax
80105095:	83 c0 04             	add    $0x4,%eax
80105098:	c7 44 24 04 c2 95 10 	movl   $0x801095c2,0x4(%esp)
8010509f:	80 
801050a0:	89 04 24             	mov    %eax,(%esp)
801050a3:	e8 22 01 00 00       	call   801051ca <initlock>
  lk->name = name;
801050a8:	8b 45 08             	mov    0x8(%ebp),%eax
801050ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801050ae:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801050b1:	8b 45 08             	mov    0x8(%ebp),%eax
801050b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050ba:	8b 45 08             	mov    0x8(%ebp),%eax
801050bd:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801050c4:	c9                   	leave  
801050c5:	c3                   	ret    

801050c6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801050c6:	55                   	push   %ebp
801050c7:	89 e5                	mov    %esp,%ebp
801050c9:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801050cc:	8b 45 08             	mov    0x8(%ebp),%eax
801050cf:	83 c0 04             	add    $0x4,%eax
801050d2:	89 04 24             	mov    %eax,(%esp)
801050d5:	e8 11 01 00 00       	call   801051eb <acquire>
  while (lk->locked) {
801050da:	eb 15                	jmp    801050f1 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
801050dc:	8b 45 08             	mov    0x8(%ebp),%eax
801050df:	83 c0 04             	add    $0x4,%eax
801050e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801050e6:	8b 45 08             	mov    0x8(%ebp),%eax
801050e9:	89 04 24             	mov    %eax,(%esp)
801050ec:	e8 cf fa ff ff       	call   80104bc0 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
801050f1:	8b 45 08             	mov    0x8(%ebp),%eax
801050f4:	8b 00                	mov    (%eax),%eax
801050f6:	85 c0                	test   %eax,%eax
801050f8:	75 e2                	jne    801050dc <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
801050fa:	8b 45 08             	mov    0x8(%ebp),%eax
801050fd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105103:	e8 07 f2 ff ff       	call   8010430f <myproc>
80105108:	8b 50 10             	mov    0x10(%eax),%edx
8010510b:	8b 45 08             	mov    0x8(%ebp),%eax
8010510e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105111:	8b 45 08             	mov    0x8(%ebp),%eax
80105114:	83 c0 04             	add    $0x4,%eax
80105117:	89 04 24             	mov    %eax,(%esp)
8010511a:	e8 36 01 00 00       	call   80105255 <release>
}
8010511f:	c9                   	leave  
80105120:	c3                   	ret    

80105121 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105121:	55                   	push   %ebp
80105122:	89 e5                	mov    %esp,%ebp
80105124:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105127:	8b 45 08             	mov    0x8(%ebp),%eax
8010512a:	83 c0 04             	add    $0x4,%eax
8010512d:	89 04 24             	mov    %eax,(%esp)
80105130:	e8 b6 00 00 00       	call   801051eb <acquire>
  lk->locked = 0;
80105135:	8b 45 08             	mov    0x8(%ebp),%eax
80105138:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010513e:	8b 45 08             	mov    0x8(%ebp),%eax
80105141:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105148:	8b 45 08             	mov    0x8(%ebp),%eax
8010514b:	89 04 24             	mov    %eax,(%esp)
8010514e:	e8 44 fb ff ff       	call   80104c97 <wakeup>
  release(&lk->lk);
80105153:	8b 45 08             	mov    0x8(%ebp),%eax
80105156:	83 c0 04             	add    $0x4,%eax
80105159:	89 04 24             	mov    %eax,(%esp)
8010515c:	e8 f4 00 00 00       	call   80105255 <release>
}
80105161:	c9                   	leave  
80105162:	c3                   	ret    

80105163 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105163:	55                   	push   %ebp
80105164:	89 e5                	mov    %esp,%ebp
80105166:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	83 c0 04             	add    $0x4,%eax
8010516f:	89 04 24             	mov    %eax,(%esp)
80105172:	e8 74 00 00 00       	call   801051eb <acquire>
  r = lk->locked;
80105177:	8b 45 08             	mov    0x8(%ebp),%eax
8010517a:	8b 00                	mov    (%eax),%eax
8010517c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010517f:	8b 45 08             	mov    0x8(%ebp),%eax
80105182:	83 c0 04             	add    $0x4,%eax
80105185:	89 04 24             	mov    %eax,(%esp)
80105188:	e8 c8 00 00 00       	call   80105255 <release>
  return r;
8010518d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105190:	c9                   	leave  
80105191:	c3                   	ret    
	...

80105194 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105194:	55                   	push   %ebp
80105195:	89 e5                	mov    %esp,%ebp
80105197:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010519a:	9c                   	pushf  
8010519b:	58                   	pop    %eax
8010519c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010519f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051a2:	c9                   	leave  
801051a3:	c3                   	ret    

801051a4 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801051a4:	55                   	push   %ebp
801051a5:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801051a7:	fa                   	cli    
}
801051a8:	5d                   	pop    %ebp
801051a9:	c3                   	ret    

801051aa <sti>:

static inline void
sti(void)
{
801051aa:	55                   	push   %ebp
801051ab:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801051ad:	fb                   	sti    
}
801051ae:	5d                   	pop    %ebp
801051af:	c3                   	ret    

801051b0 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801051b6:	8b 55 08             	mov    0x8(%ebp),%edx
801051b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051bf:	f0 87 02             	lock xchg %eax,(%edx)
801051c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801051c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051c8:	c9                   	leave  
801051c9:	c3                   	ret    

801051ca <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051ca:	55                   	push   %ebp
801051cb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051cd:	8b 45 08             	mov    0x8(%ebp),%eax
801051d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801051d3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051df:	8b 45 08             	mov    0x8(%ebp),%eax
801051e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051e9:	5d                   	pop    %ebp
801051ea:	c3                   	ret    

801051eb <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051eb:	55                   	push   %ebp
801051ec:	89 e5                	mov    %esp,%ebp
801051ee:	53                   	push   %ebx
801051ef:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051f2:	e8 53 01 00 00       	call   8010534a <pushcli>
  if(holding(lk))
801051f7:	8b 45 08             	mov    0x8(%ebp),%eax
801051fa:	89 04 24             	mov    %eax,(%esp)
801051fd:	e8 17 01 00 00       	call   80105319 <holding>
80105202:	85 c0                	test   %eax,%eax
80105204:	74 0c                	je     80105212 <acquire+0x27>
    panic("acquire");
80105206:	c7 04 24 cd 95 10 80 	movl   $0x801095cd,(%esp)
8010520d:	e8 42 b3 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105212:	90                   	nop
80105213:	8b 45 08             	mov    0x8(%ebp),%eax
80105216:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010521d:	00 
8010521e:	89 04 24             	mov    %eax,(%esp)
80105221:	e8 8a ff ff ff       	call   801051b0 <xchg>
80105226:	85 c0                	test   %eax,%eax
80105228:	75 e9                	jne    80105213 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010522a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010522f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105232:	e8 54 f0 ff ff       	call   8010428b <mycpu>
80105237:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010523a:	8b 45 08             	mov    0x8(%ebp),%eax
8010523d:	83 c0 0c             	add    $0xc,%eax
80105240:	89 44 24 04          	mov    %eax,0x4(%esp)
80105244:	8d 45 08             	lea    0x8(%ebp),%eax
80105247:	89 04 24             	mov    %eax,(%esp)
8010524a:	e8 53 00 00 00       	call   801052a2 <getcallerpcs>
}
8010524f:	83 c4 14             	add    $0x14,%esp
80105252:	5b                   	pop    %ebx
80105253:	5d                   	pop    %ebp
80105254:	c3                   	ret    

80105255 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105255:	55                   	push   %ebp
80105256:	89 e5                	mov    %esp,%ebp
80105258:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010525b:	8b 45 08             	mov    0x8(%ebp),%eax
8010525e:	89 04 24             	mov    %eax,(%esp)
80105261:	e8 b3 00 00 00       	call   80105319 <holding>
80105266:	85 c0                	test   %eax,%eax
80105268:	75 0c                	jne    80105276 <release+0x21>
    panic("release");
8010526a:	c7 04 24 d5 95 10 80 	movl   $0x801095d5,(%esp)
80105271:	e8 de b2 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80105276:	8b 45 08             	mov    0x8(%ebp),%eax
80105279:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105280:	8b 45 08             	mov    0x8(%ebp),%eax
80105283:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010528a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010528f:	8b 45 08             	mov    0x8(%ebp),%eax
80105292:	8b 55 08             	mov    0x8(%ebp),%edx
80105295:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010529b:	e8 f4 00 00 00       	call   80105394 <popcli>
}
801052a0:	c9                   	leave  
801052a1:	c3                   	ret    

801052a2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801052a2:	55                   	push   %ebp
801052a3:	89 e5                	mov    %esp,%ebp
801052a5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801052a8:	8b 45 08             	mov    0x8(%ebp),%eax
801052ab:	83 e8 08             	sub    $0x8,%eax
801052ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052b1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052b8:	eb 37                	jmp    801052f1 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052be:	74 37                	je     801052f7 <getcallerpcs+0x55>
801052c0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801052c7:	76 2e                	jbe    801052f7 <getcallerpcs+0x55>
801052c9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801052cd:	74 28                	je     801052f7 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
801052cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052dc:	01 c2                	add    %eax,%edx
801052de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e1:	8b 40 04             	mov    0x4(%eax),%eax
801052e4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e9:	8b 00                	mov    (%eax),%eax
801052eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052ee:	ff 45 f8             	incl   -0x8(%ebp)
801052f1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052f5:	7e c3                	jle    801052ba <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052f7:	eb 18                	jmp    80105311 <getcallerpcs+0x6f>
    pcs[i] = 0;
801052f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105303:	8b 45 0c             	mov    0xc(%ebp),%eax
80105306:	01 d0                	add    %edx,%eax
80105308:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010530e:	ff 45 f8             	incl   -0x8(%ebp)
80105311:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105315:	7e e2                	jle    801052f9 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105317:	c9                   	leave  
80105318:	c3                   	ret    

80105319 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105319:	55                   	push   %ebp
8010531a:	89 e5                	mov    %esp,%ebp
8010531c:	53                   	push   %ebx
8010531d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105320:	8b 45 08             	mov    0x8(%ebp),%eax
80105323:	8b 00                	mov    (%eax),%eax
80105325:	85 c0                	test   %eax,%eax
80105327:	74 16                	je     8010533f <holding+0x26>
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
8010532c:	8b 58 08             	mov    0x8(%eax),%ebx
8010532f:	e8 57 ef ff ff       	call   8010428b <mycpu>
80105334:	39 c3                	cmp    %eax,%ebx
80105336:	75 07                	jne    8010533f <holding+0x26>
80105338:	b8 01 00 00 00       	mov    $0x1,%eax
8010533d:	eb 05                	jmp    80105344 <holding+0x2b>
8010533f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105344:	83 c4 04             	add    $0x4,%esp
80105347:	5b                   	pop    %ebx
80105348:	5d                   	pop    %ebp
80105349:	c3                   	ret    

8010534a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010534a:	55                   	push   %ebp
8010534b:	89 e5                	mov    %esp,%ebp
8010534d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105350:	e8 3f fe ff ff       	call   80105194 <readeflags>
80105355:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105358:	e8 47 fe ff ff       	call   801051a4 <cli>
  if(mycpu()->ncli == 0)
8010535d:	e8 29 ef ff ff       	call   8010428b <mycpu>
80105362:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105368:	85 c0                	test   %eax,%eax
8010536a:	75 14                	jne    80105380 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010536c:	e8 1a ef ff ff       	call   8010428b <mycpu>
80105371:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105374:	81 e2 00 02 00 00    	and    $0x200,%edx
8010537a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105380:	e8 06 ef ff ff       	call   8010428b <mycpu>
80105385:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010538b:	42                   	inc    %edx
8010538c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105392:	c9                   	leave  
80105393:	c3                   	ret    

80105394 <popcli>:

void
popcli(void)
{
80105394:	55                   	push   %ebp
80105395:	89 e5                	mov    %esp,%ebp
80105397:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010539a:	e8 f5 fd ff ff       	call   80105194 <readeflags>
8010539f:	25 00 02 00 00       	and    $0x200,%eax
801053a4:	85 c0                	test   %eax,%eax
801053a6:	74 0c                	je     801053b4 <popcli+0x20>
    panic("popcli - interruptible");
801053a8:	c7 04 24 dd 95 10 80 	movl   $0x801095dd,(%esp)
801053af:	e8 a0 b1 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
801053b4:	e8 d2 ee ff ff       	call   8010428b <mycpu>
801053b9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801053bf:	4a                   	dec    %edx
801053c0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801053c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053cc:	85 c0                	test   %eax,%eax
801053ce:	79 0c                	jns    801053dc <popcli+0x48>
    panic("popcli");
801053d0:	c7 04 24 f4 95 10 80 	movl   $0x801095f4,(%esp)
801053d7:	e8 78 b1 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801053dc:	e8 aa ee ff ff       	call   8010428b <mycpu>
801053e1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053e7:	85 c0                	test   %eax,%eax
801053e9:	75 14                	jne    801053ff <popcli+0x6b>
801053eb:	e8 9b ee ff ff       	call   8010428b <mycpu>
801053f0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801053f6:	85 c0                	test   %eax,%eax
801053f8:	74 05                	je     801053ff <popcli+0x6b>
    sti();
801053fa:	e8 ab fd ff ff       	call   801051aa <sti>
}
801053ff:	c9                   	leave  
80105400:	c3                   	ret    
80105401:	00 00                	add    %al,(%eax)
	...

80105404 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105404:	55                   	push   %ebp
80105405:	89 e5                	mov    %esp,%ebp
80105407:	57                   	push   %edi
80105408:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105409:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010540c:	8b 55 10             	mov    0x10(%ebp),%edx
8010540f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105412:	89 cb                	mov    %ecx,%ebx
80105414:	89 df                	mov    %ebx,%edi
80105416:	89 d1                	mov    %edx,%ecx
80105418:	fc                   	cld    
80105419:	f3 aa                	rep stos %al,%es:(%edi)
8010541b:	89 ca                	mov    %ecx,%edx
8010541d:	89 fb                	mov    %edi,%ebx
8010541f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105422:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105425:	5b                   	pop    %ebx
80105426:	5f                   	pop    %edi
80105427:	5d                   	pop    %ebp
80105428:	c3                   	ret    

80105429 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105429:	55                   	push   %ebp
8010542a:	89 e5                	mov    %esp,%ebp
8010542c:	57                   	push   %edi
8010542d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010542e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105431:	8b 55 10             	mov    0x10(%ebp),%edx
80105434:	8b 45 0c             	mov    0xc(%ebp),%eax
80105437:	89 cb                	mov    %ecx,%ebx
80105439:	89 df                	mov    %ebx,%edi
8010543b:	89 d1                	mov    %edx,%ecx
8010543d:	fc                   	cld    
8010543e:	f3 ab                	rep stos %eax,%es:(%edi)
80105440:	89 ca                	mov    %ecx,%edx
80105442:	89 fb                	mov    %edi,%ebx
80105444:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105447:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010544a:	5b                   	pop    %ebx
8010544b:	5f                   	pop    %edi
8010544c:	5d                   	pop    %ebp
8010544d:	c3                   	ret    

8010544e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010544e:	55                   	push   %ebp
8010544f:	89 e5                	mov    %esp,%ebp
80105451:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105454:	8b 45 08             	mov    0x8(%ebp),%eax
80105457:	83 e0 03             	and    $0x3,%eax
8010545a:	85 c0                	test   %eax,%eax
8010545c:	75 49                	jne    801054a7 <memset+0x59>
8010545e:	8b 45 10             	mov    0x10(%ebp),%eax
80105461:	83 e0 03             	and    $0x3,%eax
80105464:	85 c0                	test   %eax,%eax
80105466:	75 3f                	jne    801054a7 <memset+0x59>
    c &= 0xFF;
80105468:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010546f:	8b 45 10             	mov    0x10(%ebp),%eax
80105472:	c1 e8 02             	shr    $0x2,%eax
80105475:	89 c2                	mov    %eax,%edx
80105477:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547a:	c1 e0 18             	shl    $0x18,%eax
8010547d:	89 c1                	mov    %eax,%ecx
8010547f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105482:	c1 e0 10             	shl    $0x10,%eax
80105485:	09 c1                	or     %eax,%ecx
80105487:	8b 45 0c             	mov    0xc(%ebp),%eax
8010548a:	c1 e0 08             	shl    $0x8,%eax
8010548d:	09 c8                	or     %ecx,%eax
8010548f:	0b 45 0c             	or     0xc(%ebp),%eax
80105492:	89 54 24 08          	mov    %edx,0x8(%esp)
80105496:	89 44 24 04          	mov    %eax,0x4(%esp)
8010549a:	8b 45 08             	mov    0x8(%ebp),%eax
8010549d:	89 04 24             	mov    %eax,(%esp)
801054a0:	e8 84 ff ff ff       	call   80105429 <stosl>
801054a5:	eb 19                	jmp    801054c0 <memset+0x72>
  } else
    stosb(dst, c, n);
801054a7:	8b 45 10             	mov    0x10(%ebp),%eax
801054aa:	89 44 24 08          	mov    %eax,0x8(%esp)
801054ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054b5:	8b 45 08             	mov    0x8(%ebp),%eax
801054b8:	89 04 24             	mov    %eax,(%esp)
801054bb:	e8 44 ff ff ff       	call   80105404 <stosb>
  return dst;
801054c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054c3:	c9                   	leave  
801054c4:	c3                   	ret    

801054c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054c5:	55                   	push   %ebp
801054c6:	89 e5                	mov    %esp,%ebp
801054c8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801054cb:	8b 45 08             	mov    0x8(%ebp),%eax
801054ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801054d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801054d7:	eb 2a                	jmp    80105503 <memcmp+0x3e>
    if(*s1 != *s2)
801054d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054dc:	8a 10                	mov    (%eax),%dl
801054de:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054e1:	8a 00                	mov    (%eax),%al
801054e3:	38 c2                	cmp    %al,%dl
801054e5:	74 16                	je     801054fd <memcmp+0x38>
      return *s1 - *s2;
801054e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054ea:	8a 00                	mov    (%eax),%al
801054ec:	0f b6 d0             	movzbl %al,%edx
801054ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054f2:	8a 00                	mov    (%eax),%al
801054f4:	0f b6 c0             	movzbl %al,%eax
801054f7:	29 c2                	sub    %eax,%edx
801054f9:	89 d0                	mov    %edx,%eax
801054fb:	eb 18                	jmp    80105515 <memcmp+0x50>
    s1++, s2++;
801054fd:	ff 45 fc             	incl   -0x4(%ebp)
80105500:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105503:	8b 45 10             	mov    0x10(%ebp),%eax
80105506:	8d 50 ff             	lea    -0x1(%eax),%edx
80105509:	89 55 10             	mov    %edx,0x10(%ebp)
8010550c:	85 c0                	test   %eax,%eax
8010550e:	75 c9                	jne    801054d9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105510:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105515:	c9                   	leave  
80105516:	c3                   	ret    

80105517 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105517:	55                   	push   %ebp
80105518:	89 e5                	mov    %esp,%ebp
8010551a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010551d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105520:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105523:	8b 45 08             	mov    0x8(%ebp),%eax
80105526:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105529:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010552c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010552f:	73 3a                	jae    8010556b <memmove+0x54>
80105531:	8b 45 10             	mov    0x10(%ebp),%eax
80105534:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105537:	01 d0                	add    %edx,%eax
80105539:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010553c:	76 2d                	jbe    8010556b <memmove+0x54>
    s += n;
8010553e:	8b 45 10             	mov    0x10(%ebp),%eax
80105541:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105544:	8b 45 10             	mov    0x10(%ebp),%eax
80105547:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010554a:	eb 10                	jmp    8010555c <memmove+0x45>
      *--d = *--s;
8010554c:	ff 4d f8             	decl   -0x8(%ebp)
8010554f:	ff 4d fc             	decl   -0x4(%ebp)
80105552:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105555:	8a 10                	mov    (%eax),%dl
80105557:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010555a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010555c:	8b 45 10             	mov    0x10(%ebp),%eax
8010555f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105562:	89 55 10             	mov    %edx,0x10(%ebp)
80105565:	85 c0                	test   %eax,%eax
80105567:	75 e3                	jne    8010554c <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105569:	eb 25                	jmp    80105590 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010556b:	eb 16                	jmp    80105583 <memmove+0x6c>
      *d++ = *s++;
8010556d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105570:	8d 50 01             	lea    0x1(%eax),%edx
80105573:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105576:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105579:	8d 4a 01             	lea    0x1(%edx),%ecx
8010557c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010557f:	8a 12                	mov    (%edx),%dl
80105581:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105583:	8b 45 10             	mov    0x10(%ebp),%eax
80105586:	8d 50 ff             	lea    -0x1(%eax),%edx
80105589:	89 55 10             	mov    %edx,0x10(%ebp)
8010558c:	85 c0                	test   %eax,%eax
8010558e:	75 dd                	jne    8010556d <memmove+0x56>
      *d++ = *s++;

  return dst;
80105590:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105593:	c9                   	leave  
80105594:	c3                   	ret    

80105595 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105595:	55                   	push   %ebp
80105596:	89 e5                	mov    %esp,%ebp
80105598:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010559b:	8b 45 10             	mov    0x10(%ebp),%eax
8010559e:	89 44 24 08          	mov    %eax,0x8(%esp)
801055a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801055a9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ac:	89 04 24             	mov    %eax,(%esp)
801055af:	e8 63 ff ff ff       	call   80105517 <memmove>
}
801055b4:	c9                   	leave  
801055b5:	c3                   	ret    

801055b6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801055b6:	55                   	push   %ebp
801055b7:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801055b9:	eb 09                	jmp    801055c4 <strncmp+0xe>
    n--, p++, q++;
801055bb:	ff 4d 10             	decl   0x10(%ebp)
801055be:	ff 45 08             	incl   0x8(%ebp)
801055c1:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801055c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055c8:	74 17                	je     801055e1 <strncmp+0x2b>
801055ca:	8b 45 08             	mov    0x8(%ebp),%eax
801055cd:	8a 00                	mov    (%eax),%al
801055cf:	84 c0                	test   %al,%al
801055d1:	74 0e                	je     801055e1 <strncmp+0x2b>
801055d3:	8b 45 08             	mov    0x8(%ebp),%eax
801055d6:	8a 10                	mov    (%eax),%dl
801055d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055db:	8a 00                	mov    (%eax),%al
801055dd:	38 c2                	cmp    %al,%dl
801055df:	74 da                	je     801055bb <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801055e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055e5:	75 07                	jne    801055ee <strncmp+0x38>
    return 0;
801055e7:	b8 00 00 00 00       	mov    $0x0,%eax
801055ec:	eb 14                	jmp    80105602 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801055ee:	8b 45 08             	mov    0x8(%ebp),%eax
801055f1:	8a 00                	mov    (%eax),%al
801055f3:	0f b6 d0             	movzbl %al,%edx
801055f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f9:	8a 00                	mov    (%eax),%al
801055fb:	0f b6 c0             	movzbl %al,%eax
801055fe:	29 c2                	sub    %eax,%edx
80105600:	89 d0                	mov    %edx,%eax
}
80105602:	5d                   	pop    %ebp
80105603:	c3                   	ret    

80105604 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105604:	55                   	push   %ebp
80105605:	89 e5                	mov    %esp,%ebp
80105607:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010560a:	8b 45 08             	mov    0x8(%ebp),%eax
8010560d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105610:	90                   	nop
80105611:	8b 45 10             	mov    0x10(%ebp),%eax
80105614:	8d 50 ff             	lea    -0x1(%eax),%edx
80105617:	89 55 10             	mov    %edx,0x10(%ebp)
8010561a:	85 c0                	test   %eax,%eax
8010561c:	7e 1c                	jle    8010563a <strncpy+0x36>
8010561e:	8b 45 08             	mov    0x8(%ebp),%eax
80105621:	8d 50 01             	lea    0x1(%eax),%edx
80105624:	89 55 08             	mov    %edx,0x8(%ebp)
80105627:	8b 55 0c             	mov    0xc(%ebp),%edx
8010562a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010562d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105630:	8a 12                	mov    (%edx),%dl
80105632:	88 10                	mov    %dl,(%eax)
80105634:	8a 00                	mov    (%eax),%al
80105636:	84 c0                	test   %al,%al
80105638:	75 d7                	jne    80105611 <strncpy+0xd>
    ;
  while(n-- > 0)
8010563a:	eb 0c                	jmp    80105648 <strncpy+0x44>
    *s++ = 0;
8010563c:	8b 45 08             	mov    0x8(%ebp),%eax
8010563f:	8d 50 01             	lea    0x1(%eax),%edx
80105642:	89 55 08             	mov    %edx,0x8(%ebp)
80105645:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105648:	8b 45 10             	mov    0x10(%ebp),%eax
8010564b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010564e:	89 55 10             	mov    %edx,0x10(%ebp)
80105651:	85 c0                	test   %eax,%eax
80105653:	7f e7                	jg     8010563c <strncpy+0x38>
    *s++ = 0;
  return os;
80105655:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105658:	c9                   	leave  
80105659:	c3                   	ret    

8010565a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010565a:	55                   	push   %ebp
8010565b:	89 e5                	mov    %esp,%ebp
8010565d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105660:	8b 45 08             	mov    0x8(%ebp),%eax
80105663:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105666:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010566a:	7f 05                	jg     80105671 <safestrcpy+0x17>
    return os;
8010566c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010566f:	eb 2e                	jmp    8010569f <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105671:	ff 4d 10             	decl   0x10(%ebp)
80105674:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105678:	7e 1c                	jle    80105696 <safestrcpy+0x3c>
8010567a:	8b 45 08             	mov    0x8(%ebp),%eax
8010567d:	8d 50 01             	lea    0x1(%eax),%edx
80105680:	89 55 08             	mov    %edx,0x8(%ebp)
80105683:	8b 55 0c             	mov    0xc(%ebp),%edx
80105686:	8d 4a 01             	lea    0x1(%edx),%ecx
80105689:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010568c:	8a 12                	mov    (%edx),%dl
8010568e:	88 10                	mov    %dl,(%eax)
80105690:	8a 00                	mov    (%eax),%al
80105692:	84 c0                	test   %al,%al
80105694:	75 db                	jne    80105671 <safestrcpy+0x17>
    ;
  *s = 0;
80105696:	8b 45 08             	mov    0x8(%ebp),%eax
80105699:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010569c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010569f:	c9                   	leave  
801056a0:	c3                   	ret    

801056a1 <strlen>:

int
strlen(const char *s)
{
801056a1:	55                   	push   %ebp
801056a2:	89 e5                	mov    %esp,%ebp
801056a4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801056a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801056ae:	eb 03                	jmp    801056b3 <strlen+0x12>
801056b0:	ff 45 fc             	incl   -0x4(%ebp)
801056b3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056b6:	8b 45 08             	mov    0x8(%ebp),%eax
801056b9:	01 d0                	add    %edx,%eax
801056bb:	8a 00                	mov    (%eax),%al
801056bd:	84 c0                	test   %al,%al
801056bf:	75 ef                	jne    801056b0 <strlen+0xf>
    ;
  return n;
801056c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056c4:	c9                   	leave  
801056c5:	c3                   	ret    
	...

801056c8 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056cc:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056d0:	55                   	push   %ebp
  pushl %ebx
801056d1:	53                   	push   %ebx
  pushl %esi
801056d2:	56                   	push   %esi
  pushl %edi
801056d3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056d4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056d6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056d8:	5f                   	pop    %edi
  popl %esi
801056d9:	5e                   	pop    %esi
  popl %ebx
801056da:	5b                   	pop    %ebx
  popl %ebp
801056db:	5d                   	pop    %ebp
  ret
801056dc:	c3                   	ret    
801056dd:	00 00                	add    %al,(%eax)
	...

801056e0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801056e0:	55                   	push   %ebp
801056e1:	89 e5                	mov    %esp,%ebp
801056e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801056e6:	e8 24 ec ff ff       	call   8010430f <myproc>
801056eb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801056ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f1:	8b 00                	mov    (%eax),%eax
801056f3:	3b 45 08             	cmp    0x8(%ebp),%eax
801056f6:	76 0f                	jbe    80105707 <fetchint+0x27>
801056f8:	8b 45 08             	mov    0x8(%ebp),%eax
801056fb:	8d 50 04             	lea    0x4(%eax),%edx
801056fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105701:	8b 00                	mov    (%eax),%eax
80105703:	39 c2                	cmp    %eax,%edx
80105705:	76 07                	jbe    8010570e <fetchint+0x2e>
    return -1;
80105707:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010570c:	eb 0f                	jmp    8010571d <fetchint+0x3d>
  *ip = *(int*)(addr);
8010570e:	8b 45 08             	mov    0x8(%ebp),%eax
80105711:	8b 10                	mov    (%eax),%edx
80105713:	8b 45 0c             	mov    0xc(%ebp),%eax
80105716:	89 10                	mov    %edx,(%eax)
  return 0;
80105718:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010571d:	c9                   	leave  
8010571e:	c3                   	ret    

8010571f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010571f:	55                   	push   %ebp
80105720:	89 e5                	mov    %esp,%ebp
80105722:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105725:	e8 e5 eb ff ff       	call   8010430f <myproc>
8010572a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010572d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105730:	8b 00                	mov    (%eax),%eax
80105732:	3b 45 08             	cmp    0x8(%ebp),%eax
80105735:	77 07                	ja     8010573e <fetchstr+0x1f>
    return -1;
80105737:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573c:	eb 41                	jmp    8010577f <fetchstr+0x60>
  *pp = (char*)addr;
8010573e:	8b 55 08             	mov    0x8(%ebp),%edx
80105741:	8b 45 0c             	mov    0xc(%ebp),%eax
80105744:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105749:	8b 00                	mov    (%eax),%eax
8010574b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010574e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105751:	8b 00                	mov    (%eax),%eax
80105753:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105756:	eb 1a                	jmp    80105772 <fetchstr+0x53>
    if(*s == 0)
80105758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010575b:	8a 00                	mov    (%eax),%al
8010575d:	84 c0                	test   %al,%al
8010575f:	75 0e                	jne    8010576f <fetchstr+0x50>
      return s - *pp;
80105761:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105764:	8b 45 0c             	mov    0xc(%ebp),%eax
80105767:	8b 00                	mov    (%eax),%eax
80105769:	29 c2                	sub    %eax,%edx
8010576b:	89 d0                	mov    %edx,%eax
8010576d:	eb 10                	jmp    8010577f <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
8010576f:	ff 45 f4             	incl   -0xc(%ebp)
80105772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105775:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105778:	72 de                	jb     80105758 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
8010577a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010577f:	c9                   	leave  
80105780:	c3                   	ret    

80105781 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105781:	55                   	push   %ebp
80105782:	89 e5                	mov    %esp,%ebp
80105784:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105787:	e8 83 eb ff ff       	call   8010430f <myproc>
8010578c:	8b 40 18             	mov    0x18(%eax),%eax
8010578f:	8b 50 44             	mov    0x44(%eax),%edx
80105792:	8b 45 08             	mov    0x8(%ebp),%eax
80105795:	c1 e0 02             	shl    $0x2,%eax
80105798:	01 d0                	add    %edx,%eax
8010579a:	8d 50 04             	lea    0x4(%eax),%edx
8010579d:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a4:	89 14 24             	mov    %edx,(%esp)
801057a7:	e8 34 ff ff ff       	call   801056e0 <fetchint>
}
801057ac:	c9                   	leave  
801057ad:	c3                   	ret    

801057ae <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801057ae:	55                   	push   %ebp
801057af:	89 e5                	mov    %esp,%ebp
801057b1:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
801057b4:	e8 56 eb ff ff       	call   8010430f <myproc>
801057b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801057bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c3:	8b 45 08             	mov    0x8(%ebp),%eax
801057c6:	89 04 24             	mov    %eax,(%esp)
801057c9:	e8 b3 ff ff ff       	call   80105781 <argint>
801057ce:	85 c0                	test   %eax,%eax
801057d0:	79 07                	jns    801057d9 <argptr+0x2b>
    return -1;
801057d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d7:	eb 3d                	jmp    80105816 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801057d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057dd:	78 21                	js     80105800 <argptr+0x52>
801057df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e2:	89 c2                	mov    %eax,%edx
801057e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e7:	8b 00                	mov    (%eax),%eax
801057e9:	39 c2                	cmp    %eax,%edx
801057eb:	73 13                	jae    80105800 <argptr+0x52>
801057ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f0:	89 c2                	mov    %eax,%edx
801057f2:	8b 45 10             	mov    0x10(%ebp),%eax
801057f5:	01 c2                	add    %eax,%edx
801057f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fa:	8b 00                	mov    (%eax),%eax
801057fc:	39 c2                	cmp    %eax,%edx
801057fe:	76 07                	jbe    80105807 <argptr+0x59>
    return -1;
80105800:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105805:	eb 0f                	jmp    80105816 <argptr+0x68>
  *pp = (char*)i;
80105807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580a:	89 c2                	mov    %eax,%edx
8010580c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010580f:	89 10                	mov    %edx,(%eax)
  return 0;
80105811:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105816:	c9                   	leave  
80105817:	c3                   	ret    

80105818 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105818:	55                   	push   %ebp
80105819:	89 e5                	mov    %esp,%ebp
8010581b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010581e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105821:	89 44 24 04          	mov    %eax,0x4(%esp)
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	89 04 24             	mov    %eax,(%esp)
8010582b:	e8 51 ff ff ff       	call   80105781 <argint>
80105830:	85 c0                	test   %eax,%eax
80105832:	79 07                	jns    8010583b <argstr+0x23>
    return -1;
80105834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105839:	eb 12                	jmp    8010584d <argstr+0x35>
  return fetchstr(addr, pp);
8010583b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105841:	89 54 24 04          	mov    %edx,0x4(%esp)
80105845:	89 04 24             	mov    %eax,(%esp)
80105848:	e8 d2 fe ff ff       	call   8010571f <fetchstr>
}
8010584d:	c9                   	leave  
8010584e:	c3                   	ret    

8010584f <syscall>:
[SYS_cstop] sys_cstop,
};

void
syscall(void)
{
8010584f:	55                   	push   %ebp
80105850:	89 e5                	mov    %esp,%ebp
80105852:	53                   	push   %ebx
80105853:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105856:	e8 b4 ea ff ff       	call   8010430f <myproc>
8010585b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010585e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105861:	8b 40 18             	mov    0x18(%eax),%eax
80105864:	8b 40 1c             	mov    0x1c(%eax),%eax
80105867:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010586a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010586e:	7e 2d                	jle    8010589d <syscall+0x4e>
80105870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105873:	83 f8 2c             	cmp    $0x2c,%eax
80105876:	77 25                	ja     8010589d <syscall+0x4e>
80105878:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587b:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105882:	85 c0                	test   %eax,%eax
80105884:	74 17                	je     8010589d <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105889:	8b 58 18             	mov    0x18(%eax),%ebx
8010588c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588f:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105896:	ff d0                	call   *%eax
80105898:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010589b:	eb 34                	jmp    801058d1 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010589d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a0:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a6:	8b 40 10             	mov    0x10(%eax),%eax
801058a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
801058b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801058b8:	c7 04 24 fb 95 10 80 	movl   $0x801095fb,(%esp)
801058bf:	e8 fd aa ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
801058c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c7:	8b 40 18             	mov    0x18(%eax),%eax
801058ca:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058d1:	83 c4 24             	add    $0x24,%esp
801058d4:	5b                   	pop    %ebx
801058d5:	5d                   	pop    %ebp
801058d6:	c3                   	ret    
	...

801058d8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058d8:	55                   	push   %ebp
801058d9:	89 e5                	mov    %esp,%ebp
801058db:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801058de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801058e5:	8b 45 08             	mov    0x8(%ebp),%eax
801058e8:	89 04 24             	mov    %eax,(%esp)
801058eb:	e8 91 fe ff ff       	call   80105781 <argint>
801058f0:	85 c0                	test   %eax,%eax
801058f2:	79 07                	jns    801058fb <argfd+0x23>
    return -1;
801058f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f9:	eb 4f                	jmp    8010594a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801058fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fe:	85 c0                	test   %eax,%eax
80105900:	78 20                	js     80105922 <argfd+0x4a>
80105902:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105905:	83 f8 0f             	cmp    $0xf,%eax
80105908:	7f 18                	jg     80105922 <argfd+0x4a>
8010590a:	e8 00 ea ff ff       	call   8010430f <myproc>
8010590f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105912:	83 c2 08             	add    $0x8,%edx
80105915:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105919:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010591c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105920:	75 07                	jne    80105929 <argfd+0x51>
    return -1;
80105922:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105927:	eb 21                	jmp    8010594a <argfd+0x72>
  if(pfd)
80105929:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010592d:	74 08                	je     80105937 <argfd+0x5f>
    *pfd = fd;
8010592f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105932:	8b 45 0c             	mov    0xc(%ebp),%eax
80105935:	89 10                	mov    %edx,(%eax)
  if(pf)
80105937:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010593b:	74 08                	je     80105945 <argfd+0x6d>
    *pf = f;
8010593d:	8b 45 10             	mov    0x10(%ebp),%eax
80105940:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105943:	89 10                	mov    %edx,(%eax)
  return 0;
80105945:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010594a:	c9                   	leave  
8010594b:	c3                   	ret    

8010594c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010594c:	55                   	push   %ebp
8010594d:	89 e5                	mov    %esp,%ebp
8010594f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105952:	e8 b8 e9 ff ff       	call   8010430f <myproc>
80105957:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010595a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105961:	eb 29                	jmp    8010598c <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105966:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105969:	83 c2 08             	add    $0x8,%edx
8010596c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105970:	85 c0                	test   %eax,%eax
80105972:	75 15                	jne    80105989 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105974:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105977:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010597a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010597d:	8b 55 08             	mov    0x8(%ebp),%edx
80105980:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	eb 0e                	jmp    80105997 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105989:	ff 45 f4             	incl   -0xc(%ebp)
8010598c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105990:	7e d1                	jle    80105963 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105997:	c9                   	leave  
80105998:	c3                   	ret    

80105999 <sys_dup>:

int
sys_dup(void)
{
80105999:	55                   	push   %ebp
8010599a:	89 e5                	mov    %esp,%ebp
8010599c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010599f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a2:	89 44 24 08          	mov    %eax,0x8(%esp)
801059a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059ad:	00 
801059ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059b5:	e8 1e ff ff ff       	call   801058d8 <argfd>
801059ba:	85 c0                	test   %eax,%eax
801059bc:	79 07                	jns    801059c5 <sys_dup+0x2c>
    return -1;
801059be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c3:	eb 29                	jmp    801059ee <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c8:	89 04 24             	mov    %eax,(%esp)
801059cb:	e8 7c ff ff ff       	call   8010594c <fdalloc>
801059d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059d7:	79 07                	jns    801059e0 <sys_dup+0x47>
    return -1;
801059d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059de:	eb 0e                	jmp    801059ee <sys_dup+0x55>
  filedup(f);
801059e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e3:	89 04 24             	mov    %eax,(%esp)
801059e6:	e8 77 b7 ff ff       	call   80101162 <filedup>
  return fd;
801059eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059ee:	c9                   	leave  
801059ef:	c3                   	ret    

801059f0 <sys_read>:

int
sys_read(void)
{
801059f0:	55                   	push   %ebp
801059f1:	89 e5                	mov    %esp,%ebp
801059f3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059f9:	89 44 24 08          	mov    %eax,0x8(%esp)
801059fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a04:	00 
80105a05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a0c:	e8 c7 fe ff ff       	call   801058d8 <argfd>
80105a11:	85 c0                	test   %eax,%eax
80105a13:	78 35                	js     80105a4a <sys_read+0x5a>
80105a15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a18:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a1c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a23:	e8 59 fd ff ff       	call   80105781 <argint>
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	78 1e                	js     80105a4a <sys_read+0x5a>
80105a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a33:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a41:	e8 68 fd ff ff       	call   801057ae <argptr>
80105a46:	85 c0                	test   %eax,%eax
80105a48:	79 07                	jns    80105a51 <sys_read+0x61>
    return -1;
80105a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4f:	eb 19                	jmp    80105a6a <sys_read+0x7a>
  return fileread(f, p, n);
80105a51:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a54:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a62:	89 04 24             	mov    %eax,(%esp)
80105a65:	e8 59 b8 ff ff       	call   801012c3 <fileread>
}
80105a6a:	c9                   	leave  
80105a6b:	c3                   	ret    

80105a6c <sys_write>:

int
sys_write(void)
{
80105a6c:	55                   	push   %ebp
80105a6d:	89 e5                	mov    %esp,%ebp
80105a6f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a75:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a80:	00 
80105a81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a88:	e8 4b fe ff ff       	call   801058d8 <argfd>
80105a8d:	85 c0                	test   %eax,%eax
80105a8f:	78 35                	js     80105ac6 <sys_write+0x5a>
80105a91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a98:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a9f:	e8 dd fc ff ff       	call   80105781 <argint>
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	78 1e                	js     80105ac6 <sys_write+0x5a>
80105aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aaf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105abd:	e8 ec fc ff ff       	call   801057ae <argptr>
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	79 07                	jns    80105acd <sys_write+0x61>
    return -1;
80105ac6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acb:	eb 19                	jmp    80105ae6 <sys_write+0x7a>
  return filewrite(f, p, n);
80105acd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ad0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ada:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ade:	89 04 24             	mov    %eax,(%esp)
80105ae1:	e8 98 b8 ff ff       	call   8010137e <filewrite>
}
80105ae6:	c9                   	leave  
80105ae7:	c3                   	ret    

80105ae8 <sys_close>:

int
sys_close(void)
{
80105ae8:	55                   	push   %ebp
80105ae9:	89 e5                	mov    %esp,%ebp
80105aeb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105aee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105af1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105af8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105afc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b03:	e8 d0 fd ff ff       	call   801058d8 <argfd>
80105b08:	85 c0                	test   %eax,%eax
80105b0a:	79 07                	jns    80105b13 <sys_close+0x2b>
    return -1;
80105b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b11:	eb 23                	jmp    80105b36 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105b13:	e8 f7 e7 ff ff       	call   8010430f <myproc>
80105b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b1b:	83 c2 08             	add    $0x8,%edx
80105b1e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b25:	00 
  fileclose(f);
80105b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 79 b6 ff ff       	call   801011aa <fileclose>
  return 0;
80105b31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b36:	c9                   	leave  
80105b37:	c3                   	ret    

80105b38 <sys_fstat>:

int
sys_fstat(void)
{
80105b38:	55                   	push   %ebp
80105b39:	89 e5                	mov    %esp,%ebp
80105b3b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b41:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b4c:	00 
80105b4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b54:	e8 7f fd ff ff       	call   801058d8 <argfd>
80105b59:	85 c0                	test   %eax,%eax
80105b5b:	78 1f                	js     80105b7c <sys_fstat+0x44>
80105b5d:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b64:	00 
80105b65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b73:	e8 36 fc ff ff       	call   801057ae <argptr>
80105b78:	85 c0                	test   %eax,%eax
80105b7a:	79 07                	jns    80105b83 <sys_fstat+0x4b>
    return -1;
80105b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b81:	eb 12                	jmp    80105b95 <sys_fstat+0x5d>
  return filestat(f, st);
80105b83:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b8d:	89 04 24             	mov    %eax,(%esp)
80105b90:	e8 df b6 ff ff       	call   80101274 <filestat>
}
80105b95:	c9                   	leave  
80105b96:	c3                   	ret    

80105b97 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b97:	55                   	push   %ebp
80105b98:	89 e5                	mov    %esp,%ebp
80105b9a:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b9d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bab:	e8 68 fc ff ff       	call   80105818 <argstr>
80105bb0:	85 c0                	test   %eax,%eax
80105bb2:	78 17                	js     80105bcb <sys_link+0x34>
80105bb4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bc2:	e8 51 fc ff ff       	call   80105818 <argstr>
80105bc7:	85 c0                	test   %eax,%eax
80105bc9:	79 0a                	jns    80105bd5 <sys_link+0x3e>
    return -1;
80105bcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd0:	e9 3d 01 00 00       	jmp    80105d12 <sys_link+0x17b>

  begin_op();
80105bd5:	e8 35 da ff ff       	call   8010360f <begin_op>
  if((ip = namei(old)) == 0){
80105bda:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105bdd:	89 04 24             	mov    %eax,(%esp)
80105be0:	e8 12 ca ff ff       	call   801025f7 <namei>
80105be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105be8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bec:	75 0f                	jne    80105bfd <sys_link+0x66>
    end_op();
80105bee:	e8 9e da ff ff       	call   80103691 <end_op>
    return -1;
80105bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf8:	e9 15 01 00 00       	jmp    80105d12 <sys_link+0x17b>
  }

  ilock(ip);
80105bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c00:	89 04 24             	mov    %eax,(%esp)
80105c03:	e8 ba be ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0b:	8b 40 50             	mov    0x50(%eax),%eax
80105c0e:	66 83 f8 01          	cmp    $0x1,%ax
80105c12:	75 1a                	jne    80105c2e <sys_link+0x97>
    iunlockput(ip);
80105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c17:	89 04 24             	mov    %eax,(%esp)
80105c1a:	e8 a2 c0 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105c1f:	e8 6d da ff ff       	call   80103691 <end_op>
    return -1;
80105c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c29:	e9 e4 00 00 00       	jmp    80105d12 <sys_link+0x17b>
  }

  ip->nlink++;
80105c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c31:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c35:	40                   	inc    %eax
80105c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c39:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	89 04 24             	mov    %eax,(%esp)
80105c43:	e8 b7 bc ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4b:	89 04 24             	mov    %eax,(%esp)
80105c4e:	e8 79 bf ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c53:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c56:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c59:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c5d:	89 04 24             	mov    %eax,(%esp)
80105c60:	e8 b4 c9 ff ff       	call   80102619 <nameiparent>
80105c65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c6c:	75 02                	jne    80105c70 <sys_link+0xd9>
    goto bad;
80105c6e:	eb 68                	jmp    80105cd8 <sys_link+0x141>
  ilock(dp);
80105c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c73:	89 04 24             	mov    %eax,(%esp)
80105c76:	e8 47 be ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7e:	8b 10                	mov    (%eax),%edx
80105c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c83:	8b 00                	mov    (%eax),%eax
80105c85:	39 c2                	cmp    %eax,%edx
80105c87:	75 20                	jne    80105ca9 <sys_link+0x112>
80105c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8c:	8b 40 04             	mov    0x4(%eax),%eax
80105c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c93:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c96:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9d:	89 04 24             	mov    %eax,(%esp)
80105ca0:	e8 8f c6 ff ff       	call   80102334 <dirlink>
80105ca5:	85 c0                	test   %eax,%eax
80105ca7:	79 0d                	jns    80105cb6 <sys_link+0x11f>
    iunlockput(dp);
80105ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cac:	89 04 24             	mov    %eax,(%esp)
80105caf:	e8 0d c0 ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105cb4:	eb 22                	jmp    80105cd8 <sys_link+0x141>
  }
  iunlockput(dp);
80105cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb9:	89 04 24             	mov    %eax,(%esp)
80105cbc:	e8 00 c0 ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc4:	89 04 24             	mov    %eax,(%esp)
80105cc7:	e8 44 bf ff ff       	call   80101c10 <iput>

  end_op();
80105ccc:	e8 c0 d9 ff ff       	call   80103691 <end_op>

  return 0;
80105cd1:	b8 00 00 00 00       	mov    $0x0,%eax
80105cd6:	eb 3a                	jmp    80105d12 <sys_link+0x17b>

bad:
  ilock(ip);
80105cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdb:	89 04 24             	mov    %eax,(%esp)
80105cde:	e8 df bd ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce6:	66 8b 40 56          	mov    0x56(%eax),%ax
80105cea:	48                   	dec    %eax
80105ceb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cee:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf5:	89 04 24             	mov    %eax,(%esp)
80105cf8:	e8 02 bc ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d00:	89 04 24             	mov    %eax,(%esp)
80105d03:	e8 b9 bf ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105d08:	e8 84 d9 ff ff       	call   80103691 <end_op>
  return -1;
80105d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d12:	c9                   	leave  
80105d13:	c3                   	ret    

80105d14 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d14:	55                   	push   %ebp
80105d15:	89 e5                	mov    %esp,%ebp
80105d17:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d1a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d21:	eb 4a                	jmp    80105d6d <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d26:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d2d:	00 
80105d2e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d35:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d39:	8b 45 08             	mov    0x8(%ebp),%eax
80105d3c:	89 04 24             	mov    %eax,(%esp)
80105d3f:	e8 15 c2 ff ff       	call   80101f59 <readi>
80105d44:	83 f8 10             	cmp    $0x10,%eax
80105d47:	74 0c                	je     80105d55 <isdirempty+0x41>
      panic("isdirempty: readi");
80105d49:	c7 04 24 17 96 10 80 	movl   $0x80109617,(%esp)
80105d50:	e8 ff a7 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d58:	66 85 c0             	test   %ax,%ax
80105d5b:	74 07                	je     80105d64 <isdirempty+0x50>
      return 0;
80105d5d:	b8 00 00 00 00       	mov    $0x0,%eax
80105d62:	eb 1b                	jmp    80105d7f <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d67:	83 c0 10             	add    $0x10,%eax
80105d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d70:	8b 45 08             	mov    0x8(%ebp),%eax
80105d73:	8b 40 58             	mov    0x58(%eax),%eax
80105d76:	39 c2                	cmp    %eax,%edx
80105d78:	72 a9                	jb     80105d23 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d7a:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d7f:	c9                   	leave  
80105d80:	c3                   	ret    

80105d81 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d81:	55                   	push   %ebp
80105d82:	89 e5                	mov    %esp,%ebp
80105d84:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d87:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d95:	e8 7e fa ff ff       	call   80105818 <argstr>
80105d9a:	85 c0                	test   %eax,%eax
80105d9c:	79 0a                	jns    80105da8 <sys_unlink+0x27>
    return -1;
80105d9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da3:	e9 a9 01 00 00       	jmp    80105f51 <sys_unlink+0x1d0>

  begin_op();
80105da8:	e8 62 d8 ff ff       	call   8010360f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105dad:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105db0:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105db3:	89 54 24 04          	mov    %edx,0x4(%esp)
80105db7:	89 04 24             	mov    %eax,(%esp)
80105dba:	e8 5a c8 ff ff       	call   80102619 <nameiparent>
80105dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc6:	75 0f                	jne    80105dd7 <sys_unlink+0x56>
    end_op();
80105dc8:	e8 c4 d8 ff ff       	call   80103691 <end_op>
    return -1;
80105dcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd2:	e9 7a 01 00 00       	jmp    80105f51 <sys_unlink+0x1d0>
  }

  ilock(dp);
80105dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dda:	89 04 24             	mov    %eax,(%esp)
80105ddd:	e8 e0 bc ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105de2:	c7 44 24 04 29 96 10 	movl   $0x80109629,0x4(%esp)
80105de9:	80 
80105dea:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ded:	89 04 24             	mov    %eax,(%esp)
80105df0:	e8 57 c4 ff ff       	call   8010224c <namecmp>
80105df5:	85 c0                	test   %eax,%eax
80105df7:	0f 84 3f 01 00 00    	je     80105f3c <sys_unlink+0x1bb>
80105dfd:	c7 44 24 04 2b 96 10 	movl   $0x8010962b,0x4(%esp)
80105e04:	80 
80105e05:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e08:	89 04 24             	mov    %eax,(%esp)
80105e0b:	e8 3c c4 ff ff       	call   8010224c <namecmp>
80105e10:	85 c0                	test   %eax,%eax
80105e12:	0f 84 24 01 00 00    	je     80105f3c <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e18:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e1f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e22:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e29:	89 04 24             	mov    %eax,(%esp)
80105e2c:	e8 3d c4 ff ff       	call   8010226e <dirlookup>
80105e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e38:	75 05                	jne    80105e3f <sys_unlink+0xbe>
    goto bad;
80105e3a:	e9 fd 00 00 00       	jmp    80105f3c <sys_unlink+0x1bb>
  ilock(ip);
80105e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e42:	89 04 24             	mov    %eax,(%esp)
80105e45:	e8 78 bc ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
80105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e51:	66 85 c0             	test   %ax,%ax
80105e54:	7f 0c                	jg     80105e62 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105e56:	c7 04 24 2e 96 10 80 	movl   $0x8010962e,(%esp)
80105e5d:	e8 f2 a6 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e65:	8b 40 50             	mov    0x50(%eax),%eax
80105e68:	66 83 f8 01          	cmp    $0x1,%ax
80105e6c:	75 1f                	jne    80105e8d <sys_unlink+0x10c>
80105e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e71:	89 04 24             	mov    %eax,(%esp)
80105e74:	e8 9b fe ff ff       	call   80105d14 <isdirempty>
80105e79:	85 c0                	test   %eax,%eax
80105e7b:	75 10                	jne    80105e8d <sys_unlink+0x10c>
    iunlockput(ip);
80105e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e80:	89 04 24             	mov    %eax,(%esp)
80105e83:	e8 39 be ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105e88:	e9 af 00 00 00       	jmp    80105f3c <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105e8d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e94:	00 
80105e95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e9c:	00 
80105e9d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ea0:	89 04 24             	mov    %eax,(%esp)
80105ea3:	e8 a6 f5 ff ff       	call   8010544e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ea8:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105eab:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105eb2:	00 
80105eb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105eb7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105eba:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec1:	89 04 24             	mov    %eax,(%esp)
80105ec4:	e8 f4 c1 ff ff       	call   801020bd <writei>
80105ec9:	83 f8 10             	cmp    $0x10,%eax
80105ecc:	74 0c                	je     80105eda <sys_unlink+0x159>
    panic("unlink: writei");
80105ece:	c7 04 24 40 96 10 80 	movl   $0x80109640,(%esp)
80105ed5:	e8 7a a6 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105edd:	8b 40 50             	mov    0x50(%eax),%eax
80105ee0:	66 83 f8 01          	cmp    $0x1,%ax
80105ee4:	75 1a                	jne    80105f00 <sys_unlink+0x17f>
    dp->nlink--;
80105ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105eed:	48                   	dec    %eax
80105eee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ef1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef8:	89 04 24             	mov    %eax,(%esp)
80105efb:	e8 ff b9 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
80105f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f03:	89 04 24             	mov    %eax,(%esp)
80105f06:	e8 b6 bd ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
80105f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0e:	66 8b 40 56          	mov    0x56(%eax),%ax
80105f12:	48                   	dec    %eax
80105f13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f16:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1d:	89 04 24             	mov    %eax,(%esp)
80105f20:	e8 da b9 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f28:	89 04 24             	mov    %eax,(%esp)
80105f2b:	e8 91 bd ff ff       	call   80101cc1 <iunlockput>

  end_op();
80105f30:	e8 5c d7 ff ff       	call   80103691 <end_op>

  return 0;
80105f35:	b8 00 00 00 00       	mov    $0x0,%eax
80105f3a:	eb 15                	jmp    80105f51 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3f:	89 04 24             	mov    %eax,(%esp)
80105f42:	e8 7a bd ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105f47:	e8 45 d7 ff ff       	call   80103691 <end_op>
  return -1;
80105f4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f51:	c9                   	leave  
80105f52:	c3                   	ret    

80105f53 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f53:	55                   	push   %ebp
80105f54:	89 e5                	mov    %esp,%ebp
80105f56:	83 ec 48             	sub    $0x48,%esp
80105f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f5c:	8b 55 10             	mov    0x10(%ebp),%edx
80105f5f:	8b 45 14             	mov    0x14(%ebp),%eax
80105f62:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f66:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f6a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f6e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f75:	8b 45 08             	mov    0x8(%ebp),%eax
80105f78:	89 04 24             	mov    %eax,(%esp)
80105f7b:	e8 99 c6 ff ff       	call   80102619 <nameiparent>
80105f80:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f83:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f87:	75 0a                	jne    80105f93 <create+0x40>
    return 0;
80105f89:	b8 00 00 00 00       	mov    $0x0,%eax
80105f8e:	e9 79 01 00 00       	jmp    8010610c <create+0x1b9>
  ilock(dp);
80105f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f96:	89 04 24             	mov    %eax,(%esp)
80105f99:	e8 24 bb ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f9e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fa5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105faf:	89 04 24             	mov    %eax,(%esp)
80105fb2:	e8 b7 c2 ff ff       	call   8010226e <dirlookup>
80105fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fbe:	74 46                	je     80106006 <create+0xb3>
    iunlockput(dp);
80105fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc3:	89 04 24             	mov    %eax,(%esp)
80105fc6:	e8 f6 bc ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
80105fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fce:	89 04 24             	mov    %eax,(%esp)
80105fd1:	e8 ec ba ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105fd6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fdb:	75 14                	jne    80105ff1 <create+0x9e>
80105fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe0:	8b 40 50             	mov    0x50(%eax),%eax
80105fe3:	66 83 f8 02          	cmp    $0x2,%ax
80105fe7:	75 08                	jne    80105ff1 <create+0x9e>
      return ip;
80105fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fec:	e9 1b 01 00 00       	jmp    8010610c <create+0x1b9>
    iunlockput(ip);
80105ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff4:	89 04 24             	mov    %eax,(%esp)
80105ff7:	e8 c5 bc ff ff       	call   80101cc1 <iunlockput>
    return 0;
80105ffc:	b8 00 00 00 00       	mov    $0x0,%eax
80106001:	e9 06 01 00 00       	jmp    8010610c <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106006:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010600a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600d:	8b 00                	mov    (%eax),%eax
8010600f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106013:	89 04 24             	mov    %eax,(%esp)
80106016:	e8 12 b8 ff ff       	call   8010182d <ialloc>
8010601b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010601e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106022:	75 0c                	jne    80106030 <create+0xdd>
    panic("create: ialloc");
80106024:	c7 04 24 4f 96 10 80 	movl   $0x8010964f,(%esp)
8010602b:	e8 24 a5 ff ff       	call   80100554 <panic>

  ilock(ip);
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	89 04 24             	mov    %eax,(%esp)
80106036:	e8 87 ba ff ff       	call   80101ac2 <ilock>
  ip->major = major;
8010603b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010603e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106041:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106045:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106048:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010604b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010604f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106052:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106058:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605b:	89 04 24             	mov    %eax,(%esp)
8010605e:	e8 9c b8 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106063:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106068:	75 68                	jne    801060d2 <create+0x17f>
    dp->nlink++;  // for ".."
8010606a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106071:	40                   	inc    %eax
80106072:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106075:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607c:	89 04 24             	mov    %eax,(%esp)
8010607f:	e8 7b b8 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	8b 40 04             	mov    0x4(%eax),%eax
8010608a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010608e:	c7 44 24 04 29 96 10 	movl   $0x80109629,0x4(%esp)
80106095:	80 
80106096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106099:	89 04 24             	mov    %eax,(%esp)
8010609c:	e8 93 c2 ff ff       	call   80102334 <dirlink>
801060a1:	85 c0                	test   %eax,%eax
801060a3:	78 21                	js     801060c6 <create+0x173>
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	8b 40 04             	mov    0x4(%eax),%eax
801060ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801060af:	c7 44 24 04 2b 96 10 	movl   $0x8010962b,0x4(%esp)
801060b6:	80 
801060b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ba:	89 04 24             	mov    %eax,(%esp)
801060bd:	e8 72 c2 ff ff       	call   80102334 <dirlink>
801060c2:	85 c0                	test   %eax,%eax
801060c4:	79 0c                	jns    801060d2 <create+0x17f>
      panic("create dots");
801060c6:	c7 04 24 5e 96 10 80 	movl   $0x8010965e,(%esp)
801060cd:	e8 82 a4 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801060d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d5:	8b 40 04             	mov    0x4(%eax),%eax
801060d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801060dc:	8d 45 de             	lea    -0x22(%ebp),%eax
801060df:	89 44 24 04          	mov    %eax,0x4(%esp)
801060e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e6:	89 04 24             	mov    %eax,(%esp)
801060e9:	e8 46 c2 ff ff       	call   80102334 <dirlink>
801060ee:	85 c0                	test   %eax,%eax
801060f0:	79 0c                	jns    801060fe <create+0x1ab>
    panic("create: dirlink");
801060f2:	c7 04 24 6a 96 10 80 	movl   $0x8010966a,(%esp)
801060f9:	e8 56 a4 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801060fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106101:	89 04 24             	mov    %eax,(%esp)
80106104:	e8 b8 bb ff ff       	call   80101cc1 <iunlockput>

  return ip;
80106109:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010610c:	c9                   	leave  
8010610d:	c3                   	ret    

8010610e <sys_open>:

int
sys_open(void)
{
8010610e:	55                   	push   %ebp
8010610f:	89 e5                	mov    %esp,%ebp
80106111:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106114:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106117:	89 44 24 04          	mov    %eax,0x4(%esp)
8010611b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106122:	e8 f1 f6 ff ff       	call   80105818 <argstr>
80106127:	85 c0                	test   %eax,%eax
80106129:	78 17                	js     80106142 <sys_open+0x34>
8010612b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010612e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106132:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106139:	e8 43 f6 ff ff       	call   80105781 <argint>
8010613e:	85 c0                	test   %eax,%eax
80106140:	79 0a                	jns    8010614c <sys_open+0x3e>
    return -1;
80106142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106147:	e9 64 01 00 00       	jmp    801062b0 <sys_open+0x1a2>

  begin_op();
8010614c:	e8 be d4 ff ff       	call   8010360f <begin_op>

  if(omode & O_CREATE){
80106151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106154:	25 00 02 00 00       	and    $0x200,%eax
80106159:	85 c0                	test   %eax,%eax
8010615b:	74 3b                	je     80106198 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010615d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106160:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106167:	00 
80106168:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010616f:	00 
80106170:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106177:	00 
80106178:	89 04 24             	mov    %eax,(%esp)
8010617b:	e8 d3 fd ff ff       	call   80105f53 <create>
80106180:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106183:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106187:	75 6a                	jne    801061f3 <sys_open+0xe5>
      end_op();
80106189:	e8 03 d5 ff ff       	call   80103691 <end_op>
      return -1;
8010618e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106193:	e9 18 01 00 00       	jmp    801062b0 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106198:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010619b:	89 04 24             	mov    %eax,(%esp)
8010619e:	e8 54 c4 ff ff       	call   801025f7 <namei>
801061a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061aa:	75 0f                	jne    801061bb <sys_open+0xad>
      end_op();
801061ac:	e8 e0 d4 ff ff       	call   80103691 <end_op>
      return -1;
801061b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b6:	e9 f5 00 00 00       	jmp    801062b0 <sys_open+0x1a2>
    }
    ilock(ip);
801061bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061be:	89 04 24             	mov    %eax,(%esp)
801061c1:	e8 fc b8 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801061c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c9:	8b 40 50             	mov    0x50(%eax),%eax
801061cc:	66 83 f8 01          	cmp    $0x1,%ax
801061d0:	75 21                	jne    801061f3 <sys_open+0xe5>
801061d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061d5:	85 c0                	test   %eax,%eax
801061d7:	74 1a                	je     801061f3 <sys_open+0xe5>
      iunlockput(ip);
801061d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dc:	89 04 24             	mov    %eax,(%esp)
801061df:	e8 dd ba ff ff       	call   80101cc1 <iunlockput>
      end_op();
801061e4:	e8 a8 d4 ff ff       	call   80103691 <end_op>
      return -1;
801061e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ee:	e9 bd 00 00 00       	jmp    801062b0 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801061f3:	e8 0a af ff ff       	call   80101102 <filealloc>
801061f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061ff:	74 14                	je     80106215 <sys_open+0x107>
80106201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106204:	89 04 24             	mov    %eax,(%esp)
80106207:	e8 40 f7 ff ff       	call   8010594c <fdalloc>
8010620c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010620f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106213:	79 28                	jns    8010623d <sys_open+0x12f>
    if(f)
80106215:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106219:	74 0b                	je     80106226 <sys_open+0x118>
      fileclose(f);
8010621b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621e:	89 04 24             	mov    %eax,(%esp)
80106221:	e8 84 af ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106229:	89 04 24             	mov    %eax,(%esp)
8010622c:	e8 90 ba ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106231:	e8 5b d4 ff ff       	call   80103691 <end_op>
    return -1;
80106236:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623b:	eb 73                	jmp    801062b0 <sys_open+0x1a2>
  }
  iunlock(ip);
8010623d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106240:	89 04 24             	mov    %eax,(%esp)
80106243:	e8 84 b9 ff ff       	call   80101bcc <iunlock>
  end_op();
80106248:	e8 44 d4 ff ff       	call   80103691 <end_op>

  f->type = FD_INODE;
8010624d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106250:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106259:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010625c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106262:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010626c:	83 e0 01             	and    $0x1,%eax
8010626f:	85 c0                	test   %eax,%eax
80106271:	0f 94 c0             	sete   %al
80106274:	88 c2                	mov    %al,%dl
80106276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106279:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010627c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010627f:	83 e0 01             	and    $0x1,%eax
80106282:	85 c0                	test   %eax,%eax
80106284:	75 0a                	jne    80106290 <sys_open+0x182>
80106286:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106289:	83 e0 02             	and    $0x2,%eax
8010628c:	85 c0                	test   %eax,%eax
8010628e:	74 07                	je     80106297 <sys_open+0x189>
80106290:	b8 01 00 00 00       	mov    $0x1,%eax
80106295:	eb 05                	jmp    8010629c <sys_open+0x18e>
80106297:	b8 00 00 00 00       	mov    $0x0,%eax
8010629c:	88 c2                	mov    %al,%dl
8010629e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a1:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
801062a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801062a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062aa:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
801062ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062b0:	c9                   	leave  
801062b1:	c3                   	ret    

801062b2 <sys_mkdir>:

int
sys_mkdir(void)
{
801062b2:	55                   	push   %ebp
801062b3:	89 e5                	mov    %esp,%ebp
801062b5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062b8:	e8 52 d3 ff ff       	call   8010360f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062cb:	e8 48 f5 ff ff       	call   80105818 <argstr>
801062d0:	85 c0                	test   %eax,%eax
801062d2:	78 2c                	js     80106300 <sys_mkdir+0x4e>
801062d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062de:	00 
801062df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062e6:	00 
801062e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062ee:	00 
801062ef:	89 04 24             	mov    %eax,(%esp)
801062f2:	e8 5c fc ff ff       	call   80105f53 <create>
801062f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062fe:	75 0c                	jne    8010630c <sys_mkdir+0x5a>
    end_op();
80106300:	e8 8c d3 ff ff       	call   80103691 <end_op>
    return -1;
80106305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630a:	eb 15                	jmp    80106321 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010630c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630f:	89 04 24             	mov    %eax,(%esp)
80106312:	e8 aa b9 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106317:	e8 75 d3 ff ff       	call   80103691 <end_op>
  return 0;
8010631c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106321:	c9                   	leave  
80106322:	c3                   	ret    

80106323 <sys_mknod>:

int
sys_mknod(void)
{
80106323:	55                   	push   %ebp
80106324:	89 e5                	mov    %esp,%ebp
80106326:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106329:	e8 e1 d2 ff ff       	call   8010360f <begin_op>
  if((argstr(0, &path)) < 0 ||
8010632e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106331:	89 44 24 04          	mov    %eax,0x4(%esp)
80106335:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010633c:	e8 d7 f4 ff ff       	call   80105818 <argstr>
80106341:	85 c0                	test   %eax,%eax
80106343:	78 5e                	js     801063a3 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106345:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106348:	89 44 24 04          	mov    %eax,0x4(%esp)
8010634c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106353:	e8 29 f4 ff ff       	call   80105781 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106358:	85 c0                	test   %eax,%eax
8010635a:	78 47                	js     801063a3 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010635c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010635f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106363:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010636a:	e8 12 f4 ff ff       	call   80105781 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010636f:	85 c0                	test   %eax,%eax
80106371:	78 30                	js     801063a3 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106373:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106376:	0f bf c8             	movswl %ax,%ecx
80106379:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010637c:	0f bf d0             	movswl %ax,%edx
8010637f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106382:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106386:	89 54 24 08          	mov    %edx,0x8(%esp)
8010638a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106391:	00 
80106392:	89 04 24             	mov    %eax,(%esp)
80106395:	e8 b9 fb ff ff       	call   80105f53 <create>
8010639a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010639d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063a1:	75 0c                	jne    801063af <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801063a3:	e8 e9 d2 ff ff       	call   80103691 <end_op>
    return -1;
801063a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ad:	eb 15                	jmp    801063c4 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801063af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b2:	89 04 24             	mov    %eax,(%esp)
801063b5:	e8 07 b9 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801063ba:	e8 d2 d2 ff ff       	call   80103691 <end_op>
  return 0;
801063bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063c4:	c9                   	leave  
801063c5:	c3                   	ret    

801063c6 <sys_chdir>:

int
sys_chdir(void)
{
801063c6:	55                   	push   %ebp
801063c7:	89 e5                	mov    %esp,%ebp
801063c9:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801063cc:	e8 3e df ff ff       	call   8010430f <myproc>
801063d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801063d4:	e8 36 d2 ff ff       	call   8010360f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801063d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801063e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e7:	e8 2c f4 ff ff       	call   80105818 <argstr>
801063ec:	85 c0                	test   %eax,%eax
801063ee:	78 14                	js     80106404 <sys_chdir+0x3e>
801063f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063f3:	89 04 24             	mov    %eax,(%esp)
801063f6:	e8 fc c1 ff ff       	call   801025f7 <namei>
801063fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106402:	75 0c                	jne    80106410 <sys_chdir+0x4a>
    end_op();
80106404:	e8 88 d2 ff ff       	call   80103691 <end_op>
    return -1;
80106409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640e:	eb 5a                	jmp    8010646a <sys_chdir+0xa4>
  }
  ilock(ip);
80106410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106413:	89 04 24             	mov    %eax,(%esp)
80106416:	e8 a7 b6 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
8010641b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641e:	8b 40 50             	mov    0x50(%eax),%eax
80106421:	66 83 f8 01          	cmp    $0x1,%ax
80106425:	74 17                	je     8010643e <sys_chdir+0x78>
    iunlockput(ip);
80106427:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642a:	89 04 24             	mov    %eax,(%esp)
8010642d:	e8 8f b8 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106432:	e8 5a d2 ff ff       	call   80103691 <end_op>
    return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	eb 2c                	jmp    8010646a <sys_chdir+0xa4>
  }
  iunlock(ip);
8010643e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106441:	89 04 24             	mov    %eax,(%esp)
80106444:	e8 83 b7 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644c:	8b 40 68             	mov    0x68(%eax),%eax
8010644f:	89 04 24             	mov    %eax,(%esp)
80106452:	e8 b9 b7 ff ff       	call   80101c10 <iput>
  end_op();
80106457:	e8 35 d2 ff ff       	call   80103691 <end_op>
  curproc->cwd = ip;
8010645c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106462:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106465:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646a:	c9                   	leave  
8010646b:	c3                   	ret    

8010646c <sys_exec>:

int
sys_exec(void)
{
8010646c:	55                   	push   %ebp
8010646d:	89 e5                	mov    %esp,%ebp
8010646f:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106475:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106478:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106483:	e8 90 f3 ff ff       	call   80105818 <argstr>
80106488:	85 c0                	test   %eax,%eax
8010648a:	78 1a                	js     801064a6 <sys_exec+0x3a>
8010648c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106492:	89 44 24 04          	mov    %eax,0x4(%esp)
80106496:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010649d:	e8 df f2 ff ff       	call   80105781 <argint>
801064a2:	85 c0                	test   %eax,%eax
801064a4:	79 0a                	jns    801064b0 <sys_exec+0x44>
    return -1;
801064a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ab:	e9 c7 00 00 00       	jmp    80106577 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
801064b0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801064b7:	00 
801064b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064bf:	00 
801064c0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064c6:	89 04 24             	mov    %eax,(%esp)
801064c9:	e8 80 ef ff ff       	call   8010544e <memset>
  for(i=0;; i++){
801064ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801064d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d8:	83 f8 1f             	cmp    $0x1f,%eax
801064db:	76 0a                	jbe    801064e7 <sys_exec+0x7b>
      return -1;
801064dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e2:	e9 90 00 00 00       	jmp    80106577 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	c1 e0 02             	shl    $0x2,%eax
801064ed:	89 c2                	mov    %eax,%edx
801064ef:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064f5:	01 c2                	add    %eax,%edx
801064f7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801064fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106501:	89 14 24             	mov    %edx,(%esp)
80106504:	e8 d7 f1 ff ff       	call   801056e0 <fetchint>
80106509:	85 c0                	test   %eax,%eax
8010650b:	79 07                	jns    80106514 <sys_exec+0xa8>
      return -1;
8010650d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106512:	eb 63                	jmp    80106577 <sys_exec+0x10b>
    if(uarg == 0){
80106514:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010651a:	85 c0                	test   %eax,%eax
8010651c:	75 26                	jne    80106544 <sys_exec+0xd8>
      argv[i] = 0;
8010651e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106521:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106528:	00 00 00 00 
      break;
8010652c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010652d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106530:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106536:	89 54 24 04          	mov    %edx,0x4(%esp)
8010653a:	89 04 24             	mov    %eax,(%esp)
8010653d:	e8 fe a6 ff ff       	call   80100c40 <exec>
80106542:	eb 33                	jmp    80106577 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106544:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010654a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010654d:	c1 e2 02             	shl    $0x2,%edx
80106550:	01 c2                	add    %eax,%edx
80106552:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106558:	89 54 24 04          	mov    %edx,0x4(%esp)
8010655c:	89 04 24             	mov    %eax,(%esp)
8010655f:	e8 bb f1 ff ff       	call   8010571f <fetchstr>
80106564:	85 c0                	test   %eax,%eax
80106566:	79 07                	jns    8010656f <sys_exec+0x103>
      return -1;
80106568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656d:	eb 08                	jmp    80106577 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010656f:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106572:	e9 5e ff ff ff       	jmp    801064d5 <sys_exec+0x69>
  return exec(path, argv);
}
80106577:	c9                   	leave  
80106578:	c3                   	ret    

80106579 <sys_pipe>:

int
sys_pipe(void)
{
80106579:	55                   	push   %ebp
8010657a:	89 e5                	mov    %esp,%ebp
8010657c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010657f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106586:	00 
80106587:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010658a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010658e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106595:	e8 14 f2 ff ff       	call   801057ae <argptr>
8010659a:	85 c0                	test   %eax,%eax
8010659c:	79 0a                	jns    801065a8 <sys_pipe+0x2f>
    return -1;
8010659e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a3:	e9 9a 00 00 00       	jmp    80106642 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801065a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801065af:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065b2:	89 04 24             	mov    %eax,(%esp)
801065b5:	e8 aa d8 ff ff       	call   80103e64 <pipealloc>
801065ba:	85 c0                	test   %eax,%eax
801065bc:	79 07                	jns    801065c5 <sys_pipe+0x4c>
    return -1;
801065be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c3:	eb 7d                	jmp    80106642 <sys_pipe+0xc9>
  fd0 = -1;
801065c5:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801065cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065cf:	89 04 24             	mov    %eax,(%esp)
801065d2:	e8 75 f3 ff ff       	call   8010594c <fdalloc>
801065d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065de:	78 14                	js     801065f4 <sys_pipe+0x7b>
801065e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065e3:	89 04 24             	mov    %eax,(%esp)
801065e6:	e8 61 f3 ff ff       	call   8010594c <fdalloc>
801065eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065f2:	79 36                	jns    8010662a <sys_pipe+0xb1>
    if(fd0 >= 0)
801065f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065f8:	78 13                	js     8010660d <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801065fa:	e8 10 dd ff ff       	call   8010430f <myproc>
801065ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106602:	83 c2 08             	add    $0x8,%edx
80106605:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010660c:	00 
    fileclose(rf);
8010660d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106610:	89 04 24             	mov    %eax,(%esp)
80106613:	e8 92 ab ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010661b:	89 04 24             	mov    %eax,(%esp)
8010661e:	e8 87 ab ff ff       	call   801011aa <fileclose>
    return -1;
80106623:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106628:	eb 18                	jmp    80106642 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
8010662a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010662d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106630:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106632:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106635:	8d 50 04             	lea    0x4(%eax),%edx
80106638:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663b:	89 02                	mov    %eax,(%edx)
  return 0;
8010663d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106642:	c9                   	leave  
80106643:	c3                   	ret    

80106644 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106644:	55                   	push   %ebp
80106645:	89 e5                	mov    %esp,%ebp
80106647:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010664a:	e8 d9 df ff ff       	call   80104628 <fork>
}
8010664f:	c9                   	leave  
80106650:	c3                   	ret    

80106651 <sys_exit>:

int
sys_exit(void)
{
80106651:	55                   	push   %ebp
80106652:	89 e5                	mov    %esp,%ebp
80106654:	83 ec 08             	sub    $0x8,%esp
  exit();
80106657:	e8 44 e1 ff ff       	call   801047a0 <exit>
  return 0;  // not reached
8010665c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106661:	c9                   	leave  
80106662:	c3                   	ret    

80106663 <sys_wait>:

int
sys_wait(void)
{
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106669:	e8 76 e2 ff ff       	call   801048e4 <wait>
}
8010666e:	c9                   	leave  
8010666f:	c3                   	ret    

80106670 <sys_kill>:

int
sys_kill(void)
{
80106670:	55                   	push   %ebp
80106671:	89 e5                	mov    %esp,%ebp
80106673:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106676:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106679:	89 44 24 04          	mov    %eax,0x4(%esp)
8010667d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106684:	e8 f8 f0 ff ff       	call   80105781 <argint>
80106689:	85 c0                	test   %eax,%eax
8010668b:	79 07                	jns    80106694 <sys_kill+0x24>
    return -1;
8010668d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106692:	eb 0b                	jmp    8010669f <sys_kill+0x2f>
  return kill(pid);
80106694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106697:	89 04 24             	mov    %eax,(%esp)
8010669a:	e8 23 e6 ff ff       	call   80104cc2 <kill>
}
8010669f:	c9                   	leave  
801066a0:	c3                   	ret    

801066a1 <sys_getpid>:

int
sys_getpid(void)
{
801066a1:	55                   	push   %ebp
801066a2:	89 e5                	mov    %esp,%ebp
801066a4:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801066a7:	e8 63 dc ff ff       	call   8010430f <myproc>
801066ac:	8b 40 10             	mov    0x10(%eax),%eax
}
801066af:	c9                   	leave  
801066b0:	c3                   	ret    

801066b1 <sys_sbrk>:

int
sys_sbrk(void)
{
801066b1:	55                   	push   %ebp
801066b2:	89 e5                	mov    %esp,%ebp
801066b4:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801066b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801066be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066c5:	e8 b7 f0 ff ff       	call   80105781 <argint>
801066ca:	85 c0                	test   %eax,%eax
801066cc:	79 07                	jns    801066d5 <sys_sbrk+0x24>
    return -1;
801066ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d3:	eb 23                	jmp    801066f8 <sys_sbrk+0x47>
  addr = myproc()->sz;
801066d5:	e8 35 dc ff ff       	call   8010430f <myproc>
801066da:	8b 00                	mov    (%eax),%eax
801066dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801066df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e2:	89 04 24             	mov    %eax,(%esp)
801066e5:	e8 a0 de ff ff       	call   8010458a <growproc>
801066ea:	85 c0                	test   %eax,%eax
801066ec:	79 07                	jns    801066f5 <sys_sbrk+0x44>
    return -1;
801066ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f3:	eb 03                	jmp    801066f8 <sys_sbrk+0x47>
  return addr;
801066f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066f8:	c9                   	leave  
801066f9:	c3                   	ret    

801066fa <sys_sleep>:

int
sys_sleep(void)
{
801066fa:	55                   	push   %ebp
801066fb:	89 e5                	mov    %esp,%ebp
801066fd:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106700:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106703:	89 44 24 04          	mov    %eax,0x4(%esp)
80106707:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010670e:	e8 6e f0 ff ff       	call   80105781 <argint>
80106713:	85 c0                	test   %eax,%eax
80106715:	79 07                	jns    8010671e <sys_sleep+0x24>
    return -1;
80106717:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671c:	eb 6b                	jmp    80106789 <sys_sleep+0x8f>
  acquire(&tickslock);
8010671e:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106725:	e8 c1 ea ff ff       	call   801051eb <acquire>
  ticks0 = ticks;
8010672a:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
8010672f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106732:	eb 33                	jmp    80106767 <sys_sleep+0x6d>
    if(myproc()->killed){
80106734:	e8 d6 db ff ff       	call   8010430f <myproc>
80106739:	8b 40 24             	mov    0x24(%eax),%eax
8010673c:	85 c0                	test   %eax,%eax
8010673e:	74 13                	je     80106753 <sys_sleep+0x59>
      release(&tickslock);
80106740:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106747:	e8 09 eb ff ff       	call   80105255 <release>
      return -1;
8010674c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106751:	eb 36                	jmp    80106789 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106753:	c7 44 24 04 60 73 11 	movl   $0x80117360,0x4(%esp)
8010675a:	80 
8010675b:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
80106762:	e8 59 e4 ff ff       	call   80104bc0 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106767:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
8010676c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010676f:	89 c2                	mov    %eax,%edx
80106771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106774:	39 c2                	cmp    %eax,%edx
80106776:	72 bc                	jb     80106734 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106778:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010677f:	e8 d1 ea ff ff       	call   80105255 <release>
  return 0;
80106784:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106789:	c9                   	leave  
8010678a:	c3                   	ret    

8010678b <sys_cstop>:

void sys_cstop(){
8010678b:	55                   	push   %ebp
8010678c:	89 e5                	mov    %esp,%ebp
8010678e:	53                   	push   %ebx
8010678f:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106792:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106795:	89 44 24 04          	mov    %eax,0x4(%esp)
80106799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067a0:	e8 73 f0 ff ff       	call   80105818 <argstr>

  if(myproc()->cont != NULL){
801067a5:	e8 65 db ff ff       	call   8010430f <myproc>
801067aa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801067b0:	85 c0                	test   %eax,%eax
801067b2:	74 72                	je     80106826 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
801067b4:	e8 56 db ff ff       	call   8010430f <myproc>
801067b9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801067bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
801067c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c5:	89 04 24             	mov    %eax,(%esp)
801067c8:	e8 d4 ee ff ff       	call   801056a1 <strlen>
801067cd:	89 c3                	mov    %eax,%ebx
801067cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d2:	83 c0 18             	add    $0x18,%eax
801067d5:	89 04 24             	mov    %eax,(%esp)
801067d8:	e8 c4 ee ff ff       	call   801056a1 <strlen>
801067dd:	39 c3                	cmp    %eax,%ebx
801067df:	75 37                	jne    80106818 <sys_cstop+0x8d>
801067e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e4:	89 04 24             	mov    %eax,(%esp)
801067e7:	e8 b5 ee ff ff       	call   801056a1 <strlen>
801067ec:	89 c2                	mov    %eax,%edx
801067ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f1:	8d 48 18             	lea    0x18(%eax),%ecx
801067f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f7:	89 54 24 08          	mov    %edx,0x8(%esp)
801067fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801067ff:	89 04 24             	mov    %eax,(%esp)
80106802:	e8 af ed ff ff       	call   801055b6 <strncmp>
80106807:	85 c0                	test   %eax,%eax
80106809:	75 0d                	jne    80106818 <sys_cstop+0x8d>
      cstop_container_helper(cont);
8010680b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680e:	89 04 24             	mov    %eax,(%esp)
80106811:	e8 66 e6 ff ff       	call   80104e7c <cstop_container_helper>
80106816:	eb 19                	jmp    80106831 <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106818:	c7 04 24 7c 96 10 80 	movl   $0x8010967c,(%esp)
8010681f:	e8 9d 9b ff ff       	call   801003c1 <cprintf>
80106824:	eb 0b                	jmp    80106831 <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106829:	89 04 24             	mov    %eax,(%esp)
8010682c:	e8 9c e6 ff ff       	call   80104ecd <cstop_helper>
  }

  //kill the processes with name as the id

}
80106831:	83 c4 24             	add    $0x24,%esp
80106834:	5b                   	pop    %ebx
80106835:	5d                   	pop    %ebp
80106836:	c3                   	ret    

80106837 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106837:	55                   	push   %ebp
80106838:	89 e5                	mov    %esp,%ebp
8010683a:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
8010683d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106840:	89 44 24 04          	mov    %eax,0x4(%esp)
80106844:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010684b:	e8 c8 ef ff ff       	call   80105818 <argstr>

  set_root_inode(name);
80106850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106853:	89 04 24             	mov    %eax,(%esp)
80106856:	e8 b0 22 00 00       	call   80108b0b <set_root_inode>
  cprintf("success\n");
8010685b:	c7 04 24 a0 96 10 80 	movl   $0x801096a0,(%esp)
80106862:	e8 5a 9b ff ff       	call   801003c1 <cprintf>

}
80106867:	c9                   	leave  
80106868:	c3                   	ret    

80106869 <sys_ps>:

void sys_ps(void){
80106869:	55                   	push   %ebp
8010686a:	89 e5                	mov    %esp,%ebp
8010686c:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
8010686f:	e8 9b da ff ff       	call   8010430f <myproc>
80106874:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010687a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
8010687d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106881:	75 07                	jne    8010688a <sys_ps+0x21>
    procdump();
80106883:	e8 b5 e4 ff ff       	call   80104d3d <procdump>
80106888:	eb 0e                	jmp    80106898 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
8010688a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688d:	83 c0 18             	add    $0x18,%eax
80106890:	89 04 24             	mov    %eax,(%esp)
80106893:	e8 b8 e6 ff ff       	call   80104f50 <c_procdump>
  }
}
80106898:	c9                   	leave  
80106899:	c3                   	ret    

8010689a <sys_container_init>:

void sys_container_init(){
8010689a:	55                   	push   %ebp
8010689b:	89 e5                	mov    %esp,%ebp
8010689d:	83 ec 08             	sub    $0x8,%esp
  container_init();
801068a0:	e8 3b 27 00 00       	call   80108fe0 <container_init>
}
801068a5:	c9                   	leave  
801068a6:	c3                   	ret    

801068a7 <sys_is_full>:

int sys_is_full(void){
801068a7:	55                   	push   %ebp
801068a8:	89 e5                	mov    %esp,%ebp
801068aa:	83 ec 08             	sub    $0x8,%esp
  return is_full();
801068ad:	e8 1d 23 00 00       	call   80108bcf <is_full>
}
801068b2:	c9                   	leave  
801068b3:	c3                   	ret    

801068b4 <sys_find>:

int sys_find(void){
801068b4:	55                   	push   %ebp
801068b5:	89 e5                	mov    %esp,%ebp
801068b7:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
801068ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801068c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068c8:	e8 4b ef ff ff       	call   80105818 <argstr>

  return find(name);
801068cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d0:	89 04 24             	mov    %eax,(%esp)
801068d3:	e8 47 23 00 00       	call   80108c1f <find>
}
801068d8:	c9                   	leave  
801068d9:	c3                   	ret    

801068da <sys_get_name>:

void sys_get_name(void){
801068da:	55                   	push   %ebp
801068db:	89 e5                	mov    %esp,%ebp
801068dd:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
801068e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801068e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068ee:	e8 8e ee ff ff       	call   80105781 <argint>
  argstr(1, &name);
801068f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801068fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106901:	e8 12 ef ff ff       	call   80105818 <argstr>

  get_name(vc_num, name);
80106906:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106910:	89 04 24             	mov    %eax,(%esp)
80106913:	e8 34 22 00 00       	call   80108b4c <get_name>
}
80106918:	c9                   	leave  
80106919:	c3                   	ret    

8010691a <sys_get_max_proc>:

int sys_get_max_proc(void){
8010691a:	55                   	push   %ebp
8010691b:	89 e5                	mov    %esp,%ebp
8010691d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106920:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106923:	89 44 24 04          	mov    %eax,0x4(%esp)
80106927:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010692e:	e8 4e ee ff ff       	call   80105781 <argint>


  return get_max_proc(vc_num);  
80106933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106936:	89 04 24             	mov    %eax,(%esp)
80106939:	e8 51 23 00 00       	call   80108c8f <get_max_proc>
}
8010693e:	c9                   	leave  
8010693f:	c3                   	ret    

80106940 <sys_get_max_mem>:

int sys_get_max_mem(void){
80106940:	55                   	push   %ebp
80106941:	89 e5                	mov    %esp,%ebp
80106943:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106946:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106949:	89 44 24 04          	mov    %eax,0x4(%esp)
8010694d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106954:	e8 28 ee ff ff       	call   80105781 <argint>


  return get_max_mem(vc_num);
80106959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010695c:	89 04 24             	mov    %eax,(%esp)
8010695f:	e8 93 23 00 00       	call   80108cf7 <get_max_mem>
}
80106964:	c9                   	leave  
80106965:	c3                   	ret    

80106966 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106966:	55                   	push   %ebp
80106967:	89 e5                	mov    %esp,%ebp
80106969:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010696c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010696f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106973:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010697a:	e8 02 ee ff ff       	call   80105781 <argint>


  return get_max_disk(vc_num);
8010697f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106982:	89 04 24             	mov    %eax,(%esp)
80106985:	e8 ad 23 00 00       	call   80108d37 <get_max_disk>

}
8010698a:	c9                   	leave  
8010698b:	c3                   	ret    

8010698c <sys_get_curr_proc>:

int sys_get_curr_proc(void){
8010698c:	55                   	push   %ebp
8010698d:	89 e5                	mov    %esp,%ebp
8010698f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106992:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106995:	89 44 24 04          	mov    %eax,0x4(%esp)
80106999:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069a0:	e8 dc ed ff ff       	call   80105781 <argint>


  return get_curr_proc(vc_num);
801069a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a8:	89 04 24             	mov    %eax,(%esp)
801069ab:	e8 c7 23 00 00       	call   80108d77 <get_curr_proc>
}
801069b0:	c9                   	leave  
801069b1:	c3                   	ret    

801069b2 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
801069b2:	55                   	push   %ebp
801069b3:	89 e5                	mov    %esp,%ebp
801069b5:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801069b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801069bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069c6:	e8 b6 ed ff ff       	call   80105781 <argint>


  return get_curr_mem(vc_num);
801069cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ce:	89 04 24             	mov    %eax,(%esp)
801069d1:	e8 e1 23 00 00       	call   80108db7 <get_curr_mem>
}
801069d6:	c9                   	leave  
801069d7:	c3                   	ret    

801069d8 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
801069d8:	55                   	push   %ebp
801069d9:	89 e5                	mov    %esp,%ebp
801069db:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801069de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069ec:	e8 90 ed ff ff       	call   80105781 <argint>


  return get_curr_disk(vc_num);
801069f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f4:	89 04 24             	mov    %eax,(%esp)
801069f7:	e8 0e 24 00 00       	call   80108e0a <get_curr_disk>
}
801069fc:	c9                   	leave  
801069fd:	c3                   	ret    

801069fe <sys_set_name>:

void sys_set_name(void){
801069fe:	55                   	push   %ebp
801069ff:	89 e5                	mov    %esp,%ebp
80106a01:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106a04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a12:	e8 01 ee ff ff       	call   80105818 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106a17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a25:	e8 57 ed ff ff       	call   80105781 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a30:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a34:	89 04 24             	mov    %eax,(%esp)
80106a37:	e8 0e 24 00 00       	call   80108e4a <set_name>
  //cprintf("Done setting name.\n");
}
80106a3c:	c9                   	leave  
80106a3d:	c3                   	ret    

80106a3e <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106a3e:	55                   	push   %ebp
80106a3f:	89 e5                	mov    %esp,%ebp
80106a41:	53                   	push   %ebx
80106a42:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106a45:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a53:	e8 29 ed ff ff       	call   80105781 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106a58:	e8 b2 d8 ff ff       	call   8010430f <myproc>
80106a5d:	89 c3                	mov    %eax,%ebx
80106a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a62:	89 04 24             	mov    %eax,(%esp)
80106a65:	e8 65 22 00 00       	call   80108ccf <get_container>
80106a6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106a70:	83 c4 24             	add    $0x24,%esp
80106a73:	5b                   	pop    %ebx
80106a74:	5d                   	pop    %ebp
80106a75:	c3                   	ret    

80106a76 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106a76:	55                   	push   %ebp
80106a77:	89 e5                	mov    %esp,%ebp
80106a79:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106a7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a8a:	e8 f2 ec ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106a8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a92:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a9d:	e8 df ec ff ff       	call   80105781 <argint>

  set_max_mem(mem, vc_num);
80106aa2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106aac:	89 04 24             	mov    %eax,(%esp)
80106aaf:	e8 cd 23 00 00       	call   80108e81 <set_max_mem>
}
80106ab4:	c9                   	leave  
80106ab5:	c3                   	ret    

80106ab6 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106ab6:	55                   	push   %ebp
80106ab7:	89 e5                	mov    %esp,%ebp
80106ab9:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106abc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106abf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aca:	e8 b2 ec ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106acf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ad6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106add:	e8 9f ec ff ff       	call   80105781 <argint>

  set_max_disk(disk, vc_num);
80106ae2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106aec:	89 04 24             	mov    %eax,(%esp)
80106aef:	e8 b2 23 00 00       	call   80108ea6 <set_max_disk>
}
80106af4:	c9                   	leave  
80106af5:	c3                   	ret    

80106af6 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106af6:	55                   	push   %ebp
80106af7:	89 e5                	mov    %esp,%ebp
80106af9:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b0a:	e8 72 ec ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106b0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b12:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b1d:	e8 5f ec ff ff       	call   80105781 <argint>

  set_max_proc(proc, vc_num);
80106b22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b28:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b2c:	89 04 24             	mov    %eax,(%esp)
80106b2f:	e8 98 23 00 00       	call   80108ecc <set_max_proc>
}
80106b34:	c9                   	leave  
80106b35:	c3                   	ret    

80106b36 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106b36:	55                   	push   %ebp
80106b37:	89 e5                	mov    %esp,%ebp
80106b39:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106b3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b4a:	e8 32 ec ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106b4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b52:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b5d:	e8 1f ec ff ff       	call   80105781 <argint>

  set_curr_mem(mem, vc_num);
80106b62:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b68:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b6c:	89 04 24             	mov    %eax,(%esp)
80106b6f:	e8 7e 23 00 00       	call   80108ef2 <set_curr_mem>
}
80106b74:	c9                   	leave  
80106b75:	c3                   	ret    

80106b76 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106b76:	55                   	push   %ebp
80106b77:	89 e5                	mov    %esp,%ebp
80106b79:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b8a:	e8 f2 eb ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106b8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b92:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b9d:	e8 df eb ff ff       	call   80105781 <argint>

  set_curr_mem(mem, vc_num);
80106ba2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bac:	89 04 24             	mov    %eax,(%esp)
80106baf:	e8 3e 23 00 00       	call   80108ef2 <set_curr_mem>
}
80106bb4:	c9                   	leave  
80106bb5:	c3                   	ret    

80106bb6 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106bb6:	55                   	push   %ebp
80106bb7:	89 e5                	mov    %esp,%ebp
80106bb9:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bca:	e8 b2 eb ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106bdd:	e8 9f eb ff ff       	call   80105781 <argint>

  set_curr_disk(disk, vc_num);
80106be2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bec:	89 04 24             	mov    %eax,(%esp)
80106bef:	e8 82 23 00 00       	call   80108f76 <set_curr_disk>
}
80106bf4:	c9                   	leave  
80106bf5:	c3                   	ret    

80106bf6 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106bf6:	55                   	push   %ebp
80106bf7:	89 e5                	mov    %esp,%ebp
80106bf9:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106bfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c0a:	e8 72 eb ff ff       	call   80105781 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c12:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c1d:	e8 5f eb ff ff       	call   80105781 <argint>

  set_curr_proc(proc, vc_num);
80106c22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c28:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c2c:	89 04 24             	mov    %eax,(%esp)
80106c2f:	e8 87 23 00 00       	call   80108fbb <set_curr_proc>
}
80106c34:	c9                   	leave  
80106c35:	c3                   	ret    

80106c36 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106c36:	55                   	push   %ebp
80106c37:	89 e5                	mov    %esp,%ebp
80106c39:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106c3c:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106c43:	e8 a3 e5 ff ff       	call   801051eb <acquire>
  xticks = ticks;
80106c48:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106c4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106c50:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106c57:	e8 f9 e5 ff ff       	call   80105255 <release>
  return xticks;
80106c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106c5f:	c9                   	leave  
80106c60:	c3                   	ret    

80106c61 <sys_getticks>:

int
sys_getticks(void)
{
80106c61:	55                   	push   %ebp
80106c62:	89 e5                	mov    %esp,%ebp
80106c64:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106c67:	e8 a3 d6 ff ff       	call   8010430f <myproc>
80106c6c:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106c6f:	c9                   	leave  
80106c70:	c3                   	ret    
80106c71:	00 00                	add    %al,(%eax)
	...

80106c74 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106c74:	1e                   	push   %ds
  pushl %es
80106c75:	06                   	push   %es
  pushl %fs
80106c76:	0f a0                	push   %fs
  pushl %gs
80106c78:	0f a8                	push   %gs
  pushal
80106c7a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106c7b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106c7f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106c81:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106c83:	54                   	push   %esp
  call trap
80106c84:	e8 c0 01 00 00       	call   80106e49 <trap>
  addl $4, %esp
80106c89:	83 c4 04             	add    $0x4,%esp

80106c8c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106c8c:	61                   	popa   
  popl %gs
80106c8d:	0f a9                	pop    %gs
  popl %fs
80106c8f:	0f a1                	pop    %fs
  popl %es
80106c91:	07                   	pop    %es
  popl %ds
80106c92:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106c93:	83 c4 08             	add    $0x8,%esp
  iret
80106c96:	cf                   	iret   
	...

80106c98 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106c98:	55                   	push   %ebp
80106c99:	89 e5                	mov    %esp,%ebp
80106c9b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ca1:	48                   	dec    %eax
80106ca2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106cad:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb0:	c1 e8 10             	shr    $0x10,%eax
80106cb3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106cb7:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106cba:	0f 01 18             	lidtl  (%eax)
}
80106cbd:	c9                   	leave  
80106cbe:	c3                   	ret    

80106cbf <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106cbf:	55                   	push   %ebp
80106cc0:	89 e5                	mov    %esp,%ebp
80106cc2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106cc5:	0f 20 d0             	mov    %cr2,%eax
80106cc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106cce:	c9                   	leave  
80106ccf:	c3                   	ret    

80106cd0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106cd0:	55                   	push   %ebp
80106cd1:	89 e5                	mov    %esp,%ebp
80106cd3:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106cd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106cdd:	e9 b8 00 00 00       	jmp    80106d9a <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce5:	8b 04 85 f4 c0 10 80 	mov    -0x7fef3f0c(,%eax,4),%eax
80106cec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106cef:	66 89 04 d5 a0 73 11 	mov    %ax,-0x7fee8c60(,%edx,8)
80106cf6:	80 
80106cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cfa:	66 c7 04 c5 a2 73 11 	movw   $0x8,-0x7fee8c5e(,%eax,8)
80106d01:	80 08 00 
80106d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d07:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106d0e:	83 e2 e0             	and    $0xffffffe0,%edx
80106d11:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d1b:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106d22:	83 e2 1f             	and    $0x1f,%edx
80106d25:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d2f:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106d36:	83 e2 f0             	and    $0xfffffff0,%edx
80106d39:	83 ca 0e             	or     $0xe,%edx
80106d3c:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d46:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106d4d:	83 e2 ef             	and    $0xffffffef,%edx
80106d50:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d5a:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106d61:	83 e2 9f             	and    $0xffffff9f,%edx
80106d64:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d6e:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80106d75:	83 ca 80             	or     $0xffffff80,%edx
80106d78:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80106d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d82:	8b 04 85 f4 c0 10 80 	mov    -0x7fef3f0c(,%eax,4),%eax
80106d89:	c1 e8 10             	shr    $0x10,%eax
80106d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d8f:	66 89 04 d5 a6 73 11 	mov    %ax,-0x7fee8c5a(,%edx,8)
80106d96:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106d97:	ff 45 f4             	incl   -0xc(%ebp)
80106d9a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106da1:	0f 8e 3b ff ff ff    	jle    80106ce2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106da7:	a1 f4 c1 10 80       	mov    0x8010c1f4,%eax
80106dac:	66 a3 a0 75 11 80    	mov    %ax,0x801175a0
80106db2:	66 c7 05 a2 75 11 80 	movw   $0x8,0x801175a2
80106db9:	08 00 
80106dbb:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106dc0:	83 e0 e0             	and    $0xffffffe0,%eax
80106dc3:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106dc8:	a0 a4 75 11 80       	mov    0x801175a4,%al
80106dcd:	83 e0 1f             	and    $0x1f,%eax
80106dd0:	a2 a4 75 11 80       	mov    %al,0x801175a4
80106dd5:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106dda:	83 c8 0f             	or     $0xf,%eax
80106ddd:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106de2:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106de7:	83 e0 ef             	and    $0xffffffef,%eax
80106dea:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106def:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106df4:	83 c8 60             	or     $0x60,%eax
80106df7:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106dfc:	a0 a5 75 11 80       	mov    0x801175a5,%al
80106e01:	83 c8 80             	or     $0xffffff80,%eax
80106e04:	a2 a5 75 11 80       	mov    %al,0x801175a5
80106e09:	a1 f4 c1 10 80       	mov    0x8010c1f4,%eax
80106e0e:	c1 e8 10             	shr    $0x10,%eax
80106e11:	66 a3 a6 75 11 80    	mov    %ax,0x801175a6

  initlock(&tickslock, "time");
80106e17:	c7 44 24 04 ac 96 10 	movl   $0x801096ac,0x4(%esp)
80106e1e:	80 
80106e1f:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106e26:	e8 9f e3 ff ff       	call   801051ca <initlock>
}
80106e2b:	c9                   	leave  
80106e2c:	c3                   	ret    

80106e2d <idtinit>:

void
idtinit(void)
{
80106e2d:	55                   	push   %ebp
80106e2e:	89 e5                	mov    %esp,%ebp
80106e30:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106e33:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106e3a:	00 
80106e3b:	c7 04 24 a0 73 11 80 	movl   $0x801173a0,(%esp)
80106e42:	e8 51 fe ff ff       	call   80106c98 <lidt>
}
80106e47:	c9                   	leave  
80106e48:	c3                   	ret    

80106e49 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106e49:	55                   	push   %ebp
80106e4a:	89 e5                	mov    %esp,%ebp
80106e4c:	57                   	push   %edi
80106e4d:	56                   	push   %esi
80106e4e:	53                   	push   %ebx
80106e4f:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106e52:	8b 45 08             	mov    0x8(%ebp),%eax
80106e55:	8b 40 30             	mov    0x30(%eax),%eax
80106e58:	83 f8 40             	cmp    $0x40,%eax
80106e5b:	75 3c                	jne    80106e99 <trap+0x50>
    if(myproc()->killed)
80106e5d:	e8 ad d4 ff ff       	call   8010430f <myproc>
80106e62:	8b 40 24             	mov    0x24(%eax),%eax
80106e65:	85 c0                	test   %eax,%eax
80106e67:	74 05                	je     80106e6e <trap+0x25>
      exit();
80106e69:	e8 32 d9 ff ff       	call   801047a0 <exit>
    myproc()->tf = tf;
80106e6e:	e8 9c d4 ff ff       	call   8010430f <myproc>
80106e73:	8b 55 08             	mov    0x8(%ebp),%edx
80106e76:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106e79:	e8 d1 e9 ff ff       	call   8010584f <syscall>
    if(myproc()->killed)
80106e7e:	e8 8c d4 ff ff       	call   8010430f <myproc>
80106e83:	8b 40 24             	mov    0x24(%eax),%eax
80106e86:	85 c0                	test   %eax,%eax
80106e88:	74 0a                	je     80106e94 <trap+0x4b>
      exit();
80106e8a:	e8 11 d9 ff ff       	call   801047a0 <exit>
    return;
80106e8f:	e9 30 02 00 00       	jmp    801070c4 <trap+0x27b>
80106e94:	e9 2b 02 00 00       	jmp    801070c4 <trap+0x27b>
  }

  switch(tf->trapno){
80106e99:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9c:	8b 40 30             	mov    0x30(%eax),%eax
80106e9f:	83 e8 20             	sub    $0x20,%eax
80106ea2:	83 f8 1f             	cmp    $0x1f,%eax
80106ea5:	0f 87 cb 00 00 00    	ja     80106f76 <trap+0x12d>
80106eab:	8b 04 85 54 97 10 80 	mov    -0x7fef68ac(,%eax,4),%eax
80106eb2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106eb4:	e8 8d d3 ff ff       	call   80104246 <cpuid>
80106eb9:	85 c0                	test   %eax,%eax
80106ebb:	75 2f                	jne    80106eec <trap+0xa3>
      acquire(&tickslock);
80106ebd:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106ec4:	e8 22 e3 ff ff       	call   801051eb <acquire>
      ticks++;
80106ec9:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106ece:	40                   	inc    %eax
80106ecf:	a3 a0 7b 11 80       	mov    %eax,0x80117ba0
      wakeup(&ticks);
80106ed4:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
80106edb:	e8 b7 dd ff ff       	call   80104c97 <wakeup>
      release(&tickslock);
80106ee0:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106ee7:	e8 69 e3 ff ff       	call   80105255 <release>
    }
    p = myproc();
80106eec:	e8 1e d4 ff ff       	call   8010430f <myproc>
80106ef1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80106ef4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106ef8:	74 0f                	je     80106f09 <trap+0xc0>
      p->ticks++;
80106efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106efd:	8b 40 7c             	mov    0x7c(%eax),%eax
80106f00:	8d 50 01             	lea    0x1(%eax),%edx
80106f03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f06:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106f09:	e8 d9 c1 ff ff       	call   801030e7 <lapiceoi>
    break;
80106f0e:	e9 35 01 00 00       	jmp    80107048 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106f13:	e8 0a ba ff ff       	call   80102922 <ideintr>
    lapiceoi();
80106f18:	e8 ca c1 ff ff       	call   801030e7 <lapiceoi>
    break;
80106f1d:	e9 26 01 00 00       	jmp    80107048 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106f22:	e8 d7 bf ff ff       	call   80102efe <kbdintr>
    lapiceoi();
80106f27:	e8 bb c1 ff ff       	call   801030e7 <lapiceoi>
    break;
80106f2c:	e9 17 01 00 00       	jmp    80107048 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106f31:	e8 6f 03 00 00       	call   801072a5 <uartintr>
    lapiceoi();
80106f36:	e8 ac c1 ff ff       	call   801030e7 <lapiceoi>
    break;
80106f3b:	e9 08 01 00 00       	jmp    80107048 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f40:	8b 45 08             	mov    0x8(%ebp),%eax
80106f43:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106f46:	8b 45 08             	mov    0x8(%ebp),%eax
80106f49:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f4c:	0f b7 d8             	movzwl %ax,%ebx
80106f4f:	e8 f2 d2 ff ff       	call   80104246 <cpuid>
80106f54:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106f58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f60:	c7 04 24 b4 96 10 80 	movl   $0x801096b4,(%esp)
80106f67:	e8 55 94 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106f6c:	e8 76 c1 ff ff       	call   801030e7 <lapiceoi>
    break;
80106f71:	e9 d2 00 00 00       	jmp    80107048 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106f76:	e8 94 d3 ff ff       	call   8010430f <myproc>
80106f7b:	85 c0                	test   %eax,%eax
80106f7d:	74 10                	je     80106f8f <trap+0x146>
80106f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f82:	8b 40 3c             	mov    0x3c(%eax),%eax
80106f85:	0f b7 c0             	movzwl %ax,%eax
80106f88:	83 e0 03             	and    $0x3,%eax
80106f8b:	85 c0                	test   %eax,%eax
80106f8d:	75 40                	jne    80106fcf <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106f8f:	e8 2b fd ff ff       	call   80106cbf <rcr2>
80106f94:	89 c3                	mov    %eax,%ebx
80106f96:	8b 45 08             	mov    0x8(%ebp),%eax
80106f99:	8b 70 38             	mov    0x38(%eax),%esi
80106f9c:	e8 a5 d2 ff ff       	call   80104246 <cpuid>
80106fa1:	8b 55 08             	mov    0x8(%ebp),%edx
80106fa4:	8b 52 30             	mov    0x30(%edx),%edx
80106fa7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106fab:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106faf:	89 44 24 08          	mov    %eax,0x8(%esp)
80106fb3:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fb7:	c7 04 24 d8 96 10 80 	movl   $0x801096d8,(%esp)
80106fbe:	e8 fe 93 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106fc3:	c7 04 24 0a 97 10 80 	movl   $0x8010970a,(%esp)
80106fca:	e8 85 95 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106fcf:	e8 eb fc ff ff       	call   80106cbf <rcr2>
80106fd4:	89 c6                	mov    %eax,%esi
80106fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd9:	8b 40 38             	mov    0x38(%eax),%eax
80106fdc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106fdf:	e8 62 d2 ff ff       	call   80104246 <cpuid>
80106fe4:	89 c3                	mov    %eax,%ebx
80106fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80106fe9:	8b 78 34             	mov    0x34(%eax),%edi
80106fec:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106fef:	8b 45 08             	mov    0x8(%ebp),%eax
80106ff2:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ff5:	e8 15 d3 ff ff       	call   8010430f <myproc>
80106ffa:	8d 50 6c             	lea    0x6c(%eax),%edx
80106ffd:	89 55 cc             	mov    %edx,-0x34(%ebp)
80107000:	e8 0a d3 ff ff       	call   8010430f <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107005:	8b 40 10             	mov    0x10(%eax),%eax
80107008:	89 74 24 1c          	mov    %esi,0x1c(%esp)
8010700c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010700f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80107013:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107017:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010701a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010701e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80107022:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107025:	89 54 24 08          	mov    %edx,0x8(%esp)
80107029:	89 44 24 04          	mov    %eax,0x4(%esp)
8010702d:	c7 04 24 10 97 10 80 	movl   $0x80109710,(%esp)
80107034:	e8 88 93 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107039:	e8 d1 d2 ff ff       	call   8010430f <myproc>
8010703e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107045:	eb 01                	jmp    80107048 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107047:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107048:	e8 c2 d2 ff ff       	call   8010430f <myproc>
8010704d:	85 c0                	test   %eax,%eax
8010704f:	74 22                	je     80107073 <trap+0x22a>
80107051:	e8 b9 d2 ff ff       	call   8010430f <myproc>
80107056:	8b 40 24             	mov    0x24(%eax),%eax
80107059:	85 c0                	test   %eax,%eax
8010705b:	74 16                	je     80107073 <trap+0x22a>
8010705d:	8b 45 08             	mov    0x8(%ebp),%eax
80107060:	8b 40 3c             	mov    0x3c(%eax),%eax
80107063:	0f b7 c0             	movzwl %ax,%eax
80107066:	83 e0 03             	and    $0x3,%eax
80107069:	83 f8 03             	cmp    $0x3,%eax
8010706c:	75 05                	jne    80107073 <trap+0x22a>
    exit();
8010706e:	e8 2d d7 ff ff       	call   801047a0 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107073:	e8 97 d2 ff ff       	call   8010430f <myproc>
80107078:	85 c0                	test   %eax,%eax
8010707a:	74 1d                	je     80107099 <trap+0x250>
8010707c:	e8 8e d2 ff ff       	call   8010430f <myproc>
80107081:	8b 40 0c             	mov    0xc(%eax),%eax
80107084:	83 f8 04             	cmp    $0x4,%eax
80107087:	75 10                	jne    80107099 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107089:	8b 45 08             	mov    0x8(%ebp),%eax
8010708c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010708f:	83 f8 20             	cmp    $0x20,%eax
80107092:	75 05                	jne    80107099 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107094:	e8 b7 da ff ff       	call   80104b50 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107099:	e8 71 d2 ff ff       	call   8010430f <myproc>
8010709e:	85 c0                	test   %eax,%eax
801070a0:	74 22                	je     801070c4 <trap+0x27b>
801070a2:	e8 68 d2 ff ff       	call   8010430f <myproc>
801070a7:	8b 40 24             	mov    0x24(%eax),%eax
801070aa:	85 c0                	test   %eax,%eax
801070ac:	74 16                	je     801070c4 <trap+0x27b>
801070ae:	8b 45 08             	mov    0x8(%ebp),%eax
801070b1:	8b 40 3c             	mov    0x3c(%eax),%eax
801070b4:	0f b7 c0             	movzwl %ax,%eax
801070b7:	83 e0 03             	and    $0x3,%eax
801070ba:	83 f8 03             	cmp    $0x3,%eax
801070bd:	75 05                	jne    801070c4 <trap+0x27b>
    exit();
801070bf:	e8 dc d6 ff ff       	call   801047a0 <exit>
}
801070c4:	83 c4 4c             	add    $0x4c,%esp
801070c7:	5b                   	pop    %ebx
801070c8:	5e                   	pop    %esi
801070c9:	5f                   	pop    %edi
801070ca:	5d                   	pop    %ebp
801070cb:	c3                   	ret    

801070cc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801070cc:	55                   	push   %ebp
801070cd:	89 e5                	mov    %esp,%ebp
801070cf:	83 ec 14             	sub    $0x14,%esp
801070d2:	8b 45 08             	mov    0x8(%ebp),%eax
801070d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801070d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070dc:	89 c2                	mov    %eax,%edx
801070de:	ec                   	in     (%dx),%al
801070df:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801070e2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801070e5:	c9                   	leave  
801070e6:	c3                   	ret    

801070e7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801070e7:	55                   	push   %ebp
801070e8:	89 e5                	mov    %esp,%ebp
801070ea:	83 ec 08             	sub    $0x8,%esp
801070ed:	8b 45 08             	mov    0x8(%ebp),%eax
801070f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801070f3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801070f7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801070fa:	8a 45 f8             	mov    -0x8(%ebp),%al
801070fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107100:	ee                   	out    %al,(%dx)
}
80107101:	c9                   	leave  
80107102:	c3                   	ret    

80107103 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107103:	55                   	push   %ebp
80107104:	89 e5                	mov    %esp,%ebp
80107106:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107109:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107110:	00 
80107111:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107118:	e8 ca ff ff ff       	call   801070e7 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010711d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107124:	00 
80107125:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010712c:	e8 b6 ff ff ff       	call   801070e7 <outb>
  outb(COM1+0, 115200/9600);
80107131:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107138:	00 
80107139:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107140:	e8 a2 ff ff ff       	call   801070e7 <outb>
  outb(COM1+1, 0);
80107145:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010714c:	00 
8010714d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107154:	e8 8e ff ff ff       	call   801070e7 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107159:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107160:	00 
80107161:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107168:	e8 7a ff ff ff       	call   801070e7 <outb>
  outb(COM1+4, 0);
8010716d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107174:	00 
80107175:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010717c:	e8 66 ff ff ff       	call   801070e7 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107181:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107188:	00 
80107189:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107190:	e8 52 ff ff ff       	call   801070e7 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107195:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010719c:	e8 2b ff ff ff       	call   801070cc <inb>
801071a1:	3c ff                	cmp    $0xff,%al
801071a3:	75 02                	jne    801071a7 <uartinit+0xa4>
    return;
801071a5:	eb 5b                	jmp    80107202 <uartinit+0xff>
  uart = 1;
801071a7:	c7 05 04 c9 10 80 01 	movl   $0x1,0x8010c904
801071ae:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801071b1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801071b8:	e8 0f ff ff ff       	call   801070cc <inb>
  inb(COM1+0);
801071bd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801071c4:	e8 03 ff ff ff       	call   801070cc <inb>
  ioapicenable(IRQ_COM1, 0);
801071c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801071d0:	00 
801071d1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801071d8:	e8 ba b9 ff ff       	call   80102b97 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801071dd:	c7 45 f4 d4 97 10 80 	movl   $0x801097d4,-0xc(%ebp)
801071e4:	eb 13                	jmp    801071f9 <uartinit+0xf6>
    uartputc(*p);
801071e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e9:	8a 00                	mov    (%eax),%al
801071eb:	0f be c0             	movsbl %al,%eax
801071ee:	89 04 24             	mov    %eax,(%esp)
801071f1:	e8 0e 00 00 00       	call   80107204 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801071f6:	ff 45 f4             	incl   -0xc(%ebp)
801071f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fc:	8a 00                	mov    (%eax),%al
801071fe:	84 c0                	test   %al,%al
80107200:	75 e4                	jne    801071e6 <uartinit+0xe3>
    uartputc(*p);
}
80107202:	c9                   	leave  
80107203:	c3                   	ret    

80107204 <uartputc>:

void
uartputc(int c)
{
80107204:	55                   	push   %ebp
80107205:	89 e5                	mov    %esp,%ebp
80107207:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010720a:	a1 04 c9 10 80       	mov    0x8010c904,%eax
8010720f:	85 c0                	test   %eax,%eax
80107211:	75 02                	jne    80107215 <uartputc+0x11>
    return;
80107213:	eb 4a                	jmp    8010725f <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107215:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010721c:	eb 0f                	jmp    8010722d <uartputc+0x29>
    microdelay(10);
8010721e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107225:	e8 e2 be ff ff       	call   8010310c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010722a:	ff 45 f4             	incl   -0xc(%ebp)
8010722d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107231:	7f 16                	jg     80107249 <uartputc+0x45>
80107233:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010723a:	e8 8d fe ff ff       	call   801070cc <inb>
8010723f:	0f b6 c0             	movzbl %al,%eax
80107242:	83 e0 20             	and    $0x20,%eax
80107245:	85 c0                	test   %eax,%eax
80107247:	74 d5                	je     8010721e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107249:	8b 45 08             	mov    0x8(%ebp),%eax
8010724c:	0f b6 c0             	movzbl %al,%eax
8010724f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107253:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010725a:	e8 88 fe ff ff       	call   801070e7 <outb>
}
8010725f:	c9                   	leave  
80107260:	c3                   	ret    

80107261 <uartgetc>:

static int
uartgetc(void)
{
80107261:	55                   	push   %ebp
80107262:	89 e5                	mov    %esp,%ebp
80107264:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107267:	a1 04 c9 10 80       	mov    0x8010c904,%eax
8010726c:	85 c0                	test   %eax,%eax
8010726e:	75 07                	jne    80107277 <uartgetc+0x16>
    return -1;
80107270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107275:	eb 2c                	jmp    801072a3 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107277:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010727e:	e8 49 fe ff ff       	call   801070cc <inb>
80107283:	0f b6 c0             	movzbl %al,%eax
80107286:	83 e0 01             	and    $0x1,%eax
80107289:	85 c0                	test   %eax,%eax
8010728b:	75 07                	jne    80107294 <uartgetc+0x33>
    return -1;
8010728d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107292:	eb 0f                	jmp    801072a3 <uartgetc+0x42>
  return inb(COM1+0);
80107294:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010729b:	e8 2c fe ff ff       	call   801070cc <inb>
801072a0:	0f b6 c0             	movzbl %al,%eax
}
801072a3:	c9                   	leave  
801072a4:	c3                   	ret    

801072a5 <uartintr>:

void
uartintr(void)
{
801072a5:	55                   	push   %ebp
801072a6:	89 e5                	mov    %esp,%ebp
801072a8:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801072ab:	c7 04 24 61 72 10 80 	movl   $0x80107261,(%esp)
801072b2:	e8 3e 95 ff ff       	call   801007f5 <consoleintr>
}
801072b7:	c9                   	leave  
801072b8:	c3                   	ret    
801072b9:	00 00                	add    %al,(%eax)
	...

801072bc <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $0
801072be:	6a 00                	push   $0x0
  jmp alltraps
801072c0:	e9 af f9 ff ff       	jmp    80106c74 <alltraps>

801072c5 <vector1>:
.globl vector1
vector1:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $1
801072c7:	6a 01                	push   $0x1
  jmp alltraps
801072c9:	e9 a6 f9 ff ff       	jmp    80106c74 <alltraps>

801072ce <vector2>:
.globl vector2
vector2:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $2
801072d0:	6a 02                	push   $0x2
  jmp alltraps
801072d2:	e9 9d f9 ff ff       	jmp    80106c74 <alltraps>

801072d7 <vector3>:
.globl vector3
vector3:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $3
801072d9:	6a 03                	push   $0x3
  jmp alltraps
801072db:	e9 94 f9 ff ff       	jmp    80106c74 <alltraps>

801072e0 <vector4>:
.globl vector4
vector4:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $4
801072e2:	6a 04                	push   $0x4
  jmp alltraps
801072e4:	e9 8b f9 ff ff       	jmp    80106c74 <alltraps>

801072e9 <vector5>:
.globl vector5
vector5:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $5
801072eb:	6a 05                	push   $0x5
  jmp alltraps
801072ed:	e9 82 f9 ff ff       	jmp    80106c74 <alltraps>

801072f2 <vector6>:
.globl vector6
vector6:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $6
801072f4:	6a 06                	push   $0x6
  jmp alltraps
801072f6:	e9 79 f9 ff ff       	jmp    80106c74 <alltraps>

801072fb <vector7>:
.globl vector7
vector7:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $7
801072fd:	6a 07                	push   $0x7
  jmp alltraps
801072ff:	e9 70 f9 ff ff       	jmp    80106c74 <alltraps>

80107304 <vector8>:
.globl vector8
vector8:
  pushl $8
80107304:	6a 08                	push   $0x8
  jmp alltraps
80107306:	e9 69 f9 ff ff       	jmp    80106c74 <alltraps>

8010730b <vector9>:
.globl vector9
vector9:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $9
8010730d:	6a 09                	push   $0x9
  jmp alltraps
8010730f:	e9 60 f9 ff ff       	jmp    80106c74 <alltraps>

80107314 <vector10>:
.globl vector10
vector10:
  pushl $10
80107314:	6a 0a                	push   $0xa
  jmp alltraps
80107316:	e9 59 f9 ff ff       	jmp    80106c74 <alltraps>

8010731b <vector11>:
.globl vector11
vector11:
  pushl $11
8010731b:	6a 0b                	push   $0xb
  jmp alltraps
8010731d:	e9 52 f9 ff ff       	jmp    80106c74 <alltraps>

80107322 <vector12>:
.globl vector12
vector12:
  pushl $12
80107322:	6a 0c                	push   $0xc
  jmp alltraps
80107324:	e9 4b f9 ff ff       	jmp    80106c74 <alltraps>

80107329 <vector13>:
.globl vector13
vector13:
  pushl $13
80107329:	6a 0d                	push   $0xd
  jmp alltraps
8010732b:	e9 44 f9 ff ff       	jmp    80106c74 <alltraps>

80107330 <vector14>:
.globl vector14
vector14:
  pushl $14
80107330:	6a 0e                	push   $0xe
  jmp alltraps
80107332:	e9 3d f9 ff ff       	jmp    80106c74 <alltraps>

80107337 <vector15>:
.globl vector15
vector15:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $15
80107339:	6a 0f                	push   $0xf
  jmp alltraps
8010733b:	e9 34 f9 ff ff       	jmp    80106c74 <alltraps>

80107340 <vector16>:
.globl vector16
vector16:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $16
80107342:	6a 10                	push   $0x10
  jmp alltraps
80107344:	e9 2b f9 ff ff       	jmp    80106c74 <alltraps>

80107349 <vector17>:
.globl vector17
vector17:
  pushl $17
80107349:	6a 11                	push   $0x11
  jmp alltraps
8010734b:	e9 24 f9 ff ff       	jmp    80106c74 <alltraps>

80107350 <vector18>:
.globl vector18
vector18:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $18
80107352:	6a 12                	push   $0x12
  jmp alltraps
80107354:	e9 1b f9 ff ff       	jmp    80106c74 <alltraps>

80107359 <vector19>:
.globl vector19
vector19:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $19
8010735b:	6a 13                	push   $0x13
  jmp alltraps
8010735d:	e9 12 f9 ff ff       	jmp    80106c74 <alltraps>

80107362 <vector20>:
.globl vector20
vector20:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $20
80107364:	6a 14                	push   $0x14
  jmp alltraps
80107366:	e9 09 f9 ff ff       	jmp    80106c74 <alltraps>

8010736b <vector21>:
.globl vector21
vector21:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $21
8010736d:	6a 15                	push   $0x15
  jmp alltraps
8010736f:	e9 00 f9 ff ff       	jmp    80106c74 <alltraps>

80107374 <vector22>:
.globl vector22
vector22:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $22
80107376:	6a 16                	push   $0x16
  jmp alltraps
80107378:	e9 f7 f8 ff ff       	jmp    80106c74 <alltraps>

8010737d <vector23>:
.globl vector23
vector23:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $23
8010737f:	6a 17                	push   $0x17
  jmp alltraps
80107381:	e9 ee f8 ff ff       	jmp    80106c74 <alltraps>

80107386 <vector24>:
.globl vector24
vector24:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $24
80107388:	6a 18                	push   $0x18
  jmp alltraps
8010738a:	e9 e5 f8 ff ff       	jmp    80106c74 <alltraps>

8010738f <vector25>:
.globl vector25
vector25:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $25
80107391:	6a 19                	push   $0x19
  jmp alltraps
80107393:	e9 dc f8 ff ff       	jmp    80106c74 <alltraps>

80107398 <vector26>:
.globl vector26
vector26:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $26
8010739a:	6a 1a                	push   $0x1a
  jmp alltraps
8010739c:	e9 d3 f8 ff ff       	jmp    80106c74 <alltraps>

801073a1 <vector27>:
.globl vector27
vector27:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $27
801073a3:	6a 1b                	push   $0x1b
  jmp alltraps
801073a5:	e9 ca f8 ff ff       	jmp    80106c74 <alltraps>

801073aa <vector28>:
.globl vector28
vector28:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $28
801073ac:	6a 1c                	push   $0x1c
  jmp alltraps
801073ae:	e9 c1 f8 ff ff       	jmp    80106c74 <alltraps>

801073b3 <vector29>:
.globl vector29
vector29:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $29
801073b5:	6a 1d                	push   $0x1d
  jmp alltraps
801073b7:	e9 b8 f8 ff ff       	jmp    80106c74 <alltraps>

801073bc <vector30>:
.globl vector30
vector30:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $30
801073be:	6a 1e                	push   $0x1e
  jmp alltraps
801073c0:	e9 af f8 ff ff       	jmp    80106c74 <alltraps>

801073c5 <vector31>:
.globl vector31
vector31:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $31
801073c7:	6a 1f                	push   $0x1f
  jmp alltraps
801073c9:	e9 a6 f8 ff ff       	jmp    80106c74 <alltraps>

801073ce <vector32>:
.globl vector32
vector32:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $32
801073d0:	6a 20                	push   $0x20
  jmp alltraps
801073d2:	e9 9d f8 ff ff       	jmp    80106c74 <alltraps>

801073d7 <vector33>:
.globl vector33
vector33:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $33
801073d9:	6a 21                	push   $0x21
  jmp alltraps
801073db:	e9 94 f8 ff ff       	jmp    80106c74 <alltraps>

801073e0 <vector34>:
.globl vector34
vector34:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $34
801073e2:	6a 22                	push   $0x22
  jmp alltraps
801073e4:	e9 8b f8 ff ff       	jmp    80106c74 <alltraps>

801073e9 <vector35>:
.globl vector35
vector35:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $35
801073eb:	6a 23                	push   $0x23
  jmp alltraps
801073ed:	e9 82 f8 ff ff       	jmp    80106c74 <alltraps>

801073f2 <vector36>:
.globl vector36
vector36:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $36
801073f4:	6a 24                	push   $0x24
  jmp alltraps
801073f6:	e9 79 f8 ff ff       	jmp    80106c74 <alltraps>

801073fb <vector37>:
.globl vector37
vector37:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $37
801073fd:	6a 25                	push   $0x25
  jmp alltraps
801073ff:	e9 70 f8 ff ff       	jmp    80106c74 <alltraps>

80107404 <vector38>:
.globl vector38
vector38:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $38
80107406:	6a 26                	push   $0x26
  jmp alltraps
80107408:	e9 67 f8 ff ff       	jmp    80106c74 <alltraps>

8010740d <vector39>:
.globl vector39
vector39:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $39
8010740f:	6a 27                	push   $0x27
  jmp alltraps
80107411:	e9 5e f8 ff ff       	jmp    80106c74 <alltraps>

80107416 <vector40>:
.globl vector40
vector40:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $40
80107418:	6a 28                	push   $0x28
  jmp alltraps
8010741a:	e9 55 f8 ff ff       	jmp    80106c74 <alltraps>

8010741f <vector41>:
.globl vector41
vector41:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $41
80107421:	6a 29                	push   $0x29
  jmp alltraps
80107423:	e9 4c f8 ff ff       	jmp    80106c74 <alltraps>

80107428 <vector42>:
.globl vector42
vector42:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $42
8010742a:	6a 2a                	push   $0x2a
  jmp alltraps
8010742c:	e9 43 f8 ff ff       	jmp    80106c74 <alltraps>

80107431 <vector43>:
.globl vector43
vector43:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $43
80107433:	6a 2b                	push   $0x2b
  jmp alltraps
80107435:	e9 3a f8 ff ff       	jmp    80106c74 <alltraps>

8010743a <vector44>:
.globl vector44
vector44:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $44
8010743c:	6a 2c                	push   $0x2c
  jmp alltraps
8010743e:	e9 31 f8 ff ff       	jmp    80106c74 <alltraps>

80107443 <vector45>:
.globl vector45
vector45:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $45
80107445:	6a 2d                	push   $0x2d
  jmp alltraps
80107447:	e9 28 f8 ff ff       	jmp    80106c74 <alltraps>

8010744c <vector46>:
.globl vector46
vector46:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $46
8010744e:	6a 2e                	push   $0x2e
  jmp alltraps
80107450:	e9 1f f8 ff ff       	jmp    80106c74 <alltraps>

80107455 <vector47>:
.globl vector47
vector47:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $47
80107457:	6a 2f                	push   $0x2f
  jmp alltraps
80107459:	e9 16 f8 ff ff       	jmp    80106c74 <alltraps>

8010745e <vector48>:
.globl vector48
vector48:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $48
80107460:	6a 30                	push   $0x30
  jmp alltraps
80107462:	e9 0d f8 ff ff       	jmp    80106c74 <alltraps>

80107467 <vector49>:
.globl vector49
vector49:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $49
80107469:	6a 31                	push   $0x31
  jmp alltraps
8010746b:	e9 04 f8 ff ff       	jmp    80106c74 <alltraps>

80107470 <vector50>:
.globl vector50
vector50:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $50
80107472:	6a 32                	push   $0x32
  jmp alltraps
80107474:	e9 fb f7 ff ff       	jmp    80106c74 <alltraps>

80107479 <vector51>:
.globl vector51
vector51:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $51
8010747b:	6a 33                	push   $0x33
  jmp alltraps
8010747d:	e9 f2 f7 ff ff       	jmp    80106c74 <alltraps>

80107482 <vector52>:
.globl vector52
vector52:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $52
80107484:	6a 34                	push   $0x34
  jmp alltraps
80107486:	e9 e9 f7 ff ff       	jmp    80106c74 <alltraps>

8010748b <vector53>:
.globl vector53
vector53:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $53
8010748d:	6a 35                	push   $0x35
  jmp alltraps
8010748f:	e9 e0 f7 ff ff       	jmp    80106c74 <alltraps>

80107494 <vector54>:
.globl vector54
vector54:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $54
80107496:	6a 36                	push   $0x36
  jmp alltraps
80107498:	e9 d7 f7 ff ff       	jmp    80106c74 <alltraps>

8010749d <vector55>:
.globl vector55
vector55:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $55
8010749f:	6a 37                	push   $0x37
  jmp alltraps
801074a1:	e9 ce f7 ff ff       	jmp    80106c74 <alltraps>

801074a6 <vector56>:
.globl vector56
vector56:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $56
801074a8:	6a 38                	push   $0x38
  jmp alltraps
801074aa:	e9 c5 f7 ff ff       	jmp    80106c74 <alltraps>

801074af <vector57>:
.globl vector57
vector57:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $57
801074b1:	6a 39                	push   $0x39
  jmp alltraps
801074b3:	e9 bc f7 ff ff       	jmp    80106c74 <alltraps>

801074b8 <vector58>:
.globl vector58
vector58:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $58
801074ba:	6a 3a                	push   $0x3a
  jmp alltraps
801074bc:	e9 b3 f7 ff ff       	jmp    80106c74 <alltraps>

801074c1 <vector59>:
.globl vector59
vector59:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $59
801074c3:	6a 3b                	push   $0x3b
  jmp alltraps
801074c5:	e9 aa f7 ff ff       	jmp    80106c74 <alltraps>

801074ca <vector60>:
.globl vector60
vector60:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $60
801074cc:	6a 3c                	push   $0x3c
  jmp alltraps
801074ce:	e9 a1 f7 ff ff       	jmp    80106c74 <alltraps>

801074d3 <vector61>:
.globl vector61
vector61:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $61
801074d5:	6a 3d                	push   $0x3d
  jmp alltraps
801074d7:	e9 98 f7 ff ff       	jmp    80106c74 <alltraps>

801074dc <vector62>:
.globl vector62
vector62:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $62
801074de:	6a 3e                	push   $0x3e
  jmp alltraps
801074e0:	e9 8f f7 ff ff       	jmp    80106c74 <alltraps>

801074e5 <vector63>:
.globl vector63
vector63:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $63
801074e7:	6a 3f                	push   $0x3f
  jmp alltraps
801074e9:	e9 86 f7 ff ff       	jmp    80106c74 <alltraps>

801074ee <vector64>:
.globl vector64
vector64:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $64
801074f0:	6a 40                	push   $0x40
  jmp alltraps
801074f2:	e9 7d f7 ff ff       	jmp    80106c74 <alltraps>

801074f7 <vector65>:
.globl vector65
vector65:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $65
801074f9:	6a 41                	push   $0x41
  jmp alltraps
801074fb:	e9 74 f7 ff ff       	jmp    80106c74 <alltraps>

80107500 <vector66>:
.globl vector66
vector66:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $66
80107502:	6a 42                	push   $0x42
  jmp alltraps
80107504:	e9 6b f7 ff ff       	jmp    80106c74 <alltraps>

80107509 <vector67>:
.globl vector67
vector67:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $67
8010750b:	6a 43                	push   $0x43
  jmp alltraps
8010750d:	e9 62 f7 ff ff       	jmp    80106c74 <alltraps>

80107512 <vector68>:
.globl vector68
vector68:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $68
80107514:	6a 44                	push   $0x44
  jmp alltraps
80107516:	e9 59 f7 ff ff       	jmp    80106c74 <alltraps>

8010751b <vector69>:
.globl vector69
vector69:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $69
8010751d:	6a 45                	push   $0x45
  jmp alltraps
8010751f:	e9 50 f7 ff ff       	jmp    80106c74 <alltraps>

80107524 <vector70>:
.globl vector70
vector70:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $70
80107526:	6a 46                	push   $0x46
  jmp alltraps
80107528:	e9 47 f7 ff ff       	jmp    80106c74 <alltraps>

8010752d <vector71>:
.globl vector71
vector71:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $71
8010752f:	6a 47                	push   $0x47
  jmp alltraps
80107531:	e9 3e f7 ff ff       	jmp    80106c74 <alltraps>

80107536 <vector72>:
.globl vector72
vector72:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $72
80107538:	6a 48                	push   $0x48
  jmp alltraps
8010753a:	e9 35 f7 ff ff       	jmp    80106c74 <alltraps>

8010753f <vector73>:
.globl vector73
vector73:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $73
80107541:	6a 49                	push   $0x49
  jmp alltraps
80107543:	e9 2c f7 ff ff       	jmp    80106c74 <alltraps>

80107548 <vector74>:
.globl vector74
vector74:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $74
8010754a:	6a 4a                	push   $0x4a
  jmp alltraps
8010754c:	e9 23 f7 ff ff       	jmp    80106c74 <alltraps>

80107551 <vector75>:
.globl vector75
vector75:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $75
80107553:	6a 4b                	push   $0x4b
  jmp alltraps
80107555:	e9 1a f7 ff ff       	jmp    80106c74 <alltraps>

8010755a <vector76>:
.globl vector76
vector76:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $76
8010755c:	6a 4c                	push   $0x4c
  jmp alltraps
8010755e:	e9 11 f7 ff ff       	jmp    80106c74 <alltraps>

80107563 <vector77>:
.globl vector77
vector77:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $77
80107565:	6a 4d                	push   $0x4d
  jmp alltraps
80107567:	e9 08 f7 ff ff       	jmp    80106c74 <alltraps>

8010756c <vector78>:
.globl vector78
vector78:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $78
8010756e:	6a 4e                	push   $0x4e
  jmp alltraps
80107570:	e9 ff f6 ff ff       	jmp    80106c74 <alltraps>

80107575 <vector79>:
.globl vector79
vector79:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $79
80107577:	6a 4f                	push   $0x4f
  jmp alltraps
80107579:	e9 f6 f6 ff ff       	jmp    80106c74 <alltraps>

8010757e <vector80>:
.globl vector80
vector80:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $80
80107580:	6a 50                	push   $0x50
  jmp alltraps
80107582:	e9 ed f6 ff ff       	jmp    80106c74 <alltraps>

80107587 <vector81>:
.globl vector81
vector81:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $81
80107589:	6a 51                	push   $0x51
  jmp alltraps
8010758b:	e9 e4 f6 ff ff       	jmp    80106c74 <alltraps>

80107590 <vector82>:
.globl vector82
vector82:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $82
80107592:	6a 52                	push   $0x52
  jmp alltraps
80107594:	e9 db f6 ff ff       	jmp    80106c74 <alltraps>

80107599 <vector83>:
.globl vector83
vector83:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $83
8010759b:	6a 53                	push   $0x53
  jmp alltraps
8010759d:	e9 d2 f6 ff ff       	jmp    80106c74 <alltraps>

801075a2 <vector84>:
.globl vector84
vector84:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $84
801075a4:	6a 54                	push   $0x54
  jmp alltraps
801075a6:	e9 c9 f6 ff ff       	jmp    80106c74 <alltraps>

801075ab <vector85>:
.globl vector85
vector85:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $85
801075ad:	6a 55                	push   $0x55
  jmp alltraps
801075af:	e9 c0 f6 ff ff       	jmp    80106c74 <alltraps>

801075b4 <vector86>:
.globl vector86
vector86:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $86
801075b6:	6a 56                	push   $0x56
  jmp alltraps
801075b8:	e9 b7 f6 ff ff       	jmp    80106c74 <alltraps>

801075bd <vector87>:
.globl vector87
vector87:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $87
801075bf:	6a 57                	push   $0x57
  jmp alltraps
801075c1:	e9 ae f6 ff ff       	jmp    80106c74 <alltraps>

801075c6 <vector88>:
.globl vector88
vector88:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $88
801075c8:	6a 58                	push   $0x58
  jmp alltraps
801075ca:	e9 a5 f6 ff ff       	jmp    80106c74 <alltraps>

801075cf <vector89>:
.globl vector89
vector89:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $89
801075d1:	6a 59                	push   $0x59
  jmp alltraps
801075d3:	e9 9c f6 ff ff       	jmp    80106c74 <alltraps>

801075d8 <vector90>:
.globl vector90
vector90:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $90
801075da:	6a 5a                	push   $0x5a
  jmp alltraps
801075dc:	e9 93 f6 ff ff       	jmp    80106c74 <alltraps>

801075e1 <vector91>:
.globl vector91
vector91:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $91
801075e3:	6a 5b                	push   $0x5b
  jmp alltraps
801075e5:	e9 8a f6 ff ff       	jmp    80106c74 <alltraps>

801075ea <vector92>:
.globl vector92
vector92:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $92
801075ec:	6a 5c                	push   $0x5c
  jmp alltraps
801075ee:	e9 81 f6 ff ff       	jmp    80106c74 <alltraps>

801075f3 <vector93>:
.globl vector93
vector93:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $93
801075f5:	6a 5d                	push   $0x5d
  jmp alltraps
801075f7:	e9 78 f6 ff ff       	jmp    80106c74 <alltraps>

801075fc <vector94>:
.globl vector94
vector94:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $94
801075fe:	6a 5e                	push   $0x5e
  jmp alltraps
80107600:	e9 6f f6 ff ff       	jmp    80106c74 <alltraps>

80107605 <vector95>:
.globl vector95
vector95:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $95
80107607:	6a 5f                	push   $0x5f
  jmp alltraps
80107609:	e9 66 f6 ff ff       	jmp    80106c74 <alltraps>

8010760e <vector96>:
.globl vector96
vector96:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $96
80107610:	6a 60                	push   $0x60
  jmp alltraps
80107612:	e9 5d f6 ff ff       	jmp    80106c74 <alltraps>

80107617 <vector97>:
.globl vector97
vector97:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $97
80107619:	6a 61                	push   $0x61
  jmp alltraps
8010761b:	e9 54 f6 ff ff       	jmp    80106c74 <alltraps>

80107620 <vector98>:
.globl vector98
vector98:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $98
80107622:	6a 62                	push   $0x62
  jmp alltraps
80107624:	e9 4b f6 ff ff       	jmp    80106c74 <alltraps>

80107629 <vector99>:
.globl vector99
vector99:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $99
8010762b:	6a 63                	push   $0x63
  jmp alltraps
8010762d:	e9 42 f6 ff ff       	jmp    80106c74 <alltraps>

80107632 <vector100>:
.globl vector100
vector100:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $100
80107634:	6a 64                	push   $0x64
  jmp alltraps
80107636:	e9 39 f6 ff ff       	jmp    80106c74 <alltraps>

8010763b <vector101>:
.globl vector101
vector101:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $101
8010763d:	6a 65                	push   $0x65
  jmp alltraps
8010763f:	e9 30 f6 ff ff       	jmp    80106c74 <alltraps>

80107644 <vector102>:
.globl vector102
vector102:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $102
80107646:	6a 66                	push   $0x66
  jmp alltraps
80107648:	e9 27 f6 ff ff       	jmp    80106c74 <alltraps>

8010764d <vector103>:
.globl vector103
vector103:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $103
8010764f:	6a 67                	push   $0x67
  jmp alltraps
80107651:	e9 1e f6 ff ff       	jmp    80106c74 <alltraps>

80107656 <vector104>:
.globl vector104
vector104:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $104
80107658:	6a 68                	push   $0x68
  jmp alltraps
8010765a:	e9 15 f6 ff ff       	jmp    80106c74 <alltraps>

8010765f <vector105>:
.globl vector105
vector105:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $105
80107661:	6a 69                	push   $0x69
  jmp alltraps
80107663:	e9 0c f6 ff ff       	jmp    80106c74 <alltraps>

80107668 <vector106>:
.globl vector106
vector106:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $106
8010766a:	6a 6a                	push   $0x6a
  jmp alltraps
8010766c:	e9 03 f6 ff ff       	jmp    80106c74 <alltraps>

80107671 <vector107>:
.globl vector107
vector107:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $107
80107673:	6a 6b                	push   $0x6b
  jmp alltraps
80107675:	e9 fa f5 ff ff       	jmp    80106c74 <alltraps>

8010767a <vector108>:
.globl vector108
vector108:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $108
8010767c:	6a 6c                	push   $0x6c
  jmp alltraps
8010767e:	e9 f1 f5 ff ff       	jmp    80106c74 <alltraps>

80107683 <vector109>:
.globl vector109
vector109:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $109
80107685:	6a 6d                	push   $0x6d
  jmp alltraps
80107687:	e9 e8 f5 ff ff       	jmp    80106c74 <alltraps>

8010768c <vector110>:
.globl vector110
vector110:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $110
8010768e:	6a 6e                	push   $0x6e
  jmp alltraps
80107690:	e9 df f5 ff ff       	jmp    80106c74 <alltraps>

80107695 <vector111>:
.globl vector111
vector111:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $111
80107697:	6a 6f                	push   $0x6f
  jmp alltraps
80107699:	e9 d6 f5 ff ff       	jmp    80106c74 <alltraps>

8010769e <vector112>:
.globl vector112
vector112:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $112
801076a0:	6a 70                	push   $0x70
  jmp alltraps
801076a2:	e9 cd f5 ff ff       	jmp    80106c74 <alltraps>

801076a7 <vector113>:
.globl vector113
vector113:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $113
801076a9:	6a 71                	push   $0x71
  jmp alltraps
801076ab:	e9 c4 f5 ff ff       	jmp    80106c74 <alltraps>

801076b0 <vector114>:
.globl vector114
vector114:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $114
801076b2:	6a 72                	push   $0x72
  jmp alltraps
801076b4:	e9 bb f5 ff ff       	jmp    80106c74 <alltraps>

801076b9 <vector115>:
.globl vector115
vector115:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $115
801076bb:	6a 73                	push   $0x73
  jmp alltraps
801076bd:	e9 b2 f5 ff ff       	jmp    80106c74 <alltraps>

801076c2 <vector116>:
.globl vector116
vector116:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $116
801076c4:	6a 74                	push   $0x74
  jmp alltraps
801076c6:	e9 a9 f5 ff ff       	jmp    80106c74 <alltraps>

801076cb <vector117>:
.globl vector117
vector117:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $117
801076cd:	6a 75                	push   $0x75
  jmp alltraps
801076cf:	e9 a0 f5 ff ff       	jmp    80106c74 <alltraps>

801076d4 <vector118>:
.globl vector118
vector118:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $118
801076d6:	6a 76                	push   $0x76
  jmp alltraps
801076d8:	e9 97 f5 ff ff       	jmp    80106c74 <alltraps>

801076dd <vector119>:
.globl vector119
vector119:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $119
801076df:	6a 77                	push   $0x77
  jmp alltraps
801076e1:	e9 8e f5 ff ff       	jmp    80106c74 <alltraps>

801076e6 <vector120>:
.globl vector120
vector120:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $120
801076e8:	6a 78                	push   $0x78
  jmp alltraps
801076ea:	e9 85 f5 ff ff       	jmp    80106c74 <alltraps>

801076ef <vector121>:
.globl vector121
vector121:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $121
801076f1:	6a 79                	push   $0x79
  jmp alltraps
801076f3:	e9 7c f5 ff ff       	jmp    80106c74 <alltraps>

801076f8 <vector122>:
.globl vector122
vector122:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $122
801076fa:	6a 7a                	push   $0x7a
  jmp alltraps
801076fc:	e9 73 f5 ff ff       	jmp    80106c74 <alltraps>

80107701 <vector123>:
.globl vector123
vector123:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $123
80107703:	6a 7b                	push   $0x7b
  jmp alltraps
80107705:	e9 6a f5 ff ff       	jmp    80106c74 <alltraps>

8010770a <vector124>:
.globl vector124
vector124:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $124
8010770c:	6a 7c                	push   $0x7c
  jmp alltraps
8010770e:	e9 61 f5 ff ff       	jmp    80106c74 <alltraps>

80107713 <vector125>:
.globl vector125
vector125:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $125
80107715:	6a 7d                	push   $0x7d
  jmp alltraps
80107717:	e9 58 f5 ff ff       	jmp    80106c74 <alltraps>

8010771c <vector126>:
.globl vector126
vector126:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $126
8010771e:	6a 7e                	push   $0x7e
  jmp alltraps
80107720:	e9 4f f5 ff ff       	jmp    80106c74 <alltraps>

80107725 <vector127>:
.globl vector127
vector127:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $127
80107727:	6a 7f                	push   $0x7f
  jmp alltraps
80107729:	e9 46 f5 ff ff       	jmp    80106c74 <alltraps>

8010772e <vector128>:
.globl vector128
vector128:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $128
80107730:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107735:	e9 3a f5 ff ff       	jmp    80106c74 <alltraps>

8010773a <vector129>:
.globl vector129
vector129:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $129
8010773c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107741:	e9 2e f5 ff ff       	jmp    80106c74 <alltraps>

80107746 <vector130>:
.globl vector130
vector130:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $130
80107748:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010774d:	e9 22 f5 ff ff       	jmp    80106c74 <alltraps>

80107752 <vector131>:
.globl vector131
vector131:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $131
80107754:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107759:	e9 16 f5 ff ff       	jmp    80106c74 <alltraps>

8010775e <vector132>:
.globl vector132
vector132:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $132
80107760:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107765:	e9 0a f5 ff ff       	jmp    80106c74 <alltraps>

8010776a <vector133>:
.globl vector133
vector133:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $133
8010776c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107771:	e9 fe f4 ff ff       	jmp    80106c74 <alltraps>

80107776 <vector134>:
.globl vector134
vector134:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $134
80107778:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010777d:	e9 f2 f4 ff ff       	jmp    80106c74 <alltraps>

80107782 <vector135>:
.globl vector135
vector135:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $135
80107784:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107789:	e9 e6 f4 ff ff       	jmp    80106c74 <alltraps>

8010778e <vector136>:
.globl vector136
vector136:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $136
80107790:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107795:	e9 da f4 ff ff       	jmp    80106c74 <alltraps>

8010779a <vector137>:
.globl vector137
vector137:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $137
8010779c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801077a1:	e9 ce f4 ff ff       	jmp    80106c74 <alltraps>

801077a6 <vector138>:
.globl vector138
vector138:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $138
801077a8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801077ad:	e9 c2 f4 ff ff       	jmp    80106c74 <alltraps>

801077b2 <vector139>:
.globl vector139
vector139:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $139
801077b4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801077b9:	e9 b6 f4 ff ff       	jmp    80106c74 <alltraps>

801077be <vector140>:
.globl vector140
vector140:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $140
801077c0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801077c5:	e9 aa f4 ff ff       	jmp    80106c74 <alltraps>

801077ca <vector141>:
.globl vector141
vector141:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $141
801077cc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801077d1:	e9 9e f4 ff ff       	jmp    80106c74 <alltraps>

801077d6 <vector142>:
.globl vector142
vector142:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $142
801077d8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801077dd:	e9 92 f4 ff ff       	jmp    80106c74 <alltraps>

801077e2 <vector143>:
.globl vector143
vector143:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $143
801077e4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801077e9:	e9 86 f4 ff ff       	jmp    80106c74 <alltraps>

801077ee <vector144>:
.globl vector144
vector144:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $144
801077f0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801077f5:	e9 7a f4 ff ff       	jmp    80106c74 <alltraps>

801077fa <vector145>:
.globl vector145
vector145:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $145
801077fc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107801:	e9 6e f4 ff ff       	jmp    80106c74 <alltraps>

80107806 <vector146>:
.globl vector146
vector146:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $146
80107808:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010780d:	e9 62 f4 ff ff       	jmp    80106c74 <alltraps>

80107812 <vector147>:
.globl vector147
vector147:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $147
80107814:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107819:	e9 56 f4 ff ff       	jmp    80106c74 <alltraps>

8010781e <vector148>:
.globl vector148
vector148:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $148
80107820:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107825:	e9 4a f4 ff ff       	jmp    80106c74 <alltraps>

8010782a <vector149>:
.globl vector149
vector149:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $149
8010782c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107831:	e9 3e f4 ff ff       	jmp    80106c74 <alltraps>

80107836 <vector150>:
.globl vector150
vector150:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $150
80107838:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010783d:	e9 32 f4 ff ff       	jmp    80106c74 <alltraps>

80107842 <vector151>:
.globl vector151
vector151:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $151
80107844:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107849:	e9 26 f4 ff ff       	jmp    80106c74 <alltraps>

8010784e <vector152>:
.globl vector152
vector152:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $152
80107850:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107855:	e9 1a f4 ff ff       	jmp    80106c74 <alltraps>

8010785a <vector153>:
.globl vector153
vector153:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $153
8010785c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107861:	e9 0e f4 ff ff       	jmp    80106c74 <alltraps>

80107866 <vector154>:
.globl vector154
vector154:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $154
80107868:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010786d:	e9 02 f4 ff ff       	jmp    80106c74 <alltraps>

80107872 <vector155>:
.globl vector155
vector155:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $155
80107874:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107879:	e9 f6 f3 ff ff       	jmp    80106c74 <alltraps>

8010787e <vector156>:
.globl vector156
vector156:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $156
80107880:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107885:	e9 ea f3 ff ff       	jmp    80106c74 <alltraps>

8010788a <vector157>:
.globl vector157
vector157:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $157
8010788c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107891:	e9 de f3 ff ff       	jmp    80106c74 <alltraps>

80107896 <vector158>:
.globl vector158
vector158:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $158
80107898:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010789d:	e9 d2 f3 ff ff       	jmp    80106c74 <alltraps>

801078a2 <vector159>:
.globl vector159
vector159:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $159
801078a4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801078a9:	e9 c6 f3 ff ff       	jmp    80106c74 <alltraps>

801078ae <vector160>:
.globl vector160
vector160:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $160
801078b0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801078b5:	e9 ba f3 ff ff       	jmp    80106c74 <alltraps>

801078ba <vector161>:
.globl vector161
vector161:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $161
801078bc:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801078c1:	e9 ae f3 ff ff       	jmp    80106c74 <alltraps>

801078c6 <vector162>:
.globl vector162
vector162:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $162
801078c8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801078cd:	e9 a2 f3 ff ff       	jmp    80106c74 <alltraps>

801078d2 <vector163>:
.globl vector163
vector163:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $163
801078d4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801078d9:	e9 96 f3 ff ff       	jmp    80106c74 <alltraps>

801078de <vector164>:
.globl vector164
vector164:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $164
801078e0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801078e5:	e9 8a f3 ff ff       	jmp    80106c74 <alltraps>

801078ea <vector165>:
.globl vector165
vector165:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $165
801078ec:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801078f1:	e9 7e f3 ff ff       	jmp    80106c74 <alltraps>

801078f6 <vector166>:
.globl vector166
vector166:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $166
801078f8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801078fd:	e9 72 f3 ff ff       	jmp    80106c74 <alltraps>

80107902 <vector167>:
.globl vector167
vector167:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $167
80107904:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107909:	e9 66 f3 ff ff       	jmp    80106c74 <alltraps>

8010790e <vector168>:
.globl vector168
vector168:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $168
80107910:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107915:	e9 5a f3 ff ff       	jmp    80106c74 <alltraps>

8010791a <vector169>:
.globl vector169
vector169:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $169
8010791c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107921:	e9 4e f3 ff ff       	jmp    80106c74 <alltraps>

80107926 <vector170>:
.globl vector170
vector170:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $170
80107928:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010792d:	e9 42 f3 ff ff       	jmp    80106c74 <alltraps>

80107932 <vector171>:
.globl vector171
vector171:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $171
80107934:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107939:	e9 36 f3 ff ff       	jmp    80106c74 <alltraps>

8010793e <vector172>:
.globl vector172
vector172:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $172
80107940:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107945:	e9 2a f3 ff ff       	jmp    80106c74 <alltraps>

8010794a <vector173>:
.globl vector173
vector173:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $173
8010794c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107951:	e9 1e f3 ff ff       	jmp    80106c74 <alltraps>

80107956 <vector174>:
.globl vector174
vector174:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $174
80107958:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010795d:	e9 12 f3 ff ff       	jmp    80106c74 <alltraps>

80107962 <vector175>:
.globl vector175
vector175:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $175
80107964:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107969:	e9 06 f3 ff ff       	jmp    80106c74 <alltraps>

8010796e <vector176>:
.globl vector176
vector176:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $176
80107970:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107975:	e9 fa f2 ff ff       	jmp    80106c74 <alltraps>

8010797a <vector177>:
.globl vector177
vector177:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $177
8010797c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107981:	e9 ee f2 ff ff       	jmp    80106c74 <alltraps>

80107986 <vector178>:
.globl vector178
vector178:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $178
80107988:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010798d:	e9 e2 f2 ff ff       	jmp    80106c74 <alltraps>

80107992 <vector179>:
.globl vector179
vector179:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $179
80107994:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107999:	e9 d6 f2 ff ff       	jmp    80106c74 <alltraps>

8010799e <vector180>:
.globl vector180
vector180:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $180
801079a0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801079a5:	e9 ca f2 ff ff       	jmp    80106c74 <alltraps>

801079aa <vector181>:
.globl vector181
vector181:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $181
801079ac:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801079b1:	e9 be f2 ff ff       	jmp    80106c74 <alltraps>

801079b6 <vector182>:
.globl vector182
vector182:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $182
801079b8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801079bd:	e9 b2 f2 ff ff       	jmp    80106c74 <alltraps>

801079c2 <vector183>:
.globl vector183
vector183:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $183
801079c4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801079c9:	e9 a6 f2 ff ff       	jmp    80106c74 <alltraps>

801079ce <vector184>:
.globl vector184
vector184:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $184
801079d0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801079d5:	e9 9a f2 ff ff       	jmp    80106c74 <alltraps>

801079da <vector185>:
.globl vector185
vector185:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $185
801079dc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801079e1:	e9 8e f2 ff ff       	jmp    80106c74 <alltraps>

801079e6 <vector186>:
.globl vector186
vector186:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $186
801079e8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801079ed:	e9 82 f2 ff ff       	jmp    80106c74 <alltraps>

801079f2 <vector187>:
.globl vector187
vector187:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $187
801079f4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801079f9:	e9 76 f2 ff ff       	jmp    80106c74 <alltraps>

801079fe <vector188>:
.globl vector188
vector188:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $188
80107a00:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107a05:	e9 6a f2 ff ff       	jmp    80106c74 <alltraps>

80107a0a <vector189>:
.globl vector189
vector189:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $189
80107a0c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107a11:	e9 5e f2 ff ff       	jmp    80106c74 <alltraps>

80107a16 <vector190>:
.globl vector190
vector190:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $190
80107a18:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107a1d:	e9 52 f2 ff ff       	jmp    80106c74 <alltraps>

80107a22 <vector191>:
.globl vector191
vector191:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $191
80107a24:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107a29:	e9 46 f2 ff ff       	jmp    80106c74 <alltraps>

80107a2e <vector192>:
.globl vector192
vector192:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $192
80107a30:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107a35:	e9 3a f2 ff ff       	jmp    80106c74 <alltraps>

80107a3a <vector193>:
.globl vector193
vector193:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $193
80107a3c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107a41:	e9 2e f2 ff ff       	jmp    80106c74 <alltraps>

80107a46 <vector194>:
.globl vector194
vector194:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $194
80107a48:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107a4d:	e9 22 f2 ff ff       	jmp    80106c74 <alltraps>

80107a52 <vector195>:
.globl vector195
vector195:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $195
80107a54:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107a59:	e9 16 f2 ff ff       	jmp    80106c74 <alltraps>

80107a5e <vector196>:
.globl vector196
vector196:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $196
80107a60:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107a65:	e9 0a f2 ff ff       	jmp    80106c74 <alltraps>

80107a6a <vector197>:
.globl vector197
vector197:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $197
80107a6c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107a71:	e9 fe f1 ff ff       	jmp    80106c74 <alltraps>

80107a76 <vector198>:
.globl vector198
vector198:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $198
80107a78:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107a7d:	e9 f2 f1 ff ff       	jmp    80106c74 <alltraps>

80107a82 <vector199>:
.globl vector199
vector199:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $199
80107a84:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107a89:	e9 e6 f1 ff ff       	jmp    80106c74 <alltraps>

80107a8e <vector200>:
.globl vector200
vector200:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $200
80107a90:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107a95:	e9 da f1 ff ff       	jmp    80106c74 <alltraps>

80107a9a <vector201>:
.globl vector201
vector201:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $201
80107a9c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107aa1:	e9 ce f1 ff ff       	jmp    80106c74 <alltraps>

80107aa6 <vector202>:
.globl vector202
vector202:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $202
80107aa8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107aad:	e9 c2 f1 ff ff       	jmp    80106c74 <alltraps>

80107ab2 <vector203>:
.globl vector203
vector203:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $203
80107ab4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107ab9:	e9 b6 f1 ff ff       	jmp    80106c74 <alltraps>

80107abe <vector204>:
.globl vector204
vector204:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $204
80107ac0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107ac5:	e9 aa f1 ff ff       	jmp    80106c74 <alltraps>

80107aca <vector205>:
.globl vector205
vector205:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $205
80107acc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107ad1:	e9 9e f1 ff ff       	jmp    80106c74 <alltraps>

80107ad6 <vector206>:
.globl vector206
vector206:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $206
80107ad8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107add:	e9 92 f1 ff ff       	jmp    80106c74 <alltraps>

80107ae2 <vector207>:
.globl vector207
vector207:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $207
80107ae4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107ae9:	e9 86 f1 ff ff       	jmp    80106c74 <alltraps>

80107aee <vector208>:
.globl vector208
vector208:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $208
80107af0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107af5:	e9 7a f1 ff ff       	jmp    80106c74 <alltraps>

80107afa <vector209>:
.globl vector209
vector209:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $209
80107afc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107b01:	e9 6e f1 ff ff       	jmp    80106c74 <alltraps>

80107b06 <vector210>:
.globl vector210
vector210:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $210
80107b08:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107b0d:	e9 62 f1 ff ff       	jmp    80106c74 <alltraps>

80107b12 <vector211>:
.globl vector211
vector211:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $211
80107b14:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107b19:	e9 56 f1 ff ff       	jmp    80106c74 <alltraps>

80107b1e <vector212>:
.globl vector212
vector212:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $212
80107b20:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107b25:	e9 4a f1 ff ff       	jmp    80106c74 <alltraps>

80107b2a <vector213>:
.globl vector213
vector213:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $213
80107b2c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107b31:	e9 3e f1 ff ff       	jmp    80106c74 <alltraps>

80107b36 <vector214>:
.globl vector214
vector214:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $214
80107b38:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107b3d:	e9 32 f1 ff ff       	jmp    80106c74 <alltraps>

80107b42 <vector215>:
.globl vector215
vector215:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $215
80107b44:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107b49:	e9 26 f1 ff ff       	jmp    80106c74 <alltraps>

80107b4e <vector216>:
.globl vector216
vector216:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $216
80107b50:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107b55:	e9 1a f1 ff ff       	jmp    80106c74 <alltraps>

80107b5a <vector217>:
.globl vector217
vector217:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $217
80107b5c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107b61:	e9 0e f1 ff ff       	jmp    80106c74 <alltraps>

80107b66 <vector218>:
.globl vector218
vector218:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $218
80107b68:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107b6d:	e9 02 f1 ff ff       	jmp    80106c74 <alltraps>

80107b72 <vector219>:
.globl vector219
vector219:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $219
80107b74:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107b79:	e9 f6 f0 ff ff       	jmp    80106c74 <alltraps>

80107b7e <vector220>:
.globl vector220
vector220:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $220
80107b80:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107b85:	e9 ea f0 ff ff       	jmp    80106c74 <alltraps>

80107b8a <vector221>:
.globl vector221
vector221:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $221
80107b8c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107b91:	e9 de f0 ff ff       	jmp    80106c74 <alltraps>

80107b96 <vector222>:
.globl vector222
vector222:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $222
80107b98:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107b9d:	e9 d2 f0 ff ff       	jmp    80106c74 <alltraps>

80107ba2 <vector223>:
.globl vector223
vector223:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $223
80107ba4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107ba9:	e9 c6 f0 ff ff       	jmp    80106c74 <alltraps>

80107bae <vector224>:
.globl vector224
vector224:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $224
80107bb0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107bb5:	e9 ba f0 ff ff       	jmp    80106c74 <alltraps>

80107bba <vector225>:
.globl vector225
vector225:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $225
80107bbc:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107bc1:	e9 ae f0 ff ff       	jmp    80106c74 <alltraps>

80107bc6 <vector226>:
.globl vector226
vector226:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $226
80107bc8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107bcd:	e9 a2 f0 ff ff       	jmp    80106c74 <alltraps>

80107bd2 <vector227>:
.globl vector227
vector227:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $227
80107bd4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107bd9:	e9 96 f0 ff ff       	jmp    80106c74 <alltraps>

80107bde <vector228>:
.globl vector228
vector228:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $228
80107be0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107be5:	e9 8a f0 ff ff       	jmp    80106c74 <alltraps>

80107bea <vector229>:
.globl vector229
vector229:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $229
80107bec:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107bf1:	e9 7e f0 ff ff       	jmp    80106c74 <alltraps>

80107bf6 <vector230>:
.globl vector230
vector230:
  pushl $0
80107bf6:	6a 00                	push   $0x0
  pushl $230
80107bf8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107bfd:	e9 72 f0 ff ff       	jmp    80106c74 <alltraps>

80107c02 <vector231>:
.globl vector231
vector231:
  pushl $0
80107c02:	6a 00                	push   $0x0
  pushl $231
80107c04:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107c09:	e9 66 f0 ff ff       	jmp    80106c74 <alltraps>

80107c0e <vector232>:
.globl vector232
vector232:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $232
80107c10:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107c15:	e9 5a f0 ff ff       	jmp    80106c74 <alltraps>

80107c1a <vector233>:
.globl vector233
vector233:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $233
80107c1c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107c21:	e9 4e f0 ff ff       	jmp    80106c74 <alltraps>

80107c26 <vector234>:
.globl vector234
vector234:
  pushl $0
80107c26:	6a 00                	push   $0x0
  pushl $234
80107c28:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107c2d:	e9 42 f0 ff ff       	jmp    80106c74 <alltraps>

80107c32 <vector235>:
.globl vector235
vector235:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $235
80107c34:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107c39:	e9 36 f0 ff ff       	jmp    80106c74 <alltraps>

80107c3e <vector236>:
.globl vector236
vector236:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $236
80107c40:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107c45:	e9 2a f0 ff ff       	jmp    80106c74 <alltraps>

80107c4a <vector237>:
.globl vector237
vector237:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $237
80107c4c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107c51:	e9 1e f0 ff ff       	jmp    80106c74 <alltraps>

80107c56 <vector238>:
.globl vector238
vector238:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $238
80107c58:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107c5d:	e9 12 f0 ff ff       	jmp    80106c74 <alltraps>

80107c62 <vector239>:
.globl vector239
vector239:
  pushl $0
80107c62:	6a 00                	push   $0x0
  pushl $239
80107c64:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107c69:	e9 06 f0 ff ff       	jmp    80106c74 <alltraps>

80107c6e <vector240>:
.globl vector240
vector240:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $240
80107c70:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107c75:	e9 fa ef ff ff       	jmp    80106c74 <alltraps>

80107c7a <vector241>:
.globl vector241
vector241:
  pushl $0
80107c7a:	6a 00                	push   $0x0
  pushl $241
80107c7c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107c81:	e9 ee ef ff ff       	jmp    80106c74 <alltraps>

80107c86 <vector242>:
.globl vector242
vector242:
  pushl $0
80107c86:	6a 00                	push   $0x0
  pushl $242
80107c88:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107c8d:	e9 e2 ef ff ff       	jmp    80106c74 <alltraps>

80107c92 <vector243>:
.globl vector243
vector243:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $243
80107c94:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107c99:	e9 d6 ef ff ff       	jmp    80106c74 <alltraps>

80107c9e <vector244>:
.globl vector244
vector244:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $244
80107ca0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107ca5:	e9 ca ef ff ff       	jmp    80106c74 <alltraps>

80107caa <vector245>:
.globl vector245
vector245:
  pushl $0
80107caa:	6a 00                	push   $0x0
  pushl $245
80107cac:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107cb1:	e9 be ef ff ff       	jmp    80106c74 <alltraps>

80107cb6 <vector246>:
.globl vector246
vector246:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $246
80107cb8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107cbd:	e9 b2 ef ff ff       	jmp    80106c74 <alltraps>

80107cc2 <vector247>:
.globl vector247
vector247:
  pushl $0
80107cc2:	6a 00                	push   $0x0
  pushl $247
80107cc4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107cc9:	e9 a6 ef ff ff       	jmp    80106c74 <alltraps>

80107cce <vector248>:
.globl vector248
vector248:
  pushl $0
80107cce:	6a 00                	push   $0x0
  pushl $248
80107cd0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107cd5:	e9 9a ef ff ff       	jmp    80106c74 <alltraps>

80107cda <vector249>:
.globl vector249
vector249:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $249
80107cdc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107ce1:	e9 8e ef ff ff       	jmp    80106c74 <alltraps>

80107ce6 <vector250>:
.globl vector250
vector250:
  pushl $0
80107ce6:	6a 00                	push   $0x0
  pushl $250
80107ce8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ced:	e9 82 ef ff ff       	jmp    80106c74 <alltraps>

80107cf2 <vector251>:
.globl vector251
vector251:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $251
80107cf4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107cf9:	e9 76 ef ff ff       	jmp    80106c74 <alltraps>

80107cfe <vector252>:
.globl vector252
vector252:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $252
80107d00:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107d05:	e9 6a ef ff ff       	jmp    80106c74 <alltraps>

80107d0a <vector253>:
.globl vector253
vector253:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $253
80107d0c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107d11:	e9 5e ef ff ff       	jmp    80106c74 <alltraps>

80107d16 <vector254>:
.globl vector254
vector254:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $254
80107d18:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107d1d:	e9 52 ef ff ff       	jmp    80106c74 <alltraps>

80107d22 <vector255>:
.globl vector255
vector255:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $255
80107d24:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107d29:	e9 46 ef ff ff       	jmp    80106c74 <alltraps>
	...

80107d30 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107d30:	55                   	push   %ebp
80107d31:	89 e5                	mov    %esp,%ebp
80107d33:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d39:	48                   	dec    %eax
80107d3a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d41:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107d45:	8b 45 08             	mov    0x8(%ebp),%eax
80107d48:	c1 e8 10             	shr    $0x10,%eax
80107d4b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107d4f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107d52:	0f 01 10             	lgdtl  (%eax)
}
80107d55:	c9                   	leave  
80107d56:	c3                   	ret    

80107d57 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107d57:	55                   	push   %ebp
80107d58:	89 e5                	mov    %esp,%ebp
80107d5a:	83 ec 04             	sub    $0x4,%esp
80107d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80107d60:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107d64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107d67:	0f 00 d8             	ltr    %ax
}
80107d6a:	c9                   	leave  
80107d6b:	c3                   	ret    

80107d6c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107d6c:	55                   	push   %ebp
80107d6d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80107d72:	0f 22 d8             	mov    %eax,%cr3
}
80107d75:	5d                   	pop    %ebp
80107d76:	c3                   	ret    

80107d77 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107d77:	55                   	push   %ebp
80107d78:	89 e5                	mov    %esp,%ebp
80107d7a:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107d7d:	e8 c4 c4 ff ff       	call   80104246 <cpuid>
80107d82:	89 c2                	mov    %eax,%edx
80107d84:	89 d0                	mov    %edx,%eax
80107d86:	c1 e0 02             	shl    $0x2,%eax
80107d89:	01 d0                	add    %edx,%eax
80107d8b:	01 c0                	add    %eax,%eax
80107d8d:	01 d0                	add    %edx,%eax
80107d8f:	c1 e0 04             	shl    $0x4,%eax
80107d92:	05 80 4c 11 80       	add    $0x80114c80,%eax
80107d97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db6:	8a 50 7d             	mov    0x7d(%eax),%dl
80107db9:	83 e2 f0             	and    $0xfffffff0,%edx
80107dbc:	83 ca 0a             	or     $0xa,%edx
80107dbf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	8a 50 7d             	mov    0x7d(%eax),%dl
80107dc8:	83 ca 10             	or     $0x10,%edx
80107dcb:	88 50 7d             	mov    %dl,0x7d(%eax)
80107dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd1:	8a 50 7d             	mov    0x7d(%eax),%dl
80107dd4:	83 e2 9f             	and    $0xffffff9f,%edx
80107dd7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	8a 50 7d             	mov    0x7d(%eax),%dl
80107de0:	83 ca 80             	or     $0xffffff80,%edx
80107de3:	88 50 7d             	mov    %dl,0x7d(%eax)
80107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de9:	8a 50 7e             	mov    0x7e(%eax),%dl
80107dec:	83 ca 0f             	or     $0xf,%edx
80107def:	88 50 7e             	mov    %dl,0x7e(%eax)
80107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df5:	8a 50 7e             	mov    0x7e(%eax),%dl
80107df8:	83 e2 ef             	and    $0xffffffef,%edx
80107dfb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e01:	8a 50 7e             	mov    0x7e(%eax),%dl
80107e04:	83 e2 df             	and    $0xffffffdf,%edx
80107e07:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107e10:	83 ca 40             	or     $0x40,%edx
80107e13:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	8a 50 7e             	mov    0x7e(%eax),%dl
80107e1c:	83 ca 80             	or     $0xffffff80,%edx
80107e1f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107e33:	ff ff 
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107e3f:	00 00 
80107e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e44:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107e54:	83 e2 f0             	and    $0xfffffff0,%edx
80107e57:	83 ca 02             	or     $0x2,%edx
80107e5a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107e69:	83 ca 10             	or     $0x10,%edx
80107e6c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107e7b:	83 e2 9f             	and    $0xffffff9f,%edx
80107e7e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e87:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107e8d:	83 ca 80             	or     $0xffffff80,%edx
80107e90:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e99:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107e9f:	83 ca 0f             	or     $0xf,%edx
80107ea2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eab:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107eb1:	83 e2 ef             	and    $0xffffffef,%edx
80107eb4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107ec3:	83 e2 df             	and    $0xffffffdf,%edx
80107ec6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecf:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107ed5:	83 ca 40             	or     $0x40,%edx
80107ed8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee1:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107ee7:	83 ca 80             	or     $0xffffff80,%edx
80107eea:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107f04:	ff ff 
80107f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f09:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107f10:	00 00 
80107f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f15:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107f25:	83 e2 f0             	and    $0xfffffff0,%edx
80107f28:	83 ca 0a             	or     $0xa,%edx
80107f2b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107f3a:	83 ca 10             	or     $0x10,%edx
80107f3d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107f4c:	83 ca 60             	or     $0x60,%edx
80107f4f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107f5e:	83 ca 80             	or     $0xffffff80,%edx
80107f61:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107f70:	83 ca 0f             	or     $0xf,%edx
80107f73:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107f82:	83 e2 ef             	and    $0xffffffef,%edx
80107f85:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107f94:	83 e2 df             	and    $0xffffffdf,%edx
80107f97:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa0:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107fa6:	83 ca 40             	or     $0x40,%edx
80107fa9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb2:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107fb8:	83 ca 80             	or     $0xffffff80,%edx
80107fbb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fce:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107fd5:	ff ff 
80107fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fda:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107fe1:	00 00 
80107fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff0:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107ff6:	83 e2 f0             	and    $0xfffffff0,%edx
80107ff9:	83 ca 02             	or     $0x2,%edx
80107ffc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108005:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010800b:	83 ca 10             	or     $0x10,%edx
8010800e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108017:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010801d:	83 ca 60             	or     $0x60,%edx
80108020:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108029:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010802f:	83 ca 80             	or     $0xffffff80,%edx
80108032:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108041:	83 ca 0f             	or     $0xf,%edx
80108044:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108053:	83 e2 ef             	and    $0xffffffef,%edx
80108056:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010805c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108065:	83 e2 df             	and    $0xffffffdf,%edx
80108068:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010806e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108071:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108077:	83 ca 40             	or     $0x40,%edx
8010807a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108089:	83 ca 80             	or     $0xffffff80,%edx
8010808c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108095:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010809c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809f:	83 c0 70             	add    $0x70,%eax
801080a2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801080a9:	00 
801080aa:	89 04 24             	mov    %eax,(%esp)
801080ad:	e8 7e fc ff ff       	call   80107d30 <lgdt>
}
801080b2:	c9                   	leave  
801080b3:	c3                   	ret    

801080b4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801080b4:	55                   	push   %ebp
801080b5:	89 e5                	mov    %esp,%ebp
801080b7:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801080ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801080bd:	c1 e8 16             	shr    $0x16,%eax
801080c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080c7:	8b 45 08             	mov    0x8(%ebp),%eax
801080ca:	01 d0                	add    %edx,%eax
801080cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801080cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d2:	8b 00                	mov    (%eax),%eax
801080d4:	83 e0 01             	and    $0x1,%eax
801080d7:	85 c0                	test   %eax,%eax
801080d9:	74 14                	je     801080ef <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801080db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080de:	8b 00                	mov    (%eax),%eax
801080e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e5:	05 00 00 00 80       	add    $0x80000000,%eax
801080ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080ed:	eb 48                	jmp    80108137 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801080ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801080f3:	74 0e                	je     80108103 <walkpgdir+0x4f>
801080f5:	e8 09 ac ff ff       	call   80102d03 <kalloc>
801080fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108101:	75 07                	jne    8010810a <walkpgdir+0x56>
      return 0;
80108103:	b8 00 00 00 00       	mov    $0x0,%eax
80108108:	eb 44                	jmp    8010814e <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010810a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108111:	00 
80108112:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108119:	00 
8010811a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811d:	89 04 24             	mov    %eax,(%esp)
80108120:	e8 29 d3 ff ff       	call   8010544e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108128:	05 00 00 00 80       	add    $0x80000000,%eax
8010812d:	83 c8 07             	or     $0x7,%eax
80108130:	89 c2                	mov    %eax,%edx
80108132:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108135:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108137:	8b 45 0c             	mov    0xc(%ebp),%eax
8010813a:	c1 e8 0c             	shr    $0xc,%eax
8010813d:	25 ff 03 00 00       	and    $0x3ff,%eax
80108142:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814c:	01 d0                	add    %edx,%eax
}
8010814e:	c9                   	leave  
8010814f:	c3                   	ret    

80108150 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108150:	55                   	push   %ebp
80108151:	89 e5                	mov    %esp,%ebp
80108153:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108156:	8b 45 0c             	mov    0xc(%ebp),%eax
80108159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010815e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108161:	8b 55 0c             	mov    0xc(%ebp),%edx
80108164:	8b 45 10             	mov    0x10(%ebp),%eax
80108167:	01 d0                	add    %edx,%eax
80108169:	48                   	dec    %eax
8010816a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010816f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108172:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108179:	00 
8010817a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108181:	8b 45 08             	mov    0x8(%ebp),%eax
80108184:	89 04 24             	mov    %eax,(%esp)
80108187:	e8 28 ff ff ff       	call   801080b4 <walkpgdir>
8010818c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010818f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108193:	75 07                	jne    8010819c <mappages+0x4c>
      return -1;
80108195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010819a:	eb 48                	jmp    801081e4 <mappages+0x94>
    if(*pte & PTE_P)
8010819c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010819f:	8b 00                	mov    (%eax),%eax
801081a1:	83 e0 01             	and    $0x1,%eax
801081a4:	85 c0                	test   %eax,%eax
801081a6:	74 0c                	je     801081b4 <mappages+0x64>
      panic("remap");
801081a8:	c7 04 24 dc 97 10 80 	movl   $0x801097dc,(%esp)
801081af:	e8 a0 83 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
801081b4:	8b 45 18             	mov    0x18(%ebp),%eax
801081b7:	0b 45 14             	or     0x14(%ebp),%eax
801081ba:	83 c8 01             	or     $0x1,%eax
801081bd:	89 c2                	mov    %eax,%edx
801081bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081c2:	89 10                	mov    %edx,(%eax)
    if(a == last)
801081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801081ca:	75 08                	jne    801081d4 <mappages+0x84>
      break;
801081cc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801081cd:	b8 00 00 00 00       	mov    $0x0,%eax
801081d2:	eb 10                	jmp    801081e4 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801081d4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801081db:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801081e2:	eb 8e                	jmp    80108172 <mappages+0x22>
  return 0;
}
801081e4:	c9                   	leave  
801081e5:	c3                   	ret    

801081e6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801081e6:	55                   	push   %ebp
801081e7:	89 e5                	mov    %esp,%ebp
801081e9:	53                   	push   %ebx
801081ea:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801081ed:	e8 11 ab ff ff       	call   80102d03 <kalloc>
801081f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081f9:	75 0a                	jne    80108205 <setupkvm+0x1f>
    return 0;
801081fb:	b8 00 00 00 00       	mov    $0x0,%eax
80108200:	e9 84 00 00 00       	jmp    80108289 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108205:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010820c:	00 
8010820d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108214:	00 
80108215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108218:	89 04 24             	mov    %eax,(%esp)
8010821b:	e8 2e d2 ff ff       	call   8010544e <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108220:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
80108227:	eb 54                	jmp    8010827d <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822c:	8b 48 0c             	mov    0xc(%eax),%ecx
8010822f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108232:	8b 50 04             	mov    0x4(%eax),%edx
80108235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108238:	8b 58 08             	mov    0x8(%eax),%ebx
8010823b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823e:	8b 40 04             	mov    0x4(%eax),%eax
80108241:	29 c3                	sub    %eax,%ebx
80108243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108246:	8b 00                	mov    (%eax),%eax
80108248:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010824c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108250:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108254:	89 44 24 04          	mov    %eax,0x4(%esp)
80108258:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825b:	89 04 24             	mov    %eax,(%esp)
8010825e:	e8 ed fe ff ff       	call   80108150 <mappages>
80108263:	85 c0                	test   %eax,%eax
80108265:	79 12                	jns    80108279 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80108267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826a:	89 04 24             	mov    %eax,(%esp)
8010826d:	e8 1a 05 00 00       	call   8010878c <freevm>
      return 0;
80108272:	b8 00 00 00 00       	mov    $0x0,%eax
80108277:	eb 10                	jmp    80108289 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108279:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010827d:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
80108284:	72 a3                	jb     80108229 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108286:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108289:	83 c4 34             	add    $0x34,%esp
8010828c:	5b                   	pop    %ebx
8010828d:	5d                   	pop    %ebp
8010828e:	c3                   	ret    

8010828f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010828f:	55                   	push   %ebp
80108290:	89 e5                	mov    %esp,%ebp
80108292:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108295:	e8 4c ff ff ff       	call   801081e6 <setupkvm>
8010829a:	a3 a4 7b 11 80       	mov    %eax,0x80117ba4
  switchkvm();
8010829f:	e8 02 00 00 00       	call   801082a6 <switchkvm>
}
801082a4:	c9                   	leave  
801082a5:	c3                   	ret    

801082a6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801082a6:	55                   	push   %ebp
801082a7:	89 e5                	mov    %esp,%ebp
801082a9:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801082ac:	a1 a4 7b 11 80       	mov    0x80117ba4,%eax
801082b1:	05 00 00 00 80       	add    $0x80000000,%eax
801082b6:	89 04 24             	mov    %eax,(%esp)
801082b9:	e8 ae fa ff ff       	call   80107d6c <lcr3>
}
801082be:	c9                   	leave  
801082bf:	c3                   	ret    

801082c0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801082c0:	55                   	push   %ebp
801082c1:	89 e5                	mov    %esp,%ebp
801082c3:	57                   	push   %edi
801082c4:	56                   	push   %esi
801082c5:	53                   	push   %ebx
801082c6:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
801082c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082cd:	75 0c                	jne    801082db <switchuvm+0x1b>
    panic("switchuvm: no process");
801082cf:	c7 04 24 e2 97 10 80 	movl   $0x801097e2,(%esp)
801082d6:	e8 79 82 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
801082db:	8b 45 08             	mov    0x8(%ebp),%eax
801082de:	8b 40 08             	mov    0x8(%eax),%eax
801082e1:	85 c0                	test   %eax,%eax
801082e3:	75 0c                	jne    801082f1 <switchuvm+0x31>
    panic("switchuvm: no kstack");
801082e5:	c7 04 24 f8 97 10 80 	movl   $0x801097f8,(%esp)
801082ec:	e8 63 82 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801082f1:	8b 45 08             	mov    0x8(%ebp),%eax
801082f4:	8b 40 04             	mov    0x4(%eax),%eax
801082f7:	85 c0                	test   %eax,%eax
801082f9:	75 0c                	jne    80108307 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801082fb:	c7 04 24 0d 98 10 80 	movl   $0x8010980d,(%esp)
80108302:	e8 4d 82 ff ff       	call   80100554 <panic>

  pushcli();
80108307:	e8 3e d0 ff ff       	call   8010534a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010830c:	e8 7a bf ff ff       	call   8010428b <mycpu>
80108311:	89 c3                	mov    %eax,%ebx
80108313:	e8 73 bf ff ff       	call   8010428b <mycpu>
80108318:	83 c0 08             	add    $0x8,%eax
8010831b:	89 c6                	mov    %eax,%esi
8010831d:	e8 69 bf ff ff       	call   8010428b <mycpu>
80108322:	83 c0 08             	add    $0x8,%eax
80108325:	c1 e8 10             	shr    $0x10,%eax
80108328:	89 c7                	mov    %eax,%edi
8010832a:	e8 5c bf ff ff       	call   8010428b <mycpu>
8010832f:	83 c0 08             	add    $0x8,%eax
80108332:	c1 e8 18             	shr    $0x18,%eax
80108335:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010833c:	67 00 
8010833e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108345:	89 f9                	mov    %edi,%ecx
80108347:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010834d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108353:	83 e2 f0             	and    $0xfffffff0,%edx
80108356:	83 ca 09             	or     $0x9,%edx
80108359:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010835f:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108365:	83 ca 10             	or     $0x10,%edx
80108368:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010836e:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108374:	83 e2 9f             	and    $0xffffff9f,%edx
80108377:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010837d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108383:	83 ca 80             	or     $0xffffff80,%edx
80108386:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010838c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108392:	83 e2 f0             	and    $0xfffffff0,%edx
80108395:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010839b:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801083a1:	83 e2 ef             	and    $0xffffffef,%edx
801083a4:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801083aa:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801083b0:	83 e2 df             	and    $0xffffffdf,%edx
801083b3:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801083b9:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801083bf:	83 ca 40             	or     $0x40,%edx
801083c2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801083c8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801083ce:	83 e2 7f             	and    $0x7f,%edx
801083d1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801083d7:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801083dd:	e8 a9 be ff ff       	call   8010428b <mycpu>
801083e2:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801083e8:	83 e2 ef             	and    $0xffffffef,%edx
801083eb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801083f1:	e8 95 be ff ff       	call   8010428b <mycpu>
801083f6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801083fc:	e8 8a be ff ff       	call   8010428b <mycpu>
80108401:	8b 55 08             	mov    0x8(%ebp),%edx
80108404:	8b 52 08             	mov    0x8(%edx),%edx
80108407:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010840d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108410:	e8 76 be ff ff       	call   8010428b <mycpu>
80108415:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010841b:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108422:	e8 30 f9 ff ff       	call   80107d57 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108427:	8b 45 08             	mov    0x8(%ebp),%eax
8010842a:	8b 40 04             	mov    0x4(%eax),%eax
8010842d:	05 00 00 00 80       	add    $0x80000000,%eax
80108432:	89 04 24             	mov    %eax,(%esp)
80108435:	e8 32 f9 ff ff       	call   80107d6c <lcr3>
  popcli();
8010843a:	e8 55 cf ff ff       	call   80105394 <popcli>
}
8010843f:	83 c4 1c             	add    $0x1c,%esp
80108442:	5b                   	pop    %ebx
80108443:	5e                   	pop    %esi
80108444:	5f                   	pop    %edi
80108445:	5d                   	pop    %ebp
80108446:	c3                   	ret    

80108447 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108447:	55                   	push   %ebp
80108448:	89 e5                	mov    %esp,%ebp
8010844a:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
8010844d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108454:	76 0c                	jbe    80108462 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108456:	c7 04 24 21 98 10 80 	movl   $0x80109821,(%esp)
8010845d:	e8 f2 80 ff ff       	call   80100554 <panic>
  mem = kalloc();
80108462:	e8 9c a8 ff ff       	call   80102d03 <kalloc>
80108467:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010846a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108471:	00 
80108472:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108479:	00 
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	89 04 24             	mov    %eax,(%esp)
80108480:	e8 c9 cf ff ff       	call   8010544e <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108488:	05 00 00 00 80       	add    $0x80000000,%eax
8010848d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108494:	00 
80108495:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108499:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084a0:	00 
801084a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084a8:	00 
801084a9:	8b 45 08             	mov    0x8(%ebp),%eax
801084ac:	89 04 24             	mov    %eax,(%esp)
801084af:	e8 9c fc ff ff       	call   80108150 <mappages>
  memmove(mem, init, sz);
801084b4:	8b 45 10             	mov    0x10(%ebp),%eax
801084b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801084bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801084be:	89 44 24 04          	mov    %eax,0x4(%esp)
801084c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c5:	89 04 24             	mov    %eax,(%esp)
801084c8:	e8 4a d0 ff ff       	call   80105517 <memmove>
}
801084cd:	c9                   	leave  
801084ce:	c3                   	ret    

801084cf <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801084cf:	55                   	push   %ebp
801084d0:	89 e5                	mov    %esp,%ebp
801084d2:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d8:	25 ff 0f 00 00       	and    $0xfff,%eax
801084dd:	85 c0                	test   %eax,%eax
801084df:	74 0c                	je     801084ed <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
801084e1:	c7 04 24 3c 98 10 80 	movl   $0x8010983c,(%esp)
801084e8:	e8 67 80 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084f4:	e9 a6 00 00 00       	jmp    8010859f <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ff:	01 d0                	add    %edx,%eax
80108501:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108508:	00 
80108509:	89 44 24 04          	mov    %eax,0x4(%esp)
8010850d:	8b 45 08             	mov    0x8(%ebp),%eax
80108510:	89 04 24             	mov    %eax,(%esp)
80108513:	e8 9c fb ff ff       	call   801080b4 <walkpgdir>
80108518:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010851b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010851f:	75 0c                	jne    8010852d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108521:	c7 04 24 5f 98 10 80 	movl   $0x8010985f,(%esp)
80108528:	e8 27 80 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
8010852d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108530:	8b 00                	mov    (%eax),%eax
80108532:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108537:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010853a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853d:	8b 55 18             	mov    0x18(%ebp),%edx
80108540:	29 c2                	sub    %eax,%edx
80108542:	89 d0                	mov    %edx,%eax
80108544:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108549:	77 0f                	ja     8010855a <loaduvm+0x8b>
      n = sz - i;
8010854b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854e:	8b 55 18             	mov    0x18(%ebp),%edx
80108551:	29 c2                	sub    %eax,%edx
80108553:	89 d0                	mov    %edx,%eax
80108555:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108558:	eb 07                	jmp    80108561 <loaduvm+0x92>
    else
      n = PGSIZE;
8010855a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	8b 55 14             	mov    0x14(%ebp),%edx
80108567:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010856a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010856d:	05 00 00 00 80       	add    $0x80000000,%eax
80108572:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108575:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010857d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108581:	8b 45 10             	mov    0x10(%ebp),%eax
80108584:	89 04 24             	mov    %eax,(%esp)
80108587:	e8 cd 99 ff ff       	call   80101f59 <readi>
8010858c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010858f:	74 07                	je     80108598 <loaduvm+0xc9>
      return -1;
80108591:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108596:	eb 18                	jmp    801085b0 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108598:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a2:	3b 45 18             	cmp    0x18(%ebp),%eax
801085a5:	0f 82 4e ff ff ff    	jb     801084f9 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801085ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085b0:	c9                   	leave  
801085b1:	c3                   	ret    

801085b2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085b2:	55                   	push   %ebp
801085b3:	89 e5                	mov    %esp,%ebp
801085b5:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801085b8:	8b 45 10             	mov    0x10(%ebp),%eax
801085bb:	85 c0                	test   %eax,%eax
801085bd:	79 0a                	jns    801085c9 <allocuvm+0x17>
    return 0;
801085bf:	b8 00 00 00 00       	mov    $0x0,%eax
801085c4:	e9 fd 00 00 00       	jmp    801086c6 <allocuvm+0x114>
  if(newsz < oldsz)
801085c9:	8b 45 10             	mov    0x10(%ebp),%eax
801085cc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085cf:	73 08                	jae    801085d9 <allocuvm+0x27>
    return oldsz;
801085d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d4:	e9 ed 00 00 00       	jmp    801086c6 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801085d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085dc:	05 ff 0f 00 00       	add    $0xfff,%eax
801085e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801085e9:	e9 c9 00 00 00       	jmp    801086b7 <allocuvm+0x105>
    mem = kalloc();
801085ee:	e8 10 a7 ff ff       	call   80102d03 <kalloc>
801085f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801085f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085fa:	75 2f                	jne    8010862b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801085fc:	c7 04 24 7d 98 10 80 	movl   $0x8010987d,(%esp)
80108603:	e8 b9 7d ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108608:	8b 45 0c             	mov    0xc(%ebp),%eax
8010860b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010860f:	8b 45 10             	mov    0x10(%ebp),%eax
80108612:	89 44 24 04          	mov    %eax,0x4(%esp)
80108616:	8b 45 08             	mov    0x8(%ebp),%eax
80108619:	89 04 24             	mov    %eax,(%esp)
8010861c:	e8 a7 00 00 00       	call   801086c8 <deallocuvm>
      return 0;
80108621:	b8 00 00 00 00       	mov    $0x0,%eax
80108626:	e9 9b 00 00 00       	jmp    801086c6 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
8010862b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108632:	00 
80108633:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010863a:	00 
8010863b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863e:	89 04 24             	mov    %eax,(%esp)
80108641:	e8 08 ce ff ff       	call   8010544e <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108649:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108659:	00 
8010865a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010865e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108665:	00 
80108666:	89 44 24 04          	mov    %eax,0x4(%esp)
8010866a:	8b 45 08             	mov    0x8(%ebp),%eax
8010866d:	89 04 24             	mov    %eax,(%esp)
80108670:	e8 db fa ff ff       	call   80108150 <mappages>
80108675:	85 c0                	test   %eax,%eax
80108677:	79 37                	jns    801086b0 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108679:	c7 04 24 95 98 10 80 	movl   $0x80109895,(%esp)
80108680:	e8 3c 7d ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108685:	8b 45 0c             	mov    0xc(%ebp),%eax
80108688:	89 44 24 08          	mov    %eax,0x8(%esp)
8010868c:	8b 45 10             	mov    0x10(%ebp),%eax
8010868f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108693:	8b 45 08             	mov    0x8(%ebp),%eax
80108696:	89 04 24             	mov    %eax,(%esp)
80108699:	e8 2a 00 00 00       	call   801086c8 <deallocuvm>
      kfree(mem);
8010869e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a1:	89 04 24             	mov    %eax,(%esp)
801086a4:	e8 c4 a5 ff ff       	call   80102c6d <kfree>
      return 0;
801086a9:	b8 00 00 00 00       	mov    $0x0,%eax
801086ae:	eb 16                	jmp    801086c6 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801086b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801086bd:	0f 82 2b ff ff ff    	jb     801085ee <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
801086c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801086c6:	c9                   	leave  
801086c7:	c3                   	ret    

801086c8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801086c8:	55                   	push   %ebp
801086c9:	89 e5                	mov    %esp,%ebp
801086cb:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801086ce:	8b 45 10             	mov    0x10(%ebp),%eax
801086d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086d4:	72 08                	jb     801086de <deallocuvm+0x16>
    return oldsz;
801086d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d9:	e9 ac 00 00 00       	jmp    8010878a <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801086de:	8b 45 10             	mov    0x10(%ebp),%eax
801086e1:	05 ff 0f 00 00       	add    $0xfff,%eax
801086e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801086ee:	e9 88 00 00 00       	jmp    8010877b <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801086f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086fd:	00 
801086fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80108702:	8b 45 08             	mov    0x8(%ebp),%eax
80108705:	89 04 24             	mov    %eax,(%esp)
80108708:	e8 a7 f9 ff ff       	call   801080b4 <walkpgdir>
8010870d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108714:	75 14                	jne    8010872a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108719:	c1 e8 16             	shr    $0x16,%eax
8010871c:	40                   	inc    %eax
8010871d:	c1 e0 16             	shl    $0x16,%eax
80108720:	2d 00 10 00 00       	sub    $0x1000,%eax
80108725:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108728:	eb 4a                	jmp    80108774 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010872a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010872d:	8b 00                	mov    (%eax),%eax
8010872f:	83 e0 01             	and    $0x1,%eax
80108732:	85 c0                	test   %eax,%eax
80108734:	74 3e                	je     80108774 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108736:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108739:	8b 00                	mov    (%eax),%eax
8010873b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108740:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108743:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108747:	75 0c                	jne    80108755 <deallocuvm+0x8d>
        panic("kfree");
80108749:	c7 04 24 b1 98 10 80 	movl   $0x801098b1,(%esp)
80108750:	e8 ff 7d ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108755:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108758:	05 00 00 00 80       	add    $0x80000000,%eax
8010875d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108760:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108763:	89 04 24             	mov    %eax,(%esp)
80108766:	e8 02 a5 ff ff       	call   80102c6d <kfree>
      *pte = 0;
8010876b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108774:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108781:	0f 82 6c ff ff ff    	jb     801086f3 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108787:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010878a:	c9                   	leave  
8010878b:	c3                   	ret    

8010878c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010878c:	55                   	push   %ebp
8010878d:	89 e5                	mov    %esp,%ebp
8010878f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108792:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108796:	75 0c                	jne    801087a4 <freevm+0x18>
    panic("freevm: no pgdir");
80108798:	c7 04 24 b7 98 10 80 	movl   $0x801098b7,(%esp)
8010879f:	e8 b0 7d ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801087a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087ab:	00 
801087ac:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801087b3:	80 
801087b4:	8b 45 08             	mov    0x8(%ebp),%eax
801087b7:	89 04 24             	mov    %eax,(%esp)
801087ba:	e8 09 ff ff ff       	call   801086c8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801087bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087c6:	eb 44                	jmp    8010880c <freevm+0x80>
    if(pgdir[i] & PTE_P){
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087d2:	8b 45 08             	mov    0x8(%ebp),%eax
801087d5:	01 d0                	add    %edx,%eax
801087d7:	8b 00                	mov    (%eax),%eax
801087d9:	83 e0 01             	and    $0x1,%eax
801087dc:	85 c0                	test   %eax,%eax
801087de:	74 29                	je     80108809 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801087e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087ea:	8b 45 08             	mov    0x8(%ebp),%eax
801087ed:	01 d0                	add    %edx,%eax
801087ef:	8b 00                	mov    (%eax),%eax
801087f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087f6:	05 00 00 00 80       	add    $0x80000000,%eax
801087fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801087fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108801:	89 04 24             	mov    %eax,(%esp)
80108804:	e8 64 a4 ff ff       	call   80102c6d <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108809:	ff 45 f4             	incl   -0xc(%ebp)
8010880c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108813:	76 b3                	jbe    801087c8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108815:	8b 45 08             	mov    0x8(%ebp),%eax
80108818:	89 04 24             	mov    %eax,(%esp)
8010881b:	e8 4d a4 ff ff       	call   80102c6d <kfree>
}
80108820:	c9                   	leave  
80108821:	c3                   	ret    

80108822 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108822:	55                   	push   %ebp
80108823:	89 e5                	mov    %esp,%ebp
80108825:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108828:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010882f:	00 
80108830:	8b 45 0c             	mov    0xc(%ebp),%eax
80108833:	89 44 24 04          	mov    %eax,0x4(%esp)
80108837:	8b 45 08             	mov    0x8(%ebp),%eax
8010883a:	89 04 24             	mov    %eax,(%esp)
8010883d:	e8 72 f8 ff ff       	call   801080b4 <walkpgdir>
80108842:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108845:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108849:	75 0c                	jne    80108857 <clearpteu+0x35>
    panic("clearpteu");
8010884b:	c7 04 24 c8 98 10 80 	movl   $0x801098c8,(%esp)
80108852:	e8 fd 7c ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885a:	8b 00                	mov    (%eax),%eax
8010885c:	83 e0 fb             	and    $0xfffffffb,%eax
8010885f:	89 c2                	mov    %eax,%edx
80108861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108864:	89 10                	mov    %edx,(%eax)
}
80108866:	c9                   	leave  
80108867:	c3                   	ret    

80108868 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108868:	55                   	push   %ebp
80108869:	89 e5                	mov    %esp,%ebp
8010886b:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010886e:	e8 73 f9 ff ff       	call   801081e6 <setupkvm>
80108873:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108876:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010887a:	75 0a                	jne    80108886 <copyuvm+0x1e>
    return 0;
8010887c:	b8 00 00 00 00       	mov    $0x0,%eax
80108881:	e9 f8 00 00 00       	jmp    8010897e <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108886:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010888d:	e9 cb 00 00 00       	jmp    8010895d <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108895:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010889c:	00 
8010889d:	89 44 24 04          	mov    %eax,0x4(%esp)
801088a1:	8b 45 08             	mov    0x8(%ebp),%eax
801088a4:	89 04 24             	mov    %eax,(%esp)
801088a7:	e8 08 f8 ff ff       	call   801080b4 <walkpgdir>
801088ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
801088af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088b3:	75 0c                	jne    801088c1 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801088b5:	c7 04 24 d2 98 10 80 	movl   $0x801098d2,(%esp)
801088bc:	e8 93 7c ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
801088c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c4:	8b 00                	mov    (%eax),%eax
801088c6:	83 e0 01             	and    $0x1,%eax
801088c9:	85 c0                	test   %eax,%eax
801088cb:	75 0c                	jne    801088d9 <copyuvm+0x71>
      panic("copyuvm: page not present");
801088cd:	c7 04 24 ec 98 10 80 	movl   $0x801098ec,(%esp)
801088d4:	e8 7b 7c ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801088d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088dc:	8b 00                	mov    (%eax),%eax
801088de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801088e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e9:	8b 00                	mov    (%eax),%eax
801088eb:	25 ff 0f 00 00       	and    $0xfff,%eax
801088f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801088f3:	e8 0b a4 ff ff       	call   80102d03 <kalloc>
801088f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801088fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801088ff:	75 02                	jne    80108903 <copyuvm+0x9b>
      goto bad;
80108901:	eb 6b                	jmp    8010896e <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108903:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108906:	05 00 00 00 80       	add    $0x80000000,%eax
8010890b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108912:	00 
80108913:	89 44 24 04          	mov    %eax,0x4(%esp)
80108917:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010891a:	89 04 24             	mov    %eax,(%esp)
8010891d:	e8 f5 cb ff ff       	call   80105517 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108922:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108925:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108928:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010892e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108931:	89 54 24 10          	mov    %edx,0x10(%esp)
80108935:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108939:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108940:	00 
80108941:	89 44 24 04          	mov    %eax,0x4(%esp)
80108945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108948:	89 04 24             	mov    %eax,(%esp)
8010894b:	e8 00 f8 ff ff       	call   80108150 <mappages>
80108950:	85 c0                	test   %eax,%eax
80108952:	79 02                	jns    80108956 <copyuvm+0xee>
      goto bad;
80108954:	eb 18                	jmp    8010896e <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108956:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010895d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108960:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108963:	0f 82 29 ff ff ff    	jb     80108892 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010896c:	eb 10                	jmp    8010897e <copyuvm+0x116>

bad:
  freevm(d);
8010896e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108971:	89 04 24             	mov    %eax,(%esp)
80108974:	e8 13 fe ff ff       	call   8010878c <freevm>
  return 0;
80108979:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010897e:	c9                   	leave  
8010897f:	c3                   	ret    

80108980 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108980:	55                   	push   %ebp
80108981:	89 e5                	mov    %esp,%ebp
80108983:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108986:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010898d:	00 
8010898e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108991:	89 44 24 04          	mov    %eax,0x4(%esp)
80108995:	8b 45 08             	mov    0x8(%ebp),%eax
80108998:	89 04 24             	mov    %eax,(%esp)
8010899b:	e8 14 f7 ff ff       	call   801080b4 <walkpgdir>
801089a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	8b 00                	mov    (%eax),%eax
801089a8:	83 e0 01             	and    $0x1,%eax
801089ab:	85 c0                	test   %eax,%eax
801089ad:	75 07                	jne    801089b6 <uva2ka+0x36>
    return 0;
801089af:	b8 00 00 00 00       	mov    $0x0,%eax
801089b4:	eb 22                	jmp    801089d8 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801089b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b9:	8b 00                	mov    (%eax),%eax
801089bb:	83 e0 04             	and    $0x4,%eax
801089be:	85 c0                	test   %eax,%eax
801089c0:	75 07                	jne    801089c9 <uva2ka+0x49>
    return 0;
801089c2:	b8 00 00 00 00       	mov    $0x0,%eax
801089c7:	eb 0f                	jmp    801089d8 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801089c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cc:	8b 00                	mov    (%eax),%eax
801089ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089d3:	05 00 00 00 80       	add    $0x80000000,%eax
}
801089d8:	c9                   	leave  
801089d9:	c3                   	ret    

801089da <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801089da:	55                   	push   %ebp
801089db:	89 e5                	mov    %esp,%ebp
801089dd:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801089e0:	8b 45 10             	mov    0x10(%ebp),%eax
801089e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801089e6:	e9 87 00 00 00       	jmp    80108a72 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801089eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801089ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801089f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801089fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108a00:	89 04 24             	mov    %eax,(%esp)
80108a03:	e8 78 ff ff ff       	call   80108980 <uva2ka>
80108a08:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108a0b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108a0f:	75 07                	jne    80108a18 <copyout+0x3e>
      return -1;
80108a11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a16:	eb 69                	jmp    80108a81 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108a18:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108a1e:	29 c2                	sub    %eax,%edx
80108a20:	89 d0                	mov    %edx,%eax
80108a22:	05 00 10 00 00       	add    $0x1000,%eax
80108a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108a30:	76 06                	jbe    80108a38 <copyout+0x5e>
      n = len;
80108a32:	8b 45 14             	mov    0x14(%ebp),%eax
80108a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108a38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a3e:	29 c2                	sub    %eax,%edx
80108a40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a43:	01 c2                	add    %eax,%edx
80108a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a48:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a53:	89 14 24             	mov    %edx,(%esp)
80108a56:	e8 bc ca ff ff       	call   80105517 <memmove>
    len -= n;
80108a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a64:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a6a:	05 00 10 00 00       	add    $0x1000,%eax
80108a6f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108a72:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a76:	0f 85 6f ff ff ff    	jne    801089eb <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a81:	c9                   	leave  
80108a82:	c3                   	ret    
	...

80108a84 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80108a84:	55                   	push   %ebp
80108a85:	89 e5                	mov    %esp,%ebp
80108a87:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
80108a8a:	8b 45 10             	mov    0x10(%ebp),%eax
80108a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a98:	8b 45 08             	mov    0x8(%ebp),%eax
80108a9b:	89 04 24             	mov    %eax,(%esp)
80108a9e:	e8 74 ca ff ff       	call   80105517 <memmove>
}
80108aa3:	c9                   	leave  
80108aa4:	c3                   	ret    

80108aa5 <strcpy>:

char* strcpy(char *s, char *t){
80108aa5:	55                   	push   %ebp
80108aa6:	89 e5                	mov    %esp,%ebp
80108aa8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108aab:	8b 45 08             	mov    0x8(%ebp),%eax
80108aae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108ab1:	90                   	nop
80108ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab5:	8d 50 01             	lea    0x1(%eax),%edx
80108ab8:	89 55 08             	mov    %edx,0x8(%ebp)
80108abb:	8b 55 0c             	mov    0xc(%ebp),%edx
80108abe:	8d 4a 01             	lea    0x1(%edx),%ecx
80108ac1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108ac4:	8a 12                	mov    (%edx),%dl
80108ac6:	88 10                	mov    %dl,(%eax)
80108ac8:	8a 00                	mov    (%eax),%al
80108aca:	84 c0                	test   %al,%al
80108acc:	75 e4                	jne    80108ab2 <strcpy+0xd>
    ;
  return os;
80108ace:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108ad1:	c9                   	leave  
80108ad2:	c3                   	ret    

80108ad3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80108ad3:	55                   	push   %ebp
80108ad4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108ad6:	eb 06                	jmp    80108ade <strcmp+0xb>
    p++, q++;
80108ad8:	ff 45 08             	incl   0x8(%ebp)
80108adb:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
80108ade:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae1:	8a 00                	mov    (%eax),%al
80108ae3:	84 c0                	test   %al,%al
80108ae5:	74 0e                	je     80108af5 <strcmp+0x22>
80108ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80108aea:	8a 10                	mov    (%eax),%dl
80108aec:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aef:	8a 00                	mov    (%eax),%al
80108af1:	38 c2                	cmp    %al,%dl
80108af3:	74 e3                	je     80108ad8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80108af5:	8b 45 08             	mov    0x8(%ebp),%eax
80108af8:	8a 00                	mov    (%eax),%al
80108afa:	0f b6 d0             	movzbl %al,%edx
80108afd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b00:	8a 00                	mov    (%eax),%al
80108b02:	0f b6 c0             	movzbl %al,%eax
80108b05:	29 c2                	sub    %eax,%edx
80108b07:	89 d0                	mov    %edx,%eax
}
80108b09:	5d                   	pop    %ebp
80108b0a:	c3                   	ret    

80108b0b <set_root_inode>:

// struct con

void set_root_inode(char* name){
80108b0b:	55                   	push   %ebp
80108b0c:	89 e5                	mov    %esp,%ebp
80108b0e:	53                   	push   %ebx
80108b0f:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
80108b12:	8b 45 08             	mov    0x8(%ebp),%eax
80108b15:	89 04 24             	mov    %eax,(%esp)
80108b18:	e8 02 01 00 00       	call   80108c1f <find>
80108b1d:	89 c3                	mov    %eax,%ebx
80108b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80108b22:	89 04 24             	mov    %eax,(%esp)
80108b25:	e8 cd 9a ff ff       	call   801025f7 <namei>
80108b2a:	89 c2                	mov    %eax,%edx
80108b2c:	89 d8                	mov    %ebx,%eax
80108b2e:	01 c0                	add    %eax,%eax
80108b30:	01 d8                	add    %ebx,%eax
80108b32:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80108b39:	01 c8                	add    %ecx,%eax
80108b3b:	c1 e0 02             	shl    $0x2,%eax
80108b3e:	05 f0 7b 11 80       	add    $0x80117bf0,%eax
80108b43:	89 50 08             	mov    %edx,0x8(%eax)

}
80108b46:	83 c4 14             	add    $0x14,%esp
80108b49:	5b                   	pop    %ebx
80108b4a:	5d                   	pop    %ebp
80108b4b:	c3                   	ret    

80108b4c <get_name>:

void get_name(int vc_num, char* name){
80108b4c:	55                   	push   %ebp
80108b4d:	89 e5                	mov    %esp,%ebp
80108b4f:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80108b52:	8b 55 08             	mov    0x8(%ebp),%edx
80108b55:	89 d0                	mov    %edx,%eax
80108b57:	01 c0                	add    %eax,%eax
80108b59:	01 d0                	add    %edx,%eax
80108b5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b62:	01 d0                	add    %edx,%eax
80108b64:	c1 e0 02             	shl    $0x2,%eax
80108b67:	83 c0 10             	add    $0x10,%eax
80108b6a:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108b6f:	83 c0 08             	add    $0x8,%eax
80108b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80108b75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
80108b7c:	eb 03                	jmp    80108b81 <get_name+0x35>
	{
		i++;
80108b7e:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80108b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b87:	01 d0                	add    %edx,%eax
80108b89:	8a 00                	mov    (%eax),%al
80108b8b:	84 c0                	test   %al,%al
80108b8d:	75 ef                	jne    80108b7e <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80108b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b92:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b99:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba0:	89 04 24             	mov    %eax,(%esp)
80108ba3:	e8 dc fe ff ff       	call   80108a84 <memcpy2>
}
80108ba8:	c9                   	leave  
80108ba9:	c3                   	ret    

80108baa <g_name>:

char* g_name(int vc_bun){
80108baa:	55                   	push   %ebp
80108bab:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
80108bad:	8b 55 08             	mov    0x8(%ebp),%edx
80108bb0:	89 d0                	mov    %edx,%eax
80108bb2:	01 c0                	add    %eax,%eax
80108bb4:	01 d0                	add    %edx,%eax
80108bb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bbd:	01 d0                	add    %edx,%eax
80108bbf:	c1 e0 02             	shl    $0x2,%eax
80108bc2:	83 c0 10             	add    $0x10,%eax
80108bc5:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108bca:	83 c0 08             	add    $0x8,%eax
}
80108bcd:	5d                   	pop    %ebp
80108bce:	c3                   	ret    

80108bcf <is_full>:

int is_full(){
80108bcf:	55                   	push   %ebp
80108bd0:	89 e5                	mov    %esp,%ebp
80108bd2:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108bd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bdc:	eb 34                	jmp    80108c12 <is_full+0x43>
		if(strlen(containers[i].name) == 0){
80108bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108be1:	89 d0                	mov    %edx,%eax
80108be3:	01 c0                	add    %eax,%eax
80108be5:	01 d0                	add    %edx,%eax
80108be7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bee:	01 d0                	add    %edx,%eax
80108bf0:	c1 e0 02             	shl    $0x2,%eax
80108bf3:	83 c0 10             	add    $0x10,%eax
80108bf6:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108bfb:	83 c0 08             	add    $0x8,%eax
80108bfe:	89 04 24             	mov    %eax,(%esp)
80108c01:	e8 9b ca ff ff       	call   801056a1 <strlen>
80108c06:	85 c0                	test   %eax,%eax
80108c08:	75 05                	jne    80108c0f <is_full+0x40>
			return i;
80108c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0d:	eb 0e                	jmp    80108c1d <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108c0f:	ff 45 f4             	incl   -0xc(%ebp)
80108c12:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80108c16:	7e c6                	jle    80108bde <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108c18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108c1d:	c9                   	leave  
80108c1e:	c3                   	ret    

80108c1f <find>:

int find(char* name){
80108c1f:	55                   	push   %ebp
80108c20:	89 e5                	mov    %esp,%ebp
80108c22:	83 ec 18             	sub    $0x18,%esp
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108c25:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108c2c:	eb 54                	jmp    80108c82 <find+0x63>
		if(strcmp(name, "") == 0){
80108c2e:	c7 44 24 04 08 99 10 	movl   $0x80109908,0x4(%esp)
80108c35:	80 
80108c36:	8b 45 08             	mov    0x8(%ebp),%eax
80108c39:	89 04 24             	mov    %eax,(%esp)
80108c3c:	e8 92 fe ff ff       	call   80108ad3 <strcmp>
80108c41:	85 c0                	test   %eax,%eax
80108c43:	75 02                	jne    80108c47 <find+0x28>
			continue;
80108c45:	eb 38                	jmp    80108c7f <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80108c47:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108c4a:	89 d0                	mov    %edx,%eax
80108c4c:	01 c0                	add    %eax,%eax
80108c4e:	01 d0                	add    %edx,%eax
80108c50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c57:	01 d0                	add    %edx,%eax
80108c59:	c1 e0 02             	shl    $0x2,%eax
80108c5c:	83 c0 10             	add    $0x10,%eax
80108c5f:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108c64:	83 c0 08             	add    $0x8,%eax
80108c67:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c6e:	89 04 24             	mov    %eax,(%esp)
80108c71:	e8 5d fe ff ff       	call   80108ad3 <strcmp>
80108c76:	85 c0                	test   %eax,%eax
80108c78:	75 05                	jne    80108c7f <find+0x60>
			//cprintf("in hereI");
			return i;
80108c7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c7d:	eb 0e                	jmp    80108c8d <find+0x6e>
}

int find(char* name){
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108c7f:	ff 45 fc             	incl   -0x4(%ebp)
80108c82:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108c86:	7e a6                	jle    80108c2e <find+0xf>
		if(strcmp(name, containers[i].name) == 0){
			//cprintf("in hereI");
			return i;
		}
	}
	return -1;
80108c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108c8d:	c9                   	leave  
80108c8e:	c3                   	ret    

80108c8f <get_max_proc>:

int get_max_proc(int vc_num){
80108c8f:	55                   	push   %ebp
80108c90:	89 e5                	mov    %esp,%ebp
80108c92:	57                   	push   %edi
80108c93:	56                   	push   %esi
80108c94:	53                   	push   %ebx
80108c95:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108c98:	8b 55 08             	mov    0x8(%ebp),%edx
80108c9b:	89 d0                	mov    %edx,%eax
80108c9d:	01 c0                	add    %eax,%eax
80108c9f:	01 d0                	add    %edx,%eax
80108ca1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ca8:	01 d0                	add    %edx,%eax
80108caa:	c1 e0 02             	shl    $0x2,%eax
80108cad:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108cb2:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108cb5:	89 c3                	mov    %eax,%ebx
80108cb7:	b8 0f 00 00 00       	mov    $0xf,%eax
80108cbc:	89 d7                	mov    %edx,%edi
80108cbe:	89 de                	mov    %ebx,%esi
80108cc0:	89 c1                	mov    %eax,%ecx
80108cc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108cc4:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80108cc7:	83 c4 40             	add    $0x40,%esp
80108cca:	5b                   	pop    %ebx
80108ccb:	5e                   	pop    %esi
80108ccc:	5f                   	pop    %edi
80108ccd:	5d                   	pop    %ebp
80108cce:	c3                   	ret    

80108ccf <get_container>:

struct container* get_container(int vc_num){
80108ccf:	55                   	push   %ebp
80108cd0:	89 e5                	mov    %esp,%ebp
80108cd2:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80108cd5:	8b 55 08             	mov    0x8(%ebp),%edx
80108cd8:	89 d0                	mov    %edx,%eax
80108cda:	01 c0                	add    %eax,%eax
80108cdc:	01 d0                	add    %edx,%eax
80108cde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ce5:	01 d0                	add    %edx,%eax
80108ce7:	c1 e0 02             	shl    $0x2,%eax
80108cea:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108cef:	89 45 fc             	mov    %eax,-0x4(%ebp)
	// cprintf("vc num given is %d\n.", vc_num);
	// cprintf("The name for this container is %s.\n", cont->name);
	return cont;
80108cf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108cf5:	c9                   	leave  
80108cf6:	c3                   	ret    

80108cf7 <get_max_mem>:

int get_max_mem(int vc_num){
80108cf7:	55                   	push   %ebp
80108cf8:	89 e5                	mov    %esp,%ebp
80108cfa:	57                   	push   %edi
80108cfb:	56                   	push   %esi
80108cfc:	53                   	push   %ebx
80108cfd:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108d00:	8b 55 08             	mov    0x8(%ebp),%edx
80108d03:	89 d0                	mov    %edx,%eax
80108d05:	01 c0                	add    %eax,%eax
80108d07:	01 d0                	add    %edx,%eax
80108d09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d10:	01 d0                	add    %edx,%eax
80108d12:	c1 e0 02             	shl    $0x2,%eax
80108d15:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d1a:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108d1d:	89 c3                	mov    %eax,%ebx
80108d1f:	b8 0f 00 00 00       	mov    $0xf,%eax
80108d24:	89 d7                	mov    %edx,%edi
80108d26:	89 de                	mov    %ebx,%esi
80108d28:	89 c1                	mov    %eax,%ecx
80108d2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108d2c:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108d2f:	83 c4 40             	add    $0x40,%esp
80108d32:	5b                   	pop    %ebx
80108d33:	5e                   	pop    %esi
80108d34:	5f                   	pop    %edi
80108d35:	5d                   	pop    %ebp
80108d36:	c3                   	ret    

80108d37 <get_max_disk>:

int get_max_disk(int vc_num){
80108d37:	55                   	push   %ebp
80108d38:	89 e5                	mov    %esp,%ebp
80108d3a:	57                   	push   %edi
80108d3b:	56                   	push   %esi
80108d3c:	53                   	push   %ebx
80108d3d:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108d40:	8b 55 08             	mov    0x8(%ebp),%edx
80108d43:	89 d0                	mov    %edx,%eax
80108d45:	01 c0                	add    %eax,%eax
80108d47:	01 d0                	add    %edx,%eax
80108d49:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d50:	01 d0                	add    %edx,%eax
80108d52:	c1 e0 02             	shl    $0x2,%eax
80108d55:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d5a:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108d5d:	89 c3                	mov    %eax,%ebx
80108d5f:	b8 0f 00 00 00       	mov    $0xf,%eax
80108d64:	89 d7                	mov    %edx,%edi
80108d66:	89 de                	mov    %ebx,%esi
80108d68:	89 c1                	mov    %eax,%ecx
80108d6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80108d6c:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80108d6f:	83 c4 40             	add    $0x40,%esp
80108d72:	5b                   	pop    %ebx
80108d73:	5e                   	pop    %esi
80108d74:	5f                   	pop    %edi
80108d75:	5d                   	pop    %ebp
80108d76:	c3                   	ret    

80108d77 <get_curr_proc>:

int get_curr_proc(int vc_num){
80108d77:	55                   	push   %ebp
80108d78:	89 e5                	mov    %esp,%ebp
80108d7a:	57                   	push   %edi
80108d7b:	56                   	push   %esi
80108d7c:	53                   	push   %ebx
80108d7d:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108d80:	8b 55 08             	mov    0x8(%ebp),%edx
80108d83:	89 d0                	mov    %edx,%eax
80108d85:	01 c0                	add    %eax,%eax
80108d87:	01 d0                	add    %edx,%eax
80108d89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d90:	01 d0                	add    %edx,%eax
80108d92:	c1 e0 02             	shl    $0x2,%eax
80108d95:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108d9a:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108d9d:	89 c3                	mov    %eax,%ebx
80108d9f:	b8 0f 00 00 00       	mov    $0xf,%eax
80108da4:	89 d7                	mov    %edx,%edi
80108da6:	89 de                	mov    %ebx,%esi
80108da8:	89 c1                	mov    %eax,%ecx
80108daa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108dac:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80108daf:	83 c4 40             	add    $0x40,%esp
80108db2:	5b                   	pop    %ebx
80108db3:	5e                   	pop    %esi
80108db4:	5f                   	pop    %edi
80108db5:	5d                   	pop    %ebp
80108db6:	c3                   	ret    

80108db7 <get_curr_mem>:

int get_curr_mem(int vc_num){
80108db7:	55                   	push   %ebp
80108db8:	89 e5                	mov    %esp,%ebp
80108dba:	57                   	push   %edi
80108dbb:	56                   	push   %esi
80108dbc:	53                   	push   %ebx
80108dbd:	83 ec 5c             	sub    $0x5c,%esp
	struct container x = containers[vc_num];
80108dc0:	8b 55 08             	mov    0x8(%ebp),%edx
80108dc3:	89 d0                	mov    %edx,%eax
80108dc5:	01 c0                	add    %eax,%eax
80108dc7:	01 d0                	add    %edx,%eax
80108dc9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108dd0:	01 d0                	add    %edx,%eax
80108dd2:	c1 e0 02             	shl    $0x2,%eax
80108dd5:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108dda:	8d 55 ac             	lea    -0x54(%ebp),%edx
80108ddd:	89 c3                	mov    %eax,%ebx
80108ddf:	b8 0f 00 00 00       	mov    $0xf,%eax
80108de4:	89 d7                	mov    %edx,%edi
80108de6:	89 de                	mov    %ebx,%esi
80108de8:	89 c1                	mov    %eax,%ecx
80108dea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
80108dec:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108def:	89 44 24 04          	mov    %eax,0x4(%esp)
80108df3:	c7 04 24 0c 99 10 80 	movl   $0x8010990c,(%esp)
80108dfa:	e8 c2 75 ff ff       	call   801003c1 <cprintf>
	return x.curr_mem; 
80108dff:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80108e02:	83 c4 5c             	add    $0x5c,%esp
80108e05:	5b                   	pop    %ebx
80108e06:	5e                   	pop    %esi
80108e07:	5f                   	pop    %edi
80108e08:	5d                   	pop    %ebp
80108e09:	c3                   	ret    

80108e0a <get_curr_disk>:

int get_curr_disk(int vc_num){
80108e0a:	55                   	push   %ebp
80108e0b:	89 e5                	mov    %esp,%ebp
80108e0d:	57                   	push   %edi
80108e0e:	56                   	push   %esi
80108e0f:	53                   	push   %ebx
80108e10:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108e13:	8b 55 08             	mov    0x8(%ebp),%edx
80108e16:	89 d0                	mov    %edx,%eax
80108e18:	01 c0                	add    %eax,%eax
80108e1a:	01 d0                	add    %edx,%eax
80108e1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e23:	01 d0                	add    %edx,%eax
80108e25:	c1 e0 02             	shl    $0x2,%eax
80108e28:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e2d:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108e30:	89 c3                	mov    %eax,%ebx
80108e32:	b8 0f 00 00 00       	mov    $0xf,%eax
80108e37:	89 d7                	mov    %edx,%edi
80108e39:	89 de                	mov    %ebx,%esi
80108e3b:	89 c1                	mov    %eax,%ecx
80108e3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80108e3f:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
80108e42:	83 c4 40             	add    $0x40,%esp
80108e45:	5b                   	pop    %ebx
80108e46:	5e                   	pop    %esi
80108e47:	5f                   	pop    %edi
80108e48:	5d                   	pop    %ebp
80108e49:	c3                   	ret    

80108e4a <set_name>:

void set_name(char* name, int vc_num){
80108e4a:	55                   	push   %ebp
80108e4b:	89 e5                	mov    %esp,%ebp
80108e4d:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80108e50:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e53:	89 d0                	mov    %edx,%eax
80108e55:	01 c0                	add    %eax,%eax
80108e57:	01 d0                	add    %edx,%eax
80108e59:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e60:	01 d0                	add    %edx,%eax
80108e62:	c1 e0 02             	shl    $0x2,%eax
80108e65:	83 c0 10             	add    $0x10,%eax
80108e68:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e6d:	8d 50 08             	lea    0x8(%eax),%edx
80108e70:	8b 45 08             	mov    0x8(%ebp),%eax
80108e73:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e77:	89 14 24             	mov    %edx,(%esp)
80108e7a:	e8 26 fc ff ff       	call   80108aa5 <strcpy>
}
80108e7f:	c9                   	leave  
80108e80:	c3                   	ret    

80108e81 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80108e81:	55                   	push   %ebp
80108e82:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80108e84:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e87:	89 d0                	mov    %edx,%eax
80108e89:	01 c0                	add    %eax,%eax
80108e8b:	01 d0                	add    %edx,%eax
80108e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e94:	01 d0                	add    %edx,%eax
80108e96:	c1 e0 02             	shl    $0x2,%eax
80108e99:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea2:	89 02                	mov    %eax,(%edx)
}
80108ea4:	5d                   	pop    %ebp
80108ea5:	c3                   	ret    

80108ea6 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
80108ea6:	55                   	push   %ebp
80108ea7:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
80108ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
80108eac:	89 d0                	mov    %edx,%eax
80108eae:	01 c0                	add    %eax,%eax
80108eb0:	01 d0                	add    %edx,%eax
80108eb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108eb9:	01 d0                	add    %edx,%eax
80108ebb:	c1 e0 02             	shl    $0x2,%eax
80108ebe:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec7:	89 42 08             	mov    %eax,0x8(%edx)
}
80108eca:	5d                   	pop    %ebp
80108ecb:	c3                   	ret    

80108ecc <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80108ecc:	55                   	push   %ebp
80108ecd:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80108ecf:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ed2:	89 d0                	mov    %edx,%eax
80108ed4:	01 c0                	add    %eax,%eax
80108ed6:	01 d0                	add    %edx,%eax
80108ed8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108edf:	01 d0                	add    %edx,%eax
80108ee1:	c1 e0 02             	shl    $0x2,%eax
80108ee4:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80108eea:	8b 45 08             	mov    0x8(%ebp),%eax
80108eed:	89 42 04             	mov    %eax,0x4(%edx)
}
80108ef0:	5d                   	pop    %ebp
80108ef1:	c3                   	ret    

80108ef2 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
80108ef2:	55                   	push   %ebp
80108ef3:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
80108ef5:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ef8:	89 d0                	mov    %edx,%eax
80108efa:	01 c0                	add    %eax,%eax
80108efc:	01 d0                	add    %edx,%eax
80108efe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f05:	01 d0                	add    %edx,%eax
80108f07:	c1 e0 02             	shl    $0x2,%eax
80108f0a:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f0f:	8b 40 0c             	mov    0xc(%eax),%eax
80108f12:	8d 48 01             	lea    0x1(%eax),%ecx
80108f15:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f18:	89 d0                	mov    %edx,%eax
80108f1a:	01 c0                	add    %eax,%eax
80108f1c:	01 d0                	add    %edx,%eax
80108f1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f25:	01 d0                	add    %edx,%eax
80108f27:	c1 e0 02             	shl    $0x2,%eax
80108f2a:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f2f:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem-1, containers[vc_num].curr_mem);	
}
80108f32:	5d                   	pop    %ebp
80108f33:	c3                   	ret    

80108f34 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
80108f34:	55                   	push   %ebp
80108f35:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;
80108f37:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f3a:	89 d0                	mov    %edx,%eax
80108f3c:	01 c0                	add    %eax,%eax
80108f3e:	01 d0                	add    %edx,%eax
80108f40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f47:	01 d0                	add    %edx,%eax
80108f49:	c1 e0 02             	shl    $0x2,%eax
80108f4c:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f51:	8b 40 0c             	mov    0xc(%eax),%eax
80108f54:	8d 48 ff             	lea    -0x1(%eax),%ecx
80108f57:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f5a:	89 d0                	mov    %edx,%eax
80108f5c:	01 c0                	add    %eax,%eax
80108f5e:	01 d0                	add    %edx,%eax
80108f60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f67:	01 d0                	add    %edx,%eax
80108f69:	c1 e0 02             	shl    $0x2,%eax
80108f6c:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f71:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem, containers[vc_num].curr_mem-1);	
}
80108f74:	5d                   	pop    %ebp
80108f75:	c3                   	ret    

80108f76 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80108f76:	55                   	push   %ebp
80108f77:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
80108f79:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f7c:	89 d0                	mov    %edx,%eax
80108f7e:	01 c0                	add    %eax,%eax
80108f80:	01 d0                	add    %edx,%eax
80108f82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f89:	01 d0                	add    %edx,%eax
80108f8b:	c1 e0 02             	shl    $0x2,%eax
80108f8e:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108f93:	8b 50 04             	mov    0x4(%eax),%edx
80108f96:	8b 45 08             	mov    0x8(%ebp),%eax
80108f99:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f9f:	89 d0                	mov    %edx,%eax
80108fa1:	01 c0                	add    %eax,%eax
80108fa3:	01 d0                	add    %edx,%eax
80108fa5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fac:	01 d0                	add    %edx,%eax
80108fae:	c1 e0 02             	shl    $0x2,%eax
80108fb1:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80108fb6:	89 48 04             	mov    %ecx,0x4(%eax)
}
80108fb9:	5d                   	pop    %ebp
80108fba:	c3                   	ret    

80108fbb <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80108fbb:	55                   	push   %ebp
80108fbc:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80108fbe:	8b 55 0c             	mov    0xc(%ebp),%edx
80108fc1:	89 d0                	mov    %edx,%eax
80108fc3:	01 c0                	add    %eax,%eax
80108fc5:	01 d0                	add    %edx,%eax
80108fc7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fce:	01 d0                	add    %edx,%eax
80108fd0:	c1 e0 02             	shl    $0x2,%eax
80108fd3:	8d 90 d0 7b 11 80    	lea    -0x7fee8430(%eax),%edx
80108fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80108fdc:	89 02                	mov    %eax,(%edx)
}
80108fde:	5d                   	pop    %ebp
80108fdf:	c3                   	ret    

80108fe0 <container_init>:

void container_init(){
80108fe0:	55                   	push   %ebp
80108fe1:	89 e5                	mov    %esp,%ebp
80108fe3:	83 ec 18             	sub    $0x18,%esp

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108fe6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108fed:	e9 f7 00 00 00       	jmp    801090e9 <container_init+0x109>
		strcpy(containers[i].name, "");
80108ff2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ff5:	89 d0                	mov    %edx,%eax
80108ff7:	01 c0                	add    %eax,%eax
80108ff9:	01 d0                	add    %edx,%eax
80108ffb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109002:	01 d0                	add    %edx,%eax
80109004:	c1 e0 02             	shl    $0x2,%eax
80109007:	83 c0 10             	add    $0x10,%eax
8010900a:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010900f:	83 c0 08             	add    $0x8,%eax
80109012:	c7 44 24 04 08 99 10 	movl   $0x80109908,0x4(%esp)
80109019:	80 
8010901a:	89 04 24             	mov    %eax,(%esp)
8010901d:	e8 83 fa ff ff       	call   80108aa5 <strcpy>
		containers[i].max_proc = 4;
80109022:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109025:	89 d0                	mov    %edx,%eax
80109027:	01 c0                	add    %eax,%eax
80109029:	01 d0                	add    %edx,%eax
8010902b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109032:	01 d0                	add    %edx,%eax
80109034:	c1 e0 02             	shl    $0x2,%eax
80109037:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010903c:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80109043:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109046:	89 d0                	mov    %edx,%eax
80109048:	01 c0                	add    %eax,%eax
8010904a:	01 d0                	add    %edx,%eax
8010904c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109053:	01 d0                	add    %edx,%eax
80109055:	c1 e0 02             	shl    $0x2,%eax
80109058:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010905d:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
80109064:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109067:	89 d0                	mov    %edx,%eax
80109069:	01 c0                	add    %eax,%eax
8010906b:	01 d0                	add    %edx,%eax
8010906d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109074:	01 d0                	add    %edx,%eax
80109076:	c1 e0 02             	shl    $0x2,%eax
80109079:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010907e:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 1;
80109084:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109087:	89 d0                	mov    %edx,%eax
80109089:	01 c0                	add    %eax,%eax
8010908b:	01 d0                	add    %edx,%eax
8010908d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109094:	01 d0                	add    %edx,%eax
80109096:	c1 e0 02             	shl    $0x2,%eax
80109099:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010909e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
801090a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801090a7:	89 d0                	mov    %edx,%eax
801090a9:	01 c0                	add    %eax,%eax
801090ab:	01 d0                	add    %edx,%eax
801090ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090b4:	01 d0                	add    %edx,%eax
801090b6:	c1 e0 02             	shl    $0x2,%eax
801090b9:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
801090be:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
801090c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801090c8:	89 d0                	mov    %edx,%eax
801090ca:	01 c0                	add    %eax,%eax
801090cc:	01 d0                	add    %edx,%eax
801090ce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090d5:	01 d0                	add    %edx,%eax
801090d7:	c1 e0 02             	shl    $0x2,%eax
801090da:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801090df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

void container_init(){

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801090e6:	ff 45 fc             	incl   -0x4(%ebp)
801090e9:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801090ed:	0f 8e ff fe ff ff    	jle    80108ff2 <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
801090f3:	c9                   	leave  
801090f4:	c3                   	ret    
