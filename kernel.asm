
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
8010002d:	b8 56 3a 10 80       	mov    $0x80103a56,%eax
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
8010003a:	c7 44 24 04 d0 94 10 	movl   $0x801094d0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100049:	e8 1c 53 00 00       	call   8010536a <initlock>

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
80100087:	c7 44 24 04 d7 94 10 	movl   $0x801094d7,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 95 51 00 00       	call   8010522c <initsleeplock>
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
801000c9:	e8 bd 52 00 00       	call   8010538b <acquire>

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
80100104:	e8 ec 52 00 00       	call   801053f5 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 4f 51 00 00       	call   80105266 <acquiresleep>
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
8010017d:	e8 73 52 00 00       	call   801053f5 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 d6 50 00 00       	call   80105266 <acquiresleep>
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
801001a7:	c7 04 24 de 94 10 80 	movl   $0x801094de,(%esp)
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
801001e2:	e8 26 29 00 00       	call   80102b0d <iderw>
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
801001fb:	e8 03 51 00 00       	call   80105303 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 ef 94 10 80 	movl   $0x801094ef,(%esp)
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
80100225:	e8 e3 28 00 00       	call   80102b0d <iderw>
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
8010023b:	e8 c3 50 00 00       	call   80105303 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 f6 94 10 80 	movl   $0x801094f6,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 63 50 00 00       	call   801052c1 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 20 d9 10 80 	movl   $0x8010d920,(%esp)
80100265:	e8 21 51 00 00       	call   8010538b <acquire>
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
801002d1:	e8 1f 51 00 00       	call   801053f5 <release>
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
801003dc:	e8 aa 4f 00 00       	call   8010538b <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 fd 94 10 80 	movl   $0x801094fd,(%esp)
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
801004cf:	c7 45 ec 06 95 10 80 	movl   $0x80109506,-0x14(%ebp)
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
8010054d:	e8 a3 4e 00 00       	call   801053f5 <release>
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
80100569:	e8 bb 2c 00 00       	call   80103229 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 0d 95 10 80 	movl   $0x8010950d,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 21 95 10 80 	movl   $0x80109521,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 9b 4e 00 00       	call   80105442 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 23 95 10 80 	movl   $0x80109523,(%esp)
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
80100695:	c7 04 24 27 95 10 80 	movl   $0x80109527,(%esp)
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
801006c9:	e8 e9 4f 00 00       	call   801056b7 <memmove>
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
801006f8:	e8 f1 4e 00 00       	call   801055ee <memset>
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
8010078e:	e8 45 6d 00 00       	call   801074d8 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 39 6d 00 00       	call   801074d8 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 2d 6d 00 00       	call   801074d8 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 20 6d 00 00       	call   801074d8 <uartputc>
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
80100813:	e8 73 4b 00 00       	call   8010538b <acquire>
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
80100a00:	e8 f6 43 00 00       	call   80104dfb <wakeup>
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
80100a21:	e8 cf 49 00 00       	call   801053f5 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 3a 95 10 80 	movl   $0x8010953a,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 64 44 00 00       	call   80104ea1 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 52 95 10 80 	movl   $0x80109552,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 6c 95 10 80 	movl   $0x8010956c,(%esp)
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
80100a8a:	e8 fc 48 00 00       	call   8010538b <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 d8 39 00 00       	call   80104473 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100aa9:	e8 47 49 00 00       	call   801053f5 <release>
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
80100ad2:	e8 4d 42 00 00       	call   80104d24 <sleep>

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
80100b5c:	e8 94 48 00 00       	call   801053f5 <release>
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
80100ba2:	e8 e4 47 00 00       	call   8010538b <acquire>
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
80100bda:	e8 16 48 00 00       	call   801053f5 <release>
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
80100bf5:	c7 44 24 04 85 95 10 	movl   $0x80109585,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80100c04:	e8 61 47 00 00       	call   8010536a <initlock>

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
80100c36:	e8 84 20 00 00       	call   80102cbf <ioapicenable>
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
80100c49:	e8 25 38 00 00       	call   80104473 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 1d 2b 00 00       	call   80103773 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 bc 1a 00 00       	call   8010271d <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 86 2b 00 00       	call   801037f5 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 8d 95 10 80 	movl   $0x8010958d,(%esp)
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
80100cd8:	e8 dd 77 00 00       	call   801084ba <setupkvm>
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
80100d96:	e8 eb 7a 00 00       	call   80108886 <allocuvm>
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
80100de8:	e8 b6 79 00 00       	call   801087a3 <loaduvm>
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
80100e1f:	e8 d1 29 00 00       	call   801037f5 <end_op>
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
80100e54:	e8 2d 7a 00 00       	call   80108886 <allocuvm>
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
80100e79:	e8 78 7c 00 00       	call   80108af6 <clearpteu>
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
80100eaf:	e8 8d 49 00 00       	call   80105841 <strlen>
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
80100ed6:	e8 66 49 00 00       	call   80105841 <strlen>
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
80100f04:	e8 a5 7d 00 00       	call   80108cae <copyout>
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
80100fa8:	e8 01 7d 00 00       	call   80108cae <copyout>
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
80100ff8:	e8 fd 47 00 00       	call   801057fa <safestrcpy>

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
80101038:	e8 57 75 00 00       	call   80108594 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 18 7a 00 00       	call   80108a60 <freevm>
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
8010105b:	e8 00 7a 00 00       	call   80108a60 <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 7f 27 00 00       	call   801037f5 <end_op>
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
801010ec:	c7 44 24 04 99 95 10 	movl   $0x80109599,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801010fb:	e8 6a 42 00 00       	call   8010536a <initlock>
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
8010110f:	e8 77 42 00 00       	call   8010538b <acquire>
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
80101138:	e8 b8 42 00 00       	call   801053f5 <release>
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
80101156:	e8 9a 42 00 00       	call   801053f5 <release>
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
8010116f:	e8 17 42 00 00       	call   8010538b <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 a0 95 10 80 	movl   $0x801095a0,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 20 23 11 80 	movl   $0x80112320,(%esp)
801011a0:	e8 50 42 00 00       	call   801053f5 <release>
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
801011ba:	e8 cc 41 00 00       	call   8010538b <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 a8 95 10 80 	movl   $0x801095a8,(%esp)
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
801011f5:	e8 fb 41 00 00       	call   801053f5 <release>
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
8010122b:	e8 c5 41 00 00       	call   801053f5 <release>

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
80101248:	e8 be 2e 00 00       	call   8010410b <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 17 25 00 00       	call   80103773 <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 89 25 00 00       	call   801037f5 <end_op>
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
801012fe:	e8 86 2f 00 00       	call   80104289 <piperead>
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
80101370:	c7 04 24 b2 95 10 80 	movl   $0x801095b2,(%esp)
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
801013ba:	e8 de 2d 00 00       	call   8010419d <pipewrite>
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
80101400:	e8 6e 23 00 00       	call   80103773 <begin_op>
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
80101466:	e8 8a 23 00 00       	call   801037f5 <end_op>

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
8010147b:	c7 04 24 bb 95 10 80 	movl   $0x801095bb,(%esp)
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
801014ad:	c7 04 24 cb 95 10 80 	movl   $0x801095cb,(%esp)
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
801014f4:	e8 be 41 00 00       	call   801056b7 <memmove>
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
8010153a:	e8 af 40 00 00       	call   801055ee <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 2d 24 00 00       	call   80103977 <log_write>
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
8010160d:	e8 65 23 00 00       	call   80103977 <log_write>
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
80101683:	c7 04 24 d8 95 10 80 	movl   $0x801095d8,(%esp)
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
80101713:	c7 04 24 ee 95 10 80 	movl   $0x801095ee,(%esp)
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
80101749:	e8 29 22 00 00       	call   80103977 <log_write>
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
8010176b:	c7 44 24 04 01 96 10 	movl   $0x80109601,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
8010177a:	e8 eb 3b 00 00       	call   8010536a <initlock>
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
801017a0:	c7 44 24 04 08 96 10 	movl   $0x80109608,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 7c 3a 00 00       	call   8010522c <initsleeplock>
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
80101819:	c7 04 24 10 96 10 80 	movl   $0x80109610,(%esp)
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
8010189b:	e8 4e 3d 00 00       	call   801055ee <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 c3 20 00 00       	call   80103977 <log_write>
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
801018f1:	c7 04 24 63 96 10 80 	movl   $0x80109663,(%esp)
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
8010199e:	e8 14 3d 00 00       	call   801056b7 <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 c9 1f 00 00       	call   80103977 <log_write>
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
801019c8:	e8 be 39 00 00       	call   8010538b <acquire>

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
80101a12:	e8 de 39 00 00       	call   801053f5 <release>
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
80101a48:	c7 04 24 75 96 10 80 	movl   $0x80109675,(%esp)
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
80101a86:	e8 6a 39 00 00       	call   801053f5 <release>

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
80101a9d:	e8 e9 38 00 00       	call   8010538b <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101ab8:	e8 38 39 00 00       	call   801053f5 <release>
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
80101ad8:	c7 04 24 85 96 10 80 	movl   $0x80109685,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 74 37 00 00       	call   80105266 <acquiresleep>

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
80101b99:	e8 19 3b 00 00       	call   801056b7 <memmove>
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
80101bbe:	c7 04 24 8b 96 10 80 	movl   $0x8010968b,(%esp)
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
80101be1:	e8 1d 37 00 00       	call   80105303 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 9a 96 10 80 	movl   $0x8010969a,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 b3 36 00 00       	call   801052c1 <releasesleep>
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
80101c1f:	e8 42 36 00 00       	call   80105266 <acquiresleep>
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
80101c41:	e8 45 37 00 00       	call   8010538b <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c56:	e8 9a 37 00 00       	call   801053f5 <release>
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
80101c93:	e8 29 36 00 00       	call   801052c1 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101c9f:	e8 e7 36 00 00       	call   8010538b <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 e0 2e 11 80 	movl   $0x80112ee0,(%esp)
80101cba:	e8 36 37 00 00       	call   801053f5 <release>
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
80101dcb:	e8 a7 1b 00 00       	call   80103977 <log_write>
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
80101de0:	c7 04 24 a2 96 10 80 	movl   $0x801096a2,(%esp)
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
8010208a:	e8 28 36 00 00       	call   801056b7 <memmove>
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
801020c3:	e8 ab 23 00 00       	call   80104473 <myproc>
801020c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	83 c0 18             	add    $0x18,%eax
801020d7:	89 04 24             	mov    %eax,(%esp)
801020da:	e8 14 6e 00 00       	call   80108ef3 <find>
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
8010211a:	c7 04 24 b5 96 10 80 	movl   $0x801096b5,(%esp)
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
8010218b:	c7 04 24 bc 96 10 80 	movl   $0x801096bc,(%esp)
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
80102220:	e8 92 34 00 00       	call   801056b7 <memmove>
    log_write(bp);
80102225:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102228:	89 04 24             	mov    %eax,(%esp)
8010222b:	e8 47 17 00 00       	call   80103977 <log_write>
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
80102266:	c7 04 24 c3 96 10 80 	movl   $0x801096c3,(%esp)
8010226d:	e8 4f e1 ff ff       	call   801003c1 <cprintf>
    if(tot == 1){
80102272:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102276:	75 13                	jne    8010228b <writei+0x1ce>
      set_curr_disk(1, x);
80102278:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102286:	e8 bf 6f 00 00       	call   8010924a <set_curr_disk>
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
801022d0:	e8 81 34 00 00       	call   80105756 <strncmp>
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
801022e9:	c7 04 24 c7 96 10 80 	movl   $0x801096c7,(%esp)
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
80102327:	c7 04 24 d9 96 10 80 	movl   $0x801096d9,(%esp)
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
8010240a:	c7 04 24 e8 96 10 80 	movl   $0x801096e8,(%esp)
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
8010244e:	e8 51 33 00 00       	call   801057a4 <strncpy>
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
80102480:	c7 04 24 f5 96 10 80 	movl   $0x801096f5,(%esp)
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
801024ff:	e8 b3 31 00 00       	call   801056b7 <memmove>
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
8010251a:	e8 98 31 00 00       	call   801056b7 <memmove>
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

8010253d <strcmp3>:

int
strcmp3(const char *p, const char *q)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80102540:	eb 06                	jmp    80102548 <strcmp3+0xb>
    p++, q++;
80102542:	ff 45 08             	incl   0x8(%ebp)
80102545:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp3(const char *p, const char *q)
{
  while(*p && *p == *q)
80102548:	8b 45 08             	mov    0x8(%ebp),%eax
8010254b:	8a 00                	mov    (%eax),%al
8010254d:	84 c0                	test   %al,%al
8010254f:	74 0e                	je     8010255f <strcmp3+0x22>
80102551:	8b 45 08             	mov    0x8(%ebp),%eax
80102554:	8a 10                	mov    (%eax),%dl
80102556:	8b 45 0c             	mov    0xc(%ebp),%eax
80102559:	8a 00                	mov    (%eax),%al
8010255b:	38 c2                	cmp    %al,%dl
8010255d:	74 e3                	je     80102542 <strcmp3+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
8010255f:	8b 45 08             	mov    0x8(%ebp),%eax
80102562:	8a 00                	mov    (%eax),%al
80102564:	0f b6 d0             	movzbl %al,%edx
80102567:	8b 45 0c             	mov    0xc(%ebp),%eax
8010256a:	8a 00                	mov    (%eax),%al
8010256c:	0f b6 c0             	movzbl %al,%eax
8010256f:	29 c2                	sub    %eax,%edx
80102571:	89 d0                	mov    %edx,%eax
}
80102573:	5d                   	pop    %ebp
80102574:	c3                   	ret    

80102575 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102575:	55                   	push   %ebp
80102576:	89 e5                	mov    %esp,%ebp
80102578:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010257b:	8b 45 08             	mov    0x8(%ebp),%eax
8010257e:	8a 00                	mov    (%eax),%al
80102580:	3c 2f                	cmp    $0x2f,%al
80102582:	75 19                	jne    8010259d <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
80102584:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010258b:	00 
8010258c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102593:	e8 23 f4 ff ff       	call   801019bb <iget>
80102598:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010259b:	eb 13                	jmp    801025b0 <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
8010259d:	e8 d1 1e 00 00       	call   80104473 <myproc>
801025a2:	8b 40 68             	mov    0x68(%eax),%eax
801025a5:	89 04 24             	mov    %eax,(%esp)
801025a8:	e8 e3 f4 ff ff       	call   80101a90 <idup>
801025ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
801025b0:	e8 be 1e 00 00       	call   80104473 <myproc>
801025b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
801025b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
801025bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801025c3:	74 11                	je     801025d6 <namex+0x61>
    cont = p->cont;
801025c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801025ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  while((path = skipelem(path, name)) != 0){
801025d1:	e9 0b 01 00 00       	jmp    801026e1 <namex+0x16c>
801025d6:	e9 06 01 00 00       	jmp    801026e1 <namex+0x16c>
    ilock(ip);
801025db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025de:	89 04 24             	mov    %eax,(%esp)
801025e1:	e8 dc f4 ff ff       	call   80101ac2 <ilock>

    if(ip->type != T_DIR){
801025e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e9:	8b 40 50             	mov    0x50(%eax),%eax
801025ec:	66 83 f8 01          	cmp    $0x1,%ax
801025f0:	74 15                	je     80102607 <namex+0x92>
      iunlockput(ip);
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f5:	89 04 24             	mov    %eax,(%esp)
801025f8:	e8 c4 f6 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801025fd:	b8 00 00 00 00       	mov    $0x0,%eax
80102602:	e9 14 01 00 00       	jmp    8010271b <namex+0x1a6>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
80102607:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
8010260e:	00 
8010260f:	c7 44 24 04 fd 96 10 	movl   $0x801096fd,0x4(%esp)
80102616:	80 
80102617:	8b 45 08             	mov    0x8(%ebp),%eax
8010261a:	89 04 24             	mov    %eax,(%esp)
8010261d:	e8 34 31 00 00       	call   80105756 <strncmp>
80102622:	85 c0                	test   %eax,%eax
80102624:	75 2c                	jne    80102652 <namex+0xdd>
80102626:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010262a:	74 26                	je     80102652 <namex+0xdd>
8010262c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010262f:	8b 40 38             	mov    0x38(%eax),%eax
80102632:	8b 50 04             	mov    0x4(%eax),%edx
80102635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102638:	8b 40 04             	mov    0x4(%eax),%eax
8010263b:	39 c2                	cmp    %eax,%edx
8010263d:	75 13                	jne    80102652 <namex+0xdd>
      iunlock(ip);
8010263f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102642:	89 04 24             	mov    %eax,(%esp)
80102645:	e8 82 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
8010264a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010264d:	e9 c9 00 00 00       	jmp    8010271b <namex+0x1a6>
    }

    if(cont != NULL && ip->inum == ROOTINO){
80102652:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102656:	74 21                	je     80102679 <namex+0x104>
80102658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265b:	8b 40 04             	mov    0x4(%eax),%eax
8010265e:	83 f8 01             	cmp    $0x1,%eax
80102661:	75 16                	jne    80102679 <namex+0x104>
      iunlock(ip);
80102663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102666:	89 04 24             	mov    %eax,(%esp)
80102669:	e8 5e f5 ff ff       	call   80101bcc <iunlock>
      return cont->root;
8010266e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102671:	8b 40 38             	mov    0x38(%eax),%eax
80102674:	e9 a2 00 00 00       	jmp    8010271b <namex+0x1a6>
    }

    if(nameiparent && *path == '\0'){
80102679:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010267d:	74 1c                	je     8010269b <namex+0x126>
8010267f:	8b 45 08             	mov    0x8(%ebp),%eax
80102682:	8a 00                	mov    (%eax),%al
80102684:	84 c0                	test   %al,%al
80102686:	75 13                	jne    8010269b <namex+0x126>
      // Stop one level early.
      iunlock(ip);
80102688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268b:	89 04 24             	mov    %eax,(%esp)
8010268e:	e8 39 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
80102693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102696:	e9 80 00 00 00       	jmp    8010271b <namex+0x1a6>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010269b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026a2:	00 
801026a3:	8b 45 10             	mov    0x10(%ebp),%eax
801026a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ad:	89 04 24             	mov    %eax,(%esp)
801026b0:	e8 22 fc ff ff       	call   801022d7 <dirlookup>
801026b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801026b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801026bc:	75 12                	jne    801026d0 <namex+0x15b>
      iunlockput(ip);
801026be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c1:	89 04 24             	mov    %eax,(%esp)
801026c4:	e8 f8 f5 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801026c9:	b8 00 00 00 00       	mov    $0x0,%eax
801026ce:	eb 4b                	jmp    8010271b <namex+0x1a6>
    }
    iunlockput(ip);
801026d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d3:	89 04 24             	mov    %eax,(%esp)
801026d6:	e8 e6 f5 ff ff       	call   80101cc1 <iunlockput>

    ip = next;
801026db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct container* cont = NULL;
  if(p != NULL){
    cont = p->cont;
  }

  while((path = skipelem(path, name)) != 0){
801026e1:	8b 45 10             	mov    0x10(%ebp),%eax
801026e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801026e8:	8b 45 08             	mov    0x8(%ebp),%eax
801026eb:	89 04 24             	mov    %eax,(%esp)
801026ee:	e8 a0 fd ff ff       	call   80102493 <skipelem>
801026f3:	89 45 08             	mov    %eax,0x8(%ebp)
801026f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026fa:	0f 85 db fe ff ff    	jne    801025db <namex+0x66>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
80102700:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102704:	74 12                	je     80102718 <namex+0x1a3>
    iput(ip);
80102706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102709:	89 04 24             	mov    %eax,(%esp)
8010270c:	e8 ff f4 ff ff       	call   80101c10 <iput>
    return 0;
80102711:	b8 00 00 00 00       	mov    $0x0,%eax
80102716:	eb 03                	jmp    8010271b <namex+0x1a6>
  }

  
  return ip;
80102718:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010271b:	c9                   	leave  
8010271c:	c3                   	ret    

8010271d <namei>:

struct inode*
namei(char *path)
{
8010271d:	55                   	push   %ebp
8010271e:	89 e5                	mov    %esp,%ebp
80102720:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102723:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102726:	89 44 24 08          	mov    %eax,0x8(%esp)
8010272a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102731:	00 
80102732:	8b 45 08             	mov    0x8(%ebp),%eax
80102735:	89 04 24             	mov    %eax,(%esp)
80102738:	e8 38 fe ff ff       	call   80102575 <namex>
}
8010273d:	c9                   	leave  
8010273e:	c3                   	ret    

8010273f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010273f:	55                   	push   %ebp
80102740:	89 e5                	mov    %esp,%ebp
80102742:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102745:	8b 45 0c             	mov    0xc(%ebp),%eax
80102748:	89 44 24 08          	mov    %eax,0x8(%esp)
8010274c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102753:	00 
80102754:	8b 45 08             	mov    0x8(%ebp),%eax
80102757:	89 04 24             	mov    %eax,(%esp)
8010275a:	e8 16 fe ff ff       	call   80102575 <namex>
}
8010275f:	c9                   	leave  
80102760:	c3                   	ret    
80102761:	00 00                	add    %al,(%eax)
	...

80102764 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102764:	55                   	push   %ebp
80102765:	89 e5                	mov    %esp,%ebp
80102767:	83 ec 14             	sub    $0x14,%esp
8010276a:	8b 45 08             	mov    0x8(%ebp),%eax
8010276d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102771:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102774:	89 c2                	mov    %eax,%edx
80102776:	ec                   	in     (%dx),%al
80102777:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010277a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010277d:	c9                   	leave  
8010277e:	c3                   	ret    

8010277f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010277f:	55                   	push   %ebp
80102780:	89 e5                	mov    %esp,%ebp
80102782:	57                   	push   %edi
80102783:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102784:	8b 55 08             	mov    0x8(%ebp),%edx
80102787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010278a:	8b 45 10             	mov    0x10(%ebp),%eax
8010278d:	89 cb                	mov    %ecx,%ebx
8010278f:	89 df                	mov    %ebx,%edi
80102791:	89 c1                	mov    %eax,%ecx
80102793:	fc                   	cld    
80102794:	f3 6d                	rep insl (%dx),%es:(%edi)
80102796:	89 c8                	mov    %ecx,%eax
80102798:	89 fb                	mov    %edi,%ebx
8010279a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010279d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027a0:	5b                   	pop    %ebx
801027a1:	5f                   	pop    %edi
801027a2:	5d                   	pop    %ebp
801027a3:	c3                   	ret    

801027a4 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027a4:	55                   	push   %ebp
801027a5:	89 e5                	mov    %esp,%ebp
801027a7:	83 ec 08             	sub    $0x8,%esp
801027aa:	8b 45 08             	mov    0x8(%ebp),%eax
801027ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801027b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801027b4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027b7:	8a 45 f8             	mov    -0x8(%ebp),%al
801027ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801027bd:	ee                   	out    %al,(%dx)
}
801027be:	c9                   	leave  
801027bf:	c3                   	ret    

801027c0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	56                   	push   %esi
801027c4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027c5:	8b 55 08             	mov    0x8(%ebp),%edx
801027c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027cb:	8b 45 10             	mov    0x10(%ebp),%eax
801027ce:	89 cb                	mov    %ecx,%ebx
801027d0:	89 de                	mov    %ebx,%esi
801027d2:	89 c1                	mov    %eax,%ecx
801027d4:	fc                   	cld    
801027d5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027d7:	89 c8                	mov    %ecx,%eax
801027d9:	89 f3                	mov    %esi,%ebx
801027db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027de:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027e1:	5b                   	pop    %ebx
801027e2:	5e                   	pop    %esi
801027e3:	5d                   	pop    %ebp
801027e4:	c3                   	ret    

801027e5 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027e5:	55                   	push   %ebp
801027e6:	89 e5                	mov    %esp,%ebp
801027e8:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027eb:	90                   	nop
801027ec:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027f3:	e8 6c ff ff ff       	call   80102764 <inb>
801027f8:	0f b6 c0             	movzbl %al,%eax
801027fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102801:	25 c0 00 00 00       	and    $0xc0,%eax
80102806:	83 f8 40             	cmp    $0x40,%eax
80102809:	75 e1                	jne    801027ec <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010280b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010280f:	74 11                	je     80102822 <idewait+0x3d>
80102811:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102814:	83 e0 21             	and    $0x21,%eax
80102817:	85 c0                	test   %eax,%eax
80102819:	74 07                	je     80102822 <idewait+0x3d>
    return -1;
8010281b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102820:	eb 05                	jmp    80102827 <idewait+0x42>
  return 0;
80102822:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102827:	c9                   	leave  
80102828:	c3                   	ret    

80102829 <ideinit>:

void
ideinit(void)
{
80102829:	55                   	push   %ebp
8010282a:	89 e5                	mov    %esp,%ebp
8010282c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010282f:	c7 44 24 04 00 97 10 	movl   $0x80109700,0x4(%esp)
80102836:	80 
80102837:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
8010283e:	e8 27 2b 00 00       	call   8010536a <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102843:	a1 00 52 11 80       	mov    0x80115200,%eax
80102848:	48                   	dec    %eax
80102849:	89 44 24 04          	mov    %eax,0x4(%esp)
8010284d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102854:	e8 66 04 00 00       	call   80102cbf <ioapicenable>
  idewait(0);
80102859:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102860:	e8 80 ff ff ff       	call   801027e5 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102865:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010286c:	00 
8010286d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102874:	e8 2b ff ff ff       	call   801027a4 <outb>
  for(i=0; i<1000; i++){
80102879:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102880:	eb 1f                	jmp    801028a1 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102882:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102889:	e8 d6 fe ff ff       	call   80102764 <inb>
8010288e:	84 c0                	test   %al,%al
80102890:	74 0c                	je     8010289e <ideinit+0x75>
      havedisk1 = 1;
80102892:	c7 05 f8 c8 10 80 01 	movl   $0x1,0x8010c8f8
80102899:	00 00 00 
      break;
8010289c:	eb 0c                	jmp    801028aa <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010289e:	ff 45 f4             	incl   -0xc(%ebp)
801028a1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028a8:	7e d8                	jle    80102882 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028aa:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028b1:	00 
801028b2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028b9:	e8 e6 fe ff ff       	call   801027a4 <outb>
}
801028be:	c9                   	leave  
801028bf:	c3                   	ret    

801028c0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028c0:	55                   	push   %ebp
801028c1:	89 e5                	mov    %esp,%ebp
801028c3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801028c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028ca:	75 0c                	jne    801028d8 <idestart+0x18>
    panic("idestart");
801028cc:	c7 04 24 04 97 10 80 	movl   $0x80109704,(%esp)
801028d3:	e8 7c dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801028d8:	8b 45 08             	mov    0x8(%ebp),%eax
801028db:	8b 40 08             	mov    0x8(%eax),%eax
801028de:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
801028e3:	76 0c                	jbe    801028f1 <idestart+0x31>
    panic("incorrect blockno");
801028e5:	c7 04 24 0d 97 10 80 	movl   $0x8010970d,(%esp)
801028ec:	e8 63 dc ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801028f1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028f8:	8b 45 08             	mov    0x8(%ebp),%eax
801028fb:	8b 50 08             	mov    0x8(%eax),%edx
801028fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102901:	0f af c2             	imul   %edx,%eax
80102904:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102907:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010290b:	75 07                	jne    80102914 <idestart+0x54>
8010290d:	b8 20 00 00 00       	mov    $0x20,%eax
80102912:	eb 05                	jmp    80102919 <idestart+0x59>
80102914:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102919:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010291c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102920:	75 07                	jne    80102929 <idestart+0x69>
80102922:	b8 30 00 00 00       	mov    $0x30,%eax
80102927:	eb 05                	jmp    8010292e <idestart+0x6e>
80102929:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010292e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102931:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102935:	7e 0c                	jle    80102943 <idestart+0x83>
80102937:	c7 04 24 04 97 10 80 	movl   $0x80109704,(%esp)
8010293e:	e8 11 dc ff ff       	call   80100554 <panic>

  idewait(0);
80102943:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010294a:	e8 96 fe ff ff       	call   801027e5 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010294f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102956:	00 
80102957:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010295e:	e8 41 fe ff ff       	call   801027a4 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102966:	0f b6 c0             	movzbl %al,%eax
80102969:	89 44 24 04          	mov    %eax,0x4(%esp)
8010296d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102974:	e8 2b fe ff ff       	call   801027a4 <outb>
  outb(0x1f3, sector & 0xff);
80102979:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010297c:	0f b6 c0             	movzbl %al,%eax
8010297f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102983:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010298a:	e8 15 fe ff ff       	call   801027a4 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010298f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102992:	c1 f8 08             	sar    $0x8,%eax
80102995:	0f b6 c0             	movzbl %al,%eax
80102998:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299c:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029a3:	e8 fc fd ff ff       	call   801027a4 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801029a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029ab:	c1 f8 10             	sar    $0x10,%eax
801029ae:	0f b6 c0             	movzbl %al,%eax
801029b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029bc:	e8 e3 fd ff ff       	call   801027a4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	8b 40 04             	mov    0x4(%eax),%eax
801029c7:	83 e0 01             	and    $0x1,%eax
801029ca:	c1 e0 04             	shl    $0x4,%eax
801029cd:	88 c2                	mov    %al,%dl
801029cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029d2:	c1 f8 18             	sar    $0x18,%eax
801029d5:	83 e0 0f             	and    $0xf,%eax
801029d8:	09 d0                	or     %edx,%eax
801029da:	83 c8 e0             	or     $0xffffffe0,%eax
801029dd:	0f b6 c0             	movzbl %al,%eax
801029e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029eb:	e8 b4 fd ff ff       	call   801027a4 <outb>
  if(b->flags & B_DIRTY){
801029f0:	8b 45 08             	mov    0x8(%ebp),%eax
801029f3:	8b 00                	mov    (%eax),%eax
801029f5:	83 e0 04             	and    $0x4,%eax
801029f8:	85 c0                	test   %eax,%eax
801029fa:	74 36                	je     80102a32 <idestart+0x172>
    outb(0x1f7, write_cmd);
801029fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029ff:	0f b6 c0             	movzbl %al,%eax
80102a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a06:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a0d:	e8 92 fd ff ff       	call   801027a4 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102a12:	8b 45 08             	mov    0x8(%ebp),%eax
80102a15:	83 c0 5c             	add    $0x5c,%eax
80102a18:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a1f:	00 
80102a20:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a24:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a2b:	e8 90 fd ff ff       	call   801027c0 <outsl>
80102a30:	eb 16                	jmp    80102a48 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102a32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a35:	0f b6 c0             	movzbl %al,%eax
80102a38:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a3c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a43:	e8 5c fd ff ff       	call   801027a4 <outb>
  }
}
80102a48:	c9                   	leave  
80102a49:	c3                   	ret    

80102a4a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
80102a4d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a50:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102a57:	e8 2f 29 00 00       	call   8010538b <acquire>

  if((b = idequeue) == 0){
80102a5c:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a68:	75 11                	jne    80102a7b <ideintr+0x31>
    release(&idelock);
80102a6a:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102a71:	e8 7f 29 00 00       	call   801053f5 <release>
    return;
80102a76:	e9 90 00 00 00       	jmp    80102b0b <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7e:	8b 40 58             	mov    0x58(%eax),%eax
80102a81:	a3 f4 c8 10 80       	mov    %eax,0x8010c8f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a89:	8b 00                	mov    (%eax),%eax
80102a8b:	83 e0 04             	and    $0x4,%eax
80102a8e:	85 c0                	test   %eax,%eax
80102a90:	75 2e                	jne    80102ac0 <ideintr+0x76>
80102a92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a99:	e8 47 fd ff ff       	call   801027e5 <idewait>
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	78 1e                	js     80102ac0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa5:	83 c0 5c             	add    $0x5c,%eax
80102aa8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102aaf:	00 
80102ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ab4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102abb:	e8 bf fc ff ff       	call   8010277f <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac3:	8b 00                	mov    (%eax),%eax
80102ac5:	83 c8 02             	or     $0x2,%eax
80102ac8:	89 c2                	mov    %eax,%edx
80102aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acd:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad2:	8b 00                	mov    (%eax),%eax
80102ad4:	83 e0 fb             	and    $0xfffffffb,%eax
80102ad7:	89 c2                	mov    %eax,%edx
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	89 04 24             	mov    %eax,(%esp)
80102ae4:	e8 12 23 00 00       	call   80104dfb <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ae9:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102aee:	85 c0                	test   %eax,%eax
80102af0:	74 0d                	je     80102aff <ideintr+0xb5>
    idestart(idequeue);
80102af2:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102af7:	89 04 24             	mov    %eax,(%esp)
80102afa:	e8 c1 fd ff ff       	call   801028c0 <idestart>

  release(&idelock);
80102aff:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102b06:	e8 ea 28 00 00       	call   801053f5 <release>
}
80102b0b:	c9                   	leave  
80102b0c:	c3                   	ret    

80102b0d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b0d:	55                   	push   %ebp
80102b0e:	89 e5                	mov    %esp,%ebp
80102b10:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	83 c0 0c             	add    $0xc,%eax
80102b19:	89 04 24             	mov    %eax,(%esp)
80102b1c:	e8 e2 27 00 00       	call   80105303 <holdingsleep>
80102b21:	85 c0                	test   %eax,%eax
80102b23:	75 0c                	jne    80102b31 <iderw+0x24>
    panic("iderw: buf not locked");
80102b25:	c7 04 24 1f 97 10 80 	movl   $0x8010971f,(%esp)
80102b2c:	e8 23 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b31:	8b 45 08             	mov    0x8(%ebp),%eax
80102b34:	8b 00                	mov    (%eax),%eax
80102b36:	83 e0 06             	and    $0x6,%eax
80102b39:	83 f8 02             	cmp    $0x2,%eax
80102b3c:	75 0c                	jne    80102b4a <iderw+0x3d>
    panic("iderw: nothing to do");
80102b3e:	c7 04 24 35 97 10 80 	movl   $0x80109735,(%esp)
80102b45:	e8 0a da ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4d:	8b 40 04             	mov    0x4(%eax),%eax
80102b50:	85 c0                	test   %eax,%eax
80102b52:	74 15                	je     80102b69 <iderw+0x5c>
80102b54:	a1 f8 c8 10 80       	mov    0x8010c8f8,%eax
80102b59:	85 c0                	test   %eax,%eax
80102b5b:	75 0c                	jne    80102b69 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102b5d:	c7 04 24 4a 97 10 80 	movl   $0x8010974a,(%esp)
80102b64:	e8 eb d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b69:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102b70:	e8 16 28 00 00       	call   8010538b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b75:	8b 45 08             	mov    0x8(%ebp),%eax
80102b78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b7f:	c7 45 f4 f4 c8 10 80 	movl   $0x8010c8f4,-0xc(%ebp)
80102b86:	eb 0b                	jmp    80102b93 <iderw+0x86>
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	8b 00                	mov    (%eax),%eax
80102b8d:	83 c0 58             	add    $0x58,%eax
80102b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b96:	8b 00                	mov    (%eax),%eax
80102b98:	85 c0                	test   %eax,%eax
80102b9a:	75 ec                	jne    80102b88 <iderw+0x7b>
    ;
  *pp = b;
80102b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ba2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ba4:	a1 f4 c8 10 80       	mov    0x8010c8f4,%eax
80102ba9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bac:	75 0d                	jne    80102bbb <iderw+0xae>
    idestart(b);
80102bae:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb1:	89 04 24             	mov    %eax,(%esp)
80102bb4:	e8 07 fd ff ff       	call   801028c0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bb9:	eb 15                	jmp    80102bd0 <iderw+0xc3>
80102bbb:	eb 13                	jmp    80102bd0 <iderw+0xc3>
    sleep(b, &idelock);
80102bbd:	c7 44 24 04 c0 c8 10 	movl   $0x8010c8c0,0x4(%esp)
80102bc4:	80 
80102bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc8:	89 04 24             	mov    %eax,(%esp)
80102bcb:	e8 54 21 00 00       	call   80104d24 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd3:	8b 00                	mov    (%eax),%eax
80102bd5:	83 e0 06             	and    $0x6,%eax
80102bd8:	83 f8 02             	cmp    $0x2,%eax
80102bdb:	75 e0                	jne    80102bbd <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102bdd:	c7 04 24 c0 c8 10 80 	movl   $0x8010c8c0,(%esp)
80102be4:	e8 0c 28 00 00       	call   801053f5 <release>
}
80102be9:	c9                   	leave  
80102bea:	c3                   	ret    
	...

80102bec <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bec:	55                   	push   %ebp
80102bed:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bef:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102bf4:	8b 55 08             	mov    0x8(%ebp),%edx
80102bf7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bf9:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102bfe:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c01:	5d                   	pop    %ebp
80102c02:	c3                   	ret    

80102c03 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c03:	55                   	push   %ebp
80102c04:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c06:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102c0b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c0e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c10:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102c15:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c18:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c1b:	5d                   	pop    %ebp
80102c1c:	c3                   	ret    

80102c1d <ioapicinit>:

void
ioapicinit(void)
{
80102c1d:	55                   	push   %ebp
80102c1e:	89 e5                	mov    %esp,%ebp
80102c20:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c23:	c7 05 34 4b 11 80 00 	movl   $0xfec00000,0x80114b34
80102c2a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c34:	e8 b3 ff ff ff       	call   80102bec <ioapicread>
80102c39:	c1 e8 10             	shr    $0x10,%eax
80102c3c:	25 ff 00 00 00       	and    $0xff,%eax
80102c41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c4b:	e8 9c ff ff ff       	call   80102bec <ioapicread>
80102c50:	c1 e8 18             	shr    $0x18,%eax
80102c53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c56:	a0 60 4c 11 80       	mov    0x80114c60,%al
80102c5b:	0f b6 c0             	movzbl %al,%eax
80102c5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c61:	74 0c                	je     80102c6f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c63:	c7 04 24 68 97 10 80 	movl   $0x80109768,(%esp)
80102c6a:	e8 52 d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c76:	eb 3d                	jmp    80102cb5 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7b:	83 c0 20             	add    $0x20,%eax
80102c7e:	0d 00 00 01 00       	or     $0x10000,%eax
80102c83:	89 c2                	mov    %eax,%edx
80102c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c88:	83 c0 08             	add    $0x8,%eax
80102c8b:	01 c0                	add    %eax,%eax
80102c8d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102c91:	89 04 24             	mov    %eax,(%esp)
80102c94:	e8 6a ff ff ff       	call   80102c03 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9c:	83 c0 08             	add    $0x8,%eax
80102c9f:	01 c0                	add    %eax,%eax
80102ca1:	40                   	inc    %eax
80102ca2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ca9:	00 
80102caa:	89 04 24             	mov    %eax,(%esp)
80102cad:	e8 51 ff ff ff       	call   80102c03 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cb2:	ff 45 f4             	incl   -0xc(%ebp)
80102cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cbb:	7e bb                	jle    80102c78 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cbd:	c9                   	leave  
80102cbe:	c3                   	ret    

80102cbf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc8:	83 c0 20             	add    $0x20,%eax
80102ccb:	89 c2                	mov    %eax,%edx
80102ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd0:	83 c0 08             	add    $0x8,%eax
80102cd3:	01 c0                	add    %eax,%eax
80102cd5:	89 54 24 04          	mov    %edx,0x4(%esp)
80102cd9:	89 04 24             	mov    %eax,(%esp)
80102cdc:	e8 22 ff ff ff       	call   80102c03 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce4:	c1 e0 18             	shl    $0x18,%eax
80102ce7:	8b 55 08             	mov    0x8(%ebp),%edx
80102cea:	83 c2 08             	add    $0x8,%edx
80102ced:	01 d2                	add    %edx,%edx
80102cef:	42                   	inc    %edx
80102cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cf4:	89 14 24             	mov    %edx,(%esp)
80102cf7:	e8 07 ff ff ff       	call   80102c03 <ioapicwrite>
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    
	...

80102d00 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d00:	55                   	push   %ebp
80102d01:	89 e5                	mov    %esp,%ebp
80102d03:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d06:	c7 44 24 04 9a 97 10 	movl   $0x8010979a,0x4(%esp)
80102d0d:	80 
80102d0e:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102d15:	e8 50 26 00 00       	call   8010536a <initlock>
  kmem.use_lock = 0;
80102d1a:	c7 05 74 4b 11 80 00 	movl   $0x0,0x80114b74
80102d21:	00 00 00 
  freerange(vstart, vend);
80102d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d27:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d2e:	89 04 24             	mov    %eax,(%esp)
80102d31:	e8 26 00 00 00       	call   80102d5c <freerange>
}
80102d36:	c9                   	leave  
80102d37:	c3                   	ret    

80102d38 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d38:	55                   	push   %ebp
80102d39:	89 e5                	mov    %esp,%ebp
80102d3b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d41:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d45:	8b 45 08             	mov    0x8(%ebp),%eax
80102d48:	89 04 24             	mov    %eax,(%esp)
80102d4b:	e8 0c 00 00 00       	call   80102d5c <freerange>
  kmem.use_lock = 1;
80102d50:	c7 05 74 4b 11 80 01 	movl   $0x1,0x80114b74
80102d57:	00 00 00 
}
80102d5a:	c9                   	leave  
80102d5b:	c3                   	ret    

80102d5c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d5c:	55                   	push   %ebp
80102d5d:	89 e5                	mov    %esp,%ebp
80102d5f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d62:	8b 45 08             	mov    0x8(%ebp),%eax
80102d65:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d72:	eb 12                	jmp    80102d86 <freerange+0x2a>
    kfree(p);
80102d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d77:	89 04 24             	mov    %eax,(%esp)
80102d7a:	e8 16 00 00 00       	call   80102d95 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d7f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d89:	05 00 10 00 00       	add    $0x1000,%eax
80102d8e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d91:	76 e1                	jbe    80102d74 <freerange+0x18>
    kfree(p);
}
80102d93:	c9                   	leave  
80102d94:	c3                   	ret    

80102d95 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d95:	55                   	push   %ebp
80102d96:	89 e5                	mov    %esp,%ebp
80102d98:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	25 ff 0f 00 00       	and    $0xfff,%eax
80102da3:	85 c0                	test   %eax,%eax
80102da5:	75 18                	jne    80102dbf <kfree+0x2a>
80102da7:	81 7d 08 b0 7c 11 80 	cmpl   $0x80117cb0,0x8(%ebp)
80102dae:	72 0f                	jb     80102dbf <kfree+0x2a>
80102db0:	8b 45 08             	mov    0x8(%ebp),%eax
80102db3:	05 00 00 00 80       	add    $0x80000000,%eax
80102db8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dbd:	76 0c                	jbe    80102dcb <kfree+0x36>
    panic("kfree");
80102dbf:	c7 04 24 9f 97 10 80 	movl   $0x8010979f,(%esp)
80102dc6:	e8 89 d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dcb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dd2:	00 
80102dd3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102dda:	00 
80102ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80102dde:	89 04 24             	mov    %eax,(%esp)
80102de1:	e8 08 28 00 00       	call   801055ee <memset>

  if(kmem.use_lock){
80102de6:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102deb:	85 c0                	test   %eax,%eax
80102ded:	74 48                	je     80102e37 <kfree+0xa2>
    acquire(&kmem.lock);
80102def:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102df6:	e8 90 25 00 00       	call   8010538b <acquire>
    if(ticks > 1){
80102dfb:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102e00:	83 f8 01             	cmp    $0x1,%eax
80102e03:	76 32                	jbe    80102e37 <kfree+0xa2>
      int x = find(myproc()->cont->name);
80102e05:	e8 69 16 00 00       	call   80104473 <myproc>
80102e0a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102e10:	83 c0 18             	add    $0x18,%eax
80102e13:	89 04 24             	mov    %eax,(%esp)
80102e16:	e8 d8 60 00 00       	call   80108ef3 <find>
80102e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102e1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e22:	78 13                	js     80102e37 <kfree+0xa2>
        reduce_curr_mem(1, x);
80102e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e27:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e2b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e32:	e8 d1 63 00 00       	call   80109208 <reduce_curr_mem>
      }
    }
  }
  r = (struct run*)v;
80102e37:	8b 45 08             	mov    0x8(%ebp),%eax
80102e3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102e3d:	8b 15 78 4b 11 80    	mov    0x80114b78,%edx
80102e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e46:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e4b:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if(kmem.use_lock)
80102e50:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	74 0c                	je     80102e65 <kfree+0xd0>
    release(&kmem.lock);
80102e59:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102e60:	e8 90 25 00 00       	call   801053f5 <release>
}
80102e65:	c9                   	leave  
80102e66:	c3                   	ret    

80102e67 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e67:	55                   	push   %ebp
80102e68:	89 e5                	mov    %esp,%ebp
80102e6a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102e6d:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102e72:	85 c0                	test   %eax,%eax
80102e74:	74 0c                	je     80102e82 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e76:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102e7d:	e8 09 25 00 00       	call   8010538b <acquire>
  }
  r = kmem.freelist;
80102e82:	a1 78 4b 11 80       	mov    0x80114b78,%eax
80102e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e8e:	74 0a                	je     80102e9a <kalloc+0x33>
    kmem.freelist = r->next;
80102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e93:	8b 00                	mov    (%eax),%eax
80102e95:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  if((char*)r != 0){
80102e9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e9e:	74 3b                	je     80102edb <kalloc+0x74>
    if(ticks > 0){
80102ea0:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80102ea5:	85 c0                	test   %eax,%eax
80102ea7:	74 32                	je     80102edb <kalloc+0x74>
      int x = find(myproc()->cont->name);
80102ea9:	e8 c5 15 00 00       	call   80104473 <myproc>
80102eae:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102eb4:	83 c0 18             	add    $0x18,%eax
80102eb7:	89 04 24             	mov    %eax,(%esp)
80102eba:	e8 34 60 00 00       	call   80108ef3 <find>
80102ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102ec2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102ec6:	78 13                	js     80102edb <kalloc+0x74>
        set_curr_mem(1, x);
80102ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ecf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ed6:	e8 eb 62 00 00       	call   801091c6 <set_curr_mem>
      }
   }
  }
  if(kmem.use_lock)
80102edb:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80102ee0:	85 c0                	test   %eax,%eax
80102ee2:	74 0c                	je     80102ef0 <kalloc+0x89>
    release(&kmem.lock);
80102ee4:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80102eeb:	e8 05 25 00 00       	call   801053f5 <release>
  return (char*)r;
80102ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ef3:	c9                   	leave  
80102ef4:	c3                   	ret    
80102ef5:	00 00                	add    %al,(%eax)
	...

80102ef8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ef8:	55                   	push   %ebp
80102ef9:	89 e5                	mov    %esp,%ebp
80102efb:	83 ec 14             	sub    $0x14,%esp
80102efe:	8b 45 08             	mov    0x8(%ebp),%eax
80102f01:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f08:	89 c2                	mov    %eax,%edx
80102f0a:	ec                   	in     (%dx),%al
80102f0b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f0e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f11:	c9                   	leave  
80102f12:	c3                   	ret    

80102f13 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102f13:	55                   	push   %ebp
80102f14:	89 e5                	mov    %esp,%ebp
80102f16:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102f19:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f20:	e8 d3 ff ff ff       	call   80102ef8 <inb>
80102f25:	0f b6 c0             	movzbl %al,%eax
80102f28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f2e:	83 e0 01             	and    $0x1,%eax
80102f31:	85 c0                	test   %eax,%eax
80102f33:	75 0a                	jne    80102f3f <kbdgetc+0x2c>
    return -1;
80102f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f3a:	e9 21 01 00 00       	jmp    80103060 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102f3f:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102f46:	e8 ad ff ff ff       	call   80102ef8 <inb>
80102f4b:	0f b6 c0             	movzbl %al,%eax
80102f4e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f51:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f58:	75 17                	jne    80102f71 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f5a:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f5f:	83 c8 40             	or     $0x40,%eax
80102f62:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102f67:	b8 00 00 00 00       	mov    $0x0,%eax
80102f6c:	e9 ef 00 00 00       	jmp    80103060 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f74:	25 80 00 00 00       	and    $0x80,%eax
80102f79:	85 c0                	test   %eax,%eax
80102f7b:	74 44                	je     80102fc1 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f7d:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102f82:	83 e0 40             	and    $0x40,%eax
80102f85:	85 c0                	test   %eax,%eax
80102f87:	75 08                	jne    80102f91 <kbdgetc+0x7e>
80102f89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f8c:	83 e0 7f             	and    $0x7f,%eax
80102f8f:	eb 03                	jmp    80102f94 <kbdgetc+0x81>
80102f91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f94:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f9a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f9f:	8a 00                	mov    (%eax),%al
80102fa1:	83 c8 40             	or     $0x40,%eax
80102fa4:	0f b6 c0             	movzbl %al,%eax
80102fa7:	f7 d0                	not    %eax
80102fa9:	89 c2                	mov    %eax,%edx
80102fab:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102fb0:	21 d0                	and    %edx,%eax
80102fb2:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
    return 0;
80102fb7:	b8 00 00 00 00       	mov    $0x0,%eax
80102fbc:	e9 9f 00 00 00       	jmp    80103060 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102fc1:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102fc6:	83 e0 40             	and    $0x40,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	74 14                	je     80102fe1 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102fcd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fd4:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102fd9:	83 e0 bf             	and    $0xffffffbf,%eax
80102fdc:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  }

  shift |= shiftcode[data];
80102fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fe4:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102fe9:	8a 00                	mov    (%eax),%al
80102feb:	0f b6 d0             	movzbl %al,%edx
80102fee:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80102ff3:	09 d0                	or     %edx,%eax
80102ff5:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  shift ^= togglecode[data];
80102ffa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ffd:	05 20 a1 10 80       	add    $0x8010a120,%eax
80103002:	8a 00                	mov    (%eax),%al
80103004:	0f b6 d0             	movzbl %al,%edx
80103007:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
8010300c:	31 d0                	xor    %edx,%eax
8010300e:	a3 fc c8 10 80       	mov    %eax,0x8010c8fc
  c = charcode[shift & (CTL | SHIFT)][data];
80103013:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80103018:	83 e0 03             	and    $0x3,%eax
8010301b:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80103022:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103025:	01 d0                	add    %edx,%eax
80103027:	8a 00                	mov    (%eax),%al
80103029:	0f b6 c0             	movzbl %al,%eax
8010302c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010302f:	a1 fc c8 10 80       	mov    0x8010c8fc,%eax
80103034:	83 e0 08             	and    $0x8,%eax
80103037:	85 c0                	test   %eax,%eax
80103039:	74 22                	je     8010305d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010303b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010303f:	76 0c                	jbe    8010304d <kbdgetc+0x13a>
80103041:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103045:	77 06                	ja     8010304d <kbdgetc+0x13a>
      c += 'A' - 'a';
80103047:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010304b:	eb 10                	jmp    8010305d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010304d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103051:	76 0a                	jbe    8010305d <kbdgetc+0x14a>
80103053:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103057:	77 04                	ja     8010305d <kbdgetc+0x14a>
      c += 'a' - 'A';
80103059:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010305d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103060:	c9                   	leave  
80103061:	c3                   	ret    

80103062 <kbdintr>:

void
kbdintr(void)
{
80103062:	55                   	push   %ebp
80103063:	89 e5                	mov    %esp,%ebp
80103065:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103068:	c7 04 24 13 2f 10 80 	movl   $0x80102f13,(%esp)
8010306f:	e8 81 d7 ff ff       	call   801007f5 <consoleintr>
}
80103074:	c9                   	leave  
80103075:	c3                   	ret    
	...

80103078 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103078:	55                   	push   %ebp
80103079:	89 e5                	mov    %esp,%ebp
8010307b:	83 ec 14             	sub    $0x14,%esp
8010307e:	8b 45 08             	mov    0x8(%ebp),%eax
80103081:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103085:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103088:	89 c2                	mov    %eax,%edx
8010308a:	ec                   	in     (%dx),%al
8010308b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010308e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103091:	c9                   	leave  
80103092:	c3                   	ret    

80103093 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103093:	55                   	push   %ebp
80103094:	89 e5                	mov    %esp,%ebp
80103096:	83 ec 08             	sub    $0x8,%esp
80103099:	8b 45 08             	mov    0x8(%ebp),%eax
8010309c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010309f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801030a3:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801030a6:	8a 45 f8             	mov    -0x8(%ebp),%al
801030a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801030ac:	ee                   	out    %al,(%dx)
}
801030ad:	c9                   	leave  
801030ae:	c3                   	ret    

801030af <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801030af:	55                   	push   %ebp
801030b0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801030b2:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030b7:	8b 55 08             	mov    0x8(%ebp),%edx
801030ba:	c1 e2 02             	shl    $0x2,%edx
801030bd:	01 c2                	add    %eax,%edx
801030bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801030c2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801030c4:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030c9:	83 c0 20             	add    $0x20,%eax
801030cc:	8b 00                	mov    (%eax),%eax
}
801030ce:	5d                   	pop    %ebp
801030cf:	c3                   	ret    

801030d0 <lapicinit>:

void
lapicinit(void)
{
801030d0:	55                   	push   %ebp
801030d1:	89 e5                	mov    %esp,%ebp
801030d3:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
801030d6:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801030db:	85 c0                	test   %eax,%eax
801030dd:	75 05                	jne    801030e4 <lapicinit+0x14>
    return;
801030df:	e9 43 01 00 00       	jmp    80103227 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030e4:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801030eb:	00 
801030ec:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030f3:	e8 b7 ff ff ff       	call   801030af <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030f8:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030ff:	00 
80103100:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103107:	e8 a3 ff ff ff       	call   801030af <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010310c:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103113:	00 
80103114:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010311b:	e8 8f ff ff ff       	call   801030af <lapicw>
  lapicw(TICR, 10000000);
80103120:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103127:	00 
80103128:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010312f:	e8 7b ff ff ff       	call   801030af <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103134:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010313b:	00 
8010313c:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103143:	e8 67 ff ff ff       	call   801030af <lapicw>
  lapicw(LINT1, MASKED);
80103148:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010314f:	00 
80103150:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103157:	e8 53 ff ff ff       	call   801030af <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010315c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103161:	83 c0 30             	add    $0x30,%eax
80103164:	8b 00                	mov    (%eax),%eax
80103166:	c1 e8 10             	shr    $0x10,%eax
80103169:	0f b6 c0             	movzbl %al,%eax
8010316c:	83 f8 03             	cmp    $0x3,%eax
8010316f:	76 14                	jbe    80103185 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103171:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103178:	00 
80103179:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103180:	e8 2a ff ff ff       	call   801030af <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103185:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010318c:	00 
8010318d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103194:	e8 16 ff ff ff       	call   801030af <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103199:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031a0:	00 
801031a1:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801031a8:	e8 02 ff ff ff       	call   801030af <lapicw>
  lapicw(ESR, 0);
801031ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031b4:	00 
801031b5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801031bc:	e8 ee fe ff ff       	call   801030af <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801031c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031c8:	00 
801031c9:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801031d0:	e8 da fe ff ff       	call   801030af <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801031d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031dc:	00 
801031dd:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031e4:	e8 c6 fe ff ff       	call   801030af <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031e9:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031f0:	00 
801031f1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031f8:	e8 b2 fe ff ff       	call   801030af <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031fd:	90                   	nop
801031fe:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103203:	05 00 03 00 00       	add    $0x300,%eax
80103208:	8b 00                	mov    (%eax),%eax
8010320a:	25 00 10 00 00       	and    $0x1000,%eax
8010320f:	85 c0                	test   %eax,%eax
80103211:	75 eb                	jne    801031fe <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103213:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010321a:	00 
8010321b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103222:	e8 88 fe ff ff       	call   801030af <lapicw>
}
80103227:	c9                   	leave  
80103228:	c3                   	ret    

80103229 <lapicid>:

int
lapicid(void)
{
80103229:	55                   	push   %ebp
8010322a:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010322c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103231:	85 c0                	test   %eax,%eax
80103233:	75 07                	jne    8010323c <lapicid+0x13>
    return 0;
80103235:	b8 00 00 00 00       	mov    $0x0,%eax
8010323a:	eb 0d                	jmp    80103249 <lapicid+0x20>
  return lapic[ID] >> 24;
8010323c:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103241:	83 c0 20             	add    $0x20,%eax
80103244:	8b 00                	mov    (%eax),%eax
80103246:	c1 e8 18             	shr    $0x18,%eax
}
80103249:	5d                   	pop    %ebp
8010324a:	c3                   	ret    

8010324b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010324b:	55                   	push   %ebp
8010324c:	89 e5                	mov    %esp,%ebp
8010324e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103251:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103256:	85 c0                	test   %eax,%eax
80103258:	74 14                	je     8010326e <lapiceoi+0x23>
    lapicw(EOI, 0);
8010325a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103261:	00 
80103262:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103269:	e8 41 fe ff ff       	call   801030af <lapicw>
}
8010326e:	c9                   	leave  
8010326f:	c3                   	ret    

80103270 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103270:	55                   	push   %ebp
80103271:	89 e5                	mov    %esp,%ebp
}
80103273:	5d                   	pop    %ebp
80103274:	c3                   	ret    

80103275 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 1c             	sub    $0x1c,%esp
8010327b:	8b 45 08             	mov    0x8(%ebp),%eax
8010327e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103281:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103288:	00 
80103289:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103290:	e8 fe fd ff ff       	call   80103093 <outb>
  outb(CMOS_PORT+1, 0x0A);
80103295:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010329c:	00 
8010329d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032a4:	e8 ea fd ff ff       	call   80103093 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801032a9:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032b3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032bb:	8d 50 02             	lea    0x2(%eax),%edx
801032be:	8b 45 0c             	mov    0xc(%ebp),%eax
801032c1:	c1 e8 04             	shr    $0x4,%eax
801032c4:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032c7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032cb:	c1 e0 18             	shl    $0x18,%eax
801032ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032d9:	e8 d1 fd ff ff       	call   801030af <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032de:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032e5:	00 
801032e6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032ed:	e8 bd fd ff ff       	call   801030af <lapicw>
  microdelay(200);
801032f2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032f9:	e8 72 ff ff ff       	call   80103270 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032fe:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103305:	00 
80103306:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010330d:	e8 9d fd ff ff       	call   801030af <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103312:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103319:	e8 52 ff ff ff       	call   80103270 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010331e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103325:	eb 3f                	jmp    80103366 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103327:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010332b:	c1 e0 18             	shl    $0x18,%eax
8010332e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103332:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103339:	e8 71 fd ff ff       	call   801030af <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010333e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103341:	c1 e8 0c             	shr    $0xc,%eax
80103344:	80 cc 06             	or     $0x6,%ah
80103347:	89 44 24 04          	mov    %eax,0x4(%esp)
8010334b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103352:	e8 58 fd ff ff       	call   801030af <lapicw>
    microdelay(200);
80103357:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010335e:	e8 0d ff ff ff       	call   80103270 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103363:	ff 45 fc             	incl   -0x4(%ebp)
80103366:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010336a:	7e bb                	jle    80103327 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010336c:	c9                   	leave  
8010336d:	c3                   	ret    

8010336e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010336e:	55                   	push   %ebp
8010336f:	89 e5                	mov    %esp,%ebp
80103371:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103374:	8b 45 08             	mov    0x8(%ebp),%eax
80103377:	0f b6 c0             	movzbl %al,%eax
8010337a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010337e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103385:	e8 09 fd ff ff       	call   80103093 <outb>
  microdelay(200);
8010338a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103391:	e8 da fe ff ff       	call   80103270 <microdelay>

  return inb(CMOS_RETURN);
80103396:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010339d:	e8 d6 fc ff ff       	call   80103078 <inb>
801033a2:	0f b6 c0             	movzbl %al,%eax
}
801033a5:	c9                   	leave  
801033a6:	c3                   	ret    

801033a7 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801033a7:	55                   	push   %ebp
801033a8:	89 e5                	mov    %esp,%ebp
801033aa:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801033ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801033b4:	e8 b5 ff ff ff       	call   8010336e <cmos_read>
801033b9:	8b 55 08             	mov    0x8(%ebp),%edx
801033bc:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801033be:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801033c5:	e8 a4 ff ff ff       	call   8010336e <cmos_read>
801033ca:	8b 55 08             	mov    0x8(%ebp),%edx
801033cd:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801033d0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801033d7:	e8 92 ff ff ff       	call   8010336e <cmos_read>
801033dc:	8b 55 08             	mov    0x8(%ebp),%edx
801033df:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801033e2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801033e9:	e8 80 ff ff ff       	call   8010336e <cmos_read>
801033ee:	8b 55 08             	mov    0x8(%ebp),%edx
801033f1:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801033f4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801033fb:	e8 6e ff ff ff       	call   8010336e <cmos_read>
80103400:	8b 55 08             	mov    0x8(%ebp),%edx
80103403:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103406:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010340d:	e8 5c ff ff ff       	call   8010336e <cmos_read>
80103412:	8b 55 08             	mov    0x8(%ebp),%edx
80103415:	89 42 14             	mov    %eax,0x14(%edx)
}
80103418:	c9                   	leave  
80103419:	c3                   	ret    

8010341a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010341a:	55                   	push   %ebp
8010341b:	89 e5                	mov    %esp,%ebp
8010341d:	57                   	push   %edi
8010341e:	56                   	push   %esi
8010341f:	53                   	push   %ebx
80103420:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103423:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010342a:	e8 3f ff ff ff       	call   8010336e <cmos_read>
8010342f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103432:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103435:	83 e0 04             	and    $0x4,%eax
80103438:	85 c0                	test   %eax,%eax
8010343a:	0f 94 c0             	sete   %al
8010343d:	0f b6 c0             	movzbl %al,%eax
80103440:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103443:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103446:	89 04 24             	mov    %eax,(%esp)
80103449:	e8 59 ff ff ff       	call   801033a7 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010344e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103455:	e8 14 ff ff ff       	call   8010336e <cmos_read>
8010345a:	25 80 00 00 00       	and    $0x80,%eax
8010345f:	85 c0                	test   %eax,%eax
80103461:	74 02                	je     80103465 <cmostime+0x4b>
        continue;
80103463:	eb 36                	jmp    8010349b <cmostime+0x81>
    fill_rtcdate(&t2);
80103465:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103468:	89 04 24             	mov    %eax,(%esp)
8010346b:	e8 37 ff ff ff       	call   801033a7 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103470:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103477:	00 
80103478:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010347b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010347f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103482:	89 04 24             	mov    %eax,(%esp)
80103485:	e8 db 21 00 00       	call   80105665 <memcmp>
8010348a:	85 c0                	test   %eax,%eax
8010348c:	75 0d                	jne    8010349b <cmostime+0x81>
      break;
8010348e:	90                   	nop
  }

  // convert
  if(bcd) {
8010348f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103493:	0f 84 ac 00 00 00    	je     80103545 <cmostime+0x12b>
80103499:	eb 02                	jmp    8010349d <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010349b:	eb a6                	jmp    80103443 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010349d:	8b 45 c8             	mov    -0x38(%ebp),%eax
801034a0:	c1 e8 04             	shr    $0x4,%eax
801034a3:	89 c2                	mov    %eax,%edx
801034a5:	89 d0                	mov    %edx,%eax
801034a7:	c1 e0 02             	shl    $0x2,%eax
801034aa:	01 d0                	add    %edx,%eax
801034ac:	01 c0                	add    %eax,%eax
801034ae:	8b 55 c8             	mov    -0x38(%ebp),%edx
801034b1:	83 e2 0f             	and    $0xf,%edx
801034b4:	01 d0                	add    %edx,%eax
801034b6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801034b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801034bc:	c1 e8 04             	shr    $0x4,%eax
801034bf:	89 c2                	mov    %eax,%edx
801034c1:	89 d0                	mov    %edx,%eax
801034c3:	c1 e0 02             	shl    $0x2,%eax
801034c6:	01 d0                	add    %edx,%eax
801034c8:	01 c0                	add    %eax,%eax
801034ca:	8b 55 cc             	mov    -0x34(%ebp),%edx
801034cd:	83 e2 0f             	and    $0xf,%edx
801034d0:	01 d0                	add    %edx,%eax
801034d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
801034d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801034d8:	c1 e8 04             	shr    $0x4,%eax
801034db:	89 c2                	mov    %eax,%edx
801034dd:	89 d0                	mov    %edx,%eax
801034df:	c1 e0 02             	shl    $0x2,%eax
801034e2:	01 d0                	add    %edx,%eax
801034e4:	01 c0                	add    %eax,%eax
801034e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
801034e9:	83 e2 0f             	and    $0xf,%edx
801034ec:	01 d0                	add    %edx,%eax
801034ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801034f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801034f4:	c1 e8 04             	shr    $0x4,%eax
801034f7:	89 c2                	mov    %eax,%edx
801034f9:	89 d0                	mov    %edx,%eax
801034fb:	c1 e0 02             	shl    $0x2,%eax
801034fe:	01 d0                	add    %edx,%eax
80103500:	01 c0                	add    %eax,%eax
80103502:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103505:	83 e2 0f             	and    $0xf,%edx
80103508:	01 d0                	add    %edx,%eax
8010350a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
8010350d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103510:	c1 e8 04             	shr    $0x4,%eax
80103513:	89 c2                	mov    %eax,%edx
80103515:	89 d0                	mov    %edx,%eax
80103517:	c1 e0 02             	shl    $0x2,%eax
8010351a:	01 d0                	add    %edx,%eax
8010351c:	01 c0                	add    %eax,%eax
8010351e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103521:	83 e2 0f             	and    $0xf,%edx
80103524:	01 d0                	add    %edx,%eax
80103526:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103529:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010352c:	c1 e8 04             	shr    $0x4,%eax
8010352f:	89 c2                	mov    %eax,%edx
80103531:	89 d0                	mov    %edx,%eax
80103533:	c1 e0 02             	shl    $0x2,%eax
80103536:	01 d0                	add    %edx,%eax
80103538:	01 c0                	add    %eax,%eax
8010353a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010353d:	83 e2 0f             	and    $0xf,%edx
80103540:	01 d0                	add    %edx,%eax
80103542:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103545:	8b 45 08             	mov    0x8(%ebp),%eax
80103548:	89 c2                	mov    %eax,%edx
8010354a:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010354d:	b8 06 00 00 00       	mov    $0x6,%eax
80103552:	89 d7                	mov    %edx,%edi
80103554:	89 de                	mov    %ebx,%esi
80103556:	89 c1                	mov    %eax,%ecx
80103558:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010355a:	8b 45 08             	mov    0x8(%ebp),%eax
8010355d:	8b 40 14             	mov    0x14(%eax),%eax
80103560:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103566:	8b 45 08             	mov    0x8(%ebp),%eax
80103569:	89 50 14             	mov    %edx,0x14(%eax)
}
8010356c:	83 c4 5c             	add    $0x5c,%esp
8010356f:	5b                   	pop    %ebx
80103570:	5e                   	pop    %esi
80103571:	5f                   	pop    %edi
80103572:	5d                   	pop    %ebp
80103573:	c3                   	ret    

80103574 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103574:	55                   	push   %ebp
80103575:	89 e5                	mov    %esp,%ebp
80103577:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010357a:	c7 44 24 04 a5 97 10 	movl   $0x801097a5,0x4(%esp)
80103581:	80 
80103582:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103589:	e8 dc 1d 00 00       	call   8010536a <initlock>
  readsb(dev, &sb);
8010358e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103591:	89 44 24 04          	mov    %eax,0x4(%esp)
80103595:	8b 45 08             	mov    0x8(%ebp),%eax
80103598:	89 04 24             	mov    %eax,(%esp)
8010359b:	e8 20 df ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
801035a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a3:	a3 b4 4b 11 80       	mov    %eax,0x80114bb4
  log.size = sb.nlog;
801035a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801035ab:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
  log.dev = dev;
801035b0:	8b 45 08             	mov    0x8(%ebp),%eax
801035b3:	a3 c4 4b 11 80       	mov    %eax,0x80114bc4
  recover_from_log();
801035b8:	e8 95 01 00 00       	call   80103752 <recover_from_log>
}
801035bd:	c9                   	leave  
801035be:	c3                   	ret    

801035bf <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801035bf:	55                   	push   %ebp
801035c0:	89 e5                	mov    %esp,%ebp
801035c2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035cc:	e9 89 00 00 00       	jmp    8010365a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801035d1:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
801035d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035da:	01 d0                	add    %edx,%eax
801035dc:	40                   	inc    %eax
801035dd:	89 c2                	mov    %eax,%edx
801035df:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801035e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801035e8:	89 04 24             	mov    %eax,(%esp)
801035eb:	e8 c5 cb ff ff       	call   801001b5 <bread>
801035f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801035f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f6:	83 c0 10             	add    $0x10,%eax
801035f9:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
80103600:	89 c2                	mov    %eax,%edx
80103602:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
80103607:	89 54 24 04          	mov    %edx,0x4(%esp)
8010360b:	89 04 24             	mov    %eax,(%esp)
8010360e:	e8 a2 cb ff ff       	call   801001b5 <bread>
80103613:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103619:	8d 50 5c             	lea    0x5c(%eax),%edx
8010361c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010361f:	83 c0 5c             	add    $0x5c,%eax
80103622:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103629:	00 
8010362a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010362e:	89 04 24             	mov    %eax,(%esp)
80103631:	e8 81 20 00 00       	call   801056b7 <memmove>
    bwrite(dbuf);  // write dst to disk
80103636:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103639:	89 04 24             	mov    %eax,(%esp)
8010363c:	e8 ab cb ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103644:	89 04 24             	mov    %eax,(%esp)
80103647:	e8 e0 cb ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010364c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010364f:	89 04 24             	mov    %eax,(%esp)
80103652:	e8 d5 cb ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103657:	ff 45 f4             	incl   -0xc(%ebp)
8010365a:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010365f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103662:	0f 8f 69 ff ff ff    	jg     801035d1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103668:	c9                   	leave  
80103669:	c3                   	ret    

8010366a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010366a:	55                   	push   %ebp
8010366b:	89 e5                	mov    %esp,%ebp
8010366d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103670:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
80103675:	89 c2                	mov    %eax,%edx
80103677:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
8010367c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103680:	89 04 24             	mov    %eax,(%esp)
80103683:	e8 2d cb ff ff       	call   801001b5 <bread>
80103688:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010368b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010368e:	83 c0 5c             	add    $0x5c,%eax
80103691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103694:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103697:	8b 00                	mov    (%eax),%eax
80103699:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  for (i = 0; i < log.lh.n; i++) {
8010369e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036a5:	eb 1a                	jmp    801036c1 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801036a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036ad:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801036b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036b4:	83 c2 10             	add    $0x10,%edx
801036b7:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801036be:	ff 45 f4             	incl   -0xc(%ebp)
801036c1:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801036c6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c9:	7f dc                	jg     801036a7 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801036cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ce:	89 04 24             	mov    %eax,(%esp)
801036d1:	e8 56 cb ff ff       	call   8010022c <brelse>
}
801036d6:	c9                   	leave  
801036d7:	c3                   	ret    

801036d8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801036d8:	55                   	push   %ebp
801036d9:	89 e5                	mov    %esp,%ebp
801036db:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801036de:	a1 b4 4b 11 80       	mov    0x80114bb4,%eax
801036e3:	89 c2                	mov    %eax,%edx
801036e5:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801036ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801036ee:	89 04 24             	mov    %eax,(%esp)
801036f1:	e8 bf ca ff ff       	call   801001b5 <bread>
801036f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036fc:	83 c0 5c             	add    $0x5c,%eax
801036ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103702:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
80103708:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010370b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010370d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103714:	eb 1a                	jmp    80103730 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103719:	83 c0 10             	add    $0x10,%eax
8010371c:	8b 0c 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%ecx
80103723:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103726:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103729:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010372d:	ff 45 f4             	incl   -0xc(%ebp)
80103730:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103735:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103738:	7f dc                	jg     80103716 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010373a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010373d:	89 04 24             	mov    %eax,(%esp)
80103740:	e8 a7 ca ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103748:	89 04 24             	mov    %eax,(%esp)
8010374b:	e8 dc ca ff ff       	call   8010022c <brelse>
}
80103750:	c9                   	leave  
80103751:	c3                   	ret    

80103752 <recover_from_log>:

static void
recover_from_log(void)
{
80103752:	55                   	push   %ebp
80103753:	89 e5                	mov    %esp,%ebp
80103755:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103758:	e8 0d ff ff ff       	call   8010366a <read_head>
  install_trans(); // if committed, copy from log to disk
8010375d:	e8 5d fe ff ff       	call   801035bf <install_trans>
  log.lh.n = 0;
80103762:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
80103769:	00 00 00 
  write_head(); // clear the log
8010376c:	e8 67 ff ff ff       	call   801036d8 <write_head>
}
80103771:	c9                   	leave  
80103772:	c3                   	ret    

80103773 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103773:	55                   	push   %ebp
80103774:	89 e5                	mov    %esp,%ebp
80103776:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103779:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103780:	e8 06 1c 00 00       	call   8010538b <acquire>
  while(1){
    if(log.committing){
80103785:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
8010378a:	85 c0                	test   %eax,%eax
8010378c:	74 16                	je     801037a4 <begin_op+0x31>
      sleep(&log, &log.lock);
8010378e:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
80103795:	80 
80103796:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010379d:	e8 82 15 00 00       	call   80104d24 <sleep>
801037a2:	eb 4d                	jmp    801037f1 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801037a4:	8b 15 c8 4b 11 80    	mov    0x80114bc8,%edx
801037aa:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801037af:	8d 48 01             	lea    0x1(%eax),%ecx
801037b2:	89 c8                	mov    %ecx,%eax
801037b4:	c1 e0 02             	shl    $0x2,%eax
801037b7:	01 c8                	add    %ecx,%eax
801037b9:	01 c0                	add    %eax,%eax
801037bb:	01 d0                	add    %edx,%eax
801037bd:	83 f8 1e             	cmp    $0x1e,%eax
801037c0:	7e 16                	jle    801037d8 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801037c2:	c7 44 24 04 80 4b 11 	movl   $0x80114b80,0x4(%esp)
801037c9:	80 
801037ca:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037d1:	e8 4e 15 00 00       	call   80104d24 <sleep>
801037d6:	eb 19                	jmp    801037f1 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
801037d8:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801037dd:	40                   	inc    %eax
801037de:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
      release(&log.lock);
801037e3:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801037ea:	e8 06 1c 00 00       	call   801053f5 <release>
      break;
801037ef:	eb 02                	jmp    801037f3 <begin_op+0x80>
    }
  }
801037f1:	eb 92                	jmp    80103785 <begin_op+0x12>
}
801037f3:	c9                   	leave  
801037f4:	c3                   	ret    

801037f5 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037f5:	55                   	push   %ebp
801037f6:	89 e5                	mov    %esp,%ebp
801037f8:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801037fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103802:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103809:	e8 7d 1b 00 00       	call   8010538b <acquire>
  log.outstanding -= 1;
8010380e:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103813:	48                   	dec    %eax
80103814:	a3 bc 4b 11 80       	mov    %eax,0x80114bbc
  if(log.committing)
80103819:	a1 c0 4b 11 80       	mov    0x80114bc0,%eax
8010381e:	85 c0                	test   %eax,%eax
80103820:	74 0c                	je     8010382e <end_op+0x39>
    panic("log.committing");
80103822:	c7 04 24 a9 97 10 80 	movl   $0x801097a9,(%esp)
80103829:	e8 26 cd ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010382e:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
80103833:	85 c0                	test   %eax,%eax
80103835:	75 13                	jne    8010384a <end_op+0x55>
    do_commit = 1;
80103837:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010383e:	c7 05 c0 4b 11 80 01 	movl   $0x1,0x80114bc0
80103845:	00 00 00 
80103848:	eb 0c                	jmp    80103856 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010384a:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103851:	e8 a5 15 00 00       	call   80104dfb <wakeup>
  }
  release(&log.lock);
80103856:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010385d:	e8 93 1b 00 00       	call   801053f5 <release>

  if(do_commit){
80103862:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103866:	74 33                	je     8010389b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103868:	e8 db 00 00 00       	call   80103948 <commit>
    acquire(&log.lock);
8010386d:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103874:	e8 12 1b 00 00       	call   8010538b <acquire>
    log.committing = 0;
80103879:	c7 05 c0 4b 11 80 00 	movl   $0x0,0x80114bc0
80103880:	00 00 00 
    wakeup(&log);
80103883:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
8010388a:	e8 6c 15 00 00       	call   80104dfb <wakeup>
    release(&log.lock);
8010388f:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103896:	e8 5a 1b 00 00       	call   801053f5 <release>
  }
}
8010389b:	c9                   	leave  
8010389c:	c3                   	ret    

8010389d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010389d:	55                   	push   %ebp
8010389e:	89 e5                	mov    %esp,%ebp
801038a0:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038aa:	e9 89 00 00 00       	jmp    80103938 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038af:	8b 15 b4 4b 11 80    	mov    0x80114bb4,%edx
801038b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b8:	01 d0                	add    %edx,%eax
801038ba:	40                   	inc    %eax
801038bb:	89 c2                	mov    %eax,%edx
801038bd:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801038c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801038c6:	89 04 24             	mov    %eax,(%esp)
801038c9:	e8 e7 c8 ff ff       	call   801001b5 <bread>
801038ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d4:	83 c0 10             	add    $0x10,%eax
801038d7:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
801038de:	89 c2                	mov    %eax,%edx
801038e0:	a1 c4 4b 11 80       	mov    0x80114bc4,%eax
801038e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801038e9:	89 04 24             	mov    %eax,(%esp)
801038ec:	e8 c4 c8 ff ff       	call   801001b5 <bread>
801038f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038f7:	8d 50 5c             	lea    0x5c(%eax),%edx
801038fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fd:	83 c0 5c             	add    $0x5c,%eax
80103900:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103907:	00 
80103908:	89 54 24 04          	mov    %edx,0x4(%esp)
8010390c:	89 04 24             	mov    %eax,(%esp)
8010390f:	e8 a3 1d 00 00       	call   801056b7 <memmove>
    bwrite(to);  // write the log
80103914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103917:	89 04 24             	mov    %eax,(%esp)
8010391a:	e8 cd c8 ff ff       	call   801001ec <bwrite>
    brelse(from);
8010391f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103922:	89 04 24             	mov    %eax,(%esp)
80103925:	e8 02 c9 ff ff       	call   8010022c <brelse>
    brelse(to);
8010392a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010392d:	89 04 24             	mov    %eax,(%esp)
80103930:	e8 f7 c8 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103935:	ff 45 f4             	incl   -0xc(%ebp)
80103938:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010393d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103940:	0f 8f 69 ff ff ff    	jg     801038af <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103946:	c9                   	leave  
80103947:	c3                   	ret    

80103948 <commit>:

static void
commit()
{
80103948:	55                   	push   %ebp
80103949:	89 e5                	mov    %esp,%ebp
8010394b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010394e:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103953:	85 c0                	test   %eax,%eax
80103955:	7e 1e                	jle    80103975 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103957:	e8 41 ff ff ff       	call   8010389d <write_log>
    write_head();    // Write header to disk -- the real commit
8010395c:	e8 77 fd ff ff       	call   801036d8 <write_head>
    install_trans(); // Now install writes to home locations
80103961:	e8 59 fc ff ff       	call   801035bf <install_trans>
    log.lh.n = 0;
80103966:	c7 05 c8 4b 11 80 00 	movl   $0x0,0x80114bc8
8010396d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103970:	e8 63 fd ff ff       	call   801036d8 <write_head>
  }
}
80103975:	c9                   	leave  
80103976:	c3                   	ret    

80103977 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103977:	55                   	push   %ebp
80103978:	89 e5                	mov    %esp,%ebp
8010397a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010397d:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103982:	83 f8 1d             	cmp    $0x1d,%eax
80103985:	7f 10                	jg     80103997 <log_write+0x20>
80103987:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
8010398c:	8b 15 b8 4b 11 80    	mov    0x80114bb8,%edx
80103992:	4a                   	dec    %edx
80103993:	39 d0                	cmp    %edx,%eax
80103995:	7c 0c                	jl     801039a3 <log_write+0x2c>
    panic("too big a transaction");
80103997:	c7 04 24 b8 97 10 80 	movl   $0x801097b8,(%esp)
8010399e:	e8 b1 cb ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801039a3:	a1 bc 4b 11 80       	mov    0x80114bbc,%eax
801039a8:	85 c0                	test   %eax,%eax
801039aa:	7f 0c                	jg     801039b8 <log_write+0x41>
    panic("log_write outside of trans");
801039ac:	c7 04 24 ce 97 10 80 	movl   $0x801097ce,(%esp)
801039b3:	e8 9c cb ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801039b8:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
801039bf:	e8 c7 19 00 00       	call   8010538b <acquire>
  for (i = 0; i < log.lh.n; i++) {
801039c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039cb:	eb 1e                	jmp    801039eb <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d0:	83 c0 10             	add    $0x10,%eax
801039d3:	8b 04 85 8c 4b 11 80 	mov    -0x7feeb474(,%eax,4),%eax
801039da:	89 c2                	mov    %eax,%edx
801039dc:	8b 45 08             	mov    0x8(%ebp),%eax
801039df:	8b 40 08             	mov    0x8(%eax),%eax
801039e2:	39 c2                	cmp    %eax,%edx
801039e4:	75 02                	jne    801039e8 <log_write+0x71>
      break;
801039e6:	eb 0d                	jmp    801039f5 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801039e8:	ff 45 f4             	incl   -0xc(%ebp)
801039eb:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
801039f0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f3:	7f d8                	jg     801039cd <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801039f5:	8b 45 08             	mov    0x8(%ebp),%eax
801039f8:	8b 40 08             	mov    0x8(%eax),%eax
801039fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801039fe:	83 c2 10             	add    $0x10,%edx
80103a01:	89 04 95 8c 4b 11 80 	mov    %eax,-0x7feeb474(,%edx,4)
  if (i == log.lh.n)
80103a08:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103a0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a10:	75 0b                	jne    80103a1d <log_write+0xa6>
    log.lh.n++;
80103a12:	a1 c8 4b 11 80       	mov    0x80114bc8,%eax
80103a17:	40                   	inc    %eax
80103a18:	a3 c8 4b 11 80       	mov    %eax,0x80114bc8
  b->flags |= B_DIRTY; // prevent eviction
80103a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a20:	8b 00                	mov    (%eax),%eax
80103a22:	83 c8 04             	or     $0x4,%eax
80103a25:	89 c2                	mov    %eax,%edx
80103a27:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a2c:	c7 04 24 80 4b 11 80 	movl   $0x80114b80,(%esp)
80103a33:	e8 bd 19 00 00       	call   801053f5 <release>
}
80103a38:	c9                   	leave  
80103a39:	c3                   	ret    
	...

80103a3c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a3c:	55                   	push   %ebp
80103a3d:	89 e5                	mov    %esp,%ebp
80103a3f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a42:	8b 55 08             	mov    0x8(%ebp),%edx
80103a45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a4b:	f0 87 02             	lock xchg %eax,(%edx)
80103a4e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a54:	c9                   	leave  
80103a55:	c3                   	ret    

80103a56 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a56:	55                   	push   %ebp
80103a57:	89 e5                	mov    %esp,%ebp
80103a59:	83 e4 f0             	and    $0xfffffff0,%esp
80103a5c:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a5f:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103a66:	80 
80103a67:	c7 04 24 b0 7c 11 80 	movl   $0x80117cb0,(%esp)
80103a6e:	e8 8d f2 ff ff       	call   80102d00 <kinit1>
  kvmalloc();      // kernel page table
80103a73:	e8 eb 4a 00 00       	call   80108563 <kvmalloc>
  mpinit();        // detect other processors
80103a78:	e8 cc 03 00 00       	call   80103e49 <mpinit>
  lapicinit();     // interrupt controller
80103a7d:	e8 4e f6 ff ff       	call   801030d0 <lapicinit>
  seginit();       // segment descriptors
80103a82:	e8 c4 45 00 00       	call   8010804b <seginit>
  picinit();       // disable pic
80103a87:	e8 0c 05 00 00       	call   80103f98 <picinit>
  ioapicinit();    // another interrupt controller
80103a8c:	e8 8c f1 ff ff       	call   80102c1d <ioapicinit>
  consoleinit();   // console hardware
80103a91:	e8 59 d1 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103a96:	e8 3c 39 00 00       	call   801073d7 <uartinit>
  pinit();         // process table
80103a9b:	e8 ee 08 00 00       	call   8010438e <pinit>
  tvinit();        // trap vectors
80103aa0:	e8 ff 34 00 00       	call   80106fa4 <tvinit>
  binit();         // buffer cache
80103aa5:	e8 8a c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103aaa:	e8 37 d6 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103aaf:	e8 75 ed ff ff       	call   80102829 <ideinit>
  startothers();   // start other processors
80103ab4:	e8 88 00 00 00       	call   80103b41 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103ab9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103ac0:	8e 
80103ac1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103ac8:	e8 6b f2 ff ff       	call   80102d38 <kinit2>
  userinit();      // first user process
80103acd:	e8 e6 0a 00 00       	call   801045b8 <userinit>
  container_init();
80103ad2:	e8 e7 57 00 00       	call   801092be <container_init>
  mpmain();        // finish this processor's setup
80103ad7:	e8 1a 00 00 00       	call   80103af6 <mpmain>

80103adc <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ae2:	e8 93 4a 00 00       	call   8010857a <switchkvm>
  seginit();
80103ae7:	e8 5f 45 00 00       	call   8010804b <seginit>
  lapicinit();
80103aec:	e8 df f5 ff ff       	call   801030d0 <lapicinit>
  mpmain();
80103af1:	e8 00 00 00 00       	call   80103af6 <mpmain>

80103af6 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103af6:	55                   	push   %ebp
80103af7:	89 e5                	mov    %esp,%ebp
80103af9:	53                   	push   %ebx
80103afa:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103afd:	e8 a8 08 00 00       	call   801043aa <cpuid>
80103b02:	89 c3                	mov    %eax,%ebx
80103b04:	e8 a1 08 00 00       	call   801043aa <cpuid>
80103b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b11:	c7 04 24 e9 97 10 80 	movl   $0x801097e9,(%esp)
80103b18:	e8 a4 c8 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103b1d:	e8 df 35 00 00       	call   80107101 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b22:	e8 c8 08 00 00       	call   801043ef <mycpu>
80103b27:	05 a0 00 00 00       	add    $0xa0,%eax
80103b2c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103b33:	00 
80103b34:	89 04 24             	mov    %eax,(%esp)
80103b37:	e8 00 ff ff ff       	call   80103a3c <xchg>
  scheduler();     // start running processes
80103b3c:	e8 16 10 00 00       	call   80104b57 <scheduler>

80103b41 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b41:	55                   	push   %ebp
80103b42:	89 e5                	mov    %esp,%ebp
80103b44:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b47:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b4e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b53:	89 44 24 08          	mov    %eax,0x8(%esp)
80103b57:	c7 44 24 04 6c c5 10 	movl   $0x8010c56c,0x4(%esp)
80103b5e:	80 
80103b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b62:	89 04 24             	mov    %eax,(%esp)
80103b65:	e8 4d 1b 00 00       	call   801056b7 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103b6a:	c7 45 f4 80 4c 11 80 	movl   $0x80114c80,-0xc(%ebp)
80103b71:	eb 75                	jmp    80103be8 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103b73:	e8 77 08 00 00       	call   801043ef <mycpu>
80103b78:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b7b:	75 02                	jne    80103b7f <startothers+0x3e>
      continue;
80103b7d:	eb 62                	jmp    80103be1 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b7f:	e8 e3 f2 ff ff       	call   80102e67 <kalloc>
80103b84:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8a:	83 e8 04             	sub    $0x4,%eax
80103b8d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b90:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b96:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9b:	83 e8 08             	sub    $0x8,%eax
80103b9e:	c7 00 dc 3a 10 80    	movl   $0x80103adc,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba7:	8d 50 f4             	lea    -0xc(%eax),%edx
80103baa:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103baf:	05 00 00 00 80       	add    $0x80000000,%eax
80103bb4:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc2:	8a 00                	mov    (%eax),%al
80103bc4:	0f b6 c0             	movzbl %al,%eax
80103bc7:	89 54 24 04          	mov    %edx,0x4(%esp)
80103bcb:	89 04 24             	mov    %eax,(%esp)
80103bce:	e8 a2 f6 ff ff       	call   80103275 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103bd3:	90                   	nop
80103bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103bdd:	85 c0                	test   %eax,%eax
80103bdf:	74 f3                	je     80103bd4 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103be1:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103be8:	a1 00 52 11 80       	mov    0x80115200,%eax
80103bed:	89 c2                	mov    %eax,%edx
80103bef:	89 d0                	mov    %edx,%eax
80103bf1:	c1 e0 02             	shl    $0x2,%eax
80103bf4:	01 d0                	add    %edx,%eax
80103bf6:	01 c0                	add    %eax,%eax
80103bf8:	01 d0                	add    %edx,%eax
80103bfa:	c1 e0 04             	shl    $0x4,%eax
80103bfd:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103c02:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c05:	0f 87 68 ff ff ff    	ja     80103b73 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103c0b:	c9                   	leave  
80103c0c:	c3                   	ret    
80103c0d:	00 00                	add    %al,(%eax)
	...

80103c10 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103c10:	55                   	push   %ebp
80103c11:	89 e5                	mov    %esp,%ebp
80103c13:	83 ec 14             	sub    $0x14,%esp
80103c16:	8b 45 08             	mov    0x8(%ebp),%eax
80103c19:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c20:	89 c2                	mov    %eax,%edx
80103c22:	ec                   	in     (%dx),%al
80103c23:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c26:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103c29:	c9                   	leave  
80103c2a:	c3                   	ret    

80103c2b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103c2b:	55                   	push   %ebp
80103c2c:	89 e5                	mov    %esp,%ebp
80103c2e:	83 ec 08             	sub    $0x8,%esp
80103c31:	8b 45 08             	mov    0x8(%ebp),%eax
80103c34:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c37:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c3b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c3e:	8a 45 f8             	mov    -0x8(%ebp),%al
80103c41:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c44:	ee                   	out    %al,(%dx)
}
80103c45:	c9                   	leave  
80103c46:	c3                   	ret    

80103c47 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c47:	55                   	push   %ebp
80103c48:	89 e5                	mov    %esp,%ebp
80103c4a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c4d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c54:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c5b:	eb 13                	jmp    80103c70 <sum+0x29>
    sum += addr[i];
80103c5d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c60:	8b 45 08             	mov    0x8(%ebp),%eax
80103c63:	01 d0                	add    %edx,%eax
80103c65:	8a 00                	mov    (%eax),%al
80103c67:	0f b6 c0             	movzbl %al,%eax
80103c6a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103c6d:	ff 45 fc             	incl   -0x4(%ebp)
80103c70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c73:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c76:	7c e5                	jl     80103c5d <sum+0x16>
    sum += addr[i];
  return sum;
80103c78:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c7b:	c9                   	leave  
80103c7c:	c3                   	ret    

80103c7d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c7d:	55                   	push   %ebp
80103c7e:	89 e5                	mov    %esp,%ebp
80103c80:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c83:	8b 45 08             	mov    0x8(%ebp),%eax
80103c86:	05 00 00 00 80       	add    $0x80000000,%eax
80103c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c94:	01 d0                	add    %edx,%eax
80103c96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c9f:	eb 3f                	jmp    80103ce0 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ca1:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ca8:	00 
80103ca9:	c7 44 24 04 00 98 10 	movl   $0x80109800,0x4(%esp)
80103cb0:	80 
80103cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb4:	89 04 24             	mov    %eax,(%esp)
80103cb7:	e8 a9 19 00 00       	call   80105665 <memcmp>
80103cbc:	85 c0                	test   %eax,%eax
80103cbe:	75 1c                	jne    80103cdc <mpsearch1+0x5f>
80103cc0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103cc7:	00 
80103cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccb:	89 04 24             	mov    %eax,(%esp)
80103cce:	e8 74 ff ff ff       	call   80103c47 <sum>
80103cd3:	84 c0                	test   %al,%al
80103cd5:	75 05                	jne    80103cdc <mpsearch1+0x5f>
      return (struct mp*)p;
80103cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cda:	eb 11                	jmp    80103ced <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103cdc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ce6:	72 b9                	jb     80103ca1 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ced:	c9                   	leave  
80103cee:	c3                   	ret    

80103cef <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cef:	55                   	push   %ebp
80103cf0:	89 e5                	mov    %esp,%ebp
80103cf2:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cf5:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cff:	83 c0 0f             	add    $0xf,%eax
80103d02:	8a 00                	mov    (%eax),%al
80103d04:	0f b6 c0             	movzbl %al,%eax
80103d07:	c1 e0 08             	shl    $0x8,%eax
80103d0a:	89 c2                	mov    %eax,%edx
80103d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0f:	83 c0 0e             	add    $0xe,%eax
80103d12:	8a 00                	mov    (%eax),%al
80103d14:	0f b6 c0             	movzbl %al,%eax
80103d17:	09 d0                	or     %edx,%eax
80103d19:	c1 e0 04             	shl    $0x4,%eax
80103d1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d23:	74 21                	je     80103d46 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103d25:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103d2c:	00 
80103d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d30:	89 04 24             	mov    %eax,(%esp)
80103d33:	e8 45 ff ff ff       	call   80103c7d <mpsearch1>
80103d38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d3f:	74 4e                	je     80103d8f <mpsearch+0xa0>
      return mp;
80103d41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d44:	eb 5d                	jmp    80103da3 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d49:	83 c0 14             	add    $0x14,%eax
80103d4c:	8a 00                	mov    (%eax),%al
80103d4e:	0f b6 c0             	movzbl %al,%eax
80103d51:	c1 e0 08             	shl    $0x8,%eax
80103d54:	89 c2                	mov    %eax,%edx
80103d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d59:	83 c0 13             	add    $0x13,%eax
80103d5c:	8a 00                	mov    (%eax),%al
80103d5e:	0f b6 c0             	movzbl %al,%eax
80103d61:	09 d0                	or     %edx,%eax
80103d63:	c1 e0 0a             	shl    $0xa,%eax
80103d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6c:	2d 00 04 00 00       	sub    $0x400,%eax
80103d71:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103d78:	00 
80103d79:	89 04 24             	mov    %eax,(%esp)
80103d7c:	e8 fc fe ff ff       	call   80103c7d <mpsearch1>
80103d81:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d84:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d88:	74 05                	je     80103d8f <mpsearch+0xa0>
      return mp;
80103d8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d8d:	eb 14                	jmp    80103da3 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d8f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103d96:	00 
80103d97:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103d9e:	e8 da fe ff ff       	call   80103c7d <mpsearch1>
}
80103da3:	c9                   	leave  
80103da4:	c3                   	ret    

80103da5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103da5:	55                   	push   %ebp
80103da6:	89 e5                	mov    %esp,%ebp
80103da8:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103dab:	e8 3f ff ff ff       	call   80103cef <mpsearch>
80103db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103db3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103db7:	74 0a                	je     80103dc3 <mpconfig+0x1e>
80103db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbc:	8b 40 04             	mov    0x4(%eax),%eax
80103dbf:	85 c0                	test   %eax,%eax
80103dc1:	75 07                	jne    80103dca <mpconfig+0x25>
    return 0;
80103dc3:	b8 00 00 00 00       	mov    $0x0,%eax
80103dc8:	eb 7d                	jmp    80103e47 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcd:	8b 40 04             	mov    0x4(%eax),%eax
80103dd0:	05 00 00 00 80       	add    $0x80000000,%eax
80103dd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103dd8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ddf:	00 
80103de0:	c7 44 24 04 05 98 10 	movl   $0x80109805,0x4(%esp)
80103de7:	80 
80103de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103deb:	89 04 24             	mov    %eax,(%esp)
80103dee:	e8 72 18 00 00       	call   80105665 <memcmp>
80103df3:	85 c0                	test   %eax,%eax
80103df5:	74 07                	je     80103dfe <mpconfig+0x59>
    return 0;
80103df7:	b8 00 00 00 00       	mov    $0x0,%eax
80103dfc:	eb 49                	jmp    80103e47 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e01:	8a 40 06             	mov    0x6(%eax),%al
80103e04:	3c 01                	cmp    $0x1,%al
80103e06:	74 11                	je     80103e19 <mpconfig+0x74>
80103e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e0b:	8a 40 06             	mov    0x6(%eax),%al
80103e0e:	3c 04                	cmp    $0x4,%al
80103e10:	74 07                	je     80103e19 <mpconfig+0x74>
    return 0;
80103e12:	b8 00 00 00 00       	mov    $0x0,%eax
80103e17:	eb 2e                	jmp    80103e47 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e1c:	8b 40 04             	mov    0x4(%eax),%eax
80103e1f:	0f b7 c0             	movzwl %ax,%eax
80103e22:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e29:	89 04 24             	mov    %eax,(%esp)
80103e2c:	e8 16 fe ff ff       	call   80103c47 <sum>
80103e31:	84 c0                	test   %al,%al
80103e33:	74 07                	je     80103e3c <mpconfig+0x97>
    return 0;
80103e35:	b8 00 00 00 00       	mov    $0x0,%eax
80103e3a:	eb 0b                	jmp    80103e47 <mpconfig+0xa2>
  *pmp = mp;
80103e3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e42:	89 10                	mov    %edx,(%eax)
  return conf;
80103e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e47:	c9                   	leave  
80103e48:	c3                   	ret    

80103e49 <mpinit>:

void
mpinit(void)
{
80103e49:	55                   	push   %ebp
80103e4a:	89 e5                	mov    %esp,%ebp
80103e4c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e4f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e52:	89 04 24             	mov    %eax,(%esp)
80103e55:	e8 4b ff ff ff       	call   80103da5 <mpconfig>
80103e5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e61:	75 0c                	jne    80103e6f <mpinit+0x26>
    panic("Expect to run on an SMP");
80103e63:	c7 04 24 0a 98 10 80 	movl   $0x8010980a,(%esp)
80103e6a:	e8 e5 c6 ff ff       	call   80100554 <panic>
  ismp = 1;
80103e6f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e79:	8b 40 24             	mov    0x24(%eax),%eax
80103e7c:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e84:	83 c0 2c             	add    $0x2c,%eax
80103e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e8d:	8b 40 04             	mov    0x4(%eax),%eax
80103e90:	0f b7 d0             	movzwl %ax,%edx
80103e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e96:	01 d0                	add    %edx,%eax
80103e98:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e9b:	eb 7d                	jmp    80103f1a <mpinit+0xd1>
    switch(*p){
80103e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea0:	8a 00                	mov    (%eax),%al
80103ea2:	0f b6 c0             	movzbl %al,%eax
80103ea5:	83 f8 04             	cmp    $0x4,%eax
80103ea8:	77 68                	ja     80103f12 <mpinit+0xc9>
80103eaa:	8b 04 85 44 98 10 80 	mov    -0x7fef67bc(,%eax,4),%eax
80103eb1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103eb9:	a1 00 52 11 80       	mov    0x80115200,%eax
80103ebe:	83 f8 07             	cmp    $0x7,%eax
80103ec1:	7f 2c                	jg     80103eef <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ec3:	8b 15 00 52 11 80    	mov    0x80115200,%edx
80103ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ecc:	8a 48 01             	mov    0x1(%eax),%cl
80103ecf:	89 d0                	mov    %edx,%eax
80103ed1:	c1 e0 02             	shl    $0x2,%eax
80103ed4:	01 d0                	add    %edx,%eax
80103ed6:	01 c0                	add    %eax,%eax
80103ed8:	01 d0                	add    %edx,%eax
80103eda:	c1 e0 04             	shl    $0x4,%eax
80103edd:	05 80 4c 11 80       	add    $0x80114c80,%eax
80103ee2:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103ee4:	a1 00 52 11 80       	mov    0x80115200,%eax
80103ee9:	40                   	inc    %eax
80103eea:	a3 00 52 11 80       	mov    %eax,0x80115200
      }
      p += sizeof(struct mpproc);
80103eef:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ef3:	eb 25                	jmp    80103f1a <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103efb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103efe:	8a 40 01             	mov    0x1(%eax),%al
80103f01:	a2 60 4c 11 80       	mov    %al,0x80114c60
      p += sizeof(struct mpioapic);
80103f06:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f0a:	eb 0e                	jmp    80103f1a <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f0c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f10:	eb 08                	jmp    80103f1a <mpinit+0xd1>
    default:
      ismp = 0;
80103f12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f19:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f20:	0f 82 77 ff ff ff    	jb     80103e9d <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103f26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f2a:	75 0c                	jne    80103f38 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103f2c:	c7 04 24 24 98 10 80 	movl   $0x80109824,(%esp)
80103f33:	e8 1c c6 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103f38:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f3b:	8a 40 0c             	mov    0xc(%eax),%al
80103f3e:	84 c0                	test   %al,%al
80103f40:	74 36                	je     80103f78 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f42:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103f49:	00 
80103f4a:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103f51:	e8 d5 fc ff ff       	call   80103c2b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f56:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103f5d:	e8 ae fc ff ff       	call   80103c10 <inb>
80103f62:	83 c8 01             	or     $0x1,%eax
80103f65:	0f b6 c0             	movzbl %al,%eax
80103f68:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f6c:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103f73:	e8 b3 fc ff ff       	call   80103c2b <outb>
  }
}
80103f78:	c9                   	leave  
80103f79:	c3                   	ret    
	...

80103f7c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f7c:	55                   	push   %ebp
80103f7d:	89 e5                	mov    %esp,%ebp
80103f7f:	83 ec 08             	sub    $0x8,%esp
80103f82:	8b 45 08             	mov    0x8(%ebp),%eax
80103f85:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f88:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f8c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f8f:	8a 45 f8             	mov    -0x8(%ebp),%al
80103f92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103f95:	ee                   	out    %al,(%dx)
}
80103f96:	c9                   	leave  
80103f97:	c3                   	ret    

80103f98 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103f98:	55                   	push   %ebp
80103f99:	89 e5                	mov    %esp,%ebp
80103f9b:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f9e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103fa5:	00 
80103fa6:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103fad:	e8 ca ff ff ff       	call   80103f7c <outb>
  outb(IO_PIC2+1, 0xFF);
80103fb2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103fb9:	00 
80103fba:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103fc1:	e8 b6 ff ff ff       	call   80103f7c <outb>
}
80103fc6:	c9                   	leave  
80103fc7:	c3                   	ret    

80103fc8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe1:	8b 10                	mov    (%eax),%edx
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fe8:	e8 15 d1 ff ff       	call   80101102 <filealloc>
80103fed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff0:	89 02                	mov    %eax,(%edx)
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	85 c0                	test   %eax,%eax
80103ff9:	0f 84 c8 00 00 00    	je     801040c7 <pipealloc+0xff>
80103fff:	e8 fe d0 ff ff       	call   80101102 <filealloc>
80104004:	8b 55 0c             	mov    0xc(%ebp),%edx
80104007:	89 02                	mov    %eax,(%edx)
80104009:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	85 c0                	test   %eax,%eax
80104010:	0f 84 b1 00 00 00    	je     801040c7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104016:	e8 4c ee ff ff       	call   80102e67 <kalloc>
8010401b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010401e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104022:	75 05                	jne    80104029 <pipealloc+0x61>
    goto bad;
80104024:	e9 9e 00 00 00       	jmp    801040c7 <pipealloc+0xff>
  p->readopen = 1;
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104033:	00 00 00 
  p->writeopen = 1;
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104040:	00 00 00 
  p->nwrite = 0;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010404d:	00 00 00 
  p->nread = 0;
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010405a:	00 00 00 
  initlock(&p->lock, "pipe");
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	c7 44 24 04 58 98 10 	movl   $0x80109858,0x4(%esp)
80104067:	80 
80104068:	89 04 24             	mov    %eax,(%esp)
8010406b:	e8 fa 12 00 00       	call   8010536a <initlock>
  (*f0)->type = FD_PIPE;
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	8b 00                	mov    (%eax),%eax
80104075:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	8b 00                	mov    (%eax),%eax
80104080:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	8b 00                	mov    (%eax),%eax
80104089:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	8b 00                	mov    (%eax),%eax
80104092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104095:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104098:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409b:	8b 00                	mov    (%eax),%eax
8010409d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a6:	8b 00                	mov    (%eax),%eax
801040a8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801040af:	8b 00                	mov    (%eax),%eax
801040b1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b8:	8b 00                	mov    (%eax),%eax
801040ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040bd:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040c0:	b8 00 00 00 00       	mov    $0x0,%eax
801040c5:	eb 42                	jmp    80104109 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801040c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040cb:	74 0b                	je     801040d8 <pipealloc+0x110>
    kfree((char*)p);
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	89 04 24             	mov    %eax,(%esp)
801040d3:	e8 bd ec ff ff       	call   80102d95 <kfree>
  if(*f0)
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	74 0d                	je     801040ee <pipealloc+0x126>
    fileclose(*f0);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	8b 00                	mov    (%eax),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 bc d0 ff ff       	call   801011aa <fileclose>
  if(*f1)
801040ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	85 c0                	test   %eax,%eax
801040f5:	74 0d                	je     80104104 <pipealloc+0x13c>
    fileclose(*f1);
801040f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fa:	8b 00                	mov    (%eax),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 a6 d0 ff ff       	call   801011aa <fileclose>
  return -1;
80104104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104109:	c9                   	leave  
8010410a:	c3                   	ret    

8010410b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410b:	55                   	push   %ebp
8010410c:	89 e5                	mov    %esp,%ebp
8010410e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	89 04 24             	mov    %eax,(%esp)
80104117:	e8 6f 12 00 00       	call   8010538b <acquire>
  if(writable){
8010411c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104120:	74 1f                	je     80104141 <pipeclose+0x36>
    p->writeopen = 0;
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010412c:	00 00 00 
    wakeup(&p->nread);
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	05 34 02 00 00       	add    $0x234,%eax
80104137:	89 04 24             	mov    %eax,(%esp)
8010413a:	e8 bc 0c 00 00       	call   80104dfb <wakeup>
8010413f:	eb 1d                	jmp    8010415e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010414b:	00 00 00 
    wakeup(&p->nwrite);
8010414e:	8b 45 08             	mov    0x8(%ebp),%eax
80104151:	05 38 02 00 00       	add    $0x238,%eax
80104156:	89 04 24             	mov    %eax,(%esp)
80104159:	e8 9d 0c 00 00       	call   80104dfb <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010415e:	8b 45 08             	mov    0x8(%ebp),%eax
80104161:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104167:	85 c0                	test   %eax,%eax
80104169:	75 25                	jne    80104190 <pipeclose+0x85>
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104174:	85 c0                	test   %eax,%eax
80104176:	75 18                	jne    80104190 <pipeclose+0x85>
    release(&p->lock);
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	89 04 24             	mov    %eax,(%esp)
8010417e:	e8 72 12 00 00       	call   801053f5 <release>
    kfree((char*)p);
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	89 04 24             	mov    %eax,(%esp)
80104189:	e8 07 ec ff ff       	call   80102d95 <kfree>
8010418e:	eb 0b                	jmp    8010419b <pipeclose+0x90>
  } else
    release(&p->lock);
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	89 04 24             	mov    %eax,(%esp)
80104196:	e8 5a 12 00 00       	call   801053f5 <release>
}
8010419b:	c9                   	leave  
8010419c:	c3                   	ret    

8010419d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010419d:	55                   	push   %ebp
8010419e:	89 e5                	mov    %esp,%ebp
801041a0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	89 04 24             	mov    %eax,(%esp)
801041a9:	e8 dd 11 00 00       	call   8010538b <acquire>
  for(i = 0; i < n; i++){
801041ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041b5:	e9 a3 00 00 00       	jmp    8010425d <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ba:	eb 56                	jmp    80104212 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041c5:	85 c0                	test   %eax,%eax
801041c7:	74 0c                	je     801041d5 <pipewrite+0x38>
801041c9:	e8 a5 02 00 00       	call   80104473 <myproc>
801041ce:	8b 40 24             	mov    0x24(%eax),%eax
801041d1:	85 c0                	test   %eax,%eax
801041d3:	74 15                	je     801041ea <pipewrite+0x4d>
        release(&p->lock);
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	89 04 24             	mov    %eax,(%esp)
801041db:	e8 15 12 00 00       	call   801053f5 <release>
        return -1;
801041e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e5:	e9 9d 00 00 00       	jmp    80104287 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041ea:	8b 45 08             	mov    0x8(%ebp),%eax
801041ed:	05 34 02 00 00       	add    $0x234,%eax
801041f2:	89 04 24             	mov    %eax,(%esp)
801041f5:	e8 01 0c 00 00       	call   80104dfb <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041fa:	8b 45 08             	mov    0x8(%ebp),%eax
801041fd:	8b 55 08             	mov    0x8(%ebp),%edx
80104200:	81 c2 38 02 00 00    	add    $0x238,%edx
80104206:	89 44 24 04          	mov    %eax,0x4(%esp)
8010420a:	89 14 24             	mov    %edx,(%esp)
8010420d:	e8 12 0b 00 00       	call   80104d24 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104212:	8b 45 08             	mov    0x8(%ebp),%eax
80104215:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104224:	05 00 02 00 00       	add    $0x200,%eax
80104229:	39 c2                	cmp    %eax,%edx
8010422b:	74 8f                	je     801041bc <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010422d:	8b 45 08             	mov    0x8(%ebp),%eax
80104230:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104236:	8d 48 01             	lea    0x1(%eax),%ecx
80104239:	8b 55 08             	mov    0x8(%ebp),%edx
8010423c:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104242:	25 ff 01 00 00       	and    $0x1ff,%eax
80104247:	89 c1                	mov    %eax,%ecx
80104249:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010424f:	01 d0                	add    %edx,%eax
80104251:	8a 10                	mov    (%eax),%dl
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010425a:	ff 45 f4             	incl   -0xc(%ebp)
8010425d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104260:	3b 45 10             	cmp    0x10(%ebp),%eax
80104263:	0f 8c 51 ff ff ff    	jl     801041ba <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104269:	8b 45 08             	mov    0x8(%ebp),%eax
8010426c:	05 34 02 00 00       	add    $0x234,%eax
80104271:	89 04 24             	mov    %eax,(%esp)
80104274:	e8 82 0b 00 00       	call   80104dfb <wakeup>
  release(&p->lock);
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	89 04 24             	mov    %eax,(%esp)
8010427f:	e8 71 11 00 00       	call   801053f5 <release>
  return n;
80104284:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104287:	c9                   	leave  
80104288:	c3                   	ret    

80104289 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104289:	55                   	push   %ebp
8010428a:	89 e5                	mov    %esp,%ebp
8010428c:	53                   	push   %ebx
8010428d:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104290:	8b 45 08             	mov    0x8(%ebp),%eax
80104293:	89 04 24             	mov    %eax,(%esp)
80104296:	e8 f0 10 00 00       	call   8010538b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010429b:	eb 39                	jmp    801042d6 <piperead+0x4d>
    if(myproc()->killed){
8010429d:	e8 d1 01 00 00       	call   80104473 <myproc>
801042a2:	8b 40 24             	mov    0x24(%eax),%eax
801042a5:	85 c0                	test   %eax,%eax
801042a7:	74 15                	je     801042be <piperead+0x35>
      release(&p->lock);
801042a9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ac:	89 04 24             	mov    %eax,(%esp)
801042af:	e8 41 11 00 00       	call   801053f5 <release>
      return -1;
801042b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042b9:	e9 b3 00 00 00       	jmp    80104371 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042be:	8b 45 08             	mov    0x8(%ebp),%eax
801042c1:	8b 55 08             	mov    0x8(%ebp),%edx
801042c4:	81 c2 34 02 00 00    	add    $0x234,%edx
801042ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801042ce:	89 14 24             	mov    %edx,(%esp)
801042d1:	e8 4e 0a 00 00       	call   80104d24 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042d6:	8b 45 08             	mov    0x8(%ebp),%eax
801042d9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042df:	8b 45 08             	mov    0x8(%ebp),%eax
801042e2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e8:	39 c2                	cmp    %eax,%edx
801042ea:	75 0d                	jne    801042f9 <piperead+0x70>
801042ec:	8b 45 08             	mov    0x8(%ebp),%eax
801042ef:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042f5:	85 c0                	test   %eax,%eax
801042f7:	75 a4                	jne    8010429d <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104300:	eb 49                	jmp    8010434b <piperead+0xc2>
    if(p->nread == p->nwrite)
80104302:	8b 45 08             	mov    0x8(%ebp),%eax
80104305:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010430b:	8b 45 08             	mov    0x8(%ebp),%eax
8010430e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104314:	39 c2                	cmp    %eax,%edx
80104316:	75 02                	jne    8010431a <piperead+0x91>
      break;
80104318:	eb 39                	jmp    80104353 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010431a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104320:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010432c:	8d 48 01             	lea    0x1(%eax),%ecx
8010432f:	8b 55 08             	mov    0x8(%ebp),%edx
80104332:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104338:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433d:	89 c2                	mov    %eax,%edx
8010433f:	8b 45 08             	mov    0x8(%ebp),%eax
80104342:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104346:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104348:	ff 45 f4             	incl   -0xc(%ebp)
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104351:	7c af                	jl     80104302 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	05 38 02 00 00       	add    $0x238,%eax
8010435b:	89 04 24             	mov    %eax,(%esp)
8010435e:	e8 98 0a 00 00       	call   80104dfb <wakeup>
  release(&p->lock);
80104363:	8b 45 08             	mov    0x8(%ebp),%eax
80104366:	89 04 24             	mov    %eax,(%esp)
80104369:	e8 87 10 00 00       	call   801053f5 <release>
  return i;
8010436e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104371:	83 c4 24             	add    $0x24,%esp
80104374:	5b                   	pop    %ebx
80104375:	5d                   	pop    %ebp
80104376:	c3                   	ret    
	...

80104378 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104378:	55                   	push   %ebp
80104379:	89 e5                	mov    %esp,%ebp
8010437b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010437e:	9c                   	pushf  
8010437f:	58                   	pop    %eax
80104380:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104383:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104386:	c9                   	leave  
80104387:	c3                   	ret    

80104388 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104388:	55                   	push   %ebp
80104389:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010438b:	fb                   	sti    
}
8010438c:	5d                   	pop    %ebp
8010438d:	c3                   	ret    

8010438e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010438e:	55                   	push   %ebp
8010438f:	89 e5                	mov    %esp,%ebp
80104391:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104394:	c7 44 24 04 60 98 10 	movl   $0x80109860,0x4(%esp)
8010439b:	80 
8010439c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801043a3:	e8 c2 0f 00 00       	call   8010536a <initlock>
}
801043a8:	c9                   	leave  
801043a9:	c3                   	ret    

801043aa <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801043aa:	55                   	push   %ebp
801043ab:	89 e5                	mov    %esp,%ebp
801043ad:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801043b0:	e8 3a 00 00 00       	call   801043ef <mycpu>
801043b5:	89 c2                	mov    %eax,%edx
801043b7:	b8 80 4c 11 80       	mov    $0x80114c80,%eax
801043bc:	29 c2                	sub    %eax,%edx
801043be:	89 d0                	mov    %edx,%eax
801043c0:	c1 f8 04             	sar    $0x4,%eax
801043c3:	89 c1                	mov    %eax,%ecx
801043c5:	89 ca                	mov    %ecx,%edx
801043c7:	c1 e2 03             	shl    $0x3,%edx
801043ca:	01 ca                	add    %ecx,%edx
801043cc:	89 d0                	mov    %edx,%eax
801043ce:	c1 e0 05             	shl    $0x5,%eax
801043d1:	29 d0                	sub    %edx,%eax
801043d3:	c1 e0 02             	shl    $0x2,%eax
801043d6:	01 c8                	add    %ecx,%eax
801043d8:	c1 e0 03             	shl    $0x3,%eax
801043db:	01 c8                	add    %ecx,%eax
801043dd:	89 c2                	mov    %eax,%edx
801043df:	c1 e2 0f             	shl    $0xf,%edx
801043e2:	29 c2                	sub    %eax,%edx
801043e4:	c1 e2 02             	shl    $0x2,%edx
801043e7:	01 ca                	add    %ecx,%edx
801043e9:	89 d0                	mov    %edx,%eax
801043eb:	f7 d8                	neg    %eax
}
801043ed:	c9                   	leave  
801043ee:	c3                   	ret    

801043ef <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801043ef:	55                   	push   %ebp
801043f0:	89 e5                	mov    %esp,%ebp
801043f2:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801043f5:	e8 7e ff ff ff       	call   80104378 <readeflags>
801043fa:	25 00 02 00 00       	and    $0x200,%eax
801043ff:	85 c0                	test   %eax,%eax
80104401:	74 0c                	je     8010440f <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104403:	c7 04 24 68 98 10 80 	movl   $0x80109868,(%esp)
8010440a:	e8 45 c1 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010440f:	e8 15 ee ff ff       	call   80103229 <lapicid>
80104414:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010441e:	eb 3b                	jmp    8010445b <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104420:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104423:	89 d0                	mov    %edx,%eax
80104425:	c1 e0 02             	shl    $0x2,%eax
80104428:	01 d0                	add    %edx,%eax
8010442a:	01 c0                	add    %eax,%eax
8010442c:	01 d0                	add    %edx,%eax
8010442e:	c1 e0 04             	shl    $0x4,%eax
80104431:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104436:	8a 00                	mov    (%eax),%al
80104438:	0f b6 c0             	movzbl %al,%eax
8010443b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010443e:	75 18                	jne    80104458 <mycpu+0x69>
      return &cpus[i];
80104440:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104443:	89 d0                	mov    %edx,%eax
80104445:	c1 e0 02             	shl    $0x2,%eax
80104448:	01 d0                	add    %edx,%eax
8010444a:	01 c0                	add    %eax,%eax
8010444c:	01 d0                	add    %edx,%eax
8010444e:	c1 e0 04             	shl    $0x4,%eax
80104451:	05 80 4c 11 80       	add    $0x80114c80,%eax
80104456:	eb 19                	jmp    80104471 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104458:	ff 45 f4             	incl   -0xc(%ebp)
8010445b:	a1 00 52 11 80       	mov    0x80115200,%eax
80104460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104463:	7c bb                	jl     80104420 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104465:	c7 04 24 8e 98 10 80 	movl   $0x8010988e,(%esp)
8010446c:	e8 e3 c0 ff ff       	call   80100554 <panic>
}
80104471:	c9                   	leave  
80104472:	c3                   	ret    

80104473 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104473:	55                   	push   %ebp
80104474:	89 e5                	mov    %esp,%ebp
80104476:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104479:	e8 6c 10 00 00       	call   801054ea <pushcli>
  c = mycpu();
8010447e:	e8 6c ff ff ff       	call   801043ef <mycpu>
80104483:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010448f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104492:	e8 9d 10 00 00       	call   80105534 <popcli>
  return p;
80104497:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010449a:	c9                   	leave  
8010449b:	c3                   	ret    

8010449c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010449c:	55                   	push   %ebp
8010449d:	89 e5                	mov    %esp,%ebp
8010449f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);
801044a2:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801044a9:	e8 dd 0e 00 00       	call   8010538b <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044ae:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801044b5:	eb 53                	jmp    8010450a <allocproc+0x6e>
    if(p->state == UNUSED)
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	8b 40 0c             	mov    0xc(%eax),%eax
801044bd:	85 c0                	test   %eax,%eax
801044bf:	75 42                	jne    80104503 <allocproc+0x67>
      goto found;
801044c1:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c5:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044cc:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801044d1:	8d 50 01             	lea    0x1(%eax),%edx
801044d4:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801044da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044dd:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801044e0:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801044e7:	e8 09 0f 00 00       	call   801053f5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044ec:	e8 76 e9 ff ff       	call   80102e67 <kalloc>
801044f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f4:	89 42 08             	mov    %eax,0x8(%edx)
801044f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fa:	8b 40 08             	mov    0x8(%eax),%eax
801044fd:	85 c0                	test   %eax,%eax
801044ff:	75 39                	jne    8010453a <allocproc+0x9e>
80104501:	eb 26                	jmp    80104529 <allocproc+0x8d>
  char *sp;
  // cprintf("In allocproc\n.");

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104503:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010450a:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104511:	72 a4                	jb     801044b7 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104513:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010451a:	e8 d6 0e 00 00       	call   801053f5 <release>
  return 0;
8010451f:	b8 00 00 00 00       	mov    $0x0,%eax
80104524:	e9 8d 00 00 00       	jmp    801045b6 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104533:	b8 00 00 00 00       	mov    $0x0,%eax
80104538:	eb 7c                	jmp    801045b6 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
8010453a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453d:	8b 40 08             	mov    0x8(%eax),%eax
80104540:	05 00 10 00 00       	add    $0x1000,%eax
80104545:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104548:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104552:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104555:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104559:	ba 60 6f 10 80       	mov    $0x80106f60,%edx
8010455e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104561:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104563:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010456d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104573:	8b 40 1c             	mov    0x1c(%eax),%eax
80104576:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010457d:	00 
8010457e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104585:	00 
80104586:	89 04 24             	mov    %eax,(%esp)
80104589:	e8 60 10 00 00       	call   801055ee <memset>
  p->context->eip = (uint)forkret;
8010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104591:	8b 40 1c             	mov    0x1c(%eax),%eax
80104594:	ba e5 4c 10 80       	mov    $0x80104ce5,%edx
80104599:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801045b0:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
801045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045b6:	c9                   	leave  
801045b7:	c3                   	ret    

801045b8 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045b8:	55                   	push   %ebp
801045b9:	89 e5                	mov    %esp,%ebp
801045bb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801045be:	e8 d9 fe ff ff       	call   8010449c <allocproc>
801045c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801045c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c9:	a3 00 c9 10 80       	mov    %eax,0x8010c900
  if((p->pgdir = setupkvm()) == 0)
801045ce:	e8 e7 3e 00 00       	call   801084ba <setupkvm>
801045d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d6:	89 42 04             	mov    %eax,0x4(%edx)
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	8b 40 04             	mov    0x4(%eax),%eax
801045df:	85 c0                	test   %eax,%eax
801045e1:	75 0c                	jne    801045ef <userinit+0x37>
    panic("userinit: out of memory?");
801045e3:	c7 04 24 9e 98 10 80 	movl   $0x8010989e,(%esp)
801045ea:	e8 65 bf ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045ef:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f7:	8b 40 04             	mov    0x4(%eax),%eax
801045fa:	89 54 24 08          	mov    %edx,0x8(%esp)
801045fe:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
80104605:	80 
80104606:	89 04 24             	mov    %eax,(%esp)
80104609:	e8 0d 41 00 00       	call   8010871b <inituvm>
  p->sz = PGSIZE;
8010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104611:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461a:	8b 40 18             	mov    0x18(%eax),%eax
8010461d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104624:	00 
80104625:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010462c:	00 
8010462d:	89 04 24             	mov    %eax,(%esp)
80104630:	e8 b9 0f 00 00       	call   801055ee <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104638:	8b 40 18             	mov    0x18(%eax),%eax
8010463b:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	8b 40 18             	mov    0x18(%eax),%eax
80104647:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010464d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104650:	8b 50 18             	mov    0x18(%eax),%edx
80104653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104656:	8b 40 18             	mov    0x18(%eax),%eax
80104659:	8b 40 2c             	mov    0x2c(%eax),%eax
8010465c:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104663:	8b 50 18             	mov    0x18(%eax),%edx
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	8b 40 18             	mov    0x18(%eax),%eax
8010466c:	8b 40 2c             	mov    0x2c(%eax),%eax
8010466f:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104676:	8b 40 18             	mov    0x18(%eax),%eax
80104679:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 40 18             	mov    0x18(%eax),%eax
80104686:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104690:	8b 40 18             	mov    0x18(%eax),%eax
80104693:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010469a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469d:	83 c0 6c             	add    $0x6c,%eax
801046a0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046a7:	00 
801046a8:	c7 44 24 04 b7 98 10 	movl   $0x801098b7,0x4(%esp)
801046af:	80 
801046b0:	89 04 24             	mov    %eax,(%esp)
801046b3:	e8 42 11 00 00       	call   801057fa <safestrcpy>
  p->cwd = namei("/");
801046b8:	c7 04 24 c0 98 10 80 	movl   $0x801098c0,(%esp)
801046bf:	e8 59 e0 ff ff       	call   8010271d <namei>
801046c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046c7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801046ca:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801046d1:	e8 b5 0c 00 00       	call   8010538b <acquire>

  p->state = RUNNABLE;
801046d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801046e0:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801046e7:	e8 09 0d 00 00       	call   801053f5 <release>
}
801046ec:	c9                   	leave  
801046ed:	c3                   	ret    

801046ee <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046ee:	55                   	push   %ebp
801046ef:	89 e5                	mov    %esp,%ebp
801046f1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801046f4:	e8 7a fd ff ff       	call   80104473 <myproc>
801046f9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801046fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ff:	8b 00                	mov    (%eax),%eax
80104701:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104704:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104708:	7e 31                	jle    8010473b <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010470a:	8b 55 08             	mov    0x8(%ebp),%edx
8010470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104710:	01 c2                	add    %eax,%edx
80104712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104715:	8b 40 04             	mov    0x4(%eax),%eax
80104718:	89 54 24 08          	mov    %edx,0x8(%esp)
8010471c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104723:	89 04 24             	mov    %eax,(%esp)
80104726:	e8 5b 41 00 00       	call   80108886 <allocuvm>
8010472b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010472e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104732:	75 3e                	jne    80104772 <growproc+0x84>
      return -1;
80104734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104739:	eb 4f                	jmp    8010478a <growproc+0x9c>
  } else if(n < 0){
8010473b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010473f:	79 31                	jns    80104772 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104741:	8b 55 08             	mov    0x8(%ebp),%edx
80104744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104747:	01 c2                	add    %eax,%edx
80104749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010474c:	8b 40 04             	mov    0x4(%eax),%eax
8010474f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104753:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104756:	89 54 24 04          	mov    %edx,0x4(%esp)
8010475a:	89 04 24             	mov    %eax,(%esp)
8010475d:	e8 3a 42 00 00       	call   8010899c <deallocuvm>
80104762:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104765:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104769:	75 07                	jne    80104772 <growproc+0x84>
      return -1;
8010476b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104770:	eb 18                	jmp    8010478a <growproc+0x9c>
  }
  curproc->sz = sz;
80104772:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104775:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104778:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010477a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010477d:	89 04 24             	mov    %eax,(%esp)
80104780:	e8 0f 3e 00 00       	call   80108594 <switchuvm>
  return 0;
80104785:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010478a:	c9                   	leave  
8010478b:	c3                   	ret    

8010478c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010478c:	55                   	push   %ebp
8010478d:	89 e5                	mov    %esp,%ebp
8010478f:	57                   	push   %edi
80104790:	56                   	push   %esi
80104791:	53                   	push   %ebx
80104792:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104795:	e8 d9 fc ff ff       	call   80104473 <myproc>
8010479a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010479d:	e8 fa fc ff ff       	call   8010449c <allocproc>
801047a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
801047a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801047a9:	75 0a                	jne    801047b5 <fork+0x29>
    return -1;
801047ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b0:	e9 47 01 00 00       	jmp    801048fc <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b8:	8b 10                	mov    (%eax),%edx
801047ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bd:	8b 40 04             	mov    0x4(%eax),%eax
801047c0:	89 54 24 04          	mov    %edx,0x4(%esp)
801047c4:	89 04 24             	mov    %eax,(%esp)
801047c7:	e8 70 43 00 00       	call   80108b3c <copyuvm>
801047cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047cf:	89 42 04             	mov    %eax,0x4(%edx)
801047d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047d5:	8b 40 04             	mov    0x4(%eax),%eax
801047d8:	85 c0                	test   %eax,%eax
801047da:	75 2c                	jne    80104808 <fork+0x7c>
    kfree(np->kstack);
801047dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047df:	8b 40 08             	mov    0x8(%eax),%eax
801047e2:	89 04 24             	mov    %eax,(%esp)
801047e5:	e8 ab e5 ff ff       	call   80102d95 <kfree>
    np->kstack = 0;
801047ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047f7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104803:	e9 f4 00 00 00       	jmp    801048fc <fork+0x170>
  }
  np->sz = curproc->sz;
80104808:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480b:	8b 10                	mov    (%eax),%edx
8010480d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104810:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104812:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104815:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104818:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010481b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010481e:	8b 50 18             	mov    0x18(%eax),%edx
80104821:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104824:	8b 40 18             	mov    0x18(%eax),%eax
80104827:	89 c3                	mov    %eax,%ebx
80104829:	b8 13 00 00 00       	mov    $0x13,%eax
8010482e:	89 d7                	mov    %edx,%edi
80104830:	89 de                	mov    %ebx,%esi
80104832:	89 c1                	mov    %eax,%ecx
80104834:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104836:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104839:	8b 40 18             	mov    0x18(%eax),%eax
8010483c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104843:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010484a:	eb 36                	jmp    80104882 <fork+0xf6>
    if(curproc->ofile[i])
8010484c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104852:	83 c2 08             	add    $0x8,%edx
80104855:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104859:	85 c0                	test   %eax,%eax
8010485b:	74 22                	je     8010487f <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010485d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104860:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104863:	83 c2 08             	add    $0x8,%edx
80104866:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010486a:	89 04 24             	mov    %eax,(%esp)
8010486d:	e8 f0 c8 ff ff       	call   80101162 <filedup>
80104872:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104875:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104878:	83 c1 08             	add    $0x8,%ecx
8010487b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010487f:	ff 45 e4             	incl   -0x1c(%ebp)
80104882:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104886:	7e c4                	jle    8010484c <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104888:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010488b:	8b 40 68             	mov    0x68(%eax),%eax
8010488e:	89 04 24             	mov    %eax,(%esp)
80104891:	e8 fa d1 ff ff       	call   80101a90 <idup>
80104896:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104899:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010489c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010489f:	8d 50 6c             	lea    0x6c(%eax),%edx
801048a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048a5:	83 c0 6c             	add    $0x6c,%eax
801048a8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048af:	00 
801048b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801048b4:	89 04 24             	mov    %eax,(%esp)
801048b7:	e8 3e 0f 00 00       	call   801057fa <safestrcpy>



  pid = np->pid;
801048bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bf:	8b 40 10             	mov    0x10(%eax),%eax
801048c2:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801048c5:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801048cc:	e8 ba 0a 00 00       	call   8010538b <acquire>

  np->state = RUNNABLE;
801048d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
801048db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048de:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801048e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048e7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
801048ed:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
801048f4:	e8 fc 0a 00 00       	call   801053f5 <release>

  return pid;
801048f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801048fc:	83 c4 2c             	add    $0x2c,%esp
801048ff:	5b                   	pop    %ebx
80104900:	5e                   	pop    %esi
80104901:	5f                   	pop    %edi
80104902:	5d                   	pop    %ebp
80104903:	c3                   	ret    

80104904 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104904:	55                   	push   %ebp
80104905:	89 e5                	mov    %esp,%ebp
80104907:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
8010490a:	e8 64 fb ff ff       	call   80104473 <myproc>
8010490f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104912:	a1 00 c9 10 80       	mov    0x8010c900,%eax
80104917:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010491a:	75 0c                	jne    80104928 <exit+0x24>
    panic("init exiting");
8010491c:	c7 04 24 c2 98 10 80 	movl   $0x801098c2,(%esp)
80104923:	e8 2c bc ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104928:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010492f:	eb 3a                	jmp    8010496b <exit+0x67>
    if(curproc->ofile[fd]){
80104931:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104934:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104937:	83 c2 08             	add    $0x8,%edx
8010493a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010493e:	85 c0                	test   %eax,%eax
80104940:	74 26                	je     80104968 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104942:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104945:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104948:	83 c2 08             	add    $0x8,%edx
8010494b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010494f:	89 04 24             	mov    %eax,(%esp)
80104952:	e8 53 c8 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104957:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010495a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010495d:	83 c2 08             	add    $0x8,%edx
80104960:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104967:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104968:	ff 45 f0             	incl   -0x10(%ebp)
8010496b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010496f:	7e c0                	jle    80104931 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104971:	e8 fd ed ff ff       	call   80103773 <begin_op>
  iput(curproc->cwd);
80104976:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104979:	8b 40 68             	mov    0x68(%eax),%eax
8010497c:	89 04 24             	mov    %eax,(%esp)
8010497f:	e8 8c d2 ff ff       	call   80101c10 <iput>
  end_op();
80104984:	e8 6c ee ff ff       	call   801037f5 <end_op>
  curproc->cwd = 0;
80104989:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010498c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104993:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
8010499a:	e8 ec 09 00 00       	call   8010538b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010499f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049a2:	8b 40 14             	mov    0x14(%eax),%eax
801049a5:	89 04 24             	mov    %eax,(%esp)
801049a8:	e8 0d 04 00 00       	call   80104dba <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049ad:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
801049b4:	eb 36                	jmp    801049ec <exit+0xe8>
    if(p->parent == curproc){
801049b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b9:	8b 40 14             	mov    0x14(%eax),%eax
801049bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801049bf:	75 24                	jne    801049e5 <exit+0xe1>
      p->parent = initproc;
801049c1:	8b 15 00 c9 10 80    	mov    0x8010c900,%edx
801049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ca:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d0:	8b 40 0c             	mov    0xc(%eax),%eax
801049d3:	83 f8 05             	cmp    $0x5,%eax
801049d6:	75 0d                	jne    801049e5 <exit+0xe1>
        wakeup1(initproc);
801049d8:	a1 00 c9 10 80       	mov    0x8010c900,%eax
801049dd:	89 04 24             	mov    %eax,(%esp)
801049e0:	e8 d5 03 00 00       	call   80104dba <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e5:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049ec:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801049f3:	72 c1                	jb     801049b6 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801049f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801049ff:	e8 01 02 00 00       	call   80104c05 <sched>
  panic("zombie exit");
80104a04:	c7 04 24 cf 98 10 80 	movl   $0x801098cf,(%esp)
80104a0b:	e8 44 bb ff ff       	call   80100554 <panic>

80104a10 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104a13:	eb 06                	jmp    80104a1b <strcmp1+0xb>
    p++, q++;
80104a15:	ff 45 08             	incl   0x8(%ebp)
80104a18:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1e:	8a 00                	mov    (%eax),%al
80104a20:	84 c0                	test   %al,%al
80104a22:	74 0e                	je     80104a32 <strcmp1+0x22>
80104a24:	8b 45 08             	mov    0x8(%ebp),%eax
80104a27:	8a 10                	mov    (%eax),%dl
80104a29:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a2c:	8a 00                	mov    (%eax),%al
80104a2e:	38 c2                	cmp    %al,%dl
80104a30:	74 e3                	je     80104a15 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104a32:	8b 45 08             	mov    0x8(%ebp),%eax
80104a35:	8a 00                	mov    (%eax),%al
80104a37:	0f b6 d0             	movzbl %al,%edx
80104a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a3d:	8a 00                	mov    (%eax),%al
80104a3f:	0f b6 c0             	movzbl %al,%eax
80104a42:	29 c2                	sub    %eax,%edx
80104a44:	89 d0                	mov    %edx,%eax
}
80104a46:	5d                   	pop    %ebp
80104a47:	c3                   	ret    

80104a48 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a48:	55                   	push   %ebp
80104a49:	89 e5                	mov    %esp,%ebp
80104a4b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104a4e:	e8 20 fa ff ff       	call   80104473 <myproc>
80104a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104a56:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104a5d:	e8 29 09 00 00       	call   8010538b <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104a62:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a69:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104a70:	e9 98 00 00 00       	jmp    80104b0d <wait+0xc5>
      if(p->parent != curproc)
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	8b 40 14             	mov    0x14(%eax),%eax
80104a7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104a7e:	74 05                	je     80104a85 <wait+0x3d>
        continue;
80104a80:	e9 81 00 00 00       	jmp    80104b06 <wait+0xbe>
      havekids = 1;
80104a85:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	8b 40 0c             	mov    0xc(%eax),%eax
80104a92:	83 f8 05             	cmp    $0x5,%eax
80104a95:	75 6f                	jne    80104b06 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9a:	8b 40 10             	mov    0x10(%eax),%eax
80104a9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 40 08             	mov    0x8(%eax),%eax
80104aa6:	89 04 24             	mov    %eax,(%esp)
80104aa9:	e8 e7 e2 ff ff       	call   80102d95 <kfree>
        p->kstack = 0;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	8b 40 04             	mov    0x4(%eax),%eax
80104abe:	89 04 24             	mov    %eax,(%esp)
80104ac1:	e8 9a 3f 00 00       	call   80108a60 <freevm>
        p->pid = 0;
80104ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aee:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104af5:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104afc:	e8 f4 08 00 00       	call   801053f5 <release>
        return pid;
80104b01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b04:	eb 4f                	jmp    80104b55 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b06:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104b0d:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104b14:	0f 82 5b ff ff ff    	jb     80104a75 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104b1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b1e:	74 0a                	je     80104b2a <wait+0xe2>
80104b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b23:	8b 40 24             	mov    0x24(%eax),%eax
80104b26:	85 c0                	test   %eax,%eax
80104b28:	74 13                	je     80104b3d <wait+0xf5>
      release(&ptable.lock);
80104b2a:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b31:	e8 bf 08 00 00       	call   801053f5 <release>
      return -1;
80104b36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3b:	eb 18                	jmp    80104b55 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104b3d:	c7 44 24 04 20 52 11 	movl   $0x80115220,0x4(%esp)
80104b44:	80 
80104b45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b48:	89 04 24             	mov    %eax,(%esp)
80104b4b:	e8 d4 01 00 00       	call   80104d24 <sleep>
  }
80104b50:	e9 0d ff ff ff       	jmp    80104a62 <wait+0x1a>
}
80104b55:	c9                   	leave  
80104b56:	c3                   	ret    

80104b57 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b57:	55                   	push   %ebp
80104b58:	89 e5                	mov    %esp,%ebp
80104b5a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104b5d:	e8 8d f8 ff ff       	call   801043ef <mycpu>
80104b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b68:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104b6f:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b72:	e8 11 f8 ff ff       	call   80104388 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b77:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104b7e:	e8 08 08 00 00       	call   8010538b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b83:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104b8a:	eb 5f                	jmp    80104beb <scheduler+0x94>
      if(p->state != RUNNABLE)
80104b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b92:	83 f8 03             	cmp    $0x3,%eax
80104b95:	74 02                	je     80104b99 <scheduler+0x42>
        continue;
80104b97:	eb 4b                	jmp    80104be4 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b9f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba8:	89 04 24             	mov    %eax,(%esp)
80104bab:	e8 e4 39 00 00       	call   80108594 <switchuvm>
      p->state = RUNNING;
80104bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb3:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bc3:	83 c2 04             	add    $0x4,%edx
80104bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bca:	89 14 24             	mov    %edx,(%esp)
80104bcd:	e8 96 0c 00 00       	call   80105868 <swtch>
      switchkvm();
80104bd2:	e8 a3 39 00 00       	call   8010857a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bda:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104be1:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be4:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104beb:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104bf2:	72 98                	jb     80104b8c <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104bf4:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104bfb:	e8 f5 07 00 00       	call   801053f5 <release>

  }
80104c00:	e9 6d ff ff ff       	jmp    80104b72 <scheduler+0x1b>

80104c05 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104c05:	55                   	push   %ebp
80104c06:	89 e5                	mov    %esp,%ebp
80104c08:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104c0b:	e8 63 f8 ff ff       	call   80104473 <myproc>
80104c10:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104c13:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104c1a:	e8 9a 08 00 00       	call   801054b9 <holding>
80104c1f:	85 c0                	test   %eax,%eax
80104c21:	75 0c                	jne    80104c2f <sched+0x2a>
    panic("sched ptable.lock");
80104c23:	c7 04 24 db 98 10 80 	movl   $0x801098db,(%esp)
80104c2a:	e8 25 b9 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104c2f:	e8 bb f7 ff ff       	call   801043ef <mycpu>
80104c34:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c3a:	83 f8 01             	cmp    $0x1,%eax
80104c3d:	74 0c                	je     80104c4b <sched+0x46>
    panic("sched locks");
80104c3f:	c7 04 24 ed 98 10 80 	movl   $0x801098ed,(%esp)
80104c46:	e8 09 b9 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4e:	8b 40 0c             	mov    0xc(%eax),%eax
80104c51:	83 f8 04             	cmp    $0x4,%eax
80104c54:	75 0c                	jne    80104c62 <sched+0x5d>
    panic("sched running");
80104c56:	c7 04 24 f9 98 10 80 	movl   $0x801098f9,(%esp)
80104c5d:	e8 f2 b8 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104c62:	e8 11 f7 ff ff       	call   80104378 <readeflags>
80104c67:	25 00 02 00 00       	and    $0x200,%eax
80104c6c:	85 c0                	test   %eax,%eax
80104c6e:	74 0c                	je     80104c7c <sched+0x77>
    panic("sched interruptible");
80104c70:	c7 04 24 07 99 10 80 	movl   $0x80109907,(%esp)
80104c77:	e8 d8 b8 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104c7c:	e8 6e f7 ff ff       	call   801043ef <mycpu>
80104c81:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104c8a:	e8 60 f7 ff ff       	call   801043ef <mycpu>
80104c8f:	8b 40 04             	mov    0x4(%eax),%eax
80104c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c95:	83 c2 1c             	add    $0x1c,%edx
80104c98:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c9c:	89 14 24             	mov    %edx,(%esp)
80104c9f:	e8 c4 0b 00 00       	call   80105868 <swtch>
  mycpu()->intena = intena;
80104ca4:	e8 46 f7 ff ff       	call   801043ef <mycpu>
80104ca9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cac:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104cb2:	c9                   	leave  
80104cb3:	c3                   	ret    

80104cb4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cb4:	55                   	push   %ebp
80104cb5:	89 e5                	mov    %esp,%ebp
80104cb7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cba:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cc1:	e8 c5 06 00 00       	call   8010538b <acquire>
  myproc()->state = RUNNABLE;
80104cc6:	e8 a8 f7 ff ff       	call   80104473 <myproc>
80104ccb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104cd2:	e8 2e ff ff ff       	call   80104c05 <sched>
  release(&ptable.lock);
80104cd7:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cde:	e8 12 07 00 00       	call   801053f5 <release>
}
80104ce3:	c9                   	leave  
80104ce4:	c3                   	ret    

80104ce5 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ce5:	55                   	push   %ebp
80104ce6:	89 e5                	mov    %esp,%ebp
80104ce8:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ceb:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104cf2:	e8 fe 06 00 00       	call   801053f5 <release>

  if (first) {
80104cf7:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104cfc:	85 c0                	test   %eax,%eax
80104cfe:	74 22                	je     80104d22 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104d00:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104d07:	00 00 00 
    iinit(ROOTDEV);
80104d0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104d11:	e8 45 ca ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104d16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104d1d:	e8 52 e8 ff ff       	call   80103574 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104d22:	c9                   	leave  
80104d23:	c3                   	ret    

80104d24 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d24:	55                   	push   %ebp
80104d25:	89 e5                	mov    %esp,%ebp
80104d27:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104d2a:	e8 44 f7 ff ff       	call   80104473 <myproc>
80104d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104d32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d36:	75 0c                	jne    80104d44 <sleep+0x20>
    panic("sleep");
80104d38:	c7 04 24 1b 99 10 80 	movl   $0x8010991b,(%esp)
80104d3f:	e8 10 b8 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104d44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d48:	75 0c                	jne    80104d56 <sleep+0x32>
    panic("sleep without lk");
80104d4a:	c7 04 24 21 99 10 80 	movl   $0x80109921,(%esp)
80104d51:	e8 fe b7 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d56:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104d5d:	74 17                	je     80104d76 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d5f:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104d66:	e8 20 06 00 00       	call   8010538b <acquire>
    release(lk);
80104d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d6e:	89 04 24             	mov    %eax,(%esp)
80104d71:	e8 7f 06 00 00       	call   801053f5 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	8b 55 08             	mov    0x8(%ebp),%edx
80104d7c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d82:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104d89:	e8 77 fe ff ff       	call   80104c05 <sched>

  // Tidy up.
  p->chan = 0;
80104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d91:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104d98:	81 7d 0c 20 52 11 80 	cmpl   $0x80115220,0xc(%ebp)
80104d9f:	74 17                	je     80104db8 <sleep+0x94>
    release(&ptable.lock);
80104da1:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104da8:	e8 48 06 00 00       	call   801053f5 <release>
    acquire(lk);
80104dad:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db0:	89 04 24             	mov    %eax,(%esp)
80104db3:	e8 d3 05 00 00       	call   8010538b <acquire>
  }
}
80104db8:	c9                   	leave  
80104db9:	c3                   	ret    

80104dba <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104dba:	55                   	push   %ebp
80104dbb:	89 e5                	mov    %esp,%ebp
80104dbd:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dc0:	c7 45 fc 54 52 11 80 	movl   $0x80115254,-0x4(%ebp)
80104dc7:	eb 27                	jmp    80104df0 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104dc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dcc:	8b 40 0c             	mov    0xc(%eax),%eax
80104dcf:	83 f8 02             	cmp    $0x2,%eax
80104dd2:	75 15                	jne    80104de9 <wakeup1+0x2f>
80104dd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dd7:	8b 40 20             	mov    0x20(%eax),%eax
80104dda:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ddd:	75 0a                	jne    80104de9 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ddf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104de9:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104df0:	81 7d fc 54 73 11 80 	cmpl   $0x80117354,-0x4(%ebp)
80104df7:	72 d0                	jb     80104dc9 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104df9:	c9                   	leave  
80104dfa:	c3                   	ret    

80104dfb <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104dfb:	55                   	push   %ebp
80104dfc:	89 e5                	mov    %esp,%ebp
80104dfe:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e01:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104e08:	e8 7e 05 00 00       	call   8010538b <acquire>
  wakeup1(chan);
80104e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e10:	89 04 24             	mov    %eax,(%esp)
80104e13:	e8 a2 ff ff ff       	call   80104dba <wakeup1>
  release(&ptable.lock);
80104e18:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104e1f:	e8 d1 05 00 00       	call   801053f5 <release>
}
80104e24:	c9                   	leave  
80104e25:	c3                   	ret    

80104e26 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e26:	55                   	push   %ebp
80104e27:	89 e5                	mov    %esp,%ebp
80104e29:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e2c:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104e33:	e8 53 05 00 00       	call   8010538b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e38:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104e3f:	eb 44                	jmp    80104e85 <kill+0x5f>
    if(p->pid == pid){
80104e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e44:	8b 40 10             	mov    0x10(%eax),%eax
80104e47:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e4a:	75 32                	jne    80104e7e <kill+0x58>
      p->killed = 1;
80104e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e59:	8b 40 0c             	mov    0xc(%eax),%eax
80104e5c:	83 f8 02             	cmp    $0x2,%eax
80104e5f:	75 0a                	jne    80104e6b <kill+0x45>
        p->state = RUNNABLE;
80104e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e64:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e6b:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104e72:	e8 7e 05 00 00       	call   801053f5 <release>
      return 0;
80104e77:	b8 00 00 00 00       	mov    $0x0,%eax
80104e7c:	eb 21                	jmp    80104e9f <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e7e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104e85:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
80104e8c:	72 b3                	jb     80104e41 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104e8e:	c7 04 24 20 52 11 80 	movl   $0x80115220,(%esp)
80104e95:	e8 5b 05 00 00       	call   801053f5 <release>
  return -1;
80104e9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e9f:	c9                   	leave  
80104ea0:	c3                   	ret    

80104ea1 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ea1:	55                   	push   %ebp
80104ea2:	89 e5                	mov    %esp,%ebp
80104ea4:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea7:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
80104eae:	e9 1e 01 00 00       	jmp    80104fd1 <procdump+0x130>
    if(p->state == UNUSED)
80104eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb6:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb9:	85 c0                	test   %eax,%eax
80104ebb:	75 05                	jne    80104ec2 <procdump+0x21>
      continue;
80104ebd:	e9 08 01 00 00       	jmp    80104fca <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec8:	83 f8 05             	cmp    $0x5,%eax
80104ecb:	77 23                	ja     80104ef0 <procdump+0x4f>
80104ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed3:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104eda:	85 c0                	test   %eax,%eax
80104edc:	74 12                	je     80104ef0 <procdump+0x4f>
      state = states[p->state];
80104ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee4:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104eeb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104eee:	eb 07                	jmp    80104ef7 <procdump+0x56>
    else
      state = "???";
80104ef0:	c7 45 ec 32 99 10 80 	movl   $0x80109932,-0x14(%ebp)

    if(p->cont == NULL){
80104ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104efa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f00:	85 c0                	test   %eax,%eax
80104f02:	75 29                	jne    80104f2d <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f07:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0d:	8b 40 10             	mov    0x10(%eax),%eax
80104f10:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f14:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f17:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f1f:	c7 04 24 36 99 10 80 	movl   $0x80109936,(%esp)
80104f26:	e8 96 b4 ff ff       	call   801003c1 <cprintf>
80104f2b:	eb 37                	jmp    80104f64 <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f30:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f36:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f3c:	8d 48 18             	lea    0x18(%eax),%ecx
80104f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f42:	8b 40 10             	mov    0x10(%eax),%eax
80104f45:	89 54 24 10          	mov    %edx,0x10(%esp)
80104f49:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f50:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104f54:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f58:	c7 04 24 44 99 10 80 	movl   $0x80109944,(%esp)
80104f5f:	e8 5d b4 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80104f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f67:	8b 40 0c             	mov    0xc(%eax),%eax
80104f6a:	83 f8 02             	cmp    $0x2,%eax
80104f6d:	75 4f                	jne    80104fbe <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f72:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f75:	8b 40 0c             	mov    0xc(%eax),%eax
80104f78:	83 c0 08             	add    $0x8,%eax
80104f7b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f82:	89 04 24             	mov    %eax,(%esp)
80104f85:	e8 b8 04 00 00       	call   80105442 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f91:	eb 1a                	jmp    80104fad <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f96:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f9e:	c7 04 24 50 99 10 80 	movl   $0x80109950,(%esp)
80104fa5:	e8 17 b4 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104faa:	ff 45 f4             	incl   -0xc(%ebp)
80104fad:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fb1:	7f 0b                	jg     80104fbe <procdump+0x11d>
80104fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fba:	85 c0                	test   %eax,%eax
80104fbc:	75 d5                	jne    80104f93 <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104fbe:	c7 04 24 54 99 10 80 	movl   $0x80109954,(%esp)
80104fc5:	e8 f7 b3 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];
  // cprintf("In procdump\n.");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fca:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104fd1:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80104fd8:	0f 82 d5 fe ff ff    	jb     80104eb3 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fde:	c9                   	leave  
80104fdf:	c3                   	ret    

80104fe0 <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  // cprintf("In procdump\n.");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe6:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80104fed:	eb 37                	jmp    80105026 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
80104fef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff2:	8d 50 18             	lea    0x18(%eax),%edx
80104ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104ffe:	83 c0 18             	add    $0x18,%eax
80105001:	89 54 24 04          	mov    %edx,0x4(%esp)
80105005:	89 04 24             	mov    %eax,(%esp)
80105008:	e8 03 fa ff ff       	call   80104a10 <strcmp1>
8010500d:	85 c0                	test   %eax,%eax
8010500f:	75 0e                	jne    8010501f <cstop_container_helper+0x3f>
      kill(p->pid);
80105011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105014:	8b 40 10             	mov    0x10(%eax),%eax
80105017:	89 04 24             	mov    %eax,(%esp)
8010501a:	e8 07 fe ff ff       	call   80104e26 <kill>

void cstop_container_helper(struct container* cont){

  struct proc *p;
  // cprintf("In procdump\n.");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010501f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80105026:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
8010502d:	72 c0                	jb     80104fef <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
8010502f:	8b 45 08             	mov    0x8(%ebp),%eax
80105032:	83 c0 18             	add    $0x18,%eax
80105035:	89 04 24             	mov    %eax,(%esp)
80105038:	e8 b6 3e 00 00       	call   80108ef3 <find>
8010503d:	89 04 24             	mov    %eax,(%esp)
80105040:	e8 8e 43 00 00       	call   801093d3 <container_reset>
}
80105045:	c9                   	leave  
80105046:	c3                   	ret    

80105047 <cstop_helper>:

void cstop_helper(char* name){
80105047:	55                   	push   %ebp
80105048:	89 e5                	mov    %esp,%ebp
8010504a:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010504d:	c7 45 f4 54 52 11 80 	movl   $0x80115254,-0xc(%ebp)
80105054:	eb 69                	jmp    801050bf <cstop_helper+0x78>

    if(p->cont == NULL){
80105056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105059:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010505f:	85 c0                	test   %eax,%eax
80105061:	75 02                	jne    80105065 <cstop_helper+0x1e>
      continue;
80105063:	eb 53                	jmp    801050b8 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
80105065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105068:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010506e:	8d 50 18             	lea    0x18(%eax),%edx
80105071:	8b 45 08             	mov    0x8(%ebp),%eax
80105074:	89 44 24 04          	mov    %eax,0x4(%esp)
80105078:	89 14 24             	mov    %edx,(%esp)
8010507b:	e8 90 f9 ff ff       	call   80104a10 <strcmp1>
80105080:	85 c0                	test   %eax,%eax
80105082:	75 34                	jne    801050b8 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80105084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105087:	8b 40 10             	mov    0x10(%eax),%eax
8010508a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010508d:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
80105093:	83 c2 18             	add    $0x18,%edx
80105096:	89 44 24 08          	mov    %eax,0x8(%esp)
8010509a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010509e:	c7 04 24 58 99 10 80 	movl   $0x80109958,(%esp)
801050a5:	e8 17 b3 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
801050aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ad:	8b 40 10             	mov    0x10(%eax),%eax
801050b0:	89 04 24             	mov    %eax,(%esp)
801050b3:	e8 6e fd ff ff       	call   80104e26 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050b8:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801050bf:	81 7d f4 54 73 11 80 	cmpl   $0x80117354,-0xc(%ebp)
801050c6:	72 8e                	jb     80105056 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
801050c8:	8b 45 08             	mov    0x8(%ebp),%eax
801050cb:	89 04 24             	mov    %eax,(%esp)
801050ce:	e8 20 3e 00 00       	call   80108ef3 <find>
801050d3:	89 04 24             	mov    %eax,(%esp)
801050d6:	e8 f8 42 00 00       	call   801093d3 <container_reset>
}
801050db:	c9                   	leave  
801050dc:	c3                   	ret    

801050dd <c_procdump>:
//   return os;
// }

void
c_procdump(char* name)
{
801050dd:	55                   	push   %ebp
801050de:	89 e5                	mov    %esp,%ebp
801050e0:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050e3:	c7 45 f0 54 52 11 80 	movl   $0x80115254,-0x10(%ebp)
801050ea:	e9 0f 01 00 00       	jmp    801051fe <c_procdump+0x121>

    // if(p->cont == NULL){
    //   cprintf("p_cont is null in %s.\n", name);
    // }
    if(p->state == UNUSED || p->cont == NULL)
801050ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f2:	8b 40 0c             	mov    0xc(%eax),%eax
801050f5:	85 c0                	test   %eax,%eax
801050f7:	74 0d                	je     80105106 <c_procdump+0x29>
801050f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050fc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105102:	85 c0                	test   %eax,%eax
80105104:	75 05                	jne    8010510b <c_procdump+0x2e>
      continue;
80105106:	e9 ec 00 00 00       	jmp    801051f7 <c_procdump+0x11a>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010510b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510e:	8b 40 0c             	mov    0xc(%eax),%eax
80105111:	83 f8 05             	cmp    $0x5,%eax
80105114:	77 23                	ja     80105139 <c_procdump+0x5c>
80105116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105119:	8b 40 0c             	mov    0xc(%eax),%eax
8010511c:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105123:	85 c0                	test   %eax,%eax
80105125:	74 12                	je     80105139 <c_procdump+0x5c>
      state = states[p->state];
80105127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010512a:	8b 40 0c             	mov    0xc(%eax),%eax
8010512d:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105134:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105137:	eb 07                	jmp    80105140 <c_procdump+0x63>
    else
      state = "???";
80105139:	c7 45 ec 32 99 10 80 	movl   $0x80109932,-0x14(%ebp)

    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
80105140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105143:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105149:	8d 50 18             	lea    0x18(%eax),%edx
8010514c:	8b 45 08             	mov    0x8(%ebp),%eax
8010514f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105153:	89 14 24             	mov    %edx,(%esp)
80105156:	e8 b5 f8 ff ff       	call   80104a10 <strcmp1>
8010515b:	85 c0                	test   %eax,%eax
8010515d:	0f 85 94 00 00 00    	jne    801051f7 <c_procdump+0x11a>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
80105163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105166:	8d 50 6c             	lea    0x6c(%eax),%edx
80105169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010516c:	8b 40 10             	mov    0x10(%eax),%eax
8010516f:	89 54 24 10          	mov    %edx,0x10(%esp)
80105173:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105176:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010517a:	8b 55 08             	mov    0x8(%ebp),%edx
8010517d:	89 54 24 08          	mov    %edx,0x8(%esp)
80105181:	89 44 24 04          	mov    %eax,0x4(%esp)
80105185:	c7 04 24 44 99 10 80 	movl   $0x80109944,(%esp)
8010518c:	e8 30 b2 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
80105191:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105194:	8b 40 0c             	mov    0xc(%eax),%eax
80105197:	83 f8 02             	cmp    $0x2,%eax
8010519a:	75 4f                	jne    801051eb <c_procdump+0x10e>
        getcallerpcs((uint*)p->context->ebp+2, pc);
8010519c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010519f:	8b 40 1c             	mov    0x1c(%eax),%eax
801051a2:	8b 40 0c             	mov    0xc(%eax),%eax
801051a5:	83 c0 08             	add    $0x8,%eax
801051a8:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801051ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801051af:	89 04 24             	mov    %eax,(%esp)
801051b2:	e8 8b 02 00 00       	call   80105442 <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
801051b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051be:	eb 1a                	jmp    801051da <c_procdump+0xfd>
          cprintf(" %p", pc[i]);
801051c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801051cb:	c7 04 24 50 99 10 80 	movl   $0x80109950,(%esp)
801051d2:	e8 ea b1 ff ff       	call   801003c1 <cprintf>
    // cprintf("%s.\n", p->name);
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
801051d7:	ff 45 f4             	incl   -0xc(%ebp)
801051da:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801051de:	7f 0b                	jg     801051eb <c_procdump+0x10e>
801051e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051e7:	85 c0                	test   %eax,%eax
801051e9:	75 d5                	jne    801051c0 <c_procdump+0xe3>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
801051eb:	c7 04 24 54 99 10 80 	movl   $0x80109954,(%esp)
801051f2:	e8 ca b1 ff ff       	call   801003c1 <cprintf>
  uint pc[10];

  // cprintf("In c_procdump.\n");


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051f7:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
801051fe:	81 7d f0 54 73 11 80 	cmpl   $0x80117354,-0x10(%ebp)
80105205:	0f 82 e4 fe ff ff    	jb     801050ef <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
8010520b:	c9                   	leave  
8010520c:	c3                   	ret    

8010520d <cont_disk>:

void
cont_disk(void){
8010520d:	55                   	push   %ebp
8010520e:	89 e5                	mov    %esp,%ebp
  
}
80105210:	5d                   	pop    %ebp
80105211:	c3                   	ret    

80105212 <initp>:


struct proc* initp(void){
80105212:	55                   	push   %ebp
80105213:	89 e5                	mov    %esp,%ebp
  return initproc;
80105215:	a1 00 c9 10 80       	mov    0x8010c900,%eax
}
8010521a:	5d                   	pop    %ebp
8010521b:	c3                   	ret    

8010521c <c_proc>:

struct proc* c_proc(void){
8010521c:	55                   	push   %ebp
8010521d:	89 e5                	mov    %esp,%ebp
8010521f:	83 ec 08             	sub    $0x8,%esp
  return myproc();
80105222:	e8 4c f2 ff ff       	call   80104473 <myproc>
}
80105227:	c9                   	leave  
80105228:	c3                   	ret    
80105229:	00 00                	add    %al,(%eax)
	...

8010522c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010522c:	55                   	push   %ebp
8010522d:	89 e5                	mov    %esp,%ebp
8010522f:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	83 c0 04             	add    $0x4,%eax
80105238:	c7 44 24 04 a2 99 10 	movl   $0x801099a2,0x4(%esp)
8010523f:	80 
80105240:	89 04 24             	mov    %eax,(%esp)
80105243:	e8 22 01 00 00       	call   8010536a <initlock>
  lk->name = name;
80105248:	8b 45 08             	mov    0x8(%ebp),%eax
8010524b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010524e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105251:	8b 45 08             	mov    0x8(%ebp),%eax
80105254:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010525a:	8b 45 08             	mov    0x8(%ebp),%eax
8010525d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105264:	c9                   	leave  
80105265:	c3                   	ret    

80105266 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105266:	55                   	push   %ebp
80105267:	89 e5                	mov    %esp,%ebp
80105269:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010526c:	8b 45 08             	mov    0x8(%ebp),%eax
8010526f:	83 c0 04             	add    $0x4,%eax
80105272:	89 04 24             	mov    %eax,(%esp)
80105275:	e8 11 01 00 00       	call   8010538b <acquire>
  while (lk->locked) {
8010527a:	eb 15                	jmp    80105291 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
8010527c:	8b 45 08             	mov    0x8(%ebp),%eax
8010527f:	83 c0 04             	add    $0x4,%eax
80105282:	89 44 24 04          	mov    %eax,0x4(%esp)
80105286:	8b 45 08             	mov    0x8(%ebp),%eax
80105289:	89 04 24             	mov    %eax,(%esp)
8010528c:	e8 93 fa ff ff       	call   80104d24 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105291:	8b 45 08             	mov    0x8(%ebp),%eax
80105294:	8b 00                	mov    (%eax),%eax
80105296:	85 c0                	test   %eax,%eax
80105298:	75 e2                	jne    8010527c <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010529a:	8b 45 08             	mov    0x8(%ebp),%eax
8010529d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801052a3:	e8 cb f1 ff ff       	call   80104473 <myproc>
801052a8:	8b 50 10             	mov    0x10(%eax),%edx
801052ab:	8b 45 08             	mov    0x8(%ebp),%eax
801052ae:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801052b1:	8b 45 08             	mov    0x8(%ebp),%eax
801052b4:	83 c0 04             	add    $0x4,%eax
801052b7:	89 04 24             	mov    %eax,(%esp)
801052ba:	e8 36 01 00 00       	call   801053f5 <release>
}
801052bf:	c9                   	leave  
801052c0:	c3                   	ret    

801052c1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801052c1:	55                   	push   %ebp
801052c2:	89 e5                	mov    %esp,%ebp
801052c4:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801052c7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ca:	83 c0 04             	add    $0x4,%eax
801052cd:	89 04 24             	mov    %eax,(%esp)
801052d0:	e8 b6 00 00 00       	call   8010538b <acquire>
  lk->locked = 0;
801052d5:	8b 45 08             	mov    0x8(%ebp),%eax
801052d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801052de:	8b 45 08             	mov    0x8(%ebp),%eax
801052e1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801052e8:	8b 45 08             	mov    0x8(%ebp),%eax
801052eb:	89 04 24             	mov    %eax,(%esp)
801052ee:	e8 08 fb ff ff       	call   80104dfb <wakeup>
  release(&lk->lk);
801052f3:	8b 45 08             	mov    0x8(%ebp),%eax
801052f6:	83 c0 04             	add    $0x4,%eax
801052f9:	89 04 24             	mov    %eax,(%esp)
801052fc:	e8 f4 00 00 00       	call   801053f5 <release>
}
80105301:	c9                   	leave  
80105302:	c3                   	ret    

80105303 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105303:	55                   	push   %ebp
80105304:	89 e5                	mov    %esp,%ebp
80105306:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105309:	8b 45 08             	mov    0x8(%ebp),%eax
8010530c:	83 c0 04             	add    $0x4,%eax
8010530f:	89 04 24             	mov    %eax,(%esp)
80105312:	e8 74 00 00 00       	call   8010538b <acquire>
  r = lk->locked;
80105317:	8b 45 08             	mov    0x8(%ebp),%eax
8010531a:	8b 00                	mov    (%eax),%eax
8010531c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010531f:	8b 45 08             	mov    0x8(%ebp),%eax
80105322:	83 c0 04             	add    $0x4,%eax
80105325:	89 04 24             	mov    %eax,(%esp)
80105328:	e8 c8 00 00 00       	call   801053f5 <release>
  return r;
8010532d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105330:	c9                   	leave  
80105331:	c3                   	ret    
	...

80105334 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105334:	55                   	push   %ebp
80105335:	89 e5                	mov    %esp,%ebp
80105337:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010533a:	9c                   	pushf  
8010533b:	58                   	pop    %eax
8010533c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010533f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105342:	c9                   	leave  
80105343:	c3                   	ret    

80105344 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105344:	55                   	push   %ebp
80105345:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105347:	fa                   	cli    
}
80105348:	5d                   	pop    %ebp
80105349:	c3                   	ret    

8010534a <sti>:

static inline void
sti(void)
{
8010534a:	55                   	push   %ebp
8010534b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010534d:	fb                   	sti    
}
8010534e:	5d                   	pop    %ebp
8010534f:	c3                   	ret    

80105350 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105350:	55                   	push   %ebp
80105351:	89 e5                	mov    %esp,%ebp
80105353:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105356:	8b 55 08             	mov    0x8(%ebp),%edx
80105359:	8b 45 0c             	mov    0xc(%ebp),%eax
8010535c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010535f:	f0 87 02             	lock xchg %eax,(%edx)
80105362:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105365:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105368:	c9                   	leave  
80105369:	c3                   	ret    

8010536a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010536a:	55                   	push   %ebp
8010536b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010536d:	8b 45 08             	mov    0x8(%ebp),%eax
80105370:	8b 55 0c             	mov    0xc(%ebp),%edx
80105373:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105376:	8b 45 08             	mov    0x8(%ebp),%eax
80105379:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010537f:	8b 45 08             	mov    0x8(%ebp),%eax
80105382:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105389:	5d                   	pop    %ebp
8010538a:	c3                   	ret    

8010538b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010538b:	55                   	push   %ebp
8010538c:	89 e5                	mov    %esp,%ebp
8010538e:	53                   	push   %ebx
8010538f:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105392:	e8 53 01 00 00       	call   801054ea <pushcli>
  if(holding(lk))
80105397:	8b 45 08             	mov    0x8(%ebp),%eax
8010539a:	89 04 24             	mov    %eax,(%esp)
8010539d:	e8 17 01 00 00       	call   801054b9 <holding>
801053a2:	85 c0                	test   %eax,%eax
801053a4:	74 0c                	je     801053b2 <acquire+0x27>
    panic("acquire");
801053a6:	c7 04 24 ad 99 10 80 	movl   $0x801099ad,(%esp)
801053ad:	e8 a2 b1 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801053b2:	90                   	nop
801053b3:	8b 45 08             	mov    0x8(%ebp),%eax
801053b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801053bd:	00 
801053be:	89 04 24             	mov    %eax,(%esp)
801053c1:	e8 8a ff ff ff       	call   80105350 <xchg>
801053c6:	85 c0                	test   %eax,%eax
801053c8:	75 e9                	jne    801053b3 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801053ca:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801053cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
801053d2:	e8 18 f0 ff ff       	call   801043ef <mycpu>
801053d7:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801053da:	8b 45 08             	mov    0x8(%ebp),%eax
801053dd:	83 c0 0c             	add    $0xc,%eax
801053e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801053e4:	8d 45 08             	lea    0x8(%ebp),%eax
801053e7:	89 04 24             	mov    %eax,(%esp)
801053ea:	e8 53 00 00 00       	call   80105442 <getcallerpcs>
}
801053ef:	83 c4 14             	add    $0x14,%esp
801053f2:	5b                   	pop    %ebx
801053f3:	5d                   	pop    %ebp
801053f4:	c3                   	ret    

801053f5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053f5:	55                   	push   %ebp
801053f6:	89 e5                	mov    %esp,%ebp
801053f8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801053fb:	8b 45 08             	mov    0x8(%ebp),%eax
801053fe:	89 04 24             	mov    %eax,(%esp)
80105401:	e8 b3 00 00 00       	call   801054b9 <holding>
80105406:	85 c0                	test   %eax,%eax
80105408:	75 0c                	jne    80105416 <release+0x21>
    panic("release");
8010540a:	c7 04 24 b5 99 10 80 	movl   $0x801099b5,(%esp)
80105411:	e8 3e b1 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80105416:	8b 45 08             	mov    0x8(%ebp),%eax
80105419:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105420:	8b 45 08             	mov    0x8(%ebp),%eax
80105423:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010542a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010542f:	8b 45 08             	mov    0x8(%ebp),%eax
80105432:	8b 55 08             	mov    0x8(%ebp),%edx
80105435:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010543b:	e8 f4 00 00 00       	call   80105534 <popcli>
}
80105440:	c9                   	leave  
80105441:	c3                   	ret    

80105442 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105442:	55                   	push   %ebp
80105443:	89 e5                	mov    %esp,%ebp
80105445:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105448:	8b 45 08             	mov    0x8(%ebp),%eax
8010544b:	83 e8 08             	sub    $0x8,%eax
8010544e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105451:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105458:	eb 37                	jmp    80105491 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010545a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010545e:	74 37                	je     80105497 <getcallerpcs+0x55>
80105460:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105467:	76 2e                	jbe    80105497 <getcallerpcs+0x55>
80105469:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010546d:	74 28                	je     80105497 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010546f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105472:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105479:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547c:	01 c2                	add    %eax,%edx
8010547e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105481:	8b 40 04             	mov    0x4(%eax),%eax
80105484:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105486:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105489:	8b 00                	mov    (%eax),%eax
8010548b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010548e:	ff 45 f8             	incl   -0x8(%ebp)
80105491:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105495:	7e c3                	jle    8010545a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105497:	eb 18                	jmp    801054b1 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105499:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010549c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a6:	01 d0                	add    %edx,%eax
801054a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054ae:	ff 45 f8             	incl   -0x8(%ebp)
801054b1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054b5:	7e e2                	jle    80105499 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801054b7:	c9                   	leave  
801054b8:	c3                   	ret    

801054b9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801054b9:	55                   	push   %ebp
801054ba:	89 e5                	mov    %esp,%ebp
801054bc:	53                   	push   %ebx
801054bd:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801054c0:	8b 45 08             	mov    0x8(%ebp),%eax
801054c3:	8b 00                	mov    (%eax),%eax
801054c5:	85 c0                	test   %eax,%eax
801054c7:	74 16                	je     801054df <holding+0x26>
801054c9:	8b 45 08             	mov    0x8(%ebp),%eax
801054cc:	8b 58 08             	mov    0x8(%eax),%ebx
801054cf:	e8 1b ef ff ff       	call   801043ef <mycpu>
801054d4:	39 c3                	cmp    %eax,%ebx
801054d6:	75 07                	jne    801054df <holding+0x26>
801054d8:	b8 01 00 00 00       	mov    $0x1,%eax
801054dd:	eb 05                	jmp    801054e4 <holding+0x2b>
801054df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054e4:	83 c4 04             	add    $0x4,%esp
801054e7:	5b                   	pop    %ebx
801054e8:	5d                   	pop    %ebp
801054e9:	c3                   	ret    

801054ea <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054ea:	55                   	push   %ebp
801054eb:	89 e5                	mov    %esp,%ebp
801054ed:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801054f0:	e8 3f fe ff ff       	call   80105334 <readeflags>
801054f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801054f8:	e8 47 fe ff ff       	call   80105344 <cli>
  if(mycpu()->ncli == 0)
801054fd:	e8 ed ee ff ff       	call   801043ef <mycpu>
80105502:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105508:	85 c0                	test   %eax,%eax
8010550a:	75 14                	jne    80105520 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010550c:	e8 de ee ff ff       	call   801043ef <mycpu>
80105511:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105514:	81 e2 00 02 00 00    	and    $0x200,%edx
8010551a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105520:	e8 ca ee ff ff       	call   801043ef <mycpu>
80105525:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010552b:	42                   	inc    %edx
8010552c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105532:	c9                   	leave  
80105533:	c3                   	ret    

80105534 <popcli>:

void
popcli(void)
{
80105534:	55                   	push   %ebp
80105535:	89 e5                	mov    %esp,%ebp
80105537:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010553a:	e8 f5 fd ff ff       	call   80105334 <readeflags>
8010553f:	25 00 02 00 00       	and    $0x200,%eax
80105544:	85 c0                	test   %eax,%eax
80105546:	74 0c                	je     80105554 <popcli+0x20>
    panic("popcli - interruptible");
80105548:	c7 04 24 bd 99 10 80 	movl   $0x801099bd,(%esp)
8010554f:	e8 00 b0 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105554:	e8 96 ee ff ff       	call   801043ef <mycpu>
80105559:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010555f:	4a                   	dec    %edx
80105560:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105566:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010556c:	85 c0                	test   %eax,%eax
8010556e:	79 0c                	jns    8010557c <popcli+0x48>
    panic("popcli");
80105570:	c7 04 24 d4 99 10 80 	movl   $0x801099d4,(%esp)
80105577:	e8 d8 af ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010557c:	e8 6e ee ff ff       	call   801043ef <mycpu>
80105581:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105587:	85 c0                	test   %eax,%eax
80105589:	75 14                	jne    8010559f <popcli+0x6b>
8010558b:	e8 5f ee ff ff       	call   801043ef <mycpu>
80105590:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105596:	85 c0                	test   %eax,%eax
80105598:	74 05                	je     8010559f <popcli+0x6b>
    sti();
8010559a:	e8 ab fd ff ff       	call   8010534a <sti>
}
8010559f:	c9                   	leave  
801055a0:	c3                   	ret    
801055a1:	00 00                	add    %al,(%eax)
	...

801055a4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801055a4:	55                   	push   %ebp
801055a5:	89 e5                	mov    %esp,%ebp
801055a7:	57                   	push   %edi
801055a8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055ac:	8b 55 10             	mov    0x10(%ebp),%edx
801055af:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b2:	89 cb                	mov    %ecx,%ebx
801055b4:	89 df                	mov    %ebx,%edi
801055b6:	89 d1                	mov    %edx,%ecx
801055b8:	fc                   	cld    
801055b9:	f3 aa                	rep stos %al,%es:(%edi)
801055bb:	89 ca                	mov    %ecx,%edx
801055bd:	89 fb                	mov    %edi,%ebx
801055bf:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055c2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055c5:	5b                   	pop    %ebx
801055c6:	5f                   	pop    %edi
801055c7:	5d                   	pop    %ebp
801055c8:	c3                   	ret    

801055c9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801055c9:	55                   	push   %ebp
801055ca:	89 e5                	mov    %esp,%ebp
801055cc:	57                   	push   %edi
801055cd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055d1:	8b 55 10             	mov    0x10(%ebp),%edx
801055d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d7:	89 cb                	mov    %ecx,%ebx
801055d9:	89 df                	mov    %ebx,%edi
801055db:	89 d1                	mov    %edx,%ecx
801055dd:	fc                   	cld    
801055de:	f3 ab                	rep stos %eax,%es:(%edi)
801055e0:	89 ca                	mov    %ecx,%edx
801055e2:	89 fb                	mov    %edi,%ebx
801055e4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055e7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055ea:	5b                   	pop    %ebx
801055eb:	5f                   	pop    %edi
801055ec:	5d                   	pop    %ebp
801055ed:	c3                   	ret    

801055ee <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055ee:	55                   	push   %ebp
801055ef:	89 e5                	mov    %esp,%ebp
801055f1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801055f4:	8b 45 08             	mov    0x8(%ebp),%eax
801055f7:	83 e0 03             	and    $0x3,%eax
801055fa:	85 c0                	test   %eax,%eax
801055fc:	75 49                	jne    80105647 <memset+0x59>
801055fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105601:	83 e0 03             	and    $0x3,%eax
80105604:	85 c0                	test   %eax,%eax
80105606:	75 3f                	jne    80105647 <memset+0x59>
    c &= 0xFF;
80105608:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010560f:	8b 45 10             	mov    0x10(%ebp),%eax
80105612:	c1 e8 02             	shr    $0x2,%eax
80105615:	89 c2                	mov    %eax,%edx
80105617:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561a:	c1 e0 18             	shl    $0x18,%eax
8010561d:	89 c1                	mov    %eax,%ecx
8010561f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105622:	c1 e0 10             	shl    $0x10,%eax
80105625:	09 c1                	or     %eax,%ecx
80105627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562a:	c1 e0 08             	shl    $0x8,%eax
8010562d:	09 c8                	or     %ecx,%eax
8010562f:	0b 45 0c             	or     0xc(%ebp),%eax
80105632:	89 54 24 08          	mov    %edx,0x8(%esp)
80105636:	89 44 24 04          	mov    %eax,0x4(%esp)
8010563a:	8b 45 08             	mov    0x8(%ebp),%eax
8010563d:	89 04 24             	mov    %eax,(%esp)
80105640:	e8 84 ff ff ff       	call   801055c9 <stosl>
80105645:	eb 19                	jmp    80105660 <memset+0x72>
  } else
    stosb(dst, c, n);
80105647:	8b 45 10             	mov    0x10(%ebp),%eax
8010564a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010564e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105651:	89 44 24 04          	mov    %eax,0x4(%esp)
80105655:	8b 45 08             	mov    0x8(%ebp),%eax
80105658:	89 04 24             	mov    %eax,(%esp)
8010565b:	e8 44 ff ff ff       	call   801055a4 <stosb>
  return dst;
80105660:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105663:	c9                   	leave  
80105664:	c3                   	ret    

80105665 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105665:	55                   	push   %ebp
80105666:	89 e5                	mov    %esp,%ebp
80105668:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010566b:	8b 45 08             	mov    0x8(%ebp),%eax
8010566e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105671:	8b 45 0c             	mov    0xc(%ebp),%eax
80105674:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105677:	eb 2a                	jmp    801056a3 <memcmp+0x3e>
    if(*s1 != *s2)
80105679:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010567c:	8a 10                	mov    (%eax),%dl
8010567e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105681:	8a 00                	mov    (%eax),%al
80105683:	38 c2                	cmp    %al,%dl
80105685:	74 16                	je     8010569d <memcmp+0x38>
      return *s1 - *s2;
80105687:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010568a:	8a 00                	mov    (%eax),%al
8010568c:	0f b6 d0             	movzbl %al,%edx
8010568f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105692:	8a 00                	mov    (%eax),%al
80105694:	0f b6 c0             	movzbl %al,%eax
80105697:	29 c2                	sub    %eax,%edx
80105699:	89 d0                	mov    %edx,%eax
8010569b:	eb 18                	jmp    801056b5 <memcmp+0x50>
    s1++, s2++;
8010569d:	ff 45 fc             	incl   -0x4(%ebp)
801056a0:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801056a3:	8b 45 10             	mov    0x10(%ebp),%eax
801056a6:	8d 50 ff             	lea    -0x1(%eax),%edx
801056a9:	89 55 10             	mov    %edx,0x10(%ebp)
801056ac:	85 c0                	test   %eax,%eax
801056ae:	75 c9                	jne    80105679 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801056b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056b5:	c9                   	leave  
801056b6:	c3                   	ret    

801056b7 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056c3:	8b 45 08             	mov    0x8(%ebp),%eax
801056c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056cf:	73 3a                	jae    8010570b <memmove+0x54>
801056d1:	8b 45 10             	mov    0x10(%ebp),%eax
801056d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056d7:	01 d0                	add    %edx,%eax
801056d9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056dc:	76 2d                	jbe    8010570b <memmove+0x54>
    s += n;
801056de:	8b 45 10             	mov    0x10(%ebp),%eax
801056e1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056e4:	8b 45 10             	mov    0x10(%ebp),%eax
801056e7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056ea:	eb 10                	jmp    801056fc <memmove+0x45>
      *--d = *--s;
801056ec:	ff 4d f8             	decl   -0x8(%ebp)
801056ef:	ff 4d fc             	decl   -0x4(%ebp)
801056f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056f5:	8a 10                	mov    (%eax),%dl
801056f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056fa:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801056fc:	8b 45 10             	mov    0x10(%ebp),%eax
801056ff:	8d 50 ff             	lea    -0x1(%eax),%edx
80105702:	89 55 10             	mov    %edx,0x10(%ebp)
80105705:	85 c0                	test   %eax,%eax
80105707:	75 e3                	jne    801056ec <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105709:	eb 25                	jmp    80105730 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010570b:	eb 16                	jmp    80105723 <memmove+0x6c>
      *d++ = *s++;
8010570d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105710:	8d 50 01             	lea    0x1(%eax),%edx
80105713:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105716:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105719:	8d 4a 01             	lea    0x1(%edx),%ecx
8010571c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010571f:	8a 12                	mov    (%edx),%dl
80105721:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105723:	8b 45 10             	mov    0x10(%ebp),%eax
80105726:	8d 50 ff             	lea    -0x1(%eax),%edx
80105729:	89 55 10             	mov    %edx,0x10(%ebp)
8010572c:	85 c0                	test   %eax,%eax
8010572e:	75 dd                	jne    8010570d <memmove+0x56>
      *d++ = *s++;

  return dst;
80105730:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105733:	c9                   	leave  
80105734:	c3                   	ret    

80105735 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105735:	55                   	push   %ebp
80105736:	89 e5                	mov    %esp,%ebp
80105738:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010573b:	8b 45 10             	mov    0x10(%ebp),%eax
8010573e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105742:	8b 45 0c             	mov    0xc(%ebp),%eax
80105745:	89 44 24 04          	mov    %eax,0x4(%esp)
80105749:	8b 45 08             	mov    0x8(%ebp),%eax
8010574c:	89 04 24             	mov    %eax,(%esp)
8010574f:	e8 63 ff ff ff       	call   801056b7 <memmove>
}
80105754:	c9                   	leave  
80105755:	c3                   	ret    

80105756 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105756:	55                   	push   %ebp
80105757:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105759:	eb 09                	jmp    80105764 <strncmp+0xe>
    n--, p++, q++;
8010575b:	ff 4d 10             	decl   0x10(%ebp)
8010575e:	ff 45 08             	incl   0x8(%ebp)
80105761:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105764:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105768:	74 17                	je     80105781 <strncmp+0x2b>
8010576a:	8b 45 08             	mov    0x8(%ebp),%eax
8010576d:	8a 00                	mov    (%eax),%al
8010576f:	84 c0                	test   %al,%al
80105771:	74 0e                	je     80105781 <strncmp+0x2b>
80105773:	8b 45 08             	mov    0x8(%ebp),%eax
80105776:	8a 10                	mov    (%eax),%dl
80105778:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577b:	8a 00                	mov    (%eax),%al
8010577d:	38 c2                	cmp    %al,%dl
8010577f:	74 da                	je     8010575b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105781:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105785:	75 07                	jne    8010578e <strncmp+0x38>
    return 0;
80105787:	b8 00 00 00 00       	mov    $0x0,%eax
8010578c:	eb 14                	jmp    801057a2 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010578e:	8b 45 08             	mov    0x8(%ebp),%eax
80105791:	8a 00                	mov    (%eax),%al
80105793:	0f b6 d0             	movzbl %al,%edx
80105796:	8b 45 0c             	mov    0xc(%ebp),%eax
80105799:	8a 00                	mov    (%eax),%al
8010579b:	0f b6 c0             	movzbl %al,%eax
8010579e:	29 c2                	sub    %eax,%edx
801057a0:	89 d0                	mov    %edx,%eax
}
801057a2:	5d                   	pop    %ebp
801057a3:	c3                   	ret    

801057a4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057a4:	55                   	push   %ebp
801057a5:	89 e5                	mov    %esp,%ebp
801057a7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057aa:	8b 45 08             	mov    0x8(%ebp),%eax
801057ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057b0:	90                   	nop
801057b1:	8b 45 10             	mov    0x10(%ebp),%eax
801057b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801057b7:	89 55 10             	mov    %edx,0x10(%ebp)
801057ba:	85 c0                	test   %eax,%eax
801057bc:	7e 1c                	jle    801057da <strncpy+0x36>
801057be:	8b 45 08             	mov    0x8(%ebp),%eax
801057c1:	8d 50 01             	lea    0x1(%eax),%edx
801057c4:	89 55 08             	mov    %edx,0x8(%ebp)
801057c7:	8b 55 0c             	mov    0xc(%ebp),%edx
801057ca:	8d 4a 01             	lea    0x1(%edx),%ecx
801057cd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801057d0:	8a 12                	mov    (%edx),%dl
801057d2:	88 10                	mov    %dl,(%eax)
801057d4:	8a 00                	mov    (%eax),%al
801057d6:	84 c0                	test   %al,%al
801057d8:	75 d7                	jne    801057b1 <strncpy+0xd>
    ;
  while(n-- > 0)
801057da:	eb 0c                	jmp    801057e8 <strncpy+0x44>
    *s++ = 0;
801057dc:	8b 45 08             	mov    0x8(%ebp),%eax
801057df:	8d 50 01             	lea    0x1(%eax),%edx
801057e2:	89 55 08             	mov    %edx,0x8(%ebp)
801057e5:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801057e8:	8b 45 10             	mov    0x10(%ebp),%eax
801057eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801057ee:	89 55 10             	mov    %edx,0x10(%ebp)
801057f1:	85 c0                	test   %eax,%eax
801057f3:	7f e7                	jg     801057dc <strncpy+0x38>
    *s++ = 0;
  return os;
801057f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057f8:	c9                   	leave  
801057f9:	c3                   	ret    

801057fa <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057fa:	55                   	push   %ebp
801057fb:	89 e5                	mov    %esp,%ebp
801057fd:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105800:	8b 45 08             	mov    0x8(%ebp),%eax
80105803:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105806:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010580a:	7f 05                	jg     80105811 <safestrcpy+0x17>
    return os;
8010580c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010580f:	eb 2e                	jmp    8010583f <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105811:	ff 4d 10             	decl   0x10(%ebp)
80105814:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105818:	7e 1c                	jle    80105836 <safestrcpy+0x3c>
8010581a:	8b 45 08             	mov    0x8(%ebp),%eax
8010581d:	8d 50 01             	lea    0x1(%eax),%edx
80105820:	89 55 08             	mov    %edx,0x8(%ebp)
80105823:	8b 55 0c             	mov    0xc(%ebp),%edx
80105826:	8d 4a 01             	lea    0x1(%edx),%ecx
80105829:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010582c:	8a 12                	mov    (%edx),%dl
8010582e:	88 10                	mov    %dl,(%eax)
80105830:	8a 00                	mov    (%eax),%al
80105832:	84 c0                	test   %al,%al
80105834:	75 db                	jne    80105811 <safestrcpy+0x17>
    ;
  *s = 0;
80105836:	8b 45 08             	mov    0x8(%ebp),%eax
80105839:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010583c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010583f:	c9                   	leave  
80105840:	c3                   	ret    

80105841 <strlen>:

int
strlen(const char *s)
{
80105841:	55                   	push   %ebp
80105842:	89 e5                	mov    %esp,%ebp
80105844:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105847:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010584e:	eb 03                	jmp    80105853 <strlen+0x12>
80105850:	ff 45 fc             	incl   -0x4(%ebp)
80105853:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105856:	8b 45 08             	mov    0x8(%ebp),%eax
80105859:	01 d0                	add    %edx,%eax
8010585b:	8a 00                	mov    (%eax),%al
8010585d:	84 c0                	test   %al,%al
8010585f:	75 ef                	jne    80105850 <strlen+0xf>
    ;
  return n;
80105861:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105864:	c9                   	leave  
80105865:	c3                   	ret    
	...

80105868 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105868:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010586c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105870:	55                   	push   %ebp
  pushl %ebx
80105871:	53                   	push   %ebx
  pushl %esi
80105872:	56                   	push   %esi
  pushl %edi
80105873:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105874:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105876:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105878:	5f                   	pop    %edi
  popl %esi
80105879:	5e                   	pop    %esi
  popl %ebx
8010587a:	5b                   	pop    %ebx
  popl %ebp
8010587b:	5d                   	pop    %ebp
  ret
8010587c:	c3                   	ret    
8010587d:	00 00                	add    %al,(%eax)
	...

80105880 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105880:	55                   	push   %ebp
80105881:	89 e5                	mov    %esp,%ebp
80105883:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105886:	e8 e8 eb ff ff       	call   80104473 <myproc>
8010588b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010588e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105891:	8b 00                	mov    (%eax),%eax
80105893:	3b 45 08             	cmp    0x8(%ebp),%eax
80105896:	76 0f                	jbe    801058a7 <fetchint+0x27>
80105898:	8b 45 08             	mov    0x8(%ebp),%eax
8010589b:	8d 50 04             	lea    0x4(%eax),%edx
8010589e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a1:	8b 00                	mov    (%eax),%eax
801058a3:	39 c2                	cmp    %eax,%edx
801058a5:	76 07                	jbe    801058ae <fetchint+0x2e>
    return -1;
801058a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ac:	eb 0f                	jmp    801058bd <fetchint+0x3d>
  *ip = *(int*)(addr);
801058ae:	8b 45 08             	mov    0x8(%ebp),%eax
801058b1:	8b 10                	mov    (%eax),%edx
801058b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b6:	89 10                	mov    %edx,(%eax)
  return 0;
801058b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058bd:	c9                   	leave  
801058be:	c3                   	ret    

801058bf <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058bf:	55                   	push   %ebp
801058c0:	89 e5                	mov    %esp,%ebp
801058c2:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801058c5:	e8 a9 eb ff ff       	call   80104473 <myproc>
801058ca:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801058cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d0:	8b 00                	mov    (%eax),%eax
801058d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801058d5:	77 07                	ja     801058de <fetchstr+0x1f>
    return -1;
801058d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058dc:	eb 41                	jmp    8010591f <fetchstr+0x60>
  *pp = (char*)addr;
801058de:	8b 55 08             	mov    0x8(%ebp),%edx
801058e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e4:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e9:	8b 00                	mov    (%eax),%eax
801058eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f1:	8b 00                	mov    (%eax),%eax
801058f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f6:	eb 1a                	jmp    80105912 <fetchstr+0x53>
    if(*s == 0)
801058f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fb:	8a 00                	mov    (%eax),%al
801058fd:	84 c0                	test   %al,%al
801058ff:	75 0e                	jne    8010590f <fetchstr+0x50>
      return s - *pp;
80105901:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105904:	8b 45 0c             	mov    0xc(%ebp),%eax
80105907:	8b 00                	mov    (%eax),%eax
80105909:	29 c2                	sub    %eax,%edx
8010590b:	89 d0                	mov    %edx,%eax
8010590d:	eb 10                	jmp    8010591f <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
8010590f:	ff 45 f4             	incl   -0xc(%ebp)
80105912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105915:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105918:	72 de                	jb     801058f8 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
8010591a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010591f:	c9                   	leave  
80105920:	c3                   	ret    

80105921 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105921:	55                   	push   %ebp
80105922:	89 e5                	mov    %esp,%ebp
80105924:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105927:	e8 47 eb ff ff       	call   80104473 <myproc>
8010592c:	8b 40 18             	mov    0x18(%eax),%eax
8010592f:	8b 50 44             	mov    0x44(%eax),%edx
80105932:	8b 45 08             	mov    0x8(%ebp),%eax
80105935:	c1 e0 02             	shl    $0x2,%eax
80105938:	01 d0                	add    %edx,%eax
8010593a:	8d 50 04             	lea    0x4(%eax),%edx
8010593d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105940:	89 44 24 04          	mov    %eax,0x4(%esp)
80105944:	89 14 24             	mov    %edx,(%esp)
80105947:	e8 34 ff ff ff       	call   80105880 <fetchint>
}
8010594c:	c9                   	leave  
8010594d:	c3                   	ret    

8010594e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010594e:	55                   	push   %ebp
8010594f:	89 e5                	mov    %esp,%ebp
80105951:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105954:	e8 1a eb ff ff       	call   80104473 <myproc>
80105959:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010595c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010595f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105963:	8b 45 08             	mov    0x8(%ebp),%eax
80105966:	89 04 24             	mov    %eax,(%esp)
80105969:	e8 b3 ff ff ff       	call   80105921 <argint>
8010596e:	85 c0                	test   %eax,%eax
80105970:	79 07                	jns    80105979 <argptr+0x2b>
    return -1;
80105972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105977:	eb 3d                	jmp    801059b6 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105979:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010597d:	78 21                	js     801059a0 <argptr+0x52>
8010597f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105982:	89 c2                	mov    %eax,%edx
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	8b 00                	mov    (%eax),%eax
80105989:	39 c2                	cmp    %eax,%edx
8010598b:	73 13                	jae    801059a0 <argptr+0x52>
8010598d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105990:	89 c2                	mov    %eax,%edx
80105992:	8b 45 10             	mov    0x10(%ebp),%eax
80105995:	01 c2                	add    %eax,%edx
80105997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599a:	8b 00                	mov    (%eax),%eax
8010599c:	39 c2                	cmp    %eax,%edx
8010599e:	76 07                	jbe    801059a7 <argptr+0x59>
    return -1;
801059a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a5:	eb 0f                	jmp    801059b6 <argptr+0x68>
  *pp = (char*)i;
801059a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059aa:	89 c2                	mov    %eax,%edx
801059ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801059af:	89 10                	mov    %edx,(%eax)
  return 0;
801059b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059b6:	c9                   	leave  
801059b7:	c3                   	ret    

801059b8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059b8:	55                   	push   %ebp
801059b9:	89 e5                	mov    %esp,%ebp
801059bb:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c5:	8b 45 08             	mov    0x8(%ebp),%eax
801059c8:	89 04 24             	mov    %eax,(%esp)
801059cb:	e8 51 ff ff ff       	call   80105921 <argint>
801059d0:	85 c0                	test   %eax,%eax
801059d2:	79 07                	jns    801059db <argstr+0x23>
    return -1;
801059d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d9:	eb 12                	jmp    801059ed <argstr+0x35>
  return fetchstr(addr, pp);
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	8b 55 0c             	mov    0xc(%ebp),%edx
801059e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801059e5:	89 04 24             	mov    %eax,(%esp)
801059e8:	e8 d2 fe ff ff       	call   801058bf <fetchstr>
}
801059ed:	c9                   	leave  
801059ee:	c3                   	ret    

801059ef <syscall>:
[SYS_container_reset] sys_container_reset,
};

void
syscall(void)
{
801059ef:	55                   	push   %ebp
801059f0:	89 e5                	mov    %esp,%ebp
801059f2:	53                   	push   %ebx
801059f3:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801059f6:	e8 78 ea ff ff       	call   80104473 <myproc>
801059fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a01:	8b 40 18             	mov    0x18(%eax),%eax
80105a04:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a0e:	7e 2d                	jle    80105a3d <syscall+0x4e>
80105a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a13:	83 f8 2f             	cmp    $0x2f,%eax
80105a16:	77 25                	ja     80105a3d <syscall+0x4e>
80105a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1b:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a22:	85 c0                	test   %eax,%eax
80105a24:	74 17                	je     80105a3d <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a29:	8b 58 18             	mov    0x18(%eax),%ebx
80105a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2f:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a36:	ff d0                	call   *%eax
80105a38:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a3b:	eb 34                	jmp    80105a71 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a40:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a46:	8b 40 10             	mov    0x10(%eax),%eax
80105a49:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105a50:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a58:	c7 04 24 db 99 10 80 	movl   $0x801099db,(%esp)
80105a5f:	e8 5d a9 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a67:	8b 40 18             	mov    0x18(%eax),%eax
80105a6a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a71:	83 c4 24             	add    $0x24,%esp
80105a74:	5b                   	pop    %ebx
80105a75:	5d                   	pop    %ebp
80105a76:	c3                   	ret    
	...

80105a78 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a78:	55                   	push   %ebp
80105a79:	89 e5                	mov    %esp,%ebp
80105a7b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a81:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a85:	8b 45 08             	mov    0x8(%ebp),%eax
80105a88:	89 04 24             	mov    %eax,(%esp)
80105a8b:	e8 91 fe ff ff       	call   80105921 <argint>
80105a90:	85 c0                	test   %eax,%eax
80105a92:	79 07                	jns    80105a9b <argfd+0x23>
    return -1;
80105a94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a99:	eb 4f                	jmp    80105aea <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9e:	85 c0                	test   %eax,%eax
80105aa0:	78 20                	js     80105ac2 <argfd+0x4a>
80105aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa5:	83 f8 0f             	cmp    $0xf,%eax
80105aa8:	7f 18                	jg     80105ac2 <argfd+0x4a>
80105aaa:	e8 c4 e9 ff ff       	call   80104473 <myproc>
80105aaf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ab2:	83 c2 08             	add    $0x8,%edx
80105ab5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ab9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105abc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac0:	75 07                	jne    80105ac9 <argfd+0x51>
    return -1;
80105ac2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac7:	eb 21                	jmp    80105aea <argfd+0x72>
  if(pfd)
80105ac9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105acd:	74 08                	je     80105ad7 <argfd+0x5f>
    *pfd = fd;
80105acf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ad5:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ad7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105adb:	74 08                	je     80105ae5 <argfd+0x6d>
    *pf = f;
80105add:	8b 45 10             	mov    0x10(%ebp),%eax
80105ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ae3:	89 10                	mov    %edx,(%eax)
  return 0;
80105ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aea:	c9                   	leave  
80105aeb:	c3                   	ret    

80105aec <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105aec:	55                   	push   %ebp
80105aed:	89 e5                	mov    %esp,%ebp
80105aef:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105af2:	e8 7c e9 ff ff       	call   80104473 <myproc>
80105af7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105afa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b01:	eb 29                	jmp    80105b2c <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b09:	83 c2 08             	add    $0x8,%edx
80105b0c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b10:	85 c0                	test   %eax,%eax
80105b12:	75 15                	jne    80105b29 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b1a:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b1d:	8b 55 08             	mov    0x8(%ebp),%edx
80105b20:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b27:	eb 0e                	jmp    80105b37 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105b29:	ff 45 f4             	incl   -0xc(%ebp)
80105b2c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b30:	7e d1                	jle    80105b03 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105b32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b37:	c9                   	leave  
80105b38:	c3                   	ret    

80105b39 <sys_dup>:

int
sys_dup(void)
{
80105b39:	55                   	push   %ebp
80105b3a:	89 e5                	mov    %esp,%ebp
80105b3c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b42:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b4d:	00 
80105b4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b55:	e8 1e ff ff ff       	call   80105a78 <argfd>
80105b5a:	85 c0                	test   %eax,%eax
80105b5c:	79 07                	jns    80105b65 <sys_dup+0x2c>
    return -1;
80105b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b63:	eb 29                	jmp    80105b8e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b68:	89 04 24             	mov    %eax,(%esp)
80105b6b:	e8 7c ff ff ff       	call   80105aec <fdalloc>
80105b70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b77:	79 07                	jns    80105b80 <sys_dup+0x47>
    return -1;
80105b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7e:	eb 0e                	jmp    80105b8e <sys_dup+0x55>
  filedup(f);
80105b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b83:	89 04 24             	mov    %eax,(%esp)
80105b86:	e8 d7 b5 ff ff       	call   80101162 <filedup>
  return fd;
80105b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b8e:	c9                   	leave  
80105b8f:	c3                   	ret    

80105b90 <sys_read>:

int
sys_read(void)
{
80105b90:	55                   	push   %ebp
80105b91:	89 e5                	mov    %esp,%ebp
80105b93:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b99:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ba4:	00 
80105ba5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bac:	e8 c7 fe ff ff       	call   80105a78 <argfd>
80105bb1:	85 c0                	test   %eax,%eax
80105bb3:	78 35                	js     80105bea <sys_read+0x5a>
80105bb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bbc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105bc3:	e8 59 fd ff ff       	call   80105921 <argint>
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	78 1e                	js     80105bea <sys_read+0x5a>
80105bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105be1:	e8 68 fd ff ff       	call   8010594e <argptr>
80105be6:	85 c0                	test   %eax,%eax
80105be8:	79 07                	jns    80105bf1 <sys_read+0x61>
    return -1;
80105bea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bef:	eb 19                	jmp    80105c0a <sys_read+0x7a>
  return fileread(f, p, n);
80105bf1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bf4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105bfe:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c02:	89 04 24             	mov    %eax,(%esp)
80105c05:	e8 b9 b6 ff ff       	call   801012c3 <fileread>
}
80105c0a:	c9                   	leave  
80105c0b:	c3                   	ret    

80105c0c <sys_write>:

int
sys_write(void)
{
80105c0c:	55                   	push   %ebp
80105c0d:	89 e5                	mov    %esp,%ebp
80105c0f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c15:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c20:	00 
80105c21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c28:	e8 4b fe ff ff       	call   80105a78 <argfd>
80105c2d:	85 c0                	test   %eax,%eax
80105c2f:	78 35                	js     80105c66 <sys_write+0x5a>
80105c31:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c34:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c38:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c3f:	e8 dd fc ff ff       	call   80105921 <argint>
80105c44:	85 c0                	test   %eax,%eax
80105c46:	78 1e                	js     80105c66 <sys_write+0x5a>
80105c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c52:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c5d:	e8 ec fc ff ff       	call   8010594e <argptr>
80105c62:	85 c0                	test   %eax,%eax
80105c64:	79 07                	jns    80105c6d <sys_write+0x61>
    return -1;
80105c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6b:	eb 19                	jmp    80105c86 <sys_write+0x7a>
  return filewrite(f, p, n);
80105c6d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c70:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c76:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c7a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c7e:	89 04 24             	mov    %eax,(%esp)
80105c81:	e8 f8 b6 ff ff       	call   8010137e <filewrite>
}
80105c86:	c9                   	leave  
80105c87:	c3                   	ret    

80105c88 <sys_close>:

int
sys_close(void)
{
80105c88:	55                   	push   %ebp
80105c89:	89 e5                	mov    %esp,%ebp
80105c8b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c91:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c95:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c98:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ca3:	e8 d0 fd ff ff       	call   80105a78 <argfd>
80105ca8:	85 c0                	test   %eax,%eax
80105caa:	79 07                	jns    80105cb3 <sys_close+0x2b>
    return -1;
80105cac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb1:	eb 23                	jmp    80105cd6 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105cb3:	e8 bb e7 ff ff       	call   80104473 <myproc>
80105cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cbb:	83 c2 08             	add    $0x8,%edx
80105cbe:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105cc5:	00 
  fileclose(f);
80105cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc9:	89 04 24             	mov    %eax,(%esp)
80105ccc:	e8 d9 b4 ff ff       	call   801011aa <fileclose>
  return 0;
80105cd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cd6:	c9                   	leave  
80105cd7:	c3                   	ret    

80105cd8 <sys_fstat>:

int
sys_fstat(void)
{
80105cd8:	55                   	push   %ebp
80105cd9:	89 e5                	mov    %esp,%ebp
80105cdb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105cde:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ce1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cec:	00 
80105ced:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cf4:	e8 7f fd ff ff       	call   80105a78 <argfd>
80105cf9:	85 c0                	test   %eax,%eax
80105cfb:	78 1f                	js     80105d1c <sys_fstat+0x44>
80105cfd:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105d04:	00 
80105d05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d13:	e8 36 fc ff ff       	call   8010594e <argptr>
80105d18:	85 c0                	test   %eax,%eax
80105d1a:	79 07                	jns    80105d23 <sys_fstat+0x4b>
    return -1;
80105d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d21:	eb 12                	jmp    80105d35 <sys_fstat+0x5d>
  return filestat(f, st);
80105d23:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d29:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d2d:	89 04 24             	mov    %eax,(%esp)
80105d30:	e8 3f b5 ff ff       	call   80101274 <filestat>
}
80105d35:	c9                   	leave  
80105d36:	c3                   	ret    

80105d37 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d37:	55                   	push   %ebp
80105d38:	89 e5                	mov    %esp,%ebp
80105d3a:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d3d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d40:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d4b:	e8 68 fc ff ff       	call   801059b8 <argstr>
80105d50:	85 c0                	test   %eax,%eax
80105d52:	78 17                	js     80105d6b <sys_link+0x34>
80105d54:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d57:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d62:	e8 51 fc ff ff       	call   801059b8 <argstr>
80105d67:	85 c0                	test   %eax,%eax
80105d69:	79 0a                	jns    80105d75 <sys_link+0x3e>
    return -1;
80105d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d70:	e9 3d 01 00 00       	jmp    80105eb2 <sys_link+0x17b>

  begin_op();
80105d75:	e8 f9 d9 ff ff       	call   80103773 <begin_op>
  if((ip = namei(old)) == 0){
80105d7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d7d:	89 04 24             	mov    %eax,(%esp)
80105d80:	e8 98 c9 ff ff       	call   8010271d <namei>
80105d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d8c:	75 0f                	jne    80105d9d <sys_link+0x66>
    end_op();
80105d8e:	e8 62 da ff ff       	call   801037f5 <end_op>
    return -1;
80105d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d98:	e9 15 01 00 00       	jmp    80105eb2 <sys_link+0x17b>
  }

  ilock(ip);
80105d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da0:	89 04 24             	mov    %eax,(%esp)
80105da3:	e8 1a bd ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dab:	8b 40 50             	mov    0x50(%eax),%eax
80105dae:	66 83 f8 01          	cmp    $0x1,%ax
80105db2:	75 1a                	jne    80105dce <sys_link+0x97>
    iunlockput(ip);
80105db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db7:	89 04 24             	mov    %eax,(%esp)
80105dba:	e8 02 bf ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105dbf:	e8 31 da ff ff       	call   801037f5 <end_op>
    return -1;
80105dc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc9:	e9 e4 00 00 00       	jmp    80105eb2 <sys_link+0x17b>
  }

  ip->nlink++;
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	66 8b 40 56          	mov    0x56(%eax),%ax
80105dd5:	40                   	inc    %eax
80105dd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dd9:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de0:	89 04 24             	mov    %eax,(%esp)
80105de3:	e8 17 bb ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105deb:	89 04 24             	mov    %eax,(%esp)
80105dee:	e8 d9 bd ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105df3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105df6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105df9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105dfd:	89 04 24             	mov    %eax,(%esp)
80105e00:	e8 3a c9 ff ff       	call   8010273f <nameiparent>
80105e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e0c:	75 02                	jne    80105e10 <sys_link+0xd9>
    goto bad;
80105e0e:	eb 68                	jmp    80105e78 <sys_link+0x141>
  ilock(dp);
80105e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e13:	89 04 24             	mov    %eax,(%esp)
80105e16:	e8 a7 bc ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1e:	8b 10                	mov    (%eax),%edx
80105e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e23:	8b 00                	mov    (%eax),%eax
80105e25:	39 c2                	cmp    %eax,%edx
80105e27:	75 20                	jne    80105e49 <sys_link+0x112>
80105e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2c:	8b 40 04             	mov    0x4(%eax),%eax
80105e2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e33:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3d:	89 04 24             	mov    %eax,(%esp)
80105e40:	e8 58 c5 ff ff       	call   8010239d <dirlink>
80105e45:	85 c0                	test   %eax,%eax
80105e47:	79 0d                	jns    80105e56 <sys_link+0x11f>
    iunlockput(dp);
80105e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4c:	89 04 24             	mov    %eax,(%esp)
80105e4f:	e8 6d be ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105e54:	eb 22                	jmp    80105e78 <sys_link+0x141>
  }
  iunlockput(dp);
80105e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e59:	89 04 24             	mov    %eax,(%esp)
80105e5c:	e8 60 be ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e64:	89 04 24             	mov    %eax,(%esp)
80105e67:	e8 a4 bd ff ff       	call   80101c10 <iput>

  end_op();
80105e6c:	e8 84 d9 ff ff       	call   801037f5 <end_op>

  return 0;
80105e71:	b8 00 00 00 00       	mov    $0x0,%eax
80105e76:	eb 3a                	jmp    80105eb2 <sys_link+0x17b>

bad:
  ilock(ip);
80105e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7b:	89 04 24             	mov    %eax,(%esp)
80105e7e:	e8 3f bc ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e86:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e8a:	48                   	dec    %eax
80105e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e8e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e95:	89 04 24             	mov    %eax,(%esp)
80105e98:	e8 62 ba ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea0:	89 04 24             	mov    %eax,(%esp)
80105ea3:	e8 19 be ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105ea8:	e8 48 d9 ff ff       	call   801037f5 <end_op>
  return -1;
80105ead:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eb2:	c9                   	leave  
80105eb3:	c3                   	ret    

80105eb4 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105eb4:	55                   	push   %ebp
80105eb5:	89 e5                	mov    %esp,%ebp
80105eb7:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eba:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ec1:	eb 4a                	jmp    80105f0d <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105ecd:	00 
80105ece:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ed2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80105edc:	89 04 24             	mov    %eax,(%esp)
80105edf:	e8 75 c0 ff ff       	call   80101f59 <readi>
80105ee4:	83 f8 10             	cmp    $0x10,%eax
80105ee7:	74 0c                	je     80105ef5 <isdirempty+0x41>
      panic("isdirempty: readi");
80105ee9:	c7 04 24 f7 99 10 80 	movl   $0x801099f7,(%esp)
80105ef0:	e8 5f a6 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105ef5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ef8:	66 85 c0             	test   %ax,%ax
80105efb:	74 07                	je     80105f04 <isdirempty+0x50>
      return 0;
80105efd:	b8 00 00 00 00       	mov    $0x0,%eax
80105f02:	eb 1b                	jmp    80105f1f <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f07:	83 c0 10             	add    $0x10,%eax
80105f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f10:	8b 45 08             	mov    0x8(%ebp),%eax
80105f13:	8b 40 58             	mov    0x58(%eax),%eax
80105f16:	39 c2                	cmp    %eax,%edx
80105f18:	72 a9                	jb     80105ec3 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105f1a:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f1f:	c9                   	leave  
80105f20:	c3                   	ret    

80105f21 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f21:	55                   	push   %ebp
80105f22:	89 e5                	mov    %esp,%ebp
80105f24:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f27:	8d 45 bc             	lea    -0x44(%ebp),%eax
80105f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f35:	e8 7e fa ff ff       	call   801059b8 <argstr>
80105f3a:	85 c0                	test   %eax,%eax
80105f3c:	79 0a                	jns    80105f48 <sys_unlink+0x27>
    return -1;
80105f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f43:	e9 f1 01 00 00       	jmp    80106139 <sys_unlink+0x218>

  begin_op();
80105f48:	e8 26 d8 ff ff       	call   80103773 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f4d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80105f50:	8d 55 c2             	lea    -0x3e(%ebp),%edx
80105f53:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f57:	89 04 24             	mov    %eax,(%esp)
80105f5a:	e8 e0 c7 ff ff       	call   8010273f <nameiparent>
80105f5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f66:	75 0f                	jne    80105f77 <sys_unlink+0x56>
    end_op();
80105f68:	e8 88 d8 ff ff       	call   801037f5 <end_op>
    return -1;
80105f6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f72:	e9 c2 01 00 00       	jmp    80106139 <sys_unlink+0x218>
  }

  ilock(dp);
80105f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7a:	89 04 24             	mov    %eax,(%esp)
80105f7d:	e8 40 bb ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f82:	c7 44 24 04 09 9a 10 	movl   $0x80109a09,0x4(%esp)
80105f89:	80 
80105f8a:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105f8d:	89 04 24             	mov    %eax,(%esp)
80105f90:	e8 20 c3 ff ff       	call   801022b5 <namecmp>
80105f95:	85 c0                	test   %eax,%eax
80105f97:	0f 84 87 01 00 00    	je     80106124 <sys_unlink+0x203>
80105f9d:	c7 44 24 04 0b 9a 10 	movl   $0x80109a0b,0x4(%esp)
80105fa4:	80 
80105fa5:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105fa8:	89 04 24             	mov    %eax,(%esp)
80105fab:	e8 05 c3 ff ff       	call   801022b5 <namecmp>
80105fb0:	85 c0                	test   %eax,%eax
80105fb2:	0f 84 6c 01 00 00    	je     80106124 <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fb8:	8d 45 b8             	lea    -0x48(%ebp),%eax
80105fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fbf:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80105fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc9:	89 04 24             	mov    %eax,(%esp)
80105fcc:	e8 06 c3 ff ff       	call   801022d7 <dirlookup>
80105fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd8:	75 05                	jne    80105fdf <sys_unlink+0xbe>
    goto bad;
80105fda:	e9 45 01 00 00       	jmp    80106124 <sys_unlink+0x203>
  ilock(ip);
80105fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe2:	89 04 24             	mov    %eax,(%esp)
80105fe5:	e8 d8 ba ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
80105fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fed:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ff1:	66 85 c0             	test   %ax,%ax
80105ff4:	7f 0c                	jg     80106002 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105ff6:	c7 04 24 0e 9a 10 80 	movl   $0x80109a0e,(%esp)
80105ffd:	e8 52 a5 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106005:	8b 40 50             	mov    0x50(%eax),%eax
80106008:	66 83 f8 01          	cmp    $0x1,%ax
8010600c:	75 1f                	jne    8010602d <sys_unlink+0x10c>
8010600e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106011:	89 04 24             	mov    %eax,(%esp)
80106014:	e8 9b fe ff ff       	call   80105eb4 <isdirempty>
80106019:	85 c0                	test   %eax,%eax
8010601b:	75 10                	jne    8010602d <sys_unlink+0x10c>
    iunlockput(ip);
8010601d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106020:	89 04 24             	mov    %eax,(%esp)
80106023:	e8 99 bc ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80106028:	e9 f7 00 00 00       	jmp    80106124 <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
8010602d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106034:	00 
80106035:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010603c:	00 
8010603d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106040:	89 04 24             	mov    %eax,(%esp)
80106043:	e8 a6 f5 ff ff       	call   801055ee <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80106048:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010604b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106052:	00 
80106053:	89 44 24 08          	mov    %eax,0x8(%esp)
80106057:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010605a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010605e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106061:	89 04 24             	mov    %eax,(%esp)
80106064:	e8 54 c0 ff ff       	call   801020bd <writei>
80106069:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
8010606c:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80106070:	74 0c                	je     8010607e <sys_unlink+0x15d>
    panic("unlink: writei");
80106072:	c7 04 24 20 9a 10 80 	movl   $0x80109a20,(%esp)
80106079:	e8 d6 a4 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
8010607e:	e8 f0 e3 ff ff       	call   80104473 <myproc>
80106083:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106089:	83 c0 18             	add    $0x18,%eax
8010608c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
8010608f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106092:	89 04 24             	mov    %eax,(%esp)
80106095:	e8 59 2e 00 00       	call   80108ef3 <find>
8010609a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
8010609d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060a0:	89 c2                	mov    %eax,%edx
801060a2:	c1 ea 1f             	shr    $0x1f,%edx
801060a5:	01 d0                	add    %edx,%eax
801060a7:	d1 f8                	sar    %eax
801060a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
801060ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060af:	f7 d8                	neg    %eax
801060b1:	89 c2                	mov    %eax,%edx
801060b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ba:	89 14 24             	mov    %edx,(%esp)
801060bd:	e8 88 31 00 00       	call   8010924a <set_curr_disk>
  if(ip->type == T_DIR){
801060c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c5:	8b 40 50             	mov    0x50(%eax),%eax
801060c8:	66 83 f8 01          	cmp    $0x1,%ax
801060cc:	75 1a                	jne    801060e8 <sys_unlink+0x1c7>
    dp->nlink--;
801060ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d1:	66 8b 40 56          	mov    0x56(%eax),%ax
801060d5:	48                   	dec    %eax
801060d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060d9:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801060dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e0:	89 04 24             	mov    %eax,(%esp)
801060e3:	e8 17 b8 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
801060e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060eb:	89 04 24             	mov    %eax,(%esp)
801060ee:	e8 ce bb ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
801060f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f6:	66 8b 40 56          	mov    0x56(%eax),%ax
801060fa:	48                   	dec    %eax
801060fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060fe:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106105:	89 04 24             	mov    %eax,(%esp)
80106108:	e8 f2 b7 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
8010610d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106110:	89 04 24             	mov    %eax,(%esp)
80106113:	e8 a9 bb ff ff       	call   80101cc1 <iunlockput>

  end_op();
80106118:	e8 d8 d6 ff ff       	call   801037f5 <end_op>

  return 0;
8010611d:	b8 00 00 00 00       	mov    $0x0,%eax
80106122:	eb 15                	jmp    80106139 <sys_unlink+0x218>

bad:
  iunlockput(dp);
80106124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106127:	89 04 24             	mov    %eax,(%esp)
8010612a:	e8 92 bb ff ff       	call   80101cc1 <iunlockput>
  end_op();
8010612f:	e8 c1 d6 ff ff       	call   801037f5 <end_op>
  return -1;
80106134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106139:	c9                   	leave  
8010613a:	c3                   	ret    

8010613b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010613b:	55                   	push   %ebp
8010613c:	89 e5                	mov    %esp,%ebp
8010613e:	83 ec 48             	sub    $0x48,%esp
80106141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106144:	8b 55 10             	mov    0x10(%ebp),%edx
80106147:	8b 45 14             	mov    0x14(%ebp),%eax
8010614a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010614e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106152:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106156:	8d 45 de             	lea    -0x22(%ebp),%eax
80106159:	89 44 24 04          	mov    %eax,0x4(%esp)
8010615d:	8b 45 08             	mov    0x8(%ebp),%eax
80106160:	89 04 24             	mov    %eax,(%esp)
80106163:	e8 d7 c5 ff ff       	call   8010273f <nameiparent>
80106168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010616b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616f:	75 0a                	jne    8010617b <create+0x40>
    return 0;
80106171:	b8 00 00 00 00       	mov    $0x0,%eax
80106176:	e9 79 01 00 00       	jmp    801062f4 <create+0x1b9>
  ilock(dp);
8010617b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617e:	89 04 24             	mov    %eax,(%esp)
80106181:	e8 3c b9 ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106186:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106189:	89 44 24 08          	mov    %eax,0x8(%esp)
8010618d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106190:	89 44 24 04          	mov    %eax,0x4(%esp)
80106194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106197:	89 04 24             	mov    %eax,(%esp)
8010619a:	e8 38 c1 ff ff       	call   801022d7 <dirlookup>
8010619f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a6:	74 46                	je     801061ee <create+0xb3>
    iunlockput(dp);
801061a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ab:	89 04 24             	mov    %eax,(%esp)
801061ae:	e8 0e bb ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
801061b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b6:	89 04 24             	mov    %eax,(%esp)
801061b9:	e8 04 b9 ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801061be:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061c3:	75 14                	jne    801061d9 <create+0x9e>
801061c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c8:	8b 40 50             	mov    0x50(%eax),%eax
801061cb:	66 83 f8 02          	cmp    $0x2,%ax
801061cf:	75 08                	jne    801061d9 <create+0x9e>
      return ip;
801061d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d4:	e9 1b 01 00 00       	jmp    801062f4 <create+0x1b9>
    iunlockput(ip);
801061d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061dc:	89 04 24             	mov    %eax,(%esp)
801061df:	e8 dd ba ff ff       	call   80101cc1 <iunlockput>
    return 0;
801061e4:	b8 00 00 00 00       	mov    $0x0,%eax
801061e9:	e9 06 01 00 00       	jmp    801062f4 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061ee:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f5:	8b 00                	mov    (%eax),%eax
801061f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801061fb:	89 04 24             	mov    %eax,(%esp)
801061fe:	e8 2a b6 ff ff       	call   8010182d <ialloc>
80106203:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106206:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010620a:	75 0c                	jne    80106218 <create+0xdd>
    panic("create: ialloc");
8010620c:	c7 04 24 2f 9a 10 80 	movl   $0x80109a2f,(%esp)
80106213:	e8 3c a3 ff ff       	call   80100554 <panic>

  ilock(ip);
80106218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621b:	89 04 24             	mov    %eax,(%esp)
8010621e:	e8 9f b8 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
80106223:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106226:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106229:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
8010622d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106230:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106233:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80106237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623a:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106240:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106243:	89 04 24             	mov    %eax,(%esp)
80106246:	e8 b4 b6 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010624b:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106250:	75 68                	jne    801062ba <create+0x17f>
    dp->nlink++;  // for ".."
80106252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106255:	66 8b 40 56          	mov    0x56(%eax),%ax
80106259:	40                   	inc    %eax
8010625a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010625d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106264:	89 04 24             	mov    %eax,(%esp)
80106267:	e8 93 b6 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010626c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626f:	8b 40 04             	mov    0x4(%eax),%eax
80106272:	89 44 24 08          	mov    %eax,0x8(%esp)
80106276:	c7 44 24 04 09 9a 10 	movl   $0x80109a09,0x4(%esp)
8010627d:	80 
8010627e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106281:	89 04 24             	mov    %eax,(%esp)
80106284:	e8 14 c1 ff ff       	call   8010239d <dirlink>
80106289:	85 c0                	test   %eax,%eax
8010628b:	78 21                	js     801062ae <create+0x173>
8010628d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106290:	8b 40 04             	mov    0x4(%eax),%eax
80106293:	89 44 24 08          	mov    %eax,0x8(%esp)
80106297:	c7 44 24 04 0b 9a 10 	movl   $0x80109a0b,0x4(%esp)
8010629e:	80 
8010629f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a2:	89 04 24             	mov    %eax,(%esp)
801062a5:	e8 f3 c0 ff ff       	call   8010239d <dirlink>
801062aa:	85 c0                	test   %eax,%eax
801062ac:	79 0c                	jns    801062ba <create+0x17f>
      panic("create dots");
801062ae:	c7 04 24 3e 9a 10 80 	movl   $0x80109a3e,(%esp)
801062b5:	e8 9a a2 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bd:	8b 40 04             	mov    0x4(%eax),%eax
801062c0:	89 44 24 08          	mov    %eax,0x8(%esp)
801062c4:	8d 45 de             	lea    -0x22(%ebp),%eax
801062c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801062cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ce:	89 04 24             	mov    %eax,(%esp)
801062d1:	e8 c7 c0 ff ff       	call   8010239d <dirlink>
801062d6:	85 c0                	test   %eax,%eax
801062d8:	79 0c                	jns    801062e6 <create+0x1ab>
    panic("create: dirlink");
801062da:	c7 04 24 4a 9a 10 80 	movl   $0x80109a4a,(%esp)
801062e1:	e8 6e a2 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801062e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e9:	89 04 24             	mov    %eax,(%esp)
801062ec:	e8 d0 b9 ff ff       	call   80101cc1 <iunlockput>

  return ip;
801062f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062f4:	c9                   	leave  
801062f5:	c3                   	ret    

801062f6 <sys_open>:

int
sys_open(void)
{
801062f6:	55                   	push   %ebp
801062f7:	89 e5                	mov    %esp,%ebp
801062f9:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062fc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106303:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010630a:	e8 a9 f6 ff ff       	call   801059b8 <argstr>
8010630f:	85 c0                	test   %eax,%eax
80106311:	78 17                	js     8010632a <sys_open+0x34>
80106313:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106316:	89 44 24 04          	mov    %eax,0x4(%esp)
8010631a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106321:	e8 fb f5 ff ff       	call   80105921 <argint>
80106326:	85 c0                	test   %eax,%eax
80106328:	79 0a                	jns    80106334 <sys_open+0x3e>
    return -1;
8010632a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632f:	e9 64 01 00 00       	jmp    80106498 <sys_open+0x1a2>

  begin_op();
80106334:	e8 3a d4 ff ff       	call   80103773 <begin_op>

  if(omode & O_CREATE){
80106339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010633c:	25 00 02 00 00       	and    $0x200,%eax
80106341:	85 c0                	test   %eax,%eax
80106343:	74 3b                	je     80106380 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106345:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010634f:	00 
80106350:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106357:	00 
80106358:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010635f:	00 
80106360:	89 04 24             	mov    %eax,(%esp)
80106363:	e8 d3 fd ff ff       	call   8010613b <create>
80106368:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010636b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010636f:	75 6a                	jne    801063db <sys_open+0xe5>
      end_op();
80106371:	e8 7f d4 ff ff       	call   801037f5 <end_op>
      return -1;
80106376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637b:	e9 18 01 00 00       	jmp    80106498 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106380:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106383:	89 04 24             	mov    %eax,(%esp)
80106386:	e8 92 c3 ff ff       	call   8010271d <namei>
8010638b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010638e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106392:	75 0f                	jne    801063a3 <sys_open+0xad>
      end_op();
80106394:	e8 5c d4 ff ff       	call   801037f5 <end_op>
      return -1;
80106399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639e:	e9 f5 00 00 00       	jmp    80106498 <sys_open+0x1a2>
    }
    ilock(ip);
801063a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a6:	89 04 24             	mov    %eax,(%esp)
801063a9:	e8 14 b7 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801063ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b1:	8b 40 50             	mov    0x50(%eax),%eax
801063b4:	66 83 f8 01          	cmp    $0x1,%ax
801063b8:	75 21                	jne    801063db <sys_open+0xe5>
801063ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063bd:	85 c0                	test   %eax,%eax
801063bf:	74 1a                	je     801063db <sys_open+0xe5>
      iunlockput(ip);
801063c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c4:	89 04 24             	mov    %eax,(%esp)
801063c7:	e8 f5 b8 ff ff       	call   80101cc1 <iunlockput>
      end_op();
801063cc:	e8 24 d4 ff ff       	call   801037f5 <end_op>
      return -1;
801063d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d6:	e9 bd 00 00 00       	jmp    80106498 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063db:	e8 22 ad ff ff       	call   80101102 <filealloc>
801063e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e7:	74 14                	je     801063fd <sys_open+0x107>
801063e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ec:	89 04 24             	mov    %eax,(%esp)
801063ef:	e8 f8 f6 ff ff       	call   80105aec <fdalloc>
801063f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063fb:	79 28                	jns    80106425 <sys_open+0x12f>
    if(f)
801063fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106401:	74 0b                	je     8010640e <sys_open+0x118>
      fileclose(f);
80106403:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106406:	89 04 24             	mov    %eax,(%esp)
80106409:	e8 9c ad ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
8010640e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106411:	89 04 24             	mov    %eax,(%esp)
80106414:	e8 a8 b8 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106419:	e8 d7 d3 ff ff       	call   801037f5 <end_op>
    return -1;
8010641e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106423:	eb 73                	jmp    80106498 <sys_open+0x1a2>
  }
  iunlock(ip);
80106425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106428:	89 04 24             	mov    %eax,(%esp)
8010642b:	e8 9c b7 ff ff       	call   80101bcc <iunlock>
  end_op();
80106430:	e8 c0 d3 ff ff       	call   801037f5 <end_op>

  f->type = FD_INODE;
80106435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106438:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010643e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106441:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106444:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106451:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106454:	83 e0 01             	and    $0x1,%eax
80106457:	85 c0                	test   %eax,%eax
80106459:	0f 94 c0             	sete   %al
8010645c:	88 c2                	mov    %al,%dl
8010645e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106461:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106467:	83 e0 01             	and    $0x1,%eax
8010646a:	85 c0                	test   %eax,%eax
8010646c:	75 0a                	jne    80106478 <sys_open+0x182>
8010646e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106471:	83 e0 02             	and    $0x2,%eax
80106474:	85 c0                	test   %eax,%eax
80106476:	74 07                	je     8010647f <sys_open+0x189>
80106478:	b8 01 00 00 00       	mov    $0x1,%eax
8010647d:	eb 05                	jmp    80106484 <sys_open+0x18e>
8010647f:	b8 00 00 00 00       	mov    $0x0,%eax
80106484:	88 c2                	mov    %al,%dl
80106486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106489:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
8010648c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010648f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106492:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
80106495:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106498:	c9                   	leave  
80106499:	c3                   	ret    

8010649a <sys_mkdir>:

int
sys_mkdir(void)
{
8010649a:	55                   	push   %ebp
8010649b:	89 e5                	mov    %esp,%ebp
8010649d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064a0:	e8 ce d2 ff ff       	call   80103773 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801064a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b3:	e8 00 f5 ff ff       	call   801059b8 <argstr>
801064b8:	85 c0                	test   %eax,%eax
801064ba:	78 2c                	js     801064e8 <sys_mkdir+0x4e>
801064bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801064c6:	00 
801064c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801064ce:	00 
801064cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801064d6:	00 
801064d7:	89 04 24             	mov    %eax,(%esp)
801064da:	e8 5c fc ff ff       	call   8010613b <create>
801064df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e6:	75 0c                	jne    801064f4 <sys_mkdir+0x5a>
    end_op();
801064e8:	e8 08 d3 ff ff       	call   801037f5 <end_op>
    return -1;
801064ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f2:	eb 15                	jmp    80106509 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801064f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f7:	89 04 24             	mov    %eax,(%esp)
801064fa:	e8 c2 b7 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801064ff:	e8 f1 d2 ff ff       	call   801037f5 <end_op>
  return 0;
80106504:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106509:	c9                   	leave  
8010650a:	c3                   	ret    

8010650b <sys_mknod>:

int
sys_mknod(void)
{
8010650b:	55                   	push   %ebp
8010650c:	89 e5                	mov    %esp,%ebp
8010650e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106511:	e8 5d d2 ff ff       	call   80103773 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106516:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106519:	89 44 24 04          	mov    %eax,0x4(%esp)
8010651d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106524:	e8 8f f4 ff ff       	call   801059b8 <argstr>
80106529:	85 c0                	test   %eax,%eax
8010652b:	78 5e                	js     8010658b <sys_mknod+0x80>
     argint(1, &major) < 0 ||
8010652d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106530:	89 44 24 04          	mov    %eax,0x4(%esp)
80106534:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010653b:	e8 e1 f3 ff ff       	call   80105921 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106540:	85 c0                	test   %eax,%eax
80106542:	78 47                	js     8010658b <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106544:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106547:	89 44 24 04          	mov    %eax,0x4(%esp)
8010654b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106552:	e8 ca f3 ff ff       	call   80105921 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106557:	85 c0                	test   %eax,%eax
80106559:	78 30                	js     8010658b <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010655b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010655e:	0f bf c8             	movswl %ax,%ecx
80106561:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106564:	0f bf d0             	movswl %ax,%edx
80106567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010656a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010656e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106572:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106579:	00 
8010657a:	89 04 24             	mov    %eax,(%esp)
8010657d:	e8 b9 fb ff ff       	call   8010613b <create>
80106582:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106589:	75 0c                	jne    80106597 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010658b:	e8 65 d2 ff ff       	call   801037f5 <end_op>
    return -1;
80106590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106595:	eb 15                	jmp    801065ac <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659a:	89 04 24             	mov    %eax,(%esp)
8010659d:	e8 1f b7 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801065a2:	e8 4e d2 ff ff       	call   801037f5 <end_op>
  return 0;
801065a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ac:	c9                   	leave  
801065ad:	c3                   	ret    

801065ae <sys_chdir>:

int
sys_chdir(void)
{
801065ae:	55                   	push   %ebp
801065af:	89 e5                	mov    %esp,%ebp
801065b1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801065b4:	e8 ba de ff ff       	call   80104473 <myproc>
801065b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801065bc:	e8 b2 d1 ff ff       	call   80103773 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801065c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065cf:	e8 e4 f3 ff ff       	call   801059b8 <argstr>
801065d4:	85 c0                	test   %eax,%eax
801065d6:	78 14                	js     801065ec <sys_chdir+0x3e>
801065d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065db:	89 04 24             	mov    %eax,(%esp)
801065de:	e8 3a c1 ff ff       	call   8010271d <namei>
801065e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ea:	75 0c                	jne    801065f8 <sys_chdir+0x4a>
    end_op();
801065ec:	e8 04 d2 ff ff       	call   801037f5 <end_op>
    return -1;
801065f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f6:	eb 5a                	jmp    80106652 <sys_chdir+0xa4>
  }
  ilock(ip);
801065f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fb:	89 04 24             	mov    %eax,(%esp)
801065fe:	e8 bf b4 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
80106603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106606:	8b 40 50             	mov    0x50(%eax),%eax
80106609:	66 83 f8 01          	cmp    $0x1,%ax
8010660d:	74 17                	je     80106626 <sys_chdir+0x78>
    iunlockput(ip);
8010660f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106612:	89 04 24             	mov    %eax,(%esp)
80106615:	e8 a7 b6 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010661a:	e8 d6 d1 ff ff       	call   801037f5 <end_op>
    return -1;
8010661f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106624:	eb 2c                	jmp    80106652 <sys_chdir+0xa4>
  }
  iunlock(ip);
80106626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106629:	89 04 24             	mov    %eax,(%esp)
8010662c:	e8 9b b5 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106634:	8b 40 68             	mov    0x68(%eax),%eax
80106637:	89 04 24             	mov    %eax,(%esp)
8010663a:	e8 d1 b5 ff ff       	call   80101c10 <iput>
  end_op();
8010663f:	e8 b1 d1 ff ff       	call   801037f5 <end_op>
  curproc->cwd = ip;
80106644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106647:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010664a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010664d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106652:	c9                   	leave  
80106653:	c3                   	ret    

80106654 <sys_exec>:

int
sys_exec(void)
{
80106654:	55                   	push   %ebp
80106655:	89 e5                	mov    %esp,%ebp
80106657:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010665d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106660:	89 44 24 04          	mov    %eax,0x4(%esp)
80106664:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010666b:	e8 48 f3 ff ff       	call   801059b8 <argstr>
80106670:	85 c0                	test   %eax,%eax
80106672:	78 1a                	js     8010668e <sys_exec+0x3a>
80106674:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010667a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010667e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106685:	e8 97 f2 ff ff       	call   80105921 <argint>
8010668a:	85 c0                	test   %eax,%eax
8010668c:	79 0a                	jns    80106698 <sys_exec+0x44>
    return -1;
8010668e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106693:	e9 c7 00 00 00       	jmp    8010675f <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106698:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010669f:	00 
801066a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801066a7:	00 
801066a8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066ae:	89 04 24             	mov    %eax,(%esp)
801066b1:	e8 38 ef ff ff       	call   801055ee <memset>
  for(i=0;; i++){
801066b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c0:	83 f8 1f             	cmp    $0x1f,%eax
801066c3:	76 0a                	jbe    801066cf <sys_exec+0x7b>
      return -1;
801066c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ca:	e9 90 00 00 00       	jmp    8010675f <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d2:	c1 e0 02             	shl    $0x2,%eax
801066d5:	89 c2                	mov    %eax,%edx
801066d7:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066dd:	01 c2                	add    %eax,%edx
801066df:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e9:	89 14 24             	mov    %edx,(%esp)
801066ec:	e8 8f f1 ff ff       	call   80105880 <fetchint>
801066f1:	85 c0                	test   %eax,%eax
801066f3:	79 07                	jns    801066fc <sys_exec+0xa8>
      return -1;
801066f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fa:	eb 63                	jmp    8010675f <sys_exec+0x10b>
    if(uarg == 0){
801066fc:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106702:	85 c0                	test   %eax,%eax
80106704:	75 26                	jne    8010672c <sys_exec+0xd8>
      argv[i] = 0;
80106706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106709:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106710:	00 00 00 00 
      break;
80106714:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106715:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106718:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010671e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106722:	89 04 24             	mov    %eax,(%esp)
80106725:	e8 16 a5 ff ff       	call   80100c40 <exec>
8010672a:	eb 33                	jmp    8010675f <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010672c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106732:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106735:	c1 e2 02             	shl    $0x2,%edx
80106738:	01 c2                	add    %eax,%edx
8010673a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106740:	89 54 24 04          	mov    %edx,0x4(%esp)
80106744:	89 04 24             	mov    %eax,(%esp)
80106747:	e8 73 f1 ff ff       	call   801058bf <fetchstr>
8010674c:	85 c0                	test   %eax,%eax
8010674e:	79 07                	jns    80106757 <sys_exec+0x103>
      return -1;
80106750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106755:	eb 08                	jmp    8010675f <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106757:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010675a:	e9 5e ff ff ff       	jmp    801066bd <sys_exec+0x69>
  return exec(path, argv);
}
8010675f:	c9                   	leave  
80106760:	c3                   	ret    

80106761 <sys_pipe>:

int
sys_pipe(void)
{
80106761:	55                   	push   %ebp
80106762:	89 e5                	mov    %esp,%ebp
80106764:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106767:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010676e:	00 
8010676f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106772:	89 44 24 04          	mov    %eax,0x4(%esp)
80106776:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010677d:	e8 cc f1 ff ff       	call   8010594e <argptr>
80106782:	85 c0                	test   %eax,%eax
80106784:	79 0a                	jns    80106790 <sys_pipe+0x2f>
    return -1;
80106786:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678b:	e9 9a 00 00 00       	jmp    8010682a <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106790:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106793:	89 44 24 04          	mov    %eax,0x4(%esp)
80106797:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010679a:	89 04 24             	mov    %eax,(%esp)
8010679d:	e8 26 d8 ff ff       	call   80103fc8 <pipealloc>
801067a2:	85 c0                	test   %eax,%eax
801067a4:	79 07                	jns    801067ad <sys_pipe+0x4c>
    return -1;
801067a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ab:	eb 7d                	jmp    8010682a <sys_pipe+0xc9>
  fd0 = -1;
801067ad:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067b7:	89 04 24             	mov    %eax,(%esp)
801067ba:	e8 2d f3 ff ff       	call   80105aec <fdalloc>
801067bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067c6:	78 14                	js     801067dc <sys_pipe+0x7b>
801067c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067cb:	89 04 24             	mov    %eax,(%esp)
801067ce:	e8 19 f3 ff ff       	call   80105aec <fdalloc>
801067d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067da:	79 36                	jns    80106812 <sys_pipe+0xb1>
    if(fd0 >= 0)
801067dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067e0:	78 13                	js     801067f5 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801067e2:	e8 8c dc ff ff       	call   80104473 <myproc>
801067e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067ea:	83 c2 08             	add    $0x8,%edx
801067ed:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067f4:	00 
    fileclose(rf);
801067f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067f8:	89 04 24             	mov    %eax,(%esp)
801067fb:	e8 aa a9 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106800:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106803:	89 04 24             	mov    %eax,(%esp)
80106806:	e8 9f a9 ff ff       	call   801011aa <fileclose>
    return -1;
8010680b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106810:	eb 18                	jmp    8010682a <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106815:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106818:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010681a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010681d:	8d 50 04             	lea    0x4(%eax),%edx
80106820:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106823:	89 02                	mov    %eax,(%edx)
  return 0;
80106825:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010682a:	c9                   	leave  
8010682b:	c3                   	ret    

8010682c <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
8010682c:	55                   	push   %ebp
8010682d:	89 e5                	mov    %esp,%ebp
8010682f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106832:	e8 55 df ff ff       	call   8010478c <fork>
}
80106837:	c9                   	leave  
80106838:	c3                   	ret    

80106839 <sys_exit>:

int
sys_exit(void)
{
80106839:	55                   	push   %ebp
8010683a:	89 e5                	mov    %esp,%ebp
8010683c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010683f:	e8 c0 e0 ff ff       	call   80104904 <exit>
  return 0;  // not reached
80106844:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106849:	c9                   	leave  
8010684a:	c3                   	ret    

8010684b <sys_wait>:

int
sys_wait(void)
{
8010684b:	55                   	push   %ebp
8010684c:	89 e5                	mov    %esp,%ebp
8010684e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106851:	e8 f2 e1 ff ff       	call   80104a48 <wait>
}
80106856:	c9                   	leave  
80106857:	c3                   	ret    

80106858 <sys_kill>:

int
sys_kill(void)
{
80106858:	55                   	push   %ebp
80106859:	89 e5                	mov    %esp,%ebp
8010685b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010685e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106861:	89 44 24 04          	mov    %eax,0x4(%esp)
80106865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010686c:	e8 b0 f0 ff ff       	call   80105921 <argint>
80106871:	85 c0                	test   %eax,%eax
80106873:	79 07                	jns    8010687c <sys_kill+0x24>
    return -1;
80106875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687a:	eb 0b                	jmp    80106887 <sys_kill+0x2f>
  return kill(pid);
8010687c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010687f:	89 04 24             	mov    %eax,(%esp)
80106882:	e8 9f e5 ff ff       	call   80104e26 <kill>
}
80106887:	c9                   	leave  
80106888:	c3                   	ret    

80106889 <sys_getpid>:

int
sys_getpid(void)
{
80106889:	55                   	push   %ebp
8010688a:	89 e5                	mov    %esp,%ebp
8010688c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010688f:	e8 df db ff ff       	call   80104473 <myproc>
80106894:	8b 40 10             	mov    0x10(%eax),%eax
}
80106897:	c9                   	leave  
80106898:	c3                   	ret    

80106899 <sys_sbrk>:

int
sys_sbrk(void)
{
80106899:	55                   	push   %ebp
8010689a:	89 e5                	mov    %esp,%ebp
8010689c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010689f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801068a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068ad:	e8 6f f0 ff ff       	call   80105921 <argint>
801068b2:	85 c0                	test   %eax,%eax
801068b4:	79 07                	jns    801068bd <sys_sbrk+0x24>
    return -1;
801068b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068bb:	eb 23                	jmp    801068e0 <sys_sbrk+0x47>
  addr = myproc()->sz;
801068bd:	e8 b1 db ff ff       	call   80104473 <myproc>
801068c2:	8b 00                	mov    (%eax),%eax
801068c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ca:	89 04 24             	mov    %eax,(%esp)
801068cd:	e8 1c de ff ff       	call   801046ee <growproc>
801068d2:	85 c0                	test   %eax,%eax
801068d4:	79 07                	jns    801068dd <sys_sbrk+0x44>
    return -1;
801068d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068db:	eb 03                	jmp    801068e0 <sys_sbrk+0x47>
  return addr;
801068dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068e0:	c9                   	leave  
801068e1:	c3                   	ret    

801068e2 <sys_sleep>:

int
sys_sleep(void)
{
801068e2:	55                   	push   %ebp
801068e3:	89 e5                	mov    %esp,%ebp
801068e5:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801068ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068f6:	e8 26 f0 ff ff       	call   80105921 <argint>
801068fb:	85 c0                	test   %eax,%eax
801068fd:	79 07                	jns    80106906 <sys_sleep+0x24>
    return -1;
801068ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106904:	eb 6b                	jmp    80106971 <sys_sleep+0x8f>
  acquire(&tickslock);
80106906:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010690d:	e8 79 ea ff ff       	call   8010538b <acquire>
  ticks0 = ticks;
80106912:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106917:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010691a:	eb 33                	jmp    8010694f <sys_sleep+0x6d>
    if(myproc()->killed){
8010691c:	e8 52 db ff ff       	call   80104473 <myproc>
80106921:	8b 40 24             	mov    0x24(%eax),%eax
80106924:	85 c0                	test   %eax,%eax
80106926:	74 13                	je     8010693b <sys_sleep+0x59>
      release(&tickslock);
80106928:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
8010692f:	e8 c1 ea ff ff       	call   801053f5 <release>
      return -1;
80106934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106939:	eb 36                	jmp    80106971 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010693b:	c7 44 24 04 60 73 11 	movl   $0x80117360,0x4(%esp)
80106942:	80 
80106943:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
8010694a:	e8 d5 e3 ff ff       	call   80104d24 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010694f:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106954:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106957:	89 c2                	mov    %eax,%edx
80106959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010695c:	39 c2                	cmp    %eax,%edx
8010695e:	72 bc                	jb     8010691c <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106960:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106967:	e8 89 ea ff ff       	call   801053f5 <release>
  return 0;
8010696c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106971:	c9                   	leave  
80106972:	c3                   	ret    

80106973 <sys_cstop>:

void sys_cstop(){
80106973:	55                   	push   %ebp
80106974:	89 e5                	mov    %esp,%ebp
80106976:	53                   	push   %ebx
80106977:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
8010697a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010697d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106981:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106988:	e8 2b f0 ff ff       	call   801059b8 <argstr>

  if(myproc()->cont != NULL){
8010698d:	e8 e1 da ff ff       	call   80104473 <myproc>
80106992:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106998:	85 c0                	test   %eax,%eax
8010699a:	74 72                	je     80106a0e <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
8010699c:	e8 d2 da ff ff       	call   80104473 <myproc>
801069a1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
801069aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ad:	89 04 24             	mov    %eax,(%esp)
801069b0:	e8 8c ee ff ff       	call   80105841 <strlen>
801069b5:	89 c3                	mov    %eax,%ebx
801069b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ba:	83 c0 18             	add    $0x18,%eax
801069bd:	89 04 24             	mov    %eax,(%esp)
801069c0:	e8 7c ee ff ff       	call   80105841 <strlen>
801069c5:	39 c3                	cmp    %eax,%ebx
801069c7:	75 37                	jne    80106a00 <sys_cstop+0x8d>
801069c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069cc:	89 04 24             	mov    %eax,(%esp)
801069cf:	e8 6d ee ff ff       	call   80105841 <strlen>
801069d4:	89 c2                	mov    %eax,%edx
801069d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d9:	8d 48 18             	lea    0x18(%eax),%ecx
801069dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069df:	89 54 24 08          	mov    %edx,0x8(%esp)
801069e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801069e7:	89 04 24             	mov    %eax,(%esp)
801069ea:	e8 67 ed ff ff       	call   80105756 <strncmp>
801069ef:	85 c0                	test   %eax,%eax
801069f1:	75 0d                	jne    80106a00 <sys_cstop+0x8d>
      cstop_container_helper(cont);
801069f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f6:	89 04 24             	mov    %eax,(%esp)
801069f9:	e8 e2 e5 ff ff       	call   80104fe0 <cstop_container_helper>
801069fe:	eb 19                	jmp    80106a19 <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106a00:	c7 04 24 5c 9a 10 80 	movl   $0x80109a5c,(%esp)
80106a07:	e8 b5 99 ff ff       	call   801003c1 <cprintf>
80106a0c:	eb 0b                	jmp    80106a19 <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a11:	89 04 24             	mov    %eax,(%esp)
80106a14:	e8 2e e6 ff ff       	call   80105047 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106a19:	83 c4 24             	add    $0x24,%esp
80106a1c:	5b                   	pop    %ebx
80106a1d:	5d                   	pop    %ebp
80106a1e:	c3                   	ret    

80106a1f <sys_set_root_inode>:

void sys_set_root_inode(void){
80106a1f:	55                   	push   %ebp
80106a20:	89 e5                	mov    %esp,%ebp
80106a22:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106a25:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a28:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a33:	e8 80 ef ff ff       	call   801059b8 <argstr>

  set_root_inode(name);
80106a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3b:	89 04 24             	mov    %eax,(%esp)
80106a3e:	e8 9c 23 00 00       	call   80108ddf <set_root_inode>
  cprintf("success\n");
80106a43:	c7 04 24 80 9a 10 80 	movl   $0x80109a80,(%esp)
80106a4a:	e8 72 99 ff ff       	call   801003c1 <cprintf>

}
80106a4f:	c9                   	leave  
80106a50:	c3                   	ret    

80106a51 <sys_ps>:

void sys_ps(void){
80106a51:	55                   	push   %ebp
80106a52:	89 e5                	mov    %esp,%ebp
80106a54:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106a57:	e8 17 da ff ff       	call   80104473 <myproc>
80106a5c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a62:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106a65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a69:	75 07                	jne    80106a72 <sys_ps+0x21>
    procdump();
80106a6b:	e8 31 e4 ff ff       	call   80104ea1 <procdump>
80106a70:	eb 0e                	jmp    80106a80 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a75:	83 c0 18             	add    $0x18,%eax
80106a78:	89 04 24             	mov    %eax,(%esp)
80106a7b:	e8 5d e6 ff ff       	call   801050dd <c_procdump>
  }
}
80106a80:	c9                   	leave  
80106a81:	c3                   	ret    

80106a82 <sys_container_init>:

void sys_container_init(){
80106a82:	55                   	push   %ebp
80106a83:	89 e5                	mov    %esp,%ebp
80106a85:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106a88:	e8 31 28 00 00       	call   801092be <container_init>
}
80106a8d:	c9                   	leave  
80106a8e:	c3                   	ret    

80106a8f <sys_is_full>:

int sys_is_full(void){
80106a8f:	55                   	push   %ebp
80106a90:	89 e5                	mov    %esp,%ebp
80106a92:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106a95:	e8 09 24 00 00       	call   80108ea3 <is_full>
}
80106a9a:	c9                   	leave  
80106a9b:	c3                   	ret    

80106a9c <sys_find>:

int sys_find(void){
80106a9c:	55                   	push   %ebp
80106a9d:	89 e5                	mov    %esp,%ebp
80106a9f:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106aa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ab0:	e8 03 ef ff ff       	call   801059b8 <argstr>

  return find(name);
80106ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab8:	89 04 24             	mov    %eax,(%esp)
80106abb:	e8 33 24 00 00       	call   80108ef3 <find>
}
80106ac0:	c9                   	leave  
80106ac1:	c3                   	ret    

80106ac2 <sys_get_name>:

void sys_get_name(void){
80106ac2:	55                   	push   %ebp
80106ac3:	89 e5                	mov    %esp,%ebp
80106ac5:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106acb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ad6:	e8 46 ee ff ff       	call   80105921 <argint>
  argstr(1, &name);
80106adb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ade:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ae2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106ae9:	e8 ca ee ff ff       	call   801059b8 <argstr>

  get_name(vc_num, name);
80106aee:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af4:	89 54 24 04          	mov    %edx,0x4(%esp)
80106af8:	89 04 24             	mov    %eax,(%esp)
80106afb:	e8 20 23 00 00       	call   80108e20 <get_name>
}
80106b00:	c9                   	leave  
80106b01:	c3                   	ret    

80106b02 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106b02:	55                   	push   %ebp
80106b03:	89 e5                	mov    %esp,%ebp
80106b05:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b16:	e8 06 ee ff ff       	call   80105921 <argint>


  return get_max_proc(vc_num);  
80106b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1e:	89 04 24             	mov    %eax,(%esp)
80106b21:	e8 3d 24 00 00       	call   80108f63 <get_max_proc>
}
80106b26:	c9                   	leave  
80106b27:	c3                   	ret    

80106b28 <sys_get_max_mem>:

int sys_get_max_mem(void){
80106b28:	55                   	push   %ebp
80106b29:	89 e5                	mov    %esp,%ebp
80106b2b:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106b2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b31:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b3c:	e8 e0 ed ff ff       	call   80105921 <argint>


  return get_max_mem(vc_num);
80106b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b44:	89 04 24             	mov    %eax,(%esp)
80106b47:	e8 7f 24 00 00       	call   80108fcb <get_max_mem>
}
80106b4c:	c9                   	leave  
80106b4d:	c3                   	ret    

80106b4e <sys_get_max_disk>:

int sys_get_max_disk(void){
80106b4e:	55                   	push   %ebp
80106b4f:	89 e5                	mov    %esp,%ebp
80106b51:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b57:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b62:	e8 ba ed ff ff       	call   80105921 <argint>


  return get_max_disk(vc_num);
80106b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6a:	89 04 24             	mov    %eax,(%esp)
80106b6d:	e8 99 24 00 00       	call   8010900b <get_max_disk>

}
80106b72:	c9                   	leave  
80106b73:	c3                   	ret    

80106b74 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106b74:	55                   	push   %ebp
80106b75:	89 e5                	mov    %esp,%ebp
80106b77:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106b7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b88:	e8 94 ed ff ff       	call   80105921 <argint>


  return get_curr_proc(vc_num);
80106b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b90:	89 04 24             	mov    %eax,(%esp)
80106b93:	e8 b3 24 00 00       	call   8010904b <get_curr_proc>
}
80106b98:	c9                   	leave  
80106b99:	c3                   	ret    

80106b9a <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106b9a:	55                   	push   %ebp
80106b9b:	89 e5                	mov    %esp,%ebp
80106b9d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ba7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bae:	e8 6e ed ff ff       	call   80105921 <argint>


  return get_curr_mem(vc_num);
80106bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb6:	89 04 24             	mov    %eax,(%esp)
80106bb9:	e8 cd 24 00 00       	call   8010908b <get_curr_mem>
}
80106bbe:	c9                   	leave  
80106bbf:	c3                   	ret    

80106bc0 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106bc0:	55                   	push   %ebp
80106bc1:	89 e5                	mov    %esp,%ebp
80106bc3:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bd4:	e8 48 ed ff ff       	call   80105921 <argint>


  return get_curr_disk(vc_num);
80106bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bdc:	89 04 24             	mov    %eax,(%esp)
80106bdf:	e8 fa 24 00 00       	call   801090de <get_curr_disk>
}
80106be4:	c9                   	leave  
80106be5:	c3                   	ret    

80106be6 <sys_set_name>:

void sys_set_name(void){
80106be6:	55                   	push   %ebp
80106be7:	89 e5                	mov    %esp,%ebp
80106be9:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bef:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bfa:	e8 b9 ed ff ff       	call   801059b8 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c02:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c0d:	e8 0f ed ff ff       	call   80105921 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106c12:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c18:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c1c:	89 04 24             	mov    %eax,(%esp)
80106c1f:	e8 fa 24 00 00       	call   8010911e <set_name>
  //cprintf("Done setting name.\n");
}
80106c24:	c9                   	leave  
80106c25:	c3                   	ret    

80106c26 <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106c26:	55                   	push   %ebp
80106c27:	89 e5                	mov    %esp,%ebp
80106c29:	53                   	push   %ebx
80106c2a:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106c2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c30:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c3b:	e8 e1 ec ff ff       	call   80105921 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106c40:	e8 2e d8 ff ff       	call   80104473 <myproc>
80106c45:	89 c3                	mov    %eax,%ebx
80106c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c4a:	89 04 24             	mov    %eax,(%esp)
80106c4d:	e8 51 23 00 00       	call   80108fa3 <get_container>
80106c52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106c58:	83 c4 24             	add    $0x24,%esp
80106c5b:	5b                   	pop    %ebx
80106c5c:	5d                   	pop    %ebp
80106c5d:	c3                   	ret    

80106c5e <sys_set_max_mem>:

void sys_set_max_mem(void){
80106c5e:	55                   	push   %ebp
80106c5f:	89 e5                	mov    %esp,%ebp
80106c61:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c67:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c72:	e8 aa ec ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106c77:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c85:	e8 97 ec ff ff       	call   80105921 <argint>

  set_max_mem(mem, vc_num);
80106c8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c90:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c94:	89 04 24             	mov    %eax,(%esp)
80106c97:	e8 b9 24 00 00       	call   80109155 <set_max_mem>
}
80106c9c:	c9                   	leave  
80106c9d:	c3                   	ret    

80106c9e <sys_set_max_disk>:

void sys_set_max_disk(void){
80106c9e:	55                   	push   %ebp
80106c9f:	89 e5                	mov    %esp,%ebp
80106ca1:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106ca4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cb2:	e8 6a ec ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106cb7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cba:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cbe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106cc5:	e8 57 ec ff ff       	call   80105921 <argint>

  set_max_disk(disk, vc_num);
80106cca:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd0:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cd4:	89 04 24             	mov    %eax,(%esp)
80106cd7:	e8 9e 24 00 00       	call   8010917a <set_max_disk>
}
80106cdc:	c9                   	leave  
80106cdd:	c3                   	ret    

80106cde <sys_set_max_proc>:

void sys_set_max_proc(void){
80106cde:	55                   	push   %ebp
80106cdf:	89 e5                	mov    %esp,%ebp
80106ce1:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ceb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cf2:	e8 2a ec ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106cf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d05:	e8 17 ec ff ff       	call   80105921 <argint>

  set_max_proc(proc, vc_num);
80106d0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d10:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d14:	89 04 24             	mov    %eax,(%esp)
80106d17:	e8 84 24 00 00       	call   801091a0 <set_max_proc>
}
80106d1c:	c9                   	leave  
80106d1d:	c3                   	ret    

80106d1e <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106d1e:	55                   	push   %ebp
80106d1f:	89 e5                	mov    %esp,%ebp
80106d21:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106d24:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d27:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d32:	e8 ea eb ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106d37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d45:	e8 d7 eb ff ff       	call   80105921 <argint>

  set_curr_mem(mem, vc_num);
80106d4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d50:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d54:	89 04 24             	mov    %eax,(%esp)
80106d57:	e8 6a 24 00 00       	call   801091c6 <set_curr_mem>
}
80106d5c:	c9                   	leave  
80106d5d:	c3                   	ret    

80106d5e <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106d5e:	55                   	push   %ebp
80106d5f:	89 e5                	mov    %esp,%ebp
80106d61:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d67:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d72:	e8 aa eb ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106d77:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d85:	e8 97 eb ff ff       	call   80105921 <argint>

  set_curr_mem(mem, vc_num);
80106d8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d90:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d94:	89 04 24             	mov    %eax,(%esp)
80106d97:	e8 2a 24 00 00       	call   801091c6 <set_curr_mem>
}
80106d9c:	c9                   	leave  
80106d9d:	c3                   	ret    

80106d9e <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106d9e:	55                   	push   %ebp
80106d9f:	89 e5                	mov    %esp,%ebp
80106da1:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106da7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106db2:	e8 6a eb ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106db7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dba:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dbe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106dc5:	e8 57 eb ff ff       	call   80105921 <argint>

  set_curr_disk(disk, vc_num);
80106dca:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd0:	89 54 24 04          	mov    %edx,0x4(%esp)
80106dd4:	89 04 24             	mov    %eax,(%esp)
80106dd7:	e8 6e 24 00 00       	call   8010924a <set_curr_disk>
}
80106ddc:	c9                   	leave  
80106ddd:	c3                   	ret    

80106dde <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106dde:	55                   	push   %ebp
80106ddf:	89 e5                	mov    %esp,%ebp
80106de1:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106de7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106deb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106df2:	e8 2a eb ff ff       	call   80105921 <argint>

  int vc_num;
  argint(1, &vc_num);
80106df7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e05:	e8 17 eb ff ff       	call   80105921 <argint>

  set_curr_proc(proc, vc_num);
80106e0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e10:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e14:	89 04 24             	mov    %eax,(%esp)
80106e17:	e8 73 24 00 00       	call   8010928f <set_curr_proc>
}
80106e1c:	c9                   	leave  
80106e1d:	c3                   	ret    

80106e1e <sys_container_reset>:

void sys_container_reset(void){
80106e1e:	55                   	push   %ebp
80106e1f:	89 e5                	mov    %esp,%ebp
80106e21:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
80106e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e27:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e2b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e32:	e8 ea ea ff ff       	call   80105921 <argint>
  container_reset(vc_num);
80106e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e3a:	89 04 24             	mov    %eax,(%esp)
80106e3d:	e8 91 25 00 00       	call   801093d3 <container_reset>
}
80106e42:	c9                   	leave  
80106e43:	c3                   	ret    

80106e44 <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106e44:	55                   	push   %ebp
80106e45:	89 e5                	mov    %esp,%ebp
80106e47:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106e4a:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106e51:	e8 35 e5 ff ff       	call   8010538b <acquire>
  xticks = ticks;
80106e56:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
80106e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106e5e:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80106e65:	e8 8b e5 ff ff       	call   801053f5 <release>
  return xticks;
80106e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106e6d:	c9                   	leave  
80106e6e:	c3                   	ret    

80106e6f <sys_getticks>:

int
sys_getticks(void){
80106e6f:	55                   	push   %ebp
80106e70:	89 e5                	mov    %esp,%ebp
80106e72:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106e75:	e8 f9 d5 ff ff       	call   80104473 <myproc>
80106e7a:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106e7d:	c9                   	leave  
80106e7e:	c3                   	ret    

80106e7f <sys_max_containers>:

int sys_max_containers(void){
80106e7f:	55                   	push   %ebp
80106e80:	89 e5                	mov    %esp,%ebp
80106e82:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
80106e85:	e8 2a 24 00 00       	call   801092b4 <max_containers>
}
80106e8a:	c9                   	leave  
80106e8b:	c3                   	ret    

80106e8c <sys_df>:


void sys_df(void){
80106e8c:	55                   	push   %ebp
80106e8d:	89 e5                	mov    %esp,%ebp
80106e8f:	83 ec 38             	sub    $0x38,%esp
  struct container* cont = myproc()->cont;
80106e92:	e8 dc d5 ff ff       	call   80104473 <myproc>
80106e97:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106e9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int used = 0;
80106ea0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80106ea7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106eab:	75 4b                	jne    80106ef8 <sys_df+0x6c>
    int max = max_containers();
80106ead:	e8 02 24 00 00       	call   801092b4 <max_containers>
80106eb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
80106eb5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106ebc:	eb 1d                	jmp    80106edb <sys_df+0x4f>
      used = used + (int)(get_curr_disk(i) / 1024);
80106ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ec1:	89 04 24             	mov    %eax,(%esp)
80106ec4:	e8 15 22 00 00       	call   801090de <get_curr_disk>
80106ec9:	85 c0                	test   %eax,%eax
80106ecb:	79 05                	jns    80106ed2 <sys_df+0x46>
80106ecd:	05 ff 03 00 00       	add    $0x3ff,%eax
80106ed2:	c1 f8 0a             	sar    $0xa,%eax
80106ed5:	01 45 f4             	add    %eax,-0xc(%ebp)
  struct container* cont = myproc()->cont;
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
80106ed8:	ff 45 f0             	incl   -0x10(%ebp)
80106edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ede:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80106ee1:	7c db                	jl     80106ebe <sys_df+0x32>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: TBD\n", used);
80106ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
80106eea:	c7 04 24 8c 9a 10 80 	movl   $0x80109a8c,(%esp)
80106ef1:	e8 cb 94 ff ff       	call   801003c1 <cprintf>
80106ef6:	eb 4d                	jmp    80106f45 <sys_df+0xb9>
  }
  else{
    int x = find(cont->name);
80106ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106efb:	83 c0 18             	add    $0x18,%eax
80106efe:	89 04 24             	mov    %eax,(%esp)
80106f01:	e8 ed 1f 00 00       	call   80108ef3 <find>
80106f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
80106f09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f0c:	89 04 24             	mov    %eax,(%esp)
80106f0f:	e8 ca 21 00 00       	call   801090de <get_curr_disk>
80106f14:	85 c0                	test   %eax,%eax
80106f16:	79 05                	jns    80106f1d <sys_df+0x91>
80106f18:	05 ff 03 00 00       	add    $0x3ff,%eax
80106f1d:	c1 f8 0a             	sar    $0xa,%eax
80106f20:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d / Disk Available: %d\n", used, get_max_disk(x));
80106f23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f26:	89 04 24             	mov    %eax,(%esp)
80106f29:	e8 dd 20 00 00       	call   8010900b <get_max_disk>
80106f2e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106f32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106f35:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f39:	c7 04 24 c0 9a 10 80 	movl   $0x80109ac0,(%esp)
80106f40:	e8 7c 94 ff ff       	call   801003c1 <cprintf>
  }
}
80106f45:	c9                   	leave  
80106f46:	c3                   	ret    
	...

80106f48 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106f48:	1e                   	push   %ds
  pushl %es
80106f49:	06                   	push   %es
  pushl %fs
80106f4a:	0f a0                	push   %fs
  pushl %gs
80106f4c:	0f a8                	push   %gs
  pushal
80106f4e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106f4f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106f53:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106f55:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106f57:	54                   	push   %esp
  call trap
80106f58:	e8 c0 01 00 00       	call   8010711d <trap>
  addl $4, %esp
80106f5d:	83 c4 04             	add    $0x4,%esp

80106f60 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106f60:	61                   	popa   
  popl %gs
80106f61:	0f a9                	pop    %gs
  popl %fs
80106f63:	0f a1                	pop    %fs
  popl %es
80106f65:	07                   	pop    %es
  popl %ds
80106f66:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106f67:	83 c4 08             	add    $0x8,%esp
  iret
80106f6a:	cf                   	iret   
	...

80106f6c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106f6c:	55                   	push   %ebp
80106f6d:	89 e5                	mov    %esp,%ebp
80106f6f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f75:	48                   	dec    %eax
80106f76:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f81:	8b 45 08             	mov    0x8(%ebp),%eax
80106f84:	c1 e8 10             	shr    $0x10,%eax
80106f87:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106f8b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f8e:	0f 01 18             	lidtl  (%eax)
}
80106f91:	c9                   	leave  
80106f92:	c3                   	ret    

80106f93 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106f93:	55                   	push   %ebp
80106f94:	89 e5                	mov    %esp,%ebp
80106f96:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106f99:	0f 20 d0             	mov    %cr2,%eax
80106f9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106f9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106fa2:	c9                   	leave  
80106fa3:	c3                   	ret    

80106fa4 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106fa4:	55                   	push   %ebp
80106fa5:	89 e5                	mov    %esp,%ebp
80106fa7:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106faa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106fb1:	e9 b8 00 00 00       	jmp    8010706e <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb9:	8b 04 85 00 c1 10 80 	mov    -0x7fef3f00(,%eax,4),%eax
80106fc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fc3:	66 89 04 d5 a0 73 11 	mov    %ax,-0x7fee8c60(,%edx,8)
80106fca:	80 
80106fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fce:	66 c7 04 c5 a2 73 11 	movw   $0x8,-0x7fee8c5e(,%eax,8)
80106fd5:	80 08 00 
80106fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fdb:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106fe2:	83 e2 e0             	and    $0xffffffe0,%edx
80106fe5:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80106fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fef:	8a 14 c5 a4 73 11 80 	mov    -0x7fee8c5c(,%eax,8),%dl
80106ff6:	83 e2 1f             	and    $0x1f,%edx
80106ff9:	88 14 c5 a4 73 11 80 	mov    %dl,-0x7fee8c5c(,%eax,8)
80107000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107003:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
8010700a:	83 e2 f0             	and    $0xfffffff0,%edx
8010700d:	83 ca 0e             	or     $0xe,%edx
80107010:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80107017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701a:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80107021:	83 e2 ef             	and    $0xffffffef,%edx
80107024:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
8010702b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702e:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80107035:	83 e2 9f             	and    $0xffffff9f,%edx
80107038:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
8010703f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107042:	8a 14 c5 a5 73 11 80 	mov    -0x7fee8c5b(,%eax,8),%dl
80107049:	83 ca 80             	or     $0xffffff80,%edx
8010704c:	88 14 c5 a5 73 11 80 	mov    %dl,-0x7fee8c5b(,%eax,8)
80107053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107056:	8b 04 85 00 c1 10 80 	mov    -0x7fef3f00(,%eax,4),%eax
8010705d:	c1 e8 10             	shr    $0x10,%eax
80107060:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107063:	66 89 04 d5 a6 73 11 	mov    %ax,-0x7fee8c5a(,%edx,8)
8010706a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010706b:	ff 45 f4             	incl   -0xc(%ebp)
8010706e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107075:	0f 8e 3b ff ff ff    	jle    80106fb6 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010707b:	a1 00 c2 10 80       	mov    0x8010c200,%eax
80107080:	66 a3 a0 75 11 80    	mov    %ax,0x801175a0
80107086:	66 c7 05 a2 75 11 80 	movw   $0x8,0x801175a2
8010708d:	08 00 
8010708f:	a0 a4 75 11 80       	mov    0x801175a4,%al
80107094:	83 e0 e0             	and    $0xffffffe0,%eax
80107097:	a2 a4 75 11 80       	mov    %al,0x801175a4
8010709c:	a0 a4 75 11 80       	mov    0x801175a4,%al
801070a1:	83 e0 1f             	and    $0x1f,%eax
801070a4:	a2 a4 75 11 80       	mov    %al,0x801175a4
801070a9:	a0 a5 75 11 80       	mov    0x801175a5,%al
801070ae:	83 c8 0f             	or     $0xf,%eax
801070b1:	a2 a5 75 11 80       	mov    %al,0x801175a5
801070b6:	a0 a5 75 11 80       	mov    0x801175a5,%al
801070bb:	83 e0 ef             	and    $0xffffffef,%eax
801070be:	a2 a5 75 11 80       	mov    %al,0x801175a5
801070c3:	a0 a5 75 11 80       	mov    0x801175a5,%al
801070c8:	83 c8 60             	or     $0x60,%eax
801070cb:	a2 a5 75 11 80       	mov    %al,0x801175a5
801070d0:	a0 a5 75 11 80       	mov    0x801175a5,%al
801070d5:	83 c8 80             	or     $0xffffff80,%eax
801070d8:	a2 a5 75 11 80       	mov    %al,0x801175a5
801070dd:	a1 00 c2 10 80       	mov    0x8010c200,%eax
801070e2:	c1 e8 10             	shr    $0x10,%eax
801070e5:	66 a3 a6 75 11 80    	mov    %ax,0x801175a6

  initlock(&tickslock, "time");
801070eb:	c7 44 24 04 e8 9a 10 	movl   $0x80109ae8,0x4(%esp)
801070f2:	80 
801070f3:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801070fa:	e8 6b e2 ff ff       	call   8010536a <initlock>
}
801070ff:	c9                   	leave  
80107100:	c3                   	ret    

80107101 <idtinit>:

void
idtinit(void)
{
80107101:	55                   	push   %ebp
80107102:	89 e5                	mov    %esp,%ebp
80107104:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80107107:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010710e:	00 
8010710f:	c7 04 24 a0 73 11 80 	movl   $0x801173a0,(%esp)
80107116:	e8 51 fe ff ff       	call   80106f6c <lidt>
}
8010711b:	c9                   	leave  
8010711c:	c3                   	ret    

8010711d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010711d:	55                   	push   %ebp
8010711e:	89 e5                	mov    %esp,%ebp
80107120:	57                   	push   %edi
80107121:	56                   	push   %esi
80107122:	53                   	push   %ebx
80107123:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80107126:	8b 45 08             	mov    0x8(%ebp),%eax
80107129:	8b 40 30             	mov    0x30(%eax),%eax
8010712c:	83 f8 40             	cmp    $0x40,%eax
8010712f:	75 3c                	jne    8010716d <trap+0x50>
    if(myproc()->killed)
80107131:	e8 3d d3 ff ff       	call   80104473 <myproc>
80107136:	8b 40 24             	mov    0x24(%eax),%eax
80107139:	85 c0                	test   %eax,%eax
8010713b:	74 05                	je     80107142 <trap+0x25>
      exit();
8010713d:	e8 c2 d7 ff ff       	call   80104904 <exit>
    myproc()->tf = tf;
80107142:	e8 2c d3 ff ff       	call   80104473 <myproc>
80107147:	8b 55 08             	mov    0x8(%ebp),%edx
8010714a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010714d:	e8 9d e8 ff ff       	call   801059ef <syscall>
    if(myproc()->killed)
80107152:	e8 1c d3 ff ff       	call   80104473 <myproc>
80107157:	8b 40 24             	mov    0x24(%eax),%eax
8010715a:	85 c0                	test   %eax,%eax
8010715c:	74 0a                	je     80107168 <trap+0x4b>
      exit();
8010715e:	e8 a1 d7 ff ff       	call   80104904 <exit>
    return;
80107163:	e9 30 02 00 00       	jmp    80107398 <trap+0x27b>
80107168:	e9 2b 02 00 00       	jmp    80107398 <trap+0x27b>
  }

  switch(tf->trapno){
8010716d:	8b 45 08             	mov    0x8(%ebp),%eax
80107170:	8b 40 30             	mov    0x30(%eax),%eax
80107173:	83 e8 20             	sub    $0x20,%eax
80107176:	83 f8 1f             	cmp    $0x1f,%eax
80107179:	0f 87 cb 00 00 00    	ja     8010724a <trap+0x12d>
8010717f:	8b 04 85 90 9b 10 80 	mov    -0x7fef6470(,%eax,4),%eax
80107186:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107188:	e8 1d d2 ff ff       	call   801043aa <cpuid>
8010718d:	85 c0                	test   %eax,%eax
8010718f:	75 2f                	jne    801071c0 <trap+0xa3>
      acquire(&tickslock);
80107191:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
80107198:	e8 ee e1 ff ff       	call   8010538b <acquire>
      ticks++;
8010719d:	a1 a0 7b 11 80       	mov    0x80117ba0,%eax
801071a2:	40                   	inc    %eax
801071a3:	a3 a0 7b 11 80       	mov    %eax,0x80117ba0
      wakeup(&ticks);
801071a8:	c7 04 24 a0 7b 11 80 	movl   $0x80117ba0,(%esp)
801071af:	e8 47 dc ff ff       	call   80104dfb <wakeup>
      release(&tickslock);
801071b4:	c7 04 24 60 73 11 80 	movl   $0x80117360,(%esp)
801071bb:	e8 35 e2 ff ff       	call   801053f5 <release>
    }
    p = myproc();
801071c0:	e8 ae d2 ff ff       	call   80104473 <myproc>
801071c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801071c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801071cc:	74 0f                	je     801071dd <trap+0xc0>
      p->ticks++;
801071ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071d1:	8b 40 7c             	mov    0x7c(%eax),%eax
801071d4:	8d 50 01             	lea    0x1(%eax),%edx
801071d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071da:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801071dd:	e8 69 c0 ff ff       	call   8010324b <lapiceoi>
    break;
801071e2:	e9 35 01 00 00       	jmp    8010731c <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801071e7:	e8 5e b8 ff ff       	call   80102a4a <ideintr>
    lapiceoi();
801071ec:	e8 5a c0 ff ff       	call   8010324b <lapiceoi>
    break;
801071f1:	e9 26 01 00 00       	jmp    8010731c <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801071f6:	e8 67 be ff ff       	call   80103062 <kbdintr>
    lapiceoi();
801071fb:	e8 4b c0 ff ff       	call   8010324b <lapiceoi>
    break;
80107200:	e9 17 01 00 00       	jmp    8010731c <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107205:	e8 6f 03 00 00       	call   80107579 <uartintr>
    lapiceoi();
8010720a:	e8 3c c0 ff ff       	call   8010324b <lapiceoi>
    break;
8010720f:	e9 08 01 00 00       	jmp    8010731c <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107214:	8b 45 08             	mov    0x8(%ebp),%eax
80107217:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010721a:	8b 45 08             	mov    0x8(%ebp),%eax
8010721d:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107220:	0f b7 d8             	movzwl %ax,%ebx
80107223:	e8 82 d1 ff ff       	call   801043aa <cpuid>
80107228:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010722c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107230:	89 44 24 04          	mov    %eax,0x4(%esp)
80107234:	c7 04 24 f0 9a 10 80 	movl   $0x80109af0,(%esp)
8010723b:	e8 81 91 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107240:	e8 06 c0 ff ff       	call   8010324b <lapiceoi>
    break;
80107245:	e9 d2 00 00 00       	jmp    8010731c <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010724a:	e8 24 d2 ff ff       	call   80104473 <myproc>
8010724f:	85 c0                	test   %eax,%eax
80107251:	74 10                	je     80107263 <trap+0x146>
80107253:	8b 45 08             	mov    0x8(%ebp),%eax
80107256:	8b 40 3c             	mov    0x3c(%eax),%eax
80107259:	0f b7 c0             	movzwl %ax,%eax
8010725c:	83 e0 03             	and    $0x3,%eax
8010725f:	85 c0                	test   %eax,%eax
80107261:	75 40                	jne    801072a3 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107263:	e8 2b fd ff ff       	call   80106f93 <rcr2>
80107268:	89 c3                	mov    %eax,%ebx
8010726a:	8b 45 08             	mov    0x8(%ebp),%eax
8010726d:	8b 70 38             	mov    0x38(%eax),%esi
80107270:	e8 35 d1 ff ff       	call   801043aa <cpuid>
80107275:	8b 55 08             	mov    0x8(%ebp),%edx
80107278:	8b 52 30             	mov    0x30(%edx),%edx
8010727b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010727f:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107283:	89 44 24 08          	mov    %eax,0x8(%esp)
80107287:	89 54 24 04          	mov    %edx,0x4(%esp)
8010728b:	c7 04 24 14 9b 10 80 	movl   $0x80109b14,(%esp)
80107292:	e8 2a 91 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107297:	c7 04 24 46 9b 10 80 	movl   $0x80109b46,(%esp)
8010729e:	e8 b1 92 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801072a3:	e8 eb fc ff ff       	call   80106f93 <rcr2>
801072a8:	89 c6                	mov    %eax,%esi
801072aa:	8b 45 08             	mov    0x8(%ebp),%eax
801072ad:	8b 40 38             	mov    0x38(%eax),%eax
801072b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801072b3:	e8 f2 d0 ff ff       	call   801043aa <cpuid>
801072b8:	89 c3                	mov    %eax,%ebx
801072ba:	8b 45 08             	mov    0x8(%ebp),%eax
801072bd:	8b 78 34             	mov    0x34(%eax),%edi
801072c0:	89 7d d0             	mov    %edi,-0x30(%ebp)
801072c3:	8b 45 08             	mov    0x8(%ebp),%eax
801072c6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801072c9:	e8 a5 d1 ff ff       	call   80104473 <myproc>
801072ce:	8d 50 6c             	lea    0x6c(%eax),%edx
801072d1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801072d4:	e8 9a d1 ff ff       	call   80104473 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801072d9:	8b 40 10             	mov    0x10(%eax),%eax
801072dc:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801072e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801072e3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801072e7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801072eb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801072ee:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801072f2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801072f6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801072f9:	89 54 24 08          	mov    %edx,0x8(%esp)
801072fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80107301:	c7 04 24 4c 9b 10 80 	movl   $0x80109b4c,(%esp)
80107308:	e8 b4 90 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010730d:	e8 61 d1 ff ff       	call   80104473 <myproc>
80107312:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107319:	eb 01                	jmp    8010731c <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010731b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010731c:	e8 52 d1 ff ff       	call   80104473 <myproc>
80107321:	85 c0                	test   %eax,%eax
80107323:	74 22                	je     80107347 <trap+0x22a>
80107325:	e8 49 d1 ff ff       	call   80104473 <myproc>
8010732a:	8b 40 24             	mov    0x24(%eax),%eax
8010732d:	85 c0                	test   %eax,%eax
8010732f:	74 16                	je     80107347 <trap+0x22a>
80107331:	8b 45 08             	mov    0x8(%ebp),%eax
80107334:	8b 40 3c             	mov    0x3c(%eax),%eax
80107337:	0f b7 c0             	movzwl %ax,%eax
8010733a:	83 e0 03             	and    $0x3,%eax
8010733d:	83 f8 03             	cmp    $0x3,%eax
80107340:	75 05                	jne    80107347 <trap+0x22a>
    exit();
80107342:	e8 bd d5 ff ff       	call   80104904 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107347:	e8 27 d1 ff ff       	call   80104473 <myproc>
8010734c:	85 c0                	test   %eax,%eax
8010734e:	74 1d                	je     8010736d <trap+0x250>
80107350:	e8 1e d1 ff ff       	call   80104473 <myproc>
80107355:	8b 40 0c             	mov    0xc(%eax),%eax
80107358:	83 f8 04             	cmp    $0x4,%eax
8010735b:	75 10                	jne    8010736d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010735d:	8b 45 08             	mov    0x8(%ebp),%eax
80107360:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107363:	83 f8 20             	cmp    $0x20,%eax
80107366:	75 05                	jne    8010736d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107368:	e8 47 d9 ff ff       	call   80104cb4 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010736d:	e8 01 d1 ff ff       	call   80104473 <myproc>
80107372:	85 c0                	test   %eax,%eax
80107374:	74 22                	je     80107398 <trap+0x27b>
80107376:	e8 f8 d0 ff ff       	call   80104473 <myproc>
8010737b:	8b 40 24             	mov    0x24(%eax),%eax
8010737e:	85 c0                	test   %eax,%eax
80107380:	74 16                	je     80107398 <trap+0x27b>
80107382:	8b 45 08             	mov    0x8(%ebp),%eax
80107385:	8b 40 3c             	mov    0x3c(%eax),%eax
80107388:	0f b7 c0             	movzwl %ax,%eax
8010738b:	83 e0 03             	and    $0x3,%eax
8010738e:	83 f8 03             	cmp    $0x3,%eax
80107391:	75 05                	jne    80107398 <trap+0x27b>
    exit();
80107393:	e8 6c d5 ff ff       	call   80104904 <exit>
}
80107398:	83 c4 4c             	add    $0x4c,%esp
8010739b:	5b                   	pop    %ebx
8010739c:	5e                   	pop    %esi
8010739d:	5f                   	pop    %edi
8010739e:	5d                   	pop    %ebp
8010739f:	c3                   	ret    

801073a0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801073a0:	55                   	push   %ebp
801073a1:	89 e5                	mov    %esp,%ebp
801073a3:	83 ec 14             	sub    $0x14,%esp
801073a6:	8b 45 08             	mov    0x8(%ebp),%eax
801073a9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801073ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073b0:	89 c2                	mov    %eax,%edx
801073b2:	ec                   	in     (%dx),%al
801073b3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801073b6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801073b9:	c9                   	leave  
801073ba:	c3                   	ret    

801073bb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801073bb:	55                   	push   %ebp
801073bc:	89 e5                	mov    %esp,%ebp
801073be:	83 ec 08             	sub    $0x8,%esp
801073c1:	8b 45 08             	mov    0x8(%ebp),%eax
801073c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801073c7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801073cb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801073ce:	8a 45 f8             	mov    -0x8(%ebp),%al
801073d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801073d4:	ee                   	out    %al,(%dx)
}
801073d5:	c9                   	leave  
801073d6:	c3                   	ret    

801073d7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801073d7:	55                   	push   %ebp
801073d8:	89 e5                	mov    %esp,%ebp
801073da:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801073dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801073e4:	00 
801073e5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801073ec:	e8 ca ff ff ff       	call   801073bb <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801073f1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801073f8:	00 
801073f9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107400:	e8 b6 ff ff ff       	call   801073bb <outb>
  outb(COM1+0, 115200/9600);
80107405:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
8010740c:	00 
8010740d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107414:	e8 a2 ff ff ff       	call   801073bb <outb>
  outb(COM1+1, 0);
80107419:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107420:	00 
80107421:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107428:	e8 8e ff ff ff       	call   801073bb <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010742d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107434:	00 
80107435:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010743c:	e8 7a ff ff ff       	call   801073bb <outb>
  outb(COM1+4, 0);
80107441:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107448:	00 
80107449:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107450:	e8 66 ff ff ff       	call   801073bb <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107455:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010745c:	00 
8010745d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107464:	e8 52 ff ff ff       	call   801073bb <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107469:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107470:	e8 2b ff ff ff       	call   801073a0 <inb>
80107475:	3c ff                	cmp    $0xff,%al
80107477:	75 02                	jne    8010747b <uartinit+0xa4>
    return;
80107479:	eb 5b                	jmp    801074d6 <uartinit+0xff>
  uart = 1;
8010747b:	c7 05 04 c9 10 80 01 	movl   $0x1,0x8010c904
80107482:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107485:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010748c:	e8 0f ff ff ff       	call   801073a0 <inb>
  inb(COM1+0);
80107491:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107498:	e8 03 ff ff ff       	call   801073a0 <inb>
  ioapicenable(IRQ_COM1, 0);
8010749d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801074a4:	00 
801074a5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801074ac:	e8 0e b8 ff ff       	call   80102cbf <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801074b1:	c7 45 f4 10 9c 10 80 	movl   $0x80109c10,-0xc(%ebp)
801074b8:	eb 13                	jmp    801074cd <uartinit+0xf6>
    uartputc(*p);
801074ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bd:	8a 00                	mov    (%eax),%al
801074bf:	0f be c0             	movsbl %al,%eax
801074c2:	89 04 24             	mov    %eax,(%esp)
801074c5:	e8 0e 00 00 00       	call   801074d8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801074ca:	ff 45 f4             	incl   -0xc(%ebp)
801074cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d0:	8a 00                	mov    (%eax),%al
801074d2:	84 c0                	test   %al,%al
801074d4:	75 e4                	jne    801074ba <uartinit+0xe3>
    uartputc(*p);
}
801074d6:	c9                   	leave  
801074d7:	c3                   	ret    

801074d8 <uartputc>:

void
uartputc(int c)
{
801074d8:	55                   	push   %ebp
801074d9:	89 e5                	mov    %esp,%ebp
801074db:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801074de:	a1 04 c9 10 80       	mov    0x8010c904,%eax
801074e3:	85 c0                	test   %eax,%eax
801074e5:	75 02                	jne    801074e9 <uartputc+0x11>
    return;
801074e7:	eb 4a                	jmp    80107533 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801074e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074f0:	eb 0f                	jmp    80107501 <uartputc+0x29>
    microdelay(10);
801074f2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801074f9:	e8 72 bd ff ff       	call   80103270 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801074fe:	ff 45 f4             	incl   -0xc(%ebp)
80107501:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107505:	7f 16                	jg     8010751d <uartputc+0x45>
80107507:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010750e:	e8 8d fe ff ff       	call   801073a0 <inb>
80107513:	0f b6 c0             	movzbl %al,%eax
80107516:	83 e0 20             	and    $0x20,%eax
80107519:	85 c0                	test   %eax,%eax
8010751b:	74 d5                	je     801074f2 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
8010751d:	8b 45 08             	mov    0x8(%ebp),%eax
80107520:	0f b6 c0             	movzbl %al,%eax
80107523:	89 44 24 04          	mov    %eax,0x4(%esp)
80107527:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010752e:	e8 88 fe ff ff       	call   801073bb <outb>
}
80107533:	c9                   	leave  
80107534:	c3                   	ret    

80107535 <uartgetc>:

static int
uartgetc(void)
{
80107535:	55                   	push   %ebp
80107536:	89 e5                	mov    %esp,%ebp
80107538:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010753b:	a1 04 c9 10 80       	mov    0x8010c904,%eax
80107540:	85 c0                	test   %eax,%eax
80107542:	75 07                	jne    8010754b <uartgetc+0x16>
    return -1;
80107544:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107549:	eb 2c                	jmp    80107577 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010754b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107552:	e8 49 fe ff ff       	call   801073a0 <inb>
80107557:	0f b6 c0             	movzbl %al,%eax
8010755a:	83 e0 01             	and    $0x1,%eax
8010755d:	85 c0                	test   %eax,%eax
8010755f:	75 07                	jne    80107568 <uartgetc+0x33>
    return -1;
80107561:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107566:	eb 0f                	jmp    80107577 <uartgetc+0x42>
  return inb(COM1+0);
80107568:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010756f:	e8 2c fe ff ff       	call   801073a0 <inb>
80107574:	0f b6 c0             	movzbl %al,%eax
}
80107577:	c9                   	leave  
80107578:	c3                   	ret    

80107579 <uartintr>:

void
uartintr(void)
{
80107579:	55                   	push   %ebp
8010757a:	89 e5                	mov    %esp,%ebp
8010757c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010757f:	c7 04 24 35 75 10 80 	movl   $0x80107535,(%esp)
80107586:	e8 6a 92 ff ff       	call   801007f5 <consoleintr>
}
8010758b:	c9                   	leave  
8010758c:	c3                   	ret    
8010758d:	00 00                	add    %al,(%eax)
	...

80107590 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $0
80107592:	6a 00                	push   $0x0
  jmp alltraps
80107594:	e9 af f9 ff ff       	jmp    80106f48 <alltraps>

80107599 <vector1>:
.globl vector1
vector1:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $1
8010759b:	6a 01                	push   $0x1
  jmp alltraps
8010759d:	e9 a6 f9 ff ff       	jmp    80106f48 <alltraps>

801075a2 <vector2>:
.globl vector2
vector2:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $2
801075a4:	6a 02                	push   $0x2
  jmp alltraps
801075a6:	e9 9d f9 ff ff       	jmp    80106f48 <alltraps>

801075ab <vector3>:
.globl vector3
vector3:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $3
801075ad:	6a 03                	push   $0x3
  jmp alltraps
801075af:	e9 94 f9 ff ff       	jmp    80106f48 <alltraps>

801075b4 <vector4>:
.globl vector4
vector4:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $4
801075b6:	6a 04                	push   $0x4
  jmp alltraps
801075b8:	e9 8b f9 ff ff       	jmp    80106f48 <alltraps>

801075bd <vector5>:
.globl vector5
vector5:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $5
801075bf:	6a 05                	push   $0x5
  jmp alltraps
801075c1:	e9 82 f9 ff ff       	jmp    80106f48 <alltraps>

801075c6 <vector6>:
.globl vector6
vector6:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $6
801075c8:	6a 06                	push   $0x6
  jmp alltraps
801075ca:	e9 79 f9 ff ff       	jmp    80106f48 <alltraps>

801075cf <vector7>:
.globl vector7
vector7:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $7
801075d1:	6a 07                	push   $0x7
  jmp alltraps
801075d3:	e9 70 f9 ff ff       	jmp    80106f48 <alltraps>

801075d8 <vector8>:
.globl vector8
vector8:
  pushl $8
801075d8:	6a 08                	push   $0x8
  jmp alltraps
801075da:	e9 69 f9 ff ff       	jmp    80106f48 <alltraps>

801075df <vector9>:
.globl vector9
vector9:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $9
801075e1:	6a 09                	push   $0x9
  jmp alltraps
801075e3:	e9 60 f9 ff ff       	jmp    80106f48 <alltraps>

801075e8 <vector10>:
.globl vector10
vector10:
  pushl $10
801075e8:	6a 0a                	push   $0xa
  jmp alltraps
801075ea:	e9 59 f9 ff ff       	jmp    80106f48 <alltraps>

801075ef <vector11>:
.globl vector11
vector11:
  pushl $11
801075ef:	6a 0b                	push   $0xb
  jmp alltraps
801075f1:	e9 52 f9 ff ff       	jmp    80106f48 <alltraps>

801075f6 <vector12>:
.globl vector12
vector12:
  pushl $12
801075f6:	6a 0c                	push   $0xc
  jmp alltraps
801075f8:	e9 4b f9 ff ff       	jmp    80106f48 <alltraps>

801075fd <vector13>:
.globl vector13
vector13:
  pushl $13
801075fd:	6a 0d                	push   $0xd
  jmp alltraps
801075ff:	e9 44 f9 ff ff       	jmp    80106f48 <alltraps>

80107604 <vector14>:
.globl vector14
vector14:
  pushl $14
80107604:	6a 0e                	push   $0xe
  jmp alltraps
80107606:	e9 3d f9 ff ff       	jmp    80106f48 <alltraps>

8010760b <vector15>:
.globl vector15
vector15:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $15
8010760d:	6a 0f                	push   $0xf
  jmp alltraps
8010760f:	e9 34 f9 ff ff       	jmp    80106f48 <alltraps>

80107614 <vector16>:
.globl vector16
vector16:
  pushl $0
80107614:	6a 00                	push   $0x0
  pushl $16
80107616:	6a 10                	push   $0x10
  jmp alltraps
80107618:	e9 2b f9 ff ff       	jmp    80106f48 <alltraps>

8010761d <vector17>:
.globl vector17
vector17:
  pushl $17
8010761d:	6a 11                	push   $0x11
  jmp alltraps
8010761f:	e9 24 f9 ff ff       	jmp    80106f48 <alltraps>

80107624 <vector18>:
.globl vector18
vector18:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $18
80107626:	6a 12                	push   $0x12
  jmp alltraps
80107628:	e9 1b f9 ff ff       	jmp    80106f48 <alltraps>

8010762d <vector19>:
.globl vector19
vector19:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $19
8010762f:	6a 13                	push   $0x13
  jmp alltraps
80107631:	e9 12 f9 ff ff       	jmp    80106f48 <alltraps>

80107636 <vector20>:
.globl vector20
vector20:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $20
80107638:	6a 14                	push   $0x14
  jmp alltraps
8010763a:	e9 09 f9 ff ff       	jmp    80106f48 <alltraps>

8010763f <vector21>:
.globl vector21
vector21:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $21
80107641:	6a 15                	push   $0x15
  jmp alltraps
80107643:	e9 00 f9 ff ff       	jmp    80106f48 <alltraps>

80107648 <vector22>:
.globl vector22
vector22:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $22
8010764a:	6a 16                	push   $0x16
  jmp alltraps
8010764c:	e9 f7 f8 ff ff       	jmp    80106f48 <alltraps>

80107651 <vector23>:
.globl vector23
vector23:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $23
80107653:	6a 17                	push   $0x17
  jmp alltraps
80107655:	e9 ee f8 ff ff       	jmp    80106f48 <alltraps>

8010765a <vector24>:
.globl vector24
vector24:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $24
8010765c:	6a 18                	push   $0x18
  jmp alltraps
8010765e:	e9 e5 f8 ff ff       	jmp    80106f48 <alltraps>

80107663 <vector25>:
.globl vector25
vector25:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $25
80107665:	6a 19                	push   $0x19
  jmp alltraps
80107667:	e9 dc f8 ff ff       	jmp    80106f48 <alltraps>

8010766c <vector26>:
.globl vector26
vector26:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $26
8010766e:	6a 1a                	push   $0x1a
  jmp alltraps
80107670:	e9 d3 f8 ff ff       	jmp    80106f48 <alltraps>

80107675 <vector27>:
.globl vector27
vector27:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $27
80107677:	6a 1b                	push   $0x1b
  jmp alltraps
80107679:	e9 ca f8 ff ff       	jmp    80106f48 <alltraps>

8010767e <vector28>:
.globl vector28
vector28:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $28
80107680:	6a 1c                	push   $0x1c
  jmp alltraps
80107682:	e9 c1 f8 ff ff       	jmp    80106f48 <alltraps>

80107687 <vector29>:
.globl vector29
vector29:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $29
80107689:	6a 1d                	push   $0x1d
  jmp alltraps
8010768b:	e9 b8 f8 ff ff       	jmp    80106f48 <alltraps>

80107690 <vector30>:
.globl vector30
vector30:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $30
80107692:	6a 1e                	push   $0x1e
  jmp alltraps
80107694:	e9 af f8 ff ff       	jmp    80106f48 <alltraps>

80107699 <vector31>:
.globl vector31
vector31:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $31
8010769b:	6a 1f                	push   $0x1f
  jmp alltraps
8010769d:	e9 a6 f8 ff ff       	jmp    80106f48 <alltraps>

801076a2 <vector32>:
.globl vector32
vector32:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $32
801076a4:	6a 20                	push   $0x20
  jmp alltraps
801076a6:	e9 9d f8 ff ff       	jmp    80106f48 <alltraps>

801076ab <vector33>:
.globl vector33
vector33:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $33
801076ad:	6a 21                	push   $0x21
  jmp alltraps
801076af:	e9 94 f8 ff ff       	jmp    80106f48 <alltraps>

801076b4 <vector34>:
.globl vector34
vector34:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $34
801076b6:	6a 22                	push   $0x22
  jmp alltraps
801076b8:	e9 8b f8 ff ff       	jmp    80106f48 <alltraps>

801076bd <vector35>:
.globl vector35
vector35:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $35
801076bf:	6a 23                	push   $0x23
  jmp alltraps
801076c1:	e9 82 f8 ff ff       	jmp    80106f48 <alltraps>

801076c6 <vector36>:
.globl vector36
vector36:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $36
801076c8:	6a 24                	push   $0x24
  jmp alltraps
801076ca:	e9 79 f8 ff ff       	jmp    80106f48 <alltraps>

801076cf <vector37>:
.globl vector37
vector37:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $37
801076d1:	6a 25                	push   $0x25
  jmp alltraps
801076d3:	e9 70 f8 ff ff       	jmp    80106f48 <alltraps>

801076d8 <vector38>:
.globl vector38
vector38:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $38
801076da:	6a 26                	push   $0x26
  jmp alltraps
801076dc:	e9 67 f8 ff ff       	jmp    80106f48 <alltraps>

801076e1 <vector39>:
.globl vector39
vector39:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $39
801076e3:	6a 27                	push   $0x27
  jmp alltraps
801076e5:	e9 5e f8 ff ff       	jmp    80106f48 <alltraps>

801076ea <vector40>:
.globl vector40
vector40:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $40
801076ec:	6a 28                	push   $0x28
  jmp alltraps
801076ee:	e9 55 f8 ff ff       	jmp    80106f48 <alltraps>

801076f3 <vector41>:
.globl vector41
vector41:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $41
801076f5:	6a 29                	push   $0x29
  jmp alltraps
801076f7:	e9 4c f8 ff ff       	jmp    80106f48 <alltraps>

801076fc <vector42>:
.globl vector42
vector42:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $42
801076fe:	6a 2a                	push   $0x2a
  jmp alltraps
80107700:	e9 43 f8 ff ff       	jmp    80106f48 <alltraps>

80107705 <vector43>:
.globl vector43
vector43:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $43
80107707:	6a 2b                	push   $0x2b
  jmp alltraps
80107709:	e9 3a f8 ff ff       	jmp    80106f48 <alltraps>

8010770e <vector44>:
.globl vector44
vector44:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $44
80107710:	6a 2c                	push   $0x2c
  jmp alltraps
80107712:	e9 31 f8 ff ff       	jmp    80106f48 <alltraps>

80107717 <vector45>:
.globl vector45
vector45:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $45
80107719:	6a 2d                	push   $0x2d
  jmp alltraps
8010771b:	e9 28 f8 ff ff       	jmp    80106f48 <alltraps>

80107720 <vector46>:
.globl vector46
vector46:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $46
80107722:	6a 2e                	push   $0x2e
  jmp alltraps
80107724:	e9 1f f8 ff ff       	jmp    80106f48 <alltraps>

80107729 <vector47>:
.globl vector47
vector47:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $47
8010772b:	6a 2f                	push   $0x2f
  jmp alltraps
8010772d:	e9 16 f8 ff ff       	jmp    80106f48 <alltraps>

80107732 <vector48>:
.globl vector48
vector48:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $48
80107734:	6a 30                	push   $0x30
  jmp alltraps
80107736:	e9 0d f8 ff ff       	jmp    80106f48 <alltraps>

8010773b <vector49>:
.globl vector49
vector49:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $49
8010773d:	6a 31                	push   $0x31
  jmp alltraps
8010773f:	e9 04 f8 ff ff       	jmp    80106f48 <alltraps>

80107744 <vector50>:
.globl vector50
vector50:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $50
80107746:	6a 32                	push   $0x32
  jmp alltraps
80107748:	e9 fb f7 ff ff       	jmp    80106f48 <alltraps>

8010774d <vector51>:
.globl vector51
vector51:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $51
8010774f:	6a 33                	push   $0x33
  jmp alltraps
80107751:	e9 f2 f7 ff ff       	jmp    80106f48 <alltraps>

80107756 <vector52>:
.globl vector52
vector52:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $52
80107758:	6a 34                	push   $0x34
  jmp alltraps
8010775a:	e9 e9 f7 ff ff       	jmp    80106f48 <alltraps>

8010775f <vector53>:
.globl vector53
vector53:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $53
80107761:	6a 35                	push   $0x35
  jmp alltraps
80107763:	e9 e0 f7 ff ff       	jmp    80106f48 <alltraps>

80107768 <vector54>:
.globl vector54
vector54:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $54
8010776a:	6a 36                	push   $0x36
  jmp alltraps
8010776c:	e9 d7 f7 ff ff       	jmp    80106f48 <alltraps>

80107771 <vector55>:
.globl vector55
vector55:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $55
80107773:	6a 37                	push   $0x37
  jmp alltraps
80107775:	e9 ce f7 ff ff       	jmp    80106f48 <alltraps>

8010777a <vector56>:
.globl vector56
vector56:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $56
8010777c:	6a 38                	push   $0x38
  jmp alltraps
8010777e:	e9 c5 f7 ff ff       	jmp    80106f48 <alltraps>

80107783 <vector57>:
.globl vector57
vector57:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $57
80107785:	6a 39                	push   $0x39
  jmp alltraps
80107787:	e9 bc f7 ff ff       	jmp    80106f48 <alltraps>

8010778c <vector58>:
.globl vector58
vector58:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $58
8010778e:	6a 3a                	push   $0x3a
  jmp alltraps
80107790:	e9 b3 f7 ff ff       	jmp    80106f48 <alltraps>

80107795 <vector59>:
.globl vector59
vector59:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $59
80107797:	6a 3b                	push   $0x3b
  jmp alltraps
80107799:	e9 aa f7 ff ff       	jmp    80106f48 <alltraps>

8010779e <vector60>:
.globl vector60
vector60:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $60
801077a0:	6a 3c                	push   $0x3c
  jmp alltraps
801077a2:	e9 a1 f7 ff ff       	jmp    80106f48 <alltraps>

801077a7 <vector61>:
.globl vector61
vector61:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $61
801077a9:	6a 3d                	push   $0x3d
  jmp alltraps
801077ab:	e9 98 f7 ff ff       	jmp    80106f48 <alltraps>

801077b0 <vector62>:
.globl vector62
vector62:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $62
801077b2:	6a 3e                	push   $0x3e
  jmp alltraps
801077b4:	e9 8f f7 ff ff       	jmp    80106f48 <alltraps>

801077b9 <vector63>:
.globl vector63
vector63:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $63
801077bb:	6a 3f                	push   $0x3f
  jmp alltraps
801077bd:	e9 86 f7 ff ff       	jmp    80106f48 <alltraps>

801077c2 <vector64>:
.globl vector64
vector64:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $64
801077c4:	6a 40                	push   $0x40
  jmp alltraps
801077c6:	e9 7d f7 ff ff       	jmp    80106f48 <alltraps>

801077cb <vector65>:
.globl vector65
vector65:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $65
801077cd:	6a 41                	push   $0x41
  jmp alltraps
801077cf:	e9 74 f7 ff ff       	jmp    80106f48 <alltraps>

801077d4 <vector66>:
.globl vector66
vector66:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $66
801077d6:	6a 42                	push   $0x42
  jmp alltraps
801077d8:	e9 6b f7 ff ff       	jmp    80106f48 <alltraps>

801077dd <vector67>:
.globl vector67
vector67:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $67
801077df:	6a 43                	push   $0x43
  jmp alltraps
801077e1:	e9 62 f7 ff ff       	jmp    80106f48 <alltraps>

801077e6 <vector68>:
.globl vector68
vector68:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $68
801077e8:	6a 44                	push   $0x44
  jmp alltraps
801077ea:	e9 59 f7 ff ff       	jmp    80106f48 <alltraps>

801077ef <vector69>:
.globl vector69
vector69:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $69
801077f1:	6a 45                	push   $0x45
  jmp alltraps
801077f3:	e9 50 f7 ff ff       	jmp    80106f48 <alltraps>

801077f8 <vector70>:
.globl vector70
vector70:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $70
801077fa:	6a 46                	push   $0x46
  jmp alltraps
801077fc:	e9 47 f7 ff ff       	jmp    80106f48 <alltraps>

80107801 <vector71>:
.globl vector71
vector71:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $71
80107803:	6a 47                	push   $0x47
  jmp alltraps
80107805:	e9 3e f7 ff ff       	jmp    80106f48 <alltraps>

8010780a <vector72>:
.globl vector72
vector72:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $72
8010780c:	6a 48                	push   $0x48
  jmp alltraps
8010780e:	e9 35 f7 ff ff       	jmp    80106f48 <alltraps>

80107813 <vector73>:
.globl vector73
vector73:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $73
80107815:	6a 49                	push   $0x49
  jmp alltraps
80107817:	e9 2c f7 ff ff       	jmp    80106f48 <alltraps>

8010781c <vector74>:
.globl vector74
vector74:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $74
8010781e:	6a 4a                	push   $0x4a
  jmp alltraps
80107820:	e9 23 f7 ff ff       	jmp    80106f48 <alltraps>

80107825 <vector75>:
.globl vector75
vector75:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $75
80107827:	6a 4b                	push   $0x4b
  jmp alltraps
80107829:	e9 1a f7 ff ff       	jmp    80106f48 <alltraps>

8010782e <vector76>:
.globl vector76
vector76:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $76
80107830:	6a 4c                	push   $0x4c
  jmp alltraps
80107832:	e9 11 f7 ff ff       	jmp    80106f48 <alltraps>

80107837 <vector77>:
.globl vector77
vector77:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $77
80107839:	6a 4d                	push   $0x4d
  jmp alltraps
8010783b:	e9 08 f7 ff ff       	jmp    80106f48 <alltraps>

80107840 <vector78>:
.globl vector78
vector78:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $78
80107842:	6a 4e                	push   $0x4e
  jmp alltraps
80107844:	e9 ff f6 ff ff       	jmp    80106f48 <alltraps>

80107849 <vector79>:
.globl vector79
vector79:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $79
8010784b:	6a 4f                	push   $0x4f
  jmp alltraps
8010784d:	e9 f6 f6 ff ff       	jmp    80106f48 <alltraps>

80107852 <vector80>:
.globl vector80
vector80:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $80
80107854:	6a 50                	push   $0x50
  jmp alltraps
80107856:	e9 ed f6 ff ff       	jmp    80106f48 <alltraps>

8010785b <vector81>:
.globl vector81
vector81:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $81
8010785d:	6a 51                	push   $0x51
  jmp alltraps
8010785f:	e9 e4 f6 ff ff       	jmp    80106f48 <alltraps>

80107864 <vector82>:
.globl vector82
vector82:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $82
80107866:	6a 52                	push   $0x52
  jmp alltraps
80107868:	e9 db f6 ff ff       	jmp    80106f48 <alltraps>

8010786d <vector83>:
.globl vector83
vector83:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $83
8010786f:	6a 53                	push   $0x53
  jmp alltraps
80107871:	e9 d2 f6 ff ff       	jmp    80106f48 <alltraps>

80107876 <vector84>:
.globl vector84
vector84:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $84
80107878:	6a 54                	push   $0x54
  jmp alltraps
8010787a:	e9 c9 f6 ff ff       	jmp    80106f48 <alltraps>

8010787f <vector85>:
.globl vector85
vector85:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $85
80107881:	6a 55                	push   $0x55
  jmp alltraps
80107883:	e9 c0 f6 ff ff       	jmp    80106f48 <alltraps>

80107888 <vector86>:
.globl vector86
vector86:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $86
8010788a:	6a 56                	push   $0x56
  jmp alltraps
8010788c:	e9 b7 f6 ff ff       	jmp    80106f48 <alltraps>

80107891 <vector87>:
.globl vector87
vector87:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $87
80107893:	6a 57                	push   $0x57
  jmp alltraps
80107895:	e9 ae f6 ff ff       	jmp    80106f48 <alltraps>

8010789a <vector88>:
.globl vector88
vector88:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $88
8010789c:	6a 58                	push   $0x58
  jmp alltraps
8010789e:	e9 a5 f6 ff ff       	jmp    80106f48 <alltraps>

801078a3 <vector89>:
.globl vector89
vector89:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $89
801078a5:	6a 59                	push   $0x59
  jmp alltraps
801078a7:	e9 9c f6 ff ff       	jmp    80106f48 <alltraps>

801078ac <vector90>:
.globl vector90
vector90:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $90
801078ae:	6a 5a                	push   $0x5a
  jmp alltraps
801078b0:	e9 93 f6 ff ff       	jmp    80106f48 <alltraps>

801078b5 <vector91>:
.globl vector91
vector91:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $91
801078b7:	6a 5b                	push   $0x5b
  jmp alltraps
801078b9:	e9 8a f6 ff ff       	jmp    80106f48 <alltraps>

801078be <vector92>:
.globl vector92
vector92:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $92
801078c0:	6a 5c                	push   $0x5c
  jmp alltraps
801078c2:	e9 81 f6 ff ff       	jmp    80106f48 <alltraps>

801078c7 <vector93>:
.globl vector93
vector93:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $93
801078c9:	6a 5d                	push   $0x5d
  jmp alltraps
801078cb:	e9 78 f6 ff ff       	jmp    80106f48 <alltraps>

801078d0 <vector94>:
.globl vector94
vector94:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $94
801078d2:	6a 5e                	push   $0x5e
  jmp alltraps
801078d4:	e9 6f f6 ff ff       	jmp    80106f48 <alltraps>

801078d9 <vector95>:
.globl vector95
vector95:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $95
801078db:	6a 5f                	push   $0x5f
  jmp alltraps
801078dd:	e9 66 f6 ff ff       	jmp    80106f48 <alltraps>

801078e2 <vector96>:
.globl vector96
vector96:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $96
801078e4:	6a 60                	push   $0x60
  jmp alltraps
801078e6:	e9 5d f6 ff ff       	jmp    80106f48 <alltraps>

801078eb <vector97>:
.globl vector97
vector97:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $97
801078ed:	6a 61                	push   $0x61
  jmp alltraps
801078ef:	e9 54 f6 ff ff       	jmp    80106f48 <alltraps>

801078f4 <vector98>:
.globl vector98
vector98:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $98
801078f6:	6a 62                	push   $0x62
  jmp alltraps
801078f8:	e9 4b f6 ff ff       	jmp    80106f48 <alltraps>

801078fd <vector99>:
.globl vector99
vector99:
  pushl $0
801078fd:	6a 00                	push   $0x0
  pushl $99
801078ff:	6a 63                	push   $0x63
  jmp alltraps
80107901:	e9 42 f6 ff ff       	jmp    80106f48 <alltraps>

80107906 <vector100>:
.globl vector100
vector100:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $100
80107908:	6a 64                	push   $0x64
  jmp alltraps
8010790a:	e9 39 f6 ff ff       	jmp    80106f48 <alltraps>

8010790f <vector101>:
.globl vector101
vector101:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $101
80107911:	6a 65                	push   $0x65
  jmp alltraps
80107913:	e9 30 f6 ff ff       	jmp    80106f48 <alltraps>

80107918 <vector102>:
.globl vector102
vector102:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $102
8010791a:	6a 66                	push   $0x66
  jmp alltraps
8010791c:	e9 27 f6 ff ff       	jmp    80106f48 <alltraps>

80107921 <vector103>:
.globl vector103
vector103:
  pushl $0
80107921:	6a 00                	push   $0x0
  pushl $103
80107923:	6a 67                	push   $0x67
  jmp alltraps
80107925:	e9 1e f6 ff ff       	jmp    80106f48 <alltraps>

8010792a <vector104>:
.globl vector104
vector104:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $104
8010792c:	6a 68                	push   $0x68
  jmp alltraps
8010792e:	e9 15 f6 ff ff       	jmp    80106f48 <alltraps>

80107933 <vector105>:
.globl vector105
vector105:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $105
80107935:	6a 69                	push   $0x69
  jmp alltraps
80107937:	e9 0c f6 ff ff       	jmp    80106f48 <alltraps>

8010793c <vector106>:
.globl vector106
vector106:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $106
8010793e:	6a 6a                	push   $0x6a
  jmp alltraps
80107940:	e9 03 f6 ff ff       	jmp    80106f48 <alltraps>

80107945 <vector107>:
.globl vector107
vector107:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $107
80107947:	6a 6b                	push   $0x6b
  jmp alltraps
80107949:	e9 fa f5 ff ff       	jmp    80106f48 <alltraps>

8010794e <vector108>:
.globl vector108
vector108:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $108
80107950:	6a 6c                	push   $0x6c
  jmp alltraps
80107952:	e9 f1 f5 ff ff       	jmp    80106f48 <alltraps>

80107957 <vector109>:
.globl vector109
vector109:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $109
80107959:	6a 6d                	push   $0x6d
  jmp alltraps
8010795b:	e9 e8 f5 ff ff       	jmp    80106f48 <alltraps>

80107960 <vector110>:
.globl vector110
vector110:
  pushl $0
80107960:	6a 00                	push   $0x0
  pushl $110
80107962:	6a 6e                	push   $0x6e
  jmp alltraps
80107964:	e9 df f5 ff ff       	jmp    80106f48 <alltraps>

80107969 <vector111>:
.globl vector111
vector111:
  pushl $0
80107969:	6a 00                	push   $0x0
  pushl $111
8010796b:	6a 6f                	push   $0x6f
  jmp alltraps
8010796d:	e9 d6 f5 ff ff       	jmp    80106f48 <alltraps>

80107972 <vector112>:
.globl vector112
vector112:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $112
80107974:	6a 70                	push   $0x70
  jmp alltraps
80107976:	e9 cd f5 ff ff       	jmp    80106f48 <alltraps>

8010797b <vector113>:
.globl vector113
vector113:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $113
8010797d:	6a 71                	push   $0x71
  jmp alltraps
8010797f:	e9 c4 f5 ff ff       	jmp    80106f48 <alltraps>

80107984 <vector114>:
.globl vector114
vector114:
  pushl $0
80107984:	6a 00                	push   $0x0
  pushl $114
80107986:	6a 72                	push   $0x72
  jmp alltraps
80107988:	e9 bb f5 ff ff       	jmp    80106f48 <alltraps>

8010798d <vector115>:
.globl vector115
vector115:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $115
8010798f:	6a 73                	push   $0x73
  jmp alltraps
80107991:	e9 b2 f5 ff ff       	jmp    80106f48 <alltraps>

80107996 <vector116>:
.globl vector116
vector116:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $116
80107998:	6a 74                	push   $0x74
  jmp alltraps
8010799a:	e9 a9 f5 ff ff       	jmp    80106f48 <alltraps>

8010799f <vector117>:
.globl vector117
vector117:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $117
801079a1:	6a 75                	push   $0x75
  jmp alltraps
801079a3:	e9 a0 f5 ff ff       	jmp    80106f48 <alltraps>

801079a8 <vector118>:
.globl vector118
vector118:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $118
801079aa:	6a 76                	push   $0x76
  jmp alltraps
801079ac:	e9 97 f5 ff ff       	jmp    80106f48 <alltraps>

801079b1 <vector119>:
.globl vector119
vector119:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $119
801079b3:	6a 77                	push   $0x77
  jmp alltraps
801079b5:	e9 8e f5 ff ff       	jmp    80106f48 <alltraps>

801079ba <vector120>:
.globl vector120
vector120:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $120
801079bc:	6a 78                	push   $0x78
  jmp alltraps
801079be:	e9 85 f5 ff ff       	jmp    80106f48 <alltraps>

801079c3 <vector121>:
.globl vector121
vector121:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $121
801079c5:	6a 79                	push   $0x79
  jmp alltraps
801079c7:	e9 7c f5 ff ff       	jmp    80106f48 <alltraps>

801079cc <vector122>:
.globl vector122
vector122:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $122
801079ce:	6a 7a                	push   $0x7a
  jmp alltraps
801079d0:	e9 73 f5 ff ff       	jmp    80106f48 <alltraps>

801079d5 <vector123>:
.globl vector123
vector123:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $123
801079d7:	6a 7b                	push   $0x7b
  jmp alltraps
801079d9:	e9 6a f5 ff ff       	jmp    80106f48 <alltraps>

801079de <vector124>:
.globl vector124
vector124:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $124
801079e0:	6a 7c                	push   $0x7c
  jmp alltraps
801079e2:	e9 61 f5 ff ff       	jmp    80106f48 <alltraps>

801079e7 <vector125>:
.globl vector125
vector125:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $125
801079e9:	6a 7d                	push   $0x7d
  jmp alltraps
801079eb:	e9 58 f5 ff ff       	jmp    80106f48 <alltraps>

801079f0 <vector126>:
.globl vector126
vector126:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $126
801079f2:	6a 7e                	push   $0x7e
  jmp alltraps
801079f4:	e9 4f f5 ff ff       	jmp    80106f48 <alltraps>

801079f9 <vector127>:
.globl vector127
vector127:
  pushl $0
801079f9:	6a 00                	push   $0x0
  pushl $127
801079fb:	6a 7f                	push   $0x7f
  jmp alltraps
801079fd:	e9 46 f5 ff ff       	jmp    80106f48 <alltraps>

80107a02 <vector128>:
.globl vector128
vector128:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $128
80107a04:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107a09:	e9 3a f5 ff ff       	jmp    80106f48 <alltraps>

80107a0e <vector129>:
.globl vector129
vector129:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $129
80107a10:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107a15:	e9 2e f5 ff ff       	jmp    80106f48 <alltraps>

80107a1a <vector130>:
.globl vector130
vector130:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $130
80107a1c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107a21:	e9 22 f5 ff ff       	jmp    80106f48 <alltraps>

80107a26 <vector131>:
.globl vector131
vector131:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $131
80107a28:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107a2d:	e9 16 f5 ff ff       	jmp    80106f48 <alltraps>

80107a32 <vector132>:
.globl vector132
vector132:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $132
80107a34:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107a39:	e9 0a f5 ff ff       	jmp    80106f48 <alltraps>

80107a3e <vector133>:
.globl vector133
vector133:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $133
80107a40:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107a45:	e9 fe f4 ff ff       	jmp    80106f48 <alltraps>

80107a4a <vector134>:
.globl vector134
vector134:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $134
80107a4c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107a51:	e9 f2 f4 ff ff       	jmp    80106f48 <alltraps>

80107a56 <vector135>:
.globl vector135
vector135:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $135
80107a58:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107a5d:	e9 e6 f4 ff ff       	jmp    80106f48 <alltraps>

80107a62 <vector136>:
.globl vector136
vector136:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $136
80107a64:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107a69:	e9 da f4 ff ff       	jmp    80106f48 <alltraps>

80107a6e <vector137>:
.globl vector137
vector137:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $137
80107a70:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107a75:	e9 ce f4 ff ff       	jmp    80106f48 <alltraps>

80107a7a <vector138>:
.globl vector138
vector138:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $138
80107a7c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107a81:	e9 c2 f4 ff ff       	jmp    80106f48 <alltraps>

80107a86 <vector139>:
.globl vector139
vector139:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $139
80107a88:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107a8d:	e9 b6 f4 ff ff       	jmp    80106f48 <alltraps>

80107a92 <vector140>:
.globl vector140
vector140:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $140
80107a94:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107a99:	e9 aa f4 ff ff       	jmp    80106f48 <alltraps>

80107a9e <vector141>:
.globl vector141
vector141:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $141
80107aa0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107aa5:	e9 9e f4 ff ff       	jmp    80106f48 <alltraps>

80107aaa <vector142>:
.globl vector142
vector142:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $142
80107aac:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ab1:	e9 92 f4 ff ff       	jmp    80106f48 <alltraps>

80107ab6 <vector143>:
.globl vector143
vector143:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $143
80107ab8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107abd:	e9 86 f4 ff ff       	jmp    80106f48 <alltraps>

80107ac2 <vector144>:
.globl vector144
vector144:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $144
80107ac4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107ac9:	e9 7a f4 ff ff       	jmp    80106f48 <alltraps>

80107ace <vector145>:
.globl vector145
vector145:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $145
80107ad0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107ad5:	e9 6e f4 ff ff       	jmp    80106f48 <alltraps>

80107ada <vector146>:
.globl vector146
vector146:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $146
80107adc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ae1:	e9 62 f4 ff ff       	jmp    80106f48 <alltraps>

80107ae6 <vector147>:
.globl vector147
vector147:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $147
80107ae8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107aed:	e9 56 f4 ff ff       	jmp    80106f48 <alltraps>

80107af2 <vector148>:
.globl vector148
vector148:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $148
80107af4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107af9:	e9 4a f4 ff ff       	jmp    80106f48 <alltraps>

80107afe <vector149>:
.globl vector149
vector149:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $149
80107b00:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107b05:	e9 3e f4 ff ff       	jmp    80106f48 <alltraps>

80107b0a <vector150>:
.globl vector150
vector150:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $150
80107b0c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107b11:	e9 32 f4 ff ff       	jmp    80106f48 <alltraps>

80107b16 <vector151>:
.globl vector151
vector151:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $151
80107b18:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107b1d:	e9 26 f4 ff ff       	jmp    80106f48 <alltraps>

80107b22 <vector152>:
.globl vector152
vector152:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $152
80107b24:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107b29:	e9 1a f4 ff ff       	jmp    80106f48 <alltraps>

80107b2e <vector153>:
.globl vector153
vector153:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $153
80107b30:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107b35:	e9 0e f4 ff ff       	jmp    80106f48 <alltraps>

80107b3a <vector154>:
.globl vector154
vector154:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $154
80107b3c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107b41:	e9 02 f4 ff ff       	jmp    80106f48 <alltraps>

80107b46 <vector155>:
.globl vector155
vector155:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $155
80107b48:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107b4d:	e9 f6 f3 ff ff       	jmp    80106f48 <alltraps>

80107b52 <vector156>:
.globl vector156
vector156:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $156
80107b54:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107b59:	e9 ea f3 ff ff       	jmp    80106f48 <alltraps>

80107b5e <vector157>:
.globl vector157
vector157:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $157
80107b60:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107b65:	e9 de f3 ff ff       	jmp    80106f48 <alltraps>

80107b6a <vector158>:
.globl vector158
vector158:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $158
80107b6c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107b71:	e9 d2 f3 ff ff       	jmp    80106f48 <alltraps>

80107b76 <vector159>:
.globl vector159
vector159:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $159
80107b78:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107b7d:	e9 c6 f3 ff ff       	jmp    80106f48 <alltraps>

80107b82 <vector160>:
.globl vector160
vector160:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $160
80107b84:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107b89:	e9 ba f3 ff ff       	jmp    80106f48 <alltraps>

80107b8e <vector161>:
.globl vector161
vector161:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $161
80107b90:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107b95:	e9 ae f3 ff ff       	jmp    80106f48 <alltraps>

80107b9a <vector162>:
.globl vector162
vector162:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $162
80107b9c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107ba1:	e9 a2 f3 ff ff       	jmp    80106f48 <alltraps>

80107ba6 <vector163>:
.globl vector163
vector163:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $163
80107ba8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107bad:	e9 96 f3 ff ff       	jmp    80106f48 <alltraps>

80107bb2 <vector164>:
.globl vector164
vector164:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $164
80107bb4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107bb9:	e9 8a f3 ff ff       	jmp    80106f48 <alltraps>

80107bbe <vector165>:
.globl vector165
vector165:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $165
80107bc0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107bc5:	e9 7e f3 ff ff       	jmp    80106f48 <alltraps>

80107bca <vector166>:
.globl vector166
vector166:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $166
80107bcc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107bd1:	e9 72 f3 ff ff       	jmp    80106f48 <alltraps>

80107bd6 <vector167>:
.globl vector167
vector167:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $167
80107bd8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107bdd:	e9 66 f3 ff ff       	jmp    80106f48 <alltraps>

80107be2 <vector168>:
.globl vector168
vector168:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $168
80107be4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107be9:	e9 5a f3 ff ff       	jmp    80106f48 <alltraps>

80107bee <vector169>:
.globl vector169
vector169:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $169
80107bf0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107bf5:	e9 4e f3 ff ff       	jmp    80106f48 <alltraps>

80107bfa <vector170>:
.globl vector170
vector170:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $170
80107bfc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107c01:	e9 42 f3 ff ff       	jmp    80106f48 <alltraps>

80107c06 <vector171>:
.globl vector171
vector171:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $171
80107c08:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107c0d:	e9 36 f3 ff ff       	jmp    80106f48 <alltraps>

80107c12 <vector172>:
.globl vector172
vector172:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $172
80107c14:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107c19:	e9 2a f3 ff ff       	jmp    80106f48 <alltraps>

80107c1e <vector173>:
.globl vector173
vector173:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $173
80107c20:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107c25:	e9 1e f3 ff ff       	jmp    80106f48 <alltraps>

80107c2a <vector174>:
.globl vector174
vector174:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $174
80107c2c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107c31:	e9 12 f3 ff ff       	jmp    80106f48 <alltraps>

80107c36 <vector175>:
.globl vector175
vector175:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $175
80107c38:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107c3d:	e9 06 f3 ff ff       	jmp    80106f48 <alltraps>

80107c42 <vector176>:
.globl vector176
vector176:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $176
80107c44:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107c49:	e9 fa f2 ff ff       	jmp    80106f48 <alltraps>

80107c4e <vector177>:
.globl vector177
vector177:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $177
80107c50:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107c55:	e9 ee f2 ff ff       	jmp    80106f48 <alltraps>

80107c5a <vector178>:
.globl vector178
vector178:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $178
80107c5c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107c61:	e9 e2 f2 ff ff       	jmp    80106f48 <alltraps>

80107c66 <vector179>:
.globl vector179
vector179:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $179
80107c68:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107c6d:	e9 d6 f2 ff ff       	jmp    80106f48 <alltraps>

80107c72 <vector180>:
.globl vector180
vector180:
  pushl $0
80107c72:	6a 00                	push   $0x0
  pushl $180
80107c74:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107c79:	e9 ca f2 ff ff       	jmp    80106f48 <alltraps>

80107c7e <vector181>:
.globl vector181
vector181:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $181
80107c80:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107c85:	e9 be f2 ff ff       	jmp    80106f48 <alltraps>

80107c8a <vector182>:
.globl vector182
vector182:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $182
80107c8c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107c91:	e9 b2 f2 ff ff       	jmp    80106f48 <alltraps>

80107c96 <vector183>:
.globl vector183
vector183:
  pushl $0
80107c96:	6a 00                	push   $0x0
  pushl $183
80107c98:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107c9d:	e9 a6 f2 ff ff       	jmp    80106f48 <alltraps>

80107ca2 <vector184>:
.globl vector184
vector184:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $184
80107ca4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107ca9:	e9 9a f2 ff ff       	jmp    80106f48 <alltraps>

80107cae <vector185>:
.globl vector185
vector185:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $185
80107cb0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107cb5:	e9 8e f2 ff ff       	jmp    80106f48 <alltraps>

80107cba <vector186>:
.globl vector186
vector186:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $186
80107cbc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107cc1:	e9 82 f2 ff ff       	jmp    80106f48 <alltraps>

80107cc6 <vector187>:
.globl vector187
vector187:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $187
80107cc8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107ccd:	e9 76 f2 ff ff       	jmp    80106f48 <alltraps>

80107cd2 <vector188>:
.globl vector188
vector188:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $188
80107cd4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107cd9:	e9 6a f2 ff ff       	jmp    80106f48 <alltraps>

80107cde <vector189>:
.globl vector189
vector189:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $189
80107ce0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107ce5:	e9 5e f2 ff ff       	jmp    80106f48 <alltraps>

80107cea <vector190>:
.globl vector190
vector190:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $190
80107cec:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107cf1:	e9 52 f2 ff ff       	jmp    80106f48 <alltraps>

80107cf6 <vector191>:
.globl vector191
vector191:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $191
80107cf8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107cfd:	e9 46 f2 ff ff       	jmp    80106f48 <alltraps>

80107d02 <vector192>:
.globl vector192
vector192:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $192
80107d04:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107d09:	e9 3a f2 ff ff       	jmp    80106f48 <alltraps>

80107d0e <vector193>:
.globl vector193
vector193:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $193
80107d10:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107d15:	e9 2e f2 ff ff       	jmp    80106f48 <alltraps>

80107d1a <vector194>:
.globl vector194
vector194:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $194
80107d1c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107d21:	e9 22 f2 ff ff       	jmp    80106f48 <alltraps>

80107d26 <vector195>:
.globl vector195
vector195:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $195
80107d28:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107d2d:	e9 16 f2 ff ff       	jmp    80106f48 <alltraps>

80107d32 <vector196>:
.globl vector196
vector196:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $196
80107d34:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107d39:	e9 0a f2 ff ff       	jmp    80106f48 <alltraps>

80107d3e <vector197>:
.globl vector197
vector197:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $197
80107d40:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107d45:	e9 fe f1 ff ff       	jmp    80106f48 <alltraps>

80107d4a <vector198>:
.globl vector198
vector198:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $198
80107d4c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107d51:	e9 f2 f1 ff ff       	jmp    80106f48 <alltraps>

80107d56 <vector199>:
.globl vector199
vector199:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $199
80107d58:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107d5d:	e9 e6 f1 ff ff       	jmp    80106f48 <alltraps>

80107d62 <vector200>:
.globl vector200
vector200:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $200
80107d64:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107d69:	e9 da f1 ff ff       	jmp    80106f48 <alltraps>

80107d6e <vector201>:
.globl vector201
vector201:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $201
80107d70:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107d75:	e9 ce f1 ff ff       	jmp    80106f48 <alltraps>

80107d7a <vector202>:
.globl vector202
vector202:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $202
80107d7c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107d81:	e9 c2 f1 ff ff       	jmp    80106f48 <alltraps>

80107d86 <vector203>:
.globl vector203
vector203:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $203
80107d88:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107d8d:	e9 b6 f1 ff ff       	jmp    80106f48 <alltraps>

80107d92 <vector204>:
.globl vector204
vector204:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $204
80107d94:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107d99:	e9 aa f1 ff ff       	jmp    80106f48 <alltraps>

80107d9e <vector205>:
.globl vector205
vector205:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $205
80107da0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107da5:	e9 9e f1 ff ff       	jmp    80106f48 <alltraps>

80107daa <vector206>:
.globl vector206
vector206:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $206
80107dac:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107db1:	e9 92 f1 ff ff       	jmp    80106f48 <alltraps>

80107db6 <vector207>:
.globl vector207
vector207:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $207
80107db8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107dbd:	e9 86 f1 ff ff       	jmp    80106f48 <alltraps>

80107dc2 <vector208>:
.globl vector208
vector208:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $208
80107dc4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107dc9:	e9 7a f1 ff ff       	jmp    80106f48 <alltraps>

80107dce <vector209>:
.globl vector209
vector209:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $209
80107dd0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107dd5:	e9 6e f1 ff ff       	jmp    80106f48 <alltraps>

80107dda <vector210>:
.globl vector210
vector210:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $210
80107ddc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107de1:	e9 62 f1 ff ff       	jmp    80106f48 <alltraps>

80107de6 <vector211>:
.globl vector211
vector211:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $211
80107de8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107ded:	e9 56 f1 ff ff       	jmp    80106f48 <alltraps>

80107df2 <vector212>:
.globl vector212
vector212:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $212
80107df4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107df9:	e9 4a f1 ff ff       	jmp    80106f48 <alltraps>

80107dfe <vector213>:
.globl vector213
vector213:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $213
80107e00:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107e05:	e9 3e f1 ff ff       	jmp    80106f48 <alltraps>

80107e0a <vector214>:
.globl vector214
vector214:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $214
80107e0c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107e11:	e9 32 f1 ff ff       	jmp    80106f48 <alltraps>

80107e16 <vector215>:
.globl vector215
vector215:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $215
80107e18:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107e1d:	e9 26 f1 ff ff       	jmp    80106f48 <alltraps>

80107e22 <vector216>:
.globl vector216
vector216:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $216
80107e24:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107e29:	e9 1a f1 ff ff       	jmp    80106f48 <alltraps>

80107e2e <vector217>:
.globl vector217
vector217:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $217
80107e30:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107e35:	e9 0e f1 ff ff       	jmp    80106f48 <alltraps>

80107e3a <vector218>:
.globl vector218
vector218:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $218
80107e3c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107e41:	e9 02 f1 ff ff       	jmp    80106f48 <alltraps>

80107e46 <vector219>:
.globl vector219
vector219:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $219
80107e48:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107e4d:	e9 f6 f0 ff ff       	jmp    80106f48 <alltraps>

80107e52 <vector220>:
.globl vector220
vector220:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $220
80107e54:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107e59:	e9 ea f0 ff ff       	jmp    80106f48 <alltraps>

80107e5e <vector221>:
.globl vector221
vector221:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $221
80107e60:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107e65:	e9 de f0 ff ff       	jmp    80106f48 <alltraps>

80107e6a <vector222>:
.globl vector222
vector222:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $222
80107e6c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107e71:	e9 d2 f0 ff ff       	jmp    80106f48 <alltraps>

80107e76 <vector223>:
.globl vector223
vector223:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $223
80107e78:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107e7d:	e9 c6 f0 ff ff       	jmp    80106f48 <alltraps>

80107e82 <vector224>:
.globl vector224
vector224:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $224
80107e84:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107e89:	e9 ba f0 ff ff       	jmp    80106f48 <alltraps>

80107e8e <vector225>:
.globl vector225
vector225:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $225
80107e90:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107e95:	e9 ae f0 ff ff       	jmp    80106f48 <alltraps>

80107e9a <vector226>:
.globl vector226
vector226:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $226
80107e9c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107ea1:	e9 a2 f0 ff ff       	jmp    80106f48 <alltraps>

80107ea6 <vector227>:
.globl vector227
vector227:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $227
80107ea8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107ead:	e9 96 f0 ff ff       	jmp    80106f48 <alltraps>

80107eb2 <vector228>:
.globl vector228
vector228:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $228
80107eb4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107eb9:	e9 8a f0 ff ff       	jmp    80106f48 <alltraps>

80107ebe <vector229>:
.globl vector229
vector229:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $229
80107ec0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107ec5:	e9 7e f0 ff ff       	jmp    80106f48 <alltraps>

80107eca <vector230>:
.globl vector230
vector230:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $230
80107ecc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107ed1:	e9 72 f0 ff ff       	jmp    80106f48 <alltraps>

80107ed6 <vector231>:
.globl vector231
vector231:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $231
80107ed8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107edd:	e9 66 f0 ff ff       	jmp    80106f48 <alltraps>

80107ee2 <vector232>:
.globl vector232
vector232:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $232
80107ee4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ee9:	e9 5a f0 ff ff       	jmp    80106f48 <alltraps>

80107eee <vector233>:
.globl vector233
vector233:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $233
80107ef0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ef5:	e9 4e f0 ff ff       	jmp    80106f48 <alltraps>

80107efa <vector234>:
.globl vector234
vector234:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $234
80107efc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107f01:	e9 42 f0 ff ff       	jmp    80106f48 <alltraps>

80107f06 <vector235>:
.globl vector235
vector235:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $235
80107f08:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107f0d:	e9 36 f0 ff ff       	jmp    80106f48 <alltraps>

80107f12 <vector236>:
.globl vector236
vector236:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $236
80107f14:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107f19:	e9 2a f0 ff ff       	jmp    80106f48 <alltraps>

80107f1e <vector237>:
.globl vector237
vector237:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $237
80107f20:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107f25:	e9 1e f0 ff ff       	jmp    80106f48 <alltraps>

80107f2a <vector238>:
.globl vector238
vector238:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $238
80107f2c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107f31:	e9 12 f0 ff ff       	jmp    80106f48 <alltraps>

80107f36 <vector239>:
.globl vector239
vector239:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $239
80107f38:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107f3d:	e9 06 f0 ff ff       	jmp    80106f48 <alltraps>

80107f42 <vector240>:
.globl vector240
vector240:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $240
80107f44:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107f49:	e9 fa ef ff ff       	jmp    80106f48 <alltraps>

80107f4e <vector241>:
.globl vector241
vector241:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $241
80107f50:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107f55:	e9 ee ef ff ff       	jmp    80106f48 <alltraps>

80107f5a <vector242>:
.globl vector242
vector242:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $242
80107f5c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107f61:	e9 e2 ef ff ff       	jmp    80106f48 <alltraps>

80107f66 <vector243>:
.globl vector243
vector243:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $243
80107f68:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107f6d:	e9 d6 ef ff ff       	jmp    80106f48 <alltraps>

80107f72 <vector244>:
.globl vector244
vector244:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $244
80107f74:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107f79:	e9 ca ef ff ff       	jmp    80106f48 <alltraps>

80107f7e <vector245>:
.globl vector245
vector245:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $245
80107f80:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107f85:	e9 be ef ff ff       	jmp    80106f48 <alltraps>

80107f8a <vector246>:
.globl vector246
vector246:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $246
80107f8c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107f91:	e9 b2 ef ff ff       	jmp    80106f48 <alltraps>

80107f96 <vector247>:
.globl vector247
vector247:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $247
80107f98:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107f9d:	e9 a6 ef ff ff       	jmp    80106f48 <alltraps>

80107fa2 <vector248>:
.globl vector248
vector248:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $248
80107fa4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107fa9:	e9 9a ef ff ff       	jmp    80106f48 <alltraps>

80107fae <vector249>:
.globl vector249
vector249:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $249
80107fb0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107fb5:	e9 8e ef ff ff       	jmp    80106f48 <alltraps>

80107fba <vector250>:
.globl vector250
vector250:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $250
80107fbc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107fc1:	e9 82 ef ff ff       	jmp    80106f48 <alltraps>

80107fc6 <vector251>:
.globl vector251
vector251:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $251
80107fc8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107fcd:	e9 76 ef ff ff       	jmp    80106f48 <alltraps>

80107fd2 <vector252>:
.globl vector252
vector252:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $252
80107fd4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107fd9:	e9 6a ef ff ff       	jmp    80106f48 <alltraps>

80107fde <vector253>:
.globl vector253
vector253:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $253
80107fe0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107fe5:	e9 5e ef ff ff       	jmp    80106f48 <alltraps>

80107fea <vector254>:
.globl vector254
vector254:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $254
80107fec:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107ff1:	e9 52 ef ff ff       	jmp    80106f48 <alltraps>

80107ff6 <vector255>:
.globl vector255
vector255:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $255
80107ff8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107ffd:	e9 46 ef ff ff       	jmp    80106f48 <alltraps>
	...

80108004 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108004:	55                   	push   %ebp
80108005:	89 e5                	mov    %esp,%ebp
80108007:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010800a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010800d:	48                   	dec    %eax
8010800e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108012:	8b 45 08             	mov    0x8(%ebp),%eax
80108015:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108019:	8b 45 08             	mov    0x8(%ebp),%eax
8010801c:	c1 e8 10             	shr    $0x10,%eax
8010801f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108023:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108026:	0f 01 10             	lgdtl  (%eax)
}
80108029:	c9                   	leave  
8010802a:	c3                   	ret    

8010802b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010802b:	55                   	push   %ebp
8010802c:	89 e5                	mov    %esp,%ebp
8010802e:	83 ec 04             	sub    $0x4,%esp
80108031:	8b 45 08             	mov    0x8(%ebp),%eax
80108034:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108038:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010803b:	0f 00 d8             	ltr    %ax
}
8010803e:	c9                   	leave  
8010803f:	c3                   	ret    

80108040 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108040:	55                   	push   %ebp
80108041:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108043:	8b 45 08             	mov    0x8(%ebp),%eax
80108046:	0f 22 d8             	mov    %eax,%cr3
}
80108049:	5d                   	pop    %ebp
8010804a:	c3                   	ret    

8010804b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010804b:	55                   	push   %ebp
8010804c:	89 e5                	mov    %esp,%ebp
8010804e:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108051:	e8 54 c3 ff ff       	call   801043aa <cpuid>
80108056:	89 c2                	mov    %eax,%edx
80108058:	89 d0                	mov    %edx,%eax
8010805a:	c1 e0 02             	shl    $0x2,%eax
8010805d:	01 d0                	add    %edx,%eax
8010805f:	01 c0                	add    %eax,%eax
80108061:	01 d0                	add    %edx,%eax
80108063:	c1 e0 04             	shl    $0x4,%eax
80108066:	05 80 4c 11 80       	add    $0x80114c80,%eax
8010806b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010806e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108071:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808a:	8a 50 7d             	mov    0x7d(%eax),%dl
8010808d:	83 e2 f0             	and    $0xfffffff0,%edx
80108090:	83 ca 0a             	or     $0xa,%edx
80108093:	88 50 7d             	mov    %dl,0x7d(%eax)
80108096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108099:	8a 50 7d             	mov    0x7d(%eax),%dl
8010809c:	83 ca 10             	or     $0x10,%edx
8010809f:	88 50 7d             	mov    %dl,0x7d(%eax)
801080a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a5:	8a 50 7d             	mov    0x7d(%eax),%dl
801080a8:	83 e2 9f             	and    $0xffffff9f,%edx
801080ab:	88 50 7d             	mov    %dl,0x7d(%eax)
801080ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b1:	8a 50 7d             	mov    0x7d(%eax),%dl
801080b4:	83 ca 80             	or     $0xffffff80,%edx
801080b7:	88 50 7d             	mov    %dl,0x7d(%eax)
801080ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bd:	8a 50 7e             	mov    0x7e(%eax),%dl
801080c0:	83 ca 0f             	or     $0xf,%edx
801080c3:	88 50 7e             	mov    %dl,0x7e(%eax)
801080c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c9:	8a 50 7e             	mov    0x7e(%eax),%dl
801080cc:	83 e2 ef             	and    $0xffffffef,%edx
801080cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	8a 50 7e             	mov    0x7e(%eax),%dl
801080d8:	83 e2 df             	and    $0xffffffdf,%edx
801080db:	88 50 7e             	mov    %dl,0x7e(%eax)
801080de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e1:	8a 50 7e             	mov    0x7e(%eax),%dl
801080e4:	83 ca 40             	or     $0x40,%edx
801080e7:	88 50 7e             	mov    %dl,0x7e(%eax)
801080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ed:	8a 50 7e             	mov    0x7e(%eax),%dl
801080f0:	83 ca 80             	or     $0xffffff80,%edx
801080f3:	88 50 7e             	mov    %dl,0x7e(%eax)
801080f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801080fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108100:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108107:	ff ff 
80108109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810c:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108113:	00 00 
80108115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108118:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108128:	83 e2 f0             	and    $0xfffffff0,%edx
8010812b:	83 ca 02             	or     $0x2,%edx
8010812e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108137:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010813d:	83 ca 10             	or     $0x10,%edx
80108140:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010814f:	83 e2 9f             	and    $0xffffff9f,%edx
80108152:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108161:	83 ca 80             	or     $0xffffff80,%edx
80108164:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010816a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108173:	83 ca 0f             	or     $0xf,%edx
80108176:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010817c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108185:	83 e2 ef             	and    $0xffffffef,%edx
80108188:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010818e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108191:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108197:	83 e2 df             	and    $0xffffffdf,%edx
8010819a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a3:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081a9:	83 ca 40             	or     $0x40,%edx
801081ac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b5:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081bb:	83 ca 80             	or     $0xffffff80,%edx
801081be:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801081ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801081d8:	ff ff 
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801081e4:	00 00 
801081e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e9:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801081f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f3:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801081f9:	83 e2 f0             	and    $0xfffffff0,%edx
801081fc:	83 ca 0a             	or     $0xa,%edx
801081ff:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108208:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010820e:	83 ca 10             	or     $0x10,%edx
80108211:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821a:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108220:	83 ca 60             	or     $0x60,%edx
80108223:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822c:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108232:	83 ca 80             	or     $0xffffff80,%edx
80108235:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010823b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108244:	83 ca 0f             	or     $0xf,%edx
80108247:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010824d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108250:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108256:	83 e2 ef             	and    $0xffffffef,%edx
80108259:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010825f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108262:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108268:	83 e2 df             	and    $0xffffffdf,%edx
8010826b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108274:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010827a:	83 ca 40             	or     $0x40,%edx
8010827d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108286:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010828c:	83 ca 80             	or     $0xffffff80,%edx
8010828f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108298:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010829f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a2:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801082a9:	ff ff 
801082ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ae:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801082b5:	00 00 
801082b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ba:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801082c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c4:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801082ca:	83 e2 f0             	and    $0xfffffff0,%edx
801082cd:	83 ca 02             	or     $0x2,%edx
801082d0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801082d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801082df:	83 ca 10             	or     $0x10,%edx
801082e2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801082e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082eb:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801082f1:	83 ca 60             	or     $0x60,%edx
801082f4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801082fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fd:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108303:	83 ca 80             	or     $0xffffff80,%edx
80108306:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010830c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108315:	83 ca 0f             	or     $0xf,%edx
80108318:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010831e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108321:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108327:	83 e2 ef             	and    $0xffffffef,%edx
8010832a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108333:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108339:	83 e2 df             	and    $0xffffffdf,%edx
8010833c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108345:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010834b:	83 ca 40             	or     $0x40,%edx
8010834e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108357:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010835d:	83 ca 80             	or     $0xffffff80,%edx
80108360:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108369:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108373:	83 c0 70             	add    $0x70,%eax
80108376:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010837d:	00 
8010837e:	89 04 24             	mov    %eax,(%esp)
80108381:	e8 7e fc ff ff       	call   80108004 <lgdt>
}
80108386:	c9                   	leave  
80108387:	c3                   	ret    

80108388 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108388:	55                   	push   %ebp
80108389:	89 e5                	mov    %esp,%ebp
8010838b:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010838e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108391:	c1 e8 16             	shr    $0x16,%eax
80108394:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010839b:	8b 45 08             	mov    0x8(%ebp),%eax
8010839e:	01 d0                	add    %edx,%eax
801083a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801083a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083a6:	8b 00                	mov    (%eax),%eax
801083a8:	83 e0 01             	and    $0x1,%eax
801083ab:	85 c0                	test   %eax,%eax
801083ad:	74 14                	je     801083c3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801083af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b2:	8b 00                	mov    (%eax),%eax
801083b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083b9:	05 00 00 00 80       	add    $0x80000000,%eax
801083be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083c1:	eb 48                	jmp    8010840b <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801083c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801083c7:	74 0e                	je     801083d7 <walkpgdir+0x4f>
801083c9:	e8 99 aa ff ff       	call   80102e67 <kalloc>
801083ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083d5:	75 07                	jne    801083de <walkpgdir+0x56>
      return 0;
801083d7:	b8 00 00 00 00       	mov    $0x0,%eax
801083dc:	eb 44                	jmp    80108422 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801083de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083e5:	00 
801083e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083ed:	00 
801083ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f1:	89 04 24             	mov    %eax,(%esp)
801083f4:	e8 f5 d1 ff ff       	call   801055ee <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801083f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fc:	05 00 00 00 80       	add    $0x80000000,%eax
80108401:	83 c8 07             	or     $0x7,%eax
80108404:	89 c2                	mov    %eax,%edx
80108406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108409:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010840b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010840e:	c1 e8 0c             	shr    $0xc,%eax
80108411:	25 ff 03 00 00       	and    $0x3ff,%eax
80108416:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010841d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108420:	01 d0                	add    %edx,%eax
}
80108422:	c9                   	leave  
80108423:	c3                   	ret    

80108424 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108424:	55                   	push   %ebp
80108425:	89 e5                	mov    %esp,%ebp
80108427:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010842a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010842d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108432:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108435:	8b 55 0c             	mov    0xc(%ebp),%edx
80108438:	8b 45 10             	mov    0x10(%ebp),%eax
8010843b:	01 d0                	add    %edx,%eax
8010843d:	48                   	dec    %eax
8010843e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108443:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108446:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010844d:	00 
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	89 44 24 04          	mov    %eax,0x4(%esp)
80108455:	8b 45 08             	mov    0x8(%ebp),%eax
80108458:	89 04 24             	mov    %eax,(%esp)
8010845b:	e8 28 ff ff ff       	call   80108388 <walkpgdir>
80108460:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108463:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108467:	75 07                	jne    80108470 <mappages+0x4c>
      return -1;
80108469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010846e:	eb 48                	jmp    801084b8 <mappages+0x94>
    if(*pte & PTE_P)
80108470:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108473:	8b 00                	mov    (%eax),%eax
80108475:	83 e0 01             	and    $0x1,%eax
80108478:	85 c0                	test   %eax,%eax
8010847a:	74 0c                	je     80108488 <mappages+0x64>
      panic("remap");
8010847c:	c7 04 24 18 9c 10 80 	movl   $0x80109c18,(%esp)
80108483:	e8 cc 80 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108488:	8b 45 18             	mov    0x18(%ebp),%eax
8010848b:	0b 45 14             	or     0x14(%ebp),%eax
8010848e:	83 c8 01             	or     $0x1,%eax
80108491:	89 c2                	mov    %eax,%edx
80108493:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108496:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010849e:	75 08                	jne    801084a8 <mappages+0x84>
      break;
801084a0:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801084a1:	b8 00 00 00 00       	mov    $0x0,%eax
801084a6:	eb 10                	jmp    801084b8 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801084a8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801084af:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801084b6:	eb 8e                	jmp    80108446 <mappages+0x22>
  return 0;
}
801084b8:	c9                   	leave  
801084b9:	c3                   	ret    

801084ba <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801084ba:	55                   	push   %ebp
801084bb:	89 e5                	mov    %esp,%ebp
801084bd:	53                   	push   %ebx
801084be:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801084c1:	e8 a1 a9 ff ff       	call   80102e67 <kalloc>
801084c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084cd:	75 0a                	jne    801084d9 <setupkvm+0x1f>
    return 0;
801084cf:	b8 00 00 00 00       	mov    $0x0,%eax
801084d4:	e9 84 00 00 00       	jmp    8010855d <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801084d9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084e0:	00 
801084e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084e8:	00 
801084e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ec:	89 04 24             	mov    %eax,(%esp)
801084ef:	e8 fa d0 ff ff       	call   801055ee <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801084f4:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
801084fb:	eb 54                	jmp    80108551 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801084fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108500:	8b 48 0c             	mov    0xc(%eax),%ecx
80108503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108506:	8b 50 04             	mov    0x4(%eax),%edx
80108509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850c:	8b 58 08             	mov    0x8(%eax),%ebx
8010850f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108512:	8b 40 04             	mov    0x4(%eax),%eax
80108515:	29 c3                	sub    %eax,%ebx
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	8b 00                	mov    (%eax),%eax
8010851c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108520:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108524:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108528:	89 44 24 04          	mov    %eax,0x4(%esp)
8010852c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010852f:	89 04 24             	mov    %eax,(%esp)
80108532:	e8 ed fe ff ff       	call   80108424 <mappages>
80108537:	85 c0                	test   %eax,%eax
80108539:	79 12                	jns    8010854d <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010853b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853e:	89 04 24             	mov    %eax,(%esp)
80108541:	e8 1a 05 00 00       	call   80108a60 <freevm>
      return 0;
80108546:	b8 00 00 00 00       	mov    $0x0,%eax
8010854b:	eb 10                	jmp    8010855d <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010854d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108551:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
80108558:	72 a3                	jb     801084fd <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010855a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010855d:	83 c4 34             	add    $0x34,%esp
80108560:	5b                   	pop    %ebx
80108561:	5d                   	pop    %ebp
80108562:	c3                   	ret    

80108563 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108563:	55                   	push   %ebp
80108564:	89 e5                	mov    %esp,%ebp
80108566:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108569:	e8 4c ff ff ff       	call   801084ba <setupkvm>
8010856e:	a3 a4 7b 11 80       	mov    %eax,0x80117ba4
  switchkvm();
80108573:	e8 02 00 00 00       	call   8010857a <switchkvm>
}
80108578:	c9                   	leave  
80108579:	c3                   	ret    

8010857a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010857a:	55                   	push   %ebp
8010857b:	89 e5                	mov    %esp,%ebp
8010857d:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108580:	a1 a4 7b 11 80       	mov    0x80117ba4,%eax
80108585:	05 00 00 00 80       	add    $0x80000000,%eax
8010858a:	89 04 24             	mov    %eax,(%esp)
8010858d:	e8 ae fa ff ff       	call   80108040 <lcr3>
}
80108592:	c9                   	leave  
80108593:	c3                   	ret    

80108594 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108594:	55                   	push   %ebp
80108595:	89 e5                	mov    %esp,%ebp
80108597:	57                   	push   %edi
80108598:	56                   	push   %esi
80108599:	53                   	push   %ebx
8010859a:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
8010859d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085a1:	75 0c                	jne    801085af <switchuvm+0x1b>
    panic("switchuvm: no process");
801085a3:	c7 04 24 1e 9c 10 80 	movl   $0x80109c1e,(%esp)
801085aa:	e8 a5 7f ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
801085af:	8b 45 08             	mov    0x8(%ebp),%eax
801085b2:	8b 40 08             	mov    0x8(%eax),%eax
801085b5:	85 c0                	test   %eax,%eax
801085b7:	75 0c                	jne    801085c5 <switchuvm+0x31>
    panic("switchuvm: no kstack");
801085b9:	c7 04 24 34 9c 10 80 	movl   $0x80109c34,(%esp)
801085c0:	e8 8f 7f ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801085c5:	8b 45 08             	mov    0x8(%ebp),%eax
801085c8:	8b 40 04             	mov    0x4(%eax),%eax
801085cb:	85 c0                	test   %eax,%eax
801085cd:	75 0c                	jne    801085db <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801085cf:	c7 04 24 49 9c 10 80 	movl   $0x80109c49,(%esp)
801085d6:	e8 79 7f ff ff       	call   80100554 <panic>

  pushcli();
801085db:	e8 0a cf ff ff       	call   801054ea <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801085e0:	e8 0a be ff ff       	call   801043ef <mycpu>
801085e5:	89 c3                	mov    %eax,%ebx
801085e7:	e8 03 be ff ff       	call   801043ef <mycpu>
801085ec:	83 c0 08             	add    $0x8,%eax
801085ef:	89 c6                	mov    %eax,%esi
801085f1:	e8 f9 bd ff ff       	call   801043ef <mycpu>
801085f6:	83 c0 08             	add    $0x8,%eax
801085f9:	c1 e8 10             	shr    $0x10,%eax
801085fc:	89 c7                	mov    %eax,%edi
801085fe:	e8 ec bd ff ff       	call   801043ef <mycpu>
80108603:	83 c0 08             	add    $0x8,%eax
80108606:	c1 e8 18             	shr    $0x18,%eax
80108609:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108610:	67 00 
80108612:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108619:	89 f9                	mov    %edi,%ecx
8010861b:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108621:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108627:	83 e2 f0             	and    $0xfffffff0,%edx
8010862a:	83 ca 09             	or     $0x9,%edx
8010862d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108633:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108639:	83 ca 10             	or     $0x10,%edx
8010863c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108642:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108648:	83 e2 9f             	and    $0xffffff9f,%edx
8010864b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108651:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108657:	83 ca 80             	or     $0xffffff80,%edx
8010865a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108660:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108666:	83 e2 f0             	and    $0xfffffff0,%edx
80108669:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010866f:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108675:	83 e2 ef             	and    $0xffffffef,%edx
80108678:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010867e:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108684:	83 e2 df             	and    $0xffffffdf,%edx
80108687:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010868d:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108693:	83 ca 40             	or     $0x40,%edx
80108696:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010869c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801086a2:	83 e2 7f             	and    $0x7f,%edx
801086a5:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801086ab:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801086b1:	e8 39 bd ff ff       	call   801043ef <mycpu>
801086b6:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801086bc:	83 e2 ef             	and    $0xffffffef,%edx
801086bf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801086c5:	e8 25 bd ff ff       	call   801043ef <mycpu>
801086ca:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801086d0:	e8 1a bd ff ff       	call   801043ef <mycpu>
801086d5:	8b 55 08             	mov    0x8(%ebp),%edx
801086d8:	8b 52 08             	mov    0x8(%edx),%edx
801086db:	81 c2 00 10 00 00    	add    $0x1000,%edx
801086e1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801086e4:	e8 06 bd ff ff       	call   801043ef <mycpu>
801086e9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801086ef:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
801086f6:	e8 30 f9 ff ff       	call   8010802b <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801086fb:	8b 45 08             	mov    0x8(%ebp),%eax
801086fe:	8b 40 04             	mov    0x4(%eax),%eax
80108701:	05 00 00 00 80       	add    $0x80000000,%eax
80108706:	89 04 24             	mov    %eax,(%esp)
80108709:	e8 32 f9 ff ff       	call   80108040 <lcr3>
  popcli();
8010870e:	e8 21 ce ff ff       	call   80105534 <popcli>
}
80108713:	83 c4 1c             	add    $0x1c,%esp
80108716:	5b                   	pop    %ebx
80108717:	5e                   	pop    %esi
80108718:	5f                   	pop    %edi
80108719:	5d                   	pop    %ebp
8010871a:	c3                   	ret    

8010871b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010871b:	55                   	push   %ebp
8010871c:	89 e5                	mov    %esp,%ebp
8010871e:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108721:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108728:	76 0c                	jbe    80108736 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010872a:	c7 04 24 5d 9c 10 80 	movl   $0x80109c5d,(%esp)
80108731:	e8 1e 7e ff ff       	call   80100554 <panic>
  mem = kalloc();
80108736:	e8 2c a7 ff ff       	call   80102e67 <kalloc>
8010873b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010873e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108745:	00 
80108746:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010874d:	00 
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	89 04 24             	mov    %eax,(%esp)
80108754:	e8 95 ce ff ff       	call   801055ee <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875c:	05 00 00 00 80       	add    $0x80000000,%eax
80108761:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108768:	00 
80108769:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010876d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108774:	00 
80108775:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010877c:	00 
8010877d:	8b 45 08             	mov    0x8(%ebp),%eax
80108780:	89 04 24             	mov    %eax,(%esp)
80108783:	e8 9c fc ff ff       	call   80108424 <mappages>
  memmove(mem, init, sz);
80108788:	8b 45 10             	mov    0x10(%ebp),%eax
8010878b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010878f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108792:	89 44 24 04          	mov    %eax,0x4(%esp)
80108796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108799:	89 04 24             	mov    %eax,(%esp)
8010879c:	e8 16 cf ff ff       	call   801056b7 <memmove>
}
801087a1:	c9                   	leave  
801087a2:	c3                   	ret    

801087a3 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801087a3:	55                   	push   %ebp
801087a4:	89 e5                	mov    %esp,%ebp
801087a6:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801087a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801087ac:	25 ff 0f 00 00       	and    $0xfff,%eax
801087b1:	85 c0                	test   %eax,%eax
801087b3:	74 0c                	je     801087c1 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
801087b5:	c7 04 24 78 9c 10 80 	movl   $0x80109c78,(%esp)
801087bc:	e8 93 7d ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801087c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087c8:	e9 a6 00 00 00       	jmp    80108873 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801087cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801087d3:	01 d0                	add    %edx,%eax
801087d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087dc:	00 
801087dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801087e1:	8b 45 08             	mov    0x8(%ebp),%eax
801087e4:	89 04 24             	mov    %eax,(%esp)
801087e7:	e8 9c fb ff ff       	call   80108388 <walkpgdir>
801087ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087f3:	75 0c                	jne    80108801 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801087f5:	c7 04 24 9b 9c 10 80 	movl   $0x80109c9b,(%esp)
801087fc:	e8 53 7d ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108801:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108804:	8b 00                	mov    (%eax),%eax
80108806:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010880b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010880e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108811:	8b 55 18             	mov    0x18(%ebp),%edx
80108814:	29 c2                	sub    %eax,%edx
80108816:	89 d0                	mov    %edx,%eax
80108818:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010881d:	77 0f                	ja     8010882e <loaduvm+0x8b>
      n = sz - i;
8010881f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108822:	8b 55 18             	mov    0x18(%ebp),%edx
80108825:	29 c2                	sub    %eax,%edx
80108827:	89 d0                	mov    %edx,%eax
80108829:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010882c:	eb 07                	jmp    80108835 <loaduvm+0x92>
    else
      n = PGSIZE;
8010882e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108838:	8b 55 14             	mov    0x14(%ebp),%edx
8010883b:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010883e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108841:	05 00 00 00 80       	add    $0x80000000,%eax
80108846:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108849:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010884d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108851:	89 44 24 04          	mov    %eax,0x4(%esp)
80108855:	8b 45 10             	mov    0x10(%ebp),%eax
80108858:	89 04 24             	mov    %eax,(%esp)
8010885b:	e8 f9 96 ff ff       	call   80101f59 <readi>
80108860:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108863:	74 07                	je     8010886c <loaduvm+0xc9>
      return -1;
80108865:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010886a:	eb 18                	jmp    80108884 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010886c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108876:	3b 45 18             	cmp    0x18(%ebp),%eax
80108879:	0f 82 4e ff ff ff    	jb     801087cd <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010887f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108884:	c9                   	leave  
80108885:	c3                   	ret    

80108886 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108886:	55                   	push   %ebp
80108887:	89 e5                	mov    %esp,%ebp
80108889:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010888c:	8b 45 10             	mov    0x10(%ebp),%eax
8010888f:	85 c0                	test   %eax,%eax
80108891:	79 0a                	jns    8010889d <allocuvm+0x17>
    return 0;
80108893:	b8 00 00 00 00       	mov    $0x0,%eax
80108898:	e9 fd 00 00 00       	jmp    8010899a <allocuvm+0x114>
  if(newsz < oldsz)
8010889d:	8b 45 10             	mov    0x10(%ebp),%eax
801088a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088a3:	73 08                	jae    801088ad <allocuvm+0x27>
    return oldsz;
801088a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801088a8:	e9 ed 00 00 00       	jmp    8010899a <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801088ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801088b0:	05 ff 0f 00 00       	add    $0xfff,%eax
801088b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801088bd:	e9 c9 00 00 00       	jmp    8010898b <allocuvm+0x105>
    mem = kalloc();
801088c2:	e8 a0 a5 ff ff       	call   80102e67 <kalloc>
801088c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801088ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088ce:	75 2f                	jne    801088ff <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801088d0:	c7 04 24 b9 9c 10 80 	movl   $0x80109cb9,(%esp)
801088d7:	e8 e5 7a ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801088dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801088df:	89 44 24 08          	mov    %eax,0x8(%esp)
801088e3:	8b 45 10             	mov    0x10(%ebp),%eax
801088e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801088ea:	8b 45 08             	mov    0x8(%ebp),%eax
801088ed:	89 04 24             	mov    %eax,(%esp)
801088f0:	e8 a7 00 00 00       	call   8010899c <deallocuvm>
      return 0;
801088f5:	b8 00 00 00 00       	mov    $0x0,%eax
801088fa:	e9 9b 00 00 00       	jmp    8010899a <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
801088ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108906:	00 
80108907:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010890e:	00 
8010890f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108912:	89 04 24             	mov    %eax,(%esp)
80108915:	e8 d4 cc ff ff       	call   801055ee <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010891a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108926:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010892d:	00 
8010892e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108932:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108939:	00 
8010893a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010893e:	8b 45 08             	mov    0x8(%ebp),%eax
80108941:	89 04 24             	mov    %eax,(%esp)
80108944:	e8 db fa ff ff       	call   80108424 <mappages>
80108949:	85 c0                	test   %eax,%eax
8010894b:	79 37                	jns    80108984 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
8010894d:	c7 04 24 d1 9c 10 80 	movl   $0x80109cd1,(%esp)
80108954:	e8 68 7a ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108959:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108960:	8b 45 10             	mov    0x10(%ebp),%eax
80108963:	89 44 24 04          	mov    %eax,0x4(%esp)
80108967:	8b 45 08             	mov    0x8(%ebp),%eax
8010896a:	89 04 24             	mov    %eax,(%esp)
8010896d:	e8 2a 00 00 00       	call   8010899c <deallocuvm>
      kfree(mem);
80108972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108975:	89 04 24             	mov    %eax,(%esp)
80108978:	e8 18 a4 ff ff       	call   80102d95 <kfree>
      return 0;
8010897d:	b8 00 00 00 00       	mov    $0x0,%eax
80108982:	eb 16                	jmp    8010899a <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108984:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010898b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108991:	0f 82 2b ff ff ff    	jb     801088c2 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108997:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010899a:	c9                   	leave  
8010899b:	c3                   	ret    

8010899c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010899c:	55                   	push   %ebp
8010899d:	89 e5                	mov    %esp,%ebp
8010899f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801089a2:	8b 45 10             	mov    0x10(%ebp),%eax
801089a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089a8:	72 08                	jb     801089b2 <deallocuvm+0x16>
    return oldsz;
801089aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801089ad:	e9 ac 00 00 00       	jmp    80108a5e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801089b2:	8b 45 10             	mov    0x10(%ebp),%eax
801089b5:	05 ff 0f 00 00       	add    $0xfff,%eax
801089ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801089c2:	e9 88 00 00 00       	jmp    80108a4f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801089c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801089d1:	00 
801089d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801089d6:	8b 45 08             	mov    0x8(%ebp),%eax
801089d9:	89 04 24             	mov    %eax,(%esp)
801089dc:	e8 a7 f9 ff ff       	call   80108388 <walkpgdir>
801089e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801089e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089e8:	75 14                	jne    801089fe <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801089ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ed:	c1 e8 16             	shr    $0x16,%eax
801089f0:	40                   	inc    %eax
801089f1:	c1 e0 16             	shl    $0x16,%eax
801089f4:	2d 00 10 00 00       	sub    $0x1000,%eax
801089f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089fc:	eb 4a                	jmp    80108a48 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801089fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a01:	8b 00                	mov    (%eax),%eax
80108a03:	83 e0 01             	and    $0x1,%eax
80108a06:	85 c0                	test   %eax,%eax
80108a08:	74 3e                	je     80108a48 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a0d:	8b 00                	mov    (%eax),%eax
80108a0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a14:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108a17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a1b:	75 0c                	jne    80108a29 <deallocuvm+0x8d>
        panic("kfree");
80108a1d:	c7 04 24 ed 9c 10 80 	movl   $0x80109ced,(%esp)
80108a24:	e8 2b 7b ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2c:	05 00 00 00 80       	add    $0x80000000,%eax
80108a31:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108a34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a37:	89 04 24             	mov    %eax,(%esp)
80108a3a:	e8 56 a3 ff ff       	call   80102d95 <kfree>
      *pte = 0;
80108a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108a48:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a52:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a55:	0f 82 6c ff ff ff    	jb     801089c7 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108a5b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108a5e:	c9                   	leave  
80108a5f:	c3                   	ret    

80108a60 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108a60:	55                   	push   %ebp
80108a61:	89 e5                	mov    %esp,%ebp
80108a63:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108a66:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108a6a:	75 0c                	jne    80108a78 <freevm+0x18>
    panic("freevm: no pgdir");
80108a6c:	c7 04 24 f3 9c 10 80 	movl   $0x80109cf3,(%esp)
80108a73:	e8 dc 7a ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108a78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a7f:	00 
80108a80:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108a87:	80 
80108a88:	8b 45 08             	mov    0x8(%ebp),%eax
80108a8b:	89 04 24             	mov    %eax,(%esp)
80108a8e:	e8 09 ff ff ff       	call   8010899c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108a93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a9a:	eb 44                	jmp    80108ae0 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa9:	01 d0                	add    %edx,%eax
80108aab:	8b 00                	mov    (%eax),%eax
80108aad:	83 e0 01             	and    $0x1,%eax
80108ab0:	85 c0                	test   %eax,%eax
80108ab2:	74 29                	je     80108add <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108abe:	8b 45 08             	mov    0x8(%ebp),%eax
80108ac1:	01 d0                	add    %edx,%eax
80108ac3:	8b 00                	mov    (%eax),%eax
80108ac5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aca:	05 00 00 00 80       	add    $0x80000000,%eax
80108acf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad5:	89 04 24             	mov    %eax,(%esp)
80108ad8:	e8 b8 a2 ff ff       	call   80102d95 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108add:	ff 45 f4             	incl   -0xc(%ebp)
80108ae0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ae7:	76 b3                	jbe    80108a9c <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80108aec:	89 04 24             	mov    %eax,(%esp)
80108aef:	e8 a1 a2 ff ff       	call   80102d95 <kfree>
}
80108af4:	c9                   	leave  
80108af5:	c3                   	ret    

80108af6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108af6:	55                   	push   %ebp
80108af7:	89 e5                	mov    %esp,%ebp
80108af9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108afc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b03:	00 
80108b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b07:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b0e:	89 04 24             	mov    %eax,(%esp)
80108b11:	e8 72 f8 ff ff       	call   80108388 <walkpgdir>
80108b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108b19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108b1d:	75 0c                	jne    80108b2b <clearpteu+0x35>
    panic("clearpteu");
80108b1f:	c7 04 24 04 9d 10 80 	movl   $0x80109d04,(%esp)
80108b26:	e8 29 7a ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2e:	8b 00                	mov    (%eax),%eax
80108b30:	83 e0 fb             	and    $0xfffffffb,%eax
80108b33:	89 c2                	mov    %eax,%edx
80108b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b38:	89 10                	mov    %edx,(%eax)
}
80108b3a:	c9                   	leave  
80108b3b:	c3                   	ret    

80108b3c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108b3c:	55                   	push   %ebp
80108b3d:	89 e5                	mov    %esp,%ebp
80108b3f:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108b42:	e8 73 f9 ff ff       	call   801084ba <setupkvm>
80108b47:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b4a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b4e:	75 0a                	jne    80108b5a <copyuvm+0x1e>
    return 0;
80108b50:	b8 00 00 00 00       	mov    $0x0,%eax
80108b55:	e9 f8 00 00 00       	jmp    80108c52 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108b5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b61:	e9 cb 00 00 00       	jmp    80108c31 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b70:	00 
80108b71:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b75:	8b 45 08             	mov    0x8(%ebp),%eax
80108b78:	89 04 24             	mov    %eax,(%esp)
80108b7b:	e8 08 f8 ff ff       	call   80108388 <walkpgdir>
80108b80:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b83:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b87:	75 0c                	jne    80108b95 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108b89:	c7 04 24 0e 9d 10 80 	movl   $0x80109d0e,(%esp)
80108b90:	e8 bf 79 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b98:	8b 00                	mov    (%eax),%eax
80108b9a:	83 e0 01             	and    $0x1,%eax
80108b9d:	85 c0                	test   %eax,%eax
80108b9f:	75 0c                	jne    80108bad <copyuvm+0x71>
      panic("copyuvm: page not present");
80108ba1:	c7 04 24 28 9d 10 80 	movl   $0x80109d28,(%esp)
80108ba8:	e8 a7 79 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bb0:	8b 00                	mov    (%eax),%eax
80108bb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bbd:	8b 00                	mov    (%eax),%eax
80108bbf:	25 ff 0f 00 00       	and    $0xfff,%eax
80108bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108bc7:	e8 9b a2 ff ff       	call   80102e67 <kalloc>
80108bcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108bcf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108bd3:	75 02                	jne    80108bd7 <copyuvm+0x9b>
      goto bad;
80108bd5:	eb 6b                	jmp    80108c42 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108bd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bda:	05 00 00 00 80       	add    $0x80000000,%eax
80108bdf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108be6:	00 
80108be7:	89 44 24 04          	mov    %eax,0x4(%esp)
80108beb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bee:	89 04 24             	mov    %eax,(%esp)
80108bf1:	e8 c1 ca ff ff       	call   801056b7 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108bf6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bfc:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c05:	89 54 24 10          	mov    %edx,0x10(%esp)
80108c09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108c0d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c14:	00 
80108c15:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c1c:	89 04 24             	mov    %eax,(%esp)
80108c1f:	e8 00 f8 ff ff       	call   80108424 <mappages>
80108c24:	85 c0                	test   %eax,%eax
80108c26:	79 02                	jns    80108c2a <copyuvm+0xee>
      goto bad;
80108c28:	eb 18                	jmp    80108c42 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108c2a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c34:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c37:	0f 82 29 ff ff ff    	jb     80108b66 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c40:	eb 10                	jmp    80108c52 <copyuvm+0x116>

bad:
  freevm(d);
80108c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c45:	89 04 24             	mov    %eax,(%esp)
80108c48:	e8 13 fe ff ff       	call   80108a60 <freevm>
  return 0;
80108c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c52:	c9                   	leave  
80108c53:	c3                   	ret    

80108c54 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108c54:	55                   	push   %ebp
80108c55:	89 e5                	mov    %esp,%ebp
80108c57:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108c5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c61:	00 
80108c62:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c65:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c69:	8b 45 08             	mov    0x8(%ebp),%eax
80108c6c:	89 04 24             	mov    %eax,(%esp)
80108c6f:	e8 14 f7 ff ff       	call   80108388 <walkpgdir>
80108c74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7a:	8b 00                	mov    (%eax),%eax
80108c7c:	83 e0 01             	and    $0x1,%eax
80108c7f:	85 c0                	test   %eax,%eax
80108c81:	75 07                	jne    80108c8a <uva2ka+0x36>
    return 0;
80108c83:	b8 00 00 00 00       	mov    $0x0,%eax
80108c88:	eb 22                	jmp    80108cac <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8d:	8b 00                	mov    (%eax),%eax
80108c8f:	83 e0 04             	and    $0x4,%eax
80108c92:	85 c0                	test   %eax,%eax
80108c94:	75 07                	jne    80108c9d <uva2ka+0x49>
    return 0;
80108c96:	b8 00 00 00 00       	mov    $0x0,%eax
80108c9b:	eb 0f                	jmp    80108cac <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca0:	8b 00                	mov    (%eax),%eax
80108ca2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ca7:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108cac:	c9                   	leave  
80108cad:	c3                   	ret    

80108cae <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108cae:	55                   	push   %ebp
80108caf:	89 e5                	mov    %esp,%ebp
80108cb1:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108cb4:	8b 45 10             	mov    0x10(%ebp),%eax
80108cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108cba:	e9 87 00 00 00       	jmp    80108d46 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108cca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd4:	89 04 24             	mov    %eax,(%esp)
80108cd7:	e8 78 ff ff ff       	call   80108c54 <uva2ka>
80108cdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108cdf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ce3:	75 07                	jne    80108cec <copyout+0x3e>
      return -1;
80108ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cea:	eb 69                	jmp    80108d55 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108cec:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cef:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108cf2:	29 c2                	sub    %eax,%edx
80108cf4:	89 d0                	mov    %edx,%eax
80108cf6:	05 00 10 00 00       	add    $0x1000,%eax
80108cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d01:	3b 45 14             	cmp    0x14(%ebp),%eax
80108d04:	76 06                	jbe    80108d0c <copyout+0x5e>
      n = len;
80108d06:	8b 45 14             	mov    0x14(%ebp),%eax
80108d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d12:	29 c2                	sub    %eax,%edx
80108d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d17:	01 c2                	add    %eax,%edx
80108d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d1c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d23:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d27:	89 14 24             	mov    %edx,(%esp)
80108d2a:	e8 88 c9 ff ff       	call   801056b7 <memmove>
    len -= n;
80108d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d32:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d38:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108d3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d3e:	05 00 10 00 00       	add    $0x1000,%eax
80108d43:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108d46:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108d4a:	0f 85 6f ff ff ff    	jne    80108cbf <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108d50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d55:	c9                   	leave  
80108d56:	c3                   	ret    
	...

80108d58 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80108d58:	55                   	push   %ebp
80108d59:	89 e5                	mov    %esp,%ebp
80108d5b:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
80108d5e:	8b 45 10             	mov    0x10(%ebp),%eax
80108d61:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d65:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d68:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108d6f:	89 04 24             	mov    %eax,(%esp)
80108d72:	e8 40 c9 ff ff       	call   801056b7 <memmove>
}
80108d77:	c9                   	leave  
80108d78:	c3                   	ret    

80108d79 <strcpy>:

char* strcpy(char *s, char *t){
80108d79:	55                   	push   %ebp
80108d7a:	89 e5                	mov    %esp,%ebp
80108d7c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108d82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108d85:	90                   	nop
80108d86:	8b 45 08             	mov    0x8(%ebp),%eax
80108d89:	8d 50 01             	lea    0x1(%eax),%edx
80108d8c:	89 55 08             	mov    %edx,0x8(%ebp)
80108d8f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d92:	8d 4a 01             	lea    0x1(%edx),%ecx
80108d95:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108d98:	8a 12                	mov    (%edx),%dl
80108d9a:	88 10                	mov    %dl,(%eax)
80108d9c:	8a 00                	mov    (%eax),%al
80108d9e:	84 c0                	test   %al,%al
80108da0:	75 e4                	jne    80108d86 <strcpy+0xd>
    ;
  return os;
80108da2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108da5:	c9                   	leave  
80108da6:	c3                   	ret    

80108da7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80108da7:	55                   	push   %ebp
80108da8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108daa:	eb 06                	jmp    80108db2 <strcmp+0xb>
    p++, q++;
80108dac:	ff 45 08             	incl   0x8(%ebp)
80108daf:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
80108db2:	8b 45 08             	mov    0x8(%ebp),%eax
80108db5:	8a 00                	mov    (%eax),%al
80108db7:	84 c0                	test   %al,%al
80108db9:	74 0e                	je     80108dc9 <strcmp+0x22>
80108dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80108dbe:	8a 10                	mov    (%eax),%dl
80108dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dc3:	8a 00                	mov    (%eax),%al
80108dc5:	38 c2                	cmp    %al,%dl
80108dc7:	74 e3                	je     80108dac <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80108dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80108dcc:	8a 00                	mov    (%eax),%al
80108dce:	0f b6 d0             	movzbl %al,%edx
80108dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dd4:	8a 00                	mov    (%eax),%al
80108dd6:	0f b6 c0             	movzbl %al,%eax
80108dd9:	29 c2                	sub    %eax,%edx
80108ddb:	89 d0                	mov    %edx,%eax
}
80108ddd:	5d                   	pop    %ebp
80108dde:	c3                   	ret    

80108ddf <set_root_inode>:

// struct con

void set_root_inode(char* name){
80108ddf:	55                   	push   %ebp
80108de0:	89 e5                	mov    %esp,%ebp
80108de2:	53                   	push   %ebx
80108de3:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
80108de6:	8b 45 08             	mov    0x8(%ebp),%eax
80108de9:	89 04 24             	mov    %eax,(%esp)
80108dec:	e8 02 01 00 00       	call   80108ef3 <find>
80108df1:	89 c3                	mov    %eax,%ebx
80108df3:	8b 45 08             	mov    0x8(%ebp),%eax
80108df6:	89 04 24             	mov    %eax,(%esp)
80108df9:	e8 1f 99 ff ff       	call   8010271d <namei>
80108dfe:	89 c2                	mov    %eax,%edx
80108e00:	89 d8                	mov    %ebx,%eax
80108e02:	01 c0                	add    %eax,%eax
80108e04:	01 d8                	add    %ebx,%eax
80108e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80108e0d:	01 c8                	add    %ecx,%eax
80108e0f:	c1 e0 02             	shl    $0x2,%eax
80108e12:	05 f0 7b 11 80       	add    $0x80117bf0,%eax
80108e17:	89 50 08             	mov    %edx,0x8(%eax)

}
80108e1a:	83 c4 14             	add    $0x14,%esp
80108e1d:	5b                   	pop    %ebx
80108e1e:	5d                   	pop    %ebp
80108e1f:	c3                   	ret    

80108e20 <get_name>:

void get_name(int vc_num, char* name){
80108e20:	55                   	push   %ebp
80108e21:	89 e5                	mov    %esp,%ebp
80108e23:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80108e26:	8b 55 08             	mov    0x8(%ebp),%edx
80108e29:	89 d0                	mov    %edx,%eax
80108e2b:	01 c0                	add    %eax,%eax
80108e2d:	01 d0                	add    %edx,%eax
80108e2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e36:	01 d0                	add    %edx,%eax
80108e38:	c1 e0 02             	shl    $0x2,%eax
80108e3b:	83 c0 10             	add    $0x10,%eax
80108e3e:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e43:	83 c0 08             	add    $0x8,%eax
80108e46:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80108e49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
80108e50:	eb 03                	jmp    80108e55 <get_name+0x35>
	{
		i++;
80108e52:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80108e55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5b:	01 d0                	add    %edx,%eax
80108e5d:	8a 00                	mov    (%eax),%al
80108e5f:	84 c0                	test   %al,%al
80108e61:	75 ef                	jne    80108e52 <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80108e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e66:	89 44 24 08          	mov    %eax,0x8(%esp)
80108e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e71:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e74:	89 04 24             	mov    %eax,(%esp)
80108e77:	e8 dc fe ff ff       	call   80108d58 <memcpy2>
}
80108e7c:	c9                   	leave  
80108e7d:	c3                   	ret    

80108e7e <g_name>:

char* g_name(int vc_bun){
80108e7e:	55                   	push   %ebp
80108e7f:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
80108e81:	8b 55 08             	mov    0x8(%ebp),%edx
80108e84:	89 d0                	mov    %edx,%eax
80108e86:	01 c0                	add    %eax,%eax
80108e88:	01 d0                	add    %edx,%eax
80108e8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e91:	01 d0                	add    %edx,%eax
80108e93:	c1 e0 02             	shl    $0x2,%eax
80108e96:	83 c0 10             	add    $0x10,%eax
80108e99:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108e9e:	83 c0 08             	add    $0x8,%eax
}
80108ea1:	5d                   	pop    %ebp
80108ea2:	c3                   	ret    

80108ea3 <is_full>:

int is_full(){
80108ea3:	55                   	push   %ebp
80108ea4:	89 e5                	mov    %esp,%ebp
80108ea6:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108ea9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108eb0:	eb 34                	jmp    80108ee6 <is_full+0x43>
		if(strlen(containers[i].name) == 0){
80108eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108eb5:	89 d0                	mov    %edx,%eax
80108eb7:	01 c0                	add    %eax,%eax
80108eb9:	01 d0                	add    %edx,%eax
80108ebb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ec2:	01 d0                	add    %edx,%eax
80108ec4:	c1 e0 02             	shl    $0x2,%eax
80108ec7:	83 c0 10             	add    $0x10,%eax
80108eca:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108ecf:	83 c0 08             	add    $0x8,%eax
80108ed2:	89 04 24             	mov    %eax,(%esp)
80108ed5:	e8 67 c9 ff ff       	call   80105841 <strlen>
80108eda:	85 c0                	test   %eax,%eax
80108edc:	75 05                	jne    80108ee3 <is_full+0x40>
			return i;
80108ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee1:	eb 0e                	jmp    80108ef1 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108ee3:	ff 45 f4             	incl   -0xc(%ebp)
80108ee6:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80108eea:	7e c6                	jle    80108eb2 <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108ef1:	c9                   	leave  
80108ef2:	c3                   	ret    

80108ef3 <find>:

int find(char* name){
80108ef3:	55                   	push   %ebp
80108ef4:	89 e5                	mov    %esp,%ebp
80108ef6:	83 ec 18             	sub    $0x18,%esp
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108ef9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108f00:	eb 54                	jmp    80108f56 <find+0x63>
		if(strcmp(name, "") == 0){
80108f02:	c7 44 24 04 44 9d 10 	movl   $0x80109d44,0x4(%esp)
80108f09:	80 
80108f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0d:	89 04 24             	mov    %eax,(%esp)
80108f10:	e8 92 fe ff ff       	call   80108da7 <strcmp>
80108f15:	85 c0                	test   %eax,%eax
80108f17:	75 02                	jne    80108f1b <find+0x28>
			continue;
80108f19:	eb 38                	jmp    80108f53 <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80108f1b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108f1e:	89 d0                	mov    %edx,%eax
80108f20:	01 c0                	add    %eax,%eax
80108f22:	01 d0                	add    %edx,%eax
80108f24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f2b:	01 d0                	add    %edx,%eax
80108f2d:	c1 e0 02             	shl    $0x2,%eax
80108f30:	83 c0 10             	add    $0x10,%eax
80108f33:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108f38:	83 c0 08             	add    $0x8,%eax
80108f3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f42:	89 04 24             	mov    %eax,(%esp)
80108f45:	e8 5d fe ff ff       	call   80108da7 <strcmp>
80108f4a:	85 c0                	test   %eax,%eax
80108f4c:	75 05                	jne    80108f53 <find+0x60>
			//cprintf("in hereI");
			return i;
80108f4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108f51:	eb 0e                	jmp    80108f61 <find+0x6e>
}

int find(char* name){
	//cprintf("in here");
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108f53:	ff 45 fc             	incl   -0x4(%ebp)
80108f56:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108f5a:	7e a6                	jle    80108f02 <find+0xf>
		if(strcmp(name, containers[i].name) == 0){
			//cprintf("in hereI");
			return i;
		}
	}
	return -1;
80108f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108f61:	c9                   	leave  
80108f62:	c3                   	ret    

80108f63 <get_max_proc>:

int get_max_proc(int vc_num){
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
	return x.max_proc;
80108f98:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80108f9b:	83 c4 40             	add    $0x40,%esp
80108f9e:	5b                   	pop    %ebx
80108f9f:	5e                   	pop    %esi
80108fa0:	5f                   	pop    %edi
80108fa1:	5d                   	pop    %ebp
80108fa2:	c3                   	ret    

80108fa3 <get_container>:

struct container* get_container(int vc_num){
80108fa3:	55                   	push   %ebp
80108fa4:	89 e5                	mov    %esp,%ebp
80108fa6:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80108fa9:	8b 55 08             	mov    0x8(%ebp),%edx
80108fac:	89 d0                	mov    %edx,%eax
80108fae:	01 c0                	add    %eax,%eax
80108fb0:	01 d0                	add    %edx,%eax
80108fb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fb9:	01 d0                	add    %edx,%eax
80108fbb:	c1 e0 02             	shl    $0x2,%eax
80108fbe:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108fc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	// cprintf("vc num given is %d\n.", vc_num);
	// cprintf("The name for this container is %s.\n", cont->name);
	return cont;
80108fc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108fc9:	c9                   	leave  
80108fca:	c3                   	ret    

80108fcb <get_max_mem>:

int get_max_mem(int vc_num){
80108fcb:	55                   	push   %ebp
80108fcc:	89 e5                	mov    %esp,%ebp
80108fce:	57                   	push   %edi
80108fcf:	56                   	push   %esi
80108fd0:	53                   	push   %ebx
80108fd1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108fd4:	8b 55 08             	mov    0x8(%ebp),%edx
80108fd7:	89 d0                	mov    %edx,%eax
80108fd9:	01 c0                	add    %eax,%eax
80108fdb:	01 d0                	add    %edx,%eax
80108fdd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fe4:	01 d0                	add    %edx,%eax
80108fe6:	c1 e0 02             	shl    $0x2,%eax
80108fe9:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80108fee:	8d 55 b8             	lea    -0x48(%ebp),%edx
80108ff1:	89 c3                	mov    %eax,%ebx
80108ff3:	b8 0f 00 00 00       	mov    $0xf,%eax
80108ff8:	89 d7                	mov    %edx,%edi
80108ffa:	89 de                	mov    %ebx,%esi
80108ffc:	89 c1                	mov    %eax,%ecx
80108ffe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80109000:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80109003:	83 c4 40             	add    $0x40,%esp
80109006:	5b                   	pop    %ebx
80109007:	5e                   	pop    %esi
80109008:	5f                   	pop    %edi
80109009:	5d                   	pop    %ebp
8010900a:	c3                   	ret    

8010900b <get_max_disk>:

int get_max_disk(int vc_num){
8010900b:	55                   	push   %ebp
8010900c:	89 e5                	mov    %esp,%ebp
8010900e:	57                   	push   %edi
8010900f:	56                   	push   %esi
80109010:	53                   	push   %ebx
80109011:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109014:	8b 55 08             	mov    0x8(%ebp),%edx
80109017:	89 d0                	mov    %edx,%eax
80109019:	01 c0                	add    %eax,%eax
8010901b:	01 d0                	add    %edx,%eax
8010901d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109024:	01 d0                	add    %edx,%eax
80109026:	c1 e0 02             	shl    $0x2,%eax
80109029:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010902e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109031:	89 c3                	mov    %eax,%ebx
80109033:	b8 0f 00 00 00       	mov    $0xf,%eax
80109038:	89 d7                	mov    %edx,%edi
8010903a:	89 de                	mov    %ebx,%esi
8010903c:	89 c1                	mov    %eax,%ecx
8010903e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80109040:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80109043:	83 c4 40             	add    $0x40,%esp
80109046:	5b                   	pop    %ebx
80109047:	5e                   	pop    %esi
80109048:	5f                   	pop    %edi
80109049:	5d                   	pop    %ebp
8010904a:	c3                   	ret    

8010904b <get_curr_proc>:

int get_curr_proc(int vc_num){
8010904b:	55                   	push   %ebp
8010904c:	89 e5                	mov    %esp,%ebp
8010904e:	57                   	push   %edi
8010904f:	56                   	push   %esi
80109050:	53                   	push   %ebx
80109051:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109054:	8b 55 08             	mov    0x8(%ebp),%edx
80109057:	89 d0                	mov    %edx,%eax
80109059:	01 c0                	add    %eax,%eax
8010905b:	01 d0                	add    %edx,%eax
8010905d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109064:	01 d0                	add    %edx,%eax
80109066:	c1 e0 02             	shl    $0x2,%eax
80109069:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010906e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109071:	89 c3                	mov    %eax,%ebx
80109073:	b8 0f 00 00 00       	mov    $0xf,%eax
80109078:	89 d7                	mov    %edx,%edi
8010907a:	89 de                	mov    %ebx,%esi
8010907c:	89 c1                	mov    %eax,%ecx
8010907e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80109080:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80109083:	83 c4 40             	add    $0x40,%esp
80109086:	5b                   	pop    %ebx
80109087:	5e                   	pop    %esi
80109088:	5f                   	pop    %edi
80109089:	5d                   	pop    %ebp
8010908a:	c3                   	ret    

8010908b <get_curr_mem>:

int get_curr_mem(int vc_num){
8010908b:	55                   	push   %ebp
8010908c:	89 e5                	mov    %esp,%ebp
8010908e:	57                   	push   %edi
8010908f:	56                   	push   %esi
80109090:	53                   	push   %ebx
80109091:	83 ec 5c             	sub    $0x5c,%esp
	struct container x = containers[vc_num];
80109094:	8b 55 08             	mov    0x8(%ebp),%edx
80109097:	89 d0                	mov    %edx,%eax
80109099:	01 c0                	add    %eax,%eax
8010909b:	01 d0                	add    %edx,%eax
8010909d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090a4:	01 d0                	add    %edx,%eax
801090a6:	c1 e0 02             	shl    $0x2,%eax
801090a9:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801090ae:	8d 55 ac             	lea    -0x54(%ebp),%edx
801090b1:	89 c3                	mov    %eax,%ebx
801090b3:	b8 0f 00 00 00       	mov    $0xf,%eax
801090b8:	89 d7                	mov    %edx,%edi
801090ba:	89 de                	mov    %ebx,%esi
801090bc:	89 c1                	mov    %eax,%ecx
801090be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
801090c0:	8b 45 b8             	mov    -0x48(%ebp),%eax
801090c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801090c7:	c7 04 24 48 9d 10 80 	movl   $0x80109d48,(%esp)
801090ce:	e8 ee 72 ff ff       	call   801003c1 <cprintf>
	return x.curr_mem; 
801090d3:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
801090d6:	83 c4 5c             	add    $0x5c,%esp
801090d9:	5b                   	pop    %ebx
801090da:	5e                   	pop    %esi
801090db:	5f                   	pop    %edi
801090dc:	5d                   	pop    %ebp
801090dd:	c3                   	ret    

801090de <get_curr_disk>:

int get_curr_disk(int vc_num){
801090de:	55                   	push   %ebp
801090df:	89 e5                	mov    %esp,%ebp
801090e1:	57                   	push   %edi
801090e2:	56                   	push   %esi
801090e3:	53                   	push   %ebx
801090e4:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801090e7:	8b 55 08             	mov    0x8(%ebp),%edx
801090ea:	89 d0                	mov    %edx,%eax
801090ec:	01 c0                	add    %eax,%eax
801090ee:	01 d0                	add    %edx,%eax
801090f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090f7:	01 d0                	add    %edx,%eax
801090f9:	c1 e0 02             	shl    $0x2,%eax
801090fc:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109101:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109104:	89 c3                	mov    %eax,%ebx
80109106:	b8 0f 00 00 00       	mov    $0xf,%eax
8010910b:	89 d7                	mov    %edx,%edi
8010910d:	89 de                	mov    %ebx,%esi
8010910f:	89 c1                	mov    %eax,%ecx
80109111:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80109113:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
80109116:	83 c4 40             	add    $0x40,%esp
80109119:	5b                   	pop    %ebx
8010911a:	5e                   	pop    %esi
8010911b:	5f                   	pop    %edi
8010911c:	5d                   	pop    %ebp
8010911d:	c3                   	ret    

8010911e <set_name>:

void set_name(char* name, int vc_num){
8010911e:	55                   	push   %ebp
8010911f:	89 e5                	mov    %esp,%ebp
80109121:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109124:	8b 55 0c             	mov    0xc(%ebp),%edx
80109127:	89 d0                	mov    %edx,%eax
80109129:	01 c0                	add    %eax,%eax
8010912b:	01 d0                	add    %edx,%eax
8010912d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109134:	01 d0                	add    %edx,%eax
80109136:	c1 e0 02             	shl    $0x2,%eax
80109139:	83 c0 10             	add    $0x10,%eax
8010913c:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109141:	8d 50 08             	lea    0x8(%eax),%edx
80109144:	8b 45 08             	mov    0x8(%ebp),%eax
80109147:	89 44 24 04          	mov    %eax,0x4(%esp)
8010914b:	89 14 24             	mov    %edx,(%esp)
8010914e:	e8 26 fc ff ff       	call   80108d79 <strcpy>
}
80109153:	c9                   	leave  
80109154:	c3                   	ret    

80109155 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80109155:	55                   	push   %ebp
80109156:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80109158:	8b 55 0c             	mov    0xc(%ebp),%edx
8010915b:	89 d0                	mov    %edx,%eax
8010915d:	01 c0                	add    %eax,%eax
8010915f:	01 d0                	add    %edx,%eax
80109161:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109168:	01 d0                	add    %edx,%eax
8010916a:	c1 e0 02             	shl    $0x2,%eax
8010916d:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80109173:	8b 45 08             	mov    0x8(%ebp),%eax
80109176:	89 02                	mov    %eax,(%edx)
}
80109178:	5d                   	pop    %ebp
80109179:	c3                   	ret    

8010917a <set_max_disk>:

void set_max_disk(int disk, int vc_num){
8010917a:	55                   	push   %ebp
8010917b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
8010917d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109180:	89 d0                	mov    %edx,%eax
80109182:	01 c0                	add    %eax,%eax
80109184:	01 d0                	add    %edx,%eax
80109186:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010918d:	01 d0                	add    %edx,%eax
8010918f:	c1 e0 02             	shl    $0x2,%eax
80109192:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
80109198:	8b 45 08             	mov    0x8(%ebp),%eax
8010919b:	89 42 08             	mov    %eax,0x8(%edx)
}
8010919e:	5d                   	pop    %ebp
8010919f:	c3                   	ret    

801091a0 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
801091a0:	55                   	push   %ebp
801091a1:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
801091a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801091a6:	89 d0                	mov    %edx,%eax
801091a8:	01 c0                	add    %eax,%eax
801091aa:	01 d0                	add    %edx,%eax
801091ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091b3:	01 d0                	add    %edx,%eax
801091b5:	c1 e0 02             	shl    $0x2,%eax
801091b8:	8d 90 c0 7b 11 80    	lea    -0x7fee8440(%eax),%edx
801091be:	8b 45 08             	mov    0x8(%ebp),%eax
801091c1:	89 42 04             	mov    %eax,0x4(%edx)
}
801091c4:	5d                   	pop    %ebp
801091c5:	c3                   	ret    

801091c6 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
801091c6:	55                   	push   %ebp
801091c7:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
801091c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801091cc:	89 d0                	mov    %edx,%eax
801091ce:	01 c0                	add    %eax,%eax
801091d0:	01 d0                	add    %edx,%eax
801091d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091d9:	01 d0                	add    %edx,%eax
801091db:	c1 e0 02             	shl    $0x2,%eax
801091de:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801091e3:	8b 40 0c             	mov    0xc(%eax),%eax
801091e6:	8d 48 01             	lea    0x1(%eax),%ecx
801091e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801091ec:	89 d0                	mov    %edx,%eax
801091ee:	01 c0                	add    %eax,%eax
801091f0:	01 d0                	add    %edx,%eax
801091f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091f9:	01 d0                	add    %edx,%eax
801091fb:	c1 e0 02             	shl    $0x2,%eax
801091fe:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109203:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem-1, containers[vc_num].curr_mem);	
}
80109206:	5d                   	pop    %ebp
80109207:	c3                   	ret    

80109208 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
80109208:	55                   	push   %ebp
80109209:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;
8010920b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010920e:	89 d0                	mov    %edx,%eax
80109210:	01 c0                	add    %eax,%eax
80109212:	01 d0                	add    %edx,%eax
80109214:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010921b:	01 d0                	add    %edx,%eax
8010921d:	c1 e0 02             	shl    $0x2,%eax
80109220:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109225:	8b 40 0c             	mov    0xc(%eax),%eax
80109228:	8d 48 ff             	lea    -0x1(%eax),%ecx
8010922b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010922e:	89 d0                	mov    %edx,%eax
80109230:	01 c0                	add    %eax,%eax
80109232:	01 d0                	add    %edx,%eax
80109234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010923b:	01 d0                	add    %edx,%eax
8010923d:	c1 e0 02             	shl    $0x2,%eax
80109240:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109245:	89 48 0c             	mov    %ecx,0xc(%eax)
	// cprintf("Memory was %d, but now its %d pages.\n",containers[vc_num].curr_mem, containers[vc_num].curr_mem-1);	
}
80109248:	5d                   	pop    %ebp
80109249:	c3                   	ret    

8010924a <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
8010924a:	55                   	push   %ebp
8010924b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
8010924d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109250:	89 d0                	mov    %edx,%eax
80109252:	01 c0                	add    %eax,%eax
80109254:	01 d0                	add    %edx,%eax
80109256:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010925d:	01 d0                	add    %edx,%eax
8010925f:	c1 e0 02             	shl    $0x2,%eax
80109262:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80109267:	8b 50 04             	mov    0x4(%eax),%edx
8010926a:	8b 45 08             	mov    0x8(%ebp),%eax
8010926d:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109270:	8b 55 0c             	mov    0xc(%ebp),%edx
80109273:	89 d0                	mov    %edx,%eax
80109275:	01 c0                	add    %eax,%eax
80109277:	01 d0                	add    %edx,%eax
80109279:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109280:	01 d0                	add    %edx,%eax
80109282:	c1 e0 02             	shl    $0x2,%eax
80109285:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010928a:	89 48 04             	mov    %ecx,0x4(%eax)
}
8010928d:	5d                   	pop    %ebp
8010928e:	c3                   	ret    

8010928f <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
8010928f:	55                   	push   %ebp
80109290:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80109292:	8b 55 0c             	mov    0xc(%ebp),%edx
80109295:	89 d0                	mov    %edx,%eax
80109297:	01 c0                	add    %eax,%eax
80109299:	01 d0                	add    %edx,%eax
8010929b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092a2:	01 d0                	add    %edx,%eax
801092a4:	c1 e0 02             	shl    $0x2,%eax
801092a7:	8d 90 d0 7b 11 80    	lea    -0x7fee8430(%eax),%edx
801092ad:	8b 45 08             	mov    0x8(%ebp),%eax
801092b0:	89 02                	mov    %eax,(%edx)
}
801092b2:	5d                   	pop    %ebp
801092b3:	c3                   	ret    

801092b4 <max_containers>:

int max_containers(){
801092b4:	55                   	push   %ebp
801092b5:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
801092b7:	b8 04 00 00 00       	mov    $0x4,%eax
}
801092bc:	5d                   	pop    %ebp
801092bd:	c3                   	ret    

801092be <container_init>:

void container_init(){
801092be:	55                   	push   %ebp
801092bf:	89 e5                	mov    %esp,%ebp
801092c1:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801092c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801092cb:	e9 f7 00 00 00       	jmp    801093c7 <container_init+0x109>
		strcpy(containers[i].name, "");
801092d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801092d3:	89 d0                	mov    %edx,%eax
801092d5:	01 c0                	add    %eax,%eax
801092d7:	01 d0                	add    %edx,%eax
801092d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092e0:	01 d0                	add    %edx,%eax
801092e2:	c1 e0 02             	shl    $0x2,%eax
801092e5:	83 c0 10             	add    $0x10,%eax
801092e8:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801092ed:	83 c0 08             	add    $0x8,%eax
801092f0:	c7 44 24 04 44 9d 10 	movl   $0x80109d44,0x4(%esp)
801092f7:	80 
801092f8:	89 04 24             	mov    %eax,(%esp)
801092fb:	e8 79 fa ff ff       	call   80108d79 <strcpy>
		containers[i].max_proc = 4;
80109300:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109303:	89 d0                	mov    %edx,%eax
80109305:	01 c0                	add    %eax,%eax
80109307:	01 d0                	add    %edx,%eax
80109309:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109310:	01 d0                	add    %edx,%eax
80109312:	c1 e0 02             	shl    $0x2,%eax
80109315:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010931a:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80109321:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109324:	89 d0                	mov    %edx,%eax
80109326:	01 c0                	add    %eax,%eax
80109328:	01 d0                	add    %edx,%eax
8010932a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109331:	01 d0                	add    %edx,%eax
80109333:	c1 e0 02             	shl    $0x2,%eax
80109336:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010933b:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
80109342:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109345:	89 d0                	mov    %edx,%eax
80109347:	01 c0                	add    %eax,%eax
80109349:	01 d0                	add    %edx,%eax
8010934b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109352:	01 d0                	add    %edx,%eax
80109354:	c1 e0 02             	shl    $0x2,%eax
80109357:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
8010935c:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 0;
80109362:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109365:	89 d0                	mov    %edx,%eax
80109367:	01 c0                	add    %eax,%eax
80109369:	01 d0                	add    %edx,%eax
8010936b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109372:	01 d0                	add    %edx,%eax
80109374:	c1 e0 02             	shl    $0x2,%eax
80109377:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010937c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		containers[i].curr_disk = 0;
80109382:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109385:	89 d0                	mov    %edx,%eax
80109387:	01 c0                	add    %eax,%eax
80109389:	01 d0                	add    %edx,%eax
8010938b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109392:	01 d0                	add    %edx,%eax
80109394:	c1 e0 02             	shl    $0x2,%eax
80109397:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
8010939c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
801093a3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801093a6:	89 d0                	mov    %edx,%eax
801093a8:	01 c0                	add    %eax,%eax
801093aa:	01 d0                	add    %edx,%eax
801093ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093b3:	01 d0                	add    %edx,%eax
801093b5:	c1 e0 02             	shl    $0x2,%eax
801093b8:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801093bd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801093c4:	ff 45 fc             	incl   -0x4(%ebp)
801093c7:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801093cb:	0f 8e ff fe ff ff    	jle    801092d0 <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 0;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
801093d1:	c9                   	leave  
801093d2:	c3                   	ret    

801093d3 <container_reset>:

void container_reset(int vc_num){
801093d3:	55                   	push   %ebp
801093d4:	89 e5                	mov    %esp,%ebp
801093d6:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
801093d9:	8b 55 08             	mov    0x8(%ebp),%edx
801093dc:	89 d0                	mov    %edx,%eax
801093de:	01 c0                	add    %eax,%eax
801093e0:	01 d0                	add    %edx,%eax
801093e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093e9:	01 d0                	add    %edx,%eax
801093eb:	c1 e0 02             	shl    $0x2,%eax
801093ee:	83 c0 10             	add    $0x10,%eax
801093f1:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801093f6:	83 c0 08             	add    $0x8,%eax
801093f9:	c7 44 24 04 44 9d 10 	movl   $0x80109d44,0x4(%esp)
80109400:	80 
80109401:	89 04 24             	mov    %eax,(%esp)
80109404:	e8 70 f9 ff ff       	call   80108d79 <strcpy>
	containers[vc_num].max_proc = 4;
80109409:	8b 55 08             	mov    0x8(%ebp),%edx
8010940c:	89 d0                	mov    %edx,%eax
8010940e:	01 c0                	add    %eax,%eax
80109410:	01 d0                	add    %edx,%eax
80109412:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109419:	01 d0                	add    %edx,%eax
8010941b:	c1 e0 02             	shl    $0x2,%eax
8010941e:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109423:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
	containers[vc_num].max_disk = 100;
8010942a:	8b 55 08             	mov    0x8(%ebp),%edx
8010942d:	89 d0                	mov    %edx,%eax
8010942f:	01 c0                	add    %eax,%eax
80109431:	01 d0                	add    %edx,%eax
80109433:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010943a:	01 d0                	add    %edx,%eax
8010943c:	c1 e0 02             	shl    $0x2,%eax
8010943f:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109444:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 100;
8010944b:	8b 55 08             	mov    0x8(%ebp),%edx
8010944e:	89 d0                	mov    %edx,%eax
80109450:	01 c0                	add    %eax,%eax
80109452:	01 d0                	add    %edx,%eax
80109454:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010945b:	01 d0                	add    %edx,%eax
8010945d:	c1 e0 02             	shl    $0x2,%eax
80109460:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
80109465:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
	containers[vc_num].curr_proc = 0;
8010946b:	8b 55 08             	mov    0x8(%ebp),%edx
8010946e:	89 d0                	mov    %edx,%eax
80109470:	01 c0                	add    %eax,%eax
80109472:	01 d0                	add    %edx,%eax
80109474:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010947b:	01 d0                	add    %edx,%eax
8010947d:	c1 e0 02             	shl    $0x2,%eax
80109480:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
80109485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	containers[vc_num].curr_disk = 0;
8010948b:	8b 55 08             	mov    0x8(%ebp),%edx
8010948e:	89 d0                	mov    %edx,%eax
80109490:	01 c0                	add    %eax,%eax
80109492:	01 d0                	add    %edx,%eax
80109494:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010949b:	01 d0                	add    %edx,%eax
8010949d:	c1 e0 02             	shl    $0x2,%eax
801094a0:	05 d0 7b 11 80       	add    $0x80117bd0,%eax
801094a5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
801094ac:	8b 55 08             	mov    0x8(%ebp),%edx
801094af:	89 d0                	mov    %edx,%eax
801094b1:	01 c0                	add    %eax,%eax
801094b3:	01 d0                	add    %edx,%eax
801094b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094bc:	01 d0                	add    %edx,%eax
801094be:	c1 e0 02             	shl    $0x2,%eax
801094c1:	05 c0 7b 11 80       	add    $0x80117bc0,%eax
801094c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
801094cd:	c9                   	leave  
801094ce:	c3                   	ret    
