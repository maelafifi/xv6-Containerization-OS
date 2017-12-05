
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
80100028:	bc 50 e9 10 80       	mov    $0x8010e950,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b6 3b 10 80       	mov    $0x80103bb6,%eax
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
8010003a:	c7 44 24 04 e8 99 10 	movl   $0x801099e8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 e9 10 80 	movl   $0x8010e960,(%esp)
80100049:	e8 14 57 00 00       	call   80105762 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 ac 30 11 80 5c 	movl   $0x8011305c,0x801130ac
80100055:	30 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 b0 30 11 80 5c 	movl   $0x8011305c,0x801130b0
8010005f:	30 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 e9 10 80 	movl   $0x8010e994,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 b0 30 11 80    	mov    0x801130b0,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 5c 30 11 80 	movl   $0x8011305c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 ef 99 10 	movl   $0x801099ef,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 8d 55 00 00       	call   80105624 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 b0 30 11 80       	mov    0x801130b0,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 b0 30 11 80       	mov    %eax,0x801130b0

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 5c 30 11 80 	cmpl   $0x8011305c,-0xc(%ebp)
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
801000c2:	c7 04 24 60 e9 10 80 	movl   $0x8010e960,(%esp)
801000c9:	e8 b5 56 00 00       	call   80105783 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 b0 30 11 80       	mov    0x801130b0,%eax
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
801000fd:	c7 04 24 60 e9 10 80 	movl   $0x8010e960,(%esp)
80100104:	e8 e4 56 00 00       	call   801057ed <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 47 55 00 00       	call   8010565e <acquiresleep>
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
80100128:	81 7d f4 5c 30 11 80 	cmpl   $0x8011305c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 ac 30 11 80       	mov    0x801130ac,%eax
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
80100176:	c7 04 24 60 e9 10 80 	movl   $0x8010e960,(%esp)
8010017d:	e8 6b 56 00 00       	call   801057ed <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 ce 54 00 00       	call   8010565e <acquiresleep>
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
8010019e:	81 7d f4 5c 30 11 80 	cmpl   $0x8011305c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 f6 99 10 80 	movl   $0x801099f6,(%esp)
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
801001e2:	e8 d6 29 00 00       	call   80102bbd <iderw>
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
801001fb:	e8 fb 54 00 00       	call   801056fb <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 07 9a 10 80 	movl   $0x80109a07,(%esp)
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
80100225:	e8 93 29 00 00       	call   80102bbd <iderw>
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
8010023b:	e8 bb 54 00 00       	call   801056fb <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 0e 9a 10 80 	movl   $0x80109a0e,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 5b 54 00 00       	call   801056b9 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 60 e9 10 80 	movl   $0x8010e960,(%esp)
80100265:	e8 19 55 00 00       	call   80105783 <acquire>
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
801002a1:	8b 15 b0 30 11 80    	mov    0x801130b0,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 5c 30 11 80 	movl   $0x8011305c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 b0 30 11 80       	mov    0x801130b0,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 b0 30 11 80       	mov    %eax,0x801130b0
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 60 e9 10 80 	movl   $0x8010e960,(%esp)
801002d1:	e8 17 55 00 00       	call   801057ed <release>
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
801003c7:	a1 f4 d8 10 80       	mov    0x8010d8f4,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
801003dc:	e8 a2 53 00 00       	call   80105783 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 15 9a 10 80 	movl   $0x80109a15,(%esp)
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
801004cf:	c7 45 ec 1e 9a 10 80 	movl   $0x80109a1e,-0x14(%ebp)
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
80100546:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
8010054d:	e8 9b 52 00 00       	call   801057ed <release>
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
8010055f:	c7 05 f4 d8 10 80 00 	movl   $0x0,0x8010d8f4
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 1b 2e 00 00       	call   80103389 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 25 9a 10 80 	movl   $0x80109a25,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 39 9a 10 80 	movl   $0x80109a39,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 93 52 00 00       	call   8010583a <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 3b 9a 10 80 	movl   $0x80109a3b,(%esp)
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
801005d0:	c7 05 ac d8 10 80 01 	movl   $0x1,0x8010d8ac
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
80100695:	c7 04 24 3f 9a 10 80 	movl   $0x80109a3f,(%esp)
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
801006c9:	e8 e1 53 00 00       	call   80105aaf <memmove>
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
801006f8:	e8 e9 52 00 00       	call   801059e6 <memset>
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
8010076e:	a1 ac d8 10 80       	mov    0x8010d8ac,%eax
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
8010078e:	e8 51 73 00 00       	call   80107ae4 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 45 73 00 00       	call   80107ae4 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 39 73 00 00       	call   80107ae4 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 2c 73 00 00       	call   80107ae4 <uartputc>
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
8010080c:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100813:	e8 6b 4f 00 00       	call   80105783 <acquire>
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
80100875:	ba c0 32 11 80       	mov    $0x801132c0,%edx
8010087a:	bb 40 d6 10 80       	mov    $0x8010d640,%ebx
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
801008a3:	ba e0 d6 10 80       	mov    $0x8010d6e0,%edx
801008a8:	bb c0 32 11 80       	mov    $0x801132c0,%ebx
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
801008c4:	ba 80 d7 10 80       	mov    $0x8010d780,%edx
801008c9:	bb c0 32 11 80       	mov    $0x801132c0,%ebx
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
801008e5:	ba 20 d8 10 80       	mov    $0x8010d820,%edx
801008ea:	bb c0 32 11 80       	mov    $0x801132c0,%ebx
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
80100908:	a1 48 33 11 80       	mov    0x80113348,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 48 33 11 80       	mov    %eax,0x80113348
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
80100922:	8b 15 48 33 11 80    	mov    0x80113348,%edx
80100928:	a1 44 33 11 80       	mov    0x80113344,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 48 33 11 80       	mov    0x80113348,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 c0 32 11 80    	mov    -0x7feecd40(%eax),%al
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
80100949:	8b 15 48 33 11 80    	mov    0x80113348,%edx
8010094f:	a1 44 33 11 80       	mov    0x80113344,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 48 33 11 80       	mov    0x80113348,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 48 33 11 80       	mov    %eax,0x80113348
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
80100983:	8b 15 48 33 11 80    	mov    0x80113348,%edx
80100989:	a1 40 33 11 80       	mov    0x80113340,%eax
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
801009aa:	a1 48 33 11 80       	mov    0x80113348,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 48 33 11 80    	mov    %edx,0x80113348
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 c0 32 11 80    	mov    %al,-0x7feecd40(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 48 33 11 80       	mov    0x80113348,%eax
801009e2:	8b 15 40 33 11 80    	mov    0x80113340,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 48 33 11 80       	mov    0x80113348,%eax
801009f4:	a3 44 33 11 80       	mov    %eax,0x80113344
          wakeup(&input.r);
801009f9:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80100a00:	e8 56 45 00 00       	call   80104f5b <wakeup>
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
80100a1a:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100a21:	e8 c7 4d 00 00       	call   801057ed <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 52 9a 10 80 	movl   $0x80109a52,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 28 46 00 00       	call   80105065 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 6a 9a 10 80 	movl   $0x80109a6a,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 84 9a 10 80 	movl   $0x80109a84,(%esp)
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
80100a78:	e8 b4 11 00 00       	call   80101c31 <iunlock>
  target = n;
80100a7d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a83:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100a8a:	e8 f4 4c 00 00       	call   80105783 <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 38 3b 00 00       	call   801045d3 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100aa9:	e8 3f 4d 00 00       	call   801057ed <release>
        ilock(ip);
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 6e 10 00 00       	call   80101b27 <ilock>
        return -1;
80100ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100abe:	e9 b3 00 00 00       	jmp    80100b76 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100ac3:	c7 44 24 04 c0 d8 10 	movl   $0x8010d8c0,0x4(%esp)
80100aca:	80 
80100acb:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80100ad2:	e8 ad 43 00 00       	call   80104e84 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100ad7:	8b 15 40 33 11 80    	mov    0x80113340,%edx
80100add:	a1 44 33 11 80       	mov    0x80113344,%eax
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
80100af8:	a1 40 33 11 80       	mov    0x80113340,%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 15 40 33 11 80    	mov    %edx,0x80113340
80100b06:	83 e0 7f             	and    $0x7f,%eax
80100b09:	8a 80 c0 32 11 80    	mov    -0x7feecd40(%eax),%al
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
80100b23:	a1 40 33 11 80       	mov    0x80113340,%eax
80100b28:	48                   	dec    %eax
80100b29:	a3 40 33 11 80       	mov    %eax,0x80113340
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
80100b55:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100b5c:	e8 8c 4c 00 00       	call   801057ed <release>
  ilock(ip);
80100b61:	8b 45 08             	mov    0x8(%ebp),%eax
80100b64:	89 04 24             	mov    %eax,(%esp)
80100b67:	e8 bb 0f 00 00       	call   80101b27 <ilock>

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
80100b96:	e8 96 10 00 00       	call   80101c31 <iunlock>
    acquire(&cons.lock);
80100b9b:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100ba2:	e8 dc 4b 00 00       	call   80105783 <acquire>
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
80100bd3:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100bda:	e8 0e 4c 00 00       	call   801057ed <release>
    ilock(ip);
80100bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80100be2:	89 04 24             	mov    %eax,(%esp)
80100be5:	e8 3d 0f 00 00       	call   80101b27 <ilock>
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
80100bf5:	c7 44 24 04 9d 9a 10 	movl   $0x80109a9d,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 c0 d8 10 80 	movl   $0x8010d8c0,(%esp)
80100c04:	e8 59 4b 00 00       	call   80105762 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c09:	c7 05 ac 3e 11 80 78 	movl   $0x80100b78,0x80113eac
80100c10:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c13:	c7 05 a8 3e 11 80 6c 	movl   $0x80100a6c,0x80113ea8
80100c1a:	0a 10 80 
  cons.locking = 1;
80100c1d:	c7 05 f4 d8 10 80 01 	movl   $0x1,0x8010d8f4
80100c24:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c2e:	00 
80100c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c36:	e8 34 21 00 00       	call   80102d6f <ioapicenable>
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
80100c49:	e8 85 39 00 00       	call   801045d3 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 7d 2c 00 00       	call   801038d3 <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 6e 1b 00 00       	call   801027cf <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 e6 2c 00 00       	call   80103955 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 a5 9a 10 80 	movl   $0x80109aa5,(%esp)
80100c76:	e8 46 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c80:	e9 f6 03 00 00       	jmp    8010107b <exec+0x43b>
  }
  ilock(ip);
80100c85:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c88:	89 04 24             	mov    %eax,(%esp)
80100c8b:	e8 97 0e 00 00       	call   80101b27 <ilock>
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
80100cb7:	e8 02 13 00 00       	call   80101fbe <readi>
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
80100cd8:	e8 e9 7d 00 00       	call   80108ac6 <setupkvm>
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
80100d26:	e8 93 12 00 00       	call   80101fbe <readi>
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
80100d96:	e8 f7 80 00 00       	call   80108e92 <allocuvm>
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
80100de8:	e8 c2 7f 00 00       	call   80108daf <loaduvm>
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
80100e1a:	e8 07 0f 00 00       	call   80101d26 <iunlockput>
  end_op();
80100e1f:	e8 31 2b 00 00       	call   80103955 <end_op>
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
80100e54:	e8 39 80 00 00       	call   80108e92 <allocuvm>
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
80100e79:	e8 84 82 00 00       	call   80109102 <clearpteu>
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
80100eaf:	e8 85 4d 00 00       	call   80105c39 <strlen>
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
80100ed6:	e8 5e 4d 00 00       	call   80105c39 <strlen>
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
80100f04:	e8 b1 83 00 00       	call   801092ba <copyout>
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
80100fa8:	e8 0d 83 00 00       	call   801092ba <copyout>
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
80100ff8:	e8 f5 4b 00 00       	call   80105bf2 <safestrcpy>

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
80101038:	e8 63 7b 00 00       	call   80108ba0 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 24 80 00 00       	call   8010906c <freevm>
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
8010105b:	e8 0c 80 00 00       	call   8010906c <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 b5 0c 00 00       	call   80101d26 <iunlockput>
    end_op();
80101071:	e8 df 28 00 00       	call   80103955 <end_op>
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
801010ec:	c7 44 24 04 b1 9a 10 	movl   $0x80109ab1,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
801010fb:	e8 62 46 00 00       	call   80105762 <initlock>
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
80101108:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
8010110f:	e8 6f 46 00 00       	call   80105783 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101114:	c7 45 f4 94 33 11 80 	movl   $0x80113394,-0xc(%ebp)
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
80101131:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
80101138:	e8 b0 46 00 00       	call   801057ed <release>
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 1e                	jmp    80101160 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
80101146:	81 7d f4 84 3e 11 80 	cmpl   $0x80113e84,-0xc(%ebp)
8010114d:	72 ce                	jb     8010111d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114f:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
80101156:	e8 92 46 00 00       	call   801057ed <release>
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
80101168:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
8010116f:	e8 0f 46 00 00       	call   80105783 <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 b8 9a 10 80 	movl   $0x80109ab8,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
801011a0:	e8 48 46 00 00       	call   801057ed <release>
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
801011b3:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
801011ba:	e8 c4 45 00 00       	call   80105783 <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 c0 9a 10 80 	movl   $0x80109ac0,(%esp)
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
801011ee:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
801011f5:	e8 f3 45 00 00       	call   801057ed <release>
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
80101224:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
8010122b:	e8 bd 45 00 00       	call   801057ed <release>

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
80101248:	e8 1e 30 00 00       	call   8010426b <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 77 26 00 00       	call   801038d3 <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 0e 0a 00 00       	call   80101c75 <iput>
    end_op();
80101267:	e8 e9 26 00 00       	call   80103955 <end_op>
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
8010128d:	e8 95 08 00 00       	call   80101b27 <ilock>
    stati(f->ip, st);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 d3 0c 00 00       	call   80101f7a <stati>
    iunlock(f->ip);
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	89 04 24             	mov    %eax,(%esp)
801012b0:	e8 7c 09 00 00       	call   80101c31 <iunlock>
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
801012fe:	e8 e6 30 00 00       	call   801043e9 <piperead>
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
80101318:	e8 0a 08 00 00       	call   80101b27 <ilock>
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
8010133e:	e8 7b 0c 00 00       	call   80101fbe <readi>
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
80101366:	e8 c6 08 00 00       	call   80101c31 <iunlock>
    return r;
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	eb 0c                	jmp    8010137c <fileread+0xb9>
  }
  panic("fileread");
80101370:	c7 04 24 ca 9a 10 80 	movl   $0x80109aca,(%esp)
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
801013ba:	e8 3e 2f 00 00       	call   801042fd <pipewrite>
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
80101400:	e8 ce 24 00 00       	call   801038d3 <begin_op>
      ilock(f->ip);
80101405:	8b 45 08             	mov    0x8(%ebp),%eax
80101408:	8b 40 10             	mov    0x10(%eax),%eax
8010140b:	89 04 24             	mov    %eax,(%esp)
8010140e:	e8 14 07 00 00       	call   80101b27 <ilock>
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
80101439:	e8 e4 0c 00 00       	call   80102122 <writei>
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
        // if(ticks > 0){
        //   struct superblock sb;
        //   readsb(1, &sb);
        // }
      }
      iunlock(f->ip);
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 40 10             	mov    0x10(%eax),%eax
8010145e:	89 04 24             	mov    %eax,(%esp)
80101461:	e8 cb 07 00 00       	call   80101c31 <iunlock>
      end_op();
80101466:	e8 ea 24 00 00       	call   80103955 <end_op>

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
8010147b:	c7 04 24 d3 9a 10 80 	movl   $0x80109ad3,(%esp)
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
801014ad:	c7 04 24 e3 9a 10 80 	movl   $0x80109ae3,(%esp)
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
801014e2:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
801014e9:	00 
801014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	89 04 24             	mov    %eax,(%esp)
801014f4:	e8 b6 45 00 00       	call   80105aaf <memmove>
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
8010153a:	e8 a7 44 00 00       	call   801059e6 <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 8d 25 00 00       	call   80103ad7 <log_write>
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
80101581:	a1 18 3f 11 80       	mov    0x80113f18,%eax
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
8010160d:	e8 c5 24 00 00       	call   80103ad7 <log_write>
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
80101654:	a1 00 3f 11 80       	mov    0x80113f00,%eax
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
80101676:	a1 00 3f 11 80       	mov    0x80113f00,%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 82 ed fe ff ff    	jb     80101570 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	c7 04 24 f0 9a 10 80 	movl   $0x80109af0,(%esp)
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
80101697:	c7 44 24 04 00 3f 11 	movl   $0x80113f00,0x4(%esp)
8010169e:	80 
8010169f:	8b 45 08             	mov    0x8(%ebp),%eax
801016a2:	89 04 24             	mov    %eax,(%esp)
801016a5:	e8 16 fe ff ff       	call   801014c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ad:	c1 e8 0c             	shr    $0xc,%eax
801016b0:	89 c2                	mov    %eax,%edx
801016b2:	a1 18 3f 11 80       	mov    0x80113f18,%eax
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
80101713:	c7 04 24 06 9b 10 80 	movl   $0x80109b06,(%esp)
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
80101749:	e8 89 23 00 00       	call   80103ad7 <log_write>
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
8010176b:	c7 44 24 04 19 9b 10 	movl   $0x80109b19,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
8010177a:	e8 e3 3f 00 00       	call   80105762 <initlock>
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
80101798:	05 40 3f 11 80       	add    $0x80113f40,%eax
8010179d:	83 c0 10             	add    $0x10,%eax
801017a0:	c7 44 24 04 20 9b 10 	movl   $0x80109b20,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 74 3e 00 00       	call   80105624 <initsleeplock>
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
801017b9:	c7 44 24 04 00 3f 11 	movl   $0x80113f00,0x4(%esp)
801017c0:	80 
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 f4 fc ff ff       	call   801014c0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 18 3f 11 80       	mov    0x80113f18,%eax
801017d1:	8b 3d 14 3f 11 80    	mov    0x80113f14,%edi
801017d7:	8b 35 10 3f 11 80    	mov    0x80113f10,%esi
801017dd:	8b 1d 0c 3f 11 80    	mov    0x80113f0c,%ebx
801017e3:	8b 0d 08 3f 11 80    	mov    0x80113f08,%ecx
801017e9:	8b 15 04 3f 11 80    	mov    0x80113f04,%edx
801017ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017f2:	8b 15 00 3f 11 80    	mov    0x80113f00,%edx
801017f8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017fc:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101800:	89 74 24 14          	mov    %esi,0x14(%esp)
80101804:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101808:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010180c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010180f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101813:	89 d0                	mov    %edx,%eax
80101815:	89 44 24 04          	mov    %eax,0x4(%esp)
80101819:	c7 04 24 28 9b 10 80 	movl   $0x80109b28,(%esp)
80101820:	e8 9c eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
  sb.size_avail = (sb.nblocks/2) * 1024;
80101825:	a1 04 3f 11 80       	mov    0x80113f04,%eax
8010182a:	d1 e8                	shr    %eax
8010182c:	c1 e0 0a             	shl    $0xa,%eax
8010182f:	a3 20 3f 11 80       	mov    %eax,0x80113f20
  sb.size_used = ((sb.size - sb.nblocks)/2) * 1024;
80101834:	8b 15 00 3f 11 80    	mov    0x80113f00,%edx
8010183a:	a1 04 3f 11 80       	mov    0x80113f04,%eax
8010183f:	29 c2                	sub    %eax,%edx
80101841:	89 d0                	mov    %edx,%eax
80101843:	d1 e8                	shr    %eax
80101845:	c1 e0 0a             	shl    $0xa,%eax
80101848:	a3 24 3f 11 80       	mov    %eax,0x80113f24

  cprintf("dev %d\n", dev);
8010184d:	8b 45 08             	mov    0x8(%ebp),%eax
80101850:	89 44 24 04          	mov    %eax,0x4(%esp)
80101854:	c7 04 24 7b 9b 10 80 	movl   $0x80109b7b,(%esp)
8010185b:	e8 61 eb ff ff       	call   801003c1 <cprintf>
  cprintf("avail %d\n", sb.size_avail);
80101860:	a1 20 3f 11 80       	mov    0x80113f20,%eax
80101865:	89 44 24 04          	mov    %eax,0x4(%esp)
80101869:	c7 04 24 83 9b 10 80 	movl   $0x80109b83,(%esp)
80101870:	e8 4c eb ff ff       	call   801003c1 <cprintf>
  cprintf("used %d\n", sb.size_used);
80101875:	a1 24 3f 11 80       	mov    0x80113f24,%eax
8010187a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010187e:	c7 04 24 8d 9b 10 80 	movl   $0x80109b8d,(%esp)
80101885:	e8 37 eb ff ff       	call   801003c1 <cprintf>
}
8010188a:	83 c4 4c             	add    $0x4c,%esp
8010188d:	5b                   	pop    %ebx
8010188e:	5e                   	pop    %esi
8010188f:	5f                   	pop    %edi
80101890:	5d                   	pop    %ebp
80101891:	c3                   	ret    

80101892 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101892:	55                   	push   %ebp
80101893:	89 e5                	mov    %esp,%ebp
80101895:	83 ec 28             	sub    $0x28,%esp
80101898:	8b 45 0c             	mov    0xc(%ebp),%eax
8010189b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010189f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018a6:	e9 9b 00 00 00       	jmp    80101946 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ae:	c1 e8 03             	shr    $0x3,%eax
801018b1:	89 c2                	mov    %eax,%edx
801018b3:	a1 14 3f 11 80       	mov    0x80113f14,%eax
801018b8:	01 d0                	add    %edx,%eax
801018ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801018be:	8b 45 08             	mov    0x8(%ebp),%eax
801018c1:	89 04 24             	mov    %eax,(%esp)
801018c4:	e8 ec e8 ff ff       	call   801001b5 <bread>
801018c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cf:	8d 50 5c             	lea    0x5c(%eax),%edx
801018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d5:	83 e0 07             	and    $0x7,%eax
801018d8:	c1 e0 06             	shl    $0x6,%eax
801018db:	01 d0                	add    %edx,%eax
801018dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018e3:	8b 00                	mov    (%eax),%eax
801018e5:	66 85 c0             	test   %ax,%ax
801018e8:	75 4e                	jne    80101938 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801018ea:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801018f1:	00 
801018f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801018f9:	00 
801018fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018fd:	89 04 24             	mov    %eax,(%esp)
80101900:	e8 e1 40 00 00       	call   801059e6 <memset>
      dip->type = type;
80101905:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101908:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010190b:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010190e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101911:	89 04 24             	mov    %eax,(%esp)
80101914:	e8 be 21 00 00       	call   80103ad7 <log_write>
      brelse(bp);
80101919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191c:	89 04 24             	mov    %eax,(%esp)
8010191f:	e8 08 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 44 24 04          	mov    %eax,0x4(%esp)
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	89 04 24             	mov    %eax,(%esp)
80101931:	e8 ea 00 00 00       	call   80101a20 <iget>
80101936:	eb 2a                	jmp    80101962 <ialloc+0xd0>
    }
    brelse(bp);
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	89 04 24             	mov    %eax,(%esp)
8010193e:	e8 e9 e8 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101943:	ff 45 f4             	incl   -0xc(%ebp)
80101946:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101949:	a1 08 3f 11 80       	mov    0x80113f08,%eax
8010194e:	39 c2                	cmp    %eax,%edx
80101950:	0f 82 55 ff ff ff    	jb     801018ab <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101956:	c7 04 24 96 9b 10 80 	movl   $0x80109b96,(%esp)
8010195d:	e8 f2 eb ff ff       	call   80100554 <panic>
}
80101962:	c9                   	leave  
80101963:	c3                   	ret    

80101964 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101964:	55                   	push   %ebp
80101965:	89 e5                	mov    %esp,%ebp
80101967:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 04             	mov    0x4(%eax),%eax
80101970:	c1 e8 03             	shr    $0x3,%eax
80101973:	89 c2                	mov    %eax,%edx
80101975:	a1 14 3f 11 80       	mov    0x80113f14,%eax
8010197a:	01 c2                	add    %eax,%edx
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	8b 00                	mov    (%eax),%eax
80101981:	89 54 24 04          	mov    %edx,0x4(%esp)
80101985:	89 04 24             	mov    %eax,(%esp)
80101988:	e8 28 e8 ff ff       	call   801001b5 <bread>
8010198d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101993:	8d 50 5c             	lea    0x5c(%eax),%edx
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	83 e0 07             	and    $0x7,%eax
8010199f:	c1 e0 06             	shl    $0x6,%eax
801019a2:	01 d0                	add    %edx,%eax
801019a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	8b 40 50             	mov    0x50(%eax),%eax
801019ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019b0:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	66 8b 40 52          	mov    0x52(%eax),%ax
801019ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019bd:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 54             	mov    0x54(%eax),%eax
801019c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019ca:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	66 8b 40 56          	mov    0x56(%eax),%ax
801019d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019d8:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801019dc:	8b 45 08             	mov    0x8(%ebp),%eax
801019df:	8b 50 58             	mov    0x58(%eax),%edx
801019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e5:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f1:	83 c0 0c             	add    $0xc,%eax
801019f4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019fb:	00 
801019fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a00:	89 04 24             	mov    %eax,(%esp)
80101a03:	e8 a7 40 00 00       	call   80105aaf <memmove>
  log_write(bp);
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	89 04 24             	mov    %eax,(%esp)
80101a0e:	e8 c4 20 00 00       	call   80103ad7 <log_write>
  brelse(bp);
80101a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a16:	89 04 24             	mov    %eax,(%esp)
80101a19:	e8 0e e8 ff ff       	call   8010022c <brelse>
}
80101a1e:	c9                   	leave  
80101a1f:	c3                   	ret    

80101a20 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a20:	55                   	push   %ebp
80101a21:	89 e5                	mov    %esp,%ebp
80101a23:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a26:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101a2d:	e8 51 3d 00 00       	call   80105783 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a39:	c7 45 f4 74 3f 11 80 	movl   $0x80113f74,-0xc(%ebp)
80101a40:	eb 5c                	jmp    80101a9e <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	8b 40 08             	mov    0x8(%eax),%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	7e 35                	jle    80101a81 <iget+0x61>
80101a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4f:	8b 00                	mov    (%eax),%eax
80101a51:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a54:	75 2b                	jne    80101a81 <iget+0x61>
80101a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a59:	8b 40 04             	mov    0x4(%eax),%eax
80101a5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a5f:	75 20                	jne    80101a81 <iget+0x61>
      ip->ref++;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	8b 40 08             	mov    0x8(%eax),%eax
80101a67:	8d 50 01             	lea    0x1(%eax),%edx
80101a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a70:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101a77:	e8 71 3d 00 00       	call   801057ed <release>
      return ip;
80101a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7f:	eb 72                	jmp    80101af3 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a85:	75 10                	jne    80101a97 <iget+0x77>
80101a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8a:	8b 40 08             	mov    0x8(%eax),%eax
80101a8d:	85 c0                	test   %eax,%eax
80101a8f:	75 06                	jne    80101a97 <iget+0x77>
      empty = ip;
80101a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a94:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a97:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a9e:	81 7d f4 94 5b 11 80 	cmpl   $0x80115b94,-0xc(%ebp)
80101aa5:	72 9b                	jb     80101a42 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101aa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aab:	75 0c                	jne    80101ab9 <iget+0x99>
    panic("iget: no inodes");
80101aad:	c7 04 24 a8 9b 10 80 	movl   $0x80109ba8,(%esp)
80101ab4:	e8 9b ea ff ff       	call   80100554 <panic>

  ip = empty;
80101ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80101ac5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aca:	8b 55 0c             	mov    0xc(%ebp),%edx
80101acd:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101add:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ae4:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101aeb:	e8 fd 3c 00 00       	call   801057ed <release>

  return ip;
80101af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101af3:	c9                   	leave  
80101af4:	c3                   	ret    

80101af5 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101af5:	55                   	push   %ebp
80101af6:	89 e5                	mov    %esp,%ebp
80101af8:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101afb:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101b02:	e8 7c 3c 00 00       	call   80105783 <acquire>
  ip->ref++;
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 08             	mov    0x8(%eax),%eax
80101b0d:	8d 50 01             	lea    0x1(%eax),%edx
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b16:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101b1d:	e8 cb 3c 00 00       	call   801057ed <release>
  return ip;
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b25:	c9                   	leave  
80101b26:	c3                   	ret    

80101b27 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b27:	55                   	push   %ebp
80101b28:	89 e5                	mov    %esp,%ebp
80101b2a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b2d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b31:	74 0a                	je     80101b3d <ilock+0x16>
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	8b 40 08             	mov    0x8(%eax),%eax
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	7f 0c                	jg     80101b49 <ilock+0x22>
    panic("ilock");
80101b3d:	c7 04 24 b8 9b 10 80 	movl   $0x80109bb8,(%esp)
80101b44:	e8 0b ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	83 c0 0c             	add    $0xc,%eax
80101b4f:	89 04 24             	mov    %eax,(%esp)
80101b52:	e8 07 3b 00 00       	call   8010565e <acquiresleep>

  if(ip->valid == 0){
80101b57:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5d:	85 c0                	test   %eax,%eax
80101b5f:	0f 85 ca 00 00 00    	jne    80101c2f <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 40 04             	mov    0x4(%eax),%eax
80101b6b:	c1 e8 03             	shr    $0x3,%eax
80101b6e:	89 c2                	mov    %eax,%edx
80101b70:	a1 14 3f 11 80       	mov    0x80113f14,%eax
80101b75:	01 c2                	add    %eax,%edx
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	8b 00                	mov    (%eax),%eax
80101b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b80:	89 04 24             	mov    %eax,(%esp)
80101b83:	e8 2d e6 ff ff       	call   801001b5 <bread>
80101b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 04             	mov    0x4(%eax),%eax
80101b97:	83 e0 07             	and    $0x7,%eax
80101b9a:	c1 e0 06             	shl    $0x6,%eax
80101b9d:	01 d0                	add    %edx,%eax
80101b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	8b 00                	mov    (%eax),%eax
80101ba7:	8b 55 08             	mov    0x8(%ebp),%edx
80101baa:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb1:	66 8b 40 02          	mov    0x2(%eax),%ax
80101bb5:	8b 55 08             	mov    0x8(%ebp),%edx
80101bb8:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bbf:	8b 40 04             	mov    0x4(%eax),%eax
80101bc2:	8b 55 08             	mov    0x8(%ebp),%edx
80101bc5:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcc:	66 8b 40 06          	mov    0x6(%eax),%ax
80101bd0:	8b 55 08             	mov    0x8(%ebp),%edx
80101bd3:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bda:	8b 50 08             	mov    0x8(%eax),%edx
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be6:	8d 50 0c             	lea    0xc(%eax),%edx
80101be9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bec:	83 c0 5c             	add    $0x5c,%eax
80101bef:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101bf6:	00 
80101bf7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bfb:	89 04 24             	mov    %eax,(%esp)
80101bfe:	e8 ac 3e 00 00       	call   80105aaf <memmove>
    brelse(bp);
80101c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 1e e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c18:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1b:	8b 40 50             	mov    0x50(%eax),%eax
80101c1e:	66 85 c0             	test   %ax,%ax
80101c21:	75 0c                	jne    80101c2f <ilock+0x108>
      panic("ilock: no type");
80101c23:	c7 04 24 be 9b 10 80 	movl   $0x80109bbe,(%esp)
80101c2a:	e8 25 e9 ff ff       	call   80100554 <panic>
  }
}
80101c2f:	c9                   	leave  
80101c30:	c3                   	ret    

80101c31 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c31:	55                   	push   %ebp
80101c32:	89 e5                	mov    %esp,%ebp
80101c34:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c3b:	74 1c                	je     80101c59 <iunlock+0x28>
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	83 c0 0c             	add    $0xc,%eax
80101c43:	89 04 24             	mov    %eax,(%esp)
80101c46:	e8 b0 3a 00 00       	call   801056fb <holdingsleep>
80101c4b:	85 c0                	test   %eax,%eax
80101c4d:	74 0a                	je     80101c59 <iunlock+0x28>
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 08             	mov    0x8(%eax),%eax
80101c55:	85 c0                	test   %eax,%eax
80101c57:	7f 0c                	jg     80101c65 <iunlock+0x34>
    panic("iunlock");
80101c59:	c7 04 24 cd 9b 10 80 	movl   $0x80109bcd,(%esp)
80101c60:	e8 ef e8 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c65:	8b 45 08             	mov    0x8(%ebp),%eax
80101c68:	83 c0 0c             	add    $0xc,%eax
80101c6b:	89 04 24             	mov    %eax,(%esp)
80101c6e:	e8 46 3a 00 00       	call   801056b9 <releasesleep>
}
80101c73:	c9                   	leave  
80101c74:	c3                   	ret    

80101c75 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c75:	55                   	push   %ebp
80101c76:	89 e5                	mov    %esp,%ebp
80101c78:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	83 c0 0c             	add    $0xc,%eax
80101c81:	89 04 24             	mov    %eax,(%esp)
80101c84:	e8 d5 39 00 00       	call   8010565e <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c8f:	85 c0                	test   %eax,%eax
80101c91:	74 5c                	je     80101cef <iput+0x7a>
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c9a:	66 85 c0             	test   %ax,%ax
80101c9d:	75 50                	jne    80101cef <iput+0x7a>
    acquire(&icache.lock);
80101c9f:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101ca6:	e8 d8 3a 00 00       	call   80105783 <acquire>
    int r = ip->ref;
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	8b 40 08             	mov    0x8(%eax),%eax
80101cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cb4:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101cbb:	e8 2d 3b 00 00       	call   801057ed <release>
    if(r == 1){
80101cc0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cc4:	75 29                	jne    80101cef <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc9:	89 04 24             	mov    %eax,(%esp)
80101ccc:	e8 86 01 00 00       	call   80101e57 <itrunc>
      ip->type = 0;
80101cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd4:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cda:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdd:	89 04 24             	mov    %eax,(%esp)
80101ce0:	e8 7f fc ff ff       	call   80101964 <iupdate>
      ip->valid = 0;
80101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	83 c0 0c             	add    $0xc,%eax
80101cf5:	89 04 24             	mov    %eax,(%esp)
80101cf8:	e8 bc 39 00 00       	call   801056b9 <releasesleep>

  acquire(&icache.lock);
80101cfd:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101d04:	e8 7a 3a 00 00       	call   80105783 <acquire>
  ip->ref--;
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 40 08             	mov    0x8(%eax),%eax
80101d0f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d18:	c7 04 24 40 3f 11 80 	movl   $0x80113f40,(%esp)
80101d1f:	e8 c9 3a 00 00       	call   801057ed <release>
}
80101d24:	c9                   	leave  
80101d25:	c3                   	ret    

80101d26 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d26:	55                   	push   %ebp
80101d27:	89 e5                	mov    %esp,%ebp
80101d29:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	89 04 24             	mov    %eax,(%esp)
80101d32:	e8 fa fe ff ff       	call   80101c31 <iunlock>
  iput(ip);
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	89 04 24             	mov    %eax,(%esp)
80101d3d:	e8 33 ff ff ff       	call   80101c75 <iput>
}
80101d42:	c9                   	leave  
80101d43:	c3                   	ret    

80101d44 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d44:	55                   	push   %ebp
80101d45:	89 e5                	mov    %esp,%ebp
80101d47:	53                   	push   %ebx
80101d48:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d4b:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d4f:	77 3e                	ja     80101d8f <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101d51:	8b 45 08             	mov    0x8(%ebp),%eax
80101d54:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d57:	83 c2 14             	add    $0x14,%edx
80101d5a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d65:	75 20                	jne    80101d87 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d67:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6a:	8b 00                	mov    (%eax),%eax
80101d6c:	89 04 24             	mov    %eax,(%esp)
80101d6f:	e8 e3 f7 ff ff       	call   80101557 <balloc>
80101d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d7d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d8a:	e9 c2 00 00 00       	jmp    80101e51 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d8f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d93:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d97:	0f 87 a8 00 00 00    	ja     80101e45 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101da0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dad:	75 1c                	jne    80101dcb <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101daf:	8b 45 08             	mov    0x8(%ebp),%eax
80101db2:	8b 00                	mov    (%eax),%eax
80101db4:	89 04 24             	mov    %eax,(%esp)
80101db7:	e8 9b f7 ff ff       	call   80101557 <balloc>
80101dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc5:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 00                	mov    (%eax),%eax
80101dd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dd7:	89 04 24             	mov    %eax,(%esp)
80101dda:	e8 d6 e3 ff ff       	call   801001b5 <bread>
80101ddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de5:	83 c0 5c             	add    $0x5c,%eax
80101de8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df8:	01 d0                	add    %edx,%eax
80101dfa:	8b 00                	mov    (%eax),%eax
80101dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e03:	75 30                	jne    80101e35 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e12:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101e15:	8b 45 08             	mov    0x8(%ebp),%eax
80101e18:	8b 00                	mov    (%eax),%eax
80101e1a:	89 04 24             	mov    %eax,(%esp)
80101e1d:	e8 35 f7 ff ff       	call   80101557 <balloc>
80101e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e28:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2d:	89 04 24             	mov    %eax,(%esp)
80101e30:	e8 a2 1c 00 00       	call   80103ad7 <log_write>
    }
    brelse(bp);
80101e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e38:	89 04 24             	mov    %eax,(%esp)
80101e3b:	e8 ec e3 ff ff       	call   8010022c <brelse>
    return addr;
80101e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e43:	eb 0c                	jmp    80101e51 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101e45:	c7 04 24 d5 9b 10 80 	movl   $0x80109bd5,(%esp)
80101e4c:	e8 03 e7 ff ff       	call   80100554 <panic>
}
80101e51:	83 c4 24             	add    $0x24,%esp
80101e54:	5b                   	pop    %ebx
80101e55:	5d                   	pop    %ebp
80101e56:	c3                   	ret    

80101e57 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e57:	55                   	push   %ebp
80101e58:	89 e5                	mov    %esp,%ebp
80101e5a:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e64:	eb 43                	jmp    80101ea9 <itrunc+0x52>
    if(ip->addrs[i]){
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6c:	83 c2 14             	add    $0x14,%edx
80101e6f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e73:	85 c0                	test   %eax,%eax
80101e75:	74 2f                	je     80101ea6 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e7d:	83 c2 14             	add    $0x14,%edx
80101e80:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 00                	mov    (%eax),%eax
80101e89:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e8d:	89 04 24             	mov    %eax,(%esp)
80101e90:	e8 fc f7 ff ff       	call   80101691 <bfree>
      ip->addrs[i] = 0;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9b:	83 c2 14             	add    $0x14,%edx
80101e9e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ea5:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ea6:	ff 45 f4             	incl   -0xc(%ebp)
80101ea9:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ead:	7e b7                	jle    80101e66 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eb8:	85 c0                	test   %eax,%eax
80101eba:	0f 84 a3 00 00 00    	je     80101f63 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec3:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 00                	mov    (%eax),%eax
80101ece:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed2:	89 04 24             	mov    %eax,(%esp)
80101ed5:	e8 db e2 ff ff       	call   801001b5 <bread>
80101eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee0:	83 c0 5c             	add    $0x5c,%eax
80101ee3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ee6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eed:	eb 3a                	jmp    80101f29 <itrunc+0xd2>
      if(a[j])
80101eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101efc:	01 d0                	add    %edx,%eax
80101efe:	8b 00                	mov    (%eax),%eax
80101f00:	85 c0                	test   %eax,%eax
80101f02:	74 22                	je     80101f26 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f11:	01 d0                	add    %edx,%eax
80101f13:	8b 10                	mov    (%eax),%edx
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 00                	mov    (%eax),%eax
80101f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f1e:	89 04 24             	mov    %eax,(%esp)
80101f21:	e8 6b f7 ff ff       	call   80101691 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101f26:	ff 45 f0             	incl   -0x10(%ebp)
80101f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f2c:	83 f8 7f             	cmp    $0x7f,%eax
80101f2f:	76 be                	jbe    80101eef <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f34:	89 04 24             	mov    %eax,(%esp)
80101f37:	e8 f0 e2 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 00                	mov    (%eax),%eax
80101f4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f4e:	89 04 24             	mov    %eax,(%esp)
80101f51:	e8 3b f7 ff ff       	call   80101691 <bfree>
    ip->addrs[NDIRECT] = 0;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f60:	00 00 00 
  }

  ip->size = 0;
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f70:	89 04 24             	mov    %eax,(%esp)
80101f73:	e8 ec f9 ff ff       	call   80101964 <iupdate>
}
80101f78:	c9                   	leave  
80101f79:	c3                   	ret    

80101f7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f7a:	55                   	push   %ebp
80101f7b:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 00                	mov    (%eax),%eax
80101f82:	89 c2                	mov    %eax,%edx
80101f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f87:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8d:	8b 50 04             	mov    0x4(%eax),%edx
80101f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f93:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f96:	8b 45 08             	mov    0x8(%ebp),%eax
80101f99:	8b 40 50             	mov    0x50(%eax),%eax
80101f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f9f:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	66 8b 40 56          	mov    0x56(%eax),%ax
80101fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fac:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	8b 50 58             	mov    0x58(%eax),%edx
80101fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb9:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fbc:	5d                   	pop    %ebp
80101fbd:	c3                   	ret    

80101fbe <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fbe:	55                   	push   %ebp
80101fbf:	89 e5                	mov    %esp,%ebp
80101fc1:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	8b 40 50             	mov    0x50(%eax),%eax
80101fca:	66 83 f8 03          	cmp    $0x3,%ax
80101fce:	75 60                	jne    80102030 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd3:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fd7:	66 85 c0             	test   %ax,%ax
80101fda:	78 20                	js     80101ffc <readi+0x3e>
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fe3:	66 83 f8 09          	cmp    $0x9,%ax
80101fe7:	7f 13                	jg     80101ffc <readi+0x3e>
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ff0:	98                   	cwtl   
80101ff1:	8b 04 c5 a0 3e 11 80 	mov    -0x7feec160(,%eax,8),%eax
80101ff8:	85 c0                	test   %eax,%eax
80101ffa:	75 0a                	jne    80102006 <readi+0x48>
      return -1;
80101ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102001:	e9 1a 01 00 00       	jmp    80102120 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	66 8b 40 52          	mov    0x52(%eax),%ax
8010200d:	98                   	cwtl   
8010200e:	8b 04 c5 a0 3e 11 80 	mov    -0x7feec160(,%eax,8),%eax
80102015:	8b 55 14             	mov    0x14(%ebp),%edx
80102018:	89 54 24 08          	mov    %edx,0x8(%esp)
8010201c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010201f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102023:	8b 55 08             	mov    0x8(%ebp),%edx
80102026:	89 14 24             	mov    %edx,(%esp)
80102029:	ff d0                	call   *%eax
8010202b:	e9 f0 00 00 00       	jmp    80102120 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80102030:	8b 45 08             	mov    0x8(%ebp),%eax
80102033:	8b 40 58             	mov    0x58(%eax),%eax
80102036:	3b 45 10             	cmp    0x10(%ebp),%eax
80102039:	72 0d                	jb     80102048 <readi+0x8a>
8010203b:	8b 45 14             	mov    0x14(%ebp),%eax
8010203e:	8b 55 10             	mov    0x10(%ebp),%edx
80102041:	01 d0                	add    %edx,%eax
80102043:	3b 45 10             	cmp    0x10(%ebp),%eax
80102046:	73 0a                	jae    80102052 <readi+0x94>
    return -1;
80102048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010204d:	e9 ce 00 00 00       	jmp    80102120 <readi+0x162>
  if(off + n > ip->size)
80102052:	8b 45 14             	mov    0x14(%ebp),%eax
80102055:	8b 55 10             	mov    0x10(%ebp),%edx
80102058:	01 c2                	add    %eax,%edx
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	8b 40 58             	mov    0x58(%eax),%eax
80102060:	39 c2                	cmp    %eax,%edx
80102062:	76 0c                	jbe    80102070 <readi+0xb2>
    n = ip->size - off;
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	8b 40 58             	mov    0x58(%eax),%eax
8010206a:	2b 45 10             	sub    0x10(%ebp),%eax
8010206d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102070:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102077:	e9 95 00 00 00       	jmp    80102111 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010207c:	8b 45 10             	mov    0x10(%ebp),%eax
8010207f:	c1 e8 09             	shr    $0x9,%eax
80102082:	89 44 24 04          	mov    %eax,0x4(%esp)
80102086:	8b 45 08             	mov    0x8(%ebp),%eax
80102089:	89 04 24             	mov    %eax,(%esp)
8010208c:	e8 b3 fc ff ff       	call   80101d44 <bmap>
80102091:	8b 55 08             	mov    0x8(%ebp),%edx
80102094:	8b 12                	mov    (%edx),%edx
80102096:	89 44 24 04          	mov    %eax,0x4(%esp)
8010209a:	89 14 24             	mov    %edx,(%esp)
8010209d:	e8 13 e1 ff ff       	call   801001b5 <bread>
801020a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020a5:	8b 45 10             	mov    0x10(%ebp),%eax
801020a8:	25 ff 01 00 00       	and    $0x1ff,%eax
801020ad:	89 c2                	mov    %eax,%edx
801020af:	b8 00 02 00 00       	mov    $0x200,%eax
801020b4:	29 d0                	sub    %edx,%eax
801020b6:	89 c1                	mov    %eax,%ecx
801020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bb:	8b 55 14             	mov    0x14(%ebp),%edx
801020be:	29 c2                	sub    %eax,%edx
801020c0:	89 c8                	mov    %ecx,%eax
801020c2:	39 d0                	cmp    %edx,%eax
801020c4:	76 02                	jbe    801020c8 <readi+0x10a>
801020c6:	89 d0                	mov    %edx,%eax
801020c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020cb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d3:	8d 50 50             	lea    0x50(%eax),%edx
801020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d9:	01 d0                	add    %edx,%eax
801020db:	8d 50 0c             	lea    0xc(%eax),%edx
801020de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e1:	89 44 24 08          	mov    %eax,0x8(%esp)
801020e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801020e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ec:	89 04 24             	mov    %eax,(%esp)
801020ef:	e8 bb 39 00 00       	call   80105aaf <memmove>
    brelse(bp);
801020f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020f7:	89 04 24             	mov    %eax,(%esp)
801020fa:	e8 2d e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102102:	01 45 f4             	add    %eax,-0xc(%ebp)
80102105:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102108:	01 45 10             	add    %eax,0x10(%ebp)
8010210b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010210e:	01 45 0c             	add    %eax,0xc(%ebp)
80102111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102114:	3b 45 14             	cmp    0x14(%ebp),%eax
80102117:	0f 82 5f ff ff ff    	jb     8010207c <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010211d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102120:	c9                   	leave  
80102121:	c3                   	ret    

80102122 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102122:	55                   	push   %ebp
80102123:	89 e5                	mov    %esp,%ebp
80102125:	83 ec 38             	sub    $0x38,%esp
  uint tot, m;
  struct buf *bp;
  struct container* cont = myproc()->cont;
80102128:	e8 a6 24 00 00       	call   801045d3 <myproc>
8010212d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102133:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
80102136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102139:	83 c0 1c             	add    $0x1c,%eax
8010213c:	89 04 24             	mov    %eax,(%esp)
8010213f:	e8 d9 73 00 00       	call   8010951d <find>
80102144:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if(ip->type == T_DEV){
80102147:	8b 45 08             	mov    0x8(%ebp),%eax
8010214a:	8b 40 50             	mov    0x50(%eax),%eax
8010214d:	66 83 f8 03          	cmp    $0x3,%ax
80102151:	75 60                	jne    801021b3 <writei+0x91>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write){
80102153:	8b 45 08             	mov    0x8(%ebp),%eax
80102156:	66 8b 40 52          	mov    0x52(%eax),%ax
8010215a:	66 85 c0             	test   %ax,%ax
8010215d:	78 20                	js     8010217f <writei+0x5d>
8010215f:	8b 45 08             	mov    0x8(%ebp),%eax
80102162:	66 8b 40 52          	mov    0x52(%eax),%ax
80102166:	66 83 f8 09          	cmp    $0x9,%ax
8010216a:	7f 13                	jg     8010217f <writei+0x5d>
8010216c:	8b 45 08             	mov    0x8(%ebp),%eax
8010216f:	66 8b 40 52          	mov    0x52(%eax),%ax
80102173:	98                   	cwtl   
80102174:	8b 04 c5 a4 3e 11 80 	mov    -0x7feec15c(,%eax,8),%eax
8010217b:	85 c0                	test   %eax,%eax
8010217d:	75 0a                	jne    80102189 <writei+0x67>
      return -1;
8010217f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102184:	e9 a1 01 00 00       	jmp    8010232a <writei+0x208>
    }
    return devsw[ip->major].write(ip, src, n);
80102189:	8b 45 08             	mov    0x8(%ebp),%eax
8010218c:	66 8b 40 52          	mov    0x52(%eax),%ax
80102190:	98                   	cwtl   
80102191:	8b 04 c5 a4 3e 11 80 	mov    -0x7feec15c(,%eax,8),%eax
80102198:	8b 55 14             	mov    0x14(%ebp),%edx
8010219b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010219f:	8b 55 0c             	mov    0xc(%ebp),%edx
801021a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a6:	8b 55 08             	mov    0x8(%ebp),%edx
801021a9:	89 14 24             	mov    %edx,(%esp)
801021ac:	ff d0                	call   *%eax
801021ae:	e9 77 01 00 00       	jmp    8010232a <writei+0x208>
  }


  if(off > ip->size || off + n < off){
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	8b 40 58             	mov    0x58(%eax),%eax
801021b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801021bc:	72 0d                	jb     801021cb <writei+0xa9>
801021be:	8b 45 14             	mov    0x14(%ebp),%eax
801021c1:	8b 55 10             	mov    0x10(%ebp),%edx
801021c4:	01 d0                	add    %edx,%eax
801021c6:	3b 45 10             	cmp    0x10(%ebp),%eax
801021c9:	73 0a                	jae    801021d5 <writei+0xb3>
    return -1;
801021cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021d0:	e9 55 01 00 00       	jmp    8010232a <writei+0x208>
  }
  if(off + n > MAXFILE*BSIZE){
801021d5:	8b 45 14             	mov    0x14(%ebp),%eax
801021d8:	8b 55 10             	mov    0x10(%ebp),%edx
801021db:	01 d0                	add    %edx,%eax
801021dd:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021e2:	76 0a                	jbe    801021ee <writei+0xcc>
    return -1;
801021e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021e9:	e9 3c 01 00 00       	jmp    8010232a <writei+0x208>
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f5:	e9 a0 00 00 00       	jmp    8010229a <writei+0x178>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021fa:	8b 45 10             	mov    0x10(%ebp),%eax
801021fd:	c1 e8 09             	shr    $0x9,%eax
80102200:	89 44 24 04          	mov    %eax,0x4(%esp)
80102204:	8b 45 08             	mov    0x8(%ebp),%eax
80102207:	89 04 24             	mov    %eax,(%esp)
8010220a:	e8 35 fb ff ff       	call   80101d44 <bmap>
8010220f:	8b 55 08             	mov    0x8(%ebp),%edx
80102212:	8b 12                	mov    (%edx),%edx
80102214:	89 44 24 04          	mov    %eax,0x4(%esp)
80102218:	89 14 24             	mov    %edx,(%esp)
8010221b:	e8 95 df ff ff       	call   801001b5 <bread>
80102220:	89 45 e8             	mov    %eax,-0x18(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102223:	8b 45 10             	mov    0x10(%ebp),%eax
80102226:	25 ff 01 00 00       	and    $0x1ff,%eax
8010222b:	89 c2                	mov    %eax,%edx
8010222d:	b8 00 02 00 00       	mov    $0x200,%eax
80102232:	29 d0                	sub    %edx,%eax
80102234:	89 c1                	mov    %eax,%ecx
80102236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102239:	8b 55 14             	mov    0x14(%ebp),%edx
8010223c:	29 c2                	sub    %eax,%edx
8010223e:	89 c8                	mov    %ecx,%eax
80102240:	39 d0                	cmp    %edx,%eax
80102242:	76 02                	jbe    80102246 <writei+0x124>
80102244:	89 d0                	mov    %edx,%eax
80102246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102251:	8d 50 50             	lea    0x50(%eax),%edx
80102254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102257:	01 d0                	add    %edx,%eax
80102259:	8d 50 0c             	lea    0xc(%eax),%edx
8010225c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010225f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102263:	8b 45 0c             	mov    0xc(%ebp),%eax
80102266:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226a:	89 14 24             	mov    %edx,(%esp)
8010226d:	e8 3d 38 00 00       	call   80105aaf <memmove>
    log_write(bp);
80102272:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102275:	89 04 24             	mov    %eax,(%esp)
80102278:	e8 5a 18 00 00       	call   80103ad7 <log_write>
    brelse(bp);
8010227d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102280:	89 04 24             	mov    %eax,(%esp)
80102283:	e8 a4 df ff ff       	call   8010022c <brelse>
  }
  if(off + n > MAXFILE*BSIZE){
    return -1;
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010228b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010228e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102291:	01 45 10             	add    %eax,0x10(%ebp)
80102294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102297:	01 45 0c             	add    %eax,0xc(%ebp)
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	3b 45 14             	cmp    0x14(%ebp),%eax
801022a0:	0f 82 54 ff ff ff    	jb     801021fa <writei+0xd8>
  }


  // void set_curr_disk(int disk, int vc_num){

  if(x >= 0){
801022a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801022aa:	78 56                	js     80102302 <writei+0x1e0>
    if(tot>0){
801022ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022b0:	74 50                	je     80102302 <writei+0x1e0>
      int before = get_curr_disk(x);
801022b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b5:	89 04 24             	mov    %eax,(%esp)
801022b8:	e8 f8 73 00 00       	call   801096b5 <get_curr_disk>
801022bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
      set_curr_disk(tot, x);
801022c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801022c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801022ca:	89 04 24             	mov    %eax,(%esp)
801022cd:	e8 08 75 00 00       	call   801097da <set_curr_disk>
      int after = get_curr_disk(x);
801022d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022d5:	89 04 24             	mov    %eax,(%esp)
801022d8:	e8 d8 73 00 00       	call   801096b5 <get_curr_disk>
801022dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(before == after){
801022e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022e3:	3b 45 dc             	cmp    -0x24(%ebp),%eax
801022e6:	75 1a                	jne    80102302 <writei+0x1e0>
        cstop_container_helper(myproc()->cont);
801022e8:	e8 e6 22 00 00       	call   801045d3 <myproc>
801022ed:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801022f3:	89 04 24             	mov    %eax,(%esp)
801022f6:	e8 c2 2e 00 00       	call   801051bd <cstop_container_helper>
        return -1;
801022fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102300:	eb 28                	jmp    8010232a <writei+0x208>
      }
    }
  }
  if(n > 0 && off > ip->size){
80102302:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102306:	74 1f                	je     80102327 <writei+0x205>
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	8b 40 58             	mov    0x58(%eax),%eax
8010230e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102311:	73 14                	jae    80102327 <writei+0x205>
    ip->size = off;
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 55 10             	mov    0x10(%ebp),%edx
80102319:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010231c:	8b 45 08             	mov    0x8(%ebp),%eax
8010231f:	89 04 24             	mov    %eax,(%esp)
80102322:	e8 3d f6 ff ff       	call   80101964 <iupdate>
  }
  return n;
80102327:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010232a:	c9                   	leave  
8010232b:	c3                   	ret    

8010232c <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010232c:	55                   	push   %ebp
8010232d:	89 e5                	mov    %esp,%ebp
8010232f:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102332:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102339:	00 
8010233a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010233d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102341:	8b 45 08             	mov    0x8(%ebp),%eax
80102344:	89 04 24             	mov    %eax,(%esp)
80102347:	e8 02 38 00 00       	call   80105b4e <strncmp>
}
8010234c:	c9                   	leave  
8010234d:	c3                   	ret    

8010234e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010234e:	55                   	push   %ebp
8010234f:	89 e5                	mov    %esp,%ebp
80102351:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102354:	8b 45 08             	mov    0x8(%ebp),%eax
80102357:	8b 40 50             	mov    0x50(%eax),%eax
8010235a:	66 83 f8 01          	cmp    $0x1,%ax
8010235e:	74 0c                	je     8010236c <dirlookup+0x1e>
    panic("dirlookup not DIR");
80102360:	c7 04 24 e8 9b 10 80 	movl   $0x80109be8,(%esp)
80102367:	e8 e8 e1 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010236c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102373:	e9 86 00 00 00       	jmp    801023fe <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102378:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010237f:	00 
80102380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102383:	89 44 24 08          	mov    %eax,0x8(%esp)
80102387:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010238e:	8b 45 08             	mov    0x8(%ebp),%eax
80102391:	89 04 24             	mov    %eax,(%esp)
80102394:	e8 25 fc ff ff       	call   80101fbe <readi>
80102399:	83 f8 10             	cmp    $0x10,%eax
8010239c:	74 0c                	je     801023aa <dirlookup+0x5c>
      panic("dirlookup read");
8010239e:	c7 04 24 fa 9b 10 80 	movl   $0x80109bfa,(%esp)
801023a5:	e8 aa e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801023aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023ad:	66 85 c0             	test   %ax,%ax
801023b0:	75 02                	jne    801023b4 <dirlookup+0x66>
      continue;
801023b2:	eb 46                	jmp    801023fa <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801023b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023b7:	83 c0 02             	add    $0x2,%eax
801023ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801023be:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c1:	89 04 24             	mov    %eax,(%esp)
801023c4:	e8 63 ff ff ff       	call   8010232c <namecmp>
801023c9:	85 c0                	test   %eax,%eax
801023cb:	75 2d                	jne    801023fa <dirlookup+0xac>
      // entry matches path element
      if(poff)
801023cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023d1:	74 08                	je     801023db <dirlookup+0x8d>
        *poff = off;
801023d3:	8b 45 10             	mov    0x10(%ebp),%eax
801023d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023d9:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023de:	0f b7 c0             	movzwl %ax,%eax
801023e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023e4:	8b 45 08             	mov    0x8(%ebp),%eax
801023e7:	8b 00                	mov    (%eax),%eax
801023e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801023f0:	89 04 24             	mov    %eax,(%esp)
801023f3:	e8 28 f6 ff ff       	call   80101a20 <iget>
801023f8:	eb 18                	jmp    80102412 <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801023fa:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102401:	8b 40 58             	mov    0x58(%eax),%eax
80102404:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102407:	0f 87 6b ff ff ff    	ja     80102378 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010240d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102412:	c9                   	leave  
80102413:	c3                   	ret    

80102414 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102414:	55                   	push   %ebp
80102415:	89 e5                	mov    %esp,%ebp
80102417:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010241a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102421:	00 
80102422:	8b 45 0c             	mov    0xc(%ebp),%eax
80102425:	89 44 24 04          	mov    %eax,0x4(%esp)
80102429:	8b 45 08             	mov    0x8(%ebp),%eax
8010242c:	89 04 24             	mov    %eax,(%esp)
8010242f:	e8 1a ff ff ff       	call   8010234e <dirlookup>
80102434:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102437:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010243b:	74 15                	je     80102452 <dirlink+0x3e>
    iput(ip);
8010243d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 2d f8 ff ff       	call   80101c75 <iput>
    return -1;
80102448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010244d:	e9 b6 00 00 00       	jmp    80102508 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102452:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102459:	eb 45                	jmp    801024a0 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102465:	00 
80102466:	89 44 24 08          	mov    %eax,0x8(%esp)
8010246a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010246d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102471:	8b 45 08             	mov    0x8(%ebp),%eax
80102474:	89 04 24             	mov    %eax,(%esp)
80102477:	e8 42 fb ff ff       	call   80101fbe <readi>
8010247c:	83 f8 10             	cmp    $0x10,%eax
8010247f:	74 0c                	je     8010248d <dirlink+0x79>
      panic("dirlink read");
80102481:	c7 04 24 09 9c 10 80 	movl   $0x80109c09,(%esp)
80102488:	e8 c7 e0 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
8010248d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102490:	66 85 c0             	test   %ax,%ax
80102493:	75 02                	jne    80102497 <dirlink+0x83>
      break;
80102495:	eb 16                	jmp    801024ad <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249a:	83 c0 10             	add    $0x10,%eax
8010249d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	8b 40 58             	mov    0x58(%eax),%eax
801024a9:	39 c2                	cmp    %eax,%edx
801024ab:	72 ae                	jb     8010245b <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801024ad:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024b4:	00 
801024b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801024bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024bf:	83 c0 02             	add    $0x2,%eax
801024c2:	89 04 24             	mov    %eax,(%esp)
801024c5:	e8 d2 36 00 00       	call   80105b9c <strncpy>
  de.inum = inum;
801024ca:	8b 45 10             	mov    0x10(%ebp),%eax
801024cd:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024db:	00 
801024dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801024e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ea:	89 04 24             	mov    %eax,(%esp)
801024ed:	e8 30 fc ff ff       	call   80102122 <writei>
801024f2:	83 f8 10             	cmp    $0x10,%eax
801024f5:	74 0c                	je     80102503 <dirlink+0xef>
    panic("dirlink");
801024f7:	c7 04 24 16 9c 10 80 	movl   $0x80109c16,(%esp)
801024fe:	e8 51 e0 ff ff       	call   80100554 <panic>

  return 0;
80102503:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102508:	c9                   	leave  
80102509:	c3                   	ret    

8010250a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010250a:	55                   	push   %ebp
8010250b:	89 e5                	mov    %esp,%ebp
8010250d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102510:	eb 03                	jmp    80102515 <skipelem+0xb>
    path++;
80102512:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102515:	8b 45 08             	mov    0x8(%ebp),%eax
80102518:	8a 00                	mov    (%eax),%al
8010251a:	3c 2f                	cmp    $0x2f,%al
8010251c:	74 f4                	je     80102512 <skipelem+0x8>
    path++;
  if(*path == 0)
8010251e:	8b 45 08             	mov    0x8(%ebp),%eax
80102521:	8a 00                	mov    (%eax),%al
80102523:	84 c0                	test   %al,%al
80102525:	75 0a                	jne    80102531 <skipelem+0x27>
    return 0;
80102527:	b8 00 00 00 00       	mov    $0x0,%eax
8010252c:	e9 81 00 00 00       	jmp    801025b2 <skipelem+0xa8>
  s = path;
80102531:	8b 45 08             	mov    0x8(%ebp),%eax
80102534:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102537:	eb 03                	jmp    8010253c <skipelem+0x32>
    path++;
80102539:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010253c:	8b 45 08             	mov    0x8(%ebp),%eax
8010253f:	8a 00                	mov    (%eax),%al
80102541:	3c 2f                	cmp    $0x2f,%al
80102543:	74 09                	je     8010254e <skipelem+0x44>
80102545:	8b 45 08             	mov    0x8(%ebp),%eax
80102548:	8a 00                	mov    (%eax),%al
8010254a:	84 c0                	test   %al,%al
8010254c:	75 eb                	jne    80102539 <skipelem+0x2f>
    path++;
  len = path - s;
8010254e:	8b 55 08             	mov    0x8(%ebp),%edx
80102551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102554:	29 c2                	sub    %eax,%edx
80102556:	89 d0                	mov    %edx,%eax
80102558:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010255b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010255f:	7e 1c                	jle    8010257d <skipelem+0x73>
    memmove(name, s, DIRSIZ);
80102561:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102568:	00 
80102569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010256c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102570:	8b 45 0c             	mov    0xc(%ebp),%eax
80102573:	89 04 24             	mov    %eax,(%esp)
80102576:	e8 34 35 00 00       	call   80105aaf <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010257b:	eb 29                	jmp    801025a6 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
8010257d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102580:	89 44 24 08          	mov    %eax,0x8(%esp)
80102584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102587:	89 44 24 04          	mov    %eax,0x4(%esp)
8010258b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010258e:	89 04 24             	mov    %eax,(%esp)
80102591:	e8 19 35 00 00       	call   80105aaf <memmove>
    name[len] = 0;
80102596:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102599:	8b 45 0c             	mov    0xc(%ebp),%eax
8010259c:	01 d0                	add    %edx,%eax
8010259e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025a1:	eb 03                	jmp    801025a6 <skipelem+0x9c>
    path++;
801025a3:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025a6:	8b 45 08             	mov    0x8(%ebp),%eax
801025a9:	8a 00                	mov    (%eax),%al
801025ab:	3c 2f                	cmp    $0x2f,%al
801025ad:	74 f4                	je     801025a3 <skipelem+0x99>
    path++;
  return path;
801025af:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025b2:	c9                   	leave  
801025b3:	c3                   	ret    

801025b4 <strcmp3>:

int
strcmp3(const char *p, const char *q)
{
801025b4:	55                   	push   %ebp
801025b5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801025b7:	eb 06                	jmp    801025bf <strcmp3+0xb>
    p++, q++;
801025b9:	ff 45 08             	incl   0x8(%ebp)
801025bc:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp3(const char *p, const char *q)
{
  while(*p && *p == *q)
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	8a 00                	mov    (%eax),%al
801025c4:	84 c0                	test   %al,%al
801025c6:	74 0e                	je     801025d6 <strcmp3+0x22>
801025c8:	8b 45 08             	mov    0x8(%ebp),%eax
801025cb:	8a 10                	mov    (%eax),%dl
801025cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801025d0:	8a 00                	mov    (%eax),%al
801025d2:	38 c2                	cmp    %al,%dl
801025d4:	74 e3                	je     801025b9 <strcmp3+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801025d6:	8b 45 08             	mov    0x8(%ebp),%eax
801025d9:	8a 00                	mov    (%eax),%al
801025db:	0f b6 d0             	movzbl %al,%edx
801025de:	8b 45 0c             	mov    0xc(%ebp),%eax
801025e1:	8a 00                	mov    (%eax),%al
801025e3:	0f b6 c0             	movzbl %al,%eax
801025e6:	29 c2                	sub    %eax,%edx
801025e8:	89 d0                	mov    %edx,%eax
}
801025ea:	5d                   	pop    %ebp
801025eb:	c3                   	ret    

801025ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025ec:	55                   	push   %ebp
801025ed:	89 e5                	mov    %esp,%ebp
801025ef:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025f2:	8b 45 08             	mov    0x8(%ebp),%eax
801025f5:	8a 00                	mov    (%eax),%al
801025f7:	3c 2f                	cmp    $0x2f,%al
801025f9:	75 19                	jne    80102614 <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
801025fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102602:	00 
80102603:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010260a:	e8 11 f4 ff ff       	call   80101a20 <iget>
8010260f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102612:	eb 13                	jmp    80102627 <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
80102614:	e8 ba 1f 00 00       	call   801045d3 <myproc>
80102619:	8b 40 68             	mov    0x68(%eax),%eax
8010261c:	89 04 24             	mov    %eax,(%esp)
8010261f:	e8 d1 f4 ff ff       	call   80101af5 <idup>
80102624:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
80102627:	e8 a7 1f 00 00       	call   801045d3 <myproc>
8010262c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
8010262f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
80102636:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010263a:	74 0c                	je     80102648 <namex+0x5c>
    cont = p->cont;
8010263c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010263f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102645:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
80102648:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
8010264f:	00 
80102650:	c7 44 24 04 1e 9c 10 	movl   $0x80109c1e,0x4(%esp)
80102657:	80 
80102658:	8b 45 08             	mov    0x8(%ebp),%eax
8010265b:	89 04 24             	mov    %eax,(%esp)
8010265e:	e8 eb 34 00 00       	call   80105b4e <strncmp>
80102663:	85 c0                	test   %eax,%eax
80102665:	75 21                	jne    80102688 <namex+0x9c>
80102667:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010266b:	74 1b                	je     80102688 <namex+0x9c>
8010266d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102670:	8b 40 3c             	mov    0x3c(%eax),%eax
80102673:	8b 50 04             	mov    0x4(%eax),%edx
80102676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102679:	8b 40 04             	mov    0x4(%eax),%eax
8010267c:	39 c2                	cmp    %eax,%edx
8010267e:	75 08                	jne    80102688 <namex+0x9c>
    return ip;
80102680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102683:	e9 45 01 00 00       	jmp    801027cd <namex+0x1e1>
  }
  
  while((path = skipelem(path, name)) != 0){
80102688:	e9 06 01 00 00       	jmp    80102793 <namex+0x1a7>
    ilock(ip);
8010268d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102690:	89 04 24             	mov    %eax,(%esp)
80102693:	e8 8f f4 ff ff       	call   80101b27 <ilock>

    if(ip->type != T_DIR){
80102698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269b:	8b 40 50             	mov    0x50(%eax),%eax
8010269e:	66 83 f8 01          	cmp    $0x1,%ax
801026a2:	74 15                	je     801026b9 <namex+0xcd>
      iunlockput(ip);
801026a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a7:	89 04 24             	mov    %eax,(%esp)
801026aa:	e8 77 f6 ff ff       	call   80101d26 <iunlockput>
      return 0;
801026af:	b8 00 00 00 00       	mov    $0x0,%eax
801026b4:	e9 14 01 00 00       	jmp    801027cd <namex+0x1e1>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
801026b9:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
801026c0:	00 
801026c1:	c7 44 24 04 1e 9c 10 	movl   $0x80109c1e,0x4(%esp)
801026c8:	80 
801026c9:	8b 45 08             	mov    0x8(%ebp),%eax
801026cc:	89 04 24             	mov    %eax,(%esp)
801026cf:	e8 7a 34 00 00       	call   80105b4e <strncmp>
801026d4:	85 c0                	test   %eax,%eax
801026d6:	75 2c                	jne    80102704 <namex+0x118>
801026d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026dc:	74 26                	je     80102704 <namex+0x118>
801026de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e1:	8b 40 3c             	mov    0x3c(%eax),%eax
801026e4:	8b 50 04             	mov    0x4(%eax),%edx
801026e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ea:	8b 40 04             	mov    0x4(%eax),%eax
801026ed:	39 c2                	cmp    %eax,%edx
801026ef:	75 13                	jne    80102704 <namex+0x118>
      iunlock(ip);
801026f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f4:	89 04 24             	mov    %eax,(%esp)
801026f7:	e8 35 f5 ff ff       	call   80101c31 <iunlock>
      return ip;
801026fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ff:	e9 c9 00 00 00       	jmp    801027cd <namex+0x1e1>
    }

    if(cont != NULL && ip->inum == ROOTINO){
80102704:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102708:	74 21                	je     8010272b <namex+0x13f>
8010270a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270d:	8b 40 04             	mov    0x4(%eax),%eax
80102710:	83 f8 01             	cmp    $0x1,%eax
80102713:	75 16                	jne    8010272b <namex+0x13f>
      iunlock(ip);
80102715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102718:	89 04 24             	mov    %eax,(%esp)
8010271b:	e8 11 f5 ff ff       	call   80101c31 <iunlock>
      return cont->root;
80102720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102723:	8b 40 3c             	mov    0x3c(%eax),%eax
80102726:	e9 a2 00 00 00       	jmp    801027cd <namex+0x1e1>
    }

    if(nameiparent && *path == '\0'){
8010272b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010272f:	74 1c                	je     8010274d <namex+0x161>
80102731:	8b 45 08             	mov    0x8(%ebp),%eax
80102734:	8a 00                	mov    (%eax),%al
80102736:	84 c0                	test   %al,%al
80102738:	75 13                	jne    8010274d <namex+0x161>
      // Stop one level early.
      iunlock(ip);
8010273a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273d:	89 04 24             	mov    %eax,(%esp)
80102740:	e8 ec f4 ff ff       	call   80101c31 <iunlock>
      return ip;
80102745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102748:	e9 80 00 00 00       	jmp    801027cd <namex+0x1e1>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010274d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102754:	00 
80102755:	8b 45 10             	mov    0x10(%ebp),%eax
80102758:	89 44 24 04          	mov    %eax,0x4(%esp)
8010275c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275f:	89 04 24             	mov    %eax,(%esp)
80102762:	e8 e7 fb ff ff       	call   8010234e <dirlookup>
80102767:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010276a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010276e:	75 12                	jne    80102782 <namex+0x196>
      iunlockput(ip);
80102770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102773:	89 04 24             	mov    %eax,(%esp)
80102776:	e8 ab f5 ff ff       	call   80101d26 <iunlockput>
      return 0;
8010277b:	b8 00 00 00 00       	mov    $0x0,%eax
80102780:	eb 4b                	jmp    801027cd <namex+0x1e1>
    }
    iunlockput(ip);
80102782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102785:	89 04 24             	mov    %eax,(%esp)
80102788:	e8 99 f5 ff ff       	call   80101d26 <iunlockput>

    ip = next;
8010278d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102790:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
    return ip;
  }
  
  while((path = skipelem(path, name)) != 0){
80102793:	8b 45 10             	mov    0x10(%ebp),%eax
80102796:	89 44 24 04          	mov    %eax,0x4(%esp)
8010279a:	8b 45 08             	mov    0x8(%ebp),%eax
8010279d:	89 04 24             	mov    %eax,(%esp)
801027a0:	e8 65 fd ff ff       	call   8010250a <skipelem>
801027a5:	89 45 08             	mov    %eax,0x8(%ebp)
801027a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027ac:	0f 85 db fe ff ff    	jne    8010268d <namex+0xa1>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
801027b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801027b6:	74 12                	je     801027ca <namex+0x1de>
    iput(ip);
801027b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bb:	89 04 24             	mov    %eax,(%esp)
801027be:	e8 b2 f4 ff ff       	call   80101c75 <iput>
    return 0;
801027c3:	b8 00 00 00 00       	mov    $0x0,%eax
801027c8:	eb 03                	jmp    801027cd <namex+0x1e1>
  }

  
  return ip;
801027ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027cd:	c9                   	leave  
801027ce:	c3                   	ret    

801027cf <namei>:

struct inode*
namei(char *path)
{
801027cf:	55                   	push   %ebp
801027d0:	89 e5                	mov    %esp,%ebp
801027d2:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801027d5:	8d 45 ea             	lea    -0x16(%ebp),%eax
801027d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801027dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801027e3:	00 
801027e4:	8b 45 08             	mov    0x8(%ebp),%eax
801027e7:	89 04 24             	mov    %eax,(%esp)
801027ea:	e8 fd fd ff ff       	call   801025ec <namex>
}
801027ef:	c9                   	leave  
801027f0:	c3                   	ret    

801027f1 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801027f1:	55                   	push   %ebp
801027f2:	89 e5                	mov    %esp,%ebp
801027f4:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801027f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801027fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801027fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102805:	00 
80102806:	8b 45 08             	mov    0x8(%ebp),%eax
80102809:	89 04 24             	mov    %eax,(%esp)
8010280c:	e8 db fd ff ff       	call   801025ec <namex>
}
80102811:	c9                   	leave  
80102812:	c3                   	ret    
	...

80102814 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102814:	55                   	push   %ebp
80102815:	89 e5                	mov    %esp,%ebp
80102817:	83 ec 14             	sub    $0x14,%esp
8010281a:	8b 45 08             	mov    0x8(%ebp),%eax
8010281d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102821:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102824:	89 c2                	mov    %eax,%edx
80102826:	ec                   	in     (%dx),%al
80102827:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010282a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010282d:	c9                   	leave  
8010282e:	c3                   	ret    

8010282f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010282f:	55                   	push   %ebp
80102830:	89 e5                	mov    %esp,%ebp
80102832:	57                   	push   %edi
80102833:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102834:	8b 55 08             	mov    0x8(%ebp),%edx
80102837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010283a:	8b 45 10             	mov    0x10(%ebp),%eax
8010283d:	89 cb                	mov    %ecx,%ebx
8010283f:	89 df                	mov    %ebx,%edi
80102841:	89 c1                	mov    %eax,%ecx
80102843:	fc                   	cld    
80102844:	f3 6d                	rep insl (%dx),%es:(%edi)
80102846:	89 c8                	mov    %ecx,%eax
80102848:	89 fb                	mov    %edi,%ebx
8010284a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010284d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102850:	5b                   	pop    %ebx
80102851:	5f                   	pop    %edi
80102852:	5d                   	pop    %ebp
80102853:	c3                   	ret    

80102854 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102854:	55                   	push   %ebp
80102855:	89 e5                	mov    %esp,%ebp
80102857:	83 ec 08             	sub    $0x8,%esp
8010285a:	8b 45 08             	mov    0x8(%ebp),%eax
8010285d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102860:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102864:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102867:	8a 45 f8             	mov    -0x8(%ebp),%al
8010286a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010286d:	ee                   	out    %al,(%dx)
}
8010286e:	c9                   	leave  
8010286f:	c3                   	ret    

80102870 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102870:	55                   	push   %ebp
80102871:	89 e5                	mov    %esp,%ebp
80102873:	56                   	push   %esi
80102874:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102875:	8b 55 08             	mov    0x8(%ebp),%edx
80102878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010287b:	8b 45 10             	mov    0x10(%ebp),%eax
8010287e:	89 cb                	mov    %ecx,%ebx
80102880:	89 de                	mov    %ebx,%esi
80102882:	89 c1                	mov    %eax,%ecx
80102884:	fc                   	cld    
80102885:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102887:	89 c8                	mov    %ecx,%eax
80102889:	89 f3                	mov    %esi,%ebx
8010288b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010288e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102891:	5b                   	pop    %ebx
80102892:	5e                   	pop    %esi
80102893:	5d                   	pop    %ebp
80102894:	c3                   	ret    

80102895 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102895:	55                   	push   %ebp
80102896:	89 e5                	mov    %esp,%ebp
80102898:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010289b:	90                   	nop
8010289c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028a3:	e8 6c ff ff ff       	call   80102814 <inb>
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
801028ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028b1:	25 c0 00 00 00       	and    $0xc0,%eax
801028b6:	83 f8 40             	cmp    $0x40,%eax
801028b9:	75 e1                	jne    8010289c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801028bb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028bf:	74 11                	je     801028d2 <idewait+0x3d>
801028c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028c4:	83 e0 21             	and    $0x21,%eax
801028c7:	85 c0                	test   %eax,%eax
801028c9:	74 07                	je     801028d2 <idewait+0x3d>
    return -1;
801028cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801028d0:	eb 05                	jmp    801028d7 <idewait+0x42>
  return 0;
801028d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028d7:	c9                   	leave  
801028d8:	c3                   	ret    

801028d9 <ideinit>:

void
ideinit(void)
{
801028d9:	55                   	push   %ebp
801028da:	89 e5                	mov    %esp,%ebp
801028dc:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801028df:	c7 44 24 04 21 9c 10 	movl   $0x80109c21,0x4(%esp)
801028e6:	80 
801028e7:	c7 04 24 00 d9 10 80 	movl   $0x8010d900,(%esp)
801028ee:	e8 6f 2e 00 00       	call   80105762 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028f3:	a1 80 62 11 80       	mov    0x80116280,%eax
801028f8:	48                   	dec    %eax
801028f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801028fd:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102904:	e8 66 04 00 00       	call   80102d6f <ioapicenable>
  idewait(0);
80102909:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102910:	e8 80 ff ff ff       	call   80102895 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102915:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010291c:	00 
8010291d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102924:	e8 2b ff ff ff       	call   80102854 <outb>
  for(i=0; i<1000; i++){
80102929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102930:	eb 1f                	jmp    80102951 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102932:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102939:	e8 d6 fe ff ff       	call   80102814 <inb>
8010293e:	84 c0                	test   %al,%al
80102940:	74 0c                	je     8010294e <ideinit+0x75>
      havedisk1 = 1;
80102942:	c7 05 38 d9 10 80 01 	movl   $0x1,0x8010d938
80102949:	00 00 00 
      break;
8010294c:	eb 0c                	jmp    8010295a <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010294e:	ff 45 f4             	incl   -0xc(%ebp)
80102951:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102958:	7e d8                	jle    80102932 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010295a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102961:	00 
80102962:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102969:	e8 e6 fe ff ff       	call   80102854 <outb>
}
8010296e:	c9                   	leave  
8010296f:	c3                   	ret    

80102970 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102970:	55                   	push   %ebp
80102971:	89 e5                	mov    %esp,%ebp
80102973:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102976:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010297a:	75 0c                	jne    80102988 <idestart+0x18>
    panic("idestart");
8010297c:	c7 04 24 25 9c 10 80 	movl   $0x80109c25,(%esp)
80102983:	e8 cc db ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	8b 40 08             	mov    0x8(%eax),%eax
8010298e:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
80102993:	76 0c                	jbe    801029a1 <idestart+0x31>
    panic("incorrect blockno");
80102995:	c7 04 24 2e 9c 10 80 	movl   $0x80109c2e,(%esp)
8010299c:	e8 b3 db ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801029a1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801029a8:	8b 45 08             	mov    0x8(%ebp),%eax
801029ab:	8b 50 08             	mov    0x8(%eax),%edx
801029ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b1:	0f af c2             	imul   %edx,%eax
801029b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801029b7:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801029bb:	75 07                	jne    801029c4 <idestart+0x54>
801029bd:	b8 20 00 00 00       	mov    $0x20,%eax
801029c2:	eb 05                	jmp    801029c9 <idestart+0x59>
801029c4:	b8 c4 00 00 00       	mov    $0xc4,%eax
801029c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801029cc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801029d0:	75 07                	jne    801029d9 <idestart+0x69>
801029d2:	b8 30 00 00 00       	mov    $0x30,%eax
801029d7:	eb 05                	jmp    801029de <idestart+0x6e>
801029d9:	b8 c5 00 00 00       	mov    $0xc5,%eax
801029de:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801029e1:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801029e5:	7e 0c                	jle    801029f3 <idestart+0x83>
801029e7:	c7 04 24 25 9c 10 80 	movl   $0x80109c25,(%esp)
801029ee:	e8 61 db ff ff       	call   80100554 <panic>

  idewait(0);
801029f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029fa:	e8 96 fe ff ff       	call   80102895 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801029ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a06:	00 
80102a07:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102a0e:	e8 41 fe ff ff       	call   80102854 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a16:	0f b6 c0             	movzbl %al,%eax
80102a19:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a1d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102a24:	e8 2b fe ff ff       	call   80102854 <outb>
  outb(0x1f3, sector & 0xff);
80102a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a2c:	0f b6 c0             	movzbl %al,%eax
80102a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a33:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102a3a:	e8 15 fe ff ff       	call   80102854 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a42:	c1 f8 08             	sar    $0x8,%eax
80102a45:	0f b6 c0             	movzbl %al,%eax
80102a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a4c:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102a53:	e8 fc fd ff ff       	call   80102854 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a5b:	c1 f8 10             	sar    $0x10,%eax
80102a5e:	0f b6 c0             	movzbl %al,%eax
80102a61:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a65:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102a6c:	e8 e3 fd ff ff       	call   80102854 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102a71:	8b 45 08             	mov    0x8(%ebp),%eax
80102a74:	8b 40 04             	mov    0x4(%eax),%eax
80102a77:	83 e0 01             	and    $0x1,%eax
80102a7a:	c1 e0 04             	shl    $0x4,%eax
80102a7d:	88 c2                	mov    %al,%dl
80102a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a82:	c1 f8 18             	sar    $0x18,%eax
80102a85:	83 e0 0f             	and    $0xf,%eax
80102a88:	09 d0                	or     %edx,%eax
80102a8a:	83 c8 e0             	or     $0xffffffe0,%eax
80102a8d:	0f b6 c0             	movzbl %al,%eax
80102a90:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a94:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102a9b:	e8 b4 fd ff ff       	call   80102854 <outb>
  if(b->flags & B_DIRTY){
80102aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa3:	8b 00                	mov    (%eax),%eax
80102aa5:	83 e0 04             	and    $0x4,%eax
80102aa8:	85 c0                	test   %eax,%eax
80102aaa:	74 36                	je     80102ae2 <idestart+0x172>
    outb(0x1f7, write_cmd);
80102aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102aaf:	0f b6 c0             	movzbl %al,%eax
80102ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ab6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102abd:	e8 92 fd ff ff       	call   80102854 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac5:	83 c0 5c             	add    $0x5c,%eax
80102ac8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102acf:	00 
80102ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ad4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102adb:	e8 90 fd ff ff       	call   80102870 <outsl>
80102ae0:	eb 16                	jmp    80102af8 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102ae2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ae5:	0f b6 c0             	movzbl %al,%eax
80102ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aec:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102af3:	e8 5c fd ff ff       	call   80102854 <outb>
  }
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp
80102afd:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102b00:	c7 04 24 00 d9 10 80 	movl   $0x8010d900,(%esp)
80102b07:	e8 77 2c 00 00       	call   80105783 <acquire>

  if((b = idequeue) == 0){
80102b0c:	a1 34 d9 10 80       	mov    0x8010d934,%eax
80102b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b18:	75 11                	jne    80102b2b <ideintr+0x31>
    release(&idelock);
80102b1a:	c7 04 24 00 d9 10 80 	movl   $0x8010d900,(%esp)
80102b21:	e8 c7 2c 00 00       	call   801057ed <release>
    return;
80102b26:	e9 90 00 00 00       	jmp    80102bbb <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2e:	8b 40 58             	mov    0x58(%eax),%eax
80102b31:	a3 34 d9 10 80       	mov    %eax,0x8010d934

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b39:	8b 00                	mov    (%eax),%eax
80102b3b:	83 e0 04             	and    $0x4,%eax
80102b3e:	85 c0                	test   %eax,%eax
80102b40:	75 2e                	jne    80102b70 <ideintr+0x76>
80102b42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b49:	e8 47 fd ff ff       	call   80102895 <idewait>
80102b4e:	85 c0                	test   %eax,%eax
80102b50:	78 1e                	js     80102b70 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b55:	83 c0 5c             	add    $0x5c,%eax
80102b58:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102b5f:	00 
80102b60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b64:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102b6b:	e8 bf fc ff ff       	call   8010282f <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b73:	8b 00                	mov    (%eax),%eax
80102b75:	83 c8 02             	or     $0x2,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b82:	8b 00                	mov    (%eax),%eax
80102b84:	83 e0 fb             	and    $0xfffffffb,%eax
80102b87:	89 c2                	mov    %eax,%edx
80102b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b91:	89 04 24             	mov    %eax,(%esp)
80102b94:	e8 c2 23 00 00       	call   80104f5b <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102b99:	a1 34 d9 10 80       	mov    0x8010d934,%eax
80102b9e:	85 c0                	test   %eax,%eax
80102ba0:	74 0d                	je     80102baf <ideintr+0xb5>
    idestart(idequeue);
80102ba2:	a1 34 d9 10 80       	mov    0x8010d934,%eax
80102ba7:	89 04 24             	mov    %eax,(%esp)
80102baa:	e8 c1 fd ff ff       	call   80102970 <idestart>

  release(&idelock);
80102baf:	c7 04 24 00 d9 10 80 	movl   $0x8010d900,(%esp)
80102bb6:	e8 32 2c 00 00       	call   801057ed <release>
}
80102bbb:	c9                   	leave  
80102bbc:	c3                   	ret    

80102bbd <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102bbd:	55                   	push   %ebp
80102bbe:	89 e5                	mov    %esp,%ebp
80102bc0:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc6:	83 c0 0c             	add    $0xc,%eax
80102bc9:	89 04 24             	mov    %eax,(%esp)
80102bcc:	e8 2a 2b 00 00       	call   801056fb <holdingsleep>
80102bd1:	85 c0                	test   %eax,%eax
80102bd3:	75 0c                	jne    80102be1 <iderw+0x24>
    panic("iderw: buf not locked");
80102bd5:	c7 04 24 40 9c 10 80 	movl   $0x80109c40,(%esp)
80102bdc:	e8 73 d9 ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102be1:	8b 45 08             	mov    0x8(%ebp),%eax
80102be4:	8b 00                	mov    (%eax),%eax
80102be6:	83 e0 06             	and    $0x6,%eax
80102be9:	83 f8 02             	cmp    $0x2,%eax
80102bec:	75 0c                	jne    80102bfa <iderw+0x3d>
    panic("iderw: nothing to do");
80102bee:	c7 04 24 56 9c 10 80 	movl   $0x80109c56,(%esp)
80102bf5:	e8 5a d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfd:	8b 40 04             	mov    0x4(%eax),%eax
80102c00:	85 c0                	test   %eax,%eax
80102c02:	74 15                	je     80102c19 <iderw+0x5c>
80102c04:	a1 38 d9 10 80       	mov    0x8010d938,%eax
80102c09:	85 c0                	test   %eax,%eax
80102c0b:	75 0c                	jne    80102c19 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102c0d:	c7 04 24 6b 9c 10 80 	movl   $0x80109c6b,(%esp)
80102c14:	e8 3b d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102c19:	c7 04 24 00 d9 10 80 	movl   $0x8010d900,(%esp)
80102c20:	e8 5e 2b 00 00       	call   80105783 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102c25:	8b 45 08             	mov    0x8(%ebp),%eax
80102c28:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102c2f:	c7 45 f4 34 d9 10 80 	movl   $0x8010d934,-0xc(%ebp)
80102c36:	eb 0b                	jmp    80102c43 <iderw+0x86>
80102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3b:	8b 00                	mov    (%eax),%eax
80102c3d:	83 c0 58             	add    $0x58,%eax
80102c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c46:	8b 00                	mov    (%eax),%eax
80102c48:	85 c0                	test   %eax,%eax
80102c4a:	75 ec                	jne    80102c38 <iderw+0x7b>
    ;
  *pp = b;
80102c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c52:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102c54:	a1 34 d9 10 80       	mov    0x8010d934,%eax
80102c59:	3b 45 08             	cmp    0x8(%ebp),%eax
80102c5c:	75 0d                	jne    80102c6b <iderw+0xae>
    idestart(b);
80102c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c61:	89 04 24             	mov    %eax,(%esp)
80102c64:	e8 07 fd ff ff       	call   80102970 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c69:	eb 15                	jmp    80102c80 <iderw+0xc3>
80102c6b:	eb 13                	jmp    80102c80 <iderw+0xc3>
    sleep(b, &idelock);
80102c6d:	c7 44 24 04 00 d9 10 	movl   $0x8010d900,0x4(%esp)
80102c74:	80 
80102c75:	8b 45 08             	mov    0x8(%ebp),%eax
80102c78:	89 04 24             	mov    %eax,(%esp)
80102c7b:	e8 04 22 00 00       	call   80104e84 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c80:	8b 45 08             	mov    0x8(%ebp),%eax
80102c83:	8b 00                	mov    (%eax),%eax
80102c85:	83 e0 06             	and    $0x6,%eax
80102c88:	83 f8 02             	cmp    $0x2,%eax
80102c8b:	75 e0                	jne    80102c6d <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102c8d:	c7 04 24 00 d9 10 80 	movl   $0x8010d900,(%esp)
80102c94:	e8 54 2b 00 00       	call   801057ed <release>
}
80102c99:	c9                   	leave  
80102c9a:	c3                   	ret    
	...

80102c9c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102c9c:	55                   	push   %ebp
80102c9d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c9f:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102ca4:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ca9:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102cae:	8b 40 10             	mov    0x10(%eax),%eax
}
80102cb1:	5d                   	pop    %ebp
80102cb2:	c3                   	ret    

80102cb3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102cb6:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102cbb:	8b 55 08             	mov    0x8(%ebp),%edx
80102cbe:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102cc0:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
80102cc8:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ccb:	5d                   	pop    %ebp
80102ccc:	c3                   	ret    

80102ccd <ioapicinit>:

void
ioapicinit(void)
{
80102ccd:	55                   	push   %ebp
80102cce:	89 e5                	mov    %esp,%ebp
80102cd0:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102cd3:	c7 05 94 5b 11 80 00 	movl   $0xfec00000,0x80115b94
80102cda:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102cdd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ce4:	e8 b3 ff ff ff       	call   80102c9c <ioapicread>
80102ce9:	c1 e8 10             	shr    $0x10,%eax
80102cec:	25 ff 00 00 00       	and    $0xff,%eax
80102cf1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102cf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102cfb:	e8 9c ff ff ff       	call   80102c9c <ioapicread>
80102d00:	c1 e8 18             	shr    $0x18,%eax
80102d03:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102d06:	a0 e0 5c 11 80       	mov    0x80115ce0,%al
80102d0b:	0f b6 c0             	movzbl %al,%eax
80102d0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102d11:	74 0c                	je     80102d1f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102d13:	c7 04 24 8c 9c 10 80 	movl   $0x80109c8c,(%esp)
80102d1a:	e8 a2 d6 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102d26:	eb 3d                	jmp    80102d65 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2b:	83 c0 20             	add    $0x20,%eax
80102d2e:	0d 00 00 01 00       	or     $0x10000,%eax
80102d33:	89 c2                	mov    %eax,%edx
80102d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d38:	83 c0 08             	add    $0x8,%eax
80102d3b:	01 c0                	add    %eax,%eax
80102d3d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d41:	89 04 24             	mov    %eax,(%esp)
80102d44:	e8 6a ff ff ff       	call   80102cb3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d4c:	83 c0 08             	add    $0x8,%eax
80102d4f:	01 c0                	add    %eax,%eax
80102d51:	40                   	inc    %eax
80102d52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102d59:	00 
80102d5a:	89 04 24             	mov    %eax,(%esp)
80102d5d:	e8 51 ff ff ff       	call   80102cb3 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d62:	ff 45 f4             	incl   -0xc(%ebp)
80102d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d68:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102d6b:	7e bb                	jle    80102d28 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102d6d:	c9                   	leave  
80102d6e:	c3                   	ret    

80102d6f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102d6f:	55                   	push   %ebp
80102d70:	89 e5                	mov    %esp,%ebp
80102d72:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102d75:	8b 45 08             	mov    0x8(%ebp),%eax
80102d78:	83 c0 20             	add    $0x20,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d80:	83 c0 08             	add    $0x8,%eax
80102d83:	01 c0                	add    %eax,%eax
80102d85:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d89:	89 04 24             	mov    %eax,(%esp)
80102d8c:	e8 22 ff ff ff       	call   80102cb3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d94:	c1 e0 18             	shl    $0x18,%eax
80102d97:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9a:	83 c2 08             	add    $0x8,%edx
80102d9d:	01 d2                	add    %edx,%edx
80102d9f:	42                   	inc    %edx
80102da0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102da4:	89 14 24             	mov    %edx,(%esp)
80102da7:	e8 07 ff ff ff       	call   80102cb3 <ioapicwrite>
}
80102dac:	c9                   	leave  
80102dad:	c3                   	ret    
	...

80102db0 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102db0:	55                   	push   %ebp
80102db1:	89 e5                	mov    %esp,%ebp
80102db3:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102db6:	c7 44 24 04 be 9c 10 	movl   $0x80109cbe,0x4(%esp)
80102dbd:	80 
80102dbe:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80102dc5:	e8 98 29 00 00       	call   80105762 <initlock>
  kmem.use_lock = 0;
80102dca:	c7 05 d4 5b 11 80 00 	movl   $0x0,0x80115bd4
80102dd1:	00 00 00 
  freerange(vstart, vend);
80102dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80102dde:	89 04 24             	mov    %eax,(%esp)
80102de1:	e8 30 00 00 00       	call   80102e16 <freerange>
}
80102de6:	c9                   	leave  
80102de7:	c3                   	ret    

80102de8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102de8:	55                   	push   %ebp
80102de9:	89 e5                	mov    %esp,%ebp
80102deb:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102dee:	8b 45 0c             	mov    0xc(%ebp),%eax
80102df1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102df5:	8b 45 08             	mov    0x8(%ebp),%eax
80102df8:	89 04 24             	mov    %eax,(%esp)
80102dfb:	e8 16 00 00 00       	call   80102e16 <freerange>
  kmem.use_lock = 1;
80102e00:	c7 05 d4 5b 11 80 01 	movl   $0x1,0x80115bd4
80102e07:	00 00 00 
  kmem.i = 0;
80102e0a:	c7 05 dc 5b 11 80 00 	movl   $0x0,0x80115bdc
80102e11:	00 00 00 
}
80102e14:	c9                   	leave  
80102e15:	c3                   	ret    

80102e16 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102e16:	55                   	push   %ebp
80102e17:	89 e5                	mov    %esp,%ebp
80102e19:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e1f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102e24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e2c:	eb 12                	jmp    80102e40 <freerange+0x2a>
    kfree(p);
80102e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e31:	89 04 24             	mov    %eax,(%esp)
80102e34:	e8 16 00 00 00       	call   80102e4f <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e39:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e43:	05 00 10 00 00       	add    $0x1000,%eax
80102e48:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102e4b:	76 e1                	jbe    80102e2e <freerange+0x18>
    kfree(p);
}
80102e4d:	c9                   	leave  
80102e4e:	c3                   	ret    

80102e4f <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102e4f:	55                   	push   %ebp
80102e50:	89 e5                	mov    %esp,%ebp
80102e52:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102e55:	8b 45 08             	mov    0x8(%ebp),%eax
80102e58:	25 ff 0f 00 00       	and    $0xfff,%eax
80102e5d:	85 c0                	test   %eax,%eax
80102e5f:	75 18                	jne    80102e79 <kfree+0x2a>
80102e61:	81 7d 08 40 8e 11 80 	cmpl   $0x80118e40,0x8(%ebp)
80102e68:	72 0f                	jb     80102e79 <kfree+0x2a>
80102e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6d:	05 00 00 00 80       	add    $0x80000000,%eax
80102e72:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102e77:	76 0c                	jbe    80102e85 <kfree+0x36>
    panic("kfree");
80102e79:	c7 04 24 c3 9c 10 80 	movl   $0x80109cc3,(%esp)
80102e80:	e8 cf d6 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e85:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e8c:	00 
80102e8d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e94:	00 
80102e95:	8b 45 08             	mov    0x8(%ebp),%eax
80102e98:	89 04 24             	mov    %eax,(%esp)
80102e9b:	e8 46 2b 00 00       	call   801059e6 <memset>

  if(kmem.use_lock){
80102ea0:	a1 d4 5b 11 80       	mov    0x80115bd4,%eax
80102ea5:	85 c0                	test   %eax,%eax
80102ea7:	74 5a                	je     80102f03 <kfree+0xb4>
    acquire(&kmem.lock);
80102ea9:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80102eb0:	e8 ce 28 00 00       	call   80105783 <acquire>
    if(ticks > 1){
80102eb5:	a1 20 8d 11 80       	mov    0x80118d20,%eax
80102eba:	83 f8 01             	cmp    $0x1,%eax
80102ebd:	76 44                	jbe    80102f03 <kfree+0xb4>
      int x = find(myproc()->cont->name);
80102ebf:	e8 0f 17 00 00       	call   801045d3 <myproc>
80102ec4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102eca:	83 c0 1c             	add    $0x1c,%eax
80102ecd:	89 04 24             	mov    %eax,(%esp)
80102ed0:	e8 48 66 00 00       	call   8010951d <find>
80102ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102ed8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102edc:	78 25                	js     80102f03 <kfree+0xb4>
        reduce_curr_mem(1, x);
80102ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ee5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102eec:	e8 c5 68 00 00       	call   801097b6 <reduce_curr_mem>
        myproc()->usage--;
80102ef1:	e8 dd 16 00 00       	call   801045d3 <myproc>
80102ef6:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102efc:	4a                   	dec    %edx
80102efd:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      }
    }
  }
  r = (struct run*)v;
80102f03:	8b 45 08             	mov    0x8(%ebp),%eax
80102f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102f09:	8b 15 d8 5b 11 80    	mov    0x80115bd8,%edx
80102f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f12:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f17:	a3 d8 5b 11 80       	mov    %eax,0x80115bd8
  kmem.i--;
80102f1c:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
80102f21:	48                   	dec    %eax
80102f22:	a3 dc 5b 11 80       	mov    %eax,0x80115bdc
  if(kmem.use_lock)
80102f27:	a1 d4 5b 11 80       	mov    0x80115bd4,%eax
80102f2c:	85 c0                	test   %eax,%eax
80102f2e:	74 0c                	je     80102f3c <kfree+0xed>
    release(&kmem.lock);
80102f30:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80102f37:	e8 b1 28 00 00       	call   801057ed <release>
}
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102f3e:	55                   	push   %ebp
80102f3f:	89 e5                	mov    %esp,%ebp
80102f41:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102f44:	a1 d4 5b 11 80       	mov    0x80115bd4,%eax
80102f49:	85 c0                	test   %eax,%eax
80102f4b:	74 0c                	je     80102f59 <kalloc+0x1b>
    acquire(&kmem.lock);
80102f4d:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80102f54:	e8 2a 28 00 00       	call   80105783 <acquire>
  }
  r = kmem.freelist;
80102f59:	a1 d8 5b 11 80       	mov    0x80115bd8,%eax
80102f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102f61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f65:	74 0a                	je     80102f71 <kalloc+0x33>
    kmem.freelist = r->next;
80102f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f6a:	8b 00                	mov    (%eax),%eax
80102f6c:	a3 d8 5b 11 80       	mov    %eax,0x80115bd8
  kmem.i++;
80102f71:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
80102f76:	40                   	inc    %eax
80102f77:	a3 dc 5b 11 80       	mov    %eax,0x80115bdc
  if((char*)r != 0){
80102f7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f80:	0f 84 84 00 00 00    	je     8010300a <kalloc+0xcc>
    if(ticks > 0){
80102f86:	a1 20 8d 11 80       	mov    0x80118d20,%eax
80102f8b:	85 c0                	test   %eax,%eax
80102f8d:	74 7b                	je     8010300a <kalloc+0xcc>
      int x = find(myproc()->cont->name);
80102f8f:	e8 3f 16 00 00       	call   801045d3 <myproc>
80102f94:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f9a:	83 c0 1c             	add    $0x1c,%eax
80102f9d:	89 04 24             	mov    %eax,(%esp)
80102fa0:	e8 78 65 00 00       	call   8010951d <find>
80102fa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102fa8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102fac:	78 5c                	js     8010300a <kalloc+0xcc>
        myproc()->usage++;
80102fae:	e8 20 16 00 00       	call   801045d3 <myproc>
80102fb3:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102fb9:	42                   	inc    %edx
80102fba:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        int before = get_curr_mem(x);
80102fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fc3:	89 04 24             	mov    %eax,(%esp)
80102fc6:	e8 b9 66 00 00       	call   80109684 <get_curr_mem>
80102fcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102fdc:	e8 7e 67 00 00       	call   8010975f <set_curr_mem>
        int after = get_curr_mem(x);
80102fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fe4:	89 04 24             	mov    %eax,(%esp)
80102fe7:	e8 98 66 00 00       	call   80109684 <get_curr_mem>
80102fec:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102fef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff2:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102ff5:	75 13                	jne    8010300a <kalloc+0xcc>
          cstop_container_helper(myproc()->cont);
80102ff7:	e8 d7 15 00 00       	call   801045d3 <myproc>
80102ffc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80103002:	89 04 24             	mov    %eax,(%esp)
80103005:	e8 b3 21 00 00       	call   801051bd <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
8010300a:	a1 d4 5b 11 80       	mov    0x80115bd4,%eax
8010300f:	85 c0                	test   %eax,%eax
80103011:	74 0c                	je     8010301f <kalloc+0xe1>
    release(&kmem.lock);
80103013:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
8010301a:	e8 ce 27 00 00       	call   801057ed <release>
  return (char*)r;
8010301f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103022:	c9                   	leave  
80103023:	c3                   	ret    

80103024 <mem_usage>:

int mem_usage(void){
80103024:	55                   	push   %ebp
80103025:	89 e5                	mov    %esp,%ebp
  return kmem.i;
80103027:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
}
8010302c:	5d                   	pop    %ebp
8010302d:	c3                   	ret    

8010302e <mem_avail>:

int mem_avail(void){
8010302e:	55                   	push   %ebp
8010302f:	89 e5                	mov    %esp,%ebp
80103031:	83 ec 10             	sub    $0x10,%esp
  int freebytes = ((P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024)))/4096;
80103034:	b8 40 8e 11 80       	mov    $0x80118e40,%eax
80103039:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
8010303e:	29 c2                	sub    %eax,%edx
80103040:	89 d0                	mov    %edx,%eax
80103042:	85 c0                	test   %eax,%eax
80103044:	79 05                	jns    8010304b <mem_avail+0x1d>
80103046:	05 ff 0f 00 00       	add    $0xfff,%eax
8010304b:	c1 f8 0c             	sar    $0xc,%eax
8010304e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return freebytes;
80103051:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103054:	c9                   	leave  
80103055:	c3                   	ret    
	...

80103058 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103058:	55                   	push   %ebp
80103059:	89 e5                	mov    %esp,%ebp
8010305b:	83 ec 14             	sub    $0x14,%esp
8010305e:	8b 45 08             	mov    0x8(%ebp),%eax
80103061:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103068:	89 c2                	mov    %eax,%edx
8010306a:	ec                   	in     (%dx),%al
8010306b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010306e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103071:	c9                   	leave  
80103072:	c3                   	ret    

80103073 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103073:	55                   	push   %ebp
80103074:	89 e5                	mov    %esp,%ebp
80103076:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103079:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103080:	e8 d3 ff ff ff       	call   80103058 <inb>
80103085:	0f b6 c0             	movzbl %al,%eax
80103088:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010308b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010308e:	83 e0 01             	and    $0x1,%eax
80103091:	85 c0                	test   %eax,%eax
80103093:	75 0a                	jne    8010309f <kbdgetc+0x2c>
    return -1;
80103095:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010309a:	e9 21 01 00 00       	jmp    801031c0 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010309f:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
801030a6:	e8 ad ff ff ff       	call   80103058 <inb>
801030ab:	0f b6 c0             	movzbl %al,%eax
801030ae:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801030b1:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801030b8:	75 17                	jne    801030d1 <kbdgetc+0x5e>
    shift |= E0ESC;
801030ba:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
801030bf:	83 c8 40             	or     $0x40,%eax
801030c2:	a3 3c d9 10 80       	mov    %eax,0x8010d93c
    return 0;
801030c7:	b8 00 00 00 00       	mov    $0x0,%eax
801030cc:	e9 ef 00 00 00       	jmp    801031c0 <kbdgetc+0x14d>
  } else if(data & 0x80){
801030d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030d4:	25 80 00 00 00       	and    $0x80,%eax
801030d9:	85 c0                	test   %eax,%eax
801030db:	74 44                	je     80103121 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801030dd:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
801030e2:	83 e0 40             	and    $0x40,%eax
801030e5:	85 c0                	test   %eax,%eax
801030e7:	75 08                	jne    801030f1 <kbdgetc+0x7e>
801030e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030ec:	83 e0 7f             	and    $0x7f,%eax
801030ef:	eb 03                	jmp    801030f4 <kbdgetc+0x81>
801030f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801030f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030fa:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030ff:	8a 00                	mov    (%eax),%al
80103101:	83 c8 40             	or     $0x40,%eax
80103104:	0f b6 c0             	movzbl %al,%eax
80103107:	f7 d0                	not    %eax
80103109:	89 c2                	mov    %eax,%edx
8010310b:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
80103110:	21 d0                	and    %edx,%eax
80103112:	a3 3c d9 10 80       	mov    %eax,0x8010d93c
    return 0;
80103117:	b8 00 00 00 00       	mov    $0x0,%eax
8010311c:	e9 9f 00 00 00       	jmp    801031c0 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103121:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
80103126:	83 e0 40             	and    $0x40,%eax
80103129:	85 c0                	test   %eax,%eax
8010312b:	74 14                	je     80103141 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010312d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103134:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
80103139:	83 e0 bf             	and    $0xffffffbf,%eax
8010313c:	a3 3c d9 10 80       	mov    %eax,0x8010d93c
  }

  shift |= shiftcode[data];
80103141:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103144:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103149:	8a 00                	mov    (%eax),%al
8010314b:	0f b6 d0             	movzbl %al,%edx
8010314e:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
80103153:	09 d0                	or     %edx,%eax
80103155:	a3 3c d9 10 80       	mov    %eax,0x8010d93c
  shift ^= togglecode[data];
8010315a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010315d:	05 20 b1 10 80       	add    $0x8010b120,%eax
80103162:	8a 00                	mov    (%eax),%al
80103164:	0f b6 d0             	movzbl %al,%edx
80103167:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
8010316c:	31 d0                	xor    %edx,%eax
8010316e:	a3 3c d9 10 80       	mov    %eax,0x8010d93c
  c = charcode[shift & (CTL | SHIFT)][data];
80103173:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
80103178:	83 e0 03             	and    $0x3,%eax
8010317b:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80103182:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103185:	01 d0                	add    %edx,%eax
80103187:	8a 00                	mov    (%eax),%al
80103189:	0f b6 c0             	movzbl %al,%eax
8010318c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010318f:	a1 3c d9 10 80       	mov    0x8010d93c,%eax
80103194:	83 e0 08             	and    $0x8,%eax
80103197:	85 c0                	test   %eax,%eax
80103199:	74 22                	je     801031bd <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010319b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010319f:	76 0c                	jbe    801031ad <kbdgetc+0x13a>
801031a1:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801031a5:	77 06                	ja     801031ad <kbdgetc+0x13a>
      c += 'A' - 'a';
801031a7:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801031ab:	eb 10                	jmp    801031bd <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801031ad:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801031b1:	76 0a                	jbe    801031bd <kbdgetc+0x14a>
801031b3:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801031b7:	77 04                	ja     801031bd <kbdgetc+0x14a>
      c += 'a' - 'A';
801031b9:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801031bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801031c0:	c9                   	leave  
801031c1:	c3                   	ret    

801031c2 <kbdintr>:

void
kbdintr(void)
{
801031c2:	55                   	push   %ebp
801031c3:	89 e5                	mov    %esp,%ebp
801031c5:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801031c8:	c7 04 24 73 30 10 80 	movl   $0x80103073,(%esp)
801031cf:	e8 21 d6 ff ff       	call   801007f5 <consoleintr>
}
801031d4:	c9                   	leave  
801031d5:	c3                   	ret    
	...

801031d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801031d8:	55                   	push   %ebp
801031d9:	89 e5                	mov    %esp,%ebp
801031db:	83 ec 14             	sub    $0x14,%esp
801031de:	8b 45 08             	mov    0x8(%ebp),%eax
801031e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801031e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031e8:	89 c2                	mov    %eax,%edx
801031ea:	ec                   	in     (%dx),%al
801031eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801031ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801031f1:	c9                   	leave  
801031f2:	c3                   	ret    

801031f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031f3:	55                   	push   %ebp
801031f4:	89 e5                	mov    %esp,%ebp
801031f6:	83 ec 08             	sub    $0x8,%esp
801031f9:	8b 45 08             	mov    0x8(%ebp),%eax
801031fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801031ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103203:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103206:	8a 45 f8             	mov    -0x8(%ebp),%al
80103209:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010320c:	ee                   	out    %al,(%dx)
}
8010320d:	c9                   	leave  
8010320e:	c3                   	ret    

8010320f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010320f:	55                   	push   %ebp
80103210:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103212:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
80103217:	8b 55 08             	mov    0x8(%ebp),%edx
8010321a:	c1 e2 02             	shl    $0x2,%edx
8010321d:	01 c2                	add    %eax,%edx
8010321f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103222:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103224:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
80103229:	83 c0 20             	add    $0x20,%eax
8010322c:	8b 00                	mov    (%eax),%eax
}
8010322e:	5d                   	pop    %ebp
8010322f:	c3                   	ret    

80103230 <lapicinit>:

void
lapicinit(void)
{
80103230:	55                   	push   %ebp
80103231:	89 e5                	mov    %esp,%ebp
80103233:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80103236:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
8010323b:	85 c0                	test   %eax,%eax
8010323d:	75 05                	jne    80103244 <lapicinit+0x14>
    return;
8010323f:	e9 43 01 00 00       	jmp    80103387 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103244:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010324b:	00 
8010324c:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103253:	e8 b7 ff ff ff       	call   8010320f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103258:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010325f:	00 
80103260:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103267:	e8 a3 ff ff ff       	call   8010320f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010326c:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103273:	00 
80103274:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010327b:	e8 8f ff ff ff       	call   8010320f <lapicw>
  lapicw(TICR, 10000000);
80103280:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103287:	00 
80103288:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010328f:	e8 7b ff ff ff       	call   8010320f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103294:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010329b:	00 
8010329c:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801032a3:	e8 67 ff ff ff       	call   8010320f <lapicw>
  lapicw(LINT1, MASKED);
801032a8:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801032af:	00 
801032b0:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801032b7:	e8 53 ff ff ff       	call   8010320f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801032bc:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
801032c1:	83 c0 30             	add    $0x30,%eax
801032c4:	8b 00                	mov    (%eax),%eax
801032c6:	c1 e8 10             	shr    $0x10,%eax
801032c9:	0f b6 c0             	movzbl %al,%eax
801032cc:	83 f8 03             	cmp    $0x3,%eax
801032cf:	76 14                	jbe    801032e5 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801032d1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801032d8:	00 
801032d9:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801032e0:	e8 2a ff ff ff       	call   8010320f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801032e5:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801032ec:	00 
801032ed:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801032f4:	e8 16 ff ff ff       	call   8010320f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801032f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103300:	00 
80103301:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103308:	e8 02 ff ff ff       	call   8010320f <lapicw>
  lapicw(ESR, 0);
8010330d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103314:	00 
80103315:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010331c:	e8 ee fe ff ff       	call   8010320f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103321:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103328:	00 
80103329:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103330:	e8 da fe ff ff       	call   8010320f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103335:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010333c:	00 
8010333d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103344:	e8 c6 fe ff ff       	call   8010320f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103349:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103350:	00 
80103351:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103358:	e8 b2 fe ff ff       	call   8010320f <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010335d:	90                   	nop
8010335e:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
80103363:	05 00 03 00 00       	add    $0x300,%eax
80103368:	8b 00                	mov    (%eax),%eax
8010336a:	25 00 10 00 00       	and    $0x1000,%eax
8010336f:	85 c0                	test   %eax,%eax
80103371:	75 eb                	jne    8010335e <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103373:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010337a:	00 
8010337b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103382:	e8 88 fe ff ff       	call   8010320f <lapicw>
}
80103387:	c9                   	leave  
80103388:	c3                   	ret    

80103389 <lapicid>:

int
lapicid(void)
{
80103389:	55                   	push   %ebp
8010338a:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010338c:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
80103391:	85 c0                	test   %eax,%eax
80103393:	75 07                	jne    8010339c <lapicid+0x13>
    return 0;
80103395:	b8 00 00 00 00       	mov    $0x0,%eax
8010339a:	eb 0d                	jmp    801033a9 <lapicid+0x20>
  return lapic[ID] >> 24;
8010339c:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
801033a1:	83 c0 20             	add    $0x20,%eax
801033a4:	8b 00                	mov    (%eax),%eax
801033a6:	c1 e8 18             	shr    $0x18,%eax
}
801033a9:	5d                   	pop    %ebp
801033aa:	c3                   	ret    

801033ab <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801033ab:	55                   	push   %ebp
801033ac:	89 e5                	mov    %esp,%ebp
801033ae:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801033b1:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
801033b6:	85 c0                	test   %eax,%eax
801033b8:	74 14                	je     801033ce <lapiceoi+0x23>
    lapicw(EOI, 0);
801033ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801033c1:	00 
801033c2:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801033c9:	e8 41 fe ff ff       	call   8010320f <lapicw>
}
801033ce:	c9                   	leave  
801033cf:	c3                   	ret    

801033d0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
}
801033d3:	5d                   	pop    %ebp
801033d4:	c3                   	ret    

801033d5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033d5:	55                   	push   %ebp
801033d6:	89 e5                	mov    %esp,%ebp
801033d8:	83 ec 1c             	sub    $0x1c,%esp
801033db:	8b 45 08             	mov    0x8(%ebp),%eax
801033de:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033e1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801033e8:	00 
801033e9:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801033f0:	e8 fe fd ff ff       	call   801031f3 <outb>
  outb(CMOS_PORT+1, 0x0A);
801033f5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801033fc:	00 
801033fd:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103404:	e8 ea fd ff ff       	call   801031f3 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103409:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103410:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103413:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103418:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010341b:	8d 50 02             	lea    0x2(%eax),%edx
8010341e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103421:	c1 e8 04             	shr    $0x4,%eax
80103424:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103427:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010342b:	c1 e0 18             	shl    $0x18,%eax
8010342e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103432:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103439:	e8 d1 fd ff ff       	call   8010320f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010343e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103445:	00 
80103446:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010344d:	e8 bd fd ff ff       	call   8010320f <lapicw>
  microdelay(200);
80103452:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103459:	e8 72 ff ff ff       	call   801033d0 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010345e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103465:	00 
80103466:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010346d:	e8 9d fd ff ff       	call   8010320f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103472:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103479:	e8 52 ff ff ff       	call   801033d0 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010347e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103485:	eb 3f                	jmp    801034c6 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103487:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010348b:	c1 e0 18             	shl    $0x18,%eax
8010348e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103492:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103499:	e8 71 fd ff ff       	call   8010320f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010349e:	8b 45 0c             	mov    0xc(%ebp),%eax
801034a1:	c1 e8 0c             	shr    $0xc,%eax
801034a4:	80 cc 06             	or     $0x6,%ah
801034a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801034ab:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801034b2:	e8 58 fd ff ff       	call   8010320f <lapicw>
    microdelay(200);
801034b7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801034be:	e8 0d ff ff ff       	call   801033d0 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801034c3:	ff 45 fc             	incl   -0x4(%ebp)
801034c6:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801034ca:	7e bb                	jle    80103487 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801034cc:	c9                   	leave  
801034cd:	c3                   	ret    

801034ce <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801034ce:	55                   	push   %ebp
801034cf:	89 e5                	mov    %esp,%ebp
801034d1:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801034d4:	8b 45 08             	mov    0x8(%ebp),%eax
801034d7:	0f b6 c0             	movzbl %al,%eax
801034da:	89 44 24 04          	mov    %eax,0x4(%esp)
801034de:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801034e5:	e8 09 fd ff ff       	call   801031f3 <outb>
  microdelay(200);
801034ea:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801034f1:	e8 da fe ff ff       	call   801033d0 <microdelay>

  return inb(CMOS_RETURN);
801034f6:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801034fd:	e8 d6 fc ff ff       	call   801031d8 <inb>
80103502:	0f b6 c0             	movzbl %al,%eax
}
80103505:	c9                   	leave  
80103506:	c3                   	ret    

80103507 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103507:	55                   	push   %ebp
80103508:	89 e5                	mov    %esp,%ebp
8010350a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010350d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103514:	e8 b5 ff ff ff       	call   801034ce <cmos_read>
80103519:	8b 55 08             	mov    0x8(%ebp),%edx
8010351c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010351e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103525:	e8 a4 ff ff ff       	call   801034ce <cmos_read>
8010352a:	8b 55 08             	mov    0x8(%ebp),%edx
8010352d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103530:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103537:	e8 92 ff ff ff       	call   801034ce <cmos_read>
8010353c:	8b 55 08             	mov    0x8(%ebp),%edx
8010353f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103542:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103549:	e8 80 ff ff ff       	call   801034ce <cmos_read>
8010354e:	8b 55 08             	mov    0x8(%ebp),%edx
80103551:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103554:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010355b:	e8 6e ff ff ff       	call   801034ce <cmos_read>
80103560:	8b 55 08             	mov    0x8(%ebp),%edx
80103563:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103566:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010356d:	e8 5c ff ff ff       	call   801034ce <cmos_read>
80103572:	8b 55 08             	mov    0x8(%ebp),%edx
80103575:	89 42 14             	mov    %eax,0x14(%edx)
}
80103578:	c9                   	leave  
80103579:	c3                   	ret    

8010357a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010357a:	55                   	push   %ebp
8010357b:	89 e5                	mov    %esp,%ebp
8010357d:	57                   	push   %edi
8010357e:	56                   	push   %esi
8010357f:	53                   	push   %ebx
80103580:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103583:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010358a:	e8 3f ff ff ff       	call   801034ce <cmos_read>
8010358f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103595:	83 e0 04             	and    $0x4,%eax
80103598:	85 c0                	test   %eax,%eax
8010359a:	0f 94 c0             	sete   %al
8010359d:	0f b6 c0             	movzbl %al,%eax
801035a0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801035a3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801035a6:	89 04 24             	mov    %eax,(%esp)
801035a9:	e8 59 ff ff ff       	call   80103507 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801035ae:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801035b5:	e8 14 ff ff ff       	call   801034ce <cmos_read>
801035ba:	25 80 00 00 00       	and    $0x80,%eax
801035bf:	85 c0                	test   %eax,%eax
801035c1:	74 02                	je     801035c5 <cmostime+0x4b>
        continue;
801035c3:	eb 36                	jmp    801035fb <cmostime+0x81>
    fill_rtcdate(&t2);
801035c5:	8d 45 b0             	lea    -0x50(%ebp),%eax
801035c8:	89 04 24             	mov    %eax,(%esp)
801035cb:	e8 37 ff ff ff       	call   80103507 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801035d0:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801035d7:	00 
801035d8:	8d 45 b0             	lea    -0x50(%ebp),%eax
801035db:	89 44 24 04          	mov    %eax,0x4(%esp)
801035df:	8d 45 c8             	lea    -0x38(%ebp),%eax
801035e2:	89 04 24             	mov    %eax,(%esp)
801035e5:	e8 73 24 00 00       	call   80105a5d <memcmp>
801035ea:	85 c0                	test   %eax,%eax
801035ec:	75 0d                	jne    801035fb <cmostime+0x81>
      break;
801035ee:	90                   	nop
  }

  // convert
  if(bcd) {
801035ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801035f3:	0f 84 ac 00 00 00    	je     801036a5 <cmostime+0x12b>
801035f9:	eb 02                	jmp    801035fd <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801035fb:	eb a6                	jmp    801035a3 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103600:	c1 e8 04             	shr    $0x4,%eax
80103603:	89 c2                	mov    %eax,%edx
80103605:	89 d0                	mov    %edx,%eax
80103607:	c1 e0 02             	shl    $0x2,%eax
8010360a:	01 d0                	add    %edx,%eax
8010360c:	01 c0                	add    %eax,%eax
8010360e:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103611:	83 e2 0f             	and    $0xf,%edx
80103614:	01 d0                	add    %edx,%eax
80103616:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103619:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010361c:	c1 e8 04             	shr    $0x4,%eax
8010361f:	89 c2                	mov    %eax,%edx
80103621:	89 d0                	mov    %edx,%eax
80103623:	c1 e0 02             	shl    $0x2,%eax
80103626:	01 d0                	add    %edx,%eax
80103628:	01 c0                	add    %eax,%eax
8010362a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010362d:	83 e2 0f             	and    $0xf,%edx
80103630:	01 d0                	add    %edx,%eax
80103632:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103635:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103638:	c1 e8 04             	shr    $0x4,%eax
8010363b:	89 c2                	mov    %eax,%edx
8010363d:	89 d0                	mov    %edx,%eax
8010363f:	c1 e0 02             	shl    $0x2,%eax
80103642:	01 d0                	add    %edx,%eax
80103644:	01 c0                	add    %eax,%eax
80103646:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103649:	83 e2 0f             	and    $0xf,%edx
8010364c:	01 d0                	add    %edx,%eax
8010364e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103651:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103654:	c1 e8 04             	shr    $0x4,%eax
80103657:	89 c2                	mov    %eax,%edx
80103659:	89 d0                	mov    %edx,%eax
8010365b:	c1 e0 02             	shl    $0x2,%eax
8010365e:	01 d0                	add    %edx,%eax
80103660:	01 c0                	add    %eax,%eax
80103662:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103665:	83 e2 0f             	and    $0xf,%edx
80103668:	01 d0                	add    %edx,%eax
8010366a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
8010366d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103670:	c1 e8 04             	shr    $0x4,%eax
80103673:	89 c2                	mov    %eax,%edx
80103675:	89 d0                	mov    %edx,%eax
80103677:	c1 e0 02             	shl    $0x2,%eax
8010367a:	01 d0                	add    %edx,%eax
8010367c:	01 c0                	add    %eax,%eax
8010367e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103681:	83 e2 0f             	and    $0xf,%edx
80103684:	01 d0                	add    %edx,%eax
80103686:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103689:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010368c:	c1 e8 04             	shr    $0x4,%eax
8010368f:	89 c2                	mov    %eax,%edx
80103691:	89 d0                	mov    %edx,%eax
80103693:	c1 e0 02             	shl    $0x2,%eax
80103696:	01 d0                	add    %edx,%eax
80103698:	01 c0                	add    %eax,%eax
8010369a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010369d:	83 e2 0f             	and    $0xf,%edx
801036a0:	01 d0                	add    %edx,%eax
801036a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801036a5:	8b 45 08             	mov    0x8(%ebp),%eax
801036a8:	89 c2                	mov    %eax,%edx
801036aa:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801036ad:	b8 06 00 00 00       	mov    $0x6,%eax
801036b2:	89 d7                	mov    %edx,%edi
801036b4:	89 de                	mov    %ebx,%esi
801036b6:	89 c1                	mov    %eax,%ecx
801036b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801036ba:	8b 45 08             	mov    0x8(%ebp),%eax
801036bd:	8b 40 14             	mov    0x14(%eax),%eax
801036c0:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	89 50 14             	mov    %edx,0x14(%eax)
}
801036cc:	83 c4 5c             	add    $0x5c,%esp
801036cf:	5b                   	pop    %ebx
801036d0:	5e                   	pop    %esi
801036d1:	5f                   	pop    %edi
801036d2:	5d                   	pop    %ebp
801036d3:	c3                   	ret    

801036d4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801036d4:	55                   	push   %ebp
801036d5:	89 e5                	mov    %esp,%ebp
801036d7:	83 ec 48             	sub    $0x48,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801036da:	c7 44 24 04 c9 9c 10 	movl   $0x80109cc9,0x4(%esp)
801036e1:	80 
801036e2:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801036e9:	e8 74 20 00 00       	call   80105762 <initlock>
  readsb(dev, &sb);
801036ee:	8d 45 d0             	lea    -0x30(%ebp),%eax
801036f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801036f5:	8b 45 08             	mov    0x8(%ebp),%eax
801036f8:	89 04 24             	mov    %eax,(%esp)
801036fb:	e8 c0 dd ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
80103700:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103703:	a3 34 5c 11 80       	mov    %eax,0x80115c34
  log.size = sb.nlog;
80103708:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010370b:	a3 38 5c 11 80       	mov    %eax,0x80115c38
  log.dev = dev;
80103710:	8b 45 08             	mov    0x8(%ebp),%eax
80103713:	a3 44 5c 11 80       	mov    %eax,0x80115c44
  recover_from_log();
80103718:	e8 95 01 00 00       	call   801038b2 <recover_from_log>
}
8010371d:	c9                   	leave  
8010371e:	c3                   	ret    

8010371f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103725:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010372c:	e9 89 00 00 00       	jmp    801037ba <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103731:	8b 15 34 5c 11 80    	mov    0x80115c34,%edx
80103737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373a:	01 d0                	add    %edx,%eax
8010373c:	40                   	inc    %eax
8010373d:	89 c2                	mov    %eax,%edx
8010373f:	a1 44 5c 11 80       	mov    0x80115c44,%eax
80103744:	89 54 24 04          	mov    %edx,0x4(%esp)
80103748:	89 04 24             	mov    %eax,(%esp)
8010374b:	e8 65 ca ff ff       	call   801001b5 <bread>
80103750:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103756:	83 c0 10             	add    $0x10,%eax
80103759:	8b 04 85 0c 5c 11 80 	mov    -0x7feea3f4(,%eax,4),%eax
80103760:	89 c2                	mov    %eax,%edx
80103762:	a1 44 5c 11 80       	mov    0x80115c44,%eax
80103767:	89 54 24 04          	mov    %edx,0x4(%esp)
8010376b:	89 04 24             	mov    %eax,(%esp)
8010376e:	e8 42 ca ff ff       	call   801001b5 <bread>
80103773:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103779:	8d 50 5c             	lea    0x5c(%eax),%edx
8010377c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010377f:	83 c0 5c             	add    $0x5c,%eax
80103782:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103789:	00 
8010378a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010378e:	89 04 24             	mov    %eax,(%esp)
80103791:	e8 19 23 00 00       	call   80105aaf <memmove>
    bwrite(dbuf);  // write dst to disk
80103796:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103799:	89 04 24             	mov    %eax,(%esp)
8010379c:	e8 4b ca ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801037a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037a4:	89 04 24             	mov    %eax,(%esp)
801037a7:	e8 80 ca ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801037ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037af:	89 04 24             	mov    %eax,(%esp)
801037b2:	e8 75 ca ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037b7:	ff 45 f4             	incl   -0xc(%ebp)
801037ba:	a1 48 5c 11 80       	mov    0x80115c48,%eax
801037bf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037c2:	0f 8f 69 ff ff ff    	jg     80103731 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801037c8:	c9                   	leave  
801037c9:	c3                   	ret    

801037ca <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801037ca:	55                   	push   %ebp
801037cb:	89 e5                	mov    %esp,%ebp
801037cd:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801037d0:	a1 34 5c 11 80       	mov    0x80115c34,%eax
801037d5:	89 c2                	mov    %eax,%edx
801037d7:	a1 44 5c 11 80       	mov    0x80115c44,%eax
801037dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801037e0:	89 04 24             	mov    %eax,(%esp)
801037e3:	e8 cd c9 ff ff       	call   801001b5 <bread>
801037e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801037eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ee:	83 c0 5c             	add    $0x5c,%eax
801037f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037f7:	8b 00                	mov    (%eax),%eax
801037f9:	a3 48 5c 11 80       	mov    %eax,0x80115c48
  for (i = 0; i < log.lh.n; i++) {
801037fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103805:	eb 1a                	jmp    80103821 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103807:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010380a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010380d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103811:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103814:	83 c2 10             	add    $0x10,%edx
80103817:	89 04 95 0c 5c 11 80 	mov    %eax,-0x7feea3f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010381e:	ff 45 f4             	incl   -0xc(%ebp)
80103821:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103826:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103829:	7f dc                	jg     80103807 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010382b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010382e:	89 04 24             	mov    %eax,(%esp)
80103831:	e8 f6 c9 ff ff       	call   8010022c <brelse>
}
80103836:	c9                   	leave  
80103837:	c3                   	ret    

80103838 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103838:	55                   	push   %ebp
80103839:	89 e5                	mov    %esp,%ebp
8010383b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010383e:	a1 34 5c 11 80       	mov    0x80115c34,%eax
80103843:	89 c2                	mov    %eax,%edx
80103845:	a1 44 5c 11 80       	mov    0x80115c44,%eax
8010384a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010384e:	89 04 24             	mov    %eax,(%esp)
80103851:	e8 5f c9 ff ff       	call   801001b5 <bread>
80103856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385c:	83 c0 5c             	add    $0x5c,%eax
8010385f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103862:	8b 15 48 5c 11 80    	mov    0x80115c48,%edx
80103868:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010386b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010386d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103874:	eb 1a                	jmp    80103890 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103879:	83 c0 10             	add    $0x10,%eax
8010387c:	8b 0c 85 0c 5c 11 80 	mov    -0x7feea3f4(,%eax,4),%ecx
80103883:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103886:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103889:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010388d:	ff 45 f4             	incl   -0xc(%ebp)
80103890:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103895:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103898:	7f dc                	jg     80103876 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010389a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010389d:	89 04 24             	mov    %eax,(%esp)
801038a0:	e8 47 c9 ff ff       	call   801001ec <bwrite>
  brelse(buf);
801038a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a8:	89 04 24             	mov    %eax,(%esp)
801038ab:	e8 7c c9 ff ff       	call   8010022c <brelse>
}
801038b0:	c9                   	leave  
801038b1:	c3                   	ret    

801038b2 <recover_from_log>:

static void
recover_from_log(void)
{
801038b2:	55                   	push   %ebp
801038b3:	89 e5                	mov    %esp,%ebp
801038b5:	83 ec 08             	sub    $0x8,%esp
  read_head();
801038b8:	e8 0d ff ff ff       	call   801037ca <read_head>
  install_trans(); // if committed, copy from log to disk
801038bd:	e8 5d fe ff ff       	call   8010371f <install_trans>
  log.lh.n = 0;
801038c2:	c7 05 48 5c 11 80 00 	movl   $0x0,0x80115c48
801038c9:	00 00 00 
  write_head(); // clear the log
801038cc:	e8 67 ff ff ff       	call   80103838 <write_head>
}
801038d1:	c9                   	leave  
801038d2:	c3                   	ret    

801038d3 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801038d3:	55                   	push   %ebp
801038d4:	89 e5                	mov    %esp,%ebp
801038d6:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801038d9:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801038e0:	e8 9e 1e 00 00       	call   80105783 <acquire>
  while(1){
    if(log.committing){
801038e5:	a1 40 5c 11 80       	mov    0x80115c40,%eax
801038ea:	85 c0                	test   %eax,%eax
801038ec:	74 16                	je     80103904 <begin_op+0x31>
      sleep(&log, &log.lock);
801038ee:	c7 44 24 04 00 5c 11 	movl   $0x80115c00,0x4(%esp)
801038f5:	80 
801038f6:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801038fd:	e8 82 15 00 00       	call   80104e84 <sleep>
80103902:	eb 4d                	jmp    80103951 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103904:	8b 15 48 5c 11 80    	mov    0x80115c48,%edx
8010390a:	a1 3c 5c 11 80       	mov    0x80115c3c,%eax
8010390f:	8d 48 01             	lea    0x1(%eax),%ecx
80103912:	89 c8                	mov    %ecx,%eax
80103914:	c1 e0 02             	shl    $0x2,%eax
80103917:	01 c8                	add    %ecx,%eax
80103919:	01 c0                	add    %eax,%eax
8010391b:	01 d0                	add    %edx,%eax
8010391d:	83 f8 1e             	cmp    $0x1e,%eax
80103920:	7e 16                	jle    80103938 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103922:	c7 44 24 04 00 5c 11 	movl   $0x80115c00,0x4(%esp)
80103929:	80 
8010392a:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
80103931:	e8 4e 15 00 00       	call   80104e84 <sleep>
80103936:	eb 19                	jmp    80103951 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103938:	a1 3c 5c 11 80       	mov    0x80115c3c,%eax
8010393d:	40                   	inc    %eax
8010393e:	a3 3c 5c 11 80       	mov    %eax,0x80115c3c
      release(&log.lock);
80103943:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
8010394a:	e8 9e 1e 00 00       	call   801057ed <release>
      break;
8010394f:	eb 02                	jmp    80103953 <begin_op+0x80>
    }
  }
80103951:	eb 92                	jmp    801038e5 <begin_op+0x12>
}
80103953:	c9                   	leave  
80103954:	c3                   	ret    

80103955 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103955:	55                   	push   %ebp
80103956:	89 e5                	mov    %esp,%ebp
80103958:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010395b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103962:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
80103969:	e8 15 1e 00 00       	call   80105783 <acquire>
  log.outstanding -= 1;
8010396e:	a1 3c 5c 11 80       	mov    0x80115c3c,%eax
80103973:	48                   	dec    %eax
80103974:	a3 3c 5c 11 80       	mov    %eax,0x80115c3c
  if(log.committing)
80103979:	a1 40 5c 11 80       	mov    0x80115c40,%eax
8010397e:	85 c0                	test   %eax,%eax
80103980:	74 0c                	je     8010398e <end_op+0x39>
    panic("log.committing");
80103982:	c7 04 24 cd 9c 10 80 	movl   $0x80109ccd,(%esp)
80103989:	e8 c6 cb ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010398e:	a1 3c 5c 11 80       	mov    0x80115c3c,%eax
80103993:	85 c0                	test   %eax,%eax
80103995:	75 13                	jne    801039aa <end_op+0x55>
    do_commit = 1;
80103997:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010399e:	c7 05 40 5c 11 80 01 	movl   $0x1,0x80115c40
801039a5:	00 00 00 
801039a8:	eb 0c                	jmp    801039b6 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801039aa:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801039b1:	e8 a5 15 00 00       	call   80104f5b <wakeup>
  }
  release(&log.lock);
801039b6:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801039bd:	e8 2b 1e 00 00       	call   801057ed <release>

  if(do_commit){
801039c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801039c6:	74 33                	je     801039fb <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801039c8:	e8 db 00 00 00       	call   80103aa8 <commit>
    acquire(&log.lock);
801039cd:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801039d4:	e8 aa 1d 00 00       	call   80105783 <acquire>
    log.committing = 0;
801039d9:	c7 05 40 5c 11 80 00 	movl   $0x0,0x80115c40
801039e0:	00 00 00 
    wakeup(&log);
801039e3:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801039ea:	e8 6c 15 00 00       	call   80104f5b <wakeup>
    release(&log.lock);
801039ef:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
801039f6:	e8 f2 1d 00 00       	call   801057ed <release>
  }
}
801039fb:	c9                   	leave  
801039fc:	c3                   	ret    

801039fd <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801039fd:	55                   	push   %ebp
801039fe:	89 e5                	mov    %esp,%ebp
80103a00:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a0a:	e9 89 00 00 00       	jmp    80103a98 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103a0f:	8b 15 34 5c 11 80    	mov    0x80115c34,%edx
80103a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a18:	01 d0                	add    %edx,%eax
80103a1a:	40                   	inc    %eax
80103a1b:	89 c2                	mov    %eax,%edx
80103a1d:	a1 44 5c 11 80       	mov    0x80115c44,%eax
80103a22:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a26:	89 04 24             	mov    %eax,(%esp)
80103a29:	e8 87 c7 ff ff       	call   801001b5 <bread>
80103a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a34:	83 c0 10             	add    $0x10,%eax
80103a37:	8b 04 85 0c 5c 11 80 	mov    -0x7feea3f4(,%eax,4),%eax
80103a3e:	89 c2                	mov    %eax,%edx
80103a40:	a1 44 5c 11 80       	mov    0x80115c44,%eax
80103a45:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a49:	89 04 24             	mov    %eax,(%esp)
80103a4c:	e8 64 c7 ff ff       	call   801001b5 <bread>
80103a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80103a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a5d:	83 c0 5c             	add    $0x5c,%eax
80103a60:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103a67:	00 
80103a68:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a6c:	89 04 24             	mov    %eax,(%esp)
80103a6f:	e8 3b 20 00 00       	call   80105aaf <memmove>
    bwrite(to);  // write the log
80103a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a77:	89 04 24             	mov    %eax,(%esp)
80103a7a:	e8 6d c7 ff ff       	call   801001ec <bwrite>
    brelse(from);
80103a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a82:	89 04 24             	mov    %eax,(%esp)
80103a85:	e8 a2 c7 ff ff       	call   8010022c <brelse>
    brelse(to);
80103a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a8d:	89 04 24             	mov    %eax,(%esp)
80103a90:	e8 97 c7 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a95:	ff 45 f4             	incl   -0xc(%ebp)
80103a98:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103a9d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aa0:	0f 8f 69 ff ff ff    	jg     80103a0f <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103aa6:	c9                   	leave  
80103aa7:	c3                   	ret    

80103aa8 <commit>:

static void
commit()
{
80103aa8:	55                   	push   %ebp
80103aa9:	89 e5                	mov    %esp,%ebp
80103aab:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103aae:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103ab3:	85 c0                	test   %eax,%eax
80103ab5:	7e 1e                	jle    80103ad5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103ab7:	e8 41 ff ff ff       	call   801039fd <write_log>
    write_head();    // Write header to disk -- the real commit
80103abc:	e8 77 fd ff ff       	call   80103838 <write_head>
    install_trans(); // Now install writes to home locations
80103ac1:	e8 59 fc ff ff       	call   8010371f <install_trans>
    log.lh.n = 0;
80103ac6:	c7 05 48 5c 11 80 00 	movl   $0x0,0x80115c48
80103acd:	00 00 00 
    write_head();    // Erase the transaction from the log
80103ad0:	e8 63 fd ff ff       	call   80103838 <write_head>
  }
}
80103ad5:	c9                   	leave  
80103ad6:	c3                   	ret    

80103ad7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103ad7:	55                   	push   %ebp
80103ad8:	89 e5                	mov    %esp,%ebp
80103ada:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103add:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103ae2:	83 f8 1d             	cmp    $0x1d,%eax
80103ae5:	7f 10                	jg     80103af7 <log_write+0x20>
80103ae7:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103aec:	8b 15 38 5c 11 80    	mov    0x80115c38,%edx
80103af2:	4a                   	dec    %edx
80103af3:	39 d0                	cmp    %edx,%eax
80103af5:	7c 0c                	jl     80103b03 <log_write+0x2c>
    panic("too big a transaction");
80103af7:	c7 04 24 dc 9c 10 80 	movl   $0x80109cdc,(%esp)
80103afe:	e8 51 ca ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103b03:	a1 3c 5c 11 80       	mov    0x80115c3c,%eax
80103b08:	85 c0                	test   %eax,%eax
80103b0a:	7f 0c                	jg     80103b18 <log_write+0x41>
    panic("log_write outside of trans");
80103b0c:	c7 04 24 f2 9c 10 80 	movl   $0x80109cf2,(%esp)
80103b13:	e8 3c ca ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103b18:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
80103b1f:	e8 5f 1c 00 00       	call   80105783 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103b24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b2b:	eb 1e                	jmp    80103b4b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b30:	83 c0 10             	add    $0x10,%eax
80103b33:	8b 04 85 0c 5c 11 80 	mov    -0x7feea3f4(,%eax,4),%eax
80103b3a:	89 c2                	mov    %eax,%edx
80103b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b3f:	8b 40 08             	mov    0x8(%eax),%eax
80103b42:	39 c2                	cmp    %eax,%edx
80103b44:	75 02                	jne    80103b48 <log_write+0x71>
      break;
80103b46:	eb 0d                	jmp    80103b55 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103b48:	ff 45 f4             	incl   -0xc(%ebp)
80103b4b:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103b50:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b53:	7f d8                	jg     80103b2d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103b55:	8b 45 08             	mov    0x8(%ebp),%eax
80103b58:	8b 40 08             	mov    0x8(%eax),%eax
80103b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b5e:	83 c2 10             	add    $0x10,%edx
80103b61:	89 04 95 0c 5c 11 80 	mov    %eax,-0x7feea3f4(,%edx,4)
  if (i == log.lh.n)
80103b68:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103b6d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b70:	75 0b                	jne    80103b7d <log_write+0xa6>
    log.lh.n++;
80103b72:	a1 48 5c 11 80       	mov    0x80115c48,%eax
80103b77:	40                   	inc    %eax
80103b78:	a3 48 5c 11 80       	mov    %eax,0x80115c48
  b->flags |= B_DIRTY; // prevent eviction
80103b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b80:	8b 00                	mov    (%eax),%eax
80103b82:	83 c8 04             	or     $0x4,%eax
80103b85:	89 c2                	mov    %eax,%edx
80103b87:	8b 45 08             	mov    0x8(%ebp),%eax
80103b8a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103b8c:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
80103b93:	e8 55 1c 00 00       	call   801057ed <release>
}
80103b98:	c9                   	leave  
80103b99:	c3                   	ret    
	...

80103b9c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103b9c:	55                   	push   %ebp
80103b9d:	89 e5                	mov    %esp,%ebp
80103b9f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103ba2:	8b 55 08             	mov    0x8(%ebp),%edx
80103ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103bab:	f0 87 02             	lock xchg %eax,(%edx)
80103bae:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103bb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103bb4:	c9                   	leave  
80103bb5:	c3                   	ret    

80103bb6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103bb6:	55                   	push   %ebp
80103bb7:	89 e5                	mov    %esp,%ebp
80103bb9:	83 e4 f0             	and    $0xfffffff0,%esp
80103bbc:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103bbf:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103bc6:	80 
80103bc7:	c7 04 24 40 8e 11 80 	movl   $0x80118e40,(%esp)
80103bce:	e8 dd f1 ff ff       	call   80102db0 <kinit1>
  kvmalloc();      // kernel page table
80103bd3:	e8 97 4f 00 00       	call   80108b6f <kvmalloc>
  mpinit();        // detect other processors
80103bd8:	e8 cc 03 00 00       	call   80103fa9 <mpinit>
  lapicinit();     // interrupt controller
80103bdd:	e8 4e f6 ff ff       	call   80103230 <lapicinit>
  seginit();       // segment descriptors
80103be2:	e8 70 4a 00 00       	call   80108657 <seginit>
  picinit();       // disable pic
80103be7:	e8 0c 05 00 00       	call   801040f8 <picinit>
  ioapicinit();    // another interrupt controller
80103bec:	e8 dc f0 ff ff       	call   80102ccd <ioapicinit>
  consoleinit();   // console hardware
80103bf1:	e8 f9 cf ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103bf6:	e8 e8 3d 00 00       	call   801079e3 <uartinit>
  pinit();         // process table
80103bfb:	e8 ee 08 00 00       	call   801044ee <pinit>
  tvinit();        // trap vectors
80103c00:	e8 ab 39 00 00       	call   801075b0 <tvinit>
  binit();         // buffer cache
80103c05:	e8 2a c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103c0a:	e8 d7 d4 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103c0f:	e8 c5 ec ff ff       	call   801028d9 <ideinit>
  startothers();   // start other processors
80103c14:	e8 88 00 00 00       	call   80103ca1 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103c19:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103c20:	8e 
80103c21:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103c28:	e8 bb f1 ff ff       	call   80102de8 <kinit2>
  userinit();      // first user process
80103c2d:	e8 dc 0a 00 00       	call   8010470e <userinit>
  container_init();
80103c32:	e8 70 5c 00 00       	call   801098a7 <container_init>
  mpmain();        // finish this processor's setup
80103c37:	e8 1a 00 00 00       	call   80103c56 <mpmain>

80103c3c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103c3c:	55                   	push   %ebp
80103c3d:	89 e5                	mov    %esp,%ebp
80103c3f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103c42:	e8 3f 4f 00 00       	call   80108b86 <switchkvm>
  seginit();
80103c47:	e8 0b 4a 00 00       	call   80108657 <seginit>
  lapicinit();
80103c4c:	e8 df f5 ff ff       	call   80103230 <lapicinit>
  mpmain();
80103c51:	e8 00 00 00 00       	call   80103c56 <mpmain>

80103c56 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103c56:	55                   	push   %ebp
80103c57:	89 e5                	mov    %esp,%ebp
80103c59:	53                   	push   %ebx
80103c5a:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103c5d:	e8 a8 08 00 00       	call   8010450a <cpuid>
80103c62:	89 c3                	mov    %eax,%ebx
80103c64:	e8 a1 08 00 00       	call   8010450a <cpuid>
80103c69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c71:	c7 04 24 0d 9d 10 80 	movl   $0x80109d0d,(%esp)
80103c78:	e8 44 c7 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103c7d:	e8 8b 3a 00 00       	call   8010770d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103c82:	e8 c8 08 00 00       	call   8010454f <mycpu>
80103c87:	05 a0 00 00 00       	add    $0xa0,%eax
80103c8c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103c93:	00 
80103c94:	89 04 24             	mov    %eax,(%esp)
80103c97:	e8 00 ff ff ff       	call   80103b9c <xchg>
  scheduler();     // start running processes
80103c9c:	e8 16 10 00 00       	call   80104cb7 <scheduler>

80103ca1 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103ca1:	55                   	push   %ebp
80103ca2:	89 e5                	mov    %esp,%ebp
80103ca4:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103ca7:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103cae:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80103cb7:	c7 44 24 04 ac d5 10 	movl   $0x8010d5ac,0x4(%esp)
80103cbe:	80 
80103cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc2:	89 04 24             	mov    %eax,(%esp)
80103cc5:	e8 e5 1d 00 00       	call   80105aaf <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103cca:	c7 45 f4 00 5d 11 80 	movl   $0x80115d00,-0xc(%ebp)
80103cd1:	eb 75                	jmp    80103d48 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103cd3:	e8 77 08 00 00       	call   8010454f <mycpu>
80103cd8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cdb:	75 02                	jne    80103cdf <startothers+0x3e>
      continue;
80103cdd:	eb 62                	jmp    80103d41 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103cdf:	e8 5a f2 ff ff       	call   80102f3e <kalloc>
80103ce4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cea:	83 e8 04             	sub    $0x4,%eax
80103ced:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103cf0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103cf6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cfb:	83 e8 08             	sub    $0x8,%eax
80103cfe:	c7 00 3c 3c 10 80    	movl   $0x80103c3c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d07:	8d 50 f4             	lea    -0xc(%eax),%edx
80103d0a:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103d0f:	05 00 00 00 80       	add    $0x80000000,%eax
80103d14:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d19:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d22:	8a 00                	mov    (%eax),%al
80103d24:	0f b6 c0             	movzbl %al,%eax
80103d27:	89 54 24 04          	mov    %edx,0x4(%esp)
80103d2b:	89 04 24             	mov    %eax,(%esp)
80103d2e:	e8 a2 f6 ff ff       	call   801033d5 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103d33:	90                   	nop
80103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d37:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103d3d:	85 c0                	test   %eax,%eax
80103d3f:	74 f3                	je     80103d34 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103d41:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103d48:	a1 80 62 11 80       	mov    0x80116280,%eax
80103d4d:	89 c2                	mov    %eax,%edx
80103d4f:	89 d0                	mov    %edx,%eax
80103d51:	c1 e0 02             	shl    $0x2,%eax
80103d54:	01 d0                	add    %edx,%eax
80103d56:	01 c0                	add    %eax,%eax
80103d58:	01 d0                	add    %edx,%eax
80103d5a:	c1 e0 04             	shl    $0x4,%eax
80103d5d:	05 00 5d 11 80       	add    $0x80115d00,%eax
80103d62:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d65:	0f 87 68 ff ff ff    	ja     80103cd3 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103d6b:	c9                   	leave  
80103d6c:	c3                   	ret    
80103d6d:	00 00                	add    %al,(%eax)
	...

80103d70 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103d70:	55                   	push   %ebp
80103d71:	89 e5                	mov    %esp,%ebp
80103d73:	83 ec 14             	sub    $0x14,%esp
80103d76:	8b 45 08             	mov    0x8(%ebp),%eax
80103d79:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d80:	89 c2                	mov    %eax,%edx
80103d82:	ec                   	in     (%dx),%al
80103d83:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103d86:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103d89:	c9                   	leave  
80103d8a:	c3                   	ret    

80103d8b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d8b:	55                   	push   %ebp
80103d8c:	89 e5                	mov    %esp,%ebp
80103d8e:	83 ec 08             	sub    $0x8,%esp
80103d91:	8b 45 08             	mov    0x8(%ebp),%eax
80103d94:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d97:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d9b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d9e:	8a 45 f8             	mov    -0x8(%ebp),%al
80103da1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103da4:	ee                   	out    %al,(%dx)
}
80103da5:	c9                   	leave  
80103da6:	c3                   	ret    

80103da7 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103da7:	55                   	push   %ebp
80103da8:	89 e5                	mov    %esp,%ebp
80103daa:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103dad:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103db4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103dbb:	eb 13                	jmp    80103dd0 <sum+0x29>
    sum += addr[i];
80103dbd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc3:	01 d0                	add    %edx,%eax
80103dc5:	8a 00                	mov    (%eax),%al
80103dc7:	0f b6 c0             	movzbl %al,%eax
80103dca:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103dcd:	ff 45 fc             	incl   -0x4(%ebp)
80103dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dd3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103dd6:	7c e5                	jl     80103dbd <sum+0x16>
    sum += addr[i];
  return sum;
80103dd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ddb:	c9                   	leave  
80103ddc:	c3                   	ret    

80103ddd <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ddd:	55                   	push   %ebp
80103dde:	89 e5                	mov    %esp,%ebp
80103de0:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103de3:	8b 45 08             	mov    0x8(%ebp),%eax
80103de6:	05 00 00 00 80       	add    $0x80000000,%eax
80103deb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103dee:	8b 55 0c             	mov    0xc(%ebp),%edx
80103df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df4:	01 d0                	add    %edx,%eax
80103df6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dff:	eb 3f                	jmp    80103e40 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103e01:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103e08:	00 
80103e09:	c7 44 24 04 24 9d 10 	movl   $0x80109d24,0x4(%esp)
80103e10:	80 
80103e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e14:	89 04 24             	mov    %eax,(%esp)
80103e17:	e8 41 1c 00 00       	call   80105a5d <memcmp>
80103e1c:	85 c0                	test   %eax,%eax
80103e1e:	75 1c                	jne    80103e3c <mpsearch1+0x5f>
80103e20:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103e27:	00 
80103e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2b:	89 04 24             	mov    %eax,(%esp)
80103e2e:	e8 74 ff ff ff       	call   80103da7 <sum>
80103e33:	84 c0                	test   %al,%al
80103e35:	75 05                	jne    80103e3c <mpsearch1+0x5f>
      return (struct mp*)p;
80103e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3a:	eb 11                	jmp    80103e4d <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e3c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e43:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e46:	72 b9                	jb     80103e01 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e4d:	c9                   	leave  
80103e4e:	c3                   	ret    

80103e4f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e4f:	55                   	push   %ebp
80103e50:	89 e5                	mov    %esp,%ebp
80103e52:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e55:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e5f:	83 c0 0f             	add    $0xf,%eax
80103e62:	8a 00                	mov    (%eax),%al
80103e64:	0f b6 c0             	movzbl %al,%eax
80103e67:	c1 e0 08             	shl    $0x8,%eax
80103e6a:	89 c2                	mov    %eax,%edx
80103e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6f:	83 c0 0e             	add    $0xe,%eax
80103e72:	8a 00                	mov    (%eax),%al
80103e74:	0f b6 c0             	movzbl %al,%eax
80103e77:	09 d0                	or     %edx,%eax
80103e79:	c1 e0 04             	shl    $0x4,%eax
80103e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e83:	74 21                	je     80103ea6 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103e85:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e8c:	00 
80103e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e90:	89 04 24             	mov    %eax,(%esp)
80103e93:	e8 45 ff ff ff       	call   80103ddd <mpsearch1>
80103e98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e9f:	74 4e                	je     80103eef <mpsearch+0xa0>
      return mp;
80103ea1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ea4:	eb 5d                	jmp    80103f03 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea9:	83 c0 14             	add    $0x14,%eax
80103eac:	8a 00                	mov    (%eax),%al
80103eae:	0f b6 c0             	movzbl %al,%eax
80103eb1:	c1 e0 08             	shl    $0x8,%eax
80103eb4:	89 c2                	mov    %eax,%edx
80103eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb9:	83 c0 13             	add    $0x13,%eax
80103ebc:	8a 00                	mov    (%eax),%al
80103ebe:	0f b6 c0             	movzbl %al,%eax
80103ec1:	09 d0                	or     %edx,%eax
80103ec3:	c1 e0 0a             	shl    $0xa,%eax
80103ec6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ecc:	2d 00 04 00 00       	sub    $0x400,%eax
80103ed1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ed8:	00 
80103ed9:	89 04 24             	mov    %eax,(%esp)
80103edc:	e8 fc fe ff ff       	call   80103ddd <mpsearch1>
80103ee1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ee4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ee8:	74 05                	je     80103eef <mpsearch+0xa0>
      return mp;
80103eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eed:	eb 14                	jmp    80103f03 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103eef:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ef6:	00 
80103ef7:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103efe:	e8 da fe ff ff       	call   80103ddd <mpsearch1>
}
80103f03:	c9                   	leave  
80103f04:	c3                   	ret    

80103f05 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103f05:	55                   	push   %ebp
80103f06:	89 e5                	mov    %esp,%ebp
80103f08:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103f0b:	e8 3f ff ff ff       	call   80103e4f <mpsearch>
80103f10:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f13:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f17:	74 0a                	je     80103f23 <mpconfig+0x1e>
80103f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1c:	8b 40 04             	mov    0x4(%eax),%eax
80103f1f:	85 c0                	test   %eax,%eax
80103f21:	75 07                	jne    80103f2a <mpconfig+0x25>
    return 0;
80103f23:	b8 00 00 00 00       	mov    $0x0,%eax
80103f28:	eb 7d                	jmp    80103fa7 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2d:	8b 40 04             	mov    0x4(%eax),%eax
80103f30:	05 00 00 00 80       	add    $0x80000000,%eax
80103f35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f38:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103f3f:	00 
80103f40:	c7 44 24 04 29 9d 10 	movl   $0x80109d29,0x4(%esp)
80103f47:	80 
80103f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f4b:	89 04 24             	mov    %eax,(%esp)
80103f4e:	e8 0a 1b 00 00       	call   80105a5d <memcmp>
80103f53:	85 c0                	test   %eax,%eax
80103f55:	74 07                	je     80103f5e <mpconfig+0x59>
    return 0;
80103f57:	b8 00 00 00 00       	mov    $0x0,%eax
80103f5c:	eb 49                	jmp    80103fa7 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f61:	8a 40 06             	mov    0x6(%eax),%al
80103f64:	3c 01                	cmp    $0x1,%al
80103f66:	74 11                	je     80103f79 <mpconfig+0x74>
80103f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f6b:	8a 40 06             	mov    0x6(%eax),%al
80103f6e:	3c 04                	cmp    $0x4,%al
80103f70:	74 07                	je     80103f79 <mpconfig+0x74>
    return 0;
80103f72:	b8 00 00 00 00       	mov    $0x0,%eax
80103f77:	eb 2e                	jmp    80103fa7 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f7c:	8b 40 04             	mov    0x4(%eax),%eax
80103f7f:	0f b7 c0             	movzwl %ax,%eax
80103f82:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f89:	89 04 24             	mov    %eax,(%esp)
80103f8c:	e8 16 fe ff ff       	call   80103da7 <sum>
80103f91:	84 c0                	test   %al,%al
80103f93:	74 07                	je     80103f9c <mpconfig+0x97>
    return 0;
80103f95:	b8 00 00 00 00       	mov    $0x0,%eax
80103f9a:	eb 0b                	jmp    80103fa7 <mpconfig+0xa2>
  *pmp = mp;
80103f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa2:	89 10                	mov    %edx,(%eax)
  return conf;
80103fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103fa7:	c9                   	leave  
80103fa8:	c3                   	ret    

80103fa9 <mpinit>:

void
mpinit(void)
{
80103fa9:	55                   	push   %ebp
80103faa:	89 e5                	mov    %esp,%ebp
80103fac:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103faf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103fb2:	89 04 24             	mov    %eax,(%esp)
80103fb5:	e8 4b ff ff ff       	call   80103f05 <mpconfig>
80103fba:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103fbd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103fc1:	75 0c                	jne    80103fcf <mpinit+0x26>
    panic("Expect to run on an SMP");
80103fc3:	c7 04 24 2e 9d 10 80 	movl   $0x80109d2e,(%esp)
80103fca:	e8 85 c5 ff ff       	call   80100554 <panic>
  ismp = 1;
80103fcf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fd9:	8b 40 24             	mov    0x24(%eax),%eax
80103fdc:	a3 e0 5b 11 80       	mov    %eax,0x80115be0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe4:	83 c0 2c             	add    $0x2c,%eax
80103fe7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fed:	8b 40 04             	mov    0x4(%eax),%eax
80103ff0:	0f b7 d0             	movzwl %ax,%edx
80103ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff6:	01 d0                	add    %edx,%eax
80103ff8:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ffb:	eb 7d                	jmp    8010407a <mpinit+0xd1>
    switch(*p){
80103ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104000:	8a 00                	mov    (%eax),%al
80104002:	0f b6 c0             	movzbl %al,%eax
80104005:	83 f8 04             	cmp    $0x4,%eax
80104008:	77 68                	ja     80104072 <mpinit+0xc9>
8010400a:	8b 04 85 68 9d 10 80 	mov    -0x7fef6298(,%eax,4),%eax
80104011:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104016:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80104019:	a1 80 62 11 80       	mov    0x80116280,%eax
8010401e:	83 f8 07             	cmp    $0x7,%eax
80104021:	7f 2c                	jg     8010404f <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80104023:	8b 15 80 62 11 80    	mov    0x80116280,%edx
80104029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010402c:	8a 48 01             	mov    0x1(%eax),%cl
8010402f:	89 d0                	mov    %edx,%eax
80104031:	c1 e0 02             	shl    $0x2,%eax
80104034:	01 d0                	add    %edx,%eax
80104036:	01 c0                	add    %eax,%eax
80104038:	01 d0                	add    %edx,%eax
8010403a:	c1 e0 04             	shl    $0x4,%eax
8010403d:	05 00 5d 11 80       	add    $0x80115d00,%eax
80104042:	88 08                	mov    %cl,(%eax)
        ncpu++;
80104044:	a1 80 62 11 80       	mov    0x80116280,%eax
80104049:	40                   	inc    %eax
8010404a:	a3 80 62 11 80       	mov    %eax,0x80116280
      }
      p += sizeof(struct mpproc);
8010404f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104053:	eb 25                	jmp    8010407a <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104058:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
8010405b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010405e:	8a 40 01             	mov    0x1(%eax),%al
80104061:	a2 e0 5c 11 80       	mov    %al,0x80115ce0
      p += sizeof(struct mpioapic);
80104066:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010406a:	eb 0e                	jmp    8010407a <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010406c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104070:	eb 08                	jmp    8010407a <mpinit+0xd1>
    default:
      ismp = 0;
80104072:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80104079:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010407a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104080:	0f 82 77 ff ff ff    	jb     80103ffd <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80104086:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010408a:	75 0c                	jne    80104098 <mpinit+0xef>
    panic("Didn't find a suitable machine");
8010408c:	c7 04 24 48 9d 10 80 	movl   $0x80109d48,(%esp)
80104093:	e8 bc c4 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80104098:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010409b:	8a 40 0c             	mov    0xc(%eax),%al
8010409e:	84 c0                	test   %al,%al
801040a0:	74 36                	je     801040d8 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801040a2:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801040a9:	00 
801040aa:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801040b1:	e8 d5 fc ff ff       	call   80103d8b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801040b6:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801040bd:	e8 ae fc ff ff       	call   80103d70 <inb>
801040c2:	83 c8 01             	or     $0x1,%eax
801040c5:	0f b6 c0             	movzbl %al,%eax
801040c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801040cc:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801040d3:	e8 b3 fc ff ff       	call   80103d8b <outb>
  }
}
801040d8:	c9                   	leave  
801040d9:	c3                   	ret    
	...

801040dc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801040dc:	55                   	push   %ebp
801040dd:	89 e5                	mov    %esp,%ebp
801040df:	83 ec 08             	sub    $0x8,%esp
801040e2:	8b 45 08             	mov    0x8(%ebp),%eax
801040e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801040e8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801040ec:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801040ef:	8a 45 f8             	mov    -0x8(%ebp),%al
801040f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801040f5:	ee                   	out    %al,(%dx)
}
801040f6:	c9                   	leave  
801040f7:	c3                   	ret    

801040f8 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801040f8:	55                   	push   %ebp
801040f9:	89 e5                	mov    %esp,%ebp
801040fb:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801040fe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104105:	00 
80104106:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010410d:	e8 ca ff ff ff       	call   801040dc <outb>
  outb(IO_PIC2+1, 0xFF);
80104112:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104119:	00 
8010411a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104121:	e8 b6 ff ff ff       	call   801040dc <outb>
}
80104126:	c9                   	leave  
80104127:	c3                   	ret    

80104128 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104128:	55                   	push   %ebp
80104129:	89 e5                	mov    %esp,%ebp
8010412b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
8010412e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104135:	8b 45 0c             	mov    0xc(%ebp),%eax
80104138:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010413e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104141:	8b 10                	mov    (%eax),%edx
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104148:	e8 b5 cf ff ff       	call   80101102 <filealloc>
8010414d:	8b 55 08             	mov    0x8(%ebp),%edx
80104150:	89 02                	mov    %eax,(%edx)
80104152:	8b 45 08             	mov    0x8(%ebp),%eax
80104155:	8b 00                	mov    (%eax),%eax
80104157:	85 c0                	test   %eax,%eax
80104159:	0f 84 c8 00 00 00    	je     80104227 <pipealloc+0xff>
8010415f:	e8 9e cf ff ff       	call   80101102 <filealloc>
80104164:	8b 55 0c             	mov    0xc(%ebp),%edx
80104167:	89 02                	mov    %eax,(%edx)
80104169:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416c:	8b 00                	mov    (%eax),%eax
8010416e:	85 c0                	test   %eax,%eax
80104170:	0f 84 b1 00 00 00    	je     80104227 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104176:	e8 c3 ed ff ff       	call   80102f3e <kalloc>
8010417b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010417e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104182:	75 05                	jne    80104189 <pipealloc+0x61>
    goto bad;
80104184:	e9 9e 00 00 00       	jmp    80104227 <pipealloc+0xff>
  p->readopen = 1;
80104189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104193:	00 00 00 
  p->writeopen = 1;
80104196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104199:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801041a0:	00 00 00 
  p->nwrite = 0;
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801041ad:	00 00 00 
  p->nread = 0;
801041b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b3:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801041ba:	00 00 00 
  initlock(&p->lock, "pipe");
801041bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c0:	c7 44 24 04 7c 9d 10 	movl   $0x80109d7c,0x4(%esp)
801041c7:	80 
801041c8:	89 04 24             	mov    %eax,(%esp)
801041cb:	e8 92 15 00 00       	call   80105762 <initlock>
  (*f0)->type = FD_PIPE;
801041d0:	8b 45 08             	mov    0x8(%ebp),%eax
801041d3:	8b 00                	mov    (%eax),%eax
801041d5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041db:	8b 45 08             	mov    0x8(%ebp),%eax
801041de:	8b 00                	mov    (%eax),%eax
801041e0:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041e4:	8b 45 08             	mov    0x8(%ebp),%eax
801041e7:	8b 00                	mov    (%eax),%eax
801041e9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041ed:	8b 45 08             	mov    0x8(%ebp),%eax
801041f0:	8b 00                	mov    (%eax),%eax
801041f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041f5:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801041fb:	8b 00                	mov    (%eax),%eax
801041fd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104203:	8b 45 0c             	mov    0xc(%ebp),%eax
80104206:	8b 00                	mov    (%eax),%eax
80104208:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010420c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010420f:	8b 00                	mov    (%eax),%eax
80104211:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104215:	8b 45 0c             	mov    0xc(%ebp),%eax
80104218:	8b 00                	mov    (%eax),%eax
8010421a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010421d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104220:	b8 00 00 00 00       	mov    $0x0,%eax
80104225:	eb 42                	jmp    80104269 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104227:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010422b:	74 0b                	je     80104238 <pipealloc+0x110>
    kfree((char*)p);
8010422d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104230:	89 04 24             	mov    %eax,(%esp)
80104233:	e8 17 ec ff ff       	call   80102e4f <kfree>
  if(*f0)
80104238:	8b 45 08             	mov    0x8(%ebp),%eax
8010423b:	8b 00                	mov    (%eax),%eax
8010423d:	85 c0                	test   %eax,%eax
8010423f:	74 0d                	je     8010424e <pipealloc+0x126>
    fileclose(*f0);
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	8b 00                	mov    (%eax),%eax
80104246:	89 04 24             	mov    %eax,(%esp)
80104249:	e8 5c cf ff ff       	call   801011aa <fileclose>
  if(*f1)
8010424e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104251:	8b 00                	mov    (%eax),%eax
80104253:	85 c0                	test   %eax,%eax
80104255:	74 0d                	je     80104264 <pipealloc+0x13c>
    fileclose(*f1);
80104257:	8b 45 0c             	mov    0xc(%ebp),%eax
8010425a:	8b 00                	mov    (%eax),%eax
8010425c:	89 04 24             	mov    %eax,(%esp)
8010425f:	e8 46 cf ff ff       	call   801011aa <fileclose>
  return -1;
80104264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104269:	c9                   	leave  
8010426a:	c3                   	ret    

8010426b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010426b:	55                   	push   %ebp
8010426c:	89 e5                	mov    %esp,%ebp
8010426e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	89 04 24             	mov    %eax,(%esp)
80104277:	e8 07 15 00 00       	call   80105783 <acquire>
  if(writable){
8010427c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104280:	74 1f                	je     801042a1 <pipeclose+0x36>
    p->writeopen = 0;
80104282:	8b 45 08             	mov    0x8(%ebp),%eax
80104285:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010428c:	00 00 00 
    wakeup(&p->nread);
8010428f:	8b 45 08             	mov    0x8(%ebp),%eax
80104292:	05 34 02 00 00       	add    $0x234,%eax
80104297:	89 04 24             	mov    %eax,(%esp)
8010429a:	e8 bc 0c 00 00       	call   80104f5b <wakeup>
8010429f:	eb 1d                	jmp    801042be <pipeclose+0x53>
  } else {
    p->readopen = 0;
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801042ab:	00 00 00 
    wakeup(&p->nwrite);
801042ae:	8b 45 08             	mov    0x8(%ebp),%eax
801042b1:	05 38 02 00 00       	add    $0x238,%eax
801042b6:	89 04 24             	mov    %eax,(%esp)
801042b9:	e8 9d 0c 00 00       	call   80104f5b <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801042be:	8b 45 08             	mov    0x8(%ebp),%eax
801042c1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042c7:	85 c0                	test   %eax,%eax
801042c9:	75 25                	jne    801042f0 <pipeclose+0x85>
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042d4:	85 c0                	test   %eax,%eax
801042d6:	75 18                	jne    801042f0 <pipeclose+0x85>
    release(&p->lock);
801042d8:	8b 45 08             	mov    0x8(%ebp),%eax
801042db:	89 04 24             	mov    %eax,(%esp)
801042de:	e8 0a 15 00 00       	call   801057ed <release>
    kfree((char*)p);
801042e3:	8b 45 08             	mov    0x8(%ebp),%eax
801042e6:	89 04 24             	mov    %eax,(%esp)
801042e9:	e8 61 eb ff ff       	call   80102e4f <kfree>
801042ee:	eb 0b                	jmp    801042fb <pipeclose+0x90>
  } else
    release(&p->lock);
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	89 04 24             	mov    %eax,(%esp)
801042f6:	e8 f2 14 00 00       	call   801057ed <release>
}
801042fb:	c9                   	leave  
801042fc:	c3                   	ret    

801042fd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042fd:	55                   	push   %ebp
801042fe:	89 e5                	mov    %esp,%ebp
80104300:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	89 04 24             	mov    %eax,(%esp)
80104309:	e8 75 14 00 00       	call   80105783 <acquire>
  for(i = 0; i < n; i++){
8010430e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104315:	e9 a3 00 00 00       	jmp    801043bd <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010431a:	eb 56                	jmp    80104372 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
8010431c:	8b 45 08             	mov    0x8(%ebp),%eax
8010431f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104325:	85 c0                	test   %eax,%eax
80104327:	74 0c                	je     80104335 <pipewrite+0x38>
80104329:	e8 a5 02 00 00       	call   801045d3 <myproc>
8010432e:	8b 40 24             	mov    0x24(%eax),%eax
80104331:	85 c0                	test   %eax,%eax
80104333:	74 15                	je     8010434a <pipewrite+0x4d>
        release(&p->lock);
80104335:	8b 45 08             	mov    0x8(%ebp),%eax
80104338:	89 04 24             	mov    %eax,(%esp)
8010433b:	e8 ad 14 00 00       	call   801057ed <release>
        return -1;
80104340:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104345:	e9 9d 00 00 00       	jmp    801043e7 <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010434a:	8b 45 08             	mov    0x8(%ebp),%eax
8010434d:	05 34 02 00 00       	add    $0x234,%eax
80104352:	89 04 24             	mov    %eax,(%esp)
80104355:	e8 01 0c 00 00       	call   80104f5b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010435a:	8b 45 08             	mov    0x8(%ebp),%eax
8010435d:	8b 55 08             	mov    0x8(%ebp),%edx
80104360:	81 c2 38 02 00 00    	add    $0x238,%edx
80104366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010436a:	89 14 24             	mov    %edx,(%esp)
8010436d:	e8 12 0b 00 00       	call   80104e84 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104372:	8b 45 08             	mov    0x8(%ebp),%eax
80104375:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010437b:	8b 45 08             	mov    0x8(%ebp),%eax
8010437e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104384:	05 00 02 00 00       	add    $0x200,%eax
80104389:	39 c2                	cmp    %eax,%edx
8010438b:	74 8f                	je     8010431c <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010438d:	8b 45 08             	mov    0x8(%ebp),%eax
80104390:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104396:	8d 48 01             	lea    0x1(%eax),%ecx
80104399:	8b 55 08             	mov    0x8(%ebp),%edx
8010439c:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801043a2:	25 ff 01 00 00       	and    $0x1ff,%eax
801043a7:	89 c1                	mov    %eax,%ecx
801043a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801043af:	01 d0                	add    %edx,%eax
801043b1:	8a 10                	mov    (%eax),%dl
801043b3:	8b 45 08             	mov    0x8(%ebp),%eax
801043b6:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043ba:	ff 45 f4             	incl   -0xc(%ebp)
801043bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801043c3:	0f 8c 51 ff ff ff    	jl     8010431a <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043c9:	8b 45 08             	mov    0x8(%ebp),%eax
801043cc:	05 34 02 00 00       	add    $0x234,%eax
801043d1:	89 04 24             	mov    %eax,(%esp)
801043d4:	e8 82 0b 00 00       	call   80104f5b <wakeup>
  release(&p->lock);
801043d9:	8b 45 08             	mov    0x8(%ebp),%eax
801043dc:	89 04 24             	mov    %eax,(%esp)
801043df:	e8 09 14 00 00       	call   801057ed <release>
  return n;
801043e4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043e7:	c9                   	leave  
801043e8:	c3                   	ret    

801043e9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043e9:	55                   	push   %ebp
801043ea:	89 e5                	mov    %esp,%ebp
801043ec:	53                   	push   %ebx
801043ed:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801043f0:	8b 45 08             	mov    0x8(%ebp),%eax
801043f3:	89 04 24             	mov    %eax,(%esp)
801043f6:	e8 88 13 00 00       	call   80105783 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043fb:	eb 39                	jmp    80104436 <piperead+0x4d>
    if(myproc()->killed){
801043fd:	e8 d1 01 00 00       	call   801045d3 <myproc>
80104402:	8b 40 24             	mov    0x24(%eax),%eax
80104405:	85 c0                	test   %eax,%eax
80104407:	74 15                	je     8010441e <piperead+0x35>
      release(&p->lock);
80104409:	8b 45 08             	mov    0x8(%ebp),%eax
8010440c:	89 04 24             	mov    %eax,(%esp)
8010440f:	e8 d9 13 00 00       	call   801057ed <release>
      return -1;
80104414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104419:	e9 b3 00 00 00       	jmp    801044d1 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010441e:	8b 45 08             	mov    0x8(%ebp),%eax
80104421:	8b 55 08             	mov    0x8(%ebp),%edx
80104424:	81 c2 34 02 00 00    	add    $0x234,%edx
8010442a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010442e:	89 14 24             	mov    %edx,(%esp)
80104431:	e8 4e 0a 00 00       	call   80104e84 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104436:	8b 45 08             	mov    0x8(%ebp),%eax
80104439:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010443f:	8b 45 08             	mov    0x8(%ebp),%eax
80104442:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104448:	39 c2                	cmp    %eax,%edx
8010444a:	75 0d                	jne    80104459 <piperead+0x70>
8010444c:	8b 45 08             	mov    0x8(%ebp),%eax
8010444f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104455:	85 c0                	test   %eax,%eax
80104457:	75 a4                	jne    801043fd <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104459:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104460:	eb 49                	jmp    801044ab <piperead+0xc2>
    if(p->nread == p->nwrite)
80104462:	8b 45 08             	mov    0x8(%ebp),%eax
80104465:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010446b:	8b 45 08             	mov    0x8(%ebp),%eax
8010446e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104474:	39 c2                	cmp    %eax,%edx
80104476:	75 02                	jne    8010447a <piperead+0x91>
      break;
80104478:	eb 39                	jmp    801044b3 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010447a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104480:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104483:	8b 45 08             	mov    0x8(%ebp),%eax
80104486:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010448c:	8d 48 01             	lea    0x1(%eax),%ecx
8010448f:	8b 55 08             	mov    0x8(%ebp),%edx
80104492:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104498:	25 ff 01 00 00       	and    $0x1ff,%eax
8010449d:	89 c2                	mov    %eax,%edx
8010449f:	8b 45 08             	mov    0x8(%ebp),%eax
801044a2:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801044a6:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044a8:	ff 45 f4             	incl   -0xc(%ebp)
801044ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801044b1:	7c af                	jl     80104462 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044b3:	8b 45 08             	mov    0x8(%ebp),%eax
801044b6:	05 38 02 00 00       	add    $0x238,%eax
801044bb:	89 04 24             	mov    %eax,(%esp)
801044be:	e8 98 0a 00 00       	call   80104f5b <wakeup>
  release(&p->lock);
801044c3:	8b 45 08             	mov    0x8(%ebp),%eax
801044c6:	89 04 24             	mov    %eax,(%esp)
801044c9:	e8 1f 13 00 00       	call   801057ed <release>
  return i;
801044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044d1:	83 c4 24             	add    $0x24,%esp
801044d4:	5b                   	pop    %ebx
801044d5:	5d                   	pop    %ebp
801044d6:	c3                   	ret    
	...

801044d8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044d8:	55                   	push   %ebp
801044d9:	89 e5                	mov    %esp,%ebp
801044db:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044de:	9c                   	pushf  
801044df:	58                   	pop    %eax
801044e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044e6:	c9                   	leave  
801044e7:	c3                   	ret    

801044e8 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044e8:	55                   	push   %ebp
801044e9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044eb:	fb                   	sti    
}
801044ec:	5d                   	pop    %ebp
801044ed:	c3                   	ret    

801044ee <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801044ee:	55                   	push   %ebp
801044ef:	89 e5                	mov    %esp,%ebp
801044f1:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801044f4:	c7 44 24 04 84 9d 10 	movl   $0x80109d84,0x4(%esp)
801044fb:	80 
801044fc:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104503:	e8 5a 12 00 00       	call   80105762 <initlock>
}
80104508:	c9                   	leave  
80104509:	c3                   	ret    

8010450a <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010450a:	55                   	push   %ebp
8010450b:	89 e5                	mov    %esp,%ebp
8010450d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104510:	e8 3a 00 00 00       	call   8010454f <mycpu>
80104515:	89 c2                	mov    %eax,%edx
80104517:	b8 00 5d 11 80       	mov    $0x80115d00,%eax
8010451c:	29 c2                	sub    %eax,%edx
8010451e:	89 d0                	mov    %edx,%eax
80104520:	c1 f8 04             	sar    $0x4,%eax
80104523:	89 c1                	mov    %eax,%ecx
80104525:	89 ca                	mov    %ecx,%edx
80104527:	c1 e2 03             	shl    $0x3,%edx
8010452a:	01 ca                	add    %ecx,%edx
8010452c:	89 d0                	mov    %edx,%eax
8010452e:	c1 e0 05             	shl    $0x5,%eax
80104531:	29 d0                	sub    %edx,%eax
80104533:	c1 e0 02             	shl    $0x2,%eax
80104536:	01 c8                	add    %ecx,%eax
80104538:	c1 e0 03             	shl    $0x3,%eax
8010453b:	01 c8                	add    %ecx,%eax
8010453d:	89 c2                	mov    %eax,%edx
8010453f:	c1 e2 0f             	shl    $0xf,%edx
80104542:	29 c2                	sub    %eax,%edx
80104544:	c1 e2 02             	shl    $0x2,%edx
80104547:	01 ca                	add    %ecx,%edx
80104549:	89 d0                	mov    %edx,%eax
8010454b:	f7 d8                	neg    %eax
}
8010454d:	c9                   	leave  
8010454e:	c3                   	ret    

8010454f <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010454f:	55                   	push   %ebp
80104550:	89 e5                	mov    %esp,%ebp
80104552:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104555:	e8 7e ff ff ff       	call   801044d8 <readeflags>
8010455a:	25 00 02 00 00       	and    $0x200,%eax
8010455f:	85 c0                	test   %eax,%eax
80104561:	74 0c                	je     8010456f <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104563:	c7 04 24 8c 9d 10 80 	movl   $0x80109d8c,(%esp)
8010456a:	e8 e5 bf ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010456f:	e8 15 ee ff ff       	call   80103389 <lapicid>
80104574:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104577:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010457e:	eb 3b                	jmp    801045bb <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104583:	89 d0                	mov    %edx,%eax
80104585:	c1 e0 02             	shl    $0x2,%eax
80104588:	01 d0                	add    %edx,%eax
8010458a:	01 c0                	add    %eax,%eax
8010458c:	01 d0                	add    %edx,%eax
8010458e:	c1 e0 04             	shl    $0x4,%eax
80104591:	05 00 5d 11 80       	add    $0x80115d00,%eax
80104596:	8a 00                	mov    (%eax),%al
80104598:	0f b6 c0             	movzbl %al,%eax
8010459b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010459e:	75 18                	jne    801045b8 <mycpu+0x69>
      return &cpus[i];
801045a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a3:	89 d0                	mov    %edx,%eax
801045a5:	c1 e0 02             	shl    $0x2,%eax
801045a8:	01 d0                	add    %edx,%eax
801045aa:	01 c0                	add    %eax,%eax
801045ac:	01 d0                	add    %edx,%eax
801045ae:	c1 e0 04             	shl    $0x4,%eax
801045b1:	05 00 5d 11 80       	add    $0x80115d00,%eax
801045b6:	eb 19                	jmp    801045d1 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801045b8:	ff 45 f4             	incl   -0xc(%ebp)
801045bb:	a1 80 62 11 80       	mov    0x80116280,%eax
801045c0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801045c3:	7c bb                	jl     80104580 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801045c5:	c7 04 24 b2 9d 10 80 	movl   $0x80109db2,(%esp)
801045cc:	e8 83 bf ff ff       	call   80100554 <panic>
}
801045d1:	c9                   	leave  
801045d2:	c3                   	ret    

801045d3 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801045d3:	55                   	push   %ebp
801045d4:	89 e5                	mov    %esp,%ebp
801045d6:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801045d9:	e8 04 13 00 00       	call   801058e2 <pushcli>
  c = mycpu();
801045de:	e8 6c ff ff ff       	call   8010454f <mycpu>
801045e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801045e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801045ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801045f2:	e8 35 13 00 00       	call   8010592c <popcli>
  return p;
801045f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801045fa:	c9                   	leave  
801045fb:	c3                   	ret    

801045fc <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801045fc:	55                   	push   %ebp
801045fd:	89 e5                	mov    %esp,%ebp
801045ff:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104602:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104609:	e8 75 11 00 00       	call   80105783 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010460e:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
80104615:	eb 53                	jmp    8010466a <allocproc+0x6e>
    if(p->state == UNUSED)
80104617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461a:	8b 40 0c             	mov    0xc(%eax),%eax
8010461d:	85 c0                	test   %eax,%eax
8010461f:	75 42                	jne    80104663 <allocproc+0x67>
      goto found;
80104621:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010462c:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104631:	8d 50 01             	lea    0x1(%eax),%edx
80104634:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
8010463a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010463d:	89 42 10             	mov    %eax,0x10(%edx)


  release(&ptable.lock);
80104640:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104647:	e8 a1 11 00 00       	call   801057ed <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010464c:	e8 ed e8 ff ff       	call   80102f3e <kalloc>
80104651:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104654:	89 42 08             	mov    %eax,0x8(%edx)
80104657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465a:	8b 40 08             	mov    0x8(%eax),%eax
8010465d:	85 c0                	test   %eax,%eax
8010465f:	75 39                	jne    8010469a <allocproc+0x9e>
80104661:	eb 26                	jmp    80104689 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104663:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010466a:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
80104671:	72 a4                	jb     80104617 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104673:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
8010467a:	e8 6e 11 00 00       	call   801057ed <release>
  return 0;
8010467f:	b8 00 00 00 00       	mov    $0x0,%eax
80104684:	e9 83 00 00 00       	jmp    8010470c <allocproc+0x110>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104693:	b8 00 00 00 00       	mov    $0x0,%eax
80104698:	eb 72                	jmp    8010470c <allocproc+0x110>
  }
  sp = p->kstack + KSTACKSIZE;
8010469a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469d:	8b 40 08             	mov    0x8(%eax),%eax
801046a0:	05 00 10 00 00       	add    $0x1000,%eax
801046a5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801046a8:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801046ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046b2:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801046b5:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801046b9:	ba 6c 75 10 80       	mov    $0x8010756c,%edx
801046be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046c1:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801046c3:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801046c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046cd:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	8b 40 1c             	mov    0x1c(%eax),%eax
801046d6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801046dd:	00 
801046de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801046e5:	00 
801046e6:	89 04 24             	mov    %eax,(%esp)
801046e9:	e8 f8 12 00 00       	call   801059e6 <memset>
  p->context->eip = (uint)forkret;
801046ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f1:	8b 40 1c             	mov    0x1c(%eax),%eax
801046f4:	ba 45 4e 10 80       	mov    $0x80104e45,%edx
801046f9:	89 50 10             	mov    %edx,0x10(%eax)

  //p->ticks = 0;
  p->cont = NULL;
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104706:	00 00 00 
  // p->usage = 0;
  return p;
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010470c:	c9                   	leave  
8010470d:	c3                   	ret    

8010470e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010470e:	55                   	push   %ebp
8010470f:	89 e5                	mov    %esp,%ebp
80104711:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104714:	e8 e3 fe ff ff       	call   801045fc <allocproc>
80104719:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010471c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471f:	a3 40 d9 10 80       	mov    %eax,0x8010d940
  if((p->pgdir = setupkvm()) == 0)
80104724:	e8 9d 43 00 00       	call   80108ac6 <setupkvm>
80104729:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010472c:	89 42 04             	mov    %eax,0x4(%edx)
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	8b 40 04             	mov    0x4(%eax),%eax
80104735:	85 c0                	test   %eax,%eax
80104737:	75 0c                	jne    80104745 <userinit+0x37>
    panic("userinit: out of memory?");
80104739:	c7 04 24 c2 9d 10 80 	movl   $0x80109dc2,(%esp)
80104740:	e8 0f be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104745:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010474a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474d:	8b 40 04             	mov    0x4(%eax),%eax
80104750:	89 54 24 08          	mov    %edx,0x8(%esp)
80104754:	c7 44 24 04 80 d5 10 	movl   $0x8010d580,0x4(%esp)
8010475b:	80 
8010475c:	89 04 24             	mov    %eax,(%esp)
8010475f:	e8 c3 45 00 00       	call   80108d27 <inituvm>
  p->sz = PGSIZE;
80104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104767:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104770:	8b 40 18             	mov    0x18(%eax),%eax
80104773:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010477a:	00 
8010477b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104782:	00 
80104783:	89 04 24             	mov    %eax,(%esp)
80104786:	e8 5b 12 00 00       	call   801059e6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010478b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478e:	8b 40 18             	mov    0x18(%eax),%eax
80104791:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479a:	8b 40 18             	mov    0x18(%eax),%eax
8010479d:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801047a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a6:	8b 50 18             	mov    0x18(%eax),%edx
801047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ac:	8b 40 18             	mov    0x18(%eax),%eax
801047af:	8b 40 2c             	mov    0x2c(%eax),%eax
801047b2:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801047b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b9:	8b 50 18             	mov    0x18(%eax),%edx
801047bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bf:	8b 40 18             	mov    0x18(%eax),%eax
801047c2:	8b 40 2c             	mov    0x2c(%eax),%eax
801047c5:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cc:	8b 40 18             	mov    0x18(%eax),%eax
801047cf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d9:	8b 40 18             	mov    0x18(%eax),%eax
801047dc:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801047e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e6:	8b 40 18             	mov    0x18(%eax),%eax
801047e9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801047f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f3:	83 c0 6c             	add    $0x6c,%eax
801047f6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047fd:	00 
801047fe:	c7 44 24 04 db 9d 10 	movl   $0x80109ddb,0x4(%esp)
80104805:	80 
80104806:	89 04 24             	mov    %eax,(%esp)
80104809:	e8 e4 13 00 00       	call   80105bf2 <safestrcpy>
  p->cwd = namei("/");
8010480e:	c7 04 24 e4 9d 10 80 	movl   $0x80109de4,(%esp)
80104815:	e8 b5 df ff ff       	call   801027cf <namei>
8010481a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010481d:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104820:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104827:	e8 57 0f 00 00       	call   80105783 <acquire>

  p->state = RUNNABLE;
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104836:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
8010483d:	e8 ab 0f 00 00       	call   801057ed <release>
}
80104842:	c9                   	leave  
80104843:	c3                   	ret    

80104844 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104844:	55                   	push   %ebp
80104845:	89 e5                	mov    %esp,%ebp
80104847:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
8010484a:	e8 84 fd ff ff       	call   801045d3 <myproc>
8010484f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104855:	8b 00                	mov    (%eax),%eax
80104857:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010485a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010485e:	7e 31                	jle    80104891 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104860:	8b 55 08             	mov    0x8(%ebp),%edx
80104863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104866:	01 c2                	add    %eax,%edx
80104868:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486b:	8b 40 04             	mov    0x4(%eax),%eax
8010486e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104872:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104875:	89 54 24 04          	mov    %edx,0x4(%esp)
80104879:	89 04 24             	mov    %eax,(%esp)
8010487c:	e8 11 46 00 00       	call   80108e92 <allocuvm>
80104881:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104884:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104888:	75 3e                	jne    801048c8 <growproc+0x84>
      return -1;
8010488a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010488f:	eb 4f                	jmp    801048e0 <growproc+0x9c>
  } else if(n < 0){
80104891:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104895:	79 31                	jns    801048c8 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104897:	8b 55 08             	mov    0x8(%ebp),%edx
8010489a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489d:	01 c2                	add    %eax,%edx
8010489f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a2:	8b 40 04             	mov    0x4(%eax),%eax
801048a5:	89 54 24 08          	mov    %edx,0x8(%esp)
801048a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801048b0:	89 04 24             	mov    %eax,(%esp)
801048b3:	e8 f0 46 00 00       	call   80108fa8 <deallocuvm>
801048b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048bf:	75 07                	jne    801048c8 <growproc+0x84>
      return -1;
801048c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c6:	eb 18                	jmp    801048e0 <growproc+0x9c>
  }
  curproc->sz = sz;
801048c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ce:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801048d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d3:	89 04 24             	mov    %eax,(%esp)
801048d6:	e8 c5 42 00 00       	call   80108ba0 <switchuvm>
  return 0;
801048db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048e0:	c9                   	leave  
801048e1:	c3                   	ret    

801048e2 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048e2:	55                   	push   %ebp
801048e3:	89 e5                	mov    %esp,%ebp
801048e5:	57                   	push   %edi
801048e6:	56                   	push   %esi
801048e7:	53                   	push   %ebx
801048e8:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801048eb:	e8 e3 fc ff ff       	call   801045d3 <myproc>
801048f0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048f3:	e8 04 fd ff ff       	call   801045fc <allocproc>
801048f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
801048fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801048ff:	75 0a                	jne    8010490b <fork+0x29>
    return -1;
80104901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104906:	e9 51 01 00 00       	jmp    80104a5c <fork+0x17a>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010490b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490e:	8b 10                	mov    (%eax),%edx
80104910:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104913:	8b 40 04             	mov    0x4(%eax),%eax
80104916:	89 54 24 04          	mov    %edx,0x4(%esp)
8010491a:	89 04 24             	mov    %eax,(%esp)
8010491d:	e8 26 48 00 00       	call   80109148 <copyuvm>
80104922:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104925:	89 42 04             	mov    %eax,0x4(%edx)
80104928:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010492b:	8b 40 04             	mov    0x4(%eax),%eax
8010492e:	85 c0                	test   %eax,%eax
80104930:	75 2c                	jne    8010495e <fork+0x7c>
    kfree(np->kstack);
80104932:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104935:	8b 40 08             	mov    0x8(%eax),%eax
80104938:	89 04 24             	mov    %eax,(%esp)
8010493b:	e8 0f e5 ff ff       	call   80102e4f <kfree>
    np->kstack = 0;
80104940:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104943:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010494a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010494d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104954:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104959:	e9 fe 00 00 00       	jmp    80104a5c <fork+0x17a>
  }
  np->sz = curproc->sz;
8010495e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104961:	8b 10                	mov    (%eax),%edx
80104963:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104966:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104968:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010496b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010496e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104971:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104974:	8b 50 18             	mov    0x18(%eax),%edx
80104977:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010497a:	8b 40 18             	mov    0x18(%eax),%eax
8010497d:	89 c3                	mov    %eax,%ebx
8010497f:	b8 13 00 00 00       	mov    $0x13,%eax
80104984:	89 d7                	mov    %edx,%edi
80104986:	89 de                	mov    %ebx,%esi
80104988:	89 c1                	mov    %eax,%ecx
8010498a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010498c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010498f:	8b 40 18             	mov    0x18(%eax),%eax
80104992:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104999:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801049a0:	eb 36                	jmp    801049d8 <fork+0xf6>
    if(curproc->ofile[i])
801049a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049a8:	83 c2 08             	add    $0x8,%edx
801049ab:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049af:	85 c0                	test   %eax,%eax
801049b1:	74 22                	je     801049d5 <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
801049b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049b9:	83 c2 08             	add    $0x8,%edx
801049bc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049c0:	89 04 24             	mov    %eax,(%esp)
801049c3:	e8 9a c7 ff ff       	call   80101162 <filedup>
801049c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801049ce:	83 c1 08             	add    $0x8,%ecx
801049d1:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801049d5:	ff 45 e4             	incl   -0x1c(%ebp)
801049d8:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049dc:	7e c4                	jle    801049a2 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801049de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049e1:	8b 40 68             	mov    0x68(%eax),%eax
801049e4:	89 04 24             	mov    %eax,(%esp)
801049e7:	e8 09 d1 ff ff       	call   80101af5 <idup>
801049ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049ef:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f5:	8d 50 6c             	lea    0x6c(%eax),%edx
801049f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049fb:	83 c0 6c             	add    $0x6c,%eax
801049fe:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104a05:	00 
80104a06:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a0a:	89 04 24             	mov    %eax,(%esp)
80104a0d:	e8 e0 11 00 00       	call   80105bf2 <safestrcpy>



  pid = np->pid;
80104a12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a15:	8b 40 10             	mov    0x10(%eax),%eax
80104a18:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104a1b:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104a22:	e8 5c 0d 00 00       	call   80105783 <acquire>

  np->state = RUNNABLE;
80104a27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a2a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->ticks = 0;
80104a31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a34:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  np->cont = curproc->cont;
80104a3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a3e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a47:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
80104a4d:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104a54:	e8 94 0d 00 00       	call   801057ed <release>

  return pid;
80104a59:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104a5c:	83 c4 2c             	add    $0x2c,%esp
80104a5f:	5b                   	pop    %ebx
80104a60:	5e                   	pop    %esi
80104a61:	5f                   	pop    %edi
80104a62:	5d                   	pop    %ebp
80104a63:	c3                   	ret    

80104a64 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a64:	55                   	push   %ebp
80104a65:	89 e5                	mov    %esp,%ebp
80104a67:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104a6a:	e8 64 fb ff ff       	call   801045d3 <myproc>
80104a6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a72:	a1 40 d9 10 80       	mov    0x8010d940,%eax
80104a77:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a7a:	75 0c                	jne    80104a88 <exit+0x24>
    panic("init exiting");
80104a7c:	c7 04 24 e6 9d 10 80 	movl   $0x80109de6,(%esp)
80104a83:	e8 cc ba ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a8f:	eb 3a                	jmp    80104acb <exit+0x67>
    if(curproc->ofile[fd]){
80104a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a97:	83 c2 08             	add    $0x8,%edx
80104a9a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a9e:	85 c0                	test   %eax,%eax
80104aa0:	74 26                	je     80104ac8 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104aa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aa8:	83 c2 08             	add    $0x8,%edx
80104aab:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aaf:	89 04 24             	mov    %eax,(%esp)
80104ab2:	e8 f3 c6 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104ab7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aba:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104abd:	83 c2 08             	add    $0x8,%edx
80104ac0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104ac7:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ac8:	ff 45 f0             	incl   -0x10(%ebp)
80104acb:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104acf:	7e c0                	jle    80104a91 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104ad1:	e8 fd ed ff ff       	call   801038d3 <begin_op>
  iput(curproc->cwd);
80104ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad9:	8b 40 68             	mov    0x68(%eax),%eax
80104adc:	89 04 24             	mov    %eax,(%esp)
80104adf:	e8 91 d1 ff ff       	call   80101c75 <iput>
  end_op();
80104ae4:	e8 6c ee ff ff       	call   80103955 <end_op>
  curproc->cwd = 0;
80104ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aec:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104af3:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104afa:	e8 84 0c 00 00       	call   80105783 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b02:	8b 40 14             	mov    0x14(%eax),%eax
80104b05:	89 04 24             	mov    %eax,(%esp)
80104b08:	e8 0d 04 00 00       	call   80104f1a <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b0d:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
80104b14:	eb 36                	jmp    80104b4c <exit+0xe8>
    if(p->parent == curproc){
80104b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b19:	8b 40 14             	mov    0x14(%eax),%eax
80104b1c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104b1f:	75 24                	jne    80104b45 <exit+0xe1>
      p->parent = initproc;
80104b21:	8b 15 40 d9 10 80    	mov    0x8010d940,%edx
80104b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b30:	8b 40 0c             	mov    0xc(%eax),%eax
80104b33:	83 f8 05             	cmp    $0x5,%eax
80104b36:	75 0d                	jne    80104b45 <exit+0xe1>
        wakeup1(initproc);
80104b38:	a1 40 d9 10 80       	mov    0x8010d940,%eax
80104b3d:	89 04 24             	mov    %eax,(%esp)
80104b40:	e8 d5 03 00 00       	call   80104f1a <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b45:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b4c:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
80104b53:	72 c1                	jb     80104b16 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b58:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b5f:	e8 01 02 00 00       	call   80104d65 <sched>
  panic("zombie exit");
80104b64:	c7 04 24 f3 9d 10 80 	movl   $0x80109df3,(%esp)
80104b6b:	e8 e4 b9 ff ff       	call   80100554 <panic>

80104b70 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104b70:	55                   	push   %ebp
80104b71:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104b73:	eb 06                	jmp    80104b7b <strcmp1+0xb>
    p++, q++;
80104b75:	ff 45 08             	incl   0x8(%ebp)
80104b78:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7e:	8a 00                	mov    (%eax),%al
80104b80:	84 c0                	test   %al,%al
80104b82:	74 0e                	je     80104b92 <strcmp1+0x22>
80104b84:	8b 45 08             	mov    0x8(%ebp),%eax
80104b87:	8a 10                	mov    (%eax),%dl
80104b89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8c:	8a 00                	mov    (%eax),%al
80104b8e:	38 c2                	cmp    %al,%dl
80104b90:	74 e3                	je     80104b75 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104b92:	8b 45 08             	mov    0x8(%ebp),%eax
80104b95:	8a 00                	mov    (%eax),%al
80104b97:	0f b6 d0             	movzbl %al,%edx
80104b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9d:	8a 00                	mov    (%eax),%al
80104b9f:	0f b6 c0             	movzbl %al,%eax
80104ba2:	29 c2                	sub    %eax,%edx
80104ba4:	89 d0                	mov    %edx,%eax
}
80104ba6:	5d                   	pop    %ebp
80104ba7:	c3                   	ret    

80104ba8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104ba8:	55                   	push   %ebp
80104ba9:	89 e5                	mov    %esp,%ebp
80104bab:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104bae:	e8 20 fa ff ff       	call   801045d3 <myproc>
80104bb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104bb6:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104bbd:	e8 c1 0b 00 00       	call   80105783 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104bc2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc9:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
80104bd0:	e9 98 00 00 00       	jmp    80104c6d <wait+0xc5>
      if(p->parent != curproc)
80104bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd8:	8b 40 14             	mov    0x14(%eax),%eax
80104bdb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104bde:	74 05                	je     80104be5 <wait+0x3d>
        continue;
80104be0:	e9 81 00 00 00       	jmp    80104c66 <wait+0xbe>
      havekids = 1;
80104be5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bef:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf2:	83 f8 05             	cmp    $0x5,%eax
80104bf5:	75 6f                	jne    80104c66 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfa:	8b 40 10             	mov    0x10(%eax),%eax
80104bfd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c03:	8b 40 08             	mov    0x8(%eax),%eax
80104c06:	89 04 24             	mov    %eax,(%esp)
80104c09:	e8 41 e2 ff ff       	call   80102e4f <kfree>
        p->kstack = 0;
80104c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1b:	8b 40 04             	mov    0x4(%eax),%eax
80104c1e:	89 04 24             	mov    %eax,(%esp)
80104c21:	e8 46 44 00 00       	call   8010906c <freevm>
        p->pid = 0;
80104c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c29:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c33:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c44:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c55:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104c5c:	e8 8c 0b 00 00       	call   801057ed <release>
        return pid;
80104c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c64:	eb 4f                	jmp    80104cb5 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c66:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104c6d:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
80104c74:	0f 82 5b ff ff ff    	jb     80104bd5 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c7e:	74 0a                	je     80104c8a <wait+0xe2>
80104c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c83:	8b 40 24             	mov    0x24(%eax),%eax
80104c86:	85 c0                	test   %eax,%eax
80104c88:	74 13                	je     80104c9d <wait+0xf5>
      release(&ptable.lock);
80104c8a:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104c91:	e8 57 0b 00 00       	call   801057ed <release>
      return -1;
80104c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c9b:	eb 18                	jmp    80104cb5 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c9d:	c7 44 24 04 a0 62 11 	movl   $0x801162a0,0x4(%esp)
80104ca4:	80 
80104ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ca8:	89 04 24             	mov    %eax,(%esp)
80104cab:	e8 d4 01 00 00       	call   80104e84 <sleep>
  }
80104cb0:	e9 0d ff ff ff       	jmp    80104bc2 <wait+0x1a>
}
80104cb5:	c9                   	leave  
80104cb6:	c3                   	ret    

80104cb7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104cb7:	55                   	push   %ebp
80104cb8:	89 e5                	mov    %esp,%ebp
80104cba:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104cbd:	e8 8d f8 ff ff       	call   8010454f <mycpu>
80104cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ccf:	00 00 00 
  //char name[16];
  
  for(;;){
    sti();
80104cd2:	e8 11 f8 ff ff       	call   801044e8 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104cd7:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104cde:	e8 a0 0a 00 00       	call   80105783 <acquire>
    //   cont_1++;
    // }
    // if(holder == 1){
    //   cont_2++;
    // }
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ce3:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
80104cea:	eb 5f                	jmp    80104d4b <scheduler+0x94>
      if(p->state != RUNNABLE){
80104cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cef:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf2:	83 f8 03             	cmp    $0x3,%eax
80104cf5:	74 02                	je     80104cf9 <scheduler+0x42>
        continue;
80104cf7:	eb 4b                	jmp    80104d44 <scheduler+0x8d>
      // }

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cff:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d08:	89 04 24             	mov    %eax,(%esp)
80104d0b:	e8 90 3e 00 00       	call   80108ba0 <switchuvm>
      p->state = RUNNING;
80104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d13:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      //   else{
      //     cprintf("wtf\n");
      //   }
      // }

      swtch(&(c->scheduler), p->context);
80104d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d23:	83 c2 04             	add    $0x4,%edx
80104d26:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d2a:	89 14 24             	mov    %edx,(%esp)
80104d2d:	e8 2e 0f 00 00       	call   80105c60 <swtch>
      switchkvm();
80104d32:	e8 4f 3e 00 00       	call   80108b86 <switchkvm>
      //p->ticks++;

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d41:	00 00 00 
    //   cont_1++;
    // }
    // if(holder == 1){
    //   cont_2++;
    // }
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d44:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104d4b:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
80104d52:	72 98                	jb     80104cec <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104d54:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104d5b:	e8 8d 0a 00 00       	call   801057ed <release>
   // holder++;

  }
80104d60:	e9 6d ff ff ff       	jmp    80104cd2 <scheduler+0x1b>

80104d65 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d65:	55                   	push   %ebp
80104d66:	89 e5                	mov    %esp,%ebp
80104d68:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104d6b:	e8 63 f8 ff ff       	call   801045d3 <myproc>
80104d70:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d73:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104d7a:	e8 32 0b 00 00       	call   801058b1 <holding>
80104d7f:	85 c0                	test   %eax,%eax
80104d81:	75 0c                	jne    80104d8f <sched+0x2a>
    panic("sched ptable.lock");
80104d83:	c7 04 24 ff 9d 10 80 	movl   $0x80109dff,(%esp)
80104d8a:	e8 c5 b7 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104d8f:	e8 bb f7 ff ff       	call   8010454f <mycpu>
80104d94:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d9a:	83 f8 01             	cmp    $0x1,%eax
80104d9d:	74 0c                	je     80104dab <sched+0x46>
    panic("sched locks");
80104d9f:	c7 04 24 11 9e 10 80 	movl   $0x80109e11,(%esp)
80104da6:	e8 a9 b7 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dae:	8b 40 0c             	mov    0xc(%eax),%eax
80104db1:	83 f8 04             	cmp    $0x4,%eax
80104db4:	75 0c                	jne    80104dc2 <sched+0x5d>
    panic("sched running");
80104db6:	c7 04 24 1d 9e 10 80 	movl   $0x80109e1d,(%esp)
80104dbd:	e8 92 b7 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104dc2:	e8 11 f7 ff ff       	call   801044d8 <readeflags>
80104dc7:	25 00 02 00 00       	and    $0x200,%eax
80104dcc:	85 c0                	test   %eax,%eax
80104dce:	74 0c                	je     80104ddc <sched+0x77>
    panic("sched interruptible");
80104dd0:	c7 04 24 2b 9e 10 80 	movl   $0x80109e2b,(%esp)
80104dd7:	e8 78 b7 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104ddc:	e8 6e f7 ff ff       	call   8010454f <mycpu>
80104de1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104de7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104dea:	e8 60 f7 ff ff       	call   8010454f <mycpu>
80104def:	8b 40 04             	mov    0x4(%eax),%eax
80104df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104df5:	83 c2 1c             	add    $0x1c,%edx
80104df8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dfc:	89 14 24             	mov    %edx,(%esp)
80104dff:	e8 5c 0e 00 00       	call   80105c60 <swtch>
  mycpu()->intena = intena;
80104e04:	e8 46 f7 ff ff       	call   8010454f <mycpu>
80104e09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e0c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e12:	c9                   	leave  
80104e13:	c3                   	ret    

80104e14 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e14:	55                   	push   %ebp
80104e15:	89 e5                	mov    %esp,%ebp
80104e17:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e1a:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104e21:	e8 5d 09 00 00       	call   80105783 <acquire>
  myproc()->state = RUNNABLE;
80104e26:	e8 a8 f7 ff ff       	call   801045d3 <myproc>
80104e2b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e32:	e8 2e ff ff ff       	call   80104d65 <sched>
  release(&ptable.lock);
80104e37:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104e3e:	e8 aa 09 00 00       	call   801057ed <release>
}
80104e43:	c9                   	leave  
80104e44:	c3                   	ret    

80104e45 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e45:	55                   	push   %ebp
80104e46:	89 e5                	mov    %esp,%ebp
80104e48:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e4b:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104e52:	e8 96 09 00 00       	call   801057ed <release>

  if (first) {
80104e57:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104e5c:	85 c0                	test   %eax,%eax
80104e5e:	74 22                	je     80104e82 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e60:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104e67:	00 00 00 
    iinit(ROOTDEV);
80104e6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104e71:	e8 e5 c8 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104e76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104e7d:	e8 52 e8 ff ff       	call   801036d4 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e82:	c9                   	leave  
80104e83:	c3                   	ret    

80104e84 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e84:	55                   	push   %ebp
80104e85:	89 e5                	mov    %esp,%ebp
80104e87:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104e8a:	e8 44 f7 ff ff       	call   801045d3 <myproc>
80104e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e96:	75 0c                	jne    80104ea4 <sleep+0x20>
    panic("sleep");
80104e98:	c7 04 24 3f 9e 10 80 	movl   $0x80109e3f,(%esp)
80104e9f:	e8 b0 b6 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104ea4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ea8:	75 0c                	jne    80104eb6 <sleep+0x32>
    panic("sleep without lk");
80104eaa:	c7 04 24 45 9e 10 80 	movl   $0x80109e45,(%esp)
80104eb1:	e8 9e b6 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104eb6:	81 7d 0c a0 62 11 80 	cmpl   $0x801162a0,0xc(%ebp)
80104ebd:	74 17                	je     80104ed6 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ebf:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104ec6:	e8 b8 08 00 00       	call   80105783 <acquire>
    release(lk);
80104ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ece:	89 04 24             	mov    %eax,(%esp)
80104ed1:	e8 17 09 00 00       	call   801057ed <release>
  }
  // Go to sleep.
  p->chan = chan;
80104ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed9:	8b 55 08             	mov    0x8(%ebp),%edx
80104edc:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee2:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ee9:	e8 77 fe ff ff       	call   80104d65 <sched>

  // Tidy up.
  p->chan = 0;
80104eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ef8:	81 7d 0c a0 62 11 80 	cmpl   $0x801162a0,0xc(%ebp)
80104eff:	74 17                	je     80104f18 <sleep+0x94>
    release(&ptable.lock);
80104f01:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104f08:	e8 e0 08 00 00       	call   801057ed <release>
    acquire(lk);
80104f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f10:	89 04 24             	mov    %eax,(%esp)
80104f13:	e8 6b 08 00 00       	call   80105783 <acquire>
  }
}
80104f18:	c9                   	leave  
80104f19:	c3                   	ret    

80104f1a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f1a:	55                   	push   %ebp
80104f1b:	89 e5                	mov    %esp,%ebp
80104f1d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f20:	c7 45 fc d4 62 11 80 	movl   $0x801162d4,-0x4(%ebp)
80104f27:	eb 27                	jmp    80104f50 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f2c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f2f:	83 f8 02             	cmp    $0x2,%eax
80104f32:	75 15                	jne    80104f49 <wakeup1+0x2f>
80104f34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f37:	8b 40 20             	mov    0x20(%eax),%eax
80104f3a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f3d:	75 0a                	jne    80104f49 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104f3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f42:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f49:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104f50:	81 7d fc d4 84 11 80 	cmpl   $0x801184d4,-0x4(%ebp)
80104f57:	72 d0                	jb     80104f29 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104f59:	c9                   	leave  
80104f5a:	c3                   	ret    

80104f5b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f5b:	55                   	push   %ebp
80104f5c:	89 e5                	mov    %esp,%ebp
80104f5e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f61:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104f68:	e8 16 08 00 00       	call   80105783 <acquire>
  wakeup1(chan);
80104f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f70:	89 04 24             	mov    %eax,(%esp)
80104f73:	e8 a2 ff ff ff       	call   80104f1a <wakeup1>
  release(&ptable.lock);
80104f78:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104f7f:	e8 69 08 00 00       	call   801057ed <release>
}
80104f84:	c9                   	leave  
80104f85:	c3                   	ret    

80104f86 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f86:	55                   	push   %ebp
80104f87:	89 e5                	mov    %esp,%ebp
80104f89:	53                   	push   %ebx
80104f8a:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  
  acquire(&ptable.lock);
80104f8d:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80104f94:	e8 ea 07 00 00       	call   80105783 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f99:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
80104fa0:	e9 9c 00 00 00       	jmp    80105041 <kill+0xbb>
    if(p->pid == pid){
80104fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa8:	8b 40 10             	mov    0x10(%eax),%eax
80104fab:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fae:	0f 85 86 00 00 00    	jne    8010503a <kill+0xb4>
      if(myproc()->cont != NULL){
80104fb4:	e8 1a f6 ff ff       	call   801045d3 <myproc>
80104fb9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fbf:	85 c0                	test   %eax,%eax
80104fc1:	74 45                	je     80105008 <kill+0x82>
        if(p->cont == NULL || strcmp1(myproc()->cont->name, p->cont->name) != 0 ){
80104fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fcc:	85 c0                	test   %eax,%eax
80104fce:	74 2a                	je     80104ffa <kill+0x74>
80104fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fd9:	8d 58 1c             	lea    0x1c(%eax),%ebx
80104fdc:	e8 f2 f5 ff ff       	call   801045d3 <myproc>
80104fe1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fe7:	83 c0 1c             	add    $0x1c,%eax
80104fea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80104fee:	89 04 24             	mov    %eax,(%esp)
80104ff1:	e8 7a fb ff ff       	call   80104b70 <strcmp1>
80104ff6:	85 c0                	test   %eax,%eax
80104ff8:	74 0e                	je     80105008 <kill+0x82>
          cprintf(" el oh el You are not authorized to do this.\n");
80104ffa:	c7 04 24 58 9e 10 80 	movl   $0x80109e58,(%esp)
80105001:	e8 bb b3 ff ff       	call   801003c1 <cprintf>
          break;
80105006:	eb 46                	jmp    8010504e <kill+0xc8>
        }
      }
      p->killed = 1;
80105008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105015:	8b 40 0c             	mov    0xc(%eax),%eax
80105018:	83 f8 02             	cmp    $0x2,%eax
8010501b:	75 0a                	jne    80105027 <kill+0xa1>
        p->state = RUNNABLE;
8010501d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105020:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105027:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
8010502e:	e8 ba 07 00 00       	call   801057ed <release>
      return 0;
80105033:	b8 00 00 00 00       	mov    $0x0,%eax
80105038:	eb 25                	jmp    8010505f <kill+0xd9>
kill(int pid)
{
  struct proc *p;
  
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010503a:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105041:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
80105048:	0f 82 57 ff ff ff    	jb     80104fa5 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010504e:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80105055:	e8 93 07 00 00       	call   801057ed <release>
  return -1;
8010505a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010505f:	83 c4 24             	add    $0x24,%esp
80105062:	5b                   	pop    %ebx
80105063:	5d                   	pop    %ebp
80105064:	c3                   	ret    

80105065 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105065:	55                   	push   %ebp
80105066:	89 e5                	mov    %esp,%ebp
80105068:	53                   	push   %ebx
80105069:	83 ec 64             	sub    $0x64,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010506c:	c7 45 f0 d4 62 11 80 	movl   $0x801162d4,-0x10(%ebp)
80105073:	e9 32 01 00 00       	jmp    801051aa <procdump+0x145>
    if(p->state == UNUSED)
80105078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507b:	8b 40 0c             	mov    0xc(%eax),%eax
8010507e:	85 c0                	test   %eax,%eax
80105080:	75 05                	jne    80105087 <procdump+0x22>
      continue;
80105082:	e9 1c 01 00 00       	jmp    801051a3 <procdump+0x13e>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508a:	8b 40 0c             	mov    0xc(%eax),%eax
8010508d:	83 f8 05             	cmp    $0x5,%eax
80105090:	77 23                	ja     801050b5 <procdump+0x50>
80105092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105095:	8b 40 0c             	mov    0xc(%eax),%eax
80105098:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
8010509f:	85 c0                	test   %eax,%eax
801050a1:	74 12                	je     801050b5 <procdump+0x50>
      state = states[p->state];
801050a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a6:	8b 40 0c             	mov    0xc(%eax),%eax
801050a9:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801050b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050b3:	eb 07                	jmp    801050bc <procdump+0x57>
    else
      state = "???";
801050b5:	c7 45 ec 86 9e 10 80 	movl   $0x80109e86,-0x14(%ebp)

    if(p->cont == NULL){
801050bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050bf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801050c5:	85 c0                	test   %eax,%eax
801050c7:	75 33                	jne    801050fc <procdump+0x97>
      cprintf("%d root %s %s TICKS: %d", p->pid, state, p->name, p->ticks);
801050c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050cc:	8b 50 7c             	mov    0x7c(%eax),%edx
801050cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d2:	8d 48 6c             	lea    0x6c(%eax),%ecx
801050d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d8:	8b 40 10             	mov    0x10(%eax),%eax
801050db:	89 54 24 10          	mov    %edx,0x10(%esp)
801050df:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801050e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050e6:	89 54 24 08          	mov    %edx,0x8(%esp)
801050ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801050ee:	c7 04 24 8a 9e 10 80 	movl   $0x80109e8a,(%esp)
801050f5:	e8 c7 b2 ff ff       	call   801003c1 <cprintf>
801050fa:	eb 41                	jmp    8010513d <procdump+0xd8>
    }
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
801050fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ff:	8b 50 7c             	mov    0x7c(%eax),%edx
80105102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105105:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105111:	8d 48 1c             	lea    0x1c(%eax),%ecx
80105114:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105117:	8b 40 10             	mov    0x10(%eax),%eax
8010511a:	89 54 24 14          	mov    %edx,0x14(%esp)
8010511e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80105122:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105125:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105129:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010512d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105131:	c7 04 24 a2 9e 10 80 	movl   $0x80109ea2,(%esp)
80105138:	e8 84 b2 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
8010513d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105140:	8b 40 0c             	mov    0xc(%eax),%eax
80105143:	83 f8 02             	cmp    $0x2,%eax
80105146:	75 4f                	jne    80105197 <procdump+0x132>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010514e:	8b 40 0c             	mov    0xc(%eax),%eax
80105151:	83 c0 08             	add    $0x8,%eax
80105154:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105157:	89 54 24 04          	mov    %edx,0x4(%esp)
8010515b:	89 04 24             	mov    %eax,(%esp)
8010515e:	e8 d7 06 00 00       	call   8010583a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105163:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010516a:	eb 1a                	jmp    80105186 <procdump+0x121>
        cprintf(" %p", pc[i]);
8010516c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105173:	89 44 24 04          	mov    %eax,0x4(%esp)
80105177:	c7 04 24 b8 9e 10 80 	movl   $0x80109eb8,(%esp)
8010517e:	e8 3e b2 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105183:	ff 45 f4             	incl   -0xc(%ebp)
80105186:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010518a:	7f 0b                	jg     80105197 <procdump+0x132>
8010518c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105193:	85 c0                	test   %eax,%eax
80105195:	75 d5                	jne    8010516c <procdump+0x107>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105197:	c7 04 24 bc 9e 10 80 	movl   $0x80109ebc,(%esp)
8010519e:	e8 1e b2 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051a3:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
801051aa:	81 7d f0 d4 84 11 80 	cmpl   $0x801184d4,-0x10(%ebp)
801051b1:	0f 82 c1 fe ff ff    	jb     80105078 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801051b7:	83 c4 64             	add    $0x64,%esp
801051ba:	5b                   	pop    %ebx
801051bb:	5d                   	pop    %ebp
801051bc:	c3                   	ret    

801051bd <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
801051bd:	55                   	push   %ebp
801051be:	89 e5                	mov    %esp,%ebp
801051c0:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051c3:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
801051ca:	eb 37                	jmp    80105203 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
801051cc:	8b 45 08             	mov    0x8(%ebp),%eax
801051cf:	8d 50 1c             	lea    0x1c(%eax),%edx
801051d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051db:	83 c0 1c             	add    $0x1c,%eax
801051de:	89 54 24 04          	mov    %edx,0x4(%esp)
801051e2:	89 04 24             	mov    %eax,(%esp)
801051e5:	e8 86 f9 ff ff       	call   80104b70 <strcmp1>
801051ea:	85 c0                	test   %eax,%eax
801051ec:	75 0e                	jne    801051fc <cstop_container_helper+0x3f>
      kill(p->pid);
801051ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f1:	8b 40 10             	mov    0x10(%eax),%eax
801051f4:	89 04 24             	mov    %eax,(%esp)
801051f7:	e8 8a fd ff ff       	call   80104f86 <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051fc:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105203:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
8010520a:	72 c0                	jb     801051cc <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
8010520c:	8b 45 08             	mov    0x8(%ebp),%eax
8010520f:	83 c0 1c             	add    $0x1c,%eax
80105212:	89 04 24             	mov    %eax,(%esp)
80105215:	e8 03 43 00 00       	call   8010951d <find>
8010521a:	89 04 24             	mov    %eax,(%esp)
8010521d:	e8 31 47 00 00       	call   80109953 <container_reset>
}
80105222:	c9                   	leave  
80105223:	c3                   	ret    

80105224 <cstop_helper>:

void cstop_helper(char* name){
80105224:	55                   	push   %ebp
80105225:	89 e5                	mov    %esp,%ebp
80105227:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010522a:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
80105231:	eb 69                	jmp    8010529c <cstop_helper+0x78>

    if(p->cont == NULL){
80105233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105236:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010523c:	85 c0                	test   %eax,%eax
8010523e:	75 02                	jne    80105242 <cstop_helper+0x1e>
      continue;
80105240:	eb 53                	jmp    80105295 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
80105242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105245:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010524b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010524e:	8b 45 08             	mov    0x8(%ebp),%eax
80105251:	89 44 24 04          	mov    %eax,0x4(%esp)
80105255:	89 14 24             	mov    %edx,(%esp)
80105258:	e8 13 f9 ff ff       	call   80104b70 <strcmp1>
8010525d:	85 c0                	test   %eax,%eax
8010525f:	75 34                	jne    80105295 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80105261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105264:	8b 40 10             	mov    0x10(%eax),%eax
80105267:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010526a:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
80105270:	83 c2 1c             	add    $0x1c,%edx
80105273:	89 44 24 08          	mov    %eax,0x8(%esp)
80105277:	89 54 24 04          	mov    %edx,0x4(%esp)
8010527b:	c7 04 24 c0 9e 10 80 	movl   $0x80109ec0,(%esp)
80105282:	e8 3a b1 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
80105287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528a:	8b 40 10             	mov    0x10(%eax),%eax
8010528d:	89 04 24             	mov    %eax,(%esp)
80105290:	e8 f1 fc ff ff       	call   80104f86 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105295:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010529c:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
801052a3:	72 8e                	jb     80105233 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
801052a5:	8b 45 08             	mov    0x8(%ebp),%eax
801052a8:	89 04 24             	mov    %eax,(%esp)
801052ab:	e8 6d 42 00 00       	call   8010951d <find>
801052b0:	89 04 24             	mov    %eax,(%esp)
801052b3:	e8 9b 46 00 00       	call   80109953 <container_reset>
}
801052b8:	c9                   	leave  
801052b9:	c3                   	ret    

801052ba <c_procdump>:

void
c_procdump(char* name)
{
801052ba:	55                   	push   %ebp
801052bb:	89 e5                	mov    %esp,%ebp
801052bd:	83 ec 38             	sub    $0x38,%esp
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052c0:	c7 45 f4 d4 62 11 80 	movl   $0x801162d4,-0xc(%ebp)
801052c7:	e9 bb 00 00 00       	jmp    80105387 <c_procdump+0xcd>
    if(p->state == UNUSED || p->cont == NULL)
801052cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052cf:	8b 40 0c             	mov    0xc(%eax),%eax
801052d2:	85 c0                	test   %eax,%eax
801052d4:	74 0d                	je     801052e3 <c_procdump+0x29>
801052d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052df:	85 c0                	test   %eax,%eax
801052e1:	75 05                	jne    801052e8 <c_procdump+0x2e>
      continue;
801052e3:	e9 98 00 00 00       	jmp    80105380 <c_procdump+0xc6>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801052e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052eb:	8b 40 0c             	mov    0xc(%eax),%eax
801052ee:	83 f8 05             	cmp    $0x5,%eax
801052f1:	77 23                	ja     80105316 <c_procdump+0x5c>
801052f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f6:	8b 40 0c             	mov    0xc(%eax),%eax
801052f9:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105300:	85 c0                	test   %eax,%eax
80105302:	74 12                	je     80105316 <c_procdump+0x5c>
      state = states[p->state];
80105304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105307:	8b 40 0c             	mov    0xc(%eax),%eax
8010530a:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105311:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105314:	eb 07                	jmp    8010531d <c_procdump+0x63>
    else
      state = "???";
80105316:	c7 45 f0 86 9e 10 80 	movl   $0x80109e86,-0x10(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
8010531d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105320:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105326:	8d 50 1c             	lea    0x1c(%eax),%edx
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
8010532c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105330:	89 14 24             	mov    %edx,(%esp)
80105333:	e8 38 f8 ff ff       	call   80104b70 <strcmp1>
80105338:	85 c0                	test   %eax,%eax
8010533a:	75 44                	jne    80105380 <c_procdump+0xc6>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d", 
8010533c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533f:	8b 50 7c             	mov    0x7c(%eax),%edx
80105342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105345:	8b 40 10             	mov    0x10(%eax),%eax
        name, p->name, p->pid, state, p->ticks);
80105348:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010534b:	83 c1 6c             	add    $0x6c,%ecx
      state = states[p->state];
    else
      state = "???";

    if(strcmp1(p->cont->name, name) == 0){
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d", 
8010534e:	89 54 24 14          	mov    %edx,0x14(%esp)
80105352:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105355:	89 54 24 10          	mov    %edx,0x10(%esp)
80105359:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010535d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105361:	8b 45 08             	mov    0x8(%ebp),%eax
80105364:	89 44 24 04          	mov    %eax,0x4(%esp)
80105368:	c7 04 24 e0 9e 10 80 	movl   $0x80109ee0,(%esp)
8010536f:	e8 4d b0 ff ff       	call   801003c1 <cprintf>
        name, p->name, p->pid, state, p->ticks);
      cprintf("\n");
80105374:	c7 04 24 bc 9e 10 80 	movl   $0x80109ebc,(%esp)
8010537b:	e8 41 b0 ff ff       	call   801003c1 <cprintf>
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105380:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105387:	81 7d f4 d4 84 11 80 	cmpl   $0x801184d4,-0xc(%ebp)
8010538e:	0f 82 38 ff ff ff    	jb     801052cc <c_procdump+0x12>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d", 
        name, p->name, p->pid, state, p->ticks);
      cprintf("\n");
    }  
  }
}
80105394:	c9                   	leave  
80105395:	c3                   	ret    

80105396 <c_proc_data>:

void
c_proc_data(char* name)
{
80105396:	55                   	push   %ebp
80105397:	89 e5                	mov    %esp,%ebp
80105399:	56                   	push   %esi
8010539a:	53                   	push   %ebx
8010539b:	83 ec 30             	sub    $0x30,%esp
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int total = 0;
8010539e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  struct proc *p;
  struct proc *x;
  char *state;
  acquire(&ptable.lock);
801053a5:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
801053ac:	e8 d2 03 00 00       	call   80105783 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053b1:	c7 45 f0 d4 62 11 80 	movl   $0x801162d4,-0x10(%ebp)
801053b8:	e9 82 00 00 00       	jmp    8010543f <c_proc_data+0xa9>
    if(p->state == UNUSED || p->cont == NULL)
801053bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c0:	8b 40 0c             	mov    0xc(%eax),%eax
801053c3:	85 c0                	test   %eax,%eax
801053c5:	74 0d                	je     801053d4 <c_proc_data+0x3e>
801053c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ca:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801053d0:	85 c0                	test   %eax,%eax
801053d2:	75 02                	jne    801053d6 <c_proc_data+0x40>
      continue;
801053d4:	eb 62                	jmp    80105438 <c_proc_data+0xa2>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801053d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d9:	8b 40 0c             	mov    0xc(%eax),%eax
801053dc:	83 f8 05             	cmp    $0x5,%eax
801053df:	77 23                	ja     80105404 <c_proc_data+0x6e>
801053e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e4:	8b 40 0c             	mov    0xc(%eax),%eax
801053e7:	8b 04 85 38 d0 10 80 	mov    -0x7fef2fc8(,%eax,4),%eax
801053ee:	85 c0                	test   %eax,%eax
801053f0:	74 12                	je     80105404 <c_proc_data+0x6e>
      state = states[p->state];
801053f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f5:	8b 40 0c             	mov    0xc(%eax),%eax
801053f8:	8b 04 85 38 d0 10 80 	mov    -0x7fef2fc8(,%eax,4),%eax
801053ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80105402:	eb 07                	jmp    8010540b <c_proc_data+0x75>
    else
      state = "???";
80105404:	c7 45 e8 86 9e 10 80 	movl   $0x80109e86,-0x18(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
8010540b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105414:	8d 50 1c             	lea    0x1c(%eax),%edx
80105417:	8b 45 08             	mov    0x8(%ebp),%eax
8010541a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010541e:	89 14 24             	mov    %edx,(%esp)
80105421:	e8 4a f7 ff ff       	call   80104b70 <strcmp1>
80105426:	85 c0                	test   %eax,%eax
80105428:	75 0e                	jne    80105438 <c_proc_data+0xa2>
      total += p->ticks;
8010542a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542d:	8b 50 7c             	mov    0x7c(%eax),%edx
80105430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105433:	01 d0                	add    %edx,%eax
80105435:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int total = 0;
  struct proc *p;
  struct proc *x;
  char *state;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105438:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
8010543f:	81 7d f0 d4 84 11 80 	cmpl   $0x801184d4,-0x10(%ebp)
80105446:	0f 82 71 ff ff ff    	jb     801053bd <c_proc_data+0x27>

    if(strcmp1(p->cont->name, name) == 0){
      total += p->ticks;
    }
  }
  release(&ptable.lock);
8010544c:	c7 04 24 a0 62 11 80 	movl   $0x801162a0,(%esp)
80105453:	e8 95 03 00 00       	call   801057ed <release>

  for(x = ptable.proc; x < &ptable.proc[NPROC]; x++){
80105458:	c7 45 ec d4 62 11 80 	movl   $0x801162d4,-0x14(%ebp)
8010545f:	e9 dd 00 00 00       	jmp    80105541 <c_proc_data+0x1ab>
    if(x->state == UNUSED || x->cont == NULL)
80105464:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105467:	8b 40 0c             	mov    0xc(%eax),%eax
8010546a:	85 c0                	test   %eax,%eax
8010546c:	74 0d                	je     8010547b <c_proc_data+0xe5>
8010546e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105471:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105477:	85 c0                	test   %eax,%eax
80105479:	75 05                	jne    80105480 <c_proc_data+0xea>
      continue;
8010547b:	e9 ba 00 00 00       	jmp    8010553a <c_proc_data+0x1a4>
    if(x->state >= 0 && x->state < NELEM(states) && states[x->state])
80105480:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105483:	8b 40 0c             	mov    0xc(%eax),%eax
80105486:	83 f8 05             	cmp    $0x5,%eax
80105489:	77 23                	ja     801054ae <c_proc_data+0x118>
8010548b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010548e:	8b 40 0c             	mov    0xc(%eax),%eax
80105491:	8b 04 85 38 d0 10 80 	mov    -0x7fef2fc8(,%eax,4),%eax
80105498:	85 c0                	test   %eax,%eax
8010549a:	74 12                	je     801054ae <c_proc_data+0x118>
      state = states[x->state];
8010549c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010549f:	8b 40 0c             	mov    0xc(%eax),%eax
801054a2:	8b 04 85 38 d0 10 80 	mov    -0x7fef2fc8(,%eax,4),%eax
801054a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
801054ac:	eb 07                	jmp    801054b5 <c_proc_data+0x11f>
    else
      state = "???";
801054ae:	c7 45 e8 86 9e 10 80 	movl   $0x80109e86,-0x18(%ebp)

    if(strcmp1(x->cont->name, name) == 0){
801054b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054b8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801054be:	8d 50 1c             	lea    0x1c(%eax),%edx
801054c1:	8b 45 08             	mov    0x8(%ebp),%eax
801054c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801054c8:	89 14 24             	mov    %edx,(%esp)
801054cb:	e8 a0 f6 ff ff       	call   80104b70 <strcmp1>
801054d0:	85 c0                	test   %eax,%eax
801054d2:	75 66                	jne    8010553a <c_proc_data+0x1a4>
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
801054d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054d7:	8b 50 7c             	mov    0x7c(%eax),%edx
801054da:	89 d0                	mov    %edx,%eax
801054dc:	c1 e0 02             	shl    $0x2,%eax
801054df:	01 d0                	add    %edx,%eax
801054e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054e8:	01 d0                	add    %edx,%eax
801054ea:	c1 e0 02             	shl    $0x2,%eax
      state = states[x->state];
    else
      state = "???";

    if(strcmp1(x->cont->name, name) == 0){
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
801054ed:	8b 75 f4             	mov    -0xc(%ebp),%esi
801054f0:	ba 00 00 00 00       	mov    $0x0,%edx
801054f5:	f7 f6                	div    %esi
801054f7:	89 c1                	mov    %eax,%ecx
801054f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054fc:	8b 50 7c             	mov    0x7c(%eax),%edx
801054ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105502:	8b 40 10             	mov    0x10(%eax),%eax
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
80105505:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80105508:	83 c3 6c             	add    $0x6c,%ebx
      state = states[x->state];
    else
      state = "???";

    if(strcmp1(x->cont->name, name) == 0){
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
8010550b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
8010550f:	89 54 24 10          	mov    %edx,0x10(%esp)
80105513:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105516:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010551a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010551e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80105522:	c7 04 24 1c 9f 10 80 	movl   $0x80109f1c,(%esp)
80105529:	e8 93 ae ff ff       	call   801003c1 <cprintf>
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
      cprintf("\n");
8010552e:	c7 04 24 bc 9e 10 80 	movl   $0x80109ebc,(%esp)
80105535:	e8 87 ae ff ff       	call   801003c1 <cprintf>
      total += p->ticks;
    }
  }
  release(&ptable.lock);

  for(x = ptable.proc; x < &ptable.proc[NPROC]; x++){
8010553a:	81 45 ec 88 00 00 00 	addl   $0x88,-0x14(%ebp)
80105541:	81 7d ec d4 84 11 80 	cmpl   $0x801184d4,-0x14(%ebp)
80105548:	0f 82 16 ff ff ff    	jb     80105464 <c_proc_data+0xce>
      cprintf("     Process: %s PID: %d State: %s Ticks: %d CPU Consumption: %d%%", 
        x->name, x->pid, state, x->ticks, (x->ticks*100/total));
      cprintf("\n");
    }  
  }
}
8010554e:	83 c4 30             	add    $0x30,%esp
80105551:	5b                   	pop    %ebx
80105552:	5e                   	pop    %esi
80105553:	5d                   	pop    %ebp
80105554:	c3                   	ret    

80105555 <pause>:

void
pause(char* name)
{
80105555:	55                   	push   %ebp
80105556:	89 e5                	mov    %esp,%ebp
80105558:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010555b:	c7 45 fc d4 62 11 80 	movl   $0x801162d4,-0x4(%ebp)
80105562:	eb 49                	jmp    801055ad <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
80105564:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105567:	8b 40 0c             	mov    0xc(%eax),%eax
8010556a:	85 c0                	test   %eax,%eax
8010556c:	74 0d                	je     8010557b <pause+0x26>
8010556e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105571:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105577:	85 c0                	test   %eax,%eax
80105579:	75 02                	jne    8010557d <pause+0x28>
      continue;
8010557b:	eb 29                	jmp    801055a6 <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
8010557d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105580:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105586:	8d 50 1c             	lea    0x1c(%eax),%edx
80105589:	8b 45 08             	mov    0x8(%ebp),%eax
8010558c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105590:	89 14 24             	mov    %edx,(%esp)
80105593:	e8 d8 f5 ff ff       	call   80104b70 <strcmp1>
80105598:	85 c0                	test   %eax,%eax
8010559a:	75 0a                	jne    801055a6 <pause+0x51>
      p->state = ZOMBIE;
8010559c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010559f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055a6:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
801055ad:	81 7d fc d4 84 11 80 	cmpl   $0x801184d4,-0x4(%ebp)
801055b4:	72 ae                	jb     80105564 <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = ZOMBIE;
    }
  }
}
801055b6:	c9                   	leave  
801055b7:	c3                   	ret    

801055b8 <resume>:

void
resume(char* name)
{
801055b8:	55                   	push   %ebp
801055b9:	89 e5                	mov    %esp,%ebp
801055bb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055be:	c7 45 fc d4 62 11 80 	movl   $0x801162d4,-0x4(%ebp)
801055c5:	eb 3b                	jmp    80105602 <resume+0x4a>
    if(p->state == ZOMBIE){
801055c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ca:	8b 40 0c             	mov    0xc(%eax),%eax
801055cd:	83 f8 05             	cmp    $0x5,%eax
801055d0:	75 29                	jne    801055fb <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
801055d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801055db:	8d 50 1c             	lea    0x1c(%eax),%edx
801055de:	8b 45 08             	mov    0x8(%ebp),%eax
801055e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801055e5:	89 14 24             	mov    %edx,(%esp)
801055e8:	e8 83 f5 ff ff       	call   80104b70 <strcmp1>
801055ed:	85 c0                	test   %eax,%eax
801055ef:	75 0a                	jne    801055fb <resume+0x43>
        p->state = RUNNABLE;
801055f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055fb:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80105602:	81 7d fc d4 84 11 80 	cmpl   $0x801184d4,-0x4(%ebp)
80105609:	72 bc                	jb     801055c7 <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
8010560b:	c9                   	leave  
8010560c:	c3                   	ret    

8010560d <initp>:


struct proc* initp(void){
8010560d:	55                   	push   %ebp
8010560e:	89 e5                	mov    %esp,%ebp
  return initproc;
80105610:	a1 40 d9 10 80       	mov    0x8010d940,%eax
}
80105615:	5d                   	pop    %ebp
80105616:	c3                   	ret    

80105617 <c_proc>:

struct proc* c_proc(void){
80105617:	55                   	push   %ebp
80105618:	89 e5                	mov    %esp,%ebp
8010561a:	83 ec 08             	sub    $0x8,%esp
  return myproc();
8010561d:	e8 b1 ef ff ff       	call   801045d3 <myproc>
}
80105622:	c9                   	leave  
80105623:	c3                   	ret    

80105624 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105624:	55                   	push   %ebp
80105625:	89 e5                	mov    %esp,%ebp
80105627:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010562a:	8b 45 08             	mov    0x8(%ebp),%eax
8010562d:	83 c0 04             	add    $0x4,%eax
80105630:	c7 44 24 04 89 9f 10 	movl   $0x80109f89,0x4(%esp)
80105637:	80 
80105638:	89 04 24             	mov    %eax,(%esp)
8010563b:	e8 22 01 00 00       	call   80105762 <initlock>
  lk->name = name;
80105640:	8b 45 08             	mov    0x8(%ebp),%eax
80105643:	8b 55 0c             	mov    0xc(%ebp),%edx
80105646:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105649:	8b 45 08             	mov    0x8(%ebp),%eax
8010564c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105652:	8b 45 08             	mov    0x8(%ebp),%eax
80105655:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010565c:	c9                   	leave  
8010565d:	c3                   	ret    

8010565e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010565e:	55                   	push   %ebp
8010565f:	89 e5                	mov    %esp,%ebp
80105661:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105664:	8b 45 08             	mov    0x8(%ebp),%eax
80105667:	83 c0 04             	add    $0x4,%eax
8010566a:	89 04 24             	mov    %eax,(%esp)
8010566d:	e8 11 01 00 00       	call   80105783 <acquire>
  while (lk->locked) {
80105672:	eb 15                	jmp    80105689 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105674:	8b 45 08             	mov    0x8(%ebp),%eax
80105677:	83 c0 04             	add    $0x4,%eax
8010567a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010567e:	8b 45 08             	mov    0x8(%ebp),%eax
80105681:	89 04 24             	mov    %eax,(%esp)
80105684:	e8 fb f7 ff ff       	call   80104e84 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105689:	8b 45 08             	mov    0x8(%ebp),%eax
8010568c:	8b 00                	mov    (%eax),%eax
8010568e:	85 c0                	test   %eax,%eax
80105690:	75 e2                	jne    80105674 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80105692:	8b 45 08             	mov    0x8(%ebp),%eax
80105695:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010569b:	e8 33 ef ff ff       	call   801045d3 <myproc>
801056a0:	8b 50 10             	mov    0x10(%eax),%edx
801056a3:	8b 45 08             	mov    0x8(%ebp),%eax
801056a6:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801056a9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ac:	83 c0 04             	add    $0x4,%eax
801056af:	89 04 24             	mov    %eax,(%esp)
801056b2:	e8 36 01 00 00       	call   801057ed <release>
}
801056b7:	c9                   	leave  
801056b8:	c3                   	ret    

801056b9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801056b9:	55                   	push   %ebp
801056ba:	89 e5                	mov    %esp,%ebp
801056bc:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801056bf:	8b 45 08             	mov    0x8(%ebp),%eax
801056c2:	83 c0 04             	add    $0x4,%eax
801056c5:	89 04 24             	mov    %eax,(%esp)
801056c8:	e8 b6 00 00 00       	call   80105783 <acquire>
  lk->locked = 0;
801056cd:	8b 45 08             	mov    0x8(%ebp),%eax
801056d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801056d6:	8b 45 08             	mov    0x8(%ebp),%eax
801056d9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801056e0:	8b 45 08             	mov    0x8(%ebp),%eax
801056e3:	89 04 24             	mov    %eax,(%esp)
801056e6:	e8 70 f8 ff ff       	call   80104f5b <wakeup>
  release(&lk->lk);
801056eb:	8b 45 08             	mov    0x8(%ebp),%eax
801056ee:	83 c0 04             	add    $0x4,%eax
801056f1:	89 04 24             	mov    %eax,(%esp)
801056f4:	e8 f4 00 00 00       	call   801057ed <release>
}
801056f9:	c9                   	leave  
801056fa:	c3                   	ret    

801056fb <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801056fb:	55                   	push   %ebp
801056fc:	89 e5                	mov    %esp,%ebp
801056fe:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105701:	8b 45 08             	mov    0x8(%ebp),%eax
80105704:	83 c0 04             	add    $0x4,%eax
80105707:	89 04 24             	mov    %eax,(%esp)
8010570a:	e8 74 00 00 00       	call   80105783 <acquire>
  r = lk->locked;
8010570f:	8b 45 08             	mov    0x8(%ebp),%eax
80105712:	8b 00                	mov    (%eax),%eax
80105714:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105717:	8b 45 08             	mov    0x8(%ebp),%eax
8010571a:	83 c0 04             	add    $0x4,%eax
8010571d:	89 04 24             	mov    %eax,(%esp)
80105720:	e8 c8 00 00 00       	call   801057ed <release>
  return r;
80105725:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105728:	c9                   	leave  
80105729:	c3                   	ret    
	...

8010572c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105732:	9c                   	pushf  
80105733:	58                   	pop    %eax
80105734:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105737:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010573a:	c9                   	leave  
8010573b:	c3                   	ret    

8010573c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010573c:	55                   	push   %ebp
8010573d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010573f:	fa                   	cli    
}
80105740:	5d                   	pop    %ebp
80105741:	c3                   	ret    

80105742 <sti>:

static inline void
sti(void)
{
80105742:	55                   	push   %ebp
80105743:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105745:	fb                   	sti    
}
80105746:	5d                   	pop    %ebp
80105747:	c3                   	ret    

80105748 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105748:	55                   	push   %ebp
80105749:	89 e5                	mov    %esp,%ebp
8010574b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010574e:	8b 55 08             	mov    0x8(%ebp),%edx
80105751:	8b 45 0c             	mov    0xc(%ebp),%eax
80105754:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105757:	f0 87 02             	lock xchg %eax,(%edx)
8010575a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010575d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105760:	c9                   	leave  
80105761:	c3                   	ret    

80105762 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105762:	55                   	push   %ebp
80105763:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105765:	8b 45 08             	mov    0x8(%ebp),%eax
80105768:	8b 55 0c             	mov    0xc(%ebp),%edx
8010576b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010576e:	8b 45 08             	mov    0x8(%ebp),%eax
80105771:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105777:	8b 45 08             	mov    0x8(%ebp),%eax
8010577a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105781:	5d                   	pop    %ebp
80105782:	c3                   	ret    

80105783 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105783:	55                   	push   %ebp
80105784:	89 e5                	mov    %esp,%ebp
80105786:	53                   	push   %ebx
80105787:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010578a:	e8 53 01 00 00       	call   801058e2 <pushcli>
  if(holding(lk))
8010578f:	8b 45 08             	mov    0x8(%ebp),%eax
80105792:	89 04 24             	mov    %eax,(%esp)
80105795:	e8 17 01 00 00       	call   801058b1 <holding>
8010579a:	85 c0                	test   %eax,%eax
8010579c:	74 0c                	je     801057aa <acquire+0x27>
    panic("acquire");
8010579e:	c7 04 24 94 9f 10 80 	movl   $0x80109f94,(%esp)
801057a5:	e8 aa ad ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801057aa:	90                   	nop
801057ab:	8b 45 08             	mov    0x8(%ebp),%eax
801057ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801057b5:	00 
801057b6:	89 04 24             	mov    %eax,(%esp)
801057b9:	e8 8a ff ff ff       	call   80105748 <xchg>
801057be:	85 c0                	test   %eax,%eax
801057c0:	75 e9                	jne    801057ab <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801057c2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801057c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
801057ca:	e8 80 ed ff ff       	call   8010454f <mycpu>
801057cf:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801057d2:	8b 45 08             	mov    0x8(%ebp),%eax
801057d5:	83 c0 0c             	add    $0xc,%eax
801057d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801057dc:	8d 45 08             	lea    0x8(%ebp),%eax
801057df:	89 04 24             	mov    %eax,(%esp)
801057e2:	e8 53 00 00 00       	call   8010583a <getcallerpcs>
}
801057e7:	83 c4 14             	add    $0x14,%esp
801057ea:	5b                   	pop    %ebx
801057eb:	5d                   	pop    %ebp
801057ec:	c3                   	ret    

801057ed <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801057ed:	55                   	push   %ebp
801057ee:	89 e5                	mov    %esp,%ebp
801057f0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801057f3:	8b 45 08             	mov    0x8(%ebp),%eax
801057f6:	89 04 24             	mov    %eax,(%esp)
801057f9:	e8 b3 00 00 00       	call   801058b1 <holding>
801057fe:	85 c0                	test   %eax,%eax
80105800:	75 0c                	jne    8010580e <release+0x21>
    panic("release");
80105802:	c7 04 24 9c 9f 10 80 	movl   $0x80109f9c,(%esp)
80105809:	e8 46 ad ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010580e:	8b 45 08             	mov    0x8(%ebp),%eax
80105811:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105818:	8b 45 08             	mov    0x8(%ebp),%eax
8010581b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105822:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105827:	8b 45 08             	mov    0x8(%ebp),%eax
8010582a:	8b 55 08             	mov    0x8(%ebp),%edx
8010582d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105833:	e8 f4 00 00 00       	call   8010592c <popcli>
}
80105838:	c9                   	leave  
80105839:	c3                   	ret    

8010583a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010583a:	55                   	push   %ebp
8010583b:	89 e5                	mov    %esp,%ebp
8010583d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105840:	8b 45 08             	mov    0x8(%ebp),%eax
80105843:	83 e8 08             	sub    $0x8,%eax
80105846:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105849:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105850:	eb 37                	jmp    80105889 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105852:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105856:	74 37                	je     8010588f <getcallerpcs+0x55>
80105858:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010585f:	76 2e                	jbe    8010588f <getcallerpcs+0x55>
80105861:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105865:	74 28                	je     8010588f <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105867:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010586a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105871:	8b 45 0c             	mov    0xc(%ebp),%eax
80105874:	01 c2                	add    %eax,%edx
80105876:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105879:	8b 40 04             	mov    0x4(%eax),%eax
8010587c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010587e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105881:	8b 00                	mov    (%eax),%eax
80105883:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105886:	ff 45 f8             	incl   -0x8(%ebp)
80105889:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010588d:	7e c3                	jle    80105852 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010588f:	eb 18                	jmp    801058a9 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105891:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105894:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010589b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589e:	01 d0                	add    %edx,%eax
801058a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058a6:	ff 45 f8             	incl   -0x8(%ebp)
801058a9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058ad:	7e e2                	jle    80105891 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801058af:	c9                   	leave  
801058b0:	c3                   	ret    

801058b1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801058b1:	55                   	push   %ebp
801058b2:	89 e5                	mov    %esp,%ebp
801058b4:	53                   	push   %ebx
801058b5:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801058b8:	8b 45 08             	mov    0x8(%ebp),%eax
801058bb:	8b 00                	mov    (%eax),%eax
801058bd:	85 c0                	test   %eax,%eax
801058bf:	74 16                	je     801058d7 <holding+0x26>
801058c1:	8b 45 08             	mov    0x8(%ebp),%eax
801058c4:	8b 58 08             	mov    0x8(%eax),%ebx
801058c7:	e8 83 ec ff ff       	call   8010454f <mycpu>
801058cc:	39 c3                	cmp    %eax,%ebx
801058ce:	75 07                	jne    801058d7 <holding+0x26>
801058d0:	b8 01 00 00 00       	mov    $0x1,%eax
801058d5:	eb 05                	jmp    801058dc <holding+0x2b>
801058d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058dc:	83 c4 04             	add    $0x4,%esp
801058df:	5b                   	pop    %ebx
801058e0:	5d                   	pop    %ebp
801058e1:	c3                   	ret    

801058e2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801058e2:	55                   	push   %ebp
801058e3:	89 e5                	mov    %esp,%ebp
801058e5:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801058e8:	e8 3f fe ff ff       	call   8010572c <readeflags>
801058ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801058f0:	e8 47 fe ff ff       	call   8010573c <cli>
  if(mycpu()->ncli == 0)
801058f5:	e8 55 ec ff ff       	call   8010454f <mycpu>
801058fa:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105900:	85 c0                	test   %eax,%eax
80105902:	75 14                	jne    80105918 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105904:	e8 46 ec ff ff       	call   8010454f <mycpu>
80105909:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010590c:	81 e2 00 02 00 00    	and    $0x200,%edx
80105912:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105918:	e8 32 ec ff ff       	call   8010454f <mycpu>
8010591d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105923:	42                   	inc    %edx
80105924:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010592a:	c9                   	leave  
8010592b:	c3                   	ret    

8010592c <popcli>:

void
popcli(void)
{
8010592c:	55                   	push   %ebp
8010592d:	89 e5                	mov    %esp,%ebp
8010592f:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105932:	e8 f5 fd ff ff       	call   8010572c <readeflags>
80105937:	25 00 02 00 00       	and    $0x200,%eax
8010593c:	85 c0                	test   %eax,%eax
8010593e:	74 0c                	je     8010594c <popcli+0x20>
    panic("popcli - interruptible");
80105940:	c7 04 24 a4 9f 10 80 	movl   $0x80109fa4,(%esp)
80105947:	e8 08 ac ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
8010594c:	e8 fe eb ff ff       	call   8010454f <mycpu>
80105951:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105957:	4a                   	dec    %edx
80105958:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010595e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105964:	85 c0                	test   %eax,%eax
80105966:	79 0c                	jns    80105974 <popcli+0x48>
    panic("popcli");
80105968:	c7 04 24 bb 9f 10 80 	movl   $0x80109fbb,(%esp)
8010596f:	e8 e0 ab ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105974:	e8 d6 eb ff ff       	call   8010454f <mycpu>
80105979:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010597f:	85 c0                	test   %eax,%eax
80105981:	75 14                	jne    80105997 <popcli+0x6b>
80105983:	e8 c7 eb ff ff       	call   8010454f <mycpu>
80105988:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010598e:	85 c0                	test   %eax,%eax
80105990:	74 05                	je     80105997 <popcli+0x6b>
    sti();
80105992:	e8 ab fd ff ff       	call   80105742 <sti>
}
80105997:	c9                   	leave  
80105998:	c3                   	ret    
80105999:	00 00                	add    %al,(%eax)
	...

8010599c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010599c:	55                   	push   %ebp
8010599d:	89 e5                	mov    %esp,%ebp
8010599f:	57                   	push   %edi
801059a0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801059a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059a4:	8b 55 10             	mov    0x10(%ebp),%edx
801059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801059aa:	89 cb                	mov    %ecx,%ebx
801059ac:	89 df                	mov    %ebx,%edi
801059ae:	89 d1                	mov    %edx,%ecx
801059b0:	fc                   	cld    
801059b1:	f3 aa                	rep stos %al,%es:(%edi)
801059b3:	89 ca                	mov    %ecx,%edx
801059b5:	89 fb                	mov    %edi,%ebx
801059b7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801059ba:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801059bd:	5b                   	pop    %ebx
801059be:	5f                   	pop    %edi
801059bf:	5d                   	pop    %ebp
801059c0:	c3                   	ret    

801059c1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801059c1:	55                   	push   %ebp
801059c2:	89 e5                	mov    %esp,%ebp
801059c4:	57                   	push   %edi
801059c5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801059c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059c9:	8b 55 10             	mov    0x10(%ebp),%edx
801059cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801059cf:	89 cb                	mov    %ecx,%ebx
801059d1:	89 df                	mov    %ebx,%edi
801059d3:	89 d1                	mov    %edx,%ecx
801059d5:	fc                   	cld    
801059d6:	f3 ab                	rep stos %eax,%es:(%edi)
801059d8:	89 ca                	mov    %ecx,%edx
801059da:	89 fb                	mov    %edi,%ebx
801059dc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801059df:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801059e2:	5b                   	pop    %ebx
801059e3:	5f                   	pop    %edi
801059e4:	5d                   	pop    %ebp
801059e5:	c3                   	ret    

801059e6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801059e6:	55                   	push   %ebp
801059e7:	89 e5                	mov    %esp,%ebp
801059e9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801059ec:	8b 45 08             	mov    0x8(%ebp),%eax
801059ef:	83 e0 03             	and    $0x3,%eax
801059f2:	85 c0                	test   %eax,%eax
801059f4:	75 49                	jne    80105a3f <memset+0x59>
801059f6:	8b 45 10             	mov    0x10(%ebp),%eax
801059f9:	83 e0 03             	and    $0x3,%eax
801059fc:	85 c0                	test   %eax,%eax
801059fe:	75 3f                	jne    80105a3f <memset+0x59>
    c &= 0xFF;
80105a00:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a07:	8b 45 10             	mov    0x10(%ebp),%eax
80105a0a:	c1 e8 02             	shr    $0x2,%eax
80105a0d:	89 c2                	mov    %eax,%edx
80105a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a12:	c1 e0 18             	shl    $0x18,%eax
80105a15:	89 c1                	mov    %eax,%ecx
80105a17:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a1a:	c1 e0 10             	shl    $0x10,%eax
80105a1d:	09 c1                	or     %eax,%ecx
80105a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a22:	c1 e0 08             	shl    $0x8,%eax
80105a25:	09 c8                	or     %ecx,%eax
80105a27:	0b 45 0c             	or     0xc(%ebp),%eax
80105a2a:	89 54 24 08          	mov    %edx,0x8(%esp)
80105a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a32:	8b 45 08             	mov    0x8(%ebp),%eax
80105a35:	89 04 24             	mov    %eax,(%esp)
80105a38:	e8 84 ff ff ff       	call   801059c1 <stosl>
80105a3d:	eb 19                	jmp    80105a58 <memset+0x72>
  } else
    stosb(dst, c, n);
80105a3f:	8b 45 10             	mov    0x10(%ebp),%eax
80105a42:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a46:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a49:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80105a50:	89 04 24             	mov    %eax,(%esp)
80105a53:	e8 44 ff ff ff       	call   8010599c <stosb>
  return dst;
80105a58:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a5b:	c9                   	leave  
80105a5c:	c3                   	ret    

80105a5d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105a5d:	55                   	push   %ebp
80105a5e:	89 e5                	mov    %esp,%ebp
80105a60:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105a63:	8b 45 08             	mov    0x8(%ebp),%eax
80105a66:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105a69:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a6c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105a6f:	eb 2a                	jmp    80105a9b <memcmp+0x3e>
    if(*s1 != *s2)
80105a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a74:	8a 10                	mov    (%eax),%dl
80105a76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a79:	8a 00                	mov    (%eax),%al
80105a7b:	38 c2                	cmp    %al,%dl
80105a7d:	74 16                	je     80105a95 <memcmp+0x38>
      return *s1 - *s2;
80105a7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a82:	8a 00                	mov    (%eax),%al
80105a84:	0f b6 d0             	movzbl %al,%edx
80105a87:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a8a:	8a 00                	mov    (%eax),%al
80105a8c:	0f b6 c0             	movzbl %al,%eax
80105a8f:	29 c2                	sub    %eax,%edx
80105a91:	89 d0                	mov    %edx,%eax
80105a93:	eb 18                	jmp    80105aad <memcmp+0x50>
    s1++, s2++;
80105a95:	ff 45 fc             	incl   -0x4(%ebp)
80105a98:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105a9b:	8b 45 10             	mov    0x10(%ebp),%eax
80105a9e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aa1:	89 55 10             	mov    %edx,0x10(%ebp)
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	75 c9                	jne    80105a71 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aad:	c9                   	leave  
80105aae:	c3                   	ret    

80105aaf <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105aaf:	55                   	push   %ebp
80105ab0:	89 e5                	mov    %esp,%ebp
80105ab2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105abb:	8b 45 08             	mov    0x8(%ebp),%eax
80105abe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ac4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ac7:	73 3a                	jae    80105b03 <memmove+0x54>
80105ac9:	8b 45 10             	mov    0x10(%ebp),%eax
80105acc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105acf:	01 d0                	add    %edx,%eax
80105ad1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ad4:	76 2d                	jbe    80105b03 <memmove+0x54>
    s += n;
80105ad6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad9:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105adc:	8b 45 10             	mov    0x10(%ebp),%eax
80105adf:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105ae2:	eb 10                	jmp    80105af4 <memmove+0x45>
      *--d = *--s;
80105ae4:	ff 4d f8             	decl   -0x8(%ebp)
80105ae7:	ff 4d fc             	decl   -0x4(%ebp)
80105aea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aed:	8a 10                	mov    (%eax),%dl
80105aef:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105af2:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105af4:	8b 45 10             	mov    0x10(%ebp),%eax
80105af7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105afa:	89 55 10             	mov    %edx,0x10(%ebp)
80105afd:	85 c0                	test   %eax,%eax
80105aff:	75 e3                	jne    80105ae4 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b01:	eb 25                	jmp    80105b28 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b03:	eb 16                	jmp    80105b1b <memmove+0x6c>
      *d++ = *s++;
80105b05:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b08:	8d 50 01             	lea    0x1(%eax),%edx
80105b0b:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b0e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b11:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b14:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105b17:	8a 12                	mov    (%edx),%dl
80105b19:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b1b:	8b 45 10             	mov    0x10(%ebp),%eax
80105b1e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b21:	89 55 10             	mov    %edx,0x10(%ebp)
80105b24:	85 c0                	test   %eax,%eax
80105b26:	75 dd                	jne    80105b05 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105b28:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105b2b:	c9                   	leave  
80105b2c:	c3                   	ret    

80105b2d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105b2d:	55                   	push   %ebp
80105b2e:	89 e5                	mov    %esp,%ebp
80105b30:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105b33:	8b 45 10             	mov    0x10(%ebp),%eax
80105b36:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b41:	8b 45 08             	mov    0x8(%ebp),%eax
80105b44:	89 04 24             	mov    %eax,(%esp)
80105b47:	e8 63 ff ff ff       	call   80105aaf <memmove>
}
80105b4c:	c9                   	leave  
80105b4d:	c3                   	ret    

80105b4e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105b4e:	55                   	push   %ebp
80105b4f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105b51:	eb 09                	jmp    80105b5c <strncmp+0xe>
    n--, p++, q++;
80105b53:	ff 4d 10             	decl   0x10(%ebp)
80105b56:	ff 45 08             	incl   0x8(%ebp)
80105b59:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105b5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b60:	74 17                	je     80105b79 <strncmp+0x2b>
80105b62:	8b 45 08             	mov    0x8(%ebp),%eax
80105b65:	8a 00                	mov    (%eax),%al
80105b67:	84 c0                	test   %al,%al
80105b69:	74 0e                	je     80105b79 <strncmp+0x2b>
80105b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6e:	8a 10                	mov    (%eax),%dl
80105b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b73:	8a 00                	mov    (%eax),%al
80105b75:	38 c2                	cmp    %al,%dl
80105b77:	74 da                	je     80105b53 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105b79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b7d:	75 07                	jne    80105b86 <strncmp+0x38>
    return 0;
80105b7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105b84:	eb 14                	jmp    80105b9a <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105b86:	8b 45 08             	mov    0x8(%ebp),%eax
80105b89:	8a 00                	mov    (%eax),%al
80105b8b:	0f b6 d0             	movzbl %al,%edx
80105b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b91:	8a 00                	mov    (%eax),%al
80105b93:	0f b6 c0             	movzbl %al,%eax
80105b96:	29 c2                	sub    %eax,%edx
80105b98:	89 d0                	mov    %edx,%eax
}
80105b9a:	5d                   	pop    %ebp
80105b9b:	c3                   	ret    

80105b9c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105b9c:	55                   	push   %ebp
80105b9d:	89 e5                	mov    %esp,%ebp
80105b9f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105ba8:	90                   	nop
80105ba9:	8b 45 10             	mov    0x10(%ebp),%eax
80105bac:	8d 50 ff             	lea    -0x1(%eax),%edx
80105baf:	89 55 10             	mov    %edx,0x10(%ebp)
80105bb2:	85 c0                	test   %eax,%eax
80105bb4:	7e 1c                	jle    80105bd2 <strncpy+0x36>
80105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb9:	8d 50 01             	lea    0x1(%eax),%edx
80105bbc:	89 55 08             	mov    %edx,0x8(%ebp)
80105bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bc2:	8d 4a 01             	lea    0x1(%edx),%ecx
80105bc5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105bc8:	8a 12                	mov    (%edx),%dl
80105bca:	88 10                	mov    %dl,(%eax)
80105bcc:	8a 00                	mov    (%eax),%al
80105bce:	84 c0                	test   %al,%al
80105bd0:	75 d7                	jne    80105ba9 <strncpy+0xd>
    ;
  while(n-- > 0)
80105bd2:	eb 0c                	jmp    80105be0 <strncpy+0x44>
    *s++ = 0;
80105bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd7:	8d 50 01             	lea    0x1(%eax),%edx
80105bda:	89 55 08             	mov    %edx,0x8(%ebp)
80105bdd:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105be0:	8b 45 10             	mov    0x10(%ebp),%eax
80105be3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105be6:	89 55 10             	mov    %edx,0x10(%ebp)
80105be9:	85 c0                	test   %eax,%eax
80105beb:	7f e7                	jg     80105bd4 <strncpy+0x38>
    *s++ = 0;
  return os;
80105bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bf0:	c9                   	leave  
80105bf1:	c3                   	ret    

80105bf2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105bf2:	55                   	push   %ebp
80105bf3:	89 e5                	mov    %esp,%ebp
80105bf5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105bfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c02:	7f 05                	jg     80105c09 <safestrcpy+0x17>
    return os;
80105c04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c07:	eb 2e                	jmp    80105c37 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c09:	ff 4d 10             	decl   0x10(%ebp)
80105c0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c10:	7e 1c                	jle    80105c2e <safestrcpy+0x3c>
80105c12:	8b 45 08             	mov    0x8(%ebp),%eax
80105c15:	8d 50 01             	lea    0x1(%eax),%edx
80105c18:	89 55 08             	mov    %edx,0x8(%ebp)
80105c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c1e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c21:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c24:	8a 12                	mov    (%edx),%dl
80105c26:	88 10                	mov    %dl,(%eax)
80105c28:	8a 00                	mov    (%eax),%al
80105c2a:	84 c0                	test   %al,%al
80105c2c:	75 db                	jne    80105c09 <safestrcpy+0x17>
    ;
  *s = 0;
80105c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c31:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105c34:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c37:	c9                   	leave  
80105c38:	c3                   	ret    

80105c39 <strlen>:

int
strlen(const char *s)
{
80105c39:	55                   	push   %ebp
80105c3a:	89 e5                	mov    %esp,%ebp
80105c3c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105c3f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c46:	eb 03                	jmp    80105c4b <strlen+0x12>
80105c48:	ff 45 fc             	incl   -0x4(%ebp)
80105c4b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c51:	01 d0                	add    %edx,%eax
80105c53:	8a 00                	mov    (%eax),%al
80105c55:	84 c0                	test   %al,%al
80105c57:	75 ef                	jne    80105c48 <strlen+0xf>
    ;
  return n;
80105c59:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c5c:	c9                   	leave  
80105c5d:	c3                   	ret    
	...

80105c60 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105c60:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105c64:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105c68:	55                   	push   %ebp
  pushl %ebx
80105c69:	53                   	push   %ebx
  pushl %esi
80105c6a:	56                   	push   %esi
  pushl %edi
80105c6b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105c6c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105c6e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105c70:	5f                   	pop    %edi
  popl %esi
80105c71:	5e                   	pop    %esi
  popl %ebx
80105c72:	5b                   	pop    %ebx
  popl %ebp
80105c73:	5d                   	pop    %ebp
  ret
80105c74:	c3                   	ret    
80105c75:	00 00                	add    %al,(%eax)
	...

80105c78 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105c78:	55                   	push   %ebp
80105c79:	89 e5                	mov    %esp,%ebp
80105c7b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105c7e:	e8 50 e9 ff ff       	call   801045d3 <myproc>
80105c83:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c89:	8b 00                	mov    (%eax),%eax
80105c8b:	3b 45 08             	cmp    0x8(%ebp),%eax
80105c8e:	76 0f                	jbe    80105c9f <fetchint+0x27>
80105c90:	8b 45 08             	mov    0x8(%ebp),%eax
80105c93:	8d 50 04             	lea    0x4(%eax),%edx
80105c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c99:	8b 00                	mov    (%eax),%eax
80105c9b:	39 c2                	cmp    %eax,%edx
80105c9d:	76 07                	jbe    80105ca6 <fetchint+0x2e>
    return -1;
80105c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca4:	eb 0f                	jmp    80105cb5 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca9:	8b 10                	mov    (%eax),%edx
80105cab:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cae:	89 10                	mov    %edx,(%eax)
  return 0;
80105cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cb5:	c9                   	leave  
80105cb6:	c3                   	ret    

80105cb7 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105cb7:	55                   	push   %ebp
80105cb8:	89 e5                	mov    %esp,%ebp
80105cba:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105cbd:	e8 11 e9 ff ff       	call   801045d3 <myproc>
80105cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc8:	8b 00                	mov    (%eax),%eax
80105cca:	3b 45 08             	cmp    0x8(%ebp),%eax
80105ccd:	77 07                	ja     80105cd6 <fetchstr+0x1f>
    return -1;
80105ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd4:	eb 41                	jmp    80105d17 <fetchstr+0x60>
  *pp = (char*)addr;
80105cd6:	8b 55 08             	mov    0x8(%ebp),%edx
80105cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cdc:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce1:	8b 00                	mov    (%eax),%eax
80105ce3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ce9:	8b 00                	mov    (%eax),%eax
80105ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cee:	eb 1a                	jmp    80105d0a <fetchstr+0x53>
    if(*s == 0)
80105cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf3:	8a 00                	mov    (%eax),%al
80105cf5:	84 c0                	test   %al,%al
80105cf7:	75 0e                	jne    80105d07 <fetchstr+0x50>
      return s - *pp;
80105cf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cff:	8b 00                	mov    (%eax),%eax
80105d01:	29 c2                	sub    %eax,%edx
80105d03:	89 d0                	mov    %edx,%eax
80105d05:	eb 10                	jmp    80105d17 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105d07:	ff 45 f4             	incl   -0xc(%ebp)
80105d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105d10:	72 de                	jb     80105cf0 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d17:	c9                   	leave  
80105d18:	c3                   	ret    

80105d19 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105d19:	55                   	push   %ebp
80105d1a:	89 e5                	mov    %esp,%ebp
80105d1c:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105d1f:	e8 af e8 ff ff       	call   801045d3 <myproc>
80105d24:	8b 40 18             	mov    0x18(%eax),%eax
80105d27:	8b 50 44             	mov    0x44(%eax),%edx
80105d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d2d:	c1 e0 02             	shl    $0x2,%eax
80105d30:	01 d0                	add    %edx,%eax
80105d32:	8d 50 04             	lea    0x4(%eax),%edx
80105d35:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d38:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3c:	89 14 24             	mov    %edx,(%esp)
80105d3f:	e8 34 ff ff ff       	call   80105c78 <fetchint>
}
80105d44:	c9                   	leave  
80105d45:	c3                   	ret    

80105d46 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d46:	55                   	push   %ebp
80105d47:	89 e5                	mov    %esp,%ebp
80105d49:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105d4c:	e8 82 e8 ff ff       	call   801045d3 <myproc>
80105d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105d54:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d57:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80105d5e:	89 04 24             	mov    %eax,(%esp)
80105d61:	e8 b3 ff ff ff       	call   80105d19 <argint>
80105d66:	85 c0                	test   %eax,%eax
80105d68:	79 07                	jns    80105d71 <argptr+0x2b>
    return -1;
80105d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6f:	eb 3d                	jmp    80105dae <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105d71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d75:	78 21                	js     80105d98 <argptr+0x52>
80105d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7a:	89 c2                	mov    %eax,%edx
80105d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7f:	8b 00                	mov    (%eax),%eax
80105d81:	39 c2                	cmp    %eax,%edx
80105d83:	73 13                	jae    80105d98 <argptr+0x52>
80105d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d88:	89 c2                	mov    %eax,%edx
80105d8a:	8b 45 10             	mov    0x10(%ebp),%eax
80105d8d:	01 c2                	add    %eax,%edx
80105d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d92:	8b 00                	mov    (%eax),%eax
80105d94:	39 c2                	cmp    %eax,%edx
80105d96:	76 07                	jbe    80105d9f <argptr+0x59>
    return -1;
80105d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9d:	eb 0f                	jmp    80105dae <argptr+0x68>
  *pp = (char*)i;
80105d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da2:	89 c2                	mov    %eax,%edx
80105da4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105da7:	89 10                	mov    %edx,(%eax)
  return 0;
80105da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dae:	c9                   	leave  
80105daf:	c3                   	ret    

80105db0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105db0:	55                   	push   %ebp
80105db1:	89 e5                	mov    %esp,%ebp
80105db3:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105db9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80105dc0:	89 04 24             	mov    %eax,(%esp)
80105dc3:	e8 51 ff ff ff       	call   80105d19 <argint>
80105dc8:	85 c0                	test   %eax,%eax
80105dca:	79 07                	jns    80105dd3 <argstr+0x23>
    return -1;
80105dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd1:	eb 12                	jmp    80105de5 <argstr+0x35>
  return fetchstr(addr, pp);
80105dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
80105dd9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ddd:	89 04 24             	mov    %eax,(%esp)
80105de0:	e8 d2 fe ff ff       	call   80105cb7 <fetchstr>
}
80105de5:	c9                   	leave  
80105de6:	c3                   	ret    

80105de7 <syscall>:
[SYS_set_os] sys_set_os,
};

void
syscall(void)
{
80105de7:	55                   	push   %ebp
80105de8:	89 e5                	mov    %esp,%ebp
80105dea:	53                   	push   %ebx
80105deb:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105dee:	e8 e0 e7 ff ff       	call   801045d3 <myproc>
80105df3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df9:	8b 40 18             	mov    0x18(%eax),%eax
80105dfc:	8b 40 1c             	mov    0x1c(%eax),%eax
80105dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105e02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e06:	7e 2d                	jle    80105e35 <syscall+0x4e>
80105e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0b:	83 f8 37             	cmp    $0x37,%eax
80105e0e:	77 25                	ja     80105e35 <syscall+0x4e>
80105e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e13:	8b 04 85 60 d0 10 80 	mov    -0x7fef2fa0(,%eax,4),%eax
80105e1a:	85 c0                	test   %eax,%eax
80105e1c:	74 17                	je     80105e35 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e21:	8b 58 18             	mov    0x18(%eax),%ebx
80105e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e27:	8b 04 85 60 d0 10 80 	mov    -0x7fef2fa0(,%eax,4),%eax
80105e2e:	ff d0                	call   *%eax
80105e30:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105e33:	eb 34                	jmp    80105e69 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e38:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3e:	8b 40 10             	mov    0x10(%eax),%eax
80105e41:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e44:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e50:	c7 04 24 c2 9f 10 80 	movl   $0x80109fc2,(%esp)
80105e57:	e8 65 a5 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5f:	8b 40 18             	mov    0x18(%eax),%eax
80105e62:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105e69:	83 c4 24             	add    $0x24,%esp
80105e6c:	5b                   	pop    %ebx
80105e6d:	5d                   	pop    %ebp
80105e6e:	c3                   	ret    
	...

80105e70 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105e70:	55                   	push   %ebp
80105e71:	89 e5                	mov    %esp,%ebp
80105e73:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105e76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e79:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105e80:	89 04 24             	mov    %eax,(%esp)
80105e83:	e8 91 fe ff ff       	call   80105d19 <argint>
80105e88:	85 c0                	test   %eax,%eax
80105e8a:	79 07                	jns    80105e93 <argfd+0x23>
    return -1;
80105e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e91:	eb 4f                	jmp    80105ee2 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e96:	85 c0                	test   %eax,%eax
80105e98:	78 20                	js     80105eba <argfd+0x4a>
80105e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9d:	83 f8 0f             	cmp    $0xf,%eax
80105ea0:	7f 18                	jg     80105eba <argfd+0x4a>
80105ea2:	e8 2c e7 ff ff       	call   801045d3 <myproc>
80105ea7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105eaa:	83 c2 08             	add    $0x8,%edx
80105ead:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eb4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eb8:	75 07                	jne    80105ec1 <argfd+0x51>
    return -1;
80105eba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebf:	eb 21                	jmp    80105ee2 <argfd+0x72>
  if(pfd)
80105ec1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ec5:	74 08                	je     80105ecf <argfd+0x5f>
    *pfd = fd;
80105ec7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ecd:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ecf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ed3:	74 08                	je     80105edd <argfd+0x6d>
    *pf = f;
80105ed5:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105edb:	89 10                	mov    %edx,(%eax)
  return 0;
80105edd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ee2:	c9                   	leave  
80105ee3:	c3                   	ret    

80105ee4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ee4:	55                   	push   %ebp
80105ee5:	89 e5                	mov    %esp,%ebp
80105ee7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105eea:	e8 e4 e6 ff ff       	call   801045d3 <myproc>
80105eef:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105ef2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ef9:	eb 29                	jmp    80105f24 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f01:	83 c2 08             	add    $0x8,%edx
80105f04:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f08:	85 c0                	test   %eax,%eax
80105f0a:	75 15                	jne    80105f21 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f12:	8d 4a 08             	lea    0x8(%edx),%ecx
80105f15:	8b 55 08             	mov    0x8(%ebp),%edx
80105f18:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1f:	eb 0e                	jmp    80105f2f <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105f21:	ff 45 f4             	incl   -0xc(%ebp)
80105f24:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105f28:	7e d1                	jle    80105efb <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f2f:	c9                   	leave  
80105f30:	c3                   	ret    

80105f31 <sys_dup>:

int
sys_dup(void)
{
80105f31:	55                   	push   %ebp
80105f32:	89 e5                	mov    %esp,%ebp
80105f34:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105f37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f3a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f45:	00 
80105f46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f4d:	e8 1e ff ff ff       	call   80105e70 <argfd>
80105f52:	85 c0                	test   %eax,%eax
80105f54:	79 07                	jns    80105f5d <sys_dup+0x2c>
    return -1;
80105f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5b:	eb 29                	jmp    80105f86 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f60:	89 04 24             	mov    %eax,(%esp)
80105f63:	e8 7c ff ff ff       	call   80105ee4 <fdalloc>
80105f68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f6f:	79 07                	jns    80105f78 <sys_dup+0x47>
    return -1;
80105f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f76:	eb 0e                	jmp    80105f86 <sys_dup+0x55>
  filedup(f);
80105f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7b:	89 04 24             	mov    %eax,(%esp)
80105f7e:	e8 df b1 ff ff       	call   80101162 <filedup>
  return fd;
80105f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f86:	c9                   	leave  
80105f87:	c3                   	ret    

80105f88 <sys_read>:

int
sys_read(void)
{
80105f88:	55                   	push   %ebp
80105f89:	89 e5                	mov    %esp,%ebp
80105f8b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f91:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f9c:	00 
80105f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fa4:	e8 c7 fe ff ff       	call   80105e70 <argfd>
80105fa9:	85 c0                	test   %eax,%eax
80105fab:	78 35                	js     80105fe2 <sys_read+0x5a>
80105fad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fb4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105fbb:	e8 59 fd ff ff       	call   80105d19 <argint>
80105fc0:	85 c0                	test   %eax,%eax
80105fc2:	78 1e                	js     80105fe2 <sys_read+0x5a>
80105fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fcb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fce:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105fd9:	e8 68 fd ff ff       	call   80105d46 <argptr>
80105fde:	85 c0                	test   %eax,%eax
80105fe0:	79 07                	jns    80105fe9 <sys_read+0x61>
    return -1;
80105fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe7:	eb 19                	jmp    80106002 <sys_read+0x7a>
  return fileread(f, p, n);
80105fe9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fec:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ff6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ffa:	89 04 24             	mov    %eax,(%esp)
80105ffd:	e8 c1 b2 ff ff       	call   801012c3 <fileread>
}
80106002:	c9                   	leave  
80106003:	c3                   	ret    

80106004 <sys_write>:

int
sys_write(void)
{
80106004:	55                   	push   %ebp
80106005:	89 e5                	mov    %esp,%ebp
80106007:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010600a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010600d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106011:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106018:	00 
80106019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106020:	e8 4b fe ff ff       	call   80105e70 <argfd>
80106025:	85 c0                	test   %eax,%eax
80106027:	78 35                	js     8010605e <sys_write+0x5a>
80106029:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010602c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106030:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106037:	e8 dd fc ff ff       	call   80105d19 <argint>
8010603c:	85 c0                	test   %eax,%eax
8010603e:	78 1e                	js     8010605e <sys_write+0x5a>
80106040:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106043:	89 44 24 08          	mov    %eax,0x8(%esp)
80106047:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010604a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010604e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106055:	e8 ec fc ff ff       	call   80105d46 <argptr>
8010605a:	85 c0                	test   %eax,%eax
8010605c:	79 07                	jns    80106065 <sys_write+0x61>
    return -1;
8010605e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106063:	eb 19                	jmp    8010607e <sys_write+0x7a>
  return filewrite(f, p, n);
80106065:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106068:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010606b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106072:	89 54 24 04          	mov    %edx,0x4(%esp)
80106076:	89 04 24             	mov    %eax,(%esp)
80106079:	e8 00 b3 ff ff       	call   8010137e <filewrite>
}
8010607e:	c9                   	leave  
8010607f:	c3                   	ret    

80106080 <sys_close>:

int
sys_close(void)
{
80106080:	55                   	push   %ebp
80106081:	89 e5                	mov    %esp,%ebp
80106083:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106086:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106089:	89 44 24 08          	mov    %eax,0x8(%esp)
8010608d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106090:	89 44 24 04          	mov    %eax,0x4(%esp)
80106094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010609b:	e8 d0 fd ff ff       	call   80105e70 <argfd>
801060a0:	85 c0                	test   %eax,%eax
801060a2:	79 07                	jns    801060ab <sys_close+0x2b>
    return -1;
801060a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a9:	eb 23                	jmp    801060ce <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
801060ab:	e8 23 e5 ff ff       	call   801045d3 <myproc>
801060b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060b3:	83 c2 08             	add    $0x8,%edx
801060b6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801060bd:	00 
  fileclose(f);
801060be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c1:	89 04 24             	mov    %eax,(%esp)
801060c4:	e8 e1 b0 ff ff       	call   801011aa <fileclose>
  return 0;
801060c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ce:	c9                   	leave  
801060cf:	c3                   	ret    

801060d0 <sys_fstat>:

int
sys_fstat(void)
{
801060d0:	55                   	push   %ebp
801060d1:	89 e5                	mov    %esp,%ebp
801060d3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801060d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060d9:	89 44 24 08          	mov    %eax,0x8(%esp)
801060dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060e4:	00 
801060e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060ec:	e8 7f fd ff ff       	call   80105e70 <argfd>
801060f1:	85 c0                	test   %eax,%eax
801060f3:	78 1f                	js     80106114 <sys_fstat+0x44>
801060f5:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801060fc:	00 
801060fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106100:	89 44 24 04          	mov    %eax,0x4(%esp)
80106104:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010610b:	e8 36 fc ff ff       	call   80105d46 <argptr>
80106110:	85 c0                	test   %eax,%eax
80106112:	79 07                	jns    8010611b <sys_fstat+0x4b>
    return -1;
80106114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106119:	eb 12                	jmp    8010612d <sys_fstat+0x5d>
  return filestat(f, st);
8010611b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010611e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106121:	89 54 24 04          	mov    %edx,0x4(%esp)
80106125:	89 04 24             	mov    %eax,(%esp)
80106128:	e8 47 b1 ff ff       	call   80101274 <filestat>
}
8010612d:	c9                   	leave  
8010612e:	c3                   	ret    

8010612f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010612f:	55                   	push   %ebp
80106130:	89 e5                	mov    %esp,%ebp
80106132:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106135:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106138:	89 44 24 04          	mov    %eax,0x4(%esp)
8010613c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106143:	e8 68 fc ff ff       	call   80105db0 <argstr>
80106148:	85 c0                	test   %eax,%eax
8010614a:	78 17                	js     80106163 <sys_link+0x34>
8010614c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010614f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106153:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010615a:	e8 51 fc ff ff       	call   80105db0 <argstr>
8010615f:	85 c0                	test   %eax,%eax
80106161:	79 0a                	jns    8010616d <sys_link+0x3e>
    return -1;
80106163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106168:	e9 3d 01 00 00       	jmp    801062aa <sys_link+0x17b>

  begin_op();
8010616d:	e8 61 d7 ff ff       	call   801038d3 <begin_op>
  if((ip = namei(old)) == 0){
80106172:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106175:	89 04 24             	mov    %eax,(%esp)
80106178:	e8 52 c6 ff ff       	call   801027cf <namei>
8010617d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106180:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106184:	75 0f                	jne    80106195 <sys_link+0x66>
    end_op();
80106186:	e8 ca d7 ff ff       	call   80103955 <end_op>
    return -1;
8010618b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106190:	e9 15 01 00 00       	jmp    801062aa <sys_link+0x17b>
  }

  ilock(ip);
80106195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106198:	89 04 24             	mov    %eax,(%esp)
8010619b:	e8 87 b9 ff ff       	call   80101b27 <ilock>
  if(ip->type == T_DIR){
801061a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a3:	8b 40 50             	mov    0x50(%eax),%eax
801061a6:	66 83 f8 01          	cmp    $0x1,%ax
801061aa:	75 1a                	jne    801061c6 <sys_link+0x97>
    iunlockput(ip);
801061ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061af:	89 04 24             	mov    %eax,(%esp)
801061b2:	e8 6f bb ff ff       	call   80101d26 <iunlockput>
    end_op();
801061b7:	e8 99 d7 ff ff       	call   80103955 <end_op>
    return -1;
801061bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c1:	e9 e4 00 00 00       	jmp    801062aa <sys_link+0x17b>
  }

  ip->nlink++;
801061c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c9:	66 8b 40 56          	mov    0x56(%eax),%ax
801061cd:	40                   	inc    %eax
801061ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061d1:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801061d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d8:	89 04 24             	mov    %eax,(%esp)
801061db:	e8 84 b7 ff ff       	call   80101964 <iupdate>
  iunlock(ip);
801061e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e3:	89 04 24             	mov    %eax,(%esp)
801061e6:	e8 46 ba ff ff       	call   80101c31 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801061eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801061ee:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801061f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801061f5:	89 04 24             	mov    %eax,(%esp)
801061f8:	e8 f4 c5 ff ff       	call   801027f1 <nameiparent>
801061fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106200:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106204:	75 02                	jne    80106208 <sys_link+0xd9>
    goto bad;
80106206:	eb 68                	jmp    80106270 <sys_link+0x141>
  ilock(dp);
80106208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620b:	89 04 24             	mov    %eax,(%esp)
8010620e:	e8 14 b9 ff ff       	call   80101b27 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106213:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106216:	8b 10                	mov    (%eax),%edx
80106218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621b:	8b 00                	mov    (%eax),%eax
8010621d:	39 c2                	cmp    %eax,%edx
8010621f:	75 20                	jne    80106241 <sys_link+0x112>
80106221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106224:	8b 40 04             	mov    0x4(%eax),%eax
80106227:	89 44 24 08          	mov    %eax,0x8(%esp)
8010622b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010622e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106235:	89 04 24             	mov    %eax,(%esp)
80106238:	e8 d7 c1 ff ff       	call   80102414 <dirlink>
8010623d:	85 c0                	test   %eax,%eax
8010623f:	79 0d                	jns    8010624e <sys_link+0x11f>
    iunlockput(dp);
80106241:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106244:	89 04 24             	mov    %eax,(%esp)
80106247:	e8 da ba ff ff       	call   80101d26 <iunlockput>
    goto bad;
8010624c:	eb 22                	jmp    80106270 <sys_link+0x141>
  }
  iunlockput(dp);
8010624e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106251:	89 04 24             	mov    %eax,(%esp)
80106254:	e8 cd ba ff ff       	call   80101d26 <iunlockput>
  iput(ip);
80106259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625c:	89 04 24             	mov    %eax,(%esp)
8010625f:	e8 11 ba ff ff       	call   80101c75 <iput>

  end_op();
80106264:	e8 ec d6 ff ff       	call   80103955 <end_op>

  return 0;
80106269:	b8 00 00 00 00       	mov    $0x0,%eax
8010626e:	eb 3a                	jmp    801062aa <sys_link+0x17b>

bad:
  ilock(ip);
80106270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106273:	89 04 24             	mov    %eax,(%esp)
80106276:	e8 ac b8 ff ff       	call   80101b27 <ilock>
  ip->nlink--;
8010627b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627e:	66 8b 40 56          	mov    0x56(%eax),%ax
80106282:	48                   	dec    %eax
80106283:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106286:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010628a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010628d:	89 04 24             	mov    %eax,(%esp)
80106290:	e8 cf b6 ff ff       	call   80101964 <iupdate>
  iunlockput(ip);
80106295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106298:	89 04 24             	mov    %eax,(%esp)
8010629b:	e8 86 ba ff ff       	call   80101d26 <iunlockput>
  end_op();
801062a0:	e8 b0 d6 ff ff       	call   80103955 <end_op>
  return -1;
801062a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062aa:	c9                   	leave  
801062ab:	c3                   	ret    

801062ac <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801062ac:	55                   	push   %ebp
801062ad:	89 e5                	mov    %esp,%ebp
801062af:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062b2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801062b9:	eb 4a                	jmp    80106305 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801062bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062be:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801062c5:	00 
801062c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801062ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d1:	8b 45 08             	mov    0x8(%ebp),%eax
801062d4:	89 04 24             	mov    %eax,(%esp)
801062d7:	e8 e2 bc ff ff       	call   80101fbe <readi>
801062dc:	83 f8 10             	cmp    $0x10,%eax
801062df:	74 0c                	je     801062ed <isdirempty+0x41>
      panic("isdirempty: readi");
801062e1:	c7 04 24 de 9f 10 80 	movl   $0x80109fde,(%esp)
801062e8:	e8 67 a2 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801062ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062f0:	66 85 c0             	test   %ax,%ax
801062f3:	74 07                	je     801062fc <isdirempty+0x50>
      return 0;
801062f5:	b8 00 00 00 00       	mov    $0x0,%eax
801062fa:	eb 1b                	jmp    80106317 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ff:	83 c0 10             	add    $0x10,%eax
80106302:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106305:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106308:	8b 45 08             	mov    0x8(%ebp),%eax
8010630b:	8b 40 58             	mov    0x58(%eax),%eax
8010630e:	39 c2                	cmp    %eax,%edx
80106310:	72 a9                	jb     801062bb <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106312:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106317:	c9                   	leave  
80106318:	c3                   	ret    

80106319 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106319:	55                   	push   %ebp
8010631a:	89 e5                	mov    %esp,%ebp
8010631c:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010631f:	8d 45 bc             	lea    -0x44(%ebp),%eax
80106322:	89 44 24 04          	mov    %eax,0x4(%esp)
80106326:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010632d:	e8 7e fa ff ff       	call   80105db0 <argstr>
80106332:	85 c0                	test   %eax,%eax
80106334:	79 0a                	jns    80106340 <sys_unlink+0x27>
    return -1;
80106336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633b:	e9 f1 01 00 00       	jmp    80106531 <sys_unlink+0x218>

  begin_op();
80106340:	e8 8e d5 ff ff       	call   801038d3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106345:	8b 45 bc             	mov    -0x44(%ebp),%eax
80106348:	8d 55 c2             	lea    -0x3e(%ebp),%edx
8010634b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010634f:	89 04 24             	mov    %eax,(%esp)
80106352:	e8 9a c4 ff ff       	call   801027f1 <nameiparent>
80106357:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010635a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010635e:	75 0f                	jne    8010636f <sys_unlink+0x56>
    end_op();
80106360:	e8 f0 d5 ff ff       	call   80103955 <end_op>
    return -1;
80106365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636a:	e9 c2 01 00 00       	jmp    80106531 <sys_unlink+0x218>
  }

  ilock(dp);
8010636f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106372:	89 04 24             	mov    %eax,(%esp)
80106375:	e8 ad b7 ff ff       	call   80101b27 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010637a:	c7 44 24 04 f0 9f 10 	movl   $0x80109ff0,0x4(%esp)
80106381:	80 
80106382:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106385:	89 04 24             	mov    %eax,(%esp)
80106388:	e8 9f bf ff ff       	call   8010232c <namecmp>
8010638d:	85 c0                	test   %eax,%eax
8010638f:	0f 84 87 01 00 00    	je     8010651c <sys_unlink+0x203>
80106395:	c7 44 24 04 f2 9f 10 	movl   $0x80109ff2,0x4(%esp)
8010639c:	80 
8010639d:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801063a0:	89 04 24             	mov    %eax,(%esp)
801063a3:	e8 84 bf ff ff       	call   8010232c <namecmp>
801063a8:	85 c0                	test   %eax,%eax
801063aa:	0f 84 6c 01 00 00    	je     8010651c <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801063b0:	8d 45 b8             	lea    -0x48(%ebp),%eax
801063b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801063b7:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801063ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801063be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c1:	89 04 24             	mov    %eax,(%esp)
801063c4:	e8 85 bf ff ff       	call   8010234e <dirlookup>
801063c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063d0:	75 05                	jne    801063d7 <sys_unlink+0xbe>
    goto bad;
801063d2:	e9 45 01 00 00       	jmp    8010651c <sys_unlink+0x203>
  ilock(ip);
801063d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063da:	89 04 24             	mov    %eax,(%esp)
801063dd:	e8 45 b7 ff ff       	call   80101b27 <ilock>

  if(ip->nlink < 1)
801063e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e5:	66 8b 40 56          	mov    0x56(%eax),%ax
801063e9:	66 85 c0             	test   %ax,%ax
801063ec:	7f 0c                	jg     801063fa <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801063ee:	c7 04 24 f5 9f 10 80 	movl   $0x80109ff5,(%esp)
801063f5:	e8 5a a1 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801063fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fd:	8b 40 50             	mov    0x50(%eax),%eax
80106400:	66 83 f8 01          	cmp    $0x1,%ax
80106404:	75 1f                	jne    80106425 <sys_unlink+0x10c>
80106406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106409:	89 04 24             	mov    %eax,(%esp)
8010640c:	e8 9b fe ff ff       	call   801062ac <isdirempty>
80106411:	85 c0                	test   %eax,%eax
80106413:	75 10                	jne    80106425 <sys_unlink+0x10c>
    iunlockput(ip);
80106415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106418:	89 04 24             	mov    %eax,(%esp)
8010641b:	e8 06 b9 ff ff       	call   80101d26 <iunlockput>
    goto bad;
80106420:	e9 f7 00 00 00       	jmp    8010651c <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80106425:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010642c:	00 
8010642d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106434:	00 
80106435:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106438:	89 04 24             	mov    %eax,(%esp)
8010643b:	e8 a6 f5 ff ff       	call   801059e6 <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80106440:	8b 45 b8             	mov    -0x48(%ebp),%eax
80106443:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010644a:	00 
8010644b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010644f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106452:	89 44 24 04          	mov    %eax,0x4(%esp)
80106456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106459:	89 04 24             	mov    %eax,(%esp)
8010645c:	e8 c1 bc ff ff       	call   80102122 <writei>
80106461:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
80106464:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80106468:	74 0c                	je     80106476 <sys_unlink+0x15d>
    panic("unlink: writei");
8010646a:	c7 04 24 07 a0 10 80 	movl   $0x8010a007,(%esp)
80106471:	e8 de a0 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
80106476:	e8 58 e1 ff ff       	call   801045d3 <myproc>
8010647b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106481:	83 c0 1c             	add    $0x1c,%eax
80106484:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
80106487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010648a:	89 04 24             	mov    %eax,(%esp)
8010648d:	e8 8b 30 00 00       	call   8010951d <find>
80106492:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
80106495:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106498:	89 c2                	mov    %eax,%edx
8010649a:	c1 ea 1f             	shr    $0x1f,%edx
8010649d:	01 d0                	add    %edx,%eax
8010649f:	d1 f8                	sar    %eax
801064a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
801064a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064a7:	f7 d8                	neg    %eax
801064a9:	89 c2                	mov    %eax,%edx
801064ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b2:	89 14 24             	mov    %edx,(%esp)
801064b5:	e8 20 33 00 00       	call   801097da <set_curr_disk>
  if(ip->type == T_DIR){
801064ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bd:	8b 40 50             	mov    0x50(%eax),%eax
801064c0:	66 83 f8 01          	cmp    $0x1,%ax
801064c4:	75 1a                	jne    801064e0 <sys_unlink+0x1c7>
    dp->nlink--;
801064c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c9:	66 8b 40 56          	mov    0x56(%eax),%ax
801064cd:	48                   	dec    %eax
801064ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064d1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801064d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d8:	89 04 24             	mov    %eax,(%esp)
801064db:	e8 84 b4 ff ff       	call   80101964 <iupdate>
  }
  iunlockput(dp);
801064e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e3:	89 04 24             	mov    %eax,(%esp)
801064e6:	e8 3b b8 ff ff       	call   80101d26 <iunlockput>

  ip->nlink--;
801064eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ee:	66 8b 40 56          	mov    0x56(%eax),%ax
801064f2:	48                   	dec    %eax
801064f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064f6:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801064fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064fd:	89 04 24             	mov    %eax,(%esp)
80106500:	e8 5f b4 ff ff       	call   80101964 <iupdate>
  iunlockput(ip);
80106505:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106508:	89 04 24             	mov    %eax,(%esp)
8010650b:	e8 16 b8 ff ff       	call   80101d26 <iunlockput>

  end_op();
80106510:	e8 40 d4 ff ff       	call   80103955 <end_op>

  return 0;
80106515:	b8 00 00 00 00       	mov    $0x0,%eax
8010651a:	eb 15                	jmp    80106531 <sys_unlink+0x218>

bad:
  iunlockput(dp);
8010651c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651f:	89 04 24             	mov    %eax,(%esp)
80106522:	e8 ff b7 ff ff       	call   80101d26 <iunlockput>
  end_op();
80106527:	e8 29 d4 ff ff       	call   80103955 <end_op>
  return -1;
8010652c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106531:	c9                   	leave  
80106532:	c3                   	ret    

80106533 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106533:	55                   	push   %ebp
80106534:	89 e5                	mov    %esp,%ebp
80106536:	83 ec 48             	sub    $0x48,%esp
80106539:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010653c:	8b 55 10             	mov    0x10(%ebp),%edx
8010653f:	8b 45 14             	mov    0x14(%ebp),%eax
80106542:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106546:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010654a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010654e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106551:	89 44 24 04          	mov    %eax,0x4(%esp)
80106555:	8b 45 08             	mov    0x8(%ebp),%eax
80106558:	89 04 24             	mov    %eax,(%esp)
8010655b:	e8 91 c2 ff ff       	call   801027f1 <nameiparent>
80106560:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106567:	75 0a                	jne    80106573 <create+0x40>
    return 0;
80106569:	b8 00 00 00 00       	mov    $0x0,%eax
8010656e:	e9 79 01 00 00       	jmp    801066ec <create+0x1b9>
  ilock(dp);
80106573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106576:	89 04 24             	mov    %eax,(%esp)
80106579:	e8 a9 b5 ff ff       	call   80101b27 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010657e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106581:	89 44 24 08          	mov    %eax,0x8(%esp)
80106585:	8d 45 de             	lea    -0x22(%ebp),%eax
80106588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010658c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658f:	89 04 24             	mov    %eax,(%esp)
80106592:	e8 b7 bd ff ff       	call   8010234e <dirlookup>
80106597:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010659a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010659e:	74 46                	je     801065e6 <create+0xb3>
    iunlockput(dp);
801065a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a3:	89 04 24             	mov    %eax,(%esp)
801065a6:	e8 7b b7 ff ff       	call   80101d26 <iunlockput>
    ilock(ip);
801065ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ae:	89 04 24             	mov    %eax,(%esp)
801065b1:	e8 71 b5 ff ff       	call   80101b27 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801065b6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801065bb:	75 14                	jne    801065d1 <create+0x9e>
801065bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c0:	8b 40 50             	mov    0x50(%eax),%eax
801065c3:	66 83 f8 02          	cmp    $0x2,%ax
801065c7:	75 08                	jne    801065d1 <create+0x9e>
      return ip;
801065c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065cc:	e9 1b 01 00 00       	jmp    801066ec <create+0x1b9>
    iunlockput(ip);
801065d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d4:	89 04 24             	mov    %eax,(%esp)
801065d7:	e8 4a b7 ff ff       	call   80101d26 <iunlockput>
    return 0;
801065dc:	b8 00 00 00 00       	mov    $0x0,%eax
801065e1:	e9 06 01 00 00       	jmp    801066ec <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801065e6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801065ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ed:	8b 00                	mov    (%eax),%eax
801065ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801065f3:	89 04 24             	mov    %eax,(%esp)
801065f6:	e8 97 b2 ff ff       	call   80101892 <ialloc>
801065fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106602:	75 0c                	jne    80106610 <create+0xdd>
    panic("create: ialloc");
80106604:	c7 04 24 16 a0 10 80 	movl   $0x8010a016,(%esp)
8010660b:	e8 44 9f ff ff       	call   80100554 <panic>

  ilock(ip);
80106610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106613:	89 04 24             	mov    %eax,(%esp)
80106616:	e8 0c b5 ff ff       	call   80101b27 <ilock>
  ip->major = major;
8010661b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010661e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106621:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106625:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106628:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010662b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010662f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106632:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106638:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663b:	89 04 24             	mov    %eax,(%esp)
8010663e:	e8 21 b3 ff ff       	call   80101964 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106643:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106648:	75 68                	jne    801066b2 <create+0x17f>
    dp->nlink++;  // for ".."
8010664a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106651:	40                   	inc    %eax
80106652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106655:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665c:	89 04 24             	mov    %eax,(%esp)
8010665f:	e8 00 b3 ff ff       	call   80101964 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106667:	8b 40 04             	mov    0x4(%eax),%eax
8010666a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010666e:	c7 44 24 04 f0 9f 10 	movl   $0x80109ff0,0x4(%esp)
80106675:	80 
80106676:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106679:	89 04 24             	mov    %eax,(%esp)
8010667c:	e8 93 bd ff ff       	call   80102414 <dirlink>
80106681:	85 c0                	test   %eax,%eax
80106683:	78 21                	js     801066a6 <create+0x173>
80106685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106688:	8b 40 04             	mov    0x4(%eax),%eax
8010668b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010668f:	c7 44 24 04 f2 9f 10 	movl   $0x80109ff2,0x4(%esp)
80106696:	80 
80106697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010669a:	89 04 24             	mov    %eax,(%esp)
8010669d:	e8 72 bd ff ff       	call   80102414 <dirlink>
801066a2:	85 c0                	test   %eax,%eax
801066a4:	79 0c                	jns    801066b2 <create+0x17f>
      panic("create dots");
801066a6:	c7 04 24 25 a0 10 80 	movl   $0x8010a025,(%esp)
801066ad:	e8 a2 9e ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801066b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b5:	8b 40 04             	mov    0x4(%eax),%eax
801066b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801066bc:	8d 45 de             	lea    -0x22(%ebp),%eax
801066bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801066c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c6:	89 04 24             	mov    %eax,(%esp)
801066c9:	e8 46 bd ff ff       	call   80102414 <dirlink>
801066ce:	85 c0                	test   %eax,%eax
801066d0:	79 0c                	jns    801066de <create+0x1ab>
    panic("create: dirlink");
801066d2:	c7 04 24 31 a0 10 80 	movl   $0x8010a031,(%esp)
801066d9:	e8 76 9e ff ff       	call   80100554 <panic>

  iunlockput(dp);
801066de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e1:	89 04 24             	mov    %eax,(%esp)
801066e4:	e8 3d b6 ff ff       	call   80101d26 <iunlockput>

  return ip;
801066e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801066ec:	c9                   	leave  
801066ed:	c3                   	ret    

801066ee <sys_open>:

int
sys_open(void)
{
801066ee:	55                   	push   %ebp
801066ef:	89 e5                	mov    %esp,%ebp
801066f1:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801066f4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106702:	e8 a9 f6 ff ff       	call   80105db0 <argstr>
80106707:	85 c0                	test   %eax,%eax
80106709:	78 17                	js     80106722 <sys_open+0x34>
8010670b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010670e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106712:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106719:	e8 fb f5 ff ff       	call   80105d19 <argint>
8010671e:	85 c0                	test   %eax,%eax
80106720:	79 0a                	jns    8010672c <sys_open+0x3e>
    return -1;
80106722:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106727:	e9 64 01 00 00       	jmp    80106890 <sys_open+0x1a2>

  begin_op();
8010672c:	e8 a2 d1 ff ff       	call   801038d3 <begin_op>

  if(omode & O_CREATE){
80106731:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106734:	25 00 02 00 00       	and    $0x200,%eax
80106739:	85 c0                	test   %eax,%eax
8010673b:	74 3b                	je     80106778 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010673d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106740:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106747:	00 
80106748:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010674f:	00 
80106750:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106757:	00 
80106758:	89 04 24             	mov    %eax,(%esp)
8010675b:	e8 d3 fd ff ff       	call   80106533 <create>
80106760:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106763:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106767:	75 6a                	jne    801067d3 <sys_open+0xe5>
      end_op();
80106769:	e8 e7 d1 ff ff       	call   80103955 <end_op>
      return -1;
8010676e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106773:	e9 18 01 00 00       	jmp    80106890 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106778:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010677b:	89 04 24             	mov    %eax,(%esp)
8010677e:	e8 4c c0 ff ff       	call   801027cf <namei>
80106783:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106786:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010678a:	75 0f                	jne    8010679b <sys_open+0xad>
      end_op();
8010678c:	e8 c4 d1 ff ff       	call   80103955 <end_op>
      return -1;
80106791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106796:	e9 f5 00 00 00       	jmp    80106890 <sys_open+0x1a2>
    }
    ilock(ip);
8010679b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679e:	89 04 24             	mov    %eax,(%esp)
801067a1:	e8 81 b3 ff ff       	call   80101b27 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801067a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a9:	8b 40 50             	mov    0x50(%eax),%eax
801067ac:	66 83 f8 01          	cmp    $0x1,%ax
801067b0:	75 21                	jne    801067d3 <sys_open+0xe5>
801067b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067b5:	85 c0                	test   %eax,%eax
801067b7:	74 1a                	je     801067d3 <sys_open+0xe5>
      iunlockput(ip);
801067b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bc:	89 04 24             	mov    %eax,(%esp)
801067bf:	e8 62 b5 ff ff       	call   80101d26 <iunlockput>
      end_op();
801067c4:	e8 8c d1 ff ff       	call   80103955 <end_op>
      return -1;
801067c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ce:	e9 bd 00 00 00       	jmp    80106890 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801067d3:	e8 2a a9 ff ff       	call   80101102 <filealloc>
801067d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067df:	74 14                	je     801067f5 <sys_open+0x107>
801067e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e4:	89 04 24             	mov    %eax,(%esp)
801067e7:	e8 f8 f6 ff ff       	call   80105ee4 <fdalloc>
801067ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
801067ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801067f3:	79 28                	jns    8010681d <sys_open+0x12f>
    if(f)
801067f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067f9:	74 0b                	je     80106806 <sys_open+0x118>
      fileclose(f);
801067fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fe:	89 04 24             	mov    %eax,(%esp)
80106801:	e8 a4 a9 ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106809:	89 04 24             	mov    %eax,(%esp)
8010680c:	e8 15 b5 ff ff       	call   80101d26 <iunlockput>
    end_op();
80106811:	e8 3f d1 ff ff       	call   80103955 <end_op>
    return -1;
80106816:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010681b:	eb 73                	jmp    80106890 <sys_open+0x1a2>
  }
  iunlock(ip);
8010681d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106820:	89 04 24             	mov    %eax,(%esp)
80106823:	e8 09 b4 ff ff       	call   80101c31 <iunlock>
  end_op();
80106828:	e8 28 d1 ff ff       	call   80103955 <end_op>

  f->type = FD_INODE;
8010682d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106830:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106836:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106839:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010683c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010683f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106842:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010684c:	83 e0 01             	and    $0x1,%eax
8010684f:	85 c0                	test   %eax,%eax
80106851:	0f 94 c0             	sete   %al
80106854:	88 c2                	mov    %al,%dl
80106856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106859:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010685c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010685f:	83 e0 01             	and    $0x1,%eax
80106862:	85 c0                	test   %eax,%eax
80106864:	75 0a                	jne    80106870 <sys_open+0x182>
80106866:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106869:	83 e0 02             	and    $0x2,%eax
8010686c:	85 c0                	test   %eax,%eax
8010686e:	74 07                	je     80106877 <sys_open+0x189>
80106870:	b8 01 00 00 00       	mov    $0x1,%eax
80106875:	eb 05                	jmp    8010687c <sys_open+0x18e>
80106877:	b8 00 00 00 00       	mov    $0x0,%eax
8010687c:	88 c2                	mov    %al,%dl
8010687e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106881:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
80106884:	8b 55 e8             	mov    -0x18(%ebp),%edx
80106887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010688a:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
8010688d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106890:	c9                   	leave  
80106891:	c3                   	ret    

80106892 <sys_mkdir>:

int
sys_mkdir(void)
{
80106892:	55                   	push   %ebp
80106893:	89 e5                	mov    %esp,%ebp
80106895:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106898:	e8 36 d0 ff ff       	call   801038d3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010689d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801068a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068ab:	e8 00 f5 ff ff       	call   80105db0 <argstr>
801068b0:	85 c0                	test   %eax,%eax
801068b2:	78 2c                	js     801068e0 <sys_mkdir+0x4e>
801068b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801068be:	00 
801068bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801068c6:	00 
801068c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801068ce:	00 
801068cf:	89 04 24             	mov    %eax,(%esp)
801068d2:	e8 5c fc ff ff       	call   80106533 <create>
801068d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068de:	75 0c                	jne    801068ec <sys_mkdir+0x5a>
    end_op();
801068e0:	e8 70 d0 ff ff       	call   80103955 <end_op>
    return -1;
801068e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ea:	eb 15                	jmp    80106901 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801068ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ef:	89 04 24             	mov    %eax,(%esp)
801068f2:	e8 2f b4 ff ff       	call   80101d26 <iunlockput>
  end_op();
801068f7:	e8 59 d0 ff ff       	call   80103955 <end_op>
  return 0;
801068fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106901:	c9                   	leave  
80106902:	c3                   	ret    

80106903 <sys_mknod>:

int
sys_mknod(void)
{
80106903:	55                   	push   %ebp
80106904:	89 e5                	mov    %esp,%ebp
80106906:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106909:	e8 c5 cf ff ff       	call   801038d3 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010690e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106911:	89 44 24 04          	mov    %eax,0x4(%esp)
80106915:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010691c:	e8 8f f4 ff ff       	call   80105db0 <argstr>
80106921:	85 c0                	test   %eax,%eax
80106923:	78 5e                	js     80106983 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106925:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106928:	89 44 24 04          	mov    %eax,0x4(%esp)
8010692c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106933:	e8 e1 f3 ff ff       	call   80105d19 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106938:	85 c0                	test   %eax,%eax
8010693a:	78 47                	js     80106983 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010693c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010693f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106943:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010694a:	e8 ca f3 ff ff       	call   80105d19 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010694f:	85 c0                	test   %eax,%eax
80106951:	78 30                	js     80106983 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106953:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106956:	0f bf c8             	movswl %ax,%ecx
80106959:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010695c:	0f bf d0             	movswl %ax,%edx
8010695f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106962:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106966:	89 54 24 08          	mov    %edx,0x8(%esp)
8010696a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106971:	00 
80106972:	89 04 24             	mov    %eax,(%esp)
80106975:	e8 b9 fb ff ff       	call   80106533 <create>
8010697a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010697d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106981:	75 0c                	jne    8010698f <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106983:	e8 cd cf ff ff       	call   80103955 <end_op>
    return -1;
80106988:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698d:	eb 15                	jmp    801069a4 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010698f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106992:	89 04 24             	mov    %eax,(%esp)
80106995:	e8 8c b3 ff ff       	call   80101d26 <iunlockput>
  end_op();
8010699a:	e8 b6 cf ff ff       	call   80103955 <end_op>
  return 0;
8010699f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069a4:	c9                   	leave  
801069a5:	c3                   	ret    

801069a6 <sys_chdir>:

int
sys_chdir(void)
{
801069a6:	55                   	push   %ebp
801069a7:	89 e5                	mov    %esp,%ebp
801069a9:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801069ac:	e8 22 dc ff ff       	call   801045d3 <myproc>
801069b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801069b4:	e8 1a cf ff ff       	call   801038d3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801069b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801069c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069c7:	e8 e4 f3 ff ff       	call   80105db0 <argstr>
801069cc:	85 c0                	test   %eax,%eax
801069ce:	78 14                	js     801069e4 <sys_chdir+0x3e>
801069d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069d3:	89 04 24             	mov    %eax,(%esp)
801069d6:	e8 f4 bd ff ff       	call   801027cf <namei>
801069db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069e2:	75 0c                	jne    801069f0 <sys_chdir+0x4a>
    end_op();
801069e4:	e8 6c cf ff ff       	call   80103955 <end_op>
    return -1;
801069e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ee:	eb 5a                	jmp    80106a4a <sys_chdir+0xa4>
  }
  ilock(ip);
801069f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069f3:	89 04 24             	mov    %eax,(%esp)
801069f6:	e8 2c b1 ff ff       	call   80101b27 <ilock>
  if(ip->type != T_DIR){
801069fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069fe:	8b 40 50             	mov    0x50(%eax),%eax
80106a01:	66 83 f8 01          	cmp    $0x1,%ax
80106a05:	74 17                	je     80106a1e <sys_chdir+0x78>
    iunlockput(ip);
80106a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0a:	89 04 24             	mov    %eax,(%esp)
80106a0d:	e8 14 b3 ff ff       	call   80101d26 <iunlockput>
    end_op();
80106a12:	e8 3e cf ff ff       	call   80103955 <end_op>
    return -1;
80106a17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a1c:	eb 2c                	jmp    80106a4a <sys_chdir+0xa4>
  }
  iunlock(ip);
80106a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a21:	89 04 24             	mov    %eax,(%esp)
80106a24:	e8 08 b2 ff ff       	call   80101c31 <iunlock>
  iput(curproc->cwd);
80106a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2c:	8b 40 68             	mov    0x68(%eax),%eax
80106a2f:	89 04 24             	mov    %eax,(%esp)
80106a32:	e8 3e b2 ff ff       	call   80101c75 <iput>
  end_op();
80106a37:	e8 19 cf ff ff       	call   80103955 <end_op>
  curproc->cwd = ip;
80106a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a42:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a4a:	c9                   	leave  
80106a4b:	c3                   	ret    

80106a4c <sys_exec>:

int
sys_exec(void)
{
80106a4c:	55                   	push   %ebp
80106a4d:	89 e5                	mov    %esp,%ebp
80106a4f:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106a55:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a63:	e8 48 f3 ff ff       	call   80105db0 <argstr>
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	78 1a                	js     80106a86 <sys_exec+0x3a>
80106a6c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a72:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a7d:	e8 97 f2 ff ff       	call   80105d19 <argint>
80106a82:	85 c0                	test   %eax,%eax
80106a84:	79 0a                	jns    80106a90 <sys_exec+0x44>
    return -1;
80106a86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8b:	e9 c7 00 00 00       	jmp    80106b57 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106a90:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106a97:	00 
80106a98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a9f:	00 
80106aa0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106aa6:	89 04 24             	mov    %eax,(%esp)
80106aa9:	e8 38 ef ff ff       	call   801059e6 <memset>
  for(i=0;; i++){
80106aae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab8:	83 f8 1f             	cmp    $0x1f,%eax
80106abb:	76 0a                	jbe    80106ac7 <sys_exec+0x7b>
      return -1;
80106abd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ac2:	e9 90 00 00 00       	jmp    80106b57 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aca:	c1 e0 02             	shl    $0x2,%eax
80106acd:	89 c2                	mov    %eax,%edx
80106acf:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ad5:	01 c2                	add    %eax,%edx
80106ad7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106add:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ae1:	89 14 24             	mov    %edx,(%esp)
80106ae4:	e8 8f f1 ff ff       	call   80105c78 <fetchint>
80106ae9:	85 c0                	test   %eax,%eax
80106aeb:	79 07                	jns    80106af4 <sys_exec+0xa8>
      return -1;
80106aed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af2:	eb 63                	jmp    80106b57 <sys_exec+0x10b>
    if(uarg == 0){
80106af4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106afa:	85 c0                	test   %eax,%eax
80106afc:	75 26                	jne    80106b24 <sys_exec+0xd8>
      argv[i] = 0;
80106afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b01:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106b08:	00 00 00 00 
      break;
80106b0c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b10:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106b16:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b1a:	89 04 24             	mov    %eax,(%esp)
80106b1d:	e8 1e a1 ff ff       	call   80100c40 <exec>
80106b22:	eb 33                	jmp    80106b57 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b24:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b2d:	c1 e2 02             	shl    $0x2,%edx
80106b30:	01 c2                	add    %eax,%edx
80106b32:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b38:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b3c:	89 04 24             	mov    %eax,(%esp)
80106b3f:	e8 73 f1 ff ff       	call   80105cb7 <fetchstr>
80106b44:	85 c0                	test   %eax,%eax
80106b46:	79 07                	jns    80106b4f <sys_exec+0x103>
      return -1;
80106b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b4d:	eb 08                	jmp    80106b57 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106b4f:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106b52:	e9 5e ff ff ff       	jmp    80106ab5 <sys_exec+0x69>
  return exec(path, argv);
}
80106b57:	c9                   	leave  
80106b58:	c3                   	ret    

80106b59 <sys_pipe>:

int
sys_pipe(void)
{
80106b59:	55                   	push   %ebp
80106b5a:	89 e5                	mov    %esp,%ebp
80106b5c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106b5f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106b66:	00 
80106b67:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b75:	e8 cc f1 ff ff       	call   80105d46 <argptr>
80106b7a:	85 c0                	test   %eax,%eax
80106b7c:	79 0a                	jns    80106b88 <sys_pipe+0x2f>
    return -1;
80106b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b83:	e9 9a 00 00 00       	jmp    80106c22 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106b88:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b92:	89 04 24             	mov    %eax,(%esp)
80106b95:	e8 8e d5 ff ff       	call   80104128 <pipealloc>
80106b9a:	85 c0                	test   %eax,%eax
80106b9c:	79 07                	jns    80106ba5 <sys_pipe+0x4c>
    return -1;
80106b9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ba3:	eb 7d                	jmp    80106c22 <sys_pipe+0xc9>
  fd0 = -1;
80106ba5:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106baf:	89 04 24             	mov    %eax,(%esp)
80106bb2:	e8 2d f3 ff ff       	call   80105ee4 <fdalloc>
80106bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bbe:	78 14                	js     80106bd4 <sys_pipe+0x7b>
80106bc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bc3:	89 04 24             	mov    %eax,(%esp)
80106bc6:	e8 19 f3 ff ff       	call   80105ee4 <fdalloc>
80106bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bd2:	79 36                	jns    80106c0a <sys_pipe+0xb1>
    if(fd0 >= 0)
80106bd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bd8:	78 13                	js     80106bed <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106bda:	e8 f4 d9 ff ff       	call   801045d3 <myproc>
80106bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106be2:	83 c2 08             	add    $0x8,%edx
80106be5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106bec:	00 
    fileclose(rf);
80106bed:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bf0:	89 04 24             	mov    %eax,(%esp)
80106bf3:	e8 b2 a5 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106bf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bfb:	89 04 24             	mov    %eax,(%esp)
80106bfe:	e8 a7 a5 ff ff       	call   801011aa <fileclose>
    return -1;
80106c03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c08:	eb 18                	jmp    80106c22 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106c0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c10:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c15:	8d 50 04             	lea    0x4(%eax),%edx
80106c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c1b:	89 02                	mov    %eax,(%edx)
  return 0;
80106c1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c22:	c9                   	leave  
80106c23:	c3                   	ret    

80106c24 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106c24:	55                   	push   %ebp
80106c25:	89 e5                	mov    %esp,%ebp
80106c27:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106c2a:	e8 a4 d9 ff ff       	call   801045d3 <myproc>
80106c2f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c35:	83 c0 1c             	add    $0x1c,%eax
80106c38:	89 04 24             	mov    %eax,(%esp)
80106c3b:	e8 dd 28 00 00       	call   8010951d <find>
80106c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106c43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c47:	78 51                	js     80106c9a <sys_fork+0x76>
    int before = get_curr_proc(x);
80106c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c4c:	89 04 24             	mov    %eax,(%esp)
80106c4f:	e8 ff 29 00 00       	call   80109653 <get_curr_proc>
80106c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c65:	e8 da 2b 00 00       	call   80109844 <set_curr_proc>
    int after = get_curr_proc(x);
80106c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6d:	89 04 24             	mov    %eax,(%esp)
80106c70:	e8 de 29 00 00       	call   80109653 <get_curr_proc>
80106c75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
80106c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c7b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80106c7e:	75 1a                	jne    80106c9a <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
80106c80:	e8 4e d9 ff ff       	call   801045d3 <myproc>
80106c85:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c8b:	89 04 24             	mov    %eax,(%esp)
80106c8e:	e8 2a e5 ff ff       	call   801051bd <cstop_container_helper>
      return -1;
80106c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c98:	eb 05                	jmp    80106c9f <sys_fork+0x7b>
    }
  }
  return fork();
80106c9a:	e8 43 dc ff ff       	call   801048e2 <fork>
}
80106c9f:	c9                   	leave  
80106ca0:	c3                   	ret    

80106ca1 <sys_exit>:

int
sys_exit(void)
{
80106ca1:	55                   	push   %ebp
80106ca2:	89 e5                	mov    %esp,%ebp
80106ca4:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106ca7:	e8 27 d9 ff ff       	call   801045d3 <myproc>
80106cac:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106cb2:	83 c0 1c             	add    $0x1c,%eax
80106cb5:	89 04 24             	mov    %eax,(%esp)
80106cb8:	e8 60 28 00 00       	call   8010951d <find>
80106cbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106cc0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cc4:	78 13                	js     80106cd9 <sys_exit+0x38>
    set_curr_proc(-1, x);
80106cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ccd:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
80106cd4:	e8 6b 2b 00 00       	call   80109844 <set_curr_proc>
  }
  exit();
80106cd9:	e8 86 dd ff ff       	call   80104a64 <exit>
  return 0;  // not reached
80106cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ce3:	c9                   	leave  
80106ce4:	c3                   	ret    

80106ce5 <sys_wait>:

int
sys_wait(void)
{
80106ce5:	55                   	push   %ebp
80106ce6:	89 e5                	mov    %esp,%ebp
80106ce8:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106ceb:	e8 b8 de ff ff       	call   80104ba8 <wait>
}
80106cf0:	c9                   	leave  
80106cf1:	c3                   	ret    

80106cf2 <sys_kill>:

int
sys_kill(void)
{
80106cf2:	55                   	push   %ebp
80106cf3:	89 e5                	mov    %esp,%ebp
80106cf5:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d06:	e8 0e f0 ff ff       	call   80105d19 <argint>
80106d0b:	85 c0                	test   %eax,%eax
80106d0d:	79 07                	jns    80106d16 <sys_kill+0x24>
    return -1;
80106d0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d14:	eb 0b                	jmp    80106d21 <sys_kill+0x2f>
  return kill(pid);
80106d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d19:	89 04 24             	mov    %eax,(%esp)
80106d1c:	e8 65 e2 ff ff       	call   80104f86 <kill>
}
80106d21:	c9                   	leave  
80106d22:	c3                   	ret    

80106d23 <sys_getpid>:

int
sys_getpid(void)
{
80106d23:	55                   	push   %ebp
80106d24:	89 e5                	mov    %esp,%ebp
80106d26:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106d29:	e8 a5 d8 ff ff       	call   801045d3 <myproc>
80106d2e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106d31:	c9                   	leave  
80106d32:	c3                   	ret    

80106d33 <sys_sbrk>:

int
sys_sbrk(void)
{
80106d33:	55                   	push   %ebp
80106d34:	89 e5                	mov    %esp,%ebp
80106d36:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106d39:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d47:	e8 cd ef ff ff       	call   80105d19 <argint>
80106d4c:	85 c0                	test   %eax,%eax
80106d4e:	79 07                	jns    80106d57 <sys_sbrk+0x24>
    return -1;
80106d50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d55:	eb 23                	jmp    80106d7a <sys_sbrk+0x47>
  addr = myproc()->sz;
80106d57:	e8 77 d8 ff ff       	call   801045d3 <myproc>
80106d5c:	8b 00                	mov    (%eax),%eax
80106d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d64:	89 04 24             	mov    %eax,(%esp)
80106d67:	e8 d8 da ff ff       	call   80104844 <growproc>
80106d6c:	85 c0                	test   %eax,%eax
80106d6e:	79 07                	jns    80106d77 <sys_sbrk+0x44>
    return -1;
80106d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d75:	eb 03                	jmp    80106d7a <sys_sbrk+0x47>
  return addr;
80106d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d7a:	c9                   	leave  
80106d7b:	c3                   	ret    

80106d7c <sys_sleep>:

int
sys_sleep(void)
{
80106d7c:	55                   	push   %ebp
80106d7d:	89 e5                	mov    %esp,%ebp
80106d7f:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d90:	e8 84 ef ff ff       	call   80105d19 <argint>
80106d95:	85 c0                	test   %eax,%eax
80106d97:	79 07                	jns    80106da0 <sys_sleep+0x24>
    return -1;
80106d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d9e:	eb 6b                	jmp    80106e0b <sys_sleep+0x8f>
  acquire(&tickslock);
80106da0:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80106da7:	e8 d7 e9 ff ff       	call   80105783 <acquire>
  ticks0 = ticks;
80106dac:	a1 20 8d 11 80       	mov    0x80118d20,%eax
80106db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106db4:	eb 33                	jmp    80106de9 <sys_sleep+0x6d>
    if(myproc()->killed){
80106db6:	e8 18 d8 ff ff       	call   801045d3 <myproc>
80106dbb:	8b 40 24             	mov    0x24(%eax),%eax
80106dbe:	85 c0                	test   %eax,%eax
80106dc0:	74 13                	je     80106dd5 <sys_sleep+0x59>
      release(&tickslock);
80106dc2:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80106dc9:	e8 1f ea ff ff       	call   801057ed <release>
      return -1;
80106dce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd3:	eb 36                	jmp    80106e0b <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106dd5:	c7 44 24 04 e0 84 11 	movl   $0x801184e0,0x4(%esp)
80106ddc:	80 
80106ddd:	c7 04 24 20 8d 11 80 	movl   $0x80118d20,(%esp)
80106de4:	e8 9b e0 ff ff       	call   80104e84 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106de9:	a1 20 8d 11 80       	mov    0x80118d20,%eax
80106dee:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106df1:	89 c2                	mov    %eax,%edx
80106df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106df6:	39 c2                	cmp    %eax,%edx
80106df8:	72 bc                	jb     80106db6 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106dfa:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80106e01:	e8 e7 e9 ff ff       	call   801057ed <release>
  return 0;
80106e06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e0b:	c9                   	leave  
80106e0c:	c3                   	ret    

80106e0d <sys_cstop>:

void sys_cstop(){
80106e0d:	55                   	push   %ebp
80106e0e:	89 e5                	mov    %esp,%ebp
80106e10:	53                   	push   %ebx
80106e11:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106e14:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e17:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e22:	e8 89 ef ff ff       	call   80105db0 <argstr>

  if(myproc()->cont != NULL){
80106e27:	e8 a7 d7 ff ff       	call   801045d3 <myproc>
80106e2c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106e32:	85 c0                	test   %eax,%eax
80106e34:	74 72                	je     80106ea8 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106e36:	e8 98 d7 ff ff       	call   801045d3 <myproc>
80106e3b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e47:	89 04 24             	mov    %eax,(%esp)
80106e4a:	e8 ea ed ff ff       	call   80105c39 <strlen>
80106e4f:	89 c3                	mov    %eax,%ebx
80106e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e54:	83 c0 1c             	add    $0x1c,%eax
80106e57:	89 04 24             	mov    %eax,(%esp)
80106e5a:	e8 da ed ff ff       	call   80105c39 <strlen>
80106e5f:	39 c3                	cmp    %eax,%ebx
80106e61:	75 37                	jne    80106e9a <sys_cstop+0x8d>
80106e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e66:	89 04 24             	mov    %eax,(%esp)
80106e69:	e8 cb ed ff ff       	call   80105c39 <strlen>
80106e6e:	89 c2                	mov    %eax,%edx
80106e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e73:	8d 48 1c             	lea    0x1c(%eax),%ecx
80106e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e79:	89 54 24 08          	mov    %edx,0x8(%esp)
80106e7d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106e81:	89 04 24             	mov    %eax,(%esp)
80106e84:	e8 c5 ec ff ff       	call   80105b4e <strncmp>
80106e89:	85 c0                	test   %eax,%eax
80106e8b:	75 0d                	jne    80106e9a <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e90:	89 04 24             	mov    %eax,(%esp)
80106e93:	e8 25 e3 ff ff       	call   801051bd <cstop_container_helper>
80106e98:	eb 19                	jmp    80106eb3 <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106e9a:	c7 04 24 44 a0 10 80 	movl   $0x8010a044,(%esp)
80106ea1:	e8 1b 95 ff ff       	call   801003c1 <cprintf>
80106ea6:	eb 0b                	jmp    80106eb3 <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106eab:	89 04 24             	mov    %eax,(%esp)
80106eae:	e8 71 e3 ff ff       	call   80105224 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106eb3:	83 c4 24             	add    $0x24,%esp
80106eb6:	5b                   	pop    %ebx
80106eb7:	5d                   	pop    %ebp
80106eb8:	c3                   	ret    

80106eb9 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106eb9:	55                   	push   %ebp
80106eba:	89 e5                	mov    %esp,%ebp
80106ebc:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ec6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ecd:	e8 de ee ff ff       	call   80105db0 <argstr>

  set_root_inode(name);
80106ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed5:	89 04 24             	mov    %eax,(%esp)
80106ed8:	e8 0e 25 00 00       	call   801093eb <set_root_inode>
  cprintf("success\n");
80106edd:	c7 04 24 68 a0 10 80 	movl   $0x8010a068,(%esp)
80106ee4:	e8 d8 94 ff ff       	call   801003c1 <cprintf>

}
80106ee9:	c9                   	leave  
80106eea:	c3                   	ret    

80106eeb <sys_ps>:

void sys_ps(void){
80106eeb:	55                   	push   %ebp
80106eec:	89 e5                	mov    %esp,%ebp
80106eee:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106ef1:	e8 dd d6 ff ff       	call   801045d3 <myproc>
80106ef6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106efc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106eff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f03:	75 07                	jne    80106f0c <sys_ps+0x21>
    procdump();
80106f05:	e8 5b e1 ff ff       	call   80105065 <procdump>
80106f0a:	eb 0e                	jmp    80106f1a <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0f:	83 c0 1c             	add    $0x1c,%eax
80106f12:	89 04 24             	mov    %eax,(%esp)
80106f15:	e8 a0 e3 ff ff       	call   801052ba <c_procdump>
  }
}
80106f1a:	c9                   	leave  
80106f1b:	c3                   	ret    

80106f1c <sys_container_init>:

void sys_container_init(){
80106f1c:	55                   	push   %ebp
80106f1d:	89 e5                	mov    %esp,%ebp
80106f1f:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106f22:	e8 80 29 00 00       	call   801098a7 <container_init>
}
80106f27:	c9                   	leave  
80106f28:	c3                   	ret    

80106f29 <sys_is_full>:

int sys_is_full(void){
80106f29:	55                   	push   %ebp
80106f2a:	89 e5                	mov    %esp,%ebp
80106f2c:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106f2f:	e8 a8 25 00 00       	call   801094dc <is_full>
}
80106f34:	c9                   	leave  
80106f35:	c3                   	ret    

80106f36 <sys_find>:

int sys_find(void){
80106f36:	55                   	push   %ebp
80106f37:	89 e5                	mov    %esp,%ebp
80106f39:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f4a:	e8 61 ee ff ff       	call   80105db0 <argstr>

  return find(name);
80106f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f52:	89 04 24             	mov    %eax,(%esp)
80106f55:	e8 c3 25 00 00       	call   8010951d <find>
}
80106f5a:	c9                   	leave  
80106f5b:	c3                   	ret    

80106f5c <sys_get_name>:

void sys_get_name(void){
80106f5c:	55                   	push   %ebp
80106f5d:	89 e5                	mov    %esp,%ebp
80106f5f:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106f62:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f65:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f70:	e8 a4 ed ff ff       	call   80105d19 <argint>
  argstr(1, &name);
80106f75:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f78:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f83:	e8 28 ee ff ff       	call   80105db0 <argstr>

  get_name(vc_num, name);
80106f88:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f92:	89 04 24             	mov    %eax,(%esp)
80106f95:	e8 84 24 00 00       	call   8010941e <get_name>
}
80106f9a:	c9                   	leave  
80106f9b:	c3                   	ret    

80106f9c <sys_get_max_proc>:

int sys_get_max_proc(void){
80106f9c:	55                   	push   %ebp
80106f9d:	89 e5                	mov    %esp,%ebp
80106f9f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fb0:	e8 64 ed ff ff       	call   80105d19 <argint>
  return get_max_proc(vc_num);  
80106fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb8:	89 04 24             	mov    %eax,(%esp)
80106fbb:	e8 be 25 00 00       	call   8010957e <get_max_proc>
}
80106fc0:	c9                   	leave  
80106fc1:	c3                   	ret    

80106fc2 <sys_get_os>:

int sys_get_os(void){
80106fc2:	55                   	push   %ebp
80106fc3:	89 e5                	mov    %esp,%ebp
80106fc5:	83 ec 08             	sub    $0x8,%esp
  return get_os();
80106fc8:	e8 e2 25 00 00       	call   801095af <get_os>
}
80106fcd:	c9                   	leave  
80106fce:	c3                   	ret    

80106fcf <sys_get_max_mem>:

int sys_get_max_mem(void){
80106fcf:	55                   	push   %ebp
80106fd0:	89 e5                	mov    %esp,%ebp
80106fd2:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fe3:	e8 31 ed ff ff       	call   80105d19 <argint>


  return get_max_mem(vc_num);
80106fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106feb:	89 04 24             	mov    %eax,(%esp)
80106fee:	e8 fe 25 00 00       	call   801095f1 <get_max_mem>
}
80106ff3:	c9                   	leave  
80106ff4:	c3                   	ret    

80106ff5 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106ff5:	55                   	push   %ebp
80106ff6:	89 e5                	mov    %esp,%ebp
80106ff8:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
80107002:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107009:	e8 0b ed ff ff       	call   80105d19 <argint>


  return get_max_disk(vc_num);
8010700e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107011:	89 04 24             	mov    %eax,(%esp)
80107014:	e8 09 26 00 00       	call   80109622 <get_max_disk>

}
80107019:	c9                   	leave  
8010701a:	c3                   	ret    

8010701b <sys_get_curr_proc>:

int sys_get_curr_proc(void){
8010701b:	55                   	push   %ebp
8010701c:	89 e5                	mov    %esp,%ebp
8010701e:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80107021:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107024:	89 44 24 04          	mov    %eax,0x4(%esp)
80107028:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010702f:	e8 e5 ec ff ff       	call   80105d19 <argint>


  return get_curr_proc(vc_num);
80107034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107037:	89 04 24             	mov    %eax,(%esp)
8010703a:	e8 14 26 00 00       	call   80109653 <get_curr_proc>
}
8010703f:	c9                   	leave  
80107040:	c3                   	ret    

80107041 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80107041:	55                   	push   %ebp
80107042:	89 e5                	mov    %esp,%ebp
80107044:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80107047:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010704a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010704e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107055:	e8 bf ec ff ff       	call   80105d19 <argint>


  return get_curr_mem(vc_num);
8010705a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705d:	89 04 24             	mov    %eax,(%esp)
80107060:	e8 1f 26 00 00       	call   80109684 <get_curr_mem>
}
80107065:	c9                   	leave  
80107066:	c3                   	ret    

80107067 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80107067:	55                   	push   %ebp
80107068:	89 e5                	mov    %esp,%ebp
8010706a:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010706d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107070:	89 44 24 04          	mov    %eax,0x4(%esp)
80107074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010707b:	e8 99 ec ff ff       	call   80105d19 <argint>


  return get_curr_disk(vc_num);
80107080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107083:	89 04 24             	mov    %eax,(%esp)
80107086:	e8 2a 26 00 00       	call   801096b5 <get_curr_disk>
}
8010708b:	c9                   	leave  
8010708c:	c3                   	ret    

8010708d <sys_set_name>:

void sys_set_name(void){
8010708d:	55                   	push   %ebp
8010708e:	89 e5                	mov    %esp,%ebp
80107090:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80107093:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107096:	89 44 24 04          	mov    %eax,0x4(%esp)
8010709a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070a1:	e8 0a ed ff ff       	call   80105db0 <argstr>

  int vc_num;
  argint(1, &vc_num);
801070a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801070ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801070b4:	e8 60 ec ff ff       	call   80105d19 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
801070b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801070bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801070c3:	89 04 24             	mov    %eax,(%esp)
801070c6:	e8 1b 26 00 00       	call   801096e6 <set_name>
  //cprintf("Done setting name.\n");
}
801070cb:	c9                   	leave  
801070cc:	c3                   	ret    

801070cd <sys_cont_proc_set>:

void sys_cont_proc_set(void){
801070cd:	55                   	push   %ebp
801070ce:	89 e5                	mov    %esp,%ebp
801070d0:	53                   	push   %ebx
801070d1:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
801070d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801070db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070e2:	e8 32 ec ff ff       	call   80105d19 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
801070e7:	e8 e7 d4 ff ff       	call   801045d3 <myproc>
801070ec:	89 c3                	mov    %eax,%ebx
801070ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f1:	89 04 24             	mov    %eax,(%esp)
801070f4:	e8 df 24 00 00       	call   801095d8 <get_container>
801070f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
801070ff:	83 c4 24             	add    $0x24,%esp
80107102:	5b                   	pop    %ebx
80107103:	5d                   	pop    %ebp
80107104:	c3                   	ret    

80107105 <sys_set_max_mem>:

void sys_set_max_mem(void){
80107105:	55                   	push   %ebp
80107106:	89 e5                	mov    %esp,%ebp
80107108:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
8010710b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010710e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107119:	e8 fb eb ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
8010711e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107121:	89 44 24 04          	mov    %eax,0x4(%esp)
80107125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010712c:	e8 e8 eb ff ff       	call   80105d19 <argint>

  set_max_mem(mem, vc_num);
80107131:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107137:	89 54 24 04          	mov    %edx,0x4(%esp)
8010713b:	89 04 24             	mov    %eax,(%esp)
8010713e:	e8 cb 25 00 00       	call   8010970e <set_max_mem>
}
80107143:	c9                   	leave  
80107144:	c3                   	ret    

80107145 <sys_set_os>:
void sys_set_os(void){
80107145:	55                   	push   %ebp
80107146:	89 e5                	mov    %esp,%ebp
80107148:	83 ec 28             	sub    $0x28,%esp
  int os;
  argint(0, &os);
8010714b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010714e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107159:	e8 bb eb ff ff       	call   80105d19 <argint>
  set_os(os);
8010715e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107161:	89 04 24             	mov    %eax,(%esp)
80107164:	e8 bb 25 00 00       	call   80109724 <set_os>
}
80107169:	c9                   	leave  
8010716a:	c3                   	ret    

8010716b <sys_set_max_disk>:

void sys_set_max_disk(void){
8010716b:	55                   	push   %ebp
8010716c:	89 e5                	mov    %esp,%ebp
8010716e:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80107171:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107174:	89 44 24 04          	mov    %eax,0x4(%esp)
80107178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010717f:	e8 95 eb ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
80107184:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107187:	89 44 24 04          	mov    %eax,0x4(%esp)
8010718b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107192:	e8 82 eb ff ff       	call   80105d19 <argint>

  set_max_disk(disk, vc_num);
80107197:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010719a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719d:	89 54 24 04          	mov    %edx,0x4(%esp)
801071a1:	89 04 24             	mov    %eax,(%esp)
801071a4:	e8 88 25 00 00       	call   80109731 <set_max_disk>
}
801071a9:	c9                   	leave  
801071aa:	c3                   	ret    

801071ab <sys_set_max_proc>:

void sys_set_max_proc(void){
801071ab:	55                   	push   %ebp
801071ac:	89 e5                	mov    %esp,%ebp
801071ae:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801071b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801071b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071bf:	e8 55 eb ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
801071c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801071cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801071d2:	e8 42 eb ff ff       	call   80105d19 <argint>

  set_max_proc(proc, vc_num);
801071d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801071e1:	89 04 24             	mov    %eax,(%esp)
801071e4:	e8 5f 25 00 00       	call   80109748 <set_max_proc>
}
801071e9:	c9                   	leave  
801071ea:	c3                   	ret    

801071eb <sys_set_curr_mem>:

void sys_set_curr_mem(void){
801071eb:	55                   	push   %ebp
801071ec:	89 e5                	mov    %esp,%ebp
801071ee:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801071f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801071f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071ff:	e8 15 eb ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
80107204:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010720b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107212:	e8 02 eb ff ff       	call   80105d19 <argint>

  set_curr_mem(mem, vc_num);
80107217:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010721a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721d:	89 54 24 04          	mov    %edx,0x4(%esp)
80107221:	89 04 24             	mov    %eax,(%esp)
80107224:	e8 36 25 00 00       	call   8010975f <set_curr_mem>
}
80107229:	c9                   	leave  
8010722a:	c3                   	ret    

8010722b <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
8010722b:	55                   	push   %ebp
8010722c:	89 e5                	mov    %esp,%ebp
8010722e:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80107231:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107234:	89 44 24 04          	mov    %eax,0x4(%esp)
80107238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010723f:	e8 d5 ea ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
80107244:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107247:	89 44 24 04          	mov    %eax,0x4(%esp)
8010724b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107252:	e8 c2 ea ff ff       	call   80105d19 <argint>

  set_curr_mem(mem, vc_num);
80107257:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010725a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725d:	89 54 24 04          	mov    %edx,0x4(%esp)
80107261:	89 04 24             	mov    %eax,(%esp)
80107264:	e8 f6 24 00 00       	call   8010975f <set_curr_mem>
}
80107269:	c9                   	leave  
8010726a:	c3                   	ret    

8010726b <sys_set_curr_disk>:

void sys_set_curr_disk(void){
8010726b:	55                   	push   %ebp
8010726c:	89 e5                	mov    %esp,%ebp
8010726e:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80107271:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107274:	89 44 24 04          	mov    %eax,0x4(%esp)
80107278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010727f:	e8 95 ea ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
80107284:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107287:	89 44 24 04          	mov    %eax,0x4(%esp)
8010728b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107292:	e8 82 ea ff ff       	call   80105d19 <argint>

  set_curr_disk(disk, vc_num);
80107297:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010729a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729d:	89 54 24 04          	mov    %edx,0x4(%esp)
801072a1:	89 04 24             	mov    %eax,(%esp)
801072a4:	e8 31 25 00 00       	call   801097da <set_curr_disk>
}
801072a9:	c9                   	leave  
801072aa:	c3                   	ret    

801072ab <sys_set_curr_proc>:

void sys_set_curr_proc(void){
801072ab:	55                   	push   %ebp
801072ac:	89 e5                	mov    %esp,%ebp
801072ae:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801072b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801072b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801072bf:	e8 55 ea ff ff       	call   80105d19 <argint>

  int vc_num;
  argint(1, &vc_num);
801072c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801072cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801072d2:	e8 42 ea ff ff       	call   80105d19 <argint>

  set_curr_proc(proc, vc_num);
801072d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801072e1:	89 04 24             	mov    %eax,(%esp)
801072e4:	e8 5b 25 00 00       	call   80109844 <set_curr_proc>
}
801072e9:	c9                   	leave  
801072ea:	c3                   	ret    

801072eb <sys_container_reset>:

void sys_container_reset(void){
801072eb:	55                   	push   %ebp
801072ec:	89 e5                	mov    %esp,%ebp
801072ee:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
801072f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801072f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801072ff:	e8 15 ea ff ff       	call   80105d19 <argint>
  container_reset(vc_num);
80107304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107307:	89 04 24             	mov    %eax,(%esp)
8010730a:	e8 44 26 00 00       	call   80109953 <container_reset>
}
8010730f:	c9                   	leave  
80107310:	c3                   	ret    

80107311 <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107311:	55                   	push   %ebp
80107312:	89 e5                	mov    %esp,%ebp
80107314:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80107317:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
8010731e:	e8 60 e4 ff ff       	call   80105783 <acquire>
  xticks = ticks;
80107323:	a1 20 8d 11 80       	mov    0x80118d20,%eax
80107328:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010732b:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80107332:	e8 b6 e4 ff ff       	call   801057ed <release>
  return xticks;
80107337:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010733a:	c9                   	leave  
8010733b:	c3                   	ret    

8010733c <sys_getticks>:

int
sys_getticks(void){
8010733c:	55                   	push   %ebp
8010733d:	89 e5                	mov    %esp,%ebp
8010733f:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80107342:	e8 8c d2 ff ff       	call   801045d3 <myproc>
80107347:	8b 40 7c             	mov    0x7c(%eax),%eax
}
8010734a:	c9                   	leave  
8010734b:	c3                   	ret    

8010734c <sys_max_containers>:

int sys_max_containers(void){
8010734c:	55                   	push   %ebp
8010734d:	89 e5                	mov    %esp,%ebp
8010734f:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
80107352:	e8 46 25 00 00       	call   8010989d <max_containers>
}
80107357:	c9                   	leave  
80107358:	c3                   	ret    

80107359 <sys_df>:


void sys_df(void){
80107359:	55                   	push   %ebp
8010735a:	89 e5                	mov    %esp,%ebp
8010735c:	83 ec 58             	sub    $0x58,%esp
  struct container* cont = myproc()->cont;
8010735f:	e8 6f d2 ff ff       	call   801045d3 <myproc>
80107364:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010736a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
8010736d:	8d 45 b8             	lea    -0x48(%ebp),%eax
80107370:	89 44 24 04          	mov    %eax,0x4(%esp)
80107374:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010737b:	e8 40 a1 ff ff       	call   801014c0 <readsb>

  int used = 0;
80107380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80107387:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010738b:	75 6c                	jne    801073f9 <sys_df+0xa0>
    int max = max_containers();
8010738d:	e8 0b 25 00 00       	call   8010989d <max_containers>
80107392:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
80107395:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010739c:	eb 37                	jmp    801073d5 <sys_df+0x7c>
      used = used + (int)(get_curr_disk(i) / 1024);
8010739e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073a1:	89 04 24             	mov    %eax,(%esp)
801073a4:	e8 0c 23 00 00       	call   801096b5 <get_curr_disk>
801073a9:	85 c0                	test   %eax,%eax
801073ab:	79 05                	jns    801073b2 <sys_df+0x59>
801073ad:	05 ff 03 00 00       	add    $0x3ff,%eax
801073b2:	c1 f8 0a             	sar    $0xa,%eax
801073b5:	01 45 f4             	add    %eax,-0xc(%ebp)
      if(i == 0){
801073b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801073bc:	75 14                	jne    801073d2 <sys_df+0x79>
        used += (int)(get_os() / 1024);
801073be:	e8 ec 21 00 00       	call   801095af <get_os>
801073c3:	85 c0                	test   %eax,%eax
801073c5:	79 05                	jns    801073cc <sys_df+0x73>
801073c7:	05 ff 03 00 00       	add    $0x3ff,%eax
801073cc:	c1 f8 0a             	sar    $0xa,%eax
801073cf:	01 45 f4             	add    %eax,-0xc(%ebp)

  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
801073d2:	ff 45 f0             	incl   -0x10(%ebp)
801073d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073d8:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801073db:	7c c1                	jl     8010739e <sys_df+0x45>
      used = used + (int)(get_curr_disk(i) / 1024);
      if(i == 0){
        used += (int)(get_os() / 1024);
      }
    }
    cprintf("~%d used out of %d available.\n", used, sb.nblocks);
801073dd:	8b 45 bc             	mov    -0x44(%ebp),%eax
801073e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801073e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801073eb:	c7 04 24 74 a0 10 80 	movl   $0x8010a074,(%esp)
801073f2:	e8 ca 8f ff ff       	call   801003c1 <cprintf>
801073f7:	eb 4d                	jmp    80107446 <sys_df+0xed>
  }
  else{
    int x = find(cont->name);
801073f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073fc:	83 c0 1c             	add    $0x1c,%eax
801073ff:	89 04 24             	mov    %eax,(%esp)
80107402:	e8 16 21 00 00       	call   8010951d <find>
80107407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
8010740a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010740d:	89 04 24             	mov    %eax,(%esp)
80107410:	e8 a0 22 00 00       	call   801096b5 <get_curr_disk>
80107415:	85 c0                	test   %eax,%eax
80107417:	79 05                	jns    8010741e <sys_df+0xc5>
80107419:	05 ff 03 00 00       	add    $0x3ff,%eax
8010741e:	c1 f8 0a             	sar    $0xa,%eax
80107421:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("~%d used out of %d available.\n", used,  get_max_disk(x));
80107424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107427:	89 04 24             	mov    %eax,(%esp)
8010742a:	e8 f3 21 00 00       	call   80109622 <get_max_disk>
8010742f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107433:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107436:	89 44 24 04          	mov    %eax,0x4(%esp)
8010743a:	c7 04 24 74 a0 10 80 	movl   $0x8010a074,(%esp)
80107441:	e8 7b 8f ff ff       	call   801003c1 <cprintf>
  }
}
80107446:	c9                   	leave  
80107447:	c3                   	ret    

80107448 <sys_pause>:

void
sys_pause(void){
80107448:	55                   	push   %ebp
80107449:	89 e5                	mov    %esp,%ebp
8010744b:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
8010744e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107451:	89 44 24 04          	mov    %eax,0x4(%esp)
80107455:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010745c:	e8 4f e9 ff ff       	call   80105db0 <argstr>
  pause(name);
80107461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107464:	89 04 24             	mov    %eax,(%esp)
80107467:	e8 e9 e0 ff ff       	call   80105555 <pause>
}
8010746c:	c9                   	leave  
8010746d:	c3                   	ret    

8010746e <sys_resume>:

void
sys_resume(void){
8010746e:	55                   	push   %ebp
8010746f:	89 e5                	mov    %esp,%ebp
80107471:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107474:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107477:	89 44 24 04          	mov    %eax,0x4(%esp)
8010747b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107482:	e8 29 e9 ff ff       	call   80105db0 <argstr>
  resume(name);
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	89 04 24             	mov    %eax,(%esp)
8010748d:	e8 26 e1 ff ff       	call   801055b8 <resume>
}
80107492:	c9                   	leave  
80107493:	c3                   	ret    

80107494 <sys_tmem>:

int
sys_tmem(void){
80107494:	55                   	push   %ebp
80107495:	89 e5                	mov    %esp,%ebp
80107497:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
8010749a:	e8 34 d1 ff ff       	call   801045d3 <myproc>
8010749f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801074a5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801074a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801074ac:	75 07                	jne    801074b5 <sys_tmem+0x21>
    return mem_usage();
801074ae:	e8 71 bb ff ff       	call   80103024 <mem_usage>
801074b3:	eb 16                	jmp    801074cb <sys_tmem+0x37>
  }
  return get_curr_mem(find(cont->name));
801074b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b8:	83 c0 1c             	add    $0x1c,%eax
801074bb:	89 04 24             	mov    %eax,(%esp)
801074be:	e8 5a 20 00 00       	call   8010951d <find>
801074c3:	89 04 24             	mov    %eax,(%esp)
801074c6:	e8 b9 21 00 00       	call   80109684 <get_curr_mem>
}
801074cb:	c9                   	leave  
801074cc:	c3                   	ret    

801074cd <sys_amem>:

int
sys_amem(void){
801074cd:	55                   	push   %ebp
801074ce:	89 e5                	mov    %esp,%ebp
801074d0:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
801074d3:	e8 fb d0 ff ff       	call   801045d3 <myproc>
801074d8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801074de:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801074e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801074e5:	75 07                	jne    801074ee <sys_amem+0x21>
    return mem_avail();
801074e7:	e8 42 bb ff ff       	call   8010302e <mem_avail>
801074ec:	eb 16                	jmp    80107504 <sys_amem+0x37>
  }
  return get_max_mem(find(cont->name));
801074ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f1:	83 c0 1c             	add    $0x1c,%eax
801074f4:	89 04 24             	mov    %eax,(%esp)
801074f7:	e8 21 20 00 00       	call   8010951d <find>
801074fc:	89 04 24             	mov    %eax,(%esp)
801074ff:	e8 ed 20 00 00       	call   801095f1 <get_max_mem>
}
80107504:	c9                   	leave  
80107505:	c3                   	ret    

80107506 <sys_c_ps>:

void sys_c_ps(void){
80107506:	55                   	push   %ebp
80107507:	89 e5                	mov    %esp,%ebp
80107509:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
8010750c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010750f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010751a:	e8 91 e8 ff ff       	call   80105db0 <argstr>
  c_proc_data(name);
8010751f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107522:	89 04 24             	mov    %eax,(%esp)
80107525:	e8 6c de ff ff       	call   80105396 <c_proc_data>
  // c_procdump(name);
}
8010752a:	c9                   	leave  
8010752b:	c3                   	ret    

8010752c <sys_get_used>:

int sys_get_used(void){
8010752c:	55                   	push   %ebp
8010752d:	89 e5                	mov    %esp,%ebp
8010752f:	83 ec 28             	sub    $0x28,%esp
  int x; 
  argint(0, &x);
80107532:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107535:	89 44 24 04          	mov    %eax,0x4(%esp)
80107539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107540:	e8 d4 e7 ff ff       	call   80105d19 <argint>
  return get_used(x);
80107545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107548:	89 04 24             	mov    %eax,(%esp)
8010754b:	e8 28 1f 00 00       	call   80109478 <get_used>
}
80107550:	c9                   	leave  
80107551:	c3                   	ret    
	...

80107554 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107554:	1e                   	push   %ds
  pushl %es
80107555:	06                   	push   %es
  pushl %fs
80107556:	0f a0                	push   %fs
  pushl %gs
80107558:	0f a8                	push   %gs
  pushal
8010755a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010755b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010755f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107561:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80107563:	54                   	push   %esp
  call trap
80107564:	e8 c0 01 00 00       	call   80107729 <trap>
  addl $4, %esp
80107569:	83 c4 04             	add    $0x4,%esp

8010756c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010756c:	61                   	popa   
  popl %gs
8010756d:	0f a9                	pop    %gs
  popl %fs
8010756f:	0f a1                	pop    %fs
  popl %es
80107571:	07                   	pop    %es
  popl %ds
80107572:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107573:	83 c4 08             	add    $0x8,%esp
  iret
80107576:	cf                   	iret   
	...

80107578 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107578:	55                   	push   %ebp
80107579:	89 e5                	mov    %esp,%ebp
8010757b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010757e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107581:	48                   	dec    %eax
80107582:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107586:	8b 45 08             	mov    0x8(%ebp),%eax
80107589:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010758d:	8b 45 08             	mov    0x8(%ebp),%eax
80107590:	c1 e8 10             	shr    $0x10,%eax
80107593:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107597:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010759a:	0f 01 18             	lidtl  (%eax)
}
8010759d:	c9                   	leave  
8010759e:	c3                   	ret    

8010759f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010759f:	55                   	push   %ebp
801075a0:	89 e5                	mov    %esp,%ebp
801075a2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801075a5:	0f 20 d0             	mov    %cr2,%eax
801075a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801075ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801075ae:	c9                   	leave  
801075af:	c3                   	ret    

801075b0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801075b0:	55                   	push   %ebp
801075b1:	89 e5                	mov    %esp,%ebp
801075b3:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801075b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801075bd:	e9 b8 00 00 00       	jmp    8010767a <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801075c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c5:	8b 04 85 40 d1 10 80 	mov    -0x7fef2ec0(,%eax,4),%eax
801075cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801075cf:	66 89 04 d5 20 85 11 	mov    %ax,-0x7fee7ae0(,%edx,8)
801075d6:	80 
801075d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075da:	66 c7 04 c5 22 85 11 	movw   $0x8,-0x7fee7ade(,%eax,8)
801075e1:	80 08 00 
801075e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e7:	8a 14 c5 24 85 11 80 	mov    -0x7fee7adc(,%eax,8),%dl
801075ee:	83 e2 e0             	and    $0xffffffe0,%edx
801075f1:	88 14 c5 24 85 11 80 	mov    %dl,-0x7fee7adc(,%eax,8)
801075f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fb:	8a 14 c5 24 85 11 80 	mov    -0x7fee7adc(,%eax,8),%dl
80107602:	83 e2 1f             	and    $0x1f,%edx
80107605:	88 14 c5 24 85 11 80 	mov    %dl,-0x7fee7adc(,%eax,8)
8010760c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760f:	8a 14 c5 25 85 11 80 	mov    -0x7fee7adb(,%eax,8),%dl
80107616:	83 e2 f0             	and    $0xfffffff0,%edx
80107619:	83 ca 0e             	or     $0xe,%edx
8010761c:	88 14 c5 25 85 11 80 	mov    %dl,-0x7fee7adb(,%eax,8)
80107623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107626:	8a 14 c5 25 85 11 80 	mov    -0x7fee7adb(,%eax,8),%dl
8010762d:	83 e2 ef             	and    $0xffffffef,%edx
80107630:	88 14 c5 25 85 11 80 	mov    %dl,-0x7fee7adb(,%eax,8)
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	8a 14 c5 25 85 11 80 	mov    -0x7fee7adb(,%eax,8),%dl
80107641:	83 e2 9f             	and    $0xffffff9f,%edx
80107644:	88 14 c5 25 85 11 80 	mov    %dl,-0x7fee7adb(,%eax,8)
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	8a 14 c5 25 85 11 80 	mov    -0x7fee7adb(,%eax,8),%dl
80107655:	83 ca 80             	or     $0xffffff80,%edx
80107658:	88 14 c5 25 85 11 80 	mov    %dl,-0x7fee7adb(,%eax,8)
8010765f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107662:	8b 04 85 40 d1 10 80 	mov    -0x7fef2ec0(,%eax,4),%eax
80107669:	c1 e8 10             	shr    $0x10,%eax
8010766c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010766f:	66 89 04 d5 26 85 11 	mov    %ax,-0x7fee7ada(,%edx,8)
80107676:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107677:	ff 45 f4             	incl   -0xc(%ebp)
8010767a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107681:	0f 8e 3b ff ff ff    	jle    801075c2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107687:	a1 40 d2 10 80       	mov    0x8010d240,%eax
8010768c:	66 a3 20 87 11 80    	mov    %ax,0x80118720
80107692:	66 c7 05 22 87 11 80 	movw   $0x8,0x80118722
80107699:	08 00 
8010769b:	a0 24 87 11 80       	mov    0x80118724,%al
801076a0:	83 e0 e0             	and    $0xffffffe0,%eax
801076a3:	a2 24 87 11 80       	mov    %al,0x80118724
801076a8:	a0 24 87 11 80       	mov    0x80118724,%al
801076ad:	83 e0 1f             	and    $0x1f,%eax
801076b0:	a2 24 87 11 80       	mov    %al,0x80118724
801076b5:	a0 25 87 11 80       	mov    0x80118725,%al
801076ba:	83 c8 0f             	or     $0xf,%eax
801076bd:	a2 25 87 11 80       	mov    %al,0x80118725
801076c2:	a0 25 87 11 80       	mov    0x80118725,%al
801076c7:	83 e0 ef             	and    $0xffffffef,%eax
801076ca:	a2 25 87 11 80       	mov    %al,0x80118725
801076cf:	a0 25 87 11 80       	mov    0x80118725,%al
801076d4:	83 c8 60             	or     $0x60,%eax
801076d7:	a2 25 87 11 80       	mov    %al,0x80118725
801076dc:	a0 25 87 11 80       	mov    0x80118725,%al
801076e1:	83 c8 80             	or     $0xffffff80,%eax
801076e4:	a2 25 87 11 80       	mov    %al,0x80118725
801076e9:	a1 40 d2 10 80       	mov    0x8010d240,%eax
801076ee:	c1 e8 10             	shr    $0x10,%eax
801076f1:	66 a3 26 87 11 80    	mov    %ax,0x80118726

  initlock(&tickslock, "time");
801076f7:	c7 44 24 04 94 a0 10 	movl   $0x8010a094,0x4(%esp)
801076fe:	80 
801076ff:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80107706:	e8 57 e0 ff ff       	call   80105762 <initlock>
}
8010770b:	c9                   	leave  
8010770c:	c3                   	ret    

8010770d <idtinit>:

void
idtinit(void)
{
8010770d:	55                   	push   %ebp
8010770e:	89 e5                	mov    %esp,%ebp
80107710:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80107713:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010771a:	00 
8010771b:	c7 04 24 20 85 11 80 	movl   $0x80118520,(%esp)
80107722:	e8 51 fe ff ff       	call   80107578 <lidt>
}
80107727:	c9                   	leave  
80107728:	c3                   	ret    

80107729 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107729:	55                   	push   %ebp
8010772a:	89 e5                	mov    %esp,%ebp
8010772c:	57                   	push   %edi
8010772d:	56                   	push   %esi
8010772e:	53                   	push   %ebx
8010772f:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80107732:	8b 45 08             	mov    0x8(%ebp),%eax
80107735:	8b 40 30             	mov    0x30(%eax),%eax
80107738:	83 f8 40             	cmp    $0x40,%eax
8010773b:	75 3c                	jne    80107779 <trap+0x50>
    if(myproc()->killed)
8010773d:	e8 91 ce ff ff       	call   801045d3 <myproc>
80107742:	8b 40 24             	mov    0x24(%eax),%eax
80107745:	85 c0                	test   %eax,%eax
80107747:	74 05                	je     8010774e <trap+0x25>
      exit();
80107749:	e8 16 d3 ff ff       	call   80104a64 <exit>
    myproc()->tf = tf;
8010774e:	e8 80 ce ff ff       	call   801045d3 <myproc>
80107753:	8b 55 08             	mov    0x8(%ebp),%edx
80107756:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107759:	e8 89 e6 ff ff       	call   80105de7 <syscall>
    if(myproc()->killed)
8010775e:	e8 70 ce ff ff       	call   801045d3 <myproc>
80107763:	8b 40 24             	mov    0x24(%eax),%eax
80107766:	85 c0                	test   %eax,%eax
80107768:	74 0a                	je     80107774 <trap+0x4b>
      exit();
8010776a:	e8 f5 d2 ff ff       	call   80104a64 <exit>
    return;
8010776f:	e9 30 02 00 00       	jmp    801079a4 <trap+0x27b>
80107774:	e9 2b 02 00 00       	jmp    801079a4 <trap+0x27b>
  }

  switch(tf->trapno){
80107779:	8b 45 08             	mov    0x8(%ebp),%eax
8010777c:	8b 40 30             	mov    0x30(%eax),%eax
8010777f:	83 e8 20             	sub    $0x20,%eax
80107782:	83 f8 1f             	cmp    $0x1f,%eax
80107785:	0f 87 cb 00 00 00    	ja     80107856 <trap+0x12d>
8010778b:	8b 04 85 3c a1 10 80 	mov    -0x7fef5ec4(,%eax,4),%eax
80107792:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107794:	e8 71 cd ff ff       	call   8010450a <cpuid>
80107799:	85 c0                	test   %eax,%eax
8010779b:	75 2f                	jne    801077cc <trap+0xa3>
      acquire(&tickslock);
8010779d:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
801077a4:	e8 da df ff ff       	call   80105783 <acquire>
      ticks++;
801077a9:	a1 20 8d 11 80       	mov    0x80118d20,%eax
801077ae:	40                   	inc    %eax
801077af:	a3 20 8d 11 80       	mov    %eax,0x80118d20
      wakeup(&ticks);
801077b4:	c7 04 24 20 8d 11 80 	movl   $0x80118d20,(%esp)
801077bb:	e8 9b d7 ff ff       	call   80104f5b <wakeup>
      release(&tickslock);
801077c0:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
801077c7:	e8 21 e0 ff ff       	call   801057ed <release>
    }
    p = myproc();
801077cc:	e8 02 ce ff ff       	call   801045d3 <myproc>
801077d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801077d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801077d8:	74 0f                	je     801077e9 <trap+0xc0>
      p->ticks++;
801077da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077dd:	8b 40 7c             	mov    0x7c(%eax),%eax
801077e0:	8d 50 01             	lea    0x1(%eax),%edx
801077e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077e6:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801077e9:	e8 bd bb ff ff       	call   801033ab <lapiceoi>
    break;
801077ee:	e9 35 01 00 00       	jmp    80107928 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801077f3:	e8 02 b3 ff ff       	call   80102afa <ideintr>
    lapiceoi();
801077f8:	e8 ae bb ff ff       	call   801033ab <lapiceoi>
    break;
801077fd:	e9 26 01 00 00       	jmp    80107928 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107802:	e8 bb b9 ff ff       	call   801031c2 <kbdintr>
    lapiceoi();
80107807:	e8 9f bb ff ff       	call   801033ab <lapiceoi>
    break;
8010780c:	e9 17 01 00 00       	jmp    80107928 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107811:	e8 6f 03 00 00       	call   80107b85 <uartintr>
    lapiceoi();
80107816:	e8 90 bb ff ff       	call   801033ab <lapiceoi>
    break;
8010781b:	e9 08 01 00 00       	jmp    80107928 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107820:	8b 45 08             	mov    0x8(%ebp),%eax
80107823:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107826:	8b 45 08             	mov    0x8(%ebp),%eax
80107829:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010782c:	0f b7 d8             	movzwl %ax,%ebx
8010782f:	e8 d6 cc ff ff       	call   8010450a <cpuid>
80107834:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107838:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010783c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107840:	c7 04 24 9c a0 10 80 	movl   $0x8010a09c,(%esp)
80107847:	e8 75 8b ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
8010784c:	e8 5a bb ff ff       	call   801033ab <lapiceoi>
    break;
80107851:	e9 d2 00 00 00       	jmp    80107928 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80107856:	e8 78 cd ff ff       	call   801045d3 <myproc>
8010785b:	85 c0                	test   %eax,%eax
8010785d:	74 10                	je     8010786f <trap+0x146>
8010785f:	8b 45 08             	mov    0x8(%ebp),%eax
80107862:	8b 40 3c             	mov    0x3c(%eax),%eax
80107865:	0f b7 c0             	movzwl %ax,%eax
80107868:	83 e0 03             	and    $0x3,%eax
8010786b:	85 c0                	test   %eax,%eax
8010786d:	75 40                	jne    801078af <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010786f:	e8 2b fd ff ff       	call   8010759f <rcr2>
80107874:	89 c3                	mov    %eax,%ebx
80107876:	8b 45 08             	mov    0x8(%ebp),%eax
80107879:	8b 70 38             	mov    0x38(%eax),%esi
8010787c:	e8 89 cc ff ff       	call   8010450a <cpuid>
80107881:	8b 55 08             	mov    0x8(%ebp),%edx
80107884:	8b 52 30             	mov    0x30(%edx),%edx
80107887:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010788b:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010788f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107893:	89 54 24 04          	mov    %edx,0x4(%esp)
80107897:	c7 04 24 c0 a0 10 80 	movl   $0x8010a0c0,(%esp)
8010789e:	e8 1e 8b ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801078a3:	c7 04 24 f2 a0 10 80 	movl   $0x8010a0f2,(%esp)
801078aa:	e8 a5 8c ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078af:	e8 eb fc ff ff       	call   8010759f <rcr2>
801078b4:	89 c6                	mov    %eax,%esi
801078b6:	8b 45 08             	mov    0x8(%ebp),%eax
801078b9:	8b 40 38             	mov    0x38(%eax),%eax
801078bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801078bf:	e8 46 cc ff ff       	call   8010450a <cpuid>
801078c4:	89 c3                	mov    %eax,%ebx
801078c6:	8b 45 08             	mov    0x8(%ebp),%eax
801078c9:	8b 78 34             	mov    0x34(%eax),%edi
801078cc:	89 7d d0             	mov    %edi,-0x30(%ebp)
801078cf:	8b 45 08             	mov    0x8(%ebp),%eax
801078d2:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801078d5:	e8 f9 cc ff ff       	call   801045d3 <myproc>
801078da:	8d 50 6c             	lea    0x6c(%eax),%edx
801078dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
801078e0:	e8 ee cc ff ff       	call   801045d3 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078e5:	8b 40 10             	mov    0x10(%eax),%eax
801078e8:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801078ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801078ef:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801078f3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801078f7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801078fa:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801078fe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80107902:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107905:	89 54 24 08          	mov    %edx,0x8(%esp)
80107909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010790d:	c7 04 24 f8 a0 10 80 	movl   $0x8010a0f8,(%esp)
80107914:	e8 a8 8a ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107919:	e8 b5 cc ff ff       	call   801045d3 <myproc>
8010791e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107925:	eb 01                	jmp    80107928 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107927:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107928:	e8 a6 cc ff ff       	call   801045d3 <myproc>
8010792d:	85 c0                	test   %eax,%eax
8010792f:	74 22                	je     80107953 <trap+0x22a>
80107931:	e8 9d cc ff ff       	call   801045d3 <myproc>
80107936:	8b 40 24             	mov    0x24(%eax),%eax
80107939:	85 c0                	test   %eax,%eax
8010793b:	74 16                	je     80107953 <trap+0x22a>
8010793d:	8b 45 08             	mov    0x8(%ebp),%eax
80107940:	8b 40 3c             	mov    0x3c(%eax),%eax
80107943:	0f b7 c0             	movzwl %ax,%eax
80107946:	83 e0 03             	and    $0x3,%eax
80107949:	83 f8 03             	cmp    $0x3,%eax
8010794c:	75 05                	jne    80107953 <trap+0x22a>
    exit();
8010794e:	e8 11 d1 ff ff       	call   80104a64 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107953:	e8 7b cc ff ff       	call   801045d3 <myproc>
80107958:	85 c0                	test   %eax,%eax
8010795a:	74 1d                	je     80107979 <trap+0x250>
8010795c:	e8 72 cc ff ff       	call   801045d3 <myproc>
80107961:	8b 40 0c             	mov    0xc(%eax),%eax
80107964:	83 f8 04             	cmp    $0x4,%eax
80107967:	75 10                	jne    80107979 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107969:	8b 45 08             	mov    0x8(%ebp),%eax
8010796c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010796f:	83 f8 20             	cmp    $0x20,%eax
80107972:	75 05                	jne    80107979 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107974:	e8 9b d4 ff ff       	call   80104e14 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107979:	e8 55 cc ff ff       	call   801045d3 <myproc>
8010797e:	85 c0                	test   %eax,%eax
80107980:	74 22                	je     801079a4 <trap+0x27b>
80107982:	e8 4c cc ff ff       	call   801045d3 <myproc>
80107987:	8b 40 24             	mov    0x24(%eax),%eax
8010798a:	85 c0                	test   %eax,%eax
8010798c:	74 16                	je     801079a4 <trap+0x27b>
8010798e:	8b 45 08             	mov    0x8(%ebp),%eax
80107991:	8b 40 3c             	mov    0x3c(%eax),%eax
80107994:	0f b7 c0             	movzwl %ax,%eax
80107997:	83 e0 03             	and    $0x3,%eax
8010799a:	83 f8 03             	cmp    $0x3,%eax
8010799d:	75 05                	jne    801079a4 <trap+0x27b>
    exit();
8010799f:	e8 c0 d0 ff ff       	call   80104a64 <exit>
}
801079a4:	83 c4 4c             	add    $0x4c,%esp
801079a7:	5b                   	pop    %ebx
801079a8:	5e                   	pop    %esi
801079a9:	5f                   	pop    %edi
801079aa:	5d                   	pop    %ebp
801079ab:	c3                   	ret    

801079ac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801079ac:	55                   	push   %ebp
801079ad:	89 e5                	mov    %esp,%ebp
801079af:	83 ec 14             	sub    $0x14,%esp
801079b2:	8b 45 08             	mov    0x8(%ebp),%eax
801079b5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801079b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079bc:	89 c2                	mov    %eax,%edx
801079be:	ec                   	in     (%dx),%al
801079bf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801079c2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801079c5:	c9                   	leave  
801079c6:	c3                   	ret    

801079c7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801079c7:	55                   	push   %ebp
801079c8:	89 e5                	mov    %esp,%ebp
801079ca:	83 ec 08             	sub    $0x8,%esp
801079cd:	8b 45 08             	mov    0x8(%ebp),%eax
801079d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801079d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801079d7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801079da:	8a 45 f8             	mov    -0x8(%ebp),%al
801079dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801079e0:	ee                   	out    %al,(%dx)
}
801079e1:	c9                   	leave  
801079e2:	c3                   	ret    

801079e3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801079e3:	55                   	push   %ebp
801079e4:	89 e5                	mov    %esp,%ebp
801079e6:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801079e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801079f0:	00 
801079f1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801079f8:	e8 ca ff ff ff       	call   801079c7 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801079fd:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107a04:	00 
80107a05:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107a0c:	e8 b6 ff ff ff       	call   801079c7 <outb>
  outb(COM1+0, 115200/9600);
80107a11:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107a18:	00 
80107a19:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107a20:	e8 a2 ff ff ff       	call   801079c7 <outb>
  outb(COM1+1, 0);
80107a25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a2c:	00 
80107a2d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107a34:	e8 8e ff ff ff       	call   801079c7 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107a39:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107a40:	00 
80107a41:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107a48:	e8 7a ff ff ff       	call   801079c7 <outb>
  outb(COM1+4, 0);
80107a4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a54:	00 
80107a55:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107a5c:	e8 66 ff ff ff       	call   801079c7 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107a61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107a68:	00 
80107a69:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107a70:	e8 52 ff ff ff       	call   801079c7 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107a75:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107a7c:	e8 2b ff ff ff       	call   801079ac <inb>
80107a81:	3c ff                	cmp    $0xff,%al
80107a83:	75 02                	jne    80107a87 <uartinit+0xa4>
    return;
80107a85:	eb 5b                	jmp    80107ae2 <uartinit+0xff>
  uart = 1;
80107a87:	c7 05 44 d9 10 80 01 	movl   $0x1,0x8010d944
80107a8e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107a91:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107a98:	e8 0f ff ff ff       	call   801079ac <inb>
  inb(COM1+0);
80107a9d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107aa4:	e8 03 ff ff ff       	call   801079ac <inb>
  ioapicenable(IRQ_COM1, 0);
80107aa9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ab0:	00 
80107ab1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107ab8:	e8 b2 b2 ff ff       	call   80102d6f <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107abd:	c7 45 f4 bc a1 10 80 	movl   $0x8010a1bc,-0xc(%ebp)
80107ac4:	eb 13                	jmp    80107ad9 <uartinit+0xf6>
    uartputc(*p);
80107ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac9:	8a 00                	mov    (%eax),%al
80107acb:	0f be c0             	movsbl %al,%eax
80107ace:	89 04 24             	mov    %eax,(%esp)
80107ad1:	e8 0e 00 00 00       	call   80107ae4 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107ad6:	ff 45 f4             	incl   -0xc(%ebp)
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	8a 00                	mov    (%eax),%al
80107ade:	84 c0                	test   %al,%al
80107ae0:	75 e4                	jne    80107ac6 <uartinit+0xe3>
    uartputc(*p);
}
80107ae2:	c9                   	leave  
80107ae3:	c3                   	ret    

80107ae4 <uartputc>:

void
uartputc(int c)
{
80107ae4:	55                   	push   %ebp
80107ae5:	89 e5                	mov    %esp,%ebp
80107ae7:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107aea:	a1 44 d9 10 80       	mov    0x8010d944,%eax
80107aef:	85 c0                	test   %eax,%eax
80107af1:	75 02                	jne    80107af5 <uartputc+0x11>
    return;
80107af3:	eb 4a                	jmp    80107b3f <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107afc:	eb 0f                	jmp    80107b0d <uartputc+0x29>
    microdelay(10);
80107afe:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107b05:	e8 c6 b8 ff ff       	call   801033d0 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b0a:	ff 45 f4             	incl   -0xc(%ebp)
80107b0d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b11:	7f 16                	jg     80107b29 <uartputc+0x45>
80107b13:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107b1a:	e8 8d fe ff ff       	call   801079ac <inb>
80107b1f:	0f b6 c0             	movzbl %al,%eax
80107b22:	83 e0 20             	and    $0x20,%eax
80107b25:	85 c0                	test   %eax,%eax
80107b27:	74 d5                	je     80107afe <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107b29:	8b 45 08             	mov    0x8(%ebp),%eax
80107b2c:	0f b6 c0             	movzbl %al,%eax
80107b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b33:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107b3a:	e8 88 fe ff ff       	call   801079c7 <outb>
}
80107b3f:	c9                   	leave  
80107b40:	c3                   	ret    

80107b41 <uartgetc>:

static int
uartgetc(void)
{
80107b41:	55                   	push   %ebp
80107b42:	89 e5                	mov    %esp,%ebp
80107b44:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107b47:	a1 44 d9 10 80       	mov    0x8010d944,%eax
80107b4c:	85 c0                	test   %eax,%eax
80107b4e:	75 07                	jne    80107b57 <uartgetc+0x16>
    return -1;
80107b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b55:	eb 2c                	jmp    80107b83 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107b57:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107b5e:	e8 49 fe ff ff       	call   801079ac <inb>
80107b63:	0f b6 c0             	movzbl %al,%eax
80107b66:	83 e0 01             	and    $0x1,%eax
80107b69:	85 c0                	test   %eax,%eax
80107b6b:	75 07                	jne    80107b74 <uartgetc+0x33>
    return -1;
80107b6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b72:	eb 0f                	jmp    80107b83 <uartgetc+0x42>
  return inb(COM1+0);
80107b74:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107b7b:	e8 2c fe ff ff       	call   801079ac <inb>
80107b80:	0f b6 c0             	movzbl %al,%eax
}
80107b83:	c9                   	leave  
80107b84:	c3                   	ret    

80107b85 <uartintr>:

void
uartintr(void)
{
80107b85:	55                   	push   %ebp
80107b86:	89 e5                	mov    %esp,%ebp
80107b88:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107b8b:	c7 04 24 41 7b 10 80 	movl   $0x80107b41,(%esp)
80107b92:	e8 5e 8c ff ff       	call   801007f5 <consoleintr>
}
80107b97:	c9                   	leave  
80107b98:	c3                   	ret    
80107b99:	00 00                	add    %al,(%eax)
	...

80107b9c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107b9c:	6a 00                	push   $0x0
  pushl $0
80107b9e:	6a 00                	push   $0x0
  jmp alltraps
80107ba0:	e9 af f9 ff ff       	jmp    80107554 <alltraps>

80107ba5 <vector1>:
.globl vector1
vector1:
  pushl $0
80107ba5:	6a 00                	push   $0x0
  pushl $1
80107ba7:	6a 01                	push   $0x1
  jmp alltraps
80107ba9:	e9 a6 f9 ff ff       	jmp    80107554 <alltraps>

80107bae <vector2>:
.globl vector2
vector2:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $2
80107bb0:	6a 02                	push   $0x2
  jmp alltraps
80107bb2:	e9 9d f9 ff ff       	jmp    80107554 <alltraps>

80107bb7 <vector3>:
.globl vector3
vector3:
  pushl $0
80107bb7:	6a 00                	push   $0x0
  pushl $3
80107bb9:	6a 03                	push   $0x3
  jmp alltraps
80107bbb:	e9 94 f9 ff ff       	jmp    80107554 <alltraps>

80107bc0 <vector4>:
.globl vector4
vector4:
  pushl $0
80107bc0:	6a 00                	push   $0x0
  pushl $4
80107bc2:	6a 04                	push   $0x4
  jmp alltraps
80107bc4:	e9 8b f9 ff ff       	jmp    80107554 <alltraps>

80107bc9 <vector5>:
.globl vector5
vector5:
  pushl $0
80107bc9:	6a 00                	push   $0x0
  pushl $5
80107bcb:	6a 05                	push   $0x5
  jmp alltraps
80107bcd:	e9 82 f9 ff ff       	jmp    80107554 <alltraps>

80107bd2 <vector6>:
.globl vector6
vector6:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $6
80107bd4:	6a 06                	push   $0x6
  jmp alltraps
80107bd6:	e9 79 f9 ff ff       	jmp    80107554 <alltraps>

80107bdb <vector7>:
.globl vector7
vector7:
  pushl $0
80107bdb:	6a 00                	push   $0x0
  pushl $7
80107bdd:	6a 07                	push   $0x7
  jmp alltraps
80107bdf:	e9 70 f9 ff ff       	jmp    80107554 <alltraps>

80107be4 <vector8>:
.globl vector8
vector8:
  pushl $8
80107be4:	6a 08                	push   $0x8
  jmp alltraps
80107be6:	e9 69 f9 ff ff       	jmp    80107554 <alltraps>

80107beb <vector9>:
.globl vector9
vector9:
  pushl $0
80107beb:	6a 00                	push   $0x0
  pushl $9
80107bed:	6a 09                	push   $0x9
  jmp alltraps
80107bef:	e9 60 f9 ff ff       	jmp    80107554 <alltraps>

80107bf4 <vector10>:
.globl vector10
vector10:
  pushl $10
80107bf4:	6a 0a                	push   $0xa
  jmp alltraps
80107bf6:	e9 59 f9 ff ff       	jmp    80107554 <alltraps>

80107bfb <vector11>:
.globl vector11
vector11:
  pushl $11
80107bfb:	6a 0b                	push   $0xb
  jmp alltraps
80107bfd:	e9 52 f9 ff ff       	jmp    80107554 <alltraps>

80107c02 <vector12>:
.globl vector12
vector12:
  pushl $12
80107c02:	6a 0c                	push   $0xc
  jmp alltraps
80107c04:	e9 4b f9 ff ff       	jmp    80107554 <alltraps>

80107c09 <vector13>:
.globl vector13
vector13:
  pushl $13
80107c09:	6a 0d                	push   $0xd
  jmp alltraps
80107c0b:	e9 44 f9 ff ff       	jmp    80107554 <alltraps>

80107c10 <vector14>:
.globl vector14
vector14:
  pushl $14
80107c10:	6a 0e                	push   $0xe
  jmp alltraps
80107c12:	e9 3d f9 ff ff       	jmp    80107554 <alltraps>

80107c17 <vector15>:
.globl vector15
vector15:
  pushl $0
80107c17:	6a 00                	push   $0x0
  pushl $15
80107c19:	6a 0f                	push   $0xf
  jmp alltraps
80107c1b:	e9 34 f9 ff ff       	jmp    80107554 <alltraps>

80107c20 <vector16>:
.globl vector16
vector16:
  pushl $0
80107c20:	6a 00                	push   $0x0
  pushl $16
80107c22:	6a 10                	push   $0x10
  jmp alltraps
80107c24:	e9 2b f9 ff ff       	jmp    80107554 <alltraps>

80107c29 <vector17>:
.globl vector17
vector17:
  pushl $17
80107c29:	6a 11                	push   $0x11
  jmp alltraps
80107c2b:	e9 24 f9 ff ff       	jmp    80107554 <alltraps>

80107c30 <vector18>:
.globl vector18
vector18:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $18
80107c32:	6a 12                	push   $0x12
  jmp alltraps
80107c34:	e9 1b f9 ff ff       	jmp    80107554 <alltraps>

80107c39 <vector19>:
.globl vector19
vector19:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $19
80107c3b:	6a 13                	push   $0x13
  jmp alltraps
80107c3d:	e9 12 f9 ff ff       	jmp    80107554 <alltraps>

80107c42 <vector20>:
.globl vector20
vector20:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $20
80107c44:	6a 14                	push   $0x14
  jmp alltraps
80107c46:	e9 09 f9 ff ff       	jmp    80107554 <alltraps>

80107c4b <vector21>:
.globl vector21
vector21:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $21
80107c4d:	6a 15                	push   $0x15
  jmp alltraps
80107c4f:	e9 00 f9 ff ff       	jmp    80107554 <alltraps>

80107c54 <vector22>:
.globl vector22
vector22:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $22
80107c56:	6a 16                	push   $0x16
  jmp alltraps
80107c58:	e9 f7 f8 ff ff       	jmp    80107554 <alltraps>

80107c5d <vector23>:
.globl vector23
vector23:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $23
80107c5f:	6a 17                	push   $0x17
  jmp alltraps
80107c61:	e9 ee f8 ff ff       	jmp    80107554 <alltraps>

80107c66 <vector24>:
.globl vector24
vector24:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $24
80107c68:	6a 18                	push   $0x18
  jmp alltraps
80107c6a:	e9 e5 f8 ff ff       	jmp    80107554 <alltraps>

80107c6f <vector25>:
.globl vector25
vector25:
  pushl $0
80107c6f:	6a 00                	push   $0x0
  pushl $25
80107c71:	6a 19                	push   $0x19
  jmp alltraps
80107c73:	e9 dc f8 ff ff       	jmp    80107554 <alltraps>

80107c78 <vector26>:
.globl vector26
vector26:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $26
80107c7a:	6a 1a                	push   $0x1a
  jmp alltraps
80107c7c:	e9 d3 f8 ff ff       	jmp    80107554 <alltraps>

80107c81 <vector27>:
.globl vector27
vector27:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $27
80107c83:	6a 1b                	push   $0x1b
  jmp alltraps
80107c85:	e9 ca f8 ff ff       	jmp    80107554 <alltraps>

80107c8a <vector28>:
.globl vector28
vector28:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $28
80107c8c:	6a 1c                	push   $0x1c
  jmp alltraps
80107c8e:	e9 c1 f8 ff ff       	jmp    80107554 <alltraps>

80107c93 <vector29>:
.globl vector29
vector29:
  pushl $0
80107c93:	6a 00                	push   $0x0
  pushl $29
80107c95:	6a 1d                	push   $0x1d
  jmp alltraps
80107c97:	e9 b8 f8 ff ff       	jmp    80107554 <alltraps>

80107c9c <vector30>:
.globl vector30
vector30:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $30
80107c9e:	6a 1e                	push   $0x1e
  jmp alltraps
80107ca0:	e9 af f8 ff ff       	jmp    80107554 <alltraps>

80107ca5 <vector31>:
.globl vector31
vector31:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $31
80107ca7:	6a 1f                	push   $0x1f
  jmp alltraps
80107ca9:	e9 a6 f8 ff ff       	jmp    80107554 <alltraps>

80107cae <vector32>:
.globl vector32
vector32:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $32
80107cb0:	6a 20                	push   $0x20
  jmp alltraps
80107cb2:	e9 9d f8 ff ff       	jmp    80107554 <alltraps>

80107cb7 <vector33>:
.globl vector33
vector33:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $33
80107cb9:	6a 21                	push   $0x21
  jmp alltraps
80107cbb:	e9 94 f8 ff ff       	jmp    80107554 <alltraps>

80107cc0 <vector34>:
.globl vector34
vector34:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $34
80107cc2:	6a 22                	push   $0x22
  jmp alltraps
80107cc4:	e9 8b f8 ff ff       	jmp    80107554 <alltraps>

80107cc9 <vector35>:
.globl vector35
vector35:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $35
80107ccb:	6a 23                	push   $0x23
  jmp alltraps
80107ccd:	e9 82 f8 ff ff       	jmp    80107554 <alltraps>

80107cd2 <vector36>:
.globl vector36
vector36:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $36
80107cd4:	6a 24                	push   $0x24
  jmp alltraps
80107cd6:	e9 79 f8 ff ff       	jmp    80107554 <alltraps>

80107cdb <vector37>:
.globl vector37
vector37:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $37
80107cdd:	6a 25                	push   $0x25
  jmp alltraps
80107cdf:	e9 70 f8 ff ff       	jmp    80107554 <alltraps>

80107ce4 <vector38>:
.globl vector38
vector38:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $38
80107ce6:	6a 26                	push   $0x26
  jmp alltraps
80107ce8:	e9 67 f8 ff ff       	jmp    80107554 <alltraps>

80107ced <vector39>:
.globl vector39
vector39:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $39
80107cef:	6a 27                	push   $0x27
  jmp alltraps
80107cf1:	e9 5e f8 ff ff       	jmp    80107554 <alltraps>

80107cf6 <vector40>:
.globl vector40
vector40:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $40
80107cf8:	6a 28                	push   $0x28
  jmp alltraps
80107cfa:	e9 55 f8 ff ff       	jmp    80107554 <alltraps>

80107cff <vector41>:
.globl vector41
vector41:
  pushl $0
80107cff:	6a 00                	push   $0x0
  pushl $41
80107d01:	6a 29                	push   $0x29
  jmp alltraps
80107d03:	e9 4c f8 ff ff       	jmp    80107554 <alltraps>

80107d08 <vector42>:
.globl vector42
vector42:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $42
80107d0a:	6a 2a                	push   $0x2a
  jmp alltraps
80107d0c:	e9 43 f8 ff ff       	jmp    80107554 <alltraps>

80107d11 <vector43>:
.globl vector43
vector43:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $43
80107d13:	6a 2b                	push   $0x2b
  jmp alltraps
80107d15:	e9 3a f8 ff ff       	jmp    80107554 <alltraps>

80107d1a <vector44>:
.globl vector44
vector44:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $44
80107d1c:	6a 2c                	push   $0x2c
  jmp alltraps
80107d1e:	e9 31 f8 ff ff       	jmp    80107554 <alltraps>

80107d23 <vector45>:
.globl vector45
vector45:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $45
80107d25:	6a 2d                	push   $0x2d
  jmp alltraps
80107d27:	e9 28 f8 ff ff       	jmp    80107554 <alltraps>

80107d2c <vector46>:
.globl vector46
vector46:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $46
80107d2e:	6a 2e                	push   $0x2e
  jmp alltraps
80107d30:	e9 1f f8 ff ff       	jmp    80107554 <alltraps>

80107d35 <vector47>:
.globl vector47
vector47:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $47
80107d37:	6a 2f                	push   $0x2f
  jmp alltraps
80107d39:	e9 16 f8 ff ff       	jmp    80107554 <alltraps>

80107d3e <vector48>:
.globl vector48
vector48:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $48
80107d40:	6a 30                	push   $0x30
  jmp alltraps
80107d42:	e9 0d f8 ff ff       	jmp    80107554 <alltraps>

80107d47 <vector49>:
.globl vector49
vector49:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $49
80107d49:	6a 31                	push   $0x31
  jmp alltraps
80107d4b:	e9 04 f8 ff ff       	jmp    80107554 <alltraps>

80107d50 <vector50>:
.globl vector50
vector50:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $50
80107d52:	6a 32                	push   $0x32
  jmp alltraps
80107d54:	e9 fb f7 ff ff       	jmp    80107554 <alltraps>

80107d59 <vector51>:
.globl vector51
vector51:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $51
80107d5b:	6a 33                	push   $0x33
  jmp alltraps
80107d5d:	e9 f2 f7 ff ff       	jmp    80107554 <alltraps>

80107d62 <vector52>:
.globl vector52
vector52:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $52
80107d64:	6a 34                	push   $0x34
  jmp alltraps
80107d66:	e9 e9 f7 ff ff       	jmp    80107554 <alltraps>

80107d6b <vector53>:
.globl vector53
vector53:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $53
80107d6d:	6a 35                	push   $0x35
  jmp alltraps
80107d6f:	e9 e0 f7 ff ff       	jmp    80107554 <alltraps>

80107d74 <vector54>:
.globl vector54
vector54:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $54
80107d76:	6a 36                	push   $0x36
  jmp alltraps
80107d78:	e9 d7 f7 ff ff       	jmp    80107554 <alltraps>

80107d7d <vector55>:
.globl vector55
vector55:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $55
80107d7f:	6a 37                	push   $0x37
  jmp alltraps
80107d81:	e9 ce f7 ff ff       	jmp    80107554 <alltraps>

80107d86 <vector56>:
.globl vector56
vector56:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $56
80107d88:	6a 38                	push   $0x38
  jmp alltraps
80107d8a:	e9 c5 f7 ff ff       	jmp    80107554 <alltraps>

80107d8f <vector57>:
.globl vector57
vector57:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $57
80107d91:	6a 39                	push   $0x39
  jmp alltraps
80107d93:	e9 bc f7 ff ff       	jmp    80107554 <alltraps>

80107d98 <vector58>:
.globl vector58
vector58:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $58
80107d9a:	6a 3a                	push   $0x3a
  jmp alltraps
80107d9c:	e9 b3 f7 ff ff       	jmp    80107554 <alltraps>

80107da1 <vector59>:
.globl vector59
vector59:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $59
80107da3:	6a 3b                	push   $0x3b
  jmp alltraps
80107da5:	e9 aa f7 ff ff       	jmp    80107554 <alltraps>

80107daa <vector60>:
.globl vector60
vector60:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $60
80107dac:	6a 3c                	push   $0x3c
  jmp alltraps
80107dae:	e9 a1 f7 ff ff       	jmp    80107554 <alltraps>

80107db3 <vector61>:
.globl vector61
vector61:
  pushl $0
80107db3:	6a 00                	push   $0x0
  pushl $61
80107db5:	6a 3d                	push   $0x3d
  jmp alltraps
80107db7:	e9 98 f7 ff ff       	jmp    80107554 <alltraps>

80107dbc <vector62>:
.globl vector62
vector62:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $62
80107dbe:	6a 3e                	push   $0x3e
  jmp alltraps
80107dc0:	e9 8f f7 ff ff       	jmp    80107554 <alltraps>

80107dc5 <vector63>:
.globl vector63
vector63:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $63
80107dc7:	6a 3f                	push   $0x3f
  jmp alltraps
80107dc9:	e9 86 f7 ff ff       	jmp    80107554 <alltraps>

80107dce <vector64>:
.globl vector64
vector64:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $64
80107dd0:	6a 40                	push   $0x40
  jmp alltraps
80107dd2:	e9 7d f7 ff ff       	jmp    80107554 <alltraps>

80107dd7 <vector65>:
.globl vector65
vector65:
  pushl $0
80107dd7:	6a 00                	push   $0x0
  pushl $65
80107dd9:	6a 41                	push   $0x41
  jmp alltraps
80107ddb:	e9 74 f7 ff ff       	jmp    80107554 <alltraps>

80107de0 <vector66>:
.globl vector66
vector66:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $66
80107de2:	6a 42                	push   $0x42
  jmp alltraps
80107de4:	e9 6b f7 ff ff       	jmp    80107554 <alltraps>

80107de9 <vector67>:
.globl vector67
vector67:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $67
80107deb:	6a 43                	push   $0x43
  jmp alltraps
80107ded:	e9 62 f7 ff ff       	jmp    80107554 <alltraps>

80107df2 <vector68>:
.globl vector68
vector68:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $68
80107df4:	6a 44                	push   $0x44
  jmp alltraps
80107df6:	e9 59 f7 ff ff       	jmp    80107554 <alltraps>

80107dfb <vector69>:
.globl vector69
vector69:
  pushl $0
80107dfb:	6a 00                	push   $0x0
  pushl $69
80107dfd:	6a 45                	push   $0x45
  jmp alltraps
80107dff:	e9 50 f7 ff ff       	jmp    80107554 <alltraps>

80107e04 <vector70>:
.globl vector70
vector70:
  pushl $0
80107e04:	6a 00                	push   $0x0
  pushl $70
80107e06:	6a 46                	push   $0x46
  jmp alltraps
80107e08:	e9 47 f7 ff ff       	jmp    80107554 <alltraps>

80107e0d <vector71>:
.globl vector71
vector71:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $71
80107e0f:	6a 47                	push   $0x47
  jmp alltraps
80107e11:	e9 3e f7 ff ff       	jmp    80107554 <alltraps>

80107e16 <vector72>:
.globl vector72
vector72:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $72
80107e18:	6a 48                	push   $0x48
  jmp alltraps
80107e1a:	e9 35 f7 ff ff       	jmp    80107554 <alltraps>

80107e1f <vector73>:
.globl vector73
vector73:
  pushl $0
80107e1f:	6a 00                	push   $0x0
  pushl $73
80107e21:	6a 49                	push   $0x49
  jmp alltraps
80107e23:	e9 2c f7 ff ff       	jmp    80107554 <alltraps>

80107e28 <vector74>:
.globl vector74
vector74:
  pushl $0
80107e28:	6a 00                	push   $0x0
  pushl $74
80107e2a:	6a 4a                	push   $0x4a
  jmp alltraps
80107e2c:	e9 23 f7 ff ff       	jmp    80107554 <alltraps>

80107e31 <vector75>:
.globl vector75
vector75:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $75
80107e33:	6a 4b                	push   $0x4b
  jmp alltraps
80107e35:	e9 1a f7 ff ff       	jmp    80107554 <alltraps>

80107e3a <vector76>:
.globl vector76
vector76:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $76
80107e3c:	6a 4c                	push   $0x4c
  jmp alltraps
80107e3e:	e9 11 f7 ff ff       	jmp    80107554 <alltraps>

80107e43 <vector77>:
.globl vector77
vector77:
  pushl $0
80107e43:	6a 00                	push   $0x0
  pushl $77
80107e45:	6a 4d                	push   $0x4d
  jmp alltraps
80107e47:	e9 08 f7 ff ff       	jmp    80107554 <alltraps>

80107e4c <vector78>:
.globl vector78
vector78:
  pushl $0
80107e4c:	6a 00                	push   $0x0
  pushl $78
80107e4e:	6a 4e                	push   $0x4e
  jmp alltraps
80107e50:	e9 ff f6 ff ff       	jmp    80107554 <alltraps>

80107e55 <vector79>:
.globl vector79
vector79:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $79
80107e57:	6a 4f                	push   $0x4f
  jmp alltraps
80107e59:	e9 f6 f6 ff ff       	jmp    80107554 <alltraps>

80107e5e <vector80>:
.globl vector80
vector80:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $80
80107e60:	6a 50                	push   $0x50
  jmp alltraps
80107e62:	e9 ed f6 ff ff       	jmp    80107554 <alltraps>

80107e67 <vector81>:
.globl vector81
vector81:
  pushl $0
80107e67:	6a 00                	push   $0x0
  pushl $81
80107e69:	6a 51                	push   $0x51
  jmp alltraps
80107e6b:	e9 e4 f6 ff ff       	jmp    80107554 <alltraps>

80107e70 <vector82>:
.globl vector82
vector82:
  pushl $0
80107e70:	6a 00                	push   $0x0
  pushl $82
80107e72:	6a 52                	push   $0x52
  jmp alltraps
80107e74:	e9 db f6 ff ff       	jmp    80107554 <alltraps>

80107e79 <vector83>:
.globl vector83
vector83:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $83
80107e7b:	6a 53                	push   $0x53
  jmp alltraps
80107e7d:	e9 d2 f6 ff ff       	jmp    80107554 <alltraps>

80107e82 <vector84>:
.globl vector84
vector84:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $84
80107e84:	6a 54                	push   $0x54
  jmp alltraps
80107e86:	e9 c9 f6 ff ff       	jmp    80107554 <alltraps>

80107e8b <vector85>:
.globl vector85
vector85:
  pushl $0
80107e8b:	6a 00                	push   $0x0
  pushl $85
80107e8d:	6a 55                	push   $0x55
  jmp alltraps
80107e8f:	e9 c0 f6 ff ff       	jmp    80107554 <alltraps>

80107e94 <vector86>:
.globl vector86
vector86:
  pushl $0
80107e94:	6a 00                	push   $0x0
  pushl $86
80107e96:	6a 56                	push   $0x56
  jmp alltraps
80107e98:	e9 b7 f6 ff ff       	jmp    80107554 <alltraps>

80107e9d <vector87>:
.globl vector87
vector87:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $87
80107e9f:	6a 57                	push   $0x57
  jmp alltraps
80107ea1:	e9 ae f6 ff ff       	jmp    80107554 <alltraps>

80107ea6 <vector88>:
.globl vector88
vector88:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $88
80107ea8:	6a 58                	push   $0x58
  jmp alltraps
80107eaa:	e9 a5 f6 ff ff       	jmp    80107554 <alltraps>

80107eaf <vector89>:
.globl vector89
vector89:
  pushl $0
80107eaf:	6a 00                	push   $0x0
  pushl $89
80107eb1:	6a 59                	push   $0x59
  jmp alltraps
80107eb3:	e9 9c f6 ff ff       	jmp    80107554 <alltraps>

80107eb8 <vector90>:
.globl vector90
vector90:
  pushl $0
80107eb8:	6a 00                	push   $0x0
  pushl $90
80107eba:	6a 5a                	push   $0x5a
  jmp alltraps
80107ebc:	e9 93 f6 ff ff       	jmp    80107554 <alltraps>

80107ec1 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $91
80107ec3:	6a 5b                	push   $0x5b
  jmp alltraps
80107ec5:	e9 8a f6 ff ff       	jmp    80107554 <alltraps>

80107eca <vector92>:
.globl vector92
vector92:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $92
80107ecc:	6a 5c                	push   $0x5c
  jmp alltraps
80107ece:	e9 81 f6 ff ff       	jmp    80107554 <alltraps>

80107ed3 <vector93>:
.globl vector93
vector93:
  pushl $0
80107ed3:	6a 00                	push   $0x0
  pushl $93
80107ed5:	6a 5d                	push   $0x5d
  jmp alltraps
80107ed7:	e9 78 f6 ff ff       	jmp    80107554 <alltraps>

80107edc <vector94>:
.globl vector94
vector94:
  pushl $0
80107edc:	6a 00                	push   $0x0
  pushl $94
80107ede:	6a 5e                	push   $0x5e
  jmp alltraps
80107ee0:	e9 6f f6 ff ff       	jmp    80107554 <alltraps>

80107ee5 <vector95>:
.globl vector95
vector95:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $95
80107ee7:	6a 5f                	push   $0x5f
  jmp alltraps
80107ee9:	e9 66 f6 ff ff       	jmp    80107554 <alltraps>

80107eee <vector96>:
.globl vector96
vector96:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $96
80107ef0:	6a 60                	push   $0x60
  jmp alltraps
80107ef2:	e9 5d f6 ff ff       	jmp    80107554 <alltraps>

80107ef7 <vector97>:
.globl vector97
vector97:
  pushl $0
80107ef7:	6a 00                	push   $0x0
  pushl $97
80107ef9:	6a 61                	push   $0x61
  jmp alltraps
80107efb:	e9 54 f6 ff ff       	jmp    80107554 <alltraps>

80107f00 <vector98>:
.globl vector98
vector98:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $98
80107f02:	6a 62                	push   $0x62
  jmp alltraps
80107f04:	e9 4b f6 ff ff       	jmp    80107554 <alltraps>

80107f09 <vector99>:
.globl vector99
vector99:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $99
80107f0b:	6a 63                	push   $0x63
  jmp alltraps
80107f0d:	e9 42 f6 ff ff       	jmp    80107554 <alltraps>

80107f12 <vector100>:
.globl vector100
vector100:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $100
80107f14:	6a 64                	push   $0x64
  jmp alltraps
80107f16:	e9 39 f6 ff ff       	jmp    80107554 <alltraps>

80107f1b <vector101>:
.globl vector101
vector101:
  pushl $0
80107f1b:	6a 00                	push   $0x0
  pushl $101
80107f1d:	6a 65                	push   $0x65
  jmp alltraps
80107f1f:	e9 30 f6 ff ff       	jmp    80107554 <alltraps>

80107f24 <vector102>:
.globl vector102
vector102:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $102
80107f26:	6a 66                	push   $0x66
  jmp alltraps
80107f28:	e9 27 f6 ff ff       	jmp    80107554 <alltraps>

80107f2d <vector103>:
.globl vector103
vector103:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $103
80107f2f:	6a 67                	push   $0x67
  jmp alltraps
80107f31:	e9 1e f6 ff ff       	jmp    80107554 <alltraps>

80107f36 <vector104>:
.globl vector104
vector104:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $104
80107f38:	6a 68                	push   $0x68
  jmp alltraps
80107f3a:	e9 15 f6 ff ff       	jmp    80107554 <alltraps>

80107f3f <vector105>:
.globl vector105
vector105:
  pushl $0
80107f3f:	6a 00                	push   $0x0
  pushl $105
80107f41:	6a 69                	push   $0x69
  jmp alltraps
80107f43:	e9 0c f6 ff ff       	jmp    80107554 <alltraps>

80107f48 <vector106>:
.globl vector106
vector106:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $106
80107f4a:	6a 6a                	push   $0x6a
  jmp alltraps
80107f4c:	e9 03 f6 ff ff       	jmp    80107554 <alltraps>

80107f51 <vector107>:
.globl vector107
vector107:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $107
80107f53:	6a 6b                	push   $0x6b
  jmp alltraps
80107f55:	e9 fa f5 ff ff       	jmp    80107554 <alltraps>

80107f5a <vector108>:
.globl vector108
vector108:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $108
80107f5c:	6a 6c                	push   $0x6c
  jmp alltraps
80107f5e:	e9 f1 f5 ff ff       	jmp    80107554 <alltraps>

80107f63 <vector109>:
.globl vector109
vector109:
  pushl $0
80107f63:	6a 00                	push   $0x0
  pushl $109
80107f65:	6a 6d                	push   $0x6d
  jmp alltraps
80107f67:	e9 e8 f5 ff ff       	jmp    80107554 <alltraps>

80107f6c <vector110>:
.globl vector110
vector110:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $110
80107f6e:	6a 6e                	push   $0x6e
  jmp alltraps
80107f70:	e9 df f5 ff ff       	jmp    80107554 <alltraps>

80107f75 <vector111>:
.globl vector111
vector111:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $111
80107f77:	6a 6f                	push   $0x6f
  jmp alltraps
80107f79:	e9 d6 f5 ff ff       	jmp    80107554 <alltraps>

80107f7e <vector112>:
.globl vector112
vector112:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $112
80107f80:	6a 70                	push   $0x70
  jmp alltraps
80107f82:	e9 cd f5 ff ff       	jmp    80107554 <alltraps>

80107f87 <vector113>:
.globl vector113
vector113:
  pushl $0
80107f87:	6a 00                	push   $0x0
  pushl $113
80107f89:	6a 71                	push   $0x71
  jmp alltraps
80107f8b:	e9 c4 f5 ff ff       	jmp    80107554 <alltraps>

80107f90 <vector114>:
.globl vector114
vector114:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $114
80107f92:	6a 72                	push   $0x72
  jmp alltraps
80107f94:	e9 bb f5 ff ff       	jmp    80107554 <alltraps>

80107f99 <vector115>:
.globl vector115
vector115:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $115
80107f9b:	6a 73                	push   $0x73
  jmp alltraps
80107f9d:	e9 b2 f5 ff ff       	jmp    80107554 <alltraps>

80107fa2 <vector116>:
.globl vector116
vector116:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $116
80107fa4:	6a 74                	push   $0x74
  jmp alltraps
80107fa6:	e9 a9 f5 ff ff       	jmp    80107554 <alltraps>

80107fab <vector117>:
.globl vector117
vector117:
  pushl $0
80107fab:	6a 00                	push   $0x0
  pushl $117
80107fad:	6a 75                	push   $0x75
  jmp alltraps
80107faf:	e9 a0 f5 ff ff       	jmp    80107554 <alltraps>

80107fb4 <vector118>:
.globl vector118
vector118:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $118
80107fb6:	6a 76                	push   $0x76
  jmp alltraps
80107fb8:	e9 97 f5 ff ff       	jmp    80107554 <alltraps>

80107fbd <vector119>:
.globl vector119
vector119:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $119
80107fbf:	6a 77                	push   $0x77
  jmp alltraps
80107fc1:	e9 8e f5 ff ff       	jmp    80107554 <alltraps>

80107fc6 <vector120>:
.globl vector120
vector120:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $120
80107fc8:	6a 78                	push   $0x78
  jmp alltraps
80107fca:	e9 85 f5 ff ff       	jmp    80107554 <alltraps>

80107fcf <vector121>:
.globl vector121
vector121:
  pushl $0
80107fcf:	6a 00                	push   $0x0
  pushl $121
80107fd1:	6a 79                	push   $0x79
  jmp alltraps
80107fd3:	e9 7c f5 ff ff       	jmp    80107554 <alltraps>

80107fd8 <vector122>:
.globl vector122
vector122:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $122
80107fda:	6a 7a                	push   $0x7a
  jmp alltraps
80107fdc:	e9 73 f5 ff ff       	jmp    80107554 <alltraps>

80107fe1 <vector123>:
.globl vector123
vector123:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $123
80107fe3:	6a 7b                	push   $0x7b
  jmp alltraps
80107fe5:	e9 6a f5 ff ff       	jmp    80107554 <alltraps>

80107fea <vector124>:
.globl vector124
vector124:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $124
80107fec:	6a 7c                	push   $0x7c
  jmp alltraps
80107fee:	e9 61 f5 ff ff       	jmp    80107554 <alltraps>

80107ff3 <vector125>:
.globl vector125
vector125:
  pushl $0
80107ff3:	6a 00                	push   $0x0
  pushl $125
80107ff5:	6a 7d                	push   $0x7d
  jmp alltraps
80107ff7:	e9 58 f5 ff ff       	jmp    80107554 <alltraps>

80107ffc <vector126>:
.globl vector126
vector126:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $126
80107ffe:	6a 7e                	push   $0x7e
  jmp alltraps
80108000:	e9 4f f5 ff ff       	jmp    80107554 <alltraps>

80108005 <vector127>:
.globl vector127
vector127:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $127
80108007:	6a 7f                	push   $0x7f
  jmp alltraps
80108009:	e9 46 f5 ff ff       	jmp    80107554 <alltraps>

8010800e <vector128>:
.globl vector128
vector128:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $128
80108010:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108015:	e9 3a f5 ff ff       	jmp    80107554 <alltraps>

8010801a <vector129>:
.globl vector129
vector129:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $129
8010801c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108021:	e9 2e f5 ff ff       	jmp    80107554 <alltraps>

80108026 <vector130>:
.globl vector130
vector130:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $130
80108028:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010802d:	e9 22 f5 ff ff       	jmp    80107554 <alltraps>

80108032 <vector131>:
.globl vector131
vector131:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $131
80108034:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108039:	e9 16 f5 ff ff       	jmp    80107554 <alltraps>

8010803e <vector132>:
.globl vector132
vector132:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $132
80108040:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108045:	e9 0a f5 ff ff       	jmp    80107554 <alltraps>

8010804a <vector133>:
.globl vector133
vector133:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $133
8010804c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108051:	e9 fe f4 ff ff       	jmp    80107554 <alltraps>

80108056 <vector134>:
.globl vector134
vector134:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $134
80108058:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010805d:	e9 f2 f4 ff ff       	jmp    80107554 <alltraps>

80108062 <vector135>:
.globl vector135
vector135:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $135
80108064:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108069:	e9 e6 f4 ff ff       	jmp    80107554 <alltraps>

8010806e <vector136>:
.globl vector136
vector136:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $136
80108070:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108075:	e9 da f4 ff ff       	jmp    80107554 <alltraps>

8010807a <vector137>:
.globl vector137
vector137:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $137
8010807c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108081:	e9 ce f4 ff ff       	jmp    80107554 <alltraps>

80108086 <vector138>:
.globl vector138
vector138:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $138
80108088:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010808d:	e9 c2 f4 ff ff       	jmp    80107554 <alltraps>

80108092 <vector139>:
.globl vector139
vector139:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $139
80108094:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108099:	e9 b6 f4 ff ff       	jmp    80107554 <alltraps>

8010809e <vector140>:
.globl vector140
vector140:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $140
801080a0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801080a5:	e9 aa f4 ff ff       	jmp    80107554 <alltraps>

801080aa <vector141>:
.globl vector141
vector141:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $141
801080ac:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801080b1:	e9 9e f4 ff ff       	jmp    80107554 <alltraps>

801080b6 <vector142>:
.globl vector142
vector142:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $142
801080b8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801080bd:	e9 92 f4 ff ff       	jmp    80107554 <alltraps>

801080c2 <vector143>:
.globl vector143
vector143:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $143
801080c4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801080c9:	e9 86 f4 ff ff       	jmp    80107554 <alltraps>

801080ce <vector144>:
.globl vector144
vector144:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $144
801080d0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801080d5:	e9 7a f4 ff ff       	jmp    80107554 <alltraps>

801080da <vector145>:
.globl vector145
vector145:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $145
801080dc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801080e1:	e9 6e f4 ff ff       	jmp    80107554 <alltraps>

801080e6 <vector146>:
.globl vector146
vector146:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $146
801080e8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801080ed:	e9 62 f4 ff ff       	jmp    80107554 <alltraps>

801080f2 <vector147>:
.globl vector147
vector147:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $147
801080f4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801080f9:	e9 56 f4 ff ff       	jmp    80107554 <alltraps>

801080fe <vector148>:
.globl vector148
vector148:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $148
80108100:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108105:	e9 4a f4 ff ff       	jmp    80107554 <alltraps>

8010810a <vector149>:
.globl vector149
vector149:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $149
8010810c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108111:	e9 3e f4 ff ff       	jmp    80107554 <alltraps>

80108116 <vector150>:
.globl vector150
vector150:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $150
80108118:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010811d:	e9 32 f4 ff ff       	jmp    80107554 <alltraps>

80108122 <vector151>:
.globl vector151
vector151:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $151
80108124:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108129:	e9 26 f4 ff ff       	jmp    80107554 <alltraps>

8010812e <vector152>:
.globl vector152
vector152:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $152
80108130:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108135:	e9 1a f4 ff ff       	jmp    80107554 <alltraps>

8010813a <vector153>:
.globl vector153
vector153:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $153
8010813c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108141:	e9 0e f4 ff ff       	jmp    80107554 <alltraps>

80108146 <vector154>:
.globl vector154
vector154:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $154
80108148:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010814d:	e9 02 f4 ff ff       	jmp    80107554 <alltraps>

80108152 <vector155>:
.globl vector155
vector155:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $155
80108154:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108159:	e9 f6 f3 ff ff       	jmp    80107554 <alltraps>

8010815e <vector156>:
.globl vector156
vector156:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $156
80108160:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108165:	e9 ea f3 ff ff       	jmp    80107554 <alltraps>

8010816a <vector157>:
.globl vector157
vector157:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $157
8010816c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108171:	e9 de f3 ff ff       	jmp    80107554 <alltraps>

80108176 <vector158>:
.globl vector158
vector158:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $158
80108178:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010817d:	e9 d2 f3 ff ff       	jmp    80107554 <alltraps>

80108182 <vector159>:
.globl vector159
vector159:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $159
80108184:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108189:	e9 c6 f3 ff ff       	jmp    80107554 <alltraps>

8010818e <vector160>:
.globl vector160
vector160:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $160
80108190:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108195:	e9 ba f3 ff ff       	jmp    80107554 <alltraps>

8010819a <vector161>:
.globl vector161
vector161:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $161
8010819c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801081a1:	e9 ae f3 ff ff       	jmp    80107554 <alltraps>

801081a6 <vector162>:
.globl vector162
vector162:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $162
801081a8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801081ad:	e9 a2 f3 ff ff       	jmp    80107554 <alltraps>

801081b2 <vector163>:
.globl vector163
vector163:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $163
801081b4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801081b9:	e9 96 f3 ff ff       	jmp    80107554 <alltraps>

801081be <vector164>:
.globl vector164
vector164:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $164
801081c0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801081c5:	e9 8a f3 ff ff       	jmp    80107554 <alltraps>

801081ca <vector165>:
.globl vector165
vector165:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $165
801081cc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801081d1:	e9 7e f3 ff ff       	jmp    80107554 <alltraps>

801081d6 <vector166>:
.globl vector166
vector166:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $166
801081d8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801081dd:	e9 72 f3 ff ff       	jmp    80107554 <alltraps>

801081e2 <vector167>:
.globl vector167
vector167:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $167
801081e4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801081e9:	e9 66 f3 ff ff       	jmp    80107554 <alltraps>

801081ee <vector168>:
.globl vector168
vector168:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $168
801081f0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801081f5:	e9 5a f3 ff ff       	jmp    80107554 <alltraps>

801081fa <vector169>:
.globl vector169
vector169:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $169
801081fc:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108201:	e9 4e f3 ff ff       	jmp    80107554 <alltraps>

80108206 <vector170>:
.globl vector170
vector170:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $170
80108208:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010820d:	e9 42 f3 ff ff       	jmp    80107554 <alltraps>

80108212 <vector171>:
.globl vector171
vector171:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $171
80108214:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108219:	e9 36 f3 ff ff       	jmp    80107554 <alltraps>

8010821e <vector172>:
.globl vector172
vector172:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $172
80108220:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108225:	e9 2a f3 ff ff       	jmp    80107554 <alltraps>

8010822a <vector173>:
.globl vector173
vector173:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $173
8010822c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108231:	e9 1e f3 ff ff       	jmp    80107554 <alltraps>

80108236 <vector174>:
.globl vector174
vector174:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $174
80108238:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010823d:	e9 12 f3 ff ff       	jmp    80107554 <alltraps>

80108242 <vector175>:
.globl vector175
vector175:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $175
80108244:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108249:	e9 06 f3 ff ff       	jmp    80107554 <alltraps>

8010824e <vector176>:
.globl vector176
vector176:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $176
80108250:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108255:	e9 fa f2 ff ff       	jmp    80107554 <alltraps>

8010825a <vector177>:
.globl vector177
vector177:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $177
8010825c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108261:	e9 ee f2 ff ff       	jmp    80107554 <alltraps>

80108266 <vector178>:
.globl vector178
vector178:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $178
80108268:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010826d:	e9 e2 f2 ff ff       	jmp    80107554 <alltraps>

80108272 <vector179>:
.globl vector179
vector179:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $179
80108274:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108279:	e9 d6 f2 ff ff       	jmp    80107554 <alltraps>

8010827e <vector180>:
.globl vector180
vector180:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $180
80108280:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108285:	e9 ca f2 ff ff       	jmp    80107554 <alltraps>

8010828a <vector181>:
.globl vector181
vector181:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $181
8010828c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108291:	e9 be f2 ff ff       	jmp    80107554 <alltraps>

80108296 <vector182>:
.globl vector182
vector182:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $182
80108298:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010829d:	e9 b2 f2 ff ff       	jmp    80107554 <alltraps>

801082a2 <vector183>:
.globl vector183
vector183:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $183
801082a4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801082a9:	e9 a6 f2 ff ff       	jmp    80107554 <alltraps>

801082ae <vector184>:
.globl vector184
vector184:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $184
801082b0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801082b5:	e9 9a f2 ff ff       	jmp    80107554 <alltraps>

801082ba <vector185>:
.globl vector185
vector185:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $185
801082bc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801082c1:	e9 8e f2 ff ff       	jmp    80107554 <alltraps>

801082c6 <vector186>:
.globl vector186
vector186:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $186
801082c8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801082cd:	e9 82 f2 ff ff       	jmp    80107554 <alltraps>

801082d2 <vector187>:
.globl vector187
vector187:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $187
801082d4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801082d9:	e9 76 f2 ff ff       	jmp    80107554 <alltraps>

801082de <vector188>:
.globl vector188
vector188:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $188
801082e0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801082e5:	e9 6a f2 ff ff       	jmp    80107554 <alltraps>

801082ea <vector189>:
.globl vector189
vector189:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $189
801082ec:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801082f1:	e9 5e f2 ff ff       	jmp    80107554 <alltraps>

801082f6 <vector190>:
.globl vector190
vector190:
  pushl $0
801082f6:	6a 00                	push   $0x0
  pushl $190
801082f8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801082fd:	e9 52 f2 ff ff       	jmp    80107554 <alltraps>

80108302 <vector191>:
.globl vector191
vector191:
  pushl $0
80108302:	6a 00                	push   $0x0
  pushl $191
80108304:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108309:	e9 46 f2 ff ff       	jmp    80107554 <alltraps>

8010830e <vector192>:
.globl vector192
vector192:
  pushl $0
8010830e:	6a 00                	push   $0x0
  pushl $192
80108310:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108315:	e9 3a f2 ff ff       	jmp    80107554 <alltraps>

8010831a <vector193>:
.globl vector193
vector193:
  pushl $0
8010831a:	6a 00                	push   $0x0
  pushl $193
8010831c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108321:	e9 2e f2 ff ff       	jmp    80107554 <alltraps>

80108326 <vector194>:
.globl vector194
vector194:
  pushl $0
80108326:	6a 00                	push   $0x0
  pushl $194
80108328:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010832d:	e9 22 f2 ff ff       	jmp    80107554 <alltraps>

80108332 <vector195>:
.globl vector195
vector195:
  pushl $0
80108332:	6a 00                	push   $0x0
  pushl $195
80108334:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108339:	e9 16 f2 ff ff       	jmp    80107554 <alltraps>

8010833e <vector196>:
.globl vector196
vector196:
  pushl $0
8010833e:	6a 00                	push   $0x0
  pushl $196
80108340:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108345:	e9 0a f2 ff ff       	jmp    80107554 <alltraps>

8010834a <vector197>:
.globl vector197
vector197:
  pushl $0
8010834a:	6a 00                	push   $0x0
  pushl $197
8010834c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108351:	e9 fe f1 ff ff       	jmp    80107554 <alltraps>

80108356 <vector198>:
.globl vector198
vector198:
  pushl $0
80108356:	6a 00                	push   $0x0
  pushl $198
80108358:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010835d:	e9 f2 f1 ff ff       	jmp    80107554 <alltraps>

80108362 <vector199>:
.globl vector199
vector199:
  pushl $0
80108362:	6a 00                	push   $0x0
  pushl $199
80108364:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108369:	e9 e6 f1 ff ff       	jmp    80107554 <alltraps>

8010836e <vector200>:
.globl vector200
vector200:
  pushl $0
8010836e:	6a 00                	push   $0x0
  pushl $200
80108370:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108375:	e9 da f1 ff ff       	jmp    80107554 <alltraps>

8010837a <vector201>:
.globl vector201
vector201:
  pushl $0
8010837a:	6a 00                	push   $0x0
  pushl $201
8010837c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108381:	e9 ce f1 ff ff       	jmp    80107554 <alltraps>

80108386 <vector202>:
.globl vector202
vector202:
  pushl $0
80108386:	6a 00                	push   $0x0
  pushl $202
80108388:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010838d:	e9 c2 f1 ff ff       	jmp    80107554 <alltraps>

80108392 <vector203>:
.globl vector203
vector203:
  pushl $0
80108392:	6a 00                	push   $0x0
  pushl $203
80108394:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108399:	e9 b6 f1 ff ff       	jmp    80107554 <alltraps>

8010839e <vector204>:
.globl vector204
vector204:
  pushl $0
8010839e:	6a 00                	push   $0x0
  pushl $204
801083a0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801083a5:	e9 aa f1 ff ff       	jmp    80107554 <alltraps>

801083aa <vector205>:
.globl vector205
vector205:
  pushl $0
801083aa:	6a 00                	push   $0x0
  pushl $205
801083ac:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801083b1:	e9 9e f1 ff ff       	jmp    80107554 <alltraps>

801083b6 <vector206>:
.globl vector206
vector206:
  pushl $0
801083b6:	6a 00                	push   $0x0
  pushl $206
801083b8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801083bd:	e9 92 f1 ff ff       	jmp    80107554 <alltraps>

801083c2 <vector207>:
.globl vector207
vector207:
  pushl $0
801083c2:	6a 00                	push   $0x0
  pushl $207
801083c4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801083c9:	e9 86 f1 ff ff       	jmp    80107554 <alltraps>

801083ce <vector208>:
.globl vector208
vector208:
  pushl $0
801083ce:	6a 00                	push   $0x0
  pushl $208
801083d0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801083d5:	e9 7a f1 ff ff       	jmp    80107554 <alltraps>

801083da <vector209>:
.globl vector209
vector209:
  pushl $0
801083da:	6a 00                	push   $0x0
  pushl $209
801083dc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801083e1:	e9 6e f1 ff ff       	jmp    80107554 <alltraps>

801083e6 <vector210>:
.globl vector210
vector210:
  pushl $0
801083e6:	6a 00                	push   $0x0
  pushl $210
801083e8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801083ed:	e9 62 f1 ff ff       	jmp    80107554 <alltraps>

801083f2 <vector211>:
.globl vector211
vector211:
  pushl $0
801083f2:	6a 00                	push   $0x0
  pushl $211
801083f4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801083f9:	e9 56 f1 ff ff       	jmp    80107554 <alltraps>

801083fe <vector212>:
.globl vector212
vector212:
  pushl $0
801083fe:	6a 00                	push   $0x0
  pushl $212
80108400:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108405:	e9 4a f1 ff ff       	jmp    80107554 <alltraps>

8010840a <vector213>:
.globl vector213
vector213:
  pushl $0
8010840a:	6a 00                	push   $0x0
  pushl $213
8010840c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108411:	e9 3e f1 ff ff       	jmp    80107554 <alltraps>

80108416 <vector214>:
.globl vector214
vector214:
  pushl $0
80108416:	6a 00                	push   $0x0
  pushl $214
80108418:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010841d:	e9 32 f1 ff ff       	jmp    80107554 <alltraps>

80108422 <vector215>:
.globl vector215
vector215:
  pushl $0
80108422:	6a 00                	push   $0x0
  pushl $215
80108424:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108429:	e9 26 f1 ff ff       	jmp    80107554 <alltraps>

8010842e <vector216>:
.globl vector216
vector216:
  pushl $0
8010842e:	6a 00                	push   $0x0
  pushl $216
80108430:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108435:	e9 1a f1 ff ff       	jmp    80107554 <alltraps>

8010843a <vector217>:
.globl vector217
vector217:
  pushl $0
8010843a:	6a 00                	push   $0x0
  pushl $217
8010843c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108441:	e9 0e f1 ff ff       	jmp    80107554 <alltraps>

80108446 <vector218>:
.globl vector218
vector218:
  pushl $0
80108446:	6a 00                	push   $0x0
  pushl $218
80108448:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010844d:	e9 02 f1 ff ff       	jmp    80107554 <alltraps>

80108452 <vector219>:
.globl vector219
vector219:
  pushl $0
80108452:	6a 00                	push   $0x0
  pushl $219
80108454:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108459:	e9 f6 f0 ff ff       	jmp    80107554 <alltraps>

8010845e <vector220>:
.globl vector220
vector220:
  pushl $0
8010845e:	6a 00                	push   $0x0
  pushl $220
80108460:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108465:	e9 ea f0 ff ff       	jmp    80107554 <alltraps>

8010846a <vector221>:
.globl vector221
vector221:
  pushl $0
8010846a:	6a 00                	push   $0x0
  pushl $221
8010846c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108471:	e9 de f0 ff ff       	jmp    80107554 <alltraps>

80108476 <vector222>:
.globl vector222
vector222:
  pushl $0
80108476:	6a 00                	push   $0x0
  pushl $222
80108478:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010847d:	e9 d2 f0 ff ff       	jmp    80107554 <alltraps>

80108482 <vector223>:
.globl vector223
vector223:
  pushl $0
80108482:	6a 00                	push   $0x0
  pushl $223
80108484:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108489:	e9 c6 f0 ff ff       	jmp    80107554 <alltraps>

8010848e <vector224>:
.globl vector224
vector224:
  pushl $0
8010848e:	6a 00                	push   $0x0
  pushl $224
80108490:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108495:	e9 ba f0 ff ff       	jmp    80107554 <alltraps>

8010849a <vector225>:
.globl vector225
vector225:
  pushl $0
8010849a:	6a 00                	push   $0x0
  pushl $225
8010849c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801084a1:	e9 ae f0 ff ff       	jmp    80107554 <alltraps>

801084a6 <vector226>:
.globl vector226
vector226:
  pushl $0
801084a6:	6a 00                	push   $0x0
  pushl $226
801084a8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801084ad:	e9 a2 f0 ff ff       	jmp    80107554 <alltraps>

801084b2 <vector227>:
.globl vector227
vector227:
  pushl $0
801084b2:	6a 00                	push   $0x0
  pushl $227
801084b4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801084b9:	e9 96 f0 ff ff       	jmp    80107554 <alltraps>

801084be <vector228>:
.globl vector228
vector228:
  pushl $0
801084be:	6a 00                	push   $0x0
  pushl $228
801084c0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801084c5:	e9 8a f0 ff ff       	jmp    80107554 <alltraps>

801084ca <vector229>:
.globl vector229
vector229:
  pushl $0
801084ca:	6a 00                	push   $0x0
  pushl $229
801084cc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801084d1:	e9 7e f0 ff ff       	jmp    80107554 <alltraps>

801084d6 <vector230>:
.globl vector230
vector230:
  pushl $0
801084d6:	6a 00                	push   $0x0
  pushl $230
801084d8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801084dd:	e9 72 f0 ff ff       	jmp    80107554 <alltraps>

801084e2 <vector231>:
.globl vector231
vector231:
  pushl $0
801084e2:	6a 00                	push   $0x0
  pushl $231
801084e4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801084e9:	e9 66 f0 ff ff       	jmp    80107554 <alltraps>

801084ee <vector232>:
.globl vector232
vector232:
  pushl $0
801084ee:	6a 00                	push   $0x0
  pushl $232
801084f0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801084f5:	e9 5a f0 ff ff       	jmp    80107554 <alltraps>

801084fa <vector233>:
.globl vector233
vector233:
  pushl $0
801084fa:	6a 00                	push   $0x0
  pushl $233
801084fc:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108501:	e9 4e f0 ff ff       	jmp    80107554 <alltraps>

80108506 <vector234>:
.globl vector234
vector234:
  pushl $0
80108506:	6a 00                	push   $0x0
  pushl $234
80108508:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010850d:	e9 42 f0 ff ff       	jmp    80107554 <alltraps>

80108512 <vector235>:
.globl vector235
vector235:
  pushl $0
80108512:	6a 00                	push   $0x0
  pushl $235
80108514:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108519:	e9 36 f0 ff ff       	jmp    80107554 <alltraps>

8010851e <vector236>:
.globl vector236
vector236:
  pushl $0
8010851e:	6a 00                	push   $0x0
  pushl $236
80108520:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108525:	e9 2a f0 ff ff       	jmp    80107554 <alltraps>

8010852a <vector237>:
.globl vector237
vector237:
  pushl $0
8010852a:	6a 00                	push   $0x0
  pushl $237
8010852c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108531:	e9 1e f0 ff ff       	jmp    80107554 <alltraps>

80108536 <vector238>:
.globl vector238
vector238:
  pushl $0
80108536:	6a 00                	push   $0x0
  pushl $238
80108538:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010853d:	e9 12 f0 ff ff       	jmp    80107554 <alltraps>

80108542 <vector239>:
.globl vector239
vector239:
  pushl $0
80108542:	6a 00                	push   $0x0
  pushl $239
80108544:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108549:	e9 06 f0 ff ff       	jmp    80107554 <alltraps>

8010854e <vector240>:
.globl vector240
vector240:
  pushl $0
8010854e:	6a 00                	push   $0x0
  pushl $240
80108550:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108555:	e9 fa ef ff ff       	jmp    80107554 <alltraps>

8010855a <vector241>:
.globl vector241
vector241:
  pushl $0
8010855a:	6a 00                	push   $0x0
  pushl $241
8010855c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108561:	e9 ee ef ff ff       	jmp    80107554 <alltraps>

80108566 <vector242>:
.globl vector242
vector242:
  pushl $0
80108566:	6a 00                	push   $0x0
  pushl $242
80108568:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010856d:	e9 e2 ef ff ff       	jmp    80107554 <alltraps>

80108572 <vector243>:
.globl vector243
vector243:
  pushl $0
80108572:	6a 00                	push   $0x0
  pushl $243
80108574:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108579:	e9 d6 ef ff ff       	jmp    80107554 <alltraps>

8010857e <vector244>:
.globl vector244
vector244:
  pushl $0
8010857e:	6a 00                	push   $0x0
  pushl $244
80108580:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108585:	e9 ca ef ff ff       	jmp    80107554 <alltraps>

8010858a <vector245>:
.globl vector245
vector245:
  pushl $0
8010858a:	6a 00                	push   $0x0
  pushl $245
8010858c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108591:	e9 be ef ff ff       	jmp    80107554 <alltraps>

80108596 <vector246>:
.globl vector246
vector246:
  pushl $0
80108596:	6a 00                	push   $0x0
  pushl $246
80108598:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010859d:	e9 b2 ef ff ff       	jmp    80107554 <alltraps>

801085a2 <vector247>:
.globl vector247
vector247:
  pushl $0
801085a2:	6a 00                	push   $0x0
  pushl $247
801085a4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801085a9:	e9 a6 ef ff ff       	jmp    80107554 <alltraps>

801085ae <vector248>:
.globl vector248
vector248:
  pushl $0
801085ae:	6a 00                	push   $0x0
  pushl $248
801085b0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801085b5:	e9 9a ef ff ff       	jmp    80107554 <alltraps>

801085ba <vector249>:
.globl vector249
vector249:
  pushl $0
801085ba:	6a 00                	push   $0x0
  pushl $249
801085bc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801085c1:	e9 8e ef ff ff       	jmp    80107554 <alltraps>

801085c6 <vector250>:
.globl vector250
vector250:
  pushl $0
801085c6:	6a 00                	push   $0x0
  pushl $250
801085c8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801085cd:	e9 82 ef ff ff       	jmp    80107554 <alltraps>

801085d2 <vector251>:
.globl vector251
vector251:
  pushl $0
801085d2:	6a 00                	push   $0x0
  pushl $251
801085d4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801085d9:	e9 76 ef ff ff       	jmp    80107554 <alltraps>

801085de <vector252>:
.globl vector252
vector252:
  pushl $0
801085de:	6a 00                	push   $0x0
  pushl $252
801085e0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801085e5:	e9 6a ef ff ff       	jmp    80107554 <alltraps>

801085ea <vector253>:
.globl vector253
vector253:
  pushl $0
801085ea:	6a 00                	push   $0x0
  pushl $253
801085ec:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801085f1:	e9 5e ef ff ff       	jmp    80107554 <alltraps>

801085f6 <vector254>:
.globl vector254
vector254:
  pushl $0
801085f6:	6a 00                	push   $0x0
  pushl $254
801085f8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801085fd:	e9 52 ef ff ff       	jmp    80107554 <alltraps>

80108602 <vector255>:
.globl vector255
vector255:
  pushl $0
80108602:	6a 00                	push   $0x0
  pushl $255
80108604:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108609:	e9 46 ef ff ff       	jmp    80107554 <alltraps>
	...

80108610 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108610:	55                   	push   %ebp
80108611:	89 e5                	mov    %esp,%ebp
80108613:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108616:	8b 45 0c             	mov    0xc(%ebp),%eax
80108619:	48                   	dec    %eax
8010861a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010861e:	8b 45 08             	mov    0x8(%ebp),%eax
80108621:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108625:	8b 45 08             	mov    0x8(%ebp),%eax
80108628:	c1 e8 10             	shr    $0x10,%eax
8010862b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010862f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108632:	0f 01 10             	lgdtl  (%eax)
}
80108635:	c9                   	leave  
80108636:	c3                   	ret    

80108637 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108637:	55                   	push   %ebp
80108638:	89 e5                	mov    %esp,%ebp
8010863a:	83 ec 04             	sub    $0x4,%esp
8010863d:	8b 45 08             	mov    0x8(%ebp),%eax
80108640:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108644:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108647:	0f 00 d8             	ltr    %ax
}
8010864a:	c9                   	leave  
8010864b:	c3                   	ret    

8010864c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010864c:	55                   	push   %ebp
8010864d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010864f:	8b 45 08             	mov    0x8(%ebp),%eax
80108652:	0f 22 d8             	mov    %eax,%cr3
}
80108655:	5d                   	pop    %ebp
80108656:	c3                   	ret    

80108657 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108657:	55                   	push   %ebp
80108658:	89 e5                	mov    %esp,%ebp
8010865a:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010865d:	e8 a8 be ff ff       	call   8010450a <cpuid>
80108662:	89 c2                	mov    %eax,%edx
80108664:	89 d0                	mov    %edx,%eax
80108666:	c1 e0 02             	shl    $0x2,%eax
80108669:	01 d0                	add    %edx,%eax
8010866b:	01 c0                	add    %eax,%eax
8010866d:	01 d0                	add    %edx,%eax
8010866f:	c1 e0 04             	shl    $0x4,%eax
80108672:	05 00 5d 11 80       	add    $0x80115d00,%eax
80108677:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010867a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108686:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010868c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108696:	8a 50 7d             	mov    0x7d(%eax),%dl
80108699:	83 e2 f0             	and    $0xfffffff0,%edx
8010869c:	83 ca 0a             	or     $0xa,%edx
8010869f:	88 50 7d             	mov    %dl,0x7d(%eax)
801086a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a5:	8a 50 7d             	mov    0x7d(%eax),%dl
801086a8:	83 ca 10             	or     $0x10,%edx
801086ab:	88 50 7d             	mov    %dl,0x7d(%eax)
801086ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b1:	8a 50 7d             	mov    0x7d(%eax),%dl
801086b4:	83 e2 9f             	and    $0xffffff9f,%edx
801086b7:	88 50 7d             	mov    %dl,0x7d(%eax)
801086ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bd:	8a 50 7d             	mov    0x7d(%eax),%dl
801086c0:	83 ca 80             	or     $0xffffff80,%edx
801086c3:	88 50 7d             	mov    %dl,0x7d(%eax)
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	8a 50 7e             	mov    0x7e(%eax),%dl
801086cc:	83 ca 0f             	or     $0xf,%edx
801086cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801086d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d5:	8a 50 7e             	mov    0x7e(%eax),%dl
801086d8:	83 e2 ef             	and    $0xffffffef,%edx
801086db:	88 50 7e             	mov    %dl,0x7e(%eax)
801086de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e1:	8a 50 7e             	mov    0x7e(%eax),%dl
801086e4:	83 e2 df             	and    $0xffffffdf,%edx
801086e7:	88 50 7e             	mov    %dl,0x7e(%eax)
801086ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ed:	8a 50 7e             	mov    0x7e(%eax),%dl
801086f0:	83 ca 40             	or     $0x40,%edx
801086f3:	88 50 7e             	mov    %dl,0x7e(%eax)
801086f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f9:	8a 50 7e             	mov    0x7e(%eax),%dl
801086fc:	83 ca 80             	or     $0xffffff80,%edx
801086ff:	88 50 7e             	mov    %dl,0x7e(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108713:	ff ff 
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010871f:	00 00 
80108721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108724:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010872b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108734:	83 e2 f0             	and    $0xfffffff0,%edx
80108737:	83 ca 02             	or     $0x2,%edx
8010873a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108743:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108749:	83 ca 10             	or     $0x10,%edx
8010874c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108755:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010875b:	83 e2 9f             	and    $0xffffff9f,%edx
8010875e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108767:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010876d:	83 ca 80             	or     $0xffffff80,%edx
80108770:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108779:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010877f:	83 ca 0f             	or     $0xf,%edx
80108782:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108791:	83 e2 ef             	and    $0xffffffef,%edx
80108794:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010879a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801087a3:	83 e2 df             	and    $0xffffffdf,%edx
801087a6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087af:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801087b5:	83 ca 40             	or     $0x40,%edx
801087b8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c1:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801087c7:	83 ca 80             	or     $0xffffff80,%edx
801087ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801087da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087dd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801087e4:	ff ff 
801087e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e9:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801087f0:	00 00 
801087f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f5:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801087fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ff:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108805:	83 e2 f0             	and    $0xfffffff0,%edx
80108808:	83 ca 0a             	or     $0xa,%edx
8010880b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108814:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010881a:	83 ca 10             	or     $0x10,%edx
8010881d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108826:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010882c:	83 ca 60             	or     $0x60,%edx
8010882f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108838:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010883e:	83 ca 80             	or     $0xffffff80,%edx
80108841:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108850:	83 ca 0f             	or     $0xf,%edx
80108853:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108862:	83 e2 ef             	and    $0xffffffef,%edx
80108865:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108874:	83 e2 df             	and    $0xffffffdf,%edx
80108877:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108886:	83 ca 40             	or     $0x40,%edx
80108889:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010888f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108892:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108898:	83 ca 80             	or     $0xffffff80,%edx
8010889b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801088ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ae:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801088b5:	ff ff 
801088b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ba:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801088c1:	00 00 
801088c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801088cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d0:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801088d6:	83 e2 f0             	and    $0xfffffff0,%edx
801088d9:	83 ca 02             	or     $0x2,%edx
801088dc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e5:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801088eb:	83 ca 10             	or     $0x10,%edx
801088ee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f7:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801088fd:	83 ca 60             	or     $0x60,%edx
80108900:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108909:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010890f:	83 ca 80             	or     $0xffffff80,%edx
80108912:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108921:	83 ca 0f             	or     $0xf,%edx
80108924:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010892a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108933:	83 e2 ef             	and    $0xffffffef,%edx
80108936:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010893c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108945:	83 e2 df             	and    $0xffffffdf,%edx
80108948:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010894e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108951:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108957:	83 ca 40             	or     $0x40,%edx
8010895a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108963:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108969:	83 ca 80             	or     $0xffffff80,%edx
8010896c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108975:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010897c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897f:	83 c0 70             	add    $0x70,%eax
80108982:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108989:	00 
8010898a:	89 04 24             	mov    %eax,(%esp)
8010898d:	e8 7e fc ff ff       	call   80108610 <lgdt>
}
80108992:	c9                   	leave  
80108993:	c3                   	ret    

80108994 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108994:	55                   	push   %ebp
80108995:	89 e5                	mov    %esp,%ebp
80108997:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010899a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010899d:	c1 e8 16             	shr    $0x16,%eax
801089a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089a7:	8b 45 08             	mov    0x8(%ebp),%eax
801089aa:	01 d0                	add    %edx,%eax
801089ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801089af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b2:	8b 00                	mov    (%eax),%eax
801089b4:	83 e0 01             	and    $0x1,%eax
801089b7:	85 c0                	test   %eax,%eax
801089b9:	74 14                	je     801089cf <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801089bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089be:	8b 00                	mov    (%eax),%eax
801089c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089c5:	05 00 00 00 80       	add    $0x80000000,%eax
801089ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089cd:	eb 48                	jmp    80108a17 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801089cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801089d3:	74 0e                	je     801089e3 <walkpgdir+0x4f>
801089d5:	e8 64 a5 ff ff       	call   80102f3e <kalloc>
801089da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089e1:	75 07                	jne    801089ea <walkpgdir+0x56>
      return 0;
801089e3:	b8 00 00 00 00       	mov    $0x0,%eax
801089e8:	eb 44                	jmp    80108a2e <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801089ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801089f1:	00 
801089f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801089f9:	00 
801089fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fd:	89 04 24             	mov    %eax,(%esp)
80108a00:	e8 e1 cf ff ff       	call   801059e6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a08:	05 00 00 00 80       	add    $0x80000000,%eax
80108a0d:	83 c8 07             	or     $0x7,%eax
80108a10:	89 c2                	mov    %eax,%edx
80108a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a15:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108a17:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a1a:	c1 e8 0c             	shr    $0xc,%eax
80108a1d:	25 ff 03 00 00       	and    $0x3ff,%eax
80108a22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2c:	01 d0                	add    %edx,%eax
}
80108a2e:	c9                   	leave  
80108a2f:	c3                   	ret    

80108a30 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108a30:	55                   	push   %ebp
80108a31:	89 e5                	mov    %esp,%ebp
80108a33:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108a36:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108a41:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a44:	8b 45 10             	mov    0x10(%ebp),%eax
80108a47:	01 d0                	add    %edx,%eax
80108a49:	48                   	dec    %eax
80108a4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108a52:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108a59:	00 
80108a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a61:	8b 45 08             	mov    0x8(%ebp),%eax
80108a64:	89 04 24             	mov    %eax,(%esp)
80108a67:	e8 28 ff ff ff       	call   80108994 <walkpgdir>
80108a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a73:	75 07                	jne    80108a7c <mappages+0x4c>
      return -1;
80108a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a7a:	eb 48                	jmp    80108ac4 <mappages+0x94>
    if(*pte & PTE_P)
80108a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a7f:	8b 00                	mov    (%eax),%eax
80108a81:	83 e0 01             	and    $0x1,%eax
80108a84:	85 c0                	test   %eax,%eax
80108a86:	74 0c                	je     80108a94 <mappages+0x64>
      panic("remap");
80108a88:	c7 04 24 c4 a1 10 80 	movl   $0x8010a1c4,(%esp)
80108a8f:	e8 c0 7a ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108a94:	8b 45 18             	mov    0x18(%ebp),%eax
80108a97:	0b 45 14             	or     0x14(%ebp),%eax
80108a9a:	83 c8 01             	or     $0x1,%eax
80108a9d:	89 c2                	mov    %eax,%edx
80108a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aa2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108aaa:	75 08                	jne    80108ab4 <mappages+0x84>
      break;
80108aac:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108aad:	b8 00 00 00 00       	mov    $0x0,%eax
80108ab2:	eb 10                	jmp    80108ac4 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108ab4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108abb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108ac2:	eb 8e                	jmp    80108a52 <mappages+0x22>
  return 0;
}
80108ac4:	c9                   	leave  
80108ac5:	c3                   	ret    

80108ac6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108ac6:	55                   	push   %ebp
80108ac7:	89 e5                	mov    %esp,%ebp
80108ac9:	53                   	push   %ebx
80108aca:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108acd:	e8 6c a4 ff ff       	call   80102f3e <kalloc>
80108ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ad5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ad9:	75 0a                	jne    80108ae5 <setupkvm+0x1f>
    return 0;
80108adb:	b8 00 00 00 00       	mov    $0x0,%eax
80108ae0:	e9 84 00 00 00       	jmp    80108b69 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108ae5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108aec:	00 
80108aed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108af4:	00 
80108af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af8:	89 04 24             	mov    %eax,(%esp)
80108afb:	e8 e6 ce ff ff       	call   801059e6 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b00:	c7 45 f4 40 d5 10 80 	movl   $0x8010d540,-0xc(%ebp)
80108b07:	eb 54                	jmp    80108b5d <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0c:	8b 48 0c             	mov    0xc(%eax),%ecx
80108b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b12:	8b 50 04             	mov    0x4(%eax),%edx
80108b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b18:	8b 58 08             	mov    0x8(%eax),%ebx
80108b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1e:	8b 40 04             	mov    0x4(%eax),%eax
80108b21:	29 c3                	sub    %eax,%ebx
80108b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b26:	8b 00                	mov    (%eax),%eax
80108b28:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108b2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108b30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3b:	89 04 24             	mov    %eax,(%esp)
80108b3e:	e8 ed fe ff ff       	call   80108a30 <mappages>
80108b43:	85 c0                	test   %eax,%eax
80108b45:	79 12                	jns    80108b59 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80108b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b4a:	89 04 24             	mov    %eax,(%esp)
80108b4d:	e8 1a 05 00 00       	call   8010906c <freevm>
      return 0;
80108b52:	b8 00 00 00 00       	mov    $0x0,%eax
80108b57:	eb 10                	jmp    80108b69 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b59:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108b5d:	81 7d f4 80 d5 10 80 	cmpl   $0x8010d580,-0xc(%ebp)
80108b64:	72 a3                	jb     80108b09 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108b69:	83 c4 34             	add    $0x34,%esp
80108b6c:	5b                   	pop    %ebx
80108b6d:	5d                   	pop    %ebp
80108b6e:	c3                   	ret    

80108b6f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108b6f:	55                   	push   %ebp
80108b70:	89 e5                	mov    %esp,%ebp
80108b72:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108b75:	e8 4c ff ff ff       	call   80108ac6 <setupkvm>
80108b7a:	a3 24 8d 11 80       	mov    %eax,0x80118d24
  switchkvm();
80108b7f:	e8 02 00 00 00       	call   80108b86 <switchkvm>
}
80108b84:	c9                   	leave  
80108b85:	c3                   	ret    

80108b86 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108b86:	55                   	push   %ebp
80108b87:	89 e5                	mov    %esp,%ebp
80108b89:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108b8c:	a1 24 8d 11 80       	mov    0x80118d24,%eax
80108b91:	05 00 00 00 80       	add    $0x80000000,%eax
80108b96:	89 04 24             	mov    %eax,(%esp)
80108b99:	e8 ae fa ff ff       	call   8010864c <lcr3>
}
80108b9e:	c9                   	leave  
80108b9f:	c3                   	ret    

80108ba0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108ba0:	55                   	push   %ebp
80108ba1:	89 e5                	mov    %esp,%ebp
80108ba3:	57                   	push   %edi
80108ba4:	56                   	push   %esi
80108ba5:	53                   	push   %ebx
80108ba6:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108ba9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108bad:	75 0c                	jne    80108bbb <switchuvm+0x1b>
    panic("switchuvm: no process");
80108baf:	c7 04 24 ca a1 10 80 	movl   $0x8010a1ca,(%esp)
80108bb6:	e8 99 79 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80108bbe:	8b 40 08             	mov    0x8(%eax),%eax
80108bc1:	85 c0                	test   %eax,%eax
80108bc3:	75 0c                	jne    80108bd1 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108bc5:	c7 04 24 e0 a1 10 80 	movl   $0x8010a1e0,(%esp)
80108bcc:	e8 83 79 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80108bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd4:	8b 40 04             	mov    0x4(%eax),%eax
80108bd7:	85 c0                	test   %eax,%eax
80108bd9:	75 0c                	jne    80108be7 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108bdb:	c7 04 24 f5 a1 10 80 	movl   $0x8010a1f5,(%esp)
80108be2:	e8 6d 79 ff ff       	call   80100554 <panic>

  pushcli();
80108be7:	e8 f6 cc ff ff       	call   801058e2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108bec:	e8 5e b9 ff ff       	call   8010454f <mycpu>
80108bf1:	89 c3                	mov    %eax,%ebx
80108bf3:	e8 57 b9 ff ff       	call   8010454f <mycpu>
80108bf8:	83 c0 08             	add    $0x8,%eax
80108bfb:	89 c6                	mov    %eax,%esi
80108bfd:	e8 4d b9 ff ff       	call   8010454f <mycpu>
80108c02:	83 c0 08             	add    $0x8,%eax
80108c05:	c1 e8 10             	shr    $0x10,%eax
80108c08:	89 c7                	mov    %eax,%edi
80108c0a:	e8 40 b9 ff ff       	call   8010454f <mycpu>
80108c0f:	83 c0 08             	add    $0x8,%eax
80108c12:	c1 e8 18             	shr    $0x18,%eax
80108c15:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108c1c:	67 00 
80108c1e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108c25:	89 f9                	mov    %edi,%ecx
80108c27:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108c2d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108c33:	83 e2 f0             	and    $0xfffffff0,%edx
80108c36:	83 ca 09             	or     $0x9,%edx
80108c39:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108c3f:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108c45:	83 ca 10             	or     $0x10,%edx
80108c48:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108c4e:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108c54:	83 e2 9f             	and    $0xffffff9f,%edx
80108c57:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108c5d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108c63:	83 ca 80             	or     $0xffffff80,%edx
80108c66:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108c6c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108c72:	83 e2 f0             	and    $0xfffffff0,%edx
80108c75:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108c7b:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108c81:	83 e2 ef             	and    $0xffffffef,%edx
80108c84:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108c8a:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108c90:	83 e2 df             	and    $0xffffffdf,%edx
80108c93:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108c99:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108c9f:	83 ca 40             	or     $0x40,%edx
80108ca2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108ca8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108cae:	83 e2 7f             	and    $0x7f,%edx
80108cb1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108cb7:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108cbd:	e8 8d b8 ff ff       	call   8010454f <mycpu>
80108cc2:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108cc8:	83 e2 ef             	and    $0xffffffef,%edx
80108ccb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108cd1:	e8 79 b8 ff ff       	call   8010454f <mycpu>
80108cd6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108cdc:	e8 6e b8 ff ff       	call   8010454f <mycpu>
80108ce1:	8b 55 08             	mov    0x8(%ebp),%edx
80108ce4:	8b 52 08             	mov    0x8(%edx),%edx
80108ce7:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108ced:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108cf0:	e8 5a b8 ff ff       	call   8010454f <mycpu>
80108cf5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108cfb:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108d02:	e8 30 f9 ff ff       	call   80108637 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108d07:	8b 45 08             	mov    0x8(%ebp),%eax
80108d0a:	8b 40 04             	mov    0x4(%eax),%eax
80108d0d:	05 00 00 00 80       	add    $0x80000000,%eax
80108d12:	89 04 24             	mov    %eax,(%esp)
80108d15:	e8 32 f9 ff ff       	call   8010864c <lcr3>
  popcli();
80108d1a:	e8 0d cc ff ff       	call   8010592c <popcli>
}
80108d1f:	83 c4 1c             	add    $0x1c,%esp
80108d22:	5b                   	pop    %ebx
80108d23:	5e                   	pop    %esi
80108d24:	5f                   	pop    %edi
80108d25:	5d                   	pop    %ebp
80108d26:	c3                   	ret    

80108d27 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d27:	55                   	push   %ebp
80108d28:	89 e5                	mov    %esp,%ebp
80108d2a:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108d2d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108d34:	76 0c                	jbe    80108d42 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108d36:	c7 04 24 09 a2 10 80 	movl   $0x8010a209,(%esp)
80108d3d:	e8 12 78 ff ff       	call   80100554 <panic>
  mem = kalloc();
80108d42:	e8 f7 a1 ff ff       	call   80102f3e <kalloc>
80108d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108d4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d51:	00 
80108d52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108d59:	00 
80108d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5d:	89 04 24             	mov    %eax,(%esp)
80108d60:	e8 81 cc ff ff       	call   801059e6 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d68:	05 00 00 00 80       	add    $0x80000000,%eax
80108d6d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108d74:	00 
80108d75:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108d79:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d80:	00 
80108d81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108d88:	00 
80108d89:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8c:	89 04 24             	mov    %eax,(%esp)
80108d8f:	e8 9c fc ff ff       	call   80108a30 <mappages>
  memmove(mem, init, sz);
80108d94:	8b 45 10             	mov    0x10(%ebp),%eax
80108d97:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da5:	89 04 24             	mov    %eax,(%esp)
80108da8:	e8 02 cd ff ff       	call   80105aaf <memmove>
}
80108dad:	c9                   	leave  
80108dae:	c3                   	ret    

80108daf <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108daf:	55                   	push   %ebp
80108db0:	89 e5                	mov    %esp,%ebp
80108db2:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108db8:	25 ff 0f 00 00       	and    $0xfff,%eax
80108dbd:	85 c0                	test   %eax,%eax
80108dbf:	74 0c                	je     80108dcd <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108dc1:	c7 04 24 24 a2 10 80 	movl   $0x8010a224,(%esp)
80108dc8:	e8 87 77 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108dcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108dd4:	e9 a6 00 00 00       	jmp    80108e7f <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ddc:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ddf:	01 d0                	add    %edx,%eax
80108de1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108de8:	00 
80108de9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ded:	8b 45 08             	mov    0x8(%ebp),%eax
80108df0:	89 04 24             	mov    %eax,(%esp)
80108df3:	e8 9c fb ff ff       	call   80108994 <walkpgdir>
80108df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108dfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108dff:	75 0c                	jne    80108e0d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108e01:	c7 04 24 47 a2 10 80 	movl   $0x8010a247,(%esp)
80108e08:	e8 47 77 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e10:	8b 00                	mov    (%eax),%eax
80108e12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e17:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1d:	8b 55 18             	mov    0x18(%ebp),%edx
80108e20:	29 c2                	sub    %eax,%edx
80108e22:	89 d0                	mov    %edx,%eax
80108e24:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e29:	77 0f                	ja     80108e3a <loaduvm+0x8b>
      n = sz - i;
80108e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2e:	8b 55 18             	mov    0x18(%ebp),%edx
80108e31:	29 c2                	sub    %eax,%edx
80108e33:	89 d0                	mov    %edx,%eax
80108e35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e38:	eb 07                	jmp    80108e41 <loaduvm+0x92>
    else
      n = PGSIZE;
80108e3a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e44:	8b 55 14             	mov    0x14(%ebp),%edx
80108e47:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e4d:	05 00 00 00 80       	add    $0x80000000,%eax
80108e52:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108e55:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108e59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e61:	8b 45 10             	mov    0x10(%ebp),%eax
80108e64:	89 04 24             	mov    %eax,(%esp)
80108e67:	e8 52 91 ff ff       	call   80101fbe <readi>
80108e6c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108e6f:	74 07                	je     80108e78 <loaduvm+0xc9>
      return -1;
80108e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e76:	eb 18                	jmp    80108e90 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108e78:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e82:	3b 45 18             	cmp    0x18(%ebp),%eax
80108e85:	0f 82 4e ff ff ff    	jb     80108dd9 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108e8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e90:	c9                   	leave  
80108e91:	c3                   	ret    

80108e92 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108e92:	55                   	push   %ebp
80108e93:	89 e5                	mov    %esp,%ebp
80108e95:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108e98:	8b 45 10             	mov    0x10(%ebp),%eax
80108e9b:	85 c0                	test   %eax,%eax
80108e9d:	79 0a                	jns    80108ea9 <allocuvm+0x17>
    return 0;
80108e9f:	b8 00 00 00 00       	mov    $0x0,%eax
80108ea4:	e9 fd 00 00 00       	jmp    80108fa6 <allocuvm+0x114>
  if(newsz < oldsz)
80108ea9:	8b 45 10             	mov    0x10(%ebp),%eax
80108eac:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108eaf:	73 08                	jae    80108eb9 <allocuvm+0x27>
    return oldsz;
80108eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eb4:	e9 ed 00 00 00       	jmp    80108fa6 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ebc:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ec1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108ec9:	e9 c9 00 00 00       	jmp    80108f97 <allocuvm+0x105>
    mem = kalloc();
80108ece:	e8 6b a0 ff ff       	call   80102f3e <kalloc>
80108ed3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108ed6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108eda:	75 2f                	jne    80108f0b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108edc:	c7 04 24 65 a2 10 80 	movl   $0x8010a265,(%esp)
80108ee3:	e8 d9 74 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eeb:	89 44 24 08          	mov    %eax,0x8(%esp)
80108eef:	8b 45 10             	mov    0x10(%ebp),%eax
80108ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef9:	89 04 24             	mov    %eax,(%esp)
80108efc:	e8 a7 00 00 00       	call   80108fa8 <deallocuvm>
      return 0;
80108f01:	b8 00 00 00 00       	mov    $0x0,%eax
80108f06:	e9 9b 00 00 00       	jmp    80108fa6 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108f0b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f12:	00 
80108f13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108f1a:	00 
80108f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1e:	89 04 24             	mov    %eax,(%esp)
80108f21:	e8 c0 ca ff ff       	call   801059e6 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f29:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f32:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108f39:	00 
80108f3a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108f3e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f45:	00 
80108f46:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4d:	89 04 24             	mov    %eax,(%esp)
80108f50:	e8 db fa ff ff       	call   80108a30 <mappages>
80108f55:	85 c0                	test   %eax,%eax
80108f57:	79 37                	jns    80108f90 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108f59:	c7 04 24 7d a2 10 80 	movl   $0x8010a27d,(%esp)
80108f60:	e8 5c 74 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108f65:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f68:	89 44 24 08          	mov    %eax,0x8(%esp)
80108f6c:	8b 45 10             	mov    0x10(%ebp),%eax
80108f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f73:	8b 45 08             	mov    0x8(%ebp),%eax
80108f76:	89 04 24             	mov    %eax,(%esp)
80108f79:	e8 2a 00 00 00       	call   80108fa8 <deallocuvm>
      kfree(mem);
80108f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f81:	89 04 24             	mov    %eax,(%esp)
80108f84:	e8 c6 9e ff ff       	call   80102e4f <kfree>
      return 0;
80108f89:	b8 00 00 00 00       	mov    $0x0,%eax
80108f8e:	eb 16                	jmp    80108fa6 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108f90:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9a:	3b 45 10             	cmp    0x10(%ebp),%eax
80108f9d:	0f 82 2b ff ff ff    	jb     80108ece <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108fa3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fa6:	c9                   	leave  
80108fa7:	c3                   	ret    

80108fa8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fa8:	55                   	push   %ebp
80108fa9:	89 e5                	mov    %esp,%ebp
80108fab:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108fae:	8b 45 10             	mov    0x10(%ebp),%eax
80108fb1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fb4:	72 08                	jb     80108fbe <deallocuvm+0x16>
    return oldsz;
80108fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fb9:	e9 ac 00 00 00       	jmp    8010906a <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108fbe:	8b 45 10             	mov    0x10(%ebp),%eax
80108fc1:	05 ff 0f 00 00       	add    $0xfff,%eax
80108fc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108fce:	e9 88 00 00 00       	jmp    8010905b <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108fdd:	00 
80108fde:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80108fe5:	89 04 24             	mov    %eax,(%esp)
80108fe8:	e8 a7 f9 ff ff       	call   80108994 <walkpgdir>
80108fed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108ff0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ff4:	75 14                	jne    8010900a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff9:	c1 e8 16             	shr    $0x16,%eax
80108ffc:	40                   	inc    %eax
80108ffd:	c1 e0 16             	shl    $0x16,%eax
80109000:	2d 00 10 00 00       	sub    $0x1000,%eax
80109005:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109008:	eb 4a                	jmp    80109054 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010900a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900d:	8b 00                	mov    (%eax),%eax
8010900f:	83 e0 01             	and    $0x1,%eax
80109012:	85 c0                	test   %eax,%eax
80109014:	74 3e                	je     80109054 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80109016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109019:	8b 00                	mov    (%eax),%eax
8010901b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109020:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109023:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109027:	75 0c                	jne    80109035 <deallocuvm+0x8d>
        panic("kfree");
80109029:	c7 04 24 99 a2 10 80 	movl   $0x8010a299,(%esp)
80109030:	e8 1f 75 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80109035:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109038:	05 00 00 00 80       	add    $0x80000000,%eax
8010903d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109040:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109043:	89 04 24             	mov    %eax,(%esp)
80109046:	e8 04 9e ff ff       	call   80102e4f <kfree>
      *pte = 0;
8010904b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010904e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109054:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010905b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109061:	0f 82 6c ff ff ff    	jb     80108fd3 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109067:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010906a:	c9                   	leave  
8010906b:	c3                   	ret    

8010906c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010906c:	55                   	push   %ebp
8010906d:	89 e5                	mov    %esp,%ebp
8010906f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80109072:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109076:	75 0c                	jne    80109084 <freevm+0x18>
    panic("freevm: no pgdir");
80109078:	c7 04 24 9f a2 10 80 	movl   $0x8010a29f,(%esp)
8010907f:	e8 d0 74 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109084:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010908b:	00 
8010908c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80109093:	80 
80109094:	8b 45 08             	mov    0x8(%ebp),%eax
80109097:	89 04 24             	mov    %eax,(%esp)
8010909a:	e8 09 ff ff ff       	call   80108fa8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010909f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090a6:	eb 44                	jmp    801090ec <freevm+0x80>
    if(pgdir[i] & PTE_P){
801090a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090b2:	8b 45 08             	mov    0x8(%ebp),%eax
801090b5:	01 d0                	add    %edx,%eax
801090b7:	8b 00                	mov    (%eax),%eax
801090b9:	83 e0 01             	and    $0x1,%eax
801090bc:	85 c0                	test   %eax,%eax
801090be:	74 29                	je     801090e9 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801090c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090ca:	8b 45 08             	mov    0x8(%ebp),%eax
801090cd:	01 d0                	add    %edx,%eax
801090cf:	8b 00                	mov    (%eax),%eax
801090d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090d6:	05 00 00 00 80       	add    $0x80000000,%eax
801090db:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801090de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e1:	89 04 24             	mov    %eax,(%esp)
801090e4:	e8 66 9d ff ff       	call   80102e4f <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801090e9:	ff 45 f4             	incl   -0xc(%ebp)
801090ec:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801090f3:	76 b3                	jbe    801090a8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801090f5:	8b 45 08             	mov    0x8(%ebp),%eax
801090f8:	89 04 24             	mov    %eax,(%esp)
801090fb:	e8 4f 9d ff ff       	call   80102e4f <kfree>
}
80109100:	c9                   	leave  
80109101:	c3                   	ret    

80109102 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109102:	55                   	push   %ebp
80109103:	89 e5                	mov    %esp,%ebp
80109105:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109108:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010910f:	00 
80109110:	8b 45 0c             	mov    0xc(%ebp),%eax
80109113:	89 44 24 04          	mov    %eax,0x4(%esp)
80109117:	8b 45 08             	mov    0x8(%ebp),%eax
8010911a:	89 04 24             	mov    %eax,(%esp)
8010911d:	e8 72 f8 ff ff       	call   80108994 <walkpgdir>
80109122:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109125:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109129:	75 0c                	jne    80109137 <clearpteu+0x35>
    panic("clearpteu");
8010912b:	c7 04 24 b0 a2 10 80 	movl   $0x8010a2b0,(%esp)
80109132:	e8 1d 74 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80109137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913a:	8b 00                	mov    (%eax),%eax
8010913c:	83 e0 fb             	and    $0xfffffffb,%eax
8010913f:	89 c2                	mov    %eax,%edx
80109141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109144:	89 10                	mov    %edx,(%eax)
}
80109146:	c9                   	leave  
80109147:	c3                   	ret    

80109148 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109148:	55                   	push   %ebp
80109149:	89 e5                	mov    %esp,%ebp
8010914b:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010914e:	e8 73 f9 ff ff       	call   80108ac6 <setupkvm>
80109153:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109156:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010915a:	75 0a                	jne    80109166 <copyuvm+0x1e>
    return 0;
8010915c:	b8 00 00 00 00       	mov    $0x0,%eax
80109161:	e9 f8 00 00 00       	jmp    8010925e <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80109166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010916d:	e9 cb 00 00 00       	jmp    8010923d <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109175:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010917c:	00 
8010917d:	89 44 24 04          	mov    %eax,0x4(%esp)
80109181:	8b 45 08             	mov    0x8(%ebp),%eax
80109184:	89 04 24             	mov    %eax,(%esp)
80109187:	e8 08 f8 ff ff       	call   80108994 <walkpgdir>
8010918c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010918f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109193:	75 0c                	jne    801091a1 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80109195:	c7 04 24 ba a2 10 80 	movl   $0x8010a2ba,(%esp)
8010919c:	e8 b3 73 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
801091a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091a4:	8b 00                	mov    (%eax),%eax
801091a6:	83 e0 01             	and    $0x1,%eax
801091a9:	85 c0                	test   %eax,%eax
801091ab:	75 0c                	jne    801091b9 <copyuvm+0x71>
      panic("copyuvm: page not present");
801091ad:	c7 04 24 d4 a2 10 80 	movl   $0x8010a2d4,(%esp)
801091b4:	e8 9b 73 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801091b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091bc:	8b 00                	mov    (%eax),%eax
801091be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801091c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091c9:	8b 00                	mov    (%eax),%eax
801091cb:	25 ff 0f 00 00       	and    $0xfff,%eax
801091d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801091d3:	e8 66 9d ff ff       	call   80102f3e <kalloc>
801091d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801091db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801091df:	75 02                	jne    801091e3 <copyuvm+0x9b>
      goto bad;
801091e1:	eb 6b                	jmp    8010924e <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
801091e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091e6:	05 00 00 00 80       	add    $0x80000000,%eax
801091eb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801091f2:	00 
801091f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801091f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091fa:	89 04 24             	mov    %eax,(%esp)
801091fd:	e8 ad c8 ff ff       	call   80105aaf <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80109202:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109205:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109208:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010920e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109211:	89 54 24 10          	mov    %edx,0x10(%esp)
80109215:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80109219:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109220:	00 
80109221:	89 44 24 04          	mov    %eax,0x4(%esp)
80109225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109228:	89 04 24             	mov    %eax,(%esp)
8010922b:	e8 00 f8 ff ff       	call   80108a30 <mappages>
80109230:	85 c0                	test   %eax,%eax
80109232:	79 02                	jns    80109236 <copyuvm+0xee>
      goto bad;
80109234:	eb 18                	jmp    8010924e <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109236:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010923d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109240:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109243:	0f 82 29 ff ff ff    	jb     80109172 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80109249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924c:	eb 10                	jmp    8010925e <copyuvm+0x116>

bad:
  freevm(d);
8010924e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109251:	89 04 24             	mov    %eax,(%esp)
80109254:	e8 13 fe ff ff       	call   8010906c <freevm>
  return 0;
80109259:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010925e:	c9                   	leave  
8010925f:	c3                   	ret    

80109260 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109260:	55                   	push   %ebp
80109261:	89 e5                	mov    %esp,%ebp
80109263:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109266:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010926d:	00 
8010926e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109271:	89 44 24 04          	mov    %eax,0x4(%esp)
80109275:	8b 45 08             	mov    0x8(%ebp),%eax
80109278:	89 04 24             	mov    %eax,(%esp)
8010927b:	e8 14 f7 ff ff       	call   80108994 <walkpgdir>
80109280:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109286:	8b 00                	mov    (%eax),%eax
80109288:	83 e0 01             	and    $0x1,%eax
8010928b:	85 c0                	test   %eax,%eax
8010928d:	75 07                	jne    80109296 <uva2ka+0x36>
    return 0;
8010928f:	b8 00 00 00 00       	mov    $0x0,%eax
80109294:	eb 22                	jmp    801092b8 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109299:	8b 00                	mov    (%eax),%eax
8010929b:	83 e0 04             	and    $0x4,%eax
8010929e:	85 c0                	test   %eax,%eax
801092a0:	75 07                	jne    801092a9 <uva2ka+0x49>
    return 0;
801092a2:	b8 00 00 00 00       	mov    $0x0,%eax
801092a7:	eb 0f                	jmp    801092b8 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801092a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ac:	8b 00                	mov    (%eax),%eax
801092ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092b3:	05 00 00 00 80       	add    $0x80000000,%eax
}
801092b8:	c9                   	leave  
801092b9:	c3                   	ret    

801092ba <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801092ba:	55                   	push   %ebp
801092bb:	89 e5                	mov    %esp,%ebp
801092bd:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801092c0:	8b 45 10             	mov    0x10(%ebp),%eax
801092c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801092c6:	e9 87 00 00 00       	jmp    80109352 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801092cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801092ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801092d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801092dd:	8b 45 08             	mov    0x8(%ebp),%eax
801092e0:	89 04 24             	mov    %eax,(%esp)
801092e3:	e8 78 ff ff ff       	call   80109260 <uva2ka>
801092e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801092eb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801092ef:	75 07                	jne    801092f8 <copyout+0x3e>
      return -1;
801092f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092f6:	eb 69                	jmp    80109361 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801092f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801092fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801092fe:	29 c2                	sub    %eax,%edx
80109300:	89 d0                	mov    %edx,%eax
80109302:	05 00 10 00 00       	add    $0x1000,%eax
80109307:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010930a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010930d:	3b 45 14             	cmp    0x14(%ebp),%eax
80109310:	76 06                	jbe    80109318 <copyout+0x5e>
      n = len;
80109312:	8b 45 14             	mov    0x14(%ebp),%eax
80109315:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109318:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010931b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010931e:	29 c2                	sub    %eax,%edx
80109320:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109323:	01 c2                	add    %eax,%edx
80109325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109328:	89 44 24 08          	mov    %eax,0x8(%esp)
8010932c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932f:	89 44 24 04          	mov    %eax,0x4(%esp)
80109333:	89 14 24             	mov    %edx,(%esp)
80109336:	e8 74 c7 ff ff       	call   80105aaf <memmove>
    len -= n;
8010933b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109341:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109344:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109347:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010934a:	05 00 10 00 00       	add    $0x1000,%eax
8010934f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109352:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109356:	0f 85 6f ff ff ff    	jne    801092cb <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010935c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109361:	c9                   	leave  
80109362:	c3                   	ret    
	...

80109364 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80109364:	55                   	push   %ebp
80109365:	89 e5                	mov    %esp,%ebp
80109367:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
8010936a:	8b 45 10             	mov    0x10(%ebp),%eax
8010936d:	89 44 24 08          	mov    %eax,0x8(%esp)
80109371:	8b 45 0c             	mov    0xc(%ebp),%eax
80109374:	89 44 24 04          	mov    %eax,0x4(%esp)
80109378:	8b 45 08             	mov    0x8(%ebp),%eax
8010937b:	89 04 24             	mov    %eax,(%esp)
8010937e:	e8 2c c7 ff ff       	call   80105aaf <memmove>
}
80109383:	c9                   	leave  
80109384:	c3                   	ret    

80109385 <strcpy>:

char* strcpy(char *s, char *t){
80109385:	55                   	push   %ebp
80109386:	89 e5                	mov    %esp,%ebp
80109388:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010938b:	8b 45 08             	mov    0x8(%ebp),%eax
8010938e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80109391:	90                   	nop
80109392:	8b 45 08             	mov    0x8(%ebp),%eax
80109395:	8d 50 01             	lea    0x1(%eax),%edx
80109398:	89 55 08             	mov    %edx,0x8(%ebp)
8010939b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010939e:	8d 4a 01             	lea    0x1(%edx),%ecx
801093a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801093a4:	8a 12                	mov    (%edx),%dl
801093a6:	88 10                	mov    %dl,(%eax)
801093a8:	8a 00                	mov    (%eax),%al
801093aa:	84 c0                	test   %al,%al
801093ac:	75 e4                	jne    80109392 <strcpy+0xd>
    ;
  return os;
801093ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801093b1:	c9                   	leave  
801093b2:	c3                   	ret    

801093b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
801093b3:	55                   	push   %ebp
801093b4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801093b6:	eb 06                	jmp    801093be <strcmp+0xb>
    p++, q++;
801093b8:	ff 45 08             	incl   0x8(%ebp)
801093bb:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
801093be:	8b 45 08             	mov    0x8(%ebp),%eax
801093c1:	8a 00                	mov    (%eax),%al
801093c3:	84 c0                	test   %al,%al
801093c5:	74 0e                	je     801093d5 <strcmp+0x22>
801093c7:	8b 45 08             	mov    0x8(%ebp),%eax
801093ca:	8a 10                	mov    (%eax),%dl
801093cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801093cf:	8a 00                	mov    (%eax),%al
801093d1:	38 c2                	cmp    %al,%dl
801093d3:	74 e3                	je     801093b8 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801093d5:	8b 45 08             	mov    0x8(%ebp),%eax
801093d8:	8a 00                	mov    (%eax),%al
801093da:	0f b6 d0             	movzbl %al,%edx
801093dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801093e0:	8a 00                	mov    (%eax),%al
801093e2:	0f b6 c0             	movzbl %al,%eax
801093e5:	29 c2                	sub    %eax,%edx
801093e7:	89 d0                	mov    %edx,%eax
}
801093e9:	5d                   	pop    %ebp
801093ea:	c3                   	ret    

801093eb <set_root_inode>:

// struct con

void set_root_inode(char* name){
801093eb:	55                   	push   %ebp
801093ec:	89 e5                	mov    %esp,%ebp
801093ee:	53                   	push   %ebx
801093ef:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
801093f2:	8b 45 08             	mov    0x8(%ebp),%eax
801093f5:	89 04 24             	mov    %eax,(%esp)
801093f8:	e8 20 01 00 00       	call   8010951d <find>
801093fd:	89 c3                	mov    %eax,%ebx
801093ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109402:	89 04 24             	mov    %eax,(%esp)
80109405:	e8 c5 93 ff ff       	call   801027cf <namei>
8010940a:	c1 e3 06             	shl    $0x6,%ebx
8010940d:	89 da                	mov    %ebx,%edx
8010940f:	81 c2 70 8d 11 80    	add    $0x80118d70,%edx
80109415:	89 42 0c             	mov    %eax,0xc(%edx)

}
80109418:	83 c4 14             	add    $0x14,%esp
8010941b:	5b                   	pop    %ebx
8010941c:	5d                   	pop    %ebp
8010941d:	c3                   	ret    

8010941e <get_name>:

void get_name(int vc_num, char* name){
8010941e:	55                   	push   %ebp
8010941f:	89 e5                	mov    %esp,%ebp
80109421:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80109424:	8b 45 08             	mov    0x8(%ebp),%eax
80109427:	c1 e0 06             	shl    $0x6,%eax
8010942a:	83 c0 10             	add    $0x10,%eax
8010942d:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109432:	83 c0 0c             	add    $0xc,%eax
80109435:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80109438:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
8010943f:	eb 03                	jmp    80109444 <get_name+0x26>
	{
		i++;
80109441:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80109444:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944a:	01 d0                	add    %edx,%eax
8010944c:	8a 00                	mov    (%eax),%al
8010944e:	84 c0                	test   %al,%al
80109450:	75 ef                	jne    80109441 <get_name+0x23>
	{
		i++;
	}
	memcpy2(name, name2, i);
80109452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109455:	89 44 24 08          	mov    %eax,0x8(%esp)
80109459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010945c:	89 44 24 04          	mov    %eax,0x4(%esp)
80109460:	8b 45 0c             	mov    0xc(%ebp),%eax
80109463:	89 04 24             	mov    %eax,(%esp)
80109466:	e8 f9 fe ff ff       	call   80109364 <memcpy2>
	name[i] = '\0';
8010946b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010946e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109471:	01 d0                	add    %edx,%eax
80109473:	c6 00 00             	movb   $0x0,(%eax)
}
80109476:	c9                   	leave  
80109477:	c3                   	ret    

80109478 <get_used>:

int get_used(){
80109478:	55                   	push   %ebp
80109479:	89 e5                	mov    %esp,%ebp
8010947b:	83 ec 18             	sub    $0x18,%esp
	int x = 0;
8010947e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109485:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010948c:	eb 2d                	jmp    801094bb <get_used+0x43>
		if(strcmp(containers[i].name, "") == 0){
8010948e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109491:	c1 e0 06             	shl    $0x6,%eax
80109494:	83 c0 10             	add    $0x10,%eax
80109497:	05 40 8d 11 80       	add    $0x80118d40,%eax
8010949c:	83 c0 0c             	add    $0xc,%eax
8010949f:	c7 44 24 04 f0 a2 10 	movl   $0x8010a2f0,0x4(%esp)
801094a6:	80 
801094a7:	89 04 24             	mov    %eax,(%esp)
801094aa:	e8 04 ff ff ff       	call   801093b3 <strcmp>
801094af:	85 c0                	test   %eax,%eax
801094b1:	75 02                	jne    801094b5 <get_used+0x3d>
			continue;
801094b3:	eb 03                	jmp    801094b8 <get_used+0x40>
		}
		x++;
801094b5:	ff 45 fc             	incl   -0x4(%ebp)
}

int get_used(){
	int x = 0;
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801094b8:	ff 45 f8             	incl   -0x8(%ebp)
801094bb:	83 7d f8 03          	cmpl   $0x3,-0x8(%ebp)
801094bf:	7e cd                	jle    8010948e <get_used+0x16>
		if(strcmp(containers[i].name, "") == 0){
			continue;
		}
		x++;
	}
	return x;
801094c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801094c4:	c9                   	leave  
801094c5:	c3                   	ret    

801094c6 <g_name>:

char* g_name(int vc_bun){
801094c6:	55                   	push   %ebp
801094c7:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
801094c9:	8b 45 08             	mov    0x8(%ebp),%eax
801094cc:	c1 e0 06             	shl    $0x6,%eax
801094cf:	83 c0 10             	add    $0x10,%eax
801094d2:	05 40 8d 11 80       	add    $0x80118d40,%eax
801094d7:	83 c0 0c             	add    $0xc,%eax
}
801094da:	5d                   	pop    %ebp
801094db:	c3                   	ret    

801094dc <is_full>:

int is_full(){
801094dc:	55                   	push   %ebp
801094dd:	89 e5                	mov    %esp,%ebp
801094df:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801094e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801094e9:	eb 25                	jmp    80109510 <is_full+0x34>
		if(strlen(containers[i].name) == 0){
801094eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ee:	c1 e0 06             	shl    $0x6,%eax
801094f1:	83 c0 10             	add    $0x10,%eax
801094f4:	05 40 8d 11 80       	add    $0x80118d40,%eax
801094f9:	83 c0 0c             	add    $0xc,%eax
801094fc:	89 04 24             	mov    %eax,(%esp)
801094ff:	e8 35 c7 ff ff       	call   80105c39 <strlen>
80109504:	85 c0                	test   %eax,%eax
80109506:	75 05                	jne    8010950d <is_full+0x31>
			return i;
80109508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950b:	eb 0e                	jmp    8010951b <is_full+0x3f>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010950d:	ff 45 f4             	incl   -0xc(%ebp)
80109510:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109514:	7e d5                	jle    801094eb <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010951b:	c9                   	leave  
8010951c:	c3                   	ret    

8010951d <find>:

int find(char* name){
8010951d:	55                   	push   %ebp
8010951e:	89 e5                	mov    %esp,%ebp
80109520:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109523:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010952a:	eb 45                	jmp    80109571 <find+0x54>
		if(strcmp(name, "") == 0){
8010952c:	c7 44 24 04 f0 a2 10 	movl   $0x8010a2f0,0x4(%esp)
80109533:	80 
80109534:	8b 45 08             	mov    0x8(%ebp),%eax
80109537:	89 04 24             	mov    %eax,(%esp)
8010953a:	e8 74 fe ff ff       	call   801093b3 <strcmp>
8010953f:	85 c0                	test   %eax,%eax
80109541:	75 02                	jne    80109545 <find+0x28>
			continue;
80109543:	eb 29                	jmp    8010956e <find+0x51>
		}
		if(strcmp(name, containers[i].name) == 0){
80109545:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109548:	c1 e0 06             	shl    $0x6,%eax
8010954b:	83 c0 10             	add    $0x10,%eax
8010954e:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109553:	83 c0 0c             	add    $0xc,%eax
80109556:	89 44 24 04          	mov    %eax,0x4(%esp)
8010955a:	8b 45 08             	mov    0x8(%ebp),%eax
8010955d:	89 04 24             	mov    %eax,(%esp)
80109560:	e8 4e fe ff ff       	call   801093b3 <strcmp>
80109565:	85 c0                	test   %eax,%eax
80109567:	75 05                	jne    8010956e <find+0x51>
			return i;
80109569:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010956c:	eb 0e                	jmp    8010957c <find+0x5f>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
8010956e:	ff 45 fc             	incl   -0x4(%ebp)
80109571:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109575:	7e b5                	jle    8010952c <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109577:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010957c:	c9                   	leave  
8010957d:	c3                   	ret    

8010957e <get_max_proc>:

int get_max_proc(int vc_num){
8010957e:	55                   	push   %ebp
8010957f:	89 e5                	mov    %esp,%ebp
80109581:	57                   	push   %edi
80109582:	56                   	push   %esi
80109583:	53                   	push   %ebx
80109584:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109587:	8b 45 08             	mov    0x8(%ebp),%eax
8010958a:	c1 e0 06             	shl    $0x6,%eax
8010958d:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109592:	8d 55 b4             	lea    -0x4c(%ebp),%edx
80109595:	89 c3                	mov    %eax,%ebx
80109597:	b8 10 00 00 00       	mov    $0x10,%eax
8010959c:	89 d7                	mov    %edx,%edi
8010959e:	89 de                	mov    %ebx,%esi
801095a0:	89 c1                	mov    %eax,%ecx
801095a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
801095a4:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
801095a7:	83 c4 40             	add    $0x40,%esp
801095aa:	5b                   	pop    %ebx
801095ab:	5e                   	pop    %esi
801095ac:	5f                   	pop    %edi
801095ad:	5d                   	pop    %ebp
801095ae:	c3                   	ret    

801095af <get_os>:

int get_os(void){
801095af:	55                   	push   %ebp
801095b0:	89 e5                	mov    %esp,%ebp
801095b2:	57                   	push   %edi
801095b3:	56                   	push   %esi
801095b4:	53                   	push   %ebx
801095b5:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[0];
801095b8:	8d 55 b4             	lea    -0x4c(%ebp),%edx
801095bb:	bb 40 8d 11 80       	mov    $0x80118d40,%ebx
801095c0:	b8 10 00 00 00       	mov    $0x10,%eax
801095c5:	89 d7                	mov    %edx,%edi
801095c7:	89 de                	mov    %ebx,%esi
801095c9:	89 c1                	mov    %eax,%ecx
801095cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.os_sz;
801095cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
801095d0:	83 c4 40             	add    $0x40,%esp
801095d3:	5b                   	pop    %ebx
801095d4:	5e                   	pop    %esi
801095d5:	5f                   	pop    %edi
801095d6:	5d                   	pop    %ebp
801095d7:	c3                   	ret    

801095d8 <get_container>:

struct container* get_container(int vc_num){
801095d8:	55                   	push   %ebp
801095d9:	89 e5                	mov    %esp,%ebp
801095db:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
801095de:	8b 45 08             	mov    0x8(%ebp),%eax
801095e1:	c1 e0 06             	shl    $0x6,%eax
801095e4:	05 40 8d 11 80       	add    $0x80118d40,%eax
801095e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
801095ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801095ef:	c9                   	leave  
801095f0:	c3                   	ret    

801095f1 <get_max_mem>:

int get_max_mem(int vc_num){
801095f1:	55                   	push   %ebp
801095f2:	89 e5                	mov    %esp,%ebp
801095f4:	57                   	push   %edi
801095f5:	56                   	push   %esi
801095f6:	53                   	push   %ebx
801095f7:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801095fa:	8b 45 08             	mov    0x8(%ebp),%eax
801095fd:	c1 e0 06             	shl    $0x6,%eax
80109600:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109605:	8d 55 b4             	lea    -0x4c(%ebp),%edx
80109608:	89 c3                	mov    %eax,%ebx
8010960a:	b8 10 00 00 00       	mov    $0x10,%eax
8010960f:	89 d7                	mov    %edx,%edi
80109611:	89 de                	mov    %ebx,%esi
80109613:	89 c1                	mov    %eax,%ecx
80109615:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80109617:	8b 45 b4             	mov    -0x4c(%ebp),%eax
}
8010961a:	83 c4 40             	add    $0x40,%esp
8010961d:	5b                   	pop    %ebx
8010961e:	5e                   	pop    %esi
8010961f:	5f                   	pop    %edi
80109620:	5d                   	pop    %ebp
80109621:	c3                   	ret    

80109622 <get_max_disk>:

int get_max_disk(int vc_num){
80109622:	55                   	push   %ebp
80109623:	89 e5                	mov    %esp,%ebp
80109625:	57                   	push   %edi
80109626:	56                   	push   %esi
80109627:	53                   	push   %ebx
80109628:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010962b:	8b 45 08             	mov    0x8(%ebp),%eax
8010962e:	c1 e0 06             	shl    $0x6,%eax
80109631:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109636:	8d 55 b4             	lea    -0x4c(%ebp),%edx
80109639:	89 c3                	mov    %eax,%ebx
8010963b:	b8 10 00 00 00       	mov    $0x10,%eax
80109640:	89 d7                	mov    %edx,%edi
80109642:	89 de                	mov    %ebx,%esi
80109644:	89 c1                	mov    %eax,%ecx
80109646:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80109648:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
8010964b:	83 c4 40             	add    $0x40,%esp
8010964e:	5b                   	pop    %ebx
8010964f:	5e                   	pop    %esi
80109650:	5f                   	pop    %edi
80109651:	5d                   	pop    %ebp
80109652:	c3                   	ret    

80109653 <get_curr_proc>:

int get_curr_proc(int vc_num){
80109653:	55                   	push   %ebp
80109654:	89 e5                	mov    %esp,%ebp
80109656:	57                   	push   %edi
80109657:	56                   	push   %esi
80109658:	53                   	push   %ebx
80109659:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010965c:	8b 45 08             	mov    0x8(%ebp),%eax
8010965f:	c1 e0 06             	shl    $0x6,%eax
80109662:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109667:	8d 55 b4             	lea    -0x4c(%ebp),%edx
8010966a:	89 c3                	mov    %eax,%ebx
8010966c:	b8 10 00 00 00       	mov    $0x10,%eax
80109671:	89 d7                	mov    %edx,%edi
80109673:	89 de                	mov    %ebx,%esi
80109675:	89 c1                	mov    %eax,%ecx
80109677:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80109679:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
8010967c:	83 c4 40             	add    $0x40,%esp
8010967f:	5b                   	pop    %ebx
80109680:	5e                   	pop    %esi
80109681:	5f                   	pop    %edi
80109682:	5d                   	pop    %ebp
80109683:	c3                   	ret    

80109684 <get_curr_mem>:

int get_curr_mem(int vc_num){
80109684:	55                   	push   %ebp
80109685:	89 e5                	mov    %esp,%ebp
80109687:	57                   	push   %edi
80109688:	56                   	push   %esi
80109689:	53                   	push   %ebx
8010968a:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010968d:	8b 45 08             	mov    0x8(%ebp),%eax
80109690:	c1 e0 06             	shl    $0x6,%eax
80109693:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109698:	8d 55 b4             	lea    -0x4c(%ebp),%edx
8010969b:	89 c3                	mov    %eax,%ebx
8010969d:	b8 10 00 00 00       	mov    $0x10,%eax
801096a2:	89 d7                	mov    %edx,%edi
801096a4:	89 de                	mov    %ebx,%esi
801096a6:	89 c1                	mov    %eax,%ecx
801096a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
801096aa:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
801096ad:	83 c4 40             	add    $0x40,%esp
801096b0:	5b                   	pop    %ebx
801096b1:	5e                   	pop    %esi
801096b2:	5f                   	pop    %edi
801096b3:	5d                   	pop    %ebp
801096b4:	c3                   	ret    

801096b5 <get_curr_disk>:

int get_curr_disk(int vc_num){
801096b5:	55                   	push   %ebp
801096b6:	89 e5                	mov    %esp,%ebp
801096b8:	57                   	push   %edi
801096b9:	56                   	push   %esi
801096ba:	53                   	push   %ebx
801096bb:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801096be:	8b 45 08             	mov    0x8(%ebp),%eax
801096c1:	c1 e0 06             	shl    $0x6,%eax
801096c4:	05 40 8d 11 80       	add    $0x80118d40,%eax
801096c9:	8d 55 b4             	lea    -0x4c(%ebp),%edx
801096cc:	89 c3                	mov    %eax,%ebx
801096ce:	b8 10 00 00 00       	mov    $0x10,%eax
801096d3:	89 d7                	mov    %edx,%edi
801096d5:	89 de                	mov    %ebx,%esi
801096d7:	89 c1                	mov    %eax,%ecx
801096d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
801096db:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801096de:	83 c4 40             	add    $0x40,%esp
801096e1:	5b                   	pop    %ebx
801096e2:	5e                   	pop    %esi
801096e3:	5f                   	pop    %edi
801096e4:	5d                   	pop    %ebp
801096e5:	c3                   	ret    

801096e6 <set_name>:

void set_name(char* name, int vc_num){
801096e6:	55                   	push   %ebp
801096e7:	89 e5                	mov    %esp,%ebp
801096e9:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
801096ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ef:	c1 e0 06             	shl    $0x6,%eax
801096f2:	83 c0 10             	add    $0x10,%eax
801096f5:	05 40 8d 11 80       	add    $0x80118d40,%eax
801096fa:	8d 50 0c             	lea    0xc(%eax),%edx
801096fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109700:	89 44 24 04          	mov    %eax,0x4(%esp)
80109704:	89 14 24             	mov    %edx,(%esp)
80109707:	e8 79 fc ff ff       	call   80109385 <strcpy>
}
8010970c:	c9                   	leave  
8010970d:	c3                   	ret    

8010970e <set_max_mem>:

void set_max_mem(int mem, int vc_num){
8010970e:	55                   	push   %ebp
8010970f:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80109711:	8b 45 0c             	mov    0xc(%ebp),%eax
80109714:	c1 e0 06             	shl    $0x6,%eax
80109717:	8d 90 40 8d 11 80    	lea    -0x7fee72c0(%eax),%edx
8010971d:	8b 45 08             	mov    0x8(%ebp),%eax
80109720:	89 02                	mov    %eax,(%edx)
}
80109722:	5d                   	pop    %ebp
80109723:	c3                   	ret    

80109724 <set_os>:

void set_os(int os){
80109724:	55                   	push   %ebp
80109725:	89 e5                	mov    %esp,%ebp
	containers[0].os_sz = os;
80109727:	8b 45 08             	mov    0x8(%ebp),%eax
8010972a:	a3 58 8d 11 80       	mov    %eax,0x80118d58
}
8010972f:	5d                   	pop    %ebp
80109730:	c3                   	ret    

80109731 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
80109731:	55                   	push   %ebp
80109732:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
80109734:	8b 45 0c             	mov    0xc(%ebp),%eax
80109737:	c1 e0 06             	shl    $0x6,%eax
8010973a:	8d 90 40 8d 11 80    	lea    -0x7fee72c0(%eax),%edx
80109740:	8b 45 08             	mov    0x8(%ebp),%eax
80109743:	89 42 08             	mov    %eax,0x8(%edx)
}
80109746:	5d                   	pop    %ebp
80109747:	c3                   	ret    

80109748 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80109748:	55                   	push   %ebp
80109749:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
8010974b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010974e:	c1 e0 06             	shl    $0x6,%eax
80109751:	8d 90 40 8d 11 80    	lea    -0x7fee72c0(%eax),%edx
80109757:	8b 45 08             	mov    0x8(%ebp),%eax
8010975a:	89 42 04             	mov    %eax,0x4(%edx)
}
8010975d:	5d                   	pop    %ebp
8010975e:	c3                   	ret    

8010975f <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010975f:	55                   	push   %ebp
80109760:	89 e5                	mov    %esp,%ebp
80109762:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
80109765:	8b 45 0c             	mov    0xc(%ebp),%eax
80109768:	c1 e0 06             	shl    $0x6,%eax
8010976b:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109770:	8b 40 0c             	mov    0xc(%eax),%eax
80109773:	8d 50 01             	lea    0x1(%eax),%edx
80109776:	8b 45 0c             	mov    0xc(%ebp),%eax
80109779:	c1 e0 06             	shl    $0x6,%eax
8010977c:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109781:	8b 00                	mov    (%eax),%eax
80109783:	39 c2                	cmp    %eax,%edx
80109785:	7e 0e                	jle    80109795 <set_curr_mem+0x36>
		cprintf("Exceded memory resource; killing container");
80109787:	c7 04 24 f4 a2 10 80 	movl   $0x8010a2f4,(%esp)
8010978e:	e8 2e 6c ff ff       	call   801003c1 <cprintf>
80109793:	eb 1f                	jmp    801097b4 <set_curr_mem+0x55>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
80109795:	8b 45 0c             	mov    0xc(%ebp),%eax
80109798:	c1 e0 06             	shl    $0x6,%eax
8010979b:	05 40 8d 11 80       	add    $0x80118d40,%eax
801097a0:	8b 40 0c             	mov    0xc(%eax),%eax
801097a3:	8d 50 01             	lea    0x1(%eax),%edx
801097a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801097a9:	c1 e0 06             	shl    $0x6,%eax
801097ac:	05 40 8d 11 80       	add    $0x80118d40,%eax
801097b1:	89 50 0c             	mov    %edx,0xc(%eax)
	}
}
801097b4:	c9                   	leave  
801097b5:	c3                   	ret    

801097b6 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
801097b6:	55                   	push   %ebp
801097b7:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
801097b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801097bc:	c1 e0 06             	shl    $0x6,%eax
801097bf:	05 40 8d 11 80       	add    $0x80118d40,%eax
801097c4:	8b 40 0c             	mov    0xc(%eax),%eax
801097c7:	8d 50 ff             	lea    -0x1(%eax),%edx
801097ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801097cd:	c1 e0 06             	shl    $0x6,%eax
801097d0:	05 40 8d 11 80       	add    $0x80118d40,%eax
801097d5:	89 50 0c             	mov    %edx,0xc(%eax)
}
801097d8:	5d                   	pop    %ebp
801097d9:	c3                   	ret    

801097da <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
801097da:	55                   	push   %ebp
801097db:	89 e5                	mov    %esp,%ebp
801097dd:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
801097e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801097e3:	c1 e0 06             	shl    $0x6,%eax
801097e6:	05 50 8d 11 80       	add    $0x80118d50,%eax
801097eb:	8b 50 04             	mov    0x4(%eax),%edx
801097ee:	8b 45 08             	mov    0x8(%ebp),%eax
801097f1:	01 d0                	add    %edx,%eax
801097f3:	85 c0                	test   %eax,%eax
801097f5:	79 05                	jns    801097fc <set_curr_disk+0x22>
801097f7:	05 ff 03 00 00       	add    $0x3ff,%eax
801097fc:	c1 f8 0a             	sar    $0xa,%eax
801097ff:	89 c2                	mov    %eax,%edx
80109801:	8b 45 0c             	mov    0xc(%ebp),%eax
80109804:	c1 e0 06             	shl    $0x6,%eax
80109807:	05 40 8d 11 80       	add    $0x80118d40,%eax
8010980c:	8b 40 08             	mov    0x8(%eax),%eax
8010980f:	39 c2                	cmp    %eax,%edx
80109811:	7e 0e                	jle    80109821 <set_curr_disk+0x47>
		cprintf("Exceded disk resource; killing container");
80109813:	c7 04 24 20 a3 10 80 	movl   $0x8010a320,(%esp)
8010981a:	e8 a2 6b ff ff       	call   801003c1 <cprintf>
8010981f:	eb 21                	jmp    80109842 <set_curr_disk+0x68>
	}
	else{
		containers[vc_num].curr_disk += disk;
80109821:	8b 45 0c             	mov    0xc(%ebp),%eax
80109824:	c1 e0 06             	shl    $0x6,%eax
80109827:	05 50 8d 11 80       	add    $0x80118d50,%eax
8010982c:	8b 50 04             	mov    0x4(%eax),%edx
8010982f:	8b 45 08             	mov    0x8(%ebp),%eax
80109832:	01 c2                	add    %eax,%edx
80109834:	8b 45 0c             	mov    0xc(%ebp),%eax
80109837:	c1 e0 06             	shl    $0x6,%eax
8010983a:	05 50 8d 11 80       	add    $0x80118d50,%eax
8010983f:	89 50 04             	mov    %edx,0x4(%eax)
	}
}
80109842:	c9                   	leave  
80109843:	c3                   	ret    

80109844 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80109844:	55                   	push   %ebp
80109845:	89 e5                	mov    %esp,%ebp
80109847:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
8010984a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010984d:	c1 e0 06             	shl    $0x6,%eax
80109850:	05 50 8d 11 80       	add    $0x80118d50,%eax
80109855:	8b 10                	mov    (%eax),%edx
80109857:	8b 45 08             	mov    0x8(%ebp),%eax
8010985a:	01 c2                	add    %eax,%edx
8010985c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010985f:	c1 e0 06             	shl    $0x6,%eax
80109862:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109867:	8b 40 04             	mov    0x4(%eax),%eax
8010986a:	39 c2                	cmp    %eax,%edx
8010986c:	7e 0e                	jle    8010987c <set_curr_proc+0x38>
		cprintf("Exceded procs resource; killing container");
8010986e:	c7 04 24 4c a3 10 80 	movl   $0x8010a34c,(%esp)
80109875:	e8 47 6b ff ff       	call   801003c1 <cprintf>
8010987a:	eb 1f                	jmp    8010989b <set_curr_proc+0x57>
	}
	else{
		containers[vc_num].curr_proc += procs;
8010987c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010987f:	c1 e0 06             	shl    $0x6,%eax
80109882:	05 50 8d 11 80       	add    $0x80118d50,%eax
80109887:	8b 10                	mov    (%eax),%edx
80109889:	8b 45 08             	mov    0x8(%ebp),%eax
8010988c:	01 c2                	add    %eax,%edx
8010988e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109891:	c1 e0 06             	shl    $0x6,%eax
80109894:	05 50 8d 11 80       	add    $0x80118d50,%eax
80109899:	89 10                	mov    %edx,(%eax)
	}
}
8010989b:	c9                   	leave  
8010989c:	c3                   	ret    

8010989d <max_containers>:

int max_containers(){
8010989d:	55                   	push   %ebp
8010989e:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
801098a0:	b8 04 00 00 00       	mov    $0x4,%eax
}
801098a5:	5d                   	pop    %ebp
801098a6:	c3                   	ret    

801098a7 <container_init>:

void container_init(){
801098a7:	55                   	push   %ebp
801098a8:	89 e5                	mov    %esp,%ebp
801098aa:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801098ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801098b4:	e9 8e 00 00 00       	jmp    80109947 <container_init+0xa0>
		strcpy(containers[i].name, "");
801098b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098bc:	c1 e0 06             	shl    $0x6,%eax
801098bf:	83 c0 10             	add    $0x10,%eax
801098c2:	05 40 8d 11 80       	add    $0x80118d40,%eax
801098c7:	83 c0 0c             	add    $0xc,%eax
801098ca:	c7 44 24 04 f0 a2 10 	movl   $0x8010a2f0,0x4(%esp)
801098d1:	80 
801098d2:	89 04 24             	mov    %eax,(%esp)
801098d5:	e8 ab fa ff ff       	call   80109385 <strcpy>
		containers[i].max_proc = 6;
801098da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098dd:	c1 e0 06             	shl    $0x6,%eax
801098e0:	05 40 8d 11 80       	add    $0x80118d40,%eax
801098e5:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
		containers[i].max_disk = 100;
801098ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098ef:	c1 e0 06             	shl    $0x6,%eax
801098f2:	05 40 8d 11 80       	add    $0x80118d40,%eax
801098f7:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 1000;
801098fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109901:	c1 e0 06             	shl    $0x6,%eax
80109904:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109909:	c7 00 e8 03 00 00    	movl   $0x3e8,(%eax)
		containers[i].curr_proc = 0;
8010990f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109912:	c1 e0 06             	shl    $0x6,%eax
80109915:	05 50 8d 11 80       	add    $0x80118d50,%eax
8010991a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		containers[i].curr_disk = 0;
80109920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109923:	c1 e0 06             	shl    $0x6,%eax
80109926:	05 50 8d 11 80       	add    $0x80118d50,%eax
8010992b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
80109932:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109935:	c1 e0 06             	shl    $0x6,%eax
80109938:	05 40 8d 11 80       	add    $0x80118d40,%eax
8010993d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109944:	ff 45 fc             	incl   -0x4(%ebp)
80109947:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
8010994b:	0f 8e 68 ff ff ff    	jle    801098b9 <container_init+0x12>
		containers[i].max_mem = 1000;
		containers[i].curr_proc = 0;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
80109951:	c9                   	leave  
80109952:	c3                   	ret    

80109953 <container_reset>:

void container_reset(int vc_num){
80109953:	55                   	push   %ebp
80109954:	89 e5                	mov    %esp,%ebp
80109956:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
80109959:	8b 45 08             	mov    0x8(%ebp),%eax
8010995c:	c1 e0 06             	shl    $0x6,%eax
8010995f:	83 c0 10             	add    $0x10,%eax
80109962:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109967:	83 c0 0c             	add    $0xc,%eax
8010996a:	c7 44 24 04 f0 a2 10 	movl   $0x8010a2f0,0x4(%esp)
80109971:	80 
80109972:	89 04 24             	mov    %eax,(%esp)
80109975:	e8 0b fa ff ff       	call   80109385 <strcpy>
	containers[vc_num].max_proc = 6;
8010997a:	8b 45 08             	mov    0x8(%ebp),%eax
8010997d:	c1 e0 06             	shl    $0x6,%eax
80109980:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109985:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
	containers[vc_num].max_disk = 100;
8010998c:	8b 45 08             	mov    0x8(%ebp),%eax
8010998f:	c1 e0 06             	shl    $0x6,%eax
80109992:	05 40 8d 11 80       	add    $0x80118d40,%eax
80109997:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 300;
8010999e:	8b 45 08             	mov    0x8(%ebp),%eax
801099a1:	c1 e0 06             	shl    $0x6,%eax
801099a4:	05 40 8d 11 80       	add    $0x80118d40,%eax
801099a9:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
	containers[vc_num].curr_proc = 0;
801099af:	8b 45 08             	mov    0x8(%ebp),%eax
801099b2:	c1 e0 06             	shl    $0x6,%eax
801099b5:	05 50 8d 11 80       	add    $0x80118d50,%eax
801099ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	containers[vc_num].curr_disk = 0;
801099c0:	8b 45 08             	mov    0x8(%ebp),%eax
801099c3:	c1 e0 06             	shl    $0x6,%eax
801099c6:	05 50 8d 11 80       	add    $0x80118d50,%eax
801099cb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
801099d2:	8b 45 08             	mov    0x8(%ebp),%eax
801099d5:	c1 e0 06             	shl    $0x6,%eax
801099d8:	05 40 8d 11 80       	add    $0x80118d40,%eax
801099dd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
801099e4:	c9                   	leave  
801099e5:	c3                   	ret    
