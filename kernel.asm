
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
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
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
80100028:	bc 30 e9 10 80       	mov    $0x8010e930,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 16 3b 10 80       	mov    $0x80103b16,%eax
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
8010003a:	c7 44 24 04 3c 9a 10 	movl   $0x80109a3c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100049:	e8 08 55 00 00       	call   80105556 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 8c 30 11 80 3c 	movl   $0x8011303c,0x8011308c
80100055:	30 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 90 30 11 80 3c 	movl   $0x8011303c,0x80113090
8010005f:	30 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 e9 10 80 	movl   $0x8010e974,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 90 30 11 80    	mov    0x80113090,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 3c 30 11 80 	movl   $0x8011303c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 43 9a 10 	movl   $0x80109a43,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 81 53 00 00       	call   80105418 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 90 30 11 80       	mov    0x80113090,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 90 30 11 80       	mov    %eax,0x80113090

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
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
801000c2:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
801000c9:	e8 a9 54 00 00       	call   80105577 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 90 30 11 80       	mov    0x80113090,%eax
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
801000fd:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100104:	e8 d8 54 00 00       	call   801055e1 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 3b 53 00 00       	call   80105452 <acquiresleep>
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
80100128:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 8c 30 11 80       	mov    0x8011308c,%eax
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
80100176:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
8010017d:	e8 5f 54 00 00       	call   801055e1 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 c2 52 00 00       	call   80105452 <acquiresleep>
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
8010019e:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 4a 9a 10 80 	movl   $0x80109a4a,(%esp)
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
801001e2:	e8 36 29 00 00       	call   80102b1d <iderw>
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
801001fb:	e8 ef 52 00 00       	call   801054ef <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 5b 9a 10 80 	movl   $0x80109a5b,(%esp)
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
80100225:	e8 f3 28 00 00       	call   80102b1d <iderw>
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
8010023b:	e8 af 52 00 00       	call   801054ef <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 62 9a 10 80 	movl   $0x80109a62,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 4f 52 00 00       	call   801054ad <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100265:	e8 0d 53 00 00       	call   80105577 <acquire>
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
801002a1:	8b 15 90 30 11 80    	mov    0x80113090,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 3c 30 11 80 	movl   $0x8011303c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 90 30 11 80       	mov    0x80113090,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 90 30 11 80       	mov    %eax,0x80113090
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
801002d1:	e8 0b 53 00 00       	call   801055e1 <release>
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
80100364:	8a 80 08 b0 10 80    	mov    -0x7fef4ff8(%eax),%al
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
801003c7:	a1 d4 d8 10 80       	mov    0x8010d8d4,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
801003dc:	e8 96 51 00 00       	call   80105577 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 69 9a 10 80 	movl   $0x80109a69,(%esp)
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
801004cf:	c7 45 ec 72 9a 10 80 	movl   $0x80109a72,-0x14(%ebp)
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
80100546:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
8010054d:	e8 8f 50 00 00       	call   801055e1 <release>
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
8010055f:	c7 05 d4 d8 10 80 00 	movl   $0x0,0x8010d8d4
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 7b 2d 00 00       	call   801032e9 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 79 9a 10 80 	movl   $0x80109a79,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 8d 9a 10 80 	movl   $0x80109a8d,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 87 50 00 00       	call   8010562e <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 8f 9a 10 80 	movl   $0x80109a8f,(%esp)
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
801005d0:	c7 05 8c d8 10 80 01 	movl   $0x1,0x8010d88c
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
80100666:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
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
80100695:	c7 04 24 93 9a 10 80 	movl   $0x80109a93,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 d5 51 00 00       	call   801058a3 <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 dd 50 00 00       	call   801057da <memset>
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
80100754:	8b 15 04 b0 10 80    	mov    0x8010b004,%edx
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
8010076e:	a1 8c d8 10 80       	mov    0x8010d88c,%eax
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
8010078e:	e8 35 71 00 00       	call   801078c8 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 29 71 00 00       	call   801078c8 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 1d 71 00 00       	call   801078c8 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 10 71 00 00       	call   801078c8 <uartputc>
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
8010080c:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100813:	e8 5f 4d 00 00       	call   80105577 <acquire>
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
80100860:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100865:	40                   	inc    %eax
80100866:	83 f8 04             	cmp    $0x4,%eax
80100869:	7e 23                	jle    8010088e <consoleintr+0x99>
        active = 1;
8010086b:	c7 05 00 b0 10 80 01 	movl   $0x1,0x8010b000
80100872:	00 00 00 
        input = buf1;
80100875:	ba a0 32 11 80       	mov    $0x801132a0,%edx
8010087a:	bb 20 d6 10 80       	mov    $0x8010d620,%ebx
8010087f:	b8 23 00 00 00       	mov    $0x23,%eax
80100884:	89 d7                	mov    %edx,%edi
80100886:	89 de                	mov    %ebx,%esi
80100888:	89 c1                	mov    %eax,%ecx
8010088a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
8010088c:	eb 6e                	jmp    801008fc <consoleintr+0x107>
      } else{
        active = active + 1;
8010088e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100893:	40                   	inc    %eax
80100894:	a3 00 b0 10 80       	mov    %eax,0x8010b000
        if(active == 2){
80100899:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010089e:	83 f8 02             	cmp    $0x2,%eax
801008a1:	75 17                	jne    801008ba <consoleintr+0xc5>
          buf2 = input;
801008a3:	ba c0 d6 10 80       	mov    $0x8010d6c0,%edx
801008a8:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ad:	b8 23 00 00 00       	mov    $0x23,%eax
801008b2:	89 d7                	mov    %edx,%edi
801008b4:	89 de                	mov    %ebx,%esi
801008b6:	89 c1                	mov    %eax,%ecx
801008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 3){
801008ba:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008bf:	83 f8 03             	cmp    $0x3,%eax
801008c2:	75 17                	jne    801008db <consoleintr+0xe6>
          buf3 = input;
801008c4:	ba 60 d7 10 80       	mov    $0x8010d760,%edx
801008c9:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ce:	b8 23 00 00 00       	mov    $0x23,%eax
801008d3:	89 d7                	mov    %edx,%edi
801008d5:	89 de                	mov    %ebx,%esi
801008d7:	89 c1                	mov    %eax,%ecx
801008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 4){
801008db:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008e0:	83 f8 04             	cmp    $0x4,%eax
801008e3:	75 17                	jne    801008fc <consoleintr+0x107>
          buf4 = input;
801008e5:	ba 00 d8 10 80       	mov    $0x8010d800,%edx
801008ea:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
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
80100908:	a1 28 33 11 80       	mov    0x80113328,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 28 33 11 80       	mov    %eax,0x80113328
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
80100922:	8b 15 28 33 11 80    	mov    0x80113328,%edx
80100928:	a1 24 33 11 80       	mov    0x80113324,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 28 33 11 80       	mov    0x80113328,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 a0 32 11 80    	mov    -0x7feecd60(%eax),%al
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
80100949:	8b 15 28 33 11 80    	mov    0x80113328,%edx
8010094f:	a1 24 33 11 80       	mov    0x80113324,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 28 33 11 80       	mov    0x80113328,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 28 33 11 80       	mov    %eax,0x80113328
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
80100983:	8b 15 28 33 11 80    	mov    0x80113328,%edx
80100989:	a1 20 33 11 80       	mov    0x80113320,%eax
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
801009aa:	a1 28 33 11 80       	mov    0x80113328,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 28 33 11 80    	mov    %edx,0x80113328
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 a0 32 11 80    	mov    %al,-0x7feecd60(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 28 33 11 80       	mov    0x80113328,%eax
801009e2:	8b 15 20 33 11 80    	mov    0x80113320,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 28 33 11 80       	mov    0x80113328,%eax
801009f4:	a3 24 33 11 80       	mov    %eax,0x80113324
          wakeup(&input.r);
801009f9:	c7 04 24 20 33 11 80 	movl   $0x80113320,(%esp)
80100a00:	e8 5d 45 00 00       	call   80104f62 <wakeup>
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
80100a1a:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100a21:	e8 bb 4b 00 00       	call   801055e1 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 a6 9a 10 80 	movl   $0x80109aa6,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 cb 45 00 00       	call   80105008 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 be 9a 10 80 	movl   $0x80109abe,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 d8 9a 10 80 	movl   $0x80109ad8,(%esp)
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
80100a83:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100a8a:	e8 e8 4a 00 00       	call   80105577 <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 98 3a 00 00       	call   80104533 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100aa9:	e8 33 4b 00 00       	call   801055e1 <release>
        ilock(ip);
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 09 10 00 00       	call   80101ac2 <ilock>
        return -1;
80100ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100abe:	e9 b3 00 00 00       	jmp    80100b76 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100ac3:	c7 44 24 04 a0 d8 10 	movl   $0x8010d8a0,0x4(%esp)
80100aca:	80 
80100acb:	c7 04 24 20 33 11 80 	movl   $0x80113320,(%esp)
80100ad2:	e8 b4 43 00 00       	call   80104e8b <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100ad7:	8b 15 20 33 11 80    	mov    0x80113320,%edx
80100add:	a1 24 33 11 80       	mov    0x80113324,%eax
80100ae2:	39 c2                	cmp    %eax,%edx
80100ae4:	74 b0                	je     80100a96 <consoleread+0x2a>
80100ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ae9:	8b 40 54             	mov    0x54(%eax),%eax
80100aec:	0f bf d0             	movswl %ax,%edx
80100aef:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100af4:	39 c2                	cmp    %eax,%edx
80100af6:	75 9e                	jne    80100a96 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100af8:	a1 20 33 11 80       	mov    0x80113320,%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 15 20 33 11 80    	mov    %edx,0x80113320
80100b06:	83 e0 7f             	and    $0x7f,%eax
80100b09:	8a 80 a0 32 11 80    	mov    -0x7feecd60(%eax),%al
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
80100b23:	a1 20 33 11 80       	mov    0x80113320,%eax
80100b28:	48                   	dec    %eax
80100b29:	a3 20 33 11 80       	mov    %eax,0x80113320
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
80100b55:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100b5c:	e8 80 4a 00 00       	call   801055e1 <release>
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
80100b87:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100b8c:	39 c2                	cmp    %eax,%edx
80100b8e:	75 5a                	jne    80100bea <consolewrite+0x72>
    iunlock(ip);
80100b90:	8b 45 08             	mov    0x8(%ebp),%eax
80100b93:	89 04 24             	mov    %eax,(%esp)
80100b96:	e8 31 10 00 00       	call   80101bcc <iunlock>
    acquire(&cons.lock);
80100b9b:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100ba2:	e8 d0 49 00 00       	call   80105577 <acquire>
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
80100bd3:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100bda:	e8 02 4a 00 00       	call   801055e1 <release>
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
80100bf5:	c7 44 24 04 f1 9a 10 	movl   $0x80109af1,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100c04:	e8 4d 49 00 00       	call   80105556 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c09:	c7 05 8c 3e 11 80 78 	movl   $0x80100b78,0x80113e8c
80100c10:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c13:	c7 05 88 3e 11 80 6c 	movl   $0x80100a6c,0x80113e88
80100c1a:	0a 10 80 
  cons.locking = 1;
80100c1d:	c7 05 d4 d8 10 80 01 	movl   $0x1,0x8010d8d4
80100c24:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c2e:	00 
80100c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c36:	e8 94 20 00 00       	call   80102ccf <ioapicenable>
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
80100c49:	e8 e5 38 00 00       	call   80104533 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 dd 2b 00 00       	call   80103833 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 cc 1a 00 00       	call   8010272d <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 46 2c 00 00       	call   801038b5 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 f9 9a 10 80 	movl   $0x80109af9,(%esp)
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
80100cd8:	e8 cd 7b 00 00       	call   801088aa <setupkvm>
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
80100d96:	e8 db 7e 00 00       	call   80108c76 <allocuvm>
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
80100de8:	e8 a6 7d 00 00       	call   80108b93 <loaduvm>
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
80100e1f:	e8 91 2a 00 00       	call   801038b5 <end_op>
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
80100e54:	e8 1d 7e 00 00       	call   80108c76 <allocuvm>
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
80100e79:	e8 68 80 00 00       	call   80108ee6 <clearpteu>
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
80100eaf:	e8 79 4b 00 00       	call   80105a2d <strlen>
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
80100ed6:	e8 52 4b 00 00       	call   80105a2d <strlen>
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
80100f04:	e8 95 81 00 00       	call   8010909e <copyout>
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
80100fa8:	e8 f1 80 00 00       	call   8010909e <copyout>
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
80100ff8:	e8 e9 49 00 00       	call   801059e6 <safestrcpy>

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
80101038:	e8 47 79 00 00       	call   80108984 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 08 7e 00 00       	call   80108e50 <freevm>
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
8010105b:	e8 f0 7d 00 00       	call   80108e50 <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 3f 28 00 00       	call   801038b5 <end_op>
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
801010ec:	c7 44 24 04 05 9b 10 	movl   $0x80109b05,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801010fb:	e8 56 44 00 00       	call   80105556 <initlock>
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
80101108:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010110f:	e8 63 44 00 00       	call   80105577 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101114:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
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
80101131:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80101138:	e8 a4 44 00 00       	call   801055e1 <release>
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 1e                	jmp    80101160 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
80101146:	81 7d f4 64 3e 11 80 	cmpl   $0x80113e64,-0xc(%ebp)
8010114d:	72 ce                	jb     8010111d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114f:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80101156:	e8 86 44 00 00       	call   801055e1 <release>
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
80101168:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010116f:	e8 03 44 00 00       	call   80105577 <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 0c 9b 10 80 	movl   $0x80109b0c,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011a0:	e8 3c 44 00 00       	call   801055e1 <release>
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
801011b3:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011ba:	e8 b8 43 00 00       	call   80105577 <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 14 9b 10 80 	movl   $0x80109b14,(%esp)
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
801011ee:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011f5:	e8 e7 43 00 00       	call   801055e1 <release>
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
80101224:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010122b:	e8 b1 43 00 00       	call   801055e1 <release>

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
80101248:	e8 7e 2f 00 00       	call   801041cb <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 d7 25 00 00       	call   80103833 <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 49 26 00 00       	call   801038b5 <end_op>
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
801012fe:	e8 46 30 00 00       	call   80104349 <piperead>
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
80101370:	c7 04 24 1e 9b 10 80 	movl   $0x80109b1e,(%esp)
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
801013ba:	e8 9e 2e 00 00       	call   8010425d <pipewrite>
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
80101400:	e8 2e 24 00 00       	call   80103833 <begin_op>
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
80101466:	e8 4a 24 00 00       	call   801038b5 <end_op>

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
8010147b:	c7 04 24 27 9b 10 80 	movl   $0x80109b27,(%esp)
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
801014ad:	c7 04 24 37 9b 10 80 	movl   $0x80109b37,(%esp)
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
801014f4:	e8 aa 43 00 00       	call   801058a3 <memmove>
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
8010153a:	e8 9b 42 00 00       	call   801057da <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 ed 24 00 00       	call   80103a37 <log_write>
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
80101581:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
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
8010160d:	e8 25 24 00 00       	call   80103a37 <log_write>
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
80101654:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
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
80101676:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 82 ed fe ff ff    	jb     80101570 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	c7 04 24 44 9b 10 80 	movl   $0x80109b44,(%esp)
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
80101697:	c7 44 24 04 e0 3e 11 	movl   $0x80113ee0,0x4(%esp)
8010169e:	80 
8010169f:	8b 45 08             	mov    0x8(%ebp),%eax
801016a2:	89 04 24             	mov    %eax,(%esp)
801016a5:	e8 16 fe ff ff       	call   801014c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ad:	c1 e8 0c             	shr    $0xc,%eax
801016b0:	89 c2                	mov    %eax,%edx
801016b2:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
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
80101713:	c7 04 24 5a 9b 10 80 	movl   $0x80109b5a,(%esp)
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
80101749:	e8 e9 22 00 00       	call   80103a37 <log_write>
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
8010176b:	c7 44 24 04 6d 9b 10 	movl   $0x80109b6d,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
8010177a:	e8 d7 3d 00 00       	call   80105556 <initlock>
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
80101798:	05 00 3f 11 80       	add    $0x80113f00,%eax
8010179d:	83 c0 10             	add    $0x10,%eax
801017a0:	c7 44 24 04 74 9b 10 	movl   $0x80109b74,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 68 3c 00 00       	call   80105418 <initsleeplock>
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
801017b9:	c7 44 24 04 e0 3e 11 	movl   $0x80113ee0,0x4(%esp)
801017c0:	80 
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 f4 fc ff ff       	call   801014c0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
801017d1:	8b 3d f4 3e 11 80    	mov    0x80113ef4,%edi
801017d7:	8b 35 f0 3e 11 80    	mov    0x80113ef0,%esi
801017dd:	8b 1d ec 3e 11 80    	mov    0x80113eec,%ebx
801017e3:	8b 0d e8 3e 11 80    	mov    0x80113ee8,%ecx
801017e9:	8b 15 e4 3e 11 80    	mov    0x80113ee4,%edx
801017ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017f2:	8b 15 e0 3e 11 80    	mov    0x80113ee0,%edx
801017f8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017fc:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101800:	89 74 24 14          	mov    %esi,0x14(%esp)
80101804:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101808:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010180c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010180f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101813:	89 d0                	mov    %edx,%eax
80101815:	89 44 24 04          	mov    %eax,0x4(%esp)
80101819:	c7 04 24 7c 9b 10 80 	movl   $0x80109b7c,(%esp)
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
8010184e:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
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
8010189b:	e8 3a 3f 00 00       	call   801057da <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 83 21 00 00       	call   80103a37 <log_write>
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
801018e4:	a1 e8 3e 11 80       	mov    0x80113ee8,%eax
801018e9:	39 c2                	cmp    %eax,%edx
801018eb:	0f 82 55 ff ff ff    	jb     80101846 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018f1:	c7 04 24 cf 9b 10 80 	movl   $0x80109bcf,(%esp)
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
80101910:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
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
8010199e:	e8 00 3f 00 00       	call   801058a3 <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 89 20 00 00       	call   80103a37 <log_write>
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
801019c1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801019c8:	e8 aa 3b 00 00       	call   80105577 <acquire>

  // Is the inode already cached?
  empty = 0;
801019cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019d4:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
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
80101a0b:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101a12:	e8 ca 3b 00 00       	call   801055e1 <release>
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
80101a39:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
80101a40:	72 9b                	jb     801019dd <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a46:	75 0c                	jne    80101a54 <iget+0x99>
    panic("iget: no inodes");
80101a48:	c7 04 24 e1 9b 10 80 	movl   $0x80109be1,(%esp)
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
80101a7f:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101a86:	e8 56 3b 00 00       	call   801055e1 <release>

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
80101a96:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101a9d:	e8 d5 3a 00 00       	call   80105577 <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101ab8:	e8 24 3b 00 00       	call   801055e1 <release>
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
80101ad8:	c7 04 24 f1 9b 10 80 	movl   $0x80109bf1,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 60 39 00 00       	call   80105452 <acquiresleep>

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
80101b0b:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
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
80101b99:	e8 05 3d 00 00       	call   801058a3 <memmove>
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
80101bbe:	c7 04 24 f7 9b 10 80 	movl   $0x80109bf7,(%esp)
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
80101be1:	e8 09 39 00 00       	call   801054ef <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 06 9c 10 80 	movl   $0x80109c06,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 9f 38 00 00       	call   801054ad <releasesleep>
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
80101c1f:	e8 2e 38 00 00       	call   80105452 <acquiresleep>
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
80101c3a:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c41:	e8 31 39 00 00       	call   80105577 <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c56:	e8 86 39 00 00       	call   801055e1 <release>
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
80101c93:	e8 15 38 00 00       	call   801054ad <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c9f:	e8 d3 38 00 00       	call   80105577 <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101cba:	e8 22 39 00 00       	call   801055e1 <release>
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
80101dcb:	e8 67 1c 00 00       	call   80103a37 <log_write>
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
80101de0:	c7 04 24 0e 9c 10 80 	movl   $0x80109c0e,(%esp)
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
80101f8c:	8b 04 c5 80 3e 11 80 	mov    -0x7feec180(,%eax,8),%eax
80101f93:	85 c0                	test   %eax,%eax
80101f95:	75 0a                	jne    80101fa1 <readi+0x48>
      return -1;
80101f97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f9c:	e9 1a 01 00 00       	jmp    801020bb <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fa8:	98                   	cwtl   
80101fa9:	8b 04 c5 80 3e 11 80 	mov    -0x7feec180(,%eax,8),%eax
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
8010208a:	e8 14 38 00 00       	call   801058a3 <memmove>
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
801020c3:	e8 6b 24 00 00       	call   80104533 <myproc>
801020c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	83 c0 18             	add    $0x18,%eax
801020d7:	89 04 24             	mov    %eax,(%esp)
801020da:	e8 6c 72 00 00       	call   8010934b <find>
801020df:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if(ip->type == T_DEV){
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	8b 40 50             	mov    0x50(%eax),%eax
801020e8:	66 83 f8 03          	cmp    $0x3,%ax
801020ec:	75 60                	jne    8010214e <writei+0x91>
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
8010210f:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
80102116:	85 c0                	test   %eax,%eax
80102118:	75 0a                	jne    80102124 <writei+0x67>
      return -1;
8010211a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010211f:	e9 64 01 00 00       	jmp    80102288 <writei+0x1cb>
    }
    return devsw[ip->major].write(ip, src, n);
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	66 8b 40 52          	mov    0x52(%eax),%ax
8010212b:	98                   	cwtl   
8010212c:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
80102133:	8b 55 14             	mov    0x14(%ebp),%edx
80102136:	89 54 24 08          	mov    %edx,0x8(%esp)
8010213a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010213d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102141:	8b 55 08             	mov    0x8(%ebp),%edx
80102144:	89 14 24             	mov    %edx,(%esp)
80102147:	ff d0                	call   *%eax
80102149:	e9 3a 01 00 00       	jmp    80102288 <writei+0x1cb>
  }


  if(off > ip->size || off + n < off){
8010214e:	8b 45 08             	mov    0x8(%ebp),%eax
80102151:	8b 40 58             	mov    0x58(%eax),%eax
80102154:	3b 45 10             	cmp    0x10(%ebp),%eax
80102157:	72 0d                	jb     80102166 <writei+0xa9>
80102159:	8b 45 14             	mov    0x14(%ebp),%eax
8010215c:	8b 55 10             	mov    0x10(%ebp),%edx
8010215f:	01 d0                	add    %edx,%eax
80102161:	3b 45 10             	cmp    0x10(%ebp),%eax
80102164:	73 0a                	jae    80102170 <writei+0xb3>
    return -1;
80102166:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216b:	e9 18 01 00 00       	jmp    80102288 <writei+0x1cb>
  }
  if(off + n > MAXFILE*BSIZE){
80102170:	8b 45 14             	mov    0x14(%ebp),%eax
80102173:	8b 55 10             	mov    0x10(%ebp),%edx
80102176:	01 d0                	add    %edx,%eax
80102178:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217d:	76 0a                	jbe    80102189 <writei+0xcc>
    return -1;
8010217f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102184:	e9 ff 00 00 00       	jmp    80102288 <writei+0x1cb>
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102189:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102190:	e9 a0 00 00 00       	jmp    80102235 <writei+0x178>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102195:	8b 45 10             	mov    0x10(%ebp),%eax
80102198:	c1 e8 09             	shr    $0x9,%eax
8010219b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	89 04 24             	mov    %eax,(%esp)
801021a5:	e8 35 fb ff ff       	call   80101cdf <bmap>
801021aa:	8b 55 08             	mov    0x8(%ebp),%edx
801021ad:	8b 12                	mov    (%edx),%edx
801021af:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b3:	89 14 24             	mov    %edx,(%esp)
801021b6:	e8 fa df ff ff       	call   801001b5 <bread>
801021bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021be:	8b 45 10             	mov    0x10(%ebp),%eax
801021c1:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c6:	89 c2                	mov    %eax,%edx
801021c8:	b8 00 02 00 00       	mov    $0x200,%eax
801021cd:	29 d0                	sub    %edx,%eax
801021cf:	89 c1                	mov    %eax,%ecx
801021d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021d4:	8b 55 14             	mov    0x14(%ebp),%edx
801021d7:	29 c2                	sub    %eax,%edx
801021d9:	89 c8                	mov    %ecx,%eax
801021db:	39 d0                	cmp    %edx,%eax
801021dd:	76 02                	jbe    801021e1 <writei+0x124>
801021df:	89 d0                	mov    %edx,%eax
801021e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	8d 50 50             	lea    0x50(%eax),%edx
801021ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801021f2:	01 d0                	add    %edx,%eax
801021f4:	8d 50 0c             	lea    0xc(%eax),%edx
801021f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801021fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801021fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80102201:	89 44 24 04          	mov    %eax,0x4(%esp)
80102205:	89 14 24             	mov    %edx,(%esp)
80102208:	e8 96 36 00 00       	call   801058a3 <memmove>
    log_write(bp);
8010220d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102210:	89 04 24             	mov    %eax,(%esp)
80102213:	e8 1f 18 00 00       	call   80103a37 <log_write>
    brelse(bp);
80102218:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010221b:	89 04 24             	mov    %eax,(%esp)
8010221e:	e8 09 e0 ff ff       	call   8010022c <brelse>
  }
  if(off + n > MAXFILE*BSIZE){
    return -1;
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102226:	01 45 f4             	add    %eax,-0xc(%ebp)
80102229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010222c:	01 45 10             	add    %eax,0x10(%ebp)
8010222f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102232:	01 45 0c             	add    %eax,0xc(%ebp)
80102235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102238:	3b 45 14             	cmp    0x14(%ebp),%eax
8010223b:	0f 82 54 ff ff ff    	jb     80102195 <writei+0xd8>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(x >= 0){
80102241:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80102245:	78 19                	js     80102260 <writei+0x1a3>
    if(tot == 1){
80102247:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010224b:	75 13                	jne    80102260 <writei+0x1a3>
      set_curr_disk(1, x);
8010224d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102250:	89 44 24 04          	mov    %eax,0x4(%esp)
80102254:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010225b:	e8 80 74 00 00       	call   801096e0 <set_curr_disk>
    }
  }
  if(n > 0 && off > ip->size){
80102260:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102264:	74 1f                	je     80102285 <writei+0x1c8>
80102266:	8b 45 08             	mov    0x8(%ebp),%eax
80102269:	8b 40 58             	mov    0x58(%eax),%eax
8010226c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010226f:	73 14                	jae    80102285 <writei+0x1c8>
    ip->size = off;
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 55 10             	mov    0x10(%ebp),%edx
80102277:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010227a:	8b 45 08             	mov    0x8(%ebp),%eax
8010227d:	89 04 24             	mov    %eax,(%esp)
80102280:	e8 7a f6 ff ff       	call   801018ff <iupdate>
  }
  return n;
80102285:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102288:	c9                   	leave  
80102289:	c3                   	ret    

8010228a <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102290:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102297:	00 
80102298:	8b 45 0c             	mov    0xc(%ebp),%eax
8010229b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010229f:	8b 45 08             	mov    0x8(%ebp),%eax
801022a2:	89 04 24             	mov    %eax,(%esp)
801022a5:	e8 98 36 00 00       	call   80105942 <strncmp>
}
801022aa:	c9                   	leave  
801022ab:	c3                   	ret    

801022ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022ac:	55                   	push   %ebp
801022ad:	89 e5                	mov    %esp,%ebp
801022af:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022b2:	8b 45 08             	mov    0x8(%ebp),%eax
801022b5:	8b 40 50             	mov    0x50(%eax),%eax
801022b8:	66 83 f8 01          	cmp    $0x1,%ax
801022bc:	74 0c                	je     801022ca <dirlookup+0x1e>
    panic("dirlookup not DIR");
801022be:	c7 04 24 21 9c 10 80 	movl   $0x80109c21,(%esp)
801022c5:	e8 8a e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d1:	e9 86 00 00 00       	jmp    8010235c <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022dd:	00 
801022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e1:	89 44 24 08          	mov    %eax,0x8(%esp)
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ec:	8b 45 08             	mov    0x8(%ebp),%eax
801022ef:	89 04 24             	mov    %eax,(%esp)
801022f2:	e8 62 fc ff ff       	call   80101f59 <readi>
801022f7:	83 f8 10             	cmp    $0x10,%eax
801022fa:	74 0c                	je     80102308 <dirlookup+0x5c>
      panic("dirlookup read");
801022fc:	c7 04 24 33 9c 10 80 	movl   $0x80109c33,(%esp)
80102303:	e8 4c e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102308:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010230b:	66 85 c0             	test   %ax,%ax
8010230e:	75 02                	jne    80102312 <dirlookup+0x66>
      continue;
80102310:	eb 46                	jmp    80102358 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
80102312:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102315:	83 c0 02             	add    $0x2,%eax
80102318:	89 44 24 04          	mov    %eax,0x4(%esp)
8010231c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010231f:	89 04 24             	mov    %eax,(%esp)
80102322:	e8 63 ff ff ff       	call   8010228a <namecmp>
80102327:	85 c0                	test   %eax,%eax
80102329:	75 2d                	jne    80102358 <dirlookup+0xac>
      // entry matches path element
      if(poff)
8010232b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010232f:	74 08                	je     80102339 <dirlookup+0x8d>
        *poff = off;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102337:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102339:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010233c:	0f b7 c0             	movzwl %ax,%eax
8010233f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102342:	8b 45 08             	mov    0x8(%ebp),%eax
80102345:	8b 00                	mov    (%eax),%eax
80102347:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010234a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010234e:	89 04 24             	mov    %eax,(%esp)
80102351:	e8 65 f6 ff ff       	call   801019bb <iget>
80102356:	eb 18                	jmp    80102370 <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102358:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	8b 40 58             	mov    0x58(%eax),%eax
80102362:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102365:	0f 87 6b ff ff ff    	ja     801022d6 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010236b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102370:	c9                   	leave  
80102371:	c3                   	ret    

80102372 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102372:	55                   	push   %ebp
80102373:	89 e5                	mov    %esp,%ebp
80102375:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102378:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010237f:	00 
80102380:	8b 45 0c             	mov    0xc(%ebp),%eax
80102383:	89 44 24 04          	mov    %eax,0x4(%esp)
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	89 04 24             	mov    %eax,(%esp)
8010238d:	e8 1a ff ff ff       	call   801022ac <dirlookup>
80102392:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102395:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102399:	74 15                	je     801023b0 <dirlink+0x3e>
    iput(ip);
8010239b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010239e:	89 04 24             	mov    %eax,(%esp)
801023a1:	e8 6a f8 ff ff       	call   80101c10 <iput>
    return -1;
801023a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ab:	e9 b6 00 00 00       	jmp    80102466 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b7:	eb 45                	jmp    801023fe <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023c3:	00 
801023c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801023c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801023cf:	8b 45 08             	mov    0x8(%ebp),%eax
801023d2:	89 04 24             	mov    %eax,(%esp)
801023d5:	e8 7f fb ff ff       	call   80101f59 <readi>
801023da:	83 f8 10             	cmp    $0x10,%eax
801023dd:	74 0c                	je     801023eb <dirlink+0x79>
      panic("dirlink read");
801023df:	c7 04 24 42 9c 10 80 	movl   $0x80109c42,(%esp)
801023e6:	e8 69 e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801023eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023ee:	66 85 c0             	test   %ax,%ax
801023f1:	75 02                	jne    801023f5 <dirlink+0x83>
      break;
801023f3:	eb 16                	jmp    8010240b <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f8:	83 c0 10             	add    $0x10,%eax
801023fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
80102404:	8b 40 58             	mov    0x58(%eax),%eax
80102407:	39 c2                	cmp    %eax,%edx
80102409:	72 ae                	jb     801023b9 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010240b:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102412:	00 
80102413:	8b 45 0c             	mov    0xc(%ebp),%eax
80102416:	89 44 24 04          	mov    %eax,0x4(%esp)
8010241a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010241d:	83 c0 02             	add    $0x2,%eax
80102420:	89 04 24             	mov    %eax,(%esp)
80102423:	e8 68 35 00 00       	call   80105990 <strncpy>
  de.inum = inum;
80102428:	8b 45 10             	mov    0x10(%ebp),%eax
8010242b:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010242f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102432:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102439:	00 
8010243a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010243e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8b 45 08             	mov    0x8(%ebp),%eax
80102448:	89 04 24             	mov    %eax,(%esp)
8010244b:	e8 6d fc ff ff       	call   801020bd <writei>
80102450:	83 f8 10             	cmp    $0x10,%eax
80102453:	74 0c                	je     80102461 <dirlink+0xef>
    panic("dirlink");
80102455:	c7 04 24 4f 9c 10 80 	movl   $0x80109c4f,(%esp)
8010245c:	e8 f3 e0 ff ff       	call   80100554 <panic>

  return 0;
80102461:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102466:	c9                   	leave  
80102467:	c3                   	ret    

80102468 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102468:	55                   	push   %ebp
80102469:	89 e5                	mov    %esp,%ebp
8010246b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010246e:	eb 03                	jmp    80102473 <skipelem+0xb>
    path++;
80102470:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102473:	8b 45 08             	mov    0x8(%ebp),%eax
80102476:	8a 00                	mov    (%eax),%al
80102478:	3c 2f                	cmp    $0x2f,%al
8010247a:	74 f4                	je     80102470 <skipelem+0x8>
    path++;
  if(*path == 0)
8010247c:	8b 45 08             	mov    0x8(%ebp),%eax
8010247f:	8a 00                	mov    (%eax),%al
80102481:	84 c0                	test   %al,%al
80102483:	75 0a                	jne    8010248f <skipelem+0x27>
    return 0;
80102485:	b8 00 00 00 00       	mov    $0x0,%eax
8010248a:	e9 81 00 00 00       	jmp    80102510 <skipelem+0xa8>
  s = path;
8010248f:	8b 45 08             	mov    0x8(%ebp),%eax
80102492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102495:	eb 03                	jmp    8010249a <skipelem+0x32>
    path++;
80102497:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	8a 00                	mov    (%eax),%al
8010249f:	3c 2f                	cmp    $0x2f,%al
801024a1:	74 09                	je     801024ac <skipelem+0x44>
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	8a 00                	mov    (%eax),%al
801024a8:	84 c0                	test   %al,%al
801024aa:	75 eb                	jne    80102497 <skipelem+0x2f>
    path++;
  len = path - s;
801024ac:	8b 55 08             	mov    0x8(%ebp),%edx
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	29 c2                	sub    %eax,%edx
801024b4:	89 d0                	mov    %edx,%eax
801024b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024b9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024bd:	7e 1c                	jle    801024db <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801024bf:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024c6:	00 
801024c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801024d1:	89 04 24             	mov    %eax,(%esp)
801024d4:	e8 ca 33 00 00       	call   801058a3 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024d9:	eb 29                	jmp    80102504 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801024db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024de:	89 44 24 08          	mov    %eax,0x8(%esp)
801024e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ec:	89 04 24             	mov    %eax,(%esp)
801024ef:	e8 af 33 00 00       	call   801058a3 <memmove>
    name[len] = 0;
801024f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024fa:	01 d0                	add    %edx,%eax
801024fc:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024ff:	eb 03                	jmp    80102504 <skipelem+0x9c>
    path++;
80102501:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102504:	8b 45 08             	mov    0x8(%ebp),%eax
80102507:	8a 00                	mov    (%eax),%al
80102509:	3c 2f                	cmp    $0x2f,%al
8010250b:	74 f4                	je     80102501 <skipelem+0x99>
    path++;
  return path;
8010250d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102510:	c9                   	leave  
80102511:	c3                   	ret    

80102512 <strcmp3>:

int
strcmp3(const char *p, const char *q)
{
80102512:	55                   	push   %ebp
80102513:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80102515:	eb 06                	jmp    8010251d <strcmp3+0xb>
    p++, q++;
80102517:	ff 45 08             	incl   0x8(%ebp)
8010251a:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp3(const char *p, const char *q)
{
  while(*p && *p == *q)
8010251d:	8b 45 08             	mov    0x8(%ebp),%eax
80102520:	8a 00                	mov    (%eax),%al
80102522:	84 c0                	test   %al,%al
80102524:	74 0e                	je     80102534 <strcmp3+0x22>
80102526:	8b 45 08             	mov    0x8(%ebp),%eax
80102529:	8a 10                	mov    (%eax),%dl
8010252b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010252e:	8a 00                	mov    (%eax),%al
80102530:	38 c2                	cmp    %al,%dl
80102532:	74 e3                	je     80102517 <strcmp3+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80102534:	8b 45 08             	mov    0x8(%ebp),%eax
80102537:	8a 00                	mov    (%eax),%al
80102539:	0f b6 d0             	movzbl %al,%edx
8010253c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010253f:	8a 00                	mov    (%eax),%al
80102541:	0f b6 c0             	movzbl %al,%eax
80102544:	29 c2                	sub    %eax,%edx
80102546:	89 d0                	mov    %edx,%eax
}
80102548:	5d                   	pop    %ebp
80102549:	c3                   	ret    

8010254a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
8010254d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102550:	8b 45 08             	mov    0x8(%ebp),%eax
80102553:	8a 00                	mov    (%eax),%al
80102555:	3c 2f                	cmp    $0x2f,%al
80102557:	75 19                	jne    80102572 <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
80102559:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102560:	00 
80102561:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102568:	e8 4e f4 ff ff       	call   801019bb <iget>
8010256d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102570:	eb 13                	jmp    80102585 <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
80102572:	e8 bc 1f 00 00       	call   80104533 <myproc>
80102577:	8b 40 68             	mov    0x68(%eax),%eax
8010257a:	89 04 24             	mov    %eax,(%esp)
8010257d:	e8 0e f5 ff ff       	call   80101a90 <idup>
80102582:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
80102585:	e8 a9 1f 00 00       	call   80104533 <myproc>
8010258a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
8010258d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
80102594:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80102598:	74 0c                	je     801025a6 <namex+0x5c>
    cont = p->cont;
8010259a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010259d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801025a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
801025a6:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
801025ad:	00 
801025ae:	c7 44 24 04 57 9c 10 	movl   $0x80109c57,0x4(%esp)
801025b5:	80 
801025b6:	8b 45 08             	mov    0x8(%ebp),%eax
801025b9:	89 04 24             	mov    %eax,(%esp)
801025bc:	e8 81 33 00 00       	call   80105942 <strncmp>
801025c1:	85 c0                	test   %eax,%eax
801025c3:	75 21                	jne    801025e6 <namex+0x9c>
801025c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025c9:	74 1b                	je     801025e6 <namex+0x9c>
801025cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025ce:	8b 40 38             	mov    0x38(%eax),%eax
801025d1:	8b 50 04             	mov    0x4(%eax),%edx
801025d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d7:	8b 40 04             	mov    0x4(%eax),%eax
801025da:	39 c2                	cmp    %eax,%edx
801025dc:	75 08                	jne    801025e6 <namex+0x9c>
    return ip;
801025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e1:	e9 45 01 00 00       	jmp    8010272b <namex+0x1e1>
  }
  
  while((path = skipelem(path, name)) != 0){
801025e6:	e9 06 01 00 00       	jmp    801026f1 <namex+0x1a7>
    ilock(ip);
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	89 04 24             	mov    %eax,(%esp)
801025f1:	e8 cc f4 ff ff       	call   80101ac2 <ilock>

    if(ip->type != T_DIR){
801025f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f9:	8b 40 50             	mov    0x50(%eax),%eax
801025fc:	66 83 f8 01          	cmp    $0x1,%ax
80102600:	74 15                	je     80102617 <namex+0xcd>
      iunlockput(ip);
80102602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102605:	89 04 24             	mov    %eax,(%esp)
80102608:	e8 b4 f6 ff ff       	call   80101cc1 <iunlockput>
      return 0;
8010260d:	b8 00 00 00 00       	mov    $0x0,%eax
80102612:	e9 14 01 00 00       	jmp    8010272b <namex+0x1e1>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
80102617:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
8010261e:	00 
8010261f:	c7 44 24 04 57 9c 10 	movl   $0x80109c57,0x4(%esp)
80102626:	80 
80102627:	8b 45 08             	mov    0x8(%ebp),%eax
8010262a:	89 04 24             	mov    %eax,(%esp)
8010262d:	e8 10 33 00 00       	call   80105942 <strncmp>
80102632:	85 c0                	test   %eax,%eax
80102634:	75 2c                	jne    80102662 <namex+0x118>
80102636:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010263a:	74 26                	je     80102662 <namex+0x118>
8010263c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010263f:	8b 40 38             	mov    0x38(%eax),%eax
80102642:	8b 50 04             	mov    0x4(%eax),%edx
80102645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102648:	8b 40 04             	mov    0x4(%eax),%eax
8010264b:	39 c2                	cmp    %eax,%edx
8010264d:	75 13                	jne    80102662 <namex+0x118>
      iunlock(ip);
8010264f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102652:	89 04 24             	mov    %eax,(%esp)
80102655:	e8 72 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
8010265a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265d:	e9 c9 00 00 00       	jmp    8010272b <namex+0x1e1>
    }

    if(cont != NULL && ip->inum == ROOTINO){
80102662:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102666:	74 21                	je     80102689 <namex+0x13f>
80102668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266b:	8b 40 04             	mov    0x4(%eax),%eax
8010266e:	83 f8 01             	cmp    $0x1,%eax
80102671:	75 16                	jne    80102689 <namex+0x13f>
      iunlock(ip);
80102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102676:	89 04 24             	mov    %eax,(%esp)
80102679:	e8 4e f5 ff ff       	call   80101bcc <iunlock>
      return cont->root;
8010267e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102681:	8b 40 38             	mov    0x38(%eax),%eax
80102684:	e9 a2 00 00 00       	jmp    8010272b <namex+0x1e1>
    }

    if(nameiparent && *path == '\0'){
80102689:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010268d:	74 1c                	je     801026ab <namex+0x161>
8010268f:	8b 45 08             	mov    0x8(%ebp),%eax
80102692:	8a 00                	mov    (%eax),%al
80102694:	84 c0                	test   %al,%al
80102696:	75 13                	jne    801026ab <namex+0x161>
      // Stop one level early.
      iunlock(ip);
80102698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269b:	89 04 24             	mov    %eax,(%esp)
8010269e:	e8 29 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
801026a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a6:	e9 80 00 00 00       	jmp    8010272b <namex+0x1e1>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026b2:	00 
801026b3:	8b 45 10             	mov    0x10(%ebp),%eax
801026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026bd:	89 04 24             	mov    %eax,(%esp)
801026c0:	e8 e7 fb ff ff       	call   801022ac <dirlookup>
801026c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801026c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801026cc:	75 12                	jne    801026e0 <namex+0x196>
      iunlockput(ip);
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	89 04 24             	mov    %eax,(%esp)
801026d4:	e8 e8 f5 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801026d9:	b8 00 00 00 00       	mov    $0x0,%eax
801026de:	eb 4b                	jmp    8010272b <namex+0x1e1>
    }
    iunlockput(ip);
801026e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e3:	89 04 24             	mov    %eax,(%esp)
801026e6:	e8 d6 f5 ff ff       	call   80101cc1 <iunlockput>

    ip = next;
801026eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026ee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
    return ip;
  }
  
  while((path = skipelem(path, name)) != 0){
801026f1:	8b 45 10             	mov    0x10(%ebp),%eax
801026f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801026f8:	8b 45 08             	mov    0x8(%ebp),%eax
801026fb:	89 04 24             	mov    %eax,(%esp)
801026fe:	e8 65 fd ff ff       	call   80102468 <skipelem>
80102703:	89 45 08             	mov    %eax,0x8(%ebp)
80102706:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010270a:	0f 85 db fe ff ff    	jne    801025eb <namex+0xa1>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
80102710:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102714:	74 12                	je     80102728 <namex+0x1de>
    iput(ip);
80102716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102719:	89 04 24             	mov    %eax,(%esp)
8010271c:	e8 ef f4 ff ff       	call   80101c10 <iput>
    return 0;
80102721:	b8 00 00 00 00       	mov    $0x0,%eax
80102726:	eb 03                	jmp    8010272b <namex+0x1e1>
  }

  
  return ip;
80102728:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010272b:	c9                   	leave  
8010272c:	c3                   	ret    

8010272d <namei>:

struct inode*
namei(char *path)
{
8010272d:	55                   	push   %ebp
8010272e:	89 e5                	mov    %esp,%ebp
80102730:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102733:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102736:	89 44 24 08          	mov    %eax,0x8(%esp)
8010273a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102741:	00 
80102742:	8b 45 08             	mov    0x8(%ebp),%eax
80102745:	89 04 24             	mov    %eax,(%esp)
80102748:	e8 fd fd ff ff       	call   8010254a <namex>
}
8010274d:	c9                   	leave  
8010274e:	c3                   	ret    

8010274f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010274f:	55                   	push   %ebp
80102750:	89 e5                	mov    %esp,%ebp
80102752:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102755:	8b 45 0c             	mov    0xc(%ebp),%eax
80102758:	89 44 24 08          	mov    %eax,0x8(%esp)
8010275c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102763:	00 
80102764:	8b 45 08             	mov    0x8(%ebp),%eax
80102767:	89 04 24             	mov    %eax,(%esp)
8010276a:	e8 db fd ff ff       	call   8010254a <namex>
}
8010276f:	c9                   	leave  
80102770:	c3                   	ret    
80102771:	00 00                	add    %al,(%eax)
	...

80102774 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102774:	55                   	push   %ebp
80102775:	89 e5                	mov    %esp,%ebp
80102777:	83 ec 14             	sub    $0x14,%esp
8010277a:	8b 45 08             	mov    0x8(%ebp),%eax
8010277d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102781:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102784:	89 c2                	mov    %eax,%edx
80102786:	ec                   	in     (%dx),%al
80102787:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010278a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010278d:	c9                   	leave  
8010278e:	c3                   	ret    

8010278f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010278f:	55                   	push   %ebp
80102790:	89 e5                	mov    %esp,%ebp
80102792:	57                   	push   %edi
80102793:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102794:	8b 55 08             	mov    0x8(%ebp),%edx
80102797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010279a:	8b 45 10             	mov    0x10(%ebp),%eax
8010279d:	89 cb                	mov    %ecx,%ebx
8010279f:	89 df                	mov    %ebx,%edi
801027a1:	89 c1                	mov    %eax,%ecx
801027a3:	fc                   	cld    
801027a4:	f3 6d                	rep insl (%dx),%es:(%edi)
801027a6:	89 c8                	mov    %ecx,%eax
801027a8:	89 fb                	mov    %edi,%ebx
801027aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ad:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027b0:	5b                   	pop    %ebx
801027b1:	5f                   	pop    %edi
801027b2:	5d                   	pop    %ebp
801027b3:	c3                   	ret    

801027b4 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027b4:	55                   	push   %ebp
801027b5:	89 e5                	mov    %esp,%ebp
801027b7:	83 ec 08             	sub    $0x8,%esp
801027ba:	8b 45 08             	mov    0x8(%ebp),%eax
801027bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801027c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801027c4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027c7:	8a 45 f8             	mov    -0x8(%ebp),%al
801027ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
801027cd:	ee                   	out    %al,(%dx)
}
801027ce:	c9                   	leave  
801027cf:	c3                   	ret    

801027d0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027d0:	55                   	push   %ebp
801027d1:	89 e5                	mov    %esp,%ebp
801027d3:	56                   	push   %esi
801027d4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027d5:	8b 55 08             	mov    0x8(%ebp),%edx
801027d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027db:	8b 45 10             	mov    0x10(%ebp),%eax
801027de:	89 cb                	mov    %ecx,%ebx
801027e0:	89 de                	mov    %ebx,%esi
801027e2:	89 c1                	mov    %eax,%ecx
801027e4:	fc                   	cld    
801027e5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027e7:	89 c8                	mov    %ecx,%eax
801027e9:	89 f3                	mov    %esi,%ebx
801027eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ee:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027f1:	5b                   	pop    %ebx
801027f2:	5e                   	pop    %esi
801027f3:	5d                   	pop    %ebp
801027f4:	c3                   	ret    

801027f5 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027fb:	90                   	nop
801027fc:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102803:	e8 6c ff ff ff       	call   80102774 <inb>
80102808:	0f b6 c0             	movzbl %al,%eax
8010280b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010280e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102811:	25 c0 00 00 00       	and    $0xc0,%eax
80102816:	83 f8 40             	cmp    $0x40,%eax
80102819:	75 e1                	jne    801027fc <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010281b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010281f:	74 11                	je     80102832 <idewait+0x3d>
80102821:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102824:	83 e0 21             	and    $0x21,%eax
80102827:	85 c0                	test   %eax,%eax
80102829:	74 07                	je     80102832 <idewait+0x3d>
    return -1;
8010282b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102830:	eb 05                	jmp    80102837 <idewait+0x42>
  return 0;
80102832:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102837:	c9                   	leave  
80102838:	c3                   	ret    

80102839 <ideinit>:

void
ideinit(void)
{
80102839:	55                   	push   %ebp
8010283a:	89 e5                	mov    %esp,%ebp
8010283c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010283f:	c7 44 24 04 5a 9c 10 	movl   $0x80109c5a,0x4(%esp)
80102846:	80 
80102847:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
8010284e:	e8 03 2d 00 00       	call   80105556 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102853:	a1 40 62 11 80       	mov    0x80116240,%eax
80102858:	48                   	dec    %eax
80102859:	89 44 24 04          	mov    %eax,0x4(%esp)
8010285d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102864:	e8 66 04 00 00       	call   80102ccf <ioapicenable>
  idewait(0);
80102869:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102870:	e8 80 ff ff ff       	call   801027f5 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102875:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010287c:	00 
8010287d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102884:	e8 2b ff ff ff       	call   801027b4 <outb>
  for(i=0; i<1000; i++){
80102889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102890:	eb 1f                	jmp    801028b1 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102892:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102899:	e8 d6 fe ff ff       	call   80102774 <inb>
8010289e:	84 c0                	test   %al,%al
801028a0:	74 0c                	je     801028ae <ideinit+0x75>
      havedisk1 = 1;
801028a2:	c7 05 18 d9 10 80 01 	movl   $0x1,0x8010d918
801028a9:	00 00 00 
      break;
801028ac:	eb 0c                	jmp    801028ba <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028ae:	ff 45 f4             	incl   -0xc(%ebp)
801028b1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028b8:	7e d8                	jle    80102892 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028ba:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028c1:	00 
801028c2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028c9:	e8 e6 fe ff ff       	call   801027b4 <outb>
}
801028ce:	c9                   	leave  
801028cf:	c3                   	ret    

801028d0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028d0:	55                   	push   %ebp
801028d1:	89 e5                	mov    %esp,%ebp
801028d3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801028d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028da:	75 0c                	jne    801028e8 <idestart+0x18>
    panic("idestart");
801028dc:	c7 04 24 5e 9c 10 80 	movl   $0x80109c5e,(%esp)
801028e3:	e8 6c dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801028e8:	8b 45 08             	mov    0x8(%ebp),%eax
801028eb:	8b 40 08             	mov    0x8(%eax),%eax
801028ee:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
801028f3:	76 0c                	jbe    80102901 <idestart+0x31>
    panic("incorrect blockno");
801028f5:	c7 04 24 67 9c 10 80 	movl   $0x80109c67,(%esp)
801028fc:	e8 53 dc ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102901:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102908:	8b 45 08             	mov    0x8(%ebp),%eax
8010290b:	8b 50 08             	mov    0x8(%eax),%edx
8010290e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102911:	0f af c2             	imul   %edx,%eax
80102914:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102917:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010291b:	75 07                	jne    80102924 <idestart+0x54>
8010291d:	b8 20 00 00 00       	mov    $0x20,%eax
80102922:	eb 05                	jmp    80102929 <idestart+0x59>
80102924:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010292c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102930:	75 07                	jne    80102939 <idestart+0x69>
80102932:	b8 30 00 00 00       	mov    $0x30,%eax
80102937:	eb 05                	jmp    8010293e <idestart+0x6e>
80102939:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010293e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102941:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102945:	7e 0c                	jle    80102953 <idestart+0x83>
80102947:	c7 04 24 5e 9c 10 80 	movl   $0x80109c5e,(%esp)
8010294e:	e8 01 dc ff ff       	call   80100554 <panic>

  idewait(0);
80102953:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010295a:	e8 96 fe ff ff       	call   801027f5 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010295f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102966:	00 
80102967:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010296e:	e8 41 fe ff ff       	call   801027b4 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102976:	0f b6 c0             	movzbl %al,%eax
80102979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010297d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102984:	e8 2b fe ff ff       	call   801027b4 <outb>
  outb(0x1f3, sector & 0xff);
80102989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010298c:	0f b6 c0             	movzbl %al,%eax
8010298f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102993:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010299a:	e8 15 fe ff ff       	call   801027b4 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010299f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029a2:	c1 f8 08             	sar    $0x8,%eax
801029a5:	0f b6 c0             	movzbl %al,%eax
801029a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ac:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b3:	e8 fc fd ff ff       	call   801027b4 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801029b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029bb:	c1 f8 10             	sar    $0x10,%eax
801029be:	0f b6 c0             	movzbl %al,%eax
801029c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029cc:	e8 e3 fd ff ff       	call   801027b4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801029d1:	8b 45 08             	mov    0x8(%ebp),%eax
801029d4:	8b 40 04             	mov    0x4(%eax),%eax
801029d7:	83 e0 01             	and    $0x1,%eax
801029da:	c1 e0 04             	shl    $0x4,%eax
801029dd:	88 c2                	mov    %al,%dl
801029df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029e2:	c1 f8 18             	sar    $0x18,%eax
801029e5:	83 e0 0f             	and    $0xf,%eax
801029e8:	09 d0                	or     %edx,%eax
801029ea:	83 c8 e0             	or     $0xffffffe0,%eax
801029ed:	0f b6 c0             	movzbl %al,%eax
801029f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029fb:	e8 b4 fd ff ff       	call   801027b4 <outb>
  if(b->flags & B_DIRTY){
80102a00:	8b 45 08             	mov    0x8(%ebp),%eax
80102a03:	8b 00                	mov    (%eax),%eax
80102a05:	83 e0 04             	and    $0x4,%eax
80102a08:	85 c0                	test   %eax,%eax
80102a0a:	74 36                	je     80102a42 <idestart+0x172>
    outb(0x1f7, write_cmd);
80102a0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a0f:	0f b6 c0             	movzbl %al,%eax
80102a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a16:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a1d:	e8 92 fd ff ff       	call   801027b4 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	83 c0 5c             	add    $0x5c,%eax
80102a28:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a2f:	00 
80102a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a34:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3b:	e8 90 fd ff ff       	call   801027d0 <outsl>
80102a40:	eb 16                	jmp    80102a58 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a45:	0f b6 c0             	movzbl %al,%eax
80102a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a4c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a53:	e8 5c fd ff ff       	call   801027b4 <outb>
  }
}
80102a58:	c9                   	leave  
80102a59:	c3                   	ret    

80102a5a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a5a:	55                   	push   %ebp
80102a5b:	89 e5                	mov    %esp,%ebp
80102a5d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a60:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102a67:	e8 0b 2b 00 00       	call   80105577 <acquire>

  if((b = idequeue) == 0){
80102a6c:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a78:	75 11                	jne    80102a8b <ideintr+0x31>
    release(&idelock);
80102a7a:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102a81:	e8 5b 2b 00 00       	call   801055e1 <release>
    return;
80102a86:	e9 90 00 00 00       	jmp    80102b1b <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8e:	8b 40 58             	mov    0x58(%eax),%eax
80102a91:	a3 14 d9 10 80       	mov    %eax,0x8010d914

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a99:	8b 00                	mov    (%eax),%eax
80102a9b:	83 e0 04             	and    $0x4,%eax
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	75 2e                	jne    80102ad0 <ideintr+0x76>
80102aa2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa9:	e8 47 fd ff ff       	call   801027f5 <idewait>
80102aae:	85 c0                	test   %eax,%eax
80102ab0:	78 1e                	js     80102ad0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	83 c0 5c             	add    $0x5c,%eax
80102ab8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102abf:	00 
80102ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102acb:	e8 bf fc ff ff       	call   8010278f <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad3:	8b 00                	mov    (%eax),%eax
80102ad5:	83 c8 02             	or     $0x2,%eax
80102ad8:	89 c2                	mov    %eax,%edx
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	8b 00                	mov    (%eax),%eax
80102ae4:	83 e0 fb             	and    $0xfffffffb,%eax
80102ae7:	89 c2                	mov    %eax,%edx
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af1:	89 04 24             	mov    %eax,(%esp)
80102af4:	e8 69 24 00 00       	call   80104f62 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102af9:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102afe:	85 c0                	test   %eax,%eax
80102b00:	74 0d                	je     80102b0f <ideintr+0xb5>
    idestart(idequeue);
80102b02:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b07:	89 04 24             	mov    %eax,(%esp)
80102b0a:	e8 c1 fd ff ff       	call   801028d0 <idestart>

  release(&idelock);
80102b0f:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102b16:	e8 c6 2a 00 00       	call   801055e1 <release>
}
80102b1b:	c9                   	leave  
80102b1c:	c3                   	ret    

80102b1d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
80102b20:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b23:	8b 45 08             	mov    0x8(%ebp),%eax
80102b26:	83 c0 0c             	add    $0xc,%eax
80102b29:	89 04 24             	mov    %eax,(%esp)
80102b2c:	e8 be 29 00 00       	call   801054ef <holdingsleep>
80102b31:	85 c0                	test   %eax,%eax
80102b33:	75 0c                	jne    80102b41 <iderw+0x24>
    panic("iderw: buf not locked");
80102b35:	c7 04 24 79 9c 10 80 	movl   $0x80109c79,(%esp)
80102b3c:	e8 13 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b41:	8b 45 08             	mov    0x8(%ebp),%eax
80102b44:	8b 00                	mov    (%eax),%eax
80102b46:	83 e0 06             	and    $0x6,%eax
80102b49:	83 f8 02             	cmp    $0x2,%eax
80102b4c:	75 0c                	jne    80102b5a <iderw+0x3d>
    panic("iderw: nothing to do");
80102b4e:	c7 04 24 8f 9c 10 80 	movl   $0x80109c8f,(%esp)
80102b55:	e8 fa d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5d:	8b 40 04             	mov    0x4(%eax),%eax
80102b60:	85 c0                	test   %eax,%eax
80102b62:	74 15                	je     80102b79 <iderw+0x5c>
80102b64:	a1 18 d9 10 80       	mov    0x8010d918,%eax
80102b69:	85 c0                	test   %eax,%eax
80102b6b:	75 0c                	jne    80102b79 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102b6d:	c7 04 24 a4 9c 10 80 	movl   $0x80109ca4,(%esp)
80102b74:	e8 db d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b79:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102b80:	e8 f2 29 00 00       	call   80105577 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b85:	8b 45 08             	mov    0x8(%ebp),%eax
80102b88:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b8f:	c7 45 f4 14 d9 10 80 	movl   $0x8010d914,-0xc(%ebp)
80102b96:	eb 0b                	jmp    80102ba3 <iderw+0x86>
80102b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9b:	8b 00                	mov    (%eax),%eax
80102b9d:	83 c0 58             	add    $0x58,%eax
80102ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba6:	8b 00                	mov    (%eax),%eax
80102ba8:	85 c0                	test   %eax,%eax
80102baa:	75 ec                	jne    80102b98 <iderw+0x7b>
    ;
  *pp = b;
80102bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102baf:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102bb4:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102bb9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bbc:	75 0d                	jne    80102bcb <iderw+0xae>
    idestart(b);
80102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc1:	89 04 24             	mov    %eax,(%esp)
80102bc4:	e8 07 fd ff ff       	call   801028d0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc9:	eb 15                	jmp    80102be0 <iderw+0xc3>
80102bcb:	eb 13                	jmp    80102be0 <iderw+0xc3>
    sleep(b, &idelock);
80102bcd:	c7 44 24 04 e0 d8 10 	movl   $0x8010d8e0,0x4(%esp)
80102bd4:	80 
80102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd8:	89 04 24             	mov    %eax,(%esp)
80102bdb:	e8 ab 22 00 00       	call   80104e8b <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102be0:	8b 45 08             	mov    0x8(%ebp),%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	83 e0 06             	and    $0x6,%eax
80102be8:	83 f8 02             	cmp    $0x2,%eax
80102beb:	75 e0                	jne    80102bcd <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102bed:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102bf4:	e8 e8 29 00 00       	call   801055e1 <release>
}
80102bf9:	c9                   	leave  
80102bfa:	c3                   	ret    
	...

80102bfc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bff:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c04:	8b 55 08             	mov    0x8(%ebp),%edx
80102c07:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c09:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c0e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c11:	5d                   	pop    %ebp
80102c12:	c3                   	ret    

80102c13 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c13:	55                   	push   %ebp
80102c14:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c16:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c1b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c20:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c25:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c28:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c2b:	5d                   	pop    %ebp
80102c2c:	c3                   	ret    

80102c2d <ioapicinit>:

void
ioapicinit(void)
{
80102c2d:	55                   	push   %ebp
80102c2e:	89 e5                	mov    %esp,%ebp
80102c30:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c33:	c7 05 54 5b 11 80 00 	movl   $0xfec00000,0x80115b54
80102c3a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c44:	e8 b3 ff ff ff       	call   80102bfc <ioapicread>
80102c49:	c1 e8 10             	shr    $0x10,%eax
80102c4c:	25 ff 00 00 00       	and    $0xff,%eax
80102c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c5b:	e8 9c ff ff ff       	call   80102bfc <ioapicread>
80102c60:	c1 e8 18             	shr    $0x18,%eax
80102c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c66:	a0 a0 5c 11 80       	mov    0x80115ca0,%al
80102c6b:	0f b6 c0             	movzbl %al,%eax
80102c6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c71:	74 0c                	je     80102c7f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c73:	c7 04 24 c4 9c 10 80 	movl   $0x80109cc4,(%esp)
80102c7a:	e8 42 d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c86:	eb 3d                	jmp    80102cc5 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8b:	83 c0 20             	add    $0x20,%eax
80102c8e:	0d 00 00 01 00       	or     $0x10000,%eax
80102c93:	89 c2                	mov    %eax,%edx
80102c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c98:	83 c0 08             	add    $0x8,%eax
80102c9b:	01 c0                	add    %eax,%eax
80102c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ca1:	89 04 24             	mov    %eax,(%esp)
80102ca4:	e8 6a ff ff ff       	call   80102c13 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cac:	83 c0 08             	add    $0x8,%eax
80102caf:	01 c0                	add    %eax,%eax
80102cb1:	40                   	inc    %eax
80102cb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb9:	00 
80102cba:	89 04 24             	mov    %eax,(%esp)
80102cbd:	e8 51 ff ff ff       	call   80102c13 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cc2:	ff 45 f4             	incl   -0xc(%ebp)
80102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ccb:	7e bb                	jle    80102c88 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ccd:	c9                   	leave  
80102cce:	c3                   	ret    

80102ccf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ccf:	55                   	push   %ebp
80102cd0:	89 e5                	mov    %esp,%ebp
80102cd2:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd8:	83 c0 20             	add    $0x20,%eax
80102cdb:	89 c2                	mov    %eax,%edx
80102cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce0:	83 c0 08             	add    $0x8,%eax
80102ce3:	01 c0                	add    %eax,%eax
80102ce5:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ce9:	89 04 24             	mov    %eax,(%esp)
80102cec:	e8 22 ff ff ff       	call   80102c13 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf4:	c1 e0 18             	shl    $0x18,%eax
80102cf7:	8b 55 08             	mov    0x8(%ebp),%edx
80102cfa:	83 c2 08             	add    $0x8,%edx
80102cfd:	01 d2                	add    %edx,%edx
80102cff:	42                   	inc    %edx
80102d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d04:	89 14 24             	mov    %edx,(%esp)
80102d07:	e8 07 ff ff ff       	call   80102c13 <ioapicwrite>
}
80102d0c:	c9                   	leave  
80102d0d:	c3                   	ret    
	...

80102d10 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d10:	55                   	push   %ebp
80102d11:	89 e5                	mov    %esp,%ebp
80102d13:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d16:	c7 44 24 04 f6 9c 10 	movl   $0x80109cf6,0x4(%esp)
80102d1d:	80 
80102d1e:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102d25:	e8 2c 28 00 00       	call   80105556 <initlock>
  kmem.use_lock = 0;
80102d2a:	c7 05 94 5b 11 80 00 	movl   $0x0,0x80115b94
80102d31:	00 00 00 
  freerange(vstart, vend);
80102d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3e:	89 04 24             	mov    %eax,(%esp)
80102d41:	e8 30 00 00 00       	call   80102d76 <freerange>
}
80102d46:	c9                   	leave  
80102d47:	c3                   	ret    

80102d48 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d48:	55                   	push   %ebp
80102d49:	89 e5                	mov    %esp,%ebp
80102d4b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d51:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	89 04 24             	mov    %eax,(%esp)
80102d5b:	e8 16 00 00 00       	call   80102d76 <freerange>
  kmem.use_lock = 1;
80102d60:	c7 05 94 5b 11 80 01 	movl   $0x1,0x80115b94
80102d67:	00 00 00 
  kmem.i = 0;
80102d6a:	c7 05 9c 5b 11 80 00 	movl   $0x0,0x80115b9c
80102d71:	00 00 00 
}
80102d74:	c9                   	leave  
80102d75:	c3                   	ret    

80102d76 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d76:	55                   	push   %ebp
80102d77:	89 e5                	mov    %esp,%ebp
80102d79:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d8c:	eb 12                	jmp    80102da0 <freerange+0x2a>
    kfree(p);
80102d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d91:	89 04 24             	mov    %eax,(%esp)
80102d94:	e8 16 00 00 00       	call   80102daf <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d99:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da3:	05 00 10 00 00       	add    $0x1000,%eax
80102da8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dab:	76 e1                	jbe    80102d8e <freerange+0x18>
    kfree(p);
}
80102dad:	c9                   	leave  
80102dae:	c3                   	ret    

80102daf <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102daf:	55                   	push   %ebp
80102db0:	89 e5                	mov    %esp,%ebp
80102db2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102db5:	8b 45 08             	mov    0x8(%ebp),%eax
80102db8:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dbd:	85 c0                	test   %eax,%eax
80102dbf:	75 18                	jne    80102dd9 <kfree+0x2a>
80102dc1:	81 7d 08 f0 8d 11 80 	cmpl   $0x80118df0,0x8(%ebp)
80102dc8:	72 0f                	jb     80102dd9 <kfree+0x2a>
80102dca:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcd:	05 00 00 00 80       	add    $0x80000000,%eax
80102dd2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dd7:	76 0c                	jbe    80102de5 <kfree+0x36>
    panic("kfree");
80102dd9:	c7 04 24 fb 9c 10 80 	movl   $0x80109cfb,(%esp)
80102de0:	e8 6f d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102de5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dec:	00 
80102ded:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102df4:	00 
80102df5:	8b 45 08             	mov    0x8(%ebp),%eax
80102df8:	89 04 24             	mov    %eax,(%esp)
80102dfb:	e8 da 29 00 00       	call   801057da <memset>

  if(kmem.use_lock){
80102e00:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e05:	85 c0                	test   %eax,%eax
80102e07:	74 5a                	je     80102e63 <kfree+0xb4>
    acquire(&kmem.lock);
80102e09:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e10:	e8 62 27 00 00       	call   80105577 <acquire>
    if(ticks > 1){
80102e15:	a1 e0 8c 11 80       	mov    0x80118ce0,%eax
80102e1a:	83 f8 01             	cmp    $0x1,%eax
80102e1d:	76 44                	jbe    80102e63 <kfree+0xb4>
      int x = find(myproc()->cont->name);
80102e1f:	e8 0f 17 00 00       	call   80104533 <myproc>
80102e24:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102e2a:	83 c0 18             	add    $0x18,%eax
80102e2d:	89 04 24             	mov    %eax,(%esp)
80102e30:	e8 16 65 00 00       	call   8010934b <find>
80102e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102e38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e3c:	78 25                	js     80102e63 <kfree+0xb4>
        reduce_curr_mem(1, x);
80102e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e4c:	e8 4d 68 00 00       	call   8010969e <reduce_curr_mem>
        myproc()->usage--;
80102e51:	e8 dd 16 00 00       	call   80104533 <myproc>
80102e56:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102e5c:	4a                   	dec    %edx
80102e5d:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      }
    }
  }
  r = (struct run*)v;
80102e63:	8b 45 08             	mov    0x8(%ebp),%eax
80102e66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102e69:	8b 15 98 5b 11 80    	mov    0x80115b98,%edx
80102e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e72:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e77:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  kmem.i--;
80102e7c:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80102e81:	48                   	dec    %eax
80102e82:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  if(kmem.use_lock)
80102e87:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e8c:	85 c0                	test   %eax,%eax
80102e8e:	74 0c                	je     80102e9c <kfree+0xed>
    release(&kmem.lock);
80102e90:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e97:	e8 45 27 00 00       	call   801055e1 <release>
}
80102e9c:	c9                   	leave  
80102e9d:	c3                   	ret    

80102e9e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e9e:	55                   	push   %ebp
80102e9f:	89 e5                	mov    %esp,%ebp
80102ea1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102ea4:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102ea9:	85 c0                	test   %eax,%eax
80102eab:	74 0c                	je     80102eb9 <kalloc+0x1b>
    acquire(&kmem.lock);
80102ead:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102eb4:	e8 be 26 00 00       	call   80105577 <acquire>
  }
  r = kmem.freelist;
80102eb9:	a1 98 5b 11 80       	mov    0x80115b98,%eax
80102ebe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ec1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ec5:	74 0a                	je     80102ed1 <kalloc+0x33>
    kmem.freelist = r->next;
80102ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eca:	8b 00                	mov    (%eax),%eax
80102ecc:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  kmem.i++;
80102ed1:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80102ed6:	40                   	inc    %eax
80102ed7:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  if((char*)r != 0){
80102edc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ee0:	0f 84 84 00 00 00    	je     80102f6a <kalloc+0xcc>
    if(ticks > 0){
80102ee6:	a1 e0 8c 11 80       	mov    0x80118ce0,%eax
80102eeb:	85 c0                	test   %eax,%eax
80102eed:	74 7b                	je     80102f6a <kalloc+0xcc>
      int x = find(myproc()->cont->name);
80102eef:	e8 3f 16 00 00       	call   80104533 <myproc>
80102ef4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102efa:	83 c0 18             	add    $0x18,%eax
80102efd:	89 04 24             	mov    %eax,(%esp)
80102f00:	e8 46 64 00 00       	call   8010934b <find>
80102f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102f08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102f0c:	78 5c                	js     80102f6a <kalloc+0xcc>
        myproc()->usage++;
80102f0e:	e8 20 16 00 00       	call   80104533 <myproc>
80102f13:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102f19:	42                   	inc    %edx
80102f1a:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        int before = get_curr_mem(x);
80102f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f23:	89 04 24             	mov    %eax,(%esp)
80102f26:	e8 b8 65 00 00       	call   801094e3 <get_curr_mem>
80102f2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f31:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102f3c:	e8 ca 66 00 00       	call   8010960b <set_curr_mem>
        int after = get_curr_mem(x);
80102f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f44:	89 04 24             	mov    %eax,(%esp)
80102f47:	e8 97 65 00 00       	call   801094e3 <get_curr_mem>
80102f4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f52:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102f55:	75 13                	jne    80102f6a <kalloc+0xcc>
          cstop_container_helper(myproc()->cont);
80102f57:	e8 d7 15 00 00       	call   80104533 <myproc>
80102f5c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f62:	89 04 24             	mov    %eax,(%esp)
80102f65:	e8 f6 21 00 00       	call   80105160 <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
80102f6a:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102f6f:	85 c0                	test   %eax,%eax
80102f71:	74 0c                	je     80102f7f <kalloc+0xe1>
    release(&kmem.lock);
80102f73:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102f7a:	e8 62 26 00 00       	call   801055e1 <release>
  return (char*)r;
80102f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102f82:	c9                   	leave  
80102f83:	c3                   	ret    

80102f84 <mem_usage>:

int mem_usage(void){
80102f84:	55                   	push   %ebp
80102f85:	89 e5                	mov    %esp,%ebp
  return kmem.i;
80102f87:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
}
80102f8c:	5d                   	pop    %ebp
80102f8d:	c3                   	ret    

80102f8e <mem_avail>:

int mem_avail(void){
80102f8e:	55                   	push   %ebp
80102f8f:	89 e5                	mov    %esp,%ebp
80102f91:	83 ec 10             	sub    $0x10,%esp
  int freebytes = ((P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024)))/4096;
80102f94:	b8 f0 8d 11 80       	mov    $0x80118df0,%eax
80102f99:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
80102f9e:	29 c2                	sub    %eax,%edx
80102fa0:	89 d0                	mov    %edx,%eax
80102fa2:	85 c0                	test   %eax,%eax
80102fa4:	79 05                	jns    80102fab <mem_avail+0x1d>
80102fa6:	05 ff 0f 00 00       	add    $0xfff,%eax
80102fab:	c1 f8 0c             	sar    $0xc,%eax
80102fae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return freebytes;
80102fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102fb4:	c9                   	leave  
80102fb5:	c3                   	ret    
	...

80102fb8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102fb8:	55                   	push   %ebp
80102fb9:	89 e5                	mov    %esp,%ebp
80102fbb:	83 ec 14             	sub    $0x14,%esp
80102fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102fc1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fc8:	89 c2                	mov    %eax,%edx
80102fca:	ec                   	in     (%dx),%al
80102fcb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102fce:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102fd1:	c9                   	leave  
80102fd2:	c3                   	ret    

80102fd3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102fd3:	55                   	push   %ebp
80102fd4:	89 e5                	mov    %esp,%ebp
80102fd6:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102fd9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fe0:	e8 d3 ff ff ff       	call   80102fb8 <inb>
80102fe5:	0f b6 c0             	movzbl %al,%eax
80102fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fee:	83 e0 01             	and    $0x1,%eax
80102ff1:	85 c0                	test   %eax,%eax
80102ff3:	75 0a                	jne    80102fff <kbdgetc+0x2c>
    return -1;
80102ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ffa:	e9 21 01 00 00       	jmp    80103120 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102fff:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80103006:	e8 ad ff ff ff       	call   80102fb8 <inb>
8010300b:	0f b6 c0             	movzbl %al,%eax
8010300e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103011:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103018:	75 17                	jne    80103031 <kbdgetc+0x5e>
    shift |= E0ESC;
8010301a:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010301f:	83 c8 40             	or     $0x40,%eax
80103022:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
80103027:	b8 00 00 00 00       	mov    $0x0,%eax
8010302c:	e9 ef 00 00 00       	jmp    80103120 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103031:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103034:	25 80 00 00 00       	and    $0x80,%eax
80103039:	85 c0                	test   %eax,%eax
8010303b:	74 44                	je     80103081 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010303d:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103042:	83 e0 40             	and    $0x40,%eax
80103045:	85 c0                	test   %eax,%eax
80103047:	75 08                	jne    80103051 <kbdgetc+0x7e>
80103049:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010304c:	83 e0 7f             	and    $0x7f,%eax
8010304f:	eb 03                	jmp    80103054 <kbdgetc+0x81>
80103051:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103054:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103057:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010305a:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010305f:	8a 00                	mov    (%eax),%al
80103061:	83 c8 40             	or     $0x40,%eax
80103064:	0f b6 c0             	movzbl %al,%eax
80103067:	f7 d0                	not    %eax
80103069:	89 c2                	mov    %eax,%edx
8010306b:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103070:	21 d0                	and    %edx,%eax
80103072:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
80103077:	b8 00 00 00 00       	mov    $0x0,%eax
8010307c:	e9 9f 00 00 00       	jmp    80103120 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103081:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103086:	83 e0 40             	and    $0x40,%eax
80103089:	85 c0                	test   %eax,%eax
8010308b:	74 14                	je     801030a1 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010308d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103094:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103099:	83 e0 bf             	and    $0xffffffbf,%eax
8010309c:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  }

  shift |= shiftcode[data];
801030a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030a4:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030a9:	8a 00                	mov    (%eax),%al
801030ab:	0f b6 d0             	movzbl %al,%edx
801030ae:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030b3:	09 d0                	or     %edx,%eax
801030b5:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  shift ^= togglecode[data];
801030ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030bd:	05 20 b1 10 80       	add    $0x8010b120,%eax
801030c2:	8a 00                	mov    (%eax),%al
801030c4:	0f b6 d0             	movzbl %al,%edx
801030c7:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030cc:	31 d0                	xor    %edx,%eax
801030ce:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  c = charcode[shift & (CTL | SHIFT)][data];
801030d3:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030d8:	83 e0 03             	and    $0x3,%eax
801030db:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
801030e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030e5:	01 d0                	add    %edx,%eax
801030e7:	8a 00                	mov    (%eax),%al
801030e9:	0f b6 c0             	movzbl %al,%eax
801030ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801030ef:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030f4:	83 e0 08             	and    $0x8,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 22                	je     8010311d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801030fb:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801030ff:	76 0c                	jbe    8010310d <kbdgetc+0x13a>
80103101:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103105:	77 06                	ja     8010310d <kbdgetc+0x13a>
      c += 'A' - 'a';
80103107:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010310b:	eb 10                	jmp    8010311d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010310d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103111:	76 0a                	jbe    8010311d <kbdgetc+0x14a>
80103113:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103117:	77 04                	ja     8010311d <kbdgetc+0x14a>
      c += 'a' - 'A';
80103119:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010311d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103120:	c9                   	leave  
80103121:	c3                   	ret    

80103122 <kbdintr>:

void
kbdintr(void)
{
80103122:	55                   	push   %ebp
80103123:	89 e5                	mov    %esp,%ebp
80103125:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103128:	c7 04 24 d3 2f 10 80 	movl   $0x80102fd3,(%esp)
8010312f:	e8 c1 d6 ff ff       	call   801007f5 <consoleintr>
}
80103134:	c9                   	leave  
80103135:	c3                   	ret    
	...

80103138 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103138:	55                   	push   %ebp
80103139:	89 e5                	mov    %esp,%ebp
8010313b:	83 ec 14             	sub    $0x14,%esp
8010313e:	8b 45 08             	mov    0x8(%ebp),%eax
80103141:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103145:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103148:	89 c2                	mov    %eax,%edx
8010314a:	ec                   	in     (%dx),%al
8010314b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010314e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103151:	c9                   	leave  
80103152:	c3                   	ret    

80103153 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103153:	55                   	push   %ebp
80103154:	89 e5                	mov    %esp,%ebp
80103156:	83 ec 08             	sub    $0x8,%esp
80103159:	8b 45 08             	mov    0x8(%ebp),%eax
8010315c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010315f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103163:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103166:	8a 45 f8             	mov    -0x8(%ebp),%al
80103169:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010316c:	ee                   	out    %al,(%dx)
}
8010316d:	c9                   	leave  
8010316e:	c3                   	ret    

8010316f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010316f:	55                   	push   %ebp
80103170:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103172:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103177:	8b 55 08             	mov    0x8(%ebp),%edx
8010317a:	c1 e2 02             	shl    $0x2,%edx
8010317d:	01 c2                	add    %eax,%edx
8010317f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103182:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103184:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103189:	83 c0 20             	add    $0x20,%eax
8010318c:	8b 00                	mov    (%eax),%eax
}
8010318e:	5d                   	pop    %ebp
8010318f:	c3                   	ret    

80103190 <lapicinit>:

void
lapicinit(void)
{
80103190:	55                   	push   %ebp
80103191:	89 e5                	mov    %esp,%ebp
80103193:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80103196:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
8010319b:	85 c0                	test   %eax,%eax
8010319d:	75 05                	jne    801031a4 <lapicinit+0x14>
    return;
8010319f:	e9 43 01 00 00       	jmp    801032e7 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801031a4:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801031ab:	00 
801031ac:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801031b3:	e8 b7 ff ff ff       	call   8010316f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801031b8:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801031bf:	00 
801031c0:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801031c7:	e8 a3 ff ff ff       	call   8010316f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801031cc:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801031d3:	00 
801031d4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031db:	e8 8f ff ff ff       	call   8010316f <lapicw>
  lapicw(TICR, 10000000);
801031e0:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801031e7:	00 
801031e8:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801031ef:	e8 7b ff ff ff       	call   8010316f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801031f4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801031fb:	00 
801031fc:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103203:	e8 67 ff ff ff       	call   8010316f <lapicw>
  lapicw(LINT1, MASKED);
80103208:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010320f:	00 
80103210:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103217:	e8 53 ff ff ff       	call   8010316f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010321c:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103221:	83 c0 30             	add    $0x30,%eax
80103224:	8b 00                	mov    (%eax),%eax
80103226:	c1 e8 10             	shr    $0x10,%eax
80103229:	0f b6 c0             	movzbl %al,%eax
8010322c:	83 f8 03             	cmp    $0x3,%eax
8010322f:	76 14                	jbe    80103245 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103231:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103238:	00 
80103239:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103240:	e8 2a ff ff ff       	call   8010316f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103245:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010324c:	00 
8010324d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103254:	e8 16 ff ff ff       	call   8010316f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103260:	00 
80103261:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103268:	e8 02 ff ff ff       	call   8010316f <lapicw>
  lapicw(ESR, 0);
8010326d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103274:	00 
80103275:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010327c:	e8 ee fe ff ff       	call   8010316f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103288:	00 
80103289:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103290:	e8 da fe ff ff       	call   8010316f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103295:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010329c:	00 
8010329d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032a4:	e8 c6 fe ff ff       	call   8010316f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801032a9:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801032b0:	00 
801032b1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032b8:	e8 b2 fe ff ff       	call   8010316f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801032bd:	90                   	nop
801032be:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
801032c3:	05 00 03 00 00       	add    $0x300,%eax
801032c8:	8b 00                	mov    (%eax),%eax
801032ca:	25 00 10 00 00       	and    $0x1000,%eax
801032cf:	85 c0                	test   %eax,%eax
801032d1:	75 eb                	jne    801032be <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801032d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032da:	00 
801032db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801032e2:	e8 88 fe ff ff       	call   8010316f <lapicw>
}
801032e7:	c9                   	leave  
801032e8:	c3                   	ret    

801032e9 <lapicid>:

int
lapicid(void)
{
801032e9:	55                   	push   %ebp
801032ea:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801032ec:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
801032f1:	85 c0                	test   %eax,%eax
801032f3:	75 07                	jne    801032fc <lapicid+0x13>
    return 0;
801032f5:	b8 00 00 00 00       	mov    $0x0,%eax
801032fa:	eb 0d                	jmp    80103309 <lapicid+0x20>
  return lapic[ID] >> 24;
801032fc:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103301:	83 c0 20             	add    $0x20,%eax
80103304:	8b 00                	mov    (%eax),%eax
80103306:	c1 e8 18             	shr    $0x18,%eax
}
80103309:	5d                   	pop    %ebp
8010330a:	c3                   	ret    

8010330b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010330b:	55                   	push   %ebp
8010330c:	89 e5                	mov    %esp,%ebp
8010330e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103311:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103316:	85 c0                	test   %eax,%eax
80103318:	74 14                	je     8010332e <lapiceoi+0x23>
    lapicw(EOI, 0);
8010331a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103321:	00 
80103322:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103329:	e8 41 fe ff ff       	call   8010316f <lapicw>
}
8010332e:	c9                   	leave  
8010332f:	c3                   	ret    

80103330 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103330:	55                   	push   %ebp
80103331:	89 e5                	mov    %esp,%ebp
}
80103333:	5d                   	pop    %ebp
80103334:	c3                   	ret    

80103335 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103335:	55                   	push   %ebp
80103336:	89 e5                	mov    %esp,%ebp
80103338:	83 ec 1c             	sub    $0x1c,%esp
8010333b:	8b 45 08             	mov    0x8(%ebp),%eax
8010333e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103341:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103348:	00 
80103349:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103350:	e8 fe fd ff ff       	call   80103153 <outb>
  outb(CMOS_PORT+1, 0x0A);
80103355:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010335c:	00 
8010335d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103364:	e8 ea fd ff ff       	call   80103153 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103369:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103370:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103373:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103378:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010337b:	8d 50 02             	lea    0x2(%eax),%edx
8010337e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103381:	c1 e8 04             	shr    $0x4,%eax
80103384:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103387:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010338b:	c1 e0 18             	shl    $0x18,%eax
8010338e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103392:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103399:	e8 d1 fd ff ff       	call   8010316f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010339e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801033a5:	00 
801033a6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801033ad:	e8 bd fd ff ff       	call   8010316f <lapicw>
  microdelay(200);
801033b2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801033b9:	e8 72 ff ff ff       	call   80103330 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801033be:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801033c5:	00 
801033c6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801033cd:	e8 9d fd ff ff       	call   8010316f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801033d2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801033d9:	e8 52 ff ff ff       	call   80103330 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801033de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801033e5:	eb 3f                	jmp    80103426 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801033e7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801033eb:	c1 e0 18             	shl    $0x18,%eax
801033ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801033f2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801033f9:	e8 71 fd ff ff       	call   8010316f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801033fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103401:	c1 e8 0c             	shr    $0xc,%eax
80103404:	80 cc 06             	or     $0x6,%ah
80103407:	89 44 24 04          	mov    %eax,0x4(%esp)
8010340b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103412:	e8 58 fd ff ff       	call   8010316f <lapicw>
    microdelay(200);
80103417:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010341e:	e8 0d ff ff ff       	call   80103330 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103423:	ff 45 fc             	incl   -0x4(%ebp)
80103426:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010342a:	7e bb                	jle    801033e7 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010342c:	c9                   	leave  
8010342d:	c3                   	ret    

8010342e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010342e:	55                   	push   %ebp
8010342f:	89 e5                	mov    %esp,%ebp
80103431:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103434:	8b 45 08             	mov    0x8(%ebp),%eax
80103437:	0f b6 c0             	movzbl %al,%eax
8010343a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010343e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103445:	e8 09 fd ff ff       	call   80103153 <outb>
  microdelay(200);
8010344a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103451:	e8 da fe ff ff       	call   80103330 <microdelay>

  return inb(CMOS_RETURN);
80103456:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010345d:	e8 d6 fc ff ff       	call   80103138 <inb>
80103462:	0f b6 c0             	movzbl %al,%eax
}
80103465:	c9                   	leave  
80103466:	c3                   	ret    

80103467 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103467:	55                   	push   %ebp
80103468:	89 e5                	mov    %esp,%ebp
8010346a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010346d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103474:	e8 b5 ff ff ff       	call   8010342e <cmos_read>
80103479:	8b 55 08             	mov    0x8(%ebp),%edx
8010347c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010347e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103485:	e8 a4 ff ff ff       	call   8010342e <cmos_read>
8010348a:	8b 55 08             	mov    0x8(%ebp),%edx
8010348d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103490:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103497:	e8 92 ff ff ff       	call   8010342e <cmos_read>
8010349c:	8b 55 08             	mov    0x8(%ebp),%edx
8010349f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801034a2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801034a9:	e8 80 ff ff ff       	call   8010342e <cmos_read>
801034ae:	8b 55 08             	mov    0x8(%ebp),%edx
801034b1:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801034b4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801034bb:	e8 6e ff ff ff       	call   8010342e <cmos_read>
801034c0:	8b 55 08             	mov    0x8(%ebp),%edx
801034c3:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801034c6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801034cd:	e8 5c ff ff ff       	call   8010342e <cmos_read>
801034d2:	8b 55 08             	mov    0x8(%ebp),%edx
801034d5:	89 42 14             	mov    %eax,0x14(%edx)
}
801034d8:	c9                   	leave  
801034d9:	c3                   	ret    

801034da <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801034da:	55                   	push   %ebp
801034db:	89 e5                	mov    %esp,%ebp
801034dd:	57                   	push   %edi
801034de:	56                   	push   %esi
801034df:	53                   	push   %ebx
801034e0:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801034e3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801034ea:	e8 3f ff ff ff       	call   8010342e <cmos_read>
801034ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801034f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034f5:	83 e0 04             	and    $0x4,%eax
801034f8:	85 c0                	test   %eax,%eax
801034fa:	0f 94 c0             	sete   %al
801034fd:	0f b6 c0             	movzbl %al,%eax
80103500:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103503:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103506:	89 04 24             	mov    %eax,(%esp)
80103509:	e8 59 ff ff ff       	call   80103467 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010350e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103515:	e8 14 ff ff ff       	call   8010342e <cmos_read>
8010351a:	25 80 00 00 00       	and    $0x80,%eax
8010351f:	85 c0                	test   %eax,%eax
80103521:	74 02                	je     80103525 <cmostime+0x4b>
        continue;
80103523:	eb 36                	jmp    8010355b <cmostime+0x81>
    fill_rtcdate(&t2);
80103525:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103528:	89 04 24             	mov    %eax,(%esp)
8010352b:	e8 37 ff ff ff       	call   80103467 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103530:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103537:	00 
80103538:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010353b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010353f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103542:	89 04 24             	mov    %eax,(%esp)
80103545:	e8 07 23 00 00       	call   80105851 <memcmp>
8010354a:	85 c0                	test   %eax,%eax
8010354c:	75 0d                	jne    8010355b <cmostime+0x81>
      break;
8010354e:	90                   	nop
  }

  // convert
  if(bcd) {
8010354f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103553:	0f 84 ac 00 00 00    	je     80103605 <cmostime+0x12b>
80103559:	eb 02                	jmp    8010355d <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010355b:	eb a6                	jmp    80103503 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010355d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103560:	c1 e8 04             	shr    $0x4,%eax
80103563:	89 c2                	mov    %eax,%edx
80103565:	89 d0                	mov    %edx,%eax
80103567:	c1 e0 02             	shl    $0x2,%eax
8010356a:	01 d0                	add    %edx,%eax
8010356c:	01 c0                	add    %eax,%eax
8010356e:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103571:	83 e2 0f             	and    $0xf,%edx
80103574:	01 d0                	add    %edx,%eax
80103576:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103579:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010357c:	c1 e8 04             	shr    $0x4,%eax
8010357f:	89 c2                	mov    %eax,%edx
80103581:	89 d0                	mov    %edx,%eax
80103583:	c1 e0 02             	shl    $0x2,%eax
80103586:	01 d0                	add    %edx,%eax
80103588:	01 c0                	add    %eax,%eax
8010358a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010358d:	83 e2 0f             	and    $0xf,%edx
80103590:	01 d0                	add    %edx,%eax
80103592:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103595:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103598:	c1 e8 04             	shr    $0x4,%eax
8010359b:	89 c2                	mov    %eax,%edx
8010359d:	89 d0                	mov    %edx,%eax
8010359f:	c1 e0 02             	shl    $0x2,%eax
801035a2:	01 d0                	add    %edx,%eax
801035a4:	01 c0                	add    %eax,%eax
801035a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
801035a9:	83 e2 0f             	and    $0xf,%edx
801035ac:	01 d0                	add    %edx,%eax
801035ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801035b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801035b4:	c1 e8 04             	shr    $0x4,%eax
801035b7:	89 c2                	mov    %eax,%edx
801035b9:	89 d0                	mov    %edx,%eax
801035bb:	c1 e0 02             	shl    $0x2,%eax
801035be:	01 d0                	add    %edx,%eax
801035c0:	01 c0                	add    %eax,%eax
801035c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801035c5:	83 e2 0f             	and    $0xf,%edx
801035c8:	01 d0                	add    %edx,%eax
801035ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801035cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035d0:	c1 e8 04             	shr    $0x4,%eax
801035d3:	89 c2                	mov    %eax,%edx
801035d5:	89 d0                	mov    %edx,%eax
801035d7:	c1 e0 02             	shl    $0x2,%eax
801035da:	01 d0                	add    %edx,%eax
801035dc:	01 c0                	add    %eax,%eax
801035de:	8b 55 d8             	mov    -0x28(%ebp),%edx
801035e1:	83 e2 0f             	and    $0xf,%edx
801035e4:	01 d0                	add    %edx,%eax
801035e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801035e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035ec:	c1 e8 04             	shr    $0x4,%eax
801035ef:	89 c2                	mov    %eax,%edx
801035f1:	89 d0                	mov    %edx,%eax
801035f3:	c1 e0 02             	shl    $0x2,%eax
801035f6:	01 d0                	add    %edx,%eax
801035f8:	01 c0                	add    %eax,%eax
801035fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
801035fd:	83 e2 0f             	and    $0xf,%edx
80103600:	01 d0                	add    %edx,%eax
80103602:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103605:	8b 45 08             	mov    0x8(%ebp),%eax
80103608:	89 c2                	mov    %eax,%edx
8010360a:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010360d:	b8 06 00 00 00       	mov    $0x6,%eax
80103612:	89 d7                	mov    %edx,%edi
80103614:	89 de                	mov    %ebx,%esi
80103616:	89 c1                	mov    %eax,%ecx
80103618:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010361a:	8b 45 08             	mov    0x8(%ebp),%eax
8010361d:	8b 40 14             	mov    0x14(%eax),%eax
80103620:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103626:	8b 45 08             	mov    0x8(%ebp),%eax
80103629:	89 50 14             	mov    %edx,0x14(%eax)
}
8010362c:	83 c4 5c             	add    $0x5c,%esp
8010362f:	5b                   	pop    %ebx
80103630:	5e                   	pop    %esi
80103631:	5f                   	pop    %edi
80103632:	5d                   	pop    %ebp
80103633:	c3                   	ret    

80103634 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103634:	55                   	push   %ebp
80103635:	89 e5                	mov    %esp,%ebp
80103637:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010363a:	c7 44 24 04 01 9d 10 	movl   $0x80109d01,0x4(%esp)
80103641:	80 
80103642:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103649:	e8 08 1f 00 00       	call   80105556 <initlock>
  readsb(dev, &sb);
8010364e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103651:	89 44 24 04          	mov    %eax,0x4(%esp)
80103655:	8b 45 08             	mov    0x8(%ebp),%eax
80103658:	89 04 24             	mov    %eax,(%esp)
8010365b:	e8 60 de ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
80103660:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103663:	a3 f4 5b 11 80       	mov    %eax,0x80115bf4
  log.size = sb.nlog;
80103668:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010366b:	a3 f8 5b 11 80       	mov    %eax,0x80115bf8
  log.dev = dev;
80103670:	8b 45 08             	mov    0x8(%ebp),%eax
80103673:	a3 04 5c 11 80       	mov    %eax,0x80115c04
  recover_from_log();
80103678:	e8 95 01 00 00       	call   80103812 <recover_from_log>
}
8010367d:	c9                   	leave  
8010367e:	c3                   	ret    

8010367f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010367f:	55                   	push   %ebp
80103680:	89 e5                	mov    %esp,%ebp
80103682:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368c:	e9 89 00 00 00       	jmp    8010371a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103691:	8b 15 f4 5b 11 80    	mov    0x80115bf4,%edx
80103697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010369a:	01 d0                	add    %edx,%eax
8010369c:	40                   	inc    %eax
8010369d:	89 c2                	mov    %eax,%edx
8010369f:	a1 04 5c 11 80       	mov    0x80115c04,%eax
801036a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801036a8:	89 04 24             	mov    %eax,(%esp)
801036ab:	e8 05 cb ff ff       	call   801001b5 <bread>
801036b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801036b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b6:	83 c0 10             	add    $0x10,%eax
801036b9:	8b 04 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%eax
801036c0:	89 c2                	mov    %eax,%edx
801036c2:	a1 04 5c 11 80       	mov    0x80115c04,%eax
801036c7:	89 54 24 04          	mov    %edx,0x4(%esp)
801036cb:	89 04 24             	mov    %eax,(%esp)
801036ce:	e8 e2 ca ff ff       	call   801001b5 <bread>
801036d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801036d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d9:	8d 50 5c             	lea    0x5c(%eax),%edx
801036dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036df:	83 c0 5c             	add    $0x5c,%eax
801036e2:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036e9:	00 
801036ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801036ee:	89 04 24             	mov    %eax,(%esp)
801036f1:	e8 ad 21 00 00       	call   801058a3 <memmove>
    bwrite(dbuf);  // write dst to disk
801036f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036f9:	89 04 24             	mov    %eax,(%esp)
801036fc:	e8 eb ca ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103704:	89 04 24             	mov    %eax,(%esp)
80103707:	e8 20 cb ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010370c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010370f:	89 04 24             	mov    %eax,(%esp)
80103712:	e8 15 cb ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103717:	ff 45 f4             	incl   -0xc(%ebp)
8010371a:	a1 08 5c 11 80       	mov    0x80115c08,%eax
8010371f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103722:	0f 8f 69 ff ff ff    	jg     80103691 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103728:	c9                   	leave  
80103729:	c3                   	ret    

8010372a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010372a:	55                   	push   %ebp
8010372b:	89 e5                	mov    %esp,%ebp
8010372d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103730:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
80103735:	89 c2                	mov    %eax,%edx
80103737:	a1 04 5c 11 80       	mov    0x80115c04,%eax
8010373c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103740:	89 04 24             	mov    %eax,(%esp)
80103743:	e8 6d ca ff ff       	call   801001b5 <bread>
80103748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010374b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010374e:	83 c0 5c             	add    $0x5c,%eax
80103751:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103754:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103757:	8b 00                	mov    (%eax),%eax
80103759:	a3 08 5c 11 80       	mov    %eax,0x80115c08
  for (i = 0; i < log.lh.n; i++) {
8010375e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103765:	eb 1a                	jmp    80103781 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103767:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010376a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010376d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103771:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103774:	83 c2 10             	add    $0x10,%edx
80103777:	89 04 95 cc 5b 11 80 	mov    %eax,-0x7feea434(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010377e:	ff 45 f4             	incl   -0xc(%ebp)
80103781:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103786:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103789:	7f dc                	jg     80103767 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010378b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010378e:	89 04 24             	mov    %eax,(%esp)
80103791:	e8 96 ca ff ff       	call   8010022c <brelse>
}
80103796:	c9                   	leave  
80103797:	c3                   	ret    

80103798 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103798:	55                   	push   %ebp
80103799:	89 e5                	mov    %esp,%ebp
8010379b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010379e:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
801037a3:	89 c2                	mov    %eax,%edx
801037a5:	a1 04 5c 11 80       	mov    0x80115c04,%eax
801037aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801037ae:	89 04 24             	mov    %eax,(%esp)
801037b1:	e8 ff c9 ff ff       	call   801001b5 <bread>
801037b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801037b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037bc:	83 c0 5c             	add    $0x5c,%eax
801037bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801037c2:	8b 15 08 5c 11 80    	mov    0x80115c08,%edx
801037c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037cb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801037cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037d4:	eb 1a                	jmp    801037f0 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801037d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d9:	83 c0 10             	add    $0x10,%eax
801037dc:	8b 0c 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%ecx
801037e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037e9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801037ed:	ff 45 f4             	incl   -0xc(%ebp)
801037f0:	a1 08 5c 11 80       	mov    0x80115c08,%eax
801037f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037f8:	7f dc                	jg     801037d6 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801037fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037fd:	89 04 24             	mov    %eax,(%esp)
80103800:	e8 e7 c9 ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103808:	89 04 24             	mov    %eax,(%esp)
8010380b:	e8 1c ca ff ff       	call   8010022c <brelse>
}
80103810:	c9                   	leave  
80103811:	c3                   	ret    

80103812 <recover_from_log>:

static void
recover_from_log(void)
{
80103812:	55                   	push   %ebp
80103813:	89 e5                	mov    %esp,%ebp
80103815:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103818:	e8 0d ff ff ff       	call   8010372a <read_head>
  install_trans(); // if committed, copy from log to disk
8010381d:	e8 5d fe ff ff       	call   8010367f <install_trans>
  log.lh.n = 0;
80103822:	c7 05 08 5c 11 80 00 	movl   $0x0,0x80115c08
80103829:	00 00 00 
  write_head(); // clear the log
8010382c:	e8 67 ff ff ff       	call   80103798 <write_head>
}
80103831:	c9                   	leave  
80103832:	c3                   	ret    

80103833 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103833:	55                   	push   %ebp
80103834:	89 e5                	mov    %esp,%ebp
80103836:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103839:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103840:	e8 32 1d 00 00       	call   80105577 <acquire>
  while(1){
    if(log.committing){
80103845:	a1 00 5c 11 80       	mov    0x80115c00,%eax
8010384a:	85 c0                	test   %eax,%eax
8010384c:	74 16                	je     80103864 <begin_op+0x31>
      sleep(&log, &log.lock);
8010384e:	c7 44 24 04 c0 5b 11 	movl   $0x80115bc0,0x4(%esp)
80103855:	80 
80103856:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010385d:	e8 29 16 00 00       	call   80104e8b <sleep>
80103862:	eb 4d                	jmp    801038b1 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103864:	8b 15 08 5c 11 80    	mov    0x80115c08,%edx
8010386a:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
8010386f:	8d 48 01             	lea    0x1(%eax),%ecx
80103872:	89 c8                	mov    %ecx,%eax
80103874:	c1 e0 02             	shl    $0x2,%eax
80103877:	01 c8                	add    %ecx,%eax
80103879:	01 c0                	add    %eax,%eax
8010387b:	01 d0                	add    %edx,%eax
8010387d:	83 f8 1e             	cmp    $0x1e,%eax
80103880:	7e 16                	jle    80103898 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103882:	c7 44 24 04 c0 5b 11 	movl   $0x80115bc0,0x4(%esp)
80103889:	80 
8010388a:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103891:	e8 f5 15 00 00       	call   80104e8b <sleep>
80103896:	eb 19                	jmp    801038b1 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103898:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
8010389d:	40                   	inc    %eax
8010389e:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
      release(&log.lock);
801038a3:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801038aa:	e8 32 1d 00 00       	call   801055e1 <release>
      break;
801038af:	eb 02                	jmp    801038b3 <begin_op+0x80>
    }
  }
801038b1:	eb 92                	jmp    80103845 <begin_op+0x12>
}
801038b3:	c9                   	leave  
801038b4:	c3                   	ret    

801038b5 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801038b5:	55                   	push   %ebp
801038b6:	89 e5                	mov    %esp,%ebp
801038b8:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801038bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801038c2:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801038c9:	e8 a9 1c 00 00       	call   80105577 <acquire>
  log.outstanding -= 1;
801038ce:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
801038d3:	48                   	dec    %eax
801038d4:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
  if(log.committing)
801038d9:	a1 00 5c 11 80       	mov    0x80115c00,%eax
801038de:	85 c0                	test   %eax,%eax
801038e0:	74 0c                	je     801038ee <end_op+0x39>
    panic("log.committing");
801038e2:	c7 04 24 05 9d 10 80 	movl   $0x80109d05,(%esp)
801038e9:	e8 66 cc ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801038ee:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
801038f3:	85 c0                	test   %eax,%eax
801038f5:	75 13                	jne    8010390a <end_op+0x55>
    do_commit = 1;
801038f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801038fe:	c7 05 00 5c 11 80 01 	movl   $0x1,0x80115c00
80103905:	00 00 00 
80103908:	eb 0c                	jmp    80103916 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010390a:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103911:	e8 4c 16 00 00       	call   80104f62 <wakeup>
  }
  release(&log.lock);
80103916:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010391d:	e8 bf 1c 00 00       	call   801055e1 <release>

  if(do_commit){
80103922:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103926:	74 33                	je     8010395b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103928:	e8 db 00 00 00       	call   80103a08 <commit>
    acquire(&log.lock);
8010392d:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103934:	e8 3e 1c 00 00       	call   80105577 <acquire>
    log.committing = 0;
80103939:	c7 05 00 5c 11 80 00 	movl   $0x0,0x80115c00
80103940:	00 00 00 
    wakeup(&log);
80103943:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010394a:	e8 13 16 00 00       	call   80104f62 <wakeup>
    release(&log.lock);
8010394f:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103956:	e8 86 1c 00 00       	call   801055e1 <release>
  }
}
8010395b:	c9                   	leave  
8010395c:	c3                   	ret    

8010395d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010395d:	55                   	push   %ebp
8010395e:	89 e5                	mov    %esp,%ebp
80103960:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103963:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010396a:	e9 89 00 00 00       	jmp    801039f8 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010396f:	8b 15 f4 5b 11 80    	mov    0x80115bf4,%edx
80103975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103978:	01 d0                	add    %edx,%eax
8010397a:	40                   	inc    %eax
8010397b:	89 c2                	mov    %eax,%edx
8010397d:	a1 04 5c 11 80       	mov    0x80115c04,%eax
80103982:	89 54 24 04          	mov    %edx,0x4(%esp)
80103986:	89 04 24             	mov    %eax,(%esp)
80103989:	e8 27 c8 ff ff       	call   801001b5 <bread>
8010398e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103994:	83 c0 10             	add    $0x10,%eax
80103997:	8b 04 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%eax
8010399e:	89 c2                	mov    %eax,%edx
801039a0:	a1 04 5c 11 80       	mov    0x80115c04,%eax
801039a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801039a9:	89 04 24             	mov    %eax,(%esp)
801039ac:	e8 04 c8 ff ff       	call   801001b5 <bread>
801039b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801039b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039b7:	8d 50 5c             	lea    0x5c(%eax),%edx
801039ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039bd:	83 c0 5c             	add    $0x5c,%eax
801039c0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801039c7:	00 
801039c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801039cc:	89 04 24             	mov    %eax,(%esp)
801039cf:	e8 cf 1e 00 00       	call   801058a3 <memmove>
    bwrite(to);  // write the log
801039d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d7:	89 04 24             	mov    %eax,(%esp)
801039da:	e8 0d c8 ff ff       	call   801001ec <bwrite>
    brelse(from);
801039df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039e2:	89 04 24             	mov    %eax,(%esp)
801039e5:	e8 42 c8 ff ff       	call   8010022c <brelse>
    brelse(to);
801039ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ed:	89 04 24             	mov    %eax,(%esp)
801039f0:	e8 37 c8 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039f5:	ff 45 f4             	incl   -0xc(%ebp)
801039f8:	a1 08 5c 11 80       	mov    0x80115c08,%eax
801039fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a00:	0f 8f 69 ff ff ff    	jg     8010396f <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103a06:	c9                   	leave  
80103a07:	c3                   	ret    

80103a08 <commit>:

static void
commit()
{
80103a08:	55                   	push   %ebp
80103a09:	89 e5                	mov    %esp,%ebp
80103a0b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103a0e:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103a13:	85 c0                	test   %eax,%eax
80103a15:	7e 1e                	jle    80103a35 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103a17:	e8 41 ff ff ff       	call   8010395d <write_log>
    write_head();    // Write header to disk -- the real commit
80103a1c:	e8 77 fd ff ff       	call   80103798 <write_head>
    install_trans(); // Now install writes to home locations
80103a21:	e8 59 fc ff ff       	call   8010367f <install_trans>
    log.lh.n = 0;
80103a26:	c7 05 08 5c 11 80 00 	movl   $0x0,0x80115c08
80103a2d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103a30:	e8 63 fd ff ff       	call   80103798 <write_head>
  }
}
80103a35:	c9                   	leave  
80103a36:	c3                   	ret    

80103a37 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103a37:	55                   	push   %ebp
80103a38:	89 e5                	mov    %esp,%ebp
80103a3a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103a3d:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103a42:	83 f8 1d             	cmp    $0x1d,%eax
80103a45:	7f 10                	jg     80103a57 <log_write+0x20>
80103a47:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103a4c:	8b 15 f8 5b 11 80    	mov    0x80115bf8,%edx
80103a52:	4a                   	dec    %edx
80103a53:	39 d0                	cmp    %edx,%eax
80103a55:	7c 0c                	jl     80103a63 <log_write+0x2c>
    panic("too big a transaction");
80103a57:	c7 04 24 14 9d 10 80 	movl   $0x80109d14,(%esp)
80103a5e:	e8 f1 ca ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103a63:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80103a68:	85 c0                	test   %eax,%eax
80103a6a:	7f 0c                	jg     80103a78 <log_write+0x41>
    panic("log_write outside of trans");
80103a6c:	c7 04 24 2a 9d 10 80 	movl   $0x80109d2a,(%esp)
80103a73:	e8 dc ca ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103a78:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103a7f:	e8 f3 1a 00 00       	call   80105577 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103a84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a8b:	eb 1e                	jmp    80103aab <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a90:	83 c0 10             	add    $0x10,%eax
80103a93:	8b 04 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%eax
80103a9a:	89 c2                	mov    %eax,%edx
80103a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9f:	8b 40 08             	mov    0x8(%eax),%eax
80103aa2:	39 c2                	cmp    %eax,%edx
80103aa4:	75 02                	jne    80103aa8 <log_write+0x71>
      break;
80103aa6:	eb 0d                	jmp    80103ab5 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103aa8:	ff 45 f4             	incl   -0xc(%ebp)
80103aab:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103ab0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ab3:	7f d8                	jg     80103a8d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab8:	8b 40 08             	mov    0x8(%eax),%eax
80103abb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103abe:	83 c2 10             	add    $0x10,%edx
80103ac1:	89 04 95 cc 5b 11 80 	mov    %eax,-0x7feea434(,%edx,4)
  if (i == log.lh.n)
80103ac8:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103acd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ad0:	75 0b                	jne    80103add <log_write+0xa6>
    log.lh.n++;
80103ad2:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103ad7:	40                   	inc    %eax
80103ad8:	a3 08 5c 11 80       	mov    %eax,0x80115c08
  b->flags |= B_DIRTY; // prevent eviction
80103add:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae0:	8b 00                	mov    (%eax),%eax
80103ae2:	83 c8 04             	or     $0x4,%eax
80103ae5:	89 c2                	mov    %eax,%edx
80103ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80103aea:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103aec:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103af3:	e8 e9 1a 00 00       	call   801055e1 <release>
}
80103af8:	c9                   	leave  
80103af9:	c3                   	ret    
	...

80103afc <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103afc:	55                   	push   %ebp
80103afd:	89 e5                	mov    %esp,%ebp
80103aff:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b02:	8b 55 08             	mov    0x8(%ebp),%edx
80103b05:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103b0b:	f0 87 02             	lock xchg %eax,(%edx)
80103b0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103b11:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b14:	c9                   	leave  
80103b15:	c3                   	ret    

80103b16 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103b16:	55                   	push   %ebp
80103b17:	89 e5                	mov    %esp,%ebp
80103b19:	83 e4 f0             	and    $0xfffffff0,%esp
80103b1c:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103b1f:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103b26:	80 
80103b27:	c7 04 24 f0 8d 11 80 	movl   $0x80118df0,(%esp)
80103b2e:	e8 dd f1 ff ff       	call   80102d10 <kinit1>
  kvmalloc();      // kernel page table
80103b33:	e8 1b 4e 00 00       	call   80108953 <kvmalloc>
  mpinit();        // detect other processors
80103b38:	e8 cc 03 00 00       	call   80103f09 <mpinit>
  lapicinit();     // interrupt controller
80103b3d:	e8 4e f6 ff ff       	call   80103190 <lapicinit>
  seginit();       // segment descriptors
80103b42:	e8 f4 48 00 00       	call   8010843b <seginit>
  picinit();       // disable pic
80103b47:	e8 0c 05 00 00       	call   80104058 <picinit>
  ioapicinit();    // another interrupt controller
80103b4c:	e8 dc f0 ff ff       	call   80102c2d <ioapicinit>
  consoleinit();   // console hardware
80103b51:	e8 99 d0 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103b56:	e8 6c 3c 00 00       	call   801077c7 <uartinit>
  pinit();         // process table
80103b5b:	e8 ee 08 00 00       	call   8010444e <pinit>
  tvinit();        // trap vectors
80103b60:	e8 2f 38 00 00       	call   80107394 <tvinit>
  binit();         // buffer cache
80103b65:	e8 ca c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b6a:	e8 77 d5 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103b6f:	e8 c5 ec ff ff       	call   80102839 <ideinit>
  startothers();   // start other processors
80103b74:	e8 88 00 00 00       	call   80103c01 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103b79:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103b80:	8e 
80103b81:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103b88:	e8 bb f1 ff ff       	call   80102d48 <kinit2>
  userinit();      // first user process
80103b8d:	e8 e6 0a 00 00       	call   80104678 <userinit>
  container_init();
80103b92:	e8 91 5c 00 00       	call   80109828 <container_init>
  mpmain();        // finish this processor's setup
80103b97:	e8 1a 00 00 00       	call   80103bb6 <mpmain>

80103b9c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b9c:	55                   	push   %ebp
80103b9d:	89 e5                	mov    %esp,%ebp
80103b9f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ba2:	e8 c3 4d 00 00       	call   8010896a <switchkvm>
  seginit();
80103ba7:	e8 8f 48 00 00       	call   8010843b <seginit>
  lapicinit();
80103bac:	e8 df f5 ff ff       	call   80103190 <lapicinit>
  mpmain();
80103bb1:	e8 00 00 00 00       	call   80103bb6 <mpmain>

80103bb6 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103bb6:	55                   	push   %ebp
80103bb7:	89 e5                	mov    %esp,%ebp
80103bb9:	53                   	push   %ebx
80103bba:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103bbd:	e8 a8 08 00 00       	call   8010446a <cpuid>
80103bc2:	89 c3                	mov    %eax,%ebx
80103bc4:	e8 a1 08 00 00       	call   8010446a <cpuid>
80103bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bd1:	c7 04 24 45 9d 10 80 	movl   $0x80109d45,(%esp)
80103bd8:	e8 e4 c7 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103bdd:	e8 0f 39 00 00       	call   801074f1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103be2:	e8 c8 08 00 00       	call   801044af <mycpu>
80103be7:	05 a0 00 00 00       	add    $0xa0,%eax
80103bec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103bf3:	00 
80103bf4:	89 04 24             	mov    %eax,(%esp)
80103bf7:	e8 00 ff ff ff       	call   80103afc <xchg>
  scheduler();     // start running processes
80103bfc:	e8 16 10 00 00       	call   80104c17 <scheduler>

80103c01 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c01:	55                   	push   %ebp
80103c02:	89 e5                	mov    %esp,%ebp
80103c04:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103c07:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c0e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c13:	89 44 24 08          	mov    %eax,0x8(%esp)
80103c17:	c7 44 24 04 8c d5 10 	movl   $0x8010d58c,0x4(%esp)
80103c1e:	80 
80103c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c22:	89 04 24             	mov    %eax,(%esp)
80103c25:	e8 79 1c 00 00       	call   801058a3 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103c2a:	c7 45 f4 c0 5c 11 80 	movl   $0x80115cc0,-0xc(%ebp)
80103c31:	eb 75                	jmp    80103ca8 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103c33:	e8 77 08 00 00       	call   801044af <mycpu>
80103c38:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c3b:	75 02                	jne    80103c3f <startothers+0x3e>
      continue;
80103c3d:	eb 62                	jmp    80103ca1 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103c3f:	e8 5a f2 ff ff       	call   80102e9e <kalloc>
80103c44:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4a:	83 e8 04             	sub    $0x4,%eax
80103c4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103c50:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103c56:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c5b:	83 e8 08             	sub    $0x8,%eax
80103c5e:	c7 00 9c 3b 10 80    	movl   $0x80103b9c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c67:	8d 50 f4             	lea    -0xc(%eax),%edx
80103c6a:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103c6f:	05 00 00 00 80       	add    $0x80000000,%eax
80103c74:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c79:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	8a 00                	mov    (%eax),%al
80103c84:	0f b6 c0             	movzbl %al,%eax
80103c87:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c8b:	89 04 24             	mov    %eax,(%esp)
80103c8e:	e8 a2 f6 ff ff       	call   80103335 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c93:	90                   	nop
80103c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c97:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c9d:	85 c0                	test   %eax,%eax
80103c9f:	74 f3                	je     80103c94 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103ca1:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103ca8:	a1 40 62 11 80       	mov    0x80116240,%eax
80103cad:	89 c2                	mov    %eax,%edx
80103caf:	89 d0                	mov    %edx,%eax
80103cb1:	c1 e0 02             	shl    $0x2,%eax
80103cb4:	01 d0                	add    %edx,%eax
80103cb6:	01 c0                	add    %eax,%eax
80103cb8:	01 d0                	add    %edx,%eax
80103cba:	c1 e0 04             	shl    $0x4,%eax
80103cbd:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80103cc2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cc5:	0f 87 68 ff ff ff    	ja     80103c33 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103ccb:	c9                   	leave  
80103ccc:	c3                   	ret    
80103ccd:	00 00                	add    %al,(%eax)
	...

80103cd0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103cd0:	55                   	push   %ebp
80103cd1:	89 e5                	mov    %esp,%ebp
80103cd3:	83 ec 14             	sub    $0x14,%esp
80103cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103cdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ce0:	89 c2                	mov    %eax,%edx
80103ce2:	ec                   	in     (%dx),%al
80103ce3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ce6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103ce9:	c9                   	leave  
80103cea:	c3                   	ret    

80103ceb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ceb:	55                   	push   %ebp
80103cec:	89 e5                	mov    %esp,%ebp
80103cee:	83 ec 08             	sub    $0x8,%esp
80103cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cf7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103cfb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103cfe:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d01:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d04:	ee                   	out    %al,(%dx)
}
80103d05:	c9                   	leave  
80103d06:	c3                   	ret    

80103d07 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103d07:	55                   	push   %ebp
80103d08:	89 e5                	mov    %esp,%ebp
80103d0a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103d0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103d14:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103d1b:	eb 13                	jmp    80103d30 <sum+0x29>
    sum += addr[i];
80103d1d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d20:	8b 45 08             	mov    0x8(%ebp),%eax
80103d23:	01 d0                	add    %edx,%eax
80103d25:	8a 00                	mov    (%eax),%al
80103d27:	0f b6 c0             	movzbl %al,%eax
80103d2a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103d2d:	ff 45 fc             	incl   -0x4(%ebp)
80103d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d33:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103d36:	7c e5                	jl     80103d1d <sum+0x16>
    sum += addr[i];
  return sum;
80103d38:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103d3b:	c9                   	leave  
80103d3c:	c3                   	ret    

80103d3d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103d3d:	55                   	push   %ebp
80103d3e:	89 e5                	mov    %esp,%ebp
80103d40:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103d43:	8b 45 08             	mov    0x8(%ebp),%eax
80103d46:	05 00 00 00 80       	add    $0x80000000,%eax
80103d4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d54:	01 d0                	add    %edx,%eax
80103d56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d5f:	eb 3f                	jmp    80103da0 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103d61:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d68:	00 
80103d69:	c7 44 24 04 5c 9d 10 	movl   $0x80109d5c,0x4(%esp)
80103d70:	80 
80103d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d74:	89 04 24             	mov    %eax,(%esp)
80103d77:	e8 d5 1a 00 00       	call   80105851 <memcmp>
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 1c                	jne    80103d9c <mpsearch1+0x5f>
80103d80:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103d87:	00 
80103d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8b:	89 04 24             	mov    %eax,(%esp)
80103d8e:	e8 74 ff ff ff       	call   80103d07 <sum>
80103d93:	84 c0                	test   %al,%al
80103d95:	75 05                	jne    80103d9c <mpsearch1+0x5f>
      return (struct mp*)p;
80103d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9a:	eb 11                	jmp    80103dad <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103d9c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103da6:	72 b9                	jb     80103d61 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dad:	c9                   	leave  
80103dae:	c3                   	ret    

80103daf <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103daf:	55                   	push   %ebp
80103db0:	89 e5                	mov    %esp,%ebp
80103db2:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103db5:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbf:	83 c0 0f             	add    $0xf,%eax
80103dc2:	8a 00                	mov    (%eax),%al
80103dc4:	0f b6 c0             	movzbl %al,%eax
80103dc7:	c1 e0 08             	shl    $0x8,%eax
80103dca:	89 c2                	mov    %eax,%edx
80103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcf:	83 c0 0e             	add    $0xe,%eax
80103dd2:	8a 00                	mov    (%eax),%al
80103dd4:	0f b6 c0             	movzbl %al,%eax
80103dd7:	09 d0                	or     %edx,%eax
80103dd9:	c1 e0 04             	shl    $0x4,%eax
80103ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ddf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103de3:	74 21                	je     80103e06 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103de5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103dec:	00 
80103ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df0:	89 04 24             	mov    %eax,(%esp)
80103df3:	e8 45 ff ff ff       	call   80103d3d <mpsearch1>
80103df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dff:	74 4e                	je     80103e4f <mpsearch+0xa0>
      return mp;
80103e01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e04:	eb 5d                	jmp    80103e63 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e09:	83 c0 14             	add    $0x14,%eax
80103e0c:	8a 00                	mov    (%eax),%al
80103e0e:	0f b6 c0             	movzbl %al,%eax
80103e11:	c1 e0 08             	shl    $0x8,%eax
80103e14:	89 c2                	mov    %eax,%edx
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	83 c0 13             	add    $0x13,%eax
80103e1c:	8a 00                	mov    (%eax),%al
80103e1e:	0f b6 c0             	movzbl %al,%eax
80103e21:	09 d0                	or     %edx,%eax
80103e23:	c1 e0 0a             	shl    $0xa,%eax
80103e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e2c:	2d 00 04 00 00       	sub    $0x400,%eax
80103e31:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e38:	00 
80103e39:	89 04 24             	mov    %eax,(%esp)
80103e3c:	e8 fc fe ff ff       	call   80103d3d <mpsearch1>
80103e41:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e48:	74 05                	je     80103e4f <mpsearch+0xa0>
      return mp;
80103e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e4d:	eb 14                	jmp    80103e63 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103e4f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103e56:	00 
80103e57:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103e5e:	e8 da fe ff ff       	call   80103d3d <mpsearch1>
}
80103e63:	c9                   	leave  
80103e64:	c3                   	ret    

80103e65 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103e65:	55                   	push   %ebp
80103e66:	89 e5                	mov    %esp,%ebp
80103e68:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103e6b:	e8 3f ff ff ff       	call   80103daf <mpsearch>
80103e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e77:	74 0a                	je     80103e83 <mpconfig+0x1e>
80103e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7c:	8b 40 04             	mov    0x4(%eax),%eax
80103e7f:	85 c0                	test   %eax,%eax
80103e81:	75 07                	jne    80103e8a <mpconfig+0x25>
    return 0;
80103e83:	b8 00 00 00 00       	mov    $0x0,%eax
80103e88:	eb 7d                	jmp    80103f07 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8d:	8b 40 04             	mov    0x4(%eax),%eax
80103e90:	05 00 00 00 80       	add    $0x80000000,%eax
80103e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e98:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103e9f:	00 
80103ea0:	c7 44 24 04 61 9d 10 	movl   $0x80109d61,0x4(%esp)
80103ea7:	80 
80103ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eab:	89 04 24             	mov    %eax,(%esp)
80103eae:	e8 9e 19 00 00       	call   80105851 <memcmp>
80103eb3:	85 c0                	test   %eax,%eax
80103eb5:	74 07                	je     80103ebe <mpconfig+0x59>
    return 0;
80103eb7:	b8 00 00 00 00       	mov    $0x0,%eax
80103ebc:	eb 49                	jmp    80103f07 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec1:	8a 40 06             	mov    0x6(%eax),%al
80103ec4:	3c 01                	cmp    $0x1,%al
80103ec6:	74 11                	je     80103ed9 <mpconfig+0x74>
80103ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ecb:	8a 40 06             	mov    0x6(%eax),%al
80103ece:	3c 04                	cmp    $0x4,%al
80103ed0:	74 07                	je     80103ed9 <mpconfig+0x74>
    return 0;
80103ed2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ed7:	eb 2e                	jmp    80103f07 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103edc:	8b 40 04             	mov    0x4(%eax),%eax
80103edf:	0f b7 c0             	movzwl %ax,%eax
80103ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee9:	89 04 24             	mov    %eax,(%esp)
80103eec:	e8 16 fe ff ff       	call   80103d07 <sum>
80103ef1:	84 c0                	test   %al,%al
80103ef3:	74 07                	je     80103efc <mpconfig+0x97>
    return 0;
80103ef5:	b8 00 00 00 00       	mov    $0x0,%eax
80103efa:	eb 0b                	jmp    80103f07 <mpconfig+0xa2>
  *pmp = mp;
80103efc:	8b 45 08             	mov    0x8(%ebp),%eax
80103eff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f02:	89 10                	mov    %edx,(%eax)
  return conf;
80103f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f07:	c9                   	leave  
80103f08:	c3                   	ret    

80103f09 <mpinit>:

void
mpinit(void)
{
80103f09:	55                   	push   %ebp
80103f0a:	89 e5                	mov    %esp,%ebp
80103f0c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103f0f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103f12:	89 04 24             	mov    %eax,(%esp)
80103f15:	e8 4b ff ff ff       	call   80103e65 <mpconfig>
80103f1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f21:	75 0c                	jne    80103f2f <mpinit+0x26>
    panic("Expect to run on an SMP");
80103f23:	c7 04 24 66 9d 10 80 	movl   $0x80109d66,(%esp)
80103f2a:	e8 25 c6 ff ff       	call   80100554 <panic>
  ismp = 1;
80103f2f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f39:	8b 40 24             	mov    0x24(%eax),%eax
80103f3c:	a3 a0 5b 11 80       	mov    %eax,0x80115ba0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f44:	83 c0 2c             	add    $0x2c,%eax
80103f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f4d:	8b 40 04             	mov    0x4(%eax),%eax
80103f50:	0f b7 d0             	movzwl %ax,%edx
80103f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f56:	01 d0                	add    %edx,%eax
80103f58:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103f5b:	eb 7d                	jmp    80103fda <mpinit+0xd1>
    switch(*p){
80103f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f60:	8a 00                	mov    (%eax),%al
80103f62:	0f b6 c0             	movzbl %al,%eax
80103f65:	83 f8 04             	cmp    $0x4,%eax
80103f68:	77 68                	ja     80103fd2 <mpinit+0xc9>
80103f6a:	8b 04 85 a0 9d 10 80 	mov    -0x7fef6260(,%eax,4),%eax
80103f71:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103f79:	a1 40 62 11 80       	mov    0x80116240,%eax
80103f7e:	83 f8 07             	cmp    $0x7,%eax
80103f81:	7f 2c                	jg     80103faf <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f83:	8b 15 40 62 11 80    	mov    0x80116240,%edx
80103f89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f8c:	8a 48 01             	mov    0x1(%eax),%cl
80103f8f:	89 d0                	mov    %edx,%eax
80103f91:	c1 e0 02             	shl    $0x2,%eax
80103f94:	01 d0                	add    %edx,%eax
80103f96:	01 c0                	add    %eax,%eax
80103f98:	01 d0                	add    %edx,%eax
80103f9a:	c1 e0 04             	shl    $0x4,%eax
80103f9d:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80103fa2:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103fa4:	a1 40 62 11 80       	mov    0x80116240,%eax
80103fa9:	40                   	inc    %eax
80103faa:	a3 40 62 11 80       	mov    %eax,0x80116240
      }
      p += sizeof(struct mpproc);
80103faf:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103fb3:	eb 25                	jmp    80103fda <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fbe:	8a 40 01             	mov    0x1(%eax),%al
80103fc1:	a2 a0 5c 11 80       	mov    %al,0x80115ca0
      p += sizeof(struct mpioapic);
80103fc6:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103fca:	eb 0e                	jmp    80103fda <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103fcc:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103fd0:	eb 08                	jmp    80103fda <mpinit+0xd1>
    default:
      ismp = 0;
80103fd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103fd9:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103fe0:	0f 82 77 ff ff ff    	jb     80103f5d <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103fe6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fea:	75 0c                	jne    80103ff8 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103fec:	c7 04 24 80 9d 10 80 	movl   $0x80109d80,(%esp)
80103ff3:	e8 5c c5 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103ff8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffb:	8a 40 0c             	mov    0xc(%eax),%al
80103ffe:	84 c0                	test   %al,%al
80104000:	74 36                	je     80104038 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104002:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104009:	00 
8010400a:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104011:	e8 d5 fc ff ff       	call   80103ceb <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104016:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010401d:	e8 ae fc ff ff       	call   80103cd0 <inb>
80104022:	83 c8 01             	or     $0x1,%eax
80104025:	0f b6 c0             	movzbl %al,%eax
80104028:	89 44 24 04          	mov    %eax,0x4(%esp)
8010402c:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104033:	e8 b3 fc ff ff       	call   80103ceb <outb>
  }
}
80104038:	c9                   	leave  
80104039:	c3                   	ret    
	...

8010403c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010403c:	55                   	push   %ebp
8010403d:	89 e5                	mov    %esp,%ebp
8010403f:	83 ec 08             	sub    $0x8,%esp
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	8b 55 0c             	mov    0xc(%ebp),%edx
80104048:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010404c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010404f:	8a 45 f8             	mov    -0x8(%ebp),%al
80104052:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104055:	ee                   	out    %al,(%dx)
}
80104056:	c9                   	leave  
80104057:	c3                   	ret    

80104058 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104058:	55                   	push   %ebp
80104059:	89 e5                	mov    %esp,%ebp
8010405b:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010405e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104065:	00 
80104066:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010406d:	e8 ca ff ff ff       	call   8010403c <outb>
  outb(IO_PIC2+1, 0xFF);
80104072:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104079:	00 
8010407a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104081:	e8 b6 ff ff ff       	call   8010403c <outb>
}
80104086:	c9                   	leave  
80104087:	c3                   	ret    

80104088 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104088:	55                   	push   %ebp
80104089:	89 e5                	mov    %esp,%ebp
8010408b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
8010408e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104095:	8b 45 0c             	mov    0xc(%ebp),%eax
80104098:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010409e:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a1:	8b 10                	mov    (%eax),%edx
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040a8:	e8 55 d0 ff ff       	call   80101102 <filealloc>
801040ad:	8b 55 08             	mov    0x8(%ebp),%edx
801040b0:	89 02                	mov    %eax,(%edx)
801040b2:	8b 45 08             	mov    0x8(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	0f 84 c8 00 00 00    	je     80104187 <pipealloc+0xff>
801040bf:	e8 3e d0 ff ff       	call   80101102 <filealloc>
801040c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801040c7:	89 02                	mov    %eax,(%edx)
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	85 c0                	test   %eax,%eax
801040d0:	0f 84 b1 00 00 00    	je     80104187 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040d6:	e8 c3 ed ff ff       	call   80102e9e <kalloc>
801040db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040e2:	75 05                	jne    801040e9 <pipealloc+0x61>
    goto bad;
801040e4:	e9 9e 00 00 00       	jmp    80104187 <pipealloc+0xff>
  p->readopen = 1;
801040e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ec:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040f3:	00 00 00 
  p->writeopen = 1;
801040f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f9:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104100:	00 00 00 
  p->nwrite = 0;
80104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104106:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010410d:	00 00 00 
  p->nread = 0;
80104110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104113:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010411a:	00 00 00 
  initlock(&p->lock, "pipe");
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	c7 44 24 04 b4 9d 10 	movl   $0x80109db4,0x4(%esp)
80104127:	80 
80104128:	89 04 24             	mov    %eax,(%esp)
8010412b:	e8 26 14 00 00       	call   80105556 <initlock>
  (*f0)->type = FD_PIPE;
80104130:	8b 45 08             	mov    0x8(%ebp),%eax
80104133:	8b 00                	mov    (%eax),%eax
80104135:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 00                	mov    (%eax),%eax
80104140:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 00                	mov    (%eax),%eax
80104149:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	8b 00                	mov    (%eax),%eax
80104152:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104155:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104163:	8b 45 0c             	mov    0xc(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010416c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416f:	8b 00                	mov    (%eax),%eax
80104171:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104175:	8b 45 0c             	mov    0xc(%ebp),%eax
80104178:	8b 00                	mov    (%eax),%eax
8010417a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104180:	b8 00 00 00 00       	mov    $0x0,%eax
80104185:	eb 42                	jmp    801041c9 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010418b:	74 0b                	je     80104198 <pipealloc+0x110>
    kfree((char*)p);
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	89 04 24             	mov    %eax,(%esp)
80104193:	e8 17 ec ff ff       	call   80102daf <kfree>
  if(*f0)
80104198:	8b 45 08             	mov    0x8(%ebp),%eax
8010419b:	8b 00                	mov    (%eax),%eax
8010419d:	85 c0                	test   %eax,%eax
8010419f:	74 0d                	je     801041ae <pipealloc+0x126>
    fileclose(*f0);
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	8b 00                	mov    (%eax),%eax
801041a6:	89 04 24             	mov    %eax,(%esp)
801041a9:	e8 fc cf ff ff       	call   801011aa <fileclose>
  if(*f1)
801041ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b1:	8b 00                	mov    (%eax),%eax
801041b3:	85 c0                	test   %eax,%eax
801041b5:	74 0d                	je     801041c4 <pipealloc+0x13c>
    fileclose(*f1);
801041b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ba:	8b 00                	mov    (%eax),%eax
801041bc:	89 04 24             	mov    %eax,(%esp)
801041bf:	e8 e6 cf ff ff       	call   801011aa <fileclose>
  return -1;
801041c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041c9:	c9                   	leave  
801041ca:	c3                   	ret    

801041cb <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041cb:	55                   	push   %ebp
801041cc:	89 e5                	mov    %esp,%ebp
801041ce:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	89 04 24             	mov    %eax,(%esp)
801041d7:	e8 9b 13 00 00       	call   80105577 <acquire>
  if(writable){
801041dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041e0:	74 1f                	je     80104201 <pipeclose+0x36>
    p->writeopen = 0;
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041ec:	00 00 00 
    wakeup(&p->nread);
801041ef:	8b 45 08             	mov    0x8(%ebp),%eax
801041f2:	05 34 02 00 00       	add    $0x234,%eax
801041f7:	89 04 24             	mov    %eax,(%esp)
801041fa:	e8 63 0d 00 00       	call   80104f62 <wakeup>
801041ff:	eb 1d                	jmp    8010421e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010420b:	00 00 00 
    wakeup(&p->nwrite);
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	05 38 02 00 00       	add    $0x238,%eax
80104216:	89 04 24             	mov    %eax,(%esp)
80104219:	e8 44 0d 00 00       	call   80104f62 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010421e:	8b 45 08             	mov    0x8(%ebp),%eax
80104221:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104227:	85 c0                	test   %eax,%eax
80104229:	75 25                	jne    80104250 <pipeclose+0x85>
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104234:	85 c0                	test   %eax,%eax
80104236:	75 18                	jne    80104250 <pipeclose+0x85>
    release(&p->lock);
80104238:	8b 45 08             	mov    0x8(%ebp),%eax
8010423b:	89 04 24             	mov    %eax,(%esp)
8010423e:	e8 9e 13 00 00       	call   801055e1 <release>
    kfree((char*)p);
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	89 04 24             	mov    %eax,(%esp)
80104249:	e8 61 eb ff ff       	call   80102daf <kfree>
8010424e:	eb 0b                	jmp    8010425b <pipeclose+0x90>
  } else
    release(&p->lock);
80104250:	8b 45 08             	mov    0x8(%ebp),%eax
80104253:	89 04 24             	mov    %eax,(%esp)
80104256:	e8 86 13 00 00       	call   801055e1 <release>
}
8010425b:	c9                   	leave  
8010425c:	c3                   	ret    

8010425d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010425d:	55                   	push   %ebp
8010425e:	89 e5                	mov    %esp,%ebp
80104260:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104263:	8b 45 08             	mov    0x8(%ebp),%eax
80104266:	89 04 24             	mov    %eax,(%esp)
80104269:	e8 09 13 00 00       	call   80105577 <acquire>
  for(i = 0; i < n; i++){
8010426e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104275:	e9 a3 00 00 00       	jmp    8010431d <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010427a:	eb 56                	jmp    801042d2 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104285:	85 c0                	test   %eax,%eax
80104287:	74 0c                	je     80104295 <pipewrite+0x38>
80104289:	e8 a5 02 00 00       	call   80104533 <myproc>
8010428e:	8b 40 24             	mov    0x24(%eax),%eax
80104291:	85 c0                	test   %eax,%eax
80104293:	74 15                	je     801042aa <pipewrite+0x4d>
        release(&p->lock);
80104295:	8b 45 08             	mov    0x8(%ebp),%eax
80104298:	89 04 24             	mov    %eax,(%esp)
8010429b:	e8 41 13 00 00       	call   801055e1 <release>
        return -1;
801042a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a5:	e9 9d 00 00 00       	jmp    80104347 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801042aa:	8b 45 08             	mov    0x8(%ebp),%eax
801042ad:	05 34 02 00 00       	add    $0x234,%eax
801042b2:	89 04 24             	mov    %eax,(%esp)
801042b5:	e8 a8 0c 00 00       	call   80104f62 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042ba:	8b 45 08             	mov    0x8(%ebp),%eax
801042bd:	8b 55 08             	mov    0x8(%ebp),%edx
801042c0:	81 c2 38 02 00 00    	add    $0x238,%edx
801042c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801042ca:	89 14 24             	mov    %edx,(%esp)
801042cd:	e8 b9 0b 00 00       	call   80104e8b <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042d2:	8b 45 08             	mov    0x8(%ebp),%eax
801042d5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042e4:	05 00 02 00 00       	add    $0x200,%eax
801042e9:	39 c2                	cmp    %eax,%edx
801042eb:	74 8f                	je     8010427c <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042ed:	8b 45 08             	mov    0x8(%ebp),%eax
801042f0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f6:	8d 48 01             	lea    0x1(%eax),%ecx
801042f9:	8b 55 08             	mov    0x8(%ebp),%edx
801042fc:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104302:	25 ff 01 00 00       	and    $0x1ff,%eax
80104307:	89 c1                	mov    %eax,%ecx
80104309:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010430c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010430f:	01 d0                	add    %edx,%eax
80104311:	8a 10                	mov    (%eax),%dl
80104313:	8b 45 08             	mov    0x8(%ebp),%eax
80104316:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010431a:	ff 45 f4             	incl   -0xc(%ebp)
8010431d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104320:	3b 45 10             	cmp    0x10(%ebp),%eax
80104323:	0f 8c 51 ff ff ff    	jl     8010427a <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104329:	8b 45 08             	mov    0x8(%ebp),%eax
8010432c:	05 34 02 00 00       	add    $0x234,%eax
80104331:	89 04 24             	mov    %eax,(%esp)
80104334:	e8 29 0c 00 00       	call   80104f62 <wakeup>
  release(&p->lock);
80104339:	8b 45 08             	mov    0x8(%ebp),%eax
8010433c:	89 04 24             	mov    %eax,(%esp)
8010433f:	e8 9d 12 00 00       	call   801055e1 <release>
  return n;
80104344:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104347:	c9                   	leave  
80104348:	c3                   	ret    

80104349 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104349:	55                   	push   %ebp
8010434a:	89 e5                	mov    %esp,%ebp
8010434c:	53                   	push   %ebx
8010434d:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104350:	8b 45 08             	mov    0x8(%ebp),%eax
80104353:	89 04 24             	mov    %eax,(%esp)
80104356:	e8 1c 12 00 00       	call   80105577 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010435b:	eb 39                	jmp    80104396 <piperead+0x4d>
    if(myproc()->killed){
8010435d:	e8 d1 01 00 00       	call   80104533 <myproc>
80104362:	8b 40 24             	mov    0x24(%eax),%eax
80104365:	85 c0                	test   %eax,%eax
80104367:	74 15                	je     8010437e <piperead+0x35>
      release(&p->lock);
80104369:	8b 45 08             	mov    0x8(%ebp),%eax
8010436c:	89 04 24             	mov    %eax,(%esp)
8010436f:	e8 6d 12 00 00       	call   801055e1 <release>
      return -1;
80104374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104379:	e9 b3 00 00 00       	jmp    80104431 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437e:	8b 45 08             	mov    0x8(%ebp),%eax
80104381:	8b 55 08             	mov    0x8(%ebp),%edx
80104384:	81 c2 34 02 00 00    	add    $0x234,%edx
8010438a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010438e:	89 14 24             	mov    %edx,(%esp)
80104391:	e8 f5 0a 00 00       	call   80104e8b <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104396:	8b 45 08             	mov    0x8(%ebp),%eax
80104399:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439f:	8b 45 08             	mov    0x8(%ebp),%eax
801043a2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a8:	39 c2                	cmp    %eax,%edx
801043aa:	75 0d                	jne    801043b9 <piperead+0x70>
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b5:	85 c0                	test   %eax,%eax
801043b7:	75 a4                	jne    8010435d <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043c0:	eb 49                	jmp    8010440b <piperead+0xc2>
    if(p->nread == p->nwrite)
801043c2:	8b 45 08             	mov    0x8(%ebp),%eax
801043c5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043cb:	8b 45 08             	mov    0x8(%ebp),%eax
801043ce:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d4:	39 c2                	cmp    %eax,%edx
801043d6:	75 02                	jne    801043da <piperead+0x91>
      break;
801043d8:	eb 39                	jmp    80104413 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043e3:	8b 45 08             	mov    0x8(%ebp),%eax
801043e6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043ec:	8d 48 01             	lea    0x1(%eax),%ecx
801043ef:	8b 55 08             	mov    0x8(%ebp),%edx
801043f2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f8:	25 ff 01 00 00       	and    $0x1ff,%eax
801043fd:	89 c2                	mov    %eax,%edx
801043ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104402:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104406:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104408:	ff 45 f4             	incl   -0xc(%ebp)
8010440b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104411:	7c af                	jl     801043c2 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	05 38 02 00 00       	add    $0x238,%eax
8010441b:	89 04 24             	mov    %eax,(%esp)
8010441e:	e8 3f 0b 00 00       	call   80104f62 <wakeup>
  release(&p->lock);
80104423:	8b 45 08             	mov    0x8(%ebp),%eax
80104426:	89 04 24             	mov    %eax,(%esp)
80104429:	e8 b3 11 00 00       	call   801055e1 <release>
  return i;
8010442e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104431:	83 c4 24             	add    $0x24,%esp
80104434:	5b                   	pop    %ebx
80104435:	5d                   	pop    %ebp
80104436:	c3                   	ret    
	...

80104438 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104438:	55                   	push   %ebp
80104439:	89 e5                	mov    %esp,%ebp
8010443b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010443e:	9c                   	pushf  
8010443f:	58                   	pop    %eax
80104440:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104443:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104446:	c9                   	leave  
80104447:	c3                   	ret    

80104448 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104448:	55                   	push   %ebp
80104449:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010444b:	fb                   	sti    
}
8010444c:	5d                   	pop    %ebp
8010444d:	c3                   	ret    

8010444e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010444e:	55                   	push   %ebp
8010444f:	89 e5                	mov    %esp,%ebp
80104451:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104454:	c7 44 24 04 bc 9d 10 	movl   $0x80109dbc,0x4(%esp)
8010445b:	80 
8010445c:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104463:	e8 ee 10 00 00       	call   80105556 <initlock>
}
80104468:	c9                   	leave  
80104469:	c3                   	ret    

8010446a <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010446a:	55                   	push   %ebp
8010446b:	89 e5                	mov    %esp,%ebp
8010446d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104470:	e8 3a 00 00 00       	call   801044af <mycpu>
80104475:	89 c2                	mov    %eax,%edx
80104477:	b8 c0 5c 11 80       	mov    $0x80115cc0,%eax
8010447c:	29 c2                	sub    %eax,%edx
8010447e:	89 d0                	mov    %edx,%eax
80104480:	c1 f8 04             	sar    $0x4,%eax
80104483:	89 c1                	mov    %eax,%ecx
80104485:	89 ca                	mov    %ecx,%edx
80104487:	c1 e2 03             	shl    $0x3,%edx
8010448a:	01 ca                	add    %ecx,%edx
8010448c:	89 d0                	mov    %edx,%eax
8010448e:	c1 e0 05             	shl    $0x5,%eax
80104491:	29 d0                	sub    %edx,%eax
80104493:	c1 e0 02             	shl    $0x2,%eax
80104496:	01 c8                	add    %ecx,%eax
80104498:	c1 e0 03             	shl    $0x3,%eax
8010449b:	01 c8                	add    %ecx,%eax
8010449d:	89 c2                	mov    %eax,%edx
8010449f:	c1 e2 0f             	shl    $0xf,%edx
801044a2:	29 c2                	sub    %eax,%edx
801044a4:	c1 e2 02             	shl    $0x2,%edx
801044a7:	01 ca                	add    %ecx,%edx
801044a9:	89 d0                	mov    %edx,%eax
801044ab:	f7 d8                	neg    %eax
}
801044ad:	c9                   	leave  
801044ae:	c3                   	ret    

801044af <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801044af:	55                   	push   %ebp
801044b0:	89 e5                	mov    %esp,%ebp
801044b2:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801044b5:	e8 7e ff ff ff       	call   80104438 <readeflags>
801044ba:	25 00 02 00 00       	and    $0x200,%eax
801044bf:	85 c0                	test   %eax,%eax
801044c1:	74 0c                	je     801044cf <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801044c3:	c7 04 24 c4 9d 10 80 	movl   $0x80109dc4,(%esp)
801044ca:	e8 85 c0 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801044cf:	e8 15 ee ff ff       	call   801032e9 <lapicid>
801044d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044de:	eb 3b                	jmp    8010451b <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801044e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e3:	89 d0                	mov    %edx,%eax
801044e5:	c1 e0 02             	shl    $0x2,%eax
801044e8:	01 d0                	add    %edx,%eax
801044ea:	01 c0                	add    %eax,%eax
801044ec:	01 d0                	add    %edx,%eax
801044ee:	c1 e0 04             	shl    $0x4,%eax
801044f1:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
801044f6:	8a 00                	mov    (%eax),%al
801044f8:	0f b6 c0             	movzbl %al,%eax
801044fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801044fe:	75 18                	jne    80104518 <mycpu+0x69>
      return &cpus[i];
80104500:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104503:	89 d0                	mov    %edx,%eax
80104505:	c1 e0 02             	shl    $0x2,%eax
80104508:	01 d0                	add    %edx,%eax
8010450a:	01 c0                	add    %eax,%eax
8010450c:	01 d0                	add    %edx,%eax
8010450e:	c1 e0 04             	shl    $0x4,%eax
80104511:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80104516:	eb 19                	jmp    80104531 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104518:	ff 45 f4             	incl   -0xc(%ebp)
8010451b:	a1 40 62 11 80       	mov    0x80116240,%eax
80104520:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104523:	7c bb                	jl     801044e0 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104525:	c7 04 24 ea 9d 10 80 	movl   $0x80109dea,(%esp)
8010452c:	e8 23 c0 ff ff       	call   80100554 <panic>
}
80104531:	c9                   	leave  
80104532:	c3                   	ret    

80104533 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104533:	55                   	push   %ebp
80104534:	89 e5                	mov    %esp,%ebp
80104536:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104539:	e8 98 11 00 00       	call   801056d6 <pushcli>
  c = mycpu();
8010453e:	e8 6c ff ff ff       	call   801044af <mycpu>
80104543:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104549:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010454f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104552:	e8 c9 11 00 00       	call   80105720 <popcli>
  return p;
80104557:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010455a:	c9                   	leave  
8010455b:	c3                   	ret    

8010455c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010455c:	55                   	push   %ebp
8010455d:	89 e5                	mov    %esp,%ebp
8010455f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104562:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104569:	e8 09 10 00 00       	call   80105577 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010456e:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104575:	eb 53                	jmp    801045ca <allocproc+0x6e>
    if(p->state == UNUSED)
80104577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457a:	8b 40 0c             	mov    0xc(%eax),%eax
8010457d:	85 c0                	test   %eax,%eax
8010457f:	75 42                	jne    801045c3 <allocproc+0x67>
      goto found;
80104581:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010458c:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104591:	8d 50 01             	lea    0x1(%eax),%edx
80104594:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
8010459a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459d:	89 42 10             	mov    %eax,0x10(%edx)


  release(&ptable.lock);
801045a0:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801045a7:	e8 35 10 00 00       	call   801055e1 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045ac:	e8 ed e8 ff ff       	call   80102e9e <kalloc>
801045b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b4:	89 42 08             	mov    %eax,0x8(%edx)
801045b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ba:	8b 40 08             	mov    0x8(%eax),%eax
801045bd:	85 c0                	test   %eax,%eax
801045bf:	75 39                	jne    801045fa <allocproc+0x9e>
801045c1:	eb 26                	jmp    801045e9 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045c3:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801045ca:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
801045d1:	72 a4                	jb     80104577 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801045d3:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801045da:	e8 02 10 00 00       	call   801055e1 <release>
  return 0;
801045df:	b8 00 00 00 00       	mov    $0x0,%eax
801045e4:	e9 8d 00 00 00       	jmp    80104676 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801045e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ec:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045f3:	b8 00 00 00 00       	mov    $0x0,%eax
801045f8:	eb 7c                	jmp    80104676 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
801045fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fd:	8b 40 08             	mov    0x8(%eax),%eax
80104600:	05 00 10 00 00       	add    $0x1000,%eax
80104605:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104608:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104612:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104615:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104619:	ba 50 73 10 80       	mov    $0x80107350,%edx
8010461e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104621:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104623:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010462d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104633:	8b 40 1c             	mov    0x1c(%eax),%eax
80104636:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010463d:	00 
8010463e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104645:	00 
80104646:	89 04 24             	mov    %eax,(%esp)
80104649:	e8 8c 11 00 00       	call   801057da <memset>
  p->context->eip = (uint)forkret;
8010464e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104651:	8b 40 1c             	mov    0x1c(%eax),%eax
80104654:	ba 4c 4e 10 80       	mov    $0x80104e4c,%edx
80104659:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465f:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104670:	00 00 00 
  // p->usage = 0;
  return p;
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104676:	c9                   	leave  
80104677:	c3                   	ret    

80104678 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104678:	55                   	push   %ebp
80104679:	89 e5                	mov    %esp,%ebp
8010467b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010467e:	e8 d9 fe ff ff       	call   8010455c <allocproc>
80104683:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104689:	a3 20 d9 10 80       	mov    %eax,0x8010d920
  if((p->pgdir = setupkvm()) == 0)
8010468e:	e8 17 42 00 00       	call   801088aa <setupkvm>
80104693:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104696:	89 42 04             	mov    %eax,0x4(%edx)
80104699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469c:	8b 40 04             	mov    0x4(%eax),%eax
8010469f:	85 c0                	test   %eax,%eax
801046a1:	75 0c                	jne    801046af <userinit+0x37>
    panic("userinit: out of memory?");
801046a3:	c7 04 24 fa 9d 10 80 	movl   $0x80109dfa,(%esp)
801046aa:	e8 a5 be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046af:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	8b 40 04             	mov    0x4(%eax),%eax
801046ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801046be:	c7 44 24 04 60 d5 10 	movl   $0x8010d560,0x4(%esp)
801046c5:	80 
801046c6:	89 04 24             	mov    %eax,(%esp)
801046c9:	e8 3d 44 00 00       	call   80108b0b <inituvm>
  p->sz = PGSIZE;
801046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046da:	8b 40 18             	mov    0x18(%eax),%eax
801046dd:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801046e4:	00 
801046e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801046ec:	00 
801046ed:	89 04 24             	mov    %eax,(%esp)
801046f0:	e8 e5 10 00 00       	call   801057da <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f8:	8b 40 18             	mov    0x18(%eax),%eax
801046fb:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	8b 40 18             	mov    0x18(%eax),%eax
80104707:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104710:	8b 50 18             	mov    0x18(%eax),%edx
80104713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104716:	8b 40 18             	mov    0x18(%eax),%eax
80104719:	8b 40 2c             	mov    0x2c(%eax),%eax
8010471c:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104723:	8b 50 18             	mov    0x18(%eax),%edx
80104726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104729:	8b 40 18             	mov    0x18(%eax),%eax
8010472c:	8b 40 2c             	mov    0x2c(%eax),%eax
8010472f:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104736:	8b 40 18             	mov    0x18(%eax),%eax
80104739:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104743:	8b 40 18             	mov    0x18(%eax),%eax
80104746:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010474d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104750:	8b 40 18             	mov    0x18(%eax),%eax
80104753:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	83 c0 6c             	add    $0x6c,%eax
80104760:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104767:	00 
80104768:	c7 44 24 04 13 9e 10 	movl   $0x80109e13,0x4(%esp)
8010476f:	80 
80104770:	89 04 24             	mov    %eax,(%esp)
80104773:	e8 6e 12 00 00       	call   801059e6 <safestrcpy>
  p->cwd = namei("/");
80104778:	c7 04 24 1c 9e 10 80 	movl   $0x80109e1c,(%esp)
8010477f:	e8 a9 df ff ff       	call   8010272d <namei>
80104784:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104787:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010478a:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104791:	e8 e1 0d 00 00       	call   80105577 <acquire>

  p->state = RUNNABLE;
80104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104799:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047a0:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801047a7:	e8 35 0e 00 00       	call   801055e1 <release>
}
801047ac:	c9                   	leave  
801047ad:	c3                   	ret    

801047ae <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801047ae:	55                   	push   %ebp
801047af:	89 e5                	mov    %esp,%ebp
801047b1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801047b4:	e8 7a fd ff ff       	call   80104533 <myproc>
801047b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801047bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047bf:	8b 00                	mov    (%eax),%eax
801047c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047c8:	7e 31                	jle    801047fb <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047ca:	8b 55 08             	mov    0x8(%ebp),%edx
801047cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d0:	01 c2                	add    %eax,%edx
801047d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047d5:	8b 40 04             	mov    0x4(%eax),%eax
801047d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801047dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047df:	89 54 24 04          	mov    %edx,0x4(%esp)
801047e3:	89 04 24             	mov    %eax,(%esp)
801047e6:	e8 8b 44 00 00       	call   80108c76 <allocuvm>
801047eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047f2:	75 3e                	jne    80104832 <growproc+0x84>
      return -1;
801047f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f9:	eb 4f                	jmp    8010484a <growproc+0x9c>
  } else if(n < 0){
801047fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047ff:	79 31                	jns    80104832 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104801:	8b 55 08             	mov    0x8(%ebp),%edx
80104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104807:	01 c2                	add    %eax,%edx
80104809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010480c:	8b 40 04             	mov    0x4(%eax),%eax
8010480f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104813:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104816:	89 54 24 04          	mov    %edx,0x4(%esp)
8010481a:	89 04 24             	mov    %eax,(%esp)
8010481d:	e8 6a 45 00 00       	call   80108d8c <deallocuvm>
80104822:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104829:	75 07                	jne    80104832 <growproc+0x84>
      return -1;
8010482b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104830:	eb 18                	jmp    8010484a <growproc+0x9c>
  }
  curproc->sz = sz;
80104832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104835:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104838:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010483a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010483d:	89 04 24             	mov    %eax,(%esp)
80104840:	e8 3f 41 00 00       	call   80108984 <switchuvm>
  return 0;
80104845:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010484a:	c9                   	leave  
8010484b:	c3                   	ret    

8010484c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010484c:	55                   	push   %ebp
8010484d:	89 e5                	mov    %esp,%ebp
8010484f:	57                   	push   %edi
80104850:	56                   	push   %esi
80104851:	53                   	push   %ebx
80104852:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104855:	e8 d9 fc ff ff       	call   80104533 <myproc>
8010485a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010485d:	e8 fa fc ff ff       	call   8010455c <allocproc>
80104862:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104865:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104869:	75 0a                	jne    80104875 <fork+0x29>
    return -1;
8010486b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104870:	e9 47 01 00 00       	jmp    801049bc <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104875:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104878:	8b 10                	mov    (%eax),%edx
8010487a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487d:	8b 40 04             	mov    0x4(%eax),%eax
80104880:	89 54 24 04          	mov    %edx,0x4(%esp)
80104884:	89 04 24             	mov    %eax,(%esp)
80104887:	e8 a0 46 00 00       	call   80108f2c <copyuvm>
8010488c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010488f:	89 42 04             	mov    %eax,0x4(%edx)
80104892:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104895:	8b 40 04             	mov    0x4(%eax),%eax
80104898:	85 c0                	test   %eax,%eax
8010489a:	75 2c                	jne    801048c8 <fork+0x7c>
    kfree(np->kstack);
8010489c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010489f:	8b 40 08             	mov    0x8(%eax),%eax
801048a2:	89 04 24             	mov    %eax,(%esp)
801048a5:	e8 05 e5 ff ff       	call   80102daf <kfree>
    np->kstack = 0;
801048aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c3:	e9 f4 00 00 00       	jmp    801049bc <fork+0x170>
  }
  np->sz = curproc->sz;
801048c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048cb:	8b 10                	mov    (%eax),%edx
801048cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d0:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048d8:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048de:	8b 50 18             	mov    0x18(%eax),%edx
801048e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e4:	8b 40 18             	mov    0x18(%eax),%eax
801048e7:	89 c3                	mov    %eax,%ebx
801048e9:	b8 13 00 00 00       	mov    $0x13,%eax
801048ee:	89 d7                	mov    %edx,%edi
801048f0:	89 de                	mov    %ebx,%esi
801048f2:	89 c1                	mov    %eax,%ecx
801048f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f9:	8b 40 18             	mov    0x18(%eax),%eax
801048fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104903:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010490a:	eb 36                	jmp    80104942 <fork+0xf6>
    if(curproc->ofile[i])
8010490c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104912:	83 c2 08             	add    $0x8,%edx
80104915:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104919:	85 c0                	test   %eax,%eax
8010491b:	74 22                	je     8010493f <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010491d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104920:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104923:	83 c2 08             	add    $0x8,%edx
80104926:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010492a:	89 04 24             	mov    %eax,(%esp)
8010492d:	e8 30 c8 ff ff       	call   80101162 <filedup>
80104932:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104935:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104938:	83 c1 08             	add    $0x8,%ecx
8010493b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010493f:	ff 45 e4             	incl   -0x1c(%ebp)
80104942:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104946:	7e c4                	jle    8010490c <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104948:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494b:	8b 40 68             	mov    0x68(%eax),%eax
8010494e:	89 04 24             	mov    %eax,(%esp)
80104951:	e8 3a d1 ff ff       	call   80101a90 <idup>
80104956:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104959:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010495c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010495f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104962:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104965:	83 c0 6c             	add    $0x6c,%eax
80104968:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010496f:	00 
80104970:	89 54 24 04          	mov    %edx,0x4(%esp)
80104974:	89 04 24             	mov    %eax,(%esp)
80104977:	e8 6a 10 00 00       	call   801059e6 <safestrcpy>



  pid = np->pid;
8010497c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010497f:	8b 40 10             	mov    0x10(%eax),%eax
80104982:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104985:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
8010498c:	e8 e6 0b 00 00       	call   80105577 <acquire>

  np->state = RUNNABLE;
80104991:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104994:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
8010499b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010499e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801049a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
801049ad:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801049b4:	e8 28 0c 00 00       	call   801055e1 <release>

  return pid;
801049b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049bc:	83 c4 2c             	add    $0x2c,%esp
801049bf:	5b                   	pop    %ebx
801049c0:	5e                   	pop    %esi
801049c1:	5f                   	pop    %edi
801049c2:	5d                   	pop    %ebp
801049c3:	c3                   	ret    

801049c4 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049c4:	55                   	push   %ebp
801049c5:	89 e5                	mov    %esp,%ebp
801049c7:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801049ca:	e8 64 fb ff ff       	call   80104533 <myproc>
801049cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049d2:	a1 20 d9 10 80       	mov    0x8010d920,%eax
801049d7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801049da:	75 0c                	jne    801049e8 <exit+0x24>
    panic("init exiting");
801049dc:	c7 04 24 1e 9e 10 80 	movl   $0x80109e1e,(%esp)
801049e3:	e8 6c bb ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049ef:	eb 3a                	jmp    80104a2b <exit+0x67>
    if(curproc->ofile[fd]){
801049f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049f7:	83 c2 08             	add    $0x8,%edx
801049fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049fe:	85 c0                	test   %eax,%eax
80104a00:	74 26                	je     80104a28 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104a02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a08:	83 c2 08             	add    $0x8,%edx
80104a0b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a0f:	89 04 24             	mov    %eax,(%esp)
80104a12:	e8 93 c7 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a1d:	83 c2 08             	add    $0x8,%edx
80104a20:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a27:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a28:	ff 45 f0             	incl   -0x10(%ebp)
80104a2b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a2f:	7e c0                	jle    801049f1 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104a31:	e8 fd ed ff ff       	call   80103833 <begin_op>
  iput(curproc->cwd);
80104a36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a39:	8b 40 68             	mov    0x68(%eax),%eax
80104a3c:	89 04 24             	mov    %eax,(%esp)
80104a3f:	e8 cc d1 ff ff       	call   80101c10 <iput>
  end_op();
80104a44:	e8 6c ee ff ff       	call   801038b5 <end_op>
  curproc->cwd = 0;
80104a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a4c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a53:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104a5a:	e8 18 0b 00 00       	call   80105577 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a62:	8b 40 14             	mov    0x14(%eax),%eax
80104a65:	89 04 24             	mov    %eax,(%esp)
80104a68:	e8 b4 04 00 00       	call   80104f21 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6d:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104a74:	eb 36                	jmp    80104aac <exit+0xe8>
    if(p->parent == curproc){
80104a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a79:	8b 40 14             	mov    0x14(%eax),%eax
80104a7c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104a7f:	75 24                	jne    80104aa5 <exit+0xe1>
      p->parent = initproc;
80104a81:	8b 15 20 d9 10 80    	mov    0x8010d920,%edx
80104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a90:	8b 40 0c             	mov    0xc(%eax),%eax
80104a93:	83 f8 05             	cmp    $0x5,%eax
80104a96:	75 0d                	jne    80104aa5 <exit+0xe1>
        wakeup1(initproc);
80104a98:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104a9d:	89 04 24             	mov    %eax,(%esp)
80104aa0:	e8 7c 04 00 00       	call   80104f21 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa5:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104aac:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
80104ab3:	72 c1                	jb     80104a76 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104abf:	e8 a8 02 00 00       	call   80104d6c <sched>
  panic("zombie exit");
80104ac4:	c7 04 24 2b 9e 10 80 	movl   $0x80109e2b,(%esp)
80104acb:	e8 84 ba ff ff       	call   80100554 <panic>

80104ad0 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104ad3:	eb 06                	jmp    80104adb <strcmp1+0xb>
    p++, q++;
80104ad5:	ff 45 08             	incl   0x8(%ebp)
80104ad8:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104adb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ade:	8a 00                	mov    (%eax),%al
80104ae0:	84 c0                	test   %al,%al
80104ae2:	74 0e                	je     80104af2 <strcmp1+0x22>
80104ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae7:	8a 10                	mov    (%eax),%dl
80104ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aec:	8a 00                	mov    (%eax),%al
80104aee:	38 c2                	cmp    %al,%dl
80104af0:	74 e3                	je     80104ad5 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104af2:	8b 45 08             	mov    0x8(%ebp),%eax
80104af5:	8a 00                	mov    (%eax),%al
80104af7:	0f b6 d0             	movzbl %al,%edx
80104afa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afd:	8a 00                	mov    (%eax),%al
80104aff:	0f b6 c0             	movzbl %al,%eax
80104b02:	29 c2                	sub    %eax,%edx
80104b04:	89 d0                	mov    %edx,%eax
}
80104b06:	5d                   	pop    %ebp
80104b07:	c3                   	ret    

80104b08 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b08:	55                   	push   %ebp
80104b09:	89 e5                	mov    %esp,%ebp
80104b0b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b0e:	e8 20 fa ff ff       	call   80104533 <myproc>
80104b13:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b16:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104b1d:	e8 55 0a 00 00       	call   80105577 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b29:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104b30:	e9 98 00 00 00       	jmp    80104bcd <wait+0xc5>
      if(p->parent != curproc)
80104b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b38:	8b 40 14             	mov    0x14(%eax),%eax
80104b3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104b3e:	74 05                	je     80104b45 <wait+0x3d>
        continue;
80104b40:	e9 81 00 00 00       	jmp    80104bc6 <wait+0xbe>
      havekids = 1;
80104b45:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b52:	83 f8 05             	cmp    $0x5,%eax
80104b55:	75 6f                	jne    80104bc6 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5a:	8b 40 10             	mov    0x10(%eax),%eax
80104b5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b63:	8b 40 08             	mov    0x8(%eax),%eax
80104b66:	89 04 24             	mov    %eax,(%esp)
80104b69:	e8 41 e2 ff ff       	call   80102daf <kfree>
        p->kstack = 0;
80104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7b:	8b 40 04             	mov    0x4(%eax),%eax
80104b7e:	89 04 24             	mov    %eax,(%esp)
80104b81:	e8 ca 42 00 00       	call   80108e50 <freevm>
        p->pid = 0;
80104b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b89:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bb5:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104bbc:	e8 20 0a 00 00       	call   801055e1 <release>
        return pid;
80104bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104bc4:	eb 4f                	jmp    80104c15 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc6:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104bcd:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
80104bd4:	0f 82 5b ff ff ff    	jb     80104b35 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104bda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bde:	74 0a                	je     80104bea <wait+0xe2>
80104be0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104be3:	8b 40 24             	mov    0x24(%eax),%eax
80104be6:	85 c0                	test   %eax,%eax
80104be8:	74 13                	je     80104bfd <wait+0xf5>
      release(&ptable.lock);
80104bea:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104bf1:	e8 eb 09 00 00       	call   801055e1 <release>
      return -1;
80104bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfb:	eb 18                	jmp    80104c15 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104bfd:	c7 44 24 04 60 62 11 	movl   $0x80116260,0x4(%esp)
80104c04:	80 
80104c05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c08:	89 04 24             	mov    %eax,(%esp)
80104c0b:	e8 7b 02 00 00       	call   80104e8b <sleep>
  }
80104c10:	e9 0d ff ff ff       	jmp    80104b22 <wait+0x1a>
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c1d:	e8 8d f8 ff ff       	call   801044af <mycpu>
80104c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c28:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c2f:	00 00 00 
  char name[16];
  
  for(;;){
    int x = get_used();
80104c32:	e8 42 46 00 00       	call   80109279 <get_used>
80104c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(holder == x){
80104c3a:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104c3f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104c42:	75 0a                	jne    80104c4e <scheduler+0x37>
      holder = -1;
80104c44:	c7 05 00 d0 10 80 ff 	movl   $0xffffffff,0x8010d000
80104c4b:	ff ff ff 
    }
    if(holder != -1){
80104c4e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104c53:	83 f8 ff             	cmp    $0xffffffff,%eax
80104c56:	74 14                	je     80104c6c <scheduler+0x55>
      get_name(holder, &name[0]);
80104c58:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104c5d:	8d 55 dc             	lea    -0x24(%ebp),%edx
80104c60:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c64:	89 04 24             	mov    %eax,(%esp)
80104c67:	e8 a4 45 00 00       	call   80109210 <get_name>
    }
    sti();
80104c6c:	e8 d7 f7 ff ff       	call   80104448 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c71:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104c78:	e8 fa 08 00 00       	call   80105577 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c7d:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104c84:	e9 ab 00 00 00       	jmp    80104d34 <scheduler+0x11d>
      if(p->state != RUNNABLE)
80104c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8f:	83 f8 03             	cmp    $0x3,%eax
80104c92:	74 05                	je     80104c99 <scheduler+0x82>
        continue;
80104c94:	e9 94 00 00 00       	jmp    80104d2d <scheduler+0x116>
      if(holder == -1){
80104c99:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104c9e:	83 f8 ff             	cmp    $0xffffffff,%eax
80104ca1:	75 0f                	jne    80104cb2 <scheduler+0x9b>
        if(p->cont != NULL){
80104ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cac:	85 c0                	test   %eax,%eax
80104cae:	74 32                	je     80104ce2 <scheduler+0xcb>
          continue;
80104cb0:	eb 7b                	jmp    80104d2d <scheduler+0x116>
        }
      }
      else{
        if(p->cont == NULL){
80104cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cbb:	85 c0                	test   %eax,%eax
80104cbd:	75 02                	jne    80104cc1 <scheduler+0xaa>
          continue;
80104cbf:	eb 6c                	jmp    80104d2d <scheduler+0x116>
        }
        if(strcmp1(p->cont->name, name) != 0){
80104cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cca:	8d 50 18             	lea    0x18(%eax),%edx
80104ccd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cd4:	89 14 24             	mov    %edx,(%esp)
80104cd7:	e8 f4 fd ff ff       	call   80104ad0 <strcmp1>
80104cdc:	85 c0                	test   %eax,%eax
80104cde:	74 02                	je     80104ce2 <scheduler+0xcb>
          continue;
80104ce0:	eb 4b                	jmp    80104d2d <scheduler+0x116>
      }

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ce8:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf1:	89 04 24             	mov    %eax,(%esp)
80104cf4:	e8 8b 3c 00 00       	call   80108984 <switchuvm>
      p->state = RUNNING;
80104cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cfc:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d06:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d0c:	83 c2 04             	add    $0x4,%edx
80104d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d13:	89 14 24             	mov    %edx,(%esp)
80104d16:	e8 39 0d 00 00       	call   80105a54 <swtch>
      switchkvm();
80104d1b:	e8 4a 3c 00 00       	call   8010896a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d23:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d2a:	00 00 00 
    }
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d2d:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104d34:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
80104d3b:	0f 82 48 ff ff ff    	jb     80104c89 <scheduler+0x72>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104d41:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104d48:	e8 94 08 00 00       	call   801055e1 <release>
    p->ticks++;
80104d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d50:	8b 40 7c             	mov    0x7c(%eax),%eax
80104d53:	8d 50 01             	lea    0x1(%eax),%edx
80104d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d59:	89 50 7c             	mov    %edx,0x7c(%eax)
    holder++;
80104d5c:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104d61:	40                   	inc    %eax
80104d62:	a3 00 d0 10 80       	mov    %eax,0x8010d000

  }
80104d67:	e9 c6 fe ff ff       	jmp    80104c32 <scheduler+0x1b>

80104d6c <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d6c:	55                   	push   %ebp
80104d6d:	89 e5                	mov    %esp,%ebp
80104d6f:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104d72:	e8 bc f7 ff ff       	call   80104533 <myproc>
80104d77:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d7a:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104d81:	e8 1f 09 00 00       	call   801056a5 <holding>
80104d86:	85 c0                	test   %eax,%eax
80104d88:	75 0c                	jne    80104d96 <sched+0x2a>
    panic("sched ptable.lock");
80104d8a:	c7 04 24 37 9e 10 80 	movl   $0x80109e37,(%esp)
80104d91:	e8 be b7 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104d96:	e8 14 f7 ff ff       	call   801044af <mycpu>
80104d9b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104da1:	83 f8 01             	cmp    $0x1,%eax
80104da4:	74 0c                	je     80104db2 <sched+0x46>
    panic("sched locks");
80104da6:	c7 04 24 49 9e 10 80 	movl   $0x80109e49,(%esp)
80104dad:	e8 a2 b7 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db5:	8b 40 0c             	mov    0xc(%eax),%eax
80104db8:	83 f8 04             	cmp    $0x4,%eax
80104dbb:	75 0c                	jne    80104dc9 <sched+0x5d>
    panic("sched running");
80104dbd:	c7 04 24 55 9e 10 80 	movl   $0x80109e55,(%esp)
80104dc4:	e8 8b b7 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104dc9:	e8 6a f6 ff ff       	call   80104438 <readeflags>
80104dce:	25 00 02 00 00       	and    $0x200,%eax
80104dd3:	85 c0                	test   %eax,%eax
80104dd5:	74 0c                	je     80104de3 <sched+0x77>
    panic("sched interruptible");
80104dd7:	c7 04 24 63 9e 10 80 	movl   $0x80109e63,(%esp)
80104dde:	e8 71 b7 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104de3:	e8 c7 f6 ff ff       	call   801044af <mycpu>
80104de8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104df1:	e8 b9 f6 ff ff       	call   801044af <mycpu>
80104df6:	8b 40 04             	mov    0x4(%eax),%eax
80104df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dfc:	83 c2 1c             	add    $0x1c,%edx
80104dff:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e03:	89 14 24             	mov    %edx,(%esp)
80104e06:	e8 49 0c 00 00       	call   80105a54 <swtch>
  mycpu()->intena = intena;
80104e0b:	e8 9f f6 ff ff       	call   801044af <mycpu>
80104e10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e13:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e19:	c9                   	leave  
80104e1a:	c3                   	ret    

80104e1b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e1b:	55                   	push   %ebp
80104e1c:	89 e5                	mov    %esp,%ebp
80104e1e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e21:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e28:	e8 4a 07 00 00       	call   80105577 <acquire>
  myproc()->state = RUNNABLE;
80104e2d:	e8 01 f7 ff ff       	call   80104533 <myproc>
80104e32:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e39:	e8 2e ff ff ff       	call   80104d6c <sched>
  release(&ptable.lock);
80104e3e:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e45:	e8 97 07 00 00       	call   801055e1 <release>
}
80104e4a:	c9                   	leave  
80104e4b:	c3                   	ret    

80104e4c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e4c:	55                   	push   %ebp
80104e4d:	89 e5                	mov    %esp,%ebp
80104e4f:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e52:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e59:	e8 83 07 00 00       	call   801055e1 <release>

  if (first) {
80104e5e:	a1 08 d0 10 80       	mov    0x8010d008,%eax
80104e63:	85 c0                	test   %eax,%eax
80104e65:	74 22                	je     80104e89 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e67:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
80104e6e:	00 00 00 
    iinit(ROOTDEV);
80104e71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104e78:	e8 de c8 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104e7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104e84:	e8 ab e7 ff ff       	call   80103634 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e89:	c9                   	leave  
80104e8a:	c3                   	ret    

80104e8b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e8b:	55                   	push   %ebp
80104e8c:	89 e5                	mov    %esp,%ebp
80104e8e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104e91:	e8 9d f6 ff ff       	call   80104533 <myproc>
80104e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e9d:	75 0c                	jne    80104eab <sleep+0x20>
    panic("sleep");
80104e9f:	c7 04 24 77 9e 10 80 	movl   $0x80109e77,(%esp)
80104ea6:	e8 a9 b6 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104eab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104eaf:	75 0c                	jne    80104ebd <sleep+0x32>
    panic("sleep without lk");
80104eb1:	c7 04 24 7d 9e 10 80 	movl   $0x80109e7d,(%esp)
80104eb8:	e8 97 b6 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104ebd:	81 7d 0c 60 62 11 80 	cmpl   $0x80116260,0xc(%ebp)
80104ec4:	74 17                	je     80104edd <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ec6:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104ecd:	e8 a5 06 00 00       	call   80105577 <acquire>
    release(lk);
80104ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed5:	89 04 24             	mov    %eax,(%esp)
80104ed8:	e8 04 07 00 00       	call   801055e1 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee0:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee3:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee9:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ef0:	e8 77 fe ff ff       	call   80104d6c <sched>

  // Tidy up.
  p->chan = 0;
80104ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104eff:	81 7d 0c 60 62 11 80 	cmpl   $0x80116260,0xc(%ebp)
80104f06:	74 17                	je     80104f1f <sleep+0x94>
    release(&ptable.lock);
80104f08:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f0f:	e8 cd 06 00 00       	call   801055e1 <release>
    acquire(lk);
80104f14:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f17:	89 04 24             	mov    %eax,(%esp)
80104f1a:	e8 58 06 00 00       	call   80105577 <acquire>
  }
}
80104f1f:	c9                   	leave  
80104f20:	c3                   	ret    

80104f21 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f21:	55                   	push   %ebp
80104f22:	89 e5                	mov    %esp,%ebp
80104f24:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f27:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
80104f2e:	eb 27                	jmp    80104f57 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f33:	8b 40 0c             	mov    0xc(%eax),%eax
80104f36:	83 f8 02             	cmp    $0x2,%eax
80104f39:	75 15                	jne    80104f50 <wakeup1+0x2f>
80104f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3e:	8b 40 20             	mov    0x20(%eax),%eax
80104f41:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f44:	75 0a                	jne    80104f50 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f49:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f50:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104f57:	81 7d fc 94 84 11 80 	cmpl   $0x80118494,-0x4(%ebp)
80104f5e:	72 d0                	jb     80104f30 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104f60:	c9                   	leave  
80104f61:	c3                   	ret    

80104f62 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f62:	55                   	push   %ebp
80104f63:	89 e5                	mov    %esp,%ebp
80104f65:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f68:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f6f:	e8 03 06 00 00       	call   80105577 <acquire>
  wakeup1(chan);
80104f74:	8b 45 08             	mov    0x8(%ebp),%eax
80104f77:	89 04 24             	mov    %eax,(%esp)
80104f7a:	e8 a2 ff ff ff       	call   80104f21 <wakeup1>
  release(&ptable.lock);
80104f7f:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f86:	e8 56 06 00 00       	call   801055e1 <release>
}
80104f8b:	c9                   	leave  
80104f8c:	c3                   	ret    

80104f8d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f93:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f9a:	e8 d8 05 00 00       	call   80105577 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f9f:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104fa6:	eb 44                	jmp    80104fec <kill+0x5f>
    if(p->pid == pid){
80104fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fab:	8b 40 10             	mov    0x10(%eax),%eax
80104fae:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fb1:	75 32                	jne    80104fe5 <kill+0x58>
      p->killed = 1;
80104fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc0:	8b 40 0c             	mov    0xc(%eax),%eax
80104fc3:	83 f8 02             	cmp    $0x2,%eax
80104fc6:	75 0a                	jne    80104fd2 <kill+0x45>
        p->state = RUNNABLE;
80104fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fd2:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104fd9:	e8 03 06 00 00       	call   801055e1 <release>
      return 0;
80104fde:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe3:	eb 21                	jmp    80105006 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe5:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104fec:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
80104ff3:	72 b3                	jb     80104fa8 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104ff5:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104ffc:	e8 e0 05 00 00       	call   801055e1 <release>
  return -1;
80105001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105006:	c9                   	leave  
80105007:	c3                   	ret    

80105008 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105008:	55                   	push   %ebp
80105009:	89 e5                	mov    %esp,%ebp
8010500b:	53                   	push   %ebx
8010500c:	83 ec 64             	sub    $0x64,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010500f:	c7 45 f0 94 62 11 80 	movl   $0x80116294,-0x10(%ebp)
80105016:	e9 32 01 00 00       	jmp    8010514d <procdump+0x145>
    if(p->state == UNUSED)
8010501b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501e:	8b 40 0c             	mov    0xc(%eax),%eax
80105021:	85 c0                	test   %eax,%eax
80105023:	75 05                	jne    8010502a <procdump+0x22>
      continue;
80105025:	e9 1c 01 00 00       	jmp    80105146 <procdump+0x13e>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010502a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502d:	8b 40 0c             	mov    0xc(%eax),%eax
80105030:	83 f8 05             	cmp    $0x5,%eax
80105033:	77 23                	ja     80105058 <procdump+0x50>
80105035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105038:	8b 40 0c             	mov    0xc(%eax),%eax
8010503b:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105042:	85 c0                	test   %eax,%eax
80105044:	74 12                	je     80105058 <procdump+0x50>
      state = states[p->state];
80105046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105049:	8b 40 0c             	mov    0xc(%eax),%eax
8010504c:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105053:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105056:	eb 07                	jmp    8010505f <procdump+0x57>
    else
      state = "???";
80105058:	c7 45 ec 8e 9e 10 80 	movl   $0x80109e8e,-0x14(%ebp)

    if(p->cont == NULL){
8010505f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105062:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105068:	85 c0                	test   %eax,%eax
8010506a:	75 33                	jne    8010509f <procdump+0x97>
      cprintf("%d root %s %s TICKS: %d", p->pid, state, p->name, p->ticks);
8010506c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506f:	8b 50 7c             	mov    0x7c(%eax),%edx
80105072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105075:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507b:	8b 40 10             	mov    0x10(%eax),%eax
8010507e:	89 54 24 10          	mov    %edx,0x10(%esp)
80105082:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105086:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105089:	89 54 24 08          	mov    %edx,0x8(%esp)
8010508d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105091:	c7 04 24 92 9e 10 80 	movl   $0x80109e92,(%esp)
80105098:	e8 24 b3 ff ff       	call   801003c1 <cprintf>
8010509d:	eb 41                	jmp    801050e0 <procdump+0xd8>
    }
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
8010509f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a2:	8b 50 7c             	mov    0x7c(%eax),%edx
801050a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a8:	8d 58 6c             	lea    0x6c(%eax),%ebx
801050ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ae:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801050b4:	8d 48 18             	lea    0x18(%eax),%ecx
801050b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ba:	8b 40 10             	mov    0x10(%eax),%eax
801050bd:	89 54 24 14          	mov    %edx,0x14(%esp)
801050c1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801050c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
801050cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801050d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801050d4:	c7 04 24 aa 9e 10 80 	movl   $0x80109eaa,(%esp)
801050db:	e8 e1 b2 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
801050e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050e3:	8b 40 0c             	mov    0xc(%eax),%eax
801050e6:	83 f8 02             	cmp    $0x2,%eax
801050e9:	75 4f                	jne    8010513a <procdump+0x132>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801050f1:	8b 40 0c             	mov    0xc(%eax),%eax
801050f4:	83 c0 08             	add    $0x8,%eax
801050f7:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801050fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801050fe:	89 04 24             	mov    %eax,(%esp)
80105101:	e8 28 05 00 00       	call   8010562e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105106:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010510d:	eb 1a                	jmp    80105129 <procdump+0x121>
        cprintf(" %p", pc[i]);
8010510f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105112:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105116:	89 44 24 04          	mov    %eax,0x4(%esp)
8010511a:	c7 04 24 c0 9e 10 80 	movl   $0x80109ec0,(%esp)
80105121:	e8 9b b2 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105126:	ff 45 f4             	incl   -0xc(%ebp)
80105129:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010512d:	7f 0b                	jg     8010513a <procdump+0x132>
8010512f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105132:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105136:	85 c0                	test   %eax,%eax
80105138:	75 d5                	jne    8010510f <procdump+0x107>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010513a:	c7 04 24 c4 9e 10 80 	movl   $0x80109ec4,(%esp)
80105141:	e8 7b b2 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105146:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
8010514d:	81 7d f0 94 84 11 80 	cmpl   $0x80118494,-0x10(%ebp)
80105154:	0f 82 c1 fe ff ff    	jb     8010501b <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010515a:	83 c4 64             	add    $0x64,%esp
8010515d:	5b                   	pop    %ebx
8010515e:	5d                   	pop    %ebp
8010515f:	c3                   	ret    

80105160 <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
80105160:	55                   	push   %ebp
80105161:	89 e5                	mov    %esp,%ebp
80105163:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105166:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
8010516d:	eb 37                	jmp    801051a6 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
8010516f:	8b 45 08             	mov    0x8(%ebp),%eax
80105172:	8d 50 18             	lea    0x18(%eax),%edx
80105175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105178:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010517e:	83 c0 18             	add    $0x18,%eax
80105181:	89 54 24 04          	mov    %edx,0x4(%esp)
80105185:	89 04 24             	mov    %eax,(%esp)
80105188:	e8 43 f9 ff ff       	call   80104ad0 <strcmp1>
8010518d:	85 c0                	test   %eax,%eax
8010518f:	75 0e                	jne    8010519f <cstop_container_helper+0x3f>
      kill(p->pid);
80105191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105194:	8b 40 10             	mov    0x10(%eax),%eax
80105197:	89 04 24             	mov    %eax,(%esp)
8010519a:	e8 ee fd ff ff       	call   80104f8d <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010519f:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801051a6:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
801051ad:	72 c0                	jb     8010516f <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
801051af:	8b 45 08             	mov    0x8(%ebp),%eax
801051b2:	83 c0 18             	add    $0x18,%eax
801051b5:	89 04 24             	mov    %eax,(%esp)
801051b8:	e8 8e 41 00 00       	call   8010934b <find>
801051bd:	89 04 24             	mov    %eax,(%esp)
801051c0:	e8 78 47 00 00       	call   8010993d <container_reset>
}
801051c5:	c9                   	leave  
801051c6:	c3                   	ret    

801051c7 <cstop_helper>:

void cstop_helper(char* name){
801051c7:	55                   	push   %ebp
801051c8:	89 e5                	mov    %esp,%ebp
801051ca:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051cd:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
801051d4:	eb 69                	jmp    8010523f <cstop_helper+0x78>

    if(p->cont == NULL){
801051d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051df:	85 c0                	test   %eax,%eax
801051e1:	75 02                	jne    801051e5 <cstop_helper+0x1e>
      continue;
801051e3:	eb 53                	jmp    80105238 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
801051e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051ee:	8d 50 18             	lea    0x18(%eax),%edx
801051f1:	8b 45 08             	mov    0x8(%ebp),%eax
801051f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f8:	89 14 24             	mov    %edx,(%esp)
801051fb:	e8 d0 f8 ff ff       	call   80104ad0 <strcmp1>
80105200:	85 c0                	test   %eax,%eax
80105202:	75 34                	jne    80105238 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80105204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105207:	8b 40 10             	mov    0x10(%eax),%eax
8010520a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010520d:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
80105213:	83 c2 18             	add    $0x18,%edx
80105216:	89 44 24 08          	mov    %eax,0x8(%esp)
8010521a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010521e:	c7 04 24 c8 9e 10 80 	movl   $0x80109ec8,(%esp)
80105225:	e8 97 b1 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
8010522a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010522d:	8b 40 10             	mov    0x10(%eax),%eax
80105230:	89 04 24             	mov    %eax,(%esp)
80105233:	e8 55 fd ff ff       	call   80104f8d <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105238:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010523f:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
80105246:	72 8e                	jb     801051d6 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
80105248:	8b 45 08             	mov    0x8(%ebp),%eax
8010524b:	89 04 24             	mov    %eax,(%esp)
8010524e:	e8 f8 40 00 00       	call   8010934b <find>
80105253:	89 04 24             	mov    %eax,(%esp)
80105256:	e8 e2 46 00 00       	call   8010993d <container_reset>
}
8010525b:	c9                   	leave  
8010525c:	c3                   	ret    

8010525d <c_procdump>:

void
c_procdump(char* name)
{
8010525d:	55                   	push   %ebp
8010525e:	89 e5                	mov    %esp,%ebp
80105260:	53                   	push   %ebx
80105261:	83 ec 34             	sub    $0x34,%esp
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105264:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
8010526b:	e9 c5 00 00 00       	jmp    80105335 <c_procdump+0xd8>
    if(p->state == UNUSED || p->cont == NULL)
80105270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105273:	8b 40 0c             	mov    0xc(%eax),%eax
80105276:	85 c0                	test   %eax,%eax
80105278:	74 0d                	je     80105287 <c_procdump+0x2a>
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105283:	85 c0                	test   %eax,%eax
80105285:	75 05                	jne    8010528c <c_procdump+0x2f>
      continue;
80105287:	e9 a2 00 00 00       	jmp    8010532e <c_procdump+0xd1>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010528c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528f:	8b 40 0c             	mov    0xc(%eax),%eax
80105292:	83 f8 05             	cmp    $0x5,%eax
80105295:	77 23                	ja     801052ba <c_procdump+0x5d>
80105297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529a:	8b 40 0c             	mov    0xc(%eax),%eax
8010529d:	8b 04 85 24 d0 10 80 	mov    -0x7fef2fdc(,%eax,4),%eax
801052a4:	85 c0                	test   %eax,%eax
801052a6:	74 12                	je     801052ba <c_procdump+0x5d>
      state = states[p->state];
801052a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ab:	8b 40 0c             	mov    0xc(%eax),%eax
801052ae:	8b 04 85 24 d0 10 80 	mov    -0x7fef2fdc(,%eax,4),%eax
801052b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801052b8:	eb 07                	jmp    801052c1 <c_procdump+0x64>
    else
      state = "???";
801052ba:	c7 45 f0 8e 9e 10 80 	movl   $0x80109e8e,-0x10(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
801052c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052ca:	8d 50 18             	lea    0x18(%eax),%edx
801052cd:	8b 45 08             	mov    0x8(%ebp),%eax
801052d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801052d4:	89 14 24             	mov    %edx,(%esp)
801052d7:	e8 f4 f7 ff ff       	call   80104ad0 <strcmp1>
801052dc:	85 c0                	test   %eax,%eax
801052de:	75 4e                	jne    8010532e <c_procdump+0xd1>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d Usage: %d", 
801052e0:	8b 0d e0 8c 11 80    	mov    0x80118ce0,%ecx
801052e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e9:	8b 50 7c             	mov    0x7c(%eax),%edx
801052ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ef:	8b 40 10             	mov    0x10(%eax),%eax
        name, p->name, p->pid, state, p->ticks, ticks);
801052f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801052f5:	83 c3 6c             	add    $0x6c,%ebx
      state = states[p->state];
    else
      state = "???";

    if(strcmp1(p->cont->name, name) == 0){
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d Usage: %d", 
801052f8:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801052fc:	89 54 24 14          	mov    %edx,0x14(%esp)
80105300:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105303:	89 54 24 10          	mov    %edx,0x10(%esp)
80105307:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010530b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010530f:	8b 45 08             	mov    0x8(%ebp),%eax
80105312:	89 44 24 04          	mov    %eax,0x4(%esp)
80105316:	c7 04 24 e8 9e 10 80 	movl   $0x80109ee8,(%esp)
8010531d:	e8 9f b0 ff ff       	call   801003c1 <cprintf>
        name, p->name, p->pid, state, p->ticks, ticks);
      cprintf("\n");
80105322:	c7 04 24 c4 9e 10 80 	movl   $0x80109ec4,(%esp)
80105329:	e8 93 b0 ff ff       	call   801003c1 <cprintf>
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010532e:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105335:	81 7d f4 94 84 11 80 	cmpl   $0x80118494,-0xc(%ebp)
8010533c:	0f 82 2e ff ff ff    	jb     80105270 <c_procdump+0x13>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d Usage: %d", 
        name, p->name, p->pid, state, p->ticks, ticks);
      cprintf("\n");
    }  
  }
}
80105342:	83 c4 34             	add    $0x34,%esp
80105345:	5b                   	pop    %ebx
80105346:	5d                   	pop    %ebp
80105347:	c3                   	ret    

80105348 <pause>:

void
pause(char* name)
{
80105348:	55                   	push   %ebp
80105349:	89 e5                	mov    %esp,%ebp
8010534b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010534e:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
80105355:	eb 49                	jmp    801053a0 <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
80105357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010535a:	8b 40 0c             	mov    0xc(%eax),%eax
8010535d:	85 c0                	test   %eax,%eax
8010535f:	74 0d                	je     8010536e <pause+0x26>
80105361:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105364:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010536a:	85 c0                	test   %eax,%eax
8010536c:	75 02                	jne    80105370 <pause+0x28>
      continue;
8010536e:	eb 29                	jmp    80105399 <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
80105370:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105373:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105379:	8d 50 18             	lea    0x18(%eax),%edx
8010537c:	8b 45 08             	mov    0x8(%ebp),%eax
8010537f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105383:	89 14 24             	mov    %edx,(%esp)
80105386:	e8 45 f7 ff ff       	call   80104ad0 <strcmp1>
8010538b:	85 c0                	test   %eax,%eax
8010538d:	75 0a                	jne    80105399 <pause+0x51>
      p->state = ZOMBIE;
8010538f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105392:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105399:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
801053a0:	81 7d fc 94 84 11 80 	cmpl   $0x80118494,-0x4(%ebp)
801053a7:	72 ae                	jb     80105357 <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = ZOMBIE;
    }
  }
}
801053a9:	c9                   	leave  
801053aa:	c3                   	ret    

801053ab <resume>:

void
resume(char* name)
{
801053ab:	55                   	push   %ebp
801053ac:	89 e5                	mov    %esp,%ebp
801053ae:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053b1:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
801053b8:	eb 3b                	jmp    801053f5 <resume+0x4a>
    if(p->state == ZOMBIE){
801053ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053bd:	8b 40 0c             	mov    0xc(%eax),%eax
801053c0:	83 f8 05             	cmp    $0x5,%eax
801053c3:	75 29                	jne    801053ee <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
801053c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801053ce:	8d 50 18             	lea    0x18(%eax),%edx
801053d1:	8b 45 08             	mov    0x8(%ebp),%eax
801053d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801053d8:	89 14 24             	mov    %edx,(%esp)
801053db:	e8 f0 f6 ff ff       	call   80104ad0 <strcmp1>
801053e0:	85 c0                	test   %eax,%eax
801053e2:	75 0a                	jne    801053ee <resume+0x43>
        p->state = RUNNABLE;
801053e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053ee:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
801053f5:	81 7d fc 94 84 11 80 	cmpl   $0x80118494,-0x4(%ebp)
801053fc:	72 bc                	jb     801053ba <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
801053fe:	c9                   	leave  
801053ff:	c3                   	ret    

80105400 <initp>:


struct proc* initp(void){
80105400:	55                   	push   %ebp
80105401:	89 e5                	mov    %esp,%ebp
  return initproc;
80105403:	a1 20 d9 10 80       	mov    0x8010d920,%eax
}
80105408:	5d                   	pop    %ebp
80105409:	c3                   	ret    

8010540a <c_proc>:

struct proc* c_proc(void){
8010540a:	55                   	push   %ebp
8010540b:	89 e5                	mov    %esp,%ebp
8010540d:	83 ec 08             	sub    $0x8,%esp
  return myproc();
80105410:	e8 1e f1 ff ff       	call   80104533 <myproc>
}
80105415:	c9                   	leave  
80105416:	c3                   	ret    
	...

80105418 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105418:	55                   	push   %ebp
80105419:	89 e5                	mov    %esp,%ebp
8010541b:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010541e:	8b 45 08             	mov    0x8(%ebp),%eax
80105421:	83 c0 04             	add    $0x4,%eax
80105424:	c7 44 24 04 57 9f 10 	movl   $0x80109f57,0x4(%esp)
8010542b:	80 
8010542c:	89 04 24             	mov    %eax,(%esp)
8010542f:	e8 22 01 00 00       	call   80105556 <initlock>
  lk->name = name;
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
80105437:	8b 55 0c             	mov    0xc(%ebp),%edx
8010543a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010543d:	8b 45 08             	mov    0x8(%ebp),%eax
80105440:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105446:	8b 45 08             	mov    0x8(%ebp),%eax
80105449:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105450:	c9                   	leave  
80105451:	c3                   	ret    

80105452 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105452:	55                   	push   %ebp
80105453:	89 e5                	mov    %esp,%ebp
80105455:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105458:	8b 45 08             	mov    0x8(%ebp),%eax
8010545b:	83 c0 04             	add    $0x4,%eax
8010545e:	89 04 24             	mov    %eax,(%esp)
80105461:	e8 11 01 00 00       	call   80105577 <acquire>
  while (lk->locked) {
80105466:	eb 15                	jmp    8010547d <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105468:	8b 45 08             	mov    0x8(%ebp),%eax
8010546b:	83 c0 04             	add    $0x4,%eax
8010546e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105472:	8b 45 08             	mov    0x8(%ebp),%eax
80105475:	89 04 24             	mov    %eax,(%esp)
80105478:	e8 0e fa ff ff       	call   80104e8b <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
8010547d:	8b 45 08             	mov    0x8(%ebp),%eax
80105480:	8b 00                	mov    (%eax),%eax
80105482:	85 c0                	test   %eax,%eax
80105484:	75 e2                	jne    80105468 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80105486:	8b 45 08             	mov    0x8(%ebp),%eax
80105489:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010548f:	e8 9f f0 ff ff       	call   80104533 <myproc>
80105494:	8b 50 10             	mov    0x10(%eax),%edx
80105497:	8b 45 08             	mov    0x8(%ebp),%eax
8010549a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010549d:	8b 45 08             	mov    0x8(%ebp),%eax
801054a0:	83 c0 04             	add    $0x4,%eax
801054a3:	89 04 24             	mov    %eax,(%esp)
801054a6:	e8 36 01 00 00       	call   801055e1 <release>
}
801054ab:	c9                   	leave  
801054ac:	c3                   	ret    

801054ad <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801054ad:	55                   	push   %ebp
801054ae:	89 e5                	mov    %esp,%ebp
801054b0:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801054b3:	8b 45 08             	mov    0x8(%ebp),%eax
801054b6:	83 c0 04             	add    $0x4,%eax
801054b9:	89 04 24             	mov    %eax,(%esp)
801054bc:	e8 b6 00 00 00       	call   80105577 <acquire>
  lk->locked = 0;
801054c1:	8b 45 08             	mov    0x8(%ebp),%eax
801054c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801054ca:	8b 45 08             	mov    0x8(%ebp),%eax
801054cd:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801054d4:	8b 45 08             	mov    0x8(%ebp),%eax
801054d7:	89 04 24             	mov    %eax,(%esp)
801054da:	e8 83 fa ff ff       	call   80104f62 <wakeup>
  release(&lk->lk);
801054df:	8b 45 08             	mov    0x8(%ebp),%eax
801054e2:	83 c0 04             	add    $0x4,%eax
801054e5:	89 04 24             	mov    %eax,(%esp)
801054e8:	e8 f4 00 00 00       	call   801055e1 <release>
}
801054ed:	c9                   	leave  
801054ee:	c3                   	ret    

801054ef <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801054ef:	55                   	push   %ebp
801054f0:	89 e5                	mov    %esp,%ebp
801054f2:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801054f5:	8b 45 08             	mov    0x8(%ebp),%eax
801054f8:	83 c0 04             	add    $0x4,%eax
801054fb:	89 04 24             	mov    %eax,(%esp)
801054fe:	e8 74 00 00 00       	call   80105577 <acquire>
  r = lk->locked;
80105503:	8b 45 08             	mov    0x8(%ebp),%eax
80105506:	8b 00                	mov    (%eax),%eax
80105508:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010550b:	8b 45 08             	mov    0x8(%ebp),%eax
8010550e:	83 c0 04             	add    $0x4,%eax
80105511:	89 04 24             	mov    %eax,(%esp)
80105514:	e8 c8 00 00 00       	call   801055e1 <release>
  return r;
80105519:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010551c:	c9                   	leave  
8010551d:	c3                   	ret    
	...

80105520 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105520:	55                   	push   %ebp
80105521:	89 e5                	mov    %esp,%ebp
80105523:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105526:	9c                   	pushf  
80105527:	58                   	pop    %eax
80105528:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010552b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552e:	c9                   	leave  
8010552f:	c3                   	ret    

80105530 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105530:	55                   	push   %ebp
80105531:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105533:	fa                   	cli    
}
80105534:	5d                   	pop    %ebp
80105535:	c3                   	ret    

80105536 <sti>:

static inline void
sti(void)
{
80105536:	55                   	push   %ebp
80105537:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105539:	fb                   	sti    
}
8010553a:	5d                   	pop    %ebp
8010553b:	c3                   	ret    

8010553c <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010553c:	55                   	push   %ebp
8010553d:	89 e5                	mov    %esp,%ebp
8010553f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105542:	8b 55 08             	mov    0x8(%ebp),%edx
80105545:	8b 45 0c             	mov    0xc(%ebp),%eax
80105548:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010554b:	f0 87 02             	lock xchg %eax,(%edx)
8010554e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105551:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105554:	c9                   	leave  
80105555:	c3                   	ret    

80105556 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105556:	55                   	push   %ebp
80105557:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105559:	8b 45 08             	mov    0x8(%ebp),%eax
8010555c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010555f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105562:	8b 45 08             	mov    0x8(%ebp),%eax
80105565:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010556b:	8b 45 08             	mov    0x8(%ebp),%eax
8010556e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105575:	5d                   	pop    %ebp
80105576:	c3                   	ret    

80105577 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105577:	55                   	push   %ebp
80105578:	89 e5                	mov    %esp,%ebp
8010557a:	53                   	push   %ebx
8010557b:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010557e:	e8 53 01 00 00       	call   801056d6 <pushcli>
  if(holding(lk))
80105583:	8b 45 08             	mov    0x8(%ebp),%eax
80105586:	89 04 24             	mov    %eax,(%esp)
80105589:	e8 17 01 00 00       	call   801056a5 <holding>
8010558e:	85 c0                	test   %eax,%eax
80105590:	74 0c                	je     8010559e <acquire+0x27>
    panic("acquire");
80105592:	c7 04 24 62 9f 10 80 	movl   $0x80109f62,(%esp)
80105599:	e8 b6 af ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010559e:	90                   	nop
8010559f:	8b 45 08             	mov    0x8(%ebp),%eax
801055a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801055a9:	00 
801055aa:	89 04 24             	mov    %eax,(%esp)
801055ad:	e8 8a ff ff ff       	call   8010553c <xchg>
801055b2:	85 c0                	test   %eax,%eax
801055b4:	75 e9                	jne    8010559f <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801055b6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801055bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
801055be:	e8 ec ee ff ff       	call   801044af <mycpu>
801055c3:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801055c6:	8b 45 08             	mov    0x8(%ebp),%eax
801055c9:	83 c0 0c             	add    $0xc,%eax
801055cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801055d0:	8d 45 08             	lea    0x8(%ebp),%eax
801055d3:	89 04 24             	mov    %eax,(%esp)
801055d6:	e8 53 00 00 00       	call   8010562e <getcallerpcs>
}
801055db:	83 c4 14             	add    $0x14,%esp
801055de:	5b                   	pop    %ebx
801055df:	5d                   	pop    %ebp
801055e0:	c3                   	ret    

801055e1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801055e7:	8b 45 08             	mov    0x8(%ebp),%eax
801055ea:	89 04 24             	mov    %eax,(%esp)
801055ed:	e8 b3 00 00 00       	call   801056a5 <holding>
801055f2:	85 c0                	test   %eax,%eax
801055f4:	75 0c                	jne    80105602 <release+0x21>
    panic("release");
801055f6:	c7 04 24 6a 9f 10 80 	movl   $0x80109f6a,(%esp)
801055fd:	e8 52 af ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80105602:	8b 45 08             	mov    0x8(%ebp),%eax
80105605:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010560c:	8b 45 08             	mov    0x8(%ebp),%eax
8010560f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105616:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010561b:	8b 45 08             	mov    0x8(%ebp),%eax
8010561e:	8b 55 08             	mov    0x8(%ebp),%edx
80105621:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105627:	e8 f4 00 00 00       	call   80105720 <popcli>
}
8010562c:	c9                   	leave  
8010562d:	c3                   	ret    

8010562e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010562e:	55                   	push   %ebp
8010562f:	89 e5                	mov    %esp,%ebp
80105631:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105634:	8b 45 08             	mov    0x8(%ebp),%eax
80105637:	83 e8 08             	sub    $0x8,%eax
8010563a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010563d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105644:	eb 37                	jmp    8010567d <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105646:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010564a:	74 37                	je     80105683 <getcallerpcs+0x55>
8010564c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105653:	76 2e                	jbe    80105683 <getcallerpcs+0x55>
80105655:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105659:	74 28                	je     80105683 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010565b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105665:	8b 45 0c             	mov    0xc(%ebp),%eax
80105668:	01 c2                	add    %eax,%edx
8010566a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010566d:	8b 40 04             	mov    0x4(%eax),%eax
80105670:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105672:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105675:	8b 00                	mov    (%eax),%eax
80105677:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010567a:	ff 45 f8             	incl   -0x8(%ebp)
8010567d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105681:	7e c3                	jle    80105646 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105683:	eb 18                	jmp    8010569d <getcallerpcs+0x6f>
    pcs[i] = 0;
80105685:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105688:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010568f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105692:	01 d0                	add    %edx,%eax
80105694:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010569a:	ff 45 f8             	incl   -0x8(%ebp)
8010569d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801056a1:	7e e2                	jle    80105685 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801056a3:	c9                   	leave  
801056a4:	c3                   	ret    

801056a5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801056a5:	55                   	push   %ebp
801056a6:	89 e5                	mov    %esp,%ebp
801056a8:	53                   	push   %ebx
801056a9:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801056ac:	8b 45 08             	mov    0x8(%ebp),%eax
801056af:	8b 00                	mov    (%eax),%eax
801056b1:	85 c0                	test   %eax,%eax
801056b3:	74 16                	je     801056cb <holding+0x26>
801056b5:	8b 45 08             	mov    0x8(%ebp),%eax
801056b8:	8b 58 08             	mov    0x8(%eax),%ebx
801056bb:	e8 ef ed ff ff       	call   801044af <mycpu>
801056c0:	39 c3                	cmp    %eax,%ebx
801056c2:	75 07                	jne    801056cb <holding+0x26>
801056c4:	b8 01 00 00 00       	mov    $0x1,%eax
801056c9:	eb 05                	jmp    801056d0 <holding+0x2b>
801056cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056d0:	83 c4 04             	add    $0x4,%esp
801056d3:	5b                   	pop    %ebx
801056d4:	5d                   	pop    %ebp
801056d5:	c3                   	ret    

801056d6 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801056d6:	55                   	push   %ebp
801056d7:	89 e5                	mov    %esp,%ebp
801056d9:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801056dc:	e8 3f fe ff ff       	call   80105520 <readeflags>
801056e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801056e4:	e8 47 fe ff ff       	call   80105530 <cli>
  if(mycpu()->ncli == 0)
801056e9:	e8 c1 ed ff ff       	call   801044af <mycpu>
801056ee:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056f4:	85 c0                	test   %eax,%eax
801056f6:	75 14                	jne    8010570c <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801056f8:	e8 b2 ed ff ff       	call   801044af <mycpu>
801056fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105700:	81 e2 00 02 00 00    	and    $0x200,%edx
80105706:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010570c:	e8 9e ed ff ff       	call   801044af <mycpu>
80105711:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105717:	42                   	inc    %edx
80105718:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010571e:	c9                   	leave  
8010571f:	c3                   	ret    

80105720 <popcli>:

void
popcli(void)
{
80105720:	55                   	push   %ebp
80105721:	89 e5                	mov    %esp,%ebp
80105723:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105726:	e8 f5 fd ff ff       	call   80105520 <readeflags>
8010572b:	25 00 02 00 00       	and    $0x200,%eax
80105730:	85 c0                	test   %eax,%eax
80105732:	74 0c                	je     80105740 <popcli+0x20>
    panic("popcli - interruptible");
80105734:	c7 04 24 72 9f 10 80 	movl   $0x80109f72,(%esp)
8010573b:	e8 14 ae ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105740:	e8 6a ed ff ff       	call   801044af <mycpu>
80105745:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010574b:	4a                   	dec    %edx
8010574c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105752:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105758:	85 c0                	test   %eax,%eax
8010575a:	79 0c                	jns    80105768 <popcli+0x48>
    panic("popcli");
8010575c:	c7 04 24 89 9f 10 80 	movl   $0x80109f89,(%esp)
80105763:	e8 ec ad ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105768:	e8 42 ed ff ff       	call   801044af <mycpu>
8010576d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105773:	85 c0                	test   %eax,%eax
80105775:	75 14                	jne    8010578b <popcli+0x6b>
80105777:	e8 33 ed ff ff       	call   801044af <mycpu>
8010577c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105782:	85 c0                	test   %eax,%eax
80105784:	74 05                	je     8010578b <popcli+0x6b>
    sti();
80105786:	e8 ab fd ff ff       	call   80105536 <sti>
}
8010578b:	c9                   	leave  
8010578c:	c3                   	ret    
8010578d:	00 00                	add    %al,(%eax)
	...

80105790 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105790:	55                   	push   %ebp
80105791:	89 e5                	mov    %esp,%ebp
80105793:	57                   	push   %edi
80105794:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105795:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105798:	8b 55 10             	mov    0x10(%ebp),%edx
8010579b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010579e:	89 cb                	mov    %ecx,%ebx
801057a0:	89 df                	mov    %ebx,%edi
801057a2:	89 d1                	mov    %edx,%ecx
801057a4:	fc                   	cld    
801057a5:	f3 aa                	rep stos %al,%es:(%edi)
801057a7:	89 ca                	mov    %ecx,%edx
801057a9:	89 fb                	mov    %edi,%ebx
801057ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
801057ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801057b1:	5b                   	pop    %ebx
801057b2:	5f                   	pop    %edi
801057b3:	5d                   	pop    %ebp
801057b4:	c3                   	ret    

801057b5 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801057b5:	55                   	push   %ebp
801057b6:	89 e5                	mov    %esp,%ebp
801057b8:	57                   	push   %edi
801057b9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801057ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057bd:	8b 55 10             	mov    0x10(%ebp),%edx
801057c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801057c3:	89 cb                	mov    %ecx,%ebx
801057c5:	89 df                	mov    %ebx,%edi
801057c7:	89 d1                	mov    %edx,%ecx
801057c9:	fc                   	cld    
801057ca:	f3 ab                	rep stos %eax,%es:(%edi)
801057cc:	89 ca                	mov    %ecx,%edx
801057ce:	89 fb                	mov    %edi,%ebx
801057d0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801057d3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801057d6:	5b                   	pop    %ebx
801057d7:	5f                   	pop    %edi
801057d8:	5d                   	pop    %ebp
801057d9:	c3                   	ret    

801057da <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801057da:	55                   	push   %ebp
801057db:	89 e5                	mov    %esp,%ebp
801057dd:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801057e0:	8b 45 08             	mov    0x8(%ebp),%eax
801057e3:	83 e0 03             	and    $0x3,%eax
801057e6:	85 c0                	test   %eax,%eax
801057e8:	75 49                	jne    80105833 <memset+0x59>
801057ea:	8b 45 10             	mov    0x10(%ebp),%eax
801057ed:	83 e0 03             	and    $0x3,%eax
801057f0:	85 c0                	test   %eax,%eax
801057f2:	75 3f                	jne    80105833 <memset+0x59>
    c &= 0xFF;
801057f4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801057fb:	8b 45 10             	mov    0x10(%ebp),%eax
801057fe:	c1 e8 02             	shr    $0x2,%eax
80105801:	89 c2                	mov    %eax,%edx
80105803:	8b 45 0c             	mov    0xc(%ebp),%eax
80105806:	c1 e0 18             	shl    $0x18,%eax
80105809:	89 c1                	mov    %eax,%ecx
8010580b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010580e:	c1 e0 10             	shl    $0x10,%eax
80105811:	09 c1                	or     %eax,%ecx
80105813:	8b 45 0c             	mov    0xc(%ebp),%eax
80105816:	c1 e0 08             	shl    $0x8,%eax
80105819:	09 c8                	or     %ecx,%eax
8010581b:	0b 45 0c             	or     0xc(%ebp),%eax
8010581e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105822:	89 44 24 04          	mov    %eax,0x4(%esp)
80105826:	8b 45 08             	mov    0x8(%ebp),%eax
80105829:	89 04 24             	mov    %eax,(%esp)
8010582c:	e8 84 ff ff ff       	call   801057b5 <stosl>
80105831:	eb 19                	jmp    8010584c <memset+0x72>
  } else
    stosb(dst, c, n);
80105833:	8b 45 10             	mov    0x10(%ebp),%eax
80105836:	89 44 24 08          	mov    %eax,0x8(%esp)
8010583a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010583d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105841:	8b 45 08             	mov    0x8(%ebp),%eax
80105844:	89 04 24             	mov    %eax,(%esp)
80105847:	e8 44 ff ff ff       	call   80105790 <stosb>
  return dst;
8010584c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010584f:	c9                   	leave  
80105850:	c3                   	ret    

80105851 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105851:	55                   	push   %ebp
80105852:	89 e5                	mov    %esp,%ebp
80105854:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105857:	8b 45 08             	mov    0x8(%ebp),%eax
8010585a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010585d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105860:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105863:	eb 2a                	jmp    8010588f <memcmp+0x3e>
    if(*s1 != *s2)
80105865:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105868:	8a 10                	mov    (%eax),%dl
8010586a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010586d:	8a 00                	mov    (%eax),%al
8010586f:	38 c2                	cmp    %al,%dl
80105871:	74 16                	je     80105889 <memcmp+0x38>
      return *s1 - *s2;
80105873:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105876:	8a 00                	mov    (%eax),%al
80105878:	0f b6 d0             	movzbl %al,%edx
8010587b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010587e:	8a 00                	mov    (%eax),%al
80105880:	0f b6 c0             	movzbl %al,%eax
80105883:	29 c2                	sub    %eax,%edx
80105885:	89 d0                	mov    %edx,%eax
80105887:	eb 18                	jmp    801058a1 <memcmp+0x50>
    s1++, s2++;
80105889:	ff 45 fc             	incl   -0x4(%ebp)
8010588c:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010588f:	8b 45 10             	mov    0x10(%ebp),%eax
80105892:	8d 50 ff             	lea    -0x1(%eax),%edx
80105895:	89 55 10             	mov    %edx,0x10(%ebp)
80105898:	85 c0                	test   %eax,%eax
8010589a:	75 c9                	jne    80105865 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010589c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058a1:	c9                   	leave  
801058a2:	c3                   	ret    

801058a3 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801058a3:	55                   	push   %ebp
801058a4:	89 e5                	mov    %esp,%ebp
801058a6:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801058a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801058af:	8b 45 08             	mov    0x8(%ebp),%eax
801058b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801058b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058bb:	73 3a                	jae    801058f7 <memmove+0x54>
801058bd:	8b 45 10             	mov    0x10(%ebp),%eax
801058c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058c3:	01 d0                	add    %edx,%eax
801058c5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058c8:	76 2d                	jbe    801058f7 <memmove+0x54>
    s += n;
801058ca:	8b 45 10             	mov    0x10(%ebp),%eax
801058cd:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801058d0:	8b 45 10             	mov    0x10(%ebp),%eax
801058d3:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801058d6:	eb 10                	jmp    801058e8 <memmove+0x45>
      *--d = *--s;
801058d8:	ff 4d f8             	decl   -0x8(%ebp)
801058db:	ff 4d fc             	decl   -0x4(%ebp)
801058de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058e1:	8a 10                	mov    (%eax),%dl
801058e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058e6:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801058e8:	8b 45 10             	mov    0x10(%ebp),%eax
801058eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801058ee:	89 55 10             	mov    %edx,0x10(%ebp)
801058f1:	85 c0                	test   %eax,%eax
801058f3:	75 e3                	jne    801058d8 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801058f5:	eb 25                	jmp    8010591c <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801058f7:	eb 16                	jmp    8010590f <memmove+0x6c>
      *d++ = *s++;
801058f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058fc:	8d 50 01             	lea    0x1(%eax),%edx
801058ff:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105902:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105905:	8d 4a 01             	lea    0x1(%edx),%ecx
80105908:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010590b:	8a 12                	mov    (%edx),%dl
8010590d:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010590f:	8b 45 10             	mov    0x10(%ebp),%eax
80105912:	8d 50 ff             	lea    -0x1(%eax),%edx
80105915:	89 55 10             	mov    %edx,0x10(%ebp)
80105918:	85 c0                	test   %eax,%eax
8010591a:	75 dd                	jne    801058f9 <memmove+0x56>
      *d++ = *s++;

  return dst;
8010591c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010591f:	c9                   	leave  
80105920:	c3                   	ret    

80105921 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105921:	55                   	push   %ebp
80105922:	89 e5                	mov    %esp,%ebp
80105924:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105927:	8b 45 10             	mov    0x10(%ebp),%eax
8010592a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010592e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105931:	89 44 24 04          	mov    %eax,0x4(%esp)
80105935:	8b 45 08             	mov    0x8(%ebp),%eax
80105938:	89 04 24             	mov    %eax,(%esp)
8010593b:	e8 63 ff ff ff       	call   801058a3 <memmove>
}
80105940:	c9                   	leave  
80105941:	c3                   	ret    

80105942 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105942:	55                   	push   %ebp
80105943:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105945:	eb 09                	jmp    80105950 <strncmp+0xe>
    n--, p++, q++;
80105947:	ff 4d 10             	decl   0x10(%ebp)
8010594a:	ff 45 08             	incl   0x8(%ebp)
8010594d:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105950:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105954:	74 17                	je     8010596d <strncmp+0x2b>
80105956:	8b 45 08             	mov    0x8(%ebp),%eax
80105959:	8a 00                	mov    (%eax),%al
8010595b:	84 c0                	test   %al,%al
8010595d:	74 0e                	je     8010596d <strncmp+0x2b>
8010595f:	8b 45 08             	mov    0x8(%ebp),%eax
80105962:	8a 10                	mov    (%eax),%dl
80105964:	8b 45 0c             	mov    0xc(%ebp),%eax
80105967:	8a 00                	mov    (%eax),%al
80105969:	38 c2                	cmp    %al,%dl
8010596b:	74 da                	je     80105947 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010596d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105971:	75 07                	jne    8010597a <strncmp+0x38>
    return 0;
80105973:	b8 00 00 00 00       	mov    $0x0,%eax
80105978:	eb 14                	jmp    8010598e <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010597a:	8b 45 08             	mov    0x8(%ebp),%eax
8010597d:	8a 00                	mov    (%eax),%al
8010597f:	0f b6 d0             	movzbl %al,%edx
80105982:	8b 45 0c             	mov    0xc(%ebp),%eax
80105985:	8a 00                	mov    (%eax),%al
80105987:	0f b6 c0             	movzbl %al,%eax
8010598a:	29 c2                	sub    %eax,%edx
8010598c:	89 d0                	mov    %edx,%eax
}
8010598e:	5d                   	pop    %ebp
8010598f:	c3                   	ret    

80105990 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105996:	8b 45 08             	mov    0x8(%ebp),%eax
80105999:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010599c:	90                   	nop
8010599d:	8b 45 10             	mov    0x10(%ebp),%eax
801059a0:	8d 50 ff             	lea    -0x1(%eax),%edx
801059a3:	89 55 10             	mov    %edx,0x10(%ebp)
801059a6:	85 c0                	test   %eax,%eax
801059a8:	7e 1c                	jle    801059c6 <strncpy+0x36>
801059aa:	8b 45 08             	mov    0x8(%ebp),%eax
801059ad:	8d 50 01             	lea    0x1(%eax),%edx
801059b0:	89 55 08             	mov    %edx,0x8(%ebp)
801059b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801059b6:	8d 4a 01             	lea    0x1(%edx),%ecx
801059b9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801059bc:	8a 12                	mov    (%edx),%dl
801059be:	88 10                	mov    %dl,(%eax)
801059c0:	8a 00                	mov    (%eax),%al
801059c2:	84 c0                	test   %al,%al
801059c4:	75 d7                	jne    8010599d <strncpy+0xd>
    ;
  while(n-- > 0)
801059c6:	eb 0c                	jmp    801059d4 <strncpy+0x44>
    *s++ = 0;
801059c8:	8b 45 08             	mov    0x8(%ebp),%eax
801059cb:	8d 50 01             	lea    0x1(%eax),%edx
801059ce:	89 55 08             	mov    %edx,0x8(%ebp)
801059d1:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801059d4:	8b 45 10             	mov    0x10(%ebp),%eax
801059d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801059da:	89 55 10             	mov    %edx,0x10(%ebp)
801059dd:	85 c0                	test   %eax,%eax
801059df:	7f e7                	jg     801059c8 <strncpy+0x38>
    *s++ = 0;
  return os;
801059e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059e4:	c9                   	leave  
801059e5:	c3                   	ret    

801059e6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801059e6:	55                   	push   %ebp
801059e7:	89 e5                	mov    %esp,%ebp
801059e9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801059ec:	8b 45 08             	mov    0x8(%ebp),%eax
801059ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801059f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059f6:	7f 05                	jg     801059fd <safestrcpy+0x17>
    return os;
801059f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059fb:	eb 2e                	jmp    80105a2b <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801059fd:	ff 4d 10             	decl   0x10(%ebp)
80105a00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a04:	7e 1c                	jle    80105a22 <safestrcpy+0x3c>
80105a06:	8b 45 08             	mov    0x8(%ebp),%eax
80105a09:	8d 50 01             	lea    0x1(%eax),%edx
80105a0c:	89 55 08             	mov    %edx,0x8(%ebp)
80105a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a12:	8d 4a 01             	lea    0x1(%edx),%ecx
80105a15:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105a18:	8a 12                	mov    (%edx),%dl
80105a1a:	88 10                	mov    %dl,(%eax)
80105a1c:	8a 00                	mov    (%eax),%al
80105a1e:	84 c0                	test   %al,%al
80105a20:	75 db                	jne    801059fd <safestrcpy+0x17>
    ;
  *s = 0;
80105a22:	8b 45 08             	mov    0x8(%ebp),%eax
80105a25:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a2b:	c9                   	leave  
80105a2c:	c3                   	ret    

80105a2d <strlen>:

int
strlen(const char *s)
{
80105a2d:	55                   	push   %ebp
80105a2e:	89 e5                	mov    %esp,%ebp
80105a30:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105a33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a3a:	eb 03                	jmp    80105a3f <strlen+0x12>
80105a3c:	ff 45 fc             	incl   -0x4(%ebp)
80105a3f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a42:	8b 45 08             	mov    0x8(%ebp),%eax
80105a45:	01 d0                	add    %edx,%eax
80105a47:	8a 00                	mov    (%eax),%al
80105a49:	84 c0                	test   %al,%al
80105a4b:	75 ef                	jne    80105a3c <strlen+0xf>
    ;
  return n;
80105a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a50:	c9                   	leave  
80105a51:	c3                   	ret    
	...

80105a54 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105a54:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105a58:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105a5c:	55                   	push   %ebp
  pushl %ebx
80105a5d:	53                   	push   %ebx
  pushl %esi
80105a5e:	56                   	push   %esi
  pushl %edi
80105a5f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105a60:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105a62:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105a64:	5f                   	pop    %edi
  popl %esi
80105a65:	5e                   	pop    %esi
  popl %ebx
80105a66:	5b                   	pop    %ebx
  popl %ebp
80105a67:	5d                   	pop    %ebp
  ret
80105a68:	c3                   	ret    
80105a69:	00 00                	add    %al,(%eax)
	...

80105a6c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105a6c:	55                   	push   %ebp
80105a6d:	89 e5                	mov    %esp,%ebp
80105a6f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105a72:	e8 bc ea ff ff       	call   80104533 <myproc>
80105a77:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7d:	8b 00                	mov    (%eax),%eax
80105a7f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a82:	76 0f                	jbe    80105a93 <fetchint+0x27>
80105a84:	8b 45 08             	mov    0x8(%ebp),%eax
80105a87:	8d 50 04             	lea    0x4(%eax),%edx
80105a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8d:	8b 00                	mov    (%eax),%eax
80105a8f:	39 c2                	cmp    %eax,%edx
80105a91:	76 07                	jbe    80105a9a <fetchint+0x2e>
    return -1;
80105a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a98:	eb 0f                	jmp    80105aa9 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a9d:	8b 10                	mov    (%eax),%edx
80105a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aa2:	89 10                	mov    %edx,(%eax)
  return 0;
80105aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aa9:	c9                   	leave  
80105aaa:	c3                   	ret    

80105aab <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105aab:	55                   	push   %ebp
80105aac:	89 e5                	mov    %esp,%ebp
80105aae:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105ab1:	e8 7d ea ff ff       	call   80104533 <myproc>
80105ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abc:	8b 00                	mov    (%eax),%eax
80105abe:	3b 45 08             	cmp    0x8(%ebp),%eax
80105ac1:	77 07                	ja     80105aca <fetchstr+0x1f>
    return -1;
80105ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac8:	eb 41                	jmp    80105b0b <fetchstr+0x60>
  *pp = (char*)addr;
80105aca:	8b 55 08             	mov    0x8(%ebp),%edx
80105acd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ad0:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad5:	8b 00                	mov    (%eax),%eax
80105ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80105add:	8b 00                	mov    (%eax),%eax
80105adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ae2:	eb 1a                	jmp    80105afe <fetchstr+0x53>
    if(*s == 0)
80105ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae7:	8a 00                	mov    (%eax),%al
80105ae9:	84 c0                	test   %al,%al
80105aeb:	75 0e                	jne    80105afb <fetchstr+0x50>
      return s - *pp;
80105aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105af3:	8b 00                	mov    (%eax),%eax
80105af5:	29 c2                	sub    %eax,%edx
80105af7:	89 d0                	mov    %edx,%eax
80105af9:	eb 10                	jmp    80105b0b <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105afb:	ff 45 f4             	incl   -0xc(%ebp)
80105afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b01:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105b04:	72 de                	jb     80105ae4 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105b06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b0b:	c9                   	leave  
80105b0c:	c3                   	ret    

80105b0d <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105b0d:	55                   	push   %ebp
80105b0e:	89 e5                	mov    %esp,%ebp
80105b10:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105b13:	e8 1b ea ff ff       	call   80104533 <myproc>
80105b18:	8b 40 18             	mov    0x18(%eax),%eax
80105b1b:	8b 50 44             	mov    0x44(%eax),%edx
80105b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b21:	c1 e0 02             	shl    $0x2,%eax
80105b24:	01 d0                	add    %edx,%eax
80105b26:	8d 50 04             	lea    0x4(%eax),%edx
80105b29:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b30:	89 14 24             	mov    %edx,(%esp)
80105b33:	e8 34 ff ff ff       	call   80105a6c <fetchint>
}
80105b38:	c9                   	leave  
80105b39:	c3                   	ret    

80105b3a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105b3a:	55                   	push   %ebp
80105b3b:	89 e5                	mov    %esp,%ebp
80105b3d:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105b40:	e8 ee e9 ff ff       	call   80104533 <myproc>
80105b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105b48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105b52:	89 04 24             	mov    %eax,(%esp)
80105b55:	e8 b3 ff ff ff       	call   80105b0d <argint>
80105b5a:	85 c0                	test   %eax,%eax
80105b5c:	79 07                	jns    80105b65 <argptr+0x2b>
    return -1;
80105b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b63:	eb 3d                	jmp    80105ba2 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105b65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b69:	78 21                	js     80105b8c <argptr+0x52>
80105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6e:	89 c2                	mov    %eax,%edx
80105b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b73:	8b 00                	mov    (%eax),%eax
80105b75:	39 c2                	cmp    %eax,%edx
80105b77:	73 13                	jae    80105b8c <argptr+0x52>
80105b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7c:	89 c2                	mov    %eax,%edx
80105b7e:	8b 45 10             	mov    0x10(%ebp),%eax
80105b81:	01 c2                	add    %eax,%edx
80105b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b86:	8b 00                	mov    (%eax),%eax
80105b88:	39 c2                	cmp    %eax,%edx
80105b8a:	76 07                	jbe    80105b93 <argptr+0x59>
    return -1;
80105b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b91:	eb 0f                	jmp    80105ba2 <argptr+0x68>
  *pp = (char*)i;
80105b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b96:	89 c2                	mov    %eax,%edx
80105b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b9b:	89 10                	mov    %edx,(%eax)
  return 0;
80105b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba2:	c9                   	leave  
80105ba3:	c3                   	ret    

80105ba4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105ba4:	55                   	push   %ebp
80105ba5:	89 e5                	mov    %esp,%ebp
80105ba7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105baa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bad:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb4:	89 04 24             	mov    %eax,(%esp)
80105bb7:	e8 51 ff ff ff       	call   80105b0d <argint>
80105bbc:	85 c0                	test   %eax,%eax
80105bbe:	79 07                	jns    80105bc7 <argstr+0x23>
    return -1;
80105bc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc5:	eb 12                	jmp    80105bd9 <argstr+0x35>
  return fetchstr(addr, pp);
80105bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bca:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bd1:	89 04 24             	mov    %eax,(%esp)
80105bd4:	e8 d2 fe ff ff       	call   80105aab <fetchstr>
}
80105bd9:	c9                   	leave  
80105bda:	c3                   	ret    

80105bdb <syscall>:
[SYS_get_used] sys_get_used,
};

void
syscall(void)
{
80105bdb:	55                   	push   %ebp
80105bdc:	89 e5                	mov    %esp,%ebp
80105bde:	53                   	push   %ebx
80105bdf:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105be2:	e8 4c e9 ff ff       	call   80104533 <myproc>
80105be7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bed:	8b 40 18             	mov    0x18(%eax),%eax
80105bf0:	8b 40 1c             	mov    0x1c(%eax),%eax
80105bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105bf6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bfa:	7e 2d                	jle    80105c29 <syscall+0x4e>
80105bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bff:	83 f8 35             	cmp    $0x35,%eax
80105c02:	77 25                	ja     80105c29 <syscall+0x4e>
80105c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c07:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105c0e:	85 c0                	test   %eax,%eax
80105c10:	74 17                	je     80105c29 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c15:	8b 58 18             	mov    0x18(%eax),%ebx
80105c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1b:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105c22:	ff d0                	call   *%eax
80105c24:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105c27:	eb 34                	jmp    80105c5d <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2c:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c32:	8b 40 10             	mov    0x10(%eax),%eax
80105c35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c38:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105c3c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c40:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c44:	c7 04 24 90 9f 10 80 	movl   $0x80109f90,(%esp)
80105c4b:	e8 71 a7 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c53:	8b 40 18             	mov    0x18(%eax),%eax
80105c56:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105c5d:	83 c4 24             	add    $0x24,%esp
80105c60:	5b                   	pop    %ebx
80105c61:	5d                   	pop    %ebp
80105c62:	c3                   	ret    
	...

80105c64 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105c64:	55                   	push   %ebp
80105c65:	89 e5                	mov    %esp,%ebp
80105c67:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105c6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c71:	8b 45 08             	mov    0x8(%ebp),%eax
80105c74:	89 04 24             	mov    %eax,(%esp)
80105c77:	e8 91 fe ff ff       	call   80105b0d <argint>
80105c7c:	85 c0                	test   %eax,%eax
80105c7e:	79 07                	jns    80105c87 <argfd+0x23>
    return -1;
80105c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c85:	eb 4f                	jmp    80105cd6 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8a:	85 c0                	test   %eax,%eax
80105c8c:	78 20                	js     80105cae <argfd+0x4a>
80105c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c91:	83 f8 0f             	cmp    $0xf,%eax
80105c94:	7f 18                	jg     80105cae <argfd+0x4a>
80105c96:	e8 98 e8 ff ff       	call   80104533 <myproc>
80105c9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c9e:	83 c2 08             	add    $0x8,%edx
80105ca1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cac:	75 07                	jne    80105cb5 <argfd+0x51>
    return -1;
80105cae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb3:	eb 21                	jmp    80105cd6 <argfd+0x72>
  if(pfd)
80105cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105cb9:	74 08                	je     80105cc3 <argfd+0x5f>
    *pfd = fd;
80105cbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cc1:	89 10                	mov    %edx,(%eax)
  if(pf)
80105cc3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105cc7:	74 08                	je     80105cd1 <argfd+0x6d>
    *pf = f;
80105cc9:	8b 45 10             	mov    0x10(%ebp),%eax
80105ccc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ccf:	89 10                	mov    %edx,(%eax)
  return 0;
80105cd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cd6:	c9                   	leave  
80105cd7:	c3                   	ret    

80105cd8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105cd8:	55                   	push   %ebp
80105cd9:	89 e5                	mov    %esp,%ebp
80105cdb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105cde:	e8 50 e8 ff ff       	call   80104533 <myproc>
80105ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105ce6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ced:	eb 29                	jmp    80105d18 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cf5:	83 c2 08             	add    $0x8,%edx
80105cf8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105cfc:	85 c0                	test   %eax,%eax
80105cfe:	75 15                	jne    80105d15 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d06:	8d 4a 08             	lea    0x8(%edx),%ecx
80105d09:	8b 55 08             	mov    0x8(%ebp),%edx
80105d0c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d13:	eb 0e                	jmp    80105d23 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105d15:	ff 45 f4             	incl   -0xc(%ebp)
80105d18:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105d1c:	7e d1                	jle    80105cef <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105d1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d23:	c9                   	leave  
80105d24:	c3                   	ret    

80105d25 <sys_dup>:

int
sys_dup(void)
{
80105d25:	55                   	push   %ebp
80105d26:	89 e5                	mov    %esp,%ebp
80105d28:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105d2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d2e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d39:	00 
80105d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d41:	e8 1e ff ff ff       	call   80105c64 <argfd>
80105d46:	85 c0                	test   %eax,%eax
80105d48:	79 07                	jns    80105d51 <sys_dup+0x2c>
    return -1;
80105d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4f:	eb 29                	jmp    80105d7a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d54:	89 04 24             	mov    %eax,(%esp)
80105d57:	e8 7c ff ff ff       	call   80105cd8 <fdalloc>
80105d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d63:	79 07                	jns    80105d6c <sys_dup+0x47>
    return -1;
80105d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6a:	eb 0e                	jmp    80105d7a <sys_dup+0x55>
  filedup(f);
80105d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6f:	89 04 24             	mov    %eax,(%esp)
80105d72:	e8 eb b3 ff ff       	call   80101162 <filedup>
  return fd;
80105d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d7a:	c9                   	leave  
80105d7b:	c3                   	ret    

80105d7c <sys_read>:

int
sys_read(void)
{
80105d7c:	55                   	push   %ebp
80105d7d:	89 e5                	mov    %esp,%ebp
80105d7f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d82:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d85:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d90:	00 
80105d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d98:	e8 c7 fe ff ff       	call   80105c64 <argfd>
80105d9d:	85 c0                	test   %eax,%eax
80105d9f:	78 35                	js     80105dd6 <sys_read+0x5a>
80105da1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105da4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105da8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105daf:	e8 59 fd ff ff       	call   80105b0d <argint>
80105db4:	85 c0                	test   %eax,%eax
80105db6:	78 1e                	js     80105dd6 <sys_read+0x5a>
80105db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dc6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105dcd:	e8 68 fd ff ff       	call   80105b3a <argptr>
80105dd2:	85 c0                	test   %eax,%eax
80105dd4:	79 07                	jns    80105ddd <sys_read+0x61>
    return -1;
80105dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddb:	eb 19                	jmp    80105df6 <sys_read+0x7a>
  return fileread(f, p, n);
80105ddd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105de0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105dea:	89 54 24 04          	mov    %edx,0x4(%esp)
80105dee:	89 04 24             	mov    %eax,(%esp)
80105df1:	e8 cd b4 ff ff       	call   801012c3 <fileread>
}
80105df6:	c9                   	leave  
80105df7:	c3                   	ret    

80105df8 <sys_write>:

int
sys_write(void)
{
80105df8:	55                   	push   %ebp
80105df9:	89 e5                	mov    %esp,%ebp
80105dfb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105dfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e01:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e0c:	00 
80105e0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e14:	e8 4b fe ff ff       	call   80105c64 <argfd>
80105e19:	85 c0                	test   %eax,%eax
80105e1b:	78 35                	js     80105e52 <sys_write+0x5a>
80105e1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e24:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105e2b:	e8 dd fc ff ff       	call   80105b0d <argint>
80105e30:	85 c0                	test   %eax,%eax
80105e32:	78 1e                	js     80105e52 <sys_write+0x5a>
80105e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e37:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e49:	e8 ec fc ff ff       	call   80105b3a <argptr>
80105e4e:	85 c0                	test   %eax,%eax
80105e50:	79 07                	jns    80105e59 <sys_write+0x61>
    return -1;
80105e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e57:	eb 19                	jmp    80105e72 <sys_write+0x7a>
  return filewrite(f, p, n);
80105e59:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105e5c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e62:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e66:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e6a:	89 04 24             	mov    %eax,(%esp)
80105e6d:	e8 0c b5 ff ff       	call   8010137e <filewrite>
}
80105e72:	c9                   	leave  
80105e73:	c3                   	ret    

80105e74 <sys_close>:

int
sys_close(void)
{
80105e74:	55                   	push   %ebp
80105e75:	89 e5                	mov    %esp,%ebp
80105e77:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105e7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e7d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e84:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e8f:	e8 d0 fd ff ff       	call   80105c64 <argfd>
80105e94:	85 c0                	test   %eax,%eax
80105e96:	79 07                	jns    80105e9f <sys_close+0x2b>
    return -1;
80105e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9d:	eb 23                	jmp    80105ec2 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105e9f:	e8 8f e6 ff ff       	call   80104533 <myproc>
80105ea4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ea7:	83 c2 08             	add    $0x8,%edx
80105eaa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105eb1:	00 
  fileclose(f);
80105eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb5:	89 04 24             	mov    %eax,(%esp)
80105eb8:	e8 ed b2 ff ff       	call   801011aa <fileclose>
  return 0;
80105ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ec2:	c9                   	leave  
80105ec3:	c3                   	ret    

80105ec4 <sys_fstat>:

int
sys_fstat(void)
{
80105ec4:	55                   	push   %ebp
80105ec5:	89 e5                	mov    %esp,%ebp
80105ec7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ed1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ed8:	00 
80105ed9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ee0:	e8 7f fd ff ff       	call   80105c64 <argfd>
80105ee5:	85 c0                	test   %eax,%eax
80105ee7:	78 1f                	js     80105f08 <sys_fstat+0x44>
80105ee9:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105ef0:	00 
80105ef1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105eff:	e8 36 fc ff ff       	call   80105b3a <argptr>
80105f04:	85 c0                	test   %eax,%eax
80105f06:	79 07                	jns    80105f0f <sys_fstat+0x4b>
    return -1;
80105f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0d:	eb 12                	jmp    80105f21 <sys_fstat+0x5d>
  return filestat(f, st);
80105f0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f15:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f19:	89 04 24             	mov    %eax,(%esp)
80105f1c:	e8 53 b3 ff ff       	call   80101274 <filestat>
}
80105f21:	c9                   	leave  
80105f22:	c3                   	ret    

80105f23 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105f23:	55                   	push   %ebp
80105f24:	89 e5                	mov    %esp,%ebp
80105f26:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105f29:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f37:	e8 68 fc ff ff       	call   80105ba4 <argstr>
80105f3c:	85 c0                	test   %eax,%eax
80105f3e:	78 17                	js     80105f57 <sys_link+0x34>
80105f40:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105f43:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f4e:	e8 51 fc ff ff       	call   80105ba4 <argstr>
80105f53:	85 c0                	test   %eax,%eax
80105f55:	79 0a                	jns    80105f61 <sys_link+0x3e>
    return -1;
80105f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5c:	e9 3d 01 00 00       	jmp    8010609e <sys_link+0x17b>

  begin_op();
80105f61:	e8 cd d8 ff ff       	call   80103833 <begin_op>
  if((ip = namei(old)) == 0){
80105f66:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105f69:	89 04 24             	mov    %eax,(%esp)
80105f6c:	e8 bc c7 ff ff       	call   8010272d <namei>
80105f71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f78:	75 0f                	jne    80105f89 <sys_link+0x66>
    end_op();
80105f7a:	e8 36 d9 ff ff       	call   801038b5 <end_op>
    return -1;
80105f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f84:	e9 15 01 00 00       	jmp    8010609e <sys_link+0x17b>
  }

  ilock(ip);
80105f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8c:	89 04 24             	mov    %eax,(%esp)
80105f8f:	e8 2e bb ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f97:	8b 40 50             	mov    0x50(%eax),%eax
80105f9a:	66 83 f8 01          	cmp    $0x1,%ax
80105f9e:	75 1a                	jne    80105fba <sys_link+0x97>
    iunlockput(ip);
80105fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa3:	89 04 24             	mov    %eax,(%esp)
80105fa6:	e8 16 bd ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105fab:	e8 05 d9 ff ff       	call   801038b5 <end_op>
    return -1;
80105fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb5:	e9 e4 00 00 00       	jmp    8010609e <sys_link+0x17b>
  }

  ip->nlink++;
80105fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbd:	66 8b 40 56          	mov    0x56(%eax),%ax
80105fc1:	40                   	inc    %eax
80105fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fc5:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcc:	89 04 24             	mov    %eax,(%esp)
80105fcf:	e8 2b b9 ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd7:	89 04 24             	mov    %eax,(%esp)
80105fda:	e8 ed bb ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105fdf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105fe2:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105fe5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105fe9:	89 04 24             	mov    %eax,(%esp)
80105fec:	e8 5e c7 ff ff       	call   8010274f <nameiparent>
80105ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ff4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ff8:	75 02                	jne    80105ffc <sys_link+0xd9>
    goto bad;
80105ffa:	eb 68                	jmp    80106064 <sys_link+0x141>
  ilock(dp);
80105ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fff:	89 04 24             	mov    %eax,(%esp)
80106002:	e8 bb ba ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600a:	8b 10                	mov    (%eax),%edx
8010600c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600f:	8b 00                	mov    (%eax),%eax
80106011:	39 c2                	cmp    %eax,%edx
80106013:	75 20                	jne    80106035 <sys_link+0x112>
80106015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106018:	8b 40 04             	mov    0x4(%eax),%eax
8010601b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010601f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106022:	89 44 24 04          	mov    %eax,0x4(%esp)
80106026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106029:	89 04 24             	mov    %eax,(%esp)
8010602c:	e8 41 c3 ff ff       	call   80102372 <dirlink>
80106031:	85 c0                	test   %eax,%eax
80106033:	79 0d                	jns    80106042 <sys_link+0x11f>
    iunlockput(dp);
80106035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106038:	89 04 24             	mov    %eax,(%esp)
8010603b:	e8 81 bc ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80106040:	eb 22                	jmp    80106064 <sys_link+0x141>
  }
  iunlockput(dp);
80106042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106045:	89 04 24             	mov    %eax,(%esp)
80106048:	e8 74 bc ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	89 04 24             	mov    %eax,(%esp)
80106053:	e8 b8 bb ff ff       	call   80101c10 <iput>

  end_op();
80106058:	e8 58 d8 ff ff       	call   801038b5 <end_op>

  return 0;
8010605d:	b8 00 00 00 00       	mov    $0x0,%eax
80106062:	eb 3a                	jmp    8010609e <sys_link+0x17b>

bad:
  ilock(ip);
80106064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106067:	89 04 24             	mov    %eax,(%esp)
8010606a:	e8 53 ba ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
8010606f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106072:	66 8b 40 56          	mov    0x56(%eax),%ax
80106076:	48                   	dec    %eax
80106077:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010607a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010607e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106081:	89 04 24             	mov    %eax,(%esp)
80106084:	e8 76 b8 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80106089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608c:	89 04 24             	mov    %eax,(%esp)
8010608f:	e8 2d bc ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106094:	e8 1c d8 ff ff       	call   801038b5 <end_op>
  return -1;
80106099:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010609e:	c9                   	leave  
8010609f:	c3                   	ret    

801060a0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801060a0:	55                   	push   %ebp
801060a1:	89 e5                	mov    %esp,%ebp
801060a3:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801060a6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801060ad:	eb 4a                	jmp    801060f9 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801060b9:	00 
801060ba:	89 44 24 08          	mov    %eax,0x8(%esp)
801060be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801060c5:	8b 45 08             	mov    0x8(%ebp),%eax
801060c8:	89 04 24             	mov    %eax,(%esp)
801060cb:	e8 89 be ff ff       	call   80101f59 <readi>
801060d0:	83 f8 10             	cmp    $0x10,%eax
801060d3:	74 0c                	je     801060e1 <isdirempty+0x41>
      panic("isdirempty: readi");
801060d5:	c7 04 24 ac 9f 10 80 	movl   $0x80109fac,(%esp)
801060dc:	e8 73 a4 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801060e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e4:	66 85 c0             	test   %ax,%ax
801060e7:	74 07                	je     801060f0 <isdirempty+0x50>
      return 0;
801060e9:	b8 00 00 00 00       	mov    $0x0,%eax
801060ee:	eb 1b                	jmp    8010610b <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801060f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f3:	83 c0 10             	add    $0x10,%eax
801060f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060fc:	8b 45 08             	mov    0x8(%ebp),%eax
801060ff:	8b 40 58             	mov    0x58(%eax),%eax
80106102:	39 c2                	cmp    %eax,%edx
80106104:	72 a9                	jb     801060af <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106106:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010610b:	c9                   	leave  
8010610c:	c3                   	ret    

8010610d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010610d:	55                   	push   %ebp
8010610e:	89 e5                	mov    %esp,%ebp
80106110:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106113:	8d 45 bc             	lea    -0x44(%ebp),%eax
80106116:	89 44 24 04          	mov    %eax,0x4(%esp)
8010611a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106121:	e8 7e fa ff ff       	call   80105ba4 <argstr>
80106126:	85 c0                	test   %eax,%eax
80106128:	79 0a                	jns    80106134 <sys_unlink+0x27>
    return -1;
8010612a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612f:	e9 f1 01 00 00       	jmp    80106325 <sys_unlink+0x218>

  begin_op();
80106134:	e8 fa d6 ff ff       	call   80103833 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106139:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010613c:	8d 55 c2             	lea    -0x3e(%ebp),%edx
8010613f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106143:	89 04 24             	mov    %eax,(%esp)
80106146:	e8 04 c6 ff ff       	call   8010274f <nameiparent>
8010614b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010614e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106152:	75 0f                	jne    80106163 <sys_unlink+0x56>
    end_op();
80106154:	e8 5c d7 ff ff       	call   801038b5 <end_op>
    return -1;
80106159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615e:	e9 c2 01 00 00       	jmp    80106325 <sys_unlink+0x218>
  }

  ilock(dp);
80106163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	e8 54 b9 ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010616e:	c7 44 24 04 be 9f 10 	movl   $0x80109fbe,0x4(%esp)
80106175:	80 
80106176:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106179:	89 04 24             	mov    %eax,(%esp)
8010617c:	e8 09 c1 ff ff       	call   8010228a <namecmp>
80106181:	85 c0                	test   %eax,%eax
80106183:	0f 84 87 01 00 00    	je     80106310 <sys_unlink+0x203>
80106189:	c7 44 24 04 c0 9f 10 	movl   $0x80109fc0,0x4(%esp)
80106190:	80 
80106191:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106194:	89 04 24             	mov    %eax,(%esp)
80106197:	e8 ee c0 ff ff       	call   8010228a <namecmp>
8010619c:	85 c0                	test   %eax,%eax
8010619e:	0f 84 6c 01 00 00    	je     80106310 <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801061a4:	8d 45 b8             	lea    -0x48(%ebp),%eax
801061a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801061ab:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801061ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801061b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b5:	89 04 24             	mov    %eax,(%esp)
801061b8:	e8 ef c0 ff ff       	call   801022ac <dirlookup>
801061bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c4:	75 05                	jne    801061cb <sys_unlink+0xbe>
    goto bad;
801061c6:	e9 45 01 00 00       	jmp    80106310 <sys_unlink+0x203>
  ilock(ip);
801061cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ce:	89 04 24             	mov    %eax,(%esp)
801061d1:	e8 ec b8 ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
801061d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d9:	66 8b 40 56          	mov    0x56(%eax),%ax
801061dd:	66 85 c0             	test   %ax,%ax
801061e0:	7f 0c                	jg     801061ee <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801061e2:	c7 04 24 c3 9f 10 80 	movl   $0x80109fc3,(%esp)
801061e9:	e8 66 a3 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801061ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f1:	8b 40 50             	mov    0x50(%eax),%eax
801061f4:	66 83 f8 01          	cmp    $0x1,%ax
801061f8:	75 1f                	jne    80106219 <sys_unlink+0x10c>
801061fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fd:	89 04 24             	mov    %eax,(%esp)
80106200:	e8 9b fe ff ff       	call   801060a0 <isdirempty>
80106205:	85 c0                	test   %eax,%eax
80106207:	75 10                	jne    80106219 <sys_unlink+0x10c>
    iunlockput(ip);
80106209:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620c:	89 04 24             	mov    %eax,(%esp)
8010620f:	e8 ad ba ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80106214:	e9 f7 00 00 00       	jmp    80106310 <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80106219:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106220:	00 
80106221:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106228:	00 
80106229:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010622c:	89 04 24             	mov    %eax,(%esp)
8010622f:	e8 a6 f5 ff ff       	call   801057da <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80106234:	8b 45 b8             	mov    -0x48(%ebp),%eax
80106237:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010623e:	00 
8010623f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106243:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106246:	89 44 24 04          	mov    %eax,0x4(%esp)
8010624a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624d:	89 04 24             	mov    %eax,(%esp)
80106250:	e8 68 be ff ff       	call   801020bd <writei>
80106255:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
80106258:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
8010625c:	74 0c                	je     8010626a <sys_unlink+0x15d>
    panic("unlink: writei");
8010625e:	c7 04 24 d5 9f 10 80 	movl   $0x80109fd5,(%esp)
80106265:	e8 ea a2 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
8010626a:	e8 c4 e2 ff ff       	call   80104533 <myproc>
8010626f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106275:	83 c0 18             	add    $0x18,%eax
80106278:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
8010627b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010627e:	89 04 24             	mov    %eax,(%esp)
80106281:	e8 c5 30 00 00       	call   8010934b <find>
80106286:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
80106289:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010628c:	89 c2                	mov    %eax,%edx
8010628e:	c1 ea 1f             	shr    $0x1f,%edx
80106291:	01 d0                	add    %edx,%eax
80106293:	d1 f8                	sar    %eax
80106295:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
80106298:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010629b:	f7 d8                	neg    %eax
8010629d:	89 c2                	mov    %eax,%edx
8010629f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a6:	89 14 24             	mov    %edx,(%esp)
801062a9:	e8 32 34 00 00       	call   801096e0 <set_curr_disk>
  if(ip->type == T_DIR){
801062ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b1:	8b 40 50             	mov    0x50(%eax),%eax
801062b4:	66 83 f8 01          	cmp    $0x1,%ax
801062b8:	75 1a                	jne    801062d4 <sys_unlink+0x1c7>
    dp->nlink--;
801062ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bd:	66 8b 40 56          	mov    0x56(%eax),%ax
801062c1:	48                   	dec    %eax
801062c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c5:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801062c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cc:	89 04 24             	mov    %eax,(%esp)
801062cf:	e8 2b b6 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
801062d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d7:	89 04 24             	mov    %eax,(%esp)
801062da:	e8 e2 b9 ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
801062df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e2:	66 8b 40 56          	mov    0x56(%eax),%ax
801062e6:	48                   	dec    %eax
801062e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ea:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801062ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f1:	89 04 24             	mov    %eax,(%esp)
801062f4:	e8 06 b6 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
801062f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fc:	89 04 24             	mov    %eax,(%esp)
801062ff:	e8 bd b9 ff ff       	call   80101cc1 <iunlockput>

  end_op();
80106304:	e8 ac d5 ff ff       	call   801038b5 <end_op>

  return 0;
80106309:	b8 00 00 00 00       	mov    $0x0,%eax
8010630e:	eb 15                	jmp    80106325 <sys_unlink+0x218>

bad:
  iunlockput(dp);
80106310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106313:	89 04 24             	mov    %eax,(%esp)
80106316:	e8 a6 b9 ff ff       	call   80101cc1 <iunlockput>
  end_op();
8010631b:	e8 95 d5 ff ff       	call   801038b5 <end_op>
  return -1;
80106320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106325:	c9                   	leave  
80106326:	c3                   	ret    

80106327 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106327:	55                   	push   %ebp
80106328:	89 e5                	mov    %esp,%ebp
8010632a:	83 ec 48             	sub    $0x48,%esp
8010632d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106330:	8b 55 10             	mov    0x10(%ebp),%edx
80106333:	8b 45 14             	mov    0x14(%ebp),%eax
80106336:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010633a:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010633e:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106342:	8d 45 de             	lea    -0x22(%ebp),%eax
80106345:	89 44 24 04          	mov    %eax,0x4(%esp)
80106349:	8b 45 08             	mov    0x8(%ebp),%eax
8010634c:	89 04 24             	mov    %eax,(%esp)
8010634f:	e8 fb c3 ff ff       	call   8010274f <nameiparent>
80106354:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010635b:	75 0a                	jne    80106367 <create+0x40>
    return 0;
8010635d:	b8 00 00 00 00       	mov    $0x0,%eax
80106362:	e9 79 01 00 00       	jmp    801064e0 <create+0x1b9>
  ilock(dp);
80106367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636a:	89 04 24             	mov    %eax,(%esp)
8010636d:	e8 50 b7 ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106372:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106375:	89 44 24 08          	mov    %eax,0x8(%esp)
80106379:	8d 45 de             	lea    -0x22(%ebp),%eax
8010637c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106383:	89 04 24             	mov    %eax,(%esp)
80106386:	e8 21 bf ff ff       	call   801022ac <dirlookup>
8010638b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010638e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106392:	74 46                	je     801063da <create+0xb3>
    iunlockput(dp);
80106394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106397:	89 04 24             	mov    %eax,(%esp)
8010639a:	e8 22 b9 ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
8010639f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a2:	89 04 24             	mov    %eax,(%esp)
801063a5:	e8 18 b7 ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801063aa:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801063af:	75 14                	jne    801063c5 <create+0x9e>
801063b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b4:	8b 40 50             	mov    0x50(%eax),%eax
801063b7:	66 83 f8 02          	cmp    $0x2,%ax
801063bb:	75 08                	jne    801063c5 <create+0x9e>
      return ip;
801063bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c0:	e9 1b 01 00 00       	jmp    801064e0 <create+0x1b9>
    iunlockput(ip);
801063c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c8:	89 04 24             	mov    %eax,(%esp)
801063cb:	e8 f1 b8 ff ff       	call   80101cc1 <iunlockput>
    return 0;
801063d0:	b8 00 00 00 00       	mov    $0x0,%eax
801063d5:	e9 06 01 00 00       	jmp    801064e0 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801063da:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801063de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e1:	8b 00                	mov    (%eax),%eax
801063e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801063e7:	89 04 24             	mov    %eax,(%esp)
801063ea:	e8 3e b4 ff ff       	call   8010182d <ialloc>
801063ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063f6:	75 0c                	jne    80106404 <create+0xdd>
    panic("create: ialloc");
801063f8:	c7 04 24 e4 9f 10 80 	movl   $0x80109fe4,(%esp)
801063ff:	e8 50 a1 ff ff       	call   80100554 <panic>

  ilock(ip);
80106404:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106407:	89 04 24             	mov    %eax,(%esp)
8010640a:	e8 b3 b6 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
8010640f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106412:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106415:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106419:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010641c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010641f:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80106423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106426:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010642c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642f:	89 04 24             	mov    %eax,(%esp)
80106432:	e8 c8 b4 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106437:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010643c:	75 68                	jne    801064a6 <create+0x17f>
    dp->nlink++;  // for ".."
8010643e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106441:	66 8b 40 56          	mov    0x56(%eax),%ax
80106445:	40                   	inc    %eax
80106446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106449:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
8010644d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106450:	89 04 24             	mov    %eax,(%esp)
80106453:	e8 a7 b4 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645b:	8b 40 04             	mov    0x4(%eax),%eax
8010645e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106462:	c7 44 24 04 be 9f 10 	movl   $0x80109fbe,0x4(%esp)
80106469:	80 
8010646a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646d:	89 04 24             	mov    %eax,(%esp)
80106470:	e8 fd be ff ff       	call   80102372 <dirlink>
80106475:	85 c0                	test   %eax,%eax
80106477:	78 21                	js     8010649a <create+0x173>
80106479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647c:	8b 40 04             	mov    0x4(%eax),%eax
8010647f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106483:	c7 44 24 04 c0 9f 10 	movl   $0x80109fc0,0x4(%esp)
8010648a:	80 
8010648b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648e:	89 04 24             	mov    %eax,(%esp)
80106491:	e8 dc be ff ff       	call   80102372 <dirlink>
80106496:	85 c0                	test   %eax,%eax
80106498:	79 0c                	jns    801064a6 <create+0x17f>
      panic("create dots");
8010649a:	c7 04 24 f3 9f 10 80 	movl   $0x80109ff3,(%esp)
801064a1:	e8 ae a0 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801064a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a9:	8b 40 04             	mov    0x4(%eax),%eax
801064ac:	89 44 24 08          	mov    %eax,0x8(%esp)
801064b0:	8d 45 de             	lea    -0x22(%ebp),%eax
801064b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ba:	89 04 24             	mov    %eax,(%esp)
801064bd:	e8 b0 be ff ff       	call   80102372 <dirlink>
801064c2:	85 c0                	test   %eax,%eax
801064c4:	79 0c                	jns    801064d2 <create+0x1ab>
    panic("create: dirlink");
801064c6:	c7 04 24 ff 9f 10 80 	movl   $0x80109fff,(%esp)
801064cd:	e8 82 a0 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801064d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d5:	89 04 24             	mov    %eax,(%esp)
801064d8:	e8 e4 b7 ff ff       	call   80101cc1 <iunlockput>

  return ip;
801064dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801064e0:	c9                   	leave  
801064e1:	c3                   	ret    

801064e2 <sys_open>:

int
sys_open(void)
{
801064e2:	55                   	push   %ebp
801064e3:	89 e5                	mov    %esp,%ebp
801064e5:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801064e8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f6:	e8 a9 f6 ff ff       	call   80105ba4 <argstr>
801064fb:	85 c0                	test   %eax,%eax
801064fd:	78 17                	js     80106516 <sys_open+0x34>
801064ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106502:	89 44 24 04          	mov    %eax,0x4(%esp)
80106506:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010650d:	e8 fb f5 ff ff       	call   80105b0d <argint>
80106512:	85 c0                	test   %eax,%eax
80106514:	79 0a                	jns    80106520 <sys_open+0x3e>
    return -1;
80106516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651b:	e9 64 01 00 00       	jmp    80106684 <sys_open+0x1a2>

  begin_op();
80106520:	e8 0e d3 ff ff       	call   80103833 <begin_op>

  if(omode & O_CREATE){
80106525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106528:	25 00 02 00 00       	and    $0x200,%eax
8010652d:	85 c0                	test   %eax,%eax
8010652f:	74 3b                	je     8010656c <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106531:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106534:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010653b:	00 
8010653c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106543:	00 
80106544:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010654b:	00 
8010654c:	89 04 24             	mov    %eax,(%esp)
8010654f:	e8 d3 fd ff ff       	call   80106327 <create>
80106554:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106557:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010655b:	75 6a                	jne    801065c7 <sys_open+0xe5>
      end_op();
8010655d:	e8 53 d3 ff ff       	call   801038b5 <end_op>
      return -1;
80106562:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106567:	e9 18 01 00 00       	jmp    80106684 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
8010656c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010656f:	89 04 24             	mov    %eax,(%esp)
80106572:	e8 b6 c1 ff ff       	call   8010272d <namei>
80106577:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010657a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010657e:	75 0f                	jne    8010658f <sys_open+0xad>
      end_op();
80106580:	e8 30 d3 ff ff       	call   801038b5 <end_op>
      return -1;
80106585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658a:	e9 f5 00 00 00       	jmp    80106684 <sys_open+0x1a2>
    }
    ilock(ip);
8010658f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106592:	89 04 24             	mov    %eax,(%esp)
80106595:	e8 28 b5 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010659a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659d:	8b 40 50             	mov    0x50(%eax),%eax
801065a0:	66 83 f8 01          	cmp    $0x1,%ax
801065a4:	75 21                	jne    801065c7 <sys_open+0xe5>
801065a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065a9:	85 c0                	test   %eax,%eax
801065ab:	74 1a                	je     801065c7 <sys_open+0xe5>
      iunlockput(ip);
801065ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b0:	89 04 24             	mov    %eax,(%esp)
801065b3:	e8 09 b7 ff ff       	call   80101cc1 <iunlockput>
      end_op();
801065b8:	e8 f8 d2 ff ff       	call   801038b5 <end_op>
      return -1;
801065bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c2:	e9 bd 00 00 00       	jmp    80106684 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801065c7:	e8 36 ab ff ff       	call   80101102 <filealloc>
801065cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065d3:	74 14                	je     801065e9 <sys_open+0x107>
801065d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d8:	89 04 24             	mov    %eax,(%esp)
801065db:	e8 f8 f6 ff ff       	call   80105cd8 <fdalloc>
801065e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801065e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801065e7:	79 28                	jns    80106611 <sys_open+0x12f>
    if(f)
801065e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ed:	74 0b                	je     801065fa <sys_open+0x118>
      fileclose(f);
801065ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f2:	89 04 24             	mov    %eax,(%esp)
801065f5:	e8 b0 ab ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
801065fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fd:	89 04 24             	mov    %eax,(%esp)
80106600:	e8 bc b6 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106605:	e8 ab d2 ff ff       	call   801038b5 <end_op>
    return -1;
8010660a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660f:	eb 73                	jmp    80106684 <sys_open+0x1a2>
  }
  iunlock(ip);
80106611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106614:	89 04 24             	mov    %eax,(%esp)
80106617:	e8 b0 b5 ff ff       	call   80101bcc <iunlock>
  end_op();
8010661c:	e8 94 d2 ff ff       	call   801038b5 <end_op>

  f->type = FD_INODE;
80106621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106624:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010662a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010662d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106630:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106633:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106636:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010663d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106640:	83 e0 01             	and    $0x1,%eax
80106643:	85 c0                	test   %eax,%eax
80106645:	0f 94 c0             	sete   %al
80106648:	88 c2                	mov    %al,%dl
8010664a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010664d:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106653:	83 e0 01             	and    $0x1,%eax
80106656:	85 c0                	test   %eax,%eax
80106658:	75 0a                	jne    80106664 <sys_open+0x182>
8010665a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010665d:	83 e0 02             	and    $0x2,%eax
80106660:	85 c0                	test   %eax,%eax
80106662:	74 07                	je     8010666b <sys_open+0x189>
80106664:	b8 01 00 00 00       	mov    $0x1,%eax
80106669:	eb 05                	jmp    80106670 <sys_open+0x18e>
8010666b:	b8 00 00 00 00       	mov    $0x0,%eax
80106670:	88 c2                	mov    %al,%dl
80106672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106675:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
80106678:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010667b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010667e:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
80106681:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106684:	c9                   	leave  
80106685:	c3                   	ret    

80106686 <sys_mkdir>:

int
sys_mkdir(void)
{
80106686:	55                   	push   %ebp
80106687:	89 e5                	mov    %esp,%ebp
80106689:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010668c:	e8 a2 d1 ff ff       	call   80103833 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106691:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106694:	89 44 24 04          	mov    %eax,0x4(%esp)
80106698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010669f:	e8 00 f5 ff ff       	call   80105ba4 <argstr>
801066a4:	85 c0                	test   %eax,%eax
801066a6:	78 2c                	js     801066d4 <sys_mkdir+0x4e>
801066a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801066b2:	00 
801066b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801066ba:	00 
801066bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801066c2:	00 
801066c3:	89 04 24             	mov    %eax,(%esp)
801066c6:	e8 5c fc ff ff       	call   80106327 <create>
801066cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066d2:	75 0c                	jne    801066e0 <sys_mkdir+0x5a>
    end_op();
801066d4:	e8 dc d1 ff ff       	call   801038b5 <end_op>
    return -1;
801066d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066de:	eb 15                	jmp    801066f5 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801066e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e3:	89 04 24             	mov    %eax,(%esp)
801066e6:	e8 d6 b5 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801066eb:	e8 c5 d1 ff ff       	call   801038b5 <end_op>
  return 0;
801066f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066f5:	c9                   	leave  
801066f6:	c3                   	ret    

801066f7 <sys_mknod>:

int
sys_mknod(void)
{
801066f7:	55                   	push   %ebp
801066f8:	89 e5                	mov    %esp,%ebp
801066fa:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801066fd:	e8 31 d1 ff ff       	call   80103833 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106702:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106705:	89 44 24 04          	mov    %eax,0x4(%esp)
80106709:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106710:	e8 8f f4 ff ff       	call   80105ba4 <argstr>
80106715:	85 c0                	test   %eax,%eax
80106717:	78 5e                	js     80106777 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106719:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010671c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106720:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106727:	e8 e1 f3 ff ff       	call   80105b0d <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
8010672c:	85 c0                	test   %eax,%eax
8010672e:	78 47                	js     80106777 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106730:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106733:	89 44 24 04          	mov    %eax,0x4(%esp)
80106737:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010673e:	e8 ca f3 ff ff       	call   80105b0d <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106743:	85 c0                	test   %eax,%eax
80106745:	78 30                	js     80106777 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106747:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010674a:	0f bf c8             	movswl %ax,%ecx
8010674d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106750:	0f bf d0             	movswl %ax,%edx
80106753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106756:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010675a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010675e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106765:	00 
80106766:	89 04 24             	mov    %eax,(%esp)
80106769:	e8 b9 fb ff ff       	call   80106327 <create>
8010676e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106775:	75 0c                	jne    80106783 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106777:	e8 39 d1 ff ff       	call   801038b5 <end_op>
    return -1;
8010677c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106781:	eb 15                	jmp    80106798 <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106786:	89 04 24             	mov    %eax,(%esp)
80106789:	e8 33 b5 ff ff       	call   80101cc1 <iunlockput>
  end_op();
8010678e:	e8 22 d1 ff ff       	call   801038b5 <end_op>
  return 0;
80106793:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106798:	c9                   	leave  
80106799:	c3                   	ret    

8010679a <sys_chdir>:

int
sys_chdir(void)
{
8010679a:	55                   	push   %ebp
8010679b:	89 e5                	mov    %esp,%ebp
8010679d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801067a0:	e8 8e dd ff ff       	call   80104533 <myproc>
801067a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801067a8:	e8 86 d0 ff ff       	call   80103833 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801067ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067bb:	e8 e4 f3 ff ff       	call   80105ba4 <argstr>
801067c0:	85 c0                	test   %eax,%eax
801067c2:	78 14                	js     801067d8 <sys_chdir+0x3e>
801067c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067c7:	89 04 24             	mov    %eax,(%esp)
801067ca:	e8 5e bf ff ff       	call   8010272d <namei>
801067cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067d6:	75 0c                	jne    801067e4 <sys_chdir+0x4a>
    end_op();
801067d8:	e8 d8 d0 ff ff       	call   801038b5 <end_op>
    return -1;
801067dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e2:	eb 5a                	jmp    8010683e <sys_chdir+0xa4>
  }
  ilock(ip);
801067e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e7:	89 04 24             	mov    %eax,(%esp)
801067ea:	e8 d3 b2 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
801067ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f2:	8b 40 50             	mov    0x50(%eax),%eax
801067f5:	66 83 f8 01          	cmp    $0x1,%ax
801067f9:	74 17                	je     80106812 <sys_chdir+0x78>
    iunlockput(ip);
801067fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fe:	89 04 24             	mov    %eax,(%esp)
80106801:	e8 bb b4 ff ff       	call   80101cc1 <iunlockput>
    end_op();
80106806:	e8 aa d0 ff ff       	call   801038b5 <end_op>
    return -1;
8010680b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106810:	eb 2c                	jmp    8010683e <sys_chdir+0xa4>
  }
  iunlock(ip);
80106812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106815:	89 04 24             	mov    %eax,(%esp)
80106818:	e8 af b3 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
8010681d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106820:	8b 40 68             	mov    0x68(%eax),%eax
80106823:	89 04 24             	mov    %eax,(%esp)
80106826:	e8 e5 b3 ff ff       	call   80101c10 <iput>
  end_op();
8010682b:	e8 85 d0 ff ff       	call   801038b5 <end_op>
  curproc->cwd = ip;
80106830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106833:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106836:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106839:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010683e:	c9                   	leave  
8010683f:	c3                   	ret    

80106840 <sys_exec>:

int
sys_exec(void)
{
80106840:	55                   	push   %ebp
80106841:	89 e5                	mov    %esp,%ebp
80106843:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106849:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010684c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106850:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106857:	e8 48 f3 ff ff       	call   80105ba4 <argstr>
8010685c:	85 c0                	test   %eax,%eax
8010685e:	78 1a                	js     8010687a <sys_exec+0x3a>
80106860:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106866:	89 44 24 04          	mov    %eax,0x4(%esp)
8010686a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106871:	e8 97 f2 ff ff       	call   80105b0d <argint>
80106876:	85 c0                	test   %eax,%eax
80106878:	79 0a                	jns    80106884 <sys_exec+0x44>
    return -1;
8010687a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687f:	e9 c7 00 00 00       	jmp    8010694b <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106884:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010688b:	00 
8010688c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106893:	00 
80106894:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010689a:	89 04 24             	mov    %eax,(%esp)
8010689d:	e8 38 ef ff ff       	call   801057da <memset>
  for(i=0;; i++){
801068a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801068a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ac:	83 f8 1f             	cmp    $0x1f,%eax
801068af:	76 0a                	jbe    801068bb <sys_exec+0x7b>
      return -1;
801068b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b6:	e9 90 00 00 00       	jmp    8010694b <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801068bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068be:	c1 e0 02             	shl    $0x2,%eax
801068c1:	89 c2                	mov    %eax,%edx
801068c3:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801068c9:	01 c2                	add    %eax,%edx
801068cb:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801068d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d5:	89 14 24             	mov    %edx,(%esp)
801068d8:	e8 8f f1 ff ff       	call   80105a6c <fetchint>
801068dd:	85 c0                	test   %eax,%eax
801068df:	79 07                	jns    801068e8 <sys_exec+0xa8>
      return -1;
801068e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e6:	eb 63                	jmp    8010694b <sys_exec+0x10b>
    if(uarg == 0){
801068e8:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068ee:	85 c0                	test   %eax,%eax
801068f0:	75 26                	jne    80106918 <sys_exec+0xd8>
      argv[i] = 0;
801068f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f5:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801068fc:	00 00 00 00 
      break;
80106900:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106904:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010690a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010690e:	89 04 24             	mov    %eax,(%esp)
80106911:	e8 2a a3 ff ff       	call   80100c40 <exec>
80106916:	eb 33                	jmp    8010694b <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106918:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010691e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106921:	c1 e2 02             	shl    $0x2,%edx
80106924:	01 c2                	add    %eax,%edx
80106926:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010692c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106930:	89 04 24             	mov    %eax,(%esp)
80106933:	e8 73 f1 ff ff       	call   80105aab <fetchstr>
80106938:	85 c0                	test   %eax,%eax
8010693a:	79 07                	jns    80106943 <sys_exec+0x103>
      return -1;
8010693c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106941:	eb 08                	jmp    8010694b <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106943:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106946:	e9 5e ff ff ff       	jmp    801068a9 <sys_exec+0x69>
  return exec(path, argv);
}
8010694b:	c9                   	leave  
8010694c:	c3                   	ret    

8010694d <sys_pipe>:

int
sys_pipe(void)
{
8010694d:	55                   	push   %ebp
8010694e:	89 e5                	mov    %esp,%ebp
80106950:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106953:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010695a:	00 
8010695b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010695e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106962:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106969:	e8 cc f1 ff ff       	call   80105b3a <argptr>
8010696e:	85 c0                	test   %eax,%eax
80106970:	79 0a                	jns    8010697c <sys_pipe+0x2f>
    return -1;
80106972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106977:	e9 9a 00 00 00       	jmp    80106a16 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010697c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010697f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106983:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106986:	89 04 24             	mov    %eax,(%esp)
80106989:	e8 fa d6 ff ff       	call   80104088 <pipealloc>
8010698e:	85 c0                	test   %eax,%eax
80106990:	79 07                	jns    80106999 <sys_pipe+0x4c>
    return -1;
80106992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106997:	eb 7d                	jmp    80106a16 <sys_pipe+0xc9>
  fd0 = -1;
80106999:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801069a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801069a3:	89 04 24             	mov    %eax,(%esp)
801069a6:	e8 2d f3 ff ff       	call   80105cd8 <fdalloc>
801069ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069b2:	78 14                	js     801069c8 <sys_pipe+0x7b>
801069b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069b7:	89 04 24             	mov    %eax,(%esp)
801069ba:	e8 19 f3 ff ff       	call   80105cd8 <fdalloc>
801069bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069c6:	79 36                	jns    801069fe <sys_pipe+0xb1>
    if(fd0 >= 0)
801069c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069cc:	78 13                	js     801069e1 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801069ce:	e8 60 db ff ff       	call   80104533 <myproc>
801069d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069d6:	83 c2 08             	add    $0x8,%edx
801069d9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801069e0:	00 
    fileclose(rf);
801069e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801069e4:	89 04 24             	mov    %eax,(%esp)
801069e7:	e8 be a7 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
801069ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069ef:	89 04 24             	mov    %eax,(%esp)
801069f2:	e8 b3 a7 ff ff       	call   801011aa <fileclose>
    return -1;
801069f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069fc:	eb 18                	jmp    80106a16 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801069fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a04:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106a06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a09:	8d 50 04             	lea    0x4(%eax),%edx
80106a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0f:	89 02                	mov    %eax,(%edx)
  return 0;
80106a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a16:	c9                   	leave  
80106a17:	c3                   	ret    

80106a18 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106a18:	55                   	push   %ebp
80106a19:	89 e5                	mov    %esp,%ebp
80106a1b:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106a1e:	e8 10 db ff ff       	call   80104533 <myproc>
80106a23:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a29:	83 c0 18             	add    $0x18,%eax
80106a2c:	89 04 24             	mov    %eax,(%esp)
80106a2f:	e8 17 29 00 00       	call   8010934b <find>
80106a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106a37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a3b:	78 51                	js     80106a8e <sys_fork+0x76>
    int before = get_curr_proc(x);
80106a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a40:	89 04 24             	mov    %eax,(%esp)
80106a43:	e8 5b 2a 00 00       	call   801094a3 <get_curr_proc>
80106a48:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a59:	e8 29 2d 00 00       	call   80109787 <set_curr_proc>
    int after = get_curr_proc(x);
80106a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a61:	89 04 24             	mov    %eax,(%esp)
80106a64:	e8 3a 2a 00 00       	call   801094a3 <get_curr_proc>
80106a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
80106a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a6f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80106a72:	75 1a                	jne    80106a8e <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
80106a74:	e8 ba da ff ff       	call   80104533 <myproc>
80106a79:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a7f:	89 04 24             	mov    %eax,(%esp)
80106a82:	e8 d9 e6 ff ff       	call   80105160 <cstop_container_helper>
      return -1;
80106a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8c:	eb 05                	jmp    80106a93 <sys_fork+0x7b>
    }
  }
  return fork();
80106a8e:	e8 b9 dd ff ff       	call   8010484c <fork>
}
80106a93:	c9                   	leave  
80106a94:	c3                   	ret    

80106a95 <sys_exit>:

int
sys_exit(void)
{
80106a95:	55                   	push   %ebp
80106a96:	89 e5                	mov    %esp,%ebp
80106a98:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106a9b:	e8 93 da ff ff       	call   80104533 <myproc>
80106aa0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106aa6:	83 c0 18             	add    $0x18,%eax
80106aa9:	89 04 24             	mov    %eax,(%esp)
80106aac:	e8 9a 28 00 00       	call   8010934b <find>
80106ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106ab4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ab8:	78 13                	js     80106acd <sys_exit+0x38>
    set_curr_proc(-1, x);
80106aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106abd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac1:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
80106ac8:	e8 ba 2c 00 00       	call   80109787 <set_curr_proc>
  }
  exit();
80106acd:	e8 f2 de ff ff       	call   801049c4 <exit>
  return 0;  // not reached
80106ad2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ad7:	c9                   	leave  
80106ad8:	c3                   	ret    

80106ad9 <sys_wait>:

int
sys_wait(void)
{
80106ad9:	55                   	push   %ebp
80106ada:	89 e5                	mov    %esp,%ebp
80106adc:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106adf:	e8 24 e0 ff ff       	call   80104b08 <wait>
}
80106ae4:	c9                   	leave  
80106ae5:	c3                   	ret    

80106ae6 <sys_kill>:

int
sys_kill(void)
{
80106ae6:	55                   	push   %ebp
80106ae7:	89 e5                	mov    %esp,%ebp
80106ae9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aef:	89 44 24 04          	mov    %eax,0x4(%esp)
80106af3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106afa:	e8 0e f0 ff ff       	call   80105b0d <argint>
80106aff:	85 c0                	test   %eax,%eax
80106b01:	79 07                	jns    80106b0a <sys_kill+0x24>
    return -1;
80106b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b08:	eb 0b                	jmp    80106b15 <sys_kill+0x2f>
  return kill(pid);
80106b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0d:	89 04 24             	mov    %eax,(%esp)
80106b10:	e8 78 e4 ff ff       	call   80104f8d <kill>
}
80106b15:	c9                   	leave  
80106b16:	c3                   	ret    

80106b17 <sys_getpid>:

int
sys_getpid(void)
{
80106b17:	55                   	push   %ebp
80106b18:	89 e5                	mov    %esp,%ebp
80106b1a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106b1d:	e8 11 da ff ff       	call   80104533 <myproc>
80106b22:	8b 40 10             	mov    0x10(%eax),%eax
}
80106b25:	c9                   	leave  
80106b26:	c3                   	ret    

80106b27 <sys_sbrk>:

int
sys_sbrk(void)
{
80106b27:	55                   	push   %ebp
80106b28:	89 e5                	mov    %esp,%ebp
80106b2a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106b2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b30:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b3b:	e8 cd ef ff ff       	call   80105b0d <argint>
80106b40:	85 c0                	test   %eax,%eax
80106b42:	79 07                	jns    80106b4b <sys_sbrk+0x24>
    return -1;
80106b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b49:	eb 23                	jmp    80106b6e <sys_sbrk+0x47>
  addr = myproc()->sz;
80106b4b:	e8 e3 d9 ff ff       	call   80104533 <myproc>
80106b50:	8b 00                	mov    (%eax),%eax
80106b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b58:	89 04 24             	mov    %eax,(%esp)
80106b5b:	e8 4e dc ff ff       	call   801047ae <growproc>
80106b60:	85 c0                	test   %eax,%eax
80106b62:	79 07                	jns    80106b6b <sys_sbrk+0x44>
    return -1;
80106b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b69:	eb 03                	jmp    80106b6e <sys_sbrk+0x47>
  return addr;
80106b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106b6e:	c9                   	leave  
80106b6f:	c3                   	ret    

80106b70 <sys_sleep>:

int
sys_sleep(void)
{
80106b70:	55                   	push   %ebp
80106b71:	89 e5                	mov    %esp,%ebp
80106b73:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106b76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b84:	e8 84 ef ff ff       	call   80105b0d <argint>
80106b89:	85 c0                	test   %eax,%eax
80106b8b:	79 07                	jns    80106b94 <sys_sleep+0x24>
    return -1;
80106b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b92:	eb 6b                	jmp    80106bff <sys_sleep+0x8f>
  acquire(&tickslock);
80106b94:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
80106b9b:	e8 d7 e9 ff ff       	call   80105577 <acquire>
  ticks0 = ticks;
80106ba0:	a1 e0 8c 11 80       	mov    0x80118ce0,%eax
80106ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106ba8:	eb 33                	jmp    80106bdd <sys_sleep+0x6d>
    if(myproc()->killed){
80106baa:	e8 84 d9 ff ff       	call   80104533 <myproc>
80106baf:	8b 40 24             	mov    0x24(%eax),%eax
80106bb2:	85 c0                	test   %eax,%eax
80106bb4:	74 13                	je     80106bc9 <sys_sleep+0x59>
      release(&tickslock);
80106bb6:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
80106bbd:	e8 1f ea ff ff       	call   801055e1 <release>
      return -1;
80106bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bc7:	eb 36                	jmp    80106bff <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106bc9:	c7 44 24 04 a0 84 11 	movl   $0x801184a0,0x4(%esp)
80106bd0:	80 
80106bd1:	c7 04 24 e0 8c 11 80 	movl   $0x80118ce0,(%esp)
80106bd8:	e8 ae e2 ff ff       	call   80104e8b <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106bdd:	a1 e0 8c 11 80       	mov    0x80118ce0,%eax
80106be2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106be5:	89 c2                	mov    %eax,%edx
80106be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bea:	39 c2                	cmp    %eax,%edx
80106bec:	72 bc                	jb     80106baa <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106bee:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
80106bf5:	e8 e7 e9 ff ff       	call   801055e1 <release>
  return 0;
80106bfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bff:	c9                   	leave  
80106c00:	c3                   	ret    

80106c01 <sys_cstop>:

void sys_cstop(){
80106c01:	55                   	push   %ebp
80106c02:	89 e5                	mov    %esp,%ebp
80106c04:	53                   	push   %ebx
80106c05:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106c08:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c16:	e8 89 ef ff ff       	call   80105ba4 <argstr>

  if(myproc()->cont != NULL){
80106c1b:	e8 13 d9 ff ff       	call   80104533 <myproc>
80106c20:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c26:	85 c0                	test   %eax,%eax
80106c28:	74 72                	je     80106c9c <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106c2a:	e8 04 d9 ff ff       	call   80104533 <myproc>
80106c2f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c3b:	89 04 24             	mov    %eax,(%esp)
80106c3e:	e8 ea ed ff ff       	call   80105a2d <strlen>
80106c43:	89 c3                	mov    %eax,%ebx
80106c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c48:	83 c0 18             	add    $0x18,%eax
80106c4b:	89 04 24             	mov    %eax,(%esp)
80106c4e:	e8 da ed ff ff       	call   80105a2d <strlen>
80106c53:	39 c3                	cmp    %eax,%ebx
80106c55:	75 37                	jne    80106c8e <sys_cstop+0x8d>
80106c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c5a:	89 04 24             	mov    %eax,(%esp)
80106c5d:	e8 cb ed ff ff       	call   80105a2d <strlen>
80106c62:	89 c2                	mov    %eax,%edx
80106c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c67:	8d 48 18             	lea    0x18(%eax),%ecx
80106c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c6d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c71:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106c75:	89 04 24             	mov    %eax,(%esp)
80106c78:	e8 c5 ec ff ff       	call   80105942 <strncmp>
80106c7d:	85 c0                	test   %eax,%eax
80106c7f:	75 0d                	jne    80106c8e <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c84:	89 04 24             	mov    %eax,(%esp)
80106c87:	e8 d4 e4 ff ff       	call   80105160 <cstop_container_helper>
80106c8c:	eb 19                	jmp    80106ca7 <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106c8e:	c7 04 24 10 a0 10 80 	movl   $0x8010a010,(%esp)
80106c95:	e8 27 97 ff ff       	call   801003c1 <cprintf>
80106c9a:	eb 0b                	jmp    80106ca7 <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c9f:	89 04 24             	mov    %eax,(%esp)
80106ca2:	e8 20 e5 ff ff       	call   801051c7 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106ca7:	83 c4 24             	add    $0x24,%esp
80106caa:	5b                   	pop    %ebx
80106cab:	5d                   	pop    %ebp
80106cac:	c3                   	ret    

80106cad <sys_set_root_inode>:

void sys_set_root_inode(void){
80106cad:	55                   	push   %ebp
80106cae:	89 e5                	mov    %esp,%ebp
80106cb0:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cc1:	e8 de ee ff ff       	call   80105ba4 <argstr>

  set_root_inode(name);
80106cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cc9:	89 04 24             	mov    %eax,(%esp)
80106ccc:	e8 fe 24 00 00       	call   801091cf <set_root_inode>
  cprintf("success\n");
80106cd1:	c7 04 24 34 a0 10 80 	movl   $0x8010a034,(%esp)
80106cd8:	e8 e4 96 ff ff       	call   801003c1 <cprintf>

}
80106cdd:	c9                   	leave  
80106cde:	c3                   	ret    

80106cdf <sys_ps>:

void sys_ps(void){
80106cdf:	55                   	push   %ebp
80106ce0:	89 e5                	mov    %esp,%ebp
80106ce2:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106ce5:	e8 49 d8 ff ff       	call   80104533 <myproc>
80106cea:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106cf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cf7:	75 07                	jne    80106d00 <sys_ps+0x21>
    procdump();
80106cf9:	e8 0a e3 ff ff       	call   80105008 <procdump>
80106cfe:	eb 0e                	jmp    80106d0e <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d03:	83 c0 18             	add    $0x18,%eax
80106d06:	89 04 24             	mov    %eax,(%esp)
80106d09:	e8 4f e5 ff ff       	call   8010525d <c_procdump>
  }
}
80106d0e:	c9                   	leave  
80106d0f:	c3                   	ret    

80106d10 <sys_container_init>:

void sys_container_init(){
80106d10:	55                   	push   %ebp
80106d11:	89 e5                	mov    %esp,%ebp
80106d13:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106d16:	e8 0d 2b 00 00       	call   80109828 <container_init>
}
80106d1b:	c9                   	leave  
80106d1c:	c3                   	ret    

80106d1d <sys_is_full>:

int sys_is_full(void){
80106d1d:	55                   	push   %ebp
80106d1e:	89 e5                	mov    %esp,%ebp
80106d20:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106d23:	e8 d3 25 00 00       	call   801092fb <is_full>
}
80106d28:	c9                   	leave  
80106d29:	c3                   	ret    

80106d2a <sys_find>:

int sys_find(void){
80106d2a:	55                   	push   %ebp
80106d2b:	89 e5                	mov    %esp,%ebp
80106d2d:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d33:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d3e:	e8 61 ee ff ff       	call   80105ba4 <argstr>

  return find(name);
80106d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d46:	89 04 24             	mov    %eax,(%esp)
80106d49:	e8 fd 25 00 00       	call   8010934b <find>
}
80106d4e:	c9                   	leave  
80106d4f:	c3                   	ret    

80106d50 <sys_get_name>:

void sys_get_name(void){
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106d56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d59:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d64:	e8 a4 ed ff ff       	call   80105b0d <argint>
  argstr(1, &name);
80106d69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d77:	e8 28 ee ff ff       	call   80105ba4 <argstr>

  get_name(vc_num, name);
80106d7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d82:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d86:	89 04 24             	mov    %eax,(%esp)
80106d89:	e8 82 24 00 00       	call   80109210 <get_name>
}
80106d8e:	c9                   	leave  
80106d8f:	c3                   	ret    

80106d90 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106d90:	55                   	push   %ebp
80106d91:	89 e5                	mov    %esp,%ebp
80106d93:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d99:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106da4:	e8 64 ed ff ff       	call   80105b0d <argint>


  return get_max_proc(vc_num);  
80106da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dac:	89 04 24             	mov    %eax,(%esp)
80106daf:	e8 07 26 00 00       	call   801093bb <get_max_proc>
}
80106db4:	c9                   	leave  
80106db5:	c3                   	ret    

80106db6 <sys_get_max_mem>:

int sys_get_max_mem(void){
80106db6:	55                   	push   %ebp
80106db7:	89 e5                	mov    %esp,%ebp
80106db9:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106dbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dca:	e8 3e ed ff ff       	call   80105b0d <argint>


  return get_max_mem(vc_num);
80106dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd2:	89 04 24             	mov    %eax,(%esp)
80106dd5:	e8 49 26 00 00       	call   80109423 <get_max_mem>
}
80106dda:	c9                   	leave  
80106ddb:	c3                   	ret    

80106ddc <sys_get_max_disk>:

int sys_get_max_disk(void){
80106ddc:	55                   	push   %ebp
80106ddd:	89 e5                	mov    %esp,%ebp
80106ddf:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106de2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106de5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106de9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106df0:	e8 18 ed ff ff       	call   80105b0d <argint>


  return get_max_disk(vc_num);
80106df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df8:	89 04 24             	mov    %eax,(%esp)
80106dfb:	e8 63 26 00 00       	call   80109463 <get_max_disk>

}
80106e00:	c9                   	leave  
80106e01:	c3                   	ret    

80106e02 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106e02:	55                   	push   %ebp
80106e03:	89 e5                	mov    %esp,%ebp
80106e05:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e16:	e8 f2 ec ff ff       	call   80105b0d <argint>


  return get_curr_proc(vc_num);
80106e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e1e:	89 04 24             	mov    %eax,(%esp)
80106e21:	e8 7d 26 00 00       	call   801094a3 <get_curr_proc>
}
80106e26:	c9                   	leave  
80106e27:	c3                   	ret    

80106e28 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106e28:	55                   	push   %ebp
80106e29:	89 e5                	mov    %esp,%ebp
80106e2b:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106e2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e31:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e3c:	e8 cc ec ff ff       	call   80105b0d <argint>


  return get_curr_mem(vc_num);
80106e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e44:	89 04 24             	mov    %eax,(%esp)
80106e47:	e8 97 26 00 00       	call   801094e3 <get_curr_mem>
}
80106e4c:	c9                   	leave  
80106e4d:	c3                   	ret    

80106e4e <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106e4e:	55                   	push   %ebp
80106e4f:	89 e5                	mov    %esp,%ebp
80106e51:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e57:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e62:	e8 a6 ec ff ff       	call   80105b0d <argint>


  return get_curr_disk(vc_num);
80106e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6a:	89 04 24             	mov    %eax,(%esp)
80106e6d:	e8 b1 26 00 00       	call   80109523 <get_curr_disk>
}
80106e72:	c9                   	leave  
80106e73:	c3                   	ret    

80106e74 <sys_set_name>:

void sys_set_name(void){
80106e74:	55                   	push   %ebp
80106e75:	89 e5                	mov    %esp,%ebp
80106e77:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e88:	e8 17 ed ff ff       	call   80105ba4 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106e8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e90:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e9b:	e8 6d ec ff ff       	call   80105b0d <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106ea0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106eaa:	89 04 24             	mov    %eax,(%esp)
80106ead:	e8 b1 26 00 00       	call   80109563 <set_name>
  //cprintf("Done setting name.\n");
}
80106eb2:	c9                   	leave  
80106eb3:	c3                   	ret    

80106eb4 <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106eb4:	55                   	push   %ebp
80106eb5:	89 e5                	mov    %esp,%ebp
80106eb7:	53                   	push   %ebx
80106eb8:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106ebb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ec2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ec9:	e8 3f ec ff ff       	call   80105b0d <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106ece:	e8 60 d6 ff ff       	call   80104533 <myproc>
80106ed3:	89 c3                	mov    %eax,%ebx
80106ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed8:	89 04 24             	mov    %eax,(%esp)
80106edb:	e8 1b 25 00 00       	call   801093fb <get_container>
80106ee0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106ee6:	83 c4 24             	add    $0x24,%esp
80106ee9:	5b                   	pop    %ebx
80106eea:	5d                   	pop    %ebp
80106eeb:	c3                   	ret    

80106eec <sys_set_max_mem>:

void sys_set_max_mem(void){
80106eec:	55                   	push   %ebp
80106eed:	89 e5                	mov    %esp,%ebp
80106eef:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ef9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f00:	e8 08 ec ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80106f05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f08:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f13:	e8 f5 eb ff ff       	call   80105b0d <argint>

  set_max_mem(mem, vc_num);
80106f18:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f22:	89 04 24             	mov    %eax,(%esp)
80106f25:	e8 70 26 00 00       	call   8010959a <set_max_mem>
}
80106f2a:	c9                   	leave  
80106f2b:	c3                   	ret    

80106f2c <sys_set_max_disk>:

void sys_set_max_disk(void){
80106f2c:	55                   	push   %ebp
80106f2d:	89 e5                	mov    %esp,%ebp
80106f2f:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106f32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f35:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f40:	e8 c8 eb ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80106f45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f48:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f53:	e8 b5 eb ff ff       	call   80105b0d <argint>

  set_max_disk(disk, vc_num);
80106f58:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f5e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f62:	89 04 24             	mov    %eax,(%esp)
80106f65:	e8 55 26 00 00       	call   801095bf <set_max_disk>
}
80106f6a:	c9                   	leave  
80106f6b:	c3                   	ret    

80106f6c <sys_set_max_proc>:

void sys_set_max_proc(void){
80106f6c:	55                   	push   %ebp
80106f6d:	89 e5                	mov    %esp,%ebp
80106f6f:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106f72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f75:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f80:	e8 88 eb ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80106f85:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f88:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f93:	e8 75 eb ff ff       	call   80105b0d <argint>

  set_max_proc(proc, vc_num);
80106f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fa2:	89 04 24             	mov    %eax,(%esp)
80106fa5:	e8 3b 26 00 00       	call   801095e5 <set_max_proc>
}
80106faa:	c9                   	leave  
80106fab:	c3                   	ret    

80106fac <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106fac:	55                   	push   %ebp
80106fad:	89 e5                	mov    %esp,%ebp
80106faf:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fc0:	e8 48 eb ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80106fc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fcc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fd3:	e8 35 eb ff ff       	call   80105b0d <argint>

  set_curr_mem(mem, vc_num);
80106fd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fde:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fe2:	89 04 24             	mov    %eax,(%esp)
80106fe5:	e8 21 26 00 00       	call   8010960b <set_curr_mem>
}
80106fea:	c9                   	leave  
80106feb:	c3                   	ret    

80106fec <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106fec:	55                   	push   %ebp
80106fed:	89 e5                	mov    %esp,%ebp
80106fef:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106ff2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107000:	e8 08 eb ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80107005:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107008:	89 44 24 04          	mov    %eax,0x4(%esp)
8010700c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107013:	e8 f5 ea ff ff       	call   80105b0d <argint>

  set_curr_mem(mem, vc_num);
80107018:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010701b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701e:	89 54 24 04          	mov    %edx,0x4(%esp)
80107022:	89 04 24             	mov    %eax,(%esp)
80107025:	e8 e1 25 00 00       	call   8010960b <set_curr_mem>
}
8010702a:	c9                   	leave  
8010702b:	c3                   	ret    

8010702c <sys_set_curr_disk>:

void sys_set_curr_disk(void){
8010702c:	55                   	push   %ebp
8010702d:	89 e5                	mov    %esp,%ebp
8010702f:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80107032:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107035:	89 44 24 04          	mov    %eax,0x4(%esp)
80107039:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107040:	e8 c8 ea ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80107045:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107048:	89 44 24 04          	mov    %eax,0x4(%esp)
8010704c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107053:	e8 b5 ea ff ff       	call   80105b0d <argint>

  set_curr_disk(disk, vc_num);
80107058:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010705b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705e:	89 54 24 04          	mov    %edx,0x4(%esp)
80107062:	89 04 24             	mov    %eax,(%esp)
80107065:	e8 76 26 00 00       	call   801096e0 <set_curr_disk>
}
8010706a:	c9                   	leave  
8010706b:	c3                   	ret    

8010706c <sys_set_curr_proc>:

void sys_set_curr_proc(void){
8010706c:	55                   	push   %ebp
8010706d:	89 e5                	mov    %esp,%ebp
8010706f:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80107072:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107075:	89 44 24 04          	mov    %eax,0x4(%esp)
80107079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107080:	e8 88 ea ff ff       	call   80105b0d <argint>

  int vc_num;
  argint(1, &vc_num);
80107085:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107088:	89 44 24 04          	mov    %eax,0x4(%esp)
8010708c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107093:	e8 75 ea ff ff       	call   80105b0d <argint>

  set_curr_proc(proc, vc_num);
80107098:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010709b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709e:	89 54 24 04          	mov    %edx,0x4(%esp)
801070a2:	89 04 24             	mov    %eax,(%esp)
801070a5:	e8 dd 26 00 00       	call   80109787 <set_curr_proc>
}
801070aa:	c9                   	leave  
801070ab:	c3                   	ret    

801070ac <sys_container_reset>:

void sys_container_reset(void){
801070ac:	55                   	push   %ebp
801070ad:	89 e5                	mov    %esp,%ebp
801070af:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
801070b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801070b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801070c0:	e8 48 ea ff ff       	call   80105b0d <argint>
  container_reset(vc_num);
801070c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c8:	89 04 24             	mov    %eax,(%esp)
801070cb:	e8 6d 28 00 00       	call   8010993d <container_reset>
}
801070d0:	c9                   	leave  
801070d1:	c3                   	ret    

801070d2 <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801070d2:	55                   	push   %ebp
801070d3:	89 e5                	mov    %esp,%ebp
801070d5:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801070d8:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
801070df:	e8 93 e4 ff ff       	call   80105577 <acquire>
  xticks = ticks;
801070e4:	a1 e0 8c 11 80       	mov    0x80118ce0,%eax
801070e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801070ec:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
801070f3:	e8 e9 e4 ff ff       	call   801055e1 <release>
  return xticks;
801070f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070fb:	c9                   	leave  
801070fc:	c3                   	ret    

801070fd <sys_getticks>:

int
sys_getticks(void){
801070fd:	55                   	push   %ebp
801070fe:	89 e5                	mov    %esp,%ebp
80107100:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80107103:	e8 2b d4 ff ff       	call   80104533 <myproc>
80107108:	8b 40 7c             	mov    0x7c(%eax),%eax
}
8010710b:	c9                   	leave  
8010710c:	c3                   	ret    

8010710d <sys_max_containers>:

int sys_max_containers(void){
8010710d:	55                   	push   %ebp
8010710e:	89 e5                	mov    %esp,%ebp
80107110:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
80107113:	e8 06 27 00 00       	call   8010981e <max_containers>
}
80107118:	c9                   	leave  
80107119:	c3                   	ret    

8010711a <sys_df>:


void sys_df(void){
8010711a:	55                   	push   %ebp
8010711b:	89 e5                	mov    %esp,%ebp
8010711d:	53                   	push   %ebx
8010711e:	83 ec 54             	sub    $0x54,%esp
  struct container* cont = myproc()->cont;
80107121:	e8 0d d4 ff ff       	call   80104533 <myproc>
80107126:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010712c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
8010712f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80107132:	89 44 24 04          	mov    %eax,0x4(%esp)
80107136:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010713d:	e8 7e a3 ff ff       	call   801014c0 <readsb>

  cprintf("nblocks: %d\n", sb.nblocks);
80107142:	8b 45 c8             	mov    -0x38(%ebp),%eax
80107145:	89 44 24 04          	mov    %eax,0x4(%esp)
80107149:	c7 04 24 3d a0 10 80 	movl   $0x8010a03d,(%esp)
80107150:	e8 6c 92 ff ff       	call   801003c1 <cprintf>
  cprintf("nblocks: %d\n", FSSIZE);
80107155:	c7 44 24 04 20 4e 00 	movl   $0x4e20,0x4(%esp)
8010715c:	00 
8010715d:	c7 04 24 3d a0 10 80 	movl   $0x8010a03d,(%esp)
80107164:	e8 58 92 ff ff       	call   801003c1 <cprintf>
  int used = 0;
80107169:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80107170:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107174:	75 52                	jne    801071c8 <sys_df+0xae>
    int max = max_containers();
80107176:	e8 a3 26 00 00       	call   8010981e <max_containers>
8010717b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
8010717e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80107185:	eb 1d                	jmp    801071a4 <sys_df+0x8a>
      used = used + (int)(get_curr_disk(i) / 1024);
80107187:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010718a:	89 04 24             	mov    %eax,(%esp)
8010718d:	e8 91 23 00 00       	call   80109523 <get_curr_disk>
80107192:	85 c0                	test   %eax,%eax
80107194:	79 05                	jns    8010719b <sys_df+0x81>
80107196:	05 ff 03 00 00       	add    $0x3ff,%eax
8010719b:	c1 f8 0a             	sar    $0xa,%eax
8010719e:	01 45 f4             	add    %eax,-0xc(%ebp)
  cprintf("nblocks: %d\n", FSSIZE);
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
801071a1:	ff 45 f0             	incl   -0x10(%ebp)
801071a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071a7:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801071aa:	7c db                	jl     80107187 <sys_df+0x6d>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: %d\n", used, sb.nblocks);
801071ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
801071af:	89 44 24 08          	mov    %eax,0x8(%esp)
801071b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801071ba:	c7 04 24 4c a0 10 80 	movl   $0x8010a04c,(%esp)
801071c1:	e8 fb 91 ff ff       	call   801003c1 <cprintf>
801071c6:	eb 5e                	jmp    80107226 <sys_df+0x10c>
  }
  else{
    int x = find(cont->name);
801071c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071cb:	83 c0 18             	add    $0x18,%eax
801071ce:	89 04 24             	mov    %eax,(%esp)
801071d1:	e8 75 21 00 00       	call   8010934b <find>
801071d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
801071d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071dc:	89 04 24             	mov    %eax,(%esp)
801071df:	e8 3f 23 00 00       	call   80109523 <get_curr_disk>
801071e4:	85 c0                	test   %eax,%eax
801071e6:	79 05                	jns    801071ed <sys_df+0xd3>
801071e8:	05 ff 03 00 00       	add    $0x3ff,%eax
801071ed:	c1 f8 0a             	sar    $0xa,%eax
801071f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d -- %d  / Disk Available: %d\n", used, get_curr_disk(x),  get_max_disk(x));
801071f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071f6:	89 04 24             	mov    %eax,(%esp)
801071f9:	e8 65 22 00 00       	call   80109463 <get_max_disk>
801071fe:	89 c3                	mov    %eax,%ebx
80107200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107203:	89 04 24             	mov    %eax,(%esp)
80107206:	e8 18 23 00 00       	call   80109523 <get_curr_disk>
8010720b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010720f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107213:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010721a:	c7 04 24 80 a0 10 80 	movl   $0x8010a080,(%esp)
80107221:	e8 9b 91 ff ff       	call   801003c1 <cprintf>
  }
}
80107226:	83 c4 54             	add    $0x54,%esp
80107229:	5b                   	pop    %ebx
8010722a:	5d                   	pop    %ebp
8010722b:	c3                   	ret    

8010722c <sys_pause>:

void
sys_pause(void){
8010722c:	55                   	push   %ebp
8010722d:	89 e5                	mov    %esp,%ebp
8010722f:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107232:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107235:	89 44 24 04          	mov    %eax,0x4(%esp)
80107239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107240:	e8 5f e9 ff ff       	call   80105ba4 <argstr>
  pause(name);
80107245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107248:	89 04 24             	mov    %eax,(%esp)
8010724b:	e8 f8 e0 ff ff       	call   80105348 <pause>
}
80107250:	c9                   	leave  
80107251:	c3                   	ret    

80107252 <sys_resume>:

void
sys_resume(void){
80107252:	55                   	push   %ebp
80107253:	89 e5                	mov    %esp,%ebp
80107255:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107258:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010725b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010725f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107266:	e8 39 e9 ff ff       	call   80105ba4 <argstr>
  resume(name);
8010726b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726e:	89 04 24             	mov    %eax,(%esp)
80107271:	e8 35 e1 ff ff       	call   801053ab <resume>
}
80107276:	c9                   	leave  
80107277:	c3                   	ret    

80107278 <sys_tmem>:

int
sys_tmem(void){
80107278:	55                   	push   %ebp
80107279:	89 e5                	mov    %esp,%ebp
8010727b:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
8010727e:	e8 b0 d2 ff ff       	call   80104533 <myproc>
80107283:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107289:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
8010728c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107290:	75 07                	jne    80107299 <sys_tmem+0x21>
    return mem_usage();
80107292:	e8 ed bc ff ff       	call   80102f84 <mem_usage>
80107297:	eb 16                	jmp    801072af <sys_tmem+0x37>
  }
  return get_curr_mem(find(cont->name));
80107299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729c:	83 c0 18             	add    $0x18,%eax
8010729f:	89 04 24             	mov    %eax,(%esp)
801072a2:	e8 a4 20 00 00       	call   8010934b <find>
801072a7:	89 04 24             	mov    %eax,(%esp)
801072aa:	e8 34 22 00 00       	call   801094e3 <get_curr_mem>
}
801072af:	c9                   	leave  
801072b0:	c3                   	ret    

801072b1 <sys_amem>:

int
sys_amem(void){
801072b1:	55                   	push   %ebp
801072b2:	89 e5                	mov    %esp,%ebp
801072b4:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
801072b7:	e8 77 d2 ff ff       	call   80104533 <myproc>
801072bc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801072c2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801072c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072c9:	75 07                	jne    801072d2 <sys_amem+0x21>
    return mem_avail();
801072cb:	e8 be bc ff ff       	call   80102f8e <mem_avail>
801072d0:	eb 16                	jmp    801072e8 <sys_amem+0x37>
  }
  return get_max_mem(find(cont->name));
801072d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d5:	83 c0 18             	add    $0x18,%eax
801072d8:	89 04 24             	mov    %eax,(%esp)
801072db:	e8 6b 20 00 00       	call   8010934b <find>
801072e0:	89 04 24             	mov    %eax,(%esp)
801072e3:	e8 3b 21 00 00       	call   80109423 <get_max_mem>
}
801072e8:	c9                   	leave  
801072e9:	c3                   	ret    

801072ea <sys_c_ps>:

void sys_c_ps(void){
801072ea:	55                   	push   %ebp
801072eb:	89 e5                	mov    %esp,%ebp
801072ed:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
801072f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801072f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801072fe:	e8 a1 e8 ff ff       	call   80105ba4 <argstr>
  c_procdump(name);
80107303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107306:	89 04 24             	mov    %eax,(%esp)
80107309:	e8 4f df ff ff       	call   8010525d <c_procdump>
}
8010730e:	c9                   	leave  
8010730f:	c3                   	ret    

80107310 <sys_get_used>:

int sys_get_used(void){
80107310:	55                   	push   %ebp
80107311:	89 e5                	mov    %esp,%ebp
80107313:	83 ec 28             	sub    $0x28,%esp
  int x; 
  argint(0, &x);
80107316:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107319:	89 44 24 04          	mov    %eax,0x4(%esp)
8010731d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107324:	e8 e4 e7 ff ff       	call   80105b0d <argint>
  return get_used(x);
80107329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732c:	89 04 24             	mov    %eax,(%esp)
8010732f:	e8 45 1f 00 00       	call   80109279 <get_used>
}
80107334:	c9                   	leave  
80107335:	c3                   	ret    
	...

80107338 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107338:	1e                   	push   %ds
  pushl %es
80107339:	06                   	push   %es
  pushl %fs
8010733a:	0f a0                	push   %fs
  pushl %gs
8010733c:	0f a8                	push   %gs
  pushal
8010733e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010733f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107343:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107345:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80107347:	54                   	push   %esp
  call trap
80107348:	e8 c0 01 00 00       	call   8010750d <trap>
  addl $4, %esp
8010734d:	83 c4 04             	add    $0x4,%esp

80107350 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107350:	61                   	popa   
  popl %gs
80107351:	0f a9                	pop    %gs
  popl %fs
80107353:	0f a1                	pop    %fs
  popl %es
80107355:	07                   	pop    %es
  popl %ds
80107356:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107357:	83 c4 08             	add    $0x8,%esp
  iret
8010735a:	cf                   	iret   
	...

8010735c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010735c:	55                   	push   %ebp
8010735d:	89 e5                	mov    %esp,%ebp
8010735f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107362:	8b 45 0c             	mov    0xc(%ebp),%eax
80107365:	48                   	dec    %eax
80107366:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010736a:	8b 45 08             	mov    0x8(%ebp),%eax
8010736d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107371:	8b 45 08             	mov    0x8(%ebp),%eax
80107374:	c1 e8 10             	shr    $0x10,%eax
80107377:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010737b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010737e:	0f 01 18             	lidtl  (%eax)
}
80107381:	c9                   	leave  
80107382:	c3                   	ret    

80107383 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107383:	55                   	push   %ebp
80107384:	89 e5                	mov    %esp,%ebp
80107386:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107389:	0f 20 d0             	mov    %cr2,%eax
8010738c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010738f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107392:	c9                   	leave  
80107393:	c3                   	ret    

80107394 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107394:	55                   	push   %ebp
80107395:	89 e5                	mov    %esp,%ebp
80107397:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010739a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801073a1:	e9 b8 00 00 00       	jmp    8010745e <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a9:	8b 04 85 18 d1 10 80 	mov    -0x7fef2ee8(,%eax,4),%eax
801073b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801073b3:	66 89 04 d5 e0 84 11 	mov    %ax,-0x7fee7b20(,%edx,8)
801073ba:	80 
801073bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073be:	66 c7 04 c5 e2 84 11 	movw   $0x8,-0x7fee7b1e(,%eax,8)
801073c5:	80 08 00 
801073c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cb:	8a 14 c5 e4 84 11 80 	mov    -0x7fee7b1c(,%eax,8),%dl
801073d2:	83 e2 e0             	and    $0xffffffe0,%edx
801073d5:	88 14 c5 e4 84 11 80 	mov    %dl,-0x7fee7b1c(,%eax,8)
801073dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073df:	8a 14 c5 e4 84 11 80 	mov    -0x7fee7b1c(,%eax,8),%dl
801073e6:	83 e2 1f             	and    $0x1f,%edx
801073e9:	88 14 c5 e4 84 11 80 	mov    %dl,-0x7fee7b1c(,%eax,8)
801073f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f3:	8a 14 c5 e5 84 11 80 	mov    -0x7fee7b1b(,%eax,8),%dl
801073fa:	83 e2 f0             	and    $0xfffffff0,%edx
801073fd:	83 ca 0e             	or     $0xe,%edx
80107400:	88 14 c5 e5 84 11 80 	mov    %dl,-0x7fee7b1b(,%eax,8)
80107407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740a:	8a 14 c5 e5 84 11 80 	mov    -0x7fee7b1b(,%eax,8),%dl
80107411:	83 e2 ef             	and    $0xffffffef,%edx
80107414:	88 14 c5 e5 84 11 80 	mov    %dl,-0x7fee7b1b(,%eax,8)
8010741b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741e:	8a 14 c5 e5 84 11 80 	mov    -0x7fee7b1b(,%eax,8),%dl
80107425:	83 e2 9f             	and    $0xffffff9f,%edx
80107428:	88 14 c5 e5 84 11 80 	mov    %dl,-0x7fee7b1b(,%eax,8)
8010742f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107432:	8a 14 c5 e5 84 11 80 	mov    -0x7fee7b1b(,%eax,8),%dl
80107439:	83 ca 80             	or     $0xffffff80,%edx
8010743c:	88 14 c5 e5 84 11 80 	mov    %dl,-0x7fee7b1b(,%eax,8)
80107443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107446:	8b 04 85 18 d1 10 80 	mov    -0x7fef2ee8(,%eax,4),%eax
8010744d:	c1 e8 10             	shr    $0x10,%eax
80107450:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107453:	66 89 04 d5 e6 84 11 	mov    %ax,-0x7fee7b1a(,%edx,8)
8010745a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010745b:	ff 45 f4             	incl   -0xc(%ebp)
8010745e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107465:	0f 8e 3b ff ff ff    	jle    801073a6 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010746b:	a1 18 d2 10 80       	mov    0x8010d218,%eax
80107470:	66 a3 e0 86 11 80    	mov    %ax,0x801186e0
80107476:	66 c7 05 e2 86 11 80 	movw   $0x8,0x801186e2
8010747d:	08 00 
8010747f:	a0 e4 86 11 80       	mov    0x801186e4,%al
80107484:	83 e0 e0             	and    $0xffffffe0,%eax
80107487:	a2 e4 86 11 80       	mov    %al,0x801186e4
8010748c:	a0 e4 86 11 80       	mov    0x801186e4,%al
80107491:	83 e0 1f             	and    $0x1f,%eax
80107494:	a2 e4 86 11 80       	mov    %al,0x801186e4
80107499:	a0 e5 86 11 80       	mov    0x801186e5,%al
8010749e:	83 c8 0f             	or     $0xf,%eax
801074a1:	a2 e5 86 11 80       	mov    %al,0x801186e5
801074a6:	a0 e5 86 11 80       	mov    0x801186e5,%al
801074ab:	83 e0 ef             	and    $0xffffffef,%eax
801074ae:	a2 e5 86 11 80       	mov    %al,0x801186e5
801074b3:	a0 e5 86 11 80       	mov    0x801186e5,%al
801074b8:	83 c8 60             	or     $0x60,%eax
801074bb:	a2 e5 86 11 80       	mov    %al,0x801186e5
801074c0:	a0 e5 86 11 80       	mov    0x801186e5,%al
801074c5:	83 c8 80             	or     $0xffffff80,%eax
801074c8:	a2 e5 86 11 80       	mov    %al,0x801186e5
801074cd:	a1 18 d2 10 80       	mov    0x8010d218,%eax
801074d2:	c1 e8 10             	shr    $0x10,%eax
801074d5:	66 a3 e6 86 11 80    	mov    %ax,0x801186e6

  initlock(&tickslock, "time");
801074db:	c7 44 24 04 ac a0 10 	movl   $0x8010a0ac,0x4(%esp)
801074e2:	80 
801074e3:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
801074ea:	e8 67 e0 ff ff       	call   80105556 <initlock>
}
801074ef:	c9                   	leave  
801074f0:	c3                   	ret    

801074f1 <idtinit>:

void
idtinit(void)
{
801074f1:	55                   	push   %ebp
801074f2:	89 e5                	mov    %esp,%ebp
801074f4:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801074f7:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801074fe:	00 
801074ff:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80107506:	e8 51 fe ff ff       	call   8010735c <lidt>
}
8010750b:	c9                   	leave  
8010750c:	c3                   	ret    

8010750d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010750d:	55                   	push   %ebp
8010750e:	89 e5                	mov    %esp,%ebp
80107510:	57                   	push   %edi
80107511:	56                   	push   %esi
80107512:	53                   	push   %ebx
80107513:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80107516:	8b 45 08             	mov    0x8(%ebp),%eax
80107519:	8b 40 30             	mov    0x30(%eax),%eax
8010751c:	83 f8 40             	cmp    $0x40,%eax
8010751f:	75 3c                	jne    8010755d <trap+0x50>
    if(myproc()->killed)
80107521:	e8 0d d0 ff ff       	call   80104533 <myproc>
80107526:	8b 40 24             	mov    0x24(%eax),%eax
80107529:	85 c0                	test   %eax,%eax
8010752b:	74 05                	je     80107532 <trap+0x25>
      exit();
8010752d:	e8 92 d4 ff ff       	call   801049c4 <exit>
    myproc()->tf = tf;
80107532:	e8 fc cf ff ff       	call   80104533 <myproc>
80107537:	8b 55 08             	mov    0x8(%ebp),%edx
8010753a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010753d:	e8 99 e6 ff ff       	call   80105bdb <syscall>
    if(myproc()->killed)
80107542:	e8 ec cf ff ff       	call   80104533 <myproc>
80107547:	8b 40 24             	mov    0x24(%eax),%eax
8010754a:	85 c0                	test   %eax,%eax
8010754c:	74 0a                	je     80107558 <trap+0x4b>
      exit();
8010754e:	e8 71 d4 ff ff       	call   801049c4 <exit>
    return;
80107553:	e9 30 02 00 00       	jmp    80107788 <trap+0x27b>
80107558:	e9 2b 02 00 00       	jmp    80107788 <trap+0x27b>
  }

  switch(tf->trapno){
8010755d:	8b 45 08             	mov    0x8(%ebp),%eax
80107560:	8b 40 30             	mov    0x30(%eax),%eax
80107563:	83 e8 20             	sub    $0x20,%eax
80107566:	83 f8 1f             	cmp    $0x1f,%eax
80107569:	0f 87 cb 00 00 00    	ja     8010763a <trap+0x12d>
8010756f:	8b 04 85 54 a1 10 80 	mov    -0x7fef5eac(,%eax,4),%eax
80107576:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107578:	e8 ed ce ff ff       	call   8010446a <cpuid>
8010757d:	85 c0                	test   %eax,%eax
8010757f:	75 2f                	jne    801075b0 <trap+0xa3>
      acquire(&tickslock);
80107581:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
80107588:	e8 ea df ff ff       	call   80105577 <acquire>
      ticks++;
8010758d:	a1 e0 8c 11 80       	mov    0x80118ce0,%eax
80107592:	40                   	inc    %eax
80107593:	a3 e0 8c 11 80       	mov    %eax,0x80118ce0
      wakeup(&ticks);
80107598:	c7 04 24 e0 8c 11 80 	movl   $0x80118ce0,(%esp)
8010759f:	e8 be d9 ff ff       	call   80104f62 <wakeup>
      release(&tickslock);
801075a4:	c7 04 24 a0 84 11 80 	movl   $0x801184a0,(%esp)
801075ab:	e8 31 e0 ff ff       	call   801055e1 <release>
    }
    p = myproc();
801075b0:	e8 7e cf ff ff       	call   80104533 <myproc>
801075b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801075b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801075bc:	74 0f                	je     801075cd <trap+0xc0>
      p->ticks++;
801075be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075c1:	8b 40 7c             	mov    0x7c(%eax),%eax
801075c4:	8d 50 01             	lea    0x1(%eax),%edx
801075c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075ca:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801075cd:	e8 39 bd ff ff       	call   8010330b <lapiceoi>
    break;
801075d2:	e9 35 01 00 00       	jmp    8010770c <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801075d7:	e8 7e b4 ff ff       	call   80102a5a <ideintr>
    lapiceoi();
801075dc:	e8 2a bd ff ff       	call   8010330b <lapiceoi>
    break;
801075e1:	e9 26 01 00 00       	jmp    8010770c <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801075e6:	e8 37 bb ff ff       	call   80103122 <kbdintr>
    lapiceoi();
801075eb:	e8 1b bd ff ff       	call   8010330b <lapiceoi>
    break;
801075f0:	e9 17 01 00 00       	jmp    8010770c <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075f5:	e8 6f 03 00 00       	call   80107969 <uartintr>
    lapiceoi();
801075fa:	e8 0c bd ff ff       	call   8010330b <lapiceoi>
    break;
801075ff:	e9 08 01 00 00       	jmp    8010770c <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107604:	8b 45 08             	mov    0x8(%ebp),%eax
80107607:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010760a:	8b 45 08             	mov    0x8(%ebp),%eax
8010760d:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107610:	0f b7 d8             	movzwl %ax,%ebx
80107613:	e8 52 ce ff ff       	call   8010446a <cpuid>
80107618:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010761c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107620:	89 44 24 04          	mov    %eax,0x4(%esp)
80107624:	c7 04 24 b4 a0 10 80 	movl   $0x8010a0b4,(%esp)
8010762b:	e8 91 8d ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107630:	e8 d6 bc ff ff       	call   8010330b <lapiceoi>
    break;
80107635:	e9 d2 00 00 00       	jmp    8010770c <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010763a:	e8 f4 ce ff ff       	call   80104533 <myproc>
8010763f:	85 c0                	test   %eax,%eax
80107641:	74 10                	je     80107653 <trap+0x146>
80107643:	8b 45 08             	mov    0x8(%ebp),%eax
80107646:	8b 40 3c             	mov    0x3c(%eax),%eax
80107649:	0f b7 c0             	movzwl %ax,%eax
8010764c:	83 e0 03             	and    $0x3,%eax
8010764f:	85 c0                	test   %eax,%eax
80107651:	75 40                	jne    80107693 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107653:	e8 2b fd ff ff       	call   80107383 <rcr2>
80107658:	89 c3                	mov    %eax,%ebx
8010765a:	8b 45 08             	mov    0x8(%ebp),%eax
8010765d:	8b 70 38             	mov    0x38(%eax),%esi
80107660:	e8 05 ce ff ff       	call   8010446a <cpuid>
80107665:	8b 55 08             	mov    0x8(%ebp),%edx
80107668:	8b 52 30             	mov    0x30(%edx),%edx
8010766b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010766f:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107673:	89 44 24 08          	mov    %eax,0x8(%esp)
80107677:	89 54 24 04          	mov    %edx,0x4(%esp)
8010767b:	c7 04 24 d8 a0 10 80 	movl   $0x8010a0d8,(%esp)
80107682:	e8 3a 8d ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107687:	c7 04 24 0a a1 10 80 	movl   $0x8010a10a,(%esp)
8010768e:	e8 c1 8e ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107693:	e8 eb fc ff ff       	call   80107383 <rcr2>
80107698:	89 c6                	mov    %eax,%esi
8010769a:	8b 45 08             	mov    0x8(%ebp),%eax
8010769d:	8b 40 38             	mov    0x38(%eax),%eax
801076a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801076a3:	e8 c2 cd ff ff       	call   8010446a <cpuid>
801076a8:	89 c3                	mov    %eax,%ebx
801076aa:	8b 45 08             	mov    0x8(%ebp),%eax
801076ad:	8b 78 34             	mov    0x34(%eax),%edi
801076b0:	89 7d d0             	mov    %edi,-0x30(%ebp)
801076b3:	8b 45 08             	mov    0x8(%ebp),%eax
801076b6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801076b9:	e8 75 ce ff ff       	call   80104533 <myproc>
801076be:	8d 50 6c             	lea    0x6c(%eax),%edx
801076c1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801076c4:	e8 6a ce ff ff       	call   80104533 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076c9:	8b 40 10             	mov    0x10(%eax),%eax
801076cc:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801076d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801076d3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801076d7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801076db:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801076de:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801076e2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801076e6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801076e9:	89 54 24 08          	mov    %edx,0x8(%esp)
801076ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801076f1:	c7 04 24 10 a1 10 80 	movl   $0x8010a110,(%esp)
801076f8:	e8 c4 8c ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801076fd:	e8 31 ce ff ff       	call   80104533 <myproc>
80107702:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107709:	eb 01                	jmp    8010770c <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010770b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010770c:	e8 22 ce ff ff       	call   80104533 <myproc>
80107711:	85 c0                	test   %eax,%eax
80107713:	74 22                	je     80107737 <trap+0x22a>
80107715:	e8 19 ce ff ff       	call   80104533 <myproc>
8010771a:	8b 40 24             	mov    0x24(%eax),%eax
8010771d:	85 c0                	test   %eax,%eax
8010771f:	74 16                	je     80107737 <trap+0x22a>
80107721:	8b 45 08             	mov    0x8(%ebp),%eax
80107724:	8b 40 3c             	mov    0x3c(%eax),%eax
80107727:	0f b7 c0             	movzwl %ax,%eax
8010772a:	83 e0 03             	and    $0x3,%eax
8010772d:	83 f8 03             	cmp    $0x3,%eax
80107730:	75 05                	jne    80107737 <trap+0x22a>
    exit();
80107732:	e8 8d d2 ff ff       	call   801049c4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107737:	e8 f7 cd ff ff       	call   80104533 <myproc>
8010773c:	85 c0                	test   %eax,%eax
8010773e:	74 1d                	je     8010775d <trap+0x250>
80107740:	e8 ee cd ff ff       	call   80104533 <myproc>
80107745:	8b 40 0c             	mov    0xc(%eax),%eax
80107748:	83 f8 04             	cmp    $0x4,%eax
8010774b:	75 10                	jne    8010775d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010774d:	8b 45 08             	mov    0x8(%ebp),%eax
80107750:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107753:	83 f8 20             	cmp    $0x20,%eax
80107756:	75 05                	jne    8010775d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107758:	e8 be d6 ff ff       	call   80104e1b <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010775d:	e8 d1 cd ff ff       	call   80104533 <myproc>
80107762:	85 c0                	test   %eax,%eax
80107764:	74 22                	je     80107788 <trap+0x27b>
80107766:	e8 c8 cd ff ff       	call   80104533 <myproc>
8010776b:	8b 40 24             	mov    0x24(%eax),%eax
8010776e:	85 c0                	test   %eax,%eax
80107770:	74 16                	je     80107788 <trap+0x27b>
80107772:	8b 45 08             	mov    0x8(%ebp),%eax
80107775:	8b 40 3c             	mov    0x3c(%eax),%eax
80107778:	0f b7 c0             	movzwl %ax,%eax
8010777b:	83 e0 03             	and    $0x3,%eax
8010777e:	83 f8 03             	cmp    $0x3,%eax
80107781:	75 05                	jne    80107788 <trap+0x27b>
    exit();
80107783:	e8 3c d2 ff ff       	call   801049c4 <exit>
}
80107788:	83 c4 4c             	add    $0x4c,%esp
8010778b:	5b                   	pop    %ebx
8010778c:	5e                   	pop    %esi
8010778d:	5f                   	pop    %edi
8010778e:	5d                   	pop    %ebp
8010778f:	c3                   	ret    

80107790 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107790:	55                   	push   %ebp
80107791:	89 e5                	mov    %esp,%ebp
80107793:	83 ec 14             	sub    $0x14,%esp
80107796:	8b 45 08             	mov    0x8(%ebp),%eax
80107799:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010779d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077a0:	89 c2                	mov    %eax,%edx
801077a2:	ec                   	in     (%dx),%al
801077a3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801077a6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801077a9:	c9                   	leave  
801077aa:	c3                   	ret    

801077ab <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801077ab:	55                   	push   %ebp
801077ac:	89 e5                	mov    %esp,%ebp
801077ae:	83 ec 08             	sub    $0x8,%esp
801077b1:	8b 45 08             	mov    0x8(%ebp),%eax
801077b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801077b7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801077bb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801077be:	8a 45 f8             	mov    -0x8(%ebp),%al
801077c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801077c4:	ee                   	out    %al,(%dx)
}
801077c5:	c9                   	leave  
801077c6:	c3                   	ret    

801077c7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801077c7:	55                   	push   %ebp
801077c8:	89 e5                	mov    %esp,%ebp
801077ca:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801077cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077d4:	00 
801077d5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801077dc:	e8 ca ff ff ff       	call   801077ab <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801077e1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801077e8:	00 
801077e9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801077f0:	e8 b6 ff ff ff       	call   801077ab <outb>
  outb(COM1+0, 115200/9600);
801077f5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801077fc:	00 
801077fd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107804:	e8 a2 ff ff ff       	call   801077ab <outb>
  outb(COM1+1, 0);
80107809:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107810:	00 
80107811:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107818:	e8 8e ff ff ff       	call   801077ab <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010781d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107824:	00 
80107825:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010782c:	e8 7a ff ff ff       	call   801077ab <outb>
  outb(COM1+4, 0);
80107831:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107838:	00 
80107839:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107840:	e8 66 ff ff ff       	call   801077ab <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107845:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010784c:	00 
8010784d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107854:	e8 52 ff ff ff       	call   801077ab <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107859:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107860:	e8 2b ff ff ff       	call   80107790 <inb>
80107865:	3c ff                	cmp    $0xff,%al
80107867:	75 02                	jne    8010786b <uartinit+0xa4>
    return;
80107869:	eb 5b                	jmp    801078c6 <uartinit+0xff>
  uart = 1;
8010786b:	c7 05 24 d9 10 80 01 	movl   $0x1,0x8010d924
80107872:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107875:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010787c:	e8 0f ff ff ff       	call   80107790 <inb>
  inb(COM1+0);
80107881:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107888:	e8 03 ff ff ff       	call   80107790 <inb>
  ioapicenable(IRQ_COM1, 0);
8010788d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107894:	00 
80107895:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010789c:	e8 2e b4 ff ff       	call   80102ccf <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078a1:	c7 45 f4 d4 a1 10 80 	movl   $0x8010a1d4,-0xc(%ebp)
801078a8:	eb 13                	jmp    801078bd <uartinit+0xf6>
    uartputc(*p);
801078aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ad:	8a 00                	mov    (%eax),%al
801078af:	0f be c0             	movsbl %al,%eax
801078b2:	89 04 24             	mov    %eax,(%esp)
801078b5:	e8 0e 00 00 00       	call   801078c8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078ba:	ff 45 f4             	incl   -0xc(%ebp)
801078bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c0:	8a 00                	mov    (%eax),%al
801078c2:	84 c0                	test   %al,%al
801078c4:	75 e4                	jne    801078aa <uartinit+0xe3>
    uartputc(*p);
}
801078c6:	c9                   	leave  
801078c7:	c3                   	ret    

801078c8 <uartputc>:

void
uartputc(int c)
{
801078c8:	55                   	push   %ebp
801078c9:	89 e5                	mov    %esp,%ebp
801078cb:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801078ce:	a1 24 d9 10 80       	mov    0x8010d924,%eax
801078d3:	85 c0                	test   %eax,%eax
801078d5:	75 02                	jne    801078d9 <uartputc+0x11>
    return;
801078d7:	eb 4a                	jmp    80107923 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078e0:	eb 0f                	jmp    801078f1 <uartputc+0x29>
    microdelay(10);
801078e2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801078e9:	e8 42 ba ff ff       	call   80103330 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078ee:	ff 45 f4             	incl   -0xc(%ebp)
801078f1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801078f5:	7f 16                	jg     8010790d <uartputc+0x45>
801078f7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801078fe:	e8 8d fe ff ff       	call   80107790 <inb>
80107903:	0f b6 c0             	movzbl %al,%eax
80107906:	83 e0 20             	and    $0x20,%eax
80107909:	85 c0                	test   %eax,%eax
8010790b:	74 d5                	je     801078e2 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
8010790d:	8b 45 08             	mov    0x8(%ebp),%eax
80107910:	0f b6 c0             	movzbl %al,%eax
80107913:	89 44 24 04          	mov    %eax,0x4(%esp)
80107917:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010791e:	e8 88 fe ff ff       	call   801077ab <outb>
}
80107923:	c9                   	leave  
80107924:	c3                   	ret    

80107925 <uartgetc>:

static int
uartgetc(void)
{
80107925:	55                   	push   %ebp
80107926:	89 e5                	mov    %esp,%ebp
80107928:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010792b:	a1 24 d9 10 80       	mov    0x8010d924,%eax
80107930:	85 c0                	test   %eax,%eax
80107932:	75 07                	jne    8010793b <uartgetc+0x16>
    return -1;
80107934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107939:	eb 2c                	jmp    80107967 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010793b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107942:	e8 49 fe ff ff       	call   80107790 <inb>
80107947:	0f b6 c0             	movzbl %al,%eax
8010794a:	83 e0 01             	and    $0x1,%eax
8010794d:	85 c0                	test   %eax,%eax
8010794f:	75 07                	jne    80107958 <uartgetc+0x33>
    return -1;
80107951:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107956:	eb 0f                	jmp    80107967 <uartgetc+0x42>
  return inb(COM1+0);
80107958:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010795f:	e8 2c fe ff ff       	call   80107790 <inb>
80107964:	0f b6 c0             	movzbl %al,%eax
}
80107967:	c9                   	leave  
80107968:	c3                   	ret    

80107969 <uartintr>:

void
uartintr(void)
{
80107969:	55                   	push   %ebp
8010796a:	89 e5                	mov    %esp,%ebp
8010796c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010796f:	c7 04 24 25 79 10 80 	movl   $0x80107925,(%esp)
80107976:	e8 7a 8e ff ff       	call   801007f5 <consoleintr>
}
8010797b:	c9                   	leave  
8010797c:	c3                   	ret    
8010797d:	00 00                	add    %al,(%eax)
	...

80107980 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107980:	6a 00                	push   $0x0
  pushl $0
80107982:	6a 00                	push   $0x0
  jmp alltraps
80107984:	e9 af f9 ff ff       	jmp    80107338 <alltraps>

80107989 <vector1>:
.globl vector1
vector1:
  pushl $0
80107989:	6a 00                	push   $0x0
  pushl $1
8010798b:	6a 01                	push   $0x1
  jmp alltraps
8010798d:	e9 a6 f9 ff ff       	jmp    80107338 <alltraps>

80107992 <vector2>:
.globl vector2
vector2:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $2
80107994:	6a 02                	push   $0x2
  jmp alltraps
80107996:	e9 9d f9 ff ff       	jmp    80107338 <alltraps>

8010799b <vector3>:
.globl vector3
vector3:
  pushl $0
8010799b:	6a 00                	push   $0x0
  pushl $3
8010799d:	6a 03                	push   $0x3
  jmp alltraps
8010799f:	e9 94 f9 ff ff       	jmp    80107338 <alltraps>

801079a4 <vector4>:
.globl vector4
vector4:
  pushl $0
801079a4:	6a 00                	push   $0x0
  pushl $4
801079a6:	6a 04                	push   $0x4
  jmp alltraps
801079a8:	e9 8b f9 ff ff       	jmp    80107338 <alltraps>

801079ad <vector5>:
.globl vector5
vector5:
  pushl $0
801079ad:	6a 00                	push   $0x0
  pushl $5
801079af:	6a 05                	push   $0x5
  jmp alltraps
801079b1:	e9 82 f9 ff ff       	jmp    80107338 <alltraps>

801079b6 <vector6>:
.globl vector6
vector6:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $6
801079b8:	6a 06                	push   $0x6
  jmp alltraps
801079ba:	e9 79 f9 ff ff       	jmp    80107338 <alltraps>

801079bf <vector7>:
.globl vector7
vector7:
  pushl $0
801079bf:	6a 00                	push   $0x0
  pushl $7
801079c1:	6a 07                	push   $0x7
  jmp alltraps
801079c3:	e9 70 f9 ff ff       	jmp    80107338 <alltraps>

801079c8 <vector8>:
.globl vector8
vector8:
  pushl $8
801079c8:	6a 08                	push   $0x8
  jmp alltraps
801079ca:	e9 69 f9 ff ff       	jmp    80107338 <alltraps>

801079cf <vector9>:
.globl vector9
vector9:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $9
801079d1:	6a 09                	push   $0x9
  jmp alltraps
801079d3:	e9 60 f9 ff ff       	jmp    80107338 <alltraps>

801079d8 <vector10>:
.globl vector10
vector10:
  pushl $10
801079d8:	6a 0a                	push   $0xa
  jmp alltraps
801079da:	e9 59 f9 ff ff       	jmp    80107338 <alltraps>

801079df <vector11>:
.globl vector11
vector11:
  pushl $11
801079df:	6a 0b                	push   $0xb
  jmp alltraps
801079e1:	e9 52 f9 ff ff       	jmp    80107338 <alltraps>

801079e6 <vector12>:
.globl vector12
vector12:
  pushl $12
801079e6:	6a 0c                	push   $0xc
  jmp alltraps
801079e8:	e9 4b f9 ff ff       	jmp    80107338 <alltraps>

801079ed <vector13>:
.globl vector13
vector13:
  pushl $13
801079ed:	6a 0d                	push   $0xd
  jmp alltraps
801079ef:	e9 44 f9 ff ff       	jmp    80107338 <alltraps>

801079f4 <vector14>:
.globl vector14
vector14:
  pushl $14
801079f4:	6a 0e                	push   $0xe
  jmp alltraps
801079f6:	e9 3d f9 ff ff       	jmp    80107338 <alltraps>

801079fb <vector15>:
.globl vector15
vector15:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $15
801079fd:	6a 0f                	push   $0xf
  jmp alltraps
801079ff:	e9 34 f9 ff ff       	jmp    80107338 <alltraps>

80107a04 <vector16>:
.globl vector16
vector16:
  pushl $0
80107a04:	6a 00                	push   $0x0
  pushl $16
80107a06:	6a 10                	push   $0x10
  jmp alltraps
80107a08:	e9 2b f9 ff ff       	jmp    80107338 <alltraps>

80107a0d <vector17>:
.globl vector17
vector17:
  pushl $17
80107a0d:	6a 11                	push   $0x11
  jmp alltraps
80107a0f:	e9 24 f9 ff ff       	jmp    80107338 <alltraps>

80107a14 <vector18>:
.globl vector18
vector18:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $18
80107a16:	6a 12                	push   $0x12
  jmp alltraps
80107a18:	e9 1b f9 ff ff       	jmp    80107338 <alltraps>

80107a1d <vector19>:
.globl vector19
vector19:
  pushl $0
80107a1d:	6a 00                	push   $0x0
  pushl $19
80107a1f:	6a 13                	push   $0x13
  jmp alltraps
80107a21:	e9 12 f9 ff ff       	jmp    80107338 <alltraps>

80107a26 <vector20>:
.globl vector20
vector20:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $20
80107a28:	6a 14                	push   $0x14
  jmp alltraps
80107a2a:	e9 09 f9 ff ff       	jmp    80107338 <alltraps>

80107a2f <vector21>:
.globl vector21
vector21:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $21
80107a31:	6a 15                	push   $0x15
  jmp alltraps
80107a33:	e9 00 f9 ff ff       	jmp    80107338 <alltraps>

80107a38 <vector22>:
.globl vector22
vector22:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $22
80107a3a:	6a 16                	push   $0x16
  jmp alltraps
80107a3c:	e9 f7 f8 ff ff       	jmp    80107338 <alltraps>

80107a41 <vector23>:
.globl vector23
vector23:
  pushl $0
80107a41:	6a 00                	push   $0x0
  pushl $23
80107a43:	6a 17                	push   $0x17
  jmp alltraps
80107a45:	e9 ee f8 ff ff       	jmp    80107338 <alltraps>

80107a4a <vector24>:
.globl vector24
vector24:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $24
80107a4c:	6a 18                	push   $0x18
  jmp alltraps
80107a4e:	e9 e5 f8 ff ff       	jmp    80107338 <alltraps>

80107a53 <vector25>:
.globl vector25
vector25:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $25
80107a55:	6a 19                	push   $0x19
  jmp alltraps
80107a57:	e9 dc f8 ff ff       	jmp    80107338 <alltraps>

80107a5c <vector26>:
.globl vector26
vector26:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $26
80107a5e:	6a 1a                	push   $0x1a
  jmp alltraps
80107a60:	e9 d3 f8 ff ff       	jmp    80107338 <alltraps>

80107a65 <vector27>:
.globl vector27
vector27:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $27
80107a67:	6a 1b                	push   $0x1b
  jmp alltraps
80107a69:	e9 ca f8 ff ff       	jmp    80107338 <alltraps>

80107a6e <vector28>:
.globl vector28
vector28:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $28
80107a70:	6a 1c                	push   $0x1c
  jmp alltraps
80107a72:	e9 c1 f8 ff ff       	jmp    80107338 <alltraps>

80107a77 <vector29>:
.globl vector29
vector29:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $29
80107a79:	6a 1d                	push   $0x1d
  jmp alltraps
80107a7b:	e9 b8 f8 ff ff       	jmp    80107338 <alltraps>

80107a80 <vector30>:
.globl vector30
vector30:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $30
80107a82:	6a 1e                	push   $0x1e
  jmp alltraps
80107a84:	e9 af f8 ff ff       	jmp    80107338 <alltraps>

80107a89 <vector31>:
.globl vector31
vector31:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $31
80107a8b:	6a 1f                	push   $0x1f
  jmp alltraps
80107a8d:	e9 a6 f8 ff ff       	jmp    80107338 <alltraps>

80107a92 <vector32>:
.globl vector32
vector32:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $32
80107a94:	6a 20                	push   $0x20
  jmp alltraps
80107a96:	e9 9d f8 ff ff       	jmp    80107338 <alltraps>

80107a9b <vector33>:
.globl vector33
vector33:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $33
80107a9d:	6a 21                	push   $0x21
  jmp alltraps
80107a9f:	e9 94 f8 ff ff       	jmp    80107338 <alltraps>

80107aa4 <vector34>:
.globl vector34
vector34:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $34
80107aa6:	6a 22                	push   $0x22
  jmp alltraps
80107aa8:	e9 8b f8 ff ff       	jmp    80107338 <alltraps>

80107aad <vector35>:
.globl vector35
vector35:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $35
80107aaf:	6a 23                	push   $0x23
  jmp alltraps
80107ab1:	e9 82 f8 ff ff       	jmp    80107338 <alltraps>

80107ab6 <vector36>:
.globl vector36
vector36:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $36
80107ab8:	6a 24                	push   $0x24
  jmp alltraps
80107aba:	e9 79 f8 ff ff       	jmp    80107338 <alltraps>

80107abf <vector37>:
.globl vector37
vector37:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $37
80107ac1:	6a 25                	push   $0x25
  jmp alltraps
80107ac3:	e9 70 f8 ff ff       	jmp    80107338 <alltraps>

80107ac8 <vector38>:
.globl vector38
vector38:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $38
80107aca:	6a 26                	push   $0x26
  jmp alltraps
80107acc:	e9 67 f8 ff ff       	jmp    80107338 <alltraps>

80107ad1 <vector39>:
.globl vector39
vector39:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $39
80107ad3:	6a 27                	push   $0x27
  jmp alltraps
80107ad5:	e9 5e f8 ff ff       	jmp    80107338 <alltraps>

80107ada <vector40>:
.globl vector40
vector40:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $40
80107adc:	6a 28                	push   $0x28
  jmp alltraps
80107ade:	e9 55 f8 ff ff       	jmp    80107338 <alltraps>

80107ae3 <vector41>:
.globl vector41
vector41:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $41
80107ae5:	6a 29                	push   $0x29
  jmp alltraps
80107ae7:	e9 4c f8 ff ff       	jmp    80107338 <alltraps>

80107aec <vector42>:
.globl vector42
vector42:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $42
80107aee:	6a 2a                	push   $0x2a
  jmp alltraps
80107af0:	e9 43 f8 ff ff       	jmp    80107338 <alltraps>

80107af5 <vector43>:
.globl vector43
vector43:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $43
80107af7:	6a 2b                	push   $0x2b
  jmp alltraps
80107af9:	e9 3a f8 ff ff       	jmp    80107338 <alltraps>

80107afe <vector44>:
.globl vector44
vector44:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $44
80107b00:	6a 2c                	push   $0x2c
  jmp alltraps
80107b02:	e9 31 f8 ff ff       	jmp    80107338 <alltraps>

80107b07 <vector45>:
.globl vector45
vector45:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $45
80107b09:	6a 2d                	push   $0x2d
  jmp alltraps
80107b0b:	e9 28 f8 ff ff       	jmp    80107338 <alltraps>

80107b10 <vector46>:
.globl vector46
vector46:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $46
80107b12:	6a 2e                	push   $0x2e
  jmp alltraps
80107b14:	e9 1f f8 ff ff       	jmp    80107338 <alltraps>

80107b19 <vector47>:
.globl vector47
vector47:
  pushl $0
80107b19:	6a 00                	push   $0x0
  pushl $47
80107b1b:	6a 2f                	push   $0x2f
  jmp alltraps
80107b1d:	e9 16 f8 ff ff       	jmp    80107338 <alltraps>

80107b22 <vector48>:
.globl vector48
vector48:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $48
80107b24:	6a 30                	push   $0x30
  jmp alltraps
80107b26:	e9 0d f8 ff ff       	jmp    80107338 <alltraps>

80107b2b <vector49>:
.globl vector49
vector49:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $49
80107b2d:	6a 31                	push   $0x31
  jmp alltraps
80107b2f:	e9 04 f8 ff ff       	jmp    80107338 <alltraps>

80107b34 <vector50>:
.globl vector50
vector50:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $50
80107b36:	6a 32                	push   $0x32
  jmp alltraps
80107b38:	e9 fb f7 ff ff       	jmp    80107338 <alltraps>

80107b3d <vector51>:
.globl vector51
vector51:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $51
80107b3f:	6a 33                	push   $0x33
  jmp alltraps
80107b41:	e9 f2 f7 ff ff       	jmp    80107338 <alltraps>

80107b46 <vector52>:
.globl vector52
vector52:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $52
80107b48:	6a 34                	push   $0x34
  jmp alltraps
80107b4a:	e9 e9 f7 ff ff       	jmp    80107338 <alltraps>

80107b4f <vector53>:
.globl vector53
vector53:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $53
80107b51:	6a 35                	push   $0x35
  jmp alltraps
80107b53:	e9 e0 f7 ff ff       	jmp    80107338 <alltraps>

80107b58 <vector54>:
.globl vector54
vector54:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $54
80107b5a:	6a 36                	push   $0x36
  jmp alltraps
80107b5c:	e9 d7 f7 ff ff       	jmp    80107338 <alltraps>

80107b61 <vector55>:
.globl vector55
vector55:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $55
80107b63:	6a 37                	push   $0x37
  jmp alltraps
80107b65:	e9 ce f7 ff ff       	jmp    80107338 <alltraps>

80107b6a <vector56>:
.globl vector56
vector56:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $56
80107b6c:	6a 38                	push   $0x38
  jmp alltraps
80107b6e:	e9 c5 f7 ff ff       	jmp    80107338 <alltraps>

80107b73 <vector57>:
.globl vector57
vector57:
  pushl $0
80107b73:	6a 00                	push   $0x0
  pushl $57
80107b75:	6a 39                	push   $0x39
  jmp alltraps
80107b77:	e9 bc f7 ff ff       	jmp    80107338 <alltraps>

80107b7c <vector58>:
.globl vector58
vector58:
  pushl $0
80107b7c:	6a 00                	push   $0x0
  pushl $58
80107b7e:	6a 3a                	push   $0x3a
  jmp alltraps
80107b80:	e9 b3 f7 ff ff       	jmp    80107338 <alltraps>

80107b85 <vector59>:
.globl vector59
vector59:
  pushl $0
80107b85:	6a 00                	push   $0x0
  pushl $59
80107b87:	6a 3b                	push   $0x3b
  jmp alltraps
80107b89:	e9 aa f7 ff ff       	jmp    80107338 <alltraps>

80107b8e <vector60>:
.globl vector60
vector60:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $60
80107b90:	6a 3c                	push   $0x3c
  jmp alltraps
80107b92:	e9 a1 f7 ff ff       	jmp    80107338 <alltraps>

80107b97 <vector61>:
.globl vector61
vector61:
  pushl $0
80107b97:	6a 00                	push   $0x0
  pushl $61
80107b99:	6a 3d                	push   $0x3d
  jmp alltraps
80107b9b:	e9 98 f7 ff ff       	jmp    80107338 <alltraps>

80107ba0 <vector62>:
.globl vector62
vector62:
  pushl $0
80107ba0:	6a 00                	push   $0x0
  pushl $62
80107ba2:	6a 3e                	push   $0x3e
  jmp alltraps
80107ba4:	e9 8f f7 ff ff       	jmp    80107338 <alltraps>

80107ba9 <vector63>:
.globl vector63
vector63:
  pushl $0
80107ba9:	6a 00                	push   $0x0
  pushl $63
80107bab:	6a 3f                	push   $0x3f
  jmp alltraps
80107bad:	e9 86 f7 ff ff       	jmp    80107338 <alltraps>

80107bb2 <vector64>:
.globl vector64
vector64:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $64
80107bb4:	6a 40                	push   $0x40
  jmp alltraps
80107bb6:	e9 7d f7 ff ff       	jmp    80107338 <alltraps>

80107bbb <vector65>:
.globl vector65
vector65:
  pushl $0
80107bbb:	6a 00                	push   $0x0
  pushl $65
80107bbd:	6a 41                	push   $0x41
  jmp alltraps
80107bbf:	e9 74 f7 ff ff       	jmp    80107338 <alltraps>

80107bc4 <vector66>:
.globl vector66
vector66:
  pushl $0
80107bc4:	6a 00                	push   $0x0
  pushl $66
80107bc6:	6a 42                	push   $0x42
  jmp alltraps
80107bc8:	e9 6b f7 ff ff       	jmp    80107338 <alltraps>

80107bcd <vector67>:
.globl vector67
vector67:
  pushl $0
80107bcd:	6a 00                	push   $0x0
  pushl $67
80107bcf:	6a 43                	push   $0x43
  jmp alltraps
80107bd1:	e9 62 f7 ff ff       	jmp    80107338 <alltraps>

80107bd6 <vector68>:
.globl vector68
vector68:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $68
80107bd8:	6a 44                	push   $0x44
  jmp alltraps
80107bda:	e9 59 f7 ff ff       	jmp    80107338 <alltraps>

80107bdf <vector69>:
.globl vector69
vector69:
  pushl $0
80107bdf:	6a 00                	push   $0x0
  pushl $69
80107be1:	6a 45                	push   $0x45
  jmp alltraps
80107be3:	e9 50 f7 ff ff       	jmp    80107338 <alltraps>

80107be8 <vector70>:
.globl vector70
vector70:
  pushl $0
80107be8:	6a 00                	push   $0x0
  pushl $70
80107bea:	6a 46                	push   $0x46
  jmp alltraps
80107bec:	e9 47 f7 ff ff       	jmp    80107338 <alltraps>

80107bf1 <vector71>:
.globl vector71
vector71:
  pushl $0
80107bf1:	6a 00                	push   $0x0
  pushl $71
80107bf3:	6a 47                	push   $0x47
  jmp alltraps
80107bf5:	e9 3e f7 ff ff       	jmp    80107338 <alltraps>

80107bfa <vector72>:
.globl vector72
vector72:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $72
80107bfc:	6a 48                	push   $0x48
  jmp alltraps
80107bfe:	e9 35 f7 ff ff       	jmp    80107338 <alltraps>

80107c03 <vector73>:
.globl vector73
vector73:
  pushl $0
80107c03:	6a 00                	push   $0x0
  pushl $73
80107c05:	6a 49                	push   $0x49
  jmp alltraps
80107c07:	e9 2c f7 ff ff       	jmp    80107338 <alltraps>

80107c0c <vector74>:
.globl vector74
vector74:
  pushl $0
80107c0c:	6a 00                	push   $0x0
  pushl $74
80107c0e:	6a 4a                	push   $0x4a
  jmp alltraps
80107c10:	e9 23 f7 ff ff       	jmp    80107338 <alltraps>

80107c15 <vector75>:
.globl vector75
vector75:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $75
80107c17:	6a 4b                	push   $0x4b
  jmp alltraps
80107c19:	e9 1a f7 ff ff       	jmp    80107338 <alltraps>

80107c1e <vector76>:
.globl vector76
vector76:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $76
80107c20:	6a 4c                	push   $0x4c
  jmp alltraps
80107c22:	e9 11 f7 ff ff       	jmp    80107338 <alltraps>

80107c27 <vector77>:
.globl vector77
vector77:
  pushl $0
80107c27:	6a 00                	push   $0x0
  pushl $77
80107c29:	6a 4d                	push   $0x4d
  jmp alltraps
80107c2b:	e9 08 f7 ff ff       	jmp    80107338 <alltraps>

80107c30 <vector78>:
.globl vector78
vector78:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $78
80107c32:	6a 4e                	push   $0x4e
  jmp alltraps
80107c34:	e9 ff f6 ff ff       	jmp    80107338 <alltraps>

80107c39 <vector79>:
.globl vector79
vector79:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $79
80107c3b:	6a 4f                	push   $0x4f
  jmp alltraps
80107c3d:	e9 f6 f6 ff ff       	jmp    80107338 <alltraps>

80107c42 <vector80>:
.globl vector80
vector80:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $80
80107c44:	6a 50                	push   $0x50
  jmp alltraps
80107c46:	e9 ed f6 ff ff       	jmp    80107338 <alltraps>

80107c4b <vector81>:
.globl vector81
vector81:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $81
80107c4d:	6a 51                	push   $0x51
  jmp alltraps
80107c4f:	e9 e4 f6 ff ff       	jmp    80107338 <alltraps>

80107c54 <vector82>:
.globl vector82
vector82:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $82
80107c56:	6a 52                	push   $0x52
  jmp alltraps
80107c58:	e9 db f6 ff ff       	jmp    80107338 <alltraps>

80107c5d <vector83>:
.globl vector83
vector83:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $83
80107c5f:	6a 53                	push   $0x53
  jmp alltraps
80107c61:	e9 d2 f6 ff ff       	jmp    80107338 <alltraps>

80107c66 <vector84>:
.globl vector84
vector84:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $84
80107c68:	6a 54                	push   $0x54
  jmp alltraps
80107c6a:	e9 c9 f6 ff ff       	jmp    80107338 <alltraps>

80107c6f <vector85>:
.globl vector85
vector85:
  pushl $0
80107c6f:	6a 00                	push   $0x0
  pushl $85
80107c71:	6a 55                	push   $0x55
  jmp alltraps
80107c73:	e9 c0 f6 ff ff       	jmp    80107338 <alltraps>

80107c78 <vector86>:
.globl vector86
vector86:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $86
80107c7a:	6a 56                	push   $0x56
  jmp alltraps
80107c7c:	e9 b7 f6 ff ff       	jmp    80107338 <alltraps>

80107c81 <vector87>:
.globl vector87
vector87:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $87
80107c83:	6a 57                	push   $0x57
  jmp alltraps
80107c85:	e9 ae f6 ff ff       	jmp    80107338 <alltraps>

80107c8a <vector88>:
.globl vector88
vector88:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $88
80107c8c:	6a 58                	push   $0x58
  jmp alltraps
80107c8e:	e9 a5 f6 ff ff       	jmp    80107338 <alltraps>

80107c93 <vector89>:
.globl vector89
vector89:
  pushl $0
80107c93:	6a 00                	push   $0x0
  pushl $89
80107c95:	6a 59                	push   $0x59
  jmp alltraps
80107c97:	e9 9c f6 ff ff       	jmp    80107338 <alltraps>

80107c9c <vector90>:
.globl vector90
vector90:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $90
80107c9e:	6a 5a                	push   $0x5a
  jmp alltraps
80107ca0:	e9 93 f6 ff ff       	jmp    80107338 <alltraps>

80107ca5 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $91
80107ca7:	6a 5b                	push   $0x5b
  jmp alltraps
80107ca9:	e9 8a f6 ff ff       	jmp    80107338 <alltraps>

80107cae <vector92>:
.globl vector92
vector92:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $92
80107cb0:	6a 5c                	push   $0x5c
  jmp alltraps
80107cb2:	e9 81 f6 ff ff       	jmp    80107338 <alltraps>

80107cb7 <vector93>:
.globl vector93
vector93:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $93
80107cb9:	6a 5d                	push   $0x5d
  jmp alltraps
80107cbb:	e9 78 f6 ff ff       	jmp    80107338 <alltraps>

80107cc0 <vector94>:
.globl vector94
vector94:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $94
80107cc2:	6a 5e                	push   $0x5e
  jmp alltraps
80107cc4:	e9 6f f6 ff ff       	jmp    80107338 <alltraps>

80107cc9 <vector95>:
.globl vector95
vector95:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $95
80107ccb:	6a 5f                	push   $0x5f
  jmp alltraps
80107ccd:	e9 66 f6 ff ff       	jmp    80107338 <alltraps>

80107cd2 <vector96>:
.globl vector96
vector96:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $96
80107cd4:	6a 60                	push   $0x60
  jmp alltraps
80107cd6:	e9 5d f6 ff ff       	jmp    80107338 <alltraps>

80107cdb <vector97>:
.globl vector97
vector97:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $97
80107cdd:	6a 61                	push   $0x61
  jmp alltraps
80107cdf:	e9 54 f6 ff ff       	jmp    80107338 <alltraps>

80107ce4 <vector98>:
.globl vector98
vector98:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $98
80107ce6:	6a 62                	push   $0x62
  jmp alltraps
80107ce8:	e9 4b f6 ff ff       	jmp    80107338 <alltraps>

80107ced <vector99>:
.globl vector99
vector99:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $99
80107cef:	6a 63                	push   $0x63
  jmp alltraps
80107cf1:	e9 42 f6 ff ff       	jmp    80107338 <alltraps>

80107cf6 <vector100>:
.globl vector100
vector100:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $100
80107cf8:	6a 64                	push   $0x64
  jmp alltraps
80107cfa:	e9 39 f6 ff ff       	jmp    80107338 <alltraps>

80107cff <vector101>:
.globl vector101
vector101:
  pushl $0
80107cff:	6a 00                	push   $0x0
  pushl $101
80107d01:	6a 65                	push   $0x65
  jmp alltraps
80107d03:	e9 30 f6 ff ff       	jmp    80107338 <alltraps>

80107d08 <vector102>:
.globl vector102
vector102:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $102
80107d0a:	6a 66                	push   $0x66
  jmp alltraps
80107d0c:	e9 27 f6 ff ff       	jmp    80107338 <alltraps>

80107d11 <vector103>:
.globl vector103
vector103:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $103
80107d13:	6a 67                	push   $0x67
  jmp alltraps
80107d15:	e9 1e f6 ff ff       	jmp    80107338 <alltraps>

80107d1a <vector104>:
.globl vector104
vector104:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $104
80107d1c:	6a 68                	push   $0x68
  jmp alltraps
80107d1e:	e9 15 f6 ff ff       	jmp    80107338 <alltraps>

80107d23 <vector105>:
.globl vector105
vector105:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $105
80107d25:	6a 69                	push   $0x69
  jmp alltraps
80107d27:	e9 0c f6 ff ff       	jmp    80107338 <alltraps>

80107d2c <vector106>:
.globl vector106
vector106:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $106
80107d2e:	6a 6a                	push   $0x6a
  jmp alltraps
80107d30:	e9 03 f6 ff ff       	jmp    80107338 <alltraps>

80107d35 <vector107>:
.globl vector107
vector107:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $107
80107d37:	6a 6b                	push   $0x6b
  jmp alltraps
80107d39:	e9 fa f5 ff ff       	jmp    80107338 <alltraps>

80107d3e <vector108>:
.globl vector108
vector108:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $108
80107d40:	6a 6c                	push   $0x6c
  jmp alltraps
80107d42:	e9 f1 f5 ff ff       	jmp    80107338 <alltraps>

80107d47 <vector109>:
.globl vector109
vector109:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $109
80107d49:	6a 6d                	push   $0x6d
  jmp alltraps
80107d4b:	e9 e8 f5 ff ff       	jmp    80107338 <alltraps>

80107d50 <vector110>:
.globl vector110
vector110:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $110
80107d52:	6a 6e                	push   $0x6e
  jmp alltraps
80107d54:	e9 df f5 ff ff       	jmp    80107338 <alltraps>

80107d59 <vector111>:
.globl vector111
vector111:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $111
80107d5b:	6a 6f                	push   $0x6f
  jmp alltraps
80107d5d:	e9 d6 f5 ff ff       	jmp    80107338 <alltraps>

80107d62 <vector112>:
.globl vector112
vector112:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $112
80107d64:	6a 70                	push   $0x70
  jmp alltraps
80107d66:	e9 cd f5 ff ff       	jmp    80107338 <alltraps>

80107d6b <vector113>:
.globl vector113
vector113:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $113
80107d6d:	6a 71                	push   $0x71
  jmp alltraps
80107d6f:	e9 c4 f5 ff ff       	jmp    80107338 <alltraps>

80107d74 <vector114>:
.globl vector114
vector114:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $114
80107d76:	6a 72                	push   $0x72
  jmp alltraps
80107d78:	e9 bb f5 ff ff       	jmp    80107338 <alltraps>

80107d7d <vector115>:
.globl vector115
vector115:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $115
80107d7f:	6a 73                	push   $0x73
  jmp alltraps
80107d81:	e9 b2 f5 ff ff       	jmp    80107338 <alltraps>

80107d86 <vector116>:
.globl vector116
vector116:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $116
80107d88:	6a 74                	push   $0x74
  jmp alltraps
80107d8a:	e9 a9 f5 ff ff       	jmp    80107338 <alltraps>

80107d8f <vector117>:
.globl vector117
vector117:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $117
80107d91:	6a 75                	push   $0x75
  jmp alltraps
80107d93:	e9 a0 f5 ff ff       	jmp    80107338 <alltraps>

80107d98 <vector118>:
.globl vector118
vector118:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $118
80107d9a:	6a 76                	push   $0x76
  jmp alltraps
80107d9c:	e9 97 f5 ff ff       	jmp    80107338 <alltraps>

80107da1 <vector119>:
.globl vector119
vector119:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $119
80107da3:	6a 77                	push   $0x77
  jmp alltraps
80107da5:	e9 8e f5 ff ff       	jmp    80107338 <alltraps>

80107daa <vector120>:
.globl vector120
vector120:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $120
80107dac:	6a 78                	push   $0x78
  jmp alltraps
80107dae:	e9 85 f5 ff ff       	jmp    80107338 <alltraps>

80107db3 <vector121>:
.globl vector121
vector121:
  pushl $0
80107db3:	6a 00                	push   $0x0
  pushl $121
80107db5:	6a 79                	push   $0x79
  jmp alltraps
80107db7:	e9 7c f5 ff ff       	jmp    80107338 <alltraps>

80107dbc <vector122>:
.globl vector122
vector122:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $122
80107dbe:	6a 7a                	push   $0x7a
  jmp alltraps
80107dc0:	e9 73 f5 ff ff       	jmp    80107338 <alltraps>

80107dc5 <vector123>:
.globl vector123
vector123:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $123
80107dc7:	6a 7b                	push   $0x7b
  jmp alltraps
80107dc9:	e9 6a f5 ff ff       	jmp    80107338 <alltraps>

80107dce <vector124>:
.globl vector124
vector124:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $124
80107dd0:	6a 7c                	push   $0x7c
  jmp alltraps
80107dd2:	e9 61 f5 ff ff       	jmp    80107338 <alltraps>

80107dd7 <vector125>:
.globl vector125
vector125:
  pushl $0
80107dd7:	6a 00                	push   $0x0
  pushl $125
80107dd9:	6a 7d                	push   $0x7d
  jmp alltraps
80107ddb:	e9 58 f5 ff ff       	jmp    80107338 <alltraps>

80107de0 <vector126>:
.globl vector126
vector126:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $126
80107de2:	6a 7e                	push   $0x7e
  jmp alltraps
80107de4:	e9 4f f5 ff ff       	jmp    80107338 <alltraps>

80107de9 <vector127>:
.globl vector127
vector127:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $127
80107deb:	6a 7f                	push   $0x7f
  jmp alltraps
80107ded:	e9 46 f5 ff ff       	jmp    80107338 <alltraps>

80107df2 <vector128>:
.globl vector128
vector128:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $128
80107df4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107df9:	e9 3a f5 ff ff       	jmp    80107338 <alltraps>

80107dfe <vector129>:
.globl vector129
vector129:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $129
80107e00:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107e05:	e9 2e f5 ff ff       	jmp    80107338 <alltraps>

80107e0a <vector130>:
.globl vector130
vector130:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $130
80107e0c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107e11:	e9 22 f5 ff ff       	jmp    80107338 <alltraps>

80107e16 <vector131>:
.globl vector131
vector131:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $131
80107e18:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e1d:	e9 16 f5 ff ff       	jmp    80107338 <alltraps>

80107e22 <vector132>:
.globl vector132
vector132:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $132
80107e24:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e29:	e9 0a f5 ff ff       	jmp    80107338 <alltraps>

80107e2e <vector133>:
.globl vector133
vector133:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $133
80107e30:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107e35:	e9 fe f4 ff ff       	jmp    80107338 <alltraps>

80107e3a <vector134>:
.globl vector134
vector134:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $134
80107e3c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107e41:	e9 f2 f4 ff ff       	jmp    80107338 <alltraps>

80107e46 <vector135>:
.globl vector135
vector135:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $135
80107e48:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107e4d:	e9 e6 f4 ff ff       	jmp    80107338 <alltraps>

80107e52 <vector136>:
.globl vector136
vector136:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $136
80107e54:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107e59:	e9 da f4 ff ff       	jmp    80107338 <alltraps>

80107e5e <vector137>:
.globl vector137
vector137:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $137
80107e60:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107e65:	e9 ce f4 ff ff       	jmp    80107338 <alltraps>

80107e6a <vector138>:
.globl vector138
vector138:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $138
80107e6c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107e71:	e9 c2 f4 ff ff       	jmp    80107338 <alltraps>

80107e76 <vector139>:
.globl vector139
vector139:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $139
80107e78:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107e7d:	e9 b6 f4 ff ff       	jmp    80107338 <alltraps>

80107e82 <vector140>:
.globl vector140
vector140:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $140
80107e84:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107e89:	e9 aa f4 ff ff       	jmp    80107338 <alltraps>

80107e8e <vector141>:
.globl vector141
vector141:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $141
80107e90:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107e95:	e9 9e f4 ff ff       	jmp    80107338 <alltraps>

80107e9a <vector142>:
.globl vector142
vector142:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $142
80107e9c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ea1:	e9 92 f4 ff ff       	jmp    80107338 <alltraps>

80107ea6 <vector143>:
.globl vector143
vector143:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $143
80107ea8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107ead:	e9 86 f4 ff ff       	jmp    80107338 <alltraps>

80107eb2 <vector144>:
.globl vector144
vector144:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $144
80107eb4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107eb9:	e9 7a f4 ff ff       	jmp    80107338 <alltraps>

80107ebe <vector145>:
.globl vector145
vector145:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $145
80107ec0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107ec5:	e9 6e f4 ff ff       	jmp    80107338 <alltraps>

80107eca <vector146>:
.globl vector146
vector146:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $146
80107ecc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ed1:	e9 62 f4 ff ff       	jmp    80107338 <alltraps>

80107ed6 <vector147>:
.globl vector147
vector147:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $147
80107ed8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107edd:	e9 56 f4 ff ff       	jmp    80107338 <alltraps>

80107ee2 <vector148>:
.globl vector148
vector148:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $148
80107ee4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107ee9:	e9 4a f4 ff ff       	jmp    80107338 <alltraps>

80107eee <vector149>:
.globl vector149
vector149:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $149
80107ef0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107ef5:	e9 3e f4 ff ff       	jmp    80107338 <alltraps>

80107efa <vector150>:
.globl vector150
vector150:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $150
80107efc:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107f01:	e9 32 f4 ff ff       	jmp    80107338 <alltraps>

80107f06 <vector151>:
.globl vector151
vector151:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $151
80107f08:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107f0d:	e9 26 f4 ff ff       	jmp    80107338 <alltraps>

80107f12 <vector152>:
.globl vector152
vector152:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $152
80107f14:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107f19:	e9 1a f4 ff ff       	jmp    80107338 <alltraps>

80107f1e <vector153>:
.globl vector153
vector153:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $153
80107f20:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f25:	e9 0e f4 ff ff       	jmp    80107338 <alltraps>

80107f2a <vector154>:
.globl vector154
vector154:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $154
80107f2c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107f31:	e9 02 f4 ff ff       	jmp    80107338 <alltraps>

80107f36 <vector155>:
.globl vector155
vector155:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $155
80107f38:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107f3d:	e9 f6 f3 ff ff       	jmp    80107338 <alltraps>

80107f42 <vector156>:
.globl vector156
vector156:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $156
80107f44:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107f49:	e9 ea f3 ff ff       	jmp    80107338 <alltraps>

80107f4e <vector157>:
.globl vector157
vector157:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $157
80107f50:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107f55:	e9 de f3 ff ff       	jmp    80107338 <alltraps>

80107f5a <vector158>:
.globl vector158
vector158:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $158
80107f5c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107f61:	e9 d2 f3 ff ff       	jmp    80107338 <alltraps>

80107f66 <vector159>:
.globl vector159
vector159:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $159
80107f68:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107f6d:	e9 c6 f3 ff ff       	jmp    80107338 <alltraps>

80107f72 <vector160>:
.globl vector160
vector160:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $160
80107f74:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107f79:	e9 ba f3 ff ff       	jmp    80107338 <alltraps>

80107f7e <vector161>:
.globl vector161
vector161:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $161
80107f80:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107f85:	e9 ae f3 ff ff       	jmp    80107338 <alltraps>

80107f8a <vector162>:
.globl vector162
vector162:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $162
80107f8c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107f91:	e9 a2 f3 ff ff       	jmp    80107338 <alltraps>

80107f96 <vector163>:
.globl vector163
vector163:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $163
80107f98:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107f9d:	e9 96 f3 ff ff       	jmp    80107338 <alltraps>

80107fa2 <vector164>:
.globl vector164
vector164:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $164
80107fa4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107fa9:	e9 8a f3 ff ff       	jmp    80107338 <alltraps>

80107fae <vector165>:
.globl vector165
vector165:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $165
80107fb0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107fb5:	e9 7e f3 ff ff       	jmp    80107338 <alltraps>

80107fba <vector166>:
.globl vector166
vector166:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $166
80107fbc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107fc1:	e9 72 f3 ff ff       	jmp    80107338 <alltraps>

80107fc6 <vector167>:
.globl vector167
vector167:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $167
80107fc8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107fcd:	e9 66 f3 ff ff       	jmp    80107338 <alltraps>

80107fd2 <vector168>:
.globl vector168
vector168:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $168
80107fd4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107fd9:	e9 5a f3 ff ff       	jmp    80107338 <alltraps>

80107fde <vector169>:
.globl vector169
vector169:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $169
80107fe0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107fe5:	e9 4e f3 ff ff       	jmp    80107338 <alltraps>

80107fea <vector170>:
.globl vector170
vector170:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $170
80107fec:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107ff1:	e9 42 f3 ff ff       	jmp    80107338 <alltraps>

80107ff6 <vector171>:
.globl vector171
vector171:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $171
80107ff8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107ffd:	e9 36 f3 ff ff       	jmp    80107338 <alltraps>

80108002 <vector172>:
.globl vector172
vector172:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $172
80108004:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108009:	e9 2a f3 ff ff       	jmp    80107338 <alltraps>

8010800e <vector173>:
.globl vector173
vector173:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $173
80108010:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108015:	e9 1e f3 ff ff       	jmp    80107338 <alltraps>

8010801a <vector174>:
.globl vector174
vector174:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $174
8010801c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108021:	e9 12 f3 ff ff       	jmp    80107338 <alltraps>

80108026 <vector175>:
.globl vector175
vector175:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $175
80108028:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010802d:	e9 06 f3 ff ff       	jmp    80107338 <alltraps>

80108032 <vector176>:
.globl vector176
vector176:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $176
80108034:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108039:	e9 fa f2 ff ff       	jmp    80107338 <alltraps>

8010803e <vector177>:
.globl vector177
vector177:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $177
80108040:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108045:	e9 ee f2 ff ff       	jmp    80107338 <alltraps>

8010804a <vector178>:
.globl vector178
vector178:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $178
8010804c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108051:	e9 e2 f2 ff ff       	jmp    80107338 <alltraps>

80108056 <vector179>:
.globl vector179
vector179:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $179
80108058:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010805d:	e9 d6 f2 ff ff       	jmp    80107338 <alltraps>

80108062 <vector180>:
.globl vector180
vector180:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $180
80108064:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108069:	e9 ca f2 ff ff       	jmp    80107338 <alltraps>

8010806e <vector181>:
.globl vector181
vector181:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $181
80108070:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108075:	e9 be f2 ff ff       	jmp    80107338 <alltraps>

8010807a <vector182>:
.globl vector182
vector182:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $182
8010807c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108081:	e9 b2 f2 ff ff       	jmp    80107338 <alltraps>

80108086 <vector183>:
.globl vector183
vector183:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $183
80108088:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010808d:	e9 a6 f2 ff ff       	jmp    80107338 <alltraps>

80108092 <vector184>:
.globl vector184
vector184:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $184
80108094:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108099:	e9 9a f2 ff ff       	jmp    80107338 <alltraps>

8010809e <vector185>:
.globl vector185
vector185:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $185
801080a0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801080a5:	e9 8e f2 ff ff       	jmp    80107338 <alltraps>

801080aa <vector186>:
.globl vector186
vector186:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $186
801080ac:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801080b1:	e9 82 f2 ff ff       	jmp    80107338 <alltraps>

801080b6 <vector187>:
.globl vector187
vector187:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $187
801080b8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801080bd:	e9 76 f2 ff ff       	jmp    80107338 <alltraps>

801080c2 <vector188>:
.globl vector188
vector188:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $188
801080c4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801080c9:	e9 6a f2 ff ff       	jmp    80107338 <alltraps>

801080ce <vector189>:
.globl vector189
vector189:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $189
801080d0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801080d5:	e9 5e f2 ff ff       	jmp    80107338 <alltraps>

801080da <vector190>:
.globl vector190
vector190:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $190
801080dc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801080e1:	e9 52 f2 ff ff       	jmp    80107338 <alltraps>

801080e6 <vector191>:
.globl vector191
vector191:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $191
801080e8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801080ed:	e9 46 f2 ff ff       	jmp    80107338 <alltraps>

801080f2 <vector192>:
.globl vector192
vector192:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $192
801080f4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801080f9:	e9 3a f2 ff ff       	jmp    80107338 <alltraps>

801080fe <vector193>:
.globl vector193
vector193:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $193
80108100:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108105:	e9 2e f2 ff ff       	jmp    80107338 <alltraps>

8010810a <vector194>:
.globl vector194
vector194:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $194
8010810c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108111:	e9 22 f2 ff ff       	jmp    80107338 <alltraps>

80108116 <vector195>:
.globl vector195
vector195:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $195
80108118:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010811d:	e9 16 f2 ff ff       	jmp    80107338 <alltraps>

80108122 <vector196>:
.globl vector196
vector196:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $196
80108124:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108129:	e9 0a f2 ff ff       	jmp    80107338 <alltraps>

8010812e <vector197>:
.globl vector197
vector197:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $197
80108130:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108135:	e9 fe f1 ff ff       	jmp    80107338 <alltraps>

8010813a <vector198>:
.globl vector198
vector198:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $198
8010813c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108141:	e9 f2 f1 ff ff       	jmp    80107338 <alltraps>

80108146 <vector199>:
.globl vector199
vector199:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $199
80108148:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010814d:	e9 e6 f1 ff ff       	jmp    80107338 <alltraps>

80108152 <vector200>:
.globl vector200
vector200:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $200
80108154:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108159:	e9 da f1 ff ff       	jmp    80107338 <alltraps>

8010815e <vector201>:
.globl vector201
vector201:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $201
80108160:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108165:	e9 ce f1 ff ff       	jmp    80107338 <alltraps>

8010816a <vector202>:
.globl vector202
vector202:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $202
8010816c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108171:	e9 c2 f1 ff ff       	jmp    80107338 <alltraps>

80108176 <vector203>:
.globl vector203
vector203:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $203
80108178:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010817d:	e9 b6 f1 ff ff       	jmp    80107338 <alltraps>

80108182 <vector204>:
.globl vector204
vector204:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $204
80108184:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108189:	e9 aa f1 ff ff       	jmp    80107338 <alltraps>

8010818e <vector205>:
.globl vector205
vector205:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $205
80108190:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108195:	e9 9e f1 ff ff       	jmp    80107338 <alltraps>

8010819a <vector206>:
.globl vector206
vector206:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $206
8010819c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801081a1:	e9 92 f1 ff ff       	jmp    80107338 <alltraps>

801081a6 <vector207>:
.globl vector207
vector207:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $207
801081a8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801081ad:	e9 86 f1 ff ff       	jmp    80107338 <alltraps>

801081b2 <vector208>:
.globl vector208
vector208:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $208
801081b4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801081b9:	e9 7a f1 ff ff       	jmp    80107338 <alltraps>

801081be <vector209>:
.globl vector209
vector209:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $209
801081c0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801081c5:	e9 6e f1 ff ff       	jmp    80107338 <alltraps>

801081ca <vector210>:
.globl vector210
vector210:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $210
801081cc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801081d1:	e9 62 f1 ff ff       	jmp    80107338 <alltraps>

801081d6 <vector211>:
.globl vector211
vector211:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $211
801081d8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801081dd:	e9 56 f1 ff ff       	jmp    80107338 <alltraps>

801081e2 <vector212>:
.globl vector212
vector212:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $212
801081e4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801081e9:	e9 4a f1 ff ff       	jmp    80107338 <alltraps>

801081ee <vector213>:
.globl vector213
vector213:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $213
801081f0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801081f5:	e9 3e f1 ff ff       	jmp    80107338 <alltraps>

801081fa <vector214>:
.globl vector214
vector214:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $214
801081fc:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108201:	e9 32 f1 ff ff       	jmp    80107338 <alltraps>

80108206 <vector215>:
.globl vector215
vector215:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $215
80108208:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010820d:	e9 26 f1 ff ff       	jmp    80107338 <alltraps>

80108212 <vector216>:
.globl vector216
vector216:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $216
80108214:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108219:	e9 1a f1 ff ff       	jmp    80107338 <alltraps>

8010821e <vector217>:
.globl vector217
vector217:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $217
80108220:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108225:	e9 0e f1 ff ff       	jmp    80107338 <alltraps>

8010822a <vector218>:
.globl vector218
vector218:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $218
8010822c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108231:	e9 02 f1 ff ff       	jmp    80107338 <alltraps>

80108236 <vector219>:
.globl vector219
vector219:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $219
80108238:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010823d:	e9 f6 f0 ff ff       	jmp    80107338 <alltraps>

80108242 <vector220>:
.globl vector220
vector220:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $220
80108244:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108249:	e9 ea f0 ff ff       	jmp    80107338 <alltraps>

8010824e <vector221>:
.globl vector221
vector221:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $221
80108250:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108255:	e9 de f0 ff ff       	jmp    80107338 <alltraps>

8010825a <vector222>:
.globl vector222
vector222:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $222
8010825c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108261:	e9 d2 f0 ff ff       	jmp    80107338 <alltraps>

80108266 <vector223>:
.globl vector223
vector223:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $223
80108268:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010826d:	e9 c6 f0 ff ff       	jmp    80107338 <alltraps>

80108272 <vector224>:
.globl vector224
vector224:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $224
80108274:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108279:	e9 ba f0 ff ff       	jmp    80107338 <alltraps>

8010827e <vector225>:
.globl vector225
vector225:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $225
80108280:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108285:	e9 ae f0 ff ff       	jmp    80107338 <alltraps>

8010828a <vector226>:
.globl vector226
vector226:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $226
8010828c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108291:	e9 a2 f0 ff ff       	jmp    80107338 <alltraps>

80108296 <vector227>:
.globl vector227
vector227:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $227
80108298:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010829d:	e9 96 f0 ff ff       	jmp    80107338 <alltraps>

801082a2 <vector228>:
.globl vector228
vector228:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $228
801082a4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801082a9:	e9 8a f0 ff ff       	jmp    80107338 <alltraps>

801082ae <vector229>:
.globl vector229
vector229:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $229
801082b0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801082b5:	e9 7e f0 ff ff       	jmp    80107338 <alltraps>

801082ba <vector230>:
.globl vector230
vector230:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $230
801082bc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801082c1:	e9 72 f0 ff ff       	jmp    80107338 <alltraps>

801082c6 <vector231>:
.globl vector231
vector231:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $231
801082c8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801082cd:	e9 66 f0 ff ff       	jmp    80107338 <alltraps>

801082d2 <vector232>:
.globl vector232
vector232:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $232
801082d4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801082d9:	e9 5a f0 ff ff       	jmp    80107338 <alltraps>

801082de <vector233>:
.globl vector233
vector233:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $233
801082e0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801082e5:	e9 4e f0 ff ff       	jmp    80107338 <alltraps>

801082ea <vector234>:
.globl vector234
vector234:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $234
801082ec:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801082f1:	e9 42 f0 ff ff       	jmp    80107338 <alltraps>

801082f6 <vector235>:
.globl vector235
vector235:
  pushl $0
801082f6:	6a 00                	push   $0x0
  pushl $235
801082f8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801082fd:	e9 36 f0 ff ff       	jmp    80107338 <alltraps>

80108302 <vector236>:
.globl vector236
vector236:
  pushl $0
80108302:	6a 00                	push   $0x0
  pushl $236
80108304:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108309:	e9 2a f0 ff ff       	jmp    80107338 <alltraps>

8010830e <vector237>:
.globl vector237
vector237:
  pushl $0
8010830e:	6a 00                	push   $0x0
  pushl $237
80108310:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108315:	e9 1e f0 ff ff       	jmp    80107338 <alltraps>

8010831a <vector238>:
.globl vector238
vector238:
  pushl $0
8010831a:	6a 00                	push   $0x0
  pushl $238
8010831c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108321:	e9 12 f0 ff ff       	jmp    80107338 <alltraps>

80108326 <vector239>:
.globl vector239
vector239:
  pushl $0
80108326:	6a 00                	push   $0x0
  pushl $239
80108328:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010832d:	e9 06 f0 ff ff       	jmp    80107338 <alltraps>

80108332 <vector240>:
.globl vector240
vector240:
  pushl $0
80108332:	6a 00                	push   $0x0
  pushl $240
80108334:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108339:	e9 fa ef ff ff       	jmp    80107338 <alltraps>

8010833e <vector241>:
.globl vector241
vector241:
  pushl $0
8010833e:	6a 00                	push   $0x0
  pushl $241
80108340:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108345:	e9 ee ef ff ff       	jmp    80107338 <alltraps>

8010834a <vector242>:
.globl vector242
vector242:
  pushl $0
8010834a:	6a 00                	push   $0x0
  pushl $242
8010834c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108351:	e9 e2 ef ff ff       	jmp    80107338 <alltraps>

80108356 <vector243>:
.globl vector243
vector243:
  pushl $0
80108356:	6a 00                	push   $0x0
  pushl $243
80108358:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010835d:	e9 d6 ef ff ff       	jmp    80107338 <alltraps>

80108362 <vector244>:
.globl vector244
vector244:
  pushl $0
80108362:	6a 00                	push   $0x0
  pushl $244
80108364:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108369:	e9 ca ef ff ff       	jmp    80107338 <alltraps>

8010836e <vector245>:
.globl vector245
vector245:
  pushl $0
8010836e:	6a 00                	push   $0x0
  pushl $245
80108370:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108375:	e9 be ef ff ff       	jmp    80107338 <alltraps>

8010837a <vector246>:
.globl vector246
vector246:
  pushl $0
8010837a:	6a 00                	push   $0x0
  pushl $246
8010837c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108381:	e9 b2 ef ff ff       	jmp    80107338 <alltraps>

80108386 <vector247>:
.globl vector247
vector247:
  pushl $0
80108386:	6a 00                	push   $0x0
  pushl $247
80108388:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010838d:	e9 a6 ef ff ff       	jmp    80107338 <alltraps>

80108392 <vector248>:
.globl vector248
vector248:
  pushl $0
80108392:	6a 00                	push   $0x0
  pushl $248
80108394:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108399:	e9 9a ef ff ff       	jmp    80107338 <alltraps>

8010839e <vector249>:
.globl vector249
vector249:
  pushl $0
8010839e:	6a 00                	push   $0x0
  pushl $249
801083a0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801083a5:	e9 8e ef ff ff       	jmp    80107338 <alltraps>

801083aa <vector250>:
.globl vector250
vector250:
  pushl $0
801083aa:	6a 00                	push   $0x0
  pushl $250
801083ac:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801083b1:	e9 82 ef ff ff       	jmp    80107338 <alltraps>

801083b6 <vector251>:
.globl vector251
vector251:
  pushl $0
801083b6:	6a 00                	push   $0x0
  pushl $251
801083b8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801083bd:	e9 76 ef ff ff       	jmp    80107338 <alltraps>

801083c2 <vector252>:
.globl vector252
vector252:
  pushl $0
801083c2:	6a 00                	push   $0x0
  pushl $252
801083c4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801083c9:	e9 6a ef ff ff       	jmp    80107338 <alltraps>

801083ce <vector253>:
.globl vector253
vector253:
  pushl $0
801083ce:	6a 00                	push   $0x0
  pushl $253
801083d0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801083d5:	e9 5e ef ff ff       	jmp    80107338 <alltraps>

801083da <vector254>:
.globl vector254
vector254:
  pushl $0
801083da:	6a 00                	push   $0x0
  pushl $254
801083dc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801083e1:	e9 52 ef ff ff       	jmp    80107338 <alltraps>

801083e6 <vector255>:
.globl vector255
vector255:
  pushl $0
801083e6:	6a 00                	push   $0x0
  pushl $255
801083e8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801083ed:	e9 46 ef ff ff       	jmp    80107338 <alltraps>
	...

801083f4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801083f4:	55                   	push   %ebp
801083f5:	89 e5                	mov    %esp,%ebp
801083f7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801083fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801083fd:	48                   	dec    %eax
801083fe:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108402:	8b 45 08             	mov    0x8(%ebp),%eax
80108405:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108409:	8b 45 08             	mov    0x8(%ebp),%eax
8010840c:	c1 e8 10             	shr    $0x10,%eax
8010840f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108413:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108416:	0f 01 10             	lgdtl  (%eax)
}
80108419:	c9                   	leave  
8010841a:	c3                   	ret    

8010841b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010841b:	55                   	push   %ebp
8010841c:	89 e5                	mov    %esp,%ebp
8010841e:	83 ec 04             	sub    $0x4,%esp
80108421:	8b 45 08             	mov    0x8(%ebp),%eax
80108424:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108428:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010842b:	0f 00 d8             	ltr    %ax
}
8010842e:	c9                   	leave  
8010842f:	c3                   	ret    

80108430 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108430:	55                   	push   %ebp
80108431:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108433:	8b 45 08             	mov    0x8(%ebp),%eax
80108436:	0f 22 d8             	mov    %eax,%cr3
}
80108439:	5d                   	pop    %ebp
8010843a:	c3                   	ret    

8010843b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010843b:	55                   	push   %ebp
8010843c:	89 e5                	mov    %esp,%ebp
8010843e:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108441:	e8 24 c0 ff ff       	call   8010446a <cpuid>
80108446:	89 c2                	mov    %eax,%edx
80108448:	89 d0                	mov    %edx,%eax
8010844a:	c1 e0 02             	shl    $0x2,%eax
8010844d:	01 d0                	add    %edx,%eax
8010844f:	01 c0                	add    %eax,%eax
80108451:	01 d0                	add    %edx,%eax
80108453:	c1 e0 04             	shl    $0x4,%eax
80108456:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
8010845b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010845e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108461:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108473:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847a:	8a 50 7d             	mov    0x7d(%eax),%dl
8010847d:	83 e2 f0             	and    $0xfffffff0,%edx
80108480:	83 ca 0a             	or     $0xa,%edx
80108483:	88 50 7d             	mov    %dl,0x7d(%eax)
80108486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108489:	8a 50 7d             	mov    0x7d(%eax),%dl
8010848c:	83 ca 10             	or     $0x10,%edx
8010848f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108495:	8a 50 7d             	mov    0x7d(%eax),%dl
80108498:	83 e2 9f             	and    $0xffffff9f,%edx
8010849b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010849e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a1:	8a 50 7d             	mov    0x7d(%eax),%dl
801084a4:	83 ca 80             	or     $0xffffff80,%edx
801084a7:	88 50 7d             	mov    %dl,0x7d(%eax)
801084aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ad:	8a 50 7e             	mov    0x7e(%eax),%dl
801084b0:	83 ca 0f             	or     $0xf,%edx
801084b3:	88 50 7e             	mov    %dl,0x7e(%eax)
801084b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b9:	8a 50 7e             	mov    0x7e(%eax),%dl
801084bc:	83 e2 ef             	and    $0xffffffef,%edx
801084bf:	88 50 7e             	mov    %dl,0x7e(%eax)
801084c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c5:	8a 50 7e             	mov    0x7e(%eax),%dl
801084c8:	83 e2 df             	and    $0xffffffdf,%edx
801084cb:	88 50 7e             	mov    %dl,0x7e(%eax)
801084ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d1:	8a 50 7e             	mov    0x7e(%eax),%dl
801084d4:	83 ca 40             	or     $0x40,%edx
801084d7:	88 50 7e             	mov    %dl,0x7e(%eax)
801084da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dd:	8a 50 7e             	mov    0x7e(%eax),%dl
801084e0:	83 ca 80             	or     $0xffffff80,%edx
801084e3:	88 50 7e             	mov    %dl,0x7e(%eax)
801084e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801084ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801084f7:	ff ff 
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108503:	00 00 
80108505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108508:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010850f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108512:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108518:	83 e2 f0             	and    $0xfffffff0,%edx
8010851b:	83 ca 02             	or     $0x2,%edx
8010851e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108527:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010852d:	83 ca 10             	or     $0x10,%edx
80108530:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108539:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010853f:	83 e2 9f             	and    $0xffffff9f,%edx
80108542:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108551:	83 ca 80             	or     $0xffffff80,%edx
80108554:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010855a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108563:	83 ca 0f             	or     $0xf,%edx
80108566:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010856c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108575:	83 e2 ef             	and    $0xffffffef,%edx
80108578:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010857e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108581:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108587:	83 e2 df             	and    $0xffffffdf,%edx
8010858a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108593:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108599:	83 ca 40             	or     $0x40,%edx
8010859c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a5:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801085ab:	83 ca 80             	or     $0xffffff80,%edx
801085ae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801085be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801085c8:	ff ff 
801085ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801085d4:	00 00 
801085d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d9:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801085e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e3:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085e9:	83 e2 f0             	and    $0xfffffff0,%edx
801085ec:	83 ca 0a             	or     $0xa,%edx
801085ef:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085fe:	83 ca 10             	or     $0x10,%edx
80108601:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108610:	83 ca 60             	or     $0x60,%edx
80108613:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861c:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108622:	83 ca 80             	or     $0xffffff80,%edx
80108625:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108634:	83 ca 0f             	or     $0xf,%edx
80108637:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010863d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108640:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108646:	83 e2 ef             	and    $0xffffffef,%edx
80108649:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108658:	83 e2 df             	and    $0xffffffdf,%edx
8010865b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108664:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010866a:	83 ca 40             	or     $0x40,%edx
8010866d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108676:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010867c:	83 ca 80             	or     $0xffffff80,%edx
8010867f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108688:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010868f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108692:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108699:	ff ff 
8010869b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801086a5:	00 00 
801086a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086aa:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801086b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b4:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086ba:	83 e2 f0             	and    $0xfffffff0,%edx
801086bd:	83 ca 02             	or     $0x2,%edx
801086c0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086cf:	83 ca 10             	or     $0x10,%edx
801086d2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086db:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086e1:	83 ca 60             	or     $0x60,%edx
801086e4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ed:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086f3:	83 ca 80             	or     $0xffffff80,%edx
801086f6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108705:	83 ca 0f             	or     $0xf,%edx
80108708:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010870e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108711:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108717:	83 e2 ef             	and    $0xffffffef,%edx
8010871a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108723:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108729:	83 e2 df             	and    $0xffffffdf,%edx
8010872c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108735:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010873b:	83 ca 40             	or     $0x40,%edx
8010873e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108747:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010874d:	83 ca 80             	or     $0xffffff80,%edx
80108750:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108759:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108763:	83 c0 70             	add    $0x70,%eax
80108766:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010876d:	00 
8010876e:	89 04 24             	mov    %eax,(%esp)
80108771:	e8 7e fc ff ff       	call   801083f4 <lgdt>
}
80108776:	c9                   	leave  
80108777:	c3                   	ret    

80108778 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108778:	55                   	push   %ebp
80108779:	89 e5                	mov    %esp,%ebp
8010877b:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010877e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108781:	c1 e8 16             	shr    $0x16,%eax
80108784:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010878b:	8b 45 08             	mov    0x8(%ebp),%eax
8010878e:	01 d0                	add    %edx,%eax
80108790:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108796:	8b 00                	mov    (%eax),%eax
80108798:	83 e0 01             	and    $0x1,%eax
8010879b:	85 c0                	test   %eax,%eax
8010879d:	74 14                	je     801087b3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010879f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087a2:	8b 00                	mov    (%eax),%eax
801087a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087a9:	05 00 00 00 80       	add    $0x80000000,%eax
801087ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087b1:	eb 48                	jmp    801087fb <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801087b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801087b7:	74 0e                	je     801087c7 <walkpgdir+0x4f>
801087b9:	e8 e0 a6 ff ff       	call   80102e9e <kalloc>
801087be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087c5:	75 07                	jne    801087ce <walkpgdir+0x56>
      return 0;
801087c7:	b8 00 00 00 00       	mov    $0x0,%eax
801087cc:	eb 44                	jmp    80108812 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801087ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087d5:	00 
801087d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087dd:	00 
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	89 04 24             	mov    %eax,(%esp)
801087e4:	e8 f1 cf ff ff       	call   801057da <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801087e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ec:	05 00 00 00 80       	add    $0x80000000,%eax
801087f1:	83 c8 07             	or     $0x7,%eax
801087f4:	89 c2                	mov    %eax,%edx
801087f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f9:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801087fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801087fe:	c1 e8 0c             	shr    $0xc,%eax
80108801:	25 ff 03 00 00       	and    $0x3ff,%eax
80108806:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010880d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108810:	01 d0                	add    %edx,%eax
}
80108812:	c9                   	leave  
80108813:	c3                   	ret    

80108814 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108814:	55                   	push   %ebp
80108815:	89 e5                	mov    %esp,%ebp
80108817:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010881a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010881d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108822:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108825:	8b 55 0c             	mov    0xc(%ebp),%edx
80108828:	8b 45 10             	mov    0x10(%ebp),%eax
8010882b:	01 d0                	add    %edx,%eax
8010882d:	48                   	dec    %eax
8010882e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108833:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108836:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010883d:	00 
8010883e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108841:	89 44 24 04          	mov    %eax,0x4(%esp)
80108845:	8b 45 08             	mov    0x8(%ebp),%eax
80108848:	89 04 24             	mov    %eax,(%esp)
8010884b:	e8 28 ff ff ff       	call   80108778 <walkpgdir>
80108850:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108853:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108857:	75 07                	jne    80108860 <mappages+0x4c>
      return -1;
80108859:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010885e:	eb 48                	jmp    801088a8 <mappages+0x94>
    if(*pte & PTE_P)
80108860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108863:	8b 00                	mov    (%eax),%eax
80108865:	83 e0 01             	and    $0x1,%eax
80108868:	85 c0                	test   %eax,%eax
8010886a:	74 0c                	je     80108878 <mappages+0x64>
      panic("remap");
8010886c:	c7 04 24 dc a1 10 80 	movl   $0x8010a1dc,(%esp)
80108873:	e8 dc 7c ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108878:	8b 45 18             	mov    0x18(%ebp),%eax
8010887b:	0b 45 14             	or     0x14(%ebp),%eax
8010887e:	83 c8 01             	or     $0x1,%eax
80108881:	89 c2                	mov    %eax,%edx
80108883:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108886:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010888e:	75 08                	jne    80108898 <mappages+0x84>
      break;
80108890:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108891:	b8 00 00 00 00       	mov    $0x0,%eax
80108896:	eb 10                	jmp    801088a8 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108898:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010889f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801088a6:	eb 8e                	jmp    80108836 <mappages+0x22>
  return 0;
}
801088a8:	c9                   	leave  
801088a9:	c3                   	ret    

801088aa <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801088aa:	55                   	push   %ebp
801088ab:	89 e5                	mov    %esp,%ebp
801088ad:	53                   	push   %ebx
801088ae:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801088b1:	e8 e8 a5 ff ff       	call   80102e9e <kalloc>
801088b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801088b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088bd:	75 0a                	jne    801088c9 <setupkvm+0x1f>
    return 0;
801088bf:	b8 00 00 00 00       	mov    $0x0,%eax
801088c4:	e9 84 00 00 00       	jmp    8010894d <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801088c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088d0:	00 
801088d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088d8:	00 
801088d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088dc:	89 04 24             	mov    %eax,(%esp)
801088df:	e8 f6 ce ff ff       	call   801057da <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801088e4:	c7 45 f4 20 d5 10 80 	movl   $0x8010d520,-0xc(%ebp)
801088eb:	eb 54                	jmp    80108941 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801088ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f0:	8b 48 0c             	mov    0xc(%eax),%ecx
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	8b 50 04             	mov    0x4(%eax),%edx
801088f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fc:	8b 58 08             	mov    0x8(%eax),%ebx
801088ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108902:	8b 40 04             	mov    0x4(%eax),%eax
80108905:	29 c3                	sub    %eax,%ebx
80108907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890a:	8b 00                	mov    (%eax),%eax
8010890c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108910:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108914:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108918:	89 44 24 04          	mov    %eax,0x4(%esp)
8010891c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010891f:	89 04 24             	mov    %eax,(%esp)
80108922:	e8 ed fe ff ff       	call   80108814 <mappages>
80108927:	85 c0                	test   %eax,%eax
80108929:	79 12                	jns    8010893d <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010892b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010892e:	89 04 24             	mov    %eax,(%esp)
80108931:	e8 1a 05 00 00       	call   80108e50 <freevm>
      return 0;
80108936:	b8 00 00 00 00       	mov    $0x0,%eax
8010893b:	eb 10                	jmp    8010894d <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010893d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108941:	81 7d f4 60 d5 10 80 	cmpl   $0x8010d560,-0xc(%ebp)
80108948:	72 a3                	jb     801088ed <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010894a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010894d:	83 c4 34             	add    $0x34,%esp
80108950:	5b                   	pop    %ebx
80108951:	5d                   	pop    %ebp
80108952:	c3                   	ret    

80108953 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108953:	55                   	push   %ebp
80108954:	89 e5                	mov    %esp,%ebp
80108956:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108959:	e8 4c ff ff ff       	call   801088aa <setupkvm>
8010895e:	a3 e4 8c 11 80       	mov    %eax,0x80118ce4
  switchkvm();
80108963:	e8 02 00 00 00       	call   8010896a <switchkvm>
}
80108968:	c9                   	leave  
80108969:	c3                   	ret    

8010896a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010896a:	55                   	push   %ebp
8010896b:	89 e5                	mov    %esp,%ebp
8010896d:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108970:	a1 e4 8c 11 80       	mov    0x80118ce4,%eax
80108975:	05 00 00 00 80       	add    $0x80000000,%eax
8010897a:	89 04 24             	mov    %eax,(%esp)
8010897d:	e8 ae fa ff ff       	call   80108430 <lcr3>
}
80108982:	c9                   	leave  
80108983:	c3                   	ret    

80108984 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108984:	55                   	push   %ebp
80108985:	89 e5                	mov    %esp,%ebp
80108987:	57                   	push   %edi
80108988:	56                   	push   %esi
80108989:	53                   	push   %ebx
8010898a:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
8010898d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108991:	75 0c                	jne    8010899f <switchuvm+0x1b>
    panic("switchuvm: no process");
80108993:	c7 04 24 e2 a1 10 80 	movl   $0x8010a1e2,(%esp)
8010899a:	e8 b5 7b ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
8010899f:	8b 45 08             	mov    0x8(%ebp),%eax
801089a2:	8b 40 08             	mov    0x8(%eax),%eax
801089a5:	85 c0                	test   %eax,%eax
801089a7:	75 0c                	jne    801089b5 <switchuvm+0x31>
    panic("switchuvm: no kstack");
801089a9:	c7 04 24 f8 a1 10 80 	movl   $0x8010a1f8,(%esp)
801089b0:	e8 9f 7b ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801089b5:	8b 45 08             	mov    0x8(%ebp),%eax
801089b8:	8b 40 04             	mov    0x4(%eax),%eax
801089bb:	85 c0                	test   %eax,%eax
801089bd:	75 0c                	jne    801089cb <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801089bf:	c7 04 24 0d a2 10 80 	movl   $0x8010a20d,(%esp)
801089c6:	e8 89 7b ff ff       	call   80100554 <panic>

  pushcli();
801089cb:	e8 06 cd ff ff       	call   801056d6 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801089d0:	e8 da ba ff ff       	call   801044af <mycpu>
801089d5:	89 c3                	mov    %eax,%ebx
801089d7:	e8 d3 ba ff ff       	call   801044af <mycpu>
801089dc:	83 c0 08             	add    $0x8,%eax
801089df:	89 c6                	mov    %eax,%esi
801089e1:	e8 c9 ba ff ff       	call   801044af <mycpu>
801089e6:	83 c0 08             	add    $0x8,%eax
801089e9:	c1 e8 10             	shr    $0x10,%eax
801089ec:	89 c7                	mov    %eax,%edi
801089ee:	e8 bc ba ff ff       	call   801044af <mycpu>
801089f3:	83 c0 08             	add    $0x8,%eax
801089f6:	c1 e8 18             	shr    $0x18,%eax
801089f9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108a00:	67 00 
80108a02:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108a09:	89 f9                	mov    %edi,%ecx
80108a0b:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108a11:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a17:	83 e2 f0             	and    $0xfffffff0,%edx
80108a1a:	83 ca 09             	or     $0x9,%edx
80108a1d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a23:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a29:	83 ca 10             	or     $0x10,%edx
80108a2c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a32:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a38:	83 e2 9f             	and    $0xffffff9f,%edx
80108a3b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a41:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a47:	83 ca 80             	or     $0xffffff80,%edx
80108a4a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a50:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a56:	83 e2 f0             	and    $0xfffffff0,%edx
80108a59:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a5f:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a65:	83 e2 ef             	and    $0xffffffef,%edx
80108a68:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a6e:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a74:	83 e2 df             	and    $0xffffffdf,%edx
80108a77:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a7d:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a83:	83 ca 40             	or     $0x40,%edx
80108a86:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a8c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a92:	83 e2 7f             	and    $0x7f,%edx
80108a95:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a9b:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108aa1:	e8 09 ba ff ff       	call   801044af <mycpu>
80108aa6:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108aac:	83 e2 ef             	and    $0xffffffef,%edx
80108aaf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108ab5:	e8 f5 b9 ff ff       	call   801044af <mycpu>
80108aba:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108ac0:	e8 ea b9 ff ff       	call   801044af <mycpu>
80108ac5:	8b 55 08             	mov    0x8(%ebp),%edx
80108ac8:	8b 52 08             	mov    0x8(%edx),%edx
80108acb:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108ad1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108ad4:	e8 d6 b9 ff ff       	call   801044af <mycpu>
80108ad9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108adf:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108ae6:	e8 30 f9 ff ff       	call   8010841b <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80108aee:	8b 40 04             	mov    0x4(%eax),%eax
80108af1:	05 00 00 00 80       	add    $0x80000000,%eax
80108af6:	89 04 24             	mov    %eax,(%esp)
80108af9:	e8 32 f9 ff ff       	call   80108430 <lcr3>
  popcli();
80108afe:	e8 1d cc ff ff       	call   80105720 <popcli>
}
80108b03:	83 c4 1c             	add    $0x1c,%esp
80108b06:	5b                   	pop    %ebx
80108b07:	5e                   	pop    %esi
80108b08:	5f                   	pop    %edi
80108b09:	5d                   	pop    %ebp
80108b0a:	c3                   	ret    

80108b0b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108b0b:	55                   	push   %ebp
80108b0c:	89 e5                	mov    %esp,%ebp
80108b0e:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108b11:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108b18:	76 0c                	jbe    80108b26 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108b1a:	c7 04 24 21 a2 10 80 	movl   $0x8010a221,(%esp)
80108b21:	e8 2e 7a ff ff       	call   80100554 <panic>
  mem = kalloc();
80108b26:	e8 73 a3 ff ff       	call   80102e9e <kalloc>
80108b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108b2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b35:	00 
80108b36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b3d:	00 
80108b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b41:	89 04 24             	mov    %eax,(%esp)
80108b44:	e8 91 cc ff ff       	call   801057da <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4c:	05 00 00 00 80       	add    $0x80000000,%eax
80108b51:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108b58:	00 
80108b59:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108b5d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b64:	00 
80108b65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b6c:	00 
80108b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80108b70:	89 04 24             	mov    %eax,(%esp)
80108b73:	e8 9c fc ff ff       	call   80108814 <mappages>
  memmove(mem, init, sz);
80108b78:	8b 45 10             	mov    0x10(%ebp),%eax
80108b7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b82:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b89:	89 04 24             	mov    %eax,(%esp)
80108b8c:	e8 12 cd ff ff       	call   801058a3 <memmove>
}
80108b91:	c9                   	leave  
80108b92:	c3                   	ret    

80108b93 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108b93:	55                   	push   %ebp
80108b94:	89 e5                	mov    %esp,%ebp
80108b96:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108b99:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b9c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108ba1:	85 c0                	test   %eax,%eax
80108ba3:	74 0c                	je     80108bb1 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108ba5:	c7 04 24 3c a2 10 80 	movl   $0x8010a23c,(%esp)
80108bac:	e8 a3 79 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108bb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bb8:	e9 a6 00 00 00       	jmp    80108c63 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bc3:	01 d0                	add    %edx,%eax
80108bc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bcc:	00 
80108bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd4:	89 04 24             	mov    %eax,(%esp)
80108bd7:	e8 9c fb ff ff       	call   80108778 <walkpgdir>
80108bdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108bdf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108be3:	75 0c                	jne    80108bf1 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108be5:	c7 04 24 5f a2 10 80 	movl   $0x8010a25f,(%esp)
80108bec:	e8 63 79 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf4:	8b 00                	mov    (%eax),%eax
80108bf6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bfb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c01:	8b 55 18             	mov    0x18(%ebp),%edx
80108c04:	29 c2                	sub    %eax,%edx
80108c06:	89 d0                	mov    %edx,%eax
80108c08:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108c0d:	77 0f                	ja     80108c1e <loaduvm+0x8b>
      n = sz - i;
80108c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c12:	8b 55 18             	mov    0x18(%ebp),%edx
80108c15:	29 c2                	sub    %eax,%edx
80108c17:	89 d0                	mov    %edx,%eax
80108c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c1c:	eb 07                	jmp    80108c25 <loaduvm+0x92>
    else
      n = PGSIZE;
80108c1e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c28:	8b 55 14             	mov    0x14(%ebp),%edx
80108c2b:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108c2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c31:	05 00 00 00 80       	add    $0x80000000,%eax
80108c36:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c39:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108c41:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c45:	8b 45 10             	mov    0x10(%ebp),%eax
80108c48:	89 04 24             	mov    %eax,(%esp)
80108c4b:	e8 09 93 ff ff       	call   80101f59 <readi>
80108c50:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c53:	74 07                	je     80108c5c <loaduvm+0xc9>
      return -1;
80108c55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c5a:	eb 18                	jmp    80108c74 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108c5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c66:	3b 45 18             	cmp    0x18(%ebp),%eax
80108c69:	0f 82 4e ff ff ff    	jb     80108bbd <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c74:	c9                   	leave  
80108c75:	c3                   	ret    

80108c76 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c76:	55                   	push   %ebp
80108c77:	89 e5                	mov    %esp,%ebp
80108c79:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108c7c:	8b 45 10             	mov    0x10(%ebp),%eax
80108c7f:	85 c0                	test   %eax,%eax
80108c81:	79 0a                	jns    80108c8d <allocuvm+0x17>
    return 0;
80108c83:	b8 00 00 00 00       	mov    $0x0,%eax
80108c88:	e9 fd 00 00 00       	jmp    80108d8a <allocuvm+0x114>
  if(newsz < oldsz)
80108c8d:	8b 45 10             	mov    0x10(%ebp),%eax
80108c90:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c93:	73 08                	jae    80108c9d <allocuvm+0x27>
    return oldsz;
80108c95:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c98:	e9 ed 00 00 00       	jmp    80108d8a <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ca0:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ca5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108cad:	e9 c9 00 00 00       	jmp    80108d7b <allocuvm+0x105>
    mem = kalloc();
80108cb2:	e8 e7 a1 ff ff       	call   80102e9e <kalloc>
80108cb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108cba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108cbe:	75 2f                	jne    80108cef <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108cc0:	c7 04 24 7d a2 10 80 	movl   $0x8010a27d,(%esp)
80108cc7:	e8 f5 76 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ccf:	89 44 24 08          	mov    %eax,0x8(%esp)
80108cd3:	8b 45 10             	mov    0x10(%ebp),%eax
80108cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cda:	8b 45 08             	mov    0x8(%ebp),%eax
80108cdd:	89 04 24             	mov    %eax,(%esp)
80108ce0:	e8 a7 00 00 00       	call   80108d8c <deallocuvm>
      return 0;
80108ce5:	b8 00 00 00 00       	mov    $0x0,%eax
80108cea:	e9 9b 00 00 00       	jmp    80108d8a <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108cef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108cf6:	00 
80108cf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108cfe:	00 
80108cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d02:	89 04 24             	mov    %eax,(%esp)
80108d05:	e8 d0 ca ff ff       	call   801057da <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d0d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d16:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108d1d:	00 
80108d1e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108d22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d29:	00 
80108d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d31:	89 04 24             	mov    %eax,(%esp)
80108d34:	e8 db fa ff ff       	call   80108814 <mappages>
80108d39:	85 c0                	test   %eax,%eax
80108d3b:	79 37                	jns    80108d74 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108d3d:	c7 04 24 95 a2 10 80 	movl   $0x8010a295,(%esp)
80108d44:	e8 78 76 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d50:	8b 45 10             	mov    0x10(%ebp),%eax
80108d53:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d57:	8b 45 08             	mov    0x8(%ebp),%eax
80108d5a:	89 04 24             	mov    %eax,(%esp)
80108d5d:	e8 2a 00 00 00       	call   80108d8c <deallocuvm>
      kfree(mem);
80108d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d65:	89 04 24             	mov    %eax,(%esp)
80108d68:	e8 42 a0 ff ff       	call   80102daf <kfree>
      return 0;
80108d6d:	b8 00 00 00 00       	mov    $0x0,%eax
80108d72:	eb 16                	jmp    80108d8a <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108d74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108d81:	0f 82 2b ff ff ff    	jb     80108cb2 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108d87:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d8a:	c9                   	leave  
80108d8b:	c3                   	ret    

80108d8c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108d8c:	55                   	push   %ebp
80108d8d:	89 e5                	mov    %esp,%ebp
80108d8f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108d92:	8b 45 10             	mov    0x10(%ebp),%eax
80108d95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d98:	72 08                	jb     80108da2 <deallocuvm+0x16>
    return oldsz;
80108d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d9d:	e9 ac 00 00 00       	jmp    80108e4e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108da2:	8b 45 10             	mov    0x10(%ebp),%eax
80108da5:	05 ff 0f 00 00       	add    $0xfff,%eax
80108daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108db2:	e9 88 00 00 00       	jmp    80108e3f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108dc1:	00 
80108dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc9:	89 04 24             	mov    %eax,(%esp)
80108dcc:	e8 a7 f9 ff ff       	call   80108778 <walkpgdir>
80108dd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108dd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108dd8:	75 14                	jne    80108dee <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ddd:	c1 e8 16             	shr    $0x16,%eax
80108de0:	40                   	inc    %eax
80108de1:	c1 e0 16             	shl    $0x16,%eax
80108de4:	2d 00 10 00 00       	sub    $0x1000,%eax
80108de9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108dec:	eb 4a                	jmp    80108e38 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df1:	8b 00                	mov    (%eax),%eax
80108df3:	83 e0 01             	and    $0x1,%eax
80108df6:	85 c0                	test   %eax,%eax
80108df8:	74 3e                	je     80108e38 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dfd:	8b 00                	mov    (%eax),%eax
80108dff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e04:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108e07:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e0b:	75 0c                	jne    80108e19 <deallocuvm+0x8d>
        panic("kfree");
80108e0d:	c7 04 24 b1 a2 10 80 	movl   $0x8010a2b1,(%esp)
80108e14:	e8 3b 77 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108e19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e1c:	05 00 00 00 80       	add    $0x80000000,%eax
80108e21:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108e24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e27:	89 04 24             	mov    %eax,(%esp)
80108e2a:	e8 80 9f ff ff       	call   80102daf <kfree>
      *pte = 0;
80108e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108e38:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e45:	0f 82 6c ff ff ff    	jb     80108db7 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108e4b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e4e:	c9                   	leave  
80108e4f:	c3                   	ret    

80108e50 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108e50:	55                   	push   %ebp
80108e51:	89 e5                	mov    %esp,%ebp
80108e53:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108e56:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e5a:	75 0c                	jne    80108e68 <freevm+0x18>
    panic("freevm: no pgdir");
80108e5c:	c7 04 24 b7 a2 10 80 	movl   $0x8010a2b7,(%esp)
80108e63:	e8 ec 76 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108e68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e6f:	00 
80108e70:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108e77:	80 
80108e78:	8b 45 08             	mov    0x8(%ebp),%eax
80108e7b:	89 04 24             	mov    %eax,(%esp)
80108e7e:	e8 09 ff ff ff       	call   80108d8c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108e83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e8a:	eb 44                	jmp    80108ed0 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e96:	8b 45 08             	mov    0x8(%ebp),%eax
80108e99:	01 d0                	add    %edx,%eax
80108e9b:	8b 00                	mov    (%eax),%eax
80108e9d:	83 e0 01             	and    $0x1,%eax
80108ea0:	85 c0                	test   %eax,%eax
80108ea2:	74 29                	je     80108ecd <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108eae:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb1:	01 d0                	add    %edx,%eax
80108eb3:	8b 00                	mov    (%eax),%eax
80108eb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eba:	05 00 00 00 80       	add    $0x80000000,%eax
80108ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec5:	89 04 24             	mov    %eax,(%esp)
80108ec8:	e8 e2 9e ff ff       	call   80102daf <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108ecd:	ff 45 f4             	incl   -0xc(%ebp)
80108ed0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ed7:	76 b3                	jbe    80108e8c <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80108edc:	89 04 24             	mov    %eax,(%esp)
80108edf:	e8 cb 9e ff ff       	call   80102daf <kfree>
}
80108ee4:	c9                   	leave  
80108ee5:	c3                   	ret    

80108ee6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108ee6:	55                   	push   %ebp
80108ee7:	89 e5                	mov    %esp,%ebp
80108ee9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108eec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ef3:	00 
80108ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
80108efb:	8b 45 08             	mov    0x8(%ebp),%eax
80108efe:	89 04 24             	mov    %eax,(%esp)
80108f01:	e8 72 f8 ff ff       	call   80108778 <walkpgdir>
80108f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108f09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f0d:	75 0c                	jne    80108f1b <clearpteu+0x35>
    panic("clearpteu");
80108f0f:	c7 04 24 c8 a2 10 80 	movl   $0x8010a2c8,(%esp)
80108f16:	e8 39 76 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1e:	8b 00                	mov    (%eax),%eax
80108f20:	83 e0 fb             	and    $0xfffffffb,%eax
80108f23:	89 c2                	mov    %eax,%edx
80108f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f28:	89 10                	mov    %edx,(%eax)
}
80108f2a:	c9                   	leave  
80108f2b:	c3                   	ret    

80108f2c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108f2c:	55                   	push   %ebp
80108f2d:	89 e5                	mov    %esp,%ebp
80108f2f:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108f32:	e8 73 f9 ff ff       	call   801088aa <setupkvm>
80108f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f3e:	75 0a                	jne    80108f4a <copyuvm+0x1e>
    return 0;
80108f40:	b8 00 00 00 00       	mov    $0x0,%eax
80108f45:	e9 f8 00 00 00       	jmp    80109042 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108f4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f51:	e9 cb 00 00 00       	jmp    80109021 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f60:	00 
80108f61:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f65:	8b 45 08             	mov    0x8(%ebp),%eax
80108f68:	89 04 24             	mov    %eax,(%esp)
80108f6b:	e8 08 f8 ff ff       	call   80108778 <walkpgdir>
80108f70:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f73:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f77:	75 0c                	jne    80108f85 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108f79:	c7 04 24 d2 a2 10 80 	movl   $0x8010a2d2,(%esp)
80108f80:	e8 cf 75 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108f85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f88:	8b 00                	mov    (%eax),%eax
80108f8a:	83 e0 01             	and    $0x1,%eax
80108f8d:	85 c0                	test   %eax,%eax
80108f8f:	75 0c                	jne    80108f9d <copyuvm+0x71>
      panic("copyuvm: page not present");
80108f91:	c7 04 24 ec a2 10 80 	movl   $0x8010a2ec,(%esp)
80108f98:	e8 b7 75 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa0:	8b 00                	mov    (%eax),%eax
80108fa2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fad:	8b 00                	mov    (%eax),%eax
80108faf:	25 ff 0f 00 00       	and    $0xfff,%eax
80108fb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108fb7:	e8 e2 9e ff ff       	call   80102e9e <kalloc>
80108fbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108fbf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108fc3:	75 02                	jne    80108fc7 <copyuvm+0x9b>
      goto bad;
80108fc5:	eb 6b                	jmp    80109032 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108fc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fca:	05 00 00 00 80       	add    $0x80000000,%eax
80108fcf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108fd6:	00 
80108fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fde:	89 04 24             	mov    %eax,(%esp)
80108fe1:	e8 bd c8 ff ff       	call   801058a3 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108fe6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108fe9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fec:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff5:	89 54 24 10          	mov    %edx,0x10(%esp)
80108ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108ffd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109004:	00 
80109005:	89 44 24 04          	mov    %eax,0x4(%esp)
80109009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900c:	89 04 24             	mov    %eax,(%esp)
8010900f:	e8 00 f8 ff ff       	call   80108814 <mappages>
80109014:	85 c0                	test   %eax,%eax
80109016:	79 02                	jns    8010901a <copyuvm+0xee>
      goto bad;
80109018:	eb 18                	jmp    80109032 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010901a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109024:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109027:	0f 82 29 ff ff ff    	jb     80108f56 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
8010902d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109030:	eb 10                	jmp    80109042 <copyuvm+0x116>

bad:
  freevm(d);
80109032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109035:	89 04 24             	mov    %eax,(%esp)
80109038:	e8 13 fe ff ff       	call   80108e50 <freevm>
  return 0;
8010903d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109042:	c9                   	leave  
80109043:	c3                   	ret    

80109044 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109044:	55                   	push   %ebp
80109045:	89 e5                	mov    %esp,%ebp
80109047:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010904a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109051:	00 
80109052:	8b 45 0c             	mov    0xc(%ebp),%eax
80109055:	89 44 24 04          	mov    %eax,0x4(%esp)
80109059:	8b 45 08             	mov    0x8(%ebp),%eax
8010905c:	89 04 24             	mov    %eax,(%esp)
8010905f:	e8 14 f7 ff ff       	call   80108778 <walkpgdir>
80109064:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906a:	8b 00                	mov    (%eax),%eax
8010906c:	83 e0 01             	and    $0x1,%eax
8010906f:	85 c0                	test   %eax,%eax
80109071:	75 07                	jne    8010907a <uva2ka+0x36>
    return 0;
80109073:	b8 00 00 00 00       	mov    $0x0,%eax
80109078:	eb 22                	jmp    8010909c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010907a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010907d:	8b 00                	mov    (%eax),%eax
8010907f:	83 e0 04             	and    $0x4,%eax
80109082:	85 c0                	test   %eax,%eax
80109084:	75 07                	jne    8010908d <uva2ka+0x49>
    return 0;
80109086:	b8 00 00 00 00       	mov    $0x0,%eax
8010908b:	eb 0f                	jmp    8010909c <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
8010908d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109090:	8b 00                	mov    (%eax),%eax
80109092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109097:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010909c:	c9                   	leave  
8010909d:	c3                   	ret    

8010909e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010909e:	55                   	push   %ebp
8010909f:	89 e5                	mov    %esp,%ebp
801090a1:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801090a4:	8b 45 10             	mov    0x10(%ebp),%eax
801090a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801090aa:	e9 87 00 00 00       	jmp    80109136 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801090af:	8b 45 0c             	mov    0xc(%ebp),%eax
801090b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801090ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801090c1:	8b 45 08             	mov    0x8(%ebp),%eax
801090c4:	89 04 24             	mov    %eax,(%esp)
801090c7:	e8 78 ff ff ff       	call   80109044 <uva2ka>
801090cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801090cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801090d3:	75 07                	jne    801090dc <copyout+0x3e>
      return -1;
801090d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090da:	eb 69                	jmp    80109145 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801090dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801090df:	8b 55 ec             	mov    -0x14(%ebp),%edx
801090e2:	29 c2                	sub    %eax,%edx
801090e4:	89 d0                	mov    %edx,%eax
801090e6:	05 00 10 00 00       	add    $0x1000,%eax
801090eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801090ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f1:	3b 45 14             	cmp    0x14(%ebp),%eax
801090f4:	76 06                	jbe    801090fc <copyout+0x5e>
      n = len;
801090f6:	8b 45 14             	mov    0x14(%ebp),%eax
801090f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801090fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80109102:	29 c2                	sub    %eax,%edx
80109104:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109107:	01 c2                	add    %eax,%edx
80109109:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010910c:	89 44 24 08          	mov    %eax,0x8(%esp)
80109110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109113:	89 44 24 04          	mov    %eax,0x4(%esp)
80109117:	89 14 24             	mov    %edx,(%esp)
8010911a:	e8 84 c7 ff ff       	call   801058a3 <memmove>
    len -= n;
8010911f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109122:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109128:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010912b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010912e:	05 00 10 00 00       	add    $0x1000,%eax
80109133:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109136:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010913a:	0f 85 6f ff ff ff    	jne    801090af <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109140:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109145:	c9                   	leave  
80109146:	c3                   	ret    
	...

80109148 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80109148:	55                   	push   %ebp
80109149:	89 e5                	mov    %esp,%ebp
8010914b:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
8010914e:	8b 45 10             	mov    0x10(%ebp),%eax
80109151:	89 44 24 08          	mov    %eax,0x8(%esp)
80109155:	8b 45 0c             	mov    0xc(%ebp),%eax
80109158:	89 44 24 04          	mov    %eax,0x4(%esp)
8010915c:	8b 45 08             	mov    0x8(%ebp),%eax
8010915f:	89 04 24             	mov    %eax,(%esp)
80109162:	e8 3c c7 ff ff       	call   801058a3 <memmove>
}
80109167:	c9                   	leave  
80109168:	c3                   	ret    

80109169 <strcpy>:

char* strcpy(char *s, char *t){
80109169:	55                   	push   %ebp
8010916a:	89 e5                	mov    %esp,%ebp
8010916c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010916f:	8b 45 08             	mov    0x8(%ebp),%eax
80109172:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80109175:	90                   	nop
80109176:	8b 45 08             	mov    0x8(%ebp),%eax
80109179:	8d 50 01             	lea    0x1(%eax),%edx
8010917c:	89 55 08             	mov    %edx,0x8(%ebp)
8010917f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109182:	8d 4a 01             	lea    0x1(%edx),%ecx
80109185:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80109188:	8a 12                	mov    (%edx),%dl
8010918a:	88 10                	mov    %dl,(%eax)
8010918c:	8a 00                	mov    (%eax),%al
8010918e:	84 c0                	test   %al,%al
80109190:	75 e4                	jne    80109176 <strcpy+0xd>
    ;
  return os;
80109192:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109195:	c9                   	leave  
80109196:	c3                   	ret    

80109197 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80109197:	55                   	push   %ebp
80109198:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
8010919a:	eb 06                	jmp    801091a2 <strcmp+0xb>
    p++, q++;
8010919c:	ff 45 08             	incl   0x8(%ebp)
8010919f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
801091a2:	8b 45 08             	mov    0x8(%ebp),%eax
801091a5:	8a 00                	mov    (%eax),%al
801091a7:	84 c0                	test   %al,%al
801091a9:	74 0e                	je     801091b9 <strcmp+0x22>
801091ab:	8b 45 08             	mov    0x8(%ebp),%eax
801091ae:	8a 10                	mov    (%eax),%dl
801091b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801091b3:	8a 00                	mov    (%eax),%al
801091b5:	38 c2                	cmp    %al,%dl
801091b7:	74 e3                	je     8010919c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801091b9:	8b 45 08             	mov    0x8(%ebp),%eax
801091bc:	8a 00                	mov    (%eax),%al
801091be:	0f b6 d0             	movzbl %al,%edx
801091c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801091c4:	8a 00                	mov    (%eax),%al
801091c6:	0f b6 c0             	movzbl %al,%eax
801091c9:	29 c2                	sub    %eax,%edx
801091cb:	89 d0                	mov    %edx,%eax
}
801091cd:	5d                   	pop    %ebp
801091ce:	c3                   	ret    

801091cf <set_root_inode>:

// struct con

void set_root_inode(char* name){
801091cf:	55                   	push   %ebp
801091d0:	89 e5                	mov    %esp,%ebp
801091d2:	53                   	push   %ebx
801091d3:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
801091d6:	8b 45 08             	mov    0x8(%ebp),%eax
801091d9:	89 04 24             	mov    %eax,(%esp)
801091dc:	e8 6a 01 00 00       	call   8010934b <find>
801091e1:	89 c3                	mov    %eax,%ebx
801091e3:	8b 45 08             	mov    0x8(%ebp),%eax
801091e6:	89 04 24             	mov    %eax,(%esp)
801091e9:	e8 3f 95 ff ff       	call   8010272d <namei>
801091ee:	89 c2                	mov    %eax,%edx
801091f0:	89 d8                	mov    %ebx,%eax
801091f2:	01 c0                	add    %eax,%eax
801091f4:	01 d8                	add    %ebx,%eax
801091f6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
801091fd:	01 c8                	add    %ecx,%eax
801091ff:	c1 e0 02             	shl    $0x2,%eax
80109202:	05 30 8d 11 80       	add    $0x80118d30,%eax
80109207:	89 50 08             	mov    %edx,0x8(%eax)

}
8010920a:	83 c4 14             	add    $0x14,%esp
8010920d:	5b                   	pop    %ebx
8010920e:	5d                   	pop    %ebp
8010920f:	c3                   	ret    

80109210 <get_name>:

void get_name(int vc_num, char* name){
80109210:	55                   	push   %ebp
80109211:	89 e5                	mov    %esp,%ebp
80109213:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80109216:	8b 55 08             	mov    0x8(%ebp),%edx
80109219:	89 d0                	mov    %edx,%eax
8010921b:	01 c0                	add    %eax,%eax
8010921d:	01 d0                	add    %edx,%eax
8010921f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109226:	01 d0                	add    %edx,%eax
80109228:	c1 e0 02             	shl    $0x2,%eax
8010922b:	83 c0 10             	add    $0x10,%eax
8010922e:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109233:	83 c0 08             	add    $0x8,%eax
80109236:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80109239:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
80109240:	eb 03                	jmp    80109245 <get_name+0x35>
	{
		i++;
80109242:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80109245:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924b:	01 d0                	add    %edx,%eax
8010924d:	8a 00                	mov    (%eax),%al
8010924f:	84 c0                	test   %al,%al
80109251:	75 ef                	jne    80109242 <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80109253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109256:	89 44 24 08          	mov    %eax,0x8(%esp)
8010925a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010925d:	89 44 24 04          	mov    %eax,0x4(%esp)
80109261:	8b 45 0c             	mov    0xc(%ebp),%eax
80109264:	89 04 24             	mov    %eax,(%esp)
80109267:	e8 dc fe ff ff       	call   80109148 <memcpy2>
	name[i] = '\0';
8010926c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010926f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109272:	01 d0                	add    %edx,%eax
80109274:	c6 00 00             	movb   $0x0,(%eax)
}
80109277:	c9                   	leave  
80109278:	c3                   	ret    

80109279 <get_used>:

int get_used(){
80109279:	55                   	push   %ebp
8010927a:	89 e5                	mov    %esp,%ebp
8010927c:	83 ec 18             	sub    $0x18,%esp
	int x = 0;
8010927f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109286:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010928d:	eb 3c                	jmp    801092cb <get_used+0x52>
		if(strcmp(containers[i].name, "") == 0){
8010928f:	8b 55 f8             	mov    -0x8(%ebp),%edx
80109292:	89 d0                	mov    %edx,%eax
80109294:	01 c0                	add    %eax,%eax
80109296:	01 d0                	add    %edx,%eax
80109298:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010929f:	01 d0                	add    %edx,%eax
801092a1:	c1 e0 02             	shl    $0x2,%eax
801092a4:	83 c0 10             	add    $0x10,%eax
801092a7:	05 00 8d 11 80       	add    $0x80118d00,%eax
801092ac:	83 c0 08             	add    $0x8,%eax
801092af:	c7 44 24 04 08 a3 10 	movl   $0x8010a308,0x4(%esp)
801092b6:	80 
801092b7:	89 04 24             	mov    %eax,(%esp)
801092ba:	e8 d8 fe ff ff       	call   80109197 <strcmp>
801092bf:	85 c0                	test   %eax,%eax
801092c1:	75 02                	jne    801092c5 <get_used+0x4c>
			continue;
801092c3:	eb 03                	jmp    801092c8 <get_used+0x4f>
		}
		x++;
801092c5:	ff 45 fc             	incl   -0x4(%ebp)
}

int get_used(){
	int x = 0;
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801092c8:	ff 45 f8             	incl   -0x8(%ebp)
801092cb:	83 7d f8 03          	cmpl   $0x3,-0x8(%ebp)
801092cf:	7e be                	jle    8010928f <get_used+0x16>
		if(strcmp(containers[i].name, "") == 0){
			continue;
		}
		x++;
	}
	return x;
801092d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801092d4:	c9                   	leave  
801092d5:	c3                   	ret    

801092d6 <g_name>:

char* g_name(int vc_bun){
801092d6:	55                   	push   %ebp
801092d7:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
801092d9:	8b 55 08             	mov    0x8(%ebp),%edx
801092dc:	89 d0                	mov    %edx,%eax
801092de:	01 c0                	add    %eax,%eax
801092e0:	01 d0                	add    %edx,%eax
801092e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092e9:	01 d0                	add    %edx,%eax
801092eb:	c1 e0 02             	shl    $0x2,%eax
801092ee:	83 c0 10             	add    $0x10,%eax
801092f1:	05 00 8d 11 80       	add    $0x80118d00,%eax
801092f6:	83 c0 08             	add    $0x8,%eax
}
801092f9:	5d                   	pop    %ebp
801092fa:	c3                   	ret    

801092fb <is_full>:

int is_full(){
801092fb:	55                   	push   %ebp
801092fc:	89 e5                	mov    %esp,%ebp
801092fe:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109308:	eb 34                	jmp    8010933e <is_full+0x43>
		if(strlen(containers[i].name) == 0){
8010930a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010930d:	89 d0                	mov    %edx,%eax
8010930f:	01 c0                	add    %eax,%eax
80109311:	01 d0                	add    %edx,%eax
80109313:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010931a:	01 d0                	add    %edx,%eax
8010931c:	c1 e0 02             	shl    $0x2,%eax
8010931f:	83 c0 10             	add    $0x10,%eax
80109322:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109327:	83 c0 08             	add    $0x8,%eax
8010932a:	89 04 24             	mov    %eax,(%esp)
8010932d:	e8 fb c6 ff ff       	call   80105a2d <strlen>
80109332:	85 c0                	test   %eax,%eax
80109334:	75 05                	jne    8010933b <is_full+0x40>
			return i;
80109336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109339:	eb 0e                	jmp    80109349 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010933b:	ff 45 f4             	incl   -0xc(%ebp)
8010933e:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109342:	7e c6                	jle    8010930a <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109349:	c9                   	leave  
8010934a:	c3                   	ret    

8010934b <find>:

int find(char* name){
8010934b:	55                   	push   %ebp
8010934c:	89 e5                	mov    %esp,%ebp
8010934e:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109351:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109358:	eb 54                	jmp    801093ae <find+0x63>
		if(strcmp(name, "") == 0){
8010935a:	c7 44 24 04 08 a3 10 	movl   $0x8010a308,0x4(%esp)
80109361:	80 
80109362:	8b 45 08             	mov    0x8(%ebp),%eax
80109365:	89 04 24             	mov    %eax,(%esp)
80109368:	e8 2a fe ff ff       	call   80109197 <strcmp>
8010936d:	85 c0                	test   %eax,%eax
8010936f:	75 02                	jne    80109373 <find+0x28>
			continue;
80109371:	eb 38                	jmp    801093ab <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80109373:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109376:	89 d0                	mov    %edx,%eax
80109378:	01 c0                	add    %eax,%eax
8010937a:	01 d0                	add    %edx,%eax
8010937c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109383:	01 d0                	add    %edx,%eax
80109385:	c1 e0 02             	shl    $0x2,%eax
80109388:	83 c0 10             	add    $0x10,%eax
8010938b:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109390:	83 c0 08             	add    $0x8,%eax
80109393:	89 44 24 04          	mov    %eax,0x4(%esp)
80109397:	8b 45 08             	mov    0x8(%ebp),%eax
8010939a:	89 04 24             	mov    %eax,(%esp)
8010939d:	e8 f5 fd ff ff       	call   80109197 <strcmp>
801093a2:	85 c0                	test   %eax,%eax
801093a4:	75 05                	jne    801093ab <find+0x60>
			return i;
801093a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801093a9:	eb 0e                	jmp    801093b9 <find+0x6e>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801093ab:	ff 45 fc             	incl   -0x4(%ebp)
801093ae:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801093b2:	7e a6                	jle    8010935a <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
801093b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801093b9:	c9                   	leave  
801093ba:	c3                   	ret    

801093bb <get_max_proc>:

int get_max_proc(int vc_num){
801093bb:	55                   	push   %ebp
801093bc:	89 e5                	mov    %esp,%ebp
801093be:	57                   	push   %edi
801093bf:	56                   	push   %esi
801093c0:	53                   	push   %ebx
801093c1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801093c4:	8b 55 08             	mov    0x8(%ebp),%edx
801093c7:	89 d0                	mov    %edx,%eax
801093c9:	01 c0                	add    %eax,%eax
801093cb:	01 d0                	add    %edx,%eax
801093cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093d4:	01 d0                	add    %edx,%eax
801093d6:	c1 e0 02             	shl    $0x2,%eax
801093d9:	05 00 8d 11 80       	add    $0x80118d00,%eax
801093de:	8d 55 b8             	lea    -0x48(%ebp),%edx
801093e1:	89 c3                	mov    %eax,%ebx
801093e3:	b8 0f 00 00 00       	mov    $0xf,%eax
801093e8:	89 d7                	mov    %edx,%edi
801093ea:	89 de                	mov    %ebx,%esi
801093ec:	89 c1                	mov    %eax,%ecx
801093ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
801093f0:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
801093f3:	83 c4 40             	add    $0x40,%esp
801093f6:	5b                   	pop    %ebx
801093f7:	5e                   	pop    %esi
801093f8:	5f                   	pop    %edi
801093f9:	5d                   	pop    %ebp
801093fa:	c3                   	ret    

801093fb <get_container>:

struct container* get_container(int vc_num){
801093fb:	55                   	push   %ebp
801093fc:	89 e5                	mov    %esp,%ebp
801093fe:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80109401:	8b 55 08             	mov    0x8(%ebp),%edx
80109404:	89 d0                	mov    %edx,%eax
80109406:	01 c0                	add    %eax,%eax
80109408:	01 d0                	add    %edx,%eax
8010940a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109411:	01 d0                	add    %edx,%eax
80109413:	c1 e0 02             	shl    $0x2,%eax
80109416:	05 00 8d 11 80       	add    $0x80118d00,%eax
8010941b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
8010941e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109421:	c9                   	leave  
80109422:	c3                   	ret    

80109423 <get_max_mem>:

int get_max_mem(int vc_num){
80109423:	55                   	push   %ebp
80109424:	89 e5                	mov    %esp,%ebp
80109426:	57                   	push   %edi
80109427:	56                   	push   %esi
80109428:	53                   	push   %ebx
80109429:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010942c:	8b 55 08             	mov    0x8(%ebp),%edx
8010942f:	89 d0                	mov    %edx,%eax
80109431:	01 c0                	add    %eax,%eax
80109433:	01 d0                	add    %edx,%eax
80109435:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010943c:	01 d0                	add    %edx,%eax
8010943e:	c1 e0 02             	shl    $0x2,%eax
80109441:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109446:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109449:	89 c3                	mov    %eax,%ebx
8010944b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109450:	89 d7                	mov    %edx,%edi
80109452:	89 de                	mov    %ebx,%esi
80109454:	89 c1                	mov    %eax,%ecx
80109456:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80109458:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
8010945b:	83 c4 40             	add    $0x40,%esp
8010945e:	5b                   	pop    %ebx
8010945f:	5e                   	pop    %esi
80109460:	5f                   	pop    %edi
80109461:	5d                   	pop    %ebp
80109462:	c3                   	ret    

80109463 <get_max_disk>:

int get_max_disk(int vc_num){
80109463:	55                   	push   %ebp
80109464:	89 e5                	mov    %esp,%ebp
80109466:	57                   	push   %edi
80109467:	56                   	push   %esi
80109468:	53                   	push   %ebx
80109469:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010946c:	8b 55 08             	mov    0x8(%ebp),%edx
8010946f:	89 d0                	mov    %edx,%eax
80109471:	01 c0                	add    %eax,%eax
80109473:	01 d0                	add    %edx,%eax
80109475:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010947c:	01 d0                	add    %edx,%eax
8010947e:	c1 e0 02             	shl    $0x2,%eax
80109481:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109486:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109489:	89 c3                	mov    %eax,%ebx
8010948b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109490:	89 d7                	mov    %edx,%edi
80109492:	89 de                	mov    %ebx,%esi
80109494:	89 c1                	mov    %eax,%ecx
80109496:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80109498:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
8010949b:	83 c4 40             	add    $0x40,%esp
8010949e:	5b                   	pop    %ebx
8010949f:	5e                   	pop    %esi
801094a0:	5f                   	pop    %edi
801094a1:	5d                   	pop    %ebp
801094a2:	c3                   	ret    

801094a3 <get_curr_proc>:

int get_curr_proc(int vc_num){
801094a3:	55                   	push   %ebp
801094a4:	89 e5                	mov    %esp,%ebp
801094a6:	57                   	push   %edi
801094a7:	56                   	push   %esi
801094a8:	53                   	push   %ebx
801094a9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801094ac:	8b 55 08             	mov    0x8(%ebp),%edx
801094af:	89 d0                	mov    %edx,%eax
801094b1:	01 c0                	add    %eax,%eax
801094b3:	01 d0                	add    %edx,%eax
801094b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094bc:	01 d0                	add    %edx,%eax
801094be:	c1 e0 02             	shl    $0x2,%eax
801094c1:	05 00 8d 11 80       	add    $0x80118d00,%eax
801094c6:	8d 55 b8             	lea    -0x48(%ebp),%edx
801094c9:	89 c3                	mov    %eax,%ebx
801094cb:	b8 0f 00 00 00       	mov    $0xf,%eax
801094d0:	89 d7                	mov    %edx,%edi
801094d2:	89 de                	mov    %ebx,%esi
801094d4:	89 c1                	mov    %eax,%ecx
801094d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
801094d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801094db:	83 c4 40             	add    $0x40,%esp
801094de:	5b                   	pop    %ebx
801094df:	5e                   	pop    %esi
801094e0:	5f                   	pop    %edi
801094e1:	5d                   	pop    %ebp
801094e2:	c3                   	ret    

801094e3 <get_curr_mem>:

int get_curr_mem(int vc_num){
801094e3:	55                   	push   %ebp
801094e4:	89 e5                	mov    %esp,%ebp
801094e6:	57                   	push   %edi
801094e7:	56                   	push   %esi
801094e8:	53                   	push   %ebx
801094e9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801094ec:	8b 55 08             	mov    0x8(%ebp),%edx
801094ef:	89 d0                	mov    %edx,%eax
801094f1:	01 c0                	add    %eax,%eax
801094f3:	01 d0                	add    %edx,%eax
801094f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094fc:	01 d0                	add    %edx,%eax
801094fe:	c1 e0 02             	shl    $0x2,%eax
80109501:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109506:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109509:	89 c3                	mov    %eax,%ebx
8010950b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109510:	89 d7                	mov    %edx,%edi
80109512:	89 de                	mov    %ebx,%esi
80109514:	89 c1                	mov    %eax,%ecx
80109516:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
80109518:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
8010951b:	83 c4 40             	add    $0x40,%esp
8010951e:	5b                   	pop    %ebx
8010951f:	5e                   	pop    %esi
80109520:	5f                   	pop    %edi
80109521:	5d                   	pop    %ebp
80109522:	c3                   	ret    

80109523 <get_curr_disk>:

int get_curr_disk(int vc_num){
80109523:	55                   	push   %ebp
80109524:	89 e5                	mov    %esp,%ebp
80109526:	57                   	push   %edi
80109527:	56                   	push   %esi
80109528:	53                   	push   %ebx
80109529:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010952c:	8b 55 08             	mov    0x8(%ebp),%edx
8010952f:	89 d0                	mov    %edx,%eax
80109531:	01 c0                	add    %eax,%eax
80109533:	01 d0                	add    %edx,%eax
80109535:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010953c:	01 d0                	add    %edx,%eax
8010953e:	c1 e0 02             	shl    $0x2,%eax
80109541:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109546:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109549:	89 c3                	mov    %eax,%ebx
8010954b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109550:	89 d7                	mov    %edx,%edi
80109552:	89 de                	mov    %ebx,%esi
80109554:	89 c1                	mov    %eax,%ecx
80109556:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80109558:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
8010955b:	83 c4 40             	add    $0x40,%esp
8010955e:	5b                   	pop    %ebx
8010955f:	5e                   	pop    %esi
80109560:	5f                   	pop    %edi
80109561:	5d                   	pop    %ebp
80109562:	c3                   	ret    

80109563 <set_name>:

void set_name(char* name, int vc_num){
80109563:	55                   	push   %ebp
80109564:	89 e5                	mov    %esp,%ebp
80109566:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109569:	8b 55 0c             	mov    0xc(%ebp),%edx
8010956c:	89 d0                	mov    %edx,%eax
8010956e:	01 c0                	add    %eax,%eax
80109570:	01 d0                	add    %edx,%eax
80109572:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109579:	01 d0                	add    %edx,%eax
8010957b:	c1 e0 02             	shl    $0x2,%eax
8010957e:	83 c0 10             	add    $0x10,%eax
80109581:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109586:	8d 50 08             	lea    0x8(%eax),%edx
80109589:	8b 45 08             	mov    0x8(%ebp),%eax
8010958c:	89 44 24 04          	mov    %eax,0x4(%esp)
80109590:	89 14 24             	mov    %edx,(%esp)
80109593:	e8 d1 fb ff ff       	call   80109169 <strcpy>
}
80109598:	c9                   	leave  
80109599:	c3                   	ret    

8010959a <set_max_mem>:

void set_max_mem(int mem, int vc_num){
8010959a:	55                   	push   %ebp
8010959b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
8010959d:	8b 55 0c             	mov    0xc(%ebp),%edx
801095a0:	89 d0                	mov    %edx,%eax
801095a2:	01 c0                	add    %eax,%eax
801095a4:	01 d0                	add    %edx,%eax
801095a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095ad:	01 d0                	add    %edx,%eax
801095af:	c1 e0 02             	shl    $0x2,%eax
801095b2:	8d 90 00 8d 11 80    	lea    -0x7fee7300(%eax),%edx
801095b8:	8b 45 08             	mov    0x8(%ebp),%eax
801095bb:	89 02                	mov    %eax,(%edx)
}
801095bd:	5d                   	pop    %ebp
801095be:	c3                   	ret    

801095bf <set_max_disk>:

void set_max_disk(int disk, int vc_num){
801095bf:	55                   	push   %ebp
801095c0:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
801095c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801095c5:	89 d0                	mov    %edx,%eax
801095c7:	01 c0                	add    %eax,%eax
801095c9:	01 d0                	add    %edx,%eax
801095cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095d2:	01 d0                	add    %edx,%eax
801095d4:	c1 e0 02             	shl    $0x2,%eax
801095d7:	8d 90 00 8d 11 80    	lea    -0x7fee7300(%eax),%edx
801095dd:	8b 45 08             	mov    0x8(%ebp),%eax
801095e0:	89 42 08             	mov    %eax,0x8(%edx)
}
801095e3:	5d                   	pop    %ebp
801095e4:	c3                   	ret    

801095e5 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
801095e5:	55                   	push   %ebp
801095e6:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
801095e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801095eb:	89 d0                	mov    %edx,%eax
801095ed:	01 c0                	add    %eax,%eax
801095ef:	01 d0                	add    %edx,%eax
801095f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095f8:	01 d0                	add    %edx,%eax
801095fa:	c1 e0 02             	shl    $0x2,%eax
801095fd:	8d 90 00 8d 11 80    	lea    -0x7fee7300(%eax),%edx
80109603:	8b 45 08             	mov    0x8(%ebp),%eax
80109606:	89 42 04             	mov    %eax,0x4(%edx)
}
80109609:	5d                   	pop    %ebp
8010960a:	c3                   	ret    

8010960b <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010960b:	55                   	push   %ebp
8010960c:	89 e5                	mov    %esp,%ebp
8010960e:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
80109611:	8b 55 0c             	mov    0xc(%ebp),%edx
80109614:	89 d0                	mov    %edx,%eax
80109616:	01 c0                	add    %eax,%eax
80109618:	01 d0                	add    %edx,%eax
8010961a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109621:	01 d0                	add    %edx,%eax
80109623:	c1 e0 02             	shl    $0x2,%eax
80109626:	05 00 8d 11 80       	add    $0x80118d00,%eax
8010962b:	8b 40 0c             	mov    0xc(%eax),%eax
8010962e:	8d 48 01             	lea    0x1(%eax),%ecx
80109631:	8b 55 0c             	mov    0xc(%ebp),%edx
80109634:	89 d0                	mov    %edx,%eax
80109636:	01 c0                	add    %eax,%eax
80109638:	01 d0                	add    %edx,%eax
8010963a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109641:	01 d0                	add    %edx,%eax
80109643:	c1 e0 02             	shl    $0x2,%eax
80109646:	05 00 8d 11 80       	add    $0x80118d00,%eax
8010964b:	8b 00                	mov    (%eax),%eax
8010964d:	39 c1                	cmp    %eax,%ecx
8010964f:	7e 0e                	jle    8010965f <set_curr_mem+0x54>
		cprintf("Exceded memory resource; killing container");
80109651:	c7 04 24 0c a3 10 80 	movl   $0x8010a30c,(%esp)
80109658:	e8 64 6d ff ff       	call   801003c1 <cprintf>
8010965d:	eb 3d                	jmp    8010969c <set_curr_mem+0x91>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
8010965f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109662:	89 d0                	mov    %edx,%eax
80109664:	01 c0                	add    %eax,%eax
80109666:	01 d0                	add    %edx,%eax
80109668:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010966f:	01 d0                	add    %edx,%eax
80109671:	c1 e0 02             	shl    $0x2,%eax
80109674:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109679:	8b 40 0c             	mov    0xc(%eax),%eax
8010967c:	8d 48 01             	lea    0x1(%eax),%ecx
8010967f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109682:	89 d0                	mov    %edx,%eax
80109684:	01 c0                	add    %eax,%eax
80109686:	01 d0                	add    %edx,%eax
80109688:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010968f:	01 d0                	add    %edx,%eax
80109691:	c1 e0 02             	shl    $0x2,%eax
80109694:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109699:	89 48 0c             	mov    %ecx,0xc(%eax)
	}
}
8010969c:	c9                   	leave  
8010969d:	c3                   	ret    

8010969e <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
8010969e:	55                   	push   %ebp
8010969f:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
801096a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801096a4:	89 d0                	mov    %edx,%eax
801096a6:	01 c0                	add    %eax,%eax
801096a8:	01 d0                	add    %edx,%eax
801096aa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096b1:	01 d0                	add    %edx,%eax
801096b3:	c1 e0 02             	shl    $0x2,%eax
801096b6:	05 00 8d 11 80       	add    $0x80118d00,%eax
801096bb:	8b 40 0c             	mov    0xc(%eax),%eax
801096be:	8d 48 ff             	lea    -0x1(%eax),%ecx
801096c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801096c4:	89 d0                	mov    %edx,%eax
801096c6:	01 c0                	add    %eax,%eax
801096c8:	01 d0                	add    %edx,%eax
801096ca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096d1:	01 d0                	add    %edx,%eax
801096d3:	c1 e0 02             	shl    $0x2,%eax
801096d6:	05 00 8d 11 80       	add    $0x80118d00,%eax
801096db:	89 48 0c             	mov    %ecx,0xc(%eax)
}
801096de:	5d                   	pop    %ebp
801096df:	c3                   	ret    

801096e0 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
801096e0:	55                   	push   %ebp
801096e1:	89 e5                	mov    %esp,%ebp
801096e3:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
801096e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801096e9:	89 d0                	mov    %edx,%eax
801096eb:	01 c0                	add    %eax,%eax
801096ed:	01 d0                	add    %edx,%eax
801096ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096f6:	01 d0                	add    %edx,%eax
801096f8:	c1 e0 02             	shl    $0x2,%eax
801096fb:	05 10 8d 11 80       	add    $0x80118d10,%eax
80109700:	8b 50 04             	mov    0x4(%eax),%edx
80109703:	8b 45 08             	mov    0x8(%ebp),%eax
80109706:	01 d0                	add    %edx,%eax
80109708:	85 c0                	test   %eax,%eax
8010970a:	79 05                	jns    80109711 <set_curr_disk+0x31>
8010970c:	05 ff 03 00 00       	add    $0x3ff,%eax
80109711:	c1 f8 0a             	sar    $0xa,%eax
80109714:	89 c1                	mov    %eax,%ecx
80109716:	8b 55 0c             	mov    0xc(%ebp),%edx
80109719:	89 d0                	mov    %edx,%eax
8010971b:	01 c0                	add    %eax,%eax
8010971d:	01 d0                	add    %edx,%eax
8010971f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109726:	01 d0                	add    %edx,%eax
80109728:	c1 e0 02             	shl    $0x2,%eax
8010972b:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109730:	8b 40 08             	mov    0x8(%eax),%eax
80109733:	39 c1                	cmp    %eax,%ecx
80109735:	7e 0e                	jle    80109745 <set_curr_disk+0x65>
		cprintf("Exceded disk resource; killing container");
80109737:	c7 04 24 38 a3 10 80 	movl   $0x8010a338,(%esp)
8010973e:	e8 7e 6c ff ff       	call   801003c1 <cprintf>
80109743:	eb 40                	jmp    80109785 <set_curr_disk+0xa5>
	}
	else{
		containers[vc_num].curr_disk += disk;
80109745:	8b 55 0c             	mov    0xc(%ebp),%edx
80109748:	89 d0                	mov    %edx,%eax
8010974a:	01 c0                	add    %eax,%eax
8010974c:	01 d0                	add    %edx,%eax
8010974e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109755:	01 d0                	add    %edx,%eax
80109757:	c1 e0 02             	shl    $0x2,%eax
8010975a:	05 10 8d 11 80       	add    $0x80118d10,%eax
8010975f:	8b 50 04             	mov    0x4(%eax),%edx
80109762:	8b 45 08             	mov    0x8(%ebp),%eax
80109765:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109768:	8b 55 0c             	mov    0xc(%ebp),%edx
8010976b:	89 d0                	mov    %edx,%eax
8010976d:	01 c0                	add    %eax,%eax
8010976f:	01 d0                	add    %edx,%eax
80109771:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109778:	01 d0                	add    %edx,%eax
8010977a:	c1 e0 02             	shl    $0x2,%eax
8010977d:	05 10 8d 11 80       	add    $0x80118d10,%eax
80109782:	89 48 04             	mov    %ecx,0x4(%eax)
	}
}
80109785:	c9                   	leave  
80109786:	c3                   	ret    

80109787 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80109787:	55                   	push   %ebp
80109788:	89 e5                	mov    %esp,%ebp
8010978a:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
8010978d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109790:	89 d0                	mov    %edx,%eax
80109792:	01 c0                	add    %eax,%eax
80109794:	01 d0                	add    %edx,%eax
80109796:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010979d:	01 d0                	add    %edx,%eax
8010979f:	c1 e0 02             	shl    $0x2,%eax
801097a2:	05 10 8d 11 80       	add    $0x80118d10,%eax
801097a7:	8b 10                	mov    (%eax),%edx
801097a9:	8b 45 08             	mov    0x8(%ebp),%eax
801097ac:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801097af:	8b 55 0c             	mov    0xc(%ebp),%edx
801097b2:	89 d0                	mov    %edx,%eax
801097b4:	01 c0                	add    %eax,%eax
801097b6:	01 d0                	add    %edx,%eax
801097b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097bf:	01 d0                	add    %edx,%eax
801097c1:	c1 e0 02             	shl    $0x2,%eax
801097c4:	05 00 8d 11 80       	add    $0x80118d00,%eax
801097c9:	8b 40 04             	mov    0x4(%eax),%eax
801097cc:	39 c1                	cmp    %eax,%ecx
801097ce:	7e 0e                	jle    801097de <set_curr_proc+0x57>
		cprintf("Exceded procs resource; killing container");
801097d0:	c7 04 24 64 a3 10 80 	movl   $0x8010a364,(%esp)
801097d7:	e8 e5 6b ff ff       	call   801003c1 <cprintf>
801097dc:	eb 3e                	jmp    8010981c <set_curr_proc+0x95>
	}
	else{
		containers[vc_num].curr_proc += procs;
801097de:	8b 55 0c             	mov    0xc(%ebp),%edx
801097e1:	89 d0                	mov    %edx,%eax
801097e3:	01 c0                	add    %eax,%eax
801097e5:	01 d0                	add    %edx,%eax
801097e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097ee:	01 d0                	add    %edx,%eax
801097f0:	c1 e0 02             	shl    $0x2,%eax
801097f3:	05 10 8d 11 80       	add    $0x80118d10,%eax
801097f8:	8b 10                	mov    (%eax),%edx
801097fa:	8b 45 08             	mov    0x8(%ebp),%eax
801097fd:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109800:	8b 55 0c             	mov    0xc(%ebp),%edx
80109803:	89 d0                	mov    %edx,%eax
80109805:	01 c0                	add    %eax,%eax
80109807:	01 d0                	add    %edx,%eax
80109809:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109810:	01 d0                	add    %edx,%eax
80109812:	c1 e0 02             	shl    $0x2,%eax
80109815:	05 10 8d 11 80       	add    $0x80118d10,%eax
8010981a:	89 08                	mov    %ecx,(%eax)
	}
}
8010981c:	c9                   	leave  
8010981d:	c3                   	ret    

8010981e <max_containers>:

int max_containers(){
8010981e:	55                   	push   %ebp
8010981f:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
80109821:	b8 04 00 00 00       	mov    $0x4,%eax
}
80109826:	5d                   	pop    %ebp
80109827:	c3                   	ret    

80109828 <container_init>:

void container_init(){
80109828:	55                   	push   %ebp
80109829:	89 e5                	mov    %esp,%ebp
8010982b:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010982e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109835:	e9 f7 00 00 00       	jmp    80109931 <container_init+0x109>
		strcpy(containers[i].name, "");
8010983a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010983d:	89 d0                	mov    %edx,%eax
8010983f:	01 c0                	add    %eax,%eax
80109841:	01 d0                	add    %edx,%eax
80109843:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010984a:	01 d0                	add    %edx,%eax
8010984c:	c1 e0 02             	shl    $0x2,%eax
8010984f:	83 c0 10             	add    $0x10,%eax
80109852:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109857:	83 c0 08             	add    $0x8,%eax
8010985a:	c7 44 24 04 08 a3 10 	movl   $0x8010a308,0x4(%esp)
80109861:	80 
80109862:	89 04 24             	mov    %eax,(%esp)
80109865:	e8 ff f8 ff ff       	call   80109169 <strcpy>
		containers[i].max_proc = 6;
8010986a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010986d:	89 d0                	mov    %edx,%eax
8010986f:	01 c0                	add    %eax,%eax
80109871:	01 d0                	add    %edx,%eax
80109873:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010987a:	01 d0                	add    %edx,%eax
8010987c:	c1 e0 02             	shl    $0x2,%eax
8010987f:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109884:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
		containers[i].max_disk = 100;
8010988b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010988e:	89 d0                	mov    %edx,%eax
80109890:	01 c0                	add    %eax,%eax
80109892:	01 d0                	add    %edx,%eax
80109894:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010989b:	01 d0                	add    %edx,%eax
8010989d:	c1 e0 02             	shl    $0x2,%eax
801098a0:	05 00 8d 11 80       	add    $0x80118d00,%eax
801098a5:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 1000;
801098ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
801098af:	89 d0                	mov    %edx,%eax
801098b1:	01 c0                	add    %eax,%eax
801098b3:	01 d0                	add    %edx,%eax
801098b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098bc:	01 d0                	add    %edx,%eax
801098be:	c1 e0 02             	shl    $0x2,%eax
801098c1:	05 00 8d 11 80       	add    $0x80118d00,%eax
801098c6:	c7 00 e8 03 00 00    	movl   $0x3e8,(%eax)
		containers[i].curr_proc = 1;
801098cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801098cf:	89 d0                	mov    %edx,%eax
801098d1:	01 c0                	add    %eax,%eax
801098d3:	01 d0                	add    %edx,%eax
801098d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098dc:	01 d0                	add    %edx,%eax
801098de:	c1 e0 02             	shl    $0x2,%eax
801098e1:	05 10 8d 11 80       	add    $0x80118d10,%eax
801098e6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
801098ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
801098ef:	89 d0                	mov    %edx,%eax
801098f1:	01 c0                	add    %eax,%eax
801098f3:	01 d0                	add    %edx,%eax
801098f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098fc:	01 d0                	add    %edx,%eax
801098fe:	c1 e0 02             	shl    $0x2,%eax
80109901:	05 10 8d 11 80       	add    $0x80118d10,%eax
80109906:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
8010990d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109910:	89 d0                	mov    %edx,%eax
80109912:	01 c0                	add    %eax,%eax
80109914:	01 d0                	add    %edx,%eax
80109916:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010991d:	01 d0                	add    %edx,%eax
8010991f:	c1 e0 02             	shl    $0x2,%eax
80109922:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109927:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010992e:	ff 45 fc             	incl   -0x4(%ebp)
80109931:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109935:	0f 8e ff fe ff ff    	jle    8010983a <container_init+0x12>
		containers[i].max_mem = 1000;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
8010993b:	c9                   	leave  
8010993c:	c3                   	ret    

8010993d <container_reset>:

void container_reset(int vc_num){
8010993d:	55                   	push   %ebp
8010993e:	89 e5                	mov    %esp,%ebp
80109940:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
80109943:	8b 55 08             	mov    0x8(%ebp),%edx
80109946:	89 d0                	mov    %edx,%eax
80109948:	01 c0                	add    %eax,%eax
8010994a:	01 d0                	add    %edx,%eax
8010994c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109953:	01 d0                	add    %edx,%eax
80109955:	c1 e0 02             	shl    $0x2,%eax
80109958:	83 c0 10             	add    $0x10,%eax
8010995b:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109960:	83 c0 08             	add    $0x8,%eax
80109963:	c7 44 24 04 08 a3 10 	movl   $0x8010a308,0x4(%esp)
8010996a:	80 
8010996b:	89 04 24             	mov    %eax,(%esp)
8010996e:	e8 f6 f7 ff ff       	call   80109169 <strcpy>
	containers[vc_num].max_proc = 6;
80109973:	8b 55 08             	mov    0x8(%ebp),%edx
80109976:	89 d0                	mov    %edx,%eax
80109978:	01 c0                	add    %eax,%eax
8010997a:	01 d0                	add    %edx,%eax
8010997c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109983:	01 d0                	add    %edx,%eax
80109985:	c1 e0 02             	shl    $0x2,%eax
80109988:	05 00 8d 11 80       	add    $0x80118d00,%eax
8010998d:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
	containers[vc_num].max_disk = 100;
80109994:	8b 55 08             	mov    0x8(%ebp),%edx
80109997:	89 d0                	mov    %edx,%eax
80109999:	01 c0                	add    %eax,%eax
8010999b:	01 d0                	add    %edx,%eax
8010999d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099a4:	01 d0                	add    %edx,%eax
801099a6:	c1 e0 02             	shl    $0x2,%eax
801099a9:	05 00 8d 11 80       	add    $0x80118d00,%eax
801099ae:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 300;
801099b5:	8b 55 08             	mov    0x8(%ebp),%edx
801099b8:	89 d0                	mov    %edx,%eax
801099ba:	01 c0                	add    %eax,%eax
801099bc:	01 d0                	add    %edx,%eax
801099be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099c5:	01 d0                	add    %edx,%eax
801099c7:	c1 e0 02             	shl    $0x2,%eax
801099ca:	05 00 8d 11 80       	add    $0x80118d00,%eax
801099cf:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
	containers[vc_num].curr_proc = 1;
801099d5:	8b 55 08             	mov    0x8(%ebp),%edx
801099d8:	89 d0                	mov    %edx,%eax
801099da:	01 c0                	add    %eax,%eax
801099dc:	01 d0                	add    %edx,%eax
801099de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099e5:	01 d0                	add    %edx,%eax
801099e7:	c1 e0 02             	shl    $0x2,%eax
801099ea:	05 10 8d 11 80       	add    $0x80118d10,%eax
801099ef:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	containers[vc_num].curr_disk = 0;
801099f5:	8b 55 08             	mov    0x8(%ebp),%edx
801099f8:	89 d0                	mov    %edx,%eax
801099fa:	01 c0                	add    %eax,%eax
801099fc:	01 d0                	add    %edx,%eax
801099fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109a05:	01 d0                	add    %edx,%eax
80109a07:	c1 e0 02             	shl    $0x2,%eax
80109a0a:	05 10 8d 11 80       	add    $0x80118d10,%eax
80109a0f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
80109a16:	8b 55 08             	mov    0x8(%ebp),%edx
80109a19:	89 d0                	mov    %edx,%eax
80109a1b:	01 c0                	add    %eax,%eax
80109a1d:	01 d0                	add    %edx,%eax
80109a1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109a26:	01 d0                	add    %edx,%eax
80109a28:	c1 e0 02             	shl    $0x2,%eax
80109a2b:	05 00 8d 11 80       	add    $0x80118d00,%eax
80109a30:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
80109a37:	c9                   	leave  
80109a38:	c3                   	ret    
