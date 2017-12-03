
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
8010003a:	c7 44 24 04 4c 99 10 	movl   $0x8010994c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100049:	e8 cc 54 00 00       	call   8010551a <initlock>

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
80100087:	c7 44 24 04 53 99 10 	movl   $0x80109953,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 45 53 00 00       	call   801053dc <initsleeplock>
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
801000c9:	e8 6d 54 00 00       	call   8010553b <acquire>

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
80100104:	e8 9c 54 00 00       	call   801055a5 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 ff 52 00 00       	call   80105416 <acquiresleep>
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
8010017d:	e8 23 54 00 00       	call   801055a5 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 86 52 00 00       	call   80105416 <acquiresleep>
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
801001a7:	c7 04 24 5a 99 10 80 	movl   $0x8010995a,(%esp)
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
801001e2:	e8 5e 29 00 00       	call   80102b45 <iderw>
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
801001fb:	e8 b3 52 00 00       	call   801054b3 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 6b 99 10 80 	movl   $0x8010996b,(%esp)
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
80100225:	e8 1b 29 00 00       	call   80102b45 <iderw>
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
8010023b:	e8 73 52 00 00       	call   801054b3 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 72 99 10 80 	movl   $0x80109972,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 13 52 00 00       	call   80105471 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100265:	e8 d1 52 00 00       	call   8010553b <acquire>
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
801002d1:	e8 cf 52 00 00       	call   801055a5 <release>
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
801003dc:	e8 5a 51 00 00       	call   8010553b <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 79 99 10 80 	movl   $0x80109979,(%esp)
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
801004cf:	c7 45 ec 82 99 10 80 	movl   $0x80109982,-0x14(%ebp)
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
8010054d:	e8 53 50 00 00       	call   801055a5 <release>
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
80100572:	c7 04 24 89 99 10 80 	movl   $0x80109989,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 9d 99 10 80 	movl   $0x8010999d,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 4b 50 00 00       	call   801055f2 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 9f 99 10 80 	movl   $0x8010999f,(%esp)
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
80100695:	c7 04 24 a3 99 10 80 	movl   $0x801099a3,(%esp)
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
801006c9:	e8 99 51 00 00       	call   80105867 <memmove>
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
801006f8:	e8 a1 50 00 00       	call   8010579e <memset>
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
8010078e:	e8 ad 70 00 00       	call   80107840 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 a1 70 00 00       	call   80107840 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 95 70 00 00       	call   80107840 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 88 70 00 00       	call   80107840 <uartputc>
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
80100813:	e8 23 4d 00 00       	call   8010553b <acquire>
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
80100a00:	e8 de 44 00 00       	call   80104ee3 <wakeup>
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
80100a21:	e8 7f 4b 00 00       	call   801055a5 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 b6 99 10 80 	movl   $0x801099b6,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 4c 45 00 00       	call   80104f89 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 ce 99 10 80 	movl   $0x801099ce,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 e8 99 10 80 	movl   $0x801099e8,(%esp)
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
80100a8a:	e8 ac 4a 00 00       	call   8010553b <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 c0 3a 00 00       	call   8010455b <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100aa9:	e8 f7 4a 00 00       	call   801055a5 <release>
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
80100ad2:	e8 35 43 00 00       	call   80104e0c <sleep>

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
80100b5c:	e8 44 4a 00 00       	call   801055a5 <release>
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
80100ba2:	e8 94 49 00 00       	call   8010553b <acquire>
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
80100bda:	e8 c6 49 00 00       	call   801055a5 <release>
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
80100bf5:	c7 44 24 04 01 9a 10 	movl   $0x80109a01,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100c04:	e8 11 49 00 00       	call   8010551a <initlock>

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
80100c36:	e8 bc 20 00 00       	call   80102cf7 <ioapicenable>
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
80100c49:	e8 0d 39 00 00       	call   8010455b <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 dd 2b 00 00       	call   80103833 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 f7 1a 00 00       	call   80102758 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 46 2c 00 00       	call   801038b5 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 09 9a 10 80 	movl   $0x80109a09,(%esp)
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
80100cd8:	e8 45 7b 00 00       	call   80108822 <setupkvm>
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
80100d96:	e8 53 7e 00 00       	call   80108bee <allocuvm>
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
80100de8:	e8 1e 7d 00 00       	call   80108b0b <loaduvm>
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
80100e54:	e8 95 7d 00 00       	call   80108bee <allocuvm>
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
80100e79:	e8 e0 7f 00 00       	call   80108e5e <clearpteu>
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
80100eaf:	e8 3d 4b 00 00       	call   801059f1 <strlen>
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
80100ed6:	e8 16 4b 00 00       	call   801059f1 <strlen>
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
80100f04:	e8 0d 81 00 00       	call   80109016 <copyout>
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
80100fa8:	e8 69 80 00 00       	call   80109016 <copyout>
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
80100ff8:	e8 ad 49 00 00       	call   801059aa <safestrcpy>

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
80101038:	e8 bf 78 00 00       	call   801088fc <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 80 7d 00 00       	call   80108dc8 <freevm>
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
8010105b:	e8 68 7d 00 00       	call   80108dc8 <freevm>
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
801010ec:	c7 44 24 04 15 9a 10 	movl   $0x80109a15,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801010fb:	e8 1a 44 00 00       	call   8010551a <initlock>
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
8010110f:	e8 27 44 00 00       	call   8010553b <acquire>
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
80101138:	e8 68 44 00 00       	call   801055a5 <release>
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
80101156:	e8 4a 44 00 00       	call   801055a5 <release>
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
8010116f:	e8 c7 43 00 00       	call   8010553b <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 1c 9a 10 80 	movl   $0x80109a1c,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011a0:	e8 00 44 00 00       	call   801055a5 <release>
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
801011ba:	e8 7c 43 00 00       	call   8010553b <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 24 9a 10 80 	movl   $0x80109a24,(%esp)
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
801011f5:	e8 ab 43 00 00       	call   801055a5 <release>
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
8010122b:	e8 75 43 00 00       	call   801055a5 <release>

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
80101248:	e8 a6 2f 00 00       	call   801041f3 <pipeclose>
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
801012fe:	e8 6e 30 00 00       	call   80104371 <piperead>
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
80101370:	c7 04 24 2e 9a 10 80 	movl   $0x80109a2e,(%esp)
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
801013ba:	e8 c6 2e 00 00       	call   80104285 <pipewrite>
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
8010147b:	c7 04 24 37 9a 10 80 	movl   $0x80109a37,(%esp)
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
801014ad:	c7 04 24 47 9a 10 80 	movl   $0x80109a47,(%esp)
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
801014f4:	e8 6e 43 00 00       	call   80105867 <memmove>
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
8010153a:	e8 5f 42 00 00       	call   8010579e <memset>
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
80101683:	c7 04 24 54 9a 10 80 	movl   $0x80109a54,(%esp)
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
80101713:	c7 04 24 6a 9a 10 80 	movl   $0x80109a6a,(%esp)
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
8010176b:	c7 44 24 04 7d 9a 10 	movl   $0x80109a7d,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
8010177a:	e8 9b 3d 00 00       	call   8010551a <initlock>
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
801017a0:	c7 44 24 04 84 9a 10 	movl   $0x80109a84,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 2c 3c 00 00       	call   801053dc <initsleeplock>
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
80101819:	c7 04 24 8c 9a 10 80 	movl   $0x80109a8c,(%esp)
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
8010189b:	e8 fe 3e 00 00       	call   8010579e <memset>
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
801018f1:	c7 04 24 df 9a 10 80 	movl   $0x80109adf,(%esp)
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
8010199e:	e8 c4 3e 00 00       	call   80105867 <memmove>
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
801019c8:	e8 6e 3b 00 00       	call   8010553b <acquire>

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
80101a12:	e8 8e 3b 00 00       	call   801055a5 <release>
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
80101a48:	c7 04 24 f1 9a 10 80 	movl   $0x80109af1,(%esp)
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
80101a86:	e8 1a 3b 00 00       	call   801055a5 <release>

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
80101a9d:	e8 99 3a 00 00       	call   8010553b <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101ab8:	e8 e8 3a 00 00       	call   801055a5 <release>
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
80101ad8:	c7 04 24 01 9b 10 80 	movl   $0x80109b01,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 24 39 00 00       	call   80105416 <acquiresleep>

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
80101b99:	e8 c9 3c 00 00       	call   80105867 <memmove>
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
80101bbe:	c7 04 24 07 9b 10 80 	movl   $0x80109b07,(%esp)
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
80101be1:	e8 cd 38 00 00       	call   801054b3 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 16 9b 10 80 	movl   $0x80109b16,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 63 38 00 00       	call   80105471 <releasesleep>
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
80101c1f:	e8 f2 37 00 00       	call   80105416 <acquiresleep>
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
80101c41:	e8 f5 38 00 00       	call   8010553b <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c56:	e8 4a 39 00 00       	call   801055a5 <release>
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
80101c93:	e8 d9 37 00 00       	call   80105471 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c9f:	e8 97 38 00 00       	call   8010553b <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101cba:	e8 e6 38 00 00       	call   801055a5 <release>
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
80101de0:	c7 04 24 1e 9b 10 80 	movl   $0x80109b1e,(%esp)
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
8010208a:	e8 d8 37 00 00       	call   80105867 <memmove>
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
801020c3:	e8 93 24 00 00       	call   8010455b <myproc>
801020c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	83 c0 18             	add    $0x18,%eax
801020d7:	89 04 24             	mov    %eax,(%esp)
801020da:	e8 7c 71 00 00       	call   8010925b <find>
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
8010210f:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
80102116:	85 c0                	test   %eax,%eax
80102118:	75 16                	jne    80102130 <writei+0x73>
      cprintf("hello1");
8010211a:	c7 04 24 31 9b 10 80 	movl   $0x80109b31,(%esp)
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
80102138:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
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
8010218b:	c7 04 24 38 9b 10 80 	movl   $0x80109b38,(%esp)
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
80102220:	e8 42 36 00 00       	call   80105867 <memmove>
    log_write(bp);
80102225:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102228:	89 04 24             	mov    %eax,(%esp)
8010222b:	e8 07 18 00 00       	call   80103a37 <log_write>
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
80102266:	c7 04 24 3f 9b 10 80 	movl   $0x80109b3f,(%esp)
8010226d:	e8 4f e1 ff ff       	call   801003c1 <cprintf>
    if(tot == 1){
80102272:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102276:	75 13                	jne    8010228b <writei+0x1ce>
      set_curr_disk(1, x);
80102278:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102286:	e8 65 73 00 00       	call   801095f0 <set_curr_disk>
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
801022d0:	e8 31 36 00 00       	call   80105906 <strncmp>
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
801022e9:	c7 04 24 43 9b 10 80 	movl   $0x80109b43,(%esp)
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
80102327:	c7 04 24 55 9b 10 80 	movl   $0x80109b55,(%esp)
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
8010240a:	c7 04 24 64 9b 10 80 	movl   $0x80109b64,(%esp)
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
8010244e:	e8 01 35 00 00       	call   80105954 <strncpy>
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
80102480:	c7 04 24 71 9b 10 80 	movl   $0x80109b71,(%esp)
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
801024ff:	e8 63 33 00 00       	call   80105867 <memmove>
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
8010251a:	e8 48 33 00 00       	call   80105867 <memmove>
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
8010259d:	e8 b9 1f 00 00       	call   8010455b <myproc>
801025a2:	8b 40 68             	mov    0x68(%eax),%eax
801025a5:	89 04 24             	mov    %eax,(%esp)
801025a8:	e8 e3 f4 ff ff       	call   80101a90 <idup>
801025ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
801025b0:	e8 a6 1f 00 00       	call   8010455b <myproc>
801025b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
801025b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
801025bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801025c3:	74 0c                	je     801025d1 <namex+0x5c>
    cont = p->cont;
801025c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801025ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
801025d1:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
801025d8:	00 
801025d9:	c7 44 24 04 79 9b 10 	movl   $0x80109b79,0x4(%esp)
801025e0:	80 
801025e1:	8b 45 08             	mov    0x8(%ebp),%eax
801025e4:	89 04 24             	mov    %eax,(%esp)
801025e7:	e8 1a 33 00 00       	call   80105906 <strncmp>
801025ec:	85 c0                	test   %eax,%eax
801025ee:	75 21                	jne    80102611 <namex+0x9c>
801025f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025f4:	74 1b                	je     80102611 <namex+0x9c>
801025f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025f9:	8b 40 38             	mov    0x38(%eax),%eax
801025fc:	8b 50 04             	mov    0x4(%eax),%edx
801025ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102602:	8b 40 04             	mov    0x4(%eax),%eax
80102605:	39 c2                	cmp    %eax,%edx
80102607:	75 08                	jne    80102611 <namex+0x9c>
    return ip;
80102609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010260c:	e9 45 01 00 00       	jmp    80102756 <namex+0x1e1>
  }
  
  while((path = skipelem(path, name)) != 0){
80102611:	e9 06 01 00 00       	jmp    8010271c <namex+0x1a7>
    ilock(ip);
80102616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102619:	89 04 24             	mov    %eax,(%esp)
8010261c:	e8 a1 f4 ff ff       	call   80101ac2 <ilock>

    if(ip->type != T_DIR){
80102621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102624:	8b 40 50             	mov    0x50(%eax),%eax
80102627:	66 83 f8 01          	cmp    $0x1,%ax
8010262b:	74 15                	je     80102642 <namex+0xcd>
      iunlockput(ip);
8010262d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102630:	89 04 24             	mov    %eax,(%esp)
80102633:	e8 89 f6 ff ff       	call   80101cc1 <iunlockput>
      return 0;
80102638:	b8 00 00 00 00       	mov    $0x0,%eax
8010263d:	e9 14 01 00 00       	jmp    80102756 <namex+0x1e1>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
80102642:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
80102649:	00 
8010264a:	c7 44 24 04 79 9b 10 	movl   $0x80109b79,0x4(%esp)
80102651:	80 
80102652:	8b 45 08             	mov    0x8(%ebp),%eax
80102655:	89 04 24             	mov    %eax,(%esp)
80102658:	e8 a9 32 00 00       	call   80105906 <strncmp>
8010265d:	85 c0                	test   %eax,%eax
8010265f:	75 2c                	jne    8010268d <namex+0x118>
80102661:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102665:	74 26                	je     8010268d <namex+0x118>
80102667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010266a:	8b 40 38             	mov    0x38(%eax),%eax
8010266d:	8b 50 04             	mov    0x4(%eax),%edx
80102670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102673:	8b 40 04             	mov    0x4(%eax),%eax
80102676:	39 c2                	cmp    %eax,%edx
80102678:	75 13                	jne    8010268d <namex+0x118>
      iunlock(ip);
8010267a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010267d:	89 04 24             	mov    %eax,(%esp)
80102680:	e8 47 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
80102685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102688:	e9 c9 00 00 00       	jmp    80102756 <namex+0x1e1>
    }

    if(cont != NULL && ip->inum == ROOTINO){
8010268d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102691:	74 21                	je     801026b4 <namex+0x13f>
80102693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102696:	8b 40 04             	mov    0x4(%eax),%eax
80102699:	83 f8 01             	cmp    $0x1,%eax
8010269c:	75 16                	jne    801026b4 <namex+0x13f>
      iunlock(ip);
8010269e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a1:	89 04 24             	mov    %eax,(%esp)
801026a4:	e8 23 f5 ff ff       	call   80101bcc <iunlock>
      return cont->root;
801026a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026ac:	8b 40 38             	mov    0x38(%eax),%eax
801026af:	e9 a2 00 00 00       	jmp    80102756 <namex+0x1e1>
    }

    if(nameiparent && *path == '\0'){
801026b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026b8:	74 1c                	je     801026d6 <namex+0x161>
801026ba:	8b 45 08             	mov    0x8(%ebp),%eax
801026bd:	8a 00                	mov    (%eax),%al
801026bf:	84 c0                	test   %al,%al
801026c1:	75 13                	jne    801026d6 <namex+0x161>
      // Stop one level early.
      iunlock(ip);
801026c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c6:	89 04 24             	mov    %eax,(%esp)
801026c9:	e8 fe f4 ff ff       	call   80101bcc <iunlock>
      return ip;
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	e9 80 00 00 00       	jmp    80102756 <namex+0x1e1>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026dd:	00 
801026de:	8b 45 10             	mov    0x10(%ebp),%eax
801026e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e8:	89 04 24             	mov    %eax,(%esp)
801026eb:	e8 e7 fb ff ff       	call   801022d7 <dirlookup>
801026f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801026f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801026f7:	75 12                	jne    8010270b <namex+0x196>
      iunlockput(ip);
801026f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026fc:	89 04 24             	mov    %eax,(%esp)
801026ff:	e8 bd f5 ff ff       	call   80101cc1 <iunlockput>
      return 0;
80102704:	b8 00 00 00 00       	mov    $0x0,%eax
80102709:	eb 4b                	jmp    80102756 <namex+0x1e1>
    }
    iunlockput(ip);
8010270b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270e:	89 04 24             	mov    %eax,(%esp)
80102711:	e8 ab f5 ff ff       	call   80101cc1 <iunlockput>

    ip = next;
80102716:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102719:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
    return ip;
  }
  
  while((path = skipelem(path, name)) != 0){
8010271c:	8b 45 10             	mov    0x10(%ebp),%eax
8010271f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102723:	8b 45 08             	mov    0x8(%ebp),%eax
80102726:	89 04 24             	mov    %eax,(%esp)
80102729:	e8 65 fd ff ff       	call   80102493 <skipelem>
8010272e:	89 45 08             	mov    %eax,0x8(%ebp)
80102731:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102735:	0f 85 db fe ff ff    	jne    80102616 <namex+0xa1>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
8010273b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010273f:	74 12                	je     80102753 <namex+0x1de>
    iput(ip);
80102741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102744:	89 04 24             	mov    %eax,(%esp)
80102747:	e8 c4 f4 ff ff       	call   80101c10 <iput>
    return 0;
8010274c:	b8 00 00 00 00       	mov    $0x0,%eax
80102751:	eb 03                	jmp    80102756 <namex+0x1e1>
  }

  
  return ip;
80102753:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102756:	c9                   	leave  
80102757:	c3                   	ret    

80102758 <namei>:

struct inode*
namei(char *path)
{
80102758:	55                   	push   %ebp
80102759:	89 e5                	mov    %esp,%ebp
8010275b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010275e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102761:	89 44 24 08          	mov    %eax,0x8(%esp)
80102765:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010276c:	00 
8010276d:	8b 45 08             	mov    0x8(%ebp),%eax
80102770:	89 04 24             	mov    %eax,(%esp)
80102773:	e8 fd fd ff ff       	call   80102575 <namex>
}
80102778:	c9                   	leave  
80102779:	c3                   	ret    

8010277a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010277a:	55                   	push   %ebp
8010277b:	89 e5                	mov    %esp,%ebp
8010277d:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102780:	8b 45 0c             	mov    0xc(%ebp),%eax
80102783:	89 44 24 08          	mov    %eax,0x8(%esp)
80102787:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010278e:	00 
8010278f:	8b 45 08             	mov    0x8(%ebp),%eax
80102792:	89 04 24             	mov    %eax,(%esp)
80102795:	e8 db fd ff ff       	call   80102575 <namex>
}
8010279a:	c9                   	leave  
8010279b:	c3                   	ret    

8010279c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010279c:	55                   	push   %ebp
8010279d:	89 e5                	mov    %esp,%ebp
8010279f:	83 ec 14             	sub    $0x14,%esp
801027a2:	8b 45 08             	mov    0x8(%ebp),%eax
801027a5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027ac:	89 c2                	mov    %eax,%edx
801027ae:	ec                   	in     (%dx),%al
801027af:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027b2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801027b5:	c9                   	leave  
801027b6:	c3                   	ret    

801027b7 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027b7:	55                   	push   %ebp
801027b8:	89 e5                	mov    %esp,%ebp
801027ba:	57                   	push   %edi
801027bb:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027bc:	8b 55 08             	mov    0x8(%ebp),%edx
801027bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027c2:	8b 45 10             	mov    0x10(%ebp),%eax
801027c5:	89 cb                	mov    %ecx,%ebx
801027c7:	89 df                	mov    %ebx,%edi
801027c9:	89 c1                	mov    %eax,%ecx
801027cb:	fc                   	cld    
801027cc:	f3 6d                	rep insl (%dx),%es:(%edi)
801027ce:	89 c8                	mov    %ecx,%eax
801027d0:	89 fb                	mov    %edi,%ebx
801027d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027d5:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027d8:	5b                   	pop    %ebx
801027d9:	5f                   	pop    %edi
801027da:	5d                   	pop    %ebp
801027db:	c3                   	ret    

801027dc <outb>:

static inline void
outb(ushort port, uchar data)
{
801027dc:	55                   	push   %ebp
801027dd:	89 e5                	mov    %esp,%ebp
801027df:	83 ec 08             	sub    $0x8,%esp
801027e2:	8b 45 08             	mov    0x8(%ebp),%eax
801027e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801027e8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801027ec:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027ef:	8a 45 f8             	mov    -0x8(%ebp),%al
801027f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801027f5:	ee                   	out    %al,(%dx)
}
801027f6:	c9                   	leave  
801027f7:	c3                   	ret    

801027f8 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	56                   	push   %esi
801027fc:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027fd:	8b 55 08             	mov    0x8(%ebp),%edx
80102800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102803:	8b 45 10             	mov    0x10(%ebp),%eax
80102806:	89 cb                	mov    %ecx,%ebx
80102808:	89 de                	mov    %ebx,%esi
8010280a:	89 c1                	mov    %eax,%ecx
8010280c:	fc                   	cld    
8010280d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010280f:	89 c8                	mov    %ecx,%eax
80102811:	89 f3                	mov    %esi,%ebx
80102813:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102816:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102819:	5b                   	pop    %ebx
8010281a:	5e                   	pop    %esi
8010281b:	5d                   	pop    %ebp
8010281c:	c3                   	ret    

8010281d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010281d:	55                   	push   %ebp
8010281e:	89 e5                	mov    %esp,%ebp
80102820:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102823:	90                   	nop
80102824:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010282b:	e8 6c ff ff ff       	call   8010279c <inb>
80102830:	0f b6 c0             	movzbl %al,%eax
80102833:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102836:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102839:	25 c0 00 00 00       	and    $0xc0,%eax
8010283e:	83 f8 40             	cmp    $0x40,%eax
80102841:	75 e1                	jne    80102824 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102843:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102847:	74 11                	je     8010285a <idewait+0x3d>
80102849:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010284c:	83 e0 21             	and    $0x21,%eax
8010284f:	85 c0                	test   %eax,%eax
80102851:	74 07                	je     8010285a <idewait+0x3d>
    return -1;
80102853:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102858:	eb 05                	jmp    8010285f <idewait+0x42>
  return 0;
8010285a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010285f:	c9                   	leave  
80102860:	c3                   	ret    

80102861 <ideinit>:

void
ideinit(void)
{
80102861:	55                   	push   %ebp
80102862:	89 e5                	mov    %esp,%ebp
80102864:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102867:	c7 44 24 04 7c 9b 10 	movl   $0x80109b7c,0x4(%esp)
8010286e:	80 
8010286f:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102876:	e8 9f 2c 00 00       	call   8010551a <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010287b:	a1 40 62 11 80       	mov    0x80116240,%eax
80102880:	48                   	dec    %eax
80102881:	89 44 24 04          	mov    %eax,0x4(%esp)
80102885:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010288c:	e8 66 04 00 00       	call   80102cf7 <ioapicenable>
  idewait(0);
80102891:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102898:	e8 80 ff ff ff       	call   8010281d <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010289d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028a4:	00 
801028a5:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028ac:	e8 2b ff ff ff       	call   801027dc <outb>
  for(i=0; i<1000; i++){
801028b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028b8:	eb 1f                	jmp    801028d9 <ideinit+0x78>
    if(inb(0x1f7) != 0){
801028ba:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028c1:	e8 d6 fe ff ff       	call   8010279c <inb>
801028c6:	84 c0                	test   %al,%al
801028c8:	74 0c                	je     801028d6 <ideinit+0x75>
      havedisk1 = 1;
801028ca:	c7 05 18 d9 10 80 01 	movl   $0x1,0x8010d918
801028d1:	00 00 00 
      break;
801028d4:	eb 0c                	jmp    801028e2 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028d6:	ff 45 f4             	incl   -0xc(%ebp)
801028d9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028e0:	7e d8                	jle    801028ba <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028e2:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028e9:	00 
801028ea:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028f1:	e8 e6 fe ff ff       	call   801027dc <outb>
}
801028f6:	c9                   	leave  
801028f7:	c3                   	ret    

801028f8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028f8:	55                   	push   %ebp
801028f9:	89 e5                	mov    %esp,%ebp
801028fb:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801028fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102902:	75 0c                	jne    80102910 <idestart+0x18>
    panic("idestart");
80102904:	c7 04 24 80 9b 10 80 	movl   $0x80109b80,(%esp)
8010290b:	e8 44 dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102910:	8b 45 08             	mov    0x8(%ebp),%eax
80102913:	8b 40 08             	mov    0x8(%eax),%eax
80102916:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
8010291b:	76 0c                	jbe    80102929 <idestart+0x31>
    panic("incorrect blockno");
8010291d:	c7 04 24 89 9b 10 80 	movl   $0x80109b89,(%esp)
80102924:	e8 2b dc ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102929:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102930:	8b 45 08             	mov    0x8(%ebp),%eax
80102933:	8b 50 08             	mov    0x8(%eax),%edx
80102936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102939:	0f af c2             	imul   %edx,%eax
8010293c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010293f:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102943:	75 07                	jne    8010294c <idestart+0x54>
80102945:	b8 20 00 00 00       	mov    $0x20,%eax
8010294a:	eb 05                	jmp    80102951 <idestart+0x59>
8010294c:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102951:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102954:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102958:	75 07                	jne    80102961 <idestart+0x69>
8010295a:	b8 30 00 00 00       	mov    $0x30,%eax
8010295f:	eb 05                	jmp    80102966 <idestart+0x6e>
80102961:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102966:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102969:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010296d:	7e 0c                	jle    8010297b <idestart+0x83>
8010296f:	c7 04 24 80 9b 10 80 	movl   $0x80109b80,(%esp)
80102976:	e8 d9 db ff ff       	call   80100554 <panic>

  idewait(0);
8010297b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102982:	e8 96 fe ff ff       	call   8010281d <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102987:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010298e:	00 
8010298f:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102996:	e8 41 fe ff ff       	call   801027dc <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010299b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299e:	0f b6 c0             	movzbl %al,%eax
801029a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a5:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801029ac:	e8 2b fe ff ff       	call   801027dc <outb>
  outb(0x1f3, sector & 0xff);
801029b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029b4:	0f b6 c0             	movzbl %al,%eax
801029b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801029bb:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801029c2:	e8 15 fe ff ff       	call   801027dc <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801029c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029ca:	c1 f8 08             	sar    $0x8,%eax
801029cd:	0f b6 c0             	movzbl %al,%eax
801029d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029d4:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029db:	e8 fc fd ff ff       	call   801027dc <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801029e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029e3:	c1 f8 10             	sar    $0x10,%eax
801029e6:	0f b6 c0             	movzbl %al,%eax
801029e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ed:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029f4:	e8 e3 fd ff ff       	call   801027dc <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	8b 40 04             	mov    0x4(%eax),%eax
801029ff:	83 e0 01             	and    $0x1,%eax
80102a02:	c1 e0 04             	shl    $0x4,%eax
80102a05:	88 c2                	mov    %al,%dl
80102a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a0a:	c1 f8 18             	sar    $0x18,%eax
80102a0d:	83 e0 0f             	and    $0xf,%eax
80102a10:	09 d0                	or     %edx,%eax
80102a12:	83 c8 e0             	or     $0xffffffe0,%eax
80102a15:	0f b6 c0             	movzbl %al,%eax
80102a18:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a1c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102a23:	e8 b4 fd ff ff       	call   801027dc <outb>
  if(b->flags & B_DIRTY){
80102a28:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2b:	8b 00                	mov    (%eax),%eax
80102a2d:	83 e0 04             	and    $0x4,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 36                	je     80102a6a <idestart+0x172>
    outb(0x1f7, write_cmd);
80102a34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a37:	0f b6 c0             	movzbl %al,%eax
80102a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a3e:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a45:	e8 92 fd ff ff       	call   801027dc <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a4d:	83 c0 5c             	add    $0x5c,%eax
80102a50:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a57:	00 
80102a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a5c:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a63:	e8 90 fd ff ff       	call   801027f8 <outsl>
80102a68:	eb 16                	jmp    80102a80 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102a6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a6d:	0f b6 c0             	movzbl %al,%eax
80102a70:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a74:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a7b:	e8 5c fd ff ff       	call   801027dc <outb>
  }
}
80102a80:	c9                   	leave  
80102a81:	c3                   	ret    

80102a82 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a82:	55                   	push   %ebp
80102a83:	89 e5                	mov    %esp,%ebp
80102a85:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a88:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102a8f:	e8 a7 2a 00 00       	call   8010553b <acquire>

  if((b = idequeue) == 0){
80102a94:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102aa0:	75 11                	jne    80102ab3 <ideintr+0x31>
    release(&idelock);
80102aa2:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102aa9:	e8 f7 2a 00 00       	call   801055a5 <release>
    return;
80102aae:	e9 90 00 00 00       	jmp    80102b43 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab6:	8b 40 58             	mov    0x58(%eax),%eax
80102ab9:	a3 14 d9 10 80       	mov    %eax,0x8010d914

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	8b 00                	mov    (%eax),%eax
80102ac3:	83 e0 04             	and    $0x4,%eax
80102ac6:	85 c0                	test   %eax,%eax
80102ac8:	75 2e                	jne    80102af8 <ideintr+0x76>
80102aca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ad1:	e8 47 fd ff ff       	call   8010281d <idewait>
80102ad6:	85 c0                	test   %eax,%eax
80102ad8:	78 1e                	js     80102af8 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	83 c0 5c             	add    $0x5c,%eax
80102ae0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102ae7:	00 
80102ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aec:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102af3:	e8 bf fc ff ff       	call   801027b7 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afb:	8b 00                	mov    (%eax),%eax
80102afd:	83 c8 02             	or     $0x2,%eax
80102b00:	89 c2                	mov    %eax,%edx
80102b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b05:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0a:	8b 00                	mov    (%eax),%eax
80102b0c:	83 e0 fb             	and    $0xfffffffb,%eax
80102b0f:	89 c2                	mov    %eax,%edx
80102b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b14:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b19:	89 04 24             	mov    %eax,(%esp)
80102b1c:	e8 c2 23 00 00       	call   80104ee3 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102b21:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b26:	85 c0                	test   %eax,%eax
80102b28:	74 0d                	je     80102b37 <ideintr+0xb5>
    idestart(idequeue);
80102b2a:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b2f:	89 04 24             	mov    %eax,(%esp)
80102b32:	e8 c1 fd ff ff       	call   801028f8 <idestart>

  release(&idelock);
80102b37:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102b3e:	e8 62 2a 00 00       	call   801055a5 <release>
}
80102b43:	c9                   	leave  
80102b44:	c3                   	ret    

80102b45 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b45:	55                   	push   %ebp
80102b46:	89 e5                	mov    %esp,%ebp
80102b48:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4e:	83 c0 0c             	add    $0xc,%eax
80102b51:	89 04 24             	mov    %eax,(%esp)
80102b54:	e8 5a 29 00 00       	call   801054b3 <holdingsleep>
80102b59:	85 c0                	test   %eax,%eax
80102b5b:	75 0c                	jne    80102b69 <iderw+0x24>
    panic("iderw: buf not locked");
80102b5d:	c7 04 24 9b 9b 10 80 	movl   $0x80109b9b,(%esp)
80102b64:	e8 eb d9 ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b69:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6c:	8b 00                	mov    (%eax),%eax
80102b6e:	83 e0 06             	and    $0x6,%eax
80102b71:	83 f8 02             	cmp    $0x2,%eax
80102b74:	75 0c                	jne    80102b82 <iderw+0x3d>
    panic("iderw: nothing to do");
80102b76:	c7 04 24 b1 9b 10 80 	movl   $0x80109bb1,(%esp)
80102b7d:	e8 d2 d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102b82:	8b 45 08             	mov    0x8(%ebp),%eax
80102b85:	8b 40 04             	mov    0x4(%eax),%eax
80102b88:	85 c0                	test   %eax,%eax
80102b8a:	74 15                	je     80102ba1 <iderw+0x5c>
80102b8c:	a1 18 d9 10 80       	mov    0x8010d918,%eax
80102b91:	85 c0                	test   %eax,%eax
80102b93:	75 0c                	jne    80102ba1 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102b95:	c7 04 24 c6 9b 10 80 	movl   $0x80109bc6,(%esp)
80102b9c:	e8 b3 d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102ba1:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102ba8:	e8 8e 29 00 00       	call   8010553b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102bad:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb0:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102bb7:	c7 45 f4 14 d9 10 80 	movl   $0x8010d914,-0xc(%ebp)
80102bbe:	eb 0b                	jmp    80102bcb <iderw+0x86>
80102bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc3:	8b 00                	mov    (%eax),%eax
80102bc5:	83 c0 58             	add    $0x58,%eax
80102bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	8b 00                	mov    (%eax),%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	75 ec                	jne    80102bc0 <iderw+0x7b>
    ;
  *pp = b;
80102bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd7:	8b 55 08             	mov    0x8(%ebp),%edx
80102bda:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102bdc:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102be1:	3b 45 08             	cmp    0x8(%ebp),%eax
80102be4:	75 0d                	jne    80102bf3 <iderw+0xae>
    idestart(b);
80102be6:	8b 45 08             	mov    0x8(%ebp),%eax
80102be9:	89 04 24             	mov    %eax,(%esp)
80102bec:	e8 07 fd ff ff       	call   801028f8 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bf1:	eb 15                	jmp    80102c08 <iderw+0xc3>
80102bf3:	eb 13                	jmp    80102c08 <iderw+0xc3>
    sleep(b, &idelock);
80102bf5:	c7 44 24 04 e0 d8 10 	movl   $0x8010d8e0,0x4(%esp)
80102bfc:	80 
80102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80102c00:	89 04 24             	mov    %eax,(%esp)
80102c03:	e8 04 22 00 00       	call   80104e0c <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c08:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0b:	8b 00                	mov    (%eax),%eax
80102c0d:	83 e0 06             	and    $0x6,%eax
80102c10:	83 f8 02             	cmp    $0x2,%eax
80102c13:	75 e0                	jne    80102bf5 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102c15:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102c1c:	e8 84 29 00 00       	call   801055a5 <release>
}
80102c21:	c9                   	leave  
80102c22:	c3                   	ret    
	...

80102c24 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102c24:	55                   	push   %ebp
80102c25:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c27:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c2c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c2f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c31:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c36:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c39:	5d                   	pop    %ebp
80102c3a:	c3                   	ret    

80102c3b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c3b:	55                   	push   %ebp
80102c3c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c3e:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c43:	8b 55 08             	mov    0x8(%ebp),%edx
80102c46:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c48:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c50:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c53:	5d                   	pop    %ebp
80102c54:	c3                   	ret    

80102c55 <ioapicinit>:

void
ioapicinit(void)
{
80102c55:	55                   	push   %ebp
80102c56:	89 e5                	mov    %esp,%ebp
80102c58:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c5b:	c7 05 54 5b 11 80 00 	movl   $0xfec00000,0x80115b54
80102c62:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c6c:	e8 b3 ff ff ff       	call   80102c24 <ioapicread>
80102c71:	c1 e8 10             	shr    $0x10,%eax
80102c74:	25 ff 00 00 00       	and    $0xff,%eax
80102c79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c83:	e8 9c ff ff ff       	call   80102c24 <ioapicread>
80102c88:	c1 e8 18             	shr    $0x18,%eax
80102c8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c8e:	a0 a0 5c 11 80       	mov    0x80115ca0,%al
80102c93:	0f b6 c0             	movzbl %al,%eax
80102c96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c99:	74 0c                	je     80102ca7 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c9b:	c7 04 24 e4 9b 10 80 	movl   $0x80109be4,(%esp)
80102ca2:	e8 1a d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102cae:	eb 3d                	jmp    80102ced <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb3:	83 c0 20             	add    $0x20,%eax
80102cb6:	0d 00 00 01 00       	or     $0x10000,%eax
80102cbb:	89 c2                	mov    %eax,%edx
80102cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc0:	83 c0 08             	add    $0x8,%eax
80102cc3:	01 c0                	add    %eax,%eax
80102cc5:	89 54 24 04          	mov    %edx,0x4(%esp)
80102cc9:	89 04 24             	mov    %eax,(%esp)
80102ccc:	e8 6a ff ff ff       	call   80102c3b <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd4:	83 c0 08             	add    $0x8,%eax
80102cd7:	01 c0                	add    %eax,%eax
80102cd9:	40                   	inc    %eax
80102cda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ce1:	00 
80102ce2:	89 04 24             	mov    %eax,(%esp)
80102ce5:	e8 51 ff ff ff       	call   80102c3b <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cea:	ff 45 f4             	incl   -0xc(%ebp)
80102ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cf3:	7e bb                	jle    80102cb0 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cf5:	c9                   	leave  
80102cf6:	c3                   	ret    

80102cf7 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cf7:	55                   	push   %ebp
80102cf8:	89 e5                	mov    %esp,%ebp
80102cfa:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80102d00:	83 c0 20             	add    $0x20,%eax
80102d03:	89 c2                	mov    %eax,%edx
80102d05:	8b 45 08             	mov    0x8(%ebp),%eax
80102d08:	83 c0 08             	add    $0x8,%eax
80102d0b:	01 c0                	add    %eax,%eax
80102d0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d11:	89 04 24             	mov    %eax,(%esp)
80102d14:	e8 22 ff ff ff       	call   80102c3b <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d19:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1c:	c1 e0 18             	shl    $0x18,%eax
80102d1f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d22:	83 c2 08             	add    $0x8,%edx
80102d25:	01 d2                	add    %edx,%edx
80102d27:	42                   	inc    %edx
80102d28:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d2c:	89 14 24             	mov    %edx,(%esp)
80102d2f:	e8 07 ff ff ff       	call   80102c3b <ioapicwrite>
}
80102d34:	c9                   	leave  
80102d35:	c3                   	ret    
	...

80102d38 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d38:	55                   	push   %ebp
80102d39:	89 e5                	mov    %esp,%ebp
80102d3b:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d3e:	c7 44 24 04 16 9c 10 	movl   $0x80109c16,0x4(%esp)
80102d45:	80 
80102d46:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102d4d:	e8 c8 27 00 00       	call   8010551a <initlock>
  kmem.use_lock = 0;
80102d52:	c7 05 94 5b 11 80 00 	movl   $0x0,0x80115b94
80102d59:	00 00 00 
  freerange(vstart, vend);
80102d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d63:	8b 45 08             	mov    0x8(%ebp),%eax
80102d66:	89 04 24             	mov    %eax,(%esp)
80102d69:	e8 30 00 00 00       	call   80102d9e <freerange>
}
80102d6e:	c9                   	leave  
80102d6f:	c3                   	ret    

80102d70 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d70:	55                   	push   %ebp
80102d71:	89 e5                	mov    %esp,%ebp
80102d73:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d76:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d79:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d80:	89 04 24             	mov    %eax,(%esp)
80102d83:	e8 16 00 00 00       	call   80102d9e <freerange>
  kmem.use_lock = 1;
80102d88:	c7 05 94 5b 11 80 01 	movl   $0x1,0x80115b94
80102d8f:	00 00 00 
  kmem.i = 0;
80102d92:	c7 05 9c 5b 11 80 00 	movl   $0x0,0x80115b9c
80102d99:	00 00 00 
}
80102d9c:	c9                   	leave  
80102d9d:	c3                   	ret    

80102d9e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d9e:	55                   	push   %ebp
80102d9f:	89 e5                	mov    %esp,%ebp
80102da1:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102da4:	8b 45 08             	mov    0x8(%ebp),%eax
80102da7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102dac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db4:	eb 12                	jmp    80102dc8 <freerange+0x2a>
    kfree(p);
80102db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db9:	89 04 24             	mov    %eax,(%esp)
80102dbc:	e8 16 00 00 00       	call   80102dd7 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102dc1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dcb:	05 00 10 00 00       	add    $0x1000,%eax
80102dd0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dd3:	76 e1                	jbe    80102db6 <freerange+0x18>
    kfree(p);
}
80102dd5:	c9                   	leave  
80102dd6:	c3                   	ret    

80102dd7 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80102de0:	25 ff 0f 00 00       	and    $0xfff,%eax
80102de5:	85 c0                	test   %eax,%eax
80102de7:	75 18                	jne    80102e01 <kfree+0x2a>
80102de9:	81 7d 08 f0 8c 11 80 	cmpl   $0x80118cf0,0x8(%ebp)
80102df0:	72 0f                	jb     80102e01 <kfree+0x2a>
80102df2:	8b 45 08             	mov    0x8(%ebp),%eax
80102df5:	05 00 00 00 80       	add    $0x80000000,%eax
80102dfa:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dff:	76 0c                	jbe    80102e0d <kfree+0x36>
    panic("kfree");
80102e01:	c7 04 24 1b 9c 10 80 	movl   $0x80109c1b,(%esp)
80102e08:	e8 47 d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e0d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e14:	00 
80102e15:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e1c:	00 
80102e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102e20:	89 04 24             	mov    %eax,(%esp)
80102e23:	e8 76 29 00 00       	call   8010579e <memset>

  if(kmem.use_lock){
80102e28:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e2d:	85 c0                	test   %eax,%eax
80102e2f:	74 48                	je     80102e79 <kfree+0xa2>
    acquire(&kmem.lock);
80102e31:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e38:	e8 fe 26 00 00       	call   8010553b <acquire>
    if(ticks > 1){
80102e3d:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80102e42:	83 f8 01             	cmp    $0x1,%eax
80102e45:	76 32                	jbe    80102e79 <kfree+0xa2>
      int x = find(myproc()->cont->name);
80102e47:	e8 0f 17 00 00       	call   8010455b <myproc>
80102e4c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102e52:	83 c0 18             	add    $0x18,%eax
80102e55:	89 04 24             	mov    %eax,(%esp)
80102e58:	e8 fe 63 00 00       	call   8010925b <find>
80102e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102e60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e64:	78 13                	js     80102e79 <kfree+0xa2>
        reduce_curr_mem(1, x);
80102e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e69:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e74:	e8 35 67 00 00       	call   801095ae <reduce_curr_mem>
      }
    }
  }
  r = (struct run*)v;
80102e79:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102e7f:	8b 15 98 5b 11 80    	mov    0x80115b98,%edx
80102e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e88:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e8d:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  kmem.i--;
80102e92:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80102e97:	48                   	dec    %eax
80102e98:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  if(kmem.use_lock)
80102e9d:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102ea2:	85 c0                	test   %eax,%eax
80102ea4:	74 0c                	je     80102eb2 <kfree+0xdb>
    release(&kmem.lock);
80102ea6:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102ead:	e8 f3 26 00 00       	call   801055a5 <release>
}
80102eb2:	c9                   	leave  
80102eb3:	c3                   	ret    

80102eb4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102eb4:	55                   	push   %ebp
80102eb5:	89 e5                	mov    %esp,%ebp
80102eb7:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102eba:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102ebf:	85 c0                	test   %eax,%eax
80102ec1:	74 0c                	je     80102ecf <kalloc+0x1b>
    acquire(&kmem.lock);
80102ec3:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102eca:	e8 6c 26 00 00       	call   8010553b <acquire>
  }
  r = kmem.freelist;
80102ecf:	a1 98 5b 11 80       	mov    0x80115b98,%eax
80102ed4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ed7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102edb:	74 0a                	je     80102ee7 <kalloc+0x33>
    kmem.freelist = r->next;
80102edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee0:	8b 00                	mov    (%eax),%eax
80102ee2:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  kmem.i++;
80102ee7:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80102eec:	40                   	inc    %eax
80102eed:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  if((char*)r != 0){
80102ef2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ef6:	74 72                	je     80102f6a <kalloc+0xb6>
    if(ticks > 0){
80102ef8:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80102efd:	85 c0                	test   %eax,%eax
80102eff:	74 69                	je     80102f6a <kalloc+0xb6>
      int x = find(myproc()->cont->name);
80102f01:	e8 55 16 00 00       	call   8010455b <myproc>
80102f06:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f0c:	83 c0 18             	add    $0x18,%eax
80102f0f:	89 04 24             	mov    %eax,(%esp)
80102f12:	e8 44 63 00 00       	call   8010925b <find>
80102f17:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102f1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102f1e:	78 4a                	js     80102f6a <kalloc+0xb6>
        int before = get_curr_mem(x);
80102f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f23:	89 04 24             	mov    %eax,(%esp)
80102f26:	e8 c8 64 00 00       	call   801093f3 <get_curr_mem>
80102f2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f31:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102f3c:	e8 da 65 00 00       	call   8010951b <set_curr_mem>
        int after = get_curr_mem(x);
80102f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f44:	89 04 24             	mov    %eax,(%esp)
80102f47:	e8 a7 64 00 00       	call   801093f3 <get_curr_mem>
80102f4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f52:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102f55:	75 13                	jne    80102f6a <kalloc+0xb6>
          cstop_container_helper(myproc()->cont);
80102f57:	e8 ff 15 00 00       	call   8010455b <myproc>
80102f5c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f62:	89 04 24             	mov    %eax,(%esp)
80102f65:	e8 5e 21 00 00       	call   801050c8 <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
80102f6a:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102f6f:	85 c0                	test   %eax,%eax
80102f71:	74 0c                	je     80102f7f <kalloc+0xcb>
    release(&kmem.lock);
80102f73:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102f7a:	e8 26 26 00 00       	call   801055a5 <release>
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
80102f94:	b8 f0 8c 11 80       	mov    $0x80118cf0,%eax
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
80103545:	e8 cb 22 00 00       	call   80105815 <memcmp>
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
8010363a:	c7 44 24 04 21 9c 10 	movl   $0x80109c21,0x4(%esp)
80103641:	80 
80103642:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103649:	e8 cc 1e 00 00       	call   8010551a <initlock>
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
801036f1:	e8 71 21 00 00       	call   80105867 <memmove>
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
80103840:	e8 f6 1c 00 00       	call   8010553b <acquire>
  while(1){
    if(log.committing){
80103845:	a1 00 5c 11 80       	mov    0x80115c00,%eax
8010384a:	85 c0                	test   %eax,%eax
8010384c:	74 16                	je     80103864 <begin_op+0x31>
      sleep(&log, &log.lock);
8010384e:	c7 44 24 04 c0 5b 11 	movl   $0x80115bc0,0x4(%esp)
80103855:	80 
80103856:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010385d:	e8 aa 15 00 00       	call   80104e0c <sleep>
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
80103891:	e8 76 15 00 00       	call   80104e0c <sleep>
80103896:	eb 19                	jmp    801038b1 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103898:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
8010389d:	40                   	inc    %eax
8010389e:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
      release(&log.lock);
801038a3:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801038aa:	e8 f6 1c 00 00       	call   801055a5 <release>
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
801038c9:	e8 6d 1c 00 00       	call   8010553b <acquire>
  log.outstanding -= 1;
801038ce:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
801038d3:	48                   	dec    %eax
801038d4:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
  if(log.committing)
801038d9:	a1 00 5c 11 80       	mov    0x80115c00,%eax
801038de:	85 c0                	test   %eax,%eax
801038e0:	74 0c                	je     801038ee <end_op+0x39>
    panic("log.committing");
801038e2:	c7 04 24 25 9c 10 80 	movl   $0x80109c25,(%esp)
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
80103911:	e8 cd 15 00 00       	call   80104ee3 <wakeup>
  }
  release(&log.lock);
80103916:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010391d:	e8 83 1c 00 00       	call   801055a5 <release>

  if(do_commit){
80103922:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103926:	74 33                	je     8010395b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103928:	e8 db 00 00 00       	call   80103a08 <commit>
    acquire(&log.lock);
8010392d:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103934:	e8 02 1c 00 00       	call   8010553b <acquire>
    log.committing = 0;
80103939:	c7 05 00 5c 11 80 00 	movl   $0x0,0x80115c00
80103940:	00 00 00 
    wakeup(&log);
80103943:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010394a:	e8 94 15 00 00       	call   80104ee3 <wakeup>
    release(&log.lock);
8010394f:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103956:	e8 4a 1c 00 00       	call   801055a5 <release>
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
801039cf:	e8 93 1e 00 00       	call   80105867 <memmove>
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
80103a57:	c7 04 24 34 9c 10 80 	movl   $0x80109c34,(%esp)
80103a5e:	e8 f1 ca ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103a63:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80103a68:	85 c0                	test   %eax,%eax
80103a6a:	7f 0c                	jg     80103a78 <log_write+0x41>
    panic("log_write outside of trans");
80103a6c:	c7 04 24 4a 9c 10 80 	movl   $0x80109c4a,(%esp)
80103a73:	e8 dc ca ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103a78:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103a7f:	e8 b7 1a 00 00       	call   8010553b <acquire>
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
80103af3:	e8 ad 1a 00 00       	call   801055a5 <release>
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
80103b27:	c7 04 24 f0 8c 11 80 	movl   $0x80118cf0,(%esp)
80103b2e:	e8 05 f2 ff ff       	call   80102d38 <kinit1>
  kvmalloc();      // kernel page table
80103b33:	e8 93 4d 00 00       	call   801088cb <kvmalloc>
  mpinit();        // detect other processors
80103b38:	e8 f4 03 00 00       	call   80103f31 <mpinit>
  lapicinit();     // interrupt controller
80103b3d:	e8 4e f6 ff ff       	call   80103190 <lapicinit>
  seginit();       // segment descriptors
80103b42:	e8 6c 48 00 00       	call   801083b3 <seginit>
  picinit();       // disable pic
80103b47:	e8 34 05 00 00       	call   80104080 <picinit>
  ioapicinit();    // another interrupt controller
80103b4c:	e8 04 f1 ff ff       	call   80102c55 <ioapicinit>
  consoleinit();   // console hardware
80103b51:	e8 99 d0 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103b56:	e8 e4 3b 00 00       	call   8010773f <uartinit>
  pinit();         // process table
80103b5b:	e8 16 09 00 00       	call   80104476 <pinit>
  tvinit();        // trap vectors
80103b60:	e8 a7 37 00 00       	call   8010730c <tvinit>
  binit();         // buffer cache
80103b65:	e8 ca c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b6a:	e8 77 d5 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103b6f:	e8 ed ec ff ff       	call   80102861 <ideinit>
  startothers();   // start other processors
80103b74:	e8 b3 00 00 00       	call   80103c2c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103b79:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103b80:	8e 
80103b81:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103b88:	e8 e3 f1 ff ff       	call   80102d70 <kinit2>
  freebytes = (P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024));
80103b8d:	b8 f0 8c 11 80       	mov    $0x80118cf0,%eax
80103b92:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
80103b97:	29 c2                	sub    %eax,%edx
80103b99:	89 d0                	mov    %edx,%eax
80103b9b:	a3 84 5c 11 80       	mov    %eax,0x80115c84
  cprintf("MEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEME: %d\n", freebytes/4096);
80103ba0:	a1 84 5c 11 80       	mov    0x80115c84,%eax
80103ba5:	c1 e8 0c             	shr    $0xc,%eax
80103ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bac:	c7 04 24 68 9c 10 80 	movl   $0x80109c68,(%esp)
80103bb3:	e8 09 c8 ff ff       	call   801003c1 <cprintf>
  userinit();      // first user process
80103bb8:	e8 e3 0a 00 00       	call   801046a0 <userinit>
  container_init();
80103bbd:	e8 76 5b 00 00       	call   80109738 <container_init>
  mpmain();        // finish this processor's setup
80103bc2:	e8 1a 00 00 00       	call   80103be1 <mpmain>

80103bc7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103bc7:	55                   	push   %ebp
80103bc8:	89 e5                	mov    %esp,%ebp
80103bca:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103bcd:	e8 10 4d 00 00       	call   801088e2 <switchkvm>
  seginit();
80103bd2:	e8 dc 47 00 00       	call   801083b3 <seginit>
  lapicinit();
80103bd7:	e8 b4 f5 ff ff       	call   80103190 <lapicinit>
  mpmain();
80103bdc:	e8 00 00 00 00       	call   80103be1 <mpmain>

80103be1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103be1:	55                   	push   %ebp
80103be2:	89 e5                	mov    %esp,%ebp
80103be4:	53                   	push   %ebx
80103be5:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103be8:	e8 a5 08 00 00       	call   80104492 <cpuid>
80103bed:	89 c3                	mov    %eax,%ebx
80103bef:	e8 9e 08 00 00       	call   80104492 <cpuid>
80103bf4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bfc:	c7 04 24 a4 9c 10 80 	movl   $0x80109ca4,(%esp)
80103c03:	e8 b9 c7 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103c08:	e8 5c 38 00 00       	call   80107469 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103c0d:	e8 c5 08 00 00       	call   801044d7 <mycpu>
80103c12:	05 a0 00 00 00       	add    $0xa0,%eax
80103c17:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103c1e:	00 
80103c1f:	89 04 24             	mov    %eax,(%esp)
80103c22:	e8 d5 fe ff ff       	call   80103afc <xchg>
  scheduler();     // start running processes
80103c27:	e8 13 10 00 00       	call   80104c3f <scheduler>

80103c2c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c2c:	55                   	push   %ebp
80103c2d:	89 e5                	mov    %esp,%ebp
80103c2f:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103c32:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c39:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c3e:	89 44 24 08          	mov    %eax,0x8(%esp)
80103c42:	c7 44 24 04 8c d5 10 	movl   $0x8010d58c,0x4(%esp)
80103c49:	80 
80103c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4d:	89 04 24             	mov    %eax,(%esp)
80103c50:	e8 12 1c 00 00       	call   80105867 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103c55:	c7 45 f4 c0 5c 11 80 	movl   $0x80115cc0,-0xc(%ebp)
80103c5c:	eb 75                	jmp    80103cd3 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103c5e:	e8 74 08 00 00       	call   801044d7 <mycpu>
80103c63:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c66:	75 02                	jne    80103c6a <startothers+0x3e>
      continue;
80103c68:	eb 62                	jmp    80103ccc <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103c6a:	e8 45 f2 ff ff       	call   80102eb4 <kalloc>
80103c6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c75:	83 e8 04             	sub    $0x4,%eax
80103c78:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103c7b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103c81:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c86:	83 e8 08             	sub    $0x8,%eax
80103c89:	c7 00 c7 3b 10 80    	movl   $0x80103bc7,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c92:	8d 50 f4             	lea    -0xc(%eax),%edx
80103c95:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103c9a:	05 00 00 00 80       	add    $0x80000000,%eax
80103c9f:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cad:	8a 00                	mov    (%eax),%al
80103caf:	0f b6 c0             	movzbl %al,%eax
80103cb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80103cb6:	89 04 24             	mov    %eax,(%esp)
80103cb9:	e8 77 f6 ff ff       	call   80103335 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103cbe:	90                   	nop
80103cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103cc8:	85 c0                	test   %eax,%eax
80103cca:	74 f3                	je     80103cbf <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103ccc:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103cd3:	a1 40 62 11 80       	mov    0x80116240,%eax
80103cd8:	89 c2                	mov    %eax,%edx
80103cda:	89 d0                	mov    %edx,%eax
80103cdc:	c1 e0 02             	shl    $0x2,%eax
80103cdf:	01 d0                	add    %edx,%eax
80103ce1:	01 c0                	add    %eax,%eax
80103ce3:	01 d0                	add    %edx,%eax
80103ce5:	c1 e0 04             	shl    $0x4,%eax
80103ce8:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80103ced:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cf0:	0f 87 68 ff ff ff    	ja     80103c5e <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103cf6:	c9                   	leave  
80103cf7:	c3                   	ret    

80103cf8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103cf8:	55                   	push   %ebp
80103cf9:	89 e5                	mov    %esp,%ebp
80103cfb:	83 ec 14             	sub    $0x14,%esp
80103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80103d01:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d08:	89 c2                	mov    %eax,%edx
80103d0a:	ec                   	in     (%dx),%al
80103d0b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103d0e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103d11:	c9                   	leave  
80103d12:	c3                   	ret    

80103d13 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d13:	55                   	push   %ebp
80103d14:	89 e5                	mov    %esp,%ebp
80103d16:	83 ec 08             	sub    $0x8,%esp
80103d19:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d1f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d23:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d26:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d29:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d2c:	ee                   	out    %al,(%dx)
}
80103d2d:	c9                   	leave  
80103d2e:	c3                   	ret    

80103d2f <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103d35:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103d3c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103d43:	eb 13                	jmp    80103d58 <sum+0x29>
    sum += addr[i];
80103d45:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d48:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4b:	01 d0                	add    %edx,%eax
80103d4d:	8a 00                	mov    (%eax),%al
80103d4f:	0f b6 c0             	movzbl %al,%eax
80103d52:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103d55:	ff 45 fc             	incl   -0x4(%ebp)
80103d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d5b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103d5e:	7c e5                	jl     80103d45 <sum+0x16>
    sum += addr[i];
  return sum;
80103d60:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103d63:	c9                   	leave  
80103d64:	c3                   	ret    

80103d65 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103d65:	55                   	push   %ebp
80103d66:	89 e5                	mov    %esp,%ebp
80103d68:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6e:	05 00 00 00 80       	add    $0x80000000,%eax
80103d73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103d76:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7c:	01 d0                	add    %edx,%eax
80103d7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d87:	eb 3f                	jmp    80103dc8 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103d89:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d90:	00 
80103d91:	c7 44 24 04 b8 9c 10 	movl   $0x80109cb8,0x4(%esp)
80103d98:	80 
80103d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9c:	89 04 24             	mov    %eax,(%esp)
80103d9f:	e8 71 1a 00 00       	call   80105815 <memcmp>
80103da4:	85 c0                	test   %eax,%eax
80103da6:	75 1c                	jne    80103dc4 <mpsearch1+0x5f>
80103da8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103daf:	00 
80103db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db3:	89 04 24             	mov    %eax,(%esp)
80103db6:	e8 74 ff ff ff       	call   80103d2f <sum>
80103dbb:	84 c0                	test   %al,%al
80103dbd:	75 05                	jne    80103dc4 <mpsearch1+0x5f>
      return (struct mp*)p;
80103dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc2:	eb 11                	jmp    80103dd5 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103dc4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103dce:	72 b9                	jb     80103d89 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dd5:	c9                   	leave  
80103dd6:	c3                   	ret    

80103dd7 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103dd7:	55                   	push   %ebp
80103dd8:	89 e5                	mov    %esp,%ebp
80103dda:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ddd:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de7:	83 c0 0f             	add    $0xf,%eax
80103dea:	8a 00                	mov    (%eax),%al
80103dec:	0f b6 c0             	movzbl %al,%eax
80103def:	c1 e0 08             	shl    $0x8,%eax
80103df2:	89 c2                	mov    %eax,%edx
80103df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df7:	83 c0 0e             	add    $0xe,%eax
80103dfa:	8a 00                	mov    (%eax),%al
80103dfc:	0f b6 c0             	movzbl %al,%eax
80103dff:	09 d0                	or     %edx,%eax
80103e01:	c1 e0 04             	shl    $0x4,%eax
80103e04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e0b:	74 21                	je     80103e2e <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103e0d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e14:	00 
80103e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e18:	89 04 24             	mov    %eax,(%esp)
80103e1b:	e8 45 ff ff ff       	call   80103d65 <mpsearch1>
80103e20:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e23:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e27:	74 4e                	je     80103e77 <mpsearch+0xa0>
      return mp;
80103e29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e2c:	eb 5d                	jmp    80103e8b <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e31:	83 c0 14             	add    $0x14,%eax
80103e34:	8a 00                	mov    (%eax),%al
80103e36:	0f b6 c0             	movzbl %al,%eax
80103e39:	c1 e0 08             	shl    $0x8,%eax
80103e3c:	89 c2                	mov    %eax,%edx
80103e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e41:	83 c0 13             	add    $0x13,%eax
80103e44:	8a 00                	mov    (%eax),%al
80103e46:	0f b6 c0             	movzbl %al,%eax
80103e49:	09 d0                	or     %edx,%eax
80103e4b:	c1 e0 0a             	shl    $0xa,%eax
80103e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e54:	2d 00 04 00 00       	sub    $0x400,%eax
80103e59:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e60:	00 
80103e61:	89 04 24             	mov    %eax,(%esp)
80103e64:	e8 fc fe ff ff       	call   80103d65 <mpsearch1>
80103e69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e70:	74 05                	je     80103e77 <mpsearch+0xa0>
      return mp;
80103e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e75:	eb 14                	jmp    80103e8b <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103e77:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103e7e:	00 
80103e7f:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103e86:	e8 da fe ff ff       	call   80103d65 <mpsearch1>
}
80103e8b:	c9                   	leave  
80103e8c:	c3                   	ret    

80103e8d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103e8d:	55                   	push   %ebp
80103e8e:	89 e5                	mov    %esp,%ebp
80103e90:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103e93:	e8 3f ff ff ff       	call   80103dd7 <mpsearch>
80103e98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e9f:	74 0a                	je     80103eab <mpconfig+0x1e>
80103ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea4:	8b 40 04             	mov    0x4(%eax),%eax
80103ea7:	85 c0                	test   %eax,%eax
80103ea9:	75 07                	jne    80103eb2 <mpconfig+0x25>
    return 0;
80103eab:	b8 00 00 00 00       	mov    $0x0,%eax
80103eb0:	eb 7d                	jmp    80103f2f <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb5:	8b 40 04             	mov    0x4(%eax),%eax
80103eb8:	05 00 00 00 80       	add    $0x80000000,%eax
80103ebd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103ec0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ec7:	00 
80103ec8:	c7 44 24 04 bd 9c 10 	movl   $0x80109cbd,0x4(%esp)
80103ecf:	80 
80103ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ed3:	89 04 24             	mov    %eax,(%esp)
80103ed6:	e8 3a 19 00 00       	call   80105815 <memcmp>
80103edb:	85 c0                	test   %eax,%eax
80103edd:	74 07                	je     80103ee6 <mpconfig+0x59>
    return 0;
80103edf:	b8 00 00 00 00       	mov    $0x0,%eax
80103ee4:	eb 49                	jmp    80103f2f <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee9:	8a 40 06             	mov    0x6(%eax),%al
80103eec:	3c 01                	cmp    $0x1,%al
80103eee:	74 11                	je     80103f01 <mpconfig+0x74>
80103ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ef3:	8a 40 06             	mov    0x6(%eax),%al
80103ef6:	3c 04                	cmp    $0x4,%al
80103ef8:	74 07                	je     80103f01 <mpconfig+0x74>
    return 0;
80103efa:	b8 00 00 00 00       	mov    $0x0,%eax
80103eff:	eb 2e                	jmp    80103f2f <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f04:	8b 40 04             	mov    0x4(%eax),%eax
80103f07:	0f b7 c0             	movzwl %ax,%eax
80103f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f11:	89 04 24             	mov    %eax,(%esp)
80103f14:	e8 16 fe ff ff       	call   80103d2f <sum>
80103f19:	84 c0                	test   %al,%al
80103f1b:	74 07                	je     80103f24 <mpconfig+0x97>
    return 0;
80103f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80103f22:	eb 0b                	jmp    80103f2f <mpconfig+0xa2>
  *pmp = mp;
80103f24:	8b 45 08             	mov    0x8(%ebp),%eax
80103f27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f2a:	89 10                	mov    %edx,(%eax)
  return conf;
80103f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f2f:	c9                   	leave  
80103f30:	c3                   	ret    

80103f31 <mpinit>:

void
mpinit(void)
{
80103f31:	55                   	push   %ebp
80103f32:	89 e5                	mov    %esp,%ebp
80103f34:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103f37:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103f3a:	89 04 24             	mov    %eax,(%esp)
80103f3d:	e8 4b ff ff ff       	call   80103e8d <mpconfig>
80103f42:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f45:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f49:	75 0c                	jne    80103f57 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103f4b:	c7 04 24 c2 9c 10 80 	movl   $0x80109cc2,(%esp)
80103f52:	e8 fd c5 ff ff       	call   80100554 <panic>
  ismp = 1;
80103f57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103f5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f61:	8b 40 24             	mov    0x24(%eax),%eax
80103f64:	a3 a0 5b 11 80       	mov    %eax,0x80115ba0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f6c:	83 c0 2c             	add    $0x2c,%eax
80103f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f75:	8b 40 04             	mov    0x4(%eax),%eax
80103f78:	0f b7 d0             	movzwl %ax,%edx
80103f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f7e:	01 d0                	add    %edx,%eax
80103f80:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103f83:	eb 7d                	jmp    80104002 <mpinit+0xd1>
    switch(*p){
80103f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f88:	8a 00                	mov    (%eax),%al
80103f8a:	0f b6 c0             	movzbl %al,%eax
80103f8d:	83 f8 04             	cmp    $0x4,%eax
80103f90:	77 68                	ja     80103ffa <mpinit+0xc9>
80103f92:	8b 04 85 fc 9c 10 80 	mov    -0x7fef6304(,%eax,4),%eax
80103f99:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103fa1:	a1 40 62 11 80       	mov    0x80116240,%eax
80103fa6:	83 f8 07             	cmp    $0x7,%eax
80103fa9:	7f 2c                	jg     80103fd7 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103fab:	8b 15 40 62 11 80    	mov    0x80116240,%edx
80103fb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103fb4:	8a 48 01             	mov    0x1(%eax),%cl
80103fb7:	89 d0                	mov    %edx,%eax
80103fb9:	c1 e0 02             	shl    $0x2,%eax
80103fbc:	01 d0                	add    %edx,%eax
80103fbe:	01 c0                	add    %eax,%eax
80103fc0:	01 d0                	add    %edx,%eax
80103fc2:	c1 e0 04             	shl    $0x4,%eax
80103fc5:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80103fca:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103fcc:	a1 40 62 11 80       	mov    0x80116240,%eax
80103fd1:	40                   	inc    %eax
80103fd2:	a3 40 62 11 80       	mov    %eax,0x80116240
      }
      p += sizeof(struct mpproc);
80103fd7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103fdb:	eb 25                	jmp    80104002 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103fe3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe6:	8a 40 01             	mov    0x1(%eax),%al
80103fe9:	a2 a0 5c 11 80       	mov    %al,0x80115ca0
      p += sizeof(struct mpioapic);
80103fee:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ff2:	eb 0e                	jmp    80104002 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ff4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ff8:	eb 08                	jmp    80104002 <mpinit+0xd1>
    default:
      ismp = 0;
80103ffa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80104001:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104005:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104008:	0f 82 77 ff ff ff    	jb     80103f85 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
8010400e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104012:	75 0c                	jne    80104020 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80104014:	c7 04 24 dc 9c 10 80 	movl   $0x80109cdc,(%esp)
8010401b:	e8 34 c5 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80104020:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104023:	8a 40 0c             	mov    0xc(%eax),%al
80104026:	84 c0                	test   %al,%al
80104028:	74 36                	je     80104060 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010402a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104031:	00 
80104032:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104039:	e8 d5 fc ff ff       	call   80103d13 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010403e:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104045:	e8 ae fc ff ff       	call   80103cf8 <inb>
8010404a:	83 c8 01             	or     $0x1,%eax
8010404d:	0f b6 c0             	movzbl %al,%eax
80104050:	89 44 24 04          	mov    %eax,0x4(%esp)
80104054:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010405b:	e8 b3 fc ff ff       	call   80103d13 <outb>
  }
}
80104060:	c9                   	leave  
80104061:	c3                   	ret    
	...

80104064 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104064:	55                   	push   %ebp
80104065:	89 e5                	mov    %esp,%ebp
80104067:	83 ec 08             	sub    $0x8,%esp
8010406a:	8b 45 08             	mov    0x8(%ebp),%eax
8010406d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104070:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80104074:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104077:	8a 45 f8             	mov    -0x8(%ebp),%al
8010407a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010407d:	ee                   	out    %al,(%dx)
}
8010407e:	c9                   	leave  
8010407f:	c3                   	ret    

80104080 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104080:	55                   	push   %ebp
80104081:	89 e5                	mov    %esp,%ebp
80104083:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104086:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
8010408d:	00 
8010408e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104095:	e8 ca ff ff ff       	call   80104064 <outb>
  outb(IO_PIC2+1, 0xFF);
8010409a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801040a1:	00 
801040a2:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801040a9:	e8 b6 ff ff ff       	call   80104064 <outb>
}
801040ae:	c9                   	leave  
801040af:	c3                   	ret    

801040b0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040b0:	55                   	push   %ebp
801040b1:	89 e5                	mov    %esp,%ebp
801040b3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
801040b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801040c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c9:	8b 10                	mov    (%eax),%edx
801040cb:	8b 45 08             	mov    0x8(%ebp),%eax
801040ce:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040d0:	e8 2d d0 ff ff       	call   80101102 <filealloc>
801040d5:	8b 55 08             	mov    0x8(%ebp),%edx
801040d8:	89 02                	mov    %eax,(%edx)
801040da:	8b 45 08             	mov    0x8(%ebp),%eax
801040dd:	8b 00                	mov    (%eax),%eax
801040df:	85 c0                	test   %eax,%eax
801040e1:	0f 84 c8 00 00 00    	je     801041af <pipealloc+0xff>
801040e7:	e8 16 d0 ff ff       	call   80101102 <filealloc>
801040ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801040ef:	89 02                	mov    %eax,(%edx)
801040f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f4:	8b 00                	mov    (%eax),%eax
801040f6:	85 c0                	test   %eax,%eax
801040f8:	0f 84 b1 00 00 00    	je     801041af <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040fe:	e8 b1 ed ff ff       	call   80102eb4 <kalloc>
80104103:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104106:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010410a:	75 05                	jne    80104111 <pipealloc+0x61>
    goto bad;
8010410c:	e9 9e 00 00 00       	jmp    801041af <pipealloc+0xff>
  p->readopen = 1;
80104111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104114:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010411b:	00 00 00 
  p->writeopen = 1;
8010411e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104121:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104128:	00 00 00 
  p->nwrite = 0;
8010412b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104135:	00 00 00 
  p->nread = 0;
80104138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104142:	00 00 00 
  initlock(&p->lock, "pipe");
80104145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104148:	c7 44 24 04 10 9d 10 	movl   $0x80109d10,0x4(%esp)
8010414f:	80 
80104150:	89 04 24             	mov    %eax,(%esp)
80104153:	e8 c2 13 00 00       	call   8010551a <initlock>
  (*f0)->type = FD_PIPE;
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 00                	mov    (%eax),%eax
80104171:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	8b 00                	mov    (%eax),%eax
8010417a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104180:	8b 45 0c             	mov    0xc(%ebp),%eax
80104183:	8b 00                	mov    (%eax),%eax
80104185:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010418b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010418e:	8b 00                	mov    (%eax),%eax
80104190:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104194:	8b 45 0c             	mov    0xc(%ebp),%eax
80104197:	8b 00                	mov    (%eax),%eax
80104199:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010419d:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a0:	8b 00                	mov    (%eax),%eax
801041a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a5:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041a8:	b8 00 00 00 00       	mov    $0x0,%eax
801041ad:	eb 42                	jmp    801041f1 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801041af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041b3:	74 0b                	je     801041c0 <pipealloc+0x110>
    kfree((char*)p);
801041b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b8:	89 04 24             	mov    %eax,(%esp)
801041bb:	e8 17 ec ff ff       	call   80102dd7 <kfree>
  if(*f0)
801041c0:	8b 45 08             	mov    0x8(%ebp),%eax
801041c3:	8b 00                	mov    (%eax),%eax
801041c5:	85 c0                	test   %eax,%eax
801041c7:	74 0d                	je     801041d6 <pipealloc+0x126>
    fileclose(*f0);
801041c9:	8b 45 08             	mov    0x8(%ebp),%eax
801041cc:	8b 00                	mov    (%eax),%eax
801041ce:	89 04 24             	mov    %eax,(%esp)
801041d1:	e8 d4 cf ff ff       	call   801011aa <fileclose>
  if(*f1)
801041d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d9:	8b 00                	mov    (%eax),%eax
801041db:	85 c0                	test   %eax,%eax
801041dd:	74 0d                	je     801041ec <pipealloc+0x13c>
    fileclose(*f1);
801041df:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e2:	8b 00                	mov    (%eax),%eax
801041e4:	89 04 24             	mov    %eax,(%esp)
801041e7:	e8 be cf ff ff       	call   801011aa <fileclose>
  return -1;
801041ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041f1:	c9                   	leave  
801041f2:	c3                   	ret    

801041f3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041f3:	55                   	push   %ebp
801041f4:	89 e5                	mov    %esp,%ebp
801041f6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801041f9:	8b 45 08             	mov    0x8(%ebp),%eax
801041fc:	89 04 24             	mov    %eax,(%esp)
801041ff:	e8 37 13 00 00       	call   8010553b <acquire>
  if(writable){
80104204:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104208:	74 1f                	je     80104229 <pipeclose+0x36>
    p->writeopen = 0;
8010420a:	8b 45 08             	mov    0x8(%ebp),%eax
8010420d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104214:	00 00 00 
    wakeup(&p->nread);
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	05 34 02 00 00       	add    $0x234,%eax
8010421f:	89 04 24             	mov    %eax,(%esp)
80104222:	e8 bc 0c 00 00       	call   80104ee3 <wakeup>
80104227:	eb 1d                	jmp    80104246 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104233:	00 00 00 
    wakeup(&p->nwrite);
80104236:	8b 45 08             	mov    0x8(%ebp),%eax
80104239:	05 38 02 00 00       	add    $0x238,%eax
8010423e:	89 04 24             	mov    %eax,(%esp)
80104241:	e8 9d 0c 00 00       	call   80104ee3 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104246:	8b 45 08             	mov    0x8(%ebp),%eax
80104249:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010424f:	85 c0                	test   %eax,%eax
80104251:	75 25                	jne    80104278 <pipeclose+0x85>
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010425c:	85 c0                	test   %eax,%eax
8010425e:	75 18                	jne    80104278 <pipeclose+0x85>
    release(&p->lock);
80104260:	8b 45 08             	mov    0x8(%ebp),%eax
80104263:	89 04 24             	mov    %eax,(%esp)
80104266:	e8 3a 13 00 00       	call   801055a5 <release>
    kfree((char*)p);
8010426b:	8b 45 08             	mov    0x8(%ebp),%eax
8010426e:	89 04 24             	mov    %eax,(%esp)
80104271:	e8 61 eb ff ff       	call   80102dd7 <kfree>
80104276:	eb 0b                	jmp    80104283 <pipeclose+0x90>
  } else
    release(&p->lock);
80104278:	8b 45 08             	mov    0x8(%ebp),%eax
8010427b:	89 04 24             	mov    %eax,(%esp)
8010427e:	e8 22 13 00 00       	call   801055a5 <release>
}
80104283:	c9                   	leave  
80104284:	c3                   	ret    

80104285 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	89 04 24             	mov    %eax,(%esp)
80104291:	e8 a5 12 00 00       	call   8010553b <acquire>
  for(i = 0; i < n; i++){
80104296:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010429d:	e9 a3 00 00 00       	jmp    80104345 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042a2:	eb 56                	jmp    801042fa <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
801042a4:	8b 45 08             	mov    0x8(%ebp),%eax
801042a7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042ad:	85 c0                	test   %eax,%eax
801042af:	74 0c                	je     801042bd <pipewrite+0x38>
801042b1:	e8 a5 02 00 00       	call   8010455b <myproc>
801042b6:	8b 40 24             	mov    0x24(%eax),%eax
801042b9:	85 c0                	test   %eax,%eax
801042bb:	74 15                	je     801042d2 <pipewrite+0x4d>
        release(&p->lock);
801042bd:	8b 45 08             	mov    0x8(%ebp),%eax
801042c0:	89 04 24             	mov    %eax,(%esp)
801042c3:	e8 dd 12 00 00       	call   801055a5 <release>
        return -1;
801042c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042cd:	e9 9d 00 00 00       	jmp    8010436f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801042d2:	8b 45 08             	mov    0x8(%ebp),%eax
801042d5:	05 34 02 00 00       	add    $0x234,%eax
801042da:	89 04 24             	mov    %eax,(%esp)
801042dd:	e8 01 0c 00 00       	call   80104ee3 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042e2:	8b 45 08             	mov    0x8(%ebp),%eax
801042e5:	8b 55 08             	mov    0x8(%ebp),%edx
801042e8:	81 c2 38 02 00 00    	add    $0x238,%edx
801042ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801042f2:	89 14 24             	mov    %edx,(%esp)
801042f5:	e8 12 0b 00 00       	call   80104e0c <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042fa:	8b 45 08             	mov    0x8(%ebp),%eax
801042fd:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010430c:	05 00 02 00 00       	add    $0x200,%eax
80104311:	39 c2                	cmp    %eax,%edx
80104313:	74 8f                	je     801042a4 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010431e:	8d 48 01             	lea    0x1(%eax),%ecx
80104321:	8b 55 08             	mov    0x8(%ebp),%edx
80104324:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010432a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010432f:	89 c1                	mov    %eax,%ecx
80104331:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104334:	8b 45 0c             	mov    0xc(%ebp),%eax
80104337:	01 d0                	add    %edx,%eax
80104339:	8a 10                	mov    (%eax),%dl
8010433b:	8b 45 08             	mov    0x8(%ebp),%eax
8010433e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104342:	ff 45 f4             	incl   -0xc(%ebp)
80104345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104348:	3b 45 10             	cmp    0x10(%ebp),%eax
8010434b:	0f 8c 51 ff ff ff    	jl     801042a2 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104351:	8b 45 08             	mov    0x8(%ebp),%eax
80104354:	05 34 02 00 00       	add    $0x234,%eax
80104359:	89 04 24             	mov    %eax,(%esp)
8010435c:	e8 82 0b 00 00       	call   80104ee3 <wakeup>
  release(&p->lock);
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	89 04 24             	mov    %eax,(%esp)
80104367:	e8 39 12 00 00       	call   801055a5 <release>
  return n;
8010436c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010436f:	c9                   	leave  
80104370:	c3                   	ret    

80104371 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104371:	55                   	push   %ebp
80104372:	89 e5                	mov    %esp,%ebp
80104374:	53                   	push   %ebx
80104375:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104378:	8b 45 08             	mov    0x8(%ebp),%eax
8010437b:	89 04 24             	mov    %eax,(%esp)
8010437e:	e8 b8 11 00 00       	call   8010553b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104383:	eb 39                	jmp    801043be <piperead+0x4d>
    if(myproc()->killed){
80104385:	e8 d1 01 00 00       	call   8010455b <myproc>
8010438a:	8b 40 24             	mov    0x24(%eax),%eax
8010438d:	85 c0                	test   %eax,%eax
8010438f:	74 15                	je     801043a6 <piperead+0x35>
      release(&p->lock);
80104391:	8b 45 08             	mov    0x8(%ebp),%eax
80104394:	89 04 24             	mov    %eax,(%esp)
80104397:	e8 09 12 00 00       	call   801055a5 <release>
      return -1;
8010439c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a1:	e9 b3 00 00 00       	jmp    80104459 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043a6:	8b 45 08             	mov    0x8(%ebp),%eax
801043a9:	8b 55 08             	mov    0x8(%ebp),%edx
801043ac:	81 c2 34 02 00 00    	add    $0x234,%edx
801043b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801043b6:	89 14 24             	mov    %edx,(%esp)
801043b9:	e8 4e 0a 00 00       	call   80104e0c <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043be:	8b 45 08             	mov    0x8(%ebp),%eax
801043c1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ca:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d0:	39 c2                	cmp    %eax,%edx
801043d2:	75 0d                	jne    801043e1 <piperead+0x70>
801043d4:	8b 45 08             	mov    0x8(%ebp),%eax
801043d7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043dd:	85 c0                	test   %eax,%eax
801043df:	75 a4                	jne    80104385 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043e8:	eb 49                	jmp    80104433 <piperead+0xc2>
    if(p->nread == p->nwrite)
801043ea:	8b 45 08             	mov    0x8(%ebp),%eax
801043ed:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043f3:	8b 45 08             	mov    0x8(%ebp),%eax
801043f6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043fc:	39 c2                	cmp    %eax,%edx
801043fe:	75 02                	jne    80104402 <piperead+0x91>
      break;
80104400:	eb 39                	jmp    8010443b <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104402:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104405:	8b 45 0c             	mov    0xc(%ebp),%eax
80104408:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010440b:	8b 45 08             	mov    0x8(%ebp),%eax
8010440e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104414:	8d 48 01             	lea    0x1(%eax),%ecx
80104417:	8b 55 08             	mov    0x8(%ebp),%edx
8010441a:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104420:	25 ff 01 00 00       	and    $0x1ff,%eax
80104425:	89 c2                	mov    %eax,%edx
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
8010442e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104430:	ff 45 f4             	incl   -0xc(%ebp)
80104433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104436:	3b 45 10             	cmp    0x10(%ebp),%eax
80104439:	7c af                	jl     801043ea <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010443b:	8b 45 08             	mov    0x8(%ebp),%eax
8010443e:	05 38 02 00 00       	add    $0x238,%eax
80104443:	89 04 24             	mov    %eax,(%esp)
80104446:	e8 98 0a 00 00       	call   80104ee3 <wakeup>
  release(&p->lock);
8010444b:	8b 45 08             	mov    0x8(%ebp),%eax
8010444e:	89 04 24             	mov    %eax,(%esp)
80104451:	e8 4f 11 00 00       	call   801055a5 <release>
  return i;
80104456:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104459:	83 c4 24             	add    $0x24,%esp
8010445c:	5b                   	pop    %ebx
8010445d:	5d                   	pop    %ebp
8010445e:	c3                   	ret    
	...

80104460 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104466:	9c                   	pushf  
80104467:	58                   	pop    %eax
80104468:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010446b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010446e:	c9                   	leave  
8010446f:	c3                   	ret    

80104470 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104470:	55                   	push   %ebp
80104471:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104473:	fb                   	sti    
}
80104474:	5d                   	pop    %ebp
80104475:	c3                   	ret    

80104476 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104476:	55                   	push   %ebp
80104477:	89 e5                	mov    %esp,%ebp
80104479:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010447c:	c7 44 24 04 18 9d 10 	movl   $0x80109d18,0x4(%esp)
80104483:	80 
80104484:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
8010448b:	e8 8a 10 00 00       	call   8010551a <initlock>
}
80104490:	c9                   	leave  
80104491:	c3                   	ret    

80104492 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104492:	55                   	push   %ebp
80104493:	89 e5                	mov    %esp,%ebp
80104495:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104498:	e8 3a 00 00 00       	call   801044d7 <mycpu>
8010449d:	89 c2                	mov    %eax,%edx
8010449f:	b8 c0 5c 11 80       	mov    $0x80115cc0,%eax
801044a4:	29 c2                	sub    %eax,%edx
801044a6:	89 d0                	mov    %edx,%eax
801044a8:	c1 f8 04             	sar    $0x4,%eax
801044ab:	89 c1                	mov    %eax,%ecx
801044ad:	89 ca                	mov    %ecx,%edx
801044af:	c1 e2 03             	shl    $0x3,%edx
801044b2:	01 ca                	add    %ecx,%edx
801044b4:	89 d0                	mov    %edx,%eax
801044b6:	c1 e0 05             	shl    $0x5,%eax
801044b9:	29 d0                	sub    %edx,%eax
801044bb:	c1 e0 02             	shl    $0x2,%eax
801044be:	01 c8                	add    %ecx,%eax
801044c0:	c1 e0 03             	shl    $0x3,%eax
801044c3:	01 c8                	add    %ecx,%eax
801044c5:	89 c2                	mov    %eax,%edx
801044c7:	c1 e2 0f             	shl    $0xf,%edx
801044ca:	29 c2                	sub    %eax,%edx
801044cc:	c1 e2 02             	shl    $0x2,%edx
801044cf:	01 ca                	add    %ecx,%edx
801044d1:	89 d0                	mov    %edx,%eax
801044d3:	f7 d8                	neg    %eax
}
801044d5:	c9                   	leave  
801044d6:	c3                   	ret    

801044d7 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801044d7:	55                   	push   %ebp
801044d8:	89 e5                	mov    %esp,%ebp
801044da:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801044dd:	e8 7e ff ff ff       	call   80104460 <readeflags>
801044e2:	25 00 02 00 00       	and    $0x200,%eax
801044e7:	85 c0                	test   %eax,%eax
801044e9:	74 0c                	je     801044f7 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801044eb:	c7 04 24 20 9d 10 80 	movl   $0x80109d20,(%esp)
801044f2:	e8 5d c0 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801044f7:	e8 ed ed ff ff       	call   801032e9 <lapicid>
801044fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104506:	eb 3b                	jmp    80104543 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104508:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450b:	89 d0                	mov    %edx,%eax
8010450d:	c1 e0 02             	shl    $0x2,%eax
80104510:	01 d0                	add    %edx,%eax
80104512:	01 c0                	add    %eax,%eax
80104514:	01 d0                	add    %edx,%eax
80104516:	c1 e0 04             	shl    $0x4,%eax
80104519:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
8010451e:	8a 00                	mov    (%eax),%al
80104520:	0f b6 c0             	movzbl %al,%eax
80104523:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104526:	75 18                	jne    80104540 <mycpu+0x69>
      return &cpus[i];
80104528:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010452b:	89 d0                	mov    %edx,%eax
8010452d:	c1 e0 02             	shl    $0x2,%eax
80104530:	01 d0                	add    %edx,%eax
80104532:	01 c0                	add    %eax,%eax
80104534:	01 d0                	add    %edx,%eax
80104536:	c1 e0 04             	shl    $0x4,%eax
80104539:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
8010453e:	eb 19                	jmp    80104559 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104540:	ff 45 f4             	incl   -0xc(%ebp)
80104543:	a1 40 62 11 80       	mov    0x80116240,%eax
80104548:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010454b:	7c bb                	jl     80104508 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
8010454d:	c7 04 24 46 9d 10 80 	movl   $0x80109d46,(%esp)
80104554:	e8 fb bf ff ff       	call   80100554 <panic>
}
80104559:	c9                   	leave  
8010455a:	c3                   	ret    

8010455b <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010455b:	55                   	push   %ebp
8010455c:	89 e5                	mov    %esp,%ebp
8010455e:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104561:	e8 34 11 00 00       	call   8010569a <pushcli>
  c = mycpu();
80104566:	e8 6c ff ff ff       	call   801044d7 <mycpu>
8010456b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010456e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104571:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104577:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010457a:	e8 65 11 00 00       	call   801056e4 <popcli>
  return p;
8010457f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104582:	c9                   	leave  
80104583:	c3                   	ret    

80104584 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104584:	55                   	push   %ebp
80104585:	89 e5                	mov    %esp,%ebp
80104587:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010458a:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104591:	e8 a5 0f 00 00       	call   8010553b <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104596:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
8010459d:	eb 53                	jmp    801045f2 <allocproc+0x6e>
    if(p->state == UNUSED)
8010459f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a2:	8b 40 0c             	mov    0xc(%eax),%eax
801045a5:	85 c0                	test   %eax,%eax
801045a7:	75 42                	jne    801045eb <allocproc+0x67>
      goto found;
801045a9:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801045b4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801045b9:	8d 50 01             	lea    0x1(%eax),%edx
801045bc:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
801045c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045c8:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801045cf:	e8 d1 0f 00 00       	call   801055a5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045d4:	e8 db e8 ff ff       	call   80102eb4 <kalloc>
801045d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045dc:	89 42 08             	mov    %eax,0x8(%edx)
801045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e2:	8b 40 08             	mov    0x8(%eax),%eax
801045e5:	85 c0                	test   %eax,%eax
801045e7:	75 39                	jne    80104622 <allocproc+0x9e>
801045e9:	eb 26                	jmp    80104611 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045eb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801045f2:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
801045f9:	72 a4                	jb     8010459f <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801045fb:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104602:	e8 9e 0f 00 00       	call   801055a5 <release>
  return 0;
80104607:	b8 00 00 00 00       	mov    $0x0,%eax
8010460c:	e9 8d 00 00 00       	jmp    8010469e <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104614:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010461b:	b8 00 00 00 00       	mov    $0x0,%eax
80104620:	eb 7c                	jmp    8010469e <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	8b 40 08             	mov    0x8(%eax),%eax
80104628:	05 00 10 00 00       	add    $0x1000,%eax
8010462d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104630:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104637:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463a:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010463d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104641:	ba c8 72 10 80       	mov    $0x801072c8,%edx
80104646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104649:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010464b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010464f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104652:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104655:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010465e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104665:	00 
80104666:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010466d:	00 
8010466e:	89 04 24             	mov    %eax,(%esp)
80104671:	e8 28 11 00 00       	call   8010579e <memset>
  p->context->eip = (uint)forkret;
80104676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104679:	8b 40 1c             	mov    0x1c(%eax),%eax
8010467c:	ba cd 4d 10 80       	mov    $0x80104dcd,%edx
80104681:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104687:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
8010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104691:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104698:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
8010469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010469e:	c9                   	leave  
8010469f:	c3                   	ret    

801046a0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801046a0:	55                   	push   %ebp
801046a1:	89 e5                	mov    %esp,%ebp
801046a3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801046a6:	e8 d9 fe ff ff       	call   80104584 <allocproc>
801046ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801046ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b1:	a3 20 d9 10 80       	mov    %eax,0x8010d920
  if((p->pgdir = setupkvm()) == 0)
801046b6:	e8 67 41 00 00       	call   80108822 <setupkvm>
801046bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046be:	89 42 04             	mov    %eax,0x4(%edx)
801046c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c4:	8b 40 04             	mov    0x4(%eax),%eax
801046c7:	85 c0                	test   %eax,%eax
801046c9:	75 0c                	jne    801046d7 <userinit+0x37>
    panic("userinit: out of memory?");
801046cb:	c7 04 24 56 9d 10 80 	movl   $0x80109d56,(%esp)
801046d2:	e8 7d be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046d7:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046df:	8b 40 04             	mov    0x4(%eax),%eax
801046e2:	89 54 24 08          	mov    %edx,0x8(%esp)
801046e6:	c7 44 24 04 60 d5 10 	movl   $0x8010d560,0x4(%esp)
801046ed:	80 
801046ee:	89 04 24             	mov    %eax,(%esp)
801046f1:	e8 8d 43 00 00       	call   80108a83 <inituvm>
  p->sz = PGSIZE;
801046f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104702:	8b 40 18             	mov    0x18(%eax),%eax
80104705:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010470c:	00 
8010470d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104714:	00 
80104715:	89 04 24             	mov    %eax,(%esp)
80104718:	e8 81 10 00 00       	call   8010579e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010471d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104720:	8b 40 18             	mov    0x18(%eax),%eax
80104723:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472c:	8b 40 18             	mov    0x18(%eax),%eax
8010472f:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104738:	8b 50 18             	mov    0x18(%eax),%edx
8010473b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473e:	8b 40 18             	mov    0x18(%eax),%eax
80104741:	8b 40 2c             	mov    0x2c(%eax),%eax
80104744:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474b:	8b 50 18             	mov    0x18(%eax),%edx
8010474e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104751:	8b 40 18             	mov    0x18(%eax),%eax
80104754:	8b 40 2c             	mov    0x2c(%eax),%eax
80104757:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
8010475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475e:	8b 40 18             	mov    0x18(%eax),%eax
80104761:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476b:	8b 40 18             	mov    0x18(%eax),%eax
8010476e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104778:	8b 40 18             	mov    0x18(%eax),%eax
8010477b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104785:	83 c0 6c             	add    $0x6c,%eax
80104788:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010478f:	00 
80104790:	c7 44 24 04 6f 9d 10 	movl   $0x80109d6f,0x4(%esp)
80104797:	80 
80104798:	89 04 24             	mov    %eax,(%esp)
8010479b:	e8 0a 12 00 00       	call   801059aa <safestrcpy>
  p->cwd = namei("/");
801047a0:	c7 04 24 78 9d 10 80 	movl   $0x80109d78,(%esp)
801047a7:	e8 ac df ff ff       	call   80102758 <namei>
801047ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047af:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801047b2:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801047b9:	e8 7d 0d 00 00       	call   8010553b <acquire>

  p->state = RUNNABLE;
801047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047c8:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801047cf:	e8 d1 0d 00 00       	call   801055a5 <release>
}
801047d4:	c9                   	leave  
801047d5:	c3                   	ret    

801047d6 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
801047d9:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801047dc:	e8 7a fd ff ff       	call   8010455b <myproc>
801047e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801047e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e7:	8b 00                	mov    (%eax),%eax
801047e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047ec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047f0:	7e 31                	jle    80104823 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047f2:	8b 55 08             	mov    0x8(%ebp),%edx
801047f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f8:	01 c2                	add    %eax,%edx
801047fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047fd:	8b 40 04             	mov    0x4(%eax),%eax
80104800:	89 54 24 08          	mov    %edx,0x8(%esp)
80104804:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104807:	89 54 24 04          	mov    %edx,0x4(%esp)
8010480b:	89 04 24             	mov    %eax,(%esp)
8010480e:	e8 db 43 00 00       	call   80108bee <allocuvm>
80104813:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104816:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010481a:	75 3e                	jne    8010485a <growproc+0x84>
      return -1;
8010481c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104821:	eb 4f                	jmp    80104872 <growproc+0x9c>
  } else if(n < 0){
80104823:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104827:	79 31                	jns    8010485a <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104829:	8b 55 08             	mov    0x8(%ebp),%edx
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	01 c2                	add    %eax,%edx
80104831:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104834:	8b 40 04             	mov    0x4(%eax),%eax
80104837:	89 54 24 08          	mov    %edx,0x8(%esp)
8010483b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010483e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104842:	89 04 24             	mov    %eax,(%esp)
80104845:	e8 ba 44 00 00       	call   80108d04 <deallocuvm>
8010484a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010484d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104851:	75 07                	jne    8010485a <growproc+0x84>
      return -1;
80104853:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104858:	eb 18                	jmp    80104872 <growproc+0x9c>
  }
  curproc->sz = sz;
8010485a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104860:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104865:	89 04 24             	mov    %eax,(%esp)
80104868:	e8 8f 40 00 00       	call   801088fc <switchuvm>
  return 0;
8010486d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104872:	c9                   	leave  
80104873:	c3                   	ret    

80104874 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104874:	55                   	push   %ebp
80104875:	89 e5                	mov    %esp,%ebp
80104877:	57                   	push   %edi
80104878:	56                   	push   %esi
80104879:	53                   	push   %ebx
8010487a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010487d:	e8 d9 fc ff ff       	call   8010455b <myproc>
80104882:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104885:	e8 fa fc ff ff       	call   80104584 <allocproc>
8010488a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010488d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104891:	75 0a                	jne    8010489d <fork+0x29>
    return -1;
80104893:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104898:	e9 47 01 00 00       	jmp    801049e4 <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010489d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a0:	8b 10                	mov    (%eax),%edx
801048a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a5:	8b 40 04             	mov    0x4(%eax),%eax
801048a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801048ac:	89 04 24             	mov    %eax,(%esp)
801048af:	e8 f0 45 00 00       	call   80108ea4 <copyuvm>
801048b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048b7:	89 42 04             	mov    %eax,0x4(%edx)
801048ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bd:	8b 40 04             	mov    0x4(%eax),%eax
801048c0:	85 c0                	test   %eax,%eax
801048c2:	75 2c                	jne    801048f0 <fork+0x7c>
    kfree(np->kstack);
801048c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048c7:	8b 40 08             	mov    0x8(%eax),%eax
801048ca:	89 04 24             	mov    %eax,(%esp)
801048cd:	e8 05 e5 ff ff       	call   80102dd7 <kfree>
    np->kstack = 0;
801048d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048eb:	e9 f4 00 00 00       	jmp    801049e4 <fork+0x170>
  }
  np->sz = curproc->sz;
801048f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f3:	8b 10                	mov    (%eax),%edx
801048f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104900:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104903:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104906:	8b 50 18             	mov    0x18(%eax),%edx
80104909:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490c:	8b 40 18             	mov    0x18(%eax),%eax
8010490f:	89 c3                	mov    %eax,%ebx
80104911:	b8 13 00 00 00       	mov    $0x13,%eax
80104916:	89 d7                	mov    %edx,%edi
80104918:	89 de                	mov    %ebx,%esi
8010491a:	89 c1                	mov    %eax,%ecx
8010491c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010491e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104921:	8b 40 18             	mov    0x18(%eax),%eax
80104924:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010492b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104932:	eb 36                	jmp    8010496a <fork+0xf6>
    if(curproc->ofile[i])
80104934:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104937:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010493a:	83 c2 08             	add    $0x8,%edx
8010493d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104941:	85 c0                	test   %eax,%eax
80104943:	74 22                	je     80104967 <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104945:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104948:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104952:	89 04 24             	mov    %eax,(%esp)
80104955:	e8 08 c8 ff ff       	call   80101162 <filedup>
8010495a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010495d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104960:	83 c1 08             	add    $0x8,%ecx
80104963:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104967:	ff 45 e4             	incl   -0x1c(%ebp)
8010496a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010496e:	7e c4                	jle    80104934 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104970:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104973:	8b 40 68             	mov    0x68(%eax),%eax
80104976:	89 04 24             	mov    %eax,(%esp)
80104979:	e8 12 d1 ff ff       	call   80101a90 <idup>
8010497e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104981:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104984:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104987:	8d 50 6c             	lea    0x6c(%eax),%edx
8010498a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010498d:	83 c0 6c             	add    $0x6c,%eax
80104990:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104997:	00 
80104998:	89 54 24 04          	mov    %edx,0x4(%esp)
8010499c:	89 04 24             	mov    %eax,(%esp)
8010499f:	e8 06 10 00 00       	call   801059aa <safestrcpy>



  pid = np->pid;
801049a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a7:	8b 40 10             	mov    0x10(%eax),%eax
801049aa:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049ad:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801049b4:	e8 82 0b 00 00       	call   8010553b <acquire>

  np->state = RUNNABLE;
801049b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049bc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
801049c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c6:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801049cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049cf:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
801049d5:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801049dc:	e8 c4 0b 00 00       	call   801055a5 <release>

  return pid;
801049e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049e4:	83 c4 2c             	add    $0x2c,%esp
801049e7:	5b                   	pop    %ebx
801049e8:	5e                   	pop    %esi
801049e9:	5f                   	pop    %edi
801049ea:	5d                   	pop    %ebp
801049eb:	c3                   	ret    

801049ec <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049ec:	55                   	push   %ebp
801049ed:	89 e5                	mov    %esp,%ebp
801049ef:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801049f2:	e8 64 fb ff ff       	call   8010455b <myproc>
801049f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049fa:	a1 20 d9 10 80       	mov    0x8010d920,%eax
801049ff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a02:	75 0c                	jne    80104a10 <exit+0x24>
    panic("init exiting");
80104a04:	c7 04 24 7a 9d 10 80 	movl   $0x80109d7a,(%esp)
80104a0b:	e8 44 bb ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a10:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a17:	eb 3a                	jmp    80104a53 <exit+0x67>
    if(curproc->ofile[fd]){
80104a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a1f:	83 c2 08             	add    $0x8,%edx
80104a22:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a26:	85 c0                	test   %eax,%eax
80104a28:	74 26                	je     80104a50 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a2d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a30:	83 c2 08             	add    $0x8,%edx
80104a33:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a37:	89 04 24             	mov    %eax,(%esp)
80104a3a:	e8 6b c7 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104a3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a42:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a45:	83 c2 08             	add    $0x8,%edx
80104a48:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a4f:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a50:	ff 45 f0             	incl   -0x10(%ebp)
80104a53:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a57:	7e c0                	jle    80104a19 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104a59:	e8 d5 ed ff ff       	call   80103833 <begin_op>
  iput(curproc->cwd);
80104a5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a61:	8b 40 68             	mov    0x68(%eax),%eax
80104a64:	89 04 24             	mov    %eax,(%esp)
80104a67:	e8 a4 d1 ff ff       	call   80101c10 <iput>
  end_op();
80104a6c:	e8 44 ee ff ff       	call   801038b5 <end_op>
  curproc->cwd = 0;
80104a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a74:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a7b:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104a82:	e8 b4 0a 00 00       	call   8010553b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8a:	8b 40 14             	mov    0x14(%eax),%eax
80104a8d:	89 04 24             	mov    %eax,(%esp)
80104a90:	e8 0d 04 00 00       	call   80104ea2 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a95:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104a9c:	eb 36                	jmp    80104ad4 <exit+0xe8>
    if(p->parent == curproc){
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	8b 40 14             	mov    0x14(%eax),%eax
80104aa4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104aa7:	75 24                	jne    80104acd <exit+0xe1>
      p->parent = initproc;
80104aa9:	8b 15 20 d9 10 80    	mov    0x8010d920,%edx
80104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	8b 40 0c             	mov    0xc(%eax),%eax
80104abb:	83 f8 05             	cmp    $0x5,%eax
80104abe:	75 0d                	jne    80104acd <exit+0xe1>
        wakeup1(initproc);
80104ac0:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104ac5:	89 04 24             	mov    %eax,(%esp)
80104ac8:	e8 d5 03 00 00       	call   80104ea2 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104acd:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ad4:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104adb:	72 c1                	jb     80104a9e <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104add:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104ae7:	e8 01 02 00 00       	call   80104ced <sched>
  panic("zombie exit");
80104aec:	c7 04 24 87 9d 10 80 	movl   $0x80109d87,(%esp)
80104af3:	e8 5c ba ff ff       	call   80100554 <panic>

80104af8 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104af8:	55                   	push   %ebp
80104af9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104afb:	eb 06                	jmp    80104b03 <strcmp1+0xb>
    p++, q++;
80104afd:	ff 45 08             	incl   0x8(%ebp)
80104b00:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104b03:	8b 45 08             	mov    0x8(%ebp),%eax
80104b06:	8a 00                	mov    (%eax),%al
80104b08:	84 c0                	test   %al,%al
80104b0a:	74 0e                	je     80104b1a <strcmp1+0x22>
80104b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0f:	8a 10                	mov    (%eax),%dl
80104b11:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b14:	8a 00                	mov    (%eax),%al
80104b16:	38 c2                	cmp    %al,%dl
80104b18:	74 e3                	je     80104afd <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1d:	8a 00                	mov    (%eax),%al
80104b1f:	0f b6 d0             	movzbl %al,%edx
80104b22:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b25:	8a 00                	mov    (%eax),%al
80104b27:	0f b6 c0             	movzbl %al,%eax
80104b2a:	29 c2                	sub    %eax,%edx
80104b2c:	89 d0                	mov    %edx,%eax
}
80104b2e:	5d                   	pop    %ebp
80104b2f:	c3                   	ret    

80104b30 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b30:	55                   	push   %ebp
80104b31:	89 e5                	mov    %esp,%ebp
80104b33:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b36:	e8 20 fa ff ff       	call   8010455b <myproc>
80104b3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b3e:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104b45:	e8 f1 09 00 00       	call   8010553b <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b51:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104b58:	e9 98 00 00 00       	jmp    80104bf5 <wait+0xc5>
      if(p->parent != curproc)
80104b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b60:	8b 40 14             	mov    0x14(%eax),%eax
80104b63:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104b66:	74 05                	je     80104b6d <wait+0x3d>
        continue;
80104b68:	e9 81 00 00 00       	jmp    80104bee <wait+0xbe>
      havekids = 1;
80104b6d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b77:	8b 40 0c             	mov    0xc(%eax),%eax
80104b7a:	83 f8 05             	cmp    $0x5,%eax
80104b7d:	75 6f                	jne    80104bee <wait+0xbe>
        // Found one.
        pid = p->pid;
80104b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b82:	8b 40 10             	mov    0x10(%eax),%eax
80104b85:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8b:	8b 40 08             	mov    0x8(%eax),%eax
80104b8e:	89 04 24             	mov    %eax,(%esp)
80104b91:	e8 41 e2 ff ff       	call   80102dd7 <kfree>
        p->kstack = 0;
80104b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba3:	8b 40 04             	mov    0x4(%eax),%eax
80104ba6:	89 04 24             	mov    %eax,(%esp)
80104ba9:	e8 1a 42 00 00       	call   80108dc8 <freevm>
        p->pid = 0;
80104bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcc:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bdd:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104be4:	e8 bc 09 00 00       	call   801055a5 <release>
        return pid;
80104be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104bec:	eb 4f                	jmp    80104c3d <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bee:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104bf5:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104bfc:	0f 82 5b ff ff ff    	jb     80104b5d <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c06:	74 0a                	je     80104c12 <wait+0xe2>
80104c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c0b:	8b 40 24             	mov    0x24(%eax),%eax
80104c0e:	85 c0                	test   %eax,%eax
80104c10:	74 13                	je     80104c25 <wait+0xf5>
      release(&ptable.lock);
80104c12:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104c19:	e8 87 09 00 00       	call   801055a5 <release>
      return -1;
80104c1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c23:	eb 18                	jmp    80104c3d <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c25:	c7 44 24 04 60 62 11 	movl   $0x80116260,0x4(%esp)
80104c2c:	80 
80104c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c30:	89 04 24             	mov    %eax,(%esp)
80104c33:	e8 d4 01 00 00       	call   80104e0c <sleep>
  }
80104c38:	e9 0d ff ff ff       	jmp    80104b4a <wait+0x1a>
}
80104c3d:	c9                   	leave  
80104c3e:	c3                   	ret    

80104c3f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c3f:	55                   	push   %ebp
80104c40:	89 e5                	mov    %esp,%ebp
80104c42:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c45:	e8 8d f8 ff ff       	call   801044d7 <mycpu>
80104c4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c50:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c57:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c5a:	e8 11 f8 ff ff       	call   80104470 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c5f:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104c66:	e8 d0 08 00 00       	call   8010553b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6b:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104c72:	eb 5f                	jmp    80104cd3 <scheduler+0x94>
      if(p->state != RUNNABLE)
80104c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c77:	8b 40 0c             	mov    0xc(%eax),%eax
80104c7a:	83 f8 03             	cmp    $0x3,%eax
80104c7d:	74 02                	je     80104c81 <scheduler+0x42>
        continue;
80104c7f:	eb 4b                	jmp    80104ccc <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c87:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c90:	89 04 24             	mov    %eax,(%esp)
80104c93:	e8 64 3c 00 00       	call   801088fc <switchuvm>
      p->state = RUNNING;
80104c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca5:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ca8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cab:	83 c2 04             	add    $0x4,%edx
80104cae:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cb2:	89 14 24             	mov    %edx,(%esp)
80104cb5:	e8 5e 0d 00 00       	call   80105a18 <swtch>
      switchkvm();
80104cba:	e8 23 3c 00 00       	call   801088e2 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cc9:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ccc:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104cd3:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104cda:	72 98                	jb     80104c74 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104cdc:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104ce3:	e8 bd 08 00 00       	call   801055a5 <release>

  }
80104ce8:	e9 6d ff ff ff       	jmp    80104c5a <scheduler+0x1b>

80104ced <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ced:	55                   	push   %ebp
80104cee:	89 e5                	mov    %esp,%ebp
80104cf0:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104cf3:	e8 63 f8 ff ff       	call   8010455b <myproc>
80104cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104cfb:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104d02:	e8 62 09 00 00       	call   80105669 <holding>
80104d07:	85 c0                	test   %eax,%eax
80104d09:	75 0c                	jne    80104d17 <sched+0x2a>
    panic("sched ptable.lock");
80104d0b:	c7 04 24 93 9d 10 80 	movl   $0x80109d93,(%esp)
80104d12:	e8 3d b8 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104d17:	e8 bb f7 ff ff       	call   801044d7 <mycpu>
80104d1c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d22:	83 f8 01             	cmp    $0x1,%eax
80104d25:	74 0c                	je     80104d33 <sched+0x46>
    panic("sched locks");
80104d27:	c7 04 24 a5 9d 10 80 	movl   $0x80109da5,(%esp)
80104d2e:	e8 21 b8 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d36:	8b 40 0c             	mov    0xc(%eax),%eax
80104d39:	83 f8 04             	cmp    $0x4,%eax
80104d3c:	75 0c                	jne    80104d4a <sched+0x5d>
    panic("sched running");
80104d3e:	c7 04 24 b1 9d 10 80 	movl   $0x80109db1,(%esp)
80104d45:	e8 0a b8 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104d4a:	e8 11 f7 ff ff       	call   80104460 <readeflags>
80104d4f:	25 00 02 00 00       	and    $0x200,%eax
80104d54:	85 c0                	test   %eax,%eax
80104d56:	74 0c                	je     80104d64 <sched+0x77>
    panic("sched interruptible");
80104d58:	c7 04 24 bf 9d 10 80 	movl   $0x80109dbf,(%esp)
80104d5f:	e8 f0 b7 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104d64:	e8 6e f7 ff ff       	call   801044d7 <mycpu>
80104d69:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d72:	e8 60 f7 ff ff       	call   801044d7 <mycpu>
80104d77:	8b 40 04             	mov    0x4(%eax),%eax
80104d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d7d:	83 c2 1c             	add    $0x1c,%edx
80104d80:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d84:	89 14 24             	mov    %edx,(%esp)
80104d87:	e8 8c 0c 00 00       	call   80105a18 <swtch>
  mycpu()->intena = intena;
80104d8c:	e8 46 f7 ff ff       	call   801044d7 <mycpu>
80104d91:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d94:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104d9a:	c9                   	leave  
80104d9b:	c3                   	ret    

80104d9c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d9c:	55                   	push   %ebp
80104d9d:	89 e5                	mov    %esp,%ebp
80104d9f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104da2:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104da9:	e8 8d 07 00 00       	call   8010553b <acquire>
  myproc()->state = RUNNABLE;
80104dae:	e8 a8 f7 ff ff       	call   8010455b <myproc>
80104db3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104dba:	e8 2e ff ff ff       	call   80104ced <sched>
  release(&ptable.lock);
80104dbf:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104dc6:	e8 da 07 00 00       	call   801055a5 <release>
}
80104dcb:	c9                   	leave  
80104dcc:	c3                   	ret    

80104dcd <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104dcd:	55                   	push   %ebp
80104dce:	89 e5                	mov    %esp,%ebp
80104dd0:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104dd3:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104dda:	e8 c6 07 00 00       	call   801055a5 <release>

  if (first) {
80104ddf:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104de4:	85 c0                	test   %eax,%eax
80104de6:	74 22                	je     80104e0a <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104de8:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104def:	00 00 00 
    iinit(ROOTDEV);
80104df2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104df9:	e8 5d c9 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104dfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104e05:	e8 2a e8 ff ff       	call   80103634 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e0a:	c9                   	leave  
80104e0b:	c3                   	ret    

80104e0c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e0c:	55                   	push   %ebp
80104e0d:	89 e5                	mov    %esp,%ebp
80104e0f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104e12:	e8 44 f7 ff ff       	call   8010455b <myproc>
80104e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e1e:	75 0c                	jne    80104e2c <sleep+0x20>
    panic("sleep");
80104e20:	c7 04 24 d3 9d 10 80 	movl   $0x80109dd3,(%esp)
80104e27:	e8 28 b7 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e30:	75 0c                	jne    80104e3e <sleep+0x32>
    panic("sleep without lk");
80104e32:	c7 04 24 d9 9d 10 80 	movl   $0x80109dd9,(%esp)
80104e39:	e8 16 b7 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e3e:	81 7d 0c 60 62 11 80 	cmpl   $0x80116260,0xc(%ebp)
80104e45:	74 17                	je     80104e5e <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e47:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e4e:	e8 e8 06 00 00       	call   8010553b <acquire>
    release(lk);
80104e53:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e56:	89 04 24             	mov    %eax,(%esp)
80104e59:	e8 47 07 00 00       	call   801055a5 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e61:	8b 55 08             	mov    0x8(%ebp),%edx
80104e64:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104e71:	e8 77 fe ff ff       	call   80104ced <sched>

  // Tidy up.
  p->chan = 0;
80104e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e79:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e80:	81 7d 0c 60 62 11 80 	cmpl   $0x80116260,0xc(%ebp)
80104e87:	74 17                	je     80104ea0 <sleep+0x94>
    release(&ptable.lock);
80104e89:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e90:	e8 10 07 00 00       	call   801055a5 <release>
    acquire(lk);
80104e95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e98:	89 04 24             	mov    %eax,(%esp)
80104e9b:	e8 9b 06 00 00       	call   8010553b <acquire>
  }
}
80104ea0:	c9                   	leave  
80104ea1:	c3                   	ret    

80104ea2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
80104ea5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ea8:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
80104eaf:	eb 27                	jmp    80104ed8 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb7:	83 f8 02             	cmp    $0x2,%eax
80104eba:	75 15                	jne    80104ed1 <wakeup1+0x2f>
80104ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ebf:	8b 40 20             	mov    0x20(%eax),%eax
80104ec2:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ec5:	75 0a                	jne    80104ed1 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eca:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed1:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104ed8:	81 7d fc 94 83 11 80 	cmpl   $0x80118394,-0x4(%ebp)
80104edf:	72 d0                	jb     80104eb1 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104ee1:	c9                   	leave  
80104ee2:	c3                   	ret    

80104ee3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ee3:	55                   	push   %ebp
80104ee4:	89 e5                	mov    %esp,%ebp
80104ee6:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ee9:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104ef0:	e8 46 06 00 00       	call   8010553b <acquire>
  wakeup1(chan);
80104ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef8:	89 04 24             	mov    %eax,(%esp)
80104efb:	e8 a2 ff ff ff       	call   80104ea2 <wakeup1>
  release(&ptable.lock);
80104f00:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f07:	e8 99 06 00 00       	call   801055a5 <release>
}
80104f0c:	c9                   	leave  
80104f0d:	c3                   	ret    

80104f0e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f0e:	55                   	push   %ebp
80104f0f:	89 e5                	mov    %esp,%ebp
80104f11:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f14:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f1b:	e8 1b 06 00 00       	call   8010553b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f20:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104f27:	eb 44                	jmp    80104f6d <kill+0x5f>
    if(p->pid == pid){
80104f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2c:	8b 40 10             	mov    0x10(%eax),%eax
80104f2f:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f32:	75 32                	jne    80104f66 <kill+0x58>
      p->killed = 1;
80104f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f37:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f41:	8b 40 0c             	mov    0xc(%eax),%eax
80104f44:	83 f8 02             	cmp    $0x2,%eax
80104f47:	75 0a                	jne    80104f53 <kill+0x45>
        p->state = RUNNABLE;
80104f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f53:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f5a:	e8 46 06 00 00       	call   801055a5 <release>
      return 0;
80104f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80104f64:	eb 21                	jmp    80104f87 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f66:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104f6d:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104f74:	72 b3                	jb     80104f29 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f76:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f7d:	e8 23 06 00 00       	call   801055a5 <release>
  return -1;
80104f82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f87:	c9                   	leave  
80104f88:	c3                   	ret    

80104f89 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f89:	55                   	push   %ebp
80104f8a:	89 e5                	mov    %esp,%ebp
80104f8c:	83 ec 68             	sub    $0x68,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f8f:	c7 45 f0 94 62 11 80 	movl   $0x80116294,-0x10(%ebp)
80104f96:	e9 1e 01 00 00       	jmp    801050b9 <procdump+0x130>
    if(p->state == UNUSED)
80104f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9e:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa1:	85 c0                	test   %eax,%eax
80104fa3:	75 05                	jne    80104faa <procdump+0x21>
      continue;
80104fa5:	e9 08 01 00 00       	jmp    801050b2 <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fad:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb0:	83 f8 05             	cmp    $0x5,%eax
80104fb3:	77 23                	ja     80104fd8 <procdump+0x4f>
80104fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb8:	8b 40 0c             	mov    0xc(%eax),%eax
80104fbb:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80104fc2:	85 c0                	test   %eax,%eax
80104fc4:	74 12                	je     80104fd8 <procdump+0x4f>
      state = states[p->state];
80104fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc9:	8b 40 0c             	mov    0xc(%eax),%eax
80104fcc:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80104fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fd6:	eb 07                	jmp    80104fdf <procdump+0x56>
    else
      state = "???";
80104fd8:	c7 45 ec ea 9d 10 80 	movl   $0x80109dea,-0x14(%ebp)

    if(p->cont == NULL){
80104fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fe8:	85 c0                	test   %eax,%eax
80104fea:	75 29                	jne    80105015 <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fef:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff5:	8b 40 10             	mov    0x10(%eax),%eax
80104ff8:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104ffc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fff:	89 54 24 08          	mov    %edx,0x8(%esp)
80105003:	89 44 24 04          	mov    %eax,0x4(%esp)
80105007:	c7 04 24 ee 9d 10 80 	movl   $0x80109dee,(%esp)
8010500e:	e8 ae b3 ff ff       	call   801003c1 <cprintf>
80105013:	eb 37                	jmp    8010504c <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80105015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105018:	8d 50 6c             	lea    0x6c(%eax),%edx
8010501b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105024:	8d 48 18             	lea    0x18(%eax),%ecx
80105027:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502a:	8b 40 10             	mov    0x10(%eax),%eax
8010502d:	89 54 24 10          	mov    %edx,0x10(%esp)
80105031:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105034:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010503c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105040:	c7 04 24 fc 9d 10 80 	movl   $0x80109dfc,(%esp)
80105047:	e8 75 b3 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
8010504c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504f:	8b 40 0c             	mov    0xc(%eax),%eax
80105052:	83 f8 02             	cmp    $0x2,%eax
80105055:	75 4f                	jne    801050a6 <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010505d:	8b 40 0c             	mov    0xc(%eax),%eax
80105060:	83 c0 08             	add    $0x8,%eax
80105063:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105066:	89 54 24 04          	mov    %edx,0x4(%esp)
8010506a:	89 04 24             	mov    %eax,(%esp)
8010506d:	e8 80 05 00 00       	call   801055f2 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105072:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105079:	eb 1a                	jmp    80105095 <procdump+0x10c>
        cprintf(" %p", pc[i]);
8010507b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105082:	89 44 24 04          	mov    %eax,0x4(%esp)
80105086:	c7 04 24 08 9e 10 80 	movl   $0x80109e08,(%esp)
8010508d:	e8 2f b3 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105092:	ff 45 f4             	incl   -0xc(%ebp)
80105095:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105099:	7f 0b                	jg     801050a6 <procdump+0x11d>
8010509b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050a2:	85 c0                	test   %eax,%eax
801050a4:	75 d5                	jne    8010507b <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801050a6:	c7 04 24 0c 9e 10 80 	movl   $0x80109e0c,(%esp)
801050ad:	e8 0f b3 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050b2:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
801050b9:	81 7d f0 94 83 11 80 	cmpl   $0x80118394,-0x10(%ebp)
801050c0:	0f 82 d5 fe ff ff    	jb     80104f9b <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801050c6:	c9                   	leave  
801050c7:	c3                   	ret    

801050c8 <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
801050c8:	55                   	push   %ebp
801050c9:	89 e5                	mov    %esp,%ebp
801050cb:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ce:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
801050d5:	eb 37                	jmp    8010510e <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
801050d7:	8b 45 08             	mov    0x8(%ebp),%eax
801050da:	8d 50 18             	lea    0x18(%eax),%edx
801050dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801050e6:	83 c0 18             	add    $0x18,%eax
801050e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801050ed:	89 04 24             	mov    %eax,(%esp)
801050f0:	e8 03 fa ff ff       	call   80104af8 <strcmp1>
801050f5:	85 c0                	test   %eax,%eax
801050f7:	75 0e                	jne    80105107 <cstop_container_helper+0x3f>
      kill(p->pid);
801050f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fc:	8b 40 10             	mov    0x10(%eax),%eax
801050ff:	89 04 24             	mov    %eax,(%esp)
80105102:	e8 07 fe ff ff       	call   80104f0e <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105107:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010510e:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80105115:	72 c0                	jb     801050d7 <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	83 c0 18             	add    $0x18,%eax
8010511d:	89 04 24             	mov    %eax,(%esp)
80105120:	e8 36 41 00 00       	call   8010925b <find>
80105125:	89 04 24             	mov    %eax,(%esp)
80105128:	e8 20 47 00 00       	call   8010984d <container_reset>
}
8010512d:	c9                   	leave  
8010512e:	c3                   	ret    

8010512f <cstop_helper>:

void cstop_helper(char* name){
8010512f:	55                   	push   %ebp
80105130:	89 e5                	mov    %esp,%ebp
80105132:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105135:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
8010513c:	eb 69                	jmp    801051a7 <cstop_helper+0x78>

    if(p->cont == NULL){
8010513e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105141:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105147:	85 c0                	test   %eax,%eax
80105149:	75 02                	jne    8010514d <cstop_helper+0x1e>
      continue;
8010514b:	eb 53                	jmp    801051a0 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
8010514d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105150:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105156:	8d 50 18             	lea    0x18(%eax),%edx
80105159:	8b 45 08             	mov    0x8(%ebp),%eax
8010515c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105160:	89 14 24             	mov    %edx,(%esp)
80105163:	e8 90 f9 ff ff       	call   80104af8 <strcmp1>
80105168:	85 c0                	test   %eax,%eax
8010516a:	75 34                	jne    801051a0 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
8010516c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516f:	8b 40 10             	mov    0x10(%eax),%eax
80105172:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105175:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
8010517b:	83 c2 18             	add    $0x18,%edx
8010517e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105182:	89 54 24 04          	mov    %edx,0x4(%esp)
80105186:	c7 04 24 10 9e 10 80 	movl   $0x80109e10,(%esp)
8010518d:	e8 2f b2 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
80105192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105195:	8b 40 10             	mov    0x10(%eax),%eax
80105198:	89 04 24             	mov    %eax,(%esp)
8010519b:	e8 6e fd ff ff       	call   80104f0e <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051a0:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801051a7:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
801051ae:	72 8e                	jb     8010513e <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
801051b0:	8b 45 08             	mov    0x8(%ebp),%eax
801051b3:	89 04 24             	mov    %eax,(%esp)
801051b6:	e8 a0 40 00 00       	call   8010925b <find>
801051bb:	89 04 24             	mov    %eax,(%esp)
801051be:	e8 8a 46 00 00       	call   8010984d <container_reset>
}
801051c3:	c9                   	leave  
801051c4:	c3                   	ret    

801051c5 <c_procdump>:

void
c_procdump(char* name)
{
801051c5:	55                   	push   %ebp
801051c6:	89 e5                	mov    %esp,%ebp
801051c8:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];



  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051cb:	c7 45 f0 94 62 11 80 	movl   $0x80116294,-0x10(%ebp)
801051d2:	e9 25 01 00 00       	jmp    801052fc <c_procdump+0x137>
    if(p->state == UNUSED || p->cont == NULL)
801051d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051da:	8b 40 0c             	mov    0xc(%eax),%eax
801051dd:	85 c0                	test   %eax,%eax
801051df:	74 0d                	je     801051ee <c_procdump+0x29>
801051e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051ea:	85 c0                	test   %eax,%eax
801051ec:	75 05                	jne    801051f3 <c_procdump+0x2e>
      continue;
801051ee:	e9 02 01 00 00       	jmp    801052f5 <c_procdump+0x130>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f6:	8b 40 0c             	mov    0xc(%eax),%eax
801051f9:	83 f8 05             	cmp    $0x5,%eax
801051fc:	77 23                	ja     80105221 <c_procdump+0x5c>
801051fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105201:	8b 40 0c             	mov    0xc(%eax),%eax
80105204:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
8010520b:	85 c0                	test   %eax,%eax
8010520d:	74 12                	je     80105221 <c_procdump+0x5c>
      state = states[p->state];
8010520f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105212:	8b 40 0c             	mov    0xc(%eax),%eax
80105215:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
8010521c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010521f:	eb 07                	jmp    80105228 <c_procdump+0x63>
    else
      state = "???";
80105221:	c7 45 ec ea 9d 10 80 	movl   $0x80109dea,-0x14(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
80105228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105231:	8d 50 18             	lea    0x18(%eax),%edx
80105234:	8b 45 08             	mov    0x8(%ebp),%eax
80105237:	89 44 24 04          	mov    %eax,0x4(%esp)
8010523b:	89 14 24             	mov    %edx,(%esp)
8010523e:	e8 b5 f8 ff ff       	call   80104af8 <strcmp1>
80105243:	85 c0                	test   %eax,%eax
80105245:	0f 85 aa 00 00 00    	jne    801052f5 <c_procdump+0x130>
      cprintf("STATE: %d \n", p->state);
8010524b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524e:	8b 40 0c             	mov    0xc(%eax),%eax
80105251:	89 44 24 04          	mov    %eax,0x4(%esp)
80105255:	c7 04 24 30 9e 10 80 	movl   $0x80109e30,(%esp)
8010525c:	e8 60 b1 ff ff       	call   801003c1 <cprintf>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
80105261:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105264:	8d 50 6c             	lea    0x6c(%eax),%edx
80105267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010526a:	8b 40 10             	mov    0x10(%eax),%eax
8010526d:	89 54 24 10          	mov    %edx,0x10(%esp)
80105271:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105274:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105278:	8b 55 08             	mov    0x8(%ebp),%edx
8010527b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010527f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105283:	c7 04 24 fc 9d 10 80 	movl   $0x80109dfc,(%esp)
8010528a:	e8 32 b1 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
8010528f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105292:	8b 40 0c             	mov    0xc(%eax),%eax
80105295:	83 f8 02             	cmp    $0x2,%eax
80105298:	75 4f                	jne    801052e9 <c_procdump+0x124>
        getcallerpcs((uint*)p->context->ebp+2, pc);
8010529a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529d:	8b 40 1c             	mov    0x1c(%eax),%eax
801052a0:	8b 40 0c             	mov    0xc(%eax),%eax
801052a3:	83 c0 08             	add    $0x8,%eax
801052a6:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801052a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801052ad:	89 04 24             	mov    %eax,(%esp)
801052b0:	e8 3d 03 00 00       	call   801055f2 <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
801052b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052bc:	eb 1a                	jmp    801052d8 <c_procdump+0x113>
          cprintf(" %p", pc[i]);
801052be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801052c9:	c7 04 24 08 9e 10 80 	movl   $0x80109e08,(%esp)
801052d0:	e8 ec b0 ff ff       	call   801003c1 <cprintf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("STATE: %d \n", p->state);
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
801052d5:	ff 45 f4             	incl   -0xc(%ebp)
801052d8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801052dc:	7f 0b                	jg     801052e9 <c_procdump+0x124>
801052de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052e5:	85 c0                	test   %eax,%eax
801052e7:	75 d5                	jne    801052be <c_procdump+0xf9>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
801052e9:	c7 04 24 0c 9e 10 80 	movl   $0x80109e0c,(%esp)
801052f0:	e8 cc b0 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];



  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052f5:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
801052fc:	81 7d f0 94 83 11 80 	cmpl   $0x80118394,-0x10(%ebp)
80105303:	0f 82 ce fe ff ff    	jb     801051d7 <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
80105309:	c9                   	leave  
8010530a:	c3                   	ret    

8010530b <pause>:

void
pause(char* name)
{
8010530b:	55                   	push   %ebp
8010530c:	89 e5                	mov    %esp,%ebp
8010530e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105311:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
80105318:	eb 49                	jmp    80105363 <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
8010531a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010531d:	8b 40 0c             	mov    0xc(%eax),%eax
80105320:	85 c0                	test   %eax,%eax
80105322:	74 0d                	je     80105331 <pause+0x26>
80105324:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105327:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010532d:	85 c0                	test   %eax,%eax
8010532f:	75 02                	jne    80105333 <pause+0x28>
      continue;
80105331:	eb 29                	jmp    8010535c <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
80105333:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105336:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010533c:	8d 50 18             	lea    0x18(%eax),%edx
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	89 44 24 04          	mov    %eax,0x4(%esp)
80105346:	89 14 24             	mov    %edx,(%esp)
80105349:	e8 aa f7 ff ff       	call   80104af8 <strcmp1>
8010534e:	85 c0                	test   %eax,%eax
80105350:	75 0a                	jne    8010535c <pause+0x51>
      p->state = ZOMBIE;
80105352:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105355:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010535c:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80105363:	81 7d fc 94 83 11 80 	cmpl   $0x80118394,-0x4(%ebp)
8010536a:	72 ae                	jb     8010531a <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = ZOMBIE;
    }
  }
}
8010536c:	c9                   	leave  
8010536d:	c3                   	ret    

8010536e <resume>:

void
resume(char* name)
{
8010536e:	55                   	push   %ebp
8010536f:	89 e5                	mov    %esp,%ebp
80105371:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105374:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
8010537b:	eb 3b                	jmp    801053b8 <resume+0x4a>
    if(p->state == ZOMBIE){
8010537d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105380:	8b 40 0c             	mov    0xc(%eax),%eax
80105383:	83 f8 05             	cmp    $0x5,%eax
80105386:	75 29                	jne    801053b1 <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
80105388:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105391:	8d 50 18             	lea    0x18(%eax),%edx
80105394:	8b 45 08             	mov    0x8(%ebp),%eax
80105397:	89 44 24 04          	mov    %eax,0x4(%esp)
8010539b:	89 14 24             	mov    %edx,(%esp)
8010539e:	e8 55 f7 ff ff       	call   80104af8 <strcmp1>
801053a3:	85 c0                	test   %eax,%eax
801053a5:	75 0a                	jne    801053b1 <resume+0x43>
        p->state = RUNNABLE;
801053a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053aa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053b1:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801053b8:	81 7d fc 94 83 11 80 	cmpl   $0x80118394,-0x4(%ebp)
801053bf:	72 bc                	jb     8010537d <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
801053c1:	c9                   	leave  
801053c2:	c3                   	ret    

801053c3 <initp>:


struct proc* initp(void){
801053c3:	55                   	push   %ebp
801053c4:	89 e5                	mov    %esp,%ebp
  return initproc;
801053c6:	a1 20 d9 10 80       	mov    0x8010d920,%eax
}
801053cb:	5d                   	pop    %ebp
801053cc:	c3                   	ret    

801053cd <c_proc>:

struct proc* c_proc(void){
801053cd:	55                   	push   %ebp
801053ce:	89 e5                	mov    %esp,%ebp
801053d0:	83 ec 08             	sub    $0x8,%esp
  return myproc();
801053d3:	e8 83 f1 ff ff       	call   8010455b <myproc>
}
801053d8:	c9                   	leave  
801053d9:	c3                   	ret    
	...

801053dc <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801053dc:	55                   	push   %ebp
801053dd:	89 e5                	mov    %esp,%ebp
801053df:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
801053e2:	8b 45 08             	mov    0x8(%ebp),%eax
801053e5:	83 c0 04             	add    $0x4,%eax
801053e8:	c7 44 24 04 66 9e 10 	movl   $0x80109e66,0x4(%esp)
801053ef:	80 
801053f0:	89 04 24             	mov    %eax,(%esp)
801053f3:	e8 22 01 00 00       	call   8010551a <initlock>
  lk->name = name;
801053f8:	8b 45 08             	mov    0x8(%ebp),%eax
801053fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801053fe:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
80105404:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010540a:	8b 45 08             	mov    0x8(%ebp),%eax
8010540d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105414:	c9                   	leave  
80105415:	c3                   	ret    

80105416 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105416:	55                   	push   %ebp
80105417:	89 e5                	mov    %esp,%ebp
80105419:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010541c:	8b 45 08             	mov    0x8(%ebp),%eax
8010541f:	83 c0 04             	add    $0x4,%eax
80105422:	89 04 24             	mov    %eax,(%esp)
80105425:	e8 11 01 00 00       	call   8010553b <acquire>
  while (lk->locked) {
8010542a:	eb 15                	jmp    80105441 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
8010542c:	8b 45 08             	mov    0x8(%ebp),%eax
8010542f:	83 c0 04             	add    $0x4,%eax
80105432:	89 44 24 04          	mov    %eax,0x4(%esp)
80105436:	8b 45 08             	mov    0x8(%ebp),%eax
80105439:	89 04 24             	mov    %eax,(%esp)
8010543c:	e8 cb f9 ff ff       	call   80104e0c <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105441:	8b 45 08             	mov    0x8(%ebp),%eax
80105444:	8b 00                	mov    (%eax),%eax
80105446:	85 c0                	test   %eax,%eax
80105448:	75 e2                	jne    8010542c <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010544a:	8b 45 08             	mov    0x8(%ebp),%eax
8010544d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105453:	e8 03 f1 ff ff       	call   8010455b <myproc>
80105458:	8b 50 10             	mov    0x10(%eax),%edx
8010545b:	8b 45 08             	mov    0x8(%ebp),%eax
8010545e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105461:	8b 45 08             	mov    0x8(%ebp),%eax
80105464:	83 c0 04             	add    $0x4,%eax
80105467:	89 04 24             	mov    %eax,(%esp)
8010546a:	e8 36 01 00 00       	call   801055a5 <release>
}
8010546f:	c9                   	leave  
80105470:	c3                   	ret    

80105471 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
80105474:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105477:	8b 45 08             	mov    0x8(%ebp),%eax
8010547a:	83 c0 04             	add    $0x4,%eax
8010547d:	89 04 24             	mov    %eax,(%esp)
80105480:	e8 b6 00 00 00       	call   8010553b <acquire>
  lk->locked = 0;
80105485:	8b 45 08             	mov    0x8(%ebp),%eax
80105488:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010548e:	8b 45 08             	mov    0x8(%ebp),%eax
80105491:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105498:	8b 45 08             	mov    0x8(%ebp),%eax
8010549b:	89 04 24             	mov    %eax,(%esp)
8010549e:	e8 40 fa ff ff       	call   80104ee3 <wakeup>
  release(&lk->lk);
801054a3:	8b 45 08             	mov    0x8(%ebp),%eax
801054a6:	83 c0 04             	add    $0x4,%eax
801054a9:	89 04 24             	mov    %eax,(%esp)
801054ac:	e8 f4 00 00 00       	call   801055a5 <release>
}
801054b1:	c9                   	leave  
801054b2:	c3                   	ret    

801054b3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801054b3:	55                   	push   %ebp
801054b4:	89 e5                	mov    %esp,%ebp
801054b6:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801054b9:	8b 45 08             	mov    0x8(%ebp),%eax
801054bc:	83 c0 04             	add    $0x4,%eax
801054bf:	89 04 24             	mov    %eax,(%esp)
801054c2:	e8 74 00 00 00       	call   8010553b <acquire>
  r = lk->locked;
801054c7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ca:	8b 00                	mov    (%eax),%eax
801054cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801054cf:	8b 45 08             	mov    0x8(%ebp),%eax
801054d2:	83 c0 04             	add    $0x4,%eax
801054d5:	89 04 24             	mov    %eax,(%esp)
801054d8:	e8 c8 00 00 00       	call   801055a5 <release>
  return r;
801054dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801054e0:	c9                   	leave  
801054e1:	c3                   	ret    
	...

801054e4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801054e4:	55                   	push   %ebp
801054e5:	89 e5                	mov    %esp,%ebp
801054e7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801054ea:	9c                   	pushf  
801054eb:	58                   	pop    %eax
801054ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801054ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054f2:	c9                   	leave  
801054f3:	c3                   	ret    

801054f4 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801054f4:	55                   	push   %ebp
801054f5:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801054f7:	fa                   	cli    
}
801054f8:	5d                   	pop    %ebp
801054f9:	c3                   	ret    

801054fa <sti>:

static inline void
sti(void)
{
801054fa:	55                   	push   %ebp
801054fb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801054fd:	fb                   	sti    
}
801054fe:	5d                   	pop    %ebp
801054ff:	c3                   	ret    

80105500 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105500:	55                   	push   %ebp
80105501:	89 e5                	mov    %esp,%ebp
80105503:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105506:	8b 55 08             	mov    0x8(%ebp),%edx
80105509:	8b 45 0c             	mov    0xc(%ebp),%eax
8010550c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010550f:	f0 87 02             	lock xchg %eax,(%edx)
80105512:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105515:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105518:	c9                   	leave  
80105519:	c3                   	ret    

8010551a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010551a:	55                   	push   %ebp
8010551b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	8b 55 0c             	mov    0xc(%ebp),%edx
80105523:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105526:	8b 45 08             	mov    0x8(%ebp),%eax
80105529:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010552f:	8b 45 08             	mov    0x8(%ebp),%eax
80105532:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105539:	5d                   	pop    %ebp
8010553a:	c3                   	ret    

8010553b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010553b:	55                   	push   %ebp
8010553c:	89 e5                	mov    %esp,%ebp
8010553e:	53                   	push   %ebx
8010553f:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105542:	e8 53 01 00 00       	call   8010569a <pushcli>
  if(holding(lk))
80105547:	8b 45 08             	mov    0x8(%ebp),%eax
8010554a:	89 04 24             	mov    %eax,(%esp)
8010554d:	e8 17 01 00 00       	call   80105669 <holding>
80105552:	85 c0                	test   %eax,%eax
80105554:	74 0c                	je     80105562 <acquire+0x27>
    panic("acquire");
80105556:	c7 04 24 71 9e 10 80 	movl   $0x80109e71,(%esp)
8010555d:	e8 f2 af ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105562:	90                   	nop
80105563:	8b 45 08             	mov    0x8(%ebp),%eax
80105566:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010556d:	00 
8010556e:	89 04 24             	mov    %eax,(%esp)
80105571:	e8 8a ff ff ff       	call   80105500 <xchg>
80105576:	85 c0                	test   %eax,%eax
80105578:	75 e9                	jne    80105563 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010557a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010557f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105582:	e8 50 ef ff ff       	call   801044d7 <mycpu>
80105587:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010558a:	8b 45 08             	mov    0x8(%ebp),%eax
8010558d:	83 c0 0c             	add    $0xc,%eax
80105590:	89 44 24 04          	mov    %eax,0x4(%esp)
80105594:	8d 45 08             	lea    0x8(%ebp),%eax
80105597:	89 04 24             	mov    %eax,(%esp)
8010559a:	e8 53 00 00 00       	call   801055f2 <getcallerpcs>
}
8010559f:	83 c4 14             	add    $0x14,%esp
801055a2:	5b                   	pop    %ebx
801055a3:	5d                   	pop    %ebp
801055a4:	c3                   	ret    

801055a5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801055a5:	55                   	push   %ebp
801055a6:	89 e5                	mov    %esp,%ebp
801055a8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801055ab:	8b 45 08             	mov    0x8(%ebp),%eax
801055ae:	89 04 24             	mov    %eax,(%esp)
801055b1:	e8 b3 00 00 00       	call   80105669 <holding>
801055b6:	85 c0                	test   %eax,%eax
801055b8:	75 0c                	jne    801055c6 <release+0x21>
    panic("release");
801055ba:	c7 04 24 79 9e 10 80 	movl   $0x80109e79,(%esp)
801055c1:	e8 8e af ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801055c6:	8b 45 08             	mov    0x8(%ebp),%eax
801055c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801055d0:	8b 45 08             	mov    0x8(%ebp),%eax
801055d3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801055da:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801055df:	8b 45 08             	mov    0x8(%ebp),%eax
801055e2:	8b 55 08             	mov    0x8(%ebp),%edx
801055e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801055eb:	e8 f4 00 00 00       	call   801056e4 <popcli>
}
801055f0:	c9                   	leave  
801055f1:	c3                   	ret    

801055f2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801055f2:	55                   	push   %ebp
801055f3:	89 e5                	mov    %esp,%ebp
801055f5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801055f8:	8b 45 08             	mov    0x8(%ebp),%eax
801055fb:	83 e8 08             	sub    $0x8,%eax
801055fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105601:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105608:	eb 37                	jmp    80105641 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010560a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010560e:	74 37                	je     80105647 <getcallerpcs+0x55>
80105610:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105617:	76 2e                	jbe    80105647 <getcallerpcs+0x55>
80105619:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010561d:	74 28                	je     80105647 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010561f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105622:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562c:	01 c2                	add    %eax,%edx
8010562e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105631:	8b 40 04             	mov    0x4(%eax),%eax
80105634:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105636:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105639:	8b 00                	mov    (%eax),%eax
8010563b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010563e:	ff 45 f8             	incl   -0x8(%ebp)
80105641:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105645:	7e c3                	jle    8010560a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105647:	eb 18                	jmp    80105661 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105649:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010564c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105653:	8b 45 0c             	mov    0xc(%ebp),%eax
80105656:	01 d0                	add    %edx,%eax
80105658:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010565e:	ff 45 f8             	incl   -0x8(%ebp)
80105661:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105665:	7e e2                	jle    80105649 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105667:	c9                   	leave  
80105668:	c3                   	ret    

80105669 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105669:	55                   	push   %ebp
8010566a:	89 e5                	mov    %esp,%ebp
8010566c:	53                   	push   %ebx
8010566d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105670:	8b 45 08             	mov    0x8(%ebp),%eax
80105673:	8b 00                	mov    (%eax),%eax
80105675:	85 c0                	test   %eax,%eax
80105677:	74 16                	je     8010568f <holding+0x26>
80105679:	8b 45 08             	mov    0x8(%ebp),%eax
8010567c:	8b 58 08             	mov    0x8(%eax),%ebx
8010567f:	e8 53 ee ff ff       	call   801044d7 <mycpu>
80105684:	39 c3                	cmp    %eax,%ebx
80105686:	75 07                	jne    8010568f <holding+0x26>
80105688:	b8 01 00 00 00       	mov    $0x1,%eax
8010568d:	eb 05                	jmp    80105694 <holding+0x2b>
8010568f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105694:	83 c4 04             	add    $0x4,%esp
80105697:	5b                   	pop    %ebx
80105698:	5d                   	pop    %ebp
80105699:	c3                   	ret    

8010569a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010569a:	55                   	push   %ebp
8010569b:	89 e5                	mov    %esp,%ebp
8010569d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801056a0:	e8 3f fe ff ff       	call   801054e4 <readeflags>
801056a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801056a8:	e8 47 fe ff ff       	call   801054f4 <cli>
  if(mycpu()->ncli == 0)
801056ad:	e8 25 ee ff ff       	call   801044d7 <mycpu>
801056b2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056b8:	85 c0                	test   %eax,%eax
801056ba:	75 14                	jne    801056d0 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801056bc:	e8 16 ee ff ff       	call   801044d7 <mycpu>
801056c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056c4:	81 e2 00 02 00 00    	and    $0x200,%edx
801056ca:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801056d0:	e8 02 ee ff ff       	call   801044d7 <mycpu>
801056d5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801056db:	42                   	inc    %edx
801056dc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801056e2:	c9                   	leave  
801056e3:	c3                   	ret    

801056e4 <popcli>:

void
popcli(void)
{
801056e4:	55                   	push   %ebp
801056e5:	89 e5                	mov    %esp,%ebp
801056e7:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801056ea:	e8 f5 fd ff ff       	call   801054e4 <readeflags>
801056ef:	25 00 02 00 00       	and    $0x200,%eax
801056f4:	85 c0                	test   %eax,%eax
801056f6:	74 0c                	je     80105704 <popcli+0x20>
    panic("popcli - interruptible");
801056f8:	c7 04 24 81 9e 10 80 	movl   $0x80109e81,(%esp)
801056ff:	e8 50 ae ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105704:	e8 ce ed ff ff       	call   801044d7 <mycpu>
80105709:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010570f:	4a                   	dec    %edx
80105710:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105716:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010571c:	85 c0                	test   %eax,%eax
8010571e:	79 0c                	jns    8010572c <popcli+0x48>
    panic("popcli");
80105720:	c7 04 24 98 9e 10 80 	movl   $0x80109e98,(%esp)
80105727:	e8 28 ae ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010572c:	e8 a6 ed ff ff       	call   801044d7 <mycpu>
80105731:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105737:	85 c0                	test   %eax,%eax
80105739:	75 14                	jne    8010574f <popcli+0x6b>
8010573b:	e8 97 ed ff ff       	call   801044d7 <mycpu>
80105740:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105746:	85 c0                	test   %eax,%eax
80105748:	74 05                	je     8010574f <popcli+0x6b>
    sti();
8010574a:	e8 ab fd ff ff       	call   801054fa <sti>
}
8010574f:	c9                   	leave  
80105750:	c3                   	ret    
80105751:	00 00                	add    %al,(%eax)
	...

80105754 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105754:	55                   	push   %ebp
80105755:	89 e5                	mov    %esp,%ebp
80105757:	57                   	push   %edi
80105758:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105759:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010575c:	8b 55 10             	mov    0x10(%ebp),%edx
8010575f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105762:	89 cb                	mov    %ecx,%ebx
80105764:	89 df                	mov    %ebx,%edi
80105766:	89 d1                	mov    %edx,%ecx
80105768:	fc                   	cld    
80105769:	f3 aa                	rep stos %al,%es:(%edi)
8010576b:	89 ca                	mov    %ecx,%edx
8010576d:	89 fb                	mov    %edi,%ebx
8010576f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105772:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105775:	5b                   	pop    %ebx
80105776:	5f                   	pop    %edi
80105777:	5d                   	pop    %ebp
80105778:	c3                   	ret    

80105779 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105779:	55                   	push   %ebp
8010577a:	89 e5                	mov    %esp,%ebp
8010577c:	57                   	push   %edi
8010577d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010577e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105781:	8b 55 10             	mov    0x10(%ebp),%edx
80105784:	8b 45 0c             	mov    0xc(%ebp),%eax
80105787:	89 cb                	mov    %ecx,%ebx
80105789:	89 df                	mov    %ebx,%edi
8010578b:	89 d1                	mov    %edx,%ecx
8010578d:	fc                   	cld    
8010578e:	f3 ab                	rep stos %eax,%es:(%edi)
80105790:	89 ca                	mov    %ecx,%edx
80105792:	89 fb                	mov    %edi,%ebx
80105794:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105797:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010579a:	5b                   	pop    %ebx
8010579b:	5f                   	pop    %edi
8010579c:	5d                   	pop    %ebp
8010579d:	c3                   	ret    

8010579e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010579e:	55                   	push   %ebp
8010579f:	89 e5                	mov    %esp,%ebp
801057a1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801057a4:	8b 45 08             	mov    0x8(%ebp),%eax
801057a7:	83 e0 03             	and    $0x3,%eax
801057aa:	85 c0                	test   %eax,%eax
801057ac:	75 49                	jne    801057f7 <memset+0x59>
801057ae:	8b 45 10             	mov    0x10(%ebp),%eax
801057b1:	83 e0 03             	and    $0x3,%eax
801057b4:	85 c0                	test   %eax,%eax
801057b6:	75 3f                	jne    801057f7 <memset+0x59>
    c &= 0xFF;
801057b8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801057bf:	8b 45 10             	mov    0x10(%ebp),%eax
801057c2:	c1 e8 02             	shr    $0x2,%eax
801057c5:	89 c2                	mov    %eax,%edx
801057c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ca:	c1 e0 18             	shl    $0x18,%eax
801057cd:	89 c1                	mov    %eax,%ecx
801057cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d2:	c1 e0 10             	shl    $0x10,%eax
801057d5:	09 c1                	or     %eax,%ecx
801057d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057da:	c1 e0 08             	shl    $0x8,%eax
801057dd:	09 c8                	or     %ecx,%eax
801057df:	0b 45 0c             	or     0xc(%ebp),%eax
801057e2:	89 54 24 08          	mov    %edx,0x8(%esp)
801057e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801057ea:	8b 45 08             	mov    0x8(%ebp),%eax
801057ed:	89 04 24             	mov    %eax,(%esp)
801057f0:	e8 84 ff ff ff       	call   80105779 <stosl>
801057f5:	eb 19                	jmp    80105810 <memset+0x72>
  } else
    stosb(dst, c, n);
801057f7:	8b 45 10             	mov    0x10(%ebp),%eax
801057fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801057fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105801:	89 44 24 04          	mov    %eax,0x4(%esp)
80105805:	8b 45 08             	mov    0x8(%ebp),%eax
80105808:	89 04 24             	mov    %eax,(%esp)
8010580b:	e8 44 ff ff ff       	call   80105754 <stosb>
  return dst;
80105810:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105813:	c9                   	leave  
80105814:	c3                   	ret    

80105815 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105815:	55                   	push   %ebp
80105816:	89 e5                	mov    %esp,%ebp
80105818:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010581b:	8b 45 08             	mov    0x8(%ebp),%eax
8010581e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105821:	8b 45 0c             	mov    0xc(%ebp),%eax
80105824:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105827:	eb 2a                	jmp    80105853 <memcmp+0x3e>
    if(*s1 != *s2)
80105829:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010582c:	8a 10                	mov    (%eax),%dl
8010582e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105831:	8a 00                	mov    (%eax),%al
80105833:	38 c2                	cmp    %al,%dl
80105835:	74 16                	je     8010584d <memcmp+0x38>
      return *s1 - *s2;
80105837:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010583a:	8a 00                	mov    (%eax),%al
8010583c:	0f b6 d0             	movzbl %al,%edx
8010583f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105842:	8a 00                	mov    (%eax),%al
80105844:	0f b6 c0             	movzbl %al,%eax
80105847:	29 c2                	sub    %eax,%edx
80105849:	89 d0                	mov    %edx,%eax
8010584b:	eb 18                	jmp    80105865 <memcmp+0x50>
    s1++, s2++;
8010584d:	ff 45 fc             	incl   -0x4(%ebp)
80105850:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105853:	8b 45 10             	mov    0x10(%ebp),%eax
80105856:	8d 50 ff             	lea    -0x1(%eax),%edx
80105859:	89 55 10             	mov    %edx,0x10(%ebp)
8010585c:	85 c0                	test   %eax,%eax
8010585e:	75 c9                	jne    80105829 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105860:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105865:	c9                   	leave  
80105866:	c3                   	ret    

80105867 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105867:	55                   	push   %ebp
80105868:	89 e5                	mov    %esp,%ebp
8010586a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010586d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105870:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105873:	8b 45 08             	mov    0x8(%ebp),%eax
80105876:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105879:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010587c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010587f:	73 3a                	jae    801058bb <memmove+0x54>
80105881:	8b 45 10             	mov    0x10(%ebp),%eax
80105884:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105887:	01 d0                	add    %edx,%eax
80105889:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010588c:	76 2d                	jbe    801058bb <memmove+0x54>
    s += n;
8010588e:	8b 45 10             	mov    0x10(%ebp),%eax
80105891:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105894:	8b 45 10             	mov    0x10(%ebp),%eax
80105897:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010589a:	eb 10                	jmp    801058ac <memmove+0x45>
      *--d = *--s;
8010589c:	ff 4d f8             	decl   -0x8(%ebp)
8010589f:	ff 4d fc             	decl   -0x4(%ebp)
801058a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058a5:	8a 10                	mov    (%eax),%dl
801058a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058aa:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801058ac:	8b 45 10             	mov    0x10(%ebp),%eax
801058af:	8d 50 ff             	lea    -0x1(%eax),%edx
801058b2:	89 55 10             	mov    %edx,0x10(%ebp)
801058b5:	85 c0                	test   %eax,%eax
801058b7:	75 e3                	jne    8010589c <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801058b9:	eb 25                	jmp    801058e0 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801058bb:	eb 16                	jmp    801058d3 <memmove+0x6c>
      *d++ = *s++;
801058bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058c0:	8d 50 01             	lea    0x1(%eax),%edx
801058c3:	89 55 f8             	mov    %edx,-0x8(%ebp)
801058c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058c9:	8d 4a 01             	lea    0x1(%edx),%ecx
801058cc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801058cf:	8a 12                	mov    (%edx),%dl
801058d1:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801058d3:	8b 45 10             	mov    0x10(%ebp),%eax
801058d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801058d9:	89 55 10             	mov    %edx,0x10(%ebp)
801058dc:	85 c0                	test   %eax,%eax
801058de:	75 dd                	jne    801058bd <memmove+0x56>
      *d++ = *s++;

  return dst;
801058e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801058e3:	c9                   	leave  
801058e4:	c3                   	ret    

801058e5 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801058e5:	55                   	push   %ebp
801058e6:	89 e5                	mov    %esp,%ebp
801058e8:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801058eb:	8b 45 10             	mov    0x10(%ebp),%eax
801058ee:	89 44 24 08          	mov    %eax,0x8(%esp)
801058f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f9:	8b 45 08             	mov    0x8(%ebp),%eax
801058fc:	89 04 24             	mov    %eax,(%esp)
801058ff:	e8 63 ff ff ff       	call   80105867 <memmove>
}
80105904:	c9                   	leave  
80105905:	c3                   	ret    

80105906 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105906:	55                   	push   %ebp
80105907:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105909:	eb 09                	jmp    80105914 <strncmp+0xe>
    n--, p++, q++;
8010590b:	ff 4d 10             	decl   0x10(%ebp)
8010590e:	ff 45 08             	incl   0x8(%ebp)
80105911:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105914:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105918:	74 17                	je     80105931 <strncmp+0x2b>
8010591a:	8b 45 08             	mov    0x8(%ebp),%eax
8010591d:	8a 00                	mov    (%eax),%al
8010591f:	84 c0                	test   %al,%al
80105921:	74 0e                	je     80105931 <strncmp+0x2b>
80105923:	8b 45 08             	mov    0x8(%ebp),%eax
80105926:	8a 10                	mov    (%eax),%dl
80105928:	8b 45 0c             	mov    0xc(%ebp),%eax
8010592b:	8a 00                	mov    (%eax),%al
8010592d:	38 c2                	cmp    %al,%dl
8010592f:	74 da                	je     8010590b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105931:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105935:	75 07                	jne    8010593e <strncmp+0x38>
    return 0;
80105937:	b8 00 00 00 00       	mov    $0x0,%eax
8010593c:	eb 14                	jmp    80105952 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010593e:	8b 45 08             	mov    0x8(%ebp),%eax
80105941:	8a 00                	mov    (%eax),%al
80105943:	0f b6 d0             	movzbl %al,%edx
80105946:	8b 45 0c             	mov    0xc(%ebp),%eax
80105949:	8a 00                	mov    (%eax),%al
8010594b:	0f b6 c0             	movzbl %al,%eax
8010594e:	29 c2                	sub    %eax,%edx
80105950:	89 d0                	mov    %edx,%eax
}
80105952:	5d                   	pop    %ebp
80105953:	c3                   	ret    

80105954 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105954:	55                   	push   %ebp
80105955:	89 e5                	mov    %esp,%ebp
80105957:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010595a:	8b 45 08             	mov    0x8(%ebp),%eax
8010595d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105960:	90                   	nop
80105961:	8b 45 10             	mov    0x10(%ebp),%eax
80105964:	8d 50 ff             	lea    -0x1(%eax),%edx
80105967:	89 55 10             	mov    %edx,0x10(%ebp)
8010596a:	85 c0                	test   %eax,%eax
8010596c:	7e 1c                	jle    8010598a <strncpy+0x36>
8010596e:	8b 45 08             	mov    0x8(%ebp),%eax
80105971:	8d 50 01             	lea    0x1(%eax),%edx
80105974:	89 55 08             	mov    %edx,0x8(%ebp)
80105977:	8b 55 0c             	mov    0xc(%ebp),%edx
8010597a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010597d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105980:	8a 12                	mov    (%edx),%dl
80105982:	88 10                	mov    %dl,(%eax)
80105984:	8a 00                	mov    (%eax),%al
80105986:	84 c0                	test   %al,%al
80105988:	75 d7                	jne    80105961 <strncpy+0xd>
    ;
  while(n-- > 0)
8010598a:	eb 0c                	jmp    80105998 <strncpy+0x44>
    *s++ = 0;
8010598c:	8b 45 08             	mov    0x8(%ebp),%eax
8010598f:	8d 50 01             	lea    0x1(%eax),%edx
80105992:	89 55 08             	mov    %edx,0x8(%ebp)
80105995:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105998:	8b 45 10             	mov    0x10(%ebp),%eax
8010599b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010599e:	89 55 10             	mov    %edx,0x10(%ebp)
801059a1:	85 c0                	test   %eax,%eax
801059a3:	7f e7                	jg     8010598c <strncpy+0x38>
    *s++ = 0;
  return os;
801059a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059a8:	c9                   	leave  
801059a9:	c3                   	ret    

801059aa <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801059aa:	55                   	push   %ebp
801059ab:	89 e5                	mov    %esp,%ebp
801059ad:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801059b0:	8b 45 08             	mov    0x8(%ebp),%eax
801059b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801059b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059ba:	7f 05                	jg     801059c1 <safestrcpy+0x17>
    return os;
801059bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059bf:	eb 2e                	jmp    801059ef <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801059c1:	ff 4d 10             	decl   0x10(%ebp)
801059c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059c8:	7e 1c                	jle    801059e6 <safestrcpy+0x3c>
801059ca:	8b 45 08             	mov    0x8(%ebp),%eax
801059cd:	8d 50 01             	lea    0x1(%eax),%edx
801059d0:	89 55 08             	mov    %edx,0x8(%ebp)
801059d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801059d6:	8d 4a 01             	lea    0x1(%edx),%ecx
801059d9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801059dc:	8a 12                	mov    (%edx),%dl
801059de:	88 10                	mov    %dl,(%eax)
801059e0:	8a 00                	mov    (%eax),%al
801059e2:	84 c0                	test   %al,%al
801059e4:	75 db                	jne    801059c1 <safestrcpy+0x17>
    ;
  *s = 0;
801059e6:	8b 45 08             	mov    0x8(%ebp),%eax
801059e9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801059ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059ef:	c9                   	leave  
801059f0:	c3                   	ret    

801059f1 <strlen>:

int
strlen(const char *s)
{
801059f1:	55                   	push   %ebp
801059f2:	89 e5                	mov    %esp,%ebp
801059f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801059f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059fe:	eb 03                	jmp    80105a03 <strlen+0x12>
80105a00:	ff 45 fc             	incl   -0x4(%ebp)
80105a03:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a06:	8b 45 08             	mov    0x8(%ebp),%eax
80105a09:	01 d0                	add    %edx,%eax
80105a0b:	8a 00                	mov    (%eax),%al
80105a0d:	84 c0                	test   %al,%al
80105a0f:	75 ef                	jne    80105a00 <strlen+0xf>
    ;
  return n;
80105a11:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a14:	c9                   	leave  
80105a15:	c3                   	ret    
	...

80105a18 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105a18:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105a1c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105a20:	55                   	push   %ebp
  pushl %ebx
80105a21:	53                   	push   %ebx
  pushl %esi
80105a22:	56                   	push   %esi
  pushl %edi
80105a23:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105a24:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105a26:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105a28:	5f                   	pop    %edi
  popl %esi
80105a29:	5e                   	pop    %esi
  popl %ebx
80105a2a:	5b                   	pop    %ebx
  popl %ebp
80105a2b:	5d                   	pop    %ebp
  ret
80105a2c:	c3                   	ret    
80105a2d:	00 00                	add    %al,(%eax)
	...

80105a30 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105a30:	55                   	push   %ebp
80105a31:	89 e5                	mov    %esp,%ebp
80105a33:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105a36:	e8 20 eb ff ff       	call   8010455b <myproc>
80105a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a41:	8b 00                	mov    (%eax),%eax
80105a43:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a46:	76 0f                	jbe    80105a57 <fetchint+0x27>
80105a48:	8b 45 08             	mov    0x8(%ebp),%eax
80105a4b:	8d 50 04             	lea    0x4(%eax),%edx
80105a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a51:	8b 00                	mov    (%eax),%eax
80105a53:	39 c2                	cmp    %eax,%edx
80105a55:	76 07                	jbe    80105a5e <fetchint+0x2e>
    return -1;
80105a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5c:	eb 0f                	jmp    80105a6d <fetchint+0x3d>
  *ip = *(int*)(addr);
80105a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a61:	8b 10                	mov    (%eax),%edx
80105a63:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a66:	89 10                	mov    %edx,(%eax)
  return 0;
80105a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a6d:	c9                   	leave  
80105a6e:	c3                   	ret    

80105a6f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105a6f:	55                   	push   %ebp
80105a70:	89 e5                	mov    %esp,%ebp
80105a72:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105a75:	e8 e1 ea ff ff       	call   8010455b <myproc>
80105a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a80:	8b 00                	mov    (%eax),%eax
80105a82:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a85:	77 07                	ja     80105a8e <fetchstr+0x1f>
    return -1;
80105a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8c:	eb 41                	jmp    80105acf <fetchstr+0x60>
  *pp = (char*)addr;
80105a8e:	8b 55 08             	mov    0x8(%ebp),%edx
80105a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a94:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a99:	8b 00                	mov    (%eax),%eax
80105a9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aa1:	8b 00                	mov    (%eax),%eax
80105aa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aa6:	eb 1a                	jmp    80105ac2 <fetchstr+0x53>
    if(*s == 0)
80105aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aab:	8a 00                	mov    (%eax),%al
80105aad:	84 c0                	test   %al,%al
80105aaf:	75 0e                	jne    80105abf <fetchstr+0x50>
      return s - *pp;
80105ab1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab7:	8b 00                	mov    (%eax),%eax
80105ab9:	29 c2                	sub    %eax,%edx
80105abb:	89 d0                	mov    %edx,%eax
80105abd:	eb 10                	jmp    80105acf <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105abf:	ff 45 f4             	incl   -0xc(%ebp)
80105ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105ac8:	72 de                	jb     80105aa8 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105aca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105acf:	c9                   	leave  
80105ad0:	c3                   	ret    

80105ad1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105ad1:	55                   	push   %ebp
80105ad2:	89 e5                	mov    %esp,%ebp
80105ad4:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105ad7:	e8 7f ea ff ff       	call   8010455b <myproc>
80105adc:	8b 40 18             	mov    0x18(%eax),%eax
80105adf:	8b 50 44             	mov    0x44(%eax),%edx
80105ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae5:	c1 e0 02             	shl    $0x2,%eax
80105ae8:	01 d0                	add    %edx,%eax
80105aea:	8d 50 04             	lea    0x4(%eax),%edx
80105aed:	8b 45 0c             	mov    0xc(%ebp),%eax
80105af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af4:	89 14 24             	mov    %edx,(%esp)
80105af7:	e8 34 ff ff ff       	call   80105a30 <fetchint>
}
80105afc:	c9                   	leave  
80105afd:	c3                   	ret    

80105afe <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105afe:	55                   	push   %ebp
80105aff:	89 e5                	mov    %esp,%ebp
80105b01:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105b04:	e8 52 ea ff ff       	call   8010455b <myproc>
80105b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105b0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b13:	8b 45 08             	mov    0x8(%ebp),%eax
80105b16:	89 04 24             	mov    %eax,(%esp)
80105b19:	e8 b3 ff ff ff       	call   80105ad1 <argint>
80105b1e:	85 c0                	test   %eax,%eax
80105b20:	79 07                	jns    80105b29 <argptr+0x2b>
    return -1;
80105b22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b27:	eb 3d                	jmp    80105b66 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105b29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b2d:	78 21                	js     80105b50 <argptr+0x52>
80105b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b32:	89 c2                	mov    %eax,%edx
80105b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b37:	8b 00                	mov    (%eax),%eax
80105b39:	39 c2                	cmp    %eax,%edx
80105b3b:	73 13                	jae    80105b50 <argptr+0x52>
80105b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b40:	89 c2                	mov    %eax,%edx
80105b42:	8b 45 10             	mov    0x10(%ebp),%eax
80105b45:	01 c2                	add    %eax,%edx
80105b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4a:	8b 00                	mov    (%eax),%eax
80105b4c:	39 c2                	cmp    %eax,%edx
80105b4e:	76 07                	jbe    80105b57 <argptr+0x59>
    return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b55:	eb 0f                	jmp    80105b66 <argptr+0x68>
  *pp = (char*)i;
80105b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5a:	89 c2                	mov    %eax,%edx
80105b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b5f:	89 10                	mov    %edx,(%eax)
  return 0;
80105b61:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b66:	c9                   	leave  
80105b67:	c3                   	ret    

80105b68 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105b68:	55                   	push   %ebp
80105b69:	89 e5                	mov    %esp,%ebp
80105b6b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105b6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b75:	8b 45 08             	mov    0x8(%ebp),%eax
80105b78:	89 04 24             	mov    %eax,(%esp)
80105b7b:	e8 51 ff ff ff       	call   80105ad1 <argint>
80105b80:	85 c0                	test   %eax,%eax
80105b82:	79 07                	jns    80105b8b <argstr+0x23>
    return -1;
80105b84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b89:	eb 12                	jmp    80105b9d <argstr+0x35>
  return fetchstr(addr, pp);
80105b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b91:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b95:	89 04 24             	mov    %eax,(%esp)
80105b98:	e8 d2 fe ff ff       	call   80105a6f <fetchstr>
}
80105b9d:	c9                   	leave  
80105b9e:	c3                   	ret    

80105b9f <syscall>:
[SYS_amem] sys_amem,
};

void
syscall(void)
{
80105b9f:	55                   	push   %ebp
80105ba0:	89 e5                	mov    %esp,%ebp
80105ba2:	53                   	push   %ebx
80105ba3:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105ba6:	e8 b0 e9 ff ff       	call   8010455b <myproc>
80105bab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb1:	8b 40 18             	mov    0x18(%eax),%eax
80105bb4:	8b 40 1c             	mov    0x1c(%eax),%eax
80105bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105bba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bbe:	7e 2d                	jle    80105bed <syscall+0x4e>
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	83 f8 33             	cmp    $0x33,%eax
80105bc6:	77 25                	ja     80105bed <syscall+0x4e>
80105bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcb:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105bd2:	85 c0                	test   %eax,%eax
80105bd4:	74 17                	je     80105bed <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd9:	8b 58 18             	mov    0x18(%eax),%ebx
80105bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdf:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105be6:	ff d0                	call   *%eax
80105be8:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105beb:	eb 34                	jmp    80105c21 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf6:	8b 40 10             	mov    0x10(%eax),%eax
80105bf9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bfc:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105c00:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c04:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c08:	c7 04 24 9f 9e 10 80 	movl   $0x80109e9f,(%esp)
80105c0f:	e8 ad a7 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c17:	8b 40 18             	mov    0x18(%eax),%eax
80105c1a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105c21:	83 c4 24             	add    $0x24,%esp
80105c24:	5b                   	pop    %ebx
80105c25:	5d                   	pop    %ebp
80105c26:	c3                   	ret    
	...

80105c28 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105c28:	55                   	push   %ebp
80105c29:	89 e5                	mov    %esp,%ebp
80105c2b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105c2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c31:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c35:	8b 45 08             	mov    0x8(%ebp),%eax
80105c38:	89 04 24             	mov    %eax,(%esp)
80105c3b:	e8 91 fe ff ff       	call   80105ad1 <argint>
80105c40:	85 c0                	test   %eax,%eax
80105c42:	79 07                	jns    80105c4b <argfd+0x23>
    return -1;
80105c44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c49:	eb 4f                	jmp    80105c9a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4e:	85 c0                	test   %eax,%eax
80105c50:	78 20                	js     80105c72 <argfd+0x4a>
80105c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c55:	83 f8 0f             	cmp    $0xf,%eax
80105c58:	7f 18                	jg     80105c72 <argfd+0x4a>
80105c5a:	e8 fc e8 ff ff       	call   8010455b <myproc>
80105c5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c62:	83 c2 08             	add    $0x8,%edx
80105c65:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c70:	75 07                	jne    80105c79 <argfd+0x51>
    return -1;
80105c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c77:	eb 21                	jmp    80105c9a <argfd+0x72>
  if(pfd)
80105c79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105c7d:	74 08                	je     80105c87 <argfd+0x5f>
    *pfd = fd;
80105c7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c82:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c85:	89 10                	mov    %edx,(%eax)
  if(pf)
80105c87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c8b:	74 08                	je     80105c95 <argfd+0x6d>
    *pf = f;
80105c8d:	8b 45 10             	mov    0x10(%ebp),%eax
80105c90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c93:	89 10                	mov    %edx,(%eax)
  return 0;
80105c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c9a:	c9                   	leave  
80105c9b:	c3                   	ret    

80105c9c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c9c:	55                   	push   %ebp
80105c9d:	89 e5                	mov    %esp,%ebp
80105c9f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ca2:	e8 b4 e8 ff ff       	call   8010455b <myproc>
80105ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105caa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105cb1:	eb 29                	jmp    80105cdc <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cb9:	83 c2 08             	add    $0x8,%edx
80105cbc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105cc0:	85 c0                	test   %eax,%eax
80105cc2:	75 15                	jne    80105cd9 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cca:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ccd:	8b 55 08             	mov    0x8(%ebp),%edx
80105cd0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd7:	eb 0e                	jmp    80105ce7 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105cd9:	ff 45 f4             	incl   -0xc(%ebp)
80105cdc:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105ce0:	7e d1                	jle    80105cb3 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ce7:	c9                   	leave  
80105ce8:	c3                   	ret    

80105ce9 <sys_dup>:

int
sys_dup(void)
{
80105ce9:	55                   	push   %ebp
80105cea:	89 e5                	mov    %esp,%ebp
80105cec:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105cef:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cfd:	00 
80105cfe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d05:	e8 1e ff ff ff       	call   80105c28 <argfd>
80105d0a:	85 c0                	test   %eax,%eax
80105d0c:	79 07                	jns    80105d15 <sys_dup+0x2c>
    return -1;
80105d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d13:	eb 29                	jmp    80105d3e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d18:	89 04 24             	mov    %eax,(%esp)
80105d1b:	e8 7c ff ff ff       	call   80105c9c <fdalloc>
80105d20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d27:	79 07                	jns    80105d30 <sys_dup+0x47>
    return -1;
80105d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2e:	eb 0e                	jmp    80105d3e <sys_dup+0x55>
  filedup(f);
80105d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d33:	89 04 24             	mov    %eax,(%esp)
80105d36:	e8 27 b4 ff ff       	call   80101162 <filedup>
  return fd;
80105d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d3e:	c9                   	leave  
80105d3f:	c3                   	ret    

80105d40 <sys_read>:

int
sys_read(void)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
80105d43:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d49:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d54:	00 
80105d55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d5c:	e8 c7 fe ff ff       	call   80105c28 <argfd>
80105d61:	85 c0                	test   %eax,%eax
80105d63:	78 35                	js     80105d9a <sys_read+0x5a>
80105d65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d73:	e8 59 fd ff ff       	call   80105ad1 <argint>
80105d78:	85 c0                	test   %eax,%eax
80105d7a:	78 1e                	js     80105d9a <sys_read+0x5a>
80105d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d83:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d91:	e8 68 fd ff ff       	call   80105afe <argptr>
80105d96:	85 c0                	test   %eax,%eax
80105d98:	79 07                	jns    80105da1 <sys_read+0x61>
    return -1;
80105d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9f:	eb 19                	jmp    80105dba <sys_read+0x7a>
  return fileread(f, p, n);
80105da1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105da4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105dae:	89 54 24 04          	mov    %edx,0x4(%esp)
80105db2:	89 04 24             	mov    %eax,(%esp)
80105db5:	e8 09 b5 ff ff       	call   801012c3 <fileread>
}
80105dba:	c9                   	leave  
80105dbb:	c3                   	ret    

80105dbc <sys_write>:

int
sys_write(void)
{
80105dbc:	55                   	push   %ebp
80105dbd:	89 e5                	mov    %esp,%ebp
80105dbf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105dc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dc5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105dd0:	00 
80105dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dd8:	e8 4b fe ff ff       	call   80105c28 <argfd>
80105ddd:	85 c0                	test   %eax,%eax
80105ddf:	78 35                	js     80105e16 <sys_write+0x5a>
80105de1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105de4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105def:	e8 dd fc ff ff       	call   80105ad1 <argint>
80105df4:	85 c0                	test   %eax,%eax
80105df6:	78 1e                	js     80105e16 <sys_write+0x5a>
80105df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e0d:	e8 ec fc ff ff       	call   80105afe <argptr>
80105e12:	85 c0                	test   %eax,%eax
80105e14:	79 07                	jns    80105e1d <sys_write+0x61>
    return -1;
80105e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1b:	eb 19                	jmp    80105e36 <sys_write+0x7a>
  return filewrite(f, p, n);
80105e1d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105e20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e2a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e2e:	89 04 24             	mov    %eax,(%esp)
80105e31:	e8 48 b5 ff ff       	call   8010137e <filewrite>
}
80105e36:	c9                   	leave  
80105e37:	c3                   	ret    

80105e38 <sys_close>:

int
sys_close(void)
{
80105e38:	55                   	push   %ebp
80105e39:	89 e5                	mov    %esp,%ebp
80105e3b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105e3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e41:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e45:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e53:	e8 d0 fd ff ff       	call   80105c28 <argfd>
80105e58:	85 c0                	test   %eax,%eax
80105e5a:	79 07                	jns    80105e63 <sys_close+0x2b>
    return -1;
80105e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e61:	eb 23                	jmp    80105e86 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105e63:	e8 f3 e6 ff ff       	call   8010455b <myproc>
80105e68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e6b:	83 c2 08             	add    $0x8,%edx
80105e6e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105e75:	00 
  fileclose(f);
80105e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e79:	89 04 24             	mov    %eax,(%esp)
80105e7c:	e8 29 b3 ff ff       	call   801011aa <fileclose>
  return 0;
80105e81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e86:	c9                   	leave  
80105e87:	c3                   	ret    

80105e88 <sys_fstat>:

int
sys_fstat(void)
{
80105e88:	55                   	push   %ebp
80105e89:	89 e5                	mov    %esp,%ebp
80105e8b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e91:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e9c:	00 
80105e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ea4:	e8 7f fd ff ff       	call   80105c28 <argfd>
80105ea9:	85 c0                	test   %eax,%eax
80105eab:	78 1f                	js     80105ecc <sys_fstat+0x44>
80105ead:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105eb4:	00 
80105eb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ebc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ec3:	e8 36 fc ff ff       	call   80105afe <argptr>
80105ec8:	85 c0                	test   %eax,%eax
80105eca:	79 07                	jns    80105ed3 <sys_fstat+0x4b>
    return -1;
80105ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed1:	eb 12                	jmp    80105ee5 <sys_fstat+0x5d>
  return filestat(f, st);
80105ed3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105edd:	89 04 24             	mov    %eax,(%esp)
80105ee0:	e8 8f b3 ff ff       	call   80101274 <filestat>
}
80105ee5:	c9                   	leave  
80105ee6:	c3                   	ret    

80105ee7 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ee7:	55                   	push   %ebp
80105ee8:	89 e5                	mov    %esp,%ebp
80105eea:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105eed:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105efb:	e8 68 fc ff ff       	call   80105b68 <argstr>
80105f00:	85 c0                	test   %eax,%eax
80105f02:	78 17                	js     80105f1b <sys_link+0x34>
80105f04:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105f07:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f12:	e8 51 fc ff ff       	call   80105b68 <argstr>
80105f17:	85 c0                	test   %eax,%eax
80105f19:	79 0a                	jns    80105f25 <sys_link+0x3e>
    return -1;
80105f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f20:	e9 3d 01 00 00       	jmp    80106062 <sys_link+0x17b>

  begin_op();
80105f25:	e8 09 d9 ff ff       	call   80103833 <begin_op>
  if((ip = namei(old)) == 0){
80105f2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105f2d:	89 04 24             	mov    %eax,(%esp)
80105f30:	e8 23 c8 ff ff       	call   80102758 <namei>
80105f35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f3c:	75 0f                	jne    80105f4d <sys_link+0x66>
    end_op();
80105f3e:	e8 72 d9 ff ff       	call   801038b5 <end_op>
    return -1;
80105f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f48:	e9 15 01 00 00       	jmp    80106062 <sys_link+0x17b>
  }

  ilock(ip);
80105f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f50:	89 04 24             	mov    %eax,(%esp)
80105f53:	e8 6a bb ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5b:	8b 40 50             	mov    0x50(%eax),%eax
80105f5e:	66 83 f8 01          	cmp    $0x1,%ax
80105f62:	75 1a                	jne    80105f7e <sys_link+0x97>
    iunlockput(ip);
80105f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f67:	89 04 24             	mov    %eax,(%esp)
80105f6a:	e8 52 bd ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105f6f:	e8 41 d9 ff ff       	call   801038b5 <end_op>
    return -1;
80105f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f79:	e9 e4 00 00 00       	jmp    80106062 <sys_link+0x17b>
  }

  ip->nlink++;
80105f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f81:	66 8b 40 56          	mov    0x56(%eax),%ax
80105f85:	40                   	inc    %eax
80105f86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f89:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f90:	89 04 24             	mov    %eax,(%esp)
80105f93:	e8 67 b9 ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9b:	89 04 24             	mov    %eax,(%esp)
80105f9e:	e8 29 bc ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105fa3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105fa6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105fa9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105fad:	89 04 24             	mov    %eax,(%esp)
80105fb0:	e8 c5 c7 ff ff       	call   8010277a <nameiparent>
80105fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fb8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fbc:	75 02                	jne    80105fc0 <sys_link+0xd9>
    goto bad;
80105fbe:	eb 68                	jmp    80106028 <sys_link+0x141>
  ilock(dp);
80105fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc3:	89 04 24             	mov    %eax,(%esp)
80105fc6:	e8 f7 ba ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fce:	8b 10                	mov    (%eax),%edx
80105fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd3:	8b 00                	mov    (%eax),%eax
80105fd5:	39 c2                	cmp    %eax,%edx
80105fd7:	75 20                	jne    80105ff9 <sys_link+0x112>
80105fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fdc:	8b 40 04             	mov    0x4(%eax),%eax
80105fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fe3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fed:	89 04 24             	mov    %eax,(%esp)
80105ff0:	e8 a8 c3 ff ff       	call   8010239d <dirlink>
80105ff5:	85 c0                	test   %eax,%eax
80105ff7:	79 0d                	jns    80106006 <sys_link+0x11f>
    iunlockput(dp);
80105ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffc:	89 04 24             	mov    %eax,(%esp)
80105fff:	e8 bd bc ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80106004:	eb 22                	jmp    80106028 <sys_link+0x141>
  }
  iunlockput(dp);
80106006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106009:	89 04 24             	mov    %eax,(%esp)
8010600c:	e8 b0 bc ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80106011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106014:	89 04 24             	mov    %eax,(%esp)
80106017:	e8 f4 bb ff ff       	call   80101c10 <iput>

  end_op();
8010601c:	e8 94 d8 ff ff       	call   801038b5 <end_op>

  return 0;
80106021:	b8 00 00 00 00       	mov    $0x0,%eax
80106026:	eb 3a                	jmp    80106062 <sys_link+0x17b>

bad:
  ilock(ip);
80106028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602b:	89 04 24             	mov    %eax,(%esp)
8010602e:	e8 8f ba ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80106033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106036:	66 8b 40 56          	mov    0x56(%eax),%ax
8010603a:	48                   	dec    %eax
8010603b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010603e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106045:	89 04 24             	mov    %eax,(%esp)
80106048:	e8 b2 b8 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	89 04 24             	mov    %eax,(%esp)
80106053:	e8 69 bc ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106058:	e8 58 d8 ff ff       	call   801038b5 <end_op>
  return -1;
8010605d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106062:	c9                   	leave  
80106063:	c3                   	ret    

80106064 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106064:	55                   	push   %ebp
80106065:	89 e5                	mov    %esp,%ebp
80106067:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010606a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106071:	eb 4a                	jmp    801060bd <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106076:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010607d:	00 
8010607e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106082:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106085:	89 44 24 04          	mov    %eax,0x4(%esp)
80106089:	8b 45 08             	mov    0x8(%ebp),%eax
8010608c:	89 04 24             	mov    %eax,(%esp)
8010608f:	e8 c5 be ff ff       	call   80101f59 <readi>
80106094:	83 f8 10             	cmp    $0x10,%eax
80106097:	74 0c                	je     801060a5 <isdirempty+0x41>
      panic("isdirempty: readi");
80106099:	c7 04 24 bb 9e 10 80 	movl   $0x80109ebb,(%esp)
801060a0:	e8 af a4 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801060a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060a8:	66 85 c0             	test   %ax,%ax
801060ab:	74 07                	je     801060b4 <isdirempty+0x50>
      return 0;
801060ad:	b8 00 00 00 00       	mov    $0x0,%eax
801060b2:	eb 1b                	jmp    801060cf <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801060b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b7:	83 c0 10             	add    $0x10,%eax
801060ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c0:	8b 45 08             	mov    0x8(%ebp),%eax
801060c3:	8b 40 58             	mov    0x58(%eax),%eax
801060c6:	39 c2                	cmp    %eax,%edx
801060c8:	72 a9                	jb     80106073 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801060ca:	b8 01 00 00 00       	mov    $0x1,%eax
}
801060cf:	c9                   	leave  
801060d0:	c3                   	ret    

801060d1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801060d1:	55                   	push   %ebp
801060d2:	89 e5                	mov    %esp,%ebp
801060d4:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801060d7:	8d 45 bc             	lea    -0x44(%ebp),%eax
801060da:	89 44 24 04          	mov    %eax,0x4(%esp)
801060de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060e5:	e8 7e fa ff ff       	call   80105b68 <argstr>
801060ea:	85 c0                	test   %eax,%eax
801060ec:	79 0a                	jns    801060f8 <sys_unlink+0x27>
    return -1;
801060ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f3:	e9 f1 01 00 00       	jmp    801062e9 <sys_unlink+0x218>

  begin_op();
801060f8:	e8 36 d7 ff ff       	call   80103833 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801060fd:	8b 45 bc             	mov    -0x44(%ebp),%eax
80106100:	8d 55 c2             	lea    -0x3e(%ebp),%edx
80106103:	89 54 24 04          	mov    %edx,0x4(%esp)
80106107:	89 04 24             	mov    %eax,(%esp)
8010610a:	e8 6b c6 ff ff       	call   8010277a <nameiparent>
8010610f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106112:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106116:	75 0f                	jne    80106127 <sys_unlink+0x56>
    end_op();
80106118:	e8 98 d7 ff ff       	call   801038b5 <end_op>
    return -1;
8010611d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106122:	e9 c2 01 00 00       	jmp    801062e9 <sys_unlink+0x218>
  }

  ilock(dp);
80106127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612a:	89 04 24             	mov    %eax,(%esp)
8010612d:	e8 90 b9 ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106132:	c7 44 24 04 cd 9e 10 	movl   $0x80109ecd,0x4(%esp)
80106139:	80 
8010613a:	8d 45 c2             	lea    -0x3e(%ebp),%eax
8010613d:	89 04 24             	mov    %eax,(%esp)
80106140:	e8 70 c1 ff ff       	call   801022b5 <namecmp>
80106145:	85 c0                	test   %eax,%eax
80106147:	0f 84 87 01 00 00    	je     801062d4 <sys_unlink+0x203>
8010614d:	c7 44 24 04 cf 9e 10 	movl   $0x80109ecf,0x4(%esp)
80106154:	80 
80106155:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106158:	89 04 24             	mov    %eax,(%esp)
8010615b:	e8 55 c1 ff ff       	call   801022b5 <namecmp>
80106160:	85 c0                	test   %eax,%eax
80106162:	0f 84 6c 01 00 00    	je     801062d4 <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106168:	8d 45 b8             	lea    -0x48(%ebp),%eax
8010616b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010616f:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106172:	89 44 24 04          	mov    %eax,0x4(%esp)
80106176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106179:	89 04 24             	mov    %eax,(%esp)
8010617c:	e8 56 c1 ff ff       	call   801022d7 <dirlookup>
80106181:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106184:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106188:	75 05                	jne    8010618f <sys_unlink+0xbe>
    goto bad;
8010618a:	e9 45 01 00 00       	jmp    801062d4 <sys_unlink+0x203>
  ilock(ip);
8010618f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106192:	89 04 24             	mov    %eax,(%esp)
80106195:	e8 28 b9 ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
8010619a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619d:	66 8b 40 56          	mov    0x56(%eax),%ax
801061a1:	66 85 c0             	test   %ax,%ax
801061a4:	7f 0c                	jg     801061b2 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801061a6:	c7 04 24 d2 9e 10 80 	movl   $0x80109ed2,(%esp)
801061ad:	e8 a2 a3 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801061b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b5:	8b 40 50             	mov    0x50(%eax),%eax
801061b8:	66 83 f8 01          	cmp    $0x1,%ax
801061bc:	75 1f                	jne    801061dd <sys_unlink+0x10c>
801061be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c1:	89 04 24             	mov    %eax,(%esp)
801061c4:	e8 9b fe ff ff       	call   80106064 <isdirempty>
801061c9:	85 c0                	test   %eax,%eax
801061cb:	75 10                	jne    801061dd <sys_unlink+0x10c>
    iunlockput(ip);
801061cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d0:	89 04 24             	mov    %eax,(%esp)
801061d3:	e8 e9 ba ff ff       	call   80101cc1 <iunlockput>
    goto bad;
801061d8:	e9 f7 00 00 00       	jmp    801062d4 <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
801061dd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801061e4:	00 
801061e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061ec:	00 
801061ed:	8d 45 d0             	lea    -0x30(%ebp),%eax
801061f0:	89 04 24             	mov    %eax,(%esp)
801061f3:	e8 a6 f5 ff ff       	call   8010579e <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
801061f8:	8b 45 b8             	mov    -0x48(%ebp),%eax
801061fb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106202:	00 
80106203:	89 44 24 08          	mov    %eax,0x8(%esp)
80106207:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010620a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106211:	89 04 24             	mov    %eax,(%esp)
80106214:	e8 a4 be ff ff       	call   801020bd <writei>
80106219:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
8010621c:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80106220:	74 0c                	je     8010622e <sys_unlink+0x15d>
    panic("unlink: writei");
80106222:	c7 04 24 e4 9e 10 80 	movl   $0x80109ee4,(%esp)
80106229:	e8 26 a3 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
8010622e:	e8 28 e3 ff ff       	call   8010455b <myproc>
80106233:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106239:	83 c0 18             	add    $0x18,%eax
8010623c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
8010623f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106242:	89 04 24             	mov    %eax,(%esp)
80106245:	e8 11 30 00 00       	call   8010925b <find>
8010624a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
8010624d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106250:	89 c2                	mov    %eax,%edx
80106252:	c1 ea 1f             	shr    $0x1f,%edx
80106255:	01 d0                	add    %edx,%eax
80106257:	d1 f8                	sar    %eax
80106259:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
8010625c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010625f:	f7 d8                	neg    %eax
80106261:	89 c2                	mov    %eax,%edx
80106263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106266:	89 44 24 04          	mov    %eax,0x4(%esp)
8010626a:	89 14 24             	mov    %edx,(%esp)
8010626d:	e8 7e 33 00 00       	call   801095f0 <set_curr_disk>
  if(ip->type == T_DIR){
80106272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106275:	8b 40 50             	mov    0x50(%eax),%eax
80106278:	66 83 f8 01          	cmp    $0x1,%ax
8010627c:	75 1a                	jne    80106298 <sys_unlink+0x1c7>
    dp->nlink--;
8010627e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106281:	66 8b 40 56          	mov    0x56(%eax),%ax
80106285:	48                   	dec    %eax
80106286:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106289:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
8010628d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106290:	89 04 24             	mov    %eax,(%esp)
80106293:	e8 67 b6 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
80106298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629b:	89 04 24             	mov    %eax,(%esp)
8010629e:	e8 1e ba ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
801062a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a6:	66 8b 40 56          	mov    0x56(%eax),%ax
801062aa:	48                   	dec    %eax
801062ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ae:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801062b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b5:	89 04 24             	mov    %eax,(%esp)
801062b8:	e8 42 b6 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
801062bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c0:	89 04 24             	mov    %eax,(%esp)
801062c3:	e8 f9 b9 ff ff       	call   80101cc1 <iunlockput>

  end_op();
801062c8:	e8 e8 d5 ff ff       	call   801038b5 <end_op>

  return 0;
801062cd:	b8 00 00 00 00       	mov    $0x0,%eax
801062d2:	eb 15                	jmp    801062e9 <sys_unlink+0x218>

bad:
  iunlockput(dp);
801062d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d7:	89 04 24             	mov    %eax,(%esp)
801062da:	e8 e2 b9 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801062df:	e8 d1 d5 ff ff       	call   801038b5 <end_op>
  return -1;
801062e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062e9:	c9                   	leave  
801062ea:	c3                   	ret    

801062eb <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801062eb:	55                   	push   %ebp
801062ec:	89 e5                	mov    %esp,%ebp
801062ee:	83 ec 48             	sub    $0x48,%esp
801062f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801062f4:	8b 55 10             	mov    0x10(%ebp),%edx
801062f7:	8b 45 14             	mov    0x14(%ebp),%eax
801062fa:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801062fe:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106302:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106306:	8d 45 de             	lea    -0x22(%ebp),%eax
80106309:	89 44 24 04          	mov    %eax,0x4(%esp)
8010630d:	8b 45 08             	mov    0x8(%ebp),%eax
80106310:	89 04 24             	mov    %eax,(%esp)
80106313:	e8 62 c4 ff ff       	call   8010277a <nameiparent>
80106318:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010631b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631f:	75 0a                	jne    8010632b <create+0x40>
    return 0;
80106321:	b8 00 00 00 00       	mov    $0x0,%eax
80106326:	e9 79 01 00 00       	jmp    801064a4 <create+0x1b9>
  ilock(dp);
8010632b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632e:	89 04 24             	mov    %eax,(%esp)
80106331:	e8 8c b7 ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106336:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106339:	89 44 24 08          	mov    %eax,0x8(%esp)
8010633d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106340:	89 44 24 04          	mov    %eax,0x4(%esp)
80106344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106347:	89 04 24             	mov    %eax,(%esp)
8010634a:	e8 88 bf ff ff       	call   801022d7 <dirlookup>
8010634f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106352:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106356:	74 46                	je     8010639e <create+0xb3>
    iunlockput(dp);
80106358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635b:	89 04 24             	mov    %eax,(%esp)
8010635e:	e8 5e b9 ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
80106363:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106366:	89 04 24             	mov    %eax,(%esp)
80106369:	e8 54 b7 ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010636e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106373:	75 14                	jne    80106389 <create+0x9e>
80106375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106378:	8b 40 50             	mov    0x50(%eax),%eax
8010637b:	66 83 f8 02          	cmp    $0x2,%ax
8010637f:	75 08                	jne    80106389 <create+0x9e>
      return ip;
80106381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106384:	e9 1b 01 00 00       	jmp    801064a4 <create+0x1b9>
    iunlockput(ip);
80106389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638c:	89 04 24             	mov    %eax,(%esp)
8010638f:	e8 2d b9 ff ff       	call   80101cc1 <iunlockput>
    return 0;
80106394:	b8 00 00 00 00       	mov    $0x0,%eax
80106399:	e9 06 01 00 00       	jmp    801064a4 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010639e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801063a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a5:	8b 00                	mov    (%eax),%eax
801063a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801063ab:	89 04 24             	mov    %eax,(%esp)
801063ae:	e8 7a b4 ff ff       	call   8010182d <ialloc>
801063b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063ba:	75 0c                	jne    801063c8 <create+0xdd>
    panic("create: ialloc");
801063bc:	c7 04 24 f3 9e 10 80 	movl   $0x80109ef3,(%esp)
801063c3:	e8 8c a1 ff ff       	call   80100554 <panic>

  ilock(ip);
801063c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cb:	89 04 24             	mov    %eax,(%esp)
801063ce:	e8 ef b6 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
801063d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801063d9:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
801063dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801063e3:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
801063e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ea:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801063f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f3:	89 04 24             	mov    %eax,(%esp)
801063f6:	e8 04 b5 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801063fb:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106400:	75 68                	jne    8010646a <create+0x17f>
    dp->nlink++;  // for ".."
80106402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106405:	66 8b 40 56          	mov    0x56(%eax),%ax
80106409:	40                   	inc    %eax
8010640a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010640d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106414:	89 04 24             	mov    %eax,(%esp)
80106417:	e8 e3 b4 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010641c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641f:	8b 40 04             	mov    0x4(%eax),%eax
80106422:	89 44 24 08          	mov    %eax,0x8(%esp)
80106426:	c7 44 24 04 cd 9e 10 	movl   $0x80109ecd,0x4(%esp)
8010642d:	80 
8010642e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106431:	89 04 24             	mov    %eax,(%esp)
80106434:	e8 64 bf ff ff       	call   8010239d <dirlink>
80106439:	85 c0                	test   %eax,%eax
8010643b:	78 21                	js     8010645e <create+0x173>
8010643d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106440:	8b 40 04             	mov    0x4(%eax),%eax
80106443:	89 44 24 08          	mov    %eax,0x8(%esp)
80106447:	c7 44 24 04 cf 9e 10 	movl   $0x80109ecf,0x4(%esp)
8010644e:	80 
8010644f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106452:	89 04 24             	mov    %eax,(%esp)
80106455:	e8 43 bf ff ff       	call   8010239d <dirlink>
8010645a:	85 c0                	test   %eax,%eax
8010645c:	79 0c                	jns    8010646a <create+0x17f>
      panic("create dots");
8010645e:	c7 04 24 02 9f 10 80 	movl   $0x80109f02,(%esp)
80106465:	e8 ea a0 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010646a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646d:	8b 40 04             	mov    0x4(%eax),%eax
80106470:	89 44 24 08          	mov    %eax,0x8(%esp)
80106474:	8d 45 de             	lea    -0x22(%ebp),%eax
80106477:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647e:	89 04 24             	mov    %eax,(%esp)
80106481:	e8 17 bf ff ff       	call   8010239d <dirlink>
80106486:	85 c0                	test   %eax,%eax
80106488:	79 0c                	jns    80106496 <create+0x1ab>
    panic("create: dirlink");
8010648a:	c7 04 24 0e 9f 10 80 	movl   $0x80109f0e,(%esp)
80106491:	e8 be a0 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80106496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106499:	89 04 24             	mov    %eax,(%esp)
8010649c:	e8 20 b8 ff ff       	call   80101cc1 <iunlockput>

  return ip;
801064a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801064a4:	c9                   	leave  
801064a5:	c3                   	ret    

801064a6 <sys_open>:

int
sys_open(void)
{
801064a6:	55                   	push   %ebp
801064a7:	89 e5                	mov    %esp,%ebp
801064a9:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801064ac:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064af:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064ba:	e8 a9 f6 ff ff       	call   80105b68 <argstr>
801064bf:	85 c0                	test   %eax,%eax
801064c1:	78 17                	js     801064da <sys_open+0x34>
801064c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064d1:	e8 fb f5 ff ff       	call   80105ad1 <argint>
801064d6:	85 c0                	test   %eax,%eax
801064d8:	79 0a                	jns    801064e4 <sys_open+0x3e>
    return -1;
801064da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064df:	e9 64 01 00 00       	jmp    80106648 <sys_open+0x1a2>

  begin_op();
801064e4:	e8 4a d3 ff ff       	call   80103833 <begin_op>

  if(omode & O_CREATE){
801064e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ec:	25 00 02 00 00       	and    $0x200,%eax
801064f1:	85 c0                	test   %eax,%eax
801064f3:	74 3b                	je     80106530 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801064f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801064ff:	00 
80106500:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106507:	00 
80106508:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010650f:	00 
80106510:	89 04 24             	mov    %eax,(%esp)
80106513:	e8 d3 fd ff ff       	call   801062eb <create>
80106518:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010651b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010651f:	75 6a                	jne    8010658b <sys_open+0xe5>
      end_op();
80106521:	e8 8f d3 ff ff       	call   801038b5 <end_op>
      return -1;
80106526:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652b:	e9 18 01 00 00       	jmp    80106648 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106530:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106533:	89 04 24             	mov    %eax,(%esp)
80106536:	e8 1d c2 ff ff       	call   80102758 <namei>
8010653b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010653e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106542:	75 0f                	jne    80106553 <sys_open+0xad>
      end_op();
80106544:	e8 6c d3 ff ff       	call   801038b5 <end_op>
      return -1;
80106549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654e:	e9 f5 00 00 00       	jmp    80106648 <sys_open+0x1a2>
    }
    ilock(ip);
80106553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106556:	89 04 24             	mov    %eax,(%esp)
80106559:	e8 64 b5 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010655e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106561:	8b 40 50             	mov    0x50(%eax),%eax
80106564:	66 83 f8 01          	cmp    $0x1,%ax
80106568:	75 21                	jne    8010658b <sys_open+0xe5>
8010656a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010656d:	85 c0                	test   %eax,%eax
8010656f:	74 1a                	je     8010658b <sys_open+0xe5>
      iunlockput(ip);
80106571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106574:	89 04 24             	mov    %eax,(%esp)
80106577:	e8 45 b7 ff ff       	call   80101cc1 <iunlockput>
      end_op();
8010657c:	e8 34 d3 ff ff       	call   801038b5 <end_op>
      return -1;
80106581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106586:	e9 bd 00 00 00       	jmp    80106648 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010658b:	e8 72 ab ff ff       	call   80101102 <filealloc>
80106590:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106593:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106597:	74 14                	je     801065ad <sys_open+0x107>
80106599:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659c:	89 04 24             	mov    %eax,(%esp)
8010659f:	e8 f8 f6 ff ff       	call   80105c9c <fdalloc>
801065a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801065a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801065ab:	79 28                	jns    801065d5 <sys_open+0x12f>
    if(f)
801065ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065b1:	74 0b                	je     801065be <sys_open+0x118>
      fileclose(f);
801065b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b6:	89 04 24             	mov    %eax,(%esp)
801065b9:	e8 ec ab ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c1:	89 04 24             	mov    %eax,(%esp)
801065c4:	e8 f8 b6 ff ff       	call   80101cc1 <iunlockput>
    end_op();
801065c9:	e8 e7 d2 ff ff       	call   801038b5 <end_op>
    return -1;
801065ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d3:	eb 73                	jmp    80106648 <sys_open+0x1a2>
  }
  iunlock(ip);
801065d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d8:	89 04 24             	mov    %eax,(%esp)
801065db:	e8 ec b5 ff ff       	call   80101bcc <iunlock>
  end_op();
801065e0:	e8 d0 d2 ff ff       	call   801038b5 <end_op>

  f->type = FD_INODE;
801065e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801065ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065f4:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801065f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fa:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106601:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106604:	83 e0 01             	and    $0x1,%eax
80106607:	85 c0                	test   %eax,%eax
80106609:	0f 94 c0             	sete   %al
8010660c:	88 c2                	mov    %al,%dl
8010660e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106611:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106617:	83 e0 01             	and    $0x1,%eax
8010661a:	85 c0                	test   %eax,%eax
8010661c:	75 0a                	jne    80106628 <sys_open+0x182>
8010661e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106621:	83 e0 02             	and    $0x2,%eax
80106624:	85 c0                	test   %eax,%eax
80106626:	74 07                	je     8010662f <sys_open+0x189>
80106628:	b8 01 00 00 00       	mov    $0x1,%eax
8010662d:	eb 05                	jmp    80106634 <sys_open+0x18e>
8010662f:	b8 00 00 00 00       	mov    $0x0,%eax
80106634:	88 c2                	mov    %al,%dl
80106636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106639:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
8010663c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010663f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106642:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
80106645:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106648:	c9                   	leave  
80106649:	c3                   	ret    

8010664a <sys_mkdir>:

int
sys_mkdir(void)
{
8010664a:	55                   	push   %ebp
8010664b:	89 e5                	mov    %esp,%ebp
8010664d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106650:	e8 de d1 ff ff       	call   80103833 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106655:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106658:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106663:	e8 00 f5 ff ff       	call   80105b68 <argstr>
80106668:	85 c0                	test   %eax,%eax
8010666a:	78 2c                	js     80106698 <sys_mkdir+0x4e>
8010666c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010666f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106676:	00 
80106677:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010667e:	00 
8010667f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106686:	00 
80106687:	89 04 24             	mov    %eax,(%esp)
8010668a:	e8 5c fc ff ff       	call   801062eb <create>
8010668f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106692:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106696:	75 0c                	jne    801066a4 <sys_mkdir+0x5a>
    end_op();
80106698:	e8 18 d2 ff ff       	call   801038b5 <end_op>
    return -1;
8010669d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a2:	eb 15                	jmp    801066b9 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801066a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a7:	89 04 24             	mov    %eax,(%esp)
801066aa:	e8 12 b6 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801066af:	e8 01 d2 ff ff       	call   801038b5 <end_op>
  return 0;
801066b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066b9:	c9                   	leave  
801066ba:	c3                   	ret    

801066bb <sys_mknod>:

int
sys_mknod(void)
{
801066bb:	55                   	push   %ebp
801066bc:	89 e5                	mov    %esp,%ebp
801066be:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801066c1:	e8 6d d1 ff ff       	call   80103833 <begin_op>
  if((argstr(0, &path)) < 0 ||
801066c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801066cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066d4:	e8 8f f4 ff ff       	call   80105b68 <argstr>
801066d9:	85 c0                	test   %eax,%eax
801066db:	78 5e                	js     8010673b <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801066dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066eb:	e8 e1 f3 ff ff       	call   80105ad1 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801066f0:	85 c0                	test   %eax,%eax
801066f2:	78 47                	js     8010673b <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801066f4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106702:	e8 ca f3 ff ff       	call   80105ad1 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106707:	85 c0                	test   %eax,%eax
80106709:	78 30                	js     8010673b <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010670b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010670e:	0f bf c8             	movswl %ax,%ecx
80106711:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106714:	0f bf d0             	movswl %ax,%edx
80106717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010671a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010671e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106722:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106729:	00 
8010672a:	89 04 24             	mov    %eax,(%esp)
8010672d:	e8 b9 fb ff ff       	call   801062eb <create>
80106732:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106735:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106739:	75 0c                	jne    80106747 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010673b:	e8 75 d1 ff ff       	call   801038b5 <end_op>
    return -1;
80106740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106745:	eb 15                	jmp    8010675c <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674a:	89 04 24             	mov    %eax,(%esp)
8010674d:	e8 6f b5 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106752:	e8 5e d1 ff ff       	call   801038b5 <end_op>
  return 0;
80106757:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010675c:	c9                   	leave  
8010675d:	c3                   	ret    

8010675e <sys_chdir>:

int
sys_chdir(void)
{
8010675e:	55                   	push   %ebp
8010675f:	89 e5                	mov    %esp,%ebp
80106761:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106764:	e8 f2 dd ff ff       	call   8010455b <myproc>
80106769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010676c:	e8 c2 d0 ff ff       	call   80103833 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106771:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106774:	89 44 24 04          	mov    %eax,0x4(%esp)
80106778:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010677f:	e8 e4 f3 ff ff       	call   80105b68 <argstr>
80106784:	85 c0                	test   %eax,%eax
80106786:	78 14                	js     8010679c <sys_chdir+0x3e>
80106788:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010678b:	89 04 24             	mov    %eax,(%esp)
8010678e:	e8 c5 bf ff ff       	call   80102758 <namei>
80106793:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106796:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010679a:	75 0c                	jne    801067a8 <sys_chdir+0x4a>
    end_op();
8010679c:	e8 14 d1 ff ff       	call   801038b5 <end_op>
    return -1;
801067a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a6:	eb 5a                	jmp    80106802 <sys_chdir+0xa4>
  }
  ilock(ip);
801067a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ab:	89 04 24             	mov    %eax,(%esp)
801067ae:	e8 0f b3 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
801067b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b6:	8b 40 50             	mov    0x50(%eax),%eax
801067b9:	66 83 f8 01          	cmp    $0x1,%ax
801067bd:	74 17                	je     801067d6 <sys_chdir+0x78>
    iunlockput(ip);
801067bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c2:	89 04 24             	mov    %eax,(%esp)
801067c5:	e8 f7 b4 ff ff       	call   80101cc1 <iunlockput>
    end_op();
801067ca:	e8 e6 d0 ff ff       	call   801038b5 <end_op>
    return -1;
801067cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d4:	eb 2c                	jmp    80106802 <sys_chdir+0xa4>
  }
  iunlock(ip);
801067d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d9:	89 04 24             	mov    %eax,(%esp)
801067dc:	e8 eb b3 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
801067e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e4:	8b 40 68             	mov    0x68(%eax),%eax
801067e7:	89 04 24             	mov    %eax,(%esp)
801067ea:	e8 21 b4 ff ff       	call   80101c10 <iput>
  end_op();
801067ef:	e8 c1 d0 ff ff       	call   801038b5 <end_op>
  curproc->cwd = ip;
801067f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067fa:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801067fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106802:	c9                   	leave  
80106803:	c3                   	ret    

80106804 <sys_exec>:

int
sys_exec(void)
{
80106804:	55                   	push   %ebp
80106805:	89 e5                	mov    %esp,%ebp
80106807:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010680d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106810:	89 44 24 04          	mov    %eax,0x4(%esp)
80106814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010681b:	e8 48 f3 ff ff       	call   80105b68 <argstr>
80106820:	85 c0                	test   %eax,%eax
80106822:	78 1a                	js     8010683e <sys_exec+0x3a>
80106824:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010682a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010682e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106835:	e8 97 f2 ff ff       	call   80105ad1 <argint>
8010683a:	85 c0                	test   %eax,%eax
8010683c:	79 0a                	jns    80106848 <sys_exec+0x44>
    return -1;
8010683e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106843:	e9 c7 00 00 00       	jmp    8010690f <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106848:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010684f:	00 
80106850:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106857:	00 
80106858:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010685e:	89 04 24             	mov    %eax,(%esp)
80106861:	e8 38 ef ff ff       	call   8010579e <memset>
  for(i=0;; i++){
80106866:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010686d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106870:	83 f8 1f             	cmp    $0x1f,%eax
80106873:	76 0a                	jbe    8010687f <sys_exec+0x7b>
      return -1;
80106875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687a:	e9 90 00 00 00       	jmp    8010690f <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010687f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106882:	c1 e0 02             	shl    $0x2,%eax
80106885:	89 c2                	mov    %eax,%edx
80106887:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010688d:	01 c2                	add    %eax,%edx
8010688f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106895:	89 44 24 04          	mov    %eax,0x4(%esp)
80106899:	89 14 24             	mov    %edx,(%esp)
8010689c:	e8 8f f1 ff ff       	call   80105a30 <fetchint>
801068a1:	85 c0                	test   %eax,%eax
801068a3:	79 07                	jns    801068ac <sys_exec+0xa8>
      return -1;
801068a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068aa:	eb 63                	jmp    8010690f <sys_exec+0x10b>
    if(uarg == 0){
801068ac:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068b2:	85 c0                	test   %eax,%eax
801068b4:	75 26                	jne    801068dc <sys_exec+0xd8>
      argv[i] = 0;
801068b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b9:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801068c0:	00 00 00 00 
      break;
801068c4:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801068c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c8:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801068ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801068d2:	89 04 24             	mov    %eax,(%esp)
801068d5:	e8 66 a3 ff ff       	call   80100c40 <exec>
801068da:	eb 33                	jmp    8010690f <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801068dc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801068e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068e5:	c1 e2 02             	shl    $0x2,%edx
801068e8:	01 c2                	add    %eax,%edx
801068ea:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801068f4:	89 04 24             	mov    %eax,(%esp)
801068f7:	e8 73 f1 ff ff       	call   80105a6f <fetchstr>
801068fc:	85 c0                	test   %eax,%eax
801068fe:	79 07                	jns    80106907 <sys_exec+0x103>
      return -1;
80106900:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106905:	eb 08                	jmp    8010690f <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106907:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010690a:	e9 5e ff ff ff       	jmp    8010686d <sys_exec+0x69>
  return exec(path, argv);
}
8010690f:	c9                   	leave  
80106910:	c3                   	ret    

80106911 <sys_pipe>:

int
sys_pipe(void)
{
80106911:	55                   	push   %ebp
80106912:	89 e5                	mov    %esp,%ebp
80106914:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106917:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010691e:	00 
8010691f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106922:	89 44 24 04          	mov    %eax,0x4(%esp)
80106926:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010692d:	e8 cc f1 ff ff       	call   80105afe <argptr>
80106932:	85 c0                	test   %eax,%eax
80106934:	79 0a                	jns    80106940 <sys_pipe+0x2f>
    return -1;
80106936:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010693b:	e9 9a 00 00 00       	jmp    801069da <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106940:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106943:	89 44 24 04          	mov    %eax,0x4(%esp)
80106947:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010694a:	89 04 24             	mov    %eax,(%esp)
8010694d:	e8 5e d7 ff ff       	call   801040b0 <pipealloc>
80106952:	85 c0                	test   %eax,%eax
80106954:	79 07                	jns    8010695d <sys_pipe+0x4c>
    return -1;
80106956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010695b:	eb 7d                	jmp    801069da <sys_pipe+0xc9>
  fd0 = -1;
8010695d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106964:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106967:	89 04 24             	mov    %eax,(%esp)
8010696a:	e8 2d f3 ff ff       	call   80105c9c <fdalloc>
8010696f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106976:	78 14                	js     8010698c <sys_pipe+0x7b>
80106978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010697b:	89 04 24             	mov    %eax,(%esp)
8010697e:	e8 19 f3 ff ff       	call   80105c9c <fdalloc>
80106983:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106986:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010698a:	79 36                	jns    801069c2 <sys_pipe+0xb1>
    if(fd0 >= 0)
8010698c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106990:	78 13                	js     801069a5 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106992:	e8 c4 db ff ff       	call   8010455b <myproc>
80106997:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010699a:	83 c2 08             	add    $0x8,%edx
8010699d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801069a4:	00 
    fileclose(rf);
801069a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801069a8:	89 04 24             	mov    %eax,(%esp)
801069ab:	e8 fa a7 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
801069b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069b3:	89 04 24             	mov    %eax,(%esp)
801069b6:	e8 ef a7 ff ff       	call   801011aa <fileclose>
    return -1;
801069bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c0:	eb 18                	jmp    801069da <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801069c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069c8:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801069ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069cd:	8d 50 04             	lea    0x4(%eax),%edx
801069d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d3:	89 02                	mov    %eax,(%edx)
  return 0;
801069d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069da:	c9                   	leave  
801069db:	c3                   	ret    

801069dc <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
801069dc:	55                   	push   %ebp
801069dd:	89 e5                	mov    %esp,%ebp
801069df:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
801069e2:	e8 74 db ff ff       	call   8010455b <myproc>
801069e7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069ed:	83 c0 18             	add    $0x18,%eax
801069f0:	89 04 24             	mov    %eax,(%esp)
801069f3:	e8 63 28 00 00       	call   8010925b <find>
801069f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
801069fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069ff:	78 51                	js     80106a52 <sys_fork+0x76>
    int before = get_curr_proc(x);
80106a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a04:	89 04 24             	mov    %eax,(%esp)
80106a07:	e8 a7 29 00 00       	call   801093b3 <get_curr_proc>
80106a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a1d:	e8 75 2c 00 00       	call   80109697 <set_curr_proc>
    int after = get_curr_proc(x);
80106a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a25:	89 04 24             	mov    %eax,(%esp)
80106a28:	e8 86 29 00 00       	call   801093b3 <get_curr_proc>
80106a2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
80106a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a33:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80106a36:	75 1a                	jne    80106a52 <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
80106a38:	e8 1e db ff ff       	call   8010455b <myproc>
80106a3d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a43:	89 04 24             	mov    %eax,(%esp)
80106a46:	e8 7d e6 ff ff       	call   801050c8 <cstop_container_helper>
      return -1;
80106a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a50:	eb 05                	jmp    80106a57 <sys_fork+0x7b>
    }
  }
  return fork();
80106a52:	e8 1d de ff ff       	call   80104874 <fork>
}
80106a57:	c9                   	leave  
80106a58:	c3                   	ret    

80106a59 <sys_exit>:

int
sys_exit(void)
{
80106a59:	55                   	push   %ebp
80106a5a:	89 e5                	mov    %esp,%ebp
80106a5c:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106a5f:	e8 f7 da ff ff       	call   8010455b <myproc>
80106a64:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a6a:	83 c0 18             	add    $0x18,%eax
80106a6d:	89 04 24             	mov    %eax,(%esp)
80106a70:	e8 e6 27 00 00       	call   8010925b <find>
80106a75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106a78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a7c:	78 13                	js     80106a91 <sys_exit+0x38>
    set_curr_proc(-1, x);
80106a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a81:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a85:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
80106a8c:	e8 06 2c 00 00       	call   80109697 <set_curr_proc>
  }
  exit();
80106a91:	e8 56 df ff ff       	call   801049ec <exit>
  return 0;  // not reached
80106a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a9b:	c9                   	leave  
80106a9c:	c3                   	ret    

80106a9d <sys_wait>:

int
sys_wait(void)
{
80106a9d:	55                   	push   %ebp
80106a9e:	89 e5                	mov    %esp,%ebp
80106aa0:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106aa3:	e8 88 e0 ff ff       	call   80104b30 <wait>
}
80106aa8:	c9                   	leave  
80106aa9:	c3                   	ret    

80106aaa <sys_kill>:

int
sys_kill(void)
{
80106aaa:	55                   	push   %ebp
80106aab:	89 e5                	mov    %esp,%ebp
80106aad:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106ab0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ab7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106abe:	e8 0e f0 ff ff       	call   80105ad1 <argint>
80106ac3:	85 c0                	test   %eax,%eax
80106ac5:	79 07                	jns    80106ace <sys_kill+0x24>
    return -1;
80106ac7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106acc:	eb 0b                	jmp    80106ad9 <sys_kill+0x2f>
  return kill(pid);
80106ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad1:	89 04 24             	mov    %eax,(%esp)
80106ad4:	e8 35 e4 ff ff       	call   80104f0e <kill>
}
80106ad9:	c9                   	leave  
80106ada:	c3                   	ret    

80106adb <sys_getpid>:

int
sys_getpid(void)
{
80106adb:	55                   	push   %ebp
80106adc:	89 e5                	mov    %esp,%ebp
80106ade:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106ae1:	e8 75 da ff ff       	call   8010455b <myproc>
80106ae6:	8b 40 10             	mov    0x10(%eax),%eax
}
80106ae9:	c9                   	leave  
80106aea:	c3                   	ret    

80106aeb <sys_sbrk>:

int
sys_sbrk(void)
{
80106aeb:	55                   	push   %ebp
80106aec:	89 e5                	mov    %esp,%ebp
80106aee:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106af1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106af4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aff:	e8 cd ef ff ff       	call   80105ad1 <argint>
80106b04:	85 c0                	test   %eax,%eax
80106b06:	79 07                	jns    80106b0f <sys_sbrk+0x24>
    return -1;
80106b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b0d:	eb 23                	jmp    80106b32 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106b0f:	e8 47 da ff ff       	call   8010455b <myproc>
80106b14:	8b 00                	mov    (%eax),%eax
80106b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b1c:	89 04 24             	mov    %eax,(%esp)
80106b1f:	e8 b2 dc ff ff       	call   801047d6 <growproc>
80106b24:	85 c0                	test   %eax,%eax
80106b26:	79 07                	jns    80106b2f <sys_sbrk+0x44>
    return -1;
80106b28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2d:	eb 03                	jmp    80106b32 <sys_sbrk+0x47>
  return addr;
80106b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106b32:	c9                   	leave  
80106b33:	c3                   	ret    

80106b34 <sys_sleep>:

int
sys_sleep(void)
{
80106b34:	55                   	push   %ebp
80106b35:	89 e5                	mov    %esp,%ebp
80106b37:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106b3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b48:	e8 84 ef ff ff       	call   80105ad1 <argint>
80106b4d:	85 c0                	test   %eax,%eax
80106b4f:	79 07                	jns    80106b58 <sys_sleep+0x24>
    return -1;
80106b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b56:	eb 6b                	jmp    80106bc3 <sys_sleep+0x8f>
  acquire(&tickslock);
80106b58:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80106b5f:	e8 d7 e9 ff ff       	call   8010553b <acquire>
  ticks0 = ticks;
80106b64:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80106b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106b6c:	eb 33                	jmp    80106ba1 <sys_sleep+0x6d>
    if(myproc()->killed){
80106b6e:	e8 e8 d9 ff ff       	call   8010455b <myproc>
80106b73:	8b 40 24             	mov    0x24(%eax),%eax
80106b76:	85 c0                	test   %eax,%eax
80106b78:	74 13                	je     80106b8d <sys_sleep+0x59>
      release(&tickslock);
80106b7a:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80106b81:	e8 1f ea ff ff       	call   801055a5 <release>
      return -1;
80106b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8b:	eb 36                	jmp    80106bc3 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106b8d:	c7 44 24 04 a0 83 11 	movl   $0x801183a0,0x4(%esp)
80106b94:	80 
80106b95:	c7 04 24 e0 8b 11 80 	movl   $0x80118be0,(%esp)
80106b9c:	e8 6b e2 ff ff       	call   80104e0c <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106ba1:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80106ba6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106ba9:	89 c2                	mov    %eax,%edx
80106bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bae:	39 c2                	cmp    %eax,%edx
80106bb0:	72 bc                	jb     80106b6e <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106bb2:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80106bb9:	e8 e7 e9 ff ff       	call   801055a5 <release>
  return 0;
80106bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bc3:	c9                   	leave  
80106bc4:	c3                   	ret    

80106bc5 <sys_cstop>:

void sys_cstop(){
80106bc5:	55                   	push   %ebp
80106bc6:	89 e5                	mov    %esp,%ebp
80106bc8:	53                   	push   %ebx
80106bc9:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106bcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bda:	e8 89 ef ff ff       	call   80105b68 <argstr>

  if(myproc()->cont != NULL){
80106bdf:	e8 77 d9 ff ff       	call   8010455b <myproc>
80106be4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106bea:	85 c0                	test   %eax,%eax
80106bec:	74 72                	je     80106c60 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106bee:	e8 68 d9 ff ff       	call   8010455b <myproc>
80106bf3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bff:	89 04 24             	mov    %eax,(%esp)
80106c02:	e8 ea ed ff ff       	call   801059f1 <strlen>
80106c07:	89 c3                	mov    %eax,%ebx
80106c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0c:	83 c0 18             	add    $0x18,%eax
80106c0f:	89 04 24             	mov    %eax,(%esp)
80106c12:	e8 da ed ff ff       	call   801059f1 <strlen>
80106c17:	39 c3                	cmp    %eax,%ebx
80106c19:	75 37                	jne    80106c52 <sys_cstop+0x8d>
80106c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c1e:	89 04 24             	mov    %eax,(%esp)
80106c21:	e8 cb ed ff ff       	call   801059f1 <strlen>
80106c26:	89 c2                	mov    %eax,%edx
80106c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2b:	8d 48 18             	lea    0x18(%eax),%ecx
80106c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c31:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c35:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106c39:	89 04 24             	mov    %eax,(%esp)
80106c3c:	e8 c5 ec ff ff       	call   80105906 <strncmp>
80106c41:	85 c0                	test   %eax,%eax
80106c43:	75 0d                	jne    80106c52 <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c48:	89 04 24             	mov    %eax,(%esp)
80106c4b:	e8 78 e4 ff ff       	call   801050c8 <cstop_container_helper>
80106c50:	eb 19                	jmp    80106c6b <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106c52:	c7 04 24 20 9f 10 80 	movl   $0x80109f20,(%esp)
80106c59:	e8 63 97 ff ff       	call   801003c1 <cprintf>
80106c5e:	eb 0b                	jmp    80106c6b <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c63:	89 04 24             	mov    %eax,(%esp)
80106c66:	e8 c4 e4 ff ff       	call   8010512f <cstop_helper>
  }

  //kill the processes with name as the id

}
80106c6b:	83 c4 24             	add    $0x24,%esp
80106c6e:	5b                   	pop    %ebx
80106c6f:	5d                   	pop    %ebp
80106c70:	c3                   	ret    

80106c71 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106c71:	55                   	push   %ebp
80106c72:	89 e5                	mov    %esp,%ebp
80106c74:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106c77:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c85:	e8 de ee ff ff       	call   80105b68 <argstr>

  set_root_inode(name);
80106c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c8d:	89 04 24             	mov    %eax,(%esp)
80106c90:	e8 b2 24 00 00       	call   80109147 <set_root_inode>
  cprintf("success\n");
80106c95:	c7 04 24 44 9f 10 80 	movl   $0x80109f44,(%esp)
80106c9c:	e8 20 97 ff ff       	call   801003c1 <cprintf>

}
80106ca1:	c9                   	leave  
80106ca2:	c3                   	ret    

80106ca3 <sys_ps>:

void sys_ps(void){
80106ca3:	55                   	push   %ebp
80106ca4:	89 e5                	mov    %esp,%ebp
80106ca6:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106ca9:	e8 ad d8 ff ff       	call   8010455b <myproc>
80106cae:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106cb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cbb:	75 07                	jne    80106cc4 <sys_ps+0x21>
    procdump();
80106cbd:	e8 c7 e2 ff ff       	call   80104f89 <procdump>
80106cc2:	eb 0e                	jmp    80106cd2 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cc7:	83 c0 18             	add    $0x18,%eax
80106cca:	89 04 24             	mov    %eax,(%esp)
80106ccd:	e8 f3 e4 ff ff       	call   801051c5 <c_procdump>
  }
}
80106cd2:	c9                   	leave  
80106cd3:	c3                   	ret    

80106cd4 <sys_container_init>:

void sys_container_init(){
80106cd4:	55                   	push   %ebp
80106cd5:	89 e5                	mov    %esp,%ebp
80106cd7:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106cda:	e8 59 2a 00 00       	call   80109738 <container_init>
}
80106cdf:	c9                   	leave  
80106ce0:	c3                   	ret    

80106ce1 <sys_is_full>:

int sys_is_full(void){
80106ce1:	55                   	push   %ebp
80106ce2:	89 e5                	mov    %esp,%ebp
80106ce4:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106ce7:	e8 1f 25 00 00       	call   8010920b <is_full>
}
80106cec:	c9                   	leave  
80106ced:	c3                   	ret    

80106cee <sys_find>:

int sys_find(void){
80106cee:	55                   	push   %ebp
80106cef:	89 e5                	mov    %esp,%ebp
80106cf1:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106cf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d02:	e8 61 ee ff ff       	call   80105b68 <argstr>

  return find(name);
80106d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d0a:	89 04 24             	mov    %eax,(%esp)
80106d0d:	e8 49 25 00 00       	call   8010925b <find>
}
80106d12:	c9                   	leave  
80106d13:	c3                   	ret    

80106d14 <sys_get_name>:

void sys_get_name(void){
80106d14:	55                   	push   %ebp
80106d15:	89 e5                	mov    %esp,%ebp
80106d17:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106d1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d28:	e8 a4 ed ff ff       	call   80105ad1 <argint>
  argstr(1, &name);
80106d2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d30:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106d3b:	e8 28 ee ff ff       	call   80105b68 <argstr>

  get_name(vc_num, name);
80106d40:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d46:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d4a:	89 04 24             	mov    %eax,(%esp)
80106d4d:	e8 36 24 00 00       	call   80109188 <get_name>
}
80106d52:	c9                   	leave  
80106d53:	c3                   	ret    

80106d54 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106d54:	55                   	push   %ebp
80106d55:	89 e5                	mov    %esp,%ebp
80106d57:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d68:	e8 64 ed ff ff       	call   80105ad1 <argint>


  return get_max_proc(vc_num);  
80106d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d70:	89 04 24             	mov    %eax,(%esp)
80106d73:	e8 53 25 00 00       	call   801092cb <get_max_proc>
}
80106d78:	c9                   	leave  
80106d79:	c3                   	ret    

80106d7a <sys_get_max_mem>:

int sys_get_max_mem(void){
80106d7a:	55                   	push   %ebp
80106d7b:	89 e5                	mov    %esp,%ebp
80106d7d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d83:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d8e:	e8 3e ed ff ff       	call   80105ad1 <argint>


  return get_max_mem(vc_num);
80106d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d96:	89 04 24             	mov    %eax,(%esp)
80106d99:	e8 95 25 00 00       	call   80109333 <get_max_mem>
}
80106d9e:	c9                   	leave  
80106d9f:	c3                   	ret    

80106da0 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106da0:	55                   	push   %ebp
80106da1:	89 e5                	mov    %esp,%ebp
80106da3:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106da6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106da9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106db4:	e8 18 ed ff ff       	call   80105ad1 <argint>


  return get_max_disk(vc_num);
80106db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dbc:	89 04 24             	mov    %eax,(%esp)
80106dbf:	e8 af 25 00 00       	call   80109373 <get_max_disk>

}
80106dc4:	c9                   	leave  
80106dc5:	c3                   	ret    

80106dc6 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106dc6:	55                   	push   %ebp
80106dc7:	89 e5                	mov    %esp,%ebp
80106dc9:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106dcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dda:	e8 f2 ec ff ff       	call   80105ad1 <argint>


  return get_curr_proc(vc_num);
80106ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106de2:	89 04 24             	mov    %eax,(%esp)
80106de5:	e8 c9 25 00 00       	call   801093b3 <get_curr_proc>
}
80106dea:	c9                   	leave  
80106deb:	c3                   	ret    

80106dec <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106dec:	55                   	push   %ebp
80106ded:	89 e5                	mov    %esp,%ebp
80106def:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106df5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106df9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e00:	e8 cc ec ff ff       	call   80105ad1 <argint>


  return get_curr_mem(vc_num);
80106e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e08:	89 04 24             	mov    %eax,(%esp)
80106e0b:	e8 e3 25 00 00       	call   801093f3 <get_curr_mem>
}
80106e10:	c9                   	leave  
80106e11:	c3                   	ret    

80106e12 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106e12:	55                   	push   %ebp
80106e13:	89 e5                	mov    %esp,%ebp
80106e15:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e26:	e8 a6 ec ff ff       	call   80105ad1 <argint>


  return get_curr_disk(vc_num);
80106e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e2e:	89 04 24             	mov    %eax,(%esp)
80106e31:	e8 fd 25 00 00       	call   80109433 <get_curr_disk>
}
80106e36:	c9                   	leave  
80106e37:	c3                   	ret    

80106e38 <sys_set_name>:

void sys_set_name(void){
80106e38:	55                   	push   %ebp
80106e39:	89 e5                	mov    %esp,%ebp
80106e3b:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106e3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e4c:	e8 17 ed ff ff       	call   80105b68 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106e51:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e54:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e5f:	e8 6d ec ff ff       	call   80105ad1 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106e64:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e6e:	89 04 24             	mov    %eax,(%esp)
80106e71:	e8 fd 25 00 00       	call   80109473 <set_name>
  //cprintf("Done setting name.\n");
}
80106e76:	c9                   	leave  
80106e77:	c3                   	ret    

80106e78 <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106e78:	55                   	push   %ebp
80106e79:	89 e5                	mov    %esp,%ebp
80106e7b:	53                   	push   %ebx
80106e7c:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e82:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e8d:	e8 3f ec ff ff       	call   80105ad1 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106e92:	e8 c4 d6 ff ff       	call   8010455b <myproc>
80106e97:	89 c3                	mov    %eax,%ebx
80106e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9c:	89 04 24             	mov    %eax,(%esp)
80106e9f:	e8 67 24 00 00       	call   8010930b <get_container>
80106ea4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106eaa:	83 c4 24             	add    $0x24,%esp
80106ead:	5b                   	pop    %ebx
80106eae:	5d                   	pop    %ebp
80106eaf:	c3                   	ret    

80106eb0 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106eb0:	55                   	push   %ebp
80106eb1:	89 e5                	mov    %esp,%ebp
80106eb3:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106eb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106eb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ebd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ec4:	e8 08 ec ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106ec9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ecc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ed0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106ed7:	e8 f5 eb ff ff       	call   80105ad1 <argint>

  set_max_mem(mem, vc_num);
80106edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee2:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ee6:	89 04 24             	mov    %eax,(%esp)
80106ee9:	e8 bc 25 00 00       	call   801094aa <set_max_mem>
}
80106eee:	c9                   	leave  
80106eef:	c3                   	ret    

80106ef0 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106ef0:	55                   	push   %ebp
80106ef1:	89 e5                	mov    %esp,%ebp
80106ef3:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ef9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f04:	e8 c8 eb ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f17:	e8 b5 eb ff ff       	call   80105ad1 <argint>

  set_max_disk(disk, vc_num);
80106f1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f22:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f26:	89 04 24             	mov    %eax,(%esp)
80106f29:	e8 a1 25 00 00       	call   801094cf <set_max_disk>
}
80106f2e:	c9                   	leave  
80106f2f:	c3                   	ret    

80106f30 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106f36:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f39:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f44:	e8 88 eb ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f49:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f50:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f57:	e8 75 eb ff ff       	call   80105ad1 <argint>

  set_max_proc(proc, vc_num);
80106f5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f62:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f66:	89 04 24             	mov    %eax,(%esp)
80106f69:	e8 87 25 00 00       	call   801094f5 <set_max_proc>
}
80106f6e:	c9                   	leave  
80106f6f:	c3                   	ret    

80106f70 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106f70:	55                   	push   %ebp
80106f71:	89 e5                	mov    %esp,%ebp
80106f73:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f84:	e8 48 eb ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f97:	e8 35 eb ff ff       	call   80105ad1 <argint>

  set_curr_mem(mem, vc_num);
80106f9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa2:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fa6:	89 04 24             	mov    %eax,(%esp)
80106fa9:	e8 6d 25 00 00       	call   8010951b <set_curr_mem>
}
80106fae:	c9                   	leave  
80106faf:	c3                   	ret    

80106fb0 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106fb0:	55                   	push   %ebp
80106fb1:	89 e5                	mov    %esp,%ebp
80106fb3:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fc4:	e8 08 eb ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80106fc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fd0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fd7:	e8 f5 ea ff ff       	call   80105ad1 <argint>

  set_curr_mem(mem, vc_num);
80106fdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe2:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fe6:	89 04 24             	mov    %eax,(%esp)
80106fe9:	e8 2d 25 00 00       	call   8010951b <set_curr_mem>
}
80106fee:	c9                   	leave  
80106fef:	c3                   	ret    

80106ff0 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106ff0:	55                   	push   %ebp
80106ff1:	89 e5                	mov    %esp,%ebp
80106ff3:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107004:	e8 c8 ea ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80107009:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010700c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107010:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107017:	e8 b5 ea ff ff       	call   80105ad1 <argint>

  set_curr_disk(disk, vc_num);
8010701c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010701f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107022:	89 54 24 04          	mov    %edx,0x4(%esp)
80107026:	89 04 24             	mov    %eax,(%esp)
80107029:	e8 c2 25 00 00       	call   801095f0 <set_curr_disk>
}
8010702e:	c9                   	leave  
8010702f:	c3                   	ret    

80107030 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80107030:	55                   	push   %ebp
80107031:	89 e5                	mov    %esp,%ebp
80107033:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80107036:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107039:	89 44 24 04          	mov    %eax,0x4(%esp)
8010703d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107044:	e8 88 ea ff ff       	call   80105ad1 <argint>

  int vc_num;
  argint(1, &vc_num);
80107049:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010704c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107050:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107057:	e8 75 ea ff ff       	call   80105ad1 <argint>

  set_curr_proc(proc, vc_num);
8010705c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010705f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107062:	89 54 24 04          	mov    %edx,0x4(%esp)
80107066:	89 04 24             	mov    %eax,(%esp)
80107069:	e8 29 26 00 00       	call   80109697 <set_curr_proc>
}
8010706e:	c9                   	leave  
8010706f:	c3                   	ret    

80107070 <sys_container_reset>:

void sys_container_reset(void){
80107070:	55                   	push   %ebp
80107071:	89 e5                	mov    %esp,%ebp
80107073:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
80107076:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107079:	89 44 24 04          	mov    %eax,0x4(%esp)
8010707d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107084:	e8 48 ea ff ff       	call   80105ad1 <argint>
  container_reset(vc_num);
80107089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708c:	89 04 24             	mov    %eax,(%esp)
8010708f:	e8 b9 27 00 00       	call   8010984d <container_reset>
}
80107094:	c9                   	leave  
80107095:	c3                   	ret    

80107096 <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107096:	55                   	push   %ebp
80107097:	89 e5                	mov    %esp,%ebp
80107099:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010709c:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
801070a3:	e8 93 e4 ff ff       	call   8010553b <acquire>
  xticks = ticks;
801070a8:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
801070ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801070b0:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
801070b7:	e8 e9 e4 ff ff       	call   801055a5 <release>
  return xticks;
801070bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070bf:	c9                   	leave  
801070c0:	c3                   	ret    

801070c1 <sys_getticks>:

int
sys_getticks(void){
801070c1:	55                   	push   %ebp
801070c2:	89 e5                	mov    %esp,%ebp
801070c4:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
801070c7:	e8 8f d4 ff ff       	call   8010455b <myproc>
801070cc:	8b 40 7c             	mov    0x7c(%eax),%eax
}
801070cf:	c9                   	leave  
801070d0:	c3                   	ret    

801070d1 <sys_max_containers>:

int sys_max_containers(void){
801070d1:	55                   	push   %ebp
801070d2:	89 e5                	mov    %esp,%ebp
801070d4:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
801070d7:	e8 52 26 00 00       	call   8010972e <max_containers>
}
801070dc:	c9                   	leave  
801070dd:	c3                   	ret    

801070de <sys_df>:


void sys_df(void){
801070de:	55                   	push   %ebp
801070df:	89 e5                	mov    %esp,%ebp
801070e1:	53                   	push   %ebx
801070e2:	83 ec 54             	sub    $0x54,%esp
  struct container* cont = myproc()->cont;
801070e5:	e8 71 d4 ff ff       	call   8010455b <myproc>
801070ea:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801070f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
801070f3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801070f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801070fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107101:	e8 ba a3 ff ff       	call   801014c0 <readsb>

  cprintf("nblocks: %d\n", sb.nblocks);
80107106:	8b 45 c8             	mov    -0x38(%ebp),%eax
80107109:	89 44 24 04          	mov    %eax,0x4(%esp)
8010710d:	c7 04 24 4d 9f 10 80 	movl   $0x80109f4d,(%esp)
80107114:	e8 a8 92 ff ff       	call   801003c1 <cprintf>
  cprintf("nblocks: %d\n", FSSIZE);
80107119:	c7 44 24 04 20 4e 00 	movl   $0x4e20,0x4(%esp)
80107120:	00 
80107121:	c7 04 24 4d 9f 10 80 	movl   $0x80109f4d,(%esp)
80107128:	e8 94 92 ff ff       	call   801003c1 <cprintf>
  int used = 0;
8010712d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80107134:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107138:	75 52                	jne    8010718c <sys_df+0xae>
    int max = max_containers();
8010713a:	e8 ef 25 00 00       	call   8010972e <max_containers>
8010713f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
80107142:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80107149:	eb 1d                	jmp    80107168 <sys_df+0x8a>
      used = used + (int)(get_curr_disk(i) / 1024);
8010714b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010714e:	89 04 24             	mov    %eax,(%esp)
80107151:	e8 dd 22 00 00       	call   80109433 <get_curr_disk>
80107156:	85 c0                	test   %eax,%eax
80107158:	79 05                	jns    8010715f <sys_df+0x81>
8010715a:	05 ff 03 00 00       	add    $0x3ff,%eax
8010715f:	c1 f8 0a             	sar    $0xa,%eax
80107162:	01 45 f4             	add    %eax,-0xc(%ebp)
  cprintf("nblocks: %d\n", FSSIZE);
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
80107165:	ff 45 f0             	incl   -0x10(%ebp)
80107168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010716b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010716e:	7c db                	jl     8010714b <sys_df+0x6d>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: %d\n", used, sb.nblocks);
80107170:	8b 45 c8             	mov    -0x38(%ebp),%eax
80107173:	89 44 24 08          	mov    %eax,0x8(%esp)
80107177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010717e:	c7 04 24 5c 9f 10 80 	movl   $0x80109f5c,(%esp)
80107185:	e8 37 92 ff ff       	call   801003c1 <cprintf>
8010718a:	eb 5e                	jmp    801071ea <sys_df+0x10c>
  }
  else{
    int x = find(cont->name);
8010718c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010718f:	83 c0 18             	add    $0x18,%eax
80107192:	89 04 24             	mov    %eax,(%esp)
80107195:	e8 c1 20 00 00       	call   8010925b <find>
8010719a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
8010719d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071a0:	89 04 24             	mov    %eax,(%esp)
801071a3:	e8 8b 22 00 00       	call   80109433 <get_curr_disk>
801071a8:	85 c0                	test   %eax,%eax
801071aa:	79 05                	jns    801071b1 <sys_df+0xd3>
801071ac:	05 ff 03 00 00       	add    $0x3ff,%eax
801071b1:	c1 f8 0a             	sar    $0xa,%eax
801071b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d -- %d  / Disk Available: %d\n", used, get_curr_disk(x),  get_max_disk(x));
801071b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071ba:	89 04 24             	mov    %eax,(%esp)
801071bd:	e8 b1 21 00 00       	call   80109373 <get_max_disk>
801071c2:	89 c3                	mov    %eax,%ebx
801071c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071c7:	89 04 24             	mov    %eax,(%esp)
801071ca:	e8 64 22 00 00       	call   80109433 <get_curr_disk>
801071cf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801071d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801071d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801071da:	89 44 24 04          	mov    %eax,0x4(%esp)
801071de:	c7 04 24 90 9f 10 80 	movl   $0x80109f90,(%esp)
801071e5:	e8 d7 91 ff ff       	call   801003c1 <cprintf>
  }
}
801071ea:	83 c4 54             	add    $0x54,%esp
801071ed:	5b                   	pop    %ebx
801071ee:	5d                   	pop    %ebp
801071ef:	c3                   	ret    

801071f0 <sys_pause>:



void
sys_pause(void){
801071f0:	55                   	push   %ebp
801071f1:	89 e5                	mov    %esp,%ebp
801071f3:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
801071f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801071fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107204:	e8 5f e9 ff ff       	call   80105b68 <argstr>
  pause(name);
80107209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720c:	89 04 24             	mov    %eax,(%esp)
8010720f:	e8 f7 e0 ff ff       	call   8010530b <pause>
}
80107214:	c9                   	leave  
80107215:	c3                   	ret    

80107216 <sys_resume>:

void
sys_resume(void){
80107216:	55                   	push   %ebp
80107217:	89 e5                	mov    %esp,%ebp
80107219:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
8010721c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010721f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010722a:	e8 39 e9 ff ff       	call   80105b68 <argstr>
  resume(name);
8010722f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107232:	89 04 24             	mov    %eax,(%esp)
80107235:	e8 34 e1 ff ff       	call   8010536e <resume>
}
8010723a:	c9                   	leave  
8010723b:	c3                   	ret    

8010723c <sys_tmem>:

int
sys_tmem(void){
8010723c:	55                   	push   %ebp
8010723d:	89 e5                	mov    %esp,%ebp
8010723f:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
80107242:	e8 14 d3 ff ff       	call   8010455b <myproc>
80107247:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010724d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80107250:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107254:	75 07                	jne    8010725d <sys_tmem+0x21>
    return mem_usage();
80107256:	e8 29 bd ff ff       	call   80102f84 <mem_usage>
8010725b:	eb 16                	jmp    80107273 <sys_tmem+0x37>
  }
  return get_curr_mem(find(cont->name));
8010725d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107260:	83 c0 18             	add    $0x18,%eax
80107263:	89 04 24             	mov    %eax,(%esp)
80107266:	e8 f0 1f 00 00       	call   8010925b <find>
8010726b:	89 04 24             	mov    %eax,(%esp)
8010726e:	e8 80 21 00 00       	call   801093f3 <get_curr_mem>
}
80107273:	c9                   	leave  
80107274:	c3                   	ret    

80107275 <sys_amem>:

int
sys_amem(void){
80107275:	55                   	push   %ebp
80107276:	89 e5                	mov    %esp,%ebp
80107278:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
8010727b:	e8 db d2 ff ff       	call   8010455b <myproc>
80107280:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107286:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80107289:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010728d:	75 07                	jne    80107296 <sys_amem+0x21>
    return mem_avail();
8010728f:	e8 fa bc ff ff       	call   80102f8e <mem_avail>
80107294:	eb 16                	jmp    801072ac <sys_amem+0x37>
  }
  return get_max_mem(find(cont->name));
80107296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107299:	83 c0 18             	add    $0x18,%eax
8010729c:	89 04 24             	mov    %eax,(%esp)
8010729f:	e8 b7 1f 00 00       	call   8010925b <find>
801072a4:	89 04 24             	mov    %eax,(%esp)
801072a7:	e8 87 20 00 00       	call   80109333 <get_max_mem>
}
801072ac:	c9                   	leave  
801072ad:	c3                   	ret    
	...

801072b0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801072b0:	1e                   	push   %ds
  pushl %es
801072b1:	06                   	push   %es
  pushl %fs
801072b2:	0f a0                	push   %fs
  pushl %gs
801072b4:	0f a8                	push   %gs
  pushal
801072b6:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801072b7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801072bb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801072bd:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801072bf:	54                   	push   %esp
  call trap
801072c0:	e8 c0 01 00 00       	call   80107485 <trap>
  addl $4, %esp
801072c5:	83 c4 04             	add    $0x4,%esp

801072c8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801072c8:	61                   	popa   
  popl %gs
801072c9:	0f a9                	pop    %gs
  popl %fs
801072cb:	0f a1                	pop    %fs
  popl %es
801072cd:	07                   	pop    %es
  popl %ds
801072ce:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801072cf:	83 c4 08             	add    $0x8,%esp
  iret
801072d2:	cf                   	iret   
	...

801072d4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801072d4:	55                   	push   %ebp
801072d5:	89 e5                	mov    %esp,%ebp
801072d7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801072da:	8b 45 0c             	mov    0xc(%ebp),%eax
801072dd:	48                   	dec    %eax
801072de:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801072e2:	8b 45 08             	mov    0x8(%ebp),%eax
801072e5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801072e9:	8b 45 08             	mov    0x8(%ebp),%eax
801072ec:	c1 e8 10             	shr    $0x10,%eax
801072ef:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801072f3:	8d 45 fa             	lea    -0x6(%ebp),%eax
801072f6:	0f 01 18             	lidtl  (%eax)
}
801072f9:	c9                   	leave  
801072fa:	c3                   	ret    

801072fb <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801072fb:	55                   	push   %ebp
801072fc:	89 e5                	mov    %esp,%ebp
801072fe:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107301:	0f 20 d0             	mov    %cr2,%eax
80107304:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107307:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010730a:	c9                   	leave  
8010730b:	c3                   	ret    

8010730c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010730c:	55                   	push   %ebp
8010730d:	89 e5                	mov    %esp,%ebp
8010730f:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107312:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107319:	e9 b8 00 00 00       	jmp    801073d6 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107321:	8b 04 85 10 d1 10 80 	mov    -0x7fef2ef0(,%eax,4),%eax
80107328:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010732b:	66 89 04 d5 e0 83 11 	mov    %ax,-0x7fee7c20(,%edx,8)
80107332:	80 
80107333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107336:	66 c7 04 c5 e2 83 11 	movw   $0x8,-0x7fee7c1e(,%eax,8)
8010733d:	80 08 00 
80107340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107343:	8a 14 c5 e4 83 11 80 	mov    -0x7fee7c1c(,%eax,8),%dl
8010734a:	83 e2 e0             	and    $0xffffffe0,%edx
8010734d:	88 14 c5 e4 83 11 80 	mov    %dl,-0x7fee7c1c(,%eax,8)
80107354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107357:	8a 14 c5 e4 83 11 80 	mov    -0x7fee7c1c(,%eax,8),%dl
8010735e:	83 e2 1f             	and    $0x1f,%edx
80107361:	88 14 c5 e4 83 11 80 	mov    %dl,-0x7fee7c1c(,%eax,8)
80107368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736b:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
80107372:	83 e2 f0             	and    $0xfffffff0,%edx
80107375:	83 ca 0e             	or     $0xe,%edx
80107378:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
8010737f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107382:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
80107389:	83 e2 ef             	and    $0xffffffef,%edx
8010738c:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
80107393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107396:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
8010739d:	83 e2 9f             	and    $0xffffff9f,%edx
801073a0:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
801073a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073aa:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
801073b1:	83 ca 80             	or     $0xffffff80,%edx
801073b4:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
801073bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073be:	8b 04 85 10 d1 10 80 	mov    -0x7fef2ef0(,%eax,4),%eax
801073c5:	c1 e8 10             	shr    $0x10,%eax
801073c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801073cb:	66 89 04 d5 e6 83 11 	mov    %ax,-0x7fee7c1a(,%edx,8)
801073d2:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801073d3:	ff 45 f4             	incl   -0xc(%ebp)
801073d6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801073dd:	0f 8e 3b ff ff ff    	jle    8010731e <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801073e3:	a1 10 d2 10 80       	mov    0x8010d210,%eax
801073e8:	66 a3 e0 85 11 80    	mov    %ax,0x801185e0
801073ee:	66 c7 05 e2 85 11 80 	movw   $0x8,0x801185e2
801073f5:	08 00 
801073f7:	a0 e4 85 11 80       	mov    0x801185e4,%al
801073fc:	83 e0 e0             	and    $0xffffffe0,%eax
801073ff:	a2 e4 85 11 80       	mov    %al,0x801185e4
80107404:	a0 e4 85 11 80       	mov    0x801185e4,%al
80107409:	83 e0 1f             	and    $0x1f,%eax
8010740c:	a2 e4 85 11 80       	mov    %al,0x801185e4
80107411:	a0 e5 85 11 80       	mov    0x801185e5,%al
80107416:	83 c8 0f             	or     $0xf,%eax
80107419:	a2 e5 85 11 80       	mov    %al,0x801185e5
8010741e:	a0 e5 85 11 80       	mov    0x801185e5,%al
80107423:	83 e0 ef             	and    $0xffffffef,%eax
80107426:	a2 e5 85 11 80       	mov    %al,0x801185e5
8010742b:	a0 e5 85 11 80       	mov    0x801185e5,%al
80107430:	83 c8 60             	or     $0x60,%eax
80107433:	a2 e5 85 11 80       	mov    %al,0x801185e5
80107438:	a0 e5 85 11 80       	mov    0x801185e5,%al
8010743d:	83 c8 80             	or     $0xffffff80,%eax
80107440:	a2 e5 85 11 80       	mov    %al,0x801185e5
80107445:	a1 10 d2 10 80       	mov    0x8010d210,%eax
8010744a:	c1 e8 10             	shr    $0x10,%eax
8010744d:	66 a3 e6 85 11 80    	mov    %ax,0x801185e6

  initlock(&tickslock, "time");
80107453:	c7 44 24 04 bc 9f 10 	movl   $0x80109fbc,0x4(%esp)
8010745a:	80 
8010745b:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80107462:	e8 b3 e0 ff ff       	call   8010551a <initlock>
}
80107467:	c9                   	leave  
80107468:	c3                   	ret    

80107469 <idtinit>:

void
idtinit(void)
{
80107469:	55                   	push   %ebp
8010746a:	89 e5                	mov    %esp,%ebp
8010746c:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010746f:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107476:	00 
80107477:	c7 04 24 e0 83 11 80 	movl   $0x801183e0,(%esp)
8010747e:	e8 51 fe ff ff       	call   801072d4 <lidt>
}
80107483:	c9                   	leave  
80107484:	c3                   	ret    

80107485 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107485:	55                   	push   %ebp
80107486:	89 e5                	mov    %esp,%ebp
80107488:	57                   	push   %edi
80107489:	56                   	push   %esi
8010748a:	53                   	push   %ebx
8010748b:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010748e:	8b 45 08             	mov    0x8(%ebp),%eax
80107491:	8b 40 30             	mov    0x30(%eax),%eax
80107494:	83 f8 40             	cmp    $0x40,%eax
80107497:	75 3c                	jne    801074d5 <trap+0x50>
    if(myproc()->killed)
80107499:	e8 bd d0 ff ff       	call   8010455b <myproc>
8010749e:	8b 40 24             	mov    0x24(%eax),%eax
801074a1:	85 c0                	test   %eax,%eax
801074a3:	74 05                	je     801074aa <trap+0x25>
      exit();
801074a5:	e8 42 d5 ff ff       	call   801049ec <exit>
    myproc()->tf = tf;
801074aa:	e8 ac d0 ff ff       	call   8010455b <myproc>
801074af:	8b 55 08             	mov    0x8(%ebp),%edx
801074b2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801074b5:	e8 e5 e6 ff ff       	call   80105b9f <syscall>
    if(myproc()->killed)
801074ba:	e8 9c d0 ff ff       	call   8010455b <myproc>
801074bf:	8b 40 24             	mov    0x24(%eax),%eax
801074c2:	85 c0                	test   %eax,%eax
801074c4:	74 0a                	je     801074d0 <trap+0x4b>
      exit();
801074c6:	e8 21 d5 ff ff       	call   801049ec <exit>
    return;
801074cb:	e9 30 02 00 00       	jmp    80107700 <trap+0x27b>
801074d0:	e9 2b 02 00 00       	jmp    80107700 <trap+0x27b>
  }

  switch(tf->trapno){
801074d5:	8b 45 08             	mov    0x8(%ebp),%eax
801074d8:	8b 40 30             	mov    0x30(%eax),%eax
801074db:	83 e8 20             	sub    $0x20,%eax
801074de:	83 f8 1f             	cmp    $0x1f,%eax
801074e1:	0f 87 cb 00 00 00    	ja     801075b2 <trap+0x12d>
801074e7:	8b 04 85 64 a0 10 80 	mov    -0x7fef5f9c(,%eax,4),%eax
801074ee:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801074f0:	e8 9d cf ff ff       	call   80104492 <cpuid>
801074f5:	85 c0                	test   %eax,%eax
801074f7:	75 2f                	jne    80107528 <trap+0xa3>
      acquire(&tickslock);
801074f9:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80107500:	e8 36 e0 ff ff       	call   8010553b <acquire>
      ticks++;
80107505:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
8010750a:	40                   	inc    %eax
8010750b:	a3 e0 8b 11 80       	mov    %eax,0x80118be0
      wakeup(&ticks);
80107510:	c7 04 24 e0 8b 11 80 	movl   $0x80118be0,(%esp)
80107517:	e8 c7 d9 ff ff       	call   80104ee3 <wakeup>
      release(&tickslock);
8010751c:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80107523:	e8 7d e0 ff ff       	call   801055a5 <release>
    }
    p = myproc();
80107528:	e8 2e d0 ff ff       	call   8010455b <myproc>
8010752d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80107530:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107534:	74 0f                	je     80107545 <trap+0xc0>
      p->ticks++;
80107536:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107539:	8b 40 7c             	mov    0x7c(%eax),%eax
8010753c:	8d 50 01             	lea    0x1(%eax),%edx
8010753f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107542:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80107545:	e8 c1 bd ff ff       	call   8010330b <lapiceoi>
    break;
8010754a:	e9 35 01 00 00       	jmp    80107684 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010754f:	e8 2e b5 ff ff       	call   80102a82 <ideintr>
    lapiceoi();
80107554:	e8 b2 bd ff ff       	call   8010330b <lapiceoi>
    break;
80107559:	e9 26 01 00 00       	jmp    80107684 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010755e:	e8 bf bb ff ff       	call   80103122 <kbdintr>
    lapiceoi();
80107563:	e8 a3 bd ff ff       	call   8010330b <lapiceoi>
    break;
80107568:	e9 17 01 00 00       	jmp    80107684 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010756d:	e8 6f 03 00 00       	call   801078e1 <uartintr>
    lapiceoi();
80107572:	e8 94 bd ff ff       	call   8010330b <lapiceoi>
    break;
80107577:	e9 08 01 00 00       	jmp    80107684 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010757c:	8b 45 08             	mov    0x8(%ebp),%eax
8010757f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107582:	8b 45 08             	mov    0x8(%ebp),%eax
80107585:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107588:	0f b7 d8             	movzwl %ax,%ebx
8010758b:	e8 02 cf ff ff       	call   80104492 <cpuid>
80107590:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107594:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010759c:	c7 04 24 c4 9f 10 80 	movl   $0x80109fc4,(%esp)
801075a3:	e8 19 8e ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801075a8:	e8 5e bd ff ff       	call   8010330b <lapiceoi>
    break;
801075ad:	e9 d2 00 00 00       	jmp    80107684 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801075b2:	e8 a4 cf ff ff       	call   8010455b <myproc>
801075b7:	85 c0                	test   %eax,%eax
801075b9:	74 10                	je     801075cb <trap+0x146>
801075bb:	8b 45 08             	mov    0x8(%ebp),%eax
801075be:	8b 40 3c             	mov    0x3c(%eax),%eax
801075c1:	0f b7 c0             	movzwl %ax,%eax
801075c4:	83 e0 03             	and    $0x3,%eax
801075c7:	85 c0                	test   %eax,%eax
801075c9:	75 40                	jne    8010760b <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801075cb:	e8 2b fd ff ff       	call   801072fb <rcr2>
801075d0:	89 c3                	mov    %eax,%ebx
801075d2:	8b 45 08             	mov    0x8(%ebp),%eax
801075d5:	8b 70 38             	mov    0x38(%eax),%esi
801075d8:	e8 b5 ce ff ff       	call   80104492 <cpuid>
801075dd:	8b 55 08             	mov    0x8(%ebp),%edx
801075e0:	8b 52 30             	mov    0x30(%edx),%edx
801075e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801075e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
801075eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801075ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801075f3:	c7 04 24 e8 9f 10 80 	movl   $0x80109fe8,(%esp)
801075fa:	e8 c2 8d ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801075ff:	c7 04 24 1a a0 10 80 	movl   $0x8010a01a,(%esp)
80107606:	e8 49 8f ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010760b:	e8 eb fc ff ff       	call   801072fb <rcr2>
80107610:	89 c6                	mov    %eax,%esi
80107612:	8b 45 08             	mov    0x8(%ebp),%eax
80107615:	8b 40 38             	mov    0x38(%eax),%eax
80107618:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010761b:	e8 72 ce ff ff       	call   80104492 <cpuid>
80107620:	89 c3                	mov    %eax,%ebx
80107622:	8b 45 08             	mov    0x8(%ebp),%eax
80107625:	8b 78 34             	mov    0x34(%eax),%edi
80107628:	89 7d d0             	mov    %edi,-0x30(%ebp)
8010762b:	8b 45 08             	mov    0x8(%ebp),%eax
8010762e:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80107631:	e8 25 cf ff ff       	call   8010455b <myproc>
80107636:	8d 50 6c             	lea    0x6c(%eax),%edx
80107639:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010763c:	e8 1a cf ff ff       	call   8010455b <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107641:	8b 40 10             	mov    0x10(%eax),%eax
80107644:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80107648:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010764b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
8010764f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107653:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80107656:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010765a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010765e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107661:	89 54 24 08          	mov    %edx,0x8(%esp)
80107665:	89 44 24 04          	mov    %eax,0x4(%esp)
80107669:	c7 04 24 20 a0 10 80 	movl   $0x8010a020,(%esp)
80107670:	e8 4c 8d ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107675:	e8 e1 ce ff ff       	call   8010455b <myproc>
8010767a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107681:	eb 01                	jmp    80107684 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107683:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107684:	e8 d2 ce ff ff       	call   8010455b <myproc>
80107689:	85 c0                	test   %eax,%eax
8010768b:	74 22                	je     801076af <trap+0x22a>
8010768d:	e8 c9 ce ff ff       	call   8010455b <myproc>
80107692:	8b 40 24             	mov    0x24(%eax),%eax
80107695:	85 c0                	test   %eax,%eax
80107697:	74 16                	je     801076af <trap+0x22a>
80107699:	8b 45 08             	mov    0x8(%ebp),%eax
8010769c:	8b 40 3c             	mov    0x3c(%eax),%eax
8010769f:	0f b7 c0             	movzwl %ax,%eax
801076a2:	83 e0 03             	and    $0x3,%eax
801076a5:	83 f8 03             	cmp    $0x3,%eax
801076a8:	75 05                	jne    801076af <trap+0x22a>
    exit();
801076aa:	e8 3d d3 ff ff       	call   801049ec <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801076af:	e8 a7 ce ff ff       	call   8010455b <myproc>
801076b4:	85 c0                	test   %eax,%eax
801076b6:	74 1d                	je     801076d5 <trap+0x250>
801076b8:	e8 9e ce ff ff       	call   8010455b <myproc>
801076bd:	8b 40 0c             	mov    0xc(%eax),%eax
801076c0:	83 f8 04             	cmp    $0x4,%eax
801076c3:	75 10                	jne    801076d5 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801076c5:	8b 45 08             	mov    0x8(%ebp),%eax
801076c8:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801076cb:	83 f8 20             	cmp    $0x20,%eax
801076ce:	75 05                	jne    801076d5 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
801076d0:	e8 c7 d6 ff ff       	call   80104d9c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801076d5:	e8 81 ce ff ff       	call   8010455b <myproc>
801076da:	85 c0                	test   %eax,%eax
801076dc:	74 22                	je     80107700 <trap+0x27b>
801076de:	e8 78 ce ff ff       	call   8010455b <myproc>
801076e3:	8b 40 24             	mov    0x24(%eax),%eax
801076e6:	85 c0                	test   %eax,%eax
801076e8:	74 16                	je     80107700 <trap+0x27b>
801076ea:	8b 45 08             	mov    0x8(%ebp),%eax
801076ed:	8b 40 3c             	mov    0x3c(%eax),%eax
801076f0:	0f b7 c0             	movzwl %ax,%eax
801076f3:	83 e0 03             	and    $0x3,%eax
801076f6:	83 f8 03             	cmp    $0x3,%eax
801076f9:	75 05                	jne    80107700 <trap+0x27b>
    exit();
801076fb:	e8 ec d2 ff ff       	call   801049ec <exit>
}
80107700:	83 c4 4c             	add    $0x4c,%esp
80107703:	5b                   	pop    %ebx
80107704:	5e                   	pop    %esi
80107705:	5f                   	pop    %edi
80107706:	5d                   	pop    %ebp
80107707:	c3                   	ret    

80107708 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107708:	55                   	push   %ebp
80107709:	89 e5                	mov    %esp,%ebp
8010770b:	83 ec 14             	sub    $0x14,%esp
8010770e:	8b 45 08             	mov    0x8(%ebp),%eax
80107711:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107715:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107718:	89 c2                	mov    %eax,%edx
8010771a:	ec                   	in     (%dx),%al
8010771b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010771e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80107721:	c9                   	leave  
80107722:	c3                   	ret    

80107723 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107723:	55                   	push   %ebp
80107724:	89 e5                	mov    %esp,%ebp
80107726:	83 ec 08             	sub    $0x8,%esp
80107729:	8b 45 08             	mov    0x8(%ebp),%eax
8010772c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010772f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107733:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107736:	8a 45 f8             	mov    -0x8(%ebp),%al
80107739:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010773c:	ee                   	out    %al,(%dx)
}
8010773d:	c9                   	leave  
8010773e:	c3                   	ret    

8010773f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010773f:	55                   	push   %ebp
80107740:	89 e5                	mov    %esp,%ebp
80107742:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107745:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010774c:	00 
8010774d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107754:	e8 ca ff ff ff       	call   80107723 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107759:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107760:	00 
80107761:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107768:	e8 b6 ff ff ff       	call   80107723 <outb>
  outb(COM1+0, 115200/9600);
8010776d:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107774:	00 
80107775:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010777c:	e8 a2 ff ff ff       	call   80107723 <outb>
  outb(COM1+1, 0);
80107781:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107788:	00 
80107789:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107790:	e8 8e ff ff ff       	call   80107723 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107795:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010779c:	00 
8010779d:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801077a4:	e8 7a ff ff ff       	call   80107723 <outb>
  outb(COM1+4, 0);
801077a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077b0:	00 
801077b1:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801077b8:	e8 66 ff ff ff       	call   80107723 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801077bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801077c4:	00 
801077c5:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801077cc:	e8 52 ff ff ff       	call   80107723 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801077d1:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801077d8:	e8 2b ff ff ff       	call   80107708 <inb>
801077dd:	3c ff                	cmp    $0xff,%al
801077df:	75 02                	jne    801077e3 <uartinit+0xa4>
    return;
801077e1:	eb 5b                	jmp    8010783e <uartinit+0xff>
  uart = 1;
801077e3:	c7 05 24 d9 10 80 01 	movl   $0x1,0x8010d924
801077ea:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801077ed:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801077f4:	e8 0f ff ff ff       	call   80107708 <inb>
  inb(COM1+0);
801077f9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107800:	e8 03 ff ff ff       	call   80107708 <inb>
  ioapicenable(IRQ_COM1, 0);
80107805:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010780c:	00 
8010780d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107814:	e8 de b4 ff ff       	call   80102cf7 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107819:	c7 45 f4 e4 a0 10 80 	movl   $0x8010a0e4,-0xc(%ebp)
80107820:	eb 13                	jmp    80107835 <uartinit+0xf6>
    uartputc(*p);
80107822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107825:	8a 00                	mov    (%eax),%al
80107827:	0f be c0             	movsbl %al,%eax
8010782a:	89 04 24             	mov    %eax,(%esp)
8010782d:	e8 0e 00 00 00       	call   80107840 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107832:	ff 45 f4             	incl   -0xc(%ebp)
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	8a 00                	mov    (%eax),%al
8010783a:	84 c0                	test   %al,%al
8010783c:	75 e4                	jne    80107822 <uartinit+0xe3>
    uartputc(*p);
}
8010783e:	c9                   	leave  
8010783f:	c3                   	ret    

80107840 <uartputc>:

void
uartputc(int c)
{
80107840:	55                   	push   %ebp
80107841:	89 e5                	mov    %esp,%ebp
80107843:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107846:	a1 24 d9 10 80       	mov    0x8010d924,%eax
8010784b:	85 c0                	test   %eax,%eax
8010784d:	75 02                	jne    80107851 <uartputc+0x11>
    return;
8010784f:	eb 4a                	jmp    8010789b <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107851:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107858:	eb 0f                	jmp    80107869 <uartputc+0x29>
    microdelay(10);
8010785a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107861:	e8 ca ba ff ff       	call   80103330 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107866:	ff 45 f4             	incl   -0xc(%ebp)
80107869:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010786d:	7f 16                	jg     80107885 <uartputc+0x45>
8010786f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107876:	e8 8d fe ff ff       	call   80107708 <inb>
8010787b:	0f b6 c0             	movzbl %al,%eax
8010787e:	83 e0 20             	and    $0x20,%eax
80107881:	85 c0                	test   %eax,%eax
80107883:	74 d5                	je     8010785a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107885:	8b 45 08             	mov    0x8(%ebp),%eax
80107888:	0f b6 c0             	movzbl %al,%eax
8010788b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010788f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107896:	e8 88 fe ff ff       	call   80107723 <outb>
}
8010789b:	c9                   	leave  
8010789c:	c3                   	ret    

8010789d <uartgetc>:

static int
uartgetc(void)
{
8010789d:	55                   	push   %ebp
8010789e:	89 e5                	mov    %esp,%ebp
801078a0:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801078a3:	a1 24 d9 10 80       	mov    0x8010d924,%eax
801078a8:	85 c0                	test   %eax,%eax
801078aa:	75 07                	jne    801078b3 <uartgetc+0x16>
    return -1;
801078ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078b1:	eb 2c                	jmp    801078df <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801078b3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801078ba:	e8 49 fe ff ff       	call   80107708 <inb>
801078bf:	0f b6 c0             	movzbl %al,%eax
801078c2:	83 e0 01             	and    $0x1,%eax
801078c5:	85 c0                	test   %eax,%eax
801078c7:	75 07                	jne    801078d0 <uartgetc+0x33>
    return -1;
801078c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078ce:	eb 0f                	jmp    801078df <uartgetc+0x42>
  return inb(COM1+0);
801078d0:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801078d7:	e8 2c fe ff ff       	call   80107708 <inb>
801078dc:	0f b6 c0             	movzbl %al,%eax
}
801078df:	c9                   	leave  
801078e0:	c3                   	ret    

801078e1 <uartintr>:

void
uartintr(void)
{
801078e1:	55                   	push   %ebp
801078e2:	89 e5                	mov    %esp,%ebp
801078e4:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801078e7:	c7 04 24 9d 78 10 80 	movl   $0x8010789d,(%esp)
801078ee:	e8 02 8f ff ff       	call   801007f5 <consoleintr>
}
801078f3:	c9                   	leave  
801078f4:	c3                   	ret    
801078f5:	00 00                	add    %al,(%eax)
	...

801078f8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $0
801078fa:	6a 00                	push   $0x0
  jmp alltraps
801078fc:	e9 af f9 ff ff       	jmp    801072b0 <alltraps>

80107901 <vector1>:
.globl vector1
vector1:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $1
80107903:	6a 01                	push   $0x1
  jmp alltraps
80107905:	e9 a6 f9 ff ff       	jmp    801072b0 <alltraps>

8010790a <vector2>:
.globl vector2
vector2:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $2
8010790c:	6a 02                	push   $0x2
  jmp alltraps
8010790e:	e9 9d f9 ff ff       	jmp    801072b0 <alltraps>

80107913 <vector3>:
.globl vector3
vector3:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $3
80107915:	6a 03                	push   $0x3
  jmp alltraps
80107917:	e9 94 f9 ff ff       	jmp    801072b0 <alltraps>

8010791c <vector4>:
.globl vector4
vector4:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $4
8010791e:	6a 04                	push   $0x4
  jmp alltraps
80107920:	e9 8b f9 ff ff       	jmp    801072b0 <alltraps>

80107925 <vector5>:
.globl vector5
vector5:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $5
80107927:	6a 05                	push   $0x5
  jmp alltraps
80107929:	e9 82 f9 ff ff       	jmp    801072b0 <alltraps>

8010792e <vector6>:
.globl vector6
vector6:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $6
80107930:	6a 06                	push   $0x6
  jmp alltraps
80107932:	e9 79 f9 ff ff       	jmp    801072b0 <alltraps>

80107937 <vector7>:
.globl vector7
vector7:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $7
80107939:	6a 07                	push   $0x7
  jmp alltraps
8010793b:	e9 70 f9 ff ff       	jmp    801072b0 <alltraps>

80107940 <vector8>:
.globl vector8
vector8:
  pushl $8
80107940:	6a 08                	push   $0x8
  jmp alltraps
80107942:	e9 69 f9 ff ff       	jmp    801072b0 <alltraps>

80107947 <vector9>:
.globl vector9
vector9:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $9
80107949:	6a 09                	push   $0x9
  jmp alltraps
8010794b:	e9 60 f9 ff ff       	jmp    801072b0 <alltraps>

80107950 <vector10>:
.globl vector10
vector10:
  pushl $10
80107950:	6a 0a                	push   $0xa
  jmp alltraps
80107952:	e9 59 f9 ff ff       	jmp    801072b0 <alltraps>

80107957 <vector11>:
.globl vector11
vector11:
  pushl $11
80107957:	6a 0b                	push   $0xb
  jmp alltraps
80107959:	e9 52 f9 ff ff       	jmp    801072b0 <alltraps>

8010795e <vector12>:
.globl vector12
vector12:
  pushl $12
8010795e:	6a 0c                	push   $0xc
  jmp alltraps
80107960:	e9 4b f9 ff ff       	jmp    801072b0 <alltraps>

80107965 <vector13>:
.globl vector13
vector13:
  pushl $13
80107965:	6a 0d                	push   $0xd
  jmp alltraps
80107967:	e9 44 f9 ff ff       	jmp    801072b0 <alltraps>

8010796c <vector14>:
.globl vector14
vector14:
  pushl $14
8010796c:	6a 0e                	push   $0xe
  jmp alltraps
8010796e:	e9 3d f9 ff ff       	jmp    801072b0 <alltraps>

80107973 <vector15>:
.globl vector15
vector15:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $15
80107975:	6a 0f                	push   $0xf
  jmp alltraps
80107977:	e9 34 f9 ff ff       	jmp    801072b0 <alltraps>

8010797c <vector16>:
.globl vector16
vector16:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $16
8010797e:	6a 10                	push   $0x10
  jmp alltraps
80107980:	e9 2b f9 ff ff       	jmp    801072b0 <alltraps>

80107985 <vector17>:
.globl vector17
vector17:
  pushl $17
80107985:	6a 11                	push   $0x11
  jmp alltraps
80107987:	e9 24 f9 ff ff       	jmp    801072b0 <alltraps>

8010798c <vector18>:
.globl vector18
vector18:
  pushl $0
8010798c:	6a 00                	push   $0x0
  pushl $18
8010798e:	6a 12                	push   $0x12
  jmp alltraps
80107990:	e9 1b f9 ff ff       	jmp    801072b0 <alltraps>

80107995 <vector19>:
.globl vector19
vector19:
  pushl $0
80107995:	6a 00                	push   $0x0
  pushl $19
80107997:	6a 13                	push   $0x13
  jmp alltraps
80107999:	e9 12 f9 ff ff       	jmp    801072b0 <alltraps>

8010799e <vector20>:
.globl vector20
vector20:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $20
801079a0:	6a 14                	push   $0x14
  jmp alltraps
801079a2:	e9 09 f9 ff ff       	jmp    801072b0 <alltraps>

801079a7 <vector21>:
.globl vector21
vector21:
  pushl $0
801079a7:	6a 00                	push   $0x0
  pushl $21
801079a9:	6a 15                	push   $0x15
  jmp alltraps
801079ab:	e9 00 f9 ff ff       	jmp    801072b0 <alltraps>

801079b0 <vector22>:
.globl vector22
vector22:
  pushl $0
801079b0:	6a 00                	push   $0x0
  pushl $22
801079b2:	6a 16                	push   $0x16
  jmp alltraps
801079b4:	e9 f7 f8 ff ff       	jmp    801072b0 <alltraps>

801079b9 <vector23>:
.globl vector23
vector23:
  pushl $0
801079b9:	6a 00                	push   $0x0
  pushl $23
801079bb:	6a 17                	push   $0x17
  jmp alltraps
801079bd:	e9 ee f8 ff ff       	jmp    801072b0 <alltraps>

801079c2 <vector24>:
.globl vector24
vector24:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $24
801079c4:	6a 18                	push   $0x18
  jmp alltraps
801079c6:	e9 e5 f8 ff ff       	jmp    801072b0 <alltraps>

801079cb <vector25>:
.globl vector25
vector25:
  pushl $0
801079cb:	6a 00                	push   $0x0
  pushl $25
801079cd:	6a 19                	push   $0x19
  jmp alltraps
801079cf:	e9 dc f8 ff ff       	jmp    801072b0 <alltraps>

801079d4 <vector26>:
.globl vector26
vector26:
  pushl $0
801079d4:	6a 00                	push   $0x0
  pushl $26
801079d6:	6a 1a                	push   $0x1a
  jmp alltraps
801079d8:	e9 d3 f8 ff ff       	jmp    801072b0 <alltraps>

801079dd <vector27>:
.globl vector27
vector27:
  pushl $0
801079dd:	6a 00                	push   $0x0
  pushl $27
801079df:	6a 1b                	push   $0x1b
  jmp alltraps
801079e1:	e9 ca f8 ff ff       	jmp    801072b0 <alltraps>

801079e6 <vector28>:
.globl vector28
vector28:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $28
801079e8:	6a 1c                	push   $0x1c
  jmp alltraps
801079ea:	e9 c1 f8 ff ff       	jmp    801072b0 <alltraps>

801079ef <vector29>:
.globl vector29
vector29:
  pushl $0
801079ef:	6a 00                	push   $0x0
  pushl $29
801079f1:	6a 1d                	push   $0x1d
  jmp alltraps
801079f3:	e9 b8 f8 ff ff       	jmp    801072b0 <alltraps>

801079f8 <vector30>:
.globl vector30
vector30:
  pushl $0
801079f8:	6a 00                	push   $0x0
  pushl $30
801079fa:	6a 1e                	push   $0x1e
  jmp alltraps
801079fc:	e9 af f8 ff ff       	jmp    801072b0 <alltraps>

80107a01 <vector31>:
.globl vector31
vector31:
  pushl $0
80107a01:	6a 00                	push   $0x0
  pushl $31
80107a03:	6a 1f                	push   $0x1f
  jmp alltraps
80107a05:	e9 a6 f8 ff ff       	jmp    801072b0 <alltraps>

80107a0a <vector32>:
.globl vector32
vector32:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $32
80107a0c:	6a 20                	push   $0x20
  jmp alltraps
80107a0e:	e9 9d f8 ff ff       	jmp    801072b0 <alltraps>

80107a13 <vector33>:
.globl vector33
vector33:
  pushl $0
80107a13:	6a 00                	push   $0x0
  pushl $33
80107a15:	6a 21                	push   $0x21
  jmp alltraps
80107a17:	e9 94 f8 ff ff       	jmp    801072b0 <alltraps>

80107a1c <vector34>:
.globl vector34
vector34:
  pushl $0
80107a1c:	6a 00                	push   $0x0
  pushl $34
80107a1e:	6a 22                	push   $0x22
  jmp alltraps
80107a20:	e9 8b f8 ff ff       	jmp    801072b0 <alltraps>

80107a25 <vector35>:
.globl vector35
vector35:
  pushl $0
80107a25:	6a 00                	push   $0x0
  pushl $35
80107a27:	6a 23                	push   $0x23
  jmp alltraps
80107a29:	e9 82 f8 ff ff       	jmp    801072b0 <alltraps>

80107a2e <vector36>:
.globl vector36
vector36:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $36
80107a30:	6a 24                	push   $0x24
  jmp alltraps
80107a32:	e9 79 f8 ff ff       	jmp    801072b0 <alltraps>

80107a37 <vector37>:
.globl vector37
vector37:
  pushl $0
80107a37:	6a 00                	push   $0x0
  pushl $37
80107a39:	6a 25                	push   $0x25
  jmp alltraps
80107a3b:	e9 70 f8 ff ff       	jmp    801072b0 <alltraps>

80107a40 <vector38>:
.globl vector38
vector38:
  pushl $0
80107a40:	6a 00                	push   $0x0
  pushl $38
80107a42:	6a 26                	push   $0x26
  jmp alltraps
80107a44:	e9 67 f8 ff ff       	jmp    801072b0 <alltraps>

80107a49 <vector39>:
.globl vector39
vector39:
  pushl $0
80107a49:	6a 00                	push   $0x0
  pushl $39
80107a4b:	6a 27                	push   $0x27
  jmp alltraps
80107a4d:	e9 5e f8 ff ff       	jmp    801072b0 <alltraps>

80107a52 <vector40>:
.globl vector40
vector40:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $40
80107a54:	6a 28                	push   $0x28
  jmp alltraps
80107a56:	e9 55 f8 ff ff       	jmp    801072b0 <alltraps>

80107a5b <vector41>:
.globl vector41
vector41:
  pushl $0
80107a5b:	6a 00                	push   $0x0
  pushl $41
80107a5d:	6a 29                	push   $0x29
  jmp alltraps
80107a5f:	e9 4c f8 ff ff       	jmp    801072b0 <alltraps>

80107a64 <vector42>:
.globl vector42
vector42:
  pushl $0
80107a64:	6a 00                	push   $0x0
  pushl $42
80107a66:	6a 2a                	push   $0x2a
  jmp alltraps
80107a68:	e9 43 f8 ff ff       	jmp    801072b0 <alltraps>

80107a6d <vector43>:
.globl vector43
vector43:
  pushl $0
80107a6d:	6a 00                	push   $0x0
  pushl $43
80107a6f:	6a 2b                	push   $0x2b
  jmp alltraps
80107a71:	e9 3a f8 ff ff       	jmp    801072b0 <alltraps>

80107a76 <vector44>:
.globl vector44
vector44:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $44
80107a78:	6a 2c                	push   $0x2c
  jmp alltraps
80107a7a:	e9 31 f8 ff ff       	jmp    801072b0 <alltraps>

80107a7f <vector45>:
.globl vector45
vector45:
  pushl $0
80107a7f:	6a 00                	push   $0x0
  pushl $45
80107a81:	6a 2d                	push   $0x2d
  jmp alltraps
80107a83:	e9 28 f8 ff ff       	jmp    801072b0 <alltraps>

80107a88 <vector46>:
.globl vector46
vector46:
  pushl $0
80107a88:	6a 00                	push   $0x0
  pushl $46
80107a8a:	6a 2e                	push   $0x2e
  jmp alltraps
80107a8c:	e9 1f f8 ff ff       	jmp    801072b0 <alltraps>

80107a91 <vector47>:
.globl vector47
vector47:
  pushl $0
80107a91:	6a 00                	push   $0x0
  pushl $47
80107a93:	6a 2f                	push   $0x2f
  jmp alltraps
80107a95:	e9 16 f8 ff ff       	jmp    801072b0 <alltraps>

80107a9a <vector48>:
.globl vector48
vector48:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $48
80107a9c:	6a 30                	push   $0x30
  jmp alltraps
80107a9e:	e9 0d f8 ff ff       	jmp    801072b0 <alltraps>

80107aa3 <vector49>:
.globl vector49
vector49:
  pushl $0
80107aa3:	6a 00                	push   $0x0
  pushl $49
80107aa5:	6a 31                	push   $0x31
  jmp alltraps
80107aa7:	e9 04 f8 ff ff       	jmp    801072b0 <alltraps>

80107aac <vector50>:
.globl vector50
vector50:
  pushl $0
80107aac:	6a 00                	push   $0x0
  pushl $50
80107aae:	6a 32                	push   $0x32
  jmp alltraps
80107ab0:	e9 fb f7 ff ff       	jmp    801072b0 <alltraps>

80107ab5 <vector51>:
.globl vector51
vector51:
  pushl $0
80107ab5:	6a 00                	push   $0x0
  pushl $51
80107ab7:	6a 33                	push   $0x33
  jmp alltraps
80107ab9:	e9 f2 f7 ff ff       	jmp    801072b0 <alltraps>

80107abe <vector52>:
.globl vector52
vector52:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $52
80107ac0:	6a 34                	push   $0x34
  jmp alltraps
80107ac2:	e9 e9 f7 ff ff       	jmp    801072b0 <alltraps>

80107ac7 <vector53>:
.globl vector53
vector53:
  pushl $0
80107ac7:	6a 00                	push   $0x0
  pushl $53
80107ac9:	6a 35                	push   $0x35
  jmp alltraps
80107acb:	e9 e0 f7 ff ff       	jmp    801072b0 <alltraps>

80107ad0 <vector54>:
.globl vector54
vector54:
  pushl $0
80107ad0:	6a 00                	push   $0x0
  pushl $54
80107ad2:	6a 36                	push   $0x36
  jmp alltraps
80107ad4:	e9 d7 f7 ff ff       	jmp    801072b0 <alltraps>

80107ad9 <vector55>:
.globl vector55
vector55:
  pushl $0
80107ad9:	6a 00                	push   $0x0
  pushl $55
80107adb:	6a 37                	push   $0x37
  jmp alltraps
80107add:	e9 ce f7 ff ff       	jmp    801072b0 <alltraps>

80107ae2 <vector56>:
.globl vector56
vector56:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $56
80107ae4:	6a 38                	push   $0x38
  jmp alltraps
80107ae6:	e9 c5 f7 ff ff       	jmp    801072b0 <alltraps>

80107aeb <vector57>:
.globl vector57
vector57:
  pushl $0
80107aeb:	6a 00                	push   $0x0
  pushl $57
80107aed:	6a 39                	push   $0x39
  jmp alltraps
80107aef:	e9 bc f7 ff ff       	jmp    801072b0 <alltraps>

80107af4 <vector58>:
.globl vector58
vector58:
  pushl $0
80107af4:	6a 00                	push   $0x0
  pushl $58
80107af6:	6a 3a                	push   $0x3a
  jmp alltraps
80107af8:	e9 b3 f7 ff ff       	jmp    801072b0 <alltraps>

80107afd <vector59>:
.globl vector59
vector59:
  pushl $0
80107afd:	6a 00                	push   $0x0
  pushl $59
80107aff:	6a 3b                	push   $0x3b
  jmp alltraps
80107b01:	e9 aa f7 ff ff       	jmp    801072b0 <alltraps>

80107b06 <vector60>:
.globl vector60
vector60:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $60
80107b08:	6a 3c                	push   $0x3c
  jmp alltraps
80107b0a:	e9 a1 f7 ff ff       	jmp    801072b0 <alltraps>

80107b0f <vector61>:
.globl vector61
vector61:
  pushl $0
80107b0f:	6a 00                	push   $0x0
  pushl $61
80107b11:	6a 3d                	push   $0x3d
  jmp alltraps
80107b13:	e9 98 f7 ff ff       	jmp    801072b0 <alltraps>

80107b18 <vector62>:
.globl vector62
vector62:
  pushl $0
80107b18:	6a 00                	push   $0x0
  pushl $62
80107b1a:	6a 3e                	push   $0x3e
  jmp alltraps
80107b1c:	e9 8f f7 ff ff       	jmp    801072b0 <alltraps>

80107b21 <vector63>:
.globl vector63
vector63:
  pushl $0
80107b21:	6a 00                	push   $0x0
  pushl $63
80107b23:	6a 3f                	push   $0x3f
  jmp alltraps
80107b25:	e9 86 f7 ff ff       	jmp    801072b0 <alltraps>

80107b2a <vector64>:
.globl vector64
vector64:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $64
80107b2c:	6a 40                	push   $0x40
  jmp alltraps
80107b2e:	e9 7d f7 ff ff       	jmp    801072b0 <alltraps>

80107b33 <vector65>:
.globl vector65
vector65:
  pushl $0
80107b33:	6a 00                	push   $0x0
  pushl $65
80107b35:	6a 41                	push   $0x41
  jmp alltraps
80107b37:	e9 74 f7 ff ff       	jmp    801072b0 <alltraps>

80107b3c <vector66>:
.globl vector66
vector66:
  pushl $0
80107b3c:	6a 00                	push   $0x0
  pushl $66
80107b3e:	6a 42                	push   $0x42
  jmp alltraps
80107b40:	e9 6b f7 ff ff       	jmp    801072b0 <alltraps>

80107b45 <vector67>:
.globl vector67
vector67:
  pushl $0
80107b45:	6a 00                	push   $0x0
  pushl $67
80107b47:	6a 43                	push   $0x43
  jmp alltraps
80107b49:	e9 62 f7 ff ff       	jmp    801072b0 <alltraps>

80107b4e <vector68>:
.globl vector68
vector68:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $68
80107b50:	6a 44                	push   $0x44
  jmp alltraps
80107b52:	e9 59 f7 ff ff       	jmp    801072b0 <alltraps>

80107b57 <vector69>:
.globl vector69
vector69:
  pushl $0
80107b57:	6a 00                	push   $0x0
  pushl $69
80107b59:	6a 45                	push   $0x45
  jmp alltraps
80107b5b:	e9 50 f7 ff ff       	jmp    801072b0 <alltraps>

80107b60 <vector70>:
.globl vector70
vector70:
  pushl $0
80107b60:	6a 00                	push   $0x0
  pushl $70
80107b62:	6a 46                	push   $0x46
  jmp alltraps
80107b64:	e9 47 f7 ff ff       	jmp    801072b0 <alltraps>

80107b69 <vector71>:
.globl vector71
vector71:
  pushl $0
80107b69:	6a 00                	push   $0x0
  pushl $71
80107b6b:	6a 47                	push   $0x47
  jmp alltraps
80107b6d:	e9 3e f7 ff ff       	jmp    801072b0 <alltraps>

80107b72 <vector72>:
.globl vector72
vector72:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $72
80107b74:	6a 48                	push   $0x48
  jmp alltraps
80107b76:	e9 35 f7 ff ff       	jmp    801072b0 <alltraps>

80107b7b <vector73>:
.globl vector73
vector73:
  pushl $0
80107b7b:	6a 00                	push   $0x0
  pushl $73
80107b7d:	6a 49                	push   $0x49
  jmp alltraps
80107b7f:	e9 2c f7 ff ff       	jmp    801072b0 <alltraps>

80107b84 <vector74>:
.globl vector74
vector74:
  pushl $0
80107b84:	6a 00                	push   $0x0
  pushl $74
80107b86:	6a 4a                	push   $0x4a
  jmp alltraps
80107b88:	e9 23 f7 ff ff       	jmp    801072b0 <alltraps>

80107b8d <vector75>:
.globl vector75
vector75:
  pushl $0
80107b8d:	6a 00                	push   $0x0
  pushl $75
80107b8f:	6a 4b                	push   $0x4b
  jmp alltraps
80107b91:	e9 1a f7 ff ff       	jmp    801072b0 <alltraps>

80107b96 <vector76>:
.globl vector76
vector76:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $76
80107b98:	6a 4c                	push   $0x4c
  jmp alltraps
80107b9a:	e9 11 f7 ff ff       	jmp    801072b0 <alltraps>

80107b9f <vector77>:
.globl vector77
vector77:
  pushl $0
80107b9f:	6a 00                	push   $0x0
  pushl $77
80107ba1:	6a 4d                	push   $0x4d
  jmp alltraps
80107ba3:	e9 08 f7 ff ff       	jmp    801072b0 <alltraps>

80107ba8 <vector78>:
.globl vector78
vector78:
  pushl $0
80107ba8:	6a 00                	push   $0x0
  pushl $78
80107baa:	6a 4e                	push   $0x4e
  jmp alltraps
80107bac:	e9 ff f6 ff ff       	jmp    801072b0 <alltraps>

80107bb1 <vector79>:
.globl vector79
vector79:
  pushl $0
80107bb1:	6a 00                	push   $0x0
  pushl $79
80107bb3:	6a 4f                	push   $0x4f
  jmp alltraps
80107bb5:	e9 f6 f6 ff ff       	jmp    801072b0 <alltraps>

80107bba <vector80>:
.globl vector80
vector80:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $80
80107bbc:	6a 50                	push   $0x50
  jmp alltraps
80107bbe:	e9 ed f6 ff ff       	jmp    801072b0 <alltraps>

80107bc3 <vector81>:
.globl vector81
vector81:
  pushl $0
80107bc3:	6a 00                	push   $0x0
  pushl $81
80107bc5:	6a 51                	push   $0x51
  jmp alltraps
80107bc7:	e9 e4 f6 ff ff       	jmp    801072b0 <alltraps>

80107bcc <vector82>:
.globl vector82
vector82:
  pushl $0
80107bcc:	6a 00                	push   $0x0
  pushl $82
80107bce:	6a 52                	push   $0x52
  jmp alltraps
80107bd0:	e9 db f6 ff ff       	jmp    801072b0 <alltraps>

80107bd5 <vector83>:
.globl vector83
vector83:
  pushl $0
80107bd5:	6a 00                	push   $0x0
  pushl $83
80107bd7:	6a 53                	push   $0x53
  jmp alltraps
80107bd9:	e9 d2 f6 ff ff       	jmp    801072b0 <alltraps>

80107bde <vector84>:
.globl vector84
vector84:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $84
80107be0:	6a 54                	push   $0x54
  jmp alltraps
80107be2:	e9 c9 f6 ff ff       	jmp    801072b0 <alltraps>

80107be7 <vector85>:
.globl vector85
vector85:
  pushl $0
80107be7:	6a 00                	push   $0x0
  pushl $85
80107be9:	6a 55                	push   $0x55
  jmp alltraps
80107beb:	e9 c0 f6 ff ff       	jmp    801072b0 <alltraps>

80107bf0 <vector86>:
.globl vector86
vector86:
  pushl $0
80107bf0:	6a 00                	push   $0x0
  pushl $86
80107bf2:	6a 56                	push   $0x56
  jmp alltraps
80107bf4:	e9 b7 f6 ff ff       	jmp    801072b0 <alltraps>

80107bf9 <vector87>:
.globl vector87
vector87:
  pushl $0
80107bf9:	6a 00                	push   $0x0
  pushl $87
80107bfb:	6a 57                	push   $0x57
  jmp alltraps
80107bfd:	e9 ae f6 ff ff       	jmp    801072b0 <alltraps>

80107c02 <vector88>:
.globl vector88
vector88:
  pushl $0
80107c02:	6a 00                	push   $0x0
  pushl $88
80107c04:	6a 58                	push   $0x58
  jmp alltraps
80107c06:	e9 a5 f6 ff ff       	jmp    801072b0 <alltraps>

80107c0b <vector89>:
.globl vector89
vector89:
  pushl $0
80107c0b:	6a 00                	push   $0x0
  pushl $89
80107c0d:	6a 59                	push   $0x59
  jmp alltraps
80107c0f:	e9 9c f6 ff ff       	jmp    801072b0 <alltraps>

80107c14 <vector90>:
.globl vector90
vector90:
  pushl $0
80107c14:	6a 00                	push   $0x0
  pushl $90
80107c16:	6a 5a                	push   $0x5a
  jmp alltraps
80107c18:	e9 93 f6 ff ff       	jmp    801072b0 <alltraps>

80107c1d <vector91>:
.globl vector91
vector91:
  pushl $0
80107c1d:	6a 00                	push   $0x0
  pushl $91
80107c1f:	6a 5b                	push   $0x5b
  jmp alltraps
80107c21:	e9 8a f6 ff ff       	jmp    801072b0 <alltraps>

80107c26 <vector92>:
.globl vector92
vector92:
  pushl $0
80107c26:	6a 00                	push   $0x0
  pushl $92
80107c28:	6a 5c                	push   $0x5c
  jmp alltraps
80107c2a:	e9 81 f6 ff ff       	jmp    801072b0 <alltraps>

80107c2f <vector93>:
.globl vector93
vector93:
  pushl $0
80107c2f:	6a 00                	push   $0x0
  pushl $93
80107c31:	6a 5d                	push   $0x5d
  jmp alltraps
80107c33:	e9 78 f6 ff ff       	jmp    801072b0 <alltraps>

80107c38 <vector94>:
.globl vector94
vector94:
  pushl $0
80107c38:	6a 00                	push   $0x0
  pushl $94
80107c3a:	6a 5e                	push   $0x5e
  jmp alltraps
80107c3c:	e9 6f f6 ff ff       	jmp    801072b0 <alltraps>

80107c41 <vector95>:
.globl vector95
vector95:
  pushl $0
80107c41:	6a 00                	push   $0x0
  pushl $95
80107c43:	6a 5f                	push   $0x5f
  jmp alltraps
80107c45:	e9 66 f6 ff ff       	jmp    801072b0 <alltraps>

80107c4a <vector96>:
.globl vector96
vector96:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $96
80107c4c:	6a 60                	push   $0x60
  jmp alltraps
80107c4e:	e9 5d f6 ff ff       	jmp    801072b0 <alltraps>

80107c53 <vector97>:
.globl vector97
vector97:
  pushl $0
80107c53:	6a 00                	push   $0x0
  pushl $97
80107c55:	6a 61                	push   $0x61
  jmp alltraps
80107c57:	e9 54 f6 ff ff       	jmp    801072b0 <alltraps>

80107c5c <vector98>:
.globl vector98
vector98:
  pushl $0
80107c5c:	6a 00                	push   $0x0
  pushl $98
80107c5e:	6a 62                	push   $0x62
  jmp alltraps
80107c60:	e9 4b f6 ff ff       	jmp    801072b0 <alltraps>

80107c65 <vector99>:
.globl vector99
vector99:
  pushl $0
80107c65:	6a 00                	push   $0x0
  pushl $99
80107c67:	6a 63                	push   $0x63
  jmp alltraps
80107c69:	e9 42 f6 ff ff       	jmp    801072b0 <alltraps>

80107c6e <vector100>:
.globl vector100
vector100:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $100
80107c70:	6a 64                	push   $0x64
  jmp alltraps
80107c72:	e9 39 f6 ff ff       	jmp    801072b0 <alltraps>

80107c77 <vector101>:
.globl vector101
vector101:
  pushl $0
80107c77:	6a 00                	push   $0x0
  pushl $101
80107c79:	6a 65                	push   $0x65
  jmp alltraps
80107c7b:	e9 30 f6 ff ff       	jmp    801072b0 <alltraps>

80107c80 <vector102>:
.globl vector102
vector102:
  pushl $0
80107c80:	6a 00                	push   $0x0
  pushl $102
80107c82:	6a 66                	push   $0x66
  jmp alltraps
80107c84:	e9 27 f6 ff ff       	jmp    801072b0 <alltraps>

80107c89 <vector103>:
.globl vector103
vector103:
  pushl $0
80107c89:	6a 00                	push   $0x0
  pushl $103
80107c8b:	6a 67                	push   $0x67
  jmp alltraps
80107c8d:	e9 1e f6 ff ff       	jmp    801072b0 <alltraps>

80107c92 <vector104>:
.globl vector104
vector104:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $104
80107c94:	6a 68                	push   $0x68
  jmp alltraps
80107c96:	e9 15 f6 ff ff       	jmp    801072b0 <alltraps>

80107c9b <vector105>:
.globl vector105
vector105:
  pushl $0
80107c9b:	6a 00                	push   $0x0
  pushl $105
80107c9d:	6a 69                	push   $0x69
  jmp alltraps
80107c9f:	e9 0c f6 ff ff       	jmp    801072b0 <alltraps>

80107ca4 <vector106>:
.globl vector106
vector106:
  pushl $0
80107ca4:	6a 00                	push   $0x0
  pushl $106
80107ca6:	6a 6a                	push   $0x6a
  jmp alltraps
80107ca8:	e9 03 f6 ff ff       	jmp    801072b0 <alltraps>

80107cad <vector107>:
.globl vector107
vector107:
  pushl $0
80107cad:	6a 00                	push   $0x0
  pushl $107
80107caf:	6a 6b                	push   $0x6b
  jmp alltraps
80107cb1:	e9 fa f5 ff ff       	jmp    801072b0 <alltraps>

80107cb6 <vector108>:
.globl vector108
vector108:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $108
80107cb8:	6a 6c                	push   $0x6c
  jmp alltraps
80107cba:	e9 f1 f5 ff ff       	jmp    801072b0 <alltraps>

80107cbf <vector109>:
.globl vector109
vector109:
  pushl $0
80107cbf:	6a 00                	push   $0x0
  pushl $109
80107cc1:	6a 6d                	push   $0x6d
  jmp alltraps
80107cc3:	e9 e8 f5 ff ff       	jmp    801072b0 <alltraps>

80107cc8 <vector110>:
.globl vector110
vector110:
  pushl $0
80107cc8:	6a 00                	push   $0x0
  pushl $110
80107cca:	6a 6e                	push   $0x6e
  jmp alltraps
80107ccc:	e9 df f5 ff ff       	jmp    801072b0 <alltraps>

80107cd1 <vector111>:
.globl vector111
vector111:
  pushl $0
80107cd1:	6a 00                	push   $0x0
  pushl $111
80107cd3:	6a 6f                	push   $0x6f
  jmp alltraps
80107cd5:	e9 d6 f5 ff ff       	jmp    801072b0 <alltraps>

80107cda <vector112>:
.globl vector112
vector112:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $112
80107cdc:	6a 70                	push   $0x70
  jmp alltraps
80107cde:	e9 cd f5 ff ff       	jmp    801072b0 <alltraps>

80107ce3 <vector113>:
.globl vector113
vector113:
  pushl $0
80107ce3:	6a 00                	push   $0x0
  pushl $113
80107ce5:	6a 71                	push   $0x71
  jmp alltraps
80107ce7:	e9 c4 f5 ff ff       	jmp    801072b0 <alltraps>

80107cec <vector114>:
.globl vector114
vector114:
  pushl $0
80107cec:	6a 00                	push   $0x0
  pushl $114
80107cee:	6a 72                	push   $0x72
  jmp alltraps
80107cf0:	e9 bb f5 ff ff       	jmp    801072b0 <alltraps>

80107cf5 <vector115>:
.globl vector115
vector115:
  pushl $0
80107cf5:	6a 00                	push   $0x0
  pushl $115
80107cf7:	6a 73                	push   $0x73
  jmp alltraps
80107cf9:	e9 b2 f5 ff ff       	jmp    801072b0 <alltraps>

80107cfe <vector116>:
.globl vector116
vector116:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $116
80107d00:	6a 74                	push   $0x74
  jmp alltraps
80107d02:	e9 a9 f5 ff ff       	jmp    801072b0 <alltraps>

80107d07 <vector117>:
.globl vector117
vector117:
  pushl $0
80107d07:	6a 00                	push   $0x0
  pushl $117
80107d09:	6a 75                	push   $0x75
  jmp alltraps
80107d0b:	e9 a0 f5 ff ff       	jmp    801072b0 <alltraps>

80107d10 <vector118>:
.globl vector118
vector118:
  pushl $0
80107d10:	6a 00                	push   $0x0
  pushl $118
80107d12:	6a 76                	push   $0x76
  jmp alltraps
80107d14:	e9 97 f5 ff ff       	jmp    801072b0 <alltraps>

80107d19 <vector119>:
.globl vector119
vector119:
  pushl $0
80107d19:	6a 00                	push   $0x0
  pushl $119
80107d1b:	6a 77                	push   $0x77
  jmp alltraps
80107d1d:	e9 8e f5 ff ff       	jmp    801072b0 <alltraps>

80107d22 <vector120>:
.globl vector120
vector120:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $120
80107d24:	6a 78                	push   $0x78
  jmp alltraps
80107d26:	e9 85 f5 ff ff       	jmp    801072b0 <alltraps>

80107d2b <vector121>:
.globl vector121
vector121:
  pushl $0
80107d2b:	6a 00                	push   $0x0
  pushl $121
80107d2d:	6a 79                	push   $0x79
  jmp alltraps
80107d2f:	e9 7c f5 ff ff       	jmp    801072b0 <alltraps>

80107d34 <vector122>:
.globl vector122
vector122:
  pushl $0
80107d34:	6a 00                	push   $0x0
  pushl $122
80107d36:	6a 7a                	push   $0x7a
  jmp alltraps
80107d38:	e9 73 f5 ff ff       	jmp    801072b0 <alltraps>

80107d3d <vector123>:
.globl vector123
vector123:
  pushl $0
80107d3d:	6a 00                	push   $0x0
  pushl $123
80107d3f:	6a 7b                	push   $0x7b
  jmp alltraps
80107d41:	e9 6a f5 ff ff       	jmp    801072b0 <alltraps>

80107d46 <vector124>:
.globl vector124
vector124:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $124
80107d48:	6a 7c                	push   $0x7c
  jmp alltraps
80107d4a:	e9 61 f5 ff ff       	jmp    801072b0 <alltraps>

80107d4f <vector125>:
.globl vector125
vector125:
  pushl $0
80107d4f:	6a 00                	push   $0x0
  pushl $125
80107d51:	6a 7d                	push   $0x7d
  jmp alltraps
80107d53:	e9 58 f5 ff ff       	jmp    801072b0 <alltraps>

80107d58 <vector126>:
.globl vector126
vector126:
  pushl $0
80107d58:	6a 00                	push   $0x0
  pushl $126
80107d5a:	6a 7e                	push   $0x7e
  jmp alltraps
80107d5c:	e9 4f f5 ff ff       	jmp    801072b0 <alltraps>

80107d61 <vector127>:
.globl vector127
vector127:
  pushl $0
80107d61:	6a 00                	push   $0x0
  pushl $127
80107d63:	6a 7f                	push   $0x7f
  jmp alltraps
80107d65:	e9 46 f5 ff ff       	jmp    801072b0 <alltraps>

80107d6a <vector128>:
.globl vector128
vector128:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $128
80107d6c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107d71:	e9 3a f5 ff ff       	jmp    801072b0 <alltraps>

80107d76 <vector129>:
.globl vector129
vector129:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $129
80107d78:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107d7d:	e9 2e f5 ff ff       	jmp    801072b0 <alltraps>

80107d82 <vector130>:
.globl vector130
vector130:
  pushl $0
80107d82:	6a 00                	push   $0x0
  pushl $130
80107d84:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107d89:	e9 22 f5 ff ff       	jmp    801072b0 <alltraps>

80107d8e <vector131>:
.globl vector131
vector131:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $131
80107d90:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107d95:	e9 16 f5 ff ff       	jmp    801072b0 <alltraps>

80107d9a <vector132>:
.globl vector132
vector132:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $132
80107d9c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107da1:	e9 0a f5 ff ff       	jmp    801072b0 <alltraps>

80107da6 <vector133>:
.globl vector133
vector133:
  pushl $0
80107da6:	6a 00                	push   $0x0
  pushl $133
80107da8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107dad:	e9 fe f4 ff ff       	jmp    801072b0 <alltraps>

80107db2 <vector134>:
.globl vector134
vector134:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $134
80107db4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107db9:	e9 f2 f4 ff ff       	jmp    801072b0 <alltraps>

80107dbe <vector135>:
.globl vector135
vector135:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $135
80107dc0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107dc5:	e9 e6 f4 ff ff       	jmp    801072b0 <alltraps>

80107dca <vector136>:
.globl vector136
vector136:
  pushl $0
80107dca:	6a 00                	push   $0x0
  pushl $136
80107dcc:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107dd1:	e9 da f4 ff ff       	jmp    801072b0 <alltraps>

80107dd6 <vector137>:
.globl vector137
vector137:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $137
80107dd8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107ddd:	e9 ce f4 ff ff       	jmp    801072b0 <alltraps>

80107de2 <vector138>:
.globl vector138
vector138:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $138
80107de4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107de9:	e9 c2 f4 ff ff       	jmp    801072b0 <alltraps>

80107dee <vector139>:
.globl vector139
vector139:
  pushl $0
80107dee:	6a 00                	push   $0x0
  pushl $139
80107df0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107df5:	e9 b6 f4 ff ff       	jmp    801072b0 <alltraps>

80107dfa <vector140>:
.globl vector140
vector140:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $140
80107dfc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107e01:	e9 aa f4 ff ff       	jmp    801072b0 <alltraps>

80107e06 <vector141>:
.globl vector141
vector141:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $141
80107e08:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107e0d:	e9 9e f4 ff ff       	jmp    801072b0 <alltraps>

80107e12 <vector142>:
.globl vector142
vector142:
  pushl $0
80107e12:	6a 00                	push   $0x0
  pushl $142
80107e14:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107e19:	e9 92 f4 ff ff       	jmp    801072b0 <alltraps>

80107e1e <vector143>:
.globl vector143
vector143:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $143
80107e20:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107e25:	e9 86 f4 ff ff       	jmp    801072b0 <alltraps>

80107e2a <vector144>:
.globl vector144
vector144:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $144
80107e2c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107e31:	e9 7a f4 ff ff       	jmp    801072b0 <alltraps>

80107e36 <vector145>:
.globl vector145
vector145:
  pushl $0
80107e36:	6a 00                	push   $0x0
  pushl $145
80107e38:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107e3d:	e9 6e f4 ff ff       	jmp    801072b0 <alltraps>

80107e42 <vector146>:
.globl vector146
vector146:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $146
80107e44:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107e49:	e9 62 f4 ff ff       	jmp    801072b0 <alltraps>

80107e4e <vector147>:
.globl vector147
vector147:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $147
80107e50:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107e55:	e9 56 f4 ff ff       	jmp    801072b0 <alltraps>

80107e5a <vector148>:
.globl vector148
vector148:
  pushl $0
80107e5a:	6a 00                	push   $0x0
  pushl $148
80107e5c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107e61:	e9 4a f4 ff ff       	jmp    801072b0 <alltraps>

80107e66 <vector149>:
.globl vector149
vector149:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $149
80107e68:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107e6d:	e9 3e f4 ff ff       	jmp    801072b0 <alltraps>

80107e72 <vector150>:
.globl vector150
vector150:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $150
80107e74:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107e79:	e9 32 f4 ff ff       	jmp    801072b0 <alltraps>

80107e7e <vector151>:
.globl vector151
vector151:
  pushl $0
80107e7e:	6a 00                	push   $0x0
  pushl $151
80107e80:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107e85:	e9 26 f4 ff ff       	jmp    801072b0 <alltraps>

80107e8a <vector152>:
.globl vector152
vector152:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $152
80107e8c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107e91:	e9 1a f4 ff ff       	jmp    801072b0 <alltraps>

80107e96 <vector153>:
.globl vector153
vector153:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $153
80107e98:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107e9d:	e9 0e f4 ff ff       	jmp    801072b0 <alltraps>

80107ea2 <vector154>:
.globl vector154
vector154:
  pushl $0
80107ea2:	6a 00                	push   $0x0
  pushl $154
80107ea4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107ea9:	e9 02 f4 ff ff       	jmp    801072b0 <alltraps>

80107eae <vector155>:
.globl vector155
vector155:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $155
80107eb0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107eb5:	e9 f6 f3 ff ff       	jmp    801072b0 <alltraps>

80107eba <vector156>:
.globl vector156
vector156:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $156
80107ebc:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107ec1:	e9 ea f3 ff ff       	jmp    801072b0 <alltraps>

80107ec6 <vector157>:
.globl vector157
vector157:
  pushl $0
80107ec6:	6a 00                	push   $0x0
  pushl $157
80107ec8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107ecd:	e9 de f3 ff ff       	jmp    801072b0 <alltraps>

80107ed2 <vector158>:
.globl vector158
vector158:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $158
80107ed4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107ed9:	e9 d2 f3 ff ff       	jmp    801072b0 <alltraps>

80107ede <vector159>:
.globl vector159
vector159:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $159
80107ee0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107ee5:	e9 c6 f3 ff ff       	jmp    801072b0 <alltraps>

80107eea <vector160>:
.globl vector160
vector160:
  pushl $0
80107eea:	6a 00                	push   $0x0
  pushl $160
80107eec:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107ef1:	e9 ba f3 ff ff       	jmp    801072b0 <alltraps>

80107ef6 <vector161>:
.globl vector161
vector161:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $161
80107ef8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107efd:	e9 ae f3 ff ff       	jmp    801072b0 <alltraps>

80107f02 <vector162>:
.globl vector162
vector162:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $162
80107f04:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107f09:	e9 a2 f3 ff ff       	jmp    801072b0 <alltraps>

80107f0e <vector163>:
.globl vector163
vector163:
  pushl $0
80107f0e:	6a 00                	push   $0x0
  pushl $163
80107f10:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107f15:	e9 96 f3 ff ff       	jmp    801072b0 <alltraps>

80107f1a <vector164>:
.globl vector164
vector164:
  pushl $0
80107f1a:	6a 00                	push   $0x0
  pushl $164
80107f1c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107f21:	e9 8a f3 ff ff       	jmp    801072b0 <alltraps>

80107f26 <vector165>:
.globl vector165
vector165:
  pushl $0
80107f26:	6a 00                	push   $0x0
  pushl $165
80107f28:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107f2d:	e9 7e f3 ff ff       	jmp    801072b0 <alltraps>

80107f32 <vector166>:
.globl vector166
vector166:
  pushl $0
80107f32:	6a 00                	push   $0x0
  pushl $166
80107f34:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107f39:	e9 72 f3 ff ff       	jmp    801072b0 <alltraps>

80107f3e <vector167>:
.globl vector167
vector167:
  pushl $0
80107f3e:	6a 00                	push   $0x0
  pushl $167
80107f40:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107f45:	e9 66 f3 ff ff       	jmp    801072b0 <alltraps>

80107f4a <vector168>:
.globl vector168
vector168:
  pushl $0
80107f4a:	6a 00                	push   $0x0
  pushl $168
80107f4c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107f51:	e9 5a f3 ff ff       	jmp    801072b0 <alltraps>

80107f56 <vector169>:
.globl vector169
vector169:
  pushl $0
80107f56:	6a 00                	push   $0x0
  pushl $169
80107f58:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107f5d:	e9 4e f3 ff ff       	jmp    801072b0 <alltraps>

80107f62 <vector170>:
.globl vector170
vector170:
  pushl $0
80107f62:	6a 00                	push   $0x0
  pushl $170
80107f64:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107f69:	e9 42 f3 ff ff       	jmp    801072b0 <alltraps>

80107f6e <vector171>:
.globl vector171
vector171:
  pushl $0
80107f6e:	6a 00                	push   $0x0
  pushl $171
80107f70:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107f75:	e9 36 f3 ff ff       	jmp    801072b0 <alltraps>

80107f7a <vector172>:
.globl vector172
vector172:
  pushl $0
80107f7a:	6a 00                	push   $0x0
  pushl $172
80107f7c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107f81:	e9 2a f3 ff ff       	jmp    801072b0 <alltraps>

80107f86 <vector173>:
.globl vector173
vector173:
  pushl $0
80107f86:	6a 00                	push   $0x0
  pushl $173
80107f88:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107f8d:	e9 1e f3 ff ff       	jmp    801072b0 <alltraps>

80107f92 <vector174>:
.globl vector174
vector174:
  pushl $0
80107f92:	6a 00                	push   $0x0
  pushl $174
80107f94:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107f99:	e9 12 f3 ff ff       	jmp    801072b0 <alltraps>

80107f9e <vector175>:
.globl vector175
vector175:
  pushl $0
80107f9e:	6a 00                	push   $0x0
  pushl $175
80107fa0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107fa5:	e9 06 f3 ff ff       	jmp    801072b0 <alltraps>

80107faa <vector176>:
.globl vector176
vector176:
  pushl $0
80107faa:	6a 00                	push   $0x0
  pushl $176
80107fac:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107fb1:	e9 fa f2 ff ff       	jmp    801072b0 <alltraps>

80107fb6 <vector177>:
.globl vector177
vector177:
  pushl $0
80107fb6:	6a 00                	push   $0x0
  pushl $177
80107fb8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107fbd:	e9 ee f2 ff ff       	jmp    801072b0 <alltraps>

80107fc2 <vector178>:
.globl vector178
vector178:
  pushl $0
80107fc2:	6a 00                	push   $0x0
  pushl $178
80107fc4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107fc9:	e9 e2 f2 ff ff       	jmp    801072b0 <alltraps>

80107fce <vector179>:
.globl vector179
vector179:
  pushl $0
80107fce:	6a 00                	push   $0x0
  pushl $179
80107fd0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107fd5:	e9 d6 f2 ff ff       	jmp    801072b0 <alltraps>

80107fda <vector180>:
.globl vector180
vector180:
  pushl $0
80107fda:	6a 00                	push   $0x0
  pushl $180
80107fdc:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107fe1:	e9 ca f2 ff ff       	jmp    801072b0 <alltraps>

80107fe6 <vector181>:
.globl vector181
vector181:
  pushl $0
80107fe6:	6a 00                	push   $0x0
  pushl $181
80107fe8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107fed:	e9 be f2 ff ff       	jmp    801072b0 <alltraps>

80107ff2 <vector182>:
.globl vector182
vector182:
  pushl $0
80107ff2:	6a 00                	push   $0x0
  pushl $182
80107ff4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107ff9:	e9 b2 f2 ff ff       	jmp    801072b0 <alltraps>

80107ffe <vector183>:
.globl vector183
vector183:
  pushl $0
80107ffe:	6a 00                	push   $0x0
  pushl $183
80108000:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108005:	e9 a6 f2 ff ff       	jmp    801072b0 <alltraps>

8010800a <vector184>:
.globl vector184
vector184:
  pushl $0
8010800a:	6a 00                	push   $0x0
  pushl $184
8010800c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108011:	e9 9a f2 ff ff       	jmp    801072b0 <alltraps>

80108016 <vector185>:
.globl vector185
vector185:
  pushl $0
80108016:	6a 00                	push   $0x0
  pushl $185
80108018:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010801d:	e9 8e f2 ff ff       	jmp    801072b0 <alltraps>

80108022 <vector186>:
.globl vector186
vector186:
  pushl $0
80108022:	6a 00                	push   $0x0
  pushl $186
80108024:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108029:	e9 82 f2 ff ff       	jmp    801072b0 <alltraps>

8010802e <vector187>:
.globl vector187
vector187:
  pushl $0
8010802e:	6a 00                	push   $0x0
  pushl $187
80108030:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108035:	e9 76 f2 ff ff       	jmp    801072b0 <alltraps>

8010803a <vector188>:
.globl vector188
vector188:
  pushl $0
8010803a:	6a 00                	push   $0x0
  pushl $188
8010803c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108041:	e9 6a f2 ff ff       	jmp    801072b0 <alltraps>

80108046 <vector189>:
.globl vector189
vector189:
  pushl $0
80108046:	6a 00                	push   $0x0
  pushl $189
80108048:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010804d:	e9 5e f2 ff ff       	jmp    801072b0 <alltraps>

80108052 <vector190>:
.globl vector190
vector190:
  pushl $0
80108052:	6a 00                	push   $0x0
  pushl $190
80108054:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108059:	e9 52 f2 ff ff       	jmp    801072b0 <alltraps>

8010805e <vector191>:
.globl vector191
vector191:
  pushl $0
8010805e:	6a 00                	push   $0x0
  pushl $191
80108060:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108065:	e9 46 f2 ff ff       	jmp    801072b0 <alltraps>

8010806a <vector192>:
.globl vector192
vector192:
  pushl $0
8010806a:	6a 00                	push   $0x0
  pushl $192
8010806c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108071:	e9 3a f2 ff ff       	jmp    801072b0 <alltraps>

80108076 <vector193>:
.globl vector193
vector193:
  pushl $0
80108076:	6a 00                	push   $0x0
  pushl $193
80108078:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010807d:	e9 2e f2 ff ff       	jmp    801072b0 <alltraps>

80108082 <vector194>:
.globl vector194
vector194:
  pushl $0
80108082:	6a 00                	push   $0x0
  pushl $194
80108084:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108089:	e9 22 f2 ff ff       	jmp    801072b0 <alltraps>

8010808e <vector195>:
.globl vector195
vector195:
  pushl $0
8010808e:	6a 00                	push   $0x0
  pushl $195
80108090:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108095:	e9 16 f2 ff ff       	jmp    801072b0 <alltraps>

8010809a <vector196>:
.globl vector196
vector196:
  pushl $0
8010809a:	6a 00                	push   $0x0
  pushl $196
8010809c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801080a1:	e9 0a f2 ff ff       	jmp    801072b0 <alltraps>

801080a6 <vector197>:
.globl vector197
vector197:
  pushl $0
801080a6:	6a 00                	push   $0x0
  pushl $197
801080a8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801080ad:	e9 fe f1 ff ff       	jmp    801072b0 <alltraps>

801080b2 <vector198>:
.globl vector198
vector198:
  pushl $0
801080b2:	6a 00                	push   $0x0
  pushl $198
801080b4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801080b9:	e9 f2 f1 ff ff       	jmp    801072b0 <alltraps>

801080be <vector199>:
.globl vector199
vector199:
  pushl $0
801080be:	6a 00                	push   $0x0
  pushl $199
801080c0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801080c5:	e9 e6 f1 ff ff       	jmp    801072b0 <alltraps>

801080ca <vector200>:
.globl vector200
vector200:
  pushl $0
801080ca:	6a 00                	push   $0x0
  pushl $200
801080cc:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801080d1:	e9 da f1 ff ff       	jmp    801072b0 <alltraps>

801080d6 <vector201>:
.globl vector201
vector201:
  pushl $0
801080d6:	6a 00                	push   $0x0
  pushl $201
801080d8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801080dd:	e9 ce f1 ff ff       	jmp    801072b0 <alltraps>

801080e2 <vector202>:
.globl vector202
vector202:
  pushl $0
801080e2:	6a 00                	push   $0x0
  pushl $202
801080e4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801080e9:	e9 c2 f1 ff ff       	jmp    801072b0 <alltraps>

801080ee <vector203>:
.globl vector203
vector203:
  pushl $0
801080ee:	6a 00                	push   $0x0
  pushl $203
801080f0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801080f5:	e9 b6 f1 ff ff       	jmp    801072b0 <alltraps>

801080fa <vector204>:
.globl vector204
vector204:
  pushl $0
801080fa:	6a 00                	push   $0x0
  pushl $204
801080fc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108101:	e9 aa f1 ff ff       	jmp    801072b0 <alltraps>

80108106 <vector205>:
.globl vector205
vector205:
  pushl $0
80108106:	6a 00                	push   $0x0
  pushl $205
80108108:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010810d:	e9 9e f1 ff ff       	jmp    801072b0 <alltraps>

80108112 <vector206>:
.globl vector206
vector206:
  pushl $0
80108112:	6a 00                	push   $0x0
  pushl $206
80108114:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108119:	e9 92 f1 ff ff       	jmp    801072b0 <alltraps>

8010811e <vector207>:
.globl vector207
vector207:
  pushl $0
8010811e:	6a 00                	push   $0x0
  pushl $207
80108120:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108125:	e9 86 f1 ff ff       	jmp    801072b0 <alltraps>

8010812a <vector208>:
.globl vector208
vector208:
  pushl $0
8010812a:	6a 00                	push   $0x0
  pushl $208
8010812c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108131:	e9 7a f1 ff ff       	jmp    801072b0 <alltraps>

80108136 <vector209>:
.globl vector209
vector209:
  pushl $0
80108136:	6a 00                	push   $0x0
  pushl $209
80108138:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010813d:	e9 6e f1 ff ff       	jmp    801072b0 <alltraps>

80108142 <vector210>:
.globl vector210
vector210:
  pushl $0
80108142:	6a 00                	push   $0x0
  pushl $210
80108144:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108149:	e9 62 f1 ff ff       	jmp    801072b0 <alltraps>

8010814e <vector211>:
.globl vector211
vector211:
  pushl $0
8010814e:	6a 00                	push   $0x0
  pushl $211
80108150:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108155:	e9 56 f1 ff ff       	jmp    801072b0 <alltraps>

8010815a <vector212>:
.globl vector212
vector212:
  pushl $0
8010815a:	6a 00                	push   $0x0
  pushl $212
8010815c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108161:	e9 4a f1 ff ff       	jmp    801072b0 <alltraps>

80108166 <vector213>:
.globl vector213
vector213:
  pushl $0
80108166:	6a 00                	push   $0x0
  pushl $213
80108168:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010816d:	e9 3e f1 ff ff       	jmp    801072b0 <alltraps>

80108172 <vector214>:
.globl vector214
vector214:
  pushl $0
80108172:	6a 00                	push   $0x0
  pushl $214
80108174:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108179:	e9 32 f1 ff ff       	jmp    801072b0 <alltraps>

8010817e <vector215>:
.globl vector215
vector215:
  pushl $0
8010817e:	6a 00                	push   $0x0
  pushl $215
80108180:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108185:	e9 26 f1 ff ff       	jmp    801072b0 <alltraps>

8010818a <vector216>:
.globl vector216
vector216:
  pushl $0
8010818a:	6a 00                	push   $0x0
  pushl $216
8010818c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108191:	e9 1a f1 ff ff       	jmp    801072b0 <alltraps>

80108196 <vector217>:
.globl vector217
vector217:
  pushl $0
80108196:	6a 00                	push   $0x0
  pushl $217
80108198:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010819d:	e9 0e f1 ff ff       	jmp    801072b0 <alltraps>

801081a2 <vector218>:
.globl vector218
vector218:
  pushl $0
801081a2:	6a 00                	push   $0x0
  pushl $218
801081a4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801081a9:	e9 02 f1 ff ff       	jmp    801072b0 <alltraps>

801081ae <vector219>:
.globl vector219
vector219:
  pushl $0
801081ae:	6a 00                	push   $0x0
  pushl $219
801081b0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801081b5:	e9 f6 f0 ff ff       	jmp    801072b0 <alltraps>

801081ba <vector220>:
.globl vector220
vector220:
  pushl $0
801081ba:	6a 00                	push   $0x0
  pushl $220
801081bc:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801081c1:	e9 ea f0 ff ff       	jmp    801072b0 <alltraps>

801081c6 <vector221>:
.globl vector221
vector221:
  pushl $0
801081c6:	6a 00                	push   $0x0
  pushl $221
801081c8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801081cd:	e9 de f0 ff ff       	jmp    801072b0 <alltraps>

801081d2 <vector222>:
.globl vector222
vector222:
  pushl $0
801081d2:	6a 00                	push   $0x0
  pushl $222
801081d4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801081d9:	e9 d2 f0 ff ff       	jmp    801072b0 <alltraps>

801081de <vector223>:
.globl vector223
vector223:
  pushl $0
801081de:	6a 00                	push   $0x0
  pushl $223
801081e0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801081e5:	e9 c6 f0 ff ff       	jmp    801072b0 <alltraps>

801081ea <vector224>:
.globl vector224
vector224:
  pushl $0
801081ea:	6a 00                	push   $0x0
  pushl $224
801081ec:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801081f1:	e9 ba f0 ff ff       	jmp    801072b0 <alltraps>

801081f6 <vector225>:
.globl vector225
vector225:
  pushl $0
801081f6:	6a 00                	push   $0x0
  pushl $225
801081f8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801081fd:	e9 ae f0 ff ff       	jmp    801072b0 <alltraps>

80108202 <vector226>:
.globl vector226
vector226:
  pushl $0
80108202:	6a 00                	push   $0x0
  pushl $226
80108204:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108209:	e9 a2 f0 ff ff       	jmp    801072b0 <alltraps>

8010820e <vector227>:
.globl vector227
vector227:
  pushl $0
8010820e:	6a 00                	push   $0x0
  pushl $227
80108210:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108215:	e9 96 f0 ff ff       	jmp    801072b0 <alltraps>

8010821a <vector228>:
.globl vector228
vector228:
  pushl $0
8010821a:	6a 00                	push   $0x0
  pushl $228
8010821c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108221:	e9 8a f0 ff ff       	jmp    801072b0 <alltraps>

80108226 <vector229>:
.globl vector229
vector229:
  pushl $0
80108226:	6a 00                	push   $0x0
  pushl $229
80108228:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010822d:	e9 7e f0 ff ff       	jmp    801072b0 <alltraps>

80108232 <vector230>:
.globl vector230
vector230:
  pushl $0
80108232:	6a 00                	push   $0x0
  pushl $230
80108234:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108239:	e9 72 f0 ff ff       	jmp    801072b0 <alltraps>

8010823e <vector231>:
.globl vector231
vector231:
  pushl $0
8010823e:	6a 00                	push   $0x0
  pushl $231
80108240:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108245:	e9 66 f0 ff ff       	jmp    801072b0 <alltraps>

8010824a <vector232>:
.globl vector232
vector232:
  pushl $0
8010824a:	6a 00                	push   $0x0
  pushl $232
8010824c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108251:	e9 5a f0 ff ff       	jmp    801072b0 <alltraps>

80108256 <vector233>:
.globl vector233
vector233:
  pushl $0
80108256:	6a 00                	push   $0x0
  pushl $233
80108258:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010825d:	e9 4e f0 ff ff       	jmp    801072b0 <alltraps>

80108262 <vector234>:
.globl vector234
vector234:
  pushl $0
80108262:	6a 00                	push   $0x0
  pushl $234
80108264:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108269:	e9 42 f0 ff ff       	jmp    801072b0 <alltraps>

8010826e <vector235>:
.globl vector235
vector235:
  pushl $0
8010826e:	6a 00                	push   $0x0
  pushl $235
80108270:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108275:	e9 36 f0 ff ff       	jmp    801072b0 <alltraps>

8010827a <vector236>:
.globl vector236
vector236:
  pushl $0
8010827a:	6a 00                	push   $0x0
  pushl $236
8010827c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108281:	e9 2a f0 ff ff       	jmp    801072b0 <alltraps>

80108286 <vector237>:
.globl vector237
vector237:
  pushl $0
80108286:	6a 00                	push   $0x0
  pushl $237
80108288:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010828d:	e9 1e f0 ff ff       	jmp    801072b0 <alltraps>

80108292 <vector238>:
.globl vector238
vector238:
  pushl $0
80108292:	6a 00                	push   $0x0
  pushl $238
80108294:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108299:	e9 12 f0 ff ff       	jmp    801072b0 <alltraps>

8010829e <vector239>:
.globl vector239
vector239:
  pushl $0
8010829e:	6a 00                	push   $0x0
  pushl $239
801082a0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801082a5:	e9 06 f0 ff ff       	jmp    801072b0 <alltraps>

801082aa <vector240>:
.globl vector240
vector240:
  pushl $0
801082aa:	6a 00                	push   $0x0
  pushl $240
801082ac:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801082b1:	e9 fa ef ff ff       	jmp    801072b0 <alltraps>

801082b6 <vector241>:
.globl vector241
vector241:
  pushl $0
801082b6:	6a 00                	push   $0x0
  pushl $241
801082b8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801082bd:	e9 ee ef ff ff       	jmp    801072b0 <alltraps>

801082c2 <vector242>:
.globl vector242
vector242:
  pushl $0
801082c2:	6a 00                	push   $0x0
  pushl $242
801082c4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801082c9:	e9 e2 ef ff ff       	jmp    801072b0 <alltraps>

801082ce <vector243>:
.globl vector243
vector243:
  pushl $0
801082ce:	6a 00                	push   $0x0
  pushl $243
801082d0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801082d5:	e9 d6 ef ff ff       	jmp    801072b0 <alltraps>

801082da <vector244>:
.globl vector244
vector244:
  pushl $0
801082da:	6a 00                	push   $0x0
  pushl $244
801082dc:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801082e1:	e9 ca ef ff ff       	jmp    801072b0 <alltraps>

801082e6 <vector245>:
.globl vector245
vector245:
  pushl $0
801082e6:	6a 00                	push   $0x0
  pushl $245
801082e8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801082ed:	e9 be ef ff ff       	jmp    801072b0 <alltraps>

801082f2 <vector246>:
.globl vector246
vector246:
  pushl $0
801082f2:	6a 00                	push   $0x0
  pushl $246
801082f4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801082f9:	e9 b2 ef ff ff       	jmp    801072b0 <alltraps>

801082fe <vector247>:
.globl vector247
vector247:
  pushl $0
801082fe:	6a 00                	push   $0x0
  pushl $247
80108300:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108305:	e9 a6 ef ff ff       	jmp    801072b0 <alltraps>

8010830a <vector248>:
.globl vector248
vector248:
  pushl $0
8010830a:	6a 00                	push   $0x0
  pushl $248
8010830c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108311:	e9 9a ef ff ff       	jmp    801072b0 <alltraps>

80108316 <vector249>:
.globl vector249
vector249:
  pushl $0
80108316:	6a 00                	push   $0x0
  pushl $249
80108318:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010831d:	e9 8e ef ff ff       	jmp    801072b0 <alltraps>

80108322 <vector250>:
.globl vector250
vector250:
  pushl $0
80108322:	6a 00                	push   $0x0
  pushl $250
80108324:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108329:	e9 82 ef ff ff       	jmp    801072b0 <alltraps>

8010832e <vector251>:
.globl vector251
vector251:
  pushl $0
8010832e:	6a 00                	push   $0x0
  pushl $251
80108330:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108335:	e9 76 ef ff ff       	jmp    801072b0 <alltraps>

8010833a <vector252>:
.globl vector252
vector252:
  pushl $0
8010833a:	6a 00                	push   $0x0
  pushl $252
8010833c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108341:	e9 6a ef ff ff       	jmp    801072b0 <alltraps>

80108346 <vector253>:
.globl vector253
vector253:
  pushl $0
80108346:	6a 00                	push   $0x0
  pushl $253
80108348:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010834d:	e9 5e ef ff ff       	jmp    801072b0 <alltraps>

80108352 <vector254>:
.globl vector254
vector254:
  pushl $0
80108352:	6a 00                	push   $0x0
  pushl $254
80108354:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108359:	e9 52 ef ff ff       	jmp    801072b0 <alltraps>

8010835e <vector255>:
.globl vector255
vector255:
  pushl $0
8010835e:	6a 00                	push   $0x0
  pushl $255
80108360:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108365:	e9 46 ef ff ff       	jmp    801072b0 <alltraps>
	...

8010836c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010836c:	55                   	push   %ebp
8010836d:	89 e5                	mov    %esp,%ebp
8010836f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108372:	8b 45 0c             	mov    0xc(%ebp),%eax
80108375:	48                   	dec    %eax
80108376:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010837a:	8b 45 08             	mov    0x8(%ebp),%eax
8010837d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108381:	8b 45 08             	mov    0x8(%ebp),%eax
80108384:	c1 e8 10             	shr    $0x10,%eax
80108387:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010838b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010838e:	0f 01 10             	lgdtl  (%eax)
}
80108391:	c9                   	leave  
80108392:	c3                   	ret    

80108393 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108393:	55                   	push   %ebp
80108394:	89 e5                	mov    %esp,%ebp
80108396:	83 ec 04             	sub    $0x4,%esp
80108399:	8b 45 08             	mov    0x8(%ebp),%eax
8010839c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801083a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083a3:	0f 00 d8             	ltr    %ax
}
801083a6:	c9                   	leave  
801083a7:	c3                   	ret    

801083a8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801083a8:	55                   	push   %ebp
801083a9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801083ab:	8b 45 08             	mov    0x8(%ebp),%eax
801083ae:	0f 22 d8             	mov    %eax,%cr3
}
801083b1:	5d                   	pop    %ebp
801083b2:	c3                   	ret    

801083b3 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801083b3:	55                   	push   %ebp
801083b4:	89 e5                	mov    %esp,%ebp
801083b6:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801083b9:	e8 d4 c0 ff ff       	call   80104492 <cpuid>
801083be:	89 c2                	mov    %eax,%edx
801083c0:	89 d0                	mov    %edx,%eax
801083c2:	c1 e0 02             	shl    $0x2,%eax
801083c5:	01 d0                	add    %edx,%eax
801083c7:	01 c0                	add    %eax,%eax
801083c9:	01 d0                	add    %edx,%eax
801083cb:	c1 e0 04             	shl    $0x4,%eax
801083ce:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
801083d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801083d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801083df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e2:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801083e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083eb:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801083ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f2:	8a 50 7d             	mov    0x7d(%eax),%dl
801083f5:	83 e2 f0             	and    $0xfffffff0,%edx
801083f8:	83 ca 0a             	or     $0xa,%edx
801083fb:	88 50 7d             	mov    %dl,0x7d(%eax)
801083fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108401:	8a 50 7d             	mov    0x7d(%eax),%dl
80108404:	83 ca 10             	or     $0x10,%edx
80108407:	88 50 7d             	mov    %dl,0x7d(%eax)
8010840a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108410:	83 e2 9f             	and    $0xffffff9f,%edx
80108413:	88 50 7d             	mov    %dl,0x7d(%eax)
80108416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108419:	8a 50 7d             	mov    0x7d(%eax),%dl
8010841c:	83 ca 80             	or     $0xffffff80,%edx
8010841f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108425:	8a 50 7e             	mov    0x7e(%eax),%dl
80108428:	83 ca 0f             	or     $0xf,%edx
8010842b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010842e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108431:	8a 50 7e             	mov    0x7e(%eax),%dl
80108434:	83 e2 ef             	and    $0xffffffef,%edx
80108437:	88 50 7e             	mov    %dl,0x7e(%eax)
8010843a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843d:	8a 50 7e             	mov    0x7e(%eax),%dl
80108440:	83 e2 df             	and    $0xffffffdf,%edx
80108443:	88 50 7e             	mov    %dl,0x7e(%eax)
80108446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108449:	8a 50 7e             	mov    0x7e(%eax),%dl
8010844c:	83 ca 40             	or     $0x40,%edx
8010844f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108455:	8a 50 7e             	mov    0x7e(%eax),%dl
80108458:	83 ca 80             	or     $0xffffff80,%edx
8010845b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010845e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108461:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108468:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010846f:	ff ff 
80108471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108474:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010847b:	00 00 
8010847d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108480:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108490:	83 e2 f0             	and    $0xfffffff0,%edx
80108493:	83 ca 02             	or     $0x2,%edx
80108496:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010849c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801084a5:	83 ca 10             	or     $0x10,%edx
801084a8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b1:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801084b7:	83 e2 9f             	and    $0xffffff9f,%edx
801084ba:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c3:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801084c9:	83 ca 80             	or     $0xffffff80,%edx
801084cc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d5:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801084db:	83 ca 0f             	or     $0xf,%edx
801084de:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e7:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801084ed:	83 e2 ef             	and    $0xffffffef,%edx
801084f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801084ff:	83 e2 df             	and    $0xffffffdf,%edx
80108502:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108511:	83 ca 40             	or     $0x40,%edx
80108514:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010851a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108523:	83 ca 80             	or     $0xffffff80,%edx
80108526:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010852c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108539:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108540:	ff ff 
80108542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108545:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010854c:	00 00 
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80108558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855b:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108561:	83 e2 f0             	and    $0xfffffff0,%edx
80108564:	83 ca 0a             	or     $0xa,%edx
80108567:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010856d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108570:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108576:	83 ca 10             	or     $0x10,%edx
80108579:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010857f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108582:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108588:	83 ca 60             	or     $0x60,%edx
8010858b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108594:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010859a:	83 ca 80             	or     $0xffffff80,%edx
8010859d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a6:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085ac:	83 ca 0f             	or     $0xf,%edx
801085af:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b8:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085be:	83 e2 ef             	and    $0xffffffef,%edx
801085c1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ca:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085d0:	83 e2 df             	and    $0xffffffdf,%edx
801085d3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085dc:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085e2:	83 ca 40             	or     $0x40,%edx
801085e5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085f4:	83 ca 80             	or     $0xffffff80,%edx
801085f7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108600:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108611:	ff ff 
80108613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108616:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010861d:	00 00 
8010861f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108622:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862c:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108632:	83 e2 f0             	and    $0xfffffff0,%edx
80108635:	83 ca 02             	or     $0x2,%edx
80108638:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010863e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108641:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108647:	83 ca 10             	or     $0x10,%edx
8010864a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108653:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108659:	83 ca 60             	or     $0x60,%edx
8010865c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108665:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010866b:	83 ca 80             	or     $0xffffff80,%edx
8010866e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010867d:	83 ca 0f             	or     $0xf,%edx
80108680:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108689:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010868f:	83 e2 ef             	and    $0xffffffef,%edx
80108692:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086a1:	83 e2 df             	and    $0xffffffdf,%edx
801086a4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ad:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086b3:	83 ca 40             	or     $0x40,%edx
801086b6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bf:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086c5:	83 ca 80             	or     $0xffffff80,%edx
801086c8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801086d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086db:	83 c0 70             	add    $0x70,%eax
801086de:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801086e5:	00 
801086e6:	89 04 24             	mov    %eax,(%esp)
801086e9:	e8 7e fc ff ff       	call   8010836c <lgdt>
}
801086ee:	c9                   	leave  
801086ef:	c3                   	ret    

801086f0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801086f0:	55                   	push   %ebp
801086f1:	89 e5                	mov    %esp,%ebp
801086f3:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801086f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801086f9:	c1 e8 16             	shr    $0x16,%eax
801086fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108703:	8b 45 08             	mov    0x8(%ebp),%eax
80108706:	01 d0                	add    %edx,%eax
80108708:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010870b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010870e:	8b 00                	mov    (%eax),%eax
80108710:	83 e0 01             	and    $0x1,%eax
80108713:	85 c0                	test   %eax,%eax
80108715:	74 14                	je     8010872b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871a:	8b 00                	mov    (%eax),%eax
8010871c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108721:	05 00 00 00 80       	add    $0x80000000,%eax
80108726:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108729:	eb 48                	jmp    80108773 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010872b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010872f:	74 0e                	je     8010873f <walkpgdir+0x4f>
80108731:	e8 7e a7 ff ff       	call   80102eb4 <kalloc>
80108736:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108739:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010873d:	75 07                	jne    80108746 <walkpgdir+0x56>
      return 0;
8010873f:	b8 00 00 00 00       	mov    $0x0,%eax
80108744:	eb 44                	jmp    8010878a <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108746:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010874d:	00 
8010874e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108755:	00 
80108756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108759:	89 04 24             	mov    %eax,(%esp)
8010875c:	e8 3d d0 ff ff       	call   8010579e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108764:	05 00 00 00 80       	add    $0x80000000,%eax
80108769:	83 c8 07             	or     $0x7,%eax
8010876c:	89 c2                	mov    %eax,%edx
8010876e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108771:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108773:	8b 45 0c             	mov    0xc(%ebp),%eax
80108776:	c1 e8 0c             	shr    $0xc,%eax
80108779:	25 ff 03 00 00       	and    $0x3ff,%eax
8010877e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108788:	01 d0                	add    %edx,%eax
}
8010878a:	c9                   	leave  
8010878b:	c3                   	ret    

8010878c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010878c:	55                   	push   %ebp
8010878d:	89 e5                	mov    %esp,%ebp
8010878f:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108792:	8b 45 0c             	mov    0xc(%ebp),%eax
80108795:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010879a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010879d:	8b 55 0c             	mov    0xc(%ebp),%edx
801087a0:	8b 45 10             	mov    0x10(%ebp),%eax
801087a3:	01 d0                	add    %edx,%eax
801087a5:	48                   	dec    %eax
801087a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801087ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801087b5:	00 
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801087bd:	8b 45 08             	mov    0x8(%ebp),%eax
801087c0:	89 04 24             	mov    %eax,(%esp)
801087c3:	e8 28 ff ff ff       	call   801086f0 <walkpgdir>
801087c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087cf:	75 07                	jne    801087d8 <mappages+0x4c>
      return -1;
801087d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087d6:	eb 48                	jmp    80108820 <mappages+0x94>
    if(*pte & PTE_P)
801087d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087db:	8b 00                	mov    (%eax),%eax
801087dd:	83 e0 01             	and    $0x1,%eax
801087e0:	85 c0                	test   %eax,%eax
801087e2:	74 0c                	je     801087f0 <mappages+0x64>
      panic("remap");
801087e4:	c7 04 24 ec a0 10 80 	movl   $0x8010a0ec,(%esp)
801087eb:	e8 64 7d ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
801087f0:	8b 45 18             	mov    0x18(%ebp),%eax
801087f3:	0b 45 14             	or     0x14(%ebp),%eax
801087f6:	83 c8 01             	or     $0x1,%eax
801087f9:	89 c2                	mov    %eax,%edx
801087fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fe:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108803:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108806:	75 08                	jne    80108810 <mappages+0x84>
      break;
80108808:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108809:	b8 00 00 00 00       	mov    $0x0,%eax
8010880e:	eb 10                	jmp    80108820 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108810:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108817:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010881e:	eb 8e                	jmp    801087ae <mappages+0x22>
  return 0;
}
80108820:	c9                   	leave  
80108821:	c3                   	ret    

80108822 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108822:	55                   	push   %ebp
80108823:	89 e5                	mov    %esp,%ebp
80108825:	53                   	push   %ebx
80108826:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108829:	e8 86 a6 ff ff       	call   80102eb4 <kalloc>
8010882e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108831:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108835:	75 0a                	jne    80108841 <setupkvm+0x1f>
    return 0;
80108837:	b8 00 00 00 00       	mov    $0x0,%eax
8010883c:	e9 84 00 00 00       	jmp    801088c5 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108841:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108848:	00 
80108849:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108850:	00 
80108851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108854:	89 04 24             	mov    %eax,(%esp)
80108857:	e8 42 cf ff ff       	call   8010579e <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010885c:	c7 45 f4 20 d5 10 80 	movl   $0x8010d520,-0xc(%ebp)
80108863:	eb 54                	jmp    801088b9 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108868:	8b 48 0c             	mov    0xc(%eax),%ecx
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	8b 50 04             	mov    0x4(%eax),%edx
80108871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108874:	8b 58 08             	mov    0x8(%eax),%ebx
80108877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887a:	8b 40 04             	mov    0x4(%eax),%eax
8010887d:	29 c3                	sub    %eax,%ebx
8010887f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108882:	8b 00                	mov    (%eax),%eax
80108884:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108888:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010888c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108890:	89 44 24 04          	mov    %eax,0x4(%esp)
80108894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108897:	89 04 24             	mov    %eax,(%esp)
8010889a:	e8 ed fe ff ff       	call   8010878c <mappages>
8010889f:	85 c0                	test   %eax,%eax
801088a1:	79 12                	jns    801088b5 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
801088a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088a6:	89 04 24             	mov    %eax,(%esp)
801088a9:	e8 1a 05 00 00       	call   80108dc8 <freevm>
      return 0;
801088ae:	b8 00 00 00 00       	mov    $0x0,%eax
801088b3:	eb 10                	jmp    801088c5 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801088b5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801088b9:	81 7d f4 60 d5 10 80 	cmpl   $0x8010d560,-0xc(%ebp)
801088c0:	72 a3                	jb     80108865 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
801088c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801088c5:	83 c4 34             	add    $0x34,%esp
801088c8:	5b                   	pop    %ebx
801088c9:	5d                   	pop    %ebp
801088ca:	c3                   	ret    

801088cb <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801088cb:	55                   	push   %ebp
801088cc:	89 e5                	mov    %esp,%ebp
801088ce:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801088d1:	e8 4c ff ff ff       	call   80108822 <setupkvm>
801088d6:	a3 e4 8b 11 80       	mov    %eax,0x80118be4
  switchkvm();
801088db:	e8 02 00 00 00       	call   801088e2 <switchkvm>
}
801088e0:	c9                   	leave  
801088e1:	c3                   	ret    

801088e2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801088e2:	55                   	push   %ebp
801088e3:	89 e5                	mov    %esp,%ebp
801088e5:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801088e8:	a1 e4 8b 11 80       	mov    0x80118be4,%eax
801088ed:	05 00 00 00 80       	add    $0x80000000,%eax
801088f2:	89 04 24             	mov    %eax,(%esp)
801088f5:	e8 ae fa ff ff       	call   801083a8 <lcr3>
}
801088fa:	c9                   	leave  
801088fb:	c3                   	ret    

801088fc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801088fc:	55                   	push   %ebp
801088fd:	89 e5                	mov    %esp,%ebp
801088ff:	57                   	push   %edi
80108900:	56                   	push   %esi
80108901:	53                   	push   %ebx
80108902:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108905:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108909:	75 0c                	jne    80108917 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010890b:	c7 04 24 f2 a0 10 80 	movl   $0x8010a0f2,(%esp)
80108912:	e8 3d 7c ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108917:	8b 45 08             	mov    0x8(%ebp),%eax
8010891a:	8b 40 08             	mov    0x8(%eax),%eax
8010891d:	85 c0                	test   %eax,%eax
8010891f:	75 0c                	jne    8010892d <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108921:	c7 04 24 08 a1 10 80 	movl   $0x8010a108,(%esp)
80108928:	e8 27 7c ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
8010892d:	8b 45 08             	mov    0x8(%ebp),%eax
80108930:	8b 40 04             	mov    0x4(%eax),%eax
80108933:	85 c0                	test   %eax,%eax
80108935:	75 0c                	jne    80108943 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108937:	c7 04 24 1d a1 10 80 	movl   $0x8010a11d,(%esp)
8010893e:	e8 11 7c ff ff       	call   80100554 <panic>

  pushcli();
80108943:	e8 52 cd ff ff       	call   8010569a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108948:	e8 8a bb ff ff       	call   801044d7 <mycpu>
8010894d:	89 c3                	mov    %eax,%ebx
8010894f:	e8 83 bb ff ff       	call   801044d7 <mycpu>
80108954:	83 c0 08             	add    $0x8,%eax
80108957:	89 c6                	mov    %eax,%esi
80108959:	e8 79 bb ff ff       	call   801044d7 <mycpu>
8010895e:	83 c0 08             	add    $0x8,%eax
80108961:	c1 e8 10             	shr    $0x10,%eax
80108964:	89 c7                	mov    %eax,%edi
80108966:	e8 6c bb ff ff       	call   801044d7 <mycpu>
8010896b:	83 c0 08             	add    $0x8,%eax
8010896e:	c1 e8 18             	shr    $0x18,%eax
80108971:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108978:	67 00 
8010897a:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108981:	89 f9                	mov    %edi,%ecx
80108983:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108989:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010898f:	83 e2 f0             	and    $0xfffffff0,%edx
80108992:	83 ca 09             	or     $0x9,%edx
80108995:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010899b:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089a1:	83 ca 10             	or     $0x10,%edx
801089a4:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801089aa:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089b0:	83 e2 9f             	and    $0xffffff9f,%edx
801089b3:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801089b9:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089bf:	83 ca 80             	or     $0xffffff80,%edx
801089c2:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801089c8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801089ce:	83 e2 f0             	and    $0xfffffff0,%edx
801089d1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801089d7:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801089dd:	83 e2 ef             	and    $0xffffffef,%edx
801089e0:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801089e6:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801089ec:	83 e2 df             	and    $0xffffffdf,%edx
801089ef:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801089f5:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801089fb:	83 ca 40             	or     $0x40,%edx
801089fe:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a04:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a0a:	83 e2 7f             	and    $0x7f,%edx
80108a0d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a13:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108a19:	e8 b9 ba ff ff       	call   801044d7 <mycpu>
80108a1e:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108a24:	83 e2 ef             	and    $0xffffffef,%edx
80108a27:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108a2d:	e8 a5 ba ff ff       	call   801044d7 <mycpu>
80108a32:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108a38:	e8 9a ba ff ff       	call   801044d7 <mycpu>
80108a3d:	8b 55 08             	mov    0x8(%ebp),%edx
80108a40:	8b 52 08             	mov    0x8(%edx),%edx
80108a43:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108a49:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108a4c:	e8 86 ba ff ff       	call   801044d7 <mycpu>
80108a51:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108a57:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108a5e:	e8 30 f9 ff ff       	call   80108393 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108a63:	8b 45 08             	mov    0x8(%ebp),%eax
80108a66:	8b 40 04             	mov    0x4(%eax),%eax
80108a69:	05 00 00 00 80       	add    $0x80000000,%eax
80108a6e:	89 04 24             	mov    %eax,(%esp)
80108a71:	e8 32 f9 ff ff       	call   801083a8 <lcr3>
  popcli();
80108a76:	e8 69 cc ff ff       	call   801056e4 <popcli>
}
80108a7b:	83 c4 1c             	add    $0x1c,%esp
80108a7e:	5b                   	pop    %ebx
80108a7f:	5e                   	pop    %esi
80108a80:	5f                   	pop    %edi
80108a81:	5d                   	pop    %ebp
80108a82:	c3                   	ret    

80108a83 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108a83:	55                   	push   %ebp
80108a84:	89 e5                	mov    %esp,%ebp
80108a86:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108a89:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108a90:	76 0c                	jbe    80108a9e <inituvm+0x1b>
    panic("inituvm: more than a page");
80108a92:	c7 04 24 31 a1 10 80 	movl   $0x8010a131,(%esp)
80108a99:	e8 b6 7a ff ff       	call   80100554 <panic>
  mem = kalloc();
80108a9e:	e8 11 a4 ff ff       	call   80102eb4 <kalloc>
80108aa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108aa6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108aad:	00 
80108aae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108ab5:	00 
80108ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab9:	89 04 24             	mov    %eax,(%esp)
80108abc:	e8 dd cc ff ff       	call   8010579e <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac4:	05 00 00 00 80       	add    $0x80000000,%eax
80108ac9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108ad0:	00 
80108ad1:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108ad5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108adc:	00 
80108add:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108ae4:	00 
80108ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae8:	89 04 24             	mov    %eax,(%esp)
80108aeb:	e8 9c fc ff ff       	call   8010878c <mappages>
  memmove(mem, init, sz);
80108af0:	8b 45 10             	mov    0x10(%ebp),%eax
80108af3:	89 44 24 08          	mov    %eax,0x8(%esp)
80108af7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108afa:	89 44 24 04          	mov    %eax,0x4(%esp)
80108afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b01:	89 04 24             	mov    %eax,(%esp)
80108b04:	e8 5e cd ff ff       	call   80105867 <memmove>
}
80108b09:	c9                   	leave  
80108b0a:	c3                   	ret    

80108b0b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108b0b:	55                   	push   %ebp
80108b0c:	89 e5                	mov    %esp,%ebp
80108b0e:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108b11:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b14:	25 ff 0f 00 00       	and    $0xfff,%eax
80108b19:	85 c0                	test   %eax,%eax
80108b1b:	74 0c                	je     80108b29 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108b1d:	c7 04 24 4c a1 10 80 	movl   $0x8010a14c,(%esp)
80108b24:	e8 2b 7a ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108b29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b30:	e9 a6 00 00 00       	jmp    80108bdb <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b38:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b3b:	01 d0                	add    %edx,%eax
80108b3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b44:	00 
80108b45:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b49:	8b 45 08             	mov    0x8(%ebp),%eax
80108b4c:	89 04 24             	mov    %eax,(%esp)
80108b4f:	e8 9c fb ff ff       	call   801086f0 <walkpgdir>
80108b54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b5b:	75 0c                	jne    80108b69 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108b5d:	c7 04 24 6f a1 10 80 	movl   $0x8010a16f,(%esp)
80108b64:	e8 eb 79 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108b69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b6c:	8b 00                	mov    (%eax),%eax
80108b6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b73:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b79:	8b 55 18             	mov    0x18(%ebp),%edx
80108b7c:	29 c2                	sub    %eax,%edx
80108b7e:	89 d0                	mov    %edx,%eax
80108b80:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108b85:	77 0f                	ja     80108b96 <loaduvm+0x8b>
      n = sz - i;
80108b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8a:	8b 55 18             	mov    0x18(%ebp),%edx
80108b8d:	29 c2                	sub    %eax,%edx
80108b8f:	89 d0                	mov    %edx,%eax
80108b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b94:	eb 07                	jmp    80108b9d <loaduvm+0x92>
    else
      n = PGSIZE;
80108b96:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba0:	8b 55 14             	mov    0x14(%ebp),%edx
80108ba3:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108ba6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba9:	05 00 00 00 80       	add    $0x80000000,%eax
80108bae:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108bb5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bbd:	8b 45 10             	mov    0x10(%ebp),%eax
80108bc0:	89 04 24             	mov    %eax,(%esp)
80108bc3:	e8 91 93 ff ff       	call   80101f59 <readi>
80108bc8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108bcb:	74 07                	je     80108bd4 <loaduvm+0xc9>
      return -1;
80108bcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bd2:	eb 18                	jmp    80108bec <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108bd4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bde:	3b 45 18             	cmp    0x18(%ebp),%eax
80108be1:	0f 82 4e ff ff ff    	jb     80108b35 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108be7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bec:	c9                   	leave  
80108bed:	c3                   	ret    

80108bee <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108bee:	55                   	push   %ebp
80108bef:	89 e5                	mov    %esp,%ebp
80108bf1:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108bf4:	8b 45 10             	mov    0x10(%ebp),%eax
80108bf7:	85 c0                	test   %eax,%eax
80108bf9:	79 0a                	jns    80108c05 <allocuvm+0x17>
    return 0;
80108bfb:	b8 00 00 00 00       	mov    $0x0,%eax
80108c00:	e9 fd 00 00 00       	jmp    80108d02 <allocuvm+0x114>
  if(newsz < oldsz)
80108c05:	8b 45 10             	mov    0x10(%ebp),%eax
80108c08:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c0b:	73 08                	jae    80108c15 <allocuvm+0x27>
    return oldsz;
80108c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c10:	e9 ed 00 00 00       	jmp    80108d02 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108c15:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c18:	05 ff 0f 00 00       	add    $0xfff,%eax
80108c1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108c25:	e9 c9 00 00 00       	jmp    80108cf3 <allocuvm+0x105>
    mem = kalloc();
80108c2a:	e8 85 a2 ff ff       	call   80102eb4 <kalloc>
80108c2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108c32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c36:	75 2f                	jne    80108c67 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108c38:	c7 04 24 8d a1 10 80 	movl   $0x8010a18d,(%esp)
80108c3f:	e8 7d 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108c44:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c47:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c4b:	8b 45 10             	mov    0x10(%ebp),%eax
80108c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c52:	8b 45 08             	mov    0x8(%ebp),%eax
80108c55:	89 04 24             	mov    %eax,(%esp)
80108c58:	e8 a7 00 00 00       	call   80108d04 <deallocuvm>
      return 0;
80108c5d:	b8 00 00 00 00       	mov    $0x0,%eax
80108c62:	e9 9b 00 00 00       	jmp    80108d02 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108c67:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c6e:	00 
80108c6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108c76:	00 
80108c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c7a:	89 04 24             	mov    %eax,(%esp)
80108c7d:	e8 1c cb ff ff       	call   8010579e <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c85:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108c95:	00 
80108c96:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108c9a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ca1:	00 
80108ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca9:	89 04 24             	mov    %eax,(%esp)
80108cac:	e8 db fa ff ff       	call   8010878c <mappages>
80108cb1:	85 c0                	test   %eax,%eax
80108cb3:	79 37                	jns    80108cec <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108cb5:	c7 04 24 a5 a1 10 80 	movl   $0x8010a1a5,(%esp)
80108cbc:	e8 00 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
80108cc8:	8b 45 10             	mov    0x10(%ebp),%eax
80108ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd2:	89 04 24             	mov    %eax,(%esp)
80108cd5:	e8 2a 00 00 00       	call   80108d04 <deallocuvm>
      kfree(mem);
80108cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cdd:	89 04 24             	mov    %eax,(%esp)
80108ce0:	e8 f2 a0 ff ff       	call   80102dd7 <kfree>
      return 0;
80108ce5:	b8 00 00 00 00       	mov    $0x0,%eax
80108cea:	eb 16                	jmp    80108d02 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108cec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf6:	3b 45 10             	cmp    0x10(%ebp),%eax
80108cf9:	0f 82 2b ff ff ff    	jb     80108c2a <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108cff:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d02:	c9                   	leave  
80108d03:	c3                   	ret    

80108d04 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108d04:	55                   	push   %ebp
80108d05:	89 e5                	mov    %esp,%ebp
80108d07:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108d0a:	8b 45 10             	mov    0x10(%ebp),%eax
80108d0d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d10:	72 08                	jb     80108d1a <deallocuvm+0x16>
    return oldsz;
80108d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d15:	e9 ac 00 00 00       	jmp    80108dc6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108d1a:	8b 45 10             	mov    0x10(%ebp),%eax
80108d1d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d22:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108d2a:	e9 88 00 00 00       	jmp    80108db7 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d32:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d39:	00 
80108d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d41:	89 04 24             	mov    %eax,(%esp)
80108d44:	e8 a7 f9 ff ff       	call   801086f0 <walkpgdir>
80108d49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108d4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d50:	75 14                	jne    80108d66 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d55:	c1 e8 16             	shr    $0x16,%eax
80108d58:	40                   	inc    %eax
80108d59:	c1 e0 16             	shl    $0x16,%eax
80108d5c:	2d 00 10 00 00       	sub    $0x1000,%eax
80108d61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108d64:	eb 4a                	jmp    80108db0 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d69:	8b 00                	mov    (%eax),%eax
80108d6b:	83 e0 01             	and    $0x1,%eax
80108d6e:	85 c0                	test   %eax,%eax
80108d70:	74 3e                	je     80108db0 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d75:	8b 00                	mov    (%eax),%eax
80108d77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108d7f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d83:	75 0c                	jne    80108d91 <deallocuvm+0x8d>
        panic("kfree");
80108d85:	c7 04 24 c1 a1 10 80 	movl   $0x8010a1c1,(%esp)
80108d8c:	e8 c3 77 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108d91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d94:	05 00 00 00 80       	add    $0x80000000,%eax
80108d99:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108d9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d9f:	89 04 24             	mov    %eax,(%esp)
80108da2:	e8 30 a0 ff ff       	call   80102dd7 <kfree>
      *pte = 0;
80108da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108daa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108db0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dba:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108dbd:	0f 82 6c ff ff ff    	jb     80108d2f <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108dc3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108dc6:	c9                   	leave  
80108dc7:	c3                   	ret    

80108dc8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108dc8:	55                   	push   %ebp
80108dc9:	89 e5                	mov    %esp,%ebp
80108dcb:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108dce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108dd2:	75 0c                	jne    80108de0 <freevm+0x18>
    panic("freevm: no pgdir");
80108dd4:	c7 04 24 c7 a1 10 80 	movl   $0x8010a1c7,(%esp)
80108ddb:	e8 74 77 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108de0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108de7:	00 
80108de8:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108def:	80 
80108df0:	8b 45 08             	mov    0x8(%ebp),%eax
80108df3:	89 04 24             	mov    %eax,(%esp)
80108df6:	e8 09 ff ff ff       	call   80108d04 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108dfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e02:	eb 44                	jmp    80108e48 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80108e11:	01 d0                	add    %edx,%eax
80108e13:	8b 00                	mov    (%eax),%eax
80108e15:	83 e0 01             	and    $0x1,%eax
80108e18:	85 c0                	test   %eax,%eax
80108e1a:	74 29                	je     80108e45 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e26:	8b 45 08             	mov    0x8(%ebp),%eax
80108e29:	01 d0                	add    %edx,%eax
80108e2b:	8b 00                	mov    (%eax),%eax
80108e2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e32:	05 00 00 00 80       	add    $0x80000000,%eax
80108e37:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e3d:	89 04 24             	mov    %eax,(%esp)
80108e40:	e8 92 9f ff ff       	call   80102dd7 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108e45:	ff 45 f4             	incl   -0xc(%ebp)
80108e48:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108e4f:	76 b3                	jbe    80108e04 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108e51:	8b 45 08             	mov    0x8(%ebp),%eax
80108e54:	89 04 24             	mov    %eax,(%esp)
80108e57:	e8 7b 9f ff ff       	call   80102dd7 <kfree>
}
80108e5c:	c9                   	leave  
80108e5d:	c3                   	ret    

80108e5e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108e5e:	55                   	push   %ebp
80108e5f:	89 e5                	mov    %esp,%ebp
80108e61:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108e64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e6b:	00 
80108e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e73:	8b 45 08             	mov    0x8(%ebp),%eax
80108e76:	89 04 24             	mov    %eax,(%esp)
80108e79:	e8 72 f8 ff ff       	call   801086f0 <walkpgdir>
80108e7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108e81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108e85:	75 0c                	jne    80108e93 <clearpteu+0x35>
    panic("clearpteu");
80108e87:	c7 04 24 d8 a1 10 80 	movl   $0x8010a1d8,(%esp)
80108e8e:	e8 c1 76 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e96:	8b 00                	mov    (%eax),%eax
80108e98:	83 e0 fb             	and    $0xfffffffb,%eax
80108e9b:	89 c2                	mov    %eax,%edx
80108e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea0:	89 10                	mov    %edx,(%eax)
}
80108ea2:	c9                   	leave  
80108ea3:	c3                   	ret    

80108ea4 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108ea4:	55                   	push   %ebp
80108ea5:	89 e5                	mov    %esp,%ebp
80108ea7:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108eaa:	e8 73 f9 ff ff       	call   80108822 <setupkvm>
80108eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108eb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108eb6:	75 0a                	jne    80108ec2 <copyuvm+0x1e>
    return 0;
80108eb8:	b8 00 00 00 00       	mov    $0x0,%eax
80108ebd:	e9 f8 00 00 00       	jmp    80108fba <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108ec2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ec9:	e9 cb 00 00 00       	jmp    80108f99 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ed8:	00 
80108ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108edd:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee0:	89 04 24             	mov    %eax,(%esp)
80108ee3:	e8 08 f8 ff ff       	call   801086f0 <walkpgdir>
80108ee8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108eeb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108eef:	75 0c                	jne    80108efd <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108ef1:	c7 04 24 e2 a1 10 80 	movl   $0x8010a1e2,(%esp)
80108ef8:	e8 57 76 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108efd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f00:	8b 00                	mov    (%eax),%eax
80108f02:	83 e0 01             	and    $0x1,%eax
80108f05:	85 c0                	test   %eax,%eax
80108f07:	75 0c                	jne    80108f15 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108f09:	c7 04 24 fc a1 10 80 	movl   $0x8010a1fc,(%esp)
80108f10:	e8 3f 76 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f18:	8b 00                	mov    (%eax),%eax
80108f1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f25:	8b 00                	mov    (%eax),%eax
80108f27:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108f2f:	e8 80 9f ff ff       	call   80102eb4 <kalloc>
80108f34:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108f37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108f3b:	75 02                	jne    80108f3f <copyuvm+0x9b>
      goto bad;
80108f3d:	eb 6b                	jmp    80108faa <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108f3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f42:	05 00 00 00 80       	add    $0x80000000,%eax
80108f47:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f4e:	00 
80108f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f56:	89 04 24             	mov    %eax,(%esp)
80108f59:	e8 09 c9 ff ff       	call   80105867 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108f5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f64:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6d:	89 54 24 10          	mov    %edx,0x10(%esp)
80108f71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108f75:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f7c:	00 
80108f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f84:	89 04 24             	mov    %eax,(%esp)
80108f87:	e8 00 f8 ff ff       	call   8010878c <mappages>
80108f8c:	85 c0                	test   %eax,%eax
80108f8e:	79 02                	jns    80108f92 <copyuvm+0xee>
      goto bad;
80108f90:	eb 18                	jmp    80108faa <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108f92:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f9f:	0f 82 29 ff ff ff    	jb     80108ece <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa8:	eb 10                	jmp    80108fba <copyuvm+0x116>

bad:
  freevm(d);
80108faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fad:	89 04 24             	mov    %eax,(%esp)
80108fb0:	e8 13 fe ff ff       	call   80108dc8 <freevm>
  return 0;
80108fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108fba:	c9                   	leave  
80108fbb:	c3                   	ret    

80108fbc <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108fbc:	55                   	push   %ebp
80108fbd:	89 e5                	mov    %esp,%ebp
80108fbf:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108fc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108fc9:	00 
80108fca:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80108fd4:	89 04 24             	mov    %eax,(%esp)
80108fd7:	e8 14 f7 ff ff       	call   801086f0 <walkpgdir>
80108fdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe2:	8b 00                	mov    (%eax),%eax
80108fe4:	83 e0 01             	and    $0x1,%eax
80108fe7:	85 c0                	test   %eax,%eax
80108fe9:	75 07                	jne    80108ff2 <uva2ka+0x36>
    return 0;
80108feb:	b8 00 00 00 00       	mov    $0x0,%eax
80108ff0:	eb 22                	jmp    80109014 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff5:	8b 00                	mov    (%eax),%eax
80108ff7:	83 e0 04             	and    $0x4,%eax
80108ffa:	85 c0                	test   %eax,%eax
80108ffc:	75 07                	jne    80109005 <uva2ka+0x49>
    return 0;
80108ffe:	b8 00 00 00 00       	mov    $0x0,%eax
80109003:	eb 0f                	jmp    80109014 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80109005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109008:	8b 00                	mov    (%eax),%eax
8010900a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010900f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80109014:	c9                   	leave  
80109015:	c3                   	ret    

80109016 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109016:	55                   	push   %ebp
80109017:	89 e5                	mov    %esp,%ebp
80109019:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010901c:	8b 45 10             	mov    0x10(%ebp),%eax
8010901f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109022:	e9 87 00 00 00       	jmp    801090ae <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80109027:	8b 45 0c             	mov    0xc(%ebp),%eax
8010902a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010902f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109032:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109035:	89 44 24 04          	mov    %eax,0x4(%esp)
80109039:	8b 45 08             	mov    0x8(%ebp),%eax
8010903c:	89 04 24             	mov    %eax,(%esp)
8010903f:	e8 78 ff ff ff       	call   80108fbc <uva2ka>
80109044:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109047:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010904b:	75 07                	jne    80109054 <copyout+0x3e>
      return -1;
8010904d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109052:	eb 69                	jmp    801090bd <copyout+0xa7>
    n = PGSIZE - (va - va0);
80109054:	8b 45 0c             	mov    0xc(%ebp),%eax
80109057:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010905a:	29 c2                	sub    %eax,%edx
8010905c:	89 d0                	mov    %edx,%eax
8010905e:	05 00 10 00 00       	add    $0x1000,%eax
80109063:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109066:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109069:	3b 45 14             	cmp    0x14(%ebp),%eax
8010906c:	76 06                	jbe    80109074 <copyout+0x5e>
      n = len;
8010906e:	8b 45 14             	mov    0x14(%ebp),%eax
80109071:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109077:	8b 55 0c             	mov    0xc(%ebp),%edx
8010907a:	29 c2                	sub    %eax,%edx
8010907c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010907f:	01 c2                	add    %eax,%edx
80109081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109084:	89 44 24 08          	mov    %eax,0x8(%esp)
80109088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010908b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010908f:	89 14 24             	mov    %edx,(%esp)
80109092:	e8 d0 c7 ff ff       	call   80105867 <memmove>
    len -= n;
80109097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010909a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010909d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801090a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090a6:	05 00 10 00 00       	add    $0x1000,%eax
801090ab:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801090ae:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801090b2:	0f 85 6f ff ff ff    	jne    80109027 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801090b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801090bd:	c9                   	leave  
801090be:	c3                   	ret    
	...

801090c0 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
801090c0:	55                   	push   %ebp
801090c1:	89 e5                	mov    %esp,%ebp
801090c3:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
801090c6:	8b 45 10             	mov    0x10(%ebp),%eax
801090c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801090cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801090d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801090d4:	8b 45 08             	mov    0x8(%ebp),%eax
801090d7:	89 04 24             	mov    %eax,(%esp)
801090da:	e8 88 c7 ff ff       	call   80105867 <memmove>
}
801090df:	c9                   	leave  
801090e0:	c3                   	ret    

801090e1 <strcpy>:

char* strcpy(char *s, char *t){
801090e1:	55                   	push   %ebp
801090e2:	89 e5                	mov    %esp,%ebp
801090e4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801090e7:	8b 45 08             	mov    0x8(%ebp),%eax
801090ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
801090ed:	90                   	nop
801090ee:	8b 45 08             	mov    0x8(%ebp),%eax
801090f1:	8d 50 01             	lea    0x1(%eax),%edx
801090f4:	89 55 08             	mov    %edx,0x8(%ebp)
801090f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801090fa:	8d 4a 01             	lea    0x1(%edx),%ecx
801090fd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80109100:	8a 12                	mov    (%edx),%dl
80109102:	88 10                	mov    %dl,(%eax)
80109104:	8a 00                	mov    (%eax),%al
80109106:	84 c0                	test   %al,%al
80109108:	75 e4                	jne    801090ee <strcpy+0xd>
    ;
  return os;
8010910a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010910d:	c9                   	leave  
8010910e:	c3                   	ret    

8010910f <strcmp>:

int
strcmp(const char *p, const char *q)
{
8010910f:	55                   	push   %ebp
80109110:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80109112:	eb 06                	jmp    8010911a <strcmp+0xb>
    p++, q++;
80109114:	ff 45 08             	incl   0x8(%ebp)
80109117:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
8010911a:	8b 45 08             	mov    0x8(%ebp),%eax
8010911d:	8a 00                	mov    (%eax),%al
8010911f:	84 c0                	test   %al,%al
80109121:	74 0e                	je     80109131 <strcmp+0x22>
80109123:	8b 45 08             	mov    0x8(%ebp),%eax
80109126:	8a 10                	mov    (%eax),%dl
80109128:	8b 45 0c             	mov    0xc(%ebp),%eax
8010912b:	8a 00                	mov    (%eax),%al
8010912d:	38 c2                	cmp    %al,%dl
8010912f:	74 e3                	je     80109114 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80109131:	8b 45 08             	mov    0x8(%ebp),%eax
80109134:	8a 00                	mov    (%eax),%al
80109136:	0f b6 d0             	movzbl %al,%edx
80109139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010913c:	8a 00                	mov    (%eax),%al
8010913e:	0f b6 c0             	movzbl %al,%eax
80109141:	29 c2                	sub    %eax,%edx
80109143:	89 d0                	mov    %edx,%eax
}
80109145:	5d                   	pop    %ebp
80109146:	c3                   	ret    

80109147 <set_root_inode>:

// struct con

void set_root_inode(char* name){
80109147:	55                   	push   %ebp
80109148:	89 e5                	mov    %esp,%ebp
8010914a:	53                   	push   %ebx
8010914b:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
8010914e:	8b 45 08             	mov    0x8(%ebp),%eax
80109151:	89 04 24             	mov    %eax,(%esp)
80109154:	e8 02 01 00 00       	call   8010925b <find>
80109159:	89 c3                	mov    %eax,%ebx
8010915b:	8b 45 08             	mov    0x8(%ebp),%eax
8010915e:	89 04 24             	mov    %eax,(%esp)
80109161:	e8 f2 95 ff ff       	call   80102758 <namei>
80109166:	89 c2                	mov    %eax,%edx
80109168:	89 d8                	mov    %ebx,%eax
8010916a:	01 c0                	add    %eax,%eax
8010916c:	01 d8                	add    %ebx,%eax
8010916e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80109175:	01 c8                	add    %ecx,%eax
80109177:	c1 e0 02             	shl    $0x2,%eax
8010917a:	05 30 8c 11 80       	add    $0x80118c30,%eax
8010917f:	89 50 08             	mov    %edx,0x8(%eax)

}
80109182:	83 c4 14             	add    $0x14,%esp
80109185:	5b                   	pop    %ebx
80109186:	5d                   	pop    %ebp
80109187:	c3                   	ret    

80109188 <get_name>:

void get_name(int vc_num, char* name){
80109188:	55                   	push   %ebp
80109189:	89 e5                	mov    %esp,%ebp
8010918b:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
8010918e:	8b 55 08             	mov    0x8(%ebp),%edx
80109191:	89 d0                	mov    %edx,%eax
80109193:	01 c0                	add    %eax,%eax
80109195:	01 d0                	add    %edx,%eax
80109197:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010919e:	01 d0                	add    %edx,%eax
801091a0:	c1 e0 02             	shl    $0x2,%eax
801091a3:	83 c0 10             	add    $0x10,%eax
801091a6:	05 00 8c 11 80       	add    $0x80118c00,%eax
801091ab:	83 c0 08             	add    $0x8,%eax
801091ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
801091b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
801091b8:	eb 03                	jmp    801091bd <get_name+0x35>
	{
		i++;
801091ba:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
801091bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c3:	01 d0                	add    %edx,%eax
801091c5:	8a 00                	mov    (%eax),%al
801091c7:	84 c0                	test   %al,%al
801091c9:	75 ef                	jne    801091ba <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
801091cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801091d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801091d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801091dc:	89 04 24             	mov    %eax,(%esp)
801091df:	e8 dc fe ff ff       	call   801090c0 <memcpy2>
}
801091e4:	c9                   	leave  
801091e5:	c3                   	ret    

801091e6 <g_name>:

char* g_name(int vc_bun){
801091e6:	55                   	push   %ebp
801091e7:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
801091e9:	8b 55 08             	mov    0x8(%ebp),%edx
801091ec:	89 d0                	mov    %edx,%eax
801091ee:	01 c0                	add    %eax,%eax
801091f0:	01 d0                	add    %edx,%eax
801091f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091f9:	01 d0                	add    %edx,%eax
801091fb:	c1 e0 02             	shl    $0x2,%eax
801091fe:	83 c0 10             	add    $0x10,%eax
80109201:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109206:	83 c0 08             	add    $0x8,%eax
}
80109209:	5d                   	pop    %ebp
8010920a:	c3                   	ret    

8010920b <is_full>:

int is_full(){
8010920b:	55                   	push   %ebp
8010920c:	89 e5                	mov    %esp,%ebp
8010920e:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109211:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109218:	eb 34                	jmp    8010924e <is_full+0x43>
		if(strlen(containers[i].name) == 0){
8010921a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010921d:	89 d0                	mov    %edx,%eax
8010921f:	01 c0                	add    %eax,%eax
80109221:	01 d0                	add    %edx,%eax
80109223:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010922a:	01 d0                	add    %edx,%eax
8010922c:	c1 e0 02             	shl    $0x2,%eax
8010922f:	83 c0 10             	add    $0x10,%eax
80109232:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109237:	83 c0 08             	add    $0x8,%eax
8010923a:	89 04 24             	mov    %eax,(%esp)
8010923d:	e8 af c7 ff ff       	call   801059f1 <strlen>
80109242:	85 c0                	test   %eax,%eax
80109244:	75 05                	jne    8010924b <is_full+0x40>
			return i;
80109246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109249:	eb 0e                	jmp    80109259 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010924b:	ff 45 f4             	incl   -0xc(%ebp)
8010924e:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109252:	7e c6                	jle    8010921a <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109259:	c9                   	leave  
8010925a:	c3                   	ret    

8010925b <find>:

int find(char* name){
8010925b:	55                   	push   %ebp
8010925c:	89 e5                	mov    %esp,%ebp
8010925e:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109261:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109268:	eb 54                	jmp    801092be <find+0x63>
		if(strcmp(name, "") == 0){
8010926a:	c7 44 24 04 18 a2 10 	movl   $0x8010a218,0x4(%esp)
80109271:	80 
80109272:	8b 45 08             	mov    0x8(%ebp),%eax
80109275:	89 04 24             	mov    %eax,(%esp)
80109278:	e8 92 fe ff ff       	call   8010910f <strcmp>
8010927d:	85 c0                	test   %eax,%eax
8010927f:	75 02                	jne    80109283 <find+0x28>
			continue;
80109281:	eb 38                	jmp    801092bb <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80109283:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109286:	89 d0                	mov    %edx,%eax
80109288:	01 c0                	add    %eax,%eax
8010928a:	01 d0                	add    %edx,%eax
8010928c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109293:	01 d0                	add    %edx,%eax
80109295:	c1 e0 02             	shl    $0x2,%eax
80109298:	83 c0 10             	add    $0x10,%eax
8010929b:	05 00 8c 11 80       	add    $0x80118c00,%eax
801092a0:	83 c0 08             	add    $0x8,%eax
801092a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801092a7:	8b 45 08             	mov    0x8(%ebp),%eax
801092aa:	89 04 24             	mov    %eax,(%esp)
801092ad:	e8 5d fe ff ff       	call   8010910f <strcmp>
801092b2:	85 c0                	test   %eax,%eax
801092b4:	75 05                	jne    801092bb <find+0x60>
			return i;
801092b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801092b9:	eb 0e                	jmp    801092c9 <find+0x6e>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801092bb:	ff 45 fc             	incl   -0x4(%ebp)
801092be:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801092c2:	7e a6                	jle    8010926a <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
801092c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801092c9:	c9                   	leave  
801092ca:	c3                   	ret    

801092cb <get_max_proc>:

int get_max_proc(int vc_num){
801092cb:	55                   	push   %ebp
801092cc:	89 e5                	mov    %esp,%ebp
801092ce:	57                   	push   %edi
801092cf:	56                   	push   %esi
801092d0:	53                   	push   %ebx
801092d1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801092d4:	8b 55 08             	mov    0x8(%ebp),%edx
801092d7:	89 d0                	mov    %edx,%eax
801092d9:	01 c0                	add    %eax,%eax
801092db:	01 d0                	add    %edx,%eax
801092dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092e4:	01 d0                	add    %edx,%eax
801092e6:	c1 e0 02             	shl    $0x2,%eax
801092e9:	05 00 8c 11 80       	add    $0x80118c00,%eax
801092ee:	8d 55 b8             	lea    -0x48(%ebp),%edx
801092f1:	89 c3                	mov    %eax,%ebx
801092f3:	b8 0f 00 00 00       	mov    $0xf,%eax
801092f8:	89 d7                	mov    %edx,%edi
801092fa:	89 de                	mov    %ebx,%esi
801092fc:	89 c1                	mov    %eax,%ecx
801092fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80109300:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80109303:	83 c4 40             	add    $0x40,%esp
80109306:	5b                   	pop    %ebx
80109307:	5e                   	pop    %esi
80109308:	5f                   	pop    %edi
80109309:	5d                   	pop    %ebp
8010930a:	c3                   	ret    

8010930b <get_container>:

struct container* get_container(int vc_num){
8010930b:	55                   	push   %ebp
8010930c:	89 e5                	mov    %esp,%ebp
8010930e:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80109311:	8b 55 08             	mov    0x8(%ebp),%edx
80109314:	89 d0                	mov    %edx,%eax
80109316:	01 c0                	add    %eax,%eax
80109318:	01 d0                	add    %edx,%eax
8010931a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109321:	01 d0                	add    %edx,%eax
80109323:	c1 e0 02             	shl    $0x2,%eax
80109326:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010932b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
8010932e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109331:	c9                   	leave  
80109332:	c3                   	ret    

80109333 <get_max_mem>:

int get_max_mem(int vc_num){
80109333:	55                   	push   %ebp
80109334:	89 e5                	mov    %esp,%ebp
80109336:	57                   	push   %edi
80109337:	56                   	push   %esi
80109338:	53                   	push   %ebx
80109339:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010933c:	8b 55 08             	mov    0x8(%ebp),%edx
8010933f:	89 d0                	mov    %edx,%eax
80109341:	01 c0                	add    %eax,%eax
80109343:	01 d0                	add    %edx,%eax
80109345:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010934c:	01 d0                	add    %edx,%eax
8010934e:	c1 e0 02             	shl    $0x2,%eax
80109351:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109356:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109359:	89 c3                	mov    %eax,%ebx
8010935b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109360:	89 d7                	mov    %edx,%edi
80109362:	89 de                	mov    %ebx,%esi
80109364:	89 c1                	mov    %eax,%ecx
80109366:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80109368:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
8010936b:	83 c4 40             	add    $0x40,%esp
8010936e:	5b                   	pop    %ebx
8010936f:	5e                   	pop    %esi
80109370:	5f                   	pop    %edi
80109371:	5d                   	pop    %ebp
80109372:	c3                   	ret    

80109373 <get_max_disk>:

int get_max_disk(int vc_num){
80109373:	55                   	push   %ebp
80109374:	89 e5                	mov    %esp,%ebp
80109376:	57                   	push   %edi
80109377:	56                   	push   %esi
80109378:	53                   	push   %ebx
80109379:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010937c:	8b 55 08             	mov    0x8(%ebp),%edx
8010937f:	89 d0                	mov    %edx,%eax
80109381:	01 c0                	add    %eax,%eax
80109383:	01 d0                	add    %edx,%eax
80109385:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010938c:	01 d0                	add    %edx,%eax
8010938e:	c1 e0 02             	shl    $0x2,%eax
80109391:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109396:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109399:	89 c3                	mov    %eax,%ebx
8010939b:	b8 0f 00 00 00       	mov    $0xf,%eax
801093a0:	89 d7                	mov    %edx,%edi
801093a2:	89 de                	mov    %ebx,%esi
801093a4:	89 c1                	mov    %eax,%ecx
801093a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
801093a8:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
801093ab:	83 c4 40             	add    $0x40,%esp
801093ae:	5b                   	pop    %ebx
801093af:	5e                   	pop    %esi
801093b0:	5f                   	pop    %edi
801093b1:	5d                   	pop    %ebp
801093b2:	c3                   	ret    

801093b3 <get_curr_proc>:

int get_curr_proc(int vc_num){
801093b3:	55                   	push   %ebp
801093b4:	89 e5                	mov    %esp,%ebp
801093b6:	57                   	push   %edi
801093b7:	56                   	push   %esi
801093b8:	53                   	push   %ebx
801093b9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801093bc:	8b 55 08             	mov    0x8(%ebp),%edx
801093bf:	89 d0                	mov    %edx,%eax
801093c1:	01 c0                	add    %eax,%eax
801093c3:	01 d0                	add    %edx,%eax
801093c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093cc:	01 d0                	add    %edx,%eax
801093ce:	c1 e0 02             	shl    $0x2,%eax
801093d1:	05 00 8c 11 80       	add    $0x80118c00,%eax
801093d6:	8d 55 b8             	lea    -0x48(%ebp),%edx
801093d9:	89 c3                	mov    %eax,%ebx
801093db:	b8 0f 00 00 00       	mov    $0xf,%eax
801093e0:	89 d7                	mov    %edx,%edi
801093e2:	89 de                	mov    %ebx,%esi
801093e4:	89 c1                	mov    %eax,%ecx
801093e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
801093e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801093eb:	83 c4 40             	add    $0x40,%esp
801093ee:	5b                   	pop    %ebx
801093ef:	5e                   	pop    %esi
801093f0:	5f                   	pop    %edi
801093f1:	5d                   	pop    %ebp
801093f2:	c3                   	ret    

801093f3 <get_curr_mem>:

int get_curr_mem(int vc_num){
801093f3:	55                   	push   %ebp
801093f4:	89 e5                	mov    %esp,%ebp
801093f6:	57                   	push   %edi
801093f7:	56                   	push   %esi
801093f8:	53                   	push   %ebx
801093f9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801093fc:	8b 55 08             	mov    0x8(%ebp),%edx
801093ff:	89 d0                	mov    %edx,%eax
80109401:	01 c0                	add    %eax,%eax
80109403:	01 d0                	add    %edx,%eax
80109405:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010940c:	01 d0                	add    %edx,%eax
8010940e:	c1 e0 02             	shl    $0x2,%eax
80109411:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109416:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109419:	89 c3                	mov    %eax,%ebx
8010941b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109420:	89 d7                	mov    %edx,%edi
80109422:	89 de                	mov    %ebx,%esi
80109424:	89 c1                	mov    %eax,%ecx
80109426:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
80109428:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
8010942b:	83 c4 40             	add    $0x40,%esp
8010942e:	5b                   	pop    %ebx
8010942f:	5e                   	pop    %esi
80109430:	5f                   	pop    %edi
80109431:	5d                   	pop    %ebp
80109432:	c3                   	ret    

80109433 <get_curr_disk>:

int get_curr_disk(int vc_num){
80109433:	55                   	push   %ebp
80109434:	89 e5                	mov    %esp,%ebp
80109436:	57                   	push   %edi
80109437:	56                   	push   %esi
80109438:	53                   	push   %ebx
80109439:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010943c:	8b 55 08             	mov    0x8(%ebp),%edx
8010943f:	89 d0                	mov    %edx,%eax
80109441:	01 c0                	add    %eax,%eax
80109443:	01 d0                	add    %edx,%eax
80109445:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010944c:	01 d0                	add    %edx,%eax
8010944e:	c1 e0 02             	shl    $0x2,%eax
80109451:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109456:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109459:	89 c3                	mov    %eax,%ebx
8010945b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109460:	89 d7                	mov    %edx,%edi
80109462:	89 de                	mov    %ebx,%esi
80109464:	89 c1                	mov    %eax,%ecx
80109466:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80109468:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
8010946b:	83 c4 40             	add    $0x40,%esp
8010946e:	5b                   	pop    %ebx
8010946f:	5e                   	pop    %esi
80109470:	5f                   	pop    %edi
80109471:	5d                   	pop    %ebp
80109472:	c3                   	ret    

80109473 <set_name>:

void set_name(char* name, int vc_num){
80109473:	55                   	push   %ebp
80109474:	89 e5                	mov    %esp,%ebp
80109476:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109479:	8b 55 0c             	mov    0xc(%ebp),%edx
8010947c:	89 d0                	mov    %edx,%eax
8010947e:	01 c0                	add    %eax,%eax
80109480:	01 d0                	add    %edx,%eax
80109482:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109489:	01 d0                	add    %edx,%eax
8010948b:	c1 e0 02             	shl    $0x2,%eax
8010948e:	83 c0 10             	add    $0x10,%eax
80109491:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109496:	8d 50 08             	lea    0x8(%eax),%edx
80109499:	8b 45 08             	mov    0x8(%ebp),%eax
8010949c:	89 44 24 04          	mov    %eax,0x4(%esp)
801094a0:	89 14 24             	mov    %edx,(%esp)
801094a3:	e8 39 fc ff ff       	call   801090e1 <strcpy>
}
801094a8:	c9                   	leave  
801094a9:	c3                   	ret    

801094aa <set_max_mem>:

void set_max_mem(int mem, int vc_num){
801094aa:	55                   	push   %ebp
801094ab:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
801094ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801094b0:	89 d0                	mov    %edx,%eax
801094b2:	01 c0                	add    %eax,%eax
801094b4:	01 d0                	add    %edx,%eax
801094b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094bd:	01 d0                	add    %edx,%eax
801094bf:	c1 e0 02             	shl    $0x2,%eax
801094c2:	8d 90 00 8c 11 80    	lea    -0x7fee7400(%eax),%edx
801094c8:	8b 45 08             	mov    0x8(%ebp),%eax
801094cb:	89 02                	mov    %eax,(%edx)
}
801094cd:	5d                   	pop    %ebp
801094ce:	c3                   	ret    

801094cf <set_max_disk>:

void set_max_disk(int disk, int vc_num){
801094cf:	55                   	push   %ebp
801094d0:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
801094d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801094d5:	89 d0                	mov    %edx,%eax
801094d7:	01 c0                	add    %eax,%eax
801094d9:	01 d0                	add    %edx,%eax
801094db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094e2:	01 d0                	add    %edx,%eax
801094e4:	c1 e0 02             	shl    $0x2,%eax
801094e7:	8d 90 00 8c 11 80    	lea    -0x7fee7400(%eax),%edx
801094ed:	8b 45 08             	mov    0x8(%ebp),%eax
801094f0:	89 42 08             	mov    %eax,0x8(%edx)
}
801094f3:	5d                   	pop    %ebp
801094f4:	c3                   	ret    

801094f5 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
801094f5:	55                   	push   %ebp
801094f6:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
801094f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801094fb:	89 d0                	mov    %edx,%eax
801094fd:	01 c0                	add    %eax,%eax
801094ff:	01 d0                	add    %edx,%eax
80109501:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109508:	01 d0                	add    %edx,%eax
8010950a:	c1 e0 02             	shl    $0x2,%eax
8010950d:	8d 90 00 8c 11 80    	lea    -0x7fee7400(%eax),%edx
80109513:	8b 45 08             	mov    0x8(%ebp),%eax
80109516:	89 42 04             	mov    %eax,0x4(%edx)
}
80109519:	5d                   	pop    %ebp
8010951a:	c3                   	ret    

8010951b <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010951b:	55                   	push   %ebp
8010951c:	89 e5                	mov    %esp,%ebp
8010951e:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
80109521:	8b 55 0c             	mov    0xc(%ebp),%edx
80109524:	89 d0                	mov    %edx,%eax
80109526:	01 c0                	add    %eax,%eax
80109528:	01 d0                	add    %edx,%eax
8010952a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109531:	01 d0                	add    %edx,%eax
80109533:	c1 e0 02             	shl    $0x2,%eax
80109536:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010953b:	8b 40 0c             	mov    0xc(%eax),%eax
8010953e:	8d 48 01             	lea    0x1(%eax),%ecx
80109541:	8b 55 0c             	mov    0xc(%ebp),%edx
80109544:	89 d0                	mov    %edx,%eax
80109546:	01 c0                	add    %eax,%eax
80109548:	01 d0                	add    %edx,%eax
8010954a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109551:	01 d0                	add    %edx,%eax
80109553:	c1 e0 02             	shl    $0x2,%eax
80109556:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010955b:	8b 00                	mov    (%eax),%eax
8010955d:	39 c1                	cmp    %eax,%ecx
8010955f:	7e 0e                	jle    8010956f <set_curr_mem+0x54>
		cprintf("Exceded memory resource; killing container");
80109561:	c7 04 24 1c a2 10 80 	movl   $0x8010a21c,(%esp)
80109568:	e8 54 6e ff ff       	call   801003c1 <cprintf>
8010956d:	eb 3d                	jmp    801095ac <set_curr_mem+0x91>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
8010956f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109572:	89 d0                	mov    %edx,%eax
80109574:	01 c0                	add    %eax,%eax
80109576:	01 d0                	add    %edx,%eax
80109578:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010957f:	01 d0                	add    %edx,%eax
80109581:	c1 e0 02             	shl    $0x2,%eax
80109584:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109589:	8b 40 0c             	mov    0xc(%eax),%eax
8010958c:	8d 48 01             	lea    0x1(%eax),%ecx
8010958f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109592:	89 d0                	mov    %edx,%eax
80109594:	01 c0                	add    %eax,%eax
80109596:	01 d0                	add    %edx,%eax
80109598:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010959f:	01 d0                	add    %edx,%eax
801095a1:	c1 e0 02             	shl    $0x2,%eax
801095a4:	05 00 8c 11 80       	add    $0x80118c00,%eax
801095a9:	89 48 0c             	mov    %ecx,0xc(%eax)
	}
}
801095ac:	c9                   	leave  
801095ad:	c3                   	ret    

801095ae <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
801095ae:	55                   	push   %ebp
801095af:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
801095b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801095b4:	89 d0                	mov    %edx,%eax
801095b6:	01 c0                	add    %eax,%eax
801095b8:	01 d0                	add    %edx,%eax
801095ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095c1:	01 d0                	add    %edx,%eax
801095c3:	c1 e0 02             	shl    $0x2,%eax
801095c6:	05 00 8c 11 80       	add    $0x80118c00,%eax
801095cb:	8b 40 0c             	mov    0xc(%eax),%eax
801095ce:	8d 48 ff             	lea    -0x1(%eax),%ecx
801095d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801095d4:	89 d0                	mov    %edx,%eax
801095d6:	01 c0                	add    %eax,%eax
801095d8:	01 d0                	add    %edx,%eax
801095da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095e1:	01 d0                	add    %edx,%eax
801095e3:	c1 e0 02             	shl    $0x2,%eax
801095e6:	05 00 8c 11 80       	add    $0x80118c00,%eax
801095eb:	89 48 0c             	mov    %ecx,0xc(%eax)
}
801095ee:	5d                   	pop    %ebp
801095ef:	c3                   	ret    

801095f0 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
801095f0:	55                   	push   %ebp
801095f1:	89 e5                	mov    %esp,%ebp
801095f3:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
801095f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801095f9:	89 d0                	mov    %edx,%eax
801095fb:	01 c0                	add    %eax,%eax
801095fd:	01 d0                	add    %edx,%eax
801095ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109606:	01 d0                	add    %edx,%eax
80109608:	c1 e0 02             	shl    $0x2,%eax
8010960b:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109610:	8b 50 04             	mov    0x4(%eax),%edx
80109613:	8b 45 08             	mov    0x8(%ebp),%eax
80109616:	01 d0                	add    %edx,%eax
80109618:	85 c0                	test   %eax,%eax
8010961a:	79 05                	jns    80109621 <set_curr_disk+0x31>
8010961c:	05 ff 03 00 00       	add    $0x3ff,%eax
80109621:	c1 f8 0a             	sar    $0xa,%eax
80109624:	89 c1                	mov    %eax,%ecx
80109626:	8b 55 0c             	mov    0xc(%ebp),%edx
80109629:	89 d0                	mov    %edx,%eax
8010962b:	01 c0                	add    %eax,%eax
8010962d:	01 d0                	add    %edx,%eax
8010962f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109636:	01 d0                	add    %edx,%eax
80109638:	c1 e0 02             	shl    $0x2,%eax
8010963b:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109640:	8b 40 08             	mov    0x8(%eax),%eax
80109643:	39 c1                	cmp    %eax,%ecx
80109645:	7e 0e                	jle    80109655 <set_curr_disk+0x65>
		cprintf("Exceded disk resource; killing container");
80109647:	c7 04 24 48 a2 10 80 	movl   $0x8010a248,(%esp)
8010964e:	e8 6e 6d ff ff       	call   801003c1 <cprintf>
80109653:	eb 40                	jmp    80109695 <set_curr_disk+0xa5>
	}
	else{
		containers[vc_num].curr_disk += disk;
80109655:	8b 55 0c             	mov    0xc(%ebp),%edx
80109658:	89 d0                	mov    %edx,%eax
8010965a:	01 c0                	add    %eax,%eax
8010965c:	01 d0                	add    %edx,%eax
8010965e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109665:	01 d0                	add    %edx,%eax
80109667:	c1 e0 02             	shl    $0x2,%eax
8010966a:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010966f:	8b 50 04             	mov    0x4(%eax),%edx
80109672:	8b 45 08             	mov    0x8(%ebp),%eax
80109675:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109678:	8b 55 0c             	mov    0xc(%ebp),%edx
8010967b:	89 d0                	mov    %edx,%eax
8010967d:	01 c0                	add    %eax,%eax
8010967f:	01 d0                	add    %edx,%eax
80109681:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109688:	01 d0                	add    %edx,%eax
8010968a:	c1 e0 02             	shl    $0x2,%eax
8010968d:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109692:	89 48 04             	mov    %ecx,0x4(%eax)
	}
}
80109695:	c9                   	leave  
80109696:	c3                   	ret    

80109697 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80109697:	55                   	push   %ebp
80109698:	89 e5                	mov    %esp,%ebp
8010969a:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
8010969d:	8b 55 0c             	mov    0xc(%ebp),%edx
801096a0:	89 d0                	mov    %edx,%eax
801096a2:	01 c0                	add    %eax,%eax
801096a4:	01 d0                	add    %edx,%eax
801096a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096ad:	01 d0                	add    %edx,%eax
801096af:	c1 e0 02             	shl    $0x2,%eax
801096b2:	05 10 8c 11 80       	add    $0x80118c10,%eax
801096b7:	8b 10                	mov    (%eax),%edx
801096b9:	8b 45 08             	mov    0x8(%ebp),%eax
801096bc:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801096bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801096c2:	89 d0                	mov    %edx,%eax
801096c4:	01 c0                	add    %eax,%eax
801096c6:	01 d0                	add    %edx,%eax
801096c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096cf:	01 d0                	add    %edx,%eax
801096d1:	c1 e0 02             	shl    $0x2,%eax
801096d4:	05 00 8c 11 80       	add    $0x80118c00,%eax
801096d9:	8b 40 04             	mov    0x4(%eax),%eax
801096dc:	39 c1                	cmp    %eax,%ecx
801096de:	7e 0e                	jle    801096ee <set_curr_proc+0x57>
		cprintf("Exceded procs resource; killing container");
801096e0:	c7 04 24 74 a2 10 80 	movl   $0x8010a274,(%esp)
801096e7:	e8 d5 6c ff ff       	call   801003c1 <cprintf>
801096ec:	eb 3e                	jmp    8010972c <set_curr_proc+0x95>
	}
	else{
		containers[vc_num].curr_proc += procs;
801096ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801096f1:	89 d0                	mov    %edx,%eax
801096f3:	01 c0                	add    %eax,%eax
801096f5:	01 d0                	add    %edx,%eax
801096f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096fe:	01 d0                	add    %edx,%eax
80109700:	c1 e0 02             	shl    $0x2,%eax
80109703:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109708:	8b 10                	mov    (%eax),%edx
8010970a:	8b 45 08             	mov    0x8(%ebp),%eax
8010970d:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109710:	8b 55 0c             	mov    0xc(%ebp),%edx
80109713:	89 d0                	mov    %edx,%eax
80109715:	01 c0                	add    %eax,%eax
80109717:	01 d0                	add    %edx,%eax
80109719:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109720:	01 d0                	add    %edx,%eax
80109722:	c1 e0 02             	shl    $0x2,%eax
80109725:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010972a:	89 08                	mov    %ecx,(%eax)
	}
}
8010972c:	c9                   	leave  
8010972d:	c3                   	ret    

8010972e <max_containers>:

int max_containers(){
8010972e:	55                   	push   %ebp
8010972f:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
80109731:	b8 04 00 00 00       	mov    $0x4,%eax
}
80109736:	5d                   	pop    %ebp
80109737:	c3                   	ret    

80109738 <container_init>:

void container_init(){
80109738:	55                   	push   %ebp
80109739:	89 e5                	mov    %esp,%ebp
8010973b:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010973e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109745:	e9 f7 00 00 00       	jmp    80109841 <container_init+0x109>
		strcpy(containers[i].name, "");
8010974a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010974d:	89 d0                	mov    %edx,%eax
8010974f:	01 c0                	add    %eax,%eax
80109751:	01 d0                	add    %edx,%eax
80109753:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010975a:	01 d0                	add    %edx,%eax
8010975c:	c1 e0 02             	shl    $0x2,%eax
8010975f:	83 c0 10             	add    $0x10,%eax
80109762:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109767:	83 c0 08             	add    $0x8,%eax
8010976a:	c7 44 24 04 18 a2 10 	movl   $0x8010a218,0x4(%esp)
80109771:	80 
80109772:	89 04 24             	mov    %eax,(%esp)
80109775:	e8 67 f9 ff ff       	call   801090e1 <strcpy>
		containers[i].max_proc = 4;
8010977a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010977d:	89 d0                	mov    %edx,%eax
8010977f:	01 c0                	add    %eax,%eax
80109781:	01 d0                	add    %edx,%eax
80109783:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010978a:	01 d0                	add    %edx,%eax
8010978c:	c1 e0 02             	shl    $0x2,%eax
8010978f:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109794:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
8010979b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010979e:	89 d0                	mov    %edx,%eax
801097a0:	01 c0                	add    %eax,%eax
801097a2:	01 d0                	add    %edx,%eax
801097a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097ab:	01 d0                	add    %edx,%eax
801097ad:	c1 e0 02             	shl    $0x2,%eax
801097b0:	05 00 8c 11 80       	add    $0x80118c00,%eax
801097b5:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 300;
801097bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801097bf:	89 d0                	mov    %edx,%eax
801097c1:	01 c0                	add    %eax,%eax
801097c3:	01 d0                	add    %edx,%eax
801097c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097cc:	01 d0                	add    %edx,%eax
801097ce:	c1 e0 02             	shl    $0x2,%eax
801097d1:	05 00 8c 11 80       	add    $0x80118c00,%eax
801097d6:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
		containers[i].curr_proc = 1;
801097dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801097df:	89 d0                	mov    %edx,%eax
801097e1:	01 c0                	add    %eax,%eax
801097e3:	01 d0                	add    %edx,%eax
801097e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097ec:	01 d0                	add    %edx,%eax
801097ee:	c1 e0 02             	shl    $0x2,%eax
801097f1:	05 10 8c 11 80       	add    $0x80118c10,%eax
801097f6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
801097fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801097ff:	89 d0                	mov    %edx,%eax
80109801:	01 c0                	add    %eax,%eax
80109803:	01 d0                	add    %edx,%eax
80109805:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010980c:	01 d0                	add    %edx,%eax
8010980e:	c1 e0 02             	shl    $0x2,%eax
80109811:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109816:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
8010981d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109820:	89 d0                	mov    %edx,%eax
80109822:	01 c0                	add    %eax,%eax
80109824:	01 d0                	add    %edx,%eax
80109826:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010982d:	01 d0                	add    %edx,%eax
8010982f:	c1 e0 02             	shl    $0x2,%eax
80109832:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109837:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010983e:	ff 45 fc             	incl   -0x4(%ebp)
80109841:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109845:	0f 8e ff fe ff ff    	jle    8010974a <container_init+0x12>
		containers[i].max_mem = 300;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
8010984b:	c9                   	leave  
8010984c:	c3                   	ret    

8010984d <container_reset>:

void container_reset(int vc_num){
8010984d:	55                   	push   %ebp
8010984e:	89 e5                	mov    %esp,%ebp
80109850:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
80109853:	8b 55 08             	mov    0x8(%ebp),%edx
80109856:	89 d0                	mov    %edx,%eax
80109858:	01 c0                	add    %eax,%eax
8010985a:	01 d0                	add    %edx,%eax
8010985c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109863:	01 d0                	add    %edx,%eax
80109865:	c1 e0 02             	shl    $0x2,%eax
80109868:	83 c0 10             	add    $0x10,%eax
8010986b:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109870:	83 c0 08             	add    $0x8,%eax
80109873:	c7 44 24 04 18 a2 10 	movl   $0x8010a218,0x4(%esp)
8010987a:	80 
8010987b:	89 04 24             	mov    %eax,(%esp)
8010987e:	e8 5e f8 ff ff       	call   801090e1 <strcpy>
	containers[vc_num].max_proc = 4;
80109883:	8b 55 08             	mov    0x8(%ebp),%edx
80109886:	89 d0                	mov    %edx,%eax
80109888:	01 c0                	add    %eax,%eax
8010988a:	01 d0                	add    %edx,%eax
8010988c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109893:	01 d0                	add    %edx,%eax
80109895:	c1 e0 02             	shl    $0x2,%eax
80109898:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010989d:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
	containers[vc_num].max_disk = 100;
801098a4:	8b 55 08             	mov    0x8(%ebp),%edx
801098a7:	89 d0                	mov    %edx,%eax
801098a9:	01 c0                	add    %eax,%eax
801098ab:	01 d0                	add    %edx,%eax
801098ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098b4:	01 d0                	add    %edx,%eax
801098b6:	c1 e0 02             	shl    $0x2,%eax
801098b9:	05 00 8c 11 80       	add    $0x80118c00,%eax
801098be:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 300;
801098c5:	8b 55 08             	mov    0x8(%ebp),%edx
801098c8:	89 d0                	mov    %edx,%eax
801098ca:	01 c0                	add    %eax,%eax
801098cc:	01 d0                	add    %edx,%eax
801098ce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098d5:	01 d0                	add    %edx,%eax
801098d7:	c1 e0 02             	shl    $0x2,%eax
801098da:	05 00 8c 11 80       	add    $0x80118c00,%eax
801098df:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
	containers[vc_num].curr_proc = 1;
801098e5:	8b 55 08             	mov    0x8(%ebp),%edx
801098e8:	89 d0                	mov    %edx,%eax
801098ea:	01 c0                	add    %eax,%eax
801098ec:	01 d0                	add    %edx,%eax
801098ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098f5:	01 d0                	add    %edx,%eax
801098f7:	c1 e0 02             	shl    $0x2,%eax
801098fa:	05 10 8c 11 80       	add    $0x80118c10,%eax
801098ff:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	containers[vc_num].curr_disk = 0;
80109905:	8b 55 08             	mov    0x8(%ebp),%edx
80109908:	89 d0                	mov    %edx,%eax
8010990a:	01 c0                	add    %eax,%eax
8010990c:	01 d0                	add    %edx,%eax
8010990e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109915:	01 d0                	add    %edx,%eax
80109917:	c1 e0 02             	shl    $0x2,%eax
8010991a:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010991f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
80109926:	8b 55 08             	mov    0x8(%ebp),%edx
80109929:	89 d0                	mov    %edx,%eax
8010992b:	01 c0                	add    %eax,%eax
8010992d:	01 d0                	add    %edx,%eax
8010992f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109936:	01 d0                	add    %edx,%eax
80109938:	c1 e0 02             	shl    $0x2,%eax
8010993b:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109940:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
80109947:	c9                   	leave  
80109948:	c3                   	ret    
